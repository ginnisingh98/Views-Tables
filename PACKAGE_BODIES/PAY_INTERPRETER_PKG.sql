--------------------------------------------------------
--  DDL for Package Body PAY_INTERPRETER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_INTERPRETER_PKG" AS
/* $Header: pyinterp.pkb 120.29.12010000.8 2009/05/08 13:16:24 ckesanap ship $ */
--
-- Global Utils
g_pkg                  VARCHAR2(30) := 'pay_interpreter_pkg';
g_traces BOOLEAN := hr_utility.debug_enabled; --See if hr_utility.traces should be output
g_dbg    BOOLEAN := FALSE; --Used for diagnosing issues by dev, more outputs

-- Global caches
g_business_group_id    NUMBER; -- business_group_id cache
g_leg_code   per_business_groups_perf.legislation_code%TYPE;
g_bus_grp_id per_business_groups_perf.business_group_id%TYPE;
g_key_date_cache     t_key_date_cache; -- store of min dates for ins records
TYPE t_upd_cache is
  table of varchar2(240) INDEX BY BINARY_INTEGER;
g_upd_cache          t_upd_cache; -- store of min dates for ins records
--
TYPE t_number is
  table of number INDEX BY BINARY_INTEGER;
--
g_grade_list t_number;
g_grd_assignment_id number;
--
type t_valact_rec is record
(
   assignment_id       pay_assignment_actions.assignment_id%type,
   proc_not_exist_date date,
   proc_exist_date     date
);
--
g_valact_rec t_valact_rec;
--
/* Globals for Time definitions */
g_time_definition_id   number := -1;
g_assignment_action_id number := -1;
g_process_time_def     boolean;
g_tim_def_prc_name     varchar2(70);
g_proc_set             boolean;
--
G_DISCO_NONE     number := 0;
G_DISCO_STANDARD number := 1;
G_DISCO_DF       number := 2;
--
/****************************************************************************
    Name      : initialise_global
    Purpose   : This initialises the global structre and sets the default
                values.
****************************************************************************/
procedure initialise_global(p_global_env IN OUT NOCOPY t_global_env_rec)
is
begin
--
   p_global_env.datetrack_ee_tab_use := FALSE;
   p_global_env.validate_run_actions := FALSE;
--
end initialise_global;
--
/****************************************************************************
    Name      : add_datetrack_event_to_entry
    Purpose   : Store a record of entry and datetracked event combinations
                This procedure uses the datetracked event id to hash into
                a link list of entries.
****************************************************************************/
procedure add_datetrack_event_to_entry
               (p_datetracked_evt_id in            number,
                p_element_entry_id   in            number,
                p_global_env         in out nocopy t_global_env_rec)
is
l_curr_ptr number;
begin
--
    l_curr_ptr := glo_datetrack_ee_tab.count + 1;

    glo_datetrack_ee_tab(l_curr_ptr).datetracked_evt_id :=
                    p_datetracked_evt_id;
    glo_datetrack_ee_tab(l_curr_ptr).element_entry_id :=
                    p_element_entry_id;
--
    /* Put the new entry at the head of the chain
    */
    if (glo_datetrack_ee_hash_tab.exists(p_datetracked_evt_id)) then
      glo_datetrack_ee_tab(l_curr_ptr).next_ptr :=
                  glo_datetrack_ee_hash_tab(p_datetracked_evt_id);
      glo_datetrack_ee_hash_tab(p_datetracked_evt_id) := l_curr_ptr;
    else
      glo_datetrack_ee_tab(l_curr_ptr).next_ptr := null;
      glo_datetrack_ee_hash_tab(p_datetracked_evt_id) := l_curr_ptr;
    end if;
--
end add_datetrack_event_to_entry;
--
/****************************************************************************
    Name      : clear_dt_event_for_entry
    Purpose   :
                This clears the cache relating datetracked events to
                element entries.
****************************************************************************/
procedure clear_dt_event_for_entry
               ( p_global_env         in out nocopy t_global_env_rec)
is
begin
--
    glo_datetrack_ee_tab.delete;
    glo_datetrack_ee_hash_tab.delete;
--
end clear_dt_event_for_entry;
--
/****************************************************************************
    Name      : time_period_internal
    Purpose   : calculates the start and end dates of the proration period.
    Arguments :
      IN      :  p_assignment_action_id
                 p_proration_group_id
      OUT     :  p_business_group_id
                 p_start_date
                 p_end_date
    Notes     : Private
****************************************************************************/
PROCEDURE time_period_internal(p_assignment_action_id IN  NUMBER   ,
                               p_proration_group_id   IN  NUMBER   ,
                               p_business_group_id    OUT NOCOPY NUMBER   ,
                               p_start_date           OUT NOCOPY DATE     ,
                               p_end_date             OUT NOCOPY DATE     ) AS

l_year              NUMBER      ;
l_time_def_id       NUMBER      ;
l_proration_type    VARCHAR2(10);
l_legislation_code  VARCHAR2(40);
l_esd               DATE        ;
l_eed               DATE        ;
--
-- The following cursor selects the time periods from pay_payroll_actions table.

CURSOR c_time_period IS
  SELECT    ptp.start_date start_date,
            ptp.end_date   end_date
  FROM      pay_assignment_actions  paa,
            pay_payroll_actions     ppa,
            per_time_periods        ptp
  WHERE paa.assignment_action_id = p_assignment_action_id
  AND paa.payroll_action_id = ppa.payroll_action_id
  AND nvl(ppa.date_earned,ppa.effective_date) between ptp.START_DATE and ptp.END_DATE
  AND ppa.payroll_id = ptp.payroll_id;

-- Bug 3080689, get periods even if check_date is not same as pay period end date
-- AND   ptp.time_period_id   = ppa.time_period_id; --obsoleted clause

-- The following cursor selects the start date and month of the financial year.

CURSOR c_financial_year(p_legislation_code IN VARCHAR) IS
    SELECT  to_date(rule_mode||'/'||l_year, 'DD/MM/YYYY') start_date
    FROM    pay_legislation_rules
    WHERE   legislation_code = p_legislation_code
    AND     rule_type        = 'L' ;

-- The following cursor selects the Proration Type.
-- Valid values from proration_period_type are C,F,P,PPA

CURSOR c_event_group IS
    SELECT proration_type, time_definition_id
    FROM   pay_event_groups
    WHERE  event_group_id = p_proration_group_id;

-- The following cursor selects the Legislation code.

CURSOR c_legislation_code IS
    SELECT    pbg.legislation_code  legislation_code,
              pbg.business_group_id business_group_id
    FROM      pay_assignment_actions   paa,
              pay_payroll_actions      ppa,
              per_business_groups_perf pbg
    WHERE     paa.assignment_action_id = p_assignment_action_id
    AND       paa.payroll_action_id    = ppa.payroll_action_id
    AND       ppa.business_group_id    = pbg.business_group_id    ;
--
BEGIN
    -- Finding the time period we are interested in
    FOR ctp IN c_time_period
    LOOP --{
        p_start_date := ctp.start_date;
        p_end_date   := ctp.end_date  ;
    END LOOP;  --}
    --
    if (g_traces) then
    hr_utility.trace('Dates are ' || TO_CHAR(p_start_date) || ' ' || TO_CHAR(p_end_date));
    end if;
    -- Selects the Proration Type
    FOR ceg IN c_event_group
    LOOP
        l_proration_type := ceg.proration_type;
        l_time_def_id    := ceg.time_definition_id;
    END LOOP;

    if (g_traces) then
    hr_utility.trace('Proration Type is ' || l_proration_type);
    end if;
    -- Selects the Legislation Code.
    FOR clc IN c_legislation_code
    LOOP
        l_legislation_code  := clc.legislation_code;
        p_business_group_id := clc.business_group_id;
    END LOOP;
    --
    if (g_traces) then
    hr_utility.trace('Legislation Code  ' || l_legislation_code );
    hr_utility.trace('Business Group Id ' || p_business_group_id);
    end if;

    -- The following code converts the start date to the appropriate date
    -- depending upon the Proration Type
    IF( l_time_def_id is not null) THEN
        --
        p_start_date := pay_core_dates.get_time_definition_date( l_time_def_id,
                            p_end_date,
                            p_business_group_id);
    ELSE
       IF (l_proration_type = 'P') THEN  -- P = Payroll Period
           -- Do nothing. l_start_date and l_end_date already contain the dates
           -- we are interested in.
          NULL;
       --
       ELSIF (l_proration_type = 'C') THEN
              -- C = Calendar Year --BUG 3657955, corrected Y to C
          p_start_date := TO_DATE('01/01' || TO_CHAR(p_start_date, 'YYYY'), 'DD/MM/YYYY');
           -- The above instruction gives the 01-JAN-YYYY as the start_date
       ELSIF (l_proration_type = 'F') THEN -- F = Financial Year
           l_year := TO_CHAR(p_end_date, 'YYYY');
           --
           if (g_traces) then
           hr_utility.trace('Legislation Code is ' || l_legislation_code);
           end if;
           --
           FOR cfy IN c_financial_year(l_legislation_code)
           LOOP
               p_start_date := cfy.start_date;
           END LOOP;
           --
           if (g_traces) then
           hr_utility.trace('p_start_date ' || TO_CHAR(p_start_date));
           end if;
           --
           IF (p_end_date < p_start_date) THEN
              p_start_date := TO_DATE(TO_CHAR(p_start_date, 'DD/MM/') ||
                           TO_CHAR(TO_NUMBER(TO_CHAR(p_start_date,'YYYY')) -1)
                               ,'DD/MM/YYYY');
              -- This condition covers the case where l_end_date = '31-MAY-2000' and
              -- l_start_date = '01-JUL-2000'.Obviously we should convert l_start_date to
              -- 01-JUL-1999
           END IF;
           -- We assume that the data in the field rule_mode will be in canonical_form
       ELSIF (l_proration_type = 'PPA') THEN/* Past Period Adjustment */
           p_start_date := p_start_date-1;
       END IF;
   END IF;
END time_period_internal;



/****************************************************************************
    Name      : prorate_start_date
    Purpose   : This function returns the start date of a proration period.
    Arguments :
      IN      :  p_assignment_action_id
                 p_proration_group_id
      OUT     :  p_start_date
    Notes     : Public
****************************************************************************/
FUNCTION prorate_start_date(p_assignment_action_id IN  NUMBER   ,
                 p_proration_group_id   IN  NUMBER
                ) RETURN DATE IS
l_start_date         DATE   ;
l_end_date           DATE   ;
l_business_group_id  NUMBER ;
BEGIN
    time_period_internal(p_assignment_action_id => p_assignment_action_id ,
                         p_proration_group_id   => p_proration_group_id   ,
                         p_business_group_id    => l_business_group_id    ,
                         p_start_date           => l_start_date           ,
                         p_end_date             => l_end_date             );

    RETURN l_start_date;
END prorate_start_date;



/****************************************************************************
    Name      : time_period
    Purpose   : The procedure returns 3 tables. This procedure is called by
                the interpreter.
    Arguments :
      IN      :  p_assignment_action_id
                 p_proration_group_id
                 p_start_date
                 p_end_date
      OUT     :  p_business_group_id
                 p_start_date
                 p_end_date
    Notes     : Private
****************************************************************************/
PROCEDURE time_period(p_assignment_action_id IN  NUMBER   ,
                      p_proration_group_id   IN  NUMBER   ,
                      p_element_entry_id     IN  NUMBER   ,
                      p_business_group_id    OUT NOCOPY NUMBER   ,
                      p_start_date           OUT NOCOPY DATE     ,
                      p_end_date             OUT NOCOPY DATE     ) AS

l_year              NUMBER      ;
l_proration_type    VARCHAR2(10);
l_legislation_code  VARCHAR2(40);
l_esd               DATE        ;
l_eed               DATE        ;

--  The following cursor selects the start and end date of the element entry id.
CURSOR c_element_start_end IS
    SELECT MIN(effective_start_date) esd,
           MAX(effective_end_date)   eed
    FROM   pay_element_entries_f
    WHERE  element_entry_id = p_element_entry_id;
--
BEGIN
--
   time_period_internal(p_assignment_action_id,
                        p_proration_group_id,
                        p_business_group_id,
                        p_start_date,
                        p_end_date);
--
   /** The following code ensures that we are interested in the time frame
       in which an element entry Id was valid.

       Lets say the time frame selected by using earlier instructions is

      15-JAN-1990                                                 31-OCT-1990
       |-----------------------------------------------------------|

    Shown below is the life time of the element entry id passed as an input.
                  |--------------------------------|
                 13-MAR-1990                      15-AUG-1990

    We should select the time as 13-MAR-1990 and 15-AUG-1990.

    On the parallel lines if the life time of element entry id is
                  |----------------------------------------------------------|
                 13-MAR-1990                                          30-NOV-1990
    Then we should select
                 13-MAR-1990 and 31-OCT-1990 as the time frame.

    Similarly if the life time of element entry id is
    |----------------------------------------------------------|
    01-JAN-1990                                          30-SEP-1990
    Then we should select
                 15-JAN-1990 and 30-SEP-1990 as the time frame.

   **/
--
    FOR ces IN c_element_start_end
    LOOP
        l_esd := ces.esd;
        l_eed := ces.eed;
    END LOOP;
--
    IF (NVL(l_esd, p_start_date) > p_start_date) THEN
        p_start_date := l_esd;
    END IF;
--
    IF (NVL(l_eed, p_end_date) < p_end_date) THEN
        p_end_date := l_eed;
    END IF;
    /**
      The following test case has been written to make sure that if the start
      date is 01-JAN-YYYY, and the proration event occurs on 01-JAN-YYYY. We
      do not want to report this proration event. Therefore we advance the date
      by 1. For end date this criterion is not true.
    ***/
--
    if (g_traces) then
    hr_utility.trace('Dates are ' || TO_CHAR(p_start_date) || ' ' || TO_CHAR(p_end_date));
    end if;
--
END time_period;

/****************************************************************************
    Name      : time_fn
    Purpose   : The function return the start date.
    Arguments :
      IN      :  p_assignment_action_id
                 p_proration_group_id
                 p_element_entry_id
    Notes     : Public
****************************************************************************/
FUNCTION time_fn(p_assignment_action_id IN  NUMBER   ,
                 p_proration_group_id   IN  NUMBER   ,
                 p_element_entry_id     IN  NUMBER   ) RETURN DATE IS
l_start_date         DATE   ;
l_end_date           DATE   ;
l_business_group_id  NUMBER ;
BEGIN
    /***
      Finding the time period we are interested in. Procedure time_period
      selects the appropriate time periods. This procedure also finds out
      the business group id.
     ***/
    time_period(p_assignment_action_id => p_assignment_action_id ,
                p_proration_group_id   => p_proration_group_id   ,
                p_element_entry_id     => p_element_entry_id     ,
                p_business_group_id    => l_business_group_id    ,
                p_start_date           => l_start_date           ,
                p_end_date             => l_end_date             );

    RETURN l_start_date;
END time_fn;


/****************************************************************************
    Name      : unique_sort
    Purpose   : This procedure sorts the dates and then generate the listing
                of unique dates.
    Arguments :
      IN OUT  :  p_proration_dates_temp
      IN      p_proration_dates
      OUT     :  p_proration_type
    Notes     : PRIVATE
****************************************************************************/


PROCEDURE unique_sort(p_proration_dates_temp IN OUT NOCOPY t_proration_dates_table_type ,
                      p_proration_dates      IN OUT NOCOPY t_proration_dates_table_type ,
                      p_change_type_temp     IN OUT NOCOPY  t_proration_type_table_type,
                      p_change_type          IN OUT NOCOPY  t_proration_type_table_type,
                      p_proration_type_temp  IN OUT NOCOPY  t_proration_type_table_type,
                      p_proration_type       OUT NOCOPY  t_proration_type_table_type  ,
                      p_internal_mode        IN OUT NOCOPY  varchar2)
AS
    l_table_count NUMBER := 0;
    l_counter     NUMBER := 0;
    l_sort_i      NUMBER := 0;
    l_sort_j      NUMBER := 0;
    l_var         NUMBER := 0;
    l_unique      NUMBER := 0;
    l_temp_date   DATE       ;
    l_temp_type   VARCHAR2(40);
    l_temp_pro_type VARCHAR2(40);
BEGIN
    l_table_count := p_proration_dates_temp.COUNT;
/*
    FOR l_sort_i IN 1..l_table_count LOOP
       hr_utility.trace('Unique Sort : Date  = '||p_proration_dates_temp(l_sort_i));
       hr_utility.trace('              Style = '||p_proration_type_temp(l_sort_i));
    END LOOP;
*/

    FOR l_sort_i IN 1..l_table_count
    LOOP
        l_temp_date := p_proration_dates_temp(l_sort_i);
        l_temp_type := p_change_type_temp(l_sort_i);
        l_temp_pro_type := p_proration_type_temp(l_sort_i);
        l_var       := l_sort_i                   ;
        FOR l_sort_j IN l_sort_i..l_table_count
        LOOP
            IF (p_proration_dates_temp(l_sort_j) <
                                  l_temp_date) THEN
                l_temp_date := p_proration_dates_temp(l_sort_j) ;
                l_temp_type := p_change_type_temp(l_sort_j) ;
                l_temp_pro_type := p_proration_type_temp(l_sort_j);
                l_var       := l_sort_j;
            END IF;
        END LOOP;
        p_proration_dates_temp(l_var)    := p_proration_dates_temp(l_sort_i);
        p_proration_dates_temp(l_sort_i) := l_temp_date;
        p_change_type_temp(l_var)    := p_change_type_temp(l_sort_i);
        p_change_type_temp(l_sort_i) := l_temp_type;
        p_proration_type_temp(l_var)    := p_proration_type_temp(l_sort_i);
        p_proration_type_temp(l_sort_i) := l_temp_pro_type;
    END LOOP;

    --hr_utility.trace('Sorting finished');

    IF (l_table_count >= 1) THEN
        l_temp_date          := p_proration_dates_temp(1);
        p_proration_dates(1) := p_proration_dates_temp(1);
        l_temp_type          := p_change_type_temp(1);
        p_change_type(1)     := p_change_type_temp(1);
        l_temp_pro_type      := p_proration_type_temp(1);
        p_proration_type(1)  := p_proration_type_temp(1);
    END IF;

    l_counter := 1;

    --hr_utility.trace('Finding Unique Dates');

    FOR l_unique IN 1..l_table_count
    LOOP
       --hr_utility.trace('Date = '||p_proration_dates_temp(l_unique));
       --hr_utility.trace('Style = '||p_proration_type_temp(l_unique));
       /* Proration Uniqueness is different to others */
       if (p_internal_mode = 'PRORATION') then
         IF (l_temp_date <> p_proration_dates_temp(l_unique)) then
            l_counter                   := l_counter + 1                   ;
            p_proration_dates(l_counter) :=
                         p_proration_dates_temp(l_unique);
            p_change_type(l_counter) :=
                         p_change_type_temp(l_unique);
            p_proration_type(l_counter) :=
                         p_proration_type_temp(l_unique);
            l_temp_date                 := p_proration_dates_temp(l_unique);
            l_temp_type                 := p_change_type_temp(l_unique);
            l_temp_pro_type             := p_proration_type_temp(l_unique);
          ELSE
            if (p_proration_type_temp(l_unique) = 'R') then
               p_proration_type(l_counter) :=
                         p_proration_type_temp(l_unique);
            end if;
          END IF;
       else
           IF (l_temp_date <> p_proration_dates_temp(l_unique) OR
                l_temp_type <> p_change_type_temp(l_unique)) THEN
            l_counter                   := l_counter + 1                   ;
            p_proration_dates(l_counter) :=
                         p_proration_dates_temp(l_unique);
            p_change_type(l_counter) :=
                         p_change_type_temp(l_unique);
            --p_proration_type(l_counter) := 'E'                             ;
            l_temp_date                 := p_proration_dates_temp(l_unique);
            l_temp_type                 := p_change_type_temp(l_unique);
          END IF;
       end if;
    END LOOP;
END unique_sort;

PROCEDURE event_group_info
(
     p_assignment_action_id   IN  NUMBER DEFAULT NULL         ,
     p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
     p_event_group_id	      OUT NOCOPY  NUMBER,
     p_assignment_id          OUT NOCOPY  NUMBER,
     p_business_group_id      OUT NOCOPY NUMBER,
     p_start_date	      OUT NOCOPY DATE,
     p_end_date               OUT NOCOPY DATE
) AS

    l_date_earned          DATE                                      ;

BEGIN

    -- The following statement selects the date earned.
    -- Date Earned is used while determining the Proration Group id.

    SELECT    ppa.date_earned
    INTO      l_date_earned
    FROM      pay_assignment_actions  paa,
              pay_payroll_actions    ppa
    WHERE     paa.assignment_action_id = p_assignment_action_id
    AND       paa.payroll_action_id    = ppa.payroll_action_id   ;

    -- The following statement selects the Proration Group Id

   SELECT    DISTINCT pee.assignment_id       ,
             pet.proration_group_id
    into     p_assignment_id,p_event_group_id
    FROM     pay_element_entries_f pee,
             pay_element_types_f   pet
    WHERE    pee.element_entry_id = p_element_entry_id
    AND      pee.element_type_id  = pet.element_type_id
    AND      pee.effective_start_date <= l_date_earned
    AND      pee.effective_end_date   >= time_fn(p_assignment_action_id,
                                         pet.proration_group_id ,
                                         p_element_entry_id   )
    AND      l_date_earned BETWEEN pet.effective_start_date AND pet.effective_end_date;


    --  Finding the time period we are interested in. Procedure time_period
    --  selects the appropriate time periods. This procedure also finds out
    --  the business group id.

    time_period(p_assignment_action_id => p_assignment_action_id ,
                p_proration_group_id   => p_event_group_id   ,
                p_element_entry_id     => p_element_entry_id     ,
                p_business_group_id    => p_business_group_id    ,
                p_start_date           => p_start_date           ,
                p_end_date             => p_end_date             );

    if (g_traces) then
    hr_utility.trace('Date Earned      ' || TO_CHAR(l_date_earned,'DD-MON-YYYY'));
    end if;

END;

procedure event_group_tables
(
 p_event_group_id IN NUMBER,
 p_distinct_tab   IN OUT NOCOPY t_distinct_table
) AS

-- The following cursor selects the distinct table_names associated with a
-- proration_group_id.

CURSOR c_distinct_table(p_proration_group_id IN NUMBER) IS
    SELECT DISTINCT pdt.dated_table_id     table_id          ,
                    pdt.table_name         table_name        ,
                    nvl(pdt.dyn_trigger_type,'T') dyt_type   ,
                    pdt.start_date_name    start_date_name   ,
                    pdt.end_date_name      end_date_name     ,
                    pdt.surrogate_key_name surrogate_key_name,
                    pde.datetracked_event_id datetracked_event_id,
                    pde.column_name        column_name       ,
                    pde.update_type        update_type       ,
                    pde.proration_style    proration_type,
                    pdt.owner              owner
    FROM   pay_datetracked_events pde,
           pay_dated_tables       pdt
    WHERE  pde.event_group_id = p_proration_group_id
    AND    pdt.dated_table_id = pde.dated_table_id
    order  by pdt.dated_table_id,pde.update_type;  --ordering vital bug 3598389

    l_tab_counter          NUMBER                                    ;
    l_tab_ori_counter      NUMBER                                    ;


BEGIN

    -- The following cursor selects the distinct/Unique table Ids.
    -- POTENTIAL CACHING CANDIDATE
    -- Caching in a PL/SQL table on proration_group_id

  if (p_event_group_id is not null) then
    IF (t_proration_group_tab.EXISTS(p_event_group_id) = FALSE) THEN

      l_tab_counter     := p_distinct_tab.COUNT + 1;
      l_tab_ori_counter := l_tab_counter           ;

      t_proration_group_tab(p_event_group_id).range_start := 0;
      t_proration_group_tab(p_event_group_id).range_end := 0    ;

      if (g_traces) then
      hr_utility.trace('Miss in Cache');
      end if;
      FOR cdt IN c_distinct_table(p_event_group_id)
      LOOP
        if (g_dbg) then
        hr_utility.trace('Store Event in Cache: '||l_tab_counter);
        end if;
        p_distinct_tab(l_tab_counter).table_id           := cdt.table_id          ;
        p_distinct_tab(l_tab_counter).table_name         := cdt.table_name        ;
        p_distinct_tab(l_tab_counter).owner              := cdt.owner    ;
        p_distinct_tab(l_tab_counter).dyt_type           := cdt.dyt_type          ;
        p_distinct_tab(l_tab_counter).surrogate_key_name := cdt.surrogate_key_name;
        p_distinct_tab(l_tab_counter).start_date_name    := cdt.start_date_name   ;
        p_distinct_tab(l_tab_counter).end_date_name      := cdt.end_date_name     ;
        p_distinct_tab(l_tab_counter).datetracked_event_id := cdt.datetracked_event_id    ;
        p_distinct_tab(l_tab_counter).update_type        := cdt.update_type    ;
        p_distinct_tab(l_tab_counter).column_name        := cdt.column_name    ;
        p_distinct_tab(l_tab_counter).proration_type     := cdt.proration_type    ;

        t_proration_group_tab(p_event_group_id).range_start := l_tab_ori_counter;
        t_proration_group_tab(p_event_group_id).range_end := l_tab_counter    ;

        l_tab_counter := l_tab_counter + 1;
      END LOOP;
    END IF;
  end if;
END;

procedure event_group_tables
(
 p_event_group_id IN NUMBER
) AS
BEGIN
    event_group_tables(p_event_group_id, t_distinct_tab);
END;


PROCEDURE event_group_table_inserted
(
 p_date_counter 	IN OUT NOCOPY NUMBER,
 p_assignment_id	IN NUMBER,
 p_effective_date	IN date,
 p_surrogate_key	IN NUMBER,
 p_business_group_id    IN NUMBER,
 p_dated_table_id    	IN NUMBER,
 p_start_date_name      IN VARCHAR2,
 p_end_date_name        IN VARCHAR2,
 l_proration_type      IN VARCHAR2,
 t_proration_dates_temp IN OUT NOCOPY  t_proration_dates_table_type ,
 t_proration_change_type IN OUT NOCOPY t_proration_type_table_type,
 t_proration_type      IN OUT NOCOPY t_proration_type_table_type,
 t_detailed_output       in OUT NOCOPY  t_detailed_output_table_type
) AS

insert_row number;
upd_end_date number;
upd_start_date number;

BEGIN



 SELECT count(*)
 into    insert_row
 FROM	pay_process_events ppe,
	pay_event_updates peu
 WHERE  ppe.assignment_id=p_assignment_id
 AND	ppe.surrogate_key=p_surrogate_key
 AND    ppe.business_group_id=p_business_group_id
 AND    ppe.event_update_id=peu.event_update_id
 AND    peu.event_type='I'
 AND    ppe.effective_date=p_effective_date
 AND    peu.dated_table_id=p_dated_table_id;

 SELECT count(*)
 INTo   upd_end_date
 FROM   pay_process_events ppe,
        pay_event_updates peu
 WHERE  ppe.assignment_id=p_assignment_id
 AND    ppe.surrogate_key=p_surrogate_key
 AND    ppe.business_group_id=p_business_group_id
 AND    ppe.event_update_id=peu.event_update_id
 AND    peu.event_type='U'
 AND    peu.column_name=p_end_date_name
 AND    ppe.calculation_date+1=p_effective_date
 AND    peu.dated_table_id=p_dated_table_id;

 SELECT count(*)
 INTo   upd_start_date
 FROM   pay_process_events ppe,
        pay_event_updates peu
 WHERE  ppe.assignment_id=p_assignment_id
 AND    ppe.surrogate_key=p_surrogate_key
 AND    ppe.business_group_id=p_business_group_id
 AND    ppe.event_update_id=peu.event_update_id
 AND    peu.event_type='U'
 AND    peu.column_name=p_start_date_name
 AND    ppe.calculation_date=p_effective_date
 AND    peu.dated_table_id=p_dated_table_id;


if (upd_start_date+upd_end_date <> insert_row)
then
 t_proration_dates_temp(p_date_counter):= p_effective_date;
 t_proration_change_type(p_date_counter):= 'I';
 t_proration_type(p_date_counter):= l_proration_type;
 t_detailed_output(p_date_counter).dated_table_id := p_dated_table_id;
 t_detailed_output(p_date_counter).datetracked_event := 'I';
 t_detailed_output(p_date_counter).surrogate_key := p_surrogate_key;
 t_detailed_output(p_date_counter).effective_date := p_effective_date;
 t_detailed_output(p_date_counter).proration_type := l_proration_type;
 p_date_counter := p_date_counter + 1;
end if;

 EXCEPTION WHEN NO_DATA_FOUND THEN NULL;


END;




PROCEDURE create_statement
(
 p_proration_group_id  	IN NUMBER,
 p_table_id	  	IN NUMBER,
 p_table_name 		IN VARCHAR2,
 p_surrogate_key_name 	IN VARCHAR2,
 p_surrogate_key 	IN NUMBER,
 p_start_date_name	IN VARCHAR2,
 p_end_date_name	IN VARCHAR2,
 p_statement		OUT NOCOPY VARCHAR2,
 p_global_env           IN OUT NOCOPY t_global_env_rec,
 t_dynamic_sql          IN OUT NOCOPY t_dynamic_sql_tab,
 p_dynamic_counter     OUT NOCOPY NUMBER
) AS


  l_loop_flag            BOOLEAN                                   ;
  l_column_string        VARCHAR2(2000)                             ;


