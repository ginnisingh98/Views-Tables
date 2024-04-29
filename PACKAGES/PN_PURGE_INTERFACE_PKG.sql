--------------------------------------------------------
--  DDL for Package PN_PURGE_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_PURGE_INTERFACE_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNVPURGS.pls 120.0 2005/05/29 12:12:25 appldev noship $

PROCEDURE purge_cad ( errbuf          OUT NOCOPY          VARCHAR2,
                      retcode         OUT NOCOPY          NUMBER,
                      function_flag                VARCHAR2,
                      p_batch_name                 VARCHAR2 DEFAULT NULL );

PROCEDURE delete_locations ( p_batch_name          VARCHAR2 DEFAULT NULL );


PROCEDURE delete_space_allocations ( p_batch_name  VARCHAR2 DEFAULT NULL );

END  PN_PURGE_INTERFACE_PKG;

 

/
