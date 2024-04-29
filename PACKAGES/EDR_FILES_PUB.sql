--------------------------------------------------------
--  DDL for Package EDR_FILES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_FILES_PUB" AUTHID CURRENT_USER AS
/* $Header: EDRPFILS.pls 120.0.12000000.1 2007/01/18 05:54:37 appldev ship $ */
/*#
 * This API provides a generic file upload management system for uploading files
 * into the Oracle E-Business Suite.
 * @rep:scope public
 * @rep:metalink 268669.1 Oracle E-Records API User's Guide
 * @rep:product EDR
 * @rep:displayname Upload and request approval for a file
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY EDR_ISIGN_FILE_UPLOAD
 */

G_API_VERSION NUMBER := 1.0;

/*#
 * This API uploads a given file into the iSign repository.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname File Upload
 */

PROCEDURE Upload_File (	p_api_version		IN NUMBER,
			p_commit		IN VARCHAR2,
			p_called_from_forms	IN VARCHAR2,
			p_file_name 		IN VARCHAR2,
			p_category 		IN VARCHAR2,
			p_content_type 		IN VARCHAR2,
			p_version_label		IN VARCHAR2,
			p_file_data	 	IN BLOB,
			p_file_format 		IN VARCHAR2,
			p_source_lang		IN VARCHAR2,
			p_description		IN VARCHAR2,
			p_file_exists_action	IN VARCHAR2,
			p_submit_for_approval	IN VARCHAR2,
			p_attribute1 		IN VARCHAR2,
			p_attribute2 		IN VARCHAR2,
			p_attribute3 		IN VARCHAR2,
			p_attribute4 		IN VARCHAR2,
			p_attribute5 		IN VARCHAR2,
			p_attribute6 		IN VARCHAR2,
			p_attribute7 		IN VARCHAR2,
			p_attribute8 		IN VARCHAR2,
			p_attribute9 		IN VARCHAR2,
			p_attribute10 		IN VARCHAR2,
			p_created_by 		IN NUMBER,
			p_creation_date 	IN DATE,
			p_last_updated_by 	IN NUMBER,
			p_last_update_login 	IN NUMBER,
			p_last_update_date 	IN DATE,
			x_return_status 	OUT NOCOPY VARCHAR2,
			x_msg_data		OUT NOCOPY VARCHAR2);



END EDR_FILES_PUB;

 

/
