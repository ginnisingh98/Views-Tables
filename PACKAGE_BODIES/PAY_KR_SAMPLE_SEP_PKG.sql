--------------------------------------------------------
--  DDL for Package Body PAY_KR_SAMPLE_SEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_SAMPLE_SEP_PKG" as
/*$Header: pykrsepl.pkb 115.8 2004/01/07 22:07:29 vborhade noship $ */

--
-- Global Variables.
--
g_debug                boolean  :=  hr_utility.debug_enabled;
g_business_group_id    number;
g_legislation_code     varchar2(2);
g_assignment_id        number;
g_balance_type_id      number;
g_assignment_action_id number;
type start_date_tbl is table of date index by binary_integer;
type end_date_tbl is table of date index by binary_integer;
type wkpd_tbl is table of varchar2(6) index by binary_integer;
type working_period_rec is record(
  start_date     start_date_tbl,
  end_date       end_date_tbl,
  wkpd           wkpd_tbl);
g_working_period working_period_rec;
--
type avg_val_rec is record(
  base_assignment_action_id number,
  base_action_sequence      number,
  base_start_date           date,
  base_end_date             date,
  assignment_id             number,
  effective_date            date,
  assignment_action_id      number,
  action_sequence           number,
  assignment_action_id1     number,
  avg_sal1                  number,
  avg_sal1_std              date,
  avg_sal1_edd              date,
  avg_sal1_wkd              number,
  assignment_action_id2     number,
  avg_sal2                  number,
  avg_sal2_std              date,
  avg_sal2_edd              date,
  avg_sal2_wkd              number,
  assignment_action_id3     number,
  avg_sal3                  number,
  avg_sal3_std              date,
  avg_sal3_edd              date,
  avg_sal3_wkd              number,
  assignment_action_id4     number,
  avg_sal4                  number,
  avg_sal4_std              date,
  avg_sal4_edd              date,
  avg_sal4_wkd              number,
  assignment_action_idb     number,
  action_sequenceb          number,
  avg_bon                   number,
  avg_bon_std               date,
  avg_bon_edd               date,
  assignment_action_ida     number,
  action_sequencea          number,
  avg_alr                   number,
  avg_alr_std               date,
  avg_alr_edd               date);
g_avg_val avg_val_rec;
--
type assignment_action_id_tbl is table of number index by binary_integer;
type action_sequence_tbl is table of number index by binary_integer;
type assignment_id_tbl is table of number index by binary_integer;
type effective_date_tbl is table of date index by binary_integer;
type base_assignment_action_id_tbl is table of number index by binary_integer;
type base_action_sequence_tbl is table of number index by binary_integer;
type base_start_date_tbl is table of date index by binary_integer;
type base_end_date_tbl is table of date index by binary_integer;
type target_start_date_tbl is table of date index by binary_integer;
type target_end_date_tbl is table of date index by binary_integer;
type past_action_rec is record(
  assignment_action_id      assignment_action_id_tbl,
  action_sequence           action_sequence_tbl,
  assignment_id             assignment_id_tbl,
  effective_date            effective_date_tbl,
  base_assignment_action_id base_assignment_action_id_tbl,
  base_action_sequence      base_action_sequence_tbl,
  base_start_date           base_start_date_tbl,
  base_end_date             base_end_date_tbl,
  target_start_date         target_start_date_tbl,
  target_end_date           target_end_date_tbl);
g_mth_past_action past_action_rec;
g_bon_past_action past_action_rec;
g_alr_past_action past_action_rec;
--
g_avg_yearly_divide_num number;
g_avg_mth_divide_num number;
--
-- Constant on each business group level
-- (if these are defined on each business place level,
--  Org information or Payroll information may be proper storage.)
--
c_mode            varchar2(5) := 'MONTH'; /* MONTH, DAY */
c_wp_for_sep_unit varchar2(5) := 'MONTH'; /* YEAR, MONTH, DAY */
c_dly_yy_unit     number := 365;
c_dly_mm_unit     number := 30;
--
--------------------------------------------------------------------------------
function get_wkpd(p_start_date  in date,
                  p_end_date    in date) return varchar2
--------------------------------------------------------------------------------
is
--
  l_yy number;
  l_mm number;
  l_mb number;
  l_dd number;
  l_wp varchar2(6);
--
begin
--
  if c_mode = 'MONTH' then
    l_mb := months_between(p_end_date , p_start_date );
/*    l_mm := to_number(to_char(p_end_date,'MM')) + 12 - to_number(to_char(p_start_date,'MM'));*/
    if l_mb -12 >= 0 then
      l_yy := to_number(to_char(p_end_date,'YYYY')) - to_number(to_char(p_start_date,'YYYY'));
      l_mm := l_mb - 12;
    else
      l_yy := to_number(to_char(p_end_date,'YYYY')) - to_number(to_char(p_start_date,'YYYY')) - 1;
      --l_mm := l_mm;
    end if;
    /* 2000/11/14,2001/01/12       */
    /* --------------------------- */
    /* l_mm = 01 + 12 - 11 = 02    */
    /* l_mm - 12 < 0               */
    /* l_yy = 2001 - 2000 - 1 = 00 */
    /* yymm = 0002                 */
    l_wp := lpad(to_char(l_yy),2,'0')||lpad(to_char(l_mm),2,'0');
  else
    l_dd := (trunc(p_end_date,'DD') - add_months(trunc(p_end_date,'MM'),-1) + 1) - to_number(to_char(p_start_date,'DD'));
    if l_dd - c_dly_mm_unit >= 0 then
      l_dd := l_dd - c_dly_mm_unit;
      l_mm := to_number(to_char(p_end_date,'MM')) + 12 - to_number(to_char(p_start_date,'MM'));
      if l_mm - 12 >= 0 then
        l_yy := to_number(to_char(p_end_date,'YYYY')) - to_number(to_char(p_start_date,'YYYY'));
        l_mm := l_mm - 12;
      else
        l_yy := to_number(to_char(p_end_date,'YYYY')) - to_number(to_char(p_start_date,'YYYY')) - 1;
        --l_mm := l_mm;
      end if;
    else
      --l_dd := l_dd;
      l_mm := (to_number(to_char(p_end_date,'MM')) -1) + 12 - to_number(to_char(p_start_date,'MM'));
      if l_mm -12 >= 0 then
        l_yy := to_number(to_char(p_end_date,'YYYY')) - to_number(to_char(p_start_date,'YYYY'));
        l_mm := l_mm - 12;
      else
        l_yy := to_number(to_char(p_end_date,'YYYY')) - to_number(to_char(p_start_date,'YYYY')) - 1;
        --l_mm := l_mm;
      end if;
    end if;
    /* 2000/11/14,2001/01/12                                    */
    /* -------------------------------------------------------- */
    /* l_dd = (2001/01/12 - 2000/12/01 + 1) - 14 = 43 - 14 = 29 */
    /* c_dly_mm_unit = 30                                       */
    /* l_dd - 30 < 0                                            */
    /* l_dd = 29                                                */
    /* l_mm = 01 - 1 + 12 - 11 = 1                              */
    /* l_mm - 12 < 0                                            */
    /* l_yy = 2001 - 2000 - 1 = 00                              */
    /* l_mm = 1                                                 */
    /* yymmdd = 000129                                          */
    l_wp := lpad(to_char(l_yy),2,'0')||lpad(to_char(l_mm),2,'0')||lpad(to_char(l_dd),2,'0');
  end if;
