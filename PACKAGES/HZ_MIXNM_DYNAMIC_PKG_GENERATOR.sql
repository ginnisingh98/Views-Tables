--------------------------------------------------------
--  DDL for Package HZ_MIXNM_DYNAMIC_PKG_GENERATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MIXNM_DYNAMIC_PKG_GENERATOR" AUTHID CURRENT_USER AS
/*$Header: ARHXGENS.pls 115.2 2003/08/15 17:44:05 kashan noship $ */

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE Gen_PackageForConc
 *
 * DESCRIPTION
 *     Generate package HZ_MIXNM_CONC_DYNAMIC_PKG for mix-n-match
 *     concurrent program.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *      p_package_name              Package name.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE Gen_PackageForConc (
    p_package_name                  IN     VARCHAR2
);

/**
 * PROCEDURE Gen_PackageForAPI
 *
 * DESCRIPTION
 *     Generate package HZ_MIXNM_API_DYNAMIC_PKG for
 *     mix-n-match API.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *      p_package_name              Package name.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE Gen_PackageForAPI (
    p_package_name                  IN     VARCHAR2
);

END HZ_MIXNM_DYNAMIC_PKG_GENERATOR;

 

/
