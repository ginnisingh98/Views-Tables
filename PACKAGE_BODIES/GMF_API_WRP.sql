--------------------------------------------------------
--  DDL for Package Body GMF_API_WRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_API_WRP" AS
/*  $Header: GMFPWRPB.pls 120.4.12000000.3 2007/05/02 10:21:14 pmarada ship $ */


/*  Body start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Create_Item_Cost                                                      |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create item Cost                                                      |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the                        |
 |    Create_Item_Cost API wrapper function                                 |
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
 |    27/Feb/2001  Uday Moogala  Created  Bug# 1418689                      |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
  PROCEDURE         Create_Item_Cost
  (
  p_dir                 IN              VARCHAR2,
  p_input_file          IN              VARCHAR2,
  p_output_file         IN              VARCHAR2,
  p_delimiter           IN              VARCHAR2
  )
  IS

    /******************
    * Local variables *
    ******************/
    l_return_status  VARCHAR2(1);

  BEGIN
    l_return_status  :=   Create_Item_Cost(p_dir, p_input_file, p_output_file, p_delimiter);
  End Create_Item_Cost;

/* +========================================================================+
 | FUNCTION NAME                                                            |
 |    Create_Item_Cost                                                      |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create item Cost                                                      |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Create_Item_Cost API.                                                 |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_rsrc_wrapper<session_id>.log in the /tmp directory.        |
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
 | 06-Apr-07 Pmarada Bug 5586406 commented goto statment in after reading   |
 |           line from file. because of this API inserting last record only |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
  FUNCTION Create_Item_Cost
  (
  p_dir                 IN              VARCHAR2,
  p_input_file          IN              VARCHAR2,
  p_output_file         IN              VARCHAR2,
  p_delimiter           IN              VARCHAR2
  )
  RETURN VARCHAR2
  IS

    /******************
    * Local variables *
    ******************/
    l_status              VARCHAR2(11);
    l_return_status       VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
    l_count               NUMBER(10)  ;
    l_record_count        NUMBER(10)  :=0;
    l_loop_cnt            NUMBER(10)  :=0;
    l_dummy_cnt           NUMBER(10)  :=0;
    l_data                VARCHAR2(1000);
    l_header_rec          GMF_ItemCost_PUB.Header_Rec_Type;
    l_this_lvl_tbl        GMF_ItemCost_PUB.This_Level_Dtl_Tbl_Type;
    l_lower_lvl_tbl       GMF_ItemCost_PUB.Lower_Level_Dtl_Tbl_Type;
    l_costcmpnt_ids       GMF_ItemCost_PUB.costcmpnt_ids_tbl_type;
    l_p_dir               VARCHAR2(150);
    l_output_file         VARCHAR2(120);
    l_outfile_handle      UTL_FILE.FILE_TYPE;
    l_input_file          VARCHAR2(120);
    l_infile_handle       UTL_FILE.FILE_TYPE;
    l_line                VARCHAR2(4000);
    l_delimiter           VARCHAR(11);
    l_log_dir             VARCHAR2(150);
    l_log_name            VARCHAR2(120)  :='gmf_api_cric_wrapper';
    l_log_handle          UTL_FILE.FILE_TYPE;
    l_global_file         VARCHAR2(120);
    l_idx		              NUMBER(10);
    l_idx1		            NUMBER(10);
    l_type		            VARCHAR2(100);
    l_continue            VARCHAR2(1) := 'Y' ;
    l_skip_details        VARCHAR2(1) := 'N' ;
    l_session_id          VARCHAR2(110);

  BEGIN

    l_p_dir              :=p_dir;
    l_input_file         :=p_input_file;
    l_output_file        :=p_output_file;
    l_delimiter          :=p_delimiter;
    l_global_file        :=l_input_file;

    /*******************************************************
    * Obtain The SessionId To Append To wrapper File Name. *
    *******************************************************/
    l_session_id := USERENV('sessionid');
    l_log_name  := CONCAT(l_log_name,l_session_id);
    l_log_name  := CONCAT(l_log_name,'.log');

    /*****************************************************
    * Directory is now the same same as for the out FILE *
    *****************************************************/
    l_log_dir   := p_dir;

    /****************************************************************
    * Open The Wrapper File For Output And The Input File for Input *
    ****************************************************************/
    l_log_handle      :=UTL_FILE.FOPEN(l_log_dir, l_log_name, 'w');
    l_infile_handle   :=UTL_FILE.FOPEN(l_p_dir, l_input_file, 'r');

    /********************************************************
    * Loop thru flat file and call Inventory Quantities API *
    ********************************************************/
    -- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    -- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
    -- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
    -- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
    -- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );
    UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Input Directory  ' || l_p_dir );
    UTL_FILE.PUT_LINE(l_log_handle, 'Input File       ' || l_input_file );
    UTL_FILE.PUT_LINE(l_log_handle, 'Record Type      ' || l_delimiter );
    UTL_FILE.PUT_LINE(l_log_handle, 'Output File      ' || l_output_file );
    l_outfile_handle  :=UTL_FILE.FOPEN(l_p_dir, l_output_file, 'w');
    BEGIN
      UTL_FILE.GET_LINE(l_infile_handle, l_line);
      l_record_count    :=l_record_count+1;
      l_type   := Get_Field(l_line,l_delimiter,1) ; /* = 10 : header rec, 20 : this level, 30 : lower level*/
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise;
    END;
    LOOP
      BEGIN
        UTL_FILE.PUT_LINE(l_log_handle, '--');
        UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
        UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
        IF l_type = '10' THEN
          /*******************
          * empty the tables *
          *******************/
          l_this_lvl_tbl.delete ;
          l_lower_lvl_tbl.delete ;
          l_costcmpnt_ids.delete;
          l_skip_details := 'N' ;
          l_header_rec.period_id          := Get_Field(l_line,l_delimiter,2) ;
          l_header_rec.calendar_code      := Get_Field(l_line,l_delimiter,3) ;
          l_header_rec.period_code        := Get_Field(l_line,l_delimiter,4) ;
          l_header_rec.cost_type_id       := Get_Field(l_line,l_delimiter,5) ;
          l_header_rec.cost_mthd_code     := Get_Field(l_line,l_delimiter,6) ;
          l_header_rec.organization_id    := Get_Field(l_line,l_delimiter,7) ;
          l_header_rec.organization_code  := Get_Field(l_line,l_delimiter,8) ;
          l_header_rec.inventory_item_id  := Get_Field(l_line,l_delimiter,9) ;
          l_header_rec.item_number        := Get_Field(l_line,l_delimiter,10) ;
          l_header_rec.user_name          := Get_Field(l_line,l_delimiter,11) ;
          l_idx  := 0 ;
          l_idx1 := 0 ;
          /*
          UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'calendar_code   = ' || l_header_rec.calendar_code) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'period_code   = ' || l_header_rec.period_code) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'cost_mthd_code   = ' || l_header_rec.cost_mthd_code) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'whse_code   = ' || l_header_rec.whse_code) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'item_id   = ' || l_header_rec.item_id) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'item_no   = ' || l_header_rec.item_no) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'user_name   = ' || l_header_rec.user_name) ;
          */

        ELSIF l_type = '20' AND l_skip_details = 'Y' THEN
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skipping this record...');
        ELSIF l_type = '20' AND l_skip_details = 'N' THEN
          l_idx := l_idx + 1 ;
          l_this_lvl_tbl(l_idx).cmpntcost_id         := Get_Field(l_line,l_delimiter,2) ;
          l_this_lvl_tbl(l_idx).cost_cmpntcls_id     := Get_Field(l_line,l_delimiter,3) ;
          l_this_lvl_tbl(l_idx).cost_cmpntcls_code   := Get_Field(l_line,l_delimiter,4) ;
          l_this_lvl_tbl(l_idx).cost_analysis_code   := Get_Field(l_line,l_delimiter,5) ;
          l_this_lvl_tbl(l_idx).cmpnt_cost           := Get_Field(l_line,l_delimiter,6) ;
          l_this_lvl_tbl(l_idx).burden_ind           := Get_Field(l_line,l_delimiter,7) ;
          l_this_lvl_tbl(l_idx).total_qty            := Get_Field(l_line,l_delimiter,8) ;
          l_this_lvl_tbl(l_idx).costcalc_orig        := Get_Field(l_line,l_delimiter,9) ;
          l_this_lvl_tbl(l_idx).rmcalc_type          := Get_Field(l_line,l_delimiter,10) ;
          l_this_lvl_tbl(l_idx).delete_mark          := Get_Field(l_line,l_delimiter,11) ;
          l_this_lvl_tbl(l_idx).attribute1           := Get_Field(l_line,l_delimiter,12) ;
          l_this_lvl_tbl(l_idx).attribute2           := Get_Field(l_line,l_delimiter,13) ;
          l_this_lvl_tbl(l_idx).attribute3           := Get_Field(l_line,l_delimiter,14) ;
          l_this_lvl_tbl(l_idx).attribute4           := Get_Field(l_line,l_delimiter,15) ;
          l_this_lvl_tbl(l_idx).attribute5           := Get_Field(l_line,l_delimiter,16) ;
          l_this_lvl_tbl(l_idx).attribute6           := Get_Field(l_line,l_delimiter,17) ;
          l_this_lvl_tbl(l_idx).attribute7           := Get_Field(l_line,l_delimiter,18) ;
          l_this_lvl_tbl(l_idx).attribute8           := Get_Field(l_line,l_delimiter,19) ;
          l_this_lvl_tbl(l_idx).attribute9           := Get_Field(l_line,l_delimiter,20) ;
          l_this_lvl_tbl(l_idx).attribute10          := Get_Field(l_line,l_delimiter,21) ;
          l_this_lvl_tbl(l_idx).attribute11          := Get_Field(l_line,l_delimiter,22) ;
          l_this_lvl_tbl(l_idx).attribute12          := Get_Field(l_line,l_delimiter,23) ;
          l_this_lvl_tbl(l_idx).attribute13          := Get_Field(l_line,l_delimiter,24) ;
          l_this_lvl_tbl(l_idx).attribute14          := Get_Field(l_line,l_delimiter,25) ;
          l_this_lvl_tbl(l_idx).attribute15          := Get_Field(l_line,l_delimiter,26) ;
          l_this_lvl_tbl(l_idx).attribute16          := Get_Field(l_line,l_delimiter,27) ;
          l_this_lvl_tbl(l_idx).attribute17          := Get_Field(l_line,l_delimiter,28) ;
          l_this_lvl_tbl(l_idx).attribute18          := Get_Field(l_line,l_delimiter,29) ;
          l_this_lvl_tbl(l_idx).attribute19          := Get_Field(l_line,l_delimiter,30) ;
          l_this_lvl_tbl(l_idx).attribute20          := Get_Field(l_line,l_delimiter,31) ;
          l_this_lvl_tbl(l_idx).attribute21          := Get_Field(l_line,l_delimiter,32) ;
          l_this_lvl_tbl(l_idx).attribute22          := Get_Field(l_line,l_delimiter,33) ;
          l_this_lvl_tbl(l_idx).attribute23          := Get_Field(l_line,l_delimiter,34) ;
          l_this_lvl_tbl(l_idx).attribute24          := Get_Field(l_line,l_delimiter,35) ;
          l_this_lvl_tbl(l_idx).attribute25          := Get_Field(l_line,l_delimiter,36) ;
          l_this_lvl_tbl(l_idx).attribute26          := Get_Field(l_line,l_delimiter,37) ;
          l_this_lvl_tbl(l_idx).attribute27          := Get_Field(l_line,l_delimiter,38) ;
          l_this_lvl_tbl(l_idx).attribute28          := Get_Field(l_line,l_delimiter,39) ;
          l_this_lvl_tbl(l_idx).attribute29          := Get_Field(l_line,l_delimiter,40) ;
          l_this_lvl_tbl(l_idx).attribute30          := Get_Field(l_line,l_delimiter,41) ;
          l_this_lvl_tbl(l_idx).attribute_category   := Get_Field(l_line,l_delimiter,42) ;

          /*
          UTL_FILE.PUT_LINE(l_log_handle,'tl cmpntcost_id('||l_idx||') = '||l_this_lvl_tbl(l_idx).cmpntcost_id) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl cost_cmpntcls_id('||l_idx||') = '||l_this_lvl_tbl(l_idx).cost_cmpntcls_id) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl cost_cmpntcls_code('||l_idx||') = '||l_this_lvl_tbl(l_idx).cost_cmpntcls_code) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl cost_analysis_code('||l_idx||') = '||l_this_lvl_tbl(l_idx).cost_analysis_code) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl cmpnt_cost('||l_idx||') = '||l_this_lvl_tbl(l_idx).cmpnt_cost) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl burden_ind('||l_idx||') = '||l_this_lvl_tbl(l_idx).burden_ind) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl total_qty('||l_idx||') = '||l_this_lvl_tbl(l_idx).total_qty) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl costcalc_orig('||l_idx||') = '||l_this_lvl_tbl(l_idx).costcalc_orig) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl rmcalc_type('||l_idx||') = '||l_this_lvl_tbl(l_idx).rmcalc_type) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl delete_mark('||l_idx||') = '||l_this_lvl_tbl(l_idx).delete_mark) ;
          */
        ELSIF l_type = '30' AND l_skip_details = 'Y' THEN
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skipping this record...');
        ELSIF l_type = '30' AND l_skip_details = 'N'  THEN
          l_idx1 := l_idx1 + 1 ;
          l_type                                       := Get_Field(l_line,l_delimiter,1) ;
          l_lower_lvl_tbl(l_idx1).cmpntcost_id         := Get_Field(l_line,l_delimiter,2) ;
          l_lower_lvl_tbl(l_idx1).cost_cmpntcls_id     := Get_Field(l_line,l_delimiter,3) ;
          l_lower_lvl_tbl(l_idx1).cost_cmpntcls_code   := Get_Field(l_line,l_delimiter,4) ;
          l_lower_lvl_tbl(l_idx1).cost_analysis_code   := Get_Field(l_line,l_delimiter,5) ;
          l_lower_lvl_tbl(l_idx1).cmpnt_cost           := Get_Field(l_line,l_delimiter,6) ;
          l_lower_lvl_tbl(l_idx1).delete_mark          := Get_Field(l_line,l_delimiter,7) ;
          /*
          UTL_FILE.PUT_LINE(l_log_handle,'ll cmpntcost_id('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cmpntcost_id) ;
          UTL_FILE.PUT_LINE(l_log_handle,'ll cost_cmpntcls_id('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cost_cmpntcls_id)      ;
          UTL_FILE.PUT_LINE(l_log_handle,'ll cost_cmpntcls_code('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cost_cmpntcls_code) ;
          UTL_FILE.PUT_LINE(l_log_handle,'ll cost_analysis_code('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cost_analysis_code) ;
          UTL_FILE.PUT_LINE(l_log_handle,'ll cmpnt_cost('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cmpnt_cost) ;
          */
        END IF ;
      EXCEPTION
        WHEN OTHERS THEN
          UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
          IF l_type = '10' THEN
            l_skip_details := 'Y' ;
            UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skip detail records.');
          ELSIF l_type = '20' THEN
            l_this_lvl_tbl.delete(l_idx);
            l_idx := l_idx-1;
          ELSIF l_type = '30' THEN
            l_lower_lvl_tbl.delete(l_idx1);
            l_idx1 := l_idx1-1;
          END IF ;
      END ;
      BEGIN
        UTL_FILE.GET_LINE(l_infile_handle, l_line);
        l_record_count    :=l_record_count+1;
        UTL_FILE.NEW_LINE(l_log_handle);
        l_type   := Get_Field(l_line,l_delimiter,1) ;  -- 10 : header rec, 20 : this level, 30 : lower level
        -- goto GET_MSG_STACK ;  commented this goto as per bug 5586406, otherwise it is skiping the records inserting
        --l_skip_details := 'N' ;
        --UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
        --UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_skip_details = 'N' THEN
            GMF_ItemCost_PUB.Create_Item_Cost
            (
            p_api_version           =>        3.0,
            p_init_msg_list         =>        FND_API.G_TRUE,
            p_commit                =>        FND_API.G_TRUE,
            x_return_status         =>        l_status,
            x_msg_count             =>        l_count,
            x_msg_data              =>        l_data,
            p_header_rec            =>        l_header_rec,
            p_this_level_dtl_tbl    =>        l_this_lvl_tbl,
            p_lower_level_dtl_Tbl   =>        l_lower_lvl_tbl,
            x_costcmpnt_ids         =>        l_costcmpnt_ids
            );
            UTL_FILE.PUT_LINE(l_log_handle, 'in exception. after API call. status := ' || l_status ||' cnt := ' || l_count );
            l_continue := 'N' ;
            goto GET_MSG_STACK ;
          END IF ;
      END;

      -- DBMS_OUTPUT.PUT_LINE('Check to call Create_Item_Cost API...type - ' || l_type || ' count = ' || l_record_count);
      IF (l_type = '10' AND l_record_count <> 1 AND l_skip_details = 'N') THEN
        -- DBMS_OUTPUT.PUT_LINE('Calling Create_Item_Cost API...');
        GMF_ItemCost_PUB.Create_Item_Cost
        (
        p_api_version           =>        3.0,
        p_init_msg_list         =>        FND_API.G_TRUE,
        p_commit                =>        FND_API.G_TRUE,
        x_return_status         =>        l_status,
        x_msg_count             =>        l_count,
        x_msg_data              =>        l_data,
        p_header_rec            =>        l_header_rec,
        p_this_level_dtl_tbl    =>        l_this_lvl_tbl,
        p_lower_level_dtl_Tbl   =>        l_lower_lvl_tbl,
        x_costcmpnt_ids         =>        l_costcmpnt_ids
        );
        UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );

      END IF;

      <<GET_MSG_STACK>>
      NULL;

      /*******************************************************************************************
      * Check if any messages generated. If so then decode and output to error message flat file *
      *******************************************************************************************/
      IF l_count > 0 THEN
        l_loop_cnt  :=1;
        LOOP
          FND_MSG_PUB.Get
          (
          p_msg_index     => l_loop_cnt,
          p_data          => l_data,
          p_encoded       => FND_API.G_FALSE,
          p_msg_index_out => l_dummy_cnt
          );

          -- DBMS_OUTPUT.PUT_LINE(l_data );
          --UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
          --UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
          --UTL_FILE.NEW_LINE(l_outfile_handle);
          UTL_FILE.PUT_LINE(l_log_handle, l_data);

          /**********************
          * Update error status *
          **********************/
          IF (l_status = 'U') THEN
            l_return_status  :=l_status;
          ELSIF (l_status = 'E' and l_return_status <> 'U') THEN
            l_return_status  :=l_status;
          ELSE
            l_return_status  :=l_status;
          END IF;
          l_loop_cnt  := l_loop_cnt + 1;
          IF l_loop_cnt > l_count THEN
            EXIT;
          END IF;
        END LOOP;
        l_count := 0 ;
      END IF;
      -- DBMS_OUTPUT.PUT_LINE('# of CostIds inserted : ' || l_costcmpnt_ids.count);
      FOR i in 1..l_costcmpnt_ids.count
      LOOP
        UTL_FILE.PUT_LINE(l_log_handle, ' CmpntClsId : ' || l_costcmpnt_ids(i).cost_cmpntcls_id ||
                                        ' Analysis Code : ' || l_costcmpnt_ids(i).cost_analysis_code ||
                                        ' Cost Level : ' || l_costcmpnt_ids(i).cost_level ||
                                        ' CostId : ' || l_costcmpnt_ids(i).cmpntcost_id);
      END LOOP ;
      IF l_continue = 'N' THEN
        EXIT ;
      END IF ;
    END LOOP;
    -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.FCLOSE_ALL;

    RETURN l_return_status;
  EXCEPTION
    WHEN UTL_FILE.INVALID_OPERATION THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_PATH THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_MODE THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.WRITE_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.READ_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INTERNAL_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Internal Error');
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('Other Error');
      UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
      UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
      UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
      UTL_FILE.FCLOSE_ALL;
      l_return_status := 'U' ;
      RETURN l_return_status;
  END Create_Item_Cost;

