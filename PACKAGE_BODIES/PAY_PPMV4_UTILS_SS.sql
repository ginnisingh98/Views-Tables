--------------------------------------------------------
--  DDL for Package Body PAY_PPMV4_UTILS_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPMV4_UTILS_SS" as
/* $Header: pyppmv4u.pkb 120.0.12010000.7 2010/03/29 09:39:58 pgongada ship $ */
---------------------------------------------------------------------------
---------------------------------- CONSTANTS ------------------------------
---------------------------------------------------------------------------
g_package constant varchar(2000) default 'pay_ppmv4_utils_ss.';
---------------------------------------------------------------------------
----------------------- FUNCTIONS AND PROCEDURES --------------------------
---------------------------------------------------------------------------
-------------------------------< seterror >--------------------------------
procedure seterrorstage
(p_proc in varchar2, p_stage in varchar2, p_location in number) is
begin
  hr_utility.set_location(p_proc || ':' || p_stage, p_location);
end seterrorstage;
-----------------------------< add_tx_row >-------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Adds a row of a given type to the PLSQL representation of the
--   transaction table.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   A new table entry is created.
--
-- Post Failure:
--   Not applicable.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure add_tx_row
(p_parameter_name  in            varchar2
,p_parameter_value in            long
,p_data_type       in            varchar2 default 'VARCHAR2'
,p_proc            in            varchar2
,p_table           in out nocopy hr_transaction_ss.transaction_table
) is
i      binary_integer;
begin
  seterrorstage(p_proc, p_parameter_name, 5);
  i := p_table.count + 1;
  p_table(i).param_name := p_parameter_name;
  p_table(i).param_value := p_parameter_value;
  p_table(i).param_data_type := p_data_type;
exception
  when others then
    raise;
end add_tx_row;
------------------------------< ppm2hrtt >---------------------------------
procedure ppm2hrtt
(p_item_type             in varchar2
,p_item_key              in varchar2
,p_activity_id           in number
,p_login_person_id       in number
,p_review_proc_call      in varchar2
,p_transaction_step_id   in number -- From PAY_PSS_TRANSACTION_STEPS.
,p_force_new_transaction in boolean
) is
l_tx_table         hr_transaction_ss.transaction_table;
l_transaction_id   number;
l_api_display_name varchar2(2000);
l_api_name         varchar2(2000);
l_result           varchar2(2000);
l_wf_txstep_id     number;
l_ovn              number;
l_proc             varchar2(2000) := g_package || 'ppm2wftt';
begin
  seterrorstage(l_proc, 'ENTER', 0);
  --
  -- Build the transaction row.
  --
  add_tx_row
  (p_parameter_name  => C_TX_STEP_ID_ARG
  ,p_parameter_value => to_char(p_transaction_step_id)
  ,p_data_type       => 'NUMBER'
  ,p_proc            => l_proc
  ,p_table           => l_tx_table
  );
  add_tx_row
  (p_parameter_name  => C_REVIEW_PROC_CALL_ARG
  ,p_parameter_value => p_review_proc_call
  ,p_proc            => l_proc
  ,p_table           => l_tx_table
  );
  add_tx_row
  (p_parameter_name  => C_REVIEW_ACTID_ARG
  ,p_parameter_value => to_char(p_activity_id)
  ,p_proc            => l_proc
  ,p_table           => l_tx_table
  );
  add_tx_row
  (p_parameter_name  => C_PROCESSED_FLAG_ARG
  ,p_parameter_value => 'N'
  ,p_proc            => l_proc
  ,p_table           => l_tx_table
  );
  --
  -- Write to HR transaction table.
  --
  l_api_name := C_PSS_API;
  l_api_display_name := 'PAYROLL PAYMENTS SELF-SERVICE V4';
  if p_force_new_transaction then
    seterrorstage(l_proc, 'START_TRANSACTION_ID', 10);
    hr_transaction_ss.start_transaction
    (itemtype          => p_item_type
    ,itemkey           => p_item_key
    ,actid             => p_activity_id
    ,funmode           => 'RUN'
    ,p_login_person_id => p_login_person_id
    ,result            => l_result
    );
    seterrorstage(l_proc, 'GET_TRANSACTION_ID:2', 20);
    l_transaction_id := hr_transaction_ss.get_transaction_id
    (p_item_type => p_item_type
    ,p_item_key  => p_item_key
    );
  else
    seterrorstage(l_proc, 'GET_TRANSACTION_ID:1', 30);
    l_transaction_id := hr_transaction_ss.get_transaction_id
    (p_item_type => p_item_type
    ,p_item_key  => p_item_key
    );
  end if;
  seterrorstage(l_proc, 'CREATE_TRANSACTION_STEP', 35);
  hr_transaction_api.create_transaction_step
  (p_validate              => false
  ,p_creator_person_id     => p_login_person_id
  ,p_transaction_id        => l_transaction_id
  ,p_api_name              => l_api_name
  ,p_api_display_name      => l_api_display_name
  ,p_item_type             => p_item_type
  ,p_item_key              => p_item_key
  ,p_activity_id           => p_activity_id
  ,p_transaction_step_id   => l_wf_txstep_id
  ,p_object_version_number => l_ovn
  );
  seterrorstage(l_proc, 'SAVE_TRANSACTION_STEP', 40);
  hr_transaction_ss.save_transaction_step
  (p_item_type           => p_item_type
  ,p_item_key            => p_item_key
  ,p_actid               => p_activity_id
  ,p_login_person_id     => p_login_person_id
  ,p_transaction_step_id => l_wf_txstep_id
  ,p_api_name            => l_api_name
  ,p_api_display_name    => l_api_display_name
  ,p_transaction_data    => l_tx_table
  );
  return;
exception
  when others then
    seterrorstage(l_proc, 'EXIT:FAIL', 50);
    raise;
end ppm2hrtt;
--------------------------------< ppm2tt >---------------------------------
procedure ppm2tt
(p_ppm in out nocopy t_ppmv4
) is
l_proc varchar2(2000) := g_package || 'ppm2tt';
begin
  seterrorstage(l_proc, 'ENTER', 0);
  if p_ppm.transaction_step_id is null then
    pay_pss_tx_steps_pkg.insert_row
    (p_transaction_id             => p_ppm.transaction_id
    ,p_transaction_step_id        => p_ppm.transaction_step_id
    ,p_source_table               => p_ppm.source_table
    ,p_state                      => p_ppm.state
    ,p_personal_payment_method_id => p_ppm.personal_payment_method_id
    ,p_update_ovn                 => p_ppm.update_ovn
    ,p_delete_ovn                 => p_ppm.delete_ovn
    ,p_update_datetrack_mode      => p_ppm.update_datetrack_mode
    ,p_delete_datetrack_mode      => p_ppm.delete_datetrack_mode
    ,p_delete_disabled            => p_ppm.delete_disabled
    ,p_effective_date             => p_ppm.effective_date
    ,p_org_payment_method_id      => p_ppm.org_payment_method_id
    ,p_assignment_id              => p_ppm.assignment_id
    ,p_payment_type               => p_ppm.payment_type
    ,p_currency_code              => p_ppm.currency_code
    ,p_territory_code             => p_ppm.territory_code
    ,p_run_type_id                => p_ppm.run_type_id
    ,p_real_priority              => p_ppm.real_priority
    ,p_logical_priority           => p_ppm.logical_priority
    ,p_amount_type                => p_ppm.amount_type
    ,p_amount                     => p_ppm.amount
    ,p_external_account_id        => p_ppm.external_account_id
    ,p_attribute_category         => p_ppm.attribute_category
    ,p_attribute1                 => p_ppm.attribute1
    ,p_attribute2                 => p_ppm.attribute2
    ,p_attribute3                 => p_ppm.attribute3
    ,p_attribute4                 => p_ppm.attribute4
    ,p_attribute5                 => p_ppm.attribute5
    ,p_attribute6                 => p_ppm.attribute6
    ,p_attribute7                 => p_ppm.attribute7
    ,p_attribute8                 => p_ppm.attribute8
    ,p_attribute9                 => p_ppm.attribute9
    ,p_attribute10                => p_ppm.attribute10
    ,p_attribute11                => p_ppm.attribute11
    ,p_attribute12                => p_ppm.attribute12
    ,p_attribute13                => p_ppm.attribute13
    ,p_attribute14                => p_ppm.attribute14
    ,p_attribute15                => p_ppm.attribute15
    ,p_attribute16                => p_ppm.attribute16
    ,p_attribute17                => p_ppm.attribute17
    ,p_attribute18                => p_ppm.attribute18
    ,p_attribute19                => p_ppm.attribute19
    ,p_attribute20                => p_ppm.attribute20
    ,p_o_real_priority            => p_ppm.o_real_priority
    ,p_o_logical_priority         => p_ppm.o_logical_priority
    ,p_o_amount_type              => p_ppm.o_amount_type
    ,p_o_amount                   => p_ppm.o_amount
    ,p_o_external_account_id      => p_ppm.o_external_account_id
    ,p_o_attribute_category       => p_ppm.o_attribute_category
    ,p_o_attribute1               => p_ppm.o_attribute1
    ,p_o_attribute2               => p_ppm.o_attribute2
    ,p_o_attribute3               => p_ppm.o_attribute3
    ,p_o_attribute4               => p_ppm.o_attribute4
    ,p_o_attribute5               => p_ppm.o_attribute5
    ,p_o_attribute6               => p_ppm.o_attribute6
    ,p_o_attribute7               => p_ppm.o_attribute7
    ,p_o_attribute8               => p_ppm.o_attribute8
    ,p_o_attribute9               => p_ppm.o_attribute9
    ,p_o_attribute10              => p_ppm.o_attribute10
    ,p_o_attribute11              => p_ppm.o_attribute11
    ,p_o_attribute12              => p_ppm.o_attribute12
    ,p_o_attribute13              => p_ppm.o_attribute13
    ,p_o_attribute14              => p_ppm.o_attribute14
    ,p_o_attribute15              => p_ppm.o_attribute15
    ,p_o_attribute16              => p_ppm.o_attribute16
    ,p_o_attribute17              => p_ppm.o_attribute17
    ,p_o_attribute18              => p_ppm.o_attribute18
    ,p_o_attribute19              => p_ppm.o_attribute19
    ,p_o_attribute20              => p_ppm.o_attribute20
    ,p_ppm_information_category   => p_ppm.ppm_information_category
    ,p_ppm_information1           => p_ppm.ppm_information1
    ,p_ppm_information2           => p_ppm.ppm_information2
    ,p_ppm_information3           => p_ppm.ppm_information3
    ,p_ppm_information4           => p_ppm.ppm_information4
    ,p_ppm_information5           => p_ppm.ppm_information5
    ,p_ppm_information6           => p_ppm.ppm_information6
    ,p_ppm_information7           => p_ppm.ppm_information7
    ,p_ppm_information8           => p_ppm.ppm_information8
    ,p_ppm_information9           => p_ppm.ppm_information9
    ,p_ppm_information10          => p_ppm.ppm_information10
    ,p_ppm_information11          => p_ppm.ppm_information11
    ,p_ppm_information12          => p_ppm.ppm_information12
    ,p_ppm_information13          => p_ppm.ppm_information13
    ,p_ppm_information14          => p_ppm.ppm_information14
    ,p_ppm_information15          => p_ppm.ppm_information15
    ,p_ppm_information16          => p_ppm.ppm_information16
    ,p_ppm_information17          => p_ppm.ppm_information17
    ,p_ppm_information18          => p_ppm.ppm_information18
    ,p_ppm_information19          => p_ppm.ppm_information19
    ,p_ppm_information20          => p_ppm.ppm_information20
    ,p_ppm_information21          => p_ppm.ppm_information21
    ,p_ppm_information22          => p_ppm.ppm_information22
    ,p_ppm_information23          => p_ppm.ppm_information23
    ,p_ppm_information24          => p_ppm.ppm_information24
    ,p_ppm_information25          => p_ppm.ppm_information25
    ,p_ppm_information26          => p_ppm.ppm_information26
    ,p_ppm_information27          => p_ppm.ppm_information27
    ,p_ppm_information28          => p_ppm.ppm_information28
    ,p_ppm_information29          => p_ppm.ppm_information29
    ,p_ppm_information30          => p_ppm.ppm_information30
    ,p_o_ppm_information_category => p_ppm.o_ppm_information_category
    ,p_o_ppm_information1         => p_ppm.o_ppm_information1
    ,p_o_ppm_information2         => p_ppm.o_ppm_information2
    ,p_o_ppm_information3         => p_ppm.o_ppm_information3
    ,p_o_ppm_information4         => p_ppm.o_ppm_information4
    ,p_o_ppm_information5         => p_ppm.o_ppm_information5
    ,p_o_ppm_information6         => p_ppm.o_ppm_information6
    ,p_o_ppm_information7         => p_ppm.o_ppm_information7
    ,p_o_ppm_information8         => p_ppm.o_ppm_information8
    ,p_o_ppm_information9         => p_ppm.o_ppm_information9
    ,p_o_ppm_information10        => p_ppm.o_ppm_information10
    ,p_o_ppm_information11        => p_ppm.o_ppm_information11
    ,p_o_ppm_information12        => p_ppm.o_ppm_information12
    ,p_o_ppm_information13        => p_ppm.o_ppm_information13
    ,p_o_ppm_information14        => p_ppm.o_ppm_information14
    ,p_o_ppm_information15        => p_ppm.o_ppm_information15
    ,p_o_ppm_information16        => p_ppm.o_ppm_information16
    ,p_o_ppm_information17        => p_ppm.o_ppm_information17
    ,p_o_ppm_information18        => p_ppm.o_ppm_information18
    ,p_o_ppm_information19        => p_ppm.o_ppm_information19
    ,p_o_ppm_information20        => p_ppm.o_ppm_information20
    ,p_o_ppm_information21        => p_ppm.o_ppm_information21
    ,p_o_ppm_information22        => p_ppm.o_ppm_information22
    ,p_o_ppm_information23        => p_ppm.o_ppm_information23
    ,p_o_ppm_information24        => p_ppm.o_ppm_information24
    ,p_o_ppm_information25        => p_ppm.o_ppm_information25
    ,p_o_ppm_information26        => p_ppm.o_ppm_information26
    ,p_o_ppm_information27        => p_ppm.o_ppm_information27
    ,p_o_ppm_information28        => p_ppm.o_ppm_information28
    ,p_o_ppm_information29        => p_ppm.o_ppm_information29
    ,p_o_ppm_information30        => p_ppm.o_ppm_information30
    );
  else
    pay_pss_tx_steps_pkg.update_row
    (p_transaction_step_id        => p_ppm.transaction_step_id
    ,p_source_table               => p_ppm.source_table
    ,p_state                      => p_ppm.state
    ,p_personal_payment_method_id => p_ppm.personal_payment_method_id
    ,p_update_ovn                 => p_ppm.update_ovn
    ,p_delete_ovn                 => p_ppm.delete_ovn
    ,p_update_datetrack_mode      => p_ppm.update_datetrack_mode
    ,p_delete_datetrack_mode      => p_ppm.delete_datetrack_mode
    ,p_delete_disabled            => p_ppm.delete_disabled
    ,p_effective_date             => p_ppm.effective_date
    ,p_org_payment_method_id      => p_ppm.org_payment_method_id
    ,p_assignment_id              => p_ppm.assignment_id
    ,p_payment_type               => p_ppm.payment_type
    ,p_currency_code              => p_ppm.currency_code
    ,p_territory_code             => p_ppm.territory_code
    ,p_run_type_id	          => p_ppm.run_type_id
    ,p_real_priority              => p_ppm.real_priority
    ,p_logical_priority           => p_ppm.logical_priority
    ,p_amount_type                => p_ppm.amount_type
    ,p_amount                     => p_ppm.amount
    ,p_external_account_id        => p_ppm.external_account_id
    ,p_attribute_category         => p_ppm.attribute_category
    ,p_attribute1                 => p_ppm.attribute1
    ,p_attribute2                 => p_ppm.attribute2
    ,p_attribute3                 => p_ppm.attribute3
    ,p_attribute4                 => p_ppm.attribute4
    ,p_attribute5                 => p_ppm.attribute5
    ,p_attribute6                 => p_ppm.attribute6
    ,p_attribute7                 => p_ppm.attribute7
    ,p_attribute8                 => p_ppm.attribute8
    ,p_attribute9                 => p_ppm.attribute9
    ,p_attribute10                => p_ppm.attribute10
    ,p_attribute11                => p_ppm.attribute11
    ,p_attribute12                => p_ppm.attribute12
    ,p_attribute13                => p_ppm.attribute13
    ,p_attribute14                => p_ppm.attribute14
    ,p_attribute15                => p_ppm.attribute15
    ,p_attribute16                => p_ppm.attribute16
    ,p_attribute17                => p_ppm.attribute17
    ,p_attribute18                => p_ppm.attribute18
    ,p_attribute19                => p_ppm.attribute19
    ,p_attribute20                => p_ppm.attribute20
    ,p_o_real_priority            => p_ppm.o_real_priority
    ,p_o_logical_priority         => p_ppm.o_logical_priority
    ,p_o_amount_type              => p_ppm.o_amount_type
    ,p_o_amount                   => p_ppm.o_amount
    ,p_o_external_account_id      => p_ppm.o_external_account_id
    ,p_o_attribute_category       => p_ppm.o_attribute_category
    ,p_o_attribute1               => p_ppm.o_attribute1
    ,p_o_attribute2               => p_ppm.o_attribute2
    ,p_o_attribute3               => p_ppm.o_attribute3
    ,p_o_attribute4               => p_ppm.o_attribute4
    ,p_o_attribute5               => p_ppm.o_attribute5
    ,p_o_attribute6               => p_ppm.o_attribute6
    ,p_o_attribute7               => p_ppm.o_attribute7
    ,p_o_attribute8               => p_ppm.o_attribute8
    ,p_o_attribute9               => p_ppm.o_attribute9
    ,p_o_attribute10              => p_ppm.o_attribute10
    ,p_o_attribute11              => p_ppm.o_attribute11
    ,p_o_attribute12              => p_ppm.o_attribute12
    ,p_o_attribute13              => p_ppm.o_attribute13
    ,p_o_attribute14              => p_ppm.o_attribute14
    ,p_o_attribute15              => p_ppm.o_attribute15
    ,p_o_attribute16              => p_ppm.o_attribute16
    ,p_o_attribute17              => p_ppm.o_attribute17
    ,p_o_attribute18              => p_ppm.o_attribute18
    ,p_o_attribute19              => p_ppm.o_attribute19
    ,p_o_attribute20              => p_ppm.o_attribute20
    ,p_ppm_information_category   => p_ppm.ppm_information_category
    ,p_ppm_information1           => p_ppm.ppm_information1
    ,p_ppm_information2           => p_ppm.ppm_information2
    ,p_ppm_information3           => p_ppm.ppm_information3
    ,p_ppm_information4           => p_ppm.ppm_information4
    ,p_ppm_information5           => p_ppm.ppm_information5
    ,p_ppm_information6           => p_ppm.ppm_information6
    ,p_ppm_information7           => p_ppm.ppm_information7
    ,p_ppm_information8           => p_ppm.ppm_information8
    ,p_ppm_information9           => p_ppm.ppm_information9
    ,p_ppm_information10          => p_ppm.ppm_information10
    ,p_ppm_information11          => p_ppm.ppm_information11
    ,p_ppm_information12          => p_ppm.ppm_information12
    ,p_ppm_information13          => p_ppm.ppm_information13
    ,p_ppm_information14          => p_ppm.ppm_information14
    ,p_ppm_information15          => p_ppm.ppm_information15
    ,p_ppm_information16          => p_ppm.ppm_information16
    ,p_ppm_information17          => p_ppm.ppm_information17
    ,p_ppm_information18          => p_ppm.ppm_information18
    ,p_ppm_information19          => p_ppm.ppm_information19
    ,p_ppm_information20          => p_ppm.ppm_information20
    ,p_ppm_information21          => p_ppm.ppm_information21
    ,p_ppm_information22          => p_ppm.ppm_information22
    ,p_ppm_information23          => p_ppm.ppm_information23
    ,p_ppm_information24          => p_ppm.ppm_information24
    ,p_ppm_information25          => p_ppm.ppm_information25
    ,p_ppm_information26          => p_ppm.ppm_information26
    ,p_ppm_information27          => p_ppm.ppm_information27
    ,p_ppm_information28          => p_ppm.ppm_information28
    ,p_ppm_information29          => p_ppm.ppm_information29
    ,p_ppm_information30          => p_ppm.ppm_information30
    ,p_o_ppm_information_category => p_ppm.o_ppm_information_category
    ,p_o_ppm_information1         => p_ppm.o_ppm_information1
    ,p_o_ppm_information2         => p_ppm.o_ppm_information2
    ,p_o_ppm_information3         => p_ppm.o_ppm_information3
    ,p_o_ppm_information4         => p_ppm.o_ppm_information4
    ,p_o_ppm_information5         => p_ppm.o_ppm_information5
    ,p_o_ppm_information6         => p_ppm.o_ppm_information6
    ,p_o_ppm_information7         => p_ppm.o_ppm_information7
    ,p_o_ppm_information8         => p_ppm.o_ppm_information8
    ,p_o_ppm_information9         => p_ppm.o_ppm_information9
    ,p_o_ppm_information10        => p_ppm.o_ppm_information10
    ,p_o_ppm_information11        => p_ppm.o_ppm_information11
    ,p_o_ppm_information12        => p_ppm.o_ppm_information12
    ,p_o_ppm_information13        => p_ppm.o_ppm_information13
    ,p_o_ppm_information14        => p_ppm.o_ppm_information14
    ,p_o_ppm_information15        => p_ppm.o_ppm_information15
    ,p_o_ppm_information16        => p_ppm.o_ppm_information16
    ,p_o_ppm_information17        => p_ppm.o_ppm_information17
    ,p_o_ppm_information18        => p_ppm.o_ppm_information18
    ,p_o_ppm_information19        => p_ppm.o_ppm_information19
    ,p_o_ppm_information20        => p_ppm.o_ppm_information20
    ,p_o_ppm_information21        => p_ppm.o_ppm_information21
    ,p_o_ppm_information22        => p_ppm.o_ppm_information22
    ,p_o_ppm_information23        => p_ppm.o_ppm_information23
    ,p_o_ppm_information24        => p_ppm.o_ppm_information24
    ,p_o_ppm_information25        => p_ppm.o_ppm_information25
    ,p_o_ppm_information26        => p_ppm.o_ppm_information26
    ,p_o_ppm_information27        => p_ppm.o_ppm_information27
    ,p_o_ppm_information28        => p_ppm.o_ppm_information28
    ,p_o_ppm_information29        => p_ppm.o_ppm_information29
    ,p_o_ppm_information30        => p_ppm.o_ppm_information30
    );
  end if;
  seterrorstage(l_proc, 'EXIT:SUCCESS', 10);
  return;
