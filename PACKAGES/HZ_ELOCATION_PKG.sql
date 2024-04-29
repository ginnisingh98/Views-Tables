--------------------------------------------------------
--  DDL for Package HZ_ELOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ELOCATION_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHELOCS.pls 120.4 2005/10/07 00:19:47 acng noship $*/

  --------------------------------------------
  -- declaration of global variables and types
  --------------------------------------------
  g_pkg_name       CONSTANT VARCHAR2(30) := 'hz_elocation_pkg';
  g_debug_count             NUMBER := 0;
  --g_debug                   BOOLEAN := FALSE;
  g_index_name     CONSTANT VARCHAR2(20) := 'hz_locations_n15';
  g_index_owner    CONSTANT VARCHAR2(2)  := 'ar';
  g_commit_interval         VARCHAR2(5)  := '1000';

  ------------------------------------
  -- declaration of private procedures
  ------------------------------------
  --PROCEDURE enable_debug;
  --PROCEDURE disable_debug;
  PROCEDURE create_index;

  PROCEDURE update_geometry (
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY VARCHAR2,
    p_loc_type	      IN  VARCHAR2 DEFAULT 'P',
    p_site_use_type   IN  VARCHAR2 DEFAULT NULL,
    p_country         IN  VARCHAR2 DEFAULT NULL,
    p_iden_addr_only  IN  VARCHAR2 DEFAULT 'N',
    p_incremental     IN  VARCHAR2 DEFAULT 'N',
    p_all_partial     IN  VARCHAR2 DEFAULT 'ALL',
    p_nb_row_update   IN  VARCHAR2 DEFAULT 'ALL',
    p_nb_row          IN  NUMBER   DEFAULT 20,
    p_nb_try          IN  NUMBER   DEFAULT 3

  );

  PROCEDURE rebuild_location_index (
    errbuf              OUT NOCOPY VARCHAR2,
    retcode             OUT NOCOPY VARCHAR2,
    p_concurrent_mode   IN  VARCHAR2 DEFAULT 'Y'
  );

END hz_elocation_pkg;

 

/
