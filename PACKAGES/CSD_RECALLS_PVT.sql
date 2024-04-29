--------------------------------------------------------
--  DDL for Package CSD_RECALLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RECALLS_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvrcls.pls 120.0.12010000.2 2010/06/23 11:39:50 subhat noship $ */
-- Start of Comments
-- Package name     : CSD_RECALLS_PVT
-- Purpose          : This package will contain all the procedure and functions used by the Recalls.
--		      Usage of this package is strictly confined to Oracle Depot Repair Development.
--
-- History          : 24/03/2010, Created by Sudheer Bhat
-- NOTE             :
-- End of Comments

g_pkg_name constant varchar2(30) := 'CSD_RECALLS_PVT';

-- Record to hold all the recall line attributes (saved attributes).

TYPE csd_recall_lines_rec IS RECORD (
			RECALL_LINE_ID 		NUMBER,
			INSTANCE_ID    		NUMBER,
			OWNER_ACCOUNT_ID 	NUMBER,
			OWNER_PARTY_ID   	NUMBER,
			INVENTORY_ITEM_ID   NUMBER,
			REVISION           	VARCHAR2(3),
			SERIAL_NUMBER		VARCHAR2(30),
			LOT_NUMBER			VARCHAR2(15),
			INCIDENT_ID         NUMBER,
			REPAIR_LINE_ID      NUMBER,
			WIP_ENTITY_ID		NUMBER,
			UOM_CODE			VARCHAR2(5),
			QUANTITY			NUMBER
			);

-- Table type of the above record.
TYPE csd_recall_lines_tbl IS TABLE OF csd_recall_lines_rec INDEX BY BINARY_INTEGER;

-- default primary ship to and bill to addresses.
TYPE csd_shipto_billto_rec IS RECORD (
			BILL_TO_SITE_USE_ID NUMBER,
			SHIP_TO_SITE_USE_ID NUMBER,
			CALLER_TYPE			VARCHAR2(30)
			);

TYPE csd_shipto_billto_tbl IS TABLE OF csd_shipto_billto_rec INDEX BY BINARY_INTEGER;

TYPE job_header_tbl IS TABLE OF wip_job_schedule_interface%ROWTYPE INDEX BY BINARY_INTEGER;

TYPE post_wipml_rec IS RECORD (
			REPAIR_LINE_ID 		NUMBER,
			WIP_ENTITY_ID  		NUMBER,
			ORGANIZATION_ID		NUMBER,
			QUANTITY			NUMBER,
			INVENTORY_ITEM_ID	NUMBER,
			RECALL_INVENTORY_ID NUMBER,
			SERIAL_NUMBER		VARCHAR2(30),
			UOM_CODE			VARCHAR2(3),
			JOB_NAME			VARCHAR2(240),
			SERVICE_CODE		VARCHAR2(80),
			SERVICE_CODE_ID		NUMBER,
			TRANSACTION_QTY		NUMBER
			);
TYPE post_wipml_tbl IS TABLE OF post_wipml_rec INDEX BY BINARY_INTEGER;

/****************************************************************************************/
/* Procedure Name: Generate_Recall_Work.                                                */
/* Description: Receives a set of recall lines for which the recall work needs to       */
/*		be generated along with SR, RO and WIP params if any. Prepares these    		*/
/*      recall lines for concurrent processing and launches the CP to create    		*/
/*      recall work.Returns the concurrent program Id to the caller if success  		*/
/*		else an appropriate error message is returned.                          		*/
/*-- History: 24/03/2010, Created by Sudheer Bhat.										*/
/****************************************************************************************/

PROCEDURE GENERATE_RECALL_WORK (p_api_version 			IN NUMBER,
								p_init_msg_list			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_recall_line_ids       IN JTF_NUMBER_TABLE,
								p_sr_type_id            IN NUMBER,
								p_ro_type_id            IN NUMBER DEFAULT NULL,
								p_service_code_id       IN NUMBER DEFAULT NULL,
								p_wip_accounting_class  IN VARCHAR2 DEFAULT NULL,
								p_upgrade_item_id       IN VARCHAR2 DEFAULT NULL,
								p_wip_inv_org_id        IN NUMBER DEFAULT NULL,
								p_recall_number         IN VARCHAR2,
								x_request_id            OUT NOCOPY NUMBER,
								x_msg_count             OUT NOCOPY NUMBER,
								x_msg_data              OUT NOCOPY VARCHAR2,
								x_return_status         OUT NOCOPY VARCHAR2);

/****************************************************************************************/
/* Procedure Name: process_recall_work.                                                 */
/* Description: This is the concurrent wrapper to process a set of recall lines.        */
/*		Generates SR, RO and WIP jobs based on the params being passed. Logs    		*/
/*		all the error messages to error log, and will generate a report of all  		*/
/*		all the successful recall lines. Updates the csd_recall_lines table     		*/
/*		with the SR id, RO line id and wip entity id when done with the         		*/
/*		processing. Once done, will reset the processing_flag to N						*/
/* -- History: 24/03/2010, Created by Sudheer Bhat.										*/
/****************************************************************************************/

PROCEDURE PROCESS_RECALL_WORK (errbuf 		   			OUT NOCOPY VARCHAR2,
                               retcode 		   			OUT NOCOPY VARCHAR2,
							   p_group_id	     		IN NUMBER,
							   p_sr_type_id        		IN NUMBER,
							   p_ro_type_id        		IN NUMBER DEFAULT NULL,
							   p_service_code_id   		IN NUMBER DEFAULT NULL,
							   p_wip_accounting_class	IN VARCHAR2 DEFAULT NULL,
							   p_upgrade_item_id        IN NUMBER,
							   p_wip_inv_org_id     	IN NUMBER );

/****************************************************************************************/
/* Procedure Name: refresh_recall_metrics												*/
/* Description: Refreshes the recall metrics for the recall number if passed, else      */
/* 				refreshes the metrics for all the open recalls. This program runs as    */
/*				concurrent program.													    */
/* -- History: 30/03/2010, Created by Sudheer Bhat.										*/
/****************************************************************************************/
PROCEDURE REFRESH_RECALL_METRICS(errbuf 		   			OUT NOCOPY VARCHAR2,
                               	 retcode 		   			OUT NOCOPY VARCHAR2,
                               	 p_recall_number			IN VARCHAR2 DEFAULT NULL );

END CSD_RECALLS_PVT;

/
