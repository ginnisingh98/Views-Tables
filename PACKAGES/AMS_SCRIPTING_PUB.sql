--------------------------------------------------------
--  DDL for Package AMS_SCRIPTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SCRIPTING_PUB" AUTHID CURRENT_USER AS
/* $Header: amspscrs.pls 115.3 2003/02/18 06:28:18 sanshuma noship $ */


-- ===============================================================
-- Start of Comments
-- Package name
--          ams_scripting_pub
-- Purpose
--
-- History
--
-- NOTE
--
-- ===============================================================


TYPE ams_party_rec_type IS RECORD
(
	organization		VARCHAR2(360),
	country			VARCHAR2(60),
	address1		VARCHAR2(240),
	address2		VARCHAR2(240),
	address3		VARCHAR2(240),
	address4		VARCHAR2(240),
	city			VARCHAR2(60),
	county			VARCHAR2(60),
	state			VARCHAR2(60),
	postal_code		VARCHAR2(60),
	firstname		VARCHAR2(150),
	middlename		VARCHAR2(60),
	lastname		VARCHAR2(150),
	email			VARCHAR2(2000),
	dayareacode		VARCHAR2(10),
	daycountrycode		VARCHAR2(10),
	daynumber		VARCHAR2(40),
	dayextension		VARCHAR2(20),
	eveningareacode		VARCHAR2(10),
	eveningcountrycode	VARCHAR2(10),
	eveningnumber		VARCHAR2(40),
	eveningExtension	VARCHAR2(20),
	faxareacode		VARCHAR2(10),
	faxcountrycode		VARCHAR2(10),
	faxnumber		VARCHAR2(40),
	faxextension		VARCHAR2(20)
);


g_miss_ams_party_rec      ams_party_rec_type := NULL;
TYPE  ams_party_tbl_type  IS TABLE OF ams_party_rec_type INDEX BY BINARY_INTEGER;
g_miss_ams_party_tbl      ams_party_tbl_type;

TYPE ams_person_profile_rec_type IS RECORD
(
	date_of_birth                   DATE,
	place_of_birth                  VARCHAR2(60),
	gender                          VARCHAR2(30),
	marital_status                  VARCHAR2(30),
	marital_status_effective_date   DATE,
	personal_income                 NUMBER,
	head_of_household_flag          VARCHAR2(1),
	household_income                NUMBER,
	household_size                  NUMBER,
	rent_own_ind                    VARCHAR2(30)
);

g_miss_ams_person_profile_rec      ams_person_profile_rec_type := NULL;
TYPE  ams_person_profile_tbl_type  IS TABLE OF ams_person_profile_rec_type INDEX BY BINARY_INTEGER;
g_miss_ams_person_tbl      ams_person_profile_tbl_type;



PROCEDURE Create_Customer(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_party_id			 IN OUT NOCOPY NUMBER,
    p_b2b_flag			 IN   VARCHAR2,
    p_import_list_header_id      IN   NUMBER,

    p_ams_party_rec              IN   ams_party_rec_type  := g_miss_ams_party_rec,

    x_new_party			 OUT  NOCOPY VARCHAR2,
    p_component_name             OUT  NOCOPY VARCHAR2
);

PROCEDURE Update_Person_Profile(
	p_api_version_number		IN  NUMBER,
	p_init_msg_list                 IN  VARCHAR2	 := FND_API.G_FALSE,
	p_commit			IN  VARCHAR2     := FND_API.G_FALSE,
	p_validation_level		IN  NUMBER       := FND_API.g_valid_level_full,
	x_return_status                 OUT NOCOPY VARCHAR2,
	x_msg_count                     OUT NOCOPY NUMBER,
	x_msg_data                      OUT NOCOPY VARCHAR2,

	p_party_id			IN  NUMBER,
	p_profile_id                    IN  OUT NOCOPY NUMBER,
	p_person_profile_rec            IN  ams_person_profile_rec_type := g_miss_ams_person_profile_rec,
	p_party_object_version_number   IN  OUT NOCOPY  NUMBER
);

END ams_scripting_pub;

 

/
