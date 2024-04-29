--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_RPT_SPR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_RPT_SPR_PVT" AUTHID CURRENT_USER AS
--$Header: JMFVSPRS.pls 120.1 2005/10/19 18:16:30 vchu noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFVSPRS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Specification file of the package for creating     |
--|                        temporary data for the SHIKYU Subcontracting       |
--|                        Order Report.                                      |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   28-MAY-2005          fwang  Created.                                    |
--+===========================================================================+
  --========================================================================
  -- PROCEDURE : spr_load_subcontracting_po     PUBLIC
  -- PARAMETERS: p_ou_id                     operating unit id
  --           : p_report_type               print selection
  --           : p_po_num_from               po number from
  --           : p_po_num_to                 po number to
  --           : p_agent_name_num            agent number
  --           : p_cancel_line               print cancel line
  --           : p_approved_flag             approved
  -- COMMENT   : get shikyu subcontracting data and insert into temp table
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE spr_load_subcontracting_po
  (
    p_ou_id          IN NUMBER
   ,p_report_type    IN VARCHAR2
   ,p_po_num_from    IN VARCHAR2
   ,p_po_num_to      IN VARCHAR2
   ,p_agent_name_num IN NUMBER
   ,p_cancel_line    IN VARCHAR2
   ,p_approved_flag  IN VARCHAR2
  );
END jmf_shikyu_rpt_spr_pvt;


 

/
