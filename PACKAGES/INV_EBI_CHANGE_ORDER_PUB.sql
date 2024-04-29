--------------------------------------------------------
--  DDL for Package INV_EBI_CHANGE_ORDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_EBI_CHANGE_ORDER_PUB" AUTHID CURRENT_USER AS
/* $Header: INVEIPCOS.pls 120.10.12010000.5 2009/07/24 13:24:23 smukka ship $ */

G_ONLY_STATUS_INFO          CONSTANT  VARCHAR2(50) := 'SEND_ONLY_STATUS_INFO';

/*PROCEDURE validate_eco(
   p_eco_obj           IN  inv_ebi_eco_obj
  ,x_out               OUT NOCOPY   inv_ebi_eco_output_obj
);*/

PROCEDURE process_change_order(
  p_commit     IN  VARCHAR2 := fnd_api.g_false
 ,p_eco_obj    IN  inv_ebi_eco_obj
 ,x_out        OUT NOCOPY inv_ebi_eco_output_obj
) ;

PROCEDURE get_eco (
  p_change_id                 IN              NUMBER
   ,p_last_update_status        IN              VARCHAR2
 ,p_revised_item_sequence_id  IN              NUMBER
 ,p_name_val_list             IN              inv_ebi_name_value_list
 ,x_eco_obj                   OUT NOCOPY      inv_ebi_eco_obj
 ,x_return_status             OUT NOCOPY      VARCHAR2
 ,x_msg_count                 OUT NOCOPY      NUMBER
 ,x_msg_data                  OUT NOCOPY      VARCHAR2
);

PROCEDURE get_eco_list_attr(
  p_change_lst                IN              inv_ebi_change_id_obj_tbl
 ,p_name_val_list             IN              inv_ebi_name_value_list
 ,x_eco_lst_obj               OUT NOCOPY      inv_ebi_eco_out_obj_tbl
 ,x_return_status             OUT NOCOPY      VARCHAR2
 ,x_msg_count                 OUT NOCOPY      NUMBER
 ,x_msg_data                  OUT NOCOPY      VARCHAR2
  );

PROCEDURE process_change_order_list(
  p_commit          IN          VARCHAR2 := fnd_api.g_false
 ,p_eco_obj_list    IN          inv_ebi_eco_obj_tbl
 ,x_out             OUT NOCOPY  inv_ebi_eco_output_obj_tbl
 ,x_return_status   OUT NOCOPY  VARCHAR2
 ,x_msg_count       OUT NOCOPY  NUMBER
 ,x_msg_data        OUT NOCOPY  VARCHAR2
);

PROCEDURE validate_change_order_list(
  p_commit          IN          VARCHAR2 := fnd_api.g_false
 ,p_eco_obj_list    IN          inv_ebi_eco_obj_tbl
 ,x_out             OUT NOCOPY  inv_ebi_eco_output_obj_tbl
 ,x_return_status   OUT NOCOPY  VARCHAR2
 ,x_msg_count       OUT NOCOPY  NUMBER
 ,x_msg_data        OUT NOCOPY  VARCHAR2);


END INV_EBI_CHANGE_ORDER_PUB;

/
