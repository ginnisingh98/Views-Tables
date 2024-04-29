--------------------------------------------------------
--  DDL for Package Body PER_RI_MNG_CFG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_MNG_CFG_PKG" AS
/* $Header: perrimngcfg.pkb 120.0 2005/06/01 00:51:47 appldev noship $ */

PROCEDURE delete_configuration
(
	p_config_code 	 In Varchar2	,
	p_ovn		 In  Number	,
	p_msg 		 Out nocopy Varchar2
)


Is
cursor csr_config_info is
select CONFIG_INFORMATION_ID  , OBJECT_VERSION_NUMBER
from per_ri_config_information
where CONFIGURATION_CODE = p_config_code;

cursor csr_config_loc is
select location_id , OBJECT_VERSION_NUMBER
from per_ri_config_locations
where CONFIGURATION_CODE = p_config_code;

begin

for rec in csr_config_info loop

per_ri_config_information_api.DELETE_CONFIG_INFORMATION
(
P_VALIDATE                     => false,
P_CONFIG_INFORMATION_ID        => rec.CONFIG_INFORMATION_ID ,
P_OBJECT_VERSION_NUMBER        => rec.OBJECT_VERSION_NUMBER
);

end loop;


for rec in csr_config_loc loop

per_ri_config_location_api.DELETE_LOCATION
(
P_VALIDATE                     => false,
P_LOCATION_ID          	       => rec.location_id ,
P_OBJECT_VERSION_NUMBER        => rec.OBJECT_VERSION_NUMBER
);
end loop;


per_ri_configuration_api.DELETE_CONFIGURATION
(
 P_VALIDATE                     => false,
 P_CONFIGURATION_CODE           => p_config_code,
 P_OBJECT_VERSION_NUMBER        => p_ovn
);


commit;

p_msg:= 'SUCCESS';

End delete_configuration;






-- duplicate_configuration
/*config code is same as the config name*/
PROCEDURE duplicate_configuration
(
	p_config_code 	 In Varchar2	,--config code of the config which is to be duplicated
	p_config_name 	 In Varchar2	,--config name as entered by the user
	p_config_desc	 In  Varchar2	,
	p_esn		 In Varchar2	,
	p_msg 		 Out nocopy Varchar2

)

Is

-- p_configuration_code : config code of the new duplicate configuration.
-- p_location_id	: locationid of the parent configuration's per_ri_config_information row.

cursor csr_get_locid (p_location_id number, p_configuration_code varchar2)
is
 select loc2.location_id
 from per_ri_config_locations loc1,per_ri_config_locations loc2
 where loc2.CONFIGURATION_CODE = p_configuration_code
 and  loc1.location_id = p_location_id
 and  loc2.location_code = loc1.location_code
 and loc1.location_id <> loc2.location_id;



cursor csr_config_copy is
select
 CONFIGURATION_CODE             ,
 CONFIGURATION_TYPE             ,
 CONFIGURATION_STATUS           ,
 CONFIGURATION_NAME             ,
 CONFIGURATION_DESCRIPTION      ,
 OBJECT_VERSION_NUMBER          ,
 LAST_UPDATE_DATE               ,
 LAST_UPDATED_BY                ,
 LAST_UPDATE_LOGIN              ,
 CREATED_BY                     ,
 CREATION_DATE
 from per_ri_configurations_vl
 where CONFIGURATION_CODE = p_config_code;




