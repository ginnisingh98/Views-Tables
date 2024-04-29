--------------------------------------------------------
--  DDL for Package Body PAY_NO_TAX_TABLE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_TAX_TABLE_UPLOAD" 
/* $Header: pynottup.pkb 120.1 2006/12/07 08:54:38 sugarg noship $ */
AS
g_package CONSTANT  VARCHAR2 (33) := 'PAY_NO_TAX_TABLE_UPLOAD';

   -- Global constants
g_warning   CONSTANT    NUMBER  := 1;
g_error     CONSTANT    NUMBER  := 2;


    -- Exceptions
e_fatal_error          EXCEPTION;
e_record_too_long      EXCEPTION;
e_empty_line           EXCEPTION;
e_SAME_DATE            EXCEPTION;
e_FUTURE_REC_EXISTS    EXCEPTION;


c_end_of_time   CONSTANT    DATE    := to_date('12/31/4712','MM/DD/YYYY');

PROCEDURE MAIN
            (
          errbuf                   OUT  nocopy VARCHAR2,
              retcode                  OUT  nocopy NUMBER,
              p_data_file_name          IN         VARCHAR2,
              p_effective_start_date    IN         VARCHAR2,
              p_business_group          IN         NUMBER
        )
IS

CURSOR CSR_Legislation_Code
is
select LEGISLATION_CODE from  PER_BUSINESS_GROUPS where BUSINESS_GROUP_ID=p_business_group;


l_proc    CONSTANT VARCHAR2 (72)  :=    g_package||'.MAIN' ;
l_errbuf           VARCHAR2 (1000);
l_retcode          Number;

lr_Legislation_Code CSR_Legislation_Code%ROWTYPE;

Legislation_Code PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE;

BEGIN
--hr_utility.trace_on(null,'vsvn1');
OPEN CSR_Legislation_Code;
FETCH CSR_Legislation_Code into lr_Legislation_Code;
close CSR_Legislation_Code;

Legislation_Code := lr_Legislation_Code.LEGISLATION_CODE;

hr_utility.set_location (   'Entering:' || l_proc, 10);

hr_utility.set_location ( 'p_business_group'||p_business_group,15);
hr_utility.set_location ( 'Legislation = ' || legislation_code, 20);
hr_utility.set_location ( 'Effective Start Date = ' || p_effective_start_date, 21);
hr_utility.set_location ( 'c_end_of_time = ' || c_end_of_time, 22);

-- Check for Sweden Localization.
IF  legislation_code= 'NO'
THEN
        PURGE(l_errbuf,l_retcode,NULL,NULL,NULL);

  -- Date Validation Check
    -- Call for the SQL Loader Concurrent Request
    Upload_Tax_To_Temp_Table(l_errbuf,l_retcode,p_data_file_name);
    errbuf := l_errbuf;
    retcode :=l_retcode;


    -- Call to Load data procedure
    Upload_Tax_To_Main_Table
                    (l_errbuf,
                     l_retcode,
                     p_legislation_code        => legislation_code,
                     p_effective_start_date    => TRUNC(TO_DATE(p_effective_start_date,'YYYY/MM/DD HH24:MI:SS')),
                     p_business_group          => p_business_group
                     );
    errbuf := l_errbuf;
    retcode :=l_retcode;
-- Emptying the Temp tables
       PURGE(l_errbuf,l_retcode,NULL,NULL,NULL);
    commit;
END IF;

hr_utility.set_location (   'Leaving:' || l_proc, 40);
END MAIN;

/*        */


---------------------------------------------------------------------------------
PROCEDURE PURGE(
            errbuf                   OUT  nocopy VARCHAR2,
            retcode                  OUT  nocopy NUMBER,
            p_business_group         IN   NUMBER,
            p_effective_start_date   IN   VARCHAR2,
            p_effective_end_date     IN   VARCHAR2
            )
IS

CURSOR csr_Legislation_Code
is
select LEGISLATION_CODE from PER_BUSINESS_GROUPS where BUSINESS_GROUP_ID=p_business_group;


/*

CURSOR csr_RANGE_TABLE_ID(p_Legislation_Code PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE)
is
    select RANGE_TABLE_ID ,OBJECT_VERSION_NUMBER
    from   PAY_RANGE_TABLES_F
    where  LEGISLATION_CODE        = p_Legislation_Code
    AND    BUSINESS_GROUP_ID       = p_business_group
    AND    EFFECTIVE_START_DATE   >= TO_DATE(p_effective_start_date,'YYYY/MM/DD HH24:MI:SS')
    AND    EFFECTIVE_END_DATE     <= TO_DATE(p_effective_end_date,'YYYY/MM/DD HH24:MI:SS');

*/

