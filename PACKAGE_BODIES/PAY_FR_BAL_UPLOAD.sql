--------------------------------------------------------
--  DDL for Package Body PAY_FR_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_BAL_UPLOAD" as
/* $Header: pyfrupld.pkb 120.0 2005/05/29 05:12:46 appldev noship $ */
--
--
g_sot date := hr_api.g_sot;
g_eot date := hr_api.g_eot;
g_iv_limit constant number := 15;
g_classification_name constant varchar2(30) := 'Balance Initialization';
g_element_name_prefix constant varchar2(30) := 'Initial_Value_';
g_alphabet            constant varchar2(26) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
g_package             constant varchar2(30) := 'pay_fr_bal_upload.';
-----------------------------------------------------------------------------
--
-- NAME
--  expiry_date
-- PURPOSE
--  Returns the expiry date of a given dimension relative to a date.
-- ARGUMENTS
--  p_upload_date       - the date on which the balance should be correct.
--  p_dimension_name    - the dimension being set (in caps).
--  p_assignment_id     - the assignment involved.
--  p_original_entry_id - ORIGINAL_ENTRY_ID context.
-- USES
-- NOTES
--  This is used by pay_balance_upload.dim_expiry_date.
--  If the expiry date cannot be derived then it is set to the end of time
--  to indicate that a failure has occured. The process that uses the
--  expiry date knows this rule and acts accordingly.
-----------------------------------------------------------------------------
function expiry_date
(
   p_upload_date       date,
   p_dimension_name    varchar2,
   p_assignment_id     number,
   p_original_entry_id number
) return date is
  --
  cursor csr_asg_itd_start is
  -- Returns the Earliest date that can be used for uploading
  -- for the assignment, therefore ensures that a time period
  -- exists, and uses the greatest of the assignment start and
  -- time period start. Used for ITD date, and as a minimum
  -- for other dimensions.
  select nvl(greatest(min(ASS.effective_start_date),
                        min(PTP.start_date)), g_eot)
      from per_assignments_f ASS
          ,per_time_periods  PTP
     where ASS.assignment_id = p_assignment_id
       and ASS.effective_start_date <= p_upload_date
       and PTP.start_date <= p_upload_date
       and PTP.payroll_id   = ASS.payroll_id
       and ASS.establishment_id is not null;
  --
  cursor csr_ele_itd_start is
  -- Returns the earliest date on which the element entry exists.
  --
  select nvl(min(EE.effective_start_date), g_eot)
    from pay_element_entries_f EE
   where EE.assignment_id         = p_assignment_id
     and (EE.element_entry_id     = p_original_entry_id or
          EE.original_entry_id    = p_original_entry_id)
     and EE.effective_start_date  <= p_upload_date;
  --
  cursor csr_period_start is
  -- Returns the start date of the current period on the upload date.
  select nvl(PTP.start_date, g_eot)
    from   per_time_periods  PTP
          ,per_assignments_f ASS
   where  ASS.assignment_id = p_assignment_id
     and  p_upload_date       between ASS.effective_start_date
                                  and ASS.effective_end_date
     and  PTP.payroll_id    = ASS.payroll_id
     and  p_upload_date       between PTP.start_date
                                  and PTP.end_date;
  --
  l_asg_itd_start_date    date; -- The assignment start date.
  l_ele_itd_start_date    date; -- The earliest date an element entry exists.
  l_period_start_date     date; -- start date of the upload date period.
  l_expiry_date           date;
begin
  open  csr_asg_itd_start;
  fetch csr_asg_itd_start into l_asg_itd_start_date;
  close csr_asg_itd_start;
  if p_dimension_name = 'FR ELEMENT-LEVEL ELE_ITD' then
    open  csr_ele_itd_start;
    fetch csr_ele_itd_start into l_ele_itd_start_date;
    close csr_ele_itd_start;
    l_expiry_date := greatest(l_ele_itd_start_date,l_asg_itd_start_date);
  elsif p_dimension_name = 'ASSIGNMENT PRORATION RUN TO DATE' then
    if p_upload_date >= l_asg_itd_start_date then
      l_expiry_date := p_upload_date;
    else
      l_expiry_date := g_eot;
    end if;
  elsif p_dimension_name = 'ASSIGNMENT PERIOD TO DATE' then
    open  csr_period_start;
    fetch csr_period_start into l_period_start_date;
    close csr_period_start;
    l_expiry_date := greatest(l_period_start_date,l_asg_itd_start_date);
  elsif p_dimension_name in ('ASSIGNMENT ESTABLISHMENT YEAR TO DATE',
                             'ASSIGNMENT YEAR TO DATE') then
    l_expiry_date := greatest(trunc(p_upload_date,'Y'),
                              l_asg_itd_start_date);
  elsif p_dimension_name = 'FR ASSIGNMENT-LEVEL ASG_ITD' then
    l_expiry_date := l_asg_itd_start_date;
  else
    l_expiry_date := g_eot;
  end if;
  return l_expiry_date;
