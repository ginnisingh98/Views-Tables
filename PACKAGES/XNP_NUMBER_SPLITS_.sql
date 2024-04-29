--------------------------------------------------------
--  DDL for Package XNP_NUMBER_SPLITS$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_NUMBER_SPLITS$" AUTHID CURRENT_USER as
/* $Header: XNPNUMSS.pls 120.0 2005/05/30 11:49:35 appldev noship $ */


   procedure Startup;
   procedure FirstPage(Z_DIRECT_CALL in boolean);
   procedure ShowAbout;
   procedure TemplateHeader(Z_DIRECT_CALL in boolean,
                            Z_TEMPLATE_ID in number);
end;

 

/