-- Bug Fix 5533206, Norwegian Tax Tables will now be uploaded without any Business Group
-- modifying cursor to remove the check for business group id

CURSOR csr_RANGE_TABLE_ID(p_Legislation_Code PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE)
is
    select RANGE_TABLE_ID ,OBJECT_VERSION_NUMBER
    from   PAY_RANGE_TABLES_F
    where  LEGISLATION_CODE        = p_Legislation_Code
    AND    EFFECTIVE_START_DATE   >= TO_DATE(p_effective_start_date,'YYYY/MM/DD HH24:MI:SS')
    AND    EFFECTIVE_END_DATE     <= TO_DATE(p_effective_end_date,'YYYY/MM/DD HH24:MI:SS');


CURSOR csr_RANGE_ID(p_RANGE_TABLE_ID NUMBER)
is
SELECT RANGE_ID, OBJECT_VERSION_NUMBER
from   PAY_RANGES_F
where  RANGE_TABLE_ID =p_RANGE_TABLE_ID
AND    EFFECTIVE_START_DATE    >= TO_DATE(p_effective_start_date,'YYYY/MM/DD HH24:MI:SS')
AND    EFFECTIVE_END_DATE      <= TO_DATE(p_effective_end_date,'YYYY/MM/DD HH24:MI:SS');


lr_Legislation_Code CSR_Legislation_Code%ROWTYPE;
Legislation_Code    PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE;

l_Ran_OBJECT_VERSION_NUMBER  PAY_RANGES_F.OBJECT_VERSION_NUMBER%TYPE;
l_Prf_OBJECT_VERSION_NUMBER  PAY_RANGE_TABLES_F.OBJECT_VERSION_NUMBER%TYPE;

l_RANGE_ID       PAY_RANGES_F.RANGE_ID%TYPE;
l_RANGE_TABLE_ID PAY_RANGE_TABLES_F.RANGE_TABLE_ID%TYPE;

BEGIN

--hr_utility.trace_on(null,'tax');
hr_utility.set_location (   'Entering: Purge ', 10);
hr_utility.set_location (   'p_business_group '||p_business_group, 10);

hr_utility.set_location (   'p_effective_start_date'||p_effective_start_date, 10);
hr_utility.set_location (   'p_effective_end_date'||p_effective_end_date, 10);

IF p_effective_start_date is NULL AND p_effective_end_date IS NULL
THEN
    DELETE  FROM  PAY_RANGE_TEMP;

ELSE

OPEN CSR_Legislation_Code;
FETCH CSR_Legislation_Code into lr_Legislation_Code;
close CSR_Legislation_Code;

Legislation_Code := lr_Legislation_Code.LEGISLATION_CODE;

hr_utility.set_location (   'Legislation_Code'||Legislation_Code, 10);

OPEN csr_RANGE_TABLE_ID(Legislation_Code);
LOOP
   FETCH csr_RANGE_TABLE_ID into l_RANGE_TABLE_ID,l_Prf_OBJECT_VERSION_NUMBER;
   EXIT WHEN csr_RANGE_TABLE_ID%NOTFOUND;

   OPEN csr_RANGE_ID(l_RANGE_TABLE_ID);
     LOOP
      FETCH csr_RANGE_ID into l_RANGE_ID,l_Ran_OBJECT_VERSION_NUMBER;
      EXIT WHEN csr_RANGE_ID%NOTFOUND;
        pay_range_api.delete_range(l_RANGE_ID,l_Ran_OBJECT_VERSION_NUMBER);
     END LOOP;
   CLOSE csr_RANGE_ID;

pay_range_table_api.delete_range_table(l_RANGE_TABLE_ID,l_Prf_OBJECT_VERSION_NUMBER);


END LOOP;
CLOSE csr_RANGE_TABLE_ID;




/*        DELETE FROM PAY_RANGES_F
        where RANGE_TABLE_ID in
                           ( select RANGE_TABLE_ID
                             from   PAY_RANGE_TABLES_F
                             where  LEGISLATION_CODE        = Legislation_Code
                             AND    BUSINESS_GROUP_ID       = p_business_group
                             AND    EFFECTIVE_START_DATE   >= TO_DATE(p_effective_start_date,'YYYY/MM/DD HH24:MI:SS')
                             AND    EFFECTIVE_END_DATE     <= TO_DATE(p_effective_end_date,'YYYY/MM/DD HH24:MI:SS')
                            )
        AND  EFFECTIVE_START_DATE    >= TO_DATE(p_effective_start_date,'YYYY/MM/DD HH24:MI:SS')
        AND  EFFECTIVE_END_DATE      <= TO_DATE(p_effective_end_date,'YYYY/MM/DD HH24:MI:SS');


        DELETE  FROM  PAY_RANGE_TABLES_F
        WHERE   LEGISLATION_CODE     = Legislation_Code
        AND  BUSINESS_GROUP_ID       = p_business_group
        AND  EFFECTIVE_START_DATE    >= TO_DATE(p_effective_start_date,'YYYY/MM/DD HH24:MI:SS')
        AND  EFFECTIVE_END_DATE      <= TO_DATE(p_effective_end_date,'YYYY/MM/DD HH24:MI:SS');
   -- Commit it after deleting

*/

