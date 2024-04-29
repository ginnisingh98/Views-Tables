--------------------------------------------------------
--  DDL for Package XNP_CENTER$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_CENTER$" AUTHID CURRENT_USER as
/* $Header: XNPCENTS.pls 120.0 2005/05/30 11:46:37 appldev noship $ */


   procedure Startup;
   procedure FirstPage(Z_DIRECT_CALL in boolean);
   procedure ShowAbout;
   procedure TemplateHeader(Z_DIRECT_CALL in boolean,
                            Z_TEMPLATE_ID in number);
end;

 

/
