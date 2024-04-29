--------------------------------------------------------
--  DDL for Package Body GMI_LOTS_WRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_LOTS_WRP" AS
/*  $Header: GMIPLOWB.pls 115.14 2003/10/22 18:37:18 jsrivast gmigapib.pls $
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Create_Lot                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create an Item Lot                                                    |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the Create_Lot             |
 |    API wrapper function                                                  |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_dir              IN VARCHAR2         - Working directory for input  |
 |                                             and output files.            |
 |    p_input_file       IN VARCHAR2         - Name of input file           |
 |    p_output_file      IN VARCHAR2         - Name of output file          |
 |    p_delimiter        IN VARCHAR2         - Delimiter character          |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |   Joe DiIorio 12/30/2002 Bug#2729049 11.5.1J plus                        |
 |   Correct delimiter sequence.  Inactive field was ignored so from there  |
 |   on all fields were incorrect.                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Create_Lot
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

l_return_status  :=Create_Lot( p_dir
			      , p_input_file
			      , p_output_file
			      , p_delimiter
			      );

End Create_Lot;

/* +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Create_Lot                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create a Lot/Sublot                                                   |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the OPM Lot/Sublot Create   |
 |    API                                                                   |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called wrapper<session_id>.log in the /tmp directory.                 |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_dir              IN VARCHAR2         - Working directory for input  |
 |                                             and output files.            |
 |    p_input_file       IN VARCHAR2         - Name of input file           |
 |    p_output_file      IN VARCHAR2         - Name of output file          |
 |    p_delimiter        IN VARCHAR2         - Delimiter character          |
 |                                                                          |
 | RETURNS                                                                  |
 |    VARCHAR2 - 'S' All records processed successfully                     |
 |               'E' 1 or more records errored                              |
 |               'U' 1 or more record unexpected error                      |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 |    24-DEC-2001  K. RajaSekhar Reddy BUG#2158123                          |
 |                          Modified the code to create the Retest Date,    |
 |                          Expire Date and Expaction Dates correctly.      |
 +==========================================================================+
  Api end of comments
*/
FUNCTION Create_Lot
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2
IS

/*
  Local variables
*/

l_status             VARCHAR2(1);
l_return_status      VARCHAR2(1)  :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER  ;
l_loop_cnt           NUMBER  :=0;
l_dummy_cnt          NUMBER  :=0;
l_record_count       NUMBER  :=0;
l_data               VARCHAR2(2000);
lot_rec              GMIGAPI.lot_rec_typ;
l_p_dir              VARCHAR2(50);
l_output_file        VARCHAR2(20);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(20);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(200);
l_delimiter          VARCHAR(1);
l_log_dir            VARCHAR2(50);
l_log_name           VARCHAR2(20)  :='wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(20);

l_session_id         VARCHAR2(10);
l_ic_lots_mst_row    ic_lots_mst%ROWTYPE;
l_ic_lots_cpg_row    ic_lots_cpg%ROWTYPE;
BEGIN

/*  Enable The Buffer
  DBMS_OUTPUT.ENABLE(1000000);
*/

l_p_dir              :=p_dir;
l_input_file         :=p_input_file;
l_output_file        :=p_output_file;
l_delimiter          :=p_delimiter;
l_global_file        :=l_input_file;

/*
  Obtain The SessionId To Append To wrapper File Name.
*/

l_session_id := USERENV('sessionid');

l_log_name  := CONCAT(l_log_name,l_session_id);
l_log_name  := CONCAT(l_log_name,'.log');
/*
  Directory is now the same same as for the out file
*/
l_log_dir   := p_dir;

/*
  Open The Wrapper File For Output And The Input File for Input.
*/

l_log_handle      :=UTL_FILE.FOPEN(l_log_dir, l_log_name, 'w');
l_infile_handle   :=UTL_FILE.FOPEN(l_p_dir, l_input_file, 'r');

/*
  Loop thru flat file and call Inventory Quantities API
*/

/*  dbms_output.put_line('Start Processing');   */
UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at '
|| to_char(SYSDATE,'DD-MON-YY HH:MI:SS'));

