--------------------------------------------------------
--  DDL for Package OTA_TFH_API_BUSINESS_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TFH_API_BUSINESS_RULES" AUTHID CURRENT_USER as
/* $Header: ottfh02t.pkh 115.5 2002/11/29 09:30:35 arkashya ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_transfer_status >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The attribute 'Transfer Status' must be in the domain of
--    'GL Transfer Status'.
--
Procedure check_transfer_status
  (
   p_transfer_status  in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_transfer_rules  >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    The following changes to Transfer Status are allowed
--        NT -> AT
--        AT -> NT
--        UT -> NT
--        UT -> AT
--    When such a change takes place all the lines for the header that
--    have the same Transfer Status should also be changed.
--
--    In addition the following are permitted
--        AT -> ST
--        AT -> UT
--        ST -> UT
Procedure check_transfer_rules
  (
   p_new_transfer_status  in  varchar2
  ,p_old_transfer_status  in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_status_unauthorized >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The transfer status must be 'NT' if the header is not authorised,
--   ie: the authorised_by_person_id is null.
--
Procedure check_status_unauthorized
  (
   p_status                  in  varchar2
  ,p_authorized_person_id    in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_authorized_by >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The authorised_by attribute must be a valid person_id from PER_PEOPLE_F
--   using the date_raised attribute as a limit for the derrivation of one date
--   tracked row.
--
Procedure check_authorized_by
  (
   p_person_id  in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< set_date_raised >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The date_raised attribute must be set to the session date upon
--   creation. This attribute may not be updated.
--
Procedure set_date_raised
  (
   p_date_raised    out  nocopy date
  ,p_session_date   in   date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_receivable_attributes >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the header is of type 'Receivable' then the following
--   attributes must be NOT NULL:
--   CUSTOMER_CONTACT_ID
--   CUSTOMER_ADDRESS_ID
--   CUSTOMER_ID
--   INVOICE_ADDRESS
--   INVOICE_CONTACT
--   RECEIVABLE_TYPE
--   The following attributes must be NULL:
--   VENDOR_ID
--   VENDOR_CONTACT_ID
--   VENDOR_ADDRESS_ID
--
--
Procedure check_receivable_attributes
  (
   p_type                 in  varchar2
  ,p_customer_id          in  number
  ,p_customer_contact_id  in  number
  ,p_customer_address_id  in  number
  ,p_invoice_address      in  varchar2
  ,p_invoice_contact      in  varchar2
  ,p_vendor_id            in  number
  ,p_vendor_contact_id    in  number
  ,p_vendor_address_id    in  number
  ,p_receivable_type      in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_customer_contact >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The customer_contact_id must be for the same customer as defined on the
--   header in the attribute customer_id, if the header is receivable .
--
Procedure check_customer_contact
  (
   p_customer_id  in  number
  ,p_contact_id   in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_customer_address >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The customer_address_id must be for the same customer as defined
--   on the header in the attribute customer_id, if the header is receivable.
--
Procedure check_customer_address
  (
   p_customer_id  in  number
  ,p_address_id   in  number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_invoice_address >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Upon insert of a receivable header the address attributes must be
--   concatenated together in the invoice_address attribute. This must
--   be reset if the customer_address_id is changed. This changed must
--   then obey the change rules defined in the business rules. If the
--   header has been transfered, then a cancel and recreate would have
--   to be performed.
--
Procedure set_invoice_address
  (
   p_customer_id      in   number
  ,p_address_id       in   number
  ,p_invoice_address  out nocopy  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_invoice_contact >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
Procedure set_invoice_contact
  (
   p_customer_id      in   number
  ,p_contact_id       in   number
  ,p_invoice_contact  out  nocopy varchar2
  );
--
/*************  ?????????????????????????   ***********************
-- ----------------------------------------------------------------------------
-- |--------------------< check_update_invoice_address >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
Procedure check_update_invoice_address
  (
   p_invoice_address  in   varchar2
  );
**************  ?????????????????????????   ***********************/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_vendor_contact >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The vendor_contact must be a valid contact for the vendor defined in
--   vendor_id on the header, if the header is 'Payable'.
--
Procedure check_vendor_contact
  (
   p_vendor_id    in  number
  ,p_contact_id   in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_vendor_address >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The vendor_address must be a valid address for the vendor defined
--   in VENDOR_ID on the header.
--
Procedure check_vendor_address
  (
   p_vendor_id    in  number
  ,p_address_id   in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_payable_attributes >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the header is of type 'Payable' then the following
--   attributes must be NOT NULL:
--   VENDOR_CONTACT_ID
--   VENDOR_ADDRESS_ID
--   VENDOR_ID
--   INVOICE_CONTACT
--   The following attributes must be NULL:
--   CUSTOMER_CONTACT_ID
--   CUSTOMER_ADDRESS_ID
--   CUSTOMER_ID
--   INVOICE_ADDRESS
--   RECEIVABLE_TYPE
--
--
Procedure check_payable_attributes
  (
   p_type                 in  varchar2
  ,p_vendor_id            in  number
  ,p_vendor_contact_id    in  number
  ,p_vendor_address_id    in  number
  ,p_invoice_contact      in  varchar2
  ,p_invoice_address      in  varchar2
  ,p_customer_id          in  number
  ,p_customer_contact_id  in  number
  ,p_customer_address_id  in  number
  ,p_receivable_type      in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_cancelled_flag >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The cancelled_flag attribute must be in the domain 'Yes No'.
--
Procedure check_cancelled_flag
  (
   p_flag  in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< cancel_header >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- OVERLOADING PROCEDURE
--
-- Description:
--   The update of cancelled_flag is not permitted by any other means
--   than to call this procedure to cancel. This sets the cancelled_flag
--   to 'Y' and creates a cancellation header with the old header_id on
--   the new cancellation header in the supersedes_header_id attribute.
--   The procedure 'CANCEL_LINES_FOR_HEADER', found in the lines API,
--   will then be called.
--
Procedure cancel_header
  (
   p_rec_finance         in out   nocopy ota_tfh_api_shd.g_rec_type
  ,p_cancel_header_id       out  nocopy  number
  ,p_date_raised         in       date
  ,p_validate            in       boolean
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< cancel_header >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- OVERLOADING PROCEDURE
--
-- Description:
--   The update of cancelled_flag is not permitted by any other means
--   than to call this procedure to cancel. This sets the cancelled_flag
--   to 'Y' and creates a cancellation header with the old header_id on
--   the new cancellation header in the supersedes_header_id attribute.
--   The procedure 'CANCEL_LINES_FOR_HEADER', found in the lines API,
--   will then be called.
--
Procedure cancel_header
  (
   p_finance_header_id     in   number
  ,p_cancel_header_id      out  nocopy number
  ,p_date_raised           in   date
  ,p_validate              in   boolean
  ,p_commit                in   boolean default FALSE
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< recancel_header >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- PROCEDURE
--
-- Description:
--   The update of cancelled_flag is not permitted by any other means
--   than to call this procedure to recancel. This sets the cancelled_flag
--   to 'N'.
--   The procedure 'RECANCEL_LINES_FOR_HEADER', found in the lines API,
--   will then be called.
--
Procedure recancel_header
  (
   p_finance_header_id     in   number
  ,p_validate              in   boolean
  ,p_commit                in   boolean default FALSE
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< check_cancellation_attributes >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the header is of type 'Cancellation' then the following
--   attributes must be NOT NULL:
--   SUPERSEDES_HEADER_ID
--   The following attributes must be NULL:
--   CUSTOMER_CONTACT_ID
--   CUSTOMER_ADDRESS_ID
--   CUSTOMER_ID
--   INVOICE_ADDRESS
--   INVOICE_CONTACT
--   VENDOR_ID
--   VENDOR_CONTACT_ID
--   VENDOR_ADDRESS_ID
--   PAYMENT_METHOD
--   RECEIVABLE_TYPE
--
--
Procedure check_cancellation_attributes
  (
   p_type                 in  varchar2
  ,p_supersedes_header_id in  number
  ,p_customer_id          in  number
  ,p_customer_contact_id  in  number
  ,p_customer_address_id  in  number
  ,p_invoice_address      in  varchar2
  ,p_invoice_contact      in  varchar2
  ,p_vendor_id            in  number
  ,p_vendor_contact_id    in  number
  ,p_vendor_address_id    in  number
  ,p_payment_method       in  varchar2
  ,p_receivable_type      in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_superseded_header >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   For a cancellation header the superseded_header_id must be a valid
--   finance header.
--
Procedure check_superseded_header
  (
   p_finance_type             in  varchar2
  ,p_superseding_header_id    in  number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_update_customer_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Reference information check, if the customer_id is changed
--
Procedure check_update_customer_id
  (
   p_customer_id  in   number
  ,p_address_id   in   number
  ,p_contact_id   in   number
  ,p_vendor_id    in   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_update_vendor_id >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Reference information check, if the vendor_id is changed
--
Procedure check_update_vendor_id
  (
   p_vendor_id    in   number
  ,p_address_id   in   number
  ,p_contact_id   in   number
  ,p_customer_id  in   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< cancel_and_recreate >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   An API procedure is required to cancel a header and create a new
--   header in its place. This procedure will create a new header, which
--   supersedes the one which is to be cancelled. The procedure
--   'COPY_LINES_TO_NEW_HEADER', found in the lines API, will then be called.
--   The old finance header will then be cancelled by using the 'CANCEL_HEADER'
--   procedure. The TRANSFER_STATUS on the newly created header must be set to
--   'N' by default.
--
Procedure cancel_and_recreate
  (
   p_rec_finance         in out   nocopy ota_tfh_api_shd.g_rec_type
  ,p_date_raised         in       date
  ,p_validate            in       boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< cancel_and_recreate >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   An API procedure is required to cancel a header and create a new
--   header in its place. This procedure will create a new header, which
--   supersedes the one which is to be cancelled. The procedure
--   'COPY_LINES_TO_NEW_HEADER', found in the lines API, will then be called.
--   The old finance header will then be cancelled by using the 'CANCEL_HEADER'
--   procedure. The TRANSFER_STATUS on the newly created header must be set to
--   'N' by default.
--
Procedure cancel_and_recreate
  (
   p_finance_header_id         in    number
  ,p_recreation_header_id      out  nocopy  number
  ,p_cancel_header_id          out  nocopy  number
  ,p_date_raised               in    date
  ,p_validate                  in    boolean
  ,p_commit              in       boolean default FALSE
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_payment_method >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The PAYMENT_METHOD attribute must be in the domain 'Payment Method'.
--
Procedure check_payment_method
  (
   p_payment_method  in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_allow_transfer >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the TRANSFER_STATUS attribute is any other value than 'NT' the
--   PAYMENT_METHOD attribute must be NOT NULL.
--
Procedure check_allow_transfer
  (
   p_transfer_status in  varchar2
  ,p_payment_method  in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_update_header >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The details of a header may not be updated if the header has been
--   transferred other than to set the 'PAYMENT_FLAG'.
--   Enforced by the constraint 'OTA_TFH_CHECK_UPDATE'
--
Procedure check_update_header
  (
   p_rec_old             in  ota_tfh_api_shd.g_rec_type
  ,p_rec_new             in  ota_tfh_api_shd.g_rec_type
  ,p_transaction_type    in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_payment_status_flag >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The attribute 'PAYMENT_STATUS_FLAG' must be in the domain 'Yes No'.
--
Procedure check_payment_status_flag
  (
   p_flag  in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_administrator >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The ADMINISTRATOR attribute must be a valid AOL user.
--
Procedure check_administrator
  (
   p_administrator   in  number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_deletion >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Checks whether a finance_header can be deleted.
--
Procedure check_deletion
  (
   p_finance_header_id     in  number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< initialize_finance_header ------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
-- Get some default values for the Finance Header Form
--
procedure initialize_finance_header
   (
    p_business_group_id    in number
   ,p_fnd_user_id          in number
   ,p_deflt_currency_code  out nocopy varchar2
   ,p_deflt_trans_status_meaning out nocopy varchar2
   ,p_deflt_administrator  out nocopy varchar2
   ,p_deflt_organization   out nocopy varchar2
   );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_superseded >---------------------------
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
-- Check whether the Finance Header has been superceded and prevent update
-- if it has
--
procedure check_superseded (p_finance_header_id in number);
--
end ota_tfh_api_business_rules;

 

/
