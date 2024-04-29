--------------------------------------------------------
--  DDL for Package HR_NO_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NO_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: penovald.pkh 120.5.12010000.2 2008/08/06 09:17:07 ubhat ship $ */

  PROCEDURE person_validate
  (p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  );

  PROCEDURE applicant_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  );

  PROCEDURE employee_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  );

  PROCEDURE cwk_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
   );

/*

 PROCEDURE validate_create_org_inf
  (p_org_info_type_code			in	 varchar2
  ,p_organization_id			in	number
  ,p_org_information1		in	varchar2
  ) ;


   PROCEDURE validate_update_org_inf
  (p_org_info_type_code			in	 varchar2
  ,p_org_information_id		in number
  ,p_org_information1		in	varchar2
  );

*/

/* Bug Fix 4463101 */

 PROCEDURE validate_create_org_inf
  (p_org_info_type_code			in	varchar2
  ,p_organization_id			in	number
  ,p_org_information1		        in	varchar2
  ,p_org_information2		        in	varchar2
  ,p_org_information3		        in	varchar2
  ,p_org_information4			in	varchar2
  ,p_org_information5			in	varchar2
  ,p_org_information6			in	varchar2
  ,p_org_information7			in	varchar2
  ,p_org_information8			in	varchar2
  ,p_org_information9			in	varchar2
  ,p_org_information10			in	varchar2
  ,p_org_information11			in	varchar2
  ,p_org_information12			in	varchar2
  ,p_org_information13			in	varchar2
  ,p_org_information14			in	varchar2
  ,p_org_information15			in	varchar2
  ,p_org_information16			in	varchar2
  ,p_org_information17			in	varchar2
  ,p_org_information18			in	varchar2
  ,p_org_information19			in	varchar2
  ,p_org_information20			in	varchar2
  ) ;
/* Bug Fix 4463101 */

 PROCEDURE validate_update_org_inf
  (p_org_info_type_code			in	varchar2
  ,p_org_information_id			in	number
  ,p_org_information1			in	varchar2
  ,p_org_information2			in	varchar2
  ,p_org_information3			in	varchar2
  ,p_org_information4			in	varchar2
  ,p_org_information5			in	varchar2
  ,p_org_information6			in	varchar2
  ,p_org_information7			in	varchar2
  ,p_org_information8			in	varchar2
  ,p_org_information9			in	varchar2
  ,p_org_information10			in	varchar2
  ,p_org_information11			in	varchar2
  ,p_org_information12			in	varchar2
  ,p_org_information13			in	varchar2
  ,p_org_information14			in	varchar2
  ,p_org_information15			in	varchar2
  ,p_org_information16			in	varchar2
  ,p_org_information17			in	varchar2
  ,p_org_information18			in	varchar2
  ,p_org_information19			in	varchar2
  ,p_org_information20			in	varchar2
  );