UTL_FILE.NEW_LINE(l_log_handle);
UTL_FILE.PUT_LINE(l_log_handle, 'Input Directory  ' || l_p_dir );
UTL_FILE.PUT_LINE(l_log_handle, 'Input File       ' || l_input_file );
UTL_FILE.PUT_LINE(l_log_handle, 'Record Type      ' || l_delimiter );
UTL_FILE.PUT_LINE(l_log_handle, 'Output File      ' || l_output_file );

l_outfile_handle  :=UTL_FILE.FOPEN(l_p_dir, l_output_file, 'w');

LOOP
l_record_count    :=l_record_count+1;

  BEGIN
  UTL_FILE.GET_LINE(l_infile_handle, l_line);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
EXIT;
  END;

UTL_FILE.NEW_LINE(l_log_handle);
UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record ' || l_record_count );

  lot_rec.item_no         :=Get_Field(l_line,l_delimiter,1);
  lot_rec.lot_no          :=Get_Field(l_line,l_delimiter,2);
  lot_rec.sublot_no       :=Get_Field(l_line,l_delimiter,3);
  lot_rec.lot_desc        :=Get_Field(l_line,l_delimiter,4);
  lot_rec.qc_grade        :=Get_Field(l_line,l_delimiter,5);
  lot_rec.expaction_code  :=Get_Field(l_line,l_delimiter,6);
  --BEGIN BUG#2158123 12/21/2001 RajaSekhar
  --Modified the IF condition from Null  to NOT NULL and commented the
  --two lines.
  IF (Get_Field(l_line,l_delimiter,7) IS NOT NULL)
  THEN
    --lot_rec.expaction_date :=GMA_GLOBAL_GRP.SY$MAX_DATE;
    --  ELSE
    lot_rec.expaction_date :=TO_DATE(
			     Get_Field(l_line,l_delimiter,7),'DDMMYYYY');
  END IF;
  --END BUG#2158123
  IF (Get_Field(l_line,l_delimiter,8) IS NULL)
  THEN
    lot_rec.lot_created   :=SYSDATE;
  ELSE
    lot_rec.lot_created   :=TO_DATE(
			     Get_Field(l_line,l_delimiter,8),'DDMMYYYY');
  END IF;
  --BEGIN BUG#2158123 12/21/2001 RajaSekhar
  --Modified the IF conditions from Null  to NOT NULL and commented the
  --four lines.
  IF (Get_Field(l_line,l_delimiter,9) IS NOT NULL)
  THEN
  --lot_rec.expire_date   :=GMA_GLOBAL_GRP.SY$MAX_DATE;
  --ELSE
    lot_rec.expire_date   :=TO_DATE(
			     Get_Field(l_line,l_delimiter,9),'DDMMYYYY');
  END IF;

  IF (Get_Field(l_line,l_delimiter,10) IS NOT NULL)
  THEN
  --lot_rec.retest_date   :=GMA_GLOBAL_GRP.SY$MAX_DATE;
  -- ELSE
    lot_rec.retest_date   :=TO_DATE(
			     Get_Field(l_line,l_delimiter,10),'DDMMYYYY');
  END IF;
  --END BUG#2158123
  IF (Get_Field(l_line,l_delimiter,11) IS NULL)
  THEN
    lot_rec.strength      :=100;
  ELSE
    lot_rec.strength      :=TO_NUMBER(Get_Field(l_line,l_delimiter,11));
  END IF;
  IF (Get_Field(l_line,l_delimiter,12) IS NULL) THEN
     lot_rec.inactive_ind    :=0;
  ELSE
     lot_rec.inactive_ind    := TO_NUMBER(Get_Field(l_line,l_delimiter,12));
  END IF;
  IF (Get_Field(l_line,l_delimiter,13) IS NULL)
  THEN
    lot_rec.origination_type     :=0;
  ELSE
    lot_rec.origination_type     :=TO_NUMBER(Get_Field(l_line,l_delimiter,13));
  END IF;
  lot_rec.shipvendor_no   :=Get_Field(l_line,l_delimiter,14);
  lot_rec.vendor_lot_no   :=Get_Field(l_line,l_delimiter,15);
  IF (Get_Field(l_line,l_delimiter,16) IS NULL)
  THEN
    lot_rec.ic_matr_date   :=GMA_GLOBAL_GRP.SY$MAX_DATE;
  ELSE
    lot_rec.ic_matr_date   :=TO_DATE(
			     Get_Field(l_line,l_delimiter,16),'DDMMYYYY');
  END IF;
  /* Jalaj Srivastava Bug 3158806
     Null hold date is allowed */
  IF (Get_Field(l_line,l_delimiter,17) IS NOT NULL)
  THEN
    lot_rec.ic_hold_date   :=TO_DATE(
			     Get_Field(l_line,l_delimiter,17),'DDMMYYYY');
  END IF;
  IF (Get_Field(l_line,l_delimiter,18) IS NULL)
  THEN
    lot_rec.user_name       :='OPM';
  ELSE
    lot_rec.user_name       :=Get_Field(l_line,l_delimiter,18);
  END IF;
  lot_rec.attribute1      :=Get_Field(l_line,l_delimiter,19);
  lot_rec.attribute2      :=Get_Field(l_line,l_delimiter,20);
  lot_rec.attribute3      :=Get_Field(l_line,l_delimiter,21);
  lot_rec.attribute4      :=Get_Field(l_line,l_delimiter,22);
  lot_rec.attribute5      :=Get_Field(l_line,l_delimiter,23);
  lot_rec.attribute6      :=Get_Field(l_line,l_delimiter,24);
  lot_rec.attribute7      :=Get_Field(l_line,l_delimiter,25);
  lot_rec.attribute8      :=Get_Field(l_line,l_delimiter,26);
  lot_rec.attribute9      :=Get_Field(l_line,l_delimiter,27);
  lot_rec.attribute10     :=Get_Field(l_line,l_delimiter,28);
  lot_rec.attribute11     :=Get_Field(l_line,l_delimiter,29);
  lot_rec.attribute12     :=Get_Field(l_line,l_delimiter,30);
  lot_rec.attribute13     :=Get_Field(l_line,l_delimiter,31);
  lot_rec.attribute14     :=Get_Field(l_line,l_delimiter,32);
  lot_rec.attribute15     :=Get_Field(l_line,l_delimiter,33);
  lot_rec.attribute16     :=Get_Field(l_line,l_delimiter,34);
  lot_rec.attribute17     :=Get_Field(l_line,l_delimiter,35);
  lot_rec.attribute18     :=Get_Field(l_line,l_delimiter,36);
  lot_rec.attribute19     :=Get_Field(l_line,l_delimiter,37);
  lot_rec.attribute20     :=Get_Field(l_line,l_delimiter,38);
  lot_rec.attribute21     :=Get_Field(l_line,l_delimiter,39);
  lot_rec.attribute22     :=Get_Field(l_line,l_delimiter,40);
  lot_rec.attribute23     :=Get_Field(l_line,l_delimiter,41);
  lot_rec.attribute24     :=Get_Field(l_line,l_delimiter,42);
  lot_rec.attribute25     :=Get_Field(l_line,l_delimiter,43);
  lot_rec.attribute26     :=Get_Field(l_line,l_delimiter,44);
  lot_rec.attribute27     :=Get_Field(l_line,l_delimiter,45);
  lot_rec.attribute28     :=Get_Field(l_line,l_delimiter,46);
  lot_rec.attribute29     :=Get_Field(l_line,l_delimiter,47);
  lot_rec.attribute30     :=Get_Field(l_line,l_delimiter,48);
  lot_rec.attribute_category  :=Get_Field(l_line,l_delimiter,49);

