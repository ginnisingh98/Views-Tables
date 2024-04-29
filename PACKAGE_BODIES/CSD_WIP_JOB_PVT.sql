--------------------------------------------------------
--  DDL for Package Body CSD_WIP_JOB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_WIP_JOB_PVT" AS
/* $Header: csdvwjbb.pls 120.13.12010000.3 2010/04/13 17:44:27 nnadig ship $*/
-- Start of Comments
-- Package name     : CSD_WIP_JOB_PVT
-- Purpose          : This package submits and creates WIP jobs using WIP Mass Load.
--			    Submit_Jobs is the API which uses various helper procedures to
--                    Submit WIP Mass Load, waits for it to complete successfully, then
--                    calls WIP_UPDATE API to update CSD_REPAIR_JOB_XREF with the
--			    newly created wip_entitity_id values.
--			    Besides these procedure, this package has a helper function
--			    is_dmf_patchset_level_j which is used by the client application
--			    to check if the discrete manufacturing patchset level is at 'j' or
--			    beyond. Based on this, the client application decides how to call
--			    the WIP completion form.
--
-- History          : 08/20/2003, Created by Shiv Ragunathan
-- History          :
-- History          :
-- NOTE             :
-- End of Comments


-- Define Global Variable --
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSD_WIP_JOB_PVT';



-- This procedure accepts job header, bills and routing information and inserts it into
-- WIP_JOB_SCHEDULE_INTERFACE table. This procedure inserts one record at a time, hence
-- this procedure needs to be called in a loop for multiple jobs being submitted
-- to WIP Mass Load. If all the records need to be processed by a single WIP Mass Load
-- request, they should all be passed in the the same group_id.

PROCEDURE insert_job_header
(
    	p_job_header_rec	 IN  	JOB_HEADER_REC_TYPE,
    	p_job_bill_routing_rec   IN	JOB_BILL_ROUTING_REC_TYPE,
    	p_group_id 	         IN  	NUMBER,
        x_interface_id           OUT    NOCOPY  NUMBER,  -- nnadig: bug 9263438
    	x_return_status          OUT 	NOCOPY 	VARCHAR2
)
IS

    	-- Job Record to hold the Job header, bills and routing information being inserted
    	-- into wip_job_schedule_interface

	l_job_header_rec                wip_job_schedule_interface%ROWTYPE;


    	-- variables used for FND_LOG debug messages

    	l_debug_level                   NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    	l_proc_level                    NUMBER  := FND_LOG.LEVEL_PROCEDURE;
    	l_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_wip_job_pvt.insert_job_header.';


    	-- Constants Used for Inserting into wip_job_schedule_interface,
    	-- These are the values needed for WIP Mass Load to pick up the records

    	-- Indicates that the process Phase is Validation
    	l_validation_phase 			CONSTANT 	NUMBER := 2;

    	-- Indicates that the process_status is Pending
    	l_pending_status			CONSTANT	NUMBER := 1;

    	-- Source Code Value of 'Depot_Repair'
    	l_depot_repair_source_code	CONSTANT	VARCHAR2(30) := 	'DEPOT_REPAIR';

    	-- Depot repair Application Id passed as source_line_id
    	l_depot_app_source_line_id	CONSTANT	NUMBER := 512;

    	-- Non Standard Discrete Job Load Type
    	l_non_standard_load_type		CONSTANT	NUMBER := 4;

        l_default_ro_item               VARCHAR2(1);

BEGIN


    	IF ( l_proc_level >= l_debug_level ) then
        	FND_LOG.STRING( 	l_proc_level,
        				l_mod_name||'begin',
        				'Entering procedure insert_job_header' );
    	END IF;

    	x_return_status := FND_API.G_RET_STS_SUCCESS;


    	-- Populate the record l_job_header_rec


    	-- Populate the constant values

    	l_job_header_rec.process_phase := l_validation_phase;
    	l_job_header_rec.process_status := l_pending_status;
    	l_job_header_rec.source_code := l_depot_repair_source_code;
    	l_job_header_rec.source_line_id := l_depot_app_source_line_id ;
    	l_job_header_rec.load_type := l_non_standard_load_type;

	    l_job_header_rec.group_id := p_group_id;

        l_default_ro_item := nvl(FND_PROFILE.VALUE('CSD_DEFAULT_RO_ITEM_AS_MATERIAL_ON_JOB'), 'N');

        -- nnadig: bug 9263438 - Use wip_interface_s for interface_id, not sequence from group_id
        -- According to wip_job_schedule_interface documentation, interface ID should be NULL
        -- and will be populated by WIP later.  However, for defaulting material, CreateOneJob
        -- is used which requires an interface ID, so we will generate an interface ID for this
        -- case only and pass it back to the calling procedure to use.
        if (l_default_ro_item = 'Y') then
            -- l_job_header_rec.interface_id := p_group_id;
            SELECT wip_interface_s.NEXTVAL INTO x_interface_id FROM dual;
            l_job_header_rec.interface_id := x_interface_id;
        else
            l_job_header_rec.interface_id := NULL;
            x_interface_id := NULL;
        end if;
        -- end nnadig: bug 9263438



    	-- Populate the row who columns

    	l_job_header_rec.creation_date := SYSDATE;
    	l_job_header_rec.last_update_date := SYSDATE;
    	l_job_header_rec.created_by := fnd_global.user_id;
    	l_job_header_rec.last_updated_by := fnd_global.user_id;
    	l_job_header_rec.last_update_login := fnd_global.login_id;


    	l_job_header_rec.job_name := p_job_bill_routing_rec.job_name;
    	l_job_header_rec.organization_id := p_job_header_rec.organization_id;
    	l_job_header_rec.status_type := p_job_header_rec.status_type;
    	l_job_header_rec.first_unit_start_date := p_job_header_rec.scheduled_start_date;
    	l_job_header_rec.last_unit_completion_date := p_job_header_rec.scheduled_end_date;
    	l_job_header_rec.primary_item_id := p_job_header_rec.inventory_item_id;

	-- rfieldma, project integration
      l_job_header_rec.project_id := p_job_header_rec.project_id;
      l_job_header_rec.task_id := p_job_header_rec.task_id;
      l_job_header_rec.end_item_unit_number := p_job_header_rec.unit_number;


    	-- WIP Accounting Class code

    	l_job_header_rec.class_code := p_job_header_rec.class_code;
    	l_job_header_rec.start_quantity := p_job_header_rec.quantity;

     -- Fix for bug# 3109417
	-- If the profile CSD: Default WIP MRP Net Qty to Zero is set to
	-- null / 'N' then net_quantity = start_quantity else if the
	-- profile is set to 'Y' then net_quantity = 0
     IF ( nvl(fnd_profile.value('CSD_WIP_MRP_NET_QTY'),'N') = 'N' ) THEN
    	  l_job_header_rec.net_quantity := p_job_header_rec.quantity;
     ELSIF ( fnd_profile.value('CSD_WIP_MRP_NET_QTY') = 'Y' ) THEN
    	  l_job_header_rec.net_quantity := 0;
	END IF;


    	-- Bill and Routing information

    	l_job_header_rec.routing_reference_id :=  p_job_bill_routing_rec.routing_reference_id ;
    	l_job_header_rec.bom_reference_id := p_job_bill_routing_rec.bom_reference_id ;
    	l_job_header_rec.alternate_routing_designator := p_job_bill_routing_rec.alternate_routing_designator ;
    	l_job_header_rec.alternate_bom_designator := p_job_bill_routing_rec.alternate_bom_designator ;
    	l_job_header_rec.completion_subinventory := p_job_bill_routing_rec.completion_subinventory;
    	l_job_header_rec.completion_locator_id := p_job_bill_routing_rec.completion_locator_id;


  	--insert into table wip_job_schedule_interface
    	BEGIN
        	INSERT INTO wip_job_schedule_interface
        	(
        	last_update_date,
        	last_updated_by,
        	creation_date,
        	created_by,
        	last_update_login,
        	load_type,
        	process_phase,
        	process_status,
        	group_id,
        	source_code,
	  	source_line_id,
        	job_name,
        	organization_id,
        	status_type,
        	first_unit_start_date,
        	last_unit_completion_date,
        	completion_subinventory,
        	completion_locator_id,
        	start_quantity,
        	net_quantity,
        	class_code,
        	primary_item_id,
        	bom_reference_id,
        	routing_reference_id,
        	alternate_routing_designator,
        	alternate_bom_designator,
		-- rfieldma, project integration
		   project_id,
		   task_id,
		   end_item_unit_number,
           interface_id
        	)
        	VALUES
        	(
        	l_job_header_rec.last_update_date,
        	l_job_header_rec.last_updated_by,
        	l_job_header_rec.creation_date,
        	l_job_header_rec.created_by,
        	l_job_header_rec.last_update_login,
        	l_job_header_rec.load_type,
        	l_job_header_rec.process_phase,
        	l_job_header_rec.process_status,
        	l_job_header_rec.group_id,
        	l_job_header_rec.source_code,
	  	l_job_header_rec.source_line_id,
        	l_job_header_rec.job_name,
        	l_job_header_rec.organization_id,
        	l_job_header_rec.status_type,
        	l_job_header_rec.first_unit_start_date,
        	l_job_header_rec.last_unit_completion_date,
        	l_job_header_rec.completion_subinventory,
        	l_job_header_rec.completion_locator_id,
        	l_job_header_rec.start_quantity,
        	l_job_header_rec.net_quantity,
        	l_job_header_rec.class_code,
        	l_job_header_rec.primary_item_id,
        	l_job_header_rec.bom_reference_id,
        	l_job_header_rec.routing_reference_id,
        	l_job_header_rec.alternate_routing_designator,
        	l_job_header_rec.alternate_bom_designator,
		   -- rfieldma, project integration
		   l_job_header_rec.project_id,
		   l_job_header_rec.task_id,
		   l_job_header_rec.end_item_unit_number,
           l_job_header_rec.interface_id
        	);
    	EXCEPTION
        	WHEN OTHERS THEN
			FND_MESSAGE.SET_NAME('CSD','CSD_JOB_HEADER_INSERT_ERR');
            	FND_MESSAGE.SET_TOKEN('JOB_NAME', l_job_header_rec.job_name );
            	FND_MSG_PUB.ADD;
            	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            	RETURN;
    	END;


    	IF ( l_proc_level >= l_debug_level ) then
        	FND_LOG.STRING( 	l_proc_level,
        				l_mod_name||'end',
        				'Leaving procedure insert_job_header');
    	END IF;


