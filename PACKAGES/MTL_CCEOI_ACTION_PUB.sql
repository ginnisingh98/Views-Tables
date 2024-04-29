--------------------------------------------------------
--  DDL for Package MTL_CCEOI_ACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CCEOI_ACTION_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPCCAS.pls 120.0 2005/05/25 06:00:00 appldev noship $ */
/*#
 * The Cycle Count Interface procedures allow users to perform online processing to the Cycle Count
 * Interface records and let the user import the records from the Cycle Count Open Interface
 * table.
 * @rep:scope public
 * @rep:product INV
 * @rep:lifecycle active
 * @rep:displayname Cycle Count Interface API
 * @rep:category BUSINESS_ENTITY INV_COUNT
 */

  -- Online processing for one record
/*#
 * This procedure allows users to perform online processing to the Cycle Count Interface records
 * and lets the user import the records from the Cycle Count Open Interface table. The procedure will
 * process those interface records that have the process flag set to ready for processing and will first validate
 * all such interface rows before importing the record.
 *
 * @param x_return_status return Variable holding the status of the procedure call
 * @param x_msg_count return Variable holding the number of error messages returned
 * @param x_msg_data return Variable holding the error message
 * @param x_errorcode return Variable that holds the error code. This code holds the reason why record was not imported.
 * @param x_interface_id  return This variable holds Interface Id of record processed
 * @param p_api_version Current API version number
 * @param p_init_msg_list The value of this variable decides whether to initialize the message list.
 * @param p_commit The value of this parameter is checked to call commit.
 * @param p_validation_level the value of this parameter decides the level of validation to be done on Interface records.
 * @param p_interface_rec This will hold the complete interface record.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Cycle Count Entries
*/
  PROCEDURE Import_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  X_return_status OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT  NOCOPY VARCHAR2 ,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE,
  x_interface_id OUT NOCOPY NUMBER );

  -- Start OF comments
  -- API name  : Import_CountRequest
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- FUNCTION  : Performs a specified type of processing on an interface record
  --
  -- Parameters:
  --     IN    : p_api_version      IN  NUMBER (required)
  --                API Version of this procedure
  --             p_init_msg_level   IN  VARCHAR2 (optional)
  --                           DEFAULT = FND_API.G_FALSE,
  --             p_commit           IN  VARCHAR2 (optional)
  --                           DEFAULT = FND_API.G_FALSE,
  --             p_validation_level IN  NUMBER (optional)
  --                           DEFAULT = FND_API.G_VALID_LEVEL_FULL
  --                           (not used at present time)
  --             p_interface_rec    IN  CCEOI_Rec_Type (required)
  --                complete interface RECORD
  --           See description below for instructions on setting this parameter
  --
  --     OUT:    x_msg_count        OUT NUMBER,
  --                   number of messages in the message list
  --             x_msg_data         OUT VARCHAR2,
  --                    if number of messages is 1, then this parameter
--                    contains the message itself
--
--               x_interface_id OUT NUMBER
--                     returns interface id of record processed
--
  --             X_return_status    OUT NUMBER
  --                Result of all the operations
  --                   FND_API.G_RET_STS_SUCCESS if success
  --                   FND_API.G_RET_STS_ERROR if error
  --		       FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
  --
--             X_ErrorCode        OUT NUMBER

