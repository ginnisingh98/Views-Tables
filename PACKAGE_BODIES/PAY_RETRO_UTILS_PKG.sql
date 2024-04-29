--------------------------------------------------------
--  DDL for Package Body PAY_RETRO_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RETRO_UTILS_PKG" as
/* $Header: pyretutl.pkb 120.8.12010000.3 2010/03/18 05:54:39 pgongada ship $ */

------------------------------------------------------------------------------
--GLOBALS
--
g_itemkey wf_items.item_key%type;
g_package   varchar2(80) := 'PAY_RETRO_UTILS_PKG.';

--g_transaction_id hr_wip_transactions.transaction_id%type;
--g_transaction_mode hr_wip_transactions.dml_mode%type;

-- GLOBAL NAMES OF ITEMS USED IN PAYRETRO WF file pyretwf
--
gn_cand_asg_list      varchar2(240):= 'ASG_CAND_LIST';
gn_event_id           varchar2(30) := 'EVENT_ID';
gn_chg_date           varchar2(30) := 'CHG_DATE';
gn_retro_sched_date   varchar2(30) := 'RETROPAY_PERFORM_DATE';
gn_change_desc        varchar2(30) := 'CHANGE_DESCRIPTION';
an_event_id    varchar2(30) := 'EVENT_ID';
an_user        varchar2(30) := 'USER';
an_retro_asg_nums varchar2(30) := 'RETRO_ASG_NUMS';
an_col         varchar2(30) := 'UPD_COL';
an_tab         varchar2(30) := 'UPD_TAB';
an_asg_id      varchar2(30) := 'ASG_ID';
an_mst_asg_list    varchar2(30) := 'MST_ASG_LIST';
an_bg_id           varchar2(30) := 'BG_ID';

g_asg_id           number := null;
g_leg_code         varchar2(15) := null;
g_bus_grp          varchar2(15) := null;
g_legrul_value_out varchar2(40);
g_ee_id            number := null;
g_et_id            number := null;
g_ef_date          date;
g_rbus_grp         varchar2(15);
g_retro_comp_id    number;

------------------------------------------------------------------------------
  Type g_temp_tab_type is table of number index by binary_integer;
  g_temp_tab g_temp_tab_type;

  --SUB FUNCTION, turn input comma-delimeted list in to table
   FUNCTION string_to_table ( id_list IN VARCHAR2)
     RETURN g_temp_tab_type
   IS
    i                  NUMBER := 1;
    l_value            VARCHAR2(100) :='';
    l_pos_of_ith_comma NUMBER := -1;
    l_pos_last_comma   NUMBER := 0;
    l_temp_table       g_temp_tab_type;

   BEGIN
     <<next_comma_loop>>
     WHILE l_pos_of_ith_comma <> 0
     LOOP
       l_pos_of_ith_comma := nvl(instr(id_list,',',1,i),0);

       -- Take substring between commas or to end if no last comma
       if (l_pos_of_ith_comma <> 0) then
         l_value := SUBSTR(id_list,l_pos_last_comma +1,
                                   l_pos_of_ith_comma - l_pos_last_comma -1 );
       else l_value := SUBSTR(id_list,l_pos_last_comma +1);
       end if;
       l_temp_table(i) := to_number(l_value);
       l_pos_last_comma := l_pos_of_ith_comma;
       i := i + 1;

       l_pos_last_comma := l_pos_of_ith_comma;
     END LOOP next_comma_loop;
     RETURN l_temp_table;

   END string_to_table;

-------------------------------------------------------------------------------
-- UTILITY PROCEDURES
-------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
--     retro_ent_tab_insert                                                  --
--     This procedure populates the retro_entries table                      --
--     Mostly called from populate_retro_tables procedure                    --
--                                                                           --
-- ----------------------------------------------------------------------------
--
/*
  Procedure retro_ent_tab_insert(
          p_retro_assignment_id    IN NUMBER
  ,       p_element_entry_id       IN NUMBER
  ,       p_reprocess_date         IN DATE
  ,       p_eff_date               IN DATE) is
  --
    l_retro_component_id  NUMBER;
    l_proc varchar2(80) := g_package||'.retro_ent_tab_insert';

  Begin
    hr_utility.set_location(l_proc,10);


    l_retro_component_id := get_retro_component_id(
                 p_element_entry_id,
                 p_eff_date);

    hr_utility.set_location(l_proc,20);
    --
    INSERT INTO pay_retro_entries
    (        retro_assignment_id
    ,        element_entry_id
    ,        reprocess_date
    ,        effective_date
    ,        retro_component_id
    )
    VALUES
    (        p_retro_assignment_id
    ,        p_element_entry_id
    ,        p_reprocess_date
    ,        p_eff_date
    ,        l_retro_component_id
    );
  --

    hr_utility.set_location(l_proc,900);
  End retro_ent_tab_insert;
*/

