--------------------------------------------------------
--  DDL for Package GR_DISPATCH_HISTORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_DISPATCH_HISTORY_PUB" AUTHID CURRENT_USER AS
/* $Header: GRPDSPHS.pls 120.0 2005/08/04 08:26:45 mgrosser noship $ */

/*--------------------------------------------------------------------------------------
  Procedure : create_dispatch_history
  Descrption: The Dispatch History Public API will store details pertaining to the
  distribution of Regulatory documents.  If the document itself has not already been
  stored in the fnd_documents table, the eSignatures file upload API will be called
  to do so.  The API can be called from within the E-Business Suite or by other sources,
  such as 3rd Party applications.
----------------------------------------------------------------------------------------*/

PROCEDURE create_dispatch_history
   (p_api_version          IN NUMBER,
    p_init_msg_list        IN VARCHAR2,
    p_commit               IN VARCHAR2,
    p_item                 IN VARCHAR2,
    p_organization_id      IN NUMBER,
    p_inventory_item_id    IN NUMBER,
    p_cas_number           IN VARCHAR2,
    p_recipient_id         IN NUMBER,
    p_recipient_site_id    IN NUMBER,
    p_date_sent            IN DATE,
    p_dispatch_method_code IN NUMBER,
    p_document_id          IN NUMBER,
    p_document_location    IN VARCHAR2,
    p_document_name        IN VARCHAR2,
    p_document_version     IN VARCHAR2,
    p_document_category    IN VARCHAR2,
    p_file_format          IN VARCHAR2,
    p_file_description     IN VARCHAR2,
    p_document_code        IN VARCHAR2,
    p_disclosure_code      IN VARCHAR2,
    p_language             IN VARCHAR2,
    p_organization_code    IN VARCHAR2,
    p_user_id              IN NUMBER,
    p_creation_source  	   IN NUMBER,
    x_return_status        OUT NOCOPY   VARCHAR2 ,
    x_msg_count            OUT NOCOPY   NUMBER ,
    x_msg_data             OUT NOCOPY   VARCHAR2
);


END GR_DISPATCH_HISTORY_PUB; -- Package spec
 

/
