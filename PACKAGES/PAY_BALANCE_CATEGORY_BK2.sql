--------------------------------------------------------
--  DDL for Package PAY_BALANCE_CATEGORY_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_CATEGORY_BK2" AUTHID CURRENT_USER as
/* $Header: pypbcapi.pkh 120.2 2005/10/22 01:25:41 aroussel noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_balance_category_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_balance_category_b
  (p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_balance_category_id           in     number
  ,p_object_version_number         in     number
  ,p_save_run_balance_enabled      in     varchar2
  ,p_user_category_name            in     varchar2
  ,p_pbc_information_category      in     varchar2
  ,p_pbc_information1              in     varchar2
  ,p_pbc_information2              in     varchar2
  ,p_pbc_information3              in     varchar2
  ,p_pbc_information4              in     varchar2
  ,p_pbc_information5              in     varchar2
  ,p_pbc_information6              in     varchar2
  ,p_pbc_information7              in     varchar2
  ,p_pbc_information8              in     varchar2
  ,p_pbc_information9              in     varchar2
  ,p_pbc_information10             in     varchar2
  ,p_pbc_information11             in     varchar2
  ,p_pbc_information12             in     varchar2
  ,p_pbc_information13             in     varchar2
  ,p_pbc_information14             in     varchar2
  ,p_pbc_information15             in     varchar2
  ,p_pbc_information16             in     varchar2
  ,p_pbc_information17             in     varchar2
  ,p_pbc_information18             in     varchar2
  ,p_pbc_information19             in     varchar2
  ,p_pbc_information20             in     varchar2
  ,p_pbc_information21             in     varchar2
  ,p_pbc_information22             in     varchar2
  ,p_pbc_information23             in     varchar2
  ,p_pbc_information24             in     varchar2
  ,p_pbc_information25             in     varchar2
  ,p_pbc_information26             in     varchar2
  ,p_pbc_information27             in     varchar2
  ,p_pbc_information28             in     varchar2
  ,p_pbc_information29             in     varchar2
  ,p_pbc_information30             in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_balance_category_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_balance_category_a
  (p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_balance_category_id           in     number
  ,p_object_version_number         in     number
  ,p_save_run_balance_enabled      in     varchar2
  ,p_user_category_name            in     varchar2
  ,p_pbc_information_category      in     varchar2
  ,p_pbc_information1              in     varchar2
  ,p_pbc_information2              in     varchar2
  ,p_pbc_information3              in     varchar2
  ,p_pbc_information4              in     varchar2
  ,p_pbc_information5              in     varchar2
  ,p_pbc_information6              in     varchar2
  ,p_pbc_information7              in     varchar2
  ,p_pbc_information8              in     varchar2
  ,p_pbc_information9              in     varchar2
  ,p_pbc_information10             in     varchar2
  ,p_pbc_information11             in     varchar2
  ,p_pbc_information12             in     varchar2
  ,p_pbc_information13             in     varchar2
  ,p_pbc_information14             in     varchar2
  ,p_pbc_information15             in     varchar2
  ,p_pbc_information16             in     varchar2
  ,p_pbc_information17             in     varchar2
  ,p_pbc_information18             in     varchar2
  ,p_pbc_information19             in     varchar2
  ,p_pbc_information20             in     varchar2
  ,p_pbc_information21             in     varchar2
  ,p_pbc_information22             in     varchar2
  ,p_pbc_information23             in     varchar2
  ,p_pbc_information24             in     varchar2
  ,p_pbc_information25             in     varchar2
  ,p_pbc_information26             in     varchar2
  ,p_pbc_information27             in     varchar2
  ,p_pbc_information28             in     varchar2
  ,p_pbc_information29             in     varchar2
  ,p_pbc_information30             in     varchar2
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end pay_balance_category_bk2;

 

/
