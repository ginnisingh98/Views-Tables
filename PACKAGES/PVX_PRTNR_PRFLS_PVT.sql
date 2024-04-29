--------------------------------------------------------
--  DDL for Package PVX_PRTNR_PRFLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_PRTNR_PRFLS_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvppfs.pls 115.15 2003/07/15 08:13:34 nramu ship $ */

TYPE prtnr_prfls_rec_type IS RECORD
(
 partner_profile_id             number
,last_update_date               date
,last_updated_by                number
,creation_date                  date
,created_by                     number
,last_update_login              number
,object_version_number          number
,partner_id			            number
,target_revenue_amt		        number
,actual_revenue_amt		        number
,target_revenue_pct		        number
,actual_revenue_pct		        number
,orig_system_reference	        varchar2(240)
,orig_system_type               varchar2(30)
,capacity_size                  varchar2(30)
,capacity_amount                varchar2(30)
,auto_match_allowed_flag        varchar2(1)
,purchase_method                varchar2(30)
,cm_id				            number
,ph_support_rep			        number
--,security_group_id		        number
,lead_sharing_status            varchar2(30)
,lead_share_appr_flag           varchar2(1)
,partner_relationship_id   	    number
,partner_level       		    varchar2(30)
,preferred_vad_id    		    number
,partner_group_id               number
,partner_resource_id            number
,partner_group_number           varchar2(30)
,partner_resource_number        varchar2(30)
,sales_partner_flag             varchar2(1)
,indirectly_managed_flag        varchar2(1)
,channel_marketing_manager      number
,related_partner_id             number
,max_users                      number
,partner_party_id		number
,status                         varchar2(1)
);


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Prtnr_Prfls
--
-- PURPOSE
--    Create a new Partner Profile Record
--
-- PARAMETERS
--    p_prtnr_prfls_rec: the new record to be inserted
--    x_partner_profile_id: return the partner_profile_id of the new record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If partner_profile_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If partner_profile_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_Prtnr_Prfls(
   p_api_version        IN  NUMBER
  ,p_init_msg_list      IN  VARCHAR2 := FND_API.g_false
  ,p_commit             IN  VARCHAR2 := FND_API.g_false
  ,p_validation_level   IN  NUMBER   := FND_API.g_valid_level_full

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2

  ,p_prtnr_prfls_rec    IN  prtnr_prfls_rec_type
  ,x_partner_profile_id OUT NOCOPY NUMBER
  );


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Prtnr_Prfls
--
-- PURPOSE
--    Delete a prtnr_prfls.
--
-- PARAMETERS
--    p_partner_profile_id: the partner_profile_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Prtnr_Prfls(
   p_api_version        IN  NUMBER
  ,p_init_msg_list      IN  VARCHAR2 := FND_API.g_false
  ,p_commit             IN  VARCHAR2 := FND_API.g_false

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2

  ,p_partner_profile_id IN  NUMBER
  ,p_object_version     IN  NUMBER
  );


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_Prtnr_Prfls
--
-- PURPOSE
--    Lock a  prtnr_prfls.
--
-- PARAMETERS
--    p_partner_profile_id:
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_Prtnr_Prfls(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2

  ,p_partner_profile_id IN  NUMBER
  ,p_object_version     IN  NUMBER
  );


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Prtnr_Prfls
--
-- PURPOSE
--    Update a  prtnr_prfls.
--
-- PARAMETERS
--    p_prtnr_prfls_rec: the record with new items.
--    p_mode    : determines what sort of validation is to be performed during update.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_Prtnr_Prfls(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false
  ,p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_prtnr_prfls_rec   IN  prtnr_prfls_rec_type
  );


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Prtnr_Prfls
--
-- PURPOSE
--    Validate a prtnr_prfls record.
--
-- PARAMETERS
--    p_prtnr_prfls_rec: the  record to be validated
--
-- NOTES
--    1. p_prtnr_prfls_rec should be the complete  record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Validate_Prtnr_Prfls(
   p_api_version      IN  NUMBER
  ,p_init_msg_list    IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2

  ,p_prtnr_prfls_rec  IN  prtnr_prfls_rec_type
  );


---------------------------------------------------------------------
-- PROCEDURE
--    Check_prtnr_prfls_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_prtnr_prfls_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Prtnr_Prfls_Items(
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2
  ,p_prtnr_prfls_rec IN  prtnr_prfls_rec_type
  );


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Prtnr_Prfls_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_prtnr_prfls_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_Prtnr_Prfls_Record(
   p_prtnr_prfls_rec IN  prtnr_prfls_rec_type
  ,p_complete_rec    IN  prtnr_prfls_rec_type := NULL
  ,p_mode            IN  VARCHAR2 := 'INSERT'
  ,x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Prtnr_Prfls_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_Prtnr_Prfls_Rec(
   x_prtnr_prfls_rec OUT NOCOPY  prtnr_prfls_rec_type
  );


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Prtnr_Prfls_Rec
--
-- PURPOSE
--    For update, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_prtnr_prfls_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Prtnr_Prfls_Rec(
   p_prtnr_prfls_rec IN  prtnr_prfls_rec_type
  ,x_complete_rec    OUT NOCOPY prtnr_prfls_rec_type
  );

---------------------------------------------------------------------
-- PROCEDURE
--    Determine_Partner_Status
--
---------------------------------------------------------------------
  PROCEDURE Determine_Partner_Status(
    p_prtnr_prfls_rec   IN  prtnr_prfls_rec_type
   ,x_partner_status   OUT NOCOPY VARCHAR2
  );


END PVX_PRTNR_PRFLS_PVT;

 

/
