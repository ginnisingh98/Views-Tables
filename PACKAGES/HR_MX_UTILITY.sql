--------------------------------------------------------
--  DDL for Package HR_MX_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MX_UTILITY" AUTHID CURRENT_USER AS
/* $Header: hrmxutil.pkh 120.6.12010000.1 2008/07/28 03:32:01 appldev ship $ */

--------------------------------------------------------------------
-- This function is used to support the full_name trigger for
-- Mexico legislation.
--------------------------------------------------------------------
    FUNCTION per_mx_full_name(
                p_first_name        IN VARCHAR2
               ,p_middle_names      IN VARCHAR2
               ,p_last_name         IN VARCHAR2
               ,p_known_as          IN VARCHAR2
               ,p_title             IN VARCHAR2
               ,p_suffix            IN VARCHAR2
               ,p_pre_name_adjunct  IN VARCHAR2
               ,p_per_information1  IN VARCHAR2
               ,p_per_information2  IN VARCHAR2
               ,p_per_information3  IN VARCHAR2
               ,p_per_information4  IN VARCHAR2
               ,p_per_information5  IN VARCHAR2
               ,p_per_information6  IN VARCHAR2
               ,p_per_information7  IN VARCHAR2
               ,p_per_information8  IN VARCHAR2
               ,p_per_information9  IN VARCHAR2
               ,p_per_information10 IN VARCHAR2
               ,p_per_information11 IN VARCHAR2
               ,p_per_information12 IN VARCHAR2
               ,p_per_information13 IN VARCHAR2
               ,p_per_information14 IN VARCHAR2
               ,p_per_information15 IN VARCHAR2
               ,p_per_information16 IN VARCHAR2
               ,p_per_information17 IN VARCHAR2
               ,p_per_information18 IN VARCHAR2
               ,p_per_information19 IN VARCHAR2
               ,p_per_information20 IN VARCHAR2
               ,p_per_information21 IN VARCHAR2
               ,p_per_information22 IN VARCHAR2
               ,p_per_information23 IN VARCHAR2
               ,p_per_information24 IN VARCHAR2
               ,p_per_information25 IN VARCHAR2
               ,p_per_information26 IN VARCHAR2
               ,p_per_information27 IN VARCHAR2
               ,p_per_information28 IN VARCHAR2
               ,p_per_information29 IN VARCHAR2
               ,p_per_information30 IN VARCHAR2
  )  RETURN VARCHAR2;


FUNCTION get_GRE_from_location(p_location_id       IN NUMBER,
                               p_business_group_id IN NUMBER, -- Bug 4129001
                               p_session_date      IN DATE,
                               p_is_ambiguous     OUT NOCOPY BOOLEAN,
                               p_missing_gre      OUT NOCOPY BOOLEAN
                               ) RETURN NUMBER;

FUNCTION get_GRE_from_scl(p_soft_coding_keyflex_id IN NUMBER
                         ) RETURN NUMBER;


PROCEDURE check_bus_grp (p_business_group_id IN NUMBER
                        ,p_legislation_code  IN VARCHAR2);


FUNCTION GET_BG_FROM_PERSON (
        p_person_id per_all_people_f.person_id%TYPE)
        RETURN per_all_people_f.business_group_id%TYPE;

FUNCTION GET_BG_FROM_ASSIGNMENT (
        p_assignment_id per_all_assignments_f.assignment_id%TYPE)
        RETURN per_all_assignments_f.business_group_id%TYPE;

FUNCTION  get_tax_subsidy_percent(p_business_group_id IN NUMBER,
                                  p_tax_unit_id       IN NUMBER) RETURN NUMBER;

FUNCTION  get_tax_subsidy_percent(p_business_group_id IN NUMBER,
                                  p_tax_unit_id       IN NUMBER,
                                  p_effective_date    IN DATE) RETURN NUMBER;

FUNCTION  get_wrip(p_business_group_id IN NUMBER,
                   p_tax_unit_id       IN NUMBER) RETURN NUMBER;

FUNCTION get_legal_employer(p_business_group_id NUMBER,
                            p_tax_unit_id       NUMBER) RETURN NUMBER;

FUNCTION get_legal_employer(p_business_group_id NUMBER,
                            p_tax_unit_id       NUMBER,
                            p_effective_date    DATE) RETURN NUMBER;

FUNCTION get_hire_anniversary(p_person_id      NUMBER,
                              p_effective_date DATE) RETURN DATE;

FUNCTION get_seniority_social_security(p_person_id      NUMBER,
                                       p_effective_date DATE) RETURN NUMBER;

FUNCTION get_seniority(p_business_group_id IN NUMBER
                      ,p_tax_unit_id       IN NUMBER
                      ,p_payroll_id        IN NUMBER
                      ,p_person_id         IN NUMBER
                      ,p_effective_date    IN DATE) RETURN NUMBER;

FUNCTION get_IANA_charset RETURN VARCHAR2;

