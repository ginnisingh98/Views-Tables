--------------------------------------------------------
--  DDL for Package AR_UPGRADE_CASH_ACCRUAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_UPGRADE_CASH_ACCRUAL" AUTHID CURRENT_USER AS
/* $Header: ARUPGLZS.pls 120.4.12010000.1 2008/07/24 16:58:52 appldev ship $ */

/*------------------------------------------------------+
 | Procedure for insertion in ra_ar_gt all transaction  |
 | distributions usable in OLTP and BATCH               |
 +------------------------------------------------------*/
PROCEDURE get_direct_inv_dist
  (p_mode                 IN VARCHAR2,
   p_trx_id               IN NUMBER   DEFAULT NULL,
   p_gt_id                IN NUMBER   DEFAULT NULL);

--MFAR invoice distributions
PROCEDURE get_direct_mf_inv_dist
  (p_mode                 IN VARCHAR2 DEFAULT 'BATCH',
   p_gt_id                IN NUMBER   DEFAULT NULL);

/*------------------------------------------------------+
 | Procedure for insertion in ra_ar_gt all adjustment   |
 | distributions usable in OLTP and BATCH               |
 +------------------------------------------------------*/
PROCEDURE get_direct_adj_dist
  (p_mode                 IN VARCHAR2,
   p_trx_id               IN NUMBER  DEFAULT NULL,
   p_gt_id                IN NUMBER  DEFAULT NULL);

PROCEDURE get_direct_inv_adj_dist
  (p_mode                 IN VARCHAR2,
   p_trx_id               IN NUMBER  DEFAULT NULL,
   p_gt_id                IN NUMBER  DEFAULT NULL);

--MFAR adj distributions procedure only in batch mode
PROCEDURE get_direct_mf_adj_dist
  (p_mode                 IN VARCHAR2,
   p_gt_id                IN NUMBER  DEFAULT NULL);

/*------------------------------------------------------+
 | Procedure for update the base proration only batch   |
 +------------------------------------------------------*/
PROCEDURE update_base
  (p_gt_id                IN NUMBER  DEFAULT NULL);

/*------------------------------------------------------+
 | Procedure for create distribution only batch         |
 +------------------------------------------------------*/
PROCEDURE create_distributions;

FUNCTION fct_acct_amt
  (p_amt             IN NUMBER,
   p_base_amt        IN NUMBER,
   p_base_acctd_amt  IN NUMBER,
   p_currency_code   IN VARCHAR2,
   p_base_currency   IN VARCHAR2,
   p_ind_id          IN NUMBER)
RETURN NUMBER;


---------------------------------------
-- PROCEDURE COMPARE_RA_REM_AMT
---------------------------------------
-- Arguments Input
--  p_app_rec         IN  ar_receivable_applications%ROWTYPE -- the application record initial
--  p_app_level       IN  VARCHAR2 DEFAULT 'TRANSACTION'     -- level of application
--  p_group_id        IN  VARCHAR2 DEFAULT NULL              -- if level = GROUP then which group
--  p_ctl_id          IN  NUMBER   DEFAULT NULL              -- if level = LINE then which line
--  p_currency        IN  VARCHAR2                           -- transactional currency
--------------
-- Outputs
--  x_app_rec         OUT NOCOPY ar_receivable_applications%ROWTYPE -- after leasing the result app_rec
--  x_return_status   IN OUT NOCOPY VARCHAR2
--  x_msg_data        IN OUT NOCOPY VARCHAR2
--  x_msg_count       IN OUT NOCOPY NUMBER
--------------
-- Objective:
--  When does a application on a 11i MFAR transaction, the amount allocated per bucket can in disconcordance
--  with the remaining amounts stamped in AR on the transaction because
--  AR tied the charges and freight adjusted to revenue line
--  but PSA tied the freight to freight line
--  prorate the charges on all lines
--  Therefore  remaining amount calculated by AR can not the same from PSA
--  For legacy transaction originate by PSA, in the upgrade AR should ensure:
--  * the overall amount remaining all buckets and application all buckets are not incompatible
--    that is no overapplication
--  * the ED UNED bucket are not mixed with the application buckets
--  * but the disconcordance between the rem and the application amount per bucket will be
--    handled by the amount applied bucket
----------------------------------------
PROCEDURE COMPARE_RA_REM_AMT
( p_app_rec         IN         ar_receivable_applications%ROWTYPE,
  x_app_rec         OUT NOCOPY ar_receivable_applications%ROWTYPE,
  p_app_level       IN         VARCHAR2 DEFAULT 'TRANSACTION',
  p_source_data_key1 IN         VARCHAR2 DEFAULT NULL,
  p_source_data_key2 IN         VARCHAR2 DEFAULT NULL,
  p_source_data_key3 IN         VARCHAR2 DEFAULT NULL,
  p_source_data_key4 IN         VARCHAR2 DEFAULT NULL,
  p_source_data_key5 IN         VARCHAR2 DEFAULT NULL,
  p_ctl_id          IN         NUMBER   DEFAULT NULL,
  p_currency        IN         VARCHAR2,
  x_return_status   IN OUT NOCOPY VARCHAR2,
  x_msg_data        IN OUT NOCOPY VARCHAR2,
  x_msg_count       IN OUT NOCOPY NUMBER);

