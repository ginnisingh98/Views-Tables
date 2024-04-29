--------------------------------------------------------
--  DDL for Package EGO_P4T_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_P4T_UPGRADE_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOP4TUS.pls 120.1.12010000.2 2009/02/11 07:43:59 chechand noship $ */

  PROCEDURE upgrade_to_pim4telco(start_effective_date IN DATE);
END ego_p4t_upgrade_pvt;

/