FUNCTION chk_entry_in_lookup
                      (p_lookup_type    IN  hr_lookups.lookup_type%TYPE
                      ,p_entry_val      IN  hr_lookups.meaning%TYPE
                      ,p_effective_date IN  hr_lookups.start_date_active%TYPE
                      ,p_message        OUT NOCOPY VARCHAR2) RETURN VARCHAR2;


--
procedure DERIVE_HR_LOC_ADDRESS
                       (p_tax_name                  in varchar2,
                        p_style                     in varchar2,
                        p_address_line_1            in varchar2,
                        p_address_line_2            in varchar2,
                        p_address_line_3            in varchar2,
                        p_town_or_city              in varchar2,
                        p_country                   in varchar2,
                        p_postal_code               in varchar2,
                        p_region_1                  in varchar2,
                        p_region_2                  in varchar2,
                        p_region_3                  in varchar2,
                        p_telephone_number_1        in varchar2,
                        p_telephone_number_2        in varchar2,
                        p_telephone_number_3        in varchar2,
                        p_loc_information13         in varchar2,
                        p_loc_information14         in varchar2,
                        p_loc_information15         in varchar2,
                        p_loc_information16         in varchar2,
                        p_loc_information17         in varchar2,
                        p_attribute_category        in varchar2,
                        p_attribute1                in varchar2,
                        p_attribute2                in varchar2,
                        p_attribute3                in varchar2,
                        p_attribute4                in varchar2,
                        p_attribute5                in varchar2,
                        p_attribute6                in varchar2,
                        p_attribute7                in varchar2,
                        p_attribute8                in varchar2,
                        p_attribute9                in varchar2,
                        p_attribute10               in varchar2,
                        p_attribute11               in varchar2,
                        p_attribute12               in varchar2,
                        p_attribute13               in varchar2,
                        p_attribute14               in varchar2,
                        p_attribute15               in varchar2,
                        p_attribute16               in varchar2,
                        p_attribute17               in varchar2,
                        p_attribute18               in varchar2,
                        p_attribute19               in varchar2,
                        p_attribute20               in varchar2,
                        p_global_attribute_category in varchar2,
                        p_global_attribute1         in varchar2,
                        p_global_attribute2         in varchar2,
                        p_global_attribute3         in varchar2,
                        p_global_attribute4         in varchar2,
                        p_global_attribute5         in varchar2,
                        p_global_attribute6         in varchar2,
                        p_global_attribute7         in varchar2,
                        p_global_attribute8         in varchar2,
                        p_global_attribute9         in varchar2,
                        p_global_attribute10        in varchar2,
                        p_global_attribute11        in varchar2,
                        p_global_attribute12        in varchar2,
                        p_global_attribute13        in varchar2,
                        p_global_attribute14        in varchar2,
                        p_global_attribute15        in varchar2,
                        p_global_attribute16        in varchar2,
                        p_global_attribute17        in varchar2,
                        p_global_attribute18        in varchar2,
                        p_global_attribute19        in varchar2,
                        p_global_attribute20        in varchar2,
                        p_loc_information18         in varchar2,
                        p_loc_information19         in varchar2,
                        p_loc_information20         in varchar2,
                        p_derived_locale           out nocopy varchar2
                       );
--
procedure DERIVE_PER_ADD_ADDRESS
                       (p_style                     in varchar2,
                        p_address_line1             in varchar2,
                        p_address_line2             in varchar2,
                        p_address_line3             in varchar2,
                        p_country                   in varchar2,
                        p_date_to                   in date,
                        p_postal_code               in varchar2,
                        p_region_1                  in varchar2,
                        p_region_2                  in varchar2,
                        p_region_3                  in varchar2,
                        p_telephone_number_1        in varchar2,
                        p_telephone_number_2        in varchar2,
                        p_telephone_number_3        in varchar2,
                        p_town_or_city              in varchar2,
                        p_addr_attribute_category   in varchar2,
                        p_addr_attribute1           in varchar2,
                        p_addr_attribute2           in varchar2,
                        p_addr_attribute3           in varchar2,
                        p_addr_attribute4           in varchar2,
                        p_addr_attribute5           in varchar2,
                        p_addr_attribute6           in varchar2,
                        p_addr_attribute7           in varchar2,
                        p_addr_attribute8           in varchar2,
                        p_addr_attribute9           in varchar2,
                        p_addr_attribute10          in varchar2,
                        p_addr_attribute11          in varchar2,
                        p_addr_attribute12          in varchar2,
                        p_addr_attribute13          in varchar2,
                        p_addr_attribute14          in varchar2,
                        p_addr_attribute15          in varchar2,
                        p_addr_attribute16          in varchar2,
                        p_addr_attribute17          in varchar2,
                        p_addr_attribute18          in varchar2,
                        p_addr_attribute19          in varchar2,
                        p_addr_attribute20          in varchar2,
		 	p_add_information13         in varchar2,
			p_add_information14         in varchar2,
			p_add_information15         in varchar2,
			p_add_information16         in varchar2,
                        p_add_information17         in varchar2,
                        p_add_information18         in varchar2,
                        p_add_information19         in varchar2,
                        p_add_information20         in varchar2,
                        p_derived_locale           out nocopy varchar2);
--
END hr_mx_utility;

/
