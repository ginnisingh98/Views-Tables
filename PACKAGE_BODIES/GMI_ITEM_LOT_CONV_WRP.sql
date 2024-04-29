--------------------------------------------------------
--  DDL for Package Body GMI_ITEM_LOT_CONV_WRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_ITEM_LOT_CONV_WRP" AS
/*  $Header: GMIPILWB.pls 115.8 2000/11/28 08:56:58 pkm ship              $ */
/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Create_conv                                                           |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create an Item/Lot/Sublot UoM conversion                              |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the Create_Conv            |
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
PROCEDURE Create_Conv
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

l_return_status  :=Create_conv( p_dir
			      , p_input_file
			      , p_output_file
			      , p_delimiter
			      );

End Create_Conv;

/* +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Create_conv                                                           |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create an Item/Lot/Sublot UoM conversion                              |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the OPM                     |
 |    Inventory Item Lot/Sublot UOM Conversion Create API.                  |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called wrapper<session_id>.log in the /Out directory.                 |
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
 +==========================================================================+
  Api end of comments
*/
FUNCTION Create_Conv
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2
IS

/*  Local variables */

l_status             VARCHAR2(1);
l_return_status      VARCHAR2(1)  :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER  ;
l_dummy_cnt          NUMBER  :=0;
l_loop_cnt           NUMBER  :=0;
l_record_count       NUMBER  :=0;
l_data               VARCHAR2(2000);
item_cnv_rec         GMIGAPI.conv_rec_typ;
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
l_ic_item_cnv_row    ic_item_cnv%ROWTYPE;

BEGIN

/*  Enable The Buffer  */
/*  DBMS_OUTPUT.ENABLE(1000000); */

l_p_dir              :=p_dir;
l_input_file         :=p_input_file;
l_output_file        :=p_output_file;
l_delimiter          :=p_delimiter;
l_global_file        :=l_input_file;

/*  Obtain The SessionId To Append To wrapper File Name. */

l_session_id := USERENV('sessionid');

l_log_name  := CONCAT(l_log_name,l_session_id);
l_log_name  := CONCAT(l_log_name,'.log');

/*  Directory is now the same same as for the out file */
l_log_dir   := p_dir;

/*  Open The Wrapper File For Output And The Input File for Input. */

l_log_handle      :=UTL_FILE.FOPEN(l_log_dir, l_log_name, 'w');
l_infile_handle   :=UTL_FILE.FOPEN(l_p_dir, l_input_file, 'r');

/*  Loop thru flat file and call Item Lot/Sublot UOM Conversion create API */

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

  item_cnv_rec.item_no      :=Get_Field(l_line,l_delimiter,1);
  item_cnv_rec.lot_no       :=Get_Field(l_line,l_delimiter,2);
  item_cnv_rec.sublot_no    :=Get_Field(l_line,l_delimiter,3);
  item_cnv_rec.from_uom     :=Get_Field(l_line,l_delimiter,4);
  item_cnv_rec.to_uom       :=Get_Field(l_line,l_delimiter,5);
  IF (Get_Field(l_line,l_delimiter,6) IS NULL)
  THEN
    item_cnv_rec.type_factor:=0;
  ELSE
    item_cnv_rec.type_factor:=TO_NUMBER(Get_Field(l_line,l_delimiter,6));
  END IF;

  IF (Get_Field(l_line,l_delimiter,7) IS NULL)
  THEN
    item_cnv_rec.user_name       :='OPM';
  ELSE
    item_cnv_rec.user_name       :=Get_Field(l_line,l_delimiter,7);
  END IF;

UTL_FILE.PUT_LINE(l_log_handle,'item no    = '||item_cnv_rec.item_no );
UTL_FILE.PUT_LINE(l_log_handle,'lot no     = '||item_cnv_rec.lot_no );
UTL_FILE.PUT_LINE(l_log_handle,'sublot no  = '||item_cnv_rec.sublot_no );
UTL_FILE.PUT_LINE(l_log_handle,'from_uom   = '||item_cnv_rec.from_uom );
UTL_FILE.PUT_LINE(l_log_handle,'to_uom     = '||item_cnv_rec.to_uom );
UTL_FILE.PUT_LINE(l_log_handle,'type_factor= '||item_cnv_rec.type_factor );
UTL_FILE.PUT_LINE(l_log_handle,'op Code    = '||item_cnv_rec.user_name );

/*  dbms_output.put_line('Calling creation routine'); */

GMIPAPI.Create_Item_Lot_Conv
( p_api_version    => 3.0
, p_init_msg_list  => FND_API.G_TRUE
, p_commit         => FND_API.G_TRUE
, p_validation_level => FND_API.G_VALID_LEVEL_FULL
, p_conv_rec       => item_cnv_rec
, x_ic_item_cnv_row => l_ic_item_cnv_row
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

  /*  dbms_output.put_line('Message ' || l_data ); */

  UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
  UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
  UTL_FILE.NEW_LINE(l_outfile_handle);

  IF l_status = 'E' OR
     l_status = 'U'
  THEN
    l_data    := CONCAT('ERROR ',l_data);
  END IF;

  UTL_FILE.PUT_LINE(l_log_handle, l_data);

  /*  Update error status */
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
/*  Check if any messages generated. If so then decode and */
/*  output to error message flat file */

UTL_FILE.FCLOSE_ALL;

RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  dbms_output.put_line('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN FND_API.G_RET_STS_UNEXP_ERROR;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  dbms_output.put_line('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN FND_API.G_RET_STS_UNEXP_ERROR;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  dbms_output.put_line('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN FND_API.G_RET_STS_UNEXP_ERROR;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /*  dbms_output.put_line('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN FND_API.G_RET_STS_UNEXP_ERROR;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  dbms_output.put_line('Invalid Write Error   '|| l_global_file);*/
   UTL_FILE.FCLOSE_ALL;
   RETURN FND_API.G_RET_STS_UNEXP_ERROR;

WHEN UTL_FILE.READ_ERROR THEN
   /*  dbms_output.put_line('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN FND_API.G_RET_STS_UNEXP_ERROR;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  dbms_output.put_line('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN FND_API.G_RET_STS_UNEXP_ERROR;

WHEN OTHERS THEN
   /*  dbms_output.put_line('Other Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN FND_API.G_RET_STS_UNEXP_ERROR;

END Create_Conv;

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
/*  Local variables */
l_start         NUMBER  :=0;
l_end           NUMBER  :=0;

BEGIN

/*  Determine start position */
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

/*  Determine end position */
l_end           :=INSTR(p_line,p_delimiter,1,p_field_no);
IF l_end        = 0
THEN
  l_end         := LENGTH(p_line) + 1;
END IF;

/*  Extract the field data */
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
/*  Local variables */
l_string_value   VARCHAR2(200)  :=' ';

BEGIN

/*  Determine start position */
l_string_value  :=NVL(RTRIM(LTRIM(p_substring)),' ');

RETURN l_string_value;
EXCEPTION
  WHEN OTHERS
  THEN
    RETURN ' ';

END Get_Substring;

END GMI_ITEM_LOT_CONV_WRP;

/
