--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_OWNER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_OWNER" AUTHID CURRENT_USER AS
/* $Header: asxvslns.pls 115.5 2002/11/22 07:20:52 aanjaria ship $ */


TYPE lead_owner_rec_type IS RECORD
(
 LEAD_OWNER_ID	                NUMBER,
 CATEGORY                       VARCHAR2(30),
 COUNTRY			VARCHAR2(100),
 FROM_POSTAL_CODE		VARCHAR2(40),
 TO_POSTAL_CODE			VARCHAR2(40),
 CM_RESOURCE_ID		        NUMBER,
 REFERRAL_TYPE                  VARCHAR2(30),
 OWNER_FLAG                     VARCHAR2(1),
 LAST_UPDATE_DATE               DATE,
 LAST_UPDATED_BY                NUMBER,
 CREATION_DATE                  DATE,
 CREATED_BY                     NUMBER,
 LAST_UPDATE_LOGIN              NUMBER,
 OBJECT_VERSION_NUMBER          NUMBER,
 REQUEST_ID                     NUMBER,
 PROGRAM_APPLICATION_ID         NUMBER,
 PROGRAM_ID                     NUMBER,
 PROGRAM_UPDATE_DATE            DATE
);

type lead_owner_rec_tbl_type is TABLE OF lead_owner_rec_type;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Lead_Owner
--
-- PURPOSE
--    Create a new mdf owner record
--
-- PARAMETERS
--    p_lead_owner_rec   : the new record to be inserted
--    x_lead_owner_id    : return the LEAD_OWNER_id of the new record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If lead_owner_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If lead_owner_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_Lead_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_LEAD_OWNER_rec IN  LEAD_OWNER_rec_type
  ,x_LEAD_OWNER_id  OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Lead_Owner
--
-- PURPOSE
--    Delete a lead_owner_id.
--
-- PARAMETERS
--    p_lead_owner_id: the lead_owner_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Lead_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_LEAD_OWNER_id    IN  NUMBER
  ,p_object_version      IN  NUMBER

);

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Lead_Owner
--
-- PURPOSE
--    Update a  Lead_Owner.
--
-- PARAMETERS
--    p_lead_owner_rec: the record with new items.
--    p_mode    : determines what sort of validation is to be performed during update.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_Lead_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_LEAD_OWNER_rec     IN  LEAD_OWNER_rec_type

);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Salesreps
--
-- PURPOSE
--    Get the salesreps based on the country, postal code
--
-- PARAMETERS
--    p_lead_id : lead_id
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Get_Salesreps(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,p_sales_lead_id     IN  NUMBER
  ,x_salesreps_tbl     OUT NOCOPY lead_owner_rec_tbl_type

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Immatured_Lead_Owner
--
-- PURPOSE
--    Get the lead owner for matured lead
--
-- PARAMETERS
--    p_lead_id : lead_id
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--    3. Returns the saleforce id of the marketing owner
----------------------------------------------------------------------
PROCEDURE Get_Immatured_Lead_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,p_sales_lead_id     IN  NUMBER
  ,x_salesforce_id     OUT NOCOPY NUMBER

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
);

END AS_SALES_LEAD_OWNER;

 

/
