--------------------------------------------------------
--  DDL for Package INV_INVENTORY_ADJUSTMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVENTORY_ADJUSTMENT" AUTHID CURRENT_USER AS
/* $Header: INVADJTS.pls 120.0.12010000.3 2010/02/05 02:29:43 musinha noship $ */

PROCEDURE send_adjustment   (x_errbuf          OUT  NOCOPY VARCHAR2,
                             x_retcode         OUT  NOCOPY NUMBER,
                             p_deploy_mode IN NUMBER DEFAULT null,
                             p_client_code IN VARCHAR2,
                             p_client      IN VARCHAR2,
                             p_org_id IN NUMBER,
                             p_trx_date_from IN VARCHAR2 DEFAULT null,
                             p_trx_date_to IN VARCHAR2 DEFAULT null,
                             p_trx_type IN VARCHAR2 DEFAULT null,
			     p_xml_doc_id IN NUMBER DEFAULT null);

PROCEDURE delete_temp_table (p_entity_id NUMBER);

END inv_inventory_adjustment;

/
