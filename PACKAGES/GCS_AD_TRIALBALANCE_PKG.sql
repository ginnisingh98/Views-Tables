--------------------------------------------------------
--  DDL for Package GCS_AD_TRIALBALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_AD_TRIALBALANCE_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsadtbs.pls 120.2 2006/05/29 06:47:28 vkosuri noship $ */
--
-- Package
--   gcs_ad_trialbalance_pkg
-- Purpose
--   Package procedures for the AD Trial Balance Program
-- History
--   25-OCT-03 Ying Liu    Created
--
  --
  -- Procedure
  --   Import
  -- Purpose
  --   Import trial balances data to GCS_AD_TRIAL_BALANCES table
  -- Arguments
  -- p_xns_id ad_transaction_id
  --
  -- Bug fix : 5169619  -- data type of p_xns_id(_char) changed to VARCHAR2
   PROCEDURE import (
      x_errbuf    OUT NOCOPY      VARCHAR2,
      x_retcode   OUT NOCOPY      VARCHAR2,
      p_xns_id_char               IN   VARCHAR2,
      p_entry_name                IN   VARCHAR2,
      p_description               IN   VARCHAR2,
      p_consideration_amount      IN   NUMBER,
      p_currency_code             IN   VARCHAR2,
      p_hierarchy_id              IN   NUMBER,
      p_consolidation_entity_id   IN   NUMBER
   );
  --
  -- Procedure
  --   Import
  -- Purpose
  --   Import AD manual adjustments data
  -- Arguments
  -- p_xns_id ad_transaction_id
  --
  -- Bug fix : 5169619  -- data type of p_xns_id(_char) changed to VARCHAR2
   PROCEDURE Import_Entry (
      x_errbuf    OUT NOCOPY      VARCHAR2,
      x_retcode   OUT NOCOPY      VARCHAR2,
      p_xns_id_char               IN   VARCHAR2,
      p_entry_name                IN   VARCHAR2,
      p_description               IN   VARCHAR2,
      p_consideration_amount      IN   NUMBER,
      p_currency_code             IN   VARCHAR2,
      p_hierarchy_id              IN   NUMBER,
      p_consolidation_entity_id   IN   NUMBER,
      p_operating_entity_id       IN   NUMBER
   );


   --
   -- Procedure
   --   upload_header
   -- Purpose
   --   Upload Web ADI AD Trial Balances header data
   -- Arguments
   -- p_xns_id ad_transaction_id
   --
   -- Bug fix : 5169619  -- data type of p_xns_id(_char) changed to VARCHAR2
   PROCEDURE upload_header (
      p_consolidation_entity_id   IN   NUMBER,
      p_hierarchy_id              IN   NUMBER,
      p_transaction_date          IN   VARCHAR2,
      p_currency_code             IN   VARCHAR2,
      p_xns_id_char               IN   VARCHAR2,
      p_category_code             IN   VARCHAR2,
      p_template_type             IN   VARCHAR2,
      p_entry_name                IN   VARCHAR2,
      p_operating_entity_id       IN   NUMBER,
      p_consideration_amount      IN   NUMBER,
      p_description               IN   VARCHAR2 );

   --
   -- Procedure
   --   undo_elim_adj
   -- Purpose
   --   An API to undo an elimination adjustment
   -- Arguments
   -- Notes
   --
   PROCEDURE undo_elim_adj (
      p_xns_id     IN              NUMBER,
      x_errbuf     OUT NOCOPY      VARCHAR2,
      x_retcode    OUT NOCOPY      VARCHAR2
   );

END gcs_ad_trialbalance_pkg;

 

/