exception
  when others then
    return g_eot;
end expiry_date;

-----------------------------------------------------------------------------
-- NAME
--  is_supported
-- PURPOSE
--  Checks if the dimension is supported by the upload process.
-- ARGUMENTS
--  p_dimension_name - the balance dimension to be checked (in caps).
-- USES
-- NOTES
--  This is used by pay_balance_upload.validate_dimension.
--  Only a subset of the FR dimensions are supported.
--  A return of zero denotes that the dimension is not supported.
-----------------------------------------------------------------------------
function is_supported(p_dimension_name varchar2) return number is
begin
  if p_dimension_name in ('FR ELEMENT-LEVEL ELE_ITD',
                          'ASSIGNMENT PRORATION RUN TO DATE',
                          'ASSIGNMENT PERIOD TO DATE',
                          'ASSIGNMENT ESTABLISHMENT YEAR TO DATE',
                          'ASSIGNMENT YEAR TO DATE',
                          'FR ASSIGNMENT-LEVEL ASG_ITD')
  then
    return 1;
  else
    return 0;
  end if;
end is_supported;


-----------------------------------------------------------------------------
-- NAME
--  validate_batch_lines
-- PURPOSE
--  Applies FR specific validation to the batch.
-- ARGUMENTS
--  p_batch_id - the batch to be validate_batch_linesd.
-- USES
-- NOTES
--  This is used by pay_balance_upload.validate_batch_lines.
-----------------------------------------------------------------------------
procedure validate_batch_lines(p_batch_id number)
is
  type t_message_line is record (
    batch_line_id  pay_balance_batch_lines.batch_line_id%TYPE,
    message_number binary_integer);
  type t_message_lines is table of t_message_line index by binary_integer;
  type t_messages      is table of pay_message_lines.line_text%TYPE
                                   index by binary_integer;
  tbl_messages  t_messages;
  tbl_msg_lines t_message_lines;
  --
  --cursor csr_batch_header_details(p_batch_id number)  is
  --select upload_date
  --from   pay_balance_batch_headers
  --where  batch_id = p_batch_id;
  --
  cursor csr_batch_line_validate(p_batch_id number)  is
  select *
  from   pay_balance_batch_lines BL
  where  BL.batch_id          = p_batch_id
    and  BL.batch_line_status in ('V','E')
  for    update;
  --
  l_proc constant varchar2(61) := g_package||'validate_batch_lines';
  l_next_msg_line binary_integer := 1;
  l_line_in_error boolean;
  --l_batch csr_batch_header_details%ROWTYPE;
  --
  procedure write_message_line(p_batch_line_id number
                              ,p_message_name  varchar2
                              ,p_message_num   binary_integer) is
  begin
    if not tbl_messages.exists(p_message_num) then
      hr_utility.set_message(801, p_message_name);
      tbl_messages(p_message_num) := substrb(hr_utility.get_message, 1, 240);
    end if;
    tbl_msg_lines(l_next_msg_line).batch_line_id  := p_batch_line_id;
    tbl_msg_lines(l_next_msg_line).message_number := p_message_num;
    l_next_msg_line := l_next_msg_line + 1;
  end write_message_line;
  --
  procedure write_message_lines is
  begin
    for i in 1..l_next_msg_line-1 loop
      insert into pay_message_lines
      (line_sequence
      ,message_level
      ,source_id
      ,source_type
      ,line_text)
      values
      (pay_message_lines_s.nextval
      ,'F' -- 'F'atal
      ,tbl_msg_lines(i).batch_line_id
      ,'L'
      ,tbl_messages(tbl_msg_lines(i).message_number));
    end loop;
  end write_message_lines;
  --
  procedure error_message_line(p_batch_line_id number) is
  begin
    update pay_balance_batch_lines
    set    batch_line_status = 'E'
    where  batch_id          = p_batch_id
    and    batch_line_id     = p_batch_line_id;
  end error_message_line;
  --