END IF;

   commit;

END PURGE;
---------------------------------------------------------------------------------
PROCEDURE check_date
                  (
                     p_effective_start_date     in varchar2,
             p_effective_end_date       in varchar2,
             p_message_name             in varchar2
            )
IS
BEGIN

IF TO_DATE(p_effective_start_date,'YYYY/MM/DD HH24:MI:SS') >
               TO_DATE(p_effective_end_date,'YYYY/MM/DD HH24:MI:SS')
THEN

     fnd_message.set_name('PAY',p_message_name);
     fnd_message.raise_error;

END IF;

end check_date;

---------------------------------------------------------------------------

/*          */

PROCEDURE Upload_Tax_To_Main_Table
    (
          errbuf             OUT  nocopy VARCHAR2,
              retcode            OUT  nocopy NUMBER,
              p_legislation_code     IN  VARCHAR2,
              p_effective_start_date IN  DATE,
              p_business_group       IN  NUMBER
        )
IS

l_proc    CONSTANT VARCHAR2 (72)  :=    g_package||'.Upload_Tax_To_Main_Table' ;
    -- Automatic Sequence created by API
    l_pay_f_range_table_id  PAY_RANGE_TABLES_F.RANGE_TABLE_ID%TYPE;

    -- Values from flat file to be uploaded to Temp Tables
    l_range_table_num   PAY_RANGE_TABLES_F.RANGE_TABLE_NUMBER%TYPE;
    l_period_frequency  PAY_RANGE_TABLES_F.PERIOD_FREQUENCY%TYPE;
    l_earnings_type     PAY_RANGE_TABLES_F.EARNINGS_TYPE%TYPE;
    l_low_band      PAY_RANGES_F.LOW_BAND%TYPE;
    l_high_band     PAY_RANGES_F.HIGH_BAND%TYPE;
    l_amount1       PAY_RANGES_F.AMOUNT1%TYPE;
    l_amount2       PAY_RANGES_F.AMOUNT2%TYPE;
    l_range_id      PAY_RANGES_F.RANGE_ID%TYPE;
    l_max_range_id  PAY_RANGES_F.RANGE_ID%TYPE;


    l_dummy_range_table_id  PAY_RANGE_TABLES_F.RANGE_TABLE_ID%TYPE;
    l_object_version_number PAY_RANGE_TABLES_F.OBJECT_VERSION_NUMBER%TYPE;

    l_dummy PAY_RANGE_TABLES_F.OBJECT_VERSION_NUMBER%TYPE;


    l_csr_range_table_id    PAY_RANGE_TABLES_F.RANGE_TABLE_ID%TYPE;

/*
CURSOR csr_data_exists_on_same_date
IS
       SELECT   'Y'
    FROM    PAY_RANGE_TABLES_F
    WHERE   LEGISLATION_CODE     = p_legislation_code
        AND BUSINESS_GROUP_ID    = p_business_group
    AND EFFECTIVE_START_DATE = p_effective_start_date;

*/

-- Bug Fix 5533206, Norwegian Tax Tables will now be uploaded without any Business Group
-- Modifying cursor to check for business_gorup_id IS NULL

CURSOR csr_data_exists_on_same_date
IS
       SELECT   'Y'
    FROM    PAY_RANGE_TABLES_F
    WHERE   LEGISLATION_CODE     = p_legislation_code
    AND BUSINESS_GROUP_ID    IS NULL
    AND EFFECTIVE_START_DATE = p_effective_start_date;

/*

CURSOR csr_data_exists_on_future_date
IS
       SELECT   'Y'
    FROM    PAY_RANGE_TABLES_F
    WHERE   LEGISLATION_CODE     = p_legislation_code
        AND BUSINESS_GROUP_ID    = p_business_group
    AND p_effective_start_date BETWEEN
                           EFFECTIVE_START_DATE
                       AND EFFECTIVE_END_DATE
    AND  EFFECTIVE_END_DATE <> c_end_of_time;

*/

-- Bug Fix 5533206 , Modifying cursor to check for business_gorup_id IS NULL

