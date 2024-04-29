--------------------------------------------------------
--  DDL for Package Body PAY_SE_TAX_TABLE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_TAX_TABLE_UPLOAD" 
/* $Header: pysettup.pkb 120.4 2007/02/15 18:00:39 vetsrini noship $ */
AS
   g_package       CONSTANT VARCHAR2 (33) := 'PAY_SE_TAX_TABLE_UPLOAD';
   -- Global constants
   g_warning       CONSTANT NUMBER        := 1;
   g_error         CONSTANT NUMBER        := 2;
   -- Exceptions
   e_fatal_error            EXCEPTION;
   e_record_too_long        EXCEPTION;
   e_diff_record_frequency  EXCEPTION;
   e_diff_record_freq_limit EXCEPTION;
   e_empty_line             EXCEPTION;
   e_same_date              EXCEPTION;
   e_future_rec_exists      EXCEPTION;
   c_end_of_time   CONSTANT DATE      := TO_DATE ('12/31/4712', 'MM/DD/YYYY');
   start_date               DATE;
   end_date                 DATE;

   PROCEDURE main (
      errbuf                     OUT NOCOPY VARCHAR2
     ,retcode                    OUT NOCOPY NUMBER
     ,p_data_file_name           IN       VARCHAR2
     ,p_tax_table_type           IN       VARCHAR2
     ,p_effective_start_date     IN       VARCHAR2
     ,p_business_group           IN       NUMBER
   )
   IS
      CURSOR csr_legislation_code
      IS
         SELECT legislation_code
           FROM per_business_groups
          WHERE business_group_id = p_business_group;

      l_proc       CONSTANT VARCHAR2 (72)              := g_package || '.MAIN';
      l_errbuf              VARCHAR2 (1000);
      l_retcode             NUMBER;
      lr_legislation_code   csr_legislation_code%ROWTYPE;
      legislation_code      per_business_groups.legislation_code%TYPE;
   BEGIN
      l_errbuf := ' ';
      l_retcode := 0;

      OPEN csr_legislation_code;

      FETCH csr_legislation_code
       INTO lr_legislation_code;

      CLOSE csr_legislation_code;

      legislation_code := lr_legislation_code.legislation_code;
      hr_utility.set_location ('Entering:' || l_proc, 10);
      hr_utility.set_location ('p_business_group' || p_business_group, 15);
      hr_utility.set_location ('Legislation = ' || legislation_code, 20);
      hr_utility.set_location (   'Effective Start Date = '
                               || p_effective_start_date
                              ,21
                              );
      hr_utility.set_location ('c_end_of_time = ' || c_end_of_time, 22);

-- Check for Sweden Localization.
      IF legislation_code = 'SE'
      THEN
         PURGE (l_errbuf, l_retcode, NULL, NULL, NULL);
         -- Date Validation Check
           -- Call for the SQL Loader Concurrent Request
         upload_tax_to_temp_table (l_errbuf, l_retcode, p_data_file_name,p_tax_table_type);
         errbuf := l_errbuf;
         retcode := l_retcode;
         --If anything happens inside the previous call,,
         -- dont proceed further
         hr_utility.set_location ('l_retcode:' || l_retcode, 40);

         IF l_retcode IS NULL OR l_retcode = 1
         THEN
            -- Call to Load data procedure
            upload_tax_to_main_table
               (l_errbuf
               ,l_retcode
               ,p_legislation_code          => legislation_code
               ,p_effective_start_date      => TRUNC
                                                  (TO_DATE
                                                      (p_effective_start_date
                                                      ,'YYYY/MM/DD HH24:MI:SS'
                                                      )
                                                  )
               ,p_business_group            => p_business_group
               ,p_tax_table_type            => p_tax_table_type
               );
            errbuf := l_errbuf;
            retcode := l_retcode;

-- Emptying the Temp tables
            IF l_retcode IS NULL OR l_retcode = 1
            THEN
               PURGE (l_errbuf, l_retcode, NULL, NULL, NULL);
            END IF;
         END IF;

         COMMIT;
      END IF;

      hr_utility.set_location ('Leaving:' || l_proc, 40);
   END main;

