--------------------------------------------------------
--  DDL for Package Body BEN_ON_LINE_LF_EVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ON_LINE_LF_EVT" AS
/* $Header: benollet.pkb 120.8.12010000.2 2009/03/09 05:00:53 krupani ship $ */
--
g_package varchar2(80) := 'ben_on_line_lf_evt';
g_benefit_action_id    number;
--
PROCEDURE error_simulation is
begin
     fnd_message.set_name('BEN', 'BEN_91009_NAME_NOT_UNIQUE');
     fnd_message.raise_error;
end;

--
-- Procedure
--  Start_on_line_lf_evt_proc
--
-- Description
--  Start the on line life event workflow process for the given p_person_id, p_effective_date and
--      p_business_group_id
--
PROCEDURE Start_on_line_lf_evt_proc( p_person_id            in number,
                                     p_effective_date       in date,
                                     p_business_group_id    in number,
                                     p_error_msg            in varchar2,
                                     p_userkey              in varchar2,
                                     p_itemkey              out nocopy varchar2) is
        --
        l_ItemType  varchar2(30) := 'BEN_OLLE';
        l_ItemKey   varchar2(30) := to_char(p_person_id);
        l_load_form varchar2(100);
        --
        -- 9999Sequence number to append the person_id so that many process instances can be
        -- launched for a single person.
        --
        --  Cursor C_Seq is select ben_on_line_lf_evt_s.nextval from sys.dual;
        --
        Cursor C_Seq is
        select to_char(WF_ERROR_PROCESSES_S.NEXTVAL)
        from SYS.DUAL;
        --
        ItemKey   varchar2(240);
        username    varchar2(50) := fnd_profile.value('USERNAME');
        ItemType  varchar2(30) := 'BEN_OLLE';
        process   varchar2(100) := 'ON_LINE_LIFE_EVENT_PROC';
        l_ben_seq       number;
        l_package       varchar2(80) := g_package||'.Start_on_line_lf_evt_proc';
        --
begin
        --
        hr_utility.set_location ('Entering '||l_package,05);
        --
        --
        -- Generate a new itemkey
        --
        Open C_Seq;
        Fetch C_Seq Into itemkey;
        Close C_Seq;
        --
        -- Create and start the process
        Wf_Engine.CreateProcess(itemtype, itemkey, process);
        Wf_Engine.SetItemUserKey(itemtype, itemkey, p_userkey);
        Wf_Engine.SetItemOwner(itemtype, itemkey, username);
        --
        -- Populate "special" attributes, if they exist
        begin
          Wf_Engine.SetItemAttrText(itemtype, itemkey, 'USER_NAME',
            fnd_profile.value('USERNAME'));
          Wf_Engine.SetItemAttrText(itemtype, itemkey, 'USER_ID',
            fnd_profile.value('USER_ID'));
          Wf_Engine.SetItemAttrText(itemtype, itemkey, 'RESP_ID',
            fnd_profile.value('RESP_ID'));
          Wf_Engine.SetItemAttrText(itemtype, itemkey, 'RESP_APPL_ID',
            fnd_profile.value('RESP_APPL_ID'));
        exception
          when others then
               null;
        end;
        --
        -- Create and set the special mail-suppression itemattr.
        -- This attr prevents mail from being sent to process originator.
        --
        Wf_Engine.AddItemAttr(itemtype, itemkey, '.MAIL_QUERY');
        Wf_Engine.SetItemAttrText(itemtype, itemkey, '.MAIL_QUERY',
            username);
        --
  --
  wf_engine.SetItemAttrText( itemtype => ItemType,
                  itemkey   => Itemkey,
                    aname   => 'PERSON_ID',
                  avalue  => to_char(p_person_id));
        --
  wf_engine.SetItemAttrText(itemtype => itemtype,
          itemkey  => itemkey,
          aname    => 'EFFECTIVE_DATE',
          avalue   => to_char(p_effective_date, 'DD/MM/YYYY'));
        --
  wf_engine.SetItemAttrText(itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'BUSINESS_GROUP_ID',
              avalue   => to_char(p_business_group_id));
        --
  wf_engine.SetItemAttrText(itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'BEN_IA_CONTEXT_SET',
              avalue   => 'Y');
        --
        Wf_Engine.StartProcess(itemtype, itemkey);
        --
        -- Commit work so our lovely new process can start grinding away,
        -- and so the monitor widget can see it.
        commit;
        --
        p_itemkey := itemkey;
        --
        --
        hr_utility.set_location ('Leaving '||l_package,05);
        --
  --
exception
        --
        when others then
          -- The line below records this function call in the error system
          -- in the case of an exception.
          wf_core.context('ben_on_line_lf_evt', 'Start_on_line_lf_evt_proc',
                    itemtype, itemkey); -- ???? add any parameters here.
          raise;
          --
end Start_on_line_lf_evt_proc;
--
--
--
PROCEDURE End_on_line_lf_evt_proc(itemtype  in varchar2,
          itemkey   in varchar2,
          actid         in number,
          funcmode  in varchar2,
          result  in out nocopy varchar2) is
begin
  --
  if funcmode = 'RUN' then
     result := 'COMPLETE:COMPLETED';
     return;
  end if;
  --
  -- Other execution modes may be created in the future.
  -- Activity indicates that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;
  --
exception
  --
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ben_on_line_lf_evt', 'End_on_line_lf_evt_proc',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
end End_on_line_lf_evt_proc;
--
--
procedure Selector(itemtype     in varchar2,
                   itemkey      in varchar2,
                   actid        in number,
                   funcmode     in varchar2,
                   resultout    out nocopy varchar2) is
  --
  l_package       varchar2(80) := g_package||'.Selector';
  --
begin
  --
  --
  hr_utility.set_location ('Entering '||l_package,05);
  --
  --
  if itemtype = 'BEN_OLLE' then
     resultout := 'ON_LINE_LIFE_EVENT_PROC';
  elsif itemtype = 'BENCSRDT' then
     resultout := 'CSR_DESKTOP';
  end if;
  --
  -- RUN mode - normal process execution.
  --
  if (funcmode = 'RUN' ) then
     --
     -- Return process to run
     --
     return;
     --
  end if;
  --
  if (funcmode = 'CANCEL' ) then
     --
     -- Return process to run
     --
     return;
     --
  end if;
  --
  if (funcmode = 'TIMEOUT' ) then
     --
     -- Return process to run
     --
     return;
     --
  end if;
  --
  --
  hr_utility.set_location ('Leaving '||l_package,05);
  --
exception
  --
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ben_on_line_lf_evt', 'Selector',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
end Selector;
--
--
procedure p_cnt_ple(itemtype    in varchar2,
                    itemkey      in varchar2,
                    actid        in number,
                    funcmode     in varchar2,
                    resultout    out nocopy varchar2) is
  --
  --  Variables to store the item attributes values.
  --
  l_person_id           varchar2(50);
  l_effective_date      varchar2(50);
  l_business_group_id   varchar2(50);
  --
  l_pil_count           number  := 0;
  l_ple_count           number  := 0;
  mesg      varchar2(500);
  --
  l_package       varchar2(80) := g_package||'.p_cnt_ple';
  --
  cursor c_ptnl_ler is
    select count(*)
    from   ben_ptnl_ler_for_per ptn
    where  ptn.person_id = to_number(l_person_id)
    and    ptn.business_group_id+0 = to_number(l_business_group_id)
    /* and    ptn.lf_evt_ocrd_dt = p_effective_date */
    and    ptn.ptnl_ler_for_per_stat_cd in ('DTCTD','UNPROCD');
    /* and    to_date(l_effective_date, 'dd/mm/yyyy')
           between ptn.effective_start_date
           and     ptn.effective_end_date; */
  --
  --
  cursor c_pil is
    select count(*)
    from   ben_per_in_ler pil
    where  pil.person_id = to_number(l_person_id)
    and    pil.business_group_id = to_number(l_business_group_id)
    and    pil.per_in_ler_stat_cd = 'STRTD';
    /* and    to_date(l_effective_date, 'dd/mm/yyyy')
           between pil.effective_start_date
           and     pil.effective_end_date; */
  --
