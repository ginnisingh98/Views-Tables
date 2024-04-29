--------------------------------------------------------
--  DDL for Package MSC_ATP_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_CUSTOM" AUTHID CURRENT_USER AS
/* $Header: MSCATPCS.pls 120.2 2007/12/12 10:22:03 sbnaik ship $  */

PROCEDURE Custom_Pre_Allocation (
        p_plan_id       IN              NUMBER
);

PROCEDURE Custom_Post_ATP_API ( p_atp_rec        IN  MRP_ATP_PUB.ATP_Rec_Typ,
                                x_atp_rec        OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ,
                                x_modify_flag    OUT NOCOPY NUMBER,
                                x_return_status  OUT NOCOPY VARCHAR2
                               );

END MSC_ATP_CUSTOM;

/
