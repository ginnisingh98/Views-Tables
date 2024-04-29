--------------------------------------------------------
--  DDL for Package EAM_ASSET_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_LOG_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVALGS.pls 120.7 2005/10/05 03:04:22 jamulu noship $ */
 -- Start of comments
 -- API name : EAM_ASSET_LOG_PVT.INSERT_ROW
 -- Type     : Private
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       P_api_version                 Required   Version Of The Api
 --          P_init_msg_list               Optional   Flag To Indicate Initialization Of Message List
 --             Default = Fnd_api.g_false
 --          P_commit                      Optional   Flag To Indicate Whether Api Should Commit Changes
 --             Default = Fnd_api.g_false
 --          P_validation_level            Optional   Flag To Indicate Validation Level
 --             Default = Fnd_api.g_valid_level_full
 --          P_event_date                  Optional   Indicates Event Date Of The Asset Log
 --             Default = Sysdate
 --          P_event_type                  Optional   Name Of Event Type Of The Asset Log Event
 --          P_event_id                    Optional   Event Id Which Gets Logged.
 --          P_organization_id             Optional   Organization Id Which Maintains The Asset
 --          P_instance_id                 Required   Asset Id Identifier Of The Asset Or Rebuildable.
 --          P_comments                    Optional   To Log Additional Information / Remarks About The Event On Which Log
 --                                                   Is Generated.
 --          P_reference                   Optional   Reference Number Of The Event Eg: Wo Number, Wr Number, Jo Number, Etc.
 --          P_ref_id                      Optional   Primary Key Identification Of The Reference.
 --          P_operable_flag               Optional   Status Of The Asset Or Rebuildable At The Time Of Event Log.
 --          P_reason_code                 Optional   Reason Code For Generation Of Event Log.
 --          P_resource_id                 Optional   Prime Identification Of The Resource Instance Attached To The Asset.
 --          P_equipment_gen_object_id     Optional   Identification Of The Osfm Resource Attached To The Asset.
 --          P_source_log_id               Optional   Identification Of The Transaction Where Logging Is Based On Resource Which
 --                                                   Got Multiple Assets Attached To It.
 --          P_instance_number             Optional   Asset Number / Asset Instance Number Identification
 --          P_downcode                    Optional   Resource Down Code Of Osfm Resource Attached To The Asset Which Generated The Asset Log
 --          P_expected_up_date            Optional   Expected Up Date Of An Osfm Resource At The Time Of Event Log.
 --          P_employee_id                 Optional   Identification Of The Employee In Osfm Who Creates The Event Log.
 --          P_department_id               Optional   Identification Of The Department Which Identifies This Asset As Resource.
 --          P_attribute_category          Optional   Dff Information
 --          P_attribute1                  Optional   Dff Information
 --          P_attribute2                  Optional   Dff Information
 --          P_attribute3                  Optional   Dff Information
 --          P_attribute4                  Optional   Dff Information
 --          P_attribute5                  Optional   Dff Information
 --          P_attribute6                  Optional   Dff Information
 --          P_attribute7                  Optional   Dff Information
 --          P_attribute8                  Optional   Dff Information
 --          P_attribute9                  Optional   Dff Information
 --          P_attribute10                 Optional   Dff Information
 --          P_attribute11                 Optional   Dff Information
 --          P_attribute12                 Optional   Dff Information
 --          P_attribute13                 Optional   Dff Information
 --          P_attribute14                 Optional   Dff Information
 --          P_attribute15                 Optional   Dff Information
 --          P_last_update_date            Required   Stadard Who Column Values
 --          P_last_updated_by             Required   Stadard Who Column Values
 --          P_creation_date               Required   Stadard Who Column Values
 --          P_created_by                  Required   Stadard Who Column Values
 --          P_last_update_login           Required   Stadard Who Column Values
 -- OUT      X_return_status               Required   Return Status Of The Procedure Call
 --          X_msg_count                   Required   Count Of The Return Messages That Api Returns
 --          X_msg_data                    Required   The Collection Of The Messages
 --
 -- End of comments

