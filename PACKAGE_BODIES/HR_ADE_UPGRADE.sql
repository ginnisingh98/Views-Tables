--------------------------------------------------------
--  DDL for Package Body HR_ADE_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ADE_UPGRADE" AS
/* $Header: peadeupg.pkb 120.0 2005/05/31 04:58:47 appldev noship $ */
--
------------------------ get_to_seperator -------------------------------------
-- helper function for parse_ini_file procedure
-- returns left most characters of supplied string upto first
-- occurance of passed character
--
--  Input Parameters
--        p_instr  - string from which substring to be selected
--        p_inchar - character at which selection is to stop
--
--  Output Parameters
--        <none>
--
--  Return Value
--        substring of input
-------------------------------------------------------------------------------
FUNCTION get_to_seperator(p_instr VARCHAR2, p_inchar CHAR) RETURN VARCHAR2 IS

  l_substr       VARCHAR2(200)  DEFAULT NULL;
  l_pos          NUMBER(3)      ;
BEGIN

  l_pos := INSTR(p_instr,p_inchar);
         -- get position of 1st 'inchar' in input line

  l_substr := substr(p_instr,1,l_pos-1);
   -- substring of inline from 1st char upto but not inc. first 'inchar'
   RETURN l_substr;

END get_to_seperator;

--------------------- crop_to_seperator -----------------------------
 -- helper function for parse_ini_file procedure
 -- discards leading characters upto first occurance of supplied character
 --
 --  Input Parameters
 --        p_instr  - string from which substring to be selected
 --        p_inchar - character at which selection is to start
 --  Output Parameters
 --        <none>
 --
 --  Return Value
 --        substring of input
--------------------------------------------------------------

FUNCTION crop_to_seperator(p_instr VARCHAR2, p_inchar CHAR) RETURN VARCHAR2 IS

  l_substr     VARCHAR2(2000);
  l_pos         NUMBER(3);
BEGIN

  l_pos := INSTR(p_instr,p_inchar);
         -- get position of 1st 'inchar' in input line

  l_substr := substr(p_instr,l_pos+1);
   -- substring of inline from 1st first 'inchar' to end of string
   RETURN l_substr;

