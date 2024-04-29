--------------------------------------------------------
--  DDL for Package PA_PWP_INVOICE_LINKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PWP_INVOICE_LINKS" AUTHID CURRENT_USER AS
 /* $Header: PAAPINVS.pls 120.0.12010000.1 2008/11/13 14:57:41 jjgeorge noship $ */

TYPE LINK_REC is RECORD(PROJECT_ID         NUMBER(15),
		                DRAFT_INVOICE_NUM  NUMBER(15),
		                AP_INVOICE_ID      NUMBER(15) );

TYPE LINK_TAB is TABLE OF LINK_REC
                 INDEX BY BINARY_INTEGER;

procedure del_invoice_link
( PA_LINK_TAB   IN PA_PWP_INVOICE_LINKS.LINK_TAB
   ,x_return_status  OUT NOCOPY VARCHAR2
   ,x_msg_count     OUT NOCOPY NUMBER
   ,x_msg_data    OUT NOCOPY VARCHAR2
);

procedure add_invoice_link
(PA_LINK_TAB  IN  PA_PWP_INVOICE_LINKS.LINK_TAB
  ,x_return_status  OUT NOCOPY VARCHAR2
  ,x_msg_count     OUT NOCOPY NUMBER
 ,x_msg_data      OUT NOCOPY VARCHAR2
);

end PA_PWP_INVOICE_LINKS;

/
