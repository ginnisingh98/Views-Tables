--------------------------------------------------------
--  DDL for Package CST_OSFMUPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_OSFMUPGRADE_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTVUPGS.pls 115.0 2003/03/24 06:30:54 visrivas noship $ */

PROCEDURE Update_Quantity_Issued(
                                 ERRBUF OUT NOCOPY  VARCHAR2,
                                 RETCODE OUT NOCOPY NUMBER,
                                 p_organization_id IN NUMBER,
                                 p_api_version     IN NUMBER DEFAULT 1.0);

END CST_OSFMUpgrade_PVT;

 

/