END insert_job_header;

--	overloaded version of insert job header. receives the job header rec and inserts into the
--  wip_job_schedule_interface table.
-- The job header rec is created as ROWTYPE of wip_job_schedule_interface.
-- 12.1 Create Job from Estimates change, subhat.

PROCEDURE insert_job_header
(
      p_job_header_rec           IN          wip_job_schedule_interface%ROWTYPE,
      x_return_status               OUT   NOCOPY   VARCHAR2
)
IS

      -- Job Record to hold the Job header, bills and routing information being inserted
      -- into wip_job_schedule_interface

   l_job_header_rec                wip_job_schedule_interface%ROWTYPE := p_job_header_rec;


      -- variables used for FND_LOG debug messages

      l_debug_level                   NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
      l_proc_level                    NUMBER  := FND_LOG.LEVEL_PROCEDURE;
      l_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_wip_job_pvt.insert_job_header.';


      -- Constants Used for Inserting into wip_job_schedule_interface,
      -- These are the values needed for WIP Mass Load to pick up the records

      -- Indicates that the process Phase is Validation
      lc_validation_phase        CONSTANT    NUMBER := 2;

      -- Indicates that the process_status is Pending
      lc_pending_status       CONSTANT NUMBER := 1;

      -- Source Code Value of 'Depot_Repair'
      lc_depot_repair_source_code   CONSTANT VARCHAR2(30) :=   'DEPOT_REPAIR';

      -- Depot repair Application Id passed as source_line_id
      lc_depot_app_source_line_id   CONSTANT NUMBER := 512;




BEGIN


      IF ( l_proc_level >= l_debug_level ) then
         FND_LOG.STRING(   l_proc_level,
                  l_mod_name||'begin',
                  'Entering procedure insert_job_header' );
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Populate the record l_job_header_rec


      -- Populate the constant values

      l_job_header_rec.process_phase := lc_validation_phase;
      l_job_header_rec.process_status := lc_pending_status;
      l_job_header_rec.source_code := lc_depot_repair_source_code;
      l_job_header_rec.source_line_id := lc_depot_app_source_line_id ;


      -- Populate the row who columns

      l_job_header_rec.creation_date := SYSDATE;
      l_job_header_rec.last_update_date := SYSDATE;
      l_job_header_rec.created_by := fnd_global.user_id;
      l_job_header_rec.last_updated_by := fnd_global.user_id;
      l_job_header_rec.last_update_login := fnd_global.login_id;


   --insert into table wip_job_schedule_interface
      BEGIN
         INSERT INTO wip_job_schedule_interface
         (
         wip_entity_id,
         interface_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         load_type,
         process_phase,
         process_status,
         group_id,
         header_id,
         source_code,
          source_line_id,
         job_name,
         organization_id,
         status_type,
         first_unit_start_date,
         last_unit_completion_date,
         completion_subinventory,
         completion_locator_id,
         start_quantity,
         net_quantity,
         class_code,
         primary_item_id,
         bom_reference_id,
         routing_reference_id,
         alternate_routing_designator,
         alternate_bom_designator,
		 project_id,
		 task_id,
		 end_item_unit_number
         )
         VALUES
         (
         l_job_header_rec.wip_entity_id,
         l_job_header_rec.interface_id,
         l_job_header_rec.last_update_date,
         l_job_header_rec.last_updated_by,
         l_job_header_rec.creation_date,
         l_job_header_rec.created_by,
         l_job_header_rec.last_update_login,
         l_job_header_rec.load_type,
         l_job_header_rec.process_phase,
         l_job_header_rec.process_status,
         l_job_header_rec.group_id,
         l_job_header_rec.header_id,
         l_job_header_rec.source_code,
		 l_job_header_rec.source_line_id,
         l_job_header_rec.job_name,
         l_job_header_rec.organization_id,
         l_job_header_rec.status_type,
         l_job_header_rec.first_unit_start_date,
         l_job_header_rec.last_unit_completion_date,
         l_job_header_rec.completion_subinventory,
         l_job_header_rec.completion_locator_id,
         l_job_header_rec.start_quantity,
         l_job_header_rec.net_quantity,
         l_job_header_rec.class_code,
         l_job_header_rec.primary_item_id,
         l_job_header_rec.bom_reference_id,
         l_job_header_rec.routing_reference_id,
         l_job_header_rec.alternate_routing_designator,
         l_job_header_rec.alternate_bom_designator,
		 l_job_header_rec.project_id,
		 l_job_header_rec.task_id,
		 l_job_header_rec.end_item_unit_number
         );
      EXCEPTION
         WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_JOB_HEADER_INSERT_ERR');
               FND_MESSAGE.SET_TOKEN('JOB_NAME', l_job_header_rec.job_name );
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RETURN;
      END;


      IF ( l_proc_level >= l_debug_level ) then
         FND_LOG.STRING(   l_proc_level,
                  l_mod_name||'end',
                  'Leaving procedure insert_job_header');
      END IF;


END insert_job_header;



-- This Procedure verifies that both the Internal and Standard Concurrent
-- managers are up. If either one is down, it writes an error to the
-- message list and returns an error status.

PROCEDURE verify_conc_manager_status
(
	x_return_status       	OUT NOCOPY 	VARCHAR2
)
IS

	-- Used in the call to check if concurrent managers are up

    	l_targetp         NUMBER;
    	l_activep         NUMBER;
    	l_targetp1        NUMBER;
    	l_activep1        NUMBER;
    	l_pmon_method     VARCHAR2(30);
    	l_callstat        NUMBER;

   	-- Declare the constants

    	-- FND Application_id under which the standard and intenral concurrent managers are registered,
    	-- Concurrent Manager Id for Standard and Internal Managers.
    	-- These are used in the call to get_manager_status to see if the standard and internal concurrent
    	-- managers are up

    	l_fnd_application_id		CONSTANT	NUMBER := 0;
    	l_internal_manager_id		CONSTANT	NUMBER := 1;
    	l_standard_manager_id		CONSTANT	NUMBER := 0;


BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Validate if Internal Concurrent Manager is up

    	fnd_concurrent.get_manager_status(applid => l_fnd_application_id,
                                    managerid => l_internal_manager_id,
                                    targetp => l_targetp1,
                                    activep => l_activep1,
                                    pmon_method => l_pmon_method,
                                    callstat => l_callstat);


    	-- Validate if Standard Concurrent Manager is up

    	fnd_concurrent.get_manager_status(applid => l_fnd_application_id,
                                    managerid => l_standard_manager_id,
                                    targetp => l_targetp,
                                    activep => l_activep,
                                    pmon_method => l_pmon_method,
                                    callstat => l_callstat);

    	-- If the actual number of processes that are up for either the Internal
    	-- or Standard Manager is <= 0, which indicates that the concurrent manager
    	-- is down, then add the message to the message list and exit

    	IF (l_activep <= 0 OR l_activep1 <= 0) THEN
        	FND_MESSAGE.SET_NAME('CSD','CSD_CONC_MGR_DOWN');
        	FND_MSG_PUB.ADD;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   	END IF;


END verify_conc_manager_status;


-- This procedure checks if the specified Job name exists in the
-- specified organization. It checks if it exists in
-- wip_entities or wip_job_schedule_interface table.
-- If it exists, then an Error status is returned.
-- If it does not exist in either of the tables, then
-- a Sucess status is returned.
-- This procedure is used whenever a job_name is generated, to confirm that
-- the newly generated job_name does not already exist and hence can be
-- used to submit it to WIP Mass Load.


PROCEDURE validate_job_name
(
  	p_job_name			IN 		VARCHAR2,
  	p_organization_id     	IN  		NUMBER,
  	x_return_status       	OUT NOCOPY 	VARCHAR2
)
IS

    	-- Used to check the existence of the Job_name for the specified organizization,
    	l_job_count                     NUMBER := 0;

BEGIN


      Select count(*) into l_job_count from wip_entities where wip_entity_name = p_job_name and
            organization_id = p_organization_id ;

      If l_job_count = 0 Then

		-- Job does not exist in WIP_entities, check if it is already inserted in the interface table by another
		-- process and so may be in the process of getting into WIP.
		-- If it exists, do not want to use this job name, so return Error

            Select count(*) into l_job_count from wip_job_schedule_interface where job_name = p_job_name and
                organization_id = p_organization_id ;

 	      IF l_job_count = 0 THEN

     			-- Generated job name does exist either in the interface or wip_entities table,
      		-- Success is returned

			x_return_status := FND_API.G_RET_STS_SUCCESS;
			RETURN;

		ELSE

			-- Job exists in wip_job_schedule_interface table, hence return Error status

			x_return_status := FND_API.G_RET_STS_ERROR;
			RETURN;


		END IF;


	ELSE

		-- Job exists in wip_entities table, hence return Error status

		x_return_status := FND_API.G_RET_STS_ERROR;
		RETURN;


	END IF;



END validate_job_name;




-- This procedure generates a job name by appending a sequence generated number
-- to the passed in Job_Prefix
-- It Validates that the generated job name is unique for the specified organization,
-- It keeps looping and appending the subsequent sequence generated number, till a
-- unique Job name is generated


PROCEDURE generate_job_name
(
    	p_job_prefix 	        	IN  		VARCHAR2,
    	p_organization_id           	IN  		NUMBER,
    	x_job_name                  	OUT NOCOPY 	VARCHAR2
)
IS

	l_return_status VARCHAR2(1);

BEGIN

	Loop

		-- generate the Job Name by appending a sequence generated number to the passed in
		-- job_prefix

            Select p_job_prefix || TO_CHAR( CSD_JOB_NAME_S.NEXTVAL ) into
            x_job_name From Dual;


            -- Check if the job name generated is unique for the specified organization,
		-- if not loop around till a unique job name is generated

		Validate_job_name     ( p_job_name 		 => x_job_name,
					 	p_organization_id  => p_organization_id,
						x_return_status    => l_return_status ) ;

		IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

			-- Generated job name does not exist both in the interface and wip_entities table, so exit the loop

			exit;

	      END IF;


	End Loop;

END generate_job_name;

