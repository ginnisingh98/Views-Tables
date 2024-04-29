--------------------------------------------------------
--  DDL for Package Body PER_DK_POSTALCODE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DK_POSTALCODE_UPLOAD" AS
/* $Header: pedkpost.pkb 120.0 2005/05/31 07:42:27 appldev noship $ */


-- Global package name
   g_package                    CONSTANT VARCHAR2 (33) := 'per_dk_postalcode_upload';
   g_bg_id			per_business_groups.business_group_id%TYPE;
   l_view_application_id	FND_LOOKUP_TYPES.view_application_id%type;
   l_security_group_id		PER_BUSINESS_GROUPS.business_group_id%type;

     -- File Handling variables
      l_file_type           UTL_FILE.file_type;
      l_location            VARCHAR2 (4000);
      l_line_read           VARCHAR2 (4000) ;
      l_batch_seq           NUMBER                      :=0;

       -- Variables to Read from File
      l_lookup_code         fnd_lookup_values.lookup_code%type :=null;
      l_meaning		    fnd_lookup_values.meaning%type;
      l_description         fnd_lookup_values.description%type;

      l_file_name            VARCHAR2 (240);

       -- Exceptions
      e_fatal_error                  EXCEPTION;
      e_invalid_record		     EXCEPTION;

       -- Global constants
	  c_warning                    CONSTANT NUMBER        := 1;
	  c_error                      CONSTANT NUMBER        := 2;

      --Variable for localization_lookup_type
      l_lookup_type         CONSTANT VARCHAR2(50)       :='DK_POSTCODE_TOWN';
       -- Constants
      c_read_file           CONSTANT VARCHAR2 (1)       := 'r';
      c_max_linesize        CONSTANT NUMBER             := 400;
      c_commit_point        CONSTANT NUMBER             := 10;
      c_data_exchange_dir   CONSTANT VARCHAR2 (30)      := 'PER_DATA_EXCHANGE_DIR';

      -- Procedure to upload postal code lookup

     PROCEDURE upload(
           errbuf           OUT NOCOPY   VARCHAR2,
           retcode          OUT NOCOPY   NUMBER,
           p_file_name      IN           VARCHAR2,
	   p_business_group_id        IN       per_business_groups.business_group_id%TYPE)

            is

	    l_proc                CONSTANT VARCHAR2 (72) :=  g_package||'.upload' ;
	    l_file_extension      VARCHAR2(4);


     BEGIN
        g_bg_id := p_business_group_id;
	l_file_name := p_file_name;
	fnd_profile.get (c_data_exchange_dir, l_location);
        IF l_location IS NULL
		THEN
		-- error : I/O directory not defined
		RAISE e_fatal_error;
		END IF;
        hr_utility.set_location(l_location,4);
	l_file_extension := substr(l_file_name,-4);
	IF l_file_extension <> '.txt' THEN
		RAISE UTL_FILE.invalid_filehandle;
	END IF;
	hr_utility.set_location('file type ok',4);
        -- Open flat file
        l_file_type := UTL_FILE.fopen (l_location, l_file_name, c_read_file, c_max_linesize);
       LOOP
            BEGIN

            UTL_FILE.get_line (l_file_type, l_line_read);
      	    hr_utility.set_location (   '  line  ' || l_line_read, 10);
	    l_batch_seq :=   l_batch_seq + 1;
            read_record(l_line_read);

                    IF MOD (l_batch_seq, c_commit_point) = 0 THEN
	                    COMMIT;
                    END IF;
	   exception
                    WHEN NO_DATA_FOUND THEN
	                    EXIT;

		    WHEN e_invalid_record THEN
		       -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_warning;

		       -- Set the application error

   		       hr_utility.set_message (800, 'HR_377018_DK_INVALID_RECORD');
		       hr_utility.set_message_token (800, 'LINE_NO', l_batch_seq);
		       hr_utility.set_message_token (800, 'LINE', l_line_read);

		       -- Write the message to log file, do not raise an application error but continue
		       -- (with next line)

		       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

            END;

        END LOOP ;
 -- Commit the outstanding records
                    COMMIT;

 EXCEPTION
      WHEN e_fatal_error
      -- No directory specified
      THEN
         -- Close the file in case of error
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

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
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (l_proc, 220);
         retcode := c_error;
         errbuf := 'Reading File ('||l_location ||' -> '
                                   || l_file_name
                                   || ') - Invalid Operation.';
      WHEN UTL_FILE.internal_error
      -- Unspecified internal error
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (l_proc, 230);
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_file_name
                   || ') - Internal Error.';

      WHEN UTL_FILE.invalid_mode
      -- Invalid string specified for file mode
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (l_proc, 240);
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_file_name
                   || ') - Invalid Mode.';

      WHEN UTL_FILE.invalid_path
      -- Directory or filename is invalid or not accessible
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_file_name
                   || ') - Invalid Path or Filename.';
         hr_utility.set_location (l_proc, 250);

      WHEN UTL_FILE.invalid_filehandle
      -- File type does not specify an open file
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (l_proc, 260);
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_file_name
                   || ') - Invalid File Type.';
      WHEN UTL_FILE.read_error

      -- Operating system error occurred during a read operation
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (l_proc, 270);
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_file_name
                   || ') - Read Error.';


      end upload;

 -- Procedure to read lines from file and insert to /update the lookup.

 PROCEDURE read_record
          ( p_line		IN VARCHAR2)
  is
    update_flag VARCHAR2(2);
    l_line      VARCHAR2(4000);


 begin

	l_view_application_id := 3;
	update_flag :='N';
	l_line := rtrim(p_line);

	hr_utility.set_location (   ' bg id '||g_bg_id, 20);
	begin
	   select SECURITY_GROUP_ID into l_security_group_id from per_business_groups where business_group_id = g_bg_id;
	exception
	when others then
	  l_security_group_id := 0;
	end;


	hr_utility.set_location (   ' l_line '||l_line , 20);
	if l_line is NULL then
		null;

	else
	        l_lookup_code:= get_field (p_line => l_line, p_delimiter => '~');
		hr_utility.set_location ('lookup_code:' || l_lookup_code, 110);

		if l_lookup_code is NULL OR l_line is NULL OR to_number(l_lookup_code) < 1 OR to_number(l_lookup_code) >9999 then
		      raise e_invalid_record;
	 	else


		        l_meaning:=l_lookup_code ||' ' || get_field (p_line => l_line, p_delimiter => '~');
			l_description:=NULL;
		        hr_utility.set_location (   ' code '||l_lookup_code , 20);
			hr_utility.set_location (   ' meaning '||l_meaning , 30);
	 		hr_utility.set_location (   ' desc '||l_description , 40);


		        begin
			    select 'Y' INTO update_flag
		            from fnd_lookup_values
			    where lookup_type=l_lookup_type
			    and lookup_code=l_lookup_code and
			    security_group_id = l_security_group_id and
			    view_application_id = l_view_application_id and
				language = userenv('LANG');

			Exception
		            when NO_DATA_FOUND   then
				    null;
			end;

		            IF  update_flag='Y' then
				update_row(l_lookup_code,l_meaning,l_description);
			    else
				insert_row(l_lookup_code,l_meaning,l_description);
			    END IF;


		end if;
	end if;
	exception
	when others then
		raise e_invalid_record;

 end read_record;

 -- Procedure to insert a row into fnd_lookup_values table