return	l_wp;
end get_wkpd;
--------------------------------------------------------------------------------
function get_wkpd_exclude(p_assignment_id in number,
                          p_start_date    in date,
                          p_end_date      in date,
                          p_exclude_flag  in varchar2) return varchar2
--------------------------------------------------------------------------------
is
  cursor csr_exclude_period
  is
  select greatest(pa.effective_start_date,p_start_date)	effective_start_date,
         least(pa.effective_end_date,p_end_date)        effective_end_date
  from   per_assignment_status_types	past,
         per_assignments_f		pa
  where  pa.assignment_id = p_assignment_id
  and    pa.effective_end_date >= p_start_date
  and    pa.effective_start_date <= p_end_date
  and    past.assignment_status_type_id = pa.assignment_status_type_id
  -- This enhancement was denied by core team.
  --and  past.past_information_context = 'KR'
  --and  past.past_information1 <> 'Y'
  --and  past.pay_system_status <> 'P'
  and    past.per_system_status <> 'ACTIVE_ASSIGN';
--
  l_csr_exclude_period csr_exclude_period%rowtype;
--
  type exclude_wp_tbl is table of varchar2(6) index by binary_integer;
--
  exclude_wp     exclude_wp_tbl;
  sum_exclude_yy number := 0;
  sum_exclude_mm number := 0;
  sum_exclude_dd number := 0;
  wp_yy          number;
  wp_mm          number;
  wp_dd          number;
  l_wp           varchar2(6);
--
  l_exc_cnt      number := 0;
  l_index binary_integer;
  l_found boolean := FALSE;
--
begin
--
  if g_assignment_id is null or p_assignment_id <> g_assignment_id then
    g_working_period.start_date.delete;
    g_working_period.end_date.delete;
    g_working_period.wkpd.delete;
    g_assignment_id := p_assignment_id;
  end if;
--
  l_index := g_working_period.start_date.count;
  for i in 1..l_index loop
    if g_working_period.start_date(i) = p_start_date
       and g_working_period.end_date(i) = p_end_date then
      l_wp := g_working_period.wkpd(i);
      l_found := TRUE;
      exit;
    end if;
  end loop;
--
  if not l_found then
    if p_exclude_flag = 'Y' then
      open csr_exclude_period;
      loop
      fetch csr_exclude_period into l_csr_exclude_period;
      exit when csr_exclude_period%notfound;
      exclude_wp(l_exc_cnt) := get_wkpd(p_start_date  => l_csr_exclude_period.effective_start_date,
                                        p_end_date    => l_csr_exclude_period.effective_end_date);
      if l_exc_cnt > 0 then
        sum_exclude_yy := to_number(substrb(exclude_wp(l_exc_cnt -1),1,2)) + to_number(substrb(exclude_wp(l_exc_cnt),1,2));
        sum_exclude_mm := to_number(substrb(exclude_wp(l_exc_cnt -1),3,4)) + to_number(substrb(exclude_wp(l_exc_cnt),3,4));
        if c_mode = 'MONTH' then
          if sum_exclude_mm >= 12 then
            sum_exclude_yy := sum_exclude_yy + 1;
            sum_exclude_mm := sum_exclude_mm - 12;
          end if;
        else
          if sum_exclude_dd >= c_dly_mm_unit then
            sum_exclude_mm := sum_exclude_mm + 1;
            sum_exclude_dd := sum_exclude_dd - c_dly_mm_unit;
          end if;
          if sum_exclude_mm >= 12 then
            sum_exclude_yy := sum_exclude_yy + 1;
            sum_exclude_mm := sum_exclude_mm - 12;
          end if;
        end if;
      end if;
      l_exc_cnt := l_exc_cnt + 1;
      end loop;
      close csr_exclude_period;
      l_wp := get_wkpd(p_start_date  => p_start_date,
                       p_end_date    => p_end_date);
      if c_mode = 'MONTH' then
        wp_mm := to_number(substrb(l_wp,3,4)) + 12 - sum_exclude_mm;
        wp_yy := to_number(substrb(l_wp,1,2)) - sum_exclude_yy;
        if wp_mm - 12 >= 0 then
          wp_mm := wp_mm - 12;
          --wp_yy := wp_yy;
        else
          --wp_mm := wp_mm;
          wp_yy := wp_yy -1;
        end if;
      else
        wp_dd := to_number(substrb(l_wp,5,6)) + c_dly_mm_unit - sum_exclude_dd;
        wp_mm := to_number(substrb(l_wp,3,4));
        if wp_dd - c_dly_mm_unit >= 0 then
          wp_dd := wp_dd - c_dly_mm_unit;
          --wp_mm := wp_mm;
        else
          wp_dd := wp_dd;
          --wp_mm := wp_mm - 1;
        end if;
        wp_mm := wp_mm + 12 - sum_exclude_mm;
        wp_yy := to_number(substrb(l_wp,1,2)) - sum_exclude_yy;
        if wp_mm - 12 >= 0 then
          wp_mm := wp_mm - 12;
          --wp_yy := wp_yy;
        else
          --wp_mm := wp_mm;
          wp_yy := wp_yy -1;
        end if;
      end if;
      l_wp := lpad(to_char(wp_yy),2,'0')||lpad(to_char(wp_mm),2,'0')||lpad(to_char(wp_dd),2,'0');
    else
      l_wp := get_wkpd(p_start_date  => p_start_date,
                       p_end_date    => p_end_date);
    end if;
    g_working_period.start_date(l_index + 1) := p_start_date;
    g_working_period.end_date(l_index + 1) := p_end_date;
    g_working_period.wkpd(l_index + 1) := l_wp;
  end if;