-- private procedure.
-- this procedure creates a material transactions table type based on the repair estimate lines.
-- all the material estimates with source as manual or repair bom would be passed as repair
-- estimates. The procedure takes in repair_line_id,wip_entity_id and the material transactions
-- table is out parameter.
-- The procedure also converts the repair item as default material requirement if the corresponding -- profile option is set. If the repair order item has serial number entered, the same is passed to
-- material requirements.
-- 12.1 default material requirements -- subhat.

PROCEDURE import_estms_to_wipjob(p_repair_line_id IN NUMBER,
								 p_wip_entity_id IN NUMBER,
								 x_mtl_txn_dtls_tab_type OUT NOCOPY          CSD_HV_WIP_JOB_PVT.mtl_txn_dtls_tbl_type )
		IS

-- local variables

l_operation_seq_num NUMBER := 1;
l_estimate_uom VARCHAR2(25);
l_inv_org NUMBER := cs_std.get_item_valdn_orgzn_id;
l_counter NUMBER;

-- cursor to calculate the estimate details.


CURSOR repair_estimate_dtls(p_rep_line_id in number) IS
SELECT crl.inventory_item_id,
       -- bug#7132807, subhat. no need to select estimate quantity.
       --crl.estimate_quantity,
       crl.lot_control_code,
       crl.serial_number_control_code,
       msi.primary_uom_code,
       crl.unit_of_measure_code,
	     msi.revision_qty_control_code,
	     msi.new_revision_code,
       SUM(crl.estimate_quantity) AS quantity
FROM csd_repair_estimate_lines_v crl, mtl_system_items_kfv msi
WHERE crl.repair_line_id = p_rep_line_id AND
      crl.inventory_item_id = msi.inventory_item_id AND
      msi.organization_id = cs_std.get_item_valdn_orgzn_id AND
      billing_category = 'M' AND
      est_line_source_type_code IN ('MANUAL','REPAIR_BOM')
GROUP BY   crl.inventory_item_id,/*crl.estimate_quantity,*/ crl.lot_control_code,crl.serial_number_control_code,msi.primary_uom_code,crl.unit_of_measure_code,msi.revision_qty_control_code, msi.new_revision_code;

-- cursor to fetch the default operation sequence number

CURSOR default_operation(p_wip_entity_id IN NUMBER) IS
SELECT operation_seq_num
FROM wip_operations
WHERE wip_entity_id = p_wip_entity_id AND
		  previous_operation_seq_num IS NULL ;

-- special case ( when CSD: Default Repair Item as Material on Job profile is set to yes)
-- cursor to fetch the material details.

CURSOR repair_item_dtls(p_rep_line_id IN NUMBER) IS

SELECT cr.inventory_item_id,
	   cr.unit_of_measure,
	   cr.serial_number,
	   cr.quantity,
	   cr.inventory_org_id
	   --msi.serial_number_control_code
FROM
	   csd_repairs_v cr
WHERE
	   cr.repair_line_id = p_repair_line_id;

BEGIN

-- determine the operations to which the materials needs to be issued.

OPEN default_operation(p_wip_entity_id);
FETCH default_operation INTO l_operation_seq_num;
CLOSE default_operation;

-- check the value of l_operation_seq_num if its null make it 1.

IF l_operation_seq_num IS NULL THEN
	l_operation_seq_num := 1;
END IF;

l_counter := 1;
-- special case
-- when the profile CSD: Default Repair Item as Material on Job is set to yes, we need to populate
-- the repair item as the material requirement,irrespective if there are any estimate lines or not.
-- put the profile value once the profile is created.

-- clear the collection type.

x_MTL_TXN_DTLS_TAB_TYPE.DELETE;

IF nvl(fnd_profile.value('CSD_DEFAULT_RO_ITEM_AS_MATERIAL_ON_JOB'),'N') = 'Y' THEN
	OPEN repair_item_dtls(p_repair_line_id);
	FETCH repair_item_dtls INTO
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).inventory_item_id,
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).transaction_uom,
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).serial_number,
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).required_quantity,
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).organization_id ;
	CLOSE repair_item_dtls;
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).transaction_quantity := x_MTL_TXN_DTLS_TAB_TYPE(l_counter).required_quantity;
	-- sub inventory is defaulted from the CSD_DEF_HV_SUBINV profile option.
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).supply_subinventory := fnd_profile.value('CSD_DEF_HV_SUBINV');
		--message(fnd_profile.value('CSD_DEF_HV_SUBINV'));
		IF x_MTL_TXN_DTLS_TAB_TYPE(l_counter).supply_subinventory IS NULL THEN
				  FND_MESSAGE.SET_NAME('CSD','CSD_DEF_SUB_INV_NULL');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
		END IF;
	x_MTL_TXN_DTLS_TAB_TYPE(l_counter).new_row := 'Y';

	x_MTL_TXN_DTLS_TAB_TYPE(l_counter).supply_locator_id := NULL;
	x_MTL_TXN_DTLS_TAB_TYPE(l_counter).wip_entity_id := p_wip_entity_id;

	x_MTL_TXN_DTLS_TAB_TYPE(l_counter).operation_seq_num := l_operation_seq_num;

	l_counter := l_counter + 1;
END IF;



OPEN repair_estimate_dtls(p_repair_line_id);

LOOP

	FETCH repair_estimate_dtls INTO
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).inventory_item_id,
		-- bug#6903726 subhat
		--x_MTL_TXN_DTLS_TAB_TYPE(l_counter).transaction_quantity,
		-- bug#7132807 subhat.
    --x_MTL_TXN_DTLS_TAB_TYPE(l_counter).required_quantity,
		-- end bug#6903726 subhat
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).lot_control_code,
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).serial_number_control_code,
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).transaction_uom,
		l_estimate_uom,
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).revision_qty_control_code,
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).revision,
    --bug#6903726 subhat
		--x_MTL_TXN_DTLS_TAB_TYPE(l_counter).required_quantity;
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).transaction_quantity;
		--end bug#6903726 subhat
		EXIT WHEN repair_estimate_dtls%NOTFOUND;
-- check if the repair estimate UOM is different from primary UOM for the item.
-- if its different then convert the UOM to primary UOM and corrosponding quantity.
		IF l_estimate_uom <> x_MTL_TXN_DTLS_TAB_TYPE(l_counter).transaction_uom THEN
			-- if the uom's are different then change convert the quantity.
			-- for instance if primary uom = 'Ea' and estimate UOM = dozen and estimate quantity = 1
			-- then the quantity should be changed to 1* uom_Conversion_factor for dozen.
			NULL;
		END IF;

		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).organization_id := l_inv_org;
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).new_row := 'Y';

	-- sub inventory is defaulted from the CSD_DEF_HV_SUBINV profile option.
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).supply_subinventory := fnd_profile.value('CSD_DEF_HV_SUBINV');
		--message(fnd_profile.value('CSD_DEF_HV_SUBINV'));
		IF x_MTL_TXN_DTLS_TAB_TYPE(l_counter).supply_subinventory IS NULL THEN
				  FND_MESSAGE.SET_NAME('CSD','CSD_DEF_SUB_INV_NULL');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
		END IF;

	  x_MTL_TXN_DTLS_TAB_TYPE(l_counter).supply_locator_id := NULL;
		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).wip_entity_id := p_wip_entity_id;

		-- check whether the item is serial controlled. If so default in the serial number.

		x_MTL_TXN_DTLS_TAB_TYPE(l_counter).operation_seq_num := l_operation_seq_num;

		l_counter := l_counter + 1;
END LOOP;

	IF repair_estimate_dtls%ISOPEN THEN
		CLOSE repair_estimate_dtls;
	END IF;

END import_estms_to_wipjob;


-- API
--   SUBMIT_JOBS
--
-- Purpose
--    This API creates WIP Jobs by submitting the passed in Job information to
--    WIP Mass Load and updates CSD tables with the newly created jobs information.
--    It achieves this by calling helper procedures.
--
-- 	This API inserts Job header, Bills and Routing information passed in into
--    WIP_JOB_SCHEDULE_INTERFACE table by calling procedure insert_job_header.
--
--    If job name is not passed in, then it is generated here by appending a
--    sequence generated number to the job_name_prefix passed in.
--    If job name is passed in, it is validated to make sure that it is unique
--    for the specified organization.
--
-- 	This API then submits the concurrent request for concurrent
--    program 'Depot Repair WIP Job Submission', which submits WIP Mass Load,
--    waits for it to complete and then runs the WIP Update program to update WIP
--    information in CSD tables.
--
-- 	If no routings or bills are passed in, jobs are submitted to WIP Mass Load based
-- 	on the header information to create jobs with no operations, material requirements
-- 	or resource requirements.
--
-- Arguments
--   p_repair_line_id - 	  Repair Line Id of the repair order for which the jobs are being created.
--					  WIP Update program is run for the specified repair order.
--                      	  If jobs are being submitted for more than one repair order, then this is
--                              passed in as null and the WIP Update program is run for all the eligible
--				        repair orders.
--   p_job_header_rec - 	  Job header Information record. This is the same for all the jobs being created.
--   p_x_job_bill_routing_tbl - Table of Bill and Routing information records. Each record results in a
--					  new job. If a record here has a not null Job Name specified, then the job name
--					  specified here is used, instead of generating it. This is done only when one job
--					  is being submitted and the profile option 'Use CSD as Job Prefix' is set to 'N'.
--					  This is a IN OUT parameter as the generated Job names are passed back to the
--					  calling program in this table.
--  x_group_id -			  Group_id used for the WIP Mass Load concurrent request submission. This is returned
--					  to the calling program.
--  x_request_id -              Concurrent Request id of the concurrent request submitted for concurrent program
--					  'Depot Repair WIP Job Submission'. This is passed back to the calling program.
--
--   Note, p_commit is not specified as a parameter to this API, as for successful submission of a concurrent
--   request, a commit is required always, so this API always commits. For the same reason, this API is
--   declared as an AUTONOMOUS Transaction. For a AUTONOMOUS Transaction, we cannot rollback to a specified
--   SAVEPOINT, hence SAVEPOINT is not specified.


