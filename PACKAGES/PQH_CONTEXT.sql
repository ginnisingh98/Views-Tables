--------------------------------------------------------
--  DDL for Package PQH_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CONTEXT" AUTHID CURRENT_USER as
/* $Header: pqhcntxt.pkh 120.0 2005/05/29 02:02:40 appldev noship $ */
 function get_global_context (p_context in varchar2) return varchar2;
end;

 

/