begin -- validate_batch_lines
  hr_utility.set_location('Entering: '|| l_proc, 10);
  --open  csr_batch_header_details(p_batch_id);
  --fetch csr_batch_header_details into l_batch;
  --close csr_batch_header_details;
  --
  for batch_line in csr_batch_line_validate(p_batch_id) loop
    l_line_in_error := false;
    if batch_line.dimension_name in ('ASSIGNMENT PERIOD TO DATE',
                                     'ASSIGNMENT PRORATION RUN TO DATE')
    and batch_line.upload_date is null
    then
      l_line_in_error := true;
      write_message_line(batch_line.batch_line_id,
                         'PAY_75092_BLD_HISTORICAL_ONLY',
                         75092);
    end if;
    --
    if l_line_in_error and batch_line.batch_line_status <> 'E' then
      error_message_line(batch_line.batch_line_id);
    end if;
  end loop;
  write_message_lines;
  hr_utility.set_location(' Leaving: '||l_proc, 90);
end validate_batch_lines;
--
-----------------------------------------------------------------------------
-- NAME
--  create_structure
-- PURPOSE
--  Creates the structure for Balance Upload
-- ARGUMENTS
--  p_batch_id - the batch for which a structure needs to be generated
-- NOTES
--  This is called from the SRS
-----------------------------------------------------------------------------
--
procedure create_structure(p_business_group_id in number,
                           p_batch_id          in number)