BEGIN

  -- The following cursor selects distinct columns for the table id.The logic
  -- then creates a string of all the column names.

  l_column_string := NULL;
  l_loop_flag     := FALSE;
  t_dynamic_sql.DELETE;
  p_dynamic_counter := 0;

  -- POTENTIAL CACHING CANDIDATE
  -- Code below is a potential caching candidate. We can cahche on
  -- l_proration_group_id or table_id.
  FOR k in p_global_env.monitor_start_ptr..p_global_env.monitor_end_ptr loop
     -- if this event is on the table were checking and its an U
     IF    (glo_monitored_events(k).table_id = p_table_id
          and glo_monitored_events(k).update_type = 'U'
          and glo_monitored_events(k).column_name is not null) THEN

       p_dynamic_counter := p_dynamic_counter + 1;

       t_dynamic_sql(p_dynamic_counter).column_name     := glo_monitored_events(k).column_name;
       t_dynamic_sql(p_dynamic_counter).date_tracked_id := glo_monitored_events(k).datetracked_event_id;
       t_dynamic_sql(p_dynamic_counter).proration_style := glo_monitored_events(k).proration_type;

       if (l_loop_flag = TRUE) then
        l_column_string := l_column_string || ',' || glo_monitored_events(k).column_name;
       else
        l_column_string := glo_monitored_events(k).column_name;
        l_loop_flag     := TRUE;
       end if;
     END IF;
  END LOOP;


   p_statement   := 'SELECT ' || l_column_string ||
                    ' FROM ' ||
                    p_table_name ||
                    ' WHERE ' || p_surrogate_key_name || ' = :p_surrogate_key ' ||
                    ' AND  :col1 BETWEEN ' ||
                    p_start_date_name || ' AND ' ||
                    p_end_date_name;
  if (g_dbg) then
    hr_utility.trace('-Dynamic SQL: ' || p_statement);
  end if;

END;


PROCEDURE execute_statement
(
 p_statement            IN VARCHAR2,
 t_dynamic_sql          IN OUT NOCOPY t_dynamic_sql_tab,
 p_surrogate_key	IN NUMBER,
 p_effective_date       IN DATE,
 p_start_date_name      IN VARCHAR2,
 p_end_date_name        IN VARCHAR2,
 p_dynamic_counter      IN NUMBER,
 p_updated_column_name	IN VARCHAR2,
 p_final_effective_date OUT NOCOPY DATE
) AS


    l_dummy                NUMBER                                    ;
    l_new_sql_fetch        NUMBER                                    ;
    l_old_sql_fetch        NUMBER                                    ;
    l_counter              NUMBER                                    ;
    l_cursor_id            INTEGER                                   ;

BEGIN

   -- The following code creates the dynamic SQL for the column names selected
   -- above.
   l_cursor_id   := DBMS_SQL.OPEN_CURSOR;
   hr_utility.trace(p_statement);
   DBMS_SQL.PARSE(l_cursor_id  , p_statement  , DBMS_SQL.V7);
--
   DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_surrogate_key', p_surrogate_key);
   IF (p_updated_column_name = p_start_date_name) THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':col1', p_effective_date - 1);
if (g_dbg) then
      hr_utility.trace('Effective Start Date changed');
      hr_utility.trace('date = '||(p_effective_date - 1));
      hr_utility.trace('key = '||p_surrogate_key);
end if;
   ELSIF (p_updated_column_name = p_end_date_name) THEN
--
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':col1', p_effective_date);
if (g_dbg) then
     hr_utility.trace('date = '||p_effective_date);
     hr_utility.trace('key = '||p_surrogate_key);
end if;
--
   END IF;

   FOR l_counter IN 1..p_dynamic_counter
   LOOP
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, l_counter, t_dynamic_sql(l_counter).old_value, 100);
   END LOOP;

   l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);

   LOOP
      -- This loop will always return a single row or no row
     l_old_sql_fetch := 0;
     IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
        EXIT;
     END IF;

     -- The following loop executes for all the columns
     FOR l_counter IN 1..p_dynamic_counter
     LOOP
        l_old_sql_fetch := 1;
        -- l_old_sql_fetch variable will become = 1 whenever the
        -- LOOP is executed.  Whenever l_old_sql_fetch becomes = 1,
        -- It means that a row is fetched from the cursor. This
        -- variable will be used to decide whether a Delete event occured.
        DBMS_SQL.COLUMN_VALUE(l_cursor_id, l_counter, t_dynamic_sql(l_counter).old_value);
     END LOOP;
   END LOOP;

   IF (p_updated_column_name = p_start_date_name) THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':col1', p_effective_date);
      p_final_effective_date := p_effective_date;
if (g_dbg) then
      hr_utility.trace('Effective Start Date changed');
      hr_utility.trace('date = '||p_effective_date);
      hr_utility.trace('key = '||p_surrogate_key);
end if;
   ELSIF (p_updated_column_name = p_end_date_name) THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':col1', p_effective_date + 1);
      p_final_effective_date := p_effective_date + 1;
if (g_dbg) then
      hr_utility.trace('Effective End  Date changed');
      hr_utility.trace('date = '||(p_effective_date + 1));
      hr_utility.trace('key = '||p_surrogate_key);
end if;
   END IF;

   -- The following loop executes for all the columns

   FOR l_counter IN 1..p_dynamic_counter
   LOOP
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, l_counter,
      t_dynamic_sql(l_counter).new_value, 100);
   END LOOP;
   l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);

   if (g_dbg) then
   hr_utility.trace('Second statement executed ');
   end if;

   LOOP

     -- This loop will always return a single row or no row

     l_new_sql_fetch := 0;

     IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
       EXIT;
     END IF;

     FOR l_counter IN 1..p_dynamic_counter
     LOOP
        l_new_sql_fetch := 1;
        DBMS_SQL.COLUMN_VALUE(l_cursor_id, l_counter,t_dynamic_sql(l_counter).new_value);
        if (g_traces) then
        hr_utility.trace('old = '||t_dynamic_sql(l_counter).old_value||' new = '||t_dynamic_sql(l_counter).new_value);
        end if;

     END LOOP;
   END LOOP;

   DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
END;

PROCEDURE add_event_procedure
(
 p_table_id              IN            NUMBER,
 p_business_group_id     in            NUMBER,
 p_column_name           IN            VARCHAR2,
 p_global_env            IN OUT NOCOPY t_global_env_rec
)
IS
--
-- The following cursor selects the third party PL/SQL procedures names
-- from pay_event_procedure
CURSOR c_event_proc(p_table_id    IN NUMBER   ,
                    p_column_name IN VARCHAR2 ,
                    p_bg_id       IN NUMBER) IS
    SELECT    pep.procedure_name
    FROM      pay_event_procedures pep,
              per_business_groups_perf  pbg
    WHERE     pep.dated_table_id     = p_table_id
    AND       UPPER(pep.column_name) = UPPER(p_column_name)
    AND       nvl(pep.procedure_type, 'E') = 'E'
    AND       pbg.business_group_id  = p_bg_id
    AND       ( (   pep.business_group_id = pbg.business_group_id
                and pep.legislation_code is null)
                or (    pep.legislation_code = pbg.legislation_code
                    and pep.business_group_id is null)
                or (    pep.legislation_code is null
                    and pep.business_group_id is null)
              )
    ORDER BY  NVL(pep.business_group_id, -100) asc,
              NVL(pep.legislation_code, ' ')   asc;
--
/*
 Order by clause will ensure that the rows that are selected in the following
 order i.e. Global, Legislation, and Client specific.

<Null> <Null> in business_group_id, and legislation_code resp = GLOBAL
<Null>  XXX   in business_group_id, and legislation_code resp = LEGISLATION
 XXX   <Null> in business_group_id, and legislation_code resp = CLIENT specific.

  The typical Data in the table will be

  Procedure_Name   Business Group Id   Legislation_code
  --------------   -----------------   ----------------
  Global           <NULL>              <NULL>
  Legislation      <NULL>              US
  Client           100                 <NULL>

  We want to sort this in the order of Global, Legislation, and then Client.

  The NVLs will generate the output as

  Procedure_Name   Business Group Id   Legislation_code
  --------------   -----------------   ----------------
  Global           -100                ' '
  Legislation      -100                US
  Client           100                 ' '

  If we order by the abouve output Business Group Id, Legislation_code
  We will get the output as

    Procedure_Name   Business Group Id   Legislation_code
  --------------   -----------------   ----------------
  Global           -100                ' '
  Legislation      -100                US
  Client           100                 ' '
*/
--
   new_idx number;
   proc_found boolean;
   evt_ptr number;
--
BEGIN
--
      new_idx := glo_table_columns.count + 1;
      glo_table_columns(new_idx).column_name := p_column_name;
      glo_table_columns(new_idx).evt_proc_start_ptr := null;
      glo_table_columns(new_idx).evt_proc_end_ptr := null;
      glo_table_columns(new_idx).next_ptr :=
                            glo_column_hash_tab(p_table_id);
      glo_column_hash_tab(p_table_id) := new_idx;
--
      proc_found := FALSE;
      for evtrec in c_event_proc(p_table_id,
                                 p_column_name,
                                 p_business_group_id) loop
--
         evt_ptr := glo_event_procedures.count +1;
--
         if (proc_found = FALSE) then
            glo_table_columns(new_idx).evt_proc_start_ptr := evt_ptr;
            proc_found := TRUE;
         end if;
--
         glo_event_procedures(evt_ptr).procedure_name :=
                                                evtrec.procedure_name;
--
      end loop;
--
      if (proc_found = TRUE) then
         glo_table_columns(new_idx).evt_proc_end_ptr := evt_ptr;
      end if;
--
END add_event_procedure;

PROCEDURE load_event_procedure
(
 p_table_id              IN            NUMBER,
 p_business_group_id     in            NUMBER,
 p_column_name           IN            VARCHAR2,
 p_table_column_idx         OUT NOCOPY NUMBER,
 p_global_env            IN OUT NOCOPY t_global_env_rec
)
IS
--
   proc_found boolean;
   curr_idx number;
--
BEGIN
--
   if (glo_column_hash_tab.exists(p_table_id)) then
--
      proc_found := FALSE;
      curr_idx := glo_column_hash_tab(p_table_id);
      while (curr_idx is not null and proc_found <> TRUE) loop
--
        if (glo_table_columns(curr_idx).column_name =
            p_column_name) then
--
          proc_found := TRUE;
          p_table_column_idx := curr_idx;
--
        else
--
          curr_idx := glo_table_columns(curr_idx).next_ptr;
--
        end if;
      end loop;
--
      if (proc_found = FALSE) then
--
         add_event_procedure (p_table_id => p_table_id,
                              p_business_group_id => p_business_group_id,
                              p_column_name => p_column_name,
                              p_global_env => p_global_env);
         p_table_column_idx := glo_column_hash_tab(p_table_id);
--
      end if;

--
   else
--
      glo_column_hash_tab(p_table_id) := null;
      add_event_procedure (p_table_id => p_table_id,
                           p_business_group_id => p_business_group_id,
                           p_column_name => p_column_name,
                           p_global_env => p_global_env);
      p_table_column_idx := glo_column_hash_tab(p_table_id);
--
   end if;
--
END load_event_procedure;

PROCEDURE event_group_procedure
(
 p_table_id     IN NUMBER,
 p_element_entry_id IN NUMBER,
 p_assignment_action_id IN NUMBER,
 p_business_group_id in NUMBER,
 p_surrogate_key IN NUMBER,
 p_column_name  IN VARCHAR2,
 p_old_value    IN VARCHAR2,
 p_new_value    IN VARCHAR2,
 p_output_result IN OUT NOCOPY VARCHAR2,
 p_final_effective_date IN DATE default null,
 p_global_env            IN OUT NOCOPY t_global_env_rec
) AS

    l_proc_string          VARCHAR2(400)                             ;
    l_cursor_id            INTEGER                                     ;
    l_dummy                NUMBER                                    ;
    l_proc_name            VARCHAR2(40)                              ;
    curr_idx               NUMBER;



BEGIN
  p_output_result := 'TRUE';
--
  load_event_procedure
  (
   p_table_id              => p_table_id,
   p_business_group_id     => p_business_group_id,
   p_column_name           => p_column_name,
   p_table_column_idx      => curr_idx,
   p_global_env            => p_global_env
  );
--
  if (glo_table_columns(curr_idx).evt_proc_start_ptr is not null)
  then
    FOR evt_idx IN glo_table_columns(curr_idx).evt_proc_start_ptr..
                   glo_table_columns(curr_idx).evt_proc_end_ptr
    LOOP
      l_proc_name := glo_event_procedures(evt_idx).procedure_name;
      -- Execute Procedure name

      if (g_traces) then
      hr_utility.trace('Procedure Name ' || l_proc_name);
      end if;

      l_proc_string := 'BEGIN ' || l_proc_name || '(' ||
                       'p_surrogate_key        => :col1,' ||
                       'p_element_entry_id     => :col2,' ||
                       'p_assignment_action_id => :col3,' ||
                       'p_column_name          => :col4,' ||
                       'p_old_value            => :col5,' ||
                       'p_new_value            => :col6,' ||
                       'p_output_result        => :col7,' ||
                       'p_date                 => :col8'  ||
                       '); END;';

      l_cursor_id := DBMS_SQL.OPEN_CURSOR;

      if (g_dbg) then
      hr_utility.trace('Parameters');
      hr_utility.trace('p_surrogate_key = '||p_surrogate_key);
      hr_utility.trace('p_element_entry_id = '||p_element_entry_id);
      hr_utility.trace('p_assignment_action_id = '||p_assignment_action_id);
      hr_utility.trace('p_column_name = '||p_column_name);
      hr_utility.trace('p_old_value = '||p_old_value);
      hr_utility.trace('p_new_value = '||p_new_value);
      end if;
      DBMS_SQL.PARSE(l_cursor_id, l_proc_string, DBMS_SQL.V7);

      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':col1',p_surrogate_key);

      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':col2', p_element_entry_id);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':col3', p_assignment_action_id);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':col4', p_column_name);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':col5', p_old_value);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':col6', p_new_value);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':col7', p_output_result, 40);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':col8', p_final_effective_date);
      if (g_dbg) then
      hr_utility.trace('All Variables Bound');
      end if;

      l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);

      if (g_dbg) then
      hr_utility.trace('Procedure Executed');
      end if;

      DBMS_SQL.VARIABLE_VALUE(l_cursor_id, ':col7', p_output_result);
      --hr_utility.trace('Got Results');

      DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

      --hr_utility.trace('Closed cursor');

      IF (p_output_result = 'FALSE') THEN
        --  False means no proration event occured
         hr_utility.trace('Not a valid event');
         EXIT;
      END IF;
    END LOOP;
  end if;
END;

/* ----------------------------------------------------------
   Add an identified event to our store of identified events
   ---------------------------------------------------------- */
PROCEDURE add_found_event
(
  p_effective_date     IN DATE,
  p_creation_date      IN DATE DEFAULT NULL,
  p_update_type        IN VARCHAR2,
  p_change_mode        IN VARCHAR2,
  p_proration_type     IN VARCHAR2,
  p_datetracked_event  IN VARCHAR2,
  p_column_name        IN VARCHAR2 default 'none',
  p_old_val            IN VARCHAR2 default null,
  p_new_val            IN VARCHAR2 default null,
  p_change_values      IN VARCHAR2 default null,
  p_element_entry_id   IN NUMBER   default null,
  p_surrogate_key      IN VARCHAR2,
  p_dated_table_id     IN NUMBER,
  p_date_counter          IN OUT NOCOPY number,
  p_global_env            IN OUT NOCOPY t_global_env_rec,
  t_proration_dates_temp  IN OUT NOCOPY  t_proration_dates_table_type,
  t_proration_change_type IN OUT NOCOPY t_proration_type_table_type,
  t_proration_type        IN OUT NOCOPY t_proration_type_table_type,
  t_detailed_output       IN OUT NOCOPY  t_detailed_output_table_type
) AS

  l_proc  VARCHAR2(80) := 'add_found_event';

BEGIN
--p_update_type, eg I.E,
--p_change_mode, eg DATE_EARNED,
--proration_type,
 t_proration_dates_temp(p_date_counter):= p_effective_date;

 t_proration_change_type(p_date_counter):= p_update_type;

 t_proration_type(p_date_counter):= p_proration_type;

 t_detailed_output(p_date_counter).dated_table_id := p_dated_table_id;
 t_detailed_output(p_date_counter).datetracked_event :=p_datetracked_event;
 t_detailed_output(p_date_counter).surrogate_key := p_surrogate_key;
 t_detailed_output(p_date_counter).effective_date := p_effective_date;
 t_detailed_output(p_date_counter).creation_date := p_creation_date;
 t_detailed_output(p_date_counter).update_type := p_update_type;
 t_detailed_output(p_date_counter).proration_type := p_proration_type;
 t_detailed_output(p_date_counter).change_mode := p_change_mode;
 t_detailed_output(p_date_counter).column_name := p_column_name;
 t_detailed_output(p_date_counter).old_value := p_old_val;
 t_detailed_output(p_date_counter).new_value := p_new_val;
 t_detailed_output(p_date_counter).change_values
             := nvl(p_change_values,p_old_val||' -> '||p_new_val);
--
 -- If this is for a specific element entry, the maintain the
 -- entry hash cache
--
  if (p_element_entry_id is not null) then
    if (glo_ee_hash_table.exists(p_element_entry_id)) then
       t_detailed_output(p_date_counter).next_ee :=
                    glo_ee_hash_table(p_element_entry_id);
       glo_ee_hash_table(p_element_entry_id) := p_date_counter;
    else
       t_detailed_output(p_date_counter).next_ee := null;
       glo_ee_hash_table(p_element_entry_id) := p_date_counter;
    end if;
    t_detailed_output(p_date_counter).element_entry_id := p_element_entry_id;
  else
     t_detailed_output(p_date_counter).element_entry_id := null;
     t_detailed_output(p_date_counter).next_ee := null;
  end if;


 if (g_traces) then
 hr_utility.trace('>> FOUND EVENT: '||p_datetracked_event||', desc '||t_detailed_output(p_date_counter).change_values);
 end if;

 p_date_counter := p_date_counter + 1;
 if (g_dbg) then
 hr_utility.trace('   For base record  :' || p_surrogate_key  );
 hr_utility.trace('   On Table         :' || p_dated_table_id );
 hr_utility.trace('   Event Type       :' || p_update_type    );
 hr_utility.trace('>> adding at pos p_date_counter: '||p_date_counter);
 end if;

END add_found_event;

--
-- Name : validate_affected_actions
-- Description
--   This procedure is used by RetroNotification and CC to
--   ensure that assignment actions have been affected by the
--   change
--
procedure validate_affected_actions(p_assignment_id in number,
                                    p_effective_date in date,
                                    p_valid             out nocopy boolean)