--
return  l_wp;
end  get_wkpd_exclude;
--------------------------------------------------------------------------------
function get_wkpd_for_calc(p_assignment_id  in number,
                           p_working_period in varchar2,
                           p_wp_format_flag in varchar2, /* Y(YYMMDD), N(XXX) */
                           p_type           in varchar2) /* EARNING, TAX */ return number
--------------------------------------------------------------------------------
is
  l_wp_yy                 number;
  l_wp_mm                 number;
  l_wp_dd                 number;
  l_target                number;
--
begin
--
  if g_avg_mth_divide_num is null
     or g_avg_yearly_divide_num is null then
    if c_mode = 'MONTH' then
      g_avg_mth_divide_num := 3;
      g_avg_yearly_divide_num := 12;
    elsif c_mode = 'DAY' then
      g_avg_mth_divide_num := c_dly_mm_unit;
      g_avg_yearly_divide_num := c_dly_yy_unit;
    end if;
  end if;
--
  if p_type = 'EARNING' then
  /* l_target unit is year */
    /* calculation for YYMMDD format */
    if p_wp_format_flag = 'Y' then
      --
      l_wp_yy := to_number(substrb(p_working_period,1,2));
      l_wp_mm := to_number(substrb(p_working_period,3,4));
      --
      if c_wp_for_sep_unit = 'YEAR' then
        l_target := l_wp_yy + round(l_wp_mm/12,0);
      elsif c_wp_for_sep_unit = 'MONTH' then
        l_target := (l_wp_yy * 12 + l_wp_mm)/12;
      else
        l_wp_dd := to_number(substrb(p_working_period,5,6));
        l_target := (l_wp_yy * c_dly_yy_unit + l_wp_mm * c_dly_mm_unit + l_wp_dd)/c_dly_yy_unit;
      end if;
    /* calculation for XXXX format */
    else
      if c_wp_for_sep_unit = 'YEAR' then
        l_target := to_number(p_working_period);
      elsif c_wp_for_sep_unit = 'MONTH' then
        l_target := to_number(p_working_period)/12;
      else
        l_target := to_number(p_working_period)/c_dly_yy_unit;
      end if;
    end if;
  elsif p_type = 'TAX' then
  /* l_target unit is month */
    /* calculation for YYMMDD format */
    if p_wp_format_flag = 'Y' then
      --
      l_wp_yy := to_number(substrb(p_working_period,1,2));
      l_wp_mm := to_number(substrb(p_working_period,3,4));
      --
      l_target := l_wp_yy * 12 + l_wp_mm;
      if c_mode = 'DAY' then
        l_wp_dd := to_number(substrb(p_working_period,5,6));
        if l_wp_dd - 15 > 0 then
          l_target := l_target + 1;
        --else
        --  l_target := l_target;
        end if;
      end if;
    /* calculation for XXXX format */
    else
      if c_wp_for_sep_unit = 'YEAR' then
        l_target := to_number(p_working_period) * 12;
        if l_target - trunc(l_target,0) > 0 then
          l_target := l_target + 1;
        --else
        --  l_target := l_target;
        end if;
      elsif c_wp_for_sep_unit = 'MONTH' then
        l_target := to_number(p_working_period);
        if l_target - trunc(l_target,0) > 0 then
          l_target := l_target + 1;
        --else
        --  l_target := l_target;
        end if;
      else
        if c_mode = 'DAY' then
          l_target := to_number(p_working_period)/c_dly_mm_unit;
          if l_target - trunc(l_target,0) > 0 then
            l_target := l_target + 1;
          --else
          --  l_target := l_target;
          end if;
        end if;
      end if;
    end if;
  end if;
--
return	l_target;
end get_wkpd_for_calc;
--------------------------------------------------------------------------------
function get_avg_sal(p_assignment_id        in number,
                     p_type                 in varchar2, /* MTH,BON,ALR */
                     p_effective_date       in date,
                     p_base_action_sequence in number,
                     p_action_sequence4     in number,
                     p_target_start_date    in date,
                     p_target_end_date      in date,
                     p_balance_type_id      in number) return number
--------------------------------------------------------------------------------
is
--
	l_target_value	number;
--
	cursor	csr_value
	is
	select
		nvl(sum(fnd_number.canonical_to_number(prrv.result_value) * pbf.scale),0)
	from	pay_balance_feeds_f		pbf,
		pay_run_result_values		prrv,
		pay_run_results			prr,
		(select /*+ INDEX(ppa PAY_PAYROLL_ACTIONS_N5)  */
                        paa.assignment_action_id	assignment_action_id,
			ppa.effective_date		effective_date
		from
	--		per_time_periods		ptp,
			per_assignment_status_types	past,
			per_assignments_f		pa,
			pay_payroll_actions		ppa,
			pay_run_types_f			prt,
			pay_assignment_actions		paa
		where	paa.assignment_id = p_assignment_id
		and	paa.action_status = 'C'
		and	prt.run_type_id = paa.run_type_id
		and	p_effective_date
			between prt.effective_start_date and prt.effective_end_date
		and	prt.run_type_name like decode(p_type,
						'BON','BON%',
						'ALR','BON_ALR',
						'MTH')
		and	not exists(
				select	null
				from	pay_run_types_f	prt2
				where	prt2.run_type_id = prt.run_type_id
				and	prt2.effective_start_date = prt.effective_start_date
				and	prt2.effective_end_date = prt.effective_end_date
				and	prt2.run_type_name = decode(p_type,
									'BON','BON_ALR',
									'XXX'))
		and	paa.action_sequence >= decode(p_type,
						'MTH',p_action_sequence4,
						'BON',paa.action_sequence)
		and	paa.action_sequence < p_base_action_sequence
		and	ppa.payroll_action_id = paa.payroll_action_id
		and	ppa.effective_date
			between p_target_start_date and p_target_end_date
		and	pa.assignment_id = paa.assignment_id
		and	ppa.effective_date
			between pa.effective_start_date and pa.effective_end_date
		and	past.assignment_status_type_id = pa.assignment_status_type_id
		/* Denied this enhancement by Core Team */
	--	and	past.past_information_context = 'KR'
	--	and	past.past_information1 = 'Y'
	--	and	past.pay_system_status = 'P'
		and	past.per_system_status = 'ACTIVE_ASSIGN')	V1
	--	and	ptp.time_period_id = ppa.time_period_id)	V1
	where	prr.assignment_action_id = V1.assignment_action_id
	and	prr.status in ('P','PA')
	and	prrv.run_result_id = prr.run_result_id
	and	nvl(prrv.result_value,'0') <> '0'
	and	pbf.balance_type_id = p_balance_type_id
	and	pbf.input_value_id = prrv.input_value_id
	and	V1.effective_date
		between pbf.effective_start_date and pbf.effective_end_date;
