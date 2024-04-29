--------------------------------------------------------
--  DDL for Package PV_PARTNER_MIGRATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PARTNER_MIGRATIONS_PUB" 
/* $Header: pvxpmigs.pls 120.2 2005/08/23 01:38:34 appldev noship $ */
  AUTHID CURRENT_USER AS

/*============================================================================
-- Start of comments
--  API name  : Convert_Partner_Type
--  Type      : Public.
--  Function  : This api is used to migrate the partners from multiple partner
--              types to single partners with primary partner type
--
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_running_mode                IN  integer,
--			p_overwrite                   IN  VARCHAR2,
--
--  OUT   : Errbuf          OUT VARCHAR2
--          retcode         OUT VARCHAR2
--
--  Version : Current version   1.0
--            Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/



   PROCEDURE Convert_Partner_Type
     (
        Errbuf                         OUT NOCOPY VARCHAR2,
        Retcode                        OUT NOCOPY VARCHAR2,
        p_Running_Mode        IN varchar2 DEFAULT 'EVALUATION',
        p_OverWrite           IN varchar2 DEFAULT 'N'
);

END; -- Package spec

 

/
