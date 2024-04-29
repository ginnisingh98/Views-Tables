--------------------------------------------------------
--  DDL for Package GCS_DYN_TB_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DYN_TB_VIEW_PKG" AUTHID CURRENT_USER AS
/* $Header: gcs_dyn_tb_vs.pls 120.1 2005/10/30 05:19:48 appldev noship $ */

--
-- Package
--   gcs_dyn_tb_view_pkg
-- Purpose
--   Dynamically creates view for the Data Submission Drilldown UI
-- History
--   07-JUN-05	M Ward		Created
--
  --
  -- Procedure
  --   Create_View
  -- Purpose
  --   Create the trial balance view based on the active dimensions
  -- Example
  --   GCS_DYN_TB_VIEW_PKG.Create_View(errbuf, retcode)
  -- Notes
  --
  PROCEDURE Create_View(
	x_errbuf	OUT NOCOPY	VARCHAR2,
	x_retcode	OUT NOCOPY	VARCHAR2);

END GCS_DYN_TB_VIEW_PKG;

 

/
