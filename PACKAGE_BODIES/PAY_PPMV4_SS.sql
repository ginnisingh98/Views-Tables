--------------------------------------------------------
--  DDL for Package Body PAY_PPMV4_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPMV4_SS" as
/* $Header: pyppmwrs.pkb 120.7.12010000.6 2010/03/29 09:35:17 pgongada ship $ */
g_package constant varchar(2000) default 'pay_ppmv4_ss.';
g_item_type varchar2(2000);
g_item_key  varchar2(2000);
g_debug     boolean := hr_utility.debug_enabled;
--
-- Constants for payments list mode profile option.
--
C_OPM_LIST_MODE constant varchar2(127) default 'PAY_PSS_PAYMENTS_LIST';
C_OPM_LIST_MODE_ANY   constant varchar2(63) default 'ANY';
C_OPM_LIST_MODE_LIKE  constant varchar2(63) default 'LIKE';
C_OPM_LIST_MODE_MATCH constant varchar2(63) default 'MATCH';
--
procedure chk_foreign_account
( p_transaction_step_id   in varchar2
) is
--
l_dummy varchar2(1);
--
begin
  --
  -- Check whether the territory code is same as the Org payment's
  -- territory code. Otherwise raise an error.
  --
  begin
    --
       select null
       into   l_dummy
       from   sys.dual
       where  not exists
              (select null
               from   pay_pss_transaction_steps pts,
                      pay_org_payment_methods_f opm,
                      pay_payment_types ppt
               where  pts.transaction_step_id = p_transaction_step_id
               and    opm.org_payment_method_id = pts.org_payment_method_id
               and    pts.effective_date
                      between opm.effective_start_date
                      and     opm.effective_end_date
               and    opm.payment_type_id = ppt.payment_type_id
               and    ppt.category = 'MT'
               and    ppt.territory_code <> pts.territory_code);
       --
    --
  exception
    when no_data_found then
       hr_utility.set_message
       (applid         => 800
       ,l_message_name => 'PAY_449775_FOREIGN_ACCOUNT'
       );
       hr_utility.raise_error;
    when others then
       null;
  end;
end;
--
--------------------------< post_submit_work >-----------------------------
procedure post_submit_work
(p_item_type       in     varchar2
,p_item_key        in     varchar2
,p_activity_id     in     varchar2
,p_login_person_id in     varchar2
,p_transaction_id  in     varchar2
,p_assignment_id   in     varchar2
,p_effective_date  in     varchar2
,p_return_status      out nocopy varchar2
,p_msg_count          out nocopy number
,p_msg_data           out nocopy varchar2
) is
cursor csr_ppm_info(p_transaction_id in number) is
select ppts.transaction_step_id
,      ppts.state
from   pay_pss_transaction_steps ppts
where  ppts.transaction_id = p_transaction_id
and    ppts.state <> C_STATE_FREED
;
--
i                  binary_integer;
l_proc             varchar2(2000) := g_package || 'post_submit_work';
l_txstepids        t_number_tbl;
l_state            varchar2(2000);
l_changes          boolean := false;
l_review_proc_call varchar2(2000);
l_result           varchar2(2000);
l_force            boolean;
l_success          boolean;
begin
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ENTER', 0);
  fnd_msg_pub.initialize;
  --
  -- Rollback any existing HR transaction table data.
  --
  hr_transaction_ss.rollback_transaction
  (itemtype => p_item_type
  ,itemkey  => p_item_key
  ,actid    => p_activity_id
  ,funmode  => 'RUN'
  ,result   => l_result
  );
  --
  -- Set the HR TRANSACTION_ID value to null.
  --
  if hr_transaction_ss.get_transaction_id
     (p_item_type => p_item_type
     ,p_item_key  => p_item_key
     ) is not null then
    wf_engine.setitemattrtext
    (itemtype => p_item_type
    ,itemkey  => p_item_key
    ,aname    => C_HR_TXID_WF_ATTRIBUTE
    ,avalue   => null
    );
  end if;
  --
  -- Check for user changes.
  --
  i := 1;
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXECUTE_CURSOR', 10);
  for rec in csr_ppm_info(p_transaction_id => to_number(p_transaction_id)) loop
    l_changes := (l_changes or rec.state <> C_STATE_EXISTING);
    l_txstepids(i) := rec.transaction_step_id;
    i := i + 1;
  end loop;
  --
  -- Allocate real priorities and write to HR transaction tables if there
  -- were any changes.
  --
  if l_changes then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ALLOC_REAL_PRIORITIES', 20);

    alloc_real_priorities
    (p_transaction_id => p_transaction_id
    ,p_assignment_id  => p_assignment_id
    ,p_effective_date => p_effective_date
    ,p_success        => l_success
    );
    if not l_success then
      pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:FAIL:1', 25);
      fnd_message.set_name('PAY', 'PAY_51518_PSS_ASSERT_ERROR');
      fnd_message.set_token('WHERE', l_proc);
      fnd_message.set_token('ADDITIONAL_INFO', '<REAL PRIORITY ALLOC FAIL>');
      fnd_msg_pub.add;
      p_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
      (p_count => p_msg_count
      ,p_data  => p_msg_data
      );
      return;
    end if;
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'C_REVIEW_REGION_ITEM', 30);
    l_review_proc_call := pay_ppmv4_utils_ss.read_wf_config_option
    (p_item_type   => p_item_type
    ,p_item_key    => p_item_key
    ,p_activity_id => p_activity_id
    ,p_option      => pay_ppmv4_utils_ss.C_REVIEW_REGION_ITEM
    );
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'PPM2HRTT', 30);
    for i in 1 .. l_txstepids.count loop
      l_force := (i = 1);
      pay_ppmv4_utils_ss.ppm2hrtt
      (p_item_type             => p_item_type
      ,p_item_key              => p_item_key
      ,p_activity_id           => p_activity_id
      ,p_login_person_id       => p_login_person_id
      ,p_review_proc_call      => l_review_proc_call
      ,p_transaction_step_id   => l_txstepids(i)
      ,p_force_new_transaction => l_force
      );
    end loop;
    commit;
  end if;
  p_return_status := fnd_api.G_RET_STS_SUCCESS;
  p_msg_count := 0;
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 40);
exception
  when others then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:FAIL:2', 50);
    fnd_message.set_name('PAY', 'PAY_51518_PSS_ASSERT_ERROR');
    fnd_message.set_token('WHERE', l_proc);
    fnd_message.set_token('ADDITIONAL_INFO', sqlerrm);
    fnd_msg_pub.add;
    p_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get
    (p_count => p_msg_count
    ,p_data  => p_msg_data
    );
    return;
end post_submit_work;
---------------------------< include_in_page >-----------------------------
function include_in_page
(p_page  in varchar2
,p_state in varchar2
) return varchar2 is
include boolean := false;
begin
  --
  -- Only interested in the Summary and Review Pages.
  --
  if p_page = C_SUMMARY_PAGE then
    include :=
    (p_state <> C_STATE_FREED and p_state <> C_STATE_DELETED);
  elsif p_page = C_REVIEW_PAGE then
    include :=
    (p_state <> C_STATE_FREED and p_state <> C_STATE_EXISTING);
  end if;
  --
  -- Include the change.
  --
  if include then
    return 'Y';
  end if;
  --
  -- Don't include the change.
  --
  return 'N';
end include_in_page;
------------------------< update_remaining_pay_ppm >-----------------------
procedure update_remaining_pay_ppm
(p_transaction_id in number
) is
l_txstepids   varchar2(2000);
l_amount_type varchar2(2000);
l_start       number;
l_next        varchar2(2000);
l_txstepid    number;
l_state       varchar2(2000);
l_ppm         pay_ppmv4_utils_ss.t_ppmv4;
l_changes     boolean;
l_bank        boolean;
begin
  l_txstepids := gettxstepids
  (p_transaction_id => p_transaction_id
  ,p_summary_page   => true
  );
  if l_txstepids is null then
    return;
  else
    l_start := 1;
    loop
      exit when l_start = 0;
      --
      l_next := pay_ppmv4_utils_ss.nextentry
      (p_list      => l_txstepids
      ,p_separator => C_COMMA
      ,p_start     => l_start
      );
      l_txstepid := to_number(l_next);
    end loop;
    --
    -- Need to check for state changes in this PPM.
    --
    select p.state
    ,      p.amount_type
    into   l_state
    ,      l_amount_type
    from   pay_pss_transaction_steps p
    where   p.transaction_step_id = l_txstepid;
    if l_state = C_STATE_EXISTING and
       l_amount_type <> C_REMAINING_PAY then
      l_state := C_STATE_UPDATED;
    elsif l_state = C_STATE_UPDATED then
      --
      -- Check if this results in a net change.
      --
      pay_ppmv4_utils_ss.tt2ppm
      (p_transaction_step_id => l_txstepid
      ,p_ppm                 => l_ppm
      );
      l_ppm.amount_type := C_REMAINING_PAY;
      l_ppm.amount := 100;
      pay_ppmv4_utils_ss.changedppm
      (p_ppm     => l_ppm
      ,p_changes => l_changes
      ,p_bank    => l_bank
      );
      if not l_changes then
        l_state := C_STATE_EXISTING;
      end if;
    end if;
    --
    -- Update the lowest priority PPM.
    --
    update pay_pss_transaction_steps p
    set    p.amount_type = C_REMAINING_PAY
    ,      p.amount      = 100
    ,      p.state       = l_state
    where  transaction_step_id = l_txstepid
    ;
  end if;
end update_remaining_pay_ppm;
-------------------------------< getwfattr >-------------------------------
function getwfattr
(p_item_type in varchar2
,p_item_key  in varchar2
,p_attr_name in varchar2
,p_ignore    in boolean  default true
) return varchar2 is
l_value varchar2(2000);
begin
  l_value :=
  wf_engine.getitemattrtext(p_item_type, p_item_key, p_attr_name, p_ignore);
  if g_debug then
    hr_utility.trace
    (g_package || 'getwfattr(' || p_attr_name || ')=' || l_value || ')');
  end if;
  return l_value;
end getwfattr;
---------------------------------< add2wf >--------------------------------
procedure add2wf
(p_item_type in varchar2
,p_item_key  in varchar2
,p_attr_name in varchar2
,p_value     in varchar2
) is
begin
  if g_debug then
    hr_utility.trace
    (g_package || 'add2wf(' || p_attr_name || ',' || p_value || ')');
  end if;
  wf_engine.additemattr
  (itemtype   => p_item_type
  ,itemkey    => p_item_key
  ,aname      => p_attr_name
  ,text_value => p_value
  );
end add2wf;
---------------------------------< db2tts >--------------------------------
procedure db2tts
(p_assignment_id        in     varchar2
,p_effective_date       in     varchar2
,p_amount_type          in     varchar2
,p_item_type            in     varchar2 default null
,p_item_key             in     varchar2 default null
,p_run_type_id          in     varchar2 default null
,p_transaction_id          out nocopy varchar2
,p_prepayments             out nocopy varchar2
,p_return_status           out nocopy varchar2
,p_msg_count               out nocopy number
,p_msg_data                out nocopy varchar2
) is
--
-- Count the PPMs for this assignment.
--
cursor csr_ppm_count
(p_assignment_id  in number
,p_effective_date in date
) is
select count(0)
from pay_personal_payment_methods_f ppm
,    pay_org_payment_methods_f opm
where  ppm.assignment_id = p_assignment_id
and    nvl(ppm.run_type_id, hr_api.g_number) = nvl(p_run_type_id, hr_api.g_number)
and    p_effective_date between
       ppm.effective_start_date and ppm.effective_end_date
and    opm.org_payment_method_id = ppm.org_payment_method_id
and    opm.defined_balance_id is not null
and    p_effective_date between
       opm.effective_start_date and opm.effective_end_date
;

--
-- Fetch current PPMs for this assignment.
--
cursor csr_ppms
(p_assignment_id  in number
,p_effective_date in date
) is
select null
      ,null
      ,C_PAY_PERSONAL_PAYMENT_METHODS
      ,C_STATE_EXISTING
      ,ppm.personal_payment_method_id
      ,ppm.object_version_number
      ,ppm.object_version_number
      ,null
      ,null
      ,'N'
      ,ppm.effective_start_date
      ,ppm.org_payment_method_id
      ,p_assignment_id
      ,ppt.category
      ,pbt.currency_code
      ,pay_ppmv4_ss.get_ppm_country(ppm.org_payment_method_id,ppm.business_group_id)
      ,ppm.priority
      ,null
      ,decode(ppm.percentage, null, C_MONETARY, C_PERCENTAGE)
      ,decode(ppm.percentage, null, ppm.amount, ppm.percentage)
      ,ppm.external_account_id
      ,ppm.attribute_category
      ,ppm.attribute1
      ,ppm.attribute2
      ,ppm.attribute3
      ,ppm.attribute4
      ,ppm.attribute5
      ,ppm.attribute6
      ,ppm.attribute7
      ,ppm.attribute8
      ,ppm.attribute9
      ,ppm.attribute10
      ,ppm.attribute11
      ,ppm.attribute12
      ,ppm.attribute13
      ,ppm.attribute14
      ,ppm.attribute15
      ,ppm.attribute16
      ,ppm.attribute17
      ,ppm.attribute18
      ,ppm.attribute19
      ,ppm.attribute20
      ,ppm.priority
      ,null
      ,decode(ppm.percentage, null, C_MONETARY, C_PERCENTAGE)
      ,decode(ppm.percentage, null, ppm.amount, ppm.percentage)
      ,ppm.external_account_id
      ,ppm.attribute_category
      ,ppm.attribute1
      ,ppm.attribute2
      ,ppm.attribute3
      ,ppm.attribute4
      ,ppm.attribute5
      ,ppm.attribute6
      ,ppm.attribute7
      ,ppm.attribute8
      ,ppm.attribute9
      ,ppm.attribute10
      ,ppm.attribute11
      ,ppm.attribute12
      ,ppm.attribute13
      ,ppm.attribute14
      ,ppm.attribute15
      ,ppm.attribute16
      ,ppm.attribute17
      ,ppm.attribute18
      ,ppm.attribute19
      ,ppm.attribute20
      ,ppm.run_type_id
      ,ppm.ppm_information_category
      ,ppm.ppm_information1
      ,ppm.ppm_information2
      ,ppm.ppm_information3
      ,ppm.ppm_information4
      ,ppm.ppm_information5
      ,ppm.ppm_information6
      ,ppm.ppm_information7
      ,ppm.ppm_information8
      ,ppm.ppm_information9
      ,ppm.ppm_information10
      ,ppm.ppm_information11
      ,ppm.ppm_information12
      ,ppm.ppm_information13
      ,ppm.ppm_information14
      ,ppm.ppm_information15
      ,ppm.ppm_information16
      ,ppm.ppm_information17
      ,ppm.ppm_information18
      ,ppm.ppm_information19
      ,ppm.ppm_information20
      ,ppm.ppm_information21
      ,ppm.ppm_information22
      ,ppm.ppm_information23
      ,ppm.ppm_information24
      ,ppm.ppm_information25
      ,ppm.ppm_information26
      ,ppm.ppm_information27
      ,ppm.ppm_information28
      ,ppm.ppm_information29
      ,ppm.ppm_information30
	  ,ppm.ppm_information_category
      ,ppm.ppm_information1
      ,ppm.ppm_information2
      ,ppm.ppm_information3
      ,ppm.ppm_information4
      ,ppm.ppm_information5
      ,ppm.ppm_information6
      ,ppm.ppm_information7
      ,ppm.ppm_information8
      ,ppm.ppm_information9
      ,ppm.ppm_information10
      ,ppm.ppm_information11
      ,ppm.ppm_information12
      ,ppm.ppm_information13
      ,ppm.ppm_information14
      ,ppm.ppm_information15
      ,ppm.ppm_information16
      ,ppm.ppm_information17
      ,ppm.ppm_information18
      ,ppm.ppm_information19
      ,ppm.ppm_information20
      ,ppm.ppm_information21
      ,ppm.ppm_information22
      ,ppm.ppm_information23
      ,ppm.ppm_information24
      ,ppm.ppm_information25
      ,ppm.ppm_information26
      ,ppm.ppm_information27
      ,ppm.ppm_information28
      ,ppm.ppm_information29
      ,ppm.ppm_information30
from   pay_personal_payment_methods_f ppm
,      pay_org_payment_methods_f      opm
,      pay_payment_types              ppt
,      pay_defined_balances           pdb
,      pay_balance_types              pbt
where  ppm.assignment_id = p_assignment_id
and    nvl(ppm.run_type_id, hr_api.g_number) = nvl(p_run_type_id, hr_api.g_number)
and    p_effective_date between
       ppm.effective_start_date and ppm.effective_end_date
and    opm.org_payment_method_id = ppm.org_payment_method_id
and    p_effective_date between
       opm.effective_start_date and opm.effective_end_date