PROCEDURE insert_row
         ( p_lookup_code	IN fnd_lookup_values.lookup_code%type,
	   p_meaning		IN fnd_lookup_values.meaning%type,
	   p_description	IN fnd_lookup_values.description%type)

IS

l_lookup_type            CONSTANT VARCHAR2(50):='DK_POSTCODE_TOWN';
l_rowid				  VARCHAR2(30);

begin


    FND_LOOKUP_VALUES_PKG.INSERT_ROW(
    X_ROWID => l_rowid,
    X_LOOKUP_TYPE => l_lookup_type,
    X_SECURITY_GROUP_ID => l_security_group_id,
    X_VIEW_APPLICATION_ID => 3,
    X_LOOKUP_CODE => p_lookup_code,
    X_TAG => NULL,
    X_ATTRIBUTE_CATEGORY => null,
    X_ATTRIBUTE1 => null,
    X_ATTRIBUTE2 => null,
    X_ATTRIBUTE3 => null,
    X_ATTRIBUTE4 => null,
    X_ENABLED_FLAG => 'Y',
    X_START_DATE_ACTIVE => null,
    X_END_DATE_ACTIVE => null,
    X_TERRITORY_CODE => 'DK',
    X_ATTRIBUTE5 => null,
    X_ATTRIBUTE6 => null,
    X_ATTRIBUTE7 => null,
    X_ATTRIBUTE8 => null,
    X_ATTRIBUTE9 => null,
    X_ATTRIBUTE10 => null,
    X_ATTRIBUTE11 => null,
    X_ATTRIBUTE12 => null,
    X_ATTRIBUTE13 => null,
    X_ATTRIBUTE14 => null,
    X_ATTRIBUTE15 => null,
    X_MEANING => p_meaning,
    X_DESCRIPTION => p_description,
    X_CREATION_DATE => SYSDATE,
    X_CREATED_BY => TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
    X_LAST_UPDATE_DATE => SYSDATE,
    X_LAST_UPDATED_BY => TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
    X_LAST_UPDATE_LOGIN => TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')));

    hr_utility.set_location (   ' insert row ', 30);

end insert_row;

-- Procedure to update a row in fnd_lookup_values table

PROCEDURE update_row
	  ( p_lookup_code	IN fnd_lookup_values.lookup_code%type,
	   p_meaning		IN fnd_lookup_values.meaning%type,
	   p_description	IN fnd_lookup_values.description%type)

IS

l_lookup_type            CONSTANT VARCHAR2(50):='DK_POSTCODE_TOWN';

begin

    FND_LOOKUP_VALUES_PKG.UPDATE_ROW(
    X_LOOKUP_TYPE =>  l_lookup_type,
    X_SECURITY_GROUP_ID => l_security_group_id,
    X_VIEW_APPLICATION_ID => 3,
    X_LOOKUP_CODE => l_lookup_code,
    X_TAG => NULL,
    X_ATTRIBUTE_CATEGORY => NULL,
    X_ATTRIBUTE1 => NULL,
    X_ATTRIBUTE2 => NULL,
    X_ATTRIBUTE3 => NULL,
    X_ATTRIBUTE4 => NULL,
    X_ENABLED_FLAG => 'Y',
    X_START_DATE_ACTIVE => null,
    X_END_DATE_ACTIVE => NULL,
    X_TERRITORY_CODE => 'DK',
    X_ATTRIBUTE5 => NULL,
    X_ATTRIBUTE6 => NULL,
    X_ATTRIBUTE7 => NULL,
    X_ATTRIBUTE8 => NULL,
    X_ATTRIBUTE9 => NULL,
    X_ATTRIBUTE10 => NULL,
    X_ATTRIBUTE11 => NULL,
    X_ATTRIBUTE12 => NULL,
    X_ATTRIBUTE13 => NULL,
    X_ATTRIBUTE14 => NULL,
    X_ATTRIBUTE15 => NULL,
    X_MEANING => p_meaning,
    X_DESCRIPTION => p_description,
    X_LAST_UPDATE_DATE => SYSDATE,
    X_LAST_UPDATED_BY => TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
    X_LAST_UPDATE_LOGIN => TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')));

        hr_utility.set_location (   ' update row ', 30);
end update_row;

--Function to fetch a field from the line.
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



 end PER_DK_POSTALCODE_UPLOAD;

/
