--------------------------------------------------------
--  DDL for Package CSD_WIP_JOB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_WIP_JOB_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvwjbs.pls 120.5.12010000.2 2010/04/18 18:54:34 subhat ship $ */
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


-- Record Type for job header information

TYPE JOB_HEADER_REC_TYPE IS RECORD   (
JOB_PREFIX                                         VARCHAR2(80),
ORGANIZATION_ID                                    NUMBER,
STATUS_type                                        NUMBER,
SCHEDULED_START_DATE                               DATE,
SCHEDULED_END_DATE                                 DATE,
INVENTORY_ITEM_ID                                  NUMBER,
CLASS_CODE                                         VARCHAR2(10),
QUANTITY                                           NUMBER,
-- rfieldma, project integration, new parameters project_id, task_id, unit_number
PROJECT_ID								 NUMBER := null, --CSD_PROCESS_UTIL.G_MISS_NUM,        -- rfieldma, default?
TASK_ID									 NUMBER := null, --CSD_PROCESS_UTIL.G_MISS_NUM,        -- rfieldma, default?
UNIT_NUMBER								 VARCHAR2(30) := null --CSD_PROCESS_UTIL.G_MISS_CHAR  -- rfieldma, default?
);


-- Record Type for bills and routings information. This also has
-- source_type and source information

TYPE JOB_BILL_ROUTING_REC_TYPE IS RECORD (
routing_reference_id                               NUMBER,
bom_reference_id                                   NUMBER,
alternate_routing_designator                       VARCHAR2(10),
alternate_bom_designator                           VARCHAR2(10),
COMPLETION_SUBINVENTORY                            VARCHAR2(10),
COMPLETION_LOCATOR_ID                              NUMBER,
JOB_NAME                                           VARCHAR2(240),
source_type_code                                   VARCHAR2(30),
source_id1                                         NUMBER,
ro_service_code_id                                 NUMBER,
group_id                                           NUMBER := NULL
);


-- Table Type corresponding to JOB_BILL_ROUTING_REC_TYPE

TYPE  JOB_BILL_ROUTING_TBL_TYPE IS TABLE OF JOB_BILL_ROUTING_REC_TYPE  INDEX BY BINARY_INTEGER;

--12.1 create job from repair estimate tab, subhat.
-- Record type for having the UI details from the estimates tab. This also consists project --integration information

TYPE ESTM_JOB_DETLS_REC_TYPE IS RECORD (
	repair_line_id			     NUMBER,
	inventory_item_id             NUMBER,
	repair_quantity			NUMBER,
	project_id				NUMBER,
	task_id					NUMBER,
    --bug#6930575,subhat
    --unit_number                  NUMBER
	unit_number			     VARCHAR2(30)
	);


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
--  p_repair_line_id - 	  	  Repair Line Id of the repair order for which the jobs are being created.
--					  WIP Update program is run for the specified repair order.
--                      	  If jobs are being submitted for more than one repair order, then this is
--                              passed in as null and the WIP Update program is run for all the eligible
--				        repair orders.
--  p_job_header_rec - 	  	  Job header Information record. This is the same for all the jobs being created.
--  p_x_job_bill_routing_tbl -  Table of Bill and Routing information records. Each record results in a
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
    	p_api_version                       IN     		NUMBER,
    	p_init_msg_list                     IN     		VARCHAR2 := FND_API.G_FALSE,
    	p_validation_level                  IN     		NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    	x_return_status		          	OUT  	NOCOPY  	VARCHAR2,
    	x_msg_count		                	OUT 	NOCOPY   	NUMBER,
    	x_msg_data		                	OUT 	NOCOPY   	VARCHAR2,
    	p_repair_line_id                    IN 			NUMBER,
    	p_job_header_rec                    IN 			job_header_rec_type,
    	p_x_job_bill_routing_tbl	    	IN OUT NOCOPY	job_bill_routing_tbl_type,
    	x_group_id                          OUT  	NOCOPY  	NUMBER,
    	x_request_id                  	OUT  	NOCOPY  	NUMBER
);



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
);


-- This function checks if the discrete manufacturing patchset level is
-- at j or beyond and if so, returns true. For now, this is used from
-- Repair Jobs tab, when COMPLETE_JOB button is pressed. If the patchset level
-- is at j or beyond, then the new WIP Completion form is called, hence
-- new parameters are passed, If not, the old WIP Completion form is called, hence
-- the new parameters are not passed. The new parameters are wip_entity_id and
-- transaction_quantity which are used to default the WIP job information, when the
-- WIP Completion form opens.

FUNCTION is_dmf_patchset_level_j RETURN BOOLEAN;

-- This procedure creates WIP job, when the create job process is invoked from repair estimate tab.
-- the procedure defaults all the required job header information from the profile values.
-- This procedure inserts the job information into WIP interface table, and the WIP api picks up from
-- interface table to create the job. This is the new feature in 12.1 subhat

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
	p_ESTM_JOB_DETLS_REC_TYPE			IN           ESTM_JOB_DETLS_REC_TYPE
   );

  -- This procedure creates the material requirements for the job using the material estimate lines.
  -- the procedure is invoked after a job is successfuly completed. This procedure inturn calls one -- more routine to get the material requirements table type.
  -- 12.1 Create Job from estimate function subhat.

 PROCEDURE matrl_reqmnt_from_estms(
	p_api_version_number			IN	NUMBER,
	p_init_msg_list					IN  VARCHAR2,
	p_commit						IN  VARCHAR2,
	p_validation_level				IN  NUMBER,
	x_return_status					OUT NOCOPY VARCHAR2,
	x_msg_count						OUT NOCOPY NUMBER,
	x_msg_data						OUT NOCOPY VARCHAR2,
	x_op_created					OUT NOCOPY VARCHAR2,
	p_rep_line_id					IN	NUMBER,
	p_wip_entity_id					IN	NUMBER
	);

-- 12.1.3 changes, subhat.
-- Exposing this API. This is for the use of internal depot dev team only. No other use is supported.
-- This procedure generates a job name by appending a sequence generated number
-- to the passed in Job_Prefix
-- It Validates that the generated job name is unique for the specified organization,
-- It keeps looping and appending the subsequent sequence generated number, till a
-- unique Job name is generated


PROCEDURE generate_job_name
(
    	p_job_prefix 	        	IN  		VARCHAR2,
    	p_organization_id          	IN  		NUMBER,
    	x_job_name                  OUT NOCOPY 	VARCHAR2
);

END CSD_WIP_JOB_PVT;

/