/*  API start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Update_Item_Cost                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Update item Cost                                                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the                        |
 |    Update_Item_Cost API wrapper function                             |
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
 |    07-Mar-2001  Uday Moogala    created                                  |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
  PROCEDURE Update_Item_Cost
  (
  p_dir                 IN              VARCHAR2,
  p_input_file          IN              VARCHAR2,
  p_output_file         IN              VARCHAR2,
  p_delimiter           IN              VARCHAR2
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_return_status  VARCHAR2(1);
  BEGIN
    l_return_status  := Update_Item_Cost  (p_dir, p_input_file, p_output_file, p_delimiter);
  END Update_Item_Cost;

/* +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Update_Item_Cost                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Update item Cost                                                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Update_Item_Cost API.                                             |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_aloc_wrapper<session_id>.log in the temp directory.        |
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
  FUNCTION Update_Item_Cost
  (
  p_dir                 IN              VARCHAR2,
  p_input_file          IN              VARCHAR2,
  p_output_file         IN              VARCHAR2,
  p_delimiter           IN              VARCHAR2
  )
  RETURN VARCHAR2
  IS

    /******************
    * Local variables *
    ******************/
    l_status              VARCHAR2(100);
    l_return_status       VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
    l_count               NUMBER(10)  ;
    l_record_count        NUMBER(10)  :=0;
    l_loop_cnt            NUMBER(10)  :=0;
    l_dummy_cnt           NUMBER(10)  :=0;
    l_data                VARCHAR2(2000);
    l_header_rec          GMF_ItemCost_PUB.Header_Rec_Type;
    l_this_lvl_tbl        GMF_ItemCost_PUB.This_Level_Dtl_Tbl_Type;
    l_lower_lvl_tbl       GMF_ItemCost_PUB.Lower_Level_Dtl_Tbl_Type;
    l_costcmpnt_ids       GMF_ItemCost_PUB.costcmpnt_ids_tbl_type;
    l_p_dir               VARCHAR2(150);
    l_output_file         VARCHAR2(120);
    l_outfile_handle      UTL_FILE.FILE_TYPE;
    l_input_file          VARCHAR2(120);
    l_infile_handle       UTL_FILE.FILE_TYPE;
    l_line                VARCHAR2(1800);
    l_delimiter           VARCHAR(11);
    l_log_dir             VARCHAR2(150);
    l_log_name            VARCHAR2(120)  :='gmf_api_updic_wrapper';
    l_log_handle          UTL_FILE.FILE_TYPE;
    l_global_file         VARCHAR2(120);
    l_idx		              NUMBER(10);
    l_idx1		            NUMBER(10);
    l_type		            VARCHAR2(100);
    l_continue            VARCHAR2(1) := 'Y' ;
    l_skip_details        VARCHAR2(1) := 'N' ;
    l_session_id          VARCHAR2(110);
  BEGIN
    /********************
    * Enable The Buffer *
    ********************/
    /*  DBMS_OUTPUT.ENABLE(1000000); */
    -- DBMS_OUTPUT.PUT_LINE('in Update_Item_Cost function...');
    l_p_dir              :=       p_dir;
    l_input_file         :=       p_input_file;
    l_output_file        :=       p_output_file;
    l_delimiter          :=       p_delimiter;
    l_global_file        :=       l_input_file;

    /*******************************************************
    * Obtain The SessionId To Append To wrapper File Name. *
    *******************************************************/
    l_session_id := USERENV('sessionid');
    l_log_name  := CONCAT(l_log_name,l_session_id);
    l_log_name  := CONCAT(l_log_name,'.log');

    /*****************************************************
    * Directory is now the same same as for the out file *
    *****************************************************/
    l_log_dir   := p_dir;

    /****************************************************************
    * Open The Wrapper File For Output And The Input File for Input *
    ****************************************************************/
    l_log_handle      :=UTL_FILE.FOPEN(l_log_dir, l_log_name, 'w');
    l_infile_handle   :=UTL_FILE.FOPEN(l_p_dir, l_input_file, 'r');

    /********************************************************
    * Loop thru flat file and call Inventory Quantities API *
    ********************************************************/
    -- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    -- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
    -- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
    -- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
    -- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );
    /*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
    UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Input Directory  ' || l_p_dir );
    UTL_FILE.PUT_LINE(l_log_handle, 'Input File       ' || l_input_file );
    UTL_FILE.PUT_LINE(l_log_handle, 'Record Type      ' || l_delimiter );
    UTL_FILE.PUT_LINE(l_log_handle, 'Output File      ' || l_output_file );
    l_outfile_handle  :=UTL_FILE.FOPEN(l_p_dir, l_output_file, 'w');
    BEGIN
      UTL_FILE.GET_LINE(l_infile_handle, l_line);
      l_record_count    :=l_record_count+1;
      l_type   := Get_Field(l_line,l_delimiter,1) ;  /* = 10 : header rec, 20 : this level, 30 : lower level*/
      --UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
      --UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE;
    END;
    /*
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
    l_type   := Get_Field(l_line,l_delimiter,1) ;  -- 10 : header rec, 20 : this level, 30 : lower level
    UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
    DBMS_OUTPUT.PUT_LINE('firt record of type = ' || l_type);
    */
    LOOP
      BEGIN
        UTL_FILE.PUT_LINE(l_log_handle, '--');
        UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
        UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
        IF l_type = '10' THEN
          /*******************
          * empty the tables *
          *******************/
          l_this_lvl_tbl.delete ;
          l_lower_lvl_tbl.delete ;
          l_costcmpnt_ids.delete;
          l_skip_details := 'N' ;
          l_header_rec.period_id          := Get_Field(l_line,l_delimiter,2) ;
          l_header_rec.calendar_code      := Get_Field(l_line,l_delimiter,3) ;
          l_header_rec.period_code        := Get_Field(l_line,l_delimiter,4) ;
          l_header_rec.cost_type_id       := Get_Field(l_line,l_delimiter,5) ;
          l_header_rec.cost_mthd_code     := Get_Field(l_line,l_delimiter,6) ;
          l_header_rec.organization_id    := Get_Field(l_line,l_delimiter,7) ;
          l_header_rec.organization_code  := Get_Field(l_line,l_delimiter,8) ;
          l_header_rec.inventory_item_id  := Get_Field(l_line,l_delimiter,9) ;
          l_header_rec.item_number        := Get_Field(l_line,l_delimiter,10) ;
          l_header_rec.user_name          := Get_Field(l_line,l_delimiter,11) ;
          l_idx  := 0 ;
          l_idx1 := 0 ;
          -- DBMS_OUTPUT.PUT_LINE('in wrapper. l_this_lvl_tbl count : ' || l_this_lvl_tbl.count) ;
          -- DBMS_OUTPUT.PUT_LINE('in wrapper. l_lower_lvl_tbl count : ' || l_lower_lvl_tbl.count) ;
          -- DBMS_OUTPUT.PUT_LINE('calendar_code   = ' || l_header_rec.calendar_code) ;
          /*
          UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'calendar_code   = ' || l_header_rec.calendar_code) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'period_code   = ' || l_header_rec.period_code) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'cost_mthd_code   = ' || l_header_rec.cost_mthd_code) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'whse_code   = ' || l_header_rec.whse_code) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'item_id   = ' || l_header_rec.item_id) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'item_no   = ' || l_header_rec.item_no) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'user_name   = ' || l_header_rec.user_name) ;
          */
        ELSIF l_type = '20' AND l_skip_details = 'Y' THEN
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skipping this record...');
        ELSIF l_type = '20' AND l_skip_details = 'N' THEN
          l_idx := l_idx + 1 ;
          --UTL_FILE.PUT_LINE(l_log_handle, 'Populating this level table...' || l_idx ) ;
          l_this_lvl_tbl(l_idx).cmpntcost_id         := Get_Field(l_line,l_delimiter,2) ;
          l_this_lvl_tbl(l_idx).cost_cmpntcls_id     := Get_Field(l_line,l_delimiter,3) ;
          l_this_lvl_tbl(l_idx).cost_cmpntcls_code   := Get_Field(l_line,l_delimiter,4) ;
          l_this_lvl_tbl(l_idx).cost_analysis_code   := Get_Field(l_line,l_delimiter,5) ;
          l_this_lvl_tbl(l_idx).cmpnt_cost           := Get_Field(l_line,l_delimiter,6) ;
          l_this_lvl_tbl(l_idx).burden_ind           := Get_Field(l_line,l_delimiter,7) ;
          l_this_lvl_tbl(l_idx).total_qty            := Get_Field(l_line,l_delimiter,8) ;
          l_this_lvl_tbl(l_idx).costcalc_orig        := Get_Field(l_line,l_delimiter,9) ;
          l_this_lvl_tbl(l_idx).rmcalc_type          := Get_Field(l_line,l_delimiter,10) ;
          l_this_lvl_tbl(l_idx).delete_mark          := Get_Field(l_line,l_delimiter,11) ;
          l_this_lvl_tbl(l_idx).attribute1           := Get_Field(l_line,l_delimiter,12) ;
          l_this_lvl_tbl(l_idx).attribute2           := Get_Field(l_line,l_delimiter,13) ;
          l_this_lvl_tbl(l_idx).attribute3           := Get_Field(l_line,l_delimiter,14) ;
          l_this_lvl_tbl(l_idx).attribute4           := Get_Field(l_line,l_delimiter,15) ;
          l_this_lvl_tbl(l_idx).attribute5           := Get_Field(l_line,l_delimiter,16) ;
          l_this_lvl_tbl(l_idx).attribute6           := Get_Field(l_line,l_delimiter,17) ;
          l_this_lvl_tbl(l_idx).attribute7           := Get_Field(l_line,l_delimiter,18) ;
          l_this_lvl_tbl(l_idx).attribute8           := Get_Field(l_line,l_delimiter,19) ;
          l_this_lvl_tbl(l_idx).attribute9           := Get_Field(l_line,l_delimiter,20) ;
          l_this_lvl_tbl(l_idx).attribute10          := Get_Field(l_line,l_delimiter,21) ;
          l_this_lvl_tbl(l_idx).attribute11          := Get_Field(l_line,l_delimiter,22) ;
          l_this_lvl_tbl(l_idx).attribute12          := Get_Field(l_line,l_delimiter,23) ;
          l_this_lvl_tbl(l_idx).attribute13          := Get_Field(l_line,l_delimiter,24) ;
          l_this_lvl_tbl(l_idx).attribute14          := Get_Field(l_line,l_delimiter,25) ;
          l_this_lvl_tbl(l_idx).attribute15          := Get_Field(l_line,l_delimiter,26) ;
          l_this_lvl_tbl(l_idx).attribute16          := Get_Field(l_line,l_delimiter,27) ;
          l_this_lvl_tbl(l_idx).attribute17          := Get_Field(l_line,l_delimiter,28) ;
          l_this_lvl_tbl(l_idx).attribute18          := Get_Field(l_line,l_delimiter,29) ;
          l_this_lvl_tbl(l_idx).attribute19          := Get_Field(l_line,l_delimiter,30) ;
          l_this_lvl_tbl(l_idx).attribute20          := Get_Field(l_line,l_delimiter,31) ;
          l_this_lvl_tbl(l_idx).attribute21          := Get_Field(l_line,l_delimiter,32) ;
          l_this_lvl_tbl(l_idx).attribute22          := Get_Field(l_line,l_delimiter,33) ;
          l_this_lvl_tbl(l_idx).attribute23          := Get_Field(l_line,l_delimiter,34) ;
          l_this_lvl_tbl(l_idx).attribute24          := Get_Field(l_line,l_delimiter,35) ;
          l_this_lvl_tbl(l_idx).attribute25          := Get_Field(l_line,l_delimiter,36) ;
          l_this_lvl_tbl(l_idx).attribute26          := Get_Field(l_line,l_delimiter,37) ;
          l_this_lvl_tbl(l_idx).attribute27          := Get_Field(l_line,l_delimiter,38) ;
          l_this_lvl_tbl(l_idx).attribute28          := Get_Field(l_line,l_delimiter,39) ;
          l_this_lvl_tbl(l_idx).attribute29          := Get_Field(l_line,l_delimiter,40) ;
          l_this_lvl_tbl(l_idx).attribute30          := Get_Field(l_line,l_delimiter,41) ;
          l_this_lvl_tbl(l_idx).attribute_category   := Get_Field(l_line,l_delimiter,42) ;
          /*
          UTL_FILE.PUT_LINE(l_log_handle,'tl cmpntcost_id('||l_idx||') = '||l_this_lvl_tbl(l_idx).cmpntcost_id) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl cost_cmpntcls_id('||l_idx||') = '||l_this_lvl_tbl(l_idx).cost_cmpntcls_id) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl cost_cmpntcls_code('||l_idx||') = '||l_this_lvl_tbl(l_idx).cost_cmpntcls_code) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl cost_analysis_code('||l_idx||') = '||l_this_lvl_tbl(l_idx).cost_analysis_code) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl cmpnt_cost('||l_idx||') = '||l_this_lvl_tbl(l_idx).cmpnt_cost) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl burden_ind('||l_idx||') = '||l_this_lvl_tbl(l_idx).burden_ind) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl total_qty('||l_idx||') = '||l_this_lvl_tbl(l_idx).total_qty) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl costcalc_orig('||l_idx||') = '||l_this_lvl_tbl(l_idx).costcalc_orig) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl rmcalc_type('||l_idx||') = '||l_this_lvl_tbl(l_idx).rmcalc_type) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl delete_mark('||l_idx||') = '||l_this_lvl_tbl(l_idx).delete_mark) ;
          */
        ELSIF l_type = '30' AND l_skip_details = 'Y' THEN
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skipping this record...');
        ELSIF l_type = '30' AND l_skip_details = 'N'  THEN
          l_idx1 := l_idx1 + 1 ;
          --UTL_FILE.PUT_LINE(l_log_handle, 'Populating lower level table...' || l_idx1 ) ;
          l_type                                       := Get_Field(l_line,l_delimiter,1) ;
          l_lower_lvl_tbl(l_idx1).cmpntcost_id         := Get_Field(l_line,l_delimiter,2) ;
          l_lower_lvl_tbl(l_idx1).cost_cmpntcls_id     := Get_Field(l_line,l_delimiter,3) ;
          l_lower_lvl_tbl(l_idx1).cost_cmpntcls_code   := Get_Field(l_line,l_delimiter,4) ;
          l_lower_lvl_tbl(l_idx1).cost_analysis_code   := Get_Field(l_line,l_delimiter,5) ;
          l_lower_lvl_tbl(l_idx1).cmpnt_cost           := Get_Field(l_line,l_delimiter,6) ;
          l_lower_lvl_tbl(l_idx1).delete_mark          := Get_Field(l_line,l_delimiter,7) ;
          /*
          UTL_FILE.PUT_LINE(l_log_handle,'ll cmpntcost_id('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cmpntcost_id) ;
          UTL_FILE.PUT_LINE(l_log_handle,'ll cost_cmpntcls_id('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cost_cmpntcls_id)      ;
          UTL_FILE.PUT_LINE(l_log_handle,'ll cost_cmpntcls_code('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cost_cmpntcls_code) ;
          UTL_FILE.PUT_LINE(l_log_handle,'ll cost_analysis_code('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cost_analysis_code) ;
          UTL_FILE.PUT_LINE(l_log_handle,'ll cmpnt_cost('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cmpnt_cost) ;
          */
        END IF ;
      EXCEPTION
        WHEN OTHERS THEN
          UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
          IF l_type = '10' THEN
            l_skip_details := 'Y' ;
            UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skip detail records.');
          ELSIF l_type = '20' THEN
            l_this_lvl_tbl.delete(l_idx);
            l_idx := l_idx-1;
          ELSIF l_type = '30' THEN
            l_lower_lvl_tbl.delete(l_idx1);
            l_idx1 := l_idx1-1;
          END IF ;
      END ;
      BEGIN
        UTL_FILE.GET_LINE(l_infile_handle, l_line);
        l_record_count    :=l_record_count+1;
        UTL_FILE.NEW_LINE(l_log_handle);
        l_type   := Get_Field(l_line,l_delimiter,1) ;  -- 10 : header rec, 20 : this level, 30 : lower level
        --l_skip_details := 'N' ;
        --UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
        --UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_skip_details = 'N' THEN
            -- DBMS_OUTPUT.PUT_LINE('In exception. Calling Update_Item_Cost API...');
            GMF_ItemCost_PUB.Update_Item_Cost
            (
            p_api_version         =>      3.0,
            p_init_msg_list       =>      FND_API.G_TRUE,
            p_commit              =>      FND_API.G_TRUE,
            x_return_status       =>      l_status,
            x_msg_count           =>      l_count,
            x_msg_data            =>      l_data,
            p_header_rec          =>      l_header_rec,
            p_this_level_dtl_tbl  =>      l_this_lvl_tbl,
            p_lower_level_dtl_Tbl =>      l_lower_lvl_tbl
            );
            UTL_FILE.PUT_LINE(l_log_handle, 'in exception. after API call. status := ' || l_status ||' cnt := ' || l_count );
            l_continue := 'N' ;
            goto GET_MSG_STACK ;
          END IF ;
      END;
      -- DBMS_OUTPUT.PUT_LINE('Check to call Update_Item_Cost API...type - ' || l_type || ' count = ' || l_record_count);
      IF (l_type = '10' AND l_record_count <> 1 AND l_skip_details = 'N') THEN
        -- DBMS_OUTPUT.PUT_LINE('Calling Update_Item_Cost API...');
        GMF_ItemCost_PUB.Update_Item_Cost
        (
        p_api_version         =>      3.0,
        p_init_msg_list       =>      FND_API.G_TRUE,
        p_commit              =>      FND_API.G_TRUE,
        x_return_status       =>      l_status,
        x_msg_count           =>      l_count,
        x_msg_data            =>      l_data,
        p_header_rec          =>      l_header_rec,
        p_this_level_dtl_tbl  =>      l_this_lvl_tbl,
        p_lower_level_dtl_Tbl =>      l_lower_lvl_tbl
        );
        UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );
      END IF;
      <<GET_MSG_STACK>>
      NULL;

      /*******************************************************************************************
      * Check if any messages generated. If so then decode and output to error message flat file *
      *******************************************************************************************/
      IF l_count > 0 THEN
        l_loop_cnt  :=1;
        LOOP
          FND_MSG_PUB.Get
          (
          p_msg_index     => l_loop_cnt,
          p_data          => l_data,
          p_encoded       => FND_API.G_FALSE,
          p_msg_index_out => l_dummy_cnt
          );
          -- DBMS_OUTPUT.PUT_LINE(l_data );
          --UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
          --UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
          --UTL_FILE.NEW_LINE(l_outfile_handle);
          UTL_FILE.PUT_LINE(l_log_handle, l_data);
          /**********************
          * Update error status *
          **********************/
          IF (l_status = 'U') THEN
            l_return_status  :=l_status;
          ELSIF (l_status = 'E' and l_return_status <> 'U') THEN
            l_return_status  :=l_status;
          ELSE
            l_return_status  :=l_status;
          END IF;
          l_loop_cnt  := l_loop_cnt + 1;
          IF l_loop_cnt > l_count THEN
            EXIT;
          END IF;
        END LOOP; -- msg stack loop
        l_count := 0 ;
      END IF;	-- if count of msg stack > 0
      IF l_continue = 'N' THEN
        EXIT ;
      END IF ;
    END LOOP;
    -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.FCLOSE_ALL;
    RETURN l_return_status;
  EXCEPTION
    WHEN UTL_FILE.INVALID_OPERATION THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_PATH THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_MODE THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.WRITE_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.READ_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INTERNAL_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Internal Error');
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('Other Error');
      UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
      UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
      UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
      UTL_FILE.FCLOSE_ALL;
      l_return_status := 'U' ;
      RETURN l_return_status;
  END Update_Item_Cost;

/*  API start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Delete_Item_Cost                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Delete item Cost                                                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the                        |
 |    Delete_Item_Cost API wrapper function                             |
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
 |    07-Mar-2001  Uday Moogala    created                                  |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
  PROCEDURE Delete_Item_Cost
  (
  p_dir                 IN              VARCHAR2,
  p_input_file          IN              VARCHAR2,
  p_output_file         IN              VARCHAR2,
  p_delimiter           IN              VARCHAR2
  )
  IS
    /******************
    * Local Variables *
    ******************/
    l_return_status  VARCHAR2(1);
  BEGIN
    l_return_status  :=Delete_Item_Cost(p_dir, p_input_file, p_output_file, p_delimiter);
  End Delete_Item_Cost;

/* +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Delete_Item_Cost                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Delete item Cost                                                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Delete_Item_Cost API.                                             |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_rsrc_wrapper<session_id>.log in the temp directory.        |
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
  FUNCTION Delete_Item_Cost
  (
  p_dir                 IN              VARCHAR2,
  p_input_file          IN              VARCHAR2,
  p_output_file         IN              VARCHAR2,
  p_delimiter           IN              VARCHAR2
  )
  RETURN VARCHAR2
  IS
    /******************
    * Local variables *
    ******************/
    l_status              VARCHAR2(100);
    l_return_status       VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
    l_count               NUMBER(10)  ;
    l_record_count        NUMBER(10)  :=0;
    l_loop_cnt            NUMBER(10)  :=0;
    l_dummy_cnt           NUMBER(10)  :=0;
    l_data                VARCHAR2(2000);
    l_header_rec          GMF_ItemCost_PUB.Header_Rec_Type;
    l_this_lvl_tbl        GMF_ItemCost_PUB.This_Level_Dtl_Tbl_Type;
    l_lower_lvl_tbl       GMF_ItemCost_PUB.Lower_Level_Dtl_Tbl_Type;
    l_costcmpnt_ids       GMF_ItemCost_PUB.costcmpnt_ids_tbl_type;
    l_p_dir               VARCHAR2(150);
    l_output_file         VARCHAR2(120);
    l_outfile_handle      UTL_FILE.FILE_TYPE;
    l_input_file          VARCHAR2(120);
    l_infile_handle       UTL_FILE.FILE_TYPE;
    l_line                VARCHAR2(1800);
    l_delimiter           VARCHAR(11);
    l_log_dir             VARCHAR2(150);
    l_log_name            VARCHAR2(120)  :='gmf_api_delic_wrapper';
    l_log_handle          UTL_FILE.FILE_TYPE;
    l_global_file         VARCHAR2(120);
    l_idx		              NUMBER(10);
    l_idx1		            NUMBER(10);
    l_type		            VARCHAR2(100);
    l_continue            VARCHAR2(1) := 'Y' ;
    l_skip_details        VARCHAR2(1) := 'N' ;
    l_session_id         VARCHAR2(110);
  BEGIN
    /********************
    * Enable The Buffer *
    ********************/
    /*  DBMS_OUTPUT.ENABLE(1000000); */
    -- DBMS_OUTPUT.PUT_LINE('in Delete_Item_Cost function...');
    l_p_dir              :=     p_dir;
    l_input_file         :=     p_input_file;
    l_output_file        :=     p_output_file;
    l_delimiter          :=     p_delimiter;
    l_global_file        :=     l_input_file;

    /*******************************************************
    * Obtain The SessionId To Append To wrapper File Name. *
    *******************************************************/
    l_session_id := USERENV('sessionid');
    l_log_name  := CONCAT(l_log_name,l_session_id);
    l_log_name  := CONCAT(l_log_name,'.log');

    /*****************************************************
    * Directory is now the same same as for the out file *
    *****************************************************/
    l_log_dir   := p_dir;

    /*****************************************************************
    * Open The Wrapper File For Output And The Input File for Input. *
    *****************************************************************/
    l_log_handle      :=UTL_FILE.FOPEN(l_log_dir, l_log_name, 'w');
    l_infile_handle   :=UTL_FILE.FOPEN(l_p_dir, l_input_file, 'r');

    /********************************************************
    * Loop thru flat file and call Inventory Quantities API *
    ********************************************************/
    -- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    -- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
    -- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
    -- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
    -- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );
    /*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
    UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Input Directory  ' || l_p_dir );
    UTL_FILE.PUT_LINE(l_log_handle, 'Input File       ' || l_input_file );
    UTL_FILE.PUT_LINE(l_log_handle, 'Record Type      ' || l_delimiter );
    UTL_FILE.PUT_LINE(l_log_handle, 'Output File      ' || l_output_file );
    l_outfile_handle  :=UTL_FILE.FOPEN(l_p_dir, l_output_file, 'w');
    BEGIN
      UTL_FILE.GET_LINE(l_infile_handle, l_line);
      l_record_count    :=l_record_count+1;
      l_type   := Get_Field(l_line,l_delimiter,1) ;  /* = 10 : header rec, 20 : this level, 30 : lower level */
      --UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
      --UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE;
    END;
    LOOP
      BEGIN
        UTL_FILE.PUT_LINE(l_log_handle, '--');
        UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
        UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
        IF l_type = '10' THEN
          /*******************
          * empty the tables *
          *******************/
          l_this_lvl_tbl.delete ;
          l_lower_lvl_tbl.delete ;
          l_costcmpnt_ids.delete;
          l_skip_details := 'N' ;
          l_header_rec.period_id          := Get_Field(l_line,l_delimiter,2) ;
          l_header_rec.calendar_code      := Get_Field(l_line,l_delimiter,3) ;
          l_header_rec.period_code        := Get_Field(l_line,l_delimiter,4) ;
          l_header_rec.cost_type_id       := Get_Field(l_line,l_delimiter,5) ;
          l_header_rec.cost_mthd_code     := Get_Field(l_line,l_delimiter,6) ;
          l_header_rec.organization_id    := Get_Field(l_line,l_delimiter,7) ;
          l_header_rec.organization_code  := Get_Field(l_line,l_delimiter,8) ;
          l_header_rec.inventory_item_id  := Get_Field(l_line,l_delimiter,9) ;
          l_header_rec.item_number        := Get_Field(l_line,l_delimiter,10) ;
          l_header_rec.user_name          := Get_Field(l_line,l_delimiter,11) ;
          l_idx  := 0 ;
          l_idx1 := 0 ;
          -- DBMS_OUTPUT.PUT_LINE('in wrapper. l_this_lvl_tbl count : ' || l_this_lvl_tbl.count) ;
          -- DBMS_OUTPUT.PUT_LINE('in wrapper. l_lower_lvl_tbl count : ' || l_lower_lvl_tbl.count) ;
          -- DBMS_OUTPUT.PUT_LINE('calendar_code   = ' || l_header_rec.calendar_code) ;
          /*
          UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'calendar_code   = ' || l_header_rec.calendar_code) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'period_code   = ' || l_header_rec.period_code) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'cost_mthd_code   = ' || l_header_rec.cost_mthd_code) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'whse_code   = ' || l_header_rec.whse_code) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'item_id   = ' || l_header_rec.item_id) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'item_no   = ' || l_header_rec.item_no) ;
          UTL_FILE.PUT_LINE(l_log_handle, 'user_name   = ' || l_header_rec.user_name) ;
          */
        ELSIF l_type = '20' AND l_skip_details = 'Y' THEN
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skipping this record...');
        ELSIF l_type = '20' AND l_skip_details = 'N' THEN
          l_idx := l_idx + 1 ;
          --UTL_FILE.PUT_LINE(l_log_handle, 'Populating this level table...' || l_idx ) ;
          l_this_lvl_tbl(l_idx).cmpntcost_id         := Get_Field(l_line,l_delimiter,2) ;
          l_this_lvl_tbl(l_idx).cost_cmpntcls_id     := Get_Field(l_line,l_delimiter,3) ;
          l_this_lvl_tbl(l_idx).cost_cmpntcls_code   := Get_Field(l_line,l_delimiter,4) ;
          l_this_lvl_tbl(l_idx).cost_analysis_code   := Get_Field(l_line,l_delimiter,5) ;
          l_this_lvl_tbl(l_idx).cmpnt_cost           := Get_Field(l_line,l_delimiter,6) ;
          l_this_lvl_tbl(l_idx).burden_ind           := Get_Field(l_line,l_delimiter,7) ;
          l_this_lvl_tbl(l_idx).total_qty            := Get_Field(l_line,l_delimiter,8) ;
          l_this_lvl_tbl(l_idx).costcalc_orig        := Get_Field(l_line,l_delimiter,9) ;
          l_this_lvl_tbl(l_idx).rmcalc_type          := Get_Field(l_line,l_delimiter,10) ;
          l_this_lvl_tbl(l_idx).delete_mark          := Get_Field(l_line,l_delimiter,11) ;
          l_this_lvl_tbl(l_idx).attribute1           := Get_Field(l_line,l_delimiter,12) ;
          l_this_lvl_tbl(l_idx).attribute2           := Get_Field(l_line,l_delimiter,13) ;
          l_this_lvl_tbl(l_idx).attribute3           := Get_Field(l_line,l_delimiter,14) ;
          l_this_lvl_tbl(l_idx).attribute4           := Get_Field(l_line,l_delimiter,15) ;
          l_this_lvl_tbl(l_idx).attribute5           := Get_Field(l_line,l_delimiter,16) ;
          l_this_lvl_tbl(l_idx).attribute6           := Get_Field(l_line,l_delimiter,17) ;
          l_this_lvl_tbl(l_idx).attribute7           := Get_Field(l_line,l_delimiter,18) ;
          l_this_lvl_tbl(l_idx).attribute8           := Get_Field(l_line,l_delimiter,19) ;
          l_this_lvl_tbl(l_idx).attribute9           := Get_Field(l_line,l_delimiter,20) ;
          l_this_lvl_tbl(l_idx).attribute10          := Get_Field(l_line,l_delimiter,21) ;
          l_this_lvl_tbl(l_idx).attribute11          := Get_Field(l_line,l_delimiter,22) ;
          l_this_lvl_tbl(l_idx).attribute12          := Get_Field(l_line,l_delimiter,23) ;
          l_this_lvl_tbl(l_idx).attribute13          := Get_Field(l_line,l_delimiter,24) ;
          l_this_lvl_tbl(l_idx).attribute14          := Get_Field(l_line,l_delimiter,25) ;
          l_this_lvl_tbl(l_idx).attribute15          := Get_Field(l_line,l_delimiter,26) ;
          l_this_lvl_tbl(l_idx).attribute16          := Get_Field(l_line,l_delimiter,27) ;
          l_this_lvl_tbl(l_idx).attribute17          := Get_Field(l_line,l_delimiter,28) ;
          l_this_lvl_tbl(l_idx).attribute18          := Get_Field(l_line,l_delimiter,29) ;
          l_this_lvl_tbl(l_idx).attribute19          := Get_Field(l_line,l_delimiter,30) ;
          l_this_lvl_tbl(l_idx).attribute20          := Get_Field(l_line,l_delimiter,31) ;
          l_this_lvl_tbl(l_idx).attribute21          := Get_Field(l_line,l_delimiter,32) ;
          l_this_lvl_tbl(l_idx).attribute22          := Get_Field(l_line,l_delimiter,33) ;
          l_this_lvl_tbl(l_idx).attribute23          := Get_Field(l_line,l_delimiter,34) ;
          l_this_lvl_tbl(l_idx).attribute24          := Get_Field(l_line,l_delimiter,35) ;
          l_this_lvl_tbl(l_idx).attribute25          := Get_Field(l_line,l_delimiter,36) ;
          l_this_lvl_tbl(l_idx).attribute26          := Get_Field(l_line,l_delimiter,37) ;
          l_this_lvl_tbl(l_idx).attribute27          := Get_Field(l_line,l_delimiter,38) ;
          l_this_lvl_tbl(l_idx).attribute28          := Get_Field(l_line,l_delimiter,39) ;
          l_this_lvl_tbl(l_idx).attribute29          := Get_Field(l_line,l_delimiter,40) ;
          l_this_lvl_tbl(l_idx).attribute30          := Get_Field(l_line,l_delimiter,41) ;
          l_this_lvl_tbl(l_idx).attribute_category   := Get_Field(l_line,l_delimiter,42) ;
          /*
          UTL_FILE.PUT_LINE(l_log_handle,'tl cmpntcost_id('||l_idx||') = '||l_this_lvl_tbl(l_idx).cmpntcost_id) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl cost_cmpntcls_id('||l_idx||') = '||l_this_lvl_tbl(l_idx).cost_cmpntcls_id) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl cost_cmpntcls_code('||l_idx||') = '||l_this_lvl_tbl(l_idx).cost_cmpntcls_code) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl cost_analysis_code('||l_idx||') = '||l_this_lvl_tbl(l_idx).cost_analysis_code) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl cmpnt_cost('||l_idx||') = '||l_this_lvl_tbl(l_idx).cmpnt_cost) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl burden_ind('||l_idx||') = '||l_this_lvl_tbl(l_idx).burden_ind) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl total_qty('||l_idx||') = '||l_this_lvl_tbl(l_idx).total_qty) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl costcalc_orig('||l_idx||') = '||l_this_lvl_tbl(l_idx).costcalc_orig) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl rmcalc_type('||l_idx||') = '||l_this_lvl_tbl(l_idx).rmcalc_type) ;
          UTL_FILE.PUT_LINE(l_log_handle,'tl delete_mark('||l_idx||') = '||l_this_lvl_tbl(l_idx).delete_mark) ;
          */
        ELSIF l_type = '30' AND l_skip_details = 'Y' THEN
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skipping this record...');
        ELSIF l_type = '30' AND l_skip_details = 'N'  THEN
          l_idx1 := l_idx1 + 1 ;
          --UTL_FILE.PUT_LINE(l_log_handle, 'Populating lower level table...' || l_idx1 ) ;
          l_type                                       := Get_Field(l_line,l_delimiter,1) ;
          l_lower_lvl_tbl(l_idx1).cmpntcost_id         := Get_Field(l_line,l_delimiter,2) ;
          l_lower_lvl_tbl(l_idx1).cost_cmpntcls_id     := Get_Field(l_line,l_delimiter,3) ;
          l_lower_lvl_tbl(l_idx1).cost_cmpntcls_code   := Get_Field(l_line,l_delimiter,4) ;
          l_lower_lvl_tbl(l_idx1).cost_analysis_code   := Get_Field(l_line,l_delimiter,5) ;
          l_lower_lvl_tbl(l_idx1).cmpnt_cost           := Get_Field(l_line,l_delimiter,6) ;
          l_lower_lvl_tbl(l_idx1).delete_mark          := Get_Field(l_line,l_delimiter,7) ;
          /*
          UTL_FILE.PUT_LINE(l_log_handle,'ll cmpntcost_id('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cmpntcost_id) ;
          UTL_FILE.PUT_LINE(l_log_handle,'ll cost_cmpntcls_id('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cost_cmpntcls_id)      ;
          UTL_FILE.PUT_LINE(l_log_handle,'ll cost_cmpntcls_code('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cost_cmpntcls_code) ;
          UTL_FILE.PUT_LINE(l_log_handle,'ll cost_analysis_code('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cost_analysis_code) ;
          UTL_FILE.PUT_LINE(l_log_handle,'ll cmpnt_cost('||l_idx1||') = '||l_lower_lvl_tbl(l_idx1).cmpnt_cost) ;
          */
        END IF ;
      EXCEPTION
        WHEN OTHERS THEN
          UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
          IF l_type = '10' THEN
            l_skip_details := 'Y' ;
            UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skip detail records.');
          ELSIF l_type = '20' THEN
            l_this_lvl_tbl.delete(l_idx);
            l_idx := l_idx-1;
          ELSIF l_type = '30' THEN
            l_lower_lvl_tbl.delete(l_idx1);
            l_idx1 := l_idx1-1;
          END IF ;
      END ;
      BEGIN
        UTL_FILE.GET_LINE(l_infile_handle, l_line);
        l_record_count    :=l_record_count+1;
        UTL_FILE.NEW_LINE(l_log_handle);
        l_type   := Get_Field(l_line,l_delimiter,1) ;  -- 10 : header rec, 20 : this level, 30 : lower level
        --l_skip_details := 'N' ;
        --UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
        --UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_skip_details = 'N' THEN
            -- DBMS_OUTPUT.PUT_LINE('In exception. Calling Delete_Item_Cost API...');
            GMF_ItemCost_PUB.Delete_Item_Cost
            (
            p_api_version         =>      3.0,
            p_init_msg_list       =>      FND_API.G_TRUE,
            p_commit              =>      FND_API.G_TRUE,
            x_return_status       =>      l_status,
            x_msg_count           =>      l_count,
            x_msg_data            =>      l_data,
            p_header_rec          =>      l_header_rec,
            p_this_level_dtl_tbl  =>      l_this_lvl_tbl,
            p_lower_level_dtl_Tbl =>      l_lower_lvl_tbl
            );
            UTL_FILE.PUT_LINE(l_log_handle, 'in exception. after API call. status := ' || l_status ||' cnt := ' || l_count );
            l_continue := 'N' ;
            GOTO GET_MSG_STACK ;
          END IF ;
      END;
      -- DBMS_OUTPUT.PUT_LINE('Check to call Delete_Item_Cost API...type - ' || l_type || ' count = ' || l_record_count);
      IF (l_type = '10' AND l_record_count <> 1 AND l_skip_details = 'N') THEN
        -- DBMS_OUTPUT.PUT_LINE('Calling Delete_Item_Cost API...');
        GMF_ItemCost_PUB.Delete_Item_Cost
        (
        p_api_version         =>      3.0,
        p_init_msg_list       =>      FND_API.G_TRUE,
        p_commit              =>      FND_API.G_TRUE,
        x_return_status       =>      l_status,
        x_msg_count           =>      l_count,
        x_msg_data            =>      l_data,
        p_header_rec          =>      l_header_rec,
        p_this_level_dtl_tbl  =>      l_this_lvl_tbl,
        p_lower_level_dtl_Tbl =>      l_lower_lvl_tbl
        );
        UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );
      END IF;
      <<GET_MSG_STACK>>
      NULL;

      /*******************************************************************************************
      * Check if any messages generated. If so then decode and output to error message flat file *
      *******************************************************************************************/
      IF l_count > 0 THEN
        l_loop_cnt  :=1;
        LOOP
          FND_MSG_PUB.Get
          (
          p_msg_index     => l_loop_cnt,
          p_data          => l_data,
          p_encoded       => FND_API.G_FALSE,
          p_msg_index_out => l_dummy_cnt
          );
          -- DBMS_OUTPUT.PUT_LINE(l_data );
          --UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
          --UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
          --UTL_FILE.NEW_LINE(l_outfile_handle);
          UTL_FILE.PUT_LINE(l_log_handle, l_data);

          /**********************
          * Update error status *
          **********************/
          IF (l_status = 'U') THEN
            l_return_status  :=l_status;
          ELSIF (l_status = 'E' and l_return_status <> 'U') THEN
            l_return_status  :=l_status;
          ELSE
            l_return_status  :=l_status;
          END IF;
          l_loop_cnt  := l_loop_cnt + 1;
          IF l_loop_cnt > l_count THEN
            EXIT;
          END IF;
        END LOOP; -- msg stack loop
        l_count := 0 ;
      END IF;	-- if count of msg stack > 0
      IF l_continue = 'N' THEN
        EXIT ;
      END IF ;
    END LOOP;
    -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.FCLOSE_ALL;
    RETURN l_return_status;
  EXCEPTION
    WHEN UTL_FILE.INVALID_OPERATION THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_PATH THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_MODE THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.WRITE_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.READ_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INTERNAL_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Internal Error');
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('Other Error');
      UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
      UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
      UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
      UTL_FILE.FCLOSE_ALL;
      l_return_status := 'U' ;
      RETURN l_return_status;
  END Delete_Item_Cost;