CURSOR csr_data_exists_on_future_date
IS
       SELECT   'Y'
    FROM    PAY_RANGE_TABLES_F
    WHERE   LEGISLATION_CODE     = p_legislation_code
    AND BUSINESS_GROUP_ID    IS NULL
    AND p_effective_start_date BETWEEN
                           EFFECTIVE_START_DATE
                       AND EFFECTIVE_END_DATE
    AND  EFFECTIVE_END_DATE <> c_end_of_time;


/*
CURSOR csr_master_end_date(l_RANGE_TABLE_NUMBER number,
               l_PERIOD_FREQUENCY  NUMBER,
               l_earnings_type VARCHAR2
                )
IS
       SELECT   RANGE_TABLE_ID,object_version_number
    FROM    PAY_RANGE_TABLES_F
    WHERE   LEGISLATION_CODE     = p_legislation_code
        AND BUSINESS_GROUP_ID    = p_business_group
    AND EFFECTIVE_START_DATE < p_effective_start_date
        AND     RANGE_TABLE_NUMBER = l_RANGE_TABLE_NUMBER
        AND EARNINGS_TYPE    =l_earnings_type
        AND PERIOD_FREQUENCY = l_PERIOD_FREQUENCY
        AND     EFFECTIVE_END_DATE = c_end_of_time;

*/

-- Bug Fix 5533206 , Modifying cursor to check for business_gorup_id IS NULL

CURSOR csr_master_end_date(l_RANGE_TABLE_NUMBER number,
               l_PERIOD_FREQUENCY  NUMBER,
               l_earnings_type VARCHAR2
                )
IS
       SELECT   RANGE_TABLE_ID,object_version_number
    FROM    PAY_RANGE_TABLES_F
    WHERE   LEGISLATION_CODE     = p_legislation_code
    AND BUSINESS_GROUP_ID    IS NULL
    AND EFFECTIVE_START_DATE < p_effective_start_date
        AND     RANGE_TABLE_NUMBER = l_RANGE_TABLE_NUMBER
        AND EARNINGS_TYPE    =l_earnings_type
        AND PERIOD_FREQUENCY = l_PERIOD_FREQUENCY
        AND     EFFECTIVE_END_DATE = c_end_of_time;


CURSOR csr_child_end_date(l_RANGE_TABLE_ID NUMBER)
IS
       SELECT   RANGE_ID
    FROM    PAY_RANGES_F
    WHERE   RANGE_TABLE_ID = l_RANGE_TABLE_ID
        AND EFFECTIVE_START_DATE < p_effective_start_date
        AND     EFFECTIVE_END_DATE <> c_end_of_time;


CURSOR csr_distinct_range_values
IS
       SELECT distinct
        RANGE_TABLE_NUMBER,
        PERIOD_FREQUENCY,
        EARNINGS_TYPE
       FROM PAY_RANGE_TEMP;


CURSOR csr_range_band_val_frm_tmp_tab( l_range_table_num NUMBER,l_period_frequency VARCHAR2,l_earnings_type VARCHAR2)
IS
      SELECT    RANGE_ID,LOW_BAND,
        HIGH_BAND,
        AMOUNT1
      FROM  PAY_RANGE_TEMP
      WHERE RANGE_TABLE_NUMBER  = l_range_table_num
      AND   PERIOD_FREQUENCY    = l_period_frequency
      AND   EARNINGS_TYPE       = l_earnings_type;

/*
CURSOR csr_range_values_from_main_tab
IS
       SELECT   RANGE_TABLE_ID,
        RANGE_TABLE_NUMBER,
        PERIOD_FREQUENCY,
        EARNINGS_TYPE
    FROM    PAY_RANGE_TABLES_F
    WHERE   LEGISLATION_CODE     = p_legislation_code
        AND BUSINESS_GROUP_ID    = p_business_group
    AND EFFECTIVE_START_DATE = p_effective_start_date
    AND EFFECTIVE_END_DATE   = c_end_of_time;

*/

-- Bug Fix 5533206 , Modifying cursor to check for business_gorup_id IS NULL

CURSOR csr_range_values_from_main_tab
IS
       SELECT   RANGE_TABLE_ID,
        RANGE_TABLE_NUMBER,
        PERIOD_FREQUENCY,
        EARNINGS_TYPE
    FROM    PAY_RANGE_TABLES_F
    WHERE   LEGISLATION_CODE     = p_legislation_code
    AND BUSINESS_GROUP_ID    IS NULL
    AND EFFECTIVE_START_DATE = p_effective_start_date
    AND EFFECTIVE_END_DATE   = c_end_of_time;


l_Check Varchar2(20);

