--------------------------------------------------------
--  DDL for Package PQH_PTX_EXTRA_INFO_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PTX_EXTRA_INFO_BK2" AUTHID CURRENT_USER as
/* $Header: pqpteapi.pkh 120.0 2005/05/29 02:20:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ptx_extra_info_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ptx_extra_info_b
  (
   p_ptx_extra_info_id              in  number
  ,p_information_type               in  varchar2
  ,p_position_transaction_id        in  number
  ,p_position_extra_info_id         in  number
  ,p_information_category           in  varchar2
  ,p_information1                   in  varchar2
  ,p_information2                   in  varchar2
  ,p_information3                   in  varchar2
  ,p_information4                   in  varchar2
  ,p_information5                   in  varchar2
  ,p_information6                   in  varchar2
  ,p_information7                   in  varchar2
  ,p_information8                   in  varchar2
  ,p_information9                   in  varchar2
  ,p_information10                  in  varchar2
  ,p_information11                  in  varchar2
  ,p_information12                  in  varchar2
  ,p_information13                  in  varchar2
  ,p_information14                  in  varchar2
  ,p_information15                  in  varchar2
  ,p_information16                  in  varchar2
  ,p_information17                  in  varchar2
  ,p_information18                  in  varchar2
  ,p_information19                  in  varchar2
  ,p_information20                  in  varchar2
  ,p_information21                  in  varchar2
  ,p_information22                  in  varchar2
  ,p_information23                  in  varchar2
  ,p_information24                  in  varchar2
  ,p_information25                  in  varchar2
  ,p_information26                  in  varchar2
  ,p_information27                  in  varchar2
  ,p_information28                  in  varchar2
  ,p_information29                  in  varchar2
  ,p_information30                  in  varchar2
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ptx_extra_info_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ptx_extra_info_a
  (
   p_ptx_extra_info_id              in  number
  ,p_information_type               in  varchar2
  ,p_position_transaction_id        in  number
  ,p_position_extra_info_id         in  number
  ,p_information_category           in  varchar2
  ,p_information1                   in  varchar2
  ,p_information2                   in  varchar2
  ,p_information3                   in  varchar2
  ,p_information4                   in  varchar2
  ,p_information5                   in  varchar2
  ,p_information6                   in  varchar2
  ,p_information7                   in  varchar2
  ,p_information8                   in  varchar2
  ,p_information9                   in  varchar2
  ,p_information10                  in  varchar2
  ,p_information11                  in  varchar2
  ,p_information12                  in  varchar2
  ,p_information13                  in  varchar2
  ,p_information14                  in  varchar2
  ,p_information15                  in  varchar2
  ,p_information16                  in  varchar2
  ,p_information17                  in  varchar2
  ,p_information18                  in  varchar2
  ,p_information19                  in  varchar2
  ,p_information20                  in  varchar2
  ,p_information21                  in  varchar2
  ,p_information22                  in  varchar2
  ,p_information23                  in  varchar2
  ,p_information24                  in  varchar2
  ,p_information25                  in  varchar2
  ,p_information26                  in  varchar2
  ,p_information27                  in  varchar2
  ,p_information28                  in  varchar2
  ,p_information29                  in  varchar2
  ,p_information30                  in  varchar2
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_object_version_number          in  number
  );
--
end pqh_ptx_extra_info_bk2;

 

/