UTL_FILE.PUT_LINE(l_log_handle,'item no        = '||lot_rec.item_no);
UTL_FILE.PUT_LINE(l_log_handle,'lot_no         = '||lot_rec.lot_no);
UTL_FILE.PUT_LINE(l_log_handle,'sublot_no      = '||lot_rec.sublot_no);
UTL_FILE.PUT_LINE(l_log_handle,'lot_desc       = '||lot_rec.lot_desc);
UTL_FILE.PUT_LINE(l_log_handle,'qc_grade       = '||lot_rec.qc_grade);
UTL_FILE.PUT_LINE(l_log_handle,'expaction_code = '||
				lot_rec.expaction_code);
UTL_FILE.PUT_LINE(l_log_handle,'expaction_date = '||
				lot_rec.expaction_date);
UTL_FILE.PUT_LINE(l_log_handle,'lot_created    = '||
				lot_rec.lot_created);
UTL_FILE.PUT_LINE(l_log_handle,'expire_date    = '||
				lot_rec.expire_date);
UTL_FILE.PUT_LINE(l_log_handle,'retest_date    = '||
				lot_rec.retest_date);
UTL_FILE.PUT_LINE(l_log_handle,'strength       = '||lot_rec.strength);
UTL_FILE.PUT_LINE(l_log_handle,'inactive_ind   = '||lot_rec.inactive_ind);
UTL_FILE.PUT_LINE(l_log_handle,'origination_type = '||
				lot_rec.origination_type);
