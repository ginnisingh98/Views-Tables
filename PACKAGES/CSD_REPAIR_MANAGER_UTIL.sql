--------------------------------------------------------
--  DDL for Package CSD_REPAIR_MANAGER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_MANAGER_UTIL" AUTHID CURRENT_USER as
/* $Header: csdurpms.pls 120.0.12010000.6 2009/09/16 15:34:40 subhat noship $ */
-- Start of Comments
-- Package name     : CSD_REPAIR_MANAGER_UTIL
-- Purpose          : This package will be used as utility package for repair manager portal
--
--
-- History          : 15/07/2009, Created by Sudheer Bhat
-- History          :
-- History          :
-- NOTE             :
-- End of Comments

g_pkg_name constant varchar2(30) := 'CSD_REPAIR_MANAGER_UTIL';

TYPE sr_rec_type is record (
	sr_account_id number,
	sr_party_id number,
	sr_incident_id number,
	sr_incident_summary varchar2(80),
	sr_bill_to_site_use_id number,
	sr_ship_to_site_use_id number,
	sr_type_id number,
	sr_status_id number,
	sr_severity_id number,
	sr_urgency_id number,
	sr_owner_id number,
	create_sr_flag varchar2(1)
	);
type sr_tbl_type is table of sr_rec_type index by binary_integer;

/******************************************************************************/
/* Function Name: get_item_quality_threshold								  */
/* Description: Returns the applicable quality threshold thats set up.		  */
/* @param p_inventory_item_id												  */
/* @param p_organization_id 												  */
/******************************************************************************/
FUNCTION get_item_quality_threshold(p_inventory_item_id IN NUMBER,
				    				p_organization_id   IN NUMBER,
				    				p_item_revision     IN VARCHAR2) RETURN NUMBER;

/******************************************************************************/
/* Function Name: get_aging_threshold										  */
/* Description: Returns the applicable aging threshold thats set up.		  */
/* @param p_inventory_item_id												  */
/* @param p_organization_id 												  */
/******************************************************************************/
FUNCTION get_aging_threshold(p_organization_id IN NUMBER,
                             p_inventory_item_id IN NUMBER,
                             p_repair_type_id    IN NUMBER,
                             p_flow_status_id    IN NUMBER,
                             p_revision          IN VARCHAR2,
                             p_repair_line_id    IN NUMBER) RETURN NUMBER;

/******************************************************************************/
/* Procedure Name: mass_update_repair_orders								  */
/* Description: This procedure provides a utility to mass update the repair   */
/*              orders. The procedure treats each logical action as a seperate*/
/*				transaction.												  */
/******************************************************************************/
PROCEDURE mass_update_repair_orders(p_api_version     IN NUMBER DEFAULT 1.0,
                                    p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                    p_commit          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                    p_repair_line_ids IN JTF_NUMBER_TABLE,
                                    p_from_ro_status  IN JTF_NUMBER_TABLE,
                                    p_orig_ro_type_ids IN JTF_NUMBER_TABLE,
                                    p_ro_obj_ver_nos  IN JTF_NUMBER_TABLE,
                                    p_to_ro_status    IN NUMBER DEFAULT NULL,
                                    p_ro_type_id      IN NUMBER DEFAULT NULL,
                                    p_ro_owner_id     IN NUMBER DEFAULT NULL,
                                    p_ro_org_id       IN NUMBER DEFAULT NULL,
                                    p_ro_priority_id  IN NUMBER DEFAULT NULL,
                                    p_ro_escalation_code IN VARCHAR2 DEFAULT NULL,
                                    p_note_type       IN VARCHAR2 DEFAULT NULL,
                                    p_note_visibility IN VARCHAR2 DEFAULT NULL,
                                    p_attach_title    IN VARCHAR2 DEFAULT NULL,
                                    p_attach_descr	  IN VARCHAR2 DEFAULT NULL,
                                    p_attach_cat_id   IN NUMBER DEFAULT NULL,
                                    p_attach_type     IN VARCHAR2 DEFAULT NULL,
                                    p_attach_file     IN BLOB DEFAULT NULL,
                                    p_attach_url      IN VARCHAR2 DEFAULT NULL,
                                    p_attach_text     IN VARCHAR2 DEFAULT NULL,
                                    p_file_name       IN VARCHAR2 DEFAULT NULL,
                                    p_content_type    IN VARCHAR2 DEFAULT NULL,
                                    p_note_text       IN VARCHAR2 DEFAULT NULL,
                                    x_return_status   OUT NOCOPY VARCHAR2,
									x_msg_count       OUT NOCOPY NUMBER,
                                    x_msg_data        OUT NOCOPY VARCHAR2,
                                    l_error_messages_tbl OUT NOCOPY JTF_VARCHAR2_TABLE_1000,
                                    p_ro_promise_date    IN DATE DEFAULT NULL
                                   );
