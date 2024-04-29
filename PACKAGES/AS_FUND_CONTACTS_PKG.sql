--------------------------------------------------------
--  DDL for Package AS_FUND_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_FUND_CONTACTS_PKG" AUTHID CURRENT_USER AS
/* $Header: asxiffcs.pls 115.5 2002/11/06 00:41:14 appldev ship $ */

PROCEDURE insert_row (
    p_row_id	       IN OUT VARCHAR2,
    p_fund_id  	       IN  	  NUMBER,
    p_party_id 	       IN  	  NUMBER,
    p_contact_role_code  IN	  VARCHAR2,
    p_last_update_date   IN     DATE,
    p_last_updated_by    IN     NUMBER,
    p_creation_date      IN     DATE,
    p_created_by         IN     NUMBER,
    p_last_update_login  IN     NUMBER,
    p_attribute_category IN	  VARCHAR2,
    p_attribute1    	 IN	  VARCHAR2,
    p_attribute2    	 IN	  VARCHAR2,
    p_attribute3    	 IN	  VARCHAR2,
    p_attribute4    	 IN	  VARCHAR2,
    p_attribute5    	 IN	  VARCHAR2,
    p_attribute6    	 IN	  VARCHAR2,
    p_attribute7    	 IN	  VARCHAR2,
    p_attribute8         IN	  VARCHAR2,
    p_attribute9         IN	  VARCHAR2,
    p_attribute10        IN	  VARCHAR2,
    p_attribute11        IN	  VARCHAR2,
    p_attribute12        IN	  VARCHAR2,
    p_attribute13        IN	  VARCHAR2,
    p_attribute14        IN	  VARCHAR2,
    p_attribute15        IN	  VARCHAR2);

PROCEDURE update_row (
    p_fund_id            IN  NUMBER,
    p_party_id           IN  NUMBER,
    p_contact_role_code	 IN  VARCHAR2,
    p_last_update_date   IN  DATE,
    p_last_updated_by    IN  NUMBER,
    p_creation_date      IN  DATE,
    p_created_by         IN  NUMBER,
    p_last_update_login  IN  NUMBER,
    p_attribute_category IN  VARCHAR2,
    p_attribute1    	 IN  VARCHAR2,
    p_attribute2    	 IN  VARCHAR2,
    p_attribute3    	 IN  VARCHAR2,
    p_attribute4    	 IN  VARCHAR2,
    p_attribute5    	 IN  VARCHAR2,
    p_attribute6    	 IN  VARCHAR2,
    p_attribute7    	 IN  VARCHAR2,
    p_attribute8         IN  VARCHAR2,
    p_attribute9         IN  VARCHAR2,
    p_attribute10        IN  VARCHAR2,
    p_attribute11        IN  VARCHAR2,
    p_attribute12        IN  VARCHAR2,
    p_attribute13        IN  VARCHAR2,
    p_attribute14        IN  VARCHAR2,
    p_attribute15        IN  VARCHAR2);

PROCEDURE delete_row (
   p_fund_id   IN NUMBER,
   p_party_id  IN NUMBER);

END AS_FUND_CONTACTS_PKG;

 

/
