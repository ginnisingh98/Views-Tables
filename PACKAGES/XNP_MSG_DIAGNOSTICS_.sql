--------------------------------------------------------
--  DDL for Package XNP_MSG_DIAGNOSTICS$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_MSG_DIAGNOSTICS$" AUTHID CURRENT_USER as
/* $Header: XNPMSGDS.pls 120.0 2005/05/30 11:50:17 appldev noship $ */


   procedure Startup;
   procedure FirstPage(Z_DIRECT_CALL in boolean);
   procedure ShowAbout;
   procedure TemplateHeader(Z_DIRECT_CALL in boolean,
                            Z_TEMPLATE_ID in number);
end;

 

/
