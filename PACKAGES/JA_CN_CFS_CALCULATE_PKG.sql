--------------------------------------------------------
--  DDL for Package JA_CN_CFS_CALCULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_CFS_CALCULATE_PKG" AUTHID CURRENT_USER AS
--$Header: JACNCCES.pls 120.0.12010000.2 2008/10/28 06:12:13 shyan ship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation
--|                       Redwood Shores, CA, USA
--|                         All rights reserved.
--+=======================================================================
--| FILENAME
--|     JACNCCES.pls
--|
--| DESCRIPTION
--|
--|     This package contains the following PL/SQL tables/procedures/functions
--|     to implement calculation for main part of cash flow statement according
--|     to data that collected by 'Cash Flow Statement - Data Collection'
--|     program and stored in JA_CN_CFS_ACTIVITIES_ALL table, and rules defined
--|     in Cash Flow Statement Assignments form and Calculation window in FSG
--|     Row Set.
--|
--| TYPE LIEST
--|   G_PERIOD_NAME_TBL
--|
--| PROCEDURE LIST
--|   Populate_Period_Names
--|   Populate_Formula
--|   Categorize_Rows
--|   Calculate_Row_Amount
--|   Calculate_Rows_Amount
--|   Generate_Cfs_Xml
--|
--| HISTORY
--|   14-Mar-2006     Donghai Wang Created
--|   29-Aug-2008     Chaoqun Wu  CNAO Enhancement
--|                               Updated procedures Calculate_Row_Amount and Calculate_Rows_Amount
--|                               Added BSV parameter for CFS-Generation
--|   23-Sep-2008     Chaoqun Wu  Fix bug# 7427067
--|
--+======================================================================*/

TYPE G_PERIOD_NAME_TBL IS TABLE OF gl_periods.period_name%TYPE
INDEX BY BINARY_INTEGER;

--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Period_Names               Public
--
--  DESCRIPTION:
--
--      This procedure is to retrieve period names from gl_periods by the
--      parameter 'p_parameter' and the parameter p_balance_type, alternative
--      value is 'YTD/QTD/PTD'
--
--  PARAMETERS:
--      In:  p_set_of_bks_id     Identifier of GL set of book, a required
--                               parameter for FSG report
--           p_period_name       GL period Name
--           p_balace_type       Type of balance, available value is 'YTD/QTD/PTD'.
--                               a required parameter for FSG report
--
--     Out:  x_period_names      Qualified period names for cash flow statement
--                               calculation
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      14-Mar-2006     Donghai Wang Created
--
--===========================================================================

