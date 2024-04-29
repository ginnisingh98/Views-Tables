--------------------------------------------------------
--  DDL for Package AR_GTA_ARTRX_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_GTA_ARTRX_PROC" AUTHID CURRENT_USER AS
--$Header: ARGRARTS.pls 120.0.12010000.3 2010/01/19 07:53:48 choli noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                      Redwood Shores, California, USA                      |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :                                                               |
--|                        ARRARTS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:                                                             |
--|                        This package provide the functionality to retrieve |
--|                        transaction data from Oracle Receivable against the|
--|                        condition defined in Setup Form.                   |
--|                                                                           |
--|                                                                           |
--|  HISTORY:                                                                 |
--|    20-APR-2005: Jim Zheng                                                 |
--|    11-Oct-2005: Jim Zheng.    Fix some bug after debug on DMFDV11i        |
--|    12/04/2006   Jogen Hu      Add function get_gta_number against bug     |
--|                               5144561                                     |
--|    18-Jun-2007: Yanping Wang  Modify g_module_prefix to use small case    |
--|                               of ar
--|    22/Jan/2009 Yao Zhang fix bug 	7829039 ITEM NAME ON GTA INVOICE LINE IS NULL                                     |
--+===========================================================================+



--==========================================================================
--  PROCEDURE NAME:
--               retrive_valid_AR_TRXs
--
--  DESCRIPTION:
--               This procedure is for invoices transfer concurrent implementation from Receivable to GTA
--
--  PARAMETERS:
--               In:  P_ORG_ID                NUMBER
--                    P_transfer_rule         NUMBER
--                    p_conc_parameters       AR_GTA_TRX_UTIL.transferParas_rec_type
--                    p_DEBUG                 VARCHAR2
--               OUT: errbuf                  varchar2
--                    retcode                 VARCHAR2

--  DESIGN REFERENCES:
--               GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--               20-APR-2005: Jim Zheng   Created.
--===========================================================================
PROCEDURE transfer_AR_to_GTA
( errbuf                  OUT NOCOPY	      VARCHAR2
, retcode	                OUT NOCOPY	      VARCHAR2
, P_ORG_ID                IN                NUMBER
, P_TRANSFER_id           IN                NUMBER
, p_conc_parameters       IN                AR_GTA_TRX_UTIL.transferParas_rec_type
);

--==========================================================================
--  PROCEDURE NAME:
--             Generate_XML_output
--
--  DESCRIPTION:
--             This procedure generate XML string as concurrent output from temporary table
--
--  PARAMETERS:
--             In:  P_ORG_ID                NUMBER
--                  p_transfer_id           NUMBER
--                  p_conc_parameters       AR_GTA_TRX_UTIL.transferParas_rec_type
--
--  DESIGN REFERENCES:
--             GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--             20-APR-2005: Jim Zheng   Created.
--===========================================================================
PROCEDURE Generate_XML_output
(p_org_id                          IN   NUMBER
, p_transfer_id                    IN   NUMBER
, p_conc_parameters                IN   AR_GTA_TRX_UTIL.transferParas_rec_type
);


--==========================================================================
--  API NAME:
--           retrive_valid_AR_TRXs
--
--  DESCRIPTION:
--           this procedure returns the valid Receivable VAT transaction
--
--  PARAMETERS:
--               In:  P_ORG_ID                NUMBER
--                    p_transfer_id           VARCHAR2
--                    p_conc_parameters       AR_GTA_TRX_UTIL.transferParas_rec_type
--               OUT: x_GTA_TRX_Tbl           AR_GTA_TRX_UTIL.TRX_TBL_TYPE

--  DESIGN REFERENCES:
--               GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--               20-APR-2005: Jim Zheng   Created.
--
--===========================================================================
PROCEDURE retrive_valid_AR_TRXs
( P_ORG_ID	          IN	        NUMBER
, p_transfer_id	      IN	        NUMBER
, p_conc_parameters	  IN	        AR_GTA_TRX_UTIL.transferParas_rec_type
, x_GTA_TRX_Tbl	      OUT NOCOPY	AR_GTA_TRX_UTIL.TRX_TBL_TYPE
);

