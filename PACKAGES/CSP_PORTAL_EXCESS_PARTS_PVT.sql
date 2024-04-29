--------------------------------------------------------
--  DDL for Package CSP_PORTAL_EXCESS_PARTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PORTAL_EXCESS_PARTS_PVT" AUTHID CURRENT_USER AS
/* $Header: cspppexs.pls 115.2 2003/10/15 18:45:32 ajosephg noship $ */

PROCEDURE Portal_Excess_Parts
      (errbuf                   OUT NOCOPY varchar2
      ,retcode                  OUT NOCOPY number
      ,p_resource_id            IN NUMBER
      ,P_resource_type          IN VARCHAR2
      ,p_condition_type	        IN VARCHAR2
      );

END; -- Package spec

 

/
