--------------------------------------------------------
--  DDL for Package CSP_SUPPLY_DEMAND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_SUPPLY_DEMAND_PVT" AUTHID CURRENT_USER AS
/* $Header: cspvpsds.pls 115.16 2002/11/26 07:37:35 hhaugeru ship $ */
PROCEDURE main
(   errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY NUMBER,
    p_api_version           IN  NUMBER,
    p_organization_id       IN  NUMBER,
    p_level_id		    IN  VARCHAR2 default null
);
  g_level_id                    varchar2(2000) default null;
END;

 

/
