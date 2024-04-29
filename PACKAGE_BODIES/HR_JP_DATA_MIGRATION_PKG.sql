--------------------------------------------------------
--  DDL for Package Body HR_JP_DATA_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JP_DATA_MIGRATION_PKG" AS
/* $Header: hrjpdtmg.pkb 120.6.12010000.2 2009/10/14 13:39:30 keyazawa ship $ */
--
c_package	constant varchar2(31) := 'hr_jp_data_migration_pkg.';
--
c_legislation_code constant varchar2(2) := 'JP';
c_commit_num constant number := 1000;
c_skip_warning varchar2(10) := 'FALSE';
--
c_mig_smr_sd date := to_date('2007/04/01','YYYY/MM/DD');
--
c_com_hi_smr_elm pay_element_types_f.element_name%type := 'COM_HI_SMR_INFO';
c_am_iv    pay_input_values_f.name%type := 'APPLY_MTH';
c_mr_iv    pay_input_values_f.name%type := 'REVISED_MR';
c_mr_o_iv  pay_input_values_f.name%type := 'PRIOR_MR';
c_smr_iv   pay_input_values_f.name%type := 'REVISED_SMR';
c_smr_o_iv pay_input_values_f.name%type := 'PRIOR_SMR';
c_at_iv    pay_input_values_f.name%type := 'APPLY_TYPE';
--
c_com_hi_smr_elm_id number;
c_am_iv_id    number;
c_mr_iv_id    number;
c_mr_o_iv_id  number;
c_smr_iv_id   number;
c_smr_o_iv_id number;
c_at_iv_id    number;
--
c_com_smr_tbl pay_user_tables.user_table_name%type  := 'T_COM_SMR';
c_hi_smr_col pay_user_columns.user_column_name%type := 'HI_SMR';
--
c_new_smr_min_high number := 93000;
c_new_smr_max_low  number := 1005000;
--
c_fut_exist_mesg   fnd_new_messages.message_text%type;
c_already_upd_mesg fnd_new_messages.message_text%type;
c_fut_am_mesg      fnd_new_messages.message_text%type;
c_am_null_mesg     fnd_new_messages.message_text%type;
c_mr_null_mesg     fnd_new_messages.message_text%type;
--
g_dml_num number;
--
g_qualify_ini_ass_id number;
g_migrate_ini_ass_id number;
--
g_ass_info t_ass_hi_smr_rec;
--
g_qualify_hi_smr_ass_tbl t_ass_hi_smr_tbl;
--
--------------------------------------------------------------------------------
-- p_mode is ELE_RR_COPY_TO then copy record pay_run_results and pay_run_result_values
--      from existing element to new element

  PROCEDURE element_run_result_copy(
    p_mode        IN  VARCHAR2,
    p_parameter_name  IN  VARCHAR2,
    p_parameter_value IN  NUMBER)
--------------------------------------------------------------------------------
IS
  l_element_type_id_from    NUMBER;
  l_element_type_id_to    NUMBER;

  CURSOR  csr_related_iv IS
    select  hjp1.parameter_value  iv_mode,
        hjp2.parameter_name   iv_name,
        hjp2.parameter_value  iv_id_to,
        hjp3.parameter_value  iv_id_from
    from  hr_jp_parameters hjp1,
        hr_jp_parameters hjp2,
        hr_jp_parameters hjp3
    where hjp1.owner = p_parameter_name
    and   hjp2.owner = hjp1.parameter_value
    and   hjp2.parameter_name = hjp1.parameter_name
    and   hjp3.owner(+) = 'IV_COPY_FROM'
    and   hjp3.parameter_name(+) = hjp2.parameter_name;

--
BEGIN

  hr_utility.set_location('Start ' || p_mode || p_parameter_name, 5);
  if p_mode = 'ELE_RR_COPY_TO' then
    -- find ELE_RR_COPY_FROM element_type_id
    l_element_type_id_to := p_parameter_value;
  --
    l_element_type_id_from := hr_jp_parameters_pkg.get_parameter_value('ELE_RR_COPY_FROM',p_parameter_name);

    if l_element_type_id_from is not null then
      -- copy run result

      insert into pay_run_results (
        RUN_RESULT_ID,
        ELEMENT_TYPE_ID,
        ASSIGNMENT_ACTION_ID,
        ENTRY_TYPE,
        SOURCE_ID,
        SOURCE_TYPE,
        STATUS)
      select  /*+ INDEX(PRR_FROM PAY_RUN_RESULTS_N1) */
        pay_run_results_s.nextval,
        l_element_type_id_to,
        prr_from.assignment_action_id,
        prr_from.entry_type,
        prr_from.source_id,
        prr_from.source_type,
        prr_from.status
      from  pay_run_results prr_from
      where prr_from.element_type_id = l_element_type_id_from
      and not exists(
          select  /*+ INDEX(PRR_TO PAY_RUN_RESULTS_N50) */
            NULL
          from  pay_run_results prr_to
          where prr_to.assignment_action_id = prr_from.assignment_action_id
          and prr_to.element_type_id = l_element_type_id_to);

      hr_utility.trace('Successefully  created run_result');

      -- get related input values
      for rec_related_iv in csr_related_iv
      loop
        if rec_related_iv.iv_mode = 'IV_COPY_TO' then
          insert into pay_run_result_values (
              INPUT_VALUE_ID,
              RUN_RESULT_ID,
              RESULT_VALUE)
          select  /*+ ORDERED
            INDEX(FROM_ELE_PRR PAY_RUN_RESULTS_N1)
            INDEX(PRRV_FROM PAY_RUN_RESULT_VALUES_PK)
            INDEX(TO_ELE_PRR PAY_RUN_RESULTS_N50)
            USE_NL(prrv_from to_ele_prr) */
            rec_related_iv.iv_id_to,
            to_ele_prr.run_result_id,
            prrv_from.result_value
          from  pay_run_results   from_ele_prr,
            pay_run_result_values prrv_from,
            pay_run_results   to_ele_prr
          where from_ele_prr.element_type_id = l_element_type_id_from
          and prrv_from.run_result_id = from_ele_prr.run_result_id
          and prrv_from.input_value_id = rec_related_iv.iv_id_from
          and to_ele_prr.assignment_action_id = from_ele_prr.assignment_action_id
          and to_ele_prr.element_type_id = l_element_type_id_to
          and not exists(
              select  NULL
              from  pay_run_result_values prrv_to
              where prrv_to.run_result_id = to_ele_prr.run_result_id
              and prrv_to.input_value_id = rec_related_iv.iv_id_to);

        end if;
        if rec_related_iv.iv_mode = 'ADD_NEW_IV' then
          insert into pay_run_result_values (
            INPUT_VALUE_ID,
            RUN_RESULT_ID,
            RESULT_VALUE)
          select  /*+ INDEX(TO_ELE_PRR PAY_RUN_RESULTS_N1) */
            rec_related_iv.iv_id_to,
            to_ele_prr.run_result_id,
            NULL
          from  pay_run_results to_ele_prr
          where to_ele_prr.element_type_id = l_element_type_id_to
          and not exists(
              select  NULL
              from  pay_run_result_values prrv_to
              where prrv_to.run_result_id = to_ele_prr.run_result_id
              and prrv_to.input_value_id = rec_related_iv.iv_id_to);

        end if;
      end loop;
      hr_utility.trace('Successefully  created run_result_value');
    end if;
  end if;
