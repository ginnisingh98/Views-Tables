--------------------------------------------------------
--  DDL for Package FV_INSTALL_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_INSTALL_EXTN" AUTHID CURRENT_USER AS
-- $Header: FVXPIXTS.pls 120.2 2002/11/11 20:09:30 ksriniva ship $

PROCEDURE Run_Process (
  errbuf                      OUT NOCOPY      VARCHAR2,
  retcode                     OUT NOCOPY      VARCHAR2);

END FV_Install_Extn ;

 

/
