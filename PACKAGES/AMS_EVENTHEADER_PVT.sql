--------------------------------------------------------
--  DDL for Package AMS_EVENTHEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVENTHEADER_PVT" AUTHID CURRENT_USER as
/* $Header: amsvevhs.pls 115.20 2002/11/22 23:37:01 dbiswas ship $ */

TYPE evh_rec_type IS RECORD(
	event_header_id             NUMBER
	,last_update_date            DATE
	,last_updated_by             NUMBER
	,creation_date               DATE
	,created_by                  NUMBER
	,last_update_login           NUMBER
	,object_version_number       NUMBER
	,event_level                 VARCHAR2(30)
	,application_id              NUMBER
	,event_type_code             VARCHAR2(30)
	,active_flag                 VARCHAR2(1)
	,private_flag                VARCHAR2(1)
	,user_status_id              NUMBER
	,system_status_code          VARCHAR2(30)
	,last_status_date            DATE
	,stream_type_code            VARCHAR2(30)
	,source_code                 VARCHAR2(30)
	,event_standalone_flag       VARCHAR2(1)
	,day_of_event                VARCHAR2(30)
	,agenda_start_time           DATE
	,agenda_end_time             DATE
	,reg_required_flag           VARCHAR2(1)
	,reg_charge_flag             VARCHAR2(1)
	,reg_invited_only_flag       VARCHAR2(1)
	,partner_flag                VARCHAR2(1)
	,overflow_flag               VARCHAR2(1)
	,parent_event_header_id      NUMBER
	,duration                    NUMBER
	,duration_uom_code           VARCHAR2(3)
	,active_from_date            DATE
	,active_to_date              DATE
	,reg_maximum_capacity        NUMBER
	,reg_minimum_capacity        NUMBER
	,main_language_code          VARCHAR2(4)
	,cert_credit_type_code       VARCHAR2(30)
	,certification_credits       NUMBER
	,inventory_item_id           NUMBER
	,organization_id             NUMBER
	,org_id                      NUMBER
	,forecasted_revenue          NUMBER
	,actual_revenue              NUMBER
	,forecasted_cost             NUMBER
	,actual_cost                 NUMBER
	,coordinator_id              NUMBER
	,fund_source_type_code       VARCHAR2(30)
	,fund_source_id              NUMBER
	,fund_amount_tc              NUMBER
	,fund_amount_fc              NUMBER
    ,currency_code_tc			 VARCHAR2(30)
    ,currency_code_fc			 VARCHAR2(30)
	,owner_user_id               NUMBER
	,url                         VARCHAR2(4000)
	,email                       VARCHAR2(120)
	,phone                       VARCHAR2(25)
	,priority_type_code          VARCHAR2(30)
	,cancellation_reason_code    VARCHAR2(30)
	,inbound_script_name         VARCHAR2(240)
	,attribute_category          VARCHAR2(30)
	,attribute1                  VARCHAR2(150)
	,attribute2                  VARCHAR2(150)
	,attribute3                  VARCHAR2(150)
	,attribute4                  VARCHAR2(150)
	,attribute5                  VARCHAR2(150)
	,attribute6                  VARCHAR2(150)
	,attribute7                  VARCHAR2(150)
	,attribute8                  VARCHAR2(150)
	,attribute9                  VARCHAR2(150)
	,attribute10                 VARCHAR2(150)
	,attribute11                 VARCHAR2(150)
	,attribute12                 VARCHAR2(150)
	,attribute13                 VARCHAR2(150)
	,attribute14                 VARCHAR2(150)
	,attribute15                 VARCHAR2(150)
   	,event_header_name           VARCHAR2(240)
   	,event_mktg_message          VARCHAR2(4000)
   	,description                 VARCHAR2(4000)
    ,custom_setup_id             NUMBER
    ,country_code	             VARCHAR2(30)
    ,business_unit_id            NUMBER
	,event_calendar				 VARCHAR2(15)
	,start_period_name           VARCHAR2(15)
	,end_period_name             VARCHAR2(15)
	,global_flag                 VARCHAR2(1)
	,task_id                     NUMBER
	,program_id                  NUMBER
	,CREATE_ATTENDANT_LEAD_FLAG   VARCHAR2(1) /*hornet*/
	,CREATE_REGISTRANT_LEAD_FLAG  VARCHAR2(1) /*hornet*/
	,EVENT_PURPOSE_CODE           VARCHAR2(30) /*hornet*/
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_event_header
--
-- PURPOSE
--    Create a new event header or agenda item for the event header.
--
-- PARAMETERS
--    p_evh_rec: the new record to be inserted
--    x_evh_id: return the event_header_id of the new event header
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If event_header_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If event_header_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_miss_char/num/date.
---------------------------------------------------------------------

PROCEDURE create_event_header(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_rec           IN  evh_rec_type,
   x_evh_id            OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_event_header
--
-- PURPOSE
--    Delete an event header.
--
-- PARAMETERS
--    p_evh_id: the event_header_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE delete_event_header(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_id            IN  NUMBER,
   p_object_version    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    lock_event_header
--
-- PURPOSE
--    Lock the event header.
--
-- PARAMETERS
--    p_evh_id: the event_header_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_event_header(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_id            IN  NUMBER,
   p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_event_header
--
-- PURPOSE
--    Update the event header.
--
-- PARAMETERS
--    p_evh_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_event_header(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_rec           IN  evh_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    validate_event_header
--
-- PURPOSE
--    Validate the event header record.
--
-- PARAMETERS
--    p_evh_rec: the event header record to be validated
--
-- NOTES
--    1. p_evh_rec should be the complete event header record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_event_header(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_rec           IN  evh_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_evh_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE check_evh_items(
   p_evh_rec         IN  evh_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_evh_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE check_evh_record(
   p_evh_rec          IN  evh_rec_type,
   p_complete_rec     IN  evh_rec_type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    init_evh_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_evh_rec(
   x_evh_rec         OUT NOCOPY  evh_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    complete_evh_rec
--
-- PURPOSE
--    For update_event_header, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_evh_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE complete_evh_rec(
   p_evh_rec       IN  evh_rec_type,
   x_complete_rec  OUT NOCOPY evh_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_inter_entity
--
-- PURPOSE
--    Check the inter-entity level business rules.
--
-- PARAMETERS
--    p_evh_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE check_evh_inter_entity(
   p_evh_rec        IN  evh_rec_type,
   p_complete_rec    IN  evh_rec_type,
   p_validation_mode IN  VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);



END AMS_EventHeader_PVT;

 

/