lr_csr_master_end_date  csr_master_end_date%ROWTYPE;
BEGIN

l_Check := ' ';

select max(range_id) into l_max_range_id  from PAY_RANGE_TEMP;

 hr_utility.set_location (  'UPLOAD PROCESS',10);

   l_object_version_number := 1;


-- Check for the Data if the effective date is same as available in db ,,
-- Plz say no and clear temp table and error out

OPEN  csr_data_exists_on_same_date;
    FETCH csr_data_exists_on_same_date INTO l_Check;
CLOSE csr_data_exists_on_same_date;

    IF l_Check ='Y'
    THEN
    RAISE e_SAME_DATE;
    END IF;
    --Resetting it to null
l_Check := ' ';

OPEN csr_data_exists_on_future_date;
    FETCH csr_data_exists_on_future_date INTO l_Check;
CLOSE csr_data_exists_on_future_date;

    IF l_Check ='Y'
    THEN
    RAISE e_FUTURE_REC_EXISTS;
    END IF;
    --Resetting it to null
l_Check := ' ';

-- TEMP TABLE

l_csr_range_table_id := -99;
-- *****************************************************************************************
   OPEN csr_distinct_range_values;

       LOOP
            FETCH csr_distinct_range_values INTO l_range_table_num,l_period_frequency,l_earnings_type;
            EXIT WHEN csr_distinct_range_values%NOTFOUND;

        OPEN csr_master_end_date(l_range_table_num,l_period_frequency,l_earnings_type);
            FETCH csr_master_end_date INTO l_csr_range_table_id,l_dummy;
        CLOSE   csr_master_end_date;
        IF l_csr_range_table_id <> -99
        THEN
         -- It found the master id is already present which has to be end-dated.

          hr_utility.set_location (  'PROCESS',10);
               pay_range_table_api.update_range_table
                 (
              p_RANGE_TABLE_ID                          => l_csr_range_table_id
                 ,p_EFFECTIVE_END_DATE                      => p_effective_start_date -1
                 ,p_OBJECT_VERSION_NUMBER                   => l_dummy
                 );
         -- End dated the master record , now itself end date the child records


         END_DATE_CHILD(l_csr_range_table_id,p_effective_start_date);

         l_csr_range_table_id := -99;
         END IF;

	 /*
              pay_range_table_api.create_range_table
                 (
              p_RANGE_TABLE_ID                          => l_dummy_range_table_id
             ,p_EFFECTIVE_START_DATE                    => p_effective_start_date
                 ,p_EFFECTIVE_END_DATE                      => c_end_of_time
                 ,p_RANGE_TABLE_NUMBER                      => l_range_table_num
                 ,p_PERIOD_FREQUENCY                        => l_period_frequency
                 ,p_EARNINGS_TYPE                           => l_earnings_type
                 ,p_LEGISLATION_CODE                        => p_legislation_code
                 ,p_BUSINESS_GROUP_ID                       => p_business_group
                 ,p_OBJECT_VERSION_NUMBER                   => l_object_version_number
                 );
	*/

	-- Bug Fix 5533206, Norwegian Tax Tables will now be uploaded without any Business Group
	-- Modifying api call to set business_gorup_id as NULL

              pay_range_table_api.create_range_table
                 (
              p_RANGE_TABLE_ID                          => l_dummy_range_table_id
             ,p_EFFECTIVE_START_DATE                    => p_effective_start_date
                 ,p_EFFECTIVE_END_DATE                      => c_end_of_time
                 ,p_RANGE_TABLE_NUMBER                      => l_range_table_num
                 ,p_PERIOD_FREQUENCY                        => l_period_frequency
                 ,p_EARNINGS_TYPE                           => l_earnings_type
                 ,p_LEGISLATION_CODE                        => p_legislation_code
                 ,p_BUSINESS_GROUP_ID                       => NULL
                 ,p_OBJECT_VERSION_NUMBER                   => l_object_version_number
                 );



    END LOOP;
   CLOSE csr_distinct_range_values;
   commit;
-- *****************************************************************************************

