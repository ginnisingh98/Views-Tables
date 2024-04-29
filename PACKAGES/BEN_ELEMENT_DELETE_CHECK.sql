--------------------------------------------------------
--  DDL for Package BEN_ELEMENT_DELETE_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELEMENT_DELETE_CHECK" AUTHID CURRENT_USER as
/* $Header: beneedck.pkh 120.0 2005/05/28 04:17:21 appldev noship $ */
procedure check_element_delete(p_element_entry_id IN NUMBER);
end ben_element_delete_check;

 

/
