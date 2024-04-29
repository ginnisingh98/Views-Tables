--------------------------------------------------------
--  DDL for Package CSFW_ATTACHMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSFW_ATTACHMENT_PVT" AUTHID CURRENT_USER as
/* $Header: csfwattachs.pls 120.0.12010000.2 2010/03/31 13:04:02 shadas noship $ */

/*
Procedure to upload attachment to Server
*/
PROCEDURE UPLOAD_ATTACHMENT
		(p_incident_id	NUMBER,
         p_incident_number NUMBER,
		 p_datatype_id NUMBER,
		 p_title VARCHAR2,
		 p_description VARCHAR2,
		 p_category_user_name VARCHAR2,
		 p_file_name VARCHAR2,
		 p_file_content_type VARCHAR2,
		 p_text VARCHAR2,
		 p_url VARCHAR2,
		 p_file_data BLOB,
		 p_error_msg     OUT NOCOPY    VARCHAR2,
         x_return_status IN OUT NOCOPY VARCHAR2
		);
END CSFW_ATTACHMENT_PVT;


/
