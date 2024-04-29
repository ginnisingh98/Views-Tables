--------------------------------------------------------
--  DDL for Package GR_DOCUMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_DOCUMENTS" AUTHID CURRENT_USER AS
/*$Header: GRFMDOCS.pls 115.4 2002/10/25 18:50:29 mgrosser ship $*/
/*	This record definition maintains the list of columns returned the form. */


   PROCEDURE paste_document
				(p_copy_from_document IN VARCHAR2,
				 p_paste_to_document IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_oracle_error OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);

   PROCEDURE delete_document
				(p_delete_document IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_oracle_error OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);


END GR_DOCUMENTS;

 

/