/******************************************************************************/
/* Procedure Name: mass_create_attachments 									  */
/* Description:	The api provides utility to create attachments for a set of   */
/*				repair orders. The API gets called from mass_update_repair_orders */
/******************************************************************************/

 PROCEDURE mass_create_attachments(p_api_version IN NUMBER DEFAULT 1.0,
 								   p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                   p_commit          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                   p_repair_line_ids IN JTF_NUMBER_TABLE,
                                   p_attach_type     IN VARCHAR2,
                                   p_attach_cat_id   IN NUMBER,
                                   p_attach_descr    IN VARCHAR2 DEFAULT NULL,
                                   p_attach_title    IN VARCHAR2,
                                   p_file_input      IN BLOB DEFAULT NULL,
                                   p_url             IN VARCHAR2 DEFAULT NULL,
                                   p_text            IN VARCHAR2 DEFAULT NULL,
                                   p_file_name       IN VARCHAR2 DEFAULT NULL,
                                   p_content_type    IN VARCHAR2 DEFAULT NULL,
                                   x_return_status   OUT NOCOPY VARCHAR2,
                                   x_msg_count       OUT NOCOPY NUMBER,
                                   x_msg_data        OUT NOCOPY VARCHAR2
                                  );
/******************************************************************************/
/* Procedure Name: mass_create_repair_orders								  */
/* Description: This is a OAF wrapper for creation of SR and repair orders.   */
/*              OAF can call this with multiple records too.			      */
/******************************************************************************/

PROCEDURE mass_create_repair_orders(p_api_version       IN NUMBER DEFAULT 1.0,
									p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
									p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
									p_item_ids          IN JTF_NUMBER_TABLE,
									p_serial_numbers    IN JTF_VARCHAR2_TABLE_100,
									p_quantity          IN JTF_NUMBER_TABLE,
									p_uom_code          IN JTF_VARCHAR2_TABLE_100,
									p_external_ref      IN JTF_VARCHAR2_TABLE_100,
									p_lot_nums          IN JTF_VARCHAR2_TABLE_100,
									p_item_revisions    IN JTF_VARCHAR2_TABLE_100,
									p_repair_type_ids   IN JTF_NUMBER_TABLE,
									p_instance_ids      IN JTF_NUMBER_TABLE,
									p_serial_ctrl_flag  IN JTF_NUMBER_TABLE,
									p_rev_ctrl_flag     IN JTF_NUMBER_TABLE,
									p_ib_ctrl_flag      IN JTF_VARCHAR2_TABLE_100,
									p_party_id          IN NUMBER,
									p_account_id        IN NUMBER,
									x_return_status     OUT NOCOPY VARCHAR2,
									x_msg_count         OUT NOCOPY NUMBER,
									x_msg_data          OUT NOCOPY VARCHAR2,
									x_incident_id       OUT NOCOPY NUMBER);
/******************************************************************************/
/* Procedure Name: mass_create_repair_orders_cp								  */
/* Description: The concurrent wrapper to process the records from 			  */
/*     csd_repairs_interface table. The API does minimal validation and then  */
/*	   calls create_sr_repair_order in a loop.								  */
/******************************************************************************/
procedure mass_create_repair_orders_cp(errbuf out nocopy varchar2,
									   retcode out nocopy varchar2,
									   p_one_sr_per_group in varchar2 default 'Y',
									   p_group_id in number
									   );
/******************************************************************************/
/* Procedure Name: create_sr_repair_order									  */
/* Description: Creates a service request, and repair order. The API delegates*/
/*     the call to private API's for creation of these entities. Upon creating*/
/*     repair orders, the API will also enter default logistics line.         */
/******************************************************************************/
procedure create_sr_repair_order(p_api_version    IN NUMBER,
								 p_init_msg_list  in varchar2 default fnd_api.g_false,
								 p_commit         in varchar2 default fnd_api.g_false,
								 p_sr_rec         in sr_rec_type,
								 p_repln_rec	  in OUT NOCOPY csd_repairs_pub.repln_rec_type,
								 p_rev_ctrl_flag  in number,
								 p_serial_ctrl_flag in number,
								 p_ib_ctrl_flag   in varchar2,
								 x_incident_id    IN OUT NOCOPY number,
								 x_repair_line_id out nocopy number,
								 x_return_status  out nocopy varchar2,
								 x_msg_count      out nocopy number,
								 x_msg_data       out nocopy varchar2,
								 p_external_reference in varchar2 default null,
								 p_lot_num            in varchar2 default null
								 );
procedure update_external_reference
							 (p_external_reference in varchar2,
  							  p_instance_id              in number,
  							  x_return_status      		 OUT NOCOPY varchar2,
  							  x_msg_count          		 OUT NOCOPY number,
  							  x_msg_data           		 OUT NOCOPY varchar2);


END CSD_REPAIR_MANAGER_UTIL;

/
