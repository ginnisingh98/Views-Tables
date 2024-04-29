--------------------------------------------------------
--  DDL for Package GMP_MRP_AUTO_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_MRP_AUTO_REL_PKG" AUTHID CURRENT_USER AS
/* $Header: GMPRELMS.pls 120.1 2005/08/30 06:51:13 rpatangy noship $ */

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
      ) ;



END gmp_mrp_auto_rel_pkg;

 

/
