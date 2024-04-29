--------------------------------------------------------
--  DDL for Package Body PAY_KR_BEE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_BEE_UPLOAD" AS
/* $Header: pykrbee.pkb 115.5 2003/05/30 07:03:25 nnaresh noship $ */

   -- Global package name
   g_package                    CONSTANT VARCHAR2 (33) := '  pay_kr_bee_upload';

   g_batch_header                     VARCHAR2 (50)  ;
   g_batch_source                     VARCHAR2 (50)  ;
   g_batch_comments                   VARCHAR2 (100) ;

  /* name of the process , this name is used to
     do any custom validation, it defaults to HIA */

   g_process                          VARCHAR2 (10) :='HIA' ;

   e_no_matching_element                 EXCEPTION;
   e_no_matching_assignment              EXCEPTION;
   e_wrong_id_type                       EXCEPTION;
   e_invalid_value                       EXCEPTION;
   e_effective_date_issue                EXCEPTION;
   e_conf_flag_not_set                   EXCEPTION;

   PRAGMA exception_init (e_invalid_value,  -1858);

   -- Global constants
   c_type_person_id             CONSTANT VARCHAR2 (30) := 'P';
   c_type_assignment_id         CONSTANT VARCHAR2 (30) := 'A';
   c_type_employee_number       CONSTANT VARCHAR2 (30) := 'E';
   c_type_national_identifier   CONSTANT VARCHAR2 (30) := 'N';
   c_warning                    CONSTANT NUMBER        := 1;
   c_error                      CONSTANT NUMBER        := 2;


   -- default year start to 01-Jan

   FUNCTION get_dflt_year_start (p_ses_date IN DATE ) RETURN DATE
   IS
   BEGIN
     RETURN trunc(p_ses_date ,'YYYY') ;
   END;

     -- default year end to 31-Dec

   FUNCTION get_dflt_year_end (p_ses_date IN DATE ) RETURN DATE
   IS
   BEGIN
     RETURN (trunc(add_months(p_ses_date,12) ,'YYYY')-1) ;
   END;

  /* This function is added for national pension adjustment process for korea.
     If the confirmation flag is not set to ' 1' in the upload file then this
     function will return FALSE */

  FUNCTION custom_validate(p_process      IN varchar2,
                            p_batch_line  IN g_batch_line ) RETURN BOOLEAN
  IS
  BEGIN
    IF nvl(p_process,'HIA') = 'HIA' THEN
      RETURN TRUE;
    ELSIF p_process = 'NPA' THEN
    -- custom validation for national pension
      IF p_batch_line.value_4 = '1' THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
   ELSE
     RETURN TRUE;
   END IF;
  END;

FUNCTION get_row_value   (p_bus_group_id      in number,
                          p_table_name        in varchar2,
                          p_col_name          in varchar2,
                          p_table_value       in varchar2,
                          p_low_high_range    in varchar2,
                          p_effective_date    in date  default null)
         return varchar2 is
l_effective_date    date;
l_range_or_match    pay_user_tables.range_or_match%type;
l_table_id          pay_user_tables.user_table_id%type;
l_value             pay_user_column_instances_f.value%type;
l_row_low_range     pay_user_rows_f.row_low_range_or_name%type;
l_row_high_range    pay_user_rows_f.row_high_range%type;
l_leg_code          varchar2(2);

cursor csr_get_eff_date is
   select effective_date
   from   fnd_sessions
   where  session_id = userenv('sessionid');

cursor csr_get_leg_code is
   select legislation_code
   from   per_business_groups
   where  business_group_id = p_bus_group_id;

cursor csr_chk_range_match is
   select range_or_match, user_table_id
   from   pay_user_tables
   where  upper(user_table_name) = upper(p_table_name)
   and    nvl (business_group_id,
               p_bus_group_id)   = p_bus_group_id
   and    nvl(legislation_code, l_leg_code) = l_leg_code;

cursor csr_get_row_value is
   select  decode(upper(p_low_high_range),'H',R.row_high_range,R.row_low_range_or_name)
   from    pay_user_column_instances_f        CINST
   ,       pay_user_columns                   C
   ,       pay_user_rows_f                    R
   ,       pay_user_tables                    TAB
   where   TAB.user_table_id                = l_table_id
   and     C.user_table_id                  = TAB.user_table_id
   and     nvl (C.business_group_id,
                p_bus_group_id)             = p_bus_group_id
   and     nvl (C.legislation_code,
                l_leg_code)                 = l_leg_code
   and     upper (C.user_column_name)       = upper (p_col_name)
   and     CINST.user_column_id             = C.user_column_id
   and     R.user_table_id                  = TAB.user_table_id
   and     l_effective_date           between R.effective_start_date
   and     R.effective_end_date
   and     nvl (R.business_group_id,
                p_bus_group_id)             = p_bus_group_id
   and     nvl (R.legislation_code,
                l_leg_code)                 = l_leg_code
   and     fnd_number.canonical_to_number (CINST.value) =
                fnd_number.canonical_to_number (p_table_value)
   and     TAB.user_key_units               = 'N'
   and     CINST.user_row_id                = R.user_row_id
   and     l_effective_date           between CINST.effective_start_date
   and     CINST.effective_end_date
   and     nvl (CINST.business_group_id,
                p_bus_group_id)             = p_bus_group_id
   and     nvl (CINST.legislation_code,
                l_leg_code)                 = l_leg_code;
        --
begin
    --
    -- Use either the supplied date, or the date from fnd_sessions
    --
    if (p_effective_date is null) then
        open  csr_get_eff_date  ;
        fetch csr_get_eff_date into l_effective_date;
        close  csr_get_eff_date  ;
    else
        l_effective_date := p_effective_date;
    end if;
    --
    -- get the legislation code:
    --
    begin
        open  csr_get_leg_code;
        fetch csr_get_leg_code into l_leg_code;
        close  csr_get_leg_code;
    end;
    --
    -- get the type of query to be performed, either range or match
    --
    open csr_chk_range_match;
    fetch csr_chk_range_match into l_range_or_match, l_table_id;
    close csr_chk_range_match;
    --
    if (l_range_or_match = 'M') then       -- matched
      begin
        --
        -- This function is only for range table and not for match table
        RAISE_APPLICATION_ERROR(-20001,'The function GET_ROW_VALUE is only for range table and not for match table');
      end;
    else                                   -- range
      begin
        open  csr_get_row_value;
        fetch csr_get_row_value into l_row_low_range;
        close  csr_get_row_value;
        --
        return l_row_low_range;
      end;
    end if;