PROCEDURE insert_row(
             p_log_id                            IN   number    := NULL,
             p_api_version                       IN   number    := 1.0,
             p_init_msg_list                     IN   varchar2  := fnd_api.g_false,
             p_commit                            IN   varchar2  := fnd_api.g_false,
             p_validation_level                  IN   number    := fnd_api.g_valid_level_full,
             p_event_date                        IN   date      := sysdate,
             p_event_type                        IN   varchar2  := NULL,
             p_event_id                          IN   number    := NULL,
             p_organization_id                   IN   number    := NULL,
             p_instance_id                       IN   number,
             p_comments                          IN   varchar2  := NULL,
             p_reference                         IN   varchar2  := NULL,
             p_ref_id                            IN   number    := NULL,
             p_operable_flag                     IN   number    := NULL,
             p_reason_code                       IN   number    := NULL,
             p_resource_id                       IN   number    := NULL,
             p_equipment_gen_object_id           IN   number    := NULL,
             p_source_log_id                     IN   number    := NULL,
             p_instance_number                   IN   varchar2  := NULL,
             p_downcode                          IN   number    := NULL,
             p_expected_up_date                  IN   date      := NULL,
             p_employee_id                       IN   number    := NULL,
             p_department_id                     IN   number    := NULL,
             p_attribute_category                IN   varchar2  := NULL,
             p_attribute1                        IN   varchar2  := NULL,
             p_attribute2                        IN   varchar2  := NULL,
             p_attribute3                        IN   varchar2  := NULL,
             p_attribute4                        IN   varchar2  := NULL,
             p_attribute5                        IN   varchar2  := NULL,
             p_attribute6                        IN   varchar2  := NULL,
             p_attribute7                        IN   varchar2  := NULL,
             p_attribute8                        IN   varchar2  := NULL,
             p_attribute9                        IN   varchar2  := NULL,
             p_attribute10                       IN   varchar2  := NULL,
             p_attribute11                       IN   varchar2  := NULL,
             p_attribute12                       IN   varchar2  := NULL,
             p_attribute13                       IN   varchar2  := NULL,
             p_attribute14                       IN   varchar2  := NULL,
             p_attribute15                       IN   varchar2  := NULL,
             x_return_status             OUT NOCOPY   varchar2,
             x_msg_count                 OUT NOCOPY   number,
             x_msg_data                  OUT NOCOPY   varchar2);

 -- Start of comments
 -- API name : EAM_ASSET_LOG_PVT.VALIDATE_EVENT
 -- Type     : Private
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       P_api_version                 Required   Version Of The Api
 --          P_init_msg_list               Optional   Flag To Indicate Initialization Of Message List
 --             Default = Fnd_api.g_false
 --          P_commit                      Optional   Flag To Indicate Whether Api Should Commit Changes
 --             Default = Fnd_api.g_false
 --          P_validation_level            Optional   Flag To Indicate Validation Level
 --             Default = Fnd_api.g_valid_level_full
 --          P_event_date                  Optional   Indicates Event Date Of The Asset Log
 --             Default = Sysdate
 --          P_event_type                  Optional   Name Of Event Type Of The Asset Log Event
 --          P_event_id                    Optional   Event Id Which Gets Logged.
 --          P_instance_id                 Required   Asset Id Identifier Of The Asset Or Rebuildable.
 --          P_instance_number             Optional   Asset Number / Asset Instance Number Identification
 --          P_operable_flag               Optional   Status Of The Asset Or Rebuildable At The Time Of Event Log.
 --          P_reason_code                 Optional   Reason Code For Generation Of Event Log.
 --          P_resource_id                 Optional   Prime Identification Of The Resource Instance Attached To The Asset.
 --          P_downcode                    Optional   Resource Down Code Of Osfm Resource Attached To The Asset Which Generated The Asset Log
 --          P_expected_up_date            Optional   Expected Up Date Of An Osfm Resource At The Time Of Event Log.
 -- OUT      X_return_status               Required   Return Status Of The Procedure Call
 --          X_msg_count                   Required   Count Of The Return Messages That Api Returns
 --          X_msg_data                    Required   The Collection Of The Messages
 --
 -- End of comments

