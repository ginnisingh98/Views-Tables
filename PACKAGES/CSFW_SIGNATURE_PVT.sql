--------------------------------------------------------
--  DDL for Package CSFW_SIGNATURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSFW_SIGNATURE_PVT" AUTHID CURRENT_USER as
/* $Header: csfwsigs.pls 115.1 2003/10/29 02:27:07 pgiri noship $ */
/*
--Start of Comments
Package name     : CSFW_SIGNATURE_PVT
Purpose          : to upload signature associated with Debrief
History          :
NOTE             : Please see the function details for additional information

UPDATE NOTES
| Date          Developer           Change
|------         ---------------     --------------------------------------
08-06-2003	MMERCHAN	 Created


--End of Comments
*/

/*
Procedure to insert signature, name and date to Server
p_description is composed of --l_signed_date||' '||l_signed_by,
*/

PROCEDURE UPLOAD_SIGNATURE
		(p_debrief_header_id	NUMBER,
		 p_task_assignment_id NUMBER,
		 p_description VARCHAR2,
		 p_file_data BLOB,
		 p_error_msg     OUT NOCOPY    VARCHAR2,
           	 x_return_status IN OUT NOCOPY VARCHAR2
		);
END CSFW_SIGNATURE_PVT;

 

/
