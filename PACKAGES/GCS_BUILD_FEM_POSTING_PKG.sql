--------------------------------------------------------
--  DDL for Package GCS_BUILD_FEM_POSTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_BUILD_FEM_POSTING_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsfempds.pls 120.1 2005/10/30 05:18:29 appldev noship $ */
--
-- Package
--   Create_Package
-- Purpose
--   Create GCS_DYN_FEM_POSTING_PKG
-- History
--   12-OCT-03	R Goyal		Created

--

g_line_size	CONSTANT NUMBER       := 250;


  PROCEDURE Create_Package;


END GCS_BUILD_FEM_POSTING_PKG;

 

/