/*  Body start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Get_Item_Cost                                                         |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Get Item Cost                                                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the                        |
 |    Get_Item_Cost API wrapper function                                    |
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
 |    27/Feb/2001  Uday Moogala  Created  Bug# 1418689                      |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
  PROCEDURE Get_Item_Cost
  (
  p_dir                 IN              VARCHAR2,
  p_input_file          IN              VARCHAR2,
  p_output_file         IN              VARCHAR2,
  p_delimiter           IN              VARCHAR2
  )
  IS
    /******************
    * Local Variables *
    ******************/
    l_return_status  VARCHAR2(1);
  BEGIN
    l_return_status  :=Get_Item_Cost(p_dir, p_input_file, p_output_file, p_delimiter);
  END Get_Item_Cost;

/* +========================================================================+
 | FUNCTION NAME                                                            |
 |    Get_Item_Cost                                                         |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Get Item Cost                                                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Get_Item_Cost API.                                                    |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_rsrc_wrapper<session_id>.log in the /tmp directory.        |
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

  FUNCTION Get_Item_Cost
  (
  p_dir                 IN              VARCHAR2,
  p_input_file          IN              VARCHAR2,
  p_output_file         IN              VARCHAR2,
  p_delimiter           IN              VARCHAR2
  )
  RETURN VARCHAR2
  IS

    /******************
    * Local variables *
    ******************/
    l_status              VARCHAR2(11);
    l_return_status       VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
    l_count               NUMBER(10)  ;
    l_record_count        NUMBER(10)  :=0;
    l_loop_cnt            NUMBER(10)  :=0;
    l_dummy_cnt           NUMBER(10)  :=0;
    l_data                VARCHAR2(1000);
    l_header_rec          GMF_ItemCost_PUB.Header_Rec_Type;
    l_this_lvl_tbl        GMF_ItemCost_PUB.This_Level_Dtl_Tbl_Type;
    l_lower_lvl_tbl       GMF_ItemCost_PUB.Lower_Level_Dtl_Tbl_Type;
    l_costcmpnt_ids       GMF_ItemCost_PUB.costcmpnt_ids_tbl_type;
    l_p_dir               VARCHAR2(150);
    l_output_file         VARCHAR2(120);
    l_outfile_handle      UTL_FILE.FILE_TYPE;
    l_input_file          VARCHAR2(120);
    l_infile_handle       UTL_FILE.FILE_TYPE;
    l_line                VARCHAR2(1000);
    l_delimiter           VARCHAR(11);
    l_log_dir             VARCHAR2(150);
    l_log_name            VARCHAR2(120)  :='gmf_api_getic_wrapper';
    l_log_handle          UTL_FILE.FILE_TYPE;
    l_global_file         VARCHAR2(120);
    l_idx		              NUMBER(10);
    l_idx1		            NUMBER(10);
    l_type		            VARCHAR2(100);
    l_continue            VARCHAR2(1) := 'Y' ;
    l_skip_details        VARCHAR2(1) := 'N' ;
    l_session_id          VARCHAR2(110);
  BEGIN
    /********************
    * Enable The Buffer *
    ********************/
    /*  DBMS_OUTPUT.ENABLE(1000000); */
    -- DBMS_OUTPUT.PUT_LINE('in Get_Item_Cost function...');
    l_p_dir              :=       p_dir;
    l_input_file         :=       p_input_file;
    l_output_file        :=       p_output_file;
    l_delimiter          :=       p_delimiter;
    l_global_file        :=       l_input_file;

    /*******************************************************
    * Obtain The SessionId To Append To wrapper File Name. *
    *******************************************************/
    l_session_id := USERENV('sessionid');
    l_log_name  := CONCAT(l_log_name,l_session_id);
    l_log_name  := CONCAT(l_log_name,'.log');

    /*****************************************************
    * Directory is now the same same as for the out file *
    *****************************************************/
    l_log_dir   := p_dir;

    /*****************************************************************
    * Open The Wrapper File For Output And The Input File for Input. *
    *****************************************************************/
    l_log_handle      :=UTL_FILE.FOPEN(l_log_dir, l_log_name, 'w');
    l_infile_handle   :=UTL_FILE.FOPEN(l_p_dir, l_input_file, 'r');

    /*  Loop thru flat file and call Inventory Quantities API */
    -- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    -- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
    -- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
    -- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
    -- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );
    /*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
    UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
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
      BEGIN
        UTL_FILE.NEW_LINE(l_log_handle);
        UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
        l_header_rec.period_id          := Get_Field(l_line,l_delimiter,1) ;
        l_header_rec.calendar_code      := Get_Field(l_line,l_delimiter,2) ;
        l_header_rec.period_code        := Get_Field(l_line,l_delimiter,3) ;
        l_header_rec.cost_type_id       := Get_Field(l_line,l_delimiter,4) ;
        l_header_rec.cost_mthd_code     := Get_Field(l_line,l_delimiter,5) ;
        l_header_rec.organization_id    := Get_Field(l_line,l_delimiter,6) ;
        l_header_rec.organization_code  := Get_Field(l_line,l_delimiter,7) ;
        l_header_rec.inventory_item_id  := Get_Field(l_line,l_delimiter,8) ;
        l_header_rec.item_number        := Get_Field(l_line,l_delimiter,9) ;
        l_header_rec.user_name          := Get_Field(l_line,l_delimiter,10) ;
        UTL_FILE.PUT_LINE(l_log_handle, 'Period_id        = ' || l_header_rec.period_id) ;
        UTL_FILE.PUT_LINE(l_log_handle, 'Calendar_code    = ' || l_header_rec.Calendar_code) ;
        UTL_FILE.PUT_LINE(l_log_handle, 'period_code      = ' || l_header_rec.period_code) ;
        UTL_FILE.PUT_LINE(l_log_handle, 'cost_type_id     = ' || l_header_rec.cost_type_id) ;
        UTL_FILE.PUT_LINE(l_log_handle, 'cost_mthd_code   = ' || l_header_rec.cost_mthd_code) ;
        UTL_FILE.PUT_LINE(l_log_handle, 'Organization_id  = ' || l_header_rec.organization_id) ;
        UTL_FILE.PUT_LINE(l_log_handle, 'Organization_code= ' || l_header_rec.organization_code) ;
        UTL_FILE.PUT_LINE(l_log_handle, 'inventory_item_id= ' || l_header_rec.inventory_item_id) ;
        UTL_FILE.PUT_LINE(l_log_handle, 'item_number      = ' || l_header_rec.item_number) ;
        UTL_FILE.PUT_LINE(l_log_handle, 'user_name       = ' || l_header_rec.user_name) ;
        -- DBMS_OUTPUT.PUT_LINE('Calling Get_Item_Cost API...');
        GMF_ItemCost_PUB.Get_Item_Cost
        (
        p_api_version         =>          3.0,
        p_init_msg_list       =>          FND_API.G_TRUE,
        x_return_status       =>          l_status,
        x_msg_count           =>          l_count,
        x_msg_data            =>          l_data,
        p_header_rec          =>          l_header_rec,
        x_this_level_dtl_tbl  =>          l_this_lvl_tbl,
        x_lower_level_dtl_Tbl =>          l_lower_lvl_tbl
        );
        UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );
        IF l_count > 0 THEN
          l_loop_cnt  :=1;
          LOOP
            FND_MSG_PUB.Get
            (
            p_msg_index     => l_loop_cnt,
            p_data          => l_data,
            p_encoded       => FND_API.G_FALSE,
            p_msg_index_out => l_dummy_cnt
            );
            -- DBMS_OUTPUT.PUT_LINE(l_data );
            --UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
            --UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
            --UTL_FILE.NEW_LINE(l_outfile_handle);
            UTL_FILE.PUT_LINE(l_log_handle, l_data);

            /**********************
            * Update error status *
            **********************/
            IF (l_status = 'U') THEN
              l_return_status  :=l_status;
            ELSIF (l_status = 'E' and l_return_status <> 'U') THEN
              l_return_status  :=l_status;
            ELSE
              l_return_status  :=l_status;
            END IF;
            l_loop_cnt  := l_loop_cnt + 1;
            IF l_loop_cnt > l_count THEN
              EXIT;
            END IF;
          END LOOP;
        END IF;
        UTL_FILE.NEW_LINE(l_log_handle);
        UTL_FILE.PUT_LINE( l_log_handle, 'This Level Cost Components : ' ) ;
        FOR i in 1..l_this_lvl_tbl.count LOOP
          UTL_FILE.PUT_LINE( l_log_handle,  ' CostId : '        || l_this_lvl_tbl(i).cmpntcost_id ||
                                            ' CmpntClsId : '    || l_this_lvl_tbl(i).cost_cmpntcls_id ||
                                            ' CmpntCls Code : ' || l_this_lvl_tbl(i).cost_cmpntcls_Code ||
                                            ' Analysis Code : ' || l_this_lvl_tbl(i).cost_analysis_code ||
                                            ' Cmpt Cost : '     || l_this_lvl_tbl(i).cmpnt_cost) ;
        END LOOP ;
        UTL_FILE.NEW_LINE(l_log_handle);
        UTL_FILE.PUT_LINE( l_log_handle, 'Lower Level Cost Components : ' ) ;
        FOR i in 1..l_lower_lvl_tbl.count LOOP
          UTL_FILE.PUT_LINE( l_log_handle,  ' CostId : '        || l_lower_lvl_tbl(i).cmpntcost_id ||
                                            ' CmpntClsId : '    || l_lower_lvl_tbl(i).cost_cmpntcls_id ||
                                            ' CmpntCls Code : ' || l_lower_lvl_tbl(i).cost_cmpntcls_Code ||
                                            ' Analysis Code : ' || l_lower_lvl_tbl(i).cost_analysis_code ||
                                            ' Cmpt Cost : '     || l_lower_lvl_tbl(i).cmpnt_cost) ;
        END LOOP ;
      EXCEPTION
        WHEN OTHERS THEN
          UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
          l_return_status := 'U' ;
      END ;
    END LOOP;
    -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.FCLOSE_ALL;
    RETURN l_return_status;
  EXCEPTION
    WHEN UTL_FILE.INVALID_OPERATION THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_PATH THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_MODE THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.WRITE_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.READ_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INTERNAL_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Internal Error');
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('Other Error');
      UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
      UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
      UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
      UTL_FILE.FCLOSE_ALL;
      l_return_status := 'U' ;
      RETURN l_return_status;
  END Get_Item_Cost;

