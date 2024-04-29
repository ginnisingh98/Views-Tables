--------------------------------------------------------
--  DDL for Package AMS_EVENTOFFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVENTOFFER_PVT" AUTHID CURRENT_USER as
/*$Header: amsvevos.pls 120.1 2006/04/18 09:27:13 anskumar noship $*/

TYPE evo_rec_type IS RECORD(
 EVENT_OFFER_ID            NUMBER,
 LAST_UPDATE_DATE          DATE,
 LAST_UPDATED_BY           NUMBER,
 CREATION_DATE             DATE,
 CREATED_BY                NUMBER,
 LAST_UPDATE_LOGIN         NUMBER,
 OBJECT_VERSION_NUMBER     NUMBER,
 APPLICATION_ID            NUMBER,
 EVENT_HEADER_ID           NUMBER,
 PRIVATE_FLAG              VARCHAR2(1),
 ACTIVE_FLAG               VARCHAR2(1),
 SOURCE_CODE               VARCHAR2(30),
 EVENT_LEVEL               VARCHAR2(30),
 USER_STATUS_ID            NUMBER,
 LAST_STATUS_DATE          DATE,
 SYSTEM_STATUS_CODE        VARCHAR2(30),
 EVENT_TYPE_CODE           VARCHAR2(30),
 EVENT_DELIVERY_METHOD_ID  NUMBER,
 -- note that delv_method_id not being currently used by offers API..
 -- but copy api will use this id to copy..
 EVENT_DELIVERY_METHOD_CODE VARCHAR2(30),
 EVENT_REQUIRED_FLAG	   VARCHAR2(1),
 EVENT_LANGUAGE_CODE       VARCHAR2(30),
 EVENT_LOCATION_ID         NUMBER,
 -- adding city,stste,country cols to evo_rec.. from create and update screens, these
 -- cols would be passed on.. wthese values will be passed to hz_loc api to create loc_id..
 -- these values will not be stored in event_offers table
 CITY						VARCHAR2(60),
 STATE						VARCHAR2(60),
 PROVINCE					VARCHAR2(60),
 COUNTRY					VARCHAR2(60),
 OVERFLOW_FLAG             VARCHAR2(1),
 PARTNER_FLAG              VARCHAR2(1),
 EVENT_STANDALONE_FLAG     VARCHAR2(1),
 REG_FROZEN_FLAG           VARCHAR2(1),
 REG_REQUIRED_FLAG         VARCHAR2(1),
 REG_CHARGE_FLAG           VARCHAR2(1),
 REG_INVITED_ONLY_FLAG     VARCHAR2(1),
 REG_WAITLIST_ALLOWED_FLAG VARCHAR2(1),
 REG_OVERBOOK_ALLOWED_FLAG VARCHAR2(1),
 PARENT_EVENT_OFFER_ID     NUMBER,
 EVENT_DURATION            NUMBER,
 EVENT_DURATION_UOM_CODE   VARCHAR2(3),
 EVENT_START_DATE          DATE,
 EVENT_START_DATE_TIME     DATE,
 EVENT_END_DATE            DATE,
 EVENT_END_DATE_TIME       DATE,
 REG_START_DATE            DATE,
 REG_START_TIME            DATE,
 REG_END_DATE              DATE,
 REG_END_TIME              DATE,
 REG_MAXIMUM_CAPACITY      NUMBER,
 REG_OVERBOOK_PCT          NUMBER,
 REG_EFFECTIVE_CAPACITY    NUMBER,
 REG_WAITLIST_PCT          NUMBER,
 REG_MINIMUM_CAPACITY      NUMBER,
 REG_MINIMUM_REQ_BY_DATE   DATE,
 INVENTORY_ITEM_ID		  NUMBER,
 INVENTORY_ITEM            VARCHAR2(1000),
 ORGANIZATION_ID		   NUMBER,
 PRICELIST_HEADER_ID       NUMBER,
 PRICELIST_LINE_ID         NUMBER,
 ORG_ID                    NUMBER,
 WAITLIST_ACTION_TYPE_CODE VARCHAR2(30),
 STREAM_TYPE_CODE          VARCHAR2(30),
 OWNER_USER_ID             NUMBER,
 EVENT_FULL_FLAG           VARCHAR2(1),
 FORECASTED_REVENUE        NUMBER,
 ACTUAL_REVENUE            NUMBER,
 FORECASTED_COST           NUMBER,
 ACTUAL_COST               NUMBER,
 FUND_SOURCE_TYPE_CODE     VARCHAR2(30),
 FUND_SOURCE_ID            NUMBER,
 CERT_CREDIT_TYPE_CODE     VARCHAR2(30),
 CERTIFICATION_CREDITS     NUMBER,
 COORDINATOR_ID            NUMBER,
 PRIORITY_TYPE_CODE        VARCHAR2(30),
 CANCELLATION_REASON_CODE  VARCHAR2(30),
 AUTO_REGISTER_FLAG        VARCHAR2(1),
 EMAIL					   VARCHAR2(120),
 PHONE                     VARCHAR2(25),
 FUND_AMOUNT_TC            NUMBER,
 FUND_AMOUNT_FC            NUMBER,
 CURRENCY_CODE_TC          VARCHAR2(15),
 CURRENCY_CODE_FC          VARCHAR2(15),
 URL                       VARCHAR2(4000),
 TIMEZONE_ID               NUMBER,
 EVENT_VENUE_ID			   NUMBER,
 PRICELIST_HEADER_CURRENCY_CODE VARCHAR2(30),
 PRICELIST_LIST_PRICE	   NUMBER,
 INBOUND_SCRIPT_NAME       VARCHAR2(240),
 ATTRIBUTE_CATEGORY        VARCHAR2(30),
 ATTRIBUTE1                VARCHAR2(150),
 ATTRIBUTE2                VARCHAR2(150),
 ATTRIBUTE3                VARCHAR2(150),
 ATTRIBUTE4                VARCHAR2(150),
 ATTRIBUTE5                VARCHAR2(150),
 ATTRIBUTE6                VARCHAR2(150),
 ATTRIBUTE7                VARCHAR2(150),
 ATTRIBUTE8                VARCHAR2(150),
 ATTRIBUTE9                VARCHAR2(150),
 ATTRIBUTE10               VARCHAR2(150),
 ATTRIBUTE11               VARCHAR2(150),
 ATTRIBUTE12               VARCHAR2(150),
 ATTRIBUTE13               VARCHAR2(150),
 ATTRIBUTE14               VARCHAR2(150),
 ATTRIBUTE15               VARCHAR2(150),
 EVENT_OFFER_NAME		   VARCHAR2(240),
 EVENT_MKTG_MESSAGE		   VARCHAR2(4000),
 DESCRIPTION			   VARCHAR2(4000),
 CUSTOM_SETUP_ID		   NUMBER,
 COUNTRY_CODE	           VARCHAR2(30),
 BUSINESS_UNIT_ID          NUMBER,
 EVENT_CALENDAR            VARCHAR2(15),
 START_PERIOD_NAME         VARCHAR2(15),
 END_PERIOD_NAME           VARCHAR2(15),
 GLOBAL_FLAG               VARCHAR2(1),
 TASK_ID                   NUMBER,  /* Hornet : */
 --PROGRAM_ID                NUMBER,  /* Hornet : */
 PARENT_TYPE               VARCHAR2(30),  /* Hornet : */
 PARENT_ID                 NUMBER  /* Hornet : */
,CREATE_ATTENDANT_LEAD_FLAG   VARCHAR2(1) /*hornet*/
,CREATE_REGISTRANT_LEAD_FLAG  VARCHAR2(1) /*hornet*/
,EVENT_OBJECT_TYPE	         VARCHAR2(30) /* Hornet : added by gdeodhar */
,REG_TIMEZONE_ID               NUMBER   /* HORnet */
,event_password               VARCHAR2(30)  /* Hornet : added for imeeting integration*/
,record_event_flag            VARCHAR2(1)   /* Hornet : added for imeeting integration*/
,allow_register_in_middle_flag VARCHAR2(1)  /* Hornet : added for imeeting integration*/
,publish_attendees_flag        VARCHAR2(1)  /* Hornet : added for imeeting integration*/
,direct_join_flag              VARCHAR2(1)  /* Hornet : added for imeeting integration*/
,event_notification_method     VARCHAR2(30)  /* Hornet : added for imeeting integration*/
,actual_start_time             DATE  /* Hornet : added for imeeting integration*/
,actual_end_time             DATE  /* Hornet : added for imeeting integration*/
,SERVER_ID             NUMBER  /* Hornet : added for imeeting integration*/
,owner_fnd_user_id     NUMBER  /* Hornet : added for imeeting integration  aug13*/
,meeting_dial_in_info  VARCHAR2(4000)  /* Hornet : added for imeeting integration aug13*/
,meeting_email_subject VARCHAR2(4000)  /* Hornet : added for imeeting integration  aug13*/
,meeting_schedule_type VARCHAR2(30)  /* Hornet : added for imeeting integration  aug13*/
,meeting_status        VARCHAR2(30)  /* Hornet : added for imeeting integration  aug13*/
,meeting_misc_info     VARCHAR2(4000)  /* Hornet : added for imeeting integration  aug13*/
,publish_flag          VARCHAR2(1)  /* Hornet : added for imeeting integration  aug13*/
,meeting_encryption_key_code VARCHAR2(150)  /* Hornet : added for imeeting integration  aug13*/
,number_of_attendees    NUMBER  /* Hornet : added for imeeting integration  aug13*/
,EVENT_PURPOSE_CODE           VARCHAR2(30) /* Hornet */
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_event_offer
--
-- PURPOSE
--    Create a new event offer or agenda item for the event offer.
--
-- PARAMETERS
--    p_evo_rec: the new record to be inserted
--    x_evo_id: return the event_offer_id of the new event offer
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If event_offer_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If event_offer_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------

PROCEDURE create_event_offer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   p_evo_rec           IN  evo_rec_type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   x_evo_id            OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_event_offer
--
-- PURPOSE
--    Delete an event offer.
--
-- PARAMETERS
--    p_evo_id: the event_offer_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE delete_event_offer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   p_evo_id            IN  NUMBER,
   p_object_version    IN  NUMBER,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);


