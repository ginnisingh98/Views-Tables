--------------------------------------------------------
--  DDL for Package RRS_ELOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_ELOCATION_PKG" AUTHID CURRENT_USER AS
/*$Header: RRSELOCS.pls 120.0 2006/01/19 07:51:35 swbhatna noship $*/

  --------------------------------------
  -- PUBLIC PROCEDURE rebuild_spatial_indexes
  -- DESCRIPTION
  --   Rebuilds the spatial index on RRS_SITE_TMP.GEOMETRY and RRS_TRADE_AREAS.GEOMETRY.
  --   Rebuilding the spatial index is required so that the index performs adequately,
  --   queries can accurately extract the spatial data and Spatial functions can be called
  --   on these columns
  -- ARGUMENTS
  --   OUT:
  --     errbuf                         Standard AOL concurrent program error buffer.
  --     retcode                        Standard AOL concurrent program return code.
  -- MODIFICATION HISTORY
  --   18/01/2006 swbhatna              Created.
  --------------------------------------
  PROCEDURE rebuild_spatial_indexes (
    errbuf              OUT NOCOPY VARCHAR2,
    retcode             OUT NOCOPY VARCHAR2
  );

  PROCEDURE Update_Index_Metadata (
  p_index_name   IN  VARCHAR2
  );

  PROCEDURE Create_Index (
  p_index_name   IN  VARCHAR2
  );

END rrs_elocation_pkg;

/