--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Process_ActualCost_Adjustment                                         |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Create/Insert, Update,Delete Actual Lot Cost Adjustment               |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This is a PL/SQL wrapper procedure to call the                        |
--|    Call_ActualCost_API wrapper function	   		                           |
--|                                                                          |
--| PARAMETERS                                                               |
--|    p_dir              IN VARCHAR2         - Working directory for input  |
--|                                             and output files.            |
--|    p_input_file       IN VARCHAR2         - Name of input file           |
--|    p_output_file      IN VARCHAR2         - Name of output file          |
--|    p_delimiter        IN VARCHAR2         - Delimiter character          |
--|    p_operation	  IN VARCHAR2	      - Operation to be performed          |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    30/Oct/2005  Anand Thiyagarajan      Created                          |
--|                                                                          |
--+==========================================================================+

  PROCEDURE Process_ActualCost_Adjustment
  (
  p_dir                   IN            VARCHAR2,
  p_input_file            IN            VARCHAR2,
  p_output_file           IN            VARCHAR2,
  p_delimiter             IN            VARCHAR2,
  p_operation             IN            VARCHAR2
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_return_status  VARCHAR2(1);
  BEGIN
    l_return_status  := Process_ActualCost_Adjustment(p_dir, p_input_file, p_output_file, p_delimiter, p_operation);
  End Process_ActualCost_Adjustment;

/* +==========================================================================+
 | FUNCTION NAME                                                              |
 |    Process_ActualCost_Adjustment                                           |
 |                                                                            |
 | TYPE                                                                       |
 |    Public                                                                  |
 |                                                                            |
 | USAGE                                                                      |
 |    Create/Insert, Update or Delete Actual Cost Adjustment                  |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This is a PL/SQL wrapper function to call the                           |
 |    Call_ActualCost_API.							                                      |
 |    It reads item data from a flat file and outputs any error               |
 |    messages to a second flat file. It also generates a Status              |
 |    called gmf_api_<operation>_wrapper<session_id>.log in the /tmp directory|
 |                                                                            |
 | PARAMETERS                                                                 |
 |    p_dir              IN VARCHAR2         - Working directory for input    |
 |                                             and output files.              |
 |    p_input_file       IN VARCHAR2         - Name of input file             |
 |    p_output_file      IN VARCHAR2         - Name of output file            |
 |    p_delimiter        IN VARCHAR2         - Delimiter character            |
 |    p_operation	  IN VARCHAR2	     - Operation to be performed              |
 |									                                                          |
 | RETURNS                                                                    |
 |    VARCHAR2 - 'S' All records processed successfully                       |
 |               'E' 1 or more records errored                                |
 |               'U' 1 or more record unexpected error                        |
 |                                                                            |
 | HISTORY                                                                    |
 |    30-Oct-2005     Anand Thiyagarajan      Created                         |
 |                                                                            |
 +============================================================================+
  Api end of comments
*/
  FUNCTION Process_ActualCost_Adjustment
  (
  p_dir                   IN            VARCHAR2,
  p_input_file            IN            VARCHAR2,
  p_output_file           IN            VARCHAR2,
  p_delimiter             IN            VARCHAR2,
  p_operation             IN            VARCHAR2
  )
  RETURN VARCHAR2
  IS

    /******************
    * Local variables *
    ******************/
    l_status              VARCHAR2(11);
    l_return_status       VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
    l_count               NUMBER(10)  ;
    l_record_count        NUMBER(10)  :=0;
    l_loop_cnt            NUMBER(10)  :=0;
    l_dummy_cnt           NUMBER(10)  :=0;
    l_data                VARCHAR2(32767);
    l_adjustment_rec      GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE;
    l_p_dir               VARCHAR2(150);
    l_output_file         VARCHAR2(120);
    l_outfile_handle      UTL_FILE.FILE_TYPE;
    l_input_file          VARCHAR2(120);
    l_infile_handle       UTL_FILE.FILE_TYPE;
    l_line                VARCHAR2(32767);
    l_delimiter           VARCHAR(11);
    l_log_dir             VARCHAR2(150);
    l_log_name            VARCHAR2(120) ;
    l_log_handle          UTL_FILE.FILE_TYPE;
    l_global_file         VARCHAR2(120);
    l_idx		              NUMBER(10);
    l_idx1		            NUMBER(10);
    l_type		            VARCHAR2(32767);
    l_continue            VARCHAR2(1) := 'Y' ;
    l_skip_details        VARCHAR2(1) := 'N' ;
    l_session_id          VARCHAR2(110);
  BEGIN
    /********************
    * Enable The Buffer *
    ********************/
    l_p_dir               :=        p_dir;
    l_log_dir	            :=        p_dir;
    l_input_file          :=        p_input_file;
    l_output_file         :=        p_output_file;
    l_delimiter           :=        p_delimiter;
    l_global_file         :=        l_input_file;
    IF p_operation = 'INSERT' THEN
      l_log_name := 'gmf_api_crtacadj_wrapper' ;
    ELSIF p_operation = 'UPDATE' THEN
      l_log_name := 'gmf_api_updacadj_wrapper' ;
    ELSIF p_operation = 'DELETE' THEN
      l_log_name := 'gmf_api_delacadj_wrapper' ;
    END IF ;

    /*******************************************************
    * Obtain The SessionId To Append To wrapper File Name. *
    *******************************************************/
    l_session_id := USERENV('sessionid');
    l_log_name  := CONCAT(l_log_name,l_session_id);
    l_log_name  := CONCAT(l_log_name,'.log');

    /*****************************************************
    * Directory is now the same same as for the out file *
    *****************************************************/
    l_log_dir   := p_dir;

    /*****************************************************************
    * Open The Wrapper File For Output And The Input File for Input. *
    *****************************************************************/
    l_log_handle      :=UTL_FILE.FOPEN(l_log_dir, l_log_name, 'w');
    l_infile_handle   :=UTL_FILE.FOPEN(l_p_dir, l_input_file, 'r');
    /*
    DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
    DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
    DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
    DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );
    */

    UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Input Directory  ' || l_p_dir );
    UTL_FILE.PUT_LINE(l_log_handle, 'Input File       ' || l_input_file );
    UTL_FILE.PUT_LINE(l_log_handle, 'Record Type      ' || l_delimiter );
    UTL_FILE.PUT_LINE(l_log_handle, 'Output File      ' || l_output_file );
    l_outfile_handle  :=UTL_FILE.FOPEN(l_p_dir, l_output_file, 'w');
    LOOP
      l_record_count    :=l_record_count+1;
      BEGIN
        UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || to_char(l_record_count));
        UTL_FILE.GET_LINE(l_infile_handle, l_line);
        IF l_line IS NOT NULL THEN
          l_adjustment_rec.cost_adjust_id       :=	 Get_Field(l_line,l_delimiter,1);
          l_adjustment_rec.organization_id      :=	 Get_Field(l_line,l_delimiter,2);
          l_adjustment_rec.organization_code    :=	 Get_Field(l_line,l_delimiter,3);
          l_adjustment_rec.inventory_item_id    :=	 Get_Field(l_line,l_delimiter,4);
          l_adjustment_rec.item_number          :=	 Get_Field(l_line,l_delimiter,5);
          l_adjustment_rec.cost_type_id         :=	 Get_Field(l_line,l_delimiter,6);
          l_adjustment_rec.cost_mthd_code       :=	 Get_Field(l_line,l_delimiter,7);
          l_adjustment_rec.period_id            :=	 Get_Field(l_line,l_delimiter,8);
          l_adjustment_rec.calendar_code        :=	 Get_Field(l_line,l_delimiter,9);
          l_adjustment_rec.period_code          :=	 Get_Field(l_line,l_delimiter,10);
          l_adjustment_rec.cost_cmpntcls_id     :=	 Get_Field(l_line,l_delimiter,11);
          l_adjustment_rec.cost_cmpntcls_code   :=	 Get_Field(l_line,l_delimiter,12);
          l_adjustment_rec.cost_analysis_code   :=	 Get_Field(l_line,l_delimiter,13);
          l_adjustment_rec.adjust_qty           :=	 Get_Field(l_line,l_delimiter,14);
          l_adjustment_rec.adjust_qty_uom       :=	 Get_Field(l_line,l_delimiter,15);
          l_adjustment_rec.adjust_cost          :=	 Get_Field(l_line,l_delimiter,16);
          l_adjustment_rec.reason_code          :=	 Get_Field(l_line,l_delimiter,17);
          l_adjustment_rec.adjust_status        :=	 Get_Field(l_line,l_delimiter,18);
          l_adjustment_rec.delete_mark          :=	 Get_Field(l_line,l_delimiter,19);
          l_adjustment_rec.attribute1           :=	 Get_Field(l_line,l_delimiter,20);
          l_adjustment_rec.attribute2           :=	 Get_Field(l_line,l_delimiter,21);
          l_adjustment_rec.attribute3           :=	 Get_Field(l_line,l_delimiter,22);
          l_adjustment_rec.attribute4           :=	 Get_Field(l_line,l_delimiter,23);
          l_adjustment_rec.attribute5           :=	 Get_Field(l_line,l_delimiter,24);
          l_adjustment_rec.attribute6           :=	 Get_Field(l_line,l_delimiter,25);
          l_adjustment_rec.attribute7           :=	 Get_Field(l_line,l_delimiter,26);
          l_adjustment_rec.attribute8           :=	 Get_Field(l_line,l_delimiter,27);
          l_adjustment_rec.attribute9           :=	 Get_Field(l_line,l_delimiter,28);
          l_adjustment_rec.attribute10          :=	 Get_Field(l_line,l_delimiter,29);
          l_adjustment_rec.attribute11          :=	 Get_Field(l_line,l_delimiter,30);
          l_adjustment_rec.attribute12          :=	 Get_Field(l_line,l_delimiter,31);
          l_adjustment_rec.attribute13          :=	 Get_Field(l_line,l_delimiter,32);
          l_adjustment_rec.attribute14          :=	 Get_Field(l_line,l_delimiter,33);
          l_adjustment_rec.attribute15          :=	 Get_Field(l_line,l_delimiter,34);
          l_adjustment_rec.attribute16          :=	 Get_Field(l_line,l_delimiter,35);
          l_adjustment_rec.attribute17          :=	 Get_Field(l_line,l_delimiter,36);
          l_adjustment_rec.attribute18          :=	 Get_Field(l_line,l_delimiter,37);
          l_adjustment_rec.attribute19          :=	 Get_Field(l_line,l_delimiter,38);
          l_adjustment_rec.attribute20          :=	 Get_Field(l_line,l_delimiter,39);
          l_adjustment_rec.attribute21          :=	 Get_Field(l_line,l_delimiter,40);
          l_adjustment_rec.attribute22          :=	 Get_Field(l_line,l_delimiter,41);
          l_adjustment_rec.attribute23          :=	 Get_Field(l_line,l_delimiter,42);
          l_adjustment_rec.attribute24          :=	 Get_Field(l_line,l_delimiter,43);
          l_adjustment_rec.attribute25          :=	 Get_Field(l_line,l_delimiter,44);
          l_adjustment_rec.attribute26          :=	 Get_Field(l_line,l_delimiter,45);
          l_adjustment_rec.attribute27          :=	 Get_Field(l_line,l_delimiter,46);
          l_adjustment_rec.attribute28          :=	 Get_Field(l_line,l_delimiter,47);
          l_adjustment_rec.attribute29          :=	 Get_Field(l_line,l_delimiter,48);
          l_adjustment_rec.attribute30          :=	 Get_Field(l_line,l_delimiter,49);
          l_adjustment_rec.attribute_category   :=	 Get_Field(l_line,l_delimiter,50);
          l_adjustment_rec.adjustment_ind       :=	 Get_Field(l_line,l_delimiter,51);
          l_adjustment_rec.subledger_ind        :=	 Get_Field(l_line,l_delimiter,52);
          l_adjustment_rec.adjustment_date		  :=   fnd_date.canonical_to_date(Get_Field(l_line,l_delimiter,53));
          l_adjustment_rec.user_name            :=	 Get_Field(l_line,l_delimiter,54);

          Call_ActualCost_API
          (
          p_adjustment_rec		=>        l_adjustment_rec,
          p_operation    	    =>        p_operation,
          x_status       	    =>        l_status,
          x_count    		      =>        l_count,
          x_data         	    =>        l_data
          );
        ELSE
          l_continue := 'N';
        END IF;
      EXCEPTION
        WHEN no_data_found THEN
          l_continue := 'N';
        WHEN OTHERS THEN
	        UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
          l_continue := 'N' ;
      END;

      /*******************************************************************************************
      * Check if any messages generated. If so then decode and output to error message flat file *
      *******************************************************************************************/
      IF l_count > 0 THEN
        l_loop_cnt  :=1;
        LOOP
          FND_MSG_PUB.Get
          (
          p_msg_index     => l_loop_cnt,
          p_data          => l_data,
          p_encoded       => FND_API.G_FALSE,
          p_msg_index_out => l_dummy_cnt
          );
          UTL_FILE.PUT_LINE(l_log_handle, l_data);

          /**********************
          * Update error status *
          **********************/
          IF (l_status = 'U') THEN
            l_return_status  :=l_status;
          ELSIF (l_status = 'E' and l_return_status <> 'U') THEN
            l_return_status  :=l_status;
          ELSE
            l_return_status  :=l_status;
          END IF;
          l_loop_cnt  := l_loop_cnt + 1;
          IF l_loop_cnt > l_count THEN
            EXIT;
          END IF;
        END LOOP;
        l_count := 0 ;
      END IF;
      IF l_continue = 'N' THEN
        EXIT ;
      END IF ;
    END LOOP;
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.FCLOSE_ALL;
    RETURN l_return_status;
  EXCEPTION
    WHEN UTL_FILE.INVALID_OPERATION THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_PATH THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_MODE THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.WRITE_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.READ_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INTERNAL_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Internal Error');
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('Other Error');
      UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
      UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
      UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
      UTL_FILE.FCLOSE_ALL;
      l_return_status := 'U' ;
      RETURN l_return_status;
END Process_ActualCost_Adjustment;

/* +============================================================================+
 | PROCEDURE NAME                                                               |
 |    Call_ActualCost_API							                                          |
 |                                                                              |
 | TYPE                                                                         |
 |    Public                                                                    |
 |										                                                          |
 | USAGE									                                                      |
 |    Calls Actual Cost Adjsutment APIs based on the operation being performed	|
 |										                                                          |
 | DESCRIPTION									                                                |
 |    This is a PL/SQL wrapper function to call the Actual Cost Adjustment API. |
 |    Data is sent from through the parameters.					                        |
 |										                                                          |
 | PARAMETERS                                                                   |
 |    p_adjustment_rec	    IN VARCHAR2         - Adjustment Details		        |
 |    p_operation	    IN VARCHAR2         - Insert/Update/Delete		            |
 |    x_status              OUT VARCHAR2        - Return Status			            |
 |    x_count               OUT VARCHAR2        - # of msgs on message stack	  |
 |    x_data                OUT VARCHAR2        - Actual Message from msg stack	|
 |										                                                          |
 |										                                                          |
 | HISTORY									                                                    |
 |     30-Oct-2005 Anand Thiyagarajan Created                                   |
 +==============================================================================+
*/

  PROCEDURE Call_ActualCost_API
  (
  p_adjustment_rec		      IN  OUT   NOCOPY    GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE,
  p_operation               IN			            VARCHAR2,
  x_status                      OUT		NOCOPY	  VARCHAR2,
  x_count                       OUT		NOCOPY	  NUMBER,
  x_data                        OUT		NOCOPY	  VARCHAR2
  )
  IS
  BEGIN
    IF p_operation = 'INSERT' THEN
      GMF_ACTUAL_COST_ADJUSTMENT_PUB.CREATE_ACTUAL_COST_ADJUSTMENT
      (
      p_api_version			        =>              1.0,
      p_init_msg_list		        =>              FND_API.G_TRUE,
      p_commit		              =>              FND_API.G_TRUE,
      x_return_status		        =>              x_status,
      x_msg_count			          =>              x_count,
      x_msg_data			          =>              x_data,
      p_adjustment_rec			    =>              p_adjustment_rec
      );
    ELSIF p_operation = 'UPDATE' THEN
      GMF_ACTUAL_COST_ADJUSTMENT_PUB.UPDATE_ACTUAL_COST_ADJUSTMENT
      (
      p_api_version			        =>              1.0,
      p_init_msg_list		        =>              FND_API.G_TRUE,
      p_commit		              =>              FND_API.G_TRUE,
      x_return_status		        =>              x_status,
      x_msg_count			          =>              x_count,
      x_msg_data			          =>              x_data,
      p_adjustment_rec			    =>              p_adjustment_rec
      );
    ELSIF p_operation = 'DELETE' THEN
      GMF_ACTUAL_COST_ADJUSTMENT_PUB.DELETE_ACTUAL_COST_ADJUSTMENT
      (
      p_api_version			        =>              1.0,
      p_init_msg_list		        =>              FND_API.G_TRUE,
      p_commit		              =>              FND_API.G_TRUE,
      x_return_status		        =>              x_status,
      x_msg_count			          =>              x_count,
      x_msg_data			          =>              x_data,
      p_adjustment_rec			    =>              p_adjustment_rec
      );
    END IF ;
  END Call_ActualCost_API ;

/* +========================================================================+
 | FUNCTION NAME                                                            |
 |    Get_ActualCost_Adjsutment                                             |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Get Actual Cost Adjustment Details                                    |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Get_ActualCost_Adjustment API.                                        |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_rsrc_wrapper<session_id>.log in the /tmp directory.        |
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
 |    28-Oct-2005 Anand Thiyagarajan Created                                |
 |									                                                        |
 +==========================================================================+
*/

  FUNCTION Get_ActualCost_Adjustment
  (
  p_dir                     IN                VARCHAR2,
  p_input_file              IN                VARCHAR2,
  p_output_file             IN                VARCHAR2,
  p_delimiter               IN                VARCHAR2
  )
  RETURN VARCHAR2
  IS

    /******************
    * Local variables *
    ******************/
    l_status                VARCHAR2(11);
    l_return_status         VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
    l_count                 NUMBER(10)  ;
    l_record_count          NUMBER(10)  :=0;
    l_loop_cnt              NUMBER(10)  :=0;
    l_dummy_cnt             NUMBER(10)  :=0;
    l_data                  VARCHAR2(1000);
    l_adjustment_rec        GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE;
    l_p_dir                 VARCHAR2(150);
    l_output_file           VARCHAR2(120);
    l_outfile_handle        UTL_FILE.FILE_TYPE;
    l_input_file            VARCHAR2(120);
    l_infile_handle         UTL_FILE.FILE_TYPE;
    l_line                  VARCHAR2(1000);
    l_delimiter             VARCHAR(11);
    l_log_dir               VARCHAR2(150);
    l_log_name              VARCHAR2(120) :='gmf_api_getactualcost_wrapper';
    l_log_handle            UTL_FILE.FILE_TYPE;
    l_global_file           VARCHAR2(120);
    l_idx		                NUMBER(10);
    l_idx1		              NUMBER(10);
    l_continue              VARCHAR2(1) := 'Y' ;
    l_skip_details          VARCHAR2(1) := 'N' ;
    l_session_id            VARCHAR2(110);
  BEGIN

    /********************
    * Enable The Buffer *
    ********************/
    l_p_dir               :=        p_dir;
    l_log_dir	            :=        p_dir;
    l_input_file          :=        p_input_file;
    l_output_file         :=        p_output_file;
    l_delimiter           :=        p_delimiter;
    l_global_file         :=        l_input_file;

    /*******************************************************
    * Obtain The SessionId To Append To wrapper File Name. *
    *******************************************************/
    l_session_id := USERENV('sessionid');
    l_log_name  := CONCAT(l_log_name,l_session_id);
    l_log_name  := CONCAT(l_log_name,'.log');

    /*****************************************************
    * Directory is now the same same as for the out file *
    *****************************************************/
    l_log_dir   := p_dir;

    /****************************************************************
    * Open The Wrapper File For Output And The Input File for Input *
    ****************************************************************/
    l_log_handle      :=UTL_FILE.FOPEN(l_log_dir, l_log_name, 'w');
    l_infile_handle   :=UTL_FILE.FOPEN(l_p_dir, l_input_file, 'r');
    -- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    -- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
    -- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
    -- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
    -- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );
    UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Input Directory  ' || l_p_dir );
    UTL_FILE.PUT_LINE(l_log_handle, 'Input File       ' || l_input_file );
    UTL_FILE.PUT_LINE(l_log_handle, 'Record Type      ' || l_delimiter );
    UTL_FILE.PUT_LINE(l_log_handle, 'Output File      ' || l_output_file );
    l_outfile_handle  :=UTL_FILE.FOPEN(l_p_dir, l_output_file, 'w');
    LOOP
      l_record_count    :=l_record_count+1;
      BEGIN
        UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || to_char(l_record_count));
        UTL_FILE.GET_LINE(l_infile_handle, l_line);
        l_adjustment_rec.cost_adjust_id       :=	 Get_Field(l_line,l_delimiter,1);
        l_adjustment_rec.organization_id      :=	 Get_Field(l_line,l_delimiter,2);
        l_adjustment_rec.organization_code    :=	 Get_Field(l_line,l_delimiter,3);
        l_adjustment_rec.inventory_item_id    :=	 Get_Field(l_line,l_delimiter,4);
        l_adjustment_rec.item_number          :=	 Get_Field(l_line,l_delimiter,5);
        l_adjustment_rec.cost_type_id         :=	 Get_Field(l_line,l_delimiter,6);
        l_adjustment_rec.cost_mthd_code       :=	 Get_Field(l_line,l_delimiter,7);
        l_adjustment_rec.period_id            :=	 Get_Field(l_line,l_delimiter,8);
        l_adjustment_rec.calendar_code        :=	 Get_Field(l_line,l_delimiter,9);
        l_adjustment_rec.period_code          :=	 Get_Field(l_line,l_delimiter,10);
        l_adjustment_rec.cost_cmpntcls_id     :=	 Get_Field(l_line,l_delimiter,11);
        l_adjustment_rec.cost_cmpntcls_code   :=	 Get_Field(l_line,l_delimiter,12);
        l_adjustment_rec.cost_analysis_code   :=	 Get_Field(l_line,l_delimiter,13);
        l_adjustment_rec.adjust_qty           :=	 Get_Field(l_line,l_delimiter,14);
        l_adjustment_rec.adjust_qty_uom       :=	 Get_Field(l_line,l_delimiter,15);
        l_adjustment_rec.adjust_cost          :=	 Get_Field(l_line,l_delimiter,16);
        l_adjustment_rec.reason_code          :=	 Get_Field(l_line,l_delimiter,17);
        l_adjustment_rec.adjust_status        :=	 Get_Field(l_line,l_delimiter,18);
        l_adjustment_rec.delete_mark          :=	 Get_Field(l_line,l_delimiter,19);
        l_adjustment_rec.attribute1           :=	 Get_Field(l_line,l_delimiter,20);
        l_adjustment_rec.attribute2           :=	 Get_Field(l_line,l_delimiter,21);
        l_adjustment_rec.attribute3           :=	 Get_Field(l_line,l_delimiter,22);
        l_adjustment_rec.attribute4           :=	 Get_Field(l_line,l_delimiter,23);
        l_adjustment_rec.attribute5           :=	 Get_Field(l_line,l_delimiter,24);
        l_adjustment_rec.attribute6           :=	 Get_Field(l_line,l_delimiter,25);
        l_adjustment_rec.attribute7           :=	 Get_Field(l_line,l_delimiter,26);
        l_adjustment_rec.attribute8           :=	 Get_Field(l_line,l_delimiter,27);
        l_adjustment_rec.attribute9           :=	 Get_Field(l_line,l_delimiter,28);
        l_adjustment_rec.attribute10          :=	 Get_Field(l_line,l_delimiter,29);
        l_adjustment_rec.attribute11          :=	 Get_Field(l_line,l_delimiter,30);
        l_adjustment_rec.attribute12          :=	 Get_Field(l_line,l_delimiter,31);
        l_adjustment_rec.attribute13          :=	 Get_Field(l_line,l_delimiter,32);
        l_adjustment_rec.attribute14          :=	 Get_Field(l_line,l_delimiter,33);
        l_adjustment_rec.attribute15          :=	 Get_Field(l_line,l_delimiter,34);
        l_adjustment_rec.attribute16          :=	 Get_Field(l_line,l_delimiter,35);
        l_adjustment_rec.attribute17          :=	 Get_Field(l_line,l_delimiter,36);
        l_adjustment_rec.attribute18          :=	 Get_Field(l_line,l_delimiter,37);
        l_adjustment_rec.attribute19          :=	 Get_Field(l_line,l_delimiter,38);
        l_adjustment_rec.attribute20          :=	 Get_Field(l_line,l_delimiter,39);
        l_adjustment_rec.attribute21          :=	 Get_Field(l_line,l_delimiter,40);
        l_adjustment_rec.attribute22          :=	 Get_Field(l_line,l_delimiter,41);
        l_adjustment_rec.attribute23          :=	 Get_Field(l_line,l_delimiter,42);
        l_adjustment_rec.attribute24          :=	 Get_Field(l_line,l_delimiter,43);
        l_adjustment_rec.attribute25          :=	 Get_Field(l_line,l_delimiter,44);
        l_adjustment_rec.attribute26          :=	 Get_Field(l_line,l_delimiter,45);
        l_adjustment_rec.attribute27          :=	 Get_Field(l_line,l_delimiter,46);
        l_adjustment_rec.attribute28          :=	 Get_Field(l_line,l_delimiter,47);
        l_adjustment_rec.attribute29          :=	 Get_Field(l_line,l_delimiter,48);
        l_adjustment_rec.attribute30          :=	 Get_Field(l_line,l_delimiter,49);
        l_adjustment_rec.attribute_category   :=	 Get_Field(l_line,l_delimiter,50);
        l_adjustment_rec.adjustment_ind       :=	 Get_Field(l_line,l_delimiter,51);
        l_adjustment_rec.subledger_ind        :=	 Get_Field(l_line,l_delimiter,52);
        l_adjustment_rec.adjustment_date		  :=	 fnd_date.canonical_to_date(Get_Field(l_line,l_delimiter,53));
        l_adjustment_rec.user_name            :=	 Get_Field(l_line,l_delimiter,54);

        GMF_ACTUAL_COST_ADJUSTMENT_PUB.GET_ACTUAL_COST_ADJUSTMENT
        (
        p_api_version			        =>              1.0,
        p_init_msg_list		        =>              FND_API.G_TRUE,
        x_return_status		        =>              l_status,
        x_msg_count			          =>              l_count,
        x_msg_data			          =>              l_data,
        p_adjustment_rec			    =>              l_adjustment_rec
        );

        UTL_FILE.PUT_LINE(l_log_handle, 'After API call. status := ' || l_status ||' cnt := ' || l_count );

      EXCEPTION
        WHEN OTHERS THEN
	        UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
          l_continue := 'N' ;
      END;

      /*******************************************************************************************
      * Check if any messages generated. If so then decode and output to error message flat file *
      *******************************************************************************************/
      IF l_count > 0 THEN
        l_loop_cnt  :=1;
        LOOP
          FND_MSG_PUB.Get
          (
          p_msg_index     => l_loop_cnt,
          p_data          => l_data,
          p_encoded       => FND_API.G_FALSE,
          p_msg_index_out => l_dummy_cnt
          );
          UTL_FILE.PUT_LINE(l_log_handle, l_data);

          /**********************
          * Update error status *
          **********************/
          IF (l_status = 'U') THEN
            l_return_status  :=l_status;
          ELSIF (l_status = 'E' and l_return_status <> 'U') THEN
            l_return_status  :=l_status;
          ELSE
            l_return_status  :=l_status;
          END IF;
          l_loop_cnt  := l_loop_cnt + 1;
          IF l_loop_cnt > l_count THEN
            EXIT;
          END IF;
        END LOOP;
        l_count := 0 ;
      END IF;
      UTL_FILE.NEW_LINE(l_log_handle);
      UTL_FILE.NEW_LINE(l_log_handle);
      UTL_FILE.NEW_LINE(l_log_handle);
      IF l_continue = 'N' THEN
        EXIT;
      END IF;
    END LOOP;
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.FCLOSE_ALL;
    RETURN l_return_status;
  EXCEPTION
    WHEN UTL_FILE.INVALID_OPERATION THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_PATH THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_MODE THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.WRITE_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.READ_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file);
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN UTL_FILE.INTERNAL_ERROR THEN
      -- DBMS_OUTPUT.PUT_LINE('Internal Error');
      UTL_FILE.FCLOSE_ALL;
      RETURN l_return_status;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('Other Error');
      UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
      UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
      UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
      UTL_FILE.FCLOSE_ALL;
      l_return_status := 'U' ;
      RETURN l_return_status;
  END Get_ActualCost_Adjustment;


  /*  Body start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Create_Alloc_Def                                                      |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Create Allocation Definition                                          |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This is a PL/SQL wrapper procedure to call the                        |
--|    Create_Allocation_definition API wrapper function                     |
--|                                                                          |
--| PARAMETERS                                                               |
--|    p_dir              IN VARCHAR2         - Working directory for input  |
--|                                             and output files.            |
--|    p_input_file       IN VARCHAR2         - Name of input file           |
--|    p_output_file      IN VARCHAR2         - Name of output file          |
--|    p_delimiter        IN VARCHAR2         - Delimiter character          |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    27/Feb/2001  Uday Moogala      Created             Bug# 1418689       |
--|    30/Oct/2002  R.Sharath Kumar   Added NOCOPY hint   Bug# 2641405       |
--|                                                                          |
--+==========================================================================+
  Api end of comments
*/
PROCEDURE Create_Alloc_Def
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

 ---- DBMS_OUTPUT.PUT_LINE('in Create_Alloc_Def procedure... ');
l_return_status  :=Create_Alloc_Def( p_dir
			      	     , p_input_file
                                     , p_output_file
                                     , p_delimiter
                                   );

 -- DBMS_OUTPUT.PUT_LINE('return status := ' || l_return_status);
End Create_Alloc_Def;

/* +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Create_Alloc_Def                                                      |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create Allocation Definition                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Create_Allocation_definition API.                                     |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_aloc_wrapper<session_id>.log in the /tmp directory.                 |
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
FUNCTION Create_Alloc_Def
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2
IS

/* Local variables */

l_status             VARCHAR2(11);
l_return_status      VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER(10)  ;
l_record_count       NUMBER(10)  :=0;
l_loop_cnt           NUMBER(10)  :=0;
l_dummy_cnt          NUMBER(10)  :=0;
l_data               VARCHAR2(2000);
alloc_rec            GMF_ALLOCATIONDEFINITION_PUB.Allocation_Definition_Rec_Type;
l_p_dir              VARCHAR2(150);
l_output_file        VARCHAR2(120);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(120);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(1800);
l_delimiter          VARCHAR(11);
l_log_dir            VARCHAR2(150);
l_log_name           VARCHAR2(120)  :='gmf_api_cralloc_wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(120);

l_session_id         VARCHAR2(110);

BEGIN

/*  Enable The Buffer  */
/*  DBMS_OUTPUT.ENABLE(1000000); */

-- DBMS_OUTPUT.PUT_LINE('in Create_Alloc_Def function...');

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

/*  Loop thru flat file and call Inventory Quantities API */
-- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
-- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
-- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
-- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
-- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );


