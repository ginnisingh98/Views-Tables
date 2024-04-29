--------------------------------------------------------
--  DDL for Package PN_CREATE_ACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_CREATE_ACC" AUTHID CURRENT_USER as
  -- $Header: PNCRACCS.pls 115.3 2004/03/03 07:43:46 kkhegde noship $

-------------------------------------------------------------------
-- ( Run as a Conc Process )
-------------------------------------------------------------------
PROCEDURE CREATE_ACC(
 errbuf                         OUT NOCOPY VARCHAR2,
 retcode                        OUT NOCOPY VARCHAR2,
 P_journal_category             IN         VARCHAR2,
 p_default_gl_date              IN         VARCHAR2,
 P_batch_name                   IN         VARCHAR2,
 P_start_date                   IN         VARCHAR2,
 P_end_date                     IN         VARCHAR2,
 P_low_lease_id                 IN         NUMBER  ,
 P_high_lease_id                IN         NUMBER  ,
 P_period_name                  IN         VARCHAR2,
 p_vendor_id                    IN         NUMBER  ,
 p_customer_id                  IN         NUMBER  ,
 P_selection_type               IN         VARCHAR2,
 p_gl_transfer_mode             IN         VARCHAR2,
 p_submit_journal_import        IN         VARCHAR2,
 p_process_days                 IN         VARCHAR2,
 p_debug_flag                   IN         VARCHAR2,
 P_validate_account             IN         VARCHAR2,
 P_Org_id                       IN         NUMBER
 );

PROCEDURE CREATE_AR_ACC (
 P_journal_category       IN      VARCHAR2,
 p_default_gl_date        IN      VARCHAR2,
 p_default_period         IN      VARCHAR2,
 P_start_date             IN      VARCHAR2,
 P_end_date               IN      VARCHAR2,
 P_low_lease_id           IN      NUMBER  ,
 P_high_lease_id          IN      NUMBER  ,
 P_period_name            IN      VARCHAR2,
 p_customer_id            IN      NUMBER  ,
 P_Org_id                 IN      NUMBER
);

PROCEDURE CREATE_AP_ACC (
 P_journal_category       IN      VARCHAR2,
 p_default_gl_date        IN      VARCHAR2,
 p_default_period         IN      VARCHAR2,
 P_start_date             IN      VARCHAR2,
 P_end_date               IN      VARCHAR2,
 P_low_lease_id           IN      NUMBER  ,
 P_high_lease_id          IN      NUMBER  ,
 P_period_name            IN      VARCHAR2,
 p_vendor_id              IN      NUMBER  ,
 P_Org_id                 IN      NUMBER
);

FUNCTION GET_ACCOUNTED_AMOUNT(
 p_amount              IN NUMBER,
 p_functional_currency IN VARCHAR2,
 p_currency            IN VARCHAR2,
 p_rate                IN NUMBER,
 p_conv_date           IN DATE,
 p_conv_type           IN VARCHAR2)
RETURN NUMBER;

-- End of Package
------------------------------
END PN_CREATE_ACC;

 

/