END;

--------------------------------------------------------------------------------
-- p_mode is ADD_NEW_IV then insert pay_link_input_value and pay_element_entry_values_f
--
  PROCEDURE add_new_input_value(
    p_mode        IN  VARCHAR2,
    p_parameter_name  IN  VARCHAR2,
    p_parameter_value IN  NUMBER)
--------------------------------------------------------------------------------
IS
  l_input_value_id_to     NUMBER;
  l_costed_flag       VARCHAR2(30);
  l_total_upd_actions     NUMBER := 0;

  CURSOR  csr_run_result_id  IS
    select  /*+ ORDERED
                    INDEX(PIV PAY_INPUT_VALUES_F_PK)
                    INDEX(PET PAY_ELEMENT_TYPES_F_PK)
                    INDEX(PRR PAY_RUN_RESULTS_N1) */
            prr.run_result_id   run_result_id
    from  pay_input_values_f    piv,
                pay_element_types_f   pet,
        pay_run_results     prr
    where piv.input_value_id = p_parameter_value
    and   pet.element_type_id = piv.element_type_id
    and   piv.effective_start_date
        between pet.effective_start_date and pet.effective_end_date
    and   prr.element_type_id = pet.element_type_id
    and not exists(
        select  /*+ INDEX(PRRV PAY_RUN_RESULT_VALUES_PK) */
                        NULL
        from  pay_run_result_values prrv
        where prrv.run_result_id=prr.run_result_id
        and   prrv.input_value_id=l_input_value_id_to);

  CURSOR  csr_element_link_id IS
  select  /*+ ORDERED
                INDEX(PIV PAY_INPUT_VALUES_F_PK)
                INDEX(PET PAY_ELEMENT_TYPES_F_PK)
                INDEX(PEL PAY_ELEMENT_LINKS_F_N7) */
        pel.rowid       row_id,
      pel.element_link_id   element_link_id,
      pel.costable_type   costable_type,
      piv.name        input_value_name,
      piv.effective_start_date      effective_start_date,
      piv.effective_end_date        effective_end_date,
      piv.default_value   default_value,
      piv.max_value     max_value,
      piv.min_value     min_value,
      piv.warning_or_error  warning_or_error
  from  pay_input_values_f  piv,
            pay_element_types_f pet,
      pay_element_links_f pel
  where piv.input_value_id = p_parameter_value
  and   pet.element_type_id = piv.element_type_id
  and   piv.effective_start_date
      between pet.effective_start_date and pet.effective_end_date
  and   pel.element_type_id = pet.element_type_id
  and   pel.effective_start_date    <= piv.effective_end_date
  and   pel.effective_end_date      >= piv.effective_start_date;

  CURSOR csr_element_entry_id(
    p_element_link_id IN NUMBER,
    p_input_value_id  IN NUMBER)
   IS
    select  /*+ INDEX(PEE PAY_ELEMENT_ENTRIES_F_N4) */
        pee.rowid   row_id,
        pee.element_entry_id  element_entry_id
    from  pay_element_entries_f pee
    where pee.element_link_id = p_element_link_id
    and not exists(select /*+ INDEX(PEEV PAY_ELEMENT_ENTRY_VALUES_F_N50) */
                        NULL
        from  pay_element_entry_values_f peev
        where peev.element_entry_id = pee.element_entry_id
        and   peev.input_value_id = p_input_value_id
        and   peev.effective_start_date = pee.effective_start_date
        and   peev.effective_end_date = pee.effective_end_date);

--
BEGIN

  hr_utility.set_location('Start procedure in the hr_jp_data_migration_pkg' || p_mode || p_parameter_name, 5);
  if p_mode = 'ADD_NEW_IV' then
    l_input_value_id_to := p_parameter_value;

    -- find element_link_id of parent element
    for rec_element_link in csr_element_link_id
    loop
      if rec_element_link.costable_type in ('F', 'C', 'D')
          and rec_element_link.input_value_name = hr_general.pay_value then
        l_costed_flag := 'Y';
      else
        l_costed_flag := 'N';
      end if;
      insert  into  pay_link_input_values_f
        (LINK_INPUT_VALUE_ID,
         EFFECTIVE_START_DATE,
         EFFECTIVE_END_DATE,
         ELEMENT_LINK_ID,
         INPUT_VALUE_ID,
         COSTED_FLAG,
         DEFAULT_VALUE,
         MAX_VALUE,
         MIN_VALUE,
         WARNING_OR_ERROR,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CREATED_BY,
         CREATION_DATE)
       select PAY_LINK_INPUT_VALUES_S.nextval,
        greatest(pel.effective_start_date,rec_element_link.effective_start_date),
        least(pel.effective_end_date,rec_element_link.effective_end_date),
        rec_element_link.element_link_id,
        l_input_value_id_to,
        l_costed_flag,
        rec_element_link.default_value,
        rec_element_link.max_value,
        rec_element_link.min_value,
        rec_element_link.warning_or_error,
        pel.last_update_date,
        pel.last_updated_by,
        pel.last_update_login,
        NULL,
        pel.creation_date
      from  pay_element_links_f pel
      where pel.rowid=rec_element_link.row_id
      and not exists(
          select  null
          from  pay_link_input_values_f
          where element_link_id = rec_element_link.element_link_id
          and   input_value_id = l_input_value_id_to);
      hr_utility.trace('Successefully  created link_input_value '|| to_char(rec_element_link.element_link_id));

      for rec_element_entry in csr_element_entry_id(rec_element_link.element_link_id,l_input_value_id_to) loop
        insert into pay_element_entry_values_f(
          ELEMENT_ENTRY_VALUE_ID,
          EFFECTIVE_START_DATE,
          EFFECTIVE_END_DATE,
          INPUT_VALUE_ID,
          ELEMENT_ENTRY_ID,
          SCREEN_ENTRY_VALUE)
        select  pay_element_entry_values_s.nextval,
          pee.effective_start_date,
          pee.effective_end_date,
          l_input_value_id_to,
          pee.element_entry_id,
          NULL
        from  pay_element_entries_f pee
        where pee.rowid=rec_element_entry.row_id;

        l_total_upd_actions := l_total_upd_actions + 1;
        if l_total_upd_actions > 1000 then
          commit;
          l_total_upd_actions := 0;
        end if;
      end loop;
      hr_utility.trace('Successefully  created element_entry_value');
      if l_total_upd_actions > 0 then
        l_total_upd_actions := 0;
        commit;
      end if;
    end loop;

    -- find run_result_id of parent element
    for rec_run_result_id in csr_run_result_id
    loop
      insert into pay_run_result_values (
          INPUT_VALUE_ID,
          RUN_RESULT_ID,
          RESULT_VALUE)
      values(l_input_value_id_to,
          rec_run_result_id.run_result_id,
          NULL);

      l_total_upd_actions := l_total_upd_actions + 1;
      if l_total_upd_actions > 1000 then
        commit;
        l_total_upd_actions := 0;
      end if;
    end loop;
    hr_utility.trace('Successefully  created run_result_value '|| to_char(l_input_value_id_to));

    if l_total_upd_actions > 0 then
      commit;
    end if;
  end if;
