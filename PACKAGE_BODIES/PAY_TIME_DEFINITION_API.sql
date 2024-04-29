--------------------------------------------------------
--  DDL for Package Body PAY_TIME_DEFINITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TIME_DEFINITION_API" as
/* $Header: pytdfapi.pkb 120.3 2005/09/21 03:56:23 adkumar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_TIME_DEFINITION_API.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< generate_time_periods >----------------------|
-- ----------------------------------------------------------------------------
--
procedure generate_time_periods
  (p_time_definition_id            in     number
  ) is
  --
  l_earliest_start_date date;
  l_latest_end_date     date;
  l_no_of_existing_periods  number;

  l_definition_type varchar2(30);
  l_start_date  date;
  l_period_type varchar2 (30);
  l_legislation_code varchar2 (30);
  l_business_group_id number (15);
  l_number_of_years   number (9);
  l_period_time_definition_id number (9);

  l_time_definition_id_to_pass number (9);

  l_first_period_start_date     date;
  l_first_period_end_date       date;
  l_gen_first_period_start_date date;
  l_gen_first_period_end_date   date;
  l_period_start_date           date;
  l_period_end_date             date;

  l_next_period_start_date     date;

  l_multiple number;
  l_base_period_type varchar2(1);
  l_period_number number;
  l_period_name   per_time_periods.period_name%type ;
  l_end_years_marker  date;
  l_display_period_type    per_time_period_types.display_period_type%type ;
  l_date date;

  l_next_leg_start_date date;
  l_leg_start_date      date;

  l_day_adj_multiple number;
  l_period_unit_multiple number;

  l_dpit_period_unit varchar2(30);
  l_dpit_period_type varchar2(30);
  l_dpit_day_adjustment varchar2(30);

  l_proc  varchar2(72) := g_package||'generate_time_periods';

  WEEKLY CONSTANT varchar2(1) := 'W';
  MONTHLY CONSTANT varchar2(1) := 'M';
  SEMIMONTHLY CONSTANT varchar2(1) := 'S';

  --
  cursor csr_time_definition_details is
    select nvl(definition_type,'P'),
           start_date,
           period_type,
           business_group_id,
           legislation_code,
           number_of_years,
           period_time_definition_id
    from   pay_time_definitions
    where  time_definition_id = p_time_definition_id;

  cursor csr_existing_period_details is
    select min(start_date),
           max(end_date),
           count(time_period_id)
    from   per_time_periods ptp
    where  ptp.time_definition_id = p_time_definition_id;

  cursor csr_first_period_end_date is
    select end_date
    from   per_time_periods ptp
    where  ptp.time_definition_id = p_time_definition_id
    and    start_date = l_first_period_start_date;

--
  function add_multiples
    (p_date  in  date,
     p_base_period_type in varchar2,
     p_multiple in number,
     p_first_period_end_date in date
    ) return date is
    --
    l_ret_date date;
    --
  begin
    --
      if p_base_period_type  = WEEKLY then
         return (p_date + (7 * p_multiple ));
      elsif p_base_period_type = MONTHLY then
         return (add_months(p_date , p_multiple));
      else
         if p_multiple > 0 then
              l_ret_date := hr_payrolls.next_semi_month(p_date, p_first_period_end_date);
              return l_ret_date;
         else
              l_ret_date := hr_payrolls.prev_semi_month(p_date, p_first_period_end_date);
              return l_ret_date;
         end if;
      end if;
  end add_multiples;
  --
  --
 Procedure get_period_number(
 p_time_definition_id    in number,
 p_first_period_end_date in date,
 p_legislation_code      in varchar2,
 p_business_group_id     in number,
 p_leg_start_date        out nocopy date,
 p_period_number         out nocopy number
 ) is

 l_leg_start_date   date;
 l_next_start_date  date;
 no_periods         number;
 begin
 --
    begin
      select to_date(plr.rule_mode || '/' ||
                     to_char(p_first_period_end_date, 'YYYY'), 'DD/MM/YYYY')
        into  l_leg_start_date
        from  pay_legislation_rules plr
       where plr.rule_type = 'L'
         and   plr.legislation_code = nvl(p_legislation_code,
                                  hr_api.return_legislation_code(p_business_group_id) );
    exception
       when NO_DATA_FOUND then
          l_leg_start_date := to_date('01/01/' ||
              to_char(p_first_period_end_date, 'YYYY'), 'DD/MM/YYYY');
    end;
    --
    if l_leg_start_date > p_first_period_end_date then
       l_leg_start_date := add_months(l_leg_start_date, -12);
    end if;
    --
    no_periods := 0;

    l_next_start_date := l_leg_start_date;
    while  p_first_period_end_date >= l_next_start_date loop
       l_next_start_date :=  pay_core_dates.get_time_definition_date(
                                p_time_def_id     =>p_time_definition_id,
                                p_effective_date  =>l_next_start_date,
                                p_bus_grp         =>p_business_group_id);
       no_periods := no_periods + 1;
    end loop;
    --
    p_period_number := no_periods;
    p_leg_start_date := l_leg_start_date;
  end ;
  --
  --
begin
  --
  -- Get the time definition details.

     open csr_time_definition_details;

     fetch csr_time_definition_details
           into  l_definition_type,
                 l_start_date,
                 l_period_type,
                 l_business_group_id,
                 l_legislation_code,
                 l_number_of_years,
                 l_period_time_definition_id;

     if csr_time_definition_details%notfound then

       hr_utility.set_location(l_proc, 20);
       close csr_time_definition_details;
       fnd_message.set_name('PAY','PAY_34056_FLSA_INV_TIME_DEF_ID');
       fnd_message.raise_error;

     end if;

     close csr_time_definition_details;
     hr_utility.set_location(l_proc, 30);

     if l_definition_type in ('P', 'E', 'C') then

         hr_utility.set_location(l_proc, 40);
         return;

     end if;

     --
     if l_period_type is not null then
        l_time_definition_id_to_pass := p_time_definition_id;
        hr_payrolls.get_period_details
                     (p_proc_period_type => l_period_type,
                      p_base_period_type => l_base_period_type,
                      p_multiple => l_multiple);

     elsif l_period_time_definition_id is not null then
        l_time_definition_id_to_pass := l_period_time_definition_id;
     end if;

     hr_utility.set_location(l_proc, 50);

  -- Check if there are already periods existing for this time definition.
  -- If the periods are already existing the user is trying to increase
  -- number of years of the time definition.

     open csr_existing_period_details;
     fetch csr_existing_period_details into l_earliest_start_date,
                 l_latest_end_date, l_no_of_existing_periods;
     close csr_existing_period_details;

     if l_no_of_existing_periods = 0 then
        -- Time Periods do not exist for the time definition.
        hr_utility.set_location(l_proc, 60);

        l_first_period_start_date := l_start_date;
        if l_period_time_definition_id is not null then
           -- if Time Definition is static and point in time definition id is not null
           l_next_period_start_date := pay_core_dates.get_time_definition_date(
	                                p_time_def_id     =>l_time_definition_id_to_pass,
                                        p_effective_date  =>l_start_date,
                                        p_bus_grp         =>l_business_group_id);

           l_first_period_end_date := l_next_period_start_date -1;

           hr_utility.set_location(l_proc, 70);

        elsif l_period_type is not null then
	-- if Time Definition is static and period type is not null
           l_first_period_end_date   := add_multiples
                                            ( p_date => l_start_date - 1 ,
                                              p_base_period_type => l_base_period_type,
                                              p_multiple => l_multiple,
                                              p_first_period_end_date => l_start_date - 1
                                              ) ;
           hr_utility.set_location(l_proc, 80);
        end if;
        l_gen_first_period_start_date := l_first_period_start_date;
        l_gen_first_period_end_date   := l_first_period_end_date;

     else

         -- Time Periods have been generated before.

           hr_utility.set_location(l_proc, 90);

           l_first_period_start_date := l_earliest_start_date;

           open csr_first_period_end_date;
           fetch csr_first_period_end_date into l_first_period_end_date;
           close csr_first_period_end_date;

           l_gen_first_period_start_date := l_latest_end_date + 1;

	   if l_period_time_definition_id is not null then
	      l_next_period_start_date := pay_core_dates.get_time_definition_date(
	                                p_time_def_id     =>l_time_definition_id_to_pass,
                                        p_effective_date  =>l_gen_first_period_start_date,
                                        p_bus_grp         =>l_business_group_id);

              l_gen_first_period_end_date := l_next_period_start_date -1;
              hr_utility.set_location(l_proc, 100);
           elsif l_period_type is not null then

              l_gen_first_period_end_date   := add_multiples
                                            ( p_date => l_gen_first_period_start_date - 1  ,
                                              p_base_period_type => l_base_period_type,
                                              p_multiple => l_multiple,
                                              p_first_period_end_date => l_first_period_end_date
					      ) ;
              hr_utility.set_location(l_proc, 110);
           end if;

     end if;
--
     hr_utility.set_location(l_proc, 160);

     if l_gen_first_period_end_date < l_gen_first_period_start_date then
        fnd_message.set_name('PAY','PAY_33414_FLSA_CROSS_VAL3');
        fnd_message.raise_error;
     End if;


  -- Generate the periods.

     -- Derive the period number of the first period.

           get_period_number(
               p_time_definition_id => l_time_definition_id_to_pass,
               p_first_period_end_date => l_gen_first_period_end_date,
               p_legislation_code => l_legislation_code,
               p_business_group_id => l_business_group_id,
	       p_leg_start_date => l_leg_start_date,
               p_period_number => l_period_number);


     -- Insert the time periods for the number of years required

        hr_utility.set_location(l_proc, 120);

        l_end_years_marker := add_months(l_first_period_start_date,
                                             (12 * l_number_of_years) );

        l_next_leg_start_date := add_months(l_leg_start_date, 12);

        l_period_start_date := l_gen_first_period_start_date;
        l_period_end_date := l_gen_first_period_end_date;

        while (l_period_start_date < l_end_years_marker) loop

          hr_utility.set_location(l_proc, 130);

          begin

            select NVL(tpt.display_period_type, l_period_type)
            into   l_display_period_type
            from   per_time_period_types_vl tpt
            where  tpt.period_type = l_period_type;

            l_period_name   := to_char(l_period_number) || ' '
                                || to_char(l_period_end_date, 'YYYY') || ' '
                                || l_display_period_type ;

            hr_utility.set_location(l_proc, 140);

          exception
            when NO_DATA_FOUND then
                 l_period_name := to_char(l_period_number) || ' '
                                || to_char(l_period_end_date, 'YYYY') || ' '
                                ;
                 l_period_type := 'Dynamic Period';
                 hr_utility.set_location(l_proc, 232);
          end;

	   if l_period_time_definition_id is not null then
              l_next_period_start_date := pay_core_dates.get_time_definition_date(
	                                p_time_def_id     =>l_time_definition_id_to_pass,
                                        p_effective_date  =>l_period_start_date,
                                        p_bus_grp         =>l_business_group_id);

              l_period_end_date := l_next_period_start_date -1;
              hr_utility.set_location(l_proc, 150);

          else
              l_next_period_start_date := add_multiples
                                 ( p_date => l_period_start_date,
                                   p_base_period_type => l_base_period_type,
                                   p_multiple => l_multiple,
                                   p_first_period_end_date => l_first_period_end_date
                                 );

              l_period_end_date := l_next_period_start_date -1;
              hr_utility.set_location(l_proc, 160);

	  end if;

          if l_period_end_date < l_period_start_date then
             fnd_message.set_name('PAY','PAY_33414_FLSA_CROSS_VAL3');
             fnd_message.raise_error;
          End if;

	  insert into per_time_periods
          (time_period_id,
           start_date,
           end_date,
           period_type,
           period_num,
           period_name,
           time_definition_id
          )
          select
            per_time_periods_s.nextval,
            l_period_start_date,
            l_period_end_date,
            l_period_type,
            l_period_number,
            l_period_name,
            p_time_definition_id
          from sys.dual;

          l_period_start_date := l_period_end_date + 1 ;

          if l_period_end_date >= l_next_leg_start_date then

             hr_utility.set_location(l_proc, 170);

             l_period_number := 1;
             l_next_leg_start_date := add_months(l_next_leg_start_date, 12);

          else

             hr_utility.set_location(l_proc, 180);

             l_period_number := l_period_number + 1;

          end if;

          hr_utility.set_location(l_proc, 260);

        end loop;

  --
end generate_time_periods;
--
-- ----------------------------------------------------------------------------
-- |------------------------< CREATE_TIME_DEFINITION >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_definition
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_short_name                    in     varchar2
  ,p_definition_name               in     varchar2
  ,p_period_type                   in     varchar2 default null
  ,p_period_unit                   in     varchar2 default null
  ,p_day_adjustment                in     varchar2 default null
  ,p_dynamic_code                  in     varchar2 default null
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_definition_type               in     varchar2 default 'P'
  ,p_number_of_years               in     number   default null
  ,p_start_date                    in     date     default null
  ,p_period_time_definition_id     in     number   default null
  ,p_creator_id                    in     number   default null
  ,p_creator_type                  in     varchar2 default null
  ,p_time_definition_id               out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date        date;
  l_start_date            date;
  l_proc                  varchar2(72) := g_package||'create_time_definition';
  l_object_version_number number;
  l_time_definition_id    number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_time_definition;
  --
  -- Remember IN OUT parameter IN values
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_start_date     := trunc(p_start_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_time_definition_bk1.create_time_definition_b
      (p_effective_date                => l_effective_date
      ,p_short_name                    => p_short_name
      ,p_definition_name               => p_definition_name
      ,p_period_type                   => p_period_type
      ,p_period_unit                   => p_period_unit
      ,p_day_adjustment                => p_day_adjustment
      ,p_dynamic_code                  => p_dynamic_code
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_definition_type               => p_definition_type
      ,p_number_of_years               => p_number_of_years
      ,p_start_date                    => l_start_date
      ,p_period_time_definition_id     => p_period_time_definition_id
      ,p_creator_id                    => p_creator_id
      ,p_creator_type                  => p_creator_type
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_time_definition'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  pay_tdf_ins.ins
  (p_effective_date                 => l_effective_date
  ,p_short_name                     => p_short_name
  ,p_definition_name                => p_definition_name
  ,p_period_type                    => p_period_type
  ,p_period_unit                    => p_period_unit
  ,p_day_adjustment                 => p_day_adjustment
  ,p_dynamic_code                   => p_dynamic_code
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_definition_type                => p_definition_type
  ,p_number_of_years                => p_number_of_years
  ,p_start_date                     => l_start_date
  ,p_period_time_definition_id      => p_period_time_definition_id
  ,p_creator_id                     => p_creator_id
  ,p_creator_type                   => p_creator_type
  ,p_time_definition_id             => l_time_definition_id
  ,p_object_version_number          => l_object_version_number
  );

  generate_time_periods
   (p_time_definition_id  => l_time_definition_id);

  --
  -- Call After Process User Hook
  --
  begin
    pay_time_definition_bk1.create_time_definition_a
      (p_effective_date                => l_effective_date
      ,p_short_name                    => p_short_name
      ,p_definition_name               => p_definition_name
      ,p_period_type                   => p_period_type
      ,p_period_unit                   => p_period_unit
      ,p_day_adjustment                => p_day_adjustment
      ,p_dynamic_code                  => p_dynamic_code
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_definition_type               => p_definition_type
      ,p_number_of_years               => p_number_of_years
      ,p_start_date                    => l_start_date
      ,p_period_time_definition_id     => p_period_time_definition_id
      ,p_creator_id                    => p_creator_id
      ,p_creator_type                  => p_creator_type
      ,p_time_definition_id            => l_time_definition_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_time_definition'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_time_definition_id :=  l_time_definition_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_time_definition;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_time_definition_id     := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_time_definition;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_time_definition_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_time_definition;
--
-- ----------------------------------------------------------------------------
-- |------------------------< UPDATE_TIME_DEFINITION >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_definition
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_time_definition_id            in     number
  ,p_definition_name               in     varchar2  default hr_api.g_varchar2
  ,p_period_type                   in     varchar2  default hr_api.g_varchar2
  ,p_period_unit                   in     varchar2  default hr_api.g_varchar2
  ,p_day_adjustment                in     varchar2  default hr_api.g_varchar2
  ,p_dynamic_code                  in     varchar2  default hr_api.g_varchar2
  ,p_number_of_years               in     number    default hr_api.g_number
  ,p_start_date                    in     date      default hr_api.g_date
  ,p_period_time_definition_id     in     number    default hr_api.g_number
  ,p_creator_id                    in     number    default hr_api.g_number
  ,p_creator_type                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date        date;
  l_proc                  varchar2(72) := g_package||'update_time_definition';
  l_object_version_number number;
  l_regenerate_periods    boolean;
  l_delete_periods        boolean;
  l_in_out_parameter      number;
  l_definition_type       varchar2(30);
  --
  cursor csr_definition_type is
  select definition_type
  from   pay_time_definitions
  where  time_definition_id = p_time_definition_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_time_definition;
  --
  -- Remember IN OUT parameter IN values
  --
  l_in_out_parameter := p_object_version_number;
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    pay_time_definition_bk2.update_time_definition_b
      (p_effective_date                => l_effective_date
      ,p_time_definition_id            => p_time_definition_id
      ,p_definition_name               => p_definition_name
      ,p_period_type                   => p_period_type
      ,p_period_unit                   => p_period_unit
      ,p_day_adjustment                => p_day_adjustment
      ,p_dynamic_code                  => p_dynamic_code
      ,p_number_of_years               => p_number_of_years
      ,p_start_date                    => p_start_date
      ,p_period_time_definition_id     => p_period_time_definition_id
      ,p_creator_id                    => p_creator_id
      ,p_creator_type                  => p_creator_type
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_time_definition'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  pay_tdf_upd.upd
  (p_effective_date                => l_effective_date
  ,p_time_definition_id            => p_time_definition_id
  ,p_object_version_number         => l_object_version_number
  ,p_regenerate_periods            => l_regenerate_periods
  ,p_delete_periods                => l_delete_periods
  ,p_definition_name               => p_definition_name
  ,p_period_type                   => p_period_type
  ,p_period_unit                   => p_period_unit
  ,p_day_adjustment                => p_day_adjustment
  ,p_dynamic_code                  => p_dynamic_code
  ,p_number_of_years               => p_number_of_years
  ,p_start_date                    => p_start_date
  ,p_period_time_definition_id     => p_period_time_definition_id
  ,p_creator_id                    => p_creator_id
  ,p_creator_type                  => p_creator_type
  );

  if l_delete_periods then

     open  csr_definition_type;
     fetch csr_definition_type into l_definition_type;
     close csr_definition_type;

     if l_definition_type not in ('P', 'E', 'C') then

        delete from per_time_periods
        where  time_definition_id = p_time_definition_id;

        generate_time_periods
          (p_time_definition_id  => p_time_definition_id);

     end if;

  elsif l_regenerate_periods then

        generate_time_periods
          (p_time_definition_id  => p_time_definition_id);

  end if;

  --
  -- Call After Process User Hook
  --
  begin
    pay_time_definition_bk2.update_time_definition_a
      (p_effective_date                => l_effective_date
      ,p_time_definition_id            => p_time_definition_id
      ,p_definition_name               => p_definition_name
      ,p_period_type                   => p_period_type
      ,p_period_unit                   => p_period_unit
      ,p_day_adjustment                => p_day_adjustment
      ,p_dynamic_code                  => p_dynamic_code
      ,p_number_of_years               => p_number_of_years
      ,p_start_date                    => p_start_date
      ,p_period_time_definition_id     => p_period_time_definition_id
      ,p_creator_id                    => p_creator_id
      ,p_creator_type                  => p_creator_type
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_time_definition'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_time_definition;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_in_out_parameter;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_time_definition;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := l_in_out_parameter;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_time_definition;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_time_definition >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_definition
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_time_definition_id            in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'delete_time_definition';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_time_definition;
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    pay_time_definition_bk3.delete_time_definition_b
      (p_effective_date                => l_effective_date
      ,p_time_definition_id            => p_time_definition_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_time_definition'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  delete from per_time_periods
  where  time_definition_id = p_time_definition_id;

  delete from pay_time_def_usages
  where  time_definition_id = p_time_definition_id;

  pay_tdf_del.del
  (p_time_definition_id    => p_time_definition_id
  ,p_object_version_number => p_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
    pay_time_definition_bk3.delete_time_definition_a
      (p_effective_date                => l_effective_date
      ,p_time_definition_id            => p_time_definition_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_time_definition'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_time_definition;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_time_definition;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_time_definition;
--
end PAY_TIME_DEFINITION_API;

/