PROCEDURE validate_event(
             p_api_version                       IN   number    := 1.0,
             p_init_msg_list                     IN   varchar2  := fnd_api.g_false,
             p_commit                            IN   varchar2  := fnd_api.g_false,
             p_validation_level                  IN   number    := fnd_api.g_valid_level_full,
             p_event_date                        IN   date      := sysdate,
             p_event_type                        IN   varchar2  := NULL,
             p_event_id                          IN   number    := NULL,
             p_instance_id                       IN   number    := NULL,
             p_instance_number                   IN   varchar2  := NULL,
             p_operable_flag                     IN   number    := NULL,
             p_reason_code                       IN   number    := NULL,
             p_resource_id                       IN   number    := NULL,
             p_equipment_gen_object_id           IN   number    := NULL,
             p_downcode                          IN   number    := NULL,
             p_expected_up_date                  IN   date      := NULL,
             x_return_status             OUT NOCOPY   varchar2,
             x_msg_count                 OUT NOCOPY   number,
             x_msg_data                  OUT NOCOPY   varchar2);

 -- Start of comments
 -- API name : EAM_ASSET_LOG_PVT.DELETE_ROW
 -- Type     : Private
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       P_start_date                  Required   Indicates Event Start Date Of The Asset Log To Purge
 --          P_end_date                    Required   Indicates Event End Date Of The Asset Log To Purge
 --          P_event_type                  Optional   Name Of Event Type Of The Asset Log Event
 --          P_instance_id                 Optional   Asset Instance Identification
 --          P_asset_group                 Optional   Asset Group Identification
 --          P_equipment_gen_object_id     Optional   Identification Of The Osfm Resource Attached To The Asset.
 --          P_resource_id                 Optional   Prime Identification Of The Resource Instance Attached To The Asset.
 --          P_organization_id             Optional   Organization Id Which Maintains The Asset
 -- OUT      Errbuf                        Required   Contains Error Message
 --          Retcode                       Required   Return Code To Identify The Event Status
 --
 -- End of comments

PROCEDURE delete_row(
             errbuf                        OUT NOCOPY   varchar2,
             retcode                       OUT NOCOPY   number,
             p_start_date                          IN   varchar2,
             p_end_date                            IN   varchar2,
             p_asset_group                         IN   number,
	     p_instance_id                         IN   number,
             p_event_type                          IN   varchar2,
             p_event_id                            IN   number,
             p_resource_id                         IN   number,
	     p_organization_id                     IN   number,
             p_equipment_gen_object_id             IN   number);

 -- Start of comments
 -- API name : EAM_ASSET_LOG_PVT.INSTANCE_UPDATE_EVENT
 -- Type     : Private
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       P_api_version                 Required   Version Of The Api
 --          P_init_msg_list               Optional   Flag To Indicate Initialization Of Message List
 --             Default = Fnd_api.g_false
 --          P_commit                      Optional   Flag To Indicate Whether Api Should Commit Changes
 --             Default = Fnd_api.g_false
 --          P_validation_level            Optional   Flag To Indicate Validation Level
 --             Default = Fnd_api.g_valid_level_full
 --          P_event_date                  Optional   Indicates Event Date Of The Asset Log
 --             Default = Sysdate
 --          P_event_type                  Optional   Name Of Event Type Of The Asset Log Event
 --          P_event_id                    Optional   Event Id Which Gets Logged.
 --          P_instance_id                 Required   Asset Id Identifier Of The Asset Or Rebuildable.
 --          P_ref_id                      Optional   Primary Key Identification Of The Reference.
 --          P_organization_id             Optional   Organization Id Which Maintains The Asset
 -- OUT      X_return_status               Required   Return Status Of The Procedure Call
 --          X_msg_count                   Required   Count Of The Return Messages That Api Returns
 --          X_msg_data                    Required   The Collection Of The Messages
 --
 -- End of comments

