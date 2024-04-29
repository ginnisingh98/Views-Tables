--------------------------------------------------------
--  DDL for Package JA_CN_AB_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_AB_EXP_PKG" AUTHID CURRENT_USER AS
  --$Header: JACNABES.pls 120.0.12000000.1 2007/08/13 14:09:05 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 1998 Oracle Corporation
  --|                       Redwood Shores, CA, USA
  --|                         All rights reserved.
  --+=======================================================================
  --| FILENAME
  --|     JACNABES.pls
  --|
  --| DESCRIPTION
  --|
  --|      This package is to provide share procedures for CNAO programs
  --|
  --| PROCEDURE LIST
  --|
  --|   PROCEDURE run_export
  --|
  --|
  --| HISTORY
  --|   01-May-2007     Shujuan Yan Created
  --+======================================================================*/

  prefix_a CONSTANT VARCHAR2(10) := 'A';
  prefix_b CONSTANT VARCHAR2(10) := 'B';

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    run_export                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to export the account balances.
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf              Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode             Mandatory parameter for PL/SQL concurrent programs
  --      In:        p_legal_entity      Legal entity ID
  --      In:        p_start_period      start period name
  --      In:        P_end_period        end period name
  --      In: P_XML_TEMPLATE_LANGUAGE    template language of exception report
  --      In: P_XML_TEMPLATE_TERRITORY   template territory of exception report
  --      In: P_XML_OUTPUT_FORMAT        output format of exception report
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      07-May-2007     Shujuan Yan Created
  --
  --===========================================================================
  PROCEDURE Run_Export(errbuf                   OUT NOCOPY VARCHAR2
                      ,retcode                  OUT NOCOPY VARCHAR2
                      ,p_coa_id                 IN NUMBER
                      ,p_ledger_id              IN NUMBER
                      ,p_legal_entity           IN NUMBER
                      ,p_start_period           IN VARCHAR2
                      ,p_end_period             IN VARCHAR2
                      ,P_XML_TEMPLATE_LANGUAGE  IN VARCHAR2
                      ,P_XML_TEMPLATE_TERRITORY IN VARCHAR2
                      ,P_XML_OUTPUT_FORMAT      IN VARCHAR2);

END JA_CN_AB_EXP_PKG;

 

/
