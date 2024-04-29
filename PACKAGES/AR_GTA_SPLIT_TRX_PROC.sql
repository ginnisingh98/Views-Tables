--------------------------------------------------------
--  DDL for Package AR_GTA_SPLIT_TRX_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_GTA_SPLIT_TRX_PROC" AUTHID CURRENT_USER AS
--$Header: ARGRXTRS.pls 120.0.12010000.3 2010/01/19 08:56:43 choli noship $
--+===========================================================================|
--|                    Copyright (c) 2002 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================|
--|                                                                           |
--|  FILENAME :                                                               |
--|                        ARRXTRS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:                                                             |
--|                        This package is used to slipt the trx by some      |
--|                        condition such as tax rate, max_amount, max_line   |
--|                                                                           |
--|                                                                           |
--|  HISTORY:                                                                 |
--|    10-MAY-2005: Jim.Zheng       Create                                    |
--|    30-sep-2005: Jim zheng       modify because registration issue         |
--|    13-Oct-2005: Jim Zheng       fix get trx type bug                      |
--|    18-Jun-2007: Yanping Wang    Modify g_module_prefix to use small case  |
--|                                 of ar                                    |
--|    23-Jan-2009:Yao Zhang fix bug 7758496 CreditMemo whose line num exceeds|
--|                           max line number limitation should be transfered |
--|                           when sales list is enabled                      |
--|                                                                           |
--+===========================================================================+


--=============================================================================
-- PROCEDURE NAME :
--                 split_Transactions
-- TYPE :
--                 PUBLIC
--
-- DESCRIPTION:
--                 This procedure returns slpited tracsation by max_amount, max_lines
-- PARAMETERS :
--   P_ORG_ID           IN        org_id
--   p_transfer_id      IN        the transfer rule
--   P_GTA_TRX_Tbl      IN        a trx nested table as input
--   x_GTA_TRX_Tbl      OUT       a trx nestedt tabel as output
--
-- HISTORY:
--                      10-MAY-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE split_Transactions
( P_ORG_ID	                IN	        NUMBER
, p_transfer_id             IN          NUMBER
, P_GTA_TRX_Tbl	            IN	        AR_GTA_TRX_UTIL.TRX_TBL_TYPE
, x_GTA_TRX_Tbl	            OUT NOCOPY	AR_GTA_TRX_UTIL.TRX_TBL_TYPE
);


--=============================================================================
-- PROCEDURE NAME:
--               Copy_Header
-- TYPE:
--               PUBLIC
--
-- DESCRIPTION:
--              When split trx procedure new a trx, new a trx_header for the new trx
-- PARAMETERS :
--   p_GTA_TRX_Header_Rec           in        old trx_header
--   x_GTA_TRX_Header_Rec           out       new trx_header
--
-- HISTORY:
--              10-MAY-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE Copy_Header
( p_GTA_TRX_Header_Rec IN AR_GTA_TRX_UTIL.TRX_HEADER_REC_TYPE
, x_GTA_TRX_Header_Rec OUT NOCOPY AR_GTA_TRX_UTIL.TRX_HEADER_REC_TYPE
);



--=============================================================================
-- PROCEDURE NAME:
--            process_before_split
-- TYPE:
--            PUBLIC
--
-- DESCRIPTION:
--            When split trx procedure new a trx, the line_num, trx_num, trx_header_id alse
--            be change.
--
-- PARAMETERS:
--   x_gta_trx_rec     IN OUT NOCOPY       new trx which line number is changed
--
-- HISTORY:
--                      10-MAY-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE process_before_split
(
 x_gta_trx_rec     IN OUT NOCOPY                AR_Gta_Trx_Util.TRX_REC_TYPE
);



--=============================================================================
-- PROCEDURE NAME :
--                 split_nested_table
-- TYPE :
--                 PUBLIC
--
-- DESCRIPTION:
--                 a nested table hasn't a split method, this procedure make a
--                 split table method for TRX_Line_tbl_type
--                 be change.
-- PARAMETERS    :
--      p_trx_lines           in        source table
--      split_flag            in        the position of table which be split
--      x_first_lines         out       first party of demanation table
--      x_last_lines          out       last party of demanation table
--
-- HISTORY:
--                 10-MAY-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE split_nested_table
(p_trx_lines                IN              AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE
, p_split_flag              IN              NUMBER
, x_first_lines             OUT NOCOPY      AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE
, x_last_lines              OUT NOCOPY      AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE
);


--=============================================================================
-- PROCEDURE NAME:
--                add_succ_to_temp
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 insert a sucess row to temp table when a trx is due successed
--                 be change.
-- PARAMETERS:
--   p_gta_trx_rec         in   the successed trx
--
-- HISTORY:
--                 10-MAY-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE add_succ_to_temp
(
 p_gta_trx_rec   IN         AR_Gta_Trx_Util.TRX_REC_TYPE
);