UTL_FILE.PUT_LINE(l_log_handle,'shipvendor_no  = '||lot_rec.shipvendor_no);
UTL_FILE.PUT_LINE(l_log_handle,'vendor_lot_no  = '||lot_rec.vendor_lot_no);
UTL_FILE.PUT_LINE(l_log_handle,'ic_matr_date   = '||lot_rec.ic_matr_date);
UTL_FILE.PUT_LINE(l_log_handle,'ic_hold_date   = '||lot_rec.ic_hold_date);
UTL_FILE.PUT_LINE(l_log_handle,'user name        = '||lot_rec.user_name );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute1        = '||                                                         lot_rec.attribute1 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute2        = '||                                                         lot_rec.attribute2 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute3        = '||                                                         lot_rec.attribute3 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute4        = '||                                                         lot_rec.attribute4 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute5        = '||                                                         lot_rec.attribute5 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute6        = '||                                                         lot_rec.attribute6 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute7        = '||                                                         lot_rec.attribute7 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute8        = '||                                                         lot_rec.attribute8 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute9        = '||                                                         lot_rec.attribute9 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute10        = '||                                                         lot_rec.attribute10 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute11        = '||                                                         lot_rec.attribute11 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute12        = '||                                                         lot_rec.attribute12 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute13        = '||                                                         lot_rec.attribute13 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute14        = '||                                                         lot_rec.attribute14 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute15        = '||                                                         lot_rec.attribute15 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute16        = '||                                                         lot_rec.attribute16 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute17        = '||                                                         lot_rec.attribute17 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute18        = '||                                                         lot_rec.attribute18 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute19        = '||                                                         lot_rec.attribute19 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute20        = '||                                                         lot_rec.attribute20 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute21        = '||                                                         lot_rec.attribute21 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute22        = '||                                                         lot_rec.attribute22 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute23        = '||                                                         lot_rec.attribute23 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute24        = '||                                                         lot_rec.attribute24 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute25        = '||                                                         lot_rec.attribute25 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute26        = '||                                                         lot_rec.attribute26 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute27        = '||                                                         lot_rec.attribute27 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute28        = '||                                                         lot_rec.attribute28 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute29        = '||                                                         lot_rec.attribute29 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute30        = '||                                                         lot_rec.attribute30 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute_Category = '||                                                         lot_rec.attribute_category );

GMIPAPI.Create_Lot
( p_api_version    => 3.0
, p_init_msg_list  => FND_API.G_TRUE
, p_commit         => FND_API.G_TRUE
, p_validation_level => FND_API.G_VALID_LEVEL_FULL
, p_lot_rec        =>lot_rec
, x_ic_lots_mst_row => l_ic_lots_mst_row
, x_ic_lots_cpg_row => l_ic_lots_cpg_row
, x_return_status  =>l_status
, x_msg_count      =>l_count
, x_msg_data       =>l_data
);

IF l_count > 0
THEN
  l_loop_cnt  :=1;
  LOOP

  FND_MSG_PUB.Get(
    p_msg_index     => l_loop_cnt,
    p_data          => l_data,
    p_encoded       => FND_API.G_FALSE,
    p_msg_index_out => l_dummy_cnt);

  /*  dbms_output.put_line('Message ' || l_data );  */

  UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
  UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
  UTL_FILE.NEW_LINE(l_outfile_handle);

  IF l_status = 'E' OR
     l_status = 'U'
  THEN
    l_data    := CONCAT('ERROR ',l_data);
  END IF;

  UTL_FILE.PUT_LINE(l_log_handle, l_data);

  /*  Update error status  */
    IF (l_status = 'U')
    THEN
      l_return_status  :=l_status;
    ELSIF (l_status = 'E' and l_return_status <> 'U')
    THEN
      l_return_status  :=l_status;
    ELSE
      l_return_status  :=l_status;
    END IF;

  l_loop_cnt  := l_loop_cnt + 1;
  IF l_loop_cnt > l_count
  THEN
    EXIT;
  END IF;

  END LOOP;

