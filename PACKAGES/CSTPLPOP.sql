--------------------------------------------------------
--  DDL for Package CSTPLPOP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPLPOP" AUTHID CURRENT_USER AS
/* $Header: CSTLPOPS.pls 115.3 2002/11/07 21:35:47 awwang ship $ */
   FUNCTION po_price(l_org_id NUMBER, l_item_id NUMBER) RETURN NUMBER;
   PRAGMA restrict_references(po_price, wnds);
END CSTPLPOP;

 

/
