--------------------------------------------------------
--  DDL for Package XNP_SV_ORDERS$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_SV_ORDERS$" AUTHID CURRENT_USER as
/* $Header: XNPSVORS.pls 120.0 2005/05/30 11:46:40 appldev noship $ */


   procedure Startup;
   procedure FirstPage(Z_DIRECT_CALL in boolean);
   procedure ShowAbout;
   procedure TemplateHeader(Z_DIRECT_CALL in boolean,
                            Z_TEMPLATE_ID in number);
end;

 

/