exception
  when others then
    seterrorstage(l_proc, 'EXIT:FAIL', 20);
    raise;
end ppm2tt;
--------------------------------< tt2ppm >---------------------------------
procedure tt2ppm
(p_transaction_step_id in     number
,p_ppm                    out nocopy t_ppmv4
) is
cursor csr_ppm
(p_transaction_step_id in number
) is
select p.transaction_id
      ,p.transaction_step_id
      ,p.source_table
      ,p.state
      ,p.personal_payment_method_id
      ,p.update_ovn
      ,p.delete_ovn
      ,p.update_datetrack_mode
      ,p.delete_datetrack_mode
      ,p.delete_disabled
      ,p.effective_date
      ,p.org_payment_method_id
      ,p.assignment_id
      ,p.payment_type
      ,p.currency_code
      ,p.territory_code
      ,p.real_priority
      ,p.logical_priority
      ,p.amount_type
      ,p.amount
      ,p.external_account_id
      ,p.attribute_category
      ,p.attribute1
      ,p.attribute2
      ,p.attribute3
      ,p.attribute4
      ,p.attribute5
      ,p.attribute6
      ,p.attribute7
      ,p.attribute8
      ,p.attribute9
      ,p.attribute10
      ,p.attribute11
      ,p.attribute12
      ,p.attribute13
      ,p.attribute14
      ,p.attribute15
      ,p.attribute16
      ,p.attribute17
      ,p.attribute18
      ,p.attribute19
      ,p.attribute20
      ,p.o_real_priority
      ,p.o_logical_priority
      ,p.o_amount_type
      ,p.o_amount
      ,p.o_external_account_id
      ,p.o_attribute_category
      ,p.o_attribute1
      ,p.o_attribute2
      ,p.o_attribute3
      ,p.o_attribute4
      ,p.o_attribute5
      ,p.o_attribute6
      ,p.o_attribute7
      ,p.o_attribute8
      ,p.o_attribute9
      ,p.o_attribute10
      ,p.o_attribute11
      ,p.o_attribute12
      ,p.o_attribute13
      ,p.o_attribute14
      ,p.o_attribute15
      ,p.o_attribute16
      ,p.o_attribute17
      ,p.o_attribute18
      ,p.o_attribute19
      ,p.o_attribute20
      ,p.run_type_id
      ,p.ppm_information_category
      ,p.ppm_information1
      ,p.ppm_information2
      ,p.ppm_information3
      ,p.ppm_information4
      ,p.ppm_information5
      ,p.ppm_information6
      ,p.ppm_information7
      ,p.ppm_information8
      ,p.ppm_information9
      ,p.ppm_information10
      ,p.ppm_information11
      ,p.ppm_information12
      ,p.ppm_information13
      ,p.ppm_information14
      ,p.ppm_information15
      ,p.ppm_information16
      ,p.ppm_information17
      ,p.ppm_information18
      ,p.ppm_information19
      ,p.ppm_information20
      ,p.ppm_information21
      ,p.ppm_information22
      ,p.ppm_information23
      ,p.ppm_information24
      ,p.ppm_information25
      ,p.ppm_information26
      ,p.ppm_information27
      ,p.ppm_information28
      ,p.ppm_information29
      ,p.ppm_information30
      ,p.o_ppm_information_category
      ,p.o_ppm_information1
      ,p.o_ppm_information2
      ,p.o_ppm_information3
      ,p.o_ppm_information4
      ,p.o_ppm_information5
      ,p.o_ppm_information6
      ,p.o_ppm_information7
      ,p.o_ppm_information8
      ,p.o_ppm_information9
      ,p.o_ppm_information10
      ,p.o_ppm_information11
      ,p.o_ppm_information12
      ,p.o_ppm_information13
      ,p.o_ppm_information14
      ,p.o_ppm_information15
      ,p.o_ppm_information16
      ,p.o_ppm_information17
      ,p.o_ppm_information18
      ,p.o_ppm_information19
      ,p.o_ppm_information20
      ,p.o_ppm_information21
      ,p.o_ppm_information22
      ,p.o_ppm_information23
      ,p.o_ppm_information24
      ,p.o_ppm_information25
      ,p.o_ppm_information26
      ,p.o_ppm_information27
      ,p.o_ppm_information28
      ,p.o_ppm_information29
      ,p.o_ppm_information30
from   pay_pss_transaction_steps p
where  p.transaction_step_id = p_transaction_step_id;

l_proc varchar2(2000) := g_package || 'tt2ppm';
begin
  seterrorstage(l_proc, 'ENTER', 0);
  --
  open csr_ppm
  (p_transaction_step_id => p_transaction_step_id
  );
  fetch csr_ppm
  into p_ppm.transaction_id
  ,    p_ppm.transaction_step_id
  ,    p_ppm.source_table
  ,    p_ppm.state
  ,    p_ppm.personal_payment_method_id
  ,    p_ppm.update_ovn
  ,    p_ppm.delete_ovn
  ,    p_ppm.update_datetrack_mode
  ,    p_ppm.delete_datetrack_mode
  ,    p_ppm.delete_disabled
  ,    p_ppm.effective_date
  ,    p_ppm.org_payment_method_id
  ,    p_ppm.assignment_id
  ,    p_ppm.payment_type
  ,    p_ppm.currency_code
  ,    p_ppm.territory_code
  ,    p_ppm.real_priority
  ,    p_ppm.logical_priority
  ,    p_ppm.amount_type
  ,    p_ppm.amount
  ,    p_ppm.external_account_id
  ,    p_ppm.attribute_category
  ,    p_ppm.attribute1
  ,    p_ppm.attribute2
  ,    p_ppm.attribute3
  ,    p_ppm.attribute4
  ,    p_ppm.attribute5
  ,    p_ppm.attribute6
  ,    p_ppm.attribute7
  ,    p_ppm.attribute8
  ,    p_ppm.attribute9
  ,    p_ppm.attribute10
  ,    p_ppm.attribute11
  ,    p_ppm.attribute12
  ,    p_ppm.attribute13
  ,    p_ppm.attribute14
  ,    p_ppm.attribute15
  ,    p_ppm.attribute16
  ,    p_ppm.attribute17
  ,    p_ppm.attribute18
  ,    p_ppm.attribute19
  ,    p_ppm.attribute20
  ,    p_ppm.o_real_priority
  ,    p_ppm.o_logical_priority
  ,    p_ppm.o_amount_type
  ,    p_ppm.o_amount
  ,    p_ppm.o_external_account_id
  ,    p_ppm.o_attribute_category
  ,    p_ppm.o_attribute1
  ,    p_ppm.o_attribute2
  ,    p_ppm.o_attribute3
  ,    p_ppm.o_attribute4
  ,    p_ppm.o_attribute5
  ,    p_ppm.o_attribute6
  ,    p_ppm.o_attribute7
  ,    p_ppm.o_attribute8
  ,    p_ppm.o_attribute9
  ,    p_ppm.o_attribute10
  ,    p_ppm.o_attribute11
  ,    p_ppm.o_attribute12
  ,    p_ppm.o_attribute13
  ,    p_ppm.o_attribute14
  ,    p_ppm.o_attribute15
  ,    p_ppm.o_attribute16
  ,    p_ppm.o_attribute17
  ,    p_ppm.o_attribute18
  ,    p_ppm.o_attribute19
  ,    p_ppm.o_attribute20
  ,    p_ppm.run_type_id
  ,    p_ppm.ppm_information_category
  ,    p_ppm.ppm_information1
  ,    p_ppm.ppm_information2
  ,    p_ppm.ppm_information3
  ,    p_ppm.ppm_information4
  ,    p_ppm.ppm_information5
  ,    p_ppm.ppm_information6
  ,    p_ppm.ppm_information7
  ,    p_ppm.ppm_information8
  ,    p_ppm.ppm_information9
  ,    p_ppm.ppm_information10
  ,    p_ppm.ppm_information11
  ,    p_ppm.ppm_information12
  ,    p_ppm.ppm_information13
  ,    p_ppm.ppm_information14
  ,    p_ppm.ppm_information15
  ,    p_ppm.ppm_information16
  ,    p_ppm.ppm_information17
  ,    p_ppm.ppm_information18
  ,    p_ppm.ppm_information19
  ,    p_ppm.ppm_information20
  ,    p_ppm.ppm_information21
  ,    p_ppm.ppm_information22
  ,    p_ppm.ppm_information23
  ,    p_ppm.ppm_information24
  ,    p_ppm.ppm_information25
  ,    p_ppm.ppm_information26
  ,    p_ppm.ppm_information27
  ,    p_ppm.ppm_information28
  ,    p_ppm.ppm_information29
  ,    p_ppm.ppm_information30
  ,    p_ppm.o_ppm_information_category
  ,    p_ppm.o_ppm_information1
  ,    p_ppm.o_ppm_information2
  ,    p_ppm.o_ppm_information3
  ,    p_ppm.o_ppm_information4
  ,    p_ppm.o_ppm_information5
  ,    p_ppm.o_ppm_information6
  ,    p_ppm.o_ppm_information7
  ,    p_ppm.o_ppm_information8
  ,    p_ppm.o_ppm_information9
  ,    p_ppm.o_ppm_information10
  ,    p_ppm.o_ppm_information11
  ,    p_ppm.o_ppm_information12
  ,    p_ppm.o_ppm_information13
  ,    p_ppm.o_ppm_information14
  ,    p_ppm.o_ppm_information15
  ,    p_ppm.o_ppm_information16
  ,    p_ppm.o_ppm_information17
  ,    p_ppm.o_ppm_information18
  ,    p_ppm.o_ppm_information19
  ,    p_ppm.o_ppm_information20
  ,    p_ppm.o_ppm_information21
  ,    p_ppm.o_ppm_information22
  ,    p_ppm.o_ppm_information23
  ,    p_ppm.o_ppm_information24
  ,    p_ppm.o_ppm_information25
  ,    p_ppm.o_ppm_information26
  ,    p_ppm.o_ppm_information27
  ,    p_ppm.o_ppm_information28
  ,    p_ppm.o_ppm_information29
  ,    p_ppm.o_ppm_information30
  ;
  close csr_ppm;
  seterrorstage(l_proc, 'EXIT:SUCCESS', 20);
  return;
