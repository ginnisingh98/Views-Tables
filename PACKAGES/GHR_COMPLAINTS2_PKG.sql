--------------------------------------------------------
--  DDL for Package GHR_COMPLAINTS2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINTS2_PKG" AUTHID CURRENT_USER AS
/* $Header: ghrcomp2.pkh 120.0.12010000.1 2008/07/28 10:38:04 appldev ship $ */

PROCEDURE get_fullname_ssn (p_complainant_person_id IN     NUMBER
                           ,p_effective_date        IN     DATE
                           ,p_full_name             IN OUT NOCOPY VARCHAR2
                           ,p_ssn                   IN OUT NOCOPY VARCHAR2);

PROCEDURE get_asg_ids      (p_complainant_person_id IN     NUMBER
                           ,p_effective_date        IN     DATE
                           ,p_asg_id                IN OUT NOCOPY NUMBER
                           ,p_posn_id               IN OUT NOCOPY NUMBER
                           ,p_grade_id              IN OUT NOCOPY NUMBER
                           ,p_job_id                IN OUT NOCOPY NUMBER);

PROCEDURE fetch_peopleei(
    p_person_id         IN     NUMBER
   ,p_information_type  IN     VARCHAR2
   ,p_date_effective    IN     DATE
   ,p_information1      IN OUT  NOCOPY VARCHAR2
   ,p_information2      IN OUT  NOCOPY VARCHAR2
   ,p_information3      IN OUT  NOCOPY VARCHAR2
   ,p_information4      IN OUT  NOCOPY VARCHAR2
   ,p_information5      IN OUT  NOCOPY VARCHAR2
   ,p_information6      IN OUT  NOCOPY VARCHAR2
   ,p_information7      IN OUT  NOCOPY VARCHAR2
   ,p_information8      IN OUT  NOCOPY VARCHAR2
   ,p_information9      IN OUT  NOCOPY VARCHAR2
   ,p_information10     IN OUT  NOCOPY VARCHAR2
   ,p_information11     IN OUT  NOCOPY VARCHAR2
   ,p_information12     IN OUT  NOCOPY VARCHAR2
   ,p_information13     IN OUT  NOCOPY VARCHAR2
   ,p_information14     IN OUT  NOCOPY VARCHAR2
   ,p_information15     IN OUT  NOCOPY VARCHAR2
   ,p_information16     IN OUT  NOCOPY VARCHAR2
   ,p_information17     IN OUT  NOCOPY VARCHAR2
   ,p_information18     IN OUT  NOCOPY VARCHAR2
   ,p_information19     IN OUT  NOCOPY VARCHAR2
   ,p_information20     IN OUT  NOCOPY VARCHAR2
   ,p_information21     IN OUT  NOCOPY VARCHAR2
   ,p_information22     IN OUT  NOCOPY VARCHAR2
   ,p_information23     IN OUT  NOCOPY VARCHAR2
   ,p_information24     IN OUT  NOCOPY VARCHAR2
   ,p_information25     IN OUT  NOCOPY VARCHAR2
   ,p_information26     IN OUT  NOCOPY VARCHAR2
   ,p_information27     IN OUT  NOCOPY VARCHAR2
   ,p_information28     IN OUT  NOCOPY VARCHAR2
   ,p_information29     IN OUT  NOCOPY VARCHAR2
   ,p_information30     IN OUT  NOCOPY VARCHAR2);

PROCEDURE fetch_asgei(
    p_assignment_id     IN     NUMBER
   ,p_information_type  IN     VARCHAR2
   ,p_date_effective    IN     DATE
   ,p_information1      IN OUT  NOCOPY VARCHAR2
   ,p_information2      IN OUT  NOCOPY VARCHAR2
   ,p_information3      IN OUT  NOCOPY VARCHAR2
   ,p_information4      IN OUT  NOCOPY VARCHAR2
   ,p_information5      IN OUT  NOCOPY VARCHAR2
   ,p_information6      IN OUT  NOCOPY VARCHAR2
   ,p_information7      IN OUT  NOCOPY VARCHAR2
   ,p_information8      IN OUT  NOCOPY VARCHAR2
   ,p_information9      IN OUT  NOCOPY VARCHAR2
   ,p_information10     IN OUT  NOCOPY VARCHAR2
   ,p_information11     IN OUT  NOCOPY VARCHAR2
   ,p_information12     IN OUT  NOCOPY VARCHAR2
   ,p_information13     IN OUT  NOCOPY VARCHAR2
   ,p_information14     IN OUT  NOCOPY VARCHAR2
   ,p_information15     IN OUT  NOCOPY VARCHAR2
   ,p_information16     IN OUT  NOCOPY VARCHAR2
   ,p_information17     IN OUT  NOCOPY VARCHAR2
   ,p_information18     IN OUT  NOCOPY VARCHAR2
   ,p_information19     IN OUT  NOCOPY VARCHAR2
   ,p_information20     IN OUT  NOCOPY VARCHAR2
   ,p_information21     IN OUT  NOCOPY VARCHAR2
   ,p_information22     IN OUT  NOCOPY VARCHAR2
   ,p_information23     IN OUT  NOCOPY VARCHAR2
   ,p_information24     IN OUT  NOCOPY VARCHAR2
   ,p_information25     IN OUT  NOCOPY VARCHAR2
   ,p_information26     IN OUT  NOCOPY VARCHAR2
   ,p_information27     IN OUT  NOCOPY VARCHAR2
   ,p_information28     IN OUT  NOCOPY VARCHAR2
   ,p_information29     IN OUT  NOCOPY VARCHAR2
   ,p_information30     IN OUT  NOCOPY VARCHAR2);

