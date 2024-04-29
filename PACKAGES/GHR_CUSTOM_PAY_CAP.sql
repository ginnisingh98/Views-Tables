--------------------------------------------------------
--  DDL for Package GHR_CUSTOM_PAY_CAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CUSTOM_PAY_CAP" AUTHID CURRENT_USER as
/* $Header: ghcupcap.pkh 120.0.12010000.3 2009/05/26 11:50:01 utokachi noship $ */
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< custom_hook >------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure is provided for the customer to update to allow them to
--    add there own pay cap routines. It is called from the main pay cap
--    procedure.
--
--  Pre Conditions:
--    A fully validated entity record structure.
--
--  In Arguments:
--    p_pay_cap_in_data (Record structure for all in data used to do pay_caps ).
--
--  OUT Arguments:
--    p_pay_cap_out_data (Record structure for all out data used to do pay_caps ).
-- 		open_pay_fields
--          message_set
--
--  Post Success:
--    Processing goes back to the main pay cap process.
--
--  Post Failure:
--    If message_set is set to TRUE then open_pay_fields should also be set to TRUE
--    This means in the form (GHRWS52L) the pay field will be opened up
--    when validation takes place in Update HR message_set to TRUE will raise
--    an error
--
--  Developer Implementation Notes:
--    Customer defined.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
procedure custom_hook
  (p_pay_cap_in_data  IN     ghr_pay_caps.pay_cap_in_rec_type
  ,p_pay_cap_out_data IN OUT NOCOPY ghr_pay_caps.pay_cap_out_rec_type
  );
--
end ghr_custom_pay_cap;

/