END;

--------------------------------------------------------------------------------
-- This procedure will update or delete element entry for obsolete elements in R11i.
--    -If the element entry exist on sysdate then effective_end_date set to sysdate.
--    -If the element entry exist later than sysdate then these records will be purged.
--
  PROCEDURE end_element_entry(
      p_mode        IN VARCHAR2,
      p_parameter_name  IN VARCHAR2,
      p_parameter_value IN NUMBER,
      p_session_date    IN DATE)
--------------------------------------------------------------------------------
IS
  l_element_type_id   NUMBER;
  l_delete_mode     VARCHAR2(10);
  l_target_date     DATE;
  l_total_upd_actions   NUMBER := 0;
  v_entry_id        NUMBER;

  CURSOR  csr_element_link_id IS
    select  element_link_id
    from  pay_element_links_f
    where element_type_id=l_element_type_id;

  CURSOR csr_element_entry_id(
    p_element_link_id IN NUMBER,
    p_session_date    IN DATE)
  IS
    select  pee.element_entry_id,
        pee.effective_start_date
    from  pay_element_entries_f pee
    where pee.element_link_id=p_element_link_id
    and   p_session_date<pee.effective_end_date;

  CURSOR csr_chk_entry(
    p_element_entry_id  IN NUMBER,
    p_session_date    IN DATE)
  IS
    select  pee.element_entry_id
    from  pay_element_entries_f pee
    where pee.element_entry_id=p_element_entry_id
    and p_session_date
      between pee.effective_start_date and pee.effective_end_date;

BEGIN
  hr_utility.set_location('Start procedure in the hr_jp_data_migration_pkg' || p_mode || p_parameter_name, 5);
  if p_mode = 'ELE_END_ENTRY' then
    l_element_type_id := p_parameter_value;
    for rec_element_link in csr_element_link_id
    loop
      for rec_element_entry in csr_element_entry_id(rec_element_link.element_link_id,p_session_date) loop
        open csr_chk_entry(rec_element_entry.element_entry_id,rec_element_entry.effective_start_date);
        fetch csr_chk_entry into v_entry_id;
        if csr_chk_entry%found then
          close csr_chk_entry;
          if rec_element_entry.effective_start_date > p_session_date then
            l_delete_mode := 'ZAP';
            l_target_date := rec_element_entry.effective_start_date;
          else
            l_delete_mode := 'DELETE';
            l_target_date := p_session_date;
          end if;
          hr_entry_api.delete_element_entry(l_delete_mode,l_target_date,rec_element_entry.element_entry_id);
          l_total_upd_actions := l_total_upd_actions + 1;
        else
          close csr_chk_entry;
        end if;
        if l_total_upd_actions > 1000 then
          commit;
          l_total_upd_actions := 0;
        end if;
      end loop;
      if l_total_upd_actions > 0 then
        commit;
      end if;
    end loop;
  end if;
END;
--
--
-- -------------------------------------------------------------------------
-- get_ass_info
-- -------------------------------------------------------------------------
function get_ass_info(
  p_assignment_id  in number,
  p_effective_date in date)
return t_ass_hi_smr_rec
is
--
  l_proc varchar2(80) := c_package||'get_ass_info';
--
  cursor csr_ass
  is
  select /*+ ORDERED
             INDEX(PA PER_ASSIGNMENTS_F_PK) */
         pbg.business_group_id bg_id,
         pbg.name bg_name,
         pa.assignment_number ass_num
  from   per_all_assignments_f pa,
         per_business_groups_perf pbg
  where  pa.assignment_id = p_assignment_id
  and    p_effective_date
         between pa.effective_start_date and pa.effective_end_date
  and    pbg.business_group_id = pa.business_group_id;
--
  l_csr_ass csr_ass%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('p_assignment_id : '||to_char(p_assignment_id));
  end if;
--
  if g_ass_info.ass_id <> p_assignment_id
  or g_ass_info.ass_id is null then
  --
    open csr_ass;
    fetch csr_ass into l_csr_ass;
    close csr_ass;
  --
    g_ass_info.ass_id  := p_assignment_id;
    g_ass_info.ass_num := l_csr_ass.ass_num;
    g_ass_info.bg_id   := l_csr_ass.bg_id;
    g_ass_info.bg_name := l_csr_ass.bg_name;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
return g_ass_info;
--
end get_ass_info;
--
-- -------------------------------------------------------------------------
-- set_hi_smr_id
-- -------------------------------------------------------------------------
procedure set_hi_smr_id
is
--
  l_proc varchar2(80) := c_package||'set_hi_smr_id';
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  c_com_hi_smr_elm_id := hr_jp_id_pkg.element_type_id(c_com_hi_smr_elm,null,c_legislation_code,c_skip_warning);
  c_am_iv_id    := hr_jp_id_pkg.input_value_id(c_com_hi_smr_elm_id,c_am_iv,c_skip_warning);
  c_mr_iv_id    := hr_jp_id_pkg.input_value_id(c_com_hi_smr_elm_id,c_mr_iv,c_skip_warning);
  c_mr_o_iv_id  := hr_jp_id_pkg.input_value_id(c_com_hi_smr_elm_id,c_mr_o_iv,c_skip_warning);
  c_smr_iv_id   := hr_jp_id_pkg.input_value_id(c_com_hi_smr_elm_id,c_smr_iv,c_skip_warning);
  c_smr_o_iv_id := hr_jp_id_pkg.input_value_id(c_com_hi_smr_elm_id,c_smr_o_iv,c_skip_warning);
  c_at_iv_id    := hr_jp_id_pkg.input_value_id(c_com_hi_smr_elm_id,c_at_iv,c_skip_warning);
