--------------------------------------------------------
--  DDL for Package Body GMI_ITEM_WRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_ITEM_WRP" AS
/*  $Header: GMIPITWB.pls 115.12 2003/09/17 15:45:26 txyu gmigapib.pls $ */
/*  Body start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Create_Item                                                           |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create an Inventory Item                                              |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper procedure to call the Create_Item            |
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
 |    16-AUG-1999        B965832(1)   Set lot_status/qc_grade to NULL if    |
 |                                    they are read in as spaces            |
 |  18-Oct-2002   Bug 2513463 - Fixed code so that errors are returned.     |
 |  11-Sep-2003   B2378017 - Added code to read in four new classes.        |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Create_Item
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
IS

l_return_status  VARCHAR2(1);

BEGIN

l_return_status  :=Create_item( p_dir
			      , p_input_file
                              , p_output_file
                              , p_delimiter
                              );

End Create_Item;

/* +==========================================================================+
 | FUNCTION NAME                                                            |
 |    Create_Item                                                           |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create an inventory item                                              |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This is a PL/SQL wrapper function to call the FND                     |
 |    Inventory Create Item API.                                            |
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
 |  18-Oct-2002   Bug 2513463 - Fixed code so that errors are returned.     |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
FUNCTION Create_Item
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2
IS

/* Local variables */

l_status             VARCHAR2(1);
l_return_status      VARCHAR2(1)  :=FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER  ;
l_record_count       NUMBER  :=0;
l_loop_cnt           NUMBER  :=0;
l_dummy_cnt          NUMBER  :=0;
l_data               VARCHAR2(2000);
item_rec             GMIGAPI.item_rec_typ;
l_ic_item_mst_row    ic_item_mst%ROWTYPE;
l_ic_item_cpg_row    ic_item_cpg%ROWTYPE;
l_p_dir              VARCHAR2(50);
l_output_file        VARCHAR2(20);
l_outfile_handle     UTL_FILE.FILE_TYPE;
l_input_file         VARCHAR2(20);
l_infile_handle      UTL_FILE.FILE_TYPE;
l_line               VARCHAR2(800);
l_delimiter          VARCHAR(1);
l_log_dir            VARCHAR2(50);
l_log_name           VARCHAR2(20)  :='wrapper';
l_log_handle         UTL_FILE.FILE_TYPE;
l_global_file        VARCHAR2(20);

l_session_id         VARCHAR2(10);

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

/*  Loop thru flat file and call Inventory Quantities API */

/*  dbms_output.put_line('Start Processing'); */
UTL_FILE.PUT_LINE(l_log_handle, 'Process Started at '
|| to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));

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

  item_rec.item_no         :=Get_Field(l_line,l_delimiter,1);
  item_rec.item_desc1      :=Get_Field(l_line,l_delimiter,2);
  item_rec.item_desc2      :=Get_Field(l_line,l_delimiter,3);
  item_rec.alt_itema       :=Get_Field(l_line,l_delimiter,4);
  item_rec.alt_itemb       :=Get_Field(l_line,l_delimiter,5);
  item_rec.item_um         :=Get_Field(l_line,l_delimiter,6);
  item_rec.dualum_ind      :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,7),' '),' ','0'));
  item_rec.item_um2        :=Get_Field(l_line,l_delimiter,8);
  item_rec.deviation_lo    :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,9),' '),' ','0'));
  item_rec.deviation_hi    :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,10),' '),' ','0'));
  item_rec.level_code      :=TO_NUMBER(Get_Field(l_line,l_delimiter,11));
  item_rec.lot_ctl         :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,12),' '),' ','0'));
  item_rec.lot_indivisible :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,13),' '),' ','0'));
  item_rec.sublot_ctl      :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,14),' '),' ','0'));
  item_rec.loct_ctl        :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,15),' '),' ','0'));
  item_rec.noninv_ind      :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,16),' '),' ','0'));
  item_rec.match_type      :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,17),' '),' ','0'));
  item_rec.inactive_ind    :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,18),' '),' ','0'));
  item_rec.inv_type        :=Get_Field(l_line,l_delimiter,19);
  item_rec.shelf_life      :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,20),' '),' ','0'));
  item_rec.retest_interval :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,21),' '),' ','0'));
  item_rec.item_abccode    :=Get_Field(l_line,l_delimiter,22);
  item_rec.gl_class        :=Get_Field(l_line,l_delimiter,23);
  item_rec.inv_class       :=Get_Field(l_line,l_delimiter,24);
  item_rec.sales_class     :=Get_Field(l_line,l_delimiter,25);
  item_rec.ship_class      :=Get_Field(l_line,l_delimiter,26);
  item_rec.frt_class       :=Get_Field(l_line,l_delimiter,27);
  item_rec.price_class     :=Get_Field(l_line,l_delimiter,28);
  item_rec.storage_class   :=Get_Field(l_line,l_delimiter,29);
  item_rec.purch_class     :=Get_Field(l_line,l_delimiter,30);
  item_rec.tax_class       :=Get_Field(l_line,l_delimiter,31);
  item_rec.customs_class   :=Get_Field(l_line,l_delimiter,32);
  item_rec.alloc_class     :=Get_Field(l_line,l_delimiter,33);
  item_rec.planning_class  :=Get_Field(l_line,l_delimiter,34);
  item_rec.itemcost_class  :=Get_Field(l_line,l_delimiter,35);
  item_rec.cost_mthd_code  :=Get_Field(l_line,l_delimiter,36);
  item_rec.upc_code        :=Get_Field(l_line,l_delimiter,37);
  item_rec.grade_ctl       :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,38),' '),' ','0'));
  item_rec.status_ctl      :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,39),' '),' ','0'));
  item_rec.qc_grade        :=Get_Field(l_line,l_delimiter,40);