PROCEDURE submit_jobs
(
    p_api_version                       	IN     		NUMBER,
    p_init_msg_list                     	IN     		VARCHAR2 := FND_API.G_FALSE,
    p_validation_level                  	IN    		NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status		            OUT  	NOCOPY  	VARCHAR2,
    x_msg_count		                  OUT 	NOCOPY   	NUMBER,
    x_msg_data		                  OUT	NOCOPY   	VARCHAR2,
    p_repair_line_id                    	IN 			NUMBER,
    p_job_header_rec                    	IN 			job_header_rec_type,
    p_x_job_bill_routing_tbl	        	IN OUT NOCOPY   	job_bill_routing_tbl_type,
    x_group_id                          	OUT  	NOCOPY  	NUMBER,
    x_request_id                        	OUT  	NOCOPY  	NUMBER
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

--This API is an Autonomous Transaction. We have to explicitly commit or rollback the
--transactions it or its called procedure contain when it exits. This autonomous
--transaction doesn't affect the main transaction in its calling API.


 	l_api_name                      CONSTANT VARCHAR2(30) := 'Submit_jobs';
    	l_api_version                   CONSTANT NUMBER       := 1.0;

    	l_group_id                      NUMBER;


    	-- Bill, routing information for the Job passed to insert_job_header
    	l_job_bill_routing_rec          job_bill_routing_rec_type;


    	-- variables used for FND_LOG debug messages

    	l_debug_level                   NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    	l_stat_level                    NUMBER  := FND_LOG.LEVEL_STATEMENT;
    	l_proc_level                    NUMBER  := FND_LOG.LEVEL_PROCEDURE;
    	l_event_level                   NUMBER  := FND_LOG.LEVEL_EVENT;
    	l_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_wip_job_pvt.submit_jobs.';

        l_default_ro_item               VARCHAR2(1);
        l_wip_entity_id                 NUMBER;
        l_mtl_txn_dtls_tbl              CSD_HV_WIP_JOB_PVT.MTL_TXN_DTLS_TBL_TYPE;
        l_op_created		            VARCHAR2(10);


        CURSOR c_repair_line_info(p_repair_line_id IN NUMBER) IS
        select inventory_item_id, unit_of_measure, quantity, serial_number, inventory_org_id
        from csd_repairs
        where repair_line_id = p_repair_line_id;

        CURSOR c_count_material(p_wip_entity_id NUMBER, l_inventory_item_id NUMBER) IS
        select 'X'
        from wip_requirement_operations_v
        where wip_entity_id = p_wip_entity_id
        and inventory_item_id = l_inventory_item_id
        and rownum = 1;


        -- Cursor to select the item attributes serial control code and
        --  lot control code.
        CURSOR cur_get_item_attribs (
         p_org_id                            NUMBER,
         p_item_id                           NUMBER
        )
        IS
         SELECT serial_number_control_code
           FROM mtl_system_items
          WHERE organization_id = p_org_id AND inventory_item_id = p_item_id;


        Cursor c_get_serial_info(p_item_id number, p_serial_number varchar2, p_org_id number) is
        select current_status, current_subinventory_code from mtl_serial_numbers
        where inventory_item_id = p_item_id and serial_number = p_serial_number and current_organization_id = p_org_id;


        Cursor c_get_min_operation_seq(p_wip_entity_id number) is
        select min(operation_seq_num) from wip_operations_v where wip_entity_id = p_wip_entity_id;

        l_inventory_item_id     NUMBER;
        l_unit_of_measure       VARCHAR2(3);
        l_quantity              NUMBER;
        l_serial_number         VARCHAR2(30);
        l_inventory_org_id      NUMBER;
        l_subinventory          VARCHAR2(30);
        l_dummy                 VARCHAR2(1) := null;
        l_serial_control_code   NUMBER;
        l_current_status        NUMBER;
        l_current_subinventory_code VARCHAR2(10);
        l_operation_seq_num     NUMBER;
        l_num_other_jobs        NUMBER :=0; -- swai: bug 7477845/7483291
        l_interface_id          NUMBER;     -- nnadig: bug 9263438

BEGIN

    	IF ( l_proc_level >= l_debug_level ) THEN
        	FND_LOG.STRING( 	l_proc_level,
        				l_mod_name||'begin',
        				'Entering Private API submit_jobs');
    	END IF;

    	-- Standard call to check for call compatibility
   	IF Not FND_API.COMPATIBLE_API_CALL(	l_api_version,
                                       	p_api_version,
                                       	l_api_name,
                                       	G_PKG_NAME) THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END If;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_boolean(p_init_msg_list) THEN
        	FND_MSG_PUB.initialize;
    	END IF;

    	--  Initialize API return status to success
    	x_return_status:=FND_API.G_RET_STS_SUCCESS;


	-- Verify that the Standard and Internal Concurrent Managers are UP

      verify_conc_manager_status ( x_return_status    => x_return_status );

      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    l_default_ro_item := nvl(FND_PROFILE.VALUE('CSD_DEFAULT_RO_ITEM_AS_MATERIAL_ON_JOB'), 'N');

	-- Get the Group_id to be used for WIP Mass Load, All the records inserted into
	-- wip_job_schedule_interface have the same group_id , so that one WIP Mass Load
	-- request can process all the records

    if (l_default_ro_item = 'N') then
	    SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_group_id FROM dual;

    else
        OPEN  c_repair_line_info(p_repair_line_id);
        FETCH c_repair_line_info into
              l_inventory_item_id,
              l_unit_of_measure,
              l_quantity,
              l_serial_number,
              l_inventory_org_id;
        CLOSE c_repair_line_info;
        l_subinventory := fnd_profile.value('CSD_DEF_HV_SUBINV');


        --Get serial number control code and lot control code
        OPEN cur_get_item_attribs (l_inventory_org_id,
                             l_inventory_item_id);

        FETCH cur_get_item_attribs
            INTO l_serial_control_code;
        CLOSE cur_get_item_attribs;


        IF l_serial_control_code IN (2, 5) then
            OPEN c_get_serial_info (l_inventory_item_id, l_serial_number, l_inventory_org_id);
            FETCH c_get_serial_info
                INTO l_current_status,l_current_subinventory_code;
            CLOSE c_get_serial_info;
            --current status = 3 is valid serial number
            if (l_current_status = 3) then
                l_subinventory := l_current_subinventory_code;
            else
                l_serial_number := null;
            end if;
        else
            --don't pass the serial number, it is not valid serial number
            l_serial_number := null;
        end if;

    End if;


	IF p_x_job_bill_routing_tbl.COUNT = 0 THEN

        if (l_default_ro_item = 'Y') then
	        SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_group_id FROM dual;
        End if;

        p_x_job_bill_routing_tbl(0).group_id := l_group_id;

   		-- The bill_routings table is empty, Generate the job name using the
    		-- job_prefix passed in. Here no bills and routings are passed in and only one job
   		-- will be created for the passed in Job header information.


  		generate_job_name  (   	p_job_prefix       => p_job_header_rec.job_prefix,
					  	p_organization_id  => p_job_header_rec.organization_id,
                                	x_job_name         => l_job_bill_routing_rec.job_name );


	  	-- Assign the generated Job name to the first record in job_bill_routing_tbl to be passed back
	  	-- to the calling program. This is passed to the insert_job_header procedure as well.

        	p_x_job_bill_routing_tbl(0).job_name := l_job_bill_routing_rec.job_name;

        	IF ( l_event_level >= l_debug_level ) then
            	FND_LOG.STRING( 	l_event_level,
            				l_mod_name||'beforecallinsert',
            				'Just before calling insert_job_header');
       	END IF;


        	-- Call procedure to insert job header and job name information
        	-- into wip_job_schedule_interface table


        	insert_job_header(  	p_job_header_rec 		=> 	p_job_header_rec,
                            		p_job_bill_routing_rec  =>	l_job_bill_routing_rec,
                            		p_group_id 			=> 	l_group_id,
                                        x_interface_id                  => l_interface_id,--nnadig: bug 9263438
                            		x_return_status 		=> 	x_return_status );


        	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       	END IF;

        if (l_default_ro_item = 'Y') then

            --This code is change to online create the wipjob without use the concurrent program.
                 WIP_MASSLOAD_PUB.createOneJob( p_interfaceID => l_interface_id,--nnadig: bug 9263438
                         p_validationLevel => p_validation_level,
                         x_wipEntityID => l_wip_entity_id,
                         x_returnStatus => x_return_status,
                         x_errorMsg     => x_msg_data );

                if (x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                    FND_MESSAGE.SET_NAME('CSD','CSD_JOB_GEN_FAILURE');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                end if;

                COMMIT;

                -- swai: bug 7477845/7483291
                -- check if there another job existing for this RO.  If so, do not default
                -- the RO item as a material.  Must compare we.wip_entity_id since
                -- crj.wip_entity_id may be null (until wip_update is done).
                select count(*)
                  into l_num_other_jobs
                  from csd_repair_job_xref crj,
                       wip_entities we
                 where crj.job_name        = we.wip_entity_name
                   and crj.organization_id = we.organization_id
                   and crj.repair_line_id = p_repair_line_id
                   and we.wip_entity_id <> l_wip_entity_id;

                l_dummy := null;
                OPEN c_count_material(l_wip_entity_id, l_inventory_item_id);
                FETCH c_count_material into l_dummy;
                CLOSE c_count_material;


                if (l_dummy is null) and (l_num_other_jobs = 0) then
                    --Default Repair Item as Material on Job
                    l_mtl_txn_dtls_tbl.delete;

                    l_mtl_txn_dtls_tbl(0).INVENTORY_ITEM_ID          :=l_inventory_item_id;
                    l_mtl_txn_dtls_tbl(0).WIP_ENTITY_ID              :=l_wip_entity_id;
                    l_mtl_txn_dtls_tbl(0).ORGANIZATION_ID            :=l_inventory_org_id;
                    l_mtl_txn_dtls_tbl(0).OPERATION_SEQ_NUM          :=1;
                    l_mtl_txn_dtls_tbl(0).TRANSACTION_QUANTITY       :=l_quantity; --repair order qty
                    l_mtl_txn_dtls_tbl(0).TRANSACTION_UOM            :=l_unit_of_measure; --Repair order UOM
                    l_mtl_txn_dtls_tbl(0).SERIAL_NUMBER              :=l_serial_number;
                    l_mtl_txn_dtls_tbl(0).SUPPLY_SUBINVENTORY        :=l_subinventory;
                    l_mtl_txn_dtls_tbl(0).OBJECT_VERSION_NUMBER      := 1;
                    l_mtl_txn_dtls_tbl(0).NEW_ROW                    := 'Y';


                    -- call API to create Repair Actuals header
                    CSD_HV_WIP_JOB_PVT.PROCESS_SAVE_MTL_TXN_DTLS
                            ( p_api_version_number      => 1.0,
                              p_init_msg_list           => 'T',
                              p_commit                  => 'F',
                              p_validation_level        => 1,
                              p_mtl_txn_dtls_tbl		=> l_mtl_txn_dtls_tbl,
		                      x_op_created				=> l_op_created,
                              x_return_status           => x_return_status,
                              x_msg_count               => x_msg_count,
                              x_msg_data                => x_msg_data);
                    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                        FND_MESSAGE.SET_NAME('CSD','CSD_JOB_GEN_FAILURE');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                end if;

        End if;

	ELSE

		-- The bill_routings table is not empty
    		-- Process each bill routng record passed in to generate unique job names for each job being submitted,
		-- if needed.
		-- Check each record to see if the job_name is already passed in,
    		-- If it is passed in, it is validated for uniqueness and an error is raised if not unique and we exit out of
    		-- the API.
   		-- If job_name is not passed in, then the job_name is generated
    		-- by appending a sequence generated number to the job_prefix specified in the job header record.
    		-- For each bill, routings record, once a job name is found or generated, procedure insert_job_header is called
    		-- to insert the header, bills and routings information into the WIP interface table.

    		-- Note, for now, a job_name is passed in, only when one Job is submitted and the profile
    		-- 'Use CSD as Job Prefix' is set to 'N'. However this API supports job names
    		-- to be passed in, when more than one jobs are submitted.


    		FOR rt_ctr in p_x_job_bill_routing_tbl.FIRST.. p_x_job_bill_routing_tbl.LAST

		LOOP

            if (l_default_ro_item = 'Y') then
	            SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_group_id FROM dual;
            End if;

            p_x_job_bill_routing_tbl(rt_ctr).group_id := l_group_id;

	  		-- Populate the bill, routing record variable to be passed to procedure insert_job_header

        		l_job_bill_routing_rec := p_x_job_bill_routing_tbl(rt_ctr) ;


            	IF  l_job_bill_routing_rec.job_name is not NULL then

               		-- job name is passed in, validate it for Uniqueness,
		   		-- Check if it already exists in WIP_ENTITIES or WIP interface table

		   		validate_job_name (  	p_job_name 		 => l_job_bill_routing_rec.Job_Name,
					 			p_organization_id  => p_job_header_rec.organization_id,
								x_return_status    => x_return_status  ) ;


                		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

					-- Job name either exists in WIP_ENTITIES or in the interface table for the specified
			      	-- organization, So raise an error and exit

                        	FND_MESSAGE.SET_NAME('CSD','CSD_JOB_NAME_EXISTS');
					FND_MESSAGE.SET_TOKEN('JOB_NAME', l_job_bill_routing_rec.job_name );
                        	FND_MSG_PUB.ADD;
                        	RAISE FND_API.G_EXC_ERROR;
                		end if;

            	ELSE

               		-- job name is not passed in , generate the Job Name

	   	   		generate_job_name  (   	p_job_prefix       => p_job_header_rec.job_prefix,
					        		p_organization_id  => p_job_header_rec.organization_id,
                                      		x_job_name         => l_job_bill_routing_rec.job_name );



	 	    		-- Assign the generated Job name to the current record in job_bill_routing_tbl to be passed
                		-- to procedure insert_job_header and is also passed back
	  	    		-- to the calling program.

                		p_x_job_bill_routing_tbl(rt_ctr).job_name := l_job_bill_routing_rec.job_name;

            	END IF;


        		IF ( l_event_level >= l_debug_level ) then
            		FND_LOG.STRING( 	l_event_level,
            					l_mod_name||'beforecallinsert',
            					'Just before calling insert_job_header');
       	 	END IF;

        		-- Call procedure to insert job header and bills, routing information
        		-- into wip_job_schedule_interface table
     			-- All the records inserted into the WIP interface table
        		-- are passed the same group_id and hence will be processed by one WIP Mass Load
        		-- request.

        		insert_job_header( p_job_header_rec 	  => p_job_header_rec,
                            	           p_job_bill_routing_rec => l_job_bill_routing_rec,
                            		   p_group_id 	          => l_group_id,
                                           x_interface_id         => l_interface_id,--nnadig: bug 9263438
                            	           x_return_status 	  => x_return_status );


        		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        		END IF;

                if (l_default_ro_item = 'Y') then

                    --This code is change to online create the wipjob without use the concurrent program.
                    WIP_MASSLOAD_PUB.createOneJob( p_interfaceID => l_interface_id,--nnadig: bug 9263438
                             p_validationLevel => p_validation_level,
                             x_wipEntityID => l_wip_entity_id,
                             x_returnStatus => x_return_status,
                             x_errorMsg     => x_msg_data );

                    if (x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                        FND_MESSAGE.SET_NAME('CSD','CSD_JOB_GEN_FAILURE');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    end if;

                    COMMIT;

                    -- swai: bug 7477845/7483291
                    -- check if there another job existing for this RO.  If so, do not default
                    -- the RO item as a material. Must compare we.wip_entity_id since
                    -- crj.wip_entity_id may be null (until wip_update is done).
                    select count(*)
                      into l_num_other_jobs
                      from csd_repair_job_xref crj,
                           wip_entities we
                     where crj.job_name        = we.wip_entity_name
                       and crj.organization_id = we.organization_id
                       and crj.repair_line_id = p_repair_line_id
                       and we.wip_entity_id <> l_wip_entity_id;
                    -- More than one bill/route could have been submitted at a time.
                    -- These jobs are processed all at once before rows are inserted into
                    -- csd_repair_job_xref.  Need to count these jobs as well.
                    l_num_other_jobs := l_num_other_jobs + rt_ctr - p_x_job_bill_routing_tbl.FIRST;
                    -- end swai: bug 7477845/7483291

                    l_dummy := null;
                    OPEN c_count_material(l_wip_entity_id, l_inventory_item_id);
                    FETCH c_count_material into l_dummy;
                    CLOSE c_count_material;

                    if (l_dummy is null) and (l_num_other_jobs = 0) then

                        --Default Repair Item as Material on Job
                        l_mtl_txn_dtls_tbl.delete;

                        OPEN  c_get_min_operation_seq(l_wip_entity_id);
                        FETCH c_get_min_operation_seq into l_operation_seq_num;
                        CLOSE c_get_min_operation_seq;

                        if (l_operation_seq_num is null) then
                            l_operation_seq_num := 1;
                        end if;

                        l_mtl_txn_dtls_tbl(0).INVENTORY_ITEM_ID          :=l_inventory_item_id;
                        l_mtl_txn_dtls_tbl(0).WIP_ENTITY_ID              :=l_wip_entity_id;
                        l_mtl_txn_dtls_tbl(0).ORGANIZATION_ID            :=l_inventory_org_id;

                        if (l_job_bill_routing_rec.routing_reference_id is null) then

                            l_mtl_txn_dtls_tbl(0).OPERATION_SEQ_NUM          :=1;
                        else
                            l_mtl_txn_dtls_tbl(0).OPERATION_SEQ_NUM          :=l_operation_seq_num;
                        end if;
                        l_mtl_txn_dtls_tbl(0).TRANSACTION_QUANTITY       :=l_quantity; --repair order qty
                        l_mtl_txn_dtls_tbl(0).TRANSACTION_UOM            :=l_unit_of_measure; --Repair order UOM
                        l_mtl_txn_dtls_tbl(0).SERIAL_NUMBER              :=l_serial_number;
                        l_mtl_txn_dtls_tbl(0).SUPPLY_SUBINVENTORY        :=l_subinventory;
                        l_mtl_txn_dtls_tbl(0).OBJECT_VERSION_NUMBER      := 1;
                        l_mtl_txn_dtls_tbl(0).NEW_ROW                    := 'Y';


                        -- call API to create Repair Actuals header
                        CSD_HV_WIP_JOB_PVT.PROCESS_SAVE_MTL_TXN_DTLS
                                ( p_api_version_number      => 1.0,
                                  p_init_msg_list           => 'T',
                                  p_commit                  => 'F',
                                  p_validation_level        => 1,
                                  p_mtl_txn_dtls_tbl		=> l_mtl_txn_dtls_tbl,
		                          x_op_created				=> l_op_created,
                                  x_return_status           => x_return_status,
                                  x_msg_count               => x_msg_count,
                                  x_msg_data                => x_msg_data);
                        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                            FND_MESSAGE.SET_NAME('CSD','CSD_JOB_GEN_FAILURE');
                            FND_MSG_PUB.ADD;
                            RAISE FND_API.G_EXC_ERROR;
                        END IF;
                    end if;
       --                 COMMIT;
                End if;


    		END LOOP ;

	END IF;


    	-- submit request for 'Depot Repair WIP Job Submission' concurrent program, which in turn
    	-- submits WIP Mass Load, waits for it to complete and then calls the WIP UPDATE
    	-- program.
   	-- Here the repair_line_id specified is used to run the WIP Update program for
    	-- the specified repair_line_id. If Jobs are submitted for more than one repair
    	-- order, then p_repair_line_id is NULL, In this case, the WIP Update program runs for
    	-- all eligible repair orders.

        if (l_default_ro_item = 'N') then
    	    x_request_id    :=   fnd_request.submit_request	(
   								    application 	=> 	'CSD',
                  					    program 		=> 	'CSDJSWIP',
                  					    description 	=> 	NULL,
                  					    start_time 		=> 	NULL,
                  					    sub_request 	=> 	FALSE,
                  					    argument1 		=> 	TO_CHAR(l_group_id),
                  					    argument2 		=> 	p_repair_line_id ) ;

    	    IF ( l_stat_level >= l_debug_level ) then
        	    FND_LOG.STRING( 	l_stat_level,
        				    l_mod_name||'submitdata',
        				    'When calling submit_request, the group_id is '||to_char(l_group_id));
    	    END IF;


    	    IF ( x_request_id = 0 ) THEN

       	    -- request submission failed,
	 	    -- add the error message to the message list and exit

        	    FND_MESSAGE.SET_NAME('CSD','CSD_CSDJSWIP_SUBMIT_FAILURE');
        	    FND_MSG_PUB.ADD;
        	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


        	    IF ( l_stat_level >= l_debug_level ) then
            	    FND_LOG.STRING( 	l_stat_level,
            				    l_mod_name||'requestfail',
            				    'Submit request failed');
        	    END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    	    ELSE
	  	        --This commit is a must for the successful submission of the concurrent request above
      	        COMMIT;
    	        -- Populate the Out parameter x_group_id
    	        x_group_id := l_group_id;

    	    END IF;
        END IF;

        COMMIT;

    	IF ( l_proc_level >= l_debug_level ) then
        	FND_LOG.STRING( l_proc_level,
        	l_mod_name||'end',
        	'Leaving Private API submit_jobs');
    	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
        	ROLLBACK ;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        	FND_MSG_PUB.count_and_get( 	p_encoded => FND_API.G_FALSE,
                               		p_count   => x_msg_count,
                               		p_data    => x_msg_data);

        	IF ( FND_LOG.LEVEL_EXCEPTION >= l_debug_level ) then
            	FND_LOG.STRING(	FND_LOG.LEVEL_EXCEPTION,
            				l_mod_name||'unx_exception',
            				'G_EXC_UNEXPECTED_ERROR Exception');
        	END IF;


    	WHEN FND_API.G_EXC_ERROR THEN
        	ROLLBACK ;
        	x_return_status := FND_API.G_RET_STS_ERROR;
        	FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);

        	IF ( FND_LOG.LEVEL_ERROR >= l_debug_level ) then
            	FND_LOG.STRING(	FND_LOG.LEVEL_ERROR,
            				l_mod_name||'exc_exception',
            				'G_EXC_ERROR Exception');
        	END IF;

    	WHEN OTHERS THEN
        	ROLLBACK ;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	  		-- Add Unexpected Error to Message List, here SQLERRM is used for
	  		-- getting the error

            	FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'CSD_WIP_JOB_PVT',
                              		p_procedure_name => 'submit_jobs');
        	END IF;

        	FND_MSG_PUB.count_and_get( 	p_encoded 	=> FND_API.G_FALSE,
                               		p_count 	=> x_msg_count,
                               		p_data  	=> x_msg_data);

        	IF ( FND_LOG.LEVEL_EXCEPTION >= l_debug_level ) then
            	FND_LOG.STRING(	FND_LOG.LEVEL_EXCEPTION,
            				l_mod_name||'others_exception',
            				'OTHERS Exception');
        	END IF;

END submit_jobs;




-- This is the executable procedure for concurrent program
-- 'Depot Repair WIP Job Submission'. This program is submitted from
-- submit_jobs API.
-- This procedure submits WIP Mass Load, waits for it to complete successfully,
-- then calls the WIP_Update API to associate new records
-- created in csd_repair_job_xref table with corresponding newly
-- created wip_entity_ids.
-- This concurrent program is passed in group_id and repair_line_id as
-- parameters. If repair_line_id is null, then the WIP Update program is
-- run for all the eligible repair orders, otherwise the WIP Update porgram
-- is run for the specified repair_line_id.


procedure  submit_wip_mass_load_conc
(
	errbuf              OUT NOCOPY      VARCHAR2,
    	retcode             OUT NOCOPY      VARCHAR2,
    	p_group_id          IN              NUMBER,
    	p_repair_line_id    IN              NUMBER
)
IS

    	-- Declare the constants

    	l_api_version     CONSTANT NUMBER := 1.0;
    	l_procedure_name  CONSTANT VARCHAR2(30) := 'Submit_Wip_Mass_Load_Conc' ;

    	-- Used for standard concurrent progam parameter 'retcode' value
    	l_success         CONSTANT NUMBER := 0;
    	l_warning         CONSTANT NUMBER := 1;
    	l_error           CONSTANT NUMBER := 2;

    	-- Parameter to WIP Mass Load Concurrent program, specifying full validation
    	l_full_validation CONSTANT NUMBER := 0;

    	-- Concurrenr Request Id
    	l_req_id          NUMBER;

    	-- used for checking the success or failure of call to wait_for_request procedure
    	l_boolvar         BOOLEAN;

    	-- Concurrent Request Phase, status, message
    	l_phase           VARCHAR2(80);
    	l_status          VARCHAR2(80);
    	l_dev_phase       VARCHAR2(80);
    	l_dev_status      VARCHAR2(80);
    	l_message         VARCHAR2(255);

    	l_msg_count       NUMBER;
    	l_msg_data        VARCHAR2(2000);
    	l_return_status   VARCHAR2(1);

    	-- variables used for FND_LOG debug messages

    	l_debug_level                   NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    	l_stat_level                    NUMBER  := FND_LOG.LEVEL_STATEMENT;
    	l_proc_level                    NUMBER  := FND_LOG.LEVEL_PROCEDURE;
    	l_event_level                   NUMBER  := FND_LOG.LEVEL_EVENT;
    	l_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_wip_job_pvt.submit_wip_mass_load_conc.';




BEGIN

	IF ( l_proc_level >= l_debug_level ) then
        	FND_LOG.STRING( 	l_proc_level,
        				l_mod_name||'begin',
        				'Entering procedure submit_wip_mass_load_conc' );
    	END IF;


    	-- submit concurrent request for WIP Mass Load

    	-- argument3 specifies whether to print report or not, which when passed in as NULL
    	-- , defaults to the value of 'Yes'.
    	-- argument2 specifies the validation level for WIP Mass Load
    	-- argument1 is the group_id

    	l_req_id := fnd_request.submit_request (
     							application 	=> 	'WIP',
                  				program 		=> 	'WICMLP',
                  				description 	=> 	NULL,
                  				start_time 		=> 	NULL,
                  				sub_request 	=> 	FALSE,
                  				argument1 		=> 	TO_CHAR(p_group_id),
                  				argument2 		=> 	l_full_validation,
                  				argument3 		=> 	NULL );



    	-- If request submission fails, raise an error

    	IF (l_req_id = 0 ) THEN

	  	l_msg_data := FND_MESSAGE.GET_STRING('CSD','CSD_WICMLP_SUBMIT_FAILURE');
        	fnd_file.put_line(fnd_file.log, l_msg_data );

        	IF ( l_stat_level >= l_debug_level ) then
            	FND_LOG.STRING( 	l_stat_level,
            				l_mod_name||'requestfailure',
            				'WIP Mass Load Submit request failed' );
        	END IF;

        	Raise FND_API.G_EXC_UNEXPECTED_ERROR;

    	ELSE

        	COMMIT; --This commit is a must for the completion of the concurrent request submission

        	IF ( l_stat_level >= l_debug_level ) then
            	FND_LOG.STRING( 	l_stat_level,
            				l_mod_name||'beforewait',
            				'After commit and before wait for request' );
        	END IF;

        	-- wait for the execution result of WIP Mass Load

	 	-- Interval is specified in seconds and is the number of seconds to wait between checks,
	  	-- max_wait is also specified in seconds and will wait indefinitely, when specified as 0,
	  	-- dev_phase and dev_status are the developer versions of phase and status, which can be used
	  	-- for logic comparisons

        	l_boolvar:= fnd_concurrent.wait_for_request
                    (
                    request_id 	=> 	l_req_id,
                    interval 		=> 	15,
                    max_wait 		=> 	0,
                    phase 		=> 	l_phase,
                    status 		=> 	l_status,
                    dev_phase 	=> 	l_dev_phase,
                    dev_status 	=> 	l_dev_status,
                    message 		=> 	l_message);

        	-- If wait for WIP Mass Load request fails, raise an error

        	IF NOT l_boolvar THEN

	      	l_msg_data := FND_MESSAGE.GET_STRING('CSD','CSD_WICMLP_WAIT_FAILURE');
            	fnd_file.put_line(fnd_file.log, l_msg_data );


            	IF ( l_stat_level >= l_debug_level ) then
                		FND_LOG.STRING( 	l_stat_level,
                					l_mod_name||'waitfailure',
                					'Wait for request failed');
            	END IF;

            	Raise FND_API.G_EXC_UNEXPECTED_ERROR;


        	ELSIF (l_dev_phase = 'COMPLETE' AND l_dev_status = 'NORMAL') THEN

			-- WIP Mass Load completed successfully

            	IF ( l_event_level >= l_debug_level ) then
                		FND_LOG.STRING( 	l_event_level,
                					l_mod_name||'beforeupdatecall',
                					'Before Call to depot_wip_update');
            	END IF;


            	-- Call the WIP Update program

			-- When Repair Jobs are submitted to WIP Mass Load, a record is inserted into
			-- CSD_REPAIR_JOB_XREF for each combination of repair_line_id and repair Job.
			-- Once WIP Mass Load successfully completes, WIP_UPDATE API is called here to update
			-- the newly inserted records in CSD_REPAIR_JOB_XREF with the wip_entity_id of the
			-- corresponding jobs from WIP.

			-- Here p_upd_job_completion is specified as 'N'
			-- so that only the WIP Creation Update program is run, the WIP Completion Update program
			-- is not run in this case.

			-- If p_repair_line_id is passed in as NULL, then WIP_UPDATE is run for all the
			-- eligible repair_line_id values. When Repair Jobs are submitted for more than
			-- one repair order, then this is the case, that is, p_repair_line_id is null.

            	CSD_UPDATE_PROGRAMS_PVT.WIP_UPDATE
                	(   	p_api_version          => l_api_version,
                    	p_commit               => FND_API.G_TRUE,
                    	p_init_msg_list        => FND_API.G_TRUE,
                    	p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                    	x_return_status        => l_return_status,
                    	x_msg_count            => l_msg_count,
                    	x_msg_data             => l_msg_data,
                    	p_upd_job_completion   => 'N',
                    	p_repair_line_id       => p_repair_line_id );

            	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

		    		-- If return status is not success, write the error messages to
		    		-- the concurrent request log file and raise exception to exit

                		IF l_msg_count = 1 THEN

                    		fnd_file.put_line( fnd_file.log,l_msg_data);

                		ELSIF l_msg_count > 1 THEN

			  		-- If the message count is greater than 1, loop through the
			  		-- message list, retrieve the messages and write it to the log file

                    		FOR l_msg_ctr IN 1..l_msg_count
                    		LOOP
                        		l_msg_data := fnd_msg_pub.get(l_msg_ctr, FND_API.G_FALSE );
                        		fnd_file.put_line( fnd_file.log, l_msg_data);
                    		END LOOP;

                		END IF;

                		IF ( l_stat_level >= l_debug_level ) then
                    		FND_LOG.STRING( 	l_stat_level,
                    					l_mod_name||'updatecallerror',
                    					'CSD_UPDATE_PROGRAMS_PVT.WIP_UPDATE call returned error');
                		END IF;

                		Raise FND_API.G_EXC_UNEXPECTED_ERROR;

           	 	ELSE

		    		-- If return status is success, return concurrent program success code

                		errbuf   := '';
                		retcode := l_success;

            	END IF;


        	ELSE

			-- WIP Mass Load did not complete successfully, write error message to log file
			-- and raise exception to exit

	      	l_msg_data := FND_MESSAGE.GET_STRING('CSD','CSD_WICMLP_COMPLETION_FAILURE');
            	fnd_file.put_line(fnd_file.log,l_msg_data );

            	IF ( l_stat_level >= l_debug_level ) then
                		FND_LOG.STRING( 	l_stat_level,
                					l_mod_name||'completionfailure',
                					'WIP Mass Load did not Complete Successfully');
            	END IF;

            	Raise FND_API.G_EXC_UNEXPECTED_ERROR;

        	END IF;
    	END IF;

    	IF ( l_proc_level >= l_debug_level ) then
        	FND_LOG.STRING( 	l_proc_level,
        				l_mod_name||'end',
        				'Leaving procedure submit_wip_mass_load_conc');
    	END IF;


EXCEPTION


    	WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN

	  	-- write message to log file indicating the failure of the concurrent program,
	  	-- return error retcode

        	errbuf  := FND_MESSAGE.GET_STRING('CSD','CSD_CSDJSWIP_FAILURE');
        	retcode := l_error;

    	WHEN FND_API.G_EXC_ERROR THEN

	  	-- write message to log file indicating the failure of the concurrent program,
	  	-- return error retcode

        	errbuf  := FND_MESSAGE.GET_STRING('CSD','CSD_CSDJSWIP_FAILURE');
        	retcode := l_error;

    	WHEN OTHERS THEN

	  	-- Add Unexpected Error to Message List, here SQLERRM is used for
	  	-- getting the error

        	FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME ,
                                p_procedure_name => l_procedure_name );

	  	-- Get the count of the Messages from the message list, if the count is 1
	  	-- get the message as well

        	FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);

        	IF l_msg_count = 1 THEN

            	fnd_file.put_line( fnd_file.log, l_msg_data);

        	ELSIF l_msg_count > 1 THEN

		 	-- If the message count is greater than 1, loop through the
	       	-- message list, retrieve the messages and write it to the log file

            	FOR l_msg_ctr IN 1..l_msg_count
            	LOOP
                		l_msg_data := fnd_msg_pub.get(l_msg_ctr, FND_API.G_FALSE );
                		fnd_file.put_line( fnd_file.log, l_msg_data);
            	END LOOP;

        	END IF;

	  	-- write message to log file indicating the failure of the concurrent program,
	  	-- return error retcode

        	errbuf  := FND_MESSAGE.GET_STRING('CSD','CSD_CSDJSWIP_FAILURE');
        	retcode := l_error ;

        	IF ( FND_LOG.LEVEL_EXCEPTION >= l_debug_level ) then
            	FND_LOG.STRING(	FND_LOG.LEVEL_EXCEPTION,
            				l_mod_name||'others_exception',
            				'OTHERS Exception');
        	END IF;

