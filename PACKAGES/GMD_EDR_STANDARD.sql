--------------------------------------------------------
--  DDL for Package GMD_EDR_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_EDR_STANDARD" AUTHID CURRENT_USER AS
/* $Header: GMDERDSS.pls 115.2 2003/10/14 20:15:52 ssitaram noship $ */

PROCEDURE raise_event (p_event_name      in varchar2,
                       p_event_key        in varchar2,
                       p_parameter_name1  in varchar2  default NULL,
                       p_parameter_value1 in varchar2  default NULL,
                       p_parameter_name2  in varchar2  default NULL,
                       p_parameter_value2 in varchar2  default NULL,
                       p_parameter_name3  in varchar2  default NULL,
                       p_parameter_value3 in varchar2  default NULL,
                       p_parameter_name4  in varchar2  default NULL,
                       p_parameter_value4 in varchar2  default NULL,
                       p_parameter_name5  in varchar2  default NULL,
                       p_parameter_value5 in varchar2  default NULL,
                       p_parameter_name6  in varchar2  default NULL,
                       p_parameter_value6 in varchar2  default NULL,
                       p_parameter_name7  in varchar2  default NULL,
                       p_parameter_value7 in varchar2  default NULL,
                       p_parameter_name8  in varchar2  default NULL,
                       p_parameter_value8 in varchar2  default NULL,
                       p_parameter_name9  in varchar2  default NULL,
                       p_parameter_value9 in varchar2  default NULL,
                       p_parameter_name10  in varchar2 default NULL,
                       p_parameter_value10 in varchar2 default NULL);

end GMD_EDR_STANDARD;

 

/
