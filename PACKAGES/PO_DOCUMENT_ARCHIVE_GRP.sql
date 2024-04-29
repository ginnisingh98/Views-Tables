--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_ARCHIVE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_ARCHIVE_GRP" AUTHID CURRENT_USER AS
/* $Header: POXPOARS.pls 115.2 2003/10/28 21:42:00 zxzhang noship $ */


PROCEDURE archive_po(p_api_version         IN         NUMBER,
                     p_document_id         IN         NUMBER,
                     p_document_type       IN         VARCHAR2,
                     p_document_subtype    IN         VARCHAR2,
                     x_return_status       OUT NOCOPY VARCHAR2,
                     x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE archive_po(p_api_version         IN         NUMBER,
                     p_document_id         IN         NUMBER,
                     p_document_type       IN         VARCHAR2,
                     p_document_subtype    IN         VARCHAR2,
                     x_return_status       OUT NOCOPY VARCHAR2,
                     x_msg_count	   OUT NOCOPY NUMBER,
                     x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE archive_po(p_api_version         IN         NUMBER,
                     p_document_id         IN         NUMBER,
                     p_document_type       IN         VARCHAR2,
                     p_document_subtype    IN         VARCHAR2,
                     p_process             IN         VARCHAR2,
                     x_return_status       OUT NOCOPY VARCHAR2,
                     x_msg_count	   OUT NOCOPY NUMBER,
                     x_msg_data            OUT NOCOPY VARCHAR2);


END PO_DOCUMENT_ARCHIVE_GRP; -- Package spec

 

/
