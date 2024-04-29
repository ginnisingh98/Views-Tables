--------------------------------------------------------
--  DDL for Package OZF_FUNDRULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUNDRULES_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvfrus.pls 120.1 2005/08/17 17:29:32 appldev ship $*/

-----------------------------------------------------------------------
-- PROCEDURE
--    check_fund_calendar
--
-- PURPOSE
--    Check fund_calendar, start_period_name, end_period_name.
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
--
-- NOTES
--    1. The start date of the start period should be no later than
--       the end date of the end period.
-----------------------------------------------------------------------
PROCEDURE check_fund_calendar(
   p_fund_calendar       IN  VARCHAR2,
   p_start_period_name   IN  VARCHAR2,
   p_end_period_name     IN  VARCHAR2,
   p_start_date          IN  DATE,
   p_end_date            IN  DATE,
   p_fund_type           IN  VARCHAR2,
   x_return_status       OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_dates_vs_parent
--
-- PURPOSE
--    Check fund dates against its parent.
--
-- HISTORY
--    01/15/2001  Mumu Pande  Create.

---------------------------------------------------------------------
PROCEDURE check_fund_dates_vs_parent(
   p_parent_id      IN  NUMBER,
   p_start_date_active IN DATE,
   p_end_date_active IN DATE,
   x_return_status  OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_amount_vs_parent
--
-- PURPOSE
--    Check fund dates against its parent.
--
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
--    09/04/2001  Mumu Pande  Updated for different currency child
---------------------------------------------------------------------
PROCEDURE check_fund_amount_vs_parent(
   p_parent_id      IN  NUMBER,
   p_child_curr     IN VARCHAR2,
   p_original_budget IN NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_type_vs_parent
--
-- PURPOSE
--    Check fund type against its parent.
--
-- HISTORY
--    01/15/2001  Mumu Pande  Create.

---------------------------------------------------------------------
PROCEDURE check_fund_type_vs_parent(
   p_parent_id      IN  NUMBER,
   p_fund_type       IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_curr_vs_parent
--
-- PURPOSE
--    Check fund curr against its parent.
--
-- HISTORY
--    01/15/2001  Mumu Pande  Create.

---------------------------------------------------------------------
PROCEDURE check_fund_curr_vs_parent(
   p_parent_id      IN  NUMBER,
   p_fund_curr       IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_status_vs_parent
--
-- PURPOSE
--    Check fund status(active,draft) against its parent.
--
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
---------------------------------------------------------------------
PROCEDURE check_fund_status_vs_parent(
   p_parent_id      IN  NUMBER,
   p_status_code    IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_dates_vs_child
--
-- HISTORY
--    01/15/2001  Mumu Pande  Create.

---------------------------------------------------------------------
PROCEDURE check_fund_dates_vs_child(
   p_fund_id        IN  NUMBER,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_types_vs_child
--

-- HISTORY
--    01/15/2001  Mumu Pande  Create.

---------------------------------------------------------------------
PROCEDURE check_fund_type_vs_child(
   p_fund_id        IN  NUMBER,
   p_fund_type      IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_curr_vs_child
--

-- HISTORY
--    01/15/2001  Mumu Pande  Create.

---------------------------------------------------------------------
PROCEDURE check_fund_curr_vs_child(
   p_fund_id        IN  NUMBER,
   p_fund_curr      IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_amount_vs_child
--
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
--    09/04/2001  Mumu Pande  Updated for different currency child
---------------------------------------------------------------------
PROCEDURE check_fund_amount_vs_child(
   p_fund_id        IN  NUMBER,
   p_fund_org_amount    IN  NUMBER,
   p_fund_tran_in_amount    IN  NUMBER,
   p_fund_tran_out_amount    IN  NUMBER,
   p_parent_currency        IN       VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_product_elig_exists
--
-- PURPOSE
--    check product eligibility exists for the fund

-- HISTORY
--    01/15/2001  Mumu Pande  Create.

-- NOTES
---------------------------------------------------------------------
PROCEDURE check_product_elig_exists(
      p_fund_id      IN  NUMBER,
      x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    udpate_fund_status
--
-- PURPOSE
-- This API does all the status related validation of funds  during updation
-- This is a private API to be used by funds module only
--DESCRIPTION
--    Update fund status
--p_fund_rec            IN  ozf_funds_pvt.fund_rec_type,
--x_new_status_code       OUT NOCOPY VARCHAR2, -- new status code of the fund
--x_new_status_id       OUT NOCOPY NUMBER,-- new user status id of the fund
--x_return_status           OUT NOCOPY VARCHAR2,-- standard API parameter
--x_msg_count         OUT NOCOPY NUMBER, -- standard API parameter
--x_msg_data         OUT NOCOPY VARCHAR2, -- standard API parameter
--p_api_version         IN  NUMBER  -- standard API parameter
-- HISTORY
--    01/15/2001  Mumu Pande  Create.

-----------------------------------------------------------------------
PROCEDURE Update_Fund_Status
      (p_fund_rec            IN  ozf_funds_pvt.fund_rec_type,
       x_new_status_code       OUT NOCOPY VARCHAR2,
       x_new_status_id       OUT NOCOPY NUMBER,
       x_submit_budget_approval  OUT NOCOPY VARCHAR2,
       x_submit_child_approval   OUT NOCOPY VARCHAR2,
       x_return_status           OUT NOCOPY VARCHAR2,
       x_msg_count         OUT NOCOPY NUMBER,
       x_msg_data         OUT NOCOPY VARCHAR2,
       p_api_version         IN  NUMBER
      );
---------------------------------------------------------------------
-- PROCEDURE
--    process_approval
--
-- PURPOSE
--    This API is called when  fund is approved from a workflow.
--    This API does the following transactions for a Active fund.
--    1) Record for  holdback amount
--    2) Handle  transactions for a  Accrual type fund

-- HISTORY
--    01/15/2001  Mumu Pande  Create.

-- NOTES
---------------------------------------------------------------------

PROCEDURE process_approval(
   p_fund_rec        IN       ozf_funds_pvt.fund_rec_type
  ,p_mode            IN       VARCHAR2
  ,p_old_fund_status IN       VARCHAR2 := NULL
  ,x_return_status   OUT NOCOPY      VARCHAR2
  ,x_msg_count       OUT NOCOPY      NUMBER
  ,x_msg_data        OUT NOCOPY      VARCHAR2
  ,p_api_version     IN       NUMBER);
---------------------------------------------------------------------
-- PROCEDURE
--    process_accrual
--
-- PURPOSE
--    This API is called for Acrrual to either Customer or Sales depending upon fund type.
--    This API does the following transactions for a Active fund.
--    1) If Accrual basis if 'Customer' then it accrues to customer.
--    2) If Accrual basis if 'Sales' then it accrues to sales.
-- HISTORY
--    10/08/2002 Srinivasa Rudravarapu Create.
-- NOTES
---------------------------------------------------------------------
PROCEDURE process_accrual(
   p_fund_rec          IN       ozf_funds_pvt.fund_rec_type,
   p_api_version       IN       NUMBER,
   p_mode              IN       VARCHAR2,
   p_old_fund_status   IN       VARCHAR2 := NULL,
   x_return_status     OUT NOCOPY      VARCHAR2,
   x_msg_count         OUT NOCOPY      NUMBER,
   x_msg_data          OUT NOCOPY      VARCHAR2) ;
END OZF_FundRules_Pvt;

 

/