exception
  when others then
    seterrorstage(l_proc, 'EXIT:FAIL', 30);
    if csr_ppm%isopen then
      close csr_ppm;
    end if;
    raise;
end;
-----------------------------< changed >-------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Compares data used to check whether or not a PPM has changed.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   P_CHANGES is set to true if there are any differences.
--   P_BANK is set to true if the Bank Details differ.
--
-- Post Failure:
--   Not applicable.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure changed
(p_logical_priority      in     number
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
,p_o_logical_priority    in     number
,p_o_amount_type         in     varchar2
,p_o_amount              in     number
,p_o_external_account_id in     number
,p_o_attribute_category  in     varchar2
,p_o_attribute1          in     varchar2
,p_o_attribute2          in     varchar2
,p_o_attribute3          in     varchar2
,p_o_attribute4          in     varchar2
,p_o_attribute5          in     varchar2
,p_o_attribute6          in     varchar2
,p_o_attribute7          in     varchar2
,p_o_attribute8          in     varchar2
,p_o_attribute9          in     varchar2
,p_o_attribute10         in     varchar2
,p_o_attribute11         in     varchar2
,p_o_attribute12         in     varchar2
,p_o_attribute13         in     varchar2
,p_o_attribute14         in     varchar2
,p_o_attribute15         in     varchar2
,p_o_attribute16         in     varchar2
,p_o_attribute17         in     varchar2
,p_o_attribute18         in     varchar2
,p_o_attribute19         in     varchar2
,p_o_attribute20         in     varchar2
,p_ppm_information_category in  varchar2
,p_ppm_information1      in     varchar2
,p_ppm_information2      in     varchar2
,p_ppm_information3      in     varchar2
,p_ppm_information4      in     varchar2
,p_ppm_information5      in     varchar2
,p_ppm_information6      in     varchar2
,p_ppm_information7      in     varchar2
,p_ppm_information8      in     varchar2
,p_ppm_information9      in     varchar2
,p_ppm_information10     in     varchar2
,p_ppm_information11     in     varchar2
,p_ppm_information12     in     varchar2
,p_ppm_information13     in     varchar2
,p_ppm_information14     in     varchar2
,p_ppm_information15     in     varchar2
,p_ppm_information16     in     varchar2
,p_ppm_information17     in     varchar2
,p_ppm_information18     in     varchar2
,p_ppm_information19     in     varchar2
,p_ppm_information20     in     varchar2
,p_ppm_information21     in     varchar2
,p_ppm_information22     in     varchar2
,p_ppm_information23     in     varchar2
,p_ppm_information24     in     varchar2
,p_ppm_information25     in     varchar2
,p_ppm_information26     in     varchar2
,p_ppm_information27     in     varchar2
,p_ppm_information28     in     varchar2
,p_ppm_information29     in     varchar2
,p_ppm_information30     in     varchar2
,p_o_ppm_information_category in varchar2
,p_o_ppm_information1    in     varchar2
,p_o_ppm_information2    in     varchar2
,p_o_ppm_information3    in     varchar2
,p_o_ppm_information4    in     varchar2
,p_o_ppm_information5    in     varchar2
,p_o_ppm_information6    in     varchar2
,p_o_ppm_information7    in     varchar2
,p_o_ppm_information8    in     varchar2
,p_o_ppm_information9    in     varchar2
,p_o_ppm_information10   in     varchar2
,p_o_ppm_information11   in     varchar2
,p_o_ppm_information12   in     varchar2
,p_o_ppm_information13   in     varchar2
,p_o_ppm_information14   in     varchar2
,p_o_ppm_information15   in     varchar2
,p_o_ppm_information16   in     varchar2
,p_o_ppm_information17   in     varchar2
,p_o_ppm_information18   in     varchar2
,p_o_ppm_information19   in     varchar2
,p_o_ppm_information20   in     varchar2
,p_o_ppm_information21   in     varchar2
,p_o_ppm_information22   in     varchar2
,p_o_ppm_information23   in     varchar2
,p_o_ppm_information24   in     varchar2
,p_o_ppm_information25   in     varchar2
,p_o_ppm_information26   in     varchar2
,p_o_ppm_information27   in     varchar2
,p_o_ppm_information28   in     varchar2
,p_o_ppm_information29   in     varchar2
,p_o_ppm_information30   in     varchar2
,p_changes                  out nocopy boolean
,p_bank                     out nocopy boolean
) is
--
l_changes boolean := false;
l_bank    boolean := false;
--
-- Local procedures to detect a changed column.
--
procedure ch
(p_value1 in     number
,p_value2 in     number
,p_change in out nocopy boolean
) is
begin
  --
  -- The HR_API defaults are used to indicate no change.
  --
  if nvl(p_value1, hr_api.g_number) <> nvl(p_value2, hr_api.g_number) then
    p_change := true;
  end if;
end ch;
--
procedure ch
(p_value1 in     varchar2
,p_value2 in     varchar2
,p_change in out nocopy boolean
) is
begin
  --
  -- The HR_API defaults are used to indicate no change.
  --
  if nvl(p_value1, hr_api.g_varchar2) <> nvl(p_value2, hr_api.g_varchar2) then
    p_change := true;
  end if;
end ch;
--
begin
  ch(p_logical_priority, p_o_logical_priority, l_changes);
  ch(p_amount, p_o_amount, l_changes);
  ch(p_amount_type, p_o_amount_type, l_changes);
  ch(p_external_account_id, p_o_external_account_id, l_bank);
  ch(p_attribute_category, p_o_attribute_category, l_changes);
  ch(p_attribute1, p_o_attribute1, l_changes);
  ch(p_attribute2, p_o_attribute2, l_changes);
  ch(p_attribute3, p_o_attribute3, l_changes);
  ch(p_attribute4, p_o_attribute4, l_changes);
  ch(p_attribute5, p_o_attribute5, l_changes);
  ch(p_attribute6, p_o_attribute6, l_changes);
  ch(p_attribute7, p_o_attribute7, l_changes);
  ch(p_attribute8, p_o_attribute8, l_changes);
  ch(p_attribute9, p_o_attribute9, l_changes);
  ch(p_attribute10, p_o_attribute10, l_changes);
  ch(p_attribute11, p_o_attribute11, l_changes);
  ch(p_attribute12, p_o_attribute12, l_changes);
  ch(p_attribute13, p_o_attribute13, l_changes);
  ch(p_attribute14, p_o_attribute14, l_changes);
  ch(p_attribute15, p_o_attribute15, l_changes);
  ch(p_attribute16, p_o_attribute16, l_changes);
  ch(p_attribute17, p_o_attribute17, l_changes);
  ch(p_attribute18, p_o_attribute18, l_changes);
  ch(p_attribute19, p_o_attribute19, l_changes);
  ch(p_attribute20, p_o_attribute20, l_changes);

  ch(p_ppm_information_category, p_o_ppm_information_category, l_changes);
  ch(p_ppm_information1, p_o_ppm_information1, l_changes);
  ch(p_ppm_information2, p_o_ppm_information2, l_changes);
  ch(p_ppm_information3, p_o_ppm_information3, l_changes);
  ch(p_ppm_information4, p_o_ppm_information4, l_changes);
  ch(p_ppm_information5, p_o_ppm_information5, l_changes);
  ch(p_ppm_information6, p_o_ppm_information6, l_changes);
  ch(p_ppm_information7, p_o_ppm_information7, l_changes);
  ch(p_ppm_information8, p_o_ppm_information8, l_changes);
  ch(p_ppm_information9, p_o_ppm_information9, l_changes);
  ch(p_ppm_information10, p_o_ppm_information10, l_changes);
  ch(p_ppm_information11, p_o_ppm_information11, l_changes);
  ch(p_ppm_information12, p_o_ppm_information12, l_changes);
  ch(p_ppm_information13, p_o_ppm_information13, l_changes);
  ch(p_ppm_information14, p_o_ppm_information14, l_changes);
  ch(p_ppm_information15, p_o_ppm_information15, l_changes);
  ch(p_ppm_information16, p_o_ppm_information16, l_changes);
  ch(p_ppm_information17, p_o_ppm_information17, l_changes);
  ch(p_ppm_information18, p_o_ppm_information18, l_changes);
  ch(p_ppm_information19, p_o_ppm_information19, l_changes);
  ch(p_ppm_information20, p_o_ppm_information20, l_changes);
  ch(p_ppm_information22, p_o_ppm_information21, l_changes);
  ch(p_ppm_information22, p_o_ppm_information22, l_changes);
  ch(p_ppm_information23, p_o_ppm_information23, l_changes);
  ch(p_ppm_information24, p_o_ppm_information24, l_changes);
  ch(p_ppm_information25, p_o_ppm_information25, l_changes);
  ch(p_ppm_information26, p_o_ppm_information26, l_changes);
  ch(p_ppm_information27, p_o_ppm_information27, l_changes);
  ch(p_ppm_information28, p_o_ppm_information28, l_changes);
  ch(p_ppm_information29, p_o_ppm_information29, l_changes);
  ch(p_ppm_information30, p_o_ppm_information30, l_changes);
  --
  -- Set the return values.
  --
  if l_bank then
    l_changes := true;
  end if;
  p_bank    := l_bank;
  p_changes := l_changes;
