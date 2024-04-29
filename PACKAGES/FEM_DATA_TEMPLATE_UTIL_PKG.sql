--------------------------------------------------------
--  DDL for Package FEM_DATA_TEMPLATE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DATA_TEMPLATE_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_intg_dtmanip.pls 120.0 2008/01/10 12:34:25 hakumar noship $ */
  --
  -- Package
  --   FEM_DATA_TEMPLATE_UTIL_PKG
  -- Purpose
  --   Package procedures for the Data Template Manipulation Program
  -- Notes
  --   Data Template Replacement Program
  --

  --
  -- Procedure
  --   REPLACE_DT_PROC
  -- Purpose
  --   Data Template Replacement Program.
  -- Arguments
  --   * None *
  -- Example
  --   fem_data_template_util_pkg.replace_dt_proc;
  -- Notes
  --
  procedure replace_dt_proc( x_errbuf  out nocopy varchar2,
                             x_retcode  out nocopy varchar2
                            );

END FEM_DATA_TEMPLATE_UTIL_PKG;

/
