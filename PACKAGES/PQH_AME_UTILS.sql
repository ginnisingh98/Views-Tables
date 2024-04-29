--------------------------------------------------------
--  DDL for Package PQH_AME_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_AME_UTILS" AUTHID CURRENT_USER AS
/* $Header: pqameutl.pkh 120.0 2005/05/29 01:24:17 appldev noship $ */
--
--
g_item_type       hr_api_transactions.item_Type%Type;
g_item_key        hr_api_transactions.item_Key%Type;
g_process_name    hr_api_transactions.process_name%Type;
g_person_id       number(18);
g_creator_person_id number(18);
g_transaction_id  number(18);
g_function_id     number(18);
   function get_item_type( p_transaction_id in varchar2) return varchar2;
   function get_item_key( p_transaction_id in varchar2) return varchar2;
   function get_process_name( p_transaction_id in varchar2) return varchar2;
   function get_final_approver( p_transaction_id in varchar2) return varchar2;
   function get_requestor_person_id( p_transaction_id in varchar2) return varchar2;
END; -- Package Specification PQH_AME_UTILS

 

/
