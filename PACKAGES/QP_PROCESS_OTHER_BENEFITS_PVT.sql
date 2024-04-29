--------------------------------------------------------
--  DDL for Package QP_PROCESS_OTHER_BENEFITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PROCESS_OTHER_BENEFITS_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVOTHS.pls 120.1.12010000.1 2008/07/28 11:59:05 appldev ship $ */
  PROCEDURE Calculate_Recurring_Quantity(p_list_line_id     	 NUMBER,
                                         p_list_header_id        NUMBER,
                                         p_line_index            NUMBER,
                                         p_benefit_line_id  	 NUMBER,
                                         x_benefit_line_qty   OUT NOCOPY NUMBER,
                                         x_return_status      OUT NOCOPY VARCHAR2,
                                         x_return_status_txt  OUT NOCOPY VARCHAR2);

  PROCEDURE Calculate_Recurring_Quantity(p_pricing_phase_id        NUMBER,
                                       x_return_status      OUT NOCOPY VARCHAR2,
                                       x_return_status_txt  OUT NOCOPY VARCHAR2);

  PROCEDURE Find_Qualification_For_Benefit(p_line_index            NUMBER,
                                         p_list_line_id            NUMBER,
                                         p_rltd_modifier_type      VARCHAR2,
                                         p_list_line_type          VARCHAR2,
                                         x_qualified_flag          OUT NOCOPY BOOLEAN,
                                         x_return_status           OUT NOCOPY VARCHAR2,
                                         x_return_status_txt       OUT NOCOPY VARCHAR2);

  PROCEDURE Process_Other_Benefits(p_line_index             NUMBER,
                                   p_pricing_phase_id  	    NUMBER,
                                   p_pricing_effective_date DATE,
                                   p_line_quantity          NUMBER,
                                   p_simulation_flag        VARCHAR2,
                                   x_return_status          OUT NOCOPY VARCHAR2,
                                   x_return_status_txt      OUT NOCOPY VARCHAR2);

  PROCEDURE Process_PRG(p_line_index	         NUMBER,
                        p_line_detail_index      NUMBER,
                        p_modifier_level_code    VARCHAR2,
                        p_list_line_id           NUMBER,
                        p_pricing_phase_id       NUMBER,
                        x_return_status      OUT NOCOPY VARCHAR2,
                        x_return_status_txt  OUT NOCOPY VARCHAR2);

  PROCEDURE Process_OID(p_line_index	         NUMBER,
                        p_list_line_id           NUMBER,
                        p_pricing_phase_id       NUMBER,
                        x_return_status      OUT NOCOPY VARCHAR2,
                        x_return_status_txt  OUT NOCOPY VARCHAR2);

END QP_Process_Other_Benefits_PVT;

/