-- Open Master parent table and fetch the range_table_num , Period_frequency and row value num
-- pick up values from temp table for this record and insert that in to Main child table
     OPEN csr_range_values_from_main_tab;

       LOOP
            FETCH   csr_range_values_from_main_tab
        INTO    l_pay_f_range_table_id,
            l_range_table_num,
            l_period_frequency,
            l_earnings_type;

            EXIT WHEN csr_range_values_from_main_tab%NOTFOUND;
    -- For each record in the pay_range_tables_f
    -- pick up all record one by one from pay_ranges_temp
    -- and insert into pay_ranges_f table

            OPEN csr_range_band_val_frm_tmp_tab(l_range_table_num,l_period_frequency,l_earnings_type);
               LOOP
               FETCH    csr_range_band_val_frm_tmp_tab
           INTO l_range_id,l_low_band,
            l_high_band,
            l_amount1;
               EXIT WHEN csr_range_band_val_frm_tmp_tab%NOTFOUND;

         -- check to find whether it is last record to avoid high band search
         if (l_max_range_id <> l_range_id) then

         -- Calculates the HIGH_BAND values by looking a record forward
         select decode(low_band-1,-1,99999,low_band-1) into l_high_band from PAY_RANGE_TEMP where range_id=l_range_id+1;
         pay_range_api.create_range
           (
               P_RANGE_TABLE_ID                          => l_pay_f_range_table_id
              ,P_LOW_BAND                                => l_low_band
              ,P_HIGH_BAND                               => l_high_band
              ,P_AMOUNT1                                 => l_amount1
              ,P_EFFECTIVE_START_DATE                    => p_effective_start_date
              ,P_EFFECTIVE_END_DATE                      => c_end_of_time
              ,P_OBJECT_VERSION_NUMBER                   => l_object_version_number
              ,P_RANGE_ID                                => l_dummy_range_table_id
            );
         else
         pay_range_api.create_range
           (
               P_RANGE_TABLE_ID                          => l_pay_f_range_table_id
              ,P_LOW_BAND                                => l_low_band
              ,P_HIGH_BAND                               => 99999
              ,P_AMOUNT1                                 => l_amount1
              ,P_EFFECTIVE_START_DATE                    => p_effective_start_date
              ,P_EFFECTIVE_END_DATE                      => c_end_of_time
              ,P_OBJECT_VERSION_NUMBER                   => l_object_version_number
              ,P_RANGE_ID                                => l_dummy_range_table_id
            );
         end if;

            END LOOP;
            CLOSE csr_range_band_val_frm_tmp_tab;
            commit;


  END LOOP;
  CLOSE csr_range_values_from_main_tab;
  commit;

EXCEPTION
         -- *************************************
      WHEN e_SAME_DATE
      -- Data already availabe on same date
      THEN

         hr_utility.set_location (l_proc, 270);
         -- Set retcode to 2, indicating an ERROR to the ConcMgr
          retcode := g_error;

            -- Set the application error
         hr_utility.set_message (801, 'PAY_376850_NO_DATE_INVALID');

             -- Return the message to the ConcMgr (This msg will appear in the log file)
             errbuf := hr_utility.get_message;
    -- *************************************

         -- *************************************
      WHEN e_FUTURE_REC_EXISTS
      -- Data already availabe on same date
      THEN

         hr_utility.set_location (l_proc, 270);
         -- Set retcode to 2, indicating an ERROR to the ConcMgr
          retcode := g_error;

            -- Set the application error
         hr_utility.set_message (801, 'PAY_376851_NO_FUTURE_DATA_EXST');

             -- Return the message to the ConcMgr (This msg will appear in the log file)
             errbuf := hr_utility.get_message;
    -- *************************************



END Upload_Tax_To_Main_Table;

PROCEDURE END_DATE_CHILD( p_Range_Table_id in Number,p_effective_start_date in DATE )
is

CURSOR csr_child_end_date
IS
       SELECT   RANGE_ID,object_version_number
    FROM    PAY_RANGES_F
    WHERE   RANGE_TABLE_ID = p_RANGE_TABLE_ID
        AND EFFECTIVE_START_DATE < p_effective_start_date
        AND     EFFECTIVE_END_DATE = c_end_of_time;

   l_Range_id number;
   l_object_version_number PAY_RANGE_TABLES_F.OBJECT_VERSION_NUMBER%TYPE;
BEGIN

      OPEN csr_child_end_date;
      LOOP
        EXIT WHEN csr_child_end_date%NOTFOUND;
        FETCH csr_child_end_date into l_Range_id,l_object_version_number;

        Pay_range_api.Update_range
           (
               P_RANGE_TABLE_ID                          => p_RANGE_TABLE_ID
                      ,P_EFFECTIVE_END_DATE              => p_effective_start_date - 1
              ,P_OBJECT_VERSION_NUMBER                   => l_object_version_number
              ,P_RANGE_ID                                => l_Range_id
            );
      END LOOP;
      CLOSE csr_child_end_date;


end END_DATE_CHILD;