/*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
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

BEGIN
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );

  alloc_rec.alloc_id            := Get_Field(l_line,l_delimiter,1) ;
  alloc_rec.alloc_code          := Get_Field(l_line,l_delimiter,2) ;
  alloc_rec.legal_entity_id     := Get_Field(l_line,l_delimiter,3) ;
  alloc_rec.alloc_method        := Get_Field(l_line,l_delimiter,4) ;
  alloc_rec.line_no             := Get_Field(l_line,l_delimiter,5) ;
  alloc_rec.organization_id     := Get_Field(l_line,l_delimiter,6) ;
  alloc_rec.organization_code   := Get_Field(l_line,l_delimiter,7) ;
  alloc_rec.item_id             := Get_Field(l_line,l_delimiter,8) ;
  alloc_rec.item_number         := Get_Field(l_line,l_delimiter,9) ;
  alloc_rec.basis_account_id    := Get_Field(l_line,l_delimiter,10) ;
  alloc_rec.basis_account_key   := Get_Field(l_line,l_delimiter,11) ;
  alloc_rec.balance_type        := Get_Field(l_line,l_delimiter,12) ;
  alloc_rec.bas_ytd_ptd         := Get_Field(l_line,l_delimiter,13) ;
  alloc_rec.basis_type          := Get_Field(l_line,l_delimiter,14) ;
  alloc_rec.fixed_percent       := Get_Field(l_line,l_delimiter,15) ;
  alloc_rec.cmpntcls_id         := Get_Field(l_line,l_delimiter,16) ;
  alloc_rec.cost_cmpntcls_code  := Get_Field(l_line,l_delimiter,17) ;
  alloc_rec.analysis_code       := Get_Field(l_line,l_delimiter,18) ;
  alloc_rec.delete_mark         := Get_Field(l_line,l_delimiter,19) ;
  alloc_rec.user_name           := Get_Field(l_line,l_delimiter,20) ;
  /*
  UTL_FILE.PUT_LINE(l_log_handle, 'alloc_id     	= ' || alloc_rec.alloc_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'alloc_code     	= ' || alloc_rec.alloc_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'co_code     		= ' || alloc_rec.co_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'alloc_method 	= ' || alloc_rec.alloc_method) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'line_no      	= ' || alloc_rec.line_no) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'item_id      	= ' || alloc_rec.item_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'item_no      	= ' || alloc_rec.item_no) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'basis_account_key    = ' || alloc_rec.basis_account_key) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'balance_type 	= ' || alloc_rec.balance_type) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'bas_ytd_ptd  	= ' || alloc_rec.bas_ytd_ptd) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'fixed_percent        = ' || alloc_rec.fixed_percent) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'cmpntcls_id  	= ' || alloc_rec.cmpntcls_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'cost_cmpntcls_code  	= ' || alloc_rec.cost_cmpntcls_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'analysis_code        = ' || alloc_rec.analysis_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'whse_code    	= ' || alloc_rec.whse_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'delete_mark  	= ' || alloc_rec.delete_mark) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'user_name  		= ' || alloc_rec.user_name) ;
  */
  GMF_ALLOCATIONDEFINITION_PUB.Create_Allocation_Definition
  ( p_api_version    => 3.0
  , p_init_msg_list  => FND_API.G_TRUE
  , p_commit         => FND_API.G_TRUE

  , x_return_status  =>l_status
  , x_msg_count      =>l_count
  , x_msg_data       =>l_data

  , p_allocation_definition_rec => alloc_rec
  );

  UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );
  IF l_count > 0
  THEN
   l_loop_cnt  :=1;
   LOOP

    FND_MSG_PUB.Get(
    p_msg_index     => l_loop_cnt,
    p_data          => l_data,
    p_encoded       => FND_API.G_FALSE,
    p_msg_index_out => l_dummy_cnt);


   -- DBMS_OUTPUT.PUT_LINE(l_data );

   UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
   UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
   UTL_FILE.NEW_LINE(l_outfile_handle);

   /*
     IF l_status = 'E' OR
        l_status = 'U'
     THEN
        l_data    := CONCAT('ERROR : ',l_data);
     END IF;
   */

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

EXCEPTION
 WHEN OTHERS THEN
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  l_return_status := 'U' ;
END ;

END LOOP;

  -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));

/*  Check if any messages generated. If so then decode and */
/*  output to error message flat file */

UTL_FILE.FCLOSE_ALL;

RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /* -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN OTHERS THEN
  /* -- DBMS_OUTPUT.PUT_LINE('Other Error'); */
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.FCLOSE_ALL;
  l_return_status := 'U' ;
  RETURN l_return_status;

END Create_Alloc_Def;

/*  API start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Update_Alloc_Def                                                      |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Update Allocation Definition                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the                        |
 |    Update_Alloc_Def API wrapper function                                 |
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
 |    07-Mar-2001  Uday Moogala    created                                  |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Update_Alloc_Def
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

 ---- DBMS_OUTPUT.PUT_LINE('in Update_Alloc_Def procedure... ');
l_return_status  :=Update_Alloc_Def( p_dir
                                     , p_input_file
                                     , p_output_file
                                     , p_delimiter
                                   );

 -- DBMS_OUTPUT.PUT_LINE('return status := ' || l_return_status);
End Update_Alloc_Def;

/* +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Update_Alloc_Def                                                      |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Update Allocation Definition                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Update_Allocation_definition API.                                     |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_aloc_wrapper<session_id>.log in the temp directory.        |
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
FUNCTION Update_Alloc_Def
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2
IS

/* Local variables */

l_status             VARCHAR2(100);
l_return_status      VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER(10)  ;
l_record_count       NUMBER(10)  :=0;
l_loop_cnt           NUMBER(10)  :=0;
l_dummy_cnt          NUMBER(10)  :=0;
l_data               VARCHAR2(2000);
alloc_rec            gmf_allocationdefinition_pub.Allocation_Definition_Rec_Type;
l_p_dir              VARCHAR2(150);
l_output_file        VARCHAR2(120);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(120);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(1800);
l_delimiter          VARCHAR(11);
l_log_dir            VARCHAR2(150);
l_log_name           VARCHAR2(120)  :='gmf_api_updalloc_wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(120);

l_session_id         VARCHAR2(110);

BEGIN

/*  Enable The Buffer  */
/*  DBMS_OUTPUT.ENABLE(1000000); */

-- DBMS_OUTPUT.PUT_LINE('in Update_Alloc_Def function...');

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

/*  Loop thru flat file and call Inventory Quantities API */
-- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
-- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
-- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
-- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
-- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );


/*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
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

BEGIN
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );

  alloc_rec.alloc_id            := Get_Field(l_line,l_delimiter,1) ;
  alloc_rec.alloc_code          := Get_Field(l_line,l_delimiter,2) ;
  alloc_rec.legal_entity_id     := Get_Field(l_line,l_delimiter,3) ;
  alloc_rec.alloc_method        := Get_Field(l_line,l_delimiter,4) ;
  alloc_rec.line_no             := Get_Field(l_line,l_delimiter,5) ;
  alloc_rec.organization_id     := Get_Field(l_line,l_delimiter,6) ;
  alloc_rec.organization_code   := Get_Field(l_line,l_delimiter,7) ;
  alloc_rec.item_id             := Get_Field(l_line,l_delimiter,8) ;
  alloc_rec.item_number         := Get_Field(l_line,l_delimiter,9) ;
  alloc_rec.basis_account_id    := Get_Field(l_line,l_delimiter,10) ;
  alloc_rec.basis_account_key   := Get_Field(l_line,l_delimiter,11) ;
  alloc_rec.balance_type        := Get_Field(l_line,l_delimiter,12) ;
  alloc_rec.bas_ytd_ptd         := Get_Field(l_line,l_delimiter,13) ;
  alloc_rec.basis_type          := Get_Field(l_line,l_delimiter,14) ;
  alloc_rec.fixed_percent       := Get_Field(l_line,l_delimiter,15) ;
  alloc_rec.cmpntcls_id         := Get_Field(l_line,l_delimiter,16) ;
  alloc_rec.cost_cmpntcls_code  := Get_Field(l_line,l_delimiter,17) ;
  alloc_rec.analysis_code       := Get_Field(l_line,l_delimiter,18) ;
  alloc_rec.delete_mark         := Get_Field(l_line,l_delimiter,19) ;
  alloc_rec.user_name           := Get_Field(l_line,l_delimiter,20) ;

  UTL_FILE.PUT_LINE(l_log_handle, 'alloc_id             = ' || alloc_rec.alloc_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'alloc_code           = ' || alloc_rec.alloc_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'legal_entity_id              = ' || alloc_rec.legal_entity_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'alloc_method         = ' || alloc_rec.alloc_method) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'line_no              = ' || alloc_rec.line_no) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'item_id              = ' || alloc_rec.item_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'item_number             = ' || alloc_rec.item_number) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'basis_account_key    = ' || alloc_rec.basis_account_key) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'balance_type         = ' || alloc_rec.balance_type) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'bas_ytd_ptd          = ' || alloc_rec.bas_ytd_ptd) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'basis_type           = ' || alloc_rec.basis_type) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'fixed_percent        = ' || alloc_rec.fixed_percent) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'cmpntcls_id          = ' || alloc_rec.cmpntcls_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'cost_cmpntcls_code   = ' || alloc_rec.cost_cmpntcls_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'analysis_code        = ' || alloc_rec.analysis_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'organization_id      = ' || alloc_rec.organization_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'organization_code    = ' || alloc_rec.organization_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'delete_mark          = ' || alloc_rec.delete_mark) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'user_name            = ' || alloc_rec.user_name) ;

  -- DBMS_OUTPUT.PUT_LINE('before calling Update API...');
  GMF_ALLOCATIONDEFINITION_PUB.Update_Allocation_Definition
  ( p_api_version    => 3.0
  , p_init_msg_list  => FND_API.G_TRUE
  , p_commit         => FND_API.G_TRUE

  , x_return_status  =>l_status
  , x_msg_count      =>l_count
  , x_msg_data       =>l_data

  , p_allocation_definition_rec => alloc_rec
  );

  UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );
  IF l_count > 0
  THEN
   l_loop_cnt  :=1;
  LOOP

  FND_MSG_PUB.Get(
    p_msg_index     => l_loop_cnt,
    p_data          => l_data,
    p_encoded       => FND_API.G_FALSE,
    p_msg_index_out => l_dummy_cnt);


  -- DBMS_OUTPUT.PUT_LINE(l_data );

  UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
  UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
  UTL_FILE.NEW_LINE(l_outfile_handle);


/*
  IF l_status = 'E' OR
     l_status = 'U'
  THEN
    l_data    := CONCAT('ERROR : ',l_data);
  END IF;
*/

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

EXCEPTION
 WHEN OTHERS THEN
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  l_return_status := 'U' ;
END ;

END LOOP;
  -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));

/*  Check if any messages generated. If so then decode and */
/*  output to error message flat file */

UTL_FILE.FCLOSE_ALL;

RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /* -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN OTHERS THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Other Error'); */
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
   UTL_FILE.FCLOSE_ALL;
   l_return_status := 'U' ;
   RETURN l_return_status;

END Update_Alloc_Def;

/*  API start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Delete_Alloc_def                                                      |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Delete Allocation Definition                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the                        |
 |    Delete_Alloc_def API wrapper function                                 |
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
 |    07-Mar-2001  Uday Moogala    created                                  |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Delete_Alloc_def
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

 ---- DBMS_OUTPUT.PUT_LINE('in Delete_Alloc_def procedure... ');
l_return_status  :=Delete_Alloc_def( p_dir
                                     , p_input_file
                                     , p_output_file
                                     , p_delimiter
                                   );

 -- DBMS_OUTPUT.PUT_LINE('return status := ' || l_return_status);
End Delete_Alloc_def;

/* +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Delete_Alloc_def                                                      |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Delete Allocation Definition                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Delete_Allocation_definition API.                                     |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_aloc_wrapper<session_id>.log in the temp directory.        |
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
FUNCTION Delete_Alloc_def
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2
IS

/* Local variables */

l_status             VARCHAR2(100);
l_return_status      VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER(10)  ;
l_record_count       NUMBER(10)  :=0;
l_loop_cnt           NUMBER(10)  :=0;
l_dummy_cnt          NUMBER(10)  :=0;
l_data               VARCHAR2(2000);
alloc_rec            gmf_allocationdefinition_pub.Allocation_Definition_Rec_Type;
l_p_dir              VARCHAR2(150);
l_output_file        VARCHAR2(120);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(120);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(1800);
l_delimiter          VARCHAR(11);
l_log_dir            VARCHAR2(150);
l_log_name           VARCHAR2(120)  :='gmf_api_delalloc_wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(120);

l_session_id         VARCHAR2(110);

BEGIN

/*  Enable The Buffer  */
/*  DBMS_OUTPUT.ENABLE(1000000); */

-- DBMS_OUTPUT.PUT_LINE('in Delete_Alloc_def function...');

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

/*  Loop thru flat file and call Inventory Quantities API */
-- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
-- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
-- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
-- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
-- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );


/*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
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

BEGIN
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );

  alloc_rec.alloc_id            := Get_Field(l_line,l_delimiter,1) ;
  alloc_rec.alloc_code          := Get_Field(l_line,l_delimiter,2) ;
  alloc_rec.legal_entity_id     := Get_Field(l_line,l_delimiter,3) ;
  alloc_rec.alloc_method        := Get_Field(l_line,l_delimiter,4) ;
  alloc_rec.line_no             := Get_Field(l_line,l_delimiter,5) ;
  alloc_rec.organization_id     := Get_Field(l_line,l_delimiter,6) ;
  alloc_rec.organization_code   := Get_Field(l_line,l_delimiter,7) ;
  alloc_rec.item_id             := Get_Field(l_line,l_delimiter,8) ;
  alloc_rec.item_number         := Get_Field(l_line,l_delimiter,9) ;
  alloc_rec.basis_account_id    := Get_Field(l_line,l_delimiter,10) ;
  alloc_rec.basis_account_key   := Get_Field(l_line,l_delimiter,11) ;
  alloc_rec.balance_type        := Get_Field(l_line,l_delimiter,12) ;
  alloc_rec.bas_ytd_ptd         := Get_Field(l_line,l_delimiter,13) ;
  alloc_rec.basis_type          := Get_Field(l_line,l_delimiter,14) ;
  alloc_rec.fixed_percent       := Get_Field(l_line,l_delimiter,15) ;
  alloc_rec.cmpntcls_id         := Get_Field(l_line,l_delimiter,16) ;
  alloc_rec.cost_cmpntcls_code  := Get_Field(l_line,l_delimiter,17) ;
  alloc_rec.analysis_code       := Get_Field(l_line,l_delimiter,18) ;
  alloc_rec.delete_mark         := Get_Field(l_line,l_delimiter,19) ;
  alloc_rec.user_name           := Get_Field(l_line,l_delimiter,20) ;

  UTL_FILE.PUT_LINE(l_log_handle, 'alloc_id             = ' || alloc_rec.alloc_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'alloc_code           = ' || alloc_rec.alloc_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'legal_entity_id      = ' || alloc_rec.legal_entity_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'alloc_method         = ' || alloc_rec.alloc_method) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'line_no              = ' || alloc_rec.line_no) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'item_id              = ' || alloc_rec.item_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'item_number          = ' || alloc_rec.item_number) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'basis_account_key    = ' || alloc_rec.basis_account_key) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'balance_type         = ' || alloc_rec.balance_type) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'bas_ytd_ptd          = ' || alloc_rec.bas_ytd_ptd) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'basis_type           = ' || alloc_rec.basis_type) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'fixed_percent        = ' || alloc_rec.fixed_percent) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'cmpntcls_id          = ' || alloc_rec.cmpntcls_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'cost_cmpntcls_code   = ' || alloc_rec.cost_cmpntcls_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'analysis_code        = ' || alloc_rec.analysis_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'organization_id      = ' || alloc_rec.organization_id) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'organization_code    = ' || alloc_rec.organization_code) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'delete_mark          = ' || alloc_rec.delete_mark) ;
  UTL_FILE.PUT_LINE(l_log_handle, 'user_name            = ' || alloc_rec.user_name) ;

  -- DBMS_OUTPUT.PUT_LINE('before calling Delete API...');
  GMF_ALLOCATIONDEFINITION_PUB.Delete_Allocation_Definition
  ( p_api_version    => 3.0
  , p_init_msg_list  => FND_API.G_TRUE
  , p_commit         => FND_API.G_TRUE

  , x_return_status  =>l_status
  , x_msg_count      =>l_count
  , x_msg_data       =>l_data

  , p_allocation_definition_rec => alloc_rec
  );

  UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );
  IF l_count > 0
  THEN
  l_loop_cnt  :=1;
  LOOP

  FND_MSG_PUB.Get(
    p_msg_index     => l_loop_cnt,
    p_data          => l_data,
    p_encoded       => FND_API.G_FALSE,
    p_msg_index_out => l_dummy_cnt);


  -- DBMS_OUTPUT.PUT_LINE(l_data );

  UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
  UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
  UTL_FILE.NEW_LINE(l_outfile_handle);

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

EXCEPTION
 WHEN OTHERS THEN
  -- DBMS_OUTPUT.PUT_LINE('Other Error...1');
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  l_return_status := 'U' ;
END ;

END LOOP;

  -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));

/*  Check if any messages generated. If so then decode and */
/*  output to error message flat file */

UTL_FILE.FCLOSE_ALL;

RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /* -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN OTHERS THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Other Error'); */
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
   UTL_FILE.FCLOSE_ALL;
   l_return_status := 'U' ;
   RETURN l_return_status;

END Delete_Alloc_def;



--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Process_LotCost_Adjustment                                            |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Create/Insert, Update,Delete Lot Cost Adjustment                      |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This is a PL/SQL wrapper procedure to call the                        |
--|    Call_LotCost_API wrapper function	   		             |
--|                                                                          |
--| PARAMETERS                                                               |
--|    p_dir              IN VARCHAR2         - Working directory for input  |
--|                                             and output files.            |
--|    p_input_file       IN VARCHAR2         - Name of input file           |
--|    p_output_file      IN VARCHAR2         - Name of output file          |
--|    p_delimiter        IN VARCHAR2         - Delimiter character          |
--|    p_operation	  IN VARCHAR2	      - Operation to be performed    |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    30/Mar/2004  Dinesh Vadivel      Created                              |
--|                                                                          |
--+==========================================================================+

PROCEDURE Process_LotCost_Adjustment
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_operation    IN VARCHAR2
)

IS
l_return_status  VARCHAR2(1);

BEGIN

--DBMS_OUTPUT.PUT_LINE('in Process_LotCost_Adjustment procedure... ');
l_return_status  :=Process_LotCost_Adjustment( p_dir
			      	                    , p_input_file
                                     , p_output_file
                                     , p_delimiter
				                        , p_operation
                                   );
End Process_LotCost_Adjustment;


/* +==========================================================================+
 | FUNCTION NAME                                                              |
 |    Process_LotCost_Adjustment                                              |
 |                                                                            |
 | TYPE                                                                       |
 |    Public                                                                  |
 |                                                                            |
 | USAGE                                                                      |
 |    Create/Insert, Update or Delete Lot Cost Adjustment                     |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This is a PL/SQL wrapper function to call the                           |
 |    Call_LotCost_API.							      |
 |    It reads item data from a flat file and outputs any error               |
 |    messages to a second flat file. It also generates a Status              |
 |    called gmf_api_<operation>_wrapper<session_id>.log in the /tmp directory|
 |                                                                            |
 | PARAMETERS                                                                 |
 |    p_dir              IN VARCHAR2         - Working directory for input    |
 |                                             and output files.              |
 |    p_input_file       IN VARCHAR2         - Name of input file             |
 |    p_output_file      IN VARCHAR2         - Name of output file            |
 |    p_delimiter        IN VARCHAR2         - Delimiter character            |
 |    p_operation	  IN VARCHAR2	     - Operation to be performed      |
 |									      |
 | RETURNS                                                                    |
 |    VARCHAR2 - 'S' All records processed successfully                       |
 |               'E' 1 or more records errored                                |
 |               'U' 1 or more record unexpected error                        |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 +============================================================================+
  Api end of comments
*/
FUNCTION Process_LotCost_Adjustment
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_operation    IN VARCHAR2
)
RETURN VARCHAR2
IS

/* Local variables */


l_status             VARCHAR2(11);
l_return_status      VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER(10)  ;
l_record_count       NUMBER(10)  :=0;
l_loop_cnt           NUMBER(10)  :=0;
l_dummy_cnt          NUMBER(10)  :=0;
l_data               VARCHAR2(32767);

l_header_rec         GMF_LOTCOSTADJUSTMENT_PUB.Lc_Adjustment_Header_Rec_Type;
l_dtl_tbl            GMF_LOTCOSTADJUSTMENT_PUB.Lc_Adjustment_Dtls_Tbl_Type;

l_p_dir              VARCHAR2(150);
l_output_file        VARCHAR2(120);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(120);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(32767);
l_delimiter          VARCHAR(11);
l_log_dir            VARCHAR2(150);
l_log_name           VARCHAR2(120) ;--:='gmf_api_cric_wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(120);
l_idx		     NUMBER(10);
l_idx1		     NUMBER(10);
l_type		     VARCHAR2(32767);
l_continue           VARCHAR2(1) := 'Y' ;
l_skip_details       VARCHAR2(1) := 'N' ;
l_session_id         VARCHAR2(110);


BEGIN

  /*  Enable The Buffer  */
