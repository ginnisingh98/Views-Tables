--------------------------------------------------------
--  DDL for Package GCS_BUILD_EPB_DATA_TR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_BUILD_EPB_DATA_TR_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsepbtrdatas.pls 120.1 2005/10/30 05:18:17 appldev noship $ */

  g_line_size	CONSTANT NUMBER       := 250;

  PROCEDURE Build_epb_datatr_pkg;


END GCS_BUILD_EPB_DATA_TR_PKG;

 

/
