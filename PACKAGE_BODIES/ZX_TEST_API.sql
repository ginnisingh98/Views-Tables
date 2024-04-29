--------------------------------------------------------
--  DDL for Package Body ZX_TEST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TEST_API" AS
/* $Header: zxitestapispvtb.pls 120.41 2006/04/05 17:12:26 appradha ship $ */

l_ship_from_location_id NUMBER;

/* ============================================================================*
 | PROCEDURE write_message:  Write output depending of the value given in      |
 |                           l_destination                                     |
 * ===========================================================================*/
  PROCEDURE write_message(p_message IN VARCHAR2) IS
  BEGIN
    IF g_log_destination = 'LOGFILE' THEN
      arp_util_tax.debug(p_message);
    ELSIF g_log_destination = 'LOGVARIABLE' THEN
     --DBMS_OUTPUT.PUT_LINE(p_message); --Uncomment unly when testing in SQL plus.
     g_log_variable := g_log_variable ||'
'|| p_message; --Return delivery entered, due Standard avoiding CHR() function.
    END IF;
  END write_message;



/*=============================================================================*
 | PROCEDURE get_log: Retrieves the log stored in global_variable              |
 *=============================================================================*/
  PROCEDURE get_log
    (
     x_log                  OUT NOCOPY LONG
    ) IS
  BEGIN
    x_log := g_log_variable;
  END;



/* ============================================================================*
 | PROCEDURE Initialize_file : Open the file for reading.                      |
 * ===========================================================================*/
  PROCEDURE initialize_file
    (
     p_file_dir             IN  VARCHAR2,
     p_file_name            IN  VARCHAR2,
	 x_return_status        OUT NOCOPY VARCHAR2
	) IS
  l_line_max_size  BINARY_INTEGER;

  BEGIN
    l_line_max_size := 32767;
    -------------------------------
    -- Open the file to process.
    -------------------------------
    g_file := UTL_FILE.FOPEN(p_file_dir,
                             p_file_name,
                             'r',
                             l_line_max_size);
    x_return_status := 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'FAILURE';
      write_message('-------------------------------------------------------------------');
      write_message('ERROR: Not able to find the file '||p_file_name||' at '||p_file_dir);
      write_message('-------------------------------------------------------------------');


  END initialize_file;



/* ======================================================================*
 | PROCEDURE close_file : Close the current file for reading.            |
 * ======================================================================*/

  PROCEDURE close_file
    (
	 x_return_status        OUT NOCOPY VARCHAR2
	) IS
  BEGIN
    -------------------------------
    -- Close the file.
    -------------------------------
    UTL_FILE.FCLOSE_ALL;
    x_return_status := 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'FAILURE';

  END close_file;


/* ==================================================================================*
 | PROCEDURE retrieve_another_segment : Retrieves next segment(1000 chars) from line |
 * ==================================================================================*/

  PROCEDURE retrieve_another_segment
    (
      x_return_status         OUT NOCOPY VARCHAR2
	) IS
  BEGIN
    x_return_status := 'IN PROGRESS';
    ---------------------------------------------------------------------------
    -- Process the line. Line max size is 32767 characters long.
    -- Separate the line in segments of 1000 chars and process it.
    -- It does a maximum of 32 cycles.(Due limit of 32*1000 chars=32K chars)
    ---------------------------------------------------------------------------
    IF g_retrieve_another_segment = 'Y' THEN
      IF    g_line_segment_counter  = 0  THEN
        g_line_segment_string      := substr(g_line_buffer,1,1000);
        ------------------------------------------------------------------------
        -- Separates any contiguos separators ",,," with spaces " , , , "
        ------------------------------------------------------------------------
        g_line_segment_string      := replace(g_line_segment_string,g_separator||g_separator
                                                                   ,' '||g_separator||' '||g_separator||' ');
        g_line_segment_counter     := g_line_segment_counter + 1;
        g_retrieve_another_segment := 'N';
        IF g_line_segment_string IS NULL THEN
          x_return_status := 'COMPLETED';
        ELSE
          x_return_status := 'IN PROGRESS';
        END IF;

      ELSIF g_line_segment_counter <= 32 THEN
        -----------------------------------------------------------------------
        -- Separates the Line in segments of 1000 chars , append
        -- the last part of the previous line that was not processed.
        -----------------------------------------------------------------------
        g_line_segment_string      := substr(g_line_buffer,(1000*(g_line_segment_counter)+1),1000);
        g_line_segment_string      := g_last_portion_prev_string||g_line_segment_string;
        g_line_segment_counter     := g_line_segment_counter + 1;
        g_retrieve_another_segment := 'N';
        IF g_line_segment_string IS NULL THEN
          x_return_status := 'COMPLETED';
        ELSE
          x_return_status := 'IN PROGRESS';
        END IF;
      END IF;
    END IF;

  END retrieve_another_segment;


/* ===========================================================================*
 | PROCEDURE read_line : Reads a line from the file and puts it on buffer     |
 * ===========================================================================*/

  PROCEDURE read_line
     (
      x_line_suite               OUT NOCOPY VARCHAR2,
      x_line_case                OUT NOCOPY VARCHAR2,
      x_line_api                 OUT NOCOPY VARCHAR2,
      x_line_task                OUT NOCOPY VARCHAR2,
      x_line_structure           OUT NOCOPY VARCHAR2,
      x_line_counter             OUT NOCOPY NUMBER  ,
      x_line_is_end_of_case      OUT NOCOPY VARCHAR2,
      x_current_datafile_section OUT NOCOPY VARCHAR2,
	  x_return_status            OUT NOCOPY VARCHAR2
     ) IS

  l_curr                    NUMBER;
  l_next                    NUMBER;
  l_next_line_buffer        LONG;
  l_next_line_return_status VARCHAR2(2000);
  l_next_line_suite         VARCHAR2(30);
  l_next_line_case          VARCHAR2(30);
  l_next_line_string        VARCHAR2(2000);
  l_curr_line_string        VARCHAR2(2000);
  l_dummy_exception         EXCEPTION;
  l_structure               VARCHAR2(2000);

  BEGIN
    --------------------------------
    -- Initialize variables for line
    --------------------------------
    g_line_segment_counter     := 0;
    g_element_in_segment_count := 0;
    g_last_portion_prev_string := '';
    g_retrieve_another_segment := 'Y';

    -------------------------------------------------------------
    -- If is the first line to be read in the file then retrieve
    -- it from file, if not, then retrieve it from the buffer
    -- retrieved in the previous cycle.
    -- This is done to be able to determine, based on current
    -- and next lines, if the line is end of case or file.
    -------------------------------------------------------------
    IF g_initial_file_reading_flag = 'Y' THEN
      -------------------------------------------------
      -- Get a Line from the file and put it in buffer
      -------------------------------------------------
      UTL_FILE.GET_LINE ( g_file,
                          g_line_buffer);
      x_return_status := 'SUCCESS';
      g_initial_file_reading_flag := 'N';
    ELSE
      -------------------------------------------------
      -- Get the Line from the previous iteration.
      -------------------------------------------------
      g_line_buffer   := g_next_line_buffer;
      x_return_status := g_next_line_return_status;
    END IF;

    ----------------------------------------------------------------------------
    -- Identify what kind of data is being read from datafile
    -- If row is a header row, skip it, set the data section, discard current
    -- line and read next line.
    ----------------------------------------------------------------------------
    x_current_datafile_section := g_current_datafile_section;
    l_curr_line_string := substr(g_line_buffer,1,1000);
    IF substr(l_curr_line_string,1,28)     = '<DATA HEADER ROW:INPUT DATA>' THEN
      x_current_datafile_section := 'INPUT_DATA';
      g_current_datafile_section := 'INPUT_DATA';
      ---------------------------
      -- Get a Line from the file.
      ---------------------------
      UTL_FILE.GET_LINE ( g_file,
                          g_line_buffer);
      x_return_status := 'SUCCESS';
      l_curr_line_string := substr(g_line_buffer,1,1000);
    ELSIF substr(l_curr_line_string,1,38)  = '<DATA HEADER ROW:EXPECTED OUTPUT DATA>' THEN
      -----------------------------------------------------------------------------
      -- If the seccion is Output_data means ends of input data. Reading completed.
      -- as if file is over.
      -----------------------------------------------------------------------------
      x_current_datafile_section := 'OUTPUT_DATA';
      g_current_datafile_section := 'OUTPUT_DATA';
      l_curr_line_string := substr(g_line_buffer,1,1000);
      RAISE l_dummy_exception;
    END IF;

    ---------------------------------------------------------------------------
    -- Assign the counter of the lines read from file. Header rows do not count
    ---------------------------------------------------------------------------
    g_file_curr_line_counter := g_file_curr_line_counter + 1;

    ----------------------------------------------------------------
    --Identify all the basic information of the current row
    ----------------------------------------------------------------
    x_line_suite     :=           GET_NTH_ELEMENT(1,l_curr_line_string,g_separator);
    x_line_case      :=           GET_NTH_ELEMENT(2,l_curr_line_string,g_separator);
    x_line_api       :=           GET_NTH_ELEMENT(4,l_curr_line_string,g_separator);
    x_line_task      :=           GET_NTH_ELEMENT(8,l_curr_line_string,g_separator);
    x_line_structure :=           GET_NTH_ELEMENT(9,l_curr_line_string,g_separator);
    x_line_counter   := g_file_curr_line_counter;

    --------------------------------------------------------------
    -- Retreives the next line and put it on buffer for next cycle.
    --------------------------------------------------------------
    BEGIN
      -----------------------------------
      -- Get the next line from the file.
      -----------------------------------
      UTL_FILE.GET_LINE ( g_file,
                          g_next_line_buffer);
      g_next_line_return_status := 'SUCCESS';
      l_next_line_string := substr(g_next_line_buffer,1,1000);

      --------------------------------------------------------------------------
      -- If the Row is an Output Row, it will not consider this row, skip it and
      -- retrieve the next row.
      --------------------------------------------------------------------------
      IF SUBSTR(GET_NTH_ELEMENT(9,l_next_line_string,g_separator),1,16) = 'STRUCTURE_OUTPUT' THEN
        LOOP
          l_structure :=  SUBSTR(GET_NTH_ELEMENT(9,l_next_line_string,g_separator),1,16);
          IF l_structure = 'STRUCTURE_OUTPUT' THEN
            write_message('Skiping Line '||GET_NTH_ELEMENT(9,l_next_line_string,g_separator)||' not used for calculations.');
            ---------------------------
            -- Get a Line from the file.
            ---------------------------
            UTL_FILE.GET_LINE ( g_file,
                                g_next_line_buffer);
            x_return_status := 'SUCCESS';
            l_next_line_string := substr(g_next_line_buffer,1,1000);
          ELSE
            EXIT;
          END IF;
        END LOOP;
      END IF;
      --------------------------------------
      -- Retrieve the next Suite and Case
      --------------------------------------
      l_next_line_suite := GET_NTH_ELEMENT(1,l_next_line_string,g_separator);
      l_next_line_case  := GET_NTH_ELEMENT(2,l_next_line_string,g_separator);

    EXCEPTION
      WHEN l_dummy_exception THEN
        x_return_status := 'FAILURE';
      WHEN OTHERS THEN
        g_next_line_return_status := 'FAILURE';
    END;

    ---------------------------------------------------------------
    -- Determines if current line is end of Case or end of File
    ---------------------------------------------------------------
    IF (x_line_suite <> l_next_line_suite) or
       (x_line_case  <> l_next_line_case ) or
       (g_next_line_return_status = 'FAILURE') or
       (substr(l_next_line_string,1,38)  = '<DATA HEADER ROW:EXPECTED OUTPUT DATA>') THEN
        x_line_is_end_of_case := 'Y';
    ELSE
        x_line_is_end_of_case := 'N';
    END IF;
    -------------------------------------------------------------------------------------
    -- If next line is expected output set the info to end of data
    -------------------------------------------------------------------------------------
    IF (substr(l_next_line_string,1,38)  = '<DATA HEADER ROW:EXPECTED OUTPUT DATA>') THEN
      g_next_line_return_status := 'FAILURE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'FAILURE';

  END read_line;


/* ===========================================================================*
 | PROCEDURE get_next_element_in_row : From the line in buffer retrieves next |
 |                                     element                                |
 * ===========================================================================*/

  PROCEDURE get_next_element_in_row
    (
      x_element               OUT NOCOPY VARCHAR2 ,
      x_return_status         OUT NOCOPY VARCHAR2
	) IS
  l_value           VARCHAR2(4000);
  l_text            VARCHAR2(4000);
  l_start_string    NUMBER;
  l_end_string      NUMBER;
  l_separator       VARCHAR2(1);
  l_first_separator_position NUMBER;
  l_return_status   VARCHAR2(2000);

  BEGIN
    l_separator  := g_separator;
    l_first_separator_position := 0;

    -----------------------------------------------
    -- Retrieves a segment of 1000 chars if needed.
    -----------------------------------------------
    l_value := null;
    x_return_status := 'IN PROGRESS';
    retrieve_another_segment(l_return_status);
    IF l_return_status <> 'COMPLETED' THEN
      l_end_string   := instr(g_line_segment_string,l_separator,1);
      IF l_end_string > 0 THEN
         l_value               := substr(g_line_segment_string,1,l_end_string-1);
         g_line_segment_string := substr(g_line_segment_string,l_end_string+1,1001);
      ELSE
         g_retrieve_another_segment := 'Y';
         retrieve_another_segment(l_return_status);
         IF l_return_status <> 'COMPLETED' THEN
           If substr(g_line_segment_string,1,1) = l_separator THEN
             g_line_segment_string := substr(g_line_segment_string,1,1000);
           END IF;
           l_end_string   := instr(g_line_segment_string,l_separator,1);
           l_value        := substr(g_line_segment_string,1,l_end_string-1);
           g_line_segment_string := substr(g_line_segment_string,l_end_string+1,1000);
           x_return_status := 'IN PROGRESS';
         ELSE
           l_value := null;
           x_return_status := 'COMPLETED';
         END IF;
      END IF;
      g_last_portion_prev_string := g_line_segment_string;
      x_element := l_value;
      IF l_value is NULL and g_line_segment_string is not null THEN
        x_element := g_line_segment_string;
        x_return_status := 'COMPLETED';
      END IF;
    ELSE
      x_element := null;
      x_return_status := 'COMPLETED';
    END IF;
  END get_next_element_in_row;


/* ============================================================================*
 | PROCEDURE surrogate_key: Populate the surrogate keys                        |
 * ===========================================================================*/
  PROCEDURE surrogate_key (
                           p_surrogate_key IN VARCHAR2,
                           x_real_value    OUT NOCOPY NUMBER,
                           p_type          IN VARCHAR2 )
  IS

  BEGIN
    IF p_surrogate_key IS NOT NULL THEN
      ----------------------------------------------------------------
      -- Generates the real key based on the type of the surrogate key
      ----------------------------------------------------------------
      IF p_type = 'HEADER' THEN
        --SELECT zx_trx_header_id_s.nextval
        SELECT zx_transaction_s.nextval
        INTO   x_real_value
        FROM   DUAL;
        --------------------------------------------------------
        -- This value has been harcoded to test with Nilesh data
        --------------------------------------------------------
      ELSIF p_type = 'LINE' THEN
        --SELECT zx_trx_line_id_s.nextval
        SELECT zx_transaction_lines_s.nextval
        INTO   x_real_value
        FROM   DUAL;
        --------------------------------------------------------
        -- This value has been harcoded to test with Nilesh data
        --------------------------------------------------------
      ELSIF p_type = 'DIST' THEN
        --SELECT zx_trx_line_dist_id_s.nextval
        SELECT zx_sim_trx_dists_s.nextval
        INTO   x_real_value
        FROM   DUAL;
      END IF;
      write_message('~      Surrogate Key '||to_char(p_surrogate_key));
      write_message('~      has been substituted for the generated key :'
                                 ||to_char(x_real_value));
      write_message('~      of type: '||p_type);
    END IF;
  END surrogate_key;


/* ============================================================================*
 | PROCEDURE check_surrogate_key   : Checks the existence of surrogate key     |
 * ===========================================================================*/
  PROCEDURE check_surrogate_key (p_key   IN VARCHAR2,
                                 x_value OUT NOCOPY NUMBER,
                                 p_type  IN VARCHAR2)
  IS

   surrogate_key_not_found_exp   EXCEPTION;

  BEGIN
    IF p_key is not null THEN
      ------------------------------------------------------------------------
      -- Retrieves the already generated real key based on the type of the
      -- surrogate key
      ------------------------------------------------------------------------
      IF p_type = 'HEADER' THEN
         IF (g_surr_trx_id_tbl.exists(p_key)) THEN
            x_value := g_surr_trx_id_tbl(p_key);
         ELSE
            RAISE surrogate_key_not_found_exp;
         END IF;
      ELSIF p_type = 'LINE' THEN
        IF (g_surr_trx_line_id_tbl.exists(p_key)) THEN
          x_value := g_surr_trx_line_id_tbl(p_key);
        ELSE
          RAISE surrogate_key_not_found_exp;
        END IF;
      ELSIF p_type = 'DIST' THEN
        IF (g_surr_trx_dist_id_tbl.exists(p_key)) THEN
          x_value := g_surr_trx_dist_id_tbl(p_key);
        ELSE
          RAISE surrogate_key_not_found_exp;
        END IF;
      END IF;
      write_message('~           Surrogate Key '||to_char(p_key));
      write_message('~           has been substituted for the already generated key :'||to_char(x_value));
      write_message('~           of type: '||p_type);

    END IF;

    EXCEPTION
      WHEN surrogate_key_not_found_exp THEN
         write_message('~           Expected already Surrogate Key was not found');
         write_message('~           Surrogate Key '||to_char(p_key));
         write_message('~           of type: '||p_type||' not found');
         write_message('~           It will be generated...');
         surrogate_key (p_surrogate_key => p_key,
                        x_real_value    => x_value,
                        p_type          => p_type);
         Return;

  END check_surrogate_key;


/* =====================================================================================*
 | PROCEDURE break_user_key_into_segments: Breaks into segments a string for User Keys  |
 * =====================================================================================*/
  PROCEDURE break_user_key_into_segments (
                                          p_string             IN VARCHAR2,
                                          p_separator          IN VARCHAR2,
                                          x_number_of_segments OUT NOCOPY NUMBER,
                                          x_user_key_tbl       OUT NOCOPY user_keys_segments_tbl_type) IS
  l_counter            INTEGER;
  l_string             VARCHAR2(2000);
  l_separator_position NUMBER;
  l_last_segment_flag  VARCHAR2(1);
  BEGIN
    l_string := p_string;
    FOR l_counter in 1..1000 LOOP
      l_separator_position := INSTR(l_string,p_separator,1,1);
      IF nvl(l_separator_position,0) = 0 THEN
        l_last_segment_flag := 'Y';
        l_separator_position := 2000;
      END IF;
      x_user_key_tbl(l_counter) := substr(l_string,1,l_separator_position-1);
      x_number_of_segments := l_counter;
      l_string := substr(l_string,l_separator_position+1,2000);
      IF l_last_segment_flag = 'Y' THEN
        EXIT;
      END IF;
    END LOOP;
  END break_user_key_into_segments;


/* ============================================================================*
 | PROCEDURE get_user_key_id: Retrieve the ID for the User Keys                |
 |                                                                             |
 | NOTES:                                                                      |
 |        This procedure retrieves the ID for any given user key.              |
 |        The user key values come in a single string separated by a colon.    |
 |        That string has to be separated in the different elements of the user|
 |        key.                                                                 |
 |        Example for Batch Source (Actually Batch Source will be different,but|
 |                                  lets show it just as example):             |
 |                                                                             |
 |          USER KEY string for BATCH_SOURCE_ID  -->  'MyBatchName:MyOrg_id'   |
 |                                                                             |
 |          1) Break the string in 'MyBatchName' and 'MyOrg_id'                |
 |          2) Retrieve the BATCH_SOURCE_ID from RA_BATCH_SOURCES where        |
 |             name = 'MyBatchName' and org_id = 'MyOrg_id'                    |
 |          3) If User Key not found raise and error.                          |
 |                                                                             |
 |        The procedure will retrieve the User Keys for the following:         |
 |                                                                             |
 |                                                                             |
 |           BATCH_SOURCE_ID                                                   |
 |           INTERNAL_ORGANIZATION_ID                                          |
 |           APPLICATION_ID                                                    |
 |           REF_DOC_APPLICATION_ID                                            |
 |           RELATED_DOC_APPLICATION_ID                                        |
 |           APPLIED_DOC_APPLICATION_ID                                        |
 |           APPLIED_TO_APPLICATION_ID                                         |
 |           APPLIED_FROM_APPLICATION_ID                                       |
 |           ADJUSTED_DOC_APPLICATION_ID                                       |
 |           LEDGER_ID                                                         |
 |           LEGAL_ENTITY_ID                                                   |
 |           ROUNDING_SHIP_TO_PARTY_ID                                         |
 |           ROUNDING_SHIP_FROM_PARTY_ID                                       |
 |           ROUNDING_BILL_TO_PARTY_ID                                         |
 |           ROUNDING_BILL_FROM_PARTY_ID                                       |
 |           SHIP_FROM_PARTY                                                   |
 |           SHIP_TO_PARTY                                                     |
 |           POA_PARTY_ID                                                      |
 |           POO_PARTY_ID                                                      |
 |           BILL_TO_PARTY_ID                                                  |
 |           BILL_FROM_PARTY_ID                                                |
 |           MERCHANT_PARTY_ID                                                 |
 |           PAYING_PARTY_ID                                                   |
 |           OWN_HQ_PARTY_ID                                                   |
 |           SHIP_TO_LOCATION_ID                                               |
 |           SHIP_FROM_LOCATION_ID                                             |
 |           POA_LOCATION_ID                                                   |
 |           POO_LOCATION_ID                                                   |
 |           BILL_TO_LOCATION_ID                                               |
 |           BILL_FROM_LOCATION_ID                                             |
 |           PAYING_LOCATION_ID                                                |
 |           OWN_HQ_LOCATION_ID                                                |
 |           POI_LOCATION_ID                                                   |
 |           ACCOUNT_STRING                                                    |
 |           DOC_SEQ_ID                                                        |
 |           RNDG_SHIP_TO_PARTY_SITE_ID                                        |
 |           RNDG_SHIP_FROM_PARTY_SITE_ID                                      |
 |           RNDG_BILL_TO_PARTY_SITE_ID                                        |
 |           RNDG_BILL_FROM_PARTY_SITE_ID                                      |
 |           SHIP_TO_PARTY_SITE_ID                                             |
 |           SHIP_FROM_PARTY_SITE_ID                                           |
 |           POA_PARTY_SITE_ID                                                 |
 |           POO_PARTY_SITE_ID                                                 |
 |           BILL_TO_PARTY_SITE_ID                                             |
 |           BILL_FROM_PARTY_SITE_ID                                           |
 |           PAYING_PARTY_SITE_ID                                              |
 |           OWN_HQ_PARTY_SITE_ID                                              |
 |           TRADING_HQ_PARTY_SITE_ID                                          |
 |                                                                             |
 * ===========================================================================*/
  PROCEDURE get_user_key_id (
                              p_user_key_string IN VARCHAR2,
                              p_user_key_type   IN VARCHAR2,
                              x_user_key_id     OUT NOCOPY NUMBER
                              )
  IS
  l_user_key_segments_tbl user_keys_segments_tbl_type;
  l_separator             VARCHAR2(1);
  l_number_of_segments    NUMBER;
  l_varchar2_id           VARCHAR2(1000);
  l_varchar2_id1          VARCHAR2(1000);
  l_num_id                NUMBER;
  l_chrt_acct_id          hr_all_organization_units.business_group_id%type;
  l_table_name            zx_party_types.party_source_table%type;
  l_party_type            zx_party_types.party_type_code%type;
  l_party_number          hz_parties.party_number%type;
  l_name                  xle_entity_profiles.name%type;
  l_flow                  VARCHAR2(2000);

  BEGIN
      l_separator := ':';

    --------------------------------------------------------
    -- Determine the Flow of the Scenario. (P2P or OTC)
    -- From zx_evnt_cls_mappings (g_party_rec)
    --------------------------------------------------------
    l_flow := g_party_rec.prod_family_grp_code;


    IF p_user_key_string IS NOT NULL THEN
      ------------------------------------------------------
      -- Gets user key for BATCH_SOURCE_NAME
      -- the LOV used is BATCH_SOURCE_NAME_LOV
      -- and the segments in user key string are:
      --     Segment 1 is NAME
      --     Segment 2 is ORG_ID
      -- Returns BATCH SOURCE ID
      ------------------------------------------------------
      IF p_user_key_type = 'BATCH_SOURCE_NAME' THEN
        break_user_key_into_segments(p_user_key_string,
                                     l_separator,
                                     l_number_of_segments,
                                     l_user_key_segments_tbl);
        l_varchar2_id   :=           l_user_key_segments_tbl(1);
        l_num_id := to_number(l_user_key_segments_tbl(2));

        -----------------------------------------
        -- Retrieves the Batch Source Id
        -----------------------------------------
        BEGIN
          select batch_source_id
          into   x_user_key_id
          from   ra_batch_sources_all
          where  org_id = l_num_id
          and    name   = l_varchar2_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','BATCH_SOURCE_ID: '||sqlerrm);
          write_message(substr(fnd_message.get,1,200));
          FND_MSG_PUB.Add;
            x_user_key_id := -9999;
          WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','BATCH_SOURCE_ID: '||sqlerrm);
          write_message(substr(fnd_message.get,1,200));
          FND_MSG_PUB.Add;
            x_user_key_id := -9999;
        END;
      END IF;

      ------------------------------------------------------
      -- Gets user key for INTERNAL_ORGANIZATION_ID
      -- the LOV used is   ORGANIZATION_LOV
      -- and the segments in user key string are:
      --     Segment 1 is NAME
      --     Segment 2 is BUSINESS_GROUP_ID (ORG_ID)
      ------------------------------------------------------
      IF p_user_key_type = 'INTERNAL_ORGANIZATION_ID' THEN
        break_user_key_into_segments(p_user_key_string,
                                     l_separator,
                                     l_number_of_segments,
                                     l_user_key_segments_tbl);
        l_varchar2_id := l_user_key_segments_tbl(1);
        l_num_id := to_number(l_user_key_segments_tbl(2));

        -----------------------------------------
        -- Retrieves the Internal Organization Id
        -----------------------------------------
        BEGIN
          select organization_id
          into   x_user_key_id
          from   hr_all_organization_units
          where  business_group_id = l_num_id
          and    name   = l_varchar2_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','INTERNAL_ORG_ID: '||sqlerrm);
          write_message(substr(fnd_message.get,1,200));
          FND_MSG_PUB.Add;
            x_user_key_id := -9999;
          WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','INTERNAL_ORG_ID: '||sqlerrm);
          write_message(substr(fnd_message.get,1,200));
          FND_MSG_PUB.Add;
            x_user_key_id := -9999;
        END;
      END IF;

      ------------------------------------------------------
      -- Gets user key for APPLICATION_ID
      --                   REF_DOC_APPLICATION_ID
      --                   RELATED_DOC_APPLICATION_ID
      --                   APPLIED_DOC_APPLICATION_ID
      --                   APPLIED_TO_APPLICATION_ID
      --                   APPLIED_FROM_APPLICATION_ID
      --                   ADJUSTED_DOC_APPLICATION_ID
      -- the LOV used is   APPLICATION_ID_LOV
      -- and the segments in user key string are:
      --     Segment 1 is APPLICATION_NAME
      ------------------------------------------------------
      IF p_user_key_type in( 'APPLICATION_ID',
                             'REF_DOC_APPLICATION_ID',
                             'RELATED_DOC_APPLICATION_ID',
                             'APPLIED_DOC_APPLICATION_ID',
                             'APPLIED_TO_APPLICATION_ID',
                             'APPLIED_FROM_APPLICATION_ID',
                             'ADJUSTED_DOC_APPLICATION_ID')
      THEN
        break_user_key_into_segments(p_user_key_string,
                                     l_separator,
                                     l_number_of_segments,
                                     l_user_key_segments_tbl);
        l_varchar2_id := l_user_key_segments_tbl(1);

        -----------------------------------------
        -- Retrieves the Application ID
        -----------------------------------------
        BEGIN
          select application_id
          into   x_user_key_id
          from   fnd_application
          where  application_short_name = l_varchar2_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Error for '||p_user_key_type||' '||sqlerrm);
          write_message(substr(fnd_message.get,1,200));
          FND_MSG_PUB.Add;
            x_user_key_id := -9999;
          WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Error for '||p_user_key_type||' '||sqlerrm);
          write_message(substr(fnd_message.get,1,200));
          FND_MSG_PUB.Add;
            x_user_key_id := -9999;
        END;
      END IF;

      -------------------------------------------------------
      -- Gets user key for LEDGER_ID (Former SET_OF_BOOKS_ID)
      -- the LOV used is   LEDGER_ID_LOV
      -- and the segments in user key string are:
      --     Segment 1 is NAME
      -------------------------------------------------------
      IF p_user_key_type = 'LEDGER_ID' THEN
        ------------------------------------------
        -- Break the User Key String into Segments
        -- Segment 1 is NAME
        ------------------------------------------
        break_user_key_into_segments(p_user_key_string,
                                     l_separator,
                                     l_number_of_segments,
                                     l_user_key_segments_tbl);
        l_varchar2_id := l_user_key_segments_tbl(1);


        ----------------------------------------------------
        -- Retrieves the LEDGER_ID (Former SET_OF_BOOKS_ID)
        ----------------------------------------------------
        BEGIN
          select set_of_books_id
          into   x_user_key_id
          from   gl_sets_of_books
          where  name = l_varchar2_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','LEDGER_ID: '||sqlerrm);
          write_message(substr(fnd_message.get,1,200));
          FND_MSG_PUB.Add;
            x_user_key_id := -9999;
          WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','LEDGER_ID: '||sqlerrm);
          write_message(substr(fnd_message.get,1,200));
          FND_MSG_PUB.Add;
            x_user_key_id := -9999;
        END;
      END IF;

      ------------------------------------------------------
      -- Gets user key for LEGAL_ENTITY_ID
      -- the LOV used is   LEGAL_ENTITY_LOV
      -- and the segments in user key string are:
      --     Segment 1 is PARTY_NAME   (Comes from XLE_ENTITY_PROFILES.NAME)
      --     Segment 2 is PARTY_NUMBER (Comes from HZ_PARTIES.PARTY_NUMBER)
      ------------------------------------------------------

      IF p_user_key_type = 'LEGAL_ENTITY_ID' THEN
        break_user_key_into_segments(p_user_key_string,
                                     l_separator,
                                     l_number_of_segments,
                                     l_user_key_segments_tbl);

        l_name         := l_user_key_segments_tbl(1);
        --------------------------------------------------------
        --Name can be entered with Uppercase errors, so will
        --convert name to uppercaase only.
        --------------------------------------------------------
        l_name         := upper(l_name);
        If nvl(l_number_of_segments,1) > 1 then
          l_party_number := l_user_key_segments_tbl(2);
        Else
          -------------------------------------------------------
          -- It is required to receive the Party Name and Number
          -- if not raise an error.
          -------------------------------------------------------
           RAISE_APPLICATION_ERROR (-20000,'
 Error: To derive LEGAL_ENTITY_ID the Party Name and Party Number are required.
        The user Key that has been passed is:'||p_user_key_string||'
        Please review that value for LEGAL_ENTITY_ID is in the format PARTY_NAME:PARTY_NUMBER
        Review your datafile *.dat and your MASTER_SETUP.xls files');

        End If;

        -----------------------------------------
        -- Retrieves the Legal Entity ID
        -----------------------------------------
        BEGIN
          ----------------------------------------------
          -- From BTT User will select from an LOV that
          -- Shows Legal Entity Name and Party Number.
          -- The Party Name is duplicated as there
          -- is a row with the same name for Main Legal Establishment
          -- and one row same name for the Legal entity itself. The
          -- Party Number is unique and this will distinguish the rows.
          -- However xle_entity_profiles does not contain party_number. This
          -- is why is required to go and join with hz_parties.
          -- Discussed with Desh on 11-Nov-2005
          ----------------------------------------------

          select xle_ep.legal_entity_id
          into   x_user_key_id
          from   xle_entity_profiles xle_ep,
                 hz_parties          hz_pty
          where  xle_ep.party_id     = hz_pty.party_id
          and    upper(xle_ep.name)  = l_name
          and    hz_pty.party_number = l_party_number;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
            FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','LEGAL ENTITY ID: '||sqlerrm);
            write_message(substr(fnd_message.get,1,200));
            FND_MSG_PUB.Add;
            RAISE_APPLICATION_ERROR (-20000,'Error while calculating LEGAL_ENTITY_ID with user key'||p_user_key_string|| sqlerrm);

          WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
            FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','LEGAL ENTITY ID: '||sqlerrm);
            write_message(substr(fnd_message.get,1,200));
            FND_MSG_PUB.Add;
            RAISE_APPLICATION_ERROR (-20000, 'Error while calculating LEGAL_ENTITY_ID with user key'||p_user_key_string||sqlerrm);
        END;
      END IF;

      -----------------------------------------------------------
      -- Gets user key for ROUNDING_SHIP_TO_PARTY_ID
      --                   ROUNDING_SHIP_FROM_PARTY_ID
      --                   ROUNDING_BILL_TO_PARTY_ID
      --                   ROUNDING_BILL_FROM_PARTY_ID
      --                   SHIP_FROM_PARTY_ID
      --                   SHIP_TO_PARTY_ID
      --                   POA_PARTY_ID
      --                   POO_PARTY_ID
      --                   BILL_TO_PARTY_ID
      --                   BILL_FROM_PARTY_ID
      --                   MERCHANT_PARTY_ID
      --                   PAYING_PARTY_ID
      --
      --
      -- the LOV used is   HZPARTIES_POVENDORS
      -- This User Key is a special case.
      -- Depending of the mapping of ZX_EVENT_CLS_MAPPINGS and
      -- value in table ZX_PARTY_TYPES, for
      -- every user_key, will be chosen a from either
      -- HZ_PARTIES or PO_VENDORS, so we have the following:
      -- If PO_VENDORS the segments in user key are:
      --     Segment 1 is VENDOR_NAME
      --     Segment 2 is VENDOR_SITE_CODE
      --     Segment 3 is ORG_ID
      -- If HZ_PARTIES the segments in user key are:
      --     Segment 1 is PARTY_SITE_NUMBER
      --     Segment 2 is PARTY_SITE_NAME
      -----------------------------------------------------------
      IF p_user_key_type in ('ROUNDING_SHIP_TO_PARTY_ID',
                             'ROUNDING_SHIP_FROM_PARTY_ID',
                             'ROUNDING_BILL_TO_PARTY_ID',
                             'ROUNDING_BILL_FROM_PARTY_ID',
                             'SHIP_FROM_PARTY_ID',
                             'SHIP_TO_PARTY_ID',
                             'POA_PARTY_ID',
                             'POO_PARTY_ID',
                             'BILL_TO_PARTY_ID',
                             'BILL_FROM_PARTY_ID',
                             'MERCHANT_PARTY_ID'
                             )
      THEN
        break_user_key_into_segments(p_user_key_string,
                                     l_separator,
                                     l_number_of_segments,
                                     l_user_key_segments_tbl);

        BEGIN
          ---------------------------------------------
          -- RETRIEVE THE PARTY TYPE FOR THE USER KEY
          ---------------------------------------------
          IF    p_user_key_type  = 'ROUNDING_SHIP_TO_PARTY_ID'
            THEN l_party_type := g_party_rec.SHIP_TO_PARTY_TYPE;

          ELSIF p_user_key_type  = 'ROUNDING_SHIP_FROM_PARTY_ID'
            THEN l_party_type := g_party_rec.SHIP_FROM_PARTY_TYPE;

          ELSIF p_user_key_type =  'ROUNDING_BILL_TO_PARTY_ID'
            THEN l_party_type := g_party_rec.BILL_TO_PARTY_TYPE;

          ELSIF p_user_key_type  = 'ROUNDING_BILL_FROM_PARTY_ID'
            THEN l_party_type := g_party_rec.BILL_FROM_PARTY_TYPE;

          ELSIF p_user_key_type           = 'SHIP_FROM_PARTY_ID'
            THEN l_party_type := g_party_rec.SHIP_FROM_PARTY_TYPE;

          ELSIF p_user_key_type           = 'SHIP_TO_PARTY_ID'
            THEN l_party_type := g_party_rec.SHIP_TO_PARTY_TYPE;

          ELSIF p_user_key_type           = 'POA_PARTY_ID'
            THEN l_party_type := g_party_rec.POA_PARTY_TYPE;

          ELSIF p_user_key_type           = 'POO_PARTY_ID'
            THEN l_party_type := g_party_rec.POO_PARTY_TYPE;

          ELSIF p_user_key_type           = 'BILL_TO_PARTY_ID'
            THEN l_party_type := g_party_rec.BILL_TO_PARTY_TYPE;

          ELSIF p_user_key_type           = 'BILL_FROM_PARTY_ID'
            THEN l_party_type := g_party_rec.BILL_FROM_PARTY_TYPE;

          ELSIF p_user_key_type           = 'OWN_HQ_PARTY_ID'
            THEN l_party_type := g_party_rec.OWN_HQ_PARTY_TYPE;
          END IF;

          write_message('~      To Retrieve the ID for the user key of:'||p_user_key_type);
          write_message('~      we will use the l_party_type:'||l_party_type);

          BEGIN
            SELECT upper(party_source_table)
            INTO   l_table_name
            FROM   zx_party_types
            WHERE  party_type_code = l_party_type;
          EXCEPTION
            WHEN OTHERS THEN l_table_name := null;
          END;

          write_message('~      we have obtained the table:'||l_table_name||' to be used as source');

          IF  l_table_name = 'PO_VENDORS' THEN
            ------------------------------------------------------------
            -- Retrieves the user_key_id using PO_VENDORS
            ------------------------------------------------------------
            l_varchar2_id      := l_user_key_segments_tbl(1);

            select vendor_id
            into   x_user_key_id
            from   ap_suppliers
            where  vendor_name = l_varchar2_id;

          ELSIF l_table_name = 'HZ_PARTIES' THEN
            ------------------------------------------------------------
            -- Retrieves the user_key_id using HZ_PARTIES.
            -- We have two cases. User Key with one Value and Two Values
            -- If we have User Key with One Value:
            --   Segment1 => Party Number (From HZ_PARTIES.PARTY_NUMBER)
            -- If we have User Key with Two Values:
            --  Segment1 => Name         (From XLE_ENTITY_PROFILES.NAME)
            --  Segment2 => Party Number (From HZ_PARTIES.PARTY_NUMBER)
            ------------------------------------------------------------
            If nvl(l_number_of_segments,1) = 1 then
               l_varchar2_id := l_user_key_segments_tbl(1);
            Else
               l_varchar2_id := l_user_key_segments_tbl(2);
			End if;

            BEGIN
              Select party_id
              into   x_user_key_id
              from   hz_parties
              where  party_number = l_varchar2_id;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              select party_id
              into   x_user_key_id
              from   hz_parties
              where  party_name = l_varchar2_id;
            END;
          ELSE
            RAISE NO_DATA_FOUND;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            RAISE_APPLICATION_ERROR (-20000,'
NO_DATA_FOUND Error: To derive '||p_user_key_type||' the Party Number from HZ_PARTIES is required.
        The user Key that has been passed is:'||p_user_key_string||'
        Please review that value passed is the format PARTY_NUMBER or PARTY_NAME:PARTY_NUMBER
        and this value exists in table HZ_PARTIES.
        Review your datafile *.dat and your MASTER_SETUP.xls files. The sqlerrm found is
		'||sqlerrm);


          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR (-20000,'
OTHERS Error: To derive '||p_user_key_type||' the Party Number from HZ_PARTIES is required.
        The user Key that has been passed is:'||p_user_key_string||'
        Please review that value passed is the format PARTY_NUMBER or PARTY_NAME:PARTY_NUMBER
        and this value exists in table HZ_PARTIES.
        Review your datafile *.dat and your MASTER_SETUP.xls files. The sqlerrm found is
		'||sqlerrm);
        END;
      END IF;


      ------------------------------------------------------
      -- Gets user key for SHIP_TO_LOCATION_ID
      -- the LOV used is   HR_LOCATIONS for P2P
      -- the LOV used is   HZ_LOCATIONS for O2C
      -- and the segments in user key string are:
      --     Segment 1 is LOCATION_CODE
      --     Segment 2 is BUSINESS_GROUP_ID
      -- Note: We will use only segment1 we expect user to enter unique value.
      ------------------------------------------------------

      IF p_user_key_type = 'SHIP_TO_LOCATION_ID' THEN
        -----------------------------------------
        -- Retrieves the SHIP_TO_LOCATION_ID
        -----------------------------------------
        write_message('~      The flow to Calculate Ship to Location is:'||l_flow);
        IF l_flow = 'P2P' THEN
          write_message('~      Table to get Ship to Location is HR_LOCATIONS');
          break_user_key_into_segments(p_user_key_string,
                                       l_separator,
                                       l_number_of_segments,
                                       l_user_key_segments_tbl);
          l_varchar2_id := l_user_key_segments_tbl(1);
          If nvl(l_number_of_segments,1) > 1 then
            l_num_id := to_number(l_user_key_segments_tbl(2));
          End If;
          -------------------------------------------------------
          -- P2P Retrieve SHIP_TO_LOCATION_ID from HR_LOCATIONS
          -------------------------------------------------------
          BEGIN
            IF l_num_id is not null THEN
              select ship_to_location_id
              into   x_user_key_id
              from   hr_locations
              where  location_code = l_varchar2_id
              and    business_group_id = l_num_id;
            ELSE
              select ship_to_location_id
              into   x_user_key_id
              from   hr_locations
              where  location_code = l_varchar2_id
              and    business_group_id is null;
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              ----------------------------------------------------------------------
              -- If no location is found, error out.
              ----------------------------------------------------------------------
              write_message('No location was found. Please review your data');
              FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
              FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','SHIP TO LOCATION ID: '||sqlerrm);
              write_message(substr(fnd_message.get,1,200));
              FND_MSG_PUB.Add;

            WHEN TOO_MANY_ROWS THEN
              ----------------------------------------------------------------------
              -- If multiple locations are found, error out.
              ----------------------------------------------------------------------
              write_message('Multiple locations were found. Please review your data');
              FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
              FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','SHIP TO LOCATION ID: '||sqlerrm);
              write_message(substr(fnd_message.get,1,200));
              FND_MSG_PUB.Add;

            WHEN OTHERS THEN
              ----------------------------------------------------------------------
              --If other issue, error out.
              ----------------------------------------------------------------------
              write_message('Not able to retrieve the Location. Please review your data');
              FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
              FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','SHIP TO LOCATION ID: '||sqlerrm);
              write_message(substr(fnd_message.get,1,200));
              FND_MSG_PUB.Add;
          END;

        ELSIF l_flow = 'O2C' THEN
          write_message('~      Table to get Ship to Location is HZ_LOCATIONS');
          break_user_key_into_segments(p_user_key_string,
                                       l_separator,
                                       l_number_of_segments,
                                       l_user_key_segments_tbl);
          l_varchar2_id := l_user_key_segments_tbl(1);
          If nvl(l_number_of_segments,1) > 1 then
            l_varchar2_id1 := l_user_key_segments_tbl(2);
          End If;
          -------------------------------------------------------
          -- O2C Retrieve SHIP_TO_LOCATION_ID from HZ_LOCATIONS
          -------------------------------------------------------
          BEGIN
            select location_id
            into   x_user_key_id
            from   hz_locations
            where  ltrim(rtrim(upper(address1))) = ltrim(rtrim(upper(l_varchar2_id)))
            and    upper(city)                   = upper(l_varchar2_id1);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              --------------------------------------------------------------------
              -- If Location not found, search location by the short description
              --------------------------------------------------------------------
              BEGIN
                select location_id
                into   x_user_key_id
                from   hz_locations
                where  short_description  = l_varchar2_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  --------------------------------------------------------------------
                  -- If location not found, error out
                  --------------------------------------------------------------------
                  write_message(' No Data Found. Location cannot be found. Please review your data');
                  FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
                  FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','SHIP TO LOCATION ID: '||sqlerrm);
                  write_message(substr(fnd_message.get,1,200));
                  FND_MSG_PUB.Add;

                WHEN OTHERS THEN
                  --------------------------------------------------------------------
                  -- If location not found, error out
                  --------------------------------------------------------------------
                  write_message(' Others error. Location cannot be found. Please review your data');
                  FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
                  FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','SHIP TO LOCATION ID: '||sqlerrm);
                  write_message(substr(fnd_message.get,1,200));
                  FND_MSG_PUB.Add;

              END;

            WHEN TOO_MANY_ROWS THEN
              ----------------------------------------------------------------------
              -- If multiple locations are found, the error out.
              ----------------------------------------------------------------------
              write_message('Multiple locations were found. Please review your data');
              FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
              FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','SHIP TO LOCATION ID: '||sqlerrm);
              write_message(substr(fnd_message.get,1,200));
              FND_MSG_PUB.Add;

            WHEN OTHERS THEN
              ----------------------------------------------------------------------
              -- In multiple locations are found, the error out.
              ----------------------------------------------------------------------
              write_message('Multiple locations were found. Please review your data');
              FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
              FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','SHIP TO LOCATION ID: '||sqlerrm);
              write_message(substr(fnd_message.get,1,200));
              FND_MSG_PUB.Add;

          END;
        END IF;
      END IF;

      ------------------------------------------------------
      -- Gets user key for SHIP_FROM_LOCATION_ID
      --                   POA_LOCATION_ID
      --                   POO_LOCATION_ID
      --                   BILL_TO_LOCATION_ID
      --                   BILL_FROM__LOCATION_ID
      --                   PAYING_LOCATION_ID
      --                   POI_LOCATION_ID
      -- the LOV used is   HR_LOCATIONS_LOV
      -- and the segments in user key string are:
      --     Segment 1 is LOCATION_CODE
      --     Segment 2 is BUSINESS_GROUP_ID
      ------------------------------------------------------
      IF p_user_key_type in ('SHIP_FROM_LOCATION_ID',
                             'POA_LOCATION_ID',
                             'POO_LOCATION_ID',
                             'BILL_TO_LOCATION_ID',
                             'BILL_FROM_LOCATION_ID'
                             ) THEN
        break_user_key_into_segments(p_user_key_string,
                                     l_separator,
                                     l_number_of_segments,
                                     l_user_key_segments_tbl);

        l_varchar2_id := l_user_key_segments_tbl(1);
        If nvl(l_number_of_segments,1) > 1 then
          l_num_id := to_number(l_user_key_segments_tbl(2));
        End If;
        -----------------------------------------
        -- Retrieves the id for the user key.
        -----------------------------------------
        BEGIN
          IF l_num_id is not null THEN
            select location_id
            into   x_user_key_id
            from   hr_locations
            where  location_code = l_varchar2_id
            and    business_group_id = l_num_id;
          ELSE
            select location_id
            into   x_user_key_id
            from   hr_locations
            where  location_code = l_varchar2_id
            and    business_group_id is null;
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

              RAISE_APPLICATION_ERROR (-20000,'
NO_DATA_FOUND Error: To derive '||p_user_key_type||' the Location Code or Location Code and Business Group from HR_LOCATIONS is required.
        The user Key that has been passed is:'||p_user_key_string||'
        Please review that value passed is the format LOCATION_CODE or LOCATION_CODE:BUSINESS_GROUP_ID and
        this value exists in table HR_LOCATIONS.
        Review your datafile *.dat, your Spreadsheet and MASTER_SETUP.xls files. The sqlerrm found is
		'||sqlerrm);



          WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR (-20000,'
OTHERS Error: To derive '||p_user_key_type||' the Location Code or Location Code and Business Group from HR_LOCATIONS is required.
        The user Key that has been passed is:'||p_user_key_string||'
        Please review that value passed is the format LOCATION_CODE or LOCATION_CODE:BUSINESS_GROUP_ID and
        this value exists in table HR_LOCATIONS.
        Review your datafile *.dat, your Spreadsheet and MASTER_SETUP.xls files. The sqlerrm found is
		'||sqlerrm);


        END;
      END IF;

      -------------------------------------------------------
      -- Gets user key for ACCOUNT_STRING
      -- the LOV used is   NONE.
      -- and the segments in user key string are:
      --     Standard Segments used in the Account String.
      -- Notes:
      --   This is a special case, there is no LOV associated
      --   but user will populate the account string in the
      --   field manually. Example '001.3456.14412.32412.001'
      --   We use the standard APIs to obtain the CCID
      --   The column for CCID will be populated, and the
      --   column with the ACCOUNT_STRING will remain with
      --   its value.
      -------------------------------------------------------
      IF p_user_key_type = 'ACCOUNT_STRING' THEN
        -----------------------------------------
        -- Retrieves the ACCOUNT_CCID
        -----------------------------------------
        BEGIN

          select chart_of_accounts_id
          into   l_chrt_acct_id
          from   gl_sets_of_books
          where  set_of_books_id = g_suite_rec_tbl.ledger_id(1);

          x_user_key_id := FND_FLEX_EXT.GET_CCID('SQLGL','GL#',l_chrt_acct_id,sysdate,p_user_key_string);

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ACCOUNT_CCID: '||sqlerrm);
          write_message(substr(fnd_message.get,1,200));
          FND_MSG_PUB.Add;
            x_user_key_id := -9999;
          WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ACCOUNT_CCID: '||sqlerrm);
          write_message(substr(fnd_message.get,1,200));
          FND_MSG_PUB.Add;
            x_user_key_id := -9999;
        END;
      END IF;


      ------------------------------------------------------
      -- Gets user key for DOC_SEQ_ID
      -- the LOV used is   DOC_SEQ_ID_LOV
      -- and the segments in user key string are:
      --     Segment 1 is NAME
      ------------------------------------------------------
      IF p_user_key_type = 'DOC_SEQ_ID' THEN
      ----------------------------------------------------
        break_user_key_into_segments(p_user_key_string,
                                     l_separator,
                                     l_number_of_segments,
                                     l_user_key_segments_tbl);
        l_varchar2_id := l_user_key_segments_tbl(1);

        ---------------------------------------------
        -- Retrieves the DOC_SEQ_ID
        ---------------------------------------------
        BEGIN
          select doc_sequence_id
          into   x_user_key_id
          from   FND_DOCUMENT_SEQUENCES
          where  name  = l_varchar2_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','DOC SEQ ID: '||sqlerrm);
          write_message(substr(fnd_message.get,1,200));
          FND_MSG_PUB.Add;
            x_user_key_id := -9999;
          WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','DOC SEQ ID: '||sqlerrm);
          write_message(substr(fnd_message.get,1,200));
          FND_MSG_PUB.Add;
            x_user_key_id := -9999;
        END;
      END IF;

      -----------------------------------------------------------
      -- Gets user key for RNDG_SHIP_TO_PARTY_SITE_ID
      --                   RNDG_SHIP_FROM_PARTY_SITE_ID
      --                   RNDG_BILL_TO_PARTY_SITE_ID
      --                   RNDG_BILL_FROM_PARTY_SITE_ID
      --                   SHIP_TO_PARTY_SITE_ID
      --                   SHIP_FROM_PARTY_SITE_ID
      --                   POA_PARTY_SITE_ID
      --                   POO_PARTY_SITE_ID
      --                   BILL_TO_PARTY_SITE_ID
      --                   BILL_FROM_PARTY_SITE_ID
      --                   PAYING_PARTY_SITE_ID
      --                   OWN_HQ_PARTY_SITE_ID
      --                   TRADING_HQ_PARTY_SITE_ID
      --
      --
      -- the LOV used is   HZPARTYSITES_POVENDORSITES
      -- This User Key is a special case.
      -- Depending of the mapping of ZX_EVENT_CLS_MAPPINGS and
      -- value in table ZX_PARTY_TYPES, for
      -- every user_key, will be chosen a from either
      -- HZ_PARTY_SITES or PO_VENDOR_SITES, so we have the following:
      -- If PO_VENDOR_SITES the segments in user key are:
      --     Segment 1 is VENDOR_NAME
      --     Segment 2 is VENDOR_SITE_CODE
      --     Segment 3 is ORG_ID
      -- If HZ_PARTY_SITES the segments in user key are:
      --     Segment 1 is PARTY_SITE_NUMBER
      --     Segment 2 is PARTY_SITE_NAME
      -----------------------------------------------------------
      IF p_user_key_type in ('RNDG_SHIP_TO_PARTY_SITE_ID',
                             'RNDG_SHIP_FROM_PARTY_SITE_ID',
                             'RNDG_BILL_TO_PARTY_SITE_ID',
                             'RNDG_BILL_FROM_PARTY_SITE_ID',
                             'SHIP_TO_PARTY_SITE_ID',
                             'SHIP_FROM_PARTY_SITE_ID',
                             'POA_PARTY_SITE_ID',
                             'POO_PARTY_SITE_ID',
                             'BILL_TO_PARTY_SITE_ID',
                             'BILL_FROM_PARTY_SITE_ID',
                             'TRADING_HQ_PARTY_SITE_ID'
                             )
      THEN
        break_user_key_into_segments(p_user_key_string,
                                     l_separator,
                                     l_number_of_segments,
                                     l_user_key_segments_tbl);
        --Bug 4306914. The Composite Key was simpified to single key.
       /* IF l_number_of_segments = 3 THEN
          l_varchar2_id    :=           l_user_key_segments_tbl(1);
          l_varchar2_id1   :=           l_user_key_segments_tbl(2);
          l_num_id         := to_number(l_user_key_segments_tbl(3));
        ELSE
          l_varchar2_id    :=           l_user_key_segments_tbl(1);
        END IF;*/

          l_varchar2_id    :=           l_user_key_segments_tbl(1);

        ---------------------------------------------
        -- Retrieves the RNDG_SHIP_TO_PARTY_SITE_ID
        ---------------------------------------------
        BEGIN
          ---------------------------------------------
          -- RETRIEVE THE PARTY TYPE FOR THE USER KEY
          ---------------------------------------------
          IF    p_user_key_type           = 'RNDG_SHIP_TO_PARTY_SITE_ID'
            THEN l_party_type := g_party_rec.ship_to_pty_site_type;
          ELSIF p_user_key_type           = 'RNDG_SHIP_FROM_PARTY_SITE_ID'
            THEN l_party_type := g_party_rec.ship_from_pty_site_type;
          ELSIF p_user_key_type           = 'RNDG_BILL_TO_PARTY_SITE_ID'
            THEN l_party_type := g_party_rec.bill_to_pty_site_type;
          ELSIF p_user_key_type           = 'RNDG_BILL_FROM_PARTY_SITE_ID'
            THEN l_party_type := g_party_rec.bill_from_pty_site_type;
          ELSIF p_user_key_type           = 'SHIP_TO_PARTY_SITE_ID'
            THEN l_party_type := g_party_rec.ship_to_pty_site_type;
          ELSIF p_user_key_type           = 'SHIP_FROM_PARTY_SITE_ID'
            THEN l_party_type := g_party_rec.ship_from_pty_site_type;
          ELSIF p_user_key_type           = 'POA_PARTY_SITE_ID'
            THEN l_party_type := g_party_rec.poa_pty_site_type;
          ELSIF p_user_key_type           = 'POO_PARTY_SITE_ID'
            THEN l_party_type := g_party_rec.poo_pty_site_type;
          ELSIF p_user_key_type           = 'BILL_TO_PARTY_SITE_ID'
            THEN l_party_type := g_party_rec.bill_to_pty_site_type;
          ELSIF p_user_key_type           = 'BILL_FROM_PARTY_SITE_ID'
            THEN l_party_type := g_party_rec.bill_from_pty_site_type;
          ELSIF p_user_key_type           = 'TRADING_HQ_PARTY_SITE_ID'
            THEN l_party_type := g_party_rec.trad_hq_party_type;
          END IF;

          BEGIN
            select upper(party_source_table)
            into   l_table_name
            from   zx_party_types
            where  party_type_code = l_party_type;
          EXCEPTION
            WHEN OTHERS THEN l_table_name := null;
          END;

          BEGIN
            IF l_table_name = 'HZ_PARTY_SITES' THEN  -- Verify if it is PARTIES or PARTY_SITES
              ---------------------------------------------------
              -- Retrieves the user_key_id using HZ_PARTY_SITES
              ---------------------------------------------------
              write_message('~      Retrieves the user_key_id using HZ_PARTY_SITES');
              begin

              select party_site_id
              into   x_user_key_id
              from   hz_party_sites
              where  party_site_number  = l_varchar2_id ;
              exception
                WHEN no_data_found then
                   select party_site_id
                   into   x_user_key_id
                   from   po_vendor_sites
                   where  vendor_site_code = l_varchar2_id;

                   select location_id
                   into   l_ship_from_location_id
                   from   hz_party_sites
                   where  party_site_id=x_user_key_id;
              end;
            ELSE
              ---------------------------------------------------
              -- Retrieves the user_key_id using PO_VENDOR_SITES
              ---------------------------------------------------
              write_message('~      Retrieves the user_key_id using PO_VENDOR_SITES');
              select vendor_site_id
              into   x_user_key_id
              from   po_vendor_sites_all
              where    vendor_site_code = l_varchar2_id;
              --Bug 4306914. The Composite Key was simpified to single key.
              /*where  vendor_id        = to_number(l_varchar2_id)
              and    vendor_site_code = l_varchar2_id1
              and    org_id           = l_num_id;*/
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
              FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Error for'||p_user_key_type||' '||sqlerrm);
          write_message(substr(sqlerrm,1,200));
              FND_MSG_PUB.Add;
                x_user_key_id := -9999;

            WHEN TOO_MANY_ROWS THEN
              FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
              FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Error for'||
               p_user_key_type|| ' the vendor_site_code'|| l_varchar2_id1 ||
               'is not unique in table PO_VENDOR_SITES_ALL. '||sqlerrm);
          write_message(substr(sqlerrm,1,200));
              FND_MSG_PUB.Add;
                x_user_key_id := -9999;
            WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
              FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Error for'||p_user_key_type||' '||sqlerrm);
          write_message(substr(sqlerrm,1,200));
              FND_MSG_PUB.Add;
                x_user_key_id := -9999;
              FND_MSG_PUB.Add;
                x_user_key_id := -9999;
          END;
        END;
      END IF;
      write_Message('~      The ID retrieved from USER KEY value above is: '||to_char(x_user_key_id));
    ELSE
      x_user_key_id := NULL;
    END IF;
  END get_user_key_id;


/* ============================================================================*
 | PROCEDURE insert_into_rev_dist_lines_gt : Logic to Insert into Global       |
 |                                           Temporary Table                   |
 |                                           ZX_REVERSE_DIST_GT                |
 * ===========================================================================*/

 PROCEDURE insert_into_rev_dist_lines_gt(p_transaction_id IN NUMBER) IS

 l_int_org_id  NUMBER;

 BEGIN

     INSERT INTO ZX_REVERSE_DIST_GT
                ( internal_organization_id,
                  reversing_appln_id,
                  reversing_entity_code,
                  reversing_evnt_cls_code,
                  reversing_trx_level_type,
                  reversing_trx_id,
                  reversing_trx_line_id,
                  reversing_trx_line_dist_id,
                  reversing_tax_line_id,
                  reversed_appln_id,
                  reversed_entity_code,
                  reversed_evnt_cls_code,
                  reversed_trx_level_type,
                  reversed_trx_id,
                  reversed_trx_line_id,
                  reversed_trx_line_dist_id,
                  FIRST_PTY_ORG_ID         ,
                  reversed_tax_line_id )
           SELECT g_transaction_rec.internal_organization_id,
                  application_id,
                  entity_code,
                  event_class_code,
                  'DISTRIBUTION',
                  trx_id,
                  trx_line_id,
                  trx_line_dist_id,
                  tax_line_id,
                  application_id,
                  entity_code,
                  event_class_code,
                  'DISTRIBUTION',
                  trx_id,
                  trx_line_id,
                  trx_line_dist_id,
                  g_transaction_rec.first_pty_org_id,
                  tax_line_id
            FROM  zx_rec_nrec_dist
           WHERE  trx_id = p_transaction_id;

  END insert_into_rev_dist_lines_gt;


/* ======================================================================*
 | PROCEDURE put_data_in_party_rec : Put party_rec data in the a record  |
 * ======================================================================*/

  PROCEDURE put_data_in_party_rec(p_header_row IN NUMBER) IS
  BEGIN
    IF g_suite_rec_tbl.application_id(p_header_row)   IS NOT NULL AND
       g_suite_rec_tbl.entity_code(p_header_row)      IS NOT NULL AND
       g_suite_rec_tbl.event_class_code(p_header_row) IS NOT NULL THEN
    SELECT
      SHIP_TO_PARTY_TYPE ,
      SHIP_FROM_PARTY_TYPE,
      POA_PARTY_TYPE,
      POO_PARTY_TYPE,
      PAYING_PARTY_TYPE,
      OWN_HQ_PARTY_TYPE,
      TRAD_HQ_PARTY_TYPE,
      POI_PARTY_TYPE,
      POD_PARTY_TYPE,
      BILL_TO_PARTY_TYPE,
      BILL_FROM_PARTY_TYPE,
      TTL_TRNS_PARTY_TYPE,
      MERCHANT_PARTY_TYPE,
      SHIP_TO_PTY_SITE_TYPE,
      SHIP_FROM_PTY_SITE_TYPE,
      POA_PTY_SITE_TYPE,
      POO_PTY_SITE_TYPE,
      PAYING_PTY_SITE_TYPE,
      OWN_HQ_PTY_SITE_TYPE,
      TRAD_HQ_PTY_SITE_TYPE,
      POI_PTY_SITE_TYPE,
      POD_PTY_SITE_TYPE,
      BILL_TO_PTY_SITE_TYPE,
      BILL_FROM_PTY_SITE_TYPE,
      TTL_TRNS_PTY_SITE_TYPE,
      PROD_FAMILY_GRP_CODE
    INTO
      g_party_rec.SHIP_TO_PARTY_TYPE,
      g_party_rec.SHIP_FROM_PARTY_TYPE,
      g_party_rec.POA_PARTY_TYPE,
      g_party_rec.POO_PARTY_TYPE,
      g_party_rec.PAYING_PARTY_TYPE,
      g_party_rec.OWN_HQ_PARTY_TYPE,
      g_party_rec.TRAD_HQ_PARTY_TYPE,
      g_party_rec.POI_PARTY_TYPE,
      g_party_rec.POD_PARTY_TYPE,
      g_party_rec.BILL_TO_PARTY_TYPE,
      g_party_rec.BILL_FROM_PARTY_TYPE,
      g_party_rec.TTL_TRNS_PARTY_TYPE,
      g_party_rec.MERCHANT_PARTY_TYPE,
      g_party_rec.SHIP_TO_PTY_SITE_TYPE,
      g_party_rec.SHIP_FROM_PTY_SITE_TYPE,
      g_party_rec.POA_PTY_SITE_TYPE,
      g_party_rec.POO_PTY_SITE_TYPE,
      g_party_rec.PAYING_PTY_SITE_TYPE,
      g_party_rec.OWN_HQ_PTY_SITE_TYPE,
      g_party_rec.TRAD_HQ_PTY_SITE_TYPE,
      g_party_rec.POI_PTY_SITE_TYPE,
      g_party_rec.POD_PTY_SITE_TYPE,
      g_party_rec.BILL_TO_PTY_SITE_TYPE,
      g_party_rec.BILL_FROM_PTY_SITE_TYPE,
      g_party_rec.TTL_TRNS_PTY_SITE_TYPE,
      g_party_rec.PROD_FAMILY_GRP_CODE
    FROM
      zx_evnt_cls_mappings
    WHERE
      application_id       = g_suite_rec_tbl.application_id(p_header_row)
      and entity_code      = g_suite_rec_tbl.entity_code(p_header_row)
      and event_class_code = g_suite_rec_tbl.event_class_code(p_header_row) ;
    END IF;
    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','TOO MANY ROWS PARTY_REC: '||sqlerrm);
        write_message(substr(fnd_message.get,1,200));
        FND_MSG_PUB.Add;
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','NO DATA FOUND PARTY_REC: '||sqlerrm);
        write_message(substr(fnd_message.get,1,200));
        FND_MSG_PUB.Add;
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','OTHERS PARTY_REC: '||sqlerrm);
        write_message(substr(fnd_message.get,1,200));
        FND_MSG_PUB.Add;
  END put_data_in_party_rec;


/* ================================================================================*
 | PROCEDURE insert_data_trx_headers_gt : Inserts a row in zx_trx_headers_gt|
 * ================================================================================*/

  PROCEDURE insert_data_trx_headers_gt(p_row_id IN NUMBER)
  IS
  BEGIN
  write_message('Inserting into zx_trx_headers_gt rec_tbl_row:'||to_char(p_row_id));
    ----------------------------------------------
    -- INSERT INTO TABLE zx_trx_headers_gt
    ----------------------------------------------

    INSERT INTO zx_trx_headers_gt(
      INTERNAL_ORGANIZATION_ID            ,
      INTERNAL_ORG_LOCATION_ID            ,
      APPLICATION_ID                      ,
      ENTITY_CODE                         ,
      EVENT_CLASS_CODE                    ,
      EVENT_TYPE_CODE                     ,
      TRX_ID                              ,
      TRX_DATE                            ,
      TRX_DOC_REVISION                    ,
      LEDGER_ID                           ,
      TRX_CURRENCY_CODE                   ,
      CURRENCY_CONVERSION_DATE            ,
      CURRENCY_CONVERSION_RATE            ,
      CURRENCY_CONVERSION_TYPE            ,
      MINIMUM_ACCOUNTABLE_UNIT            ,
      PRECISION                           ,
      LEGAL_ENTITY_ID                     ,
      ROUNDING_SHIP_TO_PARTY_ID           ,
      ROUNDING_SHIP_FROM_PARTY_ID         ,
      ROUNDING_BILL_TO_PARTY_ID           ,
      ROUNDING_BILL_FROM_PARTY_ID         ,
      RNDG_SHIP_TO_PARTY_SITE_ID          ,
      RNDG_SHIP_FROM_PARTY_SITE_ID        ,
      RNDG_BILL_TO_PARTY_SITE_ID          ,
      RNDG_BILL_FROM_PARTY_SITE_ID        ,
      ESTABLISHMENT_ID                    ,
      RECEIVABLES_TRX_TYPE_ID             ,
      RELATED_DOC_APPLICATION_ID          ,
      RELATED_DOC_ENTITY_CODE             ,
      RELATED_DOC_EVENT_CLASS_CODE        ,
      RELATED_DOC_TRX_ID                  ,
      RELATED_DOC_NUMBER                  ,
      RELATED_DOC_DATE                    ,
      DEFAULT_TAXATION_COUNTRY            ,
      QUOTE_FLAG                          ,
      CTRL_TOTAL_HDR_TX_AMT               ,
      TRX_NUMBER                          ,
      TRX_DESCRIPTION                     ,
      TRX_COMMUNICATED_DATE               ,
      BATCH_SOURCE_ID                     ,
      BATCH_SOURCE_NAME                   ,
      DOC_SEQ_ID                          ,
      DOC_SEQ_NAME                        ,
      DOC_SEQ_VALUE                       ,
      TRX_DUE_DATE                        ,
      TRX_TYPE_DESCRIPTION                ,
      DOCUMENT_SUB_TYPE                   ,
      SUPPLIER_TAX_INVOICE_NUMBER         ,
      SUPPLIER_TAX_INVOICE_DATE           ,
      SUPPLIER_EXCHANGE_RATE              ,
      TAX_INVOICE_DATE                    ,
      TAX_INVOICE_NUMBER                  ,
      FIRST_PTY_ORG_ID                    ,
      TAX_EVENT_CLASS_CODE                ,
      TAX_EVENT_TYPE_CODE                 ,
      DOC_EVENT_STATUS                    ,
      RDNG_SHIP_TO_PTY_TX_PROF_ID         ,
      RDNG_SHIP_FROM_PTY_TX_PROF_ID       ,
      RDNG_BILL_TO_PTY_TX_PROF_ID         ,
      RDNG_BILL_FROM_PTY_TX_PROF_ID       ,
      RDNG_SHIP_TO_PTY_TX_P_ST_ID         ,
      RDNG_SHIP_FROM_PTY_TX_P_ST_ID       ,
      RDNG_BILL_TO_PTY_TX_P_ST_ID         ,
      RDNG_BILL_FROM_PTY_TX_P_ST_ID       ,
      VALIDATION_CHECK_FLAG               ,
      PORT_OF_ENTRY_CODE                  )
      VALUES
      (
      g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(p_row_id)            ,
      g_suite_rec_tbl.INTERNAL_ORG_LOCATION_ID(p_row_id)            ,
      g_suite_rec_tbl.APPLICATION_ID(p_row_id)                      ,
      g_suite_rec_tbl.ENTITY_CODE(p_row_id)                         ,
      g_suite_rec_tbl.EVENT_CLASS_CODE(p_row_id)                    ,
      g_suite_rec_tbl.EVENT_TYPE_CODE(p_row_id)                     ,
      g_suite_rec_tbl.TRX_ID(p_row_id)                              ,
      g_suite_rec_tbl.TRX_DATE(p_row_id)                            ,
      g_suite_rec_tbl.TRX_DOC_REVISION(p_row_id)                    ,
      g_suite_rec_tbl.LEDGER_ID(p_row_id)                           ,
      g_suite_rec_tbl.TRX_CURRENCY_CODE(p_row_id)                   ,
      g_suite_rec_tbl.CURRENCY_CONVERSION_DATE(p_row_id)            ,
      g_suite_rec_tbl.CURRENCY_CONVERSION_RATE(p_row_id)            ,
      g_suite_rec_tbl.CURRENCY_CONVERSION_TYPE(p_row_id)            ,
      g_suite_rec_tbl.MINIMUM_ACCOUNTABLE_UNIT(p_row_id)            ,
      g_suite_rec_tbl.PRECISION(p_row_id)                           ,
      g_suite_rec_tbl.LEGAL_ENTITY_ID(p_row_id)                     ,
      g_suite_rec_tbl.ROUNDING_SHIP_TO_PARTY_ID(p_row_id)           ,
      g_suite_rec_tbl.ROUNDING_SHIP_FROM_PARTY_ID(p_row_id)         ,
      g_suite_rec_tbl.ROUNDING_BILL_TO_PARTY_ID(p_row_id)           ,
      g_suite_rec_tbl.ROUNDING_BILL_FROM_PARTY_ID(p_row_id)         ,
      g_suite_rec_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(p_row_id)          ,
      g_suite_rec_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(p_row_id)        ,
      g_suite_rec_tbl.RNDG_BILL_TO_PARTY_SITE_ID(p_row_id)          ,
      g_suite_rec_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(p_row_id)        ,
      g_suite_rec_tbl.ESTABLISHMENT_ID(p_row_id)                    ,
      g_suite_rec_tbl.RECEIVABLES_TRX_TYPE_ID(p_row_id)             ,
      g_suite_rec_tbl.RELATED_DOC_APPLICATION_ID(p_row_id)          ,
      g_suite_rec_tbl.RELATED_DOC_ENTITY_CODE(p_row_id)             ,
      g_suite_rec_tbl.RELATED_DOC_EVENT_CLASS_CODE(p_row_id)        ,
      g_suite_rec_tbl.RELATED_DOC_TRX_ID(p_row_id)                  ,
      g_suite_rec_tbl.RELATED_DOC_NUMBER(p_row_id)                  ,
      g_suite_rec_tbl.RELATED_DOC_DATE(p_row_id)                    ,
      g_suite_rec_tbl.DEFAULT_TAXATION_COUNTRY(p_row_id)            ,
      g_suite_rec_tbl.QUOTE_FLAG(p_row_id)                          ,
      g_suite_rec_tbl.CTRL_TOTAL_HDR_TX_AMT(p_row_id)               ,
      g_suite_rec_tbl.TRX_NUMBER(p_row_id)                          ,
      g_suite_rec_tbl.TRX_DESCRIPTION(p_row_id)                     ,
      g_suite_rec_tbl.TRX_COMMUNICATED_DATE(p_row_id)               ,
      g_suite_rec_tbl.BATCH_SOURCE_ID(p_row_id)                     ,
      g_suite_rec_tbl.BATCH_SOURCE_NAME(p_row_id)                   ,
      g_suite_rec_tbl.DOC_SEQ_ID(p_row_id)                          ,
      g_suite_rec_tbl.DOC_SEQ_NAME(p_row_id)                        ,
      g_suite_rec_tbl.DOC_SEQ_VALUE(p_row_id)                       ,
      g_suite_rec_tbl.TRX_DUE_DATE(p_row_id)                        ,
      g_suite_rec_tbl.TRX_TYPE_DESCRIPTION(p_row_id)                ,
      g_suite_rec_tbl.DOCUMENT_SUB_TYPE(p_row_id)                   ,
      g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_NUMBER(p_row_id)         ,
      g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_DATE(p_row_id)           ,
      g_suite_rec_tbl.SUPPLIER_EXCHANGE_RATE(p_row_id)              ,
      g_suite_rec_tbl.TAX_INVOICE_DATE(p_row_id)                    ,
      g_suite_rec_tbl.TAX_INVOICE_NUMBER(p_row_id)                  ,
      g_suite_rec_tbl.FIRST_PTY_ORG_ID(p_row_id)                    ,
      g_suite_rec_tbl.TAX_EVENT_CLASS_CODE(p_row_id)                ,
      g_suite_rec_tbl.TAX_EVENT_TYPE_CODE(p_row_id)                 ,
      g_suite_rec_tbl.DOC_EVENT_STATUS(p_row_id)                    ,
      g_suite_rec_tbl.RDNG_SHIP_TO_PTY_TX_PROF_ID(p_row_id)         ,
      g_suite_rec_tbl.RDNG_SHIP_FROM_PTY_TX_PROF_ID(p_row_id)       ,
      g_suite_rec_tbl.RDNG_BILL_TO_PTY_TX_PROF_ID(p_row_id)         ,
      g_suite_rec_tbl.RDNG_BILL_FROM_PTY_TX_PROF_ID(p_row_id)       ,
      g_suite_rec_tbl.RDNG_SHIP_TO_PTY_TX_P_ST_ID(p_row_id)         ,
      g_suite_rec_tbl.RDNG_SHIP_FROM_PTY_TX_P_ST_ID(p_row_id)       ,
      g_suite_rec_tbl.RDNG_BILL_TO_PTY_TX_P_ST_ID(p_row_id)         ,
      g_suite_rec_tbl.RDNG_BILL_FROM_PTY_TX_P_ST_ID(p_row_id)       ,
      g_suite_rec_tbl.VALIDATION_CHECK_FLAG(p_row_id)               ,
      g_suite_rec_tbl.PORT_OF_ENTRY_CODE(p_row_id)                  );
  END insert_data_trx_headers_gt;


/* ============================================================================*
 | PROCEDURE insert_data_trx_lines_gt : Inserts data for lines in              |
 |                                      ZX_TRANSACTION_LINES_GT. Some values   |
 |                                      are obtained from the Header row       |
 * ============================================================================*/

  PROCEDURE insert_data_trx_lines_gt(p_header_row        NUMBER,
                                     p_starting_line_row NUMBER,
                                     p_ending_line_row   NUMBER)
  IS
     l_counter                  NUMBER;
     i                          NUMBER;
  BEGIN
    ---------------------------------------------
    -- INSERT INTO TABLE ZX_TRANSACTION_LINES_GT
    ---------------------------------------------
    for i in p_starting_line_row..p_ending_line_row loop
    write_message('Inserting into ZX_TRANSACTION_LINES_GT rec_tbl_row:'||to_char(i));

    --forall i in p_starting_line_row..p_ending_line_row
        INSERT INTO ZX_TRANSACTION_LINES_GT(
              APPLICATION_ID                           ,
              ENTITY_CODE                              ,
              EVENT_CLASS_CODE                         ,
              TRX_ID                                   ,
              TRX_LEVEL_TYPE                           ,
              TRX_LINE_ID                              ,
              LINE_LEVEL_ACTION                        ,
              LINE_CLASS                               ,
              TRX_SHIPPING_DATE                        ,
              TRX_RECEIPT_DATE                         ,
              TRX_LINE_TYPE                            ,
              TRX_LINE_DATE                            ,
              TRX_BUSINESS_CATEGORY                    ,
              LINE_INTENDED_USE                        ,
              USER_DEFINED_FISC_CLASS                  ,
              LINE_AMT                                 ,
              TRX_LINE_QUANTITY                        ,
              UNIT_PRICE                               ,
              EXEMPT_CERTIFICATE_NUMBER                ,
              EXEMPT_REASON                            ,
              CASH_DISCOUNT                            ,
              VOLUME_DISCOUNT                          ,
              TRADING_DISCOUNT                         ,
              TRANSFER_CHARGE                          ,
              TRANSPORTATION_CHARGE                    ,
              INSURANCE_CHARGE                         ,
              OTHER_CHARGE                             ,
              PRODUCT_ID                               ,
              PRODUCT_FISC_CLASSIFICATION              ,
              PRODUCT_ORG_ID                           ,
              UOM_CODE                                 ,
              PRODUCT_TYPE                             ,
              PRODUCT_CODE                             ,
              PRODUCT_CATEGORY                         ,
              TRX_SIC_CODE                             ,
              FOB_POINT                                ,
              SHIP_TO_PARTY_ID                         ,
              SHIP_FROM_PARTY_ID                       ,
              POA_PARTY_ID                             ,
              POO_PARTY_ID                             ,
              BILL_TO_PARTY_ID                         ,
              BILL_FROM_PARTY_ID                       ,
              MERCHANT_PARTY_ID                        ,
              SHIP_TO_PARTY_SITE_ID                    ,
              SHIP_FROM_PARTY_SITE_ID                  ,
              POA_PARTY_SITE_ID                        ,
              POO_PARTY_SITE_ID                        ,
              BILL_TO_PARTY_SITE_ID                    ,
              BILL_FROM_PARTY_SITE_ID                  ,
              SHIP_TO_LOCATION_ID                      ,
              SHIP_FROM_LOCATION_ID                    ,
              POA_LOCATION_ID                          ,
              POO_LOCATION_ID                          ,
              BILL_TO_LOCATION_ID                      ,
              BILL_FROM_LOCATION_ID                    ,
              ACCOUNT_CCID                             ,
              ACCOUNT_STRING                           ,
              MERCHANT_PARTY_COUNTRY                   ,
              REF_DOC_APPLICATION_ID                   ,
              REF_DOC_ENTITY_CODE                      ,
              REF_DOC_EVENT_CLASS_CODE                 ,
              REF_DOC_TRX_ID                           ,
              REF_DOC_LINE_ID                          ,
              REF_DOC_LINE_QUANTITY                    ,
              APPLIED_FROM_APPLICATION_ID              ,
              APPLIED_FROM_ENTITY_CODE                 ,
              APPLIED_FROM_EVENT_CLASS_CODE            ,
              APPLIED_FROM_TRX_ID                      ,
              APPLIED_FROM_LINE_ID                     ,
              ADJUSTED_DOC_APPLICATION_ID              ,
              ADJUSTED_DOC_ENTITY_CODE                 ,
              ADJUSTED_DOC_EVENT_CLASS_CODE            ,
              ADJUSTED_DOC_TRX_ID                      ,
              ADJUSTED_DOC_LINE_ID                     ,
              ADJUSTED_DOC_NUMBER                      ,
              ADJUSTED_DOC_DATE                        ,
              APPLIED_TO_APPLICATION_ID                ,
              APPLIED_TO_ENTITY_CODE                   ,
              APPLIED_TO_EVENT_CLASS_CODE              ,
              APPLIED_TO_TRX_ID                        ,
              APPLIED_TO_TRX_LINE_ID                   ,
              TRX_ID_LEVEL2                            ,
              TRX_ID_LEVEL3                            ,
              TRX_ID_LEVEL4                            ,
              TRX_ID_LEVEL5                            ,
              TRX_ID_LEVEL6                            ,
              TRX_LINE_NUMBER                          ,
              TRX_LINE_DESCRIPTION                     ,
              PRODUCT_DESCRIPTION                      ,
              TRX_WAYBILL_NUMBER                       ,
              TRX_LINE_GL_DATE                         ,
              MERCHANT_PARTY_NAME                      ,
              MERCHANT_PARTY_DOCUMENT_NUMBER           ,
              MERCHANT_PARTY_REFERENCE                 ,
              MERCHANT_PARTY_TAXPAYER_ID               ,
              MERCHANT_PARTY_TAX_REG_NUMBER            ,
              PAYING_PARTY_ID                          ,
              OWN_HQ_PARTY_ID                          ,
              TRADING_HQ_PARTY_ID                      ,
              POI_PARTY_ID                             ,
              POD_PARTY_ID                             ,
              TITLE_TRANSFER_PARTY_ID                  ,
              PAYING_PARTY_SITE_ID                     ,
              OWN_HQ_PARTY_SITE_ID                     ,
              TRADING_HQ_PARTY_SITE_ID                 ,
              POI_PARTY_SITE_ID                        ,
              POD_PARTY_SITE_ID                      ,
              TITLE_TRANSFER_PARTY_SITE_ID           ,
              PAYING_LOCATION_ID                     ,
              OWN_HQ_LOCATION_ID                     ,
              TRADING_HQ_LOCATION_ID                 ,
              POC_LOCATION_ID                        ,
              POI_LOCATION_ID                        ,
              POD_LOCATION_ID                        ,
              TITLE_TRANSFER_LOCATION_ID             ,
              ASSESSABLE_VALUE                      ,
              ASSET_FLAG                            ,
              ASSET_NUMBER                          ,
              ASSET_ACCUM_DEPRECIATION              ,
              ASSET_TYPE                            ,
              ASSET_COST                            ,
              SHIP_TO_PARTY_TAX_PROF_ID             ,
              SHIP_FROM_PARTY_TAX_PROF_ID           ,
              POA_PARTY_TAX_PROF_ID                 ,
              POO_PARTY_TAX_PROF_ID                 ,
              PAYING_PARTY_TAX_PROF_ID              ,
              OWN_HQ_PARTY_TAX_PROF_ID              ,
              TRADING_HQ_PARTY_TAX_PROF_ID          ,
              POI_PARTY_TAX_PROF_ID                 ,
              POD_PARTY_TAX_PROF_ID                 ,
              BILL_TO_PARTY_TAX_PROF_ID             ,
              BILL_FROM_PARTY_TAX_PROF_ID           ,
              TITLE_TRANS_PARTY_TAX_PROF_ID         ,
              SHIP_TO_SITE_TAX_PROF_ID              ,
              SHIP_FROM_SITE_TAX_PROF_ID            ,
              POA_SITE_TAX_PROF_ID                  ,
              POO_SITE_TAX_PROF_ID                  ,
              PAYING_SITE_TAX_PROF_ID               ,
              OWN_HQ_SITE_TAX_PROF_ID               ,
              TRADING_HQ_SITE_TAX_PROF_ID           ,
              POI_SITE_TAX_PROF_ID                  ,
              POD_SITE_TAX_PROF_ID                  ,
              BILL_TO_SITE_TAX_PROF_ID              ,
              BILL_FROM_SITE_TAX_PROF_ID            ,
              TITLE_TRANS_SITE_TAX_PROF_ID          ,
              MERCHANT_PARTY_TAX_PROF_ID            ,
              HQ_ESTB_PARTY_TAX_PROF_ID             ,
              LINE_AMT_INCLUDES_TAX_FLAG            ,
              HISTORICAL_FLAG                       ,
              CTRL_HDR_TX_APPL_FLAG                 ,
              CTRL_TOTAL_LINE_TX_AMT
              )
              VALUES
              (
               g_suite_rec_tbl.APPLICATION_ID(p_header_row)      ,
               g_suite_rec_tbl.ENTITY_CODE(p_header_row)         ,
               g_suite_rec_tbl.EVENT_CLASS_CODE(p_header_row)    ,
               g_suite_rec_tbl.TRX_ID(p_header_row)              ,
               g_suite_rec_tbl.TRX_LEVEL_TYPE(p_header_row)      ,
               g_suite_rec_tbl.TRX_LINE_ID(i)                    ,
               g_suite_rec_tbl.LINE_LEVEL_ACTION(i)              ,
               g_suite_rec_tbl.LINE_CLASS(i)                     ,
               g_suite_rec_tbl.TRX_SHIPPING_DATE(i)              ,
               g_suite_rec_tbl.TRX_RECEIPT_DATE(i)               ,
               g_suite_rec_tbl.TRX_LINE_TYPE(i)                  ,
               g_suite_rec_tbl.TRX_LINE_DATE(i)                  ,
               g_suite_rec_tbl.TRX_BUSINESS_CATEGORY(i)          ,
               g_suite_rec_tbl.LINE_INTENDED_USE(i)              ,
               g_suite_rec_tbl.USER_DEFINED_FISC_CLASS(i)        ,
               g_suite_rec_tbl.LINE_AMT(i)                       ,
               g_suite_rec_tbl.TRX_LINE_QUANTITY(i)              ,
               g_suite_rec_tbl.UNIT_PRICE(i)                     ,
               g_suite_rec_tbl.EXEMPT_CERTIFICATE_NUMBER(i)      ,
               g_suite_rec_tbl.EXEMPT_REASON(i)                  ,
               g_suite_rec_tbl.CASH_DISCOUNT(i)                  ,
               g_suite_rec_tbl.VOLUME_DISCOUNT(i)                ,
               g_suite_rec_tbl.TRADING_DISCOUNT(i)               ,
               g_suite_rec_tbl.TRANSFER_CHARGE(i)                ,
               g_suite_rec_tbl.TRANSPORTATION_CHARGE(i)          ,
               g_suite_rec_tbl.INSURANCE_CHARGE(i)               ,
               g_suite_rec_tbl.OTHER_CHARGE(i)                   ,
               g_suite_rec_tbl.PRODUCT_ID(i)                     ,
               g_suite_rec_tbl.PRODUCT_FISC_CLASSIFICATION(i)    ,
               g_suite_rec_tbl.PRODUCT_ORG_ID(i)                 ,
               g_suite_rec_tbl.UOM_CODE(i)                       ,
               g_suite_rec_tbl.PRODUCT_TYPE(i)                   ,
               g_suite_rec_tbl.PRODUCT_CODE(i)                   ,
               g_suite_rec_tbl.PRODUCT_CATEGORY(i)               ,
               g_suite_rec_tbl.TRX_SIC_CODE(i)                   ,
               g_suite_rec_tbl.FOB_POINT(i)                      ,
               g_suite_rec_tbl.SHIP_TO_PARTY_ID(i)               ,
               g_suite_rec_tbl.SHIP_FROM_PARTY_ID(i)             ,
               g_suite_rec_tbl.POA_PARTY_ID(i)                   ,
               g_suite_rec_tbl.POO_PARTY_ID(i)                   ,
               g_suite_rec_tbl.BILL_TO_PARTY_ID(i)               ,
               g_suite_rec_tbl.BILL_FROM_PARTY_ID(i)             ,
               g_suite_rec_tbl.MERCHANT_PARTY_ID(i)              ,
               g_suite_rec_tbl.SHIP_TO_PARTY_SITE_ID(i)          ,
               g_suite_rec_tbl.SHIP_FROM_PARTY_SITE_ID(i)        ,
               g_suite_rec_tbl.POA_PARTY_SITE_ID(i)                     ,
               g_suite_rec_tbl.POO_PARTY_SITE_ID(i)                     ,
               g_suite_rec_tbl.BILL_TO_PARTY_SITE_ID(i)                 ,
               g_suite_rec_tbl.BILL_FROM_PARTY_SITE_ID(i)               ,
               g_suite_rec_tbl.SHIP_TO_LOCATION_ID(i)                   ,
               --g_suite_rec_tbl.SHIP_FROM_LOCATION_ID(i)                 ,
               l_ship_from_location_id,
               g_suite_rec_tbl.POA_LOCATION_ID(i)                       ,
               g_suite_rec_tbl.POO_LOCATION_ID(i)                       ,
               g_suite_rec_tbl.BILL_TO_LOCATION_ID(i)                   ,
               g_suite_rec_tbl.BILL_FROM_LOCATION_ID(i)                 ,
               g_suite_rec_tbl.ACCOUNT_CCID(i)                          ,
               g_suite_rec_tbl.ACCOUNT_STRING(i)                        ,
               g_suite_rec_tbl.MERCHANT_PARTY_COUNTRY(i)                ,
               g_suite_rec_tbl.REF_DOC_APPLICATION_ID(i)                ,
               g_suite_rec_tbl.REF_DOC_ENTITY_CODE(i)                   ,
               g_suite_rec_tbl.REF_DOC_EVENT_CLASS_CODE(i)              ,
               g_suite_rec_tbl.REF_DOC_TRX_ID(i)                        ,
               g_suite_rec_tbl.REF_DOC_LINE_ID(i)                       ,
               g_suite_rec_tbl.REF_DOC_LINE_QUANTITY(i)                 ,
               g_suite_rec_tbl.APPLIED_FROM_APPLICATION_ID(i)           ,
               g_suite_rec_tbl.APPLIED_FROM_ENTITY_CODE(i)              ,
               g_suite_rec_tbl.APPLIED_FROM_EVENT_CLASS_CODE(i)         ,
               g_suite_rec_tbl.APPLIED_FROM_TRX_ID(i)                   ,
               g_suite_rec_tbl.APPLIED_FROM_LINE_ID(i)                  ,
               g_suite_rec_tbl.ADJUSTED_DOC_APPLICATION_ID(i)           ,
               g_suite_rec_tbl.ADJUSTED_DOC_ENTITY_CODE(i)              ,
               g_suite_rec_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(i)         ,
               g_suite_rec_tbl.ADJUSTED_DOC_TRX_ID(i)                   ,
               g_suite_rec_tbl.ADJUSTED_DOC_LINE_ID(i)                  ,
               g_suite_rec_tbl.ADJUSTED_DOC_NUMBER(i)                   ,
               g_suite_rec_tbl.ADJUSTED_DOC_DATE(i)                     ,
               g_suite_rec_tbl.APPLIED_TO_APPLICATION_ID(i)             ,
               g_suite_rec_tbl.APPLIED_TO_ENTITY_CODE(i)                ,
               g_suite_rec_tbl.APPLIED_TO_EVENT_CLASS_CODE(i)           ,
               g_suite_rec_tbl.APPLIED_TO_TRX_ID(i)                     ,
               g_suite_rec_tbl.APPLIED_TO_TRX_LINE_ID(i)                ,
               g_suite_rec_tbl.TRX_ID_LEVEL2(i)                         ,
               g_suite_rec_tbl.TRX_ID_LEVEL3(i)                         ,
               g_suite_rec_tbl.TRX_ID_LEVEL4(i)                         ,
               g_suite_rec_tbl.TRX_ID_LEVEL5(i)                         ,
               g_suite_rec_tbl.TRX_ID_LEVEL6(i)                         ,
               g_suite_rec_tbl.TRX_LINE_NUMBER(i)                       ,
               g_suite_rec_tbl.TRX_LINE_DESCRIPTION(i)                  ,
               g_suite_rec_tbl.PRODUCT_DESCRIPTION(i)                   ,
               g_suite_rec_tbl.TRX_WAYBILL_NUMBER(i)                    ,
               g_suite_rec_tbl.TRX_LINE_GL_DATE(i)                      ,
               g_suite_rec_tbl.MERCHANT_PARTY_NAME(i)                   ,
               g_suite_rec_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER(i)        ,
               g_suite_rec_tbl.MERCHANT_PARTY_REFERENCE(i)              ,
               g_suite_rec_tbl.MERCHANT_PARTY_TAXPAYER_ID(i)            ,
               g_suite_rec_tbl.MERCHANT_PARTY_TAX_REG_NUMBER(i)         ,
               g_suite_rec_tbl.PAYING_PARTY_ID(i)                       ,
               g_suite_rec_tbl.OWN_HQ_PARTY_ID(i)                       ,
               g_suite_rec_tbl.TRADING_HQ_PARTY_ID(i)                   ,
               g_suite_rec_tbl.POI_PARTY_ID(i)                          ,
               g_suite_rec_tbl.POD_PARTY_ID(i)                          ,
               g_suite_rec_tbl.TITLE_TRANSFER_PARTY_ID(i)               ,
               g_suite_rec_tbl.PAYING_PARTY_SITE_ID(i)                  ,
               g_suite_rec_tbl.OWN_HQ_PARTY_SITE_ID(i)                  ,
               g_suite_rec_tbl.TRADING_HQ_PARTY_SITE_ID(i)              ,
               g_suite_rec_tbl.POI_PARTY_SITE_ID(i)                     ,
               g_suite_rec_tbl.POD_PARTY_SITE_ID(i)                     ,
               g_suite_rec_tbl.TITLE_TRANSFER_PARTY_SITE_ID(i)          ,
               g_suite_rec_tbl.PAYING_LOCATION_ID(i)                    ,
               g_suite_rec_tbl.OWN_HQ_LOCATION_ID(i)                    ,
               g_suite_rec_tbl.TRADING_HQ_LOCATION_ID(i)                ,
               g_suite_rec_tbl.POC_LOCATION_ID(i)                       ,
               g_suite_rec_tbl.POI_LOCATION_ID(i)                       ,
               g_suite_rec_tbl.POD_LOCATION_ID(i)                       ,
               g_suite_rec_tbl.TITLE_TRANSFER_LOCATION_ID(i)            ,
               g_suite_rec_tbl.ASSESSABLE_VALUE(i)                      ,
               g_suite_rec_tbl.ASSET_FLAG(i)                            ,
               g_suite_rec_tbl.ASSET_NUMBER(i)                          ,
               g_suite_rec_tbl.ASSET_ACCUM_DEPRECIATION(i)              ,
               g_suite_rec_tbl.ASSET_TYPE(i)                            ,
               g_suite_rec_tbl.ASSET_COST(i)                            ,
               g_suite_rec_tbl.SHIP_TO_PARTY_TAX_PROF_ID(i)             ,
               g_suite_rec_tbl.SHIP_FROM_PARTY_TAX_PROF_ID(i)           ,
               g_suite_rec_tbl.POA_PARTY_TAX_PROF_ID(i)                 ,
               g_suite_rec_tbl.POO_PARTY_TAX_PROF_ID(i)                 ,
               g_suite_rec_tbl.PAYING_PARTY_TAX_PROF_ID(i)              ,
               g_suite_rec_tbl.OWN_HQ_PARTY_TAX_PROF_ID(i)              ,
               g_suite_rec_tbl.TRADING_HQ_PARTY_TAX_PROF_ID(i)          ,
               g_suite_rec_tbl.POI_PARTY_TAX_PROF_ID(i)                 ,
               g_suite_rec_tbl.POD_PARTY_TAX_PROF_ID(i)                 ,
               g_suite_rec_tbl.BILL_TO_PARTY_TAX_PROF_ID(i)             ,
               g_suite_rec_tbl.BILL_FROM_PARTY_TAX_PROF_ID(i)           ,
               g_suite_rec_tbl.TITLE_TRANS_PARTY_TAX_PROF_ID(i)         ,
               g_suite_rec_tbl.SHIP_TO_SITE_TAX_PROF_ID(i)              ,
               g_suite_rec_tbl.SHIP_FROM_SITE_TAX_PROF_ID(i)            ,
               g_suite_rec_tbl.POA_SITE_TAX_PROF_ID(i)                  ,
               g_suite_rec_tbl.POO_SITE_TAX_PROF_ID(i)                  ,
               g_suite_rec_tbl.PAYING_SITE_TAX_PROF_ID(i)               ,
               g_suite_rec_tbl.OWN_HQ_SITE_TAX_PROF_ID(i)               ,
               g_suite_rec_tbl.TRADING_HQ_SITE_TAX_PROF_ID(i)           ,
               g_suite_rec_tbl.POI_SITE_TAX_PROF_ID(i)                  ,
               g_suite_rec_tbl.POD_SITE_TAX_PROF_ID(i)                  ,
               g_suite_rec_tbl.BILL_TO_SITE_TAX_PROF_ID(i)              ,
               g_suite_rec_tbl.BILL_FROM_SITE_TAX_PROF_ID(i)            ,
               g_suite_rec_tbl.TITLE_TRANS_SITE_TAX_PROF_ID(i)          ,
               g_suite_rec_tbl.MERCHANT_PARTY_TAX_PROF_ID(i)            ,
               g_suite_rec_tbl.HQ_ESTB_PARTY_TAX_PROF_ID(i)             ,
               g_suite_rec_tbl.LINE_AMT_INCLUDES_TAX_FLAG(i)            ,
               g_suite_rec_tbl.HISTORICAL_FLAG(i)                       ,
               g_suite_rec_tbl.CTRL_HDR_TX_APPL_FLAG(i)                 ,
               g_suite_rec_tbl.CTRL_TOTAL_LINE_TX_AMT(i)
               );

          END LOOP;
  END insert_data_trx_lines_gt;



/* ============================================================================*
 | PROCEDURE insert_data_mrc_gt :Inserts a row in ZX_MRC_GT                    |
 * ===========================================================================*/
  PROCEDURE insert_data_mrc_gt
    (
      p_header_row        IN NUMBER
    ) IS
  BEGIN
      INSERT INTO ZX_MRC_GT
      (
        MINIMUM_ACCOUNTABLE_UNIT                       ,
        PRECISION                                      ,
        APPLICATION_ID                                 ,
        ENTITY_CODE                                    ,
        EVENT_CLASS_CODE                               ,
        EVENT_TYPE_CODE                                ,
        TRX_ID                                         ,
        REPORTING_CURRENCY_CODE                        ,
        CURRENCY_CONVERSION_DATE                       ,
        CURRENCY_CONVERSION_TYPE                       ,
        CURRENCY_CONVERSION_RATE                       ,
        LEDGER_ID
      )
      VALUES
      (
        g_suite_rec_tbl.MINIMUM_ACCOUNTABLE_UNIT(p_header_row)    ,
        g_suite_rec_tbl.PRECISION(p_header_row)                   ,
        g_suite_rec_tbl.APPLICATION_ID (p_header_row)             ,
        g_suite_rec_tbl.ENTITY_CODE(p_header_row)                 ,
        g_suite_rec_tbl.EVENT_CLASS_CODE(p_header_row)            ,
        g_suite_rec_tbl.EVENT_TYPE_CODE(p_header_row)             ,
        g_suite_rec_tbl.TRX_ID(p_header_row)                      ,
        g_suite_rec_tbl.TRX_CURRENCY_CODE(p_header_row)           ,
        ------------------------------------------------------------
        --At this moment we will use TRX_CURRENCY_CODE, later when
        --g_suite_rec_tbl.REPORTING_CURRENCY_CODE(i) is added to BTT
        --we will replace it by REPORTING_CURRENCY_CODE.
        ------------------------------------------------------------
        g_suite_rec_tbl.CURRENCY_CONVERSION_DATE(p_header_row)    ,
        g_suite_rec_tbl.CURRENCY_CONVERSION_TYPE(p_header_row)    ,
        g_suite_rec_tbl.CURRENCY_CONVERSION_RATE(p_header_row)    ,
        g_suite_rec_tbl.LEDGER_ID(p_header_row)
      );
  END;



/* ============================================================================*
 | PROCEDURE insert_transaction_rec : Populate the row in transaction_rec      |
 * ============================================================================*/

  PROCEDURE insert_transaction_rec (
               p_transaction_rec IN OUT NOCOPY zx_api_pub.transaction_rec_type
              )
  IS
  BEGIN

    p_transaction_rec.INTERNAL_ORGANIZATION_ID := g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(1);
    p_transaction_rec.APPLICATION_ID           := g_suite_rec_tbl.APPLICATION_ID(1);
    p_transaction_rec.ENTITY_CODE              := g_suite_rec_tbl.ENTITY_CODE(1);
    p_transaction_rec.EVENT_CLASS_CODE         := g_suite_rec_tbl.EVENT_CLASS_CODE(1);
    p_transaction_rec.EVENT_TYPE_CODE          := g_suite_rec_tbl.EVENT_TYPE_CODE(1);
    p_transaction_rec.TRX_ID                   := g_suite_rec_tbl.TRX_ID(1);

  END insert_transaction_rec;


/* ============================================================================*
 | PROCEDURE insert_row_transaction_rec : Populate the row in transaction_rec      |
 * ============================================================================*/

  PROCEDURE insert_row_transaction_rec (
              p_transaction_rec IN OUT NOCOPY zx_api_pub.transaction_rec_type,
              p_initial_row     IN NUMBER
              )
  IS
  BEGIN

    p_transaction_rec.INTERNAL_ORGANIZATION_ID := g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(p_initial_row);
    p_transaction_rec.APPLICATION_ID           := g_suite_rec_tbl.APPLICATION_ID(p_initial_row);
    p_transaction_rec.ENTITY_CODE              := g_suite_rec_tbl.ENTITY_CODE(p_initial_row);
    p_transaction_rec.EVENT_CLASS_CODE         := g_suite_rec_tbl.EVENT_CLASS_CODE(p_initial_row);
    p_transaction_rec.EVENT_TYPE_CODE          := g_suite_rec_tbl.EVENT_TYPE_CODE(p_initial_row);
    p_transaction_rec.TRX_ID                   := g_suite_rec_tbl.TRX_ID(p_initial_row);

  END insert_row_transaction_rec;


/* ====================================================================================*
 | PROCEDURE insert_import_sum_tax_lines_gt:Insert a row in ZX_IMPORT_TAX_LINES_GT |
 * ====================================================================================*/
  PROCEDURE insert_import_sum_tax_lines_gt (
      p_starting_row_tax_lines IN NUMBER,
      p_ending_row_tax_lines   IN NUMBER)
  IS
  i NUMBER;
  BEGIN

     FORALL i in p_starting_row_tax_lines..p_ending_row_tax_lines
     INSERT INTO ZX_IMPORT_TAX_LINES_GT
    (
     SUMMARY_TAX_LINE_NUMBER    ,
     INTERNAL_ORGANIZATION_ID   ,
     APPLICATION_ID             ,
     ENTITY_CODE                ,
     EVENT_CLASS_CODE           ,
     TRX_ID                     ,
     TAX_REGIME_CODE            ,
     TAX                        ,
     TAX_STATUS_CODE            ,
     TAX_RATE_CODE              ,
     TAX_RATE                   ,
     TAX_AMT                    ,
     TAX_JURISDICTION_CODE      ,
     TAX_AMT_INCLUDED_FLAG      ,
     TAX_RATE_ID                ,
     TAX_PROVIDER_ID            ,
     TAX_EXCEPTION_ID           ,
     TAX_EXEMPTION_ID           ,
     EXEMPT_REASON_CODE         ,
     EXEMPT_CERTIFICATE_NUMBER  ,
     TAX_LINE_ALLOCATION_FLAG
     )
     VALUES
     (
     g_suite_rec_tbl.SUMMARY_TAX_LINE_NUMBER(i)  ,
     g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(i) ,
     g_suite_rec_tbl.APPLICATION_ID(i)           ,
     g_suite_rec_tbl.ENTITY_CODE(i)              ,
     g_suite_rec_tbl.EVENT_CLASS_CODE(i)         ,
     g_suite_rec_tbl.TRX_ID(i)                   ,
     g_suite_rec_tbl.TAX_REGIME_CODE(i)          ,
     g_suite_rec_tbl.TAX(i)                      ,
     g_suite_rec_tbl.TAX_STATUS_CODE(i)          ,
     g_suite_rec_tbl.TAX_RATE_CODE(i)            ,
     g_suite_rec_tbl.TAX_RATE(i)                 ,
     g_suite_rec_tbl.TAX_AMT(i)                  ,
     g_suite_rec_tbl.TAX_JURISDICTION_CODE(i)    ,
     g_suite_rec_tbl.TAX_AMT_INCLUDED_FLAG(i)    ,
     g_suite_rec_tbl.TAX_RATE_ID(i)              ,
     g_suite_rec_tbl.TAX_PROVIDER_ID(i)          ,
     g_suite_rec_tbl.TAX_EXCEPTION_ID(i)         ,
     g_suite_rec_tbl.TAX_EXEMPTION_ID(i)         ,
     g_suite_rec_tbl.EXEMPT_REASON_CODE(i)       ,
     g_suite_rec_tbl.EXEMPT_CERTIFICATE_NUMBER(i),
     g_suite_rec_tbl.TAX_LINE_ALLOCATION_FLAG(i)
     );

  END insert_import_sum_tax_lines_gt;


/* ====================================================================*
 | PROCEDURE insert_trx_tax_link_gt:Insert a row in ZX_TRX_TAX_LINK_GT |
 * ====================================================================*/
  PROCEDURE insert_trx_tax_link_gt
      (
      p_sta_row_imp_tax_link   IN NUMBER,
      p_end_row_imp_tax_link   IN NUMBER
      )
  IS
  i NUMBER;
  BEGIN
    forall i in p_sta_row_imp_tax_link..p_end_row_imp_tax_link
    INSERT INTO ZX_TRX_TAX_LINK_GT
    (
     APPLICATION_ID                  ,
     ENTITY_CODE                     ,
     EVENT_CLASS_CODE                ,
     TRX_ID                          ,
     TRX_LEVEL_TYPE                  ,
     TRX_LINE_ID                     ,
     SUMMARY_TAX_LINE_NUMBER         ,
     LINE_AMT
    )
    VALUES
    (
     g_suite_rec_tbl.APPLICATION_ID(i)           ,
     g_suite_rec_tbl.ENTITY_CODE(i)              ,
     g_suite_rec_tbl.EVENT_CLASS_CODE(i)         ,
     g_suite_rec_tbl.TRX_ID(i)                   ,
     g_suite_rec_tbl.TRX_LEVEL_TYPE(i)           ,
     g_suite_rec_tbl.TRX_LINE_ID(i)              ,
     g_suite_rec_tbl.SUMMARY_TAX_LINE_NUMBER(i)  ,
     g_suite_rec_tbl.LINE_AMT(i)
    );

  END insert_trx_tax_link_gt;


/* =============================================================================*
 | PROCEDURE insert_reverse_trx_lines_gt:Insert a row in ZX_REVERSE_TRX_LINES_GT|
 * =============================================================================*/
  PROCEDURE insert_reverse_trx_lines_gt
  IS
  i NUMBER;
  BEGIN

  forall i in g_suite_rec_tbl.application_id.first..g_suite_rec_tbl.application_id.last
  INSERT INTO ZX_REVERSE_TRX_LINES_GT
  (
    INTERNAL_ORGANIZATION_ID    ,
    REVERSING_APPLN_ID          ,
    REVERSING_ENTITY_CODE       ,
    REVERSING_EVNT_CLS_CODE     ,
    REVERSING_TRX_ID            ,
    REVERSING_TRX_LEVEL_TYPE    ,
    REVERSING_TRX_LINE_ID       ,
    REVERSED_APPLN_ID           ,
    REVERSED_ENTITY_CODE        ,
    REVERSED_EVNT_CLS_CODE      ,
    REVERSED_TRX_ID             ,
    REVERSED_TRX_LEVEL_TYPE     ,
    REVERSED_TRX_LINE_ID        ,
    TRX_LINE_DESCRIPTION        ,
    PRODUCT_DESCRIPTION         ,
    TRX_WAYBILL_NUMBER          ,
    TRX_LINE_GL_DATE            ,
    MERCHANT_PARTY_DOCUMENT_NUMBER
   )
   VALUES
   (
    g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(i) ,
    g_suite_rec_tbl.REVERSING_APPLN_ID(i)       ,
    g_suite_rec_tbl.REVERSING_ENTITY_CODE(i)    ,
    g_suite_rec_tbl.REVERSING_EVNT_CLS_CODE(i)  ,
    g_suite_rec_tbl.REVERSING_TRX_ID(i)         ,
    g_suite_rec_tbl.REVERSING_TRX_LEVEL_TYPE(i) ,
    g_suite_rec_tbl.REVERSING_TRX_LINE_ID(i)    ,
    g_suite_rec_tbl.REVERSED_APPLN_ID(i)        ,
    g_suite_rec_tbl.REVERSED_ENTITY_CODE(i)     ,
    g_suite_rec_tbl.REVERSED_EVNT_CLS_CODE(i)   ,
    g_suite_rec_tbl.REVERSED_TRX_ID(i)          ,
    g_suite_rec_tbl.REVERSED_TRX_LEVEL_TYPE(i)  ,
    g_suite_rec_tbl.REVERSED_TRX_LINE_ID(i)     ,
    g_suite_rec_tbl.TRX_LINE_DESCRIPTION(i)      ,
    g_suite_rec_tbl.PRODUCT_DESCRIPTION(i)       ,
    g_suite_rec_tbl.TRX_WAYBILL_NUMBER(i)        ,
    g_suite_rec_tbl.TRX_LINE_GL_DATE(i)          ,
    g_suite_rec_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER(i)
    );

  END insert_reverse_trx_lines_gt;


/* ===============================================================================*
 | PROCEDURE insert_reverse_dist_lines_gt:Insert a row in ZX_REVERSE_TRX_LINES_GT |
 * ===============================================================================*/
  PROCEDURE insert_reverse_dist_lines_gt
  IS
  i NUMBER;
  BEGIN

  forall i in g_suite_rec_tbl.application_id.first..g_suite_rec_tbl.application_id.last
  INSERT INTO ZX_REVERSE_DIST_GT
  (
     INTERNAL_ORGANIZATION_ID,
     REVERSING_APPLN_ID,
     REVERSING_ENTITY_CODE,
     REVERSING_EVNT_CLS_CODE,
     REVERSING_TRX_ID,
     REVERSING_TRX_LEVEL_TYPE,
     REVERSING_TRX_LINE_ID,
     REVERSING_TRX_LINE_DIST_ID,
     REVERSING_TAX_LINE_ID,
     REVERSED_APPLN_ID,
     REVERSED_ENTITY_CODE,
     REVERSED_EVNT_CLS_CODE,
     REVERSED_TRX_ID,
     REVERSED_TRX_LEVEL_TYPE,
     REVERSED_TRX_LINE_ID,
     REVERSED_TRX_LINE_DIST_ID,
     FIRST_PTY_ORG_ID         ,
     REVERSED_TAX_LINE_ID
   )
   VALUES
   (
     g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(i),
     g_suite_rec_tbl.REVERSING_APPLN_ID(i),
     g_suite_rec_tbl.REVERSING_ENTITY_CODE(i),
     g_suite_rec_tbl.REVERSING_EVNT_CLS_CODE(i),
     g_suite_rec_tbl.REVERSING_TRX_ID(i),
     g_suite_rec_tbl.REVERSING_TRX_LEVEL_TYPE(i),
     g_suite_rec_tbl.REVERSING_TRX_LINE_ID(i),
     g_suite_rec_tbl.REVERSING_TRX_LINE_DIST_ID(i),
     g_suite_rec_tbl.REVERSING_TAX_LINE_ID(i),
     g_suite_rec_tbl.REVERSED_APPLN_ID(i),
     g_suite_rec_tbl.REVERSED_ENTITY_CODE(i),
     g_suite_rec_tbl.REVERSED_EVNT_CLS_CODE(i),
     g_suite_rec_tbl.REVERSED_TRX_ID(i),
     g_suite_rec_tbl.REVERSED_TRX_LEVEL_TYPE(i)           ,
     g_suite_rec_tbl.REVERSED_TRX_LINE_ID(i)              ,
     g_suite_rec_tbl.REVERSED_TRX_LINE_DIST_ID(i)         ,
     g_suite_rec_tbl.FIRST_PTY_ORG_ID(i)                   ,
     g_suite_rec_tbl.REVERSED_TAX_LINE_ID(i)
    );

  END insert_reverse_dist_lines_gt;


/* ================================================================================*
 | PROCEDURE insert_itm_distributions_gt:Insert a row in ZX_ITM_DISTRIBUTIONS_GT   |
 * ================================================================================*/
  PROCEDURE insert_itm_distributions_gt
      (
      p_header_row        IN NUMBER,
      p_sta_row_item_dist IN NUMBER,
      p_end_row_item_dist IN NUMBER
      )

  IS
  i NUMBER;
  BEGIN

    forall i in p_sta_row_item_dist..p_end_row_item_dist
    INSERT INTO ZX_ITM_DISTRIBUTIONS_GT
    (
     APPLICATION_ID                           ,
     ENTITY_CODE                              ,
     EVENT_CLASS_CODE                         ,
     TRX_ID                                   ,
     TRX_LINE_ID                              ,
     TRX_LEVEL_TYPE                           ,
     TRX_LINE_DIST_ID                         ,
     DIST_LEVEL_ACTION                        ,
     TRX_LINE_DIST_DATE                       ,
     ITEM_DIST_NUMBER                         ,
     DIST_INTENDED_USE                        ,
     TAX_INCLUSION_FLAG                       ,
     TAX_CODE                                 ,
     APPLIED_FROM_TAX_DIST_ID                 ,
     ADJUSTED_DOC_TAX_DIST_ID                 ,
     TASK_ID                                  ,
     AWARD_ID                                 ,
     PROJECT_ID                               ,
     EXPENDITURE_TYPE                         ,
     EXPENDITURE_ORGANIZATION_ID              ,
     EXPENDITURE_ITEM_DATE                    ,
     TRX_LINE_DIST_AMT                        ,
     TRX_LINE_DIST_QTY                        ,
     TRX_LINE_QUANTITY                        ,
     ACCOUNT_CCID                             ,
     ACCOUNT_STRING                           ,
     REF_DOC_APPLICATION_ID                   ,
     REF_DOC_ENTITY_CODE                      ,
     REF_DOC_EVENT_CLASS_CODE                 ,
     REF_DOC_TRX_ID                           ,
     REF_DOC_LINE_ID                          ,
     REF_DOC_DIST_ID                          ,
     REF_DOC_CURR_CONV_RATE                   ,
     TRX_LINE_DIST_TAX_AMT                    ,
     HISTORICAL_FLAG                          ,
     APPLIED_FROM_APPLICATION_ID              ,
     APPLIED_FROM_EVENT_CLASS_CODE            ,
     APPLIED_FROM_ENTITY_CODE                 ,
     APPLIED_FROM_TRX_ID                      ,
     APPLIED_FROM_LINE_ID                     ,
     APPLIED_FROM_DIST_ID                     ,
     ADJUSTED_DOC_APPLICATION_ID              ,
     ADJUSTED_DOC_EVENT_CLASS_CODE            ,
     ADJUSTED_DOC_ENTITY_CODE                 ,
     ADJUSTED_DOC_TRX_ID                      ,
     ADJUSTED_DOC_LINE_ID                     ,
     ADJUSTED_DOC_DIST_ID                     ,
     APPLIED_TO_DOC_CURR_CONV_RATE            ,
     TAX_VARIANCE_CALC_FLAG
    )
    VALUES
    (
      g_suite_rec_tbl.APPLICATION_ID(p_header_row)        ,
      g_suite_rec_tbl.ENTITY_CODE(p_header_row)           ,
      g_suite_rec_tbl.EVENT_CLASS_CODE(p_header_row)      ,
      g_suite_rec_tbl.TRX_ID(p_header_row)                ,
      g_suite_rec_tbl.TRX_LINE_ID(i)                      ,
      g_suite_rec_tbl.TRX_LEVEL_TYPE(i)                   ,
      g_suite_rec_tbl.TRX_LINE_DIST_ID(i)                 ,
      g_suite_rec_tbl.DIST_LEVEL_ACTION(i)                ,
      g_suite_rec_tbl.TRX_LINE_DIST_DATE(i)               ,
      g_suite_rec_tbl.ITEM_DIST_NUMBER(i)                 ,
      g_suite_rec_tbl.DIST_INTENDED_USE(i)                ,
      g_suite_rec_tbl.TAX_INCLUSION_FLAG(i)               ,
      g_suite_rec_tbl.TAX_CODE(i)                         ,
      g_suite_rec_tbl.APPLIED_FROM_TAX_DIST_ID(i)         ,
      g_suite_rec_tbl.ADJUSTED_DOC_TAX_DIST_ID(i)         ,
      g_suite_rec_tbl.TASK_ID(i)                          ,
      g_suite_rec_tbl.AWARD_ID(i)                         ,
      g_suite_rec_tbl.PROJECT_ID(i)                       ,
      g_suite_rec_tbl.EXPENDITURE_TYPE(i)                 ,
      g_suite_rec_tbl.EXPENDITURE_ORGANIZATION_ID(i)      ,
      g_suite_rec_tbl.EXPENDITURE_ITEM_DATE(i)            ,
      g_suite_rec_tbl.TRX_LINE_DIST_AMT(i)                ,
      g_suite_rec_tbl.TRX_LINE_DIST_QUANTITY(i)           ,
      g_suite_rec_tbl.TRX_LINE_QUANTITY(i)                ,
      g_suite_rec_tbl.ACCOUNT_CCID(i)                     ,
      g_suite_rec_tbl.ACCOUNT_STRING(i)                   ,
      g_suite_rec_tbl.REF_DOC_APPLICATION_ID(i)           ,
      g_suite_rec_tbl.REF_DOC_ENTITY_CODE(i)              ,
      g_suite_rec_tbl.REF_DOC_EVENT_CLASS_CODE(i)         ,
      g_suite_rec_tbl.REF_DOC_TRX_ID(i)                   ,
      g_suite_rec_tbl.REF_DOC_LINE_ID(i)                  ,
      g_suite_rec_tbl.REF_DOC_DIST_ID(i)                  ,
      g_suite_rec_tbl.REF_DOC_CURR_CONV_RATE(i)           ,
      g_suite_rec_tbl.TRX_LINE_DIST_TAX_AMT(i)            ,
      g_suite_rec_tbl.HISTORICAL_FLAG(i)                  ,
      g_suite_rec_tbl.APPLIED_FROM_APPLICATION_ID(i)      ,
      g_suite_rec_tbl.APPLIED_FROM_EVENT_CLASS_CODE(i)    ,
      g_suite_rec_tbl.APPLIED_FROM_ENTITY_CODE(i)         ,
      g_suite_rec_tbl.APPLIED_FROM_TRX_ID(i)              ,
      g_suite_rec_tbl.APPLIED_FROM_LINE_ID(i)             ,
      g_suite_rec_tbl.APPLIED_FROM_DIST_ID(i)             ,
      g_suite_rec_tbl.ADJUSTED_DOC_APPLICATION_ID(i)      ,
      g_suite_rec_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(i)    ,
      g_suite_rec_tbl.adjusted_doc_entity_code(i)         ,
      g_suite_rec_tbl.ADJUSTED_DOC_TRX_ID(i)              ,
      g_suite_rec_tbl.ADJUSTED_DOC_LINE_ID(i)             ,
      g_suite_rec_tbl.ADJUSTED_DOC_DIST_ID(i)             ,
      g_suite_rec_tbl.APPLIED_TO_DOC_CURR_CONV_RATE(i)    ,
      g_suite_rec_tbl.TAX_VARIANCE_CALC_FLAG(i)           );

  END insert_itm_distributions_gt;


/* ========================================================================*
 | PROCEDURE Insert rows into ZX_TAX_DIST_ID_GT from zx_rec_nrec_dist      |
 * ========================================================================*/
  PROCEDURE insert_rows_tax_dist_id_gt( p_trx_id IN NUMBER)
  IS
  BEGIN
       INSERT INTO ZX_TAX_DIST_ID_GT
       (
         TAX_DIST_ID
       )
       SELECT
         REC_NREC_TAX_DIST_ID
       FROM ZX_REC_NREC_DIST
       WHERE TRX_ID = p_trx_id;

  END insert_rows_tax_dist_id_gt;


/* =========================================================================*
 | PROCEDURE insert_sync_trx_rec: Insert the row in the sync trx record     |
 * =========================================================================*/
  PROCEDURE insert_sync_trx_rec
    (
     p_header_row IN NUMBER,
     x_sync_trx_rec OUT NOCOPY zx_api_pub.sync_trx_rec_type
    )
  IS
  BEGIN
   x_sync_trx_rec.APPLICATION_ID                 := g_suite_rec_tbl.APPLICATION_ID(p_header_row);
   x_sync_trx_rec.ENTITY_CODE                    := g_suite_rec_tbl.ENTITY_CODE(p_header_row);
   x_sync_trx_rec.EVENT_CLASS_CODE               := g_suite_rec_tbl.EVENT_CLASS_CODE(p_header_row);
   x_sync_trx_rec.EVENT_TYPE_CODE                := g_suite_rec_tbl.EVENT_TYPE_CODE(p_header_row);
   x_sync_trx_rec.TRX_ID                         := g_suite_rec_tbl.TRX_ID(p_header_row);
   x_sync_trx_rec.TRX_NUMBER                     := g_suite_rec_tbl.TRX_NUMBER(p_header_row);
   x_sync_trx_rec.TRX_DESCRIPTION                := g_suite_rec_tbl.TRX_DESCRIPTION(p_header_row);
   x_sync_trx_rec.TRX_COMMUNICATED_DATE          := g_suite_rec_tbl.TRX_COMMUNICATED_DATE(p_header_row);
   x_sync_trx_rec.BATCH_SOURCE_ID                := g_suite_rec_tbl.BATCH_SOURCE_ID(p_header_row);
   x_sync_trx_rec.BATCH_SOURCE_NAME              := g_suite_rec_tbl.BATCH_SOURCE_NAME(p_header_row);
   x_sync_trx_rec.DOC_SEQ_ID                     := g_suite_rec_tbl.DOC_SEQ_ID(p_header_row);
   x_sync_trx_rec.DOC_SEQ_NAME                   := g_suite_rec_tbl.DOC_SEQ_NAME(p_header_row);
   x_sync_trx_rec.DOC_SEQ_VALUE                  := g_suite_rec_tbl.DOC_SEQ_VALUE(p_header_row);
   x_sync_trx_rec.TRX_DUE_DATE                   := g_suite_rec_tbl.TRX_DUE_DATE(p_header_row);
   x_sync_trx_rec.TRX_TYPE_DESCRIPTION           := g_suite_rec_tbl.TRX_TYPE_DESCRIPTION(p_header_row);
   x_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER    := g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_NUMBER(p_header_row);
   x_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE      := g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_DATE(p_header_row);
   x_sync_trx_rec.SUPPLIER_EXCHANGE_RATE         := g_suite_rec_tbl.SUPPLIER_EXCHANGE_RATE(p_header_row);
   x_sync_trx_rec.TAX_INVOICE_DATE               := g_suite_rec_tbl.TAX_INVOICE_DATE(p_header_row);
  END insert_sync_trx_rec;


/* ==========================================================================*
 | PROCEDURE insert_sync_trx_lines_tbl:Insert a row in ZX_SYNC_TRX_LINES_tbl |
 * ==========================================================================*/

  PROCEDURE insert_sync_trx_lines_tbl(
              p_header_row                  IN NUMBER,
              p_starting_row_sync_trx_lines IN NUMBER,
              p_ending_row_sync_trx_lines   IN NUMBER,
              x_sync_trx_lines_tbl          OUT NOCOPY zx_api_pub.sync_trx_lines_tbl_type%type)
  IS
    i NUMBER;
    l_counter NUMBER;
  BEGIN
    l_counter := 1;
    FOR i in p_starting_row_sync_trx_lines..p_ending_row_sync_trx_lines
    LOOP
      x_sync_trx_lines_tbl.application_id(l_counter)                 := g_suite_rec_tbl.application_id(p_header_row);
      x_sync_trx_lines_tbl.entity_code(l_counter)                    := g_suite_rec_tbl.entity_code(p_header_row);
      x_sync_trx_lines_tbl.event_class_code(l_counter)               := g_suite_rec_tbl.event_class_code(p_header_row);
      x_sync_trx_lines_tbl.trx_id(l_counter)                         := g_suite_rec_tbl.trx_id(p_header_row);
      x_sync_trx_lines_tbl.trx_level_type(l_counter)                 := g_suite_rec_tbl.trx_level_type(i);
      x_sync_trx_lines_tbl.trx_line_id(l_counter)                    := g_suite_rec_tbl.trx_line_id(i);
      x_sync_trx_lines_tbl.trx_waybill_number(l_counter)             := g_suite_rec_tbl.trx_waybill_number(i);
      x_sync_trx_lines_tbl.trx_line_description(l_counter)           := g_suite_rec_tbl.trx_line_description(i);
      x_sync_trx_lines_tbl.product_description(l_counter)            := g_suite_rec_tbl.product_description(i);
      x_sync_trx_lines_tbl.trx_line_gl_date(l_counter)               := g_suite_rec_tbl.trx_line_gl_date(i);
      x_sync_trx_lines_tbl.merchant_party_name(l_counter)            := g_suite_rec_tbl.merchant_party_name(i);
      x_sync_trx_lines_tbl.merchant_party_document_number(l_counter) := g_suite_rec_tbl.merchant_party_document_number(i);
      x_sync_trx_lines_tbl.merchant_party_reference(l_counter)       := g_suite_rec_tbl.merchant_party_reference(i);
      x_sync_trx_lines_tbl.merchant_party_taxpayer_id(l_counter)     := g_suite_rec_tbl.merchant_party_taxpayer_id(i);
      x_sync_trx_lines_tbl.merchant_party_tax_reg_number(l_counter)  := g_suite_rec_tbl.merchant_party_tax_reg_number(i);
      x_sync_trx_lines_tbl.asset_number(l_counter)                   := g_suite_rec_tbl.asset_number(i);

      l_counter := l_counter + 1;
    END LOOP;
  END insert_sync_trx_lines_tbl;



/* ============================================================================*
 | PROCEDURE insert_transaction_line_rec: Populate the transaction_line_rec    |
 * ============================================================================*/
  PROCEDURE insert_transaction_line_rec (
         p_transaction_line_rec IN OUT NOCOPY zx_api_pub.transaction_line_rec_type,
         p_row_trx_line         IN NUMBER
         )
  IS
  BEGIN

    p_transaction_line_rec.INTERNAL_ORGANIZATION_ID := g_suite_rec_tbl.internal_organization_id(p_row_trx_line);
    p_transaction_line_rec.APPLICATION_ID           := g_suite_rec_tbl.application_id(p_row_trx_line);
    p_transaction_line_rec.ENTITY_CODE              := g_suite_rec_tbl.entity_code(p_row_trx_line);
    p_transaction_line_rec.EVENT_CLASS_CODE         := g_suite_rec_tbl.event_class_code(p_row_trx_line);
    p_transaction_line_rec.EVENT_TYPE_CODE          := g_suite_rec_tbl.event_type_code(p_row_trx_line);
    p_transaction_line_rec.TRX_ID                   := g_suite_rec_tbl.trx_id(p_row_trx_line);
    p_transaction_line_rec.TRX_LINE_ID              := g_suite_rec_tbl.trx_line_id(p_row_trx_line);
    p_transaction_line_rec.TRX_LEVEL_TYPE           := g_suite_rec_tbl.trx_level_type(p_row_trx_line);

    write_message('A row has been inserted in g_transaction_line_rec.');
    write_message('~ INTERNAL_ORGANIZATION_ID '||to_char(g_transaction_line_rec.INTERNAL_ORGANIZATION_ID));
    write_message('~ APPLICATION_ID '          ||to_char(g_transaction_line_rec.APPLICATION_ID));
    write_message('~ ENTITY_CODE '             ||        g_transaction_line_rec.ENTITY_CODE);
    write_message('~ EVENT_CLASS_CODE '        ||        g_transaction_line_rec.EVENT_CLASS_CODE);
    write_message('~ EVENT_TYPE_CODE '         ||        g_transaction_line_rec.EVENT_TYPE_CODE);
    write_message('~ TRX_ID '                  ||to_char(g_transaction_line_rec.TRX_ID));
    write_message('~ TRX_LINE_ID '             ||to_char(g_transaction_line_rec.TRX_LINE_ID));
    write_message('~ TRX_LEVEL_TYPE '          ||        g_transaction_line_rec.TRX_LEVEL_TYPE);


  END insert_transaction_line_rec;



/* ======================================================================*
 | PROCEDURE delete_table :     Reset the record of tables               |
 * ======================================================================*/

  PROCEDURE delete_table IS

  BEGIN
   g_suite_rec_tbl.ROW_ID.delete;
   g_suite_rec_tbl.ROW_SUITE.delete;
   g_suite_rec_tbl.ROW_CASE.delete;
   g_suite_rec_tbl.ROW_API.delete;
   g_suite_rec_tbl.ROW_SERVICE.delete;
   g_suite_rec_tbl.ROW_STRUCTURE.delete;
   g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID.delete;
   g_suite_rec_tbl.INTERNAL_ORG_LOCATION_ID.delete;
   g_suite_rec_tbl.APPLICATION_ID.delete;
   g_suite_rec_tbl.ENTITY_CODE.delete;
   g_suite_rec_tbl.EVENT_CLASS_CODE.delete;
   g_suite_rec_tbl.TAX_EVENT_CLASS_CODE.delete;
   g_suite_rec_tbl.DOC_EVENT_STATUS.delete;
   g_suite_rec_tbl.TAX_HOLD_RELEASED_CODE.delete;
   g_suite_rec_tbl.EVENT_TYPE_CODE.delete;
   g_suite_rec_tbl.TRX_ID.delete;
   g_suite_rec_tbl.OVERRIDE_LEVEL.delete;
   g_suite_rec_tbl.TRX_LEVEL_TYPE.delete;
   g_suite_rec_tbl.TRX_LINE_ID.delete;
   g_suite_rec_tbl.TRX_WAYBILL_NUMBER.delete;
   g_suite_rec_tbl.TRX_LINE_DESCRIPTION.delete;
   g_suite_rec_tbl.PRODUCT_DESCRIPTION.delete;
   g_suite_rec_tbl.TAX_LINE_ID.delete;
   g_suite_rec_tbl.SUMMARY_TAX_LINE_ID.delete;
   g_suite_rec_tbl.INVOICE_PRICE_VARIANCE.delete;
   g_suite_rec_tbl.LINE_LEVEL_ACTION.delete;
   g_suite_rec_tbl.TAX_CLASSIFICATION_CODE.delete;
   g_suite_rec_tbl.TRX_DATE.delete;
   g_suite_rec_tbl.TRX_DOC_REVISION.delete;
   g_suite_rec_tbl.LEDGER_ID.delete;
   g_suite_rec_tbl.TAX_RATE_ID.delete;
   g_suite_rec_tbl.TRX_CURRENCY_CODE.delete;
   g_suite_rec_tbl.CURRENCY_CONVERSION_DATE.delete;
   g_suite_rec_tbl.CURRENCY_CONVERSION_RATE.delete;
   g_suite_rec_tbl.CURRENCY_CONVERSION_TYPE.delete;
   g_suite_rec_tbl.MINIMUM_ACCOUNTABLE_UNIT.delete;
   g_suite_rec_tbl.PRECISION.delete;
   g_suite_rec_tbl.TRX_SHIPPING_DATE.delete;
   g_suite_rec_tbl.TRX_RECEIPT_DATE.delete;
   g_suite_rec_tbl.LEGAL_ENTITY_ID.delete;
   g_suite_rec_tbl.REVERSING_APPLN_ID.delete;
   g_suite_rec_tbl.ROUNDING_SHIP_TO_PARTY_ID.delete;
   g_suite_rec_tbl.ROUNDING_SHIP_FROM_PARTY_ID.delete;
   g_suite_rec_tbl.ROUNDING_BILL_TO_PARTY_ID.delete;
   g_suite_rec_tbl.ROUNDING_BILL_FROM_PARTY_ID.delete;
   g_suite_rec_tbl.RNDG_SHIP_TO_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.RNDG_BILL_TO_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.RNDG_BILL_FROM_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.ESTABLISHMENT_ID.delete;
   g_suite_rec_tbl.TAX_EXEMPTION_ID.delete;
   g_suite_rec_tbl.REC_NREC_TAX_DIST_ID.delete;
   g_suite_rec_tbl.TAX_APPORTIONMENT_LINE_NUMBER.delete;
   g_suite_rec_tbl.EXEMPTION_RATE.delete;
   g_suite_rec_tbl.TOTAL_NREC_TAX_AMT.delete;
   g_suite_rec_tbl.TOTAL_REC_TAX_AMT.delete;
   g_suite_rec_tbl.REC_TAX_AMT.delete;
   g_suite_rec_tbl.NREC_TAX_AMT.delete;
   g_suite_rec_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER.delete;
   g_suite_rec_tbl.TRX_LINE_TYPE.delete;
   g_suite_rec_tbl.TAX_REGISTRATION_NUMBER.delete;
   g_suite_rec_tbl.CTRL_TOTAL_HDR_TX_AMT.delete;
   g_suite_rec_tbl.EXEMPT_REASON_CODE.delete;
   g_suite_rec_tbl.TAX_HOLD_CODE.delete;
   g_suite_rec_tbl.TAX_AMT_FUNCL_CURR.delete;
   g_suite_rec_tbl.TOTAL_REC_TAX_AMT_FUNCL_CURR.delete;
   g_suite_rec_tbl.TOTAL_NREC_TAX_AMT_FUNCL_CURR.delete;
   g_suite_rec_tbl.TAXABLE_AMT_FUNCL_CURR.delete;
   g_suite_rec_tbl.REC_TAX_AMT_FUNCL_CURR.delete;
   g_suite_rec_tbl.NREC_TAX_AMT_FUNCL_CURR.delete;
   g_suite_rec_tbl.TRX_LINE_DATE.delete;
   g_suite_rec_tbl.TRX_BUSINESS_CATEGORY.delete;
   g_suite_rec_tbl.LINE_INTENDED_USE.delete;
   g_suite_rec_tbl.USER_DEFINED_FISC_CLASS.delete;
   g_suite_rec_tbl.TAX_CODE.delete;
   g_suite_rec_tbl.TAX_INCLUSION_FLAG.delete;
   g_suite_rec_tbl.TAX_AMT_INCLUDED_FLAG.delete;
   g_suite_rec_tbl.SELF_ASSESSED_FLAG.delete;
   g_suite_rec_tbl.QUOTE_FLAG.delete;
   g_suite_rec_tbl.HISTORICAL_FLAG.delete;
   g_suite_rec_tbl.MANUALLY_ENTERED_FLAG.delete;
   g_suite_rec_tbl.LINE_AMT.delete;
   g_suite_rec_tbl.TRX_LINE_QUANTITY.delete;
   g_suite_rec_tbl.UNIT_PRICE.delete;
   g_suite_rec_tbl.EXEMPT_CERTIFICATE_NUMBER.delete;
   g_suite_rec_tbl.EXEMPT_REASON.delete;
   g_suite_rec_tbl.CASH_DISCOUNT.delete;
   g_suite_rec_tbl.VOLUME_DISCOUNT.delete;
   g_suite_rec_tbl.TRADING_DISCOUNT.delete;
   g_suite_rec_tbl.TRANSFER_CHARGE.delete;
   g_suite_rec_tbl.TRANSPORTATION_CHARGE.delete;
   g_suite_rec_tbl.INSURANCE_CHARGE.delete;
   g_suite_rec_tbl.OTHER_CHARGE.delete;
   g_suite_rec_tbl.PRODUCT_ID.delete;
   g_suite_rec_tbl.PRODUCT_FISC_CLASSIFICATION.delete;
   g_suite_rec_tbl.PRODUCT_ORG_ID.delete;
   g_suite_rec_tbl.UOM_CODE.delete;
   g_suite_rec_tbl.PRODUCT_TYPE.delete;
   g_suite_rec_tbl.PRODUCT_CODE.delete;
   g_suite_rec_tbl.PRODUCT_CATEGORY.delete;
   g_suite_rec_tbl.TRX_SIC_CODE.delete;
   g_suite_rec_tbl.FOB_POINT.delete;
   g_suite_rec_tbl.SHIP_TO_PARTY_ID.delete;
   g_suite_rec_tbl.SHIP_FROM_PARTY_ID.delete;
   g_suite_rec_tbl.POA_PARTY_ID.delete;
   g_suite_rec_tbl.POO_PARTY_ID.delete;
   g_suite_rec_tbl.BILL_TO_PARTY_ID.delete;
   g_suite_rec_tbl.BILL_FROM_PARTY_ID.delete;
   g_suite_rec_tbl.MERCHANT_PARTY_ID.delete;
   g_suite_rec_tbl.SHIP_TO_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.SHIP_FROM_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.POA_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.POO_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.BILL_TO_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.BILL_FROM_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.SHIP_TO_LOCATION_ID.delete;
   g_suite_rec_tbl.SHIP_FROM_LOCATION_ID.delete;
   g_suite_rec_tbl.POA_LOCATION_ID.delete;
   g_suite_rec_tbl.POO_LOCATION_ID.delete;
   g_suite_rec_tbl.BILL_TO_LOCATION_ID.delete;
   g_suite_rec_tbl.BILL_FROM_LOCATION_ID.delete;
   g_suite_rec_tbl.ACCOUNT_CCID.delete;
   g_suite_rec_tbl.ACCOUNT_STRING.delete;
   g_suite_rec_tbl.MERCHANT_PARTY_COUNTRY.delete;
   g_suite_rec_tbl.RECEIVABLES_TRX_TYPE_ID.delete;
   g_suite_rec_tbl.REF_DOC_APPLICATION_ID.delete;
   g_suite_rec_tbl.REF_DOC_ENTITY_CODE.delete;
   g_suite_rec_tbl.REF_DOC_EVENT_CLASS_CODE.delete;
   g_suite_rec_tbl.REF_DOC_TRX_ID.delete;
   g_suite_rec_tbl.REF_DOC_LINE_ID.delete;
   g_suite_rec_tbl.REF_DOC_LINE_QUANTITY.delete;
   g_suite_rec_tbl.RELATED_DOC_APPLICATION_ID.delete;
   g_suite_rec_tbl.RELATED_DOC_ENTITY_CODE.delete;
   g_suite_rec_tbl.RELATED_DOC_EVENT_CLASS_CODE.delete;
   g_suite_rec_tbl.RELATED_DOC_TRX_ID.delete;
   g_suite_rec_tbl.RELATED_DOC_NUMBER.delete;
   g_suite_rec_tbl.RELATED_DOC_DATE.delete;
   g_suite_rec_tbl.APPLIED_FROM_APPLICATION_ID.delete;
   g_suite_rec_tbl.APPLIED_FROM_ENTITY_CODE.delete;
   g_suite_rec_tbl.APPLIED_FROM_EVENT_CLASS_CODE.delete;
   g_suite_rec_tbl.APPLIED_FROM_TRX_ID.delete;
   g_suite_rec_tbl.APPLIED_FROM_LINE_ID.delete;
   g_suite_rec_tbl.ADJUSTED_DOC_APPLICATION_ID.delete;
   g_suite_rec_tbl.ADJUSTED_DOC_ENTITY_CODE.delete;
   g_suite_rec_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE.delete;
   g_suite_rec_tbl.ADJUSTED_DOC_TRX_ID.delete;
   g_suite_rec_tbl.ADJUSTED_DOC_LINE_ID.delete;
   g_suite_rec_tbl.ADJUSTED_DOC_NUMBER.delete;
   g_suite_rec_tbl.ASSESSABLE_VALUE.delete;
   g_suite_rec_tbl.ADJUSTED_DOC_DATE.delete;
   g_suite_rec_tbl.APPLIED_TO_APPLICATION_ID.delete;
   g_suite_rec_tbl.APPLIED_TO_ENTITY_CODE.delete;
   g_suite_rec_tbl.APPLIED_TO_EVENT_CLASS_CODE.delete;
   g_suite_rec_tbl.APPLIED_TO_TRX_ID.delete;
   g_suite_rec_tbl.APPLIED_TO_TRX_LINE_ID.delete;
   g_suite_rec_tbl.TRX_LINE_NUMBER.delete;
   g_suite_rec_tbl.TRX_NUMBER.delete;
   g_suite_rec_tbl.TRX_DESCRIPTION.delete;
   g_suite_rec_tbl.TRX_COMMUNICATED_DATE.delete;
   g_suite_rec_tbl.TRX_LINE_GL_DATE.delete;
   g_suite_rec_tbl.BATCH_SOURCE_ID.delete;
   g_suite_rec_tbl.BATCH_SOURCE_NAME.delete;
   g_suite_rec_tbl.DOC_SEQ_ID.delete;
   g_suite_rec_tbl.DOC_SEQ_NAME.delete;
   g_suite_rec_tbl.DOC_SEQ_VALUE.delete;
   g_suite_rec_tbl.TRX_DUE_DATE.delete;
   g_suite_rec_tbl.TRX_TYPE_DESCRIPTION.delete;
   g_suite_rec_tbl.MERCHANT_PARTY_NAME.delete;
   g_suite_rec_tbl.MERCHANT_PARTY_REFERENCE.delete;
   g_suite_rec_tbl.MERCHANT_PARTY_TAXPAYER_ID.delete;
   g_suite_rec_tbl.MERCHANT_PARTY_TAX_REG_NUMBER.delete;
   g_suite_rec_tbl.DOCUMENT_SUB_TYPE.delete;
   g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_NUMBER.delete;
   g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_DATE.delete;
   g_suite_rec_tbl.SUPPLIER_EXCHANGE_RATE.delete;
   g_suite_rec_tbl.EXCHANGE_RATE_VARIANCE.delete;
   g_suite_rec_tbl.BASE_INVOICE_PRICE_VARIANCE.delete;
   g_suite_rec_tbl.TAX_INVOICE_DATE.delete;
   g_suite_rec_tbl.TAX_INVOICE_NUMBER.delete;
   g_suite_rec_tbl.SUMMARY_TAX_LINE_NUMBER.delete;
   g_suite_rec_tbl.TAX_REGIME_CODE.delete;
   g_suite_rec_tbl.TAX_JURISDICTION_ID.delete;
   g_suite_rec_tbl.TAX.delete;
   g_suite_rec_tbl.TAX_STATUS_CODE.delete;
   g_suite_rec_tbl.RECOVERY_TYPE_CODE.delete;
   g_suite_rec_tbl.RECOVERY_RATE_CODE.delete;
   g_suite_rec_tbl.TAX_RATE_CODE.delete;
   g_suite_rec_tbl.RECOVERABLE_FLAG.delete;
   g_suite_rec_tbl.FREEZE_FLAG.delete;
   g_suite_rec_tbl.POSTING_FLAG.delete;
   g_suite_rec_tbl.TAX_RATE.delete;
   g_suite_rec_tbl.TAX_AMT.delete;
   g_suite_rec_tbl.REC_NREC_TAX_AMT.delete;
   g_suite_rec_tbl.TAXABLE_AMT.delete;
   g_suite_rec_tbl.REC_NREC_TAX_AMT_FUNCL_CURR.delete;
   g_suite_rec_tbl.REC_NREC_CCID.delete;
   g_suite_rec_tbl.REVERSING_ENTITY_CODE.delete;
   g_suite_rec_tbl.REVERSING_EVNT_CLS_CODE.delete;
   g_suite_rec_tbl.REVERSING_TRX_ID.delete;
   g_suite_rec_tbl.REVERSING_TRX_LINE_DIST_ID.delete;
   g_suite_rec_tbl.REVERSING_TRX_LEVEL_TYPE.delete;
   g_suite_rec_tbl.REVERSING_TRX_LINE_ID.delete;
   g_suite_rec_tbl.REVERSED_APPLN_ID.delete;
   g_suite_rec_tbl.REVERSED_ENTITY_CODE.delete;
   g_suite_rec_tbl.REVERSED_EVNT_CLS_CODE.delete;
   g_suite_rec_tbl.REVERSED_TRX_ID.delete;
   g_suite_rec_tbl.REVERSED_TRX_LEVEL_TYPE.delete;
   g_suite_rec_tbl.REVERSED_TRX_LINE_ID.delete;
   g_suite_rec_tbl.REVERSE_FLAG.delete;
   g_suite_rec_tbl.CANCEL_FLAG.delete;
   g_suite_rec_tbl.TRX_LINE_DIST_ID.delete;
   g_suite_rec_tbl.REVERSED_TAX_DIST_ID.delete;
   g_suite_rec_tbl.DIST_LEVEL_ACTION.delete;
   g_suite_rec_tbl.TRX_LINE_DIST_DATE.delete;
   g_suite_rec_tbl.ITEM_DIST_NUMBER.delete;
   g_suite_rec_tbl.DIST_INTENDED_USE.delete;
   g_suite_rec_tbl.TASK_ID.delete;
   g_suite_rec_tbl.AWARD_ID.delete;
   g_suite_rec_tbl.PROJECT_ID.delete;
   g_suite_rec_tbl.EXPENDITURE_TYPE.delete;
   g_suite_rec_tbl.EXPENDITURE_ORGANIZATION_ID.delete;
   g_suite_rec_tbl.EXPENDITURE_ITEM_DATE.delete;
   g_suite_rec_tbl.TRX_LINE_DIST_AMT.delete;
   g_suite_rec_tbl.TRX_LINE_DIST_QUANTITY.delete;
   g_suite_rec_tbl.REF_DOC_DIST_ID.delete;
   g_suite_rec_tbl.REF_DOC_CURR_CONV_RATE.delete;
   g_suite_rec_tbl.TAX_DIST_ID.delete;
   g_suite_rec_tbl.LINE_AMT_INCLUDES_TAX_FLAG.delete;
   g_suite_rec_tbl.DEFAULT_TAXATION_COUNTRY.delete;
   g_suite_rec_tbl.VALIDATION_CHECK_FLAG.delete;
   g_suite_rec_tbl.FIRST_PTY_ORG_ID.delete;
   g_suite_rec_tbl.RDNG_SHIP_TO_PTY_TX_PROF_ID.delete;
   g_suite_rec_tbl.RDNG_SHIP_FROM_PTY_TX_PROF_ID.delete;
   g_suite_rec_tbl.RDNG_BILL_TO_PTY_TX_PROF_ID.delete;
   g_suite_rec_tbl.RDNG_BILL_FROM_PTY_TX_PROF_ID.delete;
   g_suite_rec_tbl.RDNG_SHIP_TO_PTY_TX_P_ST_ID.delete;
   g_suite_rec_tbl.RDNG_SHIP_FROM_PTY_TX_P_ST_ID.delete;
   g_suite_rec_tbl.RDNG_BILL_TO_PTY_TX_P_ST_ID.delete;
   g_suite_rec_tbl.RDNG_BILL_FROM_PTY_TX_P_ST_ID.delete;
   g_suite_rec_tbl.ASSESSABLE_VALUE.delete;
   g_suite_rec_tbl.ASSET_ACCUM_DEPRECIATION.delete;
   g_suite_rec_tbl.ASSET_COST.delete;
   g_suite_rec_tbl.ASSET_FLAG.delete;
   g_suite_rec_tbl.ASSET_NUMBER.delete;
   g_suite_rec_tbl.ASSET_TYPE.delete;
   g_suite_rec_tbl.BILL_FROM_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.BILL_FROM_SITE_TAX_PROF_ID.delete;
   g_suite_rec_tbl.BILL_TO_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.BILL_TO_SITE_TAX_PROF_ID.delete;
   g_suite_rec_tbl.CTRL_HDR_TX_APPL_FLAG.delete;
   g_suite_rec_tbl.CTRL_TOTAL_LINE_TX_AMT.delete;
   g_suite_rec_tbl.ENTITY_CODE.delete;
   g_suite_rec_tbl.EVENT_CLASS_CODE.delete;
   g_suite_rec_tbl.HQ_ESTB_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.LINE_CLASS.delete;
   g_suite_rec_tbl.MERCHANT_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.OWN_HQ_LOCATION_ID.delete;
   g_suite_rec_tbl.OWN_HQ_PARTY_ID.delete;
   g_suite_rec_tbl.OWN_HQ_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.OWN_HQ_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.OWN_HQ_SITE_TAX_PROF_ID.delete;
   g_suite_rec_tbl.PAYING_LOCATION_ID.delete;
   g_suite_rec_tbl.PAYING_PARTY_ID.delete;
   g_suite_rec_tbl.PAYING_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.PAYING_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.PAYING_SITE_TAX_PROF_ID.delete;
   g_suite_rec_tbl.POA_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.POA_SITE_TAX_PROF_ID.delete;
   g_suite_rec_tbl.POC_LOCATION_ID.delete;
   g_suite_rec_tbl.POD_LOCATION_ID.delete;
   g_suite_rec_tbl.POD_PARTY_ID.delete;
   g_suite_rec_tbl.POD_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.POD_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.POD_SITE_TAX_PROF_ID.delete;
   g_suite_rec_tbl.POI_LOCATION_ID.delete;
   g_suite_rec_tbl.POI_PARTY_ID.delete;
   g_suite_rec_tbl.POI_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.POI_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.POI_SITE_TAX_PROF_ID.delete;
   g_suite_rec_tbl.POO_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.POO_SITE_TAX_PROF_ID.delete;
   g_suite_rec_tbl.SHIP_FROM_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.SHIP_FROM_SITE_TAX_PROF_ID.delete;
   g_suite_rec_tbl.SHIP_TO_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.SHIP_TO_SITE_TAX_PROF_ID.delete;
   g_suite_rec_tbl.TITLE_TRANS_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.TITLE_TRANS_SITE_TAX_PROF_ID.delete;
   g_suite_rec_tbl.TITLE_TRANSFER_LOCATION_ID.delete;
   g_suite_rec_tbl.TITLE_TRANSFER_PARTY_ID.delete;
   g_suite_rec_tbl.TITLE_TRANSFER_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.TRADING_HQ_LOCATION_ID.delete;
   g_suite_rec_tbl.TRADING_HQ_PARTY_ID.delete;
   g_suite_rec_tbl.TRADING_HQ_PARTY_SITE_ID.delete;
   g_suite_rec_tbl.TRADING_HQ_PARTY_TAX_PROF_ID.delete;
   g_suite_rec_tbl.TRADING_HQ_SITE_TAX_PROF_ID.delete;
   g_suite_rec_tbl.TRX_ID_LEVEL2.delete;
   g_suite_rec_tbl.TRX_ID_LEVEL3.delete;
   g_suite_rec_tbl.TRX_ID_LEVEL4.delete;
   g_suite_rec_tbl.TRX_ID_LEVEL5.delete;
   g_suite_rec_tbl.TRX_ID_LEVEL6.delete;
   g_suite_rec_tbl.PORT_OF_ENTRY_CODE.delete;
   g_suite_rec_tbl.SHIP_THIRD_PTY_ACCT_ID.delete;
   g_suite_rec_tbl.BILL_THIRD_PTY_ACCT_ID.delete;
   g_suite_rec_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID.delete;
   g_suite_rec_tbl.BILL_THIRD_PTY_ACCT_SITE_ID.delete;
   g_suite_rec_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID.delete;
   g_suite_rec_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID.delete;

   END delete_table;



/* ======================================================================*
 | PROCEDURE initialize_row :     Initialize a row of record of tables   |
 * ======================================================================*/

  PROCEDURE Initialize_row(p_record_counter IN NUMBER) IS

  BEGIN
   g_suite_rec_tbl.ROW_ID(p_record_counter)                        := NULL;
   g_suite_rec_tbl.ROW_SUITE(p_record_counter)                     := NULL;
   g_suite_rec_tbl.ROW_CASE(p_record_counter)                      := NULL;
   g_suite_rec_tbl.ROW_API(p_record_counter)                       := NULL;
   g_suite_rec_tbl.ROW_SERVICE(p_record_counter)                   := NULL;
   g_suite_rec_tbl.ROW_STRUCTURE(p_record_counter)                 := NULL;
   g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(p_record_counter)      := NULL;
   g_suite_rec_tbl.INTERNAL_ORG_LOCATION_ID(p_record_counter)      := NULL;
   g_suite_rec_tbl.APPLICATION_ID(p_record_counter)                := NULL;
   g_suite_rec_tbl.ENTITY_CODE(p_record_counter)                   := NULL;
   g_suite_rec_tbl.EVENT_CLASS_CODE(p_record_counter)              := NULL;
   g_suite_rec_tbl.TAX_EVENT_CLASS_CODE(p_record_counter)          := NULL;
   g_suite_rec_tbl.DOC_EVENT_STATUS(p_record_counter)              := NULL;
   g_suite_rec_tbl.TAX_HOLD_RELEASED_CODE(p_record_counter)        := NULL;
   g_suite_rec_tbl.EVENT_TYPE_CODE(p_record_counter)               := NULL;
   g_suite_rec_tbl.TRX_ID(p_record_counter)                        := NULL;
   g_suite_rec_tbl.OVERRIDE_LEVEL(p_record_counter)                := NULL;
   g_suite_rec_tbl.TRX_LEVEL_TYPE(p_record_counter)                := NULL;
   g_suite_rec_tbl.TRX_LINE_ID(p_record_counter)                   := NULL;
   g_suite_rec_tbl.TRX_WAYBILL_NUMBER(p_record_counter)            := NULL;
   g_suite_rec_tbl.TRX_LINE_DESCRIPTION(p_record_counter)          := NULL;
   g_suite_rec_tbl.PRODUCT_DESCRIPTION(p_record_counter)           := NULL;
   g_suite_rec_tbl.TAX_LINE_ID(p_record_counter)                   := NULL;
   g_suite_rec_tbl.SUMMARY_TAX_LINE_ID(p_record_counter)           := NULL;
   g_suite_rec_tbl.INVOICE_PRICE_VARIANCE(p_record_counter)        := NULL;
   g_suite_rec_tbl.LINE_LEVEL_ACTION(p_record_counter)             := NULL;
   g_suite_rec_tbl.TAX_CLASSIFICATION_CODE(p_record_counter)       := NULL;
   g_suite_rec_tbl.TRX_DATE(p_record_counter)                      := NULL;
   g_suite_rec_tbl.TRX_DOC_REVISION(p_record_counter)              := NULL;
   g_suite_rec_tbl.LEDGER_ID(p_record_counter)                     := NULL;
   g_suite_rec_tbl.TAX_RATE_ID(p_record_counter)                   := NULL;
   g_suite_rec_tbl.TRX_CURRENCY_CODE(p_record_counter)             := NULL;
   g_suite_rec_tbl.CURRENCY_CONVERSION_DATE(p_record_counter)      := NULL;
   g_suite_rec_tbl.CURRENCY_CONVERSION_RATE(p_record_counter)      := NULL;
   g_suite_rec_tbl.CURRENCY_CONVERSION_TYPE(p_record_counter)      := NULL;
   g_suite_rec_tbl.MINIMUM_ACCOUNTABLE_UNIT(p_record_counter)      := NULL;
   g_suite_rec_tbl.PRECISION(p_record_counter)                     := NULL;
   g_suite_rec_tbl.TRX_SHIPPING_DATE(p_record_counter)             := NULL;
   g_suite_rec_tbl.TRX_RECEIPT_DATE(p_record_counter)              := NULL;
   g_suite_rec_tbl.LEGAL_ENTITY_ID(p_record_counter)               := NULL;
   g_suite_rec_tbl.REVERSING_APPLN_ID(p_record_counter)            := NULL;
   g_suite_rec_tbl.ROUNDING_SHIP_TO_PARTY_ID(p_record_counter)     := NULL;
   g_suite_rec_tbl.ROUNDING_SHIP_FROM_PARTY_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.ROUNDING_BILL_TO_PARTY_ID(p_record_counter)     := NULL;
   g_suite_rec_tbl.ROUNDING_BILL_FROM_PARTY_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(p_record_counter)    := NULL;
   g_suite_rec_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(p_record_counter)  := NULL;
   g_suite_rec_tbl.RNDG_BILL_TO_PARTY_SITE_ID(p_record_counter)    := NULL;
   g_suite_rec_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(p_record_counter)  := NULL;
   g_suite_rec_tbl.ESTABLISHMENT_ID(p_record_counter)              := NULL;
   g_suite_rec_tbl.TAX_EXEMPTION_ID(p_record_counter)              := NULL;
   g_suite_rec_tbl.REC_NREC_TAX_DIST_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.TAX_APPORTIONMENT_LINE_NUMBER(p_record_counter) := NULL;
   g_suite_rec_tbl.EXEMPTION_RATE(p_record_counter)                := NULL;
   g_suite_rec_tbl.TOTAL_NREC_TAX_AMT(p_record_counter)            := NULL;
   g_suite_rec_tbl.TOTAL_REC_TAX_AMT(p_record_counter)             := NULL;
   g_suite_rec_tbl.REC_TAX_AMT(p_record_counter)                   := NULL;
   g_suite_rec_tbl.NREC_TAX_AMT(p_record_counter)                  := NULL;
   g_suite_rec_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER(p_record_counter):= NULL;
   g_suite_rec_tbl.TRX_LINE_TYPE(p_record_counter)                 := NULL;
   g_suite_rec_tbl.TAX_REGISTRATION_NUMBER(p_record_counter)       := NULL;
   g_suite_rec_tbl.CTRL_TOTAL_HDR_TX_AMT(p_record_counter)         := NULL;
   g_suite_rec_tbl.EXEMPT_REASON_CODE(p_record_counter)            := NULL;
   g_suite_rec_tbl.TAX_HOLD_CODE(p_record_counter)                 := NULL;
   g_suite_rec_tbl.TAX_AMT_FUNCL_CURR(p_record_counter)            := NULL;
   g_suite_rec_tbl.TOTAL_REC_TAX_AMT_FUNCL_CURR(p_record_counter)  := NULL;
   g_suite_rec_tbl.TOTAL_NREC_TAX_AMT_FUNCL_CURR(p_record_counter) := NULL;
   g_suite_rec_tbl.TAXABLE_AMT_FUNCL_CURR(p_record_counter)        := NULL;
   g_suite_rec_tbl.REC_TAX_AMT_FUNCL_CURR(p_record_counter)        := NULL;
   g_suite_rec_tbl.NREC_TAX_AMT_FUNCL_CURR(p_record_counter)       := NULL;
   g_suite_rec_tbl.TRX_LINE_DATE(p_record_counter)                 := NULL;
   g_suite_rec_tbl.TRX_BUSINESS_CATEGORY(p_record_counter)         := NULL;
   g_suite_rec_tbl.LINE_INTENDED_USE(p_record_counter)             := NULL;
   g_suite_rec_tbl.USER_DEFINED_FISC_CLASS(p_record_counter)       := NULL;
   g_suite_rec_tbl.TAX_CODE(p_record_counter)                      := NULL;
   g_suite_rec_tbl.TAX_INCLUSION_FLAG(p_record_counter)            := NULL;
   g_suite_rec_tbl.TAX_AMT_INCLUDED_FLAG(p_record_counter)         := NULL;
   g_suite_rec_tbl.SELF_ASSESSED_FLAG(p_record_counter)            := NULL;
   g_suite_rec_tbl.QUOTE_FLAG(p_record_counter)                    := NULL;
   g_suite_rec_tbl.HISTORICAL_FLAG(p_record_counter)               := NULL;
   g_suite_rec_tbl.MANUALLY_ENTERED_FLAG(p_record_counter)         := NULL;
   g_suite_rec_tbl.LINE_AMT(p_record_counter)                      := NULL;
   g_suite_rec_tbl.TRX_LINE_QUANTITY(p_record_counter)             := NULL;
   g_suite_rec_tbl.UNIT_PRICE(p_record_counter)                    := NULL;
   g_suite_rec_tbl.EXEMPT_CERTIFICATE_NUMBER(p_record_counter)     := NULL;
   g_suite_rec_tbl.EXEMPT_REASON(p_record_counter)                 := NULL;
   g_suite_rec_tbl.CASH_DISCOUNT(p_record_counter)                 := NULL;
   g_suite_rec_tbl.VOLUME_DISCOUNT(p_record_counter)               := NULL;
   g_suite_rec_tbl.TRADING_DISCOUNT(p_record_counter)              := NULL;
   g_suite_rec_tbl.TRANSFER_CHARGE(p_record_counter)               := NULL;
   g_suite_rec_tbl.TRANSPORTATION_CHARGE(p_record_counter)         := NULL;
   g_suite_rec_tbl.INSURANCE_CHARGE(p_record_counter)              := NULL;
   g_suite_rec_tbl.OTHER_CHARGE(p_record_counter)                  := NULL;
   g_suite_rec_tbl.PRODUCT_ID(p_record_counter)                    := NULL;
   g_suite_rec_tbl.PRODUCT_FISC_CLASSIFICATION(p_record_counter)   := NULL;
   g_suite_rec_tbl.PRODUCT_ORG_ID(p_record_counter)                := NULL;
   g_suite_rec_tbl.UOM_CODE(p_record_counter)                      := NULL;
   g_suite_rec_tbl.PRODUCT_TYPE(p_record_counter)                  := NULL;
   g_suite_rec_tbl.PRODUCT_CODE(p_record_counter)                  := NULL;
   g_suite_rec_tbl.PRODUCT_CATEGORY(p_record_counter)              := NULL;
   g_suite_rec_tbl.TRX_SIC_CODE(p_record_counter)                  := NULL;
   g_suite_rec_tbl.FOB_POINT(p_record_counter)                     := NULL;
   g_suite_rec_tbl.SHIP_TO_PARTY_ID(p_record_counter)              := NULL;
   g_suite_rec_tbl.SHIP_FROM_PARTY_ID(p_record_counter)            := NULL;
   g_suite_rec_tbl.POA_PARTY_ID(p_record_counter)                  := NULL;
   g_suite_rec_tbl.POO_PARTY_ID(p_record_counter)                  := NULL;
   g_suite_rec_tbl.BILL_TO_PARTY_ID(p_record_counter)              := NULL;
   g_suite_rec_tbl.BILL_FROM_PARTY_ID(p_record_counter)            := NULL;
   g_suite_rec_tbl.MERCHANT_PARTY_ID(p_record_counter)             := NULL;
   g_suite_rec_tbl.SHIP_TO_PARTY_SITE_ID(p_record_counter)         := NULL;
   g_suite_rec_tbl.SHIP_FROM_PARTY_SITE_ID(p_record_counter)       := NULL;
   g_suite_rec_tbl.POA_PARTY_SITE_ID(p_record_counter)             := NULL;
   g_suite_rec_tbl.POO_PARTY_SITE_ID(p_record_counter)             := NULL;
   g_suite_rec_tbl.BILL_TO_PARTY_SITE_ID(p_record_counter)         := NULL;
   g_suite_rec_tbl.BILL_FROM_PARTY_SITE_ID(p_record_counter)       := NULL;
   g_suite_rec_tbl.SHIP_TO_LOCATION_ID(p_record_counter)           := NULL;
   g_suite_rec_tbl.SHIP_FROM_LOCATION_ID(p_record_counter)         := NULL;
   g_suite_rec_tbl.POA_LOCATION_ID(p_record_counter)               := NULL;
   g_suite_rec_tbl.POO_LOCATION_ID(p_record_counter)               := NULL;
   g_suite_rec_tbl.BILL_TO_LOCATION_ID(p_record_counter)           := NULL;
   g_suite_rec_tbl.BILL_FROM_LOCATION_ID(p_record_counter)         := NULL;
   g_suite_rec_tbl.ACCOUNT_CCID(p_record_counter)                  := NULL;
   g_suite_rec_tbl.ACCOUNT_STRING(p_record_counter)                := NULL;
   g_suite_rec_tbl.MERCHANT_PARTY_COUNTRY(p_record_counter)        := NULL;
   g_suite_rec_tbl.RECEIVABLES_TRX_TYPE_ID(p_record_counter)       := NULL;
   g_suite_rec_tbl.REF_DOC_APPLICATION_ID(p_record_counter)        := NULL;
   g_suite_rec_tbl.REF_DOC_ENTITY_CODE(p_record_counter)           := NULL;
   g_suite_rec_tbl.REF_DOC_EVENT_CLASS_CODE(p_record_counter)      := NULL;
   g_suite_rec_tbl.REF_DOC_TRX_ID(p_record_counter)                := NULL;
   g_suite_rec_tbl.REF_DOC_LINE_ID(p_record_counter)               := NULL;
   g_suite_rec_tbl.REF_DOC_LINE_QUANTITY(p_record_counter)         := NULL;
   g_suite_rec_tbl.RELATED_DOC_APPLICATION_ID(p_record_counter)    := NULL;
   g_suite_rec_tbl.RELATED_DOC_ENTITY_CODE(p_record_counter)       := NULL;
   g_suite_rec_tbl.RELATED_DOC_EVENT_CLASS_CODE(p_record_counter)  := NULL;
   g_suite_rec_tbl.RELATED_DOC_TRX_ID(p_record_counter)            := NULL;
   g_suite_rec_tbl.RELATED_DOC_NUMBER(p_record_counter)            := NULL;
   g_suite_rec_tbl.RELATED_DOC_DATE(p_record_counter)              := NULL;
   g_suite_rec_tbl.APPLIED_FROM_APPLICATION_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.APPLIED_FROM_ENTITY_CODE(p_record_counter)      := NULL;
   g_suite_rec_tbl.APPLIED_FROM_EVENT_CLASS_CODE(p_record_counter) := NULL;
   g_suite_rec_tbl.APPLIED_FROM_TRX_ID(p_record_counter)           := NULL;
   g_suite_rec_tbl.APPLIED_FROM_LINE_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.ADJUSTED_DOC_APPLICATION_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.ADJUSTED_DOC_ENTITY_CODE(p_record_counter)      := NULL;
   g_suite_rec_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(p_record_counter) := NULL;
   g_suite_rec_tbl.ADJUSTED_DOC_TRX_ID(p_record_counter)           := NULL;
   g_suite_rec_tbl.ADJUSTED_DOC_LINE_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.ADJUSTED_DOC_NUMBER(p_record_counter)           := NULL;
   g_suite_rec_tbl.ASSESSABLE_VALUE(p_record_counter)              := NULL;
   g_suite_rec_tbl.ADJUSTED_DOC_DATE(p_record_counter)             := NULL;
   g_suite_rec_tbl.APPLIED_TO_APPLICATION_ID(p_record_counter)     := NULL;
   g_suite_rec_tbl.APPLIED_TO_ENTITY_CODE(p_record_counter)        := NULL;
   g_suite_rec_tbl.APPLIED_TO_EVENT_CLASS_CODE(p_record_counter)   := NULL;
   g_suite_rec_tbl.APPLIED_TO_TRX_ID(p_record_counter)             := NULL;
   g_suite_rec_tbl.APPLIED_TO_TRX_LINE_ID(p_record_counter)        := NULL;
   g_suite_rec_tbl.TRX_LINE_NUMBER(p_record_counter)               := NULL;
   g_suite_rec_tbl.TRX_NUMBER(p_record_counter)                    := NULL;
   g_suite_rec_tbl.TRX_DESCRIPTION(p_record_counter)               := NULL;
   g_suite_rec_tbl.TRX_COMMUNICATED_DATE(p_record_counter)         := NULL;
   g_suite_rec_tbl.TRX_LINE_GL_DATE(p_record_counter)              := NULL;
   g_suite_rec_tbl.BATCH_SOURCE_ID(p_record_counter)               := NULL;
   g_suite_rec_tbl.BATCH_SOURCE_NAME(p_record_counter)             := NULL;
   g_suite_rec_tbl.DOC_SEQ_ID(p_record_counter)                    := NULL;
   g_suite_rec_tbl.DOC_SEQ_NAME(p_record_counter)                  := NULL;
   g_suite_rec_tbl.DOC_SEQ_VALUE(p_record_counter)                 := NULL;
   g_suite_rec_tbl.TRX_DUE_DATE(p_record_counter)                  := NULL;
   g_suite_rec_tbl.TRX_TYPE_DESCRIPTION(p_record_counter)          := NULL;
   g_suite_rec_tbl.MERCHANT_PARTY_NAME(p_record_counter)           := NULL;
   g_suite_rec_tbl.MERCHANT_PARTY_REFERENCE(p_record_counter)      := NULL;
   g_suite_rec_tbl.MERCHANT_PARTY_TAXPAYER_ID(p_record_counter)    := NULL;
   g_suite_rec_tbl.MERCHANT_PARTY_TAX_REG_NUMBER(p_record_counter) := NULL;
   g_suite_rec_tbl.DOCUMENT_SUB_TYPE(p_record_counter)             := NULL;
   g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_NUMBER(p_record_counter)   := NULL;
   g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_DATE(p_record_counter)     := NULL;
   g_suite_rec_tbl.SUPPLIER_EXCHANGE_RATE(p_record_counter)        := NULL;
   g_suite_rec_tbl.EXCHANGE_RATE_VARIANCE(p_record_counter)        := NULL;
   g_suite_rec_tbl.BASE_INVOICE_PRICE_VARIANCE(p_record_counter)   := NULL;
   g_suite_rec_tbl.TAX_INVOICE_DATE(p_record_counter)              := NULL;
   g_suite_rec_tbl.TAX_INVOICE_NUMBER(p_record_counter)            := NULL;
   g_suite_rec_tbl.SUMMARY_TAX_LINE_NUMBER(p_record_counter)       := NULL;
   g_suite_rec_tbl.TAX_REGIME_CODE(p_record_counter)               := NULL;
   g_suite_rec_tbl.TAX_JURISDICTION_ID(p_record_counter)           := NULL;
   g_suite_rec_tbl.TAX(p_record_counter)                           := NULL;
   g_suite_rec_tbl.TAX_STATUS_CODE(p_record_counter)               := NULL;
   g_suite_rec_tbl.RECOVERY_TYPE_CODE(p_record_counter)            := NULL;
   g_suite_rec_tbl.RECOVERY_RATE_CODE(p_record_counter)            := NULL;
   g_suite_rec_tbl.TAX_RATE_CODE(p_record_counter)                 := NULL;
   g_suite_rec_tbl.RECOVERABLE_FLAG(p_record_counter)              := NULL;
   g_suite_rec_tbl.FREEZE_FLAG(p_record_counter)                   := NULL;
   g_suite_rec_tbl.POSTING_FLAG(p_record_counter)                  := NULL;
   g_suite_rec_tbl.TAX_RATE(p_record_counter)                      := NULL;
   g_suite_rec_tbl.TAX_AMT(p_record_counter)                       := NULL;
   g_suite_rec_tbl.REC_NREC_TAX_AMT(p_record_counter)              := NULL;
   g_suite_rec_tbl.TAXABLE_AMT(p_record_counter)                   := NULL;
   g_suite_rec_tbl.REC_NREC_TAX_AMT_FUNCL_CURR(p_record_counter)   := NULL;
   g_suite_rec_tbl.REC_NREC_CCID(p_record_counter)                 := NULL;
   g_suite_rec_tbl.REVERSING_ENTITY_CODE(p_record_counter)         := NULL;
   g_suite_rec_tbl.REVERSING_EVNT_CLS_CODE(p_record_counter)       := NULL;
   g_suite_rec_tbl.REVERSING_TRX_ID(p_record_counter)              := NULL;
   g_suite_rec_tbl.REVERSING_TRX_LINE_DIST_ID(p_record_counter)    := NULL;
   g_suite_rec_tbl.REVERSING_TRX_LEVEL_TYPE(p_record_counter)      := NULL;
   g_suite_rec_tbl.REVERSING_TRX_LINE_ID(p_record_counter)         := NULL;
   g_suite_rec_tbl.REVERSED_APPLN_ID(p_record_counter)             := NULL;
   g_suite_rec_tbl.REVERSED_ENTITY_CODE(p_record_counter)          := NULL;
   g_suite_rec_tbl.REVERSED_EVNT_CLS_CODE(p_record_counter)        := NULL;
   g_suite_rec_tbl.REVERSED_TRX_ID(p_record_counter)               := NULL;
   g_suite_rec_tbl.REVERSED_TRX_LEVEL_TYPE(p_record_counter)       := NULL;
   g_suite_rec_tbl.REVERSED_TRX_LINE_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.REVERSE_FLAG(p_record_counter)                  := NULL;
   g_suite_rec_tbl.CANCEL_FLAG(p_record_counter)                   := NULL;
   g_suite_rec_tbl.TRX_LINE_DIST_ID(p_record_counter)              := NULL;
   g_suite_rec_tbl.REVERSED_TAX_DIST_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.DIST_LEVEL_ACTION(p_record_counter)             := NULL;
   g_suite_rec_tbl.TRX_LINE_DIST_DATE(p_record_counter)            := NULL;
   g_suite_rec_tbl.ITEM_DIST_NUMBER(p_record_counter)              := NULL;
   g_suite_rec_tbl.DIST_INTENDED_USE(p_record_counter)             := NULL;
   g_suite_rec_tbl.TASK_ID(p_record_counter)                       := NULL;
   g_suite_rec_tbl.AWARD_ID(p_record_counter)                      := NULL;
   g_suite_rec_tbl.PROJECT_ID(p_record_counter)                    := NULL;
   g_suite_rec_tbl.EXPENDITURE_TYPE(p_record_counter)              := NULL;
   g_suite_rec_tbl.EXPENDITURE_ORGANIZATION_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.EXPENDITURE_ITEM_DATE(p_record_counter)         := NULL;
   g_suite_rec_tbl.TRX_LINE_DIST_AMT(p_record_counter)             := NULL;
   g_suite_rec_tbl.TRX_LINE_DIST_QUANTITY(p_record_counter)        := NULL;
   g_suite_rec_tbl.REF_DOC_DIST_ID(p_record_counter)               := NULL;
   g_suite_rec_tbl.REF_DOC_CURR_CONV_RATE(p_record_counter)        := NULL;
   g_suite_rec_tbl.TAX_DIST_ID(p_record_counter)                   := NULL;
   g_suite_rec_tbl.LINE_AMT_INCLUDES_TAX_FLAG(p_record_counter)    := NULL;
   g_suite_rec_tbl.DEFAULT_TAXATION_COUNTRY(p_record_counter)      := NULL;
   g_suite_rec_tbl.VALIDATION_CHECK_FLAG(p_record_counter)         := NULL;
   g_suite_rec_tbl.FIRST_PTY_ORG_ID(p_record_counter)              := NULL;
   g_suite_rec_tbl.RDNG_SHIP_TO_PTY_TX_PROF_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.RDNG_SHIP_FROM_PTY_TX_PROF_ID(p_record_counter) := NULL;
   g_suite_rec_tbl.RDNG_BILL_TO_PTY_TX_PROF_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.RDNG_BILL_FROM_PTY_TX_PROF_ID(p_record_counter) := NULL;
   g_suite_rec_tbl.RDNG_SHIP_TO_PTY_TX_P_ST_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.RDNG_SHIP_FROM_PTY_TX_P_ST_ID(p_record_counter) := NULL;
   g_suite_rec_tbl.RDNG_BILL_TO_PTY_TX_P_ST_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.RDNG_BILL_FROM_PTY_TX_P_ST_ID(p_record_counter) := NULL;
   g_suite_rec_tbl.ASSESSABLE_VALUE(p_record_counter)              := NULL;
   g_suite_rec_tbl.ASSET_ACCUM_DEPRECIATION(p_record_counter)      := NULL;
   g_suite_rec_tbl.ASSET_COST(p_record_counter)                    := NULL;
   g_suite_rec_tbl.ASSET_FLAG(p_record_counter)                    := NULL;
   g_suite_rec_tbl.ASSET_NUMBER(p_record_counter)                  := NULL;
   g_suite_rec_tbl.ASSET_TYPE(p_record_counter)                    := NULL;
   g_suite_rec_tbl.BILL_FROM_PARTY_TAX_PROF_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.BILL_FROM_SITE_TAX_PROF_ID(p_record_counter)    := NULL;
   g_suite_rec_tbl.BILL_TO_PARTY_TAX_PROF_ID(p_record_counter)     := NULL;
   g_suite_rec_tbl.BILL_TO_SITE_TAX_PROF_ID(p_record_counter)      := NULL;
   g_suite_rec_tbl.CTRL_HDR_TX_APPL_FLAG(p_record_counter)         := NULL;
   g_suite_rec_tbl.CTRL_TOTAL_LINE_TX_AMT(p_record_counter)        := NULL;
   g_suite_rec_tbl.ENTITY_CODE(p_record_counter)                   := NULL;
   g_suite_rec_tbl.EVENT_CLASS_CODE(p_record_counter)              := NULL;
   g_suite_rec_tbl.HQ_ESTB_PARTY_TAX_PROF_ID(p_record_counter)     := NULL;
   g_suite_rec_tbl.LINE_CLASS(p_record_counter)                    := NULL;
   g_suite_rec_tbl.MERCHANT_PARTY_TAX_PROF_ID(p_record_counter)    := NULL;
   g_suite_rec_tbl.OWN_HQ_LOCATION_ID(p_record_counter)            := NULL;
   g_suite_rec_tbl.OWN_HQ_PARTY_ID(p_record_counter)               := NULL;
   g_suite_rec_tbl.OWN_HQ_PARTY_SITE_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.OWN_HQ_PARTY_TAX_PROF_ID(p_record_counter)      := NULL;
   g_suite_rec_tbl.OWN_HQ_SITE_TAX_PROF_ID(p_record_counter)       := NULL;
   g_suite_rec_tbl.PAYING_LOCATION_ID(p_record_counter)            := NULL;
   g_suite_rec_tbl.PAYING_PARTY_ID(p_record_counter)               := NULL;
   g_suite_rec_tbl.PAYING_PARTY_SITE_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.PAYING_PARTY_TAX_PROF_ID(p_record_counter)      := NULL;
   g_suite_rec_tbl.PAYING_SITE_TAX_PROF_ID(p_record_counter)       := NULL;
   g_suite_rec_tbl.POA_PARTY_TAX_PROF_ID(p_record_counter)         := NULL;
   g_suite_rec_tbl.POA_SITE_TAX_PROF_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.POC_LOCATION_ID(p_record_counter)               := NULL;
   g_suite_rec_tbl.POD_LOCATION_ID(p_record_counter)               := NULL;
   g_suite_rec_tbl.POD_PARTY_ID(p_record_counter)                  := NULL;
   g_suite_rec_tbl.POD_PARTY_SITE_ID(p_record_counter)             := NULL;
   g_suite_rec_tbl.POD_PARTY_TAX_PROF_ID(p_record_counter)         := NULL;
   g_suite_rec_tbl.POD_SITE_TAX_PROF_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.POI_LOCATION_ID(p_record_counter)               := NULL;
   g_suite_rec_tbl.POI_PARTY_ID(p_record_counter)                  := NULL;
   g_suite_rec_tbl.POI_PARTY_SITE_ID(p_record_counter)             := NULL;
   g_suite_rec_tbl.POI_PARTY_TAX_PROF_ID(p_record_counter)         := NULL;
   g_suite_rec_tbl.POI_SITE_TAX_PROF_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.POO_PARTY_TAX_PROF_ID(p_record_counter)         := NULL;
   g_suite_rec_tbl.POO_SITE_TAX_PROF_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.SHIP_FROM_PARTY_TAX_PROF_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.SHIP_FROM_SITE_TAX_PROF_ID(p_record_counter)    := NULL;
   g_suite_rec_tbl.SHIP_TO_PARTY_TAX_PROF_ID(p_record_counter)     := NULL;
   g_suite_rec_tbl.SHIP_TO_SITE_TAX_PROF_ID(p_record_counter)      := NULL;
   g_suite_rec_tbl.TITLE_TRANS_PARTY_TAX_PROF_ID(p_record_counter) := NULL;
   g_suite_rec_tbl.TITLE_TRANS_SITE_TAX_PROF_ID(p_record_counter)  := NULL;
   g_suite_rec_tbl.TITLE_TRANSFER_LOCATION_ID(p_record_counter)    := NULL;
   g_suite_rec_tbl.TITLE_TRANSFER_PARTY_ID(p_record_counter)       := NULL;
   g_suite_rec_tbl.TITLE_TRANSFER_PARTY_SITE_ID(p_record_counter)  := NULL;
   g_suite_rec_tbl.TRADING_HQ_LOCATION_ID(p_record_counter)        := NULL;
   g_suite_rec_tbl.TRADING_HQ_PARTY_ID(p_record_counter)           := NULL;
   g_suite_rec_tbl.TRADING_HQ_PARTY_SITE_ID(p_record_counter)      := NULL;
   g_suite_rec_tbl.TRADING_HQ_PARTY_TAX_PROF_ID(p_record_counter)  := NULL;
   g_suite_rec_tbl.TRADING_HQ_SITE_TAX_PROF_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.TRX_ID_LEVEL2(p_record_counter)                 := NULL;
   g_suite_rec_tbl.TRX_ID_LEVEL3(p_record_counter)                 := NULL;
   g_suite_rec_tbl.TRX_ID_LEVEL4(p_record_counter)                 := NULL;
   g_suite_rec_tbl.TRX_ID_LEVEL5(p_record_counter)                 := NULL;
   g_suite_rec_tbl.TRX_ID_LEVEL6(p_record_counter)                 := NULL;
   g_suite_rec_tbl.PORT_OF_ENTRY_CODE(p_record_counter)            := NULL;
   g_suite_rec_tbl.SHIP_THIRD_PTY_ACCT_ID(p_record_counter)        := NULL;
   g_suite_rec_tbl.BILL_THIRD_PTY_ACCT_ID(p_record_counter)        := NULL;
   g_suite_rec_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.BILL_THIRD_PTY_ACCT_SITE_ID(p_record_counter)   := NULL;
   g_suite_rec_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID(p_record_counter) := NULL;
   g_suite_rec_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID(p_record_counter) := NULL;


   --Missing initializations discovered while testig recovery case.

   g_suite_rec_tbl.APPLIED_FROM_TAX_DIST_ID(p_record_counter)      := NULL;
   g_suite_rec_tbl.ADJUSTED_DOC_TAX_DIST_ID(p_record_counter)      := NULL;
   g_suite_rec_tbl.TRX_LINE_DIST_TAX_AMT(p_record_counter)         := NULL;
   g_suite_rec_tbl.APPLIED_FROM_DIST_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.ADJUSTED_DOC_DIST_ID(p_record_counter)          := NULL;
   g_suite_rec_tbl.APPLIED_TO_DOC_CURR_CONV_RATE(p_record_counter) := NULL;
   g_suite_rec_tbl.TAX_VARIANCE_CALC_FLAG(p_record_counter)        := NULL;

   --Missing initializations discovered while testig Import Case.

   g_suite_rec_tbl.TAX_JURISDICTION_CODE(p_record_counter)        := NULL;
   g_suite_rec_tbl.TAX_PROVIDER_ID(p_record_counter)              := NULL;
   g_suite_rec_tbl.TAX_EXCEPTION_ID(p_record_counter)             := NULL;
   g_suite_rec_tbl.TAX_LINE_ALLOCATION_FLAG(p_record_counter)     := NULL;


   END Initialize_row;



/* ======================================================================*
 | PROCEDURE put_line_in_suite_rec_tbl : Read a line from flat file and  |
 |           puts it in the structure record of tables for the suite     |
 |           Will put the row in the indicated p_record_counter          |
 * ======================================================================*/

  PROCEDURE put_line_in_suite_rec_tbl(x_suite_number  OUT NOCOPY VARCHAR2,
                                      x_case_number   OUT NOCOPY VARCHAR2,
                                      x_api_name      OUT NOCOPY VARCHAR2,
                                      x_api_service   OUT NOCOPY VARCHAR2,
                                      x_api_structure OUT NOCOPY VARCHAR2,
                                      p_header_row     IN NUMBER,
                                      p_record_counter IN NUMBER ) IS
  l_counter                  NUMBER;
  l_element_value            VARCHAR2(2000);
  l_parameter_name           VARCHAR2(2000);
  l_return_status_p          VARCHAR2(2000);
  l_numeric_surrogate_value  NUMBER;
  l_numeric_real_value       NUMBER;
  BEGIN
    l_counter        := 0;
    l_parameter_name := null;

    -------------------------------------------------
    -- Get values from the line of file.
    -------------------------------------------------
    initialize_row(p_record_counter);

    LOOP
      l_counter := l_counter + 1;
      ------------------------------
      -- Get a Element from the Line
      ------------------------------

      get_next_element_in_row(l_element_value,l_return_status_p);

      IF l_return_status_p = 'COMPLETED' THEN
        EXIT;
      END IF;

      l_element_value := ltrim(rtrim(l_element_value));

      -------------------------------------------------------------------------------
      -- Retrieves the Suite, Case, API and Service if element in line is 1,2,3 or 4
      -------------------------------------------------------------------------------
      IF    l_counter = 1 THEN
        write_message('-------------------------------------------------------');
        write_message('--          Suite Number : '||l_element_value);
        x_suite_number:= l_element_value;
        g_suite_rec_tbl.ROW_SUITE(p_record_counter)    :=x_suite_number;

      ELSIF l_counter = 2 THEN
        write_message('--           Case Number : '||l_element_value);
        x_case_number := l_element_value;
        g_suite_rec_tbl.ROW_CASE(p_record_counter)    :=x_case_number;

      ELSIF l_counter = 3 THEN
        --Parameter 3 are the comments of the suite
        null;

      ELSIF l_counter = 4 THEN
        write_message('--                   API : '||l_element_value);
        x_api_name := l_element_value;
        g_suite_rec_tbl.ROW_API(p_record_counter)    :=x_api_name;

      ELSIF l_counter = 5 THEN
        write_message('--        APPLICATION_ID : '||l_element_value);
           get_user_key_id(l_element_value,'APPLICATION_ID',
           g_suite_rec_tbl.APPLICATION_ID(p_record_counter));
           put_data_in_party_rec(nvl(p_header_row,p_record_counter));

      ELSIF l_counter = 6 THEN
        write_message('--         DOCUMENT_NAME : '||l_element_value);

      ELSIF l_counter = 7 THEN
        write_message('-- DOCUMENT_LEVEL_ACTION : '||l_element_value);
        ------------------------------------------------------------------
        -- TAX EVENT TYPE CODE is the same as DOCUMENT LEVEL ACTION as Sri
        -- explained. So If Event Type Code is null then I will take
        -- the value of Document Level Action. Verify this later. 5-NOV-03
        ------------------------------------------------------------------
        g_suite_rec_tbl.TAX_EVENT_TYPE_CODE(p_record_counter) := l_element_value;

      ELSIF l_counter = 8 THEN
        write_message('--               Service : '||l_element_value);
        x_api_service:= l_element_value;
        g_suite_rec_tbl.ROW_SERVICE(p_record_counter)    :=x_api_service;

      ELSIF l_counter = 9 THEN
        write_message('--             Structure : '||l_element_value);
        write_message('-------------------------------------------------------');
        x_api_structure:= l_element_value;
        g_suite_rec_tbl.ROW_STRUCTURE(p_record_counter)    :=l_element_value;

      ELSE
        --------------------------------------
        -- Retrieves the elements in the line.
        --------------------------------------
        IF mod(l_counter,2) <> 1 THEN
          --------------------------------------
          -- Retrieves the Name of the Parameter
          --------------------------------------
          l_parameter_name := l_element_value;
          IF l_parameter_name IS NULL THEN
           l_return_status_p := 'LINE COMPLETED';
           EXIT;
          END IF;
        ELSE
          ---------------------------------------
          -- Retrieves the Value of the Parameter
          ---------------------------------------
          IF l_element_value is NOT NULL THEN
            write_message(/*trunc(l_counter/2)-2||*/
                          'Prm: '||rpad(l_parameter_name,32,' ')||
                          'Val: '||substr(l_element_value,1,50));
            IF    l_parameter_name= 'INTERNAL_ORGANIZATION_ID'     THEN
              get_user_key_id(l_element_value,'INTERNAL_ORGANIZATION_ID',
              g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'ENTITY_CODE'                  THEN
              g_suite_rec_tbl.ENTITY_CODE(p_record_counter):=l_element_value;
              put_data_in_party_rec(nvl(p_header_row,p_record_counter));

            ELSIF l_parameter_name= 'EVENT_CLASS_CODE'             THEN
              g_suite_rec_tbl.EVENT_CLASS_CODE(p_record_counter):=l_element_value;
              put_data_in_party_rec(nvl(p_header_row,p_record_counter));

            ELSIF l_parameter_name= 'EVENT_TYPE_CODE'              THEN
                g_suite_rec_tbl.EVENT_TYPE_CODE(p_record_counter)            :=l_element_value;
                g_suite_rec_tbl.TAX_EVENT_TYPE_CODE(p_record_counter):=
                get_tax_event_type(g_suite_rec_tbl.APPLICATION_ID(p_record_counter),
                                 g_suite_rec_tbl.ENTITY_CODE(p_record_counter),
                                 g_suite_rec_tbl.EVENT_CLASS_CODE(p_record_counter),
                                 g_suite_rec_tbl.EVENT_TYPE_CODE(p_record_counter));

            ELSIF l_parameter_name= 'TRX_ID'                       THEN
              ----------------------------------------------------------------------------
              --Create the surrogate Key if has to be created or has not been created yet.
              ----------------------------------------------------------------------------
              IF g_suite_rec_tbl.tax_event_type_code.exists(p_record_counter) then
                IF (g_suite_rec_tbl.tax_event_type_code(p_record_counter) = 'CREATE'
                   AND NOT(g_surr_trx_id_tbl.exists(l_element_value))) THEN
                   --write_message('Calling the Surrogate_Key Pkg.'||to_char(p_record_counter));
                  surrogate_key ( l_element_value,g_suite_rec_tbl.trx_id(p_record_counter),'HEADER');
                   --write_message('Calling the g_surr_trx_id_tbl.'||to_char(p_record_counter));
                   --write_message('Value in g_suite_rec_tbl_trx_id is:'||g_suite_rec_tbl.trx_id(p_record_counter));
                  g_surr_trx_id_tbl(l_element_value) := g_suite_rec_tbl.trx_id(p_record_counter);
                ELSE
                  check_surrogate_key(l_element_value,g_suite_rec_tbl.trx_id(p_record_counter),'HEADER');
                END IF;
              ELSE
                write_message('~           Tax_event_type_code does not exists');
                write_message('~           for the current record because it''s');
                write_message('~           on the header line.');
                check_surrogate_key(l_element_value,g_suite_rec_tbl.trx_id(p_record_counter),'HEADER');
              END IF;

            ELSIF l_parameter_name= 'TRX_LEVEL_TYPE'               THEN
              g_suite_rec_tbl.TRX_LEVEL_TYPE(p_record_counter)     :=l_element_value;

            ELSIF l_parameter_name= 'TRX_LINE_ID'                  THEN
              ----------------------------------------------------------------------------
              --Create the surrogate Key if has to be created or has not been created yet.
              ----------------------------------------------------------------------------
              IF g_suite_rec_tbl.tax_event_type_code.exists(p_record_counter) then
                IF (g_suite_rec_tbl.tax_event_type_code(p_record_counter) = 'CREATE'
                    AND NOT(g_surr_trx_line_id_tbl.exists(l_element_value))) THEN
                  surrogate_key(l_element_value,g_suite_rec_tbl.trx_line_id(p_record_counter),'LINE');
                  g_surr_trx_line_id_tbl(l_element_value) := g_suite_rec_tbl.trx_line_id(p_record_counter);
                ELSE
                  check_surrogate_key(l_element_value,g_suite_rec_tbl.trx_line_id(p_record_counter),'LINE');
                END IF;
              ELSE
                check_surrogate_key(l_element_value,g_suite_rec_tbl.trx_line_id(p_record_counter),'LINE');
              END IF;

            ELSIF l_parameter_name= 'LINE_LEVEL_ACTION'            THEN
              g_suite_rec_tbl.LINE_LEVEL_ACTION(p_record_counter)  :=l_element_value;

            ELSIF l_parameter_name= 'TRX_DATE'                     THEN
              g_suite_rec_tbl.TRX_DATE(p_record_counter):=
                to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'TRX_DOC_REVISION'             THEN
              g_suite_rec_tbl.TRX_DOC_REVISION(p_record_counter):=l_element_value;

            ELSIF l_parameter_name= 'LEDGER_ID'                    THEN
              get_user_key_id(l_element_value,
                              'LEDGER_ID',
                              g_suite_rec_tbl.LEDGER_ID(p_record_counter));

            ELSIF l_parameter_name= 'TRX_CURRENCY_CODE'            THEN
              g_suite_rec_tbl.TRX_CURRENCY_CODE(p_record_counter):=l_element_value;

            ELSIF l_parameter_name= 'CURRENCY_CONVERSION_DATE'     THEN
              g_suite_rec_tbl.CURRENCY_CONVERSION_DATE(p_record_counter):=
                to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'CURRENCY_CONVERSION_RATE'     THEN
              g_suite_rec_tbl.CURRENCY_CONVERSION_RATE(p_record_counter):=
                to_number(l_element_value);

            ELSIF l_parameter_name= 'CURRENCY_CONVERSION_TYPE'     THEN
              g_suite_rec_tbl.CURRENCY_CONVERSION_TYPE(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'MINIMUM_ACCOUNTABLE_UNIT'     THEN
              g_suite_rec_tbl.MINIMUM_ACCOUNTABLE_UNIT(p_record_counter):=
                to_number(l_element_value);

            ELSIF l_parameter_name= 'PRECISION'                    THEN
              g_suite_rec_tbl.PRECISION(p_record_counter):=
                to_number(l_element_value);

            ELSIF l_parameter_name= 'TRX_SHIPPING_DATE'            THEN
              g_suite_rec_tbl.TRX_SHIPPING_DATE(p_record_counter):=
                to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'TRX_RECEIPT_DATE'             THEN
              g_suite_rec_tbl.TRX_RECEIPT_DATE(p_record_counter):=
                to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'LEGAL_ENTITY_ID'              THEN
              get_user_key_id(l_element_value,
                              'LEGAL_ENTITY_ID',
                              g_suite_rec_tbl.LEGAL_ENTITY_ID(p_record_counter));

            ELSIF l_parameter_name= 'ROUNDING_SHIP_TO_PARTY_ID'    THEN
              get_user_key_id(l_element_value,
                              'ROUNDING_SHIP_TO_PARTY_ID',
                              g_suite_rec_tbl.ROUNDING_SHIP_TO_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'ROUNDING_SHIP_FROM_PARTY_ID'  THEN
              get_user_key_id(l_element_value,
                              'ROUNDING_SHIP_FROM_PARTY_ID',
                              g_suite_rec_tbl.ROUNDING_SHIP_FROM_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'ROUNDING_BILL_TO_PARTY_ID'    THEN
              get_user_key_id(l_element_value,
                              'ROUNDING_BILL_TO_PARTY_ID',
                              g_suite_rec_tbl.ROUNDING_BILL_TO_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'ROUNDING_BILL_FROM_PARTY_ID'  THEN
              get_user_key_id(l_element_value,
                              'ROUNDING_BILL_FROM_PARTY_ID',
                              g_suite_rec_tbl.ROUNDING_BILL_FROM_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'RNDG_SHIP_TO_PARTY_SITE_ID'   THEN
              get_user_key_id(l_element_value,
                              'RNDG_SHIP_TO_PARTY_SITE_ID',
                              g_suite_rec_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(p_record_counter));

            ELSIF l_parameter_name= 'RNDG_SHIP_FROM_PARTY_SITE_ID' THEN
              get_user_key_id(l_element_value,
                              'RNDG_SHIP_FROM_PARTY_SITE_ID',
                              g_suite_rec_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(p_record_counter));

            ELSIF l_parameter_name= 'RNDG_BILL_TO_PARTY_SITE_ID'   THEN
              get_user_key_id(l_element_value,
                              'RNDG_BILL_TO_PARTY_SITE_ID',
                              g_suite_rec_tbl.RNDG_BILL_TO_PARTY_SITE_ID(p_record_counter));

            ELSIF l_parameter_name= 'RNDG_BILL_FROM_PARTY_SITE_ID' THEN
              get_user_key_id(l_element_value,
                              'RNDG_BILL_FROM_PARTY_SITE_ID',
                              g_suite_rec_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(p_record_counter));

            ELSIF l_parameter_name= 'ESTABLISHMENT_ID'             THEN
              get_user_key_id(l_element_value,
                              'ESTABLISHMENT_ID',
                              g_suite_rec_tbl.ESTABLISHMENT_ID(p_record_counter));

            ELSIF l_parameter_name= 'TRX_LINE_TYPE'                THEN
              g_suite_rec_tbl.TRX_LINE_TYPE(p_record_counter):=l_element_value;

            ELSIF l_parameter_name= 'TRX_LINE_DATE'                THEN
              g_suite_rec_tbl.TRX_LINE_DATE(p_record_counter):=
                to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'TRX_BUSINESS_CATEGORY'        THEN
              g_suite_rec_tbl.TRX_BUSINESS_CATEGORY(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'ASSESSABLE_VALUE'        THEN
              g_suite_rec_tbl.ASSESSABLE_VALUE(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'BASE_INVOICE_PRICE_VARIANCE' THEN
              g_suite_rec_tbl.BASE_INVOICE_PRICE_VARIANCE(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'CANCEL_FLAG' THEN
              g_suite_rec_tbl.CANCEL_FLAG(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'CTRL_TOTAL_HDR_TX_AMT' THEN
              g_suite_rec_tbl.CTRL_TOTAL_HDR_TX_AMT(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'REC_NREC_TAX_AMT' THEN
              g_suite_rec_tbl.REC_NREC_TAX_AMT(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'REC_TAX_AMT_FUNCL_CURR' THEN
              g_suite_rec_tbl.REC_TAX_AMT_FUNCL_CURR(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TOTAL_REC_TAX_AMT_FUNCL_CURR' THEN
              g_suite_rec_tbl.TOTAL_REC_TAX_AMT_FUNCL_CURR(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TOTAL_NREC_TAX_AMT_FUNCL_CURR' THEN
              g_suite_rec_tbl.TOTAL_NREC_TAX_AMT_FUNCL_CURR(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TAXABLE_AMT_FUNCL_CURR' THEN
              g_suite_rec_tbl.TAXABLE_AMT_FUNCL_CURR(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TAXABLE_AMT' THEN
              g_suite_rec_tbl.TAXABLE_AMT(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TAX_REGISTRATION_NUMBER' THEN
              g_suite_rec_tbl.TAX_REGISTRATION_NUMBER(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TAX_LINE_ID' THEN
              g_suite_rec_tbl.TAX_LINE_ID(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TAX_JURISDICTION_ID' THEN
              g_suite_rec_tbl.TAX_JURISDICTION_ID(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TAX_HOLD_CODE' THEN
              g_suite_rec_tbl.TAX_HOLD_CODE(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TAX_EXEMPTION_ID' THEN
              g_suite_rec_tbl.TAX_EXEMPTION_ID(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TAX_CLASSIFICATION_CODE' THEN
              g_suite_rec_tbl.TAX_CLASSIFICATION_CODE(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'RECOVERABLE_FLAG' THEN
              g_suite_rec_tbl.RECOVERABLE_FLAG(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TAX_APPORTIONMENT_LINE_NUMBER' THEN
              g_suite_rec_tbl.TAX_APPORTIONMENT_LINE_NUMBER(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TAX_AMT_INCLUDED_FLAG' THEN
              g_suite_rec_tbl.TAX_AMT_INCLUDED_FLAG(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'TAX_AMT_FUNCL_CURR' THEN
              g_suite_rec_tbl.TAX_AMT_FUNCL_CURR(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'SUMMARY_TAX_LINE_ID' THEN
              g_suite_rec_tbl.SUMMARY_TAX_LINE_ID(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'REVERSING_TAX_LINE_ID' THEN
              g_suite_rec_tbl.REVERSING_TAX_LINE_ID(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'REVERSING_TRX_LINE_DIST_ID' THEN
              g_suite_rec_tbl.REVERSING_TRX_LINE_DIST_ID(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'REVERSED_TAX_DIST_ID' THEN
              g_suite_rec_tbl.REVERSED_TAX_DIST_ID(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'REVERSED_TRX_LINE_DIST_ID' THEN
              g_suite_rec_tbl.REVERSED_TRX_LINE_DIST_ID(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'REVERSE_FLAG' THEN
              g_suite_rec_tbl.REVERSE_FLAG(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'RECOVERY_TYPE_CODE' THEN
              g_suite_rec_tbl.RECOVERY_TYPE_CODE(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'RECOVERY_RATE_CODE' THEN
              g_suite_rec_tbl.RECOVERY_RATE_CODE(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'REC_TAX_AMT' THEN
              g_suite_rec_tbl.REC_TAX_AMT(p_record_counter):=
                l_element_value;

            ELSIF l_parameter_name= 'REC_NREC_TAX_DIST_ID' THEN
              g_suite_rec_tbl.REC_NREC_TAX_DIST_ID(p_record_counter):=l_element_value;

            ELSIF l_parameter_name= 'REC_TAX_AMT_FUNCL_CURR' THEN
                      g_suite_rec_tbl.REC_TAX_AMT_FUNCL_CURR(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'REC_TAX_AMT' THEN
                      g_suite_rec_tbl.REC_TAX_AMT(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'REC_NREC_TAX_DIST_ID' THEN
                      g_suite_rec_tbl.REC_NREC_TAX_DIST_ID(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'REC_NREC_TAX_AMT_FUNCL_CURR' THEN
                      g_suite_rec_tbl.REC_NREC_TAX_AMT_FUNCL_CURR(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'REC_NREC_CCID' THEN
                      g_suite_rec_tbl.REC_NREC_CCID(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'EXCHANGE_RATE_VARIANCE' THEN
                      g_suite_rec_tbl.EXCHANGE_RATE_VARIANCE(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'POSTING_FLAG' THEN
                      g_suite_rec_tbl.POSTING_FLAG(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'EXEMPT_REASON_CODE' THEN
                      g_suite_rec_tbl.EXEMPT_REASON_CODE(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'EXEMPTION_RATE' THEN
                      g_suite_rec_tbl.EXEMPTION_RATE(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'NREC_TAX_AMT_FUNCL_CURR' THEN
                      g_suite_rec_tbl.NREC_TAX_AMT_FUNCL_CURR(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'NREC_TAX_AMT' THEN
                      g_suite_rec_tbl.NREC_TAX_AMT(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'INVOICE_PRICE_VARIANCE' THEN
                      g_suite_rec_tbl.INVOICE_PRICE_VARIANCE(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'INTERNAL_ORG_LOCATION_ID' THEN
                      g_suite_rec_tbl.INTERNAL_ORG_LOCATION_ID(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'FREEZE_FLAG' THEN
                      g_suite_rec_tbl.FREEZE_FLAG(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'OVERRIDE_LEVEL'               THEN
                      g_suite_rec_tbl.OVERRIDE_LEVEL(p_record_counter)       :=l_element_value;

            ELSIF l_parameter_name= 'LINE_INTENDED_USE'            THEN
                      g_suite_rec_tbl.LINE_INTENDED_USE(p_record_counter)    :=l_element_value;

            ELSIF l_parameter_name= 'USER_DEFINED_FISC_CLASS'      THEN
                      g_suite_rec_tbl.USER_DEFINED_FISC_CLASS(p_record_counter)  :=l_element_value;

            ELSIF l_parameter_name= 'TAX_CODE'                     THEN
                      g_suite_rec_tbl.TAX_CODE(p_record_counter)                   :=l_element_value;

            ELSIF l_parameter_name= 'TAX_INCLUSION_FLAG'            THEN
                      g_suite_rec_tbl.TAX_INCLUSION_FLAG(p_record_counter)      :=l_element_value;

            ELSIF l_parameter_name= 'LINE_AMT'                     THEN
                      g_suite_rec_tbl.LINE_AMT(p_record_counter)               :=to_number(l_element_value);

            ELSIF l_parameter_name= 'TRX_LINE_QUANTITY'            THEN
                      g_suite_rec_tbl.TRX_LINE_QUANTITY(p_record_counter)     :=to_number(l_element_value);

            ELSIF l_parameter_name= 'UNIT_PRICE'                   THEN
                      g_suite_rec_tbl.UNIT_PRICE(p_record_counter)           :=to_number(l_element_value);

            ELSIF l_parameter_name= 'EXEMPT_CERTIFICATE_NUMBER'    THEN
                      g_suite_rec_tbl.EXEMPT_CERTIFICATE_NUMBER(p_record_counter)  :=l_element_value;

            ELSIF l_parameter_name= 'EXEMPT_REASON'                THEN
                      g_suite_rec_tbl.EXEMPT_REASON(p_record_counter)        :=l_element_value;

            ELSIF l_parameter_name= 'CASH_DISCOUNT'                THEN
                      g_suite_rec_tbl.CASH_DISCOUNT(p_record_counter)       :=to_number(l_element_value);

            ELSIF l_parameter_name= 'VOLUME_DISCOUNT'              THEN
                      g_suite_rec_tbl.VOLUME_DISCOUNT(p_record_counter)     :=to_number(l_element_value);

            ELSIF l_parameter_name= 'TRADING_DISCOUNT'             THEN
                      g_suite_rec_tbl.TRADING_DISCOUNT(p_record_counter)    :=to_number(l_element_value);

            ELSIF l_parameter_name= 'TRANSFER_CHARGE'              THEN
                      g_suite_rec_tbl.TRANSFER_CHARGE(p_record_counter)     :=to_number(l_element_value);

            ELSIF l_parameter_name= 'TRANSPORTATION_CHARGE'        THEN
                      g_suite_rec_tbl.TRANSPORTATION_CHARGE(p_record_counter)  :=to_number(l_element_value);

            ELSIF l_parameter_name= 'INSURANCE_CHARGE'             THEN
                      g_suite_rec_tbl.INSURANCE_CHARGE(p_record_counter)     :=to_number(l_element_value);

            ELSIF l_parameter_name= 'OTHER_CHARGE'                 THEN
                      g_suite_rec_tbl.OTHER_CHARGE(p_record_counter)        :=to_number(l_element_value);

            ELSIF l_parameter_name= 'PRODUCT_ID'                   THEN
                 get_user_key_id(l_element_value,'PRODUCT_ID',g_suite_rec_tbl.PRODUCT_ID(p_record_counter));

            ELSIF l_parameter_name= 'FIRST_PARTY_ORG_ID'  THEN
                      g_suite_rec_tbl.FIRST_PARTY_ORG_ID(p_record_counter):=l_element_value;

            ELSIF l_parameter_name= 'TAX_EVENT_CLASS_CODE'  THEN
                      g_suite_rec_tbl.TAX_EVENT_CLASS_CODE(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'DOC_EVENT_STATUS'  THEN
                      g_suite_rec_tbl.DOC_EVENT_STATUS(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'APPLIED_FROM_DIST_ID'  THEN
                      g_suite_rec_tbl.APPLIED_FROM_DIST_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'FIRST_PARTY_ORG_ID'  THEN
                      g_suite_rec_tbl.FIRST_PARTY_ORG_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'RDNG_SHIP_TO_PTY_TX_PROF_ID'  THEN
                      g_suite_rec_tbl.RDNG_SHIP_TO_PTY_TX_PROF_ID(p_record_counter):=l_element_value;

            ELSIF l_parameter_name= 'RDNG_SHIP_FROM_PTY_TX_PROF_ID'  THEN
                      g_suite_rec_tbl.RDNG_SHIP_FROM_PTY_TX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'RDNG_BILL_TO_PTY_TX_PROF_ID'  THEN
                      g_suite_rec_tbl.RDNG_BILL_TO_PTY_TX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'RDNG_BILL_FROM_PTY_TX_PROF_ID'  THEN
                      g_suite_rec_tbl.RDNG_BILL_FROM_PTY_TX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'RDNG_SHIP_TO_PTY_TX_P_ST_ID'  THEN
                      g_suite_rec_tbl.RDNG_SHIP_TO_PTY_TX_P_ST_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'RDNG_SHIP_FROM_PTY_TX_P_ST_ID'  THEN
                      g_suite_rec_tbl.RDNG_SHIP_FROM_PTY_TX_P_ST_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'RDNG_BILL_TO_PTY_TX_P_ST_ID'  THEN
                      g_suite_rec_tbl.RDNG_BILL_TO_PTY_TX_P_ST_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'RDNG_BILL_FROM_PTY_TX_P_ST_ID'  THEN
                      g_suite_rec_tbl.RDNG_BILL_FROM_PTY_TX_P_ST_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'VALIDATION_CHECK_FLAG'  THEN
                      g_suite_rec_tbl.VALIDATION_CHECK_FLAG(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'LINE_CLASS'  THEN
                      g_suite_rec_tbl.LINE_CLASS(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRX_ID_LEVEL2'  THEN
                      g_suite_rec_tbl.TRX_ID_LEVEL2(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRX_ID_LEVEL3'  THEN
                      g_suite_rec_tbl.TRX_ID_LEVEL3(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRX_ID_LEVEL4'  THEN
                      g_suite_rec_tbl.TRX_ID_LEVEL4(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRX_ID_LEVEL5'  THEN
                      g_suite_rec_tbl.TRX_ID_LEVEL5(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRX_ID_LEVEL6'  THEN
                      g_suite_rec_tbl.TRX_ID_LEVEL6(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'PAYING_PARTY_ID'  THEN
                      g_suite_rec_tbl.PAYING_PARTY_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRADING_HQ_PARTY_ID'  THEN
                      g_suite_rec_tbl.TRADING_HQ_PARTY_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'PAYING_PARTY_ID'  THEN
                      g_suite_rec_tbl.PAYING_PARTY_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRADING_HQ_PARTY_ID'  THEN
                      g_suite_rec_tbl.TRADING_HQ_PARTY_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POI_PARTY_ID'  THEN
                      g_suite_rec_tbl.POI_PARTY_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POD_PARTY_ID'  THEN
                      g_suite_rec_tbl.POD_PARTY_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TITLE_TRANSFER_PARTY_ID'  THEN
                      g_suite_rec_tbl.TITLE_TRANSFER_PARTY_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'PAYING_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.PAYING_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'OWN_HQ_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.OWN_HQ_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRADING_HQ_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.TRADING_HQ_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POI_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.POI_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POD_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.POD_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TITLE_TRANSFER_PARTY_ID'  THEN
                      g_suite_rec_tbl.TITLE_TRANSFER_PARTY_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'PAYING_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.PAYING_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'OWN_HQ_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.OWN_HQ_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRADING_HQ_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.TRADING_HQ_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POI_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.POI_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POD_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.POD_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POD_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.POD_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POD_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.POD_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POD_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.POD_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TITLE_TRANSFER_PARTY_SITE_ID'  THEN
                      g_suite_rec_tbl.TITLE_TRANSFER_PARTY_SITE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'PAYING_LOCATION_ID'  THEN
                      g_suite_rec_tbl.PAYING_LOCATION_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'OWN_HQ_LOCATION_ID'  THEN
                      g_suite_rec_tbl.OWN_HQ_LOCATION_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRADING_HQ_LOCATION_ID'  THEN
                      g_suite_rec_tbl.TRADING_HQ_LOCATION_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRADING_HQ_LOCATION_ID'  THEN
                      g_suite_rec_tbl.TRADING_HQ_LOCATION_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POC_LOCATION_ID'  THEN
                      g_suite_rec_tbl.POC_LOCATION_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POI_LOCATION_ID'  THEN
                      g_suite_rec_tbl.POI_LOCATION_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POD_LOCATION_ID'  THEN
                      g_suite_rec_tbl.POD_LOCATION_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TITLE_TRANSFER_LOCATION_ID'  THEN
                      g_suite_rec_tbl.TITLE_TRANSFER_LOCATION_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'ASSET_FLAG'  THEN
                      g_suite_rec_tbl.ASSET_FLAG(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'ASSET_NUMBER'  THEN
                      g_suite_rec_tbl.ASSET_NUMBER(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'ASSET_ACCUM_DEPRECIATION'  THEN
                      g_suite_rec_tbl.ASSET_ACCUM_DEPRECIATION(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'ASSET_TYPE'  THEN
                      g_suite_rec_tbl.ASSET_TYPE(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'ASSET_COST'  THEN
                      g_suite_rec_tbl.ASSET_COST(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'SHIP_TO_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.SHIP_TO_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'SHIP_FROM_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.SHIP_FROM_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POA_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.POA_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POO_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.POO_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'PAYING_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.PAYING_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'OWN_HQ_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.OWN_HQ_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRADING_HQ_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.TRADING_HQ_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POI_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.POI_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POD_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.POD_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'BILL_TO_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.BILL_TO_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'BILL_FROM_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.BILL_FROM_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'SHIP_TO_SITE_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.SHIP_TO_SITE_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POA_SITE_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.POA_SITE_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POO_SITE_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.POO_SITE_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'PAYING_SITE_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.PAYING_SITE_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'OWN_HQ_SITE_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.OWN_HQ_SITE_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRADING_HQ_SITE_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.TRADING_HQ_SITE_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POI_SITE_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.POI_SITE_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'POD_SITE_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.POD_SITE_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'BILL_TO_SITE_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.BILL_TO_SITE_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'BILL_FROM_SITE_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.BILL_FROM_SITE_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TITLE_TRANS_SITE_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.TITLE_TRANS_SITE_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'MERCHANT_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.MERCHANT_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'HQ_ESTB_PARTY_TAX_PROF_ID'  THEN
                      g_suite_rec_tbl.HQ_ESTB_PARTY_TAX_PROF_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'CTRL_HDR_TX_APPL_FLAG'  THEN
                      g_suite_rec_tbl.CTRL_HDR_TX_APPL_FLAG(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'CTRL_TOTAL_LINE_TX_AMT'  THEN
                      g_suite_rec_tbl.CTRL_TOTAL_LINE_TX_AMT(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TAX_JURISDICTION_CODE'  THEN
                      g_suite_rec_tbl.TAX_JURISDICTION_CODE(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TAX_PROVIDER_ID'  THEN
                      g_suite_rec_tbl.TAX_PROVIDER_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TAX_EXCEPTION_ID'  THEN
                      g_suite_rec_tbl.TAX_EXCEPTION_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TAX_LINE_ALLOCATION_FLAG'  THEN
                      g_suite_rec_tbl.TAX_LINE_ALLOCATION_FLAG(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'REVERSED_TAX_LINE_ID'  THEN
                      g_suite_rec_tbl.REVERSED_TAX_LINE_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'APPLIED_FROM_TAX_DIST_ID'  THEN
                      g_suite_rec_tbl.APPLIED_FROM_TAX_DIST_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'ADJUSTED_DOC_TAX_DIST_ID'  THEN
                      g_suite_rec_tbl.ADJUSTED_DOC_TAX_DIST_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TRX_LINE_DIST_TAX_AMT'  THEN
                      g_suite_rec_tbl.TRX_LINE_DIST_TAX_AMT(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'ADJUSTED_DOC_DIST_ID'  THEN
                      g_suite_rec_tbl.ADJUSTED_DOC_DIST_ID(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'APPLIED_TO_DOC_CURR_CONV_RATE'  THEN
                      g_suite_rec_tbl.APPLIED_TO_DOC_CURR_CONV_RATE(p_record_counter):=l_element_value;
            ELSIF l_parameter_name= 'TAX_VARIANCE_CALC_FLAG'  THEN
                      g_suite_rec_tbl.TAX_VARIANCE_CALC_FLAG(p_record_counter):=l_element_value;


            ELSIF l_parameter_name= 'PRODUCT_FISC_CLASSIFICATION'  THEN
                      g_suite_rec_tbl.PRODUCT_FISC_CLASSIFICATION(p_record_counter):=l_element_value;

            ELSIF l_parameter_name= 'PRODUCT_ORG_ID'               THEN
               get_user_key_id(l_element_value,'PRODUCT_ORG_ID',g_suite_rec_tbl.PRODUCT_ORG_ID(p_record_counter));

            ELSIF l_parameter_name= 'UOM_CODE'                     THEN
                      g_suite_rec_tbl.UOM_CODE(p_record_counter)        :=l_element_value;

            ELSIF l_parameter_name= 'PRODUCT_TYPE'                 THEN
                      g_suite_rec_tbl.PRODUCT_TYPE(p_record_counter)    :=l_element_value;

            ELSIF l_parameter_name= 'PRODUCT_CODE'                 THEN
                      g_suite_rec_tbl.PRODUCT_CODE(p_record_counter)    :=l_element_value;

            ELSIF l_parameter_name= 'PRODUCT_CATEGORY'             THEN
                      g_suite_rec_tbl.PRODUCT_CATEGORY(p_record_counter)  :=l_element_value;

            ELSIF l_parameter_name= 'TRX_SIC_CODE'                 THEN
                      g_suite_rec_tbl.TRX_SIC_CODE(p_record_counter)    :=l_element_value;

            ELSIF l_parameter_name= 'FOB_POINT'                    THEN
                      g_suite_rec_tbl.FOB_POINT(p_record_counter)                  :=l_element_value;

            ELSIF l_parameter_name= 'SHIP_TO_PARTY_ID'             THEN
                 get_user_key_id(l_element_value,'SHIP_TO_PARTY_ID',g_suite_rec_tbl.SHIP_TO_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'SHIP_FROM_PARTY_ID'           THEN
                 get_user_key_id(l_element_value,'SHIP_FROM_PARTY_ID',g_suite_rec_tbl.SHIP_FROM_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'POA_PARTY_ID'                 THEN
                 get_user_key_id(l_element_value,'POA_PARTY_ID',g_suite_rec_tbl.POA_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'POO_PARTY_ID'                 THEN
                 get_user_key_id(l_element_value,'POO_PARTY_ID',g_suite_rec_tbl.POO_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'BILL_TO_PARTY_ID'             THEN
                 get_user_key_id(l_element_value,'BILL_TO_PARTY_ID',g_suite_rec_tbl.BILL_TO_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'BILL_FROM_PARTY_ID'           THEN
                 get_user_key_id(l_element_value,'BILL_FROM_PARTY_ID',g_suite_rec_tbl.BILL_FROM_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'MERCHANT_PARTY_ID'            THEN
                 get_user_key_id(l_element_value,'MERCHANT_PARTY_ID',g_suite_rec_tbl.MERCHANT_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'SHIP_TO_PARTY_SITE_ID'        THEN
                 get_user_key_id(l_element_value,'SHIP_TO_PARTY_SITE_ID',g_suite_rec_tbl.SHIP_TO_PARTY_SITE_ID(p_record_counter));

            ELSIF l_parameter_name= 'SHIP_FROM_PARTY_SITE_ID'      THEN
                 get_user_key_id(l_element_value,'SHIP_FROM_PARTY_SITE_ID',g_suite_rec_tbl.SHIP_FROM_PARTY_SITE_ID(p_record_counter));

            ELSIF l_parameter_name= 'POA_PARTY_SITE_ID'            THEN
                 get_user_key_id(l_element_value,'POA_PARTY_ID',g_suite_rec_tbl.POA_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'POO_PARTY_SITE_ID'            THEN
                 get_user_key_id(l_element_value,'POO_PARTY_ID',g_suite_rec_tbl.POO_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'BILL_TO_PARTY_SITE_ID'        THEN
                 get_user_key_id(l_element_value,'BILL_TO_PARTY_SITE_ID',g_suite_rec_tbl.BILL_TO_PARTY_SITE_ID(p_record_counter));

            ELSIF l_parameter_name= 'BILL_FROM_PARTY_SITE_ID'      THEN
                 get_user_key_id(l_element_value,'BILL_FROM_PARTY_SITE_ID',g_suite_rec_tbl.BILL_FROM_PARTY_SITE_ID(p_record_counter));

            ELSIF l_parameter_name= 'SHIP_TO_LOCATION_ID'          THEN
                 get_user_key_id(l_element_value,'SHIP_TO_LOCATION_ID',g_suite_rec_tbl.SHIP_TO_LOCATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'SHIP_FROM_LOCATION_ID'        THEN
                 get_user_key_id(l_element_value,'SHIP_FROM_LOCATION_ID',g_suite_rec_tbl.SHIP_FROM_LOCATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'POA_LOCATION_ID'              THEN
                 get_user_key_id(l_element_value,'POA_LOCATION_ID',g_suite_rec_tbl.POA_LOCATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'POO_LOCATION_ID'              THEN
                 get_user_key_id(l_element_value,'POO_LOCATION_ID',g_suite_rec_tbl.POO_LOCATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'BILL_TO_LOCATION_ID'          THEN
                 get_user_key_id(l_element_value,'BILL_TO_LOCATION_ID',g_suite_rec_tbl.BILL_TO_LOCATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'BILL_FROM_LOCATION_ID'        THEN
                 get_user_key_id(l_element_value,'BILL_FROM_LOCATION_ID',g_suite_rec_tbl.BILL_FROM_LOCATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'ACCOUNT_CCID'                 THEN
                    null;

            ELSIF l_parameter_name = 'ACCOUNT_STRING'               THEN

                    ----------------------------------------------------------------------
                    -- Account String has to populate the Account CCID and Account String
                    -- based and the Account String given.
                    ----------------------------------------------------------------------

                    g_suite_rec_tbl.ACCOUNT_STRING(p_record_counter)    :=l_element_value;
                    get_user_key_id(l_element_value,'ACCOUNT_STRING',g_suite_rec_tbl.ACCOUNT_CCID(p_record_counter));

            ELSIF l_parameter_name= 'MERCHANT_PARTY_COUNTRY'       THEN
                    g_suite_rec_tbl.MERCHANT_PARTY_COUNTRY(p_record_counter)     :=l_element_value;

            ELSIF l_parameter_name= 'RECEIVABLES_TRX_TYPE_ID'      THEN
                 --get_user_key_id(l_element_value,'RECEIVABLES_TRX_TYPE_ID',g_suite_rec_tbl.RECEIVABLES_TRX_TYPE_ID(p_record_counter));
                 --JUST FOR TESTING PORPUSES WILL USE FIXED VALUE
                 write_message('Calculating Receivables Trx type id');
                 IF l_element_value is not null then
                   write_message('Assigning Calculating Receivables Trx type id');

                   g_suite_rec_tbl.RECEIVABLES_TRX_TYPE_ID(p_record_counter) :=101;
                   write_message(to_char(g_suite_rec_tbl.RECEIVABLES_TRX_TYPE_ID(p_record_counter)));
                 END IF;

            ELSIF l_parameter_name= 'REF_DOC_APPLICATION_ID'       THEN
                 get_user_key_id(l_element_value,'REF_DOC_APPLICATION_ID',g_suite_rec_tbl.REF_DOC_APPLICATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'REF_DOC_ENTITY_CODE'          THEN
                      g_suite_rec_tbl.REF_DOC_ENTITY_CODE(p_record_counter)        :=l_element_value;

            ELSIF l_parameter_name= 'REF_DOC_EVENT_CLASS_CODE'     THEN
                      g_suite_rec_tbl.REF_DOC_EVENT_CLASS_CODE(p_record_counter)   :=l_element_value;

            ELSIF l_parameter_name= 'REF_DOC_TRX_ID'               THEN
              check_surrogate_key(l_element_value,g_suite_rec_tbl.ref_doc_trx_id(p_record_counter),'HEADER');

            ELSIF l_parameter_name= 'REF_DOC_LINE_ID'              THEN
              check_surrogate_key(l_element_value,g_suite_rec_tbl.ref_doc_line_id(p_record_counter),'LINE');

            ELSIF l_parameter_name= 'REF_DOC_LINE_QUANTITY'        THEN
                    g_suite_rec_tbl.REF_DOC_LINE_QUANTITY(p_record_counter)  :=to_number(l_element_value);

            ELSIF l_parameter_name= 'RELATED_DOC_APPLICATION_ID'   THEN
               get_user_key_id(l_element_value,'RELATED_DOC_APPLICATION_ID',g_suite_rec_tbl.RELATED_DOC_APPLICATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'RELATED_DOC_ENTITY_CODE'      THEN
                    g_suite_rec_tbl.RELATED_DOC_ENTITY_CODE(p_record_counter)    :=l_element_value;

            ELSIF l_parameter_name= 'RELATED_DOC_EVENT_CLASS_CODE' THEN
                    g_suite_rec_tbl.RELATED_DOC_EVENT_CLASS_CODE(p_record_counter):= l_element_value;

            ELSIF l_parameter_name= 'RELATED_DOC_TRX_ID'           THEN
            check_surrogate_key(l_element_value,g_suite_rec_tbl.related_doc_trx_id(p_record_counter),'HEADER');

            ELSIF l_parameter_name= 'RELATED_DOC_NUMBER'           THEN
                    g_suite_rec_tbl.RELATED_DOC_NUMBER(p_record_counter)         :=l_element_value;

            ELSIF l_parameter_name= 'RELATED_DOC_DATE'             THEN
                    g_suite_rec_tbl.RELATED_DOC_DATE(p_record_counter)           :=to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'APPLIED_FROM_APPLICATION_ID'  THEN
               get_user_key_id(l_element_value,'APPLIED_FROM_APPLICATION_ID',g_suite_rec_tbl.APPLIED_FROM_APPLICATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'APPLIED_FROM_ENTITY_CODE'     THEN
                    g_suite_rec_tbl.APPLIED_FROM_ENTITY_CODE(p_record_counter)   :=l_element_value;

            ELSIF l_parameter_name= 'APPLIED_FROM_EVENT_CLASS_CODE' THEN
                    g_suite_rec_tbl.APPLIED_FROM_EVENT_CLASS_CODE(p_record_counter):= l_element_value;

            ELSIF l_parameter_name= 'APPLIED_FROM_TRX_ID'          THEN
            check_surrogate_key(l_element_value,g_suite_rec_tbl.applied_from_trx_id(p_record_counter),'HEADER');

            ELSIF l_parameter_name= 'APPLIED_FROM_LINE_ID'         THEN
            check_surrogate_key(l_element_value,g_suite_rec_tbl.applied_from_line_id(p_record_counter),'LINE');

            ELSIF l_parameter_name= 'ADJUSTED_DOC_APPLICATION_ID'  THEN
               get_user_key_id(l_element_value,'ADJUSTED_DOC_APPLICATION_ID',g_suite_rec_tbl.ADJUSTED_DOC_APPLICATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'ADJUSTED_DOC_ENTITY_CODE'     THEN
                    g_suite_rec_tbl.adjusted_doc_entity_code(p_record_counter)   :=l_element_value;

            ELSIF l_parameter_name= 'ADJUSTED_DOC_EVENT_CLASS_CODE' THEN
                    g_suite_rec_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(p_record_counter):= l_element_value;

            ELSIF l_parameter_name= 'ADJUSTED_DOC_TRX_ID'          THEN
            check_surrogate_key(l_element_value,g_suite_rec_tbl.adjusted_doc_trx_id(p_record_counter),'HEADER');

            ELSIF l_parameter_name= 'ADJUSTED_DOC_LINE_ID'         THEN
            check_surrogate_key(l_element_value,g_suite_rec_tbl.adjusted_doc_line_id(p_record_counter),'LINE');

            ELSIF l_parameter_name= 'ADJUSTED_DOC_NUMBER'          THEN
                    g_suite_rec_tbl.ADJUSTED_DOC_NUMBER(p_record_counter)        :=l_element_value;

            ELSIF l_parameter_name= 'ADJUSTED_DOC_DATE'            THEN
                    g_suite_rec_tbl.ADJUSTED_DOC_DATE(p_record_counter)          :=to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'APPLIED_TO_APPLICATION_ID'    THEN
               get_user_key_id(l_element_value,'APPLIED_TO_APPLICATION_ID',g_suite_rec_tbl.APPLIED_TO_APPLICATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'APPLIED_TO_ENTITY_CODE'       THEN
                    g_suite_rec_tbl.APPLIED_TO_ENTITY_CODE(p_record_counter)     :=l_element_value;

            ELSIF l_parameter_name= 'APPLIED_TO_EVENT_CLASS_CODE'  THEN
                    g_suite_rec_tbl.APPLIED_TO_EVENT_CLASS_CODE(p_record_counter):=l_element_value;

            ELSIF l_parameter_name= 'APPLIED_TO_TRX_ID'            THEN
            check_surrogate_key(l_element_value,g_suite_rec_tbl.applied_to_trx_id(p_record_counter),'HEADER');

            ELSIF l_parameter_name= 'APPLIED_TO_TRX_LINE_ID'       THEN
            check_surrogate_key(l_element_value,g_suite_rec_tbl.applied_to_trx_line_id(p_record_counter),'LINE');

            ELSIF l_parameter_name= 'TRX_LINE_NUMBER'              THEN
                    g_suite_rec_tbl.TRX_LINE_NUMBER(p_record_counter)            :=to_number(l_element_value);

            ELSIF l_parameter_name= 'TRX_NUMBER'                   THEN
                    g_suite_rec_tbl.TRX_NUMBER(p_record_counter)     :=l_element_value;

            ELSIF l_parameter_name= 'TRX_DESCRIPTION'              THEN
                    g_suite_rec_tbl.TRX_DESCRIPTION(p_record_counter)     :=l_element_value;

            ELSIF l_parameter_name= 'TRX_LINE_DESCRIPTION'         THEN
                    g_suite_rec_tbl.TRX_LINE_DESCRIPTION(p_record_counter)      :=l_element_value;

            ELSIF l_parameter_name= 'PRODUCT_DESCRIPTION'          THEN
                    g_suite_rec_tbl.PRODUCT_DESCRIPTION(p_record_counter)     :=l_element_value;

            ELSIF l_parameter_name= 'TRX_WAYBILL_NUMBER'           THEN
                    g_suite_rec_tbl.TRX_WAYBILL_NUMBER(p_record_counter)         :=l_element_value;

            ELSIF l_parameter_name= 'TRX_COMMUNICATED_DATE'        THEN
                    g_suite_rec_tbl.TRX_COMMUNICATED_DATE(p_record_counter)      :=to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'TRX_LINE_GL_DATE'             THEN
                    g_suite_rec_tbl.TRX_LINE_GL_DATE(p_record_counter)           :=to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'BATCH_SOURCE_ID'              THEN
                    null;

            ELSIF l_parameter_name= 'BATCH_SOURCE_NAME'            THEN
                    ----------------------------------------------------------------------
                    -- Batch Source Name has to populate the Batch Source Id and Name
                    -- based and the Batch Source Name given.
                    ----------------------------------------------------------------------
                    g_suite_rec_tbl.BATCH_SOURCE_NAME(p_record_counter)          :=l_element_value;
                    get_user_key_id(l_element_value,'BATCH_SOURCE_NAME',g_suite_rec_tbl.BATCH_SOURCE_ID(p_record_counter));

            ELSIF l_parameter_name= 'DOC_SEQ_ID'                   THEN
               get_user_key_id(l_element_value,'DOC_SEQ_ID',g_suite_rec_tbl.DOC_SEQ_ID(p_record_counter));

            ELSIF l_parameter_name= 'DOC_SEQ_NAME'                 THEN
                    g_suite_rec_tbl.DOC_SEQ_NAME(p_record_counter)               :=l_element_value;

            ELSIF l_parameter_name= 'DOC_SEQ_VALUE'                THEN
                    g_suite_rec_tbl.DOC_SEQ_VALUE(p_record_counter)              :=l_element_value;

            ELSIF l_parameter_name= 'TRX_DUE_DATE'                 THEN
                    g_suite_rec_tbl.TRX_DUE_DATE(p_record_counter)  :=to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'TRX_TYPE_DESCRIPTION'         THEN
                    g_suite_rec_tbl.TRX_TYPE_DESCRIPTION(p_record_counter)       :=l_element_value;

            ELSIF l_parameter_name= 'MERCHANT_PARTY_NAME'          THEN
                    g_suite_rec_tbl.MERCHANT_PARTY_NAME(p_record_counter)        :=l_element_value;

            ELSIF l_parameter_name= 'MERCHANT_PARTY_DOCUMENT_NUMBER' THEN
                    g_suite_rec_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER(p_record_counter):= l_element_value;

            ELSIF l_parameter_name= 'MERCHANT_PARTY_REFERENCE'     THEN
                    g_suite_rec_tbl.MERCHANT_PARTY_REFERENCE(p_record_counter)   :=l_element_value;

            ELSIF l_parameter_name= 'MERCHANT_PARTY_TAXPAYER_ID'   THEN
                    g_suite_rec_tbl.MERCHANT_PARTY_TAXPAYER_ID(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'MERCHANT_PARTY_TAX_REG_NUMBER' THEN
                    g_suite_rec_tbl.MERCHANT_PARTY_TAX_REG_NUMBER(p_record_counter):= l_element_value;

            ELSIF l_parameter_name= 'DOCUMENT_SUB_TYPE'            THEN
                    g_suite_rec_tbl.DOCUMENT_SUB_TYPE(p_record_counter)          :=l_element_value;

            ELSIF l_parameter_name= 'SUPPLIER_TAX_INVOICE_NUMBER'  THEN
                    g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_NUMBER(p_record_counter):=l_element_value;

            ELSIF l_parameter_name= 'SUPPLIER_TAX_INVOICE_DATE'    THEN
                    g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_DATE(p_record_counter)  :=to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'SUPPLIER_EXCHANGE_RATE'       THEN
                    g_suite_rec_tbl.SUPPLIER_EXCHANGE_RATE(p_record_counter)     :=to_number(l_element_value);

            ELSIF l_parameter_name= 'TAX_INVOICE_DATE'             THEN
                    g_suite_rec_tbl.TAX_INVOICE_DATE(p_record_counter)   :=to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'TAX_INVOICE_NUMBER'           THEN
                    g_suite_rec_tbl.TAX_INVOICE_NUMBER(p_record_counter)     :=l_element_value;

            ELSIF l_parameter_name= 'SUMMARY_TAX_LINE_NUMBER'      THEN
                    g_suite_rec_tbl.SUMMARY_TAX_LINE_NUMBER(p_record_counter) :=to_number(l_element_value);

            ELSIF l_parameter_name= 'TAX_REGIME_CODE'              THEN
                    g_suite_rec_tbl.TAX_REGIME_CODE(p_record_counter)            :=l_element_value;

            ELSIF l_parameter_name= 'TAX'                          THEN
                    g_suite_rec_tbl.TAX(p_record_counter)                        :=l_element_value;

            ELSIF l_parameter_name= 'TAX_STATUS_CODE'              THEN
                    g_suite_rec_tbl.TAX_STATUS_CODE(p_record_counter)            :=l_element_value;

            ELSIF l_parameter_name= 'TAX_RATE_CODE'                THEN
                    g_suite_rec_tbl.TAX_RATE_CODE(p_record_counter)              :=l_element_value;

            ELSIF l_parameter_name= 'TAX_RATE'                     THEN
                    g_suite_rec_tbl.TAX_RATE(p_record_counter)                   :=to_number(l_element_value);

            ELSIF l_parameter_name= 'TAX_AMT'                      THEN
                    g_suite_rec_tbl.TAX_AMT(p_record_counter)                    :=to_number(l_element_value);

            ELSIF l_parameter_name= 'TAX_LINE_NUMBER'              THEN
                    g_suite_rec_tbl.TAX_LINE_NUMBER(p_record_counter)            :=to_number(l_element_value);

            ELSIF l_parameter_name= 'REVERSING_APPLN_ID'            THEN
                    g_suite_rec_tbl.REVERSING_APPLN_ID(p_record_counter)          :=to_number(l_element_value);

            ELSIF l_parameter_name= 'REVERSING_ENTITY_CODE'        THEN
                    g_suite_rec_tbl.REVERSING_ENTITY_CODE(p_record_counter)      :=l_element_value;

            ELSIF l_parameter_name= 'REVERSING_EVNT_CLS_CODE'      THEN
                    g_suite_rec_tbl.REVERSING_EVNT_CLS_CODE(p_record_counter)    :=l_element_value;

            ELSIF l_parameter_name= 'REVERSING_TRX_ID'             THEN
              ----------------------------------------------------------------------------
              --Create the surrogate Key if has to be created or has not been created yet.
              ----------------------------------------------------------------------------
              IF (g_suite_rec_tbl.tax_event_type_code(p_record_counter) = 'CREATE' and NOT(g_surr_trx_id_tbl.exists(l_element_value))) THEN
                surrogate_key ( l_element_value,g_suite_rec_tbl.reversing_trx_id(p_record_counter),'HEADER');
                g_surr_trx_id_tbl(l_element_value) := g_suite_rec_tbl.reversing_trx_id(p_record_counter);
              ELSE
                check_surrogate_key(l_element_value,g_suite_rec_tbl.reversing_trx_id(p_record_counter),'HEADER');
              END IF;

            ELSIF l_parameter_name= 'REVERSING_TRX_LEVEL_TYPE'     THEN
                      g_suite_rec_tbl.REVERSING_TRX_LEVEL_TYPE(p_record_counter)   :=to_number(l_element_value);

            ELSIF l_parameter_name= 'REVERSING_TRX_LINE_ID'        THEN
              ----------------------------------------------------------------------------
              --Create the surrogate Key if has to be created or has not been created yet.
              ----------------------------------------------------------------------------
              IF g_suite_rec_tbl.tax_event_type_code(p_record_counter) = 'CREATE' THEN
                surrogate_key ( l_element_value,g_suite_rec_tbl.reversing_trx_line_id(p_record_counter),'LINE');
                g_surr_trx_id_tbl(l_element_value) := g_suite_rec_tbl.reversing_trx_line_id(p_record_counter);
              ELSE
                check_surrogate_key(l_element_value,g_suite_rec_tbl.reversing_trx_line_id(p_record_counter),'LINE');
              END IF;

            ELSIF l_parameter_name= 'REVERSED_APPLN_ID'            THEN
                    g_suite_rec_tbl.REVERSED_APPLN_ID(p_record_counter)          :=to_number(l_element_value);

            ELSIF l_parameter_name= 'REVERSED_ENTITY_CODE'         THEN
                    g_suite_rec_tbl.REVERSED_ENTITY_CODE(p_record_counter)       :=l_element_value;

            ELSIF l_parameter_name= 'REVERSED_EVNT_CLS_CODE'       THEN
                    g_suite_rec_tbl.REVERSED_EVNT_CLS_CODE(p_record_counter)     :=l_element_value;

            ELSIF l_parameter_name= 'REVERSED_TRX_ID'              THEN
              check_surrogate_key(l_element_value,g_suite_rec_tbl.reversed_trx_id(p_record_counter),'HEADER');

            ELSIF l_parameter_name= 'REVERSED_TRX_LEVEL_TYPE'      THEN
                    g_suite_rec_tbl.REVERSED_TRX_LEVEL_TYPE(p_record_counter)    :=to_number(l_element_value);

            ELSIF l_parameter_name= 'REVERSED_TRX_LINE_ID'         THEN
              check_surrogate_key(l_element_value,g_suite_rec_tbl.reversed_trx_line_id(p_record_counter),'LINE');

            ELSIF l_parameter_name= 'TRX_LINE_DIST_ID'             THEN
              ----------------------------------------------------------------------------
              --Create the surrogate Key if has to be created or has not been created yet.
              ----------------------------------------------------------------------------
              IF g_suite_rec_tbl.tax_event_type_code(p_record_counter) = 'CREATE' THEN
                surrogate_key ( l_element_value,g_suite_rec_tbl.trx_line_dist_id(p_record_counter),'DIST');
                g_surr_trx_id_tbl(l_element_value) := g_suite_rec_tbl.trx_line_dist_id(p_record_counter);
              ELSE
                check_surrogate_key(l_element_value,g_suite_rec_tbl.trx_line_dist_id(p_record_counter),'DIST');
              END IF;

            ELSIF l_parameter_name= 'DIST_LEVEL_ACTION'            THEN
                      g_suite_rec_tbl.DIST_LEVEL_ACTION(p_record_counter)          :=l_element_value;

            ELSIF l_parameter_name= 'TRX_LINE_DIST_DATE'           THEN
                      g_suite_rec_tbl.TRX_LINE_DIST_DATE(p_record_counter)         :=to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'ITEM_DIST_NUMBER'             THEN
                      g_suite_rec_tbl.ITEM_DIST_NUMBER(p_record_counter)           :=to_number(l_element_value);

            ELSIF l_parameter_name= 'DIST_INTENDED_USE'            THEN
                      g_suite_rec_tbl.DIST_INTENDED_USE(p_record_counter)          :=l_element_value;

            ELSIF l_parameter_name= 'TASK_ID'                      THEN
                      g_suite_rec_tbl.TASK_ID(p_record_counter)                    :=to_number(l_element_value);

            ELSIF l_parameter_name= 'AWARD_ID'                     THEN
                      g_suite_rec_tbl.AWARD_ID(p_record_counter)                   :=to_number(l_element_value);

            ELSIF l_parameter_name= 'PROJECT_ID'                   THEN
                      g_suite_rec_tbl.PROJECT_ID(p_record_counter)                 :=to_number(l_element_value);

            ELSIF l_parameter_name= 'EXPENDITURE_TYPE'             THEN
                      g_suite_rec_tbl.EXPENDITURE_TYPE(p_record_counter)           :=l_element_value;

            ELSIF l_parameter_name= 'EXPENDITURE_ORGANIZATION_ID'  THEN
                      g_suite_rec_tbl.EXPENDITURE_ORGANIZATION_ID(p_record_counter):=to_number(l_element_value);

            ELSIF l_parameter_name= 'EXPENDITURE_ITEM_DATE'        THEN
                      g_suite_rec_tbl.EXPENDITURE_ITEM_DATE(p_record_counter)      :=to_date(nvl(l_element_value,'2000/01/01'),'YYYY/MM/DD');

            ELSIF l_parameter_name= 'TRX_LINE_DIST_AMT'            THEN
                      g_suite_rec_tbl.TRX_LINE_DIST_AMT(p_record_counter)          :=to_number(l_element_value);

            ELSIF l_parameter_name= 'TRX_LINE_DIST_QUANTITY'       THEN
                      g_suite_rec_tbl.TRX_LINE_DIST_QUANTITY(p_record_counter)     :=to_number(l_element_value);

            ELSIF l_parameter_name= 'REF_DOC_DIST_ID'              THEN
                      g_suite_rec_tbl.REF_DOC_DIST_ID(p_record_counter)            :=to_number(l_element_value);

            ELSIF l_parameter_name= 'REF_DOC_CURR_CONV_RATE'       THEN
                      g_suite_rec_tbl.REF_DOC_CURR_CONV_RATE(p_record_counter)     :=to_number(l_element_value);

            ELSIF l_parameter_name= 'TAX_DIST_ID'                  THEN
                      g_suite_rec_tbl.TAX_DIST_ID(p_record_counter)                :=to_number(l_element_value);

            ELSIF l_parameter_name= 'LINE_AMT_INCLUDES_TAX_FLAG'    THEN
                      g_suite_rec_tbl.LINE_AMT_INCLUDES_TAX_FLAG(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'PORT_OF_ENTRY_CODE'    THEN
                      g_suite_rec_tbl.PORT_OF_ENTRY_CODE(p_record_counter)         :=l_element_value;

            ELSIF l_parameter_name= 'OWN_HQ_PARTY_ID'   THEN
                 get_user_key_id(l_element_value,'OWN_HQ_PARTY_ID',g_suite_rec_tbl.OWN_HQ_PARTY_ID(p_record_counter));

            ELSIF l_parameter_name= 'DEFAULT_TAXATION_COUNTRY' THEN
                      g_suite_rec_tbl.DEFAULT_TAXATION_COUNTRY(p_record_counter)   :=l_element_value;

            ELSIF l_parameter_name= 'SHIP_THIRD_PTY_ACCT_ID' THEN
                      g_suite_rec_tbl.SHIP_THIRD_PTY_ACCT_ID(p_record_counter)     :=l_element_value;

            ELSIF l_parameter_name= 'BILL_THIRD_PTY_ACCT_ID' THEN
                      g_suite_rec_tbl.BILL_THIRD_PTY_ACCT_ID(p_record_counter)     :=l_element_value;

            ELSIF l_parameter_name= 'SHIP_THIRD_PTY_ACCT_SITE_ID' THEN
                      g_suite_rec_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'BILL_THIRD_PTY_ACCT_SITE_ID' THEN
                      g_suite_rec_tbl.BILL_THIRD_PTY_ACCT_SITE_ID(p_record_counter) :=l_element_value;


            ELSIF l_parameter_name= 'BILL_TO_CUST_ACCT_SITE_USE_ID' THEN
                      g_suite_rec_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID(p_record_counter) :=l_element_value;

            ELSIF l_parameter_name= 'SHIP_TO_CUST_ACCT_SITE_USE_ID' THEN
                      g_suite_rec_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID(p_record_counter) :=l_element_value;


            ---------------------------------------------------------------------------------
            -- Bug 4477978. Added Source Columns.
            ---------------------------------------------------------------------------------
            ELSIF l_parameter_name= 'SOURCE_APPLICATION_ID' THEN
                      get_user_key_id(l_element_value,'SOURCE_APPLICATION_ID',
                                       g_suite_rec_tbl.SOURCE_APPLICATION_ID(p_record_counter));

            ELSIF l_parameter_name= 'SOURCE_ENTITY_CODE' THEN
                      g_suite_rec_tbl.SOURCE_ENTITY_CODE(p_record_counter) := l_element_value;

            ELSIF l_parameter_name= 'SOURCE_EVENT_CLASS_CODE' THEN
                      g_suite_rec_tbl.SOURCE_EVENT_CLASS_CODE(p_record_counter) := l_element_value;

            ELSIF l_parameter_name= 'SOURCE_TRX_ID' THEN
                      check_surrogate_key(l_element_value,g_suite_rec_tbl.SOURCE_TRX_ID(p_record_counter),'HEADER');

            ELSIF l_parameter_name= 'SOURCE_LINE_ID' THEN
                      check_surrogate_key(l_element_value,g_suite_rec_tbl.SOURCE_LINE_ID(p_record_counter),'LINE');

            ELSIF l_parameter_name= 'SOURCE_TRX_LEVEL_TYPE' THEN
                      g_suite_rec_tbl.SOURCE_TRX_LEVEL_TYPE(p_record_counter) := l_element_value;

            ELSIF l_parameter_name= 'SOURCE_TAX_LINE_ID' THEN
                      check_surrogate_key(l_element_value,g_suite_rec_tbl.SOURCE_TAX_LINE_ID(p_record_counter),'LINE');



            ELSIF l_parameter_name= 'COMMON_TRANSACTION_DATA'   THEN
                 --------------------------------------------------------------------
                 --Predefined Values Column is used only for generation of text file.
                 --------------------------------------------------------------------
                 null;
            ELSIF l_parameter_name IN ('COMMENTS01','COMMENTS02','COMMENTS03','COMMENTS04','COMMENTS05',
                                       'COMMENTS06','COMMENTS07','COMMENTS08','COMMENTS09','COMMENTS10')   THEN
                 null;

            ELSE
              write_message('~      *** The Parameter above is NOT DEFINED in ZX_TEST_API:'||l_parameter_name||' ***');
            END IF;
          END IF;
        IF l_return_status_p = 'LINE COMPLETED' THEN
          EXIT;
        END IF;
      END IF;
     END IF;
    END LOOP;

  END put_line_in_suite_rec_tbl;



/* ====================================================================================*
 | PROCEDURE call_api : Logic to Call the APIs                                         |
 * ====================================================================================*/

  PROCEDURE call_api (p_api_service    IN VARCHAR,
                      p_suite_number   IN VARCHAR,
                      p_case_number    IN VARCHAR,
                      p_transaction_id IN NUMBER) IS

  l_row_id                 VARCHAR2(4000);
  l_error_flag             VARCHAR2(1);
  l_mesg                   VARCHAR2(2000);
  l_return_status          VARCHAR2(2000);
  l_override_level         VARCHAR2(2000);
  l_hold_codes_tbl         zx_api_pub.hold_codes_tbl_type;
  l_validation_status      VARCHAR2(4000);
  l_start_row              NUMBER;
  l_end_row                NUMBER;
  l_flag                   VARCHAR2(1);
  l_tax_hold_code          VARCHAR2(100);
  l_initial_row            NUMBER;
  l_ending_row             NUMBER;
  l_first                  BOOLEAN;
  l_sync_trx_rec           zx_api_pub.sync_trx_rec_type;
  l_sync_trx_lines_tbl     zx_api_pub.sync_trx_lines_tbl_type%type;
  l_zx_errors_gt           VARCHAR2(4000);


  -------------------------------------
  --7 Standard Parameters for all APIs
  -------------------------------------
  l_api_version              NUMBER;
  l_init_msg_list            VARCHAR2(2000);
  l_commit                   VARCHAR2(2000);
  l_validation_level         NUMBER;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_dummy                    NUMBER;
  l_object_version_number    NUMBER;

  BEGIN
    l_row_id := NULL;
    l_api_version  :=g_api_version;

    -------------------------------------------------------------
    -- Call the APIs for the case has been just finished reading.
    -------------------------------------------------------------
    write_message('In the Procedure CALL_API for:'||p_api_service);
    -----------------------------------------------------------
    -- Proceeds to Call the APIs Calculate Tax
    -----------------------------------------------------------
    IF p_api_service = 'CALCULATE_TAX' THEN
      select count(*) into l_dummy from zx_trx_headers_gt;
      write_message('zx_transaction_headers_gt contains rows:'||to_char(l_dummy));

      zx_api_pub.calculate_tax (
                     l_api_version      ,
                     l_init_msg_list    ,
                     l_commit           ,
                     l_validation_level ,
                     l_return_status    ,
                     l_msg_count        ,
                     l_msg_data
                     );
      write_message('----------------------------------------------------');
      write_message('Service ZX_API_PUB.CALCULATE_TAX has been called! For ');
      write_message('Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||to_char(l_msg_count)    );

    -----------------------------------------------------------
    -- Proceeds to Call the API Override Detail Manual Tax Line
    -----------------------------------------------------------
    ELSIF p_api_service = 'OVERRIDE_DETAIL_ENTER_MANUAL_TAX_LINE' THEN
      get_start_end_rows_structure
       (
         p_suite      => p_suite_number,
         p_case       => p_case_number,
         p_structure  => 'STRUCTURE_OVERRIDE_DETAIL_TAX_LINES',
         x_start_row  => l_start_row,
         x_end_row    => l_end_row
       );

      FOR i IN l_start_row..l_end_row LOOP
      zx_trl_detail_override_pkg.Insert_row (
        X_ROWID                        => l_row_id                                   ,
        P_TAX_LINE_ID                  => null                                       ,
        P_INTERNAL_ORGANIZATION_ID     => g_suite_rec_tbl.internal_organization_id(i),
        P_APPLICATION_ID               => g_suite_rec_tbl.application_id(i)          ,
        P_ENTITY_CODE                  => g_suite_rec_tbl.entity_code(i)             ,
        P_EVENT_CLASS_CODE             => g_suite_rec_tbl.event_class_code(i)        ,
        P_EVENT_TYPE_CODE              => g_suite_rec_tbl.event_type_code(i)         ,
        P_TRX_ID                       => g_suite_rec_tbl.trx_id(i)                  ,
        P_TRX_LINE_ID                  => g_suite_rec_tbl.tax_line_id(i)             ,
        P_TRX_LEVEL_TYPE               => g_suite_rec_tbl.trx_level_type(i)          ,
        P_TRX_LINE_NUMBER              => g_suite_rec_tbl.trx_line_number(i)         ,
        P_DOC_EVENT_STATUS             => null                                       ,
        P_TAX_EVENT_CLASS_CODE         => null                                       ,
        P_TAX_EVENT_TYPE_CODE          => null                                       ,
        P_TAX_LINE_NUMBER              => g_suite_rec_tbl.tax_line_number(i)         ,
        P_CONTENT_OWNER_ID             => null                                       ,
        P_TAX_REGIME_ID                => null                                       ,
        P_TAX_REGIME_CODE              => g_suite_rec_tbl.tax_regime_code(i)         ,
        P_TAX_ID                       => null                                       ,
        P_TAX                          => g_suite_rec_tbl.tax(i)                     ,
        P_TAX_STATUS_ID                => null                                       ,
        P_TAX_STATUS_CODE              => g_suite_rec_tbl.tax_status_code(i)         ,
        P_TAX_RATE_ID                  => g_suite_rec_tbl.tax_rate_id(i)             ,
        P_TAX_RATE_CODE                => g_suite_rec_tbl.tax_rate_code(i)           ,
        P_TAX_RATE                     => g_suite_rec_tbl.tax_rate(i)                ,
        P_TAX_RATE_TYPE                => null                                       ,
        P_TAX_APPORTIONMENT_LINE_NUM   => null                                       ,
        P_TRX_ID_LEVEL2                => null                                       ,
        P_TRX_ID_LEVEL3                => null                                       ,
        P_TRX_ID_LEVEL4                => null                                       ,
        P_TRX_ID_LEVEL5                => null                                       ,
        P_TRX_ID_LEVEL6                => null                                       ,
        P_TRX_USER_KEY_LEVEL1          => null                                       ,
        P_TRX_USER_KEY_LEVEL2          => null                                       ,
        P_TRX_USER_KEY_LEVEL3          => null                                       ,
        P_TRX_USER_KEY_LEVEL4          => null                                       ,
        P_TRX_USER_KEY_LEVEL5          => null                                       ,
        P_TRX_USER_KEY_LEVEL6          => null                                       ,
/*      P_HDR_TRX_USER_KEY1            => null                                       ,
        P_HDR_TRX_USER_KEY2            => null                                       ,
        P_HDR_TRX_USER_KEY3            => null                                       ,
        P_HDR_TRX_USER_KEY4            => null                                       ,
        P_HDR_TRX_USER_KEY5            => null                                       ,
        P_HDR_TRX_USER_KEY6            => null                                       ,
        P_LINE_TRX_USER_KEY1           => null                                       ,
        P_LINE_TRX_USER_KEY2           => null                                       ,
        P_LINE_TRX_USER_KEY3           => null                                       ,
        P_LINE_TRX_USER_KEY4           => null                                       ,
        P_LINE_TRX_USER_KEY5           => null                                       ,
        P_LINE_TRX_USER_KEY6           => null                                       ,*/
        P_MRC_TAX_LINE_FLAG            => null                                       ,
        P_MRC_LINK_TO_TAX_LINE_ID      => null                                       ,
        P_LEDGER_ID                    => null                                       ,
        P_ESTABLISHMENT_ID             => null                                       ,
        P_LEGAL_ENTITY_ID              => null                                       ,
        -- P_LEGAL_ENTITY_TAX_REG_NUMBER  => null                                       ,
        P_HQ_ESTB_REG_NUMBER           => null                                       ,
        P_HQ_ESTB_PARTY_TAX_PROF_ID    => null                                       ,
        P_CURRENCY_CONVERSION_DATE     => null                                       ,
        P_CURRENCY_CONVERSION_TYPE     => null                                       ,
        P_CURRENCY_CONVERSION_RATE     => null                                       ,
        P_TAX_CURR_CONVERSION_DATE     => null                                       ,
        P_TAX_CURR_CONVERSION_TYPE     => null                                       ,
        P_TAX_CURR_CONVERSION_RATE     => null                                       ,
        P_TRX_CURRENCY_CODE            => null                                       ,
        P_REPORTING_CURRENCY_CODE      => null                                       ,
        P_MINIMUM_ACCOUNTABLE_UNIT     => null                                       ,
        P_PRECISION                    => null                                       ,
        P_TRX_NUMBER                   => g_suite_rec_tbl.trx_number(i)              ,
        P_TRX_DATE                     => null                                       ,
        P_UNIT_PRICE                   => null                                       ,
        P_LINE_AMT                     => null                                       ,
        P_TRX_LINE_QUANTITY            => null                                       ,
        P_TAX_BASE_MODIFIER_RATE       => null                                       ,
        P_REF_DOC_APPLICATION_ID       => null                                       ,
        P_REF_DOC_ENTITY_CODE          => null                                       ,
        P_REF_DOC_EVENT_CLASS_CODE     => null                                       ,
        P_REF_DOC_TRX_ID               => null                                       ,
        P_REF_DOC_TRX_LEVEL_TYPE       => null                                       ,
        P_REF_DOC_LINE_ID              => null                                       ,
        P_REF_DOC_LINE_QUANTITY        => null                                       ,
        P_OTHER_DOC_LINE_AMT           => null                                       ,
        P_OTHER_DOC_LINE_TAX_AMT       => null                                       ,
        P_OTHER_DOC_LINE_TAXABLE_AMT   => null                                       ,
        P_UNROUNDED_TAXABLE_AMT        => null                                       ,
        P_UNROUNDED_TAX_AMT            => null                                       ,
        P_RELATED_DOC_APPLICATION_ID   => null                                       ,
        P_RELATED_DOC_ENTITY_CODE      => null                                       ,
        P_RELATED_DOC_EVT_CLASS_CODE   => null                                       ,
        P_RELATED_DOC_TRX_ID           => null                                       ,
        P_RELATED_DOC_TRX_LEVEL_TYPE   => null                                       ,
        P_RELATED_DOC_NUMBER           => null                                       ,
        P_RELATED_DOC_DATE             => null                                       ,
        P_APPLIED_FROM_APPL_ID         => null                                       ,
        P_APPLIED_FROM_EVT_CLSS_CODE   => null                                       ,
        P_APPLIED_FROM_ENTITY_CODE     => null                                       ,
        P_APPLIED_FROM_TRX_ID          => null                                       ,
        P_APPLIED_FROM_TRX_LEVEL_TYPE  => null                                       ,
        P_APPLIED_FROM_LINE_ID         => null                                       ,
        P_APPLIED_FROM_TRX_NUMBER      => null                                       ,
        P_ADJUSTED_DOC_APPLN_ID        => null                                       ,
        P_ADJUSTED_DOC_ENTITY_CODE     => g_suite_rec_tbl.adjusted_doc_entity_code(i),
        P_ADJUSTED_DOC_EVT_CLSS_CODE   => null                                       ,
        P_ADJUSTED_DOC_TRX_ID          => null                                       ,
        P_ADJUSTED_DOC_TRX_LEVEL_TYPE  => null                                       ,
        P_ADJUSTED_DOC_LINE_ID         => null                                       ,
        P_ADJUSTED_DOC_NUMBER          => null                                       ,
        P_ADJUSTED_DOC_DATE            => null                                       ,
        P_APPLIED_TO_APPLICATION_ID    => null                                       ,
        P_APPLIED_TO_EVT_CLASS_CODE    => null                                       ,
        P_APPLIED_TO_ENTITY_CODE       => null                                       ,
        P_APPLIED_TO_TRX_ID            => null                                       ,
        P_APPLIED_TO_TRX_LEVEL_TYPE    => null                                       ,
        P_APPLIED_TO_LINE_ID           => null                                       ,
        P_SUMMARY_TAX_LINE_ID          => g_suite_rec_tbl.summary_tax_line_id(i)     ,
        P_OFFSET_LINK_TO_TAX_LINE_ID   => null                                       ,
        P_OFFSET_FLAG                  => null                                       ,
        P_PROCESS_FOR_RECOVERY_FLAG    => null                                       ,
        P_TAX_JURISDICTION_ID          => g_suite_rec_tbl.tax_jurisdiction_id(i)     ,
        P_TAX_JURISDICTION_CODE        => null                                       ,
        P_PLACE_OF_SUPPLY              => null                                       ,
        P_PLACE_OF_SUPPLY_TYPE_CODE    => null                                       ,
        P_PLACE_OF_SUPPLY_RESULT_ID    => null                                       ,
        P_TAX_DATE_RULE_ID             => null                                       ,
        P_TAX_DATE                     => null                                       ,
        P_TAX_DETERMINE_DATE           => null                                       ,
        P_TAX_POINT_DATE               => null                                       ,
        P_TRX_LINE_DATE                => null                                       ,
        P_TAX_TYPE_CODE                => null                                       ,
        P_TAX_CODE                     => null                                       ,
        P_TAX_REGISTRATION_ID          => null                                       ,
        P_TAX_REGISTRATION_NUMBER      => g_suite_rec_tbl.tax_registration_number(i) ,
        P_REGISTRATION_PARTY_TYPE      => null                                       ,
        P_ROUNDING_LEVEL_CODE          => null                                       ,
        P_ROUNDING_RULE_CODE           => null                                       ,
        P_RNDG_LVL_PARTY_TAX_PROF_ID   => null                                       ,
        P_ROUNDING_LVL_PARTY_TYPE      => null                                       ,
        P_COMPOUNDING_TAX_FLAG         => null                                       ,
        P_ORIG_TAX_STATUS_ID           => null                                       ,
        P_ORIG_TAX_STATUS_CODE         => null                                       ,
        P_ORIG_TAX_RATE_ID             => null                                       ,
        P_ORIG_TAX_RATE_CODE           => null                                       ,
        P_ORIG_TAX_RATE                => null                                       ,
        P_ORIG_TAX_JURISDICTION_ID     => null                                       ,
        P_ORIG_TAX_JURISDICTION_CODE   => null                                       ,
        P_ORIG_TAX_AMT_INCLUDED_FLAG   => null                                       ,
        P_ORIG_SELF_ASSESSED_FLAG      => null                                       ,
        P_TAX_CURRENCY_CODE            => null                                       ,
        P_TAX_AMT                      => g_suite_rec_tbl.tax_amt(i)                 ,
        P_TAX_AMT_TAX_CURR             => null                                       ,
        P_TAX_AMT_FUNCL_CURR           => null                                       ,
        P_TAXABLE_AMT                  => g_suite_rec_tbl.taxable_amt(i)             ,
        P_TAXABLE_AMT_TAX_CURR         => null                                       ,
        P_TAXABLE_AMT_FUNCL_CURR       => null                                       ,
        P_ORIG_TAXABLE_AMT             => null                                       ,
        P_ORIG_TAXABLE_AMT_TAX_CURR    => null                                       ,
        P_CAL_TAX_AMT                  => null                                       ,
        P_CAL_TAX_AMT_TAX_CURR         => null                                       ,
        P_CAL_TAX_AMT_FUNCL_CURR       => null                                       ,
        P_ORIG_TAX_AMT                 => null                                       ,
        P_ORIG_TAX_AMT_TAX_CURR        => null                                       ,
        P_REC_TAX_AMT                  => g_suite_rec_tbl.rec_tax_amt(i)             ,
        P_REC_TAX_AMT_TAX_CURR         => null                                       ,
        P_REC_TAX_AMT_FUNCL_CURR       => null                                       ,
        P_NREC_TAX_AMT                 => g_suite_rec_tbl.nrec_tax_amt(i)            ,
        P_NREC_TAX_AMT_TAX_CURR        => null                                       ,
        P_NREC_TAX_AMT_FUNCL_CURR      => null                                       ,
        P_TAX_EXEMPTION_ID             => g_suite_rec_tbl.tax_exemption_id(i)        ,
        P_TAX_RATE_BEFORE_EXEMPTION    => null, --NOT SURE IF IT IS g_suite_rec_tbl.exemption_rate(i),
        P_TAX_RATE_NAME_BEFORE_EXEMPT  => null                                       ,
        P_EXEMPT_RATE_MODIFIER         => null                                       ,
        P_EXEMPT_CERTIFICATE_NUMBER    => g_suite_rec_tbl.exempt_certificate_number(i),
        P_EXEMPT_REASON                => null                                       ,
        P_EXEMPT_REASON_CODE           => g_suite_rec_tbl.exempt_reason_code(i)      ,
        P_TAX_EXCEPTION_ID             => null                                       ,
        P_TAX_RATE_BEFORE_EXCEPTION    => null                                       ,
        P_TAX_RATE_NAME_BEFORE_EXCEPT  => null                                       ,
        P_EXCEPTION_RATE               => g_suite_rec_tbl.exemption_rate(i)          ,
        P_TAX_APPORTIONMENT_FLAG       => null                                       ,
        P_HISTORICAL_FLAG              => null                                       ,
        P_TAXABLE_BASIS_FORMULA        => null                                       ,
        P_TAX_CALCULATION_FORMULA      => null                                       ,
        P_CANCEL_FLAG                  => g_suite_rec_tbl.cancel_flag(i)             ,
        P_PURGE_FLAG                   => null                                       ,
        P_DELETE_FLAG                  => null                                       ,
        P_TAX_AMT_INCLUDED_FLAG        => g_suite_rec_tbl.tax_amt_included_flag(i)   ,
        P_SELF_ASSESSED_FLAG           => g_suite_rec_tbl.self_assessed_flag(i)      ,
        P_OVERRIDDEN_FLAG              => null                                       ,
        P_MANUALLY_ENTERED_FLAG        => g_suite_rec_tbl.manually_entered_flag(i)   ,
        P_REPORTING_ONLY_FLAG          => null                                       ,
        P_FREEZE_UNTIL_OVERRIDDN_FLG   => null                                       ,
        P_COPIED_FROM_OTHER_DOC_FLAG   => null                                       ,
        P_RECALC_REQUIRED_FLAG         => null                                       ,
        P_SETTLEMENT_FLAG              => null                                       ,
        P_ITEM_DIST_CHANGED_FLAG       => null                                       ,
        P_ASSOC_CHILDREN_FROZEN_FLG    => null                                       ,
        P_TAX_ONLY_LINE_FLAG           => null                                       ,
        P_COMPOUNDING_DEP_TAX_FLAG     => null                                       ,
        P_COMPOUNDING_TAX_MISS_FLAG    => null                                       ,
        P_SYNC_WITH_PRVDR_FLAG         => null                                       ,
        P_LAST_MANUAL_ENTRY            => null                                       ,
        P_TAX_PROVIDER_ID              => null                                       ,
        P_RECORD_TYPE_CODE             => null                                       ,
        P_REPORTING_PERIOD_ID          => null                                       ,
        P_LEGAL_JUSTIFICATION_TEXT1    => null                                       ,
        P_LEGAL_JUSTIFICATION_TEXT2    => null                                       ,
        P_LEGAL_JUSTIFICATION_TEXT3    => null                                       ,
        P_LEGAL_MESSAGE_APPL_2         => null                                       ,
        P_LEGAL_MESSAGE_STATUS         => null                                       ,
        P_LEGAL_MESSAGE_RATE           => null                                       ,
        P_LEGAL_MESSAGE_BASIS          => null                                       ,
        P_LEGAL_MESSAGE_CALC           => null                                       ,
        P_LEGAL_MESSAGE_THRESHOLD      => null                                       ,
        P_LEGAL_MESSAGE_POS            => null                                       ,
        P_LEGAL_MESSAGE_TRN            => null                                       ,
        P_LEGAL_MESSAGE_EXMPT          => null                                       ,
        P_LEGAL_MESSAGE_EXCPT          => null                                       ,
        P_TAX_REGIME_TEMPLATE_ID       => null                                       ,
        P_TAX_APPLICABILITY_RESULT_ID  => null                                       ,
        P_DIRECT_RATE_RESULT_ID        => null                                       ,
        P_STATUS_RESULT_ID             => null                                       ,
        P_RATE_RESULT_ID               => null                                       ,
        P_BASIS_RESULT_ID              => null                                       ,
        P_THRESH_RESULT_ID             => null                                       ,
        P_CALC_RESULT_ID               => null                                       ,
        P_TAX_REG_NUM_DET_RESULT_ID    => null                                       ,
        P_EVAL_EXMPT_RESULT_ID         => null                                       ,
        P_EVAL_EXCPT_RESULT_ID         => null                                       ,
        P_ENFORCED_FROM_NAT_ACCT_FLG   => null                                       ,
        P_TAX_HOLD_CODE                => null                                       ,
        P_TAX_HOLD_RELEASED_CODE       => null                                       ,
        P_PRD_TOTAL_TAX_AMT            => null                                       ,
        P_PRD_TOTAL_TAX_AMT_TAX_CURR   => null                                       ,
        P_PRD_TOTAL_TAX_AMT_FUNCL_CURR => null                                       ,
        P_TRX_LINE_INDEX               => null                                       ,
        P_OFFSET_TAX_RATE_CODE         => null                                       ,
        P_PRORATION_CODE               => null                                       ,
        P_OTHER_DOC_SOURCE             => null                                       ,
        P_INTERNAL_ORG_LOCATION_ID     => null                                       ,
        P_LINE_ASSESSABLE_VALUE        => null                                       ,
        P_CTRL_TOTAL_LINE_TX_AMT       => g_suite_rec_tbl.ctrl_total_line_tx_amt(i)  ,
        P_APPLIED_TO_TRX_NUMBER        => null                                       ,
        --P_EVENT_ID  => null (has been renamed),
        P_ATTRIBUTE_CATEGORY           => null                                       ,
        P_ATTRIBUTE1                   => null                                       ,
        P_ATTRIBUTE2                   => null                                       ,
        P_ATTRIBUTE3                   => null                                       ,
        P_ATTRIBUTE4                   => null                                       ,
        P_ATTRIBUTE5                   => null                                       ,
        P_ATTRIBUTE6                   => null                                       ,
        P_ATTRIBUTE7                   => null                                       ,
        P_ATTRIBUTE8                   => null                                       ,
        P_ATTRIBUTE9                   => null                                       ,
        P_ATTRIBUTE10                  => null                                       ,
        P_ATTRIBUTE11                  => null                                       ,
        P_ATTRIBUTE12                  => null                                       ,
        P_ATTRIBUTE13                  => null                                       ,
        P_ATTRIBUTE14                  => null                                       ,
        P_ATTRIBUTE15                  => null                                       ,
        P_GLOBAL_ATTRIBUTE_CATEGORY    => null                                       ,
        P_GLOBAL_ATTRIBUTE1            => null                                       ,
        P_GLOBAL_ATTRIBUTE2            => null                                       ,
        P_GLOBAL_ATTRIBUTE3            => null                                       ,
        P_GLOBAL_ATTRIBUTE4            => null                                       ,
        P_GLOBAL_ATTRIBUTE5            => null                                       ,
        P_GLOBAL_ATTRIBUTE6            => null                                       ,
        P_GLOBAL_ATTRIBUTE7            => null                                       ,
        P_GLOBAL_ATTRIBUTE8            => null                                       ,
        P_GLOBAL_ATTRIBUTE9            => null                                       ,
        P_GLOBAL_ATTRIBUTE10           => null                                       ,
        P_GLOBAL_ATTRIBUTE11           => null                                       ,
        P_GLOBAL_ATTRIBUTE12           => null                                       ,
        P_GLOBAL_ATTRIBUTE13           => null                                       ,
        P_GLOBAL_ATTRIBUTE14           => null                                       ,
        P_GLOBAL_ATTRIBUTE15           => null                                       ,
        P_NUMERIC1                     => null                                       ,
        P_NUMERIC2                     => null                                       ,
        P_NUMERIC3                     => null                                       ,
        P_NUMERIC4                     => null                                       ,
        P_NUMERIC5                     => null                                       ,
        P_NUMERIC6                     => null                                       ,
        P_NUMERIC7                     => null                                       ,
        P_NUMERIC8                     => null                                       ,
        P_NUMERIC9                     => null                                       ,
        P_NUMERIC10                    => null                                       ,
        P_CHAR1                        => null                                       ,
        P_CHAR2                        => null                                       ,
        P_CHAR3                        => null                                       ,
        P_CHAR4                        => null                                       ,
        P_CHAR5                        => null                                       ,
        P_CHAR6                        => null                                       ,
        P_CHAR7                        => null                                       ,
        P_CHAR8                        => null                                       ,
        P_CHAR9                        => null                                       ,
        P_CHAR10                       => null                                       ,
        P_DATE1                        => null                                       ,
        P_DATE2                        => null                                       ,
        P_DATE3                        => null                                       ,
        P_DATE4                        => null                                       ,
        P_DATE5                        => null                                       ,
        P_DATE6                        => null                                       ,
        P_DATE7                        => null                                       ,
        P_DATE8                        => null                                       ,
        P_DATE9                        => null                                       ,
        P_DATE10                       => null                                       ,
        P_INTERFACE_ENTITY_CODE        => null                                       ,
        P_INTERFACE_TAX_LINE_ID        => null                                       ,
        P_TAXING_JURIS_GEOGRAPHY_ID    => null                                       ,
        P_ADJUSTED_DOC_TAX_LINE_ID     => null                                       ,
        P_OBJECT_VERSION_NUMBER        => 1                                          ,
        P_CREATED_BY                   => 1      , ---------------------------------
        P_CREATION_DATE                => sysdate, -- What are the correct values
        P_LAST_UPDATED_BY              => 1      , -- to pass for the Who Columns?
        P_LAST_UPDATE_DATE             => sysdate, -- Review this later.
        P_LAST_UPDATE_LOGIN            => 1 );      ---------------------------------

      END LOOP;


    ELSIF p_api_service = 'OVERRIDE_DETAIL_UPDATE_TAX_LINE' THEN
      ----------------------------------------------
      -- Get inital and ending row for the structure
      ----------------------------------------------
      get_start_end_rows_structure
       (
         p_suite      => p_suite_number,
         p_case       => p_case_number,
         p_structure  => 'STRUCTURE_OVERRIDE_DETAIL_TAX_LINES',
         x_start_row  => l_start_row,
         x_end_row    => l_end_row
       );

      /* For Lock Row V7 changes I didn't find following columns zx_trl_detail_override_pkg.Lock_row
        P_EXEMPTION_RATE                => g_suite_rec_tbl.exemption_rate(i)          ,
        P_EXEMPT_CERTIFICATE_NUMBER     => g_suite_rec_tbl.exempt_certificate_number(i),
        P_EXEMPT_REASON_CODE            => g_suite_rec_tbl.exempt_reason_code(i)      , */


      FOR i in l_start_row..l_end_row LOOP
        select object_version_number
        into l_object_version_number
        from zx_lines
        where application_id =g_suite_rec_tbl.application_id(i)
          and entity_code = g_suite_rec_tbl.entity_code(i)
          and event_class_code = g_suite_rec_tbl.event_class_code(i)
          and trx_id = g_suite_rec_tbl.trx_id(i)
          and trx_line_id = g_suite_rec_tbl.trx_line_id(i)
          and trx_level_type = g_suite_rec_tbl.trx_level_type(i)
          and tax_line_id = g_suite_rec_tbl.tax_line_id(i) ;

      zx_trl_detail_override_pkg.Lock_row (
        X_ROWID                        => l_row_id                                   ,
        P_TAX_LINE_ID                  => g_suite_rec_tbl.tax_line_id(i)             ,
        P_INTERNAL_ORGANIZATION_ID     => g_suite_rec_tbl.internal_organization_id(i),
        P_APPLICATION_ID               => g_suite_rec_tbl.application_id(i)          ,
        P_ENTITY_CODE                  => g_suite_rec_tbl.entity_code(i)             ,
        P_EVENT_CLASS_CODE             => g_suite_rec_tbl.event_class_code(i)        ,
        P_EVENT_TYPE_CODE              => g_suite_rec_tbl.event_type_code(i)         ,
        P_TRX_ID                       => g_suite_rec_tbl.trx_id(i)                  ,
        P_TRX_LINE_ID                  => g_suite_rec_tbl.trx_line_id(i)             ,
        P_TRX_LEVEL_TYPE               => g_suite_rec_tbl.trx_level_type(i)          ,
        P_TRX_LINE_NUMBER              => g_suite_rec_tbl.trx_line_number(i)         ,
        P_DOC_EVENT_STATUS             => null                                       ,
        P_TAX_EVENT_CLASS_CODE         => null                                       ,
        P_TAX_EVENT_TYPE_CODE          => null                                       ,
        P_TAX_LINE_NUMBER              => null                                       ,
        P_CONTENT_OWNER_ID             => null                                       ,
        P_TAX_REGIME_ID                => null                                       ,
        P_TAX_REGIME_CODE              => null                                       ,
        P_TAX_ID                       => null                                       ,
        P_TAX                          => g_suite_rec_tbl.tax(i)                     ,
        P_TAX_STATUS_ID                => g_suite_rec_tbl.tax_rate_id(i)             ,
        P_TAX_STATUS_CODE              => g_suite_rec_tbl.tax_rate_code(i)           ,
        P_TAX_RATE_ID                  => null                                       ,
        P_TAX_RATE_CODE                => null                                       ,
        P_TAX_RATE                     => g_suite_rec_tbl.tax_rate(i)                ,
        P_TAX_RATE_TYPE                => null                                       ,
        P_TAX_APPORTIONMENT_LINE_NUM   => null                                       ,
        P_TRX_ID_LEVEL2                => null                                       ,
        P_TRX_ID_LEVEL3                => null                                       ,
        P_TRX_ID_LEVEL4                => null                                       ,
        P_TRX_ID_LEVEL5                => null                                       ,
        P_TRX_ID_LEVEL6                => null                                       ,
        P_TRX_USER_KEY_LEVEL1          => null                                       ,
        P_TRX_USER_KEY_LEVEL2          => null                                       ,
        P_TRX_USER_KEY_LEVEL3          => null                                       ,
        P_TRX_USER_KEY_LEVEL4          => null                                       ,
        P_TRX_USER_KEY_LEVEL5          => null                                       ,
        P_TRX_USER_KEY_LEVEL6          => null                                       ,
/*        P_HDR_TRX_USER_KEY1            => null                                       ,
        P_HDR_TRX_USER_KEY2            => null                                       ,
        P_HDR_TRX_USER_KEY3            => null                                       ,
        P_HDR_TRX_USER_KEY4            => null                                       ,
        P_HDR_TRX_USER_KEY5            => null                                       ,
        P_HDR_TRX_USER_KEY6            => null                                       ,
        P_LINE_TRX_USER_KEY1           => null                                       ,
        P_LINE_TRX_USER_KEY2           => null                                       ,
        P_LINE_TRX_USER_KEY3           => null                                       ,
        P_LINE_TRX_USER_KEY4           => null                                       ,
        P_LINE_TRX_USER_KEY5           => null                                       ,
        P_LINE_TRX_USER_KEY6           => null                                       ,*/
        P_MRC_TAX_LINE_FLAG            => null                                       ,
        P_MRC_LINK_TO_TAX_LINE_ID      => null                                       ,
        P_LEDGER_ID                    => null                                       ,
        P_ESTABLISHMENT_ID             => null                                       ,
        P_LEGAL_ENTITY_ID              => null                                       ,
     --  P_LEGAL_ENTITY_TAX_REG_NUMBER  => null                                       ,
        P_HQ_ESTB_REG_NUMBER           => null                                       ,
        P_HQ_ESTB_PARTY_TAX_PROF_ID    => null                                       ,
        P_CURRENCY_CONVERSION_DATE     => null                                       ,
        P_CURRENCY_CONVERSION_TYPE     => null                                       ,
        P_CURRENCY_CONVERSION_RATE     => null                                       ,
        P_TAX_CURR_CONVERSION_DATE     => null                                       ,
        P_TAX_CURR_CONVERSION_TYPE     => null                                       ,
        P_TAX_CURR_CONVERSION_RATE     => null                                       ,
        P_TRX_CURRENCY_CODE            => null                                       ,
        P_REPORTING_CURRENCY_CODE      => null                                       ,
        P_MINIMUM_ACCOUNTABLE_UNIT     => null                                       ,
        P_PRECISION                    => null                                       ,
        P_TRX_NUMBER                   => g_suite_rec_tbl.trx_number(i)              ,
        P_TRX_DATE                     => null                                       ,
        P_UNIT_PRICE                   => null                                       ,
        P_LINE_AMT                     => null                                       ,
        P_TRX_LINE_QUANTITY            => null                                       ,
        P_TAX_BASE_MODIFIER_RATE       => null                                       ,
        P_REF_DOC_APPLICATION_ID       => null                                       ,
        P_REF_DOC_ENTITY_CODE          => null                                       ,
        P_REF_DOC_EVENT_CLASS_CODE     => null                                       ,
        P_REF_DOC_TRX_ID               => null                                       ,
        P_REF_DOC_TRX_LEVEL_TYPE       => null                                       ,
        P_REF_DOC_LINE_ID              => null                                       ,
        P_REF_DOC_LINE_QUANTITY        => null                                       ,
        P_OTHER_DOC_LINE_AMT           => null                                       ,
        P_OTHER_DOC_LINE_TAX_AMT       => null                                       ,
        P_OTHER_DOC_LINE_TAXABLE_AMT   => null                                       ,
        P_UNROUNDED_TAXABLE_AMT        => null                                       ,
        P_UNROUNDED_TAX_AMT            => null                                       ,
        P_RELATED_DOC_APPLICATION_ID   => null                                       ,
        P_RELATED_DOC_ENTITY_CODE      => null                                       ,
        P_RELATED_DOC_EVT_CLASS_CODE   => null                                       ,
        P_RELATED_DOC_TRX_ID           => null                                       ,
        P_RELATED_DOC_TRX_LEVEL_TYPE   => null                                       ,
        P_RELATED_DOC_NUMBER           => null                                       ,
        P_RELATED_DOC_DATE             => null                                       ,
        P_APPLIED_FROM_APPL_ID         => null                                       ,
        P_APPLIED_FROM_EVT_CLSS_CODE   => null                                       ,
        P_APPLIED_FROM_ENTITY_CODE     => null                                       ,
        P_APPLIED_FROM_TRX_ID          => null                                       ,
        P_APPLIED_FROM_TRX_LEVEL_TYPE  => null                                       ,
        P_APPLIED_FROM_LINE_ID         => null                                       ,
        P_APPLIED_FROM_TRX_NUMBER      => null                                       ,
        P_ADJUSTED_DOC_APPLN_ID        => null                                       ,
        P_ADJUSTED_DOC_ENTITY_CODE     => g_suite_rec_tbl.adjusted_doc_entity_code(i),
        P_ADJUSTED_DOC_EVT_CLSS_CODE   => null                                       ,
        P_ADJUSTED_DOC_TRX_ID          => null                                       ,
        P_ADJUSTED_DOC_TRX_LEVEL_TYPE  => null                                       ,
        P_ADJUSTED_DOC_LINE_ID         => null                                       ,
        P_ADJUSTED_DOC_NUMBER          => null                                       ,
        P_ADJUSTED_DOC_DATE            => null                                       ,
        P_APPLIED_TO_APPLICATION_ID    => null                                       ,
        P_APPLIED_TO_EVT_CLASS_CODE    => null                                       ,
        P_APPLIED_TO_ENTITY_CODE       => null                                       ,
        P_APPLIED_TO_TRX_ID            => null                                       ,
        P_APPLIED_TO_TRX_LEVEL_TYPE    => null                                       ,
        P_APPLIED_TO_LINE_ID           => null                                       ,
        P_SUMMARY_TAX_LINE_ID          => g_suite_rec_tbl.summary_tax_line_id(i)     ,
        P_OFFSET_LINK_TO_TAX_LINE_ID   => null                                       ,
        P_OFFSET_FLAG                  => null                                       ,
        P_PROCESS_FOR_RECOVERY_FLAG    => null                                       ,
        P_TAX_JURISDICTION_ID          => g_suite_rec_tbl.tax_jurisdiction_id(i)     ,
        P_TAX_JURISDICTION_CODE        => null                                       ,
        P_PLACE_OF_SUPPLY              => null                                       ,
        P_PLACE_OF_SUPPLY_TYPE_CODE    => null                                       ,
        P_PLACE_OF_SUPPLY_RESULT_ID    => null                                       ,
        P_TAX_DATE_RULE_ID             => null                                       ,
        P_TAX_DATE                     => null                                       ,
        P_TAX_DETERMINE_DATE           => null                                       ,
        P_TAX_POINT_DATE               => null                                       ,
        P_TRX_LINE_DATE                => null                                       ,
        P_TAX_TYPE_CODE                => null                                       ,
        P_TAX_CODE                     => null                                       ,
        P_TAX_REGISTRATION_ID          => null                                       ,
        P_TAX_REGISTRATION_NUMBER      => g_suite_rec_tbl.tax_registration_number(i) ,
        P_REGISTRATION_PARTY_TYPE      => null                                       ,
        P_ROUNDING_LEVEL_CODE          => null                                       ,
        P_ROUNDING_RULE_CODE           => null                                       ,
        P_RNDG_LVL_PARTY_TAX_PROF_ID   => null                                       ,
        P_ROUNDING_LVL_PARTY_TYPE      => null                                       ,
        P_COMPOUNDING_TAX_FLAG         => null                                       ,
        P_ORIG_TAX_STATUS_ID           => null                                       ,
        P_ORIG_TAX_STATUS_CODE         => null                                       ,
        P_ORIG_TAX_RATE_ID             => null                                       ,
        P_ORIG_TAX_RATE_CODE           => null                                       ,
        P_ORIG_TAX_RATE                => null                                       ,
        P_ORIG_TAX_JURISDICTION_ID     => null                                       ,
        P_ORIG_TAX_JURISDICTION_CODE   => null                                       ,
        P_ORIG_TAX_AMT_INCLUDED_FLAG   => null                                       ,
        P_ORIG_SELF_ASSESSED_FLAG      => null                                       ,
        P_TAX_CURRENCY_CODE            => null                                       ,
        P_TAX_AMT                      => g_suite_rec_tbl.tax_amt(i)                 ,
        P_TAX_AMT_TAX_CURR             => null                                       ,
        P_TAX_AMT_FUNCL_CURR           => null                                       ,
        P_TAXABLE_AMT                  => g_suite_rec_tbl.taxable_amt(i)             ,
        P_TAXABLE_AMT_TAX_CURR         => null                                       ,
        P_TAXABLE_AMT_FUNCL_CURR       => null                                       ,
        P_ORIG_TAXABLE_AMT             => null                                       ,
        P_ORIG_TAXABLE_AMT_TAX_CURR    => null                                       ,
        P_CAL_TAX_AMT                  => null                                       ,
        P_CAL_TAX_AMT_TAX_CURR         => null                                       ,
        P_CAL_TAX_AMT_FUNCL_CURR       => null                                       ,
        P_ORIG_TAX_AMT                 => null                                       ,
        P_ORIG_TAX_AMT_TAX_CURR        => null                                       ,
        P_REC_TAX_AMT                  => g_suite_rec_tbl.rec_tax_amt(i)             ,
        P_REC_TAX_AMT_TAX_CURR         => null                                       ,
        P_REC_TAX_AMT_FUNCL_CURR       => null                                       ,
        P_NREC_TAX_AMT                 => g_suite_rec_tbl.nrec_tax_amt(i)            ,
        P_NREC_TAX_AMT_TAX_CURR        => null                                       ,
        P_NREC_TAX_AMT_FUNCL_CURR      => null                                       ,
        P_TAX_EXEMPTION_ID             => g_suite_rec_tbl.tax_exemption_id(i)        ,
        P_TAX_RATE_BEFORE_EXEMPTION    => null                                       ,
        P_TAX_RATE_NAME_BEFORE_EXEMPT  => null                                       ,
        P_EXEMPT_RATE_MODIFIER         => null                                       ,
        P_EXEMPT_CERTIFICATE_NUMBER    => null                                       ,
        P_EXEMPT_REASON                => null                                       ,
        P_EXEMPT_REASON_CODE           => null                                       ,
        P_TAX_EXCEPTION_ID             => null                                       ,
        P_TAX_RATE_BEFORE_EXCEPTION    => null                                       ,
        P_TAX_RATE_NAME_BEFORE_EXCEPT  => null                                       ,
        P_EXCEPTION_RATE               => null                                       ,
        P_TAX_APPORTIONMENT_FLAG       => null                                       ,
        P_HISTORICAL_FLAG              => null                                       ,
        P_TAXABLE_BASIS_FORMULA        => null                                       ,
        P_TAX_CALCULATION_FORMULA      => null                                       ,
        P_CANCEL_FLAG                  => null                                       ,
        P_PURGE_FLAG                   => null                                       ,
        P_DELETE_FLAG                  => null                                       ,
        P_TAX_AMT_INCLUDED_FLAG        => g_suite_rec_tbl.tax_amt_included_flag(i)   ,
        P_SELF_ASSESSED_FLAG           => g_suite_rec_tbl.self_assessed_flag(i)      ,
        P_OVERRIDDEN_FLAG              => null                                       ,
        P_MANUALLY_ENTERED_FLAG        => null                                       ,
        P_REPORTING_ONLY_FLAG          => null                                       ,
        P_FREEZE_UNTIL_OVERRIDDN_FLG   => null                                       ,
        P_COPIED_FROM_OTHER_DOC_FLAG   => null                                       ,
        P_RECALC_REQUIRED_FLAG         => null                                       ,
        P_SETTLEMENT_FLAG              => null                                       ,
        P_ITEM_DIST_CHANGED_FLAG       => null                                       ,
        P_ASSOC_CHILDREN_FROZEN_FLG    => null                                       ,
        P_TAX_ONLY_LINE_FLAG           => null                                       ,
        P_COMPOUNDING_DEP_TAX_FLAG     => null                                       ,
        P_COMPOUNDING_TAX_MISS_FLAG    => null                                       ,
        P_SYNC_WITH_PRVDR_FLAG         => null                                       ,
        P_LAST_MANUAL_ENTRY            => null                                       ,
        P_TAX_PROVIDER_ID              => null                                       ,
        P_RECORD_TYPE_CODE             => null                                       ,
        P_REPORTING_PERIOD_ID          => null                                       ,
        P_LEGAL_JUSTIFICATION_TEXT1    => null                                       ,
        P_LEGAL_JUSTIFICATION_TEXT2    => null                                       ,
        P_LEGAL_JUSTIFICATION_TEXT3    => null                                       ,
        P_LEGAL_MESSAGE_APPL_2         => null                                       ,
        P_LEGAL_MESSAGE_STATUS         => null                                       ,
        P_LEGAL_MESSAGE_RATE           => null                                       ,
        P_LEGAL_MESSAGE_BASIS          => null                                       ,
        P_LEGAL_MESSAGE_CALC           => null                                       ,
        P_LEGAL_MESSAGE_THRESHOLD      => null                                       ,
        P_LEGAL_MESSAGE_POS            => null                                       ,
        P_LEGAL_MESSAGE_TRN            => null                                       ,
        P_LEGAL_MESSAGE_EXMPT          => null                                       ,
        P_LEGAL_MESSAGE_EXCPT          => null                                       ,
        P_TAX_REGIME_TEMPLATE_ID       => null                                       ,
        P_TAX_APPLICABILITY_RESULT_ID  => null                                       ,
        P_DIRECT_RATE_RESULT_ID        => null                                       ,
        P_STATUS_RESULT_ID             => null                                       ,
        P_RATE_RESULT_ID               => null                                       ,
        P_BASIS_RESULT_ID              => null                                       ,
        P_THRESH_RESULT_ID             => null                                       ,
        P_CALC_RESULT_ID               => null                                       ,
        P_TAX_REG_NUM_DET_RESULT_ID    => null                                       ,
        P_EVAL_EXMPT_RESULT_ID         => null                                       ,
        P_EVAL_EXCPT_RESULT_ID         => null                                       ,
        P_ENFORCED_FROM_NAT_ACCT_FLG   => null                                       ,
        P_TAX_HOLD_CODE                => null                                       ,
        P_TAX_HOLD_RELEASED_CODE       => null                                       ,
        P_PRD_TOTAL_TAX_AMT            => null                                       ,
        P_PRD_TOTAL_TAX_AMT_TAX_CURR   => null                                       ,
        P_PRD_TOTAL_TAX_AMT_FUNCL_CURR => null                                       ,
        P_TRX_LINE_INDEX               => null                                       ,
        P_OFFSET_TAX_RATE_CODE         => null                                       ,
        P_PRORATION_CODE               => null                                       ,
        P_OTHER_DOC_SOURCE             => null                                       ,
        P_INTERNAL_ORG_LOCATION_ID     => null                                       ,
        P_LINE_ASSESSABLE_VALUE        => null                                       ,
        P_CTRL_TOTAL_LINE_TX_AMT       => g_suite_rec_tbl.ctrl_total_line_tx_amt(i)  ,
        P_APPLIED_TO_TRX_NUMBER        => null                                       ,
        P_ATTRIBUTE_CATEGORY           => null                                       ,
        P_ATTRIBUTE1                   => null                                       ,
        P_ATTRIBUTE2                   => null                                       ,
        P_ATTRIBUTE3                   => null                                       ,
        P_ATTRIBUTE4                   => null                                       ,
        P_ATTRIBUTE5                   => null                                       ,
        P_ATTRIBUTE6                   => null                                       ,
        P_ATTRIBUTE7                   => null                                       ,
        P_ATTRIBUTE8                   => null                                       ,
        P_ATTRIBUTE9                   => null                                       ,
        P_ATTRIBUTE10                  => null                                       ,
        P_ATTRIBUTE11                  => null                                       ,
        P_ATTRIBUTE12                  => null                                       ,
        P_ATTRIBUTE13                  => null                                       ,
        P_ATTRIBUTE14                  => null                                       ,
        P_ATTRIBUTE15                  => null                                       ,
        P_GLOBAL_ATTRIBUTE_CATEGORY    => null                                       ,
        P_GLOBAL_ATTRIBUTE1            => null                                       ,
        P_GLOBAL_ATTRIBUTE2            => null                                       ,
        P_GLOBAL_ATTRIBUTE3            => null                                       ,
        P_GLOBAL_ATTRIBUTE4            => null                                       ,
        P_GLOBAL_ATTRIBUTE5            => null                                       ,
        P_GLOBAL_ATTRIBUTE6            => null                                       ,
        P_GLOBAL_ATTRIBUTE7            => null                                       ,
        P_GLOBAL_ATTRIBUTE8            => null                                       ,
        P_GLOBAL_ATTRIBUTE9            => null                                       ,
        P_GLOBAL_ATTRIBUTE10           => null                                       ,
        P_GLOBAL_ATTRIBUTE11           => null                                       ,
        P_GLOBAL_ATTRIBUTE12           => null                                       ,
        P_GLOBAL_ATTRIBUTE13           => null                                       ,
        P_GLOBAL_ATTRIBUTE14           => null                                       ,
        P_GLOBAL_ATTRIBUTE15           => null                                       ,
        P_NUMERIC1                     => null                                       ,
        P_NUMERIC2                     => null                                       ,
        P_NUMERIC3                     => null                                       ,
        P_NUMERIC4                     => null                                       ,
        P_NUMERIC5                     => null                                       ,
        P_NUMERIC6                     => null                                       ,
        P_NUMERIC7                     => null                                       ,
        P_NUMERIC8                     => null                                       ,
        P_NUMERIC9                     => null                                       ,
        P_NUMERIC10                    => null                                       ,
        P_CHAR1                        => null                                       ,
        P_CHAR2                        => null                                       ,
        P_CHAR3                        => null                                       ,
        P_CHAR4                        => null                                       ,
        P_CHAR5                        => null                                       ,
        P_CHAR6                        => null                                       ,
        P_CHAR7                        => null                                       ,
        P_CHAR8                        => null                                       ,
        P_CHAR9                        => null                                       ,
        P_CHAR10                       => null                                       ,
        P_DATE1                        => null                                       ,
        P_DATE2                        => null                                       ,
        P_DATE3                        => null                                       ,
        P_DATE4                        => null                                       ,
        P_DATE5                        => null                                       ,
        P_DATE6                        => null                                       ,
        P_DATE7                        => null                                       ,
        P_DATE8                        => null                                       ,
        P_DATE9                        => null                                       ,
        P_DATE10                       => null                                       ,
        P_INTERFACE_ENTITY_CODE        => null                                       ,
        P_INTERFACE_TAX_LINE_ID        => null                                       ,
        P_TAXING_JURIS_GEOGRAPHY_ID    => null                                       ,
        P_ADJUSTED_DOC_TAX_LINE_ID     => null                                       ,
        P_OBJECT_VERSION_NUMBER        => l_object_version_number                    ,
        P_CREATED_BY                   => 1      , ---------------------------------
        P_CREATION_DATE                => sysdate, -- What are the correct values
        P_LAST_UPDATED_BY              => 1      , -- to pass for the Who Columns?
        P_LAST_UPDATE_DATE             => sysdate, -- Review this later.
        P_LAST_UPDATE_LOGIN            => 1 );      ---------------------------------

      END LOOP;

      FOR i in l_start_row..l_end_row LOOP
        select object_version_number
        into l_object_version_number
        from zx_lines
        where application_id =g_suite_rec_tbl.application_id(i)
          and entity_code = g_suite_rec_tbl.entity_code(i)
          and event_class_code = g_suite_rec_tbl.event_class_code(i)
          and trx_id = g_suite_rec_tbl.trx_id(i)
          and trx_line_id = g_suite_rec_tbl.trx_line_id(i)
          and trx_level_type = g_suite_rec_tbl.trx_level_type(i)
          and tax_line_id = g_suite_rec_tbl.tax_line_id(i) ;

      zx_trl_detail_override_pkg.Update_row(
        --X_ROWID                        => l_row_id                                   ,
        P_TAX_LINE_ID                  => g_suite_rec_tbl.tax_line_id(i)             ,
        P_INTERNAL_ORGANIZATION_ID     => g_suite_rec_tbl.internal_organization_id(i),
        P_APPLICATION_ID               => g_suite_rec_tbl.application_id(i)          ,
        P_ENTITY_CODE                  => g_suite_rec_tbl.entity_code(i)             ,
        P_EVENT_CLASS_CODE             => g_suite_rec_tbl.event_class_code(i)        ,
        P_EVENT_TYPE_CODE              => g_suite_rec_tbl.event_type_code(i)         ,
        P_TRX_ID                       => g_suite_rec_tbl.trx_id(i)                  ,
        P_TRX_LINE_ID                  => g_suite_rec_tbl.trx_line_id(i)             ,
        P_TRX_LEVEL_TYPE               => g_suite_rec_tbl.trx_level_type(i)          ,
        P_TRX_LINE_NUMBER              => g_suite_rec_tbl.trx_line_number(i)         ,
        P_DOC_EVENT_STATUS             => null                                       ,
        P_TAX_EVENT_CLASS_CODE         => null                                       ,
        P_TAX_EVENT_TYPE_CODE          => null                                       ,
        P_TAX_LINE_NUMBER              => null                                       ,
        P_CONTENT_OWNER_ID             => null                                       ,
        P_TAX_REGIME_ID                => null                                       ,
        P_TAX_REGIME_CODE              => g_suite_rec_tbl.tax_regime_code(i)         ,
        P_TAX_ID                       => null                                       ,
        P_TAX                          => null                                       ,
        P_TAX_STATUS_ID                => null                                       ,
        P_TAX_STATUS_CODE              => g_suite_rec_tbl.tax_status_code(i)         ,
        P_TAX_RATE_ID                  => g_suite_rec_tbl.tax_rate_id(i)             ,
        P_TAX_RATE_CODE                => g_suite_rec_tbl.tax_rate_code(i)           ,
        P_TAX_RATE                     => g_suite_rec_tbl.tax_rate(i)                ,
        P_TAX_RATE_TYPE                => null                                       ,
        P_TAX_APPORTIONMENT_LINE_NUM   => null                                       ,
        P_TRX_ID_LEVEL2                => null                                       ,
        P_TRX_ID_LEVEL3                => null                                       ,
        P_TRX_ID_LEVEL4                => null                                       ,
        P_TRX_ID_LEVEL5                => null                                       ,
        P_TRX_ID_LEVEL6                => null                                       ,
        P_TRX_USER_KEY_LEVEL1          => null                                       ,
        P_TRX_USER_KEY_LEVEL2          => null                                       ,
        P_TRX_USER_KEY_LEVEL3          => null                                       ,
        P_TRX_USER_KEY_LEVEL4          => null                                       ,
        P_TRX_USER_KEY_LEVEL5          => null                                       ,
        P_TRX_USER_KEY_LEVEL6          => null                                       ,
        /*P_HDR_TRX_USER_KEY1            => null                                       ,
        P_HDR_TRX_USER_KEY2            => null                                       ,
        P_HDR_TRX_USER_KEY3            => null                                       ,
        P_HDR_TRX_USER_KEY4            => null                                       ,
        P_HDR_TRX_USER_KEY5            => null                                       ,
        P_HDR_TRX_USER_KEY6            => null                                       ,
        P_LINE_TRX_USER_KEY1           => null                                       ,
        P_LINE_TRX_USER_KEY2           => null                                       ,
        P_LINE_TRX_USER_KEY3           => null                                       ,
        P_LINE_TRX_USER_KEY4           => null                                       ,
        P_LINE_TRX_USER_KEY5           => null                                       ,
        P_LINE_TRX_USER_KEY6           => null                                       ,*/
        P_MRC_TAX_LINE_FLAG            => null                                       ,
        P_MRC_LINK_TO_TAX_LINE_ID      => null                                       ,
        P_LEDGER_ID                    => null                                       ,
        P_ESTABLISHMENT_ID             => null                                       ,
        P_LEGAL_ENTITY_ID              => null                                       ,
        -- P_LEGAL_ENTITY_TAX_REG_NUMBER  => null                                       ,
        P_HQ_ESTB_REG_NUMBER           => null                                       ,
        P_HQ_ESTB_PARTY_TAX_PROF_ID    => null                                       ,
        P_CURRENCY_CONVERSION_DATE     => null                                       ,
        P_CURRENCY_CONVERSION_TYPE     => null                                       ,
        P_CURRENCY_CONVERSION_RATE     => null                                       ,
        P_TAX_CURR_CONVERSION_DATE     => null                                       ,
        P_TAX_CURR_CONVERSION_TYPE     => null                                       ,
        P_TAX_CURR_CONVERSION_RATE     => null                                       ,
        P_TRX_CURRENCY_CODE            => null                                       ,
        P_REPORTING_CURRENCY_CODE      => null                                       ,
        P_MINIMUM_ACCOUNTABLE_UNIT     => null                                       ,
        P_PRECISION                    => null                                       ,
        P_TRX_NUMBER                   => null                                       ,
        P_TRX_DATE                     => null                                       ,
        P_UNIT_PRICE                   => null                                       ,
        P_LINE_AMT                     => null                                       ,
        P_TRX_LINE_QUANTITY            => null                                       ,
        P_TAX_BASE_MODIFIER_RATE       => null                                       ,
        P_REF_DOC_APPLICATION_ID       => null                                       ,
        P_REF_DOC_ENTITY_CODE          => null                                       ,
        P_REF_DOC_EVENT_CLASS_CODE     => null                                       ,
        P_REF_DOC_TRX_ID               => null                                       ,
        P_REF_DOC_TRX_LEVEL_TYPE       => null                                       ,
        P_REF_DOC_LINE_ID              => null                                       ,
        P_REF_DOC_LINE_QUANTITY        => null                                       ,
        P_OTHER_DOC_LINE_AMT           => null                                       ,
        P_OTHER_DOC_LINE_TAX_AMT       => null                                       ,
        P_OTHER_DOC_LINE_TAXABLE_AMT   => null                                       ,
        P_UNROUNDED_TAXABLE_AMT        => null                                       ,
        P_UNROUNDED_TAX_AMT            => null                                       ,
        P_RELATED_DOC_APPLICATION_ID   => null                                       ,
        P_RELATED_DOC_ENTITY_CODE      => null                                       ,
        P_RELATED_DOC_EVT_CLASS_CODE   => null                                       ,
        P_RELATED_DOC_TRX_ID           => null                                       ,
        P_RELATED_DOC_TRX_LEVEL_TYPE   => null                                       ,
        P_RELATED_DOC_NUMBER           => null                                       ,
        P_RELATED_DOC_DATE             => null                                       ,
        P_APPLIED_FROM_APPL_ID         => null                                       ,
        P_APPLIED_FROM_EVT_CLSS_CODE   => null                                       ,
        P_APPLIED_FROM_ENTITY_CODE     => null                                       ,
        P_APPLIED_FROM_TRX_ID          => null                                       ,
        P_APPLIED_FROM_TRX_LEVEL_TYPE  => null                                       ,
        P_APPLIED_FROM_LINE_ID         => null                                       ,
        P_APPLIED_FROM_TRX_NUMBER      => null                                       ,
        P_ADJUSTED_DOC_APPLN_ID        => null                                       ,
        P_ADJUSTED_DOC_ENTITY_CODE     => g_suite_rec_tbl.adjusted_doc_entity_code(i),
        P_ADJUSTED_DOC_EVT_CLSS_CODE   => null                                       ,
        P_ADJUSTED_DOC_TRX_ID          => null                                       ,
        P_ADJUSTED_DOC_TRX_LEVEL_TYPE  => null                                       ,
        P_ADJUSTED_DOC_LINE_ID         => null                                       ,
        P_ADJUSTED_DOC_NUMBER          => null                                       ,
        P_ADJUSTED_DOC_DATE            => null                                       ,
        P_APPLIED_TO_APPLICATION_ID    => null                                       ,
        P_APPLIED_TO_EVT_CLASS_CODE    => null                                       ,
        P_APPLIED_TO_ENTITY_CODE       => null                                       ,
        P_APPLIED_TO_TRX_ID            => null                                       ,
        P_APPLIED_TO_TRX_LEVEL_TYPE    => null                                       ,
        P_APPLIED_TO_LINE_ID           => null                                       ,
        P_SUMMARY_TAX_LINE_ID          => g_suite_rec_tbl.summary_tax_line_id(i)     ,
        P_OFFSET_LINK_TO_TAX_LINE_ID   => null                                       ,
        P_OFFSET_FLAG                  => null                                       ,
        P_PROCESS_FOR_RECOVERY_FLAG    => null                                       ,
        P_TAX_JURISDICTION_ID          => null                                       ,
        P_TAX_JURISDICTION_CODE        => null                                       ,
        P_PLACE_OF_SUPPLY              => null                                       ,
        P_PLACE_OF_SUPPLY_TYPE_CODE    => null                                       ,
        P_PLACE_OF_SUPPLY_RESULT_ID    => null                                       ,
        P_TAX_DATE_RULE_ID             => null                                       ,
        P_TAX_DATE                     => null                                       ,
        P_TAX_DETERMINE_DATE           => null                                       ,
        P_TAX_POINT_DATE               => null                                       ,
        P_TRX_LINE_DATE                => null                                       ,
        P_TAX_TYPE_CODE                => null                                       ,
        P_TAX_CODE                     => null                                       ,
        P_TAX_REGISTRATION_ID          => null                                       ,
        P_TAX_REGISTRATION_NUMBER      => null                                       ,
        P_REGISTRATION_PARTY_TYPE      => null                                       ,
        P_ROUNDING_LEVEL_CODE          => null                                       ,
        P_ROUNDING_RULE_CODE           => null                                       ,
        P_RNDG_LVL_PARTY_TAX_PROF_ID   => null                                       ,
        P_ROUNDING_LVL_PARTY_TYPE      => null                                       ,
        P_COMPOUNDING_TAX_FLAG         => null                                       ,
        P_ORIG_TAX_STATUS_ID           => null                                       ,
        P_ORIG_TAX_STATUS_CODE         => null                                       ,
        P_ORIG_TAX_RATE_ID             => null                                       ,
        P_ORIG_TAX_RATE_CODE           => null                                       ,
        P_ORIG_TAX_RATE                => null                                       ,
        P_ORIG_TAX_JURISDICTION_ID     => null                                       ,
        P_ORIG_TAX_JURISDICTION_CODE   => null                                       ,
        P_ORIG_TAX_AMT_INCLUDED_FLAG   => null                                       ,
        P_ORIG_SELF_ASSESSED_FLAG      => null                                       ,
        P_TAX_CURRENCY_CODE            => null                                       ,
        P_TAX_AMT                      => g_suite_rec_tbl.tax_amt(i)                 ,
        P_TAX_AMT_TAX_CURR             => null                                       ,
        P_TAX_AMT_FUNCL_CURR           => null                                       ,
        P_TAXABLE_AMT                  => null                                       ,
        P_TAXABLE_AMT_TAX_CURR         => null                                       ,
        P_TAXABLE_AMT_FUNCL_CURR       => null                                       ,
        P_ORIG_TAXABLE_AMT             => null                                       ,
        P_ORIG_TAXABLE_AMT_TAX_CURR    => null                                       ,
        P_CAL_TAX_AMT                  => null                                       ,
        P_CAL_TAX_AMT_TAX_CURR         => null                                       ,
        P_CAL_TAX_AMT_FUNCL_CURR       => null                                       ,
        P_ORIG_TAX_AMT                 => null                                       ,
        P_ORIG_TAX_AMT_TAX_CURR        => null                                       ,
        P_REC_TAX_AMT                  => null                                       ,
        P_REC_TAX_AMT_TAX_CURR         => null                                       ,
        P_REC_TAX_AMT_FUNCL_CURR       => null                                       ,
        P_NREC_TAX_AMT                 => null                                       ,
        P_NREC_TAX_AMT_TAX_CURR        => null                                       ,
        P_NREC_TAX_AMT_FUNCL_CURR      => null                                       ,
        P_TAX_EXEMPTION_ID             => null                                       ,
        P_TAX_RATE_BEFORE_EXEMPTION    => null                                       ,
        P_TAX_RATE_NAME_BEFORE_EXEMPT  => null                                       ,
        P_EXEMPT_RATE_MODIFIER         => null                                       ,
        P_EXEMPT_CERTIFICATE_NUMBER    => null                                       ,
        P_EXEMPT_REASON                => null                                       ,
        P_EXEMPT_REASON_CODE           => null                                       ,
        P_TAX_EXCEPTION_ID             => null                                       ,
        P_TAX_RATE_BEFORE_EXCEPTION    => null                                       ,
        P_TAX_RATE_NAME_BEFORE_EXCEPT  => null                                       ,
        P_EXCEPTION_RATE               => null                                       ,
        P_TAX_APPORTIONMENT_FLAG       => null                                       ,
        P_HISTORICAL_FLAG              => null                                       ,
        P_TAXABLE_BASIS_FORMULA        => null                                       ,
        P_TAX_CALCULATION_FORMULA      => null                                       ,
        P_CANCEL_FLAG                  => null                                       ,
        P_PURGE_FLAG                   => null                                       ,
        P_DELETE_FLAG                  => null                                       ,
        P_TAX_AMT_INCLUDED_FLAG        => g_suite_rec_tbl.tax_amt_included_flag(i)   ,
        P_SELF_ASSESSED_FLAG           => g_suite_rec_tbl.self_assessed_flag(i)      ,
        P_OVERRIDDEN_FLAG              => null                                       ,
        P_MANUALLY_ENTERED_FLAG        => null                                       ,
        P_REPORTING_ONLY_FLAG          => null                                       ,
        P_FREEZE_UNTIL_OVERRIDDN_FLG   => null                                       ,
        P_COPIED_FROM_OTHER_DOC_FLAG   => null                                       ,
        P_RECALC_REQUIRED_FLAG         => null                                       ,
        P_SETTLEMENT_FLAG              => null                                       ,
        P_ITEM_DIST_CHANGED_FLAG       => null                                       ,
        P_ASSOC_CHILDREN_FROZEN_FLG    => null                                       ,
        P_TAX_ONLY_LINE_FLAG           => null                                       ,
        P_COMPOUNDING_DEP_TAX_FLAG     => null                                       ,
        P_COMPOUNDING_TAX_MISS_FLAG    => null                                       ,
        P_SYNC_WITH_PRVDR_FLAG         => null                                       ,
        P_LAST_MANUAL_ENTRY            => null                                       ,
        P_TAX_PROVIDER_ID              => null                                       ,
        P_RECORD_TYPE_CODE             => null                                       ,
        P_REPORTING_PERIOD_ID          => null                                       ,
        P_LEGAL_JUSTIFICATION_TEXT1    => null                                       ,
        P_LEGAL_JUSTIFICATION_TEXT2    => null                                       ,
        P_LEGAL_JUSTIFICATION_TEXT3    => null                                       ,
        P_LEGAL_MESSAGE_APPL_2         => null                                       ,
        P_LEGAL_MESSAGE_STATUS         => null                                       ,
        P_LEGAL_MESSAGE_RATE           => null                                       ,
        P_LEGAL_MESSAGE_BASIS          => null                                       ,
        P_LEGAL_MESSAGE_CALC           => null                                       ,
        P_LEGAL_MESSAGE_THRESHOLD      => null                                       ,
        P_LEGAL_MESSAGE_POS            => null                                       ,
        P_LEGAL_MESSAGE_TRN            => null                                       ,
        P_LEGAL_MESSAGE_EXMPT          => null                                       ,
        P_LEGAL_MESSAGE_EXCPT          => null                                       ,
        P_TAX_REGIME_TEMPLATE_ID       => null                                       ,
        P_TAX_APPLICABILITY_RESULT_ID  => null                                       ,
        P_DIRECT_RATE_RESULT_ID        => null                                       ,
        P_STATUS_RESULT_ID             => null                                       ,
        P_RATE_RESULT_ID               => null                                       ,
        P_BASIS_RESULT_ID              => null                                       ,
        P_THRESH_RESULT_ID             => null                                       ,
        P_CALC_RESULT_ID               => null                                       ,
        P_TAX_REG_NUM_DET_RESULT_ID    => null                                       ,
        P_EVAL_EXMPT_RESULT_ID         => null                                       ,
        P_EVAL_EXCPT_RESULT_ID         => null                                       ,
        P_ENFORCED_FROM_NAT_ACCT_FLG   => null                                       ,
        P_TAX_HOLD_CODE                => null                                       ,
        P_TAX_HOLD_RELEASED_CODE       => null                                       ,
        P_PRD_TOTAL_TAX_AMT            => null                                       ,
        P_PRD_TOTAL_TAX_AMT_TAX_CURR   => null                                       ,
        P_PRD_TOTAL_TAX_AMT_FUNCL_CURR => null                                       ,
        P_TRX_LINE_INDEX               => null                                       ,
        P_OFFSET_TAX_RATE_CODE         => null                                       ,
        P_PRORATION_CODE               => null                                       ,
        P_OTHER_DOC_SOURCE             => null                                       ,
        P_INTERNAL_ORG_LOCATION_ID     => null                                       ,
        P_LINE_ASSESSABLE_VALUE        => null                                       ,
        P_CTRL_TOTAL_LINE_TX_AMT       => g_suite_rec_tbl.ctrl_total_line_tx_amt(i)  ,
        P_APPLIED_TO_TRX_NUMBER        => null                                       ,
        --P_CTRL_EF_OV_CAL_LINE_FLAG     => null                                       ,
        P_ATTRIBUTE_CATEGORY           => null                                       ,
        P_ATTRIBUTE1                   => null                                       ,
        P_ATTRIBUTE2                   => null                                       ,
        P_ATTRIBUTE3                   => null                                       ,
        P_ATTRIBUTE4                   => null                                       ,
        P_ATTRIBUTE5                   => null                                       ,
        P_ATTRIBUTE6                   => null                                       ,
        P_ATTRIBUTE7                   => null                                       ,
        P_ATTRIBUTE8                   => null                                       ,
        P_ATTRIBUTE9                   => null                                       ,
        P_ATTRIBUTE10                  => null                                       ,
        P_ATTRIBUTE11                  => null                                       ,
        P_ATTRIBUTE12                  => null                                       ,
        P_ATTRIBUTE13                  => null                                       ,
        P_ATTRIBUTE14                  => null                                       ,
        P_ATTRIBUTE15                  => null                                       ,
        P_GLOBAL_ATTRIBUTE_CATEGORY    => null                                       ,
        P_GLOBAL_ATTRIBUTE1            => null                                       ,
        P_GLOBAL_ATTRIBUTE2            => null                                       ,
        P_GLOBAL_ATTRIBUTE3            => null                                       ,
        P_GLOBAL_ATTRIBUTE4            => null                                       ,
        P_GLOBAL_ATTRIBUTE5            => null                                       ,
        P_GLOBAL_ATTRIBUTE6            => null                                       ,
        P_GLOBAL_ATTRIBUTE7            => null                                       ,
        P_GLOBAL_ATTRIBUTE8            => null                                       ,
        P_GLOBAL_ATTRIBUTE9            => null                                       ,
        P_GLOBAL_ATTRIBUTE10           => null                                       ,
        P_GLOBAL_ATTRIBUTE11           => null                                       ,
        P_GLOBAL_ATTRIBUTE12           => null                                       ,
        P_GLOBAL_ATTRIBUTE13           => null                                       ,
        P_GLOBAL_ATTRIBUTE14           => null                                       ,
        P_GLOBAL_ATTRIBUTE15           => null                                       ,
        P_NUMERIC1                     => null                                       ,
        P_NUMERIC2                     => null                                       ,
        P_NUMERIC3                     => null                                       ,
        P_NUMERIC4                     => null                                       ,
        P_NUMERIC5                     => null                                       ,
        P_NUMERIC6                     => null                                       ,
        P_NUMERIC7                     => null                                       ,
        P_NUMERIC8                     => null                                       ,
        P_NUMERIC9                     => null                                       ,
        P_NUMERIC10                    => null                                       ,
        P_CHAR1                        => null                                       ,
        P_CHAR2                        => null                                       ,
        P_CHAR3                        => null                                       ,
        P_CHAR4                        => null                                       ,
        P_CHAR5                        => null                                       ,
        P_CHAR6                        => null                                       ,
        P_CHAR7                        => null                                       ,
        P_CHAR8                        => null                                       ,
        P_CHAR9                        => null                                       ,
        P_CHAR10                       => null                                       ,
        P_DATE1                        => null                                       ,
        P_DATE2                        => null                                       ,
        P_DATE3                        => null                                       ,
        P_DATE4                        => null                                       ,
        P_DATE5                        => null                                       ,
        P_DATE6                        => null                                       ,
        P_DATE7                        => null                                       ,
        P_DATE8                        => null                                       ,
        P_DATE9                        => null                                       ,
        P_DATE10                       => null                                       ,
        P_INTERFACE_ENTITY_CODE        => null                                       ,
        P_INTERFACE_TAX_LINE_ID        => null                                       ,
        P_TAXING_JURIS_GEOGRAPHY_ID    => null                                       ,
        P_ADJUSTED_DOC_TAX_LINE_ID     => null                                       ,
        P_OBJECT_VERSION_NUMBER        => l_object_version_number+1                  ,
        --P_CREATED_BY                   => 1      , ---------------------------------
        --P_CREATION_DATE                => sysdate, -- What are the correct values
        P_LAST_UPDATED_BY              => 1      , -- to pass for the Who Columns?
        P_LAST_UPDATE_DATE             => sysdate, -- Review this later.
        P_LAST_UPDATE_LOGIN            => 1 );      ---------------------------------

      END LOOP;

      write_message('Service ZX_TRL_DETAIL_OVERRIDE_PKG.Lock_row/Update_row have been called!.');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );


    ELSIF p_api_service = 'OVERRIDE_DETAIL_DELETE_TAX_LINE' THEN
      ----------------------------------------------
      -- Get inital and ending row for the structure
      ----------------------------------------------
      get_start_end_rows_structure
       (
         p_suite      => p_suite_number,
         p_case       => p_case_number,
         p_structure  => 'STRUCTURE_OVERRIDE_DETAIL_TAX_LINES',
         x_start_row  => l_start_row,
         x_end_row    => l_end_row
       );


      /* In V7 Changes for ZX_TRL_DETAIL_OVERRIDE_PKG.delete_row
      P_EXEMPTION_RATE              => g_suite_rec_tbl.exemption_rate(i)
      is no longer there*/

      FOR i in l_start_row..l_end_row LOOP
        select object_version_number
        into l_object_version_number
        from zx_lines
        where application_id =g_suite_rec_tbl.application_id(i)
          and entity_code = g_suite_rec_tbl.entity_code(i)
          and event_class_code = g_suite_rec_tbl.event_class_code(i)
          and trx_id = g_suite_rec_tbl.trx_id(i)
          and trx_line_id = g_suite_rec_tbl.trx_line_id(i)
          and trx_level_type = g_suite_rec_tbl.trx_level_type(i)
          and tax_line_id = g_suite_rec_tbl.tax_line_id(i) ;

      ZX_TRL_DETAIL_OVERRIDE_PKG.delete_row(
        X_ROWID                        => l_row_id                                   ,
        P_TAX_LINE_ID                  => g_suite_rec_tbl.tax_line_id(i)             ,
        P_INTERNAL_ORGANIZATION_ID     => g_suite_rec_tbl.internal_organization_id(i),
        P_APPLICATION_ID               => g_suite_rec_tbl.application_id(i)          ,
        P_ENTITY_CODE                  => g_suite_rec_tbl.entity_code(i)             ,
        P_EVENT_CLASS_CODE             => g_suite_rec_tbl.event_class_code(i)        ,
        P_EVENT_TYPE_CODE              => g_suite_rec_tbl.event_type_code(i)         ,
        P_TRX_ID                       => g_suite_rec_tbl.trx_id(i)                  ,
        P_TRX_LINE_ID                  => g_suite_rec_tbl.trx_line_id(i)             ,
        P_TRX_LEVEL_TYPE               => g_suite_rec_tbl.trx_level_type(i)          ,
        P_TRX_LINE_NUMBER              => g_suite_rec_tbl.trx_line_number(i)         ,
        P_DOC_EVENT_STATUS             => null                                       ,
        P_TAX_EVENT_CLASS_CODE         => null                                       ,
        P_TAX_EVENT_TYPE_CODE          => null                                       ,
        P_TAX_LINE_NUMBER              => null                                       ,
        P_CONTENT_OWNER_ID             => null                                       ,
        P_TAX_REGIME_ID                => null                                       ,
        P_TAX_REGIME_CODE              => g_suite_rec_tbl.tax_regime_code(i)         ,
        P_TAX_ID                       => null                                       ,
        P_TAX                          => g_suite_rec_tbl.tax(i)                     ,
        P_TAX_STATUS_ID                => null                                       ,
        P_TAX_STATUS_CODE              => g_suite_rec_tbl.tax_status_code(i)         ,
        P_TAX_RATE_ID                  => g_suite_rec_tbl.tax_rate_id(i)             ,
        P_TAX_RATE_CODE                => g_suite_rec_tbl.tax_rate_code(i)           ,
        P_TAX_RATE                     => g_suite_rec_tbl.tax_rate(i)                ,
        P_TAX_RATE_TYPE                => null                                       ,
        P_TAX_APPORTIONMENT_LINE_NUM   => null                                       ,
        P_TRX_ID_LEVEL2                => null                                       ,
        P_TRX_ID_LEVEL3                => null                                       ,
        P_TRX_ID_LEVEL4                => null                                       ,
        P_TRX_ID_LEVEL5                => null                                       ,
        P_TRX_ID_LEVEL6                => null                                       ,
        P_TRX_USER_KEY_LEVEL1          => null                                       ,
        P_TRX_USER_KEY_LEVEL2          => null                                       ,
        P_TRX_USER_KEY_LEVEL3          => null                                       ,
        P_TRX_USER_KEY_LEVEL4          => null                                       ,
        P_TRX_USER_KEY_LEVEL5          => null                                       ,
        P_TRX_USER_KEY_LEVEL6          => null                                       ,
      /*P_HDR_TRX_USER_KEY1            => null                                       ,
        P_HDR_TRX_USER_KEY2            => null                                       ,
        P_HDR_TRX_USER_KEY3            => null                                       ,
        P_HDR_TRX_USER_KEY4            => null                                       ,
        P_HDR_TRX_USER_KEY5            => null                                       ,
        P_HDR_TRX_USER_KEY6            => null                                       ,
        P_LINE_TRX_USER_KEY1           => null                                       ,
        P_LINE_TRX_USER_KEY2           => null                                       ,
        P_LINE_TRX_USER_KEY3           => null                                       ,
        P_LINE_TRX_USER_KEY4           => null                                       ,
        P_LINE_TRX_USER_KEY5           => null                                       ,
        P_LINE_TRX_USER_KEY6           => null                                       ,*/
        P_MRC_TAX_LINE_FLAG            => null                                       ,
        P_MRC_LINK_TO_TAX_LINE_ID      => null                                       ,
        P_LEDGER_ID                    => null                                       ,
        P_ESTABLISHMENT_ID             => null                                       ,
        P_LEGAL_ENTITY_ID              => null                                       ,
        -- P_LEGAL_ENTITY_TAX_REG_NUMBER  => null                                       ,
        P_HQ_ESTB_REG_NUMBER           => null                                       ,
        P_HQ_ESTB_PARTY_TAX_PROF_ID    => null                                       ,
        P_CURRENCY_CONVERSION_DATE     => null                                       ,
        P_CURRENCY_CONVERSION_TYPE     => null                                       ,
        P_CURRENCY_CONVERSION_RATE     => null                                       ,
        P_TAX_CURR_CONVERSION_DATE     => null                                       ,
        P_TAX_CURR_CONVERSION_TYPE     => null                                       ,
        P_TAX_CURR_CONVERSION_RATE     => null                                       ,
        P_TRX_CURRENCY_CODE            => null                                       ,
        P_REPORTING_CURRENCY_CODE      => null                                       ,
        P_MINIMUM_ACCOUNTABLE_UNIT     => null                                       ,
        P_PRECISION                    => null                                       ,
        P_TRX_NUMBER                   => g_suite_rec_tbl.trx_number(i)              ,
        P_TRX_DATE                     => null                                       ,
        P_UNIT_PRICE                   => null                                       ,
        P_LINE_AMT                     => null                                       ,
        P_TRX_LINE_QUANTITY            => null                                       ,
        P_TAX_BASE_MODIFIER_RATE       => null                                       ,
        P_REF_DOC_APPLICATION_ID       => null                                       ,
        P_REF_DOC_ENTITY_CODE          => null                                       ,
        P_REF_DOC_EVENT_CLASS_CODE     => null                                       ,
        P_REF_DOC_TRX_ID               => null                                       ,
        P_REF_DOC_TRX_LEVEL_TYPE       => null                                       ,
        P_REF_DOC_LINE_ID              => null                                       ,
        P_REF_DOC_LINE_QUANTITY        => null                                       ,
        P_OTHER_DOC_LINE_AMT           => null                                       ,
        P_OTHER_DOC_LINE_TAX_AMT       => null                                       ,
        P_OTHER_DOC_LINE_TAXABLE_AMT   => null                                       ,
        P_UNROUNDED_TAXABLE_AMT        => null                                       ,
        P_UNROUNDED_TAX_AMT            => null                                       ,
        P_RELATED_DOC_APPLICATION_ID   => null                                       ,
        P_RELATED_DOC_ENTITY_CODE      => null                                       ,
        P_RELATED_DOC_EVT_CLASS_CODE   => null                                       ,
        P_RELATED_DOC_TRX_ID           => null                                       ,
        P_RELATED_DOC_TRX_LEVEL_TYPE   => null                                       ,
        P_RELATED_DOC_NUMBER           => null                                       ,
        P_RELATED_DOC_DATE             => null                                       ,
        P_APPLIED_FROM_APPL_ID         => null                                       ,
        P_APPLIED_FROM_EVT_CLSS_CODE   => null                                       ,
        P_APPLIED_FROM_ENTITY_CODE     => null                                       ,
        P_APPLIED_FROM_TRX_ID          => null                                       ,
        P_APPLIED_FROM_TRX_LEVEL_TYPE  => null                                       ,
        P_APPLIED_FROM_LINE_ID         => null                                       ,
        P_APPLIED_FROM_TRX_NUMBER      => null                                       ,
        P_ADJUSTED_DOC_APPLN_ID        => null                                       ,
        P_ADJUSTED_DOC_ENTITY_CODE     => g_suite_rec_tbl.adjusted_doc_entity_code(i),
        P_ADJUSTED_DOC_EVT_CLSS_CODE   => null                                       ,
        P_ADJUSTED_DOC_TRX_ID          => null                                       ,
        P_ADJUSTED_DOC_TRX_LEVEL_TYPE  => null                                       ,
        P_ADJUSTED_DOC_LINE_ID         => null                                       ,
        P_ADJUSTED_DOC_NUMBER          => null                                       ,
        P_ADJUSTED_DOC_DATE            => null                                       ,
        P_APPLIED_TO_APPLICATION_ID    => null                                       ,
        P_APPLIED_TO_EVT_CLASS_CODE    => null                                       ,
        P_APPLIED_TO_ENTITY_CODE       => null                                       ,
        P_APPLIED_TO_TRX_ID            => null                                       ,
        P_APPLIED_TO_TRX_LEVEL_TYPE    => null                                       ,
        P_APPLIED_TO_LINE_ID           => null                                       ,
        P_SUMMARY_TAX_LINE_ID          => g_suite_rec_tbl.summary_tax_line_id(i)     ,
        P_OFFSET_LINK_TO_TAX_LINE_ID   => null                                       ,
        P_OFFSET_FLAG                  => null                                       ,
        P_PROCESS_FOR_RECOVERY_FLAG    => null                                       ,
        P_TAX_JURISDICTION_ID          => g_suite_rec_tbl.tax_jurisdiction_id(i)     ,
        P_TAX_JURISDICTION_CODE        => null                                       ,
        P_PLACE_OF_SUPPLY              => null                                       ,
        P_PLACE_OF_SUPPLY_TYPE_CODE    => null                                       ,
        P_PLACE_OF_SUPPLY_RESULT_ID    => null                                       ,
        P_TAX_DATE_RULE_ID             => null                                       ,
        P_TAX_DATE                     => null                                       ,
        P_TAX_DETERMINE_DATE           => null                                       ,
        P_TAX_POINT_DATE               => null                                       ,
        P_TRX_LINE_DATE                => null                                       ,
        P_TAX_TYPE_CODE                => null                                       ,
        P_TAX_CODE                     => null                                       ,
        P_TAX_REGISTRATION_ID          => null                                       ,
        P_TAX_REGISTRATION_NUMBER      => g_suite_rec_tbl.tax_registration_number(i) ,
        P_REGISTRATION_PARTY_TYPE      => null                                       ,
        P_ROUNDING_LEVEL_CODE          => null                                       ,
        P_ROUNDING_RULE_CODE           => null                                       ,
        P_RNDG_LVL_PARTY_TAX_PROF_ID   => null                                       ,
        P_ROUNDING_LVL_PARTY_TYPE      => null                                       ,
        P_COMPOUNDING_TAX_FLAG         => null                                       ,
        P_ORIG_TAX_STATUS_ID           => null                                       ,
        P_ORIG_TAX_STATUS_CODE         => null                                       ,
        P_ORIG_TAX_RATE_ID             => null                                       ,
        P_ORIG_TAX_RATE_CODE           => null                                       ,
        P_ORIG_TAX_RATE                => null                                       ,
        P_ORIG_TAX_JURISDICTION_ID     => null                                       ,
        P_ORIG_TAX_JURISDICTION_CODE   => null                                       ,
        P_ORIG_TAX_AMT_INCLUDED_FLAG   => null                                       ,
        P_ORIG_SELF_ASSESSED_FLAG      => null                                       ,
        P_TAX_CURRENCY_CODE            => null                                       ,
        P_TAX_AMT                      => g_suite_rec_tbl.tax_amt(i)                 ,
        P_TAX_AMT_TAX_CURR             => null                                       ,
        P_TAX_AMT_FUNCL_CURR           => null                                       ,
        P_TAXABLE_AMT                  => g_suite_rec_tbl.taxable_amt(i)             ,
        P_TAXABLE_AMT_TAX_CURR         => null                                       ,
        P_TAXABLE_AMT_FUNCL_CURR       => null                                       ,
        P_ORIG_TAXABLE_AMT             => null                                       ,
        P_ORIG_TAXABLE_AMT_TAX_CURR    => null                                       ,
        P_CAL_TAX_AMT                  => null                                       ,
        P_CAL_TAX_AMT_TAX_CURR         => null                                       ,
        P_CAL_TAX_AMT_FUNCL_CURR       => null                                       ,
        P_ORIG_TAX_AMT                 => null                                       ,
        P_ORIG_TAX_AMT_TAX_CURR        => null                                       ,
        P_REC_TAX_AMT                  => g_suite_rec_tbl.rec_tax_amt(i)             ,
        P_REC_TAX_AMT_TAX_CURR         => null                                       ,
        P_REC_TAX_AMT_FUNCL_CURR       => null                                       ,
        P_NREC_TAX_AMT                 => g_suite_rec_tbl.nrec_tax_amt(i)            ,
        P_NREC_TAX_AMT_TAX_CURR        => null                                       ,
        P_NREC_TAX_AMT_FUNCL_CURR      => null                                       ,
        P_TAX_EXEMPTION_ID             => null                                       ,
        P_TAX_RATE_BEFORE_EXEMPTION    => null                                       ,
        P_TAX_RATE_NAME_BEFORE_EXEMPT  => null                                       ,
        P_EXEMPT_RATE_MODIFIER         => null                                       ,
        P_EXEMPT_CERTIFICATE_NUMBER    => g_suite_rec_tbl.exempt_certificate_number(i),
        P_EXEMPT_REASON                => null                                       ,
        P_EXEMPT_REASON_CODE           => g_suite_rec_tbl.exempt_reason_code(i)      ,
        P_TAX_EXCEPTION_ID             => null                                       ,
        P_TAX_RATE_BEFORE_EXCEPTION    => null                                       ,
        P_TAX_RATE_NAME_BEFORE_EXCEPT  => null                                       ,
        P_EXCEPTION_RATE               => null                                       ,
        P_TAX_APPORTIONMENT_FLAG       => null                                       ,
        P_HISTORICAL_FLAG              => null                                       ,
        P_TAXABLE_BASIS_FORMULA        => null                                       ,
        P_TAX_CALCULATION_FORMULA      => null                                       ,
        P_CANCEL_FLAG                  => g_suite_rec_tbl.cancel_flag(i)             ,
        P_PURGE_FLAG                   => null                                       ,
        P_DELETE_FLAG                  => null                                       ,
        P_TAX_AMT_INCLUDED_FLAG        => g_suite_rec_tbl.tax_amt_included_flag(i)   ,
        P_SELF_ASSESSED_FLAG           => g_suite_rec_tbl.self_assessed_flag(i)      ,
        P_OVERRIDDEN_FLAG              => null                                       ,
        P_MANUALLY_ENTERED_FLAG        => g_suite_rec_tbl.manually_entered_flag(i)   ,
        P_REPORTING_ONLY_FLAG          => null                                       ,
        P_FREEZE_UNTIL_OVERRIDDN_FLG   => null                                       ,
        P_COPIED_FROM_OTHER_DOC_FLAG   => null                                       ,
        P_RECALC_REQUIRED_FLAG         => null                                       ,
        P_SETTLEMENT_FLAG              => null                                       ,
        P_ITEM_DIST_CHANGED_FLAG       => null                                       ,
        P_ASSOC_CHILDREN_FROZEN_FLG    => null                                       ,
        P_TAX_ONLY_LINE_FLAG           => null                                       ,
        P_COMPOUNDING_DEP_TAX_FLAG     => null                                       ,
        P_COMPOUNDING_TAX_MISS_FLAG    => null                                       ,
        P_SYNC_WITH_PRVDR_FLAG         => null                                       ,
        P_LAST_MANUAL_ENTRY            => null                                       ,
        P_TAX_PROVIDER_ID              => null                                       ,
        P_RECORD_TYPE_CODE             => null                                       ,
        P_REPORTING_PERIOD_ID          => null                                       ,
        P_LEGAL_JUSTIFICATION_TEXT1    => null                                       ,
        P_LEGAL_JUSTIFICATION_TEXT2    => null                                       ,
        P_LEGAL_JUSTIFICATION_TEXT3    => null                                       ,
        P_LEGAL_MESSAGE_APPL_2         => null                                       ,
        P_LEGAL_MESSAGE_STATUS         => null                                       ,
        P_LEGAL_MESSAGE_RATE           => null                                       ,
        P_LEGAL_MESSAGE_BASIS          => null                                       ,
        P_LEGAL_MESSAGE_CALC           => null                                       ,
        P_LEGAL_MESSAGE_THRESHOLD      => null                                       ,
        P_LEGAL_MESSAGE_POS            => null                                       ,
        P_LEGAL_MESSAGE_TRN            => null                                       ,
        P_LEGAL_MESSAGE_EXMPT          => null                                       ,
        P_LEGAL_MESSAGE_EXCPT          => null                                       ,
        P_TAX_REGIME_TEMPLATE_ID       => null                                       ,
        P_TAX_APPLICABILITY_RESULT_ID  => null                                       ,
        P_DIRECT_RATE_RESULT_ID        => null                                       ,
        P_STATUS_RESULT_ID             => null                                       ,
        P_RATE_RESULT_ID               => null                                       ,
        P_BASIS_RESULT_ID              => null                                       ,
        P_THRESH_RESULT_ID             => null                                       ,
        P_CALC_RESULT_ID               => null                                       ,
        P_TAX_REG_NUM_DET_RESULT_ID    => null                                       ,
        P_EVAL_EXMPT_RESULT_ID         => null                                       ,
        P_EVAL_EXCPT_RESULT_ID         => null                                       ,
        P_ENFORCED_FROM_NAT_ACCT_FLG   => null                                       ,
        P_TAX_HOLD_CODE                => null                                       ,
        P_TAX_HOLD_RELEASED_CODE       => null                                       ,
        P_PRD_TOTAL_TAX_AMT            => null                                       ,
        P_PRD_TOTAL_TAX_AMT_TAX_CURR   => null                                       ,
        P_PRD_TOTAL_TAX_AMT_FUNCL_CURR => null                                       ,
        P_TRX_LINE_INDEX               => null                                       ,
        P_OFFSET_TAX_RATE_CODE         => null                                       ,
        P_PRORATION_CODE               => null                                       ,
        P_OTHER_DOC_SOURCE             => null                                       ,
        P_INTERNAL_ORG_LOCATION_ID     => null                                       ,
        P_LINE_ASSESSABLE_VALUE        => null                                       ,
        P_CTRL_TOTAL_LINE_TX_AMT       => g_suite_rec_tbl.ctrl_total_line_tx_amt(i)  ,
        P_APPLIED_TO_TRX_NUMBER        => null                                       , --added bug 4053445
        P_ATTRIBUTE_CATEGORY           => null                                       ,
        P_ATTRIBUTE1                   => null                                       ,
        P_ATTRIBUTE2                   => null                                       ,
        P_ATTRIBUTE3                   => null                                       ,
        P_ATTRIBUTE4                   => null                                       ,
        P_ATTRIBUTE5                   => null                                       ,
        P_ATTRIBUTE6                   => null                                       ,
        P_ATTRIBUTE7                   => null                                       ,
        P_ATTRIBUTE8                   => null                                       ,
        P_ATTRIBUTE9                   => null                                       ,
        P_ATTRIBUTE10                  => null                                       ,
        P_ATTRIBUTE11                  => null                                       ,
        P_ATTRIBUTE12                  => null                                       ,
        P_ATTRIBUTE13                  => null                                       ,
        P_ATTRIBUTE14                  => null                                       ,
        P_ATTRIBUTE15                  => null                                       ,
        P_GLOBAL_ATTRIBUTE_CATEGORY    => null                                       ,
        P_GLOBAL_ATTRIBUTE1            => null                                       ,
        P_GLOBAL_ATTRIBUTE2            => null                                       ,
        P_GLOBAL_ATTRIBUTE3            => null                                       ,
        P_GLOBAL_ATTRIBUTE4            => null                                       ,
        P_GLOBAL_ATTRIBUTE5            => null                                       ,
        P_GLOBAL_ATTRIBUTE6            => null                                       ,
        P_GLOBAL_ATTRIBUTE7            => null                                       ,
        P_GLOBAL_ATTRIBUTE8            => null                                       ,
        P_GLOBAL_ATTRIBUTE9            => null                                       ,
        P_GLOBAL_ATTRIBUTE10           => null                                       ,
        P_GLOBAL_ATTRIBUTE11           => null                                       ,
        P_GLOBAL_ATTRIBUTE12           => null                                       ,
        P_GLOBAL_ATTRIBUTE13           => null                                       ,
        P_GLOBAL_ATTRIBUTE14           => null                                       ,
        P_GLOBAL_ATTRIBUTE15           => null                                       ,
        P_NUMERIC1                     => null                                       ,
        P_NUMERIC2                     => null                                       ,
        P_NUMERIC3                     => null                                       ,
        P_NUMERIC4                     => null                                       ,
        P_NUMERIC5                     => null                                       ,
        P_NUMERIC6                     => null                                       ,
        P_NUMERIC7                     => null                                       ,
        P_NUMERIC8                     => null                                       ,
        P_NUMERIC9                     => null                                       ,
        P_NUMERIC10                    => null                                       ,
        P_CHAR1                        => null                                       ,
        P_CHAR2                        => null                                       ,
        P_CHAR3                        => null                                       ,
        P_CHAR4                        => null                                       ,
        P_CHAR5                        => null                                       ,
        P_CHAR6                        => null                                       ,
        P_CHAR7                        => null                                       ,
        P_CHAR8                        => null                                       ,
        P_CHAR9                        => null                                       ,
        P_CHAR10                       => null                                       ,
        P_DATE1                        => null                                       ,
        P_DATE2                        => null                                       ,
        P_DATE3                        => null                                       ,
        P_DATE4                        => null                                       ,
        P_DATE5                        => null                                       ,
        P_DATE6                        => null                                       ,
        P_DATE7                        => null                                       ,
        P_DATE8                        => null                                       ,
        P_DATE9                        => null                                       ,
        P_DATE10                       => null                                       ,
        P_INTERFACE_ENTITY_CODE        => null                                       ,
        P_INTERFACE_TAX_LINE_ID        => null                                       ,
        P_TAXING_JURIS_GEOGRAPHY_ID    => null                                       ,
        P_ADJUSTED_DOC_TAX_LINE_ID     => null                                       ,
        P_OBJECT_VERSION_NUMBER        => l_object_version_number                    ,
        P_CREATED_BY                   => 1      , ---------------------------------
        P_CREATION_DATE                => sysdate, -- What are the correct values
        P_LAST_UPDATED_BY              => 1      , -- to pass for the Who Columns?
        P_LAST_UPDATE_DATE             => sysdate, -- Review this later.
        P_LAST_UPDATE_LOGIN            => 1 );      ---------------------------------

      END LOOP;
      write_message('Service ZX_TRL_DETAIL_OVERRIDE_PKG.Delete_Row has been called!.');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );


    -------------------------------------------------------------
    -- Call the APIs for the case has been just finished reading.
    -------------------------------------------------------------
    ELSIF p_api_service = 'OVERRIDE_SUMMARY_ENTER_MANUAL_TAX_LINE' THEN
      ----------------------------------------------
      -- Get inital and ending row for the structure
      ----------------------------------------------
      get_start_end_rows_structure
       (
         p_suite      => p_suite_number,
         p_case       => p_case_number,
         p_structure  => 'STRUCTURE_OVERRIDE_SUMMARY_TAX_LINES',
         x_start_row  => l_start_row,
         x_end_row    => l_end_row
       );

      /* Not found in ZX_TRL_SUMMARY_OVERRIDE_PKG.insert_row following
      columns
         P_TRX_LEVEL_TYPE           => g_suite_rec_tbl.TRX_LEVEL_TYPE(i)       ,
         P_SUMMARY_TAX_LINE_NUMBER  => g_suite_rec_tbl.SUMMARY_TAX_LINE_NUMBER(i),
         P_TAX_JURISDICTION_ID      => g_suite_rec_tbl.TAX_JURISDICTION_ID(i)  , --THERE IS ONLY CODE */

      FOR i IN l_start_row..l_end_row LOOP
      ZX_TRL_SUMMARY_OVERRIDE_PKG.insert_row(
        X_ROWID                        => l_row_id                                ,
        P_SUMMARY_TAX_LINE_ID          => g_suite_rec_tbl.SUMMARY_TAX_LINE_ID(i)  ,
        P_INTERNAL_ORGANIZATION_ID     => g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(i),
        P_APPLICATION_ID               => g_suite_rec_tbl.APPLICATION_ID(i)       ,
        P_ENTITY_CODE                  => g_suite_rec_tbl.ENTITY_CODE(i)          ,
        P_EVENT_CLASS_CODE             => g_suite_rec_tbl.EVENT_CLASS_CODE(i)     ,
        P_TRX_ID                       => g_suite_rec_tbl.TRX_ID(i)               ,
        P_SUMMARY_TAX_LINE_NUMBER      => null                                    ,
        P_TRX_NUMBER                   => g_suite_rec_tbl.TRX_NUMBER(i)           ,
        P_APPLIED_FROM_APPLICATION_ID  => null                                    ,
        P_APPLIED_FROM_EVT_CLASS_CODE  => null                                    ,
        P_APPLIED_FROM_ENTITY_CODE     => null                                    ,
        P_APPLIED_FROM_TRX_ID          => null                                    ,
        P_APPLIED_FROM_TRX_LEVEL_TYPE  => null                                    ,
        P_APPLIED_FROM_LINE_ID         => null                                    ,
        P_ADJUSTED_DOC_APPLICATION_ID  => null                                    ,
        P_ADJUSTED_DOC_ENTITY_CODE     => g_suite_rec_tbl.adjusted_doc_entity_code(i),
        P_ADJUSTED_DOC_EVT_CLASS_CODE  => null                                    ,
        P_ADJUSTED_DOC_TRX_ID          => null                                    ,
        P_ADJUSTED_DOC_TRX_LEVEL_TYPE  => null                                    ,
        P_APPLIED_TO_APPLICATION_ID    => null                                    ,
        P_APPLIED_TO_EVENT_CLASS_CODE  => null                                    ,
        P_APPLIED_TO_ENTITY_CODE       => null                                    ,
        P_APPLIED_TO_TRX_ID            => null                                    ,
        P_APPLIED_TO_TRX_LEVEL_TYPE    => null                                    ,
        P_APPLIED_TO_LINE_ID           => null                                    ,
        P_TAX_EXEMPTION_ID             => null                                    ,
        P_TAX_RATE_BEFORE_EXEMPTION    => null                                    ,
        P_TAX_RATE_NAME_BEFORE_EXEMPT  => null                                    ,
        P_EXEMPT_RATE_MODIFIER         => null                                    ,
        P_EXEMPT_CERTIFICATE_NUMBER    => null                                    ,
        P_EXEMPT_REASON                => null                                    ,
        P_EXEMPT_REASON_CODE           => null                                    ,
        P_TAX_RATE_BEFORE_EXCEPTION    => null                                    ,
        P_TAX_RATE_NAME_BEFORE_EXCEPT  => null                                    ,
        P_TAX_EXCEPTION_ID             => null                                    ,
        P_EXCEPTION_RATE               => null                                    ,
        P_CONTENT_OWNER_ID             => null                                    ,
        P_TAX_REGIME_CODE              => g_suite_rec_tbl.TAX_REGIME_CODE(i)      ,
        P_TAX                          => g_suite_rec_tbl.TAX(i)                  ,
        P_TAX_STATUS_CODE              => g_suite_rec_tbl.TAX_STATUS_CODE(i)      ,
        P_TAX_RATE_ID                  => g_suite_rec_tbl.TAX_RATE_ID(i)          ,
        P_TAX_RATE_CODE                => g_suite_rec_tbl.TAX_RATE_CODE(i)        ,
        P_TAX_RATE                     => g_suite_rec_tbl.TAX_RATE(i)             ,
        P_TAX_AMT                      => g_suite_rec_tbl.TAX_AMT(i)              ,
        P_TAX_AMT_TAX_CURR             => null                                    ,
        P_TAX_AMT_FUNCL_CURR           => null                                    ,
        P_TAX_JURISDICTION_CODE        => null                                    ,
        P_TOTAL_REC_TAX_AMT            => g_suite_rec_tbl.TOTAL_REC_TAX_AMT(i)    ,
        P_TOTAL_REC_TAX_AMT_FUNC_CURR  => null                                    ,
        P_TOTAL_REC_TAX_AMT_TAX_CURR   => null                                    ,
        P_TOTAL_NREC_TAX_AMT           => g_suite_rec_tbl.TOTAL_NREC_TAX_AMT(i)   ,
        P_TOTAL_NREC_TAX_AMT_FUNC_CURR => null                                    ,
        P_TOTAL_NREC_TAX_AMT_TAX_CURR  => null                                    ,
        P_LEDGER_ID                    => g_suite_rec_tbl.LEDGER_ID(i)            ,
        P_LEGAL_ENTITY_ID              => null                                    ,
        P_ESTABLISHMENT_ID             => null                                    ,
        P_CURRENCY_CONVERSION_DATE     => null                                    ,
        P_CURRENCY_CONVERSION_TYPE     => null                                    ,
        P_CURRENCY_CONVERSION_RATE     => null                                    ,
        P_SUMMARIZATION_TEMPLATE_ID    => null                                    ,
        P_TAXABLE_BASIS_FORMULA        => null                                    ,
        P_TAX_CALCULATION_FORMULA      => null                                    ,
        P_HISTORICAL_FLAG              => null                                    ,
        P_CANCEL_FLAG                  => g_suite_rec_tbl.CANCEL_FLAG(i)          ,
        P_DELETE_FLAG                  => null                                    ,
        P_TAX_AMT_INCLUDED_FLAG        => g_suite_rec_tbl.TAX_AMT_INCLUDED_FLAG(i),
        P_COMPOUNDING_TAX_FLAG         => null                                    ,
        P_SELF_ASSESSED_FLAG           => g_suite_rec_tbl.SELF_ASSESSED_FLAG(i)   ,
        P_OVERRIDDEN_FLAG              => null                                    ,
        P_REPORTING_ONLY_FLAG          => null                                    ,
        P_ASSOC_CHILD_FROZEN_FLAG      => null                                    ,
        P_COPIED_FROM_OTHER_DOC_FLAG   => null                                    ,
        P_MANUALLY_ENTERED_FLAG        => g_suite_rec_tbl.MANUALLY_ENTERED_FLAG(i),
        P_MRC_TAX_LINE_FLAG            => null                                    ,
        P_LAST_MANUAL_ENTRY            => null                                    ,
        P_RECORD_TYPE_CODE             => null                                    ,
        P_TAX_PROVIDER_ID              => null                                    ,
        P_TAX_ONLY_LINE_FLAG           => null                                    ,
        P_ADJUST_TAX_AMT_FLAG          => null                                    ,
        P_ATTRIBUTE_CATEGORY           => null                                    ,
        P_ATTRIBUTE1                   => null                                    ,
        P_ATTRIBUTE2                   => null                                    ,
        P_ATTRIBUTE3                   => null                                    ,
        P_ATTRIBUTE4                   => null                                    ,
        P_ATTRIBUTE5                   => null                                    ,
        P_ATTRIBUTE6                   => null                                    ,
        P_ATTRIBUTE7                   => null                                    ,
        P_ATTRIBUTE8                   => null                                    ,
        P_ATTRIBUTE9                   => null                                    ,
        P_ATTRIBUTE10                  => null                                    ,
        P_ATTRIBUTE11                  => null                                    ,
        P_ATTRIBUTE12                  => null                                    ,
        P_ATTRIBUTE13                  => null                                    ,
        P_ATTRIBUTE14                  => null                                    ,
        P_ATTRIBUTE15                  => null                                    ,
        P_GLOBAL_ATTRIBUTE_CATEGORY    => null                                    ,
        P_GLOBAL_ATTRIBUTE1            => null                                    ,
        P_GLOBAL_ATTRIBUTE2            => null                                    ,
        P_GLOBAL_ATTRIBUTE3            => null                                    ,
        P_GLOBAL_ATTRIBUTE4            => null                                    ,
        P_GLOBAL_ATTRIBUTE5            => null                                    ,
        P_GLOBAL_ATTRIBUTE6            => null                                    ,
        P_GLOBAL_ATTRIBUTE7            => null                                    ,
        P_GLOBAL_ATTRIBUTE8            => null                                    ,
        P_GLOBAL_ATTRIBUTE9            => null                                    ,
        P_GLOBAL_ATTRIBUTE10           => null                                    ,
        P_GLOBAL_ATTRIBUTE11           => null                                    ,
        P_GLOBAL_ATTRIBUTE12           => null                                    ,
        P_GLOBAL_ATTRIBUTE13           => null                                    ,
        P_GLOBAL_ATTRIBUTE14           => null                                    ,
        P_GLOBAL_ATTRIBUTE15           => null                                    ,
        P_GLOBAL_ATTRIBUTE16           => null                                    ,
        P_GLOBAL_ATTRIBUTE17           => null                                    ,
        P_GLOBAL_ATTRIBUTE18           => null                                    ,
        P_GLOBAL_ATTRIBUTE19           => null                                    ,
        P_GLOBAL_ATTRIBUTE20           => null                                    ,
        P_OBJECT_VERSION_NUMBER        => 1                                       ,
        P_CREATED_BY                   => 1      , ---------------------------------
        P_CREATION_DATE                => sysdate, -- What are the correct values
        P_LAST_UPDATED_BY              => 1      , -- to pass for the Who Columns?
        P_LAST_UPDATE_DATE             => sysdate, -- Review this later.
        P_LAST_UPDATE_LOGIN            => 1 );      ---------------------------------


      END LOOP;
      write_message('Service ZX_TRL_DETAIL_OVERRIDE_PKG.Delete_Row has been called!.');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );


      FOR i IN l_start_row..l_end_row LOOP
        write_message('Calling zx_trl_allocations_pkg.insert_row');

      zx_trl_allocations_pkg.insert_row(
        X_ROWID                        => l_row_id                                   ,
        P_SUMMARY_TAX_LINE_ID          => g_suite_rec_tbl.summary_tax_line_id(i)     ,
        P_INTERNAL_ORGANIZATION_ID     => g_suite_rec_tbl.internal_organization_id(i),
        P_APPLICATION_ID               => g_suite_rec_tbl.application_id(i)          ,
        P_ENTITY_CODE                  => g_suite_rec_tbl.entity_code(i)             ,
        P_EVENT_CLASS_CODE             => g_suite_rec_tbl.event_class_code(i)        ,
        P_EVENT_TYPE_CODE              => g_suite_rec_tbl.event_type_code(i)         ,
        P_TRX_LINE_NUMBER              => g_suite_rec_tbl.trx_line_number(i)         ,
        P_TRX_ID                       => g_suite_rec_tbl.trx_id(i)                  ,
        P_TRX_NUMBER                   => null                                       ,
        P_TRX_LINE_ID                  => g_suite_rec_tbl.trx_line_id(i)             ,
        P_TRX_LEVEL_TYPE               => g_suite_rec_tbl.trx_level_type(i)          ,
        P_LINE_AMT                     => null                                       ,
        P_TRX_LINE_DATE                => null                                       ,
        --P_TAX_REGIME_ID                => null                                     ,
        P_TAX_REGIME_CODE              => g_suite_rec_tbl.tax_regime_code(i)         ,
        --P_TAX_ID                       => null                                     ,
        P_TAX                          => g_suite_rec_tbl.tax(i)                     ,
        --P_TAX_JURISDICTION_ID          => g_suite_rec_tbl.tax_jurisdiction_id(i)   ,
        P_TAX_JURISDICTION_CODE        => null                                       ,
        --P_TAX_STATUS_ID                => null                                       ,
        P_TAX_STATUS_CODE              => g_suite_rec_tbl.tax_status_code(i)         ,
        P_TAX_RATE_ID                  => g_suite_rec_tbl.tax_rate_id(i)             ,
        P_TAX_RATE_CODE                => g_suite_rec_tbl.tax_rate_code(i)           ,
        P_TAX_RATE                     => g_suite_rec_tbl.tax_rate(i)                ,
        P_TAX_AMT                      => g_suite_rec_tbl.tax_amt(i)                 ,
        P_ENABLED_RECORD               => null                                       ,
        --P_HDR_TRX_USER_KEY1          => null                                       ,
        --P_HDR_TRX_USER_KEY2          => null                                       ,
        --P_HDR_TRX_USER_KEY3          => null                                       ,
        --P_HDR_TRX_USER_KEY4          => null                                       ,
        --P_HDR_TRX_USER_KEY5          => null                                       ,
        --P_HDR_TRX_USER_KEY6          => null                                       ,
        --P_LINE_TRX_USER_KEY1         => null                                       ,
        --P_LINE_TRX_USER_KEY2         => null                                       ,
        --P_LINE_TRX_USER_KEY3         => null                                       ,
        --P_LINE_TRX_USER_KEY4         => null                                       ,
        --P_LINE_TRX_USER_KEY5         => null                                       ,
        --P_LINE_TRX_USER_KEY6         => null                                       ,
        P_MANUALLY_ENTERED_FLAG        => null                                       ,
        P_CONTENT_OWNER_ID             => null                                       ,
        P_RECORD_TYPE_CODE             => null                                       ,
        P_LAST_MANUAL_ENTRY            => null                                       ,
        P_TRX_LINE_AMT                 => null                                       ,
        P_TAX_AMT_INCLUDED_FLAG        => null                                       ,
        P_SELF_ASSESSED_FLAG           => null                                       ,
        P_TAX_ONLY_LINE_FLAG           => null                                       ,
        P_CREATED_BY                   => 1       , ---------------------------------
        P_CREATION_DATE                => sysdate , -- What are the correct values
        P_LAST_UPDATED_BY              => 1       , -- to pass for the Who Columns?
        P_LAST_UPDATE_DATE             => sysdate , -- Review this later.
        P_LAST_UPDATE_LOGIN            => 1 );      ---------------------------------

      END LOOP;
      write_message('Service zx_trl_allocations_pkg.Insert_row has been called!.');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );

     -----------------------------------------------------------------------
     -- Note: ZX_TRL_ALLOCATIONS_PKG.UPDATE_ROW and
     --       ZX_TRL_ALLOCATIONS_PKG.LOCK_ROWS and
     --       ZX_TRL_ALLOCATIONS_PKG.DELETE_ROW have been removed in TRL pkg
     --       10-DEC-2004
     -----------------------------------------------------------------------

/*      FOR i in l_start_row..l_end_row LOOP
        zx_trl_allocations_pkg.lock_row
        (
          X_ROWID             => l_row_id,
          P_CREATED_BY        => 1       , ------------------------------
          P_CREATION_DATE     => sysdate , -- What are to correct values
          P_LAST_UPDATED_BY   => 1       , -- to pass to Who Columns?
          P_LAST_UPDATE_DATE  => sysdate , ------------------------------
          P_LAST_UPDATE_LOGIN => 1
        ); null;
      END LOOP;
      write_message('Service zx_trl_allocations_pkg.lock_row has been called!.');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );


      FOR i IN l_start_row..l_end_row LOOP
        zx_trl_allocations_pkg.Update_row
          (
          X_ROWID                    => l_row_id                                    ,
          P_SUMMARY_TAX_LINE_ID      => g_suite_rec_tbl.summary_tax_line_id(i)      ,
          P_INTERNAL_ORGANIZATION_ID => g_suite_rec_tbl.internal_organization_id(i) ,
          P_APPLICATION_ID           => g_suite_rec_tbl.application_id(i)           ,
          P_ENTITY_CODE              => g_suite_rec_tbl.entity_code(i)              ,
          P_EVENT_CLASS_CODE         => g_suite_rec_tbl.event_class_code(i)         ,
          P_EVENT_TYPE_CODE          => g_suite_rec_tbl.event_type_code(i)          ,
          P_TRX_LINE_ID              => g_suite_rec_tbl.trx_line_id(i)              ,
          P_TRX_LINE_NUMBER          => g_suite_rec_tbl.trx_line_number(i)          ,
          P_TAX_EVENT_CLASS_CODE     => null                                        ,
          P_TAX_EVENT_TYPE_CODE      => null                                        ,
          P_TRX_ID                   => g_suite_rec_tbl.trx_id(i)                   ,
          P_TAX_LINE_ID              => g_suite_rec_tbl.tax_line_id(i)              ,
          P_TAX_LINE_NUMBER          => null                                        ,
          P_TAX_AMT                  => g_suite_rec_tbl.tax_amt(i)                  ,
          P_ENABLED_RECORD           => null                                        ,
          P_CREATED_BY               => null                                        ,
          P_CREATION_DATE            => null                                        ,
          P_LAST_UPDATED_BY          => null                                        ,
          P_LAST_UPDATE_DATE         => null                                        ,
          P_LAST_UPDATE_LOGIN        => null
          ); null;


     END LOOP;
     write_message('Service zx_trl_allocations_pkg.Update_row has been called!.');
     write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
     write_message('x_return_status : '||l_return_status);
     write_message('x_msg_count     : '||l_msg_count    );
     write_message('x_msg_data      : '||l_msg_data     );

     FOR i in l_start_row..l_end_row LOOP
       zx_trl_allocations_pkg.Delete_row
        (
        X_ROWID                    => l_row_id                                   ,
        P_SUMMARY_TAX_LINE_ID      => g_suite_rec_tbl.summary_tax_line_id(i)     ,
        P_INTERNAL_ORGANIZATION_ID => g_suite_rec_tbl.internal_organization_id(i),
        P_APPLICATION_ID           => g_suite_rec_tbl.application_id(i)          ,
        P_ENTITY_CODE              => g_suite_rec_tbl.entity_code(i)             ,
        P_EVENT_CLASS_CODE         => g_suite_rec_tbl.event_class_code(i)        ,
        P_EVENT_TYPE_CODE          => g_suite_rec_tbl.event_type_code(i)         ,
        P_TRX_ID                   => g_suite_rec_tbl.trx_id(i)
        );

     END LOOP;
     write_message('Service zx_trl_allocations_pkg.Delete_row has been called!.');
     write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
     write_message('x_return_status : '||l_return_status);
     write_message('x_msg_count     : '||l_msg_count    );
     write_message('x_msg_data      : '||l_msg_data     );
*/

    ELSIF p_api_service = 'OVERRIDE_SUMMARY_UPDATE_TAX_LINE' THEN

      FOR i in g_suite_rec_tbl.application_id.FIRST..g_suite_rec_tbl.application_id.LAST LOOP

      select object_version_number
      into l_object_version_number
      from zx_lines_summary
      where application_id =g_suite_rec_tbl.application_id(i)
        and entity_code = g_suite_rec_tbl.entity_code(i)
        and event_class_code = g_suite_rec_tbl.event_class_code(i)
        and trx_id = g_suite_rec_tbl.trx_id(i)
        and summary_tax_line_id = g_suite_rec_tbl.summary_tax_line_id(i) ;

      ZX_TRL_SUMMARY_OVERRIDE_PKG.Lock_row(
        X_ROWID                        => l_row_id                                   ,
        P_SUMMARY_TAX_LINE_ID          => g_suite_rec_tbl.SUMMARY_TAX_LINE_ID(i)     ,
        P_INTERNAL_ORGANIZATION_ID     => g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(i),
        P_APPLICATION_ID               => g_suite_rec_tbl.APPLICATION_ID(i)          ,
        P_ENTITY_CODE                  => g_suite_rec_tbl.ENTITY_CODE(i)             ,
        P_EVENT_CLASS_CODE             => g_suite_rec_tbl.EVENT_CLASS_CODE(i)        ,
        P_TRX_ID                       => g_suite_rec_tbl.TRX_ID(i)                  ,
        P_SUMMARY_TAX_LINE_NUMBER      => g_suite_rec_tbl.SUMMARY_TAX_LINE_NUMBER(i) ,
        P_TRX_NUMBER                   => g_suite_rec_tbl.TRX_NUMBER(i)              ,
        P_APPLIED_FROM_APPLICATION_ID  => null                                       ,
        P_APPLIED_FROM_EVT_CLASS_CODE  => null                                       ,
        P_APPLIED_FROM_ENTITY_CODE     => null                                       ,
        P_APPLIED_FROM_TRX_ID          => null                                       ,
        P_APPLIED_FROM_TRX_LEVEL_TYPE  => null                                       ,
        P_APPLIED_FROM_LINE_ID         => null                                       ,
        P_ADJUSTED_DOC_APPLICATION_ID  => null                                       ,
        P_ADJUSTED_DOC_ENTITY_CODE     => g_suite_rec_tbl.adjusted_doc_entity_code(i),
        P_ADJUSTED_DOC_EVT_CLASS_CODE  => null                                       ,
        P_ADJUSTED_DOC_TRX_ID          => null                                       ,
        P_ADJUSTED_DOC_TRX_LEVEL_TYPE  => null                                       ,
        P_APPLIED_TO_APPLICATION_ID    => null                                       ,
        P_APPLIED_TO_EVENT_CLASS_CODE  => null                                       ,
        P_APPLIED_TO_ENTITY_CODE       => null                                       ,
        P_APPLIED_TO_TRX_ID            => null                                       ,
        P_APPLIED_TO_TRX_LEVEL_TYPE    => null                                       ,
        P_APPLIED_TO_LINE_ID           => null                                       ,
        P_TAX_EXEMPTION_ID             => null                                       ,
        P_TAX_RATE_BEFORE_EXEMPTION    => null                                       ,
        P_TAX_RATE_NAME_BEFORE_EXEMPT  => null                                       ,
        P_EXEMPT_RATE_MODIFIER         => null                                       ,
        P_EXEMPT_CERTIFICATE_NUMBER    => null                                       ,
        P_EXEMPT_REASON                => null                                       ,
        P_EXEMPT_REASON_CODE           => null                                       ,
        P_TAX_RATE_BEFORE_EXCEPTION    => null                                       ,
        P_TAX_RATE_NAME_BEFORE_EXCEPT  => null                                       ,
        P_TAX_EXCEPTION_ID             => null                                       ,
        P_EXCEPTION_RATE               => null                                       ,
        P_CONTENT_OWNER_ID             => null                                       ,
        P_TAX_REGIME_CODE              => g_suite_rec_tbl.TAX_REGIME_CODE(i)         ,
        P_TAX                          => g_suite_rec_tbl.TAX(i)                     ,
        P_TAX_STATUS_CODE              => g_suite_rec_tbl.TAX_STATUS_CODE(i)         ,
        P_TAX_RATE_ID                  => g_suite_rec_tbl.TAX_RATE_ID(i)             ,
        P_TAX_RATE_CODE                => g_suite_rec_tbl.TAX_RATE_CODE(i)           ,
        P_TAX_RATE                     => g_suite_rec_tbl.TAX_RATE(i)                ,
        P_TAX_AMT                      => g_suite_rec_tbl.TAX_AMT(i)                 ,
        P_TAX_AMT_TAX_CURR             => null                                       ,
        P_TAX_AMT_FUNCL_CURR           => null                                       ,
        P_TAX_JURISDICTION_CODE        => null                                       ,
        P_TOTAL_REC_TAX_AMT            => g_suite_rec_tbl.TOTAL_REC_TAX_AMT(i)       ,
        P_TOTAL_REC_TAX_AMT_FUNC_CURR  => null                                       ,
        P_TOTAL_REC_TAX_AMT_TAX_CURR   => null                                       ,
        P_TOTAL_NREC_TAX_AMT           => g_suite_rec_tbl.TOTAL_NREC_TAX_AMT(i)      ,
        P_TOTAL_NREC_TAX_AMT_FUNC_CURR => null                                       ,
        P_TOTAL_NREC_TAX_AMT_TAX_CURR  => null                                       ,
        P_LEDGER_ID                    => g_suite_rec_tbl.LEDGER_ID(i)               ,
        P_LEGAL_ENTITY_ID              => null                                       ,
        P_ESTABLISHMENT_ID             => null                                       ,
        P_CURRENCY_CONVERSION_DATE     => null                                       ,
        P_CURRENCY_CONVERSION_TYPE     => null                                       ,
        P_CURRENCY_CONVERSION_RATE     => null                                       ,
        P_SUMMARIZATION_TEMPLATE_ID    => null                                       ,
        P_TAXABLE_BASIS_FORMULA        => null                                       ,
        P_TAX_CALCULATION_FORMULA      => null                                       ,
        P_HISTORICAL_FLAG              => null                                       ,
        P_CANCEL_FLAG                  => g_suite_rec_tbl.CANCEL_FLAG(i)             ,
        P_DELETE_FLAG                  => null                                       ,
        P_TAX_AMT_INCLUDED_FLAG        => g_suite_rec_tbl.TAX_AMT_INCLUDED_FLAG(i)   ,
        P_COMPOUNDING_TAX_FLAG         => null                                       ,
        P_SELF_ASSESSED_FLAG           => g_suite_rec_tbl.SELF_ASSESSED_FLAG(i)      ,
        P_OVERRIDDEN_FLAG              => null                                       ,
        P_REPORTING_ONLY_FLAG          => null                                       ,
        P_ASSOC_CHILD_FROZEN_FLAG      => null                                       ,
        P_COPIED_FROM_OTHER_DOC_FLAG   => null                                       ,
        P_MANUALLY_ENTERED_FLAG        => g_suite_rec_tbl.MANUALLY_ENTERED_FLAG(i)   ,
        P_MRC_TAX_LINE_FLAG            => null                                       ,
        P_LAST_MANUAL_ENTRY            => null                                       ,
        P_RECORD_TYPE_CODE             => null                                       ,
        P_TAX_PROVIDER_ID              => null                                       ,
        P_TAX_ONLY_LINE_FLAG           => null                                       ,
        P_ADJUST_TAX_AMT_FLAG          => null                                       ,
        P_ATTRIBUTE_CATEGORY           => null                                       ,
        P_ATTRIBUTE1                   => null                                       ,
        P_ATTRIBUTE2                   => null                                       ,
        P_ATTRIBUTE3                   => null                                       ,
        P_ATTRIBUTE4                   => null                                       ,
        P_ATTRIBUTE5                   => null                                       ,
        P_ATTRIBUTE6                   => null                                       ,
        P_ATTRIBUTE7                   => null                                       ,
        P_ATTRIBUTE8                   => null                                       ,
        P_ATTRIBUTE9                   => null                                       ,
        P_ATTRIBUTE10                  => null                                       ,
        P_ATTRIBUTE11                  => null                                       ,
        P_ATTRIBUTE12                  => null                                       ,
        P_ATTRIBUTE13                  => null                                       ,
        P_ATTRIBUTE14                  => null                                       ,
        P_ATTRIBUTE15                  => null                                       ,
        P_GLOBAL_ATTRIBUTE_CATEGORY    => null                                       ,
        P_GLOBAL_ATTRIBUTE1            => null                                       ,
        P_GLOBAL_ATTRIBUTE2            => null                                       ,
        P_GLOBAL_ATTRIBUTE3            => null                                       ,
        P_GLOBAL_ATTRIBUTE4            => null                                       ,
        P_GLOBAL_ATTRIBUTE5            => null                                       ,
        P_GLOBAL_ATTRIBUTE6            => null                                       ,
        P_GLOBAL_ATTRIBUTE7            => null                                       ,
        P_GLOBAL_ATTRIBUTE8            => null                                       ,
        P_GLOBAL_ATTRIBUTE9            => null                                       ,
        P_GLOBAL_ATTRIBUTE10           => null                                       ,
        P_GLOBAL_ATTRIBUTE11           => null                                       ,
        P_GLOBAL_ATTRIBUTE12           => null                                       ,
        P_GLOBAL_ATTRIBUTE13           => null                                       ,
        P_GLOBAL_ATTRIBUTE14           => null                                       ,
        P_GLOBAL_ATTRIBUTE15           => null                                       ,
        P_GLOBAL_ATTRIBUTE16           => null                                       ,
        P_GLOBAL_ATTRIBUTE17           => null                                       ,
        P_GLOBAL_ATTRIBUTE18           => null                                       ,
        P_GLOBAL_ATTRIBUTE19           => null                                       ,
        P_GLOBAL_ATTRIBUTE20           => null                                       ,
        P_OBJECT_VERSION_NUMBER        => l_object_version_number                    ,
        P_CREATED_BY                   => 1       , ---------------------------------
        P_CREATION_DATE                => sysdate , -- What are the correct values
        P_LAST_UPDATED_BY              => 1       , -- to pass for the Who Columns?
        P_LAST_UPDATE_DATE             => sysdate , -- Review this later.
        P_LAST_UPDATE_LOGIN            => 1 );      ---------------------------------

        null;
   END LOOP;

      FOR i in g_suite_rec_tbl.application_id.FIRST..g_suite_rec_tbl.application_id.LAST LOOP

      select object_version_number
      into l_object_version_number
      from zx_lines_summary
      where application_id =g_suite_rec_tbl.application_id(i)
        and entity_code = g_suite_rec_tbl.entity_code(i)
        and event_class_code = g_suite_rec_tbl.event_class_code(i)
        and trx_id = g_suite_rec_tbl.trx_id(i)
        and summary_tax_line_id = g_suite_rec_tbl.summary_tax_line_id(i) ;

     ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_row(
        --X_ROWID                        => l_row_id                                   ,
        P_SUMMARY_TAX_LINE_ID          => g_suite_rec_tbl.SUMMARY_TAX_LINE_ID(i)     ,
        P_INTERNAL_ORGANIZATION_ID     => g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(i),
        P_APPLICATION_ID               => g_suite_rec_tbl.APPLICATION_ID(i)          ,
        P_ENTITY_CODE                  => g_suite_rec_tbl.ENTITY_CODE(i)             ,
        P_EVENT_CLASS_CODE             => g_suite_rec_tbl.EVENT_CLASS_CODE(i)        ,
        P_TRX_ID                       => g_suite_rec_tbl.TRX_ID(i)                  ,
        P_SUMMARY_TAX_LINE_NUMBER      => g_suite_rec_tbl.SUMMARY_TAX_LINE_NUMBER(i) ,
        P_TRX_NUMBER                   => g_suite_rec_tbl.TRX_NUMBER(i)              ,
        P_APPLIED_FROM_APPLICATION_ID  => null                                       ,
        P_APPLIED_FROM_EVT_CLASS_CODE  => null                                       ,
        P_APPLIED_FROM_ENTITY_CODE     => null                                       ,
        P_APPLIED_FROM_TRX_ID          => null                                       ,
        P_APPLIED_FROM_TRX_LEVEL_TYPE  => null                                       ,
        P_APPLIED_FROM_LINE_ID         => null                                       ,
        P_ADJUSTED_DOC_APPLICATION_ID  => null                                       ,
        P_ADJUSTED_DOC_ENTITY_CODE     => g_suite_rec_tbl.adjusted_doc_entity_code(i),
        P_ADJUSTED_DOC_EVT_CLASS_CODE  => null                                       ,
        P_ADJUSTED_DOC_TRX_ID          => null                                       ,
        P_ADJUSTED_DOC_TRX_LEVEL_TYPE  => null                                       ,
        P_APPLIED_TO_APPLICATION_ID    => null                                       ,
        P_APPLIED_TO_EVENT_CLASS_CODE  => null                                       ,
        P_APPLIED_TO_ENTITY_CODE       => null                                       ,
        P_APPLIED_TO_TRX_ID            => null                                       ,
        P_APPLIED_TO_TRX_LEVEL_TYPE    => null                                       ,
        P_APPLIED_TO_LINE_ID           => null                                       ,
        P_TAX_EXEMPTION_ID             => null                                       ,
        P_TAX_RATE_BEFORE_EXEMPTION    => null                                       ,
        P_TAX_RATE_NAME_BEFORE_EXEMPT  => null                                       ,
        P_EXEMPT_RATE_MODIFIER         => null                                       ,
        P_EXEMPT_CERTIFICATE_NUMBER    => null                                       ,
        P_EXEMPT_REASON                => null                                       ,
        P_EXEMPT_REASON_CODE           => null                                       ,
        P_TAX_RATE_BEFORE_EXCEPTION    => null                                       ,
        P_TAX_RATE_NAME_BEFORE_EXCEPT  => null                                       ,
        P_TAX_EXCEPTION_ID             => null                                       ,
        P_EXCEPTION_RATE               => null                                       ,
        P_CONTENT_OWNER_ID             => null                                       ,
        P_TAX_REGIME_CODE              => g_suite_rec_tbl.TAX_REGIME_CODE(i)         ,
        P_TAX                          => g_suite_rec_tbl.TAX(i)                     ,
        P_TAX_STATUS_ID                => null                     ,
        P_TAX_STATUS_CODE              => g_suite_rec_tbl.TAX_STATUS_CODE(i)         ,
        P_TAX_RATE_ID                  => g_suite_rec_tbl.TAX_RATE_ID(i)             ,
        P_TAX_RATE_CODE                => g_suite_rec_tbl.TAX_RATE_CODE(i)           ,
        P_TAX_RATE                     => g_suite_rec_tbl.TAX_RATE(i)                ,
        P_TAX_AMT                      => g_suite_rec_tbl.TAX_AMT(i)                 ,
        P_TAX_AMT_TAX_CURR             => null                                       ,
        P_TAX_AMT_FUNCL_CURR           => null                                       ,
        P_TAX_JURISDICTION_CODE        => null                                       ,
        P_TOTAL_REC_TAX_AMT            => g_suite_rec_tbl.TOTAL_REC_TAX_AMT(i)       ,
        P_TOTAL_REC_TAX_AMT_FUNC_CURR  => null                                       ,
        P_TOTAL_REC_TAX_AMT_TAX_CURR   => null                                       ,
        P_TOTAL_NREC_TAX_AMT           => g_suite_rec_tbl.TOTAL_NREC_TAX_AMT(i)      ,
        P_TOTAL_NREC_TAX_AMT_FUNC_CURR => null                                       ,
        P_TOTAL_NREC_TAX_AMT_TAX_CURR  => null                                       ,
        P_LEDGER_ID                    => g_suite_rec_tbl.LEDGER_ID(i)               ,
        P_LEGAL_ENTITY_ID              => null                                       ,
        P_ESTABLISHMENT_ID             => null                                       ,
        P_CURRENCY_CONVERSION_DATE     => null                                       ,
        P_CURRENCY_CONVERSION_TYPE     => null                                       ,
        P_CURRENCY_CONVERSION_RATE     => null                                       ,
        P_SUMMARIZATION_TEMPLATE_ID    => null                                       ,
        P_TAXABLE_BASIS_FORMULA        => null                                       ,
        P_TAX_CALCULATION_FORMULA      => null                                       ,
        P_HISTORICAL_FLAG              => null                                       ,
        P_CANCEL_FLAG                  => g_suite_rec_tbl.CANCEL_FLAG(i)             ,
        P_DELETE_FLAG                  => null                                       ,
        P_TAX_AMT_INCLUDED_FLAG        => g_suite_rec_tbl.TAX_AMT_INCLUDED_FLAG(i)   ,
        P_COMPOUNDING_TAX_FLAG         => null                                       ,
        P_SELF_ASSESSED_FLAG           => g_suite_rec_tbl.SELF_ASSESSED_FLAG(i)      ,
        P_OVERRIDDEN_FLAG              => null                                       ,
        P_REPORTING_ONLY_FLAG          => null                                       ,
        P_ASSOC_CHILD_FROZEN_FLAG      => null                                       ,
        P_COPIED_FROM_OTHER_DOC_FLAG   => null                                       ,
        P_MANUALLY_ENTERED_FLAG        => g_suite_rec_tbl.MANUALLY_ENTERED_FLAG(i)   ,
        P_MRC_TAX_LINE_FLAG            => null                                       ,
        P_LAST_MANUAL_ENTRY            => null                                       ,
        P_RECORD_TYPE_CODE             => null                                       ,
        P_TAX_PROVIDER_ID              => null                                       ,
        P_TAX_ONLY_LINE_FLAG           => null                                       ,
        P_ADJUST_TAX_AMT_FLAG          => null                                       ,
        --P_EVENT_ID                     => null                                       ,
        --P_CTRL_EF_OV_CAL_LINE_FLAG     => null                                       ,
        P_ATTRIBUTE_CATEGORY           => null                                       ,
        P_ATTRIBUTE1                   => null                                       ,
        P_ATTRIBUTE2                   => null                                       ,
        P_ATTRIBUTE3                   => null                                       ,
        P_ATTRIBUTE4                   => null                                       ,
        P_ATTRIBUTE5                   => null                                       ,
        P_ATTRIBUTE6                   => null                                       ,
        P_ATTRIBUTE7                   => null                                       ,
        P_ATTRIBUTE8                   => null                                       ,
        P_ATTRIBUTE9                   => null                                       ,
        P_ATTRIBUTE10                  => null                                       ,
        P_ATTRIBUTE11                  => null                                       ,
        P_ATTRIBUTE12                  => null                                       ,
        P_ATTRIBUTE13                  => null                                       ,
        P_ATTRIBUTE14                  => null                                       ,
        P_ATTRIBUTE15                  => null                                       ,
        P_GLOBAL_ATTRIBUTE_CATEGORY    => null                                       ,
        P_GLOBAL_ATTRIBUTE1            => null                                       ,
        P_GLOBAL_ATTRIBUTE2            => null                                       ,
        P_GLOBAL_ATTRIBUTE3            => null                                       ,
        P_GLOBAL_ATTRIBUTE4            => null                                       ,
        P_GLOBAL_ATTRIBUTE5            => null                                       ,
        P_GLOBAL_ATTRIBUTE6            => null                                       ,
        P_GLOBAL_ATTRIBUTE7            => null                                       ,
        P_GLOBAL_ATTRIBUTE8            => null                                       ,
        P_GLOBAL_ATTRIBUTE9            => null                                       ,
        P_GLOBAL_ATTRIBUTE10           => null                                       ,
        P_GLOBAL_ATTRIBUTE11           => null                                       ,
        P_GLOBAL_ATTRIBUTE12           => null                                       ,
        P_GLOBAL_ATTRIBUTE13           => null                                       ,
        P_GLOBAL_ATTRIBUTE14           => null                                       ,
        P_GLOBAL_ATTRIBUTE15           => null                                       ,
        P_GLOBAL_ATTRIBUTE16           => null                                       ,
        P_GLOBAL_ATTRIBUTE17           => null                                       ,
        P_GLOBAL_ATTRIBUTE18           => null                                       ,
        P_GLOBAL_ATTRIBUTE19           => null                                       ,
        P_GLOBAL_ATTRIBUTE20           => null                                       ,
        P_OBJECT_VERSION_NUMBER        => l_object_version_number+1                  ,
        --P_CREATED_BY                   => 1       , ---------------------------------
        --P_CREATION_DATE                => sysdate , -- What are the correct values
        P_LAST_UPDATED_BY              => 1       , -- to pass for the Who Columns?
        P_LAST_UPDATE_DATE             => sysdate , -- Review this later.
        P_LAST_UPDATE_LOGIN            => 1 );      ---------------------------------
 null;

    END LOOP;

     write_message('Service zx_trl_allocations_pkg.Delete_row has been called!.');
     write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
     write_message('x_return_status : '||l_return_status);
     write_message('x_msg_count     : '||l_msg_count    );
     write_message('x_msg_data      : '||l_msg_data     );

    ELSIF p_api_service = 'OVERRIDE_SUMMARY_DELETE_TAX_LINE' THEN

      ----------------------------------------------
      -- Get inital and ending row for the structure
      ----------------------------------------------
      get_start_end_rows_structure
       (
         p_suite      => p_suite_number,
         p_case       => p_case_number,
         p_structure  => 'STRUCTURE_OVERRIDE_SUMMARY_TAX_LINES',
         x_start_row  => l_start_row,
         x_end_row    => l_end_row
       );

      -----------------------------------------------------------
      -- Proceeds to Call the API Synchronize Tax Repository
      -----------------------------------------------------------
      write_message('Calculating for OVERRIDE_SUMMARY_DELETE_TAX_LINE');
      FOR i in l_start_row..l_end_row LOOP

      select object_version_number
      into l_object_version_number
      from zx_lines_summary
      where application_id =g_suite_rec_tbl.application_id(i)
        and entity_code = g_suite_rec_tbl.entity_code(i)
        and event_class_code = g_suite_rec_tbl.event_class_code(i)
        and trx_id = g_suite_rec_tbl.trx_id(i)
        and summary_tax_line_id = g_suite_rec_tbl.summary_tax_line_id(i) ;

      ZX_TRL_SUMMARY_OVERRIDE_PKG.Delete_row(
          X_ROWID                        => l_row_id                                   ,
          P_SUMMARY_TAX_LINE_ID          => g_suite_rec_tbl.SUMMARY_TAX_LINE_ID(i)     ,
          P_INTERNAL_ORGANIZATION_ID     => g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(i),
          P_APPLICATION_ID               => g_suite_rec_tbl.APPLICATION_ID(i)          ,
          P_ENTITY_CODE                  => g_suite_rec_tbl.ENTITY_CODE(i)             ,
          P_EVENT_CLASS_CODE             => g_suite_rec_tbl.EVENT_CLASS_CODE(i)        ,
          P_TRX_ID                       => g_suite_rec_tbl.TRX_ID(i)                  ,
          P_SUMMARY_TAX_LINE_NUMBER      => g_suite_rec_tbl.SUMMARY_TAX_LINE_NUMBER(i) ,
          P_TRX_NUMBER                   => g_suite_rec_tbl.TRX_NUMBER(i)              ,
          P_APPLIED_FROM_APPLICATION_ID  => null                                       ,
          P_APPLIED_FROM_EVT_CLASS_CODE  => null                                       ,
          P_APPLIED_FROM_ENTITY_CODE     => null                                       ,
          P_APPLIED_FROM_TRX_ID          => null                                       ,
          P_APPLIED_FROM_TRX_LEVEL_TYPE  => null                                       ,
          P_APPLIED_FROM_LINE_ID         => null                                       ,
          P_ADJUSTED_DOC_APPLICATION_ID  => null                                       ,
          P_ADJUSTED_DOC_ENTITY_CODE     => g_suite_rec_tbl.adjusted_doc_entity_code(i),
          P_ADJUSTED_DOC_EVT_CLASS_CODE  => null                                       ,
          P_ADJUSTED_DOC_TRX_ID          => null                                       ,
          P_ADJUSTED_DOC_TRX_LEVEL_TYPE  => null                                       ,
          P_APPLIED_TO_APPLICATION_ID    => null                                       ,
          P_APPLIED_TO_EVENT_CLASS_CODE  => null                                       ,
          P_APPLIED_TO_ENTITY_CODE       => null                                       ,
          P_APPLIED_TO_TRX_ID            => null                                       ,
          P_APPLIED_TO_TRX_LEVEL_TYPE    => null                                       ,
          P_APPLIED_TO_LINE_ID           => null                                       ,
          P_TAX_EXEMPTION_ID             => null                                       ,
          P_TAX_RATE_BEFORE_EXEMPTION    => null                                       ,
          P_TAX_RATE_NAME_BEFORE_EXEMPT  => null                                       ,
          P_EXEMPT_RATE_MODIFIER         => null                                       ,
          P_EXEMPT_CERTIFICATE_NUMBER    => null                                       ,
          P_EXEMPT_REASON                => null                                       ,
          P_EXEMPT_REASON_CODE           => null                                       ,
          P_TAX_RATE_BEFORE_EXCEPTION    => null                                       ,
          P_TAX_RATE_NAME_BEFORE_EXCEPT  => null                                       ,
          P_TAX_EXCEPTION_ID             => null                                       ,
          P_EXCEPTION_RATE               => null                                       ,
          P_CONTENT_OWNER_ID             => null                                       ,
          P_TAX_REGIME_CODE              => g_suite_rec_tbl.TAX_REGIME_CODE(i)         ,
          P_TAX                          => g_suite_rec_tbl.TAX(i)                     ,
          P_TAX_STATUS_CODE              => g_suite_rec_tbl.TAX_STATUS_CODE(i)         ,
          P_TAX_RATE_ID                  => g_suite_rec_tbl.TAX_RATE_ID(i)             ,
          P_TAX_RATE_CODE                => g_suite_rec_tbl.TAX_RATE_CODE(i)           ,
          P_TAX_RATE                     => g_suite_rec_tbl.TAX_RATE(i)                ,
          P_TAX_AMT                      => g_suite_rec_tbl.TAX_AMT(i)                 ,
          P_TAX_AMT_TAX_CURR             => null                                       ,
          P_TAX_AMT_FUNCL_CURR           => null                                       ,
          P_TAX_JURISDICTION_CODE        => null                                       ,
          P_TOTAL_REC_TAX_AMT            => g_suite_rec_tbl.TOTAL_REC_TAX_AMT(i)       ,
          P_TOTAL_REC_TAX_AMT_FUNC_CURR  => null                                       ,
          P_TOTAL_REC_TAX_AMT_TAX_CURR   => null                                       ,
          P_TOTAL_NREC_TAX_AMT           => g_suite_rec_tbl.TOTAL_NREC_TAX_AMT(i)      ,
          P_TOTAL_NREC_TAX_AMT_FUNC_CURR => null                                       ,
          P_TOTAL_NREC_TAX_AMT_TAX_CURR  => null                                       ,
          P_LEDGER_ID                    => g_suite_rec_tbl.LEDGER_ID(i)               ,
          P_LEGAL_ENTITY_ID              => null                                       ,
          P_ESTABLISHMENT_ID             => null                                       ,
          P_CURRENCY_CONVERSION_DATE     => null                                       ,
          P_CURRENCY_CONVERSION_TYPE     => null                                       ,
          P_CURRENCY_CONVERSION_RATE     => null                                       ,
          P_SUMMARIZATION_TEMPLATE_ID    => null                                       ,
          P_TAXABLE_BASIS_FORMULA        => null                                       ,
          P_TAX_CALCULATION_FORMULA      => null                                       ,
          P_HISTORICAL_FLAG              => null                                       ,
          P_CANCEL_FLAG                  => g_suite_rec_tbl.CANCEL_FLAG(i)             ,
          P_DELETE_FLAG                  => null                                       ,
          P_TAX_AMT_INCLUDED_FLAG        => g_suite_rec_tbl.TAX_AMT_INCLUDED_FLAG(i)   ,
          P_COMPOUNDING_TAX_FLAG         => null                                       ,
          P_SELF_ASSESSED_FLAG           => g_suite_rec_tbl.SELF_ASSESSED_FLAG(i)      ,
          P_OVERRIDDEN_FLAG              => null                                       ,
          P_REPORTING_ONLY_FLAG          => null                                       ,
          P_ASSOC_CHILD_FROZEN_FLAG      => null                                       ,
          P_COPIED_FROM_OTHER_DOC_FLAG   => null                                       ,
          P_MANUALLY_ENTERED_FLAG        => g_suite_rec_tbl.MANUALLY_ENTERED_FLAG(i)   ,
          P_MRC_TAX_LINE_FLAG            => null                                       ,
          P_LAST_MANUAL_ENTRY            => null                                       ,
          P_RECORD_TYPE_CODE             => null                                       ,
          P_TAX_PROVIDER_ID              => null                                       ,
          P_TAX_ONLY_LINE_FLAG           => null                                       ,
          P_ADJUST_TAX_AMT_FLAG          => null                                       ,
          P_ATTRIBUTE_CATEGORY           => null                                       ,
          P_ATTRIBUTE1                   => null                                       ,
          P_ATTRIBUTE2                   => null                                       ,
          P_ATTRIBUTE3                   => null                                       ,
          P_ATTRIBUTE4                   => null                                       ,
          P_ATTRIBUTE5                   => null                                       ,
          P_ATTRIBUTE6                   => null                                       ,
          P_ATTRIBUTE7                   => null                                       ,
          P_ATTRIBUTE8                   => null                                       ,
          P_ATTRIBUTE9                   => null                                       ,
          P_ATTRIBUTE10                  => null                                       ,
          P_ATTRIBUTE11                  => null                                       ,
          P_ATTRIBUTE12                  => null                                       ,
          P_ATTRIBUTE13                  => null                                       ,
          P_ATTRIBUTE14                  => null                                       ,
          P_ATTRIBUTE15                  => null                                       ,
          P_GLOBAL_ATTRIBUTE_CATEGORY    => null                                       ,
          P_GLOBAL_ATTRIBUTE1            => null                                       ,
          P_GLOBAL_ATTRIBUTE2            => null                                       ,
          P_GLOBAL_ATTRIBUTE3            => null                                       ,
          P_GLOBAL_ATTRIBUTE4            => null                                       ,
          P_GLOBAL_ATTRIBUTE5            => null                                       ,
          P_GLOBAL_ATTRIBUTE6            => null                                       ,
          P_GLOBAL_ATTRIBUTE7            => null                                       ,
          P_GLOBAL_ATTRIBUTE8            => null                                       ,
          P_GLOBAL_ATTRIBUTE9            => null                                       ,
          P_GLOBAL_ATTRIBUTE10           => null                                       ,
          P_GLOBAL_ATTRIBUTE11           => null                                       ,
          P_GLOBAL_ATTRIBUTE12           => null                                       ,
          P_GLOBAL_ATTRIBUTE13           => null                                       ,
          P_GLOBAL_ATTRIBUTE14           => null                                       ,
          P_GLOBAL_ATTRIBUTE15           => null                                       ,
          P_GLOBAL_ATTRIBUTE16           => null                                       ,
          P_GLOBAL_ATTRIBUTE17           => null                                       ,
          P_GLOBAL_ATTRIBUTE18           => null                                       ,
          P_GLOBAL_ATTRIBUTE19           => null                                       ,
          P_GLOBAL_ATTRIBUTE20           => null                                       ,
          P_OBJECT_VERSION_NUMBER        => l_object_version_number                    ,
          P_CREATED_BY                => 1       , -------------------------------
          P_CREATION_DATE             => sysdate , -- What are the correct values
          P_LAST_UPDATED_BY           => 1       , -- to pass for who columns?
          P_LAST_UPDATE_LOGIN         => 1       , -- Review this later.
          P_LAST_UPDATE_DATE          => sysdate); -------------------------------

   END LOOP;

    ELSIF p_api_service = 'OVERRIDE_DISTRIBUTION_UPDATE_TAX_LINE' THEN
      -----------------------------------------------------------
      -- Proceeds to Call the Lock_row and Update_row API
      -----------------------------------------------------------

      FOR i in g_suite_rec_tbl.application_id.FIRST..g_suite_rec_tbl.application_id.LAST LOOP

      select object_version_number
      into l_object_version_number
      from ZX_REC_NREC_DIST
      where application_id =g_suite_rec_tbl.application_id(i)
        and entity_code = g_suite_rec_tbl.entity_code(i)
        and event_class_code = g_suite_rec_tbl.event_class_code(i)
        and trx_id = g_suite_rec_tbl.trx_id(i)
        and trx_line_id = g_suite_rec_tbl.trx_line_id(i)
        and trx_level_type = g_suite_rec_tbl.trx_level_type(i)
        and REC_NREC_TAX_DIST_ID = g_suite_rec_tbl.REC_NREC_TAX_DIST_ID(i) ;

      ZX_TRL_DISTRIBUTIONS_PKG.Lock_Row(
          X_ROWID                        => l_row_id                                   ,
          P_REC_NREC_TAX_DIST_ID         => g_suite_rec_tbl.rec_nrec_tax_dist_id(i)    ,
          P_APPLICATION_ID               => g_suite_rec_tbl.application_id(i)          ,
          P_ENTITY_CODE                  => g_suite_rec_tbl.entity_code(i)             ,
          P_EVENT_CLASS_CODE             => g_suite_rec_tbl.event_class_code(i)        ,
          P_EVENT_TYPE_CODE              => g_suite_rec_tbl.event_type_code(i)         ,
          P_TRX_ID                       => g_suite_rec_tbl.trx_id(i)                  ,
          P_TRX_NUMBER                   => null                                       ,
          P_TRX_LINE_ID                  => g_suite_rec_tbl.trx_line_id(i)             ,
          P_TRX_LINE_NUMBER              => g_suite_rec_tbl.trx_line_number(i)         ,
          P_TAX_LINE_ID                  => g_suite_rec_tbl.tax_line_id(i)             ,
          P_TAX_LINE_NUMBER              => null                                       ,
          P_TRX_LINE_DIST_ID             => g_suite_rec_tbl.trx_line_dist_id(i)        ,
          P_TRX_LEVEL_TYPE               => null                                       ,
          P_ITEM_DIST_NUMBER             => g_suite_rec_tbl.item_dist_number(i)        ,
          P_REC_NREC_TAX_DIST_NUMBER     => null                                       ,
          P_REC_NREC_RATE                => null                                       ,
          P_RECOVERABLE_FLAG             => g_suite_rec_tbl.recoverable_flag(i)        ,
          P_REC_NREC_TAX_AMT             => g_suite_rec_tbl.rec_nrec_tax_amt(i)        ,
          P_TAX_EVENT_CLASS_CODE         => null                                       ,
          P_TAX_EVENT_TYPE_CODE          => null                                       ,
          P_CONTENT_OWNER_ID             => null                                       ,
          P_TAX_REGIME_ID                => null                                       ,
          P_TAX_REGIME_CODE              => g_suite_rec_tbl.tax_regime_code(i)         ,
          P_TAX_ID                       => null                                       ,
          P_TAX                          => g_suite_rec_tbl.tax(i)                     ,
          P_TAX_STATUS_ID                => null                                       ,
          P_TAX_STATUS_CODE              => g_suite_rec_tbl.tax_status_code(i)         ,
          P_TAX_RATE_ID                  => g_suite_rec_tbl.tax_rate_id(i)             ,
          P_TAX_RATE_CODE                => g_suite_rec_tbl.tax_rate_code(i)           ,
          P_TAX_RATE                     => g_suite_rec_tbl.tax_rate(i)                ,
          P_INCLUSIVE_FLAG               => null                                       ,
          P_RECOVERY_TYPE_ID             => null                                       ,
          P_RECOVERY_TYPE_CODE           => g_suite_rec_tbl.recovery_type_code(i)      ,
          P_RECOVERY_RATE_ID             => null                                       ,
          P_RECOVERY_RATE_CODE           => g_suite_rec_tbl.recovery_rate_code(i)      ,
          P_REC_TYPE_RULE_FLAG           => null                                       ,
          P_NEW_REC_RATE_CODE_FLAG       => null                                       ,
          P_REVERSE_FLAG                 => g_suite_rec_tbl.reverse_flag(i)            ,
          P_HISTORICAL_FLAG              => g_suite_rec_tbl.historical_flag(i)         ,
          P_REVERSED_TAX_DIST_ID         => g_suite_rec_tbl.reversed_tax_dist_id(i)    ,
          P_REC_NREC_TAX_AMT_TAX_CURR    => null                                       ,
          P_REC_NREC_TAX_AMT_FUNCL_CURR  => g_suite_rec_tbl.rec_nrec_tax_amt_funcl_curr(i),
          P_INTENDED_USE                 => null                                       ,
          P_PROJECT_ID                   => g_suite_rec_tbl.project_id(i)              ,
          P_TASK_ID                      => g_suite_rec_tbl.task_id(i)                 ,
          P_AWARD_ID                     => g_suite_rec_tbl.award_id(i)                ,
          P_EXPENDITURE_TYPE             => g_suite_rec_tbl.expenditure_type(i)        ,
          P_EXPENDITURE_ORGANIZATION_ID  => g_suite_rec_tbl.expenditure_organization_id(i),
          P_EXPENDITURE_ITEM_DATE        => g_suite_rec_tbl.expenditure_item_date(i)   ,
          P_REC_RATE_DET_RULE_FLAG       => null                                       ,
          P_LEDGER_ID                    => g_suite_rec_tbl.ledger_id(i)               ,
          P_SUMMARY_TAX_LINE_ID          => g_suite_rec_tbl.summary_tax_line_id(i)     ,
          P_RECORD_TYPE_CODE             => null                                       ,
          P_CURRENCY_CONVERSION_DATE     => g_suite_rec_tbl.currency_conversion_date(i),
          P_CURRENCY_CONVERSION_TYPE     => g_suite_rec_tbl.currency_conversion_type(i),
          P_CURRENCY_CONVERSION_RATE     => g_suite_rec_tbl.currency_conversion_rate(i),
          P_TAX_CURRENCY_CONVERSION_DATE => null                                       ,
          P_TAX_CURRENCY_CONVERSION_TYPE => null                                       ,
          P_TAX_CURRENCY_CONVERSION_RATE => null                                       ,
          P_TRX_CURRENCY_CODE            => g_suite_rec_tbl.trx_currency_code(i)       ,
          P_TAX_CURRENCY_CODE            => null                                       ,
          P_TRX_LINE_DIST_QTY            => null                                       ,
          P_REF_DOC_TRX_LINE_DIST_QTY    => null                                       ,
          P_PRICE_DIFF                   => null                                       ,
          P_QTY_DIFF                     => null                                       ,
          P_PER_TRX_CURR_UNIT_NR_AMT     => null                                       ,
          P_REF_PER_TRX_CURR_UNIT_NR_AMT => null                                       ,
          P_REF_DOC_CURR_CONV_RATE       => null                                       ,
          P_UNIT_PRICE                   => null                                       ,
          P_REF_DOC_UNIT_PRICE           => null                                       ,
          P_PER_UNIT_NREC_TAX_AMT        => null                                       ,
          P_REF_DOC_PER_UNIT_NREC_TAX_AM => null                                       ,
          P_RATE_TAX_FACTOR              => null                                       ,
          P_TAX_APPORTIONMENT_FLAG       => null                                       ,
          P_TRX_LINE_DIST_AMT            => g_suite_rec_tbl.trx_line_dist_amt(i)       ,
          P_TRX_LINE_DIST_TAX_AMT        => null                                       ,
          P_ORIG_REC_NREC_RATE           => null                                       ,
          P_ORIG_REC_RATE_CODE           => null                                       ,
          P_ORIG_REC_NREC_TAX_AMT        => null                                       ,
          P_ORIG_REC_NREC_TAX_AMT_TAX_CU => null                                       ,
          P_ACCOUNT_CCID                 => null                                       ,
          P_ACCOUNT_STRING               => null                                       ,
          P_UNROUNDED_REC_NREC_TAX_AMT   => null                                       ,
          P_APPLICABILITY_RESULT_ID      => null                                       ,
          P_REC_RATE_RESULT_ID           => null                                       ,
          P_BACKWARD_COMPATIBILITY_FLAG  => null                                       ,
          P_OVERRIDDEN_FLAG              => null                                       ,
          P_SELF_ASSESSED_FLAG           => g_suite_rec_tbl.self_assessed_flag(i)      ,
          P_FREEZE_FLAG                  => g_suite_rec_tbl.freeze_flag(i)             ,
          P_POSTING_FLAG                 => g_suite_rec_tbl.posting_flag(i)            ,
          P_GL_DATE                      => null                                       ,
          P_REF_DOC_APPLICATION_ID       => null                                       ,
          P_REF_DOC_ENTITY_CODE          => null                                       ,
          P_REF_DOC_EVENT_CLASS_CODE     => null                                       ,
          P_REF_DOC_TRX_ID               => null                                       ,
          P_REF_DOC_TRX_LEVEL_TYPE       => null                                       ,
          P_REF_DOC_LINE_ID              => null                                       ,
          P_REF_DOC_DIST_ID              => null                                       ,
          P_MINIMUM_ACCOUNTABLE_UNIT     => null                                       ,
          P_PRECISION                    => null                                       ,
          P_ROUNDING_RULE_CODE           => null                                       ,
          P_TAXABLE_AMT                  => null                                       ,
          P_TAXABLE_AMT_TAX_CURR         => null                                       ,
          P_TAXABLE_AMT_FUNCL_CURR       => null                                       ,
          P_TAX_ONLY_LINE_FLAG           => null                                       ,
          P_UNROUNDED_TAXABLE_AMT        => null                                       ,
          P_LEGAL_ENTITY_ID              => null                                       ,
          P_PRD_TAX_AMT                  => null                                       ,
          P_PRD_TAX_AMT_TAX_CURR         => null                                       ,
          P_PRD_TAX_AMT_FUNCL_CURR       => null                                       ,
          P_PRD_TOTAL_TAX_AMT            => null                                       ,
          P_PRD_TOTAL_TAX_AMT_TAX_CURR   => null                                       ,
          P_PRD_TOTAL_TAX_AMT_FUNCL_CURR => null                                       ,
          P_APPLIED_FROM_TAX_DIST_ID     => null                                       ,
          P_APPL_TO_DOC_CURR_CONV_RATE   => null                                       ,
          P_ADJUSTED_DOC_TAX_DIST_ID     => null                                       ,
          P_FUNC_CURR_ROUNDING_ADJUST    => null                                       ,
          P_TAX_APPORTIONMENT_LINE_NUM   => null                                       ,
          P_LAST_MANUAL_ENTRY            => null                                       ,
          P_REF_DOC_TAX_DIST_ID          => null                                       ,
          P_MRC_TAX_DIST_FLAG            => null                                       ,
          P_MRC_LINK_TO_TAX_DIST_ID      => null                                       ,
/*          P_HDR_TRX_USER_KEY1            => null                                       ,
          P_HDR_TRX_USER_KEY2            => null                                       ,
          P_HDR_TRX_USER_KEY3            => null                                       ,
          P_HDR_TRX_USER_KEY4            => null                                       ,
          P_HDR_TRX_USER_KEY5            => null                                       ,
          P_HDR_TRX_USER_KEY6            => null                                       ,
          P_LINE_TRX_USER_KEY1           => null                                       ,
          P_LINE_TRX_USER_KEY2           => null                                       ,
          P_LINE_TRX_USER_KEY3           => null                                       ,
          P_LINE_TRX_USER_KEY4           => null                                       ,
          P_LINE_TRX_USER_KEY5           => null                                       ,
          P_LINE_TRX_USER_KEY6           => null                                       ,
          P_DIST_TRX_USER_KEY1           => null                                       ,
          P_DIST_TRX_USER_KEY2           => null                                       ,
          P_DIST_TRX_USER_KEY3           => null                                       ,
          P_DIST_TRX_USER_KEY4           => null                                       ,
          P_DIST_TRX_USER_KEY5           => null                                       ,
          P_DIST_TRX_USER_KEY6           => null                                       ,*/
          P_ATTRIBUTE_CATEGORY           => null                                       ,
          P_ATTRIBUTE1                   => null                                       ,
          P_ATTRIBUTE2                   => null                                       ,
          P_ATTRIBUTE3                   => null                                       ,
          P_ATTRIBUTE4                   => null                                       ,
          P_ATTRIBUTE5                   => null                                       ,
          P_ATTRIBUTE6                   => null                                       ,
          P_ATTRIBUTE7                   => null                                       ,
          P_ATTRIBUTE8                   => null                                       ,
          P_ATTRIBUTE9                   => null                                       ,
          P_ATTRIBUTE10                  => null                                       ,
          P_ATTRIBUTE11                  => null                                       ,
          P_ATTRIBUTE12                  => null                                       ,
          P_ATTRIBUTE13                  => null                                       ,
          P_ATTRIBUTE14                  => null                                       ,
          P_ATTRIBUTE15                  => null                                       ,
          P_GLOBAL_ATTRIBUTE_CATEGORY    => null                                       ,
          P_GLOBAL_ATTRIBUTE1            => null                                       ,
          P_GLOBAL_ATTRIBUTE2            => null                                       ,
          P_GLOBAL_ATTRIBUTE3            => null                                       ,
          P_GLOBAL_ATTRIBUTE4            => null                                       ,
          P_GLOBAL_ATTRIBUTE5            => null                                       ,
          P_GLOBAL_ATTRIBUTE6            => null                                       ,
          P_GLOBAL_ATTRIBUTE7            => null                                       ,
          P_GLOBAL_ATTRIBUTE8            => null                                       ,
          P_GLOBAL_ATTRIBUTE9            => null                                       ,
          P_GLOBAL_ATTRIBUTE10           => null                                       ,
          P_GLOBAL_ATTRIBUTE11           => null                                       ,
          P_GLOBAL_ATTRIBUTE12           => null                                       ,
          P_GLOBAL_ATTRIBUTE13           => null                                       ,
          P_GLOBAL_ATTRIBUTE14           => null                                       ,
          P_GLOBAL_ATTRIBUTE15           => null                                       ,
          P_GLOBAL_ATTRIBUTE16           => null                                       ,
          P_GLOBAL_ATTRIBUTE17           => null                                       ,
          P_GLOBAL_ATTRIBUTE18           => null                                       ,
          P_GLOBAL_ATTRIBUTE19           => null                                       ,
          P_GLOBAL_ATTRIBUTE20           => null                                       ,
          P_ORIG_AP_CHRG_DIST_NUM        => null                                       ,
          P_ORIG_AP_CHRG_DIST_ID         => null                                       ,
          P_ORIG_AP_TAX_DIST_NUM         => null                                       ,
          P_ORIG_AP_TAX_DIST_ID          => null                                       ,
          P_OBJECT_VERSION_NUMBER        => l_object_version_number                    ,
          P_CREATED_BY                => 1       , -------------------------------
          P_CREATION_DATE             => sysdate , -- What are the correct values
          P_LAST_UPDATED_BY           => 1       , -- to pass for who columns?
          P_LAST_UPDATE_LOGIN         => 1       , -- Review this later.
          P_LAST_UPDATE_DATE          => sysdate); -------------------------------

    END LOOP;

    FOR i in g_suite_rec_tbl.application_id.FIRST..g_suite_rec_tbl.application_id.LAST LOOP

      select object_version_number
      into l_object_version_number
      from ZX_REC_NREC_DIST
      where application_id =g_suite_rec_tbl.application_id(i)
        and entity_code = g_suite_rec_tbl.entity_code(i)
        and event_class_code = g_suite_rec_tbl.event_class_code(i)
        and trx_id = g_suite_rec_tbl.trx_id(i)
        and trx_line_id = g_suite_rec_tbl.trx_line_id(i)
        and trx_level_type = g_suite_rec_tbl.trx_level_type(i)
        and REC_NREC_TAX_DIST_ID = g_suite_rec_tbl.REC_NREC_TAX_DIST_ID(i) ;

    ZX_TRL_DISTRIBUTIONS_PKG.Update_row(
--          X_ROWID                        => l_row_id                                   ,
          P_REC_NREC_TAX_DIST_ID         => g_suite_rec_tbl.rec_nrec_tax_dist_id(i)    ,
          P_APPLICATION_ID               => g_suite_rec_tbl.application_id(i)          ,
          P_ENTITY_CODE                  => g_suite_rec_tbl.entity_code(i)             ,
          P_EVENT_CLASS_CODE             => g_suite_rec_tbl.event_class_code(i)        ,
          P_EVENT_TYPE_CODE              => g_suite_rec_tbl.event_type_code(i)         ,
          P_TRX_ID                       => g_suite_rec_tbl.trx_id(i)                  ,
          P_TRX_NUMBER                   => null                                       ,
          P_TRX_LINE_ID                  => g_suite_rec_tbl.trx_line_id(i)             ,
          P_TRX_LINE_NUMBER              => g_suite_rec_tbl.trx_line_number(i)         ,
          P_TAX_LINE_ID                  => g_suite_rec_tbl.tax_line_id(i)             ,
          P_TAX_LINE_NUMBER              => null                                       ,
          P_TRX_LINE_DIST_ID             => g_suite_rec_tbl.trx_line_dist_id(i)        ,
          P_TRX_LEVEL_TYPE               => null                                       ,
          P_ITEM_DIST_NUMBER             => g_suite_rec_tbl.item_dist_number(i)        ,
          P_REC_NREC_TAX_DIST_NUMBER     => null                                       ,
          P_REC_NREC_RATE                => null                                       ,
          P_RECOVERABLE_FLAG             => null                                       ,
          P_REC_NREC_TAX_AMT             => g_suite_rec_tbl.rec_nrec_tax_amt(i)        ,
          P_TAX_EVENT_CLASS_CODE         => null                                       ,
          P_TAX_EVENT_TYPE_CODE          => null                                       ,
          P_CONTENT_OWNER_ID             => null                                       ,
          P_TAX_REGIME_ID                => null                                       ,
          P_TAX_REGIME_CODE              => g_suite_rec_tbl.tax_regime_code(i)         ,
          P_TAX_ID                       => null                                       ,
          P_TAX                          => g_suite_rec_tbl.tax(i)                     ,
          P_TAX_STATUS_ID                => null                                       ,
          P_TAX_STATUS_CODE              => g_suite_rec_tbl.tax_status_code(i)         ,
          P_TAX_RATE_ID                  => g_suite_rec_tbl.tax_rate_id(i)             ,
          P_TAX_RATE_CODE                => g_suite_rec_tbl.tax_rate_code(i)           ,
          P_TAX_RATE                     => g_suite_rec_tbl.tax_rate(i)                ,
          P_INCLUSIVE_FLAG               => null                                       ,
          P_RECOVERY_TYPE_ID             => null                                       ,
          P_RECOVERY_TYPE_CODE           => g_suite_rec_tbl.recovery_type_code(i)      ,
          P_RECOVERY_RATE_ID             => null                                       ,
          P_RECOVERY_RATE_CODE           => g_suite_rec_tbl.recovery_rate_code(i)      ,
          P_REC_TYPE_RULE_FLAG           => null                                       ,
          P_NEW_REC_RATE_CODE_FLAG       => null                                       ,
          P_REVERSE_FLAG                 => g_suite_rec_tbl.reverse_flag(i)            ,
          P_HISTORICAL_FLAG              => g_suite_rec_tbl.historical_flag(i)         ,
          P_REVERSED_TAX_DIST_ID         => g_suite_rec_tbl.reversed_tax_dist_id(i)    ,
          P_REC_NREC_TAX_AMT_TAX_CURR    => null                                       ,
          P_REC_NREC_TAX_AMT_FUNCL_CURR  => g_suite_rec_tbl.rec_nrec_tax_amt_funcl_curr(i),
          P_INTENDED_USE                 => null                                       ,
          P_PROJECT_ID                   => g_suite_rec_tbl.project_id(i)              ,
          P_TASK_ID                      => g_suite_rec_tbl.task_id(i)                 ,
          P_AWARD_ID                     => g_suite_rec_tbl.award_id(i)                ,
          P_EXPENDITURE_TYPE             => g_suite_rec_tbl.expenditure_type(i)        ,
          P_EXPENDITURE_ORGANIZATION_ID  => g_suite_rec_tbl.expenditure_organization_id(i),
          P_EXPENDITURE_ITEM_DATE        => g_suite_rec_tbl.expenditure_item_date(i)   ,
          P_REC_RATE_DET_RULE_FLAG       => null                                       ,
          P_LEDGER_ID                    => g_suite_rec_tbl.ledger_id(i)               ,
          P_SUMMARY_TAX_LINE_ID          => g_suite_rec_tbl.summary_tax_line_id(i)     ,
          P_RECORD_TYPE_CODE             => null                                       ,
          P_CURRENCY_CONVERSION_DATE     => g_suite_rec_tbl.currency_conversion_date(i),
          P_CURRENCY_CONVERSION_TYPE     => g_suite_rec_tbl.currency_conversion_type(i),
          P_CURRENCY_CONVERSION_RATE     => g_suite_rec_tbl.currency_conversion_rate(i),
          P_TAX_CURRENCY_CONVERSION_DATE => null                                       ,
          P_TAX_CURRENCY_CONVERSION_TYPE => null                                       ,
          P_TAX_CURRENCY_CONVERSION_RATE => null                                       ,
          P_TRX_CURRENCY_CODE            => g_suite_rec_tbl.trx_currency_code(i)       ,
          P_TAX_CURRENCY_CODE            => null                                       ,
          P_TRX_LINE_DIST_QTY            => null                                       ,
          P_REF_DOC_TRX_LINE_DIST_QTY    => null                                       ,
          P_PRICE_DIFF                   => null                                       ,
          P_QTY_DIFF                     => null                                       ,
          P_PER_TRX_CURR_UNIT_NR_AMT     => null                                       ,
          P_REF_PER_TRX_CURR_UNIT_NR_AMT => null                                       ,
          P_REF_DOC_CURR_CONV_RATE       => null                                       ,
          P_UNIT_PRICE                   => null                                       ,
          P_REF_DOC_UNIT_PRICE           => null                                       ,
          P_PER_UNIT_NREC_TAX_AMT        => null                                       ,
          P_REF_DOC_PER_UNIT_NREC_TAX_AM => null                                       ,
          P_RATE_TAX_FACTOR              => null                                       ,
          P_TAX_APPORTIONMENT_FLAG       => null                                       ,
          P_TRX_LINE_DIST_AMT            => g_suite_rec_tbl.trx_line_dist_amt(i)       ,
          P_TRX_LINE_DIST_TAX_AMT        => null                                       ,
          P_ORIG_REC_NREC_RATE           => null                                       ,
          P_ORIG_REC_RATE_CODE           => null                                       ,
          P_ORIG_REC_NREC_TAX_AMT        => null                                       ,
          P_ORIG_REC_NREC_TAX_AMT_TAX_CU => null                                       ,
          P_ACCOUNT_CCID                 => null                                       ,
          P_ACCOUNT_STRING               => null                                       ,
          P_UNROUNDED_REC_NREC_TAX_AMT   => null                                       ,
          P_APPLICABILITY_RESULT_ID      => null                                       ,
          P_REC_RATE_RESULT_ID           => null                                       ,
          P_BACKWARD_COMPATIBILITY_FLAG  => null                                       ,
          P_OVERRIDDEN_FLAG              => null                                       ,
          P_SELF_ASSESSED_FLAG           => g_suite_rec_tbl.self_assessed_flag(i)      ,
          P_FREEZE_FLAG                  => g_suite_rec_tbl.freeze_flag(i)             ,
          P_POSTING_FLAG                 => g_suite_rec_tbl.posting_flag(i)            ,
          P_GL_DATE                      => null                                       ,
          P_REF_DOC_APPLICATION_ID       => null                                       ,
          P_REF_DOC_ENTITY_CODE          => null                                       ,
          P_REF_DOC_EVENT_CLASS_CODE     => null                                       ,
          P_REF_DOC_TRX_ID               => null                                       ,
          P_REF_DOC_TRX_LEVEL_TYPE       => null                                       ,
          P_REF_DOC_LINE_ID              => null                                       ,
          P_REF_DOC_DIST_ID              => null                                       ,
          P_MINIMUM_ACCOUNTABLE_UNIT     => null                                       ,
          P_PRECISION                    => null                                       ,
          P_ROUNDING_RULE_CODE           => null                                       ,
          P_TAXABLE_AMT                  => null                                       ,
          P_TAXABLE_AMT_TAX_CURR         => null                                       ,
          P_TAXABLE_AMT_FUNCL_CURR       => null                                       ,
          P_TAX_ONLY_LINE_FLAG           => null                                       ,
          P_UNROUNDED_TAXABLE_AMT        => null                                       ,
          P_LEGAL_ENTITY_ID              => null                                       ,
          P_PRD_TAX_AMT                  => null                                       ,
          P_PRD_TAX_AMT_TAX_CURR         => null                                       ,
          P_PRD_TAX_AMT_FUNCL_CURR       => null                                       ,
          P_PRD_TOTAL_TAX_AMT            => null                                       ,
          P_PRD_TOTAL_TAX_AMT_TAX_CURR   => null                                       ,
          P_PRD_TOTAL_TAX_AMT_FUNCL_CURR => null                                       ,
          P_APPLIED_FROM_TAX_DIST_ID     => null                                       ,
          P_APPL_TO_DOC_CURR_CONV_RATE   => null                                       ,
          P_ADJUSTED_DOC_TAX_DIST_ID     => null                                       ,
          P_FUNC_CURR_ROUNDING_ADJUST    => null                                       ,
          P_TAX_APPORTIONMENT_LINE_NUM   => null                                       ,
          P_LAST_MANUAL_ENTRY            => null                                       ,
          P_REF_DOC_TAX_DIST_ID          => null                                       ,
          P_MRC_TAX_DIST_FLAG            => null                                       ,
          P_MRC_LINK_TO_TAX_DIST_ID      => null                                       ,
/*          P_HDR_TRX_USER_KEY1            => null                                       ,
          P_HDR_TRX_USER_KEY2            => null                                       ,
          P_HDR_TRX_USER_KEY3            => null                                       ,
          P_HDR_TRX_USER_KEY4            => null                                       ,
          P_HDR_TRX_USER_KEY5            => null                                       ,
          P_HDR_TRX_USER_KEY6            => null                                       ,
          P_LINE_TRX_USER_KEY1           => null                                       ,
          P_LINE_TRX_USER_KEY2           => null                                       ,
          P_LINE_TRX_USER_KEY3           => null                                       ,
          P_LINE_TRX_USER_KEY4           => null                                       ,
          P_LINE_TRX_USER_KEY5           => null                                       ,
          P_LINE_TRX_USER_KEY6           => null                                       ,
          P_DIST_TRX_USER_KEY1           => null                                       ,
          P_DIST_TRX_USER_KEY2           => null                                       ,
          P_DIST_TRX_USER_KEY3           => null                                       ,
          P_DIST_TRX_USER_KEY4           => null                                       ,
          P_DIST_TRX_USER_KEY5           => null                                       ,
          P_DIST_TRX_USER_KEY6           => null                                       ,
          P_REPORTING_CURRENCY_CODE      => null                                       ,
          P_INTERNAL_ORGANIZATION_ID     => null                                       ,*/
          P_ATTRIBUTE_CATEGORY           => null                                       ,
          P_ATTRIBUTE1                   => null                                       ,
          P_ATTRIBUTE2                   => null                                       ,
          P_ATTRIBUTE3                   => null                                       ,
          P_ATTRIBUTE4                   => null                                       ,
          P_ATTRIBUTE5                   => null                                       ,
          P_ATTRIBUTE6                   => null                                       ,
          P_ATTRIBUTE7                   => null                                       ,
          P_ATTRIBUTE8                   => null                                       ,
          P_ATTRIBUTE9                   => null                                       ,
          P_ATTRIBUTE10                  => null                                       ,
          P_ATTRIBUTE11                  => null                                       ,
          P_ATTRIBUTE12                  => null                                       ,
          P_ATTRIBUTE13                  => null                                       ,
          P_ATTRIBUTE14                  => null                                       ,
          P_ATTRIBUTE15                  => null                                       ,
          P_GLOBAL_ATTRIBUTE_CATEGORY    => null                                       ,
          P_GLOBAL_ATTRIBUTE1            => null                                       ,
          P_GLOBAL_ATTRIBUTE2            => null                                       ,
          P_GLOBAL_ATTRIBUTE3            => null                                       ,
          P_GLOBAL_ATTRIBUTE4            => null                                       ,
          P_GLOBAL_ATTRIBUTE5            => null                                       ,
          P_GLOBAL_ATTRIBUTE6            => null                                       ,
          P_GLOBAL_ATTRIBUTE7            => null                                       ,
          P_GLOBAL_ATTRIBUTE8            => null                                       ,
          P_GLOBAL_ATTRIBUTE9            => null                                       ,
          P_GLOBAL_ATTRIBUTE10           => null                                       ,
          P_GLOBAL_ATTRIBUTE11           => null                                       ,
          P_GLOBAL_ATTRIBUTE12           => null                                       ,
          P_GLOBAL_ATTRIBUTE13           => null                                       ,
          P_GLOBAL_ATTRIBUTE14           => null                                       ,
          P_GLOBAL_ATTRIBUTE15           => null                                       ,
          P_GLOBAL_ATTRIBUTE16           => null                                       ,
          P_GLOBAL_ATTRIBUTE17           => null                                       ,
          P_GLOBAL_ATTRIBUTE18           => null                                       ,
          P_GLOBAL_ATTRIBUTE19           => null                                       ,
          P_GLOBAL_ATTRIBUTE20           => null                                       ,
          P_ORIG_AP_CHRG_DIST_NUM        => null                                       ,
          P_ORIG_AP_CHRG_DIST_ID         => null                                       ,
          P_ORIG_AP_TAX_DIST_NUM         => null                                       ,
          P_ORIG_AP_TAX_DIST_ID          => null                                       ,
          P_OBJECT_VERSION_NUMBER        => l_object_version_number+1                  ,
--          P_CREATED_BY                   => 1       , -------------------------------
--          P_CREATION_DATE                => sysdate , -- What are the correct values
          P_LAST_UPDATED_BY              => 1       , -- to pass for who columns?
          P_LAST_UPDATE_LOGIN            => 1       , -- Review this later.
          P_LAST_UPDATE_DATE             => sysdate); -------------------------------
 null;
    END LOOP;

    ELSIF p_api_service = 'SYNCHRONIZE_TAX_REPOSITORY' THEN

      ------------------------------------------------------------------
      --The values for sync_trx_rec are stored in global variable
      --g_sync_trx_rec
      ------------------------------------------------------------------
      l_sync_trx_rec := g_sync_trx_rec;

      ------------------------------------------------------------------
      --The values for sync_trx_lines_tbl are stored in global variable
      --g_sync_trx_lines_tbl
      ------------------------------------------------------------------
      l_sync_trx_lines_tbl := g_sync_trx_lines_tbl;

      -----------------------------------------------------------
      -- Proceeds to Call the API Synchronize Tax Repository
      -----------------------------------------------------------
        zx_api_pub.synchronize_tax_repository (
                P_API_VERSION         =>  l_api_version       ,
                P_INIT_MSG_LIST       =>  l_init_msg_list     ,
                P_COMMIT              =>  l_commit            ,
                P_VALIDATION_LEVEL    =>  l_validation_level  ,
                X_RETURN_STATUS       =>  l_return_status     ,
                X_MSG_COUNT           =>  l_msg_count         ,
                X_MSG_DATA            =>  l_msg_data          ,
                P_SYNC_TRX_REC        =>  l_sync_trx_rec      ,
                P_SYNC_TRX_LINES_TBL  =>  l_sync_trx_lines_tbl);


            write_message('Service ZX_API_PUB.SYNCHRONIZE_TAX_REPOSITORY has been called!.');
            write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
            write_message('x_return_status : '||l_return_status);
            write_message('x_msg_count     : '||l_msg_count    );
            write_message('x_msg_data      : '||l_msg_data     );

    ELSIF p_api_service = 'OVERRIDE_TAX' THEN
            l_override_level := 'S';

            -----------------------------------------------------------
            -- Proceeds to Call the API Override Tax
            -----------------------------------------------------------
            zx_api_pub.override_tax(
                           P_API_VERSION      => l_api_version      ,
                           P_INIT_MSG_LIST    => l_init_msg_list    ,
                           P_COMMIT           => l_commit           ,
                           P_VALIDATION_LEVEL => l_validation_level ,
                           X_RETURN_STATUS    => l_return_status    ,
                           X_MSG_COUNT        => l_msg_count        ,
                           X_MSG_DATA         => l_msg_data         ,
                           P_TRANSACTION_REC  => g_transaction_rec  ,
                           P_OVERRIDE_LEVEL   => l_override_level   ,
                           P_EVENT_ID         => null -- v7 change. From where to obtain l_event_id?
                           );

            write_message('Service ZX_API_PUB.OVERRIDE_TAX has been called!. ');
            write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
            write_message('x_return_status : '||l_return_status);
            write_message('x_msg_count     : '||l_msg_count    );
            write_message('x_msg_data      : '||l_msg_data     );

    ELSIF p_api_service = 'GLOBAL_DOCUMENT_UPDATE' THEN
           -----------------------------------------------------------
      -- Proceeds to Call the API Synchronize Tax Repository
      -----------------------------------------------------------
      zx_api_pub.global_document_update (
                     l_api_version      ,
                     l_init_msg_list    ,
                     l_commit           ,
                     l_validation_level ,
                     l_return_status    ,
                     l_msg_count        ,
                     l_msg_data         ,
                     g_transaction_rec );
      write_message('Service ZX_API_PUB.GLOBAL_DOCUMENT_UPDATE has been called!. ');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );

    ELSIF p_api_service = 'MARK_TAX_LINES_DELETED' THEN
      -----------------------------------------------------------
      -- Proceeds to Call the API Synchronize Tax Repository
      -----------------------------------------------------------
      zx_api_pub.mark_tax_lines_deleted (
                     l_api_version      ,
                     l_init_msg_list    ,
                     l_commit           ,
                     l_validation_level ,
                     l_return_status    ,
                     l_msg_count        ,
                     l_msg_data         ,
                     g_transaction_line_rec);

      write_message('Service ZX_API_PUB.MARK_TAX_LINES_DELETED has been called!. ');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );

    ELSIF p_api_service = 'IMPORT_DOCUMENT_WITH_TAX' THEN
      -----------------------------------------------------------
      -- Proceeds to Call the API Synchronize Tax Repository
      -----------------------------------------------------------
      zx_api_pub.import_document_with_tax (
                     l_api_version      ,
                     l_init_msg_list    ,
                     l_commit           ,
                     l_validation_level ,
                     l_return_status    ,
                     l_msg_count        ,
                     l_msg_data
                     );

      write_message('Service ZX_API_PUB.IMPORT_DOCUMENT_WITH_TAX has been called!. ');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );

    ELSIF p_api_service = 'VALIDATE_DOCUMENT_WITH_TAX' THEN
      -----------------------------------------------------------
      -- Proceeds to Call the API Synchronize Tax Repository
      -----------------------------------------------------------
      zx_api_pub.validate_document_for_tax (
                     P_API_VERSION       => l_api_version      ,
                     P_INIT_MSG_LIST     => l_init_msg_list    ,
                     P_COMMIT            => l_commit           ,
                     P_VALIDATION_LEVEL  => l_validation_level ,
                     X_RETURN_STATUS     => l_return_status    ,
                     X_MSG_COUNT         => l_msg_count        ,
                     X_MSG_DATA          => l_msg_data         ,
                     P_TRANSACTION_REC   => g_transaction_rec  ,
                     X_VALIDATION_STATUS => l_validation_status,
                     X_HOLD_CODES_TBL    => l_hold_codes_tbl);

      write_message('Service ZX_API_PUB.VALIDATE_DOCUMENT_WITH_TAX has been called!. ');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );

    ELSIF p_api_service = 'REVERSE_DOCUMENT_DISTRIBUTIONS' THEN
      -----------------------------------------------------------
      -- Proceeds to Call the API Reverse Document Distribution
      -----------------------------------------------------------
      zx_api_pub.reverse_document_distribution (
                     l_api_version      ,
                     l_init_msg_list    ,
                     l_commit           ,
                     l_validation_level ,
                     l_return_status    ,
                     l_msg_count        ,
                     l_msg_data         );

      write_message('Service ZX_API_PUB.REVERSE_DOCUMENT_DISTRIBUTION has been called!. ');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );

    ELSIF p_api_service = 'REVERSE_DOCUMENT' THEN
      -----------------------------------------------------------
      -- Proceeds to Call the API Synchronize Tax Repository
      -----------------------------------------------------------
      zx_api_pub.reverse_document (
                     l_api_version      ,
                     l_init_msg_list    ,
                     l_commit           ,
                     l_validation_level ,
                     l_return_status    ,
                     l_msg_count        ,
                     l_msg_data         );

      write_message('Service ZX_API_PUB.REVERSE_DOCUMENT has been called!. ');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );

    ELSIF p_api_service = 'REVERSE_DISTRIBUTIONS' THEN
      -----------------------------------------------------------
      -- Proceeds to Call the API REVERSE DISTRIBUTIONS
      -----------------------------------------------------------
      zx_api_pub.reverse_distributions (
                     l_api_version      ,
                     l_init_msg_list    ,
                     l_commit           ,
                     l_validation_level ,
                     l_return_status    ,
                     l_msg_count        ,
                     l_msg_data         );

      write_message('Service ZX_API_PUB.REVERSE_DISTRIBUTIONS has been called!. ');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );

    ELSIF p_api_service = 'DETERMINE_RECOVERY' THEN
      -----------------------------------------------------------
      -- Proceeds to Call the API Synchronize Tax Repository
      -----------------------------------------------------------
      zx_api_pub.determine_recovery (
               l_api_version      ,
               l_init_msg_list    ,
               l_commit           ,
               l_validation_level ,
               l_return_status    ,
               l_msg_count        ,
               l_msg_data
               );

      write_message('Service ZX_API_PUB.DETERMINE_RECOVERY has been called!. ');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );

    ELSIF p_api_service = 'OVERRIDE_RECOVERY' THEN
      -----------------------------------------------------------
      -- Proceeds to Call the API Synchronize Tax Repository
      -----------------------------------------------------------
      zx_api_pub.override_recovery (
                     l_api_version      ,
                     l_init_msg_list    ,
                     l_commit           ,
                     l_validation_level ,
                     l_return_status    ,
                     l_msg_count        ,
                     l_msg_data         ,
                     g_transaction_rec  );

      write_message('Service ZX_API_PUB.OVERRIDE_RECOVERY has been called!. ');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );

    ELSIF p_api_service = 'FREEZE_DISTRIBUTION_LINES' THEN
      -----------------------------------------------------------
      -- Proceeds to Call the API Synchronize Tax Repository
      -----------------------------------------------------------
      zx_api_pub.freeze_tax_distributions (
                     l_api_version      ,
                     l_init_msg_list    ,
                     l_commit           ,
                     l_validation_level ,
                     l_return_status    ,
                     l_msg_count        ,
                     l_msg_data         ,
                     g_transaction_rec  );

      write_message('Service ZX_API_PUB.FREEZE_DISTRIBUTION_LINES has been called!. ');
      write_message('For Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data     );

    -------------------------------------------------------------
    -- Call the APIs for the case has been just finished reading.
    -------------------------------------------------------------
    ELSIF p_api_service = 'CANCEL' THEN
      -----------------------------------------------------------
      -- Logic for the Cancel Document
      -----------------------------------------------------------

      -----------------------------------------------------------
      -- Logic to get the start and end number in the case
      -----------------------------------------------------------

      get_start_end_rows_structure
       (
        p_suite     =>  p_suite_number,
        p_case      =>  p_case_number,
        p_structure =>  'STRUCTURE_TRANSACTION_RECORD',
        x_start_row =>  l_initial_row,
        x_end_row   =>  l_ending_row
       );

      write_message('----------------------------------------------------------');
      write_message('Getting start and end rows of the structure '||to_char(l_initial_row)||' End '||to_char(l_ending_row));

      -----------------------------------------------------------
      -- Inserting tax dist id
      -----------------------------------------------------------
      insert_rows_tax_dist_id_gt(p_transaction_id);

      -----------------------------------------------------------
      -- Inserting into transaction record
      -----------------------------------------------------------

      insert_row_transaction_rec(g_transaction_rec,l_initial_row);

      write_message('----------------------------------------------------------');
      write_message('After inserting row_transaction_rec ');

      -----------------------------------------------------------
       -- Selecting Event Type Code
      -----------------------------------------------------------
      Begin

        Select event_type_code into g_transaction_rec.event_type_code
        FROM   zx_evnt_typ_mappings
        WHERE  application_id = g_suite_rec_tbl.APPLICATION_ID(l_initial_row)
        AND    entity_code = g_suite_rec_tbl.ENTITY_CODE(l_initial_row)
        AND    event_class_code = g_suite_rec_tbl.EVENT_CLASS_CODE(l_initial_row)
        AND    tax_event_type_code = 'UPDATE';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Fetching event type code in cancel logic: '||sqlerrm);
        write_message(substr(fnd_message.get,1,200));
        FND_MSG_PUB.Add;
        WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Fetching Event type Code in cancel logic: '||sqlerrm);
        write_message(substr(fnd_message.get,1,200));
        FND_MSG_PUB.Add;
      END;


      -----------------------------------------------------------
      -- Inserting into zx_trx_headers_gt and
      -- zx_transaction_lines_gt
      -----------------------------------------------------------

       Insert into zx_trx_headers_gt
                   ( INTERNAL_ORGANIZATION_ID,
                     APPLICATION_ID,
                     ENTITY_CODE,
                     EVENT_CLASS_CODE,
                     EVENT_TYPE_CODE,
                     TRX_ID,
                     TRX_DATE,
                     TRX_CURRENCY_CODE,
                     PRECISION,
                     LEGAL_ENTITY_ID)
              SELECT INTERNAL_ORGANIZATION_ID,
                     APPLICATION_ID,
                     ENTITY_CODE,
                     EVENT_CLASS_CODE,
                     G_TRANSACTION_REC.EVENT_TYPE_CODE,
                     TRX_ID,
                     TRX_DATE,
                     TRX_CURRENCY_CODE,
                     PRECISION,
                     LEGAL_ENTITY_ID
              FROM   zx_lines
              WHERE  trx_id = p_transaction_id
              AND    tax_only_line_flag= 'N';

 --- Inserting into zx_transaction_lines_gt has changed. Correct it later.
 /*      Insert into zx_transaction_lines_gt
                   ( APPLICATION_ID,
                     ENTITY_CODE,
                     EVENT_CLASS_CODE,
                     TRX_LEVEL_TYPE,
                     LINE_LEVEL_ACTION,
                     TRX_BUSINESS_CATEGORY,
                     LINE_AMT,
                     TRX_LINE_QUANTITY,
                     UNIT_PRICE,
                     --UOM_CODE,                --Commented for V6 Changes.
                     TRX_LINE_GL_DATE,
                     LINE_AMT_INCLUDES_TAX_FLAG)
             SELECT  APPLICATION_ID,
                     ENTITY_CODE,
                     EVENT_CLASS_CODE,
                     TRX_LEVEL_TYPE,
                     'DISCARD',
                     TRX_BUSINESS_CATEGORY,
                     LINE_AMT,
                     TRX_LINE_QUANTITY,
                     UNIT_PRICE,
                     --UOM_CODE,                        -- Commented for V6 Changes.
                     sysdate, --TRX_LINE_GL_DATE,       -- Commented for V6 changes.
                     'A'   --LINE_AMT_INCLUDES_TAX_FLAG -- Commented for V6 Changes.
              FROM   zx_lines
              WHERE  trx_id = p_transaction_id
              AND    tax_only_line_flag= 'N'; */

      -----------------------------------------------------------
      -- Proceeds to Call the APIs Calculate Tax
      -----------------------------------------------------------
      zx_api_pub.calculate_tax (
                     p_api_version      => l_api_version      ,
                     p_init_msg_list    => l_init_msg_list    ,
                     p_commit           => l_commit           ,
                     p_validation_level => l_validation_level ,
                     x_return_status    => l_return_status    ,
                     x_msg_count        => l_msg_count        ,
                     x_msg_data         => l_msg_data
                     );
      write_message('----------------------------------------------------------');
      write_message('Service ZX_API_PUB.CALCULATE_TAX has been called! For '||
                    'Suite: '||p_suite_number||' and Case: '||p_case_number);
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data    );
      write_message('Trx Id          : '||to_char(p_transaction_id));

       l_flag := 'N';

      Begin

        SELECT 'X' into l_flag
        FROM zx_lines
        WHERE trx_id = p_transaction_id
        AND   tax_only_line_flag= 'Y';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Tax Only Lines Flag: '||sqlerrm);
        write_message(substr(fnd_message.get,1,200));
        FND_MSG_PUB.Add;
        WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Tax Only Lines Flag: '||sqlerrm);
        write_message(substr(fnd_message.get,1,200));
        FND_MSG_PUB.Add;
      END;

       IF l_flag = 'X' THEN

      -----------------------------------------------------------
      -- Calling  Discard tax only Lines
      -----------------------------------------------------------

         zx_api_pub.Discard_tax_only_lines
         (
           p_api_version => l_api_version      ,
           p_init_msg_list => l_init_msg_list    ,
           p_commit => l_commit           ,
           p_validation_level => l_validation_level ,
           x_return_status => l_return_status    ,
           x_msg_count => l_msg_count        ,
           x_msg_data => l_msg_data         ,
           p_transaction_rec => g_transaction_rec  );

           write_message('----------------------------------------------------------');
           write_message('Service ZX_API_PUB.Discard_Tax_only_lines has been called ');
           write_message('x_return_status : '||l_return_status);

       END IF;

      -----------------------------------------------------------
       --  Inserting into rev_dist_lines_gt
      -----------------------------------------------------------

          insert_into_rev_dist_lines_gt(p_transaction_id);

      -----------------------------------------------------------
       -- Proceeds to Call Reverse Distributions
      -----------------------------------------------------------
            zx_api_pub.Reverse_distributions (
                           p_api_version => l_api_version      ,
                           p_init_msg_list => l_init_msg_list    ,
                           p_commit => l_commit           ,
                           p_validation_level => l_validation_level ,
                           x_return_status => l_return_status    ,
                           x_msg_count => l_msg_count        ,
                           x_msg_data  => l_msg_data         );

            write_message('Service Reverse_Distributions');
            write_message('After calling Reverse_distributions ');
            write_message('x_return_status : '||l_return_status);
            write_message('x_msg_count     : '||l_msg_count    );
            write_message('x_msg_data      : '||l_msg_data     );

      ----------------------------------------------------------------------
       --   Call validate_document_for_tax
      ----------------------------------------------------------------------

	    zx_api_pub.validate_document_for_tax (
		     p_api_version       => l_api_version,
		     p_init_msg_list     => l_init_msg_list,
		     p_commit            => l_commit,
		     p_validation_level  => l_validation_level,
		     x_return_status     => l_return_status,
		     x_msg_count         => l_msg_count,
		     x_msg_data          => l_msg_data,
		     p_transaction_rec   => g_transaction_rec,
		     x_validation_status => l_validation_status,
             x_hold_codes_tbl    => l_hold_codes_tbl);

      write_message('----------------------------------------------------------');
      write_message('Service ZX_API_PUB.VALIDATE_DOCUMENT_FOR_TAX ');
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data    );

      l_first := TRUE;

      IF l_hold_codes_tbl.count > 1 THEN
        For i in 1..l_hold_codes_tbl.LAST
        LOOP
          IF l_first THEN
            l_tax_hold_code := l_hold_codes_tbl(i);
            l_first := FALSE;
          ELSE
            l_tax_hold_code := l_tax_hold_code||'+'||l_hold_codes_tbl(i);
          END IF;
        END LOOP;
      END IF;

      ----------------------------------------------------------------------
       --   Selecting event type code for tax event type 'CANCEL'
      ----------------------------------------------------------------------

           --g_transaction_rec.tax_hold_released_code := l_tax_hold_code;
           BEGIN
           Select event_type_code into g_transaction_rec.event_type_code
           FROM   zx_evnt_typ_mappings
           WHERE  application_id = g_suite_rec_tbl.APPLICATION_ID(l_initial_row)
           AND    entity_code = g_suite_rec_tbl.ENTITY_CODE(l_initial_row)
           AND    event_class_code = g_suite_rec_tbl.EVENT_CLASS_CODE(l_initial_row)
           AND    tax_event_type_code = 'CANCEL';

           EXCEPTION
             WHEN NO_DATA_FOUND THEN
             FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
             FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Event Type for Tax event type CANCEL in Cancel Logic: '||sqlerrm);
             write_message(substr(fnd_message.get,1,200));
             FND_MSG_PUB.Add;
             WHEN OTHERS THEN
             FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
             FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Event Type Code for Tax Event type CANCEL in Cancel Logic: '||sqlerrm);
             write_message(substr(fnd_message.get,1,200));
             FND_MSG_PUB.Add;
           END;

      ----------------------------------------------------------------------
      --   Call global_document_update
      ----------------------------------------------------------------------

            zx_api_pub.global_document_update (
                     p_api_version      => l_api_version,
                     p_init_msg_list    => l_init_msg_list,
                     p_commit           => l_commit,
                     p_validation_level => l_validation_level ,
                     x_return_status    => l_return_status ,
                     x_msg_count        => l_msg_count ,
                     x_msg_data         => l_msg_data ,
                     p_transaction_rec  => g_transaction_rec );

      write_message('----------------------------------------------------------');
      write_message('Service ZX_API_PUB.GLOBAL_DOCUMENT_FOR_UPDATE has been called');
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data      : '||l_msg_data    );

      ----------------------------------------------------------------------
       --   Selecting event type code for tax event type 'RELEASE_HOLD'
      ----------------------------------------------------------------------

         BEGIN
           Select event_type_code into g_transaction_rec.event_type_code
           FROM   zx_evnt_typ_mappings
           WHERE  application_id = g_suite_rec_tbl.APPLICATION_ID(l_initial_row)
           AND    entity_code = g_suite_rec_tbl.ENTITY_CODE(l_initial_row)
           AND    event_class_code = g_suite_rec_tbl.EVENT_CLASS_CODE(l_initial_row)
           AND    tax_event_type_code = 'RELEASE_HOLD';
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
             FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Deriving Event type code for Tax event type release_code in Cancel Logic: '||sqlerrm);
             write_message(substr(fnd_message.get,1,200));
             FND_MSG_PUB.Add;
             WHEN OTHERS THEN
             FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
             FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Deriving Event type code for Tax event type release_code in Cancel Logic: '||sqlerrm);
             write_message(substr(fnd_message.get,1,200));
             FND_MSG_PUB.Add;
         END;

      ----------------------------------------------------------------------
      --   Call global_document_update
      ----------------------------------------------------------------------

            zx_api_pub.global_document_update (
                     p_api_version => l_api_version ,
                     p_init_msg_list => l_init_msg_list    ,
                     p_commit => l_commit,
                     p_validation_level => l_validation_level ,
                     x_return_status => l_return_status ,
                     x_msg_count => l_msg_count ,
                     x_msg_data => l_msg_data ,
                     p_transaction_rec => g_transaction_rec );

      write_message('----------------------------------------------------------');
      write_message('Service ZX_API_PUB.GLOBAL_DOCUMENT_UPDATE has been called ');
      write_message('x_return_status : '||l_return_status);
      write_message('x_msg_count     : '||l_msg_count    );
      write_message('x_msg_data     : '||l_msg_data    );

   END IF;

   write_message('--------------------------------------');
   write_message('Calls to the APIs have been completed.');
   write_message('Populating report table.');
   write_message('--------------------------------------');

    ----------------------------------------------------
    -- After Calling the API Call populate Report Tables
    ----------------------------------------------------
    IF l_return_status = 'S' then
      IF l_msg_data is not null then
        l_error_flag := 'Y';
      ELSE
        l_error_flag := 'N';
      END IF;

      ---------------------------------------------
      -- Print messages only when there is a error.
      ---------------------------------------------
      l_error_flag := 'N';
    ELSE
      l_error_flag := 'Y';
    END IF;


    If l_return_status = 'S' and l_error_flag = 'Y' then
       write_message('Call to API was SUCCESSFUL!, messages are returned.');
    Elsif l_return_status = 'S' and l_error_flag = 'N' then
       write_message('Call to API was SUCCESSFUL!, no messages are returned.');
    Elsif l_return_status <> 'S' and l_error_flag = 'Y' then
       write_message('Call to API was NOT SUCCESSFUL!, messages are returned.');
    Elsif l_return_status <> 'S' and l_error_flag = 'N' then
       write_message('Call to API was NOT SUCCESSFUL!, no messages are returned.');
    Else
       write_message('Call to API was NOT SUCCESSFUL!');
       write_message('return_status:'||l_return_status);
       write_message('error_flag:'||l_error_flag);
    End if;


    IF l_msg_count = 1 THEN
      --------------------------------------------------------
      --If there is one message raised by the API, so it has
      --been sent out in the parameter x_msg_dat a, get it.
      --------------------------------------------------------
      write_message('Retrieving unique message returned by the API...');
      write_message('x_msg_data      : '||l_msg_data     );
    ELSIF l_msg_count > 1 THEN
      -----------------------------------------------------------
      --If the messages on the stack are more than one, create a
      --loop and put the messages in a PL/SQL table.
      -----------------------------------------------------------
     write_message('Retrieving multiple messages returned by API...');
     LOOP
      l_mesg := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
      IF  l_mesg IS NULL THEN
         EXIT;
      ELSE
        write_message(l_mesg);
        l_msg_data := l_msg_data ||' '|| ltrim(rtrim(l_mesg));
      END IF;
     END LOOP;
    END IF;

    -----------------------------------------------------
    -- If there are messages in ZX_ERRORS_GT extract them
    -----------------------------------------------------
    get_zx_errors_gt(l_zx_errors_gt);
    IF ltrim(rtrim(l_zx_errors_gt)) IS NOT NULL THEN
      l_msg_data := l_msg_data ||' Errors from ZX_ERRORS_GT:'||l_zx_errors_gt;
      write_message(l_msg_data);
    END IF;

    ---------------------------------------------------------
    -- Proceed to pupulate the table used by the report
    ---------------------------------------------------------
    populate_report_table(
                          p_suite          => p_suite_number,
                          p_case           => p_case_number ,
                          p_service        => p_api_service ,
                          p_transaction_id => p_transaction_id,
                          p_error_flag     => l_error_flag,
                          p_error_message  => l_msg_data
                         );

  END call_api;


/* ====================================================================================*
 | PROCEDURE insert_into_gts : Logic to Insert in the Global Temporary Tables,         |
 |                             Records or Records of Tables                            |
 * ====================================================================================*/
  PROCEDURE insert_into_gts (p_suite_number    IN VARCHAR2,
                             p_case_number     IN VARCHAR2,
                             p_service         IN VARCHAR2,
                             p_structure       IN VARCHAR2,
                             p_header_row_id   IN NUMBER,
                             p_starting_row_id IN NUMBER,
                             p_ending_row_id   IN NUMBER,
                             p_prev_trx_id     IN NUMBER) IS
  l_trx_id       NUMBER;
  l_initial_row  NUMBER;
  l_ending_row   NUMBER;
  l_header_row   NUMBER;

  BEGIN
    IF p_service = 'CALCULATE_TAX' THEN
      ---------------------------------------------------------------
      --Insert the data in the GTT for Transaction Headers
      ---------------------------------------------------------------
      insert_data_trx_headers_gt(p_header_row_id);
      write_message('Row has been inserted in ZX_TRX_HEADERS_GT!');

      ---------------------------------------------------------------
      --Insert the data in the GTT for Transaction Lines
      ---------------------------------------------------------------
      insert_data_trx_lines_gt(p_header_row_id,
                               p_starting_row_id,
                               p_ending_row_id);
      write_message('Row(s) have been inserted in TRX_LINES_GT!');

      ---------------------------------------------------------------
      --Insert the data in the MRC Table
      ---------------------------------------------------------------
      insert_data_mrc_gt(p_header_row_id);
      write_message('Row(s) have been inserted in ZX_MRC_GT!');


    ELSIF p_service = 'DETERMINE_RECOVERY'         THEN
          ----------------------------------------------------------
          -- Retrieve the initial and ending lines for Imp Tax Lines
          ----------------------------------------------------------
          get_start_end_rows_structure
          (
           p_suite     =>  p_suite_number,
           p_case      =>  p_case_number,
           p_structure =>  'STRUCTURE_TRANSACTION_HEADER',
           x_start_row =>  l_initial_row,
           x_end_row   =>  l_ending_row
           );

          l_header_row := l_initial_row;

          ----------------------------------------------------------------------------
          -- BUG 4376581. For Determine Recovery will be required to reinsert
          --              the header information. Not to re-use the Header of
          --              the Calculate Tax, because Determine Recovery header
          --              requires the following header value:
          --                 EVENT_TYPE_CODE = STANDARD DISTRIBUTE
          --              I'll delete and reinsert the entire Header Information
          --              for Determine Recovey as other columns may have changed.
          ----------------------------------------------------------------------------
          DELETE from ZX_TRX_HEADERS_GT
          WHERE  trx_id = g_suite_rec_tbl.TRX_ID(p_header_row_id);

          write_message('--Row for Calculate has been deleted from ZX_TRX_HEADERS_GT!!!');


          ----------------------------------
          -- Insert the Transaction Header
          ----------------------------------
          insert_data_trx_headers_gt(l_header_row);
          write_message('--Row for Recovery has been inserted in ZX_TRX_HEADERS_GT!!!');


          ----------------------------------------------------------
          -- Retrieve the initial and ending lines for Imp Tax Lines
          ----------------------------------------------------------
          get_start_end_rows_structure
          (
           p_suite     =>  p_suite_number,
           p_case      =>  p_case_number,
           p_structure =>  'STRUCTURE_ITEM_DISTRIBUTIONS',
           x_start_row =>  l_initial_row,
           x_end_row   =>  l_ending_row
           );


          ----------------------------------
          -- Insert the Item Distribution
          ----------------------------------
          insert_itm_distributions_gt
             (
              p_header_row           => l_header_row,
              p_sta_row_item_dist    => l_initial_row,
              p_end_row_item_dist    => l_ending_row
              );

          write_message('--Row(s) has been inserted in ZX_ITM_DISTRIBUTIONS_GT!!!');

          ---------------------------------------------------------------
          --Insert the data in the MRC Table
          ---------------------------------------------------------------
          insert_data_mrc_gt(p_header_row_id);
          write_message('--Row(s) have been inserted in ZX_MRC_GT!');



    ELSIF p_service = 'SYNCHRONIZE_TAX_REPOSITORY' THEN

          ----------------------------------------------------
          --Insert the row in the g_sync_trx_rec
          ----------------------------------------------------
          insert_sync_trx_rec(
              p_header_row                   =>  p_header_row_id,
              x_sync_trx_rec                 =>  g_sync_trx_rec);
          write_message('A row has been inserted in g_sync_trx_rec.');

          ----------------------------------------------------
          --Insert the row in the g_sync_trx_lines_tbl
          ----------------------------------------------------
          insert_sync_trx_lines_tbl(
              p_header_row                   =>  p_header_row_id,
              p_starting_row_sync_trx_lines  =>  p_starting_row_id,
              p_ending_row_sync_trx_lines    =>  p_ending_row_id,
              x_sync_trx_lines_tbl           =>  g_sync_trx_lines_tbl);
          write_message('Rows have been inserted in g_sync_trx_lines_tbl.');


    ELSIF p_service = 'OVERRIDE_TAX'               THEN
          --------------------------
          --Insert the row in the GT
          --------------------------
          insert_data_trx_headers_gt(p_header_row_id);
          write_message('-- A row has been inserted in ZX_TRX_HEADERS_GT!!!');

          -----------------------------------------------------------
          -- Logic to get the start and end number in the case
          -----------------------------------------------------------
          get_start_end_rows_structure
           (
             p_suite     =>  p_suite_number,
             p_case      =>  p_case_number,
             p_structure =>  'STRUCTURE_TRANSACTION_RECORD',
             x_start_row =>  l_initial_row,
             x_end_row   =>  l_ending_row
           );

          -----------------------------------------------------------
          -- Inserting into transaction record
          -----------------------------------------------------------
          insert_row_transaction_rec(g_transaction_rec,l_initial_row);
          write_message('-- A row has been inserted in TRANSACTION RECORD!!!');

    ELSIF p_service = 'GLOBAL_DOCUMENT_UPDATE'     THEN
          --------------------------
          --Insert the row in the GT
          --------------------------
          insert_transaction_rec(g_transaction_rec);
          write_message('A row has been inserted in transaction_rec.');

    ELSIF p_service = 'MARK_TAX_LINES_DELETED'     THEN
          -----------------------------------------------------------
          -- Logic to get the start and end number in the case
          -----------------------------------------------------------
          get_start_end_rows_structure
           (
             p_suite     =>  p_suite_number,
             p_case      =>  p_case_number,
             p_structure =>  'STRUCTURE_TRANSACTION_LINE_RECORD',
             x_start_row =>  l_initial_row,
             x_end_row   =>  l_ending_row
           );

          --------------------------
          --Insert the row in the GT
          --------------------------
          insert_transaction_line_rec(g_transaction_line_rec,
                                      l_initial_row);


    ELSIF p_service = 'IMPORT_DOCUMENT_WITH_TAX'   THEN
          ---------------------------------------------------------------
          --Insert the data in the GTT for Transaction Headers
          ---------------------------------------------------------------
          insert_data_trx_headers_gt(p_header_row_id);
          write_message('Row has been inserted in ZX_TRX_HEADERS_GT!');

          --------------------------------------------------------------
          -- Retrieve the initial and ending lines for Transaction Lines
          --------------------------------------------------------------
          get_start_end_rows_structure
          (
           p_suite     =>  p_suite_number,
           p_case      =>  p_case_number,
           p_structure =>  'STRUCTURE_TRANSACTION_LINES',
           x_start_row =>  l_initial_row,
           x_end_row   =>  l_ending_row
           );
          --------------------------
          --Insert the row in the GT
          --------------------------
          insert_data_trx_lines_gt(p_header_row_id,
                                   l_initial_row,
                                   l_ending_row);
          write_message('Row(s) have been inserted in TRX_LINES_GT!');


          ---------------------------------------------------------------
          -- Retrieve the initial and ending lines for Imported Tax Lines
          ---------------------------------------------------------------
          get_start_end_rows_structure
          (
           p_suite     =>  p_suite_number,
           p_case      =>  p_case_number,
           p_structure =>  'STRUCTURE_IMPORTED_TAX_LINES',
           x_start_row =>  l_initial_row,
           x_end_row   =>  l_ending_row
           );

          --------------------------------------------
          -- Call Insert into Import Summary Tax Lines
          --------------------------------------------
          insert_import_sum_tax_lines_gt(
                                 p_starting_row_tax_lines => l_initial_row,
                                 p_ending_row_tax_lines   => l_ending_row);

          ----------------------------------------------------------
          -- Retrieve the initial and ending lines for Imp Tax Lines
          ----------------------------------------------------------
          get_start_end_rows_structure
          (
           p_suite     =>  p_suite_number,
           p_case      =>  p_case_number,
           p_structure =>  'STRUCTURE_IMPORTED_TAX_LINES_ALLOCATION',
           x_start_row =>  l_initial_row,
           x_end_row   =>  l_ending_row
           );

          ----------------------------------------------------------------
          -- Allocation is Optional in this scenario. So, only if provided
          -- will be called.
          ----------------------------------------------------------------
          IF l_initial_row is not null THEN
            write_message('To Call TRX_TAX_LINK_GT insert the initial row is'||to_char(l_initial_row));
            -------------------------------------
            -- Call Insert into TRX_TAX_LINK_GT
            -------------------------------------
            insert_trx_tax_link_gt
            (
              p_sta_row_imp_tax_link  => l_initial_row,
              p_end_row_imp_tax_link  => l_ending_row
            );
          END IF;

          write_message('Rows have been inserted in ZX_TRANSACTION_LINES_GT');
          write_message('.                          ZX_IMPORT_TAX_LINES_GT');
          write_message('.                          ZX_TRX_TAX_LINE_GT.');

    ELSIF p_service = 'VALIDATE_DOCUMENT_WITH_TAX' THEN
          --------------------------
          --Insert the row in the GT
          --------------------------
          insert_transaction_rec(g_transaction_rec);
          write_message('A row has been inserted in transaction_rec.');


    ELSIF p_service = 'REVERSE_DOCUMENT'           THEN
          --------------------------
          --Insert the row in the GT
          --------------------------
          insert_reverse_trx_lines_gt;
          write_message('A row has been inserted in reverse_trx_lines_gt.');

    ELSIF p_service = 'REVERSE_DISTRIBUTIONS'      THEN
          --------------------------
          --Insert the row in the GT
          --------------------------
          insert_reverse_dist_lines_gt;
          write_message('A row has been inserted in reverse_dist_lines_gt.');


    ELSIF p_service = 'OVERRIDE_RECOVERY'          THEN
          --------------------------
          --Insert the row in the GT
          --------------------------
          insert_transaction_rec(g_transaction_rec
                                 );
          write_message('A row has been inserted in transaction_rec.');

    ELSIF p_service = 'FREEZE_DISTRIBUTION_LINES'  THEN
          --------------------------
          --Insert the row in the GT
          --------------------------
          insert_transaction_rec(g_transaction_rec);
          ----------------------------------
          -- Insert the Tax Dist Id
          ----------------------------------
          insert_tax_dist_id_gt
             (
              p_suite         => p_suite_number,
              p_case          => p_case_number,
              p_structure     => 'STRUCTURE_ITEM_DISTRIBUTION_KEY'
              );

          write_message('A row has been inserted in transaction_rec.');
          write_message('                           distribution_lines_gt.');
    END IF;
  END insert_into_gts;


/* ======================================================================*
 | PROCEDURE Get_Tax_Event_Type : Get Tax Event Type                     |
 * ======================================================================*/
  FUNCTION Get_Tax_Event_Type
  (
    p_appln_id             IN     NUMBER,
    p_entity_code          IN     VARCHAR2,
    p_evnt_cls_code        IN     VARCHAR2,
    p_evnt_typ_code        IN     VARCHAR2
  ) RETURN VARCHAR2
  IS
    x_tx_evnt_typ_code VARCHAR2(80);

  BEGIN

    SELECT zxevntmap.tax_event_type_code
    INTO   x_tx_evnt_typ_code
    FROM   zx_evnt_typ_mappings zxevntmap
    WHERE  zxevntmap.event_class_code = p_evnt_cls_code
    AND    zxevntmap.application_id = p_appln_id
    AND    zxevntmap.entity_code = p_entity_code
    AND    zxevntmap.event_type_code = p_evnt_typ_code
    AND    zxevntmap.enabled_flag = 'Y';


    RETURN x_tx_evnt_typ_code;

  EXCEPTION

    WHEN OTHERS THEN
      write_message('~  The Event Type Mapping is Invalid for:');
      write_message('~                             APPLN_ID      :'||p_appln_id);
      write_message('~                             ENTITY_CODE   :'||p_entity_code);
      write_message('~                             EVENT_CLS_CODE:'||p_evnt_cls_code);
      write_message('~                             EVENT_TYP_CODE:'||p_evnt_typ_code);

      FND_MESSAGE.SET_NAME('ZX','ZX_EVNT_TYP_MPG_INVALID');
      FND_MSG_PUB.Add;
      Return null;

  END Get_Tax_Event_Type;

 /* ====================================================================================*
  | FUNCTION RETRIEVE_NTH_ELEMENT: Retrieves a element from a string                   |
  * ====================================================================================*/
  FUNCTION get_nth_element
   (
     p_element_number IN NUMBER,
     p_string         IN VARCHAR2,
     p_separator      IN VARCHAR2
   ) RETURN VARCHAR2 IS

  l_position_first_separator  NUMBER;
  l_position_second_separator NUMBER;
  l_element_length            NUMBER;
  l_element_value             VARCHAR2(4000);

  BEGIN
    --------------------------------------
    -- Calculates position first separator
    --------------------------------------
    If p_element_number <> 1 then
      l_position_first_separator := instr(p_string,p_separator,1,p_element_number-1);
    Else
      l_position_first_separator := 0;
    End if;

    --------------------------------------
    -- Calculates position second separator
    --------------------------------------
    l_position_second_separator := instr(p_string,p_separator,1,p_element_number);

    ---------------------------------------
    -- Calculates the length of the element
    ---------------------------------------
    l_element_length := l_position_second_separator - l_position_first_separator;
    l_position_first_separator := l_position_first_separator + 1;
    ----------------------------------------
    -- Calculates the Element String
    ----------------------------------------
    If l_element_length = 0 then
      -- This element is not in the string
      l_element_value := null;
    Elsif l_element_length < 0 then
      -- This element is the last in the string
      l_element_value := substr(p_string,l_position_first_separator);
    Elsif l_element_length = 1 then
      l_element_value := null;
    Else
      -- This element exists in the string.
      l_element_value := substr(p_string,l_position_first_separator,l_element_length-1);
    End If;
    RETURN l_element_value;
  END get_nth_element;

/*==========================================================================*
 | PROCEDURE Populate_Report_Table : Populates the Report Table to display  |
 |                                   the results of the Suite.              |
 |                                   First, it has to fetch the information |
 |                                   from ZX_LINES,ZX_LINES_SUMMARY and     |
 |                                   ZX_REC_NREC_DIST tables, then Bulk     |
 |                                   Collect into memory structures and then|
 |                                   Bulk insert into the temporary table.  |
 *==========================================================================*/

  PROCEDURE Populate_Report_Table
  (
    p_suite                IN     VARCHAR2,
    p_case                 IN     VARCHAR2,
    p_service              IN     VARCHAR2,
    p_transaction_id       IN     NUMBER,
    p_error_flag           IN     VARCHAR2,
    p_error_message        IN     VARCHAR2
  ) IS

    c_lines_per_fetch           CONSTANT NUMBER:= 1000;
    l_counter                   BINARY_INTEGER;
    l_counter2                  BINARY_INTEGER;
    l_tax_rate_name             NUMBER;
    l_tax_rate_type             NUMBER;
    l_dummy                     NUMBER;
    l_application_id            NUMBER;
    l_entity_code               VARCHAR2(2000);
    l_event_class_code          VARCHAR2(2000);
    l_initial_row               VARCHAR2(2000);
    l_ending_row                VARCHAR2(2000);

  BEGIN

    --------------------------------------------------------------
    -- Obtain the App, Entity Code and Event Class Code for the
    -- current Case.
    --------------------------------------------------------------

    FOR i IN g_suite_rec_tbl.ROW_SUITE.FIRST..g_suite_rec_tbl.ROW_SUITE.LAST LOOP
      IF g_suite_rec_tbl.ROW_SUITE(i)     = p_suite AND
         g_suite_rec_tbl.ROW_CASE(i)      = p_case  AND
         g_suite_rec_tbl.APPLICATION_ID(i) IS NOT NULL AND
         g_suite_rec_tbl.ENTITY_CODE(i) IS NOT NULL AND
         g_suite_rec_tbl.EVENT_CLASS_CODE(i) IS NOT NULL
          THEN
          l_application_id   := g_suite_rec_tbl.APPLICATION_ID(i);
          l_entity_code      := g_suite_rec_tbl.ENTITY_CODE(i);
          l_event_class_code := g_suite_rec_tbl.EVENT_CLASS_CODE(i);

      END IF;
    END LOOP;

    IF p_error_flag <> 'Y' THEN

      --------------------------------------------------
      -- Proceed to Insert ZX_LINES data
      --------------------------------------------------
      select count(*)
      into   l_dummy
      from   zx_lines l
      where  l.trx_id           = p_transaction_id
      and    l.application_id   = l_application_id
      and    l.entity_code      = l_entity_code
      and    l.event_class_code = l_event_class_code;


      write_message('The number of rows in ZX_LINES for transaction id '||to_char(p_transaction_id)||' are '||to_char(l_dummy));

      INSERT INTO ZX_TEST_API_GT(
          SUITE_NUMBER                                ,
          CASE_NUMBER                                 ,
          TRX_ID                                      ,
          TRX_NUMBER                                  ,
          TRX_LINE_NUMBER                             ,
          TRX_DATE                                    ,
          TRX_CURRENCY_CODE                           ,
          SUMMARY_TAX_LINE_ID                         ,
          TAX_LINE_ID                                 ,
          TAX_REGIME_CODE                             ,
          TAX_JURISDICTION_ID                         ,
          TAX                                         ,
          TAX_STATUS_CODE                             ,
          TAX_RATE_ID                                 ,
          TAX_RATE_CODE                               ,
          TAX_RATE                                    ,
          TAX_AMT                                     ,
          TAXABLE_AMT                                 ,
          REC_TAX_AMT                                 ,
          NREC_TAX_AMT                                ,
          TAX_AMT_FUNCL_CURR                          ,
          TOTAL_REC_TAX_AMT                           ,
          TOTAL_NREC_TAX_AMT                          ,
          TOTAL_REC_TAX_AMT_FUNCL_CURR                ,
          TOTAL_NREC_TAX_AMT_FUNCL_CURR               ,
          SELF_ASSESSED_FLAG                          ,
          MANUALLY_ENTERED_FLAG                       ,
          LINE_AMT_INCLUDES_TAX_FLAG                  ,
          TAXABLE_AMT_FUNCL_CURR                      ,
          REC_TAX_AMT_FUNCL_CURR                      ,
          NREC_TAX_AMT_FUNCL_CURR                     ,
          TAX_AMT_INCLUDED_FLAG                       ,
          TAX_EXEMPTION_ID                            ,
          EXEMPTION_RATE                              ,
          EXEMPT_REASON_CODE                          ,
          TAX_APPORTIONMENT_LINE_NUMBER               ,
          TAX_REGISTRATION_NUMBER                     ,
          TAX_HOLD_CODE                               ,
          TAX_HOLD_RELEASED_CODE                      ,
          LINE_AMT                                    ,
          TAX_JURISDICTION_CODE                       ,
          TAX_RATE_NAME                               ,
          TAX_RATE_TYPE                               ,
          TAX_DETERMINE_DATE                          ,
          CANCEL_FLAG                                 ,
          EVENT_CLASS_CODE                            ,
          EVENT_TYPE_CODE                             ,
          ETAX_API                                    ,
          ERROR_FLAG                                  ,
          ERROR_MESSAGE                               )
          select
          p_suite                                                ,
          p_case                                                 ,
          p_transaction_id                                       ,
          zx_lines.TRX_NUMBER                                    ,
          zx_lines.trx_line_id                                   , --zx_lines.TRX_LINE_NUMBER,
          zx_lines.TRX_DATE                                      ,
          zx_lines.TRX_CURRENCY_CODE                             ,
          zx_lines.SUMMARY_TAX_LINE_ID                           ,
          zx_lines.TAX_LINE_ID                                   ,
          zx_lines.TAX_REGIME_CODE                               ,
          zx_lines.TAX_JURISDICTION_ID                           ,
          zx_lines.TAX                                           ,
          zx_lines.TAX_STATUS_CODE                               ,
          zx_lines.TAX_RATE_ID                                   ,
          zx_lines.TAX_RATE_CODE                                 ,
          zx_lines.TAX_RATE                                      ,
          zx_lines.TAX_AMT                                       ,
          zx_lines.TAXABLE_AMT                                   ,
          zx_lines.REC_TAX_AMT                                   ,
          zx_lines.NREC_TAX_AMT                                  ,
          zx_lines.TAX_AMT_FUNCL_CURR                            ,
          NULL                                                   ,
          NULL                                                   ,
          NULL                                                   ,
          NULL                                                   ,
          zx_lines.SELF_ASSESSED_FLAG                            ,
          zx_lines.MANUALLY_ENTERED_FLAG                         ,
          'A', --substr(zx_lines.LINE_AMT_INCLUDES_TAX_FLAG,1,1)  , --Commented V6 Changes.
          zx_lines.TAXABLE_AMT_FUNCL_CURR                        ,
          zx_lines.REC_TAX_AMT_FUNCL_CURR                        ,
          zx_lines.NREC_TAX_AMT_FUNCL_CURR                       ,
          zx_lines.TAX_AMT_INCLUDED_FLAG                         ,
          zx_lines.TAX_EXEMPTION_ID                              ,
          NULL,      -- zx_lines.EXEMPTION_RATE, --Commented for V6 changes
          zx_lines.EXEMPT_REASON_CODE                            ,
          zx_lines.TAX_APPORTIONMENT_LINE_NUMBER                 ,
          zx_lines.TAX_REGISTRATION_NUMBER                       ,
          zx_lines.TAX_HOLD_CODE                                 ,
          zx_lines.TAX_HOLD_RELEASED_CODE                        ,
          zx_lines.LINE_AMT                                      ,
          zx_lines.TAX_JURISDICTION_CODE                         ,
          zx_rates_b.tax_rate_code,   --l_TAX_RATE_NAME ,-- Has to be calculated
          zx_rates_b.rate_type_code,  --l_TAX_RATE_TYPE_CODE ,-- Has to be calculated
          zx_lines.TAX_DETERMINE_DATE                            ,
          zx_lines.CANCEL_FLAG                                   ,
          zx_lines.EVENT_CLASS_CODE                              ,
          zx_lines.EVENT_TYPE_CODE                               ,
          p_service                                              ,
          'N',   --ERROR_FLAG                                    ,
          g_party_rec.prod_family_grp_code||' LINE' --ERROR_MESSAGE
          FROM   ZX_LINES,
                 ZX_RATES_B
          WHERE  trx_id = p_transaction_id
          AND    application_id   = l_application_id
          AND    entity_code      = l_entity_code
          AND    event_class_code = l_event_class_code
          AND    zx_lines.tax_rate_id(+) = zx_rates_b.tax_rate_id
          ORDER BY trx_id,
          trx_line_id;


      --------------------------------------------------
      -- Insert ZX_LINES_SUMMARY data
      --------------------------------------------------
   select count(*) into l_dummy from zx_lines_summary where trx_id =p_transaction_id;
    write_message('The number of rows in ZX_LINES_SUMMARY for transaction id '
    ||to_char(p_transaction_id)||' are '||to_char(l_dummy));

        INSERT INTO ZX_TEST_API_GT(
          SUITE_NUMBER                                ,
          CASE_NUMBER                                 ,
          TRX_ID                                      ,
          TRX_NUMBER                                  ,
          TRX_LINE_NUMBER                             ,
          TRX_DATE                                    ,
          TRX_CURRENCY_CODE                           ,
          SUMMARY_TAX_LINE_ID                         ,
          TAX_LINE_ID                                 ,
          TAX_REGIME_CODE                             ,
          TAX_JURISDICTION_ID                         ,
          TAX                                         ,
          TAX_STATUS_CODE                             ,
          TAX_RATE_ID                                 ,
          TAX_RATE_CODE                               ,
          TAX_RATE                                    ,
          TAX_AMT                                     ,
          TAXABLE_AMT                                 ,
          REC_TAX_AMT                                 ,
          NREC_TAX_AMT                                ,
          TAX_AMT_FUNCL_CURR                          ,
          TOTAL_REC_TAX_AMT                           ,
          TOTAL_NREC_TAX_AMT                          ,
          TOTAL_REC_TAX_AMT_FUNCL_CURR                ,
          TOTAL_NREC_TAX_AMT_FUNCL_CURR               ,
          SELF_ASSESSED_FLAG                          ,
          MANUALLY_ENTERED_FLAG                       ,
          LINE_AMT_INCLUDES_TAX_FLAG                  ,
          TAXABLE_AMT_FUNCL_CURR                      ,
          REC_TAX_AMT_FUNCL_CURR                      ,
          NREC_TAX_AMT_FUNCL_CURR                     ,
          TAX_AMT_INCLUDED_FLAG                       ,
          TAX_EXEMPTION_ID                            ,
          EXEMPTION_RATE                              ,
          EXEMPT_REASON_CODE                          ,
          TAX_APPORTIONMENT_LINE_NUMBER               ,
          TAX_REGISTRATION_NUMBER                     ,
          TAX_HOLD_CODE                               ,
          TAX_HOLD_RELEASED_CODE                      ,
          LINE_AMT                                    ,
          TAX_JURISDICTION_CODE                       ,
          TAX_RATE_NAME                               ,
          TAX_RATE_TYPE                               ,
          TAX_DETERMINE_DATE                          ,
          CANCEL_FLAG                                 ,
          EVENT_CLASS_CODE                            ,
          EVENT_TYPE_CODE                             ,
          ETAX_API                                    ,
          ERROR_FLAG                                  ,
          ERROR_MESSAGE                               )
          select p_suite                              ,
          p_case                                      ,
          p_transaction_id                            ,
          zx_lines_summary.TRX_NUMBER                 ,
          null,   --TRX_LINE_NUMBER                   ,
          null,   --TRX_DATE                          ,
          null,   --TRX_CURRENCY_CODE                 ,
          zx_lines_summary.SUMMARY_TAX_LINE_ID                  ,
          null,   --TAX_LINE_ID                                 ,
          zx_lines_summary.TAX_REGIME_CODE                      ,
          null,   --zx_lines_summary.TAX_JURISDICTION_ID,  Commented for V6 Changes.
          zx_lines_summary.TAX                                  ,
          zx_lines_summary.TAX_STATUS_CODE                      ,
          zx_lines_summary.TAX_RATE_ID                          ,
          zx_lines_summary.TAX_RATE_CODE                        ,
          zx_lines_summary.TAX_RATE                             ,
          zx_lines_summary.TAX_AMT                              ,
          null,   --TAXABLE_AMT                                               ,
          null,   --REC_TAX_AMT                                               ,
          null,   --NREC_TAX_AMT                                              ,
          zx_lines_summary.TAX_AMT_FUNCL_CURR                   ,
          zx_lines_summary.TOTAL_REC_TAX_AMT                    ,
          zx_lines_summary.TOTAL_NREC_TAX_AMT                   ,
          zx_lines_summary.TOTAL_REC_TAX_AMT_FUNCL_CURR         ,
          zx_lines_summary.TOTAL_NREC_TAX_AMT_FUNCL_CURR        ,
          zx_lines_summary.SELF_ASSESSED_FLAG                   ,
          zx_lines_summary.MANUALLY_ENTERED_FLAG                ,
          null,   --LINE_AMT_INCLUDES_TAX_FLAG                                ,
          null,   --TAXABLE_AMT_FUNCL_CURR                                    ,
          null,   --REC_TAX_AMT_FUNCL_CURR                                    ,
          null,   --NREC_TAX_AMT_FUNCL_CURR                                   ,
          zx_lines_summary.TAX_AMT_INCLUDED_FLAG                ,
          null,   --TAX_EXEMPTION_ID                                          ,
          null,   --EXEMPTION_RATE                                            ,
          null,   --EXEMPT_REASON_CODE                                        ,
          null,   --TAX_APPORTIONMENT_LINE_NUMBER                             ,
          null,   --TAX_REGISTRATION_NUMBER                                   ,
          null,   --TAX_HOLD_CODE                                             ,
          null,   --TAX_HOLD_RELEASED_CODE                                    ,
          null,   --LINE_AMT                                                  ,
          zx_lines_summary.TAX_JURISDICTION_CODE                ,
          zx_rates_b.tax_rate_code, --null, --TAX_RATE_NAME     ,
          zx_rates_b.rate_type_code, --null, --TAX_RATE_TYPE         ,
          null,   --TAX_DETERMINE_DATE                          ,
          zx_lines_summary.CANCEL_FLAG                          ,
          zx_lines_summary.EVENT_CLASS_CODE                     ,
          null,   --EVENT_TYPE_CODE                                           ,
          p_service                                                           ,
          'N',    --ERROR_FLAG                                             ,
          g_party_rec.prod_family_grp_code||' SUMMARY' --ERROR_MESSAGE
          FROM    ZX_LINES_SUMMARY,
                  ZX_RATES_B
          WHERE   trx_id = p_transaction_id
          AND     application_id   = l_application_id
          AND     entity_code      = l_entity_code
          AND     event_class_code = l_event_class_code
          AND     zx_lines_summary.tax_rate_id(+) = zx_rates_b.tax_rate_id;


      --------------------------------------------------
      -- Insert ZX_REC_NREC_DIST data
      --------------------------------------------------
      /*select count(*) into l_dummy from zx_rec_nrec_dist where trx_id =p_transaction_id;
      write_message('The number of rows in zx_rec_nrec_dist for transaction id '||to_char(p_transaction_id)||' are '||to_char(l_dummy));*/
        INSERT INTO ZX_TEST_API_GT(
          SUITE_NUMBER                                ,
          CASE_NUMBER                                 ,
          TRX_ID                                      ,
          TRX_NUMBER                                  ,
          TRX_LINE_NUMBER                             ,
          TRX_DATE                                    ,
          TRX_CURRENCY_CODE                           ,
          SUMMARY_TAX_LINE_ID                         ,
          TAX_LINE_ID                                 ,
          TAX_REGIME_CODE                             ,
          TAX_JURISDICTION_ID                         ,
          TAX                                         ,
          TAX_STATUS_CODE                             ,
          TAX_RATE_ID                                 ,
          TAX_RATE_CODE                               ,
          TAX_RATE                                    ,
          TAX_AMT                                     ,
          TAXABLE_AMT                                 ,
          REC_TAX_AMT                                 ,
          NREC_TAX_AMT                                ,
          TAX_AMT_FUNCL_CURR                          ,
          TOTAL_REC_TAX_AMT                           ,
          TOTAL_NREC_TAX_AMT                          ,
          TOTAL_REC_TAX_AMT_FUNCL_CURR                ,
          TOTAL_NREC_TAX_AMT_FUNCL_CURR               ,
          SELF_ASSESSED_FLAG                          ,
          MANUALLY_ENTERED_FLAG                       ,
          LINE_AMT_INCLUDES_TAX_FLAG                  ,
          TAXABLE_AMT_FUNCL_CURR                      ,
          REC_TAX_AMT_FUNCL_CURR                      ,
          NREC_TAX_AMT_FUNCL_CURR                     ,
          TAX_AMT_INCLUDED_FLAG                       ,
          TAX_EXEMPTION_ID                            ,
          EXEMPTION_RATE                              ,
          EXEMPT_REASON_CODE                          ,
          TAX_APPORTIONMENT_LINE_NUMBER               ,
          TAX_REGISTRATION_NUMBER                     ,
          TAX_HOLD_CODE                               ,
          TAX_HOLD_RELEASED_CODE                      ,
          LINE_AMT                                    ,
          TAX_JURISDICTION_CODE                       ,
          TAX_RATE_NAME                               ,
          TAX_RATE_TYPE                               ,
          TAX_DETERMINE_DATE                          ,
          CANCEL_FLAG                                 ,
          EVENT_CLASS_CODE                            ,
          EVENT_TYPE_CODE                             ,
          ETAX_API                                    ,
          ERROR_FLAG                                  ,
          ERROR_MESSAGE                               )
   SELECT p_suite                                    ,
          p_case                                     ,
          p_transaction_id                           ,
          null                                       ,   --TRX_NUMBER
          zx_rec_nrec_dist.trx_line_id               ,   --zx_rec_nrec_dist.TRX_LINE_NUMBER
          null                                       ,   --TRX_DATE
          null                                       ,   --TRX_CURRENCY_CODE
          zx_rec_nrec_dist.SUMMARY_TAX_LINE_ID       ,
          zx_rec_nrec_dist.TAX_LINE_ID               ,
          zx_rec_nrec_dist.TAX_REGIME_CODE           ,
          null                                       ,   --TAX_JURISDICTION_ID
          zx_rec_nrec_dist.TAX                       ,
          zx_rec_nrec_dist.TAX_STATUS_CODE           ,
          zx_rec_nrec_dist.TAX_RATE_ID               ,
          zx_rec_nrec_dist.TAX_RATE_CODE             ,
          zx_rec_nrec_dist.TAX_RATE                  ,
          zx_rec_nrec_dist.REC_NREC_TAX_AMT          ,   --TAX_AMT --BUG 4376481, Is this the Tax Amt?
          zx_rec_nrec_dist.TAXABLE_AMT               ,
          null                                       ,   --REC_TAX_AMT
          null                                       ,   --NREC_TAX_AMT
          null                                       ,   --zx_rec_nrec_dist.TAX_AMT_FUNCL_CURR
          null                                       ,   --TOTAL_REC_TAX_AMT
          null                                       ,   --TOTAL_NREC_TAX_AMT
          null                                       ,   --TOTAL_REC_TAX_AMT_FUNCL_CURR
          null                                       ,   --TOTAL_NREC_TAX_AMT_FUNCL_CURR
          null                                       ,   --zx_rec_nrec_dist.SELF_ASSESSED_FLAG
          null                                       ,   --MANUALLY_ENTERED_FLAG
          null                                       ,   --LINE_AMT_INCLUDES_TAX_FLAG
          null                                       ,   --TAXABLE_AMT_FUNCL_CURR
          null                                       ,   --REC_TAX_AMT_FUNCL_CURR
          null                                       ,   --NREC_TAX_AMT_FUNCL_CURR
          null                                       ,   --TAX_AMT_INCLUDED_FLAG
          null                                       ,   --TAX_EXEMPTION_ID
          null                                       ,   --EXEMPTION_RATE
          null                                       ,   --EXEMPT_REASON_CODE
          null                                       ,   --TAX_APPORTIONMENT_LINE_NUMBER
          null                                       ,   --TAX_REGISTRATION_NUMBER
          null                                       ,   --TAX_HOLD_CODE
          null                                       ,   --TAX_HOLD_RELEASED_CODE
          null                                       ,   --LINE_AMT
          null                                       ,   --TAX_JURISDICTION_CODE
          null                                       ,   --TAX_RATE_NAME
          null                                       ,   --TAX_RATE_TYPE
          null                                       ,   --TAX_DETERMINE_DATE
          null                                       ,   --CANCEL_FLAG
          zx_rec_nrec_dist.EVENT_CLASS_CODE          ,
          zx_rec_nrec_dist.EVENT_TYPE_CODE           ,
          p_service                                  ,
          'N'                                        ,    --ERROR_FLAG
          g_party_rec.prod_family_grp_code||' DIST'       --ERROR_MESSAGE
          FROM    zx_rec_nrec_dist,
                  zx_rates_b
          WHERE   trx_id = p_transaction_id
          AND     application_id   = l_application_id
          AND     entity_code      = l_entity_code
          AND     event_class_code = l_event_class_code
          AND     zx_rec_nrec_dist.tax_rate_id(+) = zx_rates_b.tax_rate_id;

     ELSIF p_error_flag = 'Y' THEN
       Write_Message('Error messages will be inserted in the Report Table');
       -------------------------------------------------------------------
       -- IF the Error Flag indicates, error message will be inserted
       -- in Report Table.
       --------------------------------------------------------------------
       INSERT INTO ZX_TEST_API_GT
         (SUITE_NUMBER                                ,
          CASE_NUMBER                                 ,
          TRX_ID                                      ,
          TRX_NUMBER                                  ,
          TRX_LINE_NUMBER                             ,
          TRX_DATE                                    ,
          TRX_CURRENCY_CODE                           ,
          SUMMARY_TAX_LINE_ID                         ,
          TAX_LINE_ID                                 ,
          TAX_REGIME_CODE                             ,
          TAX_JURISDICTION_ID                         ,
          TAX                                         ,
          TAX_STATUS_CODE                             ,
          TAX_RATE_ID                                 ,
          TAX_RATE_CODE                               ,
          TAX_RATE                                    ,
          TAX_AMT                                     ,
          TAXABLE_AMT                                 ,
          REC_TAX_AMT                                 ,
          NREC_TAX_AMT                                ,
          TAX_AMT_FUNCL_CURR                          ,
          TOTAL_REC_TAX_AMT                           ,
          TOTAL_NREC_TAX_AMT                          ,
          TOTAL_REC_TAX_AMT_FUNCL_CURR                ,
          TOTAL_NREC_TAX_AMT_FUNCL_CURR               ,
          SELF_ASSESSED_FLAG                          ,
          MANUALLY_ENTERED_FLAG                       ,
          LINE_AMT_INCLUDES_TAX_FLAG                  ,
          TAXABLE_AMT_FUNCL_CURR                      ,
          REC_TAX_AMT_FUNCL_CURR                      ,
          NREC_TAX_AMT_FUNCL_CURR                     ,
          TAX_AMT_INCLUDED_FLAG                       ,
          TAX_EXEMPTION_ID                            ,
          EXEMPTION_RATE                              ,
          EXEMPT_REASON_CODE                          ,
          TAX_APPORTIONMENT_LINE_NUMBER               ,
          TAX_REGISTRATION_NUMBER                     ,
          TAX_HOLD_CODE                               ,
          TAX_HOLD_RELEASED_CODE                      ,
          LINE_AMT                                    ,
          TAX_JURISDICTION_CODE                       ,
          TAX_RATE_NAME                               ,
          TAX_RATE_TYPE                               ,
          TAX_DETERMINE_DATE                          ,
          CANCEL_FLAG                                 ,
          EVENT_CLASS_CODE                            ,
          EVENT_TYPE_CODE                             ,
          ETAX_API                                    ,
          ERROR_FLAG                                  ,
          ERROR_MESSAGE)
          VALUES
         (p_suite                                                  ,
          p_case                                                   ,
          p_transaction_id,   --TRX_ID                             ,
          null,   --TRX_NUMBER                                     ,
          null,   --TRX_LINE_NUMBER                                ,
          null,   --TRX_DATE                                       ,
          null,   --TRX_CURRENCY_CODE                              ,
          null,   --SUMMARY_TAX_LINE_ID                            ,
          null,   --TAX_LINE_ID                                    ,
          null,   --TAX_REGIME_CODE                                ,
          null,   --TAX_JURISDICTION_ID                            ,
          null,   --TAX                                            ,
          null,   --TAX_STATUS_CODE                                ,
          null,   --TAX_RATE_ID                                    ,
          null,   --TAX_RATE_CODE                                  ,
          null,   --TAX_RATE                                       ,
          null,   --TAX_AMT                                        ,
          null,   --TAXABLE_AMT                                    ,
          null,   --REC_TAX_AMT                                    ,
          null,   --NREC_TAX_AMT                                   ,
          null,   --TAX_AMT_FUNCL_CURR                             ,
          null,   --TOTAL_REC_TAX_AMT                              ,
          null,   --TOTAL_NREC_TAX_AMT                             ,
          null,   --TOTAL_REC_TAX_AMT_FUNCL_CURR                   ,
          null,   --TOTAL_NREC_TAX_AMT_FUNCL_CURR                  ,
          null,   --SELF_ASSESSED_FLAG                             ,
          null,   --MANUALLY_ENTERED_FLAG                          ,
          null,   --LINE_AMT_INCLUDES_TAX_FLAG                     ,
          null,   --TAXABLE_AMT_FUNCL_CURR                         ,
          null,   --REC_TAX_AMT_FUNCL_CURR                         ,
          null,   --NREC_TAX_AMT_FUNCL_CURR                        ,
          null,   --TAX_AMT_INCLUDED_FLAG                          ,
          null,   --TAX_EXEMPTION_ID                               ,
          null,   --EXEMPTION_RATE                                 ,
          null,   --EXEMPT_REASON_CODE                             ,
          null,   --TAX_APPORTIONMENT_LINE_NUMBER                  ,
          null,   --TAX_REGISTRATION_NUMBER                        ,
          null,   --TAX_HOLD_CODE                                  ,
          null,   --TAX_HOLD_RELEASED_CODE                         ,
          null,   --LINE_AMT                                       ,
          null,   --TAX_JURISDICTION_CODE                          ,
          null,   --TAX_RATE_NAME                                  ,
          null,   --TAX_RATE_TYPE                                  ,
          null,   --TAX_DETERMINE_DATE                             ,
          null,   --CANCEL_FLAG                                    ,
          null,   --EVENT_CLASS_CODE                               ,
          null,   --EVENT_TYPE_CODE                                ,
          p_service                                                ,
          p_error_flag                                             ,
          p_error_message);

     END IF;
  END Populate_Report_Table;


/* ===========================================================================*
 | PROCEDURE populate_trx_header_cache : Caches the Transaction Header Info   |
 |                                       from a row in g_suite_rec_tbl        |
 * ===========================================================================*/
  PROCEDURE populate_trx_header_cache(p_header_row_id IN NUMBER) IS

  BEGIN
    g_header_cache_counter := g_header_cache_counter + 1;
    --------------------------------------------
    -- Put the Header Information in the Cache
    -------------------------------------------
    g_trx_headers_cache_rec_tbl.INTERNAL_ORGANIZATION_ID(g_header_cache_counter)       :=g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.APPLICATION_ID(g_header_cache_counter)                 :=g_suite_rec_tbl.APPLICATION_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.ENTITY_CODE(g_header_cache_counter)                    :=g_suite_rec_tbl.ENTITY_CODE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.EVENT_CLASS_CODE(g_header_cache_counter)               :=g_suite_rec_tbl.EVENT_CLASS_CODE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.EVENT_TYPE_CODE(g_header_cache_counter)                :=g_suite_rec_tbl.EVENT_TYPE_CODE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_ID(g_header_cache_counter)                         :=g_suite_rec_tbl.TRX_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_DATE(g_header_cache_counter)                       :=g_suite_rec_tbl.TRX_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_DOC_REVISION(g_header_cache_counter)               :=g_suite_rec_tbl.TRX_DOC_REVISION(p_header_row_id);
    g_trx_headers_cache_rec_tbl.LEDGER_ID(g_header_cache_counter)                      :=g_suite_rec_tbl.LEDGER_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_CURRENCY_CODE(g_header_cache_counter)              :=g_suite_rec_tbl.TRX_CURRENCY_CODE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.CURRENCY_CONVERSION_DATE(g_header_cache_counter)       :=g_suite_rec_tbl.CURRENCY_CONVERSION_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.CURRENCY_CONVERSION_RATE(g_header_cache_counter)       :=g_suite_rec_tbl.CURRENCY_CONVERSION_RATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.CURRENCY_CONVERSION_TYPE(g_header_cache_counter)       :=g_suite_rec_tbl.CURRENCY_CONVERSION_TYPE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.MINIMUM_ACCOUNTABLE_UNIT(g_header_cache_counter)       :=g_suite_rec_tbl.MINIMUM_ACCOUNTABLE_UNIT(p_header_row_id);
    g_trx_headers_cache_rec_tbl.PRECISION(g_header_cache_counter)                      :=g_suite_rec_tbl.PRECISION(p_header_row_id);
    g_trx_headers_cache_rec_tbl.LEGAL_ENTITY_ID(g_header_cache_counter)                :=g_suite_rec_tbl.LEGAL_ENTITY_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.ROUNDING_SHIP_TO_PARTY_ID(g_header_cache_counter)      :=g_suite_rec_tbl.ROUNDING_SHIP_TO_PARTY_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.ROUNDING_SHIP_FROM_PARTY_ID(g_header_cache_counter)    :=g_suite_rec_tbl.ROUNDING_SHIP_FROM_PARTY_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.ROUNDING_BILL_TO_PARTY_ID(g_header_cache_counter)      :=g_suite_rec_tbl.ROUNDING_BILL_TO_PARTY_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.ROUNDING_BILL_FROM_PARTY_ID(g_header_cache_counter)    :=g_suite_rec_tbl.ROUNDING_BILL_FROM_PARTY_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(g_header_cache_counter)     :=g_suite_rec_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(g_header_cache_counter)   :=g_suite_rec_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RNDG_BILL_TO_PARTY_SITE_ID(g_header_cache_counter)     :=g_suite_rec_tbl.RNDG_BILL_TO_PARTY_SITE_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(g_header_cache_counter)   :=g_suite_rec_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.ESTABLISHMENT_ID(g_header_cache_counter)               :=g_suite_rec_tbl.ESTABLISHMENT_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RECEIVABLES_TRX_TYPE_ID(g_header_cache_counter)        :=g_suite_rec_tbl.RECEIVABLES_TRX_TYPE_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RELATED_DOC_APPLICATION_ID(g_header_cache_counter)     :=g_suite_rec_tbl.RELATED_DOC_APPLICATION_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RELATED_DOC_ENTITY_CODE(g_header_cache_counter)        :=g_suite_rec_tbl.RELATED_DOC_ENTITY_CODE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RELATED_DOC_EVENT_CLASS_CODE(g_header_cache_counter)   :=g_suite_rec_tbl.RELATED_DOC_EVENT_CLASS_CODE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RELATED_DOC_TRX_ID(g_header_cache_counter)             :=g_suite_rec_tbl.RELATED_DOC_TRX_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RELATED_DOC_NUMBER(g_header_cache_counter)             :=g_suite_rec_tbl.RELATED_DOC_NUMBER(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RELATED_DOC_DATE(g_header_cache_counter)               :=g_suite_rec_tbl.RELATED_DOC_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.DEFAULT_TAXATION_COUNTRY(g_header_cache_counter)       :=g_suite_rec_tbl.DEFAULT_TAXATION_COUNTRY(p_header_row_id);
    g_trx_headers_cache_rec_tbl.QUOTE_FLAG(g_header_cache_counter)                      :=g_suite_rec_tbl.QUOTE_FLAG(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_NUMBER(g_header_cache_counter)                     :=g_suite_rec_tbl.TRX_NUMBER(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_DESCRIPTION(g_header_cache_counter)                :=g_suite_rec_tbl.TRX_DESCRIPTION(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_COMMUNICATED_DATE(g_header_cache_counter)          :=g_suite_rec_tbl.TRX_COMMUNICATED_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.BATCH_SOURCE_ID(g_header_cache_counter)                :=g_suite_rec_tbl.BATCH_SOURCE_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.BATCH_SOURCE_NAME(g_header_cache_counter)              :=g_suite_rec_tbl.BATCH_SOURCE_NAME(p_header_row_id);
    g_trx_headers_cache_rec_tbl.DOC_SEQ_ID(g_header_cache_counter)                     :=g_suite_rec_tbl.DOC_SEQ_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.DOC_SEQ_NAME(g_header_cache_counter)                   :=g_suite_rec_tbl.DOC_SEQ_NAME(p_header_row_id);
    g_trx_headers_cache_rec_tbl.DOC_SEQ_VALUE(g_header_cache_counter)                  :=g_suite_rec_tbl.DOC_SEQ_VALUE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_DUE_DATE(g_header_cache_counter)                   :=g_suite_rec_tbl.TRX_DUE_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_TYPE_DESCRIPTION(g_header_cache_counter)           :=g_suite_rec_tbl.TRX_TYPE_DESCRIPTION(p_header_row_id);
    g_trx_headers_cache_rec_tbl.DOCUMENT_SUB_TYPE(g_header_cache_counter)              :=g_suite_rec_tbl.DOCUMENT_SUB_TYPE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.SUPPLIER_TAX_INVOICE_NUMBER(g_header_cache_counter)    :=g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_NUMBER(p_header_row_id);
    g_trx_headers_cache_rec_tbl.SUPPLIER_TAX_INVOICE_DATE(g_header_cache_counter)      :=g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.SUPPLIER_EXCHANGE_RATE(g_header_cache_counter)         :=g_suite_rec_tbl.SUPPLIER_EXCHANGE_RATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TAX_INVOICE_DATE(g_header_cache_counter)               :=g_suite_rec_tbl.TAX_INVOICE_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TAX_INVOICE_NUMBER(g_header_cache_counter)             :=g_suite_rec_tbl.TAX_INVOICE_NUMBER(p_header_row_id);
    g_trx_headers_cache_rec_tbl.PORT_OF_ENTRY_CODE(g_header_cache_counter)             :=g_suite_rec_tbl.PORT_OF_ENTRY_CODE(g_header_cache_counter);

  END populate_trx_header_cache;


/* ===========================================================================*
 | PROCEDURE populate_trx_lines_cache : Caches the Transaction Line Info      |
 |                                       from a row in g_suite_rec_tbl        |
 * ===========================================================================*/
  PROCEDURE populate_trx_lines_cache(p_header_row_id IN NUMBER,
                                     p_line_row_id IN NUMBER) IS

  BEGIN
    g_line_cache_counter := g_line_cache_counter+1;
    --------------------------------------------
    -- Put the Line Information in the Cache
    -------------------------------------------
    g_trx_lines_cache_rec_tbl.APPLICATION_ID(g_line_cache_counter)               := g_suite_rec_tbl.APPLICATION_ID(p_header_row_id);
    g_trx_lines_cache_rec_tbl.ENTITY_CODE(g_line_cache_counter)                  := g_suite_rec_tbl.ENTITY_CODE(p_header_row_id);
    g_trx_lines_cache_rec_tbl.EVENT_CLASS_CODE(g_line_cache_counter)             := g_suite_rec_tbl.EVENT_CLASS_CODE(p_header_row_id);
    g_trx_lines_cache_rec_tbl.TRX_ID(g_line_cache_counter)                       := g_suite_rec_tbl.TRX_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.TRX_LINE_ID(g_line_cache_counter)                  := g_suite_rec_tbl.TRX_LINE_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.LINE_LEVEL_ACTION(g_line_cache_counter)            := g_suite_rec_tbl.LINE_LEVEL_ACTION(p_line_row_id);
    g_trx_lines_cache_rec_tbl.TRX_LINE_TYPE(g_line_cache_counter)                := g_suite_rec_tbl.TRX_LINE_TYPE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.TRX_LINE_DATE(g_line_cache_counter)                := g_suite_rec_tbl.TRX_LINE_DATE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.TRX_BUSINESS_CATEGORY(g_line_cache_counter)        := g_suite_rec_tbl.TRX_BUSINESS_CATEGORY(p_line_row_id);
    g_trx_lines_cache_rec_tbl.LINE_INTENDED_USE(g_line_cache_counter)            := g_suite_rec_tbl.LINE_INTENDED_USE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.USER_DEFINED_FISC_CLASS(g_line_cache_counter)      := g_suite_rec_tbl.USER_DEFINED_FISC_CLASS(p_line_row_id);
    g_trx_lines_cache_rec_tbl.LINE_AMT(g_line_cache_counter)                     := g_suite_rec_tbl.LINE_AMT(p_line_row_id);
    g_trx_lines_cache_rec_tbl.TRX_LINE_QUANTITY(g_line_cache_counter)            := g_suite_rec_tbl.TRX_LINE_QUANTITY(p_line_row_id);
    g_trx_lines_cache_rec_tbl.UNIT_PRICE(g_line_cache_counter)                   := g_suite_rec_tbl.UNIT_PRICE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.PRODUCT_ID(g_line_cache_counter)                   := g_suite_rec_tbl.PRODUCT_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.PRODUCT_FISC_CLASSIFICATION(g_line_cache_counter)  := g_suite_rec_tbl.PRODUCT_FISC_CLASSIFICATION(p_line_row_id);
    g_trx_lines_cache_rec_tbl.PRODUCT_ORG_ID(g_line_cache_counter)               := g_suite_rec_tbl.PRODUCT_ORG_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.UOM_CODE(g_line_cache_counter)                     := g_suite_rec_tbl.UOM_CODE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.PRODUCT_TYPE(g_line_cache_counter)                 := g_suite_rec_tbl.PRODUCT_TYPE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.PRODUCT_CODE(g_line_cache_counter)                 := g_suite_rec_tbl.PRODUCT_CODE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.PRODUCT_CATEGORY(g_line_cache_counter)             := g_suite_rec_tbl.PRODUCT_CATEGORY(p_line_row_id);
    g_trx_lines_cache_rec_tbl.MERCHANT_PARTY_ID(g_line_cache_counter)            := g_suite_rec_tbl.MERCHANT_PARTY_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.ACCOUNT_CCID(g_line_cache_counter)                 := g_suite_rec_tbl.ACCOUNT_CCID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.ACCOUNT_STRING(g_line_cache_counter)               := g_suite_rec_tbl.ACCOUNT_STRING(p_line_row_id);
    g_trx_lines_cache_rec_tbl.REF_DOC_APPLICATION_ID(g_line_cache_counter)       := g_suite_rec_tbl.REF_DOC_APPLICATION_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.REF_DOC_ENTITY_CODE(g_line_cache_counter)          := g_suite_rec_tbl.REF_DOC_ENTITY_CODE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.REF_DOC_EVENT_CLASS_CODE(g_line_cache_counter)     := g_suite_rec_tbl.REF_DOC_EVENT_CLASS_CODE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.REF_DOC_TRX_ID(g_line_cache_counter)               := g_suite_rec_tbl.REF_DOC_TRX_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.REF_DOC_LINE_ID(g_line_cache_counter)              := g_suite_rec_tbl.REF_DOC_LINE_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.REF_DOC_LINE_QUANTITY(g_line_cache_counter)        := g_suite_rec_tbl.REF_DOC_LINE_QUANTITY(p_line_row_id);
    g_trx_lines_cache_rec_tbl.APPLIED_FROM_APPLICATION_ID(g_line_cache_counter)  := g_suite_rec_tbl.APPLIED_FROM_APPLICATION_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.APPLIED_FROM_ENTITY_CODE(g_line_cache_counter)     := g_suite_rec_tbl.APPLIED_FROM_ENTITY_CODE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.APPLIED_FROM_EVENT_CLASS_CODE(g_line_cache_counter):= g_suite_rec_tbl.APPLIED_FROM_EVENT_CLASS_CODE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.APPLIED_FROM_TRX_ID(g_line_cache_counter)          := g_suite_rec_tbl.APPLIED_FROM_TRX_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.APPLIED_FROM_LINE_ID(g_line_cache_counter)         := g_suite_rec_tbl.APPLIED_FROM_LINE_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.ADJUSTED_DOC_APPLICATION_ID(g_line_cache_counter)  := g_suite_rec_tbl.ADJUSTED_DOC_APPLICATION_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.adjusted_doc_entity_code(g_line_cache_counter)     := g_suite_rec_tbl.adjusted_doc_entity_code(p_line_row_id);
    g_trx_lines_cache_rec_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(g_line_cache_counter):= g_suite_rec_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.ADJUSTED_DOC_TRX_ID(g_line_cache_counter)          := g_suite_rec_tbl.ADJUSTED_DOC_TRX_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.ADJUSTED_DOC_LINE_ID(g_line_cache_counter)         := g_suite_rec_tbl.ADJUSTED_DOC_LINE_ID(p_line_row_id);
    g_trx_lines_cache_rec_tbl.TRX_LINE_NUMBER(g_line_cache_counter)              := g_suite_rec_tbl.TRX_LINE_NUMBER(p_line_row_id);
    g_trx_lines_cache_rec_tbl.TRX_LINE_DESCRIPTION(g_line_cache_counter)         := g_suite_rec_tbl.TRX_LINE_DESCRIPTION(p_line_row_id);
    g_trx_lines_cache_rec_tbl.TRX_LINE_GL_DATE(g_line_cache_counter)             := g_suite_rec_tbl.TRX_LINE_GL_DATE(p_line_row_id);
    g_trx_lines_cache_rec_tbl.LINE_AMT_INCLUDES_TAX_FLAG(g_line_cache_counter)   := g_suite_rec_tbl.LINE_AMT_INCLUDES_TAX_FLAG(p_line_row_id);
    g_trx_lines_cache_rec_tbl.TRX_LEVEL_TYPE(g_line_cache_counter)               := g_suite_rec_tbl.TRX_LEVEL_TYPE(p_line_row_id);

  END populate_trx_lines_cache;


/* ===========================================================================*
 | PROCEDURE populate_dist_lines_cache : Caches the Distribution Lines Info   |
 |                                       from a row in g_suite_rec_tbl        |
 * ===========================================================================*/
  PROCEDURE populate_dist_lines_cache(p_dist_row_id IN NUMBER) IS

  l_dist_cache_counter NUMBER;
  BEGIN
    g_dist_cache_counter := g_dist_cache_counter + 1;
    -----------------------------------------------------
    -- Put the Distribution Line Information in the Cache
    -----------------------------------------------------
    g_dist_lines_cache_rec_tbl.APPLICATION_ID(g_dist_cache_counter)        :=g_suite_rec_tbl.APPLICATION_ID(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.ENTITY_CODE(g_dist_cache_counter)           :=g_suite_rec_tbl.ENTITY_CODE(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.EVENT_CLASS_CODE(g_dist_cache_counter)      :=g_suite_rec_tbl.EVENT_CLASS_CODE(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.EVENT_TYPE_CODE(g_dist_cache_counter)       :=g_suite_rec_tbl.EVENT_TYPE_CODE(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.TRX_ID(g_dist_cache_counter)                :=g_suite_rec_tbl.TRX_ID(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.TRX_LINE_ID(g_dist_cache_counter)           :=g_suite_rec_tbl.TRX_LINE_ID(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.TRX_LINE_QUANTITY(g_dist_cache_counter)     :=g_suite_rec_tbl.TRX_LINE_QUANTITY(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.TRX_LEVEL_TYPE(g_dist_cache_counter)        :=g_suite_rec_tbl.TRX_LEVEL_TYPE(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_ID(g_dist_cache_counter)      :=g_suite_rec_tbl.TRX_LINE_DIST_ID(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_AMT(g_dist_cache_counter)     :=g_suite_rec_tbl.TRX_LINE_DIST_AMT(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_QUANTITY(g_dist_cache_counter):=g_suite_rec_tbl.TRX_LINE_DIST_QUANTITY(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.DIST_LEVEL_ACTION(g_dist_cache_counter)     :=g_suite_rec_tbl.DIST_LEVEL_ACTION(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_DATE(g_dist_cache_counter)    :=g_suite_rec_tbl.TRX_LINE_DIST_DATE(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.ITEM_DIST_NUMBER(g_dist_cache_counter)      :=g_suite_rec_tbl.ITEM_DIST_NUMBER(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.DIST_INTENDED_USE(g_dist_cache_counter)     :=g_suite_rec_tbl.DIST_INTENDED_USE(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.TAX_INCLUSION_FLAG(g_dist_cache_counter)    :=g_suite_rec_tbl.TAX_INCLUSION_FLAG(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.TAX_CODE(g_dist_cache_counter)              :=g_suite_rec_tbl.TAX_CODE(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.TASK_ID(g_dist_cache_counter)               :=g_suite_rec_tbl.TASK_ID(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.AWARD_ID(g_dist_cache_counter)              :=g_suite_rec_tbl.AWARD_ID(p_dist_row_id);
    g_dist_lines_cache_rec_tbl.PROJECT_ID(g_dist_cache_counter)            :=g_suite_rec_tbl.PROJECT_ID(p_dist_row_id);
  END populate_dist_lines_cache;


/* ============================================================================*
 | PROCEDURE update_trx_header_cache : Update the Cache Transaction Header Info|
 |                                     from a row in g_suite_rec_tbl           |
 * ===========================================================================*/
PROCEDURE update_trx_header_cache(p_header_row_id IN NUMBER) IS
  l_updateable_row NUMBER;
  i NUMBER;
  BEGIN
    -----------------------------------------------------
    -- Loop to find the Header Row with Same Trx_id
    -- That will be updated
    -----------------------------------------------------
    FOR i in g_trx_headers_cache_rec_tbl.trx_id.FIRST..g_trx_headers_cache_rec_tbl.trx_id.LAST LOOP
      If g_trx_headers_cache_rec_tbl.trx_id(i) = g_suite_rec_tbl.TRX_ID(p_header_row_id) THEN
        l_updateable_row := i;
        EXIT;
      END IF;
    END LOOP;
    write_message('=========================================');
    write_message('==Updating Transaction Header Cache');
    Write_message('==Row to be updated is'||l_updateable_row);
    write_message('=========================================');
    --------------------------------------------
    -- Update the Header Information in the Cache
    -------------------------------------------
    g_trx_headers_cache_rec_tbl.INTERNAL_ORGANIZATION_ID(l_updateable_row)       :=g_suite_rec_tbl.INTERNAL_ORGANIZATION_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.APPLICATION_ID(l_updateable_row)                 :=g_suite_rec_tbl.APPLICATION_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.ENTITY_CODE(l_updateable_row)                    :=g_suite_rec_tbl.ENTITY_CODE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.EVENT_CLASS_CODE(l_updateable_row)               :=g_suite_rec_tbl.EVENT_CLASS_CODE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.EVENT_TYPE_CODE(l_updateable_row)                :=g_suite_rec_tbl.EVENT_TYPE_CODE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_ID(l_updateable_row)                         :=g_suite_rec_tbl.TRX_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_DATE(l_updateable_row)                       :=g_suite_rec_tbl.TRX_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_DOC_REVISION(l_updateable_row)               :=g_suite_rec_tbl.TRX_DOC_REVISION(p_header_row_id);
    g_trx_headers_cache_rec_tbl.LEDGER_ID(l_updateable_row)                      :=g_suite_rec_tbl.LEDGER_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_CURRENCY_CODE(l_updateable_row)              :=g_suite_rec_tbl.TRX_CURRENCY_CODE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.CURRENCY_CONVERSION_DATE(l_updateable_row)       :=g_suite_rec_tbl.CURRENCY_CONVERSION_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.CURRENCY_CONVERSION_RATE(l_updateable_row)       :=g_suite_rec_tbl.CURRENCY_CONVERSION_RATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.CURRENCY_CONVERSION_TYPE(l_updateable_row)       :=g_suite_rec_tbl.CURRENCY_CONVERSION_TYPE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.MINIMUM_ACCOUNTABLE_UNIT(l_updateable_row)       :=g_suite_rec_tbl.MINIMUM_ACCOUNTABLE_UNIT(p_header_row_id);
    g_trx_headers_cache_rec_tbl.PRECISION(l_updateable_row)                      :=g_suite_rec_tbl.PRECISION(p_header_row_id);
    g_trx_headers_cache_rec_tbl.LEGAL_ENTITY_ID(l_updateable_row)                :=g_suite_rec_tbl.LEGAL_ENTITY_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.ROUNDING_SHIP_TO_PARTY_ID(l_updateable_row)      :=g_suite_rec_tbl.ROUNDING_SHIP_TO_PARTY_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.ROUNDING_SHIP_FROM_PARTY_ID(l_updateable_row)    :=g_suite_rec_tbl.ROUNDING_SHIP_FROM_PARTY_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.ROUNDING_BILL_TO_PARTY_ID(l_updateable_row)      :=g_suite_rec_tbl.ROUNDING_BILL_TO_PARTY_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.ROUNDING_BILL_FROM_PARTY_ID(l_updateable_row)    :=g_suite_rec_tbl.ROUNDING_BILL_FROM_PARTY_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(l_updateable_row)     :=g_suite_rec_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(l_updateable_row)   :=g_suite_rec_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RNDG_BILL_TO_PARTY_SITE_ID(l_updateable_row)     :=g_suite_rec_tbl.RNDG_BILL_TO_PARTY_SITE_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(l_updateable_row)   :=g_suite_rec_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.ESTABLISHMENT_ID(l_updateable_row)               :=g_suite_rec_tbl.ESTABLISHMENT_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RECEIVABLES_TRX_TYPE_ID(l_updateable_row)        :=g_suite_rec_tbl.RECEIVABLES_TRX_TYPE_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RELATED_DOC_APPLICATION_ID(l_updateable_row)     :=g_suite_rec_tbl.RELATED_DOC_APPLICATION_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RELATED_DOC_ENTITY_CODE(l_updateable_row)        :=g_suite_rec_tbl.RELATED_DOC_ENTITY_CODE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RELATED_DOC_EVENT_CLASS_CODE(l_updateable_row)   :=g_suite_rec_tbl.RELATED_DOC_EVENT_CLASS_CODE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RELATED_DOC_TRX_ID(l_updateable_row)             :=g_suite_rec_tbl.RELATED_DOC_TRX_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RELATED_DOC_NUMBER(l_updateable_row)             :=g_suite_rec_tbl.RELATED_DOC_NUMBER(p_header_row_id);
    g_trx_headers_cache_rec_tbl.RELATED_DOC_DATE(l_updateable_row)               :=g_suite_rec_tbl.RELATED_DOC_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.DEFAULT_TAXATION_COUNTRY(l_updateable_row)       :=g_suite_rec_tbl.DEFAULT_TAXATION_COUNTRY(p_header_row_id);
    g_trx_headers_cache_rec_tbl.QUOTE_FLAG(l_updateable_row)                     :=g_suite_rec_tbl.QUOTE_FLAG(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_NUMBER(l_updateable_row)                     :=g_suite_rec_tbl.TRX_NUMBER(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_DESCRIPTION(l_updateable_row)                :=g_suite_rec_tbl.TRX_DESCRIPTION(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_COMMUNICATED_DATE(l_updateable_row)          :=g_suite_rec_tbl.TRX_COMMUNICATED_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.BATCH_SOURCE_ID(l_updateable_row)                :=g_suite_rec_tbl.BATCH_SOURCE_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.BATCH_SOURCE_NAME(l_updateable_row)              :=g_suite_rec_tbl.BATCH_SOURCE_NAME(p_header_row_id);
    g_trx_headers_cache_rec_tbl.DOC_SEQ_ID(l_updateable_row)                     :=g_suite_rec_tbl.DOC_SEQ_ID(p_header_row_id);
    g_trx_headers_cache_rec_tbl.DOC_SEQ_NAME(l_updateable_row)                   :=g_suite_rec_tbl.DOC_SEQ_NAME(p_header_row_id);
    g_trx_headers_cache_rec_tbl.DOC_SEQ_VALUE(l_updateable_row)                  :=g_suite_rec_tbl.DOC_SEQ_VALUE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_DUE_DATE(l_updateable_row)                   :=g_suite_rec_tbl.TRX_DUE_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TRX_TYPE_DESCRIPTION(l_updateable_row)           :=g_suite_rec_tbl.TRX_TYPE_DESCRIPTION(p_header_row_id);
    g_trx_headers_cache_rec_tbl.DOCUMENT_SUB_TYPE(l_updateable_row)              :=g_suite_rec_tbl.DOCUMENT_SUB_TYPE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.SUPPLIER_TAX_INVOICE_NUMBER(l_updateable_row)    :=g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_NUMBER(p_header_row_id);
    g_trx_headers_cache_rec_tbl.SUPPLIER_TAX_INVOICE_DATE(l_updateable_row)      :=g_suite_rec_tbl.SUPPLIER_TAX_INVOICE_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.SUPPLIER_EXCHANGE_RATE(l_updateable_row)         :=g_suite_rec_tbl.SUPPLIER_EXCHANGE_RATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TAX_INVOICE_DATE(l_updateable_row)               :=g_suite_rec_tbl.TAX_INVOICE_DATE(p_header_row_id);
    g_trx_headers_cache_rec_tbl.TAX_INVOICE_NUMBER(l_updateable_row)             :=g_suite_rec_tbl.TAX_INVOICE_NUMBER(p_header_row_id);

  END update_trx_header_cache;


/* =======================================================================*
 | PROCEDURE update_trx_lines_cache : Update the Cache Lines Info         |
 |                                    from a row in g_suite_rec_tbl       |
 * =======================================================================*/
  PROCEDURE update_trx_lines_cache(p_header_row_id IN NUMBER,
                                     p_line_row_id IN NUMBER) IS

  l_trx_line_exists_flag VARCHAR2(1);
  l_updateable_row NUMBER;
  i NUMBER;
  BEGIN
    l_trx_line_exists_flag := 'N';

    -----------------------------------------------------
    -- Loop to find the Cached Trx Line Row with Same Trx_id
    -- That will be updated
    -----------------------------------------------------
    FOR i in g_trx_lines_cache_rec_tbl.trx_id.FIRST..g_trx_lines_cache_rec_tbl.trx_id.LAST LOOP
      If   g_trx_lines_cache_rec_tbl.trx_id(i)      = g_suite_rec_tbl.TRX_ID(p_header_row_id)
      AND  g_trx_lines_cache_rec_tbl.trx_line_id(i) = g_suite_rec_tbl.TRX_LINE_ID(p_line_row_id)
      THEN
        l_updateable_row := i;
        l_trx_line_exists_flag := 'Y';
      ELSE
        l_trx_line_exists_flag := 'N';
      END IF;
      ------------------------------------------------
      -- If the Line to be updated does not exist then
      -- Create the Line in the Cache, if not update.
      ------------------------------------------------
      IF l_trx_line_exists_flag = 'N' THEN
        populate_trx_lines_cache(p_header_row_id,
                                 i);
      ELSIF l_trx_line_exists_flag = 'Y' THEN
        write_message('=========================================');
        write_message('==Updating Transaction Line Header Cache' );
        write_message('==Row to be updated is'||l_updateable_row );
        write_message('=========================================');
        --------------------------------------------
        -- Update the Line Information in the Cache
        -------------------------------------------
        g_trx_lines_cache_rec_tbl.APPLICATION_ID(l_updateable_row)             := g_suite_rec_tbl.APPLICATION_ID(p_header_row_id);
        g_trx_lines_cache_rec_tbl.ENTITY_CODE(l_updateable_row)                := g_suite_rec_tbl.ENTITY_CODE(p_header_row_id);
        g_trx_lines_cache_rec_tbl.EVENT_CLASS_CODE(l_updateable_row)           := g_suite_rec_tbl.EVENT_CLASS_CODE(p_header_row_id);
        g_trx_lines_cache_rec_tbl.TRX_ID(l_updateable_row)                     := g_suite_rec_tbl.TRX_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.TRX_LINE_ID(l_updateable_row)                := g_suite_rec_tbl.TRX_LINE_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.LINE_LEVEL_ACTION(l_updateable_row)          := g_suite_rec_tbl.LINE_LEVEL_ACTION(p_line_row_id);
        g_trx_lines_cache_rec_tbl.TRX_LINE_TYPE(l_updateable_row)              := g_suite_rec_tbl.TRX_LINE_TYPE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.TRX_LINE_DATE(l_updateable_row)              := g_suite_rec_tbl.TRX_LINE_DATE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.TRX_BUSINESS_CATEGORY(l_updateable_row)      := g_suite_rec_tbl.TRX_BUSINESS_CATEGORY(p_line_row_id);
        g_trx_lines_cache_rec_tbl.LINE_INTENDED_USE(l_updateable_row)          := g_suite_rec_tbl.LINE_INTENDED_USE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.USER_DEFINED_FISC_CLASS(l_updateable_row)    := g_suite_rec_tbl.USER_DEFINED_FISC_CLASS(p_line_row_id);
        g_trx_lines_cache_rec_tbl.LINE_AMT(l_updateable_row)                   := g_suite_rec_tbl.LINE_AMT(p_line_row_id);
        g_trx_lines_cache_rec_tbl.TRX_LINE_QUANTITY(l_updateable_row)          := g_suite_rec_tbl.TRX_LINE_QUANTITY(p_line_row_id);
        g_trx_lines_cache_rec_tbl.UNIT_PRICE(l_updateable_row)                 := g_suite_rec_tbl.UNIT_PRICE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.PRODUCT_ID(l_updateable_row)                 := g_suite_rec_tbl.PRODUCT_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.PRODUCT_FISC_CLASSIFICATION(l_updateable_row):= g_suite_rec_tbl.PRODUCT_FISC_CLASSIFICATION(p_line_row_id);
        g_trx_lines_cache_rec_tbl.PRODUCT_ORG_ID(l_updateable_row)             := g_suite_rec_tbl.PRODUCT_ORG_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.UOM_CODE(l_updateable_row)                   := g_suite_rec_tbl.UOM_CODE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.PRODUCT_TYPE(l_updateable_row)               := g_suite_rec_tbl.PRODUCT_TYPE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.PRODUCT_CODE(l_updateable_row)               := g_suite_rec_tbl.PRODUCT_CODE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.PRODUCT_CATEGORY(l_updateable_row)           := g_suite_rec_tbl.PRODUCT_CATEGORY(p_line_row_id);
        g_trx_lines_cache_rec_tbl.MERCHANT_PARTY_ID(l_updateable_row)          := g_suite_rec_tbl.MERCHANT_PARTY_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.ACCOUNT_CCID(l_updateable_row)               := g_suite_rec_tbl.ACCOUNT_CCID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.ACCOUNT_STRING(l_updateable_row)             := g_suite_rec_tbl.ACCOUNT_STRING(p_line_row_id);
        g_trx_lines_cache_rec_tbl.REF_DOC_APPLICATION_ID(l_updateable_row)     := g_suite_rec_tbl.REF_DOC_APPLICATION_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.REF_DOC_ENTITY_CODE(l_updateable_row)        := g_suite_rec_tbl.REF_DOC_ENTITY_CODE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.REF_DOC_EVENT_CLASS_CODE(l_updateable_row)   := g_suite_rec_tbl.REF_DOC_EVENT_CLASS_CODE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.REF_DOC_TRX_ID(l_updateable_row)             := g_suite_rec_tbl.REF_DOC_TRX_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.REF_DOC_LINE_ID(l_updateable_row)            := g_suite_rec_tbl.REF_DOC_LINE_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.REF_DOC_LINE_QUANTITY(l_updateable_row)      := g_suite_rec_tbl.REF_DOC_LINE_QUANTITY(p_line_row_id);
        g_trx_lines_cache_rec_tbl.APPLIED_FROM_APPLICATION_ID(l_updateable_row):= g_suite_rec_tbl.APPLIED_FROM_APPLICATION_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.APPLIED_FROM_ENTITY_CODE(l_updateable_row)   := g_suite_rec_tbl.APPLIED_FROM_ENTITY_CODE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.APPLIED_FROM_EVENT_CLASS_CODE(l_updateable_row):= g_suite_rec_tbl.APPLIED_FROM_EVENT_CLASS_CODE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.APPLIED_FROM_TRX_ID(l_updateable_row)        := g_suite_rec_tbl.APPLIED_FROM_TRX_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.APPLIED_FROM_LINE_ID(l_updateable_row)       := g_suite_rec_tbl.APPLIED_FROM_LINE_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.ADJUSTED_DOC_APPLICATION_ID(l_updateable_row):= g_suite_rec_tbl.ADJUSTED_DOC_APPLICATION_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.adjusted_doc_entity_code(l_updateable_row)   := g_suite_rec_tbl.adjusted_doc_entity_code(p_line_row_id);
        g_trx_lines_cache_rec_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(l_updateable_row):= g_suite_rec_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.ADJUSTED_DOC_TRX_ID(l_updateable_row)        := g_suite_rec_tbl.ADJUSTED_DOC_TRX_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.ADJUSTED_DOC_LINE_ID(l_updateable_row)       := g_suite_rec_tbl.ADJUSTED_DOC_LINE_ID(p_line_row_id);
        g_trx_lines_cache_rec_tbl.TRX_LINE_NUMBER(l_updateable_row)            := g_suite_rec_tbl.TRX_LINE_NUMBER(p_line_row_id);
        g_trx_lines_cache_rec_tbl.TRX_LINE_DESCRIPTION(l_updateable_row)       := g_suite_rec_tbl.TRX_LINE_DESCRIPTION(p_line_row_id);
        g_trx_lines_cache_rec_tbl.TRX_LINE_GL_DATE(l_updateable_row)           := g_suite_rec_tbl.TRX_LINE_GL_DATE(p_line_row_id);
        g_trx_lines_cache_rec_tbl.LINE_AMT_INCLUDES_TAX_FLAG(l_updateable_row) := g_suite_rec_tbl.LINE_AMT_INCLUDES_TAX_FLAG(p_line_row_id);
        g_trx_lines_cache_rec_tbl.TRX_LEVEL_TYPE(l_updateable_row)             := g_suite_rec_tbl.TRX_LEVEL_TYPE(p_line_row_id);
      END IF;
    END LOOP;
  END update_trx_lines_cache;


/* =======================================================================*
 | PROCEDURE update_dist_lines_cache : Update the Cache Dist Lines Info   |
 |                                    from a row in g_suite_rec_tbl       |
 * =======================================================================*/
  PROCEDURE update_dist_lines_cache
   (
    p_dist_row_id IN NUMBER
   ) IS

  l_dist_line_exists_flag VARCHAR2(1);
  l_updateable_row NUMBER;
  i NUMBER;

  BEGIN
    l_dist_line_exists_flag := 'N';
    ---------------------------------------------------------------
    -- Loop to find the Dist Row with Same Trx_id and trx_line_id
    -- That will be updated
    ---------------------------------------------------------------
    FOR i in g_dist_lines_cache_rec_tbl.trx_id.FIRST..g_dist_lines_cache_rec_tbl.trx_id.LAST LOOP
      If   g_dist_lines_cache_rec_tbl.trx_id(i)      = g_suite_rec_tbl.TRX_ID(p_dist_row_id)
      AND  g_dist_lines_cache_rec_tbl.trx_line_dist_id(i) = g_suite_rec_tbl.TRX_LINE_DIST_ID(p_dist_row_id)
      THEN
        l_updateable_row := i;
        l_dist_line_exists_flag := 'Y';

        write_message('=========================================');
        write_message('==Updating Distribution Lines Cache' );
        write_message('==Row to be updated is'||l_updateable_row );
        write_message('=========================================');
        ---------------------------------------------------------
        -- Update the Distribution Line Information in the Cache
        ---------------------------------------------------------
        g_dist_lines_cache_rec_tbl.APPLICATION_ID(l_updateable_row)        :=g_suite_rec_tbl.APPLICATION_ID(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.ENTITY_CODE(l_updateable_row)           :=g_suite_rec_tbl.ENTITY_CODE(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.EVENT_CLASS_CODE(l_updateable_row)      :=g_suite_rec_tbl.EVENT_CLASS_CODE(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.EVENT_TYPE_CODE(l_updateable_row)       :=g_suite_rec_tbl.EVENT_TYPE_CODE(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.TRX_ID(l_updateable_row)                :=g_suite_rec_tbl.TRX_ID(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.TRX_LINE_ID(l_updateable_row)           :=g_suite_rec_tbl.TRX_LINE_ID(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.TRX_LINE_QUANTITY(l_updateable_row)     :=g_suite_rec_tbl.TRX_LINE_QUANTITY(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.TRX_LEVEL_TYPE(l_updateable_row)        :=g_suite_rec_tbl.TRX_LEVEL_TYPE(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_ID(l_updateable_row)      :=g_suite_rec_tbl.TRX_LINE_DIST_ID(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_AMT(l_updateable_row)     :=g_suite_rec_tbl.TRX_LINE_DIST_AMT(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_QUANTITY(l_updateable_row):=g_suite_rec_tbl.TRX_LINE_DIST_QUANTITY(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.DIST_LEVEL_ACTION(l_updateable_row)     :=g_suite_rec_tbl.DIST_LEVEL_ACTION(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_DATE(l_updateable_row)    :=g_suite_rec_tbl.TRX_LINE_DIST_DATE(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.ITEM_DIST_NUMBER(l_updateable_row)      :=g_suite_rec_tbl.ITEM_DIST_NUMBER(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.DIST_INTENDED_USE(l_updateable_row)     :=g_suite_rec_tbl.DIST_INTENDED_USE(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.TAX_INCLUSION_FLAG(l_updateable_row)     :=g_suite_rec_tbl.TAX_INCLUSION_FLAG(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.TAX_CODE(l_updateable_row)              :=g_suite_rec_tbl.TAX_CODE(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.TASK_ID(l_updateable_row)               :=g_suite_rec_tbl.TASK_ID(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.AWARD_ID(l_updateable_row)              :=g_suite_rec_tbl.AWARD_ID(p_dist_row_id);
        g_dist_lines_cache_rec_tbl.PROJECT_ID(l_updateable_row)            :=g_suite_rec_tbl.PROJECT_ID(p_dist_row_id);
      END IF;
    END LOOP;
    ----------------------------------------------------
    -- If the Line to be updated does not exist display
    -- a message in the log.
    ----------------------------------------------------
    IF l_dist_line_exists_flag = 'N' THEN
      write_message('The Distribution Line Does not exists!!!!!!!');
      write_message('Please review the data for Distributions');
    END IF;
  END update_dist_lines_cache;

/* ============================================================================*
 | PROCEDURE merge_with_dist_lines_cache : Merges Dist Lines for current Case  |
 |                                         when RE-DISTRIBUTE for DETERMINE    |
 |                                         RECOVERY. Merges the                |
 |                                         actual given lines plus the lines   |
 |                                         not given but existing in the cache |
 |                                         Lines taken from Cache will be      |
 |                                         marked as NO-ACTION.                |
 | Logic to Sync Distributions Cache and Suite Structure                       |
 | 1) Lets Call Distributions Cache "A"                                        |
 | 2) Lets Call Suite Structure "B"                                            |
 | 3) If A(i) exists in B(l) then A(i) = B(l)                                  |
 | 4) If A(i) does not exists in B(l) then                                     |
 |                    A(i) = "NO_ACTION"                                       |
 |                    Insert A(l) into B                                       |
 | 5) If B(i) is not in A(l) Do nothing                                        |
 | 6) If B(i) is not in A(l) insert into A                                     |
 * ===========================================================================*/
  PROCEDURE merge_with_dist_lines_cache
   (
    p_suite         IN VARCHAR2,
    p_case          IN VARCHAR2
   )
  IS

  l_dist_is_in_cache_flag VARCHAR2(1);
  l_row NUMBER;
  i NUMBER;
  l NUMBER;

  BEGIN
    l_dist_is_in_cache_flag := 'N';

    ---------------------------------------------------------------
    -- Loop The Distributions Cache to sync Cache vs Suite
    ---------------------------------------------------------------
    FOR i in g_dist_lines_cache_rec_tbl.trx_id.FIRST..g_dist_lines_cache_rec_tbl.trx_id.LAST LOOP

      l_dist_is_in_cache_flag := 'N';
      --------------------------------------------------------------------------
      -- Loop the Suite and Case in Memory to see if the record in Cache matches
      --------------------------------------------------------------------------
      FOR l in g_suite_rec_tbl.trx_id.FIRST..g_suite_rec_tbl.trx_id.LAST LOOP
        IF  g_suite_rec_tbl.TRX_ID(l)    = g_dist_lines_cache_rec_tbl.trx_id(i) AND
            g_suite_rec_tbl.ROW_SUITE(l) = p_suite AND
            g_suite_rec_tbl.ROW_CASE(l)  = p_case   THEN
          -------------------------------------------------------------------
          -- If the record exists, then update dist cache with it, if not
          -- then update cache with "NO-ACTION" and insert in Suite and Case
          -------------------------------------------------------------------
          IF g_suite_rec_tbl.TRX_LINE_ID(l) = g_dist_lines_cache_rec_tbl.trx_line_id(i) THEN
            l_dist_is_in_cache_flag := 'Y';
            write_message('=========================================');
            write_message('==Updating Distribution Lines Cache to NO ACTION' );
            write_message('=========================================');
            ----------------------------------------------------------------------------------
            -- Update the Distribution Line Information in the Cache with the info from Suite
            ----------------------------------------------------------------------------------
            g_dist_lines_cache_rec_tbl.APPLICATION_ID(l)        :=g_suite_rec_tbl.APPLICATION_ID(i);
            g_dist_lines_cache_rec_tbl.ENTITY_CODE(l)           :=g_suite_rec_tbl.ENTITY_CODE(i);
            g_dist_lines_cache_rec_tbl.EVENT_CLASS_CODE(l)      :=g_suite_rec_tbl.EVENT_CLASS_CODE(i);
            g_dist_lines_cache_rec_tbl.EVENT_TYPE_CODE(l)       :=g_suite_rec_tbl.EVENT_TYPE_CODE(i);
            g_dist_lines_cache_rec_tbl.TRX_ID(l)                :=g_suite_rec_tbl.TRX_ID(i);
            g_dist_lines_cache_rec_tbl.TRX_LINE_ID(l)           :=g_suite_rec_tbl.TRX_LINE_ID(i);
            g_dist_lines_cache_rec_tbl.TRX_LINE_QUANTITY(l)     :=g_suite_rec_tbl.TRX_LINE_QUANTITY(i);
            g_dist_lines_cache_rec_tbl.TRX_LEVEL_TYPE(l)        :=g_suite_rec_tbl.TRX_LEVEL_TYPE(i);
            g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_ID(l)      :=g_suite_rec_tbl.TRX_LINE_DIST_ID(i);
            g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_AMT(l)     :=g_suite_rec_tbl.TRX_LINE_DIST_AMT(i);
            g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_QUANTITY(l):=g_suite_rec_tbl.TRX_LINE_DIST_QUANTITY(i);
            g_dist_lines_cache_rec_tbl.DIST_LEVEL_ACTION(l)     :=g_suite_rec_tbl.DIST_LEVEL_ACTION(i);
            g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_DATE(l)    :=g_suite_rec_tbl.TRX_LINE_DIST_DATE(i);
            g_dist_lines_cache_rec_tbl.ITEM_DIST_NUMBER(l)      :=g_suite_rec_tbl.ITEM_DIST_NUMBER(i);
            g_dist_lines_cache_rec_tbl.DIST_INTENDED_USE(l)     :=g_suite_rec_tbl.DIST_INTENDED_USE(i);
            g_dist_lines_cache_rec_tbl.TAX_INCLUSION_FLAG(l)     :=g_suite_rec_tbl.TAX_INCLUSION_FLAG(i);
            g_dist_lines_cache_rec_tbl.TAX_CODE(l)              :=g_suite_rec_tbl.TAX_CODE(i);
            g_dist_lines_cache_rec_tbl.TASK_ID(l)               :=g_suite_rec_tbl.TASK_ID(i);
            g_dist_lines_cache_rec_tbl.AWARD_ID(l)              :=g_suite_rec_tbl.AWARD_ID(i);
            g_dist_lines_cache_rec_tbl.PROJECT_ID(l)            :=g_suite_rec_tbl.PROJECT_ID(i);
            EXIT;
          END IF;
        END IF;
      END LOOP;
      ---------------------------------------------------------------------------
      --If Line from Dist Cache is not in the Suite then update the Cache Line
      --with "NO_ACTION" and the insert the Cache Line in the Suite_Rec_Tbl
      ----------------------------------------------------------------------------
      IF l_dist_is_in_cache_flag = 'N' THEN
        g_dist_lines_cache_rec_tbl.DIST_LEVEL_ACTION(i)     :='NO_ACTION';
        -----------------------------------------------
        -- Inserts the Cache line in the Suite_Rec_Tbl
        -----------------------------------------------
        l_row := g_suite_rec_tbl.trx_id.LAST + 1;
        initialize_row(p_record_counter => l_row);

        g_suite_rec_tbl.ROW_SUITE(l_row)              := p_Suite ;
        g_suite_rec_tbl.ROW_CASE(l_row)               := p_Case;
        g_suite_rec_tbl.ROW_API(l_row)                := 'ZX_API_PUB';
        g_suite_rec_tbl.ROW_SERVICE(l_row)            := 'DETERMINE_RECOVERY';
        g_suite_rec_tbl.APPLICATION_ID(l_row)         := g_dist_lines_cache_rec_tbl.APPLICATION_ID(i);
        g_suite_rec_tbl.ENTITY_CODE(l_row)            := g_dist_lines_cache_rec_tbl.ENTITY_CODE(i);
        g_suite_rec_tbl.EVENT_CLASS_CODE(l_row)       := g_dist_lines_cache_rec_tbl.EVENT_CLASS_CODE(i);
        g_suite_rec_tbl.EVENT_TYPE_CODE(l_row)        := g_dist_lines_cache_rec_tbl.EVENT_TYPE_CODE(i);
        g_suite_rec_tbl.TRX_ID(l_row)                 := g_dist_lines_cache_rec_tbl.TRX_ID(i);
        g_suite_rec_tbl.TRX_LINE_ID(l_row)            := g_dist_lines_cache_rec_tbl.TRX_LINE_ID(i);
        g_suite_rec_tbl.TRX_LINE_QUANTITY(l_row)      := g_dist_lines_cache_rec_tbl.TRX_LINE_QUANTITY(i);
        g_suite_rec_tbl.TRX_LEVEL_TYPE(l_row)         := g_dist_lines_cache_rec_tbl.TRX_LEVEL_TYPE(i);
        g_suite_rec_tbl.TRX_LINE_DIST_ID(l_row)       := g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_ID(i);
        g_suite_rec_tbl.TRX_LINE_DIST_AMT(l_row)      := g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_AMT(i);
        g_suite_rec_tbl.TRX_LINE_DIST_QUANTITY(l_row) := g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_QUANTITY(i);
        g_suite_rec_tbl.DIST_LEVEL_ACTION(l_row)      := g_dist_lines_cache_rec_tbl.DIST_LEVEL_ACTION(i);
        g_suite_rec_tbl.TRX_LINE_DIST_DATE(l_row)     := g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_DATE(i);
        g_suite_rec_tbl.ITEM_DIST_NUMBER(l_row)       := g_dist_lines_cache_rec_tbl.ITEM_DIST_NUMBER(i);
        g_suite_rec_tbl.DIST_INTENDED_USE(l_row)      := g_dist_lines_cache_rec_tbl.DIST_INTENDED_USE(i);
        g_suite_rec_tbl.TAX_INCLUSION_FLAG(l_row)      := g_dist_lines_cache_rec_tbl.TAX_INCLUSION_FLAG(i);
        g_suite_rec_tbl.TAX_CODE(l_row)               := g_dist_lines_cache_rec_tbl.TAX_CODE(i);
        g_suite_rec_tbl.TASK_ID(l_row)                := g_dist_lines_cache_rec_tbl.TASK_ID(i);
        g_suite_rec_tbl.AWARD_ID(l_row)               := g_dist_lines_cache_rec_tbl.AWARD_ID(i);
        g_suite_rec_tbl.PROJECT_ID(l_row)             := g_dist_lines_cache_rec_tbl.PROJECT_ID(i);
      END IF;
    END LOOP;
    ---------------------------------------------------------------
    -- Now, Loop The Suite to sync the Distributions Cache vs Suite
    ---------------------------------------------------------------
    FOR i in g_suite_rec_tbl.trx_id.FIRST..g_suite_rec_tbl.trx_id.LAST LOOP
      IF g_suite_rec_tbl.ROW_SUITE(i) = p_suite AND
        g_suite_rec_tbl.ROW_CASE(i)  = p_case  THEN
        ------------------------------------------------------------------
        -- Loop the Distribution Cache to see if record in Suite Matches
        ------------------------------------------------------------------
        l_dist_is_in_cache_flag := 'N';
        FOR l in g_dist_lines_cache_rec_tbl.trx_id.FIRST..g_dist_lines_cache_rec_tbl.trx_id.LAST LOOP
          IF g_suite_rec_tbl.TRX_ID(i)    = g_dist_lines_cache_rec_tbl.trx_id(l) THEN
            l_dist_is_in_cache_flag := 'Y';
            EXIT;
          END IF;
        END LOOP;
        IF l_dist_is_in_cache_flag = 'N' THEN
          l_row := g_dist_lines_cache_rec_tbl.trx_id.LAST + 1;
          -----------------------------------------------------------
          -- If is not in Cache then Insert into Cache from the Suite
          -----------------------------------------------------------
          g_dist_lines_cache_rec_tbl.APPLICATION_ID(l_row)        :=g_suite_rec_tbl.APPLICATION_ID(i);
          g_dist_lines_cache_rec_tbl.ENTITY_CODE(l_row)           :=g_suite_rec_tbl.ENTITY_CODE(i);
          g_dist_lines_cache_rec_tbl.EVENT_CLASS_CODE(l_row)      :=g_suite_rec_tbl.EVENT_CLASS_CODE(i);
          g_dist_lines_cache_rec_tbl.EVENT_TYPE_CODE(l_row)       :=g_suite_rec_tbl.EVENT_TYPE_CODE(i);
          g_dist_lines_cache_rec_tbl.TRX_ID(l_row)                :=g_suite_rec_tbl.TRX_ID(i);
          g_dist_lines_cache_rec_tbl.TRX_LINE_ID(l_row)           :=g_suite_rec_tbl.TRX_LINE_ID(i);
          g_dist_lines_cache_rec_tbl.TRX_LINE_QUANTITY(l_row)     :=g_suite_rec_tbl.TRX_LINE_QUANTITY(i);
          g_dist_lines_cache_rec_tbl.TRX_LEVEL_TYPE(l_row)        :=g_suite_rec_tbl.TRX_LEVEL_TYPE(i);
          g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_ID(l_row)      :=g_suite_rec_tbl.TRX_LINE_DIST_ID(i);
          g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_AMT(l_row)     :=g_suite_rec_tbl.TRX_LINE_DIST_AMT(i);
          g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_QUANTITY(l_row):=g_suite_rec_tbl.TRX_LINE_DIST_QUANTITY(i);
          g_dist_lines_cache_rec_tbl.DIST_LEVEL_ACTION(l_row)     :=g_suite_rec_tbl.DIST_LEVEL_ACTION(i);
          g_dist_lines_cache_rec_tbl.TRX_LINE_DIST_DATE(l_row)    :=g_suite_rec_tbl.TRX_LINE_DIST_DATE(i);
          g_dist_lines_cache_rec_tbl.ITEM_DIST_NUMBER(l_row)      :=g_suite_rec_tbl.ITEM_DIST_NUMBER(i);
          g_dist_lines_cache_rec_tbl.DIST_INTENDED_USE(l_row)     :=g_suite_rec_tbl.DIST_INTENDED_USE(i);
          g_dist_lines_cache_rec_tbl.TAX_INCLUSION_FLAG(l_row)     :=g_suite_rec_tbl.TAX_INCLUSION_FLAG(i);
          g_dist_lines_cache_rec_tbl.TAX_CODE(l_row)              :=g_suite_rec_tbl.TAX_CODE(i);
          g_dist_lines_cache_rec_tbl.TASK_ID(l_row)               :=g_suite_rec_tbl.TASK_ID(i);
          g_dist_lines_cache_rec_tbl.AWARD_ID(l_row)              :=g_suite_rec_tbl.AWARD_ID(i);
          g_dist_lines_cache_rec_tbl.PROJECT_ID(l_row)            :=g_suite_rec_tbl.PROJECT_ID(i);
        END IF;
      END IF;
    END LOOP;
  END merge_with_dist_lines_cache;

/* =========================================================================*
 | PROCEDURE insert_tax_dist_id_gt :Retrieves TAX_DIST_ID depending on      |
 |                                  what STRUCTURE is being passed when     |
 |                                  calling using service                   |
 |                                  FREEZE_DISTRIBUTIONS                    |
 |                                   The Structures are:                    |
 |                                      STRUCTURE_TAX_LINE_KEY              |
 |                                      STRUCTURE_ITEM_DISTRIBUTION_KEY     |
 |                                      STRUCTURE_TRANSACTION_LINE_KEY      |
 |                                  Also Pupulates ZX_TAX_DIST_ID_GT        |
 * =========================================================================*/
  PROCEDURE insert_tax_dist_id_gt
   (
    p_suite         IN VARCHAR2,
    p_case          IN VARCHAR2,
    p_structure     IN VARCHAR2
   ) IS

  l_rec_nrec_tax_dist_id NUMBER;
  l_start_row NUMBER;
  l_end_row NUMBER;
  l_header_row NUMBER;


  BEGIN
    WRITE_MESSAGE('Calling insert_tax_dist_id with '||p_structure);
    IF p_structure = 'STRUCTURE_TRANSACTION_LINE_KEY'  THEN
      BEGIN
        --------------------------------------------------------
        -- Retrieve the start and ending rows for the structure
        --------------------------------------------------------
        get_start_end_rows_structure
        (
          p_suite      => p_suite,
          p_case       => p_case,
          p_structure  => p_structure,
          x_start_row  => l_start_row,
          x_end_row    => l_end_row
        );

        -----------------------------------
        -- Inserts into ZX_TAX_DIST_ID_GT
        -----------------------------------
        FOR i in l_start_row..l_end_row LOOP
          INSERT INTO ZX_TAX_DIST_ID_GT
            (
              TAX_DIST_ID
            )
            (SELECT
              REC_NREC_TAX_DIST_ID
           FROM   zx_rec_nrec_dist
           WHERE  tax_id in (SELECT tax_id
                             FROM   zx_lines l
                             WHERE  l.application_id   = g_suite_rec_tbl.APPLICATION_ID(i)
                             AND    l.entity_code      = g_suite_rec_tbl.ENTITY_CODE(i)
                             AND    l.event_class_code = g_suite_rec_tbl.EVENT_CLASS_CODE(i)
                             AND    l.trx_id           = g_suite_rec_tbl.TRX_ID(i)
                             AND    l.trx_line_id      = g_suite_rec_tbl.TRX_LINE_ID(i)));
        END LOOP;

      EXCEPTION
        --Code the Appropiate Exception Here
        WHEN OTHERS THEN
          write_message('An error has ocurred while populating ZX_TAX_DIST_ID_GT for Structure Trx Line Key');
      END;


    ELSIF p_structure = 'STRUCTURE_ITEM_DISTRIBUTION_KEY' THEN
        --------------------------------------------------------
        -- Retrieve the start and ending rows for the structure
        --------------------------------------------------------
        get_start_end_rows_structure
        (
          p_suite      => p_suite,
          p_case       => p_case,
          p_structure  => 'STRUCTURE_ITEM_DISTRIBUTION_KEY',
          x_start_row  => l_start_row,
          x_end_row    => l_end_row
        );

      BEGIN
        -----------------------------------
        -- Inserts into ZX_TAX_DIST_ID_GT
        -----------------------------------
        FOR i in l_start_row..l_end_row LOOP
          INSERT INTO ZX_TAX_DIST_ID_GT
          (
           TAX_DIST_ID
          )
          (SELECT rec_nrec_tax_dist_id
             REC_NREC_TAX_DIST_ID
           FROM   zx_rec_nrec_dist d
           WHERE  d.application_id   = g_suite_rec_tbl.APPLICATION_ID(i)
           AND    d.entity_code      = g_suite_rec_tbl.ENTITY_CODE(i)
           AND    d.event_class_code = g_suite_rec_tbl.EVENT_CLASS_CODE(i)
           AND    d.trx_id           = g_suite_rec_tbl.TRX_ID(i)
           AND    d.trx_line_id      = g_suite_rec_tbl.TRX_LINE_ID(i)
           AND    d.trx_line_dist_id = g_suite_rec_tbl.TRX_LINE_DIST_ID(i));
        END LOOP;
      EXCEPTION
        --Code the Appropiate Exception Here, by now only messages.
        WHEN OTHERS THEN
          write_message('An error has ocurred while populating ZX_TAX_DIST_ID_GT for Structure Item Dist Key');
      END;

    ELSIF p_structure = 'STRUCTURE_TAX_LINE_KEY'          THEN
      BEGIN
        --------------------------------------------------------
        -- Retrieve the start and ending rows for the structure
        --------------------------------------------------------
        get_start_end_rows_structure
        (
          p_suite      => p_suite,
          p_case       => p_case,
          p_structure  => 'STRUCTURE_TAX_LINE_KEY',
          x_start_row  => l_start_row,
          x_end_row    => l_end_row
        );
        -----------------------------------
        -- Inserts into ZX_TAX_DIST_ID_GT
        -----------------------------------
        FOR i in l_start_row..l_end_row LOOP
          INSERT INTO ZX_TAX_DIST_ID_GT
          (
            TAX_DIST_ID
          )
          (SELECT
            REC_NREC_TAX_DIST_ID
           FROM   zx_rec_nrec_dist
           WHERE  tax_id in (SELECT tax_id
                             FROM   zx_lines l
                             WHERE  l.application_id   = g_suite_rec_tbl.APPLICATION_ID(i)
                             AND    l.entity_code      = g_suite_rec_tbl.ENTITY_CODE(i)
                             AND    l.event_class_code = g_suite_rec_tbl.EVENT_CLASS_CODE(i)
                             AND    l.trx_id           = g_suite_rec_tbl.TRX_ID(i)
                             AND    l.trx_line_id      = g_suite_rec_tbl.TRX_LINE_ID(i)
                             AND    l.tax_regime_code  = g_suite_rec_tbl.TAX_REGIME_CODE(i)
                             AND    l.tax              = g_suite_rec_tbl.TAX(i)
                             AND    l.tax_status_code  = g_suite_rec_tbl.TAX_STATUS_CODE(i)
                             AND    l.tax_line_number  = g_suite_rec_tbl.TAX_LINE_NUMBER(i)));
        END LOOP;
      EXCEPTION
        --Code the Appropiate Exception Here, by now only messages.
        WHEN OTHERS THEN
          write_message('An error has ocurred populating ZX_TAX_DIST_ID_GT for Structure Tax Line Key');
      END;
    ELSIF p_structure = 'STRUCTURE_ITEM_DISTRIBUTIONS' THEN

        ---------------------------------------------------------------
        -- Retrieve the start and ending rows for the Header structure
        ---------------------------------------------------------------
        get_start_end_rows_structure
        (
          p_suite      => p_suite,
          p_case       => p_case,
          p_structure  => 'STRUCTURE_TRANSACTION_HEADER',
          x_start_row  => l_header_row,
          x_end_row    => l_end_row
        );

      --------------------------------------------------------
      -- Retrieve the start and ending rows for the structure
      --------------------------------------------------------
       get_start_end_rows_structure
        (
          p_suite      => p_suite,
          p_case       => p_case,
          p_structure  => 'STRUCTURE_ITEM_DISTRIBUTIONS',
          x_start_row  => l_start_row,
          x_end_row    => l_end_row
        );
        -----------------------------------
        -- Inserts into ZX_TAX_DIST_ID_GT
        -----------------------------------
        --write_message(to_char(l_start_row)||','||to_char(l_end_row));
        FOR i in l_start_row..l_end_row LOOP
        --write_message('i:'||to_number(i));
        --write_message('tax_dist_id:'||g_suite_rec_tbl.tax_dist_id(i));
          INSERT INTO ZX_TAX_DIST_ID_GT
          (
           TAX_DIST_ID
          )
          VALUES
          (
           g_suite_rec_tbl.tax_dist_id(i)
          );
        END LOOP;

    END IF;
  END insert_tax_dist_id_gt;


/* ============================================================================*
 | PROCEDURE perform_data_caching : Calls all the procedures needed for Caching|
 |                                  depending on the Scenario Executed         |
 * ===========================================================================*/

PROCEDURE perform_data_caching (p_suite_number    IN VARCHAR2,
                             p_case_number     IN VARCHAR2,
                             p_service         IN VARCHAR2,
                             p_structure       IN VARCHAR2,
                             p_header_row_id   IN NUMBER,
                             p_starting_row_id IN NUMBER,
                             p_ending_row_id   IN NUMBER,
                             p_prev_trx_id     IN NUMBER) IS

  l_structure VARCHAR2(2000);
  l_tax_event_type_code VARCHAR2(80);
  l_initial_row NUMBER;
  l_ending_row NUMBER;
  i NUMBER;
  BEGIN
    ------------------------------------------------------------
    -- Proceed to do Data Caching when the API is Calculate Tax
    -- and the tax_event_type is CREATE. So Cache the entire
    -- Header and Lines
    ------------------------------------------------------------
    IF p_service  = 'CALCULATE_TAX' THEN
      FOR i IN p_header_row_id..p_ending_row_id LOOP
        l_tax_event_type_code := g_suite_rec_tbl.TAX_EVENT_TYPE_CODE(p_header_row_id);
        l_structure := g_suite_rec_tbl.ROW_STRUCTURE(i);
        ---------------------------------------------------------------
        -- Handle the Data Caching when Tax Event Type Code is CREATE
        ---------------------------------------------------------------
        IF l_tax_event_type_code = 'CREATE' THEN
          IF l_structure = 'STRUCTURE_TRANSACTION_HEADER' THEN
            --write_message('Im going to cache Header row:'||to_char(i));
            populate_trx_header_cache(p_header_row_id => p_header_row_id);
            --write_message('==================================================');
            write_message('==A line for Header has been cached');
            --write_message('==tax_event_type_code:'||l_tax_event_type_code);
            --write_message('==          Structure:'||l_structure);
            --write_message('==                Row:'||to_char(i));
            --write_message('==================================================');

          ELSIF l_structure = 'STRUCTURE_TRANSACTION_LINES' THEN
            --write_message('Im going to cache line row:'||to_char(i));
            --write_message('Im going to cache Structur:'||nvl(l_structure,'EMPTY'));
            populate_trx_lines_cache(p_header_row_id => p_header_row_id,
                                     p_line_row_id   => i);
            --write_message('==================================================');
            write_message('==A line for Line has been cached  ');
            --write_message('==tax_event_type_code:'||l_tax_event_type_code);
            --write_message('==          Structure:'||l_structure);
            --write_message('==                Row:'||to_char(i));
            --write_message('==================================================');

          END IF;
        ---------------------------------------------------------------
        -- Handle the Data Caching when Tax Event Type Code is UPDATE
        ---------------------------------------------------------------
        ELSIF l_tax_event_type_code = 'UPDATE' THEN
          IF l_structure = 'STRUCTURE_TRANSACTION_HEADER' THEN
            update_trx_header_cache(p_header_row_id => p_header_row_id);
            write_message('==================================================');
            write_message('==A line for Header cache has been updated');
            write_message('==tax_event_type_code:'||l_tax_event_type_code);
            write_message('==          Structure:'||l_structure);
            write_message('==                Row:'||to_char(i));
            write_message('==================================================');

          ELSIF l_structure = 'STRUCTURE_TRANSACTION_LINES' THEN
            update_trx_lines_cache(p_header_row_id   => p_header_row_id,
                                     p_line_row_id   => i);
            write_message('==================================================');
            write_message('==A line for Line cache has been updated');
            write_message('==tax_event_type_code:'||l_tax_event_type_code);
            write_message('==          Structure:'||l_structure);
            write_message('==                Row:'||to_char(i));
            write_message('==================================================');
          END IF;
        END IF;
      END LOOP;
    ------------------------------------------------------------
    -- Proceed to do Data Caching when the API is Calculate Tax
    -- and the tax_event_type is CREATE. So Cache the entire
    -- Header and Lines
    ------------------------------------------------------------
    ELSIF p_service  = 'DETERMINE_RECOVERY' THEN
      ----------------------------------------------------------
      -- Retrieve the initial and ending lines for Imp Tax Lines
      ----------------------------------------------------------
      get_start_end_rows_structure
       (
        p_suite     =>  p_suite_number,
        p_case      =>  p_case_number,
        p_structure =>  'STRUCTURE_TRANSACTION_HEADER',
        x_start_row =>  l_initial_row,
        x_end_row   =>  l_ending_row
       );

      FOR i IN l_initial_row..l_ending_row LOOP
        l_tax_event_type_code := g_suite_rec_tbl.TAX_EVENT_TYPE_CODE(l_initial_row);
        l_structure := g_suite_rec_tbl.ROW_STRUCTURE(i);
        -----------------------------------------------------------------
        -- Handle the Data Caching when Tax Event Type Code is DISTRIBUTE
        -----------------------------------------------------------------
        IF l_tax_event_type_code = 'DISTRIBUTE' THEN
          IF l_structure = 'STRUCTURE_TRANSACTION_HEADER' THEN
            populate_trx_header_cache(p_header_row_id => p_header_row_id);
            write_message('==================================================');
            write_message('==A line for Header has been cached');
            write_message('==tax_event_type_code:'||l_tax_event_type_code);
            write_message('==          Structure:'||l_structure);
            write_message('==                Row:'||to_char(i));
            write_message('==================================================');

          ELSIF l_structure = 'STRUCTURE_ITEM_DISTRIBUTIONS' THEN
            populate_dist_lines_cache(p_dist_row_id => i);
            write_message('==================================================');
            write_message('==A line for Line has been cached  ');
            write_message('==tax_event_type_code:'||l_tax_event_type_code);
            write_message('==          Structure:'||l_structure);
            write_message('==                Row:'||to_char(i));
            write_message('==================================================');
          END IF;

        END IF;
      END LOOP;
    END IF;
  END perform_data_caching;

/*============================================================================*
 | PROCEDURE get_start_end_rows_structure: Retrieves the initial and ending   |
 |                                    rows of a Structure in g_suite_rec_tbl  |
 |                                    The Structure lines always have to be   |
 |                                    contiguos.                              |
 *============================================================================*/
  PROCEDURE get_start_end_rows_structure
    (
      p_suite                IN VARCHAR2,
      p_case                 IN VARCHAR2,
      p_structure            IN VARCHAR2,
      x_start_row            OUT NOCOPY NUMBER,
      x_end_row              OUT NOCOPY NUMBER
    ) IS
  l_start_row NUMBER;
  l_end_row   NUMBER;
  i           NUMBER;
  BEGIN
    l_start_row := NULL;
    l_end_row   := NULL;


    FOR i IN g_suite_rec_tbl.ROW_SUITE.FIRST..g_suite_rec_tbl.ROW_SUITE.LAST LOOP
      IF g_suite_rec_tbl.ROW_SUITE(i)     = p_suite AND
         g_suite_rec_tbl.ROW_CASE(i)      = p_case  AND
         g_suite_rec_tbl.ROW_STRUCTURE(i) = p_structure THEN
        IF l_start_row is NULL THEN
          l_start_row := i;
        END IF;
        l_end_row := i;
      END IF;
    END LOOP;
    x_start_row := l_start_row;
    x_end_row := l_end_row;
  END get_start_end_rows_structure;


/*============================================================================*
 | PROCEDURE get_zx_errors_gt: Retrieves the errors stored in ZX_ERRORS_GT    |
 *============================================================================*/
  PROCEDURE get_zx_errors_gt
    (x_message            OUT NOCOPY VARCHAR2)
  IS
  l_zx_errors_gt_count     NUMBER;
  l_message                VARCHAR2(4000);

  CURSOR c_errors IS
    SELECT message_text
    FROM   zx_errors_gt;
  BEGIN

    ----------------------------------------------------------------
    -- Detects if there are messages in the table ZX_ERRORS_GT
    -- if so, extract them and print them.
    ----------------------------------------------------------------
    BEGIN
      Select count(*) into l_zx_errors_gt_count from ZX_ERRORS_GT;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

    IF l_zx_errors_gt_count = 0 then
      l_message := NULL;
    ELSE
      FOR c in c_errors LOOP
        l_message := l_message || c.message_text ||' ';
      END LOOP;
    END IF;
    x_message := l_message;

  END get_zx_errors_gt;


/*============================================================================*
 | PROCEDURE TEST_API: This is the main procedure of Testing APIs             |
 |                     The parameters being passed are the name and location  |
 |                     of the Text Data file.                                 |
 |                     The procedure returns a LONG variable containing the   |
 |                     log that will be visible from report in the application|
 *============================================================================*/

PROCEDURE TEST_API(p_file      IN VARCHAR2,
                   p_directory IN VARCHAR2,
                   x_log       OUT NOCOPY LONG)  IS

l_file_curr_line_counter          NUMBER;
l_suite_curr_line_counter         NUMBER;
l_sid                             NUMBER;
l_file_completed                  VARCHAR2(2000);
l_return_status                   VARCHAR2(2000);
l_curr_case_header_row            NUMBER;
l_curr_case_line_start_row        NUMBER;
l_curr_case_line_end_row          NUMBER;
l_prev_case_header_row            NUMBER;
l_prev_case_line_start_row        NUMBER;
l_prev_case_line_end_row          NUMBER;
l_file_curr_line_string           VARCHAR2(2000);
l_file_curr_line_suite_number     VARCHAR2(30);
l_file_curr_line_case_number      VARCHAR2(30);
l_file_curr_line_api              VARCHAR2(90);
l_file_curr_line_task             VARCHAR2(90);
l_file_curr_line_structure        VARCHAR2(90);
l_file_prev_line_suite_number     VARCHAR2(30);
l_file_prev_line_case_number      VARCHAR2(30);
l_file_prev_line_api              VARCHAR2(90);
l_file_prev_line_task             VARCHAR2(90);
l_file_prev_line_structure        VARCHAR2(90);
l_previous_trx_id                 NUMBER;
l_file_line_counter               NUMBER;
l_suite_line_counter              NUMBER;
l_record_counter                  NUMBER;
l_current_datafile_section        VARCHAR2(2000);
l_suite_line_header               NUMBER;
l_suite_line_begin_lines          NUMBER;
l_suite_line_end_lines            NUMBER;
l_file_curr_line_end_of_case      VARCHAR2(90);
l_curr_case_trx_id                NUMBER;
l_initial_row                     NUMBER;
l_ending_row                      NUMBER;
l_environment                     VARCHAR2(2000);
l_user_id                         NUMBER;

BEGIN
  -----------------------------------
  --Initialize Global Variables
  -----------------------------------
  g_log_destination           := 'LOGVARIABLE'; --SPOOL,LOGFILE,LOGV
  g_line_max_size             := 32767;
  g_initial_file_reading_flag := 'Y';
  g_separator                 := '~';
  g_last_portion_prev_string  := '';
  g_string_segment            := '';
  g_line_segment_string       := '';
  g_retrieve_another_segment  := 'Y';
  g_line_segment_counter      := 0;
  g_element_in_segment_count  := 0;
  g_file_curr_line_counter    := 0;
  g_api_version               := 1.0;
  g_header_cache_counter      := 0;
  g_line_cache_counter        := 0;
  g_dist_cache_counter        := 0;

  -----------------------------------
  -- Initialize Local Variables
  -----------------------------------
  l_file_curr_line_counter  := 0;
  l_suite_curr_line_counter := 0;
  l_file_completed          := 'N';
  l_suite_line_counter      := 0;


  write_message('---------------------------------------');
  write_message('--      eTAX TESTING OF APIs         --');
  write_message('--      --------------------         --');
  write_message('-- File Name is :'||p_file);
  write_message('---------------------------------------');
  ------------------
  -- Initialization
  ------------------
  --FND_GLOBAL.INITIALIZE(l_sid,0,20420,1,null,null,0,0,null,null,null,null);
  --------------------------------------------------------------------------------
  --Bug 4216336. The Initialization is required to obtain for a concurrent
  --             program (The calling report of ZX_TEST_API) as per bug 3771348.
  --             The initialization is made for the settings of user "BTT".
  --------------------------------------------------------------------------------
  BEGIN
    Select user_id
      into l_user_id
      from fnd_user_view
     where user_name = 'BTT';
  EXCEPTION
    WHEN OTHERS THEN
     write_message('ERROR: Cannot retrieve the User ID for user BTT. Please review');
  END;

  FND_GLOBAL.APPS_INITIALIZE( USER_ID      => l_user_id,  --User BTT
                              RESP_ID      =>     60252,  --Resp ZX Testing Tool
                              RESP_APPL_ID =>      235); --Application eBTax
  write_message( 'User name           = ' || fnd_global.user_name);
  write_message( 'User id             = ' || fnd_global.user_id);
  write_message( 'Resp name           = ' || fnd_global.resp_name);
  write_message( 'Resp id             = ' || fnd_global.resp_id);
  write_message( 'Resp app short name = ' || fnd_global.application_short_name);
  write_message( 'Resp app id         = ' || fnd_global.resp_appl_id);


  ----------------------------
  -- Open the file to process
  ----------------------------
  INITIALIZE_FILE(p_directory,p_file,l_return_status);

  l_file_curr_line_suite_number          := null;
  l_file_curr_line_case_number           := null;
  l_file_curr_line_api                   := null;
  l_file_curr_line_task                  := null;
  l_file_curr_line_structure             := null;
  l_file_prev_line_suite_number          := null;
  l_file_prev_line_case_number           := null;
  l_file_prev_line_api                   := null;
  l_file_prev_line_task                  := null;
  l_file_prev_line_structure             := null;
  l_file_curr_line_end_of_case           := 'N';
  g_initial_file_reading_flag            := 'Y';

  ----------------------------------------------------------------
  -- Start the cycle of reading the file line by line
  -- and putting the Suite in the memory structure g_suite_rec_tbl.
  -----------------------------------------------------------------
  LOOP
    -------------------------
    -- Read a line from file
    -------------------------
    READ_LINE(
       x_line_suite               => l_file_curr_line_suite_number,
       x_line_case                => l_file_curr_line_case_number,
       x_line_api                 => l_file_curr_line_api,
       x_line_task                => l_file_curr_line_task,
       x_line_structure           => l_file_curr_line_structure,
       x_line_counter             => l_file_line_counter,
       x_line_is_end_of_case      => l_file_curr_line_end_of_case,
       x_current_datafile_section => l_current_datafile_section,
	   x_return_status            => l_return_status);

    IF l_return_status = 'FAILURE' THEN
      write_message('--------------------------------------------------------');
      write_message('--File Reading has been completed.  End of Processing --');
      write_message('--------------------------------------------------------');
      EXIT;
    END IF;


    write_message('-- Reading line number : '||to_char(l_file_line_counter));

    l_file_curr_line_string := substr(g_line_buffer,1,1000);

    -------------------------------------------------------------------
    -- Identify where the different structures are for each Case     --
    -------------------------------------------------------------------
    If g_current_datafile_section = 'INPUT_DATA' THEN
      l_suite_line_counter := l_suite_line_counter + 1;

      ----------------------------------------------------------------
      --Identify header row information and begin and end of lines
      ----------------------------------------------------------------
      IF l_file_curr_line_structure = 'STRUCTURE_TRANSACTION_HEADER' THEN
        -----------------------------------------------------------
        -- Identifies in wich line of Suite is the Header
        -----------------------------------------------------------
        l_curr_case_header_row          := l_suite_line_counter;

      ELSIF l_file_curr_line_structure = 'STRUCTURE_TRANSACTION_LINES' THEN
        ---------------------------------------------------------------
        -- Identifies in wich lines of Suite are Begin and End of Lines
        ---------------------------------------------------------------
        IF l_curr_case_line_start_row IS NULL THEN
          l_curr_case_line_start_row := l_suite_line_counter;
        END IF;
        l_curr_case_line_end_row := l_suite_line_counter;
      END IF;
    END IF;

    -------------------------------------------------------------
    -- Populate a record in the structure that holds the Suite with
    -- the info from the line retrieved from the file.
    -------------------------------------------------------------
    put_line_in_suite_rec_tbl
        (
          x_suite_number    => l_file_curr_line_suite_number   ,
          x_case_number     => l_file_curr_line_case_number    ,
          x_api_name        => l_file_curr_line_api            ,
          x_api_service     => l_file_curr_line_task           ,
          x_api_structure   => l_file_curr_line_structure      ,
          p_header_row      => l_curr_case_header_row          ,
          p_record_counter  => l_suite_line_counter
        );

    write_message('-----------------------------------------------');
    write_message('-- Row has been inserted in  Suite Structure --');
    write_message('-- put_line_in_suite_rec_tbl                 --');
    write_message('-- l_suite_number:'||        l_file_curr_line_suite_number);
    write_message('-- l_case_number :'||        l_file_curr_line_case_number);
    write_message('-- l_service     :'||        l_file_curr_line_task);
    write_message('-- l_structure   :'||        l_file_curr_line_structure);
    write_message('------------------------------------------------');

    ---------------------------------------------------------------------
    -- Perform this Data Caching ONLY for the Case of Re-Distribute
    -- in DETERMINE_RECOVERY
    ---------------------------------------------------------------------

    IF l_file_curr_line_task = 'DETERMINE_RECOVERY' THEN
      ----------------------------------------------------------
      -- Retrieve the initial and ending lines for Imp Tax Lines
      ----------------------------------------------------------
      get_start_end_rows_structure
       (
        p_suite     =>  l_file_curr_line_suite_number,
        p_case      =>  l_file_curr_line_case_number,
        p_structure =>  'STRUCTURE_TRANSACTION_HEADER',
        x_start_row =>  l_initial_row,
        x_end_row   =>  l_ending_row
       );

      write_message('Data Caching for Determine Recovery');
      IF g_suite_rec_tbl.TAX_EVENT_TYPE_CODE(l_initial_row) = 'RE-DISTRIBUTE' THEN
        -----------------------------------------------------------
        -- Perform this Data Caching only for the Case of Re-Distribute
        -- in DETERMINE_RECOVERY
        -----------------------------------------------------------
        merge_with_dist_lines_cache(
                        p_suite         => l_file_curr_line_suite_number,
                        p_case          => l_file_curr_line_case_number);
      END IF;
    END IF;

    ----------------------------------------------------------------------------
    -- If the current line is the end of a case,
    -- Insert into the Global Temporary Tables before calling API
    ----------------------------------------------------------------------------
    IF l_file_curr_line_end_of_case = 'Y' THEN

      ----------------------------------------------------------
      -- Retrieve the row of the Header
      ----------------------------------------------------------
      get_start_end_rows_structure
       (
        p_suite     =>  l_file_curr_line_suite_number,
        p_case      =>  l_file_curr_line_case_number,
        p_structure =>  'STRUCTURE_TRANSACTION_HEADER',
        x_start_row =>  l_initial_row,
        x_end_row   =>  l_ending_row
       );
      l_curr_case_header_row := l_initial_row;

      ----------------------------------------------------------
      -- Retrieve the row of the Lines
      ----------------------------------------------------------
      get_start_end_rows_structure
       (
        p_suite     =>  l_file_curr_line_suite_number,
        p_case      =>  l_file_curr_line_case_number,
        p_structure =>  'STRUCTURE_TRANSACTION_LINES',
        x_start_row =>  l_initial_row,
        x_end_row   =>  l_ending_row
       );
      l_curr_case_line_start_row := l_initial_row;
      l_curr_case_line_end_row := l_ending_row;

      ------------------------------------------------
      -- Obtains the Transaction ID of the Header row
      ------------------------------------------------

      If l_curr_case_header_row IS NOT NULL then
        l_curr_case_trx_id := g_suite_rec_tbl.trx_id(l_curr_case_header_row);
      ELSE
        l_curr_case_trx_id := g_suite_rec_tbl.trx_id(l_suite_line_counter);
      END IF;

      write_message('-- Inserting into Global Temporary Tables --');
      write_message('-- For the Following values:              --');
      write_message('p_suite_number   ->l_curr_line_suite_number   '||l_file_curr_line_suite_number);
      write_message('p_case_number    ->l_curr_line_case_number    '||l_file_curr_line_case_number);
      write_message('p_service        ->l_curr_line_task           '||l_file_curr_line_task);
      write_message('p_structure      ->l_curr_line_structure      '||l_file_curr_line_structure);
      write_message('p_header_line_id ->l_curr_case_header_row     '||to_char(l_curr_case_header_row));
      write_message('p_starting_line_id>l_curr_case_line_start_row '||to_char(l_curr_case_line_start_row));
      write_message('p_ending_line_id  >l_curr_case_line_end_row   '||to_char(l_curr_case_line_end_row));
      write_message('p_curr_case_trx_id>l_curr_case_trx_id         '||to_char(l_curr_case_trx_id));
      write_message('--------------------------------------------');

      write_message('---------------------------------------');
      write_message('-- Insert into GTs will be performed --');
      write_message('---------------------------------------');
      insert_into_gts(p_suite_number    =>  l_file_curr_line_suite_number,
                      p_case_number     =>  l_file_curr_line_case_number,
                      p_service         =>  l_file_curr_line_task,
                      p_structure       =>  l_file_curr_line_structure,
                      p_header_row_id   =>  l_curr_case_header_row,
                      p_starting_row_id =>  l_curr_case_line_start_row,
                      p_ending_row_id   =>  l_curr_case_line_end_row,
                      p_prev_trx_id     =>  l_curr_case_trx_id);

      write_message('---------------------------------------');
      write_message('--   Insert into GTs is completed.   --');
      write_message('---------------------------------------');

      ---------------------------------------------------------------
      -- Perform Data Caching for all scenarios <> than RE-DISTRIBUTE
      ---------------------------------------------------------------
      write_message('-- Data Caching will been performed...');
      write_message('p_suite_number  =>'||         l_file_curr_line_suite_number);
      write_message('p_case_number   =>'||         l_file_curr_line_case_number);
      write_message('p_service       =>'||         l_file_curr_line_task);
      write_message('p_structure     =>'||         l_file_curr_line_structure);
      write_message('p_header_row_id =>'||to_char( l_curr_case_header_row));
      write_message('p_starting_row_id => '||to_char( l_curr_case_line_start_row));
      write_message('p_ending_row_id =>'||to_char( l_curr_case_line_end_row));
      write_message('p_prev_trx_id   =>'||to_char( l_curr_case_trx_id));

      perform_data_caching(
                      p_suite_number    =>  l_file_curr_line_suite_number,
                      p_case_number     =>  l_file_curr_line_case_number,
                      p_service         =>  l_file_curr_line_task,
                      p_structure       =>  l_file_curr_line_structure,
                      p_header_row_id   =>  l_curr_case_header_row,
                      p_starting_row_id =>  l_curr_case_line_start_row,
                      p_ending_row_id   =>  l_curr_case_line_end_row,
                      p_prev_trx_id     =>  l_curr_case_trx_id);
      write_message('-- Data Caching Completed...');

      ---------------------------------------------------------------
      -- Call the APIs after Data Caching and GT are populated
      ---------------------------------------------------------------
      write_message('----------------------------------------------------');
      write_message('-- Calling the Service ==> '||l_file_curr_line_task);
      write_message('--               Suite ==> '||l_file_curr_line_suite_number);
      write_message('--                Case ==> '||l_file_curr_line_case_number);
      write_message('--      Transaction Id ==> '||to_char(l_curr_case_trx_id));
      call_api( p_api_service    => l_file_curr_line_task,
                p_suite_number   => l_file_curr_line_suite_number,
                p_case_number    => l_file_curr_line_case_number,
                p_transaction_id => l_curr_case_trx_id);

      COMMIT;

      ---------------------------------------------------------------
      -- Clean up the Table --NOTE delete_table has to be used to
      -- initilize the memory for the next SUITE.
      ---------------------------------------------------------------
      -- delete_table;

      ---------------------------------------------------------------
      -- Reset variables for next case
      ---------------------------------------------------------------
      l_curr_case_line_start_row := null;

    END IF;
  END LOOP;

  -----------------------------------------
  -- Close the file.
  -----------------------------------------
  CLOSE_FILE(l_return_status);

  -----------------------------------------------------
  -- Returns the Log in a variable used by the report
  -----------------------------------------------------
  x_log := g_log_variable;
  g_log_variable := null;

END TEST_API;
END ZX_TEST_API;

/
