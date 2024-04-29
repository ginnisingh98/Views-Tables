--------------------------------------------------------
--  DDL for Package GCS_TEMPLATES_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_TEMPLATES_DYNAMIC_PKG" AUTHID CURRENT_USER AS
/* $Header: gcstempdyns.pls 120.1 2005/10/30 05:19:12 appldev noship $ */
--
-- Package
--   GCS_TEMPLATES_DYNAMIC_PKG
-- Purpose
--   Package procedures for the Data Preparation Engine Program
-- History
--   08-Dec-03 Ying Liu    Created
--

  --
  -- Procedure
  --   Balance
  -- Purpose
  --   Balances the entry in question with the template specified.
  -- Arguments
  --   p_entry_header_id	Entry with the information to be balanced.
  --   p_template_record	Template of the balancing dimension account.
  --   p_bal_type_code		The balance type of the consolidation.
  --   p_hierarchy_id		The hierarchy on which the consolidation is
  --				being run.
  --   p_entity_id		The entity on which the consolidation is
  --				being run.
  --   p_threshold		Threshold under which you should balance. If
  --				the amount of difference is over the threshold
  --				then an exception will be raised.
  -- Example
  --   GCS_TEMPLATES_PKG.Balance(1, cta_temp)
  -- Notes
  --
  PROCEDURE Balance(
	p_entry_id      	NUMBER,
	p_template		GCS_TEMPLATES_PKG.TemplateRecord,
	p_bal_type_code		VARCHAR2,
	p_hierarchy_id		NUMBER,
	p_entity_id		NUMBER,
	p_threshold		NUMBER	DEFAULT 0,
        p_threshold_currency_code  VARCHAR2 DEFAULT NULL
);


   -- PROCEDURE
   --   calculate_re
   -- Purpose
   --   Retained Earnings Calculation
   -- Arguments
   --   p_entry_id     Entry Identifier
   --   p_hierarchy_id     Hierarchy Identifier
   --   p_bal_type_code     Balance Type Code: 'ACTUAL' or 'ADB'
   --   p_entity_id    Entity Identifer
   -- Notes
   --
      PROCEDURE calculate_re (
      p_entry_id        NUMBER,
      p_hierarchy_id    NUMBER,
      p_bal_type_code   VARCHAR2,
      p_entity_id       NUMBER,
      p_data_prep_flag  VARCHAR2 DEFAULT 'N'
   );

   PROCEDURE calculate_dp_re (
      p_entry_id        NUMBER,
      p_hierarchy_id    NUMBER,
      p_bal_type_code   VARCHAR2,
      p_entity_id       NUMBER,
      p_pre_cal_period_id    NUMBER,
      p_first_ever_data_prep    VARCHAR2
   );

END GCS_TEMPLATES_DYNAMIC_PKG;

 

/
