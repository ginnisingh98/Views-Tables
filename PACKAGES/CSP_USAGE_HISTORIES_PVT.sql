--------------------------------------------------------
--  DDL for Package CSP_USAGE_HISTORIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_USAGE_HISTORIES_PVT" AUTHID CURRENT_USER AS
/* $Header: cspvpuhs.pls 115.7 2002/11/26 07:35:57 hhaugeru ship $ */

PROCEDURE create_usage_history
(   errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY NUMBER,
    p_api_version           IN  NUMBER,
    p_organization_id	   IN  NUMBER
);


-- Start of comments
--  API name    : create_usage_history
--  Type        : Private
--  Function    :
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version       Standards input
--              p_organization_id   Organization identifier
--
--  OUT     :   errbuf              standard output parameter
--              retcode             standard output parameter
--
--  Version : Current version   1.0
--              Changed....
--            previous version  none
--              Changed....
--            .
--            .
--            previous version  none
--              Changed....
--            Initial version   1.0
--
--  Notes       :
--              Api is used to create usage history
--
-- End of comments

END;

 

/