/*        */

   ---------------------------------------------------------------------------------
   PROCEDURE PURGE (
      errbuf                     OUT NOCOPY VARCHAR2
     ,retcode                    OUT NOCOPY NUMBER
     ,p_business_group           IN       NUMBER
     ,p_effective_start_date     IN       VARCHAR2
     ,p_effective_end_date       IN       VARCHAR2
   )
   IS
      CURSOR csr_legislation_code
      IS
         SELECT legislation_code
           FROM per_business_groups
          WHERE business_group_id = p_business_group;

      CURSOR csr_range_table_id (
         p_legislation_code                  per_business_groups.legislation_code%TYPE
      )
      IS
         SELECT range_table_id
               ,object_version_number
           FROM pay_range_tables_f
          WHERE legislation_code = p_legislation_code
            --AND    BUSINESS_GROUP_ID       = p_business_group
            AND effective_start_date >=
                     TO_DATE (p_effective_start_date, 'YYYY/MM/DD HH24:MI:SS')
            AND effective_end_date <=
                       TO_DATE (p_effective_end_date, 'YYYY/MM/DD HH24:MI:SS');

      CURSOR csr_range_id (p_range_table_id NUMBER)
      IS
         SELECT range_id
               ,object_version_number
           FROM pay_ranges_f
          WHERE range_table_id = p_range_table_id
            AND effective_start_date >=
                     TO_DATE (p_effective_start_date, 'YYYY/MM/DD HH24:MI:SS')
            AND effective_end_date <=
                       TO_DATE (p_effective_end_date, 'YYYY/MM/DD HH24:MI:SS');

      lr_legislation_code   csr_legislation_code%ROWTYPE;
      legislation_code      per_business_groups.legislation_code%TYPE;
   BEGIN
--hr_utility.trace_on(null,'tax');
      hr_utility.set_location ('Entering: Purge ', 10);
      hr_utility.set_location ('p_business_group ' || p_business_group, 10);
      hr_utility.set_location (   'p_effective_start_date'
                               || p_effective_start_date
                              ,10
                              );
      hr_utility.set_location ('p_effective_end_date' || p_effective_end_date
                              ,10
                              );

      IF p_effective_start_date IS NULL AND p_effective_end_date IS NULL
      THEN
         DELETE FROM pay_range_temp;
      ELSE
         OPEN csr_legislation_code;

         FETCH csr_legislation_code
          INTO lr_legislation_code;

         CLOSE csr_legislation_code;

         legislation_code := lr_legislation_code.legislation_code;
         hr_utility.set_location ('Legislation_Code' || legislation_code, 10);

         FOR MASTER IN csr_range_table_id (legislation_code)
         LOOP
            FOR CHILD IN csr_range_id (MASTER.range_table_id)
            LOOP
               pay_range_api.delete_range (CHILD.range_id
                                          ,CHILD.object_version_number
                                          );
            END LOOP;

            pay_range_table_api.delete_range_table
                                                 (MASTER.range_table_id
                                                 ,MASTER.object_version_number
                                                 );
         END LOOP;
      END IF;

      COMMIT;
   END PURGE;

---------------------------------------------------------------------------------
   PROCEDURE check_date (
      p_effective_start_date     IN       VARCHAR2
     ,p_effective_end_date       IN       VARCHAR2
     ,p_message_name             IN       VARCHAR2
   )
   IS
   BEGIN
      IF TO_DATE (p_effective_start_date, 'YYYY/MM/DD HH24:MI:SS') >
                      TO_DATE (p_effective_end_date, 'YYYY/MM/DD HH24:MI:SS')
      THEN
         fnd_message.set_name ('PAY', p_message_name);
         fnd_message.raise_error;
      END IF;
   END check_date;