PROCEDURE qual_insert_validate
  (p_business_group_id              in      number
  ,p_qualification_type_id          in      number
  ,p_qua_information_category       in      varchar2 default null
  ,p_person_id                      in      number
  ,p_qua_information1               in      varchar2 default null
  ,p_qua_information2               in      varchar2 default null
  );

  PROCEDURE qual_update_validate
  (p_qua_information_category       in      varchar2 default null
  ,p_qualification_id               in      number
  ,p_qualification_type_id          in      number
  ,p_qua_information1               in      varchar2 default null
  ,p_qua_information2               in      varchar2 default null
  );

 PROCEDURE validate_create_org_cat
  (p_organization_id		in	number
  ,p_org_information1           in      varchar2
  ) ;

 PROCEDURE create_contract_validate
  (p_status                         in      varchar2
  ,p_effective_date		    in      date
  ,p_ctr_information_category       in      varchar2 default null
  ,p_ctr_information1               in      varchar2 default null
   ) ;

 PROCEDURE update_contract_validate
  (p_contract_id		    in      number   default null
  ,p_status                         in      varchar2
  ,p_effective_date		    in      date
  ,p_ctr_information_category       in      varchar2 default null
  ,p_ctr_information1               in      varchar2 default null
   ) ;

 PROCEDURE workinc_validate
  (p_incident_date                 in     date
  ,p_inc_information_category      in     varchar2 default null
  ,p_inc_information1              in     varchar2 default null
  ,p_inc_information2              in     varchar2 default null
   ) ;

 PROCEDURE create_asg_validate
 ( p_scl_segment12                IN      VARCHAR2  DEFAULT  NULL
  ,p_scl_segment13                IN      VARCHAR2  DEFAULT  NULL
  ,p_scl_segment14                IN      VARCHAR2  DEFAULT  NULL
  ,p_effective_date		  IN	  DATE
  ,p_person_id			  IN	  NUMBER
   ) ;

 PROCEDURE update_asg_validate
 ( p_segment12                IN      VARCHAR2  DEFAULT  NULL
  ,p_segment13                IN      VARCHAR2  DEFAULT  NULL
  ,p_segment14                IN      VARCHAR2  DEFAULT  NULL
  ,p_effective_date		  IN	  DATE
  ,p_assignment_id		  IN	  NUMBER
   ) ;

PROCEDURE CREATE_ELEMENT_ELE_CODE
  (p_information_type         IN VARCHAR2
  ,p_element_type_id          IN NUMBER
  ,p_eei_attribute_category   IN VARCHAR2
  ,p_eei_attribute1           IN VARCHAR2
  ,p_eei_attribute2           IN VARCHAR2
  ,p_eei_attribute3           IN VARCHAR2
  ,p_eei_attribute4           IN VARCHAR2
  ,p_eei_attribute5           IN VARCHAR2
  ,p_eei_attribute6           IN VARCHAR2
  ,p_eei_attribute7           IN VARCHAR2
  ,p_eei_attribute8           IN VARCHAR2
  ,p_eei_attribute9           IN VARCHAR2
  ,p_eei_attribute10          IN VARCHAR2
  ,p_eei_attribute11          IN VARCHAR2
  ,p_eei_attribute12          IN VARCHAR2
  ,p_eei_attribute13          IN VARCHAR2
  ,p_eei_attribute14          IN VARCHAR2
  ,p_eei_attribute15          IN VARCHAR2
  ,p_eei_attribute16          IN VARCHAR2
  ,p_eei_attribute17          IN VARCHAR2
  ,p_eei_attribute18          IN VARCHAR2
  ,p_eei_attribute19          IN VARCHAR2
  ,p_eei_attribute20          IN VARCHAR2
  ,p_eei_information_category IN VARCHAR2
  ,p_eei_information1         IN VARCHAR2
  ,p_eei_information2         IN VARCHAR2
  ,p_eei_information3         IN VARCHAR2
  ,p_eei_information4         IN VARCHAR2
  ,p_eei_information5         IN VARCHAR2
  ,p_eei_information6         IN VARCHAR2
  ,p_eei_information7         IN VARCHAR2
  ,p_eei_information8         IN VARCHAR2
  ,p_eei_information9         IN VARCHAR2
  ,p_eei_information10        IN VARCHAR2
  ,p_eei_information11        IN VARCHAR2
  ,p_eei_information12        IN VARCHAR2
  ,p_eei_information13        IN VARCHAR2
  ,p_eei_information14        IN VARCHAR2
  ,p_eei_information15        IN VARCHAR2
  ,p_eei_information16        IN VARCHAR2
  ,p_eei_information17        IN VARCHAR2
  ,p_eei_information18        IN VARCHAR2
  ,p_eei_information19        IN VARCHAR2
  ,p_eei_information20        IN VARCHAR2
  ,p_eei_information21        IN VARCHAR2
  ,p_eei_information22        IN VARCHAR2
  ,p_eei_information23        IN VARCHAR2
  ,p_eei_information24        IN VARCHAR2
  ,p_eei_information25        IN VARCHAR2
  ,p_eei_information26        IN VARCHAR2
  ,p_eei_information27        IN VARCHAR2
  ,p_eei_information28        IN VARCHAR2
  ,p_eei_information29        IN VARCHAR2
  ,p_eei_information30        IN VARCHAR2
) ;

