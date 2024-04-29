--------------------------------------------------------
--  DDL for Package IGIPREC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIPREC" AUTHID CURRENT_USER AS
-- $Header: igiprecs.pls 115.7 2002/11/18 14:08:44 panaraya ship $ --

PROCEDURE Submit(
	           errbuf      		OUT NOCOPY VARCHAR2,
	           retcode     		OUT NOCOPY NUMBER,
                   p_gl_from_period     in gl_period_statuses.period_name%type,
                   p_gl_to_period	in gl_period_statuses.period_name%type
                  ) ;
     subtype glcontrol is gl_interface_control%rowtype;
    subtype glinterface is gl_interface%rowtype;


end  IGIPREC;

 

/