-- ----------------------------------------------------------------------------
--     get_creation_status                                                  --
--     This procedure gets the status value to assign to the newly created  --
--     retro_assignment.                                                    --
--                                                                           --
-- ----------------------------------------------------------------------------
--
  FUNCTION get_creation_status(
         p_payroll_id            IN NUMBER ) return varchar2 is
  --
  l_proc varchar2(30) := 'get_creation_status';
  l_creation_status varchar2(15) := 'A'; --dflt auto-included in next RetroPay run
  begin
      hr_utility.set_location('Entering '||l_proc, 10);
	  return l_creation_status;
  END get_creation_status;

-- ----------------------------------------------------------------------------
--     retro_asg_tab_insert                                                  --
--     This procedure populates the retro_assignments table                  --
--     Mostly called from maintain_retro_asg procedure                    --
--                                                                           --
-- ----------------------------------------------------------------------------
--
  Procedure retro_asg_tab_insert(
          p_assignment_id         IN NUMBER
  ,       p_payroll_id            IN NUMBER
  ,       p_reprocess_date        IN DATE
  ,       p_start_date            IN DATE
  ,       p_retro_assignment_id   OUT nocopy NUMBER) is
  --
  l_proc varchar2(30) := 'retro_asg_tab_insert';
  l_creation_status varchar2(15);
  Begin
  --
    hr_utility.set_location(l_proc,10);
    select pay_retro_assignments_s.nextval
      into p_retro_assignment_id
    from sys.dual;
    --
    l_creation_status := get_creation_status(p_payroll_id);

    INSERT INTO pay_retro_assignments
    (        retro_assignment_id
    ,        assignment_id
    ,        reprocess_date
    ,        start_date
    ,        approval_status
    ,        retro_assignment_action_id
    )
    VALUES
    (        p_retro_assignment_id
    ,        p_assignment_id
    ,        p_reprocess_date
    ,        p_start_date
    ,        l_creation_status
    ,        null
    );
  --
    hr_utility.set_location(l_proc,900);
  End retro_asg_tab_insert;

--
-- ----------------------------------------------------------------------------
--     create_super_retro_asg
--     This procedure populates the retro_assignments table                  --
--     This creates a superceding Retro Assignment (if needed)               --
--                                                                           --
-- ----------------------------------------------------------------------------
  procedure create_super_retro_asg(p_asg_id           IN NUMBER
                                  ,p_payroll_id       IN NUMBER
                                  ,p_reprocess_date   IN DATE
                                  ,p_retro_asg_id       OUT nocopy NUMBER)
  is
  Cursor c_retro_asg (cp_asg NUMBER,
                      p_ret_asg_id number) is
   SELECT
          pra.start_date
         ,pra.retro_assignment_id ret_asg_id
         ,pra.created_by
   FROM   pay_retro_assignments  pra
   WHERE  pra.assignment_id = cp_asg
   AND    pra.retro_assignment_action_id is null
   AND    pra.superseding_retro_asg_id is null
   AND    pra.retro_assignment_id <> p_ret_asg_id
   AND    approval_status in ('P','A','D');
--
   cursor get_unproc(p_ret_asg_id in number)
   is
   select pra.retro_assignment_id,
          pre.element_entry_id,
          pre.element_type_id,
          pre.reprocess_date,
          pre.effective_date,
          pre.retro_component_id,
          pre.owner_type,
          pre.system_reprocess_date,
          pre.created_by
     from pay_retro_assignments pra,
          pay_retro_entries     pre
    where pra.retro_assignment_id = p_ret_asg_id
      and pra.retro_assignment_id = pre.retro_assignment_id;