--
  if g_debug then
    hr_utility.trace('c_com_hi_smr_elm_id : '||to_char(c_com_hi_smr_elm_id));
    hr_utility.trace('c_am_iv_id          : '||to_char(c_am_iv_id));
    hr_utility.trace('c_mr_iv_id          : '||to_char(c_mr_iv_id));
    hr_utility.trace('c_mr_o_iv_id        : '||to_char(c_mr_o_iv_id));
    hr_utility.trace('c_smr_iv_id         : '||to_char(c_smr_iv_id));
    hr_utility.trace('c_smr_o_iv_id       : '||to_char(c_smr_o_iv_id));
    hr_utility.trace('c_at_iv_id          : '||to_char(c_at_iv_id));
    hr_utility.set_location(l_proc,1000);
  end if;
--
end set_hi_smr_id;
--
-- -------------------------------------------------------------------------
-- set_hi_smr_mesg
-- -------------------------------------------------------------------------
procedure set_hi_smr_mesg
is
--
  l_proc varchar2(80) := c_package||'set_hi_smr_mesg';
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
    fnd_message.set_name('PAY','PAY_JP_MIG_SMR_FUT_EXIST');
    c_fut_exist_mesg := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_MIG_SMR_ALREADY_UPD');
    c_already_upd_mesg := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_MIG_SMR_FUT_AM');
    c_fut_am_mesg := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_MIG_SMR_AM_NULL');
    c_am_null_mesg := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_MIG_SMR_MR_NULL');
    c_mr_null_mesg := fnd_message.get;
--
  if g_debug then
    hr_utility.trace('c_fut_exist_mesg   : '||c_fut_exist_mesg);
    hr_utility.trace('c_already_upd_mesg : '||c_already_upd_mesg);
    hr_utility.trace('c_fut_am_mesg      : '||c_fut_am_mesg);
    hr_utility.trace('c_am_null_mesg     : '||c_am_null_mesg);
    hr_utility.trace('c_mr_null_mesg     : '||c_mr_null_mesg);
    hr_utility.set_location(l_proc,1000);
  end if;
--
end set_hi_smr_mesg;
--
-- -------------------------------------------------------------------------
-- get_sqlerrm
-- -------------------------------------------------------------------------
function get_sqlerrm
return varchar2
is
begin
--
  if sqlcode = -20001 then
  --
    declare
      l_sqlerrm varchar2(2000) := fnd_message.get;
    begin
      if l_sqlerrm is not null then
        return l_sqlerrm;
      else
        return sqlerrm;
      end if;
    end;
  --
  else
    return sqlerrm;
  end if;
--
end get_sqlerrm;
--
-- -------------------------------------------------------------------------
-- get_mig_date
-- -------------------------------------------------------------------------
function get_mig_date
return date
is
--
  l_proc varchar2(80) := c_package||'get_mig_date';
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('g_mig_date : '||to_char(g_mig_date,'YYYY/MM/DD'));
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
return g_mig_date;
--
end get_mig_date;
--
-- -------------------------------------------------------------------------
-- insert_session
-- -------------------------------------------------------------------------
procedure insert_session(
            p_effective_date in date)
is
--
  l_rowid rowid;
--
  cursor csr_session
  is
  select rowid
  from   fnd_sessions
  where  session_id = userenv('sessionid')
  for update nowait;
--
begin
--
  open csr_session;
  fetch csr_session into l_rowid;
  --
    if csr_session%notfound then
    --
      insert into fnd_sessions(
        session_id,
        effective_date)
      values(
        userenv('sessionid'),
        p_effective_date);
    --
    else
    --
      update fnd_sessions
      set    effective_date = p_effective_date
      where rowid = l_rowid;
    --
    end if;
  --
  close csr_session;
--
end insert_session;
--
-- -------------------------------------------------------------------------
-- delete_session
-- -------------------------------------------------------------------------
procedure delete_session
is
begin
--
  delete
  from  fnd_sessions
  where session_id = userenv('sessionid');
--
end delete_session;
--
-- -------------------------------------------------------------------------
-- qualify_hi_smr_hd
-- -------------------------------------------------------------------------
-- run by qualify_hi_smr_data
procedure qualify_hi_smr_hd(
  p_assignment_id in number)
is
--
  l_proc varchar2(80) := c_package||'qualify_hi_smr_hd';
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('g_qualify_ini_ass_id : '||to_char(g_qualify_ini_ass_id));
  end if;
--
  if g_qualify_ini_ass_id is null
  or g_qualify_ini_ass_id = p_assignment_id then
  --
    fnd_file.put_line(fnd_file.log, 'Business Group Name            Assignment Number              Message');
    fnd_file.put_line(fnd_file.log, '------------------------------ ------------------------------ --------------------------------------------------------------------------------');
  --
    g_qualify_ini_ass_id := p_assignment_id;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('g_qualify_ini_ass_id : '||to_char(g_qualify_ini_ass_id));
    hr_utility.set_location(l_proc,1000);
  end if;
--
end qualify_hi_smr_hd;
--
-- -------------------------------------------------------------------------
-- migrate_hi_smr_hd
-- -------------------------------------------------------------------------
-- run by migrate_hi_smr_data
procedure migrate_hi_smr_hd(
  p_assignment_id in number)
is
--
  l_proc varchar2(80) := c_package||'migrate_hi_smr_hd';
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('g_migrate_ini_ass_id : '||to_char(g_migrate_ini_ass_id));
  end if;
--
  if g_migrate_ini_ass_id is null
  or g_migrate_ini_ass_id = p_assignment_id then
  --
    fnd_file.put_line(fnd_file.output, 'Business Group Name            Assignment Number                        MR        SMR    Exp SMR');
    fnd_file.put_line(fnd_file.output, '------------------------------ ------------------------------ ------------ ---------- ----------');
  --
    g_migrate_ini_ass_id := p_assignment_id;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('g_migrate_ini_ass_id : '||to_char(g_migrate_ini_ass_id));
    hr_utility.set_location(l_proc,1000);
  end if;
--
end migrate_hi_smr_hd;
--
-- -------------------------------------------------------------------------
-- init_def_hi_smr_data
-- -------------------------------------------------------------------------
-- run by qualify_hi_smr_data
procedure init_def_hi_smr_data
is
--
  l_proc varchar2(80) := c_package||'init_def_hi_smr_data';
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('g_legislation_code : '||g_legislation_code);
  end if;
--
  -- temporary solution because of no initialize.
  -- run once for each thread.
  if g_legislation_code is null
  or g_legislation_code <> c_legislation_code then
  --
    -- no support of legsilative parameter at this moment.
    g_skip_qualify := 'N';
    g_upd_mode     := 'UPDATE';
    g_mig_date     := c_mig_smr_sd;
  --
    set_hi_smr_id;
    set_hi_smr_mesg;
  --
    g_legislation_code := c_legislation_code;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('g_legislation_code : '||g_legislation_code);
    hr_utility.set_location(l_proc,1000);
  end if;