--  DBMS_OUTPUT.ENABLE(1000000);

  --DBMS_OUTPUT.PUT_LINE('in Process_LotCost_Adjustment function...');

  l_p_dir              :=p_dir;
  l_log_dir	       := p_dir;
  l_input_file         :=p_input_file;
  l_output_file        :=p_output_file;
  l_delimiter          :=p_delimiter;
  l_global_file        :=l_input_file;

  IF p_operation = 'INSERT' THEN
    l_log_name := 'gmf_api_crtlcadj_wrapper' ;
  ELSIF p_operation = 'UPDATE' THEN
    l_log_name := 'gmf_api_updlcadj_wrapper' ;
  ELSIF p_operation = 'DELETE' THEN
    l_log_name := 'gmf_api_dellcadj_wrapper' ;
  END IF ;


  /* Obtain The SessionId To Append To wrapper File Name. */
  l_session_id := USERENV('sessionid');

  l_log_name  := CONCAT(l_log_name,l_session_id);
  l_log_name  := CONCAT(l_log_name,'.log');

  /*  Directory is now the same same as for the out file */
  l_log_dir   := p_dir;

  /* Open The Wrapper File For Output And The Input File for Input. */
  l_log_handle      :=UTL_FILE.FOPEN(l_log_dir, l_log_name, 'w');
  l_infile_handle   :=UTL_FILE.FOPEN(l_p_dir, l_input_file, 'r');

  /* Loop thru flat file and call Inventory Quantities API */
  /*
   DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
   DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
   DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
   DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
   DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );
  */

  UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Input Directory  ' || l_p_dir );
  UTL_FILE.PUT_LINE(l_log_handle, 'Input File       ' || l_input_file );
  UTL_FILE.PUT_LINE(l_log_handle, 'Record Type      ' || l_delimiter );
  UTL_FILE.PUT_LINE(l_log_handle, 'Output File      ' || l_output_file );

  l_outfile_handle  :=UTL_FILE.FOPEN(l_p_dir, l_output_file, 'w');


  BEGIN
   <<TITLE_REPEAT>>
    UTL_FILE.GET_LINE(l_infile_handle, l_line);
    l_type   := Get_Field(l_line,l_delimiter,1) ;  -- = 10 : header rec, 20 : detail record
    IF ( l_type  <> '10' AND l_type <> '20' AND l_type IS NOT NULL) THEN
      GOTO TITLE_REPEAT;
    END IF;
    l_record_count    :=l_record_count+1;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise;
  END;

  LOOP
    BEGIN
      UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || to_char(l_record_count));
      UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;

       IF l_type = '10' THEN

	     l_header_rec.adjustment_id			:=	 Get_Field(l_line,l_delimiter,2);
        l_header_rec.legal_entity_id             	:=	 Get_Field(l_line,l_delimiter,3);
        l_header_rec.cost_type_id			:=	 Get_Field(l_line,l_delimiter,4);
        l_header_rec.cost_mthd_code			:=	 Get_Field(l_line,l_delimiter,5);
        l_header_rec.organization_id			:=	 Get_Field(l_line,l_delimiter,6);
        l_header_rec.organization_code			:=	 Get_Field(l_line,l_delimiter,7);
        l_header_rec.item_id				:=	 Get_Field(l_line,l_delimiter,8);
        l_header_rec.item_number				:=	 Get_Field(l_line,l_delimiter,9);
        l_header_rec.lot_number				:=	 Get_Field(l_line,l_delimiter,10);


	-- Bug # 3755374 ANTHIYAG 12-Jul-2004 Start
      	BEGIN
      		l_header_rec.adjustment_date		:=	 fnd_date.canonical_to_date(Get_Field(l_line,l_delimiter,11));
      	EXCEPTION
      		WHEN OTHERS THEN
      			-- Date set to Sysdate + 1 to disallow errors to be raised in Wrapper.
      			-- Error would be handled in Validate procedure of Public API Package
      			l_header_rec.adjustment_date	:=	 SYSDATE + 1;
      	END;
	-- Bug # 3755374 ANTHIYAG 12-Jul-2004 End

              l_header_rec.reason_code			:=	 Get_Field(l_line,l_delimiter,12);
              l_header_rec.delete_mark			:=	 Get_Field(l_line,l_delimiter,13);
              l_header_rec.attribute1				:=	 Get_Field(l_line,l_delimiter,14);
              l_header_rec.attribute2				:=	 Get_Field(l_line,l_delimiter,15);
              l_header_rec.attribute3				:=	 Get_Field(l_line,l_delimiter,16);
              l_header_rec.attribute4				:=	 Get_Field(l_line,l_delimiter,17);
              l_header_rec.attribute5				:=	 Get_Field(l_line,l_delimiter,18);
              l_header_rec.attribute6				:=	 Get_Field(l_line,l_delimiter,19);
         	l_header_rec.attribute7				:=	 Get_Field(l_line,l_delimiter,20);
         	l_header_rec.attribute8				:=	 Get_Field(l_line,l_delimiter,21);
         	l_header_rec.attribute9				:=	 Get_Field(l_line,l_delimiter,22);
         	l_header_rec.attribute10			:=	 Get_Field(l_line,l_delimiter,23);
         	l_header_rec.attribute11			:=	 Get_Field(l_line,l_delimiter,24);
         	l_header_rec.attribute12			:=	 Get_Field(l_line,l_delimiter,25);
      	l_header_rec.attribute13			:=	 Get_Field(l_line,l_delimiter,26);
      	l_header_rec.attribute14			:=	 Get_Field(l_line,l_delimiter,27);
      	l_header_rec.attribute15			:=	 Get_Field(l_line,l_delimiter,28);
      	l_header_rec.attribute16			:=	 Get_Field(l_line,l_delimiter,29);
      	l_header_rec.attribute17			:=	 Get_Field(l_line,l_delimiter,30);
      	l_header_rec.attribute18			:=	 Get_Field(l_line,l_delimiter,31);
      	l_header_rec.attribute19			:=	 Get_Field(l_line,l_delimiter,32);
      	l_header_rec.attribute20			:=	 Get_Field(l_line,l_delimiter,33);
      	l_header_rec.attribute21			:=	 Get_Field(l_line,l_delimiter,34);
      	l_header_rec.attribute22			:=	 Get_Field(l_line,l_delimiter,35);
      	l_header_rec.attribute23			:=	 Get_Field(l_line,l_delimiter,36);
      	l_header_rec.attribute24			:=	 Get_Field(l_line,l_delimiter,37);
      	l_header_rec.attribute25			:=	 Get_Field(l_line,l_delimiter,38);
      	l_header_rec.attribute26			:=	 Get_Field(l_line,l_delimiter,39);
      	l_header_rec.attribute27			:=	 Get_Field(l_line,l_delimiter,40);
      	l_header_rec.attribute28			:=	 Get_Field(l_line,l_delimiter,41);
      	l_header_rec.attribute29			:=	 Get_Field(l_line,l_delimiter,42);
      	l_header_rec.attribute30			:=	 Get_Field(l_line,l_delimiter,43);
      	l_header_rec.attribute_category	:=	 Get_Field(l_line,l_delimiter,44);
         l_header_rec.user_name				:=	 Get_Field(l_line,l_delimiter,45);
      	l_dtl_tbl.DELETE ;
         l_skip_details := 'N' ;
      	l_idx  := 0 ;

  ELSIF l_type = '20' AND l_skip_details = 'Y' THEN
      UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skipping this record...');
   ELSIF l_type = '20' AND l_skip_details = 'N' THEN

	l_idx := l_idx + 1 ;
	l_dtl_tbl(l_idx).adjustment_dtl_id		:=	Get_Field(l_line,l_delimiter,2);
	l_dtl_tbl(l_idx).adjustment_id			:=	Get_Field(l_line,l_delimiter,3);
	l_dtl_tbl(l_idx).cost_cmpntcls_id		:=	Get_Field(l_line,l_delimiter,4);
	l_dtl_tbl(l_idx).cost_cmpntcls_code		:=	Get_Field(l_line,l_delimiter,5);
	l_dtl_tbl(l_idx).cost_analysis_code		:=	Get_Field(l_line,l_delimiter,6);

	-- Bug # 3755374 ANTHIYAG 12-Jul-2004 Start
	BEGIN
		l_dtl_tbl(l_idx).adjustment_cost	:=	Get_Field(l_line,l_delimiter,7);
	EXCEPTION
		WHEN VALUE_ERROR THEN
			UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : Invalid Adjustment Cost Specified');
			UTL_FILE.PUT_LINE(l_log_handle, 'Error : Invalid Adjustment Cost Specified');
	END;
	-- Bug # 3755374 ANTHIYAG 12-Jul-2004 End

   -- Bug # 3778177 ANTHIYAG 20-Jul-2004 Start
   -- l_dtl_tbl(l_idx).delete_mark			:=	Get_Field(l_line,l_delimiter,8);
   -- Bug # 3778177 ANTHIYAG 20-Jul-2004 End

        l_dtl_tbl(l_idx).text_code			:=	Get_Field(l_line,l_delimiter,8);

      END IF ;

    EXCEPTION

      WHEN OTHERS THEN
	     UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
        UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
        IF l_type = '10' THEN
          l_skip_details := 'Y' ;
          UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skip detail records.');
        ELSIF l_type = '20' THEN
          l_dtl_tbl.DELETE(l_idx);
          l_idx := l_idx-1;
        END IF ;
     END ;

    BEGIN

      <<TITLE_REPEAT1>>
      UTL_FILE.GET_LINE(l_infile_handle, l_line);
      l_type   := Get_Field(l_line,l_delimiter,1) ;  -- 10 : Header Record, 20 : Detail Record
       IF ( l_type  <> '10' AND l_type <> '20' AND l_type IS NOT NULL) THEN
          GOTO TITLE_REPEAT1;
       END IF;
      l_record_count    :=l_record_count+1;
      UTL_FILE.NEW_LINE(l_log_handle);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF l_skip_details = 'N' THEN
          UTL_FILE.PUT_LINE(l_log_handle,'Final Call to Call_LotCost_API...');

          /* Call the Call Lot Cost API function */
	  Call_LotCost_API
	  (
	      p_header_rec		=>  l_header_rec
            , p_dtl_tbl			=>  l_dtl_tbl
            , p_operation    		=>  p_operation
            , x_status       		=>  l_status
            , x_count    		=>  l_count
            , x_data         		=>  l_data
          ) ;

          UTL_FILE.PUT_LINE(l_log_handle,'Final After call to Create_LotCost_Adjustment API.status := ' || l_status ||' cnt := ' || l_count );
        END IF;
        l_continue := 'N' ;
        GOTO GET_MSG_STACK ;
    END;

    IF (l_type = '10' AND l_record_count <> 1 AND l_skip_details = 'N') THEN
      UTL_FILE.PUT_LINE(l_log_handle,'Call to  Create_LotCost_Adjustment API...');

      /* Call the Call Lot Cost API function */ --to change
      Call_LotCost_API
      (
	  p_header_rec		=>  l_header_rec
        , p_dtl_tbl		=>  l_dtl_tbl
        , p_operation    	=>  p_operation
	     , x_status       	=>  l_status
        , x_count    		=>  l_count
        , x_data         	=>  l_data
       ) ;

       UTL_FILE.PUT_LINE(l_log_handle,' After call to Create_LotCost_Adjustment API.status := ' ||	l_status ||' cnt := ' || l_count );
     END IF;

     <<GET_MSG_STACK>>
       null;

    /*  Check if any messages generated. If so then decode and */
    /*  output to error message flat file */

      IF l_count > 0 THEN

        l_loop_cnt  :=1;
        LOOP
          FND_MSG_PUB.Get(
          p_msg_index     => l_loop_cnt,
          p_data          => l_data,
          p_encoded       => FND_API.G_FALSE,
          p_msg_index_out => l_dummy_cnt);

          UTL_FILE.PUT_LINE(l_log_handle, l_data);

          /*  Update error status */
          IF (l_status = 'U') THEN
            l_return_status  :=l_status;
          ELSIF (l_status = 'E' and l_return_status <> 'U') THEN
            l_return_status  :=l_status;
          ELSE
            l_return_status  :=l_status;
          END IF;

          l_loop_cnt  := l_loop_cnt + 1;
          IF l_loop_cnt > l_count THEN
            EXIT;
          END IF;

        END LOOP; -- msg stack loop
        l_count := 0 ;

      END IF;	-- if count of msg stack > 0

      IF l_continue = 'N' THEN
        EXIT ;
      END IF ;

    END LOOP;

--    DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
    UTL_FILE.FCLOSE_ALL;

    RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /* -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN OTHERS THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Other Error'); */
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
   UTL_FILE.FCLOSE_ALL;
   l_return_status := 'U' ;
   RETURN l_return_status;

END Process_LotCost_Adjustment;

/* +============================================================================+
 | PROCEDURE NAME                                                               |
 |    Call_LotCost_API							        |
 |                                                                              |
 | TYPE                                                                         |
 |    Public                                                                    |
 |										|
 | USAGE									|
 |    Calls LotCost_Adjsutment APIs based on the operation being performed	|
 |										|
 | DESCRIPTION									|
 |    This is a PL/SQL wrapper function to call the Burden_detail API.		|
 |    Data is sent from through the parameters.					|
 |										|
 | PARAMETERS                                                                   |
 |    p_header_rec	    IN VARCHAR2         - Burden Details Header		|
 |    p_dtl_tbl             IN VARCHAR2         - Burden Details		|
 |    p_operation	    IN VARCHAR2         - Insert/Update/Delete		|
 |    x_status              OUT VARCHAR2        - Return Status			|
 |    x_count               OUT VARCHAR2        - # of msgs on message stack	|
 |    x_data                OUT VARCHAR2        - Actual Message from msg stack	|
 |										|
 |										|
 | HISTORY									|
 |     Created by dvadivel on 5-Apr-2004                                        |
 +==============================================================================+
*/

PROCEDURE Call_LotCost_API
(
  p_header_rec		  IN OUT	NOCOPY GMF_LOTCOSTADJUSTMENT_PUB.Lc_Adjustment_Header_Rec_Type
, p_dtl_tbl		  IN OUT	NOCOPY GMF_LOTCOSTADJUSTMENT_PUB.Lc_Adjustment_Dtls_Tbl_Type
, p_operation             IN			VARCHAR2
, x_status                OUT		NOCOPY	VARCHAR2
, x_count                 OUT		NOCOPY	NUMBER
, x_data                  OUT		NOCOPY	VARCHAR2
)
IS

BEGIN

 IF p_operation = 'INSERT' THEN
   GMF_LotCostAdjustment_PUB.Create_LotCost_Adjustment
	( p_api_version		=>	2.0
	, p_init_msg_list	=>	FND_API.G_TRUE
	, p_commit		=>	FND_API.G_TRUE
	, x_return_status	=>	x_status
	, x_msg_count		=>	x_count
	, x_msg_data		=>	x_data
	, p_header_rec		=>	p_header_rec
	, p_dtl_Tbl		=>	p_dtl_tbl
	);
 ELSIF p_operation = 'UPDATE' THEN
   GMF_LotCostAdjustment_PUB.Update_LotCost_Adjustment
	( p_api_version		=>	2.0
	, p_init_msg_list	=>	FND_API.G_TRUE
	, p_commit		=>	FND_API.G_TRUE
	, x_return_status	=>	x_status
	, x_msg_count		=>	x_count
	, x_msg_data		=>	x_data
	, p_header_rec		=>	p_header_rec
	, p_dtl_Tbl		=>	p_dtl_tbl
	);
 ELSIF p_operation = 'DELETE' THEN
   GMF_LotCostAdjustment_PUB.Delete_LotCost_Adjustment
	( p_api_version		=>	2.0
	, p_init_msg_list	=>	FND_API.G_TRUE
	, p_commit		=>	FND_API.G_TRUE
	, x_return_status	=>	x_status
	, x_msg_count		=>	x_count
	, x_msg_data		=>	x_data
	, p_header_rec		=>	p_header_rec
	, p_dtl_Tbl		=>	p_dtl_tbl
	);
 END IF ;

END Call_LotCost_API ;

/* +========================================================================+
 | FUNCTION NAME                                                            |
 |    Get_LotCost_Adjsutment                                                   |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Get Lot Cost Adjustment Details                                                 |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Get_LotCost_Adjustment API.                                               |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_rsrc_wrapper<session_id>.log in the /tmp directory.        |
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
 |    Dinesh Vadivel 05-Apr-2004 Created                                    |
 |									    |
 +==========================================================================+
*/

FUNCTION Get_LotCost_Adjustment
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2
IS

/* Local variables */

l_status             VARCHAR2(11);
l_return_status      VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER(10)  ;
l_record_count       NUMBER(10)  :=0;
l_loop_cnt           NUMBER(10)  :=0;
l_dummy_cnt          NUMBER(10)  :=0;
l_data               VARCHAR2(1000);

l_header_rec         GMF_LOTCOSTADJUSTMENT_PUB.Lc_Adjustment_Header_Rec_Type;
l_dtl_tbl            GMF_LOTCOSTADJUSTMENT_PUB.Lc_Adjustment_Dtls_Tbl_Type;

l_p_dir              VARCHAR2(150);
l_output_file        VARCHAR2(120);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(120);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(1000);
l_delimiter          VARCHAR(11);
l_log_dir            VARCHAR2(150);
l_log_name           VARCHAR2(120) :='gmf_api_getlotcost_wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(120);
l_idx		     NUMBER(10);
l_idx1		     NUMBER(10);
l_type		     VARCHAR2(32767);
l_continue           VARCHAR2(1) := 'Y' ;
l_skip_details       VARCHAR2(1) := 'N' ;
l_session_id         VARCHAR2(110);

BEGIN

  /*  Enable The Buffer  */
  /*  DBMS_OUTPUT.ENABLE(1000000); */

  -- DBMS_OUTPUT.PUT_LINE('in Get_Burden_details function...');

  l_p_dir              :=p_dir;
  l_log_dir	       := p_dir;
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

  /*  Loop thru flat file and call Inventory Quantities API */
  -- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  -- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
  -- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
  -- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
  -- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );


  /*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Input Directory  ' || l_p_dir );
  UTL_FILE.PUT_LINE(l_log_handle, 'Input File       ' || l_input_file );
  UTL_FILE.PUT_LINE(l_log_handle, 'Record Type      ' || l_delimiter );
  UTL_FILE.PUT_LINE(l_log_handle, 'Output File      ' || l_output_file );

  l_outfile_handle  :=UTL_FILE.FOPEN(l_p_dir, l_output_file, 'w');


 LOOP
  BEGIN
     <<TITLE_REPEAT>>
    UTL_FILE.GET_LINE(l_infile_handle, l_line);
    l_type   := Get_Field(l_line,l_delimiter,1) ;  -- = 10 : header rec, 20 : detail record
    IF ( l_type  <> '10' AND l_type IS NOT NULL) THEN
      GOTO TITLE_REPEAT;
    END IF;
    l_record_count    :=l_record_count+1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      EXIT ;
  END;

  BEGIN
    UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
      -- empty the tables
      l_dtl_tbl.delete ;

        l_header_rec.adjustment_id			:=	 Get_Field(l_line,l_delimiter,2);
        l_header_rec.legal_entity_id   	:=	 Get_Field(l_line,l_delimiter,3);
        l_header_rec.cost_type_id			:=	 Get_Field(l_line,l_delimiter,4);
        l_header_rec.cost_mthd_code			:=	 Get_Field(l_line,l_delimiter,5);
        l_header_rec.organization_id			:=	 Get_Field(l_line,l_delimiter,6);
        l_header_rec.organization_code			:=	 Get_Field(l_line,l_delimiter,7);
        l_header_rec.item_id				:=	 Get_Field(l_line,l_delimiter,8);
        l_header_rec.item_number				:=	 Get_Field(l_line,l_delimiter,9);
        l_header_rec.lot_number				:=	 Get_Field(l_line,l_delimiter,10);

	-- Bug # 3755374 ANTHIYAG 12-Jul-2004 Start
	BEGIN
		l_header_rec.adjustment_date		:=	 fnd_date.canonical_to_date(Get_Field(l_line,l_delimiter,11));
	EXCEPTION
		WHEN OTHERS THEN
			-- Date set to Sysdate + 1 to disallow errors to be raised in Wrapper.
			-- Error would be handled in Validate procedure of Public API Package
			l_header_rec.adjustment_date	:=	 SYSDATE + 1;
	END;
	-- Bug # 3755374 ANTHIYAG 12-Jul-2004 Start

        l_header_rec.reason_code			:=	 Get_Field(l_line,l_delimiter,12);
        l_header_rec.delete_mark			:=	 Get_Field(l_line,l_delimiter,13);
        l_header_rec.attribute1				:=	 Get_Field(l_line,l_delimiter,14);
        l_header_rec.attribute2				:=	 Get_Field(l_line,l_delimiter,15);
        l_header_rec.attribute3				:=	 Get_Field(l_line,l_delimiter,16);
        l_header_rec.attribute4				:=	 Get_Field(l_line,l_delimiter,17);
        l_header_rec.attribute5				:=	 Get_Field(l_line,l_delimiter,18);
        l_header_rec.attribute6				:=	 Get_Field(l_line,l_delimiter,19);
	l_header_rec.attribute7				:=	 Get_Field(l_line,l_delimiter,20);
	l_header_rec.attribute8				:=	 Get_Field(l_line,l_delimiter,21);
	l_header_rec.attribute9				:=	 Get_Field(l_line,l_delimiter,22);
	l_header_rec.attribute10			:=	 Get_Field(l_line,l_delimiter,23);
	l_header_rec.attribute11			:=	 Get_Field(l_line,l_delimiter,24);
	l_header_rec.attribute12			:=	 Get_Field(l_line,l_delimiter,25);
	l_header_rec.attribute13			:=	 Get_Field(l_line,l_delimiter,26);
	l_header_rec.attribute14			:=	 Get_Field(l_line,l_delimiter,27);
	l_header_rec.attribute15			:=	 Get_Field(l_line,l_delimiter,28);
	l_header_rec.attribute16			:=	 Get_Field(l_line,l_delimiter,29);
	l_header_rec.attribute17			:=	 Get_Field(l_line,l_delimiter,30);
	l_header_rec.attribute18			:=	 Get_Field(l_line,l_delimiter,31);
	l_header_rec.attribute19			:=	 Get_Field(l_line,l_delimiter,32);
	l_header_rec.attribute20			:=	 Get_Field(l_line,l_delimiter,33);
	l_header_rec.attribute21			:=	 Get_Field(l_line,l_delimiter,34);
	l_header_rec.attribute22			:=	 Get_Field(l_line,l_delimiter,35);
	l_header_rec.attribute23			:=	 Get_Field(l_line,l_delimiter,36);
	l_header_rec.attribute24			:=	 Get_Field(l_line,l_delimiter,37);
	l_header_rec.attribute25			:=	 Get_Field(l_line,l_delimiter,38);
	l_header_rec.attribute26			:=	 Get_Field(l_line,l_delimiter,39);
	l_header_rec.attribute27			:=	 Get_Field(l_line,l_delimiter,40);
	l_header_rec.attribute28			:=	 Get_Field(l_line,l_delimiter,41);
	l_header_rec.attribute29			:=	 Get_Field(l_line,l_delimiter,42);
	l_header_rec.attribute30			:=	 Get_Field(l_line,l_delimiter,43);
	l_header_rec.attribute_category			:=	 Get_Field(l_line,l_delimiter,44);
        l_header_rec.user_name				:=	 Get_Field(l_line,l_delimiter,45);



      -- DBMS_OUTPUT.PUT_LINE('Calling Get_Item_Cost API...');

      GMF_LotCostAdjustment_PUB.Get_LotCost_Adjustment
      (
        p_api_version        =>  2.0
      , p_init_msg_list      =>  FND_API.G_TRUE

      , x_return_status      =>  l_status
      , x_msg_count          =>  l_count
      , x_msg_data           =>  l_data

      , p_header_rec         =>  l_header_rec

      , p_dtl_tbl            =>  l_dtl_tbl
      );

      UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );


    /*  Check if any messages generated. If so then decode and */
    /*  output to error message flat file */

    IF l_count > 0 THEN

       l_loop_cnt  :=1;
       LOOP
        FND_MSG_PUB.Get(
          p_msg_index     => l_loop_cnt,
          p_data          => l_data,
          p_encoded       => FND_API.G_FALSE,
          p_msg_index_out => l_dummy_cnt);

        ---- DBMS_OUTPUT.PUT_LINE(l_data );
        UTL_FILE.PUT_LINE(l_log_handle, l_data);

        /*  Update error status */
        IF (l_status = 'U') THEN
          l_return_status  :=l_status;
        ELSIF (l_status = 'E' and l_return_status <> 'U') THEN
          l_return_status  :=l_status;
        ELSE
          l_return_status  :=l_status;
        END IF;

        l_loop_cnt  := l_loop_cnt + 1;
        IF l_loop_cnt > l_count THEN
          EXIT;
        END IF;

      END LOOP; -- msg stack loop
      l_count := 0 ;

    END IF;	-- if count of msg stack > 0

    UTL_FILE.NEW_LINE(l_log_handle);
    FOR i in 1..l_dtl_tbl.count
    LOOP
      UTL_FILE.PUT_LINE(l_log_handle,
			' Adjustment Dtl Id : '		||	l_dtl_tbl(i).adjustment_dtl_id	||
			' Adjustment Id	: '		||	l_dtl_tbl(i).adjustment_id	||
			' Cost Cmpntcls Id : '		||	l_dtl_tbl(i).cost_cmpntcls_id	||
			' Cost Cmpntcls Code : '	||	l_dtl_tbl(i).cost_cmpntcls_code	||
			' Cost Anlys Code : '		||	l_dtl_tbl(i).cost_analysis_code ||
			' Adjustment Mark : '		||	l_dtl_tbl(i).adjustment_cost	||
			' Text Code : '			||	l_dtl_tbl(i).text_code
		      );
    END LOOP ;
    l_dtl_tbl.delete ;
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.NEW_LINE(l_log_handle);

  EXCEPTION
   WHEN OTHERS THEN
    UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
    UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  END ;

 END LOOP;

  -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.FCLOSE_ALL;

  RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /* -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN OTHERS THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Other Error'); */
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
   UTL_FILE.FCLOSE_ALL;
   l_return_status := 'U' ;
   RETURN l_return_status;

END Get_LotCost_Adjustment;


PROCEDURE Process_Burden_details
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_operation    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

-- DBMS_OUTPUT.PUT_LINE('in Process_Burden_details procedure... ');
l_return_status  :=Process_Burden_details( p_dir
			      	       , p_input_file
                                       , p_output_file
                                       , p_delimiter
                                       , p_operation
                                       );

 -- DBMS_OUTPUT.PUT_LINE('return status := ' || l_return_status);
END Process_Burden_details;

/* +========================================================================+
 | FUNCTION NAME                                                            |
 |    Process_Burden_details                                                |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create burden details                                                 |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Process_Burden_details API.                                           |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_rsrc_wrapper<session_id>.log in the /tmp directory.        |
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
*/
FUNCTION Process_Burden_details
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_operation    IN VARCHAR2
)
RETURN VARCHAR2
IS

/* Local variables */

l_status             VARCHAR2(11);
l_return_status      VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER(10)  ;
l_record_count       NUMBER(10)  :=0;
l_loop_cnt           NUMBER(10)  :=0;
l_dummy_cnt          NUMBER(10)  :=0;
l_data               VARCHAR2(1000);
l_header_rec         GMF_BurdenDetails_PUB.Burden_Header_Rec_Type;
l_dtl_tbl            GMF_BurdenDetails_PUB.Burden_Dtl_Tbl_Type;
l_burdenline_ids     GMF_BurdenDetails_PUB.Burdenline_Ids_Tbl_Type;
l_p_dir              VARCHAR2(150);
l_output_file        VARCHAR2(120);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(120);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(1000);
l_delimiter          VARCHAR(11);
l_log_dir            VARCHAR2(150);
l_log_name           VARCHAR2(120) ; -- :='gmf_api_cric_wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(120);
l_idx		     NUMBER(10);
l_idx1		     NUMBER(10);
l_type		     NUMBER(10);
l_continue           VARCHAR2(1) := 'Y' ;
l_skip_details       VARCHAR2(1) := 'N' ;
l_session_id         VARCHAR2(110);
--l_first_rec          VARCHAR2(1) ; -- for the first record it is Y else N.
				   -- to avoid calling API for the first record

