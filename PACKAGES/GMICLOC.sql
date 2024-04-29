--------------------------------------------------------
--  DDL for Package GMICLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMICLOC" AUTHID CURRENT_USER AS
/* $Header: gmiclocs.pls 115.1 99/08/10 14:10:03 porting ship  $ */

PROCEDURE gmiclocu(p_whse_code VARCHAR2,
                  p_whse_addr_id  NUMBER,
                  p_whse_name VARCHAR2,
                  p_whse_phone VARCHAR2,
                  p_orgn_id NUMBER,
                  p_oper_unit_id NUMBER);

END;

 

/