--                RETURN value OF the x_errorcode
--                check only if x_return_status <> fnd_api.g_ret_sts_success
--
--                These errors are unrecoverable and interface record was not
--                inserted as a result of this thing
--          200 - Interface row is locked by someone else
--          201 - Interface row is trying to process cycle count entry that
--                has been exported to some other interface record
--          202 - Interface record is trying to process cycle count entry
--                of not open status
--          203 - field cycle_count_entry_id inside interface record points to
--                non exising cycle count entry
--          204 - Interface row has already been marked for deletion, therefore
--                no more processing should be done
--          205 - passed interface record id points to non-existing
--                record in the table
--          206 - Interface record has already been processed, and no
--                additional processing should be done
--          207 - Interface record is marked as not ready
--          -1  - unexpected error - all operations have been rollbacked
--
  --
  -- Version: Current Version 0.9
  --              Changed
  -- Previous Version Y.X
  --          Initial version 0.9
  -- Notes  :
  /*
  Description:

  This API is designed to automate manual processing of count entries
  info previously done through cycle count count forms.
  Its functionality is almost equivalent to that of forms with few
  exceptions which are listed in "Processing" section of this document.

  It is possible to process existing cycle count requests, create and/or
  process new unscheduled cycle count entries, validate data in interface,
  and, finally, simulate processing of a count request (no tables will be
  affected except for cycle count open interface tables)


  This procedure takes an interface row passed through
  p_interface_rec parameter and processes it, based on values of
  the parameter's fields.
  p_interface_rec is of type MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE that is
  composed of the fields corresponding to columns of
  MTL_CC_ENTRIES_INTERFACE table.

  Processing starts from inserting/updating p_interface_rec into the
  interface table, locking it, and for processing scheduled requests
  exporting corresponding cycle count entry.

  If this operation fails then interface record is not
  inserted/updated into a the inteface table and error code is returned.
  It could fail for few main reasons:
  1) interface record is locked => someone else is processing that same
  interface record
  2) Corresponding cycle count entry is not an open request/does not exist
  3) Trying to re-process processed interface record
  4) some non-null columns are missing (e.g. organization_id) and, therefore,
     interface record cannot be inserted

  -------------------------------------------------------------------------
  Use of fields of p_interface_rec:

  CC_ENTRY_INTERFACE_ID is a primary key of the cc entries interface table
  if it is filled out then we base processing on this record in the interface.
  we will check whether it points to a valid id, and if not error will be
  reported.
  if cc_entry_intreface_id is left blank then a new interface record
  will be created unless there is a an unprocessed interface record inside
  the cc interface that corresponds to the same count request, in which
  case we find and use interface id of that already exising record and try
  to finish processing it.

  ORGANIZATION_ID always has to be filled out

  Two controlling fields are PROCESS_MODE, and ACTION_CODE.
  PROCESS_MODE defines whether a record should be processed in online mode
  (process_mode = 1), or in background_mode (process_mode = 3).

  The procedure operates in any mode, but concurrent import program
  will only pickup record marked for background mode.
  Background mode processing is done using concurrent programs accessible
  through INVCCEOI form. The concurrent programs call onto the same base code
  as Open Interface public API, and have the same functionality.

  ACTION_CODE determines type of processing that is going to be done

  11 = G_VALIDATE - will check validity of data in the record
	The validation functionality will also be invoked from
        G_PROCESS, G_CREATE, and G_VALSIM. The validation consists of five
        major parts:
	1) validating cycle count header
        2) validating count list sequence
	3) validating SKU info
        4) validating UOM and quantity,
	5) validating count date and counter info.

        If validation is called directly or invoked as part of G_CREATE then
        only first 3 parts of validation will be executed
        (only fields of p_interface_rec that need to be filled out are
        the fields mentioned below in steps 1-3)
        If action_code was G_PROCESS or G_VALSIM then all 5 validation steps
        will be done (all mentioned fields need to be filled out).

        if cycle_count_entry_id is not null and points to a open and unexported
        cycle count entry then fields mentioned in steps 1 - 3 will be
        derived from that entry (their passed values will be ignored), if it
        contains invalid data then an error will be thrown and interface
        record will not be inserted/updated into interface

        1) Validate Cycle Count Header:
           either Cycle_Count_Header_id or Cycle_Count_Header_Name should
           correspond to an existing cycle count

        2) Validate Count List Sequence:
           Count_List_Sequence should be either:
             a) existing list sequence within the cycle count for open request

	     b) non existing count list sequence id

	     c) null
	        in which case a new count list sequence will be automatically
	        generated for it

           In case of a) Item and SKU info will be derived automatically from
           MTL_CYCLE_COUNT_ENTRIES, and, therefore, item and sku fields do not
           have to be filled out. Their values  will be ignored and
           overwritten by data drawn from the cycle count entries table.

           In case of b) and c) step 3 will have to be performed


        3) Validate Item and SKU info:
          for that the following fields need to be filled out:
	     a) Inventory_Item_Id and/or Item_Segment1..Item_Segment20
             b) Subinventory
             c) Revision
             d) Lot_Number
             e) Serial_Number
	     f) Locator_Id and/or Locator_Segment1..Locator_Segment20

          note: id parameter always takes precedence over values specified
                in segments

        The following checks will be run only if the validation is called
        with processing option (if called through G_PROCESS, or G_VALSIM)

        4) Validate UOM and quantity
	   the following fields need to be filled out:
	     a) Primary_Uom_Quantity and/or
	        ((Count_Uom and/or Count_Unit_Of_Measure) and Count_quantity)

	  note: specified primary_uom_quantity takes precedence over specified
		count_uom and count quantity

	     b) System_Quantity may also be filled out (if left null,
                it will be computed automatically).
                Warning: providing system quantity in count UOM will make
                the program run slightly faster, but it will also mean that
                the program will not compute the actual system quantity and
                thus may create incorrect adjustments if user did not enter
                system quantity correctly. If this field is left blank then
                system quantity at the time of processing will be computed.

        5) Validate count date and counter info
	   the following fields are to be filled out:
	     a) Count_Date
	     b) Employee_Id and/or
                Employee_Full_Name which can be either the full name or
		just the last name

		employee_id takes precedence over employee name

   12 = G_CREATE - will create corresponding cycle count entry request in
        MTL_CYCLE_COUNT_ENTRIES. It can be called directly, or it may
	be automatically invoked from G_PROCESS, or G_VALSIM if processing of
	the record requires creating a new count request.
	At first, it will try to validate data (first 3 steps), and
	then try to create a corresponding count request. See G_VALIDATE
        for p_interface_rec fields to be filled out

   13 = G_VALSIM - will simulate full validation and processing of
	an interface record. This mode is equivalent to the process mode
        with exception that no modifications will be made to tables other
        than interface tables.

   14 = G_PROCESS - will validate and process the interface record.
                    If corresponding count request does not exist
                    in MTL_CYCLE_COUNT_ENTRIES then it will be
                    created, and then processed


Brief description of other fields:

project_id              - project id
task_id                 - task id


fields whose value should not be modified (API ignores supplied values):

process_flag - indicates to interface whether a record is ready for
		processing
		1, NULL - ready
		2 - not ready
  it is useful for marking records as unavailable  in which case
  those interface entries will not be picked up by a call to concurrent
  request to process some or all interface records. The flag is manipulated
  through Inquire/Update CC Interface Entries Form.

error_flag - indicates whether an error has occured during processing
		1 - error
		2 - no error

status_flag - indicates processing status of the record
		0 - process completed
		1 - processed with warnings
		2 - processed with errors
		3 - marked for recounting
		4 - marked for reprocessing
		5 - validated
		6 - processing simulated
              NULL - no status
public api will only process interface records whose status is NULL or 3,4
  other statuses mean that the record is already processed

valid_flag - indicates whether data inside the interface record is valid
		1 - valid
		2, NULL - invalid (invalid could is set for new data or
                          data that errored out

lock_flag -  indicates whether record is locked by a process for processing
  1 - locked
  2, NULL - not locked

cc_entry_interface_group_id - used by concurrent manager to divide processing
				to different workers

program_application_id  - program application id
program_id              - program id
program_update_date     - program update date

last_update_date  - standard who column
last_updated_by   - standard who column
creation_date     - standard who column
created_by        - standard who column
last_update_login - standard who column
-------------------------------------------------------------------------
Processing notes:
        Do not populate interface manually, the only means of populating it
        should be either through this API or using CC Export form.

	If during processing we adjustment of system quantitities has to
	be made then transaction is entered into
	mtl_material_transactions_temp from where it will be picked up
	by concurrent manager (it is not immediate).

	Serial numbers are only partially validated during validation since
	for complete validation of serial number we need to know whether it
	is going to be issued, received, or kept where it is now. The only
	problems that we are able to catch during initial validation of
	serial number are issues related to ability to create this serial
	number. Other issues can be caught only during processing.

	If processing serial number requires transferring it from one location
	to another then CC Open Interface will not be able to resolve that
	and processing cycle count entry we will have to be completed manually
	through the cycle count approval form (INVAMCAP).

	Unscheduled entries will be created in mtl_cycle_count_entries and
	marked as exported.

-------------------------------------------------------------------------
Post Processing:

  After completion of processing error, delete, status and valid flags
  will be set to values that correspond their state after
  successful or unsuccessful processing(1 = TRUE, 2 or NULL = FALSE).
  The interface record will also be unlocked.

  In case of successful processing the corresponding cycle count entry
  will be unexported.

  If procedure does not complete successfuly, then the corresponding errors
  are saved in the interface's errors table, and if a corresponding
  cycle count entry was exported then it will remain exported.

  If record was inserted updated (error code returned was not above 199)
  then it's cc_entry_interface_id will be contained in x_interface_id.
  It is useful for reprocessing of the record if it errored out and user
  does not wish to create a whole new interface record with fixed data.

  Interface records that are successfully processed are marked processed
  or processed with warnings
  and may later be removed using Purge CC Interface concurrent program.

----------------------------------------------------------------------------
     Example of usage:

     create a new  interface record INV_CCEOI_TYPE following the above
     mentioned rules or retrieve data into interface record from the
     the interface table (the table can be populated it by running
     Inventory's export). Set process_mode, action_code, and any other
     fields necessary. Call the procedure. Check for errors upon return.

Example:
Process an unscheduled count request for item SC55437, counted by Mr. Hat
in the Stores subinventory for organization 207. Counting revealed that there
were 100000 pieces of SC55437, and it was done on December 23, 1998.

declare
lstatus VARCHAR2(1);
lmsg_count NUMBER;
lmsg_data VARCHAR2(240);
lrec mtl_cceoi_var_pvt.inv_cceoi_type;
l_errorcode number;
l_interface_id number;

begin

-- set online processing mode
  lrec.PROCESS_MODE := 1;

-- import request into the application and do any adjustments necessary
  lrec.ACTION_CODE := mtl_cceoi_var_pvt.G_PROCESS;

-- necessary info

-- 1) cycle count header info
  lrec.cycle_count_header_name := 'MCCOI';

-- 2) count list sequence of the enrty (null = don't know/unscheduled)
  lrec.count_list_sequence := null;


-- 3) item and sku info

--  lrec.item_segment1 :=;
  lrec.inventory_item_id = 151;

  lrec.subinventory := 'Engineer';
  lrec.revision := null;
  lrec.lot_number := null;
  lrec.serial_number := null;
  lrec.locator_id := null;

  lrec.organization_id := 207;


-- 4) validate and UOM qunatity
  lrec.count_uom := 'Ea';
  lrec.count_quantity  := 100000;

-- 5) Date and Counter info
  lrec.count_date := to_date('23-DEC-1998', 'DD-MON-YYYY');
  lrec.employee_full_name := 'Hat, Mr.';

-- this record is not in the interface
  lrec.cc_entry_interface_id := null;


-- call API
  mtl_cceoi_action_pub.import_CountRequest(
				p_api_version => 0.9,
				p_commit => FND_API.G_TRUE,
				x_return_status => lstatus,
                                x_errorcode => l_errorcode
				x_msg_count => lmsg_count,
				x_msg_data => lmsg_data,
				p_interface_rec => lrec,
                                x_interface_id => l_interface_id);

  if (lstatus = fnd_api.g_ret_sts_success) then
	....
  else
	....
  end if;


end;
*/
  -- END OF comments

