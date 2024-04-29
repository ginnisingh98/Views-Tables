--------------------------------------------------------
--  DDL for Package Body GMP_MRP_AUTO_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_MRP_AUTO_REL_PKG" AS
/* $Header: GMPRELMB.pls 120.1 2005/08/30 06:51:32 rpatangy noship $ */

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   perform_auto_release                                          */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* retrieves the rows from the Cursor                              */
  /*                                                                 */
  /* History :                                                       */
  /* Sridhar 05-SEP-2003  Initial implementation                     */
  /* =============================================================== */
  PROCEDURE perform_auto_release
      (
        errbuf                   OUT  NOCOPY VARCHAR2,
        retcode                  OUT  NOCOPY VARCHAR2,
        p_orgn_code              IN   VARCHAR2,
        p_schedule               IN   VARCHAR2,
        p_fplanner               IN   VARCHAR2,
        p_tplanner               IN   VARCHAR2,
        p_fplanning_class        IN   VARCHAR2,
        p_tplanning_class        IN   VARCHAR2,
        p_fitem_no               IN   VARCHAR2,
        p_titem_no               IN   VARCHAR2,
        p_fwhse_code             IN   VARCHAR2,
        p_twhse_code             IN   VARCHAR2,
        p_fdate                  IN   VARCHAR2,
        p_tdate                  IN   VARCHAR2
      ) IS

BEGIN
    retcode   := '0';
    errbuf   := null;
END perform_auto_release ;

END gmp_mrp_auto_rel_pkg;

/
