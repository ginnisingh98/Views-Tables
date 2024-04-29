--------------------------------------------------------
--  DDL for Package WMS_RFID_DEVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RFID_DEVICE_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSRFIDS.pls 120.4 2006/07/06 19:24:18 satkumar ship $ */
/*#
  * This object processes EPC/LPN data read through RFID or barcode reader.
  * @rep:scope public
  * @rep:product WMS
  * @rep:lifecycle active
  * @rep:displayname RFID/barcode read processing APIs for WMS
  * @rep:category BUSINESS_ENTITY WMS_RFID_DEVICE
  */


TYPE t_genref IS REF CURSOR;

TYPE tag_info IS RECORD
    (
     tag_id VARCHAR2(260) --WILL HOLD THE EPC CODE
     ,tag_data VARCHAR2(130)
     ,lpn_id NUMBER
     ,parent_lpn_id NUMBER
     ,item_id NUMBER
     ,serial_number VARCHAR2(30) --MSN has it as varchar2
     ,gtin NUMBER
     ,gtin_serial NUMBER
     );

TYPE tag_info_tbl IS TABLE OF tag_info INDEX BY BINARY_INTEGER;


/*#
*
  * This API will process the RFID or barcode scan read data (p_tagid) and
  * perform the transactions after identifying what to do with the read data.
  * Only LPN_Id will be read by the hardware and process_rfid_txn() API
  * will perform the appropriate transaction. Set up defined in the 'Define
  * Device' and 'Assign Device' forms of Oracle Warehouse Management are used to
  * identify the valid transactions to process.
  *
  * Processed records will be stored in the XML file (depending on the set up of
  * the 'Define Device' form and WMS_DEVICE_REQUESTS_HIST table). If the system
  * is unable to determine what to do with the read tag value then the XML is
  * generated but no transaction processing will occur.
  * If the processing fails or succeeds after determining the business
  * event, a record is stored in both XML and WMS_DEVICE_REQUESTS_HIST
  * table. Details of WMS_DEVICE_REQUESTS_HIST table can be viewed through
  * 'Device Requests History' form.
  *
  * (This API will be called mainly by the Oracle Edge Server and it acts as an
  * interface between Oracle Edge Server and Oracle Warehouse Management for
  * RFID transactions.)
  *
  * The following parameters are included but are not currently used.
  * p_system_id     : System identifier with seperate physical locations. It
  * will be used mainly for physical location of org. To avoid the case in which same device
  * name exists in two different organizations, we suggest that p_system_id
  * should be passed as organization_id (based on physical location) so that
  * we can uniquely identify which device is referred.
  * p_statuschange : Boolean indicating change of data on the tag
  * p_datachange:
  * p_status    : indicates whether the reader is active
  * p_x         : x location of the tag
  * p_y         : y location of the tag
  * x_return_value : success/error/warning
  * x_return_mesg  : message to be displayed on the message board of response device
  * @ param p_tagid Written EPC/LPN values on RFID tag
  * @ paraminfo {@rep:required}
  * @ param p_tagdata Extra data on the tag, Not used Currently
  * @ paraminfo {@rep:required}
  * @ param p_portalid  Reader Name fomr the 'Define Device Form' in WMS
  * @ paraminfo {@rep:required}
  * @ param p_event_date read time of RFID tag
  * @ paraminfo {@rep:required}
  * @ param p_system_id NOT used currently in WMS,System identifier with seperate physical locations. It will be used mainly for physical location of org. To avoid the case in which same device name exists in two different organizations
  * @ paraminfo {@rep:optional}
  * @ param p_statuschange NOT used currently,Boolean indicating change of data on the tag
  * @ paraminfo {@rep:optional}
  * @ param p_datachange NOT used currently,whether data on tag changed
  * @ paraminfo {@rep:optional}
  * @ param p_status NOT used currently,indicates whether the reader is active
  * @ paraminfo {@rep:optional}
  * @ param p_x x location of the tag
  * @ paraminfo {@rep:optional}
  * @ param p_y y location of the tag
  * @ paraminfo {@rep:optional}
  * @ param x_return_value success/error/warning
  * @ paraminfo {@rep:required}
  * @ param x_return_mesg message to be displayed on the message board of response device
  * @ paraminfo {@rep:required}
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname API to process RFID enabled WMS transactions
  * @rep:businessevent process_rfid_txn
  */