end changed;
-----------------------------< changedppm >------------------------
procedure changedppm
(p_ppm           in     t_ppmv4
,p_changes          out nocopy boolean
,p_bank             out nocopy boolean
) is
begin
  --
  -- Call private routine.
  --
  changed
  (p_logical_priority      => p_ppm.logical_priority
  ,p_amount_type           => p_ppm.amount_type
  ,p_amount                => p_ppm.amount
  ,p_external_account_id   => p_ppm.external_account_id
  ,p_attribute_category    => p_ppm.attribute_category
  ,p_attribute1            => p_ppm.attribute1
  ,p_attribute2            => p_ppm.attribute2
  ,p_attribute3            => p_ppm.attribute3
  ,p_attribute4            => p_ppm.attribute4
  ,p_attribute5            => p_ppm.attribute5
  ,p_attribute6            => p_ppm.attribute6
  ,p_attribute7            => p_ppm.attribute7
  ,p_attribute8            => p_ppm.attribute8
  ,p_attribute9            => p_ppm.attribute9
  ,p_attribute10           => p_ppm.attribute10
  ,p_attribute11           => p_ppm.attribute11
  ,p_attribute12           => p_ppm.attribute12
  ,p_attribute13           => p_ppm.attribute13
  ,p_attribute14           => p_ppm.attribute14
  ,p_attribute15           => p_ppm.attribute15
  ,p_attribute16           => p_ppm.attribute16
  ,p_attribute17           => p_ppm.attribute17
  ,p_attribute18           => p_ppm.attribute18
  ,p_attribute19           => p_ppm.attribute19
  ,p_attribute20           => p_ppm.attribute20
  ,p_o_logical_priority    => p_ppm.o_logical_priority
  ,p_o_amount_type         => p_ppm.o_amount_type
  ,p_o_amount              => p_ppm.o_amount
  ,p_o_external_account_id => p_ppm.o_external_account_id
  ,p_o_attribute_category  => p_ppm.o_attribute_category
  ,p_o_attribute1          => p_ppm.o_attribute1
  ,p_o_attribute2          => p_ppm.o_attribute2
  ,p_o_attribute3          => p_ppm.o_attribute3
  ,p_o_attribute4          => p_ppm.o_attribute4
  ,p_o_attribute5          => p_ppm.o_attribute5
  ,p_o_attribute6          => p_ppm.o_attribute6
  ,p_o_attribute7          => p_ppm.o_attribute7
  ,p_o_attribute8          => p_ppm.o_attribute8
  ,p_o_attribute9          => p_ppm.o_attribute9
  ,p_o_attribute10         => p_ppm.o_attribute10
  ,p_o_attribute11         => p_ppm.o_attribute11
  ,p_o_attribute12         => p_ppm.o_attribute12
  ,p_o_attribute13         => p_ppm.o_attribute13
  ,p_o_attribute14         => p_ppm.o_attribute14
  ,p_o_attribute15         => p_ppm.o_attribute15
  ,p_o_attribute16         => p_ppm.o_attribute16
  ,p_o_attribute17         => p_ppm.o_attribute17
  ,p_o_attribute18         => p_ppm.o_attribute18
  ,p_o_attribute19         => p_ppm.o_attribute19
  ,p_o_attribute20         => p_ppm.o_attribute20
  ,p_ppm_information_category => p_ppm.ppm_information_category
  ,p_ppm_information1      => p_ppm.ppm_information1
  ,p_ppm_information2      => p_ppm.ppm_information2
  ,p_ppm_information3      => p_ppm.ppm_information3
  ,p_ppm_information4      => p_ppm.ppm_information4
  ,p_ppm_information5      => p_ppm.ppm_information5
  ,p_ppm_information6      => p_ppm.ppm_information6
  ,p_ppm_information7      => p_ppm.ppm_information7
  ,p_ppm_information8      => p_ppm.ppm_information8
  ,p_ppm_information9      => p_ppm.ppm_information9
  ,p_ppm_information10     => p_ppm.ppm_information10
  ,p_ppm_information11     => p_ppm.ppm_information11
  ,p_ppm_information12     => p_ppm.ppm_information12
  ,p_ppm_information13     => p_ppm.ppm_information13
  ,p_ppm_information14     => p_ppm.ppm_information14
  ,p_ppm_information15     => p_ppm.ppm_information15
  ,p_ppm_information16     => p_ppm.ppm_information16
  ,p_ppm_information17     => p_ppm.ppm_information17
  ,p_ppm_information18     => p_ppm.ppm_information18
  ,p_ppm_information19     => p_ppm.ppm_information19
  ,p_ppm_information20     => p_ppm.ppm_information20
  ,p_ppm_information21     => p_ppm.ppm_information21
  ,p_ppm_information22     => p_ppm.ppm_information22
  ,p_ppm_information23     => p_ppm.ppm_information23
  ,p_ppm_information24     => p_ppm.ppm_information24
  ,p_ppm_information25     => p_ppm.ppm_information25
  ,p_ppm_information26     => p_ppm.ppm_information26
  ,p_ppm_information27     => p_ppm.ppm_information27
  ,p_ppm_information28     => p_ppm.ppm_information28
  ,p_ppm_information29     => p_ppm.ppm_information29
  ,p_ppm_information30     => p_ppm.ppm_information30
  ,p_o_ppm_information_category => p_ppm.o_ppm_information_category
  ,p_o_ppm_information1    => p_ppm.o_ppm_information1
  ,p_o_ppm_information2    => p_ppm.o_ppm_information2
  ,p_o_ppm_information3    => p_ppm.o_ppm_information3
  ,p_o_ppm_information4    => p_ppm.o_ppm_information4
  ,p_o_ppm_information5    => p_ppm.o_ppm_information5
  ,p_o_ppm_information6    => p_ppm.o_ppm_information6
  ,p_o_ppm_information7    => p_ppm.o_ppm_information7
  ,p_o_ppm_information8    => p_ppm.o_ppm_information8
  ,p_o_ppm_information9    => p_ppm.o_ppm_information9
  ,p_o_ppm_information10   => p_ppm.o_ppm_information10
  ,p_o_ppm_information11   => p_ppm.o_ppm_information11
  ,p_o_ppm_information12   => p_ppm.o_ppm_information12
  ,p_o_ppm_information13   => p_ppm.o_ppm_information13
  ,p_o_ppm_information14   => p_ppm.o_ppm_information14
  ,p_o_ppm_information15   => p_ppm.o_ppm_information15
  ,p_o_ppm_information16   => p_ppm.o_ppm_information16
  ,p_o_ppm_information17   => p_ppm.o_ppm_information17
  ,p_o_ppm_information18   => p_ppm.o_ppm_information18
  ,p_o_ppm_information19   => p_ppm.o_ppm_information19
  ,p_o_ppm_information20   => p_ppm.o_ppm_information20
  ,p_o_ppm_information21   => p_ppm.o_ppm_information21
  ,p_o_ppm_information22   => p_ppm.o_ppm_information22
  ,p_o_ppm_information23   => p_ppm.o_ppm_information23
  ,p_o_ppm_information24   => p_ppm.o_ppm_information24
  ,p_o_ppm_information25   => p_ppm.o_ppm_information25
  ,p_o_ppm_information26   => p_ppm.o_ppm_information26
  ,p_o_ppm_information27   => p_ppm.o_ppm_information27
  ,p_o_ppm_information28   => p_ppm.o_ppm_information28
  ,p_o_ppm_information29   => p_ppm.o_ppm_information29
  ,p_o_ppm_information30   => p_ppm.o_ppm_information30
  ,p_changes               => p_changes
  ,p_bank                  => p_bank
  );
end changedppm;
-----------------------------< changedppm >------------------------
procedure changedppm
(p_new_ppm   in     t_ppmv4
,p_saved_ppm in     t_ppmv4
,p_original     out nocopy boolean
,p_current      out nocopy boolean
) is
l_bank boolean;
l_changes boolean;
begin
  --
  -- Call private routine.
  --
  changed
  (p_logical_priority      => hr_api.g_number
  ,p_amount_type           => p_new_ppm.amount_type
  ,p_amount                => p_new_ppm.amount
  ,p_external_account_id   => p_new_ppm.external_account_id
  ,p_attribute_category    => p_new_ppm.attribute_category
  ,p_attribute1            => p_new_ppm.attribute1
  ,p_attribute2            => p_new_ppm.attribute2
  ,p_attribute3            => p_new_ppm.attribute3
  ,p_attribute4            => p_new_ppm.attribute4
  ,p_attribute5            => p_new_ppm.attribute5
  ,p_attribute6            => p_new_ppm.attribute6
  ,p_attribute7            => p_new_ppm.attribute7
  ,p_attribute8            => p_new_ppm.attribute8
  ,p_attribute9            => p_new_ppm.attribute9
  ,p_attribute10           => p_new_ppm.attribute10
  ,p_attribute11           => p_new_ppm.attribute11
  ,p_attribute12           => p_new_ppm.attribute12
  ,p_attribute13           => p_new_ppm.attribute13
  ,p_attribute14           => p_new_ppm.attribute14
  ,p_attribute15           => p_new_ppm.attribute15
  ,p_attribute16           => p_new_ppm.attribute16
  ,p_attribute17           => p_new_ppm.attribute17
  ,p_attribute18           => p_new_ppm.attribute18
  ,p_attribute19           => p_new_ppm.attribute19
  ,p_attribute20           => p_new_ppm.attribute20
  ,p_o_logical_priority    => hr_api.g_number
  ,p_o_amount_type         => p_saved_ppm.o_amount_type
  ,p_o_amount              => p_saved_ppm.o_amount
  ,p_o_external_account_id => p_saved_ppm.o_external_account_id
  ,p_o_attribute_category  => p_saved_ppm.o_attribute_category
  ,p_o_attribute1          => p_saved_ppm.o_attribute1
  ,p_o_attribute2          => p_saved_ppm.o_attribute2
  ,p_o_attribute3          => p_saved_ppm.o_attribute3
  ,p_o_attribute4          => p_saved_ppm.o_attribute4
  ,p_o_attribute5          => p_saved_ppm.o_attribute5
  ,p_o_attribute6          => p_saved_ppm.o_attribute6
  ,p_o_attribute7          => p_saved_ppm.o_attribute7
  ,p_o_attribute8          => p_saved_ppm.o_attribute8
  ,p_o_attribute9          => p_saved_ppm.o_attribute9
  ,p_o_attribute10         => p_saved_ppm.o_attribute10
  ,p_o_attribute11         => p_saved_ppm.o_attribute11
  ,p_o_attribute12         => p_saved_ppm.o_attribute12
  ,p_o_attribute13         => p_saved_ppm.o_attribute13
  ,p_o_attribute14         => p_saved_ppm.o_attribute14
  ,p_o_attribute15         => p_saved_ppm.o_attribute15
  ,p_o_attribute16         => p_saved_ppm.o_attribute16
  ,p_o_attribute17         => p_saved_ppm.o_attribute17
  ,p_o_attribute18         => p_saved_ppm.o_attribute18
  ,p_o_attribute19         => p_saved_ppm.o_attribute19
  ,p_o_attribute20         => p_saved_ppm.o_attribute20
  ,p_ppm_information_category => p_new_ppm.ppm_information_category
  ,p_ppm_information1      => p_new_ppm.ppm_information1
  ,p_ppm_information2      => p_new_ppm.ppm_information2
  ,p_ppm_information3      => p_new_ppm.ppm_information3
  ,p_ppm_information4      => p_new_ppm.ppm_information4
  ,p_ppm_information5      => p_new_ppm.ppm_information5
  ,p_ppm_information6      => p_new_ppm.ppm_information6
  ,p_ppm_information7      => p_new_ppm.ppm_information7
  ,p_ppm_information8      => p_new_ppm.ppm_information8
  ,p_ppm_information9      => p_new_ppm.ppm_information9
  ,p_ppm_information10     => p_new_ppm.ppm_information10
  ,p_ppm_information11     => p_new_ppm.ppm_information11
  ,p_ppm_information12     => p_new_ppm.ppm_information12
  ,p_ppm_information13     => p_new_ppm.ppm_information13
  ,p_ppm_information14     => p_new_ppm.ppm_information14
  ,p_ppm_information15     => p_new_ppm.ppm_information15
  ,p_ppm_information16     => p_new_ppm.ppm_information16
  ,p_ppm_information17     => p_new_ppm.ppm_information17
  ,p_ppm_information18     => p_new_ppm.ppm_information18
  ,p_ppm_information19     => p_new_ppm.ppm_information19
  ,p_ppm_information20     => p_new_ppm.ppm_information20
  ,p_ppm_information21     => p_new_ppm.ppm_information21
  ,p_ppm_information22     => p_new_ppm.ppm_information22
  ,p_ppm_information23     => p_new_ppm.ppm_information23
  ,p_ppm_information24     => p_new_ppm.ppm_information24
  ,p_ppm_information25     => p_new_ppm.ppm_information25
  ,p_ppm_information26     => p_new_ppm.ppm_information26
  ,p_ppm_information27     => p_new_ppm.ppm_information27
  ,p_ppm_information28     => p_new_ppm.ppm_information28
  ,p_ppm_information29     => p_new_ppm.ppm_information29
  ,p_ppm_information30     => p_new_ppm.ppm_information30
  ,p_o_ppm_information_category => p_saved_ppm.o_ppm_information_category
  ,p_o_ppm_information1    => p_saved_ppm.o_ppm_information1
  ,p_o_ppm_information2    => p_saved_ppm.o_ppm_information2
  ,p_o_ppm_information3    => p_saved_ppm.o_ppm_information3
  ,p_o_ppm_information4    => p_saved_ppm.o_ppm_information4
  ,p_o_ppm_information5    => p_saved_ppm.o_ppm_information5
  ,p_o_ppm_information6    => p_saved_ppm.o_ppm_information6
  ,p_o_ppm_information7    => p_saved_ppm.o_ppm_information7
  ,p_o_ppm_information8    => p_saved_ppm.o_ppm_information8
  ,p_o_ppm_information9    => p_saved_ppm.o_ppm_information9
  ,p_o_ppm_information10   => p_saved_ppm.o_ppm_information10
  ,p_o_ppm_information11   => p_saved_ppm.o_ppm_information11
  ,p_o_ppm_information12   => p_saved_ppm.o_ppm_information12
  ,p_o_ppm_information13   => p_saved_ppm.o_ppm_information13
  ,p_o_ppm_information14   => p_saved_ppm.o_ppm_information14
  ,p_o_ppm_information15   => p_saved_ppm.o_ppm_information15
  ,p_o_ppm_information16   => p_saved_ppm.o_ppm_information16
  ,p_o_ppm_information17   => p_saved_ppm.o_ppm_information17
  ,p_o_ppm_information18   => p_saved_ppm.o_ppm_information18
  ,p_o_ppm_information19   => p_saved_ppm.o_ppm_information19
  ,p_o_ppm_information20   => p_saved_ppm.o_ppm_information20
  ,p_o_ppm_information21   => p_saved_ppm.o_ppm_information21
  ,p_o_ppm_information22   => p_saved_ppm.o_ppm_information22
  ,p_o_ppm_information23   => p_saved_ppm.o_ppm_information23
  ,p_o_ppm_information24   => p_saved_ppm.o_ppm_information24
  ,p_o_ppm_information25   => p_saved_ppm.o_ppm_information25
  ,p_o_ppm_information26   => p_saved_ppm.o_ppm_information26
  ,p_o_ppm_information27   => p_saved_ppm.o_ppm_information27
  ,p_o_ppm_information28   => p_saved_ppm.o_ppm_information28
  ,p_o_ppm_information29   => p_saved_ppm.o_ppm_information29
  ,p_o_ppm_information30   => p_saved_ppm.o_ppm_information30
  ,p_changes               => l_changes
  ,p_bank                  => l_bank
  );
  p_original := l_changes;
  --
  changed
  (p_logical_priority      => hr_api.g_number
  ,p_amount_type           => p_new_ppm.amount_type
  ,p_amount                => p_new_ppm.amount
  ,p_external_account_id   => p_new_ppm.external_account_id
  ,p_attribute_category    => p_new_ppm.attribute_category
  ,p_attribute1            => p_new_ppm.attribute1
  ,p_attribute2            => p_new_ppm.attribute2
  ,p_attribute3            => p_new_ppm.attribute3
  ,p_attribute4            => p_new_ppm.attribute4
  ,p_attribute5            => p_new_ppm.attribute5
  ,p_attribute6            => p_new_ppm.attribute6
  ,p_attribute7            => p_new_ppm.attribute7
  ,p_attribute8            => p_new_ppm.attribute8
  ,p_attribute9            => p_new_ppm.attribute9
  ,p_attribute10           => p_new_ppm.attribute10
  ,p_attribute11           => p_new_ppm.attribute11
  ,p_attribute12           => p_new_ppm.attribute12
  ,p_attribute13           => p_new_ppm.attribute13
  ,p_attribute14           => p_new_ppm.attribute14
  ,p_attribute15           => p_new_ppm.attribute15
  ,p_attribute16           => p_new_ppm.attribute16
  ,p_attribute17           => p_new_ppm.attribute17
  ,p_attribute18           => p_new_ppm.attribute18
  ,p_attribute19           => p_new_ppm.attribute19
  ,p_attribute20           => p_new_ppm.attribute20
  ,p_o_logical_priority    => hr_api.g_number
  ,p_o_amount_type         => p_saved_ppm.amount_type
  ,p_o_amount              => p_saved_ppm.amount
  ,p_o_external_account_id => p_saved_ppm.external_account_id
  ,p_o_attribute_category  => p_saved_ppm.attribute_category
  ,p_o_attribute1          => p_saved_ppm.attribute1
  ,p_o_attribute2          => p_saved_ppm.attribute2
  ,p_o_attribute3          => p_saved_ppm.attribute3
  ,p_o_attribute4          => p_saved_ppm.attribute4
  ,p_o_attribute5          => p_saved_ppm.attribute5
  ,p_o_attribute6          => p_saved_ppm.attribute6
  ,p_o_attribute7          => p_saved_ppm.attribute7
  ,p_o_attribute8          => p_saved_ppm.attribute8
  ,p_o_attribute9          => p_saved_ppm.attribute9
  ,p_o_attribute10         => p_saved_ppm.attribute10
  ,p_o_attribute11         => p_saved_ppm.attribute11
  ,p_o_attribute12         => p_saved_ppm.attribute12
  ,p_o_attribute13         => p_saved_ppm.attribute13
  ,p_o_attribute14         => p_saved_ppm.attribute14
  ,p_o_attribute15         => p_saved_ppm.attribute15
  ,p_o_attribute16         => p_saved_ppm.attribute16
  ,p_o_attribute17         => p_saved_ppm.attribute17
  ,p_o_attribute18         => p_saved_ppm.attribute18
  ,p_o_attribute19         => p_saved_ppm.attribute19
  ,p_o_attribute20         => p_saved_ppm.attribute20
  ,p_ppm_information_category => p_new_ppm.ppm_information_category
  ,p_ppm_information1      => p_new_ppm.ppm_information1
  ,p_ppm_information2      => p_new_ppm.ppm_information2
  ,p_ppm_information3      => p_new_ppm.ppm_information3
  ,p_ppm_information4      => p_new_ppm.ppm_information4
  ,p_ppm_information5      => p_new_ppm.ppm_information5
  ,p_ppm_information6      => p_new_ppm.ppm_information6
  ,p_ppm_information7      => p_new_ppm.ppm_information7
  ,p_ppm_information8      => p_new_ppm.ppm_information8
  ,p_ppm_information9      => p_new_ppm.ppm_information9
  ,p_ppm_information10     => p_new_ppm.ppm_information10
  ,p_ppm_information11     => p_new_ppm.ppm_information11
  ,p_ppm_information12     => p_new_ppm.ppm_information12
  ,p_ppm_information13     => p_new_ppm.ppm_information13
  ,p_ppm_information14     => p_new_ppm.ppm_information14
  ,p_ppm_information15     => p_new_ppm.ppm_information15
  ,p_ppm_information16     => p_new_ppm.ppm_information16
  ,p_ppm_information17     => p_new_ppm.ppm_information17
  ,p_ppm_information18     => p_new_ppm.ppm_information18
  ,p_ppm_information19     => p_new_ppm.ppm_information19
  ,p_ppm_information20     => p_new_ppm.ppm_information20
  ,p_ppm_information21     => p_new_ppm.ppm_information21
  ,p_ppm_information22     => p_new_ppm.ppm_information22
  ,p_ppm_information23     => p_new_ppm.ppm_information23
  ,p_ppm_information24     => p_new_ppm.ppm_information24
  ,p_ppm_information25     => p_new_ppm.ppm_information25
  ,p_ppm_information26     => p_new_ppm.ppm_information26
  ,p_ppm_information27     => p_new_ppm.ppm_information27
  ,p_ppm_information28     => p_new_ppm.ppm_information28
  ,p_ppm_information29     => p_new_ppm.ppm_information29
  ,p_ppm_information30     => p_new_ppm.ppm_information30
  ,p_o_ppm_information_category => p_saved_ppm.o_ppm_information_category
  ,p_o_ppm_information1    => p_saved_ppm.o_ppm_information1
  ,p_o_ppm_information2    => p_saved_ppm.o_ppm_information2
  ,p_o_ppm_information3    => p_saved_ppm.o_ppm_information3
  ,p_o_ppm_information4    => p_saved_ppm.o_ppm_information4
  ,p_o_ppm_information5    => p_saved_ppm.o_ppm_information5
  ,p_o_ppm_information6    => p_saved_ppm.o_ppm_information6
  ,p_o_ppm_information7    => p_saved_ppm.o_ppm_information7
  ,p_o_ppm_information8    => p_saved_ppm.o_ppm_information8
  ,p_o_ppm_information9    => p_saved_ppm.o_ppm_information9
  ,p_o_ppm_information10   => p_saved_ppm.o_ppm_information10
  ,p_o_ppm_information11   => p_saved_ppm.o_ppm_information11
  ,p_o_ppm_information12   => p_saved_ppm.o_ppm_information12
  ,p_o_ppm_information13   => p_saved_ppm.o_ppm_information13
  ,p_o_ppm_information14   => p_saved_ppm.o_ppm_information14
  ,p_o_ppm_information15   => p_saved_ppm.o_ppm_information15
  ,p_o_ppm_information16   => p_saved_ppm.o_ppm_information16
  ,p_o_ppm_information17   => p_saved_ppm.o_ppm_information17
  ,p_o_ppm_information18   => p_saved_ppm.o_ppm_information18
  ,p_o_ppm_information19   => p_saved_ppm.o_ppm_information19
  ,p_o_ppm_information20   => p_saved_ppm.o_ppm_information20
  ,p_o_ppm_information21   => p_saved_ppm.o_ppm_information21
  ,p_o_ppm_information22   => p_saved_ppm.o_ppm_information22
  ,p_o_ppm_information23   => p_saved_ppm.o_ppm_information23
  ,p_o_ppm_information24   => p_saved_ppm.o_ppm_information24
  ,p_o_ppm_information25   => p_saved_ppm.o_ppm_information25
  ,p_o_ppm_information26   => p_saved_ppm.o_ppm_information26
  ,p_o_ppm_information27   => p_saved_ppm.o_ppm_information27
  ,p_o_ppm_information28   => p_saved_ppm.o_ppm_information28
  ,p_o_ppm_information29   => p_saved_ppm.o_ppm_information29
  ,p_o_ppm_information30   => p_saved_ppm.o_ppm_information30
  ,p_changes               => l_changes
  ,p_bank                  => l_bank
  );
  p_current := l_changes;
