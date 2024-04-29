--------------------------------------------------------
--  DDL for Package PER_ADDRESSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ADDRESSES_PKG" AUTHID CURRENT_USER AS
/* $Header: peadd01t.pkh 115.6 2002/12/26 13:45:30 fsheikh ship $ */
/* Package to Handle DML for the PER_ADDRESSES table
   Called from the Personnel Workstation Forms which
   Utilise the Base View Methodology
*/
--
--
procedure insert_row(p_row_id in out nocopy VARCHAR2
    ,p_address_id      in out nocopy NUMBER
    ,p_business_group_id   NUMBER
    ,p_person_id       NUMBER
    ,p_date_from       DATE
    ,p_primary_flag      VARCHAR2
    ,p_style         VARCHAR2
    ,p_address_line1     VARCHAR2
    ,p_address_line2     VARCHAR2
    ,p_address_line3     VARCHAR2
    ,p_address_type      VARCHAR2
    ,p_comments        VARCHAR2
    ,p_country       VARCHAR2
    ,p_date_to       DATE
    ,p_postal_code     VARCHAR2
    ,p_region_1        VARCHAR2
    ,p_region_2        VARCHAR2
    ,p_region_3        VARCHAR2
    ,p_telephone_number_1  VARCHAR2
    ,p_telephone_number_2  VARCHAR2
    ,p_telephone_number_3  VARCHAR2
    ,p_town_or_city      VARCHAR2
    ,p_request_id      NUMBER
    ,p_program_application_id NUMBER
    ,p_program_id      NUMBER
    ,p_program_update_date DATE
    ,p_addr_attribute_category    VARCHAR2
    ,p_addr_attribute1   VARCHAR2
    ,p_addr_attribute2   VARCHAR2
    ,p_addr_attribute3   VARCHAR2
    ,p_addr_attribute4   VARCHAR2
    ,p_addr_attribute5   VARCHAR2
    ,p_addr_attribute6   VARCHAR2
    ,p_addr_attribute7   VARCHAR2
    ,p_addr_attribute8   VARCHAR2
    ,p_addr_attribute9   VARCHAR2
    ,p_addr_attribute10    VARCHAR2
    ,p_addr_attribute11    VARCHAR2
    ,p_addr_attribute12    VARCHAR2
    ,p_addr_attribute13    VARCHAR2
    ,p_addr_attribute14    VARCHAR2
    ,p_addr_attribute15    VARCHAR2
    ,p_addr_attribute16    VARCHAR2
    ,p_addr_attribute17    VARCHAR2
    ,p_addr_attribute18    VARCHAR2
    ,p_addr_attribute19    VARCHAR2
    ,p_addr_attribute20    VARCHAR2
-- ***** Start new code for bug 2711964 **************
    ,p_add_information13   VARCHAR2
    ,p_add_information14   VARCHAR2
    ,p_add_information15   VARCHAR2
    ,p_add_information16   VARCHAR2
-- ***** End new code for bug 2711964 ***************
    ,p_add_information17   VARCHAR2
    ,p_add_information18   VARCHAR2
    ,p_add_information19   VARCHAR2
    ,p_add_information20   VARCHAR2
    ,p_end_of_time     DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
);
procedure insert_row(p_row_id in out nocopy VARCHAR2
    ,p_address_id      in out nocopy NUMBER
    ,p_business_group_id   NUMBER
    ,p_person_id       NUMBER
    ,p_date_from       DATE
    ,p_primary_flag      VARCHAR2
    ,p_style         VARCHAR2
    ,p_address_line1     VARCHAR2
    ,p_address_line2     VARCHAR2
    ,p_address_line3     VARCHAR2
    ,p_address_type      VARCHAR2
    ,p_comments        VARCHAR2
    ,p_country       VARCHAR2
    ,p_date_to       DATE
    ,p_postal_code     VARCHAR2
    ,p_region_1        VARCHAR2
    ,p_region_2        VARCHAR2
    ,p_region_3        VARCHAR2
    ,p_telephone_number_1  VARCHAR2
    ,p_telephone_number_2  VARCHAR2
    ,p_telephone_number_3  VARCHAR2
    ,p_town_or_city      VARCHAR2
    ,p_request_id      NUMBER
    ,p_program_application_id NUMBER
    ,p_program_id      NUMBER
    ,p_program_update_date DATE
    ,p_addr_attribute_category    VARCHAR2
    ,p_addr_attribute1   VARCHAR2
    ,p_addr_attribute2   VARCHAR2
    ,p_addr_attribute3   VARCHAR2
    ,p_addr_attribute4   VARCHAR2
    ,p_addr_attribute5   VARCHAR2
    ,p_addr_attribute6   VARCHAR2
    ,p_addr_attribute7   VARCHAR2
    ,p_addr_attribute8   VARCHAR2
    ,p_addr_attribute9   VARCHAR2
    ,p_addr_attribute10    VARCHAR2
    ,p_addr_attribute11    VARCHAR2
    ,p_addr_attribute12    VARCHAR2
    ,p_addr_attribute13    VARCHAR2
    ,p_addr_attribute14    VARCHAR2
    ,p_addr_attribute15    VARCHAR2
    ,p_addr_attribute16    VARCHAR2
    ,p_addr_attribute17    VARCHAR2
    ,p_addr_attribute18    VARCHAR2
    ,p_addr_attribute19    VARCHAR2
    ,p_addr_attribute20    VARCHAR2
-- ***** Start new code for bug 2711964 **************
    ,p_add_information13   VARCHAR2
    ,p_add_information14   VARCHAR2
    ,p_add_information15   VARCHAR2
    ,p_add_information16   VARCHAR2
-- ***** End new code for bug 2711964 ***************
    ,p_add_information17   VARCHAR2
    ,p_add_information18   VARCHAR2
    ,p_add_information19   VARCHAR2
    ,p_add_information20   VARCHAR2
    ,p_end_of_time     DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
    ,p_default_primary IN OUT NOCOPY VARCHAR2
);
--
procedure delete_row(p_row_id VARCHAR2);
--
procedure delete_row(p_row_id VARCHAR2
                    ,p_person_id NUMBER
                    ,p_business_group_id NUMBER
                    ,p_end_of_time DATE
                    ,p_default_primary IN OUT NOCOPY VARCHAR2);