cursor csr_config_info is
select CONFIG_INFORMATION_ID  ,
 CONFIG_SEQUENCE                ,
 CONFIG_INFORMATION_CATEGORY    ,
 CONFIG_INFORMATION1            ,
 CONFIG_INFORMATION2            ,
 CONFIG_INFORMATION3            ,
 CONFIG_INFORMATION4            ,
 CONFIG_INFORMATION5            ,
 CONFIG_INFORMATION6            ,
 CONFIG_INFORMATION7            ,
 CONFIG_INFORMATION8            ,
 CONFIG_INFORMATION9            ,
 CONFIG_INFORMATION10           ,
 CONFIG_INFORMATION11           ,
 CONFIG_INFORMATION12           ,
 CONFIG_INFORMATION13           ,
 CONFIG_INFORMATION14           ,
 CONFIG_INFORMATION15           ,
 CONFIG_INFORMATION16           ,
 CONFIG_INFORMATION17           ,
 CONFIG_INFORMATION18           ,
 CONFIG_INFORMATION19           ,
 CONFIG_INFORMATION20           ,
 CONFIG_INFORMATION21           ,
 CONFIG_INFORMATION22           ,
 CONFIG_INFORMATION23           ,
 CONFIG_INFORMATION24           ,
 CONFIG_INFORMATION25           ,
 CONFIG_INFORMATION26           ,
 CONFIG_INFORMATION27           ,
 CONFIG_INFORMATION28           ,
 CONFIG_INFORMATION29           ,
 CONFIG_INFORMATION30           ,
 LAST_UPDATE_DATE               ,
 LAST_UPDATED_BY                ,
 LAST_UPDATE_LOGIN              ,
 CREATED_BY                     ,
 CREATION_DATE
from per_ri_config_information
where CONFIGURATION_CODE = p_config_code;


cursor csr_config_loc is
select
 CONFIGURATION_CONTEXT          ,
 LOCATION_CODE                  ,
 DESCRIPTION                    ,
 STYLE                          ,
 ADDRESS_LINE_1                 ,
 ADDRESS_LINE_2                 ,
 ADDRESS_LINE_3                 ,
 TOWN_OR_CITY                   ,
 COUNTRY                        ,
 POSTAL_CODE                    ,
 REGION_1                       ,
 REGION_2                       ,
 REGION_3                       ,
 TELEPHONE_NUMBER_1             ,
 TELEPHONE_NUMBER_2             ,
 TELEPHONE_NUMBER_3             ,
 LOC_INFORMATION13              ,
 LOC_INFORMATION14              ,
 LOC_INFORMATION15              ,
 LOC_INFORMATION16              ,
 LOC_INFORMATION17              ,
 LOC_INFORMATION18              ,
 LOC_INFORMATION19              ,
 LOC_INFORMATION20              ,
 LAST_UPDATE_DATE               ,
 LAST_UPDATED_BY                ,
 LAST_UPDATE_LOGIN              ,
 CREATED_BY                     ,
 CREATION_DATE
 from per_ri_config_locations
where CONFIGURATION_CODE = p_config_code;



cursor csr_config_copy_exists is
select 1
from per_ri_configurations_vl
where configuration_code = p_config_name;



l_config_ovn number;
l_config_info_id number;
l_config_info_ovn number;
l_config_loc_ovn number;
l_config_loc_id number;
l_dummy number;
l_config_code varchar(100);
l_child_location_id number;




begin

l_config_code:=upper(p_config_name);
l_config_code :=replace(l_config_code,' ','_');