---------------------------------------------------------------------------

   /*          */
   PROCEDURE upload_tax_to_main_table (
      errbuf                     OUT NOCOPY VARCHAR2
     ,retcode                    OUT NOCOPY NUMBER
     ,p_legislation_code         IN       VARCHAR2
     ,p_effective_start_date     IN       DATE
     ,p_business_group           IN       NUMBER
     ,p_tax_table_type           IN       VARCHAR2
   )
   IS
      l_proc           CONSTANT VARCHAR2 (72)
                                  := g_package || '.Upload_Tax_To_Main_Table';
      -- Automatic Sequence created by API
      l_pay_f_range_table_id    pay_range_tables_f.range_table_id%TYPE;
      -- Values from flat file to be uploaded to Temp Tables
      l_range_table_num         pay_range_tables_f.range_table_number%TYPE;
      l_period_frequency        pay_range_tables_f.period_frequency%TYPE;
      l_row_value_uom           pay_range_tables_f.row_value_uom%TYPE;
      l_low_band                pay_ranges_f.low_band%TYPE;
      l_high_band               pay_ranges_f.high_band%TYPE;
      l_amount1                 pay_ranges_f.amount1%TYPE;
      l_amount2                 pay_ranges_f.amount2%TYPE;
      l_amount3                 pay_ranges_f.amount3%TYPE;
      l_amount4                 pay_ranges_f.amount4%TYPE;
      l_amount5                 pay_ranges_f.amount5%TYPE;
      l_amount6                 pay_ranges_f.amount6%TYPE;
      l_amount7                 pay_ranges_f.amount7%TYPE;
      l_amount8                 pay_ranges_f.amount8%TYPE;
      l_dummy_range_table_id    pay_range_tables_f.range_table_id%TYPE;
      l_object_version_number   pay_range_tables_f.object_version_number%TYPE;
      l_dummy                   pay_range_tables_f.object_version_number%TYPE;
      l_csr_range_table_id      pay_range_tables_f.range_table_id%TYPE;

      CURSOR csr_data_exists_on_same_date
      IS
         SELECT 'Y'
           FROM pay_range_tables_f
          WHERE legislation_code = p_legislation_code
            AND  period_frequency    = p_tax_table_type
            --AND  BUSINESS_GROUP_ID    = p_business_group
            AND effective_start_date = p_effective_start_date;

      CURSOR csr_data_exists_on_future_date
      IS
         SELECT 'Y'
               ,effective_start_date
               ,effective_end_date
           FROM pay_range_tables_f
          WHERE legislation_code = p_legislation_code
            AND  period_frequency    = p_tax_table_type
            --AND  BUSINESS_GROUP_ID    = p_business_group
            AND effective_start_date > p_effective_start_date;

      CURSOR csr_master_end_date (
         l_range_table_number                NUMBER
        ,l_period_frequency                  NUMBER
        ,l_row_value_uom                     VARCHAR2
      )
      IS
         SELECT range_table_id
               ,object_version_number
           FROM pay_range_tables_f
          WHERE legislation_code = p_legislation_code
            --AND  BUSINESS_GROUP_ID    = p_business_group
            AND effective_start_date < p_effective_start_date
            AND range_table_number = l_range_table_number
            AND row_value_uom = l_row_value_uom
            AND period_frequency = l_period_frequency
            AND effective_end_date = c_end_of_time;

      CURSOR csr_child_end_date (l_range_table_id NUMBER)
      IS
         SELECT range_id
           FROM pay_ranges_f
          WHERE range_table_id = l_range_table_id
            AND effective_start_date < p_effective_start_date
            AND effective_end_date <> c_end_of_time;

      CURSOR csr_distinct_range_values
      IS
         SELECT DISTINCT range_table_number
                        ,period_frequency
                        ,row_value_uom
                    FROM pay_range_temp;

      CURSOR csr_range_band_val_frm_tmp_tab (
         l_range_table_num                   NUMBER
        ,l_period_frequency                  VARCHAR2
        ,l_row_value_uom                     VARCHAR2
      )
      IS
         SELECT low_band
               ,high_band
               ,amount1
               ,amount2
               ,amount3
               ,amount4
               ,amount5
               ,amount6
               ,amount7
               ,amount8
           FROM pay_range_temp
          WHERE range_table_number = l_range_table_num
            AND period_frequency = l_period_frequency
            AND row_value_uom = l_row_value_uom;

      CURSOR csr_range_values_from_main_tab
      IS
         SELECT range_table_id
               ,range_table_number
               ,period_frequency
               ,row_value_uom
           FROM pay_range_tables_f
          WHERE legislation_code = p_legislation_code
            --AND  BUSINESS_GROUP_ID    = p_business_group
            AND effective_start_date = p_effective_start_date
            AND effective_end_date = c_end_of_time;

      l_check                   VARCHAR2 (20);
      lr_csr_master_end_date    csr_master_end_date%ROWTYPE;
   BEGIN
      l_check := ' ';
      hr_utility.set_location ('UPLOAD PROCESS', 10);
      l_object_version_number := 1;