and    opm.defined_balance_id is not null
and    pdb.defined_balance_id = opm.defined_balance_id
and    pbt.balance_type_id = pdb.balance_type_id
and    ppt.payment_type_id = opm.payment_type_id
order  by ppm.priority
;
--
-- Check for future-dated prepayments.
--
cursor csr_prepayments_check
(p_personal_payment_method_id in number
,p_effective_date             in date
) is
select 'Y'
from   pay_pre_payments ppp
,      pay_assignment_actions paa
,      pay_payroll_actions ppa
where  ppp.personal_payment_method_id = p_personal_payment_method_id
and    paa.assignment_action_id = ppp.assignment_action_id
and    ppa.payroll_action_id = paa.payroll_action_id
and    ppa.effective_date >= p_effective_date
;
--
-- Date-track row count (to get the delete mode).
--
cursor csr_dt_row_count
(p_personal_payment_method_id in number
) is
select count(0)
from   pay_personal_payment_methods_f ppm
where  ppm.personal_payment_method_id = p_personal_payment_method_id
;
l_effective_date date;
l_ppm            pay_ppmv4_utils_ss.t_ppmv4;
l_dummy          varchar2(1);
i                binary_integer;
irt              binary_integer;
l_count          number;
l_dt_count       number;
l_transaction_id number := null;
l_item_type      varchar2(2000);
l_item_key       varchar2(2000);
l_proc           varchar2(2000) := g_package || 'db2tts';
begin

  savepoint db2tts;
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ENTER', 0);
  --
  fnd_msg_pub.initialize;
  -------------------------------------------------------------------
  -- Check if this routine has been called before and use workflow --
  -- item attributes to return the values.                         --
  -------------------------------------------------------------------
  l_item_type := nvl(p_item_type, g_item_type);
  l_item_key := nvl(p_item_key, g_item_key);
  if getwfattr(l_item_type, l_item_key, C_GOT_CONFIG2_WF_ATTR) is not null then
    p_prepayments :=
    getwfattr(l_item_type, l_item_key, C_PREPAYMENTS_WF_ATTR, false);
    p_transaction_id :=
    getwfattr(l_item_type, l_item_key, C_PSS_TXID_WF_ATTRIBUTE, false);
    --
    -- Set successful return status.
    --
    p_return_status := fnd_api.G_RET_STS_SUCCESS;
    fnd_msg_pub.count_and_get
    (p_count => p_msg_count
    ,p_data  => p_msg_data
    );
    return;
  end if;
  --
  -- Flag that this part of the code is being entered.
  --
  add2wf(l_item_type, l_item_key, C_GOT_CONFIG2_WF_ATTR, 'Y');
  --
  l_effective_date :=
  to_date(p_effective_date, hr_transaction_ss.g_date_format);
  p_prepayments := 'N';
  add2wf(l_item_type, l_item_key, C_PREPAYMENTS_WF_ATTR, 'N');
  --
  -- Count the PPMs.
  --
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'FETCH_PPMS', 5);
  open csr_ppm_count
  (p_assignment_id  => p_assignment_id
  ,p_effective_date => l_effective_date
  );
  fetch csr_ppm_count into l_count;
  close csr_ppm_count;
  if l_count = 0 then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 10);
    --
    -- Return the transaction_id.
    --
    select pay_pss_transactions_s.nextval
    into   l_transaction_id
    from   dual;
    p_transaction_id := to_char(l_transaction_id);
    add2wf(l_item_type, l_item_key, C_PSS_TXID_WF_ATTRIBUTE, l_transaction_id);
    p_msg_count := 0;
    p_return_status := fnd_api.G_RET_STS_SUCCESS;
    return;
  end if;
  --
  -- Fetch the PPMs.
  --
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'FETCH_PPMS', 15);
  i := 1;
  open csr_ppms
  (p_assignment_id  => p_assignment_id
  ,p_effective_date => l_effective_date
  );
  loop
    fetch csr_ppms into l_ppm;
    exit when csr_ppms%notfound;
    --
    -- Set the logical priority.
    --
    l_ppm.logical_priority := i;
    l_ppm.o_logical_priority := i;
    --
    -- If the amount type is restricted then it's necessary to
    -- restrict l_ppm.amount_type accordingly. The configuration
    -- options should have already been checked for consistency against
    -- the user's data.
    --
    if p_amount_type = C_MONETARY_ONLY then
      l_ppm.amount_type := C_MONETARY_ONLY;
    elsif p_amount_type = C_PERCENTAGE_ONLY then
      l_ppm.amount_type := C_PERCENTAGE_ONLY;
    end if;
    --
    -- Check for future-dated prepayments.
    --
    pay_ppmv4_utils_ss.seterrorstage
    (l_proc, 'PREPAYMENTS_CHECK:' || to_char(i), 20);
    open csr_prepayments_check
    (p_personal_payment_method_id => l_ppm.personal_payment_method_id
    ,p_effective_date             => l_effective_date
    );
    fetch csr_prepayments_check into l_dummy;
    if csr_prepayments_check%found then
      p_prepayments := 'Y';
      wf_engine.setitemattrtext(l_item_type, l_item_key, C_PREPAYMENTS_WF_ATTR, 'Y');
      --
      -- Cannot delete the PPM if it is referenced in future-dated
      -- prepayments.
      --
      l_ppm.delete_disabled := 'Y';
    end if;
    close csr_prepayments_check;
    --
    -- Fill in the date-track modes.
    --
    pay_ppmv4_utils_ss.seterrorstage
    (l_proc, 'SET_DT_MODES:' || to_char(i), 30);
    if l_ppm.effective_date = l_effective_date then
      l_ppm.update_datetrack_mode := hr_api.g_correction;
      --
      -- Need to check whether or not there are preceding date-track rows as
      -- this affects the delete date-track mode.
      --
      pay_ppmv4_utils_ss.seterrorstage
      (l_proc, 'DT_ROW_COUNT:' || to_char(i), 40);
      open csr_dt_row_count
      (p_personal_payment_method_id => l_ppm.personal_payment_method_id
      );
      fetch csr_dt_row_count into l_dt_count;
      if l_dt_count > 1 then
        l_ppm.delete_datetrack_mode := hr_api.g_delete;
        --
        -- Get the object version number for the preceding row - as the
        -- delete is done on that row.
        --
        select ppm.object_version_number
        into   l_ppm.delete_ovn
        from   pay_personal_payment_methods_f ppm
        where  ppm.personal_payment_method_id =
               l_ppm.personal_payment_method_id
        and    ppm.effective_end_date = (l_effective_date-1);
      else
        l_ppm.delete_datetrack_mode := hr_api.g_zap;
      end if;
      close csr_dt_row_count;
    else
      l_ppm.update_datetrack_mode := hr_api.g_update;
      l_ppm.delete_datetrack_mode := hr_api.g_delete;
    end if;
    --
    -- Set the effective date to the correct value.
    --
    l_ppm.effective_date := l_effective_date;
    --
    -- Mark the Remaining Pay PPM (amount is 100%).
    --
    if p_run_type_id is null and i = l_count then
      l_ppm.amount_type := C_REMAINING_PAY;
      l_ppm.amount := 100;
      l_ppm.o_amount_type := C_REMAINING_PAY;
      l_ppm.o_amount := 100;
    end if;
    --
    -- Now, create a transaction table entry for this PPM.
    --
    pay_ppmv4_utils_ss.seterrorstage
    (l_proc, 'WRITE_TRANSACTION:' || to_char(i), 50);
    if i > 1 then
     l_ppm.transaction_id := l_transaction_id;
    end if;
    pay_ppmv4_utils_ss.ppm2tt
    (p_ppm => l_ppm
    );
    --
    -- Save the transaction_id.
    --
    if i = 1 then
      l_transaction_id := l_ppm.transaction_id;
    end if;
    --
    i := i + 1;
  end loop;
  close csr_ppms;
  p_transaction_id := l_transaction_id;
  add2wf(l_item_type, l_item_key, C_PSS_TXID_WF_ATTRIBUTE, l_transaction_id);
  p_msg_count := 0;
  p_return_status := fnd_api.G_RET_STS_SUCCESS;
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 60);
  return;
exception
  when others then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:FAIL', 70);
    if csr_ppm_count%isopen then
      close csr_ppm_count;
    end if;
    --
    if csr_ppms%isopen then
      close csr_ppms;
    end if;
    --
    if csr_prepayments_check%isopen then
      close csr_prepayments_check;
    end if;
    --
    if csr_dt_row_count%isopen then
      close csr_dt_row_count;
    end if;
    --
    rollback to db2tts;
    --
    -- Set up messages to Oracle Applications API standards as these
    -- are handled "for free" using checkErrors.
    --
    p_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.initialize;
    fnd_message.set_name('PAY', 'PAY_51518_PSS_ASSERT_ERROR');
    fnd_message.set_token('WHERE', l_proc);
    fnd_message.set_token('ADDITIONAL_INFO', sqlerrm);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get
    (p_count => p_msg_count
    ,p_data  => p_msg_data
    );
    return;
end db2tts;
--------------------------------< getcustomopms >----------------------------
--
-- {Start Of Comments}
--
-- Description:
--
--  akadam     30-DEC-2006 115.26  5739568
--
--  Returns the OPMID's of different Payment category depending upon the value
--  of the profile PAY_PSS_PAYMENT_FUNCTION.
--
--  If profile PAY_PSS_PAYMENT_FUNCTION value is ALL then it would return a string of
--  ALL valid OPMID's for each of the payment category attached to the payroll attached
--  to the assignment.
--
--  If profile PAY_PSS_PAYMENT_FUNCTION is null then this function will not be called.
--
--  If profile PAY_PSS_PAYMENT_FUNCTION is not null and ALL then the value should be a
--  valid function name which would be dynamically executed and for each of the payment
--  category and the returned OPMID would be returned.
--
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   The OUT parameters are filled in for the required payment types.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure getcustomopms
(p_assignment_id  in     number
,p_effective_date in     date
,p_cash           in     boolean
,p_check          in     boolean
,p_deposit        in     boolean
,p_function       in     varchar2
,p_show_paymthd_lov  in     varchar2
,p_cash_opmid        out nocopy number
,p_check_opmid       out nocopy number
,p_deposit_opmid     out nocopy number
,p_faa_ch_opmid_list  out nocopy varchar2
,p_faa_ca_opmid_list   out nocopy varchar2
,p_faa_mt_opmid_list out nocopy varchar2
) is
--
-- Cursor for fetching the OPMs.
--
cursor csr_opms
(p_assignment_id  in number
,p_effective_date in date
,p_category       in varchar2
,p_org_payment_id in number
) is
select opm.org_payment_method_id   opmid
from   pay_org_payment_methods_f   opm
,      per_all_assignments_f       paa
,      pay_org_pay_method_usages_f popmu
,      pay_payment_types           ppt
where  paa.assignment_id = p_assignment_id
and    p_effective_date between
       paa.effective_start_date and paa.effective_end_date
and    opm.org_payment_method_id =  p_org_payment_id
and    popmu.payroll_id = paa.payroll_id
and    p_effective_date between
       popmu.effective_start_date and popmu.effective_end_date
and    opm.org_payment_method_id = popmu.org_payment_method_id
and    opm.defined_balance_id is not null
and    p_effective_date between
       opm.effective_start_date and opm.effective_end_date
and    ppt.payment_type_id = opm.payment_type_id
and    ppt.category = p_category
;

cursor csr_allopms
(p_assignment_id  in number
,p_effective_date in date
,p_category       in varchar2
) is
select opm.org_payment_method_id   opmid
from   pay_org_payment_methods_f   opm
,      per_all_assignments_f       paa
,      pay_org_pay_method_usages_f popmu
,      pay_payment_types           ppt
where  paa.assignment_id = p_assignment_id
and    p_effective_date between
       paa.effective_start_date and paa.effective_end_date
and    popmu.payroll_id = paa.payroll_id
and    p_effective_date between
       popmu.effective_start_date and popmu.effective_end_date
and    opm.org_payment_method_id = popmu.org_payment_method_id
and    opm.defined_balance_id is not null
and    p_effective_date between
       opm.effective_start_date and opm.effective_end_date
and    ppt.payment_type_id = opm.payment_type_id
and    ppt.category = p_category
;


--
--
l_category      varchar2(2000);
l_opmids        varchar2(2000);
l_opmid         number;
l_found         boolean;
l_cash_found    boolean;
l_check_found   boolean;
l_deposit_found boolean;
l_sql_stat      varchar2(4000);
l_faa_ch_opmid_list  varchar2(32767);
l_faa_ca_opmid_list   varchar2(32767);
l_faa_mt_opmid_list varchar2(32767);
j               binary_integer;

