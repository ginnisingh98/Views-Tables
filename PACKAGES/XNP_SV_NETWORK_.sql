--------------------------------------------------------
--  DDL for Package XNP_SV_NETWORK$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_SV_NETWORK$" AUTHID CURRENT_USER as
/* $Header: XNPSVNWS.pls 120.0 2005/05/30 11:49:49 appldev noship $ */


   procedure Startup;
   procedure FirstPage(Z_DIRECT_CALL in boolean);
   procedure ShowAbout;
   procedure TemplateHeader(Z_DIRECT_CALL in boolean,
                            Z_TEMPLATE_ID in number);
end;

 

/
