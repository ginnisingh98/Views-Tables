--------------------------------------------------------
--  DDL for Package RCV_RECEIPT_CONFIRMATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_RECEIPT_CONFIRMATION" AUTHID CURRENT_USER AS
/* $Header: RCVRCCNS.pls 120.0.12010000.6 2010/04/13 12:11:18 smididud noship $ */

PROCEDURE send_confirmation (x_errbuf        OUT  NOCOPY VARCHAR2,
                             x_retcode       OUT  NOCOPY NUMBER,
                             p_deploy_mode   IN VARCHAR2 DEFAULT NULL,
                             p_client_code   IN VARCHAR2 DEFAULT NULL,
                             p_org_id        IN NUMBER,
			     p_dummy_client  IN VARCHAR2 DEFAULT NULL,
                             p_trx_date_from IN VARCHAR2 DEFAULT NULL,
                             p_trx_date_to   IN VARCHAR2 DEFAULT NULL,
                             p_rcpt_from     IN NUMBER DEFAULT NULL,
                             p_rcpt_to       IN NUMBER DEFAULT NULL,
                             p_xml_doc_id    IN NUMBER DEFAULT NULL);

PROCEDURE get_ou_name(p_org_id NUMBER DEFAULT NULL,
                      p_ou_name OUT NOCOPY varchar2);

END rcv_receipt_confirmation;

/
