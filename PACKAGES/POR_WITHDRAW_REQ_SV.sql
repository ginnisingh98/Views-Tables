--------------------------------------------------------
--  DDL for Package POR_WITHDRAW_REQ_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_WITHDRAW_REQ_SV" AUTHID CURRENT_USER AS
/* $Header: PORWDRS.pls 115.0 2000/09/12 17:38:24 pkm ship       $*/
/******************************************************************
 **  Function :     Rebuild_Requisition
 **  Description :  This is a function called from Java layer
 **                 It will use the information of the new
 **                 requisition to restore the existing one.
 ******************************************************************/

function Rebuild_Requisition(
		p_new_requisition_id       in number,
                p_existing_requisition_id  in number,
			p_agentId	   in number) return number;

PROCEDURE withdraw_req (p_headerId    	in  NUMBER);

END POR_WITHDRAW_REQ_SV;

 

/