end changedppm;
-----------------------------< nextentry >--------------------------
function nextentry
(p_list      in     varchar2
,p_separator in     varchar2
,p_start     in out nocopy number
) return varchar2 is
l_list  long;
l_entry long;
l_end   number;
begin
  l_list := substr(p_list, p_start);
  l_end :=  instr(l_list, p_separator);
  --
  -- Separator not found - last entry in the list.
  --
  if nvl(l_end, 0) = 0 then
    l_entry := l_list;
    p_start := 0;
  else
  --
  -- Found separator, get the entry and reset the start of
  -- the list. Don't worry if the new start is beyond the
  -- end of the list.
  --
    l_entry := substr(l_list, 1, l_end-1);
    p_start := p_start + l_end;
  end if;
  return l_entry;
end nextentry;
------------------------< read_wf_config_option >------------------------
function read_wf_config_option
(p_item_type   in varchar2
,p_item_key    in varchar2
,p_activity_id in number   default null
,p_option      in varchar2
,p_number      in boolean  default false
) return varchar2 is
l_value   long;
l_exists  boolean;
l_subtype wf_activity_attributes.subtype%type;
l_type    wf_activity_attributes.type%type;
l_format  wf_activity_attributes.format%type;
l_date    wf_activity_attr_values.date_value%type;
l_number  wf_activity_attr_values.number_value%type;
begin
  if p_activity_id is not null then
    --
    -- Look for activity attribute first.
    --
    hr_mee_workflow_service.get_act_attr_expanded_info
    (p_item_type    => p_item_type
    ,p_item_key     => p_item_key
    ,p_actid        => p_activity_id
    ,p_name         => p_option
    ,p_exists       => l_exists
    ,p_subtype      => l_subtype
    ,p_type         => l_type
    ,p_format       => l_format
    ,p_date_value   => l_date
    ,p_number_value => l_number
    ,p_text_value   => l_value
    );
    if l_exists then
      if l_type = 'NUMBER' then
        l_value := to_char(l_number);
      elsif l_type = 'DATE' then
        l_value := to_char(l_date, hr_transaction_ss.g_date_format);
      end if;
      return l_value;
    end if;
  end if;
  --
  -- Just look for item attribute.
  --
  if hr_workflow_utility.item_attribute_exists
     (p_item_type => p_item_type
     ,p_item_key  => p_item_key
     ,p_name      => p_option
     )
  then
    if p_number then
      l_number := wf_engine.getitemattrnumber
      (itemtype => p_item_type
      ,itemkey  => p_item_key
      ,aname    => p_option
      );
      l_value := to_char(l_number);
    else
      l_value := wf_engine.getitemattrtext
      (itemtype => p_item_type
      ,itemkey  => p_item_key
      ,aname    => p_option
      );
    end if;
    return l_value;
  end if;
  --
  -- Display a fatal error.
  --
  hr_utility.set_message
  (applid         => 800
  ,l_message_name => 'PAY_52631_PPMSS_OPTION_ERROR'
  );
  hr_utility.set_message_token
  (l_token_name  => 'OPTION'
  ,l_token_value => p_option
  );
  hr_utility.raise_error;
exception
  when others then
    raise;
end read_wf_config_option;
----------------------< getpriorities >-----------------------
procedure getpriorities
(p_assignment_id  in     number
,p_effective_date in     date
,p_run_type_id    in     number default null
,p_priority_tbl      out nocopy t_boolean_tbl
,p_first_available   out nocopy number
) is
cursor csr_priorities
(p_assignment_id  in number
,p_effective_date in date
,p_run_type_id    in number
) is
select ppm.priority priority
from   pay_personal_payment_methods_f ppm
,      pay_org_payment_methods_f opm
where  ppm.assignment_id = p_assignment_id
and    nvl(ppm.run_type_id, hr_api.g_number) = nvl(p_run_type_id, hr_api.g_number)
and    p_effective_date between
       ppm.effective_start_date and ppm.effective_end_date
and    opm.org_payment_method_id = ppm.org_payment_method_id
and    opm.defined_balance_id is not null
and    p_effective_date between
       opm.effective_start_date and opm.effective_end_date
order by priority
;
--
l_priority_tbl    t_boolean_tbl;
l_first_available number;
l_proc            varchar2(2000) := g_package||'getpriorities';
begin
  seterrorstage(l_proc, 'ENTER', 0);
  --
  -- Initialise the priority table.
  --
  for i in C_MIN_PRIORITY .. C_MAX_PRIORITY loop
    l_priority_tbl(i) := true;
  end loop;
  --
  -- Get the existing priorities.
  --
  seterrorstage(l_proc, 'FETCH_PRIORITIES', 10);
  l_first_available := C_MIN_PRIORITY;
  for crec in csr_priorities
  (p_assignment_id  => p_assignment_id
  ,p_effective_date => p_effective_date
  ,p_run_type_id    => p_run_type_id
  ) loop
    --
    -- Avoid adding entries for values < C_MIN_PRIORITY.
    --
    if crec.priority >= C_MIN_PRIORITY then
      l_priority_tbl(crec.priority) := false;
    end if;
    if crec.priority = l_first_available then
      l_first_available := l_first_available + 1;
    end if;
  end loop;
  p_first_available := l_first_available;
  p_priority_tbl := l_priority_tbl;
  seterrorstage(l_proc, 'EXIT:SUCCESS', 20);
  return;
exception
  when others then
    seterrorstage(l_proc, 'EXIT:FAIL', 30);
    raise;
end getpriorities;
-----------------------------< validateppm >------------------------
procedure validateppm
(p_state                      in     varchar2
,p_personal_payment_method_id in     number   default null
,p_object_version_number      in     number   default null
,p_update_datetrack_mode      in     varchar2 default null
,p_effective_date             in     date     default null
,p_org_payment_method_id      in     number   default null
,p_assignment_id              in     number   default null
,p_run_type_id                in     number   default null
,p_payment_type               in     varchar2 default null
,p_territory_code             in     varchar2 default null
,p_amount_type                in     varchar2 default null
,p_amount                     in     number   default null
,p_external_account_id        in     number   default null
,p_attribute_category         in     varchar2 default null
,p_attribute1                 in     varchar2 default null
,p_attribute2                 in     varchar2 default null
,p_attribute3                 in     varchar2 default null
,p_attribute4                 in     varchar2 default null
,p_attribute5                 in     varchar2 default null
,p_attribute6                 in     varchar2 default null
,p_attribute7                 in     varchar2 default null
,p_attribute8                 in     varchar2 default null
,p_attribute9                 in     varchar2 default null
,p_attribute10                in     varchar2 default null
,p_attribute11                in     varchar2 default null
,p_attribute12                in     varchar2 default null
,p_attribute13                in     varchar2 default null
,p_attribute14                in     varchar2 default null
,p_attribute15                in     varchar2 default null
,p_attribute16                in     varchar2 default null
,p_attribute17                in     varchar2 default null
,p_attribute18                in     varchar2 default null
,p_attribute19                in     varchar2 default null
,p_attribute20                in     varchar2 default null
,p_segment1                   in     varchar2 default null
,p_segment2                   in     varchar2 default null
,p_segment3                   in     varchar2 default null
,p_segment4                   in     varchar2 default null
,p_segment5                   in     varchar2 default null
,p_segment6                   in     varchar2 default null
,p_segment7                   in     varchar2 default null
,p_segment8                   in     varchar2 default null
,p_segment9                   in     varchar2 default null
,p_segment10                  in     varchar2 default null
,p_segment11                  in     varchar2 default null
,p_segment12                  in     varchar2 default null
,p_segment13                  in     varchar2 default null
,p_segment14                  in     varchar2 default null
,p_segment15                  in     varchar2 default null
,p_segment16                  in     varchar2 default null
,p_segment17                  in     varchar2 default null
,p_segment18                  in     varchar2 default null
,p_segment19                  in     varchar2 default null
,p_segment20                  in     varchar2 default null
,p_segment21                  in     varchar2 default null
,p_segment22                  in     varchar2 default null
,p_segment23                  in     varchar2 default null
,p_segment24                  in     varchar2 default null
,p_segment25                  in     varchar2 default null
,p_segment26                  in     varchar2 default null
,p_segment27                  in     varchar2 default null
,p_segment28                  in     varchar2 default null
,p_segment29                  in     varchar2 default null
,p_segment30                  in     varchar2 default null
,p_ppm_information_category   in     varchar2 default null
,p_ppm_information1           in     varchar2 default null
,p_ppm_information2           in     varchar2 default null
,p_ppm_information3           in     varchar2 default null
,p_ppm_information4           in     varchar2 default null
,p_ppm_information5           in     varchar2 default null
,p_ppm_information6           in     varchar2 default null
,p_ppm_information7           in     varchar2 default null
,p_ppm_information8           in     varchar2 default null
,p_ppm_information9           in     varchar2 default null
,p_ppm_information10          in     varchar2 default null
,p_ppm_information11          in     varchar2 default null
,p_ppm_information12          in     varchar2 default null
,p_ppm_information13          in     varchar2 default null
,p_ppm_information14          in     varchar2 default null
,p_ppm_information15          in     varchar2 default null
,p_ppm_information16          in     varchar2 default null
,p_ppm_information17          in     varchar2 default null
,p_ppm_information18          in     varchar2 default null
,p_ppm_information19          in     varchar2 default null
,p_ppm_information20          in     varchar2 default null
,p_ppm_information21          in     varchar2 default null
,p_ppm_information22          in     varchar2 default null
,p_ppm_information23          in     varchar2 default null
,p_ppm_information24          in     varchar2 default null
,p_ppm_information25          in     varchar2 default null
,p_ppm_information26          in     varchar2 default null
,p_ppm_information27          in     varchar2 default null
,p_ppm_information28          in     varchar2 default null
,p_ppm_information29          in     varchar2 default null
,p_ppm_information30          in     varchar2 default null
,p_return_status                 out nocopy varchar2
,p_msg_count                     out nocopy number
,p_msg_data                      out nocopy varchar2
) is
--
--  Cursor to get business_group_id from assignment_id and
--  effective_date. This is required for the INSERT operation.
--
cursor csr_asg_busgrp
(p_assignment_id  in number
,p_effective_date in date
) is
select asg.business_group_id
from   per_all_assignments_f asg
where  asg.assignment_id = p_assignment_id
and    p_effective_date between
       asg.effective_start_date and asg.effective_end_date