-- *****************************************************************************************
/*
    PROCEDURE NAME  : Upload_Tax_To_Temp_Table
    PARAMATERS  : p_data_file_name  -- Name of the file to be read.

    PURPOSE     : To Open the file Specified from the particular Dir
              Pass it to SPLIT_LINE Procedure

    ERRORS HANDLED  : Raise ERROR if No directory specified
              Raise Error for all invalid file level operations
              Like
                invalid operation
                internal error
                invalid mode
                invalid path
                invalid filehandle
                read error
*/
PROCEDURE Upload_Tax_To_Temp_Table
            (
              errbuf             OUT  nocopy VARCHAR2,
              retcode            OUT  nocopy NUMBER,
              p_data_file_name    IN  VARCHAR2
            )

IS

      -- Procedure name
      l_proc            CONSTANT    VARCHAR2 (72)   :=    g_package||'.Upload_Tax_To_Temp_Table' ;

    -- Constants
      c_read_file       CONSTANT    VARCHAR2 (1)    := 'r';
      c_max_linesize        CONSTANT    NUMBER          := 4000;
      c_commit_point        CONSTANT    NUMBER          := 20;
      c_data_exchange_dir   CONSTANT    VARCHAR2 (30)   := 'PER_DATA_EXCHANGE_DIR';

        -- File Handling variables
      l_file_type       UTL_FILE.file_type;
      l_filename        VARCHAR2 (240);
      l_location        VARCHAR2 (4000);
      l_line_read       VARCHAR2 (4000) := NULL;

          -- Batch Variables
      l_batch_seq       NUMBER  := 0;
      l_batch_id        NUMBER;

      -- variables which represents columns in PAY_RANGE_TEMP table.
    l_range_table_number    PAY_RANGE_TABLES_F .RANGE_TABLE_NUMBER%TYPE;
    l_period_frequency  PAY_RANGE_TABLES_F .PERIOD_FREQUENCY%TYPE;
    l_earnings_type     PAY_RANGE_TABLES_F .EARNINGS_TYPE%TYPE;
    l_low_band      PAY_RANGES_F.LOW_BAND%TYPE;
    l_high_band     PAY_RANGES_F.HIGH_BAND%TYPE;
    l_amount1       PAY_RANGES_F.AMOUNT1%TYPE;
    l_amount2       PAY_RANGES_F.AMOUNT2%TYPE;

BEGIN

 hr_utility.set_location (   'Entering:' || l_proc, 10);

 hr_utility.set_location('p_data_file_name '||p_data_file_name,1);

 l_filename := p_data_file_name;
 fnd_profile.get (c_data_exchange_dir, l_location);

 hr_utility.set_location (   'Directory = ' || l_location, 30);

IF l_location IS NULL
THEN
     hr_utility.set_location (   'Raising I/O error = ' || l_location, 35);
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
              l_batch_seq :=   l_batch_seq + 1;

          hr_utility.set_location ( '  line read: ' || l_line_read ,60);

        -- Calling the procedure tyo split the line into variables

            split_line
            (
             p_line           => l_line_read
            ,p_RANGE_TABLE_NUMBER => l_RANGE_TABLE_NUMBER
            ,p_EARNINGS_TYPE      => l_EARNINGS_TYPE
            ,p_PERIOD_FREQUENCY   => l_PERIOD_FREQUENCY
            ,p_LOW_BAND           => l_LOW_BAND
            ,p_AMOUNT1            => l_AMOUNT1
            );

                     insert into
                     pay_range_temp
                     ( RANGE_ID,
                       RANGE_TABLE_NUMBER,
                       ROW_VALUE_UOM,
                       PERIOD_FREQUENCY,
                       EARNINGS_TYPE,
                       LOW_BAND,
                       HIGH_BAND,
                       AMOUNT1,
                       AMOUNT2)
                      values
                     (
                      pay_ranges_f_s.nextval,
                      l_RANGE_TABLE_NUMBER,
                      NULL,
                      l_PERIOD_FREQUENCY,
                      l_EARNINGS_TYPE,
                      l_LOW_BAND,
                      NULL,
                      l_AMOUNT1,
                      NULL);

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
                   -- When the Record in the file is larger than specified size.
         WHEN e_record_too_long
          --Record is too long
         THEN
          -- Set retcode to 1, indicating a WARNING to the ConcMgr
               retcode := g_warning;

               -- Set the application error
               hr_utility.set_message (801, 'PAY_376852_NO_RECORD_TOO_LONG');
               hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
               hr_utility.set_message_token (801, 'LINE', l_line_read);
               hr_utility.set_location (l_proc, 260);

               -- Write the message to log file, do not raise an application error but continue
               -- (with next line)

               fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);
                    -- *************************************
             WHEN e_empty_line THEN
               -- Set retcode to 1, indicating a WARNING to the ConcMgr
               retcode := g_warning;

               -- Set the application error

               hr_utility.set_message (800, 'PAY_376853_NO_EMPTY_LINE');
               hr_utility.set_message_token (800, 'LINE_NO', l_batch_seq);


               -- Write the message to log file, do not raise an application error but continue
               -- (with next line)

               fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);
     END; -- file reading Begin

  END LOOP read_lines_in_file;

     -- Commit the outstanding records
      COMMIT;

      UTL_FILE.fclose (l_file_type);
      hr_utility.set_location (   'Leaving:'|| l_proc, 260);


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
         hr_utility.set_message (801, 'PAY_376826_NO_DATA_EXC_DIR_MIS');

             -- Return the message to the ConcMgr (This msg will appear in the log file)
             errbuf := hr_utility.get_message;

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
          errbuf := 'Reading File ('||l_location ||' -> ' || l_filename  || ') - Invalid Operation.';

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
         errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Internal Error.';

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
         errbuf :=    'Reading File ('  || l_location  || ' -> ' || l_filename || ') - Invalid Mode.';

     -- ***********************************************

      WHEN UTL_FILE.invalid_path
      -- Directory or filename is invalid or not accessible
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         retcode := g_error;
         errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Invalid Path or Filename.';
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
         errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Invalid File Type.';
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
         errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Read Error.';

     -- ***********************************************


      END Upload_Tax_To_Temp_Table;



