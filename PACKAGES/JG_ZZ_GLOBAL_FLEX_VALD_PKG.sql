--------------------------------------------------------
--  DDL for Package JG_ZZ_GLOBAL_FLEX_VALD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_GLOBAL_FLEX_VALD_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzzrfvs.pls 120.4 2005/08/25 23:31:20 cleyvaol ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/


PROCEDURE Validate_Global_Flexfield(
                          p_global_attribute_category  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute1  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute2  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute3  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute4  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute5  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute6  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute7  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute8  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute9  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute10 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute11 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute12 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute13 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute14 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute15 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute16 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute17 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute18 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute19 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute20 IN OUT NOCOPY VARCHAR2,
                          p_desc_flex_name      IN VARCHAR2,
                          p_return_status       IN OUT NOCOPY  varchar2
                         );

PROCEDURE Validate_Global_Attb_Cat(
                                 p_global_attribute_category IN  VARCHAR2,
                                 p_product_code              IN  VARCHAR2,
                                 p_country_code              IN  VARCHAR2,
                                 p_form_name                 IN  VARCHAR2,
                                 p_return_status             OUT NOCOPY BOOLEAN);

END jg_zz_global_flex_vald_pkg;

 

/
