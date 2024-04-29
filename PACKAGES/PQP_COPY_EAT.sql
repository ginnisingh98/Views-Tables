--------------------------------------------------------
--  DDL for Package PQP_COPY_EAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_COPY_EAT" AUTHID CURRENT_USER AS
/* $Header: pqpcpext.pkh 115.0 2001/12/27 16:28:37 pkm ship        $ */

PROCEDURE copy_extract_attributes
	(p_curr_ext_dfn_id 	IN NUMBER
	,p_new_ext_dfn_id	IN NUMBER
	,p_ext_prefix 		IN VARCHAR2
	,p_business_group_id 	IN NUMBER
	);


END pqp_copy_eat;

 

/