END IF;

END LOOP;
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at '
  || to_char(SYSDATE,'DD-MON-YY HH:MI:SS'));
/*
  Check if any messages generated. If so then decode and
  output to error message flat file
*/

UTL_FILE.FCLOSE_ALL;

RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  dbms_output.put_line('Invalid Operation For '|| l_global_file);  */
   UTL_FILE.FCLOSE_ALL;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  dbms_output.put_line('Invalid Path For      '|| l_global_file);  */
   UTL_FILE.FCLOSE_ALL;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  dbms_output.put_line('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /*  dbms_output.put_line('Invalid File Handle   '|| l_global_file);  */
   UTL_FILE.FCLOSE_ALL;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  dbms_output.put_line('Invalid Write Error   '|| l_global_file);  */
   UTL_FILE.FCLOSE_ALL;

WHEN UTL_FILE.READ_ERROR THEN
   /*  dbms_output.put_line('Invalid Read  Error   '|| l_global_file);  */
   UTL_FILE.FCLOSE_ALL;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  dbms_output.put_line('Internal Error');   */
   UTL_FILE.FCLOSE_ALL;

WHEN OTHERS THEN
   /*  dbms_output.put_line('Other Error');  */
   UTL_FILE.FCLOSE_ALL;

END Create_Lot;

/* +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Get_Field                                                             |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Get value of field n from a delimited line of ASCII data              |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This utility function will return the value of a field from           |
 |    a delimited line of ASCII text                                        |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_line             IN VARCHAR2         - line of data                 |
 |    p_delimiter        IN VARCHAR2         - Delimiter character          |
 |    p_field_no         IN NUMBER           - Field occurance to be        |
 |                                             returned                     |
 |                                                                          |
 | RETURNS                                                                  |
 |    VARCHAR2                               - Value of field               |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
FUNCTION Get_Field
( p_line         IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_field_no     IN NUMBER
)
RETURN VARCHAR2
IS
/*
  Local variables
*/
l_start         NUMBER  :=0;
l_end           NUMBER  :=0;

BEGIN

/*   Determine start position  */
IF p_field_no = 1
THEN
  l_start       :=0;
ELSE
  l_start       :=INSTR(p_line,p_delimiter,1,(p_field_no - 1));
  IF l_start    = 0
  THEN
    RETURN NULL;
  END IF;
END IF;

/*  Determine end position   */
l_end           :=INSTR(p_line,p_delimiter,1,p_field_no);
IF l_end        = 0
THEN
  l_end         := LENGTH(p_line) + 1;
END IF;

/*  Extract the field data  */
IF (l_end - l_start) = 1
THEN
  RETURN NULL;
ELSE
  RETURN SUBSTR(p_line,(l_start + 1),((l_end - l_start) - 1));
END IF;

EXCEPTION
  WHEN OTHERS
  THEN
    RETURN NULL;

END Get_Field;

/* +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Get_Substring                                                         |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Get value of Sub-string from formatted ASCII data file record         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This utility function will return the value of a passed sub-string    |
 |    of a formatted ASCII data file record                                 |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_substring        IN VARCHAR2         - substring data               |
 |                                                                          |
 | RETURNS                                                                  |
 |    VARCHAR2                               - Value of field               |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
FUNCTION Get_Substring
( p_substring    IN VARCHAR2
)
RETURN VARCHAR2
IS
/*
  Local variables
*/
l_string_value   VARCHAR2(200)  :=' ';

BEGIN

/*  Determine start position    */
l_string_value  :=NVL(RTRIM(LTRIM(p_substring)),' ');

RETURN l_string_value;
EXCEPTION
  WHEN OTHERS
  THEN
    RETURN ' ';

END Get_Substring;

END GMI_LOTS_WRP;

/
