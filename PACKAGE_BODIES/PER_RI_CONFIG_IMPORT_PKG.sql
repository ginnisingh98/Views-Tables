--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIG_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIG_IMPORT_PKG" as
/* $Header: perricnfimp.pkb 120.0 2005/06/01 00:47:40 appldev noship $ */



Procedure load_configuration( p_configuration_code            In  Varchar2
                             ,p_configuration_type            In  Varchar2
                             ,p_configuration_status          In  Varchar2
                             ,p_configuration_name            In  Varchar2
                             ,p_configuration_description     In  Varchar2
                             ,p_effective_date                In  Date
                             ,p_enterprise_shortname	      In  Varchar2
                            ) Is
 Cursor csr_cnf Is
   Select object_version_number
     From per_ri_configurations
    Where configuration_code = p_configuration_code;


 Cursor csr_ent_shtname  Is
  Select config_information2
  From per_ri_config_information
  Where configuration_code <> p_configuration_code
  And  config_information_category='CONFIG ENTERPRISE'
  And config_information2 = p_enterprise_shortname;


 l_ovn Number;
 l_ent_shtname Varchar2(240);
 import_cnf_exception Exception;
 ent_shtname_exception Exception;
 ldt_file_incomp_exception Exception;

Begin

   Open csr_cnf;
   Fetch csr_cnf Into l_ovn;

   Open csr_ent_shtname;
   Fetch csr_ent_shtname Into l_ent_shtname;

   If(p_enterprise_shortname is null) Then
   RAISE ldt_file_incomp_exception;
   End if;


   If( csr_cnf %Found ) Then
   RAISE  import_cnf_exception ;

   ElsIf ( csr_ent_shtname %Found) Then
   RAISE ent_shtname_exception;

   Else

    per_ri_configuration_api.create_configuration(p_configuration_code             => p_configuration_code
                                                ,p_configuration_type             => p_configuration_type
                                                ,p_configuration_status           => p_configuration_status
                                                ,p_configuration_name             => p_configuration_name
                                                ,p_configuration_description      => p_configuration_description
                                                ,p_effective_date                 => p_effective_date
                                                ,p_object_version_number          => l_ovn
                                              );

   End If;

   Exception
	when import_cnf_exception then
	   FND_MESSAGE.SET_NAME('PER','PER_449451_RI_IMP_CFG_ERR');
	   FND_MESSAGE.SET_TOKEN('CONFIGNAME', p_configuration_name);
	   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

	   FND_MESSAGE.SET_NAME('PER','PER_449452_RI_IMP_CFG_ERR');
	   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
           FND_MESSAGE.raise_error;
       when ent_shtname_exception then
	   FND_MESSAGE.SET_NAME('PER','PER_449564_RI_IMP_ESN_WRN');
	   FND_MESSAGE.SET_TOKEN('ENTERPRISESHTNAME', p_enterprise_shortname);
	   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
  	   FND_MESSAGE.raise_error;
       when ldt_file_incomp_exception then
	   FND_MESSAGE.SET_NAME('PER','PER_449570_RI_IMP_OLD_LDT_ERR');
	   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
	   FND_MESSAGE.raise_error;


End load_configuration;

