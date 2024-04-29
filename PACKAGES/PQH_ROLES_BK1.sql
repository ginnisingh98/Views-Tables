--------------------------------------------------------
--  DDL for Package PQH_ROLES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROLES_BK1" AUTHID CURRENT_USER as
/* $Header: pqrlsapi.pkh 120.1 2005/10/02 02:27:36 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_role_b >-----------------|
-- ----------------------------------------------------------------------------
--
-- mvanakda
-- Added Developer DF Columns to the procedure create_role_b
procedure create_role_b
  (
   p_role_name                    in varchar2
  ,p_role_type_cd                 in varchar2
  ,p_enable_flag                  in varchar2
  ,p_business_group_id            in number
  ,p_effective_date               in date
  ,p_information_category         in varchar2
  ,p_information1                 in varchar2
  ,p_information2                 in varchar2
  ,p_information3                 in varchar2
  ,p_information4	          in varchar2
  ,p_information5                 in varchar2
  ,p_information6	          in varchar2
  ,p_information7                 in varchar2
  ,p_information8	          in varchar2
  ,p_information9                 in varchar2
  ,p_information10	          in varchar2
  ,p_information11                in varchar2
  ,p_information12	          in varchar2
  ,p_information13	          in varchar2
  ,p_information14                in varchar2
  ,p_information15	          in varchar2
  ,p_information16                in varchar2
  ,p_information17	          in varchar2
  ,p_information18                in varchar2
  ,p_information19	          in varchar2
  ,p_information20                in varchar2
  ,p_information21                in varchar2
  ,p_information22	          in varchar2
  ,p_information23	          in varchar2
  ,p_information24                in varchar2
  ,p_information25	          in varchar2
  ,p_information26                in varchar2
  ,p_information27	          in varchar2
  ,p_information28                in varchar2
  ,p_information29	          in varchar2
  ,p_information30                in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_role_a >-----------------|
-- ----------------------------------------------------------------------------
-- -- mvankada
-- Added Developer DF Columns to the procedure create_role_a
procedure create_role_a
  (
   p_role_id                      in number
  ,p_role_name                    in varchar2
  ,p_role_type_cd                 in varchar2
  ,p_enable_flag                  in varchar2
  ,p_object_version_number        in number
  ,p_business_group_id            in number
  ,p_effective_date               in date
  ,p_information_category         in varchar2
  ,p_information1                 in varchar2
  ,p_information2                 in varchar2
  ,p_information3                 in varchar2
  ,p_information4	          in varchar2
  ,p_information5                 in varchar2
  ,p_information6	          in varchar2
  ,p_information7                 in varchar2
  ,p_information8	          in varchar2
  ,p_information9                 in varchar2
  ,p_information10	          in varchar2
  ,p_information11                in varchar2
  ,p_information12	          in varchar2
  ,p_information13	          in varchar2
  ,p_information14                in varchar2
  ,p_information15	          in varchar2
  ,p_information16                in varchar2
  ,p_information17	          in varchar2
  ,p_information18                in varchar2
  ,p_information19	          in varchar2
  ,p_information20                in varchar2
  ,p_information21                in varchar2
  ,p_information22	          in varchar2
  ,p_information23	          in varchar2
  ,p_information24                in varchar2
  ,p_information25	          in varchar2
  ,p_information26                in varchar2
  ,p_information27	          in varchar2
  ,p_information28                in varchar2
  ,p_information29	          in varchar2
  ,p_information30                in varchar2
  );

--
end pqh_roles_bk1;

 

/
