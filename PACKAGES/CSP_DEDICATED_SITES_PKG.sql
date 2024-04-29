--------------------------------------------------------
--  DDL for Package CSP_DEDICATED_SITES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_DEDICATED_SITES_PKG" AUTHID CURRENT_USER AS
/* $Header: csptdsis.pls 120.0.12010000.2 2010/04/18 23:16:30 ajosephg noship $ */
-- Start of Comments
-- Package name     : CSP_DEDICATED_SITES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
px_DEDICATED_SITES_ID                       NUMBER
,p_PLANNING_PARAMETERS_ID                  NUMBER
,p_PARTY_SITE_ID                           NUMBER
,p_CREATED_BY                              NUMBER
,p_CREATION_DATE                           DATE
,p_LAST_UPDATED_BY                         NUMBER
,p_LAST_UPDATE_DATE                        DATE
,p_LAST_UPDATE_LOGIN                       NUMBER
);

PROCEDURE Update_Row(
p_DEDICATED_SITES_ID                       NUMBER
,p_PLANNING_PARAMETERS_ID                  NUMBER
,p_PARTY_SITE_ID                           NUMBER
,p_CREATED_BY                              NUMBER
,p_CREATION_DATE                           DATE
,p_LAST_UPDATED_BY                         NUMBER
,p_LAST_UPDATE_DATE                        DATE
,p_LAST_UPDATE_LOGIN                       NUMBER
);
PROCEDURE Lock_Row(
p_DEDICATED_SITES_ID                       NUMBER
,p_PLANNING_PARAMETERS_ID                  NUMBER
,p_PARTY_SITE_ID                           NUMBER
,p_CREATED_BY                              NUMBER
,p_CREATION_DATE                           DATE
,p_LAST_UPDATED_BY                         NUMBER
,p_LAST_UPDATE_DATE                        DATE
,p_LAST_UPDATE_LOGIN                       NUMBER
);

PROCEDURE Delete_Row(
p_DEDICATED_SITES_ID                       NUMBER
,p_PLANNING_PARAMETERS_ID                  NUMBER
,p_PARTY_SITE_ID                           NUMBER
);

End CSP_DEDICATED_SITES_PKG;

/