BEGIN

  /*  Enable The Buffer  */
  /*  DBMS_OUTPUT.ENABLE(1000000); */


  l_p_dir              :=p_dir;
  l_input_file         :=p_input_file;
  l_output_file        :=p_output_file;
  l_delimiter          :=p_delimiter;
  l_global_file        :=l_input_file;

  IF p_operation = 'INSERT' THEN
    l_log_name := 'gmf_api_crbrdn_wrapper' ;
  ELSIF p_operation = 'UPDATE' THEN
    l_log_name := 'gmf_api_updbrdn_wrapper' ;
  ELSIF p_operation = 'DELETE' THEN
    l_log_name := 'gmf_api_delbrdn_wrapper' ;
  END IF ;

  /*  Obtain The SessionId To Append To wrapper File Name. */

  l_session_id := USERENV('sessionid');

  l_log_name  := CONCAT(l_log_name,l_session_id);
  l_log_name  := CONCAT(l_log_name,'.log');

  /*  Directory is now the same same as for the out file */
  l_log_dir   := p_dir;


  /*  Open The Wrapper File For Output And The Input File for Input. */

  l_log_handle      :=UTL_FILE.FOPEN(l_log_dir, l_log_name, 'w');
  l_infile_handle   :=UTL_FILE.FOPEN(l_p_dir, l_input_file, 'r');

  /*  Loop thru flat file and call Inventory Quantities API */
  -- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  -- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
  -- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
  -- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
  -- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );

  /*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Input Directory  ' || l_p_dir );
  UTL_FILE.PUT_LINE(l_log_handle, 'Input File       ' || l_input_file );
  UTL_FILE.PUT_LINE(l_log_handle, 'Record Type      ' || l_delimiter );
  UTL_FILE.PUT_LINE(l_log_handle, 'Output File      ' || l_output_file );

  l_outfile_handle  :=UTL_FILE.FOPEN(l_p_dir, l_output_file, 'w');

  --zzz
  BEGIN
    UTL_FILE.GET_LINE(l_infile_handle, l_line);
    l_record_count    :=l_record_count+1;
    l_type   := Get_Field(l_line,l_delimiter,1) ;  -- = 10 : header rec, 20 : detail record
    --l_first_rec := 'Y' ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise;
  END;


 LOOP
  BEGIN
    UTL_FILE.PUT_LINE(l_log_handle, '--');
    UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
    UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
    IF l_type = 10 THEN
      -- empty the tables
      l_dtl_tbl.delete ;
      l_skip_details := 'N' ;
      l_header_rec.organization_id   := Get_Field(l_line,l_delimiter,2) ;
      l_header_rec.organization_code := Get_Field(l_line,l_delimiter,3) ;
      l_header_rec.inventory_item_id := Get_Field(l_line,l_delimiter,4) ;
      l_header_rec.item_number       := Get_Field(l_line,l_delimiter,5) ;
      l_header_rec.period_id         := Get_Field(l_line,l_delimiter,6) ;
      l_header_rec.calendar_code     := Get_Field(l_line,l_delimiter,7) ;
      l_header_rec.period_code       := Get_Field(l_line,l_delimiter,8) ;
      l_header_rec.cost_type_id      := Get_Field(l_line,l_delimiter,9) ;
      l_header_rec.cost_mthd_code    := Get_Field(l_line,l_delimiter,10) ;
      l_header_rec.user_name         := Get_Field(l_line,l_delimiter,11) ;
      l_idx  := 0 ;
      /*
      UTL_FILE.PUT_LINE(l_log_handle, 'Type   = ' || l_type) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'orgn_code   = ' || l_header_rec.orgn_code) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'item_id   = ' || l_header_rec.item_id) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'item_no   = ' || l_header_rec.item_no) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'whse_code   = ' || l_header_rec.whse_code) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'calendar_code   = ' || l_header_rec.calendar_code) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'period_code   = ' || l_header_rec.period_code) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'cost_mthd_code   = ' || l_header_rec.cost_mthd_code) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'user_name   = ' || l_header_rec.user_name) ;
      */
    ELSIF l_type = 20 AND l_skip_details = 'Y' THEN
      UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skipping this record...');
    ELSIF l_type = 20 AND l_skip_details = 'N' THEN
      l_idx := l_idx + 1 ;
      l_dtl_tbl(l_idx).burdenline_id        := Get_Field(l_line,l_delimiter,2) ;
      l_dtl_tbl(l_idx).resources            := Get_Field(l_line,l_delimiter,3) ;
      l_dtl_tbl(l_idx).cost_cmpntcls_id     := Get_Field(l_line,l_delimiter,4) ;
      l_dtl_tbl(l_idx).cost_cmpntcls_code   := Get_Field(l_line,l_delimiter,5) ;
      l_dtl_tbl(l_idx).cost_analysis_code   := Get_Field(l_line,l_delimiter,6) ;
      l_dtl_tbl(l_idx).burden_usage         := Get_Field(l_line,l_delimiter,7) ;
      l_dtl_tbl(l_idx).item_qty             := Get_Field(l_line,l_delimiter,8) ;
      l_dtl_tbl(l_idx).item_uom             := Get_Field(l_line,l_delimiter,9) ;
      l_dtl_tbl(l_idx).burden_qty           := Get_Field(l_line,l_delimiter,10) ;
      l_dtl_tbl(l_idx).burden_uom           := Get_Field(l_line,l_delimiter,11) ;
      l_dtl_tbl(l_idx).delete_mark          := Get_Field(l_line,l_delimiter,12) ;
      /*
      UTL_FILE.PUT_LINE(l_log_handle, 'Populating details level table...' || l_idx ) ;
      UTL_FILE.PUT_LINE(l_log_handle,'DtlRec: burdenline_id('||l_idx||') = '||l_dtl_tbl(l_idx).burdenline_id) ;
      UTL_FILE.PUT_LINE(l_log_handle,'DtlRec: resources('||l_idx||') = '||l_dtl_tbl(l_idx).resources) ;
      UTL_FILE.PUT_LINE(l_log_handle,'DtlRec: cost_cmpntcls_id('||l_idx||') = '||l_dtl_tbl(l_idx).cost_cmpntcls_id) ;
      UTL_FILE.PUT_LINE(l_log_handle,'DtlRec: cost_cmpntcls_code('||l_idx||') = '||
			l_dtl_tbl(l_idx).cost_cmpntcls_code) ;
      UTL_FILE.PUT_LINE(l_log_handle,'DtlRec: cost_analysis_code('||l_idx||') = '||
			l_dtl_tbl(l_idx).cost_analysis_code) ;
      UTL_FILE.PUT_LINE(l_log_handle,'DtlRec: burden_usage('||l_idx||') = '||l_dtl_tbl(l_idx).burden_usage) ;
      UTL_FILE.PUT_LINE(l_log_handle,'DtlRec: item_qty('||l_idx||') = '||l_dtl_tbl(l_idx).item_qty) ;
      UTL_FILE.PUT_LINE(l_log_handle,'DtlRec: item_um('||l_idx||') = '||l_dtl_tbl(l_idx).item_um) ;
      UTL_FILE.PUT_LINE(l_log_handle,'DtlRec: burden_qty('||l_idx||') = '||l_dtl_tbl(l_idx).burden_qty) ;
      UTL_FILE.PUT_LINE(l_log_handle,'DtlRec: burden_um('||l_idx||') = '||l_dtl_tbl(l_idx).burden_um) ;
      UTL_FILE.PUT_LINE(l_log_handle,'DtlRec: delete_mark('||l_idx||') = '||l_dtl_tbl(l_idx).delete_mark) ;
      */
    END IF ;

  EXCEPTION
   WHEN OTHERS THEN
    UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
    UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
    IF l_type = 10 THEN
      l_skip_details := 'Y' ;
      UTL_FILE.PUT_LINE(l_log_handle, 'Error : Skip detail records.');
    ELSIF l_type = 20 THEN
      l_dtl_tbl.delete(l_idx);
      l_idx := l_idx-1;
    END IF ;
  END ;

  BEGIN
      --IF l_record_count > 1 THEN	-- to avoid calling API for the first record
	--l_first_rec := 'N' ;
      --END IF ;

      UTL_FILE.GET_LINE(l_infile_handle, l_line);
      l_record_count    :=l_record_count+1;
      UTL_FILE.NEW_LINE(l_log_handle);
      l_type   := Get_Field(l_line,l_delimiter,1) ;  -- 10 : header rec, 20 : Detail Record
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     IF l_skip_details = 'N' THEN
      UTL_FILE.PUT_LINE(l_log_handle,'In wrapper exception. Call to Call_Burden_API...');
      Call_Burden_API
      (
	p_burden_header		=>  l_header_rec
      , p_burden_detail		=>  l_dtl_tbl
      , p_operation    		=>  p_operation
      , x_burdenline_ids	=>  l_burdenline_ids
      , x_status       		=>  l_status
      , x_count    		=>  l_count
      , x_data         		=>  l_data
      ) ;

      UTL_FILE.PUT_LINE(l_log_handle,'In wrapper exception. After call to Call_Burden_API.status := ' ||
			l_status ||' cnt := ' || l_count );
      l_continue := 'N' ;
      goto GET_MSG_STACK ;
     END IF ;
  END;

    -- DBMS_OUTPUT.PUT_LINE('Check to call Call_Burden_API...type - ' || l_type || ' count = ' || l_record_count);

    IF (l_type = 10 AND l_record_count <> 1 AND l_skip_details = 'N') THEN
      UTL_FILE.PUT_LINE(l_log_handle,'In wrapper exception. Call to Call_Burden_API...');
      Call_Burden_API
      (
	p_burden_header		=>  l_header_rec
      , p_burden_detail		=>  l_dtl_tbl
      , p_operation    		=>  p_operation
      , x_burdenline_ids	=>  l_burdenline_ids
      , x_status       		=>  l_status
      , x_count    		=>  l_count
      , x_data         		=>  l_data
      ) ;
      UTL_FILE.PUT_LINE(l_log_handle,'In wrapper exception. After call to Call_Burden_API.status := ' ||
			l_status ||' cnt := ' || l_count );
    END IF;

   <<GET_MSG_STACK>>
     null;

    /*  Check if any messages generated. If so then decode and */
    /*  output to error message flat file */

    IF l_count > 0 THEN

       l_loop_cnt  :=1;
       LOOP
        FND_MSG_PUB.Get(
          p_msg_index     => l_loop_cnt,
          p_data          => l_data,
          p_encoded       => FND_API.G_FALSE,
          p_msg_index_out => l_dummy_cnt);

        ---- DBMS_OUTPUT.PUT_LINE(l_data );
        UTL_FILE.PUT_LINE(l_log_handle, l_data);

        /*  Update error status */
        IF (l_status = 'U') THEN
          l_return_status  :=l_status;
        ELSIF (l_status = 'E' and l_return_status <> 'U') THEN
          l_return_status  :=l_status;
        ELSE
          l_return_status  :=l_status;
        END IF;

        l_loop_cnt  := l_loop_cnt + 1;
        IF l_loop_cnt > l_count THEN
          EXIT;
        END IF;

      END LOOP; -- msg stack loop
      l_count := 0 ;

    END IF;	-- if count of msg stack > 0

    IF ((l_type = 10 AND l_record_count <> 1 AND l_skip_details = 'N') OR
	(l_continue = 'N')
       ) THEN
      FOR i in 1..l_burdenline_ids.count
      LOOP
        UTL_FILE.PUT_LINE(l_log_handle,'Resource : ' || l_burdenline_ids(i).resources ||
				       ' CmpntClsId : ' || l_burdenline_ids(i).cost_cmpntcls_id ||
				       ' Analysis Code : ' || l_burdenline_ids(i).cost_analysis_code ||
				       ' BurdenLineID : ' || l_burdenline_ids(i).burdenline_id);
      END LOOP ;
      l_burdenline_ids.delete ;
    END IF ;

    IF l_continue = 'N' THEN
      EXIT ;
    END IF ;

 END LOOP;

  -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.FCLOSE_ALL;

  RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /* -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN OTHERS THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Other Error'); */
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
   UTL_FILE.FCLOSE_ALL;
   l_return_status := 'U' ;
   RETURN l_return_status;

END Process_Burden_details;

/*  Body start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Get_Burden_details                                                    |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create burden details                                                 |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the                        |
 |    Get_Burden_details API wrapper function                               |
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
 |    27-Apr-2001  Uday Moogala  Created  Bug# 1418689                      |
 |    22-Oct-2005  Prasad Marada Modified as per inventory convergence      |
 |                               bug 4689137                                |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Get_Burden_details
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

 DBMS_OUTPUT.PUT_LINE('in Get_Burden_details procedure... ');
l_return_status  :=Get_Burden_details( p_dir
			      	       , p_input_file
                                       , p_output_file
                                       , p_delimiter
                                       );

-- DBMS_OUTPUT.PUT_LINE('return status := ' || l_return_status);
END Get_Burden_details;

/* +========================================================================+
 | FUNCTION NAME                                                            |
 |    Get_Burden_details                                                    |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create burden details                                                 |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Get_Burden_details API.                                               |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_rsrc_wrapper<session_id>.log in the /tmp directory.        |
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
 |    22-Oct-2005  Prasad Marada Modified as per inventory convergence      |
 |                               bug 4689137                                |
 |                                                                          |
 +==========================================================================+
*/
FUNCTION Get_Burden_details
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2
IS

/* Local variables */

l_status             VARCHAR2(11);
l_return_status      VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER(10)  ;
l_record_count       NUMBER(10)  :=0;
l_loop_cnt           NUMBER(10)  :=0;
l_dummy_cnt          NUMBER(10)  :=0;
l_data               VARCHAR2(1000);
l_header_rec         GMF_BurdenDetails_PUB.Burden_Header_Rec_Type;
l_dtl_tbl            GMF_BurdenDetails_PUB.Burden_Dtl_Tbl_Type;
l_p_dir              VARCHAR2(150);
l_output_file        VARCHAR2(120);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(120);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(1000);
l_delimiter          VARCHAR(11);
l_log_dir            VARCHAR2(150);
l_log_name           VARCHAR2(120) :='gmf_api_getbrdn_wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(120);
l_idx		     NUMBER(10);
l_idx1		     NUMBER(10);
l_type		     NUMBER(10);
l_continue           VARCHAR2(1) := 'Y' ;
l_skip_details       VARCHAR2(1) := 'N' ;
l_session_id         VARCHAR2(110);

BEGIN

  /*  Enable The Buffer  */
  /*  DBMS_OUTPUT.ENABLE(1000000); */

  -- DBMS_OUTPUT.PUT_LINE('in Get_Burden_details function...');

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

  /*  Loop thru flat file and call Inventory Quantities API */
  -- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  -- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
  -- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
  -- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
  -- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );


  /*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Input Directory  ' || l_p_dir );
  UTL_FILE.PUT_LINE(l_log_handle, 'Input File       ' || l_input_file );
  UTL_FILE.PUT_LINE(l_log_handle, 'Record Type      ' || l_delimiter );
  UTL_FILE.PUT_LINE(l_log_handle, 'Output File      ' || l_output_file );

  l_outfile_handle  :=UTL_FILE.FOPEN(l_p_dir, l_output_file, 'w');

 LOOP
  BEGIN
    UTL_FILE.GET_LINE(l_infile_handle, l_line);
    l_record_count    :=l_record_count+1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      EXIT ;
  END;

  BEGIN
    UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
      -- empty the tables
      l_dtl_tbl.delete ;

      l_header_rec.organization_id   := Get_Field(l_line,l_delimiter,1) ;
      l_header_rec.organization_code := Get_Field(l_line,l_delimiter,2) ;
      l_header_rec.inventory_item_id := Get_Field(l_line,l_delimiter,3) ;
      l_header_rec.item_number       := Get_Field(l_line,l_delimiter,4) ;
      l_header_rec.period_id         := Get_Field(l_line,l_delimiter,5) ;
      l_header_rec.calendar_code     := Get_Field(l_line,l_delimiter,6) ;
      l_header_rec.period_code       := Get_Field(l_line,l_delimiter,7) ;
      l_header_rec.cost_type_id      := Get_Field(l_line,l_delimiter,8) ;
      l_header_rec.cost_mthd_code    := Get_Field(l_line,l_delimiter,9) ;
      l_header_rec.user_name         := Get_Field(l_line,l_delimiter,10) ;

      UTL_FILE.PUT_LINE(l_log_handle, 'organization_id   = ' || l_header_rec.organization_id) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'organization_code = ' || l_header_rec.organization_code) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'inventory_item_id = ' || l_header_rec.inventory_item_id) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'item_number  = '      || l_header_rec.item_number) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'period_id   = '     || l_header_rec.period_id) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'calendar_code   = ' || l_header_rec.calendar_code) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'period_code   = '   || l_header_rec.period_code) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'cost_type_id   = '  || l_header_rec.cost_type_id) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'cost_mthd_code  = ' || l_header_rec.cost_mthd_code) ;
      UTL_FILE.PUT_LINE(l_log_handle, 'user_name   = '     || l_header_rec.user_name) ;

       -- Invoke public get burden details
      GMF_BurdenDetails_PUB.Get_Burden_Details
      (
        p_api_version        =>  2.0
      , p_init_msg_list      =>  FND_API.G_TRUE

      , x_return_status      =>  l_status
      , x_msg_count          =>  l_count
      , x_msg_data           =>  l_data

      , p_header_rec         =>  l_header_rec

      , x_dtl_tbl            =>  l_dtl_tbl
      );

      UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );

    /*  Check if any messages generated. If so then decode and */
    /*  output to error message flat file */

    IF l_count > 0 THEN

       l_loop_cnt  :=1;
       LOOP
        FND_MSG_PUB.Get(
          p_msg_index     => l_loop_cnt,
          p_data          => l_data,
          p_encoded       => FND_API.G_FALSE,
          p_msg_index_out => l_dummy_cnt);

        ---- DBMS_OUTPUT.PUT_LINE(l_data );
        UTL_FILE.PUT_LINE(l_log_handle, l_data);

        /*  Update error status */
        IF (l_status = 'U') THEN
          l_return_status  :=l_status;
        ELSIF (l_status = 'E' and l_return_status <> 'U') THEN
          l_return_status  :=l_status;
        ELSE
          l_return_status  :=l_status;
        END IF;

        l_loop_cnt  := l_loop_cnt + 1;
        IF l_loop_cnt > l_count THEN
          EXIT;
        END IF;

      END LOOP; -- msg stack loop
      l_count := 0 ;

    END IF;	-- if count of msg stack > 0

    UTL_FILE.NEW_LINE(l_log_handle);
    FOR i in 1..l_dtl_tbl.count
    LOOP
      UTL_FILE.PUT_LINE(l_log_handle,
			'Burdenline_Id : ' || l_dtl_tbl(i).Burdenline_Id ||
			' resources : ' || l_dtl_tbl(i).resources ||
			' Cmpntcls Id : ' || l_dtl_tbl(i).cost_cmpntcls_id ||
			' Cmpntcls Code : ' || l_dtl_tbl(i).cost_cmpntcls_id ||
			' Alys Code : ' || l_dtl_tbl(i).cost_analysis_code
		       );
      UTL_FILE.PUT_LINE(l_log_handle,
			' Burden Usage : ' || l_dtl_tbl(i).Burden_Usage ||
			' Item Qty : ' || l_dtl_tbl(i).item_qty ||
			' Item UOM : ' || l_dtl_tbl(i).Item_UOM ||
			' Burden Qty : ' || l_dtl_tbl(i).Burden_Qty ||
			' Burden UOM : ' || l_dtl_tbl(i).Burden_UOM ||
			' Burden Factor : ' || l_dtl_tbl(i).Burden_Factor ||
			' Delete Mark : ' || l_dtl_tbl(i).Delete_Mark
                       );
    END LOOP ;
    l_dtl_tbl.delete ;
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.NEW_LINE(l_log_handle);

  EXCEPTION
   WHEN OTHERS THEN
    UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
    UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  END ;

 END LOOP;

  -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.FCLOSE_ALL;

  RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /* -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN OTHERS THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Other Error'); */
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
   UTL_FILE.FCLOSE_ALL;
   l_return_status := 'U' ;
   RETURN l_return_status;

END Get_Burden_details;

/* +========================================================================+
 | FUNCTION NAME                                                            |
 |    Call_Burden_API                                                 |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Calls burden APIs based on the operation being performed              |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the Burden_detail API.      |
 |    Data is sent from through the parameters.                             |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_burden_header    IN VARCHAR2         - Burden Details Header        |
 |    p_burden_detail    IN VARCHAR2         - Burden Details               |
 |    p_operation        IN VARCHAR2         - Insert/Update/Delete         |
 |    x_burdenline_ids   OUT VARCHAR2        - Inserted burdenline_ids      |
 |    x_status           OUT VARCHAR2        - Return Status                |
 |    x_count            OUT VARCHAR2        - # of msgs on message stack   |
 |    x_data             OUT VARCHAR2        - Actual Message from msg stack|
 |                                                                          |
 | RETURNS                                                                  |
 |    VARCHAR2 - 'S' All records processed successfully                     |
 |               'E' 1 or more records errored                              |
 |               'U' 1 or more record unexpected error                      |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 +==========================================================================+
*/
PROCEDURE Call_Burden_API
(
  p_burden_header    IN  GMF_BurdenDetails_PUB.Burden_Header_Rec_Type
, p_burden_detail    IN  GMF_BurdenDetails_PUB.Burden_Dtl_Tbl_Type
, p_operation        IN  VARCHAR2
, x_burdenline_ids   OUT NOCOPY GMF_BurdenDetails_PUB.Burdenline_Ids_Tbl_Type
, x_status           OUT NOCOPY VARCHAR2
, x_count            OUT NOCOPY NUMBER
, x_data             OUT NOCOPY VARCHAR2
)
IS

BEGIN

 IF p_operation = 'INSERT' THEN
   GMF_BurdenDetails_PUB.Create_Burden_Details
   (
     p_api_version        =>  2.0
   , p_init_msg_list      =>  FND_API.G_TRUE
   , p_commit             =>  FND_API.G_TRUE

   , x_return_status      =>  x_status
   , x_msg_count          =>  x_count
   , x_msg_data           =>  x_data

   , p_header_rec         =>  p_burden_header
   , p_dtl_tbl            =>  p_burden_detail

   , x_burdenline_ids     =>  x_burdenline_ids
   );
 ELSIF p_operation = 'UPDATE' THEN
   GMF_BurdenDetails_PUB.Update_Burden_Details
   (
     p_api_version        =>  2.0
   , p_init_msg_list      =>  FND_API.G_TRUE
   , p_commit             =>  FND_API.G_TRUE

   , x_return_status      =>  x_status
   , x_msg_count          =>  x_count
   , x_msg_data           =>  x_data

   , p_header_rec         =>  p_burden_header
   , p_dtl_tbl            =>  p_burden_detail
   );
 ELSIF p_operation = 'DELETE' THEN
   GMF_BurdenDetails_PUB.Delete_Burden_Details
   (
     p_api_version        =>  2.0
   , p_init_msg_list      =>  FND_API.G_TRUE
   , p_commit             =>  FND_API.G_TRUE

   , x_return_status      =>  x_status
   , x_msg_count          =>  x_count
   , x_msg_data           =>  x_data

   , p_header_rec         =>  p_burden_header
   , p_dtl_tbl            =>  p_burden_detail
   );
 END IF ;

END Call_Burden_API ;



/*  Body start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Create_resource_cost                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create Resource Cost                                                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the                        |
 |    Create_Resource_Cost API wrapper function                             |
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
 | 27-Feb-2001  Uday Moogala  Created  Bug# 1418689                         |
 | 21-Oct-2005  Prasad marada Modified the procedure as per the record type |
 |              changes in resource cost public packages                    |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Create_resource_cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

-- DBMS_OUTPUT.PUT_LINE('in Create_resource_cost procedure... ');
l_return_status  :=Create_resource_cost( p_dir
			      	       , p_input_file
                                       , p_output_file
                                       , p_delimiter
                                       );

 -- DBMS_OUTPUT.PUT_LINE('return status := ' || l_return_status);
END Create_resource_cost;

/* +========================================================================+
 | FUNCTION NAME                                                            |
 |    Create_resource_cost                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create Resource Cost                                                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Create_Resource_Cost API.                                             |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_rsrc_wrapper<session_id>.log in the /tmp directory.        |
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
 | 21-Oct-2005  Prasad marada Modified the procedure as per the record type |
 |              changes in resource cost public packages                    |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
FUNCTION Create_resource_cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2
IS

/* Local variables */

l_status             VARCHAR2(11);
l_return_status      VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER(10)  ;
l_record_count       NUMBER(10)  :=0;
l_loop_cnt           NUMBER(10)  :=0;
l_dummy_cnt          NUMBER(10)  :=0;
l_data               VARCHAR2(1000);
rsrc_rec             GMF_ResourceCost_PUB.Resource_Cost_Rec_Type;
l_p_dir              VARCHAR2(150);
l_output_file        VARCHAR2(120);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(120);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(1000);
l_delimiter          VARCHAR(11);
l_log_dir            VARCHAR2(150);
l_log_name           VARCHAR2(120)  :='gmf_api_crrc_wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(120);

l_session_id         VARCHAR2(110);

BEGIN

/*  Enable The Buffer  */
/*  DBMS_OUTPUT.ENABLE(1000000); */

-- DBMS_OUTPUT.PUT_LINE('in Create_resource_cost function...');

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

/*  Loop thru flat file and call Inventory Quantities API */
-- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
-- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
-- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
-- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
-- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );

