--------------------------------------------------------
--  DDL for Package INV_TM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TM" AUTHID CURRENT_USER AS
/* $Header: INVTMS.pls 120.0 2005/05/24 18:14:45 appldev noship $ */
 FUNCTION launch(
    program in varchar2,
    args in varchar2 default NULL,
    put1 in varchar2 default NULL,
    put2 in varchar2 default NULL,
    put3 in varchar2 default NULL,
    put4 in varchar2 default NULL,
    put5 in varchar2 default NULL,
    get1 in varchar2 default NULL,
    get2 in varchar2 default NULL,
    get3 in varchar2 default NULL,
    get4 in varchar2 default NULL,
    get5 in varchar2 default NULL,
    timeout in number default NULL,
    rc_field in varchar2 default NULL) return BOOLEAN;
END;

 

/
