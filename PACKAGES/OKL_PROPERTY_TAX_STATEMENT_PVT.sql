--------------------------------------------------------
--  DDL for Package OKL_PROPERTY_TAX_STATEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROPERTY_TAX_STATEMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPTSS.pls 120.1 2005/10/30 03:16:58 appldev noship $ */
  -- Procedure for Property Tax Report Generation
  -------------------------------------------------------------------------------
  -- PROCEDURE do_report
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : do_report
  -- Description     : This procedure generates the report for estimated property tax
  --                 :
  -- Business Rules  :
  -- Parameters      : p_errbuf, p_retcode, p_cont_num_from, p_cont_num_to, p_asset_name_from, p_asset_name_to
  -- Version         : 1.0
  -- History         : 20-OCT-2004 GIRAO created
  -- End of comments
  PROCEDURE do_report(p_errbuf            OUT  NOCOPY VARCHAR2,
                      p_retcode           OUT  NOCOPY NUMBER,
                      p_cont_num_from     IN   VARCHAR2,
                      p_cont_num_to       IN   VARCHAR2,
                      p_asset_name_from   IN   VARCHAR2,
                      p_asset_name_to     IN   VARCHAR2);

  -- Function for length formatting
  -------------------------------------------------------------------------------
  -- FUNCTION get_proper_length
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_proper_length
  -- Description     : This function formats the columns in the report
  --                 :
  -- Business Rules  :
  -- Parameters      : p_input_data, p_input_length, p_input_type
  -- Version         : 1.0
  -- History         : 20-OCT-2004 GIRAO created
  -- End of comments

  FUNCTION get_proper_length(p_input_data         IN   VARCHAR2,
                             p_input_length       IN   NUMBER,
                             p_input_type         IN   VARCHAR2) RETURN VARCHAR2;
END okl_property_tax_statement_pvt;

 

/