/*All parameters are same as Import_CountRequest, with the exception of the out
variable. In this case the procedure will returns a list of interface ids.  The
procedure acts as a wrapper for Import_CountRequest.  In case where an lpn or
lpn id is specified in the interface record, Process_LPN_CountRequest will run
and Import_countrequest for each item within that lpn, returning the interface ids
given by Import_CountRequests in the out parameter list.
*/
--
PROCEDURE Process_LPN_CountRequest
(
   	p_api_version 		IN 	NUMBER
,  	p_init_msg_list 	IN 	VARCHAR2 DEFAULT FND_API.G_FALSE
,  	p_commit 		IN 	VARCHAR2 DEFAULT FND_API.G_FALSE
,  	p_validation_level 	IN 	NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
,  	x_return_status 	OUT NOCOPY	VARCHAR2
,  	x_errorcode 		OUT NOCOPY	NUMBER
,  	x_msg_count 		OUT NOCOPY	NUMBER
,  	x_msg_data 		OUT 	 NOCOPY VARCHAR2
,  	p_interface_rec 	IN 	MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE
,  	x_interface_id_list 	OUT 	NOCOPY MTL_CCEOI_VAR_PVT.INV_CCEOI_ID_TABLE_TYPE
);

END MTL_CCEOI_ACTION_PUB;

 

/