;
--
-- Cursor to get business_group_id from the personal_payment_method_id
-- and effective_date. This is required for the UPDATE operation.
--
cursor csr_ppm_busgrp
(p_personal_payment_method_id in number
,p_effective_date             in date
) is
select ppm.business_group_id
from   pay_personal_payment_methods_f ppm
where  ppm.personal_payment_method_id = p_personal_payment_method_id
and    p_effective_date between
       ppm.effective_start_date and ppm.effective_end_date
;
--
l_business_group_id     number;
l_rec                   pay_ppm_shd.g_rec_type;
l_datetrack_mode        varchar2(2000);
l_validation_start_date date;
l_validation_end_date   date;
l_message_name          varchar2(2000);
l_column                varchar2(2000);
l_prompt                varchar2(2000);
--
-- Percentage/Amount values.
--
l_amount                number;
l_percentage            number;
--
-- The following are required for bank details segment validation.
--
l_external_account_id   number;
l_external_account_ovn  number;
l_exa_user_error        boolean := false;
l_user_error            boolean := false;
--
-- API default values.
--
l_default_number        number;
l_default_varchar2      varchar2(2000);
--
-- Transit code checking.
--
l_check_digit           number;
l_transit_code_sum      number;
--
l_proc                  varchar2(2000) := g_package || 'validateppm';
begin
  --
  savepoint start_validate;
  --
  -- Set up default values by operation and type.
  --
  seterrorstage(l_proc, 'ENTER', 0);
  if p_state = pay_pss_tx_steps_pkg.C_STATE_NEW then
    seterrorstage(l_proc, 'C_STATE_NEW', 10);
    l_default_number := null;
    l_default_varchar2 := null;
    l_datetrack_mode := hr_api.g_insert;
  elsif p_state = pay_pss_tx_steps_pkg.C_STATE_UPDATED then
    seterrorstage(l_proc, 'C_STATE_UPDATED', 20);
    l_default_number := hr_api.g_number;
    l_default_varchar2 := hr_api.g_varchar2;
    l_datetrack_mode := p_update_datetrack_mode;
  else
    --
    -- Should not reach here.
    --
    seterrorstage(l_proc, 'STATE:'||p_state, 30);
    fnd_message.set_name('PAY', 'PAY_51518_PSS_ASSERT_ERROR');
    fnd_message.set_token('WHERE', l_proc);
    fnd_message.set_token('ADDITIONAL_INFO', '<p_state = ' || p_state || '>');
    fnd_msg_pub.add;
    p_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get
    (p_count => p_msg_count
    ,p_data  => p_msg_data
    );
    return;
  end if;
  --
  -- Set up Percent/Amount validation.
  --
  if p_amount_type = pay_pss_tx_steps_pkg.C_PERCENTAGE or
     p_amount_type = pay_pss_tx_steps_pkg.C_PERCENTAGE_ONLY then
    seterrorstage(l_proc, 'C_PERCENTAGE', 40);
    l_amount := null;
    l_percentage := p_amount;
  elsif p_amount_type = pay_pss_tx_steps_pkg.C_MONETARY or
        p_amount_type = pay_pss_tx_steps_pkg.C_MONETARY_ONLY then
    seterrorstage(l_proc, 'C_MONETARY', 50);
    l_amount := p_amount;
    l_percentage := null;
  elsif p_amount_type = pay_pss_tx_steps_pkg.C_REMAINING_PAY then
    --
    -- Handled as 100%.
    --
    seterrorstage(l_proc, 'C_REMAINING_PAY', 60);
    l_amount := null;
    l_percentage := 100;
  else
    --
    -- Should not reach here.
    --
    seterrorstage(l_proc, 'AMOUNT_TYPE:'||p_amount_type, 70);
    fnd_message.set_name('PAY', 'PAY_51518_PSS_ASSERT_ERROR');
    fnd_message.set_token('WHERE', l_proc);
    fnd_message.set_token
    ('ADDITIONAL_INFO', '<p_amount_type = ' || p_amount_type || '>');
    fnd_msg_pub.add;
    p_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get
    (p_count => p_msg_count
    ,p_data  => p_msg_data
    );
    return;
  end if;
  --
  -- Set up the business_group_id for the INSERT and UPDATE operations.
  --
  if p_state = pay_pss_tx_steps_pkg.C_STATE_NEW then
    --
    -- Check for (fatal) business_group_id error. If this error
    -- occurs then the module is broken.
    --
    seterrorstage(l_proc, 'ASG_BUSGRPID', 80);
    begin
      open csr_asg_busgrp
      (p_assignment_id  => p_assignment_id
      ,p_effective_date => p_effective_date
      );
      fetch csr_asg_busgrp
      into  l_business_group_id;
      close csr_asg_busgrp;
      hr_api.validate_bus_grp_id
      (p_business_group_id => l_business_group_id
      );
    exception
      when others then
        if csr_asg_busgrp%isopen then
          close csr_asg_busgrp;
        end if;
        raise;
    end;
  elsif p_state  = pay_pss_tx_steps_pkg.C_STATE_UPDATED then
    --
    -- Check for (fatal) business_group_id error. If this error
    -- occurs then the module is broken.
    --
    seterrorstage(l_proc, 'PPM_BUSGRPID', 90);
    begin
      open csr_ppm_busgrp
      (p_personal_payment_method_id => p_personal_payment_method_id
      ,p_effective_date             => p_effective_date
      );
      fetch csr_ppm_busgrp
      into  l_business_group_id;
      close csr_ppm_busgrp;
      hr_api.validate_bus_grp_id
      (p_business_group_id => l_business_group_id
      );
    exception
      when others then
        if csr_ppm_busgrp%isopen then
          close csr_ppm_busgrp;
        end if;
        raise;
    end;
  end if;
  --
  -- Set up the internal PPM record structure.
  --
  seterrorstage(l_proc, 'CONVERT_ARGS', 100);
  l_rec := pay_ppm_shd.convert_args
  (p_personal_payment_method_id =>
   nvl(p_personal_payment_method_id, l_default_number)
  ,p_effective_start_date       => null
  ,p_effective_end_date         => null
  ,p_business_group_id          => l_business_group_id
  ,p_external_account_id        => l_external_account_id
  ,p_assignment_id              => nvl(p_assignment_id, l_default_number)
  ,p_run_type_id                => p_run_type_id
  ,p_org_payment_method_id      => nvl(p_org_payment_method_id, l_default_number)
  ,p_amount                     => l_amount
  ,p_comment_id                 => l_default_number
  ,p_comments                   => l_default_varchar2
  ,p_percentage                 => l_percentage
  ,p_priority                   => hr_api.g_number
  ,p_attribute_category         => p_attribute_category
  ,p_attribute1                 => p_attribute1
  ,p_attribute2                 => p_attribute2
  ,p_attribute3                 => p_attribute3
  ,p_attribute4                 => p_attribute4
  ,p_attribute5                 => p_attribute5
  ,p_attribute6                 => p_attribute6
  ,p_attribute7                 => p_attribute7
  ,p_attribute8                 => p_attribute8
  ,p_attribute9                 => p_attribute9
  ,p_attribute10                => p_attribute10
  ,p_attribute11                => p_attribute11
  ,p_attribute12                => p_attribute12
  ,p_attribute13                => p_attribute13
  ,p_attribute14                => p_attribute14
  ,p_attribute15                => p_attribute15
  ,p_attribute16                => p_attribute16
  ,p_attribute17                => p_attribute17
  ,p_attribute18                => p_attribute18
  ,p_attribute19                => p_attribute19
  ,p_attribute20                => p_attribute20
  ,p_object_version_number      => nvl(p_object_version_number,l_default_number)
  ,p_payee_type                 => l_default_varchar2
  ,p_payee_id                   => l_default_number
  ,p_ppm_information_category   => p_ppm_information_category
  ,p_ppm_information1           => p_ppm_information1
  ,p_ppm_information2           => p_ppm_information2
  ,p_ppm_information3           => p_ppm_information3
  ,p_ppm_information4           => p_ppm_information4
  ,p_ppm_information5           => p_ppm_information5
  ,p_ppm_information6           => p_ppm_information6
  ,p_ppm_information7           => p_ppm_information7
  ,p_ppm_information8           => p_ppm_information8
  ,p_ppm_information9           => p_ppm_information9
  ,p_ppm_information10          => p_ppm_information10
  ,p_ppm_information11          => p_ppm_information11
  ,p_ppm_information12          => p_ppm_information12
  ,p_ppm_information13          => p_ppm_information13
  ,p_ppm_information14          => p_ppm_information14
  ,p_ppm_information15          => p_ppm_information15
  ,p_ppm_information16          => p_ppm_information16
  ,p_ppm_information17          => p_ppm_information17
  ,p_ppm_information18          => p_ppm_information18
  ,p_ppm_information19          => p_ppm_information19
  ,p_ppm_information20          => p_ppm_information20
  ,p_ppm_information21          => p_ppm_information21
  ,p_ppm_information22          => p_ppm_information22
  ,p_ppm_information23          => p_ppm_information23
  ,p_ppm_information24          => p_ppm_information24
  ,p_ppm_information25          => p_ppm_information25
  ,p_ppm_information26          => p_ppm_information26
  ,p_ppm_information27          => p_ppm_information27
  ,p_ppm_information28          => p_ppm_information28
  ,p_ppm_information29          => p_ppm_information29
  ,p_ppm_information30          => p_ppm_information30);

  --
  -- Do initial checks specific to each operation.
  --
  if p_state = pay_pss_tx_steps_pkg.C_STATE_NEW then
    --
    -- Do the record locking. If this code fails then it is fatal
    -- error within the module.
    --
    seterrorstage(l_proc, 'INS:INITIAL', 110);
    begin
      pay_ppm_ins.ins_lck
      (p_effective_date        => p_effective_date
      ,p_datetrack_mode        => l_datetrack_mode
      ,p_rec                   => l_rec
      ,p_validation_start_date => l_validation_start_date
      ,p_validation_end_date   => l_validation_end_date
      );
      --
      l_validation_end_date := pay_ppm_bus.return_effective_end_date
      (p_datetrack_mode             =>  l_datetrack_mode
      ,p_effective_date             =>  p_effective_date
      ,p_org_payment_method_id      =>  l_rec.org_payment_method_id
      ,p_business_group_id          =>  l_rec.business_group_id
      ,p_personal_payment_method_id =>  l_rec.personal_payment_method_id
      ,p_assignment_id              =>  l_rec.assignment_id
      ,p_run_type_id                =>  l_rec.run_type_id
      ,p_priority                   =>  l_rec.priority
      ,p_validation_start_date      =>  l_validation_start_date
      ,p_validation_end_date        =>  l_validation_end_date
      );
    exception
      when others then
        raise;
    end;
    --
    -- Check for (fatal) org_payment_method_id error. The module is
    -- broken if a correct value for org_payment_method_id is not
    -- supplied because the org_payment_method_id select list is
    -- generated.
    --
    begin
      pay_ppm_bus.chk_org_payment_method_id
      (p_business_group_id     => l_business_group_id
      ,p_org_payment_method_id => l_rec.org_payment_method_id
      ,p_effective_date        => p_effective_date
      );
    exception
      when others then
        raise;
    end;
  elsif p_state = pay_pss_tx_steps_pkg.C_STATE_UPDATED then
    --
    -- Do the record locking. If this code fails then it is fatal
    -- error within the module.
    --
    seterrorstage(l_proc, 'UPD:INITIAL', 120);
    begin
      pay_ppm_shd.lck
      (p_effective_date             => p_effective_date
      ,p_datetrack_mode             => l_datetrack_mode
      ,p_personal_payment_method_id => l_rec.personal_payment_method_id
      ,p_object_version_number      => l_rec.object_version_number
      ,p_validation_start_date      => l_validation_start_date
      ,p_validation_end_date        => l_validation_end_date
      );
    exception
      when others then
        raise;
    end;
    --
    -- Convert the default values to the actual values.
    --
    pay_ppm_upd.convert_defs(p_rec => l_rec);
    --
    -- Check for (fatal) error in the arguments that may not be updated.
    -- Such an error indicates a bug in the module.
    --
    seterrorstage(l_proc, 'CHK_NON_UPDATEABLE', 130);
    begin
      pay_ppm_bus.check_non_updateable_args
      (p_rec            => l_rec
      ,p_effective_date => p_effective_date
      );
    exception
      when others then
        raise;
    end;
  end if;
  --
  -- Now call the segment validation code.
  --
  seterrorstage(l_proc, 'VALIDATE_BANK_SEGMENTS', 150);
  begin
    --
    if p_payment_type = pay_pss_tx_steps_pkg.C_DEPOSIT then
      --
      -- The OA key flex code inserts into the combination table: therefore,
      -- p_external_account_id refers to an existing row in
      -- PAY_EXTERNAL_ACCOUNTS.
      --
      l_external_account_id := p_external_account_id;
      pay_exa_upd.upd_or_sel
      (p_segment1              => p_segment1
      ,p_segment2              => p_segment2
      ,p_segment3              => p_segment3
      ,p_segment4              => p_segment4
      ,p_segment5              => p_segment5
      ,p_segment6              => p_segment6
      ,p_segment7              => p_segment7
      ,p_segment8              => p_segment8
      ,p_segment9              => p_segment9
      ,p_segment10             => p_segment10
      ,p_segment11             => p_segment11
      ,p_segment12             => p_segment12
      ,p_segment13             => p_segment13
      ,p_segment14             => p_segment14
      ,p_segment15             => p_segment15
      ,p_segment16             => p_segment16
      ,p_segment17             => p_segment17
      ,p_segment18             => p_segment18
      ,p_segment19             => p_segment19
      ,p_segment20             => p_segment20
      ,p_segment21             => p_segment21
      ,p_segment22             => p_segment22
      ,p_segment23             => p_segment23
      ,p_segment24             => p_segment24
      ,p_segment25             => p_segment25
      ,p_segment26             => p_segment26
      ,p_segment27             => p_segment27
      ,p_segment28             => p_segment28
      ,p_segment29             => p_segment29
      ,p_segment30             => p_segment30
      ,p_concat_segments       => null
      ,p_business_group_id     => l_business_group_id
      ,p_territory_code        => p_territory_code
      ,p_external_account_id   => l_external_account_id
      ,p_object_version_number => l_external_account_ovn
      ,p_prenote_date          => null
      ,p_validate              => false
      );
    end if;
  exception
    when others then
      l_exa_user_error := true;
      l_user_error := true;
      l_external_account_id := null;
      hr_message.provide_error;
      l_message_name := hr_message.last_message_name;
      --
      -- Can set field-level errors for US and GB segments.
      --
      if (p_territory_code = 'US' and
           ( l_message_name = 'HR_51458_EXA_US_ACCT_NAME_LONG' or
             l_message_name = 'HR_51459_EXA_US_ACCT_TYPE_LONG' or
             l_message_name = 'HR_51460_EXA_US_ACC_TYP_UNKNOW' or
             l_message_name = 'HR_51461_EXA_US_ACCT_NO_LONG'   or
             l_message_name = 'HR_51462_EXA_US_TRAN_CODE_LONG' or
             l_message_name = 'HR_51463_EXA_US_BANK_NAME_LONG' or
             l_message_name = 'HR_51464_EXA_US_BANK_BRAN_LONG'
           )
         ) or
         (p_territory_code = 'GB' and
           ( l_message_name = 'HR_51416_EXA_BANK_NAME_LONG'     or
             l_message_name = 'HR_51417_EXA_BANK_NAME_UNKNOWN'  or
             l_message_name = 'HR_51418_EXA_BANK_BRANCH_LONG'   or
             l_message_name = 'HR_51419_EXA_SORT_CODE_LENGTH'   or
             l_message_name = 'HR_51420_EXA_SORT_CODE_POSITVE'  or
             l_message_name = 'HR_51421_EXA_ACCOUNT_NO_LONG'    or
             l_message_name = 'HR_51422_EXA_ACCT_NO_POSITIVE'   or
             l_message_name = 'HR_51423_EXA_ACCOUNT_NAME_LONG'  or
             l_message_name = 'HR_51424_EXA_ACCOUNT_NAME_CASE'  or
             l_message_name = 'HR_51425_EXA_ACCOUNT_TYPE_LONG'  or
             l_message_name = 'HR_51426_EXA_ACCT_TYPE_RANGE'    or
             l_message_name = 'HR_51427_EXA_BS_ACCT_NO_LONG'    or
             l_message_name = 'HR_51428_EXA_BS_ACCT_NO_CASE'    or
             l_message_name = 'HR_51429_EXA_BANK_LOC_LONG'      or
             l_message_name = 'HR_51430_EXA_BANK_LOC_UNKNOWN'
           )
         )
      then
        fnd_msg_pub.add;
      end if;
      --
      -- Handle generic flexfield errors.
      --
      if l_message_name = 'HR_FLEX_VALUE_MISSING' then
        fnd_message.set_name('PER', 'HR_WEB_REQUIRED_FIELD');
        fnd_msg_pub.add;
      elsif l_message_name = 'HR_FLEX_VALUE_INVALID' then
        fnd_message.set_name('PER', 'PAY_52634_PPM_BAD_FLEX_VALUE');
        l_prompt := hr_message.get_token_value(p_token_name => 'PROMPT');
        fnd_message.set_token('PROMPT', l_prompt);
        fnd_msg_pub.add;
      else
        --
        -- General flexfield message that cannot be assigned to a
        -- particular field.
        --
        fnd_msg_pub.add;
      end if;
  end;
  --
  -- Check Transit Code for US Bank flex.
  --
     if p_territory_code = 'US' then
     /*Only validate the transit code if the IAT Profile is set to N.
       If it's 'Y', then transit code should be '000000000' and this validation
       is raised in user hook of the US (PAY_US_PPM_HOOK)
       The below logic doesn't raise error message if the transit code is
       '000000000'. Logically it's valid but it's not a valid transit code.*/
     if (NVL(FND_PROFILE.VALUE('PAY_US_NACHA_IAT'),'N')='N') then
         if (p_segment4 = '000000000') then
             l_exa_user_error := true;
             l_user_error := true;
             fnd_message.set_name('PAY', 'PAY_50043_INVALID_TRANSIT_CODE');
             fnd_msg_pub.add;
        else
             l_transit_code_sum := 0;
            --
            -- Standard Transit Code checking algorithm.
            --
             l_check_digit := substr(p_segment4, 9, 1);
             for i in 1 .. 8 loop
                if i = 1 or i = 4 or i = 7 then
                  l_transit_code_sum :=
                  l_transit_code_sum + 3 * substr(p_segment4, i, 1);
                elsif i = 2 or i = 5 or i = 8 then
                  l_transit_code_sum :=
                  l_transit_code_sum + 7 * substr(p_segment4, i, 1);
                else
                  l_transit_code_sum :=
                  l_transit_code_sum + substr(p_segment4, i, 1);
                end if;
             end loop;
             l_transit_code_sum := 10 - mod(l_transit_code_sum, 10);
             if l_transit_code_sum = 10 then
                l_transit_code_sum := 0;
             end if;
             if l_transit_code_sum <> l_check_digit then
                l_exa_user_error := true;
                l_user_error := true;
                fnd_message.set_name('PAY', 'PAY_50043_INVALID_TRANSIT_CODE');
                fnd_msg_pub.add;
             end if;
         end if;
  end if;
  end if;
  --
  -- Only do the external_account_id check if there are no
  -- errors.
  --
  if not l_exa_user_error then
    seterrorstage(l_proc, 'CHK_EXA_ID', 160);
    begin
      pay_ppm_bus.chk_external_account_id
      (p_personal_payment_method_id => p_personal_payment_method_id
      ,p_org_payment_method_id      => l_rec.org_payment_method_id
      ,p_external_account_id        => l_external_account_id
      ,p_effective_date             => p_effective_date
      ,p_object_version_number      => p_object_version_number
      );
    exception
      when others then
        l_user_error := true;
        hr_message.provide_error;
        l_message_name := hr_message.last_message_name;
        if l_message_name = 'HR_6678_PPM_MT_BANK' then
          --
          -- The user did not supply bank details when required.
          --
          fnd_msg_pub.add;
        else
          --
          -- The remaining errors are fatal errors because they
          -- concern data that the module should set up correctly.
          --
          raise;
        end if;
    end;
  end if;
  --
  -- defined_balance_id check - this is yet another fatal error
  -- check.
  --
  begin
    seterrorstage(l_proc, 'CHK_DEF_BAL_ID', 170);
    pay_ppm_bus.chk_defined_balance_id
    (p_business_group_id           =>  l_rec.business_group_id
    ,p_assignment_id               =>  l_rec.assignment_id
    ,p_personal_payment_method_id  =>  l_rec.personal_payment_method_id
    ,p_org_payment_method_id       =>  l_rec.org_payment_method_id
    ,p_effective_date              =>  p_effective_date
    ,p_object_version_number       =>  l_rec.object_version_number
    ,p_payee_type                  =>  l_rec.payee_type
    ,p_payee_id                    =>  l_rec.payee_id
    );
  exception
    when others then
      raise;
  end;
  --
  -- Amount and percentage checks.
  --
  begin
    seterrorstage(l_proc, 'CHK_AMOUNT', 180);
    pay_ppm_bus.chk_amount_percent
    (p_amount                     => l_rec.amount
    ,p_percentage                 => l_rec.percentage
    ,p_personal_payment_method_id => l_rec.personal_payment_method_id
    ,p_org_payment_method_id      => l_rec.org_payment_method_id
    ,p_effective_date             => p_effective_date
    ,p_object_version_number      => l_rec.object_version_number
    );
  exception
    when others then
      l_user_error := true;
      hr_message.provide_error;
      l_message_name := hr_message.last_message_name;
      if l_message_name = 'HR_6221_PAYM_INVALID_PPM' or
         l_message_name = 'HR_6680_PPM_AMT_PERC' then
        --
        -- Choose more specific messages based on whether or not
        -- the configuration is for percent only or amount only.
        --
        if p_amount_type = pay_pss_tx_steps_pkg.C_PERCENTAGE or
           p_amount_type = pay_pss_tx_steps_pkg.C_MONETARY then
          fnd_msg_pub.add;
        else
          fnd_message.set_name('PER', 'HR_WEB_REQUIRED_FIELD');
          fnd_msg_pub.add;
        end if;
      elsif l_message_name = 'HR_7355_PPM_AMOUNT_NEGATIVE' or
            l_message_name = 'HR_7040_PERCENT_RANGE'       or
            l_message_name = 'HR_7912_CHECK_FMT_MONEY'     or
            l_message_name = 'HR_7913_CHK_FMT_INTEGER'
      then
        fnd_msg_pub.add;
      else
        --
        -- Some other (fatal) error.
        --
        raise;
      end if;
    end;
  --
  -- Check the descriptive flex field - another user-level error.
  --
  begin
    seterrorstage(l_proc, 'CHK_DF', 190);
    pay_ppm_bus.chk_df(p_rec => l_rec);
  exception
    when others then
      l_user_error := true;
      hr_message.provide_error;
      l_message_name := hr_message.last_message_name;
      if l_message_name = 'HR_FLEX_VALUE_MISSING' then
        fnd_message.set_name('PER', 'HR_WEB_REQUIRED_FIELD');
        fnd_msg_pub.add;
      elsif l_message_name = 'HR_FLEX_VALUE_INVALID' then
        l_prompt := hr_message.get_token_value(p_token_name => 'PROMPT');
        fnd_message.set_name('PER', 'PAY_52634_PPM_BAD_FLEX_VALUE');
        fnd_message.set_token('PROMPT', l_prompt);
        fnd_msg_pub.add;
      else
        if l_message_name is null then
          if fnd_flex_descval.encoded_error_message is not null then
            fnd_message.set_encoded(fnd_flex_descval.encoded_error_message);
          end if;
        end if;
        --
        -- General flexfield message that cannot be assigned to a
        -- particular field.
        --
        fnd_msg_pub.add;
      end if;
  end;
  --
  rollback to start_validate;
  --
  -- Set up messages to Oracle Applications API standards as these
  -- are handled "for free" using checkErrors.
  --
  if l_user_error then
    seterrorstage(l_proc, 'GOT_USER_ERRORS', 200);
    p_return_status := fnd_api.G_RET_STS_ERROR;
  else
    seterrorstage(l_proc, 'NO_USER_ERRORS', 205);
    p_return_status := fnd_api.G_RET_STS_SUCCESS;
  end if;
  fnd_msg_pub.count_and_get
  (p_count => p_msg_count
  ,p_data  => p_msg_data
  );
  seterrorstage(l_proc, 'EXIT:SUCCESS', 210);
  return;
