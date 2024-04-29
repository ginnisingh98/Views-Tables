--------------------------------------------------------
--  DDL for Package WMS_CONSOLIDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CONSOLIDATION_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSCONSS.pls 120.4.12010000.1 2008/07/28 18:32:35 appldev ship $ */

TYPE t_genref IS REF CURSOR;


PROCEDURE get_values_for_loc(p_sub                   IN  VARCHAR2,
			     p_loc_id                IN  NUMBER,
			     p_org_id                IN  NUMBER,
			     p_comp_cons_dels_inq_mode IN VARCHAR2,
			     x_total_no_of_dels      OUT NOCOPY NUMBER,
			     x_total_no_of_cons_dels OUT NOCOPY NUMBER,
			     x_total_no_of_lpns      OUT NOCOPY NUMBER,
			     x_return_status         OUT NOCOPY VARCHAR2,
			     x_msg_count             OUT NOCOPY NUMBER,
			     x_msg_data              OUT NOCOPY VARCHAR2);



PROCEDURE get_consolidation_inq_loc(x_loc                   IN OUT NOCOPY VARCHAR2,
				    p_sub                   IN  VARCHAR2,
				    p_org_id                IN  NUMBER,
				    p_comp_cons_dels_inq_mode IN VARCHAR2,
				    x_total_no_of_dels      OUT NOCOPY NUMBER,
				    x_total_no_of_cons_dels OUT NOCOPY NUMBER,
				    x_total_no_of_lpns      OUT NOCOPY NUMBER,
				    x_return_status         OUT NOCOPY VARCHAR2,
				    x_msg_count             OUT NOCOPY NUMBER,
				    x_msg_data              OUT NOCOPY VARCHAR2,
				    x_loc_available         OUT NOCOPY VARCHAR2,
				    x_loc_count             OUT NOCOPY NUMBER);


PROCEDURE get_consolidation_inq_lpn_lov(x_lpn_lov OUT NOCOPY t_genref,
					p_org_id  IN NUMBER,
					p_lpn     IN VARCHAR2);


PROCEDURE get_consolidation_inq_del_lov(x_deliveryLOV     OUT NOCOPY t_genref,
					p_organization_id IN NUMBER,
					p_delivery_name   IN VARCHAR2,
					p_lpn_id          IN NUMBER);


PROCEDURE get_cons_inq_orders_lov(x_order_lov   OUT NOCOPY t_genref,
				  p_org_id      IN NUMBER,
				  p_order       IN VARCHAR2,
				  p_delivery_id IN NUMBER,
				  p_lpn_id      IN NUMBER);


PROCEDURE get_consolidation_inq_sub_lov(x_sub_lov      OUT NOCOPY t_genref,
					p_sub          IN VARCHAR2,
					p_org_id       IN NUMBER);


PROCEDURE get_consolidation_inq_loc_lov(x_loc_lov      OUT NOCOPY t_genref,
					p_sub          IN VARCHAR2,
					p_loc          IN VARCHAR2,
					p_org_id       IN NUMBER,
					p_comp_cons_dels_inq_mode IN VARCHAR2);

PROCEDURE get_consolidation_inq_loc_lov(x_loc_lov      OUT NOCOPY t_genref,
					p_sub          IN VARCHAR2,
					p_loc          IN VARCHAR2,
					p_org_id       IN NUMBER,
					p_comp_cons_dels_inq_mode IN VARCHAR2,
					p_alias        IN VARCHAR2);


PROCEDURE get_values_for_lpn(p_lpn_id                IN  NUMBER,
			     p_org_id                IN  NUMBER,
			     x_sub                   IN  OUT NOCOPY VARCHAR2,
			     x_loc                   IN  OUT NOCOPY VARCHAR2,
			     x_delivery_id           IN  OUT NOCOPY NUMBER,
			     x_order_number          IN  OUT NOCOPY VARCHAR2,
			     p_inquiry_mode          IN  NUMBER,
			     p_comp_cons_dels_inq_mode IN VARCHAR2,
			     x_delivery_status       OUT NOCOPY VARCHAR2,
			     x_return_status         OUT NOCOPY VARCHAR2,
			     x_msg_count             OUT NOCOPY NUMBER,
			     x_msg_data              OUT NOCOPY VARCHAR2,
			     x_lpn                   OUT NOCOPY VARCHAR2,
			     x_project               OUT NOCOPY VARCHAR2,
			     x_task                  OUT NOCOPY VARCHAR2);



PROCEDURE get_consolidation_inq_lpn(x_loc                   IN OUT NOCOPY VARCHAR2,
				    x_sub                   IN OUT NOCOPY VARCHAR2,
				    p_org_id                IN NUMBER,
				    x_delivery_id           IN OUT NOCOPY NUMBER,
				    x_order_number          IN OUT NOCOPY VARCHAR2,
				    p_inquiry_mode          IN NUMBER,
				    p_comp_cons_dels_inq_mode IN VARCHAR2,
				    x_lpn_vector            OUT NOCOPY VARCHAR2,
				    x_delivery_status       OUT NOCOPY VARCHAR2,
				    x_return_status         OUT NOCOPY VARCHAR2,
				    x_msg_count             OUT NOCOPY NUMBER,
				    x_msg_data              OUT	NOCOPY VARCHAR2,
				    x_lpn                   IN OUT NOCOPY VARCHAR2,
				    x_lpn_available         OUT NOCOPY VARCHAR2,
				    x_project               OUT NOCOPY VARCHAR2,
				    x_task                  OUT NOCOPY VARCHAR2);


