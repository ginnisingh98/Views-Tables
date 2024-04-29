--------------------------------------------------------
--  DDL for Package OTA_FINANCE_HEADER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FINANCE_HEADER_API" AUTHID CURRENT_USER as
/* $Header: ottfhapi.pkh 120.3 2006/08/30 09:49:56 niarora noship $ */
/*#
 * This package contains finance header APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Finance Header
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_finance_header >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This package creates a finance header.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Organization must exist.
 *
 * <p><b>Post Success</b><br>
 * The Finance header is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a Finance Header record, and raises an error.
 *
 * @param p_finance_header_id The Unique identifier of the Finance Header.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created learning path section. If p_validate is true,
 * then the value will be null.
 * @param p_superceding_header_id Foreign key to OTA_FINANCE_HEADERS.
 * @param p_authorizer_person_id Foreign key to PER_ALL_PEOPLE_F.
 * @param p_organization_id Foreign key to HR_ALL_ORGANIZATION_UNITS.
 * @param p_administrator The person who raised the header.
 * @param p_cancelled_flag An indication of whether the header has been
 * cancelled. Permissible values Y and N.
 * @param p_currency_code The currency in which all lines are defined.
 * @param p_date_raised The date this header was raised.
 * @param p_payment_status_flag Describes if the invoice has been paid or not.
 * @param p_transfer_status The Status of the header for external transfer.
 * @param p_type The type of header. Valid values are: cancellation,payable
 * and receivable.
 * @param p_receivable_type The type of receivable header.
 * @param p_comments Comment text.
 * @param p_external_reference The identification of this header in the external system.
 * @param p_invoice_address The address to which the invoice is to be sent.
 * @param p_invoice_contact The person to which this invoice is to be sent.
 * @param p_payment_method The payment method by which this header is to be paid.
 * @param p_pym_information_category The flexfield to hold Payment Method Details.
 * @param p_pym_attribute1 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute2 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute3 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute4 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute5 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute6 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute7 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute8 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute9 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute10 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute11 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute12 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute13 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute14 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute15 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute16 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute17 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute18 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute19 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute20 Payment Method Descriptive flexfield segment.
 * @param p_transfer_date The date this header was transfered into an external system.
 * @param p_transfer_message A message to send to the external system with this header.
 * @param p_vendor_id Foreign key to PO_VENDORS.
 * @param p_contact_id Foreign key to RA_CONTACTS.
 * @param p_address_id Foreign key to RA_ADDRESSES.
 * @param p_customer_id Foreign key to RA_CUSTOMERS.
 * @param p_tfh_information_category This context value determines
 * which flexfield structure to use with the descriptive flexfield segments.
 * @param p_tfh_information1 Descriptive flexfield segment.
 * @param p_tfh_information2 Descriptive flexfield segment.
 * @param p_tfh_information3 Descriptive flexfield segment.
 * @param p_tfh_information4 Descriptive flexfield segment.
 * @param p_tfh_information5 Descriptive flexfield segment.
 * @param p_tfh_information6 Descriptive flexfield segment.
 * @param p_tfh_information7 Descriptive flexfield segment.
 * @param p_tfh_information8 Descriptive flexfield segment.
 * @param p_tfh_information9 Descriptive flexfield segment.
 * @param p_tfh_information10 Descriptive flexfield segment.
 * @param p_tfh_information11 Descriptive flexfield segment.
 * @param p_tfh_information12 Descriptive flexfield segment.
 * @param p_tfh_information13 Descriptive flexfield segment.
 * @param p_tfh_information14 Descriptive flexfield segment.
 * @param p_tfh_information15 Descriptive flexfield segment.
 * @param p_tfh_information16 Descriptive flexfield segment.
 * @param p_tfh_information17 Descriptive flexfield segment.
 * @param p_tfh_information18 Descriptive flexfield segment.
 * @param p_tfh_information19 Descriptive flexfield segment.
 * @param p_tfh_information20 Descriptive flexfield segment.
 * @param p_paying_cost_center Paying cost center code for the
 * resource charge cross transfer.
 * @param p_receiving_cost_center Receiving cost center code for the
 * resource charge cross transfer.
 * @param p_transfer_from_set_of_book_id Transfer from Set of books id.
 * @param p_transfer_to_set_of_book_id Transfer to Set of books id.
 * @param p_from_segment1 GL From Descriptive flexfield segment.
 * @param p_from_segment2 GL From Descriptive flexfield segment.
 * @param p_from_segment3 GL From Descriptive flexfield segment.
 * @param p_from_segment4 GL From Descriptive flexfield segment.
 * @param p_from_segment5 GL From Descriptive flexfield segment.
 * @param p_from_segment6 GL From Descriptive flexfield segment.
 * @param p_from_segment7 GL From Descriptive flexfield segment.
 * @param p_from_segment8 GL From Descriptive flexfield segment.
 * @param p_from_segment9 GL From Descriptive flexfield segment.
 * @param p_from_segment10 GL From Descriptive flexfield segment.
 * @param p_from_segment11 GL From Descriptive flexfield segment.
 * @param p_from_segment12 GL From Descriptive flexfield segment.
 * @param p_from_segment13 GL From Descriptive flexfield segment.
 * @param p_from_segment14 GL From Descriptive flexfield segment.
 * @param p_from_segment15 GL From Descriptive flexfield segment.
 * @param p_from_segment16 GL From Descriptive flexfield segment.
 * @param p_from_segment17 GL From Descriptive flexfield segment.
 * @param p_from_segment18 GL From Descriptive flexfield segment.
 * @param p_from_segment19 GL From Descriptive flexfield segment.
 * @param p_from_segment20 GL From Descriptive flexfield segment.
 * @param p_from_segment21 GL From Descriptive flexfield segment.
 * @param p_from_segment22 GL From Descriptive flexfield segment.
 * @param p_from_segment23 GL From Descriptive flexfield segment.
 * @param p_from_segment24 GL From Descriptive flexfield segment.
 * @param p_from_segment25 GL From Descriptive flexfield segment.
 * @param p_from_segment26 GL From Descriptive flexfield segment.
 * @param p_from_segment27 GL From Descriptive flexfield segment.
 * @param p_from_segment28 GL From Descriptive flexfield segment.
 * @param p_from_segment29 GL From Descriptive flexfield segment.
 * @param p_from_segment30 GL From Descriptive flexfield segment.
 * @param p_to_segment1 GL To Descriptive flexfield segment.
 * @param p_to_segment2 GL To Descriptive flexfield segment.
 * @param p_to_segment3 GL To Descriptive flexfield segment.
 * @param p_to_segment4 GL To Descriptive flexfield segment.
 * @param p_to_segment5 GL To Descriptive flexfield segment.
 * @param p_to_segment6 GL To Descriptive flexfield segment.
 * @param p_to_segment7 GL To Descriptive flexfield segment.
 * @param p_to_segment8 GL To Descriptive flexfield segment.
 * @param p_to_segment9 GL To Descriptive flexfield segment.
 * @param p_to_segment10 GL To Descriptive flexfield segment.
 * @param p_to_segment11 GL To Descriptive flexfield segment.
 * @param p_to_segment12 GL To Descriptive flexfield segment.
 * @param p_to_segment13 GL To Descriptive flexfield segment.
 * @param p_to_segment14 GL To Descriptive flexfield segment.
 * @param p_to_segment15 GL To Descriptive flexfield segment.
 * @param p_to_segment16 GL To Descriptive flexfield segment.
 * @param p_to_segment17 GL To Descriptive flexfield segment.
 * @param p_to_segment18 GL To Descriptive flexfield segment.
 * @param p_to_segment19 GL To Descriptive flexfield segment.
 * @param p_to_segment20 GL To Descriptive flexfield segment.
 * @param p_to_segment21 GL To Descriptive flexfield segment.
 * @param p_to_segment22 GL To Descriptive flexfield segment.
 * @param p_to_segment23 GL To Descriptive flexfield segment.
 * @param p_to_segment24 GL To Descriptive flexfield segment.
 * @param p_to_segment25 GL To Descriptive flexfield segment.
 * @param p_to_segment26 GL To Descriptive flexfield segment.
 * @param p_to_segment27 GL To Descriptive flexfield segment.
 * @param p_to_segment28 GL To Descriptive flexfield segment.
 * @param p_to_segment29 GL To Descriptive flexfield segment.
 * @param p_to_segment30 GL To Descriptive flexfield segment.
 * @param p_transfer_from_cc_id Transfer from GL Code Combination Id.
 * @param p_transfer_to_cc_id Transfer to GL Code Combination Id.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @rep:displayname Create Finanace Header
 * @rep:category BUSINESS_ENTITY OTA_FINANCE_HEADER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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

  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_finance_header >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This package updates Finance header.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Finance Header with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Finance header is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update Finance Header record, and raises an error.
 *
 * @param p_finance_header_id The Unique identifier of the Finance Header.
 * @param p_object_version_number If p_validate is false, then set to the version
 * number of the created learning path section. If p_validate is true, then the value will be null.
 * @param p_new_object_version_number The new object version number of the record after the update.
 * @param p_superceding_header_id Foreign key to OTA_FINANCE_HEADERS.
 * @param p_authorizer_person_id Foreign key to PER_ALL_PEOPLE_F.
 * @param p_organization_id Foreign key to HR_ALL_ORGANIZATION_UNITS.
 * @param p_administrator The person who raised the header.
 * @param p_cancelled_flag An indication of whether the header has been cancelled.
 * Permissible values Y and N.
 * @param p_currency_code The currency in which all lines are defined.
 * @param p_date_raised The date this header was raised.
 * @param p_payment_status_flag Describes if the invoice has been paid or not.
 * @param p_transfer_status The Status of the header for external transfer.
 * @param p_type The type of header. Valid vlaues are: cancellation,payable,receivable
 * @param p_receivable_type The type of receivable header.
 * @param p_comments Comment text.
 * @param p_external_reference The identification of this header in the external system.
 * @param p_invoice_address The address to which the invoice is to sent.
 * @param p_invoice_contact The person to which this invoice is to be sent.
 * @param p_payment_method The payment Method by which this header is to be paid.
 * @param p_pym_information_category The flexfield to hold Payment Method Details.
 * @param p_pym_attribute1 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute2 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute3 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute4 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute5 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute6 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute7 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute8 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute9 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute10 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute11 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute12 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute13 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute14 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute15 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute16 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute17 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute18 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute19 Payment Method Descriptive flexfield segment.
 * @param p_pym_attribute20 Payment Method Descriptive flexfield segment.
 * @param p_transfer_date The date this header was transfered into an external system.
 * @param p_transfer_message A message to send to the external system with this header.
 * @param p_vendor_id Foreign key to PO_VENDORS.
 * @param p_contact_id Foreign key to RA_CONTACTS.
 * @param p_address_id Foreign key to RA_ADDRESSES.
 * @param p_customer_id Foreign key to RA_CUSTOMERS.
 * @param p_tfh_information_category This context value determines which flexfield structure
 * to use with the descriptive flexfield segments.
 * @param p_tfh_information1 Descriptive flexfield segment.
 * @param p_tfh_information2 Descriptive flexfield segment.
 * @param p_tfh_information3 Descriptive flexfield segment.
 * @param p_tfh_information4 Descriptive flexfield segment.
 * @param p_tfh_information5 Descriptive flexfield segment.
 * @param p_tfh_information6 Descriptive flexfield segment.
 * @param p_tfh_information7 Descriptive flexfield segment.
 * @param p_tfh_information8 Descriptive flexfield segment.
 * @param p_tfh_information9 Descriptive flexfield segment.
 * @param p_tfh_information10 Descriptive flexfield segment.
 * @param p_tfh_information11 Descriptive flexfield segment.
 * @param p_tfh_information12 Descriptive flexfield segment.
 * @param p_tfh_information13 Descriptive flexfield segment.
 * @param p_tfh_information14 Descriptive flexfield segment.
 * @param p_tfh_information15 Descriptive flexfield segment.
 * @param p_tfh_information16 Descriptive flexfield segment.
 * @param p_tfh_information17 Descriptive flexfield segment.
 * @param p_tfh_information18 Descriptive flexfield segment.
 * @param p_tfh_information19 Descriptive flexfield segment.
 * @param p_tfh_information20 Descriptive flexfield segment.
 * @param p_paying_cost_center Paying cost center code for the resource charge cross transfer.
 * @param p_receiving_cost_center Receiving cost center code for the resource charge cross transfer.
 * @param p_transfer_from_set_of_book_id Transfer from Set of books id.
 * @param p_transfer_to_set_of_book_id Transfer to Set of books id.
 * @param p_from_segment1 GL From Descriptive flexfield segment.
 * @param p_from_segment2 GL From Descriptive flexfield segment.
 * @param p_from_segment3 GL From Descriptive flexfield segment.
 * @param p_from_segment4 GL From Descriptive flexfield segment.
 * @param p_from_segment5 GL From Descriptive flexfield segment.
 * @param p_from_segment6 GL From Descriptive flexfield segment.
 * @param p_from_segment7 GL From Descriptive flexfield segment.
 * @param p_from_segment8 GL From Descriptive flexfield segment.
 * @param p_from_segment9 GL From Descriptive flexfield segment.
 * @param p_from_segment10 GL From Descriptive flexfield segment.
 * @param p_from_segment11 GL From Descriptive flexfield segment.
 * @param p_from_segment12 GL From Descriptive flexfield segment.
 * @param p_from_segment13 GL From Descriptive flexfield segment.
 * @param p_from_segment14 GL From Descriptive flexfield segment.
 * @param p_from_segment15 GL From Descriptive flexfield segment.
 * @param p_from_segment16 GL From Descriptive flexfield segment.
 * @param p_from_segment17 GL From Descriptive flexfield segment.
 * @param p_from_segment18 GL From Descriptive flexfield segment.
 * @param p_from_segment19 GL From Descriptive flexfield segment.
 * @param p_from_segment20 GL From Descriptive flexfield segment.
 * @param p_from_segment21 GL From Descriptive flexfield segment.
 * @param p_from_segment22 GL From Descriptive flexfield segment.
 * @param p_from_segment23 GL From Descriptive flexfield segment.
 * @param p_from_segment24 GL From Descriptive flexfield segment.
 * @param p_from_segment25 GL From Descriptive flexfield segment.
 * @param p_from_segment26 GL From Descriptive flexfield segment.
 * @param p_from_segment27 GL From Descriptive flexfield segment.
 * @param p_from_segment28 GL From Descriptive flexfield segment.
 * @param p_from_segment29 GL From Descriptive flexfield segment.
 * @param p_from_segment30 GL From Descriptive flexfield segment.
 * @param p_to_segment1 GL To Descriptive flexfield segment.
 * @param p_to_segment2 GL To Descriptive flexfield segment.
 * @param p_to_segment3 GL To Descriptive flexfield segment.
 * @param p_to_segment4 GL To Descriptive flexfield segment.
 * @param p_to_segment5 GL To Descriptive flexfield segment.
 * @param p_to_segment6 GL To Descriptive flexfield segment.
 * @param p_to_segment7 GL To Descriptive flexfield segment.
 * @param p_to_segment8 GL To Descriptive flexfield segment.
 * @param p_to_segment9 GL To Descriptive flexfield segment.
 * @param p_to_segment10 GL To Descriptive flexfield segment.
 * @param p_to_segment11 GL To Descriptive flexfield segment.
 * @param p_to_segment12 GL To Descriptive flexfield segment.
 * @param p_to_segment13 GL To Descriptive flexfield segment.
 * @param p_to_segment14 GL To Descriptive flexfield segment.
 * @param p_to_segment15 GL To Descriptive flexfield segment.
 * @param p_to_segment16 GL To Descriptive flexfield segment.
 * @param p_to_segment17 GL To Descriptive flexfield segment.
 * @param p_to_segment18 GL To Descriptive flexfield segment.
 * @param p_to_segment19 GL To Descriptive flexfield segment.
 * @param p_to_segment20 GL To Descriptive flexfield segment.
 * @param p_to_segment21 GL To Descriptive flexfield segment.
 * @param p_to_segment22 GL To Descriptive flexfield segment.
 * @param p_to_segment23 GL To Descriptive flexfield segment.
 * @param p_to_segment24 GL To Descriptive flexfield segment.
 * @param p_to_segment25 GL To Descriptive flexfield segment.
 * @param p_to_segment26 GL To Descriptive flexfield segment.
 * @param p_to_segment27 GL To Descriptive flexfield segment.
 * @param p_to_segment28 GL To Descriptive flexfield segment.
 * @param p_to_segment29 GL To Descriptive flexfield segment.
 * @param p_to_segment30 GL To Descriptive flexfield segment.
 * @param p_transfer_from_cc_id Transfer from GL Code Combination Id.
 * @param p_transfer_to_cc_id Transfer to GL Code Combination Id.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Finanace Header
 * @rep:category BUSINESS_ENTITY OTA_FINANCE_HEADER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_FINANCE_HEADER
  (
  p_finance_header_id            in number,
  p_object_version_number        in out nocopy number,
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
  p_transfer_to_cc_id              in number ,
  P_validate			   in boolean  default false,
  p_effective_date		   in date


  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_finance_header >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This package deletes Finance header.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Finance Header with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Finance header is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete Finance Header record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_finance_header_id The Unique identifier of the Finance Header.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created learning path section. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Delete Finanace Header
 * @rep:category BUSINESS_ENTITY OTA_FINANCE_HEADER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure DELETE_FINANCE_HEADER
  (p_validate                      in     boolean  default false
   ,p_finance_header_id            in number
  ,p_object_version_number        in number
  );

end ota_FINANCE_HEADER_api;

 

/
