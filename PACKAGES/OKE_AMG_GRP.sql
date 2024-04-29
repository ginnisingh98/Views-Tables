--------------------------------------------------------
--  DDL for Package OKE_AMG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_AMG_GRP" AUTHID CURRENT_USER AS
/* $Header: OKEAMGDS.pls 120.1 2005/09/20 10:29:02 ausmani noship $ */

   TYPE dlv_rec_type IS RECORD(
                         dlv_short_name         VARCHAR2(150),
                         dlv_description        VARCHAR2(240),
                         item_id                NUMBER       ,
                         inventory_org_id       NUMBER       ,
                         quantity               NUMBER       ,
                         uom_code               VARCHAR2(30) ,
                         unit_price             NUMBER       ,
                         unit_number            VARCHAR2(30) ,
                         pa_deliverable_id      NUMBER       ,
                         project_id             NUMBER       ,
                         currency_code          VARCHAR2(30));

    TYPE dlv_ship_action_rec_type IS RECORD(
                         pa_action_id               NUMBER      ,
	                 pa_deliverable_id          NUMBER      ,
                         action_name                VARCHAR2(240),
                         ship_finnancial_task_id    NUMBER      ,
                         demand_schedule            VARCHAR2(10),
                         ship_from_organization_id  NUMBER      ,
                         ship_from_location_id      NUMBER      ,
                         ship_to_organization_id    NUMBER      ,
                         ship_to_location_id        NUMBER      ,
                         INSPECTION_REQ_FLAG        Varchar2(1),
                         promised_shipment_date     DATE        ,
                         expected_shipment_date     DATE        ,
                         volume                     NUMBER      ,
                         volume_uom                 VARCHAR2(10),
                         weight                     NUMBER      ,
                         weight_uom                 VARCHAR2(10),
                         quantity                  NUMBER      ,
                         uom_code                   VARCHAR2(10),
                         ready_to_ship_flag         VARCHAR2(1) ,
                         initiate_planning_flag     VARCHAR2(1) ,
                         initiate_shipping_flag     VARCHAR2(1) );

    TYPE dlv_req_action_rec_type IS RECORD(
	                 pa_action_id               NUMBER       ,
	                 pa_deliverable_id          NUMBER      ,
                         action_name                VARCHAR2(240) ,
                         proc_finnancial_task_id    NUMBER       ,
                         destination_type_code      VARCHAR2(30) ,
                         receiving_org_id           NUMBER       ,
                         receiving_location_id      VARCHAR2(150),
                         po_need_by_date            DATE         ,
                         vendor_id                  NUMBER       ,
                         vendor_site_id             NUMBER       ,
                         quantity                   NUMBER       ,
                         uom_code                   Varchar2(30) ,
                         unit_price                 NUMBER       ,
                         currency                   Varchar2(30) ,
                         exchange_rate_type         VARCHAR2(30) ,
                         exchange_rate_date         DATE         ,
                         exchange_rate              NUMBER       ,
                         expenditure_type           VARCHAR2(30) ,
                         expenditure_org_id         NUMBER       ,
                         expenditure_item_date      DATE         ,
                         requisition_line_type_id   NUMBER       ,
                         category_id                NUMBER       ,
                         ready_to_procure_flag      VARCHAR2(1)  ,
                         initiate_procure_flag      VARCHAR2(1) );

Procedure manage_dlv(
                    p_api_version         IN  Number,
                    p_init_msg_list	  IN  Varchar2 default FND_API.G_FALSE,
                    p_commit	          IN  Varchar2 default fnd_api.g_false,
                    p_action       	  IN  Varchar2,
	            p_item_dlv		  IN  Varchar2,
	            p_master_inv_org_id	  IN	Number,
	            p_dlv_rec		IN OUT NOCOPY	dlv_rec_type,
	            x_return_status	OUT NOCOPY	Varchar2,
                    x_msg_data		OUT	 NOCOPY Varchar2,
                    x_msg_count		OUT	 NOCOPY Number
                     );

Procedure manage_dlv_action(
                    p_api_version         IN  Number,
                    p_init_msg_list	  IN  Varchar2 default fnd_api.g_false,
                    p_commit	          IN  Varchar2 default fnd_api.g_false,
                    p_action       	  IN  Varchar2,
	            p_item_dlv		  IN  Varchar2,
	            p_master_inv_org_id	  IN  Number,
	            p_dlv_action_type	  IN  Varchar2,
               	    p_dlv_ship_action_rec IN OUT NOCOPY dlv_ship_action_rec_type,
	            p_dlv_req_action_rec  IN OUT NOCOPY dlv_req_action_rec_type,
	            x_return_status	  OUT NOCOPY 	Varchar2,
               	    x_msg_data		  OUT NOCOPY 	Varchar2,
                    x_msg_count		  OUT NOCOPY 	Number
                        );

Procedure initiate_dlv_action     (
                    p_api_version       IN Number,
                    p_init_msg_list	IN Varchar2 default fnd_api.g_false,
                    p_commit	        IN Varchar2 default fnd_api.g_false,
                    p_pa_action_id      IN Number,
	            p_dlv_action_type	IN Varchar2,
	            x_return_status	OUT NOCOPY 	Varchar2,
                    x_msg_data	        OUT NOCOPY 	Varchar2,
                    x_msg_count	        OUT NOCOPY 	Number
                        );
END OKE_AMG_GRP;

 

/
