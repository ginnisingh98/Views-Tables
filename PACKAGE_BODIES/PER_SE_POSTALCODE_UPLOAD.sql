--------------------------------------------------------
--  DDL for Package Body PER_SE_POSTALCODE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SE_POSTALCODE_UPLOAD" AS
/* $Header: pesepost.pkb 120.0.12010000.2 2008/12/30 10:55:13 rsengupt ship $ */


-- Global package name
        g_package                    CONSTANT VARCHAR2 (33) := 'POST_SE_UPLOAD';
        g_proc                       CONSTANT VARCHAR2 (33) :='error';
        g_bg_id           per_business_groups.business_group_id%TYPE;
        g_view_application_id	FND_LOOKUP_TYPES.view_application_id%type;
        g_security_group_id		PER_BUSINESS_GROUPS.business_group_id%type;
        --l_original_desc              fnd_lookup_values.description%type;

     -- File Handling variables
        l_file_type           UTL_FILE.file_type;
        l_location            VARCHAR2 (4000);
        l_line_read           VARCHAR2 (4000) ;
        l_batch_seq           NUMBER                      :=0;

       -- Variables to Read from File
        g_meaning		    VARCHAR2(80);

       -- Exceptions
      e_fatal_error                  EXCEPTION;
      e_invalid_record		         EXCEPTION;
      e_empty_line                   EXCEPTION;

       -- Global constants
	  c_warning                    CONSTANT NUMBER        := 1;
	  c_error                      CONSTANT NUMBER        := 2;


      --Variable for localization_lookup_type

      g_lookup_type         CONSTANT VARCHAR2(50)       :='SE_POSTAL_CODE';

       -- Constants
      c_read_file           CONSTANT VARCHAR2 (1)       := 'r';
      c_max_linesize        CONSTANT NUMBER             := 400;
      c_commit_point        CONSTANT NUMBER             := 10;
      c_data_exchange_dir   CONSTANT VARCHAR2 (30)      := 'PER_DATA_EXCHANGE_DIR';