PROCEDURE fetch_positionei(
    p_position_id       IN     NUMBER
   ,p_information_type  IN     VARCHAR2
   ,p_date_effective    IN     DATE
   ,p_information1      IN OUT  NOCOPY VARCHAR2
   ,p_information2      IN OUT  NOCOPY VARCHAR2
   ,p_information3      IN OUT  NOCOPY VARCHAR2
   ,p_information4      IN OUT  NOCOPY VARCHAR2
   ,p_information5      IN OUT  NOCOPY VARCHAR2
   ,p_information6      IN OUT  NOCOPY VARCHAR2
   ,p_information7      IN OUT  NOCOPY VARCHAR2
   ,p_information8      IN OUT  NOCOPY VARCHAR2
   ,p_information9      IN OUT  NOCOPY VARCHAR2
   ,p_information10     IN OUT  NOCOPY VARCHAR2
   ,p_information11     IN OUT  NOCOPY VARCHAR2
   ,p_information12     IN OUT  NOCOPY VARCHAR2
   ,p_information13     IN OUT  NOCOPY VARCHAR2
   ,p_information14     IN OUT  NOCOPY VARCHAR2
   ,p_information15     IN OUT  NOCOPY VARCHAR2
   ,p_information16     IN OUT  NOCOPY VARCHAR2
   ,p_information17     IN OUT  NOCOPY VARCHAR2
   ,p_information18     IN OUT  NOCOPY VARCHAR2
   ,p_information19     IN OUT  NOCOPY VARCHAR2
   ,p_information20     IN OUT  NOCOPY VARCHAR2
   ,p_information21     IN OUT  NOCOPY VARCHAR2
   ,p_information22     IN OUT  NOCOPY VARCHAR2
   ,p_information23     IN OUT  NOCOPY VARCHAR2
   ,p_information24     IN OUT  NOCOPY VARCHAR2
   ,p_information25     IN OUT  NOCOPY VARCHAR2
   ,p_information26     IN OUT  NOCOPY VARCHAR2
   ,p_information27     IN OUT  NOCOPY VARCHAR2
   ,p_information28     IN OUT  NOCOPY VARCHAR2
   ,p_information29     IN OUT  NOCOPY VARCHAR2
   ,p_information30     IN OUT  NOCOPY VARCHAR2);
--
FUNCTION get_poi_desc (p_personnel_office_id IN NUMBER)
  RETURN VARCHAR2;

PROCEDURE get_grade_details (p_grade_id       IN     NUMBER
                            ,p_grade_name     IN OUT  NOCOPY VARCHAR2
                            ,p_pay_plan       IN OUT  NOCOPY VARCHAR2
                            ,p_grade_or_level IN OUT  NOCOPY VARCHAR2);

FUNCTION get_consolidated_count (p_consolidated_complaint_id IN NUMBER
				,p_complaint_id		     IN NUMBER)
  RETURN NUMBER;

FUNCTION get_docket_number (p_consolidated_complaint_id IN NUMBER)
  RETURN VARCHAR2;

FUNCTION mixed_complaint(p_complaint_id IN NUMBER)
  RETURN BOOLEAN;

FUNCTION remand_complaint(p_complaint_id IN NUMBER)
  RETURN BOOLEAN;

FUNCTION get_window_title(p_complaint_id IN NUMBER
                         ,p_effective_date IN DATE)
  RETURN VARCHAR2;

FUNCTION get_lookup_code(p_application_id fnd_common_lookups.application_id%TYPE
                        ,p_lookup_type    fnd_common_lookups.lookup_type%TYPE
                        ,p_meaning        fnd_common_lookups.meaning%TYPE)
  RETURN VARCHAR2;

FUNCTION get_lookup_meaning(p_application_id fnd_common_lookups.application_id%TYPE
                           ,p_lookup_type    fnd_common_lookups.lookup_type%TYPE
                           ,p_lookup_code    fnd_common_lookups.lookup_code%TYPE)
  RETURN VARCHAR2;

FUNCTION CA_REC_EXISTS(p_complaint_id IN NUMBER)
  RETURN BOOLEAN;

FUNCTION LTR_CLAIM_CHK(p_complaint_id IN NUMBER)
  RETURN BOOLEAN;

FUNCTION CLAIM_CHK(p_complaint_id IN NUMBER)
  RETURN BOOLEAN;

FUNCTION PCOM_INIT_CHK(p_complaint_id IN NUMBER)
  RETURN BOOLEAN;

FUNCTION BASIS_CHK(p_compl_claim_id IN NUMBER)
  RETURN BOOLEAN;

FUNCTION claim_exists(p_complaint_id IN NUMBER)
  RETURN BOOLEAN;


END ghr_complaints2_pkg;

/
