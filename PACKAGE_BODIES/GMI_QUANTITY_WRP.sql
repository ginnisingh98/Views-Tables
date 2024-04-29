--------------------------------------------------------
--  DDL for Package Body GMI_QUANTITY_WRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_QUANTITY_WRP" AS
/*  $Header: GMIPQTWB.pls 115.17 2003/09/09 04:49:28 gmangari gmigapib.pls $
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Post                                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Post an inventory transaction                                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the Post transaction       |
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
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Post
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

l_return_status  :=Post( p_dir
		       , p_input_file
		       , p_output_file
		       , p_delimiter
		       );

End Post;

/*  +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Post                                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Post an inventory transaction                                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the OPM                     |
 |    Inventory Quantities API.                                             |
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
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |    01/Nov/2001  K.RajaSekhar  Bug 1962677 The field journal_comment is   |
 |                               got from the flat file and assigned to     |
 |                               trans_rec and also stored in UTL_FILE.     |
 |    16/Apr/2002  Sastry        BUG#1492002 Changed the date format to     |
 |                               include the time stamp. Also added code to |
 |                               write a message into the log file if the   |
 |                               user does not pass the date in a valid date|
 |                               format while calling the API.              |
 |    22/May/2002  Sastry        BUG#1492002 Modified the date format so    |
 |                               that the user can input the timestamp in   |
 |                               24-hour time format.                       |
 |    07/04/2002  Jalaj Srivastava Bug 2483656
 |                               Added 33 new columns
 |    07/24/2003   Sastry        BUG#3054841 Increased the size of l_line   |
 |                               from 200 to 4000.                          |
 |    08/14/2003   Sastry        BUG#2861715 Added code to read the newly   |
 |                               added parameter from the flat file.        |
 +==========================================================================+
  Api end of comments
*/
FUNCTION Post
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
trans_rec            GMIGAPI.qty_rec_typ;
l_p_dir              VARCHAR2(50);
l_output_file        VARCHAR2(20);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(20);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(4000); --BUG#3054841 Increased the size from 200 to 4000.
l_delimiter          VARCHAR(1);
l_log_dir            VARCHAR2(50);
l_log_name           VARCHAR2(20)  :='wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(20);

l_session_id         VARCHAR2(10);

l_ic_jrnl_mst_row  ic_jrnl_mst%ROWTYPE;
l_ic_adjs_jnl_row1 ic_adjs_jnl%ROWTYPE;
l_ic_adjs_jnl_row2 ic_adjs_jnl%ROWTYPE;
BEGIN

/*  Enable The Buffer
 DBMS_OUTPUT.ENABLE(1000000);
  Disable The Buffer
 DBMS_OUTPUT.DISABLE;
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

/*  Set the Wrapper file to be placed in the default working directory    */

l_log_dir  := p_dir;

/*
  Open The Wrapper File For Output And The Input File for Input.
*/
/*  dbms_output.put_line(l_log_name||' '||l_input_file||' '||l_log_dir||' '||l_p_dir);  */
l_log_handle      :=UTL_FILE.FOPEN(l_log_dir, l_log_name, 'w');
l_infile_handle   :=UTL_FILE.FOPEN(l_p_dir, l_input_file, 'r');

/*
  Loop thru flat file and call Inventory Quantities API
*/

/*  dbms_output.put_line('Start Processing');  */
UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at '
|| to_char(SYSDATE,'DD-MON-YY HH:MI:SS'));

UTL_FILE.NEW_LINE(l_log_handle);
UTL_FILE.PUT_LINE(l_log_handle, 'Input Directory  ' || l_p_dir );
UTL_FILE.PUT_LINE(l_log_handle, 'Input File       ' || l_input_file );
UTL_FILE.PUT_LINE(l_log_handle, 'Record Type      ' || l_delimiter );
UTL_FILE.PUT_LINE(l_log_handle, 'Output File      ' || l_output_file );