--=============================================================================
-- PROCEDURE NAME:
--                split_trx_by_taxreg_number
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 split trx by first party registration number
-- PARAMETERS:
--   p_gta_trx         in   AR_GTA_TRX_UTIL.trx_rec_type
--   x_trx_tbl         out  AR_Gta_Trx_Util.trx_tbl_type
-- HISTORY:
--                 10-Sep-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE split_trx_by_taxreg_number
(p_gta_trx       IN               AR_GTA_TRX_UTIL.trx_rec_type
,x_trx_tbl       OUT NOCOPY       AR_Gta_Trx_Util.trx_tbl_type
);

--=============================================================================
-- PROCEDURE NAME:
--                split_trx_by_rate
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 split trx by tax rate
-- PARAMETERS:
--   p_gta_trx         in   AR_GTA_TRX_UTIL.trx_tbl_type
--   x_trx_tbl         out  AR_Gta_Trx_Util.trx_tbl_type
-- HISTORY:
--                 10-Sep-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE split_trx_by_rate
(p_gta_tbl       IN               AR_GTA_TRX_UTIL.trx_tbl_type
,x_trx_tbl       OUT NOCOPY       AR_Gta_Trx_Util.trx_tbl_type
);

--=============================================================================
-- PROCEDURE NAME:
--                get_trx_type
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 get trx type by trx id
-- PARAMETERS:
--   p_org_id          IN   NUMBER
--   p_gta_trx         in   AR_GTA_TRX_UTIL.trx_tbl_type
--   x_trx_type        out  ra_cust_trx_types_all.type%TYPE
-- HISTORY:
--                 10-Sep-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE get_trx_type
(p_org_id           IN           NUMBER
, p_gta_trx         IN           AR_Gta_Trx_Util.trx_rec_type
, x_trx_type        OUT  NOCOPY  ra_cust_trx_types_all.type%TYPE
);

--=============================================================================
-- PROCEDURE NAME:
--                judge_cm_limit
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 Judge wether the CM exceed the max line and max amount
-- PARAMETERS:
--   p_gta_trx         in   AR_GTA_TRX_UTIL.trx_tbl_type
--   p_org_id          in   number
--   x_result          out  BOOLEAN
-- HISTORY:
--                 10-Sep-2005 : Jim.Zheng  Create
--                 23-Jan-2009   Yao Zhang Changed for bug 7758496
--=============================================================================
PROCEDURE judge_cm_limit
(p_gta_trx    IN           AR_Gta_Trx_Util.trx_rec_type
, p_org_id    IN           NUMBER
, p_transfer_id IN          NUMBER --yao zhang changed for bug 7758496
, x_result    OUT  NOCOPY  BOOLEAN
);

--=============================================================================
-- PROCEDURE NAME:
--                judge_cm_limit
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 get max line and max amount by fp registration number
-- PARAMETERS:
--   p_gta_trx         in   AR_GTA_TRX_UTIL.trx_tbl_type
--   p_org_id          in   number
--   x_max_amount      in   number
--   x_max_line        in   number
-- HISTORY:
--                 10-Sep-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE get_max_amount_line
(p_gta_trx       IN           AR_Gta_Trx_Util.trx_rec_type
, p_org_id       IN           NUMBER
, x_max_amount   OUT NOCOPY   NUMBER
, x_max_line     OUT NOCOPY   NUMBER
);

--=============================================================================
-- PROCEDURE NAME:
--                fileter_credit_memo
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 filter credit memo which amount and lines number exceeded.
-- PARAMETERS:
--   p_org_id          in           number
--   p_gta_trx_tbl     in           ar_gta_trx_util.trx_tbl_type
--   x_gta_trx_tbl     out nocopy   ar_gta_trx_util.trx_tbl_type
--
-- HISTORY:
--                 10-Sep-2005 : Jim.Zheng  Create
--                 23-Jan-2009   Yao Zhang Changed for bug 7758496
--=============================================================================
PROCEDURE  filter_credit_memo
(p_org_id                IN          NUMBER
, p_transfer_id          IN          NUMBER--yao zhang changed for bug 7758496
, p_gta_trx_tbl          IN          ar_gta_trx_util.trx_tbl_type
, x_gta_Trx_tbl          OUT NOCOPY  ar_gta_trx_util.trx_tbl_type
);


G_MODULE_PREFIX VARCHAR2(50) := 'ar.plsql.AR_GTA_SPLIT_TRX_PROC';

END AR_GTA_SPLIT_TRX_PROC;

/
