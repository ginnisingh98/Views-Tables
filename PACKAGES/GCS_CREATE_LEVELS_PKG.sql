--------------------------------------------------------
--  DDL for Package GCS_CREATE_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_CREATE_LEVELS_PKG" AUTHID CURRENT_USER AS
/* $Header: gcslevels.pls 120.1 2005/10/30 05:18:58 appldev noship $ */


  --
  -- Procedure
  --   Gcs_Create_Level
  -- Purpose
  --   Create levels
  -- Arguments
  --   errbuf:             Buffer to store the error message
  --   retcode:            Return code
  --   p_level_exists      Returns Y if levels exists for any members
  --   p_dimension         Dimension label
  -- Example
  --
  -- Notes
  PROCEDURE Gcs_Create_Level (
                errbuf       OUT NOCOPY VARCHAR2,
		retcode      OUT NOCOPY VARCHAR2,
                p_level_exists OUT NOCOPY VARCHAR2,
                p_sequence_num     NUMBER,
		p_dimension        VARCHAR2,
                p_hierarchy_name   VARCHAR2,
                p_analysis_flag    VARCHAR2 );


END GCS_CREATE_LEVELS_PKG;

 

/
