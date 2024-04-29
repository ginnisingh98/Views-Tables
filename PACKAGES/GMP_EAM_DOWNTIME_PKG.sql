--------------------------------------------------------
--  DDL for Package GMP_EAM_DOWNTIME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_EAM_DOWNTIME_PKG" AUTHID CURRENT_USER AS
/* $Header: GMPASUNS.pls 120.1 2005/09/02 13:53:41 rpatangy noship $ */

  PROCEDURE insert_man_unavail
      (
        errbuf                   OUT  NOCOPY VARCHAR2,
        retcode                  OUT  NOCOPY NUMBER,
        p_organization_id        IN   NUMBER,
        p_include_unreleased     IN   NUMBER,   /* 3467386 */
        p_include_unfirmed       IN   NUMBER,   /* 3467386 */
        p_resources              IN   VARCHAR2   /* 3467386 */
      ) ;

END gmp_eam_downtime_pkg;

 

/