l_outfile_handle  :=UTL_FILE.FOPEN(l_p_dir, l_output_file, 'w');
/*  dbms_output.put_line('Opened Log file: '||l_p_dir||l_output_file);   */

LOOP
l_record_count    :=l_record_count+1;

  BEGIN
  UTL_FILE.GET_LINE(l_infile_handle, l_line);
  /*  dbms_output.put_line('LINE IS ' ||l_line);  */
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     EXIT;
  END;
  -- BEGIN BUG#1492002 Sastry
  l_return_status  := FND_API.G_RET_STS_SUCCESS;
  -- END BUG#1492002
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record ' || l_record_count );
  trans_rec.trans_type      :=TO_NUMBER(Get_Field(l_line,l_delimiter,1));
  trans_rec.item_no         :=Get_Field(l_line,l_delimiter,2);
  trans_rec.journal_no      :=Get_Field(l_line,l_delimiter,3);
  trans_rec.from_whse_code  :=Get_Field(l_line,l_delimiter,4);
  trans_rec.to_whse_code    :=Get_Field(l_line,l_delimiter,5);
  trans_rec.item_um         :=Get_Field(l_line,l_delimiter,6);
  trans_rec.item_um2        :=Get_Field(l_line,l_delimiter,7);
  trans_rec.lot_no          :=Get_Field(l_line,l_delimiter,8);
  trans_rec.sublot_no       :=Get_Field(l_line,l_delimiter,9);
  trans_rec.from_location   :=Get_Field(l_line,l_delimiter,10);
  trans_rec.to_location     :=Get_Field(l_line,l_delimiter,11);
  trans_rec.trans_qty       :=TO_NUMBER(Get_Field(l_line,l_delimiter,12));
  trans_rec.trans_qty2      :=TO_NUMBER(Get_Field(l_line,l_delimiter,13));
  trans_rec.qc_grade        :=Get_Field(l_line,l_delimiter,14);
  trans_rec.lot_status      :=Get_Field(l_line,l_delimiter,15);
  trans_rec.co_code         :=Get_Field(l_line,l_delimiter,16);
  trans_rec.orgn_code       :=Get_Field(l_line,l_delimiter,17);
  IF Get_Field(l_line,l_delimiter,18)  IS NULL
  THEN
    trans_rec.trans_date    :=SYSDATE;
  ELSE
    -- BEGIN BUG#1492002 Sastry
    -- Modified the date format from 'DDMMYYYY' to 'DDMMYYYYHH24MISS'
    -- such that the user can pass the timestamp in 24-hour format.
    -- Added code to write an appropriate error message into the log
    -- file if the user passes an invalid date format.
    BEGIN
    trans_rec.trans_date    :=TO_DATE(Get_Field(l_line,l_delimiter,18)
			      ,'DDMMYYYYHH24MISS');
	  EXCEPTION
	  WHEN OTHERS THEN
	    FND_MSG_PUB.Initialize;
    	    FND_MESSAGE.SET_NAME ('GMA', 'SY_BAD_DATEFORMAT');
            FND_MSG_PUB.Add;
         L_LOOP_CNT := 1;
		   FND_MSG_PUB.Get(
           p_msg_index     => l_loop_cnt,
           p_data          => l_data,
           p_encoded       => FND_API.G_FALSE,
           p_msg_index_out => l_dummy_cnt);
          UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
          UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
          UTL_FILE.NEW_LINE(l_outfile_handle);
          l_data := CONCAT('ERROR: ', l_data);
          UTL_FILE.PUT_LINE(l_log_handle, l_data);
          l_return_status  :='E';
    END;
    -- END BUG#1492002
  END IF;
  trans_rec.reason_code     :=Get_Field(l_line,l_delimiter,19);
  IF ((Get_Field(l_line,l_delimiter,20)) IS NULL)
  THEN
    trans_rec.user_name     :='OPM';
  ELSE
    trans_rec.user_name     :=Get_Field(l_line,l_delimiter,20);
  END IF;
  --BEGIN BUG#1962677 K.RajaSekhar
  trans_rec.journal_comment :=Get_Field(l_line,l_delimiter,21);
  --END BUG#1962677
  trans_rec.attribute1      :=Get_Field(l_line,l_delimiter,22);
  trans_rec.attribute2      :=Get_Field(l_line,l_delimiter,23);
  trans_rec.attribute3      :=Get_Field(l_line,l_delimiter,24);
  trans_rec.attribute4      :=Get_Field(l_line,l_delimiter,25);
  trans_rec.attribute5      :=Get_Field(l_line,l_delimiter,26);
  trans_rec.attribute6      :=Get_Field(l_line,l_delimiter,27);
  trans_rec.attribute7      :=Get_Field(l_line,l_delimiter,28);
  trans_rec.attribute8      :=Get_Field(l_line,l_delimiter,29);
  trans_rec.attribute9      :=Get_Field(l_line,l_delimiter,30);
  trans_rec.attribute10     :=Get_Field(l_line,l_delimiter,31);
  trans_rec.attribute11     :=Get_Field(l_line,l_delimiter,32);
  trans_rec.attribute12     :=Get_Field(l_line,l_delimiter,33);
  trans_rec.attribute13     :=Get_Field(l_line,l_delimiter,34);
  trans_rec.attribute14     :=Get_Field(l_line,l_delimiter,35);
  trans_rec.attribute15     :=Get_Field(l_line,l_delimiter,36);
  trans_rec.attribute16     :=Get_Field(l_line,l_delimiter,37);
  trans_rec.attribute17     :=Get_Field(l_line,l_delimiter,38);
  trans_rec.attribute18     :=Get_Field(l_line,l_delimiter,39);
  trans_rec.attribute19     :=Get_Field(l_line,l_delimiter,40);
  trans_rec.attribute20     :=Get_Field(l_line,l_delimiter,41);
  trans_rec.attribute21     :=Get_Field(l_line,l_delimiter,42);
  trans_rec.attribute22     :=Get_Field(l_line,l_delimiter,43);
  trans_rec.attribute23     :=Get_Field(l_line,l_delimiter,44);
  trans_rec.attribute24     :=Get_Field(l_line,l_delimiter,45);
  trans_rec.attribute25     :=Get_Field(l_line,l_delimiter,46);
  trans_rec.attribute26     :=Get_Field(l_line,l_delimiter,47);
  trans_rec.attribute27     :=Get_Field(l_line,l_delimiter,48);
  trans_rec.attribute28     :=Get_Field(l_line,l_delimiter,49);
  trans_rec.attribute29     :=Get_Field(l_line,l_delimiter,50);
  trans_rec.attribute30     :=Get_Field(l_line,l_delimiter,51);
  trans_rec.attribute_category     :=Get_Field(l_line,l_delimiter,52);
  trans_rec.acctg_unit_no   :=Get_Field(l_line,l_delimiter,53);
  trans_rec.acct_no         :=Get_Field(l_line,l_delimiter,54);
  trans_rec.move_entire_qty :=NVL(Get_Field(l_line,l_delimiter,55),'Y'); --BUG#2861715 Sastry

