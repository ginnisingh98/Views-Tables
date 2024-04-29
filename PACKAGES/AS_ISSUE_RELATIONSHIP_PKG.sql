--------------------------------------------------------
--  DDL for Package AS_ISSUE_RELATIONSHIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_ISSUE_RELATIONSHIP_PKG" AUTHID CURRENT_USER AS
/* #$Header: asxifirs.pls 115.5 2002/11/06 00:41:47 appldev ship $ */
PROCEDURE insert_row(	p_row_id		IN OUT	VARCHAR2,
			p_issue_relationship_id IN OUT 	NUMBER,
			p_issue_relationship_type IN	VARCHAR2,
			p_subject_id		IN	NUMBER,
			p_object_id 	 	IN      NUMBER,
			p_start_date_active	IN      DATE,
			p_end_date_active	IN      DATE,
			p_directional_flag	IN      VARCHAR2,
			p_last_update_date    	IN	DATE,
          		p_last_updated_by    	IN	NUMBER,
          		p_creation_date    	IN	DATE,
          		p_created_by    	IN	NUMBER,
          		p_last_update_login    	IN	NUMBER,
			p_attribute_category    IN	VARCHAR2,
          		p_attribute1    	IN	VARCHAR2,
          		p_attribute2    	IN	VARCHAR2,
          		p_attribute3    	IN	VARCHAR2,
          		p_attribute4    	IN	VARCHAR2,
         		p_attribute5    	IN	VARCHAR2,
          		p_attribute6    	IN	VARCHAR2,
          		p_attribute7    	IN	VARCHAR2,
         		p_attribute8    	IN	VARCHAR2,
          		p_attribute9    	IN	VARCHAR2,
          		p_attribute10   	IN	VARCHAR2,
          		p_attribute11    	IN	VARCHAR2,
          		p_attribute12   	IN	VARCHAR2,
          		p_attribute13    	IN	VARCHAR2,
          		p_attribute14    	IN	VARCHAR2,
          		p_attribute15    	IN	VARCHAR2);
PROCEDURE update_row (  p_issue_relationship_id  IN     NUMBER,
			p_issue_relationship_type IN	VARCHAR2,
			p_subject_id		IN	NUMBER,
			p_object_id		IN 	NUMBER,
			p_start_date_active	IN 	DATE,
			p_end_date_active	IN 	DATE,
			p_directional_flag	IN	VARCHAR2,
			p_last_update_date      IN	DATE,
          		p_last_updated_by    	IN	NUMBER,
          		p_creation_date    	IN	DATE,
          		p_created_by    	IN	NUMBER,
          		p_last_update_login     IN	NUMBER,
			p_attribute_category    IN 	VARCHAR2,
          		p_attribute1    	IN	VARCHAR2,
          		p_attribute2    	IN	VARCHAR2,
          		p_attribute3    	IN	VARCHAR2,
          		p_attribute4    	IN	VARCHAR2,
         		p_attribute5    	IN	VARCHAR2,
          		p_attribute6    	IN	VARCHAR2,
          		p_attribute7    	IN	VARCHAR2,
         		p_attribute8    	IN	VARCHAR2,
          		p_attribute9    	IN	VARCHAR2,
          		p_attribute10   	IN	VARCHAR2,
          		p_attribute11    	IN	VARCHAR2,
          		p_attribute12   	IN	VARCHAR2,
          		p_attribute13    	IN	VARCHAR2,
          		p_attribute14    	IN	VARCHAR2,
          		p_attribute15    	IN	VARCHAR2);
PROCEDURE delete_row   (p_issue_relationship_id 		IN	NUMBER );
END AS_ISSUE_RELATIONSHIP_PKG;

 

/
