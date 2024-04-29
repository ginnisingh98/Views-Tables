--------------------------------------------------------
--  DDL for Package CSTPPDOP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPDOP" AUTHID CURRENT_USER AS
/* $Header: CSTPDOPS.pls 115.2 2002/11/09 00:44:11 awwang ship $ */

FUNCTION validate_post_to_GL (
		p_org_id	IN	NUMBER,
		p_legal_entity	IN	NUMBER,
		p_cost_type_id	IN	NUMBER,
		p_options	IN	NUMBER
		)
RETURN	BOOLEAN;


END CSTPPDOP;

 

/