END crop_to_seperator;
--
---------------------------- parse_ini_file -----------------------------
-- This process reads style setting from the ADE.ini file
-- creates output file with metadata suitable for upload to Web ADI
-- Will be run as a concurrent process
--
--  Input Parameters
--        p_file  - name of input file, normally ADE.INI
--
--  Output Parameters
--        errbuff - variable used by concurrent process manager
--        retcode - variable used by concurrent process manager
--------------------------------------------------------------------------
PROCEDURE parse_ini_file(errbuff     OUT NOCOPY VARCHAR2
                        ,retcode     OUT NOCOPY NUMBER
                        ,p_file   IN     VARCHAR2) IS

    l_dir            VARCHAR2(240);
    l_infile               UTL_FILE.FILE_TYPE ;
    l_out_file             UTL_FILE.FILE_TYPE ;
    --
    l_inline          VARCHAR2(32767)      ;
    --
    l_package         VARCHAR2(500) DEFAULT NULL;
    l_procedure       VARCHAR2(500) DEFAULT NULL;
    l_interface_param VARCHAR2(500) DEFAULT NULL;
    --
    l_groupname       VARCHAR2(500) DEFAULT NULL;
    l_setting1        VARCHAR2(500) DEFAULT NULL;
    l_setting2        VARCHAR2(500) DEFAULT NULL;
    l_setting3        VARCHAR2(500) DEFAULT NULL;
    l_setting4        VARCHAR2(500) DEFAULT NULL;
    l_setting5        VARCHAR2(500) DEFAULT NULL;
    l_setting6        VARCHAR2(500) DEFAULT NULL;
    l_setting7        VARCHAR2(500) DEFAULT NULL;
    l_all_settings    VARCHAR2(2000)            ;

    l_int_igr_name    VARCHAR2(500)  ;
    l_date            DATE          ;
    l_datestamp       VARCHAR2(12)  ;

    l_out_file_name  varchar2(50);
   BEGIN
    --set Concurrent process variables (used to indicate if warnings encounters)
    retcode := 0; --can be 0 (success),1(warnings) or 2(failure)
    errbuff := 'Output Files Created';
    --
    --get directory from system profile value
    fnd_profile.get('PER_DATA_EXCHANGE_DIR', l_dir);
    -- open input file for reading
    l_infile := UTL_FILE.FOPEN(l_dir,p_file,'r');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing '||l_dir||'/'||p_file);
    select sysdate into l_date from dual;
    l_datestamp := to_char(l_date,'DDMMYYHH24MISS');
    --
    --create output file names
    l_out_file_name  := 'UPG'   ||l_datestamp||'.csv';
    --
    -- open/create file for writing
    l_out_file    :=    UTL_FILE.FOPEN(l_dir,l_out_file_name,'w');
    --
    BEGIN -- annonymous block to trap NO_DATA_FOUND at end of file
      LOOP
         EXIT WHEN 1=2;-- continue reading until NO_DATA_FOUND error
                       --    raised when end-of-file reached
         --
         --read 1 line from infile into inline
         UTL_FILE.get_line(l_infile,l_inline);
         --
         IF substr(l_inline,1,1) = '[' THEN
            l_groupname := l_inline; -- store group name
            l_groupname := REPLACE(l_groupname,'[','');
            l_groupname := REPLACE(l_groupname,']',''); --without square brackets
            FND_FILE.PUT_LINE(FND_FILE.LOG, '   Processing Group '||l_groupname);
         END IF; --end if line is group name
         --
         IF UPPER(substr(l_inline,1,5)) = 'STYLE' THEN
            --parse for values
            --settingN is the Nth comma seperated value in .ini file list
            FND_FILE.PUT(FND_FILE.LOG, '      Processing Style ');
            --get upto first '=' and discard processed part of string
            l_setting1 := HR_ADE_UPGRADE.get_to_seperator(l_inline,'=');
            l_inline := HR_ADE_UPGRADE.crop_to_seperator(l_inline, '=');
               -- get style name and discard processed part of string
            l_setting2 := HR_ADE_UPGRADE.get_to_seperator(l_inline,',');
            FND_FILE.PUT(FND_FILE.LOG, l_setting2);
            FND_FILE.NEW_LINE(FND_FILE.LOG);
            l_inline := HR_ADE_UPGRADE.crop_to_seperator(l_inline, ',');
               -- get document name and discard processed part of string
            l_setting3 := HR_ADE_UPGRADE.get_to_seperator(l_inline,',');
            l_inline := HR_ADE_UPGRADE.crop_to_seperator(l_inline, ',');
               -- get view name and discard processed part of string
            l_setting4 := HR_ADE_UPGRADE.get_to_seperator(l_inline,',');
            l_inline := HR_ADE_UPGRADE.crop_to_seperator(l_inline, ',');
               -- get single/multiple and discard processed part of string
            l_setting5 := HR_ADE_UPGRADE.get_to_seperator(l_inline,',');
            l_inline := HR_ADE_UPGRADE.crop_to_seperator(l_inline, ',');
               -- get api name and discard processed part of string
            l_setting6 := HR_ADE_UPGRADE.get_to_seperator(l_inline,',');
            l_inline := HR_ADE_UPGRADE.crop_to_seperator(l_inline, ',');
               -- get letter name and discard processed part of string
            l_setting7 := HR_ADE_UPGRADE.get_to_seperator(l_inline,',');
            l_inline := HR_ADE_UPGRADE.crop_to_seperator(l_inline, ',');
            --
            -- validate view name, replace with group name if no specified
            IF l_setting4 = '' OR l_setting4 IS NULL THEN
               l_setting4 := '<<VIEWNAME>>';
               FND_FILE.PUT_LINE(FND_FILE.LOG,
                  '        WARNING: Please add view name to this style.');
               retcode := 1; -- mark Concurrent process with warning
            END IF;
            --
            --get package and procedure name from API name
            IF l_setting6 IS NOT NULL THEN
               l_package  := get_to_seperator(l_setting6,'.');
               l_procedure := crop_to_seperator(l_setting6,'.');
            ELSE
               --no api specified, so blank previous package and procedure
               l_package :=null;
               l_procedure := null;
            END IF;
            --create internal integrator name from user integrator name
            l_int_igr_name := SUBSTR((UPPER(REPLACE(l_setting2,' ','_'))),1,20);
            --
            --create interface parameter list name
            l_interface_param := l_setting2||' Parameters';
            --concatenate all processed strings to be transfered to CSV file
            --   with placeholder values for data to be entered by user
            l_all_settings := '<<APPLICATION_ID>>'||','||
                              l_setting2       ||','||
                              l_setting4       ||','||
                              l_groupname      ||','||
                              l_package        ||','||
                              l_procedure      ||','||
                              l_setting2       ||','||
                              l_interface_param||','||
                              'PROCEDURE';
            --write modified line to appropriate csv file, appending new line char/s
            IF l_package IS NOT NULL THEN
               --has an API specified so is update style
               utl_file.put_line(l_out_file,'UPDATE,'||l_all_settings);
            ELSE
            --No API specified so is download type
               utl_file.put_line(l_out_file,'DOWNLOAD,'||l_all_settings);
            END IF;
            -- There cannot be create style as these were not supported in ADE

         END IF;--end of if line is style specifier
      END LOOP;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN -- reached end of file
      --will drop out of anonymous block and contine main procedure execution.
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processed '|| p_file);
    END;--end of anonymous block for loop
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Closing files');
    UTL_FILE.FCLOSE(l_infile); -- close file opened for reading

    UTL_FILE.FFLUSH(l_out_file); --force physical write of data

    UTL_FILE.FCLOSE(l_out_file); -- close file opened for writing

    IF retcode <>0 --warnings encountered
    THEN
       errbuff := errbuff || ' - Some View Names must be added manually';
    ELSE
       errbuff := errbuff || ' - Procedure completed Successfully';
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Complete');
       --Concurrent Process log line
   EXCEPTION
      WHEN NO_DATA_FOUND THEN -- file opened for reading does not exist
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Input File Not Found');
         --Concurrent Process log line
         retcode := 2; -- mark Concurrent process as failed
         UTL_FILE.FCLOSE(l_infile); -- close file opened for reading
         UTL_FILE.FCLOSE(l_out_file);
         FND_MESSAGE.SET_NAME('PER','PER_289859_FILE_NOT_FOUND');
         FND_MESSAGE.RAISE_ERROR;

      WHEN UTL_FILE.INVALID_OPERATION THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,
           'The supplied file cannot be opened.'||
           'Please check the file name and make sure this file exists'||
           ' in the correct directory, and that the file is readable');
         --Concurrent Process log line
         retcode := 2; -- mark Concurrent process as failed
         UTL_FILE.FCLOSE(l_infile); -- close file opened for reading
         UTL_FILE.FCLOSE(l_out_file);
         FND_MESSAGE.SET_NAME('PER','PER_289863_INVALID_OP');
         FND_MESSAGE.RAISE_ERROR;

      WHEN UTL_FILE.READ_ERROR THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Input File Error');
         --Concurrent Process log line
         retcode := 2; -- mark Concurrent process as failed
         UTL_FILE.FCLOSE(l_infile); -- close file opened for reading
         UTL_FILE.FCLOSE(l_out_file);
         FND_MESSAGE.SET_NAME('PER','PER_289860_READ_ERROR');
         FND_MESSAGE.RAISE_ERROR;

      WHEN UTL_FILE.WRITE_ERROR THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Output File Error');
         --Concurrent Process log line
         retcode := 2; -- mark Concurrent process as failed
         UTL_FILE.FCLOSE(l_infile); -- close file opened for reading
         UTL_FILE.FCLOSE(l_out_file);
         FND_MESSAGE.SET_NAME('PER','PER_289861_WRITE_ERROR');
         FND_MESSAGE.RAISE_ERROR;

      WHEN UTL_FILE.INVALID_PATH THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invalid Directory Supplied');
         --Concurrent Process log line
         retcode := 2; -- mark Concurrent process as failed
         UTL_FILE.FCLOSE(l_infile); -- close file opened for reading
         UTL_FILE.FCLOSE(l_out_file);
         FND_MESSAGE.SET_NAME('PER','PER_289862_INVALID_PATH');
         FND_MESSAGE.RAISE_ERROR;

  END parse_ini_file;

END HR_ADE_UPGRADE;


/