--
begin
--
  open  csr_value;
  fetch csr_value into l_target_value;
  close csr_value;

  if g_debug then
    hr_utility.trace('p_base_action_sequence ' || p_base_action_sequence);
    hr_utility.trace('p_target_start_date  ' || p_target_start_date);
    hr_utility.trace('p_target_end_date  ' || p_target_end_date);
    hr_utility.trace('p_action_sequence4 ' || p_action_sequence4);
    hr_utility.trace('p_type ' || p_type);
    hr_utility.trace('l_targe_value ' || l_target_value);
  end if;
--
return l_target_value;
end get_avg_sal;
--------------------------------------------------------------------------------
function get_avg_val(p_business_group_id     in number,
                     p_assignment_action_id  in number,
                     p_performance_flag      in varchar2,
                     p_assignment_action_id1 out nocopy number,
                     p_avg_sal1              out nocopy number,
                     p_avg_sal1_std          out nocopy date,
                     p_avg_sal1_edd          out nocopy date,
                     p_avg_sal1_wkd          out nocopy number,
                     p_assignment_action_id2 out nocopy number,
                     p_avg_sal2              out nocopy number,
                     p_avg_sal2_std          out nocopy date,
                     p_avg_sal2_edd          out nocopy date,
                     p_avg_sal2_wkd          out nocopy number,
                     p_assignment_action_id3 out nocopy number,
                     p_avg_sal3              out nocopy number,
                     p_avg_sal3_std          out nocopy date,
                     p_avg_sal3_edd          out nocopy date,
                     p_avg_sal3_wkd          out nocopy number,
                     p_assignment_action_id4 out nocopy number,
                     p_avg_sal4              out nocopy number,
                     p_avg_sal4_std          out nocopy date,
                     p_avg_sal4_edd          out nocopy date,
                     p_avg_sal4_wkd          out nocopy number,
                     p_assignment_action_idb out nocopy number,
                     p_avg_bon               out nocopy number,
                     p_assignment_action_ida out nocopy number,
                     p_avg_alr               out nocopy number) return number
--------------------------------------------------------------------------------
is
  l_type			varchar2(3);
  l_end_date			date;
  l_row_cnt			number;
  l_prev_action_cnt		number := 4;
  l_rate			number := 1;
  l_found                       boolean := FALSE;
  l_dummy			number := 0;
  l_mth_index			binary_integer;
  l_bon_index			binary_integer;
  l_alr_index			binary_integer;
--
	cursor	csr_balance_type_id
	is
	select	balance_type_id
	from	pay_balance_types
	where	legislation_code = g_legislation_code
	and	balance_name = 'EARNINGS_SUBJ_AVG';
--
	cursor	csr_past_action
	is
	select	paa.assignment_action_id	assignment_action_id,
		paa.action_sequence		action_sequence,
		bpaa.assignment_id		assignment_id,
		bppa.effective_date		effective_date,
		bpaa.assignment_action_id	base_assignment_action_id,
		bpaa.action_sequence		base_action_sequence,
	 	to_date('01/04/2002','DD/MM/YYYY') base_start_date,
		to_date('30/04/2002','DD/MM/YYYY') base_end_date,
		ptp.start_date			target_start_date,
		ptp.end_date			target_end_date
	from	per_time_periods		ptp,
		per_assignment_status_types	past,
		per_assignments_f		pa,
		pay_payroll_actions		ppa,
		pay_run_types_f			prt,
		pay_assignment_actions		paa,
--		per_time_periods		bptp,
		pay_payroll_actions		bppa,
		pay_assignment_actions		bpaa
	where	bpaa.assignment_action_id = p_assignment_action_id
	and	bppa.payroll_action_id = bpaa.payroll_action_id
--	and	bptp.time_period_id = bppa.time_period_id
	and	paa.assignment_id = bpaa.assignment_id
	and	paa.action_status = 'C'
	and	prt.run_type_id = paa.run_type_id
	and	prt.run_type_name like decode(l_type,
						'BON','BON%',
						'ALR','BON_ALR',
						'MTH')
	and	not exists(
			select	null
			from	pay_run_types_f	prt2
			where	prt2.run_type_id = prt.run_type_id
			and	prt2.effective_start_date = prt.effective_start_date
			and	prt2.effective_end_date = prt.effective_end_date
			and	prt2.run_type_name = decode(l_type,
								'BON','BON_ALR',
								'XXX'))
	and	bppa.effective_date
		between prt.effective_start_date and prt.effective_end_date
	and	paa.action_sequence < bpaa.action_sequence
	and	ppa.payroll_action_id = paa.payroll_action_id
--	and	ppa.effective_date <= bptp.end_date
	and	ppa.effective_date >= decode(l_type,
					'MTH',decode(p_performance_flag,
							'N',ppa.effective_date,
							add_months(bppa.effective_date -1,-12)),
					'BON',add_months(bppa.effective_date -1,-12),
					'ALR',add_months(bppa.effective_date -1,-12))
	and	ppa.action_type <> 'V'
	and	not exists(
			select	null
			from	pay_payroll_actions	rppa,
				pay_assignment_actions	rpaa,
				pay_action_interlocks	pai
			where	pai.locked_action_id = paa.assignment_action_id
			and	rpaa.assignment_action_id = pai.locking_action_id
			and	rppa.payroll_action_id = rpaa.payroll_action_id
			and	rppa.action_type = 'V')
	and	pa.assignment_id = paa.assignment_id
	and	ppa.effective_date
		between pa.effective_start_date and pa.effective_end_date
	and	past.assignment_status_type_id = pa.assignment_status_type_id
	/* Denied this enhancement by Core Team */