end submit_wip_mass_load_conc;




-- This function checks if the discrete manufacturing patchset level is
-- at j or beyond and if so, returns true. For now, this is used from
-- Repair Jobs tab, when COMPLETE_JOB button is pressed. If the patchset level
-- is at j or beyond, then the new WIP Completion form is called, hence
-- new parameters are passed, If not, the old WIP Completion form is called, hence
-- the new parameters are not passed. The new parameters are wip_entity_id and
-- transaction_quantity which are used to default the WIP job information, when the
-- WIP Completion form opens.

FUNCTION is_dmf_patchset_level_j RETURN BOOLEAN IS
BEGIN
	IF (wip_constants.dmf_patchset_level >= wip_constants.dmf_patchset_j_value) THEN
        	RETURN TRUE;
    	ELSE
        	RETURN FALSE;
    	END IF;
END;

/***************
-- 12.1 create job from estimates -- subhat
-- This procedure creates WIP jobs from estimates tab. The procedure defaults the job header,
-- checks if the repair estimate has a routing associated, if so passes in the routing information
-- to the WIP API. When successfully finished, the procedure will return WIP Entity ID and Job Name
-- to the calling routine.
Code change history:
-- 4/2/2010 120.13.12010000.3 nnadig: Bug fix 9263438,
   Use wip_interface_s for interface_id instead of wip_job_schedule_interface_s
***************/
PROCEDURE create_job_from_estimate(
    p_api_version_number                    IN           NUMBER,
    p_init_msg_list                         IN           VARCHAR2 ,
    p_commit                                IN           VARCHAR2 ,
    p_validation_level                      IN           NUMBER,
    x_return_status                         OUT  NOCOPY  VARCHAR2,
    x_msg_count                             OUT  NOCOPY  NUMBER,
    x_msg_data                              OUT  NOCOPY  VARCHAR2,
    x_job_name                              OUT  NOCOPY  VARCHAR2,
	x_wip_entity_id							OUT  NOCOPY	 NUMBER,
    p_ESTM_JOB_DETLS_REC_TYPE			    IN           ESTM_JOB_DETLS_REC_TYPE
   ) IS

 -- Job Record to hold the Job header, bills and routing information being inserted
      -- into wip_job_schedule_interface

    l_job_header_rec                wip_job_schedule_interface%ROWTYPE;

     lc_api_name                CONSTANT VARCHAR2(30) := 'CREATE_WIP_JOB';
     lc_api_version_number      CONSTANT NUMBER := 1.0;