begin

  --
  hr_utility.set_location ('Entering '||l_package,05);
  --
  -- RUN mode - normal process execution.
  --
  if (funcmode = 'RUN' ) then
     --
     -- Extract the person_id, effective_date, business_group_id
     -- from the item type attributes.
     --
     l_person_id := wf_engine.GetItemAttrTEXT(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'PERSON_ID');
     --
     l_effective_date := wf_engine.GetItemAttrTEXT(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'EFFECTIVE_DATE');
     --
     l_business_group_id := wf_engine.GetItemAttrTEXT(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BUSINESS_GROUP_ID');
     --
     -- Get the number of pil/ptnl ler  records for the person.
     --
     open c_ptnl_ler;
     fetch c_ptnl_ler into l_ple_count;
     close c_ptnl_ler;
     --
     --
     open c_pil;
     fetch c_pil into l_pil_count;
     close c_pil;
     --
     -- set the item type attributes with the extracted ptnl ler, pil record counts.
     --
     wf_engine.SetItemAttrNumber(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_PLE_COUNT',
                        avalue      =>  l_ple_count);
     --
     wf_engine.SetItemAttrNumber(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_PIL_COUNT',
                        avalue      =>  l_pil_count);
     --
     -- error_simulation;
     if l_ple_count > 0 or  l_pil_count > 0 then
        --
        resultout :=  'COMPLETE:T';
        return;
        --
     else
        --
        resultout :=  'COMPLETE:F';
        return;
        --
     end if;
  end if;
  --
  if (funcmode = 'CANCEL' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:';
     return;
     --
  end if;
  --
  if (funcmode = 'TIMEOUT' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:';
     return;
     --
  end if;
  --
  --
  hr_utility.set_location ('Leaving '||l_package,05);
  --
exception
  --
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    mesg := fnd_message.get;
    wf_core.context('ben_on_line_lf_evt', 'p_cnt_ple' || substr(mesg, 1, 10),
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
  --
--
end p_cnt_ple;
--
procedure p_run_form(itemtype    in varchar2,
                     itemkey      in varchar2,
                     actid        in number,
                     funcmode     in varchar2,
                     resultout    out nocopy varchar2) is
begin
  if (funcmode = 'RUN' ) then
     --
     /* 99999 -- Extract the person_id, effective_date, business_group_id
     -- from the item type attributes.
     --
     l_person_id := wf_engine.GetItemAttrNumber(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'PERSON_ID');
     --
     l_effective_date := wf_engine.GetItemAttrDate(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'EFFECTIVE_DATE');
     --
     l_business_group_id := wf_engine.GetItemAttrNumber(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BUSINESS_GROUP_ID');
     --
     -- Get the number of pil/ptnl ler  records for the person.
     --
     open c_ptnl_ler;
     fetch c_ptnl_ler into l_ple_count;
     close c_ptnl_ler;
     --
     --
     open c_pil;
     fetch c_pil into l_pil_count;
     close c_pil;
     --
     -- set the item type attributes with the extracted ptnl ler, pil record counts.
     --
     wf_engine.SetItemAttrNumber(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_PLE_COUNT',
                        avalue      =>  l_ple_count);
     --
     wf_engine.SetItemAttrNumber(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_PIL_COUNT',
                        avalue      =>  l_pil_count);
     FND_FUNCTION.EXECUTE(FUNCTION_NAME =>'BENPECRT',
                          OPEN_FLAG => 'Y', OTHER_PARAMS=>
                          'G_PERSON_ID="'||TO_CHAR(:PGM_V.PERSON_ID)||'"');
     --
     FND_FUNCTION.EXECUTE(FUNCTION_NAME =>'BENAUTHE',
                          OPEN_FLAG => 'Y'); */
     --
     resultout :=  'COMPLETE:T';
     return;
     --
  end if;
  --
  if (funcmode = 'CANCEL' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:';
     return;
     --
  end if;
  --
  if (funcmode = 'TIMEOUT' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:';
     return;
     --
  end if;
  --
exception
  --
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ben_on_line_lf_evt', 'p_run_form',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
end p_run_form;
--

--
-- procedure to evaluate the potential life events,
-- and life events
--
procedure p_evt_lf_events(itemtype    in varchar2,
                    itemkey      in varchar2,
                    actid        in number,
                    funcmode     in varchar2,
                    resultout    out nocopy varchar2) is
  --
  --  Variables to store the item attributes values.
  --
  l_person_id                  number;
  l_effective_date             date;
  l_business_group_id          number;
  l_mesg           varchar2(1000);
  l_benefit_action_id          varchar2(80);
  l_person_count               number;
  l_prog_count           number;
  l_plan_count           number;
  l_oipl_count           number;
  l_plan_nip_count         number;
  l_oipl_nip_count         number;
  l_ler_id           number;
  l_object_version_number      number;
  l_ler_count                  number := 0;
  l_errbuf                     varchar2(1000);
  L_RETCODE                number;
  l_package                    varchar2(80) := g_package||'.p_evt_lf_events';
  --
  type l_le_rec is record
    (name              ben_ler_f.name%type,
     lf_evt_ocrd_dt    ben_per_in_ler.lf_evt_ocrd_dt%type);
  --
  type l_le_table is table of l_le_rec
  index by binary_integer;
  --
  l_le_object l_le_table;
  --
  --
  type l_cont_rel_table is table of varchar2(1000)
  index by binary_integer;
  --
  l_cont_rel_object l_cont_rel_table;
  --
  l_pil_count     number  := 0;
  l_ple_count     number  := 0;
  l_rel_per_count number  := 0;
  l_bft_id        number;
  --
  cursor c_ler is
    select ler_id
       from ben_person_actions
       where BENEFIT_ACTION_ID = benutils.g_benefit_action_id;
  --
  cursor c_ptnl_ler is
    select count(*)
    from   ben_ptnl_ler_for_per ptn
    where  ptn.person_id = l_person_id
    and    ptn.business_group_id+0 = l_business_group_id
    /* and    ptn.lf_evt_ocrd_dt = p_effective_date */
    and    ptn.ptnl_ler_for_per_stat_cd in ('DTCTD','UNPROCD');
    /* and    l_effective_date
           between ptn.effective_start_date
           and     ptn.effective_end_date; */
  --
  cursor c_pil is
  select ler.name,
         ler.ler_id,
         pil.lf_evt_ocrd_dt,
         pil.per_in_ler_stat_cd,
         pel.dflt_enrt_dt
  from   ben_per_in_ler pil,
         ben_ler_f        ler,
         ben_pil_elctbl_chc_popl pel
  where  pil.ler_id = ler.ler_id
         and pil.per_in_ler_id = pel.per_in_ler_id
         and pil.person_id = l_person_id
         and pil.business_group_id = l_business_group_id
         and ler.business_group_id = l_business_group_id
         and pel.business_group_id = l_business_group_id
         and pil.per_in_ler_stat_cd = 'STRTD'
         /*and l_effective_date
             between pil.effective_start_date
             and     pil.effective_end_date */
         and l_effective_date
             between ler.effective_start_date
             and     ler.effective_end_date;

  --
 cursor c_cont_rel is
   select csr.contact_person_id,
          ppf.full_name,
          ler.name,
          ler.ler_id,
          pil.lf_evt_ocrd_dt,
          pil.per_in_ler_stat_cd,
          pel.dflt_enrt_dt
   from   per_contact_relationships csr,  --?? will be _f
          per_people_f ppf,
          ben_per_in_ler pil,
          ben_ler_f        ler,
          ben_pil_elctbl_chc_popl pel
   where  csr.person_id = l_person_id
   and    ppf.person_id = csr.contact_person_id
   and    pil.per_in_ler_id = pel.per_in_ler_id
   /* and    l_effective_date
          between ppf.effective_start_date
          and     ppf.effective_end_date */
   and csr.personal_flag = 'Y'
   and l_effective_date between nvl(csr.date_start, l_effective_date)
                                and nvl(csr.date_end, l_effective_date)
   and pil.ler_id = ler.ler_id
   and pil.person_id = csr.contact_person_id
   and pil.business_group_id = l_business_group_id
   and ler.business_group_id = l_business_group_id
   and pel.business_group_id = l_business_group_id
   and pil.per_in_ler_stat_cd = 'STRTD'
   /* and l_effective_date
              between pil.effective_start_date
              and     pil.effective_end_date */
   and l_effective_date
              between ler.effective_start_date
              and     ler.effective_end_date
   order by 1;

  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,05);
  --
  --
  -- RUN mode - normal process execution.
  --
  if (funcmode = 'RUN' ) then
     --
     -- Extract the person_id, effective_date, business_group_id
     -- from the item type attributes.
     --
     l_person_id := to_number(wf_engine.GetItemAttrTEXT(
                    itemtype    =>  itemtype,
                                      itemkey     =>  itemkey,
                                      aname       =>  'PERSON_ID'));
     --
     l_effective_date := to_date(wf_engine.GetItemAttrTEXT(
                    itemtype    =>  itemtype,
                                      itemkey     =>  itemkey,
                                      aname       =>  'EFFECTIVE_DATE'), 'YYYY/MM/DD HH24:MI:SS');
     --
     l_business_group_id := to_number(wf_engine.GetItemAttrTEXT(
                    itemtype    =>  itemtype,
                                      itemkey     =>  itemkey,
                                      aname       =>  'BUSINESS_GROUP_ID'));
     --
     -- Get the number of ptnl ler  records for the person.
     -- before evaluating the life events.
     --
     open  c_ptnl_ler;
     fetch c_ptnl_ler into l_ple_count;
     close c_ptnl_ler;
     --
     -- In case of error rollback upto this point.
     --
     savepoint process_lf_evts;
     --
    --
    l_bft_id := null;
    --
    ben_manage_life_events.process
      (
       errbuf                     => l_errbuf,
       retcode                    => l_retcode,
       p_benefit_action_id        => l_bft_id,
       p_effective_date           => l_effective_date,
       p_mode                     => 'L',
       p_derivable_factors        => 'ASC' ,
       p_validate                 => 'N',
       p_person_id                => l_person_id,
       p_person_type_id           => null,
       p_pgm_id                   => null,
       p_business_group_id        => l_business_group_id,
       p_pl_id                    => null,
       p_popl_enrt_typ_cycl_id    => null,
       p_no_programs              => 'N' ,
       p_no_plans                 => 'N' ,
       p_comp_selection_rule_id   => null,
       p_person_selection_rule_id => null,
       p_ler_id                   => null,
       p_organization_id          => null,
       p_benfts_grp_id            => null,
       p_location_id              => null,
       p_pstl_zip_rng_id          => null,
       p_rptg_grp_id              => null,
       p_pl_typ_id                => null,
       p_opt_id                   => null,
       p_eligy_prfl_id            => null,
       p_vrbl_rt_prfl_id          => null,
       p_legal_entity_id          => null,
       p_payroll_id               => null,
       p_commit_data              => 'N',
                   p_lmt_prpnip_by_org_flag   => nvl(fnd_profile.value('BEN_LMT_PRPNIP_BY_ORG_FLAG'), 'N'),
                   p_lf_evt_ocrd_dt           => l_effective_date  );
     --
     ben_comp_object_list.build_comp_object_list
      (p_benefit_action_id      => benutils.g_benefit_action_id,
       p_comp_selection_rule_id => null,
       p_effective_date         => l_effective_date,
       p_pgm_id                 => null,
       p_business_group_id      => l_business_group_id,
       p_pl_id                  => null,
       p_oipl_id                => null,
                   p_asnd_lf_evt_dt         => null,
       -- p_popl_enrt_typ_cycl_id  => null,
       p_no_programs            => 'N',
       p_no_plans               => 'N',
       p_rptg_grp_id            => null,
       p_pl_typ_id              => null,
       p_opt_id                 => null,
       p_eligy_prfl_id          => null,
       p_vrbl_rt_prfl_id        => null,
       p_thread_id              => 1,
       p_mode                   => 'L');
     --
     ben_manage_life_events.person_header
         (p_person_id                => l_person_id,
    p_business_group_id        => l_business_group_id,
    p_effective_date           => l_effective_date);
     --
     open c_ler;
     fetch c_ler into l_ler_id;
     --
     if c_ler%notfound then
  --
        close c_ler;
  fnd_message.set_name('BEN','BEN_91791_LER_NOT_IN_PER_ACTN');
  fnd_message.raise_error;
  --
     end if;
     --
     close c_ler;
     ben_manage_life_events.evaluate_life_events
      (p_person_id                => l_person_id,
       p_business_group_id        => l_business_group_id,
       p_mode                     => 'L',
                   -- p_popl_enrt_typ_cycl_id    => null,
       p_ler_id                   => l_ler_id,
                   p_lf_evt_ocrd_dt           => l_effective_date,
       p_effective_date           => l_effective_date);
     --
     -- Populate the Item attributes with life event data to be displayed along with
     -- message.
     --
     for l_pil_rec in c_pil loop
   --
   l_pil_count := l_pil_count + 1;
   --
         l_le_object(l_pil_count).name           := l_pil_rec.name;
         l_le_object(l_pil_count).lf_evt_ocrd_dt := l_pil_rec.lf_evt_ocrd_dt;
       --
     end loop;
     --
     -- Populate the Item attributes with related person life event data
     -- to be displayed along with message.
     --
     for l_cont_rel_rec in c_cont_rel loop
         --
         l_rel_per_count := l_rel_per_count + 1;
         l_cont_rel_object(l_rel_per_count) := 'Related Person : '|| l_cont_rel_rec.full_name
                                     || ', Event : ' || l_cont_rel_rec.name
                                     || ' , Date : ' ||
                                     to_char(l_cont_rel_rec.lf_evt_ocrd_dt, 'DD/MM/YYY');
         --
         if l_rel_per_count = 10 then
            exit;
         end if;
         --
     end loop;
     --
     -- Now is the time to rollback;
     l_benefit_action_id :=  to_char(benutils.g_benefit_action_id);
     rollback to process_lf_evts;
     --
     /* ben_manage_life_events.process_comp_objects
          (p_person_id                => l_person_id,
           p_person_action_id         => null,
           p_object_version_number    => l_object_version_number,
           p_business_group_id        => l_business_group_id,
           p_mode                     => 'L',
           p_ler_id                   => l_ler_id,
           p_derivable_factors        => 'ASC',
           p_person_count             => l_person_count,
           p_popl_enrt_typ_cycl_id    => null,
           p_effective_date           => l_effective_date
     );*/
     --
     -- Now set all the item attributes for the messaging purpose.
     --
     -- Save the ler id for future use.
     --
     wf_engine.SetItemAttrNumber(
        itemtype    =>  itemtype,
        itemkey     =>  itemkey,
        aname       =>  'BEN_IA_LER_ID',
        avalue      =>  l_ler_id);
     --
     for i in 1..l_pil_count loop
   --
   -- Set item attribute (Life event name, occured date )values.
   --
   wf_engine.SetItemAttrTEXT(
      itemtype    =>  itemtype,
      itemkey     =>  itemkey,
      aname       =>  'BEN_IA_LE_NAME',
      avalue      =>  l_le_object(l_pil_count).name);
   --
   wf_engine.SetItemAttrTEXT(
      itemtype    =>  itemtype,
      itemkey     =>  itemkey,
      aname       =>  'BEN_IA_LF_EVT_OCRD_DT',
      avalue      =>  l_le_object(l_pil_count).lf_evt_ocrd_dt);
        --
        -- Right now assumption is only one LE exists for the person.
        --
        if i = 1 then
           exit;
        end if;
        --
     end loop;
     --
     -- set the item type attributes with the extracted ptnl ler, pil record counts.
     --
     wf_engine.SetItemAttrNumber(
        itemtype    =>  itemtype,
        itemkey     =>  itemkey,
        aname       =>  'BEN_IA_PLE_COUNT',
        avalue      =>  l_ple_count);
     --
     wf_engine.SetItemAttrNumber(
        itemtype    =>  itemtype,
        itemkey     =>  itemkey,
        aname       =>  'BEN_IA_PIL_COUNT',
        avalue      =>  l_pil_count);
     --
     -- If no life events are detected then set message to No life Events Detected.
     --
     if l_pil_count = 0 then
  --
  wf_engine.SetItemAttrTEXT(
      itemtype    =>  itemtype,
      itemkey     =>  itemkey,
      aname       =>  'BEN_IA_LE_NAME',
      avalue      =>  ' No life Events Detected based on data changes');
  --
     end if;
     --
     --
     -- Populate the Item attributes with related person life event data
     -- to be displayed along with message.
     --
     for i in 1..l_rel_per_count loop
         --
         -- Set item attribute with(Related Person name, Life event name, occured date ).
         --
         wf_engine.SetItemAttrTEXT(
                        itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_REL_PER_LF' || to_char(i),
                        avalue      => l_cont_rel_object(i));
         --
         -- Currently only 10 related persons are handled so exit after 10 records fetch.
         --
         if i = 10 then
            exit;
         end if;
     end loop;
     --
     -- Store the thread id and benefit action id's into item attributes.
     --
     wf_engine.SetItemAttrTEXT(
                        itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_THREAD_ID',
                        avalue      =>  '1');
     --
     wf_engine.SetItemAttrTEXT(
                        itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_BENEFIT_ACTION_ID',
                        avalue      =>  l_benefit_action_id);
                        -- avalue      =>  to_char(benutils.g_benefit_action_id));
     --
     -- Successfully completed.
     --
     resultout :=  'COMPLETE:COMPLETE';
     return;
     --
  end if;
  --
  if (funcmode = 'CANCEL' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:COMPLETE';
     return;
     --
  end if;
  --
  if (funcmode = 'TIMEOUT' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:COMPLETE';
     return;
     --
  end if;
  --
  --
  hr_utility.set_location ('Leaving '||l_package,05);
  --
exception
  --
  when others then
    --
    -- The line below records this function call in the error system
    -- in the case of an exception.
    -- The error message is written to item attribute to be notified to the
    -- user. ?????
    l_mesg := fnd_message.get;
    --
    rollback to process_lf_evts;
    --
    wf_engine.SetItemAttrText(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_ERROR_TEXT',
                        avalue      =>  l_mesg);
    --
    --
    -- Completed with Errors.
    --
    resultout :=  'COMPLETE:ERROR';
    wf_core.context('ben_on_line_lf_evt', 'p_evt_lf_events' ,
                    itemtype, itemkey, to_char(actid), funcmode);
    return;
    --
end p_evt_lf_events;
--
-- procedure to process the life events,
--
procedure p_mng_lf_events(itemtype    in varchar2,
                          itemkey      in varchar2,
                          actid        in number,
                          funcmode     in varchar2,
                          resultout    out nocopy varchar2) is
  --
  --  Variables to store the item attributes values.
  --
  l_person_id           varchar2(50);
  l_effective_date      varchar2(50);
  l_business_group_id   varchar2(50);
  l_mesg    varchar2(1000);
  l_person_count  number;
  l_error_person_count  number;
  l_prog_count    number;
  l_plan_count    number;
  l_oipl_count    number;
  l_plan_nip_count  number;
  l_oipl_nip_count  number;
  l_ler_id    number;
  l_errbuf    varchar2(1000);
  l_retcode         number;
  l_object_version_number number;
  --
begin
  --
  -- RUN mode - normal process execution.
  --
  if (funcmode = 'RUN' ) then
     --
     -- Extract the person_id, effective_date, business_group_id
     -- from the item type attributes.
     --
     l_person_id := wf_engine.GetItemAttrTEXT(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'PERSON_ID');
     --
     l_effective_date := wf_engine.GetItemAttrTEXT(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'EFFECTIVE_DATE');
     --
     l_business_group_id := wf_engine.GetItemAttrTEXT(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BUSINESS_GROUP_ID');
     --
     l_ler_id := wf_engine.GetItemAttrNumber(
                        itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_LER_ID');
     --
     -- In case of error rollback upto this point.
     --
     savepoint process_lf_evts;
     --
     ben_on_line_lf_evt.p_manage_life_events(
      p_person_id             => to_number(l_person_id)
     ,p_effective_date        => to_date(l_effective_date, 'DD/MM/YYYY')
     ,p_business_group_id     => to_number(l_business_group_id)
     ,p_pgm_id                => null
     ,p_pl_id                 => null
     ,p_mode                  => 'L'
     ,p_prog_count            => l_prog_count
     ,p_plan_count            => l_plan_count
     ,p_oipl_count            => l_oipl_count
     ,p_person_count          => l_person_count
     ,p_plan_nip_count        => l_plan_nip_count
     ,p_oipl_nip_count        => l_oipl_nip_count
     ,p_ler_id                => l_ler_id
     ,p_errbuf                => l_errbuf
     ,p_retcode               => l_retcode);
     --
     --
     -- Store the thread id and benefit action id's into item attributes.
     --
     wf_engine.SetItemAttrTEXT(
                        itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_THREAD_ID',
                        avalue      =>  '1');
     --
     wf_engine.SetItemAttrTEXT(
                        itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_BENEFIT_ACTION_ID',
                        avalue      =>  to_char(benutils.g_benefit_action_id));
     --
     -- Successfully completed.
     resultout :=  'COMPLETE:COMPLETE';
     return;
     --
  end if;
  --
  if (funcmode = 'CANCEL' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:COMPLETE';
     return;
     --
  end if;
  --
  if (funcmode = 'TIMEOUT' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:COMPLETE';
     return;
     --
  end if;
  --
exception
  --
  when others then
    --
    -- The line below records this function call in the error system
    -- in the case of an exception.
    -- The error message is written to item attribute to be notified to the
    -- user. ?????
    l_mesg := fnd_message.get;
    --
    rollback to process_lf_evts;
    --
    wf_engine.SetItemAttrText(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_ERROR_TEXT',
                        avalue      =>  l_mesg);
    --
    --
    -- Completed with Errors.
    --
    resultout :=  'COMPLETE:ERROR';
    wf_core.context('ben_on_line_lf_evt', 'p_mng_lf_events' ,
                    itemtype, itemkey, to_char(actid), funcmode);
    return;
    --
end p_mng_lf_events;
--
--
-- procedure to count electable choices.
--
procedure p_have_elctbl_chcs(itemtype    in varchar2,
                    itemkey      in varchar2,
                    actid        in number,
                    funcmode     in varchar2,
                    resultout    out nocopy varchar2) is
  --
  --  Variables to store the item attributes values.
  --
  l_person_id           varchar2(50);
  l_effective_date      varchar2(50);
  l_business_group_id   varchar2(50);
  l_mesg    varchar2(1000);
  l_elctbl_chc_count  number := 0;
  l_can_prtcpnt_enroll  char(1);
  --
  cursor c_elctbl_chc is
    select count(*)
    from   ben_elig_per_elctbl_chc epe,
           ben_pil_elctbl_chc_popl pcp,
           ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = to_number(l_person_id)
    and    pil.per_in_ler_id = pcp.per_in_ler_id
    and    pcp.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
    and    ler.ler_id = pil.ler_id
    and    ler.business_group_id+0 = to_number(l_business_group_id)
    and    to_date(l_effective_date, 'dd/MM/yyyy')
           between ler.effective_start_date
           and     ler.effective_end_date
    and    epe.business_group_id+0 = to_number(l_business_group_id)
    and    pil.business_group_id+0 = to_number(l_business_group_id)
    and    pcp.business_group_id+0 = to_number(l_business_group_id)
    and    pil.per_in_ler_stat_cd = 'STRTD'
    /* and    to_date(l_effective_date, 'dd/MM/yyyy')
           between pil.effective_start_date
           and     pil.effective_end_date */
    and    ( to_date(l_effective_date, 'dd/MM/yyyy')
           between pcp.enrt_perd_strt_dt
           and     pcp.enrt_perd_end_dt or ler.TYP_CD = 'SCHDDU');
  --
  l_package       varchar2(80) := g_package||'.p_have_elctbl_chcs';
  --
begin
  --
  --
  hr_utility.set_location ('Entering '||l_package,05);
  --
  -- RUN mode - normal process execution.
  --
  if (funcmode = 'RUN' ) then
     --
     -- Extract the person_id, effective_date, business_group_id
     -- from the item type attributes.
     --
     l_person_id := wf_engine.GetItemAttrTEXT(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'PERSON_ID');
     --
     l_effective_date := wf_engine.GetItemAttrTEXT(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'EFFECTIVE_DATE');
     --
     l_business_group_id := wf_engine.GetItemAttrTEXT(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BUSINESS_GROUP_ID');
     --
     open c_elctbl_chc;
     fetch c_elctbl_chc into l_elctbl_chc_count;
     close c_elctbl_chc;
     --
     if l_elctbl_chc_count > 0  then
        resultout :=  'COMPLETE:Y';
     else
        resultout :=  'COMPLETE:N';
     end if;
     return;
     --
  end if;
  --
  if (funcmode = 'CANCEL' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:Y';
     return;
     --
  end if;
  --
  if (funcmode = 'TIMEOUT' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:Y';
     return;
     --
  end if;
  --
  --
  hr_utility.set_location ('Leaving '||l_package,05);
  --
exception
  --
  when others then
    --
    -- The line below records this function call in the error system
    -- in the case of an exception.
    -- The error message is written to item attribute to be notified to the
    -- user. ?????
    l_mesg := fnd_message.get;
    --
    -- Completed with Errors.
    --
    resultout :=  'COMPLETE:E';
    wf_core.context('ben_on_line_lf_evt', 'p_have_elctbl_chcs' ,
                    itemtype, itemkey, to_char(actid), funcmode);
    return;
    --
end p_have_elctbl_chcs;
--
-- procedure to detect a person can enroll now.
--
procedure p_can_prtcpnt_enrl(itemtype    in varchar2,
                    itemkey      in varchar2,
                    actid        in number,
                    funcmode     in varchar2,
                    resultout    out nocopy varchar2) is
  --
  --  Variables to store the item attributes values.
  --
  l_person_id           varchar2(50);
  l_effective_date      varchar2(50);
  l_business_group_id   varchar2(50);
  l_mesg    varchar2(1000);
  l_elctbl_chc_count  number := 0;
  l_can_prtcpnt_enroll  char(1);
  --
  cursor c_elctbl_chc is
    select count(*)
    from   ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil
    where  pil.person_id = to_number(l_person_id)
    and    epe.business_group_id+0 = to_number(l_business_group_id)
    and    epe.PER_IN_LER_ID = pil.PER_IN_LER_ID
    and    pil.business_group_id+0 = to_number(l_business_group_id)
    and    pil.per_in_ler_stat_cd = 'PROCD';
    /* and    to_date(l_effective_date, 'dd/MM/yyyy')
           between pil.effective_start_date
           and     pil.effective_end_date; */
  --
  l_package       varchar2(80) := g_package||'.p_can_prtcpnt_enrl';
  --
begin
  --
  --
  hr_utility.set_location ('Entering '||l_package,05);
  --
  -- RUN mode - normal process execution.
  --
  if (funcmode = 'RUN' ) then
     --
     -- Extract the person_id, effective_date, business_group_id
     -- from the item type attributes.
     --
     l_person_id := wf_engine.GetItemAttrTEXT(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'PERSON_ID');
     --
     l_effective_date := wf_engine.GetItemAttrTEXT(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'EFFECTIVE_DATE');
     --
     l_business_group_id := wf_engine.GetItemAttrTEXT(
      itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BUSINESS_GROUP_ID');
     --
     /*
     open c_elctbl_chc;
     fetch c_elctbl_chc into l_elctbl_chc_count;
     close c_elctbl_chc;
     */
     --
     if l_elctbl_chc_count > 0  then
        resultout :=  'COMPLETE:Y';
     else
        resultout :=  'COMPLETE:N';
     end if;
     /* 9999 delete below line */
     resultout :=  'COMPLETE:Y';
     return;
     --
  end if;
  --
  if (funcmode = 'CANCEL' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:Y';
     return;
     --
  end if;
  --
  if (funcmode = 'TIMEOUT' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:Y';
     return;
     --
  end if;
  --
  --
  hr_utility.set_location ('Leaving '||l_package,05);
  --
exception
  --
  when others then
    --
    -- The line below records this function call in the error system
    -- in the case of an exception.
    -- The error message is written to item attribute to be notified to the
    -- user. ?????
    l_mesg := fnd_message.get;
    --
    -- Completed with Errors.
    --
    resultout :=  'COMPLETE:E';
    wf_core.context('ben_on_line_lf_evt', 'p_can_prtcpnt_enrl' ,
                    itemtype, itemkey, to_char(actid), funcmode);
    return;
    --
end p_can_prtcpnt_enrl;
--
-- procedure to evaluate the potential life events,
-- and life events
--
procedure p_manage_life_events(
  p_person_id             in   number
 ,p_effective_date        in   date
 ,p_business_group_id     in   number
 ,p_prog_count            out nocopy  number
 ,p_plan_count            out nocopy  number
 ,p_oipl_count            out nocopy  number
 ,p_person_count          out nocopy  number
 ,p_plan_nip_count        out nocopy  number
 ,p_oipl_nip_count        out nocopy  number
 ,p_ler_id                out nocopy  number
 ,p_errbuf                out nocopy  varchar2
 ,p_retcode           out nocopy  number) is
  --
  --  local variables.
  l_object_version_number      number;
  --
  cursor c_ler is
    select ler_id
       from ben_person_actions
       where BENEFIT_ACTION_ID = benutils.g_benefit_action_id;
  --
begin
  --
      /* ben_manage_life_events.process
          (
           errbuf                     => p_errbuf,
           retcode                    => p_retcode,
           p_benefit_action_id        => null,
           p_effective_date           => p_effective_date,
           p_mode                     => 'L',
           p_derivable_factors        => 'ASC' ,
           p_validate                 => 'N',
           p_person_id                => p_person_id,
           p_person_type_id           => null,
           p_pgm_id                   => null,
           p_business_group_id        => p_business_group_id,
           p_pl_id                    => null,
           p_popl_enrt_typ_cycl_id    => null,
           p_no_programs              => 'N' ,
           p_no_plans                 => 'N' ,
           p_comp_selection_rule_id   => null,
           p_person_selection_rule_id => null,
           p_ler_id                   => null,
           p_organization_id          => null,
           p_benfts_grp_id            => null,
           p_location_id              => null,
           p_pstl_zip_rng_id          => null,
           p_rptg_grp_id              => null,
           p_pl_typ_id                => null,
           p_opt_id                   => null,
           p_eligy_prfl_id            => null,
           p_vrbl_rt_prfl_id          => null,
           p_legal_entity_id          => null,
           p_payroll_id               => null,
           p_commit_data              => 'N'  ); */
     --
     /* ben_comp_object_list.build_comp_object_list
          (p_benefit_action_id      => benutils.g_benefit_action_id,
           p_comp_selection_rule_id => null,
           p_effective_date         => p_effective_date,
           p_pgm_id                 => null,
           p_business_group_id      => p_business_group_id,
           p_pl_id                  => null,
           p_oipl_id                => null,
           p_popl_enrt_typ_cycl_id  => null,
           p_no_programs            => 'N',
           p_no_plans               => 'N',
           p_rptg_grp_id            => null,
           p_pl_typ_id              => null,
           p_opt_id                 => null,
           p_eligy_prfl_id          => null,
           p_vrbl_rt_prfl_id        => null,
           p_thread_id              => 1,
           p_mode                   => 'L', -- is it a parameter????
           -- p_cache_single_object    => 'N', -- 99999 Graham why removed
           p_prog_count             => p_prog_count,
           p_plan_count             => p_plan_count,
           p_oipl_count             => p_oipl_count,
           p_plan_nip_count         => p_plan_nip_count,
           p_oipl_nip_count         => p_oipl_nip_count); */
     --
     ben_manage_life_events.person_header
       (p_person_id                => p_person_id,
        p_business_group_id        => p_business_group_id,
        p_effective_date           => p_effective_date );
     --
     open c_ler;
     fetch c_ler into p_ler_id;
     --
     if c_ler%notfound then
        --
        fnd_message.set_name('BEN','BEN_91791_LER_NOT_IN_PER_ACTN');
        fnd_message.raise_error;
        --
     end if;
     --
     close c_ler;
     ben_manage_life_events.evaluate_life_events
          (p_person_id                => p_person_id,
           p_business_group_id        => p_business_group_id,
           p_mode                     => 'L',
           p_ler_id                   => p_ler_id,
           -- p_popl_enrt_typ_cycl_id    => null,
           p_lf_evt_ocrd_dt           => p_effective_date,
           p_effective_date           => p_effective_date);
     --
     ben_manage_life_events.process_comp_objects
          (p_person_id                => p_person_id,
           p_person_action_id         => null,
           p_object_version_number    => l_object_version_number,
           p_business_group_id        => p_business_group_id,
           p_mode                     => 'L',
           p_ler_id                   => p_ler_id,
           p_derivable_factors        => 'ASC',
           p_person_count             => p_person_count,
           -- p_popl_enrt_typ_cycl_id    => null,
           p_effective_date           => p_effective_date
     );
  --
end p_manage_life_events;
--
-- procedure to evaluate the potential life events,
-- and life events
--
procedure p_manage_life_events(
  p_person_id             in   number
 ,p_effective_date        in   date
 ,p_business_group_id     in   number
 ,p_pgm_id                in   number default null
 ,p_pl_id                 in   number default null
 ,p_mode                  in   varchar2
 ,p_lf_evt_ocrd_dt        in   date default null --GLOBAL CWB
 ,p_prog_count            out nocopy  number
 ,p_plan_count            out nocopy  number
 ,p_oipl_count            out nocopy  number
 ,p_person_count          out nocopy  number
 ,p_plan_nip_count        out nocopy  number
 ,p_oipl_nip_count        out nocopy  number
 ,p_ler_id                out nocopy  number
 ,p_errbuf                out nocopy  varchar2
 ,p_retcode           out nocopy  number) is
  --
  --  local variables.
  l_object_version_number      number;
  l_effective_date         varchar2(30);
  l_lf_evt_ocrd_dt         varchar2(30);
  l_chunk_size                 number := 0;
  l_threads                    number := 0;
  l_max_errors_allowed         number ;
  l_rec                        benutils.g_active_life_event;
  --
  cursor c_ler is
    select ler_id
       from ben_person_actions
       where BENEFIT_ACTION_ID = benutils.g_benefit_action_id;
  --
  l_bft_id number;
  l_assignment_id              number;
  l_encoded_message   varchar2(2000);
  l_app_short_name    varchar2(2000);
  l_message_name      varchar2(2000);

  -- start bug 4430107
  cursor c_pgm is
    select pgm_id
       from BEN_PIL_ELCTBL_CHC_POPL
       where business_group_id = p_business_group_id
       and   PER_IN_LER_ID     = l_rec.per_in_ler_id
       and   pgm_id is not null;
  --
  cursor c_contact is
    select pcr.contact_person_id ,
           pcr.contact_relationship_id
      from per_contact_relationships pcr,
           per_all_people_f          per
      where pcr.person_id = p_person_id
      and   pcr.contact_person_id = per.person_id
      and   pcr.personal_flag = 'Y'
      and   p_effective_date between per.effective_start_date and per.effective_end_date
      and   p_effective_date between
              nvl(pcr.date_start,p_effective_date) and
              nvl(pcr.date_end,p_effective_date)
      and   p_effective_date > l_rec.lf_evt_ocrd_dt
      and   nvl(pcr.date_start,p_effective_date) > l_rec.lf_evt_ocrd_dt ;

  --
  --l_contact c_contact%rowtype;
  --end bug 4430107
begin
  --
  hr_utility.set_location('Before Process',5);
  savepoint p_manage_life_events_savepoint;  -- Bug 8290746
  /*
  l_effective_date := to_char(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_lf_evt_ocrd_dt := to_char(nvl(p_lf_evt_ocrd_dt,p_effective_date),'YYYY/MM/DD HH24:MI:SS');
  */
  --
  l_effective_date :=  fnd_date.date_to_canonical(p_effective_date);
  l_lf_evt_ocrd_dt :=  fnd_date.date_to_canonical(NVL(p_lf_evt_ocrd_dt,p_effective_date));
  --
  -- Bug 3486966
  --
  if p_mode in ('L', 'C','U') then
        l_assignment_id  := null;
        l_assignment_id  :=
          benutils.get_assignment_id(p_person_id=> p_person_id
           ,p_business_group_id => p_business_group_id
           ,p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date));
        --
        if l_assignment_id is null
        then
           fnd_message.set_name('BEN','BEN_93906_NO_EMP_BEN_ASG');
           fnd_message.raise_error;
        end if ;
  end if;
  l_bft_id := null;
  ben_manage_life_events.g_modified_mode := null;
  --
  ben_comp_object_list1.refresh_eff_date_caches;
  --

      ben_manage_life_events.process
          (
           errbuf                     => p_errbuf,
           retcode                    => p_retcode,
           p_benefit_action_id        => l_bft_id,
           p_effective_date           => l_effective_date,
           p_mode                     => p_mode,
           p_derivable_factors        => 'ASC' ,
           p_validate                 => 'N',
           p_person_id                => p_person_id,
           p_person_type_id           => null,
           p_pgm_id                   => p_pgm_id,
           p_business_group_id        => p_business_group_id,
           p_pl_id                    => p_pl_id,
           p_popl_enrt_typ_cycl_id    => null,
           p_no_programs              => 'N' ,
           p_no_plans                 => 'N' ,
           p_comp_selection_rule_id   => null,
           p_person_selection_rule_id => null,
           p_ler_id                   => null,
           p_organization_id          => null,
           p_benfts_grp_id            => null,
           p_location_id              => null,
           p_pstl_zip_rng_id          => null,
           p_rptg_grp_id              => null,
           p_pl_typ_id                => null,
           p_opt_id                   => null,
           p_eligy_prfl_id            => null,
           p_vrbl_rt_prfl_id          => null,
           p_legal_entity_id          => null,
           p_payroll_id               => null,
           p_commit_data              => 'N',
           p_lmt_prpnip_by_org_flag   => nvl(fnd_profile.value('BEN_LMT_PRPNIP_BY_ORG_FLAG'), 'N'),
           p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt ); -- GLOBAL CWB l_effective_date  );
     --
     hr_utility.set_location('After process',10);
     hr_utility.set_location('Before get_parameter',21);
     --
     benutils.get_parameter
       (p_business_group_id => p_business_group_id,
        p_batch_exe_cd      => 'BENMNGLE',
        p_threads           => l_threads,
        p_chunk_size        => l_chunk_size,
        p_max_errors        => l_max_errors_allowed);
     --
     -- Set up benefits environment
     --
     hr_utility.set_location('After get_parameter',22);
     hr_utility.set_location('Before clear_init_benmngle_caches',23);
     --
     ben_manage_life_events.clear_init_benmngle_caches
       (p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_threads           => l_threads
       ,p_chunk_size        => l_chunk_size
       ,p_max_errors        => l_max_errors_allowed
       ,p_benefit_action_id => benutils.g_benefit_action_id
       ,p_thread_id         => 1
       );
     hr_utility.set_location('After clear_init_benmngle_caches',24);
     hr_utility.set_location('Before Build Comp Object List',30);
     --
     if (p_mode = 'U')
     then
         ben_comp_object_list.build_comp_object_list
          (p_benefit_action_id      => benutils.g_benefit_action_id,
           p_comp_selection_rule_id => null,
           p_effective_date         => p_effective_date,
           p_pgm_id                 => p_pgm_id,
           p_business_group_id      => p_business_group_id,
           p_pl_id                  => p_pl_id,
           p_oipl_id                => null,
           -- p_popl_enrt_typ_cycl_id  => null,
           p_asnd_lf_evt_dt         => null,
           p_no_programs            => 'N',
           p_no_plans               => 'N',
           p_rptg_grp_id            => null,
           p_pl_typ_id              => null,
           p_opt_id                 => null,
           p_eligy_prfl_id          => null,
           p_vrbl_rt_prfl_id        => null,
           p_thread_id              => 1,
           p_mode                   => p_mode);
       --
       ben_manage_life_events.g_modified_mode := 'U';
     --
     end if;
     hr_utility.set_location('After build comp object',32);
     hr_utility.set_location('Before Cursor',35);
     --
     open c_ler;
     fetch c_ler into p_ler_id;
     --
     if c_ler%notfound then
        --
        fnd_message.set_name('BEN','BEN_91791_LER_NOT_IN_PER_ACTN');
        fnd_message.raise_error;
        --
     end if;
     --
     close c_ler;
     --
     hr_utility.set_location('After Cursor',40);
     hr_utility.set_location('Before evaluate life events',45);
     --
     ben_manage_life_events.evaluate_life_events
          (p_person_id                => p_person_id,
           p_business_group_id        => p_business_group_id,
           p_mode                     => p_mode,
           p_ler_id                   => p_ler_id,
           -- p_popl_enrt_typ_cycl_id    => null,
           p_lf_evt_ocrd_dt           => nvl(p_lf_evt_ocrd_dt,p_effective_date),
           p_effective_date           => p_effective_date);
     --
     hr_utility.set_location('After evaluate life events',50);
     --
     -- save the benefit action id to be used by process_comp_objects.
     --
     g_benefit_action_id      := benutils.g_benefit_action_id;
     --
     -- To synchronize with process_life_events procedure
     -- ben_manage_life_events.person_header is moved here.
     --
     hr_utility.set_location('Before Person Header',51);
     --
     if p_mode = 'W' then
       -- GLOBAL CWB : Call diferent procedures for different modes.
       benutils.get_active_life_event
      (p_person_id             => p_person_id,
       p_business_group_id     => p_business_group_id,
       p_effective_date        => p_effective_date,
       p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt,
       p_ler_id                => p_ler_id,
       p_rec                   => l_rec);
      --
     -- GSP : Call diferent procedures for different modes.
     elsif p_mode = 'G' then
          --
          benutils.get_active_life_event
          (p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_event_mode   => 'G',
           p_rec               => l_rec);
          --
     elsif p_mode = 'U' then
          --
          benutils.get_active_life_event
          (p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_event_mode   => 'U',
           p_rec               => l_rec);
     elsif p_mode = 'M' then
          --
          benutils.get_active_life_event
          (p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_event_mode   => 'M',
           p_rec               => l_rec);
          --
     else
          --
          benutils.get_active_life_event
         (p_person_id             => p_person_id,
          p_business_group_id     => p_business_group_id,
          p_effective_date        => p_effective_date,
          p_rec                   => l_rec);
          --
     end if;
     --
     --
     ben_manage_life_events.person_header
        (p_person_id                => p_person_id,
        p_business_group_id        => p_business_group_id,
        p_effective_date           => nvl(l_rec.lf_evt_ocrd_dt,p_effective_date) );
     --
     hr_utility.set_location('After Person Header',52);
     --
     hr_utility.set_location('Before process comp objects',55);
     --
     hr_utility.set_location('p_ler_id '||p_ler_id,10);
     hr_utility.set_location('l_rec.lf_evt_ocrd_dt'||l_rec.lf_evt_ocrd_dt,10);
     --
     ben_manage_life_events.process_comp_objects
          (p_person_id                => p_person_id,
           p_person_action_id         => null,
           p_object_version_number    => l_object_version_number,
           p_business_group_id        => p_business_group_id,
           p_mode                     => p_mode,
           p_ler_id                   => p_ler_id,
           p_derivable_factors        => 'ASC',
           p_person_count             => p_person_count,
           -- p_popl_enrt_typ_cycl_id    => null,
           p_effective_date           => p_effective_date,
           p_lf_evt_ocrd_dt           => nvl(l_rec.lf_evt_ocrd_dt,p_effective_date) --CWB GLOBAL
     );
    --
    hr_utility.set_location('After process comp objects',60);

   -- start bug 4430107
   if p_mode <> 'U' then -- only for NON-unrestricted Life events
     for l_pgm in c_pgm loop

      hr_utility.set_location('SUP: In c_pgm Loop :l_pgm.pgm_id '||l_pgm.pgm_id, 99);

      for l_contact in c_contact loop

         hr_utility.set_location('SUP: In c_contact Loop :l_contact.contact_person_id '||l_contact.contact_person_id, 99);

         ben_determine_dpnt_elig_ss.main
         (p_pgm_id                  =>  l_pgm.pgm_id,
          p_per_in_ler_id           =>  l_rec.per_in_ler_id,
          p_person_id               =>  p_person_id,
          p_contact_person_id       =>  l_contact.contact_person_id ,
          p_contact_relationship_id =>  l_contact.contact_relationship_id,
          p_effective_date          =>  p_effective_date
          );


      end loop;
     end loop ;

   end if; -- only for NON-unrestricted Life events

   -- end bug 4430107


exception
  when ben_manage_life_events.g_record_error then
     -- there is an error from benmngle, show the error message that is
     -- setup in benmngle.
     fnd_message.raise_error;
  when ben_manage_life_events.g_life_event_after then
    get_ser_message(p_encoded_message => l_encoded_message,
                    p_app_short_name  => l_app_short_name,
                    p_message_name    => l_message_name);
 -- Bug 4254792 Donot add substitute manual LE errors
    if (l_message_name = 'BEN_92396_LIFE_EVENT_MANUAL'
        or l_message_name = 'BEN_94209_MAN_LER_EXISTIS') then
        null;
    elsif l_message_name = 'BEN_92144_NO_LIFE_EVENTS' then --5211969
        null;
    else
     -- there is an error in benmngle.  In this case display a special error
     -- message as the message in benmgle is too generic.
     fnd_message.set_name('BEN', 'BEN_91940_LIFE_EVT_AFTER');
    end if;
     fnd_message.raise_error;

  -- Bug 8290746
  when ben_manage_life_events.g_cwb_trk_ineligible then
    --
    hr_utility.set_location ('Exception g_cwb_trk_ineligible ',20);

    --
    rollback to p_manage_life_events_savepoint;

 -- Bug 8290746
  when others then
     raise;
  --
end p_manage_life_events;
--
--
-- procedure to check whether the context is already established.
-- if established then authentication form is bypassed.
--
procedure p_context_def(itemtype    in varchar2,
                    itemkey      in varchar2,
                    actid        in number,
                    funcmode     in varchar2,
                    resultout    out nocopy varchar2) is
  --
  --  Variables to store the item attributes values.
  --
  l_context_set         varchar2(50);
  l_mesg    varchar2(1000);
  --
begin
  --
  -- RUN mode - normal process execution.
  --
  if (funcmode = 'RUN' ) then
     --
     l_context_set := wf_engine.GetItemAttrTEXT(
                        itemtype    =>  itemtype,
                        itemkey     =>  itemkey,
                        aname       =>  'BEN_IA_CONTEXT_SET');
     --
     if l_context_set = 'Y'
     then
        resultout :=  'COMPLETE:Y';
     else
        resultout :=  'COMPLETE:N';
     end if;
     return;
     --
  end if;
  --
  if (funcmode = 'CANCEL' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:N';
     return;
     --
  end if;
  --
  if (funcmode = 'TIMEOUT' ) then
     --
     -- Return process to run
     --
     resultout := 'COMPLETE:N';
     return;
     --
  end if;
  --
exception
  --
  when others then
    --
    -- The line below records this function call in the error system
    -- in the case of an exception.
    -- The error message is written to item attribute to be notified to the
    -- user. ?????
    l_mesg := fnd_message.get;
    --
    -- Completed with Errors.
    --
    resultout :=  'COMPLETE:E';
    wf_core.context('ben_on_line_lf_evt', 'p_context_def' ,
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
    --
end p_context_def;
--
procedure p_commit is
begin
--
commit;
--
end p_commit;
--
--
-- This procedure to evaluate the potential life events,
-- and life events called from benauthe form as a CSR
-- desktop activity.
--
procedure p_evt_lf_evts_from_benauthe(
  p_person_id             in   number
 ,p_effective_date        in   date
 ,p_business_group_id     in   number
 ,p_pgm_id                in   number default null
 ,p_pl_id                 in   number default null
 ,p_mode                  in   varchar2
 ,p_popl_enrt_typ_cycl_id in   number
 ,p_lf_evt_ocrd_dt        in   date
 ,p_prog_count            out nocopy  number
 ,p_plan_count            out nocopy  number
 ,p_oipl_count            out nocopy  number
 ,p_person_count          out nocopy  number
 ,p_plan_nip_count        out nocopy  number
 ,p_oipl_nip_count        out nocopy  number
 ,p_ler_id                out nocopy  number
 ,p_errbuf                out nocopy  varchar2
 ,p_retcode           out nocopy  number) is
  --
  --  local variables.
  l_package               varchar2(80) := 'ben_on_line_lf_evt.p_evt_lf_evts_from_benauthe';
  l_object_version_number      number;
  l_effective_date             varchar2(30);
  l_lf_evt_ocrd_dt             varchar2(30);
  l_chunk_size                 number := 0;
  l_threads                    number := 0;
  l_max_errors_allowed         number;
  l_rec                        benutils.g_active_life_event;
  l_assignment_id              number;
  --
  l_bft_id             number;
  --
  cursor c_ler is
    select ler_id
       from ben_person_actions
       where BENEFIT_ACTION_ID = benutils.g_benefit_action_id;
  --
begin
  --
      hr_utility.set_location(l_package || ' Before Process',5);
      --
      if p_effective_date is not null then
         --l_effective_date := to_char(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
         l_effective_date :=  fnd_date.date_to_canonical(p_effective_date);
      end if;
      if p_lf_evt_ocrd_dt is not null then
         --l_lf_evt_ocrd_dt := to_char(p_lf_evt_ocrd_dt,'YYYY/MM/DD HH24:MI:SS');
         l_lf_evt_ocrd_dt :=  fnd_date.date_to_canonical(p_lf_evt_ocrd_dt);
      end if;
      --
      -- Initialise the globals.
      --
      g_benefit_action_id := null;
      ben_person_object.clear_down_cache;
      --
      l_bft_id := null;
      --
      -- Bug 3486966
      --
      if p_mode in ('L', 'C','U') then
        l_assignment_id  := null;
        l_assignment_id  :=
          benutils.get_assignment_id(p_person_id=> p_person_id
           ,p_business_group_id => p_business_group_id
           ,p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date));
        --
        if l_assignment_id is null
        then
           fnd_message.set_name('BEN','BEN_93906_NO_EMP_BEN_ASG');
           fnd_message.raise_error;
        end if ;
      end if;
      ben_manage_life_events.process
          (
           errbuf                     => p_errbuf,
           retcode                    => p_retcode,
           p_benefit_action_id        => l_bft_id,
           p_effective_date           => l_effective_date,
           p_mode                     => p_mode,
           p_derivable_factors        => 'ASC' ,
           p_validate                 => 'N',
           p_person_id                => p_person_id,
           p_person_type_id           => null,
           p_pgm_id                   => p_pgm_id,
           p_business_group_id        => p_business_group_id,
           p_pl_id                    => p_pl_id,
           -- PB : 5422 :
           --  p_popl_enrt_typ_cycl_id    => p_popl_enrt_typ_cycl_id,
           p_no_programs              => 'N' ,
           p_no_plans                 => 'N' ,
           p_comp_selection_rule_id   => null,
           p_person_selection_rule_id => null,
           p_ler_id                   => null,
           p_organization_id          => null,
           p_benfts_grp_id            => null,
           p_location_id              => null,
           p_pstl_zip_rng_id          => null,
           p_rptg_grp_id              => null,
           p_pl_typ_id                => null,
           p_opt_id                   => null,
           p_eligy_prfl_id            => null,
           p_vrbl_rt_prfl_id          => null,
           p_legal_entity_id          => null,
           p_payroll_id               => null,
           p_commit_data              => 'N',
           p_lmt_prpnip_by_org_flag   => nvl(fnd_profile.value('BEN_LMT_PRPNIP_BY_ORG_FLAG'), 'N'),
           p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt  );
     --
     hr_utility.set_location(l_package ||' After process',10);
     --
     hr_utility.set_location('Before get_parameter',21);
     --
     benutils.get_parameter
       (p_business_group_id => p_business_group_id,
        p_batch_exe_cd      => 'BENMNGLE',
        p_threads           => l_threads,
        p_chunk_size        => l_chunk_size,
        p_max_errors        => l_max_errors_allowed);
     --
     -- Set up benefits environment
     --
     hr_utility.set_location('After get_parameter',22);
     --
     -- Clear benmngle level caches
     --
     ben_manage_life_events.clear_init_benmngle_caches
       (p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_threads           => l_threads
       ,p_chunk_size        => l_chunk_size
       ,p_max_errors        => l_max_errors_allowed
       ,p_benefit_action_id => benutils.g_benefit_action_id
       ,p_thread_id         => 1
       );
     --
     hr_utility.set_location('After ben_manage_life_events.clear_init_benmngle_caches',24);
     hr_utility.set_location('Before Cursor',35);
     --
     open c_ler;
     fetch c_ler into p_ler_id;
     --
     if c_ler%notfound then
        --
        -- 3948506: Changed the error message.
        fnd_message.set_name('BEN','BEN_92540_NOONE_TO_PROCESS_CM');
        --fnd_message.set_name('BEN','BEN_91791_LER_NOT_IN_PER_ACTN');
        fnd_message.raise_error;
        --
     end if;
     --
     close c_ler;
     --
     hr_utility.set_location('After Cursor',40);
     hr_utility.set_location('Before evaluate life events',45);
     --
     g_ptnls_voidd_flag := FALSE;
     ben_manage_life_events.g_modified_mode := null;
     ben_lf_evt_clps_restore.g_bckdt_pil_restored_flag := 'N';
     ben_manage_life_events.evaluate_life_events
          (p_person_id                => p_person_id,
           p_business_group_id        => p_business_group_id,
           p_mode                     => p_mode,
           p_ler_id                   => p_ler_id,
   -- PB : 5422 :
   -- p_popl_enrt_typ_cycl_id    => p_popl_enrt_typ_cycl_id,
           p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt,
           p_effective_date           => p_effective_date);
     --
     hr_utility.set_location('After evaluate life events',50);
     --
     -- save the benefit action id to be used by process_comp_objects.
     --
     g_benefit_action_id      := benutils.g_benefit_action_id;
     --
     -- To synchronize with process_life_events procedure
     -- ben_manage_life_events.person_header is moved here.
     --
     hr_utility.set_location('Before Person Header',51);
     --
     -- GSP : Call diferent procedures for different modes.
     if p_mode = 'G' then
          --
          benutils.get_active_life_event
          (p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_event_mode   => 'G',
           p_rec               => l_rec);
          --
     elsif p_mode = 'U' then
          --
          benutils.get_active_life_event
          (p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_event_mode   => 'U',
           p_rec               => l_rec);
     elsif p_mode = 'M' then
          --
          benutils.get_active_life_event
          (p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_event_mode   => 'M',
           p_rec               => l_rec);
          --
     else
          --
          benutils.get_active_life_event
         (p_person_id             => p_person_id,
          p_business_group_id     => p_business_group_id,
          p_effective_date        => p_effective_date,
          p_rec                   => l_rec);
          --
     end if;
     --
     ben_manage_life_events.person_header
       (p_person_id                => p_person_id,
        p_business_group_id        => p_business_group_id,
        p_effective_date           => nvl(l_rec.lf_evt_ocrd_dt,p_effective_date) );
     --
     hr_utility.set_location('After Person Header',52);
     --
exception
  when ben_manage_life_events.g_record_error then
     -- there is an error from benmngle, show the error message that is
     -- setup in benmngle.
     fnd_message.raise_error;
  when ben_manage_life_events.g_life_event_after then
     -- there is an error in benmngle.  In this case display a special error
     -- message as the message in benmgle is too generic.
     -- fnd_message.set_name('BEN', 'BEN_91940_LIFE_EVT_AFTER');
     -- fnd_message.raise_error;
     null;
  when others then
     raise;
  --
end p_evt_lf_evts_from_benauthe;
--

--
-- This procedure to process life events called from benauthe form as a CSR
-- desktop activity.
--
procedure p_proc_lf_evts_from_benauthe(
  p_person_id             in   number
 ,p_effective_date        in   date
 ,p_business_group_id     in   number
 ,p_mode                  in   varchar2
 ,p_ler_id                in   number
 -- PB : 5422 :
 -- ,p_popl_enrt_typ_cycl_id in   number
 ,p_lf_evt_ocrd_dt        in   date default null
 ,p_person_count          out nocopy  number
 ,p_benefit_action_id     out nocopy  number
 ,p_errbuf                out nocopy  varchar2
 ,p_retcode           out nocopy  number) is
  --
  --  local variables.
  --
  cursor c_person_thread is
    select ben.object_version_number, ben.person_action_id
    from   ben_person_actions ben
    where  ben.benefit_action_id = g_benefit_action_id
    and    ben.person_id = p_person_id
    and    ben.action_status_cd <> 'P';
  --
  l_object_version_number      number;
  l_person_action_id           number;
  --
begin
     --
     hr_utility.set_location('Before process comp objects',55);
     --
     --
     open  c_person_thread;
     fetch c_person_thread into l_object_version_number, l_person_action_id;
     close c_person_thread;
     --
     ben_manage_life_events.process_comp_objects
          (p_person_id                => p_person_id,
           p_person_action_id         => l_person_action_id,
           p_object_version_number    => l_object_version_number,
           p_business_group_id        => p_business_group_id,
           p_mode                     => p_mode,
           p_ler_id                   => p_ler_id,
           p_derivable_factors        => 'ASC',
           p_person_count             => p_person_count,
           -- PB : 5422 :
           p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt,
           -- p_popl_enrt_typ_cycl_id    => p_popl_enrt_typ_cycl_id,
           p_effective_date           => p_effective_date
     );
    p_benefit_action_id := benutils.g_benefit_action_id;
    --
    -- Write results to log
    --
    benutils.WRITE_TABLE_AND_FILE(P_TABLE => TRUE, P_FILE => FALSE);
    --
    ben_cobj_cache.clear_down_cache;
    hr_utility.set_location('After process comp objects',60);
    --
exception
  when ben_manage_life_events.g_record_error then
     -- there is an error from benmngle, show the error message that is
     -- setup in benmngle.
     fnd_message.raise_error;
  when ben_manage_life_events.g_life_event_after then
     -- there is an error in benmngle.  In this case display a special error
     -- message as the message in benmgle is too generic.
     fnd_message.set_name('BEN', 'BEN_91940_LIFE_EVT_AFTER');
     fnd_message.raise_error;

  when others then
     raise;
  --
end p_proc_lf_evts_from_benauthe;
--
-- procedure to evaluate the potential life events,
-- and life events
--
procedure p_watif_manage_life_events(
  p_person_id             in   number
 ,p_effective_date        in   date
 ,p_business_group_id     in   number
 ,p_pgm_id                in   number default null
 ,p_pl_id                 in   number default null
 ,p_mode                  in   varchar2
 ,p_derivable_factors     in   varchar2
 ,p_prog_count            out nocopy  number
 ,p_plan_count            out nocopy  number
 ,p_oipl_count            out nocopy  number
 ,p_person_count          out nocopy  number
 ,p_plan_nip_count        out nocopy  number
 ,p_oipl_nip_count        out nocopy  number
 ,p_ler_id                out nocopy  number
 ,p_errbuf                out nocopy  varchar2
 ,p_retcode           out nocopy  number) is
  --
  --  local variables.
  l_object_version_number number;
  l_effective_date        varchar2(30);
  l_chunk_size            number := 0;
  l_threads               number := 0;
  l_max_errors_allowed    number;
  --
  l_rec                   benutils.g_active_life_event;
  --
  l_bft_id                number;
  --
  cursor c_ler is
    select ler_id
       from ben_person_actions
       where BENEFIT_ACTION_ID = benutils.g_benefit_action_id;
  --
begin
  --
  hr_utility.set_location('Before Process',5);
  --
  -- Initialise the globals.
  --
  g_benefit_action_id := null;
  --
  --l_effective_date := to_char(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date :=  fnd_date.date_to_canonical(p_effective_date);
  --
  l_bft_id := null;
  --
  ben_manage_life_events.process
          (
           errbuf                     => p_errbuf,
           retcode                    => p_retcode,
           p_benefit_action_id        => l_bft_id,
           p_effective_date           => l_effective_date,
           p_mode                     => p_mode,
           p_derivable_factors        => p_derivable_factors,
           p_validate                 => 'N',
           p_person_id                => p_person_id,
           p_person_type_id           => null,
           p_pgm_id                   => p_pgm_id,
           p_business_group_id        => p_business_group_id,
           p_pl_id                    => p_pl_id,
           p_popl_enrt_typ_cycl_id    => null,
           p_no_programs              => 'N' ,
           p_no_plans                 => 'N' ,
           p_comp_selection_rule_id   => null,
           p_person_selection_rule_id => null,
           p_ler_id                   => null,
           p_organization_id          => null,
           p_benfts_grp_id            => null,
           p_location_id              => null,
           p_pstl_zip_rng_id          => null,
           p_rptg_grp_id              => null,
           p_pl_typ_id                => null,
           p_opt_id                   => null,
           p_eligy_prfl_id            => null,
           p_vrbl_rt_prfl_id          => null,
           p_legal_entity_id          => null,
           p_payroll_id               => null,
           p_commit_data              => 'N',
           p_lmt_prpnip_by_org_flag   => nvl(fnd_profile.value('BEN_LMT_PRPNIP_BY_ORG_FLAG'), 'N'),
           p_lf_evt_ocrd_dt           => l_effective_date  );
     --
     hr_utility.set_location('After process',10);
     hr_utility.set_location('Before get_parameter',21);
     --
     benutils.get_parameter
       (p_business_group_id => p_business_group_id,
        p_batch_exe_cd      => 'BENMNGLE',
        p_threads           => l_threads,
        p_chunk_size        => l_chunk_size,
        p_max_errors        => l_max_errors_allowed);
     --
     -- Set up benefits environment
     --
     hr_utility.set_location('After get_parameter',22);
     --
     -- Clear benmngle level caches
     --
     ben_manage_life_events.clear_init_benmngle_caches
       (p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_threads           => l_threads
       ,p_chunk_size        => l_chunk_size
       ,p_max_errors        => l_max_errors_allowed
       ,p_benefit_action_id => benutils.g_benefit_action_id
       ,p_thread_id         => 1
       );
     --
     hr_utility.set_location('After ben_manage_life_events.clear_init_benmngle_caches',24);
     hr_utility.set_location('Before Cursor',35);
     --
     open c_ler;
     fetch c_ler into p_ler_id;
     --
     if c_ler%notfound then
        --
        fnd_message.set_name('BEN','BEN_91791_LER_NOT_IN_PER_ACTN');
        fnd_message.raise_error;
        --
     end if;
     --
     close c_ler;
     --
     hr_utility.set_location('After Cursor',40);
     hr_utility.set_location('Before evaluate life events',45);
     --
     ben_manage_life_events.evaluate_life_events
          (p_person_id                => p_person_id,
           p_business_group_id        => p_business_group_id,
           p_mode                     => p_mode,
           p_ler_id                   => p_ler_id,
           -- p_popl_enrt_typ_cycl_id    => null,
           p_lf_evt_ocrd_dt           => p_effective_date,
           p_effective_date           => p_effective_date);
     --
     hr_utility.set_location('After evaluate life events',50);
     hr_utility.set_location('Before Person Header',25);
     --
     -- GSP : Call diferent procedures for different modes.
     if p_mode = 'G' then
          --
          benutils.get_active_life_event
          (p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_event_mode   => 'G',
           p_rec               => l_rec);
          --
     elsif p_mode = 'U' then
          --
          benutils.get_active_life_event
          (p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_event_mode   => 'U',
           p_rec               => l_rec);
     elsif p_mode = 'M' then
          --
          benutils.get_active_life_event
          (p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_event_mode   => 'M',
           p_rec               => l_rec);
          --
     else
          --
          benutils.get_active_life_event
         (p_person_id             => p_person_id,
          p_business_group_id     => p_business_group_id,
          p_effective_date        => p_effective_date,
          p_rec                   => l_rec);
          --
     end if;
     --
     --
     ben_manage_life_events.person_header
       (p_person_id                => p_person_id,
        p_business_group_id        => p_business_group_id,
        p_effective_date           => nvl(l_rec.lf_evt_ocrd_dt,p_effective_date));
     --
     hr_utility.set_location('After Person Header',30);
     hr_utility.set_location('Before process comp objects',55);
     --
     ben_manage_life_events.process_comp_objects
          (p_person_id                => p_person_id,
           p_person_action_id         => benutils.g_benefit_action_id, -- null,
           p_object_version_number    => l_object_version_number,
           p_business_group_id        => p_business_group_id,
           p_mode                     => p_mode,
           p_ler_id                   => p_ler_id,
           p_derivable_factors        => p_derivable_factors,
           p_person_count             => p_person_count,
           -- p_popl_enrt_typ_cycl_id    => null,
           p_effective_date           => p_effective_date
     );
    --
    hr_utility.set_location('After process comp objects',60);
    --
exception
  when ben_manage_life_events.g_record_error then
     -- there is an error from benmngle, show the error message that is
     -- setup in benmngle.
     fnd_message.raise_error;
  when ben_manage_life_events.g_life_event_after then
     -- there is an error in benmngle.  In this case display a special error
     -- message as the message in benmgle is too generic.
     -- BUG 2879140 -- change message as unrestricted enrollment does not make sense in watif
     fnd_message.set_name('BEN', 'BEN_93376_LIFE_EVT_AFTER');
     -- fnd_message.set_name('BEN', 'BEN_91940_LIFE_EVT_AFTER');
     fnd_message.raise_error;

  when others then
     raise;
  --
end p_watif_manage_life_events;
--
-- Procedure when called from a form message hook it will evaluates the
-- fast formula which returns Y or N, if Y then form displays the associated
-- message else nothing happens.
--
procedure p_oll_pop_up_message
                (p_person_id                in     number
                 ,p_business_group_id       in     number
                 ,p_function_name           in     varchar2
                 ,p_block_name              in     varchar2
                 ,p_field_name              in     varchar2
                 ,p_event_name              in     varchar2
                 ,p_effective_date          in     date
                 ,p_payroll_id              in number   default null
                 ,p_payroll_action_id       in number   default null
                 ,p_assignment_id           in number   default null
                 ,p_assignment_action_id    in number   default null
                 ,p_org_pay_method_id       in number   default null
                 ,p_per_pay_method_id       in number   default null
                 ,p_organization_id         in number   default null
                 ,p_tax_unit_id             in number   default null
                 ,p_jurisdiction_code       in number   default null
                 ,p_balance_date            in number   default null
                 ,p_element_entry_id        in number   default null
                 ,p_element_type_id         in number   default null
                 ,p_original_entry_id       in number   default null
                 ,p_tax_group               in number   default null
                 ,p_pgm_id                  in number   default null
                 ,p_pl_id                   in number   default null
                 ,p_pl_typ_id               in number   default null
                 ,p_opt_id                  in number   default null
                 ,p_ler_id                  in number   default null
                 ,p_communication_type_id   in number   default null
                 ,p_action_type_id          in number   default null
                 ,p_message_count           out nocopy    number
                 ,p_message1                out nocopy    varchar2
                 ,p_message_type1           out nocopy    varchar2
                 ,p_message2                out nocopy    varchar2
                 ,p_message_type2           out nocopy    varchar2
                 ,p_message3                out nocopy    varchar2
                 ,p_message_type3           out nocopy    varchar2
                 ,p_message4                out nocopy    varchar2
                 ,p_message_type4           out nocopy    varchar2
                 ,p_message5                out nocopy    varchar2
                 ,p_message_type5           out nocopy    varchar2
                 ,p_message6                out nocopy    varchar2
                 ,p_message_type6           out nocopy    varchar2
                 ,p_message7                out nocopy    varchar2
                 ,p_message_type7           out nocopy    varchar2
                 ,p_message8                out nocopy    varchar2
                 ,p_message_type8           out nocopy    varchar2
                 ,p_message9                out nocopy    varchar2
                 ,p_message_type9           out nocopy    varchar2
                 ,p_message10               out nocopy    varchar2
                 ,p_message_type10          out nocopy    varchar2
                 ) is
  --
  cursor c_rule is
    select *
    from   ben_pop_up_messages pop
    where  pop.function_name = p_function_name
    and    pop.event_name    = p_event_name
    and    nvl(pop.block_name, '***')  = nvl(p_block_name,  '***')
    and    nvl(pop.field_name, '***')  = nvl(p_field_name,  '***')
    and    pop.business_group_id+0 = p_business_group_id
    and    p_effective_date
           between nvl(pop.start_date, p_effective_date)
           and     nvl(pop.end_date, p_effective_date);
  --
  l_rule_rec       c_rule%rowtype;
  --
  cursor per_asn is
      select assignment_id,organization_id
        from per_assignments_f paf
       where paf.person_id = p_person_id
         and   paf.assignment_type <> 'C'
         and paf.primary_flag = 'Y'
         and paf.business_group_id + 0= p_business_group_id
         and p_effective_date between
                 paf.effective_start_date and paf.effective_end_date;
  l_asn       per_asn%rowtype;

  Cursor c_state is
  select region_2
  from hr_locations_all loc,per_all_assignments_f asg
  where loc.location_id = asg.location_id
  and asg.person_id = p_person_id
  and asg.assignment_type <> 'C'
  and asg.primary_flag = 'Y'
       and p_effective_date between
             asg.effective_start_date and asg.effective_end_date
       and asg.business_group_id+0=p_business_group_id;

  l_state c_state%rowtype;
  l_proc           varchar2(80) := '.p_call_oll_ff';
  l_outputs        ff_exec.outputs_t;
  l_return         varchar2(30);
  l_formula_id     number;
  l_jurisdiction_code     varchar2(30);
  l_mess_type      varchar2(10); -- 9999 delete it
  l_message_count  number := 0;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  p_message_type1    := null;
  p_message1         := null;
  p_message_type2    := null;
  p_message2         := null;
  p_message_type3    := null;
  p_message3         := null;
  p_message_type4    := null;
  p_message4         := null;
  p_message_type5    := null;
  p_message5         := null;
  p_message_type6    := null;
  p_message6         := null;
  p_message_type7    := null;
  p_message7         := null;
  p_message_type8    := null;
  p_message8         := null;
  p_message_type9    := null;
  p_message9         := null;
  p_message_type10   := null;
  p_message10        := null;
  p_message_count    := null;
  --
  if p_person_id is not null then
     --
     -- Get assignment ID,organization_id form per_assignments_f table.
     --
     open per_asn;
     fetch per_asn into l_asn;
     if per_asn%notfound then
        --
        -- Defensive coding
        --
        close per_asn;
        raise no_data_found;
     end if;
     close per_asn;
     --
/*  -- 4031733 - Cursor c_state populates l_state variable which is no longer
    -- used in the package. Cursor can be commented
     open c_state;
     fetch c_state into l_state;
     close c_state;
*/
     --if l_state.region_2 is not null then

     --   l_jurisdiction_code :=
     --      pay_mag_utils.lookup_jurisdiction_code
     --          (p_state => l_state.region_2);

     --end if;

  end if;
  --
  -- Get the message record
  --
  for l_rule_rec in c_rule loop
     --
     l_message_count := l_message_count + 1;
     if l_message_count > 10 then
        exit;
     end if;
     --
     if l_rule_rec.no_formula_flag = 'Y' then
        --
        -- Just return the message and message type
        -- As the case is to display a message
        -- without executing the fast formula
        -- Example : on WHEN-NEW-FORM-INSTANCE trigger display a message.
        --
        if l_message_count = 1 then
           p_message_type1 := l_rule_rec.message_type;
           p_message1      := l_rule_rec.message;
        elsif l_message_count = 2 then
           p_message_type2 := l_rule_rec.message_type;
           p_message2      := l_rule_rec.message;
        elsif l_message_count = 3 then
           p_message_type3 := l_rule_rec.message_type;
           p_message3      := l_rule_rec.message;
        elsif l_message_count = 4 then
           p_message_type4 := l_rule_rec.message_type;
           p_message4      := l_rule_rec.message;
        elsif l_message_count = 5 then
           p_message_type5 := l_rule_rec.message_type;
           p_message5      := l_rule_rec.message;
        elsif  l_message_count = 6 then
           p_message_type6 := l_rule_rec.message_type;
           p_message6      := l_rule_rec.message;
        elsif  l_message_count = 7 then
           p_message_type7 := l_rule_rec.message_type;
           p_message7      := l_rule_rec.message;
        elsif  l_message_count = 8 then
           p_message_type8 := l_rule_rec.message_type;
           p_message8      := l_rule_rec.message;
        elsif  l_message_count = 9 then
           p_message_type9 := l_rule_rec.message_type;
           p_message9      := l_rule_rec.message;
        elsif  l_message_count = 10 then
           p_message_type10 := l_rule_rec.message_type;
           p_message10      := l_rule_rec.message;
        end if;

        -- p_message_type := l_rule_rec.message_type;
        -- p_message      := l_rule_rec.message;
        -- copy(l_rule_rec.message_type, 'p_message_type' || to_char(l_message_count));
        -- copy(l_rule_rec.message, 'p_message' || to_char(l_message_count));
        --
     else
         --
         -- Call formula initialise routine
         --
         l_outputs := benutils.formula
                      (p_formula_id          => l_rule_rec.formula_id
                      ,p_effective_date      => p_effective_date
                      ,p_assignment_id       => l_asn.assignment_id
                      ,p_organization_id     => l_asn.organization_id
                      ,p_business_group_id   =>p_business_group_id
                      ,p_pgm_id              =>p_pgm_id
                      ,p_pl_id               =>p_pl_id
                      ,p_pl_typ_id           =>p_pl_typ_id
                      ,p_opt_id              =>p_opt_id
                      ,p_ler_id              =>p_ler_id
                      ,p_jurisdiction_code   =>l_jurisdiction_code);
         --
         l_return := l_outputs(l_outputs.first).value;
         --
         if upper(l_return) not in ('Y', 'N')  then
            --
            -- Defensive coding
            -- Just return 'N' means no popup in case of non Y or N.
            --
            l_return := 'N';
            --
         end if;
         if upper(l_return) = 'Y' then
            --
            -- Now display the message based on the message type
            --
            -- copy(l_rule_rec.message_type, 'p_message_type' || to_char(l_message_count));
            -- copy(l_rule_rec.message, 'p_message' || to_char(l_message_count));
            if l_message_count = 1 then
               p_message_type1 := l_rule_rec.message_type;
               p_message1      := l_rule_rec.message;
            elsif l_message_count = 2 then
               p_message_type2 := l_rule_rec.message_type;
               p_message2      := l_rule_rec.message;
            elsif l_message_count = 3 then
               p_message_type3 := l_rule_rec.message_type;
               p_message3      := l_rule_rec.message;
            elsif l_message_count = 4 then
               p_message_type4 := l_rule_rec.message_type;
               p_message4      := l_rule_rec.message;
            elsif l_message_count = 5 then
               p_message_type5 := l_rule_rec.message_type;
               p_message5      := l_rule_rec.message;
            elsif  l_message_count = 6 then
               p_message_type6 := l_rule_rec.message_type;
               p_message6      := l_rule_rec.message;
            elsif  l_message_count = 7 then
               p_message_type7 := l_rule_rec.message_type;
               p_message7      := l_rule_rec.message;
            elsif  l_message_count = 8 then
               p_message_type8 := l_rule_rec.message_type;
               p_message8      := l_rule_rec.message;
            elsif  l_message_count = 9 then
               p_message_type9 := l_rule_rec.message_type;
               p_message9      := l_rule_rec.message;
            elsif  l_message_count = 10 then
               p_message_type10 := l_rule_rec.message_type;
               p_message10      := l_rule_rec.message;
            end if;
            --
         end if;
         --
     end if;
     --
   end loop;
   p_message_count := l_message_count;
   hr_utility.set_location ('Leaving '||l_proc,10);
   --
   return ;
Exception
  when others then
  --
  -- Just return 'N' means no popup. Really don't stop the further processing.
  --
  l_return := 'N';
  return;
  --
end p_oll_pop_up_message;
--
function f_ret_ptnls_voidd_flag return boolean is
begin
  --
  return g_ptnls_voidd_flag;
  --
end;
--
--
-- Bug : 4504/1217193 This procedure is called from the form
-- BENWFREP to see whether any electable choices are created by this
-- run of benmngle. If not created then return a message.
--
function f_ret_elec_chc_created return boolean is
begin
  --
  return ben_enrolment_requirements.g_electable_choice_created;
  --
end;
--
-- Parse_encoded is not working properly on form side.
-- So this procedure is called from form to retrive the
-- message name. Based on the message BENAUTHE decides
-- what mwssage to diaply after evaluating the potential
-- life events.
--
procedure get_ser_message(p_encoded_message out nocopy varchar2,
                          p_app_short_name out nocopy varchar2,
                          p_message_name out nocopy varchar2) is
  --
  l_encoded_message   varchar2(2000);
  l_app_short_name    varchar2(2000);
  l_message_name      varchar2(2000);
  --
begin
  --
  p_encoded_message := null;
  p_app_short_name  := null;
  p_message_name    := null;
  p_encoded_message := fnd_message.get_encoded;
  fnd_message.parse_encoded(encoded_message => p_encoded_message,
                   app_short_name  => p_app_short_name,
                   message_name    => p_message_name);
  --
  if p_message_name is not null then
     fnd_message.set_encoded(encoded_message => p_encoded_message);
  end if;
  --
end;
--
--
-- self-service wrapper to run benmngle in
-- unrestricted mode.
--
procedure p_manage_life_events_w(
            p_person_id             in   number
           ,p_effective_date        in   date
           ,p_lf_evt_ocrd_dt        in   date default null
           ,p_business_group_id     in   number
           ,p_mode                  in   varchar2
           ,p_ss_process_unrestricted    in   varchar2 default 'Y'
	   ,p_return_status          out nocopy varchar2) is
  --
  l_proc           varchar2(72) := g_package||'p_manage_life_events_w';
  l_errbuf         varchar2(2000);
  l_retcode        number;
  l_prog_count     number;
  l_plan_count     number;
  l_oipl_count     number;
  l_person_count   number;
  l_plan_nip_count number;
  l_oipl_nip_count number;
  l_ler_id         number;
  --
  l_encoded_message   varchar2(2000);
  l_app_short_name    varchar2(2000);
  l_message_name      varchar2(2000);
  --
  --
  cursor c_open(p_lf_evt_ocrd_dt date,
                p_person_id number ) is
    select ler.typ_cd
    from ben_ptnl_ler_for_per pel,
         ben_ler_f ler
    where p_effective_date between ler.effective_start_date
                               and ler.effective_end_date
      and ler.typ_cd in ( 'SCHEDDO','SCHEDDA')
      and pel.ptnl_ler_for_per_stat_cd = 'UNPROCD'
      and pel.lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
      and p_person_id = pel.person_id
      and pel.ler_id  =ler.ler_id  ;
  --
  l_open  varchar2(30) := 'N' ;
  l_effective_date date := NVL(p_lf_evt_ocrd_dt,p_effective_date);
  l_mode varchar2(30) := p_mode ;
  --
  l_trace_param          varchar2(30);
  l_trace_on             boolean;
  --
begin
  p_return_status := 'S';
  l_trace_param := null;
  l_trace_on := false;
  --
  l_trace_param := fnd_profile.value('BEN_SS_TRACE_VALUE');
  --

  if l_trace_param = 'BENOLLET' then
     l_trace_on := true;
  else
     l_trace_on := false;
  end if;
  --
  if l_trace_on then
    hr_utility.trace_on(null,'BENOLLET');
  end if;
  --
  hr_utility.set_location('l_trace_param : '|| l_trace_param, 5);
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  fnd_msg_pub.initialize;

 /* One-Off bug 3697615
    The behavior of SS form function parameter 'ssProcessUnrestricted' will be as follows:
    1. If set to Y, it will always run Unrestricted Benmngle
    2. If set to P, [P for performance] it will not run unrestricted Benmngle at
       most of the cases (except when the person's data which affects eligibility has
       got changed since the last time Unrestricted was run). This is determined by calling
       benutils.run_osb_benmngle_flag
    3. If set to N, it will not run Unrestricted at all and it will also prevent the user
       from making any changes to his elections for programs enrolled into through Unrestricted LE.
  */

  if (p_mode <> 'U'
      or
     (p_mode = 'U' and p_ss_process_unrestricted <> 'N'
                   and (p_ss_process_unrestricted = 'Y'
                        or (p_ss_process_unrestricted = 'P' and
                           (benutils.run_osb_benmngle_flag(p_person_id,p_business_group_id,
                                                           p_effective_date)))))) then
  --
  hr_utility.set_location ('Calling p_manage_life_events in '||p_mode||' p_mode ', 20);
  --
  if p_lf_evt_ocrd_dt IS NOT NULL THEN
    open c_open(p_lf_evt_ocrd_dt,p_person_id);
      fetch c_open into l_open ;
      if  c_open%found then
        l_effective_date := p_effective_date ;
        l_mode := 'C';
      end if;
    close c_open ;
  end if;
	--
  --5194398: Check if POPL is locked
  if p_mode = 'U' then
    declare
      cursor c_popl_lock(p_per_in_ler_id number) is
      select null
      from   ben_pil_elctbl_chc_popl pel
      where  per_in_ler_id = p_per_in_ler_id
      for update nowait;
      l_test number;

      record_locked EXCEPTION;
      PRAGMA EXCEPTION_INIT (record_locked, -54);
      l_rec benutils.g_active_life_event;

    begin
      savepoint ben_popl_lock_savepoint;

			benutils.get_active_life_event
      (p_person_id         => p_person_id,
       p_business_group_id => p_business_group_id,
       p_effective_date    => l_effective_date,
       p_lf_event_mode     => 'U',
       p_rec               => l_rec);

      open c_popl_lock(l_rec.per_in_ler_id);
      fetch c_popl_lock into l_test;
      close c_popl_lock;

      rollback to ben_popl_lock_savepoint; --in order to release the lock(if obtained) on POPL

    exception
      when record_locked then
        hr_utility.set_location ('POPL locked. Returning without processing unrestricted.',25);
        return; --POPL is locked, so return to calling procedure without processing unrestricted
    end;
  end if;
  --
  ben_on_line_lf_evt.p_manage_life_events
    (p_person_id             => p_person_id
    ,p_effective_date        => l_effective_date -- p_effective_date
    ,p_business_group_id     => p_business_group_id
    ,p_pgm_id                => null
    ,p_pl_id                 => null
    ,p_mode                  => l_mode -- p_mode
    ,p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt
    ,p_prog_count            => l_prog_count
    ,p_plan_count            => l_plan_count
    ,p_oipl_count            => l_oipl_count
    ,p_person_count          => l_person_count
    ,p_plan_nip_count        => l_plan_nip_count
    ,p_oipl_nip_count        => l_oipl_nip_count
    ,p_ler_id                => l_ler_id
    ,p_errbuf                => l_errbuf
    ,p_retcode               => l_retcode
    );
  --
  end if;

  -- If no execption raised, clear the message cache to avoid
  -- getting "Calling ben_generate_communications".
  --
  fnd_msg_pub.initialize;
  --
  commit;
  --
  hr_utility.set_location ('Leaving '||l_proc,30);
  --
  if l_trace_on then
    hr_utility.trace_off;
    l_trace_param := null;
    l_trace_on := false;
  end if;
  --
exception
  when app_exception.application_exception then
    get_ser_message(p_encoded_message => l_encoded_message,
                    p_app_short_name  => l_app_short_name,
                    p_message_name    => l_message_name);
    --
    -- Kill the error if it is
    -- "No comp objects selected".
    -- Bug 1972460.
    --
    if (l_message_name like '%BEN_91769_NOONE_TO_PROCESS%') then
      fnd_message.set_name('BEN', 'BEN_92540_NOONE_TO_PROCESS_CM');
--      l_encoded_message := fnd_message.get;
--      copy(l_encoded_message, 'messages.message');
    end if;
-- Bug 4254792 Donot add manual LE errors to stack
    if (l_message_name = 'BEN_92396_LIFE_EVENT_MANUAL'
        or l_message_name = 'BEN_94209_MAN_LER_EXISTIS') then
      p_return_status := 'M';
    elsif l_message_name = 'BEN_92144_NO_LIFE_EVENTS' then --5211969
      commit;
    elsif (l_message_name = 'BEN_91664_BENMNGLE_NO_OBJECTS') then
      l_encoded_message := fnd_message.get_encoded;
      rollback;
    else
      p_return_status := 'E';
      fnd_msg_pub.add;
      rollback;
    end if;
--
    if l_trace_on then
      hr_utility.trace_off;
      l_trace_param := null;
      l_trace_on := false;
    end if;
    --rollback;
  --
  when others then
    fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
    fnd_message.set_token('2',substr(sqlerrm,1,200));
    fnd_msg_pub.add;
    p_return_status := 'E';
    if l_trace_on then
      hr_utility.trace_off;
      l_trace_param := null;
      l_trace_on := false;
    end if;
end p_manage_life_events_w;
--
--
-- self-service wrapper to run benmngle through
-- iRecruitment
--
procedure p_manage_irec_life_events_w(
            p_person_id             in   number
           ,p_assignment_id         in   number
	   ,p_effective_date        in   date
           ,p_business_group_id     in   number
	   ,p_offer_assignment_rec  in   per_all_assignments_f%rowtype) --bug 4621751 irec2

is
  --
  l_proc		varchar2(72) := g_package || 'p_manage_irec_life_events_w';
  l_errbuf		varchar2(2000);
  l_retcode		number;
  l_effective_date      varchar2(30);
  --
  l_encoded_message   varchar2(2000);
  l_app_short_name    varchar2(2000);
  l_message_name      varchar2(2000);
  --

begin
  --
  -- Create a save point.
     savepoint irec_life_events_savepoint; --irec2

  --hr_utility.trace_on(NULL, 'IREC2');  -- ACE
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  fnd_msg_pub.initialize;
  --
  hr_utility.set_location ('Calling p_manage_irec_life_events_w in iRecruitment (I) mode', 20);
  --
  -- l_effective_date := to_char(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date :=  fnd_date.date_to_canonical(p_effective_date);
  --
  ben_comp_object_list1.refresh_eff_date_caches;
  --
  ben_manage_life_events.irec_process
    (errbuf                     => l_errbuf,
     retcode                    => l_retcode,
     p_effective_date           => l_effective_date,
     p_mode                     => 'I',			-- Mode for iRecruitment = 'I'
     p_person_id                => p_person_id,
     p_business_group_id        => p_business_group_id,
     p_assignment_id            => p_assignment_id,
     p_offer_assignment_rec     => p_offer_assignment_rec); --bug 4621751 irec2
  --

  -- If no execption raised, clear the message cache to avoid
  -- getting "Calling ben_generate_communications".
  --
  fnd_msg_pub.initialize;
  --
  commit;
  --
  hr_utility.set_location ('Leaving '||l_proc,30);
  -- hr_utility.trace_off;
  --
exception
  when app_exception.application_exception then
    get_ser_message(p_encoded_message => l_encoded_message,
                    p_app_short_name  => l_app_short_name,
                    p_message_name    => l_message_name);
    --
    -- Kill the error if it is
    -- "No comp objects selected".
    -- Bug 1972460.
    --
    if (l_message_name like '%BEN_91769_NOONE_TO_PROCESS%') then
      fnd_message.set_name('BEN', 'BEN_92540_NOONE_TO_PROCESS_CM');
--      l_encoded_message := fnd_message.get;
--      copy(l_encoded_message, 'messages.message');
    end if;
    if (l_message_name = 'BEN_91664_BENMNGLE_NO_OBJECTS') then
      l_encoded_message := fnd_message.get_encoded;
    else
      fnd_msg_pub.add;
    end if;

    rollback to irec_life_events_savepoint;
  --
  when others then
    fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
    fnd_message.set_token('2',substr(sqlerrm,1,200));
    fnd_msg_pub.add;
   -- hr_utility.set_location(' EXCEPTION CAUGHT',9909);
    --hr_utility.trace_off;
    rollback to irec_life_events_savepoint;
end p_manage_irec_life_events_w;
--
end ben_on_line_lf_evt;

/