--
    l_ret_asg_id number;
    l_min_reprocess_date date;
    l_created_by         number;
  begin
--
     l_min_reprocess_date := p_reprocess_date;
--
     retro_asg_tab_insert(
                       p_assignment_id         => p_asg_id
               ,       p_payroll_id            => p_payroll_id
               ,       p_reprocess_date        => p_reprocess_date
               ,       p_start_date            => hr_api.g_eot
               ,       p_retro_assignment_id   => l_ret_asg_id);
--
     for rarec in c_retro_asg(p_asg_id, l_ret_asg_id) loop
        update pay_retro_assignments
           set superseding_retro_asg_id = l_ret_asg_id
         where retro_assignment_id = rarec.ret_asg_id;
--
        update pay_retro_assignments
           set start_date = rarec.start_date
          where retro_assignment_id = l_ret_asg_id;
--
        for unprocrec in get_unproc(rarec.ret_asg_id) loop
--
--          Either update or insert rows to represent those that
--          exist on our unproc RA.
            pay_retro_pkg.maintain_retro_entry(l_ret_asg_id,
                                 unprocrec.element_entry_id,
                                 unprocrec.element_type_id,
                                 unprocrec.reprocess_date,
                                 unprocrec.effective_date,
                                 unprocrec.retro_component_id,
                                 unprocrec.owner_type,
                                 unprocrec.system_reprocess_date
                                );
             -- inherit created_by.
             update pay_retro_entries
             set created_by = unprocrec.created_by
             where retro_assignment_id = l_ret_asg_id
             and element_entry_id = unprocrec.element_entry_id;
             --
             l_min_reprocess_date := least(l_min_reprocess_date,
                                         unprocrec.reprocess_date);
--
          end loop;
        -- remember created_by.
        l_created_by := rarec.created_by;
     end loop;

     -- currently created_by is referred by the UI to
     -- distinguish the system created record, hence
     -- it has to be inherited.
     update pay_retro_assignments
        set reprocess_date = l_min_reprocess_date
           ,created_by = nvl(l_created_by, created_by)
      where retro_assignment_id = l_ret_asg_id;
--
     --
     -- Set out variable.
     --
     p_retro_asg_id := l_ret_asg_id;
--
  end create_super_retro_asg;
-- ----------------------------------------------------------------------------
--     maintain_retro_asg
--     This procedure populates the retro_assignments table                  --
--     The reason it is in a different procedure is that it is called from   --
--     both the event driven retro-notification and the SRS version          --
--     The method to expunge an existing row may change thus creating an     --
--     archive for retro-asg                                                 --
--                                                                           --
-- ----------------------------------------------------------------------------
--

Procedure  maintain_retro_asg(
                   p_asg_id     IN NUMBER
                  ,p_payroll_id IN NUMBER
                  ,p_min_date   IN DATE
                  ,p_eff_date   IN DATE
                  ,p_retro_asg_id OUT nocopy NUMBER) IS


  Cursor c_retro_asg (cp_asg NUMBER) is
   SELECT
          pra.start_date
         ,pra.retro_assignment_id ret_asg_id
   FROM   pay_retro_assignments  pra
   WHERE  pra.assignment_id = cp_asg
   AND    pra.retro_assignment_action_id is null
   AND    pra.superseding_retro_asg_id is null
   AND    approval_status in ('P','A','D');


  l_ret_asg_id   NUMBER;

  l_proc varchar2(80) := g_package||'.maintain_retro_asg';

BEGIN
   hr_utility.set_location(l_proc,10);

  for exist_retro_asg in c_retro_asg(p_asg_id) loop
    --just one row, but fetch neatly
    --
    l_ret_asg_id    := exist_retro_asg.ret_asg_id;

     -- Make sure status is back to unApproved
    hr_utility.trace('+ RetroAsg exists so update, retro-asg = '||l_ret_asg_id);
    update PAY_RETRO_ASSIGNMENTS
    set    APPROVAL_STATUS = 'P'
    where  ASSIGNMENT_ID   = p_asg_id
    /*Bug#8306525*/
    and    RETRO_ASSIGNMENT_ACTION_ID IS NULL;


    -- Delete any system retro-element records as were about to repopulate
    delete from PAY_RETRO_ENTRIES
    where  RETRO_ASSIGNMENT_ID = exist_retro_asg.ret_asg_id
    and    owner_type = 'S';

  end loop;

  if l_ret_asg_id is null then --There was no record for this asg

    -- Create our retro_asg row
    retro_asg_tab_insert(
        p_assignment_id        => p_asg_id
       ,p_payroll_id           => p_payroll_id
       ,p_reprocess_date       => p_eff_date -- overriden after child
                                 -- entries are created in pay_retro_notif
       ,p_start_date           => p_min_date
       ,p_retro_assignment_id  => l_ret_asg_id);

  end if;

  p_retro_asg_id := l_ret_asg_id;
  hr_utility.set_location(l_proc,900);