begin
  --
    l_faa_ch_opmid_list := '(';
    l_faa_ca_opmid_list := '(';
    l_faa_mt_opmid_list := '(';

  for i in 1..3 loop
    --
    if i=1 then
      l_category := C_DEPOSIT;
      l_found    := not p_deposit;
    elsif i=2 then
      l_category := C_CHECK;
      l_found    := not p_check;
    elsif i=3 then
      l_category := C_CASH;
      l_found    := not p_cash;
    end if;
    --

    if p_show_paymthd_lov = C_YES then
       /* Bug#9044653
        * Clearing the flags to have a fresh values.
        * This enables us to display respective buttons
        * depending on the payment types attached to the payroll*/
       l_found := false;
       l_opmid := null;
       for rec in csr_allopms
        (p_assignment_id  => p_assignment_id
        ,p_effective_date => p_effective_date
        ,p_category       => l_category
        ) loop
          l_opmids := to_char(rec.opmid);

            if i = 1 then
              if not l_found then
                l_opmid := rec.opmid;
              end if;
              l_found := true;
              l_faa_mt_opmid_list := l_faa_mt_opmid_list || l_opmids ||',';
            elsif i = 2 then
              if not l_found then
                l_opmid := rec.opmid;
              end if;
              l_found := true;
              l_faa_ch_opmid_list := l_faa_ch_opmid_list || l_opmids ||',';
            else
              if not l_found then
                l_opmid := rec.opmid;
              end if;
              l_found := true;
             l_faa_ca_opmid_list := l_faa_ca_opmid_list || l_opmids ||',';
            end if;


       end loop;
    else
        if not l_found then
        --
          l_sql_stat:='select '||p_function||'('||p_assignment_id||','''||to_char(p_effective_date)||''','''||l_category||''') from sys.dual';
          --
          begin
            execute immediate l_sql_stat into l_opmid;
          exception
            when others then
              fnd_message.set_name('PER', 'PAY_34069_NO_PAY_METHOD');
              fnd_msg_pub.add;
              fnd_message.raise_error;
          end;
          --
          open csr_opms(p_assignment_id,p_effective_date,l_category,l_opmid);
          fetch csr_opms into l_opmid;
          if csr_opms%notfound then
            close csr_opms;
            fnd_message.set_name('PER', 'PAY_34069_NO_PAY_METHOD');
            fnd_msg_pub.add;
            fnd_message.raise_error;
          end if;
          close csr_opms;
          --
          l_found := TRUE;
          --
        end if;
    end if;
    --
    -- Update the payment category-specific variables.
    --

    if p_show_paymthd_lov = C_YES then

        if i = 1 then
          l_deposit_found := l_found;
          p_deposit_opmid := l_opmid;
          l_faa_mt_opmid_list := rtrim(l_faa_mt_opmid_list,',') || ')';
        elsif i = 2 then
          l_check_found := l_found;
          p_check_opmid := l_opmid;
          l_faa_ch_opmid_list := rtrim(l_faa_ch_opmid_list,',') || ')';
        else
          l_cash_found := l_found;
          p_cash_opmid := l_opmid;
          l_faa_ca_opmid_list := rtrim(l_faa_ca_opmid_list,',') || ')';
        end if;

    else
        if i = 1 then
          l_deposit_found := l_found;
          p_deposit_opmid := l_opmid;
          l_faa_mt_opmid_list := l_faa_mt_opmid_list || to_char(p_deposit_opmid) || ')';
        elsif i = 2 then
          l_check_found := l_found;
          p_check_opmid := l_opmid;
          l_faa_ch_opmid_list := l_faa_ch_opmid_list || to_char(p_check_opmid) || ')';
        else
          l_cash_found := l_found;
          p_cash_opmid := l_opmid;
          l_faa_ca_opmid_list := l_faa_ca_opmid_list || to_char(p_cash_opmid) || ')';
        end if;
     end if;

    p_faa_ch_opmid_list := l_faa_ch_opmid_list;
    p_faa_ca_opmid_list := l_faa_ca_opmid_list;
    p_faa_mt_opmid_list := l_faa_mt_opmid_list;
    --
  end loop;
  --
  --
  -- Output error message.
  --
  if not l_cash_found and not l_check_found and not l_deposit_found then
    fnd_message.set_name('PER', 'PAY_52626_NO_PAYMENT_TYPES');
    fnd_msg_pub.add;
    fnd_message.raise_error;
  end if;
  --

end getcustomopms;

--------------------------------< getopms >----------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Returns the OPMIDs of the first OPM of the required type from the
--   supplied configuration information.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   The OUT parameters are filled in for the required payment types.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure getopms
(p_assignment_id  in     number
,p_effective_date in     date
,p_cash           in     boolean
,p_check          in     boolean
,p_deposit        in     boolean
,p_deposit_list   in     varchar2
,p_cash_list      in     varchar2
,p_check_list     in     varchar2
,p_cash_opmid        out nocopy number
,p_check_opmid       out nocopy number
,p_deposit_opmid     out nocopy number
) is
--
-- Cursor for fetching the OPMs.
--
cursor csr_opms
(p_assignment_id  in number
,p_effective_date in date
,p_category       in varchar2
) is
select opm.org_payment_method_name name
,      opm.org_payment_method_id   opmid
from   pay_org_payment_methods_f   opm
,      per_all_assignments_f       paa
,      pay_org_pay_method_usages_f popmu
,      pay_payment_types           ppt
where  paa.assignment_id = p_assignment_id
and    p_effective_date between
       paa.effective_start_date and paa.effective_end_date
and    popmu.payroll_id = paa.payroll_id
and    p_effective_date between
       popmu.effective_start_date and popmu.effective_end_date
and    opm.org_payment_method_id = popmu.org_payment_method_id
and    opm.defined_balance_id is not null
and    p_effective_date between
       opm.effective_start_date and opm.effective_end_date
and    ppt.payment_type_id = opm.payment_type_id
and    ppt.category = p_category
;
--
type t_opm_tbl is table of varchar2(2000) index by binary_integer;
--
l_opm_list_mode varchar2(64);
l_category      varchar2(2000);
l_opms          t_opm_tbl;
l_opmids        t_opm_tbl;
l_opmid         number;
l_found         boolean;
l_cash_found    boolean;
l_check_found   boolean;
l_deposit_found boolean;
l_list          long;
l_start         number;
l_name          long;
j               binary_integer;
begin
  --
  -- Get and set the mode in which the payment lists will be used. The default
  -- mode is C_OPM_LIST_MODE_MATCH.
  --
  l_opm_list_mode :=
  nvl(upper(fnd_profile.value(name => C_OPM_LIST_MODE)), C_OPM_LIST_MODE_MATCH);
  if l_opm_list_mode <> C_OPM_LIST_MODE_MATCH and
     l_opm_list_mode <> C_OPM_LIST_MODE_ANY and
     l_opm_list_mode <> C_OPM_LIST_MODE_LIKE
  then
     l_opm_list_mode := C_OPM_LIST_MODE_MATCH;
  end if;
  begin
    for i in 1 .. 3 loop
      --
      -- Initialise general variables.
      --
      l_opms.delete;
      l_opmids.delete;
      l_opmid := null;
      if i = 1 then
        l_category := C_DEPOSIT;
        l_found := not p_deposit;
        l_list := p_deposit_list;
      elsif i = 2 then
        l_category := C_CHECK;
        l_found := not p_check;
        l_list := p_check_list;
      else
        l_category := C_CASH;
        l_found := not p_cash;
        l_list := p_cash_list;
      end if;
      --
      -- Only search if required.
      --
      if not l_found then
        --
        -- Read in OPMs by category.
        --
        j := 1;
        for rec in csr_opms
        (p_assignment_id  => p_assignment_id
        ,p_effective_date => p_effective_date
        ,p_category       => l_category
        ) loop
          l_opms(j) := upper(rec.name);
          l_opmids(j) := to_char(rec.opmid);
          j := j + 1;
        end loop;
        --
        -- ANY suitable OPM will do.
        --
        if l_opm_list_mode = C_OPM_LIST_MODE_ANY then
          if l_opmids.exists(1) then
            l_found := true;
            l_opmid := l_opmids(1);
          end if;
        else
          --
          -- Match the opm names against the list for the category.
          --
          l_start := 1;
          loop
            exit when (l_found or l_start = 0);
            --
            l_name := pay_ppmv4_utils_ss.nextentry
            (p_list      => l_list
            ,p_separator => C_LIST_SEPARATOR
            ,p_start     => l_start
            );
            l_name := upper(l_name);
            -- Prevent LIKE behaving like ANY.
            exit when l_name is null;
            --
            -- Look for a match.
            --
            j := l_opms.first;
            loop
              exit when (l_found or not l_opms.exists(j));
              --
              -- OPM name must MATCH.
              --
              if l_opm_list_mode = C_OPM_LIST_MODE_MATCH then
                if l_opms(j) = l_name then
                  l_found := true;
                  l_opmid := l_opmids(j);
                end if;
              --
              -- OPM name is LIKE list name.
              --
              elsif l_opm_list_mode = C_OPM_LIST_MODE_LIKE then
                if l_opms(j) like '%' || l_name || '%' then
                  l_found := true;
                  l_opmid := l_opmids(j);
                end if;
              end if;
              --
              j := l_opms.next(j);
            end loop;
          end loop;
        end if;
      end if;
      --
      -- Update the payment category-specific variables.
      --
      if i = 1 then
        l_deposit_found := l_found;
        p_deposit_opmid := l_opmid;
      elsif i = 2 then
        l_check_found := l_found;
        p_check_opmid := l_opmid;
      else
        l_cash_found := l_found;
        p_cash_opmid := l_opmid;
      end if;
    end loop;

  exception
    when others then
      --
      -- Output error message for unexpected error.
      --
      if csr_opms%isopen then
        close csr_opms;
      end if;
      fnd_message.set_name('PAY', 'PAY_50405_PSS_CFG_PROC_ERROR');
      fnd_message.set_token('STAGE', 'GET_OPMS');
      fnd_message.set_token('ADDITIONAL_INFO', sqlerrm);
      fnd_msg_pub.add;
      fnd_message.raise_error;
  end;
  --
  -- Output error message.
  --
  if not l_cash_found and not l_check_found and not l_deposit_found then
    fnd_message.set_name('PER', 'PAY_52626_NO_PAYMENT_TYPES');
    fnd_msg_pub.add;
    fnd_message.raise_error;
  end if;
end getopms;

-------------------------------< getpayrollinfo >--------------------------
procedure getpayrollinfo
(p_assignment_id        in     number
,p_effective_date       in     date
,p_default_payment_type    out nocopy varchar2
,p_prenote_required        out nocopy varchar2
,p_payroll_id  out nocopy varchar2
) is
cursor csr_getpayrollinfo
(p_assigment_id   in number
,p_effective_date in date
) is
select ppt.category
,      nvl(ppt.territory_code, hr_api.return_legislation_code(paa.business_group_id))
,      pap.prl_information3
,      paa.payroll_id
from   per_all_assignments_f paa
,      pay_all_payrolls_f    pap
,      pay_org_payment_methods_f popm
,      pay_payment_types ppt
where  paa.assignment_id = p_assignment_id
and    p_effective_date between
       paa.effective_start_date and paa.effective_end_date
and    pap.payroll_id = paa.payroll_id
and    p_effective_date between
       pap.effective_start_date and pap.effective_end_date
and    popm.org_payment_method_id(+) = pap.default_payment_method_id
and    p_effective_date between
       popm.effective_start_date and popm.effective_end_date
and    ppt.payment_type_id = popm.payment_type_id
;
--
l_payment_type    varchar2(2000);
l_territory_code  varchar2(2000);
l_prenote_allowed varchar2(2000);
l_proc            varchar2(2000) := g_package || 'getpayrollinfo';
l_payroll_id per_all_assignments_f.payroll_id%TYPE;

begin
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ENTER', 0);
  open csr_getpayrollinfo
  (p_assigment_id   => p_assignment_id
  ,p_effective_date => p_effective_date
  );
  fetch csr_getpayrollinfo
  into  l_payment_type
  ,     l_territory_code
  ,     l_prenote_allowed
  ,     l_payroll_id
  ;
  close csr_getpayrollinfo;
  p_default_payment_type := l_payment_type;
  --
  -- PRL_INFORMATION3 is used as a "Prenote Allowed" indicator on the
  -- payroll. The default behaviour was to always have Prenoting, so
  -- the code should allow for that. Non-US territories don't have
  -- Prenoting.
  --
  if l_territory_code = 'US' then
    if l_prenote_allowed is null or
       (l_prenote_allowed <> 'Y' and l_prenote_allowed <> 'N')
    then
      l_prenote_allowed := 'Y';
    end if;
    p_prenote_required := l_prenote_allowed;
  else
    p_prenote_required := 'N';
  end if;
  p_payroll_id := to_char(l_payroll_id);
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 90);

  return;
exception
  when others then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:FAIL', 100);
    if csr_getpayrollinfo%isopen then
      close csr_getpayrollinfo;
    end if;
    raise;
end getpayrollinfo;

---------------------------------< getconfig >-----------------------------
--  akadam     30-DEC-2006 115.26  5739568
--
--  Added some more configuration paremeters to support Foreign Payment Method
--

procedure getconfig
(p_item_type            in     varchar2
,p_item_key             in     varchar2
,p_activity_id          in     varchar2
,p_person_id            in     varchar2
,p_assignment_id        in     varchar2
,p_effective_date       in     varchar2
,p_run_type_id          in     varchar2          default null
,p_business_group_id    out nocopy varchar2
,p_territory_code       out nocopy varchar2
,p_id_flex_num          out nocopy varchar2
,p_flex_struct_code     out nocopy varchar2
,p_default_payment_type out nocopy varchar2
,p_prenote_required     out nocopy varchar2
,p_use_check            out nocopy varchar2
,p_view_only            out nocopy varchar2
,p_payment_types        out nocopy varchar2
,p_amount_types         out nocopy varchar2
,p_max_pay_methods      out nocopy varchar2
,p_cash_opmid           out nocopy varchar2
,p_check_opmid          out nocopy varchar2
,p_deposit_opmid        out nocopy varchar2
,p_obscure_prompt       out nocopy varchar2
,p_obscure_digits       out nocopy varchar2
,p_obscure_char         out nocopy varchar2
,p_return_status        out nocopy varchar2
,p_msg_count            out nocopy number
,p_msg_data             out nocopy varchar2
,p_branch_validation    out nocopy varchar2
,p_show_paymthd_lov     out nocopy varchar2
,p_faa_ch_opmid_list    out nocopy varchar2
,p_faa_ca_opmid_list    out nocopy varchar2
,p_faa_mt_opmid_list    out nocopy varchar2
,p_payroll_id           out nocopy varchar2
) is
--
-- Check if this assignment has future-dated PPMs.
--
cursor csr_future_ppms
(p_assignment_id  in number
,p_effective_date in date
) is
select null
from   pay_personal_payment_methods_f ppm
where  ppm.assignment_id = p_assignment_id
and    nvl(ppm.run_type_id, hr_api.g_number) = nvl(p_run_type_id, hr_api.g_number)
and    ppm.effective_start_date > p_effective_date
;
--
-- Check if this assignment has any PPMs with not null (monetary) amount
-- values.
--
cursor csr_monetary
(p_assignment_id  in number
,p_effective_date in date
) is
select null
from  pay_personal_payment_methods_f ppm
where ppm.assignment_id = p_assignment_id
and   nvl(ppm.run_type_id, hr_api.g_number) = nvl(p_run_type_id, hr_api.g_number)
and   p_effective_date between
      ppm.effective_start_date and ppm.effective_end_date
and   ppm.amount is not null
;
--
-- Check if this assignment has any PPMs with not null percentage values.
-- The cursor must ignore 3rd party payments and the remaining pay PPM
-- (highest priority number).
--
cursor csr_percentage
(p_assignment_id  in number
,p_effective_date in date
) is
select null
from  pay_personal_payment_methods_f ppm
,     pay_org_payment_methods_f      opm
where ppm.assignment_id = p_assignment_id
and   nvl(ppm.run_type_id, hr_api.g_number) = nvl(p_run_type_id, hr_api.g_number)
and   p_effective_date between
      ppm.effective_start_date and ppm.effective_end_date
and   opm.org_payment_method_id = ppm.org_payment_method_id
and   p_effective_date between
      opm.effective_start_date and opm.effective_end_date
and   opm.defined_balance_id is not null
and   ( (p_run_type_id is not null) or (ppm.priority <
      (select max(priority)
       from   pay_personal_payment_methods_f ppm1
       where  ppm1.assignment_id = p_assignment_id
       and    nvl(ppm1.run_type_id, hr_api.g_number) = nvl(p_run_type_id, hr_api.g_number)
       and    p_effective_date between
              ppm1.effective_start_date and ppm1.effective_end_date)))
and   ppm.percentage is not null
;
--
cursor csr_amount_lookup ( p_lookup_code in varchar2
                          ,p_effective_date in date
			 ) is
select null
from   hr_lookups
where  lookup_type = 'PAY_METHOD_AMOUNT_TYPE'
and    lookup_code = p_lookup_code
and    enabled_flag = 'Y'
and    p_effective_date between nvl(start_date_active, p_effective_date)
       and nvl(end_date_active, p_effective_date) ;
--
l_start             number;
l_part              varchar2(32767);
l_wf_attr           varchar2(128);
l_wf_attr1          varchar2(128);
l_option_value      varchar2(32767);
l_option_value1     varchar2(32767);
l_option            varchar2(64);
l_number_value      number;
l_view_only         boolean := false;
--
-- Database information.
--
l_person_id         number;
l_assignment_id     number;
l_effective_date    date;
l_business_group_id number;
l_territory_code    varchar2(64);
--
-- Variables used to get the OPMID values.
--
l_payment_types     varchar2(2000);
l_cash              boolean := false;
l_check             boolean := false;
l_deposit           boolean := false;
l_cash_list         varchar2(32767);
l_check_list        varchar2(32767);
l_deposit_list      varchar2(32767);
l_cash_opmid        number;
l_check_opmid       number;
l_deposit_opmid     number;
l_show_paymthd_lov     varchar2(200);
l_payroll_id        varchar2(200);


--
-- Flags for amount type checking.
--
l_percentage_only   boolean;
l_monetary_only     boolean;

l_percentage_enabled boolean;
l_monetary_enabled   boolean;
l_null               varchar2(10);
--
l_function           varchar2(1000);
--
l_proc              varchar2(2000) := g_package||'getconfig';
--
-- How far the code has progressed.
--
l_stage             varchar2(2000);
--
l_msg_count         number;
--
-- Convenience procedure for raising error in the initial code.
--
procedure initialerror(p_stage in varchar2, p_additional_info in varchar2) is
begin
  fnd_message.set_name('PAY', 'PAY_50405_PSS_CFG_PROC_ERROR');
  fnd_message.set_token('STAGE', p_stage);
  fnd_message.set_token('ADDITIONAL_INFO', p_additional_info);
  fnd_msg_pub.add;
  fnd_message.raise_error;
end initialerror;
begin
  --
  -- Initialise the AOL message tables.
  --
    l_show_paymthd_lov     := null;


  fnd_msg_pub.initialize;
  -------------------------------------------------------------------
  -- Check if this routine has been called before and use workflow --
  -- item attributes to return the values.                         --
  -------------------------------------------------------------------
  g_item_type := p_item_type;
  g_item_key := p_item_key;
  if getwfattr(p_item_type, p_item_key, C_GOT_CONFIG1_WF_ATTR) is not null
  then
    p_business_group_id :=
    getwfattr(p_item_type, p_item_key, C_BUS_GROUP_ID_WF_ATTR, false);
    p_branch_validation :=
    getwfattr(p_item_type, p_item_key, C_BRANCH_CODE_CHK_WF_ATTR, false);
    p_territory_code :=
    getwfattr(p_item_type, p_item_key, C_LEG_CODE_WF_ATTR, false);
    p_id_flex_num :=
    getwfattr(p_item_type, p_item_key, C_ID_FLEX_NUM_WF_ATTR, false);
    p_flex_struct_code :=
    getwfattr(p_item_type, p_item_key, C_FLEX_STRUCT_CODE_WF_ATTR, false);
    p_default_payment_type :=
    getwfattr(p_item_type, p_item_key, C_DEF_PAYMENT_TYPE_WF_ATTR, false);
    p_prenote_required :=
    getwfattr(p_item_type, p_item_key, C_PRENOTE_REQUIRED_WF_ATTR, false);
    p_use_check:=
    getwfattr(p_item_type, p_item_key, C_USE_CHECK_WF_ATTR, false);
    p_view_only :=
    getwfattr(p_item_type, p_item_key, C_VIEW_ONLY_WF_ATTR, false);
    p_payment_types :=
    getwfattr(p_item_type, p_item_key, C_PAYMENT_TYPES_WF_ATTR, false);
    p_amount_types :=
    getwfattr(p_item_type, p_item_key, C_AMOUNT_TYPES_WF_ATTR, false);
    p_max_pay_methods :=
    getwfattr(p_item_type, p_item_key, C_MAX_PAY_METHODS_WF_ATTR, false);
    p_cash_opmid :=
    getwfattr(p_item_type, p_item_key, C_CA_OPM_ID_WF_ATTR);
    p_check_opmid :=
    getwfattr(p_item_type, p_item_key, C_CH_OPM_ID_WF_ATTR);
    p_deposit_opmid :=
    getwfattr(p_item_type, p_item_key, C_MT_OPM_ID_WF_ATTR);
    p_show_paymthd_lov :=
    getwfattr(p_item_type, p_item_key, C_FACCT_ALWD_WF_ATTR);  --- akadam
    p_faa_ch_opmid_list :=
    getwfattr(p_item_type, p_item_key, C_FAA_CH_OPMID_LST_WF_ATTR);
    p_faa_ca_opmid_list  :=
    getwfattr(p_item_type, p_item_key, C_FAA_CA_OPMID_LST_WF_ATTR);
    p_faa_mt_opmid_list  :=
    getwfattr(p_item_type, p_item_key, C_FAA_MT_OPMID_LST_WF_ATTR); -- akadam


    --
    -- Set successful return status.
    --
    p_return_status := fnd_api.G_RET_STS_SUCCESS;
    fnd_msg_pub.count_and_get
    (p_count => p_msg_count
    ,p_data  => p_msg_data
    );
    return;
  end if;
  --
  -- Flag that this part of the code is being entered.
  --
  add2wf(p_item_type, p_item_key, C_GOT_CONFIG1_WF_ATTR, 'Y');
  --
  -- Handle information on the payroll, legislation etc. Errors here indicate
  -- serious errors in the code (as opposed to user errors in configuration).
  --
  begin
    --
    -- 1. Check that EFFECTIVE_DATE is valid and save it to the workflow.
    --
    l_stage := 'EFFECTIVE_DATE:1';
    l_effective_date :=
    to_date(p_effective_date, hr_transaction_ss.g_date_format);
    --
    l_stage := 'EFFECTIVE_DATE:2';
    if not hr_workflow_utility.item_attribute_exists
           (p_item_type => p_item_type
           ,p_item_key  => p_item_key
           ,p_name      => pay_ppmv4_utils_ss.C_EFFECTIVE_DATE
           )
    then
      wf_engine.additemattr
      (itemtype   => p_item_type
      ,itemkey    => p_item_key
      ,aname      => pay_ppmv4_utils_ss.C_EFFECTIVE_DATE
      ,date_value => l_effective_date
      );
    end if;
    --
    -- Check that the assignment_id is valid and save it to the workflow.
    --
    l_stage := 'ASSIGNMENT_ID:1';
    l_assignment_id := to_number(p_assignment_id);
    select  person_id
    into    l_person_id
    from    per_all_assignments_f a
    where   a.assignment_id = l_assignment_id
    and     l_effective_date
            between a.effective_start_date and a.effective_end_date;
    --
    l_stage := 'ASSIGNMENT_ID:2';
    if not hr_workflow_utility.item_attribute_exists
           (p_item_type => p_item_type
           ,p_item_key  => p_item_key
           ,p_name      => pay_ppmv4_utils_ss.C_ASSIGNMENT_ID
           )
    then
      wf_engine.additemattr
      (itemtype     => p_item_type
      ,itemkey      => p_item_key
      ,aname        => pay_ppmv4_utils_ss.C_ASSIGNMENT_ID
      ,number_value => p_assignment_id
      );
    end if;
    --
    -- Fetch the payroll information.
    --
    l_stage := 'PAYROLL_INFO';

    getpayrollinfo
    (p_assignment_id        => l_assignment_id
    ,p_effective_date       => l_effective_date
    ,p_default_payment_type => l_option_value
    ,p_prenote_required     => l_option_value1
    ,p_payroll_id => l_payroll_id
    );
    p_default_payment_type := l_option_value;
    p_prenote_required := l_option_value1;
    p_payroll_id := l_payroll_id;
    add2wf(p_item_type, p_item_key, C_DEF_PAYMENT_TYPE_WF_ATTR, l_option_value);
    add2wf(p_item_type, p_item_key, C_PRENOTE_REQUIRED_WF_ATTR, l_option_value1);
    add2wf(p_item_type, p_item_key, C_PAYROLL_ID, l_payroll_id);
    --
    -- TERRITORY_CODE
    --
    l_stage := 'TERRITORY_CODE';
    select pbg.legislation_code
    ,      pbg.business_group_id
    into   l_territory_code
    ,      l_business_group_id
    from   per_business_groups pbg
    ,      per_all_assignments_f asg
    where  asg.assignment_id = l_assignment_id
    and    l_effective_date between
           asg.effective_start_date and asg.effective_end_date
    and    pbg.business_group_id + 0 = asg.business_group_id;
    p_territory_code := l_territory_code;
    p_business_group_id := to_char(l_business_group_id);
    add2wf(p_item_type, p_item_key, C_LEG_CODE_WF_ATTR, l_territory_code);
    add2wf(p_item_type, p_item_key, C_BUS_GROUP_ID_WF_ATTR, to_char(l_business_group_id));
    --
    -- ID_FLEX_NUM/FLEX_STRUCT_CODE
    --
    l_stage := 'ID_FLEX_NUM';
    select leg.rule_mode
    ,      flex.id_flex_structure_code
    into   l_option_value
    ,      l_option_value1
    from   pay_legislation_rules  leg
    ,      fnd_id_flex_structures flex
    where  leg.legislation_code = l_territory_code
    and    leg.rule_type = 'E'
    and    to_char(flex.id_flex_num) = leg.rule_mode
    and    flex.id_flex_code = 'BANK';
    p_id_flex_num := l_option_value;
    p_flex_struct_code := l_option_value1;
    add2wf(p_item_type, p_item_key, C_ID_FLEX_NUM_WF_ATTR, l_option_value);
    add2wf(p_item_type, p_item_key, C_FLEX_STRUCT_CODE_WF_ATTR, l_option_value1);
    --
    -- USE_CHECK.
    --
    l_stage := 'USE_CHECK';
    begin
      select 'Y'
      into   l_option_value
      from   pay_legislative_field_info leg
      where  leg.field_name = 'CHEQUE_CHECK'
      and    leg.legislation_code = l_territory_code;
    exception
      when no_data_found then
        l_option_value := 'N';
      when others then
        raise;
    end;
    p_use_check := l_option_value;
    add2wf(p_item_type, p_item_key, C_USE_CHECK_WF_ATTR, l_option_value);
  exception
    when others then
      initialerror(l_stage, sqlerrm);
  end;


  ---------------------------------------------------
  -- Now look at the configuration for the module. --
  ---------------------------------------------------
  --
  -- VIEW_ONLY
  --
  l_option := C_VIEW_ONLY;
  l_option_value := pay_ppmv4_utils_ss.read_wf_config_option
  (p_item_type   => p_item_type
  ,p_item_key    => p_item_key
  ,p_activity_id => p_activity_id
  ,p_option      => l_option
  );
  l_option_value := nvl(l_option_value, 'N');
  p_view_only := l_option_value;
  l_view_only := (l_option_value = 'Y');
  add2wf(p_item_type, p_item_key, C_VIEW_ONLY_WF_ATTR, l_option_value);
  --
  -- PERMITTED_PAYMENT_TYPES
  --
  if l_view_only then
    --
    -- Display everything.
    --
    p_payment_types := C_ALL;
    add2wf(p_item_type, p_item_key, C_PAYMENT_TYPES_WF_ATTR, C_ALL);
    p_show_paymthd_lov := C_NO;
    add2wf(p_item_type, p_item_key, C_FACCT_ALWD_WF_ATTR, C_NO);
  else
    l_option := C_PERMITTED_PAYMENT_TYPES;
    l_option_value := pay_ppmv4_utils_ss.read_wf_config_option
    (p_item_type   => p_item_type
    ,p_item_key    => p_item_key
    ,p_activity_id => p_activity_id
    ,p_option      => l_option
    );
    l_option_value := nvl(l_option_value, C_ALL);
    l_payment_types := l_option_value;
    p_payment_types := l_option_value;
    l_cash :=
    l_option_value = C_CASH_ONLY or l_option_value = C_CASH_AND_CHECK or
    l_option_value = C_CASH_AND_DEPOSIT or l_option_value = C_ALL;
    l_check :=
    l_option_value = C_CHECK_ONLY or l_option_value = C_CASH_AND_CHECK or
    l_option_value = C_CHECK_AND_DEPOSIT or l_option_value = C_ALL;
    l_deposit :=
    l_option_value = C_DEPOSIT_ONLY or l_option_value = C_CASH_AND_DEPOSIT or
    l_option_value = C_CHECK_AND_DEPOSIT or l_option_value = C_ALL;
    --
    -- Avoid problems such as that reported in bug2869603 where the
    -- lookup type was incorrectly extended.
    --
    if l_option_value <> C_CASH_ONLY and
       l_option_value <> C_CHECK_ONLY and
       l_option_value <> C_DEPOSIT_ONLY and
       l_option_value <> C_CASH_AND_CHECK and
       l_option_value <> C_CASH_AND_DEPOSIT and
       l_option_value <> C_CHECK_AND_DEPOSIT and
       l_option_value <> C_ALL
    then
      goto option_error;
    end if;
    add2wf(p_item_type, p_item_key, C_PAYMENT_TYPES_WF_ATTR, l_option_value);
  end if;
  --
  -- PERMITTED_AMOUNT_TYPE
  -- Need to read the configuration option in all cases as some organisations
  -- probably wouldn't want to display Amount Type.
  --
  l_option := C_PERMITTED_AMOUNT_TYPES;
  l_option_value := pay_ppmv4_utils_ss.read_wf_config_option
  (p_item_type   => p_item_type
  ,p_item_key    => p_item_key
  ,p_activity_id => p_activity_id
  ,p_option      => l_option
  );

  l_option_value := nvl(l_option_value, C_EITHER_AMOUNT);
  p_amount_types := l_option_value;
  l_monetary_only := (l_option_value = C_MONETARY_ONLY);
  l_percentage_only := (l_option_value = C_PERCENTAGE_ONLY);

  if l_option_value = C_EITHER_AMOUNT then

        -- Bug 3697405. Don't display if the lookup codes are not enabled.
        -- This Check is done only when the workflow setting is EITHER_AMOUNT,
        -- to avoid the scenario where one Amount type is disabled at Workflow
        -- level and the other has been disabled at Lookup level which will
        -- result in no amount type being available for the transaction.
        -- Though this scenario is very unlikely, handling this avoids
        -- unnecessary confusion.

	open csr_amount_lookup( p_lookup_code => 'MONETARY'
	                       ,p_effective_date => l_effective_date );
        fetch csr_amount_lookup into l_null;
	if csr_amount_lookup%found then
	    l_monetary_enabled := true;
        else
	    l_monetary_enabled := false;
	end if;
	close csr_amount_lookup;

	open csr_amount_lookup( p_lookup_code => 'PERCENTAGE'
	                       ,p_effective_date => l_effective_date );
        fetch csr_amount_lookup into l_null;
	if csr_amount_lookup%found then
	    l_percentage_enabled := true;
        else
	    l_percentage_enabled := false;
	end if;
	close csr_amount_lookup;

	if l_percentage_enabled and not l_monetary_enabled then

		l_option_value := C_PERCENTAGE_ONLY ;
		p_amount_types := l_option_value ;
		l_percentage_only := true;
		l_monetary_only := false;

	elsif l_monetary_enabled and not l_percentage_enabled then

		l_option_value := C_MONETARY_ONLY ;
		p_amount_types := l_option_value ;
		l_monetary_only := true;
		l_percentage_only := false;

	end if;

  end if;

  add2wf(p_item_type, p_item_key, C_AMOUNT_TYPES_WF_ATTR, l_option_value);
  --
  -- MAXIMUM_PAYMENT_METHODS
  --
  if l_view_only then
    --
    -- Prevent attempted use of this option.
    --
    p_max_pay_methods := 0;
    add2wf(p_item_type, p_item_key, C_MAX_PAY_METHODS_WF_ATTR, '0');
  else
    l_option := C_MAXIMUM_PAYMENT_METHODS;
    l_option_value := pay_ppmv4_utils_ss.read_wf_config_option
    (p_item_type   => p_item_type
    ,p_item_key    => p_item_key
    ,p_activity_id => p_activity_id
    ,p_option      => l_option
    ,p_number      => true
    );
    begin
      l_number_value := trunc(to_number(l_option_value));
    exception
      when others then
        goto option_error;
    end;
    --
    if l_number_value is null then
      l_number_value := C_DEFAULT_PAYMENT_METHODS;
    elsif l_number_value < C_MIN_PAYMENT_METHODS then
      l_number_value := C_MIN_PAYMENT_METHODS;
    elsif l_number_value > C_MAX_PAYMENT_METHODS then
      l_number_value := C_MAX_PAYMENT_METHODS;
    end if;
    p_max_pay_methods := to_char(l_number_value);
    add2wf(p_item_type, p_item_key, C_MAX_PAY_METHODS_WF_ATTR, to_char(l_number_value));
  end if;


  --
  -- CASH_OPMID
  -- CHECK_OPMID
  -- DEPOSIT_OPMID
  --
  if not l_view_only then

    l_option := C_CASH_LIST;
    l_cash_list := pay_ppmv4_utils_ss.read_wf_config_option
    (p_item_type   => p_item_type
    ,p_item_key    => p_item_key
    ,p_activity_id => p_activity_id
    ,p_option      => l_option
    );
    --
    l_option := C_CHECK_LIST;
    l_check_list := pay_ppmv4_utils_ss.read_wf_config_option
    (p_item_type   => p_item_type
    ,p_item_key    => p_item_key
    ,p_activity_id => p_activity_id
    ,p_option      => l_option
    );
    --
    l_option := C_DEPOSIT_LIST;
    l_deposit_list := pay_ppmv4_utils_ss.read_wf_config_option
    (p_item_type   => p_item_type
    ,p_item_key    => p_item_key
    ,p_activity_id => p_activity_id
    ,p_option      => l_option
    );
    --

    l_function := substr(fnd_profile.value(name => 'PAY_PSS_PAYMENT_FUNCTION'),1,1000);

    if l_function is not null and l_function = C_ALL then
      l_show_paymthd_lov := C_YES;
    else
      l_show_paymthd_lov := C_NO;
    end if;

    add2wf(p_item_type, p_item_key, C_FACCT_ALWD_WF_ATTR, l_show_paymthd_lov);

    p_show_paymthd_lov := l_show_paymthd_lov;


    if l_function is not null then

      getcustomopms
      (p_assignment_id  => l_assignment_id
      ,p_effective_date => l_effective_date
      ,p_cash           => l_cash
      ,p_check          => l_check
      ,p_deposit        => l_deposit
      ,p_function       => l_function
      ,p_show_paymthd_lov  => l_show_paymthd_lov
      ,p_cash_opmid     => l_cash_opmid
      ,p_check_opmid    => l_check_opmid
      ,p_deposit_opmid  => l_deposit_opmid
      ,p_faa_ch_opmid_list => p_faa_ch_opmid_list
      ,p_faa_ca_opmid_list => p_faa_ca_opmid_list
      ,p_faa_mt_opmid_list => p_faa_mt_opmid_list
      );
    else

      getopms
      (p_assignment_id  => l_assignment_id
      ,p_effective_date => l_effective_date
      ,p_cash           => l_cash
      ,p_check          => l_check
      ,p_deposit        => l_deposit
      ,p_deposit_list   => l_deposit_list
      ,p_cash_list      => l_cash_list
      ,p_check_list     => l_check_list
      ,p_cash_opmid     => l_cash_opmid
      ,p_check_opmid    => l_check_opmid
      ,p_deposit_opmid  => l_deposit_opmid
      );
    end if;
    --
    -- If OPMID of a particular type cannot be found then reduce the returned
    -- Payment Types value accordingly to allow the module to continue.
    --
    if l_deposit and l_deposit_opmid is null then
      l_deposit := false;
      if l_payment_types = C_ALL then
        l_payment_types := C_CASH_AND_CHECK;
      elsif l_payment_types = C_CASH_AND_DEPOSIT then
        l_payment_types := C_CASH_ONLY;
      elsif l_payment_types = C_CHECK_AND_DEPOSIT then
        l_payment_types := C_CHECK_ONLY;
      else
        l_payment_types := null;
      end if;
    end if;
    --
    if l_cash and l_cash_opmid is null then
      l_cash := false;
      if l_payment_types = C_ALL then
        l_payment_types := C_CHECK_AND_DEPOSIT;
      elsif l_payment_types = C_CASH_AND_DEPOSIT then
        l_payment_types := C_DEPOSIT_ONLY;
      elsif l_payment_types = C_CASH_AND_CHECK then
        l_payment_types := C_CHECK_ONLY;
      else
        l_payment_types := null;
      end if;
    end if;
    --
    if l_check and l_check_opmid is null then
      l_check := false;
      if l_payment_types = C_ALL then
        l_payment_types := C_CASH_AND_DEPOSIT;
      elsif l_payment_types = C_CHECK_AND_DEPOSIT then
        l_payment_types := C_DEPOSIT_ONLY;
      elsif l_payment_types = C_CASH_AND_CHECK then
        l_payment_types := C_CASH_ONLY;
      else
        l_payment_types := null;
      end if;
    end if;
    --
    if l_payment_types is null then
      fnd_message.set_name('PER', 'PAY_52626_NO_PAYMENT_TYPES');
      fnd_msg_pub.add;
      fnd_message.raise_error;
    end if;
    p_payment_types := l_payment_types;
    p_deposit_opmid := to_char(l_deposit_opmid);
    p_cash_opmid := to_char(l_cash_opmid);
    p_check_opmid := to_char(l_check_opmid);


    add2wf(p_item_type, p_item_key, C_CA_OPM_ID_WF_ATTR, to_char(l_cash_opmid));
    add2wf(p_item_type, p_item_key, C_CH_OPM_ID_WF_ATTR, to_char(l_check_opmid));
    add2wf(p_item_type, p_item_key, C_MT_OPM_ID_WF_ATTR, to_char(l_deposit_opmid));

    add2wf(p_item_type, p_item_key, C_FAA_CH_OPMID_LST_WF_ATTR, p_faa_ch_opmid_list);
    add2wf(p_item_type, p_item_key, C_FAA_CA_OPMID_LST_WF_ATTR, p_faa_ca_opmid_list);
    add2wf(p_item_type, p_item_key, C_FAA_MT_OPMID_LST_WF_ATTR, p_faa_mt_opmid_list);

    wf_engine.setitemattrtext
    (p_item_type, p_item_key, C_PAYMENT_TYPES_WF_ATTR, l_payment_types);
  end if;
  --
  -- 9. OBSCURE_ACCOUNT_NUMBER
  --
  l_option := null;
  l_option_value := null;
  p_obscure_prompt := null;
  p_obscure_digits := null;
  p_obscure_char := null;
  if not l_view_only and l_option_value is not null then
    l_start := 1;
    --
    -- Flexfield prompt.
    --
    l_part :=  pay_ppmv4_utils_ss.nextentry
    (p_list      => l_option_value
    ,p_separator => C_LIST_SEPARATOR
    ,p_start     => l_start
    );
    if l_part is null or l_start = 0 then
      goto option_error;
    end if;
    p_obscure_prompt := l_part;
    --
    -- Character used to obscure account information.
    --
    l_part :=  pay_ppmv4_utils_ss.nextentry
    (p_list      => l_option_value
    ,p_separator => C_LIST_SEPARATOR
    ,p_start     => l_start
    );
    if l_part is null or length(l_part) <> 1 or l_start = 0 then
      goto option_error;
    end if;
    p_obscure_char := l_part;
    --
    -- Number of characters to obscure.
    --
    l_part :=  pay_ppmv4_utils_ss.nextentry
    (p_list      => l_option_value
    ,p_separator => C_LIST_SEPARATOR
    ,p_start     => l_start
    );
    if l_part is null then
      goto option_error;
    end if;
    --
    -- Check that it's a valid number.
    --
    begin
      l_number_value := trunc(to_number(l_part));
    exception
      when others then
        goto option_error;
    end;
    p_obscure_digits := to_char(l_number_value);
  end if;
  --
  -- 10. Branch validation.
  --
  l_option := C_BRANCH_VALIDATION;
  l_option_value :=
  nvl(upper(fnd_profile.value(name => 'PAY_ENABLE_BANK_BRANCHES')), 'N');
  if l_option_value = 'Y' then
    --
    -- Branch validation is restricted to the following territories:
    -- GB
    --
    if l_territory_code <> 'GB' then
      l_option_value := 'N';
    end if;
  elsif l_option_value <> 'N' then
    goto option_error;
  end if;
  p_branch_validation := l_option_value;
  add2wf(p_item_type, p_item_key, C_BRANCH_CODE_CHK_WF_ATTR, l_option_value);
  --
  -- Check that there are no future-dated PPMs on the assignment.
  --
  open csr_future_ppms
  (p_assignment_id  => l_assignment_id
  ,p_effective_date => l_effective_date
  );
  fetch csr_future_ppms into l_option_value;
  if csr_future_ppms%found then
    close csr_future_ppms;
    fnd_message.set_name('PER', 'PAY_52622_FUTURE_PAYMENTS');
    fnd_msg_pub.add;
    fnd_message.raise_error;
  end if;
  close csr_future_ppms;
  --
  -- Check for consistency between the permitted amount types and the
  -- user's PPMs.
  --
  if l_percentage_only then
    open csr_monetary
    (p_assignment_id  => l_assignment_id
    ,p_effective_date => l_effective_date
    );
    fetch csr_monetary into l_option_value;
    if csr_monetary%found then
      close csr_monetary;
      fnd_message.set_name('PER', 'PAY_52625_PPM_USES_AMOUNT');
      fnd_msg_pub.add;
      fnd_message.raise_error;
    end if;
    close csr_monetary;
  elsif l_monetary_only then
    open csr_percentage
    (p_assignment_id  => l_assignment_id
    ,p_effective_date => l_effective_date
    );
    fetch csr_percentage into l_option_value;
    if csr_percentage%found then
      close csr_percentage;
      fnd_message.set_name('PER', 'PAY_52624_PPM_USES_PERCENTAGE');
      fnd_msg_pub.add;
      fnd_message.raise_error;
    end if;
    close csr_percentage;
  end if;
  --
  -- Set up success status.
  --
  p_return_status := fnd_api.G_RET_STS_SUCCESS;
  fnd_msg_pub.count_and_get
  (p_count => p_msg_count
  ,p_data  => p_msg_data
  );
  return;
<<option_error>>
  fnd_message.set_name('PER', 'PAY_52631_PPMSS_OPTION_ERROR');
  fnd_message.set_token('OPTION', l_option);
  fnd_msg_pub.add;
  fnd_message.raise_error;
exception
  --
  -- Set up the error status.
  --
  when others then
    --
    -- Errors should have already been added.
    --
    p_return_status := fnd_api.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get
    (p_count => l_msg_count
    ,p_data  => p_msg_data
    );
    if l_msg_count = 0 then
      fnd_message.set_name('PAY', 'PAY_50405_PSS_CFG_PROC_ERROR');
      fnd_message.set_token('STAGE', 'UNEXPECTED_ERROR');
      fnd_message.set_token('ADDITIONAL_INFO', sqlerrm);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get
      (p_count => l_msg_count
      ,p_data  => p_msg_data
      );
    end if;


    p_msg_count := l_msg_count;
end getconfig;
--------------------------------< gettxstepids >---------------------------
function gettxstepids
(p_transaction_id in varchar2
,p_review_page    in boolean  default false
,p_summary_page   in boolean  default false
,p_freed          in boolean  default false
) return varchar2 is
cursor csr_txstepids
(p_transaction_id in number
) is
select transaction_step_id
,      state
,      logical_priority
from   pay_pss_transaction_steps
where  transaction_id = p_transaction_id;
--
l_state          varchar2(2000);
l_priority       number;
l_txstepid_tbl   t_number_tbl;
l_add_to_list    boolean;
l_list           varchar2(32767);
i                number;
l_proc           varchar2(2000) := g_package || 'gettxstepids';
begin
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ENTER', 0);
  --
  -- Look for the transaction_id.
  --
  if p_transaction_id is null then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 0);
    return null;
  end if;
  --
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'CURSOR_FOR_LOOP', 10);
  for rec in csr_txstepids(p_transaction_id => p_transaction_id) loop
    l_state := rec.state;
    l_priority := rec.logical_priority;
    --
    -- Which PPMs get displayed depends upon whether or not this is
    -- for the Review page.
    --

    l_add_to_list :=
    (p_summary_page and include_in_page(C_SUMMARY_PAGE, l_state) = 'Y') or
    (p_review_page and include_in_page(C_REVIEW_PAGE, l_state) = 'Y') or
    (p_freed and l_state = C_STATE_FREED);
    if l_add_to_list then

      --
      -- For the Summary Page, and Review Page (non-deleted PPMs), the
      -- transaction_step_ids are put in priority order.
      --
      if p_summary_page or
         p_review_page and l_state <> C_STATE_DELETED then
        l_txstepid_tbl(l_priority) := rec.transaction_step_id;
      --
      -- Otherwise, order does not matter but need to avoid clashes with
      -- priority for the Review Page PPMs.
      --
      else
        i := pay_ppmv4_utils_ss.C_MAX_PRIORITY + 1 + rec.transaction_step_id;
        l_txstepid_tbl(i) := rec.transaction_step_id;
      end if;
    end if;
  end loop;
  --
  -- Build list from table.
  --
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ADD_TO_LIST', 35);
  i := l_txstepid_tbl.first;
  loop
    exit when not l_txstepid_tbl.exists(i);
    --
    if l_list is not null then
      l_list := l_list || C_COMMA;
    end if;
    l_list := l_list || to_char(l_txstepid_tbl(i));
    --
    i := l_txstepid_tbl.next(i);
  end loop;
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 40);
  return l_list;
exception
  when others then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:FAIL', 50);
    raise;
end gettxstepids;
-----------------------------< alloc_real_priorities >---------------------
procedure alloc_real_priorities
(p_transaction_id  in     varchar2
,p_assignment_id   in     varchar2
,p_effective_date  in     varchar2
,p_success            out nocopy boolean
) is
l_effective_date date;
--
-- transaction_step_id variables.
--
l_txstepids varchar2(32767);
l_next      varchar2(32767);
l_start     number := 1;
l_txstepid  number;
--
-- Priority variables.
--
l_priority   number;
l_o_priority number;
l_priorities pay_ppmv4_utils_ss.t_boolean_tbl;
i            number;
l_proc       varchar2(2000) := g_package||'alloc_real_priorities';

l_run_type_id pay_pss_transaction_steps.run_type_id%type;

--
-- cursor to fetch the run_type_id
--

cursor csr_run_type_id(p_transaction_id in number) is
select distinct ppts.run_type_id
from   pay_pss_transaction_steps ppts
where  ppts.transaction_id = p_transaction_id;

begin
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ENTER', 0);
  p_success := true;
  --
  -- Fetch transaction_step_ids.
  --
  l_txstepids := gettxstepids
  (p_transaction_id => p_transaction_id
  ,p_summary_page   => true
  );
  if l_txstepids is null then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 5);
    return;
  end if;

  -- Fetch the run type id for the transaction.
  -- All the transaction steps for the given transaction will have the same value for run_type_id.

  open csr_run_type_id (p_transaction_id => p_transaction_id);
  fetch csr_run_type_id into l_run_type_id;

  if csr_run_type_id%notfound then
	l_run_type_id := null;
  end if;

  close csr_run_type_id;

  --
  -- Fetch priorities.
  --
  l_effective_date :=
  to_date(p_effective_date, hr_transaction_ss.g_date_format);
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'GETPRIORITIES', 10);
  pay_ppmv4_utils_ss.getpriorities
  (p_assignment_id   => p_assignment_id
  ,p_effective_date  => l_effective_date
  ,p_run_type_id     => l_run_type_id
  ,p_priority_tbl    => l_priorities
  ,p_first_available => i
  );
  --
  -- Start from the beginning of the priority list to avoid unnecessary
  -- reallocation of priorities.
  --
  i := l_priorities.first;
  while l_start <> 0 loop
    l_next := pay_ppmv4_utils_ss.nextentry
    (p_list      => l_txstepids
    ,p_separator => C_COMMA
    ,p_start     => l_start
    );
    l_txstepid := to_number(l_next);

    --
    -- Fetch original real priority.
    --
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'O_REAL_PRIORITY', 20);
    select p.o_real_priority
    into   l_o_priority
    from   pay_pss_transaction_steps p
    where  p.transaction_step_id = l_txstepid
    ;

    --
    -- Handle NULL value in the case of a brand new row.
    --
    if l_o_priority is null then
      l_o_priority := pay_ppmv4_utils_ss.C_NO_PRIORITY;
    end if;
    --
    -- Loop through the priority list until there is an available
    -- priority or the original real priority value is found.
    --
    l_priority := pay_ppmv4_utils_ss.C_NO_PRIORITY;


    for j in i .. pay_ppmv4_utils_ss.C_MAX_PRIORITY loop
      if l_priorities(j) or (not l_priorities(j) and j = l_o_priority) then
        l_priority := j;
        --
        -- Make sure that the next iteration starts one up in the list.
        --
        i := j + 1;
        exit;
      end if;
    end loop;
    --
    -- The following IF-statement is an ASSERTION that a priority
    -- value must be allocated.
    --
    if l_priority = pay_ppmv4_utils_ss.C_NO_PRIORITY then
      pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ALLOC_FAIL', 30);
      p_success := false;
      return;
    end if;
    --
    -- Write back the real priority value.
    --
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'WRITE_PRIORITY', 40);
    update pay_pss_transaction_steps p
    set    p.real_priority = l_priority
    where  p.transaction_step_id = l_txstepid;
    --

  end loop;
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 50);
  return;
exception
  when others then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:FAIL', 60);
    raise;
end alloc_real_priorities;
----------------------------< update_logical_priority >--------------------
procedure update_logical_priority
(p_transaction_step_id in varchar2
,p_logical_priority    in varchar2
,p_amount_type         in varchar2
) is
l_logical_priority   varchar2(2000);
l_o_logical_priority varchar2(2000);
l_state              varchar2(2000);
l_amount_type        varchar2(2000);
l_amount             number;
l_ppm                pay_ppmv4_utils_ss.t_ppmv4;
l_changes            boolean;
l_bank               boolean;
l_proc               varchar2(2000) := g_package||'update_logical_priority';

l_org_amt number;
l_org_percent number;

/*Below cursor created for fixing the bug#7230549. The changes
done are not in compliance with the functionality. So we are
commenting the changes. So we are not using below cursor any more.
If the customer still want this functionality then we need to create
a profile and switch this functionality based on the profile.*/

/*
-- Curosor to get the actual percentage/amount of the ppm.
cursor fetch_org_values is
select ppm.AMOUNT, ppm.PERCENTAGE
from pay_personal_payment_methods_f ppm,
pay_pss_transaction_steps pps
where pps.transaction_step_id = p_transaction_step_id
and pps.PERSONAL_PAYMENT_METHOD_ID = ppm.PERSONAL_PAYMENT_METHOD_ID
and pps.ASSIGNMENT_ID= ppm.ASSIGNMENT_ID
and pps.ORG_PAYMENT_METHOD_ID = ppm.ORG_PAYMENT_METHOD_ID
and pps.effective_date between ppm.effective_start_date and ppm.effective_end_date;
*/

begin
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ENTER', 0);
  --
  -- Fetch the current logical priority.
  --
  select to_char(p.logical_priority)
  ,      to_char(p.o_logical_priority)
  ,      p.state
  ,      p.amount_type
  ,      p.amount
  into   l_logical_priority
  ,      l_o_logical_priority
  ,      l_state
  ,      l_amount_type
  ,      l_amount
  from   pay_pss_transaction_steps p
  where  p.transaction_step_id = p_transaction_step_id;
  --
  -- Only need to do something if the new logical priority differs
  -- from the current logical priority.
  --
  if l_logical_priority <> p_logical_priority then
    --
--  chk_foreign_account(p_transaction_step_id   => p_transaction_step_id); removed for Foreign Account Enh akadam
    --
    -- Check if this pay method is the Remaining Pay pay method. If the
    -- logical priority moves the pay method up the priority order, the
    -- amount type and amount need for the Remaining Pay pay method.
    --
    if l_amount_type = C_REMAINING_PAY and
       p_logical_priority < l_logical_priority  then
      pay_ppmv4_utils_ss.seterrorstage(l_proc, 'REMAINING_PAY', 5);

      /*Below are the changes done based on the bug#7230549. This is not
	    expected functionality. So we are revering back the changes.
	    If the customer still want this functionality then we need to
		create a profile and switch this functionality based on the profile.*/
	  /*fetch the oriiginal values from the pay_personal_payment_methods_f table
       open fetch_org_values;
       fetch fetch_org_values into l_org_amt, l_org_percent;

       pay_ppmv4_utils_ss.seterrorstage(l_proc, 'l_org_amt-percent : ' || l_org_amt || '-' || l_org_percent , 2);

	     -- if no value is returned...use the earlier algorithm to set the value to 0
      if(fetch_org_values%notfound) then
      	 l_amount := 0;
      	 if p_amount_type = C_EITHER_AMOUNT then
	         l_amount_type := C_PERCENTAGE;
	       else
             l_amount_type := p_amount_type;
         end if;
      else
	     -- if values are found.. assign it to l_amount and accordingly also change the l_amount_type
        if(l_org_amt is not null) then
      	    l_amount := l_org_amt;
      	    l_amount_type := C_MONETARY;
	    else
    	    l_amount := l_org_percent;
	        l_amount_type := C_PERCENTAGE;
    	end if;

      end if;*/

      l_amount := 0;
      if p_amount_type = C_EITHER_AMOUNT then
        l_amount_type := C_PERCENTAGE;
      else
        l_amount_type := p_amount_type;
      end if;
    end if;
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'LOGICAL_PRIORITY CHANGE', 10);
    if nvl(l_o_logical_priority, to_char(hr_api.g_number)) =
       p_logical_priority then
      --
      -- If this is an existing PPM that has been updated then it is
      -- necessary to check whether or not this change will reset the PPM
      -- to its original state.
      --
      if l_state = C_STATE_UPDATED then
        pay_ppmv4_utils_ss.seterrorstage(l_proc, 'TT2PPM', 20);
        pay_ppmv4_utils_ss.tt2ppm
        (p_transaction_step_id => to_number(p_transaction_step_id)
        ,p_ppm                 => l_ppm
        );
        l_ppm.logical_priority := to_number(p_logical_priority);
        l_ppm.amount := l_amount;
        l_ppm.amount_type := l_amount_type;
        pay_ppmv4_utils_ss.changedppm
        (p_ppm     => l_ppm
        ,p_changes => l_changes
        ,p_bank    => l_bank
        );
        if not l_changes then
          --
          -- This priority change takes the PPM back to its original
          -- state so the state must be reset to C_STATE_EXISTING.
          --
          l_state := C_STATE_EXISTING;
        end if;
      end if;
    else
      --
      -- COMPLETELY NEW LOGICAL PRIORITY
      -- The state may need to be updated if this is effectively the
      -- first change on an existing PPM.
      --
      if l_o_logical_priority is not null then
        if l_state = C_STATE_EXISTING then
          l_state := C_STATE_UPDATED;
        end if;
      end if;
    end if;
    --
    -- Make and Commit the changes.
    --
    update pay_pss_transaction_steps p
    set    p.amount = l_amount
    ,      p.amount_type = l_amount_type
    ,      p.logical_priority = p_logical_priority
    ,      p.state = l_state
    where  p.transaction_step_id = p_transaction_step_id;
  end if;
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 70);
exception
  when others then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:FAIL', 80);
    raise;
end update_logical_priority;
----------------------------< increment_priorities >-----------------------
--
-- {Start Of Comments}
--
-- Description:
--   Increments the logical priority of each transaction table entry by
--   1. This is done because a newly added PPM is created with a priority
--   of 1.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure increment_priorities
(p_transaction_id  in number
) is
cursor csr_ppms(p_transaction_id in number) is
select ppts.transaction_step_id
,      ppts.logical_priority
,      ppts.amount_type
from   pay_pss_transaction_steps ppts
where  ppts.transaction_id = p_transaction_id
and    pay_ppmv4_ss.include_in_page(C_SUMMARY_PAGE, ppts.state) = 'Y';

--
l_proc             varchar2(2000) := g_package||'increment_priorities';
begin
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ENTER', 10);
  for rec in csr_ppms(p_transaction_id => p_transaction_id) loop
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'IN-LOOP', 20);
    update_logical_priority
    (p_transaction_step_id => rec.transaction_step_id
    ,p_amount_type         => rec.amount_type
    ,p_logical_priority    => rec.logical_priority + 1
    );
  end loop;
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 30);
  return;
exception
  when others then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:FAIL', 40);
    raise;
end increment_priorities;
----------------------------------< enter_ppm >----------------------------
procedure enter_ppm
(p_transaction_id        in     varchar2
,p_transaction_step_id   in out nocopy varchar2
,p_source_table          in     varchar2
default pay_pss_tx_steps_pkg.C_PAY_PERSONAL_PAYMENT_METHODS
,p_assignment_id         in     varchar2
,p_payment_type          in     varchar2
,p_currency_code         in     varchar2
,p_org_payment_method_id in     varchar2
,p_territory_code        in     varchar2
,p_effective_date        in     varchar2
,p_amount_type           in     varchar2
,p_amount                in     number
,p_external_account_id   in     number
,p_attribute_category    in     varchar2
,p_attribute1            in     varchar2
,p_attribute2            in     varchar2
,p_attribute3            in     varchar2
,p_attribute4            in     varchar2
,p_attribute5            in     varchar2
,p_attribute6            in     varchar2
,p_attribute7            in     varchar2
,p_attribute8            in     varchar2
,p_attribute9            in     varchar2
,p_attribute10           in     varchar2
,p_attribute11           in     varchar2
,p_attribute12           in     varchar2
,p_attribute13           in     varchar2
,p_attribute14           in     varchar2
,p_attribute15           in     varchar2
,p_attribute16           in     varchar2
,p_attribute17           in     varchar2
,p_attribute18           in     varchar2
,p_attribute19           in     varchar2
,p_attribute20           in     varchar2
,p_run_type_id           in     varchar2  default null
,p_ppm_information_category  in varchar2 default null
,p_ppm_information1      in     varchar2 default null
,p_ppm_information2      in     varchar2 default null
,p_ppm_information3      in     varchar2 default null
,p_ppm_information4      in     varchar2 default null
,p_ppm_information5      in     varchar2 default null
,p_ppm_information6      in     varchar2 default null
,p_ppm_information7      in     varchar2 default null
,p_ppm_information8      in     varchar2 default null
,p_ppm_information9      in     varchar2 default null
,p_ppm_information10     in     varchar2 default null
,p_ppm_information11     in     varchar2 default null
,p_ppm_information12     in     varchar2 default null
,p_ppm_information13     in     varchar2 default null
,p_ppm_information14     in     varchar2 default null
,p_ppm_information15     in     varchar2 default null
,p_ppm_information16     in     varchar2 default null
,p_ppm_information17     in     varchar2 default null
,p_ppm_information18     in     varchar2 default null
,p_ppm_information19     in     varchar2 default null
,p_ppm_information20     in     varchar2 default null
,p_ppm_information21     in     varchar2 default null
,p_ppm_information22     in     varchar2 default null
,p_ppm_information23     in     varchar2 default null
,p_ppm_information24     in     varchar2 default null
,p_ppm_information25     in     varchar2 default null
,p_ppm_information26     in     varchar2 default null
,p_ppm_information27     in     varchar2 default null
,p_ppm_information28     in     varchar2 default null
,p_ppm_information29     in     varchar2 default null
,p_ppm_information30     in     varchar2 default null
,p_return_status            out nocopy varchar2
,p_msg_count                out nocopy number
,p_msg_data                 out nocopy varchar2
) is
l_current         boolean;
l_original        boolean;
l_new_ppm         pay_ppmv4_utils_ss.t_ppmv4;
l_saved_ppm       pay_ppmv4_utils_ss.t_ppmv4;
l_freed_txstepids varchar2(32767);
l_freed_txstepid  varchar2(2000);
l_start           number := 1;
l_return_status   varchar2(2000);
l_msg_count       number;
l_msg_data        varchar2(16000);
l_proc            varchar2(2000) := g_package||'enter_ppm';
l_segment1        varchar2(2000);
l_segment2        varchar2(2000);
l_segment3        varchar2(2000);
l_segment4        varchar2(2000);
l_segment5        varchar2(2000);
l_segment6        varchar2(2000);
l_segment7        varchar2(2000);
l_segment8        varchar2(2000);
l_segment9        varchar2(2000);
l_segment10       varchar2(2000);
l_segment11       varchar2(2000);
l_segment12       varchar2(2000);
l_segment13       varchar2(2000);
l_segment14       varchar2(2000);
l_segment15       varchar2(2000);
l_segment16       varchar2(2000);
l_segment17       varchar2(2000);
l_segment18       varchar2(2000);
l_segment19       varchar2(2000);
l_segment20       varchar2(2000);
l_segment21       varchar2(2000);
l_segment22       varchar2(2000);
l_segment23       varchar2(2000);
l_segment24       varchar2(2000);
l_segment25       varchar2(2000);
l_segment26       varchar2(2000);
l_segment27       varchar2(2000);
l_segment28       varchar2(2000);
l_segment29       varchar2(2000);
l_segment30       varchar2(2000);
begin

  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ENTER', 0);
  --
  -- Initialise the AOL message tables.
  --
  fnd_msg_pub.initialize;
  --
  -- Write to a t_ppmv4 structure.
  --
hr_utility.trace('Creating record : context => '||p_ppm_information_category);
hr_utility.trace('information 1 => '||p_ppm_information1);
hr_utility.trace('information 2 => '||p_ppm_information2);
hr_utility.trace('information 3 => '||p_ppm_information3);
hr_utility.trace('information 4 => '||p_ppm_information4);
hr_utility.trace('p_transaction_id => '||p_transaction_id);
hr_utility.trace('p_transaction_id => '||p_transaction_id);
hr_utility.trace('p_assignment_id => '||p_assignment_id);
hr_utility.trace('p_org_payment_method_id => '||p_org_payment_method_id);
hr_utility.trace('p_payment_type => '||p_payment_type);

  l_new_ppm.transaction_id        := p_transaction_id;
  l_new_ppm.transaction_step_id   := p_transaction_step_id;
  l_new_ppm.assignment_id         := p_assignment_id;
  l_new_ppm.payment_type          := p_payment_type;
  l_new_ppm.currency_code         := p_currency_code;
  l_new_ppm.org_payment_method_id := p_org_payment_method_id;
  l_new_ppm.territory_code        := p_territory_code;
  l_new_ppm.effective_date        :=
  to_date(p_effective_date, hr_transaction_ss.g_date_format);
  l_new_ppm.amount_type           := p_amount_type;
  l_new_ppm.amount                := p_amount;
  l_new_ppm.external_account_id   := p_external_account_id;
  l_new_ppm.attribute_category    := p_attribute_category;
  l_new_ppm.attribute1            := p_attribute1;
  l_new_ppm.attribute2            := p_attribute2;
  l_new_ppm.attribute3            := p_attribute3;
  l_new_ppm.attribute4            := p_attribute4;
  l_new_ppm.attribute5            := p_attribute5;
  l_new_ppm.attribute6            := p_attribute6;
  l_new_ppm.attribute7            := p_attribute7;
  l_new_ppm.attribute8            := p_attribute8;
  l_new_ppm.attribute9            := p_attribute9;
  l_new_ppm.attribute10           := p_attribute10;
  l_new_ppm.attribute11           := p_attribute11;
  l_new_ppm.attribute12           := p_attribute12;
  l_new_ppm.attribute13           := p_attribute13;
  l_new_ppm.attribute14           := p_attribute14;
  l_new_ppm.attribute15           := p_attribute15;
  l_new_ppm.attribute16           := p_attribute16;
  l_new_ppm.attribute17           := p_attribute17;
  l_new_ppm.attribute18           := p_attribute18;
  l_new_ppm.attribute19           := p_attribute19;
  l_new_ppm.attribute20           := p_attribute20;
  l_new_ppm.source_table          := p_source_table;
  l_new_ppm.update_ovn            := 1;
  l_new_ppm.delete_disabled       := 'N';
  l_new_ppm.run_type_id           := p_run_type_id;
  l_new_ppm.ppm_information_category    := p_ppm_information_category;
  l_new_ppm.ppm_information1      := p_ppm_information1;
  l_new_ppm.ppm_information2      := p_ppm_information2;
  l_new_ppm.ppm_information3      := p_ppm_information3;
  l_new_ppm.ppm_information4      := p_ppm_information4;
  l_new_ppm.ppm_information5      := p_ppm_information5;
  l_new_ppm.ppm_information6      := p_ppm_information6;
  l_new_ppm.ppm_information7      := p_ppm_information7;
  l_new_ppm.ppm_information8      := p_ppm_information8;
  l_new_ppm.ppm_information9      := p_ppm_information9;
  l_new_ppm.ppm_information10     := p_ppm_information10;
  l_new_ppm.ppm_information11     := p_ppm_information11;
  l_new_ppm.ppm_information12     := p_ppm_information12;
  l_new_ppm.ppm_information13     := p_ppm_information13;
  l_new_ppm.ppm_information14     := p_ppm_information14;
  l_new_ppm.ppm_information15     := p_ppm_information15;
  l_new_ppm.ppm_information16     := p_ppm_information16;
  l_new_ppm.ppm_information17     := p_ppm_information17;
  l_new_ppm.ppm_information18     := p_ppm_information18;
  l_new_ppm.ppm_information19     := p_ppm_information19;
  l_new_ppm.ppm_information20     := p_ppm_information20;
  l_new_ppm.ppm_information21     := p_ppm_information21;
  l_new_ppm.ppm_information22     := p_ppm_information22;
  l_new_ppm.ppm_information23     := p_ppm_information23;
  l_new_ppm.ppm_information24     := p_ppm_information24;
  l_new_ppm.ppm_information25     := p_ppm_information25;
  l_new_ppm.ppm_information26     := p_ppm_information26;
  l_new_ppm.ppm_information27     := p_ppm_information27;
  l_new_ppm.ppm_information28     := p_ppm_information28;
  l_new_ppm.ppm_information29     := p_ppm_information29;
  l_new_ppm.ppm_information30     := p_ppm_information30;
  --------------------
  -- AN UPDATED PPM --
  --------------------
  if p_transaction_step_id is not null then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'TT2PPM', 10);
    pay_ppmv4_utils_ss.tt2ppm
    (p_transaction_step_id => p_transaction_step_id
    ,p_ppm                 => l_saved_ppm
    );
    --
    -- Compare the new and saved PPMs.
    --
    pay_ppmv4_utils_ss.changedppm
    (p_new_ppm   => l_new_ppm
    ,p_saved_ppm => l_saved_ppm
    ,p_original  => l_original
    ,p_current   => l_current
    );
    --
    -- Return if the result is no net change from the saved PPM.
    --
    if not l_current then
      pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 20);
      --
      -- Set up messages to Oracle Applications API standards as these
      -- are handled "for free" using checkErrors.
      --
      p_return_status := fnd_api.G_RET_STS_SUCCESS;
      fnd_msg_pub.count_and_get
      (p_count => p_msg_count
      ,p_data  => p_msg_data
      );
      return;
    end if;
    --
    -- Update L_SAVED_PPM with changes from L_NEW_PPM. This gives a
    -- completed PPM for subsequent saving.
    --
    l_saved_ppm.amount_type         := l_new_ppm.amount_type;
    l_saved_ppm.amount              := l_new_ppm.amount;
    l_saved_ppm.external_account_id := l_new_ppm.external_account_id;
    l_saved_ppm.attribute_category  := l_new_ppm.attribute_category;
    l_saved_ppm.attribute1          := l_new_ppm.attribute1;
    l_saved_ppm.attribute2          := l_new_ppm.attribute2;
    l_saved_ppm.attribute3          := l_new_ppm.attribute3;
    l_saved_ppm.attribute4          := l_new_ppm.attribute4;
    l_saved_ppm.attribute5          := l_new_ppm.attribute5;
    l_saved_ppm.attribute6          := l_new_ppm.attribute6;
    l_saved_ppm.attribute7          := l_new_ppm.attribute7;
    l_saved_ppm.attribute8          := l_new_ppm.attribute8;
    l_saved_ppm.attribute9          := l_new_ppm.attribute9;
    l_saved_ppm.attribute10         := l_new_ppm.attribute10;
    l_saved_ppm.attribute11         := l_new_ppm.attribute11;
    l_saved_ppm.attribute12         := l_new_ppm.attribute12;
    l_saved_ppm.attribute13         := l_new_ppm.attribute13;
    l_saved_ppm.attribute14         := l_new_ppm.attribute14;
    l_saved_ppm.attribute15         := l_new_ppm.attribute15;
    l_saved_ppm.attribute15         := l_new_ppm.attribute15;
    l_saved_ppm.attribute16         := l_new_ppm.attribute16;
    l_saved_ppm.attribute17         := l_new_ppm.attribute17;
    l_saved_ppm.attribute18         := l_new_ppm.attribute18;
    l_saved_ppm.attribute19         := l_new_ppm.attribute19;
    l_saved_ppm.attribute20         := l_new_ppm.attribute20;

	l_saved_ppm.ppm_information_category  := l_new_ppm.ppm_information_category;
    l_saved_ppm.ppm_information1    := l_new_ppm.ppm_information1;
    l_saved_ppm.ppm_information2    := l_new_ppm.ppm_information2;
    l_saved_ppm.ppm_information3    := l_new_ppm.ppm_information3;
    l_saved_ppm.ppm_information4    := l_new_ppm.ppm_information4;
    l_saved_ppm.ppm_information5    := l_new_ppm.ppm_information5;
    l_saved_ppm.ppm_information6    := l_new_ppm.ppm_information6;
    l_saved_ppm.ppm_information7    := l_new_ppm.ppm_information7;
    l_saved_ppm.ppm_information8    := l_new_ppm.ppm_information8;
    l_saved_ppm.ppm_information9    := l_new_ppm.ppm_information9;
    l_saved_ppm.ppm_information10   := l_new_ppm.ppm_information10;
    l_saved_ppm.ppm_information11   := l_new_ppm.ppm_information11;
    l_saved_ppm.ppm_information12   := l_new_ppm.ppm_information12;
    l_saved_ppm.ppm_information13   := l_new_ppm.ppm_information13;
    l_saved_ppm.ppm_information14   := l_new_ppm.ppm_information14;
    l_saved_ppm.ppm_information15   := l_new_ppm.ppm_information15;
    l_saved_ppm.ppm_information16   := l_new_ppm.ppm_information16;
    l_saved_ppm.ppm_information17   := l_new_ppm.ppm_information17;
    l_saved_ppm.ppm_information18   := l_new_ppm.ppm_information18;
    l_saved_ppm.ppm_information19   := l_new_ppm.ppm_information19;
    l_saved_ppm.ppm_information20   := l_new_ppm.ppm_information20;
	l_saved_ppm.ppm_information21   := l_new_ppm.ppm_information21;
    l_saved_ppm.ppm_information22   := l_new_ppm.ppm_information22;
    l_saved_ppm.ppm_information23   := l_new_ppm.ppm_information23;
    l_saved_ppm.ppm_information24   := l_new_ppm.ppm_information24;
    l_saved_ppm.ppm_information25   := l_new_ppm.ppm_information25;
    l_saved_ppm.ppm_information26   := l_new_ppm.ppm_information26;
    l_saved_ppm.ppm_information27   := l_new_ppm.ppm_information27;
    l_saved_ppm.ppm_information28   := l_new_ppm.ppm_information28;
    l_saved_ppm.ppm_information29   := l_new_ppm.ppm_information29;
    l_saved_ppm.ppm_information30   := l_new_ppm.ppm_information30;
    --
    -- If there is no difference from the original saved PPM then no
    -- input validation is required, but the changes need to be saved.
    -- This cannot be done for PPMs newly created during this PSS
    -- session (being paranoid just in case the UI does not validate
    -- mandatory fields) as the "original" just contains NULL fields
    -- which correspond to an invalid PPM.
    --
    if not l_original and l_saved_ppm.state = C_STATE_UPDATED then
      --
      -- The above version of changedppm ignores logical_priority so
      -- do the check here.
      --
      if l_saved_ppm.logical_priority = l_saved_ppm.o_logical_priority then
        pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXISTING', 30);
        l_saved_ppm.state := C_STATE_EXISTING;
      end if;
      --
      -- Save the PPM and return.
      --
      pay_ppmv4_utils_ss.seterrorstage(l_proc, 'PPM2TT', 40);
      pay_ppmv4_utils_ss.ppm2tt
      (p_ppm => l_saved_ppm
      );
      pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 50);
      --
      -- Set up messages to Oracle Applications API standards as these
      -- are handled "for free" using checkErrors().
      --
      p_return_status := fnd_api.G_RET_STS_SUCCESS;
      fnd_msg_pub.count_and_get
      (p_count => p_msg_count
      ,p_data  => p_msg_data
      );
      return;
    end if;
    --
    -- The PPM has been updated (rather than just having its priority
    -- changed) so update its state accordingly.
    --
    if l_saved_ppm.state = C_STATE_EXISTING then
      pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXISTING', 60);
      l_saved_ppm.state := C_STATE_UPDATED;
    end if;
  -------------------------
  -- A NEWLY CREATED PPM --
  -------------------------
  else
    l_saved_ppm := l_new_ppm;
    l_saved_ppm.state := C_STATE_NEW;
    l_saved_ppm.logical_priority := 1;
    --
    -- Reuse any available freed transaction.
    --
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'GETTXSTEPIDS', 80);
    l_freed_txstepids := gettxstepids
    (p_transaction_id => p_transaction_id
    ,p_freed          => true
    );
    l_freed_txstepid := pay_ppmv4_utils_ss.nextentry
    (p_list      => l_freed_txstepids
    ,p_separator => C_COMMA
    ,p_start     => l_start
    );
    l_saved_ppm.transaction_step_id := to_number(l_freed_txstepid);
  end if;
  --
  -- Get the bank segments, if necessary.
  --
  if l_saved_ppm.external_account_id is not null then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'GET_SEGMENTS', 85);
    pay_ppmv4_utils_ss.get_bank_segments
    (p_external_account_id => l_saved_ppm.external_account_id
    ,p_segment1            => l_segment1
    ,p_segment2            => l_segment2
    ,p_segment3            => l_segment3
    ,p_segment4            => l_segment4
    ,p_segment5            => l_segment5
    ,p_segment6            => l_segment6
    ,p_segment7            => l_segment7
    ,p_segment8            => l_segment8
    ,p_segment9            => l_segment9
    ,p_segment10           => l_segment10
    ,p_segment11           => l_segment11
    ,p_segment12           => l_segment12
    ,p_segment13           => l_segment13
    ,p_segment14           => l_segment14
    ,p_segment15           => l_segment15
    ,p_segment16           => l_segment16
    ,p_segment17           => l_segment17
    ,p_segment18           => l_segment18
    ,p_segment19           => l_segment19
    ,p_segment20           => l_segment20
    ,p_segment21           => l_segment21
    ,p_segment22           => l_segment22
    ,p_segment23           => l_segment23
    ,p_segment24           => l_segment24
    ,p_segment25           => l_segment25
    ,p_segment26           => l_segment26
    ,p_segment27           => l_segment27
    ,p_segment28           => l_segment28
    ,p_segment29           => l_segment29
    ,p_segment30           => l_segment30
    );
  end if;
  --
--  chk_foreign_account(p_transaction_step_id   => p_transaction_step_id); removed for Foreign Account Enh akadam
  --
  -- Validate the PPM changes.
  --
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'VALIDATEPPM', 90);
  pay_ppmv4_utils_ss.validateppm
  (p_state                      => l_saved_ppm.state
  ,p_personal_payment_method_id => l_saved_ppm.personal_payment_method_id
  ,p_object_version_number      => l_saved_ppm.update_ovn
  ,p_update_datetrack_mode      => l_saved_ppm.update_datetrack_mode
  ,p_effective_date             => l_saved_ppm.effective_date
  ,p_org_payment_method_id      => l_saved_ppm.org_payment_method_id
  ,p_assignment_id              => l_saved_ppm.assignment_id
  ,p_run_type_id                => l_saved_ppm.run_type_id
  ,p_payment_type               => l_saved_ppm.payment_type
  ,p_territory_code             => l_saved_ppm.territory_code
  ,p_amount_type                => l_saved_ppm.amount_type
  ,p_amount                     => l_saved_ppm.amount
  ,p_external_account_id        => l_saved_ppm.external_account_id
  ,p_attribute_category         => l_saved_ppm.attribute_category
  ,p_attribute1                 => l_saved_ppm.attribute1
  ,p_attribute2                 => l_saved_ppm.attribute2
  ,p_attribute3                 => l_saved_ppm.attribute3
  ,p_attribute4                 => l_saved_ppm.attribute4
  ,p_attribute5                 => l_saved_ppm.attribute5
  ,p_attribute6                 => l_saved_ppm.attribute6
  ,p_attribute7                 => l_saved_ppm.attribute7
  ,p_attribute8                 => l_saved_ppm.attribute8
  ,p_attribute9                 => l_saved_ppm.attribute9
  ,p_attribute10                => l_saved_ppm.attribute10
  ,p_attribute11                => l_saved_ppm.attribute11
  ,p_attribute12                => l_saved_ppm.attribute12
  ,p_attribute13                => l_saved_ppm.attribute13
  ,p_attribute14                => l_saved_ppm.attribute14
  ,p_attribute15                => l_saved_ppm.attribute15
  ,p_attribute16                => l_saved_ppm.attribute16
  ,p_attribute17                => l_saved_ppm.attribute17
  ,p_attribute18                => l_saved_ppm.attribute18
  ,p_attribute19                => l_saved_ppm.attribute19
  ,p_attribute20                => l_saved_ppm.attribute20
  ,p_ppm_information_category   => l_saved_ppm.ppm_information_category
  ,p_ppm_information1           => l_saved_ppm.ppm_information1
  ,p_ppm_information2           => l_saved_ppm.ppm_information2
  ,p_ppm_information3           => l_saved_ppm.ppm_information3
  ,p_ppm_information4           => l_saved_ppm.ppm_information4
  ,p_ppm_information5           => l_saved_ppm.ppm_information5
  ,p_ppm_information6           => l_saved_ppm.ppm_information6
  ,p_ppm_information7           => l_saved_ppm.ppm_information7
  ,p_ppm_information8           => l_saved_ppm.ppm_information8
  ,p_ppm_information9           => l_saved_ppm.ppm_information9
  ,p_ppm_information10          => l_saved_ppm.ppm_information10
  ,p_ppm_information11          => l_saved_ppm.ppm_information11
  ,p_ppm_information12          => l_saved_ppm.ppm_information12
  ,p_ppm_information13          => l_saved_ppm.ppm_information13
  ,p_ppm_information14          => l_saved_ppm.ppm_information14
  ,p_ppm_information15          => l_saved_ppm.ppm_information15
  ,p_ppm_information16          => l_saved_ppm.ppm_information16
  ,p_ppm_information17          => l_saved_ppm.ppm_information17
  ,p_ppm_information18          => l_saved_ppm.ppm_information18
  ,p_ppm_information19          => l_saved_ppm.ppm_information19
  ,p_ppm_information20          => l_saved_ppm.ppm_information20
  ,p_ppm_information21          => l_saved_ppm.ppm_information21
  ,p_ppm_information22          => l_saved_ppm.ppm_information22
  ,p_ppm_information23          => l_saved_ppm.ppm_information23
  ,p_ppm_information24          => l_saved_ppm.ppm_information24
  ,p_ppm_information25          => l_saved_ppm.ppm_information25
  ,p_ppm_information26          => l_saved_ppm.ppm_information26
  ,p_ppm_information27          => l_saved_ppm.ppm_information27
  ,p_ppm_information28          => l_saved_ppm.ppm_information28
  ,p_ppm_information29          => l_saved_ppm.ppm_information29
  ,p_ppm_information30          => l_saved_ppm.ppm_information30
  ,p_segment1                   => l_segment1
  ,p_segment2                   => l_segment2
  ,p_segment3                   => l_segment3
  ,p_segment4                   => l_segment4
  ,p_segment5                   => l_segment5
  ,p_segment6                   => l_segment6
  ,p_segment7                   => l_segment7
  ,p_segment8                   => l_segment8
  ,p_segment9                   => l_segment9
  ,p_segment10                  => l_segment10
  ,p_segment11                  => l_segment11
  ,p_segment12                  => l_segment12
  ,p_segment13                  => l_segment13
  ,p_segment14                  => l_segment14
  ,p_segment15                  => l_segment15
  ,p_segment16                  => l_segment16
  ,p_segment17                  => l_segment17
  ,p_segment18                  => l_segment18
  ,p_segment19                  => l_segment19
  ,p_segment20                  => l_segment20
  ,p_segment21                  => l_segment21
  ,p_segment22                  => l_segment22
  ,p_segment23                  => l_segment23
  ,p_segment24                  => l_segment24
  ,p_segment25                  => l_segment25
  ,p_segment26                  => l_segment26
  ,p_segment27                  => l_segment27
  ,p_segment28                  => l_segment28
  ,p_segment29                  => l_segment29
  ,p_segment30                  => l_segment30
  ,p_return_status              => l_return_status
  ,p_msg_data                   => l_msg_data
  ,p_msg_count                  => l_msg_count
  );
  --
  -- Save the PPM if there were no errors.
  --
  if l_return_status = fnd_api.G_RET_STS_SUCCESS then
    --
    -- Increment the logical priorities if this is a brand
    -- new PPM - it must be inserted at priority 1.
    --
    if p_transaction_step_id is null then
      pay_ppmv4_utils_ss.seterrorstage(l_proc, 'INCREMENT_PRIORITIES', 100);
      increment_priorities
      (p_transaction_id  => p_transaction_id
      );
    end if;
    --
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'PPM2TT', 110);
    pay_ppmv4_utils_ss.ppm2tt
    (p_ppm             => l_saved_ppm
    );
    --
    -- Update p_transaction_step_id.
    --
    p_transaction_step_id := l_saved_ppm.transaction_step_id;
  end if;
  --
  -- Set up messages to Oracle Applications API standards as these
  -- are handled "for free" using checkErrors().
  --
  p_return_status := l_return_status;
  fnd_msg_pub.count_and_get
  (p_count => p_msg_count
  ,p_data  => p_msg_data
  );
  if l_return_status = fnd_api.G_RET_STS_SUCCESS then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 120);
  else
    pay_ppmv4_utils_ss.seterrorstage
    (l_proc, 'EXIT:VALIDATE_FAIL:' || l_return_status, 125);
  end if;
  return;
exception
  when others then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:FAIL', 130);
    --
    -- Set up messages to Oracle Applications API standards as these
    -- are handled "for free" using checkErrors().
    --
    p_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg
    (p_pkg_name       => g_package
    ,p_procedure_name => 'enter_ppm'
    );
    fnd_msg_pub.count_and_get
    (p_count => p_msg_count
    ,p_data  => p_msg_data
    );
    return;
end enter_ppm;
---------------------------------< delete_ppm >----------------------------
procedure delete_ppm
(p_transaction_step_id in     varchar2
,p_return_status          out nocopy varchar2
,p_msg_count              out nocopy number
,p_msg_data               out nocopy varchar2
) is
l_state          varchar2(2000);
l_amount_type    varchar2(2000);
l_transaction_id number;
l_ppm            pay_ppmv4_utils_ss.t_ppmv4;
l_proc           varchar2(2000) := g_package||'delete_ppm';
l_message_name   varchar2(2000);
begin
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ENTER', 0);
  --
  -- Initialise the AOL message tables.
  --
  fnd_msg_pub.initialize;
  --
  -- Get additional information about this PPM.
  --
  select p.state
  ,      p.amount_type
  ,      p.transaction_id
  into   l_state
  ,      l_amount_type
  ,      l_transaction_id
  from   pay_pss_transaction_steps p
  where  p.transaction_step_id = p_transaction_step_id;
  --
  -- If this is a newly created PPM then it's only necessary to update
  -- the state.
  --
  if l_state = C_STATE_NEW then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'PPM_FREED', 10);
    update pay_pss_transaction_steps p
    set    p.state = C_STATE_FREED
    where  p.transaction_step_id = p_transaction_step_id;
  else
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'TT2PPM', 20);
    pay_ppmv4_utils_ss.tt2ppm
    (p_transaction_step_id => p_transaction_step_id
    ,p_ppm                 => l_ppm
    );
    --
    -- All the information for deleting the PPM is automatically set up.
    -- Call process_api to validate the changes.
    --
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'PROCESS_API', 25);
    begin
      pay_ppmv4_utils_ss.process_api
      (p_validate                   => true
      ,p_state                      => C_STATE_DELETED
      ,p_effective_date             => l_ppm.effective_date
      ,p_personal_payment_method_id => l_ppm.personal_payment_method_id
      ,p_delete_datetrack_mode      => l_ppm.delete_datetrack_mode
      ,p_delete_ovn                 => l_ppm.delete_ovn
      );
    exception
      when others then
        hr_message.provide_error;
        l_message_name := hr_message.last_message_name;
        if l_message_name = 'HR_7360_PPM_DEL_NOT_ALLOWED' or
           l_message_name = 'HR_6679_PPM_PRE_PAY' or
           l_message_name = 'PER_PRS_PAY_MTD_DISABLE_DEL'
        then
          pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:FAIL:1', 30);
          --
          -- Handle valid DELETE failures:
          -- a) Prepayments exist.
          -- b) 3rd Party Payroll interface does not allow zap deletes.
          --
          fnd_message.set_name('PAY', 'PAY_51519_PSS_CANNOT_DELETE');
          fnd_msg_pub.add;
          p_return_status := fnd_api.G_RET_STS_ERROR;
          fnd_msg_pub.count_and_get
          (p_count => p_msg_count
          ,p_data  => p_msg_data
          );
          return;
        else
          --
          -- Unexpected error so raise the exception.
          --
          raise;
        end if;
    end;
    l_ppm.logical_priority    := null;
    l_ppm.amount_type         := null;
    l_ppm.amount              := null;
    l_ppm.external_account_id := null;
    l_ppm.attribute_category  := null;
    l_ppm.attribute1          := null;
    l_ppm.attribute2          := null;
    l_ppm.attribute3          := null;
    l_ppm.attribute4          := null;
    l_ppm.attribute5          := null;
    l_ppm.attribute6          := null;
    l_ppm.attribute7          := null;
    l_ppm.attribute8          := null;
    l_ppm.attribute9          := null;
    l_ppm.attribute10         := null;
    l_ppm.attribute11         := null;
    l_ppm.attribute12         := null;
    l_ppm.attribute13         := null;
    l_ppm.attribute14         := null;
    l_ppm.attribute15         := null;
    l_ppm.attribute15         := null;
    l_ppm.attribute16         := null;
    l_ppm.attribute17         := null;
    l_ppm.attribute18         := null;
    l_ppm.attribute19         := null;
    l_ppm.attribute20         := null;
    l_ppm.state               := C_STATE_DELETED;

	l_ppm.ppm_information_category  := null;
    l_ppm.ppm_information1    := null;
    l_ppm.ppm_information2    := null;
    l_ppm.ppm_information3    := null;
    l_ppm.ppm_information4    := null;
    l_ppm.ppm_information5    := null;
    l_ppm.ppm_information6    := null;
    l_ppm.ppm_information7    := null;
    l_ppm.ppm_information8    := null;
    l_ppm.ppm_information9    := null;
    l_ppm.ppm_information10   := null;
    l_ppm.ppm_information11   := null;
    l_ppm.ppm_information12   := null;
    l_ppm.ppm_information13   := null;
    l_ppm.ppm_information14   := null;
    l_ppm.ppm_information15   := null;
    l_ppm.ppm_information15   := null;
    l_ppm.ppm_information16   := null;
    l_ppm.ppm_information17   := null;
    l_ppm.ppm_information18   := null;
    l_ppm.ppm_information19   := null;
    l_ppm.ppm_information20   := null;
	l_ppm.ppm_information21   := null;
    l_ppm.ppm_information22   := null;
    l_ppm.ppm_information23   := null;
    l_ppm.ppm_information24   := null;
    l_ppm.ppm_information25   := null;
    l_ppm.ppm_information26   := null;
    l_ppm.ppm_information27   := null;
    l_ppm.ppm_information28   := null;
    l_ppm.ppm_information29   := null;
    l_ppm.ppm_information30   := null;
    --
    -- Write back the PPM.
    --
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'DELETED', 40);
    pay_ppmv4_utils_ss.ppm2tt
    (p_ppm => l_ppm
    );
  end if;
  --
  -- If the Remaining Pay PPM was deleted then it's necessary to create a
  -- new Remaining Pay PPM.
  --
  if l_amount_type = C_REMAINING_PAY then
    update_remaining_pay_ppm
    (p_transaction_id => l_transaction_id
    );
  end if;
  --
  -- Set up messages to Oracle Applications API standards as these
  -- are handled "for free" using checkErrors().
  --
  p_return_status := fnd_api.G_RET_STS_SUCCESS;
  fnd_msg_pub.count_and_get
  (p_count => p_msg_count
  ,p_data  => p_msg_data
  );
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 45);
  return;
exception
  when others then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:FAIL:2', 50);
    --
    -- Set up messages to Oracle Applications API standards as these
    -- are handled "for free" using checkErrors().
    --
    fnd_message.set_name('PAY', 'PAY_51518_PSS_ASSERT_ERROR');
    fnd_message.set_token('WHERE', l_proc);
    fnd_message.set_token('ADDITIONAL_INFO', sqlerrm);
    fnd_msg_pub.add;
    p_return_status := fnd_api.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get
    (p_count => p_msg_count
    ,p_data  => p_msg_data
    );
    return;
end delete_ppm;
--
-------------------------< resequence_priorities >-----------------------
--
-- {Start Of Comments}
--
-- Description:
--
--   Called after the API calls in the transaction to make the pay method
--   go up in sequence order 1, 2, 3, .. N.
--
-- Prerequisites:
--   Also, all of the PPMSS transaction API calls must have been made.
--
-- Post Success:
--   The pay method priorities are updated.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure resequence_priorities
(p_assignment_id  in number
,p_effective_date in date
,p_run_type_id    in number default null
,p_transaction_step_id in number default null
) is
l_proc       varchar2(2000) := g_package || 'resequence_priorities';
l_priority   number;
l_dt_mode    varchar2(30);
l_exaid      number;
l_comment_id number;
l_esd        date;
l_eed        date;

l_ppm             pay_ppmv4_utils_ss.t_ppmv4;
--
cursor c_ppms(p_assignment_id in number, p_effective_date in date) is
select ppm.personal_payment_method_id ppmid
,      ppm.object_version_number      ovn
,      ppm.effective_start_date       esd
,      ppm.priority                   priority
from   pay_personal_payment_methods_f ppm
,      pay_org_payment_methods_f      opm
where  ppm.assignment_id = p_assignment_id
and    nvl(ppm.run_type_id, hr_api.g_number) = nvl(p_run_type_id, hr_api.g_number)
and    p_effective_date
       between ppm.effective_start_date and ppm.effective_end_date
and    opm.org_payment_method_id = ppm.org_payment_method_id
and    p_effective_date between
       opm.effective_start_date and opm.effective_end_date
and    opm.defined_balance_id is not null
order  by ppm.priority;
begin
  --
  -- Fix up the priorities.
  --
  hr_utility.trace('Entering resequence_priorities....');
  l_priority := pay_ppmv4_utils_ss.C_MIN_PRIORITY;
  for ppm in c_ppms(p_assignment_id, p_effective_date) loop
    hr_utility.trace('ppm.priority => '||ppm.priority);
    hr_utility.trace('l_priority   => '||l_priority);
    if ppm.priority <> l_priority then
      pay_ppmv4_utils_ss.tt2ppm
     (p_transaction_step_id => p_transaction_step_id
     ,p_ppm                 => l_ppm
     );
      --
      -- Set the correct datetrack mode.
      --
      l_dt_mode := hr_api.g_correction;
      if ppm.esd < p_effective_date then
        l_dt_mode := hr_api.g_update;
      end if;
      hr_utility.trace('Calling UPDATE from resequence_priorities');
      hr_personal_pay_method_api.update_personal_pay_method
      (p_validate                   => false
      ,p_personal_payment_method_id => ppm.ppmid
      ,p_object_version_number      => ppm.ovn
      ,p_priority                   => l_priority
      ,p_effective_date             => p_effective_date
      ,p_datetrack_update_mode      => l_dt_mode
      /*,p_ppm_information_category   => l_ppm.ppm_information_category
      ,p_ppm_information1           => l_ppm.ppm_information1
      ,p_ppm_information2           => l_ppm.ppm_information2
      ,p_ppm_information3           => l_ppm.ppm_information3
      ,p_ppm_information4           => l_ppm.ppm_information4
      ,p_ppm_information5           => l_ppm.ppm_information5
      ,p_ppm_information6           => l_ppm.ppm_information6
      ,p_ppm_information7           => l_ppm.ppm_information7
      ,p_ppm_information8           => l_ppm.ppm_information8
      ,p_ppm_information9           => l_ppm.ppm_information9
      ,p_ppm_information10          => l_ppm.ppm_information10
      ,p_ppm_information11          => l_ppm.ppm_information11
      ,p_ppm_information12          => l_ppm.ppm_information12
      ,p_ppm_information13          => l_ppm.ppm_information13
      ,p_ppm_information14          => l_ppm.ppm_information14
      ,p_ppm_information15          => l_ppm.ppm_information15
      ,p_ppm_information16          => l_ppm.ppm_information16
      ,p_ppm_information17          => l_ppm.ppm_information17
      ,p_ppm_information18          => l_ppm.ppm_information18
      ,p_ppm_information19          => l_ppm.ppm_information19
      ,p_ppm_information20          => l_ppm.ppm_information20
      ,p_ppm_information21          => l_ppm.ppm_information21
      ,p_ppm_information22          => l_ppm.ppm_information22
      ,p_ppm_information23          => l_ppm.ppm_information23
      ,p_ppm_information24          => l_ppm.ppm_information24
      ,p_ppm_information25          => l_ppm.ppm_information25
      ,p_ppm_information26          => l_ppm.ppm_information26
      ,p_ppm_information27          => l_ppm.ppm_information27
      ,p_ppm_information28          => l_ppm.ppm_information28
      ,p_ppm_information29          => l_ppm.ppm_information29
      ,p_ppm_information30          => l_ppm.ppm_information30*/
      ,p_external_account_id        => l_exaid
      ,p_effective_start_date       => l_esd
      ,p_effective_end_date         => l_eed
      ,p_comment_id                 => l_comment_id
      );
      hr_utility.trace('Came out from UPDATE in resequence_priorities');
    end if;
    l_priority := l_priority + 1;
  end loop;
exception
  when others then
    raise;
end resequence_priorities;
-------------------------------< process_api >---------------------------
procedure process_api
(p_transaction_step_id in number
,p_validate            in boolean default false
) is
l_ppm             pay_ppmv4_utils_ss.t_ppmv4;
l_proc            varchar2(2000) := g_package||'process_api';
l_pss_txstepid  number;
l_segment1        varchar2(2000);
l_segment2        varchar2(2000);
l_segment3        varchar2(2000);
l_segment4        varchar2(2000);
l_segment5        varchar2(2000);
l_segment6        varchar2(2000);
l_segment7        varchar2(2000);
l_segment8        varchar2(2000);
l_segment9        varchar2(2000);
l_segment10       varchar2(2000);
l_segment11       varchar2(2000);
l_segment12       varchar2(2000);
l_segment13       varchar2(2000);
l_segment14       varchar2(2000);
l_segment15       varchar2(2000);
l_segment16       varchar2(2000);
l_segment17       varchar2(2000);
l_segment18       varchar2(2000);
l_segment19       varchar2(2000);
l_segment20       varchar2(2000);
l_segment21       varchar2(2000);
l_segment22       varchar2(2000);
l_segment23       varchar2(2000);
l_segment24       varchar2(2000);
l_segment25       varchar2(2000);
l_segment26       varchar2(2000);
l_segment27       varchar2(2000);
l_segment28       varchar2(2000);
l_segment29       varchar2(2000);
l_segment30       varchar2(2000);
--
l_hr_txpersonid   number;
l_hr_txid         number;
l_unprocessed     number;
begin
  --HR_UTILITY.TRACE_ON(NULL,'PPM');
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'ENTER', 0);
  l_pss_txstepid := hr_transaction_api.get_number_value
  (p_transaction_step_id => p_transaction_step_id
  ,p_name                => pay_ppmv4_utils_ss.C_TX_STEP_ID_ARG
  );

  pay_ppmv4_utils_ss.tt2ppm
  (p_transaction_step_id => l_pss_txstepid
  ,p_ppm                 => l_ppm
  );
  --
  -- Get the bank segments for deposit PPMs.
  --

  if  l_ppm.external_account_id is not null then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'GET_BANK_SEGMENTS', 5);
    pay_ppmv4_utils_ss.get_bank_segments
    (p_external_account_id => l_ppm.external_account_id
    ,p_segment1            => l_segment1
    ,p_segment2            => l_segment2
    ,p_segment3            => l_segment3
    ,p_segment4            => l_segment4
    ,p_segment5            => l_segment5
    ,p_segment6            => l_segment6
    ,p_segment7            => l_segment7
    ,p_segment8            => l_segment8
    ,p_segment9            => l_segment9
    ,p_segment10           => l_segment10
    ,p_segment11           => l_segment11
    ,p_segment12           => l_segment12
    ,p_segment13           => l_segment13
    ,p_segment14           => l_segment14
    ,p_segment15           => l_segment15
    ,p_segment16           => l_segment16
    ,p_segment17           => l_segment17
    ,p_segment18           => l_segment18
    ,p_segment19           => l_segment19
    ,p_segment20           => l_segment20
    ,p_segment21           => l_segment21
    ,p_segment22           => l_segment22
    ,p_segment23           => l_segment23
    ,p_segment24           => l_segment24
    ,p_segment25           => l_segment25
    ,p_segment26           => l_segment26
    ,p_segment27           => l_segment27
    ,p_segment28           => l_segment28
    ,p_segment29           => l_segment29
    ,p_segment30           => l_segment30
    );
  end if;
  --
  -- Make the API call.
  --
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'PROCESS_API', 10);
  hr_utility.trace('l_ppm.ppm_information_category => '||l_ppm.ppm_information_category);
  hr_utility.trace('l_pss_txstepid => '||l_pss_txstepid);
  pay_ppmv4_utils_ss.process_api
  (p_state                      => l_ppm.state
  ,p_personal_payment_method_id => l_ppm.personal_payment_method_id
  ,p_object_version_number      => l_ppm.update_ovn
  ,p_delete_ovn                 => l_ppm.delete_ovn
  ,p_update_datetrack_mode      => l_ppm.update_datetrack_mode
  ,p_delete_datetrack_mode      => l_ppm.delete_datetrack_mode
  ,p_effective_date             => l_ppm.effective_date
  ,p_org_payment_method_id      => l_ppm.org_payment_method_id
  ,p_assignment_id              => l_ppm.assignment_id
  ,p_run_type_id                => l_ppm.run_type_id
  ,p_territory_code             => l_ppm.territory_code
  ,p_real_priority              => l_ppm.real_priority
  ,p_amount_type                => l_ppm.amount_type
  ,p_amount                     => l_ppm.amount
  ,p_attribute_category         => l_ppm.attribute_category
  ,p_attribute1                 => l_ppm.attribute1
  ,p_attribute2                 => l_ppm.attribute2
  ,p_attribute3                 => l_ppm.attribute3
  ,p_attribute4                 => l_ppm.attribute4
  ,p_attribute5                 => l_ppm.attribute5
  ,p_attribute6                 => l_ppm.attribute6
  ,p_attribute7                 => l_ppm.attribute7
  ,p_attribute8                 => l_ppm.attribute8
  ,p_attribute9                 => l_ppm.attribute9
  ,p_attribute10                => l_ppm.attribute10
  ,p_attribute11                => l_ppm.attribute11
  ,p_attribute12                => l_ppm.attribute12
  ,p_attribute13                => l_ppm.attribute13
  ,p_attribute14                => l_ppm.attribute14
  ,p_attribute15                => l_ppm.attribute15
  ,p_attribute16                => l_ppm.attribute16
  ,p_attribute17                => l_ppm.attribute17
  ,p_attribute18                => l_ppm.attribute18
  ,p_attribute19                => l_ppm.attribute19
  ,p_attribute20                => l_ppm.attribute20
  ,p_segment1                   => l_segment1
  ,p_segment2                   => l_segment2
  ,p_segment3                   => l_segment3
  ,p_segment4                   => l_segment4
  ,p_segment5                   => l_segment5
  ,p_segment6                   => l_segment6
  ,p_segment7                   => l_segment7
  ,p_segment8                   => l_segment8
  ,p_segment9                   => l_segment9
  ,p_segment10                  => l_segment10
  ,p_segment11                  => l_segment11
  ,p_segment12                  => l_segment12
  ,p_segment13                  => l_segment13
  ,p_segment14                  => l_segment14
  ,p_segment15                  => l_segment15
  ,p_segment16                  => l_segment16
  ,p_segment17                  => l_segment17
  ,p_segment18                  => l_segment18
  ,p_segment19                  => l_segment19
  ,p_segment20                  => l_segment20
  ,p_segment21                  => l_segment21
  ,p_segment22                  => l_segment22
  ,p_segment23                  => l_segment23
  ,p_segment24                  => l_segment24
  ,p_segment25                  => l_segment25
  ,p_segment26                  => l_segment26
  ,p_segment27                  => l_segment27
  ,p_segment28                  => l_segment28
  ,p_segment29                  => l_segment29
  ,p_segment30                  => l_segment30
  ,p_o_real_priority            => l_ppm.o_real_priority
  ,p_ppm_information_category   => l_ppm.ppm_information_category
  ,p_ppm_information1           => l_ppm.ppm_information1
  ,p_ppm_information2           => l_ppm.ppm_information2
  ,p_ppm_information3           => l_ppm.ppm_information3
  ,p_ppm_information4           => l_ppm.ppm_information4
  ,p_ppm_information5           => l_ppm.ppm_information5
  ,p_ppm_information6           => l_ppm.ppm_information6
  ,p_ppm_information7           => l_ppm.ppm_information7
  ,p_ppm_information8           => l_ppm.ppm_information8
  ,p_ppm_information9           => l_ppm.ppm_information9
  ,p_ppm_information10          => l_ppm.ppm_information10
  ,p_ppm_information11          => l_ppm.ppm_information11
  ,p_ppm_information12          => l_ppm.ppm_information12
  ,p_ppm_information13          => l_ppm.ppm_information13
  ,p_ppm_information14          => l_ppm.ppm_information14
  ,p_ppm_information15          => l_ppm.ppm_information15
  ,p_ppm_information16          => l_ppm.ppm_information16
  ,p_ppm_information17          => l_ppm.ppm_information17
  ,p_ppm_information18          => l_ppm.ppm_information18
  ,p_ppm_information19          => l_ppm.ppm_information19
  ,p_ppm_information20          => l_ppm.ppm_information20
  ,p_ppm_information21          => l_ppm.ppm_information21
  ,p_ppm_information22          => l_ppm.ppm_information22
  ,p_ppm_information23          => l_ppm.ppm_information23
  ,p_ppm_information24          => l_ppm.ppm_information24
  ,p_ppm_information25          => l_ppm.ppm_information25
  ,p_ppm_information26          => l_ppm.ppm_information26
  ,p_ppm_information27          => l_ppm.ppm_information27
  ,p_ppm_information28          => l_ppm.ppm_information28
  ,p_ppm_information29          => l_ppm.ppm_information29
  ,p_ppm_information30          => l_ppm.ppm_information30
  ,p_validate                   => p_validate
  );
  if not p_validate then
    --
    -- Get the HR transaction information.
    --
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'GET_HR_TX_INFO', 20);
    select creator_person_id
    ,      transaction_id
    into   l_hr_txpersonid
    ,      l_hr_txid
    from   hr_api_transaction_steps
    where  transaction_step_id = p_transaction_step_id;
    --
    -- Set the processed flag for this transaction.
    --
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'SET_PROCESSED_FLAG', 25);
    hr_transaction_api.set_varchar2_value
    (p_validate            => false
    ,p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => l_hr_txpersonid
    ,p_name                => pay_ppmv4_utils_ss.C_PROCESSED_FLAG_ARG
    ,p_value               => 'Y'
    );
    --
    -- Check is any HR transactions are still to be processed.
    --
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'COUNT_UNPROCESSED', 30);
    select count(*)
    into   l_unprocessed
    from   hr_api_transaction_values hatv
    where  hatv.name = pay_ppmv4_utils_ss.C_PROCESSED_FLAG_ARG
    and    hatv.varchar2_value = 'N'
    and    hatv.transaction_step_id in
    (select transaction_step_id
     from   hr_api_transaction_steps hats
     where  hats.transaction_id = l_hr_txid);
    pay_ppmv4_utils_ss.seterrorstage
    (l_proc, 'UNPROCESSED_COUNT:' || to_char(l_unprocessed), 35);
    --
    -- Resequence priorities if nothing left to be processed.
    --
    if l_unprocessed = 0 then
      pay_ppmv4_utils_ss.seterrorstage(l_proc, 'RESEQUENCE_PRIORITIES', 40);
      resequence_priorities
      (p_assignment_id  => l_ppm.assignment_id
      ,p_effective_date => l_ppm.effective_date
      ,p_run_type_id    => l_ppm.run_type_id
      ,p_transaction_step_id => l_pss_txstepid
      );
    end if;
  end if;
  pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:SUCCESS', 50);
  return;
exception
  when others then
    pay_ppmv4_utils_ss.seterrorstage(l_proc, 'EXIT:FAIL', 60);
    raise;
end process_api;
------------------------< delete_pss_transactions >----------------------
procedure delete_ppm_transactions
(item_type in     varchar2
,item_key  in     varchar2
,actid     in     number
,funmode   in     varchar2
,result       out nocopy varchar2
) is
l_transaction_id varchar2(2000);
begin
  if funmode = 'RUN' then
    --
    -- Make sure that the transaction workflow attribute is set-up. It
    -- may not be if there was a problem with the configuration.
    --
    begin
      l_transaction_id := wf_engine.getitemattrtext
      (itemtype => item_type
      ,itemkey  => item_key
      ,aname    => C_PSS_TXID_WF_ATTRIBUTE
      );
    exception
      when others then
        l_transaction_id := null;
    end;
    if l_transaction_id is not null then
      pay_pss_tx_steps_pkg.delete_rows
      (p_transaction_id => to_number(l_transaction_id)
      );
    end if;
    result := 'SUCCESS';
  end if;
exception
  when others then
    raise;
end delete_ppm_transactions;
--------------------------< resequence_priorities >-----------------------
procedure resequence_priorities
(item_type in     varchar2
,item_key  in     varchar2
,actid     in     number
,funmode   in     varchar2
,result       out nocopy varchar2
) is
begin
  --
  -- This code must not be changed.
  --
  result := 'SUCCESS';
end resequence_priorities;
--

-------------------------< get_ppm_country >-----------------------
--
-- {Start Of Comments}
--
-- Description:
-- 11-12-2006 This function gets the Country associated with the PPM
--
--
-- Prerequisites:
--   None.
--
-- Post Success:
--  Always returns the Terirory code associated with the PPM
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_ppm_country
(p_org_payment_method_id IN number,
 p_business_group_id IN     number,
 p_return_desc IN VARCHAR2 default 'N'
)return varchar2 IS

cursor c_get_country_code (
   cp_org_payment_method_id  number) IS
   SELECT ppt.territory_code,
          TERR.territory_short_name
   FROM pay_org_payment_methods_f pom,
        pay_payment_types ppt,
        FND_TERRITORIES_VL TERR
   WHERE pom.org_payment_method_id = cp_org_payment_method_id
        AND pom.payment_type_id = ppt.payment_type_id
        AND ppt.territory_code = TERR.territory_code (+);

cursor c_get_bg_country (
   cp_business_group_id number) IS
   SELECT org_inf.org_information9,
          TERR.territory_short_name
   FROM hr_all_organization_units org,
        hr_organization_information org_inf,
        FND_TERRITORIES_VL TERR
   WHERE org.ORGANIZATION_ID = cp_business_group_id
        AND org.ORGANIZATION_ID = org_inf.ORGANIZATION_ID
        AND ORG_INFORMATION_CONTEXT = 'Business Group Information'
        AND org_inf.org_information9 = TERR.territory_code (+);

l_ppt_territory_code pay_payment_types.territory_code%TYPE;
l_bg_country hr_organization_information.org_information9%TYPE;
l_territory_desc FND_TERRITORIES_VL.territory_short_name%TYPE;

begin
l_ppt_territory_code := null;
l_bg_country := null;
l_territory_desc := null;

open c_get_country_code(p_org_payment_method_id);
fetch c_get_country_code into l_ppt_territory_code, l_territory_desc;
close c_get_country_code;

if l_ppt_territory_code is null then
  open c_get_bg_country(p_business_group_id);
  fetch c_get_bg_country into l_bg_country,l_territory_desc;
  close c_get_bg_country;
  if p_return_desc = 'Y' then
    return l_territory_desc;
  else
    return l_bg_country;
  end if;
else
  if p_return_desc = 'Y' then
    return l_territory_desc;
  else
    return l_ppt_territory_code;
  end if;
end if ;

end get_ppm_country;

-------------------------< get_bank_flexcode >-----------------------
--
-- {Start Of Comments}
--
-- Description:
-- 11-12-2006 This function gets the Bank Flex Structure Code
-- for country with the Payment Type Country if it is Non Generic
-- Payment Types and BG County for Generic Payment Types.
--
--
-- Prerequisites:
--   None.
--
-- Post Success:
--  Always returns the required Bank Flex Structure Code.
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_bank_flexcode
(p_org_payment_method_id IN     number,
 p_business_group_id IN     number)return varchar2 IS

l_bank_country_code hr_organization_information.org_information9%TYPE;

cursor c_get_flexcode (
    cp_opm_id number
    ,cp_bgid number ) IS
  select  flex.id_flex_structure_code
  from   pay_legislation_rules  leg
  ,      fnd_id_flex_structures flex
  ,      PAY_ORG_PAYMENT_METHODS_F opm
  ,      PAY_PAYMENT_TYPES PTS
  where  opm.ORG_PAYMENT_METHOD_ID = cp_opm_id
  and    opm.BUSINESS_GROUP_ID = cp_bgid
  and    opm.PAYMENT_TYPE_ID = PTS.PAYMENT_TYPE_ID
  and    leg.legislation_code = DECODE(PTS.territory_code, null, HR_API.RETURN_LEGISLATION_CODE(OPM.BUSINESS_GROUP_ID),PTS.territory_code)
  and    leg.rule_type = 'E'
  and    to_char(flex.id_flex_num) = leg.rule_mode
  and    flex.id_flex_code = 'BANK';

l_bank_flex_structure_code fnd_id_flex_structures.id_flex_structure_code%TYPE;

begin

OPEN c_get_flexcode(p_org_payment_method_id,p_business_group_id);
fetch c_get_flexcode into l_bank_flex_structure_code;
close c_get_flexcode;

return l_bank_flex_structure_code;

end get_bank_flexcode;

-------------------------< get_org_method_name >-----------------------
--
-- {Start Of Comments}
--
-- Description:
-- 11-12-2006 This function gets the ORG Payment Method Name
--
--
-- Prerequisites:
--   None.
--
-- Post Success:
--  Always returns the required Bank Flex Structure Code.
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_org_method_name
(p_org_payment_method_id IN number,
 p_business_group_id IN     number
)return varchar2 is

cursor c_get_opm_name ( cp_opmid number,
                        cp_bgid number) is
  select OPMTL.ORG_PAYMENT_METHOD_NAME
  from   PAY_ORG_PAYMENT_METHODS_F_TL OPMTL,
    PAY_ORG_PAYMENT_METHODS_F OPM
  where  OPM.ORG_PAYMENT_METHOD_ID = OPMTL.ORG_PAYMENT_METHOD_ID
  AND OPM.ORG_PAYMENT_METHOD_ID = cp_opmid
  AND BUSINESS_GROUP_ID + 0 = cp_bgid
  AND OPMTL.LANGUAGE = USERENV('LANG');

  l_payment_method_name PAY_ORG_PAYMENT_METHODS_F_TL.ORG_PAYMENT_METHOD_NAME%TYPE;
Begin
  l_payment_method_name := null;

  open c_get_opm_name(p_org_payment_method_id,p_business_group_id);
  fetch c_get_opm_name into l_payment_method_name;
  close c_get_opm_name;
  return l_payment_method_name;
end get_org_method_name;

function is_foreign_transaction(p_opm_id in number,
                                p_effective_date DATE) return varchar is
  l_is_foreign_transaction PAY_ORG_PAYMENT_METHODS_F.PMETH_INFORMATION9%TYPE;
begin
  select popm.PMETH_INFORMATION9
        INTO l_is_foreign_transaction
        from pay_org_payment_methods_f popm
        where popm.ORG_PAYMENT_METHOD_ID =  p_opm_id
        and   HR_API.RETURN_LEGISLATION_CODE(POPM.BUSINESS_GROUP_ID)='US'
        AND p_effective_date
        BETWEEN popm.effective_start_date AND popm.effective_end_date;

  return nvl(l_is_foreign_transaction,'N');
exception
        when no_data_found then
        return 'N';
end is_foreign_transaction;

function get_payment_type_name(p_opm_id number,
                               p_effective_date date) RETURN  varchar2 is

l_payment_type_name PAY_PAYMENT_TYPES.PAYMENT_TYPE_NAME%TYPE;

begin
     SELECT PT.PAYMENT_TYPE_NAME
     INTO   l_payment_type_name
     FROM   PAY_PAYMENT_TYPES PT, PAY_ORG_PAYMENT_METHODS_F PM
     WHERE  PM.ORG_PAYMENT_METHOD_ID = P_OPM_ID
     AND    PM.PAYMENT_TYPE_ID = PT.PAYMENT_TYPE_ID
     AND    P_EFFECTIVE_DATE BETWEEN PM.EFFECTIVE_START_DATE
                             AND     PM.EFFECTIVE_END_DATE;
     RETURN NVL(L_PAYMENT_TYPE_NAME,'');
     EXCEPTION
              WHEN NO_DATA_FOUND THEN
              RETURN '';
end get_payment_type_name;

procedure store_session(p_effective_date DATE) IS
   --
      --local variable
   l_eff_date date;
   l_proc constant varchar2(100) := g_package || ' setEffectiveDate';
  BEGIN
   hr_utility.set_location('Entering: '|| l_proc,5);
   hr_utility.set_location('Effective Date => '||p_effective_date,6);
   hr_utility.set_location('Session Date   => '||userenv('sessionid'),7);
    --
    l_eff_date := trunc(p_effective_date);
    begin
      dt_fndate.set_effective_date(l_eff_date);
    exception
    when DUP_VAL_ON_INDEX then
      hr_utility.set_location('change for DUP_VAL_ON_INDEX : ' || l_proc ,999);
    when others then
      hr_utility.set_location('change for others : ' || l_proc ,998);
    end;
    --
    --
     hr_utility.set_location('Leaving: '|| l_proc,10);
  EXCEPTION
    WHEN others THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      rollback;
      raise;
END STORE_SESSION;
end pay_ppmv4_ss;

/