-- Check for the Data if the effective date is same as available in db ,,
-- Plz say no and clear temp table and error out
      OPEN csr_data_exists_on_same_date;

      FETCH csr_data_exists_on_same_date
       INTO l_check;

      CLOSE csr_data_exists_on_same_date;

      IF l_check = 'Y'
      THEN
         RAISE e_same_date;
      END IF;

      --Resetting it to null
      l_check := ' ';

      OPEN csr_data_exists_on_future_date;

      FETCH csr_data_exists_on_future_date
       INTO l_check
           ,start_date
           ,end_date;

      CLOSE csr_data_exists_on_future_date;

      IF l_check = 'Y'
      THEN
         RAISE e_future_rec_exists;
      END IF;

      --Resetting it to null
      l_check := ' ';
-- TEMP TABLE
      l_csr_range_table_id := -99;

-- *****************************************************************************************
      FOR uni_master IN csr_distinct_range_values
      LOOP
         OPEN csr_master_end_date (uni_master.range_table_number
                                  ,uni_master.period_frequency
                                  ,uni_master.row_value_uom
                                  );

         FETCH csr_master_end_date
          INTO l_csr_range_table_id
              ,l_dummy;

         CLOSE csr_master_end_date;

         IF l_csr_range_table_id <> -99
         THEN
            -- It found the master id is already present which has to be end-dated.
            hr_utility.set_location ('PROCESS', 10);
            pay_range_table_api.update_range_table
                           (p_range_table_id             => l_csr_range_table_id
                           ,p_effective_end_date         =>   p_effective_start_date
                                                            - 1
                           ,p_object_version_number      => l_dummy
                           );
            -- End dated the master record , now itself end date the child records
            end_date_child (l_csr_range_table_id, p_effective_start_date);
            l_csr_range_table_id := -99;
         END IF;

         pay_range_table_api.create_range_table
                       (p_range_table_id             => l_dummy_range_table_id
                       ,p_effective_start_date       => p_effective_start_date
                       ,p_effective_end_date         => c_end_of_time
                       ,p_range_table_number         => uni_master.range_table_number
                       ,p_period_frequency           => uni_master.period_frequency
                       ,p_row_value_uom              => uni_master.row_value_uom
                       ,p_legislation_code           => p_legislation_code
                       ,p_business_group_id          => NULL
                       --p_business_group
         ,              p_object_version_number      => l_object_version_number
                       );
      END LOOP;

-- *****************************************************************************************

      -- Open Master parent table and fetch the range_table_num , Period_frequency and row value num
-- pick up values from temp table for this record and insert that in to Main child table
      FOR MASTER IN csr_range_values_from_main_tab
      LOOP
         -- For each record in the pay_range_tables_f
         -- pick up all record one by one from pay_ranges_temp
         -- and insert into pay_ranges_f table
         FOR CHILD IN
            csr_range_band_val_frm_tmp_tab (MASTER.range_table_number
                                           ,MASTER.period_frequency
                                           ,MASTER.row_value_uom
                                           )
         LOOP
            pay_range_api.create_range
                         (p_range_table_id             => MASTER.range_table_id
                         ,p_low_band                   => CHILD.low_band
                         ,p_high_band                  => CHILD.high_band
                         ,p_amount1                    => CHILD.amount1
                         ,p_amount2                    => CHILD.amount2
                         ,p_amount3                    => CHILD.amount3
                         ,p_amount4                    => CHILD.amount4
                         ,p_amount5                    => CHILD.amount5
                         ,p_amount6                    => CHILD.amount6
                         ,p_amount7                    => CHILD.amount7
                         ,p_amount8                    => CHILD.amount8
                         ,p_effective_start_date       => p_effective_start_date
                         ,p_effective_end_date         => c_end_of_time
                         ,p_object_version_number      => l_object_version_number
                         ,p_range_id                   => l_dummy_range_table_id
                         );
         END LOOP;
      END LOOP;
   EXCEPTION
-- *************************************
      WHEN e_same_date
      -- Data already availabe on same date
      THEN
         hr_utility.set_location (l_proc, 270);
         -- Set retcode to 2, indicating an ERROR to the ConcMgr
         retcode := g_error;
         -- Set the application error
         hr_utility.set_message (801, 'HR_377224_SE_DATE_INVALID');
         -- Return the message to the ConcMgr (This msg will appear in the log file)
         errbuf := hr_utility.GET_MESSAGE;
