--------------------------------------------------------
--  DDL for Package FEM_DIS_HIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIS_HIER_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_dis_hier.pls 120.0 2005/10/19 19:27:15 appldev noship $ */

  PROCEDURE Run_Transformation(
    x_errbuf                  OUT NOCOPY VARCHAR2,
    x_retcode                 OUT NOCOPY VARCHAR2,
    p_dimension_varchar_label IN VARCHAR2
  );

END FEM_DIS_HIER_PKG;

 

/
