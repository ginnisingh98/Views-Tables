--------------------------------------------------------
--  DDL for Package Body PQP_COPY_UDT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_COPY_UDT" AS
/* $Header: pqpcpudt.pkb 115.2 2002/10/04 13:37:14 rtahilia noship $ */

-- Type Declaration
TYPE IdTab IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

-- Package Collections Variables
t_ColId         IdTab;
t_RowId         IdTab;

-- Package Variables
g_package       VARCHAR2(33) := '  PQP_COPY_UDT.';
g_target_bg_id  NUMBER(15);
g_udt_prefix    VARCHAR2(15);

-- ---------------------------------------------------------------------------+
-- |------------------------< ADD_ID  >---------------------------------------|
-- ---------------------------------------------------------------------------+
PROCEDURE add_id(p_curr_id IN NUMBER
                ,p_new_id  IN NUMBER
                ,p_type_flag   IN VARCHAR2
                ) IS

  l_proc        VARCHAR2(72) := g_package||'add_id';

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);


  IF p_type_flag ='C' THEN
  -- Column
    t_ColId(p_curr_id) := p_new_id;
  ELSE -- p_type_flag = 'R'
  -- Row
    t_RowId(p_curr_id) := p_new_id;
  END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
END; -- add_id

-- ---------------------------------------------------------------------------+
-- |------------------------< GET_NEW_USER_ROW_ID >---------------------------|
-- ---------------------------------------------------------------------------+
FUNCTION get_new_pur_id(p_curr_pur_id IN NUMBER) RETURN NUMBER IS

  l_new_pur_id NUMBER(15);

  l_proc        VARCHAR2(72) := g_package||'get_new_user_row_id';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_new_pur_id := t_RowId(p_curr_pur_id);

  hr_utility.set_location('Leaving:'|| l_proc, 20);

  RETURN l_new_pur_id;

END; -- get_new_pur_id
-- ---------------------------------------------------------------------------+
-- |------------------------< COPY_TABLE >------------------------------------|
-- ---------------------------------------------------------------------------+
FUNCTION copy_table(p_curr_put_id IN NUMBER) RETURN NUMBER IS

  CURSOR c_user_table IS
  SELECT *
  FROM pay_user_tables
  WHERE user_table_id = p_curr_put_id;

  r_user_table c_user_table%ROWTYPE;

  l_new_put_id          NUMBER(9);
  l_row_id              VARCHAR2(18) := NULL;
  l_new_user_table_name pay_user_tables.user_table_name%TYPE;

  l_proc        VARCHAR2(72) := g_package||'copy_table';

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  For r_user_table in c_user_table
  Loop


    -- Add prefix to user table name
    -- Moved after the if statement as part of the UTF8 changes
    -- l_new_user_table_name := g_udt_prefix||'_'||r_user_table.user_table_name;

    --    Changed for UTF8
    --    if length(l_new_user_table_name) > 80 then

    if length(g_udt_prefix||'_'||r_user_table.user_table_name) > 80 then
      fnd_message.set_name('PQP', 'PQP_230565_UDT_NAME_TOO_LONG');
      fnd_message.raise_error;
    end if;

    -- Add prefix to user table name
    l_new_user_table_name := g_udt_prefix||'_'||r_user_table.user_table_name;

    -- Insert new row in PAY_USER_TABLES
    pay_user_tables_pkg.insert_row
                        (p_rowid                => l_row_id     -- IN OUT
                        ,p_user_table_id        => l_new_put_id -- IN OUT
                        ,p_business_group_id    => g_target_bg_id
                        ,p_legislation_code     => NULL
                        ,p_legislation_subgroup => NULL
                        ,p_range_or_match       => r_user_table.range_or_match
                        ,p_user_key_units       => r_user_table.user_key_units
                        ,p_user_table_name      => l_new_user_table_name
                        ,p_user_row_title       => r_user_table.user_row_title
                        );

  End Loop;

  hr_utility.set_location('Leaving:'|| l_proc, 20);

  Return l_new_put_id;

END; -- copy_table