PROCEDURE instance_update_event(
             p_api_version                       IN   number    := 1.0,
             p_init_msg_list                     IN   varchar2  := fnd_api.g_false,
             p_commit                            IN   varchar2  := fnd_api.g_false,
             p_validation_level                  IN   number    := fnd_api.g_valid_level_full,
             p_event_date                        IN   date,
             p_event_type                        IN   varchar2  := 'EAM_SYSTEM_EVENTS',
             p_event_id                          IN   number    := NULL,
	     p_instance_id                       IN   number,
	     p_ref_id                            IN   number,
             p_organization_id                   IN   number    := NULL,
             x_return_status             OUT NOCOPY   varchar2,
             x_msg_count                 OUT NOCOPY   number,
             x_msg_data                  OUT NOCOPY   varchar2);

 -- API name : EAM_ASSET_LOG_PVT.INSERT_METER_LOG
 -- Type     : Private
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       P_api_version                 Required   Version Of The Api
 --          P_init_msg_list               Optional   Flag To Indicate Initialization Of Message List
 --             Default = Fnd_api.g_false
 --          P_commit                      Optional   Flag To Indicate Whether Api Should Commit Changes
 --             Default = Fnd_api.g_false
 --          P_validation_level            Optional   Flag To Indicate Validation Level
 --             Default = Fnd_api.g_valid_level_full
 --          P_event_date                  Optional   Indicates Event Date Of The Asset Log
 --             Default = Sysdate
 --          P_instance_id                 Required   Asset Id Identifier Of The Asset Or Rebuildable.
 --          P_ref_id                      Optional   Primary Key Identification Of The Reference.
 --          P_attribute_category          Optional   Dff Information
 --          P_attribute1                  Optional   Dff Information
 --          P_attribute2                  Optional   Dff Information
 --          P_attribute3                  Optional   Dff Information
 --          P_attribute4                  Optional   Dff Information
 --          P_attribute5                  Optional   Dff Information
 --          P_attribute6                  Optional   Dff Information
 --          P_attribute7                  Optional   Dff Information
 --          P_attribute8                  Optional   Dff Information
 --          P_attribute9                  Optional   Dff Information
 --          P_attribute10                 Optional   Dff Information
 --          P_attribute11                 Optional   Dff Information
 --          P_attribute12                 Optional   Dff Information
 --          P_attribute13                 Optional   Dff Information
 --          P_attribute14                 Optional   Dff Information
 --          P_attribute15                 Optional   Dff Information
 -- OUT      X_return_status               Required   Return Status Of The Procedure Call
 --          X_msg_count                   Required   Count Of The Return Messages That Api Returns
 --          X_msg_data                    Required   The Collection Of The Messages
 --
 -- End of comments

PROCEDURE insert_meter_log(
             p_api_version                       IN   number    := 1.0,
             p_init_msg_list                     IN   varchar2  := fnd_api.g_false,
             p_commit                            IN   varchar2  := fnd_api.g_false,
             p_validation_level                  IN   number    := fnd_api.g_valid_level_full,
             p_event_date                        IN   date      := sysdate,
             p_instance_id                       IN   number    := NULL,
             p_ref_id                            IN   number,
             p_attribute_category                IN   varchar2  := NULL,
             p_attribute1                        IN   varchar2  := NULL,
             p_attribute2                        IN   varchar2  := NULL,
             p_attribute3                        IN   varchar2  := NULL,
             p_attribute4                        IN   varchar2  := NULL,
             p_attribute5                        IN   varchar2  := NULL,
             p_attribute6                        IN   varchar2  := NULL,
             p_attribute7                        IN   varchar2  := NULL,
             p_attribute8                        IN   varchar2  := NULL,
             p_attribute9                        IN   varchar2  := NULL,
             p_attribute10                       IN   varchar2  := NULL,
             p_attribute11                       IN   varchar2  := NULL,
             p_attribute12                       IN   varchar2  := NULL,
             p_attribute13                       IN   varchar2  := NULL,
             p_attribute14                       IN   varchar2  := NULL,
             p_attribute15                       IN   varchar2  := NULL,
             x_return_status             OUT NOCOPY   varchar2,
             x_msg_count                 OUT NOCOPY   number,
             x_msg_data                  OUT NOCOPY   varchar2);

END EAM_ASSET_LOG_PVT;

 

/