-- *************************************

      -- *************************************
      WHEN e_future_rec_exists
      -- Data already availabe on same date
      THEN
         hr_utility.set_location (l_proc, 270);
         -- Set retcode to 2, indicating an ERROR to the ConcMgr
         retcode := g_error;
         -- Set the application error
         hr_utility.set_message (801, 'HR_377226_SE_FUTURE_DATA_EXIST');
         hr_utility.set_message_token (801
                                      ,'START_DATE'
                                      ,TO_DATE (start_date, 'DD/MM/YYYY')
                                      );
         hr_utility.set_message_token (801
                                      ,'END_DATE'
                                      ,TO_DATE (end_date, 'DD/MM/YYYY')
                                      );
         -- Return the message to the ConcMgr (This msg will appear in the log file)
         errbuf := hr_utility.GET_MESSAGE;
-- *************************************
   END upload_tax_to_main_table;

   PROCEDURE end_date_child (
      p_range_table_id           IN       NUMBER
     ,p_effective_start_date     IN       DATE
   )
   IS
      CURSOR csr_child_end_date
      IS
         SELECT range_id
               ,object_version_number
           FROM pay_ranges_f
          WHERE range_table_id = p_range_table_id
            AND effective_start_date < p_effective_start_date
            AND effective_end_date = c_end_of_time;

      l_range_id                NUMBER;
      l_object_version_number   pay_range_tables_f.object_version_number%TYPE;
   BEGIN
      OPEN csr_child_end_date;

      LOOP
         EXIT WHEN csr_child_end_date%NOTFOUND;

         FETCH csr_child_end_date
          INTO l_range_id
              ,l_object_version_number;

         pay_range_api.update_range
                          (p_range_table_id             => p_range_table_id
                          ,p_effective_end_date         =>   p_effective_start_date
                                                           - 1
                          ,p_object_version_number      => l_object_version_number
                          ,p_range_id                   => l_range_id
                          );
      END LOOP;

      CLOSE csr_child_end_date;
   END end_date_child;

