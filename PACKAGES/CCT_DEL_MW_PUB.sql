--------------------------------------------------------
--  DDL for Package CCT_DEL_MW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_DEL_MW_PUB" AUTHID CURRENT_USER AS
/* $Header: cctdelms.pls 115.0 2003/02/18 00:23:32 gvasvani noship $ */

-- Delete CCT Middleware Configurations, Route Points, IVR Mapping and
-- Telesets.

    PROCEDURE DELETE_ALL_MW_RP_TEL;

END CCT_DEL_MW_PUB;

 

/
