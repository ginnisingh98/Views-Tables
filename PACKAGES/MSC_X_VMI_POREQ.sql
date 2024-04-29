--------------------------------------------------------
--  DDL for Package MSC_X_VMI_POREQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_VMI_POREQ" AUTHID CURRENT_USER AS
/* $Header: MSCXVMOS.pls 120.0.12000000.1 2007/01/16 22:42:02 appldev ship $ */

G_CREATE CONSTANT NUMBER := 1;
G_UPDATE CONSTANT NUMBER := 2;

G_SUCCESS CONSTANT NUMBER := 1;
G_ERROR CONSTANT NUMBER := 2;

SYS_YES CONSTANT NUMBER := 1;
SYS_NO CONSTANT NUMBER := 2;

PROCEDURE INITIALIZE
               ( p_user_name         IN  VARCHAR2,
                 p_resp_name         IN  VARCHAR2,
                 p_application_name  IN  VARCHAR2);

PROCEDURE LD_PO_REQUISITIONS_INTERFACE1 (
                       p_user_name         in varchar2,
                       p_application_name  in varchar2,
                       p_resp_name         in varchar2,
                       p_po_group_by_name  in varchar2,
                       p_instance_id IN NUMBER,
                       p_instance_code IN VARCHAR2,
                       p_dblink IN VARCHAR2,
                       o_request_id        out nocopy number);

PROCEDURE LD_PO_REQUISITIONS_INTERFACE2 (
                       p_user_name        IN  VARCHAR2,
                       p_po_group_by_name    IN  VARCHAR2);

PROCEDURE LD_SO_RELEASE_INTERFACE (
			            p_user_name            IN  VARCHAR2,
			            p_resp_name            IN  VARCHAR2,
			            p_application_name     IN  VARCHAR2,
				    p_release_id           IN  NUMBER,
                       p_instance_id IN NUMBER, -- bug 3436758
                       p_instance_code IN VARCHAR2,
                       p_a2m_dblink IN VARCHAR2,
		                    o_status               OUT nocopy NUMBER,
				    o_header_id            OUT nocopy NUMBER,
				    o_line_id              OUT nocopy NUMBER,
				    o_sales_order_number   OUT nocopy NUMBER,
				    o_ship_from_org_id     OUT nocopy NUMBER,
				    o_schedule_ship_date   OUT nocopy DATE,
				    o_schedule_arriv_date  OUT nocopy DATE,
				    o_schedule_date_change OUT nocopy NUMBER,
				    o_error_message        OUT nocopy VARCHAR2);

PROCEDURE START_RELEASE_PROGRAM(
	      ERRBUF             OUT NOCOPY VARCHAR2,
	      RETCODE            OUT NOCOPY NUMBER,
	      p_user_name        IN  VARCHAR2,
	      p_resp_name        IN  VARCHAR2,
	      p_application_name IN  VARCHAR2,
              pItem_name         IN  VARCHAR2,
	      pCustomer_name     IN  VARCHAR2,
	      pCustomer_site_name IN  VARCHAR2,
              pItemtype          IN  VARCHAR2,
              pItemkey           IN  VARCHAR2,
	      pRelease_Id        IN  NUMBER,
          p_instance_id IN  NUMBER,
          p_instance_code  IN  VARCHAR2,
          p_a2m_dblink IN  VARCHAR2,
	      o_request_id       OUT NOCOPY NUMBER);

PROCEDURE WAIT_FOR_REQUEST(
              p_request_id   IN  NUMBER,
	      p_timeout      IN  NUMBER,
	      o_retcode      OUT NOCOPY NUMBER);

END MSC_X_VMI_POREQ;

 

/
