--------------------------------------------------------
--  DDL for Package Body GR_DISPATCH_HISTORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_DISPATCH_HISTORY_PUB" AS
/* $Header: GRPDSPHB.pls 120.0 2005/08/04 08:27:10 mgrosser noship $ */

G_PKG_NAME CONSTANT varchar2(30) := 'GR_DISPATCH_HISTORY_PUB';

g_log_head    CONSTANT VARCHAR2(50) := 'gr.plsql.'|| G_PKG_NAME || '.';

--------------------------------------------------------------------------------
--Start of Comments
--Name: create_dispatch_history
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure inserts records in the dispatch history table after validations.
--Parameters:
--IN:
-- Version of API to validate compatibility
--p_api_version                      IN      		NUMBER,
-- Initialize message  stack  (TRUE or FALSE)
--p_init_msg_list         	         IN      		VARCHAR2,
-- Issue database commit after update (TRUE or FALSE)
--p_commit                  	         IN      		VARCHAR2,
-- Item/product that document is related to
--p_item                                 IN                		VARCHAR2,
-- CAS # of item/product that document is related to
--p_cas_number                    IN                		VARCHAR2,
-- Document recipient ID
--p_recipient_id                    IN                		NUMBER,
-- Document recipient site ID
--p_recipient_site_id             IN                		NUMBER,
-- Date document was sent to recipient
--p_date_sent                         IN                		DATE,
-- Method used to send the document to recipient
--p_dispatch_method_code  IN      	 	NUMBER,
-- ID of saved document (document is already in the system)
--p_document_id                  IN               		NUMBER,
-- Physical Location of the document
--p_document_location         IN               		VARCHAR2,
-- Actual name of File
--p_document_name             IN               		VARCHAR2,
-- Version of document
--p_document_version          IN               		VARCHAR2,
-- Category to assign document to
--p_document_category        IN               		VARCHAR2,
-- Format of file - e.g. XML, pdf, etc
--p_file_format                      IN               		VARCHAR2,
-- Description of document
--p_file_description              IN                		VARCHAR2,
-- Type of  regulatory document - e.g. US16, CA16, etc.
--p_document_code              IN             		VARCHAR2,
-- Disclosure code used to generate the document
--p_disclosure_code              IN          		VARCHAR2,
-- Language that document was generated in
--p_language                         IN          		VARCHAR2,
-- Organization document was created for
--p_organization_code          IN          		VARCHAR2,
-- User id to use for who columns
--p_user_id                            IN      		NUMBER,
-- Specifies the application calling this API
-- (0 - External application ,1- Internal application, 2 - Form)
--p_creation_source  	         IN      		NUMBER,

--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if API succeeds
--  FND_API.G_RET_STS_ERROR if API fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_msg_count                Number of error message in the error message
--                           list
--
--x_msg_data                 If the number of error message in the error
--                           message list is one, the error message
--                           is in this output parameter
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE CREATE_DISPATCH_HISTORY(
    p_api_version          IN NUMBER,
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
)
IS

  l_api_version  NUMBER       := 1.0;
  l_api_name     VARCHAR2(60) := 'CREATE_DISPATCH_HISTORY';
  l_log_head	 CONSTANT varchar2(100) := g_log_head || l_api_name;
  l_progress	 VARCHAR2(3) := '000';

  ITEM_OR_CAS_REQ EXCEPTION;
  NO_DOCUMENT     EXCEPTION;

BEGIN
  --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(  l_api_version
                                      , p_api_version
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_progress := 10;

   --Make sure either CAS # or item has been sent in
   IF p_item IS NULL and p_cas_number IS NULL THEN
      RAISE ITEM_OR_CAS_REQ;
   END IF;

   --If neither document id nor document name is sent in
   IF p_document_id IS NULL  AND p_document_name IS NULL THEN
      RAISE NO_DOCUMENT;
   END IF;


   --Insert record into the Dispatch History table
   GR_DISPATCH_HISTORY_PVT.create_dispatch_history_rec
                         ( p_item            ,
                           p_organization_id,
                           p_inventory_item_id,
                           p_cas_number       ,
                           p_recipient_id      ,
                           p_recipient_site_id  ,
                           p_date_sent           ,
                           p_dispatch_method_code ,
                           p_document_id          ,
                           p_document_location    ,
                           p_document_name        ,
                           p_document_version     ,
                           p_document_category    ,
                           p_file_format          ,
                           p_file_description     ,
                           p_document_code        ,
                           p_disclosure_code      ,
                           p_language             ,
                           p_organization_code    ,
                           p_user_id              ,
                           p_creation_source  	  ,
                           x_return_status        ,
                           x_msg_count            ,
                           x_msg_data );


   IF (x_return_status = FND_API.G_RET_STS_ERROR)
   THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Issue commit if required
   -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
     COMMIT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count,
                               p_data  => x_msg_data
                            );

   EXCEPTION
         WHEN ITEM_OR_CAS_REQ THEN
            FND_MESSAGE.SET_NAME('GR', 'GR_NO_ITEM_OR_CAS');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

         WHEN NO_DOCUMENT THEN
            FND_MESSAGE.SET_NAME('GR', 'GR_NO_DOCUMENT');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );


         WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count,
                                         p_data  => x_msg_data);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count,
                                         p_data  => x_msg_data);

         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get (
                     	p_count => x_msg_count,
                        p_data  => x_msg_data   );

END CREATE_DISPATCH_HISTORY;



END GR_DISPATCH_HISTORY_PUB; -- Package body

/
