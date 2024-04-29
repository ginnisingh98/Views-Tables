--------------------------------------------------------
--  DDL for Package MRP_SCATP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SCATP_PUB" AUTHID CURRENT_USER AS
/* $Header: MRPPATPS.pls 115.7 2003/02/06 22:16:21 ichoudhu ship $  */

PROCEDURE Insert_Line_MDI (
   p_api_version        IN      NUMBER,
   x_return_status      OUT NOCOPY     VARCHAR2,
   x_msg_count          OUT NOCOPY     NUMBER,
   x_msg_data           OUT NOCOPY     VARCHAR2,
   p_line_id            IN      NUMBER,
   p_assignment_set_id  IN      NUMBER,
   p_atp_group_id        IN OUT NOCOPY     NUMBER,
   x_session_id          OUT NOCOPY     NUMBER );

PROCEDURE Insert_Supply_Sources_MDI (
   p_api_version        IN      NUMBER,
   x_return_status      OUT NOCOPY     VARCHAR2,
   x_msg_count          OUT NOCOPY     NUMBER,
   x_msg_data           OUT NOCOPY     VARCHAR2,
   p_atp_group_id       IN      NUMBER,
   p_assignment_set_id  IN      NUMBER,
   x_session_id          OUT NOCOPY     NUMBER );

PROCEDURE Uncheck (
   p_api_version        IN      NUMBER,
   x_return_status      OUT NOCOPY     VARCHAR2,
   x_msg_count          OUT NOCOPY     NUMBER,
   x_msg_data           OUT NOCOPY     VARCHAR2,
   p_atp_group_id       IN      NUMBER );

PROCEDURE Insert_Res_MDI (
   x_err_num            OUT NOCOPY     NUMBER,
   x_err_msg            OUT NOCOPY     VARCHAR2,
   p_atp_group_id       IN      NUMBER );

PROCEDURE Insert_Comp_MDI (
   p_api_version        IN      NUMBER,
   x_return_status      OUT NOCOPY     VARCHAR2,
   x_msg_count          OUT NOCOPY     NUMBER,
   x_msg_data           OUT NOCOPY     VARCHAR2,
   p_atp_group_id       IN      NUMBER );

FUNCTION required_component(
   p_top_bill_seq_id IN NUMBER,
   p_plan_level      IN NUMBER,
   p_request_date    IN DATE,
   p_comp_seq_id     IN NUMBER,
   p_component_code  IN VARCHAR2)
return NUMBER;

FUNCTION mtl_wip_supply_type(
   p_top_bill_seq_id IN NUMBER,
   p_comp_id     IN NUMBER)
return NUMBER;

END MRP_SCATP_PUB;

 

/
