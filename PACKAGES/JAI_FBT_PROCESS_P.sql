--------------------------------------------------------
--  DDL for Package JAI_FBT_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_FBT_PROCESS_P" AUTHID CURRENT_USER AS
--$Header: jainfbtprc.pls 120.0.12010000.2 2008/11/27 04:32:44 huhuliu ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     jai_fbt_process_p.pls                                             |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     To fetch eligible ap invoices for FBT assessment and calculate    |
--|     the tax and insert data into jai_fbt_repository table             |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Fbt_Inv_Process                                        |
--|      FUNCTION  Get_Natural_Acc_Seg                                    |
--|      FUNCTION  Check_Inv_Validation                                   |
--|                                                                       |
--| HISTORY                                                               |
--|     2007/10/11 Kevin Cheng     Created                                |
--|                                                                       |
--+======================================================================*/

-- Declare global variable for package name
GV_MODULE_PREFIX VARCHAR2(50) :='jai.plsql.JAI_FBT_PROCESS_P';
GV_DATE_MASK  CONSTANT VARCHAR2(25) := 'DD-MON-YYYY';

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Natural_Acc_Seg                       Public
--
--  DESCRIPTION:
--
--    This function is used to get the natural account segment value
--
--  PARAMETERS:
--      In:  pv_col_name            Identifier of natural account name
--           pn_ccid                Identifier of code combination id
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           11-OCT-2007   Kevin Cheng  created

FUNCTION Get_Natural_Acc_Seg
( pv_col_name IN VARCHAR2
, pn_ccid     IN NUMBER
)
RETURN VARCHAR2;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Balance_Acc_Seg                       Public
--
--  DESCRIPTION:
--
--    This function is used to get the balance account segment value
--
--  PARAMETERS:
--      In:  pv_col_name            Identifier of natural account name
--           pn_ccid                Identifier of code combination id
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           11-AUG-2008   Xiao Lv  created

FUNCTION Get_Balance_Acc_Seg
( pv_col_name IN VARCHAR2
, pn_ccid     IN NUMBER
)
RETURN VARCHAR2;


--==========================================================================
--  FUNCTION NAME:
--
--    Check_Inv_Validation                       Public
--
--  DESCRIPTION:
--
--    This function checks whether the invoice is validate or not
--
--  PARAMETERS:
--      In:  pn_invoice_id            Identifier of ap invoices
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           11-OCT-2007   Kevin Cheng  created

FUNCTION Check_Inv_Validation
( pn_invoice_id IN NUMBER
)
RETURN VARCHAR2;

--==========================================================================
--  PROCEDURE NAME:
--
--    Fbt_Inv_Process                       Public
--
--  DESCRIPTION:
--
--    This is the main procedure which will be called by the concurrent
--    program to check eligible invoices, calculate FBT taxes and insert
--    data into jai_fbt_repository table
--
--  PARAMETERS:
--      In:  pn_legal_entity_id          Identifier of legal entity
--           pv_start_date               Identifier of period start date
--           pv_end_date                 Identifier of period end date
--           pv_fringe_benefit_type_code Identifier of FB type code
--           pv_generate_return          Identifier of supplier id
--
--      Out: pv_errbuf           Returns the error if concurrent program
--                               does not execute completely
--           pv_retcode          Returns success or failure
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           11-OCT-2007   Kevin Cheng  created
--           06-NOV-2008   Xiao Lv      modified

PROCEDURE Fbt_Inv_Process
( pv_errbuf                   OUT NOCOPY VARCHAR2
, pv_retcode                  OUT NOCOPY VARCHAR2
, pn_legal_entity_id          IN  NUMBER
, pn_fbt_year                 IN  NUMBER
, pv_start_date               IN  VARCHAR2
, pv_end_date                 IN  VARCHAR2
, pv_fringe_benefit_type_code IN  VARCHAR2
);

END JAI_FBT_PROCESS_P;

/
