--------------------------------------------------------
--  DDL for Package EAM_ASSET_LOG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_LOG_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPALGS.pls 120.2 2006/10/05 06:05:59 kmurthy noship $ */
/*
 * This package is used for the Logging Asset Events.
 * It defines a procedure log_event which first validates and massages the
 * IN parameters and then carries out the respective operations.
 */

/*
--      API name        : LOG_EVENT
--      Type            : Public
--      Function        : log_event and validate_event of the asset log data
--      Pre-reqs        : None.
*/
        g_pkg_name         constant varchar2(30):='eam_asset_log_pub';

/* This procedure inserts a record in the eam_asset_log table
--      Parameters      :
--      IN              : p_api_version		IN	NUMBER       REQUIRED
--                        p_init_msg_list		IN	VARCHAR2     OPTIONAL
--                                     DEFAULT = FND_API.G_FALSE
--                        p_commit			IN	VARCHAR2     OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                        p_validation_level		IN	NUMBER	     OPTIONAL
--                                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--                        p_event_date			IN	DATE
--                        p_event_type			IN	VARCHAR2
--                        p_event_id			IN	NUMBER
--                        p_instance_id		IN	NUMBER
--                        p_asset_number		IN	VARCHAR2
--                        p_comments			IN	VARCHAR2
--                        p_reference			IN	VARCHAR2
--                        p_ref_id			IN	VARCHAR2
--                        p_operable_flag		IN	NUMBER
--                        p_reason_code		IN	VARCHAR2
--                        p_equipment_gen_object_id	IN	NUMBER
--                        p_resource_id		IN	NUMBER
--                        p_down_code			IN	NUMBER
--                        p_expected_up_date		IN	DATE
--
--      OUT             :  x_return_status	OUT NOCOPY	VARCHAR2(1)
--                         x_msg_count		OUT NOCOPY	NUMBER
--                         x_msg_data		OUT NOCOPY	VARCHAR2 (2000)
--
--      Version :       Current version: 1.0
--                      Initial version: 1.0
--
--      Notes
--
-- End of comments
*/

/*
 * This procedure is used to insert records in to EAM_ASSET_LOG table.
 * It is used to create Asset Event Log.
 *  p_api_version		Version of the API
 *  p_init_msg_list	Flag to indicate initialization of message list
 *  p_commit		Flag to indicate whether API should commit changes
 *  p_validation_level	Validation Level of the API
 *  x_return_status	Return status of the procedure call
 *  x_msg_count		Count of the return messages that API returns
 *  x_msg_data		The collection of the messages
 *  p_event_date		Indicates Event date of the Asset Log
 *  p_event_type		Name of Event Type of the Asset Log Event
 *  p_event_id		Event Id which gets logged.
 *  p_organization_id	Organization Id which maintains the asset.
 *  p_instance_id		Asset id identifier of the asset or rebuildable.
 *  p_instance_number	Asset Number / Asset Instance number identification
 *  p_comments		To log additional information / Remarks about the event on which log is generated.
 *  p_reference		Reference number of the event eg: WO Number, WR Number, JO Number, etc.
 *  p_ref_id		Primary Key identification of the reference.
 *  p_operable_flag	Status of the Asset or Rebuildable at the time of Event Log.
 *  p_reason_code		Reason Code for generation of Event Log.
 *  p_equipment_gen_object_id	Identification of the OSFM resource attached to the asset.
 *  p_resource_id		Prime Identification of the resource Instance attached to the asset.
 *  p_downcode		Resource down code of OSFM resource attached to the asset which generated the Asset Log.
 *  p_employee_id		Identification of the Employee in OSFM who creates the Event Log.
 *  p_department_id	Identification of the Department which identifies this asset as Resource.
 *  p_expected_up_date	Expected Up date of an OSFM resource at the time of Event Log.
 *  return			Returns the newly created Primary Key for the record inserted
 */


PROCEDURE LOG_EVENT(
		p_api_version			IN	number		:= 1.0,
		p_init_msg_list			IN      varchar2	:= fnd_api.g_false,
		p_commit			IN      varchar2	:= fnd_api.g_false,
		p_validation_level		IN      number		:= fnd_api.g_valid_level_full,
		p_event_date			IN      date		:= sysdate,
		p_event_type			IN      varchar2,
		p_event_id			IN      number,
		p_organization_id		IN	number		:= null,
		p_instance_id			IN      number		:= null,
		p_instance_number		IN      varchar2	:= null,
		p_comments			IN      varchar2	:= null,
		p_reference			IN      varchar2	:= null,
		p_ref_id			IN      number,
		p_operable_flag			IN      number		:= null,
		p_reason_code			IN      number		:= null,
		p_equipment_gen_object_id	IN      number		:= null,
		p_resource_id			IN      number		:= null,
		p_downcode			IN      number		:= null,
		p_employee_id			IN      number		:= null,
		p_department_id			IN      number		:= null,
		p_expected_up_date		IN      date		:= null,
		x_return_status         OUT NOCOPY	varchar2,
		x_msg_count		OUT NOCOPY      number,
		x_msg_data		OUT NOCOPY      varchar2);

END EAM_ASSET_LOG_PUB;

 

/
