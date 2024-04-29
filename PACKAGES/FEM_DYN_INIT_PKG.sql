--------------------------------------------------------
--  DDL for Package FEM_DYN_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DYN_INIT_PKG" AUTHID CURRENT_USER AS
/* $Header: femdyninit.pls 120.0 2008/01/10 12:35:10 hakumar noship $ */
--
-- Package
--   FEM_DYN_INIT_PKG
-- Purpose
--   Package for dnamic initialization
-- History
--   12-JAN-07   HAKUMAR
--

  --
  -- Procedure
  --   Create_Index
  -- Purpose
  --   Creates indices dynamically
  -- Arguments
  --   errbuf and retcode
  -- Example
  --   FEM_DYN_INIT_PKG.main( x_errbuf, x_retcode )
  -- Notes
  --
  PROCEDURE main(	x_errbuf	OUT NOCOPY VARCHAR2,
                  x_retcode	OUT NOCOPY VARCHAR2);

END FEM_DYN_INIT_PKG ;

/