/* B965832(1) Check for spaces */
  IF item_rec.qc_grade = ' '
  THEN
  item_rec.qc_grade := '';
  END IF;
/* B965832(1) End */
  item_rec.lot_status      :=Get_Field(l_line,l_delimiter,41);
/* B965832(1) Check for spaces */
  IF item_rec.lot_status = ' '
  THEN
  item_rec.lot_status :='';
  END IF;
/* B965832(1) End */
  item_rec.bulk_id         :=TO_NUMBER(Get_Field(l_line,l_delimiter,42));
  item_rec.pkg_id          :=TO_NUMBER(Get_Field(l_line,l_delimiter,43));
  item_rec.qcitem_no       :=Get_Field(l_line,l_delimiter,44);
  item_rec.qchold_res_code :=Get_Field(l_line,l_delimiter,45);
  item_rec.expaction_code  :=Get_Field(l_line,l_delimiter,46);
  item_rec.fill_qty        :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,47),' '),' ','0'));
  item_rec.fill_um         :=Get_Field(l_line,l_delimiter,48);
  item_rec.expaction_interval  :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,49),' '),' ','0'));
  item_rec.phantom_type    :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,50),' '),' ','0'));
  item_rec.whse_item_no    :=Get_Field(l_line,l_delimiter,51);
  item_rec.experimental_ind:=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,52),' '),' ','0'));
  IF (Get_Field(l_line,l_line,53) IS NULL)
  THEN
    item_rec.exported_date :=TO_DATE('02011970','DDMMYYYY');
  ELSE
    item_rec.exported_date :=TO_DATE(
			     Get_Field(l_line,l_delimiter,53),'DDMMYYYY');
  END IF;
  item_rec.seq_dpnd_class  :=Get_Field(l_line,l_delimiter,54);
  item_rec.commodity_code  :=Get_Field(l_line,l_delimiter,55);
  item_rec.ic_matr_days    :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,56),' '),' ','0'));
  item_rec.ic_hold_days :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,57),' '),' ','0'));
  IF ((Get_Field(l_line,l_delimiter,58)) IS NULL)
  THEN
    item_rec.user_name     :='OPM';
  ELSE
    item_rec.user_name     :=Get_Field(l_line,l_delimiter,58);
  END IF;
  item_rec.attribute1      :=Get_Field(l_line,l_delimiter,59);
  item_rec.attribute2      :=Get_Field(l_line,l_delimiter,60);
  item_rec.attribute3      :=Get_Field(l_line,l_delimiter,61);
  item_rec.attribute4      :=Get_Field(l_line,l_delimiter,62);
  item_rec.attribute5      :=Get_Field(l_line,l_delimiter,63);
  item_rec.attribute6      :=Get_Field(l_line,l_delimiter,64);
  item_rec.attribute7      :=Get_Field(l_line,l_delimiter,65);
  item_rec.attribute8      :=Get_Field(l_line,l_delimiter,66);
  item_rec.attribute9      :=Get_Field(l_line,l_delimiter,67);
  item_rec.attribute10     :=Get_Field(l_line,l_delimiter,68);
  item_rec.attribute11     :=Get_Field(l_line,l_delimiter,69);
  item_rec.attribute12     :=Get_Field(l_line,l_delimiter,70);
  item_rec.attribute13     :=Get_Field(l_line,l_delimiter,71);
  item_rec.attribute14     :=Get_Field(l_line,l_delimiter,72);
  item_rec.attribute15     :=Get_Field(l_line,l_delimiter,73);
  item_rec.attribute16     :=Get_Field(l_line,l_delimiter,74);
  item_rec.attribute17     :=Get_Field(l_line,l_delimiter,75);
  item_rec.attribute18     :=Get_Field(l_line,l_delimiter,76);
  item_rec.attribute19     :=Get_Field(l_line,l_delimiter,77);
  item_rec.attribute20     :=Get_Field(l_line,l_delimiter,78);
  item_rec.attribute21     :=Get_Field(l_line,l_delimiter,79);
  item_rec.attribute22     :=Get_Field(l_line,l_delimiter,80);
  item_rec.attribute23     :=Get_Field(l_line,l_delimiter,81);
  item_rec.attribute24     :=Get_Field(l_line,l_delimiter,82);
  item_rec.attribute25     :=Get_Field(l_line,l_delimiter,83);
  item_rec.attribute26     :=Get_Field(l_line,l_delimiter,84);
  item_rec.attribute27     :=Get_Field(l_line,l_delimiter,85);
  item_rec.attribute28     :=Get_Field(l_line,l_delimiter,86);
  item_rec.attribute29     :=Get_Field(l_line,l_delimiter,87);
  item_rec.attribute30     :=Get_Field(l_line,l_delimiter,88);
  item_rec.attribute_category :=Get_Field(l_line,l_delimiter,89);
  item_rec.ont_pricing_qty_source :=
  TO_NUMBER(TRANSLATE(NVL(Get_Field(l_line,l_delimiter,90),' '),' ','0'));
  -- TKW 9/11/2003 B2378017
  item_rec.gl_business_class  :=Get_Field(l_line,l_delimiter,91);
  item_rec.gl_prod_line  :=Get_Field(l_line,l_delimiter,92);
  item_rec.sub_standard_class :=Get_Field(l_line,l_delimiter,93);
  item_rec.tech_class  :=Get_Field(l_line,l_delimiter,94);