PROCEDURE UPDATE_ELEMENT_ELE_CODE
  (p_element_type_extra_info_id IN NUMBER
  ,p_eei_attribute_category     IN VARCHAR2
  ,p_eei_attribute1             IN VARCHAR2
  ,p_eei_attribute2             IN VARCHAR2
  ,p_eei_attribute3             IN VARCHAR2
  ,p_eei_attribute4             IN VARCHAR2
  ,p_eei_attribute5             IN VARCHAR2
  ,p_eei_attribute6             IN VARCHAR2
  ,p_eei_attribute7             IN VARCHAR2
  ,p_eei_attribute8             IN VARCHAR2
  ,p_eei_attribute9             IN VARCHAR2
  ,p_eei_attribute10            IN VARCHAR2
  ,p_eei_attribute11            IN VARCHAR2
  ,p_eei_attribute12            IN VARCHAR2
  ,p_eei_attribute13            IN VARCHAR2
  ,p_eei_attribute14            IN VARCHAR2
  ,p_eei_attribute15            IN VARCHAR2
  ,p_eei_attribute16            IN VARCHAR2
  ,p_eei_attribute17            IN VARCHAR2
  ,p_eei_attribute18            IN VARCHAR2
  ,p_eei_attribute19            IN VARCHAR2
  ,p_eei_attribute20            IN VARCHAR2
  ,p_eei_information_category   IN VARCHAR2
  ,p_eei_information1           IN VARCHAR2
  ,p_eei_information2           IN VARCHAR2
  ,p_eei_information3           IN VARCHAR2
  ,p_eei_information4           IN VARCHAR2
  ,p_eei_information5           IN VARCHAR2
  ,p_eei_information6           IN VARCHAR2
  ,p_eei_information7           IN VARCHAR2
  ,p_eei_information8           IN VARCHAR2
  ,p_eei_information9           IN VARCHAR2
  ,p_eei_information10          IN VARCHAR2
  ,p_eei_information11          IN VARCHAR2
  ,p_eei_information12          IN VARCHAR2
  ,p_eei_information13          IN VARCHAR2
  ,p_eei_information14          IN VARCHAR2
  ,p_eei_information15          IN VARCHAR2
  ,p_eei_information16          IN VARCHAR2
  ,p_eei_information17          IN VARCHAR2
  ,p_eei_information18          IN VARCHAR2
  ,p_eei_information19          IN VARCHAR2
  ,p_eei_information20          IN VARCHAR2
  ,p_eei_information21          IN VARCHAR2
  ,p_eei_information22          IN VARCHAR2
  ,p_eei_information23          IN VARCHAR2
  ,p_eei_information24          IN VARCHAR2
  ,p_eei_information25          IN VARCHAR2
  ,p_eei_information26          IN VARCHAR2
  ,p_eei_information27          IN VARCHAR2
  ,p_eei_information28          IN VARCHAR2
  ,p_eei_information29          IN VARCHAR2
  ,p_eei_information30          IN VARCHAR2
  ,p_object_version_number      IN NUMBER
  ) ;


 PROCEDURE update_ele_entry_bp
 ( p_effective_date		  IN	  DATE
   ) ;

 PROCEDURE create_ele_entry_bp
 ( p_effective_date		  IN	  DATE
   ) ;

 PROCEDURE update_ele_entry_ap
 ( p_effective_date		  IN	  DATE
   ) ;

 PROCEDURE create_ele_entry_ap
 ( p_effective_date		  IN	  DATE
   ) ;

 END hr_no_validate_pkg;

/