Procedure load_config_information
                             (p_configuration_code             In  Varchar2
                             ,p_config_information_category    In  Varchar2
                             ,p_config_sequence                In  Number
                             ,p_config_information1            In  Varchar2  Default Null
                             ,p_config_information2            In  Varchar2  Default Null
                             ,p_config_information3            In  Varchar2  Default Null
                             ,p_config_information4            In  Varchar2  Default Null
                             ,p_config_information5            In  Varchar2  Default Null
                             ,p_config_information6            In  Varchar2  Default Null
                             ,p_config_information7            In  Varchar2  Default Null
                             ,p_config_information8            In  Varchar2  Default Null
                             ,p_config_information9            In  Varchar2  Default Null
                             ,p_config_information10           In  Varchar2  Default Null
                             ,p_config_information11           In  Varchar2  Default Null
                             ,p_config_information12           In  Varchar2  Default Null
                             ,p_config_information13           In  Varchar2  Default Null
                             ,p_config_information14           In  Varchar2  Default Null
                             ,p_config_information15           In  Varchar2  Default Null
                             ,p_config_information16           In  Varchar2  Default Null
                             ,p_config_information17           In  Varchar2  Default Null
                             ,p_config_information18           In  Varchar2  Default Null
                             ,p_config_information19           In  Varchar2  Default Null
                             ,p_config_information20           In  Varchar2  Default Null
                             ,p_config_information21           In  Varchar2  Default Null
                             ,p_config_information22           In  Varchar2  Default Null
                             ,p_config_information23           In  Varchar2  Default Null
                             ,p_config_information24           In  Varchar2  Default Null
                             ,p_config_information25           In  Varchar2  Default Null
                             ,p_config_information26           In  Varchar2  Default Null
                             ,p_config_information27           In  Varchar2  Default Null
                             ,p_config_information28           In  Varchar2  Default Null
                             ,p_config_information29           In  Varchar2  Default Null
                             ,p_config_information30           In  Varchar2  Default Null
                             ,p_effective_date                 In  Date
                             ) Is
  Cursor csr_cni Is
   Select object_version_number
        ,config_information_id
     From per_ri_config_information
    Where configuration_code = p_configuration_code
      and config_information_category = p_config_information_category
      and config_sequence = p_config_sequence;


   cursor csr_get_locid (p_location_code varchar2, p_configuration_code varchar2)
   is
   select location_id
   from per_ri_config_locations
   where location_code = p_location_code
   and configuration_code = p_configuration_code;


  l_ovn Number;
  l_cni_id Number;
  l_child_location_id number default null;


