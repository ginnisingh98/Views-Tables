--------------------------------------------------------
--  DDL for Package GCS_DATASUB_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DATASUB_DYNAMIC_PKG" AUTHID CURRENT_USER as
/* $Header: gcs_datasub_dyns.pls 120.1 2005/10/30 05:17:21 appldev noship $ */

  --
  -- Procedure
  --   Write_To_Log
  -- Purpose
  --   Write the text given to the log in 3500 character increments
  --   this happened. Write it to the log repository.
  -- Arguments
  --   p_module         Name of the module
  --   p_level          Logging level
  --   p_text           Text to write
  -- Example
  --
  -- Notes
  --
  PROCEDURE write_to_log
    (p_module   VARCHAR2,
     p_level    NUMBER,
     p_text     VARCHAR2);

  PROCEDURE create_datasub_utility_pkg (p_retcode	NUMBER,
					p_errbuf	VARCHAR2);

END GCS_DATASUB_DYNAMIC_PKG;


 

/
