--------------------------------------------------------
--  DDL for Package AS_INTEREST_CODES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_INTEREST_CODES_PUB" AUTHID CURRENT_USER as
/* $Header: asxintcs.pls 115.5 2003/10/10 08:58:12 gbatra ship $ */
--
--****************************************************************************
-- Name : AS_INTEREST_CODES_PUB
--
-- Purpose : Public API to Create and Update Interest Codes in the Oracle
--           Sales Online.
--
-- History:
--
--   09/12/2002    Rajan T          Created
--
--****************************************************************************
-- Start of Comments
-- Record Name      : interest_code_rec_type
-- Type             : Global
-- End of Comments

TYPE interest_code_rec_type IS RECORD (
    interest_code_id        NUMBER        ,
    last_update_date        DATE          ,
    last_updated_by    	    NUMBER        ,
    creation_date    	    DATE          ,
    created_by              NUMBER        ,
    last_update_login       NUMBER        ,
    request_id              NUMBER        ,
    program_application_id  NUMBER        ,
    program_id              NUMBER        ,
    program_update_date     DATE          ,
    interest_type_id        NUMBER        ,
    parent_interest_code_id NUMBER        ,
    master_enabled_flag     VARCHAR2(1)   ,
    category_id             NUMBER        ,
    category_set_id    	    NUMBER        ,
    pf_item_id              NUMBER        ,
    pf_organization_id      NUMBER        ,
    currency_code    	    VARCHAR2(15)  ,
    price                   NUMBER        ,
    attribute_category      VARCHAR2(30)  ,
    attribute1              VARCHAR2(150) ,
    attribute2              VARCHAR2(150) ,
    attribute3              VARCHAR2(150) ,
    attribute4              VARCHAR2(150) ,
    attribute5              VARCHAR2(150) ,
    attribute6              VARCHAR2(150) ,
    attribute7              VARCHAR2(150) ,
    attribute8              VARCHAR2(150) ,
    attribute9              VARCHAR2(150) ,
    attribute10             VARCHAR2(150) ,
    attribute11             VARCHAR2(150) ,
    attribute12             VARCHAR2(150) ,
    attribute13             VARCHAR2(150) ,
    attribute14             VARCHAR2(150) ,
    attribute15             VARCHAR2(150) ,
    code                    VARCHAR2(100) ,
    description             VARCHAR2(240) ,
    prod_cat_set_id         NUMBER	      ,
    prod_cat_id		        NUMBER
    );
g_miss_interest_code_rec interest_code_rec_type;

-- Start of Comments
-- API Name         : crete_interest_code
-- Type             : Public
-- End of Comments

PROCEDURE create_interest_code(
    p_api_version_number      IN 	NUMBER,
    p_init_msg_list           IN	VARCHAR2	DEFAULT fnd_api.g_false,
    p_commit    	      IN	VARCHAR2 	DEFAULT fnd_api.g_false,
    p_validation_level	      IN	NUMBER	DEFAULT fnd_api.g_valid_level_full,
    x_return_status           OUT NOCOPY	VARCHAR2,
    x_msg_count    	      OUT NOCOPY	NUMBER,
    x_msg_data    	      OUT NOCOPY	VARCHAR2,
    p_interest_code_rec	      IN	interest_code_rec_type DEFAULT g_miss_interest_code_rec,
    x_interest_code_id 	      OUT NOCOPY	NUMBER
    );

-- Start of Comments
-- API Name         : update_interest_code
-- Type             : Public
-- End of Comments

PROCEDURE update_interest_code(
    p_api_version_number IN 	NUMBER,
    p_init_msg_list      IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit    	 IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level	 IN	NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status      OUT NOCOPY	VARCHAR2,
    x_msg_count    	 OUT NOCOPY	NUMBER,
    x_msg_data    	 OUT NOCOPY	VARCHAR2,
    p_interest_code_rec	 IN	interest_code_rec_type DEFAULT g_miss_interest_code_rec
    );

END as_interest_codes_pub;

 

/
