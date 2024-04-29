--------------------------------------------------------
--  DDL for Package PNT_COMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNT_COMP_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNTCOMPS.pls 115.10 2002/11/14 20:24:43 stripath ship $


PROCEDURE check_unique_company_name ( p_rowid        IN VARCHAR2,
				                      p_company_name IN VARCHAR2,
				                      p_warning_flag IN OUT NOCOPY VARCHAR2,
				                      p_org_id       IN NUMBER default NULL
                                    );

PROCEDURE check_unique_company_number  ( p_rowid           IN VARCHAR2,
				                         p_company_number  IN VARCHAR2,
				                         p_org_id          IN NUMBER default NULL
                                       );

PROCEDURE insert_row ( x_rowid                   IN OUT NOCOPY VARCHAR2,
	                   x_company_id              IN OUT NOCOPY NUMBER,
                       x_company_number          IN OUT NOCOPY VARCHAR2,
                       x_last_update_date               DATE,
                       x_last_updated_by                NUMBER,
                       x_creation_date                  DATE,
                       x_created_by                     NUMBER,
                       x_last_update_login              NUMBER,
                       x_name                           VARCHAR2,
                       x_enabled_flag                   VARCHAR2,
                       x_parent_company_id              NUMBER,
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
	                   x_company_id                     NUMBER,
                       x_company_number                 VARCHAR2,
                       x_last_update_date               DATE,
                       x_last_updated_by                NUMBER,
                       x_last_update_login              NUMBER,
                       x_name                           VARCHAR2,
                       x_enabled_flag                   VARCHAR2,
                       x_parent_company_id              NUMBER,
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

PROCEDURE lock_row   ( x_rowid                          VARCHAR2,
	                   x_company_id                     NUMBER,
                       x_company_number                 VARCHAR2,
                       x_name                           VARCHAR2,
                       x_enabled_flag                   VARCHAR2,
                       x_parent_company_id              NUMBER,
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
END PNT_COMP_PKG;

 

/