-- *****************************************************************************************
/*
   PROCEDURE NAME : Upload_Tax_To_Temp_Table
   PARAMATERS  : p_data_file_name   -- Name of the file to be read.

   PURPOSE     : To Open the file Specified from the particular Dir
           Pass it to SPLIT_LINE Procedure

   ERRORS HANDLED : Raise ERROR if No directory specified
           Raise Error for all invalid file level operations
           Like
            invalid operation
            internal error
            invalid mode
            invalid path
            invalid filehandle
            read error
*/
   PROCEDURE upload_tax_to_temp_table (
      errbuf                     OUT NOCOPY VARCHAR2
     ,retcode                    OUT NOCOPY NUMBER
     ,p_data_file_name           IN       VARCHAR2
     ,p_tax_table_type           IN       VARCHAR2
   )
   IS
      -- Procedure name
      l_proc                CONSTANT VARCHAR2 (72)
                                  := g_package || '.Upload_Tax_To_Temp_Table';
      -- Constants
      c_read_file           CONSTANT VARCHAR2 (1)                      := 'r';
      c_max_linesize        CONSTANT NUMBER                           := 4000;
      c_commit_point        CONSTANT NUMBER                           := 1000;
      c_data_exchange_dir   CONSTANT VARCHAR2 (30) := 'PER_DATA_EXCHANGE_DIR';
      -- File Handling variables
      l_file_type                    UTL_FILE.file_type;
      l_filename                     VARCHAR2 (240);
      l_location                     VARCHAR2 (4000);
      l_line_read                    VARCHAR2 (4000)                  := NULL;
      -- Batch Variables
      l_batch_seq                    NUMBER                              := 0;
      l_batch_id                     NUMBER;
      -- variables which represents columns in PAY_RANGE_TEMP table.
      l_range_table_number           pay_range_tables_f.range_table_number%TYPE;
      l_period_frequency             pay_range_tables_f.period_frequency%TYPE;
      l_row_value_uom                pay_range_tables_f.row_value_uom%TYPE;
      l_low_band                     pay_ranges_f.low_band%TYPE;
      l_high_band                    pay_ranges_f.high_band%TYPE;
      l_amount1                      pay_ranges_f.amount1%TYPE;
      l_amount2                      pay_ranges_f.amount2%TYPE;
      l_amount3                      pay_ranges_f.amount3%TYPE;
      l_amount4                      pay_ranges_f.amount4%TYPE;
      l_amount5                      pay_ranges_f.amount5%TYPE;
      l_amount6                      pay_ranges_f.amount6%TYPE;
      l_amount7                      pay_ranges_f.amount7%TYPE;
      l_amount8                      pay_ranges_f.amount8%TYPE;
      -- Local Variables
      l_diff_record_type             NUMBER                              := 0;

   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      hr_utility.set_location ('p_data_file_name ' || p_data_file_name, 1);
      l_filename := p_data_file_name;
      fnd_profile.get (c_data_exchange_dir, l_location);
      hr_utility.set_location ('Directory = ' || l_location, 30);

      IF l_location IS NULL
      THEN
         hr_utility.set_location ('Raising I/O error = ' || l_location, 35);
         -- error : I/O directory not defined
         RAISE e_fatal_error;
      END IF;

      -- Open flat file
      l_file_type :=
          UTL_FILE.fopen (l_location, l_filename, c_read_file, c_max_linesize);

      -- Loop over the file, reading in each line.
      -- GET_LINE will raise NO_DATA_FOUND when it r4eaches EOF
      -- so we use that as the exit condition for the loop
      <<read_lines_in_file>>
      LOOP
         BEGIN
            UTL_FILE.get_line (l_file_type, l_line_read);
            l_batch_seq := l_batch_seq + 1;
            hr_utility.set_location ('  line read: ' || l_line_read, 60);
            -- Calling the procedure tyo split the line into variables
            split_line (p_line                    => l_line_read
                       ,p_range_table_number      => l_range_table_number
                       ,p_row_value_uom           => l_row_value_uom
                       ,p_period_frequency        => l_period_frequency
                       ,p_low_band                => l_low_band
                       ,p_high_band               => l_high_band
                       ,p_amount1                 => l_amount1
                       ,p_amount2                 => l_amount2
                       ,p_amount3                 => l_amount3
                       ,p_amount4                 => l_amount4
                       ,p_amount5                 => l_amount5
                       ,p_amount6                 => l_amount6
                       ,p_amount7                 => l_amount7
                       ,p_amount8                 => l_amount8
                       );
         -- Warning record is of different frequency Type
         IF (trim(l_period_frequency) = trim(p_tax_table_type))
         THEN
            INSERT INTO pay_range_temp
                        (range_id
                        ,range_table_number
                        ,row_value_uom
                        ,period_frequency
                        ,earnings_type
                        ,low_band
                        ,high_band
                        ,amount1
                        ,amount2
                        ,amount3
                        ,amount4
                        ,amount5
                        ,amount6
                        ,amount7
                        ,amount8
                        )
                 VALUES (pay_ranges_f_s.NEXTVAL
                        ,l_range_table_number
                        ,l_row_value_uom
                        ,l_period_frequency
                        ,NULL
                        ,l_low_band
                        ,l_high_band
                        ,l_amount1
                        ,l_amount2
                        ,l_amount3
                        ,l_amount4
                        ,l_amount5
                        ,l_amount6
                        ,l_amount7
                        ,l_amount8
                        );
         else
            hr_utility.set_location ('  Record is of different type', 110);
            l_diff_record_type := l_diff_record_type +1;
            IF l_diff_record_type < 100
            THEN
                RAISE e_diff_record_frequency;
            ELSE
                RAISE e_diff_record_freq_limit;
            END IF;
         END IF;


            -- commit the records uppon reaching the commit point
            IF MOD (l_batch_seq, c_commit_point) = 0
            THEN
               COMMIT;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               EXIT;
-- *************************************
-- When the Record is of differnt frequency type .
            WHEN e_diff_record_frequency
            --Record is of different frequency
            THEN
               -- Set retcode to 1, indicating a WARNING to the ConcMgr
               retcode := g_warning;
               -- Set the application error
               hr_utility.set_message (801, 'HR_377252_SE_REC_DIFF_FREQ');
               hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
               hr_utility.set_message_token (801, 'LINE', l_line_read);
               hr_utility.set_location (l_proc, 260);
               -- Write the message to log file, do not raise an application error but continue
               -- (with next line)
               fnd_file.put_line (fnd_file.LOG, hr_utility.GET_MESSAGE);

-- *************************************
-- When 100 Records of different frequency type has been found.
            WHEN e_diff_record_freq_limit
            --Record is of different frequency
            THEN
         hr_utility.set_location (l_proc, 270);
         -- Set retcode to 2, indicating an ERROR to the ConcMgr
         retcode := g_error;
         -- Set the application error
         hr_utility.set_message (801, 'HR_377253_SE_REC_FREQ_LIMIT');
         -- Return the message to the ConcMgr (This msg will appear in the log file)
         errbuf := hr_utility.GET_MESSAGE;