PROCEDURE Populate_Period_Names
(p_ledger_id   IN NUMBER
,p_period_name     IN VARCHAR2
,p_balance_type    IN VARCHAR2
,x_period_names    OUT NOCOPY JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Formula               Public
--
--  DESCRIPTION:
--
--      For Cash Flow Statement, user would define calculation rule for items
--      on 'FSG Rowset' form,  one item can be calculated by other items, it
--      can have multiple calculation lines. In one calculation line, user can
--      define a range for rows from low to high, or specify a specific row.
--      Also, rows selected in such calculation rules can be also items that
--      are calculated by other items. Just so, it is hard for calculating
--      directly. The procedure 'Populate_Formula' is used to convert involved
--      calculating items in calculation lines to most detailed items for all
--      calculated items, hereinto, most detailed items mean items that are
--      directly calculated by FSG account assignments or Cash Flow item assignments.
--
--  PARAMETERS:
--      In:  p_axis_set_id        Identifier of FSG Row Set
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      14-Mar-2006     Donghai Wang Created
--      23-Sep-2008     Chaoqun Wu  Fix bug# 7427067
--
--===========================================================================
PROCEDURE Populate_Formula
(p_coa     IN NUMBER  --Fix bug# 7427067
,p_axis_set_id     IN NUMBER
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Categorize_Rows               Public
--
--  DESCRIPTION:
--
--    The 'Categorize_Rows' procedure is to categorize rows in FSG rowsets that
--    are defined for Cash Flow statement with the following three types:
--        1.  Rows belong to subsidiary part of Cash Flow Statement
--        2.  Rows belong to main part of Cash Flow Statement
--        3.  Rows that have calculation on FSG rowset form, but those rows
--            involved in calculation respectively belong to above the type one
--            and the type two.
--
--  PARAMETERS:
--      In: p_legal_entity_id    Identifier of legal entity
--          p_axis_set_id        Identifier of FSG Row Set
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      14-Mar-2006     Donghai Wang Created
--
--===========================================================================
PROCEDURE Categorize_Rows
(p_coa     IN NUMBER
,p_axis_set_id         IN NUMBER
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Calculate_Row_Amount               Public
--
--  DESCRIPTION:
--
--    The procedure 'Calculate_Row_Amount' is used to calculate amount for a
--    specific cash flow item in the main part of cash flow statement according
--    to assignment in the table 'JA_CN_CFS_ASSIGNMENTS_ALL' and amount of detailed
--    cash flow item in the table 'JA_CN_CFS_ACTIVITIES_ALL'.
--
--  PARAMETERS:
--      In:  p_legal_entity_id   Identifier of legal entity
--           p_set_of_bks_id     Identifier of GL set of book, a required
--                               parameter for FSG report
--           p_axis_set_id       Identifier of FSG Row Set
--           p_axis_seq          Sequence number of FSG row
--
--           p_balace_type       Type of balance, available value is 'YTD/QTD/PTD'.
--                               a required parameter for FSG report
--           p_period_names      Qualified period names for cash flow statement
--                               calculation
--           p_rounding_option   Rounding option for amount in Cash Flow statement
--           p_internal_trx_flag To indicate if intercompany transactions
--                               should be involved in amount calculation
--                               of cash flow statement.
--
--
--     Out:  x_amount            Amount of cash flow item
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      14-Mar-2006     Donghai Wang Created
--
--===========================================================================
PROCEDURE Calculate_Row_Amount
(p_legal_entity_id    IN    NUMBER
,p_ledger_id      IN    NUMBER
,p_coa            IN    NUMBER-- ADDED BY LYB
,p_axis_set_id        IN    NUMBER
,p_axis_seq           IN    NUMBER
,p_period_names       IN    JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL
,p_rounding_option    IN    VARCHAR2
,p_balancing_segment_value IN VARCHAR2  --Added for CNAO Enhancement
--,p_internal_trx_flag  IN    VARCHAR2
,x_amount             OUT   NOCOPY NUMBER
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Calculate_Rows_Amount               Public
--
--  DESCRIPTION:
--
--    The procedure Calculate_Rows_Amount is used to calculate amount for items
--    in the main part of Cash Flow Statement.
--
--  PARAMETERS:
--      In: p_legal_entity_id           Identifier of legal entity
--          p_set_of_bks_id             Identifier of GL set of book, a required
--                                      parameter for FSG report
--          p_axis_set_id               Identifier of FSG Row Set
--          p_period_names              Qualified period names for cash flow statement
--                                      calculation
--          p_lastyear_period_names     Qualified period names in last year for cash
--                                      flow statement calculation
--          p_rounding_option           Rounding option for amount in Cash Flow statement
--          p_internal_trx_flag         To indicate if intercompany transactions
--                                      should be involved in amount calculation
--                                      of cash flow statement.
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      14-Mar-2006     Donghai Wang Created
--
--===========================================================================
PROCEDURE Calculate_Rows_Amount
(p_legal_entity_id       IN    NUMBER
,p_ledger_id         IN    NUMBER
,p_coa               IN    NUMBER
,p_axis_set_id           IN    NUMBER
,p_period_names          IN    JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL
,p_lastyear_period_names IN    JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL
,p_rounding_option       IN    VARCHAR2
,p_segment_override     IN VARCHAR2  --added for CNAO Enhancement
--,p_internal_trx_flag     IN    VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Generate_Cfs_Xml                  Public
--
--  DESCRIPTION:
--
--      The procedure Generate_Cfs_Xml is to generate xml output for main part of
--      cash flow statement by following format of FSG xml output.
--
--  PARAMETERS:
--      In: p_legal_entity_id           Identifier of legal entity
--          p_set_of_bks_id             Identifier of GL set of book, a required
--                                      parameter for FSG report
--          p_period_name               GL period Name
--          p_axis_set_id               Identifier of FSG Row Set
--          p_rounding_option           Rounding option for amount in Cash Flow statement
--          p_balance_type              Type of balance, available value is
--                                      'YTD/QTD/PTD'. a required parameter for FSG
--                                      report
--          p_internal_trx_flag         To indicate if intercompany transactions
--                                      should be involved in amount calculation
--                                      of cash flow statement.
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      14-Mar-2006     Donghai Wang Created
--
--===========================================================================
PROCEDURE Generate_Cfs_Xml
(p_legal_entity_id         IN         NUMBER
,p_ledger_id           IN         NUMBER
,p_period_name             IN         VARCHAR2
,p_axis_set_id             IN         NUMBER
,p_rounding_option         IN         VARCHAR2
,p_balance_type            IN         VARCHAR2
--,p_internal_trx_flag       IN         VARCHAR2
,p_coa                     IN         NUMBER
,p_segment_override        IN         VARCHAR2 --added for CNAO Enhancement
);

END JA_CN_CFS_CALCULATE_PKG;

/
