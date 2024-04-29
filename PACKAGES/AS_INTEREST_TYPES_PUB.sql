--------------------------------------------------------
--  DDL for Package AS_INTEREST_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_INTEREST_TYPES_PUB" AUTHID CURRENT_USER as
/* $Header: asxintys.pls 115.5 2003/10/10 08:58:13 gbatra ship $ */
--
-- Package Name : AS_INTEREST_TYPES_PUB
-- Purpose : Public API to Create and Update Interest Types in the Oracle
--           Sales Online.
--
-- History
--
--   09/12/2002    Rajan T          Created
--

-- Start of Comments
-- Record Name      : interest_type_rec_type
-- Type             : Global
-- End of Comments

TYPE interest_type_rec_type IS RECORD (
interest_type_id               NUMBER        ,
last_update_date 	             DATE          ,
last_updated_by                NUMBER        ,
creation_date                  DATE          ,
created_by                     NUMBER        ,
last_update_login              NUMBER        ,
master_enabled_flag            VARCHAR2(1)   ,
interest_type 		       VARCHAR2(80)  ,
company_classification_flag    VARCHAR2(1)   ,
contact_interest_flag	       VARCHAR2(1)   ,
lead_classification_flag       VARCHAR2(1)   ,
expected_purchase_flag	       VARCHAR2(1)   ,
current_environment_flag       VARCHAR2(1)   ,
enabled_flag		       VARCHAR2(1)   ,
org_id			       NUMBER        ,
description	                   VARCHAR2(240) ,
prod_cat_set_id        NUMBER	      ,
prod_cat_id		       NUMBER
);

g_miss_interest_type_rec interest_type_rec_type;

-- Start of Comments
-- API Name      : create_interest_type
-- Type          : Public
-- End of Comments

PROCEDURE create_interest_type(
p_api_version_number 	IN 	NUMBER,
p_init_msg_list		IN	VARCHAR2  DEFAULT fnd_api.g_false,
p_commit		      IN	VARCHAR2  DEFAULT fnd_api.g_false,
p_validation_level	IN	NUMBER    DEFAULT fnd_api.g_valid_level_full,
x_return_status		OUT NOCOPY	VARCHAR2,
x_msg_count	            OUT NOCOPY	NUMBER,
x_msg_data              OUT NOCOPY	VARCHAR2,
p_interest_type_rec	IN	interest_type_rec_type  DEFAULT g_miss_interest_type_rec,
x_interest_type_id 	OUT NOCOPY	NUMBER
);

-- Start of Comments
-- API Name      : update_interest_type
-- Type          : Public
-- End of Comments

PROCEDURE update_interest_type(
p_api_version_number 	IN 	NUMBER,
p_init_msg_list		IN	VARCHAR2  DEFAULT fnd_api.g_false,
p_commit                IN	VARCHAR2  DEFAULT fnd_api.g_false,
p_validation_level	IN	NUMBER    DEFAULT fnd_api.g_valid_level_full,
x_return_status		OUT NOCOPY	VARCHAR2,
x_msg_count             OUT NOCOPY	NUMBER,
x_msg_data              OUT NOCOPY	VARCHAR2,
p_interest_type_rec	IN	as_interest_types_pub.interest_type_rec_type  DEFAULT g_miss_interest_type_rec
);

END as_interest_types_pub;

 

/