exception
  when others then
    rollback to start_validate;
    seterrorstage(l_proc, 'EXIT:FAIL', 220);
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
end validateppm;
-----------------------------< process_api >------------------------
procedure process_api
(p_state                      in     varchar2 default null
,p_personal_payment_method_id in     number   default null
,p_object_version_number      in     number   default null
,p_delete_ovn                 in     number   default null
,p_update_datetrack_mode      in     varchar2 default null
,p_delete_datetrack_mode      in     varchar2 default null
,p_effective_date             in     date     default null
,p_org_payment_method_id      in     number   default null
,p_assignment_id              in     number   default null
,p_run_type_id                in     number   default null
,p_territory_code             in     varchar2 default null
,p_real_priority              in     number   default null
,p_amount_type                in     varchar2 default null
,p_amount                     in     number   default null
,p_attribute_category         in     varchar2 default null
,p_attribute1                 in     varchar2 default null
,p_attribute2                 in     varchar2 default null
,p_attribute3                 in     varchar2 default null
,p_attribute4                 in     varchar2 default null
,p_attribute5                 in     varchar2 default null
,p_attribute6                 in     varchar2 default null
,p_attribute7                 in     varchar2 default null
,p_attribute8                 in     varchar2 default null
,p_attribute9                 in     varchar2 default null
,p_attribute10                in     varchar2 default null
,p_attribute11                in     varchar2 default null
,p_attribute12                in     varchar2 default null
,p_attribute13                in     varchar2 default null
,p_attribute14                in     varchar2 default null
,p_attribute15                in     varchar2 default null
,p_attribute16                in     varchar2 default null
,p_attribute17                in     varchar2 default null
,p_attribute18                in     varchar2 default null
,p_attribute19                in     varchar2 default null
,p_attribute20                in     varchar2 default null
,p_segment1                   in     varchar2 default null
,p_segment2                   in     varchar2 default null
,p_segment3                   in     varchar2 default null
,p_segment4                   in     varchar2 default null
,p_segment5                   in     varchar2 default null
,p_segment6                   in     varchar2 default null
,p_segment7                   in     varchar2 default null
,p_segment8                   in     varchar2 default null
,p_segment9                   in     varchar2 default null
,p_segment10                  in     varchar2 default null
,p_segment11                  in     varchar2 default null
,p_segment12                  in     varchar2 default null
,p_segment13                  in     varchar2 default null
,p_segment14                  in     varchar2 default null
,p_segment15                  in     varchar2 default null
,p_segment16                  in     varchar2 default null
,p_segment17                  in     varchar2 default null
,p_segment18                  in     varchar2 default null
,p_segment19                  in     varchar2 default null
,p_segment20                  in     varchar2 default null
,p_segment21                  in     varchar2 default null
,p_segment22                  in     varchar2 default null
,p_segment23                  in     varchar2 default null
,p_segment24                  in     varchar2 default null
,p_segment25                  in     varchar2 default null
,p_segment26                  in     varchar2 default null
,p_segment27                  in     varchar2 default null
,p_segment28                  in     varchar2 default null
,p_segment29                  in     varchar2 default null
,p_segment30                  in     varchar2 default null
,p_o_real_priority            in     number   default null
,p_validate                   in     boolean  default false
,p_ppm_information_category   in     varchar2 default null
,p_ppm_information1           in     varchar2 default null
,p_ppm_information2           in     varchar2 default null
,p_ppm_information3           in     varchar2 default null
,p_ppm_information4           in     varchar2 default null
,p_ppm_information5           in     varchar2 default null
,p_ppm_information6           in     varchar2 default null
,p_ppm_information7           in     varchar2 default null
,p_ppm_information8           in     varchar2 default null
,p_ppm_information9           in     varchar2 default null
,p_ppm_information10          in     varchar2 default null
,p_ppm_information11          in     varchar2 default null
,p_ppm_information12          in     varchar2 default null
,p_ppm_information13          in     varchar2 default null
,p_ppm_information14          in     varchar2 default null
,p_ppm_information15          in     varchar2 default null
,p_ppm_information16          in     varchar2 default null
,p_ppm_information17          in     varchar2 default null
,p_ppm_information18          in     varchar2 default null
,p_ppm_information19          in     varchar2 default null
,p_ppm_information20          in     varchar2 default null
,p_ppm_information21          in     varchar2 default null
,p_ppm_information22          in     varchar2 default null
,p_ppm_information23          in     varchar2 default null
,p_ppm_information24          in     varchar2 default null
,p_ppm_information25          in     varchar2 default null
,p_ppm_information26          in     varchar2 default null
,p_ppm_information27          in     varchar2 default null
,p_ppm_information28          in     varchar2 default null
,p_ppm_information29          in     varchar2 default null
,p_ppm_information30          in     varchar2 default null
) is
l_effective_date             date;
--
-- Various OUT-parameters.
--
l_effective_start_date       date;
l_effective_end_date         date;
l_object_version_number      number;
l_personal_payment_method_id number;
l_external_account_id        number;
l_comment_id                 number;
--
-- Percentage/Amount.
--
l_percentage                 number;
l_amount                     number;
l_proc                       varchar2(100) := 'PAY_PPMV4_UTILS_SS.PROCESS_API';
begin
  seterrorstage(l_proc,'Entering ...',10);
  l_object_version_number := p_object_version_number;
  l_personal_payment_method_id := p_personal_payment_method_id;
  --
  -- Set Percentage/Amount.
  --
  if p_amount_type = pay_pss_tx_steps_pkg.C_PERCENTAGE or
     p_amount_type = pay_pss_tx_steps_pkg.C_PERCENTAGE_ONLY then
    l_percentage := p_amount;
    l_amount := null;
  elsif p_amount_type = pay_pss_tx_steps_pkg.C_MONETARY or
        p_amount_type = pay_pss_tx_steps_pkg.C_MONETARY_ONLY then
    l_percentage := null;
    l_amount := p_amount;

    --
    -- If its the C_REMAINING_PAY (i.e. lowest priority) pay method,
    -- then setting the values to hr_api.g_number so that original values are retained
    -- when date track apis enters a new record.
  else
    /*Below are the changes done based on the bug#7230549, 8279553. This is not
	  expected functionality. So we are revering back the changes.
	  If the customer still want this functionality then we need to
	  create a profile and switch this functionality based on the profile.*/
	/*Bug#8279553: Setting the percentage to 100 when the PPM is created for
      the first time.*/
    /*if p_state = pay_pss_tx_steps_pkg.C_STATE_NEW then
	    l_percentage := 100;
	    l_amount := null;
    elsif p_state = pay_pss_tx_steps_pkg.C_STATE_UPDATED then
	    l_percentage := hr_api.g_number;
 	    l_amount := hr_api.g_number;
    end if;*/
	l_percentage := 100;
        l_amount := null;
  end if;

   /*Store the session into FND_SESSIONS and profile PAY_US_NACHA_IAT.
    *This is required to derive the segments of the DFFs*/
   pay_ppmv4_ss.store_session(trunc(p_effective_date));
   fnd_profile.put('PAY_US_NACHA_IAT',p_ppm_information4);
  --
  -- Check the PPM state to determine which API call to make.
  --
  seterrorstage(l_proc,'Calling  ...hr_personal_pay_method_api.create_personal_pay_method',20);
  if p_state = pay_pss_tx_steps_pkg.C_STATE_NEW then
    hr_personal_pay_method_api.create_personal_pay_method
    (p_validate                   => p_validate
    ,p_effective_date             => p_effective_date
    ,p_assignment_id              => p_assignment_id
    ,p_run_type_id                => p_run_type_id
    ,p_org_payment_method_id      => p_org_payment_method_id
    ,p_personal_payment_method_id => l_personal_payment_method_id
    ,p_object_version_number      => l_object_version_number
    ,p_amount                     => l_amount
    ,p_percentage                 => l_percentage
    ,p_priority                   => p_real_priority
    ,p_attribute_category         => p_attribute_category
    ,p_attribute1                 => p_attribute1
    ,p_attribute2                 => p_attribute2
    ,p_attribute3                 => p_attribute3
    ,p_attribute4                 => p_attribute4
    ,p_attribute5                 => p_attribute5
    ,p_attribute6                 => p_attribute6
    ,p_attribute7                 => p_attribute7
    ,p_attribute8                 => p_attribute8
    ,p_attribute9                 => p_attribute9
    ,p_attribute10                => p_attribute10
    ,p_attribute11                => p_attribute11
    ,p_attribute12                => p_attribute12
    ,p_attribute13                => p_attribute13
    ,p_attribute14                => p_attribute14
    ,p_attribute15                => p_attribute15
    ,p_attribute16                => p_attribute16
    ,p_attribute17                => p_attribute17
    ,p_attribute18                => p_attribute18
    ,p_attribute19                => p_attribute19
    ,p_attribute20                => p_attribute20
    ,p_territory_code             => p_territory_code
    ,p_segment1                   => p_segment1
    ,p_segment2                   => p_segment2
    ,p_segment3                   => p_segment3
    ,p_segment4                   => p_segment4
    ,p_segment5                   => p_segment5
    ,p_segment6                   => p_segment6
    ,p_segment7                   => p_segment7
    ,p_segment8                   => p_segment8
    ,p_segment9                   => p_segment9
    ,p_segment10                  => p_segment10
    ,p_segment11                  => p_segment11
    ,p_segment12                  => p_segment12
    ,p_segment13                  => p_segment13
    ,p_segment14                  => p_segment14
    ,p_segment15                  => p_segment15
    ,p_segment16                  => p_segment16
    ,p_segment17                  => p_segment17
    ,p_segment18                  => p_segment18
    ,p_segment19                  => p_segment19
    ,p_segment20                  => p_segment20
    ,p_segment21                  => p_segment21
    ,p_segment22                  => p_segment22
    ,p_segment23                  => p_segment23
    ,p_segment24                  => p_segment24
    ,p_segment25                  => p_segment25
    ,p_segment26                  => p_segment26
    ,p_segment27                  => p_segment27
    ,p_segment28                  => p_segment28
    ,p_segment29                  => p_segment29
    ,p_segment30                  => p_segment30
    ,p_ppm_information_category   => p_ppm_information_category
    ,p_ppm_information1           => p_ppm_information1
    ,p_ppm_information2           => p_ppm_information2
    ,p_ppm_information3           => p_ppm_information3
    ,p_ppm_information4           => p_ppm_information4
    ,p_ppm_information5           => p_ppm_information5
    ,p_ppm_information6           => p_ppm_information6
    ,p_ppm_information7           => p_ppm_information7
    ,p_ppm_information8           => p_ppm_information8
    ,p_ppm_information9           => p_ppm_information9
    ,p_ppm_information10          => p_ppm_information10
    ,p_ppm_information11          => p_ppm_information11
    ,p_ppm_information12          => p_ppm_information12
    ,p_ppm_information13          => p_ppm_information13
    ,p_ppm_information14          => p_ppm_information14
    ,p_ppm_information15          => p_ppm_information15
    ,p_ppm_information16          => p_ppm_information16
    ,p_ppm_information17          => p_ppm_information17
    ,p_ppm_information18          => p_ppm_information18
    ,p_ppm_information19          => p_ppm_information19
    ,p_ppm_information20          => p_ppm_information20
    ,p_ppm_information21          => p_ppm_information21
    ,p_ppm_information22          => p_ppm_information22
    ,p_ppm_information23          => p_ppm_information23
    ,p_ppm_information24          => p_ppm_information24
    ,p_ppm_information25          => p_ppm_information25
    ,p_ppm_information26          => p_ppm_information26
    ,p_ppm_information27          => p_ppm_information27
    ,p_ppm_information28          => p_ppm_information28
    ,p_ppm_information29          => p_ppm_information29
    ,p_ppm_information30          => p_ppm_information30
    ,p_external_account_id        => l_external_account_id
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_comment_id                 => l_comment_id
    );
  elsif p_state = pay_pss_tx_steps_pkg.C_STATE_UPDATED then
    seterrorstage(l_proc, 'Calling ...hr_personal_pay_method_api.update_personal_pay_method', 30);
    hr_personal_pay_method_api.update_personal_pay_method
    (p_validate                   => p_validate
    ,p_effective_date             => p_effective_date
    ,p_datetrack_update_mode      => p_update_datetrack_mode
    ,p_personal_payment_method_id => p_personal_payment_method_id
    ,p_object_version_number      => l_object_version_number
    ,p_amount                     => l_amount
    ,p_percentage                 => l_percentage
    ,p_priority                   => p_real_priority
    ,p_attribute_category         => p_attribute_category
    ,p_attribute1                 => p_attribute1
    ,p_attribute2                 => p_attribute2
    ,p_attribute3                 => p_attribute3
    ,p_attribute4                 => p_attribute4
    ,p_attribute5                 => p_attribute5
    ,p_attribute6                 => p_attribute6
    ,p_attribute7                 => p_attribute7
    ,p_attribute8                 => p_attribute8
    ,p_attribute9                 => p_attribute9
    ,p_attribute10                => p_attribute10
    ,p_attribute11                => p_attribute11
    ,p_attribute12                => p_attribute12
    ,p_attribute13                => p_attribute13
    ,p_attribute14                => p_attribute14
    ,p_attribute15                => p_attribute15
    ,p_attribute16                => p_attribute16
    ,p_attribute17                => p_attribute17
    ,p_attribute18                => p_attribute18
    ,p_attribute19                => p_attribute19
    ,p_attribute20                => p_attribute20
    ,p_territory_code             => p_territory_code
    ,p_segment1                   => p_segment1
    ,p_segment2                   => p_segment2
    ,p_segment3                   => p_segment3
    ,p_segment4                   => p_segment4
    ,p_segment5                   => p_segment5
    ,p_segment6                   => p_segment6
    ,p_segment7                   => p_segment7
    ,p_segment8                   => p_segment8
    ,p_segment9                   => p_segment9
    ,p_segment10                  => p_segment10
    ,p_segment11                  => p_segment11
    ,p_segment12                  => p_segment12
    ,p_segment13                  => p_segment13
    ,p_segment14                  => p_segment14
    ,p_segment15                  => p_segment15
    ,p_segment16                  => p_segment16
    ,p_segment17                  => p_segment17
    ,p_segment18                  => p_segment18
    ,p_segment19                  => p_segment19
    ,p_segment20                  => p_segment20
    ,p_segment21                  => p_segment21
    ,p_segment22                  => p_segment22
    ,p_segment23                  => p_segment23
    ,p_segment24                  => p_segment24
    ,p_segment25                  => p_segment25
    ,p_segment26                  => p_segment26
    ,p_segment27                  => p_segment27
    ,p_segment28                  => p_segment28
    ,p_segment29                  => p_segment29
    ,p_segment30                  => p_segment30
    ,p_ppm_information_category   => p_ppm_information_category
    ,p_ppm_information1           => p_ppm_information1
    ,p_ppm_information2           => p_ppm_information2
    ,p_ppm_information3           => p_ppm_information3
    ,p_ppm_information4           => p_ppm_information4
    ,p_ppm_information5           => p_ppm_information5
    ,p_ppm_information6           => p_ppm_information6
    ,p_ppm_information7           => p_ppm_information7
    ,p_ppm_information8           => p_ppm_information8
    ,p_ppm_information9           => p_ppm_information9
    ,p_ppm_information10          => p_ppm_information10
    ,p_ppm_information11          => p_ppm_information11
    ,p_ppm_information12          => p_ppm_information12
    ,p_ppm_information13          => p_ppm_information13
    ,p_ppm_information14          => p_ppm_information14
    ,p_ppm_information15          => p_ppm_information15
    ,p_ppm_information16          => p_ppm_information16
    ,p_ppm_information17          => p_ppm_information17
    ,p_ppm_information18          => p_ppm_information18
    ,p_ppm_information19          => p_ppm_information19
    ,p_ppm_information20          => p_ppm_information20
    ,p_ppm_information21          => p_ppm_information21
    ,p_ppm_information22          => p_ppm_information22
    ,p_ppm_information23          => p_ppm_information23
    ,p_ppm_information24          => p_ppm_information24
    ,p_ppm_information25          => p_ppm_information25
    ,p_ppm_information26          => p_ppm_information26
    ,p_ppm_information27          => p_ppm_information27
    ,p_ppm_information28          => p_ppm_information28
    ,p_ppm_information29          => p_ppm_information29
    ,p_ppm_information30          => p_ppm_information30
    ,p_external_account_id        => l_external_account_id
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_comment_id                 => l_comment_id
    );
  elsif p_state = pay_pss_tx_steps_pkg.C_STATE_DELETED then
    l_object_version_number := p_delete_ovn;
    if p_delete_datetrack_mode = hr_api.g_zap then
      l_effective_date := p_effective_date;
    else
      l_effective_date := p_effective_date - 1;
    end if;
    seterrorstage(l_proc,'Calling ...hr_personal_pay_method_api.delete_personal_pay_method',40);
    hr_personal_pay_method_api.delete_personal_pay_method
    (p_validate                   => p_validate
    ,p_effective_date             => l_effective_date
    ,p_datetrack_delete_mode      => p_delete_datetrack_mode
    ,p_personal_payment_method_id => p_personal_payment_method_id
    ,p_object_version_number      => l_object_version_number
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    );
  elsif p_state = pay_pss_tx_steps_pkg.C_STATE_EXISTING and
        p_real_priority <> p_o_real_priority then
    seterrorstage(l_proc,'Calling ...hr_personal_pay_method_api.update_personal_pay_method',50);
    hr_personal_pay_method_api.update_personal_pay_method
    (p_validate                   => p_validate
    ,p_personal_payment_method_id => p_personal_payment_method_id
    ,p_object_version_number      => l_object_version_number
    ,p_effective_date             => p_effective_date
    ,p_datetrack_update_mode      => p_update_datetrack_mode
    ,p_priority                   => p_real_priority
    ,p_external_account_id        => l_external_account_id
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_comment_id                 => l_comment_id
    );
  end if;