--
end init_def_hi_smr_data;
--
-- -------------------------------------------------------------------------
-- val_mig_smr_assact
-- -------------------------------------------------------------------------
procedure val_mig_smr_assact(
  p_business_group_id   in number,
  p_business_group_name in varchar2,
  p_assignment_id       in number,
  p_assignment_number   in varchar2,
  p_session_date        in date,
  p_valid_delete        in out nocopy varchar2)
is
--
  l_proc varchar2(80) := c_package||'val_mig_smr_assact';
--
  l_am_eev pay_element_entry_values_f.screen_entry_value%type;
  l_mr_eev pay_element_entry_values_f.screen_entry_value%type;
  l_ee_esd date;
  l_ee_upd_id number;
  l_ft_ee_esd date;
  l_am_date date;
--
  l_valid_delete varchar2(1) := 'N';
--
  cursor csr_ee_esd
  is
  select /*+ ORDERED
             USE_NL(PLIV, PEE)
             INDEX(PLIV PAY_LINK_INPUT_VALUES_F_N2)
             INDEX(PEE PAY_ELEMENT_ENTRIES_F_N51) */
         pee.effective_start_date,
         pee.updating_action_id
  from   pay_link_input_values_f pliv,
         pay_element_entries_f pee
  where  pliv.input_value_id = c_smr_iv_id
  and    p_session_date
         between pliv.effective_start_date and pliv.effective_end_date
  and    pee.element_link_id = pliv.element_link_id
  and    pee.assignment_id = p_assignment_id
  and    p_session_date
         between pee.effective_start_date and pee.effective_end_date;
--
  cursor csr_ft_ee
  is
  select /*+ ORDERED
             USE_NL(PLIV, PEE)
             INDEX(PLIV PAY_LINK_INPUT_VALUES_F_N2)
             INDEX(PEE PAY_ELEMENT_ENTRIES_F_N51) */
         pee.effective_start_date
  from   pay_link_input_values_f pliv,
         pay_element_entries_f pee
  where  pliv.input_value_id = c_smr_iv_id
  and    p_session_date
         between pliv.effective_start_date and pliv.effective_end_date
  and    pee.element_link_id = pliv.element_link_id
  and    pee.assignment_id = p_assignment_id
  and    pee.effective_start_date > p_session_date;
--
begin
--
  if g_detail_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace(p_business_group_id ||' : '||p_assignment_id||'('||p_assignment_number||')');
  end if;
--
  if p_valid_delete = 'N' then
  --
  -- skip ee not exist.
  -- skip already updated (manual update)
  --
    open csr_ee_esd;
    fetch csr_ee_esd into l_ee_esd, l_ee_upd_id;
    close csr_ee_esd;
  --
    if l_ee_esd is not null then
    --
      l_valid_delete := 'Y';
    --
    end if;
  --
    if g_skip_manual_upd = 'Y' then
    --
      if l_ee_esd = p_session_date
      and l_ee_esd is not null
      and l_ee_upd_id is null then
      --
        l_valid_delete := 'N';
      --
        if g_sql_run = 'Y' then
        --
          if g_log = 'Y' then
          --
            hr_utility.trace(rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||c_already_upd_mesg);
          --
          end if;
        --
        else
        --
          fnd_file.put_line(fnd_file.log, rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||c_already_upd_mesg);
        --
        end if;
      --
      end if;
    --
    end if;
  --
    if g_detail_debug then
      hr_utility.set_location(l_proc,10);
      hr_utility.trace('skip manual upd : l_valid_delete : '||l_valid_delete);
    end if;
  --
  -- skip future entry exists
  --
    if l_valid_delete = 'Y' then
    --
      open csr_ft_ee;
      fetch csr_ft_ee into l_ft_ee_esd;
      close csr_ft_ee;
    --
      if l_ft_ee_esd is not null then
      --
        l_valid_delete := 'N';
      --
        if g_sql_run = 'Y' then
        --
          if g_log = 'Y' then
          --
            hr_utility.trace(rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||c_fut_exist_mesg);
          --
          end if;
        --
        else
        --
          fnd_file.put_line(fnd_file.log, rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||c_fut_exist_mesg);
        --
        end if;
      --
      end if;
    --
    end if;
  --
    if g_detail_debug then
      hr_utility.set_location(l_proc,20);
      hr_utility.trace('skip future entry : l_valid_delete : '||l_valid_delete);
    end if;
  --
  -- skip in update mode applied month is future (>= p_session_date)
  --
    if l_valid_delete = 'Y'
    and g_upd_mode <> 'OVERRIDE' then
    --
      l_am_eev := pay_jp_balance_pkg.get_entry_value_char(
                     p_input_value_id => c_am_iv_id,
                     p_assignment_id  => p_assignment_id,
                     p_effective_date => p_session_date);
    --
      if l_am_eev is not null then
      --
        l_am_date := to_date(l_am_eev||'01','YYYYMMDD');
      --
        if trunc(l_am_date,'DD') >= trunc(p_session_date,'DD') then
        --
          l_valid_delete := 'N';
        --
          if g_sql_run = 'Y' then
          --
            if g_log = 'Y' then
            --
              hr_utility.trace(rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||c_fut_am_mesg);
            --
            end if;
          --
          else
          --
            fnd_file.put_line(fnd_file.log, rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||c_fut_am_mesg);
          --
          end if;
        --
        end if;
      --
      else
      --
        l_valid_delete := 'N';
      --
        if g_sql_run = 'Y' then
        --
          if g_log = 'Y' then
          --
            hr_utility.trace(rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||c_am_null_mesg);
          --
          end if;
        --
        else
        --
          fnd_file.put_line(fnd_file.log, rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||c_am_null_mesg);
        --
        end if;
      --
      end if;
    --
    end if;
  --
    if g_detail_debug then
      hr_utility.set_location(l_proc,30);
      hr_utility.trace('skip applied month in future : l_valid_delete : '||l_valid_delete);
    end if;
  --
  -- skip mr is null.
  -- target only assignment, who belongs to new mr range.
  --
    if l_valid_delete = 'Y' then
    --
      l_mr_eev := pay_jp_balance_pkg.get_entry_value_char(
                     p_input_value_id => c_mr_iv_id,
                     p_assignment_id  => p_assignment_id,
                     p_effective_date => p_session_date);
    --
      if l_mr_eev is null then
      --
        l_valid_delete := 'N';
      --
        if g_sql_run = 'Y' then
        --
          if g_log = 'Y' then
          --
            hr_utility.trace(rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||c_mr_null_mesg);
          --
          end if;
        --
        else
        --
          fnd_file.put_line(fnd_file.log, rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||c_mr_null_mesg);
        --
        end if;
      --
      else
      --
        if g_skip_out_range_upd = 'Y' then
        --
          if (to_number(l_mr_eev) >= c_new_smr_min_high
              and to_number(l_mr_eev) < c_new_smr_max_low) then
          --
            l_valid_delete := 'N';
          --
          end if;
        --
        end if;
      --
      end if;
    --
    end if;
  --
    if g_detail_debug then
      hr_utility.set_location(l_proc,40);
      hr_utility.trace('skip mr is null or out range : l_valid_delete : '||l_valid_delete);
    end if;
  --
    if l_valid_delete = 'Y' then
    --
      p_valid_delete := 'Y';
    --
    end if;
  --
  end if;