/*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
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

BEGIN
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );

  rsrc_rec.resources           := Get_Field(l_line,l_delimiter,1) ;
  rsrc_rec.legal_entity_id     := Get_Field(l_line,l_delimiter,2) ;
  rsrc_rec.organization_id     := Get_Field(l_line,l_delimiter,3) ;
  rsrc_rec.organization_code   := Get_Field(l_line,l_delimiter,4) ;
  rsrc_rec.period_id           := Get_Field(l_line,l_delimiter,5) ;
  rsrc_rec.calendar_code       := Get_Field(l_line,l_delimiter,6) ;
  rsrc_rec.period_code         := Get_Field(l_line,l_delimiter,7) ;
  rsrc_rec.cost_type_id        := Get_Field(l_line,l_delimiter,8) ;
  rsrc_rec.cost_mthd_code      := Get_Field(l_line,l_delimiter,9) ;
  rsrc_rec.usage_uom           := Get_Field(l_line,l_delimiter,10) ;
  rsrc_rec.nominal_cost        := Get_Field(l_line,l_delimiter,11) ;
  rsrc_rec.delete_mark         := Get_Field(l_line,l_delimiter,12) ;
  rsrc_rec.user_name           := Get_Field(l_line,l_delimiter,13) ;

  UTL_FILE.PUT_LINE(l_log_handle, 'resources     = ' || rsrc_rec.resources);
  UTL_FILE.PUT_LINE(l_log_handle, 'legal_entity_id= ' || rsrc_rec.legal_entity_id);
  UTL_FILE.PUT_LINE(l_log_handle, 'organization_id= ' || rsrc_rec.organization_id);
  UTL_FILE.PUT_LINE(l_log_handle, 'organization_code= ' || rsrc_rec.organization_code);
  UTL_FILE.PUT_LINE(l_log_handle, 'period_id     = ' || rsrc_rec.period_id);
  UTL_FILE.PUT_LINE(l_log_handle, 'calendar_code = ' || rsrc_rec.calendar_code);
  UTL_FILE.PUT_LINE(l_log_handle, 'period_code   = ' || rsrc_rec.period_code);
  UTL_FILE.PUT_LINE(l_log_handle, 'cost_type_id= '   || rsrc_rec.cost_type_id);
  UTL_FILE.PUT_LINE(l_log_handle, 'cost_mthd_code= ' || rsrc_rec.cost_mthd_code);
  UTL_FILE.PUT_LINE(l_log_handle, 'usage_uom     = ' || rsrc_rec.usage_uom);
  UTL_FILE.PUT_LINE(l_log_handle, 'nominal_cost  = ' || rsrc_rec.nominal_cost);
  UTL_FILE.PUT_LINE(l_log_handle, 'delete_mark   = ' || rsrc_rec.delete_mark);
  UTL_FILE.PUT_LINE(l_log_handle, 'user_name     = ' || rsrc_rec.user_name);

  GMF_ResourceCost_PUB.Create_Resource_Cost
  ( p_api_version    => 2.0
  , p_init_msg_list  => FND_API.G_TRUE
  , p_commit         => FND_API.G_TRUE

  , x_return_status  =>l_status
  , x_msg_count      =>l_count
  , x_msg_data       =>l_data

  , p_Resource_Cost_rec => rsrc_rec
  );

  UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );
  IF l_count > 0
  THEN
    l_loop_cnt  :=1;
    LOOP

    FND_MSG_PUB.Get(
      p_msg_index     => l_loop_cnt,
      p_data          => l_data,
      p_encoded       => FND_API.G_FALSE,
      p_msg_index_out => l_dummy_cnt);


    -- DBMS_OUTPUT.PUT_LINE(l_data );

    UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
    UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
    UTL_FILE.NEW_LINE(l_outfile_handle);

  /*
    IF l_status = 'E' OR
       l_status = 'U'
    THEN
      l_data    := CONCAT('ERROR : ',l_data);
    END IF;
  */

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

EXCEPTION
 WHEN OTHERS THEN
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  l_return_status := 'U' ;
END ;


END LOOP;
  -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));

/*  Check if any messages generated. If so then decode and */
/*  output to error message flat file */

UTL_FILE.FCLOSE_ALL;

RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /* -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN OTHERS THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Other Error'); */
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
   UTL_FILE.FCLOSE_ALL;
   l_return_status := 'U' ;
   RETURN l_return_status;

END Create_resource_cost;

/*  API start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Update_resource_cost                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Update Resource Cost                                                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the                        |
 |    Update_resource_cost API wrapper function                             |
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
 |    07-Mar-2001  Uday Moogala    created                                  |

 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Update_resource_cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

 ---- DBMS_OUTPUT.PUT_LINE('in Update_resource_cost procedure... ');
l_return_status  :=Update_resource_cost( p_dir
                                     , p_input_file
                                     , p_output_file
                                     , p_delimiter
                                   );

 -- DBMS_OUTPUT.PUT_LINE('return status := ' || l_return_status);
END Update_resource_cost;

/* +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Update_resource_cost                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Update Resource Cost                                                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Update_Resource_Cost API.                                             |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_aloc_wrapper<session_id>.log in the temp directory.        |
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
 | 21-Oct-2005 Prasad marada Modified the procedure as per the record type  |
 |                           changes in resource cost public packages       |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
FUNCTION Update_resource_cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2
IS

/* Local variables */

l_status             VARCHAR2(100);
l_return_status      VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER(10)  ;
l_record_count       NUMBER(10)  :=0;
l_loop_cnt           NUMBER(10)  :=0;
l_dummy_cnt          NUMBER(10)  :=0;
l_data               VARCHAR2(2000);
rsrc_rec             GMF_ResourceCost_PUB.Resource_Cost_Rec_Type;
l_p_dir              VARCHAR2(150);
l_output_file        VARCHAR2(120);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(120);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(1800);
l_delimiter          VARCHAR(11);
l_log_dir            VARCHAR2(150);
l_log_name           VARCHAR2(120)  :='gmf_api_updrc_wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(120);

l_session_id         VARCHAR2(110);

BEGIN

/*  Enable The Buffer  */
/*  DBMS_OUTPUT.ENABLE(1000000); */

-- DBMS_OUTPUT.PUT_LINE('in Update_resource_cost function...');

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

/*  Loop thru flat file and call Inventory Quantities API */
-- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
-- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
-- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
-- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
-- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );


/*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
UTL_FILE.NEW_LINE(l_log_handle);
UTL_FILE.PUT_LINE(l_log_handle, 'Input Directory  ' || l_p_dir );
UTL_FILE.PUT_LINE(l_log_handle, 'Input File       ' || l_input_file );
UTL_FILE.PUT_LINE(l_log_handle, 'Record Type      ' || l_delimiter );
UTL_FILE.PUT_LINE(l_log_handle, 'Output File      ' || l_output_file );

l_outfile_handle  :=UTL_FILE.FOPEN(l_p_dir, l_output_file, 'w');

LOOP
  l_record_count    :=l_record_count+1;
  BEGIN
    BEGIN
      UTL_FILE.NEW_LINE(l_log_handle);
      UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );
      UTL_FILE.GET_LINE(l_infile_handle, l_line);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
    END;
    IF l_line IS NULL THEN
      EXIT;
    ELSE
      rsrc_rec.resources           := Get_Field(l_line,l_delimiter,1) ;
      rsrc_rec.legal_entity_id     := Get_Field(l_line,l_delimiter,2) ;
      rsrc_rec.organization_id     := Get_Field(l_line,l_delimiter,3) ;
      rsrc_rec.organization_code   := Get_Field(l_line,l_delimiter,4) ;
      rsrc_rec.period_id           := Get_Field(l_line,l_delimiter,5) ;
      rsrc_rec.calendar_code       := Get_Field(l_line,l_delimiter,6) ;
      rsrc_rec.period_code         := Get_Field(l_line,l_delimiter,7) ;
      rsrc_rec.cost_type_id        := Get_Field(l_line,l_delimiter,8) ;
      rsrc_rec.cost_mthd_code      := Get_Field(l_line,l_delimiter,9) ;
      rsrc_rec.usage_uom           := Get_Field(l_line,l_delimiter,10) ;
      rsrc_rec.nominal_cost        := Get_Field(l_line,l_delimiter,11) ;
      rsrc_rec.delete_mark         := Get_Field(l_line,l_delimiter,12) ;
      rsrc_rec.user_name           := Get_Field(l_line,l_delimiter,13) ;

      UTL_FILE.PUT_LINE(l_log_handle, 'resources     = ' || rsrc_rec.resources);
      UTL_FILE.PUT_LINE(l_log_handle, 'legal_entity_id= ' || rsrc_rec.legal_entity_id);
      UTL_FILE.PUT_LINE(l_log_handle, 'organization_id= ' || rsrc_rec.organization_id);
      UTL_FILE.PUT_LINE(l_log_handle, 'organization_code= ' || rsrc_rec.organization_code);
      UTL_FILE.PUT_LINE(l_log_handle, 'period_id     = ' || rsrc_rec.period_id);
      UTL_FILE.PUT_LINE(l_log_handle, 'calendar_code = ' || rsrc_rec.calendar_code);
      UTL_FILE.PUT_LINE(l_log_handle, 'period_code   = ' || rsrc_rec.period_code);
      UTL_FILE.PUT_LINE(l_log_handle, 'cost_type_id= '   || rsrc_rec.cost_type_id);
      UTL_FILE.PUT_LINE(l_log_handle, 'cost_mthd_code= ' || rsrc_rec.cost_mthd_code);
      UTL_FILE.PUT_LINE(l_log_handle, 'usage_uom     = ' || rsrc_rec.usage_uom);
      UTL_FILE.PUT_LINE(l_log_handle, 'nominal_cost  = ' || rsrc_rec.nominal_cost);
      UTL_FILE.PUT_LINE(l_log_handle, 'delete_mark   = ' || rsrc_rec.delete_mark);
      UTL_FILE.PUT_LINE(l_log_handle, 'user_name     = ' || rsrc_rec.user_name);

  -- DBMS_OUTPUT.PUT_LINE('before calling Update API...');
  GMF_ResourceCost_PUB.Update_Resource_Cost
  ( p_api_version    => 2.0
  , p_init_msg_list  => FND_API.G_TRUE
  , p_commit         => FND_API.G_TRUE

  , x_return_status  =>l_status
  , x_msg_count      =>l_count
  , x_msg_data       =>l_data

  , p_Resource_Cost_rec => rsrc_rec
  );

    UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );
  IF l_count > 0
  THEN
    l_loop_cnt  :=1;
    LOOP

    FND_MSG_PUB.Get(
      p_msg_index     => l_loop_cnt,
      p_data          => l_data,
      p_encoded       => FND_API.G_FALSE,
      p_msg_index_out => l_dummy_cnt);


    -- DBMS_OUTPUT.PUT_LINE(l_data );

    UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
    UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
    UTL_FILE.NEW_LINE(l_outfile_handle);


  /*
    IF l_status = 'E' OR
       l_status = 'U'
    THEN
      l_data    := CONCAT('ERROR : ',l_data);
    END IF;
  */

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
  END IF;


EXCEPTION
 WHEN OTHERS THEN
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  l_return_status := 'U' ;
END ;

END LOOP;
  -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));

/*  Check if any messages generated. If so then decode and */
/*  output to error message flat file */

UTL_FILE.FCLOSE_ALL;

RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /* -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN OTHERS THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Other Error'); */
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
   UTL_FILE.FCLOSE_ALL;
   l_return_status := 'U' ;
   RETURN l_return_status;

END Update_resource_cost;

/*  API start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Delete_resource_cost                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Delete Resource Cost                                                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the                        |
 |    Delete_resource_cost API wrapper function                             |
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
 |    07-Mar-2001  Uday Moogala    created                                  |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Delete_resource_cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

 ---- DBMS_OUTPUT.PUT_LINE('in Delete_resource_cost procedure... ');
l_return_status  :=Delete_resource_cost( p_dir
                                     , p_input_file
                                     , p_output_file
                                     , p_delimiter
                                   );

 -- DBMS_OUTPUT.PUT_LINE('return status := ' || l_return_status);
END Delete_resource_cost;

/* +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Delete_resource_cost                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Delete Resource Cost                                                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Delete_Resource_Cost API.                                             |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_rsrc_wrapper<session_id>.log in the temp directory.        |
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
 | 21-Oct-2005 Prasad marada Modified the procedure as per the record type  |
 |                           changes in resource cost public packages       |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
FUNCTION Delete_resource_cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2
IS

/* Local variables */

l_status             VARCHAR2(100);
l_return_status      VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER(10)  ;
l_record_count       NUMBER(10)  :=0;
l_loop_cnt           NUMBER(10)  :=0;
l_dummy_cnt          NUMBER(10)  :=0;
l_data               VARCHAR2(2000);
rsrc_rec             GMF_ResourceCost_PUB.Resource_Cost_Rec_Type;
l_p_dir              VARCHAR2(150);
l_output_file        VARCHAR2(120);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(120);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(1800);
l_delimiter          VARCHAR(11);
l_log_dir            VARCHAR2(150);
l_log_name           VARCHAR2(120)  :='gmf_api_delrc_wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(120);

l_session_id         VARCHAR2(110);

BEGIN

/*  Enable The Buffer  */
/*  DBMS_OUTPUT.ENABLE(1000000); */

-- DBMS_OUTPUT.PUT_LINE('in Delete_resource_cost function...');

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

/*  Loop thru flat file and call Inventory Quantities API */
-- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
-- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
-- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
-- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
-- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );


/*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
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

BEGIN
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );

  rsrc_rec.resources           := Get_Field(l_line,l_delimiter,1) ;
  rsrc_rec.legal_entity_id     := Get_Field(l_line,l_delimiter,2) ;
  rsrc_rec.organization_id     := Get_Field(l_line,l_delimiter,3) ;
  rsrc_rec.organization_code   := Get_Field(l_line,l_delimiter,4) ;
  rsrc_rec.period_id           := Get_Field(l_line,l_delimiter,5) ;
  rsrc_rec.calendar_code       := Get_Field(l_line,l_delimiter,6) ;
  rsrc_rec.period_code         := Get_Field(l_line,l_delimiter,7) ;
  rsrc_rec.cost_type_id        := Get_Field(l_line,l_delimiter,8) ;
  rsrc_rec.cost_mthd_code      := Get_Field(l_line,l_delimiter,9) ;
  rsrc_rec.usage_uom           := Get_Field(l_line,l_delimiter,10) ;
  rsrc_rec.nominal_cost        := Get_Field(l_line,l_delimiter,11) ;
  rsrc_rec.delete_mark         := Get_Field(l_line,l_delimiter,12) ;
  rsrc_rec.user_name           := Get_Field(l_line,l_delimiter,13) ;

  UTL_FILE.PUT_LINE(l_log_handle, 'resources     = ' || rsrc_rec.resources);
  UTL_FILE.PUT_LINE(l_log_handle, 'legal_entity_id= ' || rsrc_rec.legal_entity_id);
  UTL_FILE.PUT_LINE(l_log_handle, 'organization_id= ' || rsrc_rec.organization_id);
  UTL_FILE.PUT_LINE(l_log_handle, 'organization_code= ' || rsrc_rec.organization_code);
  UTL_FILE.PUT_LINE(l_log_handle, 'period_id     = ' || rsrc_rec.period_id);
  UTL_FILE.PUT_LINE(l_log_handle, 'calendar_code = ' || rsrc_rec.calendar_code);
  UTL_FILE.PUT_LINE(l_log_handle, 'period_code   = ' || rsrc_rec.period_code);
  UTL_FILE.PUT_LINE(l_log_handle, 'cost_type_id= '   || rsrc_rec.cost_type_id);
  UTL_FILE.PUT_LINE(l_log_handle, 'cost_mthd_code= ' || rsrc_rec.cost_mthd_code);
  UTL_FILE.PUT_LINE(l_log_handle, 'usage_uom     = ' || rsrc_rec.usage_uom);
  UTL_FILE.PUT_LINE(l_log_handle, 'nominal_cost  = ' || rsrc_rec.nominal_cost);
  UTL_FILE.PUT_LINE(l_log_handle, 'delete_mark   = ' || rsrc_rec.delete_mark);
  UTL_FILE.PUT_LINE(l_log_handle, 'user_name     = ' || rsrc_rec.user_name);

  -- DBMS_OUTPUT.PUT_LINE('before calling Delete API...');
  GMF_ResourceCost_PUB.Delete_Resource_Cost
  ( p_api_version    => 2.0
  , p_init_msg_list  => FND_API.G_TRUE
  , p_commit         => FND_API.G_TRUE

  , x_return_status  =>l_status
  , x_msg_count      =>l_count
  , x_msg_data       =>l_data

  , p_Resource_Cost_rec => rsrc_rec
  );

    UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );
  IF l_count > 0
  THEN
    l_loop_cnt  :=1;
    LOOP

    FND_MSG_PUB.Get(
      p_msg_index     => l_loop_cnt,
      p_data          => l_data,
      p_encoded       => FND_API.G_FALSE,
      p_msg_index_out => l_dummy_cnt);


    -- DBMS_OUTPUT.PUT_LINE(l_data );

    UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
    UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
    UTL_FILE.NEW_LINE(l_outfile_handle);

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

EXCEPTION
 WHEN OTHERS THEN
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  l_return_status := 'U' ;
END ;


END LOOP;
  -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));

/*  Check if any messages generated. If so then decode and */
/*  output to error message flat file */

UTL_FILE.FCLOSE_ALL;

RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /* -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN OTHERS THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Other Error'); */
  UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
   UTL_FILE.FCLOSE_ALL;
   l_return_status := 'U' ;
   RETURN l_return_status;

END Delete_resource_cost;

/*  Body start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Get_Resource_Cost                                                     |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Get Item Cost                                                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the                        |
 |    Get_Resource_Cost API wrapper function                                |
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
 |    27/Feb/2001  Uday Moogala  Created  Bug# 1418689                      |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Get_Resource_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

-- DBMS_OUTPUT.PUT_LINE('in Get_Resource_Cost procedure... ');
l_return_status  :=Get_Resource_Cost( p_dir
			      	, p_input_file
                                , p_output_file
                                , p_delimiter
                                );

 -- DBMS_OUTPUT.PUT_LINE('return status := ' || l_return_status);
END Get_Resource_Cost;

/* +========================================================================+
 | FUNCTION NAME                                                            |
 |    Get_Resource_Cost                                                     |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Get Item Cost                                                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the                         |
 |    Get_Resource_Cost API.                                                |
 |    It reads item data from a flat file and outputs any error             |
 |    messages to a second flat file. It also generates a Status            |
 |    called gmf_rsrc_wrapper<session_id>.log in the /tmp directory.        |
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

FUNCTION Get_Resource_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2
IS

/* Local variables */

l_status             VARCHAR2(100);
l_return_status      VARCHAR2(11) :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER(10)  ;
l_record_count       NUMBER(10)  :=0;
l_loop_cnt           NUMBER(10)  :=0;
l_dummy_cnt          NUMBER(10)  :=0;
l_data               VARCHAR2(2000);
rsrc_rec             GMF_ResourceCost_PUB.Resource_Cost_Rec_Type;
x_rsrc_rec           GMF_ResourceCost_PUB.Resource_Cost_Rec_Type;
l_p_dir              VARCHAR2(150);
l_output_file        VARCHAR2(120);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(120);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(1800);
l_delimiter          VARCHAR(11);
l_log_dir            VARCHAR2(150);
l_log_name           VARCHAR2(120)  :='gmf_api_getrc_wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(120);

l_session_id         VARCHAR2(110);

BEGIN

/*  Enable The Buffer  */
/*  DBMS_OUTPUT.ENABLE(1000000); */

-- DBMS_OUTPUT.PUT_LINE('in Get_resource_cost function...');

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

/*  Loop thru flat file and call Inventory Quantities API */
-- DBMS_OUTPUT.PUT_LINE('Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
-- DBMS_OUTPUT.PUT_LINE('Input Directory  ' || l_p_dir );
-- DBMS_OUTPUT.PUT_LINE('Input File       ' || l_input_file );
-- DBMS_OUTPUT.PUT_LINE('Delimiter        ' || l_delimiter );
-- DBMS_OUTPUT.PUT_LINE('Output File      ' || l_output_file );


/*  -- DBMS_OUTPUT.PUT_LINE('Start Processing'); */
UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
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

  BEGIN
    UTL_FILE.NEW_LINE(l_log_handle);
    UTL_FILE.PUT_LINE(l_log_handle, 'Reading Record...' || l_record_count );

    rsrc_rec.resources           := Get_Field(l_line,l_delimiter,1) ;
    rsrc_rec.legal_entity_id     := Get_Field(l_line,l_delimiter,2) ;
    rsrc_rec.organization_id     := Get_Field(l_line,l_delimiter,3) ;
    rsrc_rec.organization_code   := Get_Field(l_line,l_delimiter,4) ;
    rsrc_rec.period_id           := Get_Field(l_line,l_delimiter,5) ;
    rsrc_rec.calendar_code       := Get_Field(l_line,l_delimiter,6) ;
    rsrc_rec.period_code         := Get_Field(l_line,l_delimiter,7) ;
    rsrc_rec.cost_type_id        := Get_Field(l_line,l_delimiter,8) ;
    rsrc_rec.cost_mthd_code      := Get_Field(l_line,l_delimiter,9) ;
    rsrc_rec.usage_uom           := Get_Field(l_line,l_delimiter,10) ;
    rsrc_rec.nominal_cost        := Get_Field(l_line,l_delimiter,11) ;
    rsrc_rec.delete_mark         := Get_Field(l_line,l_delimiter,12) ;
    rsrc_rec.user_name           := Get_Field(l_line,l_delimiter,13) ;

    UTL_FILE.PUT_LINE(l_log_handle, 'resources     = ' || rsrc_rec.resources);
    UTL_FILE.PUT_LINE(l_log_handle, 'legal_entity_id= ' || rsrc_rec.legal_entity_id);
    UTL_FILE.PUT_LINE(l_log_handle, 'organization_id= ' || rsrc_rec.organization_id);
    UTL_FILE.PUT_LINE(l_log_handle, 'organization_code= ' || rsrc_rec.organization_code);
    UTL_FILE.PUT_LINE(l_log_handle, 'period_id     = ' || rsrc_rec.period_id);
    UTL_FILE.PUT_LINE(l_log_handle, 'calendar_code = ' || rsrc_rec.calendar_code);
    UTL_FILE.PUT_LINE(l_log_handle, 'period_code   = ' || rsrc_rec.period_code);
    UTL_FILE.PUT_LINE(l_log_handle, 'cost_type_id= '   || rsrc_rec.cost_type_id);
    UTL_FILE.PUT_LINE(l_log_handle, 'cost_mthd_code= ' || rsrc_rec.cost_mthd_code);
    UTL_FILE.PUT_LINE(l_log_handle, 'usage_uom     = ' || rsrc_rec.usage_uom);
    UTL_FILE.PUT_LINE(l_log_handle, 'nominal_cost  = ' || rsrc_rec.nominal_cost);
    UTL_FILE.PUT_LINE(l_log_handle, 'delete_mark   = ' || rsrc_rec.delete_mark);
    UTL_FILE.PUT_LINE(l_log_handle, 'user_name     = ' || rsrc_rec.user_name);

    -- DBMS_OUTPUT.PUT_LINE('before calling Get Resource Cost Public API...');
    GMF_ResourceCost_PUB.Get_Resource_Cost
    ( p_api_version    => 2.0
    , p_init_msg_list  => FND_API.G_TRUE

    , x_return_status  =>l_status
    , x_msg_count      =>l_count
    , x_msg_data       =>l_data

    , p_Resource_Cost_rec => rsrc_rec
    , x_Resource_Cost_rec => x_rsrc_rec
    );

    UTL_FILE.PUT_LINE(l_log_handle, 'after API call. status := ' || l_status ||' cnt := ' || l_count );
    IF l_count > 0
    THEN
      l_loop_cnt  :=1;
      LOOP

        FND_MSG_PUB.Get(
          p_msg_index     => l_loop_cnt,
          p_data          => l_data,
          p_encoded       => FND_API.G_FALSE,
          p_msg_index_out => l_dummy_cnt);


        -- DBMS_OUTPUT.PUT_LINE(l_data );
        --UTL_FILE.PUT_LINE(l_outfile_handle, 'Record = ' ||l_record_count );
        --UTL_FILE.PUT_LINE(l_outfile_handle, l_data);
        --UTL_FILE.NEW_LINE(l_outfile_handle);

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
    END IF;	-- message count

    IF (x_rsrc_rec.usage_uom <> FND_API.G_MISS_CHAR) OR
       (x_rsrc_rec.nominal_cost <> FND_API.G_MISS_NUM) THEN

      UTL_FILE.PUT_LINE( l_log_handle,
                       'Usage_uom : '         || x_rsrc_rec.usage_uom ||
                       ' Nominal Cost : '    || x_rsrc_rec.nominal_cost ||
                       ' Delete Mark : '     || x_rsrc_rec.delete_mark ||
                       ' User Name : '       || x_rsrc_rec.user_name
                       ) ;
    END IF ;

  EXCEPTION
   WHEN OTHERS THEN
    UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
    UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
    l_return_status := 'U' ;
  END ;

END LOOP ;

  -- DBMS_OUTPUT.PUT_LINE('Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.NEW_LINE(l_log_handle);
  UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
  UTL_FILE.FCLOSE_ALL;

  RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /* -- DBMS_OUTPUT.PUT_LINE('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Write Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN OTHERS THEN
   /*  -- DBMS_OUTPUT.PUT_LINE('Other Error'); */
   UTL_FILE.PUT_LINE(l_outfile_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
   UTL_FILE.PUT_LINE(l_log_handle, 'Error : ' || to_char(SQLCODE) || ' ' || SQLERRM);
   UTL_FILE.PUT_LINE(l_log_handle, 'Process Completed at ' || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
   UTL_FILE.FCLOSE_ALL;
   l_return_status := 'U' ;
   RETURN l_return_status;

END Get_Resource_Cost;




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
l_string   VARCHAR2(2000);

BEGIN

/* Determine start position */
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
  -- RETURN SUBSTR(p_line,(l_start + 1),((l_end - l_start) - 1));
  l_string := SUBSTR(p_line,(l_start + 1),((l_end - l_start) - 1));

  IF l_string IS NULL THEN
	RETURN NULL;
  ELSIF l_string = 'G_MISS_CHAR' THEN
	RETURN FND_API.G_MISS_CHAR;
  ELSIF l_string = 'G_MISS_NUM' THEN
	RETURN FND_API.G_MISS_NUM;
  ELSIF l_string = 'G_MISS_DATE' THEN
	RETURN FND_API.G_MISS_DATE;
  ELSE
	RETURN l_string;
  END IF;

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


END GMF_API_WRP;

/
