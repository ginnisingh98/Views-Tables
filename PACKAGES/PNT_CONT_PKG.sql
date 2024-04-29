--------------------------------------------------------
--  DDL for Package PNT_CONT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNT_CONT_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNTCONTS.pls 115.15 2002/11/14 20:24:50 stripath ship $

PROCEDURE check_unique_contact_name ( x_rowid                   VARCHAR2,
                                      x_company_site_id         NUMBER,
                                      x_first_name              VARCHAR2,
                                      x_last_name               VARCHAR2,
                                      x_warning_flag     IN OUT NOCOPY VARCHAR2,
                                      x_org_id                  NUMBER default NULL
                                    );


PROCEDURE check_primary ( p_contact_id       IN NUMBER,
	                      p_company_site_id  IN NUMBER,
	                      p_org_id           IN NUMBER  default NULL
                        );

PROCEDURE insert_row ( x_rowid                   IN OUT NOCOPY VARCHAR2,
                       x_contact_id              IN OUT NOCOPY NUMBER,
                       x_company_site_id                NUMBER,
                       x_last_name                      VARCHAR2,
                       x_created_by                     NUMBER,
                       x_creation_date                  DATE,
                       x_last_updated_by                NUMBER,
                       x_last_update_date               DATE,
                       x_last_update_login              NUMBER,
                       x_status                         VARCHAR2,
                       x_first_Name                     VARCHAR2,
                       x_job_title                      VARCHAR2,
                       x_mail_stop                      VARCHAR2,
                       x_email_address                  VARCHAR2,
                       x_primary_flag                   VARCHAR2,
                       x_company_or_location            VARCHAR2,
                       x_attribute_category             VARCHAR2,
                       x_attribute1                     VARCHAR2,
                       x_attribute2                     VARCHAR2,
                       x_attribute3                     VARCHAR2,
                       x_attribute4                     VARCHAR2,
                       x_attribute5                     VARCHAR2,
                       x_attribute6                     VARCHAR2,
                       x_attribute7                     VARCHAR2,
                       x_attribute8                     VARCHAR2,
                       x_attribute9                     VARCHAR2,
                       x_attribute10                    VARCHAR2,
                       x_attribute11                    VARCHAR2,
                       x_attribute12                    VARCHAR2,
                       x_attribute13                    VARCHAR2,
                       x_attribute14                    VARCHAR2,
                       x_attribute15                    VARCHAR2,
                       x_org_id                         NUMBER default NULL
                     );

PROCEDURE update_row ( x_rowid                          VARCHAR2,
                       x_contact_id                     NUMBER,
                       x_company_site_id                NUMBER,
                       x_last_name                      VARCHAR2,
                       x_last_updated_by                NUMBER,
                       x_last_update_date               DATE,
                       x_last_update_login              NUMBER,
                       x_status                         VARCHAR2,
                       x_first_Name                     VARCHAR2,
                       x_job_title                      VARCHAR2,
                       x_mail_stop                      VARCHAR2,
                       x_email_address                  VARCHAR2,
                       x_primary_flag                   VARCHAR2,
                       x_attribute_category             VARCHAR2,
                       x_attribute1                     VARCHAR2,
                       x_attribute2                     VARCHAR2,
                       x_attribute3                     VARCHAR2,
                       x_attribute4                     VARCHAR2,
                       x_attribute5                     VARCHAR2,
                       x_attribute6                     VARCHAR2,
                       x_attribute7                     VARCHAR2,
                       x_attribute8                     VARCHAR2,
                       x_attribute9                     VARCHAR2,
                       x_attribute10                    VARCHAR2,
                       x_attribute11                    VARCHAR2,
                       x_attribute12                    VARCHAR2,
                       x_attribute13                    VARCHAR2,
                       x_attribute14                    VARCHAR2,
                       x_attribute15                    VARCHAR2
                     );

PROCEDURE lock_row  ( x_rowid                          VARCHAR2,
                      x_contact_id                     NUMBER,
                      x_last_name                      VARCHAR2,
                      x_status                         VARCHAR2,
                      x_first_Name                     VARCHAR2,
                      x_job_title                      VARCHAR2,
                      x_mail_stop                      VARCHAR2,
                      x_email_address                  VARCHAR2,
                      x_primary_flag                   VARCHAR2,
                      x_attribute_category             VARCHAR2,
                      x_attribute1                     VARCHAR2,
                      x_attribute2                     VARCHAR2,
                      x_attribute3                     VARCHAR2,
                      x_attribute4                     VARCHAR2,
                      x_attribute5                     VARCHAR2,
                      x_attribute6                     VARCHAR2,
                      x_attribute7                     VARCHAR2,
                      x_attribute8                     VARCHAR2,
                      x_attribute9                     VARCHAR2,
                      x_attribute10                    VARCHAR2,
                      x_attribute11                    VARCHAR2,
                      x_attribute12                    VARCHAR2,
                      x_attribute13                    VARCHAR2,
                      x_attribute14                    VARCHAR2,
                      x_attribute15                    VARCHAR2
                    );

PROCEDURE check_delete ( x_contact_id                  NUMBER );

PROCEDURE delete_row   ( x_contact_id                  NUMBER );

END PNT_CONT_PKG;

 

/