procedure process_rfid_txn
  (
   p_tagid           in      WMS_EPC_TAGID_TYPE,  -- EPC TAGS ID VALUE, IN VARRAY
   p_tagdata         IN      WMS_EPC_TAGDATA_TYPE,-- ANY ADDITIONAL DATA IN TAG AS VARRAY
   p_portalid        in      varchar2,--reader name
   p_event_date      in      date,
   p_system_id       in      VARCHAR2 DEFAULT null,
   p_statuschange    in      NUMBER DEFAULT null,
   p_datachange      in      NUMBER DEFAULT null,
   p_status          in      NUMBER DEFAULT null,
   p_x               in      NUMBER DEFAULT null,
   p_y               in      NUMBER DEFAULT NULL,
   x_return_value    out     nocopy VARCHAR2,  --success,error,warning
   x_return_mesg     OUT     nocopy varchar2);

/*
 API is below is same as above  process_rfid_txn() ecept that it will
   return the request_id for device transaction as well. Internally it does
   call above process_rfid_txn
   */

     /*#
   *
   * This API is the same as other process_rfid_txn() API except that it
   * will return the request_id for device transaction as well. Internally it
   * will call process_rfid_txn.
   * @ param p_tagid Written EPC/LPN values on RFID tag
   * @ paraminfo {@rep:required}
   * @ param p_tagdata Extra data on the tag, Not used Currently
   * @ paraminfo {@rep:required}
   * @ param p_portalid  Reader Name fomr the 'Define Device Form' in WMS
   * @ paraminfo {@rep:required}
   * @ param p_event_date read time of RFID tag
   * @ paraminfo {@rep:required}
   * @ param p_system_id NOT used currently in WMS, System identifier with separate physical locations. It will be used mainly for physical location of org. To avoid the case in which same device name exists in two different organizations
   * @ paraminfo {@rep:optional}
   * @ param p_statuschange NOT used currently,Boolean indicating change of data on the tag
   * @ paraminfo {@rep:optional}
   * @ param p_datachange NOT used currently,whether data on tag changed
   * @ paraminfo {@rep:optional}
   * @ param p_status NOT used currently,indicates whether the reader is active
   * @ paraminfo {@rep:optional}
   * @ param p_x x location of the tag
   * @ paraminfo {@rep:optional}
   * @ param p_y y location of the tag
   * @ paraminfo {@rep:optional}
   * @ param x_return_value success/error/warning
   * @ paraminfo {@rep:required}
   * @ param x_return_mesg message to be displayed on the message board of response device
   * @ paraminfo {@rep:required}
   * @ param x_request_id processed request_id
   * @ paraminfo {@rep:required}
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:displayname API to process RFID enabled WMS transactions
   * @rep:businessevent process_rfid_txn
  */
   procedure process_rfid_txn
  (
   p_tagid           in      WMS_EPC_TAGID_TYPE,  -- EPC TAGS ID VALUE, IN VARRAY
   p_tagdata         IN      WMS_EPC_TAGDATA_TYPE,-- ANY ADDITIONAL DATA IN TAG AS VARRAY
   p_portalid        in      VARCHAR2,--number as varchar2
   p_event_date      in      DATE,
   p_system_id       in      VARCHAR2 DEFAULT null,
   p_statuschange    in      NUMBER DEFAULT null,
   p_datachange      in      NUMBER DEFAULT null,
   p_status          in      NUMBER DEFAULT null,
   p_x               in      NUMBER DEFAULT null,
   p_y               in      NUMBER DEFAULT NULL,
   x_return_value    out     nocopy VARCHAR2,  --success,error,warning
   x_return_mesg     OUT     nocopy VARCHAR2,
   x_request_id      OUT     nocopy NUMBER
   );



  /*#
  *
  * This API, if registred with the Oracle Edge Server, will return a
  * status that will indicate that the RFID tag has been read. This API should
  * have a higher priority in the registered callback table so that it can get
  * called before the transaction processing starts.
  *
  * Example set up:
  * API                        priority
  * process_wmsc_epc_rfid_txn  10
  * WMS_READ_EVENT            20
  *
  * Procedure WMS_READ_EVENT should get called first for each read.
  *
  * @ param p_tagid Written EPC/LPN values on RFID tag
  * @ paraminfo {@rep:required}
  * @ param p_tagdata Extra data on the tag, Not used Currently
  * @ paraminfo {@rep:required}
  * @ param p_portalid  Reader Name fomr the 'Define Device Form' in WMS
  * @ paraminfo {@rep:required}
  * @ param p_event_date read time of RFID tag
  * @ paraminfo {@rep:required}
  * @ param p_system_id NOT used currently in WMS,System identifier with seperate physical locations. It will be used mainly for physical location of org. To avoid the case in which same device name exists in two different organizations
  * @ paraminfo {@rep:optional}
  * @ param p_statuschange NOT used currently,Boolean indicating change of data on the tag
  * @ paraminfo {@rep:optional}
  * @ param p_datachange NOT used currently,whether data on tag changed
  * @ paraminfo {@rep:optional}
  * @ param p_status NOT used currently,indicates whether the reader is active
  * @ paraminfo {@rep:optional}
  * @ param p_x x location of the tag
  * @ paraminfo {@rep:optional}
  * @ param p_y y location of the tag
  * @ paraminfo {@rep:optional}
  * @ param x_return_value success/error/warning
  * @ paraminfo {@rep:required}
  * @ param x_return_mesg message to be displayed on the message board of response device
  * @ paraminfo {@rep:required}
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname API to process RFID enabled WMS transactions
  * @rep:businessevent WMS_READ_EVENT
    */
  Procedure WMS_READ_EVENT
  (
   p_tagid           in      WMS_EPC_TAGID_TYPE,  -- EPC TAGS ID VALUE, IN VARRAY
   p_tagdata         IN      WMS_EPC_TAGDATA_TYPE,-- ANY ADDITIONAL DATA IN TAG AS VARRAY
   p_portalid        in      VARCHAR2,
   p_event_date      in      date,
   p_system_id       in      VARCHAR2 DEFAULT null,
   p_statuschange    in      NUMBER DEFAULT null,
   p_datachange      in      NUMBER DEFAULT null,
   p_status          in      NUMBER DEFAULT null,
   p_x               in      NUMBER DEFAULT null,
   p_y               in      NUMBER DEFAULT null,
   x_return_value    out     nocopy VARCHAR2,  --success,error,warning
   x_return_mesg     out     nocopy varchar2
   )  ;

  --Internal Wrapper API for testing purpose only using Mobile
  --Not to be touched by customer
procedure MobTest_process_rfid_txn
  (
   p_tagid           in      clob, -- EPC tag ID
   p_tagdata         IN      clob, -- Any additional value with EPC tag
   p_portalid        in      varchar2,--reader name
   p_event_date      in      date,
   p_system_id       in      VARCHAR2 DEFAULT null,
   p_statuschange    in      NUMBER DEFAULT null,
   p_datachange      in      NUMBER DEFAULT null,
   p_status          in      NUMBER DEFAULT null,
   p_x               in      NUMBER DEFAULT null,
   p_y               in      NUMBER DEFAULT NULL,
   x_return_value    out     nocopy VARCHAR2,  --success,error,warning
   x_return_mesg     OUT     nocopy varchar2);

END WMS_RFID_DEVICE_PUB;

 

/
