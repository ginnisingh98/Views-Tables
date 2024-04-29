--------------------------------------------------------
--  DDL for Package WIP_BIS_PERIOD_BAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_BIS_PERIOD_BAL_PKG" AUTHID CURRENT_USER as
/* $Header: wipbiits.pls 115.1 2003/01/07 22:34:42 seli noship $ */

PROCEDURE Refresh (
  errbuf  IN OUT NOCOPY VARCHAR2,
  retcode IN OUT NOCOPY VARCHAR2
);

END WIP_BIS_PERIOD_BAL_PKG;

 

/
