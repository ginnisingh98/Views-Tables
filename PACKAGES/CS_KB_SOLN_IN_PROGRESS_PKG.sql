--------------------------------------------------------
--  DDL for Package CS_KB_SOLN_IN_PROGRESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_SOLN_IN_PROGRESS_PKG" AUTHID CURRENT_USER as
/* $Header: cskbsips.pls 115.0 2003/08/29 20:57:30 mkettle noship $ */

PROCEDURE CHECK_SOLN_IN_PROGRESS (
  ERRBUF  OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY VARCHAR2);

END CS_KB_SOLN_IN_PROGRESS_PKG;

 

/
