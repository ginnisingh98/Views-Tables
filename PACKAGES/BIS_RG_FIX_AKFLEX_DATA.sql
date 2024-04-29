--------------------------------------------------------
--  DDL for Package BIS_RG_FIX_AKFLEX_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RG_FIX_AKFLEX_DATA" AUTHID CURRENT_USER as
/* $Header: BISVAFXS.pls 115.5 2002/12/23 18:43:30 kiprabha noship $ */
----------------------------------------------------------------------------
--  PACKAGE:      BIS_SCHEDULE_PVT
--                                                                        --
--  DESCRIPTION:  Private package to move AK region flex field data for
--                Report regions from Global Data Elements to BIS PM Viewer
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                --
--  02-25-00   amkulkar   Initial creation                                --

----------------------------------------------------------------------------
PROCEDURE FIX_AK_REGIONITEMS
(
 x_return_code    OUT  NOCOPY NUMBER
,x_return_status  OUT  NOCOPY VARCHAR2
)
;
PROCEDURE FIX_AK_REGIONS
(
 x_return_code    OUT  NOCOPY NUMBER
,x_return_status  OUT  NOCOPY VARCHAR2
)
;
END BIS_RG_FIX_AKFLEX_DATA;

 

/