/*
    PROCEDURE NAME  : split_line
    PARAMATERS  :
             p_line     a line read from file
                        Out variables
                    split the values in the line pass it to
                    specific out parameter.
    PURPOSE     : To split up the line read and return it to specific columns.
    ERRORS HANDLED  :
               e_record_too_long   When Record is Too Long.



    l_range_table_number    PAY_RANGE_TABLES_F .RANGE_TABLE_NUMBER%TYPE;
    l_period_frequency      PAY_RANGE_TABLES_F .PERIOD_FREQUENCY%TYPE;
    l_row_value_uom         PAY_RANGE_TABLES_F .EARNINGS_TYPE%TYPE;
    l_low_band              PAY_RANGES_F.LOW_BAND%TYPE;
    l_amount1               PAY_RANGES_F.AMOUNT1%TYPE;
    */

PROCEDURE split_line
            (
             p_line             IN  VARCHAR2
            ,p_RANGE_TABLE_NUMBER   OUT nocopy PAY_RANGE_TABLES_F .RANGE_TABLE_NUMBER%TYPE
            ,p_EARNINGS_TYPE        out nocopy PAY_RANGE_TABLES_F .EARNINGS_TYPE%TYPE
            ,p_PERIOD_FREQUENCY     OUT nocopy PAY_RANGE_TABLES_F .PERIOD_FREQUENCY%TYPE
            ,p_LOW_BAND             OUT nocopy PAY_RANGES_F.LOW_BAND%TYPE
            ,p_AMOUNT1              OUT nocopy PAY_RANGES_F.AMOUNT1%TYPE
            )
            is

              -- Procedure name
l_proc  CONSTANT  VARCHAR2 (72) :=    g_package|| '.split_line';
l_record_length   NUMBER    :=  16;
BEGIN
 hr_utility.set_location (   'Entering:'|| l_proc, 70);

       --Set record length
      l_record_length := 16;
IF p_line is NULL
THEN
        /* If the line is empty Raise an Warning saying the line is empty */
    RAISE e_empty_line;
ELSE
 -- Error in record if it is too long according to given format
   /*IF (length(p_line)> l_record_length)
   THEN
        hr_utility.set_location (   '  Record too long', 110);
        RAISE e_record_too_long;
   END IF;*/


 p_RANGE_TABLE_NUMBER := substr( p_line ,1,4);
 p_PERIOD_FREQUENCY   := substr( p_line ,5,1);
 p_EARNINGS_TYPE      := substr( p_line ,6,1);
 p_LOW_BAND           := substr( p_line ,7,5);
 p_AMOUNT1            := substr( p_line ,12,5);

hr_utility.set_location (   ' p_RANGE_TABLE_NUMBER' || p_RANGE_TABLE_NUMBER, 110);
hr_utility.set_location (   ' p_EARNINGS_TYPE ' || p_EARNINGS_TYPE, 110);
hr_utility.set_location (   ' p_PERIOD_FREQUENCY ' || p_PERIOD_FREQUENCY, 110);
hr_utility.set_location (   ' p_LOW_BAND ' ||p_LOW_BAND , 110);
hr_utility.set_location (   ' p_AMOUNT1 ' ||p_AMOUNT1 , 110);

END IF;

   hr_utility.set_location (   'Leaving:'|| l_proc, 120);
END;
END pay_no_tax_table_upload;

/
