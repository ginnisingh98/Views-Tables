--------------------------------------------------------
--  DDL for Package IGS_PE_CONTACT_POINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_CONTACT_POINT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI78S.pls 115.6 2003/05/05 14:56:18 kpadiyar ship $ */

PROCEDURE HZ_CONTACT_POINTS_AKE(
             p_action			IN	  VARCHAR2,
 		 p_rowid 		IN OUT NOCOPY    VARCHAR2,
   		 p_status		IN	  VARCHAR2,
  		 p_owner_table_name	IN	  VARCHAR2,
  		 p_owner_table_id	IN	  NUMBER,
  		 P_primary_flag		IN	  VARCHAR2,
  		 p_email_format		IN	  VARCHAR2,
   		 p_email_address        IN	  VARCHAR2,
		 p_return_status   	OUT NOCOPY       VARCHAR2,
       	         p_msg_data             OUT NOCOPY  	  VARCHAR2,
 		 p_last_update_date	IN OUT NOCOPY     DATE,
                 p_contact_point_id     IN OUT NOCOPY     NUMBER,
                 p_contact_point_ovn    IN OUT NOCOPY     NUMBER,
                 p_attribute_category   IN VARCHAR2 DEFAULT NULL,
                 p_attribute1		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute2 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute3 		IN VARCHAR2 DEFAULT NULL,
  		 p_attribute4 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute5 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute6 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute7 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute8 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute9 		IN VARCHAR2 DEFAULT NULL,
    		 p_attribute10 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute11 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute12 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute13 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute14 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute15 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute16 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute17 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute18 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute19 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute20 		IN VARCHAR2 DEFAULT NULL
 ) ;

PROCEDURE HZ_CONTACT_POINTS_AKP(
                 p_action		IN	  VARCHAR2,
 		 p_rowid 		IN OUT NOCOPY  VARCHAR2,
   		 p_status		IN	  VARCHAR2,
  		 p_owner_table_name	IN	  VARCHAR2,
  		 p_owner_table_id	IN	  NUMBER,
  		 P_primary_flag		IN	  VARCHAR2,
   		 p_phone_country_code   IN	  VARCHAR2,
 		 p_phone_area_code      IN	  VARCHAR2,
	         p_phone_number         IN	  VARCHAR2,
	         p_phone_extension      IN	  VARCHAR2,
                 p_phone_line_type      IN      VARCHAR2,
		 p_return_status   	OUT NOCOPY     VARCHAR2,
       	         p_msg_data             OUT NOCOPY  	  VARCHAR2,
 		 p_last_update_date	IN OUT NOCOPY  DATE,
                 p_contact_point_id     IN OUT NOCOPY     NUMBER,
                 p_contact_point_ovn    IN OUT NOCOPY     NUMBER,
                 p_attribute_category   IN VARCHAR2 DEFAULT NULL,
                 p_attribute1		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute2 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute3 		IN VARCHAR2 DEFAULT NULL,
  		 p_attribute4 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute5 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute6 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute7 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute8 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute9 		IN VARCHAR2 DEFAULT NULL,
    		 p_attribute10 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute11 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute12 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute13 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute14 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute15 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute16 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute17 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute18 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute19 		IN VARCHAR2 DEFAULT NULL,
   		 p_attribute20 		IN VARCHAR2 DEFAULT NULL
) ;


END IGS_PE_CONTACT_POINT_PKG;

 

/