--
procedure lock_row(p_row_id VARCHAR2
    ,p_address_id      NUMBER
    ,p_business_group_id   NUMBER
    ,p_person_id       NUMBER
    ,p_date_from       DATE
    ,p_primary_flag      VARCHAR2
    ,p_style         VARCHAR2
    ,p_address_line1     VARCHAR2
    ,p_address_line2     VARCHAR2
    ,p_address_line3     VARCHAR2
    ,p_address_type      VARCHAR2
    ,p_comments        VARCHAR2
    ,p_country       VARCHAR2
    ,p_date_to       DATE
    ,p_postal_code     VARCHAR2
    ,p_region_1        VARCHAR2
    ,p_region_2        VARCHAR2
    ,p_region_3        VARCHAR2
    ,p_telephone_number_1  VARCHAR2
    ,p_telephone_number_2  VARCHAR2
    ,p_telephone_number_3  VARCHAR2
    ,p_town_or_city      VARCHAR2
    ,p_addr_attribute_category    VARCHAR2
    ,p_addr_attribute1   VARCHAR2
    ,p_addr_attribute2   VARCHAR2
    ,p_addr_attribute3   VARCHAR2
    ,p_addr_attribute4   VARCHAR2
    ,p_addr_attribute5   VARCHAR2
    ,p_addr_attribute6   VARCHAR2
    ,p_addr_attribute7   VARCHAR2
    ,p_addr_attribute8   VARCHAR2
    ,p_addr_attribute9   VARCHAR2
    ,p_addr_attribute10    VARCHAR2
    ,p_addr_attribute11    VARCHAR2
    ,p_addr_attribute12    VARCHAR2
    ,p_addr_attribute13    VARCHAR2
    ,p_addr_attribute14    VARCHAR2
    ,p_addr_attribute15    VARCHAR2
    ,p_addr_attribute16    VARCHAR2
    ,p_addr_attribute17    VARCHAR2
    ,p_addr_attribute18    VARCHAR2
    ,p_addr_attribute19    VARCHAR2
    ,p_addr_attribute20    VARCHAR2
    ,p_add_information17   VARCHAR2
    ,p_add_information18   VARCHAR2
    ,p_add_information19   VARCHAR2
    ,p_add_information20   VARCHAR2
);
--
procedure update_row(p_row_id VARCHAR2
    ,p_address_id      NUMBER
    ,p_business_group_id   NUMBER
    ,p_person_id       NUMBER
    ,p_date_from       DATE
    ,p_primary_flag      VARCHAR2
    ,p_style         VARCHAR2
    ,p_address_line1     VARCHAR2
    ,p_address_line2     VARCHAR2
    ,p_address_line3     VARCHAR2
    ,p_address_type      VARCHAR2
    ,p_comments        VARCHAR2
    ,p_country       VARCHAR2
    ,p_date_to       DATE
    ,p_postal_code     VARCHAR2
    ,p_region_1        VARCHAR2
    ,p_region_2        VARCHAR2
    ,p_region_3        VARCHAR2
    ,p_telephone_number_1  VARCHAR2
    ,p_telephone_number_2  VARCHAR2
    ,p_telephone_number_3  VARCHAR2
    ,p_town_or_city      VARCHAR2
    ,p_request_id      NUMBER
    ,p_program_application_id NUMBER
    ,p_program_id      NUMBER
    ,p_program_update_date DATE
    ,p_addr_attribute_category    VARCHAR2
    ,p_addr_attribute1   VARCHAR2
    ,p_addr_attribute2   VARCHAR2
    ,p_addr_attribute3   VARCHAR2
    ,p_addr_attribute4   VARCHAR2
    ,p_addr_attribute5   VARCHAR2
    ,p_addr_attribute6   VARCHAR2
    ,p_addr_attribute7   VARCHAR2
    ,p_addr_attribute8   VARCHAR2
    ,p_addr_attribute9   VARCHAR2
    ,p_addr_attribute10    VARCHAR2
    ,p_addr_attribute11    VARCHAR2
    ,p_addr_attribute12    VARCHAR2
    ,p_addr_attribute13    VARCHAR2
    ,p_addr_attribute14    VARCHAR2
    ,p_addr_attribute15    VARCHAR2
    ,p_addr_attribute16    VARCHAR2
    ,p_addr_attribute17    VARCHAR2
    ,p_addr_attribute18    VARCHAR2
    ,p_addr_attribute19    VARCHAR2
    ,p_addr_attribute20    VARCHAR2
    ,p_add_information17   VARCHAR2
    ,p_add_information18   VARCHAR2
    ,p_add_information19   VARCHAR2
    ,p_add_information20   VARCHAR2
    ,p_end_of_time     DATE DEFAULT  to_date('31-12-4712','DD-MM-YYYY')
);
procedure update_row(p_row_id VARCHAR2
    ,p_address_id      NUMBER
    ,p_business_group_id   NUMBER
    ,p_person_id       NUMBER
    ,p_date_from       DATE
    ,p_primary_flag      VARCHAR2
    ,p_style         VARCHAR2
    ,p_address_line1     VARCHAR2
    ,p_address_line2     VARCHAR2
    ,p_address_line3     VARCHAR2
    ,p_address_type      VARCHAR2
    ,p_comments        VARCHAR2
    ,p_country       VARCHAR2
    ,p_date_to       DATE
    ,p_postal_code     VARCHAR2
    ,p_region_1        VARCHAR2
    ,p_region_2        VARCHAR2
    ,p_region_3        VARCHAR2
    ,p_telephone_number_1  VARCHAR2
    ,p_telephone_number_2  VARCHAR2
    ,p_telephone_number_3  VARCHAR2
    ,p_town_or_city      VARCHAR2
    ,p_request_id      NUMBER
    ,p_program_application_id NUMBER
    ,p_program_id      NUMBER
    ,p_program_update_date DATE
    ,p_addr_attribute_category    VARCHAR2
    ,p_addr_attribute1   VARCHAR2
    ,p_addr_attribute2   VARCHAR2
    ,p_addr_attribute3   VARCHAR2
    ,p_addr_attribute4   VARCHAR2
    ,p_addr_attribute5   VARCHAR2
    ,p_addr_attribute6   VARCHAR2
    ,p_addr_attribute7   VARCHAR2
    ,p_addr_attribute8   VARCHAR2
    ,p_addr_attribute9   VARCHAR2
    ,p_addr_attribute10    VARCHAR2
    ,p_addr_attribute11    VARCHAR2
    ,p_addr_attribute12    VARCHAR2
    ,p_addr_attribute13    VARCHAR2
    ,p_addr_attribute14    VARCHAR2
    ,p_addr_attribute15    VARCHAR2
    ,p_addr_attribute16    VARCHAR2
    ,p_addr_attribute17    VARCHAR2
    ,p_addr_attribute18    VARCHAR2
    ,p_addr_attribute19    VARCHAR2
    ,p_addr_attribute20    VARCHAR2
    ,p_add_information17   VARCHAR2
    ,p_add_information18   VARCHAR2
    ,p_add_information19   VARCHAR2
    ,p_add_information20   VARCHAR2
    ,p_end_of_time     DATE DEFAULT  to_date('31-12-4712','DD-MM-YYYY')
    ,p_default_primary IN OUT NOCOPY VARCHAR2
);
--
function does_primary_exist(p_person_id NUMBER
                           ,p_business_group_id NUMBER
                           ,p_end_of_time DATE)return VARCHAR2;
