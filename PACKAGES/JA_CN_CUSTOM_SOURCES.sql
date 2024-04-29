--------------------------------------------------------
--  DDL for Package JA_CN_CUSTOM_SOURCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_CUSTOM_SOURCES" AUTHID CURRENT_USER AS
  --$Header: JACNSCSS.pls 120.2.12010000.3 2009/06/01 09:42:45 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|      JACNSCSS.pls                                                     |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used to create customer source.                   |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|                                                                       |
  --|      PROCEDURE    Invoice_Category     PUBLIC                         |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      01/08/2007     yanbo liu         Created                         |
  --|      01/06/2009     Chaoqun Wu        Fixing bug#8478003
  --|                                                                       |
  --+======================================================================*/
   l_module_prefix              VARCHAR2(100) :='JA_CN_CUSTOM_SOURCES';
  --==========================================================================
  --  PROCEDURE NAME:
  --    Invoice_Category                 Public
  --
  --  DESCRIPTION:
  --    This procedure is used to return different source value according to
  --    invoice source input.
  --
  --  PARAMETERS:
  --      p_Invoice_Source               invoice source
  --      p_invoice_id                   invoice id
  --      p_invoice_line_number          invoice line number
  --      p_distribution_line_number     distribution line number
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --
  --===========================================================================
  FUNCTION Invoice_Category(p_Invoice_Source            IN VARCHAR2,
                            p_invoice_id                IN  NUMBER,
                            p_invoice_distribution_id   IN  NUMBER)
  RETURN VARCHAR2;

  FUNCTION GET_PROJECT_NUM(p_project_id IN NUMBER) --Fixing bug#8478003
  RETURN VARCHAR2;

end JA_CN_CUSTOM_SOURCES;


/
