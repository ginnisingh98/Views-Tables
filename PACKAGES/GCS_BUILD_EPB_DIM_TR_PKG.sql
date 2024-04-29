--------------------------------------------------------
--  DDL for Package GCS_BUILD_EPB_DIM_TR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_BUILD_EPB_DIM_TR_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsdimtrs.pls 120.1 2005/10/30 05:17:30 appldev noship $ */

  g_line_size	CONSTANT NUMBER       := 250;

  PROCEDURE Build_epb_dimtr_pkg;

  FUNCTION get_obj_def_id(num VARCHAR2) RETURN NUMBER;


END GCS_BUILD_EPB_DIM_TR_PKG;

 

/