/*
	PROCEDURE NAME	: READ_FILE
	PARAMATERS	: p_filename	-- Name of the file to be read.

	PURPOSE		: To Open the file Specified from the particular Dir
			  Pass it to READ_RECORD Procedure

	ERRORS HANDLED	: Raise ERROR if No directory specified
			  Raise Error for all invalid file level operations
			  Like
				invalid operation
				internal error
				invalid mode
				invalid path
				invalid filehandle
				read error
*/

 PROCEDURE READ_FILE(
          		 errbuf           OUT NOCOPY	VARCHAR2
          		,retcode          OUT NOCOPY	NUMBER
          		,p_filename       IN		VARCHAR2
          		,p_business_group_id   IN  per_business_groups.business_group_id%TYPE
          		)
            is
   l_filename            VARCHAR2 (240);

     BEGIN
        g_bg_id := p_business_group_id;
     	/* Get the filename from parameter to local variable */
     	l_filename := p_filename;
     	if substr(l_filename,length(l_filename)-3) <>'.txt'
     	then RAISE UTL_FILE.invalid_filehandle;
     	END IF;

        /* Get the DIR set in the profile to local variable */
        fnd_profile.get (c_data_exchange_dir, l_location);

        IF l_location IS NULL
		THEN
		-- error : I/O directory not defined
		RAISE e_fatal_error;
		END IF;
        hr_utility.set_location(l_location,4);
        -- Open flat file
        l_file_type := UTL_FILE.fopen (l_location, l_filename, c_read_file, c_max_linesize);

       LOOP
            BEGIN

            	UTL_FILE.get_line (l_file_type, l_line_read);
      	    	hr_utility.set_location (   '  line  ' || l_line_read, 10);
      	    	l_batch_seq :=   l_batch_seq + 1;
            	READ_RECORD(l_line_read);

                IF MOD (l_batch_seq, c_commit_point) = 0
                THEN
                	COMMIT;
                END IF;
	   EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                    EXIT;

                    WHEN e_invalid_record THEN
		       -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_warning;

		       -- Set the application error

   		       hr_utility.set_message (800, 'HR_377221_SE_INVALID_RECORD');
		       hr_utility.set_message_token (800, 'LINE_NO', l_batch_seq);
		       hr_utility.set_message_token (800, 'LINE', l_line_read);

		       -- Write the message to log file, do not raise an application error but continue
		       -- (with next line)

		       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);


		       WHEN e_empty_line THEN
		       -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_warning;

		       -- Set the application error

   		       hr_utility.set_message (800, 'HR_377222_SE_EMPTY_LINE');
		       hr_utility.set_message_token (800, 'LINE_NO', l_batch_seq);


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

         hr_utility.set_location (g_proc, 270);

         -- Set retcode to 2, indicating an ERROR to the ConcMgr
         retcode := c_error;

         -- Set the application error
         hr_utility.set_message (800, 'HR_78040_DATA_EXCHANGE_DIR_MIS');

         -- Return the message to the ConcMgr (This msg will appear in the log file)
         errbuf := hr_utility.get_message;

      WHEN UTL_FILE.invalid_operation
	      -- File could not be opened as requested, because of operating system permissions
	      -- Also raised when attempting a write operation on a file opened for read.

      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (g_proc, 280);
         retcode := c_error;
         errbuf := 'Reading File ('||l_location ||' -> ' || l_filename  || ') - Invalid Operation.';
      WHEN UTL_FILE.internal_error
      -- Unspecified internal error
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (g_proc, 290);
         retcode := c_error;
         errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Internal Error.';

      WHEN UTL_FILE.invalid_mode
      -- Invalid string specified for file mode
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (g_proc, 300);
         retcode := c_error;
         errbuf :=    'Reading File ('  || l_location  || ' -> ' || l_filename || ') - Invalid Mode.';

      WHEN UTL_FILE.invalid_path
      -- Directory or filename is invalid or not accessible
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         retcode := c_error;
         errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Invalid Path or Filename.';
         hr_utility.set_location (g_proc, 310);

      WHEN UTL_FILE.invalid_filehandle
      -- File type does not specify an open file
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (g_proc, 320);
         retcode := c_error;
         errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Invalid File Type.';
      WHEN UTL_FILE.read_error

      -- Operating system error occurred during a read operation
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         hr_utility.set_location (g_proc, 330);
         retcode := c_error;
         errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Read Error.';


 end READ_FILE;


/*
	PROCEDURE NAME	: READ_RECORD
	PARAMATERS	: p_line	-- a line read from file.

	PURPOSE		: To Update or Create the Lookup_code
	ERRORS HANDLED	: Raise warning for EMPTY LINE
			  Raise an Error for the Empty Lookup Code
*/

 PROCEDURE READ_RECORD
          ( p_line  IN varchar2
          )
  is
    l_update_flag 	varchar2(50);
    l_original_meaning 	fnd_lookup_values.meaning%type;
    l_Description 	fnd_lookup_values.description%type;
    l_code		fnd_lookup_values.lookup_code%type;


 BEGIN
        l_update_flag:='N';
        g_view_application_id := 3;
	begin
	   select SECURITY_GROUP_ID into g_security_group_id from per_business_groups where business_group_id = g_bg_id;
      	exception
	when others then
	  g_security_group_id := 0;
	   end;
        IF p_line is NULL
        THEN
        		/* If the line is empty Raise an Warning saying the line is empty */
            RAISE e_empty_line;
        ELSE
            		/* get the Lookup_code 12 from the line */
          --l_code:= substr(p_line,95,5);               -- Changes for Postal Code Format Chance 2008/2009
            l_code:= substr(p_line,1,5);
            if l_code is null or is_number(l_code)=false
          --or is_number(substr(p_line,95,6))=true      -- Changes for Postal Code Format Chance 2008/2009
            or is_number(substr(p_line,1,6))=true
            then
            RAISE e_invalid_record;
            else

          --g_meaning:=rtrim(substr(p_line,100,20));   -- Changes for Postal Code Format Chance 2008/2009
            g_meaning:=rtrim(substr(p_line,6,15));

	    --fnd_file.put_line(fnd_file.log,'g_meaning:'||g_meaning);

	    /* if Trace switched ON this wud give us the value read */
            hr_utility.set_location (   ' code '||l_code , 20);
 	    hr_utility.set_location (   ' desc '||l_description , 30);
 	    end if;

	END IF;

        BEGIN
	        	/* Get 'Y' if the lookupcode already available */
	        	/* get the description also to checkup whether the Description has been changed */
	        	/* if so update the description only */

            SELECT	'Y',flv.meaning
            INTO 	l_update_flag,l_original_meaning
            FROM 	fnd_lookup_values flv
            WHERE	flv.lookup_type=g_lookup_type
            AND 	flv.lookup_code=l_code and
            security_group_id = g_security_group_id and
	    language=userenv('LANG') and
			view_application_id = g_view_application_id;
	EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
            null;
        END;
        --end;
            IF  l_update_flag='Y'
            THEN
                IF l_original_meaning <>l_code||' '||g_meaning
                THEN
                       UPDATE_ROW(l_code,g_meaning,l_Description);

                END IF;
            ELSE
            	INSERT_ROW(l_code,g_meaning,l_Description);

            END IF;

 end READ_RECORD;

 PROCEDURE INSERT_ROW(
 			 p_lookup_code 	in fnd_lookup_values.lookup_code%TYPE
 			,p_meaning 	in fnd_lookup_values.meaning%TYPE
			,p_description	IN fnd_lookup_values.description%type
			)
	is