-- ---------------------------------------------------------------------------+
-- |------------------------< COPY_COLUMNS >----------------------------------|
-- ---------------------------------------------------------------------------+
PROCEDURE copy_columns(p_curr_put_id IN NUMBER
                      ,p_new_put_id  IN NUMBER
                      ) IS

  CURSOR c_user_columns IS
  SELECT *
  FROM pay_user_columns
  WHERE user_table_id = p_curr_put_id;

  r_user_columns c_user_columns%ROWTYPE;

  l_new_puc_id          NUMBER(9);
  l_row_id              VARCHAR2(18) := NULL;
  l_proc        VARCHAR2(72) := g_package||'copy_columns';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  For r_user_columns in c_user_columns
  Loop

    -- Check column name unique
    pay_user_columns_pkg.check_unique_f
                        (p_rowid             => l_row_id
                        ,p_user_column_name  => r_user_columns.user_column_name
                        ,p_user_table_id     => p_new_put_id
                        ,p_business_group_id => g_target_bg_id
                        ,p_legislation_code  => NULL
                        );

    -- Insert new row into PAY_USER_COLUMNS
    pay_user_columns_pkg.insert_row
                        (p_rowid                => l_row_id     -- IN OUT
                        ,p_user_column_id       => l_new_puc_id -- IN OUT
                        ,p_user_table_id        => p_new_put_id
                        ,p_business_group_id    => g_target_bg_id
                        ,p_legislation_code     => NULL
                        ,p_legislation_subgroup => NULL
                        ,p_user_column_name     => r_user_columns.user_column_name
                        ,p_formula_id           => r_user_columns.formula_id
                        );

    -- Add column to list of copied columns
    add_id(p_curr_id    => r_user_columns.user_column_id
          ,p_new_id     => l_new_puc_id
          ,p_type_flag  => 'C'
          );

  End Loop;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
END; -- copy_columns

-- ---------------------------------------------------------------------------+
-- |------------------------< COPY_ROWS >-------------------------------------|
-- ---------------------------------------------------------------------------+
PROCEDURE copy_rows(p_curr_put_id IN NUMBER
                   ,p_new_put_id  IN NUMBER
                   ) IS

  CURSOR c_user_rows IS
  SELECT *
  FROM pay_user_rows_f
  WHERE user_table_id = p_curr_put_id
  ORDER BY user_row_id, effective_start_date;

  r_user_rows c_user_rows%ROWTYPE;

  l_prev_src_pur_id     NUMBER(15) := NULL;
  l_cre_new_pur_id      BOOLEAN    := FALSE;
  l_new_pur_id          NUMBER(15);
  l_row_id              VARCHAR2(18) := NULL;

  l_proc        VARCHAR2(72) := g_package||'copy_rows';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  For r_user_rows in c_user_rows
  Loop

    -- Bugfix : 2257831
    -- Don't create a new PUR Id if its a datetrack changed row
    IF NVL(l_prev_src_pur_id,-1) <> r_user_rows.user_row_id THEN
      l_cre_new_pur_id := TRUE;
      l_prev_src_pur_id := r_user_rows.user_row_id;
    ELSE
      l_cre_new_pur_id := FALSE;
    END IF;

    IF l_cre_new_pur_id THEN

      -- Pre Insert step for PAY_USER_ROWS_F
      pay_user_rows_pkg.pre_insert
                       (p_rowid                 => l_row_id
                       ,p_user_table_id         => p_new_put_id
                       ,p_row_low_range_or_name => r_user_rows.row_low_range_or_name
                       ,p_user_row_id           => l_new_pur_id -- OUT
                       ,p_business_group_id     => g_target_bg_id
                       );

    END IF;

    -- Insert new row into PAY_USER_ROWS_F
    INSERT INTO pay_user_rows_f
    (user_row_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,legislation_code
    ,user_table_id
    ,row_low_range_or_name
    ,display_sequence
    ,legislation_subgroup
    ,row_high_range
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date
    )
    values
    (l_new_pur_id
    ,r_user_rows.effective_start_date
    ,r_user_rows.effective_end_date
    ,g_target_bg_id
    ,NULL
    ,p_new_put_id
    ,r_user_rows.row_low_range_or_name
    ,r_user_rows.display_sequence
    ,NULL
    ,r_user_rows.row_high_range
    ,r_user_rows.last_update_date
    ,r_user_rows.last_updated_by
    ,r_user_rows.last_update_login
    ,r_user_rows.created_by
    ,r_user_rows.creation_date
    );

    -- Bugfix : 2257831
    IF l_cre_new_pur_id THEN
      -- Add row to list of copied rows
      add_id(p_curr_id    => r_user_rows.user_row_id
            ,p_new_id     => l_new_pur_id
            ,p_type_flag  => 'R'
            );
    END IF;
    --
  End Loop;

  hr_utility.set_location('Leaving:'|| l_proc, 20);

END; -- copy_rows

