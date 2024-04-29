--------------------------------------------------------
--  DDL for Package CS_KB_TRACKING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_TRACKING_PKG" AUTHID CURRENT_USER as
/* $Header: cskbtks.pls 115.0 2003/08/18 22:44:43 allau noship $ */

PROCEDURE PURGE_TRACKING_HISTORY (ERRBUF  OUT NOCOPY VARCHAR2,
                                  RETCODE OUT NOCOPY VARCHAR2);
END CS_KB_TRACKING_PKG;

 

/
