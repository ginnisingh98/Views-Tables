--------------------------------------------------------
--  DDL for Package HXC_GET_NAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_GET_NAME" AUTHID CURRENT_USER as
/* $Header: hxcgetnm.pkh 115.1 2002/03/01 18:29:03 pkm ship      $ */

Function get_name
  (p_person_id          in number) Return varchar2;
  -- p_query_date         in date) Return number;

end hxc_get_name;

 

/
