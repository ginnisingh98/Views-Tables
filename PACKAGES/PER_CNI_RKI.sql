--------------------------------------------------------
--  DDL for Package PER_CNI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CNI_RKI" AUTHID CURRENT_USER as
/* $Header: pecnirhi.pkh 120.0 2005/05/31 06:49:33 appldev noship $ */
 --
 -- ----------------------------------------------------------------------------
 -- |-----------------------------< after_insert >-----------------------------|
 -- ----------------------------------------------------------------------------
 --
 procedure after_insert
   (p_effective_date               in date
   ,p_configuration_code           in varchar2
   ,p_config_information_category  in varchar2
   ,p_config_information1          in varchar2
   ,p_config_information2          in varchar2
   ,p_config_information3          in varchar2
   ,p_config_information4          in varchar2
   ,p_config_information5          in varchar2
   ,p_config_information6          in varchar2
   ,p_config_information7          in varchar2
   ,p_config_information8          in varchar2
   ,p_config_information9          in varchar2
   ,p_config_information10         in varchar2
   ,p_config_information11         in varchar2
   ,p_config_information12         in varchar2
   ,p_config_information13         in varchar2
   ,p_config_information14         in varchar2
   ,p_config_information15         in varchar2
   ,p_config_information16         in varchar2
   ,p_config_information17         in varchar2
   ,p_config_information18         in varchar2
   ,p_config_information19         in varchar2
   ,p_config_information20         in varchar2
   ,p_config_information21         in varchar2
   ,p_config_information22         in varchar2
   ,p_config_information23         in varchar2
   ,p_config_information24         in varchar2
   ,p_config_information25         in varchar2
   ,p_config_information26         in varchar2
   ,p_config_information27         in varchar2
   ,p_config_information28         in varchar2
   ,p_config_information29         in varchar2
   ,p_config_information30         in varchar2
   ,p_config_information_id        in number
   ,p_config_sequence              in number
   );
 end per_cni_rki;

 

/
