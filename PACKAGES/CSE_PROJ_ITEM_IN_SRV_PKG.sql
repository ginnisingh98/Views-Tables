--------------------------------------------------------
--  DDL for Package CSE_PROJ_ITEM_IN_SRV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_PROJ_ITEM_IN_SRV_PKG" AUTHID CURRENT_USER AS
/* $Header: CSEITSVS.pls 120.3.12010000.1 2008/07/30 05:18:09 appldev ship $ */


  PROCEDURE interface_nl_to_pa(
    p_in_srv_pa_attr_rec  IN  CSE_DATASTRUCTURES_PUB.Proj_Itm_Insv_PA_ATTR_REC_TYPE,
    p_conc_request_id     IN  NUMBER DEFAULT NULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_message       OUT NOCOPY VARCHAR2);

  PROCEDURE interface_nl_to_pa(
    p_in_srv_pa_attr_tbl  IN  CSE_DATASTRUCTURES_PUB.Proj_Itm_Insv_PA_ATTR_tbl_TYPE,
    p_conc_request_id     IN  NUMBER DEFAULT NULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_message       OUT NOCOPY VARCHAR2);

END cse_proj_item_in_srv_pkg;

/