--
  if g_detail_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
when others then
--
  if g_debug then
    hr_utility.set_location(l_proc,-1000);
    hr_utility.trace(to_char(p_assignment_id)||':'||get_sqlerrm);
  end if;
--
end val_mig_smr_assact;
--
-- -------------------------------------------------------------------------
-- mig_smr_assact
-- -------------------------------------------------------------------------
procedure mig_smr_assact(
  p_business_group_id   in number,
  p_business_group_name in varchar2,
  p_assignment_id       in number,
  p_assignment_number   in varchar2,
  p_session_date        in date,
  p_hi_mr               in varchar2)
is
--
  l_proc varchar2(80) := c_package||'mig_smr_assact';
--
  l_mr_eev pay_element_entry_values_f.screen_entry_value%type;
  l_smr_eev pay_element_entry_values_f.screen_entry_value%type;
  l_mr_o_eev pay_element_entry_values_f.screen_entry_value%type;
  l_smr_o_eev pay_element_entry_values_f.screen_entry_value%type;
  l_exp_mr_eev pay_element_entry_values_f.screen_entry_value%type;
  l_exp_smr_eev pay_element_entry_values_f.screen_entry_value%type;
  l_exp_mr_o_eev pay_element_entry_values_f.screen_entry_value%type;
  l_exp_smr_o_eev pay_element_entry_values_f.screen_entry_value%type;
--
  l_ovn number;
  l_esd date;
  l_eed date;
  l_warning boolean;
  l_upd varchar2(1) := 'Y';
--
  cursor csr_entry
  is
  select /*+ ORDERED
             USE_NL(PEL, PEE, PEEV)
             INDEX(PEL PAY_ELEMENT_LINKS_F_N7)
             INDEX(PEE PAY_ELEMENT_ENTRIES_F_N51)
             INDEX(PEEV PAY_ELEMENT_ENTRY_VALUES_F_N50) */
         pee.element_entry_id,
         pee.effective_start_date,
         pee.effective_end_date,
         pee.object_version_number,
         peev.input_value_id,
         peev.screen_entry_value
  from   pay_element_links_f        pel,
         pay_element_entries_f      pee,
         pay_element_entry_values_f peev
  where  pel.element_type_id = c_com_hi_smr_elm_id
  and    pel.business_group_id + 0 = p_business_group_id
  and    p_session_date
         between pel.effective_start_date and pel.effective_end_date
  and    pee.assignment_id = p_assignment_id
  and    pee.element_link_id = pel.element_link_id
  and    p_session_date
         between pee.effective_start_date and pee.effective_end_date
  and    pee.entry_type = 'E'
  and    peev.element_entry_id = pee.element_entry_id
  and    peev.effective_start_date = pee.effective_start_date
  and    peev.effective_end_date = pee.effective_end_date
  for update of peev.element_entry_value_id nowait;
--
  l_csr_entry csr_entry%rowtype;
--
begin
--
  if g_detail_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace(p_business_group_id ||' : '||p_assignment_id||'('||p_assignment_number||')');
  end if;
--
  open csr_entry;
  loop
  --
    fetch csr_entry into l_csr_entry;
    exit when csr_entry%notfound;
  --
    if l_csr_entry.input_value_id = c_smr_iv_id then
    --
      l_smr_eev := l_csr_entry.screen_entry_value;
    --
    elsif l_csr_entry.input_value_id = c_smr_o_iv_id then
    --
      l_smr_o_eev := l_csr_entry.screen_entry_value;
    --
    elsif l_csr_entry.input_value_id = c_mr_iv_id then
    --
      l_mr_eev := l_csr_entry.screen_entry_value;
    --
    elsif l_csr_entry.input_value_id = c_mr_o_iv_id then
    --
      l_mr_o_eev := l_csr_entry.screen_entry_value;
    --
    end if;
  --
  end loop;
  close csr_entry;
--
  if g_detail_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('l_smr_eev : '||l_smr_eev||', l_smr_o_eev : '||l_smr_o_eev||', l_mr_eev : '||l_mr_eev||', l_mr_o_eev : '||l_mr_o_eev);
  end if;
--
  if p_hi_mr is not null then
  --
    l_exp_mr_eev := p_hi_mr;
  --
  else
  --
    l_exp_mr_eev := l_mr_eev;
  --
  end if;
--
  l_exp_smr_eev := substrb(ltrim(rtrim(hruserdt.get_table_value(
                     p_bus_group_id   => p_business_group_id,
                     p_table_name     => c_com_smr_tbl,
                     p_col_name       => c_hi_smr_col,
                     p_row_value      => l_exp_mr_eev,
                     p_effective_date => p_session_date))),0,60);
--
  if g_detail_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('l_exp_mr_eev : '||l_exp_mr_eev||', l_exp_smr_eev : '||l_exp_smr_eev);
  end if;
--
  if g_exc_match_exp_smr = 'Y' then
  --
    if l_smr_eev = l_exp_smr_eev then
    --
      l_upd := 'N';
    --
    end if;
  --
  end if;
--
  if g_upd_mode = 'OVERRIDE' then
  --
    l_exp_smr_o_eev := l_smr_o_eev;
    l_exp_mr_o_eev  := l_mr_o_eev;
  --
  else
  --
    l_exp_smr_o_eev := l_smr_eev;
    l_exp_mr_o_eev  := l_mr_eev;
  --
  end if;
--
  if g_detail_debug then
    hr_utility.set_location(l_proc,30);
    hr_utility.trace('l_exp_smr_o_eev : '||l_exp_smr_o_eev||', l_exp_mr_o_eev : '||l_exp_mr_o_eev);
  end if;
--
  l_ovn := l_csr_entry.object_version_number;