------------------------------------------------------------------------
is
  type t_cxt_iv is record (
    iv_name  pay_legislation_contexts.input_value_name%TYPE,
    UOM      pay_input_values_f.uom%TYPE);
  type t_cxt_ivs is table of t_cxt_iv index by binary_integer;
  tbl_cxt_ivs t_cxt_ivs;
  --
  l_num_cxts             number := 0;
  l_business_group_name  per_business_groups_perf.name%TYPE;
  l_legislation_code     per_business_groups_perf.legislation_code%TYPE;
  l_BG_currency_code     per_business_groups_perf.currency_code%TYPE;
  l_prev_currency_code   pay_balance_types.currency_code%TYPE;
  l_element_type_id      pay_element_types_f.element_type_id%TYPE;
  l_element_name         pay_element_types_f.element_name%TYPE;
  l_element_counter      number;
  l_element_link_id      number;
  l_iv_counter           number;
  --
  -- Cursor to derive necessary parameters in later phase.
  --
  cursor csr_bg is
    select
      pbg.name,
      pbg.legislation_code,
      pbg.currency_code
    from
      per_business_groups_perf  pbg
    where  pbg.business_group_id = p_business_group_id;
  --
  Cursor csr_cxt_ivs is
    select lc.input_value_name,
           decode(c.data_type,'T','C',c.data_type) UOM
    from   pay_legislation_contexts lc,
           ff_contexts c
    where  c.context_id = lc.context_id
    and    lc.input_value_name is not null
    and    lc.legislation_code = l_legislation_code;
  --
  -- Cursor to return balance types without balance initialization element feed
  -- for current batch_id
  --
  cursor csr_balance_wo_feed is
    select pbt2.balance_type_id id,
      pbt2.balance_name name,
      pbt2.balance_uom uom,
      nvl(pbt2.currency_code,l_BG_currency_code) currency_code
    from  pay_balance_types       pbt2
    where pbt2.balance_type_id in (select pbt.balance_type_id
    from  pay_balance_batch_lines bbl,
          pay_balance_types       pbt
    where bbl.batch_id = p_batch_id
    and   (bbl.balance_type_id = pbt.balance_type_id or
           (bbl.balance_type_id is null
            and   upper(pbt.balance_name) = upper(bbl.balance_name)))
    and   nvl(pbt.business_group_id, p_business_group_id) = p_business_group_id
    and   nvl(pbt.legislation_code, l_legislation_code) = l_legislation_code
    and   not exists(
        select  1
        from  pay_element_classifications  pec,
          pay_element_types_f    pet,
          pay_input_values_f    piv,
          pay_balance_feeds_f    pbf
        where  pbf.balance_type_id = pbt.balance_type_id
        and  pbf.effective_start_date = g_sot
        and  pbf.effective_end_date = g_eot
        and  nvl(pbf.business_group_id, p_business_group_id) = p_business_group_id
        and  nvl(pbf.legislation_code, l_legislation_code) = l_legislation_code
        and  piv.input_value_id = pbf.input_value_id
        and  piv.effective_start_date = g_sot
        and  piv.effective_end_date = g_eot
        and  pet.element_type_id = piv.element_type_id
        and  pet.effective_start_date = g_sot
        and  pet.effective_end_date = g_eot
        and  pec.classification_id = pet.classification_id
        and  pec.balance_initialization_flag = 'Y'))
    order by nvl(pbt2.currency_code,l_BG_currency_code)
    for update;

  --------------------------------------------------------------
  function create_iv(
      p_element_type_id  in number,
      p_element_name     in varchar2,
      p_element_link_id  in number,
      p_input_value_name in varchar2,
      p_uom              in varchar2,
      p_display_sequence in number) return number
  --------------------------------------------------------------
  is
    l_input_value_id  number;
  begin
    l_input_value_id := pay_db_pay_setup.create_input_value(
          p_element_name         => p_element_name,
          p_name                 => p_input_value_name,
          p_uom_code             => p_uom,
          p_business_group_name  => l_business_group_name,
          p_effective_start_date => g_sot,
          p_effective_end_date   => g_eot,
          p_display_sequence     => p_display_sequence);
    --
    hr_input_values.create_link_input_value(
      p_insert_type           => 'INSERT_INPUT_VALUE',
      p_element_link_id       => p_element_link_id,
      p_input_value_id        => l_input_value_id,
      p_input_value_name      => p_input_value_name,
      p_costable_type         => NULL,
      p_validation_start_date => g_sot,
      p_validation_end_date   => g_eot,
      p_default_value         => NULL,
      p_max_value             => NULL,
      p_min_value             => NULL,
      p_warning_or_error_flag => NULL,
      p_hot_default_flag      => NULL,
      p_legislation_code      => NULL,
      p_pay_value_name        => NULL,
      p_element_type_id       => p_element_type_id);
    --
    return l_input_value_id;
  end create_iv;
  --------------------------------------------------------------
  procedure create_iv_bf(
      p_balance_type_id  in number,
      p_balance_uom      in varchar2,
      p_element_type_id  in number,
      p_element_name     in varchar2,
      p_element_link_id  in number,
      p_input_value_name in varchar2,
      p_display_sequence in number)
  --------------------------------------------------------------
  is
    l_input_value_id  number;
  begin
    l_input_value_id := create_iv(
      p_element_type_id  => p_element_type_id,
      p_element_name     => p_element_name,
      p_element_link_id  => p_element_link_id,
      p_input_value_name => p_input_value_name,
      p_uom              => p_balance_uom,
      p_display_sequence => p_display_sequence);
    --
    hr_balances.ins_balance_feed(
      p_option                     => 'INS_MANUAL_FEED',
      p_input_value_id             => l_input_value_id,
      p_element_type_id            => p_element_type_id,
      p_primary_classification_id  => NULL,
      p_sub_classification_id      => NULL,
      p_sub_classification_rule_id => NULL,
      p_balance_type_id            => p_balance_type_id,
      p_scale                      => '1',
      p_session_date               => g_sot,
      p_business_group             => p_business_group_id,
      p_legislation_code           => NULL,
      p_mode                       => 'USER');
  end create_iv_bf;
  --------------------------------------------------------------
  procedure create_et_el(
      p_currency_code   in  varchar2,
      p_element_type_id out NOCOPY number,
      p_element_name    out NOCOPY varchar2,
      p_element_link_id out NOCOPY number)
  --------------------------------------------------------------
  is
    --
    l_iv_id number;
    --
    procedure init_element_counter
    is
      cursor csr_et(p_prefix varchar2) is
        select
          nvl(max(to_number(translate(upper(substr(element_name,
                                            instr(element_name,'_',-1)+1))
                           ,'0 _'||g_alphabet,'0'))),0)+1
        from  pay_element_types_f
        where  element_name like p_prefix;
    begin
      open  csr_et(g_element_name_prefix || p_batch_id || '%');
      fetch csr_et into l_element_counter;
      close csr_et;
    end init_element_counter;
  begin -- create_et_el
    if l_element_counter is null then
      init_element_counter;
    else l_element_counter := l_element_counter + 1;
    end if;

    p_element_name := g_element_name_prefix || p_batch_id || '_' ||
                      l_element_counter;
    --
    p_element_type_id := pay_db_pay_setup.create_element(
          p_element_name    => p_element_name,
          p_effective_start_date  => g_sot,
          p_effective_end_date  => g_eot,
          p_classification_name  => g_classification_name,
          p_input_currency_code  => p_currency_code,
          p_output_currency_code  => p_currency_code,
          p_processing_type  => 'N',
          p_adjustment_only_flag  => 'Y',
          p_process_in_run_flag  => 'Y',
          p_business_group_name  => l_business_group_name,
          p_post_termination_rule  => 'Final Close');
    --
    update  pay_element_types_f
    set  element_information1 = 'B'
    where  element_type_id = p_element_type_id;
    --
    p_element_link_id := pay_db_pay_setup.create_element_link(
          p_element_name          => p_element_name,
          p_link_to_all_pyrlls_fl => 'Y',
          p_standard_link_flag    => 'N',
          p_effective_start_date  => g_sot,
          p_effective_end_date    => g_eot,
          p_business_group_name   => l_business_group_name);
    for i in 1..l_num_cxts loop
      l_iv_id := create_iv(
        p_element_type_id  => p_element_type_id,
        p_element_name     => p_element_name,
        p_element_link_id  => p_element_link_id,
        p_input_value_name => tbl_cxt_ivs(i).iv_name,
        p_uom              => tbl_cxt_ivs(i).UOM,
        p_display_sequence => i);
    end loop;
  end create_et_el;