UTL_FILE.PUT_LINE(l_log_handle,'item_no        = '||item_rec.item_no);
UTL_FILE.PUT_LINE(l_log_handle,'item_desc1     = '||item_rec.item_desc1);
UTL_FILE.PUT_LINE(l_log_handle,'item_desc2     = '||item_rec.item_desc2);
UTL_FILE.PUT_LINE(l_log_handle,'alt_itema      = '||item_rec.alt_itema);
UTL_FILE.PUT_LINE(l_log_handle,'alt_itemb      = '||item_rec.alt_itemb);
UTL_FILE.PUT_LINE(l_log_handle,'item_um        = '||item_rec.item_um);
UTL_FILE.PUT_LINE(l_log_handle,'dualum_ind     = '||item_rec.dualum_ind);
UTL_FILE.PUT_LINE(l_log_handle,'item_um2       = '||item_rec.item_um2);
UTL_FILE.PUT_LINE(l_log_handle,'deviation_lo   = '||item_rec.deviation_lo);
UTL_FILE.PUT_LINE(l_log_handle,'deviation_hi   = '||item_rec.deviation_hi);
UTL_FILE.PUT_LINE(l_log_handle,'level_code     = '||item_rec.level_code);
UTL_FILE.PUT_LINE(l_log_handle,'lot_ctl        = '||item_rec.lot_ctl);
UTL_FILE.PUT_LINE(l_log_handle,'lot_indivisible= '||item_rec.lot_indivisible);
UTL_FILE.PUT_LINE(l_log_handle,'sublot_ctl     = '||item_rec.sublot_ctl);
UTL_FILE.PUT_LINE(l_log_handle,'loct_ctl       = '||item_rec.loct_ctl);
UTL_FILE.PUT_LINE(l_log_handle,'noninv_ind     = '||item_rec.noninv_ind);
UTL_FILE.PUT_LINE(l_log_handle,'match_type     = '||item_rec.match_type);
UTL_FILE.PUT_LINE(l_log_handle,'inactive_ind   = '||item_rec.inactive_ind);
UTL_FILE.PUT_LINE(l_log_handle,'inv_type       = '||item_rec.inv_type);
UTL_FILE.PUT_LINE(l_log_handle,'shelf_life     = '||item_rec.shelf_life);
UTL_FILE.PUT_LINE(l_log_handle,'retest_interval= '||item_rec.retest_interval);
UTL_FILE.PUT_LINE(l_log_handle,'item_abccode   = '||item_rec.item_abccode);
UTL_FILE.PUT_LINE(l_log_handle,'gl_class       = '||item_rec.gl_class);
UTL_FILE.PUT_LINE(l_log_handle,'inv_class      = '||item_rec.inv_class);
UTL_FILE.PUT_LINE(l_log_handle,'sales_class    = '||item_rec.sales_class);
UTL_FILE.PUT_LINE(l_log_handle,'ship_class     = '||item_rec.ship_class);
UTL_FILE.PUT_LINE(l_log_handle,'frt_class      = '||item_rec.frt_class);
UTL_FILE.PUT_LINE(l_log_handle,'price_class    = '||item_rec.price_class);
UTL_FILE.PUT_LINE(l_log_handle,'storage_class  = '||item_rec.storage_class);
UTL_FILE.PUT_LINE(l_log_handle,'purch_class    = '||item_rec.purch_class);
UTL_FILE.PUT_LINE(l_log_handle,'tax_class      = '||item_rec.tax_class);
UTL_FILE.PUT_LINE(l_log_handle,'customs_class  = '||item_rec.customs_class);
UTL_FILE.PUT_LINE(l_log_handle,'alloc_class    = '||item_rec.alloc_class);
UTL_FILE.PUT_LINE(l_log_handle,'planning_class = '||item_rec.planning_class);
UTL_FILE.PUT_LINE(l_log_handle,'itemcost_class = '||item_rec.itemcost_class);
UTL_FILE.PUT_LINE(l_log_handle,'cost_mthd_code = '||item_rec.cost_mthd_code);
UTL_FILE.PUT_LINE(l_log_handle,'upc_code       = '||item_rec.upc_code);
UTL_FILE.PUT_LINE(l_log_handle,'grade_ctl      = '||item_rec.grade_ctl);
UTL_FILE.PUT_LINE(l_log_handle,'status_ctl     = '||item_rec.status_ctl);
UTL_FILE.PUT_LINE(l_log_handle,'qc_grade       = '||item_rec.qc_grade);
UTL_FILE.PUT_LINE(l_log_handle,'lot_status     = '||item_rec.lot_status);
UTL_FILE.PUT_LINE(l_log_handle,'bulk_id        = '||item_rec.bulk_id);
UTL_FILE.PUT_LINE(l_log_handle,'pkg_id         = '||item_rec.pkg_id);
UTL_FILE.PUT_LINE(l_log_handle,'qcitem_no      = '||item_rec.qcitem_no);
UTL_FILE.PUT_LINE(l_log_handle,'qchold_res_code= '||item_rec.qchold_res_code);
UTL_FILE.PUT_LINE(l_log_handle,'expaction_code = '||item_rec.expaction_code);
UTL_FILE.PUT_LINE(l_log_handle,'fill_qty       = '||item_rec.fill_qty);
UTL_FILE.PUT_LINE(l_log_handle,'fill_um        = '||item_rec.fill_um);
UTL_FILE.PUT_LINE(
  l_log_handle,'expaction_interval = '||item_rec.expaction_interval);