is
l_dummy varchar2(5);
begin
--
    if (p_assignment_id <> g_valact_rec.assignment_id) then
       g_valact_rec.proc_not_exist_date := to_date('4712/12/31 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
       g_valact_rec.proc_exist_date := to_date('1900/01/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
       g_valact_rec.assignment_id := p_assignment_id;
    end if;
--
    --
    -- This code is trying to find out if we already know
    -- whether processes exist for the date supplied
    --
    if (p_effective_date >= g_valact_rec.proc_not_exist_date) then
       p_valid := FALSE;
    elsif (p_effective_date <= g_valact_rec.proc_exist_date) then
       p_valid := TRUE;
    else
       --
       -- This date hasn't already been calculated, we
       -- need to find out if processes exist
       --
       begin
--
         select ''
           into l_dummy
           from dual
          where exists (select ''
                          from pay_payroll_actions ppa,
                               pay_assignment_actions paa
                         where paa.assignment_id  = p_assignment_id
                           and ppa.payroll_action_id = paa.payroll_action_id
                           and ppa.action_type in ('R', 'Q', 'B', 'V')
                           and (ppa.effective_date >= p_effective_date
                             or ppa.date_earned >= p_effective_date)
                       );
--
         p_valid := TRUE;
         g_valact_rec.proc_exist_date := p_effective_date;
--
       exception
           when no_data_found then
               p_valid := FALSE;
               g_valact_rec.proc_not_exist_date := p_effective_date;
       end;
    end if;
--
end validate_affected_actions;

procedure perform_qualifications
(
 p_table_id             IN NUMBER,
 p_final_effective_date IN DATE,
 p_creation_date        IN DATE DEFAULT NULL,
 p_start_date           IN DATE,
 p_end_date             IN DATE,
 p_element_entry_id IN NUMBER,
 p_assignment_action_id IN NUMBER,
 p_business_group_id    IN NUMBER,
 p_assignment_id        IN NUMBER,
 p_process_mode         in varchar2,
 p_update_type          in varchar2,
 p_change_mode          in varchar2,
 p_change_values        in varchar2,
 p_surrogate_key IN NUMBER,
 p_date_counter         IN OUT NOCOPY NUMBER,
 p_global_env            IN OUT NOCOPY t_global_env_rec,
 p_datetracked_id       IN NUMBER,
 p_column_name          IN VARCHAR2,
 p_old_value            IN VARCHAR2,
 p_new_value            IN VARCHAR2,
 p_proration_style      IN VARCHAR2,
 t_proration_dates_temp IN OUT NOCOPY  t_proration_dates_table_type,
 t_proration_change_type IN OUT NOCOPY t_proration_type_table_type,
 t_proration_type      IN OUT NOCOPY t_proration_type_table_type,
 t_detailed_output       in OUT NOCOPY  t_detailed_output_table_type,
 p_run_event_proc        in out nocopy boolean,
 p_event_proc_res        in out nocopy varchar2
)
is
    l_output_result        VARCHAR2(40)                              ;
    l_valid                VARCHAR2(10);
    l_type                VARCHAR2(10);

begin
--
   l_output_result := 'TRUE';
--
-- Before we do anything do we need to check if there are any payroll runs
-- out there for this effective_date
--
   if (p_global_env.validate_run_actions) then
--
     declare
       l_valid boolean;
     begin
        validate_affected_actions(p_assignment_id  => p_assignment_id,
                                  p_effective_date => p_final_effective_date,
                                  p_valid          => l_valid);
        if (l_valid = FALSE) then
          l_output_result := 'FALSE';
        end if;
     end ;
--
   end if;
--
   -- The above condition checks whether or not the values of the two SELECTS
   -- were same.
--
   if (l_output_result = 'TRUE') then
--
     -- Now perform the generic data comparison.
     begin
       pay_interpreter_pkg.generic_data_validation
                            (p_table_id ,
                             p_datetracked_id,
                             p_old_value,
                             p_new_value,
                             p_final_effective_date,
                             p_surrogate_key,
                             p_element_entry_id,
                             p_assignment_id,
                             l_valid,
                             l_type,
                             p_global_env);
     exception
       -- This is possible if the hire date is chagned.
       when no_data_found then
         l_output_result := 'FALSE';
       when others then
         raise;
     end;
     --
     if (l_valid = 'N') then
        l_output_result := 'FALSE';
     end if;
   end if;

   -- Now check the external procedure calls

   if (l_output_result = 'TRUE')
   then
     if (p_run_event_proc = TRUE) then
        event_group_procedure(p_table_id,
                            p_element_entry_id,
                            p_assignment_action_id,
                            p_business_group_id,
                            p_surrogate_key,
                            p_column_name,
                            p_old_value,
                            p_new_value,
                            l_output_result,
                            p_final_effective_date,
                            p_global_env);
--
        p_run_event_proc := FALSE;
        p_event_proc_res := l_output_result;
--
     else
        l_output_result := p_event_proc_res;
     end if;
   end if;

   IF(l_output_result = 'TRUE') THEN

     -- t_proration_dates_temp is a temporary table. This stores all the dates
     --  irrespective of the fact the dates are unique or not

     IF (    p_process_mode = 'ENTRY_EFFECTIVE_DATE'
         and p_final_effective_date > p_start_date
         and p_final_effective_date <= p_end_date)
        or
        (p_process_mode <> 'ENTRY_EFFECTIVE_DATE')
     THEN

        add_found_event (
         p_effective_date        =>  p_final_effective_date,
         p_creation_date         =>  p_creation_date,
         p_update_type           =>  p_update_type,
         p_change_mode           =>  p_change_mode,
         p_proration_type        =>  p_proration_style,
         p_datetracked_event     =>  p_datetracked_id,
                                  -- possible future enhancement request
         p_column_name           =>  p_column_name,
         p_old_val               =>  p_old_value,
         p_new_val               =>  p_new_value,
         p_element_entry_id      =>  p_element_entry_id,
         p_surrogate_key         =>  p_surrogate_key,
         p_change_values         =>  p_change_values,
         p_dated_table_id        =>  p_table_id,
         p_global_env            =>  p_global_env,
         p_date_counter          =>  p_date_counter,
         t_proration_dates_temp  =>  t_proration_dates_temp,
         t_proration_change_type =>  t_proration_change_type,
         t_proration_type        =>  t_proration_type,
         t_detailed_output       =>  t_detailed_output
       );

     END IF;
  END IF;
end;





PROCEDURE compare_values
(
 p_table_id	  	IN NUMBER,
 p_table_name           IN VARCHAR2,
 p_final_effective_date IN DATE,
 p_creation_date        IN DATE DEFAULT NULL,
 p_start_date           IN DATE,
 p_end_date             IN DATE,
 p_dynamic_counter      IN NUMBER,
 p_element_entry_id IN NUMBER,
 p_assignment_action_id IN NUMBER,
 p_business_group_id    IN NUMBER,
 p_assignment_id        IN NUMBER,
 p_process_mode         in varchar2,  --eg ENTRY_CREATION_DATE
 p_change_mode           in varchar2, --eg DATE_PROCESSED
 p_surrogate_key IN NUMBER,
 p_date_counter		IN OUT NOCOPY NUMBER,
 p_global_env            IN OUT NOCOPY t_global_env_rec,
 t_dynamic_sql           IN t_dynamic_sql_tab,
 t_proration_dates_temp IN OUT NOCOPY  t_proration_dates_table_type,
 t_proration_change_type IN OUT NOCOPY t_proration_type_table_type,
 t_proration_type      IN OUT NOCOPY t_proration_type_table_type,
 l_proration_type      IN VARCHAR2,
 t_detailed_output       in OUT NOCOPY  t_detailed_output_table_type
) AS

    l_counter              NUMBER                                    ;
    process_event          boolean;
    curr_ptr               number;
    run_event_proc         boolean;
    event_proc_res         VARCHAR2(40);

BEGIN

   run_event_proc := TRUE;
   event_proc_res := 'TRUE';

   --  In the following loop the old and new values of the columns are compared
   FOR l_counter IN 1..p_dynamic_counter
   LOOP
      IF (NVL(t_dynamic_sql(l_counter).old_value,'-9999') <>
          NVL(t_dynamic_sql(l_counter).new_value,'-9999'))
      THEN
         if (g_dbg) then
         hr_utility.trace('Value of the column has changed');
         end if;
--
         -- We could be saving the results in one for 2 modes.
         -- First mode is that the events are being generated for a
         -- single element entry.
         -- Second mode is that a list of element entries have been
         -- suppled cross referencing the datetracked events for which
         -- we are looking.
--
         if (p_global_env.datetrack_ee_tab_use = FALSE) then
--
           run_event_proc := TRUE;
           event_proc_res := 'TRUE';
--
           perform_qualifications
           (
            p_table_id              => p_table_id,
            p_final_effective_date  => p_final_effective_date,
            p_creation_date         => p_creation_date,
            p_start_date            => p_start_date,
            p_end_date              => p_end_date,
            p_element_entry_id      => p_element_entry_id,
            p_assignment_action_id  => p_assignment_action_id,
            p_business_group_id     => p_business_group_id,
            p_assignment_id         => p_assignment_id,
            p_process_mode          => p_process_mode,
            p_update_type           => 'U',
            p_change_mode           => p_change_mode,
            p_change_values         => null,
            p_surrogate_key         => p_surrogate_key,
            p_date_counter          => p_date_counter,
            p_global_env            => p_global_env,
            p_datetracked_id        => t_dynamic_sql(l_counter).date_tracked_id,
            p_column_name           => t_dynamic_sql(l_counter).column_name,
            p_old_value             => t_dynamic_sql(l_counter).old_value,
            p_new_value             => t_dynamic_sql(l_counter).new_value,
            p_proration_style       => t_dynamic_sql(l_counter).proration_style,
            t_proration_dates_temp  => t_proration_dates_temp,
            t_proration_change_type => t_proration_change_type,
            t_proration_type        => t_proration_type,
            t_detailed_output       => t_detailed_output,
            p_run_event_proc        => run_event_proc,
            p_event_proc_res        => event_proc_res
           );
--
         else
--
           if (glo_datetrack_ee_hash_tab.exists(
                  t_dynamic_sql(l_counter).date_tracked_id))
           then
--
              run_event_proc := TRUE;
              event_proc_res := 'TRUE';
--
              curr_ptr :=
                  glo_datetrack_ee_hash_tab(
                             t_dynamic_sql(l_counter).date_tracked_id);
--
              while (curr_ptr is not null) loop
--
                -- Need to decide if the event is relevent to the current entry
--
                process_event := FALSE;
                if (p_table_name = 'PAY_ELEMENT_ENTRIES_F') then
--
                   if (glo_datetrack_ee_tab(curr_ptr).element_entry_id
                       = p_surrogate_key) then
                       process_event := TRUE;
                       run_event_proc := TRUE;
                       event_proc_res := 'TRUE';
                   end if;
--
                elsif (p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F') then
--
                  declare
                  l_dummy varchar2(2);
                  l_ee_id pay_element_entries_f.element_entry_id%type;
                  begin
                     l_ee_id :=
                      glo_datetrack_ee_tab(curr_ptr).element_entry_id;
                     select ''
                       into l_dummy
                       from dual
                      where exists (select ''
                                      from pay_element_entry_values_f
                                     where element_entry_id = l_ee_id
                                       and element_entry_value_id =
                                                         p_surrogate_key
                                   );
                     process_event := TRUE;
                     run_event_proc := TRUE;
                     event_proc_res := 'TRUE';
                  exception
                     when no_data_found then
                        process_event := FALSE;
                  end;
--
                else
                   process_event := TRUE;
                end if;

--
                if (process_event = TRUE) then
--
hr_utility.trace(' >= Found a valid event, valid for our ee, now check qualifiers');
                  perform_qualifications
                  (
                   p_table_id              => p_table_id,
                   p_final_effective_date  => p_final_effective_date,
                   p_creation_date         => p_creation_date,
                   p_start_date            => p_start_date,
                   p_end_date              => p_end_date,
                   p_element_entry_id      =>
                   glo_datetrack_ee_tab(curr_ptr).element_entry_id,
                   p_assignment_action_id  => p_assignment_action_id,
                   p_business_group_id     => p_business_group_id,
                   p_assignment_id         => p_assignment_id,
                   p_process_mode          => p_process_mode,
                   p_update_type           => 'U',
                   p_change_mode           => p_change_mode,
                   p_change_values         => null,
                   p_surrogate_key         => p_surrogate_key,
                   p_date_counter          => p_date_counter,
                   p_global_env            => p_global_env,
                   p_datetracked_id        => t_dynamic_sql(l_counter).date_tracked_id,
                   p_column_name           => t_dynamic_sql(l_counter).column_name,
                   p_old_value             => t_dynamic_sql(l_counter).old_value,
                   p_new_value             => t_dynamic_sql(l_counter).new_value,
                   p_proration_style       => t_dynamic_sql(l_counter).proration_style,
                   t_proration_dates_temp  => t_proration_dates_temp,
                   t_proration_change_type => t_proration_change_type,
                   t_proration_type        => t_proration_type,
                   t_detailed_output       => t_detailed_output,
                   p_run_event_proc        => run_event_proc,
                   p_event_proc_res        => event_proc_res
                  );
--
                end if;
--
                curr_ptr := glo_datetrack_ee_tab(curr_ptr).next_ptr;
--
              end loop;
            end if;
         end if;
--
      END IF;
    END LOOP;

END;



PROCEDURE event_group_table_correction
(
 p_end_date_name        IN VARCHAR2,
 p_start_date_name      IN VARCHAR2,
 p_updated_column_name  IN VARCHAR2,
 p_table_id             in NUMBER,
 p_surrogate_key        in NUMBER,
 p_change_values        in varchar2,
 p_effective_date       IN DATE,
 p_date_counter         IN OUT NOCOPY number,
 store_correction       IN OUT NOCOPY NUMBER,
 is_correction          IN OUT NOCOPY NUMBER,
 l_proration_type      IN VARCHAR2,
 t_proration_dates_temp IN OUT NOCOPY  t_proration_dates_table_type,
 t_proration_change_type IN OUT NOCOPY t_proration_type_table_type,
 t_proration_type      IN OUT NOCOPY t_proration_type_table_type,
 t_detailed_output       in OUT NOCOPY  t_detailed_output_table_type
) AS

BEGIN


 is_correction:=0;

 if (p_start_date_name <> p_updated_column_name AND
      p_end_date_name <> p_updated_column_name)
 THEN
     is_correction:=1;
 END IF;
 IF (store_correction = 0 AND is_correction=1)
 THEN
     t_proration_dates_temp(p_date_counter):= p_effective_date;
     t_proration_change_type(p_date_counter):= 'C';
     t_proration_type(p_date_counter):= l_proration_type;
     t_detailed_output(p_date_counter).dated_table_id := p_table_id;
     t_detailed_output(p_date_counter).datetracked_event := 'C';
     t_detailed_output(p_date_counter).surrogate_key := p_surrogate_key;
     t_detailed_output(p_date_counter).column_name := p_updated_column_name;
     t_detailed_output(p_date_counter).change_values := p_change_values;
     p_date_counter := p_date_counter + 1;
 END IF;
END;

PROCEDURE event_group_table_deleted
(
 p_table_name           IN VARCHAR2,
 p_table_id             IN NUMBER,
 p_surrogate_key_name   IN VARCHAR2,
 p_surrogate_key        IN NUMBER,
 p_end_date_name        IN VARCHAR2,
 p_effective_date       IN DATE,
 p_updated_column_name   IN VARCHAR2,
 p_date_counter         IN OUT NOCOPY number,
 store_delete		IN OUT NOCOPY NUMBER,
 is_delete		IN OUT NOCOPY NUMBER,
 l_proration_type      IN VARCHAR2,
 t_proration_dates_temp IN OUT NOCOPY  t_proration_dates_table_type,
 t_proration_change_type IN OUT NOCOPY t_proration_type_table_type,
 t_proration_type      IN OUT NOCOPY t_proration_type_table_type,
 t_detailed_output       in OUT NOCOPY  t_detailed_output_table_type
) AS

  l_statement 		 VARCHAR2(1000)				   ;
  l_result 		 NUMBER					   ;
  l_date		 date;


BEGIN
  is_delete:=0;
  l_result:=0;
  IF (p_updated_column_name=p_end_date_name)
  THEN

    l_statement   := 'SELECT 1 FROM  dual  WHERE  EXISTS (select 1 from '
                                || p_table_name || ' where ' ||
	            		p_surrogate_key_name ||' = :p_surrogate_key '||
                    		' and ' ||  p_end_date_name ||' >  :col1)';
    if (g_traces) then
    hr_utility.trace('-Dynamic SQL ' || l_statement);
    end if;

    execute immediate l_statement into l_result using p_surrogate_key, p_effective_date;
    return;

 END IF;
  EXCEPTION
    when NO_DATA_FOUND then
    is_delete:=1;
    IF (store_delete = 0)
    THEN
     t_proration_dates_temp(p_date_counter):= p_effective_date;
     t_proration_change_type(p_date_counter):= 'E';
     t_proration_type(p_date_counter):= l_proration_type;
     t_detailed_output(p_date_counter).dated_table_id := p_table_id;
     t_detailed_output(p_date_counter).datetracked_event := 'E';
     t_detailed_output(p_date_counter).surrogate_key := p_surrogate_key;
     p_date_counter := p_date_counter + 1;
    END IF;
END;

PROCEDURE event_group_table_updated
(
 p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
 p_assignment_action_id IN NUMBER,
 p_business_group_id    IN NUMBER,
 p_assignment_id        IN NUMBER,
 p_process_mode         IN VARCHAR2,
 p_change_mode          IN VARCHAR2,
 p_proration_group_id   IN NUMBER,
 p_table_id             IN NUMBER,
 p_table_name           IN VARCHAR2,
 p_surrogate_key_name   IN VARCHAR2,
 p_surrogate_key        IN NUMBER,
 p_start_date_name      IN VARCHAR2,
 p_end_date_name        IN VARCHAR2,
 p_effective_date       IN DATE,
 p_creation_date        IN DATE DEFAULT NULL,
 p_start_date           IN DATE,
 p_end_date             IN DATE,
 p_updated_column_name   IN VARCHAR2,
 p_date_counter         IN OUT NOCOPY number,
 p_global_env           IN OUT NOCOPY t_global_env_rec,
 l_proration_type      IN VARCHAR2,
 t_dynamic_sql		IN OUT NOCOPY t_dynamic_sql_tab,
 t_proration_dates_temp IN OUT NOCOPY  t_proration_dates_table_type,
 t_proration_change_type IN OUT NOCOPY t_proration_type_table_type,
 t_proration_type      IN OUT NOCOPY t_proration_type_table_type,
 t_detailed_output       in OUT NOCOPY  t_detailed_output_table_type
) AS

    l_old_sql_fetch        NUMBER                                    ;
    l_statement            VARCHAR2(2000)                            ;
    l_dynamic_counter      NUMBER                                    ;
    l_final_effective_date DATE                                      ;

BEGIN


   create_statement(p_proration_group_id,
                    p_table_id,
                    p_table_name,
                    p_surrogate_key_name,
                    p_surrogate_key,
                    p_start_date_name,
                    p_end_date_name,
                    l_statement,
                    p_global_env,
                    t_dynamic_sql,
                    l_dynamic_counter);

   execute_statement(l_statement,
                     t_dynamic_sql,
			               p_surrogate_key,
                     p_effective_date,
                     p_start_date_name,
                     p_end_date_name,
                     l_dynamic_counter,
                     p_updated_column_name,
                     l_final_effective_date);
--
   compare_values(p_table_id,
                        p_table_name,
                        l_final_effective_date,
                        p_creation_date,
                        p_start_date,
                        p_end_date,
                        l_dynamic_counter,
			                  p_element_entry_id,
			                  p_assignment_action_id,
                        p_business_group_id,
			                  p_assignment_id,
                        p_process_mode,
                        p_change_mode,
                        p_surrogate_key,
                        p_date_counter,
                        p_global_env,
			t_dynamic_sql,
                        t_proration_dates_temp,
                        t_proration_change_type,
                        t_proration_type,
                        l_proration_type,
                        t_detailed_output );
--
END;


procedure get_prorated_dates
(
    p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
    p_assignment_action_id   IN  NUMBER DEFAULT NULL          ,
    p_time_definition_id     IN  NUMBER DEFAULT NULL          ,
    t_detailed_output       OUT NOCOPY  t_detailed_output_table_type ,
    t_proration_dates       OUT NOCOPY  t_proration_dates_table_type ,
    t_proration_type        OUT NOCOPY  t_proration_type_table_type
)
is
--
--
    t_proration_change_type t_proration_type_table_type;
--
    t_proration_dates_temp t_proration_dates_table_type        ;
    t_proration_change_type_temp t_proration_type_table_type;
    t_proration_type_temp        t_proration_type_table_type;
    l_global_env            t_global_env_rec;
    l_internal_mode varchar2(30) := 'PRORATION';
--
    function process_time_def(p_assignment_action_id in           number,
                              p_time_definition_id   in            number)
             return boolean
    is
    l_recalc boolean;
    begin
--
      l_recalc := FALSE;
      if (p_time_definition_id <> g_time_definition_id) then
         begin
           select procedure_name
             into g_tim_def_prc_name
             from pay_event_procedures
            where time_definition_id = p_time_definition_id
              and nvl(procedure_type, 'E') = 'T';
--
           l_recalc := TRUE;
           g_proc_set := TRUE;
--
         exception
            when no_data_found then
               g_process_time_def := TRUE;
               g_assignment_action_id := p_assignment_action_id;
               g_time_definition_id := p_time_definition_id;
               g_proc_set := FALSE;
               g_process_time_def := TRUE;
         end;
      end if;
--
      if (p_assignment_action_id <> g_assignment_action_id) then
         l_recalc := TRUE;
      end if;
--
      if (l_recalc = TRUE and g_proc_set = TRUE) then
--
         declare
            l_cursor_id            INTEGER;
            l_dummy                NUMBER;
            l_res                  number;
            l_proc_string          VARCHAR2(400);
         begin

            if (g_traces) then
                  hr_utility.trace('Procedure Name ' || g_tim_def_prc_name);
            end if;

            l_proc_string := 'BEGIN :res := ' || g_tim_def_prc_name || '(' ||
                             'p_assignment_action_id => :aa' ||
                             '); END;';

            l_cursor_id := DBMS_SQL.OPEN_CURSOR;

            if (g_dbg) then
                hr_utility.trace('Parameters');
            end if;

            DBMS_SQL.PARSE(l_cursor_id, l_proc_string, DBMS_SQL.V7);

            DBMS_SQL.BIND_VARIABLE(l_cursor_id,':res', l_res);
            DBMS_SQL.BIND_VARIABLE(l_cursor_id,':aa',p_assignment_action_id);

            if (g_dbg) then
                hr_utility.trace('All Variables Bound');
            end if;

            l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);

            if (g_dbg) then
                hr_utility.trace('Procedure Executed');
            end if;

            DBMS_SQL.VARIABLE_VALUE(l_cursor_id, ':res', l_res);
--
            g_process_time_def := TRUE;
            if (l_res = 0) then
                g_process_time_def := FALSE;
            end if;
            g_assignment_action_id := p_assignment_action_id;
            g_time_definition_id := p_time_definition_id;

            DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
         end;
      end if;
--
      return g_process_time_def;
--
    end process_time_def;
--
    procedure get_time_periods(p_assignment_action_id in           number,
                        p_time_definition_id         in            number,
                        p_element_entry_id           in            number,
                        t_detailed_output            in out nocopy t_detailed_output_table_type ,
                        t_proration_dates_temp       in out nocopy t_proration_dates_table_type,
                        t_proration_change_type_temp in out nocopy t_proration_type_table_type,
                        t_proration_type_temp        in out nocopy t_proration_type_table_type
                       )
    is
--
    cursor find_start_dates (p_asg_act in number,
                             p_time_def in number
                            )
    is
    select ptp_td.start_date
      from per_time_periods       ptp_td,
           pay_assignment_actions paa,
           pay_payroll_actions    ppa,
           per_time_periods       ptp_ppa
     where ptp_td.time_definition_id = p_time_def
       and paa.assignment_action_id = p_asg_act
       and paa.payroll_action_id = ppa.payroll_action_id
       and ppa.payroll_id = ptp_ppa.payroll_id
       and ppa.date_earned between ptp_ppa.start_date
                               and ptp_ppa.end_date
       and ptp_td.start_date > ptp_ppa.start_date
       and ptp_td.start_date <= ptp_ppa.end_date;
--
    l_date_counter number;
    l_ee_min_date date;
    l_ee_max_date date;
--
    begin
--
      select min(effective_start_date),
             max(effective_end_date)
        into l_ee_min_date,
             l_ee_max_date
        from pay_element_entries_f
       where element_entry_id = p_element_entry_id;
--
      hr_utility.trace('td id '|| p_time_definition_id );
      hr_utility.trace('asg act id '|| p_assignment_action_id );
      l_date_counter := t_proration_dates_temp.count + 1;
--
      for datrec in find_start_dates(p_assignment_action_id,
                                     p_time_definition_id) loop
--
          hr_utility.trace('Allocation Date '||datrec.start_date);
--
          if (datrec.start_date > l_ee_min_date
               and datrec.start_date <= l_ee_max_date) then
--
             add_found_event
             (
               p_effective_date     => datrec.start_date,
               p_creation_date      => null,
               p_update_type        => null,
               p_change_mode        => null,
               p_proration_type     => 'E',
               p_datetracked_event  => null,
               p_surrogate_key      => null,
               p_dated_table_id     => null,
               p_date_counter          => l_date_counter,
               p_global_env            => l_global_env,
               t_proration_dates_temp  => t_proration_dates_temp,
               t_proration_change_type => t_proration_change_type_temp,
               t_proration_type        => t_proration_type_temp,
               t_detailed_output       => t_detailed_output
             );
--
          end if;
--
      end loop;
--
    end get_time_periods;
--
begin
--
    -- Clear out the caches
--
    t_proration_dates.delete;
    t_proration_dates_temp.delete;
    t_proration_change_type.delete;
    t_proration_change_type_temp.delete;
    t_proration_type_temp.delete;
    t_proration_type.delete;
--
    -- First generate the proration events
--
    entry_affected(
                p_element_entry_id,
                p_assignment_action_id,
                NULL,
                NULL,
                NULL,
                NULL,
                l_internal_mode,
                hr_api.g_sot,
                hr_api.g_eot,
                sysdate,
                'N',
                null,
                t_detailed_output,
                t_proration_dates_temp,
                t_proration_change_type_temp,
                t_proration_type_temp);
--
    -- Now generate the allocation events if needed
--
    if (p_time_definition_id is not null) then
--
       if (process_time_def(p_assignment_action_id,
                            p_time_definition_id) = TRUE) then
          get_time_periods(p_assignment_action_id,
                           p_time_definition_id,
                           p_element_entry_id,
                           t_detailed_output,
                           t_proration_dates_temp,
                           t_proration_change_type_temp,
                           t_proration_type_temp
                          );
       end if;
--
    end if;
--
    -- Finally create a sorted unique list
--
    unique_sort(p_proration_dates_temp => t_proration_dates_temp ,
                p_proration_dates      => t_proration_dates      ,
                p_change_type_temp     => t_proration_change_type_temp,
                p_proration_type_temp  => t_proration_type_temp,
                p_change_type          => t_proration_change_type,
                p_proration_type       => t_proration_type,
                p_internal_mode        => l_internal_mode);
--
end get_prorated_dates;

/****************************************************************************
    Name      : entry_affected
    Purpose   : The procedure returns 3 tables. This procedure is called by
                the Payroll.
    Arguments :
      IN      :  p_element_entry_id
                 p_assignment_action_id
      OUT     :  t_detailed_output
                 t_proration_dates
                 t_proration_type
    Notes     : PUBLIC
****************************************************************************/

-- Main Entry Point, 5 params, called from orig PRORATION code
--
PROCEDURE entry_affected
(
    p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
    p_assignment_action_id   IN  NUMBER DEFAULT NULL          ,
    t_detailed_output       OUT NOCOPY  t_detailed_output_table_type ,
    t_proration_dates       OUT NOCOPY  t_proration_dates_table_type ,
    t_proration_type        OUT NOCOPY  t_proration_type_table_type
) AS

 t_proration_change_type t_proration_type_table_type;

BEGIN

-- Call main overloaded entry_affected, 15 params
-- Created as part of ADV_RETRONOT enhancement.
-- Allows calling in different historic modes
--
 entry_affected(
    p_element_entry_id,
		p_assignment_action_id,
		NULL,
		NULL,
		NULL,
		NULL,
    'PRORATION',
    hr_api.g_sot,
    hr_api.g_eot,
    sysdate,
    'Y',
    null,
		t_detailed_output,
		t_proration_dates,
		t_proration_change_type,
		t_proration_type);
END entry_affected;  --5params

-- Main Entry Point, 7 params, called from orig RETRONOT code
--
PROCEDURE entry_affected
(
    p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
    p_assignment_id          IN  NUMBER DEFAULT NULL          ,
    p_mode                   IN  VARCHAR2 DEFAULT NULL        ,
    p_process                IN  VARCHAR2 DEFAULT NULL        ,
    p_event_group_id         IN  NUMBER DEFAULT NULL          ,
    t_proration_dates       OUT NOCOPY  t_proration_dates_table_type ,
    t_proration_change_type OUT NOCOPY  t_proration_type_table_type
) AS

t_proration_type   t_proration_type_table_type;
t_detailed_output  t_detailed_output_table_type;
BEGIN

-- Call main overloaded entry_affected, 15 params
-- Created as part of ADV_RETRONOT enhancement.
-- Allows calling in different historic modes
--

entry_affected (
    p_element_entry_id,
		NULL,
		p_assignment_id,
		p_mode,
		p_process,
		p_event_group_id,
    'ENTRY_RETROSTATUS',
    hr_api.g_sot,
    hr_api.g_eot,
    sysdate,
    'Y',
    null,
		t_detailed_output,
		t_proration_dates,
		t_proration_change_type,
		t_proration_type);
END entry_affected;  --7params

-- Main Entry Point, 11 params, called from somewhere
--
PROCEDURE entry_affected

(
    p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
    p_assignment_action_id   IN  NUMBER DEFAULT NULL          ,
    p_assignment_id	         IN  NUMBER DEFAULT NULL	      ,
    p_mode		               IN  VARCHAR2 DEFAULT NULL	      ,
    p_process		             IN  VARCHAR2 DEFAULT NULL	      ,
    p_event_group_id	       IN  NUMBER DEFAULT NULL	      ,
    p_process_mode           IN  VARCHAR2 DEFAULT 'ENTRY_EFFECTIVE_DATE' ,
    t_detailed_output       OUT NOCOPY  t_detailed_output_table_type ,
    t_proration_dates       OUT NOCOPY  t_proration_dates_table_type ,
    t_proration_change_type OUT NOCOPY  t_proration_type_table_type,
    t_proration_type        OUT NOCOPY  t_proration_type_table_type
) AS
BEGIN

-- Call main overloaded entry_affected, 15 params
-- Created as part of ADV_RETRONOT enhancement.
-- Allows calling in different historic modes
--
entry_affected (
  p_element_entry_id,
  NULL,
  p_assignment_id,
  p_mode,
  p_process,
  p_event_group_id,
  'ENTRY_RETROSTATUS',
  hr_api.g_sot,
  hr_api.g_eot,
  sysdate,
  'Y',
    null,
  t_detailed_output,
  t_proration_dates,
  t_proration_change_type,
  t_proration_type);
END entry_affected;  --11params


/****************************************************************************
    Name      : asg_action_affected
    Purpose   : The procedure is used in Continous Calc.
    Arguments :
      IN      :  p_assignment_action_id
      OUT     :  VARCHAR2 ('YES','NO')
    Notes     : PUBLIC
****************************************************************************/
PROCEDURE asg_action_affected(p_assignment_action_id   IN  NUMBER) AS

--  The following cursor selects the rows from pay_process_events where
--  Change_type in DATE_PROCESSED, DATE_EARNED, GRE, PAYMENT, COST_CENTRE
--  and status = 'U'
CURSOR c_pay_process_events(p_assignment_id IN NUMBER) IS
    SELECT    process_event_id ,
              event_update_id  ,
              change_type      ,
              assignment_id    ,
              surrogate_key    ,
              effective_date
    FROM      pay_process_events
    WHERE     assignment_id = p_assignment_id
    AND       change_type  IN ('DATE_PROCESSED',
                               'DATE_EARNED'   ,
                               'PAYMENT'       ,
                               'GRE'           ,
                               'COST_CENTRE'   )
    AND       status = 'U';

--  The following cursor selects the assignment Id for a given assignment_action_id.
CURSOR c_ass_act_id IS
    SELECT assignment_id
    FROM   pay_assignment_actions
    WHERE  assignment_action_id = p_assignment_action_id;

CURSOR c_mixed(p_event_update_id IN NUMBER) IS
    SELECT a.dated_table_id      table_id           ,
           a.column_name         column_name        ,
           a.change_type         change_type        ,
           a.event_type          event_type         ,
           b.table_name          table_name         ,
           b.surrogate_key_name  surrogate_key_name ,
           b.start_date_name     start_date_name    ,
           b.end_date_name       end_date_name
    FROM   pay_event_updates a ,
           pay_dated_tables  b
    WHERE  a.dated_table_id = b.dated_table_id;

    l_process_event_id   pay_process_events.process_event_id%TYPE ;
    l_change_type1       pay_process_events.change_type%TYPE      ;
    l_assignment_id      pay_process_events.assignment_id%TYPE    ;
    l_surrogate_key      pay_process_events.surrogate_key%TYPE    ;
    l_effective_date     pay_process_events.effective_date%TYPE   ;

    l_event_update_id    pay_event_updates.event_update_id%TYPE   ;
    l_table_id           pay_event_updates.dated_table_id%TYPE          ;
    l_column_name        pay_event_updates.column_name%TYPE       ;
    l_change_type2       pay_event_updates.change_type%TYPE       ;
    l_event_type         pay_event_updates.event_type%TYPE        ;
    l_table_name         pay_dated_tables.table_name%TYPE               ;
    l_surrogate_key_name pay_dated_tables.surrogate_key_name%TYPE       ;
    l_start_date_name    pay_dated_tables.start_date_name%TYPE          ;
    l_end_date_name      pay_dated_tables.end_date_name%TYPE            ;
BEGIN
    FOR caa IN c_ass_act_id
    LOOP
        l_assignment_id := caa.assignment_id;
    END LOOP;

    FOR cppe IN c_pay_process_events(l_assignment_id)
    LOOP
        l_process_event_id := cppe.process_event_id ;
        l_event_update_id  := cppe.event_update_id  ;
        l_change_type1     := cppe.change_type      ;
        l_assignment_id    := cppe.assignment_id    ;
        l_surrogate_key    := cppe.surrogate_key    ;
        l_effective_date   := cppe.effective_date   ;

        FOR cm IN c_mixed(l_event_update_id)
        LOOP
            l_table_id     := cm.table_id           ;
            l_column_name  := cm.column_name        ;
            l_change_type2 := cm.change_type        ;
            l_event_type   := cm.event_type         ;
            l_table_name   := cm.table_name         ;
        END LOOP;
    END LOOP;
END asg_action_affected;



/****************************************************************************
    Name      : asg_action_event
    Purpose   : The procedure is used in Continous Calc.
    Arguments :
      IN      :  p_assignment_action_id
              :  An array of process_event_id
      OUT     :  VARCHAR2 ('YES','NO')
    Notes     : PUBLIC
****************************************************************************/
PROCEDURE asg_action_event(p_assignment_action_id IN  NUMBER               ,
                           p_process_event_tab    IN  t_process_event_table,
                           p_affected             OUT NOCOPY VARCHAR2             ) AS

CURSOR c_event_updates(p_event_update_id IN NUMBER   ,
                       p_change_type     IN VARCHAR2 ) IS
    SELECT a.dated_table_id     table_id    ,
           a.column_name  column_name ,
           a.event_type   event_type
    FROM   pay_event_updates a
    WHERE  a.event_update_id  = p_event_update_id
    AND    a.change_type      = p_change_type    ;

CURSOR c_event_tables(p_table_id    IN NUMBER   ,
                      p_change_type IN VARCHAR2 ,
                      p_start_col   IN VARCHAR2 ,
                      p_end_col     IN VARCHAR2) IS
    SELECT a.column_name  column_name ,
           a.event_type   event_type
    FROM   pay_event_updates a,
           pay_dated_tables  b
    WHERE  a.dated_table_id    = b.dated_table_id
    AND    a.dated_table_id    = p_table_id
    AND    a.change_type = p_change_type
    AND    a.column_name NOT IN (p_start_col, p_end_col)
    AND    a.event_type  = 'U'
    AND    a.column_name IS NOT NULL ;

CURSOR c_process_events(p_process_event_id IN NUMBER) IS
    SELECT change_type     ,
           event_update_id ,
           effective_date
    FROM   pay_process_events
    WHERE  process_event_id = p_process_event_id ;

CURSOR c_pay_tables(p_table_id IN NUMBER) IS
    SELECT table_name         ,
           surrogate_key_name ,
           start_date_name    ,
           end_date_name
    FROM   pay_dated_tables
    WHERE  dated_table_id = p_table_id;

l_counter          NUMBER      ;
l_tab_count        NUMBER      ;
l_process_event_id NUMBER      ;
l_event_update_id  NUMBER      ;
l_table_id         NUMBER      ;
l_dynamic_counter  NUMBER      ;

l_change_type      VARCHAR2(40);
l_event_type       VARCHAR2(40);
l_return_flag      VARCHAR2(40);
l_table_name         VARCHAR2(40)      ;
l_surrogate_key_name VARCHAR2(40);
l_start_date_name    VARCHAR2(40)   ;
l_end_date_name      VARCHAR2(40) ;
l_column_name      VARCHAR2(40);
l_column_string    VARCHAR2(2000);

l_loop_flag        BOOLEAN;

l_effective_date   DATE        ;

t_dynamic_sql    t_dynamic_sql_tab;

BEGIN
    p_affected := 'NO';

    FOR l_counter IN 1..l_tab_count
    LOOP --{
        l_process_event_id := p_process_event_tab(l_counter).process_event_id;

        l_change_type        := NULL ;
        l_event_update_id    := NULL ;
        l_table_id           := NULL ;
        l_column_name        := NULL ;
        l_event_type         := NULL ;
        l_table_name         := NULL ;
        l_surrogate_key_name := NULL ;
        l_start_date_name    := NULL ;
        l_end_date_name      := NULL ;

        FOR cpes IN c_process_events(l_process_event_id)
        LOOP
            l_change_type     := cpes.change_type    ;
            l_event_update_id := cpes.event_update_id;
            l_effective_date  := cpes.effective_date ;
            FOR ceu IN c_event_updates(l_event_update_id,
                                       l_change_type    )
            LOOP
                l_table_id    := ceu.table_id   ;
                l_column_name := ceu.column_name;
                l_event_type  := ceu.event_type ;
                FOR cpt IN c_pay_tables(l_table_id)
                LOOP
                    l_table_name         := cpt.table_name         ;
                    l_surrogate_key_name := cpt.surrogate_key_name ;
                    l_start_date_name    := cpt.start_date_name    ;
                    l_end_date_name      := cpt.end_date_name      ;
                END LOOP;
            END LOOP;
        END LOOP;
        IF(l_column_name IS NOT NULL AND
            l_column_name NOT IN (l_start_date_name, l_end_date_name) AND
            l_event_type = 'U')  THEN
            p_affected := 'YES';
            EXIT;
        ELSIF(l_column_name IS NOT NULL
             AND l_column_name IN (l_start_date_name, l_end_date_name)
             AND l_event_type = 'U') THEN

                l_column_string := NULL;
                l_loop_flag     := FALSE;

                IF (t_dynamic_sql.EXISTS(1)) THEN
		    -- The code ensures that in the next cycle of loop for multiple tables, the
		    -- dynamic_sql table gets intialized
                    t_dynamic_sql.DELETE;
                END IF;

            l_dynamic_counter := 0;

            FOR cet IN c_event_tables(l_table_id        ,
                                      l_change_type     ,
                                      l_start_date_name ,
                                      l_end_date_name   )
            LOOP
                l_column_name     := cet.column_name ;
                l_event_type      := cet.event_type  ;
                l_dynamic_counter := l_dynamic_counter + 1;
                t_dynamic_sql(l_dynamic_counter).column_name := cet.column_name;
                IF (l_loop_flag = TRUE) THEN
                   l_column_string := l_column_string || ',' || cet.column_name;
                ELSE
                    l_column_string := cet.column_name;
                END IF;
                l_loop_flag     := TRUE;
            END LOOP;
            -- Build_SQL_dynamically;
            -- See the difference;
            -- IF (difference) THEN
            --     Execute III party proc.
            --         IF return TRUE then
            --            EXIT with yes;
            -- END If;  */
        END IF;
    END LOOP;

END asg_action_event;
--
procedure compare_event_values (p_old_value       in varchar2,
                          p_new_value       in varchar2,
                          p_from_value      in varchar2,
                          p_to_value        in varchar2,
                          p_valid_event     in varchar2,
                          p_prorate_type    in varchar2,
                          p_qualifier_valid in OUT NOCOPY boolean,
                          p_qual_pro_type   in OUT NOCOPY varchar2
                          )
is
begin
  if (g_traces) then
  hr_utility.trace(' +Compare value change details...');
  hr_utility.trace(' |Compare '||nvl(p_old_value, '<NULL>'));
  hr_utility.trace(' |   with '||nvl(p_from_value, '<NULL>'));
  hr_utility.trace(' |Compare '||nvl(p_new_value, '<NULL>'));
  hr_utility.trace(' |   with '||nvl(p_to_value, '<NULL>'));
  end if;

-- Bug 2681385
-- Dont do further comparisons if old and new are the same
 IF p_old_value = p_new_value Then
        if (g_traces) then
          hr_utility.trace(' + Does NOT pass comparison');
        end if;
        p_qualifier_valid := FALSE ;
 ELSE


  if (nvl(p_old_value, '<NULL>') = p_from_value or
      p_from_value = '<ANY_VALUE>') and
      (nvl(p_new_value, '<NULL>') = p_to_value or
         p_to_value = '<ANY_VALUE>') then
    if (p_to_value = '<ANY_VALUE>'
           and p_from_value = '<ANY_VALUE>'
           and nvl(p_old_value, '<NULL>') = nvl(p_new_value, '<NULL>')
           ) then
       if (g_traces) then
       hr_utility.trace('NULL path');
       end if;
       null;
    else
      if (p_valid_event = 'Y') then
         if (g_traces) then
          hr_utility.trace(' + PASS comparison, event is thus TRUE');
         end if;
         p_qualifier_valid := TRUE ;
         if p_qual_pro_type <> 'R' then
           p_qual_pro_type := p_prorate_type;
         end if ;
      else
         if (g_traces) then
          hr_utility.trace(' + PASS comparison, event is thus FALSE');
         end if;
         p_qualifier_valid := TRUE ; -- fixed in 3939168
      end if ;
    end if;
  else
    if (g_traces) then
     hr_utility.trace(' + FAILED comparison');
    end if;
  end if ;

  END IF;
end compare_event_values;
--
procedure run_qualification_code(p_qual_definition    in varchar2,
                                 p_comparison_column  in varchar2,
                                 p_qual_where_cl      in varchar2,
                                 p_qualifying_value   in varchar2,
                                 p_key                in varchar2,
                                 p_date               in date,
                                 p_qualified          OUT NOCOPY boolean,
                                 p_old_col_value      OUT NOCOPY varchar2,
                                 p_new_col_value      OUT NOCOPY varchar2)
--
is
  l_statem varchar2(4000);
  l_qual_value varchar2(300);
  l_column_value varchar2(2000);
--
begin
  p_qualified := FALSE;
  p_old_col_value := null;
  p_new_col_value := null;
--
  -- Build Qualifiction statement
  l_statem := 'select '|| p_qual_definition;
  if p_comparison_column is not null then
    l_statem := l_statem||', '||p_comparison_column;
  end if;
  l_statem := l_statem||' from '||p_qual_where_cl;
  g_effective_date := p_date;
  g_object_key := p_key;
--

  -- Run the select statement
  if p_comparison_column is not null then
    execute immediate l_statem into l_qual_value, l_column_value;
  else
    execute immediate l_statem into l_qual_value;
  end if;
--
  -- Perform the qualifications
if (g_dbg) then
  hr_utility.trace('++Testing value_change qualifier value.');
  hr_utility.trace(' +Qualifier cursor = evc qual value ? '||l_qual_value||' = '||p_qualifying_value);
end if;
  if l_qual_value = p_qualifying_value then
    p_qualified := TRUE;
    if p_comparison_column is not null then
      p_new_col_value := l_column_value;
      g_effective_date := p_date -1;
      execute immediate l_statem  into l_qual_value, l_column_value;
      p_old_col_value := l_column_value;
    end if;
  end if;
end;
--
procedure full_qualification_code(p_qual_definition    in varchar2,
                                 p_comparison_column  in varchar2,
                                 p_qual_where_cl      in varchar2,
                                 p_qualifying_value   in varchar2,
                                 p_key                in varchar2,
                                 p_date               in date,
                                 p_old_col_value      in varchar2,
                                 p_new_col_value      in varchar2,
                                 p_multi_chk_code     in varchar2,
                                 p_from_value      in varchar2,
                                 p_to_value        in varchar2,
                                 p_valid_event     in varchar2,
                                 p_prorate_type    in varchar2,
                                 p_qualifier_valid in OUT NOCOPY boolean,
                                 p_qual_pro_type   in OUT NOCOPY varchar2)
is
  l_statem varchar2(4000);
  TYPE MultCurTyp IS REF CURSOR;  -- define weak REF CURSOR type
  mult_crs   MultCurTyp;
  l_key varchar2(200);
  l_qualified boolean;
  l_old_value varchar2(2000);
  l_new_value varchar2(2000);
begin
--
  -- If we have multi checking code then we need
  -- to run the comparison for each of the sub keys.
  if(p_multi_chk_code is not null) then
    l_statem := p_multi_chk_code;
    g_effective_date := p_date;
    g_object_key := p_key;
    open mult_crs for l_statem;
    loop
      fetch mult_crs into l_key;
      exit when mult_crs%NOTFOUND;
      g_parent_key := p_key;
      run_qualification_code(p_qual_definition,
                            p_comparison_column,
                            p_qual_where_cl,
                            p_qualifying_value,
                            l_key,
                            p_date,
                            l_qualified,
                            l_old_value,
                            l_new_value);
     if l_qualified then
       compare_event_values(l_old_value,
                      l_new_value,
                      p_from_value,
                      p_to_value,
                      p_valid_event,
                      p_prorate_type,
                      p_qualifier_valid,
                      p_qual_pro_type);
      end if;
    end loop;
    close mult_crs;
  else
--
    -- Non multi checking comparison
    run_qualification_code(p_qual_definition,
                          p_comparison_column,
                          p_qual_where_cl,
                          p_qualifying_value,
                          p_key,
                          p_date,
                          l_qualified,
                          l_old_value, -- For non multi checking code, we always compare values passed in.
                          l_new_value) ;
    if l_qualified then
      compare_event_values(p_old_col_value,
                     p_new_col_value,
                     p_from_value,
                     p_to_value,
                     p_valid_event,
                     p_prorate_type,
                     p_qualifier_valid,
                     p_qual_pro_type);
    end if;
  end if;
end ;
--
procedure run_asg_ee_qualification(p_asg_id       in number,
                                   p_ee_id        in number,
                                   p_date         in date,
                                   p_key          in varchar2,
                                   p_asg_sql      in varchar2,
                                   p_ee_sql       in varchar2,
                                   p_asg_ee_valid in OUT NOCOPY boolean)
is
  l_asg_ee_valid varchar2(1);
  l_asg_ee_valid_con boolean;
begin
--
  -- Setup the variables used in the dynamic sql
  g_effective_date := p_date;
  g_object_key     := p_key;
  g_asg_id         := p_asg_id;
  g_ee_id          := p_ee_id;
--
  l_asg_ee_valid_con := p_asg_ee_valid;
  -- Either perform the entry validation or the
  -- assignment validation
  if (p_ee_id is null) then
    if (p_asg_sql is not null) then
--
      execute immediate p_asg_sql into l_asg_ee_valid;
--
    end if;
  else
    if (p_ee_sql is not null) then
--
      execute immediate p_ee_sql into l_asg_ee_valid;
--
    end if;
  end if;
--
  -- Set the output up
  if l_asg_ee_valid = 'Y' then
     l_asg_ee_valid_con := TRUE;
  else
     l_asg_ee_valid_con := FALSE;
  end if;

  p_asg_ee_valid   := l_asg_ee_valid_con;
  g_asg_id         := null;
  g_ee_id          := null;
--
end;
--
procedure load_event_qualifiers(p_datetracked_event_id in number,
                                p_global_env            IN OUT NOCOPY t_global_env_rec
                               )
is
--
cursor get_qual (p_datetracked_id in number,
                 p_valid_events in varchar2)
is
select peqv.from_value,
          peqv.to_value,
          peqv.valid_event,
          peqv.proration_style,
          peqv.qualifier_value,
          peq.qualifier_definition,
          peq.comparison_column,
          peq.qualifier_where_clause,
          peq.multi_event_sql
from pay_event_value_changes_f peqv,
        pay_event_qualifiers_f peq
where peqv.datetracked_event_id = p_datetracked_id
and peqv.valid_event = p_valid_events
and peq.event_qualifier_id = peqv.event_qualifier_id;
--
default_val_event varchar2(30);
default_pro_type varchar2(30);
default_asg_qual varchar2(2000);
default_ee_qual varchar2(2000);
needed_events varchar2(30);
qual_found boolean;
qual_idx   number;
--
begin
--
   if (glo_event_qualifiers.exists(p_datetracked_event_id) = FALSE) then
--
      begin
--
        default_val_event := null;
        default_pro_type := null;
        default_asg_qual := null;
        default_ee_qual := null;
--
        -- Get the default settings
        select peqv.valid_event,
               peqv.proration_style,
               peq.assignment_qualification,
               peq.entry_qualification
            into default_val_event,
                 default_pro_type,
                 default_asg_qual,
                 default_ee_qual
            from pay_event_value_changes_f peqv,
                 pay_event_qualifiers_f peq
           where peqv.datetracked_event_id = p_datetracked_event_id
             and peqv.default_event = 'Y'
             and peq.event_qualifier_id = peqv.event_qualifier_id;
--
      exception
         when no_data_found then
           default_val_event := 'Y';
           default_pro_type := 'E';
      end;
--
      glo_event_qualifiers(p_datetracked_event_id).valid_event:=
                      default_val_event;
      glo_event_qualifiers(p_datetracked_event_id).proration_style:=
                      default_pro_type;
      glo_event_qualifiers(p_datetracked_event_id).assignment_qualification:=
                      default_asg_qual;
      glo_event_qualifiers(p_datetracked_event_id).entry_qualification :=
                      default_ee_qual;
      glo_event_qualifiers(p_datetracked_event_id).start_qual_ptr := null;
      glo_event_qualifiers(p_datetracked_event_id).end_qual_ptr := null;
--
      -- Now we have the default go get the exceptions
--
      if (default_val_event = 'Y') then
        needed_events := 'N';
      else
        needed_events := 'Y';
      end if;
--
      qual_found := FALSE;
      for qualrec in get_qual(p_datetracked_event_id, needed_events) loop
--
         qual_idx := glo_child_event_qualifiers.count + 1;
         if (qual_found = FALSE) then
--
            qual_found := TRUE;
            glo_event_qualifiers(p_datetracked_event_id).start_qual_ptr:=
                    qual_idx;
--
         end if;
--
         glo_child_event_qualifiers(qual_idx).from_value :=
                   qualrec.from_value;
         glo_child_event_qualifiers(qual_idx).to_value :=
                   qualrec.to_value;
         glo_child_event_qualifiers(qual_idx).valid_event :=
                   qualrec.valid_event;
         glo_child_event_qualifiers(qual_idx).proration_style :=
                   qualrec.proration_style;
         glo_child_event_qualifiers(qual_idx).qualifier_value :=
                   qualrec.qualifier_value;
         glo_child_event_qualifiers(qual_idx).qualifier_definition :=
                   qualrec.qualifier_definition;
         glo_child_event_qualifiers(qual_idx).comparison_column :=
                   qualrec.comparison_column;
         glo_child_event_qualifiers(qual_idx).qualifier_where_clause :=
                   qualrec.qualifier_where_clause;
         glo_child_event_qualifiers(qual_idx).multi_event_sql :=
                   qualrec.multi_event_sql;
--
      end loop;
--
      if (qual_found = TRUE) then
        glo_event_qualifiers(p_datetracked_event_id).end_qual_ptr :=
                  qual_idx;
      end if;
--
   end if;
--
end load_event_qualifiers;
--
procedure generic_data_validation(p_dated_table_id in number,
                                  p_datetracked_event_id in number,
                                  p_old_value in varchar2,
                                  p_new_value in varchar2,
                                  p_date in date,
                                  p_key in varchar2,
                                  p_ee_id in number,
                                  p_asg_id in number,
                                  p_valid OUT NOCOPY varchar2,
                                  p_type OUT NOCOPY varchar2,
                                  p_global_env IN OUT NOCOPY t_global_env_rec)
is
--
l_overall_type varchar2(10);
found_rows boolean;
default_val_event varchar2(30);
default_pro_type varchar2(30);
default_asg_qual varchar2(2000);
default_ee_qual varchar2(2000);
l_asg_ee_valid boolean;
needed_events varchar2(30);
qualifier_passes boolean;
qual_proration_type varchar2(30);
--
begin
  l_overall_type := 'E';
  found_rows := FALSE;
  l_asg_ee_valid := TRUE;
--
  load_event_qualifiers(p_datetracked_event_id => p_datetracked_event_id,
                        p_global_env           => p_global_env
                       );
--
  default_pro_type :=
         glo_event_qualifiers(p_datetracked_event_id)
                 .proration_style;
  default_val_event :=
         glo_event_qualifiers(p_datetracked_event_id)
                 .valid_event;
  default_asg_qual :=
         glo_event_qualifiers(p_datetracked_event_id)
                 .assignment_qualification;
  default_ee_qual :=
         glo_event_qualifiers(p_datetracked_event_id)
                 .entry_qualification;
--
  if (   default_asg_qual is not null
      or default_ee_qual is not null) then
    run_asg_ee_qualification(p_asg_id,
                             p_ee_id,
                             p_date,
                             p_key,
                             default_asg_qual,
                             default_ee_qual,
                             l_asg_ee_valid);
  end if;
--
  if (g_dbg) then
  hr_utility.trace('Default valid entry '||default_val_event);
  hr_utility.trace('Default proration type '||default_pro_type);
  end if;
--
   -- Only process if the event is valid for the assignment
   if (l_asg_ee_valid) then
     -- What types of comparisons do we need that will over rule the default.
     if (default_val_event = 'Y') then
        needed_events := 'N';
     else
        needed_events := 'Y';
     end if;
--
    if (glo_event_qualifiers(p_datetracked_event_id).start_qual_ptr
           is not null)
    then
      for curr_idx in
        glo_event_qualifiers(p_datetracked_event_id).start_qual_ptr
      ..glo_event_qualifiers(p_datetracked_event_id).end_qual_ptr
      loop
       if(glo_child_event_qualifiers(curr_idx).qualifier_value
             is not null)
       then
          full_qualification_code(
           glo_child_event_qualifiers(curr_idx).qualifier_definition,
           glo_child_event_qualifiers(curr_idx).comparison_column,
           glo_child_event_qualifiers(curr_idx).qualifier_where_clause,
           glo_child_event_qualifiers(curr_idx).qualifier_value,
           p_key,
           p_date,
           p_old_value,
           p_new_value,
           glo_child_event_qualifiers(curr_idx).multi_event_sql,
           glo_child_event_qualifiers(curr_idx).from_value,
           glo_child_event_qualifiers(curr_idx).to_value,
           glo_child_event_qualifiers(curr_idx).valid_event,
           glo_child_event_qualifiers(curr_idx).proration_style,
           qualifier_passes,
           qual_proration_type);
       else
        compare_event_values (
           p_old_value,
           p_new_value,
           glo_child_event_qualifiers(curr_idx).from_value,
           glo_child_event_qualifiers(curr_idx).to_value,
           glo_child_event_qualifiers(curr_idx).valid_event,
           glo_child_event_qualifiers(curr_idx).proration_style,
           qualifier_passes,
           qual_proration_type
          );
       end if;
--

      -- record if we passed comparisons
      if (qualifier_passes = TRUE) then
         found_rows := TRUE;
         if (l_overall_type <> 'R') then
           l_overall_type := qual_proration_type;
         end if;
      end if;
--
      end loop;  -- Get next event value change qualifier row
    end if;
--
    -- Now set up the return variables.
    if (found_rows = TRUE) then
      if (default_val_event = 'Y') then
        p_valid := 'N';
        p_type := 'E';
      else
        p_valid := 'Y';
       p_type := l_overall_type;
      end if;
    else
      p_valid := default_val_event;
      p_type := default_pro_type;
    end if;
  else
    p_valid := 'N';
  end if;
--

 hr_utility.trace(' >= Generic data validation, Event qualification Result: '||p_valid);
end;
--
function get_object_key return varchar2
is
begin
   return g_object_key;
end get_object_key;
function get_effective_date return date
is
begin
   return g_effective_date;
end get_effective_date;
function get_parent_key return varchar2
is
begin
   return g_parent_key;
end get_parent_key;
function get_assignment_id return number
is
begin
   return g_asg_id;
end get_assignment_id;
function get_element_entry_id return number
is
begin
   return g_ee_id;
end get_element_entry_id;
--

/* ----------------------------------------------------------
   Get master mode that will tell us which version of main
   driving query to use.
   ---------------------------------------------------------- */
FUNCTION get_master_process_mode
(
         p_process_mode         IN     VARCHAR2
) return VARCHAR2 IS

  l_master_process_mode  VARCHAR2(30);

  l_proc varchar2(80) := g_pkg||'.get_master_process_mode';
BEGIN

-- >>> BUG 3329824- Performance issues, so massive restructure
-- >>> There are 5 processing modes of executing interpreter, process_modes...
-- >   ENTRY_CREATION_DATE, ASG_CREATION,ENTRY_RETROSTATUS,
-- >   ENTRY_EFECTIVE_DATE , PRORATION

-- Additional glossary...
-- p_process eg vals of ppe.retroactive_status -now obsoleted
--           i.e. U nprocessed, P rocessing, C ompleted
-- p_mode    eg 'DATE_EARNED', 'DATE_PROCESSED', stored against event-update

-- When we start looking for candidate rows in ppe, we restrict on 3 main
-- areas, process and mode, entry_creation_date and entry_effective_date
-- Whereas previously bind variables were set  to make these restrictions
-- this was not performant, and thus now we can split in to two subsets of
-- restriction and then use two different driving cursors.  As we dont then
-- bind in massive unused date ranges, the CBO can do its job much better.
-- So based on the logic below, we use the new p_master_process_mode to split
-- in to the two possible queries.

-- Binding restrictions  \ Process Modes
--   ENTRY_EFFECTIVE_DATE          ASG_CREATION  PRORATION
--           ENTRY_RETROSTATUS          ENTRY_CREATION_DATE
-- process         :    X    O     X    X        X
-- mode            :    X    O     X    O        X
-- eff date        :    O    X     X    X        O
-- creation date   :    X    X     O    O        X

if    ( p_process_mode = 'ENTRY_EFFECTIVE_DATE' or
        p_process_mode = 'PRORATION'    or
        p_process_mode = 'ENTRY_RETROSTATUS' ) then
  -- care about process, mode and effective date
  l_master_process_mode := 'EFF';

elsif (p_process_mode = 'ASG_CREATION' or
       p_process_mode = 'ENTRY_CREATION_DATE') then
  -- care about mode and creation date
  l_master_process_mode := 'CRE';
else
  -- SHOULDNT HAVE NON-EXPLICIT CASES but robust
  l_master_process_mode := 'CRE';
end if;

-- So in summary, our main driving cursors will be duplicated
-- => we dont pass in blank date ranges where possible
-- i) master mode EFF will be tuned to be performant for
-- EFFECTIVE DATE: eg use PPE_N5: assignment_id, effective_date
-- ii)master mode CRE, tuned to be performant for
-- CREATION DATE:  eg use PPE_N3: assignment_id, creation_date
  RETURN l_master_process_mode;
end get_master_process_mode;


/*Bug 7409433 -- Added parameter p_penserv_mode */
procedure save_disco_details
(
  p_effective_date     IN DATE,
  p_creation_date      IN DATE DEFAULT NULL,
  p_update_type        IN VARCHAR2,
  p_change_mode        IN VARCHAR2,
  p_process_mode       IN VARCHAR2,
  p_proration_type     IN VARCHAR2,
  p_datetracked_event  IN VARCHAR2,
  p_column_name        IN VARCHAR2 default 'none',
  p_old_val            IN VARCHAR2 default null,
  p_new_val            IN VARCHAR2 default null,
  p_change_values      IN VARCHAR2 default null,
  p_element_entry_id   IN NUMBER   default null,
  p_surrogate_key      IN VARCHAR2,
  p_dated_table_id     IN NUMBER,
  p_table_name         IN VARCHAR2,
  p_disco              IN NUMBER,
  p_start_date            IN DATE,
  p_end_date              IN DATE,
  p_assignment_action_id  IN NUMBER,
  p_business_group_id     IN NUMBER,
  p_assignment_id         IN NUMBER,
  p_penserv_mode          IN VARCHAR2 default 'N',
  p_date_counter          IN OUT NOCOPY number,
  p_global_env            IN OUT NOCOPY t_global_env_rec,
  t_proration_dates_temp  IN OUT NOCOPY  t_proration_dates_table_type,
  t_proration_change_type IN OUT NOCOPY t_proration_type_table_type,
  t_proration_type        IN OUT NOCOPY t_proration_type_table_type,
  t_detailed_output       IN OUT NOCOPY  t_detailed_output_table_type
)
is
save_event boolean;
curr_ptr   number;

    run_event_proc         boolean;
    event_proc_res         VARCHAR2(40);
    l_update_type          varchar2(10);
    l_element_entry_id     number;

cursor get_update_type IS
select update_type
from pay_Datetracked_events
where datetracked_event_id = p_datetracked_event;

begin
--
   run_event_proc := TRUE;
   event_proc_res := 'TRUE';
--
   -- We could be saving the results in one for 2 modes.
   -- First mode is that the events are being generated for a
   -- single element entry.
   -- Second mode is that a list of element entries have been
   -- suppled cross referencing the datetracked events for which
   -- we are looking.
--
   if (p_global_env.datetrack_ee_tab_use = FALSE) then
/*
     if (p_disco = G_DISCO_STANDARD) then
--
          add_found_event (
               p_effective_date        =>  p_effective_date,
               p_creation_date         =>  p_creation_date,
               p_update_type           =>  p_update_type,
               p_change_mode           =>  p_change_mode,
               p_proration_type        =>  p_proration_type,
               p_datetracked_event     =>  p_datetracked_event,
               p_column_name           =>  p_column_name,
               p_change_values         =>  p_change_values,
               p_element_entry_id      =>  p_element_entry_id,
               p_surrogate_key         =>  p_surrogate_key,
               p_dated_table_id        =>  p_dated_table_id,
               p_date_counter          =>  p_date_counter,
               p_global_env            =>  p_global_env,
               t_proration_dates_temp  =>  t_proration_dates_temp,
               t_proration_change_type =>  t_proration_change_type,
               t_proration_type        =>  t_proration_type,
               t_detailed_output       =>  t_detailed_output
             );
--
     elsif (p_disco = G_DISCO_DF) then
          add_found_event (
            p_effective_date        => p_effective_date,
            p_creation_date         =>  p_creation_date,
            p_update_type           => p_update_type,
            p_change_mode           => p_change_mode,
            p_proration_type        => p_proration_type,
            p_datetracked_event     => p_datetracked_event,
            p_element_entry_id      =>  p_element_entry_id,
            p_surrogate_key         => p_surrogate_key,
            p_dated_table_id        => p_dated_table_id,
            p_date_counter          => p_date_counter,
            p_global_env            =>  p_global_env,
            t_proration_dates_temp  =>  t_proration_dates_temp,
            t_proration_change_type =>  t_proration_change_type,
            t_proration_type        =>  t_proration_type,
            t_detailed_output       =>  t_detailed_output
          );
--
     else
        pay_core_utils.assert_condition(
                 'pay_interpreter_pkg.save_disco_details:1',
                 1 = 2);
     end if;
*/

     /* If its element entries don't run the procedure
        validation, assume it's qualified
     */
     if (  p_table_name = 'PAY_ELEMENT_ENTRIES_F'
         or p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F') then
       run_event_proc := FALSE;
       event_proc_res := 'TRUE';

     end if;
--
     perform_qualifications
     (
      p_table_id              => p_dated_table_id,
      p_final_effective_date  => p_effective_date,
      p_creation_date         => p_creation_date,
      p_start_date            => p_start_date,
      p_end_date              => p_end_date,
      p_element_entry_id      => p_element_entry_id,
      p_assignment_action_id  => p_assignment_action_id,
      p_business_group_id     => p_business_group_id,
      p_assignment_id         => p_assignment_id,
      p_process_mode          => p_process_mode,
      p_update_type           => p_update_type,
      p_change_mode           => p_change_mode,
      p_change_values         => p_change_values,
      p_surrogate_key         => p_surrogate_key,
      p_date_counter          => p_date_counter,
      p_global_env            => p_global_env,
      p_datetracked_id        => p_datetracked_event,
      p_column_name           => p_column_name,
      p_old_value             => p_old_val,
      p_new_value             => p_new_val,
      p_proration_style       => p_proration_type,
      t_proration_dates_temp  => t_proration_dates_temp,
      t_proration_change_type => t_proration_change_type,
      t_proration_type        => t_proration_type,
      t_detailed_output       => t_detailed_output,
      p_run_event_proc        => run_event_proc,
      p_event_proc_res        => event_proc_res
     );
   else
--
     if (g_dbg) then
       hr_utility.trace('Candidate has passed tests, final test as in ee list mode');
     end if;
     if (glo_datetrack_ee_hash_tab.exists(p_datetracked_event)) then
--
        curr_ptr := glo_datetrack_ee_hash_tab(p_datetracked_event);

	 open  get_update_type;                                  -- 7190857
         fetch get_update_type into l_update_type;
	 close get_update_type;

        while (curr_ptr is not null) loop
--
        l_element_entry_id := glo_datetrack_ee_tab(curr_ptr).element_entry_id;

          -- Need to decide if the event is relevent to the current entry
--
          save_event := FALSE;
          if (p_table_name = 'PAY_ELEMENT_ENTRIES_F') then
--
            if(l_element_entry_id = p_surrogate_key) then
               save_event := TRUE;
            end if;
--
          elsif (p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F') then
--
            declare
            l_dummy varchar2(2);
            l_ee_id pay_element_entries_f.element_entry_id%type;
            begin
               l_ee_id :=
                  l_element_entry_id;
               select ''
                 into l_dummy
                 from dual
                where exists (select ''
                                from pay_element_entry_values_f
                               where element_entry_id = l_ee_id
                                 and element_entry_value_id = p_surrogate_key
                             );
               save_event := TRUE;
            exception
               when no_data_found then
                  save_event := FALSE;
            end;
--
          else
             save_event := TRUE;
          end if;

	   -- 7190857. Move the increment of the pointer above. If no match is found between p_surrogate_key and element entry ids
	   -- after all the iterations, switch save_event to TRUE for PURGE update_type.

          curr_ptr := glo_datetrack_ee_tab(curr_ptr).next_ptr;

	  if( curr_ptr IS NULL   AND
	      nvl(save_event,FALSE) = FALSE and                 -- bug 8298970. save_event is null as it is not initialized
	      p_table_name = 'PAY_ELEMENT_ENTRIES_F' and
	      l_update_type = 'P' and
	      p_penserv_mode = 'N' ) THEN  /*Bug 7409433 Added condition p_penserv_mode ='N' */

	        save_event := TRUE;

	  END if;

--
          if (save_event = TRUE) then
/*
             if (p_disco = G_DISCO_STANDARD) then
--
               add_found_event (
                  p_effective_date        =>  p_effective_date,
                  p_creation_date         =>  p_creation_date,
                  p_update_type           =>  p_update_type,
                  p_change_mode           =>  p_change_mode,
                  p_proration_type        =>  p_proration_type,
                  p_datetracked_event     =>  p_datetracked_event,
                  p_column_name           =>  p_column_name,
                  p_change_values         =>  p_change_values,
                  p_element_entry_id      =>
                    l_element_entry_id,
                  p_surrogate_key         =>  p_surrogate_key,
                  p_dated_table_id        =>  p_dated_table_id,
                  p_date_counter          =>  p_date_counter,
                  p_global_env            =>  p_global_env,
                  t_proration_dates_temp  =>  t_proration_dates_temp,
                  t_proration_change_type =>  t_proration_change_type,
                  t_proration_type        =>  t_proration_type,
                  t_detailed_output       =>  t_detailed_output
                );
--
             elsif (p_disco = G_DISCO_DF) then
               add_found_event (
                 p_effective_date        => p_effective_date,
                 p_creation_date         =>  p_creation_date,
                 p_update_type           => p_update_type,
                 p_change_mode           => p_change_mode,
                 p_proration_type        => p_proration_type,
                 p_datetracked_event     => p_datetracked_event,
                 p_element_entry_id      =>
                   l_element_entry_id,
                 p_surrogate_key         => p_surrogate_key,
                 p_dated_table_id        => p_dated_table_id,
                 p_date_counter          => p_date_counter,
                 p_global_env            =>  p_global_env,
                 t_proration_dates_temp  =>  t_proration_dates_temp,
                 t_proration_change_type =>  t_proration_change_type,
                 t_proration_type        =>  t_proration_type,
                 t_detailed_output       =>  t_detailed_output
               );
--
             else
               pay_core_utils.assert_condition(
                      'pay_interpreter_pkg.save_disco_details:1',
                      1 = 2);
             end if;
*/

            /* If its element entries don't run the procedure
               validation, assume it's qualified
            */
            if (  p_table_name = 'PAY_ELEMENT_ENTRIES_F'
                or p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F') then
              run_event_proc := FALSE;
              event_proc_res := 'TRUE';
            end if;
            perform_qualifications
            (
             p_table_id              => p_dated_table_id,
             p_final_effective_date  => p_effective_date,
             p_creation_date         => p_creation_date,
             p_start_date            => p_start_date,
             p_end_date              => p_end_date,
             p_element_entry_id      =>
                 l_element_entry_id,
             p_assignment_action_id  => p_assignment_action_id,
             p_business_group_id     => p_business_group_id,
             p_assignment_id         => p_assignment_id,
             p_process_mode          => p_process_mode,
             p_update_type           => p_update_type,
             p_change_mode           => p_change_mode,
             p_change_values         => p_change_values,
             p_surrogate_key         => p_surrogate_key,
             p_date_counter          => p_date_counter,
             p_global_env            => p_global_env,
             p_datetracked_id        => p_datetracked_event,
             p_column_name           => p_column_name,
             p_old_value             => p_old_val,
             p_new_value             => p_new_val,
             p_proration_style       => p_proration_type,
             t_proration_dates_temp  => t_proration_dates_temp,
             t_proration_change_type => t_proration_change_type,
             t_proration_type        => t_proration_type,
             t_detailed_output       => t_detailed_output,
             p_run_event_proc        => run_event_proc,
             p_event_proc_res        => event_proc_res
            );
          end if;
--
        end loop;
--
     end if;
--
   end if;
--
end save_disco_details;
--


/* ----------------------------------------------------------
Procedure: extra_tests_dbt_df
High Level Summary:
  We can do a single query to identify all the df events for a given
  table.
  So do this for this process_event, then mark in cache so no other events
  on the same table are performed as weve already recorded them.

--
Detail Logic:
/* ----------------------------------------------------------

   ---------------------------------------------------------- */

PROCEDURE extra_tests_dbt_df
(
     p_element_entry_id     IN  pay_element_entries.element_entry_id%type,
     p_assignment_action_id IN  pay_assignment_actions.assignment_action_id%type,
     p_business_group_id    IN  per_business_groups.business_group_id%type,
     p_assignment_id        IN  per_all_assignments_f.assignment_id%type,
     p_mode                 IN  VARCHAR2,
     p_process              IN  VARCHAR2,
     p_process_mode         IN  VARCHAR2,
     p_event_group_id       IN  pay_event_groups.event_group_id%type,
     p_start_date           IN  date,
     p_end_date             IN  date,
     p_penserv_mode         IN VARCHAR2 default 'N', /*Bug 7409433 */
     p_date_counter         IN OUT NOCOPY number,
     p_global_env           IN OUT NOCOPY t_global_env_rec,
     t_dynamic_sql          IN OUT NOCOPY t_dynamic_sql_tab,

     t_proration_dates_temp  IN OUT NOCOPY  t_proration_dates_table_type,
     t_proration_change_type IN OUT NOCOPY  t_proration_type_table_type,
     t_proration_type        IN OUT NOCOPY  t_proration_type_table_type,
     t_detailed_output       IN OUT NOCOPY  t_detailed_output_table_type,

     p_pro_evt_rec          IN  t_mst_process_event_rec , --record from master query
     p_dtevent_rec          IN  t_distinct_table_rec ,
     p_disco                IN OUT NOCOPY number
)  IS

  l_proc    VARCHAR2(80) := g_pkg||'.extra_tests_dbt_df';
  l_effective_date date;
  l_count number;

BEGIN
--
  -- If the process event is a delete and is the earliest
  -- delete for the object. Also if there is an insert
  -- then it must be a Delete Next or Delete Future.
--
  if (p_pro_evt_rec.event_type = 'D') then
--
    -- Get the min date of the Delete rows for this
    -- Date Track transaction
    select min(effective_date)
      into l_effective_date
      from pay_process_events
     where surrogate_key = p_pro_evt_rec.surrogate_key
       and event_update_id = p_pro_evt_rec.event_update_id
       and creation_date = p_pro_evt_rec.creation_date;
--
    -- If the min date matches the current process event then we may
    -- have a Delete Next.
    if (l_effective_date = p_pro_evt_rec.effective_date) then
--
      select count(*)
        into l_count
        from pay_dated_tables pdt,
             pay_event_updates peu,
             pay_process_events ppe
       where pdt.table_name = p_pro_evt_rec.table_name
         and pdt.dated_table_id = peu.dated_table_id
         and peu.event_type = 'I'
         and peu.change_type = p_pro_evt_rec.change_mode
         and peu.event_update_id = ppe.event_update_id
         and ppe.surrogate_key = p_pro_evt_rec.surrogate_key
         and ppe.creation_date = p_pro_evt_rec.creation_date;
--
      -- If the count is not 0 then there was an insert at the
      -- same time as a delete, hence we must assume that this
      -- is a Delete Next
--
      if (l_count <> 0) then
--
        save_disco_details (
           p_effective_date        =>  p_pro_evt_rec.effective_date,
           p_creation_date         =>  p_pro_evt_rec.creation_date,
           p_update_type           =>  'DF',
           p_change_mode           =>  p_pro_evt_rec.change_mode,
           p_process_mode          =>  p_process_mode,
           p_proration_type        =>  p_dtevent_rec.proration_type,
           p_datetracked_event     =>  p_dtevent_rec.datetracked_event_id,
           p_element_entry_id      =>  p_element_entry_id,
           p_surrogate_key         =>  p_pro_evt_rec.surrogate_key,
           p_dated_table_id        =>  p_dtevent_rec.table_id,
           p_table_name            =>  p_dtevent_rec.table_name,
           p_disco                 =>  p_disco,
           p_start_date            =>  p_start_date,
           p_end_date              =>  p_end_date,
           p_assignment_action_id  =>  p_assignment_action_id,
           p_business_group_id     =>  p_business_group_id,
           p_assignment_id         =>  p_assignment_id,
           p_penserv_mode          =>  p_penserv_mode,  /*Bug 7409433 */
           p_date_counter          =>  p_date_counter,
           p_global_env            =>  p_global_env,
           t_proration_dates_temp  =>  t_proration_dates_temp,
           t_proration_change_type =>  t_proration_change_type,
           t_proration_type        =>  t_proration_type,
           t_detailed_output       =>  t_detailed_output
         );
--
      end if;
--
    end if;
--
  -- If we ahave an Update to the effective end date, such that the
  -- calculation date is earlier than the effective date then
  -- it must be a Delete next change.
--
  elsif (p_pro_evt_rec.event_type = 'U') then
--
     if (p_pro_evt_rec.updated_column_name = p_dtevent_rec.end_date_name
         and p_pro_evt_rec.effective_date > p_pro_evt_rec.calculation_date)
       then
--
        save_disco_details (
           p_effective_date        =>  p_pro_evt_rec.calculation_date,
           p_creation_date         =>  p_pro_evt_rec.creation_date,
           p_update_type           =>  'DF',
           p_change_mode           =>  p_pro_evt_rec.change_mode,
           p_process_mode          =>  p_process_mode,
           p_proration_type        =>  p_dtevent_rec.proration_type,
           p_datetracked_event     =>  p_dtevent_rec.datetracked_event_id,
           p_element_entry_id      =>  p_element_entry_id,
           p_surrogate_key         =>  p_pro_evt_rec.surrogate_key,
           p_dated_table_id        =>  p_dtevent_rec.table_id,
           p_table_name            =>  p_dtevent_rec.table_name,
           p_disco                 =>  p_disco,
           p_start_date            =>  p_start_date,
           p_end_date              =>  p_end_date,
           p_assignment_action_id  =>  p_assignment_action_id,
           p_business_group_id     =>  p_business_group_id,
           p_assignment_id         =>  p_assignment_id,
           p_penserv_mode          =>  p_penserv_mode, /*Bug 7409433 */
           p_date_counter          =>  p_date_counter,
           p_global_env            =>  p_global_env,
           t_proration_dates_temp  =>  t_proration_dates_temp,
           t_proration_change_type =>  t_proration_change_type,
           t_proration_type        =>  t_proration_type,
           t_detailed_output       =>  t_detailed_output
         );
--
     end if;
--
  end if;
--
   if (g_dbg) then
   hr_utility.set_location(l_proc, 900);
   end if;

END extra_tests_dbt_df;


/* ----------------------------------------------------------
Procedure: extra_tests_dbt_u_e
High Level Summary:
  A complex one.  Need to differentiate between all of the following
--
Detail Logic:
/* ----------------------------------------------------------
   Look through PPE for an update or end-date
   --
      -- all dbt_df now in extra_tests_dbt_df

   Driving Query gets candidate rows...
   ...that may be indicative of one of the six situations.
     API-U,API-E,API-DF and , DT-U,DT-E
   The first two are indicated by an update to the end-date column with
   eff_date = calc_date.
   The third is indicated by an update to the end-date column with
   eff_date > calc_date
   The fourth is definitively indicated by any alteration to the
   start-date column.
   The last two situations are recorded elsewhere

   Further Tests involve...
   ...differentiating between API-U and API-E by checking the base table
   for future dated records. If no future rows exist then must be an E.
   (NB. At this point we note that if an E occurs; and then it is undone
   and a future row inserted; this test will fail and an API-U will be
   recorded instead of the actual original API-E.  It has been decided
   this is an acceptable behaviour.)

   API-DF and DT-U require no more tests.
   DT-E and DT-DF cannot be distinguished from each other.  Proposed
   behaviour is to flag this occurrence as a DT-DF.

   Further advanced checking occurs against each update candidate to make
   sure we are interested in this type and values of the updates.

   ---------------------------------------------------------- */

PROCEDURE extra_tests_dbt_u_e
(
     p_element_entry_id     IN  pay_element_entries.element_entry_id%type,
     p_assignment_action_id IN  pay_assignment_actions.assignment_action_id%type,
     p_business_group_id    IN  per_business_groups.business_group_id%type,
     p_assignment_id        IN  per_all_assignments_f.assignment_id%type,
     p_process_mode         IN  VARCHAR2,
     p_event_group_id       IN  pay_event_groups.event_group_id%type,
     p_start_date           IN  date,
     p_end_date             IN  date,
     p_penserv_mode         IN VARCHAR2 DEFAULT 'N',
     p_date_counter         IN OUT NOCOPY number,
     p_global_env           IN OUT NOCOPY t_global_env_rec,
     t_dynamic_sql          IN OUT NOCOPY t_dynamic_sql_tab,

     t_proration_dates_temp  IN OUT NOCOPY  t_proration_dates_table_type,
     t_proration_change_type IN OUT NOCOPY  t_proration_type_table_type,
     t_proration_type        IN OUT NOCOPY  t_proration_type_table_type,
     t_detailed_output       IN OUT NOCOPY  t_detailed_output_table_type,

     p_pro_evt_rec          IN  t_mst_process_event_rec , --record from master query
     p_dtevent_rec          IN  t_distinct_table_rec ,
     p_disco                IN OUT NOCOPY NUMBER
)  IS

  l_search  varchar2(30) := p_dtevent_rec.update_type;
  l_statement varchar2(800);
  l_dummy number := null;
  l_date_dummy date := hr_api.g_eot;

  l_proc    VARCHAR2(80) := g_pkg||'.extra_tests_dbt_u_e';

BEGIN

   if (g_dbg) then
   hr_utility.set_location(l_proc, 10);
   end if;

   /* Only interested in the event if it is a change to the
      effective date columns
   */
   if (p_pro_evt_rec.updated_column_name = p_dtevent_rec.start_date_name
       or p_pro_evt_rec.updated_column_name = p_dtevent_rec.end_date_name
      ) then
--
     -- Look for an Update (via Forms => DT-U
     --
      IF (p_pro_evt_rec.updated_column_name = p_dtevent_rec.start_date_name
          and l_search = 'U') THEN
        --defo got DT-U
        --Allow existing involved code to further test and add to our list
        if (g_dbg) then
           hr_utility.set_location(l_proc, 25);
        end if;
            event_group_table_updated(p_element_entry_id,
                                      p_assignment_action_id,
                                      p_business_group_id,
                                      p_assignment_id,
                                      p_process_mode,
                                      p_pro_evt_rec.change_mode,
                                      p_event_group_id,
                                      p_dtevent_rec.table_id,
                                      p_dtevent_rec.table_name,
                                      p_dtevent_rec.surrogate_key_name,
                                      p_pro_evt_rec.surrogate_key,
                                      p_dtevent_rec.start_date_name,
                                      p_dtevent_rec.end_date_name,
                                      p_pro_evt_rec.effective_date,
                                      p_pro_evt_rec.creation_date,
                                      p_start_date,
                                      p_end_date,
                                      p_pro_evt_rec.updated_column_name,
                                      p_date_counter,
                                      p_global_env,
                                      p_dtevent_rec.proration_type,
                                      t_dynamic_sql,
                                      t_proration_dates_temp,
                                      t_proration_change_type,
                                      t_proration_type,
                                      t_detailed_output );

      -- all dbt_df now in extra_tests_dbt_df
      -- ELSIF (p_pro_evt_rec.updated_column_name = p_dtevent_rec.end_date_name
      --        and p_pro_evt_rec.effective_date > p_pro_evt_rec.calculation_date
      --        and l_search = 'DF') THEN
      --   --Add found API-DF to store
      --     if (g_dbg) then
      --        hr_utility.set_location(l_proc, 35);
      --     end if;
      --     p_disco := G_DISCO_DF;
--
      ELSE
    -- >>> PHASE 4: Differentiate between remaining API-U,API-E,DT-E,DT-DF
    --
--
        if (g_dbg) then
           hr_utility.set_location(l_proc, 45);
        end if;


      l_statement :=
         'select max('||p_dtevent_rec.end_date_name||')'||
         ' from  '|| p_dtevent_rec.table_name||
         ' where '|| p_dtevent_rec.surrogate_key_name ||' = :1 '||
         ' and   '|| p_dtevent_rec.end_date_name || '>= :2'||
         ' group by '|| p_dtevent_rec.surrogate_key_name;

        if (g_dbg) then
            hr_utility.trace('- Dynamic SQL: '||l_statement);
        end if;
        begin
          execute immediate l_statement
           into l_date_dummy
           using p_pro_evt_rec.surrogate_key,  --:1
                 p_pro_evt_rec.effective_date; --:2

        exception
        when no_data_found then
          --
          l_dummy := 0;  -- No data, weve had a purge
                         -- process as UPDATE
        end;


	/* Added for bug 6595505
           For Datetracked tables, after datetrack update, l_date_dummy is greater
	   than the effective date. But for PER_ADDRESSES, l_date_dummy will be equal
	   to effective date even for an UPDATE as it is not datetracked and the new
	   record will have a different primary key.
	*/

	if ( p_dtevent_rec.table_name = 'PER_ADDRESSES' and
	     l_date_dummy = p_pro_evt_rec.effective_date AND
	     p_penserv_mode <> 'A' ) then                         -- bug 7211447
	  --
	  l_dummy := 2;
	  --
        elsif (l_date_dummy = p_pro_evt_rec.effective_date) THEN  -- If latest is our date then no future rows,
	  --                                                        End date has occurred
          l_dummy := 1;  --Eff date is max, process as END DATE
	  --
        elsif (l_date_dummy > p_pro_evt_rec.effective_date ) then
          --
          l_dummy := 2;  -- Eff date is less max,later rows exist
                         -- process as UPDATE
        end if;


/*
        --Check the base table to see if any future dated records exist,
        l_statement :=
          'SELECT count(*) FROM '||p_dtevent_rec.table_name||
          ' WHERE '||p_dtevent_rec.surrogate_key_name ||' = :1 '||
          ' AND  '|| p_dtevent_rec.end_date_name || ' >= :2 ';
--
        if (g_dbg) then
            hr_utility.trace('-Dynamic SQL: '||l_statement);
        end if;
--
        execute immediate l_statement
         into l_dummy
         using p_pro_evt_rec.surrogate_key,  --:1
               p_pro_evt_rec.effective_date; --:2

        --The subset of rows for DT-E, may actually be one of four
        -- DT-I + DT-P, API-I + API-P, DT-DF or DT-E
        -- If a purge has occurred then cursor will find no rows, I.e.

*/
        -- From our dummy system
        --l_dummy = 0 => purge occurred
        --l_dummy = 1 => end_date occurred
        --l_dummy = 2 => possible update occurred

        IF (p_pro_evt_rec.updated_column_name = p_dtevent_rec.end_date_name
            and l_dummy > 1
            and l_search = 'U') THEN
--
          if (g_dbg) then
              hr_utility.set_location(l_proc, 55);
          end if;
--
          --Allow existing involved code to further test and add API-U
            event_group_table_updated(p_element_entry_id,
                                      p_assignment_action_id,
                                      p_business_group_id,
                                      p_assignment_id,
                                      p_process_mode,
                                      p_pro_evt_rec.change_mode,
                                      p_event_group_id,
                                      p_dtevent_rec.table_id,
                                      p_dtevent_rec.table_name,
                                      p_dtevent_rec.surrogate_key_name,
                                      p_pro_evt_rec.surrogate_key,
                                      p_dtevent_rec.start_date_name,
                                      p_dtevent_rec.end_date_name,
                                      p_pro_evt_rec.effective_date,
                                      p_pro_evt_rec.creation_date,
                                      p_start_date,
                                      p_end_date,
                                      p_pro_evt_rec.updated_column_name,
                                      p_date_counter,
                                      p_global_env,
                                      p_dtevent_rec.proration_type,
                                      t_dynamic_sql,
                                      t_proration_dates_temp,
                                      t_proration_change_type,
                                      t_proration_type,
                                      t_detailed_output );

        ELSIF (p_pro_evt_rec.updated_column_name = p_dtevent_rec.end_date_name
               and l_dummy = 1
               and l_search = 'E') THEN
--
          if (g_dbg) then
             hr_utility.set_location(l_proc, 65);
          end if;
--
          --Add found API-E to store
            p_disco := G_DISCO_STANDARD;

        -- all dbt_df now in extra_tests_dbt_df
        -- ELSIF (p_pro_evt_rec.updated_column_name is null
        --
        --       and l_dummy = 1
        --       and l_search = 'DF') THEN
        --  if (g_dbg) then
        --    hr_utility.set_location(l_proc, 75);
        --  end if;
        -- We have got either a DT-E or DT-F
        -- NB.  As it is impossible to identify exactly which one
        -- it is proposed that it is simply classified as DT-DF
        -- Add found DF event to our store
        --    p_disco := G_DISCO_STANDARD;


        END IF;

      END IF; --end of main IF
   end if; -- IS it effective_start_date or effective_end_date.

   if (g_dbg) then
     hr_utility.set_location(l_proc, 900);
   end if;
END extra_tests_dbt_u_e;


/* ----------------------------------------------------------
Procedure: extra_tests_dyt_pkg_e
High Level Summary:
  Look at candidate process event to see if it is an end date
--
Detail Logic:
1) Check it is flagged as a Datetrack delete = End dated
2) Check this end date still applies

   ---------------------------------------------------------- */
PROCEDURE extra_tests_dyt_pkg_e
(
     p_pro_evt_rec          IN  t_mst_process_event_rec , --record from master query
     p_dtevent_rec          IN  t_distinct_table_rec ,
     p_disco                IN OUT NOCOPY number
)  IS
  l_statement varchar2(800);
  l_dummy number := null;

  l_proc    VARCHAR2(80) := g_pkg||'.extra_tests_dyt_pkg_e';

BEGIN
  if (g_dbg) then
  hr_utility.set_location(l_proc, 10);
  end if;
  if (p_pro_evt_rec.event_type = hr_api.g_delete) then

-- >>> PHASE 2: Check e is still relevant
--
   hr_utility.set_location(l_proc, 20);
-- If end date is still relevant, then base key has no rows
-- with end dates later than this end date.

      --Check the base table to see if any future dated records exist,
      l_statement :=
        'SELECT count(*) FROM '||p_dtevent_rec.table_name||
        ' WHERE '||p_dtevent_rec.surrogate_key_name ||' = :1 '||
        ' AND  '|| p_dtevent_rec.end_date_name ||' >= :2';
   if (g_dbg) then
   hr_utility.trace(l_statement);
   end if;
      execute immediate l_statement
        into l_dummy
        using  p_pro_evt_rec.surrogate_key,   --:1
               p_pro_evt_rec.effective_date ; --:2

      IF ( l_dummy = 1)  then
        --Add found event to our store
        p_disco := G_DISCO_STANDARD;
      end if;

  end if; --If not delete type then dont do anything

  if (g_dbg) then
  hr_utility.set_location(l_proc, 900);
  end if;
END extra_tests_dyt_pkg_e;

/* ----------------------------------------------------------
Procedure: get_dbt_i_p_cache
High Level Summary:
  Build up a global cache of ppe data for quick reference
  Essentially getting min and max dates
  Used by extra_tests_dbt_p and extra_tests_i
--
Detail Logic:
1) Check the event update is the right type, a deletion
2) Check this is the latest created ppe event for this
  event_update/surrogate_key combination
3) Check this deletion is part of a purge, no rows in base table
  also check we havent got this event yet under the guise of another
  ppe row, 'cos creation date may be identical for several

   ---------------------------------------------------------- */
PROCEDURE get_dbt_i_p_cache
(
     p_surrogate_key        IN  pay_process_events.surrogate_key%type ,
     p_event_update_id      IN  pay_process_events.event_update_id%type ,
     p_assignment_id        IN  per_all_assignments.assignment_id%type,
     p_change_mode          IN  pay_event_updates.change_type%type,
     p_cache_number         IN OUT NOCOPY NUMBER
)  IS

  CURSOR csr_get_cache_asgid (
                      cp_base_record_id  in number,
                      cp_event_update_id in number,
                      cp_mode            in varchar2,
                      cp_assignment_id   in number) is
    SELECT min(creation_date),
           max(creation_date)
    FROM PAY_PROCESS_EVENTS
    WHERE event_update_id  = cp_event_update_id
    AND    surrogate_key   = cp_base_record_id
    AND    assignment_id is not null
    AND    assignment_id   = cp_assignment_id
    AND    change_type = nvl(cp_mode,change_type);

 CURSOR csr_get_cache_noasg (
                      cp_base_record_id  in number,
                      cp_event_update_id in number,
                      cp_mode            in varchar2) is
    SELECT min(creation_date),
           max(creation_date)
    FROM   PAY_PROCESS_EVENTS
    WHERE  event_update_id  = cp_event_update_id
    AND    surrogate_key   = cp_base_record_id
    AND    assignment_id is null
    AND    change_type = nvl(cp_mode,change_type);

  l_proc   VARCHAR2(80) := g_pkg||'.get_dbt_i_p_cache';

  l_statement varchar2(800);
  l_dummy number := null;

  l_key varchar2(240);
  l_min_date  date;
  l_max_date  date;
  l_got_flag      varchar2(15);

  l_pos number := 0;

BEGIN
   if (g_dbg) then
   hr_utility.set_location(l_proc, 10);
   end if;

  l_key := p_event_update_id||'_'
               ||p_surrogate_key||'_'
               ||p_change_mode ;

  for j in 1..g_key_date_cache.count() loop
    if (g_key_date_cache(j).key = l_key) then
      l_pos := j;
      if (g_traces) then
       hr_utility.trace('Found key in cache, pos '||l_pos);
      end if;
       l_min_date := g_key_date_cache(j).min_date;
       l_max_date := g_key_date_cache(j).max_date;
       l_got_flag := g_key_date_cache(j).got_flag;
       exit;
    end if;
  end loop;

  --if no date obtained then get it now
  if (l_max_date is null) then
    if (g_traces) then
     hr_utility.trace('Not in cache, get dates now, key '||l_key);
    end if;
    if p_assignment_id is not null then
       open csr_get_cache_asgid(
                                    p_surrogate_key,
                                    p_event_update_id,
                                    p_change_mode,
                                    p_assignment_id);
       fetch csr_get_cache_asgid into l_min_date,l_max_date;
       close csr_get_cache_asgid;
    else
       open csr_get_cache_noasg(
                                    p_surrogate_key,
                                    p_event_update_id,
                                    p_change_mode);
       fetch csr_get_cache_noasg into l_min_date,l_max_date;
       close csr_get_cache_noasg;
    end if;
    l_got_flag := 'N';
    --store result in cache
    l_pos := g_key_date_cache.count()+1;
    g_key_date_cache(l_pos).key := l_key;
    g_key_date_cache(l_pos).min_date := l_min_date;
    g_key_date_cache(l_pos).max_date := l_max_date;
    g_key_date_cache(l_pos).got_flag := l_got_flag;

  end if;
  if (g_traces) then
  hr_utility.trace('Cache utilised key = '||l_key||', pos = '||l_pos);
  hr_utility.trace('min date = '||
                      to_char(g_key_date_cache(l_pos).min_date,'DD-MON-RR HH24:MI:SS'));
  hr_utility.trace('max date = '||
                      to_char(g_key_date_cache(l_pos).max_date,'DD-MON-RR HH24:MI:SS'));
  end if;
  p_cache_number :=l_pos;

  if (g_dbg) then
  hr_utility.set_location(l_proc, 900);
  end if;
end get_dbt_i_p_cache;


/* ----------------------------------------------------------
Procedure: extra_tests_i --Both dbt and dyt_pkg
High Level Summary:
  Look at candidate process event to see if it is an insert
--
Detail Logic:
1) Check this candidate is indicative of an Insert event update
2) Check this candidate is the absolute min creation date for this
   event update, surrogate key combination
   as clearly later inserts will not be a result of a true insert.
3) No earlier dated row exist in base table, and one today
   eg sanity check point 2 and also DO NOT RETURN A TRUE INSERT
  IF THE DATA HAS BEEN PURGED (this is designed behaviour) against
  the concept of a total audit trail.

   ---------------------------------------------------------- */
PROCEDURE extra_tests_i
(
     p_pro_evt_rec          IN  t_mst_process_event_rec , --record from master query
     p_dtevent_rec          IN  t_distinct_table_rec ,
     p_disco                IN OUT NOCOPY number
)  IS

  l_statement varchar2(800);
  l_dummy number := null;
  l_pos number;

  l_proc    VARCHAR2(80) := g_pkg||'.extra_tests_i';

BEGIN
   if (g_dbg) then
   hr_utility.set_location(l_proc, 10);
   end if;

   -- 1 >>> Check the found process event is an Insert
   --Quick short-circuit opportunity
   -- Removed here as done prior in calling code
    --if (p_pro_evt_rec.event_type <> 'I'
    --    AND p_pro_evt_rec.event_type <> hr_api.g_insert) then
    --  p_disco := G_DISCO_NONE;
    --  RETURN;
    --end if;


  -- 2 >>> We are looking for true inserts, this MUST be the earliest
  --  ins record for this surrogate key and event update_id, if its not
  --  then return straight away

  -- if weve got a min date stored in our cache, then use that for the
  -- comparison, ow go and get it now

  get_dbt_i_p_cache
  (
     p_surrogate_key   => p_pro_evt_rec.surrogate_key,
     p_event_update_id => p_pro_evt_rec.event_update_id,
     p_assignment_id   => p_pro_evt_rec.assignment_id,
     p_change_mode     => p_pro_evt_rec.change_mode,
     p_cache_number    => l_pos
) ;


  if (g_traces) then
  hr_utility.trace('Compare date = '||to_char(g_key_date_cache(l_pos).min_date,'DD-MON-RR HH24:MI:SS')||
                      ' - '||
                      to_char(p_pro_evt_rec.creation_date,'DD-MON-RR HH24:MI:SS'));
  hr_utility.trace('Compare N flag to '||g_key_date_cache(l_pos).got_flag);
  end if;

  --MAIN COMPARE
  if (p_pro_evt_rec.creation_date = g_key_date_cache(l_pos).min_date
      and g_key_date_cache(l_pos).got_flag = 'N' ) then

  -- 3 >>> Now check base table to see if we had any rows for this surrogate key
  -- on the previous day (if weve got here we know weve only got the
  -- earliest created ppe row, but sanity check and test for any future purge
  -- (Non-dated dated tables we know cant have straight away)
  if (p_dtevent_rec.start_date_name is null) then
      --g_key_date_cache(l_pos).got_flag := 'Y' ;
      p_disco := G_DISCO_STANDARD;
  else

    l_statement :=
        'SELECT count(*) FROM '||p_dtevent_rec.table_name||
        ' WHERE ' || p_dtevent_rec.surrogate_key_name || ' = :1 '||
        ' AND '|| p_dtevent_rec.start_date_name || ' <=  :2 ';

     if (g_dbg) then
        hr_utility.trace('>>> Dynamic SQL: '||l_statement);
      end if;
        execute immediate l_statement
         into l_dummy
         using p_pro_evt_rec.surrogate_key,  --:1
               p_pro_evt_rec.effective_date; --:2
    --
      IF (l_dummy = 1) THEN
        --g_key_date_cache(l_pos).got_flag := 'Y' ;
        p_disco := G_DISCO_STANDARD;
      end if;
    end if;
  END IF; --end if else due to non-dated support
   if (g_dbg) then
   hr_utility.set_location(l_proc, 900);
   end if;
END extra_tests_i;

/* ----------------------------------------------------------
Procedure: extra_tests_dyt_pkg_u
High Level Summary:
  Look at candidate process event to see if it is an update
--
Detail Logic:
1) Check the event update is the right type
        AND   peu.event_type = hr_api.g_update
2) Check the update is one we're interested

   ---------------------------------------------------------- */
PROCEDURE extra_tests_dyt_pkg_u
(
     p_element_entry_id     IN  pay_element_entries.element_entry_id%type,
     p_assignment_action_id IN  pay_assignment_actions.assignment_action_id%type,
     p_business_group_id    IN  per_business_groups.business_group_id%type,
     p_assignment_id        IN  per_all_assignments_f.assignment_id%type,
     p_process_mode         IN  VARCHAR2,
     p_event_group_id       IN  pay_event_groups.event_group_id%type,
     p_start_date           IN  date,
     p_end_date             IN  date,
     p_date_counter         IN OUT NOCOPY number,
     p_global_env           IN OUT NOCOPY t_global_env_rec,
     t_dynamic_sql          IN OUT NOCOPY t_dynamic_sql_tab,

     t_proration_dates_temp  IN OUT NOCOPY  t_proration_dates_table_type,
     t_proration_change_type IN OUT NOCOPY  t_proration_type_table_type,
     t_proration_type        IN OUT NOCOPY  t_proration_type_table_type,
     t_detailed_output       IN OUT NOCOPY  t_detailed_output_table_type,

     p_pro_evt_rec          IN  t_mst_process_event_rec , --record from master query
     p_dtevent_rec          IN  t_distinct_table_rec ,
     p_disco                IN OUT NOCOPY number
)  IS

  l_proc    VARCHAR2(80) := g_pkg||'.extra_tests_dyt_pkg_u';

BEGIN
  if (g_dbg) then
  hr_utility.set_location(l_proc, 10);
  end if;

  if ( p_pro_evt_rec.event_type  = hr_api.g_update
    or p_pro_evt_rec.event_type  = hr_api.g_update_override
    or p_pro_evt_rec.event_type  = hr_api.g_update_change_insert
      ) then

      event_group_table_updated(p_element_entry_id,
                                p_assignment_action_id,
                                p_business_group_id,
                                p_assignment_id,
                                p_process_mode,
                                p_pro_evt_rec.change_mode,
                                p_event_group_id,
                                p_dtevent_rec.table_id,
                                p_dtevent_rec.table_name,
                                p_dtevent_rec.surrogate_key_name,
                                p_pro_evt_rec.surrogate_key,
                                p_dtevent_rec.start_date_name,
                                p_dtevent_rec.end_date_name,
                                p_pro_evt_rec.effective_date,
                                p_pro_evt_rec.creation_date,
                                p_start_date,
                                p_end_date,
                                p_pro_evt_rec.updated_column_name,
                                p_date_counter,
                                p_global_env,
                                p_dtevent_rec.proration_type,
                                t_dynamic_sql,
                                t_proration_dates_temp,
                                t_proration_change_type,
                                t_proration_type,
                                t_detailed_output );
  --NB This is the only instance in extra_tests where we do not return a found event
  --   existing code has already added the event so dont explicitly flag it for addition here
  end if;

  if (g_dbg) then
  hr_utility.set_location(l_proc, 900);
  end if;
END extra_tests_dyt_pkg_u;

/* ----------------------------------------------------------
Procedure: extra_tests_dbt_p
High Level Summary:
  Look at candidate process event to see if it is a correction
  Similar to extra_tests_i
--
Detail Logic:
1) Check the event update is the right type, a deletion
2) Check this is the latest created ppe event for this
  event_update/surrogate_key combination
3) Check this deletion is part of a purge, no rows in base table
  also check we havent got this event yet under the guise of another
  ppe row, 'cos creation date may be identical for several

   ---------------------------------------------------------- */
PROCEDURE extra_tests_dbt_p
(
     p_pro_evt_rec         IN  t_mst_process_event_rec ,
     p_dtevent_rec         IN  t_distinct_table_rec ,
     p_disco               IN OUT NOCOPY number
)  IS


  l_statement varchar2(800);
  l_dummy number := null;
  l_pos number := 0;

  l_proc    VARCHAR2(80) := g_pkg||'.extra_tests_dbt_p';

BEGIN
   if (g_dbg) then
   hr_utility.set_location(l_proc, 10);
   end if;

    -- 1 >>> Check the found process event is an Delete
    -- Quick short-circuit opportunity
    -- Removed as done prior in calling code
    -- if (p_pro_evt_rec.event_type <> 'D') then
    --   p_disco := G_DISCO_NONE;
    --   RETURN;
    -- end if;

  -- 2 >>> We are looking for total purges, this MUST be the last
  --  del record for this surrogate key and event update_id, if its not
  --  then return straight away
  get_dbt_i_p_cache
  (
     p_surrogate_key   => p_pro_evt_rec.surrogate_key,
     p_event_update_id => p_pro_evt_rec.event_update_id,
     p_assignment_id   => p_pro_evt_rec.assignment_id,
     p_change_mode     => p_pro_evt_rec.change_mode,
     p_cache_number    => l_pos
  ) ;


  if (g_traces) then
  hr_utility.trace('Compare date = '||to_char(g_key_date_cache(l_pos).min_date,'DD-MON-RR HH24:MI:SS')||
                      ' - '||
                      to_char(p_pro_evt_rec.creation_date,'DD-MON-RR HH24:MI:SS'));
  hr_utility.trace('Compare N flag to '||g_key_date_cache(l_pos).got_flag);
  end if;

  -- MAIN TEST
  if (p_pro_evt_rec.creation_date = g_key_date_cache(l_pos).max_date
      and g_key_date_cache(l_pos).got_flag = 'N') then

    -- 3 >>> Now check base table
    if (g_dbg) then
    hr_utility.set_location(l_proc, 30);
    end if;

    --Now check base table to see if we have any rows for this surrogate key
    -- just need one row
     l_statement :=
        'SELECT count(*) FROM '||p_dtevent_rec.table_name||
        ' WHERE '||p_dtevent_rec.surrogate_key_name ||' = :1 ';

     if (g_dbg) then
     hr_utility.trace('-Dynamic SQL: '||l_statement);
     end if;
     execute immediate l_statement
      into l_dummy
      using p_pro_evt_rec.surrogate_key;  --:1

    IF (l_dummy = 0 ) THEN
      --Got no rows, so delete is part of PURGE
      p_disco := G_DISCO_STANDARD;
      --g_key_date_cache(l_pos).got_flag := 'Y';  --make sure we dont get this again

    END IF;

  end if;


  if (g_dbg) then
  hr_utility.set_location(l_proc, 900);
  end if;
END extra_tests_dbt_p;


/* ----------------------------------------------------------
Procedure: extra_tests_dyt_pkg_df
High Level Summary:
  As dynamic trigger package, its immediately obvious when a delete future
  (FUTURE_CHANGE or DELETE_NEXT_CHANGE has occurred)
  But functional requirement to check this is still valid,
  eg dont return if a new row has now been introduced after
--
Detail Logic:
   Easy to identify 'FUTURE_CHANGE','DELETE_NEXT_CHANGE'
   ...just want to check all future deletes are still applicable, eg no-one
   has reintroduced some information for the surrogate key.

   ---------------------------------------------------------- */
PROCEDURE extra_tests_dyt_pkg_df
(
     p_pro_evt_rec          IN  t_mst_process_event_rec , --record from master query
     p_dtevent_rec          IN  t_distinct_table_rec ,
     p_disco                IN OUT NOCOPY number
)  IS
  l_statement varchar2(800);
  l_dummy number := null;

  l_proc    VARCHAR2(80) := g_pkg||'.extra_tests_dyt_pkg_df';

BEGIN
  if (g_dbg) then
  hr_utility.set_location(l_proc, 10);
  end if;

  -- >>> PHASE 4: Check no future rows
  --

  IF   ( p_pro_evt_rec.event_type = hr_api.g_future_change or
       p_pro_evt_rec.event_type = hr_api.g_delete_next_change ) THEN

    --Check the base table to see if any future dated records exist,
    -- Eg we know we have a FUTURE_CHANGE or a DELETE_NEXT_CHANGE
    -- but check it still applies, not been overriden
    l_statement :=
        'SELECT count(*) FROM '||p_dtevent_rec.table_name||
        ' WHERE ' || p_dtevent_rec.surrogate_key_name || ' =  :1 ' ||
        ' AND    '|| p_dtevent_rec.end_date_name || ' >= :2 ';

    if (g_dbg) then
    hr_utility.trace(l_statement);
    end if;
      execute immediate l_statement
        into l_dummy
        using p_pro_evt_rec.surrogate_key,   --:1
              p_pro_evt_rec.effective_date;  --:2

     IF (l_dummy >= 1)  then
       p_disco := G_DISCO_STANDARD;
     END IF;

  END IF;
  if (g_dbg) then
  hr_utility.set_location(l_proc, 900);
  end if;
END extra_tests_dyt_pkg_df;
--
procedure analyse_disco_process_events
(
     p_element_entry_id     IN  NUMBER ,
     p_assignment_id        IN  NUMBER ,
     p_assignment_action_id IN  NUMBER ,
     p_business_group_id    IN  NUMBER ,
     p_start_date           IN  DATE   ,
     p_end_date             IN  DATE,
     p_mode                 IN  VARCHAR2,
     p_process              IN  VARCHAR2,
     p_process_mode         IN  VARCHAR2,
     p_range_start          IN  NUMBER,
     p_range_end            IN  NUMBER,
     p_mst_pe_rec            IN             t_mst_process_event_rec,
     p_event_group_id        IN NUMBER,
     p_distinct_tab          IN             t_distinct_table,
     p_penserv_mode          IN VARCHAR2 DEFAULT 'N',
     p_date_counter          IN OUT NOCOPY  NUMBER,
     p_global_env            IN OUT NOCOPY  t_global_env_rec,
     t_dynamic_sql           IN OUT NOCOPY  t_dynamic_sql_tab,
     t_proration_dates_temp  IN OUT NOCOPY  t_proration_dates_table_type,
     t_proration_change_type IN OUT NOCOPY  t_proration_type_table_type,
     t_proration_type        IN OUT NOCOPY  t_proration_type_table_type,
     t_detailed_output       IN OUT NOCOPY  t_detailed_output_table_type
)
IS
  l_look_for_rec          t_distinct_table_rec;
  l_previous_look_for_rec t_distinct_table_rec;  --bug 3598389
  l_search                varchar2(30);
  disco                   number;
  l_all_upd_events_recorded boolean := FALSE; --tested before doing extra upd checks below
BEGIN
--
  if (g_traces) then
     hr_utility.trace('>> New master candidate PE: '||
                        p_mst_pe_rec.process_event_id||
                        ' , indicative of update_id: '||
                        p_mst_pe_rec.event_update_id||
                        ' key: '||
                        p_mst_pe_rec.surrogate_key   );
  end if;
  if (g_dbg) then
     hr_utility.trace('   Look within Event group '||
                       p_event_group_id||
                       ' with: '||
                        to_char( to_number(nvl(p_range_end,0))
                                 - to_number(nvl(p_range_start,0)) + 1 )||
                        ' events');
  end if;
--
  -- >>> PHASE 3:
  --
  -- Loop through the table of datetracked events that the user
  -- has expressed an interest in.  Perform a test on our master
  -- candidate row to see if it matches the desired event
--
  disco := G_DISCO_NONE;
--
  FOR l_tab_loop_counter IN p_range_start..p_range_end
    LOOP
     -- Look for next event in Event Group
     l_look_for_rec := p_distinct_tab(l_tab_loop_counter);
     l_search := l_look_for_rec.update_type;

      if (g_dbg) then
         hr_utility.trace('   + Searching... event '||
                          l_look_for_rec.datetracked_event_id||
                          ' an: '||
                          l_search||
                          ' on '||
                          l_look_for_rec.table_name||
                          '.'||
                          l_look_for_rec.column_name);
      end if;

      -- As we are interpreting events in PPE, we must decide the
      -- kind of patterns to recognise in this table.  These patterns
      -- depend on whether the rows were inserted (event captured) by
      -- the DYnamic Trigger PacKaGe methodology (eg from api->rhi->hook)
      -- or from dyt's as db trigs.  In other words, if DBMS_TRIGGERS
      -- then we need to check for patterns that represent both API-row
      -- level updates and DT library row-level updates, If the table
      -- is DYT_PKG mode, then we need to check for patterns representing
      -- API-hook updates
--
      -- First make sure the process is on the correct table
      -- (or our one exception of element entries and element_entry_values_f)
      -- if not then dont do any more processing, get next p_mst_pe_rec
--
      IF (p_mst_pe_rec.table_name = l_look_for_rec.table_name
         or ( p_mst_pe_rec.table_name = 'PAY_ELEMENT_ENTRIES_F'
              and l_look_for_rec.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F') )
      then


------------ START fix for BUG 3598389 --------------------------
-- As the events have been ordered by table_name,type
-- we know if the event before this was same table, also "update"
-- then we would have already recorded our current datetracked_event previously
-- thus set flag so no duplicate processing will occur.

  l_all_upd_events_recorded := FALSE;
 -- Only relevant to Update datetracked_events and not the first one
 -- (as first has no prior record)
 if (l_tab_loop_counter > p_range_start and l_search = 'U') then
   l_previous_look_for_rec := p_distinct_tab(l_tab_loop_counter - 1);
   if (    l_previous_look_for_rec.update_type = 'U'
       and l_look_for_rec.table_name = l_previous_look_for_rec.table_name) then
   l_all_upd_events_recorded := TRUE;
   else
   l_all_upd_events_recorded := FALSE;
   end if;

 end if;
------------ End fix for BUG 3598389 --------------------------

         -- a chance we're interested, so do extra work
         if (g_dbg) then
            hr_utility.trace(
               '     Found a candidate PE on same table as our DE: '||
               'so call extra logic');
         end if;

         -- The if /elsif conditions have changed for bg 3488104
         -- Now call the code that identifies whether this process_event
         -- is indeed indicative of the event we are looking for.  This
         -- comparing code is dependent on whether the pe_rec was created
         -- as part of a dbt dyn trig or a dyt_pkg dyn trigger.
--
         -- Dynamic Triggers as dbt_trig are event_type  'I, 'U', 'D'
         -- Dynamic Triggers as dyt_pkg are all other event_types
--
         IF (   l_search = 'I'  and p_mst_pe_rec.event_type = 'I')  then
             extra_tests_i(p_mst_pe_rec,l_look_for_rec,disco);
         ELSIF (l_search = 'I'  and
                p_mst_pe_rec.event_type = hr_api.g_insert)  then
             extra_tests_i(p_mst_pe_rec,l_look_for_rec,disco);
--
         ELSIF (l_search = 'U'  and p_mst_pe_rec.event_type = 'U'
                and l_all_upd_events_recorded <> TRUE) then
          extra_tests_dbt_u_e(
                p_element_entry_id     =>  p_element_entry_id,
                p_assignment_action_id =>  p_assignment_action_id,
                p_business_group_id    =>  p_business_group_id,
                p_assignment_id        =>  p_assignment_id,
                p_process_mode         =>  p_process_mode,
                p_event_group_id       =>  null,
                p_start_date           =>  p_start_date,
                p_end_date             =>  p_end_date,
		p_penserv_mode         => p_penserv_mode,
                p_date_counter         =>  p_date_counter, --in/out
                p_global_env           =>  p_global_env,
                t_dynamic_sql          =>  t_dynamic_sql, --in/out
                t_proration_dates_temp  => t_proration_dates_temp, --in/out
                t_proration_change_type => t_proration_change_type, --in/out
                t_proration_type        => t_proration_type, --in/out
                t_detailed_output       => t_detailed_output, --in/out
                p_pro_evt_rec          => p_mst_pe_rec  , --record from
                                                          -- master query
                p_dtevent_rec          => l_look_for_rec  ,
                p_disco                => disco --in/out
           );


        ELSIF (l_search = 'U'  and
               p_mst_pe_rec.event_type not in ('I','U','D')
                and l_all_upd_events_recorded <> TRUE) then
           extra_tests_dyt_pkg_u(
                p_element_entry_id     =>  p_element_entry_id,
                p_assignment_action_id =>  p_assignment_action_id,
                p_business_group_id    =>  p_business_group_id,
                p_assignment_id        =>  p_assignment_id,
                p_process_mode         =>  p_process_mode,
                p_event_group_id       =>  null,
                p_start_date           =>  p_start_date,
                p_end_date             =>  p_end_date,
                p_date_counter         =>  p_date_counter, --in/out
                p_global_env           =>  p_global_env,
                t_dynamic_sql          =>  t_dynamic_sql, --in/out
                t_proration_dates_temp  => t_proration_dates_temp, --in/out
                t_proration_change_type => t_proration_change_type, --in/out
                t_proration_type        => t_proration_type, --in/out
                t_detailed_output       => t_detailed_output, --in/out
                p_pro_evt_rec          => p_mst_pe_rec  , --record from
                                                          -- master query
                p_dtevent_rec          => l_look_for_rec  ,
                p_disco                => disco --in/out
           );

        ELSIF (l_search = 'C'  and p_mst_pe_rec.event_type = 'U') then
           -- Simple test for Database Trigger styled Correction
           if (p_mst_pe_rec.updated_column_name = l_look_for_rec.column_name)
           then
              disco := G_DISCO_STANDARD;
           end if;

        ELSIF (l_search = 'C'  and
               p_mst_pe_rec.event_type not in ('I','U','D')) then
--
            -- Simple test for Dynamic Package styled Correction
            if (p_mst_pe_rec.updated_column_name = l_look_for_rec.column_name
                and p_mst_pe_rec.event_type  = hr_api.g_correction) then
              disco := G_DISCO_STANDARD;
            end if;

        ELSIF (l_search = 'P'  and p_mst_pe_rec.event_type = 'D') then
           extra_tests_dbt_p(p_mst_pe_rec,l_look_for_rec,disco);
        ELSIF (l_search = 'P'  and
               p_mst_pe_rec.event_type = hr_api.g_zap ) then
            -- Simple test already performed for Dynamic Package styled Purge
            disco := G_DISCO_STANDARD;

        ELSIF (l_search = 'E'  and
               p_mst_pe_rec.event_type in ('I','U','D')) then
            extra_tests_dbt_u_e(
                  p_element_entry_id     =>  p_element_entry_id,
                  p_assignment_action_id =>  p_assignment_action_id,
                  p_business_group_id    =>  p_business_group_id,
                  p_assignment_id        =>  p_assignment_id,
                  p_process_mode         =>  p_process_mode,
                  p_event_group_id       =>  null,
                  p_start_date           =>  p_start_date,
                  p_end_date             =>  p_end_date,
		  p_penserv_mode         => p_penserv_mode,
                  p_date_counter         =>  p_date_counter, --in/out
                  p_global_env           =>  p_global_env,
                  t_dynamic_sql          =>  t_dynamic_sql, --in/out
                  t_proration_dates_temp  => t_proration_dates_temp, --in/out
                  t_proration_change_type => t_proration_change_type, --in/out
                  t_proration_type        => t_proration_type, --in/out
                  t_detailed_output       => t_detailed_output, --in/out
                  p_pro_evt_rec          => p_mst_pe_rec  , --record from
                                                            -- master query
                  p_dtevent_rec          => l_look_for_rec  ,
                  p_disco                => disco --in/out
             );

        ELSIF (l_search = 'E'  and
               p_mst_pe_rec.event_type not in ('I','U','D')) then
           extra_tests_dyt_pkg_e(p_mst_pe_rec,l_look_for_rec,disco);

        ELSIF (l_search = 'DF'
               and p_mst_pe_rec.event_type in ('I','U','D')
               ) then

           disco := G_DISCO_DF; -- This test calls save directly so set here...
           extra_tests_dbt_df(
                 p_element_entry_id     =>  p_element_entry_id,
                 p_assignment_action_id =>  p_assignment_action_id,
                 p_business_group_id    =>  p_business_group_id,
                 p_assignment_id        =>  p_assignment_id,
                 p_mode                 =>  p_mode,
                 p_process              =>  p_process,
                 p_process_mode         =>  p_process_mode,
                 p_event_group_id       =>  p_event_group_id,
                 p_start_date           =>  p_start_date,
                 p_end_date             =>  p_end_date,
                 p_penserv_mode         =>  p_penserv_mode, /*Bug 7409433 */
                 p_date_counter         =>  p_date_counter, --in/out
                 p_global_env           =>  p_global_env,
                 t_dynamic_sql          =>  t_dynamic_sql, --in/out
                 t_proration_dates_temp  => t_proration_dates_temp, --in/out
                 t_proration_change_type => t_proration_change_type, --in/out
                 t_proration_type        => t_proration_type, --in/out
                 t_detailed_output       => t_detailed_output, --in/out
                 p_pro_evt_rec          => p_mst_pe_rec  , -- record from
                                                           -- master query
                 p_dtevent_rec          => l_look_for_rec  ,
                 p_disco                => disco --in/out
            );

          disco := G_DISCO_NONE; -- ... and unset here
        ELSIF (l_search = 'DF'  and
               p_mst_pe_rec.event_type not in ('I','U','D')) then
            extra_tests_dyt_pkg_df(p_mst_pe_rec,l_look_for_rec,disco);

        END IF;


        If (disco <> G_DISCO_NONE) then
           --Add found event to store

           save_disco_details (
               p_effective_date        =>  p_mst_pe_rec.effective_date,
               p_creation_date         =>  p_mst_pe_rec.creation_date,
               p_update_type           =>  l_search,
               p_change_mode           =>  p_mst_pe_rec.change_mode,
               p_process_mode          =>  p_process_mode,
               p_proration_type        =>  l_look_for_rec.proration_type,
               p_datetracked_event     =>  l_look_for_rec.datetracked_event_id,
               p_column_name           =>  p_mst_pe_rec.updated_column_name,
               p_change_values         =>  p_mst_pe_rec.change_values,
               p_element_entry_id      =>  p_element_entry_id,
               p_surrogate_key         =>  p_mst_pe_rec.surrogate_key,
               p_dated_table_id        =>  l_look_for_rec.table_id,
               p_table_name            =>  l_look_for_rec.table_name,
               p_disco                 =>  disco,
               p_start_date            =>  p_start_date,
               p_end_date              =>  p_end_date,
               p_assignment_action_id  =>  p_assignment_action_id,
               p_business_group_id     =>  p_business_group_id,
               p_assignment_id         =>  p_assignment_id,
               p_penserv_mode          =>  p_penserv_mode, /*Bug 7409433 */
               p_date_counter          =>  p_date_counter,
               p_global_env            =>  p_global_env,
               t_proration_dates_temp  =>  t_proration_dates_temp,
               t_proration_change_type =>  t_proration_change_type,
               t_proration_type        =>  t_proration_type,
               t_detailed_output       =>  t_detailed_output
             );
           disco := G_DISCO_NONE;

        end if;

      END IF; --PE not on same table as DE, so get next DE

  END LOOP; -- Get next datetracked event in cache and compare
            -- this event with that
--
end analyse_disco_process_events;
--
--
-- Name: valid_group_event_for_asg
-- Description : This function is used by the group level
--               cursors. It tries to reduce the group
--               level work needed by performing
--               simple group level restrictions
--
function valid_group_event_for_asg(p_table_name    in varchar2,
                                   p_assignment_id in number,
                                   p_surrogate_key in varchar2)
return varchar2
is
--
cursor validate_grade(p_assignment_id in number
                      )
is
     select /*+ USE_NL(pgr paf)*/
            pgr.grade_rule_id
       from pay_grade_rules_f pgr,
            per_all_assignments_f paf
      where paf.assignment_id = p_assignment_id
        and paf.grade_id = pgr.grade_or_spinal_point_id
     union all
     select /*+ ORDERED USE_NL(pgr psp psps pspp)*/
            pgr.grade_rule_id
       from per_spinal_point_placements_f pspp,
            per_spinal_point_steps_f      psps,
            per_spinal_points             psp,
            pay_grade_rules_f             pgr
      where psp.spinal_point_id = pgr.grade_or_spinal_point_id
        and psp.spinal_point_id = psps.spinal_point_id
        and p_assignment_id = pspp.assignment_id
        and pspp.step_id = psps.step_id;
--
cursor validate_rate_by_criteria(p_assignment_id in number,
                      p_surrogate_key in number)
is
select '' chk
from dual
where exists (
	select '' chk
        from pay_element_entries_f pee
            ,pqh_criteria_rate_elements pcre
            ,pqh_rate_matrix_rates_f prmr
	where pee.assignment_id=p_assignment_id
        and pcre.element_type_id=pee.element_type_id
  	and pcre.criteria_rate_defn_id=prmr.criteria_rate_defn_id
        and prmr.rate_matrix_rate_id=p_surrogate_key)
or exists (
         select '' chk
         from pay_element_entries_f pee
            ,pqh_criteria_rate_elements pcre
	    ,pqh_criteria_rate_factors pcrf
            ,pqh_rate_matrix_rates_f prmr
         where pee.assignment_id=p_assignment_id
  	 and pcre.element_type_id=pee.element_type_id
  	 and pcre.criteria_rate_defn_id = pcrf.criteria_rate_defn_id
  	 and pcrf.parent_criteria_rate_defn_id = prmr.criteria_rate_defn_id
  	 and prmr.rate_matrix_rate_id = p_surrogate_key);


l_valid_event varchar2(5);
begin
--
    l_valid_event := 'Y';
--
    if (p_table_name = 'PAY_GRADE_RULES_F') then
--
      if (g_grd_assignment_id <> p_assignment_id) then
--
         g_grade_list.delete();
         g_grd_assignment_id := p_assignment_id;
--
         for grrec in validate_grade(p_assignment_id) loop
             g_grade_list(grrec.grade_rule_id) := grrec.grade_rule_id;
         end loop;
--
      end if;
--
      l_valid_event := 'N';
--
      if (g_grade_list.exists(p_surrogate_key)) then
--
         l_valid_event := 'Y';
--
      end if;
--
    elsif  (p_table_name = 'PQH_RATE_MATRIX_RATES_F') then

      l_valid_event := 'N';

      for grrec in validate_rate_by_criteria(p_assignment_id,p_surrogate_key) loop
--
         l_valid_event := 'Y';
--
      end loop;
--
    elsif  (p_table_name = 'FF_GLOBALS_F') then
--
      l_valid_event := pay_group_event_pkg.ff_global_check(p_assignment_id,p_surrogate_key);
--
    elsif  (p_table_name = 'PAY_USER_COLUMN_INSTANCES_F') then
--
      l_valid_event := pay_group_event_pkg.pay_user_table_check(p_assignment_id,p_surrogate_key);
--
    end if;
--
    return l_valid_event;
--
end valid_group_event_for_asg;
--
--
----------------------------

-- ----------------------------------------------------------------------------
-- |----------------------------< get_penserver_date >-------------------------|
-- Description : For each assignment fetch the least effective date
-- ----------------------------------------------------------------------------

FUNCTION get_penserver_date
                (p_assignment_id      IN   NUMBER
                ,p_business_group_id  IN   NUMBER
                ,p_lapp_date          IN   DATE
                ,p_end_date           IN   DATE
                 )  RETURN date
    IS

    l_penserver_date date;

    -- This cursor will fetch the minimum efective on which a penserver event has
    -- occured for the employee having the creation_date in the current period.
    cursor csr_pen_eff_date
        is select min(ppe.effective_date)
             from pay_process_events ppe
            where trunc(ppe.creation_date) between p_lapp_date and p_end_date
              and ppe.assignment_id = p_assignment_id
              and ppe.business_group_id = p_business_group_id
              and ppe.effective_date >= ben_ext_thread.g_effective_start_date
              and  exists (select pde.event_group_id
                             from pay_datetracked_events pde,
                                  pay_event_updates peu
                            where pde.event_group_id in (select becv.val_1
                                                           from ben_ext_crit_val becv,
                                                                ben_ext_crit_typ bect,
                                                                ben_ext_dfn  bed
                                                          where becv.ext_crit_typ_id = bect.ext_crit_typ_id
                                                            and bect.ext_crit_prfl_id = bed.ext_crit_prfl_id
                                                            and bed.ext_dfn_id = ben_ext_thread.g_ext_dfn_id
                                                            and bect.crit_typ_cd = 'CPE')
                             and ppe.event_update_id = peu.event_update_id
                             and peu.dated_table_id = pde.dated_table_id);


   BEGIN

    open csr_pen_eff_date;
    fetch csr_pen_eff_date into l_penserver_date;
    if l_penserver_date is null
    then
       l_penserver_date := p_lapp_date;
    end if;
    close csr_pen_eff_date;


    if l_penserver_date > p_lapp_date
    then
       l_penserver_date := p_lapp_date;
    end if;

    l_penserver_date := l_penserver_date - 1;


    hr_utility.trace('p_lapp_date :' ||p_lapp_date);
    hr_utility.trace('l_penserver_date :' ||l_penserver_date);

    RETURN l_penserver_date;

   END get_penserver_date;

-- P_d(atetracked)ev(ents) info, eg stuff to look for

-- This procedure called for each table within the event group
PROCEDURE record_all_disco_events
(
     p_event_group_id       IN  NUMBER ,

     p_element_entry_id     IN  NUMBER ,
     p_assignment_id        IN  NUMBER ,
     p_assignment_action_id IN  NUMBER ,
     p_business_group_id    IN  NUMBER ,
     p_start_date           IN  DATE   ,
     p_end_date             IN  DATE,
     p_process              IN  VARCHAR2,
     p_mode                 IN  VARCHAR2,
     p_process_mode         IN  VARCHAR2,
     p_global_env            IN OUT NOCOPY  t_global_env_rec,
     t_dynamic_sql           IN OUT NOCOPY  t_dynamic_sql_tab,
     t_proration_dates_temp  IN OUT NOCOPY  t_proration_dates_table_type,
     t_proration_change_type IN OUT NOCOPY  t_proration_type_table_type,
     t_proration_type        IN OUT NOCOPY  t_proration_type_table_type,
     t_detailed_output       IN OUT NOCOPY  t_detailed_output_table_type,
     p_penserv_mode          IN VARCHAR2 DEFAULT 'N'
) AS
--
-- Setup the types
--
type t_column_name is table of pay_event_updates.column_name%type
     index by binary_integer;
type t_event_type is table of pay_event_updates.event_type%type
     index by binary_integer;
type t_event_update_id is table of pay_event_updates.event_update_id%type
     index by binary_integer;
type t_effective_date is table of pay_process_events.effective_date%type
     index by binary_integer;
type t_assignment_id is table of pay_process_events.assignment_id%type
     index by binary_integer;
type t_surrogate_key is table of pay_process_events.surrogate_key%type
     index by binary_integer;
type t_process_event_id is table of pay_process_events.process_event_id%type
     index by binary_integer;
type t_description is table of pay_process_events.description%type
     index by binary_integer;
type t_calculation_date is table of pay_process_events.calculation_date%type
     index by binary_integer;
type t_creation_date is table of pay_process_events.creation_date%type
     index by binary_integer;
type t_change_type is table of pay_process_events.change_type%type
     index by binary_integer;
type t_table_name is table of pay_dated_tables.table_name%type
     index by binary_integer;
--
l_column_name      t_column_name;
l_event_type       t_event_type;
l_event_update_id  t_event_update_id;
l_effective_date   t_effective_date;
l_assignment_id    t_assignment_id;
l_surrogate_key    t_surrogate_key;
l_process_event_id t_process_event_id;
l_description      t_description;
l_calculation_date t_calculation_date;
l_creation_date    t_creation_date;
l_change_type      t_change_type;
l_table_name       t_table_name;
--
  -- NB Following statement has been tuned for performance purposes
  CURSOR csr_all_process_events_cre (
                  cp_bulk_processing   IN VARCHAR,
                  cp_cstart_date       IN DATE ,
                  cp_cend_date         IN DATE    )  IS

     SELECT  /*+ no_expand ORDERED INDEX(PPE PAY_PROCESS_EVENTS_N3) USE_NL(PPE) */
             peu.column_name       updated_column_name ,
             peu.event_type        event_type          ,
             peu.event_update_id   event_update_id     ,
             ppe.effective_date    effective_date      ,
             ppe.assignment_id     assignment_id       ,
             ppe.surrogate_key     surrogate_key       ,
             ppe.process_event_id  process_event_id,
             ppe.description       change_values,
             ppe.calculation_date  calculation_date,
             ppe.creation_date     creation_date,
             ppe.change_type       change_mode,
             pdt.table_name        table_name
     FROM
             pay_dated_tables    pdt ,
             pay_process_events  ppe ,
             pay_event_updates   peu
     WHERE
             peu.event_update_id      = ppe.event_update_id + 0
     AND     peu.dated_table_id       = pdt.dated_table_id
     AND     pdt.dated_table_id IN
               ( select distinct pde2.dated_table_id table_id
                        from   pay_datetracked_events pde2
                        where  pde2.event_group_id = p_event_group_id
                          and  cp_bulk_processing =  'N'
                 union all
                  select distinct pdt2.dated_table_id
                    from pay_dated_tables pdt2
                   where cp_bulk_processing =  'Y'
               )
     AND     ppe.assignment_id is not null
     AND     ppe.assignment_id = p_assignment_id
     AND  ppe.business_group_id = p_business_group_id
     AND  (   peu.business_group_id = ppe.business_group_id
           or peu.legislation_code  = g_leg_code
          or (    peu.business_group_id is null
              and peu.legislation_code  is null) )
     AND   ppe.change_type = nvl(p_mode,ppe.change_type)
     AND   ppe.creation_date  BETWEEN cp_cstart_date AND cp_cend_date
     AND   (    (cp_bulk_processing = 'Y')
            or (    cp_bulk_processing = 'N'
                AND   ( (pdt.table_name <> 'PAY_ELEMENT_ENTRIES_F'   )
                         or
                        ( pdt.table_name = 'PAY_ELEMENT_ENTRIES_F'
                          and ppe.surrogate_key=p_element_entry_id )
                      )
                AND   ( ( pdt.table_name <> 'PAY_ELEMENT_ENTRY_VALUES_F'  )
                         or
                        ( pdt.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
                          and exists
                              ( select null
                                from pay_element_entry_values_f
                                where element_entry_id = p_element_entry_id
                                and   element_entry_value_id =
                                                       ppe.surrogate_key ) )
                      )
               )
           )
     UNION ALL
     SELECT  /*+ no_expand ORDERED INDEX(PPE PAY_PROCESS_EVENTS_N3) USE_NL(PDT) */
             peu.column_name       updated_column_name ,
             peu.event_type        event_type          ,
             peu.event_update_id   event_update_id     ,
             ppe.effective_date    effective_date      ,
             ppe.assignment_id     assignment_id       ,
             ppe.surrogate_key     surrogate_key       ,
             ppe.process_event_id  process_event_id,
             ppe.description       change_values,
             ppe.calculation_date  calculation_date,
             ppe.creation_date     creation_date,
             ppe.change_type       change_mode,
             pdt.table_name        table_name
     FROM
             pay_dated_tables    pdt ,
             pay_event_updates   peu ,
             pay_process_events  ppe
     WHERE
             peu.event_update_id      = ppe.event_update_id + 0
     AND     peu.dated_table_id       = pdt.dated_table_id
     AND     pdt.dated_table_id IN
               ( select distinct pde2.dated_table_id table_id
                        from   pay_datetracked_events pde2
                        where  pde2.event_group_id = p_event_group_id
                          and  cp_bulk_processing =  'N'
                 union all
                  select distinct pdt2.dated_table_id
                    from pay_dated_tables pdt2
                   where cp_bulk_processing =  'Y'
               )
     AND     ppe.assignment_id is null
     AND  ppe.business_group_id = p_business_group_id
     AND  (   peu.business_group_id = ppe.business_group_id
           or peu.legislation_code  = g_leg_code
           or (    peu.business_group_id is null
               and peu.legislation_code  is null) )
     AND   ppe.change_type = nvl(p_mode,ppe.change_type)
     AND   ppe.creation_date  BETWEEN cp_cstart_date AND cp_cend_date
     AND   (    (cp_bulk_processing = 'Y')
            or (    cp_bulk_processing = 'N'
                AND   ( (pdt.table_name <> 'PAY_ELEMENT_ENTRIES_F'   )
                         or
                        ( pdt.table_name = 'PAY_ELEMENT_ENTRIES_F'
                          and ppe.surrogate_key=p_element_entry_id )
                      )
                AND   ( ( pdt.table_name <> 'PAY_ELEMENT_ENTRY_VALUES_F'  )
                         or
                        ( pdt.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
                          and exists
                              ( select null
                                from pay_element_entry_values_f
                                where element_entry_id = p_element_entry_id
                                and   element_entry_value_id =
                                                       ppe.surrogate_key ) )
                      )
               )
           )
     AND pay_interpreter_pkg.valid_group_event_for_asg
                                  (pdt.table_name,
                                   p_assignment_id,
                                   ppe.surrogate_key) = 'Y'
     ORDER BY 11, 6, 5, 4;


  -- NB Following statement has been tuned for performance purposes
  CURSOR csr_all_process_events_eff(
                  cp_bulk_processing   IN VARCHAR2,
                  cp_estart_date       IN DATE ,
                  cp_eend_date         IN DATE    )  IS

     SELECT  /*+ no_expand ORDERED INDEX(PPE PAY_PROCESS_EVENTS_N5) USE_NL(PPE) */
             peu.column_name       updated_column_name ,
             peu.event_type        event_type          ,
             peu.event_update_id   event_update_id     ,
             ppe.effective_date    effective_date      ,
             ppe.assignment_id     assignment_id       ,
             ppe.surrogate_key     surrogate_key       ,
             ppe.process_event_id  process_event_id,
             ppe.description       change_values,
             ppe.calculation_date  calculation_date,
             ppe.creation_date     creation_date,
             ppe.change_type       change_mode,
             pdt.table_name        table_name
     FROM
             pay_dated_tables    pdt ,
             pay_process_events  ppe ,
             pay_event_updates   peu
     WHERE
             peu.event_update_id      = ppe.event_update_id + 0
     AND     peu.dated_table_id       = pdt.dated_table_id
     AND     pdt.dated_table_id IN
               ( select distinct pde2.dated_table_id table_id
                        from   pay_datetracked_events pde2
                        where  pde2.event_group_id = p_event_group_id
                          and  cp_bulk_processing =  'N'
                 union all
                  select distinct pdt2.dated_table_id
                    from pay_dated_tables pdt2
                   where cp_bulk_processing =  'Y'
               )
     AND     ppe.assignment_id is not null
     AND     ppe.assignment_id = p_assignment_id
     AND  ppe.business_group_id = p_business_group_id
     AND  (   peu.business_group_id = ppe.business_group_id
           or peu.legislation_code  = g_leg_code
           or (    peu.business_group_id is null
               and peu.legislation_code  is null) )
     AND   (ppe.retroactive_status = nvl(p_process, ppe.retroactive_status)
             or ppe.retroactive_status is null)
     AND   ppe.change_type = nvl(p_mode,ppe.change_type)
     AND   ppe.effective_date BETWEEN cp_estart_date AND cp_eend_date
     AND   (    (cp_bulk_processing = 'Y')
            or (    cp_bulk_processing = 'N'
                AND   ( (pdt.table_name <> 'PAY_ELEMENT_ENTRIES_F'   )
                         or
                        ( pdt.table_name = 'PAY_ELEMENT_ENTRIES_F'
                          and ppe.surrogate_key=p_element_entry_id )
                      )
                AND   ( ( pdt.table_name <> 'PAY_ELEMENT_ENTRY_VALUES_F'  )
                         or
                        ( pdt.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
                          and exists
                              ( select null
                                from pay_element_entry_values_f
                                where element_entry_id = p_element_entry_id
                                and   element_entry_value_id =
                                                       ppe.surrogate_key ) )
                      )
               )
           )
  UNION ALL
     SELECT  /*+ no_expand ORDERED INDEX(PPE PAY_PROCESS_EVENTS_N5) USE_NL(PDT) */
             peu.column_name       updated_column_name ,
             peu.event_type        event_type          ,
             peu.event_update_id   event_update_id     ,
             ppe.effective_date    effective_date      ,
             ppe.assignment_id     assignment_id       ,
             ppe.surrogate_key     surrogate_key       ,
             ppe.process_event_id  process_event_id,
             ppe.description       change_values,
             ppe.calculation_date  calculation_date,
             ppe.creation_date     creation_date,
             ppe.change_type       change_mode,
             pdt.table_name        table_name
     FROM
             pay_dated_tables    pdt ,
             pay_event_updates   peu ,
             pay_process_events  ppe
     WHERE
             peu.event_update_id      = ppe.event_update_id + 0
     AND     peu.dated_table_id       = pdt.dated_table_id
     AND     pdt.dated_table_id IN
               ( select distinct pde2.dated_table_id table_id
                        from   pay_datetracked_events pde2
                        where  pde2.event_group_id = p_event_group_id
                          and  cp_bulk_processing =  'N'
                 union all
                  select distinct pdt2.dated_table_id
                    from pay_dated_tables pdt2
                   where cp_bulk_processing =  'Y'
               )
     AND     ppe.assignment_id is null
     AND  ppe.business_group_id = p_business_group_id
     AND  (   peu.business_group_id = ppe.business_group_id
           or peu.legislation_code  = g_leg_code
           or (    peu.business_group_id is null
               and peu.legislation_code  is null) )
     AND   (ppe.retroactive_status = nvl(p_process, ppe.retroactive_status)
             or ppe.retroactive_status is null)
     AND   ppe.change_type = nvl(p_mode,ppe.change_type)
     AND   ppe.effective_date BETWEEN cp_estart_date AND cp_eend_date
     AND   (    (cp_bulk_processing = 'Y')
            or (    cp_bulk_processing = 'N'
                AND   ( (pdt.table_name <> 'PAY_ELEMENT_ENTRIES_F'   )
                         or
                        ( pdt.table_name = 'PAY_ELEMENT_ENTRIES_F'
                          and ppe.surrogate_key=p_element_entry_id )
                      )
                AND   ( ( pdt.table_name <> 'PAY_ELEMENT_ENTRY_VALUES_F'  )
                         or
                        ( pdt.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
                          and exists
                              ( select null
                                from pay_element_entry_values_f
                                where element_entry_id = p_element_entry_id
                                and   element_entry_value_id =
                                                       ppe.surrogate_key ) )
                      )
               )
           )
     AND pay_interpreter_pkg.valid_group_event_for_asg
                                  (pdt.table_name,
                                   p_assignment_id,
                                   ppe.surrogate_key) = 'Y'
     ORDER BY 11, 6, 5, 4;
     --ORDER BY pdt.table_name, ppe.surrogate_key, ppe.assignment_id, ppe.effective_date;

  -- The above cursor is modified for penserver extract
  CURSOR csr_all_process_events_eff_pen(
                  cp_bulk_processing   IN VARCHAR2,
                  cp_estart_date       IN DATE ,
                  cp_eend_date         IN DATE    )  IS

     SELECT
             peu.column_name       updated_column_name ,
             peu.event_type        event_type          ,
             peu.event_update_id   event_update_id     ,
             ppe.effective_date    effective_date      ,
             ppe.assignment_id     assignment_id       ,
             ppe.surrogate_key     surrogate_key       ,
             ppe.process_event_id  process_event_id,
             ppe.description       change_values,
             ppe.calculation_date  calculation_date,
             ppe.creation_date     creation_date,
             ppe.change_type       change_mode,
             pdt.table_name        table_name
     FROM
             pay_dated_tables    pdt ,
             pay_process_events  ppe ,
             pay_event_updates   peu
     WHERE
             peu.event_update_id      = ppe.event_update_id + 0
     AND     peu.dated_table_id       = pdt.dated_table_id
     AND     pdt.dated_table_id IN
               ( select distinct pde2.dated_table_id table_id
                        from   pay_datetracked_events pde2
                        where  pde2.event_group_id = p_event_group_id
                          and  cp_bulk_processing =  'N'
                 union all
                  select distinct pdt2.dated_table_id
                    from pay_dated_tables pdt2
                   where cp_bulk_processing =  'Y'
               )
     AND     ppe.assignment_id is not null
     AND     ppe.assignment_id = p_assignment_id
     AND  ppe.business_group_id = p_business_group_id
     AND  (   peu.business_group_id = ppe.business_group_id
           or peu.legislation_code  = g_leg_code
           or (    peu.business_group_id is null
               and peu.legislation_code  is null) )
     AND   (ppe.retroactive_status = nvl(p_process, ppe.retroactive_status)
             or ppe.retroactive_status is null)
     AND   ppe.change_type = nvl(p_mode,ppe.change_type)
     AND   ppe.effective_date BETWEEN cp_estart_date AND cp_eend_date
     AND   (    (cp_bulk_processing = 'Y')
            or (    cp_bulk_processing = 'N'
                AND   ( (pdt.table_name <> 'PAY_ELEMENT_ENTRIES_F'   )
                         or
                        ( pdt.table_name = 'PAY_ELEMENT_ENTRIES_F'
                          and ppe.surrogate_key=p_element_entry_id )
                      )
                AND   ( ( pdt.table_name <> 'PAY_ELEMENT_ENTRY_VALUES_F'  )
                         or
                        ( pdt.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
                          and exists
                              ( select null
                                from pay_element_entry_values_f
                                where element_entry_id = p_element_entry_id
                                and   element_entry_value_id =
                                                       ppe.surrogate_key ) )
                      )
               )
           )
     AND pay_interpreter_pkg.valid_group_event_for_asg
                                  (pdt.table_name,
                                   p_assignment_id,
                                   ppe.surrogate_key) = 'Y'
     ORDER BY 11, 6, 5, 4;
     --ORDER BY pdt.table_name, ppe.surrogate_key, ppe.assignment_id, ppe.effective_date;

  l_mst_pm  VARCHAR2(30);
  l_proc    VARCHAR2(80) := g_pkg||'.record_all_disco_events';


  --New holders
  l_date_counter NUMBER;

  l_bulk_processing varchar2(5);

  l_mst_pe_rec  t_mst_process_event_rec;

  --bug 7443747:Start
  -- New cursor for extracts that need to track just REPORTS type of events
  CURSOR csr_all_proces_eve_eff_pen_rep(
                  cp_bulk_processing   IN VARCHAR2,
                  cp_estart_date       IN DATE ,
                  cp_eend_date         IN DATE    )
  IS
     SELECT
             peu.column_name       updated_column_name ,
             peu.event_type        event_type          ,
             peu.event_update_id   event_update_id     ,
             ppe.effective_date    effective_date      ,
             ppe.assignment_id     assignment_id       ,
             ppe.surrogate_key     surrogate_key       ,
             ppe.process_event_id  process_event_id,
             ppe.description       change_values,
             ppe.calculation_date  calculation_date,
             ppe.creation_date     creation_date,
             ppe.change_type       change_mode,
             pdt.table_name        table_name
     FROM
             pay_dated_tables    pdt ,
             pay_process_events  ppe ,
             pay_event_updates   peu
     WHERE
             peu.event_update_id      = ppe.event_update_id + 0
     AND     peu.dated_table_id       = pdt.dated_table_id
     --Added new condition to capture REPORTS events only
     AND     ppe.change_type = 'REPORTS'
     AND     pdt.dated_table_id IN
               ( select distinct pde2.dated_table_id table_id
                        from   pay_datetracked_events pde2
                        where  pde2.event_group_id = p_event_group_id
                          and  cp_bulk_processing =  'N'
                 union all
                  select distinct pdt2.dated_table_id
                    from pay_dated_tables pdt2
                   where cp_bulk_processing =  'Y'
               )
     AND     ppe.assignment_id is not null
     AND     ppe.assignment_id = p_assignment_id
     AND  ppe.business_group_id = p_business_group_id
     AND  (   peu.business_group_id = ppe.business_group_id
           or peu.legislation_code  = g_leg_code
           or (    peu.business_group_id is null
               and peu.legislation_code  is null) )
     AND   (ppe.retroactive_status = nvl(p_process, ppe.retroactive_status)
             or ppe.retroactive_status is null)
     AND   ppe.change_type = nvl(p_mode,ppe.change_type)
     AND   ppe.effective_date BETWEEN cp_estart_date AND cp_eend_date
     AND   (    (cp_bulk_processing = 'Y')
            or (    cp_bulk_processing = 'N'
                AND   ( (pdt.table_name <> 'PAY_ELEMENT_ENTRIES_F'   )
                         or
                        ( pdt.table_name = 'PAY_ELEMENT_ENTRIES_F'
                          and ppe.surrogate_key=p_element_entry_id )
                      )
                AND   ( ( pdt.table_name <> 'PAY_ELEMENT_ENTRY_VALUES_F'  )
                         or
                        ( pdt.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
                          and exists
                              ( select null
                                from pay_element_entry_values_f
                                where element_entry_id = p_element_entry_id
                                and   element_entry_value_id =
                                                       ppe.surrogate_key ) )
                      )
               )
           )
     AND pay_interpreter_pkg.valid_group_event_for_asg
                                  (pdt.table_name,
                                   p_assignment_id,
                                   ppe.surrogate_key) = 'Y'
     --Modified order by to include actual date
     ORDER BY 11, 5, 4, 10 desc;


  CURSOR csr_get_pen_reports_exts(c_ext_dfn_id IN NUMBER)
  IS
    SELECT 'x'
    FROM BEN_EXT_DFN
    WHERE ext_dfn_id = c_ext_dfn_id
    AND name in ('PQP GB PenServer Periodic Changes Interface - Allowance History',
                'PQP GB PenServer Periodic Changes Interface - Bonus History')
    AND legislation_code ='GB';

  l_pen_ext_exists         VARCHAR2(5);
--bug 7443747:Stop

  -- -- BUG 7525608 :start For Penserver
  -- Cursor to fetch the last approved date for each extract

   CURSOR csr_pen_get_lapp_date
   IS
   SELECT least(trunc(run_strt_dt),eff_dt) app_date
     FROM ben_ext_rslt
    WHERE ext_dfn_id = ben_ext_thread.g_ext_dfn_id
      AND business_group_id = p_business_group_id
      AND ext_stat_cd = 'A'
    ORDER BY app_date DESC;

BEGIN
   hr_utility.set_location(l_proc, 10);
   l_date_counter := 1;

   -- As part of looking for a dbt_i and dbt_p we create a cache
   -- This is a new call to the Interpreter so we destroy this cache
   g_key_date_cache.delete;
   g_upd_cache.delete; --bug 3598389

   -- set up bus grp and leg code cache
   if (g_bus_grp_id is null or
       (g_bus_grp_id is not null and
        g_bus_grp_id <> p_business_group_id)) then
      select legislation_code
      into g_leg_code
      from per_business_groups_perf
      where business_group_id = p_business_group_id;
      --
      g_bus_grp_id := p_business_group_id;
   end if;

  l_bulk_processing := 'N';
  if(p_global_env.datetrack_ee_tab_use) then
     l_bulk_processing := 'Y';
  end if;

   -- >>> PHASE 1: Split copy of code in to two cursors based on
   -- master process mode to avoid performance issues.
   l_mst_pm := get_master_process_mode(p_process_mode);

   -- NB. More notes in get_master_process_mode, but summary
   --     CRE = tune for mode, creation date
   --     EFF = tune for process, mode and effective date
 if(g_traces) then
  hr_utility.trace('MASTER PROCESS MODE '||l_mst_pm);
  hr_utility.trace('p_penserv_mode '||p_penserv_mode);
 end if;
-- >>> PHASE 2: Get candidate rows from PPE
--
   IF (l_mst_pm = 'CRE') THEN
     hr_utility.set_location(l_proc,20);
--
     l_column_name.delete;
     l_event_type.delete;
     l_event_update_id.delete;
     l_effective_date.delete;
     l_assignment_id.delete;
     l_surrogate_key.delete;
     l_process_event_id.delete;
     l_description.delete;
     l_calculation_date.delete;
     l_creation_date.delete;
     l_change_type.delete;
     l_table_name.delete;
--
     open  csr_all_process_events_cre(
                       l_bulk_processing,
                       p_start_date ,
                       p_end_date
                       );
--
     fetch csr_all_process_events_cre bulk collect into
                 l_column_name,
                 l_event_type,
                 l_event_update_id,
                 l_effective_date,
                 l_assignment_id,
                 l_surrogate_key,
                 l_process_event_id,
                 l_description,
                 l_calculation_date,
                 l_creation_date,
                 l_change_type,
                 l_table_name;
--
     for i in 1..l_process_event_id.count loop
--
        l_mst_pe_rec.updated_column_name := l_column_name(i);
        l_mst_pe_rec.event_type          := l_event_type(i);
        l_mst_pe_rec.event_update_id     := l_event_update_id(i);
        l_mst_pe_rec.effective_date      := l_effective_date(i);
        l_mst_pe_rec.assignment_id       := l_assignment_id(i);
        l_mst_pe_rec.surrogate_key       := l_surrogate_key(i);
        l_mst_pe_rec.process_event_id    := l_process_event_id(i);
        l_mst_pe_rec.change_values       := l_description(i);
        l_mst_pe_rec.calculation_date    := l_calculation_date(i);
        l_mst_pe_rec.creation_date       := l_creation_date(i);
        l_mst_pe_rec.change_mode         := l_change_type(i);
        l_mst_pe_rec.table_name          := l_table_name(i);
--
         analyse_disco_process_events
         (
              p_element_entry_id     => p_element_entry_id,
              p_assignment_id        => p_assignment_id,
              p_assignment_action_id => p_assignment_action_id,
              p_business_group_id    => p_business_group_id,
              p_start_date           => p_start_date,
              p_end_date             => p_end_date,
              p_mode                 => p_mode,
              p_process              => p_process,
              p_process_mode         => p_process_mode,
              p_range_start          => p_global_env.monitor_start_ptr,
              p_range_end            => p_global_env.monitor_end_ptr,
              p_mst_pe_rec            => l_mst_pe_rec,
              p_event_group_id        => p_event_group_id,
              p_distinct_tab          => glo_monitored_events,
	      p_penserv_mode          => p_penserv_mode,
              p_date_counter          => l_date_counter,
              p_global_env            => p_global_env,
              t_dynamic_sql           => t_dynamic_sql,
              t_proration_dates_temp  => t_proration_dates_temp,
              t_proration_change_type => t_proration_change_type,
              t_proration_type        => t_proration_type,
              t_detailed_output       => t_detailed_output
         );

     end loop; --Get next process event to do comparisons on
     close csr_all_process_events_cre;


   ELSIF (l_mst_pm = 'EFF') THEN
--
     hr_utility.set_location(l_proc,320);
--
     l_column_name.delete;
     l_event_type.delete;
     l_event_update_id.delete;
     l_effective_date.delete;
     l_assignment_id.delete;
     l_surrogate_key.delete;
     l_process_event_id.delete;
     l_description.delete;
     l_calculation_date.delete;
     l_creation_date.delete;
     l_change_type.delete;
     l_table_name.delete;
--
     if (p_penserv_mode = 'N') then
     open  csr_all_process_events_eff(
                       l_bulk_processing,
                       p_start_date ,
                       p_end_date
                       );
--
     fetch csr_all_process_events_eff bulk collect into
                 l_column_name,
                 l_event_type,
                 l_event_update_id,
                 l_effective_date,
                 l_assignment_id,
                 l_surrogate_key,
                 l_process_event_id,
                 l_description,
                 l_calculation_date,
                 l_creation_date,
                 l_change_type,
                 l_table_name;
--
     else

    -- BUG 7525608 :start
    -- Fetch the actual p_start_date for each assignment instead of the
    -- start date passed by penserver program

     IF  g_pen_lapp_date is null
     THEN
        OPEN csr_pen_get_lapp_date;
        FETCH csr_pen_get_lapp_date INTO g_pen_lapp_date;
        CLOSE csr_pen_get_lapp_date;
	  hr_utility.trace('-------g_pen_lapp_date----------');
        hr_utility.trace('g_pen_lapp_date :'||g_pen_lapp_date);
     END IF;

     -- Get the Actual Start Date for Each assignment
     IF g_pen_lapp_date is not null
     THEN
        IF p_assignment_id <> g_pen_prev_ass_id
        THEN
           g_pen_from_date := get_penserver_date(p_assignment_id,p_business_group_id,g_pen_lapp_date,p_end_date); -- For bug 8359083
           g_pen_prev_ass_id := p_assignment_id;
           hr_utility.trace('-------p_assignment_id----------');
           hr_utility.trace('p_assignment_id :'||p_assignment_id);
        END IF;
     ELSE
        g_pen_from_date := p_start_date;
     END IF;
     hr_utility.trace('-------g_pen_prev_ass_id----------');
     hr_utility.trace('g_pen_prev_ass_id :'||g_pen_prev_ass_id);
     hr_utility.trace('g_pen_from_date :'||g_pen_from_date);

   -- BUG 7525608 :End

   --bug 7443747:Start
     hr_utility.trace('ben_ext_thread.g_ext_dfn_id '||ben_ext_thread.g_ext_dfn_id);
     hr_utility.trace('g_pen_collect_reports '||g_pen_collect_reports);

     IF g_pen_collect_reports is null
     THEN
          OPEN csr_get_pen_reports_exts(ben_ext_thread.g_ext_dfn_id);
          FETCH csr_get_pen_reports_exts INTO l_pen_ext_exists;

          IF csr_get_pen_reports_exts%found
          THEN
               g_pen_collect_reports := 'Y';
          ELSE
               g_pen_collect_reports := 'N';
          END IF;

          CLOSE csr_get_pen_reports_exts;

     END IF;

     IF g_pen_collect_reports = 'Y'
     THEN
          open  csr_all_proces_eve_eff_pen_rep(
                       l_bulk_processing,
                       g_pen_from_date ,  -- Replaced the date p_start_date for bug 7525608
                       p_end_date
                       );
--
          fetch csr_all_proces_eve_eff_pen_rep bulk collect into
                 l_column_name,
                 l_event_type,
                 l_event_update_id,
                 l_effective_date,
                 l_assignment_id,
                 l_surrogate_key,
                 l_process_event_id,
                 l_description,
                 l_calculation_date,
                 l_creation_date,
                 l_change_type,
                 l_table_name;

     ELSE
   --bug 7443747:Stop
     open  csr_all_process_events_eff_pen(
                       l_bulk_processing,
                       g_pen_from_date ,  -- Replaced the date p_start_date for bug 7525608
                       p_end_date
                       );
--
     fetch csr_all_process_events_eff_pen bulk collect into
                 l_column_name,
                 l_event_type,
                 l_event_update_id,
                 l_effective_date,
                 l_assignment_id,
                 l_surrogate_key,
                 l_process_event_id,
                 l_description,
                 l_calculation_date,
                 l_creation_date,
                 l_change_type,
                 l_table_name;

   --bug 7443747:Start
     END IF;
   --bug 7443747:Stop

     end if;

     for i in 1..l_process_event_id.count loop
--
        l_mst_pe_rec.updated_column_name := l_column_name(i);
        l_mst_pe_rec.event_type          := l_event_type(i);
        l_mst_pe_rec.event_update_id     := l_event_update_id(i);
        l_mst_pe_rec.effective_date      := l_effective_date(i);
        l_mst_pe_rec.assignment_id       := l_assignment_id(i);
        l_mst_pe_rec.surrogate_key       := l_surrogate_key(i);
        l_mst_pe_rec.process_event_id    := l_process_event_id(i);
        l_mst_pe_rec.change_values       := l_description(i);
        l_mst_pe_rec.calculation_date    := l_calculation_date(i);
        l_mst_pe_rec.creation_date       := l_creation_date(i);
        l_mst_pe_rec.change_mode         := l_change_type(i);
        l_mst_pe_rec.table_name          := l_table_name(i);
--

        IF (p_penserv_mode = 'N')
	  THEN

           analyse_disco_process_events
           (
             p_element_entry_id     => p_element_entry_id,
             p_assignment_id        => p_assignment_id,
             p_assignment_action_id => p_assignment_action_id,
             p_business_group_id    => p_business_group_id,
             p_start_date           => p_start_date,
             p_end_date             => p_end_date,
             p_mode                 => p_mode,
             p_process              => p_process,
             p_process_mode         => p_process_mode,
             p_range_start          => p_global_env.monitor_start_ptr,
             p_range_end            => p_global_env.monitor_end_ptr,
             p_mst_pe_rec            => l_mst_pe_rec,
             p_event_group_id        => p_event_group_id,
             p_distinct_tab          => glo_monitored_events,
             p_penserv_mode          => p_penserv_mode,
             p_date_counter          => l_date_counter,
             p_global_env            => p_global_env,
             t_dynamic_sql           => t_dynamic_sql,
             t_proration_dates_temp  => t_proration_dates_temp,
             t_proration_change_type => t_proration_change_type,
             t_proration_type        => t_proration_type,
             t_detailed_output       => t_detailed_output
           );

	  ELSE

	     analyse_disco_process_events
           (
             p_element_entry_id     => p_element_entry_id,
             p_assignment_id        => p_assignment_id,
             p_assignment_action_id => p_assignment_action_id,
             p_business_group_id    => p_business_group_id,
             p_start_date           => g_pen_from_date ,  -- Replaced the date p_start_date for bug 7525608
             p_end_date             => p_end_date,
             p_mode                 => p_mode,
             p_process              => p_process,
             p_process_mode         => p_process_mode,
             p_range_start          => p_global_env.monitor_start_ptr,
             p_range_end            => p_global_env.monitor_end_ptr,
             p_mst_pe_rec            => l_mst_pe_rec,
             p_event_group_id        => p_event_group_id,
             p_distinct_tab          => glo_monitored_events,
             p_penserv_mode          => p_penserv_mode,
             p_date_counter          => l_date_counter,
             p_global_env            => p_global_env,
             t_dynamic_sql           => t_dynamic_sql,
             t_proration_dates_temp  => t_proration_dates_temp,
             t_proration_change_type => t_proration_change_type,
             t_proration_type        => t_proration_type,
             t_detailed_output       => t_detailed_output
           );

	  END IF;

--
     end loop; --Get next process event to do comparisons on
     if (p_penserv_mode = 'N') then
          close csr_all_process_events_eff;
     else
        --bug 7443747:Start
         IF g_pen_collect_reports = 'Y'
         THEN
             close csr_all_proces_eve_eff_pen_rep;
         ELSE
       --bug 7443747:Stop
          close csr_all_process_events_eff_pen;
	--bug 7443747:Start
         END IF;
	--bug 7443747:Stop
     end if;

   END IF; --END MAIN IF CRE OR EFF


  hr_utility.set_location(l_proc, 900);
END record_all_disco_events;



--------------------------
--------------------------

/* ----------------------------------------------------------
  Main Entrance procedure, get info of datetracked event we're looking for
  then call procedure for this type
     I  - Ins event
     U  - Update event
     E  - End date event
     P  - Purge event
     C  - Correction event
     DF - Delete Future (Equals both Delete Next and Future Changes)
   ---------------------------------------------------------- */
PROCEDURE event_group_tables_affected
(
     p_element_entry_id       IN  NUMBER DEFAULT NULL,
     p_assignment_action_id   IN  NUMBER,
     p_event_group_id         IN  NUMBER,
     p_assignment_id          IN  NUMBER,
     p_business_group_id      IN  NUMBER,
     p_start_date             IN  DATE,
     p_end_date               IN  DATE,
     p_mode                   IN  VARCHAR2,
     p_process                IN  VARCHAR2,
     p_process_mode           IN  VARCHAR2,
     p_global_env             IN OUT NOCOPY t_global_env_rec,
     t_dynamic_sql            IN OUT NOCOPY t_dynamic_sql_tab,
     t_proration_dates_temp  IN OUT NOCOPY  t_proration_dates_table_type ,
     t_proration_change_type IN OUT NOCOPY  t_proration_type_table_type,
     t_proration_type        IN OUT NOCOPY  t_proration_type_table_type,
     t_detailed_output       IN OUT NOCOPY  t_detailed_output_table_type,
     p_penserv_mode          IN VARCHAR2 DEFAULT 'N'
) AS
--Misc helper/counters
    l_date_counter         NUMBER   ;
    l_range_start          NUMBER;
    l_range_end            NUMBER;
    l_dyt_type             VARCHAR2(15);  --Holds wot type of dyt table has

    l_proc VARCHAR2(80) := 'event_group_tables_affected';


BEGIN
   hr_utility.set_location(l_proc, 10);
   if (g_traces) then
   hr_utility.trace('Event group ID '||p_event_group_id||
      ' number of events in t_proration_group_tab: '||t_proration_group_tab.COUNT);
   end if;


  --For each Table that features in the clients event group we need
  --to gather all the potential events from ppe, then compare each potential
  --to the actual reqd events and add them to our store of Happened events
  --all this code is within record_disco_events

  -- EG
  -- PROCESS EVENTS
  --   pay_process_events are all events that have occurred
  -- DATETRACKED EVENTS
  --   All events the user has declared they are interested in,
  --   ie child of event group
  -- DISCO(vered) EVENTS
  --   Matched PROCESS EVENTS with DATETRACKED EVENTS, eg this list is
  --   the whole point of interpreter

     -- Call this for each table in event group
     record_all_disco_events
       (
        p_event_group_id        => p_event_group_id,

        p_element_entry_id    => p_element_entry_id,
        p_assignment_id       => p_assignment_id,
        p_assignment_action_id       => p_assignment_action_id,
        p_business_group_id   => p_business_group_id,
        p_start_date          => p_start_date,
        p_end_date            => p_end_date,
        p_process             => p_process,
        p_mode                => p_mode,
        p_process_mode        => p_process_mode,
        p_global_env          => p_global_env,
        t_dynamic_sql           => t_dynamic_sql,
        t_proration_dates_temp  => t_proration_dates_temp,
        t_proration_change_type => t_proration_change_type,
        t_proration_type        => t_proration_type,
        t_detailed_output       => t_detailed_output,
        p_penserv_mode          => p_penserv_mode
     );

   hr_utility.set_location(l_proc, 900);
END event_group_tables_affected;


PROCEDURE event_group_tables_affected
(
     p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
     p_assignment_action_id IN NUMBER,
     p_event_group_id         IN  NUMBER,
     p_assignment_id          IN  NUMBER,
     p_business_group_id      IN  NUMBER,
     p_start_date             IN  DATE,
     p_end_date               IN  DATE,
     p_mode                   IN  VARCHAR2,
     p_process                IN  VARCHAR2,
     p_process_mode           IN  VARCHAR2,
     t_dynamic_sql            IN OUT NOCOPY t_dynamic_sql_tab,
     t_proration_dates_temp  IN OUT NOCOPY  t_proration_dates_table_type ,
     t_proration_change_type IN OUT NOCOPY  t_proration_type_table_type,
     t_detailed_output       IN OUT NOCOPY  t_detailed_output_table_type,
     p_penserv_mode          IN VARCHAR2 DEFAULT 'N'
) is
     t_proration_type t_proration_type_table_type;
     l_global_env     t_global_env_rec;
begin
  initialise_global(l_global_env);
--
  glo_monitored_events  := t_distinct_tab;
  l_global_env.monitor_start_ptr :=
                   t_proration_group_tab(p_event_group_id).range_start;
  l_global_env.monitor_end_ptr   :=
                   t_proration_group_tab(p_event_group_id).range_end;
--

  event_group_tables_affected
  (
     p_element_entry_id     => p_element_entry_id,
     p_assignment_action_id => p_assignment_action_id,
     p_event_group_id       => p_event_group_id,
     p_assignment_id        => p_assignment_id,
     p_business_group_id    => p_business_group_id,
     p_start_date           => p_start_date,
     p_end_date             => p_end_date,
     p_mode                 => p_mode,
     p_process              => p_process,
     p_process_mode         => p_process_mode,
     p_global_env           => l_global_env,
     t_dynamic_sql          => t_dynamic_sql,
     t_proration_dates_temp => t_proration_dates_temp,
     t_proration_change_type => t_proration_change_type,
     t_proration_type        => t_proration_type,
     t_detailed_output       => t_detailed_output,
     p_penserv_mode          => p_penserv_mode
  );

end;

/*
    NAME
    validate_entry_parameters

    DESCRIPTION
     Validate all the parameters supplied to entry_affected
*/
procedure validate_entry_parameters (    p_assignment_action_id   IN             NUMBER,
               p_assignment_id          IN             NUMBER,
               p_mode                   IN             VARCHAR2,
               p_process                IN             VARCHAR2,
               p_event_group_id         IN             NUMBER,
               p_process_mode           IN             VARCHAR2,
               p_start_date             IN             DATE,
               p_end_date               IN             DATE,
               p_outprocess_mode            OUT NOCOPY VARCHAR2
                                   )
is
begin
--
   -- Ensure we have either an assignment or and action.
   pay_core_utils.assert_condition('pay_interpreter_pkg.validate_entry_parameters:1',
                                    (    p_assignment_action_id is not null
                                     or p_assignment_id is not null));
--
   -- Ensure the mode is correct
   pay_core_utils.assert_condition('pay_interpreter_pkg.validate_entry_parameters:2',
                                    (p_mode in ('COST_CENTRE',
                                                'DATE_EARNED',
                                                'DATE_PROCESSED',
                                                'PAYMENT',
                                                'REPORTS')
                                     or p_mode is null));
--
   -- Ensure the status is correct
   pay_core_utils.assert_condition('pay_interpreter_pkg.validate_entry_parameters:3',
                                    (p_process in ('U',
                                                'P',
                                                'C')
                                     or p_process is null));
--
   -- Ensure the processing mode is correct
   pay_core_utils.assert_condition('pay_interpreter_pkg.validate_entry_parameters:4',
                                    (p_process_mode in ('ENTRY_EFFECTIVE_DATE',
                                                'ENTRY_RETROSTATUS',
                                                'ENTRY_CREATION_DATE',
                                                'PRORATION')
                                     ));
--
   if (p_process_mode = 'PRORATION') then
--
     p_outprocess_mode := 'ENTRY_EFFECTIVE_DATE';
--
   else
--
     p_outprocess_mode := p_process_mode;
--
   end if;
--
end validate_entry_parameters;

--This is called directly by ADV_RETRONOT and CONT CALC
--also called by historic overloaded entry points
--This is an exact copy of the logic in the original entry_affected
--procedure, except having the three additional date parameters, thus existing code
--will just call the original which in turn calls this overloaded definition
PROCEDURE entry_affected
(
    p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
    p_assignment_action_id   IN  NUMBER DEFAULT NULL          ,
    p_assignment_id          IN  NUMBER DEFAULT NULL          ,
    p_mode                   IN  VARCHAR2 DEFAULT NULL        ,
    p_process                IN  VARCHAR2 DEFAULT NULL        ,
    p_event_group_id         IN  NUMBER DEFAULT NULL          ,
    p_process_mode           IN  VARCHAR2 DEFAULT 'ENTRY_EFFECTIVE_DATE' ,
    p_start_date             IN  DATE  DEFAULT hr_api.g_sot, --events created since this date
    p_end_date               IN  DATE  DEFAULT hr_api.g_eot,  --events created until this date
    p_process_date           IN  DATE  DEFAULT SYSDATE,  -- This date, drives for getting
                            -- a dflt event grop id if one is not passed
    p_unique_sort            IN  VARCHAR2, --default 'Y', --quicker if N
    p_business_group_id      IN  NUMBER, --default null,  in case someones wrapper needs it
    t_detailed_output       OUT NOCOPY  t_detailed_output_table_type ,
    t_proration_dates       OUT NOCOPY  t_proration_dates_table_type ,
    t_proration_change_type OUT NOCOPY  t_proration_type_table_type,
    t_proration_type        OUT NOCOPY  t_proration_type_table_type,
    p_penserv_mode          IN VARCHAR2 DEFAULT 'N'
) AS

    cursor csr_dflt_grps (cp_ee_id in number, cp_report_date in date ) IS
     select distinct(et.recalc_event_group_id) recalc_event_group_id
     from
      pay_element_entries_f ee
     ,pay_element_links_f   el
     ,pay_element_types_f   et
     where ee.element_entry_id = nvl(cp_ee_id,-1)
     and   ee.element_link_id = el.element_link_id
     and   el.element_type_id = et.element_type_id
     and   cp_report_date between et.effective_start_date
                          and et.effective_end_date;

--   Local variables declaration.

    l_assignment_id        per_all_assignments_f.assignment_id%TYPE  ;
    l_event_group_id   NUMBER                                  ;
    l_business_group_id    NUMBER                              ;
    l_start_date           DATE  := p_start_date               ;
    l_end_date             DATE  := p_end_date                 ;
    t_dynamic_sql          t_dynamic_sql_tab                   ;
    t_proration_dates_temp t_proration_dates_table_type        ;
    t_proration_change_type_temp t_proration_type_table_type;
    t_proration_type_temp        t_proration_type_table_type;
    l_internal_mode        varchar2(30);
    l_process_mode         varchar2(30);
    l_global_env           t_global_env_rec;

    l_proc VARCHAR2(80) := 'entry_affected';

BEGIN
  g_traces := hr_utility.debug_enabled ;

   if (g_traces) then
   hr_utility.trace('+------ ENTERED INTERPRETER ----+');
   hr_utility.trace('| Assignment Id      ' || p_assignment_id);
   hr_utility.trace('| Assignment Act Id  ' || p_assignment_action_id);
   hr_utility.trace('| Element Entry Id   ' || TO_CHAR(p_element_entry_id));
   hr_utility.trace('| Event Group Id     ' || p_event_group_id);
   end if;

   if (g_dbg) then
      hr_utility.trace('| P_mode             ' || p_mode);
      hr_utility.trace('| P_process          ' || p_process);
      hr_utility.trace('| P_process_mode     ' || p_process_mode);
      hr_utility.trace('+-------------------------------+ ');
   end if;
--
    -- were either passed in and ee_id,event_group_id ,assignment_id ,date, mode
    -- or a ee_id and assign_act_id.
    -- if its the second then we need to calc the assginemt_id, and time periods
    -- ENTRY_CREATION_DATE is a mode where dates are past in,
    -- Continuous Calculation is an example of this process mode
    validate_entry_parameters (p_assignment_action_id => p_assignment_action_id,
                               p_assignment_id        => p_assignment_id,
                               p_mode                 => p_mode,
                               p_process              => p_process,
                               p_event_group_id       => p_event_group_id,
                               p_process_mode         => p_process_mode,
                               p_start_date           => p_start_date,
                               p_end_date             => p_end_date,
                               p_outprocess_mode      => l_process_mode
                         );
--

-- Empty all results, this stops accidental
-- results in calling code and massive memory overheads
-- Please remember NOT to pass in partial tables of results
    t_dynamic_sql.delete;
    t_proration_dates_temp.delete;
    t_proration_change_type_temp.delete;
    t_proration_type_temp.delete;


    IF p_process_mode = 'PRORATION' THEN
      event_group_info(p_assignment_action_id,
                     p_element_entry_id,
                     l_event_group_id,
                     l_assignment_id,
                     l_business_group_id,
                     l_start_date,
                     l_end_date);
      l_internal_mode := 'PRORATION';
    ELSE

  -- if no business group id is passed then get from cache,
  -- if not in cache either then hit the db for it and store in cache
      if (p_business_group_id is null) then
        if (g_business_group_id is null) then
          --cache empty so get now
          select max(business_group_id)
          into l_business_group_id
          from per_all_assignments_f
          where assignment_id = p_assignment_id;

          -- There is one exceptional circumstance where bg_id is null
          -- specifically, a purge of an asg from per_all_assignments_f
          -- if we care that its been purged then weve caught the event so
          -- workaround is to get the bg from ppe
          --
          if ( l_business_group_id is null) then
            select max(business_group_id)
            into l_business_group_id
            from pay_process_events
            where assignment_id = p_assignment_id;
          end if;


          if (g_dbg) then
            hr_utility.trace('BG ID was null, now ' ||l_business_group_id);
          end if;

          -- set cache value
          g_business_group_id := l_business_group_id;
        else
         -- Use the cached value
          l_business_group_id := g_business_group_id;
        end if;
      else
         --use the parameter version and set global
         l_business_group_id := p_business_group_id;
         g_business_group_id := l_business_group_id;

      end if;

      l_assignment_id:=p_assignment_id;
      l_event_group_id:=p_event_group_id;
      l_internal_mode := 'RECALCULATION';
    END IF;

   hr_utility.set_location(l_proc, 20);
   --  If event group id has not been passed then check to see if there is
   --  a default event group for this element type
   --
   if (l_event_group_id is null) then
--
     -- If we are Prorating then there isn't a Proration group, hence
     -- just leave the procedure
     --
     if (l_internal_mode = 'PRORATION') then
--
        return;
--
     else
        for dflt_ev_grp in csr_dflt_grps(p_element_entry_id,p_process_date) loop
          --just one row, but fetch neatly
          l_event_group_id := dflt_ev_grp.recalc_event_group_id;
        end loop;
        if (g_traces) then
        hr_utility.trace(' Event Group ID from element type dflt: '||l_event_group_id);
        end if;

        -- if we still have no event group just bug out
        if (l_event_group_id is null) then
          if (g_traces) then
          hr_utility.trace('>>> No event group => return null from interpreter');
          end if;
          return;
        end if;
     end if;


   end if;

   event_group_tables(l_event_group_id);
--
    -- Setup the global structure
--
    initialise_global(l_global_env);
    glo_monitored_events  := t_distinct_tab;
    l_global_env.monitor_start_ptr :=
                     t_proration_group_tab(l_event_group_id).range_start;
    l_global_env.monitor_end_ptr   :=
                     t_proration_group_tab(l_event_group_id).range_end;
--
   hr_utility.set_location(l_proc, 30);

    event_group_tables_affected( p_element_entry_id,
                                p_assignment_action_id,
                                l_event_group_id,
                                l_assignment_id,
                                l_business_group_id,
                                l_start_date,
                                l_end_date,
                                p_mode,
                                p_process,
                                l_process_mode,
                                l_global_env,
                                t_dynamic_sql,
                                t_proration_dates_temp,
                                t_proration_change_type_temp,
                                t_proration_type_temp,
                                t_detailed_output,
				p_penserv_mode);

   hr_utility.set_location(l_proc, 40);

   --Only perform the sort if calling procedure has requested it
   --NB detailed output results table is never sorted
  if (p_unique_sort = 'Y') then
    -- This procedure sorts the dates and then generate the listing of unique dates.
    unique_sort(p_proration_dates_temp => t_proration_dates_temp ,
                p_proration_dates      => t_proration_dates      ,
                p_change_type_temp     => t_proration_change_type_temp,
                p_proration_type_temp  => t_proration_type_temp,
                p_change_type          => t_proration_change_type,
                p_proration_type       => t_proration_type,
                p_internal_mode        => l_internal_mode       );

  elsif (l_internal_mode = 'PRORATION') then
--
    t_proration_type := t_proration_type_temp;
    t_proration_dates := t_proration_dates_temp;
    t_proration_change_type := t_proration_change_type_temp;
--
  end if;

   hr_utility.set_location(l_proc, 900);
END entry_affected;

PROCEDURE get_subset_given_new_evg
(
    p_filter_event_group_id  IN  NUMBER ,
    p_complete_detail_tab    IN  t_detailed_output_table_type ,
    p_subset_detail_tab    IN OUT NOCOPY  t_detailed_output_table_type
) AS

CURSOR csr_reqd_events is
    SELECT DISTINCT pdt.dated_table_id     table_id          ,
                    pdt.table_name         table_name        ,
                    pde.column_name        column_name       ,
                    pde.update_type        update_type
    FROM   pay_datetracked_events pde,
           pay_dated_tables       pdt
    WHERE  pde.event_group_id = p_filter_event_group_id
    AND    pdt.dated_table_id = pde.dated_table_id
    order  by pdt.dated_table_id;


    l_proc VARCHAR2(80) := 'get_subset_given_new_evg';

    k number := 1;
BEGIN
  g_traces := hr_utility.debug_enabled ;

  if (g_traces) then
  hr_utility.set_location(l_proc,10);
  hr_utility.trace('| Filter full results using new Event Group Id: ' ||
                      p_filter_event_group_id);
  end if;

  -- For each given event, look for the event in our new event group
  -- Match the table, column and update type from the complete details tab

  -- Loop through the required events
  for reqd_event_rec in csr_reqd_events loop

    if (g_dbg) then
    hr_utility.trace('Looking for '||reqd_event_rec.update_type||' on '||
                      reqd_event_rec.table_name||'.'||reqd_event_rec.column_name);
    end if;

    -- Loop through all the full table events
    for j in 1..p_complete_detail_tab.count loop

      --First check type and table match
      if (reqd_event_rec.table_id = p_complete_detail_tab(j).dated_table_id
         and reqd_event_rec.update_type = p_complete_detail_tab(j).update_type)
      then

        -- Second, Check that if we care, the column is also the same
        if ( reqd_event_rec.update_type not in ('U','C') )
        then
          --dont care about col  - Found a match, add this event to results
          p_subset_detail_tab(k) := p_complete_detail_tab(j);
          k := k + 1;
        elsif
          (nvl(reqd_event_rec.column_name,'X') = nvl(p_complete_detail_tab(j).column_name,'X') )
        then
          --do   care about col  - Found a match, add this event to results
          p_subset_detail_tab(k) := p_complete_detail_tab(j);
          k := k + 1;
        end if;

      end if;

    end loop; --Get next event in full detail table

  end loop; --Get next reqd event from the filter event group

  if (g_traces) then
  hr_utility.trace('| p_complete_details_tab contained: '
                           ||p_complete_detail_tab.count() );
  hr_utility.trace('| p_subset_detail_tab contains:     '
                           ||p_subset_detail_tab.count() );
  hr_utility.set_location(l_proc,900);
  end if;
END get_subset_given_new_evg;


PROCEDURE entries_affected
(
    p_assignment_id          IN  NUMBER DEFAULT NULL          ,
    p_mode                   IN  VARCHAR2 DEFAULT NULL        ,
    p_start_date             IN  DATE  DEFAULT hr_api.g_sot,
    p_end_date               IN  DATE  DEFAULT hr_api.g_eot,
    p_business_group_id      IN  NUMBER,
    p_global_env             IN OUT NOCOPY t_global_env_rec,
    t_detailed_output       OUT NOCOPY  t_detailed_output_table_type,
    p_process_mode           IN VARCHAR2 DEFAULT 'ENTRY_CREATION_DATE',
    p_penserv_mode          IN VARCHAR2 DEFAULT 'N'
) AS

--   Local variables declaration.

    l_assignment_id        per_all_assignments_f.assignment_id%TYPE  ;
    l_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE  ;
    t_dynamic_sql          t_dynamic_sql_tab                   ;
    t_proration_dates_temp t_proration_dates_table_type        ;
    t_proration_change_type_temp t_proration_type_table_type;
    t_proration_type_temp        t_proration_type_table_type;
    l_internal_mode        varchar2(30);
    l_process_mode         varchar2(30);
    l_processout_mode         varchar2(30);

    l_proc VARCHAR2(80) := 'entries_affected';

BEGIN
  g_traces := hr_utility.debug_enabled ;

   if (g_traces) then
     hr_utility.trace('+------ ENTERED INTERPRETER ----+');
     hr_utility.trace('| Assignment Id      ' || p_assignment_id);
   end if;

   if (g_dbg) then
      hr_utility.trace('| P_mode             ' || p_mode);
      hr_utility.trace('+-------------------------------+ ');
   end if;
--
    -- Setup the global structure
--
    l_process_mode := p_process_mode;
--
    validate_entry_parameters (p_assignment_action_id => null,
                               p_assignment_id        => p_assignment_id,
                               p_mode                 => p_mode,
                               p_process              => null,
                               p_event_group_id       => null,
                               p_process_mode         => l_process_mode,
                               p_start_date           => p_start_date,
                               p_end_date             => p_end_date,
                               p_outprocess_mode      => l_processout_mode
                         );
--
-- For Penserver bug 7829985
   IF  p_penserv_mode = 'N'
   THEN

    select assignment_action_id
      into l_assignment_action_id
     from pay_assignment_actions
    where assignment_id = p_assignment_id
      and rownum = 1;

   END IF;
--


    -- Empty all results, this stops accidental
    -- results in calling code and massive memory overheads
    -- Please remember NOT to pass in partial tables of results
    t_dynamic_sql.delete;
    t_detailed_output.delete;
    t_proration_dates_temp.delete;
    t_proration_change_type_temp.delete;
    t_proration_type_temp.delete;


    l_assignment_id:=p_assignment_id;
    l_internal_mode := 'RECALCULATION';

    hr_utility.set_location(l_proc, 20);

    event_group_tables_affected( null,
                                l_assignment_action_id,
                                null,
                                l_assignment_id,
                                p_business_group_id,
                                p_start_date,
                                p_end_date,
                                p_mode,
                                null,
                                l_processout_mode,
                                p_global_env,
                                t_dynamic_sql,
                                t_proration_dates_temp,
                                t_proration_change_type_temp,
                                t_proration_type_temp,
                                t_detailed_output,
				p_penserv_mode);

   hr_utility.set_location(l_proc, 40);

   hr_utility.set_location(l_proc, 900);
END entries_affected;


begin
   g_valact_rec.assignment_id := '-1';
   g_grd_assignment_id := -1;
END PAY_INTERPRETER_PKG;

/