-- ---------------------------------------------------------------------------+
-- |------------------------< COPY_COLUMN_INSTANCES >-------------------------|
-- ---------------------------------------------------------------------------+
PROCEDURE copy_column_instances IS

  CURSOR c_user_ci(p_user_column_id IN NUMBER) IS
  SELECT *
  FROM pay_user_column_instances_f
  WHERE user_column_id = p_user_column_id
  ORDER BY user_column_instance_id, effective_start_date;

  r_user_ci c_user_ci%ROWTYPE;

  l_curr_puc_id         NUMBER(15);
  l_new_puc_id          NUMBER(15);

  l_new_pur_id          NUMBER(15);

  l_prev_src_puci_id    NUMBER(15) := NULL;
  l_cre_new_puci_id     BOOLEAN    := FALSE;
  l_prev_new_puci_id    NUMBER(15);

  l_new_puci_id         NUMBER(15);
  l_row_id              VARCHAR2(18) := NULL;

  l_proc        VARCHAR2(72) := g_package||'copy_column_instances';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  For l_cntr IN nvl(t_ColId.FIRST,-1)..nvl(t_ColId.LAST,-2)
  Loop -- 1

    If t_ColId.EXISTS(l_cntr) then
      l_new_puc_id := t_ColId(l_cntr);
      l_curr_puc_id := l_cntr;

      l_prev_src_puci_id := NULL;
      l_cre_new_puci_id := FALSE;
      l_prev_new_puci_id := NULL;

      -- Copy all instances for this column
      For r_user_ci IN c_user_ci(l_curr_puc_id)
      Loop -- 2

        -- Bugfix : 2257831
        -- Don't create a new PUR Id if its a datetrack changed row
        --   However, pay_user_column_instances_pkg.insert_row always
        --   creates a new PUCI Id, so we will first insert a new row
        --   and then update it with the PUCI Id of the previous row.
        --   Disadvantage of this approach will be the wasting
        --   of sequence values
        IF NVL(l_prev_src_puci_id,-1) <> r_user_ci.user_column_instance_id THEN
          l_cre_new_puci_id := TRUE;
          l_prev_src_puci_id := r_user_ci.user_column_instance_id;
        ELSE
          l_cre_new_puci_id := FALSE;
        END IF;

        -- For the current USER_ROW_ID, find the corresponding new USER_ROW_ID
        l_new_pur_id := get_new_pur_id(p_curr_pur_id => r_user_ci.user_row_id);

        -- Insert into PAY_USER_COLUMN_INSTANCES_F
        pay_user_column_instances_pkg.insert_row
                        (p_rowid                   => l_row_id          -- IN OUT
                        ,p_user_column_instance_id => l_new_puci_id     -- IN OUT
                        ,p_effective_start_date    => r_user_ci.effective_start_date
                        ,p_effective_end_date      => r_user_ci.effective_end_date
                        ,p_user_column_id          => l_new_puc_id
                        ,p_user_row_id             => l_new_pur_id
                        ,p_business_group_id       => g_target_bg_id
                        ,p_legislation_code        => NULL
                        ,p_legislation_subgroup    => NULL
                        ,p_value                   => r_user_ci.value
                        );

        -- Bugfix : 2257831
        IF l_cre_new_puci_id THEN

          l_prev_new_puci_id := l_new_puci_id;

        ELSE

          -- Update the newly inserted row with the PUCI Id of previous row
          --   l_row_id stores the ROWID of the newly inserted row
          pay_user_column_instances_pkg.update_row
                        (p_rowid                   => l_row_id -- IN, used to update row
                        ,p_user_column_instance_id => l_prev_new_puci_id
                        ,p_effective_start_date    => r_user_ci.effective_start_date
                        ,p_effective_end_date      => r_user_ci.effective_end_date
                        ,p_user_column_id          => l_new_puc_id
                        ,p_user_row_id             => l_new_pur_id
                        ,p_business_group_id       => g_target_bg_id
                        ,p_legislation_code        => NULL
                        ,p_legislation_subgroup    => NULL
                        ,p_value                   => r_user_ci.value
                        );

        END IF; -- l_cre_new_puci_id THEN
        --
      End Loop; -- 2
      --
    End if;  -- t_ColId.EXISTS
    --
  End Loop; -- 1

  hr_utility.set_location('Leaving:'|| l_proc, 20);

END; -- copy_column_instances

-- ---------------------------------------------------------------------------+
-- |------------------------< COPY_USER_TABLE >-------------------------------|
-- ---------------------------------------------------------------------------+
FUNCTION copy_user_table(p_curr_udt_id          IN NUMBER
                        ,p_udt_prefix           IN VARCHAR2
                        ,p_business_group_id    IN NUMBER
                        ) RETURN NUMBER IS

  l_new_put_id  NUMBER(15);

  l_proc        VARCHAR2(72) := g_package||'copy_user_table';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Set package variables
  g_target_bg_id        := p_business_group_id;
  g_udt_prefix          := upper(p_udt_prefix);

  -- Copy PAY_USER_TABLES data
  l_new_put_id := copy_table(p_curr_put_id => p_curr_udt_id);

  -- Copy PAY_USER_COLUMNS data
  copy_columns(p_curr_put_id    => p_curr_udt_id
              ,p_new_put_id     => l_new_put_id
              );

  -- Copy PAY_USER_ROWS_F data
  copy_rows(p_curr_put_id       => p_curr_udt_id
           ,p_new_put_id        => l_new_put_id
           );

  -- Copy PAY_USER_COLUMN_INSTANCES_F data
  copy_column_instances;

  hr_utility.set_location('Leaving:'|| l_proc, 20);

  -- Return the Id of the new User Table
  RETURN l_new_put_id;

END; -- copy_user_table

END pqp_copy_udt;

/