---------------------------------------
-- PROCEDURE portion_to_move
---------------------------------------
-- Calculate the portion to move from the total to each bucket
--  based on the ratio argument
--  for example:
--   total to move = 15
--     freight ratio = 10
--     tax ratio     = 20
--     line ratio    = 40
--     chrg ratio    = 80
--     ---
--     freight_portion to move = 1
--     tax_portion to move = 2
--     line_portion to move = 4
--     chrg_portion to move = 8
----------------------------------------
PROCEDURE portion_to_move
(p_total_to_move     IN NUMBER,
 p_freight_ratio     IN NUMBER  DEFAULT 0,
 p_tax_ratio         IN NUMBER  DEFAULT 0,
 p_line_ratio        IN NUMBER  DEFAULT 0,
 p_chrg_ratio        IN NUMBER  DEFAULT 0,
 p_currency          IN VARCHAR2,
 x_freight_portion   OUT NOCOPY NUMBER,
 x_tax_portion       OUT NOCOPY NUMBER,
 x_line_portion      OUT NOCOPY NUMBER,
 x_chrg_portion      OUT NOCOPY NUMBER);

---------------------------------------
-- PROCEDURE move_bucket
---------------------------------------
-- Determine the amount to move and
-- Does the movement of the bucket for bucket originate the movement
-- For example:
--  p_chrg_entire meaning Chrg (ED UNED APP) of an application
--  is greater then the Chrg remaining on the invoice to apply
--  we need to reconcile the surplus amount from the chrg to move
--  to other buckets
--------------
-- Consider we have a surplus of 15 usd of charge to move, so
-- if which bucket = 'CHRG' then 15 usd will be moved to line, tax, freight buckets
-- Consider we have a surplus of 10 usd of freight to move, so
-- if which bucket = 'FREIGHT' then 10 usd will be moved to line, tax buckets
-- Consider we have a surplus of 5 usd of tax to move, so
-- if which bucket = 'TAX' then 5 usd will be moved to line
-- No movement is allowed on LINE bucket the surplus stay in line buckets
---------------
-- The new entire amount by bucket are returned in x_XXX_entire output argument
----------------------------------------
PROCEDURE move_bucket
  (p_line_entire       IN NUMBER,
   p_freight_entire    IN NUMBER,
   p_tax_entire        IN NUMBER,
   p_chrg_entire       IN NUMBER,
   --
   p_line_rem          IN NUMBER,
   p_freight_rem       IN NUMBER,
   p_tax_rem           IN NUMBER,
   p_chrg_rem          IN NUMBER,
   --
   p_which_bucket      IN VARCHAR2,
   p_currency          IN VARCHAR2,
   --
   x_line_entire       OUT NOCOPY NUMBER,
   x_freight_entire    OUT NOCOPY NUMBER,
   x_tax_entire        OUT NOCOPY NUMBER,
   x_chrg_entire       OUT NOCOPY NUMBER);

---------------------------------------
-- PROCEDURE lease_app_bucket_amts
---------------------------------------
-- This a wrapper which will lease the entire application amt buckets
-- based on the remaining of the transaction
--------------
-- For example :
--  The application has
--   ED + UNED + APP for line    - x_line_entire   => 100
--   ED + UNED + APP for freight - x_freight_entire=> 30
--   ED + UNED + APP for tax     - x_tax_entire    => 16
--   ED + UNED + APP for chrg    - x_chrg_entire   => 6
--------------
--  The transaction has remaining
--    on line      p_line_rem          => 200
--    on freight   p_freight_rem       => 30
--    on tax       p_tax_rem           => 15
--    on charges   p_chrg_rem          => 3
----------------
--  sum all rem > sum all entire buckets ==> no over applications - OK
--  The result will be
--   x_line_entire      => 104
--   x_freight_entire   => 30
--   x_tax_entire       => 15
--   x_chrg_entire      => 3
--  Note in this example the surplus from tax and charges are absorbed by line buckets
----------------------------------------
PROCEDURE lease_app_bucket_amts
(p_line_rem          IN NUMBER,
 p_tax_rem           IN NUMBER,
 p_freight_rem       IN NUMBER,
 p_chrg_rem          IN NUMBER,
 --
 p_currency          IN VARCHAR2,
 --
 x_line_entire       IN OUT NOCOPY NUMBER,
 x_tax_entire        IN OUT NOCOPY NUMBER,
 x_freight_entire    IN OUT NOCOPY NUMBER,
 x_chrg_entire       IN OUT NOCOPY NUMBER);


PROCEDURE stamping_11i_mfar_app_post;

PROCEDURE stamping_11i_cash_app_post;

END;

/
