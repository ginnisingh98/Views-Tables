--------------------------------------------------------
--  DDL for Package Body PAY_RETRO_COMP_USAGE_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RETRO_COMP_USAGE_INTERNAL" as
/* $Header: pyrcubsi.pkb 120.1 2005/10/04 23:03 pgongada noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'pay_retro_comp_usage_internal.';
--
--
--private procedures
--
--Created for Bug#4075607
procedure get_ele_typ_det (p_effective_date                in     date
                          ,p_element_type_id               in     number
                          ,x_legislation_code              out nocopy     varchar2
                          ,x_classification_id             out nocopy     number
                          ,x_business_group_id             out nocopy     number);

--public procedures

-- ----------------------------------------------------------------------------
-- |----------------------< populate_retro_comp_usages >----------------------|
-- ----------------------------------------------------------------------------
--
procedure populate_retro_comp_usages
  (p_effective_date                in     date
  ,p_element_type_id               in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_rcu_id                  number;
  l_rcu_ovn                 number;
  l_esu_id                  number;
  l_esu_ovn                 number;

  cursor csr_base_rcu
  is
    --
    -- Business_group_id and legislation_code should be derived from
    -- the element type.
    -- Return no rows if a retro component usage already exists
    -- for that element type.
    --
    select
      rcu1.retro_component_usage_id
     ,rcu1.retro_component_id
     ,rcu1.creator_id
     ,rcu1.creator_type
     ,rcu1.default_component
     ,rcu1.reprocess_type
     ,etp.business_group_id
     ,etp.legislation_code
    from
      pay_element_types_f etp
     ,pay_retro_component_usages rcu1
    where
        etp.element_type_id = p_element_type_id
    and p_effective_date between etp.effective_start_date
    and etp.effective_end_date
    and rcu1.creator_type = 'EC'
    and rcu1.creator_id = etp.classification_id
    and not exists
          (select null from pay_retro_component_usages rcu2
           where rcu2.creator_id = etp.element_type_id
             and rcu2.creator_type = 'ET')
    ;

  cursor csr_base_esu
    (p_retro_comp_usage_id in number
    )
  is
    select
      element_span_usage_id
     ,time_span_id
     ,retro_component_usage_id
     ,adjustment_type
     ,retro_element_type_id
     ,business_group_id
     ,legislation_code
    from
      pay_element_span_usages
    where
      retro_component_usage_id = p_retro_comp_usage_id
    ;

  l_proc              varchar2(72) := g_package||'populate_retro_comp_usages';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  -- 1) Populate retro component usages with the rows defined for the
  --    classification if none is created for the element type.
  --    Business_group_id and legislation_code should be inherited
  --    from the element type.
  -- 2) Populate the child element span usages accordingly.
  --    Business_group_id and legislation_code should be inherited
  --    from the element type as well.

  for l_rcu_rec in csr_base_rcu loop

    hr_utility.set_location(l_proc, 20);

    l_rcu_id  := null;
    l_rcu_ovn := null;

    --
    -- Create the retro component usage for the element type
    --
    pay_rcu_ins.ins
      (p_effective_date           => p_effective_date
      ,p_retro_component_id       => l_rcu_rec.retro_component_id
      ,p_creator_id               => p_element_type_id
      ,p_creator_type             => 'ET'
      ,p_default_component        => l_rcu_rec.default_component
      ,p_reprocess_type           => l_rcu_rec.reprocess_type
      ,p_business_group_id        => l_rcu_rec.business_group_id
      ,p_legislation_code         => l_rcu_rec.legislation_code
      ,p_retro_component_usage_id => l_rcu_id
      ,p_object_version_number    => l_rcu_ovn
      );

    --
    -- Create the Element Span Usages
    --
    for l_esu_rec in csr_base_esu(l_rcu_rec.retro_component_usage_id) loop

      hr_utility.set_location(l_proc, 30);

      l_esu_id  := null;
      l_esu_ovn := null;

      pay_esu_ins.ins
        (p_effective_date           => p_effective_date
        ,p_time_span_id             => l_esu_rec.time_span_id
        ,p_retro_component_usage_id => l_rcu_id
        ,p_retro_element_type_id    => l_esu_rec.retro_element_type_id
        ,p_adjustment_type          => l_esu_rec.adjustment_type
        ,p_business_group_id        => l_rcu_rec.business_group_id
        ,p_legislation_code         => l_rcu_rec.legislation_code
        ,p_element_span_usage_id    => l_esu_id
        ,p_object_version_number    => l_esu_ovn
        );

    end loop;

  end loop;

  hr_utility.set_location(l_proc, 40);

  --
  -- Set all output arguments
  --

  hr_utility.set_location('Leaving:'||l_proc, 50);

end populate_retro_comp_usages;


-- ----------------------------------------------------------------------------
-- |---------------------< delete_child_retro_comp_usages >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_child_retro_comp_usages
  (p_effective_date                in     date
  ,p_element_type_id               in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  --Bug#4075607. Takes in leg code and business group id as parameters.

  cursor csr_rcu(p_legislation_code varchar2, p_business_group_id number)
  is
    select
      retro_component_usage_id
     ,object_version_number
    from
      pay_retro_component_usages
    where
        creator_id = p_element_type_id
    and nvl(legislation_code, -1) = p_legislation_code
    and nvl(business_group_id , -1) = p_business_group_id
    and creator_type = 'ET'
    ;

  cursor csr_esu
    (p_retro_component_usage_id in number
    )
  is
    select
      element_span_usage_id
     ,object_version_number
    from
      pay_element_span_usages
    where
        retro_component_usage_id = p_retro_component_usage_id
    ;

  l_proc           varchar2(72) := g_package||'delete_child_retro_comp_usages';

  --Bug#4075607
  --local variables to hold element type details..
  l_classification_id       pay_element_types_f.classification_id%type;
  l_business_group_id       pay_element_types_f.business_group_id%type;
  l_legislation_code        pay_element_types_f.legislation_code%type;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  --
  --get element type details
  --Bug#4075607
     get_ele_typ_det (p_effective_date    => p_effective_date
                   ,p_element_type_id   => p_element_type_id
                   ,x_legislation_code  => l_legislation_code
                   ,x_classification_id => l_classification_id
                   ,x_business_group_id => l_business_group_id);

  --Bug#4075607. Takes in leg code and business group id as parameters.
  for l_rcu_rec in csr_rcu(l_legislation_code, l_business_group_id) loop

    --
    -- Delete Element Span Usages
    --
    for l_esu_rec in csr_esu(l_rcu_rec.retro_component_usage_id) loop

      hr_utility.set_location(l_proc, 15);
      pay_esu_del.del
        (p_element_span_usage_id => l_esu_rec.element_span_usage_id
        ,p_object_version_number => l_esu_rec.object_version_number
        );

    end loop;

    --
    -- Delete Retro Component Usages
    --
    hr_utility.set_location(l_proc, 20);

    pay_rcu_del.del
      (p_retro_component_usage_id => l_rcu_rec.retro_component_usage_id
      ,p_object_version_number    => l_rcu_rec.object_version_number
      );

  end loop;

  hr_utility.set_location('Leaving:'||l_proc, 40);

end delete_child_retro_comp_usages;

--
-- Bug#4075607
-- ----------------------------------------------------------------------------
-- |----------------------< get_ele_typ_det >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_ele_typ_det (p_effective_date                in     date
                          ,p_element_type_id               in     number
                          ,x_legislation_code              out nocopy     varchar2
                          ,x_classification_id             out nocopy     number
                          ,x_business_group_id             out nocopy     number)
IS
  --Bug#4075607
  --In order to add business group id and legislation code to unique constraint
  --for pay_element_span_usages and pay_retro_component_usages tables, we need
  --to check for the both these column values for the above tables to match
  --with the pay_element_types table values.
--
Begin
--
--Fetch element type details......
    Select nvl(etp.business_group_id, -1)
          ,nvl(etp.legislation_code, -1)
          ,etp.classification_id
     Into
         x_business_group_id
        ,x_legislation_code
        ,x_classification_id
     From pay_element_types_f etp
    Where etp.element_type_id = p_element_type_id
      And p_effective_date between etp.effective_start_date and etp.effective_end_date ;

End get_ele_typ_det;
--
--
end pay_retro_comp_usage_internal;

/