--	and	past.past_information_context = 'KR'
--	and	past.past_information1 = 'Y'
--	and	past.pay_system_status = 'P'
	and	past.per_system_status = 'ACTIVE_ASSIGN'
	and	ptp.time_period_id = ppa.time_period_id
	order by paa.action_sequence desc;
--
begin
--
-- Initialize
--
--  p_assignment_action_id1 := -1;
--  p_avg_sal1              := 0;
--  p_avg_sal1_std          := hr_api.g_sot;
--  p_avg_sal1_edd          := hr_api.g_sot;
--  p_avg_sal1_wkd          := 0;
--  p_assignment_action_id2 := -1;
--  p_avg_sal2              := 0;
--  p_avg_sal2_std          := hr_api.g_sot;
--  p_avg_sal2_edd          := hr_api.g_sot;
--  p_avg_sal2_wkd          := 0;
--  p_assignment_action_id3 := -1;
--  p_avg_sal3              := 0;
--  p_avg_sal3_std          := hr_api.g_sot;
--  p_avg_sal3_edd          := hr_api.g_sot;
--  p_avg_sal3_wkd          := 0;
--  p_assignment_action_id4 := -1;
--  p_avg_sal4              := 0;
--  p_avg_sal4_std          := hr_api.g_sot;
--  p_avg_sal4_edd          := hr_api.g_sot;
--  p_avg_sal4_wkd          := 0;
--  p_assignment_action_idb := -1;
--  p_avg_bon               := 0;
--  p_assignment_action_ida := -1;
--  p_avg_alr               := 0;
--
  if g_business_group_id is null or g_business_group_id <> p_business_group_id then
    g_legislation_code := pay_kr_report_pkg.legislation_code(p_business_group_id);
    g_business_group_id := p_business_group_id;
    --
    open  csr_balance_type_id;
    fetch csr_balance_type_id into g_balance_type_id;
    close csr_balance_type_id;
    --
  end if;
--

  if g_debug then
    hr_utility.trace('g_balance_type_id' || g_balance_type_id);
    hr_utility.trace('p_business_group_id' || p_business_group_id);
    hr_utility.trace('p_performance_flag ' || p_performance_flag);
    hr_utility.trace('p_assignment_action_id ' || p_assignment_action_id);
    hr_utility.trace('g_avg_val.base_assignment_action_id' || g_avg_val.base_assignment_action_id);
  end if;

  if g_avg_val.base_assignment_action_id is null or g_avg_val.base_assignment_action_id <> p_assignment_action_id then
    g_avg_val.base_assignment_action_id := p_assignment_action_id;
    g_avg_val.base_action_sequence  := -1;
    g_avg_val.base_start_date       := hr_api.g_sot;
    g_avg_val.base_end_date         := hr_api.g_sot;
    g_avg_val.assignment_id         := -1;
    g_avg_val.effective_date        := hr_api.g_sot;
    g_avg_val.assignment_action_id  := -1;
    g_avg_val.action_sequence       := -1;
    g_avg_val.assignment_action_id1 := -1;
    g_avg_val.avg_sal1              := 0;
    g_avg_val.avg_sal1_std          := hr_api.g_sot;
    g_avg_val.avg_sal1_edd          := hr_api.g_sot;
    g_avg_val.avg_sal1_wkd          := 0;
    g_avg_val.assignment_action_id2 := -1;
    g_avg_val.avg_sal2              := 0;
    g_avg_val.avg_sal2_std          := hr_api.g_sot;
    g_avg_val.avg_sal2_edd          := hr_api.g_sot;
    g_avg_val.avg_sal2_wkd          := 0;
    g_avg_val.assignment_action_id3 := -1;
    g_avg_val.avg_sal3              := 0;
    g_avg_val.avg_sal3_std          := hr_api.g_sot;
    g_avg_val.avg_sal3_edd          := hr_api.g_sot;
    g_avg_val.avg_sal3_wkd          := 0;
    g_avg_val.assignment_action_id4 := -1;
    g_avg_val.avg_sal4              := 0;
    g_avg_val.avg_sal4_std          := hr_api.g_sot;
    g_avg_val.avg_sal4_edd          := hr_api.g_sot;
    g_avg_val.avg_sal4_wkd          := 0;
    g_avg_val.assignment_action_idb := -1;
    g_avg_val.action_sequenceb      := -1;
    g_avg_val.avg_bon               := 0;
    g_avg_val.avg_bon_std           := hr_api.g_sot;
    g_avg_val.avg_bon_edd           := hr_api.g_sot;
    g_avg_val.assignment_action_ida := -1;
    g_avg_val.action_sequencea      := -1;
    g_avg_val.avg_alr               := 0;
    g_avg_val.avg_alr_std           := hr_api.g_sot;
    g_avg_val.avg_alr_edd           := hr_api.g_sot;
  --
    g_mth_past_action.assignment_action_id.delete;
    g_mth_past_action.action_sequence.delete;
    g_mth_past_action.assignment_id.delete;
    g_mth_past_action.effective_date.delete;
    g_mth_past_action.base_assignment_action_id.delete;
    g_mth_past_action.base_action_sequence.delete;
    g_mth_past_action.base_start_date.delete;
    g_mth_past_action.base_end_date.delete;
    g_mth_past_action.target_start_date.delete;
    g_mth_past_action.target_end_date.delete;
  --
    g_bon_past_action.assignment_action_id.delete;
    g_bon_past_action.action_sequence.delete;
    g_bon_past_action.assignment_id.delete;
    g_bon_past_action.effective_date.delete;
    g_bon_past_action.base_assignment_action_id.delete;
    g_bon_past_action.base_action_sequence.delete;
    g_bon_past_action.base_start_date.delete;
    g_bon_past_action.base_end_date.delete;
    g_bon_past_action.target_start_date.delete;
    g_bon_past_action.target_end_date.delete;
  --
    g_alr_past_action.assignment_action_id.delete;
    g_alr_past_action.action_sequence.delete;
    g_alr_past_action.assignment_id.delete;
    g_alr_past_action.effective_date.delete;
    g_alr_past_action.base_assignment_action_id.delete;
    g_alr_past_action.base_action_sequence.delete;
    g_alr_past_action.base_start_date.delete;
    g_alr_past_action.base_end_date.delete;
    g_alr_past_action.target_start_date.delete;
    g_alr_past_action.target_end_date.delete;
  --
  else
    l_found := TRUE;
  end if;
