--------------------------------------------------------
--  DDL for Package Body PAY_PSS_TX_STEPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PSS_TX_STEPS_PKG" as
/* $Header: pypsst.pkb 120.0.12010000.2 2009/09/26 06:12:35 pgongada ship $ */
---------------------------------< create_row >----------------------------
procedure insert_row
(p_transaction_id             in out nocopy number
,p_transaction_step_id           out nocopy number
,p_source_table               in     varchar2
,p_state                      in     varchar2
,p_personal_payment_method_id in     number
,p_update_ovn                 in     number
,p_delete_ovn                 in     number
,p_update_datetrack_mode      in     varchar2
,p_delete_datetrack_mode      in     varchar2
,p_delete_disabled            in     varchar2
,p_effective_date             in     date
,p_org_payment_method_id      in     number
,p_assignment_id              in     number
,p_payment_type               in     varchar2
,p_currency_code              in     varchar2
,p_territory_code             in     varchar2
,p_run_type_id                in     number
,p_real_priority              in     number
,p_logical_priority           in     number
,p_amount_type                in     varchar2
,p_amount                     in     number
,p_external_account_id        in     number
,p_attribute_category         in     varchar2
,p_attribute1                 in     varchar2
,p_attribute2                 in     varchar2
,p_attribute3                 in     varchar2
,p_attribute4                 in     varchar2
,p_attribute5                 in     varchar2
,p_attribute6                 in     varchar2
,p_attribute7                 in     varchar2
,p_attribute8                 in     varchar2
,p_attribute9                 in     varchar2
,p_attribute10                in     varchar2
,p_attribute11                in     varchar2
,p_attribute12                in     varchar2
,p_attribute13                in     varchar2
,p_attribute14                in     varchar2
,p_attribute15                in     varchar2
,p_attribute16                in     varchar2
,p_attribute17                in     varchar2
,p_attribute18                in     varchar2
,p_attribute19                in     varchar2
,p_attribute20                in     varchar2
,p_o_real_priority            in     number
,p_o_logical_priority         in     number
,p_o_amount_type              in     varchar2
,p_o_amount                   in     number
,p_o_external_account_id      in     number
,p_o_attribute_category       in     varchar2
,p_o_attribute1               in     varchar2
,p_o_attribute2               in     varchar2
,p_o_attribute3               in     varchar2
,p_o_attribute4               in     varchar2
,p_o_attribute5               in     varchar2
,p_o_attribute6               in     varchar2
,p_o_attribute7               in     varchar2
,p_o_attribute8               in     varchar2
,p_o_attribute9               in     varchar2
,p_o_attribute10              in     varchar2
,p_o_attribute11              in     varchar2
,p_o_attribute12              in     varchar2
,p_o_attribute13              in     varchar2
,p_o_attribute14              in     varchar2
,p_o_attribute15              in     varchar2
,p_o_attribute16              in     varchar2
,p_o_attribute17              in     varchar2
,p_o_attribute18              in     varchar2
,p_o_attribute19              in     varchar2
,p_o_attribute20              in     varchar2
,p_ppm_information_category   in     varchar2
,p_ppm_information1           in     varchar2
,p_ppm_information2           in     varchar2
,p_ppm_information3           in     varchar2
,p_ppm_information4           in     varchar2
,p_ppm_information5           in     varchar2
,p_ppm_information6           in     varchar2
,p_ppm_information7           in     varchar2
,p_ppm_information8           in     varchar2
,p_ppm_information9           in     varchar2
,p_ppm_information10          in     varchar2
,p_ppm_information11          in     varchar2
,p_ppm_information12          in     varchar2
,p_ppm_information13          in     varchar2
,p_ppm_information14          in     varchar2
,p_ppm_information15          in     varchar2
,p_ppm_information16          in     varchar2
,p_ppm_information17          in     varchar2
,p_ppm_information18          in     varchar2
,p_ppm_information19          in     varchar2
,p_ppm_information20          in     varchar2
,p_ppm_information21          in     varchar2
,p_ppm_information22          in     varchar2
,p_ppm_information23          in     varchar2
,p_ppm_information24          in     varchar2
,p_ppm_information25          in     varchar2
,p_ppm_information26          in     varchar2
,p_ppm_information27          in     varchar2
,p_ppm_information28          in     varchar2
,p_ppm_information29          in     varchar2
,p_ppm_information30          in     varchar2
,p_o_ppm_information_category in     varchar2
,p_o_ppm_information1         in     varchar2
,p_o_ppm_information2         in     varchar2
,p_o_ppm_information3         in     varchar2
,p_o_ppm_information4         in     varchar2
,p_o_ppm_information5         in     varchar2
,p_o_ppm_information6         in     varchar2
,p_o_ppm_information7         in     varchar2
,p_o_ppm_information8         in     varchar2
,p_o_ppm_information9         in     varchar2
,p_o_ppm_information10        in     varchar2
,p_o_ppm_information11        in     varchar2
,p_o_ppm_information12        in     varchar2
,p_o_ppm_information13        in     varchar2
,p_o_ppm_information14        in     varchar2
,p_o_ppm_information15        in     varchar2
,p_o_ppm_information16        in     varchar2
,p_o_ppm_information17        in     varchar2
,p_o_ppm_information18        in     varchar2
,p_o_ppm_information19        in     varchar2
,p_o_ppm_information20        in     varchar2
,p_o_ppm_information21        in     varchar2
,p_o_ppm_information22        in     varchar2
,p_o_ppm_information23        in     varchar2
,p_o_ppm_information24        in     varchar2
,p_o_ppm_information25        in     varchar2
,p_o_ppm_information26        in     varchar2
,p_o_ppm_information27        in     varchar2
,p_o_ppm_information28        in     varchar2
,p_o_ppm_information29        in     varchar2
,p_o_ppm_information30        in     varchar2
) is
l_transaction_id      number := p_transaction_id;
l_transaction_step_id number;
begin
  --
  -- Create (and return) transaction_id, if necessary.
  --
  if l_transaction_id is null then
    select pay_pss_transactions_s.nextval
    into   l_transaction_id
    from    dual;
    p_transaction_id := l_transaction_id;
  end if;
  --
  -- Create and return the transaction_step_id.
  --
  select pay_pss_transaction_steps_s.nextval
  into   l_transaction_step_id
  from   dual;
  p_transaction_step_id := l_transaction_step_id;
  --
  -- Do the insert.
  --
  insert into pay_pss_transaction_steps
  (transaction_step_id
  ,transaction_id
  ,source_table
  ,state
  ,personal_payment_method_id
  ,update_ovn
  ,delete_ovn
  ,update_datetrack_mode
  ,delete_datetrack_mode
  ,delete_disabled
  ,effective_date
  ,org_payment_method_id
  ,assignment_id
  ,payment_type
  ,currency_code
  ,territory_code
  ,real_priority
  ,logical_priority
  ,amount_type
  ,amount
  ,external_account_id
  ,attribute_category
  ,attribute1
  ,attribute2
  ,attribute3
  ,attribute4
  ,attribute5
  ,attribute6
  ,attribute7
  ,attribute8
  ,attribute9
  ,attribute10
  ,attribute11
  ,attribute12
  ,attribute13
  ,attribute14
  ,attribute15
  ,attribute16
  ,attribute17
  ,attribute18
  ,attribute19
  ,attribute20
  ,o_real_priority
  ,o_logical_priority
  ,o_amount_type
  ,o_amount
  ,o_external_account_id
  ,o_attribute_category
  ,o_attribute1
  ,o_attribute2
  ,o_attribute3
  ,o_attribute4
  ,o_attribute5
  ,o_attribute6
  ,o_attribute7
  ,o_attribute8
  ,o_attribute9
  ,o_attribute10
  ,o_attribute11
  ,o_attribute12
  ,o_attribute13
  ,o_attribute14
  ,o_attribute15
  ,o_attribute16
  ,o_attribute17
  ,o_attribute18
  ,o_attribute19
  ,o_attribute20
  ,run_type_id
  ,ppm_information_category
  ,ppm_information1
  ,ppm_information2
  ,ppm_information3
  ,ppm_information4
  ,ppm_information5
  ,ppm_information6
  ,ppm_information7
  ,ppm_information8
  ,ppm_information9
  ,ppm_information10
  ,ppm_information11
  ,ppm_information12
  ,ppm_information13
  ,ppm_information14
  ,ppm_information15
  ,ppm_information16
  ,ppm_information17
  ,ppm_information18
  ,ppm_information19
  ,ppm_information20
  ,ppm_information21
  ,ppm_information22
  ,ppm_information23
  ,ppm_information24
  ,ppm_information25
  ,ppm_information26
  ,ppm_information27
  ,ppm_information28
  ,ppm_information29
  ,ppm_information30
  ,o_ppm_information_category
  ,o_ppm_information1
  ,o_ppm_information2
  ,o_ppm_information3
  ,o_ppm_information4
  ,o_ppm_information5
  ,o_ppm_information6
  ,o_ppm_information7
  ,o_ppm_information8
  ,o_ppm_information9
  ,o_ppm_information10
  ,o_ppm_information11
  ,o_ppm_information12
  ,o_ppm_information13
  ,o_ppm_information14
  ,o_ppm_information15
  ,o_ppm_information16
  ,o_ppm_information17
  ,o_ppm_information18
  ,o_ppm_information19
  ,o_ppm_information20
  ,o_ppm_information21
  ,o_ppm_information22
  ,o_ppm_information23
  ,o_ppm_information24
  ,o_ppm_information25
  ,o_ppm_information26
  ,o_ppm_information27
  ,o_ppm_information28
  ,o_ppm_information29
  ,o_ppm_information30
  )
  values
  (l_transaction_step_id
  ,l_transaction_id
  ,p_source_table
  ,p_state
  ,p_personal_payment_method_id
  ,p_update_ovn
  ,p_delete_ovn
  ,p_update_datetrack_mode
  ,p_delete_datetrack_mode
  ,p_delete_disabled
  ,p_effective_date
  ,p_org_payment_method_id
  ,p_assignment_id
  ,p_payment_type
  ,p_currency_code
  ,p_territory_code
  ,p_real_priority
  ,p_logical_priority
  ,p_amount_type
  ,p_amount
  ,p_external_account_id
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_o_real_priority
  ,p_o_logical_priority
  ,p_o_amount_type
  ,p_o_amount
  ,p_o_external_account_id
  ,p_o_attribute_category
  ,p_o_attribute1
  ,p_o_attribute2
  ,p_o_attribute3
  ,p_o_attribute4
  ,p_o_attribute5
  ,p_o_attribute6
  ,p_o_attribute7
  ,p_o_attribute8
  ,p_o_attribute9
  ,p_o_attribute10
  ,p_o_attribute11
  ,p_o_attribute12
  ,p_o_attribute13
  ,p_o_attribute14
  ,p_o_attribute15
  ,p_o_attribute16
  ,p_o_attribute17
  ,p_o_attribute18
  ,p_o_attribute19
  ,p_o_attribute20
  ,p_run_type_id
  ,p_ppm_information_category
  ,p_ppm_information1
  ,p_ppm_information2
  ,p_ppm_information3
  ,p_ppm_information4
  ,p_ppm_information5
  ,p_ppm_information6
  ,p_ppm_information7
  ,p_ppm_information8
  ,p_ppm_information9
  ,p_ppm_information10
  ,p_ppm_information11
  ,p_ppm_information12
  ,p_ppm_information13
  ,p_ppm_information14
  ,p_ppm_information15
  ,p_ppm_information16
  ,p_ppm_information17
  ,p_ppm_information18
  ,p_ppm_information19
  ,p_ppm_information20
  ,p_ppm_information21
  ,p_ppm_information22
  ,p_ppm_information23
  ,p_ppm_information24
  ,p_ppm_information25
  ,p_ppm_information26
  ,p_ppm_information27
  ,p_ppm_information28
  ,p_ppm_information29
  ,p_ppm_information30
  ,p_o_ppm_information_category
  ,p_o_ppm_information1
  ,p_o_ppm_information2
  ,p_o_ppm_information3
  ,p_o_ppm_information4
  ,p_o_ppm_information5
  ,p_o_ppm_information6
  ,p_o_ppm_information7
  ,p_o_ppm_information8
  ,p_o_ppm_information9
  ,p_o_ppm_information10
  ,p_o_ppm_information11
  ,p_o_ppm_information12
  ,p_o_ppm_information13
  ,p_o_ppm_information14
  ,p_o_ppm_information15
  ,p_o_ppm_information16
  ,p_o_ppm_information17
  ,p_o_ppm_information18
  ,p_o_ppm_information19
  ,p_o_ppm_information20
  ,p_o_ppm_information21
  ,p_o_ppm_information22
  ,p_o_ppm_information23
  ,p_o_ppm_information24
  ,p_o_ppm_information25
  ,p_o_ppm_information26
  ,p_o_ppm_information27
  ,p_o_ppm_information28
  ,p_o_ppm_information29
  ,p_o_ppm_information30
  );