exception
  when others then
    raise;
end process_api;
-------------------------< get_bank_segments >----------------------
procedure get_bank_segments
(p_external_account_id in     number
,p_segment1               out nocopy varchar2
,p_segment2               out nocopy varchar2
,p_segment3               out nocopy varchar2
,p_segment4               out nocopy varchar2
,p_segment5               out nocopy varchar2
,p_segment6               out nocopy varchar2
,p_segment7               out nocopy varchar2
,p_segment8               out nocopy varchar2
,p_segment9               out nocopy varchar2
,p_segment10              out nocopy varchar2
,p_segment11              out nocopy varchar2
,p_segment12              out nocopy varchar2
,p_segment13              out nocopy varchar2
,p_segment14              out nocopy varchar2
,p_segment15              out nocopy varchar2
,p_segment16              out nocopy varchar2
,p_segment17              out nocopy varchar2
,p_segment18              out nocopy varchar2
,p_segment19              out nocopy varchar2
,p_segment20              out nocopy varchar2
,p_segment21              out nocopy varchar2
,p_segment22              out nocopy varchar2
,p_segment23              out nocopy varchar2
,p_segment24              out nocopy varchar2
,p_segment25              out nocopy varchar2
,p_segment26              out nocopy varchar2
,p_segment27              out nocopy varchar2
,p_segment28              out nocopy varchar2
,p_segment29              out nocopy varchar2
,p_segment30              out nocopy varchar2
) is
l_proc varchar2(2000) := g_package || 'get_bank_segments';
begin
  --
  -- Use SELECT ... INTO ... rather than a cursor as this select
  -- statement must return segments. The OA framework code inserts
  -- into the combination table.
  --
  seterrorstage(l_proc, 'ENTER', 10);
  select  segment1
  ,       segment2
  ,       segment3
  ,       segment4
  ,       segment5
  ,       segment6
  ,       segment7
  ,       segment8
  ,       segment9
  ,       segment10
  ,       segment11
  ,       segment12
  ,       segment13
  ,       segment14
  ,       segment15
  ,       segment16
  ,       segment17
  ,       segment18
  ,       segment19
  ,       segment20
  ,       segment21
  ,       segment22
  ,       segment23
  ,       segment24
  ,       segment25
  ,       segment26
  ,       segment27
  ,       segment28
  ,       segment29
  ,       segment30
  into    p_segment1
  ,       p_segment2
  ,       p_segment3
  ,       p_segment4
  ,       p_segment5
  ,       p_segment6
  ,       p_segment7
  ,       p_segment8
  ,       p_segment9
  ,       p_segment10
  ,       p_segment11
  ,       p_segment12
  ,       p_segment13
  ,       p_segment14
  ,       p_segment15
  ,       p_segment16
  ,       p_segment17
  ,       p_segment18
  ,       p_segment19
  ,       p_segment20
  ,       p_segment21
  ,       p_segment22
  ,       p_segment23
  ,       p_segment24
  ,       p_segment25
  ,       p_segment26
  ,       p_segment27
  ,       p_segment28
  ,       p_segment29
  ,       p_segment30
  from    pay_external_accounts
  where   external_account_id = p_external_account_id;
exception
  when others then
    seterrorstage(l_proc, 'EXIT:FAIL', 20);
    raise;
end get_bank_segments;
--
end pay_ppmv4_utils_ss;

/
