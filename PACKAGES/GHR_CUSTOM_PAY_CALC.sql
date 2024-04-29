--------------------------------------------------------
--  DDL for Package GHR_CUSTOM_PAY_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CUSTOM_PAY_CALC" AUTHID CURRENT_USER as
/* $Header: ghcustpc.pkh 120.0.12010000.3 2009/05/26 11:50:46 utokachi noship $ */
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< custum_pay_calc >--------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure is provided for the customer to update to allow them to
--    add there own pay calculation routines. It is called from the main pay calc
--    procedure.
--
--  Pre Conditions:
--    A fully validated entity record structure.
--
--  In Arguments:
--    p_pay_data_rec (Record structure for all in data used to calculate pay ).
--    p_message_set  BOOLEAN set to TRUE if we want to display a message to the user
--    p_calculated   BOOLEAN set to TRUE if we calculated it otherwise FALSE
--    If p_calcaulated is set to TRUE the values of the calcuated pay will also
--    be given.
--
--  OUT Arguments:
--  If the user can calculate pay (or wishes to overide our pay calc!) they must set
--  the p_calculated parameter to TRUE
--
--  Post Success:
--    Processing goes back to the main pay calc process.
--    If the customer calculated pay they must set ALL the OUT parameters and the
--    p_calculated to TRUE and p_message to FALSE. The out parameters are
--     p_basic_pay
--     p_locality_adj
--     p_adj_basic_pay
--     p_total_salary
--     p_other_pay_amount
--     p_au_overtime
--     p_availability_pay
--
--  Post Failure:
--    SQL failure:
--      Processing goes back to the main pay calc process:
--    Unable to calculate:
--      If the customer cannot calculate pay either given the same in parameters
--      set p_calculated to FALSE and if you also want a message to be given set
--      p_message to TRUE and use fnd_message.set_name to put the message you want
--      on the stack
--
--  Developer Implementation Notes:
--    Customer defined.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
procedure custom_pay_calc
  (p_pay_data_rec              IN     ghr_pay_calc.pay_calc_in_rec_type
  ,p_pay_data_out_rec          IN OUT NOCOPY ghr_pay_calc.pay_calc_out_rec_type
  ,p_message_set               IN OUT NOCOPY BOOLEAN
  ,p_calculated                IN OUT NOCOPY BOOLEAN
  );
--
end ghr_custom_pay_calc;

/