-- *************************************
-- When the Record in the file is larger than specified size.
            WHEN e_record_too_long
            --Record is too long
            THEN
               -- Set retcode to 1, indicating a WARNING to the ConcMgr
               retcode := g_warning;
               -- Set the application error
               hr_utility.set_message (801, 'HR_377215_SE_RECORD_TOO_LONG');
               hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
               hr_utility.set_message_token (801, 'LINE', l_line_read);
               hr_utility.set_location (l_proc, 260);
               -- Write the message to log file, do not raise an application error but continue
               -- (with next line)
               fnd_file.put_line (fnd_file.LOG, hr_utility.GET_MESSAGE);
-- *************************************
            WHEN e_empty_line
            THEN
               -- Set retcode to 1, indicating a WARNING to the ConcMgr
               retcode := g_warning;
               -- Set the application error
               hr_utility.set_message (800, 'HR_377222_SE_EMPTY_LINE');
               hr_utility.set_message_token (800, 'LINE_NO', l_batch_seq);
               -- Write the message to log file, do not raise an application error but continue
               -- (with next line)
               fnd_file.put_line (fnd_file.LOG, hr_utility.GET_MESSAGE);
         END;                                            -- file reading Begin
      END LOOP read_lines_in_file;

      -- Commit the outstanding records
      COMMIT;
      UTL_FILE.fclose (l_file_type);
      hr_utility.set_location ('Leaving:' || l_proc, 260);
   EXCEPTION
-- When file location is not proper
-- ***********************************************
      WHEN e_fatal_error
      -- No directory specified
      THEN
         -- Close the file in case of error
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (l_proc, 270);
         -- Set retcode to 2, indicating an ERROR to the ConcMgr
         retcode := g_error;
         -- Set the application error
         hr_utility.set_message (801, 'HR_SE_DATA_EXCHANGE_DIR_MIS');
         -- Return the message to the ConcMgr (This msg will appear in the log file)
         errbuf := hr_utility.GET_MESSAGE;
-- ***********************************************
      WHEN UTL_FILE.invalid_operation
      -- File could not be opened as requested, perhaps because of operating system permissions
      -- Also raised when attempting a write operation on a file opened for read, or a read operation
      -- on a file opened for write.
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (l_proc, 280);
         retcode := g_error;
         errbuf :=
               'Reading File ('
            || l_location
            || ' -> '
            || l_filename
            || ') - Invalid Operation.';
-- ***********************************************
      WHEN UTL_FILE.internal_error
      -- Unspecified internal error
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (l_proc, 290);
         retcode := g_error;
         errbuf :=
               'Reading File ('
            || l_location
            || ' -> '
            || l_filename
            || ') - Internal Error.';
-- ***********************************************
      WHEN UTL_FILE.invalid_mode
      -- Invalid string specified for file mode
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (l_proc, 300);
         retcode := g_error;
         errbuf :=
               'Reading File ('
            || l_location
            || ' -> '
            || l_filename
            || ') - Invalid Mode.';
-- ***********************************************
      WHEN UTL_FILE.invalid_path
      -- Directory or filename is invalid or not accessible
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         retcode := g_error;
         errbuf :=
               'Reading File ('
            || l_location
            || ' -> '
            || l_filename
            || ') - Invalid Path or Filename.';
         hr_utility.set_location (l_proc, 310);
-- ***********************************************
      WHEN UTL_FILE.invalid_filehandle
      -- File type does not specify an open file
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (l_proc, 320);
         retcode := g_error;
         errbuf :=
               'Reading File ('
            || l_location
            || ' -> '
            || l_filename
            || ') - Invalid File Type.';
      WHEN UTL_FILE.read_error
-- ***********************************************

      -- Operating system error occurred during a read operation
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (l_proc, 330);
         retcode := g_error;
         errbuf :=
               'Reading File ('
            || l_location
            || ' -> '
            || l_filename
            || ') - Read Error.';
-- ***********************************************
   END upload_tax_to_temp_table;

