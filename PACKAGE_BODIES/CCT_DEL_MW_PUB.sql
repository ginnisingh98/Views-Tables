--------------------------------------------------------
--  DDL for Package Body CCT_DEL_MW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_DEL_MW_PUB" AS
/* $Header: cctdelmb.pls 115.1 2003/02/19 00:12:18 gvasvani noship $ */

    PROCEDURE DELETE_ALL_MW_RP_TEL IS
    BEGIN
	delete from cct_middlewares;
	delete from cct_middleware_values;
	delete from cct_mw_route_points;
	delete from cct_mw_route_point_values;
	delete from cct_ivr_maps;
	delete from cct_telesets;
    END DELETE_ALL_MW_RP_TEL;

END CCT_DEL_MW_PUB;

/