--
  if not l_found then
    l_type := 'MTH';
    l_end_date := hr_api.g_eot;
    l_row_cnt := 0;
  --
    if g_debug then
      hr_utility.trace('l_end_date' || l_end_date);
    end if;

    l_mth_index := g_mth_past_action.assignment_action_id.count;

    if g_debug then
      hr_utility.trace('l_mth_index ' || l_mth_index);
    end if;

    for i in 1..l_mth_index loop
      if g_mth_past_action.target_end_date(i) <> l_end_date then
         l_end_date := g_mth_past_action.target_end_date(i);
         l_row_cnt := l_row_cnt + 1;
         if l_row_cnt > l_prev_action_cnt then
           exit;
         end if;
         l_found := TRUE;
      end if;
      g_avg_val.assignment_action_id := g_mth_past_action.assignment_action_id(i);
      g_avg_val.action_sequence := g_mth_past_action.action_sequence(i);
      if l_row_cnt = 1 then
        g_avg_val.assignment_action_id1     := g_mth_past_action.assignment_action_id(i);
        g_avg_val.assignment_id             := g_mth_past_action.assignment_id(i);
        g_avg_val.effective_date            := g_mth_past_action.effective_date(i);
        g_avg_val.base_assignment_action_id := g_mth_past_action.base_assignment_action_id(i);
        g_avg_val.base_action_sequence      := g_mth_past_action.base_action_sequence(i);
        g_avg_val.base_start_date           := g_mth_past_action.base_start_date(i);
        g_avg_val.base_end_date             := g_mth_past_action.base_end_date(i);
        g_avg_val.avg_sal1_std              := g_mth_past_action.target_start_date(i);
        g_avg_val.avg_sal1_edd              := g_mth_past_action.target_end_date(i);
        g_avg_val.avg_sal1_wkd              := g_avg_val.avg_sal1_edd - g_avg_val.avg_sal1_std + 1;
      elsif l_row_cnt = 2 then
        g_avg_val.assignment_action_id2     := g_mth_past_action.assignment_action_id(i);
        g_avg_val.avg_sal2_std              := g_mth_past_action.target_start_date(i);
        g_avg_val.avg_sal2_edd              := g_mth_past_action.target_end_date(i);
        g_avg_val.avg_sal2_wkd              := g_avg_val.avg_sal2_edd - g_avg_val.avg_sal2_std + 1;
      elsif l_row_cnt = 3 then
        g_avg_val.assignment_action_id3     := g_mth_past_action.assignment_action_id(i);
        g_avg_val.avg_sal3_std              := g_mth_past_action.target_start_date(i);
        g_avg_val.avg_sal3_edd              := g_mth_past_action.target_end_date(i);
        g_avg_val.avg_sal3_wkd              := g_avg_val.avg_sal3_edd - g_avg_val.avg_sal3_std + 1;
      elsif l_row_cnt = 4 then
        g_avg_val.assignment_action_id4     := g_mth_past_action.assignment_action_id(i);
        g_avg_val.avg_sal4_std              := g_mth_past_action.target_start_date(i);
        g_avg_val.avg_sal4_edd              := g_mth_past_action.target_end_date(i);
        g_avg_val.avg_sal4_wkd              := g_avg_val.avg_sal4_edd - g_avg_val.avg_sal4_std + 1;
      end if;
    end loop;
  --
    l_end_date := hr_api.g_eot;
    l_row_cnt := 0;
  --
    if not l_found then
      open  csr_past_action;
      fetch csr_past_action bulk collect into g_mth_past_action.assignment_action_id,
                                              g_mth_past_action.action_sequence,
                                              g_mth_past_action.assignment_id,
                                              g_mth_past_action.effective_date,
                                              g_mth_past_action.base_assignment_action_id,
                                              g_mth_past_action.base_action_sequence,
                                              g_mth_past_action.base_start_date,
                                              g_mth_past_action.base_end_date,
                                              g_mth_past_action.target_start_date,
                                              g_mth_past_action.target_end_date;
      close csr_past_action;
      for i in 1..g_mth_past_action.assignment_action_id.count loop
        if g_mth_past_action.target_end_date(i) <> l_end_date then
           l_end_date := g_mth_past_action.target_end_date(i);
           l_row_cnt := l_row_cnt + 1;
           if l_row_cnt > l_prev_action_cnt then
             exit;
           end if;
           l_found := TRUE;
        end if;
        g_avg_val.assignment_action_id := g_mth_past_action.assignment_action_id(i);
        g_avg_val.action_sequence := g_mth_past_action.action_sequence(i);
        if l_row_cnt = 1 then
          g_avg_val.assignment_action_id1     := g_mth_past_action.assignment_action_id(i);
          g_avg_val.assignment_id             := g_mth_past_action.assignment_id(i);
          g_avg_val.effective_date            := g_mth_past_action.effective_date(i);
          g_avg_val.base_assignment_action_id := g_mth_past_action.base_assignment_action_id(i);
          g_avg_val.base_action_sequence      := g_mth_past_action.base_action_sequence(i);
          g_avg_val.base_start_date           := g_mth_past_action.base_start_date(i);
          g_avg_val.base_end_date             := g_mth_past_action.base_end_date(i);
          g_avg_val.avg_sal1_std              := g_mth_past_action.target_start_date(i);
          g_avg_val.avg_sal1_edd              := g_mth_past_action.target_end_date(i);
          g_avg_val.avg_sal1_wkd              := g_avg_val.avg_sal1_edd - g_avg_val.avg_sal1_std + 1;
        elsif l_row_cnt = 2 then
          g_avg_val.assignment_action_id2     := g_mth_past_action.assignment_action_id(i);
          g_avg_val.avg_sal2_std              := g_mth_past_action.target_start_date(i);
          g_avg_val.avg_sal2_edd              := g_mth_past_action.target_end_date(i);
          g_avg_val.avg_sal2_wkd              := g_avg_val.avg_sal2_edd - g_avg_val.avg_sal2_std + 1;
        elsif l_row_cnt = 3 then
          g_avg_val.assignment_action_id3     := g_mth_past_action.assignment_action_id(i);
          g_avg_val.avg_sal3_std              := g_mth_past_action.target_start_date(i);
          g_avg_val.avg_sal3_edd              := g_mth_past_action.target_end_date(i);
          g_avg_val.avg_sal3_wkd              := g_avg_val.avg_sal3_edd - g_avg_val.avg_sal3_std + 1;
        elsif l_row_cnt = 4 then
          g_avg_val.assignment_action_id4     := g_mth_past_action.assignment_action_id(i);
          g_avg_val.avg_sal4_std              := g_mth_past_action.target_start_date(i);
          g_avg_val.avg_sal4_edd              := g_mth_past_action.target_end_date(i);
          g_avg_val.avg_sal4_wkd              := g_avg_val.avg_sal4_edd - g_avg_val.avg_sal4_std + 1;
        end if;
      end loop;
    end if;
  --
    g_avg_val.avg_sal1 := get_avg_sal(
  				p_assignment_id		=> g_avg_val.assignment_id,
  				p_type			=> l_type,
  				p_effective_date	=> g_avg_val.effective_date,
  				p_action_sequence4	=> g_avg_val.action_sequence,
  				p_base_action_sequence	=> g_avg_val.base_action_sequence,
  				p_target_start_date	=> g_avg_val.avg_sal1_std,
  				p_target_end_date	=> g_avg_val.avg_sal1_edd,
  				p_balance_type_id	=> g_balance_type_id);
  --
    g_avg_val.avg_sal2 := get_avg_sal(
  				p_assignment_id		=> g_avg_val.assignment_id,
  				p_type			=> l_type,
  				p_effective_date	=> g_avg_val.effective_date,
  				p_action_sequence4	=> g_avg_val.action_sequence,
  				p_base_action_sequence	=> g_avg_val.base_action_sequence,
  				p_target_start_date	=> g_avg_val.avg_sal2_std,
  				p_target_end_date	=> g_avg_val.avg_sal2_edd,
  				p_balance_type_id	=> g_balance_type_id);
  --
    g_avg_val.avg_sal3 := get_avg_sal(
  				p_assignment_id		=> g_avg_val.assignment_id,
  				p_type			=> l_type,
  				p_effective_date	=> g_avg_val.effective_date,
  				p_action_sequence4	=> g_avg_val.action_sequence,
  				p_base_action_sequence	=> g_avg_val.base_action_sequence,
  				p_target_start_date	=> g_avg_val.avg_sal3_std,
  				p_target_end_date	=> g_avg_val.avg_sal3_edd,
  				p_balance_type_id	=> g_balance_type_id);
  --
    if c_mode = 'DAY' then
      g_avg_val.avg_sal4 := get_avg_sal(
  				p_assignment_id		=> g_avg_val.assignment_id,
  				p_type			=> l_type,
  				p_effective_date	=> g_avg_val.effective_date,
  				p_action_sequence4	=> g_avg_val.action_sequence,
  				p_base_action_sequence	=> g_avg_val.base_action_sequence,
  				p_target_start_date	=> g_avg_val.avg_sal4_std,
  				p_target_end_date	=> g_avg_val.avg_sal4_edd,
  				p_balance_type_id	=> g_balance_type_id);
      if l_rate is null then
        /* 4th period is same to the period from effective date to 1st Period end date. */
        l_rate := round((g_avg_val.avg_sal1_edd - g_avg_val.effective_date + 1) / (g_avg_val.avg_sal1_edd - g_avg_val.avg_sal1_std),2);
      end if;
      g_avg_val.avg_sal4 := g_avg_val.avg_sal4 * l_rate;
    end if;
  --
    l_type := 'BON';
    l_end_date := hr_api.g_eot;
    l_row_cnt := 0;
    l_found := FALSE;
  --
    l_bon_index := g_bon_past_action.assignment_action_id.count;
    for i in 1..l_bon_index loop
      g_avg_val.assignment_action_idb := g_bon_past_action.assignment_action_id(i);
      g_avg_val.action_sequenceb := g_bon_past_action.action_sequence(i);
  --    g_avg_val.assignment_id := g_bon_past_action.assignment_id(i);
  --    g_avg_val.effective_date := g_bon_past_action.effective_date(i);
  --    g_avg_val.base_assignment_action_id := g_bon_past_action.base_assignment_action_id(i);
  --    g_avg_val.base_action_sequence := g_bon_past_action.base_action_sequence(i);
  --    g_avg_val.base_start_date := g_bon_past_action.base_start_date(i);
  --    g_avg_val.base_end_date := g_bon_past_action.base_end_date(i);
      g_avg_val.avg_bon_std := g_bon_past_action.target_start_date(i);
      g_avg_val.avg_bon_edd := g_avg_val.effective_date;
      l_found := TRUE;
    end loop;

    if not l_found then
      open  csr_past_action;
      fetch csr_past_action bulk collect into g_bon_past_action.assignment_action_id,
                                              g_bon_past_action.action_sequence,
                                              g_bon_past_action.assignment_id,
                                              g_bon_past_action.effective_date,
                                              g_bon_past_action.base_assignment_action_id,
                                              g_bon_past_action.base_action_sequence,
                                              g_bon_past_action.base_start_date,
                                              g_bon_past_action.base_end_date,
                                              g_bon_past_action.target_start_date,
                                              g_bon_past_action.target_end_date;
      close csr_past_action;
      for i in 1..g_bon_past_action.assignment_action_id.count loop
        g_avg_val.assignment_action_idb := g_bon_past_action.assignment_action_id(i);
        g_avg_val.action_sequenceb := g_bon_past_action.action_sequence(i);
  --      g_avg_val.assignment_id := g_bon_past_action.assignment_id(i);
  --      g_avg_val.effective_date := g_bon_past_action.effective_date(i);
  --      g_avg_val.base_assignment_action_id := g_bon_past_action.base_assignment_action_id(i);
  --      g_avg_val.base_action_sequence := g_bon_past_action.base_action_sequence(i);
  --      g_avg_val.base_start_date := g_bon_past_action.base_start_date(i);
  --      g_avg_val.base_end_date := g_bon_past_action.base_end_date(i);
        g_avg_val.avg_bon_std := g_bon_past_action.target_start_date(i);
        g_avg_val.avg_bon_edd := g_avg_val.effective_date;
        l_found := TRUE;
      end loop;
    end if;
    --
    g_avg_val.avg_bon := get_avg_sal(
  				p_assignment_id		=> g_avg_val.assignment_id,
  				p_type			=> l_type,
  				p_effective_date	=> g_avg_val.effective_date,
  				p_action_sequence4	=> g_avg_val.action_sequenceb,
  				p_base_action_sequence	=> g_avg_val.base_action_sequence,
  				p_target_start_date	=> g_avg_val.avg_bon_std,
  				p_target_end_date	=> g_avg_val.avg_bon_edd,
  				p_balance_type_id	=> g_balance_type_id);
  --
    l_type := 'ALR';
    l_end_date := hr_api.g_eot;
    l_row_cnt := 0;
    l_found := FALSE;
  --
    l_alr_index := g_alr_past_action.assignment_action_id.count;
    for i in 1..l_alr_index loop
      g_avg_val.assignment_action_ida := g_alr_past_action.assignment_action_id(i);
      g_avg_val.action_sequencea := g_alr_past_action.action_sequence(i);
  --    g_avg_val.assignment_id := g_alr_past_action.assignment_id(i);
  --    g_avg_val.effective_date := g_alr_past_action.effective_date(i);
  --    g_avg_val.base_assignment_action_id := g_alr_past_action.base_assignment_action_id(i);
  --    g_avg_val.base_action_sequence := g_alr_past_action.base_action_sequence(i);
  --    g_avg_val.base_start_date := g_alr_past_action.base_start_date(i);
  --    g_avg_val.base_end_date := g_alr_past_action.base_end_date(i);
      g_avg_val.avg_alr_std := g_alr_past_action.target_start_date(i);
      g_avg_val.avg_alr_edd := g_avg_val.effective_date;
      l_found := TRUE;
    end loop;

    if not l_found then
      open  csr_past_action;
      fetch csr_past_action bulk collect into g_alr_past_action.assignment_action_id,
                                              g_alr_past_action.action_sequence,
                                              g_alr_past_action.assignment_id,
                                              g_alr_past_action.effective_date,
                                              g_alr_past_action.base_assignment_action_id,
                                              g_alr_past_action.base_action_sequence,
                                              g_alr_past_action.base_start_date,
                                              g_alr_past_action.base_end_date,
                                              g_alr_past_action.target_start_date,
                                              g_alr_past_action.target_end_date;
      close csr_past_action;
      for i in 1..g_alr_past_action.assignment_action_id.count loop
        g_avg_val.assignment_action_ida := g_alr_past_action.assignment_action_id(i);
        g_avg_val.action_sequencea := g_alr_past_action.action_sequence(i);
  --      g_avg_val.assignment_id := g_alr_past_action.assignment_id(i);
  --      g_avg_val.effective_date := g_alr_past_action.effective_date(i);
  --      g_avg_val.base_assignment_action_id := g_alr_past_action.base_assignment_action_id(i);
  --      g_avg_val.base_action_sequence := g_alr_past_action.base_action_sequence(i);
  --      g_avg_val.base_start_date := g_alr_past_action.base_start_date(i);
  --      g_avg_val.base_end_date := g_alr_past_action.base_end_date(i);
        g_avg_val.avg_alr_std := g_alr_past_action.target_start_date(i);
        g_avg_val.avg_alr_edd := g_avg_val.effective_date;
        l_found := TRUE;
      end loop;
    end if;
    --
    g_avg_val.avg_alr := get_avg_sal(
  				p_assignment_id		=> g_avg_val.assignment_id,
  				p_type			=> l_type,
  				p_effective_date	=> g_avg_val.effective_date,
  				p_action_sequence4	=> g_avg_val.action_sequencea,
  				p_base_action_sequence	=> g_avg_val.base_action_sequence,
  				p_target_start_date	=> g_avg_val.avg_alr_std,
  				p_target_end_date	=> g_avg_val.avg_alr_edd,
  				p_balance_type_id	=> g_balance_type_id);
  --
  end if;
  --
  p_assignment_action_id1 := g_avg_val.assignment_action_id1;
  p_avg_sal1              := g_avg_val.avg_sal1;
  p_avg_sal1_std          := g_avg_val.avg_sal1_std;
  p_avg_sal1_edd          := g_avg_val.avg_sal1_edd;
  p_avg_sal1_wkd          := g_avg_val.avg_sal1_wkd;
  p_assignment_action_id2 := g_avg_val.assignment_action_id2;
  p_avg_sal2              := g_avg_val.avg_sal2;
  p_avg_sal2_std          := g_avg_val.avg_sal2_std;
  p_avg_sal2_edd          := g_avg_val.avg_sal2_edd;
  p_avg_sal2_wkd          := g_avg_val.avg_sal2_wkd;
  p_assignment_action_id3 := g_avg_val.assignment_action_id3;
  p_avg_sal3              := g_avg_val.avg_sal3;
  p_avg_sal3_std          := g_avg_val.avg_sal3_std;
  p_avg_sal3_edd          := g_avg_val.avg_sal3_edd;
  p_avg_sal3_wkd          := g_avg_val.avg_sal3_wkd;
  p_assignment_action_id4 := g_avg_val.assignment_action_id4;
  p_avg_sal4              := g_avg_val.avg_sal4;
  p_avg_sal4_std          := g_avg_val.avg_sal4_std;
  p_avg_sal4_edd          := g_avg_val.avg_sal4_edd;
  p_avg_sal4_wkd          := g_avg_val.avg_sal4_wkd;
  p_assignment_action_idb := g_avg_val.assignment_action_idb;
  p_avg_bon               := g_avg_val.avg_bon;
  p_assignment_action_ida := g_avg_val.assignment_action_ida;
  p_avg_alr               := g_avg_val.avg_alr;
  --
return	l_dummy;
end get_avg_val;
end pay_kr_sample_sep_pkg;

/
