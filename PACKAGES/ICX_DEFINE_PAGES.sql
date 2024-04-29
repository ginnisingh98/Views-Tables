--------------------------------------------------------
--  DDL for Package ICX_DEFINE_PAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_DEFINE_PAGES" AUTHID CURRENT_USER as
/* $Header: ICXCNPAS.pls 120.1 2005/10/07 13:23:41 gjimenez noship $ */

-- the UI procedures
procedure EditPageList;

procedure PageList;

procedure DispPageDialog
(p_mode      in varchar2 default null,
 p_page_id   in varchar2 default null);

procedure OrderPages(
   Pages     in varchar2 default null,
   oldPages  in varchar2 default null,
   calledfrom   in varchar2 default null);

procedure SavePage(
   P_request          in varchar2 default null,
   P_Mode             in varchar2 default null,
   P_Page_id          in varchar2 default null,
   P_Page_Name        in varchar2 default null);

end;

 

/