Begin

  Open csr_cni;
  Fetch csr_cni Into l_ovn,l_cni_id;

  If csr_cni %NotFound Then
  	If(p_config_information_category ='CONFIG ENTERPRISE' OR p_config_information_category = 'CONFIG LEGAL ENTITY')
  	   Then
  		open csr_get_locid(p_config_information5,p_configuration_code);
  			fetch csr_get_locid into l_child_location_id;

	  per_ri_config_information_api.create_config_information(p_configuration_code          => p_configuration_code
							       ,p_config_information_category   => p_config_information_category
							       ,p_config_sequence               => p_config_sequence
							       ,p_config_information1           => p_config_information1
							       ,p_config_information2           => p_config_information2
							       ,p_config_information3           => p_config_information3
							       ,p_config_information4           => p_config_information4
							       ,p_config_information5           => l_child_location_id
							       ,p_config_information6           => p_config_information6
							       ,p_config_information7           => p_config_information7
							       ,p_config_information8           => p_config_information8
							       ,p_config_information9           => p_config_information9
							       ,p_config_information10          => p_config_information10
							       ,p_config_information11          => p_config_information11
							       ,p_config_information12          => p_config_information12
							       ,p_config_information13          => p_config_information13
							       ,p_config_information14          => p_config_information14
							       ,p_config_information15          => p_config_information15
							       ,p_config_information16          => p_config_information16
							       ,p_config_information17          => p_config_information17
							       ,p_config_information18          => p_config_information18
							       ,p_config_information19          => p_config_information19
							       ,p_config_information20          => p_config_information20
							       ,p_config_information21          => p_config_information21
							       ,p_config_information22          => p_config_information22
							       ,p_config_information23          => p_config_information23
							       ,p_config_information24          => p_config_information24
							       ,p_config_information25          => p_config_information25
							       ,p_config_information26          => p_config_information26
							       ,p_config_information27          => p_config_information27
							       ,p_config_information28          => p_config_information28
							       ,p_config_information29          => p_config_information29
							       ,p_config_information30          => p_config_information30
							       ,p_effective_date                => p_effective_date
							       ,p_object_version_number         => l_ovn
							       ,p_config_information_id         => l_cni_id
							       );
	 close csr_get_locid;


	ElsIf(p_config_information_category ='CONFIG OPERATING COMPANY')
	 Then
	   	open csr_get_locid(p_config_information4,p_configuration_code);
	     			fetch csr_get_locid into l_child_location_id;
		 per_ri_config_information_api.create_config_information(p_configuration_code          => p_configuration_code
							       ,p_config_information_category   => p_config_information_category
							       ,p_config_sequence               => p_config_sequence
							       ,p_config_information1           => p_config_information1
							       ,p_config_information2           => p_config_information2
							       ,p_config_information3           => p_config_information3
							       ,p_config_information4           => l_child_location_id
							       ,p_config_information5           => p_config_information5
							       ,p_config_information6           => p_config_information6
							       ,p_config_information7           => p_config_information7
							       ,p_config_information8           => p_config_information8
							       ,p_config_information9           => p_config_information9
							       ,p_config_information10          => p_config_information10
							       ,p_config_information11          => p_config_information11
							       ,p_config_information12          => p_config_information12
							       ,p_config_information13          => p_config_information13
							       ,p_config_information14          => p_config_information14
							       ,p_config_information15          => p_config_information15
							       ,p_config_information16          => p_config_information16
							       ,p_config_information17          => p_config_information17
							       ,p_config_information18          => p_config_information18
							       ,p_config_information19          => p_config_information19
							       ,p_config_information20          => p_config_information20
							       ,p_config_information21          => p_config_information21
							       ,p_config_information22          => p_config_information22
							       ,p_config_information23          => p_config_information23
							       ,p_config_information24          => p_config_information24
							       ,p_config_information25          => p_config_information25
							       ,p_config_information26          => p_config_information26
							       ,p_config_information27          => p_config_information27
							       ,p_config_information28          => p_config_information28
							       ,p_config_information29          => p_config_information29
							       ,p_config_information30          => p_config_information30
							       ,p_effective_date                => p_effective_date
							       ,p_object_version_number         => l_ovn
							       ,p_config_information_id         => l_cni_id
							       );
	 close csr_get_locid;


	Else
		 per_ri_config_information_api.create_config_information(p_configuration_code          => p_configuration_code
							       ,p_config_information_category   => p_config_information_category
							       ,p_config_sequence               => p_config_sequence
							       ,p_config_information1           => p_config_information1
							       ,p_config_information2           => p_config_information2
							       ,p_config_information3           => p_config_information3
							       ,p_config_information4           => p_config_information4
							       ,p_config_information5           => p_config_information5
							       ,p_config_information6           => p_config_information6
							       ,p_config_information7           => p_config_information7
							       ,p_config_information8           => p_config_information8
							       ,p_config_information9           => p_config_information9
							       ,p_config_information10          => p_config_information10
							       ,p_config_information11          => p_config_information11
							       ,p_config_information12          => p_config_information12
							       ,p_config_information13          => p_config_information13
							       ,p_config_information14          => p_config_information14
							       ,p_config_information15          => p_config_information15
							       ,p_config_information16          => p_config_information16
							       ,p_config_information17          => p_config_information17
							       ,p_config_information18          => p_config_information18
							       ,p_config_information19          => p_config_information19
							       ,p_config_information20          => p_config_information20
							       ,p_config_information21          => p_config_information21
							       ,p_config_information22          => p_config_information22
							       ,p_config_information23          => p_config_information23
							       ,p_config_information24          => p_config_information24
							       ,p_config_information25          => p_config_information25
							       ,p_config_information26          => p_config_information26
							       ,p_config_information27          => p_config_information27
							       ,p_config_information28          => p_config_information28
							       ,p_config_information29          => p_config_information29
							       ,p_config_information30          => p_config_information30
							       ,p_effective_date                => p_effective_date
							       ,p_object_version_number         => l_ovn
							       ,p_config_information_id         => l_cni_id
							       );





	End If;



  End If;