/*

   PROCEDURE NAME : split_line
   PARAMATERS  :
          p_line     a line read from file
                     Out variables
               split the values in the line pass it to
               specific out parameter.
   PURPOSE     : To split up the line read  return it to specific columns.
   ERRORS HANDLED :
            e_record_too_long   When Record is Too Long.

*/
   PROCEDURE split_line (
      p_line                     IN       VARCHAR2
     ,p_range_table_number       OUT NOCOPY pay_range_tables_f.range_table_number%TYPE
     ,p_row_value_uom            OUT NOCOPY pay_range_tables_f.row_value_uom%TYPE
     ,p_period_frequency         OUT NOCOPY pay_range_tables_f.period_frequency%TYPE
     ,p_low_band                 OUT NOCOPY pay_ranges_f.low_band%TYPE
     ,p_high_band                OUT NOCOPY pay_ranges_f.high_band%TYPE
     ,p_amount1                  OUT NOCOPY pay_ranges_f.amount1%TYPE
     ,p_amount2                  OUT NOCOPY pay_ranges_f.amount2%TYPE
     ,p_amount3                  OUT NOCOPY pay_ranges_f.amount3%TYPE
     ,p_amount4                  OUT NOCOPY pay_ranges_f.amount4%TYPE
     ,p_amount5                  OUT NOCOPY pay_ranges_f.amount5%TYPE
     ,p_amount6                  OUT NOCOPY pay_ranges_f.amount6%TYPE
     ,p_amount7                  OUT NOCOPY pay_ranges_f.amount7%TYPE
     ,p_amount8                  OUT NOCOPY pay_ranges_f.amount8%TYPE
   )
   IS
      -- Procedure name
      l_proc   CONSTANT VARCHAR2 (72) := g_package || '.split_line';
      l_record_length   NUMBER        := 45;                            --33;
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 70);
      --Set record length
      l_record_length := 45;                                            --33;

      IF p_line IS NULL
      THEN
         /* If the line is empty Raise an Warning saying the line is empty */
         RAISE e_empty_line;
      ELSE
         -- Error in record if it is too long according to given format
         IF (LENGTH (p_line) > l_record_length)
         THEN
            hr_utility.set_location ('  Record too long', 110);
            RAISE e_record_too_long;
         END IF;

         p_period_frequency := SUBSTR (p_line, 1, 2);
         p_row_value_uom := SUBSTR (p_line, 3, 1);
         p_range_table_number := SUBSTR (p_line, 4, 2);
         p_low_band := TRIM (SUBSTR (p_line, 6, 7));
         p_high_band := TRIM (SUBSTR (p_line, 13, 7));
         p_amount1 := TRIM (SUBSTR (p_line, 20, 5));
         p_amount2 := TRIM (SUBSTR (p_line, 25, 5));
         p_amount3 := TRIM (SUBSTR (p_line, 30, 5));
         p_amount4 := TRIM (SUBSTR (p_line, 35, 5));
         p_amount5 := TRIM (SUBSTR (p_line, 40, 5));
-- ************************* NOT REQUIRED FOR NOW *********************
-- BUT ADDING IT FOR FUTURE USE
         p_amount6 := NULL;
         p_amount7 := NULL;
         p_amount8 := NULL;
-- ************************* NOT REQUIRED FOR NOW *********************
         hr_utility.set_location (   ' p_RANGE_TABLE_NUMBER'
                                  || p_range_table_number
                                 ,110
                                 );
         hr_utility.set_location (' p_ROW_VALUE_UOM ' || p_row_value_uom, 110);
         hr_utility.set_location (' p_PERIOD_FREQUENCY ' || p_period_frequency
                                 ,110
                                 );
         hr_utility.set_location (' p_LOW_BAND ' || p_low_band, 110);
         hr_utility.set_location (' p_HIGH_BAND ' || p_high_band, 110);
         hr_utility.set_location (' p_AMOUNT1 ' || p_amount1, 110);
         hr_utility.set_location (' p_AMOUNT2 ' || p_amount2, 110);
         hr_utility.set_location (' p_AMOUNT3 ' || p_amount3, 110);
         hr_utility.set_location (' p_AMOUNT4 ' || p_amount4, 110);
         hr_utility.set_location (' p_AMOUNT5 ' || p_amount5, 110);
         hr_utility.set_location (' p_AMOUNT6 ' || p_amount6, 110);
         hr_utility.set_location (' p_AMOUNT7 ' || p_amount7, 110);
         hr_utility.set_location (' p_AMOUNT8 ' || p_amount8, 110);
      END IF;

      hr_utility.set_location ('Leaving:' || l_proc, 120);
   END;
END pay_se_tax_table_upload;

/