-- WIP Job Status Lookup Codes for Released and Unreleased status, --- The Lookup Type is WIP_JOB_STATUS

     lc_released_status_code     CONSTANT NUMBER :=  3;
     lc_unreleased_status_code   CONSTANT NUMBER :=  1;

         -- Non Standard Discrete Job Load Type
    lc_non_standard_load_type    CONSTANT NUMBER := 4;


      -- Constants used for FND_LOG debug messages

      lc_mod_name     CONSTANT      VARCHAR2(2000) := 'csd.plsql.csd_wip_job_pvt.create_job_from_estimate';



     l_user_id  NUMBER;
     l_repair_xref_id  NUMBER;
     l_rep_hist_id  NUMBER;

      l_job_prefix   VARCHAR2(80);
     -- l_wip_entity_id  NUMBER;



BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering Private API create_job_from_estimate');
      END IF;

-- Standard Start of API savepoint
     SAVEPOINT CREATE_WIP_JOB_PVT;
-- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call
           (lc_api_version_number,
            p_api_version_number,
            lc_api_name,
            G_PKG_NAME)
      THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status:=FND_API.G_RET_STS_SUCCESS;

-- initialize the job header rec.

l_job_header_rec.organization_id :=
              fnd_profile.value('CSD_DEF_REP_INV_ORG');

         IF l_job_header_rec.organization_id is NULL THEN

              FND_MESSAGE.SET_NAME('CSD','CSD_DEF_REP_INV_NULL');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
          END IF;


       l_job_prefix := fnd_profile.value('CSD_DEFAULT_JOB_PREFIX');

        --  If l_job_prefix is null, throw an error and return;


        IF l_job_prefix IS NULL THEN

              FND_MESSAGE.SET_NAME('CSD','CSD_JOB_PREFIX_NULL');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
        END IF;

         l_job_header_rec.class_code :=
              fnd_profile.value('CSD_DEF_WIP_ACCOUNTING_CLASS');

          IF l_job_header_rec.class_code is NULL THEN

              FND_MESSAGE.SET_NAME('CSD','CSD_CLASS_CODE_NULL');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