--G_LOOKUP_TYPE CONSTANT VARCHAR2(50)             :='SE_POSTAL_CODE';

	l_rowid 		VARCHAR2(30);

	begin


	    FND_LOOKUP_VALUES_PKG.INSERT_ROW(
	    X_ROWID => l_rowid,
	    X_LOOKUP_TYPE => g_lookup_type,
	    X_SECURITY_GROUP_ID => g_security_group_id,
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
	    X_TERRITORY_CODE => 'SE',
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
	    X_MEANING => p_lookup_code||' '||p_meaning,
	    X_DESCRIPTION => p_description,
	    X_CREATION_DATE => SYSDATE,
	    X_CREATED_BY => TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
	    X_LAST_UPDATE_DATE => SYSDATE,
	    X_LAST_UPDATED_BY => TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
	    X_LAST_UPDATE_LOGIN => TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'))

	   );

end INSERT_ROW;



PROCEDURE UPDATE_ROW(p_lookup_code in fnd_lookup_values.lookup_code%TYPE,
			p_meaning in fnd_lookup_values.meaning%TYPE,
			p_description	IN fnd_lookup_values.description%type)
is
--G_LOOKUP_TYPE CONSTANT VARCHAR2(50)             :='SE_POSTAL_CODE';

begin

    FND_LOOKUP_VALUES_PKG.UPDATE_ROW(
    X_LOOKUP_TYPE => g_lookup_type,
    X_SECURITY_GROUP_ID => g_security_group_id,
    X_VIEW_APPLICATION_ID => 3,
    X_LOOKUP_CODE => p_lookup_code,
    X_TAG => NULL,
    X_ATTRIBUTE_CATEGORY => NULL,
    X_ATTRIBUTE1 => NULL,
    X_ATTRIBUTE2 => NULL,
    X_ATTRIBUTE3 => NULL,
    X_ATTRIBUTE4 => NULL,
    X_ENABLED_FLAG => 'Y',
    X_START_DATE_ACTIVE => null,
    X_END_DATE_ACTIVE => NULL,
    X_TERRITORY_CODE => 'SE',
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
    X_MEANING => p_lookup_code||' '||p_meaning,
    X_DESCRIPTION => null,
    X_LAST_UPDATE_DATE => SYSDATE,
    X_LAST_UPDATED_BY => TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
    X_LAST_UPDATE_LOGIN => TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')));

end UPDATE_ROW;

/*
Function is_number
This function checks whether the postal_code read from the file is
numeric or not
If the postal code is not numeric, the record is skipped and the a
warning is thrown by the concurrent manager
*/


FUNCTION is_number ( p_value IN varchar2 )  return boolean is
    l_number number(20);
    begin
     l_number := to_number(p_value);
     return true;
     exception
     when others then
          return false;
    end is_number;


end PER_SE_POSTALCODE_UPLOAD ;

/
