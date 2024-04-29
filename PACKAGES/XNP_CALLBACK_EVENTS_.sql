--------------------------------------------------------
--  DDL for Package XNP_CALLBACK_EVENTS$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_CALLBACK_EVENTS$" AUTHID CURRENT_USER as
/* $Header: XNPWEBCS.pls 120.0 2005/05/30 11:52:41 appldev noship $ */


   procedure Startup;
   procedure FirstPage(Z_DIRECT_CALL in boolean);
   procedure ShowAbout;
   procedure TemplateHeader(Z_DIRECT_CALL in boolean,
                            Z_TEMPLATE_ID in number);
end;

 

/