-- Assign the WIP Job Status lookup codes corresponding to Released -- and Unreleased Job status,
            -- to be passed for WIP Interface Table

        IF fnd_profile.value('CSD_DEFAULT_JOB_STATUS')   = 'RELEASED'  THEN

                  l_job_header_rec.status_type := lc_released_status_code ;

        ELSIF NVL( fnd_profile.value('CSD_DEFAULT_JOB_STATUS'), 'UNRELEASED' )   = 'UNRELEASED'  THEN

                  l_job_header_rec.status_type := lc_unreleased_status_code;
        END IF;


         l_job_header_rec.load_type := lc_non_standard_load_type;

      l_job_header_rec.first_unit_start_date := SYSDATE;
      l_job_header_rec.last_unit_completion_date := SYSDATE;

      l_job_header_rec.start_quantity := p_ESTM_JOB_DETLS_REC_TYPE.repair_quantity;

   -- If the profile CSD: Default WIP MRP Net Qty to Zero is set to
   -- null / 'N' then net_quantity = start_quantity else if the
   -- profile is set to 'Y' then net_quantity = 0
        IF ( nvl(fnd_profile.value('CSD_WIP_MRP_NET_QTY'),'N') = 'N' ) THEN
        l_job_header_rec.net_quantity := p_ESTM_JOB_DETLS_REC_TYPE.repair_quantity;
        ELSIF ( fnd_profile.value('CSD_WIP_MRP_NET_QTY') = 'Y' ) THEN
        l_job_header_rec.net_quantity := 0;
        END IF;


        l_job_header_rec.primary_item_id :=
           p_ESTM_JOB_DETLS_REC_TYPE.inventory_item_id ;


-- Get the Group_id to be used for WIP Create Job,

         SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_job_header_rec.group_id FROM dual;

         -- Bug 9263438: Use wip_interface_s for interface_id instead of wip_job_schedule_interface_s
         SELECT wip_interface_s.NEXTVAL INTO l_job_header_rec.interface_id FROM dual;


          generate_job_name  (      p_job_prefix       =>l_job_prefix,
                                        p_organization_id  => l_job_header_rec.organization_id,
                                        x_job_name         => l_job_header_rec.job_name );


          x_job_name := l_job_header_rec.job_name;

-- associate the projects integration parameters.

		l_job_header_rec.project_id := p_ESTM_JOB_DETLS_REC_TYPE.project_id;
		l_job_header_rec.task_id	:= p_ESTM_JOB_DETLS_REC_TYPE.task_id;
		l_job_header_rec.end_item_unit_number := p_ESTM_JOB_DETLS_REC_TYPE.unit_number;