PROCEDURE get_query_by_del_lpn(x_delivery_id           IN  OUT NOCOPY NUMBER,
			       p_org_id                IN  NUMBER,
			       x_order_number          OUT NOCOPY VARCHAR2,
			       x_loc                   OUT NOCOPY VARCHAR2,
			       x_sub                   OUT NOCOPY VARCHAR2,
			       x_lpn_vector            OUT NOCOPY VARCHAR2,
			       x_delivery_status       OUT NOCOPY VARCHAR2,
			       x_return_status         OUT NOCOPY VARCHAR2,
			       x_msg_count             OUT NOCOPY NUMBER,
			       x_msg_data              OUT NOCOPY VARCHAR2,
			       x_lpn                   OUT NOCOPY VARCHAR2,
			       x_lpn_available         OUT NOCOPY VARCHAR2,
			       x_tot_lines_for_del     OUT NOCOPY NUMBER,
			       x_tot_comp_lines_for_del OUT NOCOPY NUMBER,
			       x_tot_locs_for_del      OUT NOCOPY NUMBER,
			       x_project               OUT NOCOPY VARCHAR2,
			       x_task                  OUT NOCOPY VARCHAR2);


PROCEDURE get_empty_cons_loc_lov(x_loc_lov      OUT NOCOPY t_genref,
				 p_sub          IN VARCHAR2,
				 p_loc          IN VARCHAR2,
				 p_org_id       IN NUMBER,
				 p_alias        IN VARCHAR2);

PROCEDURE get_empty_cons_loc_lov(x_loc_lov      OUT NOCOPY t_genref,
				 p_sub          IN VARCHAR2,
				 p_loc          IN VARCHAR2,
				 p_org_id       IN NUMBER);

PROCEDURE get_empty_cons_loc(p_sub             IN  VARCHAR2,
			     p_org_id          IN  NUMBER,
			     x_loc             OUT NOCOPY VARCHAR2,
			     x_loc_count       OUT NOCOPY NUMBER,
			     x_return_status   OUT NOCOPY VARCHAR2,
			     x_msg_count       OUT NOCOPY NUMBER,
			     x_msg_data        OUT NOCOPY VARCHAR2);


PROCEDURE lpn_mass_move (p_org_id          IN  NUMBER,
			 p_from_sub        IN  VARCHAR2,
			 p_from_loc_id     IN  NUMBER,
			 p_to_sub          IN  VARCHAR2,
			 p_to_loc_id       IN  NUMBER,
			 p_to_loc_type     IN  NUMBER,
                         p_transfer_lpn_id IN  NUMBER,
			 x_return_status   OUT NOCOPY VARCHAR2,
			 x_msg_count       OUT NOCOPY NUMBER,
			 x_msg_data        OUT NOCOPY VARCHAR2);


PROCEDURE get_lpn_mass_move_sub_lov(x_sub_lov      OUT NOCOPY t_genref,
				    p_sub          IN VARCHAR2,
				    p_org_id       IN NUMBER);


PROCEDURE get_lpn_mass_move_locs_lov(x_loc_lov      OUT NOCOPY t_genref,
				     p_org_id       IN NUMBER,
				     p_sub          IN VARCHAR2,
				     p_loc          IN VARCHAR2,
				     p_from_sub     IN VARCHAR2,
				     p_from_loc     IN VARCHAR2);

PROCEDURE get_lpn_mass_move_locs_lov(x_loc_lov      OUT NOCOPY t_genref,
				     p_org_id       IN NUMBER,
				     p_sub          IN VARCHAR2,
				     p_loc          IN VARCHAR2,
				     p_from_sub     IN VARCHAR2,
				     p_from_loc     IN VARCHAR2,
				     p_alias        IN VARCHAR2);

PROCEDURE get_lpn_mass_move_lpn_lov(x_lpn_lov      OUT NOCOPY t_genref,
                                    p_org_id       IN NUMBER,
                                    p_lpn          IN VARCHAR2,
                                    p_from_loc_id  IN VARCHAR2);

FUNCTION is_delivery_consolidated(p_delivery_id IN NUMBER,
				  p_org_id      IN NUMBER,
				  p_sub         IN VARCHAR2 DEFAULT NULL,  -- added default for packing workbench query (patchset J)
				  p_loc_id      IN NUMBER DEFAULT NULL)  -- added default for packing workbench query (patchset J)
  RETURN VARCHAR2;


PROCEDURE create_staging_move
  (p_org_id                       IN  NUMBER
   ,  p_user_id                   IN  NUMBER
   ,  p_emp_id                    IN  NUMBER
   ,  p_eqp_ins                   IN  VARCHAR2
   ,  p_lpn_id                    IN  NUMBER
   ,  x_return_status             OUT nocopy VARCHAR2
   ,  x_msg_count                 OUT NOCOPY  NUMBER
   ,  x_msg_data                  OUT NOCOPY  VARCHAR2
   ,  p_calling_mode              IN VARCHAR2
   ,  p_temp_id                   OUT NOCOPY NUMBER
   );


PROCEDURE mydebug(msg in varchar2);

END wms_consolidation_pub;

/
