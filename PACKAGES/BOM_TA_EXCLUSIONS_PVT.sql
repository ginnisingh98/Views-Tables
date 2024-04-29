--------------------------------------------------------
--  DDL for Package BOM_TA_EXCLUSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_TA_EXCLUSIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: BOMVTAXS.pls 120.0.12010000.1 2009/03/17 22:44:45 kkonada noship $ */


PROCEDURE Delete_Item_TA_Exclusions (p_del_comp_seq NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2);

END BOM_TA_EXCLUSIONS_PVT;


/
