--------------------------------------------------------
--  DDL for Package PO_SHARED_PROC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SHARED_PROC_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGSPSS.pls 115.1 2003/08/18 22:15:07 pthapliy noship $ */

PROCEDURE check_shared_proc_scenario
(
    p_api_version                IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    p_destination_type_code      IN  VARCHAR2,
    p_document_type_code         IN  VARCHAR2,
    p_project_id                 IN  NUMBER,
    p_purchasing_ou_id           IN  NUMBER,
    p_ship_to_inv_org_id         IN  NUMBER,
    p_transaction_flow_header_id IN  NUMBER,
    x_is_shared_proc_scenario    OUT NOCOPY VARCHAR2
);

END PO_SHARED_PROC_GRP;

 

/
