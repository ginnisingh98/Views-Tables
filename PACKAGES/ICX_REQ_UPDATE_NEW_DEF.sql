--------------------------------------------------------
--  DDL for Package ICX_REQ_UPDATE_NEW_DEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_REQ_UPDATE_NEW_DEF" AUTHID CURRENT_USER as
/* $Header: ICXRQCDS.pls 115.1 99/07/17 03:22:53 porting ship $ */

  procedure Req_Line_Upd_Def(ak_line IN OUT AK$ICX_PO_REQUISITION_LINES_IN.REC);

end ICX_REQ_UPDATE_NEW_DEF;

 

/