--==========================================================================
--  PROCEDURE NAME:
--               Get_AR_SQL
--
--  DESCRIPTION:
--               This procedure returns the SQL for Receivable VAT transaction retrieval
--
--  PARAMETERS:
--               In:  P_ORG_ID                NUMBER
--                    p_transfer_id         VARCHAR2
--                    p_conc_parameters       AR_GTA_TRX_UTIL.transferParas_rec_type
--               OUT: x_query_sql           	VARCHAR2
--                    x_trxtype_parameter	    AR_GTA_TRX_UTIL.Condition_para_tbl_type
--                    x_flex_parameter        AR_GTA_TRX_UTIL.Condition_para_tbl_type
--                    x_other_parameter       AR_GTA_TRX_UTIL.Condition_para_tbl_type
--                    x_currency_code         VARCHAR2


--  DESIGN REFERENCES:
--               GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--               20-APR-2005: Jim Zheng   Created.
--
--===========================================================================
PROCEDURE Get_AR_SQL
( P_ORG_ID                IN        	NUMBER
, p_transfer_id	          IN	        NUMBER
, p_conc_parameters	      IN	        AR_GTA_TRX_UTIL.transferParas_rec_type
, x_query_sql           	OUT NOCOPY	VARCHAR2
, x_trxtype_parameter	    OUT NOCOPY	AR_GTA_TRX_UTIL.Condition_para_tbl_type
, x_flex_parameter        OUT NOCOPY	AR_GTA_TRX_UTIL.Condition_para_tbl_type
, x_other_parameter       OUT NOCOPY  AR_GTA_TRX_UTIL.Condition_para_tbl_type
, x_currency_code         OUT NOCOPY  VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--               Get_AR_TrxType_Cond
--
--  DESCRIPTION:
--               This procedure returns the WHERE clause about transaction type
--
--  PARAMETERS:
--               In:  P_ORG_ID                NUMBER
--                    p_transfer_id           VARCHAR2

--               OUT: x_condition_sql         Varchar2
--                    x_query_parameter       AR_GTA_TRX_UTIL.Condition_para_tbl_type


--  DESIGN REFERENCES:
--               GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--               20-APR-2005: Jim Zheng   Created.
--===========================================================================
PROCEDURE Get_AR_TrxType_Cond
( p_ORG_ID          IN	        NUMBER
, p_transfer_id	    IN	        NUMBER
, x_condition_sql	  OUT NOCOPY	VARCHAR2
, x_query_parameter	OUT NOCOPY	AR_GTA_TRX_UTIL.Condition_para_tbl_type
);



--==========================================================================
--  PROCEDURE NAME:
--               Get_AR_FLEX_COND
--
--  DESCRIPTION:
--               This procedure returns the WHERE clause about flexfield condition
--
--  PARAMETERS:
--               In:  P_ORG_ID                NUMBER
--                    p_transfer_id           VARCHAR2

--               OUT: x_condition_sql         Varchar2
--                    x_query_parameter       AR_GTA_TRX_UTIL.Condition_para_tbl_type


--  DESIGN REFERENCES:
--               GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--               20-APR-2005: Jim Zheng   Created.
--===========================================================================
PROCEDURE Get_AR_FLEX_COND
( P_ORG_ID          IN	        NUMBER
, p_transfer_id	    IN	        NUMBER
, x_condition_sql	  OUT NOCOPY	VARCHAR2
, x_query_parameter	OUT NOCOPY	AR_GTA_TRX_UTIL.Condition_para_tbl_type
);


--==========================================================================
--  PROCEDURE NAME:
--               Get_Param_Cond
--
--  DESCRIPTION:
--               This procedure returns the WHERE clause about request parameter and fixed condition
--
--  PARAMETERS:
--               In:  P_ORG_ID                NUMBER
--                    p_transfer_id           VARCHAR2
--                    p_conc_parameters       AR_GTA_TRX_UTIL.transferParas_rec_type

--               OUT: x_condition_sql         Varchar2
--                    x_query_parameter       AR_GTA_TRX_UTIL.Condition_para_tbl_type


--  DESIGN REFERENCES:
--               GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--               20-APR-2005: Jim Zheng   Created.
--
--===========================================================================
PROCEDURE Get_Param_Cond
( P_ORG_ID          IN	        NUMBER
, p_transfer_id	    IN	        NUMBER
, p_conc_parameters	IN	        AR_GTA_TRX_UTIL.transferParas_rec_type
, x_condition_sql	  OUT NOCOPY	VARCHAR2
, x_query_parameter	OUT NOCOPY	AR_GTA_TRX_UTIL.Condition_para_tbl_type
);

--==========================================================================
--  PROCEDURE NAME:
--               Get_AR_Currency_Cond
--
--  DESCRIPTION:
--               This procedure returns the WHERE clause about transaction Currency code
--
--  PARAMETERS:
--               In:  P_ORG_ID                NUMBER
--                    p_transfer_id           VARCHAR2

--               OUT: x_condition_sql         Varchar2
--                    x_currency_code 	      VARCHAR2


--  DESIGN REFERENCES:
--               GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--               17-AUG-2005: Jim Zheng   Created.
--===========================================================================
PROCEDURE Get_AR_Currency_Cond
( p_ORG_ID          IN	              NUMBER
, p_transfer_id	    IN	              NUMBER
, x_condition_sql	  OUT NOCOPY	      VARCHAR2
, x_currency_code 	OUT NOCOPY	      VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--               Retrieve_AR_TRXs
--
--  DESCRIPTION:
--               This procedure retrieve Receivable VAT transaction
--
--  PARAMETERS:
--               In:  P_ORG_ID                NUMBER
--                    p_transfer_id           VARCHAR2
--                    P_trxtype_para		      AR_GTA_TRX_UTIL.Condition_para_tbl_type
--                    p_flex_para             AR_GTA_TRX_UTIL.Condition_para_tbl_type
--                    p_other_para            AR_GTA_TRX_UTIL.Condition_para_tbl_type
--                    p_currency_code         IN          VARCHAR2
--               OUT: x_GTA_Trx_Tbl	         	AR_GTA_TRX_UTIL.TRX_TBL_TYPE


--  DESIGN REFERENCES:
--               GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--               20-APR-2005: Jim Zheng   Created.
--===========================================================================
PROCEDURE Retrieve_AR_TRXs
( p_org_id                IN          NUMBER
, p_transfer_id           IN          NUMBER
, P_query_SQL	            IN	        VARCHAR2
, P_trxtype_query_para	  IN	        AR_GTA_TRX_UTIL.Condition_para_tbl_type
, p_flex_query_para       IN          AR_GTA_TRX_UTIL.Condition_para_tbl_type
, p_other_query_para      IN          AR_GTA_TRX_UTIL.Condition_para_tbl_type
, p_currency_code         IN          VARCHAR2
, x_GTA_TRX_TBL	          OUT NOCOPY	AR_GTA_TRX_UTIL.TRX_TBL_TYPE
);

--==========================================================================
--  PROCEDURE NAME:
--                get_inv_item_model
--
--  DESCRIPTION:
--                This procedure get_item model by p_inventory_item_id and org_id
--
--  PARAMETERS:   p_org_id                 IN                  NUMBER
--                p_inventory_item_id      IN                  NUMBER
--                p_attribute_column       IN                  VARCHAR2
--                x_attribute_value        OUT NOCOPY          VARCHAR2

--  DESIGN REFERENCES:
--                GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--                20-APR-2005: Jim Zheng   Created.
--                22/Jan/2009  Yao Zhang  modified for bug 7829039
--
--===========================================================================
PROCEDURE get_inv_item_model
(
 p_item_master_org_id     IN                  NUMBER
 , p_inventory_item_id    IN                  NUMBER
 , p_attribute_column     IN                  VARCHAR2
 , x_attribute_value      OUT NOCOPY          VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--                get_ra_item_model
--
--  DESCRIPTION:
--                This procedure get_item model from ra line by ra_line_id and
--                attribute_column.  This procedure replace the dynamic sql
--
--  PARAMETERS:
--                p_ra_line_id             IN          NUMBER
--                p_attribute_column       IN          VARCHAR2
--                x_attribute_value        OUT NOCOPY  VARCHAR2

--  DESIGN REFERENCES:
--                GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--                20-APR-2005: Jim Zheng   Created.
--
--===========================================================================
PROCEDURE get_ra_item_model
( p_ra_line_id             IN          NUMBER
, p_attribute_column       IN          VARCHAR2
, x_attribute_value        OUT NOCOPY  VARCHAR2
);

--==========================================================================
--  FUNCTION NAME:
--                get_inventory_item_number
--
--  DESCRIPTION:
--                This procedure get item number by inventory_item_id
--
--  PARAMETERS:
--                p_inventory_item_id      IN                  NUMBER
--                p_org_id                 IN                  NUMBER
--                x_inventory_item_code    OUT NOCOPY          VARCHAR2
--
--  DESIGN REFERENCES:
--                GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--                20-APR-2005: Jim Zheng   Created.
--               22/Jan/2009  Yao Zhang  modified for bug 7829039
--===========================================================================
PROCEDURE get_inventory_item_number
( p_inventory_item_id   IN          NUMBER
, p_item_master_org_id              IN          NUMBER
, x_inventory_item_code OUT NOCOPY  VARCHAR2
);

--==========================================================================
--  FUNCTION NAME:
--                get_uom_name
--
--  DESCRIPTION:
--                This procedure get item number by inventory_item_id
--
--  PARAMETERS:
--          p_uom_code   IN         VARCHAR2
--          x_uom_name   OUT NOCOPY VARCHAR2
--
--  DESIGN REFERENCES:
--                GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--                11-Oct2005: Jim Zheng   Created.
--===========================================================================
PROCEDURE get_uom_name
(p_uom_code   IN         VARCHAR2
,x_uom_name   OUT NOCOPY VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--                Get_Taxinfo_From_Ebtax
--
--  DESCRIPTION:
--                This procedure get the tax info from ebtax by tax_line_id
--
--  PARAMETERS:
--                p_tax_line_id                      IN             NUMBER
--                x_taxable_amt                      OUT NOCOPY     NUMBER
--                x_taxable_amt_tax_curr             OUT NOCOPY     NUMBER
--                x_trx_line_quantity                OUT NOCOPY     NUMBER
--                x_unit_price                       OUT NOCOPY     NUMBER
--                x_tax_rate                         OUT NOCOPY     NUMBER
--                x_tax_amt_tax_curr                 OUT NOCOPY     NUMBER
--
--  DESIGN REFERENCES:
--                GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--                20-APR-2005: Jim Zheng   Created.
--===========================================================================
/*
PROCEDURE Get_Taxinfo_From_Ebtax
(p_tax_line_id                      IN             NUMBER
, x_taxable_amt                     OUT NOCOPY     NUMBER
, x_taxable_amt_tax_curr            OUT NOCOPY     NUMBER
, x_trx_line_quantity               OUT NOCOPY     NUMBER
, x_unit_price                      OUT NOCOPY     NUMBER
, x_tax_rate                        OUT NOCOPY     NUMBER
, x_tax_amt_tax_curr                OUT NOCOPY     NUMBER
);
*/

--==========================================================================
--  PROCEDURE NAME:
--                get_gta_number
--
--  DESCRIPTION:
--                This function get concated GTA number by a AR trx ID
--
--  PARAMETERS:
--                p_ar_trxId                      IN             NUMBER
--  RETURN:
--                varchar2                        concated GTA number
--
--  DESIGN REFERENCES:
--                GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--                12-APR-2006: Jogen Hu   Created.
--===========================================================================
FUNCTION get_gta_number(p_ar_trxId IN NUMBER)
RETURN VARCHAR2;

 --============================================================================

 -- PROCEDURE NAME:
--                 Get_Invoice_Type
--
-- DESCRIPTION:
--               This procedure returns the WHERE clause about Invoice Type using the
--               Invoice Type,Transaction Type mapping relationship defined in GTA
--               System Option.
--  PARAMETERS:
--           In:  P_ORG_ID                NUMBER
--                p_transfer_id           VARCHAR2

--           OUT: x_condition_sql         Varchar2
--  CHANGE HISTORY:
--               28-Dec-2007: Subba   Created.
-- ===========================================================================

PROCEDURE Get_Invoice_Type
( p_ORG_ID               IN               NUMBER
, p_transfer_id          IN               NUMBER
, x_condition_sql        OUT NOCOPY         VARCHAR2
);


G_MODULE_PREFIX VARCHAR2(100) := 'ar.plsql.AR_GTA_ARTRX_PROC';

END AR_GTA_ARTRX_PROC;

/
