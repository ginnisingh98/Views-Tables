--------------------------------------------------------
--  DDL for Package Body FF_FORMULA_WEBUI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FORMULA_WEBUI_PKG" as
/* $Header: fffwebpk.pkb 120.2 2006/05/26 16:08:42 swinton noship $ */
  --
  g_debug boolean := hr_utility.debug_enabled;
  --
  procedure generate_unique_formula_name(
    p_formula_type_id   in            varchar2,
    p_business_group_id in            number,
    p_legislation_code  in            varchar2,
    p_formula_name         out nocopy varchar2
    )
  is
    --
    l_tmp_name varchar2(80);
    l_startup_mode varchar2(10) := ffstup.get_mode (p_business_group_id,p_legislation_code);
    l_dummy varchar2(1);
    --
  begin
    --
    if g_debug then
      hr_utility.set_location('Entering ff_formula_webui_pkg.generate_unique_formula_name',10);
    end if;
    --
    -- Loop until we have a unique name
    loop
      --
      begin
        --
        -- Generate a temporary formula name based on the systimestamp
        l_tmp_name := 'FF_TMP_'||to_char(systimestamp,'JHH24MISSFF6');
        --
        -- Now check the formula name is unique
        -- It is highly unlikely that this name will clash, but we check
        -- just to be on the safe side
        select null into l_dummy from dual where exists
        (select null
         from ff_formulas_f a
         where a.formula_name = l_tmp_name
         and   a.formula_type_id = p_formula_type_id
         and
          ( l_startup_mode = 'MASTER'
            or
            ( l_startup_mode = 'SEED'
              and
              ( a.legislation_code = p_legislation_code
                or
                (a.legislation_code is null and a.business_group_id is null)
                or
                p_legislation_code =
                (select b.legislation_code
                 from   per_business_groups_perf b
                 where  b.business_group_id = a.business_group_id)
              )
            )
            or
            ( l_startup_mode = 'NON-SEED'
              and
              ( a.business_group_id = p_business_group_id
                or
                (a.legislation_code is null and a.business_group_id is null)
                or
                (a.business_group_id is null and a.legislation_code = p_legislation_code)
              )
            )
          ));
        -- No error was raised, so l_tmp_name must clash with an existing
        -- name
        -- Keep looping until we have a unique name
        -- l_tmp_name is updated at the start of each loop iteration
        --
      exception
        when no_data_found then
        -- No data found, so l_tmp_name is unique
        -- Exit the loop
        exit;
      end;
    end loop;
    --
    if g_debug then
      hr_utility.trace('p_formula_name: '||p_formula_name);
      hr_utility.set_location('Leaving ff_formula_webui_pkg.generate_unique_formula_name',30);
    end if;
    --
    p_formula_name := l_tmp_name;
    --
  end generate_unique_formula_name;
  --
  procedure validate_formula_name(
    p_formula_name         in out nocopy varchar2,
    p_formula_type_id      in            number,
    p_business_group_id    in            number,
    p_legislation_code     in            varchar2,
    p_effective_start_date in            date,
    p_effective_end_date   in out nocopy date,
    p_return_status           out nocopy varchar2
    )
  is
    --
    l_formula_name varchar2(80);
    l_formula_type_id number(9);
    l_business_group_id number(15);
    l_legislation_code varchar2(30);
    l_effective_start_date date;
    l_effective_end_date date;
    --
  begin
    --
    if g_debug then
      hr_utility.set_location('Entering ff_formula_webui_pkg.validate_formula_name',10);
      hr_utility.trace('p_formula_name: '||p_formula_name);
      hr_utility.trace('p_formula_type_id: '||to_char(p_formula_type_id));
      hr_utility.trace('p_business_group_id: '||to_char(p_business_group_id));
      hr_utility.trace('p_legislation_code: '||p_legislation_code);
      hr_utility.trace('p_effective_start_date: '||fnd_date.date_to_canonical(p_effective_start_date));
      hr_utility.trace('p_effective_end_date: '||fnd_date.date_to_canonical(p_effective_end_date));
    end if;
    --
    l_formula_name := p_formula_name;
    l_formula_type_id := p_formula_type_id;
    l_business_group_id := p_business_group_id;
    l_legislation_code := p_legislation_code;
    l_effective_start_date := p_effective_start_date;
    l_effective_end_date := p_effective_end_date;
    --
    -- Enable multi-messaging
    hr_multi_message.enable_message_list;
    --
    ffdict.validate_formula(
      p_formula_name => l_formula_name,
      p_formula_type_id => l_formula_type_id,
      p_bus_grp => l_business_group_id,
      p_leg_code => l_legislation_code,
      p_effective_start_date => l_effective_start_date,
      p_effective_end_date => l_effective_end_date
      );
    --
    -- Set OUT parameters
    p_formula_name := l_formula_name;
    p_effective_end_date := l_effective_end_date;
    --
    if g_debug then
      hr_utility.set_location('Leaving ff_formula_webui_pkg.validate_formula_name',20);
    end if;
    --
    -- Get the return status and disable multi-messaging
    p_return_status := hr_multi_message.get_return_status_disable;
    --
  exception
    --
    when hr_multi_message.error_message_exist then
      p_return_status := hr_multi_message.get_return_status_disable;
    --
    when others then
      hr_multi_message.add;
      p_return_status := hr_multi_message.get_return_status_disable;
    --
  end validate_formula_name;
  --
  procedure insert_formula(
    p_rowid                in out nocopy varchar2,
    p_formula_id           in out nocopy varchar2,
    p_effective_start_date in            date,
    p_effective_end_date   in            date,
    p_business_group_id    in            number,
    p_legislation_code     in            varchar2,
    p_formula_type_id      in            varchar2,
    p_formula_name         in out nocopy varchar2,
    p_description          in            varchar2,
    p_formula_text         in            long,
    p_sticky_flag          in            varchar2,
    p_last_update_date     in out nocopy date,
    p_return_status           out nocopy varchar2
    )
  is
    --
  begin
    --
    if g_debug then
      hr_utility.set_location('Entering ff_formula_webui_pkg.insert_formula',10);
    end if;
    --
    -- Enable multi-messaging
    hr_multi_message.enable_message_list;
    --
    ff_formulas_f_pkg.insert_row(
      x_rowid                 => p_rowid,
      x_formula_id            => p_formula_id,
      x_effective_start_date  => p_effective_start_date,
      x_effective_end_date    => p_effective_end_date,
      x_business_group_id     => p_business_group_id,
      x_legislation_code      => p_legislation_code,
      x_formula_type_id       => p_formula_type_id,
      x_formula_name          => p_formula_name,
      x_description           => p_description,
      --x_formula_text          => l_long_formula_text,
      x_formula_text          => p_formula_text,
      --x_sticky_flag           => p_sticky_flag,
      x_sticky_flag           => 'Y',
      x_last_update_date      => p_last_update_date
      );
    --
    if g_debug then
      hr_utility.set_location('Leaving ff_formula_webui_pkg.insert_formula',20);
    end if;
    --
    -- Get the return status and disable multi-messaging
    p_return_status := hr_multi_message.get_return_status_disable;
    --
  exception
    --
    when hr_multi_message.error_message_exist then
      p_return_status := hr_multi_message.get_return_status_disable;
    --
    when others then
      hr_multi_message.add;
      p_return_status := hr_multi_message.get_return_status_disable;
    --
  end insert_formula;
  --
  procedure update_formula(
    p_rowid                in            varchar2,
    p_formula_id           in            number,
    p_effective_start_date in            date,
    p_effective_end_date   in            date,
    p_business_group_id    in            number,
    p_legislation_code     in            varchar2,
    p_formula_type_id      in            varchar2,
    p_formula_name         in            varchar2,
    p_description          in            varchar2,
    p_formula_text         in            long,
    p_sticky_flag          in            varchar2,
    p_last_update_date     in out nocopy date,
    p_return_status           out nocopy varchar2
    )
  is
    --
  begin
    --
    if g_debug then
      hr_utility.set_location('Entering ff_formula_webui_pkg.update_formula',10);
    end if;
    --
    -- Enable multi-messaging
    hr_multi_message.enable_message_list;
    --
    ff_formulas_f_pkg.update_row(
      x_rowid                 => p_rowid,
      x_formula_id            => p_formula_id,
      x_effective_start_date  => p_effective_start_date,
      x_effective_end_date    => p_effective_end_date,
      x_business_group_id     => p_business_group_id,
      x_legislation_code      => p_legislation_code,
      x_formula_type_id       => p_formula_type_id,
      x_formula_name          => p_formula_name,
      x_description           => p_description,
      --x_formula_text          => l_long_formula_text,
      x_formula_text          => p_formula_text,
      x_sticky_flag           => p_sticky_flag,
      x_last_update_date      => p_last_update_date
      );
    --
    if g_debug then
      hr_utility.set_location('Leaving ff_formula_webui_pkg.update_formula',20);
    end if;
    --
    -- Get the return status and disable multi-messaging
    p_return_status := hr_multi_message.get_return_status_disable;
    --
  exception
    --
    when hr_multi_message.error_message_exist then
      p_return_status := hr_multi_message.get_return_status_disable;
    --
    when others then
      hr_multi_message.add;
      p_return_status := hr_multi_message.get_return_status_disable;
    --
  end update_formula;
  --
  procedure delete_formula(
    p_rowid                 in            varchar2,
    p_formula_id            in            number,
    p_dt_delete_mode        in            varchar2,
    p_validation_start_date in            date,
    p_validation_end_date   in            date,
    p_effective_date        in            date,
    p_return_status            out nocopy varchar2
    )
  is
  begin
    --
    if g_debug then
      hr_utility.set_location('Entering ff_formula_webui_pkg.delete_formula',10);
    end if;
    --
    -- Enable multi-messaging
    hr_multi_message.enable_message_list;
    --
    ff_formulas_f_pkg.delete_row(
      x_rowid                 => p_rowid,
      x_formula_id            => p_formula_id,
      x_dt_delete_mode        => p_dt_delete_mode,
      x_validation_start_date => p_validation_start_date,
      x_validation_end_date   => p_validation_end_date,
      x_effective_date        => p_effective_date
      );
    --
    if g_debug then
      hr_utility.set_location('Leaving ff_formula_webui_pkg.delete_formula',20);
    end if;
    --
    -- Get the return status and disable multi-messaging
    p_return_status := hr_multi_message.get_return_status_disable;
    --
  exception
    --
    when hr_multi_message.error_message_exist then
      p_return_status := hr_multi_message.get_return_status_disable;
    --
    when others then
      hr_multi_message.add;
      p_return_status := hr_multi_message.get_return_status_disable;
    --
  end delete_formula;
  --
  procedure lock_formula(
    p_rowid            in            varchar2,
    p_last_update_date in            date,
    p_return_status       out nocopy varchar2
    )
  is
  begin
    --
    if g_debug then
      hr_utility.set_location('Entering ff_formula_webui_pkg.lock_formula',10);
    end if;
    --
    -- Enable multi-messaging
    hr_multi_message.enable_message_list;
    --
    ff_formulas_f_pkg.lock_row(
      x_rowid            => p_rowid,
      x_last_update_date => p_last_update_date
      );
    --
    if g_debug then
      hr_utility.set_location('Leaving ff_formula_webui_pkg.lock_formula',20);
    end if;
    --
    -- Get the return status and disable multi-messaging
    p_return_status := hr_multi_message.get_return_status_disable;
    --
  exception
    --
    when hr_multi_message.error_message_exist then
      p_return_status := hr_multi_message.get_return_status_disable;
    --
    when others then
      hr_multi_message.add;
      p_return_status := hr_multi_message.get_return_status_disable;
    --
  end lock_formula;
  --
  procedure compile_formula(
    p_formula_id     in            number,
    p_effective_date in            date,
    p_outcome           out nocopy varchar2,
    p_message           out nocopy varchar2
    )
  is
    --
    l_retval  number;
    l_timeout number := 120;
    l_outcome varchar2(30);
    l_message varchar2(240);
    --
  begin
    --
    if g_debug then
      hr_utility.set_location('Entering ff_formula_webui_pkg.compile_formula',10);
    end if;
    --
    l_retval := fnd_transaction.synchronous(
      timeout     => l_timeout,
      outcome     => l_outcome,
      message     => l_message,
      application => 'FF',
      program     => 'FFTMSINGLECOMPILE',
      arg_1       => to_char(p_formula_id),
      arg_2       => fnd_date.date_to_canonical(p_effective_date)
      );
    --
    -- Return values are either 0, 1, 2 or 3
    -- 0 Indicates success - although formula compilation may have failed
    -- 1 Indicates timeout error
    -- 2 Indicates no transaction manager available
    -- 3 Indicates some other error
    if l_retval <> 0  then
      --
      if l_retval = 1 then
        --
        -- Timeout error
        hr_utility.set_message(802, 'FF_WEB_TX_MGR_TIMEOUT_ERROR');
        hr_utility.set_message_token(802, 'ERROR_MESSAGE', l_message);
        hr_utility.raise_error;
        --
      elsif l_retval = 2 then
        --
        -- No transaction manager error
        hr_utility.set_message(802, 'FF_WEB_NO_TX_MGR_ERROR');
        hr_utility.set_message_token(802, 'ERROR_MESSAGE', l_message);
        hr_utility.raise_error;
        --
      elsif l_retval = 3 then
        --
        -- Generic error
        hr_utility.set_message(802, 'FF_WEB_GENERIC_TX_MGR_ERROR');
        hr_utility.set_message_token(802, 'ERROR_MESSAGE', l_message);
        hr_utility.raise_error;
        --
      end if;
    elsif l_outcome = 'SUCCESS' then
        -- Formula compilation was successful
        p_outcome := 'S';
    else
        -- Formula compilation error
        p_outcome := 'E';
        p_message := l_message;
    end if;
    --
    if g_debug then
      hr_utility.set_location('Leaving ff_formula_webui_pkg.compile_formula',20);
    end if;
    --
  exception
    --
    when others then raise;
    --
  end compile_formula;
  --
  procedure do_autonomous_insert(
    p_rowid                        in out nocopy varchar2,
    p_formula_id                   in out nocopy number,
    p_effective_start_date                date,
    p_effective_end_date                  date,
    p_business_group_id                   number,
    p_legislation_code                    varchar2,
    p_formula_type_id                     number,
    p_formula_name                 in out nocopy varchar2,
    p_formula_text                        varchar2,
    p_last_update_date             in out nocopy date
    )
  is
    --
    pragma autonomous_transaction;
    --
  begin
    --
    ff_formulas_f_pkg.insert_row (
      x_rowid                 => p_rowid,
      x_formula_id            => p_formula_id,
      x_effective_start_date  => p_effective_start_date,
      x_effective_end_date    => p_effective_end_date,
      x_business_group_id     => p_business_group_id,
      x_legislation_code      => p_legislation_code,
      x_formula_type_id       => p_formula_type_id,
      x_formula_name          => p_formula_name,
      x_description           => null,
      x_formula_text          => p_formula_text,
      x_sticky_flag           => 'Y',
      x_last_update_date      => p_last_update_date
    );
    --
    commit;
    --
  end do_autonomous_insert;
  --
  procedure do_autonomous_delete(
    p_rowid                 varchar2,
    p_formula_id            number,
    p_effective_start_date  date,
		p_effective_end_date    date
  )
  is
    --
    pragma autonomous_transaction;
    --
  begin
    --
    ff_formulas_f_pkg.delete_row(
      x_rowid                 => p_rowid,
      x_formula_id            => p_formula_id,
      x_dt_delete_mode        => 'ZAP',
      x_validation_start_date => fnd_date.canonical_to_date('0001/01/01'),
      x_validation_end_date   => p_effective_end_date,
      x_effective_date        => p_effective_start_date
    );
    --
    commit;
    --
  end do_autonomous_delete;
  --
  procedure compile_formula_autonomously(
    p_formula_type_id      in            number,
    p_effective_start_date in            date,
    p_effective_end_date   in            date,
    p_business_group_id    in            number,
    p_legislation_code     in            varchar2,
    p_formula_text         in            long,
    p_outcome                 out nocopy varchar2,
    p_message                 out nocopy varchar2,
    p_return_status           out nocopy varchar2
    )
  is
    --
    l_rowid varchar2(240);
    l_formula_id number;
    l_formula_name varchar2(80);
    l_last_update_date date;
    --
  begin
    --
    if g_debug then
      hr_utility.set_location('Entering ff_formula_webui_pkg.compile_formula_autonomously',10);
    end if;
    --
    -- Enable multi-messaging
    hr_multi_message.enable_message_list;
    --
    -- Generate a unique formula name for this formula type, business group
    -- and legislation
    generate_unique_formula_name(
      p_formula_type_id => p_formula_type_id,
      p_business_group_id => p_business_group_id,
      p_legislation_code => p_legislation_code,
      p_formula_name => l_formula_name
      );
    --
    -- insert the formula
    do_autonomous_insert (
      p_rowid                 => l_rowid,
      p_formula_id            => l_formula_id,
      p_effective_start_date  => p_effective_start_date,
      p_effective_end_date    => p_effective_end_date,
      p_business_group_id     => p_business_group_id,
      p_legislation_code      => p_legislation_code,
      p_formula_type_id       => p_formula_type_id,
      p_formula_name          => l_formula_name,
      p_formula_text          => p_formula_text,
      p_last_update_date      => l_last_update_date
    );
    -- do the compile
    compile_formula(
      p_formula_id     => l_formula_id,
      p_effective_date => p_effective_start_date,
      p_outcome        => p_outcome,
      p_message        => p_message
    );
    -- delete the formula
    do_autonomous_delete(
      p_rowid                 => l_rowid,
      p_formula_id            => l_formula_id,
      p_effective_start_date  => p_effective_start_date,
      p_effective_end_date    => p_effective_end_date
    );
    --
    if g_debug then
      hr_utility.set_location('Leaving ff_formula_webui_pkg.compile_formula_autonomously',20);
    end if;
    --
    -- Get the return status and disable multi-messaging
    p_return_status := hr_multi_message.get_return_status_disable;
    --
  exception
    --
    when hr_multi_message.error_message_exist then
      p_return_status := hr_multi_message.get_return_status_disable;
    --
    when others then raise;
      --hr_multi_message.add;
      --p_return_status := hr_multi_message.get_return_status_disable;
    --
  end compile_formula_autonomously;
  --
  procedure run_formula(
    p_formula_id     in            number,
    p_session_date   in            date,
    p_input_name1    in            varchar2,
    p_input_name2    in            varchar2,
    p_input_name3    in            varchar2,
    p_input_name4    in            varchar2,
    p_input_name5    in            varchar2,
    p_input_name6    in            varchar2,
    p_input_name7    in            varchar2,
    p_input_name8    in            varchar2,
    p_input_name9    in            varchar2,
    p_input_name10   in            varchar2,
    p_input_name11   in            varchar2,
    p_input_name12   in            varchar2,
    p_input_name13   in            varchar2,
    p_input_name14   in            varchar2,
    p_input_name15   in            varchar2,
    p_input_name16   in            varchar2,
    p_input_name17   in            varchar2,
    p_input_name18   in            varchar2,
    p_input_name19   in            varchar2,
    p_input_name20   in            varchar2,
    p_input_name21   in            varchar2,
    p_input_name22   in            varchar2,
    p_input_name23   in            varchar2,
    p_input_name24   in            varchar2,
    p_input_name25   in            varchar2,
    p_input_name26   in            varchar2,
    p_input_name27   in            varchar2,
    p_input_name28   in            varchar2,
    p_input_name29   in            varchar2,
    p_input_name30   in            varchar2,
    p_input_value1   in            varchar2,
    p_input_value2   in            varchar2,
    p_input_value3   in            varchar2,
    p_input_value4   in            varchar2,
    p_input_value5   in            varchar2,
    p_input_value6   in            varchar2,
    p_input_value7   in            varchar2,
    p_input_value8   in            varchar2,
    p_input_value9   in            varchar2,
    p_input_value10  in            varchar2,
    p_input_value11  in            varchar2,
    p_input_value12  in            varchar2,
    p_input_value13  in            varchar2,
    p_input_value14  in            varchar2,
    p_input_value15  in            varchar2,
    p_input_value16  in            varchar2,
    p_input_value17  in            varchar2,
    p_input_value18  in            varchar2,
    p_input_value19  in            varchar2,
    p_input_value20  in            varchar2,
    p_input_value21  in            varchar2,
    p_input_value22  in            varchar2,
    p_input_value23  in            varchar2,
    p_input_value24  in            varchar2,
    p_input_value25  in            varchar2,
    p_input_value26  in            varchar2,
    p_input_value27  in            varchar2,
    p_input_value28  in            varchar2,
    p_input_value29  in            varchar2,
    p_input_value30  in            varchar2,
    p_output_name1   in out nocopy varchar2,
    p_output_name2   in out nocopy varchar2,
    p_output_name3   in out nocopy varchar2,
    p_output_name4   in out nocopy varchar2,
    p_output_name5   in out nocopy varchar2,
    p_output_name6   in out nocopy varchar2,
    p_output_name7   in out nocopy varchar2,
    p_output_name8   in out nocopy varchar2,
    p_output_name9   in out nocopy varchar2,
    p_output_name10  in out nocopy varchar2,
    p_output_name11  in out nocopy varchar2,
    p_output_name12  in out nocopy varchar2,
    p_output_name13  in out nocopy varchar2,
    p_output_name14  in out nocopy varchar2,
    p_output_name15  in out nocopy varchar2,
    p_output_name16  in out nocopy varchar2,
    p_output_name17  in out nocopy varchar2,
    p_output_name18  in out nocopy varchar2,
    p_output_name19  in out nocopy varchar2,
    p_output_name20  in out nocopy varchar2,
    p_output_name21  in out nocopy varchar2,
    p_output_name22  in out nocopy varchar2,
    p_output_name23  in out nocopy varchar2,
    p_output_name24  in out nocopy varchar2,
    p_output_name25  in out nocopy varchar2,
    p_output_name26  in out nocopy varchar2,
    p_output_name27  in out nocopy varchar2,
    p_output_name28  in out nocopy varchar2,
    p_output_name29  in out nocopy varchar2,
    p_output_name30  in out nocopy varchar2,
    p_output_value1     out nocopy varchar2,
    p_output_value2     out nocopy varchar2,
    p_output_value3     out nocopy varchar2,
    p_output_value4     out nocopy varchar2,
    p_output_value5     out nocopy varchar2,
    p_output_value6     out nocopy varchar2,
    p_output_value7     out nocopy varchar2,
    p_output_value8     out nocopy varchar2,
    p_output_value9     out nocopy varchar2,
    p_output_value10    out nocopy varchar2,
    p_output_value11    out nocopy varchar2,
    p_output_value12    out nocopy varchar2,
    p_output_value13    out nocopy varchar2,
    p_output_value14    out nocopy varchar2,
    p_output_value15    out nocopy varchar2,
    p_output_value16    out nocopy varchar2,
    p_output_value17    out nocopy varchar2,
    p_output_value18    out nocopy varchar2,
    p_output_value19    out nocopy varchar2,
    p_output_value20    out nocopy varchar2,
    p_output_value21    out nocopy varchar2,
    p_output_value22    out nocopy varchar2,
    p_output_value23    out nocopy varchar2,
    p_output_value24    out nocopy varchar2,
    p_output_value25    out nocopy varchar2,
    p_output_value26    out nocopy varchar2,
    p_output_value27    out nocopy varchar2,
    p_output_value28    out nocopy varchar2,
    p_output_value29    out nocopy varchar2,
    p_output_value30    out nocopy varchar2,
    p_return_status     out nocopy varchar2
    )
  is
    --
    v_inputs  ff_exec.inputs_t;
    v_outputs ff_exec.outputs_t;
    v_output_name varchar2(240);
    --
  begin
    --
    if g_debug then
      hr_utility.set_location('Entering ff_formula_webui_pkg.run_formula',10);
    end if;
    --
    -- Enable multi-messaging
    hr_multi_message.enable_message_list;
    --
    ff_exec.init_formula(p_formula_id, p_session_date, v_inputs, v_outputs);
    --
    -- Check to see if any errors occurred, if so the
    -- hr_multi_message.error_message_exist exception will be raised
    hr_multi_message.end_validation_set;
    --
    -- Set up the inputs and contexts to formula.
    for i in v_inputs.first..v_inputs.last loop
      --
      if upper(v_inputs(i).name) = upper(p_input_name1) then
        v_inputs(i).value := p_input_value1;
      elsif upper(v_inputs(i).name) = upper(p_input_name2) then
        v_inputs(i).value := p_input_value2;
      elsif upper(v_inputs(i).name) = upper(p_input_name3) then
        v_inputs(i).value := p_input_value3;
      elsif upper(v_inputs(i).name) = upper(p_input_name4) then
        v_inputs(i).value := p_input_value4;
      elsif upper(v_inputs(i).name) = upper(p_input_name5) then
        v_inputs(i).value := p_input_value5;
      elsif upper(v_inputs(i).name) = upper(p_input_name6) then
        v_inputs(i).value := p_input_value6;
      elsif upper(v_inputs(i).name) = upper(p_input_name7) then
        v_inputs(i).value := p_input_value7;
      elsif upper(v_inputs(i).name) = upper(p_input_name8) then
        v_inputs(i).value := p_input_value8;
      elsif upper(v_inputs(i).name) = upper(p_input_name9) then
        v_inputs(i).value := p_input_value9;
      elsif upper(v_inputs(i).name) = upper(p_input_name10) then
        v_inputs(i).value := p_input_value10;
      elsif upper(v_inputs(i).name) = upper(p_input_name11) then
        v_inputs(i).value := p_input_value11;
      elsif upper(v_inputs(i).name) = upper(p_input_name12) then
        v_inputs(i).value := p_input_value12;
      elsif upper(v_inputs(i).name) = upper(p_input_name13) then
        v_inputs(i).value := p_input_value13;
      elsif upper(v_inputs(i).name) = upper(p_input_name14) then
        v_inputs(i).value := p_input_value14;
      elsif upper(v_inputs(i).name) = upper(p_input_name15) then
        v_inputs(i).value := p_input_value15;
      elsif upper(v_inputs(i).name) = upper(p_input_name16) then
        v_inputs(i).value := p_input_value16;
      elsif upper(v_inputs(i).name) = upper(p_input_name17) then
        v_inputs(i).value := p_input_value17;
      elsif upper(v_inputs(i).name) = upper(p_input_name18) then
        v_inputs(i).value := p_input_value18;
      elsif upper(v_inputs(i).name) = upper(p_input_name19) then
        v_inputs(i).value := p_input_value19;
      elsif upper(v_inputs(i).name) = upper(p_input_name20) then
        v_inputs(i).value := p_input_value20;
      elsif upper(v_inputs(i).name) = upper(p_input_name21) then
        v_inputs(i).value := p_input_value21;
      elsif upper(v_inputs(i).name) = upper(p_input_name22) then
        v_inputs(i).value := p_input_value22;
      elsif upper(v_inputs(i).name) = upper(p_input_name23) then
        v_inputs(i).value := p_input_value23;
      elsif upper(v_inputs(i).name) = upper(p_input_name24) then
        v_inputs(i).value := p_input_value24;
      elsif upper(v_inputs(i).name) = upper(p_input_name25) then
        v_inputs(i).value := p_input_value25;
      elsif upper(v_inputs(i).name) = upper(p_input_name26) then
        v_inputs(i).value := p_input_value26;
      elsif upper(v_inputs(i).name) = upper(p_input_name27) then
        v_inputs(i).value := p_input_value27;
      elsif upper(v_inputs(i).name) = upper(p_input_name28) then
        v_inputs(i).value := p_input_value28;
      elsif upper(v_inputs(i).name) = upper(p_input_name29) then
        v_inputs(i).value := p_input_value29;
      elsif upper(v_inputs(i).name) = upper(p_input_name30) then
        v_inputs(i).value := p_input_value30;
      else
        -- Input name not recognized
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE',
                                     'FF_FORMULA_WEBUI_PKG.run_formula');
        hr_utility.set_message_token('STEP','10');
        if hr_multi_message.exception_add then
          hr_utility.raise_error;
        end if;
      end if;
      --
    end loop;
    --
    ff_exec.run_formula(v_inputs, v_outputs);
    --
    -- Now obtain the return values.
    for i in v_outputs.first..v_outputs.last loop
      --
      v_output_name := upper(v_outputs(i).name);
      --
      if v_output_name = upper(p_output_name1) then
        p_output_value1 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name2) then
        p_output_value2 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name3) then
        p_output_value3 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name4) then
        p_output_value4 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name5) then
        p_output_value5 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name6) then
        p_output_value6 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name7) then
        p_output_value7 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name8) then
        p_output_value8 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name9) then
        p_output_value9 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name10) then
        p_output_value10 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name11) then
        p_output_value11 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name12) then
        p_output_value12 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name13) then
        p_output_value13 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name14) then
        p_output_value14 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name15) then
        p_output_value15 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name16) then
        p_output_value16 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name17) then
        p_output_value17 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name18) then
        p_output_value18 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name19) then
        p_output_value19 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name20) then
        p_output_value20 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name21) then
        p_output_value21 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name22) then
        p_output_value22 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name23) then
        p_output_value23 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name24) then
        p_output_value24 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name25) then
        p_output_value25 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name26) then
        p_output_value26 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name27) then
        p_output_value27 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name28) then
        p_output_value28 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name29) then
        p_output_value29 := v_outputs(i).value;
      elsif v_output_name = upper(p_output_name30) then
        p_output_value30 := v_outputs(i).value;
      else
        -- Output name not recognized
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE',
                                     'FF_FORMULA_WEBUI_PKG.run_formula');
        hr_utility.set_message_token('STEP','20');
        if hr_multi_message.exception_add then
          hr_utility.raise_error;
        end if;
      end if;
      --
    end loop;
    --
    if g_debug then
      hr_utility.set_location('Leaving ff_formula_webui_pkg.run_formula',20);
    end if;
    --
    -- Get the return status and disable multi-messaging
    p_return_status := hr_multi_message.get_return_status_disable;
    --
  exception
    --
    when hr_multi_message.error_message_exist then
      ff_exec.reset_caches;
      p_return_status := hr_multi_message.get_return_status_disable;
    --
    when others then
      ff_exec.reset_caches;
      hr_multi_message.add;
      p_return_status := hr_multi_message.get_return_status_disable;
    --
  end run_formula;
  --
  function isFormulaCompiled(
    p_formula_id in number,
    p_effective_date in date) return varchar2
  is
    --
    cursor c_formula_compiled_info is
    select 'Y'
    from ff_compiled_info_f
    where formula_id = p_formula_id
    and p_effective_date between effective_start_date and effective_end_date;
    --
    l_formula_is_compiled varchar2(15) := 'N';
    --
  begin
    --
    if g_debug then
      hr_utility.set_location('Entering ff_formula_webui_pkg.isFormulaCompiled',10);
    end if;
    --
    open c_formula_compiled_info;
    fetch c_formula_compiled_info into l_formula_is_compiled;
    close c_formula_compiled_info;
    --
    --
    if g_debug then
      hr_utility.set_location('Leaving ff_formula_webui_pkg.isFormulaCompiled',20);
    end if;
    return l_formula_is_compiled;
  end isFormulaCompiled;
  --
  function list_function_params(
    p_function_id in number) return varchar2
  is
    --
    cursor c_fn_name (p_fn_id number) is
    select f.name
    from ff_functions f
    where f.function_id = p_fn_id;
    --
    cursor c_fn_params (p_fn_id number) is
    select fp.name, lu.meaning data_type
    from ff_function_parameters fp,
         hr_lookups lu
    where fp.function_id = p_fn_id
    and fp.data_type = lu.lookup_code
    and lu.lookup_type = 'DATA_TYPE'
    order by fp.sequence_number;
    --
    l_param_list varchar2(4000);
    l_separator varchar2(5);
    --
  begin
    --
    if g_debug then
      hr_utility.set_location('Entering ff_formula_webui_pkg.list_function_params',10);
    end if;
    --
    open c_fn_name(p_function_id);
    fetch c_fn_name into l_param_list;
    close c_fn_name;
    --
    l_param_list := l_param_list || '(';
    --
    for param in c_fn_params(p_function_id) loop
      --
      l_param_list := l_param_list || l_separator || param.name ||' '|| param.data_type;
      l_separator := ', ';
      --
    end loop;
    --
    l_param_list := l_param_list || ')';
    --
    if g_debug then
      hr_utility.trace('l_param_list: '||l_param_list);
      hr_utility.set_location('Leaving ff_formula_webui_pkg.list_function_params',20);
    end if;
    --
    return l_param_list;
    --
  end list_function_params;
  --
end FF_FORMULA_WEBUI_PKG;

/
