--------------------------------------------------------
--  DDL for Package GCS_CREATE_DYN_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_CREATE_DYN_INDEX_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsdynidxs.pls 120.2 2006/06/16 11:38:40 vkosuri noship $ */
--
-- Package
--   GCS_CREATE_DYN_INDEX_PKG
-- Purpose
--   Package to create dynamic indexes
-- History
--   12-AUG-04   Rashmi Goyal
--

  --
  -- Procedure
  --   Create_Index
  -- Purpose
  --   Creates indices dynamically
  -- Arguments
  --   errbuf and retcode
  -- Example
  --   GCS_CREATE_DYN_INDEX_PKG.Create_Index( x_errbuf, x_retcode )
  -- Notes
  --
  PROCEDURE Create_Index(	x_errbuf	OUT NOCOPY VARCHAR2,
				x_retcode	OUT NOCOPY VARCHAR2);

  -- Bug fix : 5289002
  -- Procedure
  --   submit_request
  -- Purpose
  --   Submits the concurrent program Financial Consolidation Hub: Module Initialization
  -- Arguments --> p_request_id
  -- Example
  -- Notes
  --
  PROCEDURE submit_request(p_request_id OUT NOCOPY NUMBER);

END GCS_CREATE_DYN_INDEX_PKG ;

 

/
