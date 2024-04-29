--------------------------------------------------------
--  DDL for Package FUN_UPDATE_UPGRADED_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_UPDATE_UPGRADED_TRX_PKG" AUTHID CURRENT_USER AS
/* $Header: funupgrs.pls 120.0 2006/06/16 11:11:46 cjain noship $ */

PROCEDURE UPDATE_UPGRADED_TRX (err_buf                OUT NOCOPY VARCHAR2,
                               ret_code               OUT NOCOPY VARCHAR2,
                               p_org_id               IN         NUMBER,
                               p_legal_entity_id      IN         NUMBER);
END FUN_UPDATE_UPGRADED_TRX_PKG;

 

/
