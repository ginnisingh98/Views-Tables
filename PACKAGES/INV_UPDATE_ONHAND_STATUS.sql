--------------------------------------------------------
--  DDL for Package INV_UPDATE_ONHAND_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_UPDATE_ONHAND_STATUS" AUTHID CURRENT_USER AS
/*  $Header: INVONSUS.pls 120.2 2008/01/11 21:07:36 musinha noship $*/
  PROCEDURE update_onhand_status(
                            x_errbuf          	OUT NOCOPY VARCHAR2
                           ,x_retcode           OUT NOCOPY NUMBER
                           ,p_from_org_code     IN  VARCHAR2
                           ,p_to_org_code       IN  VARCHAR2
                           ,p_default_status    IN  VARCHAR2
                          );


END INV_UPDATE_ONHAND_STATUS ;

/