UTL_FILE.PUT_LINE(l_log_handle,'trans type     = '||trans_rec.trans_type);
UTL_FILE.PUT_LINE(l_log_handle,'item no        = '||trans_rec.item_no);
UTL_FILE.PUT_LINE(l_log_handle,'journal no     = '||trans_rec.journal_no);
UTL_FILE.PUT_LINE(l_log_handle,'from_whse_code = '||
				trans_rec.from_whse_code);
UTL_FILE.PUT_LINE(l_log_handle,'to_whse_code   = '||
				trans_rec.to_whse_code);
UTL_FILE.PUT_LINE(l_log_handle,'item_um        = '||trans_rec.item_um);
UTL_FILE.PUT_LINE(l_log_handle,'item_um2       = '||trans_rec.item_um2);
UTL_FILE.PUT_LINE(l_log_handle,'lot no         = '||trans_rec.lot_no);
UTL_FILE.PUT_LINE(l_log_handle,'sublot no      = '||trans_rec.sublot_no);
UTL_FILE.PUT_LINE(l_log_handle,'from_location  = '||
				trans_rec.from_location);
UTL_FILE.PUT_LINE(l_log_handle,'to_location    = '||
				trans_rec.to_location);
UTL_FILE.PUT_LINE(l_log_handle,'trans_qty      = '||trans_rec.trans_qty);
UTL_FILE.PUT_LINE(l_log_handle,'trans_qty2     = '||trans_rec.trans_qty2);
UTL_FILE.PUT_LINE(l_log_handle,'qc_grade       = '||trans_rec.qc_grade);
UTL_FILE.PUT_LINE(l_log_handle,'lot_status     = '||trans_rec.lot_status);
UTL_FILE.PUT_LINE(l_log_handle,'co code        = '||trans_rec.co_code);
UTL_FILE.PUT_LINE(l_log_handle,'orgn code      = '||trans_rec.orgn_code);
UTL_FILE.PUT_LINE(l_log_handle,'trans_date     = '||trans_rec.trans_date);
UTL_FILE.PUT_LINE(l_log_handle,'reason code    = '||trans_rec.reason_code);
UTL_FILE.PUT_LINE(l_log_handle,'user name      = '||trans_rec.user_name );
--BEGIN BUG#1962677 K.RajaSekhar
UTL_FILE.PUT_LINE(l_log_handle,'journal comment= '||trans_rec.journal_comment);
--END BUG#1962677
UTL_FILE.PUT_LINE(l_log_handle,'acctg_unit_no  = '||trans_rec.acctg_unit_no);
UTL_FILE.PUT_LINE(l_log_handle,'acct_no        = '||trans_rec.acct_no);
UTL_FILE.PUT_LINE(l_log_handle,'attribute1        = '||trans_rec.attribute1);
UTL_FILE.PUT_LINE(l_log_handle,'attribute2        = '||trans_rec.attribute2);
UTL_FILE.PUT_LINE(l_log_handle,'attribute3        = '||trans_rec.attribute3);
UTL_FILE.PUT_LINE(l_log_handle,'attribute4        = '||trans_rec.attribute4);
UTL_FILE.PUT_LINE(l_log_handle,'attribute5        = '||trans_rec.attribute5);
UTL_FILE.PUT_LINE(l_log_handle,'attribute6        = '||trans_rec.attribute6);
UTL_FILE.PUT_LINE(l_log_handle,'attribute7        = '||trans_rec.attribute7);
UTL_FILE.PUT_LINE(l_log_handle,'attribute8        = '||trans_rec.attribute8);
UTL_FILE.PUT_LINE(l_log_handle,'attribute9        = '||trans_rec.attribute9);
UTL_FILE.PUT_LINE(l_log_handle,'attribute10        = '||trans_rec.attribute10);
UTL_FILE.PUT_LINE(l_log_handle,'attribute11        = '||trans_rec.attribute11);
UTL_FILE.PUT_LINE(l_log_handle,'attribute12        = '||trans_rec.attribute12);
UTL_FILE.PUT_LINE(l_log_handle,'attribute13        = '||trans_rec.attribute13);
UTL_FILE.PUT_LINE(l_log_handle,'attribute14        = '||trans_rec.attribute14);
UTL_FILE.PUT_LINE(l_log_handle,'attribute15        = '||trans_rec.attribute15);
UTL_FILE.PUT_LINE(l_log_handle,'attribute16        = '||trans_rec.attribute16);
UTL_FILE.PUT_LINE(l_log_handle,'attribute17        = '||trans_rec.attribute17);
UTL_FILE.PUT_LINE(l_log_handle,'attribute18        = '||trans_rec.attribute18);
UTL_FILE.PUT_LINE(l_log_handle,'attribute19        = '||trans_rec.attribute19);
UTL_FILE.PUT_LINE(l_log_handle,'attribute20        = '||trans_rec.attribute20);
UTL_FILE.PUT_LINE(l_log_handle,'attribute21        = '||trans_rec.attribute21);
UTL_FILE.PUT_LINE(l_log_handle,'attribute22        = '||trans_rec.attribute22);
UTL_FILE.PUT_LINE(l_log_handle,'attribute23        = '||trans_rec.attribute23);
UTL_FILE.PUT_LINE(l_log_handle,'attribute24        = '||trans_rec.attribute24);
UTL_FILE.PUT_LINE(l_log_handle,'attribute25        = '||trans_rec.attribute25);
UTL_FILE.PUT_LINE(l_log_handle,'attribute26        = '||trans_rec.attribute26);
UTL_FILE.PUT_LINE(l_log_handle,'attribute27        = '||trans_rec.attribute27);
UTL_FILE.PUT_LINE(l_log_handle,'attribute28        = '||trans_rec.attribute28);
UTL_FILE.PUT_LINE(l_log_handle,'attribute29        = '||trans_rec.attribute29);
UTL_FILE.PUT_LINE(l_log_handle,'attribute30        = '||trans_rec.attribute30);
UTL_FILE.PUT_LINE(l_log_handle,'attribute_category        = '||trans_rec.attribute_category);
-- BEGIN BUG#1492002 Sastry
-- Perform posting only if the return status is not an error.
IF l_return_status <> 'E' THEN
-- END BUG#1492002
  /*  Allow Default Allocation Of User If NULL.   */
  IF trans_rec.user_name IS NULL THEN
     trans_rec.user_name :='OPM';
  END IF;

  GMIPAPI.Inventory_Posting
  ( p_api_version    => 3.0
  , p_init_msg_list  => FND_API.G_TRUE
  , p_commit         => FND_API.G_TRUE
  , p_validation_level  => FND_API.G_valid_level_full
  , p_qty_rec  => trans_rec
  , x_ic_jrnl_mst_row => l_ic_jrnl_mst_row
  , x_ic_adjs_jnl_row1 => l_ic_adjs_jnl_row1
  , x_ic_adjs_jnl_row2 => l_ic_adjs_jnl_row2
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


    UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
    UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
    UTL_FILE.NEW_LINE(l_outfile_handle);

    IF l_status = 'E' OR
       l_status = 'U'
    THEN
      l_data    := CONCAT('ERROR ',l_data);
    END IF;

    UTL_FILE.PUT_LINE(l_log_handle, l_data);

    /*  Update error status    */
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
-- BEGIN BUG#1492002 Sastry
END IF;
-- END BUG#1492002
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
   UTL_FILE.FCLOSE_ALL;
RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   UTL_FILE.FCLOSE_ALL;
RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   UTL_FILE.FCLOSE_ALL;
RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   UTL_FILE.FCLOSE_ALL;
RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   UTL_FILE.FCLOSE_ALL;
RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   UTL_FILE.FCLOSE_ALL;
RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   UTL_FILE.FCLOSE_ALL;
RETURN l_return_status;

WHEN OTHERS THEN
   UTL_FILE.FCLOSE_ALL;
RETURN l_return_status;

END Post;

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

/*  Determine start position   */
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

/*  Extract the field data   */
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

/*  Determine start position   */
l_string_value  :=NVL(RTRIM(LTRIM(p_substring)),' ');

RETURN l_string_value;
EXCEPTION
  WHEN OTHERS
  THEN
    RETURN ' ';

END Get_Substring;

END GMI_QUANTITY_WRP;

/
