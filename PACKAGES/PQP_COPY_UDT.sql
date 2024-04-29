--------------------------------------------------------
--  DDL for Package PQP_COPY_UDT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_COPY_UDT" AUTHID CURRENT_USER AS
/* $Header: pqpcpudt.pkh 115.0 2001/12/28 09:45:15 pkm ship        $ */

FUNCTION copy_user_table(p_curr_udt_id		IN NUMBER
			,p_udt_prefix		IN VARCHAR2
			,p_business_group_id	IN NUMBER
			) RETURN NUMBER;

END pqp_copy_udt;

 

/
