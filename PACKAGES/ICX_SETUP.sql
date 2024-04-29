--------------------------------------------------------
--  DDL for Package ICX_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_SETUP" AUTHID CURRENT_USER AS
/* $Header: ICXDPARS.pls 120.0 2005/10/07 12:14:13 gjimenez noship $ */

PROCEDURE get_parameters;
PROCEDURE update_parameters(QuerySet in number,
			    HomeUrl  in varchar2,
			    WebEmail in varchar2,
                            MaxRows  in number,
			    WebUser  in number);

END ICX_SETUP;

 

/