end insert_row;
----------------------------------< update_row >----------------------------
procedure update_row
(p_transaction_step_id        in     number
,p_source_table               in     varchar2
,p_state                      in     varchar2
,p_personal_payment_method_id in     number
,p_update_ovn                 in     number
,p_delete_ovn                 in     number
,p_update_datetrack_mode      in     varchar2
,p_delete_datetrack_mode      in     varchar2
,p_delete_disabled            in     varchar2
,p_effective_date             in     date
,p_org_payment_method_id      in     number
,p_assignment_id              in     number
,p_payment_type               in     varchar2
,p_currency_code              in     varchar2
,p_territory_code             in     varchar2
,p_run_type_id                in     number
,p_real_priority              in     number
,p_logical_priority           in     number
,p_amount_type                in     varchar2
,p_amount                     in     number
,p_external_account_id        in     number
,p_attribute_category         in     varchar2
,p_attribute1                 in     varchar2
,p_attribute2                 in     varchar2
,p_attribute3                 in     varchar2
,p_attribute4                 in     varchar2
,p_attribute5                 in     varchar2
,p_attribute6                 in     varchar2
,p_attribute7                 in     varchar2
,p_attribute8                 in     varchar2
,p_attribute9                 in     varchar2
,p_attribute10                in     varchar2
,p_attribute11                in     varchar2
,p_attribute12                in     varchar2
,p_attribute13                in     varchar2
,p_attribute14                in     varchar2
,p_attribute15                in     varchar2
,p_attribute16                in     varchar2
,p_attribute17                in     varchar2
,p_attribute18                in     varchar2
,p_attribute19                in     varchar2
,p_attribute20                in     varchar2
,p_o_real_priority            in     number
,p_o_logical_priority         in     number
,p_o_amount_type              in     varchar2
,p_o_amount                   in     number
,p_o_external_account_id      in     number
,p_o_attribute_category       in     varchar2
,p_o_attribute1               in     varchar2
,p_o_attribute2               in     varchar2
,p_o_attribute3               in     varchar2
,p_o_attribute4               in     varchar2
,p_o_attribute5               in     varchar2
,p_o_attribute6               in     varchar2
,p_o_attribute7               in     varchar2
,p_o_attribute8               in     varchar2
,p_o_attribute9               in     varchar2
,p_o_attribute10              in     varchar2
,p_o_attribute11              in     varchar2
,p_o_attribute12              in     varchar2
,p_o_attribute13              in     varchar2
,p_o_attribute14              in     varchar2
,p_o_attribute15              in     varchar2
,p_o_attribute16              in     varchar2
,p_o_attribute17              in     varchar2
,p_o_attribute18              in     varchar2
,p_o_attribute19              in     varchar2
,p_o_attribute20              in     varchar2
,p_ppm_information_category   in     varchar2
,p_ppm_information1           in     varchar2
,p_ppm_information2           in     varchar2
,p_ppm_information3           in     varchar2
,p_ppm_information4           in     varchar2
,p_ppm_information5           in     varchar2
,p_ppm_information6           in     varchar2
,p_ppm_information7           in     varchar2
,p_ppm_information8           in     varchar2
,p_ppm_information9           in     varchar2
,p_ppm_information10          in     varchar2
,p_ppm_information11          in     varchar2
,p_ppm_information12          in     varchar2
,p_ppm_information13          in     varchar2
,p_ppm_information14          in     varchar2
,p_ppm_information15          in     varchar2
,p_ppm_information16          in     varchar2
,p_ppm_information17          in     varchar2
,p_ppm_information18          in     varchar2
,p_ppm_information19          in     varchar2
,p_ppm_information20          in     varchar2
,p_ppm_information21          in     varchar2
,p_ppm_information22          in     varchar2
,p_ppm_information23          in     varchar2
,p_ppm_information24          in     varchar2
,p_ppm_information25          in     varchar2
,p_ppm_information26          in     varchar2
,p_ppm_information27          in     varchar2
,p_ppm_information28          in     varchar2
,p_ppm_information29          in     varchar2
,p_ppm_information30          in     varchar2
,p_o_ppm_information_category in     varchar2
,p_o_ppm_information1         in     varchar2
,p_o_ppm_information2         in     varchar2
,p_o_ppm_information3         in     varchar2
,p_o_ppm_information4         in     varchar2
,p_o_ppm_information5         in     varchar2
,p_o_ppm_information6         in     varchar2
,p_o_ppm_information7         in     varchar2
,p_o_ppm_information8         in     varchar2
,p_o_ppm_information9         in     varchar2
,p_o_ppm_information10        in     varchar2
,p_o_ppm_information11        in     varchar2
,p_o_ppm_information12        in     varchar2
,p_o_ppm_information13        in     varchar2
,p_o_ppm_information14        in     varchar2
,p_o_ppm_information15        in     varchar2
,p_o_ppm_information16        in     varchar2
,p_o_ppm_information17        in     varchar2
,p_o_ppm_information18        in     varchar2
,p_o_ppm_information19        in     varchar2
,p_o_ppm_information20        in     varchar2
,p_o_ppm_information21        in     varchar2
,p_o_ppm_information22        in     varchar2
,p_o_ppm_information23        in     varchar2
,p_o_ppm_information24        in     varchar2
,p_o_ppm_information25        in     varchar2
,p_o_ppm_information26        in     varchar2
,p_o_ppm_information27        in     varchar2
,p_o_ppm_information28        in     varchar2
,p_o_ppm_information29        in     varchar2
,p_o_ppm_information30        in     varchar2
) is
begin
  update pay_pss_transaction_steps p
  set    p.source_table = p_source_table
  ,      p.state = p_state
  ,      p.personal_payment_method_id = p_personal_payment_method_id
  ,      p.update_ovn = p_update_ovn
  ,      p.delete_ovn = p_delete_ovn
  ,      p.update_datetrack_mode = p_update_datetrack_mode
  ,      p.delete_datetrack_mode = p_delete_datetrack_mode
  ,      p.delete_disabled = p_delete_disabled
  ,      p.effective_date = p_effective_date
  ,      p.org_payment_method_id = p_org_payment_method_id
  ,      p.assignment_id = p_assignment_id
  ,      p.payment_type = p_payment_type
  ,      p.currency_code = p_currency_code
  ,      p.territory_code = p_territory_code
  ,      p.real_priority = p_real_priority
  ,      p.logical_priority = p_logical_priority
  ,      p.amount_type = p_amount_type
  ,      p.amount = p_amount
  ,      p.external_account_id = p_external_account_id
  ,      p.attribute_category = p_attribute_category
  ,      p.attribute1  = p_attribute1
  ,      p.attribute2  = p_attribute2
  ,      p.attribute3  = p_attribute3
  ,      p.attribute4  = p_attribute4
  ,      p.attribute5  = p_attribute5
  ,      p.attribute6  = p_attribute6
  ,      p.attribute7  = p_attribute7
  ,      p.attribute8  = p_attribute8
  ,      p.attribute9  = p_attribute9
  ,      p.attribute10 = p_attribute10
  ,      p.attribute11 = p_attribute11
  ,      p.attribute12 = p_attribute12
  ,      p.attribute13 = p_attribute13
  ,      p.attribute14 = p_attribute14
  ,      p.attribute15 = p_attribute15
  ,      p.attribute16 = p_attribute16
  ,      p.attribute17 = p_attribute17
  ,      p.attribute18 = p_attribute18
  ,      p.attribute19 = p_attribute19
  ,      p.attribute20 = p_attribute20
  ,      p.o_real_priority = p_o_real_priority
  ,      p.o_logical_priority = p_o_logical_priority
  ,      p.o_amount_type = p_o_amount_type
  ,      p.o_amount = p_o_amount
  ,      p.o_external_account_id = p_o_external_account_id
  ,      p.o_attribute_category = p_o_attribute_category
  ,      p.o_attribute1  = p_o_attribute1
  ,      p.o_attribute2  = p_o_attribute2
  ,      p.o_attribute3  = p_o_attribute3
  ,      p.o_attribute4  = p_o_attribute4
  ,      p.o_attribute5  = p_o_attribute5
  ,      p.o_attribute6  = p_o_attribute6
  ,      p.o_attribute7  = p_o_attribute7
  ,      p.o_attribute8  = p_o_attribute8
  ,      p.o_attribute9  = p_o_attribute9
  ,      p.o_attribute10 = p_o_attribute10
  ,      p.o_attribute11 = p_o_attribute11
  ,      p.o_attribute12 = p_o_attribute12
  ,      p.o_attribute13 = p_o_attribute13
  ,      p.o_attribute14 = p_o_attribute14
  ,      p.o_attribute15 = p_o_attribute15
  ,      p.o_attribute16 = p_o_attribute16
  ,      p.o_attribute17 = p_o_attribute17
  ,      p.o_attribute18 = p_o_attribute18
  ,      p.o_attribute19 = p_o_attribute19
  ,      p.o_attribute20 = p_o_attribute20
  ,      p.run_type_id   = p_run_type_id
  ,      p.ppm_information_category = p_ppm_information_category
  ,      p.ppm_information1    = p_ppm_information1
  ,      p.ppm_information2    = p_ppm_information2
  ,      p.ppm_information3    = p_ppm_information3
  ,      p.ppm_information4    = p_ppm_information4
  ,      p.ppm_information5    = p_ppm_information5
  ,      p.ppm_information6    = p_ppm_information6
  ,      p.ppm_information7    = p_ppm_information7
  ,      p.ppm_information8    = p_ppm_information8
  ,      p.ppm_information9    = p_ppm_information9
  ,      p.ppm_information10   = p_ppm_information10
  ,      p.ppm_information11   = p_ppm_information11
  ,      p.ppm_information12   = p_ppm_information12
  ,      p.ppm_information13   = p_ppm_information13
  ,      p.ppm_information14   = p_ppm_information14
  ,      p.ppm_information15   = p_ppm_information15
  ,      p.ppm_information16   = p_ppm_information16
  ,      p.ppm_information17   = p_ppm_information17
  ,      p.ppm_information18   = p_ppm_information18
  ,      p.ppm_information19   = p_ppm_information19
  ,      p.ppm_information20   = p_ppm_information20
  ,      p.ppm_information21   = p_ppm_information21
  ,      p.ppm_information22   = p_ppm_information22
  ,      p.ppm_information23   = p_ppm_information23
  ,      p.ppm_information24   = p_ppm_information24
  ,      p.ppm_information25   = p_ppm_information25
  ,      p.ppm_information26   = p_ppm_information26
  ,      p.ppm_information27   = p_ppm_information27
  ,      p.ppm_information28   = p_ppm_information28
  ,      p.ppm_information29   = p_ppm_information29
  ,      p.ppm_information30   = p_ppm_information30
  ,      p.o_ppm_information_category = p_o_ppm_information_category
  ,      p.o_ppm_information1  = p_o_ppm_information1
  ,      p.o_ppm_information2  = p_o_ppm_information2
  ,      p.o_ppm_information3  = p_o_ppm_information3
  ,      p.o_ppm_information4  = p_o_ppm_information4
  ,      p.o_ppm_information5  = p_o_ppm_information5
  ,      p.o_ppm_information6  = p_o_ppm_information6
  ,      p.o_ppm_information7  = p_o_ppm_information7
  ,      p.o_ppm_information8  = p_o_ppm_information8
  ,      p.o_ppm_information9  = p_o_ppm_information9
  ,      p.o_ppm_information10 = p_o_ppm_information10
  ,      p.o_ppm_information11 = p_o_ppm_information11
  ,      p.o_ppm_information12 = p_o_ppm_information12
  ,      p.o_ppm_information13 = p_o_ppm_information13
  ,      p.o_ppm_information14 = p_o_ppm_information14
  ,      p.o_ppm_information15 = p_o_ppm_information15
  ,      p.o_ppm_information16 = p_o_ppm_information16
  ,      p.o_ppm_information17 = p_o_ppm_information17
  ,      p.o_ppm_information18 = p_o_ppm_information18
  ,      p.o_ppm_information19 = p_o_ppm_information19
  ,      p.o_ppm_information20 = p_o_ppm_information20
  ,      p.o_ppm_information21 = p_o_ppm_information21
  ,      p.o_ppm_information22 = p_o_ppm_information22
  ,      p.o_ppm_information23 = p_o_ppm_information23
  ,      p.o_ppm_information24 = p_o_ppm_information24
  ,      p.o_ppm_information25 = p_o_ppm_information25
  ,      p.o_ppm_information26 = p_o_ppm_information26
  ,      p.o_ppm_information27 = p_o_ppm_information27
  ,      p.o_ppm_information28 = p_o_ppm_information28
  ,      p.o_ppm_information29 = p_o_ppm_information29
  ,      p.o_ppm_information30 = p_o_ppm_information30
  where  p.transaction_step_id = p_transaction_step_id;
end update_row;
----------------------------------< delete_row >----------------------------
procedure delete_row
(p_transaction_step_id in number
) is
begin
  delete
  from  pay_pss_transaction_steps
  where transaction_step_id = p_transaction_step_id;
end delete_row;
---------------------------------< delete_rows >----------------------------
procedure delete_rows
(p_transaction_id in number
) is
begin
  delete
  from  pay_pss_transaction_steps
  where transaction_id = p_transaction_id;
end delete_rows;
--
end pay_pss_tx_steps_pkg;

/
