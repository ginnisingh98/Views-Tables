--------------------------------------------------------
--  DDL for Package GCS_DATA_TEMPLATE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DATA_TEMPLATE_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsdtmanips.pls 120.2 2006/01/16 19:49:32 skamdar noship $ */
--
-- Package
--   GCS_DATA_TEMPLATE_UTIL_PKG
-- Purpose
--   Package procedures for the Data Template Manipulation Program
-- Notes
--   Data Template Replacement Program
--
  --
  -- Procedure
  --   GCS_REPLACE_DT_PROC
  -- Purpose
  --   Data Template Replacement Program.
  -- Arguments
  --   * None *
  -- Example
  --   GCS_DATA_TEMPLATE_UTIL_PKG.GCS_REPLACE_DT_PROC;
  -- Notes
  --
  procedure GCS_REPLACE_DT_PROC(
  x_errbuf  out nocopy varchar2,
  x_retcode  out nocopy varchar2);
END GCS_DATA_TEMPLATE_UTIL_PKG;

 

/
