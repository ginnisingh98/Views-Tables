--------------------------------------------------------
--  DDL for Package AZ_MORG_CONVERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZ_MORG_CONVERT_PKG" AUTHID CURRENT_USER AS
  /* $Header: azmorgs.pls 115.5 2003/03/07 20:05:38 jke noship $*/

  PROCEDURE az_morg_main (errbuf   OUT NOCOPY VARCHAR2,
			  retcode  OUT NOCOPY NUMBER);

end az_morg_convert_pkg;

 

/