-------------------------------------------------------------------
-- PROCEDURE
--    lock_event_offer
--
-- PURPOSE
--    Lock the event offer.
--
-- PARAMETERS
--    p_evo_id: the event_offer_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_event_offer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   p_evo_id            IN  NUMBER,
   p_object_version    IN  NUMBER,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_event_offer
--
-- PURPOSE
--    Update the event offer.
--
-- PARAMETERS
--    p_evo_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_event_offer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   p_evo_rec           IN  evo_rec_type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
   );


---------------------------------------------------------------------
-- PROCEDURE
--    validate_event_offer
--
-- PURPOSE
--    Validate the event offer record.
--
-- PARAMETERS
--    p_evo_rec: the event offer record to be validated
--
-- NOTES
--    1. p_evo_rec should be the complete event offer record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_event_offer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   p_evo_rec           IN  evo_rec_type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_evo_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_evo_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE check_evo_items(
   p_evo_rec         IN  evo_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_evo_record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_evo_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE check_evo_record(
   p_evo_rec          IN  evo_rec_type,
   p_complete_rec     IN  evo_rec_type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    init_evo_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_evo_rec(
   x_evo_rec         OUT NOCOPY  evo_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    complete_evo_rec
--
-- PURPOSE
--    For update_event_offer, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_evo_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE complete_evo_rec(
   p_evo_rec       IN  evo_rec_type,
   x_complete_rec  OUT NOCOPY evo_rec_type
);

PROCEDURE Unit_Test_Insert;

PROCEDURE fulfill_event_offer(
   p_evo_rec           IN  evo_rec_type,
   x_return_status     OUT NOCOPY VARCHAR2
);

END AMS_Eventoffer_PVT;

 

/
