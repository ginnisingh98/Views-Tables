--------------------------------------------------------
--  DDL for Package HR_LOCATION_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOCATION_BK4" AUTHID CURRENT_USER AS
/* $Header: hrlocapi.pkh 120.2.12010000.3 2009/10/26 12:26:36 skura ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_location_legal_adr_b >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_location_legal_adr_b
(       p_effective_date                IN DATE,
	p_language_code                 IN VARCHAR2,
	p_location_code                 IN VARCHAR2,
	p_description                   IN VARCHAR2,
        p_timezone_code                 IN VARCHAR2,
	p_address_line_1                IN VARCHAR2,
	p_address_line_2                IN VARCHAR2,
	p_address_line_3                IN VARCHAR2,
	p_country                       IN VARCHAR2,
        p_inactive_date                 IN DATE,
	p_postal_code                   IN VARCHAR2,
	p_region_1                      IN VARCHAR2,
	p_region_2                      IN VARCHAR2,
	p_region_3                      IN VARCHAR2,
	p_style                         IN VARCHAR2,
	p_town_or_city                  IN VARCHAR2,
	p_attribute_category            IN VARCHAR2,
    /*Added for bug8703747 */
  p_telephone_number_1             IN  VARCHAR2,
  p_telephone_number_2             IN  VARCHAR2,
  p_telephone_number_3             IN  VARCHAR2,
  p_loc_information13              IN  VARCHAR2,
  p_loc_information14              IN  VARCHAR2,
  p_loc_information15              IN  VARCHAR2,
  p_loc_information16              IN  VARCHAR2,
  p_loc_information17              IN  VARCHAR2,
  p_loc_information18              IN  VARCHAR2,
  p_loc_information19              IN  VARCHAR2,
  p_loc_information20              IN  VARCHAR2,
    /*Changes end for bug8703747 */
	p_attribute1                    IN VARCHAR2,
	p_attribute2                    IN VARCHAR2,
	p_attribute3                    IN VARCHAR2,
	p_attribute4                    IN VARCHAR2,
	p_attribute5                    IN VARCHAR2,
	p_attribute6                    IN VARCHAR2,
	p_attribute7                    IN VARCHAR2,
	p_attribute8                    IN VARCHAR2,
	p_attribute9                    IN VARCHAR2,
	p_attribute10                   IN VARCHAR2,
	p_attribute11                   IN VARCHAR2,
	p_attribute12                   IN VARCHAR2,
	p_attribute13                   IN VARCHAR2,
	p_attribute14                   IN VARCHAR2,
	p_attribute15                   IN VARCHAR2,
	p_attribute16                   IN VARCHAR2,
	p_attribute17                   IN VARCHAR2,
	p_attribute18                   IN VARCHAR2,
	p_attribute19                   IN VARCHAR2,
	p_attribute20                   IN VARCHAR2,
	p_business_group_id             IN NUMBER
--
     );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_location_legal_adr_a >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_location_legal_adr_a
  (     p_effective_date                IN DATE,
	p_language_code                 IN VARCHAR2,
	p_location_code                 IN VARCHAR2,
	p_description                   IN VARCHAR2,
        p_timezone_code                 IN VARCHAR2,
	p_address_line_1                IN VARCHAR2,
	p_address_line_2                IN VARCHAR2,
	p_address_line_3                IN VARCHAR2,
	p_country                       IN VARCHAR2,
        p_inactive_date                 IN DATE,
	p_postal_code                   IN VARCHAR2,
	p_region_1                      IN VARCHAR2,
	p_region_2                      IN VARCHAR2,
	p_region_3                      IN VARCHAR2,
	p_style                         IN VARCHAR2,
	p_town_or_city                  IN VARCHAR2,
      /*Added for bug8703747 */
  p_telephone_number_1             IN  VARCHAR2,
  p_telephone_number_2             IN  VARCHAR2,
  p_telephone_number_3             IN  VARCHAR2,
  p_loc_information13              IN  VARCHAR2,
  p_loc_information14              IN  VARCHAR2,
  p_loc_information15              IN  VARCHAR2,
  p_loc_information16              IN  VARCHAR2,
  p_loc_information17              IN  VARCHAR2,
  p_loc_information18              IN  VARCHAR2,
  p_loc_information19              IN  VARCHAR2,
  p_loc_information20              IN  VARCHAR2,
    /*Changes end for bug8703747 */
	p_attribute_category            IN VARCHAR2,
	p_attribute1                    IN VARCHAR2,
	p_attribute2                    IN VARCHAR2,
	p_attribute3                    IN VARCHAR2,
	p_attribute4                    IN VARCHAR2,
	p_attribute5                    IN VARCHAR2,
	p_attribute6                    IN VARCHAR2,
	p_attribute7                    IN VARCHAR2,
	p_attribute8                    IN VARCHAR2,
	p_attribute9                    IN VARCHAR2,
	p_attribute10                   IN VARCHAR2,
	p_attribute11                   IN VARCHAR2,
	p_attribute12                   IN VARCHAR2,
	p_attribute13                   IN VARCHAR2,
	p_attribute14                   IN VARCHAR2,
	p_attribute15                   IN VARCHAR2,
	p_attribute16                   IN VARCHAR2,
	p_attribute17                   IN VARCHAR2,
	p_attribute18                   IN VARCHAR2,
	p_attribute19                   IN VARCHAR2,
	p_attribute20                   IN VARCHAR2,
	p_business_group_id             IN NUMBER,
  	p_location_id                   IN NUMBER,
  	p_object_version_number         IN NUMBER
  );
END hr_location_bk4;
--

/
