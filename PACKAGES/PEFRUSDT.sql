--------------------------------------------------------
--  DDL for Package PEFRUSDT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PEFRUSDT" AUTHID CURRENT_USER as
/* $Header: pefrusdt.pkh 120.1 2005/06/15 01:58:29 sbairagi noship $ */
function get_table_value (p_bus_group_id      in number,
                          p_table_name        in varchar2,
                          p_col_name          in varchar2,
                          p_row_value         in varchar2,
                          p_effective_date    in date  default null)
         return varchar2;
pragma restrict_references (get_table_value,WNDS,WNPS);
--
END pefrusdt;

 

/
