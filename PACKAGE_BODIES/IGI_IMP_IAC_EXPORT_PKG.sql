--------------------------------------------------------
--  DDL for Package Body IGI_IMP_IAC_EXPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IMP_IAC_EXPORT_PKG" AS
/* $Header: igiimepb.pls 120.7.12000000.1 2007/08/01 16:20:55 npandya ship $ */

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiimepb.igi_imp_iac_export_pkg.';

--===========================FND_LOG.END====================================

   FUNCTION trim_invalid_chars (p_validation_string varchar2) return varchar2 is
        l_string_length number;			-- Variable to hold the length of the string passed to be validated
        l_validated_string varchar2(2000);	-- Variable which holds the final string after trimming unwanted characters
        l_converted_string varchar2(2000);	-- Variable to hold the string converted to ASCII using the convert function
   begin
   	-- First obtain the length of the string to be validated

        l_string_length := NVL(length(p_validation_string), 0);

        -- Since the string passed to be validated can be in any language depending on the user environment parameter, first
        -- convert the string to ASCII and check for the invalid characters. After trimming off the invalids reconvert the string back
        -- to the users language

        l_converted_string := convert(p_validation_string, 'US7ASCII', substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'), '.') + 1));

        -- Validate each character in the string against alphabets and integers. If the character is not an alphabet/integer simply ignore it.
        -- The test to check whether the character entered is an alphabet/integer is done using the ASCII value of the character

        FOR cntr IN 1..l_string_length
        LOOP
            IF (ASCII(SUBSTR(l_converted_string, cntr, 1)) BETWEEN 48 AND 57)			-- Check for integers (0-9)
                OR (ASCII(SUBSTR(l_converted_string, cntr, 1)) BETWEEN 65 AND 90) 		-- Check for uppercase alphabets ('A'-'Z')
                OR (ASCII(SUBSTR(l_converted_string, cntr, 1)) BETWEEN 97 AND 122) THEN		-- Check for lowercase alphabets ('a'-'z')
               l_validated_string := l_validated_string||SUBSTR(l_converted_string, cntr, 1);
            END IF;
        END LOOP;

        -- If the validated string still holds the value of NULL, assign a default value as the return value. Such a case is rare and can occur only if
        -- the string to be validated is passed as a NULL or if it contains all invalids

        IF (l_validated_string IS NULL) THEN
             l_validated_string := 'DEFAULT';
        END IF;

        l_validated_string := convert(l_validated_string, substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'), '.') + 1), 'US7ASCII');

        return l_validated_string;
   EXCEPTION
        WHEN OTHERS THEN
           return convert('DEFAULT', substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'), '.') + 1), 'US7ASCII');
   END trim_invalid_chars;


   /* Main Process */
   PROCEDURE  Export_data_process(
   	errbuf OUT NOCOPY  varchar2 ,
   	retcode OUT NOCOPY  number,
	p_book IN IGI_IMP_IAC_INTERFACE.book_type_code%type,
	p_category_id IN IGI_IMP_IAC_INTERFACE.category_id%type,
	category_name IN varchar2) IS

   /* Cursor to get all the groups for a book and category_id */
   Cursor c_get_groups is
   	Select distinct group_id from igi_imp_iac_interface
   	where book_type_code = p_book and
   	      category_id = p_category_id;


   l_get_groups 		    c_get_groups%rowtype;
   l_filename                       varchar2(1000);
   l_fname_with_locn                varchar2(1000);
   l_request_id			    NUMBER;
   l_message			    varchar2(1000);
   l_gp_present_chk_flag	    varchar2(1);
--   l_bookname_sans_spaces           IGI_IMP_IAC_INTERFACE.book_type_code%type;	-- Bug 2843747 (Tpradhan) - Commented since no longer required
   l_file_loc                       varchar2(1000);

   IGI_IMP_IAC_GROUP_NOTFOUND       Exception;
   IGI_IAC_REQUEST_SUB_ERR 	    Exception;
   IGI_IAC_NOT_ENABLED		    Exception;
   l_path_name VARCHAR2(150) := g_path||'export_data_process';

   Begin
  	/* Check whether the IAC Option is enabled */
   	if NOT igi_gen.is_req_installed('IAC') then
   		raise IGI_IAC_NOT_ENABLED;
     	END IF;


  	/* Flag to check whther groups are present for the given Book and category */
	l_gp_present_chk_flag   := 'N';



	/* Remove all spaces in the book type code*/
--	l_bookname_sans_spaces:= remove_spaces(p_book);		-- Bug No. 2843747 (Tpradhan) - Commented since this check is now performed using trim_invalid_chars function

	l_file_loc:='';
	/* Get the  Directory  from the profile IGI_IMP_IAC_FILE_LOCN */
	fnd_profile.get('IGI_IMP_IAC_FILE_LOCN',l_file_loc);

	for l_get_groups in c_get_groups loop
		l_gp_present_chk_flag 	:='Y';

		-- Bug 2843747 (Tpradhan) - Included the trim_invalid_chars function for the book name and category name so that any spaces or additional characters
		--			    can be removed. These characters lead to a failure in spooling the file.

		l_filename 		:= trim_invalid_chars(p_book)||'_'||trim_invalid_chars(category_name)||'_'||to_char(l_get_groups.group_id)||'_'||'out.csv';
		l_fname_with_locn	:= l_file_loc||l_filename;

		/* call the concurrent process to run igiimpef.sql*/
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => ' Group_id is ' || l_get_groups.group_id
					    || ' File : ' || l_filename);


		     l_request_id := FND_REQUEST.SUBMIT_REQUEST(
		      APPLICATION		 => 'IGI',
		      PROGRAM			 => 'IGIIMPED',
		      DESCRIPTION		 => 'Inflation Accounting : Write data To Data file',
		      START_TIME		 => NULL,
      		      SUB_REQUEST		 => FALSE,
		      ARGUMENT1		 	 => p_book,
		      ARGUMENT2  	     	 => p_category_id,
		      ARGUMENT3  		 => l_get_groups.group_id,
		      ARGUMENT4                  => l_fname_with_locn,
		      ARGUMENT5     		 => CHR(0),
		      ARGUMENT6             	 => NULL,
		      ARGUMENT7  	         => NULL,
		      ARGUMENT8           	 => NULL,
		      ARGUMENT9		         => NULL,
		      ARGUMENT10   	         => NULL,
		      ARGUMENT11   	         => NULL,
		      ARGUMENT12   	         => NULL,
		      ARGUMENT13                 => NULL,
		      ARGUMENT14                 => NULL,
		      ARGUMENT15                 => NULL,
		      ARGUMENT16                 => NULL,
		      ARGUMENT17                 => NULL,
		      ARGUMENT18                 => NULL,
		      ARGUMENT19                 => NULL,
		      ARGUMENT20                 => NULL,
		      ARGUMENT21                 => NULL,
		      ARGUMENT22                 => NULL,
		      ARGUMENT23                 => NULL,
		      ARGUMENT24                 => NULL,
		      ARGUMENT25                 => NULL,
		      ARGUMENT26                 => NULL,
		      ARGUMENT27                 => NULL,
		      ARGUMENT28                 => NULL,
		      ARGUMENT29                 => NULL,
		      ARGUMENT30                 => NULL,
		      ARGUMENT31                 => NULL,
		      ARGUMENT32                 => NULL,
		      ARGUMENT33                 => NULL,
		      ARGUMENT34                 => NULL,
		      ARGUMENT35                 => NULL,
		      ARGUMENT36                 => NULL,
		      ARGUMENT37                 => NULL,
		      ARGUMENT38                 => NULL,
		      ARGUMENT39                 => NULL,
		      ARGUMENT40                 => NULL,
		      ARGUMENT41                 => NULL,
		      ARGUMENT42                 => NULL,
		      ARGUMENT43	         => NULL,
		      ARGUMENT44                 => NULL,
		      ARGUMENT45                 => NULL,
		      ARGUMENT46                 => NULL,
		      ARGUMENT47                 => NULL,
		      ARGUMENT48                 => NULL,
		      ARGUMENT49                 => NULL,
		      ARGUMENT50                 => NULL,
		      ARGUMENT51                 => NULL,
		      ARGUMENT52                 => NULL,
		      ARGUMENT53                 => NULL,
		      ARGUMENT54                 => NULL,
		      ARGUMENT55                 => NULL,
		      ARGUMENT56                 => NULL,
		      ARGUMENT57                 => NULL,
		      ARGUMENT58                 => NULL,
		      ARGUMENT59                 => NULL,
		      ARGUMENT60                 => NULL,
		      ARGUMENT61                 => NULL,
		      ARGUMENT62                 => NULL,
		      ARGUMENT63                 => NULL,
		      ARGUMENT64                 => NULL,
		      ARGUMENT65                 => NULL,
		      ARGUMENT66                 => NULL,
		      ARGUMENT67                 => NULL,
		      ARGUMENT68                 => NULL,
		      ARGUMENT69                 => NULL,
		      ARGUMENT70                 => NULL,
		      ARGUMENT71                 => NULL,
		      ARGUMENT72                 => NULL,
		      ARGUMENT73                 => NULL,
		      ARGUMENT74                 => NULL,
		      ARGUMENT75                 => NULL,
		      ARGUMENT76                 => NULL,
		      ARGUMENT77                 => NULL,
		      ARGUMENT78                 => NULL,
		      ARGUMENT79                 => NULL,
		      ARGUMENT80                 => NULL,
		      ARGUMENT81                 => NULL,
		      ARGUMENT82                 => NULL,
		      ARGUMENT83                 => NULL,
		      ARGUMENT84                 => NULL,
		      ARGUMENT85                 => NULL,
		      ARGUMENT86                 => NULL,
		      ARGUMENT87                 => NULL,
		      ARGUMENT88                 => NULL,
		      ARGUMENT89                 => NULL,
		      ARGUMENT90                 => NULL,
		      ARGUMENT91                 => NULL,
		      ARGUMENT92                 => NULL,
		      ARGUMENT93                 => NULL,
		      ARGUMENT94                 => NULL,
		      ARGUMENT95                 => NULL,
		      ARGUMENT96                 => NULL,
		      ARGUMENT97                 => NULL,
		      ARGUMENT98                 => NULL,
		      ARGUMENT99                 => NULL,
		      ARGUMENT100                => NULL
		    );

	    IF l_request_id = 0 THEN
	        raise IGI_IAC_REQUEST_SUB_ERR;
	    ELSE
		commit;
		/*  Bug No : 2497429 sowsubra   start storing the entire directory path for export file instead of just the file name */
		/* Update the igi_imp_iac_interface table with  the export details  */
		update igi_imp_iac_interface set export_file=l_fname_with_locn ,export_date=trunc(sysdate)
		where book_type_code = p_book and
     	              category_id = p_category_id  and
     	              group_id =l_get_groups.group_id;
               /* Bug No:2497429 sowsubra end */
               commit;
	    END IF;


	end loop;

	/* If No groups are present Raise exception */
	If l_gp_present_chk_flag = 'N'  Then
		Raise IGI_IMP_IAC_GROUP_NOTFOUND;
	End IF;


   EXCEPTION

    WHEN IGI_IAC_NOT_ENABLED Then
       fnd_message.set_name('IGI','IGI_GEN_PROD_NOT_INSTALLED');
       fnd_message.set_token('OPTION_NAME','IAC');
       igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		       p_full_path => l_path_name,
		       p_remove_from_stack => FALSE);
       Errbuf:=fnd_message.get;
       fnd_file.put_line(fnd_file.log, errbuf);
       retcode :=2;

    WHEN IGI_IMP_IAC_GROUP_NOTFOUND Then
        fnd_message.set_name('IGI','IGI_IMP_IAC_NO_GROUPS');
        igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		       p_full_path => l_path_name,
		       p_remove_from_stack => FALSE);
        Errbuf:=fnd_message.get;
        fnd_file.put_line(fnd_file.log, errbuf);
   	retcode:=2;

    WHEN IGI_IAC_REQUEST_SUB_ERR then
      fnd_message.retrieve(l_message);
      igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		       p_full_path => l_path_name,
		       p_remove_from_stack => FALSE);
      retcode:=2;
      errbuf:=l_message;
      fnd_file.put_line(fnd_file.log, errbuf);

   End Export_data_process;


END igi_imp_iac_export_pkg;

/
