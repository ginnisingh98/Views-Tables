--------------------------------------------------------
--  DDL for Package XNP_TIMERS$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_TIMERS$" AUTHID CURRENT_USER as
/* $Header: XNPWEBTS.pls 120.0 2005/05/30 11:51:03 appldev noship $ */


   procedure Startup;
   procedure FirstPage(Z_DIRECT_CALL in boolean);
   procedure ShowAbout;
   procedure TemplateHeader(Z_DIRECT_CALL in boolean,
                            Z_TEMPLATE_ID in number);
end;

 

/