UTL_FILE.PUT_LINE(l_log_handle,'phantom_type   = '||item_rec.phantom_type);
UTL_FILE.PUT_LINE(l_log_handle,'whse_item_no   = '||item_rec.whse_item_no);
UTL_FILE.PUT_LINE(
  l_log_handle,'experimental_ind = '||item_rec.experimental_ind);
UTL_FILE.PUT_LINE(l_log_handle,'exported_date  = '||item_rec.exported_date);
UTL_FILE.PUT_LINE(l_log_handle,'seq_dpnd_class = '||item_rec.seq_dpnd_class);
UTL_FILE.PUT_LINE(l_log_handle,'commodity_code = '||item_rec.commodity_code);
UTL_FILE.PUT_LINE(l_log_handle,'ic_matr_days   = '||item_rec.ic_matr_days);
UTL_FILE.PUT_LINE(l_log_handle,'ic_hold_days   = '||item_rec.ic_hold_days);
UTL_FILE.PUT_LINE(l_log_handle,'user_name      = '||item_rec.user_name);
UTL_FILE.PUT_LINE(l_log_handle,'Attribute1        = '||                                                         item_rec.attribute1 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute2        = '||                                                         item_rec.attribute2 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute3        = '||                                                         item_rec.attribute3 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute4        = '||                                                         item_rec.attribute4 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute5        = '||                                                         item_rec.attribute5 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute6        = '||                                                         item_rec.attribute6 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute7        = '||                                                         item_rec.attribute7 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute8        = '||                                                         item_rec.attribute8 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute9        = '||                                                         item_rec.attribute9 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute10        = '||                                                         item_rec.attribute10 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute11        = '||                                                         item_rec.attribute11 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute12        = '||                                                         item_rec.attribute12 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute13        = '||                                                         item_rec.attribute13 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute14        = '||                                                         item_rec.attribute14 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute15        = '||                                                         item_rec.attribute15 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute16        = '||                                                         item_rec.attribute16 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute17        = '||                                                         item_rec.attribute17 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute18        = '||                                                         item_rec.attribute18 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute19        = '||                                                         item_rec.attribute19 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute20        = '||                                                         item_rec.attribute20 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute21        = '||                                                         item_rec.attribute21 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute22        = '||                                                         item_rec.attribute22 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute23        = '||                                                         item_rec.attribute23 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute24        = '||                                                         item_rec.attribute24 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute25        = '||                                                         item_rec.attribute25 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute26        = '||                                                         item_rec.attribute26 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute27        = '||                                                         item_rec.attribute27 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute28        = '||                                                         item_rec.attribute28 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute29        = '||                                                         item_rec.attribute29 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute30        = '||                                                         item_rec.attribute30 );
UTL_FILE.PUT_LINE(l_log_handle,'Attribute_Category = '||                                                         item_rec.attribute_category );
UTL_FILE.PUT_LINE(l_log_handle,'ont_pricing_qty_source = '||                                                     item_rec.ont_pricing_qty_source );
-- TKW 9/11/2003 B2378017
UTL_FILE.PUT_LINE(l_log_handle,'GL Business Class        = '||                                                         item_rec.gl_business_class);
UTL_FILE.PUT_LINE(l_log_handle,'GL Product Line        = '||                                                         item_rec.gl_prod_line);
UTL_FILE.PUT_LINE(l_log_handle,'Substandard Item Class        = '||                                                         item_rec.sub_standard_class);
UTL_FILE.PUT_LINE(l_log_handle,'Tech Class and Subclass        = '||                                                         item_rec.tech_class);

GMIPAPI.Create_Item
( p_api_version    => 3.0
, p_init_msg_list  => FND_API.G_TRUE
, p_commit         => FND_API.G_TRUE
, p_validation_level => FND_API.G_VALID_LEVEL_FULL
, p_item_rec       =>item_rec
, x_ic_item_mst_row => l_ic_item_mst_row
, x_ic_item_cpg_row => l_ic_item_cpg_row
, x_return_status  =>l_status
, x_msg_count      =>l_count
, x_msg_data       =>l_data
);

/* Bug 2513463 - Avoid having Default value of S overwriting errors incurred */
/* Added the equals sign to the condition so the errors are returned properly*/

IF l_count >= 0
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
  || to_char(SYSDATE,'DD-MON-YY HH24:MI:SS'));
/*  Check if any messages generated. If so then decode and */
/*  output to error message flat file */

UTL_FILE.FCLOSE_ALL;

RETURN l_return_status;

EXCEPTION
WHEN UTL_FILE.INVALID_OPERATION THEN
   /*  dbms_output.put_line('Invalid Operation For '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_PATH THEN
   /*  dbms_output.put_line('Invalid Path For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_MODE THEN
   /*  dbms_output.put_line('Invalid Mode For      '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
   /* dbms_output.put_line('Invalid File Handle   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.WRITE_ERROR THEN
   /*  dbms_output.put_line('Invalid Write Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.READ_ERROR THEN
   /*  dbms_output.put_line('Invalid Read  Error   '|| l_global_file); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN UTL_FILE.INTERNAL_ERROR THEN
   /*  dbms_output.put_line('Internal Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

WHEN OTHERS THEN
   /*  dbms_output.put_line('Other Error'); */
   UTL_FILE.FCLOSE_ALL;
   RETURN l_return_status;

END Create_Item;

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

END GMI_ITEM_WRP;

/