--
  if l_upd = 'Y' then
  --
    if g_valid = 'N' then
    --
      pay_element_entry_api.update_element_entry(
        p_validate              => false,
        p_effective_date        => p_session_date,
        p_business_group_id     => p_business_group_id,
        p_datetrack_update_mode => 'UPDATE',
        p_element_entry_id      => l_csr_entry.element_entry_id,
        p_object_version_number => l_ovn,
        p_input_value_id1       => c_am_iv_id,
        p_input_value_id2       => c_smr_iv_id,
        p_input_value_id3       => c_smr_o_iv_id,
        p_input_value_id4       => c_at_iv_id,
        p_input_value_id5       => c_mr_iv_id,
        p_input_value_id6       => c_mr_o_iv_id,
        p_entry_value1          => to_char(p_session_date,'YYYYMM'),
        p_entry_value2          => l_exp_smr_eev,
        p_entry_value3          => l_exp_smr_o_eev,
        p_entry_value4          => 'O',
        p_entry_value5          => l_exp_mr_eev,
        p_entry_value6          => l_exp_mr_o_eev,
        p_effective_start_date  => l_esd,
        p_effective_end_date    => l_eed,
        p_update_warning        => l_warning);
    --
      if g_detail_debug then
        hr_utility.set_location(l_proc,40);
      end if;
    --
    end if;
  --
    if g_sql_run = 'Y' then
    --
      if g_log = 'Y' then
      --
        hr_utility.trace(rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||'   '||lpad(l_exp_mr_eev,10)||' '||lpad(nvl(l_smr_eev,' '),10)||' '||lpad(l_exp_smr_eev,10));
      --
      end if;
    --
    else
    --
      fnd_file.put_line(fnd_file.output, rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||'   '||lpad(l_exp_mr_eev,10)||' '||lpad(nvl(l_smr_eev,' '),10)||' '||lpad(l_exp_smr_eev,10));
    --
    end if;
  --
  else
  --
    if g_sql_run = 'Y' then
    --
      if g_log = 'Y' then
      --
        hr_utility.trace(rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' X '||lpad(l_exp_mr_eev,10)||' '||lpad(nvl(l_smr_eev,' '),10)||' '||lpad(l_exp_smr_eev,10));
      --
      end if;
    --
    else
    --
      fnd_file.put_line(fnd_file.output, rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' X '||lpad(l_exp_mr_eev,10)||' '||lpad(nvl(l_smr_eev,' '),10)||' '||lpad(l_exp_smr_eev,10));
    --
    end if;
  --
    if g_detail_debug then
      hr_utility.set_location(l_proc,45);
    end if;
  --
  end if;
--
  if g_detail_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
when hr_api.object_locked then
--
  if g_debug then
    hr_utility.set_location(l_proc,-1000);
    hr_utility.trace(to_char(p_assignment_id)||':'||fnd_message.get_string('FND','FND_LOCK_RECORD_ERROR'));
  end if;
--
  if g_sql_run = 'Y' then
  --
    if g_log = 'Y' then
    --
      hr_utility.trace(rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||fnd_message.get_string('FND','FND_LOCK_RECORD_ERROR'));
    --
    end if;
  --
  else
  --
    fnd_file.put_line(fnd_file.log, rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||fnd_message.get_string('FND','FND_LOCK_RECORD_ERROR'));
  --
  end if;
--
when others then
--
  if g_debug then
    hr_utility.set_location(l_proc,-1000);
    hr_utility.trace(to_char(p_assignment_id)||':'||get_sqlerrm);
  end if;
--
  if g_sql_run = 'Y' then
  --
    if g_log = 'Y' then
    --
      hr_utility.trace(rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||get_sqlerrm);
    --
    end if;
  --
  else
  --
    fnd_file.put_line(fnd_file.log, rpad(p_business_group_name,30)||' '||rpad(p_assignment_number,30)||' '||get_sqlerrm);
  --
  end if;
--
end mig_smr_assact;
--
-- -------------------------------------------------------------------------
-- run_mig_smr
-- -------------------------------------------------------------------------
-- this is for manual run by script, recommend to use generic upgrade instead of this.
procedure run_mig_smr
is
--
  l_proc varchar2(80) := c_package||'run_mig_smr';
--
  l_range_ass_tbl_cnt number := 0;
  l_qualify_ass_tbl_cnt number := 0;
  l_qualify_valid_update varchar2(1) := 'N';
--
  l_mig_cnt number := 0;
  l_mig_commit_cnt number := 1;
--
  cursor csr_range_ass
  is
  select /*+ ORDERED
             INDEX(PA PER_ASSIGNMENTS_F_FK1) */
         pbg.business_group_id,
         pbg.name bg_name,
         pa.assignment_id,
         pa.assignment_number
  from   per_business_groups_perf pbg,
         per_all_assignments_f pa
  where  pbg.legislation_code = g_legislation_code
  and    pa.business_group_id = pbg.business_group_id
  and    pa.effective_start_date = (
           select /*+ INDEX(PA2 PER_ASSIGNMENTS_F_PK) */
                  max(pa2.effective_start_date)
           from   per_all_assignments_f pa2
           where  pa2.assignment_id = pa.assignment_id);
--
  l_csr_range_ass csr_range_ass%rowtype;
--
begin
--
-- --
-- init
-- --
--
  g_sql_run := 'Y';
--
  if g_sql_run = 'Y'
  and g_log = 'Y' then
    g_debug := false;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  if g_skip_qualify is null then
    g_skip_qualify := 'N';
  end if;
--
  if g_upd_mode is null then
    g_upd_mode := 'UPDATE';
  end if;
--
  if g_mig_date is null then
    g_mig_date:= c_mig_smr_sd;
  end if;
--
  -- can set g_range_ass_hi_smr_tbl by out of this procedure
  -- in case g_legislation_code is set.
  if g_legislation_code is null
  or g_legislation_code <> c_legislation_code then
  --
    g_range_ass_hi_smr_tbl.delete;
    g_legislation_code := c_legislation_code;
  --
  end if;
--
  g_dml_num := null;
  g_qualify_hi_smr_ass_tbl.delete;
  l_range_ass_tbl_cnt := g_range_ass_hi_smr_tbl.count;
--
  set_hi_smr_id;
  set_hi_smr_mesg;
--
  -- for api use
  insert_session(g_mig_date);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
-- --
-- range
-- --
--
  if l_range_ass_tbl_cnt = 0 then
  --
    open csr_range_ass;
    loop
    --
      fetch csr_range_ass into l_csr_range_ass;
      exit when csr_range_ass%notfound;
    --
      g_range_ass_hi_smr_tbl(l_range_ass_tbl_cnt).bg_id    := l_csr_range_ass.business_group_id;
      g_range_ass_hi_smr_tbl(l_range_ass_tbl_cnt).bg_name  := l_csr_range_ass.bg_name;
      g_range_ass_hi_smr_tbl(l_range_ass_tbl_cnt).ass_id   := l_csr_range_ass.assignment_id;
      g_range_ass_hi_smr_tbl(l_range_ass_tbl_cnt).ass_num  := l_csr_range_ass.assignment_number;
      g_range_ass_hi_smr_tbl(l_range_ass_tbl_cnt).del_done := 'N';
    --
      l_range_ass_tbl_cnt := l_range_ass_tbl_cnt + 1;
    --
    end loop;
    close csr_range_ass;
  --
  end if;
