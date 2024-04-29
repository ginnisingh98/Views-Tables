--------------------------------------------------------
--  DDL for Package BOM_UDA_OVERRIDES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_UDA_OVERRIDES_PVT" AUTHID CURRENT_USER AS
/* $Header: BOMVATOS.pls 120.0.12010000.3 2009/03/17 01:49:43 ksuleman noship $ */


PROCEDURE Copy_Comp_UDA_Overrides (p_old_comp_seq NUMBER, p_new_comp_seq NUMBER);



PROCEDURE Delete_Comp_UDA_Overrides (p_del_comp_seq NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2);

END BOM_UDA_OVERRIDES_PVT;


/
