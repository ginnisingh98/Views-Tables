--------------------------------------------------------
--  DDL for Package WMS_DEVICE_CONFIRMATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_DEVICE_CONFIRMATION_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSDEVCS.pls 120.4.12010000.1 2008/07/28 18:33:14 appldev ship $ */
/*#
  * This procedure handles the response call for device confirmation
  *  functionality in WMS
  * @rep:scope public
  * @rep:product WMS
  * @rep:lifecycle active
  * @rep:displayname Device Confirmation for WMS
  * @rep:category BUSINESS_ENTITY WMS_DEVICE_CONFIRMATION_PUB
  */

    --Assumption :
    --1-This API will be called for single delivery_lines in a batch
    --2-Device-integration should be enabled at the time of pick-release and details
    --should be present in the device-history table before a transaction can be
    --transacted/confirmed by this API

    -- This is the API which need to be called for device confimation
    -- It takes all records from wms_device_requests (WDR) temporary table for device_confimation
    -- business_event_id = 54, 56 and device_status = 'S',process them and
    -- finally transfer them to wms_device_requests_hist (WDRH)table.
    -- If any records fails, it ransfers it to WDRH with STATUS_CODE = 'E' and
    -- appropriate error message and proceed to the next one
    -- If all suggested items are being picked, there is no need to pass
    -- the information about child records having lot information but if there
    -- IS quantity discrepancy and the user picks less than suggested, then all
    -- information about lot need TO be passed in child record.

    --What is supported:
    --1- Operations supported are 'load' TASK (ID= 56) OR load_and_drop (ID=54)
    --2- Plain item and Lot items are supported. Serial-controlled items not supported
    --3- Picking loose is supported into Xfer_lpn
    --4- Exact match of LPN containing normal items or Lot controlled item
    --5- If LPN other than allocated, it should be picked from the same locator.
    --6- No Lot Substitution is allowed at the time of pick-confirm
    --7- If one original allocation (MMTT) is being satisfied by material residing in
    --multiple LPNs, then the original allocation (MMTT) needs to be split and
    --quantity proportionately split across the new allocation lines corresponding to
    --the quantity present in the LPN before invoking this API. If the split lines are
    --not present at the time the API is called, then the remaining quantity will be
    --backordered.



    --fields that can be changed (other than suggested one):
    -- transaction_quantity, Xfer_sub, Xfer_loc, Xfer_lpn_id,REASON_ID (in case of discrepancy only)
    -- reason_id is used to fire appropriate work flow

    --MANDATORY FIELDS to be populated in WDR before calling this api:-
    --  RELATION_ID, TASK_ID, ORG_ID, BUSINESS_EVENT_ID,
    --  TASK_SUMMARY, DEVICE_STATUS,XFER_LPN_ID,
    --Input Parameters:
    --  None
    --Output Parameters:
    --  x_return_status : Status of the API
    --  x_msg_count     : message count
    --  x_msg_data      : Status message
    --  x_successful_row_cnt : # of successful rows after processing

    /*#
    *
    * This is the procedure should be called for device confirmation.
    * It takes all records from wms_device_requests (WDR) temporary table for
    * device_confimation
    * business_event_id = 54, 56 and device_status = 'S', processes them and
    * finally transfers them to the wms_device_requests_hist (WDRH)table.
    * If any records fail, it transfers them to WDRH with STATUS_CODE = 'E' and
    * populates the appropriate error message and proceeds to the next record
    * for processing.  If all suggested items are being picked, there is no need
    * to pass the information about child records having lot information but if
    * there is quantity discrepancy and the user picks less than suggested, then
    * all information about lot need TO be passed in child record.
    *
    * This procedure should be called for single delivery_lines in a batch.
    *
    * What is supported:
    * -1- Operations supported are 'load' TASK (ID= 56) OR load_and_drop (ID=54
    * -2- Plain item and Lot items are supported. Serial-controlled items not supported
    * -3- Picking loose is supported into Xfer_lpn
    * -4- Exact match of LPN containing normal items or Lot controlled item
    * -5- If LPN other than allocated, it should be picked from the same locator.
    * -6- No Lot Substitution is allowed at the time of pick-confirm
    * -7- If one original allocation (MMTT) is being satisfied by material residing in
    * multiple LPNs, then the original allocation (MMTT) needs to be split and
    * quantity proportionately split across the new allocation lines corresponding to
    * the quantity present in the LPN before invoking this API. If the split lines are
    * not present at the time the API is called, then the remaining quantity
    * will be backordered.
    *
    * Fields that can be changed (other than suggested one):
    * transaction_quantity, Xfer_sub, Xfer_loc, Xfer_lpn_id,REASON_ID (in case of discrepancies only)
    * reason_id is used to fire appropriate work flow
    *
    * MANDATORY FIELDS to be populated in WDR before calling this api:-
    * RELATION_ID, TASK_ID, ORG_ID, BUSINESS_EVENT_ID,
    * TASK_SUMMARY, DEVICE_STATUS,XFER_LPN_ID,
    *
    * @ param x_return_status Status of request. ( S = Success, E = Error)
    * @ paraminfo {@rep:required}
    * @ param x_msg_count message count
    * @ paraminfo {@rep:required}
    * @ param x_msg_data  Status message
    * @ paraminfo {@rep:required}
    * @ param p_request_id Request id for resubmitted records
    * @ paraminfo {@rep:required}
    * @ param  x_successful_row_cnt number of successful rows after processing
    * @ paraminfo {@rep:required}
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Processes requests from devices defined in WMS
    * @rep:businessevent device_confirmation
    */
PROCEDURE device_confirmation(
			      x_return_status OUT NOCOPY VARCHAR2
			      ,x_msg_count OUT NOCOPY NUMBER
			      ,x_msg_data  OUT NOCOPY VARCHAR2
			      ,p_request_id IN NUMBER DEFAULT NULL
			      ,x_successful_row_cnt OUT nocopy number
			      );


END WMS_DEVICE_CONFIRMATION_PUB;

/