end maintain_retro_asg;

--
-- ----------------------------------------------------------------------------
--                                                                           --
--   get_user                                                                --
--     This Procedure is called from workflow to derive the user that caused --
--     the Retro-Assignments to be created.                                  --
--                                                                           --
-- resultout : not required
-- ----------------------------------------------------------------------------
--
PROCEDURE get_user (itemtype in varchar2,
                    itemkey in varchar2,
                    actid in number,
                    funcmode in varchar2,
                    resultout out nocopy varchar2) is
--

cursor csr_usr_name (cp_usr_id number) is
         select user_name
         from fnd_user
         where user_id = cp_usr_id
         and sysdate between start_date and nvl(end_date,hr_api.g_eot);

cursor csr_upd_row_info (cp_ppe_id number) is
     select pdt.table_name,peu.column_name,
            pdt.start_date_name,pdt.end_date_name,
            pdt.surrogate_key_name,ppe.surrogate_key,ppe.effective_date
     from pay_process_events ppe
         ,Pay_event_updates  peu
         ,pay_dated_tables   pdt
     where ppe.process_event_id = cp_ppe_id
     and   ppe.event_update_id = peu.event_update_id
     and   peu.dated_table_id = pdt.dated_table_id;

  l_ppe_id    pay_process_events.process_event_id%type;
  l_usr_id   fnd_user.user_id%type;
  l_user      fnd_user.user_name%type := 'ANONYMOUS';
  l_statement varchar2(2000);

  l_table_name  varchar2(80);
  l_column_name varchar2(80);
  l_sd_name     varchar2(80);
  l_ed_name     varchar2(80);
  l_surr_key_name varchar2(80);
  l_surr_key    varchar2(80);
  l_eff_date    date;
  --
BEGIN

