--------------------------------------------------------
--  DDL for Package Body PAY_KR_AEI_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_AEI_API" as
/* $Header: pykraei.pkb 115.5 2003/12/15 02:00:14 viagarwa noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_kr_aei_api.';
g_debug    boolean      := hr_utility.debug_enabled;
--
-- Common business group and legislation code check function
--
procedure check_bg_lc
( p_business_group_id in number
) is
  l_legislation_code varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'KR'.
  --
  if l_legislation_code <> 'KR' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','KR');
    hr_utility.raise_error;
  end if;
end check_bg_lc;
-- ---------------------------------------------------------------------
-- |------------------< ins_yea_tax_break_info >-----------------------|
-- ---------------------------------------------------------------------
procedure ins_yea_tax_break_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_object_version_number            out NOCOPY number
  ,p_assignment_extra_info_id         out NOCOPY number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'ins_yea_tax_break_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.trace('Inside ins_yea_tax_break_info');
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.create_assignment_extra_info
  (p_validate                 => p_validate
  ,p_assignment_id            => p_assignment_id
  ,p_information_type         => p_information_type
  ,p_aei_information_category => p_aei_information_category
  ,p_aei_information1         => p_aei_information1
  ,p_aei_information2         => p_aei_information2
  ,p_aei_information3         => p_aei_information3
  ,p_aei_information4         => p_aei_information4
  ,p_object_version_number    => p_object_version_number
  ,p_assignment_extra_info_id => p_assignment_extra_info_id
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end ins_yea_tax_break_info;
--
-- ---------------------------------------------------------------------
-- |------------------< upd_yea_tax_break_info >-----------------------|
-- ---------------------------------------------------------------------
procedure upd_yea_tax_break_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'upd_yea_tax_break_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.update_assignment_extra_info
  (p_validate                   => p_validate
  ,p_assignment_extra_info_id   => p_assignment_extra_info_id
  ,p_object_version_number      => p_object_version_number
  ,p_aei_information_category   => p_aei_information_category
  ,p_aei_information1           => p_aei_information1
  ,p_aei_information2           => p_aei_information2
  ,p_aei_information3           => p_aei_information3
  ,p_aei_information4           => p_aei_information4
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end upd_yea_tax_break_info;
--
-- ---------------------------------------------------------------------
-- |------------------< ins_yea_tax_exem_info >------------------------|
-- ---------------------------------------------------------------------
procedure ins_yea_tax_exem_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_object_version_number            out NOCOPY number
  ,p_assignment_extra_info_id         out NOCOPY number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'ins_yea_tax_exem_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.trace('Inside ins_yea_tax_exem_info');
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.create_assignment_extra_info
  (p_validate                 => p_validate
  ,p_assignment_id            => p_assignment_id
  ,p_information_type         => p_information_type
  ,p_aei_information_category => p_aei_information_category
  ,p_aei_information1         => p_aei_information1
  ,p_aei_information2         => p_aei_information2
  ,p_aei_information3         => p_aei_information3
  ,p_aei_information4         => p_aei_information4
  ,p_aei_information5         => p_aei_information5
  ,p_aei_information6         => p_aei_information6
  ,p_aei_information7         => p_aei_information7
  ,p_object_version_number    => p_object_version_number
  ,p_assignment_extra_info_id => p_assignment_extra_info_id
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end ins_yea_tax_exem_info;
--
-- ---------------------------------------------------------------------
-- |-------------------< upd_yea_tax_exem_info >-----------------------|
-- ---------------------------------------------------------------------
procedure upd_yea_tax_exem_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'upd_yea_tax_exem_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.update_assignment_extra_info
  (p_validate                   => p_validate
  ,p_assignment_extra_info_id   => p_assignment_extra_info_id
  ,p_object_version_number      => p_object_version_number
  ,p_aei_information_category   => p_aei_information_category
  ,p_aei_information1           => p_aei_information1
  ,p_aei_information2           => p_aei_information2
  ,p_aei_information3           => p_aei_information3
  ,p_aei_information4           => p_aei_information4
  ,p_aei_information5           => p_aei_information5
  ,p_aei_information6           => p_aei_information6
  ,p_aei_information7           => p_aei_information7
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end upd_yea_tax_exem_info;
--
-- ---------------------------------------------------------------------
-- |------------------< ins_yea_sp_tax_exem_info >---------------------|
-- ---------------------------------------------------------------------
procedure ins_yea_sp_tax_exem_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_aei_information11             in     varchar2 default null
  ,p_aei_information12             in     varchar2 default null
  ,p_aei_information13             in     varchar2 default null
  ,p_aei_information14             in     varchar2 default null
  ,p_aei_information15             in     varchar2 default null
  ,p_aei_information16             in     varchar2 default null
  ,p_aei_information17             in     varchar2 default null
  ,p_aei_information18             in     varchar2 default null
  ,p_aei_information19             in     varchar2 default null
  ,p_aei_information20             in     varchar2 default null
  ,p_aei_information21             in     varchar2 default null
  ,p_aei_information22             in     varchar2 default null
  ,p_object_version_number            out NOCOPY number
  ,p_assignment_extra_info_id         out NOCOPY number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'ins_yea_sp_tax_exem_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.trace('Inside ins_yea_sp_tax_exem_info');
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.create_assignment_extra_info
  (p_validate                 => p_validate
  ,p_assignment_id            => p_assignment_id
  ,p_information_type         => p_information_type
  ,p_aei_information_category => p_aei_information_category
  ,p_aei_information1         => p_aei_information1
  ,p_aei_information2         => p_aei_information2
  ,p_aei_information3         => p_aei_information3
  ,p_aei_information4         => p_aei_information4
  ,p_aei_information5         => p_aei_information5
  ,p_aei_information6         => p_aei_information6
  ,p_aei_information7         => p_aei_information7
  ,p_aei_information8         => p_aei_information8
  ,p_aei_information9         => p_aei_information9
  ,p_aei_information10        => p_aei_information10
  ,p_aei_information11        => p_aei_information11
  ,p_aei_information12        => p_aei_information12
  ,p_aei_information13        => p_aei_information13
  ,p_aei_information14        => p_aei_information14
  ,p_aei_information15        => p_aei_information15
  ,p_aei_information16        => p_aei_information16
  ,p_aei_information17        => p_aei_information17
  ,p_aei_information18        => p_aei_information18
  ,p_aei_information19        => p_aei_information19
  ,p_aei_information20        => p_aei_information20
  ,p_aei_information21        => p_aei_information21
  ,p_aei_information22        => p_aei_information22
  ,p_object_version_number    => p_object_version_number
  ,p_assignment_extra_info_id => p_assignment_extra_info_id
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end ins_yea_sp_tax_exem_info;
--
-- ---------------------------------------------------------------------
-- |-------------------< upd_yea_sp_tax_exem_info >--------------------|
-- ---------------------------------------------------------------------
procedure upd_yea_sp_tax_exem_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_aei_information11             in     varchar2 default null
  ,p_aei_information12             in     varchar2 default null
  ,p_aei_information13             in     varchar2 default null
  ,p_aei_information14             in     varchar2 default null
  ,p_aei_information15             in     varchar2 default null
  ,p_aei_information16             in     varchar2 default null
  ,p_aei_information17             in     varchar2 default null
  ,p_aei_information18             in     varchar2 default null
  ,p_aei_information19             in     varchar2 default null
  ,p_aei_information20             in     varchar2 default null
  ,p_aei_information21             in     varchar2 default null
  ,p_aei_information22             in     varchar2 default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'upd_yea_sp_tax_exem_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.update_assignment_extra_info
  (p_validate                   => p_validate
  ,p_assignment_extra_info_id   => p_assignment_extra_info_id
  ,p_object_version_number      => p_object_version_number
  ,p_aei_information_category   => p_aei_information_category
  ,p_aei_information1           => p_aei_information1
  ,p_aei_information2           => p_aei_information2
  ,p_aei_information3           => p_aei_information3
  ,p_aei_information4           => p_aei_information4
  ,p_aei_information5           => p_aei_information5
  ,p_aei_information6           => p_aei_information6
  ,p_aei_information7           => p_aei_information7
  ,p_aei_information8           => p_aei_information8
  ,p_aei_information9           => p_aei_information9
  ,p_aei_information10          => p_aei_information10
  ,p_aei_information11          => p_aei_information11
  ,p_aei_information12          => p_aei_information12
  ,p_aei_information13          => p_aei_information13
  ,p_aei_information14          => p_aei_information14
  ,p_aei_information15          => p_aei_information15
  ,p_aei_information16          => p_aei_information16
  ,p_aei_information17          => p_aei_information17
  ,p_aei_information18          => p_aei_information18
  ,p_aei_information19          => p_aei_information19
  ,p_aei_information20          => p_aei_information20
  ,p_aei_information21          => p_aei_information21
  ,p_aei_information22          => p_aei_information22
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end upd_yea_sp_tax_exem_info;
--
-- ---------------------------------------------------------------------
-- |------------< ins_yea_dpnteduc_tax_exem_info >---------------------|
-- ---------------------------------------------------------------------
procedure ins_yea_dpnteduc_tax_exem_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_object_version_number            out NOCOPY number
  ,p_assignment_extra_info_id         out NOCOPY number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'ins_yea_dpnteduc_tax_exem_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.trace('Inside ins_yea_dpnteduc_tax_exem_info');
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.create_assignment_extra_info
  (p_validate                 => p_validate
  ,p_assignment_id            => p_assignment_id
  ,p_information_type         => p_information_type
  ,p_aei_information_category => p_aei_information_category
  ,p_aei_information1         => p_aei_information1
  ,p_aei_information2         => p_aei_information2
  ,p_aei_information3         => p_aei_information3
  ,p_aei_information4         => p_aei_information4
  ,p_object_version_number    => p_object_version_number
  ,p_assignment_extra_info_id => p_assignment_extra_info_id
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end ins_yea_dpnteduc_tax_exem_info;
--
-- ---------------------------------------------------------------------
-- |-------------< upd_yea_dpnteduc_tax_exem_info >--------------------|
-- ---------------------------------------------------------------------
procedure upd_yea_dpnteduc_tax_exem_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'upd_yea_dpnteduc_tax_exem_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.update_assignment_extra_info
  (p_validate                   => p_validate
  ,p_assignment_extra_info_id   => p_assignment_extra_info_id
  ,p_object_version_number      => p_object_version_number
  ,p_aei_information_category   => p_aei_information_category
  ,p_aei_information1           => p_aei_information1
  ,p_aei_information2           => p_aei_information2
  ,p_aei_information3           => p_aei_information3
  ,p_aei_information4           => p_aei_information4
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end upd_yea_dpnteduc_tax_exem_info;
--
-- ---------------------------------------------------------------------
-- |------------< ins_yea_fw_tax_break_info >--------------------------|
-- ---------------------------------------------------------------------
procedure ins_yea_fw_tax_break_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_object_version_number            out NOCOPY number
  ,p_assignment_extra_info_id         out NOCOPY number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'ins_yea_fw_tax_break_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.trace('Inside ins_yea_fw_tax_break_info');
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.create_assignment_extra_info
  (p_validate                 => p_validate
  ,p_assignment_id            => p_assignment_id
  ,p_information_type         => p_information_type
  ,p_aei_information_category => p_aei_information_category
  ,p_aei_information1         => p_aei_information1
  ,p_aei_information2         => p_aei_information2
  ,p_aei_information3         => p_aei_information3
  ,p_aei_information4         => p_aei_information4
  ,p_aei_information5         => p_aei_information5
  ,p_aei_information6         => p_aei_information6
  ,p_object_version_number    => p_object_version_number
  ,p_assignment_extra_info_id => p_assignment_extra_info_id
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end ins_yea_fw_tax_break_info;
--
-- ---------------------------------------------------------------------
-- |-------------< upd_yea_fw_tax_break_info >-------------------------|
-- ---------------------------------------------------------------------
procedure upd_yea_fw_tax_break_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'upd_yea_fw_tax_break_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.update_assignment_extra_info
  (p_validate                   => p_validate
  ,p_assignment_extra_info_id   => p_assignment_extra_info_id
  ,p_object_version_number      => p_object_version_number
  ,p_aei_information_category   => p_aei_information_category
  ,p_aei_information1           => p_aei_information1
  ,p_aei_information2           => p_aei_information2
  ,p_aei_information3           => p_aei_information3
  ,p_aei_information4           => p_aei_information4
  ,p_aei_information5           => p_aei_information5
  ,p_aei_information6           => p_aei_information6
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end upd_yea_fw_tax_break_info;
--
-- ---------------------------------------------------------------------
-- |------------< ins_yea_ovs_tax_break_info >-------------------------|
-- ---------------------------------------------------------------------
procedure ins_yea_ovs_tax_break_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_object_version_number            out NOCOPY number
  ,p_assignment_extra_info_id         out NOCOPY number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'ins_yea_ovs_tax_break_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.trace('Inside ins_yea_ovs_tax_break_info');
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.create_assignment_extra_info
  (p_validate                 => p_validate
  ,p_assignment_id            => p_assignment_id
  ,p_information_type         => p_information_type
  ,p_aei_information_category => p_aei_information_category
  ,p_aei_information1         => p_aei_information1
  ,p_aei_information2         => p_aei_information2
  ,p_aei_information3         => p_aei_information3
  ,p_aei_information4         => p_aei_information4
  ,p_aei_information5         => p_aei_information5
  ,p_aei_information6         => p_aei_information6
  ,p_aei_information7         => p_aei_information7
  ,p_aei_information8         => p_aei_information8
  ,p_aei_information9         => p_aei_information9
  ,p_aei_information10        => p_aei_information10
  ,p_object_version_number    => p_object_version_number
  ,p_assignment_extra_info_id => p_assignment_extra_info_id
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end ins_yea_ovs_tax_break_info;
--
-- ---------------------------------------------------------------------
-- |-------------< upd_yea_ovs_tax_break_info >------------------------|
-- ---------------------------------------------------------------------
procedure upd_yea_ovs_tax_break_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'upd_yea_ovs_tax_break_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.update_assignment_extra_info
  (p_validate                   => p_validate
  ,p_assignment_extra_info_id   => p_assignment_extra_info_id
  ,p_object_version_number      => p_object_version_number
  ,p_aei_information_category   => p_aei_information_category
  ,p_aei_information1           => p_aei_information1
  ,p_aei_information2           => p_aei_information2
  ,p_aei_information3           => p_aei_information3
  ,p_aei_information4           => p_aei_information4
  ,p_aei_information5           => p_aei_information5
  ,p_aei_information6           => p_aei_information6
  ,p_aei_information7           => p_aei_information7
  ,p_aei_information8           => p_aei_information8
  ,p_aei_information9           => p_aei_information9
  ,p_aei_information10          => p_aei_information10
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end upd_yea_ovs_tax_break_info;
--
-- ---------------------------------------------------------------------
-- |-------------< upd_yea_prev_er_info >------------------------------|
-- ---------------------------------------------------------------------
procedure upd_yea_prev_er_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_aei_information11             in     varchar2 default null
  ,p_aei_information12             in     varchar2 default null
  ,p_aei_information13             in     varchar2 default null
  ,p_aei_information14             in     varchar2 default null
  ,p_aei_information15             in     varchar2 default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'upd_yea_prev_er_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.update_assignment_extra_info
  (p_validate                   => p_validate
  ,p_assignment_extra_info_id   => p_assignment_extra_info_id
  ,p_object_version_number      => p_object_version_number
  ,p_aei_information_category   => p_aei_information_category
  ,p_aei_information1           => p_aei_information1
  ,p_aei_information2           => p_aei_information2
  ,p_aei_information3           => p_aei_information3
  ,p_aei_information4           => p_aei_information4
  ,p_aei_information5           => p_aei_information5
  ,p_aei_information6           => p_aei_information6
  ,p_aei_information7           => p_aei_information7
  ,p_aei_information8           => p_aei_information8
  ,p_aei_information9           => p_aei_information9
  ,p_aei_information10          => p_aei_information10
  ,p_aei_information11          => p_aei_information11
  ,p_aei_information12          => p_aei_information12
  ,p_aei_information13          => p_aei_information13
  ,p_aei_information14          => p_aei_information14
  ,p_aei_information15          => p_aei_information15
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end upd_yea_prev_er_info;

-- ---------------------------------------------------------------------
-- |------------< ins_yea_prev_er_info >-------------------------------|
-- ---------------------------------------------------------------------
procedure ins_yea_prev_er_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_aei_information11             in     varchar2 default null
  ,p_aei_information12             in     varchar2 default null
  ,p_aei_information13             in     varchar2 default null
  ,p_aei_information14             in     varchar2 default null
  ,p_aei_information15             in     varchar2 default null
  ,p_object_version_number            out NOCOPY number
  ,p_assignment_extra_info_id         out NOCOPY number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'ins_yea_prev_er_info';
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.trace('Inside ins_yea_prev_er_info');
  end if;

  -- Check business group and legislation code
  check_bg_lc
  (p_business_group_id => p_business_group_id
  );

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.create_assignment_extra_info
  (p_validate                 => p_validate
  ,p_assignment_id            => p_assignment_id
  ,p_information_type         => p_information_type
  ,p_aei_information_category => p_aei_information_category
  ,p_aei_information1         => p_aei_information1
  ,p_aei_information2         => p_aei_information2
  ,p_aei_information3         => p_aei_information3
  ,p_aei_information4         => p_aei_information4
  ,p_aei_information5         => p_aei_information5
  ,p_aei_information6         => p_aei_information6
  ,p_aei_information7         => p_aei_information7
  ,p_aei_information8         => p_aei_information8
  ,p_aei_information9         => p_aei_information9
  ,p_aei_information10        => p_aei_information10
  ,p_aei_information11        => p_aei_information11
  ,p_aei_information12        => p_aei_information12
  ,p_aei_information13        => p_aei_information13
  ,p_aei_information14        => p_aei_information14
  ,p_aei_information15        => p_aei_information15
  ,p_object_version_number    => p_object_version_number
  ,p_assignment_extra_info_id => p_assignment_extra_info_id
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;
end ins_yea_prev_er_info;
--
--
procedure chk_date_in_current_year
  (p_session_date                  in     date
  ,p_entry_date                    in     date
  ) is
begin
  if p_entry_date is null
    then return;
  end if;

  if substr(to_char(p_session_date, 'DD-MON-YYYY'), 8, 4)
    <> substr(to_char(p_entry_date, 'DD-MON-YYYY'), 8, 4) then
    hr_utility.set_message(801, 'PAY_KR_NOT_WITHIN_CURRENT_YEAR');
    hr_utility.raise_error;
  end if;
end chk_date_in_current_year;
--
--
end pay_kr_aei_api;

/
