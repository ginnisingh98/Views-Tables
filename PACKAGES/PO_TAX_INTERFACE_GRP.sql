--------------------------------------------------------
--  DDL for Package PO_TAX_INTERFACE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_TAX_INTERFACE_GRP" AUTHID CURRENT_USER AS
/* $Header: PO_TAX_INTERFACE_GRP.pls 120.0 2005/11/20 23:52:35 nipagarw noship $ */


PROCEDURE get_document_tax_constants(p_api_version      IN  NUMBER,
                                     p_init_msg_list    IN  VARCHAR2,
                                     p_commit           IN  VARCHAR2,
                                     p_validation_level IN  NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2,
                                     p_doc_type         IN  VARCHAR2,
                                     x_application_id   OUT NOCOPY NUMBER,
                                     x_entity_code      OUT NOCOPY VARCHAR2,
                                     x_event_class_code OUT NOCOPY VARCHAR2);


END PO_TAX_INTERFACE_GRP;

 

/