begin -- create_structure
  open csr_bg;
  fetch csr_bg into
    l_business_group_name,
    l_legislation_code,
    l_BG_currency_code;
  close csr_bg;
  -- Cache the contexts
  for l_cxt_iv in csr_cxt_ivs loop
    l_num_cxts := l_num_cxts +1;
    tbl_cxt_ivs(l_num_cxts).iv_name := l_cxt_iv.input_value_name;
    tbl_cxt_ivs(l_num_cxts).UOM     := l_cxt_iv.UOM;
  end loop;
  --
  -- Loop of balances without initial balance feed for current batch_id.
  --
  for l_bal in csr_balance_wo_feed loop
    if l_iv_counter is null or l_iv_counter >= g_iv_limit - l_num_cxts
    or l_bal.currency_code <> l_prev_currency_code
    then
      l_iv_counter := 1;
      --
      -- Create element type and link, plus context inputs with link inputs.
      --
      create_et_el(
        p_currency_code    => l_bal.currency_code, -- IN
        p_element_type_id  => l_element_type_id,   -- OUT
        p_element_name     => l_element_name,      -- OUT
        p_element_link_id  => l_element_link_id);  -- OUT
      --
      l_prev_currency_code := l_bal.currency_code;
    else
      l_iv_counter := l_iv_counter + 1;
    end if;
    --
    -- Create input_value, link_input_value and balance_feed.
    --
    create_iv_bf(
      p_balance_type_id  => l_bal.id,
      p_balance_uom      => l_bal.uom,
      p_element_type_id  => l_element_type_id,
      p_element_name     => l_element_name,
      p_element_link_id  => l_element_link_id,
      p_input_value_name => rtrim(substr(l_bal.name, 1, 27)) || '_' ||
                            lpad(to_char(l_iv_counter),2,'0'),
      p_display_sequence => l_iv_counter+l_num_cxts);
  end loop;
end create_structure;
------------------------------------------------------------------------
procedure create_structure(
    errbuf      out NOCOPY varchar2,
    retcode     out NOCOPY number,
    p_business_group_id in number,
    p_batch_id  in number)
is
begin
  --
  -- errbuf and retcode are special parameters needed for the SRS.
  -- retcode = 0 means no error and retcode = 2 means an error occurred.
  --
  retcode := 0;
  create_structure(p_batch_id    => p_batch_id,
                   p_business_group_id => p_business_group_id);
  --
  commit;
exception
  WHEN HR_UTILITY.HR_ERROR THEN
    retcode := 2;
    errbuf := SUBSTRB(HR_UTILITY.GET_MESSAGE,1,240);
    rollback;
  when others then
    retcode := 2;
    errbuf  := substrb(SQLERRM,1,240);
    rollback;
end create_structure;
--
end pay_fr_bal_upload;

/
