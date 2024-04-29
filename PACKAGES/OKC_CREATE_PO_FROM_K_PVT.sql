--------------------------------------------------------
--  DDL for Package OKC_CREATE_PO_FROM_K_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CREATE_PO_FROM_K_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKCRKPOS.pls 120.0 2005/05/26 09:35:10 appldev noship $ */


----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : okc_create_po_from_k_pvt.create_po_from_k
--
-- Type         : Private
--
-- Pre-reqs     : None
--
-- Function : This procedure is called from the public package
-- okc_create_po_from_k_pub. It accepts a Contract Identifier as a
-- parameter and uses it to create records in POs interface tables
-- which will be converted to a PO
--
-- Parameters   : Please see specification below. No special parameters.
--
-- Version      : Initial version
--
-- End of comments
----------------------------------------------------------------------------------

  PROCEDURE create_po_from_k(p_api_version              IN  NUMBER
			               ,p_init_msg_list            IN  VARCHAR2
			               ,p_chr_id                   IN  okc_k_headers_b.ID%TYPE
                              ,x_return_status            OUT NOCOPY VARCHAR2
			               ,x_msg_count                OUT NOCOPY NUMBER
			               ,x_msg_data                 OUT NOCOPY VARCHAR2);


----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : okc_create_po_from_k_pvt.tieback_related_objs_from_po
--
-- Type         : Private
--
-- Pre-reqs     : None
--
-- Function: This procedure is called from the Public package on the
-- second invokation of the Create PO from Contract. It is called
-- after the Population of Interface tables and Purchasing Documents
-- Open Interface. The purpose of the procedure is to tieback the
-- transactions. It also invokes the Purchasing Interface Errors
-- report as a concurrent program (not a child process)
--
-- Why tieback is needed: During the first pass of the main procedure,
-- records are created in okc_k_rel_objs with the contract
-- header/lines and the corresponding PO header/lines. After this,
-- PDOI is submitted to create the PO Header and lines from the
-- interface tables. It is possible that some lines or the entire
-- Contract does not get transferred over to PO. This will result in a
-- loss of data integrity since okc_k_rel_objs will be pointing to
-- non-existent objects. Hence cleanup of those objects is required
-- after PDOI is run.
--
-- This also prints the PO number in the out file.
--
-- Phase I specific: In Phase I, the current version of PDOI does not
-- accept po_ine_id. Hence the related object is initially created
-- linking K Line id to (PO Header Id+Line Num). After PDOI, the
-- correct line id is known and hence okc_k_rel_objs can be updated to
-- reflect this
--
-- Parameters : Please see specification below. No special parameters
--
-- Version      : Initial version
--
-- End of comments
--------------------------------------------------------------------------------

PROCEDURE tieback_related_objs_from_po(
                p_api_version    IN NUMBER
               ,p_init_msg_list  IN VARCHAR2
               ,p_chr_id         IN okc_k_headers_b.id%TYPE
               ,x_po_number     OUT NOCOPY VARCHAR2
               ,x_return_status OUT NOCOPY VARCHAR2
               ,x_msg_count     OUT NOCOPY NUMBER
               ,x_msg_data      OUT NOCOPY VARCHAR2
								);

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : okc_create_po_from_k_pvt.set_notification_msg
--
-- Type         : Private
--
-- Pre-reqs     : None
--
-- Function     : This procedure sets the notification messages on the stack
--
-- Parameters   : Please see specification below. No special parameters.
--
-- Version      : Initial version
--
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE set_notification_msg (p_api_version                   IN NUMBER
                    	       ,p_init_msg_list                 IN VARCHAR2
   		                   ,p_application_name              IN VARCHAR2
		                   ,p_message_subject               IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		                   ,p_message_body 	                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		                   ,p_message_body_token1 	    IN VARCHAR2
		                   ,p_message_body_token1_value     IN VARCHAR2
		                   ,p_message_body_token2 	    IN VARCHAR2
		                   ,p_message_body_token2_value     IN VARCHAR2
                               ,p_message_body_token3 	    IN VARCHAR2
		                   ,p_message_body_token3_value     IN VARCHAR2
		                   ,x_return_status   		    OUT NOCOPY VARCHAR2);

  ----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : okc_create_po_from_k_pvt.notify_buyer
--
-- Type         : Private
--
-- Pre-reqs     : None
--
-- Function     : This procedure notifies the buyer of a purchase order creation
--
-- Parameters   : Please see specification below. No special parameters.
--
-- Version      : Initial version
--
-- End of comments
----------------------------------------------------------------------------------

    PROCEDURE notify_buyer(p_api_version                    IN NUMBER
                          ,p_init_msg_list                  IN VARCHAR2
                          ,p_application_name               IN VARCHAR2
		          ,p_message_subject                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		          ,p_message_body 	            IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		          ,p_message_body_token1 	      IN VARCHAR2
		          ,p_message_body_token1_value      IN VARCHAR2
		          ,p_message_body_token2 	      IN VARCHAR2
		          ,p_message_body_token2_value      IN VARCHAR2
                          ,p_message_body_token3 	      IN VARCHAR2
		       	  ,p_message_body_token3_value      IN VARCHAR2
		      	  ,p_chr_id                         IN OKC_K_HEADERS_B.ID%TYPE
                          ,x_k_buyer_name                   OUT NOCOPY VARCHAR2
                          ,x_return_status   		      OUT NOCOPY VARCHAR2
                          ,x_msg_count                      OUT NOCOPY NUMBER
                          ,x_msg_data                       OUT NOCOPY VARCHAR2);

END OKC_CREATE_PO_FROM_K_PVT; -- Package Specification OKC_CREATE_PO_FROM_K_PVT

 

/
