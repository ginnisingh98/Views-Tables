--------------------------------------------------------
--  DDL for Package OE_CONFIG_TSO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CONFIG_TSO_GRP" AUTHID CURRENT_USER AS
/* $Header: OEXGTSOS.pls 120.1 2005/06/14 00:54:48 appldev  $ */


PROCEDURE Get_MACD_Action_Mode
(
  p_line_id           IN  NUMBER := NULL
 ,p_top_model_line_id IN  NUMBER := NULL
 ,x_config_mode       OUT NOCOPY NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
);

Procedure Process_MACD_Order
(P_api_version_number     IN  NUMBER,
 P_sold_to_org_id         IN  NUMBER,
 P_x_header_id            IN  OUT NOCOPY NUMBER,
 P_MACD_Action            IN  VARCHAR2,
 P_Instance_Tbl           IN  csi_datastructures_pub.instance_cz_tbl,
 P_Extended_Attrib_Tbl    IN  csi_datastructures_pub.ext_attrib_values_tbl,
 X_container_line_id      OUT NOCOPY NUMBER,
 X_number_of_containers   OUT NOCOPY NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2,
 x_msg_count              OUT NOCOPY VARCHAR2,
 x_msg_data               OUT NOCOPY VARCHAR2);

END OE_CONFIG_TSO_GRP;

 

/
