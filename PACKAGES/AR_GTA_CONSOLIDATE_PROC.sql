--------------------------------------------------------
--  DDL for Package AR_GTA_CONSOLIDATE_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_GTA_CONSOLIDATE_PROC" AUTHID CURRENT_USER AS
--$Header: ARGRCONS.pls 120.0.12010000.3 2010/01/19 08:17:05 choli noship $
--+===========================================================================|
--|                    Copyright (c) 2002 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================|
--|                                                                           |
--|  FILENAME :                                                               |
--|                        ARRCONS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:                                                             |
--|                        This package is used to merge GTA invoice into     |
--|                        Consolidatation Invoices.                          |
--|                                                                           |
--|                                                                           |
--|  HISTORY:                                                                 |
--|    30-Jun-2009: Yao ZHang       Create                                    |
--|                                                                           |
--+===========================================================================+

--==========================================================================
  --  PROCEDURE NAME:
  --             Generate_XML_output
  --
  --  DESCRIPTION:
  --             This procedure generate XML string as concurrent output
  --             from temporary table
  --
  --  PARAMETERS:
  --             In:  P_ORG_ID           NUMBER
  --                  p_transfer_id      NUMBER
  --                  p_conc_parameters  AR_GTA_TRX_UTIL.transferParas_rec_type
  --
  --  DESIGN REFERENCES:
  --             GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --             20-APR-2005: Yao Zhang  Created.
--===========================================================================

PROCEDURE Generate_XML_output
(p_consolidation_paras IN AR_GTA_TRX_UTIL.consolparas_rec_type
);

--=============================================================================
-- PROCEDURE NAME:
--                create_consol_inv
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION: This procedure is used to Consolidate GTA invoices
--
--
-- PARAMETERS:
-- IN           p_consolidation_paras   AR_GTA_TRX_UTIL.consolparas_rec_type
--
--
-- HISTORY:
--                 30-Jun-2009 : Yao Zhang Create
--=============================================================================
PROCEDURE Create_Consol_Inv
(p_consolidation_paras IN AR_GTA_TRX_UTIL.consolparas_rec_type
);
G_MODULE_PREFIX VARCHAR2(50) := 'ar.plsql.AR_GTA_CONSOL_PROC';
END AR_GTA_CONSOLIDATE_PROC;


/
