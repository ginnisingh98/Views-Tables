--------------------------------------------------------
--  DDL for Package Body PAY_RUN_BALANCE_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RUN_BALANCE_WF_PKG" AS
/* $Header: pyzzrbwf.pkb 120.0 2005/05/29 10:38:10 appldev noship $ */
--
procedure verify_revalidation(itemtype in varchar2
                             ,itemkey  in varchar2
                             ,actid    in number
                             ,funcmode in varchar2
                             ,resultout out nocopy varchar2)
is
--
cursor check_status(p_def_bal_id in number
                   ,p_bg_id in number)
is
select pbv.run_balance_status
,      pbv.balance_load_date
,      hl.meaning
from   pay_balance_validation pbv
,      hr_lookups hl
where  pbv.defined_balance_id = p_def_bal_id
and    pbv.business_group_id = p_bg_id
and    hl.lookup_type = 'RUN_BALANCE_STATUS'
and    hl.lookup_code = pbv.run_balance_status;
--
business_group_id number;
defined_balance_id number;
l_status varchar2(30);
l_stat_meaning varchar2(80);
l_balance_load_date date;
begin
if (funcmode = 'RUN') THEN
--
  business_group_id := wf_engine.getactivityattrnumber
                       (itemtype => itemtype
                       ,itemkey  => itemkey
                       ,actid    => actid
                       ,aname    => 'BUSINESS_GROUP_ID');
  defined_balance_id := wf_engine.getactivityattrnumber
                       (itemtype => itemtype
                       ,itemkey  => itemkey
                       ,actid    => actid
                       ,aname    => 'DEFINED_BALANCE_ID');
  --
  open check_status(defined_balance_id, business_group_id);
  fetch check_status into l_status, l_balance_load_date, l_stat_meaning;
  if check_status%notfound then
  --
    close check_status;
    resultout := 'COMPLETE:NDF';
  else
    close check_status;
    resultout := 'COMPLETE:'||l_status;
  end if;
  wf_engine.setItemAttrText(itemtype => itemtype
                           ,itemkey  => itemkey
                           ,aname    => 'RUN_BALANCE_STATUS'
                           ,avalue   => l_stat_meaning);
  wf_engine.setItemAttrDate(itemtype => itemtype
                           ,itemkey  => itemkey
                           ,aname    => 'BALANCE_LOAD_DATE'
                           ,avalue   => l_balance_load_date);
return;
end if;
--
exception
  when others then
    WF_CORE.CONTEXT('ret_test_wf_pkg'
                   ,'verify_revalidation'
                   ,itemtype
                   ,itemkey
                   ,to_char(actid)
                   ,resultout);
    raise;
--
end verify_revalidation;
--
procedure prepare_conc_prog_params(itemtype in varchar2
                                  ,itemkey  in varchar2
                                  ,actid    in number
                                  ,funcmode in varchar2
                                  ,resultout out nocopy varchar2)
is
--
cursor get_bal_level (p_defined_balance_id in number)
is
select pbd.dimension_level
,      hl.meaning
from   pay_balance_dimensions pbd
,      pay_defined_balances db
,      hr_lookups hl
where  pbd.balance_dimension_id = db.balance_dimension_id
and    db.defined_balance_id = p_defined_balance_id
and    hl.lookup_type = 'PAY_BRA_BALANCE_LEVEL'
and    hl.lookup_code = pbd.dimension_level;
--
defined_balance_id number;
balance_load_date date;
bal_load_date_char varchar2(80);
cp_bal_start_date varchar2(80);
cp_def_bal_id varchar2(80);
cp_bal_lvl varchar2(80);
cp_bal_lvl_code varchar2(80);
cp_bal_lvl_mean varchar2(80);
begin
if (funcmode = 'RUN') THEN
--
  defined_balance_id := wf_engine.getitemattrnumber
                       (itemtype => itemtype
                       ,itemkey  => itemkey
                       ,aname    => 'DEFINED_BALANCE_ID');
  balance_load_date := wf_engine.getitemattrdate
                       (itemtype => itemtype
                       ,itemkey  => itemkey
                       ,aname    => 'BALANCE_LOAD_DATE');
  bal_load_date_char := to_char(balance_load_date,'YYYY/MM/DD');
  --
  cp_bal_start_date := 'BAL_START_DATE='||bal_load_date_char;
  cp_def_bal_id := 'DEF_BAL_ID='||to_char(defined_balance_id);
  --
  open get_bal_level(defined_balance_id);
  fetch get_bal_level into cp_bal_lvl_code, cp_bal_lvl_mean;
  if get_bal_level%notfound then
  --
    close get_bal_level;
    resultout := 'COMPLETE:NDF';
  else
    close get_bal_level;
    cp_bal_lvl := 'BAL_LVL='||cp_bal_lvl_code;
    resultout := 'COMPLETE:DF';
  end if;
  --
  -- set activity parameters
  --
  wf_engine.setItemAttrText(itemtype => itemtype
                           ,itemkey  => itemkey
                           ,aname    => 'CP_BAL_START_DATE'
                           ,avalue   => cp_bal_start_date);
  wf_engine.setItemAttrText(itemtype => itemtype
                           ,itemkey  => itemkey
                           ,aname    => 'CP_DEF_BAL_ID'
                           ,avalue   => cp_def_bal_id);
  wf_engine.setItemAttrText(itemtype => itemtype
                           ,itemkey  => itemkey
                           ,aname    => 'CP_BAL_LVL_CODE'
                           ,avalue   => cp_bal_lvl_code);
  wf_engine.setItemAttrText(itemtype => itemtype
                           ,itemkey  => itemkey
                           ,aname    => 'CP_BAL_LVL_MEAN'
                           ,avalue   => cp_bal_lvl_MEAN);
  wf_engine.setItemAttrText(itemtype => itemtype
                           ,itemkey  => itemkey
                           ,aname    => 'CP_BAL_LVL'
                           ,avalue   => cp_bal_lvl);
return;
end if;
--
exception
  when others then
    WF_CORE.CONTEXT('ret_test_wf_pkg'
                   ,'prepare_conc_prog_params'
                   ,itemtype
                   ,itemkey
                   ,to_char(actid)
                   ,resultout);
    raise;
--
end prepare_conc_prog_params;
--
--
end pay_run_balance_wf_pkg;

/
