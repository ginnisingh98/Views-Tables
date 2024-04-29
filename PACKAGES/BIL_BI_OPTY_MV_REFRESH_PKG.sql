--------------------------------------------------------
--  DDL for Package BIL_BI_OPTY_MV_REFRESH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_BI_OPTY_MV_REFRESH_PKG" AUTHID CURRENT_USER AS
  /*$Header: bilrmvs.pls 115.2 2004/07/02 10:59:29 asolaiy noship $*/

  PROCEDURE CUSTOM_API
  (
    p_param IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL
  );
  END BIL_BI_OPTY_MV_REFRESH_PKG;

 

/
