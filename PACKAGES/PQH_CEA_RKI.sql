--------------------------------------------------------
--  DDL for Package PQH_CEA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CEA_RKI" AUTHID CURRENT_USER as
/* $Header: pqcearhi.pkh 120.0 2005/05/29 01:37:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_copy_entity_attrib_id          in number
 ,p_copy_entity_txn_id             in number
 ,p_row_type_cd                    in varchar2
 ,p_information_category           in varchar2
 ,p_information1                   in varchar2
 ,p_information2                   in varchar2
 ,p_information3                   in varchar2
 ,p_information4                   in varchar2
 ,p_information5                   in varchar2
 ,p_information6                   in varchar2
 ,p_information7                   in varchar2
 ,p_information8                   in varchar2
 ,p_information9                   in varchar2
 ,p_information10                  in varchar2
 ,p_information11                  in varchar2
 ,p_information12                  in varchar2
 ,p_information13                  in varchar2
 ,p_information14                  in varchar2
 ,p_information15                  in varchar2
 ,p_information16                  in varchar2
 ,p_information17                  in varchar2
 ,p_information18                  in varchar2
 ,p_information19                  in varchar2
 ,p_information20                  in varchar2
 ,p_information21                  in varchar2
 ,p_information22                  in varchar2
 ,p_information23                  in varchar2
 ,p_information24                  in varchar2
 ,p_information25                  in varchar2
 ,p_information26                  in varchar2
 ,p_information27                  in varchar2
 ,p_information28                  in varchar2
 ,p_information29                  in varchar2
 ,p_information30                  in varchar2
 ,p_check_information1             in varchar2
 ,p_check_information2             in varchar2
 ,p_check_information3             in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end pqh_cea_rki;

 

/
