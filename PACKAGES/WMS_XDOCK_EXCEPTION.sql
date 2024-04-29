--------------------------------------------------------
--  DDL for Package WMS_XDOCK_EXCEPTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_XDOCK_EXCEPTION" AUTHID CURRENT_USER AS
/* $Header: WMSXDEXS.pls 120.0 2005/06/24 16:54:01 gayu noship $*/

PROCEDURE find_exception
  (   x_errbuf            OUT nocopy VARCHAR2
     ,x_retcode           OUT nocopy NUMBER
     ,p_org_id            IN         NUMBER
     ,p_look_ahead_time   IN         NUMBER ) ;
END wms_xdock_exception;


 

/
