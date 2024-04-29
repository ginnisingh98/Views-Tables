--------------------------------------------------------
--  DDL for Package Body OTA_FINANCE_HEADER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FINANCE_HEADER_API" as
    /* $Header: ottfhapi.pkb 120.0 2005/05/29 07:40:55 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'OTA_FINANCE_HEADER_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_FINANCE_HEADER >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_FINANCE_HEADER
  (
  p_finance_header_id             out nocopy number,
  p_object_version_number         out nocopy number ,
  p_superceding_header_id        in number,
  p_authorizer_person_id         in number,
  p_organization_id              in number,
  p_administrator                in number,
  p_cancelled_flag               in varchar2,
  p_currency_code                in varchar2,
  p_date_raised                  in date,
  p_payment_status_flag          in varchar2,
  p_transfer_status              in varchar2,
  p_type                         in varchar2,
  p_receivable_type		   in varchar2,
  p_comments                     in varchar2,
  p_external_reference           in varchar2,
  p_invoice_address              in varchar2,
  p_invoice_contact              in varchar2,
  p_payment_method               in varchar2,
  p_pym_information_category     in varchar2,
  p_pym_attribute1               in varchar2,
  p_pym_attribute2               in varchar2,
  p_pym_attribute3               in varchar2,
  p_pym_attribute4               in varchar2,
  p_pym_attribute5               in varchar2,
  p_pym_attribute6               in varchar2,
  p_pym_attribute7               in varchar2,
  p_pym_attribute8               in varchar2,
  p_pym_attribute9               in varchar2,
  p_pym_attribute10              in varchar2,
  p_pym_attribute11              in varchar2,
  p_pym_attribute12              in varchar2,
  p_pym_attribute13              in varchar2,
  p_pym_attribute14              in varchar2,
  p_pym_attribute15              in varchar2,
  p_pym_attribute16              in varchar2,
  p_pym_attribute17              in varchar2,
  p_pym_attribute18              in varchar2,
  p_pym_attribute19              in varchar2,
  p_pym_attribute20              in varchar2,
  p_transfer_date                in date,
  p_transfer_message             in varchar2,
  p_vendor_id                    in number  ,
  p_contact_id                   in number  ,
  p_address_id                   in number  ,
  p_customer_id                  in number  ,
  p_tfh_information_category     in varchar2,
  p_tfh_information1             in varchar2,
  p_tfh_information2             in varchar2,
  p_tfh_information3             in varchar2,
  p_tfh_information4             in varchar2,
  p_tfh_information5             in varchar2,
  p_tfh_information6             in varchar2,
  p_tfh_information7             in varchar2,
  p_tfh_information8             in varchar2,
  p_tfh_information9             in varchar2,
  p_tfh_information10            in varchar2,
  p_tfh_information11            in varchar2,
  p_tfh_information12            in varchar2,
  p_tfh_information13            in varchar2,
  p_tfh_information14            in varchar2,
  p_tfh_information15            in varchar2,
  p_tfh_information16            in varchar2,
  p_tfh_information17            in varchar2,
  p_tfh_information18            in varchar2,
  p_tfh_information19            in varchar2,
  p_tfh_information20            in varchar2,
  p_paying_cost_center           in varchar2,
  p_receiving_cost_center        in varchar2,
  p_transfer_from_set_of_book_id   in number,
  p_transfer_to_set_of_book_id     in number,
  p_from_segment1                  in varchar2,
  p_from_segment2                  in varchar2,
  p_from_segment3                  in varchar2,
  p_from_segment4                  in varchar2,
  p_from_segment5                  in varchar2,
  p_from_segment6                  in varchar2,
  p_from_segment7                  in varchar2,
  p_from_segment8                  in varchar2,
  p_from_segment9                  in varchar2,
  p_from_segment10                 in varchar2,
  p_from_segment11                 in varchar2,
  p_from_segment12                 in varchar2,
  p_from_segment13                 in varchar2,
  p_from_segment14                 in varchar2,
  p_from_segment15                 in varchar2,
  p_from_segment16                 in varchar2,
  p_from_segment17                 in varchar2,
  p_from_segment18                 in varchar2,
  p_from_segment19                 in varchar2,
  p_from_segment20                 in varchar2,
  p_from_segment21                 in varchar2,
  p_from_segment22                 in varchar2,
  p_from_segment23                 in varchar2,
  p_from_segment24                 in varchar2,
  p_from_segment25                 in varchar2,
  p_from_segment26                 in varchar2,
  p_from_segment27                 in varchar2,
  p_from_segment28                 in varchar2,
  p_from_segment29                 in varchar2,
  p_from_segment30                 in varchar2,
  p_to_segment1                    in varchar2,
  p_to_segment2                    in varchar2,
  p_to_segment3                    in varchar2,
  p_to_segment4                    in varchar2,
  p_to_segment5                    in varchar2,
  p_to_segment6                    in varchar2,
  p_to_segment7                    in varchar2,
  p_to_segment8                    in varchar2,
  p_to_segment9                    in varchar2,
  p_to_segment10                   in varchar2,
  p_to_segment11                   in varchar2,
  p_to_segment12                   in varchar2,
  p_to_segment13                   in varchar2,
  p_to_segment14                   in varchar2,
  p_to_segment15                   in varchar2,
  p_to_segment16                   in varchar2,
  p_to_segment17                   in varchar2,
  p_to_segment18                   in varchar2,
  p_to_segment19                   in varchar2,
  p_to_segment20                   in varchar2,
  p_to_segment21                   in varchar2,
  p_to_segment22                   in varchar2,
  p_to_segment23                   in varchar2,
  p_to_segment24                   in varchar2,
  p_to_segment25                   in varchar2,
  p_to_segment26                   in varchar2,
  p_to_segment27                   in varchar2,
  p_to_segment28                   in varchar2,
  p_to_segment29                   in varchar2,
  p_to_segment30                   in varchar2,
  p_transfer_from_cc_id            in number,
  p_transfer_to_cc_id              in number,
  P_validate			   in boolean  default false,
  p_effective_date		   in date

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Training Plan';
  l_finance_header_id number;
  l_object_version_number   number;
  l_effective_date          date;
  l_name varchar2(80);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_FINANCE_HEADER;
  --
  -- Truncate the time portion from all IN date parameters
  --
 l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --

  begin
    OTA_FINANCE_HEADER_BK1.CREATE_FINANCE_HEADER_B
  (   P_superceding_header_id     =>  p_superceding_header_id
       ,P_authorizer_person_id      =>  p_authorizer_person_id
       ,P_organization_id           =>  p_organization_id
       ,P_administrator             =>  p_administrator
       ,P_cancelled_flag            =>  p_cancelled_flag
       ,P_currency_code             =>  p_currency_code
       ,P_date_raised               =>  p_date_raised
       ,P_payment_status_flag       =>  p_payment_status_flag
       ,P_transfer_status           =>  p_transfer_status
       ,P_type                      =>  p_type
       ,p_receivable_type	    =>  p_receivable_type
       ,P_comments                  =>  p_comments
       ,P_external_reference        =>  p_external_reference
       ,P_invoice_address           =>  p_invoice_address
       ,P_invoice_contact           =>  p_invoice_contact
       ,P_payment_method            =>  p_payment_method
       ,P_pym_attribute1            =>  p_pym_attribute1
       ,P_pym_attribute2            =>  p_pym_attribute2
       ,P_pym_attribute3            =>  p_pym_attribute3
       ,P_pym_attribute4            =>  p_pym_attribute4
       ,P_pym_attribute5            =>  p_pym_attribute5
       ,P_pym_attribute6            =>  p_pym_attribute6
       ,P_pym_attribute7            =>  p_pym_attribute7
       ,P_pym_attribute8            =>  p_pym_attribute8
       ,P_pym_attribute9            =>  p_pym_attribute9
       ,P_pym_attribute10           =>  p_pym_attribute10
       ,P_pym_attribute11           =>  p_pym_attribute11
       ,P_pym_attribute12           =>  p_pym_attribute12
       ,P_pym_attribute13           =>  p_pym_attribute13
       ,P_pym_attribute14           =>  p_pym_attribute14
       ,P_pym_attribute15           =>  p_pym_attribute15
       ,P_pym_attribute16           =>  p_pym_attribute16
       ,P_pym_attribute17           =>  p_pym_attribute17
       ,P_pym_attribute18           =>  p_pym_attribute18
       ,P_pym_attribute19           =>  p_pym_attribute19
       ,P_pym_attribute20           =>  p_pym_attribute20
       ,P_pym_information_category  =>  p_pym_information_category
       ,P_transfer_date             =>  p_transfer_date
       ,P_transfer_message          =>  p_transfer_message
       ,P_vendor_id                 =>  p_vendor_id
       ,P_contact_id                =>  p_contact_id
       ,P_address_id                =>  p_address_id
       ,P_customer_id               =>  p_customer_id
       ,P_tfh_information_category  =>  p_tfh_information_category
       ,P_tfh_information1          =>  p_tfh_information1
       ,P_tfh_information2          =>  p_tfh_information2
       ,P_tfh_information3          =>  p_tfh_information3
       ,P_tfh_information4          =>  p_tfh_information4
       ,P_tfh_information5          =>  p_tfh_information5
       ,P_tfh_information6          =>  p_tfh_information6
       ,P_tfh_information7          =>  p_tfh_information7
       ,P_tfh_information8          =>  p_tfh_information8
       ,P_tfh_information9          =>  p_tfh_information9
       ,P_tfh_information10         =>  p_tfh_information10
       ,P_tfh_information11         =>  p_tfh_information11
       ,P_tfh_information12         =>  p_tfh_information12
       ,P_tfh_information13         =>  p_tfh_information13
       ,P_tfh_information14         =>  p_tfh_information14
       ,P_tfh_information15         =>  p_tfh_information15
       ,P_tfh_information16         =>  p_tfh_information16
       ,P_tfh_information17         =>  p_tfh_information17
       ,P_tfh_information18         =>  p_tfh_information18
       ,P_tfh_information19         =>  p_tfh_information19
       ,P_tfh_information20         =>  p_tfh_information20
       ,P_paying_cost_center        =>  p_paying_cost_center
       ,P_receiving_cost_center     =>  p_receiving_cost_center
       ,p_transfer_from_set_of_book_id => p_transfer_from_set_of_book_id
       ,p_transfer_to_set_of_book_id => p_transfer_to_set_of_book_id
       ,p_from_segment1             =>  p_from_segment1
       ,p_from_segment2             =>  p_from_segment2
       ,p_from_segment3             =>  p_from_segment3
       ,p_from_segment4             =>  p_from_segment4
       ,p_from_segment5             =>  p_from_segment5
       ,p_from_segment6             =>  p_from_segment6
       ,p_from_segment7             =>  p_from_segment7
       ,p_from_segment8             =>  p_from_segment8
       ,p_from_segment9             =>  p_from_segment9
       ,p_from_segment10            =>  p_from_segment10
       ,p_from_segment11            =>  p_from_segment11
       ,p_from_segment12            =>  p_from_segment12
       ,p_from_segment13            =>  p_from_segment13
       ,p_from_segment14            =>  p_from_segment14
       ,p_from_segment15            =>  p_from_segment15
       ,p_from_segment16            =>  p_from_segment16
       ,p_from_segment17            =>  p_from_segment17
       ,p_from_segment18            =>  p_from_segment18
       ,p_from_segment19            =>  p_from_segment19
       ,p_from_segment20            =>  p_from_segment20
       ,p_from_segment21            =>  p_from_segment21
       ,p_from_segment22            =>  p_from_segment22
       ,p_from_segment23            =>  p_from_segment23
       ,p_from_segment24            =>  p_from_segment24
       ,p_from_segment25            =>  p_from_segment25
       ,p_from_segment26            =>  p_from_segment26
       ,p_from_segment27            =>  p_from_segment27
       ,p_from_segment28            =>  p_from_segment28
       ,p_from_segment29            =>  p_from_segment29
       ,p_from_segment30            =>  p_from_segment30
       ,p_to_segment1               =>  p_to_segment1
       ,p_to_segment2               =>  p_to_segment2
       ,p_to_segment3               =>  p_to_segment3
       ,p_to_segment4               =>  p_to_segment4
       ,p_to_segment5               =>  p_to_segment5
       ,p_to_segment6               =>  p_to_segment6
       ,p_to_segment7               =>  p_to_segment7
       ,p_to_segment8               =>  p_to_segment8
       ,p_to_segment9               =>  p_to_segment9
       ,p_to_segment10              =>  p_to_segment10
       ,p_to_segment11              =>  p_to_segment11
       ,p_to_segment12              =>  p_to_segment12
       ,p_to_segment13              =>  p_to_segment13
       ,p_to_segment14              =>  p_to_segment14
       ,p_to_segment15              =>  p_to_segment15
       ,p_to_segment16              =>  p_to_segment16
       ,p_to_segment17              =>  p_to_segment17
       ,p_to_segment18              =>  p_to_segment18
       ,p_to_segment19              =>  p_to_segment19
       ,p_to_segment20              =>  p_to_segment20
       ,p_to_segment21              =>  p_to_segment21
       ,p_to_segment22              =>  p_to_segment22
       ,p_to_segment23              =>  p_to_segment23
       ,p_to_segment24              =>  p_to_segment24
       ,p_to_segment25              =>  p_to_segment25
       ,p_to_segment26              =>  p_to_segment26
       ,p_to_segment27              =>  p_to_segment27
       ,p_to_segment28              =>  p_to_segment28
       ,p_to_segment29              =>  p_to_segment29
       ,p_to_segment30              =>  p_to_segment30
       ,p_transfer_from_cc_id       =>  p_transfer_from_cc_id
       ,p_transfer_to_cc_id         =>  p_transfer_to_cc_id
       ,p_effective_date                  =>  l_effective_date

   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FINANCE_HEADER'
        ,p_hook_type   => 'BP'
        );
  end;

     ota_tfh_api_ins.ins
       (
        P_finance_header_id         =>  p_finance_header_id
       ,P_object_version_number     =>  p_object_version_number
       ,P_superceding_header_id     =>  p_superceding_header_id
       ,P_authorizer_person_id      =>  p_authorizer_person_id
       ,P_organization_id           =>  p_organization_id
       ,P_administrator             =>  p_administrator
       ,P_cancelled_flag            =>  p_cancelled_flag
       ,P_currency_code             =>  p_currency_code
       ,P_date_raised               =>  p_date_raised
       ,P_payment_status_flag       =>  p_payment_status_flag
       ,P_transfer_status           =>  p_transfer_status
       ,P_type                      =>  p_type
       ,p_receivable_type	    =>  p_receivable_type
       ,P_comments                  =>  p_comments
       ,P_external_reference        =>  p_external_reference
       ,P_invoice_address           =>  p_invoice_address
       ,P_invoice_contact           =>  p_invoice_contact
       ,P_payment_method            =>  p_payment_method
       ,P_pym_attribute1            =>  p_pym_attribute1
       ,P_pym_attribute2            =>  p_pym_attribute2
       ,P_pym_attribute3            =>  p_pym_attribute3
       ,P_pym_attribute4            =>  p_pym_attribute4
       ,P_pym_attribute5            =>  p_pym_attribute5
       ,P_pym_attribute6            =>  p_pym_attribute6
       ,P_pym_attribute7            =>  p_pym_attribute7
       ,P_pym_attribute8            =>  p_pym_attribute8
       ,P_pym_attribute9            =>  p_pym_attribute9
       ,P_pym_attribute10           =>  p_pym_attribute10
       ,P_pym_attribute11           =>  p_pym_attribute11
       ,P_pym_attribute12           =>  p_pym_attribute12
       ,P_pym_attribute13           =>  p_pym_attribute13
       ,P_pym_attribute14           =>  p_pym_attribute14
       ,P_pym_attribute15           =>  p_pym_attribute15
       ,P_pym_attribute16           =>  p_pym_attribute16
       ,P_pym_attribute17           =>  p_pym_attribute17
       ,P_pym_attribute18           =>  p_pym_attribute18
       ,P_pym_attribute19           =>  p_pym_attribute19
       ,P_pym_attribute20           =>  p_pym_attribute20
       ,P_pym_information_category  =>  p_pym_information_category
       ,P_transfer_date             =>  p_transfer_date
       ,P_transfer_message          =>  p_transfer_message
       ,P_vendor_id                 =>  p_vendor_id
       ,P_contact_id                =>  p_contact_id
       ,P_address_id                =>  p_address_id
       ,P_customer_id               =>  p_customer_id
       ,P_tfh_information_category  =>  p_tfh_information_category
       ,P_tfh_information1          =>  p_tfh_information1
       ,P_tfh_information2          =>  p_tfh_information2
       ,P_tfh_information3          =>  p_tfh_information3
       ,P_tfh_information4          =>  p_tfh_information4
       ,P_tfh_information5          =>  p_tfh_information5
       ,P_tfh_information6          =>  p_tfh_information6
       ,P_tfh_information7          =>  p_tfh_information7
       ,P_tfh_information8          =>  p_tfh_information8
       ,P_tfh_information9          =>  p_tfh_information9
       ,P_tfh_information10         =>  p_tfh_information10
       ,P_tfh_information11         =>  p_tfh_information11
       ,P_tfh_information12         =>  p_tfh_information12
       ,P_tfh_information13         =>  p_tfh_information13
       ,P_tfh_information14         =>  p_tfh_information14
       ,P_tfh_information15         =>  p_tfh_information15
       ,P_tfh_information16         =>  p_tfh_information16
       ,P_tfh_information17         =>  p_tfh_information17
       ,P_tfh_information18         =>  p_tfh_information18
       ,P_tfh_information19         =>  p_tfh_information19
       ,P_tfh_information20         =>  p_tfh_information20
       ,P_paying_cost_center        =>  p_paying_cost_center
       ,P_receiving_cost_center     =>  p_receiving_cost_center
       ,p_transfer_from_set_of_book_id => p_transfer_from_set_of_book_id
       ,p_transfer_to_set_of_book_id => p_transfer_to_set_of_book_id
       ,p_from_segment1             =>  p_from_segment1
       ,p_from_segment2             =>  p_from_segment2
       ,p_from_segment3             =>  p_from_segment3
       ,p_from_segment4             =>  p_from_segment4
       ,p_from_segment5             =>  p_from_segment5
       ,p_from_segment6             =>  p_from_segment6
       ,p_from_segment7             =>  p_from_segment7
       ,p_from_segment8             =>  p_from_segment8
       ,p_from_segment9             =>  p_from_segment9
       ,p_from_segment10            =>  p_from_segment10
       ,p_from_segment11            =>  p_from_segment11
       ,p_from_segment12            =>  p_from_segment12
       ,p_from_segment13            =>  p_from_segment13
       ,p_from_segment14            =>  p_from_segment14
       ,p_from_segment15            =>  p_from_segment15
       ,p_from_segment16            =>  p_from_segment16
       ,p_from_segment17            =>  p_from_segment17
       ,p_from_segment18            =>  p_from_segment18
       ,p_from_segment19            =>  p_from_segment19
       ,p_from_segment20            =>  p_from_segment20
       ,p_from_segment21            =>  p_from_segment21
       ,p_from_segment22            =>  p_from_segment22
       ,p_from_segment23            =>  p_from_segment23
       ,p_from_segment24            =>  p_from_segment24
       ,p_from_segment25            =>  p_from_segment25
       ,p_from_segment26            =>  p_from_segment26
       ,p_from_segment27            =>  p_from_segment27
       ,p_from_segment28            =>  p_from_segment28
       ,p_from_segment29            =>  p_from_segment29
       ,p_from_segment30            =>  p_from_segment30
       ,p_to_segment1               =>  p_to_segment1
       ,p_to_segment2               =>  p_to_segment2
       ,p_to_segment3               =>  p_to_segment3
       ,p_to_segment4               =>  p_to_segment4
       ,p_to_segment5               =>  p_to_segment5
       ,p_to_segment6               =>  p_to_segment6
       ,p_to_segment7               =>  p_to_segment7
       ,p_to_segment8               =>  p_to_segment8
       ,p_to_segment9               =>  p_to_segment9
       ,p_to_segment10              =>  p_to_segment10
       ,p_to_segment11              =>  p_to_segment11
       ,p_to_segment12              =>  p_to_segment12
       ,p_to_segment13              =>  p_to_segment13
       ,p_to_segment14              =>  p_to_segment14
       ,p_to_segment15              =>  p_to_segment15
       ,p_to_segment16              =>  p_to_segment16
       ,p_to_segment17              =>  p_to_segment17
       ,p_to_segment18              =>  p_to_segment18
       ,p_to_segment19              =>  p_to_segment19
       ,p_to_segment20              =>  p_to_segment20
       ,p_to_segment21              =>  p_to_segment21
       ,p_to_segment22              =>  p_to_segment22
       ,p_to_segment23              =>  p_to_segment23
       ,p_to_segment24              =>  p_to_segment24
       ,p_to_segment25              =>  p_to_segment25
       ,p_to_segment26              =>  p_to_segment26
       ,p_to_segment27              =>  p_to_segment27
       ,p_to_segment28              =>  p_to_segment28
       ,p_to_segment29              =>  p_to_segment29
       ,p_to_segment30              =>  p_to_segment30
       ,p_transfer_from_cc_id       =>  p_transfer_from_cc_id
       ,p_transfer_to_cc_id         =>  p_transfer_to_cc_id
       ,p_validate                  =>  false
       ,P_transaction_type          =>  'INSERT'
);

  --
  -- Call After Process User Hook
  --

  begin
  OTA_FINANCE_HEADER_BK1.CREATE_FINANCE_HEADER_A
  (
        P_finance_header_id         =>  p_finance_header_id
       ,P_object_version_number     =>  p_object_version_number
       ,P_superceding_header_id     =>  p_superceding_header_id
       ,P_authorizer_person_id      =>  p_authorizer_person_id
       ,P_organization_id           =>  p_organization_id
       ,P_administrator             =>  p_administrator
       ,P_cancelled_flag            =>  p_cancelled_flag
       ,P_currency_code             =>  p_currency_code
       ,P_date_raised               =>  p_date_raised
       ,P_payment_status_flag       =>  p_payment_status_flag
       ,P_transfer_status           =>  p_transfer_status
       ,P_type                      =>  p_type
       ,p_receivable_type	    =>  p_receivable_type
       ,P_comments                  =>  p_comments
       ,P_external_reference        =>  p_external_reference
       ,P_invoice_address           =>  p_invoice_address
       ,P_invoice_contact           =>  p_invoice_contact
       ,P_payment_method            =>  p_payment_method
       ,P_pym_attribute1            =>  p_pym_attribute1
       ,P_pym_attribute2            =>  p_pym_attribute2
       ,P_pym_attribute3            =>  p_pym_attribute3
       ,P_pym_attribute4            =>  p_pym_attribute4
       ,P_pym_attribute5            =>  p_pym_attribute5
       ,P_pym_attribute6            =>  p_pym_attribute6
       ,P_pym_attribute7            =>  p_pym_attribute7
       ,P_pym_attribute8            =>  p_pym_attribute8
       ,P_pym_attribute9            =>  p_pym_attribute9
       ,P_pym_attribute10           =>  p_pym_attribute10
       ,P_pym_attribute11           =>  p_pym_attribute11
       ,P_pym_attribute12           =>  p_pym_attribute12
       ,P_pym_attribute13           =>  p_pym_attribute13
       ,P_pym_attribute14           =>  p_pym_attribute14
       ,P_pym_attribute15           =>  p_pym_attribute15
       ,P_pym_attribute16           =>  p_pym_attribute16
       ,P_pym_attribute17           =>  p_pym_attribute17
       ,P_pym_attribute18           =>  p_pym_attribute18
       ,P_pym_attribute19           =>  p_pym_attribute19
       ,P_pym_attribute20           =>  p_pym_attribute20
       ,P_pym_information_category  =>  p_pym_information_category
       ,P_transfer_date             =>  p_transfer_date
       ,P_transfer_message          =>  p_transfer_message
       ,P_vendor_id                 =>  p_vendor_id
       ,P_contact_id                =>  p_contact_id
       ,P_address_id                =>  p_address_id
       ,P_customer_id               =>  p_customer_id
       ,P_tfh_information_category  =>  p_tfh_information_category
       ,P_tfh_information1          =>  p_tfh_information1
       ,P_tfh_information2          =>  p_tfh_information2
       ,P_tfh_information3          =>  p_tfh_information3
       ,P_tfh_information4          =>  p_tfh_information4
       ,P_tfh_information5          =>  p_tfh_information5
       ,P_tfh_information6          =>  p_tfh_information6
       ,P_tfh_information7          =>  p_tfh_information7
       ,P_tfh_information8          =>  p_tfh_information8
       ,P_tfh_information9          =>  p_tfh_information9
       ,P_tfh_information10         =>  p_tfh_information10
       ,P_tfh_information11         =>  p_tfh_information11
       ,P_tfh_information12         =>  p_tfh_information12
       ,P_tfh_information13         =>  p_tfh_information13
       ,P_tfh_information14         =>  p_tfh_information14
       ,P_tfh_information15         =>  p_tfh_information15
       ,P_tfh_information16         =>  p_tfh_information16
       ,P_tfh_information17         =>  p_tfh_information17
       ,P_tfh_information18         =>  p_tfh_information18
       ,P_tfh_information19         =>  p_tfh_information19
       ,P_tfh_information20         =>  p_tfh_information20
       ,P_paying_cost_center        =>  p_paying_cost_center
       ,P_receiving_cost_center     =>  p_receiving_cost_center
       ,p_transfer_from_set_of_book_id => p_transfer_from_set_of_book_id
       ,p_transfer_to_set_of_book_id => p_transfer_to_set_of_book_id
       ,p_from_segment1             =>  p_from_segment1
       ,p_from_segment2             =>  p_from_segment2
       ,p_from_segment3             =>  p_from_segment3
       ,p_from_segment4             =>  p_from_segment4
       ,p_from_segment5             =>  p_from_segment5
       ,p_from_segment6             =>  p_from_segment6
       ,p_from_segment7             =>  p_from_segment7
       ,p_from_segment8             =>  p_from_segment8
       ,p_from_segment9             =>  p_from_segment9
       ,p_from_segment10            =>  p_from_segment10
       ,p_from_segment11            =>  p_from_segment11
       ,p_from_segment12            =>  p_from_segment12
       ,p_from_segment13            =>  p_from_segment13
       ,p_from_segment14            =>  p_from_segment14
       ,p_from_segment15            =>  p_from_segment15
       ,p_from_segment16            =>  p_from_segment16
       ,p_from_segment17            =>  p_from_segment17
       ,p_from_segment18            =>  p_from_segment18
       ,p_from_segment19            =>  p_from_segment19
       ,p_from_segment20            =>  p_from_segment20
       ,p_from_segment21            =>  p_from_segment21
       ,p_from_segment22            =>  p_from_segment22
       ,p_from_segment23            =>  p_from_segment23
       ,p_from_segment24            =>  p_from_segment24
       ,p_from_segment25            =>  p_from_segment25
       ,p_from_segment26            =>  p_from_segment26
       ,p_from_segment27            =>  p_from_segment27
       ,p_from_segment28            =>  p_from_segment28
       ,p_from_segment29            =>  p_from_segment29
       ,p_from_segment30            =>  p_from_segment30
       ,p_to_segment1               =>  p_to_segment1
       ,p_to_segment2               =>  p_to_segment2
       ,p_to_segment3               =>  p_to_segment3
       ,p_to_segment4               =>  p_to_segment4
       ,p_to_segment5               =>  p_to_segment5
       ,p_to_segment6               =>  p_to_segment6
       ,p_to_segment7               =>  p_to_segment7
       ,p_to_segment8               =>  p_to_segment8
       ,p_to_segment9               =>  p_to_segment9
       ,p_to_segment10              =>  p_to_segment10
       ,p_to_segment11              =>  p_to_segment11
       ,p_to_segment12              =>  p_to_segment12
       ,p_to_segment13              =>  p_to_segment13
       ,p_to_segment14              =>  p_to_segment14
       ,p_to_segment15              =>  p_to_segment15
       ,p_to_segment16              =>  p_to_segment16
       ,p_to_segment17              =>  p_to_segment17
       ,p_to_segment18              =>  p_to_segment18
       ,p_to_segment19              =>  p_to_segment19
       ,p_to_segment20              =>  p_to_segment20
       ,p_to_segment21              =>  p_to_segment21
       ,p_to_segment22              =>  p_to_segment22
       ,p_to_segment23              =>  p_to_segment23
       ,p_to_segment24              =>  p_to_segment24
       ,p_to_segment25              =>  p_to_segment25
       ,p_to_segment26              =>  p_to_segment26
       ,p_to_segment27              =>  p_to_segment27
       ,p_to_segment28              =>  p_to_segment28
       ,p_to_segment29              =>  p_to_segment29
       ,p_to_segment30              =>  p_to_segment30
       ,p_transfer_from_cc_id       =>  p_transfer_from_cc_id
       ,p_transfer_to_cc_id         =>  p_transfer_to_cc_id
       ,p_effective_date                  =>  l_effective_date




  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FINANCE_HEADER'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_finance_header_id        := l_finance_header_id;
  p_object_version_number   := l_object_version_number;


  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_FINANCE_HEADER;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_finance_header_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_FINANCE_HEADER;
    p_finance_header_id        := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_FINANCE_HEADER;
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_FINANCE_HEADER >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_FINANCE_HEADER
  (
  p_finance_header_id            in number,
  p_object_version_number        in out nocopy number ,
  p_new_object_version_number    out nocopy number,
  p_superceding_header_id        in number  ,
  p_authorizer_person_id         in number  ,
  p_organization_id              in number,
  p_administrator                in number,
  p_cancelled_flag               in varchar2,
  p_currency_code                in varchar2,
  p_date_raised                  in date,
  p_payment_status_flag          in varchar2,
  p_transfer_status              in varchar2,
  p_type                         in varchar2,
  p_receivable_type		   in varchar2,
  p_comments                     in varchar2,
  p_external_reference           in varchar2,
  p_invoice_address              in varchar2,
  p_invoice_contact              in varchar2,
  p_payment_method               in varchar2,
  p_pym_information_category     in varchar2,
  p_pym_attribute1               in varchar2,
  p_pym_attribute2               in varchar2,
  p_pym_attribute3               in varchar2,
  p_pym_attribute4               in varchar2,
  p_pym_attribute5               in varchar2,
  p_pym_attribute6               in varchar2,
  p_pym_attribute7               in varchar2,
  p_pym_attribute8               in varchar2,
  p_pym_attribute9               in varchar2,
  p_pym_attribute10              in varchar2,
  p_pym_attribute11              in varchar2,
  p_pym_attribute12              in varchar2,
  p_pym_attribute13              in varchar2,
  p_pym_attribute14              in varchar2,
  p_pym_attribute15              in varchar2,
  p_pym_attribute16              in varchar2,
  p_pym_attribute17              in varchar2,
  p_pym_attribute18              in varchar2,
  p_pym_attribute19              in varchar2,
  p_pym_attribute20              in varchar2,
  p_transfer_date                in date ,
  p_transfer_message             in varchar2,
  p_vendor_id                    in number  ,
  p_contact_id                   in number  ,
  p_address_id                   in number  ,
  p_customer_id                  in number  ,
  p_tfh_information_category     in varchar2,
  p_tfh_information1             in varchar2,
  p_tfh_information2             in varchar2,
  p_tfh_information3             in varchar2,
  p_tfh_information4             in varchar2,
  p_tfh_information5             in varchar2,
  p_tfh_information6             in varchar2,
  p_tfh_information7             in varchar2,
  p_tfh_information8             in varchar2,
  p_tfh_information9             in varchar2,
  p_tfh_information10            in varchar2,
  p_tfh_information11            in varchar2,
  p_tfh_information12            in varchar2,
  p_tfh_information13            in varchar2,
  p_tfh_information14            in varchar2,
  p_tfh_information15            in varchar2,
  p_tfh_information16            in varchar2,
  p_tfh_information17            in varchar2,
  p_tfh_information18            in varchar2,
  p_tfh_information19            in varchar2,
  p_tfh_information20            in varchar2,
  p_paying_cost_center           in varchar2,
  p_receiving_cost_center        in varchar2,
  p_transfer_from_set_of_book_id   in number,
  p_transfer_to_set_of_book_id     in number,
  p_from_segment1                  in varchar2,
  p_from_segment2                  in varchar2,
  p_from_segment3                  in varchar2,
  p_from_segment4                  in varchar2,
  p_from_segment5                  in varchar2,
  p_from_segment6                  in varchar2,
  p_from_segment7                  in varchar2,
  p_from_segment8                  in varchar2,
  p_from_segment9                  in varchar2,
  p_from_segment10                 in varchar2,
  p_from_segment11                 in varchar2,
  p_from_segment12                 in varchar2,
  p_from_segment13                 in varchar2,
  p_from_segment14                 in varchar2,
  p_from_segment15                 in varchar2,
  p_from_segment16                 in varchar2,
  p_from_segment17                 in varchar2,
  p_from_segment18                 in varchar2,
  p_from_segment19                 in varchar2,
  p_from_segment20                 in varchar2,
  p_from_segment21                 in varchar2,
  p_from_segment22                 in varchar2,
  p_from_segment23                 in varchar2,
  p_from_segment24                 in varchar2,
  p_from_segment25                 in varchar2,
  p_from_segment26                 in varchar2,
  p_from_segment27                 in varchar2,
  p_from_segment28                 in varchar2,
  p_from_segment29                 in varchar2,
  p_from_segment30                 in varchar2,
  p_to_segment1                    in varchar2,
  p_to_segment2                    in varchar2,
  p_to_segment3                    in varchar2,
  p_to_segment4                    in varchar2,
  p_to_segment5                    in varchar2,
  p_to_segment6                    in varchar2,
  p_to_segment7                    in varchar2,
  p_to_segment8                    in varchar2,
  p_to_segment9                    in varchar2,
  p_to_segment10                   in varchar2,
  p_to_segment11                   in varchar2,
  p_to_segment12                   in varchar2,
  p_to_segment13                   in varchar2,
  p_to_segment14                   in varchar2,
  p_to_segment15                   in varchar2,
  p_to_segment16                   in varchar2,
  p_to_segment17                   in varchar2,
  p_to_segment18                   in varchar2,
  p_to_segment19                   in varchar2,
  p_to_segment20                   in varchar2,
  p_to_segment21                   in varchar2,
  p_to_segment22                   in varchar2,
  p_to_segment23                   in varchar2,
  p_to_segment24                   in varchar2,
  p_to_segment25                   in varchar2,
  p_to_segment26                   in varchar2,
  p_to_segment27                   in varchar2,
  p_to_segment28                   in varchar2,
  p_to_segment29                   in varchar2,
  p_to_segment30                   in varchar2,
  p_transfer_from_cc_id            in number,
  p_transfer_to_cc_id              in number,
  P_validate			   in boolean  default false,
  p_effective_date		   in date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Training Plan';
  l_effective_date          date;
  l_object_version_number   number := p_object_version_number;
  l_name varchar2(80);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_FINANCE_HEADER;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --

  begin
    OTA_FINANCE_HEADER_BK2.UPDATE_FINANCE_HEADER_B
  (         P_finance_header_id         =>  p_finance_header_id
       ,P_object_version_number     =>  l_object_version_number
       ,P_superceding_header_id     =>  p_superceding_header_id
       ,P_authorizer_person_id      =>  p_authorizer_person_id
       ,P_organization_id           =>  p_organization_id
       ,P_administrator             =>  p_administrator
       ,P_cancelled_flag            =>  p_cancelled_flag
       ,P_currency_code             =>  p_currency_code
       ,P_date_raised               =>  p_date_raised
       ,P_payment_status_flag       =>  p_payment_status_flag
       ,P_transfer_status           =>  p_transfer_status
       ,P_type                      =>  p_type
       ,p_receivable_type	    =>  p_receivable_type
       ,P_comments                  =>  p_comments
       ,P_external_reference        =>  p_external_reference
       ,P_invoice_address           =>  p_invoice_address
       ,P_invoice_contact           =>  p_invoice_contact
       ,P_payment_method            =>  p_payment_method
       ,P_pym_attribute1            =>  p_pym_attribute1
       ,P_pym_attribute2            =>  p_pym_attribute2
       ,P_pym_attribute3            =>  p_pym_attribute3
       ,P_pym_attribute4            =>  p_pym_attribute4
       ,P_pym_attribute5            =>  p_pym_attribute5
       ,P_pym_attribute6            =>  p_pym_attribute6
       ,P_pym_attribute7            =>  p_pym_attribute7
       ,P_pym_attribute8            =>  p_pym_attribute8
       ,P_pym_attribute9            =>  p_pym_attribute9
       ,P_pym_attribute10           =>  p_pym_attribute10
       ,P_pym_attribute11           =>  p_pym_attribute11
       ,P_pym_attribute12           =>  p_pym_attribute12
       ,P_pym_attribute13           =>  p_pym_attribute13
       ,P_pym_attribute14           =>  p_pym_attribute14
       ,P_pym_attribute15           =>  p_pym_attribute15
       ,P_pym_attribute16           =>  p_pym_attribute16
       ,P_pym_attribute17           =>  p_pym_attribute17
       ,P_pym_attribute18           =>  p_pym_attribute18
       ,P_pym_attribute19           =>  p_pym_attribute19
       ,P_pym_attribute20           =>  p_pym_attribute20
       ,P_pym_information_category  =>  p_pym_information_category
       ,P_transfer_date             =>  p_transfer_date
       ,P_transfer_message          =>  p_transfer_message
       ,P_vendor_id                 =>  p_vendor_id
       ,P_contact_id                =>  p_contact_id
       ,P_address_id                =>  p_address_id
       ,P_customer_id               =>  p_customer_id
       ,P_tfh_information_category  =>  p_tfh_information_category
       ,P_tfh_information1          =>  p_tfh_information1
       ,P_tfh_information2          =>  p_tfh_information2
       ,P_tfh_information3          =>  p_tfh_information3
       ,P_tfh_information4          =>  p_tfh_information4
       ,P_tfh_information5          =>  p_tfh_information5
       ,P_tfh_information6          =>  p_tfh_information6
       ,P_tfh_information7          =>  p_tfh_information7
       ,P_tfh_information8          =>  p_tfh_information8
       ,P_tfh_information9          =>  p_tfh_information9
       ,P_tfh_information10         =>  p_tfh_information10
       ,P_tfh_information11         =>  p_tfh_information11
       ,P_tfh_information12         =>  p_tfh_information12
       ,P_tfh_information13         =>  p_tfh_information13
       ,P_tfh_information14         =>  p_tfh_information14
       ,P_tfh_information15         =>  p_tfh_information15
       ,P_tfh_information16         =>  p_tfh_information16
       ,P_tfh_information17         =>  p_tfh_information17
       ,P_tfh_information18         =>  p_tfh_information18
       ,P_tfh_information19         =>  p_tfh_information19
       ,P_tfh_information20         =>  p_tfh_information20
       ,P_paying_cost_center        =>  p_paying_cost_center
       ,P_receiving_cost_center     =>  p_receiving_cost_center
       ,p_transfer_from_set_of_book_id => p_transfer_from_set_of_book_id
       ,p_transfer_to_set_of_book_id => p_transfer_to_set_of_book_id
       ,p_from_segment1             =>  p_from_segment1
       ,p_from_segment2             =>  p_from_segment2
       ,p_from_segment3             =>  p_from_segment3
       ,p_from_segment4             =>  p_from_segment4
       ,p_from_segment5             =>  p_from_segment5
       ,p_from_segment6             =>  p_from_segment6
       ,p_from_segment7             =>  p_from_segment7
       ,p_from_segment8             =>  p_from_segment8
       ,p_from_segment9             =>  p_from_segment9
       ,p_from_segment10            =>  p_from_segment10
       ,p_from_segment11            =>  p_from_segment11
       ,p_from_segment12            =>  p_from_segment12
       ,p_from_segment13            =>  p_from_segment13
       ,p_from_segment14            =>  p_from_segment14
       ,p_from_segment15            =>  p_from_segment15
       ,p_from_segment16            =>  p_from_segment16
       ,p_from_segment17            =>  p_from_segment17
       ,p_from_segment18            =>  p_from_segment18
       ,p_from_segment19            =>  p_from_segment19
       ,p_from_segment20            =>  p_from_segment20
       ,p_from_segment21            =>  p_from_segment21
       ,p_from_segment22            =>  p_from_segment22
       ,p_from_segment23            =>  p_from_segment23
       ,p_from_segment24            =>  p_from_segment24
       ,p_from_segment25            =>  p_from_segment25
       ,p_from_segment26            =>  p_from_segment26
       ,p_from_segment27            =>  p_from_segment27
       ,p_from_segment28            =>  p_from_segment28
       ,p_from_segment29            =>  p_from_segment29
       ,p_from_segment30            =>  p_from_segment30
       ,p_to_segment1               =>  p_to_segment1
       ,p_to_segment2               =>  p_to_segment2
       ,p_to_segment3               =>  p_to_segment3
       ,p_to_segment4               =>  p_to_segment4
       ,p_to_segment5               =>  p_to_segment5
       ,p_to_segment6               =>  p_to_segment6
       ,p_to_segment7               =>  p_to_segment7
       ,p_to_segment8               =>  p_to_segment8
       ,p_to_segment9               =>  p_to_segment9
       ,p_to_segment10              =>  p_to_segment10
       ,p_to_segment11              =>  p_to_segment11
       ,p_to_segment12              =>  p_to_segment12
       ,p_to_segment13              =>  p_to_segment13
       ,p_to_segment14              =>  p_to_segment14
       ,p_to_segment15              =>  p_to_segment15
       ,p_to_segment16              =>  p_to_segment16
       ,p_to_segment17              =>  p_to_segment17
       ,p_to_segment18              =>  p_to_segment18
       ,p_to_segment19              =>  p_to_segment19
       ,p_to_segment20              =>  p_to_segment20
       ,p_to_segment21              =>  p_to_segment21
       ,p_to_segment22              =>  p_to_segment22
       ,p_to_segment23              =>  p_to_segment23
       ,p_to_segment24              =>  p_to_segment24
       ,p_to_segment25              =>  p_to_segment25
       ,p_to_segment26              =>  p_to_segment26
       ,p_to_segment27              =>  p_to_segment27
       ,p_to_segment28              =>  p_to_segment28
       ,p_to_segment29              =>  p_to_segment29
       ,p_to_segment30              =>  p_to_segment30
       ,p_transfer_from_cc_id       =>  p_transfer_from_cc_id
       ,p_transfer_to_cc_id         =>  p_transfer_to_cc_id
       ,p_effective_date                  =>  l_effective_date


  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FINANCE_HEADER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
    ota_tfh_api_upd.Upd

       (
        P_finance_header_id         =>  p_finance_header_id
       ,P_object_version_number     =>  l_object_version_number
       ,P_superceding_header_id     =>  p_superceding_header_id
       ,P_authorizer_person_id      =>  p_authorizer_person_id
       ,P_organization_id           =>  p_organization_id
       ,P_administrator             =>  p_administrator
       ,P_cancelled_flag            =>  p_cancelled_flag
       ,P_currency_code             =>  p_currency_code
       ,P_date_raised               =>  p_date_raised
       ,P_payment_status_flag       =>  p_payment_status_flag
       ,P_transfer_status           =>  p_transfer_status
       ,P_type                      =>  p_type
       ,p_receivable_type	    =>  p_receivable_type
       ,P_comments                  =>  p_comments
       ,P_external_reference        =>  p_external_reference
       ,P_invoice_address           =>  p_invoice_address
       ,P_invoice_contact           =>  p_invoice_contact
       ,P_payment_method            =>  p_payment_method
       ,P_pym_attribute1            =>  p_pym_attribute1
       ,P_pym_attribute2            =>  p_pym_attribute2
       ,P_pym_attribute3            =>  p_pym_attribute3
       ,P_pym_attribute4            =>  p_pym_attribute4
       ,P_pym_attribute5            =>  p_pym_attribute5
       ,P_pym_attribute6            =>  p_pym_attribute6
       ,P_pym_attribute7            =>  p_pym_attribute7
       ,P_pym_attribute8            =>  p_pym_attribute8
       ,P_pym_attribute9            =>  p_pym_attribute9
       ,P_pym_attribute10           =>  p_pym_attribute10
       ,P_pym_attribute11           =>  p_pym_attribute11
       ,P_pym_attribute12           =>  p_pym_attribute12
       ,P_pym_attribute13           =>  p_pym_attribute13
       ,P_pym_attribute14           =>  p_pym_attribute14
       ,P_pym_attribute15           =>  p_pym_attribute15
       ,P_pym_attribute16           =>  p_pym_attribute16
       ,P_pym_attribute17           =>  p_pym_attribute17
       ,P_pym_attribute18           =>  p_pym_attribute18
       ,P_pym_attribute19           =>  p_pym_attribute19
       ,P_pym_attribute20           =>  p_pym_attribute20
       ,P_pym_information_category  =>  p_pym_information_category
       ,P_transfer_date             =>  p_transfer_date
       ,P_transfer_message          =>  p_transfer_message
       ,P_vendor_id                 =>  p_vendor_id
       ,P_contact_id                =>  p_contact_id
       ,P_address_id                =>  p_address_id
       ,P_customer_id               =>  p_customer_id
       ,P_tfh_information_category  =>  p_tfh_information_category
       ,P_tfh_information1          =>  p_tfh_information1
       ,P_tfh_information2          =>  p_tfh_information2
       ,P_tfh_information3          =>  p_tfh_information3
       ,P_tfh_information4          =>  p_tfh_information4
       ,P_tfh_information5          =>  p_tfh_information5
       ,P_tfh_information6          =>  p_tfh_information6
       ,P_tfh_information7          =>  p_tfh_information7
       ,P_tfh_information8          =>  p_tfh_information8
       ,P_tfh_information9          =>  p_tfh_information9
       ,P_tfh_information10         =>  p_tfh_information10
       ,P_tfh_information11         =>  p_tfh_information11
       ,P_tfh_information12         =>  p_tfh_information12
       ,P_tfh_information13         =>  p_tfh_information13
       ,P_tfh_information14         =>  p_tfh_information14
       ,P_tfh_information15         =>  p_tfh_information15
       ,P_tfh_information16         =>  p_tfh_information16
       ,P_tfh_information17         =>  p_tfh_information17
       ,P_tfh_information18         =>  p_tfh_information18
       ,P_tfh_information19         =>  p_tfh_information19
       ,P_tfh_information20         =>  p_tfh_information20
       ,P_paying_cost_center        =>  p_paying_cost_center
       ,P_receiving_cost_center     =>  p_receiving_cost_center
       ,p_transfer_from_set_of_book_id => p_transfer_from_set_of_book_id
       ,p_transfer_to_set_of_book_id => p_transfer_to_set_of_book_id
       ,p_from_segment1             =>  p_from_segment1
       ,p_from_segment2             =>  p_from_segment2
       ,p_from_segment3             =>  p_from_segment3
       ,p_from_segment4             =>  p_from_segment4
       ,p_from_segment5             =>  p_from_segment5
       ,p_from_segment6             =>  p_from_segment6
       ,p_from_segment7             =>  p_from_segment7
       ,p_from_segment8             =>  p_from_segment8
       ,p_from_segment9             =>  p_from_segment9
       ,p_from_segment10            =>  p_from_segment10
       ,p_from_segment11            =>  p_from_segment11
       ,p_from_segment12            =>  p_from_segment12
       ,p_from_segment13            =>  p_from_segment13
       ,p_from_segment14            =>  p_from_segment14
       ,p_from_segment15            =>  p_from_segment15
       ,p_from_segment16            =>  p_from_segment16
       ,p_from_segment17            =>  p_from_segment17
       ,p_from_segment18            =>  p_from_segment18
       ,p_from_segment19            =>  p_from_segment19
       ,p_from_segment20            =>  p_from_segment20
       ,p_from_segment21            =>  p_from_segment21
       ,p_from_segment22            =>  p_from_segment22
       ,p_from_segment23            =>  p_from_segment23
       ,p_from_segment24            =>  p_from_segment24
       ,p_from_segment25            =>  p_from_segment25
       ,p_from_segment26            =>  p_from_segment26
       ,p_from_segment27            =>  p_from_segment27
       ,p_from_segment28            =>  p_from_segment28
       ,p_from_segment29            =>  p_from_segment29
       ,p_from_segment30            =>  p_from_segment30
       ,p_to_segment1               =>  p_to_segment1
       ,p_to_segment2               =>  p_to_segment2
       ,p_to_segment3               =>  p_to_segment3
       ,p_to_segment4               =>  p_to_segment4
       ,p_to_segment5               =>  p_to_segment5
       ,p_to_segment6               =>  p_to_segment6
       ,p_to_segment7               =>  p_to_segment7
       ,p_to_segment8               =>  p_to_segment8
       ,p_to_segment9               =>  p_to_segment9
       ,p_to_segment10              =>  p_to_segment10
       ,p_to_segment11              =>  p_to_segment11
       ,p_to_segment12              =>  p_to_segment12
       ,p_to_segment13              =>  p_to_segment13
       ,p_to_segment14              =>  p_to_segment14
       ,p_to_segment15              =>  p_to_segment15
       ,p_to_segment16              =>  p_to_segment16
       ,p_to_segment17              =>  p_to_segment17
       ,p_to_segment18              =>  p_to_segment18
       ,p_to_segment19              =>  p_to_segment19
       ,p_to_segment20              =>  p_to_segment20
       ,p_to_segment21              =>  p_to_segment21
       ,p_to_segment22              =>  p_to_segment22
       ,p_to_segment23              =>  p_to_segment23
       ,p_to_segment24              =>  p_to_segment24
       ,p_to_segment25              =>  p_to_segment25
       ,p_to_segment26              =>  p_to_segment26
       ,p_to_segment27              =>  p_to_segment27
       ,p_to_segment28              =>  p_to_segment28
       ,p_to_segment29              =>  p_to_segment29
       ,p_to_segment30              =>  p_to_segment30
       ,p_transfer_from_cc_id       =>  p_transfer_from_cc_id
       ,p_transfer_to_cc_id         =>  p_transfer_to_cc_id
       ,P_validate                  =>  false

       ,P_transaction_type          =>  'UPDATE'
       );

  begin
  OTA_FINANCE_HEADER_BK2.UPDATE_FINANCE_HEADER_A
  (         P_finance_header_id         =>  p_finance_header_id
       ,P_object_version_number     =>  l_object_version_number
       ,P_superceding_header_id     =>  p_superceding_header_id
       ,P_authorizer_person_id      =>  p_authorizer_person_id
       ,P_organization_id           =>  p_organization_id
       ,P_administrator             =>  p_administrator
       ,P_cancelled_flag            =>  p_cancelled_flag
       ,P_currency_code             =>  p_currency_code
       ,P_date_raised               =>  p_date_raised
       ,P_payment_status_flag       =>  p_payment_status_flag
       ,P_transfer_status           =>  p_transfer_status
       ,P_type                      =>  p_type
       ,p_receivable_type	    =>  p_receivable_type
       ,P_comments                  =>  p_comments
       ,P_external_reference        =>  p_external_reference
       ,P_invoice_address           =>  p_invoice_address
       ,P_invoice_contact           =>  p_invoice_contact
       ,P_payment_method            =>  p_payment_method
       ,P_pym_attribute1            =>  p_pym_attribute1
       ,P_pym_attribute2            =>  p_pym_attribute2
       ,P_pym_attribute3            =>  p_pym_attribute3
       ,P_pym_attribute4            =>  p_pym_attribute4
       ,P_pym_attribute5            =>  p_pym_attribute5
       ,P_pym_attribute6            =>  p_pym_attribute6
       ,P_pym_attribute7            =>  p_pym_attribute7
       ,P_pym_attribute8            =>  p_pym_attribute8
       ,P_pym_attribute9            =>  p_pym_attribute9
       ,P_pym_attribute10           =>  p_pym_attribute10
       ,P_pym_attribute11           =>  p_pym_attribute11
       ,P_pym_attribute12           =>  p_pym_attribute12
       ,P_pym_attribute13           =>  p_pym_attribute13
       ,P_pym_attribute14           =>  p_pym_attribute14
       ,P_pym_attribute15           =>  p_pym_attribute15
       ,P_pym_attribute16           =>  p_pym_attribute16
       ,P_pym_attribute17           =>  p_pym_attribute17
       ,P_pym_attribute18           =>  p_pym_attribute18
       ,P_pym_attribute19           =>  p_pym_attribute19
       ,P_pym_attribute20           =>  p_pym_attribute20
       ,P_pym_information_category  =>  p_pym_information_category
       ,P_transfer_date             =>  p_transfer_date
       ,P_transfer_message          =>  p_transfer_message
       ,P_vendor_id                 =>  p_vendor_id
       ,P_contact_id                =>  p_contact_id
       ,P_address_id                =>  p_address_id
       ,P_customer_id               =>  p_customer_id
       ,P_tfh_information_category  =>  p_tfh_information_category
       ,P_tfh_information1          =>  p_tfh_information1
       ,P_tfh_information2          =>  p_tfh_information2
       ,P_tfh_information3          =>  p_tfh_information3
       ,P_tfh_information4          =>  p_tfh_information4
       ,P_tfh_information5          =>  p_tfh_information5
       ,P_tfh_information6          =>  p_tfh_information6
       ,P_tfh_information7          =>  p_tfh_information7
       ,P_tfh_information8          =>  p_tfh_information8
       ,P_tfh_information9          =>  p_tfh_information9
       ,P_tfh_information10         =>  p_tfh_information10
       ,P_tfh_information11         =>  p_tfh_information11
       ,P_tfh_information12         =>  p_tfh_information12
       ,P_tfh_information13         =>  p_tfh_information13
       ,P_tfh_information14         =>  p_tfh_information14
       ,P_tfh_information15         =>  p_tfh_information15
       ,P_tfh_information16         =>  p_tfh_information16
       ,P_tfh_information17         =>  p_tfh_information17
       ,P_tfh_information18         =>  p_tfh_information18
       ,P_tfh_information19         =>  p_tfh_information19
       ,P_tfh_information20         =>  p_tfh_information20
       ,P_paying_cost_center        =>  p_paying_cost_center
       ,P_receiving_cost_center     =>  p_receiving_cost_center
       ,p_transfer_from_set_of_book_id => p_transfer_from_set_of_book_id
       ,p_transfer_to_set_of_book_id => p_transfer_to_set_of_book_id
       ,p_from_segment1             =>  p_from_segment1
       ,p_from_segment2             =>  p_from_segment2
       ,p_from_segment3             =>  p_from_segment3
       ,p_from_segment4             =>  p_from_segment4
       ,p_from_segment5             =>  p_from_segment5
       ,p_from_segment6             =>  p_from_segment6
       ,p_from_segment7             =>  p_from_segment7
       ,p_from_segment8             =>  p_from_segment8
       ,p_from_segment9             =>  p_from_segment9
       ,p_from_segment10            =>  p_from_segment10
       ,p_from_segment11            =>  p_from_segment11
       ,p_from_segment12            =>  p_from_segment12
       ,p_from_segment13            =>  p_from_segment13
       ,p_from_segment14            =>  p_from_segment14
       ,p_from_segment15            =>  p_from_segment15
       ,p_from_segment16            =>  p_from_segment16
       ,p_from_segment17            =>  p_from_segment17
       ,p_from_segment18            =>  p_from_segment18
       ,p_from_segment19            =>  p_from_segment19
       ,p_from_segment20            =>  p_from_segment20
       ,p_from_segment21            =>  p_from_segment21
       ,p_from_segment22            =>  p_from_segment22
       ,p_from_segment23            =>  p_from_segment23
       ,p_from_segment24            =>  p_from_segment24
       ,p_from_segment25            =>  p_from_segment25
       ,p_from_segment26            =>  p_from_segment26
       ,p_from_segment27            =>  p_from_segment27
       ,p_from_segment28            =>  p_from_segment28
       ,p_from_segment29            =>  p_from_segment29
       ,p_from_segment30            =>  p_from_segment30
       ,p_to_segment1               =>  p_to_segment1
       ,p_to_segment2               =>  p_to_segment2
       ,p_to_segment3               =>  p_to_segment3
       ,p_to_segment4               =>  p_to_segment4
       ,p_to_segment5               =>  p_to_segment5
       ,p_to_segment6               =>  p_to_segment6
       ,p_to_segment7               =>  p_to_segment7
       ,p_to_segment8               =>  p_to_segment8
       ,p_to_segment9               =>  p_to_segment9
       ,p_to_segment10              =>  p_to_segment10
       ,p_to_segment11              =>  p_to_segment11
       ,p_to_segment12              =>  p_to_segment12
       ,p_to_segment13              =>  p_to_segment13
       ,p_to_segment14              =>  p_to_segment14
       ,p_to_segment15              =>  p_to_segment15
       ,p_to_segment16              =>  p_to_segment16
       ,p_to_segment17              =>  p_to_segment17
       ,p_to_segment18              =>  p_to_segment18
       ,p_to_segment19              =>  p_to_segment19
       ,p_to_segment20              =>  p_to_segment20
       ,p_to_segment21              =>  p_to_segment21
       ,p_to_segment22              =>  p_to_segment22
       ,p_to_segment23              =>  p_to_segment23
       ,p_to_segment24              =>  p_to_segment24
       ,p_to_segment25              =>  p_to_segment25
       ,p_to_segment26              =>  p_to_segment26
       ,p_to_segment27              =>  p_to_segment27
       ,p_to_segment28              =>  p_to_segment28
       ,p_to_segment29              =>  p_to_segment29
       ,p_to_segment30              =>  p_to_segment30
       ,p_transfer_from_cc_id       =>  p_transfer_from_cc_id
       ,p_transfer_to_cc_id         =>  p_transfer_to_cc_id
       ,p_effective_date                  =>  l_effective_date

  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FINANCE_HEADER'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_FINANCE_HEADER;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_FINANCE_HEADER;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_FINANCE_HEADER;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_FINANCE_HEADER >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_FINANCE_HEADER
  (p_validate                      in     boolean  default false
  ,p_finance_header_id                   in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Training Plan';
  l_object_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_FINANCE_HEADER;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook
  --
  begin
    OTA_FINANCE_HEADER_BK3.DELETE_FINANCE_HEADER_B
  (p_finance_header_id            => p_finance_header_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FINANCE_HEADER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tfh_api_del.del
  (p_finance_header_id        => p_finance_header_id
  ,p_object_version_number   => p_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
  OTA_FINANCE_HEADER_BK3.DELETE_FINANCE_HEADER_A
  (p_finance_header_id            => p_finance_header_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FINANCE_HEADER'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_FINANCE_HEADER;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_FINANCE_HEADER;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_FINANCE_HEADER;
--


END OTA_FINANCE_HEADER_API;

/
