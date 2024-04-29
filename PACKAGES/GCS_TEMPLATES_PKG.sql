--------------------------------------------------------
--  DDL for Package GCS_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_TEMPLATES_PKG" AUTHID CURRENT_USER AS
/* $Header: gcstemps.pls 120.1 2005/10/30 05:19:10 appldev noship $ */


--
-- Exceptions
--
  -- This generic exception will be raised by the procedure if the balancing
  -- fails. A message will already have been written.
  GCS_TMP_BALANCING_FAILED	EXCEPTION;

--
-- Types
--
  TYPE TemplateRecord IS RECORD (
    financial_elem_id	NUMBER,
    product_id		NUMBER,
    natural_account_id	NUMBER,
    channel_id		NUMBER,
    line_item_id	NUMBER,
    project_id		NUMBER,
    customer_id		NUMBER,
    task_id		NUMBER,
    user_dim1_id	NUMBER,
    user_dim2_id	NUMBER,
    user_dim3_id	NUMBER,
    user_dim4_id	NUMBER,
    user_dim5_id	NUMBER,
    user_dim6_id	NUMBER,
    user_dim7_id	NUMBER,
    user_dim8_id	NUMBER,
    user_dim9_id	NUMBER,
    user_dim10_id	NUMBER
);

--
-- Package
--   gcs_templates_pkg
-- Purpose
--   Package procedures for template-based calculations
-- History
--   22-DEC-03	M Ward		Created
--

   PROCEDURE create_dynamic_pkg (
      x_errbuf   IN              VARCHAR2,
      x_retcode  IN              VARCHAR2
   );

  --
  -- Procedure
  --   get_dimension_template
  -- Purpose
  --   Get the specified template of a hierarchy.
  -- Arguments
  --   p_hierarchy_id		ID of the hierarchy
  --   p_template_code		'RE' (Retained Earnings) or 'SUSPENSE'
  --   p_balance_type_code	Balance type of the consolidation
  --   p_template_record        Record to hold the template retrieved
  -- Example
  --   GCS_TEMPLATES_PKG.get_dimension_template(1000, 'RE', 'ADB', l_template);
  -- Notes
  --
  PROCEDURE get_dimension_template(
	p_hierarchy_id		NUMBER,
	p_template_code		VARCHAR2,
	p_balance_type_code	VARCHAR2,
	p_template_record	OUT NOCOPY TemplateRecord);
END GCS_TEMPLATES_PKG;

 

/