open csr_config_copy_exists;
  fetch csr_config_copy_exists into l_dummy;
	if(csr_config_copy_exists%NOTFOUND)
	 then

		for rec in csr_config_copy loop
		per_ri_configuration_api.CREATE_CONFIGURATION
		(
		 P_VALIDATE                     => false,
		 P_CONFIGURATION_CODE           => l_config_code,
		 P_CONFIGURATION_TYPE           => rec.CONFIGURATION_TYPE ,
		 P_CONFIGURATION_STATUS         => 'COMPLETE',
		 P_CONFIGURATION_NAME           => p_config_name,
		 P_CONFIGURATION_DESCRIPTION    => p_config_desc,
		 P_LANGUAGE_CODE                => 'US',
		 P_EFFECTIVE_DATE               => SYSDATE,
		 P_OBJECT_VERSION_NUMBER        => l_config_ovn
		 );

		 end loop; -- this loop will run only once.

		for rec in csr_config_loc loop

		per_ri_config_location_api.CREATE_LOCATION
		(
		 P_VALIDATE                     => false,
		 P_CONFIGURATION_CODE           => l_config_code,
		 P_CONFIGURATION_CONTEXT        => rec.CONFIGURATION_CONTEXT,
		 P_LOCATION_CODE                => rec.LOCATION_CODE,
		 P_DESCRIPTION                  => rec.DESCRIPTION,
		 P_STYLE                        => rec.STYLE,
		 P_ADDRESS_LINE_1               => rec.ADDRESS_LINE_1,
		 P_ADDRESS_LINE_2               => rec.ADDRESS_LINE_2,
		 P_ADDRESS_LINE_3               => rec.ADDRESS_LINE_3,
		 P_TOWN_OR_CITY                 => rec.TOWN_OR_CITY,
		 P_COUNTRY                      => rec.COUNTRY,
		 P_POSTAL_CODE                  => rec.POSTAL_CODE,
		 P_REGION_1                     => rec.REGION_1 ,
		 P_REGION_2                     => rec.REGION_2,
		 P_REGION_3                     => rec.REGION_3,
		 P_TELEPHONE_NUMBER_1           => rec.TELEPHONE_NUMBER_1,
		 P_TELEPHONE_NUMBER_2           => rec.TELEPHONE_NUMBER_2,
		 P_TELEPHONE_NUMBER_3           => rec.TELEPHONE_NUMBER_3,
		 P_LOC_INFORMATION13            => rec.LOC_INFORMATION13 ,
		 P_LOC_INFORMATION14            => rec.LOC_INFORMATION14 ,
		 P_LOC_INFORMATION15            => rec.LOC_INFORMATION15 ,
		 P_LOC_INFORMATION16            => rec.LOC_INFORMATION16 ,
		 P_LOC_INFORMATION17            => rec.LOC_INFORMATION17 ,
		 P_LOC_INFORMATION18            => rec.LOC_INFORMATION18 ,
		 P_LOC_INFORMATION19            => rec.LOC_INFORMATION19 ,
		 P_LOC_INFORMATION20            => rec.LOC_INFORMATION20 ,
		 P_LANGUAGE_CODE                => 'US',
		 P_EFFECTIVE_DATE               => SYSDATE,
		 P_OBJECT_VERSION_NUMBER        => l_config_loc_ovn,
		 P_LOCATION_ID                  => l_config_loc_id
		);
		end loop;







		for rec in csr_config_info loop


		l_child_location_id := null;

		if(rec.CONFIG_INFORMATION_CATEGORY = 'CONFIG LEGAL ENTITY')
		then

		open csr_get_locid(rec.CONFIG_INFORMATION5,l_config_code);
			fetch csr_get_locid into l_child_location_id;
		per_ri_config_information_api.CREATE_CONFIG_INFORMATION
		(
		 P_VALIDATE                     => false,
		 P_CONFIGURATION_CODE           => l_config_code,
		 P_CONFIG_INFORMATION_CATEGORY  => rec.CONFIG_INFORMATION_CATEGORY ,
		 P_CONFIG_SEQUENCE              => rec.CONFIG_SEQUENCE    ,
		 P_CONFIG_INFORMATION1          => rec.CONFIG_INFORMATION1,
		 P_CONFIG_INFORMATION2          => rec.CONFIG_INFORMATION2,
		 P_CONFIG_INFORMATION3          => rec.CONFIG_INFORMATION3,
		 P_CONFIG_INFORMATION4          => rec.CONFIG_INFORMATION4,
		 P_CONFIG_INFORMATION5          => l_child_location_id,
		 P_CONFIG_INFORMATION6          => rec.CONFIG_INFORMATION6,
		 P_CONFIG_INFORMATION7          => rec.CONFIG_INFORMATION7,
		 P_CONFIG_INFORMATION8          => rec.CONFIG_INFORMATION8,
		 P_CONFIG_INFORMATION9          => rec.CONFIG_INFORMATION9,
		 P_CONFIG_INFORMATION10         => rec.CONFIG_INFORMATION10,
		 P_CONFIG_INFORMATION11         => rec.CONFIG_INFORMATION11,
		 P_CONFIG_INFORMATION12         => rec.CONFIG_INFORMATION12,
		 P_CONFIG_INFORMATION13         => rec.CONFIG_INFORMATION13,
		 P_CONFIG_INFORMATION14         => rec.CONFIG_INFORMATION14,
		 P_CONFIG_INFORMATION15         => rec.CONFIG_INFORMATION15,
		 P_CONFIG_INFORMATION16         => rec.CONFIG_INFORMATION16,
		 P_CONFIG_INFORMATION17         => rec.CONFIG_INFORMATION17,
		 P_CONFIG_INFORMATION18         => rec.CONFIG_INFORMATION18,
		 P_CONFIG_INFORMATION19         => rec.CONFIG_INFORMATION19,
		 P_CONFIG_INFORMATION20         => rec.CONFIG_INFORMATION20,
		 P_CONFIG_INFORMATION21         => rec.CONFIG_INFORMATION21,
		 P_CONFIG_INFORMATION22         => rec.CONFIG_INFORMATION22,
		 P_CONFIG_INFORMATION23         => rec.CONFIG_INFORMATION23,
		 P_CONFIG_INFORMATION24         => rec.CONFIG_INFORMATION24,
		 P_CONFIG_INFORMATION25         => rec.CONFIG_INFORMATION25,
		 P_CONFIG_INFORMATION26         => rec.CONFIG_INFORMATION26,
		 P_CONFIG_INFORMATION27         => rec.CONFIG_INFORMATION27,
		 P_CONFIG_INFORMATION28         => rec.CONFIG_INFORMATION28,
		 P_CONFIG_INFORMATION29         => rec.CONFIG_INFORMATION29,
		 P_CONFIG_INFORMATION30         => rec.CONFIG_INFORMATION30,
		 P_LANGUAGE_CODE                => 'US',
		 P_EFFECTIVE_DATE               => SYSDATE,
		 P_CONFIG_INFORMATION_ID        => l_config_info_id,
		 P_OBJECT_VERSION_NUMBER        => l_config_info_ovn

		 );

		close csr_get_locid;
		elsif(rec.CONFIG_INFORMATION_CATEGORY = 'CONFIG ENTERPRISE')
		then

		open csr_get_locid(rec.CONFIG_INFORMATION5,l_config_code);
			fetch csr_get_locid into l_child_location_id;
		per_ri_config_information_api.CREATE_CONFIG_INFORMATION
		(
		 P_VALIDATE                     => false,
		 P_CONFIGURATION_CODE           => l_config_code,
		 P_CONFIG_INFORMATION_CATEGORY  => rec.CONFIG_INFORMATION_CATEGORY ,
		 P_CONFIG_SEQUENCE              => rec.CONFIG_SEQUENCE    ,
		 P_CONFIG_INFORMATION1          => rec.CONFIG_INFORMATION1,
		 P_CONFIG_INFORMATION2          => p_esn,		  --ENTERPRISE SHORT NAME
		 P_CONFIG_INFORMATION3          => rec.CONFIG_INFORMATION3,
		 P_CONFIG_INFORMATION4          => rec.CONFIG_INFORMATION4,
		 P_CONFIG_INFORMATION5          => l_child_location_id,
		 P_CONFIG_INFORMATION6          => rec.CONFIG_INFORMATION6,
		 P_CONFIG_INFORMATION7          => rec.CONFIG_INFORMATION7,
		 P_CONFIG_INFORMATION8          => rec.CONFIG_INFORMATION8,
		 P_CONFIG_INFORMATION9          => rec.CONFIG_INFORMATION9,
		 P_CONFIG_INFORMATION10         => rec.CONFIG_INFORMATION10,
		 P_CONFIG_INFORMATION11         => rec.CONFIG_INFORMATION11,
		 P_CONFIG_INFORMATION12         => rec.CONFIG_INFORMATION12,
		 P_CONFIG_INFORMATION13         => rec.CONFIG_INFORMATION13,
		 P_CONFIG_INFORMATION14         => rec.CONFIG_INFORMATION14,
		 P_CONFIG_INFORMATION15         => rec.CONFIG_INFORMATION15,
		 P_CONFIG_INFORMATION16         => rec.CONFIG_INFORMATION16,
		 P_CONFIG_INFORMATION17         => rec.CONFIG_INFORMATION17,
		 P_CONFIG_INFORMATION18         => rec.CONFIG_INFORMATION18,
		 P_CONFIG_INFORMATION19         => rec.CONFIG_INFORMATION19,
		 P_CONFIG_INFORMATION20         => rec.CONFIG_INFORMATION20,
		 P_CONFIG_INFORMATION21         => rec.CONFIG_INFORMATION21,
		 P_CONFIG_INFORMATION22         => rec.CONFIG_INFORMATION22,
		 P_CONFIG_INFORMATION23         => rec.CONFIG_INFORMATION23,
		 P_CONFIG_INFORMATION24         => rec.CONFIG_INFORMATION24,
		 P_CONFIG_INFORMATION25         => rec.CONFIG_INFORMATION25,
		 P_CONFIG_INFORMATION26         => rec.CONFIG_INFORMATION26,
		 P_CONFIG_INFORMATION27         => rec.CONFIG_INFORMATION27,
		 P_CONFIG_INFORMATION28         => rec.CONFIG_INFORMATION28,
		 P_CONFIG_INFORMATION29         => rec.CONFIG_INFORMATION29,
		 P_CONFIG_INFORMATION30         => rec.CONFIG_INFORMATION30,
		 P_LANGUAGE_CODE                => 'US',
		 P_EFFECTIVE_DATE               => SYSDATE,
		 P_CONFIG_INFORMATION_ID        => l_config_info_id,
		 P_OBJECT_VERSION_NUMBER        => l_config_info_ovn

		 );

		 close csr_get_locid;

		elsif(rec.CONFIG_INFORMATION_CATEGORY = 'CONFIG OPERATING COMPANY')
		  then
		open csr_get_locid(rec.CONFIG_INFORMATION4,l_config_code);
			fetch csr_get_locid into l_child_location_id;

		per_ri_config_information_api.CREATE_CONFIG_INFORMATION
		(
		 P_VALIDATE                     => false,
		 P_CONFIGURATION_CODE           => l_config_code,
		 P_CONFIG_INFORMATION_CATEGORY  => rec.CONFIG_INFORMATION_CATEGORY ,
		 P_CONFIG_SEQUENCE              => rec.CONFIG_SEQUENCE    ,
		 P_CONFIG_INFORMATION1          => rec.CONFIG_INFORMATION1,
		 P_CONFIG_INFORMATION2          => rec.CONFIG_INFORMATION2,
		 P_CONFIG_INFORMATION3          => rec.CONFIG_INFORMATION3,
		 P_CONFIG_INFORMATION4          => l_child_location_id,
		 P_CONFIG_INFORMATION5          => rec.CONFIG_INFORMATION5,
		 P_CONFIG_INFORMATION6          => rec.CONFIG_INFORMATION6,
		 P_CONFIG_INFORMATION7          => rec.CONFIG_INFORMATION7,
		 P_CONFIG_INFORMATION8          => rec.CONFIG_INFORMATION8,
		 P_CONFIG_INFORMATION9          => rec.CONFIG_INFORMATION9,
		 P_CONFIG_INFORMATION10         => rec.CONFIG_INFORMATION10,
		 P_CONFIG_INFORMATION11         => rec.CONFIG_INFORMATION11,
		 P_CONFIG_INFORMATION12         => rec.CONFIG_INFORMATION12,
		 P_CONFIG_INFORMATION13         => rec.CONFIG_INFORMATION13,
		 P_CONFIG_INFORMATION14         => rec.CONFIG_INFORMATION14,
		 P_CONFIG_INFORMATION15         => rec.CONFIG_INFORMATION15,
		 P_CONFIG_INFORMATION16         => rec.CONFIG_INFORMATION16,
		 P_CONFIG_INFORMATION17         => rec.CONFIG_INFORMATION17,
		 P_CONFIG_INFORMATION18         => rec.CONFIG_INFORMATION18,
		 P_CONFIG_INFORMATION19         => rec.CONFIG_INFORMATION19,
		 P_CONFIG_INFORMATION20         => rec.CONFIG_INFORMATION20,
		 P_CONFIG_INFORMATION21         => rec.CONFIG_INFORMATION21,
		 P_CONFIG_INFORMATION22         => rec.CONFIG_INFORMATION22,
		 P_CONFIG_INFORMATION23         => rec.CONFIG_INFORMATION23,
		 P_CONFIG_INFORMATION24         => rec.CONFIG_INFORMATION24,
		 P_CONFIG_INFORMATION25         => rec.CONFIG_INFORMATION25,
		 P_CONFIG_INFORMATION26         => rec.CONFIG_INFORMATION26,
		 P_CONFIG_INFORMATION27         => rec.CONFIG_INFORMATION27,
		 P_CONFIG_INFORMATION28         => rec.CONFIG_INFORMATION28,
		 P_CONFIG_INFORMATION29         => rec.CONFIG_INFORMATION29,
		 P_CONFIG_INFORMATION30         => rec.CONFIG_INFORMATION30,
		 P_LANGUAGE_CODE                => 'US',
		 P_EFFECTIVE_DATE               => SYSDATE,
		 P_CONFIG_INFORMATION_ID        => l_config_info_id,
		 P_OBJECT_VERSION_NUMBER        => l_config_info_ovn

		 );

		 close csr_get_locid;

		 else
		per_ri_config_information_api.CREATE_CONFIG_INFORMATION
		(
		 P_VALIDATE                     => false,
		 P_CONFIGURATION_CODE           => l_config_code,
		 P_CONFIG_INFORMATION_CATEGORY  => rec.CONFIG_INFORMATION_CATEGORY ,
		 P_CONFIG_SEQUENCE              => rec.CONFIG_SEQUENCE    ,
		 P_CONFIG_INFORMATION1          => rec.CONFIG_INFORMATION1,
		 P_CONFIG_INFORMATION2          => rec.CONFIG_INFORMATION2,
		 P_CONFIG_INFORMATION3          => rec.CONFIG_INFORMATION3,
		 P_CONFIG_INFORMATION4          => rec.CONFIG_INFORMATION4,
		 P_CONFIG_INFORMATION5          => rec.CONFIG_INFORMATION5,
		 P_CONFIG_INFORMATION6          => rec.CONFIG_INFORMATION6,
		 P_CONFIG_INFORMATION7          => rec.CONFIG_INFORMATION7,
		 P_CONFIG_INFORMATION8          => rec.CONFIG_INFORMATION8,
		 P_CONFIG_INFORMATION9          => rec.CONFIG_INFORMATION9,
		 P_CONFIG_INFORMATION10         => rec.CONFIG_INFORMATION10,
		 P_CONFIG_INFORMATION11         => rec.CONFIG_INFORMATION11,
		 P_CONFIG_INFORMATION12         => rec.CONFIG_INFORMATION12,
		 P_CONFIG_INFORMATION13         => rec.CONFIG_INFORMATION13,
		 P_CONFIG_INFORMATION14         => rec.CONFIG_INFORMATION14,
		 P_CONFIG_INFORMATION15         => rec.CONFIG_INFORMATION15,
		 P_CONFIG_INFORMATION16         => rec.CONFIG_INFORMATION16,
		 P_CONFIG_INFORMATION17         => rec.CONFIG_INFORMATION17,
		 P_CONFIG_INFORMATION18         => rec.CONFIG_INFORMATION18,
		 P_CONFIG_INFORMATION19         => rec.CONFIG_INFORMATION19,
		 P_CONFIG_INFORMATION20         => rec.CONFIG_INFORMATION20,
		 P_CONFIG_INFORMATION21         => rec.CONFIG_INFORMATION21,
		 P_CONFIG_INFORMATION22         => rec.CONFIG_INFORMATION22,
		 P_CONFIG_INFORMATION23         => rec.CONFIG_INFORMATION23,
		 P_CONFIG_INFORMATION24         => rec.CONFIG_INFORMATION24,
		 P_CONFIG_INFORMATION25         => rec.CONFIG_INFORMATION25,
		 P_CONFIG_INFORMATION26         => rec.CONFIG_INFORMATION26,
		 P_CONFIG_INFORMATION27         => rec.CONFIG_INFORMATION27,
		 P_CONFIG_INFORMATION28         => rec.CONFIG_INFORMATION28,
		 P_CONFIG_INFORMATION29         => rec.CONFIG_INFORMATION29,
		 P_CONFIG_INFORMATION30         => rec.CONFIG_INFORMATION30,
		 P_LANGUAGE_CODE                => 'US',
		 P_EFFECTIVE_DATE               => SYSDATE,
		 P_CONFIG_INFORMATION_ID        => l_config_info_id,
		 P_OBJECT_VERSION_NUMBER        => l_config_info_ovn

		 );
 		 end if;

		 end loop;




		p_msg:= 'SUCCESS';
	  else
	     	p_msg := 'ERROR';

	end if;

 close csr_config_copy_exists ;


end duplicate_configuration;




END per_ri_mng_cfg_pkg;



/
