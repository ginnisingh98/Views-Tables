--------------------------------------------------------
--  DDL for Package GMS_INSTALL_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_INSTALL_EXTN" AUTHID CURRENT_USER AS
/* $Header: gmspixts.pls 115.3 2002/11/26 00:38:48 jmuthuku ship $ */

PROCEDURE Run_Process (
  errbuf                      OUT NOCOPY      VARCHAR2,
  retcode                     OUT NOCOPY      VARCHAR2);

END GMS_Install_Extn ;

 

/