--
  if g_debug then
  --
    hr_utility.set_location(l_proc,15);
    hr_utility.trace('g_range_ass_hi_smr_tbl.count : '||to_char(g_range_ass_hi_smr_tbl.count));
  --
    if g_range_ass_hi_smr_tbl.count > 0 then
    --
      for i in 0..g_range_ass_hi_smr_tbl.count - 1 loop
      --
        if g_detail_debug then
        --
          hr_utility.trace(to_char(g_range_ass_hi_smr_tbl(i).bg_id)
            ||':'||g_range_ass_hi_smr_tbl(i).ass_num
            ||'('||to_char(g_range_ass_hi_smr_tbl(i).ass_id)
            ||').'||g_range_ass_hi_smr_tbl(i).del_done);
        --
        end if;
      --
      end loop;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
  end if;
--
-- --
-- qualify
-- --
--
  if g_log = 'Y' then
  --
    hr_utility.trace('Business Group Name            Assignment Number              Message');
    hr_utility.trace('------------------------------ ------------------------------ --------------------------------------------------------------------------------');
  --
  end if;
--
  if g_skip_qualify = 'N' then
  --
    if g_range_ass_hi_smr_tbl.count > 0 then
    --
      for j in 0..g_range_ass_hi_smr_tbl.count - 1 loop
      --
        val_mig_smr_assact(
          p_business_group_id   => g_range_ass_hi_smr_tbl(j).bg_id,
          p_business_group_name => g_range_ass_hi_smr_tbl(j).bg_name,
          p_assignment_id       => g_range_ass_hi_smr_tbl(j).ass_id,
          p_assignment_number   => g_range_ass_hi_smr_tbl(j).ass_num,
          p_session_date        => g_mig_date,
          p_valid_delete        => g_range_ass_hi_smr_tbl(j).del_done);
      --
        if l_qualify_valid_update = 'N'
        and g_range_ass_hi_smr_tbl(j).del_done = 'Y' then
          l_qualify_valid_update := 'Y';
        end if;
      --
      end loop;
    --
    end if;
  --
  else
  --
    l_qualify_valid_update := 'Y';
  --
  end if;
--
  if l_qualify_valid_update = 'Y' then
  --
    if g_range_ass_hi_smr_tbl.count > 0 then
    --
      for k in 0..g_range_ass_hi_smr_tbl.count - 1 loop
      --
        if g_range_ass_hi_smr_tbl(k).del_done = 'Y'
        or g_skip_qualify = 'Y' then
        --
          g_qualify_hi_smr_ass_tbl(l_qualify_ass_tbl_cnt).bg_id    := g_range_ass_hi_smr_tbl(k).bg_id;
          g_qualify_hi_smr_ass_tbl(l_qualify_ass_tbl_cnt).bg_name  := g_range_ass_hi_smr_tbl(k).bg_name;
          g_qualify_hi_smr_ass_tbl(l_qualify_ass_tbl_cnt).ass_id   := g_range_ass_hi_smr_tbl(k).ass_id;
          g_qualify_hi_smr_ass_tbl(l_qualify_ass_tbl_cnt).ass_num  := g_range_ass_hi_smr_tbl(k).ass_num;
          g_qualify_hi_smr_ass_tbl(l_qualify_ass_tbl_cnt).del_done := 'N';
          g_qualify_hi_smr_ass_tbl(l_qualify_ass_tbl_cnt).hi_mr    := g_range_ass_hi_smr_tbl(k).hi_mr;
        --
          l_qualify_ass_tbl_cnt := l_qualify_ass_tbl_cnt + 1;
        --
        end if;
      --
      end loop;
    --
    end if;
  --
    if g_debug then
    --
      if g_qualify_hi_smr_ass_tbl.count > 0 then
      --
        for l in 0..g_qualify_hi_smr_ass_tbl.count - 1 loop
        --
          if g_detail_debug then
          --
            hr_utility.trace(to_char(g_qualify_hi_smr_ass_tbl(l).bg_id)
              ||':'||g_qualify_hi_smr_ass_tbl(l).ass_num
              ||'('||to_char(g_qualify_hi_smr_ass_tbl(l).ass_id)
              ||').'||g_qualify_hi_smr_ass_tbl(l).del_done);
          --
          end if;
        --
        end loop;
      --
      end if;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,30);
  end if;
--
-- --
-- upgrade
-- --
--
  if g_log = 'Y' then
  --
    hr_utility.trace('----------------------------------------------------------------------------------------------------------------------------------------------');
    hr_utility.trace('Business Group Name            Assignment Number              E         MR        SMR    Exp SMR');
    hr_utility.trace('------------------------------ ------------------------------ - ---------- ---------- ----------');
  --
  end if;
--
  if l_qualify_valid_update = 'Y' then
  --
    if g_qualify_hi_smr_ass_tbl.count > 0 then
    --
      for m in 0..g_qualify_hi_smr_ass_tbl.count - 1 loop
      --
        mig_smr_assact(
          p_business_group_id   => g_qualify_hi_smr_ass_tbl(m).bg_id,
          p_business_group_name => g_qualify_hi_smr_ass_tbl(m).bg_name,
          p_assignment_id       => g_qualify_hi_smr_ass_tbl(m).ass_id,
          p_assignment_number   => g_qualify_hi_smr_ass_tbl(m).ass_num,
          p_session_date        => g_mig_date,
          p_hi_mr               => g_qualify_hi_smr_ass_tbl(m).hi_mr);
      --
        l_mig_cnt := l_mig_cnt + 1;
      --
        if g_sql_run = 'Y' then
        --
          g_dml_num := g_dml_num + (l_mig_cnt - c_commit_num * (l_mig_commit_cnt - 1));
        --
          if g_dml_num > c_commit_num then
            commit;
            g_dml_num := 0;
            l_mig_commit_cnt := l_mig_commit_cnt + 1;
          end if;
        --
        end if;
      --
      end loop;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,40);
  end if;
--
-- --
-- deinitialize
-- --
--
  if g_log = 'Y' then
  --
    hr_utility.trace('----------------------------------------------------------------------------------------------------------------------------------------------');
  --
  end if;
--
  delete_session;
--
  if l_qualify_valid_update = 'Y' then
  --
    commit;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end run_mig_smr;
--
END HR_JP_DATA_MIGRATION_PKG;
--

/