end get_row_value;


   -- This is the package that is called by the SRS for creating new Batches.

   PROCEDURE upload(
      errbuf                     OUT NOCOPY   VARCHAR2,
      retcode                    OUT NOCOPY   NUMBER,
      p_file_name                IN       VARCHAR2,
      p_effective_date           IN       VARCHAR2,
      p_business_group_id        IN       per_business_groups.business_group_id%TYPE,
      p_delimiter                IN       VARCHAR2,
      p_action_if_exists         IN       VARCHAR2 DEFAULT NULL,
      p_date_effective_changes   IN       VARCHAR2 DEFAULT NULL,
      p_batch_name               IN       VARCHAR2 DEFAULT NULL
   )
   IS
      -- Constants
      c_read_file           CONSTANT VARCHAR2 (1)            := 'r';
      c_max_linesize        CONSTANT NUMBER                  := 4000;
      c_commit_point        CONSTANT NUMBER                  := 20;
      c_data_exchange_dir   CONSTANT VARCHAR2 (30)           := 'PER_DATA_EXCHANGE_DIR';

      -- Procedure name

      l_proc                CONSTANT VARCHAR2 (72)           :=    g_package || 'upload ';
      l_legislation_code             per_business_groups.legislation_code%TYPE;

      -- File Handling variables
      l_file_handle                  UTL_FILE.file_type;
      l_filename                     VARCHAR2 (240);
      l_location                     VARCHAR2 (4000);
      l_line_read                    VARCHAR2 (4000)                        := NULL;
      l_batch_line                   g_batch_line;


      -- Batch Variables
      l_batch_seq                    NUMBER                                    := 0;

      -- Variables to hold returning values from procedure calls
      l_batch_id                     NUMBER;
      l_batch_line_id                NUMBER;
      l_ovn                          NUMBER;

      -- Exceptions
      e_fatal_error                  EXCEPTION;

      CURSOR csr_leg (v_bg_id per_business_groups.business_group_id%TYPE)
      IS
         SELECT legislation_code
           FROM per_business_groups
          WHERE business_group_id = v_bg_id;
   BEGIN

      -- input parameters

      hr_utility.set_location('p_file_name                '||p_file_name,1);
      hr_utility.set_location('p_effective_date           '||p_effective_date,1);
      hr_utility.set_location('p_business_group_id        '||p_business_group_id,1 );
      hr_utility.set_location('p_delimiter                '||p_delimiter,1);
      hr_utility.set_location('p_action_if_exists         '||p_action_if_exists,1);
      hr_utility.set_location('p_date_effective_changes   '||p_date_effective_changes,1);
      hr_utility.set_location('p_batch_name               '||p_batch_name,1);



      hr_utility.set_location (   'Entering:' || l_proc, 10);
      OPEN csr_leg (p_business_group_id);
      FETCH csr_leg INTO l_legislation_code;
      CLOSE csr_leg;
      hr_utility.set_location (   'Legislation = ' || l_legislation_code, 20);

      l_filename := p_file_name;
      fnd_profile.get (c_data_exchange_dir, l_location);
      hr_utility.set_location (   'directory = ' || l_location, 30);

      IF l_location IS NULL
      THEN
         -- error : I/O directory not defined
         RAISE e_fatal_error;
      END IF;

      -- Open flat file
      l_file_handle :=
          UTL_FILE.fopen (l_location, l_filename, c_read_file, c_max_linesize);

      -- Create the Batch header

      create_batch_header
            ( p_effective_date=> fnd_date.canonical_to_date (p_effective_date)
             ,p_name          => substr(p_batch_name||'('||fnd_date.date_to_displaydt(SYSDATE)||')',1,30)
             ,p_bg_id         => p_business_group_id
             ,p_action_if_exists=> NVL (p_action_if_exists,
                                        c_default_action_if_exists)
             ,p_date_effective_changes=> p_date_effective_changes
             ,p_batch_id=> l_batch_id
             ,p_ovn => l_ovn );

      -- Loop over the file, reading in each line.  GET_LINE will
      -- raise NO_DATA_FOUND when it is done, so we use that as the
      -- exit condition for the loop

      <<read_lines_in_file>>
      LOOP
         BEGIN
            UTL_FILE.get_line (l_file_handle, l_line_read);
            l_batch_seq :=   l_batch_seq
                           + 1;
         EXCEPTION
            WHEN VALUE_ERROR
            -- Input line too large for buffer specified in UTL_FILE.fopen
            THEN
               IF UTL_FILE.is_open (l_file_handle)
               THEN
                  UTL_FILE.fclose (l_file_handle);
               END IF;

               hr_utility.set_location (l_proc, 180);
               retcode := c_error;
               -- The error will mean batch_seq doesn't get upped so add 1 when
               -- reporting line
               errbuf :=    'Input line (line nr = '
                         || l_batch_seq
                         + 1
                         || ') too large for buffer (='
                         || c_max_linesize
                         || ').';
               EXIT;
            WHEN NO_DATA_FOUND
            THEN
               EXIT;
         END;

         hr_utility.set_location ( 'line read: '
            || SUBSTR (l_line_read, 1, 40),
            30
         );

         BEGIN

            -- Break the line up in its fields.
            -- The fields will be stored in l_batch_line record structure.

            break_up_line (

               p_line          => l_line_read,
               p_session_date  => fnd_date.canonical_to_date (p_effective_date),
               p_batch_id      => l_batch_id,
               p_batch_seq     => l_batch_seq,
               p_delimiter     => p_delimiter,
               p_bg_id         => p_business_group_id,
               p_leg_cd        => l_legislation_code,
               p_batch_line    => l_batch_line );

            -- Create a batch line for every line found in the file.
            IF custom_validate(p_process =>g_process ,
                               p_batch_line => l_batch_line ) = TRUE THEN

              create_batch_line (
                   p_batch_line     => l_batch_line,
                   p_bline_id       => l_batch_line_id,
                   p_obj_vn         => l_ovn  );
            ELSE
               RAISE e_conf_flag_not_set;
            END IF;

            -- commit the records uppon reaching the commit point

            IF MOD (l_batch_seq, c_commit_point) = 0
            THEN
               COMMIT;
                 NULL;
            END IF;
         EXCEPTION
            WHEN e_invalid_value
            -- A line in the file contains a field that doesn't match the type in the BEE table
            THEN
               -- Set retcode to 1, indicating a WARNING to the ConcMgr
               retcode := c_warning;
               -- Set the application error
               hr_utility.set_message (800, 'HR_78041_NO_MATCHING_TYPE');
               hr_utility.set_message_token (800, 'LINE_NR', l_batch_seq);
               hr_utility.set_message_token (800, 'LINE', l_line_read);
               -- Write the message to log file, do not raise an application error but continue
               -- (with next line)
               fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

            WHEN e_no_matching_element
            -- The element_name or element_id provided does not match an element in the database
            THEN
               -- Set retcode to 1, indicating a WARNING to the ConcMgr
               retcode := c_warning;
               -- Set the application error
               hr_utility.set_message (800, 'HR_78042_NO_MATCHING_ELEMENT');
               hr_utility.set_message_token (800, 'LINE_NR', l_batch_seq);
               hr_utility.set_message_token (800, 'LINE', l_line_read);
               -- Write the message to log file, do not raise an application error but continue
               -- (with next line)
               fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

            WHEN e_no_matching_assignment
            -- The assignment id or assignment number provided do not match an assignment in the database
            THEN
               -- Set retcode to 1, indicating a WARNING to the ConcMgr
               retcode := c_warning;
               -- Set the application error
               hr_utility.set_message (800, 'HR_78044_NO_MATCHING_ASSG'); -- name too long
               hr_utility.set_message_token (800, 'LINE_NR', l_batch_seq);
               hr_utility.set_message_token (800, 'LINE', l_line_read);
               -- Write the message to log file, do not raise an application error but continue
               -- (with next line)
               fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

            WHEN e_wrong_id_type
            -- The id type provided provided does not match P(erson), N(ational Identifier),
            -- E(mployee number or A(ssignment).  Currently these are the only id's accepted.
            THEN
               -- Set retcode to 1, indicating a WARNING to the ConcMgr
               retcode := c_warning;
               -- Set the application error
               hr_utility.set_message (800, 'HR_78043_WRONG_ID_TYPE');
               hr_utility.set_message_token (800, 'LINE_NR', l_batch_seq);
               hr_utility.set_message_token (800, 'LINE', l_line_read);
               -- Write the message to log file, do not raise an application error but continue
               -- (with next line)
               fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

            WHEN e_effective_date_issue
            -- The dates provided for the effective date fields are not in the correct format
            THEN
               -- Set retcode to 1, indicating a WARNING to the ConcMgr
               retcode := c_warning;

               -- Set the application error
               hr_utility.set_message (800, 'HR_78036_WRONG_DATE_FORMAT');
               hr_utility.set_message_token (800, 'LINE_NR', l_batch_seq);
               hr_utility.set_message_token (800, 'FORMAT',fnd_date.user_mask);


               hr_utility.set_message_token (800, 'LINE', l_line_read);
               -- Write the message to log file, do not raise an application error but continue
               -- (with next line)

               fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

            WHEN e_conf_flag_not_set
            -- The confirmation flag is not set in the text file for NPA process
            THEN
               -- Set retcode to 1, indicating a WARNING to the ConcMgr
               retcode := c_warning;

               -- Set the application error
               hr_utility.set_message (800, 'PAY_KR_CONF_FLAG_NOT_SET');
               hr_utility.set_message_token (800, 'LINE_NR', l_batch_seq);
               hr_utility.set_message_token (800, 'LINE', l_line_read);
               -- Write the message to log file, do not raise an application error but continue
               -- (with next line)

               fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

            WHEN VALUE_ERROR
            -- A field in the file does not match type with the field in the BEE table or the field
            -- is to long
            THEN
               -- Set retcode to 1, indicating a WARNING to the ConcMgr

               retcode := c_warning;

               -- Set the application error

               hr_utility.set_message (800, 'HR_78035_VALUE_ERROR');
               hr_utility.set_message_token (800, 'LINE_NR', l_batch_seq);
               hr_utility.set_message_token (800, 'LINE', l_line_read);

               -- Write the message to log file, do not raise an application error but continue
               -- (with next line)

               fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);
         END;
      END LOOP read_lines_in_file;

      -- Commit the outstanding records
      COMMIT;
      UTL_FILE.fclose (l_file_handle);
      hr_utility.set_location (   'Leaving:'|| l_proc, 50);

   -- Most off these exceptions are not translated as they should not happen normally
   -- If they do happen, something is seriously wrong and SysAdmin interference will be necessary.

   EXCEPTION
      WHEN e_fatal_error
      -- No directory specified
      THEN
         -- Close the file in case off error
         IF UTL_FILE.is_open (l_file_handle)
         THEN
            UTL_FILE.fclose (l_file_handle);
         END IF;

         hr_utility.set_location (l_proc, 100);

         -- Set retcode to 2, indicating an ERROR to the ConcMgr
         retcode := c_error;

         -- Set the application error
         hr_utility.set_message (800, 'HR_78040_DATA_EXCHANGE_DIR_MIS');

         -- Return the message to the ConcMgr (This msg will appear in the log file)
         errbuf := hr_utility.get_message;

      WHEN UTL_FILE.invalid_operation
      -- File could not be opened as requested, perhaps because of operating system permissions
      -- Also raised when attempting a write operation on a file opened for read, or a read operation
      -- on a file opened for write.

      THEN
         IF UTL_FILE.is_open (l_file_handle)
         THEN
            UTL_FILE.fclose (l_file_handle);
         END IF;

         hr_utility.set_location (l_proc, 110);
         retcode := c_error;
         errbuf := 'Reading File ('||l_location ||' -> '
                                   || l_filename
                                   || ') - Invalid Operation.';
      WHEN UTL_FILE.internal_error
      -- Unspecified internal error
      THEN
         IF UTL_FILE.is_open (l_file_handle)
         THEN
            UTL_FILE.fclose (l_file_handle);
         END IF;

         hr_utility.set_location (l_proc, 120);
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Internal Error.';

      WHEN UTL_FILE.invalid_mode
      -- Invalid string specified for file mode
      THEN
         IF UTL_FILE.is_open (l_file_handle)
         THEN
            UTL_FILE.fclose (l_file_handle);
         END IF;

         hr_utility.set_location (l_proc, 130);
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Invalid Mode.';

      WHEN UTL_FILE.invalid_path
      -- Directory or filename is invalid or not accessible
      THEN
         IF UTL_FILE.is_open (l_file_handle)
         THEN
            UTL_FILE.fclose (l_file_handle);
         END IF;

         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Invalid Path or Filename.';
         hr_utility.set_location (l_proc, 140);

      WHEN UTL_FILE.invalid_filehandle
      -- File handle does not specify an open file
      THEN
         IF UTL_FILE.is_open (l_file_handle)
         THEN
            UTL_FILE.fclose (l_file_handle);
         END IF;

         hr_utility.set_location (l_proc, 150);
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Invalid File Handle.';
      WHEN UTL_FILE.read_error

      -- Operating system error occurred during a read operation
      THEN
         IF UTL_FILE.is_open (l_file_handle)
         THEN
            UTL_FILE.fclose (l_file_handle);
         END IF;

         hr_utility.set_location (l_proc, 160);
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Read Error.';
    END upload;

   -- This procedure will take a string in which fields are delimited and break it up in its fields.
   -- These fields together with some environment variables will be stored in a record structure
   -- that closely matches the BEE PAY_BATCH_LINES tables (g_batch_line)
   -- The IN Parameters are
   --    p_line         -> the line that needs to be broken up
   --    p_session_date -> the session date
   --    p_batch_id     -> the batch id to which the line
   --    p_batch_seq    -> the batch sequence number
   --    p_delimiter    -> the delimeter used to delimit a field
   --    p_bg_id        -> the business group id
   --    p_leg_cd       -> the legislation code
   --
   -- The OUT Parameters are
   --    p_batch_line   -> the record that holds the fields

   PROCEDURE break_up_line (
      p_line           IN       VARCHAR2,
      p_session_date   IN       DATE,
      p_batch_id       IN       pay_batch_lines.batch_id%TYPE,
      p_batch_seq      IN       pay_batch_lines.batch_sequence%TYPE,
      p_delimiter      IN       VARCHAR2,
      p_bg_id          IN       per_business_groups.business_group_id%TYPE,
      p_leg_cd         IN       per_business_groups.legislation_code%TYPE,
      p_batch_line     OUT  NOCOPY g_batch_line
   )
   IS
      -- Procedure name
      l_proc        CONSTANT VARCHAR2 (72)                   :=    g_package|| 'break_up_line';
      -- local variables
      l_position             NUMBER                          := NULL;
      l_field_number         NUMBER                          := 0;
      l_line                 VARCHAR2 (4000)                 := p_line;
      l_id_type              VARCHAR2 (30)                   := NULL;
      l_id                   VARCHAR2 (30)                   := NULL;
      l_start_date           per_periods_of_service.date_start%TYPE         := NULL;
      l_final_process_date   per_periods_of_service.final_process_date%TYPE := NULL;


   BEGIN
      hr_utility.set_location (   'Entering:'|| l_proc, 10);

      -- First field in file is the session_date, this should be NULL
      BEGIN
         p_batch_line.session_date :=
               NVL (
                  fnd_date.chardate_to_date (
                     get_field (p_line => l_line, p_delimiter => p_delimiter)
                  ),
                  p_session_date
               );
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE e_effective_date_issue;
      END;

      -- Second field in file is the batch_id, this should be NULL

      p_batch_line.batch_id := NVL (
                                  get_field (
                                     p_line=> l_line,
                                     p_delimiter=> p_delimiter
                                  ),
                                  p_batch_id
                               );

      -- Third field in file is the id type

      l_id_type := get_field (p_line => l_line, p_delimiter => p_delimiter);

      IF NOT correct_type_id (l_id_type) -- correct types are A,P,E,N
      THEN
         RAISE e_wrong_id_type;
      END IF;

      -- Fourth field in file is the id

      l_id := get_field (p_line => l_line, p_delimiter => p_delimiter);

      -- Moved the get_assignment_info procedure to after we get the effective dates
      -- because these are needed for get_assignment_info.

      -- Fifth field in file is the attribute_category
      p_batch_line.attribute_category :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);

      -- Next 20 fields in file are attribute1 to attribute20

      p_batch_line.attribute1 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute2 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute3 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute4 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute5 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute6 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute7 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute8 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute9 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute10 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute11 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute12 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute13 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute14 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute15 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute16 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute17 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute18 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute19 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.attribute20 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      -- Field 26 contains the batch_sequence
      p_batch_line.batch_sequence := NVL (
                                        get_field (
                                           p_line=> l_line,
                                           p_delimiter=> p_delimiter
                                        ),
                                        p_batch_seq
                                     );
      -- Field 27 contains the concatenated_segments
      p_batch_line.concatenated_segments :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      -- Field 28 contains the cost_allocation_keyflex_id
      p_batch_line.cost_allocation_keyflex_id :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);

      BEGIN

         -- We will default this later. This is to fix bug 2058082.
         -- Field 29 contains the effective_date

         p_batch_line.effective_date :=
               fnd_date.chardate_to_date (
                  get_field (p_line => l_line, p_delimiter => p_delimiter)
               );
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE e_effective_date_issue;
      END;

      -- When the user does provide an effective_start_date and an effective_end_date,
      -- we assume they are correct and within the limits of the assignment

      get_assignment_info (
         p_bus_group_id      => p_bg_id,
         p_id_type           => l_id_type,
         p_id                => l_id,
         p_effective_date    => NVL (p_batch_line.effective_date, p_session_date),
         p_assg_id           => p_batch_line.assignment_id,
         p_assg_nr           => p_batch_line.assignment_number,
         p_start_date        => l_start_date,
         p_final_process_date=> l_final_process_date    );

      IF (    p_batch_line.assignment_id IS NULL
          AND p_batch_line.assignment_number IS NULL
         )
      THEN
         RAISE e_no_matching_assignment;
      ELSE
         BEGIN

            -- Field 30 contains the effective_start_date, if empty default 01-Jan
            -- or the start date of the assignment

            p_batch_line.effective_start_date :=
                  NVL (
                     fnd_date.chardate_to_date (
                        get_field (
                           p_line=> l_line,
                           p_delimiter=> p_delimiter
                        )
                     ),
                     GREATEST (
                        get_dflt_year_start(p_session_date),
                        l_start_date
                     )
                  );
            -- Field 31 contains the effective_end_date, if empty default to end of Year
            -- or the end date of the assignment
            -- If a person has not been terminated, the final_process_date will be null
            -- In that case we should use the date provided (or end of ear).
            -- By setting it to EOT when NULL, LEAST will always evaluate to the other value
            p_batch_line.effective_end_date :=
                  NVL (
                     fnd_date.chardate_to_date (
                        get_field (
                           p_line=> l_line,
                           p_delimiter=> p_delimiter
                        )
                     ),
                     LEAST (
                       get_dflt_year_end (p_session_date),
                        NVL (
                           l_final_process_date,
                           get_dflt_year_end(p_session_date)
                        )
                     )
                  );

            -- effective_date can't be NULL, BEE will not allow it so we set it to the effective_start_date
            -- if it wasn't provided by the user.  This will solve bug 2058082 raised against GB .

            IF (p_batch_line.effective_date IS NULL)
            THEN
               p_batch_line.effective_date :=
                                            p_batch_line.effective_start_date;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE e_effective_date_issue;
         END;
      END IF;

      -- Field 32 contains the element_name

      p_batch_line.element_name :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      -- Field 33 contains the element_type_id
      p_batch_line.element_type_id :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);

      -- Populate both element_type_id and element_name if one of them is empty
      -- Commented out for Bug# 2485470
      -- IF (   p_batch_line.element_name IS NULL
      --    OR p_batch_line.element_type_id IS NULL
      --   )
      -- THEN
         get_element_info (
            p_leg_cd=> p_leg_cd,
            p_element_name=> p_batch_line.element_name,
            p_element_type_id=> p_batch_line.element_type_id
         );
      -- END IF;
      -- End of Bug# 2485470

      IF (    p_batch_line.element_name IS NULL
          AND p_batch_line.element_type_id IS NULL
         )
      THEN
         RAISE e_no_matching_element;
      END IF;

      -- Field 34 contains the reason
      p_batch_line.reason :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      -- Field 35 upto 65 contains segment1 to segment30
      p_batch_line.segment1 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment2 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment3 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment4 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment5 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment6 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment7 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment8 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment9 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment10 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment11 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment12 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment13 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment14 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment15 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment16 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment17 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment18 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment19 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment20 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment21 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment22 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment23 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment24 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment25 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment26 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment27 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment28 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment29 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.segment30 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      -- field 66 till 81 contain value_1 to value_15
      p_batch_line.value_1 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_2 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_3 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_4 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_5 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_6 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_7 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_8 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_9 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_10 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_11 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_12 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_13 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_14 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.value_15 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      -- field 82 contain entry_information_category
      p_batch_line.entry_information_category :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      -- field 83 till 113 contain entry_information1 to entry_information30
      p_batch_line.entry_information1 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information2 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information3 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information4 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information5 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information6 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information7 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information8 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information9 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information10 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information11 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information12 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information13 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information14 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information15 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information16 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information17 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information18 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information19 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information20 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information21 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information22 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information23 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information24 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information25 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information26 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information27 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information28 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information29 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      p_batch_line.entry_information30 :=
                      get_field (p_line => l_line, p_delimiter => p_delimiter);
      hr_utility.set_location (   'Leaving:'
                               || l_proc, 1000);
   END break_up_line;

   -- This function will take a string in which fields are delimited and return the field that is identified
   -- by the occurence parameter, by default this will be the first field. It also chops off the part that
   -- was found from the string.
   -- E.g. get_field('1;2;3;4;5;',';') will return '1' and change '1;2;3;4;5;' to '2;3;4;5;'
   -- E.g. get_field('1;2;3;4;5;',';',1,3) will return '1;2;3' and change '1;2;3;4;5;' to '4;5;'
   -- The IN Parameters are
   --    p_line         -> the string which needs to be searched
   --    p_delimiter    -> the delimeter used to delimit a field
   --    p_start_pos    -> the start position of the search
   --    p_occurence    -> the occurence at which the search stops
   --                      e.g. if this is 3 it will look for the third occurence of p_delimiter
   FUNCTION get_field (
      p_line        IN OUT NOCOPY  VARCHAR2,
      p_delimiter   IN       VARCHAR2,
      p_start_pos   IN       NUMBER DEFAULT 1,
      p_occurance   IN       NUMBER DEFAULT 1
   )
      RETURN VARCHAR2
   IS
      l_position   NUMBER          := NULL;
      l_field      VARCHAR2 (4000) := NULL;
   BEGIN
      l_position := INSTR (p_line, p_delimiter, p_start_pos, p_occurance);

      IF (l_position > 0)
      THEN
         l_field := SUBSTR (p_line, 1,   l_position
                                       - 1);
         hr_utility.set_location (
               RPAD ('Field', 31)
            || RPAD (LPAD (l_position, 3), 4)
            || l_field,
            70
         );
         p_line := SUBSTR (p_line,   l_position
                                   + LENGTH (p_delimiter));
      ELSE -- No delimiter found so probably this is the last field
         l_field := p_line;
         p_line := NULL;
      END IF;

      RETURN l_field;
   END get_field;

   -- This procedure will create a batch header
   -- The IN Parameters are
   --    p_effective_date -> the effective date
   --    p_name           -> the batch name
   --    p_bg_id          -> the business group id
   --    p_action_if_exists       -> The action that needs to be taken when the entry already exists
   --                                Possible values are 'I' (Insert), 'R' (Reject) or 'U' (Update)
   --    p_date_effective_changes -> The date effective change that needs to happen
   --                                Possible values are 'C' (Correct), 'O' (Override) or 'U' (Update)
   --                                This should only be used if p_action_if_exists = 'U'
   --
   -- The OUT Parameters are
   --    p_batch_id      -> the batch id of the created batch header
   --    p_ovn           -> the object version number of the created batch header
   PROCEDURE create_batch_header (
      p_effective_date           IN       DATE,
      p_name                     IN       VARCHAR2,
      p_bg_id                    IN       NUMBER,
      p_action_if_exists         IN       VARCHAR2
            DEFAULT c_default_action_if_exists,
      p_date_effective_changes   IN       VARCHAR2 DEFAULT NULL,
      p_batch_id                 OUT NOCOPY  NUMBER,
      p_ovn                      OUT NOCOPY  NUMBER
   )
   IS
      l_proc                           CONSTANT VARCHAR2 (72)
               :=    g_package
                  || 'create_batch_header';
      l_date_effective_changes                  VARCHAR2 (30)   := NULL;
      c_update_action_if_exists        CONSTANT VARCHAR2 (1)    := 'U'; --Update existing element entry
      c_default_dt_effective_changes   CONSTANT VARCHAR2 (1)    := 'U'; --Update/Change Insert
      c_batch_reference                         VARCHAR2 (50)   := g_batch_header;
      c_batch_source                            VARCHAR2 (50)   := g_batch_source;
      c_comments                                VARCHAR2 (100) := g_batch_comments ;

   BEGIN
      hr_utility.set_location (   'Entering:'
                               || l_proc, 10);

      -- CREATE_BATCH_HEADER definition
      /****************************************************************
       procedure create_batch_header
        (p_validate                      in     boolean  default false
        ,p_session_date                  in     date
        ,p_batch_name                    in     varchar2
        ,p_batch_status                  in     varchar2 default 'U'
        ,p_business_group_id             in     number
        ,p_action_if_exists              in     varchar2 default 'R'
        ,p_batch_reference               in     varchar2 default null
        ,p_batch_source                  in     varchar2 default null
        ,p_comments                      in     varchar2 default null
        ,p_date_effective_changes        in     varchar2 default 'C'
        ,p_purge_after_transfer          in     varchar2 default 'N'
        ,p_reject_if_future_changes      in     varchar2 default 'Y'
        ,p_batch_id                         out number
        ,p_object_version_number            out number);
      ******************************************************************/

      -- p_date_effective_changes should only be populated if p_action_if_exists = 'U'
      IF (p_action_if_exists = c_update_action_if_exists)
      THEN
         IF (p_date_effective_changes IS NULL)
         THEN -- Default p_date_effective_changes
            l_date_effective_changes := c_default_dt_effective_changes;
         ELSE
            l_date_effective_changes := p_date_effective_changes;
         END IF;
      ELSE -- set p_date_effective_changes to null
         l_date_effective_changes := NULL;
      END IF;

      pay_batch_element_entry_api.create_batch_header (
         p_session_date          => p_effective_date,
         p_batch_name            => p_name,
         p_business_group_id     => p_bg_id,
         p_action_if_exists      => p_action_if_exists,
         p_date_effective_changes=> l_date_effective_changes,
         p_batch_reference       => c_batch_reference,
         p_batch_source          => c_batch_source,
         p_comments              => c_comments,
         p_batch_id              => p_batch_id, -- out
         p_object_version_number => p_ovn -- out
      );
      hr_utility.set_location (   'Leaving:'
                               || l_proc, 20);
   END create_batch_header;

   PROCEDURE create_batch_line (
      p_session_date                 IN       DATE,
      p_batch_id                     IN       NUMBER,
      p_assignment_id                IN       NUMBER DEFAULT NULL,
      p_assignment_number            IN       VARCHAR2 DEFAULT NULL,
      p_attribute_category           IN       VARCHAR2 DEFAULT NULL,
      p_attribute1                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute2                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute3                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute4                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute5                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute6                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute7                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute8                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute9                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute10                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute11                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute12                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute13                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute14                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute15                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute16                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute17                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute18                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute19                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute20                  IN       VARCHAR2 DEFAULT NULL,
      p_batch_sequence               IN       NUMBER DEFAULT NULL,
      p_concatenated_segments        IN       VARCHAR2 DEFAULT NULL,
      p_cost_allocation_keyflex_id   IN       NUMBER DEFAULT NULL,
      p_effective_date               IN       DATE,
      p_effective_start_date         IN       DATE DEFAULT NULL,
      p_effective_end_date           IN       DATE DEFAULT NULL,
      p_element_name                 IN       VARCHAR2 DEFAULT NULL,
      p_element_type_id              IN       NUMBER DEFAULT NULL,
      p_reason                       IN       VARCHAR2 DEFAULT NULL,
      p_segment1                     IN       VARCHAR2 DEFAULT NULL,
      p_segment2                     IN       VARCHAR2 DEFAULT NULL,
      p_segment3                     IN       VARCHAR2 DEFAULT NULL,
      p_segment4                     IN       VARCHAR2 DEFAULT NULL,
      p_segment5                     IN       VARCHAR2 DEFAULT NULL,
      p_segment6                     IN       VARCHAR2 DEFAULT NULL,
      p_segment7                     IN       VARCHAR2 DEFAULT NULL,
      p_segment8                     IN       VARCHAR2 DEFAULT NULL,
      p_segment9                     IN       VARCHAR2 DEFAULT NULL,
      p_segment10                    IN       VARCHAR2 DEFAULT NULL,
      p_segment11                    IN       VARCHAR2 DEFAULT NULL,
      p_segment12                    IN       VARCHAR2 DEFAULT NULL,
      p_segment13                    IN       VARCHAR2 DEFAULT NULL,
      p_segment14                    IN       VARCHAR2 DEFAULT NULL,
      p_segment15                    IN       VARCHAR2 DEFAULT NULL,
      p_segment16                    IN       VARCHAR2 DEFAULT NULL,
      p_segment17                    IN       VARCHAR2 DEFAULT NULL,
      p_segment18                    IN       VARCHAR2 DEFAULT NULL,
      p_segment19                    IN       VARCHAR2 DEFAULT NULL,
      p_segment20                    IN       VARCHAR2 DEFAULT NULL,
      p_segment21                    IN       VARCHAR2 DEFAULT NULL,
      p_segment22                    IN       VARCHAR2 DEFAULT NULL,
      p_segment23                    IN       VARCHAR2 DEFAULT NULL,
      p_segment24                    IN       VARCHAR2 DEFAULT NULL,
      p_segment25                    IN       VARCHAR2 DEFAULT NULL,
      p_segment26                    IN       VARCHAR2 DEFAULT NULL,
      p_segment27                    IN       VARCHAR2 DEFAULT NULL,
      p_segment28                    IN       VARCHAR2 DEFAULT NULL,
      p_segment29                    IN       VARCHAR2 DEFAULT NULL,
      p_segment30                    IN       VARCHAR2 DEFAULT NULL,
      p_value_1                      IN       VARCHAR2 DEFAULT NULL,
      p_value_2                      IN       VARCHAR2 DEFAULT NULL,
      p_value_3                      IN       VARCHAR2 DEFAULT NULL,
      p_value_4                      IN       VARCHAR2 DEFAULT NULL,
      p_value_5                      IN       VARCHAR2 DEFAULT NULL,
      p_value_6                      IN       VARCHAR2 DEFAULT NULL,
      p_value_7                      IN       VARCHAR2 DEFAULT NULL,
      p_value_8                      IN       VARCHAR2 DEFAULT NULL,
      p_value_9                      IN       VARCHAR2 DEFAULT NULL,
      p_value_10                     IN       VARCHAR2 DEFAULT NULL,
      p_value_11                     IN       VARCHAR2 DEFAULT NULL,
      p_value_12                     IN       VARCHAR2 DEFAULT NULL,
      p_value_13                     IN       VARCHAR2 DEFAULT NULL,
      p_value_14                     IN       VARCHAR2 DEFAULT NULL,
      p_value_15                     IN       VARCHAR2 DEFAULT NULL,
      p_entry_information_category   IN       VARCHAR2 DEFAULT NULL,
      p_entry_information1           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information2           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information3           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information4           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information5           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information6           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information7           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information8           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information9           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information10          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information11          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information12          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information13          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information14          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information15          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information16          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information17          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information18          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information19          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information20          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information21          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information22          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information23          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information24          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information25          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information26          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information27          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information28          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information29          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information30          IN       VARCHAR2 DEFAULT NULL,
      p_bl_id                        OUT NOCOPY  NUMBER,
      p_ovn                          OUT NOCOPY  NUMBER
   )
   IS
      l_proc            CONSTANT VARCHAR2 (72)
               :=    g_package || 'create_batch_line';
      c_element_entry   CONSTANT VARCHAR2 (30) := 'E';
   BEGIN
      hr_utility.set_location (   'Entering:'
                               || l_proc, 10);
      -- CREATE_BATCH_LINE definition
      /****************************************************************
      procedure create_batch_line
        (p_validate                      in     boolean  default false
        ,p_session_date                  in     date
        ,p_batch_id                      in     number
        ,p_batch_line_status             in     varchar2 default 'U'
        ,p_assignment_id                 in     number   default null
        ,p_assignment_number             in     varchar2 default null
        ,p_attribute_category            in     varchar2 default null
        ,p_attribute1                    in     varchar2 default null
        ,...
        ,p_attribute20                   in     varchar2 default null
        ,p_batch_sequence                in     number   default null
        ,p_concatenated_segments         in     varchar2 default null
        ,p_cost_allocation_keyflex_id    in     number   default null
        ,p_effective_date          in     date     default null
        ,p_effective_start_date          in     date     default null
        ,p_effective_end_date            in     date     default null
        ,p_element_name                  in     varchar2 default null
        ,p_element_type_id               in     number   default null
        ,p_entry_type                    in     varchar2 default null
        ,p_reason                        in     varchar2 default null
        ,p_segment1                      in     varchar2 default null
        ,...
        ,p_segment30                     in     varchar2 default null
        ,p_value_1                       in     varchar2 default null
        ,...
        ,p_value_15                      in     varchar2 default null
        ,p_batch_line_id                    out number
        ,p_object_version_number            out number);
      ******************************************************************/

      pay_batch_element_entry_api.create_batch_line (
         p_session_date       => p_session_date,
         p_batch_id           => p_batch_id,
         p_assignment_id      => p_assignment_id,
         p_assignment_number  => p_assignment_number,
         p_attribute_category => p_attribute_category,
         p_attribute1         => p_attribute1,
         p_attribute2         => p_attribute2,
         p_attribute3         => p_attribute3,
         p_attribute4         => p_attribute4,
         p_attribute5         => p_attribute5,
         p_attribute6         => p_attribute6,
         p_attribute7         => p_attribute7,
         p_attribute8         => p_attribute8,
         p_attribute9         => p_attribute9,
         p_attribute10        => p_attribute10,
         p_attribute11        => p_attribute11,
         p_attribute12        => p_attribute12,
         p_attribute13        => p_attribute13,
         p_attribute14        => p_attribute14,
         p_attribute15        => p_attribute15,
         p_attribute16        => p_attribute16,
         p_attribute17        => p_attribute17,
         p_attribute18        => p_attribute18,
         p_attribute19        => p_attribute19,
         p_attribute20         => p_attribute20,
         p_batch_sequence      => p_batch_sequence,
         p_concatenated_segments     => p_concatenated_segments,
         p_cost_allocation_keyflex_id=> p_cost_allocation_keyflex_id,
         p_effective_date            => p_effective_date,
         p_effective_start_date      => p_effective_start_date,
         p_effective_end_date        => p_effective_end_date,
         p_element_name              => p_element_name,
         p_element_type_id           => p_element_type_id,
         p_entry_type=>              c_element_entry, -- Element Entry
         p_reason                    => p_reason,
         p_segment1                  => p_segment1,
         p_segment2                  => p_segment2,
         p_segment3                  => p_segment3,
         p_segment4                  => p_segment4,
         p_segment5                  => p_segment5,
         p_segment6                  => p_segment6,
         p_segment7                  => p_segment7,
         p_segment8                  => p_segment8,
         p_segment9                  => p_segment9,
         p_segment10                 => p_segment10,
         p_segment11                 => p_segment11,
         p_segment12                 => p_segment12,
         p_segment13                 => p_segment13,
         p_segment14                 => p_segment14,
         p_segment15                 => p_segment15,
         p_segment16                 => p_segment16,
         p_segment17                 => p_segment17,
         p_segment18                 => p_segment18,
         p_segment19                 => p_segment19,
         p_segment20                 => p_segment20,
         p_segment21                 => p_segment21,
         p_segment22                 => p_segment22,
         p_segment23                 => p_segment23,
         p_segment24                 => p_segment24,
         p_segment25                 => p_segment25,
         p_segment26                 => p_segment26,
         p_segment27                 => p_segment27,
         p_segment28                 => p_segment28,
         p_segment29                 => p_segment29,
         p_segment30                 => p_segment30,
         p_value_1                   => p_value_1,
         p_value_2                   => p_value_2,
         p_value_3                   => p_value_3,
         p_value_4                   => p_value_4,
         p_value_5                   => p_value_5,
         p_value_6                   => p_value_6,
         p_value_7                   => p_value_7,
         p_value_8                   => p_value_8,
         p_value_9                   => p_value_9,
         p_value_10                  => p_value_10,
         p_value_11                  => p_value_11,
         p_value_12                  => p_value_12,
         p_value_13                  => p_value_13,
         p_value_14                  => p_value_14,
         p_value_15                  => p_value_15,
         p_entry_information_category=> p_entry_information_category,
         p_entry_information1        => p_entry_information1,
         p_entry_information2        => p_entry_information2,
         p_entry_information3        => p_entry_information3,
         p_entry_information4        => p_entry_information4,
         p_entry_information5        => p_entry_information5,
         p_entry_information6        => p_entry_information6,
         p_entry_information7        => p_entry_information7,
         p_entry_information8        => p_entry_information8,
         p_entry_information9        => p_entry_information9,
         p_entry_information10       => p_entry_information10,
         p_entry_information11       => p_entry_information11,
         p_entry_information12       => p_entry_information12,
         p_entry_information13       => p_entry_information13,
         p_entry_information14       => p_entry_information14,
         p_entry_information15       => p_entry_information15,
         p_entry_information16       => p_entry_information16,
         p_entry_information17       => p_entry_information17,
         p_entry_information18       => p_entry_information18,
         p_entry_information19       => p_entry_information19,
         p_entry_information20       => p_entry_information20,
         p_entry_information21       => p_entry_information21,
         p_entry_information22       => p_entry_information22,
         p_entry_information23       => p_entry_information23,
         p_entry_information24       => p_entry_information24,
         p_entry_information25       => p_entry_information25,
         p_entry_information26       => p_entry_information26,
         p_entry_information27       => p_entry_information27,
         p_entry_information28       => p_entry_information28,
         p_entry_information29       => p_entry_information29,
         p_entry_information30       => p_entry_information20,
         p_batch_line_id             => p_bl_id, -- out
         p_object_version_number     => p_ovn -- out
      );
      hr_utility.set_location (   'Leaving:'|| l_proc, 20);
   END create_batch_line;

   -- OVERLOADING PROCEDURE

   PROCEDURE create_batch_line (
      p_batch_line   IN       g_batch_line,
      p_bline_id     OUT  NOCOPY  NUMBER,
      p_obj_vn       OUT  NOCOPY  NUMBER
   )
   IS
      l_proc   CONSTANT VARCHAR2 (72)
               :=    g_package|| 'create_batch_line';
   BEGIN
      hr_utility.set_location (   'Entering:'|| l_proc, 10);

      create_batch_line (
         p_session_date          => p_batch_line.session_date,
         p_batch_id              => p_batch_line.batch_id,
         p_assignment_id         => p_batch_line.assignment_id,
         p_assignment_number     => p_batch_line.assignment_number,
         p_attribute_category    => p_batch_line.attribute_category,
         p_attribute1            => p_batch_line.attribute1,
         p_attribute2            => p_batch_line.attribute2,
         p_attribute3            => p_batch_line.attribute3,
         p_attribute4            => p_batch_line.attribute4,
         p_attribute5            => p_batch_line.attribute5,
         p_attribute6            => p_batch_line.attribute6,
         p_attribute7            => p_batch_line.attribute7,
         p_attribute8            => p_batch_line.attribute8,
         p_attribute9            => p_batch_line.attribute9,
         p_attribute10           => p_batch_line.attribute10,
         p_attribute11           => p_batch_line.attribute11,
         p_attribute12           => p_batch_line.attribute12,
         p_attribute13           => p_batch_line.attribute13,
         p_attribute14           => p_batch_line.attribute14,
         p_attribute15           => p_batch_line.attribute15,
         p_attribute16           => p_batch_line.attribute16,
         p_attribute17           => p_batch_line.attribute17,
         p_attribute18           => p_batch_line.attribute18,
         p_attribute19           => p_batch_line.attribute19,
         p_attribute20           => p_batch_line.attribute20,
         p_batch_sequence        => p_batch_line.batch_sequence,
         p_concatenated_segments => p_batch_line.concatenated_segments,
         p_cost_allocation_keyflex_id=> p_batch_line.cost_allocation_keyflex_id,
         p_effective_date        => p_batch_line.effective_date,
         p_effective_start_date  => p_batch_line.effective_start_date,
         p_effective_end_date    => p_batch_line.effective_end_date,
         p_element_name          => p_batch_line.element_name,
         p_element_type_id       => p_batch_line.element_type_id,
         p_reason                => p_batch_line.reason,
         p_segment1              => p_batch_line.segment1,
         p_segment2              => p_batch_line.segment2,
         p_segment3              => p_batch_line.segment3,
         p_segment4              => p_batch_line.segment4,
         p_segment5              => p_batch_line.segment5,
         p_segment6              => p_batch_line.segment6,
         p_segment7              => p_batch_line.segment7,
         p_segment8              => p_batch_line.segment8,
         p_segment9              => p_batch_line.segment9,
         p_segment10             => p_batch_line.segment10,
         p_segment11             => p_batch_line.segment11,
         p_segment12             => p_batch_line.segment12,
         p_segment13             => p_batch_line.segment13,
         p_segment14             => p_batch_line.segment14,
         p_segment15             => p_batch_line.segment15,
         p_segment16             => p_batch_line.segment16,
         p_segment17             => p_batch_line.segment17,
         p_segment18             => p_batch_line.segment18,
         p_segment19             => p_batch_line.segment19,
         p_segment20             => p_batch_line.segment20,
         p_segment21             => p_batch_line.segment21,
         p_segment22             => p_batch_line.segment22,
         p_segment23             => p_batch_line.segment23,
         p_segment24             => p_batch_line.segment24,
         p_segment25             => p_batch_line.segment25,
         p_segment26             => p_batch_line.segment26,
         p_segment27             => p_batch_line.segment27,
         p_segment28             => p_batch_line.segment28,
         p_segment29             => p_batch_line.segment29,
         p_segment30             => p_batch_line.segment30,
         p_value_1               => p_batch_line.value_1,
         p_value_2               => p_batch_line.value_2,
         p_value_3               => p_batch_line.value_3,
         p_value_4               => p_batch_line.value_4,
         p_value_5               => p_batch_line.value_5,
         p_value_6               => p_batch_line.value_6,
         p_value_7               => p_batch_line.value_7,
         p_value_8               => p_batch_line.value_8,
         p_value_9               => p_batch_line.value_9,
         p_value_10              => p_batch_line.value_10,
         p_value_11              => p_batch_line.value_11,
         p_value_12              => p_batch_line.value_12,
         p_value_13              => p_batch_line.value_13,
         p_value_14              => p_batch_line.value_14,
         p_value_15              => p_batch_line.value_15,
         p_entry_information_category=> p_batch_line.entry_information_category,
         p_entry_information1    => p_batch_line.entry_information1,
         p_entry_information2    => p_batch_line.entry_information2,
         p_entry_information3    => p_batch_line.entry_information3,
         p_entry_information4    => p_batch_line.entry_information4,
         p_entry_information5    => p_batch_line.entry_information5,
         p_entry_information6    => p_batch_line.entry_information6,
         p_entry_information7    => p_batch_line.entry_information7,
         p_entry_information8    => p_batch_line.entry_information8,
         p_entry_information9    => p_batch_line.entry_information9,
         p_entry_information10   => p_batch_line.entry_information10,
         p_entry_information11   => p_batch_line.entry_information11,
         p_entry_information12   => p_batch_line.entry_information12,
         p_entry_information13   => p_batch_line.entry_information13,
         p_entry_information14   => p_batch_line.entry_information14,
         p_entry_information15   => p_batch_line.entry_information15,
         p_entry_information16   => p_batch_line.entry_information16,
         p_entry_information17   => p_batch_line.entry_information17,
         p_entry_information18   => p_batch_line.entry_information18,
         p_entry_information19   => p_batch_line.entry_information19,
         p_entry_information20   => p_batch_line.entry_information20,
         p_entry_information21   => p_batch_line.entry_information21,
         p_entry_information22   => p_batch_line.entry_information22,
         p_entry_information23   => p_batch_line.entry_information23,
         p_entry_information24   => p_batch_line.entry_information24,
         p_entry_information25   => p_batch_line.entry_information25,
         p_entry_information26   => p_batch_line.entry_information26,
         p_entry_information27   => p_batch_line.entry_information27,
         p_entry_information28   => p_batch_line.entry_information28,
         p_entry_information29   => p_batch_line.entry_information29,
         p_entry_information30   => p_batch_line.entry_information30,
         p_bl_id                 => p_bline_id,
         p_ovn                   => p_obj_vn
      );
      hr_utility.set_location (   'Leaving:'
                               || l_proc, 20);
   END create_batch_line;

   FUNCTION correct_type_id (p_id_type VARCHAR2)
      RETURN BOOLEAN
   IS
      l_correct   BOOLEAN := FALSE;
   BEGIN
      IF (   UPPER (p_id_type) NOT IN (c_type_person_id,
                                       c_type_assignment_id,
                                       c_type_employee_number,
                                       c_type_national_identifier
                                      )
          OR UPPER (p_id_type) IS NULL
         )
      THEN
         l_correct := FALSE;
      ELSE
         l_correct := TRUE;
      END IF;

      RETURN l_correct;
   END correct_type_id;

   PROCEDURE get_assignment_info (
      p_bus_group_id         IN       per_assignments_f.business_group_id%TYPE
            DEFAULT NULL,
      p_id_type              IN       VARCHAR2,
      p_id                   IN       VARCHAR2,
      p_effective_date       IN       DATE,
      p_assg_id              OUT NOCOPY   per_assignments_f.assignment_id%TYPE,
      p_assg_nr              OUT NOCOPY   per_assignments_f.assignment_number%TYPE,
      p_start_date           OUT NOCOPY   per_periods_of_service.date_start%TYPE,
      p_final_process_date   OUT NOCOPY   per_periods_of_service.final_process_date%TYPE
   )
   IS
      -- Procedure name
      l_proc   CONSTANT VARCHAR2 (72)    :=    g_package|| 'get_assignment_info';

      CURSOR csr_assg_id (
         v_assg_id          per_assignments_f.assignment_id%TYPE,
         v_effective_date   DATE
      )
      IS
         SELECT paa.assignment_number,
                pos.date_start,
                pos.final_process_date
           FROM per_assignments_f          paa,
                per_periods_of_service     pos
          WHERE paa.assignment_id         = v_assg_id
            AND paa.period_of_service_id  = pos.period_of_service_id
            AND v_effective_date BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date;



      CURSOR csr_person_id (
         v_person_id        per_assignments_f.person_id%TYPE,
         v_bg_id            per_assignments_f.business_group_id%TYPE,
         v_effective_date   DATE
      )
      IS
         SELECT paa.assignment_number,
                paa.assignment_id,
                pos.date_start,
                pos.final_process_date
           FROM per_assignments_f            paa,
                per_periods_of_service       pos
          WHERE paa.person_id            = v_person_id
            AND paa.period_of_service_id = pos.period_of_service_id
            AND v_effective_date BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date
            AND paa.business_group_id    = v_bg_id
            AND paa.primary_flag         = 'Y';

      CURSOR csr_empl_nr (
         v_empl_nr          per_people_f.employee_number%TYPE,
         v_bg_id            per_assignments_f.business_group_id%TYPE,
         v_effective_date   DATE
      )
      IS
         SELECT paa.assignment_number,
                paa.assignment_id,
                pos.date_start,
                pos.final_process_date
           FROM per_assignments_f paa,
                per_people_f      pap,
                per_periods_of_service pos
          WHERE pap.employee_number      = v_empl_nr
            AND pap.person_id            = paa.person_id
            AND paa.period_of_service_id = pos.period_of_service_id
            AND v_effective_date BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date
            AND v_effective_date BETWEEN pap.effective_start_date
                                     AND pap.effective_end_date
            AND paa.business_group_id    = v_bg_id
            AND paa.primary_flag         = 'Y';

      CURSOR csr_ni_nr (
         v_ni_nr            per_people_f.national_identifier%TYPE,
         v_bg_id            per_assignments_f.business_group_id%TYPE,
         v_effective_date   DATE
      )
      IS
         SELECT paa.assignment_number,
                paa.assignment_id,
                pos.date_start,
                pos.final_process_date
           FROM per_assignments_f paa,
                per_people_f pap,
                per_periods_of_service pos
          WHERE pap.national_identifier    = v_ni_nr
            AND pap.person_id              = paa.person_id
            AND paa.period_of_service_id   = pos.period_of_service_id
            AND v_effective_date BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date
            AND v_effective_date BETWEEN pap.effective_start_date
                                     AND pap.effective_end_date
            AND paa.business_group_id      = v_bg_id
            AND paa.primary_flag           = 'Y';

      l_assg_nr         per_assignments_f.assignment_number%TYPE     := NULL;
      l_assg_id         per_assignments_f.assignment_id%TYPE         := NULL;
      l_dt_start        per_periods_of_service.date_start%TYPE       := NULL;
      l_finproc_dt      per_periods_of_service.final_process_date%TYPE
                                                                      := NULL;
   BEGIN
      hr_utility.set_location (   'Entering:'
                               || l_proc, 10);
      hr_utility.set_location ( 'Effective Date used:
                               '|| p_effective_date, 20
      );

      IF (p_id_type = c_type_assignment_id)
      THEN
         OPEN csr_assg_id (p_id, p_effective_date);
         FETCH csr_assg_id INTO l_assg_nr, l_dt_start, l_finproc_dt;

         IF csr_assg_id%FOUND
         THEN
            p_assg_nr := l_assg_nr;
            p_assg_id := p_id;
            p_start_date := l_dt_start;
            p_final_process_date := l_finproc_dt;
         ELSE
            -- ERROR
            p_assg_nr := NULL;
            p_assg_id := NULL;
         END IF;

         CLOSE csr_assg_id;
      ELSIF (p_id_type = c_type_person_id)
      THEN
         OPEN csr_person_id (p_id, p_bus_group_id, p_effective_date);
         FETCH csr_person_id INTO l_assg_nr,
                                  l_assg_id,
                                  l_dt_start,
                                  l_finproc_dt;

         IF csr_person_id%FOUND
         THEN
            p_assg_nr := l_assg_nr;
            p_assg_id := l_assg_id;
            p_start_date := l_dt_start;
            p_final_process_date := l_finproc_dt;
         ELSE
            -- ERROR
            p_assg_nr := NULL;
            p_assg_id := NULL;
         END IF;

         CLOSE csr_person_id;
      ELSIF (p_id_type = c_type_national_identifier)
      THEN
         OPEN csr_ni_nr (p_id, p_bus_group_id, p_effective_date);
         FETCH csr_ni_nr INTO l_assg_nr, l_assg_id, l_dt_start, l_finproc_dt;

         IF csr_ni_nr%FOUND
         THEN
            p_assg_nr := l_assg_nr;
            p_assg_id := l_assg_id;
            p_start_date := l_dt_start;
            p_final_process_date := l_finproc_dt;
         ELSE
            -- ERROR
            p_assg_nr := NULL;
            p_assg_id := NULL;
         END IF;

         CLOSE csr_ni_nr;
      ELSIF (p_id_type = c_type_employee_number)
      THEN
         OPEN csr_empl_nr (p_id, p_bus_group_id, p_effective_date);
         FETCH csr_empl_nr INTO l_assg_nr, l_assg_id, l_dt_start, l_finproc_dt;

         IF csr_empl_nr%FOUND
         THEN
            p_assg_nr := l_assg_nr;
            p_assg_id := l_assg_id;
            p_start_date := l_dt_start;
            p_final_process_date := l_finproc_dt;
         ELSE
            -- ERROR
            p_assg_nr := NULL;
            p_assg_id := NULL;
         END IF;

         CLOSE csr_empl_nr;
      ELSE
         -- ERROR -> p_id_type not correct
         p_assg_nr := NULL;
         p_assg_id := NULL;
      END IF;

      hr_utility.set_location (   'Leaving:'
                               || l_proc, 100);
   END get_assignment_info;

   PROCEDURE get_element_info (
      p_leg_cd            IN       VARCHAR2,
      p_element_name      IN OUT NOCOPY  VARCHAR2,
      p_element_type_id   IN OUT NOCOPY  NUMBER
   )
   IS
      -- Procedure name
      l_proc     CONSTANT VARCHAR2 (72)                              :=    g_package
                                                                        || 'get_element_info';

      CURSOR csr_el (v_el_type_id NUMBER, v_el_name VARCHAR2, v_leg_cd VARCHAR2)
      IS
         SELECT pet.element_name,
                pet.element_type_id
           FROM pay_element_types_f pet
          WHERE pet.element_type_id       = v_el_type_id
            AND UPPER (pet.element_name)  = UPPER (v_el_name)
            AND pet.legislation_code      = v_leg_cd
            AND pet.business_group_id     IS NULL;

      -- Added for Bug# 2485470
      -- Start of  Bug# 2485470

      CURSOR csr_el_name (v_el_type_id NUMBER,v_leg_cd VARCHAR2)
      IS
         SELECT pet.element_name,
                pet.element_type_id
           FROM pay_element_types_f pet
          WHERE pet.element_type_id   = v_el_type_id
            AND pet.legislation_code  = v_leg_cd
            AND pet.business_group_id IS NULL;

      CURSOR csr_el_type_id (v_el_name VARCHAR2,v_leg_cd VARCHAR2)
      IS
         SELECT pet.element_name,
                pet.element_type_id
           FROM pay_element_types_f pet
          WHERE UPPER(pet.element_name) = UPPER(v_el_name)
            AND pet.legislation_code    = v_leg_cd
            AND pet.business_group_id   IS NULL;

      -- End of Bug# 2485470

      l_element_type_id   pay_element_types_f.element_type_id%TYPE;
      l_element_name      pay_element_types_f.element_name%TYPE;
   BEGIN
      hr_utility.set_location (   'Entering:'     || l_proc, 10);
      -- Added for Bug# 2485470
      -- Start of  Bug# 2485470

      IF (p_element_name IS NULL) AND (p_element_type_id IS NOT NULL) THEN
        OPEN  csr_el_name (p_element_type_id, p_leg_cd);
        FETCH csr_el_name INTO l_element_name, l_element_type_id;
         IF csr_el_name%FOUND THEN
	   p_element_type_id := l_element_type_id;
	   p_element_name    := l_element_name;
         ELSE
	 -- ERROR
	   p_element_type_id := NULL;
	   p_element_name    := NULL;
         END IF;
        CLOSE csr_el_name;
      ELSIF (p_element_name IS NOT NULL) AND (p_element_type_id IS NULL) THEN
        OPEN  csr_el_type_id (p_element_name, p_leg_cd);
        FETCH csr_el_type_id INTO l_element_name, l_element_type_id;
         IF csr_el_type_id%FOUND THEN
	   p_element_type_id := l_element_type_id;
	   p_element_name    := l_element_name;
         ELSE
	 -- ERROR
	   p_element_type_id := NULL;
	   p_element_name    := NULL;
         END IF;
        CLOSE csr_el_type_id;
      ELSIF (p_element_name IS NOT NULL) AND (p_element_type_id IS NOT NULL) THEN
        OPEN csr_el (p_element_type_id, p_element_name, p_leg_cd);
        FETCH csr_el INTO l_element_name, l_element_type_id;
         IF csr_el%FOUND THEN
	   p_element_type_id := l_element_type_id;
	   p_element_name    := l_element_name;
         ELSE
	 -- ERROR
	   p_element_type_id := NULL;
	   p_element_name    := NULL;
         END IF;
        CLOSE csr_el;
      ELSE
	 -- ERROR
	   p_element_type_id := NULL;
	   p_element_name    := NULL;
      END IF;

      -- End of Bug# 2485470
      hr_utility.set_location (   'Leaving:' || l_proc, 100);
   END get_element_info;


   /* procedure to upload health insurance info */


   PROCEDURE upload_hia (
      errbuf                     OUT NOCOPY  VARCHAR2,
      retcode                    OUT NOCOPY  NUMBER,
      p_file_name                IN       VARCHAR2,
      p_effective_date           IN       VARCHAR2,
      p_business_group_id        IN       per_business_groups.business_group_id%TYPE,
      p_delimiter                IN       VARCHAR2,
      p_action_if_exists         IN       VARCHAR2 DEFAULT NULL,
      p_date_effective_changes   IN       VARCHAR2 DEFAULT NULL,
      p_batch_name               IN       VARCHAR2 DEFAULT NULL
   ) is

  BEGIN

     g_process := 'HIA';

    /* set batch headers and other info */

     g_batch_header    := substr(hr_general.decode_lookup('KR_HIA_UPLOAD','REFERENCE'),1,30);
     g_batch_source    := substr(hr_general.decode_lookup('KR_HIA_UPLOAD','SOURCE'),1,30);
     g_batch_comments  := substr(hr_general.decode_lookup('KR_HIA_UPLOAD','COMMENT'),1,100);

    /* call actual procedure to upload */

    upload (
       errbuf                     =>errbuf
      ,retcode                    =>retcode
      ,p_file_name                =>p_file_name
      ,p_effective_date           =>p_effective_date
      ,p_business_group_id        =>p_business_group_id
      ,p_delimiter                =>p_delimiter
      ,p_action_if_exists         =>p_action_if_exists
      ,p_date_effective_changes   =>p_date_effective_changes
      ,p_batch_name               =>p_batch_name
   ) ;



  END;


   /* procedure to upload national pension info */


   PROCEDURE upload_npa (
      errbuf                     OUT NOCOPY  VARCHAR2,
      retcode                    OUT NOCOPY  NUMBER,
      p_file_name                IN       VARCHAR2,
      p_effective_date           IN       VARCHAR2,
      p_business_group_id        IN       per_business_groups.business_group_id%TYPE,
      p_delimiter                IN       VARCHAR2,
      p_action_if_exists         IN       VARCHAR2 DEFAULT NULL,
      p_date_effective_changes   IN       VARCHAR2 DEFAULT NULL,
      p_batch_name               IN       VARCHAR2 DEFAULT NULL
   ) is

  BEGIN

     g_process := 'NPA';

    /* set batch headers and other info */

     g_batch_header    := substr(hr_general.decode_lookup('KR_NPA_UPLOAD','REFERENCE'),1,30);
     g_batch_source    := substr(hr_general.decode_lookup('KR_NPA_UPLOAD','SOURCE'),1,30);
     g_batch_comments  := substr(hr_general.decode_lookup('KR_NPA_UPLOAD','COMMENT'),1,100);

    /* call actual procedure to upload */

    upload (
       errbuf                     =>errbuf
      ,retcode                    =>retcode
      ,p_file_name                =>p_file_name
      ,p_effective_date           =>p_effective_date
      ,p_business_group_id        =>p_business_group_id
      ,p_delimiter                =>p_delimiter
      ,p_action_if_exists         =>p_action_if_exists
      ,p_date_effective_changes   =>p_date_effective_changes
      ,p_batch_name               =>p_batch_name
   ) ;


  END;

END pay_kr_bee_upload;

/
