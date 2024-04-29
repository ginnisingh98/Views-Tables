--------------------------------------------------------
--  DDL for Package JA_CN_JE_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_JE_EXP_PKG" AUTHID CURRENT_USER AS
  --$Header: JACNJEES.pls 120.0.12000000.1 2007/08/13 14:09:44 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 1998 Oracle Corporation
  --|                       Redwood Shores, CA, USA
  --|                         All rights reserved.
  --+=======================================================================
  --| FILENAME
  --|     JACNJEES.pls
  --|
  --| DESCRIPTION
  --|
  --|      This package is to provide share procedures for CNAO programs
  --|
  --| PROCEDURE LIST
  --|
  --|   PROCEDURE run_export
  --|   PROCEDURE gen_clauses
  --|   FUNCTION get_subsidiary_desc
  --|
  --|
  --| HISTORY
  --|   07-May-2007     Shujuan Yan Created
  --|
  --+======================================================================*/

  TYPE assoc_array_varchar1000_type IS TABLE OF VARCHAR2(1000) INDEX BY PLS_INTEGER;
  prefix_a CONSTANT VARCHAR2(10) := 'A';
  prefix_b CONSTANT VARCHAR2(10) := 'B';
  prefix_c CONSTANT VARCHAR2(10) := 'C';

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    run_export                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to export the journal entries.
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf                     Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode                    Mandatory parameter for PL/SQL concurrent programs
  --      In         p_coa_id                   Chart of Accounts Id
  --      In         p_ledger_id                Ledger Id
  --      In:        p_legal_entity             Legal entity ID
  --      In:        p_start_period             start period name
  --      In:        P_end_period               end period name
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      01-Mar-2006     Joseph Wang Created
  --      15-Jun-2006     Add parameters p_start_period and P_end_period
  --                      remove the parameter p_period
  --
  --===========================================================================

  PROCEDURE Run_Export(errbuf         OUT NOCOPY VARCHAR2
                      ,retcode        OUT NOCOPY VARCHAR2
                      ,p_coa_id       IN NUMBER
                      ,p_ledger_id    IN NUMBER
                      ,p_legal_entity_id IN NUMBER
                      ,p_start_period IN VARCHAR2
                      ,p_end_period   IN VARCHAR2);
  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    gen_clauses                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to generate the column names with or withouot
  --    prefix in order to complete the SQL statements which are used to query
  --    journal entries.
  --
  --  PARAMETERS:
  --      In Out:       p_column_clauses               Collection stores generated column clauses
  --      In Out:       p_prefix_column_clauses        Collection stores generated prefix column clauses
  --      In:           p_has_cost_center              'Y' or not indicates whether it is cost center subsidiary
  --      In:           p_has_third_party              'Y' or not indicates whether it is third party subsidiary
  --      In:           p_has_personnel                'Y' or not indicates whether it is personnel subsidiary
  --      In:           p_has_project                  'Y' or not indicates whether it is project subsidiary
  --      Out:          p_return_column_clause         Return value of generated column clause
  --      Out:          p_return_prefix_column_clause  Return value of generated prefix column clause
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      07-May-2007     Shujuan Yan Created
  --
  --===========================================================================

  PROCEDURE Gen_Clauses(p_column_clauses              IN OUT NOCOPY assoc_array_varchar1000_type
                       ,p_prefix_column_clauses       IN OUT NOCOPY assoc_array_varchar1000_type
                       ,p_has_cost_center             VARCHAR2
                       ,p_has_third_party             VARCHAR2
                       ,p_has_personnel               VARCHAR2
                       ,p_has_project                 VARCHAR2
                       ,p_return_column_clause        OUT NOCOPY VARCHAR2
                       ,p_return_prefix_column_clause OUT NOCOPY VARCHAR2);

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    get_subsidiary_desc                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to generate the subsidiary description.
  --
  --
  --  PARAMETERS:
  --      In:          p_cost_center           Cost center segment
  --      In:          p_third_party_number    Number of third party
  --      In:          p_personnel_number      Personnel number
  --      In:          p_project_number        Number of project
  --      In:          p_has_cost_center       'Y' or not indicates whether it is cost center subsidiary.
  --      In:          p_has_third_party       'Y' or not indicates whether it is third party subsidiary.
  --      In:          p_has_personnel         'Y' or not indicates whether it is personnel subsidiary.
  --      In:          p_has_project           'Y' or not indicates whether it is project subsidiary.
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      07-May-2007     Shujuan Yan Created
  --
  --===========================================================================
  FUNCTION Get_Subsidiary_Desc(p_cost_center        VARCHAR2
                              ,p_third_party_number VARCHAR2
                              ,p_personnel_number   VARCHAR2
                              ,p_project_number     VARCHAR2
                              ,p_has_cost_center    VARCHAR2
                              ,p_has_third_party    VARCHAR2
                              ,p_has_personnel      VARCHAR2
                              ,p_has_project        VARCHAR2) RETURN VARCHAR2;

END JA_CN_JE_EXP_PKG;

 

/
