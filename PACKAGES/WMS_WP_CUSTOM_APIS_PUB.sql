--------------------------------------------------------
--  DDL for Package WMS_WP_CUSTOM_APIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_WP_CUSTOM_APIS_PUB" AUTHID CURRENT_USER as
/* $Header: WMSWPCAS.pls 120.2.12010000.1 2009/03/25 09:55:22 shrmitra noship $ */


PROCEDURE create_wave_lines_cust(p_wave_header_id                   NUMBER,
                                     x_api_is_implemented         OUT   NOCOPY BOOLEAN,
                                     x_custom_line_tbl            OUT   NOCOPY wms_wave_planning_pvt.line_tbl_typ,
                                     x_custom_line_action_tbl     OUT   NOCOPY wms_wave_planning_pvt.action_tbl_typ,
                                     x_return_status              OUT 	NOCOPY VARCHAR2,
                                     x_msg_count                  OUT 	NOCOPY NUMBER,
                                     x_msg_data                   OUT 	NOCOPY VARCHAR2);

PROCEDURE Get_wave_exceptions_cust(x_api_is_implemented           OUT   NOCOPY BOOLEAN,
                                   p_exception_name               IN VARCHAR2,
                                   p_organization_id              IN NUMBER,
                                   p_wave                         IN NUMBER,
                                   p_exception_entity             IN VARCHAR2,
                                   p_progress_stage               IN VARCHAR2,
                                   p_completion_threshold         IN NUMBER,
                                   p_high_sev_exception_threshold IN NUMBER,
                                   p_low_sev_exception_threshold  IN NUMBER,
                                   p_take_corrective_measures     IN VARCHAR2,
                                   p_release_back_ordered_lines   IN VARCHAR2,
                                   p_action_name                  IN VARCHAR2,
                                   x_return_status              OUT 	NOCOPY VARCHAR2,
                                   x_msg_count                  OUT 	NOCOPY NUMBER,
                                   x_msg_data                   OUT 	NOCOPY VARCHAR2);

PROCEDURE task_release_cust(p_organization_id            IN NUMBER,
                            p_custom_plan_tolerance      IN NUMBER,
                            p_final_mmtt_table           IN OUT nocopy wms_wave_planning_pvt.number_table_type,
                            x_return_status              OUT 	NOCOPY VARCHAR2,
                            x_msg_count                  OUT 	NOCOPY NUMBER,
                            x_msg_data                   OUT 	NOCOPY VARCHAR2
                           );

END wms_wp_custom_apis_pub;


/