End load_config_information;


Procedure load_config_location(p_configuration_code            In  Varchar2
                             ,p_configuration_context          In  Varchar2
                             ,p_location_code                  In  Varchar2
                             ,p_description                    In  Varchar2  Default Null
                             ,p_style                          In  Varchar2  Default Null
                             ,p_address_line_1                 In  Varchar2  Default Null
                             ,p_address_line_2                 In  Varchar2  Default Null
                             ,p_address_line_3                 In  Varchar2  Default Null
                             ,p_town_or_city                   In  Varchar2  Default Null
                             ,p_country                        In  Varchar2  Default Null
                             ,p_postal_code                    In  Varchar2  Default Null
                             ,p_region_1                       In  Varchar2  Default Null
                             ,p_region_2                       In  Varchar2  Default Null
                             ,p_region_3                       In  Varchar2  Default Null
                             ,p_telephone_number_1             In  Varchar2  Default Null
                             ,p_telephone_number_2             In  Varchar2  Default Null
                             ,p_telephone_number_3             In  Varchar2  Default Null
                             ,p_loc_information13              In  Varchar2  Default Null
                             ,p_loc_information14              In  Varchar2  Default Null
                             ,p_loc_information15              In  Varchar2  Default Null
                             ,p_loc_information16              In  Varchar2  Default Null
                             ,p_loc_information17              In  Varchar2  Default Null
                             ,p_loc_information18              In  Varchar2  Default Null
                             ,p_loc_information19              In  Varchar2  Default Null
                             ,p_loc_information20              In  Varchar2  Default Null
                             ,p_effective_date                 In  Date
                             ) Is

   Cursor csr_cnl Is
    Select object_version_number , location_id
      From per_ri_config_locations
     Where configuration_code    = p_configuration_code
       and configuration_context = p_configuration_context
       and location_code         = p_location_code;

l_ovn Number;
l_location_id Number;

Begin

  Open csr_cnl;
  Fetch csr_cnl Into l_ovn,l_location_id;

  If csr_cnl%NotFound Then

  per_ri_config_location_api.create_location(p_configuration_code          => p_configuration_code
                                        ,p_configuration_context           => p_configuration_context
                                        ,p_location_code                   => p_location_code
                                        ,p_description                     => p_description
                                        ,p_style                           => p_style
                                        ,p_address_line_1                  => p_address_line_1
                                        ,p_address_line_2                  => p_address_line_2
                                        ,p_address_line_3                  => p_address_line_3
                                        ,p_town_or_city                    => p_town_or_city
                                        ,p_country                         => p_country
                                        ,p_postal_code                     => p_postal_code
                                        ,p_region_1                        => p_region_1
                                        ,p_region_2                        => p_region_2
                                        ,p_region_3                        => p_region_3
                                        ,p_telephone_number_1              => p_telephone_number_1
                                        ,p_telephone_number_2              => p_telephone_number_2
                                        ,p_telephone_number_3              => p_telephone_number_3
                                        ,p_loc_information13               => p_loc_information13
                                        ,p_loc_information14               => p_loc_information14
                                        ,p_loc_information15               => p_loc_information15
                                        ,p_loc_information16               => p_loc_information16
                                        ,p_loc_information17               => p_loc_information17
                                        ,p_loc_information18               => p_loc_information18
                                        ,p_loc_information19               => p_loc_information19
                                        ,p_loc_information20               => p_loc_information20
                                        ,p_effective_date                  => p_effective_date
                                        ,p_object_version_number           => l_ovn
                                        ,p_location_id                     => l_location_id
                                        );






  End If;


End load_config_location;

End per_ri_config_import_pkg;

/
