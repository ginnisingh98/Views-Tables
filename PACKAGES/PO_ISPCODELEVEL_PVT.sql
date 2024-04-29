--------------------------------------------------------
--  DDL for Package PO_ISPCODELEVEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ISPCODELEVEL_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_ISPCODELEVEL_PVT.pls 120.0.12010000.2 2010/02/11 10:33:42 sthoppan noship $ */

--Following constants value is being used to identity the value of code level
-- These constants can be used by calling product for comparison of code levels and
-- derived their own logic based on funtionality

G_ISP_SUP_CODE_LEVEL_R12_BASE CONSTANT NUMBER  := 10;
G_ISP_SUP_CODE_LEVEL_R121_BASE CONSTANT NUMBER := 20;
G_ISP_SUP_CODE_LEVEL_CLM_BASE CONSTANT NUMBER  := 30;


--Function helps to obtain the current code level of isp supplier
FUNCTION get_curr_isp_supp_code_level
RETURN NUMBER;

END PO_ISPCODELEVEL_PVT;

/
