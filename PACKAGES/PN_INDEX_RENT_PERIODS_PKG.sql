--------------------------------------------------------
--  DDL for Package PN_INDEX_RENT_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_INDEX_RENT_PERIODS_PKG" AUTHID CURRENT_USER AS
-- $Header: PNINRPRS.pls 120.5 2007/05/14 06:51:19 hrodda ship $

-- +================================================================+
-- |                Copyright (c) 2001 Oracle Corporation
-- |                   Redwood Shores, California, USA
-- |                        All rights reserved.
-- +================================================================+
-- |  Name
-- |    pn_index_rent_periods_pkg
-- |
-- |  Description
-- |    This package contains procedures used to maintain index rent periods
-- |
-- |
-- |  History
-- |  27-MAR-2001 jreyes    o Created
-- |  22-jul-2001  psidhu   o Added procedure PROCESS_PAYMENT_TERM_AMENDMENT.
-- |
-- |  08-Mar-2002 lkatputu  o Added the following lines at the beginning.
-- |                          Added for ARU db drv auto generation
-- |  19-JAN-2006 piagrawa  o Bug#4931780 - Modified signature of
-- |                        process_main_lease_term_date
-- |  03-ARP-2007 Hareesha  o Bug # 5960582 Added handle_term_end_dates
-- +================================================================+

   PROCEDURE generate_periods_batch (
      errbuf               OUT NOCOPY      VARCHAR2
     ,retcode              OUT NOCOPY      VARCHAR2
     ,ip_index_lease_num   IN       VARCHAR2
     ,ip_regenerate_yn     IN       VARCHAR2);

   PROCEDURE generate_periods (
      ip_index_lease_id   IN       NUMBER
     ,op_msg              OUT NOCOPY      VARCHAR2);

   PROCEDURE print_basis_periods (
      p_index_lease_id   NUMBER);


------------------------------------------------------------------------
-- PROCEDURE : UNDO_PERIODS
------------------------------------------------------------------------
   PROCEDURE undo_periods (
      p_index_lease_id   IN       NUMBER
     ,p_msg              OUT NOCOPY      VARCHAR2);


------------------------------------------------------------------------
-- PROCEDURE : process_new_termination_date
------------------------------------------------------------------------
   PROCEDURE process_new_termination_date (
      p_index_lease_id          IN       NUMBER
     ,p_new_termination_date    IN       DATE
     ,p_ignore_approved_terms   IN       VARCHAR2 --DEFAULT 'N'
     ,p_msg                     OUT NOCOPY      VARCHAR2);

   ------------------------------------------------------------------------
-- PROCEDURE : generate_basis_data_check
------------------------------------------------------------------------
   PROCEDURE generate_basis_data_check (
      p_index_lease_id   IN       NUMBER
     ,p_msg              OUT NOCOPY      VARCHAR2);


------------------------------------------------------------------------
-- PROCEDURE : process_main_lease_term_date
-- DESCRIPTION:  This procedure will be called every time a new termination
--                 create periods for an index rent
-- 18-APR-07    sdmahesh        o Bug # 5985779. Enhancement for new profile
--                                option for lease early termination.
--                                Added p_term_end_dt
------------------------------------------------------------------------
   PROCEDURE process_main_lease_term_date (
      p_lease_id                   IN       NUMBER
     ,p_new_main_lease_term_date   IN       DATE
     ,p_old_main_lease_term_date   IN       DATE
     ,p_lease_context              IN       VARCHAR2
     ,p_msg                        OUT NOCOPY      VARCHAR2
     ,p_cutoff_date                IN       DATE DEFAULT NULL
     ,p_term_end_dt                IN       DATE DEFAULT NULL);

------------------------------------------------------------------------
-- PROCEDURE : DELETE_PERIODS
-- DESCRIPTION:  This procedure will create periods for an index rent
--
-- 11-MAY-07  Hareesha     o Bug6042299 Added parameter p_new_termination_date
------------------------------------------------------------------------
   PROCEDURE delete_periods (
      p_index_lease_id          IN   NUMBER
     ,p_index_period_id         IN   NUMBER
     ,p_ignore_approved_terms   IN   VARCHAR2
     ,p_new_termination_date    IN   DATE DEFAULT NULL);

------------------------------------------------------------------------
-- PROCEDURE : process_payment_term_amendment
-- DESCRIPTION: This procedure is used by the PNTLEASE form to recalculate index
--              rent amount when a payment term is added from the main lease.
--
------------------------------------------------------------------------

   PROCEDURE process_payment_term_amendment (
      p_lease_id                        IN      NUMBER
     ,p_payment_type_code               IN      VARCHAR2 --payment_fdr_blk.payment_term_type_code
     ,p_payment_start_date              IN      DATE
     ,p_payment_end_date                IN      DATE
     ,p_msg                             OUT NOCOPY      VARCHAR2) ;

-------------------------------------------------------------------------------
-- PROCEDURE handle_MTM_ACT
-- DESCRIPTION: This procedure handling of RI terms when lease changes from
--              MTM/HLD to ACT and lease is extended.
--
-------------------------------------------------------------------------------
PROCEDURE handle_MTM_ACT (
      p_lease_id          IN         NUMBER
     ,p_extended          IN OUT NOCOPY BOOLEAN
     ,x_return_status     OUT NOCOPY VARCHAR2);


-------------------------------------------------------------------------------
-- PROCEDURE handle_term_end_dates
-- DESCRIPTION: This procedure handles Term-end-dates of RI terms on change of
--              agreement termination date.
-------------------------------------------------------------------------------
PROCEDURE handle_term_date_change (
      p_index_lease_id        IN    NUMBER
      ,p_old_termination_date IN    DATE
      ,p_new_termination_date IN    DATE
      ,p_msg                  OUT NOCOPY VARCHAR2);


END pn_index_rent_periods_pkg;

/
