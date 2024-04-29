--------------------------------------------------------
--  DDL for Package PA_MC_RETN_INV_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MC_RETN_INV_DETAIL_PKG" AUTHID CURRENT_USER as
/* $Header: PAMCRIDS.pls 115.1 2002/06/11 19:41:33 pkm ship        $*/
PROCEDURE Process_RetnInvDetails(p_project_id 		IN NUMBER,
			         p_draft_invoice_num	IN NUMBER,
				 p_action		IN VARCHAR2,
				 p_request_id		IN NUMBER);
END PA_MC_RETN_INV_DETAIL_PKG;

 

/
