--------------------------------------------------------
--  DDL for Package HZ_GNR_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GNR_GEN_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHGNRGS.pls 120.2 2005/08/03 02:42:11 haradhak noship $ */

  --------------------------------------
  -- procedures and functions
  --------------------------------------
  --------------------------------------
  /**
   * PROCEDURE genPkg
   *
   * DESCRIPTION
   *     This private procedure is used to generate map specific  package with
   *     GNR search procedures
   *
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *
   *     p_map_id          Map ID
   *
   *   OUT:
   *
   *   x_pkgName  generated package name
   *   x_status   indicates if the genPkg was sucessfull or not.
   *
   * NOTES
   *
   *
   * MODIFICATION HISTORY
   *
   *
   *
   */
  --------------------------------------
  procedure genPkg(
    p_map_id           IN  NUMBER,
    x_pkgName          OUT NOCOPY VARCHAR2,
    x_status           OUT NOCOPY VARCHAR2);
  --------------------------------------
end HZ_GNR_GEN_PKG;

 

/
