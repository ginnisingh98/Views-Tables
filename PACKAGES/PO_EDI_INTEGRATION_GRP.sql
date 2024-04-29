--------------------------------------------------------
--  DDL for Package PO_EDI_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_EDI_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGEDIS.pls 115.0 2004/06/30 02:21:40 zxzhang noship $*/

-- Detailed comments maintained in the Package Body PO_EDI_INTEGRATION_GRP.archive_po
PROCEDURE archive_po
(
   p_api_version        IN   NUMBER
 , p_document_id        IN   NUMBER
 , p_document_type      IN   VARCHAR2
 , p_document_subtype   IN   VARCHAR2
 , x_return_status      OUT  NOCOPY VARCHAR2
 , x_msg_count          OUT  NOCOPY NUMBER
 , x_msg_data           OUT  NOCOPY VARCHAR2);


END PO_EDI_INTEGRATION_GRP;

 

/
