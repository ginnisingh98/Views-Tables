--------------------------------------------------------
--  DDL for Package GR_DISPATCH_HISTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_DISPATCH_HISTORY_PVT" AUTHID CURRENT_USER AS
/* $Header: GRVDSPHS.pls 120.2 2005/08/24 09:55:30 pbamb noship $ */

/*--------------------------------------------------------------------------------------
  Procedure : create_dispatch_history
  Descrption: The Dispatch History Private API will store details pertaining to the
  distribution of Regulatory documents.  If the document itself has not already been
  stored in the fnd_documents table, the eSignatures file upload API will be called
  to do so.  The API can be called from within the E-Business Suite by the public API.
----------------------------------------------------------------------------------------*/

PROCEDURE CREATE_DISPATCH_HISTORY_REC
   (p_item                 IN VARCHAR2,
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

/*--------------------------------------------------------------------------------------
  Procedure : get_cas_no
  Descrption: This API returns the Cas number for a given item number.
----------------------------------------------------------------------------------------*/

PROCEDURE GET_CAS_NO(p_item IN varchar2,
                     p_organization_id IN NUMBER,
                     p_cas_no OUT NOCOPY  varchar2);

/*--------------------------------------------------------------------------------------
  Procedure : get_organization_code
  Descrption: This API returns organization code based on organization id.
----------------------------------------------------------------------------------------*/

PROCEDURE GET_ORGANIZATION_CODE(   p_orgn_id IN NUMBER,
                                   p_orgn_code OUT NOCOPY VARCHAR2);


/*--------------------------------------------------------------------------------------
  Procedure : get_item_desc
  Descrption: This API returns Item Description based on item id, organization id.
----------------------------------------------------------------------------------------*/

PROCEDURE GET_ITEM_DESC( P_item_id IN NUMBER,
                         p_orgn_id IN NUMBER,
                         p_item_desc OUT NOCOPY VARCHAR2);


END GR_DISPATCH_HISTORY_PVT; -- Package spec
 

/
