--------------------------------------------------------
--  DDL for Package INVIDIT4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVIDIT4" AUTHID CURRENT_USER as
/* $Header: INVIDI4S.pls 115.0 99/07/16 10:54:17 porting ship $ */

FUNCTION get_struct_num_flex
  ( appl_name  in varchar2,
    flex_code  in varchar2,
    struct_num in number,
    cc_id      in number
  ) return BOOLEAN;

FUNCTION get_data_set_flex
  ( appl_name  in varchar2,
    flex_code  in varchar2,
    data_set   in number,
    cc_id      in number
  ) return BOOLEAN;


END INVIDIT4;

 

/