--
  l_ppe_id := wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => an_event_id);


  open  csr_upd_row_info(l_ppe_id);
  fetch csr_upd_row_info into l_table_name,l_column_name,l_sd_name,l_ed_name,
                              l_surr_key_name,l_surr_key,l_eff_date;
  close csr_upd_row_info;
  --
  l_statement   := 'SELECT last_updated_by'  ||
                   '  FROM ' || l_table_name ||
                   ' WHERE ' || l_surr_key_name || ' = '||l_surr_key||
                   ' AND   ' || 'to_date('''||
                        to_char(l_eff_date,'DD-MON-RR')
                                            ||''',''DD-MON-RR'') '
                      || ' BETWEEN ' || l_sd_name || ' AND ' || l_ed_name ;
  hr_utility.trace('Col getting Statement ' || l_statement);

  wf_engine.setItemAttrText
            (itemtype => itemtype,
             itemkey  => itemkey,
             aname    => an_retro_asg_nums,
             aValue   => l_ppe_id||' <- ->'||l_column_name);
  --execute immediate 'select 1 from dual' into l_usr_id;

  execute immediate l_statement  into l_usr_id;

  if (l_usr_id is not null and l_usr_id <> -1) then
    open  csr_usr_name(l_usr_id);
    fetch csr_usr_name into l_user;
    close csr_usr_name;
  end if;
  hr_utility.trace('User ID, Name: '||l_usr_id||', '||l_user);

  wf_engine.setItemAttrText
            (itemtype => itemtype,
             itemkey  => itemkey,
             aname    => an_user,
             aValue   => l_user);

  wf_engine.setItemAttrText
            (itemtype => itemtype,
             itemkey  => itemkey,
             aname    => an_tab,
             aValue   => l_table_name);

  wf_engine.setItemAttrText
            (itemtype => itemtype,
             itemkey  => itemkey,
             aname    => an_col,
             aValue   => l_column_name);

  return;

END get_user;


--
-- ----------------------------------------------------------------------------
--                                                                           --
--   cc_reqd                                                       --
--     This Procedure is called from workflow to run the cc process to mark  --
--     asg for retry, eg event has changed something but no retro-asg created --
--                                                                           --
-- resultout : Yes or No
-- ----------------------------------------------------------------------------
--
PROCEDURE cc_reqd (itemtype in varchar2,
                          itemkey in varchar2,
                          actid in number,
                          funcmode in varchar2,
                          resultout out nocopy varchar2) is
--
begin

  resultout := 'COMPLETE:Y';
  return;
end cc_reqd;


PROCEDURE is_retropay_scheduled (itemtype in varchar2,
                          itemkey in varchar2,
                          actid in number,
                          funcmode in varchar2,
                          resultout out nocopy varchar2) is
--
  l_proc      varchar2(80) := 'is_retropay_scheduled';
  l_schedule_date   date;
  r_itemtype  varchar2(30) := 'PYRETRO';
  r_itemkey   varchar2(30);

cursor csr_retro_scheduled is
  select item_key from wf_items
    where item_type = 'PYRETRO'
  and root_activity = 'PAY_RETROPAY'
  AND end_date is null;

begin

 hr_utility.set_location(g_package||l_proc,10);
  open csr_retro_scheduled;
  fetch csr_retro_scheduled into r_itemkey;
  close csr_retro_scheduled;

  if (r_itemkey is null) then --not currently scheduled
    resultout := 'COMPLETE:N';
  else
    resultout := 'COMPLETE:Y';
  end if;

 hr_utility.set_location(g_package||l_proc,900);
  return;
end is_retropay_scheduled;


--
-- ----------------------------------------------------------------------------
--                                                                           --
--   cc_perform                                                              --
--     This Procedure is called from workflow to run the cc process to mark  --
--     asg for retry, eg event has changed something but no retro-asg created --
--                                                                           --
-- resultout : not required
-- ----------------------------------------------------------------------------
--
PROCEDURE cc_perform (itemtype in varchar2,
                          itemkey in varchar2,
                          actid in number,
                          funcmode in varchar2,
                          resultout out nocopy varchar2) is
--
begin

  null;

end cc_perform;

--
-- ----------------------------------------------------------------------------
--                                                                           --
--   get_retro_component_id                                                              --
--     This Function is called during the process to insert the retro_entry --
--   A "Recalculation Reason" (or Retro-Component) is need to associate with --
--   the entry details.  EG What kind of change has required this entry to be--
--   recalculated
--
--   Result: An ID of the seeded retro_component
-- ----------------------------------------------------------------------------
--
FUNCTION get_retro_component_id (
                          p_element_entry_id  in number,
                          p_ef_date           in date,
                          p_element_type_id   in number,
                          p_asg_id            in number default NULL) return number IS

  -- Select the default component stored against this element type
  -- (standard method of getting retro_component_id)
  --

   cursor csr_get_default_id (cp_et_id in number,
                              cp_ef_date in date,
                              cp_bus_grp in number,
                              cp_leg_code in varchar2) is
   select prcu.retro_component_id
    from
      pay_retro_component_usages prcu
   where prcu.creator_id = cp_et_id
   and   prcu.creator_type   = 'ET'
   and  prcu.default_component = 'Y'
   and  ((    prcu.business_group_id = cp_bus_grp
          and prcu.legislation_code is null)
         or
         (    prcu.legislation_code = cp_leg_code
          and prcu.business_group_id is null)
         or
         (    prcu.legislation_code is null
          and prcu.business_group_id is null)
        );

  cursor csr_get_asg_id (cp_ee_id in number) IS
  select distinct pee.assignment_id
    from pay_element_entries_f    pee
   where pee.element_entry_id = p_element_entry_id;

  cursor csr_get_bg_id (cp_asg_id in number) IS
  select distinct paf.business_group_id
    from per_all_assignments_f    paf
   where paf.assignment_id = cp_asg_id;

  cursor csr_get_leg_code (cp_bg_id in number) IS
  select pbg.legislation_code
    from per_business_groups_perf pbg
   where pbg.business_group_id = cp_bg_id;

 l_legrul_name      varchar2(40) :=  'RETRO_COMP_DFLT_OVERRIDE';
 l_asg_id           number;
 l_leg_code         varchar2(15);
 l_bus_grp          varchar2(15);
 l_legrul_value_out varchar2(40);
 l_found_out        boolean;

 l_retro_comp_id    number := -1;
 l_sql              varchar2(240);

BEGIN
  -- The standard way of obtaining the retro-component_id is to look for
  -- the default value that has been seeded against the element_type.
  -- If legislations require an alternate method, they can write their own
  -- procedure, and put a row in pay_legislative pointing at it
  --

  --Get Asg_id
  --
  if p_asg_id is not NULL then
     l_asg_id := p_asg_id;
  else
     OPEN csr_get_asg_id(p_element_entry_id);
     FETCH csr_get_asg_id INTO l_asg_id;
     CLOSE csr_get_asg_id;
  end if;

  if (g_asg_id is not null and
      l_asg_id = g_asg_id) then
     l_leg_code := g_leg_code;
     l_bus_grp := g_bus_grp;
     l_legrul_value_out := g_legrul_value_out;

  else
     g_asg_id := l_asg_id;

     --Get Bg_id
     --
     OPEN csr_get_bg_id(l_asg_id);
     FETCH csr_get_bg_id INTO l_bus_grp;
     CLOSE csr_get_bg_id;

     if (g_bus_grp is not null and
         l_bus_grp = g_bus_grp) then
        l_leg_code := g_leg_code;
        l_legrul_value_out := g_legrul_value_out;
     else
        g_bus_grp := l_bus_grp;

        --Get Legislation code
        --
        OPEN csr_get_leg_code(l_bus_grp);
        FETCH csr_get_leg_code INTO l_leg_code;
        CLOSE csr_get_leg_code;

        g_leg_code := l_leg_code;

        --Look for legislative override
        pay_core_utils.get_legislation_rule(
                  p_legrul_name  => l_legrul_name
                 ,p_legislation  => l_leg_code
                 ,p_legrul_value => l_legrul_value_out
                 ,p_found        => l_found_out  );

        if (l_found_out) then
           g_legrul_value_out := l_legrul_value_out;
        else
           g_legrul_value_out := 'N';
        end if;

     end if;
  end if;

  if (l_legrul_value_out = 'Y') then
    -- This legislation does not want to use the seeded default component id
    -- but must have delivered an alternate procedure to return the id
    -- eg PAY_NL_RULES.get_retro_component_id

    if (g_ee_id is not null and
        p_element_type_id = g_ee_id) then
       l_retro_comp_id := g_retro_comp_id;
    else

       --build up sql string
       l_sql := 'begin PAY_'||l_leg_code||'_RULES.get_retro_component_id( p_ee_id  =>  :l_ee_id'||
                         ', p_element_type_id     =>  :p_et_id'||
                         ', p_retro_component_id  =>  :l_rc_id'||
                         ');  end;' ;

       hr_utility.trace(l_sql);
       execute immediate (l_sql)
       using in p_element_entry_id, in p_element_type_id, in out l_retro_comp_id;

       g_ee_id := p_element_type_id;
       g_retro_comp_id := l_retro_comp_id;
     end if;

  else
    --Use the original method

     if (g_et_id is not null and
         p_element_type_id = g_et_id and
         p_ef_date = g_ef_date and
         l_bus_grp = g_rbus_grp) then
       l_retro_comp_id := g_retro_comp_id;
     else

        open  csr_get_default_id(p_element_type_id,p_ef_date, l_bus_grp, l_leg_code);
        fetch csr_get_default_id into l_retro_comp_id;
        close csr_get_default_id;

        g_et_id := p_element_type_id;
        g_ef_date := p_ef_date;
        g_rbus_grp := l_bus_grp;
        g_retro_comp_id := l_retro_comp_id;
     end if;
  end if;
  -- hr_utility.trace(' Returned component_id is '||l_retro_comp_id);
  return l_retro_comp_id;
END get_retro_component_id;


END PAY_RETRO_UTILS_PKG;

/