--
procedure find_gaps(p_person_id NUMBER
                   ,p_end_of_time DATE);
--
procedure get_addresses(p_legislation_code VARCHAR2
                       ,p_default_country IN OUT NOCOPY VARCHAR2);
--
procedure get_default_style(p_legislation_code VARCHAR2
					    ,p_default_country IN OUT NOCOPY VARCHAR2
					    ,p_default_style IN OUT NOCOPY VARCHAR2);
--
procedure form_startup1(p_person_id NUMBER
                      ,p_business_group_id NUMBER
				  ,p_end_of_time DATE
				  ,p_primary_flag IN OUT NOCOPY VARCHAR2
				  ,p_legislation_code VARCHAR2
				  ,p_default_country IN OUT NOCOPY VARCHAR2
				  ,p_default_style IN OUT NOCOPY VARCHAR2);
--
procedure form_startup(p_person_id NUMBER
                      ,p_business_group_id NUMBER
                      ,p_end_of_time DATE
                      ,p_primary_flag IN OUT NOCOPY VARCHAR2
                      ,p_legislation_code VARCHAR2
                      ,p_default_country IN OUT NOCOPY VARCHAR2);
--
PROCEDURE validate_address(p_person_id INTEGER
                          ,p_end_of_time DATE);
END PER_ADDRESSES_PKG;

 

/