-- check if the estimate has a routing associated with it. If so, associate the routing information.

	BEGIN
		SELECT assembly_item_id INTO l_job_header_rec.routing_reference_id
				FROM csd_repair_estimate cre,bom_operational_routings bor
				WHERE cre.repair_line_id = p_ESTM_JOB_DETLS_REC_TYPE.repair_line_id
				AND cre.routing_sequence_id = bor.routing_sequence_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL; -- do nothing. Routing information is not created for the job.
	END;

	IF l_job_header_rec.routing_reference_id IS NOT NULL THEN

		BEGIN
				SELECT completion_subinventory,
				       completion_locator_id
                       into	l_job_header_rec.completion_subinventory,
                       l_job_header_rec.completion_locator_id
                FROM
                       bom_operational_routings where
                       assembly_item_id = l_job_header_rec.routing_reference_id
					   and organization_id =  l_job_header_rec.organization_id
					   and nvl( alternate_routing_designator , -1 ) =
                       nvl( l_job_header_rec.alternate_routing_designator , -1) ;

				EXCEPTION
					WHEN NO_DATA_FOUND THEN
						NULL;
			END;
	END IF;

          IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsert',
                        'Just before calling insert_job_header');
          END IF;

-- Call procedure to insert job header and bills, routing
-- information
            -- into wip_job_schedule_interface table


            insert_job_header(   p_job_header_rec     =>
                                              l_job_header_rec,
                                    x_return_status      =>
                                             x_return_status );


              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;


      -- CALL WIP API to process records in wip interface table,
         --If API fails, Raise error, rollback and return

       -- Call WIP Mass Load API

               IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallcreateonejob',
                        'Just before calling WIP_MASSLOAD_PUB.createOneJob');
                    END IF;

                 WIP_MASSLOAD_PUB.createOneJob( p_interfaceID => l_job_header_rec.interface_id,--bug 9263438
                         p_validationLevel => p_validation_level,
                         x_wipEntityID => x_wip_entity_id,
                         x_returnStatus => x_return_status,
                         x_errorMsg     => x_msg_data );




                    If (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

                        ROLLBACK to CREATE_WIP_JOB_PVT ;
						RETURN;

                    END IF;
-- call procedures to insert a row in csd_repair_job_xref
        --  and csd_repair_history tables for the job created.

               L_user_id := fnd_global.user_id;

               IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallxrefwrite',
                        'Just before calling csd_to_form_repair_job_xref.validate_and_write');
               END IF;



             csd_to_form_repair_job_xref.validate_and_write(
                    p_api_version_number => lc_api_version_number,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_commit => FND_API.G_FALSE,
                    p_validation_level => NULL,
                    p_action_code => 0,
                    px_repair_job_xref_id => l_repair_xref_id,
                    p_created_by =>  l_user_id,
                    p_creation_date => SYSDATE,
                    p_last_updated_by => l_user_id,
                    p_last_update_date => SYSDATE,
                    p_last_update_login => l_user_id,
                    p_repair_line_id => p_ESTM_JOB_DETLS_REC_TYPE.repair_line_id,
                    p_wip_entity_id => x_wip_entity_id,
                    p_group_id => l_job_header_rec.group_id,
                    p_organization_id => l_job_header_rec.organization_id,
                    p_quantity => p_ESTM_JOB_DETLS_REC_TYPE.repair_quantity,
                    p_INVENTORY_ITEM_ID => l_job_header_rec.primary_item_id,
                    p_ITEM_REVISION =>  null,
                    p_OBJECT_VERSION_NUMBER => NULL,
                    p_attribute_category => NULL,
                    p_attribute1 => NULL,
                    p_attribute2 => NULL,
                    p_attribute3 => NULL,
                    p_attribute4 => NULL,
                    p_attribute5 => NULL,
                    p_attribute6 => NULL,
                    p_attribute7 => NULL,
                    p_attribute8 => NULL,
                    p_attribute9 => NULL,
                    p_attribute10 => NULL,
                    p_attribute11 => NULL,
                    p_attribute12 => NULL,
                    p_attribute13 => NULL,
                    p_attribute14 => NULL,
                    p_attribute15 => NULL,
                    p_quantity_completed => NULL,
                    p_job_name  =>  l_job_header_rec.job_name,
                    p_source_type_code  =>  'MANUAL',  -- bug fix 5763350
                    p_source_id1  =>  NULL,
                    p_ro_service_code_id  =>  NULL,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);


            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     ROLLBACK to CREATE_WIP_JOB_PVT ;

                     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING( FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
                  END IF;

                 RETURN;

                END IF;


               IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallhistwrite',
                        'Just before calling csd_to_form_repair_history.validate_and_write');
               END IF;



                csd_to_form_repair_history.validate_and_write(
                    p_api_version_number => lc_api_version_number,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_commit => FND_API.G_FALSE,
                    p_validation_level => NULL,
                    p_action_code => 0,
                    px_repair_history_id => l_rep_hist_id,
                    p_OBJECT_VERSION_NUMBER => NULL,
                    p_request_id => NULL,
                    p_program_id => NULL,
                    p_program_application_id => NULL,
                    p_program_update_date => NULL,
                    p_created_by =>  l_user_id,
                    p_creation_date => SYSDATE,
                    p_last_updated_by => l_user_id,
                    p_last_update_date => SYSDATE,
                    p_repair_line_id => p_ESTM_JOB_DETLS_REC_TYPE.repair_line_id,
                    p_event_code => 'JS',
                    p_event_date => SYSDATE,
                    p_quantity => p_ESTM_JOB_DETLS_REC_TYPE.repair_quantity,
                    p_paramn1 => x_wip_entity_id,
                    p_paramn2 => l_job_header_rec.organization_id,
                    p_paramn3 => NULL,
                    p_paramn4 => NULL,
                    p_paramn5 => p_ESTM_JOB_DETLS_REC_TYPE.repair_quantity,
                    p_paramn6 => NULL,
                    p_paramn8 => NULL,
                    p_paramn9 => NULL,
                    p_paramn10 => NULL,
                    p_paramc1 => l_job_header_rec.job_name,
                    p_paramc2 => NULL,
                    p_paramc3 => NULL,
                    p_paramc4 => NULL,
                    p_paramc5 => NULL,
                    p_paramc6 => NULL,
                    p_paramc7 => NULL,
                    p_paramc8 => NULL,
                    p_paramc9 => NULL,
                    p_paramc10 => NULL,
                    p_paramd1 => NULL ,
                    p_paramd2 => NULL ,
                    p_paramd3 => NULL ,
                    p_paramd4 => NULL ,
                    p_paramd5 => SYSDATE,
                    p_paramd6 => NULL ,
                    p_paramd7 => NULL ,
                    p_paramd8 => NULL ,
                    p_paramd9 => NULL ,
                    p_paramd10 => NULL ,
                    p_attribute_category => NULL ,
                    p_attribute1 => NULL ,
                    p_attribute2 => NULL ,
                    p_attribute3 => NULL ,
                    p_attribute4 => NULL ,
                    p_attribute5 => NULL ,
                    p_attribute6 => NULL ,
                    p_attribute7 => NULL ,
                    p_attribute8 => NULL ,
                    p_attribute9 => NULL ,
                    p_attribute10 => NULL ,
                    p_attribute11 => NULL ,
                    p_attribute12 => NULL ,
                    p_attribute13 => NULL ,
                    p_attribute14 => NULL ,
                    p_attribute15 => NULL ,
                    p_last_update_login  => l_user_id,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     ROLLBACK to CREATE_WIP_JOB_PVT ;

                    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING( FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
                 END IF;

                 RETURN;

               END IF;

-- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;


EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to CREATE_WIP_JOB_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to CREATE_WIP_JOB_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to CREATE_WIP_JOB_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;


END create_job_from_estimate;

-- This procedure creates the save materials transactions of HVR transactions package.
-- This procedure consolidates the eligible estimate lines to be transferred as the material
-- requirements. The material requirements are created but not issued.

PROCEDURE matrl_reqmnt_from_estms(
	p_api_version_number			IN  NUMBER,
	p_init_msg_list				IN  VARCHAR2,
	p_commit				IN  VARCHAR2,
	p_validation_level			IN  NUMBER,
	x_return_status				OUT NOCOPY VARCHAR2,
	x_msg_count				OUT NOCOPY NUMBER,
	x_msg_data				OUT NOCOPY VARCHAR2,
	x_op_created				OUT NOCOPY VARCHAR2,
	p_rep_line_id				IN  NUMBER,
	p_wip_entity_id				IN  NUMBER
	) IS

lc_mod_name VARCHAR2(200) := 'csd.plsql.csd_wip_job_pvt.create_matrl_reqmnt_from_estimates';

--table type to hold the material requirement line.

x_mtl_txn_dtls_tab_type CSD_HV_WIP_JOB_PVT.mtl_txn_dtls_tbl_type;


BEGIN

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering Private API create_job_from_estimate');
   END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

  --  Initialize API return status to success
      x_return_status:=FND_API.G_RET_STS_SUCCESS;

  -- get the material transactions table type

  import_estms_to_wipjob(p_rep_line_id,p_wip_entity_id,x_mtl_txn_dtls_tab_type);

  -- if the table type contains 1 or more records we will pass it to the
  -- hvr API to create the material requirements(we just create material requirements, we dont issue -- materials).

  IF x_mtl_txn_dtls_tab_type.COUNT >= 1 THEN

	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Calling HVR API to create material requirements');
   END IF;

	-- calling HVR api with the material requirments details.
	CSD_HV_WIP_JOB_PVT.PROCESS_SAVE_MTL_TXN_DTLS(p_api_version_number => 1.0,
						     p_init_msg_list      => p_init_msg_list,
						     p_commit		  => p_commit,
						     p_validation_level   => p_validation_level,
						     x_return_status	  => x_return_status,
						     x_msg_count	  => x_msg_count,
						     x_msg_data		  => x_msg_data,
						     p_mtl_txn_dtls_tbl	  => x_mtl_txn_dtls_tab_type,
						     x_op_created         => x_op_created);


	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE fnd_api.g_exc_error;
	END IF;
  END IF;
  COMMIT WORK;
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := fnd_api.G_RET_STS_ERROR;
		fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
					  p_count   => x_msg_count,
					  p_data    => x_msg_data );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
					  p_count   => x_msg_count,
					  p_data    => x_msg_data );
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
					  p_count   => x_msg_count,
					  p_data    => x_msg_data );
END matrl_reqmnt_from_estms;

END CSD_WIP_JOB_PVT;

/
