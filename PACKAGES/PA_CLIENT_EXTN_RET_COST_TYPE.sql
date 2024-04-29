--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_RET_COST_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_RET_COST_TYPE" AUTHID CURRENT_USER AS
--$Header: PACCXRCS.pls 115.2 2003/08/18 14:31:23 ajdas noship $

FUNCTION RETIREMENT_COST_TYPE
                          (p_expenditure_item_id    IN      NUMBER,
                           p_cdl_line_number        IN      NUMBER,
                           p_expenditure_type       IN      VARCHAR2) RETURN VARCHAR2;

END;

 

/
