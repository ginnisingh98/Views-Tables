--------------------------------------------------------
--  DDL for Package Body AR_GTA_TXT_OPERATOR_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_GTA_TXT_OPERATOR_PROC" AS
--$Header: ARGRIETB.pls 120.0.12010000.3 2010/01/19 08:31:47 choli noship $
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     ARRIETB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package consists of server procedures, which are used to     |
--|     export customers, items and invoice to flat files respectively,   |
--|     also there is a procedure to import data from GT through flat     |
--|     file                                                              |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Read_GT_Line                                           |
--|      PROCEDURE Put_Line                                               |
--|      PROCEDURE Put_Log                                                |
--|      PROCEDURE Clear_Imp_Temp_Table                                   |
--|      PROCEDURE Export_Invoice                                         |
--|      PROCEDURE Export_Invoices                                        |
--|      PROCEDURE Check_Batch_Number                                     |
--|      PROCEDURE Export_Invoices_From_Conc                              |
--|      PROCEDURE Export_Invoices_From_Workbench                         |
--|      FUNCTION  Check_Header                                           |
--|      FUNCTION  Check_Line_Length                                      |
--|      PROCEDURE Export_Customers                                       |
--|      FUNCTION  Check_Item_Length                                      |
--|      PROCEDURE Export_To_Flat_File                                    |
--|      PROCEDURE Export_Items                                           |
--|                                                                       |
--|                                                                       |
--| HISTORY                                                               |
--|      05/12/2005     Jogen Hu          Created                         |
--|      05/17/2005     Jim Zheng         Add procedure  Export_Customers |
--|      05/17/2005     Donghai Wang      Add procedure  Export_Items     |
--|      07/28/005      Jim Zheng         Update Customer Export          |
--|      09/28/2005     Jogen Hu          Change procedure Export_invoices|
--|                         Export_Invoices_From_Conc and import_invoices |
--|      09/29/2005     Jim.Zheng         Update Customer Export, give up |
--|                                       the tax_payer_id export         |
--|      10/10/2005     Jim.Zheng         Change log level of Customer_ex |
--|                                       port                            |
--|      13/10/2005     Jogen Hu          Change due to message change    |
--|                                                                       |
--|      14/10/2005     Jim.Zheng         Add org_id condition in         |
--|                                       export_customer                 |
--|                                       when select custoemr site id    |
--|     18/10/2005      Donghai Wang      Update procedure                |
--|                                       'Export_To_Flat_File' in order  |
--|                                       not to export tax rate any      |
--|                                       longer due to ebtax enabled     |
--|      20/10/2005     Jogen Hu          Change invoice description check|
--|      21/10/2005     Jogen Hu          Add debug log message           |
--|      22/10/2005     Jogen Hu          update batch number source for  |
--|                                       export invoices from workbench  |
--|      08/11/2005     jim Zheng         update export_cusomters. Add '~~'
--|                                       because the tax_payer_id should |
--|                                       be leave blank '~~~~'           |
--|      09/11/2005     Jogen Hu          Update GTA invoice to add GT info
--|                                       in import_invoices              |
--|      10/11/2005     Jim Zheng         Update customer export cause by |
--|                                       Bank account mask profile change|
--|      11/11/2005     Jim Zheng         Update customer export because  |
--|                                       the bank account mask profile   |
--|                                       value change to NO MASK         |
--|      14/11/2005     Jim Zheng         Update the customer export,     |
--|                                       Delete the blank when the column|
--|                                       is null.                        |
--|      16/11/2005     Jogen Hu          Update invoices export because  |
--|                                       the bank account mask profile   |
--|                                       value change to NO MASK         |
--|      16/11/2005     Jim Zheng         Update Export_customers for     |
--|                                       add message output for bank     |
--|                                       account mask                    |
--|      16/11/2005     Jogen Hu          Update invoices import to change|
--|                                       the import identifier           |
--|                                       verification method             |
--|      30/11/2005     Jogen Hu          Add some protection due to XML  |
--|                                       function                        |
--|      1/12/2005     Jogen Hu           Change check_header: add        |
--|                                       condition when check CM         |
--|                                       CM decription is NULL           |
--|      2/12/2005     Jogen Hu           Modify procedure Read_GT_Line   |
--|                                       Add code protection for file EOF|
--|                                       replace AR_NO_DATA_FOUND with  |
--|                                       AR_GTA_NO_DATA_FOUND           |
--|      9/12/2005     Jogen Hu           Modify procedure import_invoices|
--|                                       exchange the comment line and   |
--|                                       indentifier line due to different
--|                                       golden Tax system version       |
--|     21/12/2005     Jim Zheng          Update code because bank account|
--|                                       uptake. Procedure export_customer
--|     26/12/2005     Jim Zheng          fix performance issue in percedure
--|                                       export_customers.               |
--|     13/01/2006     Jim Zheng          fix a variable issue in procedure
--|                                       export customer when get band   |
--|                                       account.                        |
--|     16/01/2006     Jim Zheng          update code by message change and
--|                                       some error format of output file|
--|     07/02/2006     Jim Zheng          Procedure export_customers. Add |
--|                                       variable init for bank account  |
--|                                       export.                         |
--|     06/03/2006     Donghai Wang       update procedures               |
--|                                       'Check_Item_Length' and         |
--|                                        'Export_Items' for adding fnd  |
--|                                         log                           |
--|     15/03/2006     Jogen Hu            erase the log by fnd_file.log  |
--|     21/03/2006     Jogen Hu            Change data range from trunc   |
--|                                        parameters to DB columns by    |
--|                                        bug 5107043                    |
--|    06/04/2006      Donghai Wang        Update procedures              |
--|                                  Check_Item_Lenth,Export_To_Flat_File |
--|                                     and Export_Items to remove tax_rate|
--|                                        from export to fix bug 5138356  |
--|    22/06/2006      Jogen Hu      update export_invoices to increase the|
--|                                     length of l_str to fix bug 5335265,|
--|                                     add '-' for batch number to fix bug|
--|                                     5351578 and change import process  |
--|    20/09/2006      Jogen Hu      update Import_invoices to             |
--|                                  Format date to XSD Date formate       |
--|                                  for Bug 5521629                       |
--|    02/01/2007      Subba      Updated 'Export_Invoices_From_Conc'      |
--|                               procedure to accept 'invoice_type'       |
--|                               parameter and added logic to fetch the   |
--|                               invoices based on invoice_type           |
--|    09/12/2008      Lv Xiao    Modified for bug#7626503                 |
--|                               Add validation of description of Special |
--|                               and Recycle VAT invoice, fixed prefix    |
--|                               Add validation of unique description of  |
--|                               Special and Recycle VAT invoice          |
--|    09/18/2008      Lv Xiao    Modified for bug#7644803                 |
--|                               Add two more parameters while description|
--|                               of invoices duplicates with each other   |
--|                               and set them to the error message        |
--|    12/25/2008      Lv Xiao    Modified for bug#7644876                 |
--|                               Enlarge the string buffer of parameters: |
--|                               lv_crmemo_prefix_msg           VARCHAR2(240);  |
--|                               lv_trx_crmemo_prefix_msg       VARCHAR2(1000); |
--|                               lv_trx_crmemo_notification_num VARCHAR2(1000); |
--|    12/26/2008   Yao Zhang   Fix bug 7670310 Add description check logic|
--|                             for common Credit Memo   |
--|    09/01/2009   Yao Zhang Fix bug 7673309  THE GTA INVOICE EXPORT: The same error
--|                           message is duplicated.                      |
--|    17/03/2009   Yao Zhang Fix bug 8230998 GOLDEN TAX CUSTOMER EXPORT, |
--|                 DOES NOT PULL ALL CUSTOMERS when parameters are null. |
--|    18/03/2009  Yao Zhang   Fix bug 7812065 When Inventory Item DFF use|
--|                              Attribute16 to Attribute30 to define     |
--                               tsegment ax denomination and item model, |
--|                              the DFF values can not be retrieved.     |
--|   19/Mar/2009    Yao Zhang Fix bug 8339490 RECEIVABLE TRANSFER TO GTA,|
--|                  NOT TRANSFER CHINESE NAME OF UOM
--|   29/APR/2009    Yao Zhang Fix bug 7670710 CUSTOMER EXPORT MISSING PHONE
--|                                NUMBER AND BANK INFO                    |
--|   14-May-2009   Yao Zhang fix bug8257757 RE-IMPORT TO GTA,THE VIEW OUT |
--|                 REPORT INVOICE DATE ISSUE.                             |
--|   16-Jun-2009   Allen Yang changed for bug 8605196 to support          |
--|                 exporting customer and bank info in Chinese.           |
--|   06-Aug-2009   Allen Yang modified procedure Export_Customers for bug |
--|                 8765298 and 8766256
--|   09-Sep-2009   Yao Zhang fix bug#8882568 CONCURRENCY CONTROL FOR
--|                 EXPORT AND CONSOLIDATION PROGRAM                       |
--|   28-Sep-2009   Allen Yang modified for bug 8981199                    |
--+======================================================================*/

--TYPE COLUMN_VALUES IS TABLE OF VARCHAR2(200);
TYPE t_invoice_export_output IS TABLE OF VARCHAR2(5000);
TYPE c_trx_header_id_type IS REF CURSOR RETURN ar_gta_trx_headers%ROWTYPE;

--===================
-- CONSTANTS
--===================
G_MODULE_PREFIX CONSTANT VARCHAR2(60):='ar.plsql.AR_GTA_TXT_OPERATOR_PROC.';

G_EXPORT_SUCC                 CONSTANT PLS_INTEGER:=0;
G_EXPORT_EXCEED_ERROR         CONSTANT PLS_INTEGER:=1;
G_EXPORT_TAXPAYERID_ERROR     CONSTANT PLS_INTEGER:=2;
G_EXPORT_CRMEMO_MISSING_ERROR CONSTANT PLS_INTEGER:=3;
G_EXPORT_MISSING              CONSTANT PLS_INTEGER:=4;

--add by Lv Xiao on 9-DEC-2008, begin
------------------------------------------------------------
G_EXPORT_MISSING_PREFIX_ERROR CONSTANT PLS_INTEGER:=5;
G_EXPORT_CRMEMO_DUP_ERROR     CONSTANT PLS_INTEGER:=6;
------------------------------------------------------------
--add by Lv Xiao on 9-DEC-2008, end

G_DEBUG_LEVEL                 CONSTANT PLS_INTEGER:=fnd_log.LEVEL_EXCEPTION;

G_import_error_prefix CONSTANT VARCHAR2(240):=
'<?xml version="1.0"?>
<ImportReport>
  <ReportFailed>Y</ReportFailed>
  <ReportFailedMsg>';

G_import_error_suffix CONSTANT VARCHAR2(100):='</ReportFailedMsg>
</ImportReport>';

g_export_delimiter     VARCHAR2(2):='~~';
g_comment_delimiter    VARCHAR2(2):='//';

gv_check_dup_flag      VARCHAR2(20):='FALSE';

gv_dup_title_flag      VARCHAR2(20):='FALSE';

gv_desc_duplicat_flag  VARCHAR2(20) := 'FALSE';

gv_output_dup_err_flag VARCHAR2(20):='FALSE';

gv_prefix_missing_flag VARCHAR(10):= 'FALSE';

--==========================================================================
--  PROCEDURE NAME:
--
--    Put_Line                     Public
--
--  DESCRIPTION:
--
--      This procedure write data to log file.
--
--  PARAMETERS:
--      In: p_str         VARCHAR2
--
--     Out:
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--      05/12/05       Jogen Hu      Created
--===========================================================================
PROCEDURE Put_Line
( p_str                  IN        VARCHAR2
)
IS
BEGIN
     FND_FILE.Put_Line(FND_FILE.Output,p_str);

END Put_Line;

--==========================================================================
--  PROCEDURE NAME:
--
--    Put_Log                     Public
--
--  DESCRIPTION:
--
--      This procedure write data to log file.
--
--  PARAMETERS:
--      In:  p_str         VARCHAR2
--
--     Out:
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--      05/12/05       Jogen Hu      Created
--===========================================================================
PROCEDURE Put_Log
( p_str                  IN  VARCHAR2
)
IS
BEGIN
     --FND_FILE.Put_Line(FND_FILE.Log,p_str);
  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
     fnd_log.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT
                   ,MODULE => G_MODULE_PREFIX||'.debug'
                   ,MESSAGE => p_str);
  END IF;
END Put_Log;

--==========================================================================
--  PROCEDURE NAME:
--
--    Read_GT_Line                   Private
--
--  DESCRIPTION:
--
--      This procedure read a single line data from flat file to
--      seperate columns
--
--      flat file format:
--      the first line is a identity line
--      the second line is description line which format is
--      number of invoices~~start date~~end date
--      for third line, there will be a invoice header and following
--      lines are invoices lines belong to the header.Then another
--      invoice header and lines..
--         header:                               Line:
--       --------------------------      --------------------------------------
--  col1  -  cancel flag                     discount flag(0:none,1:discount line)
--  col2  -  list flag                       item name
--  col3  -  invoice type code               item model
--  col4  -  invoice class coce              unit of measure
--  col5  -  invoice number                  quantity
--  col6  -  detail lines number             amount without tax
--  col7  -  invoice date(RRRRMMDD)          tax rate
--  col8  -  tax month                       tax amount
--  col9  -  invoice doc number(GTA number)  price
--  col10 - amount without tax              price flag(0: without tax,1:with tax)
--  col11 - tax rate                        item tax denomination
--  col12 - tax amount
--  col13 - customer name
--  col14 - customer taxpayer id
--  col15 - customer address phone
--  col16 - customer bank name account
--  col17 - supplier name
--  col18 - supplier taxpayer id
--  col19 - supplier address phone
--  col20 - supplier bank name account
--  col21 - comments
--  col22 - issuer
--  col23 - reviewer
--  col24 - payee
--  col25 -
--
--  PARAMETERS:
--      In Out:   p_line_seq      Read line number
--
--         Out:    x_values       Which contain all columns value
--                 x_eof          Whether it's End of File
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--      05/12/05       Jogen Hu      Created
--===========================================================================
PROCEDURE Read_GT_Line
( x_line_seq             IN OUT NOCOPY NUMBER
, x_values                  OUT NOCOPY COLUMN_VALUES
, x_eof                     OUT NOCOPY BOOLEAN
)
IS
l_procedure_name   VARCHAR2(30)    :='read_GT_Line';
l_dbg_level        NUMBER          :=FND_LOG.G_Current_Runtime_Level;
l_proc_level       NUMBER          :=FND_LOG.Level_Procedure;

BEGIN
   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

   x_values:=COLUMN_VALUES();
   IF x_line_seq IS NULL
   THEN
      x_line_seq:=1;
   END IF;

   --get exact line number
   SELECT MIN(import_seq)
     INTO x_line_seq
     FROM AR_GTA_TRXIMP_TMP
    WHERE import_seq>=x_line_seq;

   --get a valid line and insert into out parameter.
   LOOP
       BEGIN

         --clear the out table
         x_values.DELETE;
         x_values.EXTEND(25);

         SELECT col1
              , col2
              , col3
              , col4
              , col5
              , col6
              , col7
              , col8
              , col9
              , col10
              , col11
              , col12
              , col13
              , col14
              , col15
              , col16
              , col17
              , col18
              , col19
              , col20
              , col21
              , col22
              , col23
              , col24
              , col25
           INTO x_values(1)
              , x_values(2)
              , x_values(3)
              , x_values(4)
              , x_values(5)
              , x_values(6)
              , x_values(7)
              , x_values(8)
              , x_values(9)
              , x_values(10)
              , x_values(11)
              , x_values(12)
              , x_values(13)
              , x_values(14)
              , x_values(15)
              , x_values(16)
              , x_values(17)
              , x_values(18)
              , x_values(19)
              , x_values(20)
              , x_values(21)
              , x_values(22)
              , x_values(23)
              , x_values(24)
              , x_values(25)
           FROM AR_GTA_TRXIMP_TMP
          WHERE import_seq=x_line_seq;

         --delete the line from temporary table
         --DELETE AR_GTA_TRXIMP_TMP WHERE import_seq=x_line_seq;

         --set the line number read next time
         x_line_seq:=x_line_seq+1;

         --filter comments line if there is still comment line in the table
         --then we will go to next line, otherwise we already get a valid line and can exit
         IF x_values(1) IS NOT NULL
         THEN
             IF instr(x_values(1),g_comment_delimiter)<1
             THEN
                EXIT;
             END IF;
         END IF;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
              X_EOF:=TRUE;
              EXIT;

         WHEN OTHERS THEN
            IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
            THEN
              FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                            , G_MODULE_PREFIX || l_procedure_name
                              || '.OTHER_EXCEPTION'
                            , SQLCODE||SQLERRM);
            END IF;
            RAISE;
       END;
   END LOOP;

  IF trim(x_values(1)) IS NULL
  THEN
     X_EOF:=TRUE;
  END IF;

  --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.End'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level )
EXCEPTION
 WHEN NO_DATA_FOUND THEN
      X_EOF:=TRUE;

 WHEN OTHERS THEN
    IF(l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX || l_procedure_name||'.OTHER_EXCEPTION'
                    , SQLCODE||SQLERRM);
    END IF;
    RAISE;

END Read_GT_Line;

--==========================================================================
--  PROCEDURE NAME:
--
--    Clear_Imp_Temp_Table                Private
--
--  DESCRIPTION:
--
--      This procedure clear the data imported from flat file
--      in temporary table
--
--  PARAMETERS:
--      In:  None
--     Out:  None
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--      05/12/05       Jogen Hu      Created
--===========================================================================
PROCEDURE Clear_Imp_Temp_Table
IS
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
     DELETE AR_GTA_TRXIMP_TMP;
     COMMIT;

END Clear_Imp_Temp_Table;

--==========================================================================
--  PROCEDURE NAME:
--
--    Import_Invoices                     Public
--
--  DESCRIPTION:
--
--      This procedure import VAT invoices from flat file to GTA
--      Because SQL*Loader will import flat file to temporary table
--      AR_GTA_TRXIMP_TMP and GTA_TRX_NUMBER  is a unique column
--      in GTA, so no parameter is needed here
--
--  PARAMETERS:
--      In:  None
--     Out:  None
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--      05/12/05       Jogen Hu      Created
--      09/28/05       Jogen Hu      Add the part to copy fp_tax_reg_number,
--                      tp_tax_reg_number, legal_entity_id to GT line
--      14-May-2009    Yao Zhang  Fix bug#8257757
--===========================================================================
PROCEDURE Import_Invoices
IS
l_procedure_name  VARCHAR2(30):='Import_invoices';
L_HEADER_ID       AR_Gta_Trx_Headers_All.Gta_Trx_Header_Id%TYPE;
l_line_seq        NUMBER;
l_values          COLUMN_VALUES:=COLUMN_VALUES(NULL);
l_EOF             BOOLEAN;
l_num_of_Invoices NUMBER;
l_num_of_lines    NUMBER;
l_GTA_Invoice_num AR_Gta_Trx_Headers_All.Gta_Trx_Number%TYPE;
l_org_id          NUMBER;
l_trx_rec         AR_GTA_TRX_UTIL.TRX_REC_TYPE;
l_trx_header_rec  AR_GTA_TRX_UTIL.TRX_header_rec_TYPE;
l_trx_line_rec    AR_GTA_TRX_UTIL.TRX_line_rec_TYPE;
l_trx_line_tbl    AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE
                  :=AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();
l_error_msg       VARCHAR2(2000);
l_fix_field       VARCHAR2(100);
l_str             VARCHAR2(100);
l_failed          BOOLEAN;
l_line_num        NUMBER;
l_status          AR_Gta_Trx_Headers_All.Status%TYPE;
l_new_status      AR_Gta_Trx_Headers_All.Status%TYPE;
l_Customer_Name   AR_Gta_Trx_Headers_All.Bill_To_Customer_Name%TYPE;
l_TP_TAX_REG_NUMBER  AR_Gta_Trx_Headers_All.TP_TAX_REGISTRATION_NUMBER%TYPE;
l_Invoice_Num     AR_Gta_Trx_Headers_All.Gt_Invoice_Number%TYPE;
l_Invoice_date    AR_Gta_Trx_Headers_All.Gt_Invoice_Date%TYPE;
l_Amount          AR_Gta_Trx_Headers_All.Gt_Invoice_Net_Amount%TYPE;
l_conc_succ       BOOLEAN;
l_failed_XML      XMLTYPE;
l_succ_XML        XMLTYPE;
l_report_XML      XMLTYPE;
l_date_format     VARCHAR2(20);
l_dbg_level       NUMBER
                  :=FND_LOG.G_Current_Runtime_Level;
l_proc_level      NUMBER
                  :=FND_LOG.Level_Procedure;

BEGIN
    --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

    l_date_format:=fnd_profile.VALUE('ICX_DATE_FORMAT_MASK');

    l_line_seq:=1;

     --read first line
     read_GT_line( x_line_seq=>l_line_seq
                 , x_values  =>l_values
                 , x_EOF     =>l_EOF
                 );

     IF l_EOF THEN
        fnd_message.SET_NAME( APPLICATION => 'AR'
                            , NAME =>  'AR_GTA_UNMATCHED_INV_DATA_FMT');
        l_error_msg := G_import_error_prefix||fnd_message.GET
                       ||G_import_error_suffix;
        put_line(l_error_msg);
        l_conc_succ:=FND_CONCURRENT.SET_COMPLETION_STATUS( status  => 'WARNING'
                                                         , message => NULL);
        RETURN;
     END IF;

     --Get the fixed Chinese text used in export flat file which identify
     --the flat file is the flat file exported from GT system
     fnd_message.SET_NAME( APPLICATION => 'AR'
                         , NAME        => 'AR_GTA_INVOICE_IMPORT');
     fnd_message.SET_TOKEN( TOKEN => 'MIDFIX'
                          , VALUE => g_export_delimiter
                          );

     l_fix_field:=fnd_message.GET;
     l_str:=l_values(1)||g_export_delimiter||l_values(2);

     --verify the file format.
     --If <1: no fixed Chinese text, give flat file format error
     --IF instr(l_str,l_fix_field)<1
     IF instr(l_fix_field,l_values(1))<1 or instr(l_fix_field,l_values(2))<1
     THEN
        fnd_message.SET_NAME('AR','AR_GTA_UNMATCHED_INV_DATA_FMT');
        l_error_msg := G_import_error_prefix||fnd_message.GET
                       ||G_import_error_suffix;
        put_line(l_error_msg);
        l_conc_succ:=FND_CONCURRENT.SET_COMPLETION_STATUS( status => 'WARNING'
                                                         , message => NULL);
        RETURN;
     END IF;

     --After the first line, we now read the second one
     --The line sequence num is alredy increased in read_gt_line
     read_GT_line( x_line_seq=>l_line_seq
                 , x_values  =>l_values
                 , x_EOF     =>l_EOF
                 );

     --it's an empty file
     IF l_EOF
     THEN
        fnd_message.SET_NAME('AR','AR_GTA_UNMATCHED_INV_DATA_FMT');
        l_error_msg := G_import_error_prefix||fnd_message.GET
                       ||G_import_error_suffix;
        put_line(l_error_msg);
        l_conc_succ:=FND_CONCURRENT.SET_COMPLETION_STATUS( status => 'WARNING'
                                                         , message => NULL);
        RETURN;
     END IF;

     --get the number of invoices
     l_num_of_invoices:=to_number(l_values(1));

     --save invoices
     FOR i IN 1..l_num_of_invoices
     LOOP
       --mark the point where begin to create one GT invoice
       --if any line failed ,then roll back this invoice
       SAVEPOINT save_header_trans;

       --get and save one invoice
       l_failed:=FALSE;
       l_trx_header_rec:=NULL;

       --we now read a invoice header
       --The line sequence num is already increased in read_gt_line
       Read_GT_line( x_line_seq=>l_line_seq
                   , x_values  =>l_values
                   , x_EOF     =>l_EOF);

       IF l_EOF
       THEN
          EXIT;
       END IF;

       --fetch correspoding variables from flat file line
       l_Customer_Name:= l_values(13);
       l_TP_TAX_REG_NUMBER  := l_values(14);
       l_Invoice_Num  := l_values(5);

       BEGIN
         l_Invoice_date:= to_date(l_values(7),'RRRRMMDD');

       EXCEPTION
          WHEN OTHERS THEN
            l_Invoice_date := l_values(7);

       END ;

       l_Amount       := l_values(10);
       BEGIN
          l_num_of_lines := l_values(6);             --get lines number

       EXCEPTION
          WHEN OTHERS THEN
            fnd_message.SET_NAME('AR','AR_GTA_UNMATCHED_INV_DATA_FMT');
            l_error_msg := G_import_error_prefix||fnd_message.GET
                           ||G_import_error_suffix;
            put_line(l_error_msg);
            l_conc_succ:=FND_CONCURRENT.SET_COMPLETION_STATUS
                               ( status => 'WARNING'
                               , message => NULL);

            IF(G_DEBUG_LEVEL >= l_dbg_level)
            THEN
               FND_LOG.string( G_DEBUG_LEVEL
                    , G_MODULE_PREFIX || l_procedure_name || '.OTHER_EXCEPTION '
                    , 'Number of lines is not an integer'||SQLCODE||':'||SQLERRM);
            END IF;

         RETURN;
       END ;

       --check data reasonability and report AR_GTA_UNMATCHED_INV_DATA_FMT
       --when data error means no corresponding invoice in GTA
       l_GTA_Invoice_num:=trim(l_values(9));

       --get GTA corresponding infomation: GTA_TRX_HEADER_ID, org_id and status
       BEGIN

          SELECT GTA_TRX_HEADER_ID
               , org_id
               , status
            INTO l_header_id
               , l_org_id
               , l_status
            FROM AR_GTA_TRX_HEADERS_ALL
           WHERE GTA_TRX_NUMBER=l_GTA_Invoice_num
             AND SOURCE='AR'
             AND latest_version_flag='Y';

     --check the ORG access
           IF MO_GLOBAL.Check_Access(l_org_id)='Y'
           THEN
              --Jogen Jun-12 2006, bug
              /*IF (l_status='GENERATED' ) OR
                 ( l_status='COMPLETED' AND l_values(1)='1')*/

              IF (l_status='GENERATED' AND l_values(1)='0')
              --first import back with successful status
              --Jogen Jun-12 2006, bug
              THEN
                /*IF (l_values(1)='0')-- this invoice was cancelled
                THEN
                   --set GTA corresponding invoices status to completed;
                   l_new_status:='COMPLETED';
                ELSE
                  --set GTA corresponding invoices status to canceled;
                   l_new_status:='CANCELLED';
                END IF;*/
                l_new_status:='COMPLETED';

         --clear the record imported before
                DELETE AR_GTA_TRX_HEADERS
                 WHERE GTA_TRX_NUMBER=l_GTA_Invoice_num
                   AND SOURCE='GT';

                DELETE AR_GTA_TRX_LINES
                 WHERE GTA_TRX_HEADER_ID IN
                          ( SELECT GTA_TRX_HEADER_ID
                              FROM AR_GTA_TRX_HEADERS
                             WHERE GTA_TRX_NUMBER=l_GTA_Invoice_num
                               AND SOURCE='GT');

                --change the matched_flag to initiated status.
                UPDATE AR_GTA_TRX_LINES
                   SET matched_flag='N'
                 WHERE GTA_TRX_HEADER_ID=l_header_id;

               --Requested by Donghai, for workbench judge whether upgrade version
                UPDATE AR_GTA_TRX_HEADERS
                   SET Status=l_new_status
                     , gt_invoice_date         = l_Invoice_date
                     , gt_invoice_net_amount   = l_values(10)
                     , gt_invoice_tax_amount   = l_values(12)
                     , gt_tax_month            = l_values(8)
                     , gt_invoice_number       = l_values(5)
                     , gt_invoice_type         = l_values(3)
                     , gt_invoice_class        = l_values(4)
                 WHERE GTA_TRX_HEADER_ID=l_header_id;

                --copy values from GTA corresponding invoice to GT invoice:
                --l_trx_rec.trx_header

                SELECT ra_gl_date
                     , ra_gl_period
                     , set_of_books_id
                     , bill_to_customer_id
                     , bill_to_customer_number
                     , org_id
                     , rule_header_id
                     , gta_trx_number
                     , group_number
                     , version
                     , transaction_date
                     , ra_trx_id
                     , ra_currency_code
                     , conversion_type
                     , conversion_date
                     , conversion_rate
                     , gta_batch_number
                     , generator_id
                     , ra_trx_number
                     , Fp_Tax_Registration_Number
                     , Tp_Tax_Registration_Number
                     , Legal_Entity_Id
                INTO
                      l_trx_header_rec.ra_gl_date
                    , l_trx_header_rec.ra_gl_period
                    , l_trx_header_rec.set_of_books_id
                    , l_trx_header_rec.bill_to_customer_id
                    , l_trx_header_rec.bill_to_customer_number
                    , l_trx_header_rec.org_id
                    , l_trx_header_rec.rule_header_id
                    , l_trx_header_rec.gta_trx_number
                    , l_trx_header_rec.group_number
                    , l_trx_header_rec.version
                    , l_trx_header_rec.transaction_date
                    , l_trx_header_rec.ra_trx_id
                    , l_trx_header_rec.ra_currency_code
                    , l_trx_header_rec.conversion_type
                    , l_trx_header_rec.conversion_date
                    , l_trx_header_rec.conversion_rate
                    , l_trx_header_rec.gta_batch_number
                    , l_trx_header_rec.generator_id
                    , l_trx_header_rec.ra_trx_number
                    , l_trx_header_rec.Fp_Tax_Registration_Number
                    , l_trx_header_rec.Tp_Tax_Registration_Number
                    , l_trx_header_rec.Legal_Entity_Id
                 FROM  AR_GTA_TRX_HEADERS
                WHERE GTA_TRX_HEADER_ID=l_header_id;

                --fill the data from GT
                BEGIN

                  l_trx_header_rec.gt_invoice_date         := l_Invoice_date;
                  l_trx_header_rec.gt_invoice_net_amount   := l_values(10);
                  l_trx_header_rec.gt_invoice_tax_amount   := l_values(12);
                  l_trx_header_rec.tax_rate                := l_values(11);
                  l_trx_header_rec.gt_tax_month            := l_values(8);
                  l_trx_header_rec.bill_to_customer_name   := l_values(13);
                  l_trx_header_rec.source                  := 'GT';
                  l_trx_header_rec.description             := l_values(21);
                  l_trx_header_rec.customer_address_phone  := l_values(15);
                  l_trx_header_rec.bank_account_name_number:= l_values(16);
                  l_trx_header_rec.gt_invoice_number       := l_values(5);
                  l_trx_header_rec.tp_tax_registration_number := l_values(14);
                  l_trx_header_rec.status                  := l_new_status;
                  l_trx_header_rec.sales_list_flag         := l_values(2);
                  l_trx_header_rec.cancel_flag             := l_values(1);
                  l_trx_header_rec.gt_invoice_type         := l_values(3);
                  l_trx_header_rec.gt_invoice_class        := l_values(4);
                  l_trx_header_rec.issuer_name             := l_values(22);
                  l_trx_header_rec.reviewer_name           := l_values(23);
                  l_trx_header_rec.payee_name              := l_values(24);
                  l_trx_header_rec.LATEST_VERSION_FLAG     :='Y';
                  l_trx_header_rec.request_id := fnd_global.CONC_REQUEST_ID;
                  l_trx_header_rec.program_application_id
                                               := fnd_global.RESP_APPL_ID;
                  l_trx_header_rec.program_id  := fnd_global.CONC_PROGRAM_ID;
                  l_trx_header_rec.program_update_date:= SYSDATE;
                  l_trx_header_rec.creation_date      := SYSDATE;
                  l_trx_header_rec.created_by         := fnd_global.USER_ID;
                  l_trx_header_rec.last_update_date   := SYSDATE;
                  l_trx_header_rec.last_updated_by    := fnd_global.USER_ID;
                  l_trx_header_rec.last_update_login  := fnd_global.LOGIN_ID;
      l_trx_header_rec.invoice_type       := l_values(3);   --added by subba






                  SELECT ar_gta_trx_headers_all_s.NEXTVAL
                    INTO l_trx_header_rec.gta_trx_header_id
                    FROM dual;

    EXCEPTION
                  WHEN OTHERS THEN

                  l_failed:=TRUE;
                  fnd_message.SET_NAME('AR','AR_GTA_UNMATCHED_INV_DATA_FMT');
                  l_error_msg:=fnd_message.GET;

                  IF(G_DEBUG_LEVEL >= l_dbg_level)
                  THEN
                     FND_LOG.string( G_DEBUG_LEVEL
                          , G_MODULE_PREFIX || l_procedure_name || '.OTHER_EXCEPTION '
                          , 'Assign value from TXT to record:'||SQLCODE||':'||SQLERRM);
                  END IF;

                  ROLLBACK TO save_header_trans;
                  INSERT INTO AR_GTA_IMPORT_REP_TEMP( SEQ
                                                     , SUCCEEDED
                                                     , Customer_Name
                                                     , Taxpayer_ID
                                                     , Invoice_Num
                                                     , Invoice_date
                                                     , Amount
                                                     , FailedReason
                                                     )
                       VALUES(AR_GTA_IMPORT_REP_TEMP_s.NEXTVAL
                             , 'N'
                             , l_Customer_Name
                             , l_TP_TAX_REG_NUMBER
                             , l_Invoice_Num
                             , to_char(l_Invoice_date,l_date_format)
                             , l_Amount
                             , l_error_msg
                             );
                END;

                l_trx_line_tbl.DELETE;
                l_line_num:=0;

                --read lines from flat file and create line record
                FOR j IN 1..l_num_of_lines
                LOOP
                  Read_GT_line(x_line_seq=>l_line_seq
                             , x_values  =>l_values
                             , x_EOF     =>l_EOF);

                  --
                  IF NOT l_failed
                  THEN
                  BEGIN
                    --put_log('import log:10--');
                    l_trx_line_rec                      :=NULL;

                    --compare whether there's record matched in GTA
                    UPDATE ar_gta_trx_lines_all
                       SET matched_flag='Y'
                     WHERE gta_trx_header_id=l_header_id
                       AND enabled_flag='Y'
                       AND item_description=l_values(2)
                       AND item_model=l_values(3)
                       AND item_tax_denomination=l_values(11)
                       AND tax_rate=l_values(7)
                       AND uom_name=l_values(4)
                       AND quantity=l_values(5)
                       AND unit_price=decode(l_values(10),
                                           '0',l_values(9),
                                           '1',to_number(l_values(9))/
                                               (1+to_number(l_values(7))),
                                           NULL)
                       AND amount=l_values(6)
                       AND matched_flag='N'
                       AND tax_amount=l_values(8)
                       AND ROWNUM<2;

                    IF SQL%ROWCOUNT>0 THEN
                       l_trx_line_rec.matched_flag:='Y';
                    ELSE
                       l_trx_line_rec.matched_flag:='N';
                    END IF;

                    --fill other data
                    l_trx_line_rec.amount               :=l_values(6);
                    l_trx_line_rec.tax_amount           :=l_values(8);
                    l_trx_line_rec.org_id               :=l_org_id;
                    l_trx_line_rec.gta_trx_header_id
                                        :=l_trx_header_rec.gta_trx_header_id;

                    SELECT ar_gta_trx_lines_all_s.NEXTVAL
                      INTO l_trx_line_rec.gta_trx_line_id
                      FROM dual;

                    l_line_num:=l_line_num+1;
                    l_trx_line_rec.line_number          :=l_line_num;
                    l_trx_line_rec.item_description     :=l_values(2);
                    l_trx_line_rec.item_model           :=l_values(3);
                    l_trx_line_rec.item_tax_denomination:=l_values(11);
                    l_trx_line_rec.tax_rate             :=l_values(7);
                    l_trx_line_rec.uom_name             :=l_values(4);
                    l_trx_line_rec.quantity             :=l_values(5);
                    l_trx_line_rec.price_flag           :=l_values(10);

                    SELECT decode(l_values(10),
                                  '0',l_values(9),
                                  NULL)
                         , decode(l_values(10),
                                  '1',l_values(9),
                                  NULL)
                      INTO l_trx_line_rec.unit_price
                         , l_trx_line_rec.unit_tax_price
                      FROM dual;

                    l_trx_line_rec.discount_flag:=l_values(1);
                    l_trx_line_rec.enabled_flag :='Y';
                    l_trx_line_rec.request_id   := fnd_global.CONC_REQUEST_ID;
                    l_trx_line_rec.program_id   := fnd_global.CONC_PROGRAM_ID;
                    l_trx_line_rec.creation_date:= SYSDATE;
                    l_trx_line_rec.created_by   := fnd_global.USER_ID;
                    l_trx_line_rec.last_update_date := SYSDATE;
                    l_trx_line_rec.last_updated_by  := fnd_global.USER_ID;
                    l_trx_line_rec.last_update_login:= fnd_global.LOGIN_ID;
                    l_trx_line_rec.program_applicaton_id
                                                := fnd_global.RESP_APPL_ID;
                    l_trx_line_rec.program_update_date  := SYSDATE;

                    l_trx_line_tbl.EXTEND;
                    l_trx_line_tbl(l_trx_line_tbl.LAST):=l_trx_line_rec;
                  EXCEPTION
                    WHEN OTHERS THEN
                    l_failed:=TRUE;

                    fnd_message.SET_NAME( 'AR'
                                        , 'AR_GTA_UNMATCHED_INV_DATA_FMT');
                    l_error_msg:=fnd_message.GET;

                    IF(G_DEBUG_LEVEL >= l_dbg_level)
                    THEN
                       FND_LOG.string( G_DEBUG_LEVEL
                            , G_MODULE_PREFIX || l_procedure_name || '.OTHER_EXCEPTION '
                            , 'Update original record:'||SQLCODE||':'||SQLERRM);
                    END IF;

                    ROLLBACK TO save_header_trans;
                    INSERT INTO AR_GTA_IMPORT_REP_TEMP( SEQ
                                                       , SUCCEEDED
                                                       , Customer_Name
                                                       , Taxpayer_ID
                                                       , Invoice_Num
                                                       , Invoice_date
                                                       , Amount
                                                       , FailedReason
                                                       )
                         VALUES( AR_GTA_IMPORT_REP_TEMP_s.NEXTVAL
                               , 'N'
                               , l_Customer_Name
                               , l_TP_TAX_REG_NUMBER
                               , l_Invoice_Num
                               , to_char(l_Invoice_date,l_date_format)
                               , l_Amount
                               , l_error_msg
                               );
                  END;
                  END IF;  --IF NOT l_failed

                END LOOP;--FOR j IN 1..l_num_of_lines

                IF NOT l_failed
                THEN
                  l_trx_rec.trx_header:=l_trx_header_rec;
                  l_trx_rec.trx_lines:=l_trx_line_tbl;

                  --insert into GTA table
                  BEGIN
                       ar_gta_trx_util.create_Trx(P_GTA_Trx => l_trx_rec);

                       INSERT INTO AR_GTA_IMPORT_REP_TEMP( SEQ
                                                           , SUCCEEDED
                                                           , Customer_Name
                                                           , Taxpayer_ID
                                                           , Invoice_Num
                                                           , Invoice_date
                                                           , Amount
                                                           , STATUS
                                                           )
                           VALUES( AR_GTA_IMPORT_REP_TEMP_s.NEXTVAL
                                 , 'Y'
                                 , l_Customer_Name
                                 , l_TP_TAX_REG_NUMBER
                                 , l_Invoice_Num
                                 , to_char(l_Invoice_date,l_date_format)
                                 , l_Amount
                                 , l_new_status
                                 );
                    EXCEPTION
                      WHEN OTHERS THEN
                      l_failed:=TRUE;

                      fnd_message.SET_NAME('AR'
                                          ,'AR_GTA_UNMATCHED_INV_DATA_FMT');
                      l_error_msg:=fnd_message.GET;

                      IF(G_DEBUG_LEVEL >= l_dbg_level)
                      THEN
                         FND_LOG.string( G_DEBUG_LEVEL
                              , G_MODULE_PREFIX || l_procedure_name || '.OTHER_EXCEPTION '
                              , 'Insert into base table:'||SQLCODE||':'||SQLERRM);
                      END IF;

                      ROLLBACK TO save_header_trans;
                      INSERT INTO AR_GTA_IMPORT_REP_TEMP( SEQ
                                                         , SUCCEEDED
                                                         , Customer_Name
                                                         , Taxpayer_ID
                                                         , Invoice_Num
                                                         , Invoice_date
                                                         , Amount
                                                         , FailedReason
                                                         )
                           VALUES( AR_GTA_IMPORT_REP_TEMP_s.NEXTVAL
                                 , 'N'
                                 , l_Customer_Name
                                 , l_TP_TAX_REG_NUMBER
                                 , l_Invoice_Num
                                 , to_char(l_Invoice_date,l_date_format)
                                 , l_Amount
                                 , l_error_msg
                                 );
                    END ;
                  END IF;
              --Jogen Jun-12 2006, bug
              ELSIF (l_status='COMPLETED')--has exists VAT invoice from GT
              THEN
                l_failed:=TRUE;

                fnd_message.SET_NAME('AR'
                                    ,'AR_GTA_IMP_PRIEXIST_FAIL');
                fnd_message.SET_TOKEN( TOKEN => 'NUM'
                                     , VALUE => l_Invoice_Num
                                     );

                l_error_msg:=fnd_message.GET;

                INSERT INTO AR_GTA_IMPORT_REP_TEMP( SEQ
                                                   , SUCCEEDED
                                                   , Customer_Name
                                                   , Taxpayer_ID
                                                   , Invoice_Num
                                                   , Invoice_date
                                                   , Amount
                                                   , FailedReason
                                                   )
                     VALUES( AR_GTA_IMPORT_REP_TEMP_s.NEXTVAL
                           , 'N'
                           , l_Customer_Name
                           , l_TP_TAX_REG_NUMBER
                           , l_Invoice_Num
                           , to_char(l_Invoice_date,l_date_format)
                           , l_Amount
                           , l_error_msg
                           );

                 FOR j IN 1..l_num_of_lines
                 LOOP
                    Read_GT_Line(x_line_seq=>l_line_seq
                               , x_values  =>l_values
                               , x_EOF     =>l_EOF);
                 END LOOP;

              ELSIF (l_status='CANCELLED')--the VAT invoice was cancelled in GTA
              THEN
                l_failed:=TRUE;

                fnd_message.SET_NAME('AR'
                                    ,'AR_GTA_IMP_CANCEL');
                fnd_message.SET_TOKEN( TOKEN => 'NUM'
                                     , VALUE => l_Invoice_Num
                                     );

                l_error_msg:=fnd_message.GET;

                INSERT INTO AR_GTA_IMPORT_REP_TEMP( SEQ
                                                   , SUCCEEDED
                                                   , Customer_Name
                                                   , Taxpayer_ID
                                                   , Invoice_Num
                                                   , Invoice_date
                                                   , Amount
                                                   , FailedReason
                                                   )
                     VALUES( AR_GTA_IMPORT_REP_TEMP_s.NEXTVAL
                           , 'N'
                           , l_Customer_Name
                           , l_TP_TAX_REG_NUMBER
                           , l_Invoice_Num
                           , to_char(l_Invoice_date,l_date_format)
                           , l_Amount
                           , l_error_msg
                           );

                 FOR j IN 1..l_num_of_lines
                 LOOP
                    Read_GT_Line(x_line_seq=>l_line_seq
                               , x_values  =>l_values
                               , x_EOF     =>l_EOF);
                 END LOOP;
              --Jogen Jun-12 2006, bug

              ELSE --status error
                fnd_message.SET_NAME('AR','AR_GTA_WRONG_INV_STATUS');
                l_error_msg:=fnd_message.GET;

                INSERT INTO AR_GTA_IMPORT_REP_TEMP( SEQ
                                                   , SUCCEEDED
                                                   , Customer_Name
                                                   , Taxpayer_ID
                                                   , Invoice_Num
                                                   , Invoice_date
                                                   , Amount
                                                   , FailedReason
                                                   )
                     VALUES( AR_GTA_IMPORT_REP_TEMP_s.NEXTVAL
                           , 'N'
                           , l_Customer_Name
                           , l_TP_TAX_REG_NUMBER
                           , l_Invoice_Num
                           , to_char(l_Invoice_date,l_date_format)
                           , l_Amount
                           , l_error_msg
                           );

                 FOR j IN 1..l_num_of_lines
                 LOOP
                    Read_GT_Line(x_line_seq=>l_line_seq
                               , x_values  =>l_values
                               , x_EOF     =>l_EOF);
                 END LOOP;
              END IF;
           ELSE  --MO_GLOBAL.Check_Access(l_org_id)<>'Y'
              --report AR_GTA_MOAC_ERROR;
              /*fnd_message.SET_NAME('AR','AR_GTA_MOAC_FORBID');
              l_error_msg:=fnd_message.GET;

              INSERT INTO AR_GTA_IMPORT_REP_TEMP( SEQ
                                                 , SUCCEEDED
                                                 , Customer_Name
                                                 , Taxpayer_ID
                                                 , Invoice_Num
                                                 , Invoice_date
                                                 , Amount
                                                 , FailedReason
                                                 )
                   VALUES( AR_GTA_IMPORT_REP_TEMP_s.NEXTVAL
                         , 'N'
                         , l_Customer_Name
                         , l_Taxpayer_ID
                         , l_Invoice_Num
                         , to_char(l_Invoice_date,l_date_format)
                         , l_Amount
                         , l_error_msg
                         );
                  */
              FOR j IN 1..l_num_of_lines
              LOOP
                 Read_GT_line(x_line_seq=>l_line_seq
                            , x_values  =>l_values
                            , x_EOF     =>l_EOF);
              END LOOP;
           END IF; -- MO_GLOBAL.Check_Access(l_org_id)='Y'
        EXCEPTION
           WHEN NO_DATA_FOUND THEN

              FOR j IN 1..l_num_of_lines
              LOOP
                 Read_GT_line(x_line_seq=>l_line_seq
                            , x_values  =>l_values
                            , x_EOF     =>l_EOF);
              END LOOP;
        END;

     END LOOP; --FOR i IN 1..l_num_of_invoices

   --generate XML output
     BEGIN
       SELECT XMLElement("Details"
                        , xmlagg(
                             xmlelement(
                                "Invoice"
                               , xmlforest(Customer_Name    AS "CustomerName"
                                          ,Taxpayer_ID      AS "TaxpayerID"
                                          ,Invoice_Num      AS "InvoiceNum"
                                          --Jogen 20-Sep-2006 bug5521629
                                          --Format date to XSD Date format
            --,AR_GTA_TRX_UTIL.To_Xsd_Date_String(Invoice_date)AS "InvoiceDate"--deleted by Yao for bug#8257757
                                          ,Invoice_date     AS "InvoiceDate"--Added by Yao Zhang for bug#8257757
                                          --Jogen 20-Sep-2006 bug5521629
                                          ,Amount           AS "Amount"
                                          ,Status           AS "Status"
                                          )
                                       )
                                    )
                         )
         INTO l_succ_XML
        FROM AR_GTA_IMPORT_REP_TEMP
       WHERE SUCCEEDED='Y';
     EXCEPTION
       WHEN OTHERS THEN
          NULL;
     END;

     BEGIN
       SELECT XMLElement("FailedInvoices"
                        , xmlagg(
                             xmlelement(
                                "Invoice"
                                ,xmlforest(Customer_Name    AS "CustomerName"
                                          ,Taxpayer_ID      AS "TaxpayerID"
                                          ,Invoice_Num      AS "InvoiceNum"
                                          --Jogen 20-Sep-2006 bug5521629
                                          --Format date to XSD Date format
            --,AR_GTA_TRX_UTIL.To_Xsd_Date_String(Invoice_date)AS "InvoiceDate"--delete by Yao for bug#8257757
                                         ,Invoice_date     AS "InvoiceDate"--Added by Yao for bug#8257757
                                          --Jogen 20-Sep-2006 bug5521629
                                          ,Amount           AS "Amount"
                                          ,FailedReason     AS "Reason"
                                          )
                                       )
                                    )
                         )
         INTO l_failed_XML
        FROM AR_GTA_IMPORT_REP_TEMP
       WHERE SUCCEEDED='N';
     EXCEPTION
       WHEN OTHERS THEN
          NULL;
     END;

     SELECT XMLElement("ImportReport"
                       , XMLElement("RepDate",to_char( SYSDATE
                                                     , l_date_format
                                                     )
                                   )
                       , XMLElement("ReportFailed",'N')
                       , XMLElement("FailedWithParameters",'N')
                       , l_succ_XML
                       , l_failed_XML
                       )
       INTO l_report_XML
      FROM dual;

    AR_GTA_TRX_UTIL.output_conc(l_report_XML.Getclobval);

    clear_imp_temp_table;

   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level )
EXCEPTION
 WHEN OTHERS THEN
    IF(l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX || l_procedure_name||'.OTHER_EXCEPTION'
                    , SQLCODE||SQLERRM);
    END IF;
    clear_imp_temp_table;
    RAISE;

END Import_Invoices;

--==========================================================================
--  PROCEDURE NAME:
--
--    Export_Invoice                     Private
--
--  DESCRIPTION:
--
--      This procedure export one VAT invoice from GTA to flat file
--
--  PARAMETERS:
--      In:  p_invoice_header_id   The transaction id which need export
--                                 to flat file
--           p_batch_number        The export batch number
--
--     Out:  x_output              export lines which need print to flat file
--           x_success             succeed or failed when export this single
--                                 invoice
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--      05/12/05       Jogen Hu      Created
--      10/12/08       Lv Xiao       Modified for bug#7626503
--      19-Mar-2009    Yao Zhang    Changed for bug 8339490
--===========================================================================
PROCEDURE Export_Invoice
( p_invoice_header_id     IN         NUMBER
, p_batch_number          IN         VARCHAR2
, x_output                OUT NOCOPY t_invoice_export_output
, x_success               OUT NOCOPY PLS_INTEGER
, p_dup_record_tbl         IN dup_record_tbl
)
IS
l_procedure_name VARCHAR2(20):='Export_invoice';
l_invoice        AR_GTA_TRX_UTIL.TRX_header_rec_TYPE;
l_TRX_Line_REC   AR_GTA_TRX_UTIL.TRX_LINE_REC_TYPE;
l_lines_num      NUMBER:=0;
l_header_output  VARCHAR2(1000);

ln_ta_trx_id     NUMBER;
lv_desc          VARCHAR2(100);
ln_trx_org_id    NUMBER;
ln_gta_trx_number VARCHAR2(100);

i                INTEGER;
l_index          INTEGER;
l_uom_name       varchar2(25);--Yao Zhang add for bug 8339490

CURSOR c_trx_lines(p_header_id IN NUMBER) IS
SELECT *
  FROM AR_GTA_trx_lines
 WHERE GTA_trx_header_id = p_header_id
   AND Enabled_Flag='Y';

l_dbg_level      NUMBER              :=FND_LOG.G_Current_Runtime_Level;
l_proc_level     NUMBER              :=FND_LOG.Level_Procedure;
BEGIN

   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

     --reserve one line for header output
     x_output:=t_invoice_export_output(NULL,NULL);

     --Get the comments of a single invoice
     fnd_message.SET_NAME( APPLICATION => 'AR'
                         , NAME =>        'AR_GTA_INVOICE_EXPORT_COMMT'
                         );
     fnd_message.SET_TOKEN( TOKEN => 'PREFIX'
                          , VALUE => g_comment_delimiter
                          );

     --put to the temporary output
     x_output(1):=fnd_message.get;

     ar_gta_trx_headers_all_pkg.query_row( p_header_id => p_invoice_header_id
                                          , x_trx_header_rec => l_invoice
                                          );

     x_success:=check_header(l_invoice);


--add by Lv Xiao for bug#7626503 on 12-Dec-2008, begin
-------------------------------------------------------------------------
/*
  check duplicated description.
  For credit memo transaction reference to Special VAT invoice and
  Recycle VAT invoice, description should be unique.
*/
     IF gv_prefix_missing_flag = 'TRUE'
     THEN
        x_success :=G_EXPORT_MISSING_PREFIX_ERROR;
     END IF;

     IF gv_desc_duplicat_flag = 'TRUE'
     THEN
        x_success := G_EXPORT_CRMEMO_DUP_ERROR;
     END IF;

-------------------------------------------------------------------------
--add by Lv Xiao for bug#7626503 on 12-Dec-2008, end

     --put line record to flat file temp
     FOR l_Invoice_Line IN c_trx_lines(l_invoice.gta_Trx_header_id)
     LOOP

         IF l_Invoice_Line.ENABLED_FLAG='Y'
         THEN
            l_lines_num:=l_lines_num+1;

            l_TRX_Line_REC.item_description :=l_Invoice_Line.item_description ;
            --l_TRX_Line_REC.uom_name         :=l_Invoice_Line.uom_name;--comment by Yao Zhang for bug 8339490
            l_TRX_Line_REC.item_model       :=l_Invoice_Line.item_model       ;
            l_TRX_Line_REC.quantity         :=l_Invoice_Line.quantity         ;
            l_TRX_Line_REC.amount           :=l_Invoice_Line.amount           ;
            l_TRX_Line_REC.tax_rate         :=l_Invoice_Line.tax_rate         ;
            l_TRX_Line_REC.item_tax_denomination
                                        :=l_Invoice_Line.item_tax_denomination;
            --Yao Zhang add for bug#8605196 R12.1.2 ER1 to export discount amount
            l_TRX_Line_REC.discount_amount  :=l_Invoice_Line.discount_amount;
           --The following code is added by Yao Zhang for bug 8339490
            BEGIN
            SELECT uom.unit_of_measure_tl
            INTO l_uom_name
            FROM mtl_units_of_measure_tl uom
            WHERE uom.uom_code = l_invoice_line.uom
            AND uom.LANGUAGE = userenv('LANG');
            EXCEPTION
            WHEN no_data_found THEN
            l_uom_name:=NULL;
            END;
            l_TRX_Line_REC.uom_name:=l_uom_name;
           --Yao Zhang add end.

            IF NOT check_line_Length(l_TRX_Line_REC)
            THEN
              x_success:=G_EXPORT_EXCEED_ERROR;
            END IF;

           --put line record to flat file temp
           x_output.EXTEND;

           x_output(x_output.LAST):=
               substr( --rpad(l_Invoice_Line.ITEM_DESCRIPTION
                --,length(l_Invoice_Line.ITEM_DESCRIPTION)+1)--Yao Zhang modified for bug8645514
                l_Invoice_Line.ITEM_DESCRIPTION||g_export_delimiter
                --||l_Invoice_Line.UOM_NAME        ||g_export_delimiter
                ||l_uom_name                     ||g_export_delimiter--Yao Zhang changed for bug 8339490
                ||l_Invoice_Line.ITEM_MODEL      ||g_export_delimiter
                ||l_Invoice_Line.QUANTITY        ||g_export_delimiter
                ||l_Invoice_Line.AMOUNT          ||g_export_delimiter
                ||l_Invoice_Line.Tax_rate        ||g_export_delimiter
                ||l_Invoice_Line.ITEM_TAX_DENOMINATION
                --Added by Yao Zhang for bug#8605196 R12.1.2 ER1 to export discount amount
                ||g_export_delimiter||-1*(l_Invoice_Line.discount_amount)
                ,1, 1000);

         END IF;

     END LOOP;

     --put header record to flat file temp
     l_header_output:= substr(
                         l_invoice.GTA_TRX_NUMBER          ||g_export_delimiter
                       ||l_lines_num                       ||g_export_delimiter
                       ||l_invoice.BILL_TO_CUSTOMER_NAME   ||g_export_delimiter
                       ||l_invoice.tp_tax_registration_number||g_export_delimiter
                       ||l_invoice.CUSTOMER_ADDRESS_PHONE  ||g_export_delimiter
                       ||l_invoice.BANK_ACCOUNT_NAME_NUMBER||g_export_delimiter
                       ||l_invoice.DESCRIPTION             ||g_export_delimiter
                       ||l_invoice.REVIEWER_NAME           ||g_export_delimiter
                       ||l_invoice.PAYEE_NAME              ||g_export_delimiter
                       ||g_export_delimiter
                       ||to_char(l_invoice.TRANSACTION_DATE,'RRRRMMDD')
                       ,1,1000);

     IF x_success=G_EXPORT_SUCC
     THEN
         --put invoice header to temporary record of flat file
         x_output(2):=l_header_output;

         --change GTA status
         --fill request_id etc. to  P_INVOICE;
         UPDATE ar_gta_trx_headers
            SET status='GENERATED'
              , gta_batch_number      =p_batch_number
              , export_request_id     =fnd_global.CONC_REQUEST_ID
              , REQUEST_ID            =fnd_global.CONC_REQUEST_ID
              , PROGRAM_APPLICATION_ID=fnd_global.RESP_APPL_ID
              , PROGRAM_ID            =fnd_global.CONC_PROGRAM_ID
              , PROGRAM_UPDATE_DATE   =SYSDATE
              , LAST_UPDATE_DATE      =SYSDATE
              , LAST_UPDATED_BY       =fnd_global.USER_ID
              , LAST_UPDATE_LOGIN     =fnd_global.LOGIN_ID
          WHERE GTA_TRX_HEADER_ID=l_invoice.gta_Trx_header_id;

     ELSE -- x_success <> G_EXPORT_SUCC
         x_output(2):=g_comment_delimiter||l_header_output;

         i:=x_output.NEXT(2);
         IF i IS NOT NULL THEN
             i:=x_output.NEXT(i);
             --FOR i IN (2)..x_output.COUNT
             WHILE i IS NOT NULL
             LOOP
                x_output(i):=g_comment_delimiter||x_output(i);
                i:=x_output.NEXT(i);
             END LOOP;
       END IF ;

         UPDATE ar_gta_trx_headers
            SET export_request_id     =fnd_global.CONC_REQUEST_ID
              , REQUEST_ID            =fnd_global.CONC_REQUEST_ID
              , PROGRAM_APPLICATION_ID=fnd_global.RESP_APPL_ID
              , PROGRAM_ID            =fnd_global.CONC_PROGRAM_ID
              , PROGRAM_UPDATE_DATE   =SYSDATE
              , LAST_UPDATE_DATE      =SYSDATE
              , LAST_UPDATED_BY       =fnd_global.USER_ID
              , LAST_UPDATE_LOGIN     =fnd_global.LOGIN_ID
          WHERE GTA_TRX_HEADER_ID=l_invoice.gta_Trx_header_id;

     END IF;-- x_success = G_EXPORT_SUCC

     UPDATE ar_gta_trx_lines
        SET REQUEST_ID            =fnd_global.CONC_REQUEST_ID
          , program_application_id =fnd_global.RESP_APPL_ID
          , PROGRAM_ID            =fnd_global.CONC_PROGRAM_ID
          , PROGRAM_UPDATE_DATE   =SYSDATE
          , LAST_UPDATE_DATE      =SYSDATE
          , LAST_UPDATED_BY       =fnd_global.USER_ID
          , LAST_UPDATE_LOGIN     =fnd_global.LOGIN_ID
      WHERE GTA_TRX_HEADER_ID=l_invoice.gta_Trx_header_id
        AND ENABLED_FLAG='Y';

   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION

 WHEN OTHERS THEN
    IF(l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX || l_procedure_name || '.OTHER_EXCEPTION'
                    , SQLCODE||SQLERRM);
    END IF;
    RAISE;

END Export_Invoice;


--==========================================================================
--  PROCEDURE NAME:
--
--    Export_Invoices                    Private
--
--  DESCRIPTION:
--
--      This procedure export VAT invoices from GTA to flat file
--
--  PARAMETERS:
--      In:  p_gta_trx_line      CURSOR which get the invoices header_id for export
--           p_batch_number      Export batch number
--
--     Out:
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--     05/12/05       Jogen Hu      Created
--     09/28/05       Jogen Hu      add functionality to put out the first party
--                                  tax registration number
--     11/16/05       Jogen Hu      updated, the bank account mask profile change
--                                     to CE_MASK_INTERNAL_BANK_ACCT_NUM, and the value
--                                     change to NO MASK
--     09/12/08       Lv Xiao       Modified for bug#7626503
--     12/25/08       Lv Xiao       Modified for bug#7644876
--                                  Enlarge the string buffer of parameters:
--                                  lv_crmemo_prefix_msg           VARCHAR2(240);
--                                  lv_trx_crmemo_prefix_msg       VARCHAR2(1000);
--                                  lv_trx_crmemo_notification_num VARCHAR2(1000);
--    09-Sep-2009    Yao Zhang      Modified for bug#8882568
--    28-Sep-2009    Allen Yang     Modified for bug 8981199
--===========================================================================
PROCEDURE Export_Invoices
( P_cursor                 IN       c_trx_header_id_type
, p_batch_number           IN       VARCHAR2
, p_generator_id           IN       NUMBER
, p_org_id                 IN       NUMBER
, p_draft_dup_cur          IN       crmemo_dup_cur_TYPE  DEFAULT NULL
)
IS
l_procedure_name      VARCHAR2(30):='export_Invoices';
l_header_rec_cur      AR_Gta_Trx_Headers_all%ROWTYPE;
l_succ_output         t_invoice_export_output:=t_invoice_export_output();
l_exceed_output       t_invoice_export_output:=t_invoice_export_output();
l_taxpayid_err_out    t_invoice_export_output:=t_invoice_export_output();
l_creddit_memo_err    t_invoice_export_output:=t_invoice_export_output();
l_current_output      t_invoice_export_output:=t_invoice_export_output();

l_trx_export_success  PLS_INTEGER;
l_error_msg           VARCHAR2(5000);
l_conc_succ           BOOLEAN;
l_gta_trx_header_id   ar_gta_trx_headers_all.gta_trx_header_id%TYPE;
i                     INTEGER;
l_str                 VARCHAR2(1000);        --Jun-22, 2006, jogen bug 5335265
l_dbg_level           NUMBER              :=FND_LOG.G_Current_Runtime_Level;
l_proc_level          NUMBER              :=FND_LOG.Level_Procedure;
l_first_Inv           BOOLEAN             :=TRUE;

--add by Lv Xiao on 9-Dec-2008 for bug#7626503, begin
--------------------------------------------------------------------------
l_missing_prefix_output  t_invoice_export_output:=t_invoice_export_output();
l_crmemo_dup_err_output  t_invoice_export_output:=t_invoice_export_output();

ln_ta_trx_id                   NUMBER;
lv_desc                        VARCHAR2(200);
ln_trx_org_id                  NUMBER;
ln_gta_trx_number              VARCHAR2(100);
l_index                        NUMBER;
ln_dup_org_name1               VARCHAR2(100);
ln_dup_org_name2               VARCHAR2(100);

lv_trx_type                    VARCHAR2(20);
ln_pos                         NUMBER:=0;
--modified by Lv Xiao for bug#7644876 on 25-Dec-2008, begin
--------------------------------------------------------------------------
/*lv_crmemo_prefix_msg           VARCHAR2(50);
lv_trx_crmemo_prefix_msg       VARCHAR2(50);
lv_trx_crmemo_notification_num VARCHAR2(50);*/
lv_crmemo_prefix_msg           VARCHAR2(240);
lv_trx_crmemo_prefix_msg       VARCHAR2(1000);
lv_trx_crmemo_notification_num VARCHAR2(1000);
--------------------------------------------------------------------------
--modified by Lv Xiao for bug#7644876 on 25-Dec-2008, end
lb_num_flag                    BOOLEAN:=TRUE;

ln_notification_num            NUMBER:=0;

p_GTA_trx_header               AR_GTA_TRX_UTIL.TRX_header_rec_TYPE;

lt_dup_record_tbl              dup_record_tbl := dup_record_tbl();
--------------------------------------------------------------------------
--add by Lv Xiao on 9-Dec-2008 for bug#7626503, end


BEGIN

   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

      put_log(fnd_profile.VALUE('CE_MASK_INTERNAL_BANK_ACCT_NUM'));

      IF fnd_profile.VALUE('CE_MASK_INTERNAL_BANK_ACCT_NUM') IS NULL
       OR fnd_profile.VALUE('CE_MASK_INTERNAL_BANK_ACCT_NUM') <> 'NO MASK'
      THEN
        --report AR_GTA_BANKACCOUNT_MASKING
         fnd_message.SET_NAME('AR','AR_GTA_BANKACCOUNT_MASKING');
         l_error_msg:=fnd_message.GET;
         put_line(l_error_msg);
         --set concurrent status to warning
         l_conc_succ:=FND_CONCURRENT.SET_COMPLETION_STATUS( status => 'WARNING'
                                                          , message => NULL);
         RETURN;
      END IF;

--add by Lv Xiao for bug#7626503 on 12-Dec-2008, begin
----------------------------------------------------------
/* fetch all duplicated descriptions from curso p_draft_dup_cur
   to table lt_dup_record_tbl.
*/

      IF p_draft_dup_cur IS NOT NULL
      THEN
          LOOP
             FETCH p_draft_dup_cur
              INTO ln_ta_trx_id
                 , lv_desc
                 , ln_trx_org_id
                 , ln_gta_trx_number;
              EXIT WHEN p_draft_dup_cur%NOTFOUND;
                 lt_dup_record_tbl.EXTEND;
                 lt_dup_record_tbl(lt_dup_record_tbl.LAST).ra_trx_id := ln_ta_trx_id;
                 lt_dup_record_tbl(lt_dup_record_tbl.LAST).description := lv_desc;
                 lt_dup_record_tbl(lt_dup_record_tbl.LAST).org_id := ln_trx_org_id;
                 lt_dup_record_tbl(lt_dup_record_tbl.LAST).gta_trx_number := ln_gta_trx_number;

          END LOOP;
      END IF ;
----------------------------------------------------------
--add by Lv Xiao for bug#7626503 on 12-Dec-2008, end

      LOOP
         FETCH P_cursor INTO l_header_rec_cur;
         EXIT WHEN P_cursor%NOTFOUND;
/*         IF l_first_Inv
         THEN
             l_first_Inv:=FALSE;
             fnd_message.SET_NAME('AR','AR_GTA_FP_TAX_REG_NUMBER');
             fnd_message.SET_TOKEN( TOKEN => 'NUMBER'
                                  , VALUE => l_header_rec_cur.fp_tax_registration_number
                                  );
             put_line(g_comment_delimiter||fnd_message.GET);

         END IF;*/

         l_gta_trx_header_id:=l_header_rec_cur.gta_trx_header_id;

--add by Lv Xiao for bug#7626503 on 11-Dec-2008, begin
----------------------------------------------------------------

/*
 * following code is to the format of cr memo description prefix, and the fixed
 * format is :
 * 'Notification Number for Issued VAT Credit memo+16-digit Notification number'
 * if check fails, message 'AR_GTA_CRMEMO_MISSING_PREFIX' is wroten to output
 * file.
*/
     ar_gta_trx_headers_all_pkg.query_row( p_header_id => l_gta_trx_header_id
                                          , x_trx_header_rec => p_GTA_trx_header
                                          );

       --Yao Zhang add for bug8605196 begin
       IF p_GTA_trx_header.consolidation_flag='0'
       THEN
         IF AR_GTA_TRX_UTIL.Get_Gtainvoice_Amount(p_GTA_trx_header.gta_trx_header_id)>0
         THEN lv_trx_type:='INV';
         ELSE lv_trx_type:='CM';
         END IF;
       ELSE
        BEGIN
      --Yao Zhang add for bug8605196 end
        SELECT DISTINCT RCTT.type
            INTO lv_trx_type
            FROM AR_GTA_TRX_HEADERS_ALL JGTH
               , RA_CUST_TRX_TYPES_ALL RCTT
               , RA_CUSTOMER_TRX_ALL   RCT
           WHERE RCTT.cust_trx_type_id = RCT.cust_trx_type_id
             AND JGTH.source = 'AR'
             AND RCTT.org_id = p_GTA_trx_header.org_id
             AND RCT.customer_trx_id = p_GTA_trx_header.ra_trx_id;
        EXCEPTION
        WHEN OTHERS THEN
        RAISE;
        END;
        END IF;
        fnd_file.PUT_LINE(fnd_file.LOG,'lv_trx_type'||lv_trx_type);

        /* only Special and Recycle VAT invoices with transaction class
         * 'Credit Memo' will be check their Prefix format, and if there
         * duplicated descriptions exist.
         */

          IF ( (p_GTA_trx_header.invoice_type <> '2') AND
               ( lv_trx_type = 'CM'))
          THEN
            fnd_message.SET_NAME('AR','AR_GTA_CRMEMO_PREFIX');
            lv_crmemo_prefix_msg := fnd_message.GET;
            ln_pos := length(lv_crmemo_prefix_msg);


            lv_trx_crmemo_prefix_msg := substr(p_GTA_trx_header.description
                                             , 0
                                             , ln_pos);

            lv_trx_crmemo_notification_num := substr(p_GTA_trx_header.description
                                                  , ln_pos+1
                                                  , length(p_GTA_trx_header.description));



            IF length(lv_trx_crmemo_notification_num) <> 16 THEN
               lb_num_flag := FALSE;
            END IF; --length(lv_trx_crmemo_notification_num) <> 16
            BEGIN
               SELECT to_number(lv_trx_crmemo_notification_num)
                 INTO ln_notification_num
                 FROM dual;
            EXCEPTION
            WHEN OTHERS THEN
               lb_num_flag := FALSE;
            END;

            IF (lv_trx_crmemo_prefix_msg <> lv_crmemo_prefix_msg
               OR lb_num_flag = FALSE)
            THEN
               gv_prefix_missing_flag := 'TRUE';
               /* commented by Allen Yang for bug 8981199 28-Sep-2009
               fnd_message.SET_NAME('AR','AR_GTA_CRMEMO_MISSING_PREFIX');
               l_missing_prefix_output.EXTEND;
               l_missing_prefix_output(l_missing_prefix_output.LAST):= fnd_message.GET;
               */
            END IF; --lv_trx_crmemo_prefix_msg <> lv_crmemo_prefix_msg
--          END IF;

/*
 * following code is to check duplicated description, and write
 * output message to l_crmemo_dup_err_output.
*/

            IF lt_dup_record_tbl.COUNT > 0
            THEN

                 IF gv_dup_title_flag = 'FALSE'
                 THEN
                    l_crmemo_dup_err_output.EXTEND;
                    fnd_message.SET_NAME('AR','AR_GTA_CRMEMO_DUP_TITLE');
                    l_crmemo_dup_err_output(l_crmemo_dup_err_output.LAST):= fnd_message.GET;

                    gv_dup_title_flag := 'TRUE';
                 END IF;

                 l_index := lt_dup_record_tbl.FIRST;

                 WHILE l_index IS NOT NULL
                 LOOP
                   ln_ta_trx_id:=lt_dup_record_tbl(l_index).ra_trx_id;
                   lv_desc:=lt_dup_record_tbl(l_index).description;
                   ln_trx_org_id:=lt_dup_record_tbl(l_index).org_id;
                   ln_gta_trx_number := lt_dup_record_tbl(l_index).gta_trx_number;


                   /* condition is true while
                    * 1) description generated this time is duplicated with 'GENERATED' & 'COMPLETED'
                    *    transactions
                    * 2) there are more than one duplicated descriptions generated this time
                    *
                    */

                   IF ( p_GTA_trx_header.gta_trx_number <> ln_gta_trx_number AND
                        p_GTA_trx_header.description = lv_desc)
                   THEN

                     IF ( gv_desc_duplicat_flag = 'FALSE' )
                     THEN
                        gv_desc_duplicat_flag := 'TRUE';
                     END IF;

-- modified by Lv Xiao for bug#7644803 on 18-Dec-2008, begin
-------------------------------------------------------------------
/*
 * the message format is :
 * The description of credit memo &INVOICE_NUMBER1 in &ORG_NAME1
 * duplicates with credit memo &INVOICE_NUMBER2 in &ORG_NAME2
 */

                      SELECT hr.name
                        INTO ln_dup_org_name1
                        FROM hr_operating_units hr
                       WHERE hr.organization_id = p_GTA_trx_header.org_id;
                       --AND MO_GLOBAL.Check_Access(hr.organization_id) = 'Y'

                      fnd_message.SET_NAME('AR','AR_GTA_CRMEMO_DUP');
                      fnd_message.SET_TOKEN( TOKEN => 'INVOICE_NUMBER1'
                                          , VALUE => p_GTA_trx_header.gta_trx_number
                                          );
                      fnd_message.SET_TOKEN( TOKEN => 'ORG_NAME1'
                                          , VALUE => ln_dup_org_name1
                                          );

                      SELECT hr.name
                        INTO ln_dup_org_name2
                        FROM hr_operating_units hr
                       WHERE hr.organization_id = ln_trx_org_id;
                       --AND MO_GLOBAL.Check_Access(hr.organization_id) = 'Y'

                       --fnd_message.SET_NAME('AR','AR_GTA_CRMEMO_DUP');
                       fnd_message.SET_TOKEN( TOKEN => 'INVOICE_NUMBER2'
                                        , VALUE => ln_gta_trx_number
                                        );
                       fnd_message.SET_TOKEN( TOKEN => 'ORG_NAME2'
                                        , VALUE => ln_dup_org_name2
                                        );

                       l_crmemo_dup_err_output.EXTEND;
                       l_crmemo_dup_err_output(l_crmemo_dup_err_output.LAST):= fnd_message.GET;

-------------------------------------------------------------------
-- modified by Lv Xiao for bug#7644803 on 18-Dec-2008, end

                     END IF;   --(  p_GTA_trx_header.description = lv_desc)

                     l_index := lt_dup_record_tbl.NEXT(l_index);

                 END LOOP;
             END IF;  --lt_dup_record_tbl.COUNT > 0
         END IF; --( (p_GTA_trx_header.invoice_type <> '2') AND
               --( lv_trx_type = 'CM'))


----------------------------------------------------------------
--add by Lv Xiao for bug#7626503 on 11-Dec-2008, end

         Export_invoice( p_invoice_header_id =>l_gta_trx_header_id
                       , p_batch_number      =>p_batch_number
                       , x_output            =>l_current_output
                       , x_success           =>l_trx_export_success
                       , p_dup_record_tbl    =>lt_dup_record_tbl);

         --insert into proper sections
         CASE  l_trx_export_success   --succeeded section
            WHEN G_EXPORT_SUCC THEN
               i:=l_current_output.FIRST;
               WHILE i IS NOT NULL
               LOOP
                  l_succ_output.EXTEND;
                  l_succ_output(l_succ_output.LAST):=l_current_output(i);
                  i:=l_current_output.NEXT(i);
               END LOOP;

            WHEN G_EXPORT_EXCEED_ERROR THEN  --exceeded error section
               i:=l_current_output.FIRST;
               WHILE i IS NOT NULL
               LOOP
                  l_exceed_output.EXTEND;
                  l_exceed_output(l_exceed_output.LAST):=l_current_output(i);
                  i:=l_current_output.NEXT(i);
               END LOOP;

            WHEN G_EXPORT_TAXPAYERID_ERROR THEN --TAXPAYERID exceeded error section
               i:=l_current_output.FIRST;
               WHILE i IS NOT NULL
               LOOP
                  l_taxpayid_err_out.EXTEND;
                  l_taxpayid_err_out(l_taxpayid_err_out.LAST)
                                                        :=l_current_output(i);
                  i:=l_current_output.NEXT(i);
               END LOOP;

            WHEN G_EXPORT_CRMEMO_MISSING_ERROR THEN --CRMEMO_MISSING error section
               i:=l_current_output.FIRST;
               WHILE i IS NOT NULL
               LOOP
                  l_creddit_memo_err.EXTEND;
                  l_creddit_memo_err(l_creddit_memo_err.LAST)
                                                       :=l_current_output(i);
                  i:=l_current_output.NEXT(i);
               END LOOP;

--add by Lv Xiao for bug#7626503 on 9-DEC-2008, begin
--TODO more logic in the future.
--------------------------------------------------------------------------
            WHEN G_EXPORT_MISSING_PREFIX_ERROR THEN --MISSING_PREFIX_ERROR error section
              -- Modified by Allen Yang 28-Sep-2009 for bug 8981199
              ---------------------------------------------------------
              --NULL;
              fnd_message.SET_NAME('AR','AR_GTA_CRMEMO_MISSING_PREFIX');
              l_missing_prefix_output.EXTEND;
              l_missing_prefix_output(l_missing_prefix_output.LAST):= g_comment_delimiter||fnd_message.GET;
              i:=l_current_output.FIRST;
              WHILE i IS NOT NULL
              LOOP
                 l_missing_prefix_output.EXTEND;
                 l_missing_prefix_output(l_missing_prefix_output.LAST)
                                                       :=l_current_output(i);
                 i:=l_current_output.NEXT(i);
              END LOOP;
              ---------------------------------------------------------
            WHEN G_EXPORT_CRMEMO_DUP_ERROR THEN --CRMEMO_DUP_ERROR error section
              NULL;
--------------------------------------------------------------------------
--add by Lv Xiao for bug#7626503 on 9-DEC-2008, end
         END CASE;
      END LOOP;

      --no data found exception
      IF l_succ_output.COUNT=0
          AND l_exceed_output.COUNT=0
          AND l_taxpayid_err_out.COUNT=0
          AND l_creddit_memo_err.COUNT=0
--add by Lv Xiao for bug#7626503 on 9-DEC-2008, begin
------------------------------------------------------
          AND l_missing_prefix_output.COUNT=0
          AND l_crmemo_dup_err_output.COUNT=0
------------------------------------------------------
--add by Lv Xiao for bug#7626503 on 9-DEC-2008, end
      THEN
          fnd_message.SET_NAME('AR','AR_GTA_NO_DATA_FOUND');
          l_error_msg:=g_comment_delimiter||fnd_message.GET;
          put_line(l_error_msg);--Yao add for bug#8882568
          --put_line(l_error_msg||'..pls check the invoice type you selected');--Yao commented for bug#8882568
          RETURN;
      END IF;
      --write the output to flat file

      -- Get the export identity of export flat file
     fnd_message.SET_NAME( APPLICATION => 'AR'
                          , NAME =>        'AR_GTA_INVOICE_EXPORT'
                          );
     fnd_message.SET_TOKEN( TOKEN => 'MIDFIX'
                          , VALUE => g_export_delimiter
                          );

      l_str:=fnd_message.get;

      -- Put it out
      put_line(l_str);

     l_first_Inv:=FALSE;
     fnd_message.SET_NAME('AR','AR_GTA_FP_TAX_REG_NUMBER');
     fnd_message.SET_TOKEN( TOKEN => 'NUMBER'
                          , VALUE => l_header_rec_cur.fp_tax_registration_number
                          );

     put_line(g_comment_delimiter||fnd_message.GET);

      IF l_succ_output.COUNT > 0
      THEN
        i:=l_succ_output.FIRST;
        WHILE i IS NOT NULL
        LOOP
           put_line(l_succ_output(i));
           i:=l_succ_output.NEXT(i);
        END LOOP;
      END IF;


      IF l_exceed_output.COUNT>0
      THEN
         fnd_message.SET_NAME('AR','AR_GTA_EXCEED_LENGTH');
         l_error_msg:=g_comment_delimiter||fnd_message.GET;
         put_line(l_error_msg);

         i:=l_exceed_output.FIRST;
         WHILE i IS NOT NULL
         LOOP
             put_line(l_exceed_output(i));
             i:=l_exceed_output.NEXT(i);
         END LOOP;
      END IF;


      IF l_taxpayid_err_out.COUNT>0
      THEN
         fnd_message.SET_NAME('AR','AR_GTA_INVALID_LENGTH');
         l_error_msg:=g_comment_delimiter||fnd_message.GET;
         put_line(l_error_msg);


         i:=l_taxpayid_err_out.FIRST;
         WHILE i IS NOT NULL
         LOOP
             put_line(l_taxpayid_err_out(i));
             i:=l_taxpayid_err_out.NEXT(i);
         END LOOP;
      END IF;


      IF l_creddit_memo_err.COUNT>0
      THEN
         fnd_message.SET_NAME('AR','AR_GTA_CRMEMO_MISSING_GTINV');
         l_error_msg:=g_comment_delimiter||fnd_message.GET;
         put_line(l_error_msg);


         i:=l_creddit_memo_err.FIRST;
         WHILE i IS NOT NULL
         LOOP

             put_line(l_creddit_memo_err(i));
             i:=l_creddit_memo_err.NEXT(i);
         END LOOP;
      END IF;
--add by Lv Xiao on 9-Dec-2008 for bug#7626503, begin
-------------------------------------------------------------------
/*
 * output the miss_prefix & duplicated_description error message.
*/
      IF l_missing_prefix_output.COUNT>0
      THEN
         i:=l_missing_prefix_output.FIRST;
         WHILE i IS NOT NULL
         LOOP
             -- Modified by Allen Yang for bug 8981199 28-Sep-2009
             ----------------------------------------------------------
             --put_line(g_comment_delimiter||l_missing_prefix_output(i));
             put_line(l_missing_prefix_output(i));
             ----------------------------------------------------------
             i:=l_missing_prefix_output.NEXT(i);
         END LOOP;
      END IF;

      IF l_crmemo_dup_err_output.COUNT>0
      THEN
         i:=l_crmemo_dup_err_output.FIRST;
         WHILE i IS NOT NULL
         LOOP
             put_line(g_comment_delimiter||l_crmemo_dup_err_output(i));
             i:=l_crmemo_dup_err_output.NEXT(i);
         END LOOP;
      END IF;
-------------------------------------------------------------------
--add by Lv Xiao on 9-Dec-2008 for bug#7626503, end

  --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION

 WHEN OTHERS THEN
    IF(l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX || l_procedure_name ||'.OTHER_EXCEPTION '
                    , SQLCODE||SQLERRM);
    END IF;
    RAISE;

END Export_Invoices;

--==========================================================================
--  PROCEDURE NAME:
--
--    Check_Batch_Number                    Private
--
--  DESCRIPTION:
--
--      This procedure check whether the batch_number is available
--
--  PARAMETERS:
--      In:  p_org_id               Identifier of operating unit
--           p_invoke_point         indicate where invoice export
--                                  program :workbench/concurrent
--
--  In Out:  x_batch_number         The batch_number which will
--                                  write into GTA table
--    Out:   x_succ                 whether the procedure run normally
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--      05/12/05       Jogen Hu      Created
--===========================================================================
PROCEDURE Check_Batch_Number
( p_org_id                IN            NUMBER
, p_invoke_point          IN            VARCHAR2
, x_batch_number          IN OUT NOCOPY VARCHAR2
, x_succ                     OUT NOCOPY BOOLEAN
)
IS
l_procedure_name       VARCHAR2(30):='check_batch_number';
l_batch_numbering_flag VARCHAR2(1);
l_error_msg            VARCHAR2(1000);
l_rows_same_batch      NUMBER;
l_dbg_level            NUMBER              :=FND_LOG.G_Current_Runtime_Level;
l_proc_level           NUMBER              :=FND_LOG.Level_Procedure;

BEGIN
   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

          x_succ:=TRUE;
          BEGIN
              SELECT s.auto_batch_numbering_flag
                INTO l_batch_numbering_flag
                FROM ar_gta_system_parameters_all s
               WHERE s.org_id=P_ORG_ID;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_message.SET_NAME('AR','AR_GTA_SYS_CONFIG_MISSING');
                fnd_message.set_token(TOKEN => 'TAX_REGIS_NUMBER'
                                     ,VALUE => NULL
                                     );

                l_error_msg:=g_comment_delimiter||fnd_message.GET;
                put_line(l_error_msg);
                x_succ:=FALSE;
                RETURN;
          END;

          IF  l_batch_numbering_flag='A' --automatically
          THEN
              --put_line('aalog1:2--');
              IF p_invoke_point='CONC'   --concurrent
              THEN
                 x_batch_number:=ar_gta_batch_number_util.Next_Value
                                              ( p_org_id => P_ORG_ID);
              END IF;

          ELSIF x_batch_number IS NULL --manually
          THEN
              fnd_message.SET_NAME('AR','AR_GTA_BATCH_NUM_MISSING');
              l_error_msg:=g_comment_delimiter||fnd_message.GET;
              put_line(l_error_msg);
              x_succ:=FALSE;
              RETURN;

          ELSE --manually
              --Jogen Jun-12 2006, bug5351578
              --x_batch_number:=x_batch_number||to_char(SYSDATE,'YYMMDDhhMIss');
              x_batch_number:=x_batch_number||'-'||to_char(SYSDATE,'YYMMDDhhMIss');
              --Jogen Jun-12 2006, bug5351578

              SELECT COUNT(*)
                INTO l_rows_same_batch
                FROM ar_gta_trx_headers
               WHERE gta_batch_number=x_batch_number;

              IF l_rows_same_batch > 0
              THEN
                  fnd_message.SET_NAME('AR','AR_GTA_DUP_BATCHNUM');
                  l_error_msg:=g_comment_delimiter||fnd_message.GET;
                  put_line(l_error_msg);
                  x_succ:=FALSE;
                  RETURN;
              END IF;

          END IF;--l_batch_numbering_flag='A'

   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

END Check_Batch_Number;

--==========================================================================
--  PROCEDURE NAME:
--
--    Export_Invoices_From_Conc                    Public
--
--  DESCRIPTION:
--
--      This procedure will export GTA invoices to the flat file
--      Its output will be printed on concurrent output and will
--      be save as flat file by users.
--
--  PARAMETERS:
--      In:  p_org_id                  Identifier of operation unit
--           p_regeneration            New batch('N') or regeneration('Y')
--           p_transfer_rule_id        GTA transfer rule header ID
--           p_batch_number            Export batch number
--           p_customer_id_from_number AccountID against customer Number
--           p_customer_id_from_name   AccountID against customer Name
--           p_cust_id_from_taxpayer   AccountID against taxpayerid
--           p_ar_trx_num_from         AR transaction Number
--           p_ar_trx_num_to           AR transaction Number
--           p_ar_trx_date_from        AR transaction date
--           p_ar_trx_date_to          AR transaction date
--           p_ar_trx_gl_date_from     AR transaction GL date
--           p_ar_trx_gl_date_to       AR transaction GL date
--           p_ar_trx_batch_from       AR transaction batch name
--           p_ar_trx_batch_to         AR transaction batch name
--           p_trx_class               AR transaction class: INV, CM, DM
--           P_Batch_ID                GTA batch number
--           p_invoice_type_id         Invoice Type: A for All,0 for Special,2 for Common, 1 for Recycle VAT invoices  --added by Subba for R12.1
--
--     Out:
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--      05/12/05       Jogen Hu      Created
--      09/28/05       Jogen Hu      Add a parameter of
--                                   fisrt party registration number
--      01/02/08       Subba         Added new parameter and changed logic
--      09/12/08       Lv Xiao       Modified for bug#7626503
--===========================================================================

PROCEDURE Export_Invoices_From_Conc
( P_ORG_ID                  IN       NUMBER
, P_regeneration            IN       VARCHAR2
, p_FP_Tax_reg_Number       IN       VARCHAR2
, P_transfer_rule_id        IN       NUMBER
, P_Batch_Number            IN       VARCHAR2
, P_Customer_id_from_Number IN       NUMBER
, P_Customer_id_FROM_Name   IN       NUMBER
, P_cust_id_from_Taxpayer   IN       NUMBER
, P_AR_Trx_Num_From         IN       VARCHAR2
, P_AR_Trx_Num_To           IN       VARCHAR2
, P_AR_Trx_Date_From        IN       DATE
, P_AR_Trx_Date_To          IN       DATE
, P_AR_Trx_GL_Date_From     IN       DATE
, P_AR_Trx_GL_Date_To       IN       DATE
, P_AR_Trx_Batch_From       IN       VARCHAR2
, P_AR_Trx_Batch_To         IN       VARCHAR2
, P_Trx_Class               IN       VARCHAR2
, P_Batch_ID                IN       VARCHAR2
, P_Invoice_Type_ID         IN       VARCHAR2    --added by subba for R12.1
)
IS
l_procedure_name      VARCHAR2(30):='export_Invoices_from_Conc';
l_Customer_id         NUMBER;
l_cur_header          c_trx_header_id_type;
l_AR_Trx_Num_From     Ra_Customer_Trx_All.Trx_Number%TYPE
                                            :=nvl(P_AR_Trx_Num_From,' ');
l_AR_Trx_Num_To       Ra_Customer_Trx_All.Trx_Number%TYPE
                                       :=nvl(p_AR_Trx_Num_To,lpad('z',20,'z'));

l_AR_Trx_Date_From    Ra_Customer_Trx_All.Trx_Date%TYPE
                  :=nvl(P_AR_Trx_Date_From,to_date('1900/01/01','RRRR/MM/DD'));
l_AR_Trx_Date_To      Ra_Customer_Trx_All.Trx_Date%TYPE
                    :=nvl(P_AR_Trx_Date_To,to_date('4000/12/12','RRRR/MM/DD'));

l_AR_Trx_GL_Date_From RA_CUST_TRX_LINE_GL_DIST_all.Gl_Date%TYPE
               :=nvl(p_AR_Trx_GL_Date_From,to_date('1900/01/01','RRRR/MM/DD'));
l_AR_Trx_GL_Date_To   RA_CUST_TRX_LINE_GL_DIST_all.Gl_Date%TYPE
                 :=nvl(p_AR_Trx_GL_Date_To,to_date('4000/12/12','RRRR/MM/DD'));

l_AR_Trx_Batch_From   ra_batches_all.name%TYPE  :=nvl(p_AR_Trx_Batch_From,' ');
l_AR_Trx_Batch_to     ra_batches_all.name%TYPE
                                     :=nvl(p_AR_Trx_Batch_to,lpad('z',50,'z'));
-------------------------------------------------------------------------------
l_cur_draft_dup crmemo_dup_cur_TYPE;   --get draft crmemo with duplicate description
-------------------------------------------------------------------------------

l_error_msg           VARCHAR2(1000);

l_batch_number        AR_Gta_Trx_Headers_All.Gta_Batch_Number%TYPE:=p_batch_number;
l_batch_number_ok     BOOLEAN;
l_dbg_level           NUMBER              :=FND_LOG.G_Current_Runtime_Level;
l_proc_level          NUMBER              :=FND_LOG.Level_Procedure;
l_invoice_type_check  VARCHAR2(1);   --added for invoice_type condition by Subba.
BEGIN

   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

      IF P_regeneration='N'
      THEN
          check_batch_number( P_ORG_ID      => P_ORG_ID
                            , p_invoke_point =>'CONC'
                            , x_batch_number=> l_batch_number
                            , x_succ        => l_batch_number_ok
                            );

          IF NOT l_batch_number_ok
          THEN
              RETURN;
          END IF;

          --compare the customer id from 3 different source
          IF P_Customer_id_from_Number IS NOT NULL
            AND (P_Customer_id_from_Number <>
                      nvl(P_Customer_id_FROM_Name,P_Customer_id_from_Number)
             OR  P_Customer_id_from_Number <>
                      nvl(P_cust_id_from_Taxpayer,P_Customer_id_from_Number)
                )
          THEN
              fnd_message.SET_NAME('AR','AR_GTA_NO_DATA_FOUND');
              l_error_msg:=g_comment_delimiter||fnd_message.GET;
              put_line(l_error_msg);
              RETURN;

          ELSIF P_Customer_id_from_Number IS NOT NULL
  --P_Customer_id_from_Number=P_Customer_id_FROM_Name=P_cust_id_from_Taxpayer
          THEN
              l_Customer_id:=P_Customer_id_from_Number;

          ELSIF  P_Customer_id_FROM_Name IS NOT NULL
             AND P_Customer_id_FROM_Name <>
                          nvl(P_cust_id_from_Taxpayer,P_Customer_id_FROM_Name)
          THEN
              fnd_message.SET_NAME('AR','AR_GTA_NO_DATA_FOUND');
              l_error_msg:=g_comment_delimiter||fnd_message.GET;
              put_line(l_error_msg);
              RETURN;
          ELSE--   P_Customer_id_FROM_Name is null
              --or P_Customer_id_FROM_Name=
              --       nvl(P_Customer_id_FROM_Name,P_Customer_id_FROM_Name
              l_Customer_id:=nvl(P_cust_id_from_Taxpayer,P_Customer_id_FROM_Name);

          END IF;  --P_Customer_id_from_Number IS NOT NULL
                   --AND (P_Customer_id_from_Number<>
                   --    nvl(P_Customer_id_FROM_Name,P_Customer_id_from_Number)
                   --OR  P_Customer_id_from_Number<>
                   --    nvl(P_cust_id_from_Taxpayer,P_Customer_id_from_Number)


          IF P_Invoice_Type_ID <>'A' THEN   --if user selects a particular invoice_type
            OPEN l_cur_header FOR
            SELECT
                  h.*
            FROM AR_GTA_TRX_HEADERS h
               , ra_customer_trx_all ar
               , Ra_Cust_Trx_Types_all ctt
               , RA_CUST_TRX_LINE_GL_DIST_all gd
               , ra_batches_all b
          WHERE h.org_id              = p_ORG_ID
          AND ar.CUST_TRX_TYPE_ID   = ctt.CUST_TRX_TYPE_ID
          AND ctt.ORG_ID            = p_org_id
          AND h.fp_tax_registration_number = p_FP_Tax_reg_Number
          AND h.RA_TRX_ID           = ar.CUSTOMER_TRX_ID
          AND GD.CUSTOMER_TRX_ID    = h.RA_TRX_ID
          AND GD.ACCOUNT_CLASS      = 'REC'
          AND GD.LATEST_REC_FLAG    = 'Y'
          AND gd.Org_Id             = p_org_id
          AND ar.BATCH_ID           = b.batch_id(+)
          AND ar.BILL_TO_CUSTOMER_ID=nvl(l_customer_id,ar.BILL_TO_CUSTOMER_ID)
          AND h.rule_header_id      = nvl(p_transfer_rule_id,h.rule_header_id)
          AND ar.trx_number BETWEEN l_AR_Trx_Num_From
                                AND l_AR_Trx_Num_To
          AND trunc(ar.trx_date,'DDD')   BETWEEN l_AR_Trx_Date_From --jogen Mar-22, 2006
                                AND l_AR_Trx_Date_To                -- bug 5107043
          AND trunc(gd.GL_DATE,'DDD')    BETWEEN l_AR_Trx_GL_Date_From
                                AND l_AR_Trx_GL_Date_To             --jogen Mar-22, 2006
          AND nvl(b.name,' ') BETWEEN l_AR_Trx_Batch_From
                                     AND l_AR_Trx_Batch_To
          AND ctt.TYPE              = nvl(p_Trx_Class,ctt.type)
          AND h.latest_version_flag = 'Y'
          AND h.SOURCE              = 'AR'
          AND h.status              = 'DRAFT'
    AND h.invoice_type        = P_Invoice_Type_ID;       --added by subba.

--add by Lv Xiao for bug#7626503 on 11-Dec-2008, begin
-------------------------------------------------------------------------------
/*
 * Following cursor will fetch data when the package is called from concurrent.
 * For credit memo transaction referenced to Special VAT invoice and Recycle
 * VAT invoice, the cursor fetches all the duplicated description among 'DRAFT'
 * GTA Invoice need to generate this time and 'GENERATED', 'COMPLETED' GTA
 * Invoices.
 */
       OPEN l_cur_draft_dup FOR
     SELECT JGTHA.ra_trx_id
          , JGTHA.description
          , JGTHA.org_id
          , JGTHA.gta_trx_number
       FROM AR_GTA_TRX_HEADERS_ALL JGTHA
      WHERE Get_Trx_Class(JGTHA.org_id, JGTHA.ra_trx_id) = 'CM'
        AND JGTHA.status IN ('GENERATED', 'COMPLETED')

        AND JGTHA.description IN /*( SELECT h.description
                                     FROM AR_GTA_TRX_HEADERS h
                                            , ra_customer_trx_all ar
                                            , Ra_Cust_Trx_Types_all ctt
                                            , RA_CUST_TRX_LINE_GL_DIST_all gd
                                            , ra_batches_all b
                                    WHERE  ( h.org_id              = p_ORG_ID
                                          AND ar.CUST_TRX_TYPE_ID   = ctt.CUST_TRX_TYPE_ID
                                          AND ctt.ORG_ID            = p_org_id
                                          AND h.fp_tax_registration_number = p_FP_Tax_reg_Number
                                          AND h.RA_TRX_ID           = ar.CUSTOMER_TRX_ID
                                          AND GD.CUSTOMER_TRX_ID    = h.RA_TRX_ID
                                          AND GD.ACCOUNT_CLASS      = 'REC'
                                          AND GD.LATEST_REC_FLAG    = 'Y'
                                          AND gd.Org_Id             = p_org_id
                                          AND ar.BATCH_ID           = b.batch_id
                                          AND h.BILL_TO_CUSTOMER_ID=nvl(l_customer_id,h.BILL_TO_CUSTOMER_ID)
                                          AND h.rule_header_id      = nvl(p_transfer_rule_id,h.rule_header_id)
                                          AND h.ra_trx_number BETWEEN l_AR_Trx_Num_From
                                                                  AND l_AR_Trx_Num_To
                                          AND trunc(h.transaction_date,'DDD')   BETWEEN l_AR_Trx_Date_From
                                                                  AND l_AR_Trx_Date_To
                                          AND trunc(h.ra_gl_date,'DDD')    BETWEEN l_AR_Trx_GL_Date_From
                                                                  AND l_AR_Trx_GL_Date_To
                                          AND nvl(b.name,' ') BETWEEN l_AR_Trx_Batch_From
                                                                  AND l_AR_Trx_Batch_To
                                          AND ctt.TYPE              = nvl(p_Trx_Class,ctt.type)
                                          AND h.latest_version_flag = 'Y'
                                          AND h.SOURCE              = 'AR'
                                          AND h.status              = 'DRAFT'
                                          AND h.invoice_type        = P_Invoice_Type_ID)
                                         OR ( h.status IN ('GENERATED', 'COMPLETED'))

                                    GROUP BY h.description
                                    HAVING COUNT(h.description) > 1)*/

                                    ( SELECT DISTINCT description
                                 FROM (SELECT  description
                                         FROM AR_GTA_TRX_HEADERS JGTH
                                        WHERE JGTH.status IN ('GENERATED', 'COMPLETED')
                                    INTERSECT
                                       SELECT h.description
                                         FROM AR_GTA_TRX_HEADERS h
                                            , ra_customer_trx_all ar
                                            , Ra_Cust_Trx_Types_all ctt
                                            , RA_CUST_TRX_LINE_GL_DIST_all gd
                                            , ra_batches_all b
                                        WHERE h.org_id              = p_ORG_ID
                                          AND ar.CUST_TRX_TYPE_ID   = ctt.CUST_TRX_TYPE_ID
                                          AND ctt.ORG_ID            = p_org_id

                                          AND h.RA_TRX_ID           = ar.CUSTOMER_TRX_ID
                                          AND GD.CUSTOMER_TRX_ID    = h.RA_TRX_ID
                                          AND GD.ACCOUNT_CLASS      = 'REC'
                                          AND GD.LATEST_REC_FLAG    = 'Y'
                                          AND gd.Org_Id             = p_org_id
                                          AND ar.BATCH_ID           = b.batch_id(+)

                                          --AND ar.BILL_TO_CUSTOMER_ID=nvl(l_customer_id,ar.BILL_TO_CUSTOMER_ID)
                                          AND h.BILL_TO_CUSTOMER_ID=nvl(l_customer_id,h.BILL_TO_CUSTOMER_ID)

                                          AND h.rule_header_id      = nvl(p_transfer_rule_id,h.rule_header_id)

                                          AND h.fp_tax_registration_number = p_FP_Tax_reg_Number
                                          --AND ar.trx_number
                                          AND h.ra_trx_number
                                                                  BETWEEN l_AR_Trx_Num_From
                                                                  AND l_AR_Trx_Num_To

                                          --AND trunc(ar.trx_date,'DDD')
                                          --AND trunc(h.transaction_date,'DDD')
                                          AND h.transaction_date
                                                                  BETWEEN l_AR_Trx_Date_From
                                                                  AND l_AR_Trx_Date_To
                                          --AND trunc(gd.GL_DATE,'DDD')
                                          --AND trunc(h.RA_GL_DATE,'DDD')
                                          AND h.RA_GL_DATE
                                                                  BETWEEN l_AR_Trx_GL_Date_From
                                                                  AND l_AR_Trx_GL_Date_To
                                          AND nvl(b.name,' ') BETWEEN l_AR_Trx_Batch_From
                                                                  AND l_AR_Trx_Batch_To
                                          AND ctt.TYPE              = nvl(p_Trx_Class,ctt.type)
                                          AND h.latest_version_flag = 'Y'
                                          AND h.SOURCE              = 'AR'
                                          AND h.status              = 'DRAFT'
                                          AND h.invoice_type        = P_Invoice_Type_ID))


     UNION ALL

     SELECT JGTHA.ra_trx_id
          , JGTHA.description
          , JGTHA.org_id
          , JGTHA.gta_trx_number
       FROM AR_GTA_TRX_HEADERS_ALL JGTHA
          , ra_customer_trx_all ar
          , Ra_Cust_Trx_Types_all ctt
          , RA_CUST_TRX_LINE_GL_DIST_all gd
          , ra_batches_all b
      WHERE Get_Trx_Class(JGTHA.org_id, JGTHA.ra_trx_id) = 'CM'
        AND JGTHA.status = 'DRAFT'

        AND JGTHA.org_id              = p_ORG_ID
        AND ar.CUST_TRX_TYPE_ID   = ctt.CUST_TRX_TYPE_ID
        AND ctt.ORG_ID            = p_org_id

        AND JGTHA.RA_TRX_ID           = ar.CUSTOMER_TRX_ID
        AND GD.CUSTOMER_TRX_ID    = JGTHA.RA_TRX_ID
        AND GD.ACCOUNT_CLASS      = 'REC'
        AND GD.LATEST_REC_FLAG    = 'Y'
        AND gd.Org_Id             = p_org_id
        AND ar.BATCH_ID           = b.batch_id(+)

        --AND ar.BILL_TO_CUSTOMER_ID=nvl(l_customer_id,ar.BILL_TO_CUSTOMER_ID)
        AND JGTHA.BILL_TO_CUSTOMER_ID=nvl(l_customer_id,JGTHA.BILL_TO_CUSTOMER_ID)

        AND JGTHA.rule_header_id      = nvl(p_transfer_rule_id,JGTHA.rule_header_id)
        AND JGTHA.fp_tax_registration_number = p_FP_Tax_reg_Number

        --AND ar.trx_number
        AND JGTHA.ra_trx_number
                                       BETWEEN l_AR_Trx_Num_From
                                       AND l_AR_Trx_Num_To
        --AND trunc(ar.trx_date,'DDD')
        --AND trunc(JGTHA.transaction_date,'DDD')
        AND JGTHA.transaction_date
                                       BETWEEN l_AR_Trx_Date_From
                                       AND l_AR_Trx_Date_To
        --AND trunc(gd.GL_DATE,'DDD')
        --AND trunc(JGTHA.RA_GL_DATE,'DDD')
        AND JGTHA.RA_GL_DATE
                                       BETWEEN l_AR_Trx_GL_Date_From
                                       AND l_AR_Trx_GL_Date_To
        AND nvl(b.name,' ') BETWEEN l_AR_Trx_Batch_From
                                       AND l_AR_Trx_Batch_To
        AND ctt.TYPE              = nvl(p_Trx_Class,ctt.type)
        AND JGTHA.latest_version_flag = 'Y'
        AND JGTHA.SOURCE              = 'AR'
        AND JGTHA.invoice_type        = P_Invoice_Type_ID

        AND JGTHA.description IN /*( SELECT h.description
                                     FROM AR_GTA_TRX_HEADERS h
                                            , ra_customer_trx_all ar
                                            , Ra_Cust_Trx_Types_all ctt
                                            , RA_CUST_TRX_LINE_GL_DIST_all gd
                                            , ra_batches_all b
                                    WHERE ( h.org_id              = p_ORG_ID
                                          AND ar.CUST_TRX_TYPE_ID   = ctt.CUST_TRX_TYPE_ID
                                          AND ctt.ORG_ID            = p_org_id
                                          AND h.fp_tax_registration_number = p_FP_Tax_reg_Number
                                          AND h.RA_TRX_ID           = ar.CUSTOMER_TRX_ID
                                          AND GD.CUSTOMER_TRX_ID    = h.RA_TRX_ID
                                          AND GD.ACCOUNT_CLASS      = 'REC'
                                          AND GD.LATEST_REC_FLAG    = 'Y'
                                          AND gd.Org_Id             = p_org_id
                                          AND ar.BATCH_ID           = b.batch_id
                                          AND h.BILL_TO_CUSTOMER_ID=nvl(l_customer_id,h.BILL_TO_CUSTOMER_ID)
                                          AND h.rule_header_id      = nvl(p_transfer_rule_id,h.rule_header_id)
                                          AND h.ra_trx_number BETWEEN l_AR_Trx_Num_From
                                                                  AND l_AR_Trx_Num_To
                                          AND trunc(h.transaction_date,'DDD')   BETWEEN l_AR_Trx_Date_From
                                                                  AND l_AR_Trx_Date_To
                                          AND trunc(h.ra_gl_date,'DDD')    BETWEEN l_AR_Trx_GL_Date_From
                                                                  AND l_AR_Trx_GL_Date_To
                                          AND nvl(b.name,' ') BETWEEN l_AR_Trx_Batch_From
                                                                  AND l_AR_Trx_Batch_To
                                          AND ctt.TYPE              = nvl(p_Trx_Class,ctt.type)
                                          AND h.latest_version_flag = 'Y'
                                          AND h.SOURCE              = 'AR'
                                          AND h.status              = 'DRAFT'
                                          AND h.invoice_type        = P_Invoice_Type_ID)

                                          OR ( h.status IN ('GENERATED', 'COMPLETED') )
                                    GROUP BY h.description
                                    HAVING COUNT(h.description) > 1)*/

                                    ( SELECT DISTINCT description
                                 FROM (SELECT  description
                                         FROM AR_GTA_TRX_HEADERS JGTH
                                        WHERE JGTH.status IN ('GENERATED', 'COMPLETED')
                                    INTERSECT
                                       SELECT h.description
                                         FROM AR_GTA_TRX_HEADERS h
                                            , ra_customer_trx_all ar
                                            , Ra_Cust_Trx_Types_all ctt
                                            , RA_CUST_TRX_LINE_GL_DIST_all gd
                                            , ra_batches_all b
                                        WHERE h.org_id              = p_ORG_ID
                                          AND ar.CUST_TRX_TYPE_ID   = ctt.CUST_TRX_TYPE_ID
                                          AND ctt.ORG_ID            = p_org_id

                                          AND h.RA_TRX_ID           = ar.CUSTOMER_TRX_ID
                                          AND GD.CUSTOMER_TRX_ID    = h.RA_TRX_ID
                                          AND GD.ACCOUNT_CLASS      = 'REC'
                                          AND GD.LATEST_REC_FLAG    = 'Y'
                                          AND gd.Org_Id             = p_org_id
                                          AND ar.BATCH_ID           = b.batch_id(+)

                                          --AND ar.BILL_TO_CUSTOMER_ID=nvl(l_customer_id,ar.BILL_TO_CUSTOMER_ID)
                                          AND h.BILL_TO_CUSTOMER_ID=nvl(l_customer_id,h.BILL_TO_CUSTOMER_ID)

                                          AND h.rule_header_id      = nvl(p_transfer_rule_id,h.rule_header_id)

                                          AND h.fp_tax_registration_number = p_FP_Tax_reg_Number
                                          --AND ar.trx_number
                                          AND h.ra_trx_number
                                                                  BETWEEN l_AR_Trx_Num_From
                                                                  AND l_AR_Trx_Num_To

                                          --AND trunc(ar.trx_date,'DDD')
                                          --AND trunc(h.transaction_date,'DDD')
                                          AND h.transaction_date
                                                                  BETWEEN l_AR_Trx_Date_From
                                                                  AND l_AR_Trx_Date_To
                                          --AND trunc(gd.GL_DATE,'DDD')
                                          --AND trunc(h.RA_GL_DATE,'DDD')
                                          AND h.RA_GL_DATE
                                                                  BETWEEN l_AR_Trx_GL_Date_From
                                                                  AND l_AR_Trx_GL_Date_To
                                          AND nvl(b.name,' ') BETWEEN l_AR_Trx_Batch_From
                                                                  AND l_AR_Trx_Batch_To
                                          AND ctt.TYPE              = nvl(p_Trx_Class,ctt.type)
                                          AND h.latest_version_flag = 'Y'
                                          AND h.SOURCE              = 'AR'
                                          AND h.status              = 'DRAFT'
                                          AND h.invoice_type        = P_Invoice_Type_ID));

        ELSE   --user selects 'All Invoices'
          NULL;

/*
 * following code is commented since the concurrent parameter: invoice type
 * can't be selected as 'ALL' in this change.
 */

/*      OPEN l_cur_header FOR
            SELECT
                  h.*
            FROM AR_GTA_TRX_HEADERS h
               , ra_customer_trx_all ar
               , Ra_Cust_Trx_Types_all ctt
               , RA_CUST_TRX_LINE_GL_DIST_all gd
               , ra_batches_all b
          WHERE h.org_id              = p_ORG_ID
          AND ar.CUST_TRX_TYPE_ID   = ctt.CUST_TRX_TYPE_ID
          AND ctt.ORG_ID            = p_org_id
          AND h.fp_tax_registration_number = p_FP_Tax_reg_Number
          AND h.RA_TRX_ID           = ar.CUSTOMER_TRX_ID
          AND GD.CUSTOMER_TRX_ID    = h.RA_TRX_ID
          AND GD.ACCOUNT_CLASS      = 'REC'
          AND GD.LATEST_REC_FLAG    = 'Y'
          AND gd.Org_Id             = p_org_id
          AND ar.BATCH_ID           = b.batch_id(+)
          AND ar.BILL_TO_CUSTOMER_ID=nvl(l_customer_id,ar.BILL_TO_CUSTOMER_ID)
          AND h.rule_header_id      = nvl(p_transfer_rule_id,h.rule_header_id)
          AND ar.trx_number BETWEEN l_AR_Trx_Num_From
                                AND l_AR_Trx_Num_To
          AND trunc(ar.trx_date,'DDD')   BETWEEN l_AR_Trx_Date_From --jogen Mar-22, 2006
                                AND l_AR_Trx_Date_To                -- bug 5107043
          AND trunc(gd.GL_DATE,'DDD')    BETWEEN l_AR_Trx_GL_Date_From
                                AND l_AR_Trx_GL_Date_To             --jogen Mar-22, 2006
          AND nvl(b.name,' ') BETWEEN l_AR_Trx_Batch_From
                                     AND l_AR_Trx_Batch_To
          AND ctt.TYPE              = nvl(p_Trx_Class,ctt.type)
          AND h.latest_version_flag = 'Y'
          AND h.SOURCE              = 'AR'
          AND h.status              = 'DRAFT';  */
         /* AND ar.trx_date   BETWEEN l_AR_Trx_Date_From
                                AND l_AR_Trx_Date_To
          AND gd.GL_DATE    BETWEEN l_AR_Trx_GL_Date_From
                                AND l_AR_Trx_GL_Date_To */
        END IF; /*  P_Invoice_Type_ID <>'A'*/      --added by subba.
-------------------------------------------------------------------------------
--add by Lv Xiao for bug#7626503 on 11-Dec-2008, end

        export_Invoices(l_cur_header,l_batch_number, NULL, NULL, l_cur_draft_dup);
          CLOSE l_cur_draft_dup;

      ELSE --P_regeneration<>'N'


         OPEN l_cur_header FOR
         SELECT *
          FROM AR_GTA_TRX_HEADERS
          WHERE Gta_Batch_Number=P_Batch_ID
            AND status='GENERATED';

         export_Invoices(l_cur_header,P_Batch_ID, NULL, NULL);

      END IF; --P_regeneration='N'


      CLOSE l_cur_header;

   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION

 WHEN OTHERS THEN
    IF(l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX || l_procedure_name || '.OTHER_EXCEPTION'
                    , SQLCODE||SQLERRM);
    END IF;
    RAISE;
END Export_Invoices_From_Conc;

--==========================================================================
--  PROCEDURE NAME:
--
--    Export_Invoices_From_Workbench                     Public
--
--  DESCRIPTION:
--
--      This procedure export VAT invoices from GTA to flat file
--      and is invoked in workbench.
--
--  PARAMETERS:
--      In:  p_org_id            Identifier of operating unit
--           p_generator_id      Indicate which need export(choose in workbench)
--           P_Batch_ID          export batch number
--
--     Out:
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--      05/12/05       Jogen Hu      Created
--      09/12/08       Lv Xiao       Modified for bug#7626503
--                                   Validate format of VAT Invoice Number
--                                   Check the
--      09/01/2009     Yao Zhang     Modified for bug 7673309
--===========================================================================
PROCEDURE Export_Invoices_From_Workbench
( p_org_id                 IN       NUMBER
, p_generator_ID           IN       NUMBER
, P_Batch_ID               IN       VARCHAR2
)
IS
l_procedure_name VARCHAR2(40):='export_Invoices_from_Workbench';
l_cur_header     c_trx_header_id_type;

--add by Lv Xiao for bug#7626503 on 11-Dec-2008, begin
-----------------------------------------------------------------------------
l_cur_draft_dup    crmemo_dup_cur_TYPE;--get draft crmemo with duplicate description
-------------------------------------------------------------------------------
--add by Lv Xiao for bug#7626503 on 11-Dec-2008, end

l_batch_number        AR_Gta_Trx_Headers_All.Gta_Batch_Number%TYPE:=P_Batch_ID;
l_batch_number_ok     BOOLEAN;
l_dbg_level           NUMBER              :=FND_LOG.G_Current_Runtime_Level;
l_proc_level          NUMBER              :=FND_LOG.Level_Procedure;
BEGIN

   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

      check_batch_number( P_ORG_ID      => P_ORG_ID
                        , p_invoke_point=> 'WBCH'
                        , x_batch_number=> l_batch_number
                        , x_succ        => l_batch_number_ok
                        );

      IF NOT l_batch_number_ok
      THEN
          RETURN;
      END IF;


      OPEN l_cur_header FOR
      SELECT *
       FROM AR_GTA_TRX_HEADERS
      WHERE Generator_Id=p_generator_ID
        AND status='DRAFT';

--add by Lv Xiao for bug#7626503 on 11-Dec-2008, begin
-----------------------------------------------------------------------------
/*
 * Following cursor will fetch data when the package is called from workbench.
 * For credit memo transaction referenced to Special VAT invoice and Recycle
 * VAT invoice, the cursor will fetch all the duplicated descriptions among
 * 'DRAFT' GTA Invoices need to generate from this concurrent call and
 * 'GENERATED' and 'COMPLETED' GTA Invoices.
 */
       OPEN l_cur_draft_dup FOR
     SELECT JGTHA.ra_trx_id
          , JGTHA.description
          , JGTHA.org_id
          , JGTHA.gta_trx_number
       FROM AR_GTA_TRX_HEADERS_ALL JGTHA
      WHERE Get_Trx_Class(JGTHA.org_id, JGTHA.ra_trx_id) = 'CM'
        AND JGTHA.Invoice_Type<>'2'--yao zhang add for bug 7673309
        AND JGTHA.source='AR'--yao zhang add for bug7673309
        AND JGTHA.status IN ('GENERATED', 'COMPLETED')
        AND JGTHA.org_id = p_org_id

--modified by Lv Xiao for bug#7644803 on 16-Dec-08, begin
-------------------------------------------------------------------
/*        AND JGTHA.description IN ( SELECT DISTINCT description
                                     FROM (SELECT  description
                                             FROM AR_GTA_TRX_HEADERS_ALL JGTH
                                            WHERE JGTH.status IN ('GENERATED', 'COMPLETED')
                                        INTERSECT
                                           SELECT  description
                                             FROM AR_GTA_TRX_HEADERS_ALL
                                            WHERE Generator_Id=p_generator_ID
                                              AND status='DRAFT') )*/


        AND JGTHA.description IN ( SELECT description
                                     FROM AR_GTA_TRX_HEADERS JGTH
                                    WHERE (( status = 'DRAFT'
                                        AND generator_id = p_generator_ID )
                                       OR status IN ('GENERATED', 'COMPLETED'))
                                       AND Invoice_Type<>'2'--yao zhang add for bug 7673309
                                       AND source='AR'--yao zhang add for bug 7673309
                                    GROUP BY description
                                    HAVING COUNT(description) > 1)

      UNION ALL

     SELECT JGTHA.ra_trx_id
          , JGTHA.description
          , JGTHA.org_id
          , JGTHA.gta_trx_number
       FROM AR_GTA_TRX_HEADERS_ALL JGTHA
      WHERE Get_Trx_Class(JGTHA.org_id, JGTHA.ra_trx_id) = 'CM'
        AND JGTHA.Invoice_Type<>'2'--Yao Zhang add for bug 7673309
        AND JGTHA.source='AR'--Yao Zhang add for bug 7673309
        AND JGTHA.status = 'DRAFT'
        AND JGTHA.generator_id = p_generator_ID
        AND JGTHA.org_id = p_org_id
/*        AND JGTHA.description IN ( SELECT DISTINCT description
                                     FROM (SELECT  description
                                             FROM AR_GTA_TRX_HEADERS_ALL JGTH
                                            WHERE JGTH.status IN ('GENERATED', 'COMPLETED')
                                        INTERSECT
                                           SELECT  description
                                             FROM AR_GTA_TRX_HEADERS_ALL
                                            WHERE Generator_Id=p_generator_ID
                                              AND status='DRAFT') ) ;*/


        AND JGTHA.description IN ( SELECT description
                                     FROM AR_GTA_TRX_HEADERS JGTH
                                    WHERE (( status = 'DRAFT'
                                        AND generator_id = p_generator_ID )
                                       OR status IN ('GENERATED', 'COMPLETED'))
                                       AND Invoice_Type<>'2'--Yao Zhang add for bug7673309
                                       AND source='AR'--Yao Zhang add for bug7673309
                                    GROUP BY description
                                    HAVING COUNT(description) > 1);

-------------------------------------------------------------------
--modified by Lv Xiao for bug#7644803 on 16-Dec-08, end

      --export_Invoices(l_cur_header,l_batch_number);
      export_Invoices(l_cur_header
                    , l_batch_number
                    , p_generator_id
                    , p_org_id
                    , l_cur_draft_dup);

      CLOSE l_cur_draft_dup;
      CLOSE l_cur_header;
-----------------------------------------------------------------------------
--add by Lv Xiao for bug#7626503 on 11-Dec-2008, end


   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

--FND_FILE.Put_Line(FND_FILE.Log, 'export_Invoices_from_Workbench. end');
EXCEPTION

 WHEN OTHERS THEN
    IF(l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX || l_procedure_name || '.OTHER_EXCEPTION '
                    , SQLCODE||SQLERRM);
    END IF;

    RAISE;
END Export_Invoices_From_Workbench;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Trx_Class                     Public
--
--  DESCRIPTION:
--
--      This procedure get transaction class
--
--  PARAMETERS:
--      In:  p_GTA_org_id       GTA transaction org id
--      In:  p_GTA_trx_id       GTA transaction id
--
--     Out:
--  Return:  VARCHAR2;
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--      09/12/08       Lv Xiao      Created
--===========================================================================
FUNCTION Get_Trx_Class
( p_GTA_org_id           IN       NUMBER
, p_GTA_trx_id           IN       NUMBER
)
RETURN VARCHAR2
IS

lv_class_type        VARCHAR2(30);

l_procedure_name     VARCHAR2(50)  :='Get_Trx_Class';
l_dbg_level          NUMBER        :=FND_LOG.G_Current_Runtime_Level;
l_proc_level         NUMBER        :=FND_LOG.Level_Procedure;


BEGIN

   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

  SELECT DISTINCT RCTT.type
    INTO lv_class_type
    FROM RA_CUST_TRX_TYPES_ALL RCTT
       , RA_CUSTOMER_TRX_ALL   RCT
       , AR_GTA_TRX_HEADERS_ALL JGTH
   WHERE RCTT.cust_trx_type_id = RCT.cust_trx_type_id
     AND JGTH.source = 'AR'
     AND RCTT.org_id = p_GTA_org_id
     AND RCT.customer_trx_id = p_GTA_trx_id
     AND JGTH.ra_trx_id = p_GTA_trx_id;
   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

  RETURN lv_class_type;

END Get_Trx_Class;


--==========================================================================
--  FUNCTION NAME:
--
--    Check_Header                 Public
--
--  DESCRIPTION:
--
--      This procedure check whether the columns of export data
--      exceeding Golden Tax required length.
--
--  PARAMETERS:
--      In:    p_gta_trx_header      GTA transaction header
--     Out:
--  Return:    PLS_INTEGER
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--      05/12/05       Jogen Hu      Created
--      24/11/2008     Brian Zhao    Modified for bug 7590613
--      09/12/2008     Lv Xiao       Modified for bug#7626503
--      26/12/2008     Yao Zhang     Modified for bug#7670310
--===========================================================================
FUNCTION Check_Header
( p_gta_trx_header         IN       AR_GTA_TRX_UTIL.TRX_HEADER_REC_TYPE
)
RETURN PLS_INTEGER
IS

l_cm_delimiter1   VARCHAR2(100);

l_cm_delimiter2   VARCHAR2(100);

l_procedure_name  VARCHAR2(50)        :='Check_Header';
l_dbg_level       NUMBER              :=FND_LOG.G_Current_Runtime_Level;
l_proc_level      NUMBER              :=FND_LOG.Level_Procedure;
l_trx_class       VARCHAR2(20);         --added by yao Zhang for bug 7670310
BEGIN

   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level )



  IF    length(p_GTA_trx_header.bill_to_customer_name)>100
     OR length(p_GTA_trx_header.customer_address_phone)>80
     OR length(p_GTA_trx_header.bank_account_name_number)>80
     OR length(p_GTA_trx_header.gta_trx_number)>20
     OR length(p_GTA_trx_header.description)>160
  THEN
     RETURN G_EXPORT_EXCEED_ERROR ;
  END IF;
            --modified by subba to add condition for common invoice type in R12.1

/*  IF ( (p_GTA_trx_header.invoice_type <> '2') AND (length(p_GTA_trx_header.tp_tax_registration_number)<>15) )
  THEN
     RETURN G_EXPORT_TAXPAYERID_ERROR;

  END IF;
*/

  -- Modified by Brian for bug 7590613

  IF ((p_GTA_trx_header.invoice_type <> '2') AND
      (length(p_GTA_trx_header.tp_tax_registration_number) <> 15)) OR
     (p_GTA_trx_header.invoice_type = '2' AND
      length(p_GTA_trx_header.tp_tax_registration_number) <> 15 AND
      (p_GTA_trx_header.tp_tax_registration_number IS NOT NULL))
  THEN
    RETURN G_EXPORT_TAXPAYERID_ERROR;

  END IF;
  --The following code is recovered by Yao Zhang for bug 7670310
  --The following check logic is only for common Credit Memo
  --following code is commented by subba to relax the validation for CM in R12.1
IF (p_GTA_trx_header.invoice_type = '2') THEN
  IF(p_GTA_trx_header.consolidation_flag='0')
  THEN
    IF AR_GTA_TRX_UTIL.Get_Gtainvoice_Amount(p_GTA_trx_header.gta_trx_header_id)>0
    THEN l_trx_class:='INV';
    ELSE l_trx_class:='CM';
    END IF;
  ELSE
  BEGIN
    SELECT t.TYPE
      INTO l_trx_class
    FROM ra_customer_trx_all ct
       , ra_cust_trx_types_all t
    WHERE ct.cust_trx_type_id = t.cust_trx_type_id
      AND ct.customer_trx_id=p_GTA_trx_header.ra_trx_id
      AND t.org_id=p_GTA_trx_header.org_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN G_EXPORT_MISSING;

  END;
  END IF;
   fnd_message.SET_NAME( APPLICATION => 'AR'
                       , NAME => 'AR_GTA_CREDMEMO_EXPORT_IV'
                       );
   l_cm_delimiter1:=fnd_message.get;

   fnd_message.SET_NAME( APPLICATION => 'AR'
                       , NAME => 'AR_GTA_CREDMEMO_EXPORT_NR'
                       );
   l_cm_delimiter2:=fnd_message.get;

   IF l_trx_class='CM'
   AND (  p_GTA_trx_header.DESCRIPTION IS NULL
       OR instr(p_GTA_trx_header.description,l_cm_delimiter1)<1
       OR instr(p_GTA_trx_header.description,l_cm_delimiter2)<1
       )
   THEN
       RETURN G_EXPORT_CRMEMO_MISSING_ERROR;

   END IF;
   END IF;
 --comments end for CM validation
 --The above code is recovered by Yao Zhang for bug 7670310

      --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

   RETURN G_EXPORT_SUCC;
END Check_Header;

--==========================================================================
--  FUNCTION NAME:
--
--    Check_Line_Length                     Public
--
--  DESCRIPTION:
--
--      This procedure check whether the columns of export data
--      exceeding Golden Tax required length
--
--  PARAMETERS:
--      In:  p_gta_trx_line      GTA transaction line record
--
--     Out:
--  Return:  BOOLEAN;
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--      05/12/05       Jogen Hu      Created
--===========================================================================
FUNCTION Check_Line_Length
( p_GTA_trx_line           IN       AR_GTA_TRX_UTIL.TRX_LINE_REC_TYPE
)
RETURN BOOLEAN
IS
l_len_before_dot_qty NUMBER        :=0;
l_len_after_dot_qty  NUMBER        :=0;
l_len_before_dot_amt NUMBER        :=0;
l_len_after_dot_amt  NUMBER        :=0;
l_len_before_dot_disamt NUMBER       :=0;
l_len_after_dot_disamt  NUMBER       :=0;
l_len_before_dot_tax NUMBER        :=0;
l_len_after_dot_tax  NUMBER        :=0;
l_pos                NUMBER        :=0;
l_procedure_name     VARCHAR2(50)  :='Check_Line_Length';
l_dbg_level          NUMBER        :=FND_LOG.G_Current_Runtime_Level;
l_proc_level         NUMBER        :=FND_LOG.Level_Procedure;

BEGIN

   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

  --convert float number to string limitation
  l_pos:=instr(to_char(p_GTA_trx_line.quantity),'.');
  IF l_pos>0 THEN
     l_len_before_dot_qty:=l_pos - 1;
     l_len_after_dot_qty :=length(to_char(p_GTA_trx_line.quantity)) -  l_pos;
  ELSE
     l_len_before_dot_qty:=l_pos;
  END IF;

  l_pos:=instr(to_char(p_GTA_trx_line.amount),'.');
  IF l_pos>0 THEN
     l_len_before_dot_amt:=l_pos - 1;
     l_len_after_dot_amt :=length(to_char(p_GTA_trx_line.amount)) -  l_pos;
  ELSE
     l_len_before_dot_amt:=l_pos;
  END IF;

  l_pos:=instr(to_char(p_GTA_trx_line.tax_rate),'.');
  IF l_pos>0 THEN
     l_len_before_dot_tax:=l_pos - 1;
     l_len_after_dot_tax :=length(to_char(p_GTA_trx_line.tax_rate)) -  l_pos;
  ELSE
     l_len_before_dot_tax:=l_pos;
  END IF;
  --Yao Zhang add for bug#8605196 to support discount amount export
  l_pos:=instr(to_char(p_GTA_trx_line.discount_amount),'.');
  IF l_pos>0 THEN
     l_len_before_dot_disamt:=l_pos - 1;
     l_len_after_dot_disamt :=length(to_char(p_GTA_trx_line.discount_amount)) -  l_pos;
  ELSE
     l_len_before_dot_disamt:=l_pos;
  END IF;
  --Yao Zhang add end for bug#8605196 to support discount amount export

  IF    length(p_GTA_trx_line.item_description)>60
     OR length(p_GTA_trx_line.uom_name)        >16
     OR length(p_GTA_trx_line.item_model)      >30
     OR length(p_GTA_trx_line.item_tax_denomination)>4
     OR l_len_before_dot_qty                   >16
     OR l_len_after_dot_qty                    >6
     OR l_len_before_dot_amt                   >14
     OR l_len_after_dot_amt                    >2
     OR l_len_before_dot_tax                   >4
     OR l_len_after_dot_tax                    >2
     --Yao Zhang add for bug#8605196 to support discount amount export
     OR l_len_before_dot_disamt                >14
     OR l_len_after_dot_disamt                 >2

  THEN
     RETURN FALSE;
  END IF;

   --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

  RETURN TRUE;
END Check_Line_Length;

--==========================================================================
--  PROCEDURE NAME:
--
--    Export_Customers                     Public
--
--  DESCRIPTION:
--
--      This procedure export customers information  from GTA to flat file
--
--  PARAMETERS:
--      In:   p_org_id                 Identifier of operating unit
--            p_customer_num_from      Customer number low range
--            p_customer_num_to        Customer number high range
--            p_customer_name_from     Customer name low range
--            p_customer_name_to       Customer name high range
--            p_taxpayee_id            Identifier of taxpayer
--            p_creation_date_from     Creation date low range
--            p_creation_date_to       Creation date high range
--
--     OUt:
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           06/05/05      Jim Zheng   Created
--           30/09/05      Jim Zheng   updated  delete the export of tax_payer_id
--           08/11/05      Jim Zheng   updated  add '~~' in output file,because the
--                                     tax_payer_id should be leave blank
--           11/11/05      Jim Zheng   updated, the bank account mask profile change
--                                     to CE_MASK_INTERNAL_BANK_ACCT_NUM, and the value
--                                     change to NO MASK
--           17/Mar/2009    Yao Zhang   Fix bug 8230998 changed.
--           29/APR/2009    Yao Zhang   Fix bug 7670710 changed.
--           16/Jun/2009    Allen Yang  updated for bug 8605196 to support export
--                                      customer name, address, bank name, and bank
--                                      branch name in Chinese.
--           06/Aug/2009    Allen Yang  updated for bug 8765298 and 8766256.
--===========================================================================
PROCEDURE export_customers
( P_ORG_ID               IN          NUMBER
, P_CUSTOMER_NUM_FROM    IN          VARCHAR2
, P_CUSTOMER_NUM_TO      IN          VARCHAR2
, P_CUSTOMER_NAME_FROM   IN          VARCHAR2
, P_CUSTOMER_NAME_TO     IN          VARCHAR2
, P_CREATION_DATE_FROM   IN          DATE
, P_CREATION_DATE_TO     IN          DATE
)
IS
l_procedure_name                     VARCHAR2(30) := 'export_customers';

l_CUSTOMER_NUM_FROM                  HZ_CUST_ACCOUNTS.Account_Number%TYPE;
l_CUSTOMER_NUM_TO                    HZ_CUST_ACCOUNTS.Account_Number%TYPE;
l_CUSTOMER_NAME_FROM                 HZ_PARTIES.Party_Name%TYPE;
l_CUSTOMER_NAME_TO                   HZ_PARTIES.Party_Name%TYPE;

l_CREATION_DATE_FROM                 HZ_CUST_ACCOUNTS.Creation_Date%TYPE;
l_CREATION_DATE_TO                   HZ_CUST_ACCOUNTS.Creation_Date%TYPE;

l_customer_id                        HZ_CUST_ACCOUNTS.Cust_Account_Id%TYPE;
l_customer_number                    HZ_CUST_ACCOUNTS.Account_Number%TYPE;
l_customer_name                      HZ_PARTIES.Party_Name%TYPE;
--l_taxpayer_id                        HZ_PARTIES.JGZZ_FISCAL_CODE%TYPE;
l_customer_name_phonetic             HZ_PARTIES.ORGANIZATION_NAME_PHONETIC%TYPE;
l_party_id                           HZ_PARTIES.PARTY_ID%TYPE;
l_alternate_name                     HZ_PARTIES.ORGANIZATION_NAME_PHONETIC%TYPE;

l_phone_num                          Hz_Contact_Points.Phone_Number%TYPE;
l_currency_code                      AR_GTA_SYSTEM_PARAMETERS_ALL.Gt_Currency_Code%TYPE;
l_bank_account_name                  IBY_EXT_BANK_ACCOUNTS.BANK_ACCOUNT_NAME%TYPE;
l_bank_account_num                   IBY_EXT_BANK_ACCOUNTS.BANK_ACCOUNT_NUM%TYPE;
l_address                            AR_ADDRESSES_V.concatenated_address%TYPE;
l_address_phonenumber                AR_ADDRESSES_V.concatenated_address%TYPE;

l_party_site_id                      hz_party_sites.party_site_id%TYPE;
l_customer_site_id                   hz_cust_acct_sites.CUST_ACCT_SITE_ID%TYPE;
l_customer_site_use_id               hz_cust_site_uses.SITE_USE_ID%TYPE;

-- modified by allen yang 17/Jun/2009 for bug 8605196 to display bank info in Chinese
-------------------------------------------------------------------------------------
--l_bank_account                       VARCHAR2(110);
l_bank_account                       VARCHAR2(1000);
l_bank_account_current_str           VARCHAR2(1000); -- concatenated string for current loop
--------------------------------------------------------------------------------------

l_comment                            VARCHAR2(2) := '//';
l_bound                              VARCHAR2(2) := '~~';
l_exceed_length                      VARCHAR2(1000) := 'The customers below are excluded for exceeding the maximum length of the fields:';
l_error_bound                        VARCHAR2(1000):= '*****************************************';
-- modified by Allen Yang 06-Aug-2009 for bug 8765298
l_cust_number_length                 NUMBER := 16;
--l_cust_name_length                   NUMBER := 60;
l_cust_name_length                   NUMBER := 100;
l_alternate_name_length              NUMBER := 6;
l_taxpayer_id_length                 NUMBER := 15;
--l_address_phonenumber_length         NUMBER := 80;
l_address_phonenumber_length         NUMBER := 200;
-- end modified by Allen 06-Aug-2009

-- added by Allen Yang 06-Aug-2009 for bug 8766256
l_quotation_mark                     VARCHAR(2)  := '"';
-- end added by Allen 06-Aug-2009

-- modified by allen yang 17/Jun/2009 for bug 8605196 to display bank info in Chinese
-------------------------------------------------------------------------------------
--l_bank_account_name_length           NUMBER := 80;
l_bank_account_name_length           NUMBER := 200;
l_bank_account_current_length        NUMBER := 0;
l_bank_account_too_long              BOOLEAN := FALSE;
-------------------------------------------------------------------------------------

l_err_text                           VARCHAR2(2000);
l_error_string                       VARCHAR2(2000);

l_ar_gta_gta_not_enabled            VARCHAR2(2000);
l_count                              NUMBER;
l_conc_succ                          BOOLEAN; -- the status of concurrent

l_dbg_level          NUMBER        :=FND_LOG.G_Current_Runtime_Level;
l_proc_level         NUMBER        :=FND_LOG.Level_Procedure;

l_ext_payer_id       IBY_EXTERNAL_PAYERS_ALL.ext_payer_id%TYPE;
--Yao Zhang fix bug 7670710 add begin
l_bank_name                           HZ_PARTIES.party_name%TYPE;
l_bank_branch_name                    HZ_PARTIES.party_name%TYPE;
--Yao Zhang fix bug#7670710 add end


TYPE l_string_tbl IS TABLE OF VARCHAR2(1000);

l_taxpayer_tbl                        l_string_tbl := l_string_tbl();
l_exceed_tbl                          l_string_tbl := l_string_tbl();
/*added by Allen Yang 15/Jun/2009 for bug 8605196 to support export
  customer name in Chinese.*/
--------------------------------------------------------------------
l_bank_exceed_tbl                     l_string_tbl := l_string_tbl();
--------------------------------------------------------------------
l_index                               NUMBER ;  -- loop flag

CURSOR
  c_customer(p_num_from         VARCHAR2
             , p_num_to         VARCHAR2
             , p_name_from      VARCHAR2
             , p_name_to        VARCHAR2
             , p_create_from    DATE
             , p_create_to      DATE
             )
IS
  SELECT
    CUST.CUST_ACCOUNT_ID
    , CUST.ACCOUNT_NUMBER
    -- modified by Allen Yang 15/Jun/2009 for bug 8605196
    -- to support export customer name in Chinese
    ------------------------------------------------------
    , decode(CUST_PARTY.Known_As
           , null
           , CUST_PARTY.PARTY_NAME
           , CUST_PARTY.Known_As)
    --, CUST_PARTY.PARTY_NAME
    ------------------------------------------------------
    --, CUST_PARTY.JGZZ_FISCAL_CODE
    , CUST_PARTY.ORGANIZATION_NAME_PHONETIC
    , CUST_PARTY.PARTY_ID
  FROM
    HZ_CUST_ACCOUNTS CUST
    , HZ_PARTIES CUST_PARTY
  WHERE cust.party_id = cust_party.party_id
    AND cust.account_number  BETWEEN p_num_from  AND p_num_to
    --AND cust_party.party_name BETWEEN p_name_from AND p_name_to--yao zhang delete for bug 8230998
    AND cust_party.party_name BETWEEN p_name_from
        AND decode(p_name_to,null,cust_party.party_name,p_name_to)--yao zhang add for bug 8230998
    AND cust.creation_date    BETWEEN p_create_from AND p_create_to
    --AND (cust_party.jgzz_fiscal_code = p_taxpayer_id OR p_taxpayer_id IS NULL)
    AND cust.status = 'A'
    AND cust_party.party_type = 'ORGANIZATION';

-- added by Allen Yang for bug 8605196 to support export cunstomer
-- and bank info in Chinese 16/Jun/2009
------------------------------------------------------------------
CURSOR
  c_customer_bank_info(p_ext_payer_id  NUMBER
                      ,p_currency_code VARCHAR2)
IS
  SELECT *
  FROM
    (SELECT
      ibybanks.bank_account_name
    , ibybanks.bank_account_num
    , decode(bp.organization_name_phonetic
            ,null
            ,bp.party_name
            ,bp.organization_name_phonetic) bank_name
    , decode(br.organization_name_phonetic
            ,null
            ,br.party_name
            ,br.organization_name_phonetic) bank_branch_name
    FROM
      IBY_PMT_INSTR_USES_ALL ExtPartyInstrumentsEO
    , IBY_EXT_BANK_ACCOUNTS ibybanks
    , HZ_PARTIES BR
    , HZ_PARTIES BP
    WHERE ibybanks.EXT_BANK_ACCOUNT_ID = ExtPartyInstrumentsEO.instrument_id
      AND ExtPartyInstrumentsEO.INSTRUMENT_TYPE = 'BANKACCOUNT'
      AND ExtPartyInstrumentsEO.EXT_PMT_PARTY_ID = p_ext_payer_id
      AND ExtPartyInstrumentsEO.PAYMENT_FUNCTION = 'CUSTOMER_PAYMENT'
      AND ibybanks.currency_code = p_currency_code
      AND SYSDATE BETWEEN nvl(ExtPartyInstrumentsEO.START_DATE
                            , to_date('1900-01-01','RRRR-MM-DD'))
      AND nvl(ExtPartyInstrumentsEO.END_DATE
            , to_date('3000-01-01','RRRR-MM-DD'))
      AND ibybanks.bank_id = bp.party_id(+)
      AND ibybanks.branch_id = br.party_id(+)
    ORDER BY ExtPartyInstrumentsEO.ORDER_OF_PREFERENCE)
  UNION ALL
  SELECT *
  FROM
    (SELECT
      ibybanks.bank_account_name
    , ibybanks.bank_account_num
    , decode(bp.organization_name_phonetic
            ,null
            ,bp.party_name
            ,bp.organization_name_phonetic) bank_name
    , decode(br.organization_name_phonetic
            ,null
            ,br.party_name
            ,br.organization_name_phonetic) bank_branch_name
    FROM
      IBY_PMT_INSTR_USES_ALL ExtPartyInstrumentsEO
    , IBY_EXT_BANK_ACCOUNTS ibybanks
    , HZ_PARTIES BR
    , HZ_PARTIES BP
    WHERE ibybanks.EXT_BANK_ACCOUNT_ID = ExtPartyInstrumentsEO.instrument_id
      AND ExtPartyInstrumentsEO.INSTRUMENT_TYPE = 'BANKACCOUNT'
      AND ExtPartyInstrumentsEO.EXT_PMT_PARTY_ID = p_ext_payer_id
      AND ExtPartyInstrumentsEO.PAYMENT_FUNCTION = 'CUSTOMER_PAYMENT'
      AND ibybanks.currency_code IS NULL
      AND SYSDATE BETWEEN nvl(ExtPartyInstrumentsEO.START_DATE
                            , to_date('1900-01-01','RRRR-MM-DD'))
      AND nvl(ExtPartyInstrumentsEO.END_DATE
            , to_date('3000-01-01','RRRR-MM-DD'))
      AND ibybanks.bank_id = bp.party_id(+)
      AND ibybanks.branch_id = br.party_id(+)
    ORDER BY ExtPartyInstrumentsEO.ORDER_OF_PREFERENCE);
---------------------------------------------------------------------------------------

BEGIN
  -- add primary site id in  query sql commment
  -- category the wrong process
  -- add the chinese token

  IF(l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                   , G_MODULE_PREFIX||l_procedure_name
                   , ' Procedure begin . ');
  END IF;

  -- check the profile for bank account mask
  IF fnd_profile.VALUE('CE_MASK_INTERNAL_BANK_ACCT_NUM') <> 'NO MASK'
  THEN
    fnd_message.set_name('AR', 'AR_GTA_BANKACCOUNT_MASKING');

    fnd_file.put_line(fnd_file.OUTPUT, fnd_message.get());

    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                     , G_MODULE_PREFIX||l_procedure_name
                     , l_error_string);
    END IF;
    --set concurrent status to Warning
    l_conc_succ := fnd_concurrent.set_completion_status(status     => 'WARNING'
                                                          , message  => l_error_string
                                                         );
    RETURN;
  END IF;

  --output the title. by message and token
  -- message line 1
  fnd_message.set_name('AR', 'AR_GTA_CUSTOMER_EXPORT_LNA');
  fnd_message.set_token('PREFIX', '{');
  fnd_message.set_token('MIDFIX', '}[');
  fnd_message.set_token('SUFFIX', ']"~~"');
  fnd_file.put_line(fnd_file.output, fnd_message.get());

  -- message line 2
  fnd_message.set_name('AR', 'AR_GTA_CUSTOMER_EXPORT_LNB');
  fnd_message.set_token('PREFIX', '//');
  fnd_message.set_token('SUFFIX', ':');
  fnd_file.put_line(fnd_file.output, fnd_message.get());

  -- message line 3
  fnd_message.set_name('AR', 'AR_GTA_CUSTOMER_EXPORT_LNC');
  fnd_message.set_token('PREFIX', '//');
  fnd_message.set_token('MIDFIX', '~~');
  fnd_file.put_line(fnd_file.output, fnd_message.get());

  l_customer_num_from          :=nvl(p_customer_num_from,' ');
  l_customer_num_to            :=nvl(p_customer_num_to,rpad('z',30,'z'));
  l_customer_name_from         :=nvl(p_customer_name_from,' ');
  --l_customer_name_to           :=nvl(p_customer_name_to,rpad('z',30,'z'));--yao zhang delete for 8230998
  l_customer_name_to           :=p_customer_name_to;--yao zhang add for bug 8230998
  l_creation_date_from         :=nvl(p_creation_date_from,to_date('1900-01-01','RRRR-MM-DD'));
  l_creation_date_to           :=nvl(p_creation_date_to,to_date('3000-01-01','RRRR-MM-DD'));
  --l_taxpayer_id                :=P_TAXPAYEE_ID;

  -- no data found message .
  SELECT
    COUNT(cust.cust_account_id)
  INTO
    l_count
  FROM
    HZ_CUST_ACCOUNTS CUST
    , HZ_PARTIES CUST_PARTY
  WHERE cust.party_id = cust_party.party_id
    AND cust.account_number  BETWEEN l_customer_num_from  AND l_customer_num_to
   -- AND cust_party.party_name BETWEEN l_customer_name_from AND l_customer_name_to--yao zhang delete for bug 8230998
    AND cust_party.party_name BETWEEN l_customer_name_from
        AND decode(l_customer_name_to,null,cust_party.party_name,l_customer_name_to)--yao zhang add for bug 8230998
    AND cust.creation_date    BETWEEN l_creation_date_from AND l_creation_date_to
    --AND (cust_party.jgzz_fiscal_code = l_taxpayer_id OR l_taxpayer_id IS NULL)
    AND cust.status = 'A'
    AND cust_party.party_type = 'ORGANIZATION';

  IF l_count = 0
  THEN
     fnd_message.set_name('AR', 'AR_GTA_NO_DATA_FOUND');
     l_error_string := fnd_message.get();
     fnd_file.put_line(fnd_file.OUTPUT, l_comment||l_error_string);
  END IF;

  OPEN c_customer(l_customer_num_from
                 ,l_customer_num_to
                 ,l_customer_name_from
                 ,l_customer_name_to
                 ,l_creation_date_from
                 ,l_creation_date_to
                 --,l_taxpayer_id
                 );
   LOOP
     --fetch c_customer to variables;
     -- WHILE c_customer%FOUND
     FETCH
       c_customer
     INTO
       l_customer_id
       , l_customer_number
       , l_customer_name
       --, l_taxpayer_id
       , l_alternate_name  --l_customer_name_phonetic
       , l_party_id;

     IF c_customer%NOTFOUND
     THEN
       EXIT;
     END IF ;

     -- init the customer var.

     l_address := NULL;
     l_customer_site_id := NULL;
     l_party_site_id := NULL;
     l_phone_num := NULL;
     l_customer_site_use_id := NULL;
     l_bank_account_name := NULL;
     l_bank_account_num := NULL;
     l_address_phonenumber := NULL;
     l_bank_account:= NULL;
     l_ext_payer_id := NULL;
     l_bank_name:=null;
     l_bank_branch_name:=null;


     BEGIN
        SELECT
        -- Mofidied by Allen Yang 15/Jun/2009 for bug 8605196 to export customer address in Chinese
        -------------------------------------------------------------------------------------------
          decode(loc.Address_Lines_Phonetic
               , null
               , arp_addr_pkg.format_address(loc.address_style
                                           , loc.address1
                                           , loc.address2
                                           , loc.address3
                                           , loc.address4
                                           , loc.city
                                           , loc.county
                                           , loc.state
                                           , loc.province
                                           , loc.postal_code
                                           , terr.territory_short_name)
               , loc.Address_Lines_Phonetic)
          /*
          arp_addr_pkg.format_address(loc.address_style
                                      , loc.address1
                                      , loc.address2
                                      , loc.address3
                                      , loc.address4
                                      , loc.city
                                      , loc.county
                                      , loc.state
                                      , loc.province
                                      , loc.postal_code
                                      , terr.territory_short_name )
          */
        -------------------------------------------------------------------------------------------
          , addr.CUST_ACCT_SITE_ID
          , party_site.party_site_id
        INTO
           l_address
           , l_customer_site_id
           , l_party_site_id
        FROM
          hz_cust_site_uses_all   hcsua
          , hz_cust_acct_sites_all addr
          , hz_party_sites party_site
          , hz_locations loc
          , fnd_territories_tl terr
        WHERE addr.party_site_id = party_site.party_site_id
          AND loc.location_id = party_site.location_id
          AND hcsua.cust_acct_site_id = addr.cust_acct_site_id
          AND hcsua.site_use_code = 'BILL_TO'
          AND hcsua.status = 'A'
          AND hcsua.primary_flag = 'Y'
          AND loc.country = terr.territory_code(+)
          AND terr.LANGUAGE = USERENV('LANG')
          AND addr.org_id = p_org_id
          AND addr.cust_account_id = l_customer_id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
           fnd_log.STRING(FND_LOG.LEVEL_EXCEPTION
                          , G_MODULE_PREFIX || l_procedure_name || '.NoDataFound'
                          ,'Customer'|| l_customer_name || 'has no primary bill to address');
         END IF;
     END;

     --get phone info
     BEGIN
       SELECT
         phone_number
       INTO
         l_phone_num
       FROM
         Hz_Contact_Points
       WHERE owner_table_name='HZ_PARTY_SITES'
         AND owner_table_id=l_party_site_id
         AND phone_line_type='GEN'
         AND primary_flag='Y'
         AND status = 'A'
         AND contact_point_type = 'PHONE';

     EXCEPTION
         WHEN NO_DATA_FOUND THEN
         IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
           fnd_log.STRING(FND_LOG.LEVEL_EXCEPTION
                          , G_MODULE_PREFIX || l_procedure_name || '.NoDataFound'
                          ,'Customer'|| l_customer_name || 'has no primary phone number'||SQLCODE||SQLERRM);
         END IF;
     END;

     --get customer site use id
     BEGIN
       SELECT
         SITE.SITE_USE_ID
       INTO
         l_customer_site_use_id
       FROM
         hz_cust_site_uses site
       WHERE SITE.CUST_ACCT_SITE_ID = l_customer_site_id
         AND SITE.SITE_USE_CODE = 'BILL_TO'
         AND SITE.STATUS = 'A';
     EXCEPTION
       WHEN OTHERS THEN
         IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
           FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                           , G_MODULE_PREFIX || l_procedure_name || '.NoDataFound'
                           , l_err_text||SQLCODE ||SQLERRM);
         END IF;
     END;


     -- get currency code from GTA
     BEGIN
       l_err_text:='Golden Tax Interface Currency code setup error!';
       SELECT
         GT_CURRENCY_CODE
       INTO
         l_currency_code
       FROM
         AR_GTA_SYSTEM_PARAMETERS_ALL
       WHERE
         org_id = p_org_id;

     EXCEPTION
       WHEN OTHERS THEN
         IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
           FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                           , G_MODULE_PREFIX || l_procedure_name || '.NoDataFound'
                           , l_err_text||SQLCODE ||SQLERRM);
         END IF;
     END;

     -- get ext pmt party id
     BEGIN
       SELECT
         ext_payer_id
       INTO
         l_ext_payer_id
       FROM
         IBY_EXTERNAL_PAYERS_ALL
       WHERE party_id = l_party_id
       AND CUST_ACCOUNT_ID = l_customer_id  -- site account id
       AND ACCT_SITE_USE_ID = l_customer_site_use_id  -- site use id
       AND ORG_ID = p_org_id  -- org id
       AND org_type = 'OPERATING_UNIT' -- ou
       AND payment_function = 'CUSTOMER_PAYMENT';  -- function

     EXCEPTION
       WHEN OTHERS THEN
         IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
           FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                           , G_MODULE_PREFIX || l_procedure_name || '.NoDataFound'
                           , l_err_text||SQLCODE ||SQLERRM);
         END IF;
     END;


     --get back name and account number info(need org_id when MOAC)
     BEGIN

      l_err_text:='Customer'|| l_customer_name || 'has no primary bank name and accout!';
      -- modified by Allen Yang for bug 8605196 to support export cunstomer and bank info in Chinese 16/Jun/2009
      ------------------------------------------------------------------------------------------
      -- if the customer has multiple bank accounts, export them all in a concatenated string
      OPEN c_customer_bank_info(l_ext_payer_id
                               ,l_currency_code);
        LOOP
          FETCH
            c_customer_bank_info
          INTO
            l_bank_account_name
          , l_bank_account_num
          , l_bank_name
          , l_bank_branch_name;
          EXIT WHEN c_customer_bank_info%NOTFOUND;
          IF
            c_customer_bank_info%ROWCOUNT = 1
          THEN
            -- modified by Allen Yang 06-Aug-2009 for bug	8766256
            --l_bank_account := l_bank_name||' '||l_bank_branch_name||' '||l_bank_account_num;
            l_bank_account := l_quotation_mark||l_bank_name||' '||l_bank_branch_name
                              ||' '||l_bank_account_num||l_quotation_mark;
            -- end modified by Allen 06-Aug-2009
            l_bank_account_current_length := length(l_bank_account);
            IF l_bank_account_current_length > l_bank_account_name_length
            THEN
              EXIT; -- don't concatenate multiple bank info if the first bank info's length has exceeded the max length
            END IF; -- l_bank_account_current_length > l_bank_account_name_length
          ELSE
            -- modified by Allen Yang 06-Aug-2009 for bug	8766256
            --l_bank_account_current_str := ','||l_bank_name||' '||l_bank_branch_name||' '||l_bank_account_num;
            l_bank_account_current_str := ', '||l_quotation_mark||l_bank_name||' '||l_bank_branch_name
                                          ||' '||l_bank_account_num||l_quotation_mark;
            -- -- end modified by Allen 06-Aug-2009
            IF(length(l_bank_account_current_str) + l_bank_account_current_length > l_bank_account_name_length)
            THEN
              l_bank_account_too_long := TRUE;
              EXIT;
            ELSE
              l_bank_account := l_bank_account||l_bank_account_current_str;
              l_bank_account_current_length := l_bank_account_current_length + length(l_bank_account_current_str);
            END IF; -- (length(l_bank_account_current_str) + l_bank_account_current_length > l_bank_account_name_length)
          END IF; -- (c_customer_bank_info%ROWCOUNT = 1)
        END LOOP; -- c_customer_bank_info
      CLOSE c_customer_bank_info;
      /*
      SELECT
        bank_account_name
        , bank_account_num
        , bank_name --add by Yao Zhang for bug#7670710
        , bank_branch_name --add by Yao Zhang for bug#7670710
      INTO
        l_bank_account_name
        , l_bank_account_num
        ,l_bank_name--add by Yao Zhang for bug#7670710
        ,l_bank_branch_name --add by Yao Zhang for bug#7670710
      FROM (SELECT ibybanks.bank_account_name
                   , ibybanks.bank_account_num
                   , bp.party_name bank_name --add by Yao Zhang for bug#7670710
                   , br.party_name bank_branch_name --add by Yao Zhang for bug#7670710
            FROM IBY_PMT_INSTR_USES_ALL ExtPartyInstrumentsEO
            , IBY_EXT_BANK_ACCOUNTS ibybanks
            ,HZ_PARTIES BR
            ,HZ_PARTIES BP
            WHERE ibybanks.EXT_BANK_ACCOUNT_ID = ExtPartyInstrumentsEO.instrument_id
            AND ExtPartyInstrumentsEO.INSTRUMENT_TYPE = 'BANKACCOUNT'
            AND ExtPartyInstrumentsEO.EXT_PMT_PARTY_ID = l_ext_payer_id
            AND ExtPartyInstrumentsEO.PAYMENT_FUNCTION = 'CUSTOMER_PAYMENT'
            AND ibybanks.currency_code = l_currency_code
            AND SYSDATE BETWEEN nvl(ExtPartyInstrumentsEO.START_DATE, to_date('1900-01-01','RRRR-MM-DD'))
                          AND nvl(ExtPartyInstrumentsEO.END_DATE, to_date('3000-01-01','RRRR-MM-DD'))
            AND ibybanks.bank_id = bp.party_id(+)--add by Yao Zhang for bug#7670710
            AND ibybanks.branch_id = br.party_id(+) --add by Yao Zhang for bug#7670710
            ORDER BY ExtPartyInstrumentsEO.ORDER_OF_PREFERENCE)
      WHERE ROWNUM =1;
      */
     -------------------------------------------------------------------------------------------

     EXCEPTION
       WHEN OTHERS THEN
         IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
           FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                           , G_MODULE_PREFIX || l_procedure_name || '.NoDataFound'
                           , l_err_text||SQLCODE ||SQLERRM);
         END IF;
     END;

     -- modified by Allen Yang 06-Aug-2009 for bug 8766256
     IF l_address IS NULL AND l_phone_num IS NULL
     THEN
       l_address_phonenumber := NULL;
     ELSIF l_address IS NOT NULL AND l_phone_num IS NULL
     THEN
       --l_address_phonenumber := l_address;
       l_address_phonenumber := l_quotation_mark||l_address||l_quotation_mark;
     ELSIF l_address IS NULL AND l_phone_num IS NOT NULL
     THEN
       --l_address_phonenumber := l_phone_num;
       l_address_phonenumber :=l_quotation_mark||l_phone_num||l_quotation_mark;
     ELSE
       --l_address_phonenumber := l_address||' '||l_phone_num;
       l_address_phonenumber := l_quotation_mark||l_address
                                ||' '||l_phone_num||l_quotation_mark;
     END IF; /*l_address IS NULL AND l_phone_num IS NULL*/
     -- end modified by Allen 06-Aug-2009

     /* commented by Allen Yang for bug 8605196 to support exporting customer and bank info in Chinese 16/Jun/2009
        corresponding logic has been handled above

     --added  by Yao Zhang for bug#7670710 begin
     IF l_bank_name IS NOT NULL
     THEN
       l_bank_account := l_bank_name;
       IF l_bank_branch_name is not null
       Then
       l_bank_account:=l_bank_account||' '||l_bank_branch_name;
       END IF;
       IF l_bank_account_num is not null
     THEN
       l_bank_account:=l_bank_account||' '||l_bank_account_num;
       END IF;
     ELSE
       l_bank_account:=null;

     END IF; -- l_bank_account_name IS NULL AND l_bank_account_num IS NULL
     --add by Yao Zhang for bug#7670710 add end.
     */



     /*
     IF  length(l_taxpayer_id) > l_taxpayer_id_length
         OR length(l_taxpayer_id) < l_taxpayer_id_length
     THEN
       -- insert the error line into nested table
       l_taxpayer_tbl.EXTEND;
       l_taxpayer_tbl(l_taxpayer_tbl.COUNT) :=  l_comment
                                                ||nvl(l_customer_number, ' ')
                                                ||l_bound
                                                ||nvl(l_customer_name, ' ')
                                                ||l_bound
                                                ||nvl(l_alternate_name, ' ')
                                                ||l_bound
                                                ||nvl(l_taxpayer_id, ' ' )
                                                ||l_bound
                                                ||nvl(l_address_phonenumber, ' ')
                                                ||l_bound
                                                ||nvl(l_bank_account, ' ');
       */

       IF length(l_customer_number) > l_cust_number_length
       OR length(l_customer_name) > l_cust_name_length
       OR length(l_alternate_name) > l_alternate_name_length
       OR length(l_address_phonenumber)> l_address_phonenumber_length
       OR length(l_bank_account) > l_bank_account_name_length
       THEN

         l_exceed_tbl.EXTEND;
         l_exceed_tbl(l_exceed_tbl.COUNT) := l_comment
                                             ||l_customer_number
                                             ||l_bound
                                             ||l_customer_name
                                             ||l_bound
                                             ||l_alternate_name
                                             ||l_bound
                                             --||' '--nvl(l_taxpayer_id, ' ' )
                                             ||l_bound
                                             ||l_address_phonenumber
                                             ||l_bound
                                             ||l_bank_account;

       ELSE
          -- modified by allen yang for bug 8605196 to support exporting
          -- customer and bank info in Chinese 17/Jun/2009
          ------------------------------------------------------------------
         IF l_bank_account_too_long
         THEN
           /* if user has multiple bank account, and the concatenated account
              string exceeded the max length, then only export the concatenated
              string within max length, and display a message to say the bank
              accounts are not fully exported.
           */
           /*
           fnd_message.set_name('AR', 'AR_GTA_MUL_BANK_ON_CUSTOMER');
           l_error_string  := fnd_message.GET;
           fnd_file.PUT_LINE(fnd_file.OUTPUT,  l_comment||l_error_string);
           fnd_file.PUT_LINE(fnd_file.OUTPUT,  l_comment||l_error_bound);
           fnd_file.PUT_LINE(fnd_file.OUTPUT,  l_customer_number
                                              ||l_bound
                                              ||l_customer_name
                                              ||l_bound
                                              ||l_alternate_name
                                              ||l_bound
                                              --||' '--nvl(l_taxpayer_id, ' ' )
                                              ||l_bound
                                              ||l_address_phonenumber
                                              ||l_bound
                                              ||l_bank_account
                                              );
           fnd_file.PUT_LINE(fnd_file.OUTPUT,  l_comment||l_error_bound);
           */
           l_bank_exceed_tbl.EXTEND;
           l_bank_exceed_tbl(l_bank_exceed_tbl.COUNT) := l_customer_number
                                                       ||l_bound
                                                       ||l_customer_name
                                                       ||l_bound
                                                       ||l_alternate_name
                                                       ||l_bound
                                                     --||' '--nvl(l_taxpayer_id, ' ' )
                                                       ||l_bound
                                                       ||l_address_phonenumber
                                                       ||l_bound
                                                       ||l_bank_account;
         ELSE
           fnd_file.PUT_LINE(fnd_file.OUTPUT,  l_customer_number
                                              ||l_bound
                                              ||l_customer_name
                                              ||l_bound
                                              ||l_alternate_name
                                              ||l_bound
                                              --||' '--nvl(l_taxpayer_id, ' ' )
                                              ||l_bound
                                              ||l_address_phonenumber
                                              ||l_bound
                                              ||l_bank_account
                                              );
          END IF; -- l_bank_account_too_long
          --------------------------------------------------------------------
       END IF;
     END LOOP;

     CLOSE c_customer;


     /*
     IF l_taxpayer_tbl.COUNT > 0
     THEN
       -- output AR_GTA_INVALID_LENGTH
       fnd_message.SET_NAME('AR', 'AR_GTA_INVALID_LENGTH');
       l_error_string := fnd_message.get;

       fnd_file.put_line(fnd_file.output, l_comment||l_error_bound);
       fnd_file.PUT_LINE(fnd_file.output, l_comment||l_error_string);
       fnd_file.put_line(fnd_file.output, '');

       l_index := l_taxpayer_tbl.FIRST;
       WHILE l_index IS NOT NULL
       LOOP
         fnd_file.put_line(fnd_file.output, l_taxpayer_tbl(l_index));
         l_index := l_taxpayer_tbl.NEXT(l_index);
       END LOOP;

       fnd_file.PUT_LINE(fnd_file.OUTPUT, l_comment||l_error_bound);

     END IF;
     */

     -- added by Allen Yang for bug 8605196 to support exporting
     -- customer and bank info in Chinese 17/Jun/2009
     -----------------------------------------------------------------
     IF l_bank_exceed_tbl.COUNT > 0
     THEN
       -- output AR_GTA_MUL_BANK_ON_CUSTOMER message
       fnd_message.set_name('AR', 'AR_GTA_MUL_BANK_ON_CUSTOMER');
       fnd_message.set_token(TOKEN => 'NUMBER'
                            ,VALUE => l_bank_exceed_tbl.COUNT);
       l_error_string  := fnd_message.GET;
       fnd_file.put_line(fnd_file.output, l_comment||l_error_bound);
       fnd_file.PUT_LINE(fnd_file.output, l_comment||l_error_string);
       fnd_file.put_line(fnd_file.output, '');

       l_index := l_bank_exceed_tbl.FIRST;
       WHILE l_index IS NOT NULL
       LOOP
         fnd_file.put_line(fnd_file.output, l_bank_exceed_tbl(l_index));
         l_index := l_bank_exceed_tbl.NEXT(l_index);
       END LOOP;

       fnd_file.PUT_LINE(fnd_file.OUTPUT, l_comment||l_error_bound);
     END IF ;
     -----------------------------------------------------------------
     IF l_exceed_tbl.COUNT > 0
     THEN
       -- output AR_GTA_EXCEEDL_LENGTH message
       fnd_message.set_name('AR', 'AR_GTA_EXCEED_LENGTH');
       l_error_string  := fnd_message.GET;
       fnd_file.put_line(fnd_file.output, l_comment||l_error_bound);
       fnd_file.PUT_LINE(fnd_file.output, l_comment||l_error_string);
       fnd_file.put_line(fnd_file.output, '');

       l_index := l_exceed_tbl.FIRST;
       WHILE l_index IS NOT NULL
       LOOP
         fnd_file.put_line(fnd_file.output, l_exceed_tbl(l_index));
         l_index := l_exceed_tbl.NEXT(l_index);
       END LOOP;

       fnd_file.PUT_LINE(fnd_file.OUTPUT, l_comment||l_error_bound);
     END IF ;


  IF(l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                   , G_MODULE_PREFIX||l_procedure_name
                   , ' Procedure End . ');
  END IF;

EXCEPTION
 WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '.OTHER_EXCEPTION '
                    , SQLCODE||':'||SQLERRM);
    END IF;
    RAISE;

END Export_customers;

--==========================================================================
--  FUNCTION NAME:
--
--    Check_Item_Length             Private
--
--  DESCRIPTION:
--
--
--    The function is to judge if length of attributes of a item exeede limit,
--    if no, then return TRUE, else return FALSE
--
--  PARAMETERS:
--      In:  p_item_number            Item number
--           p_item_name              Item name
--           p_tax_name               Tax name
--           p_item_model             Model of item
--           p_uom                    Unit of measure
--
--      Return: BOOLEAN (TRUE/FALSE)
--
--  DESIGN REFERENCES:
--    GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005  Donghai Wang Creation
--           06-MAR-2006  Donghai Wang Add fnd log
--           06-APR-2006  Donghai Wang Remove the parameter p_tax_rate to
--                                     fix bug 5138356 due to no longer
--                                     export tax rate by items
--===========================================================================
FUNCTION Check_Item_Length
(p_item_number             IN VARCHAR2
,p_item_name               IN VARCHAR2
,p_tax_name                IN VARCHAR2
,p_item_model              IN VARCHAR2
,p_uom                     IN VARCHAR2
) RETURN BOOLEAN
IS
l_item_number                   mtl_system_items_b_kfv.concatenated_segments%TYPE  :=p_item_number;
l_item_name                     mtl_system_items_b.description%TYPE                :=p_item_name;
l_tax_name                      mtl_system_items_b.attribute1%TYPE                 :=p_tax_name;
l_item_model                    mtl_system_items_b.attribute1%TYPE                 :=p_item_model;
l_uom                           mtl_system_items_b.primary_unit_of_measure%TYPE    :=p_uom;
l_item_number_max_length        NUMBER                                             :=16;
l_item_name_max_length          NUMBER                                             :=60;
l_tax_name_max_length           NUMBER                                             :=4;
l_taxrate_maxlen_before_dot     NUMBER                                             :=4;
l_taxrate_maxlen_after_dot      NUMBER                                             :=2;
l_item_model_max_length         NUMBER                                             :=30;
l_uom_max_length                NUMBER                                             :=16;
l_tax_rate_dot_position         NUMBER;
l_item_number_length            NUMBER;
l_item_name_length              NUMBER;
l_tax_name_length               NUMBER;
l_tax_rate_length_before_dot    NUMBER;
l_tax_rate_length_after_dot     NUMBER;
l_item_model_length             NUMBER;
l_uom_length                    NUMBER;
l_dbg_level                     NUMBER                                             :=FND_LOG.G_Current_Runtime_Level;
l_proc_level                    NUMBER                                             :=FND_LOG.Level_Procedure;
l_procedure_name                VARCHAR2(100)                                      :='Check_Item_Length';
l_dbg_msg                       VARCHAR2(1000);
BEGIN

  --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter function');

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_item_number '||p_item_number);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_item_name '||p_item_name);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_tax_name '||p_tax_name);


    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_item_model '||p_item_model);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_uom  '||p_uom);
  END IF;  --( l_proc_level >= l_dbg_level )



   --Get length of attributes of the item
  l_item_number_length:=NVL(LENGTH(l_item_number),0);
  l_item_name_length:=NVL(LENGTH(l_item_name),0);
  l_tax_name_length:=NVL(LENGTH(l_tax_name),0);
  l_item_model_length:=NVL(LENGTH(l_item_model),0);
  l_uom_length:=NVL(LENGTH(l_uom),0);

  --If any fields exceed max lenth allowed, then  return false
  IF (l_item_number_length>l_item_number_max_length)                 OR
     (l_item_name_length>l_item_name_max_length)                     OR
     (l_tax_name_length>l_tax_name_max_length)                       OR
     (l_item_model_length>l_item_model_max_length)                   OR
     (l_uom_length>l_uom_max_length)
  THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;  --(l_item_number_length>l_item_number_max_length) or (l_item_name_length>l_item_name_max_length)  ....


  --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit function');
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION
WHEN OTHERS THEN
  IF(l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.string( l_proc_level
                  , G_MODULE_PREFIX || l_procedure_name || '.OTHER_EXCEPTION '
                  , SQLCODE||':'||SQLERRM);
    END IF;--(l_proc_level >= l_dbg_level)
END Check_Item_Length;


--==========================================================================
--  PROCEDURE NAME:
--
--    Export_To_Flat_File            Private
--
--  DESCRIPTION:
--
--
--    The procedure is called by export_items procedure, the purpose is to
--    export selected items to flat file
--
--  PARAMETERS:
--      In:  p_noreference            PL/SQL table to store items that can not
--                                    be export due to no cross reference
--                                    defined,although the parameter
--                                    p_item_name_source has defined
--                                    name of item should be got from item
--                                    cross reference
--           p_export_item            PL/SQL table to store items that can be
--                                    successfully exported
--           p_item_length_exp        PL/SQL table to store items that can not
--                                    be exported due to over-long
--
--      Out:
--
--
--  DESIGN REFERENCES:
--    GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005  Donghai Wang Creation
--           18-Oct-2005  Donghai Wang update code not to export tax rate any more due to
--                                     ebtax functionality
--           06-Apr-2006  Donghai Wang Remove tax rate from exception
--                                     records export to fix bug 5138356
--===========================================================================
PROCEDURE Export_To_Flat_File
(p_noreference         IN AR_GTA_TXT_OPERATOR_PROC.G_Noreference_Tbl
,p_export_item         IN AR_GTA_TXT_OPERATOR_PROC.G_Item_Tbl
,p_item_length_exp     IN AR_GTA_TXT_OPERATOR_PROC.G_Item_Tbl
)
IS
l_noreference            AR_GTA_TXT_OPERATOR_PROC.G_Noreference_Tbl  :=p_noreference;
l_export_item            AR_GTA_TXT_OPERATOR_PROC.G_Item_Tbl         :=p_export_item;
l_item_length_exp        AR_GTA_TXT_OPERATOR_PROC.G_Item_Tbl         :=p_item_length_exp;
l_idx                    NUMBER;
l_export_record          VARCHAR2(4000);
l_dbg_level              NUMBER                                       :=FND_LOG.G_Current_Runtime_Level;
l_proc_level             NUMBER                                       :=FND_LOG.Level_Procedure;
l_procedure_name         VARCHAR2(100)                                :='Export_To_Flat_file';
l_dbg_msg                VARCHAR2(1000);
BEGIN

  --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

  -- export validated item
  IF l_export_item.COUNT>0
  THEN

  --export required header section of export file
  --Line 1
    FND_MESSAGE.Set_Name(application => 'AR'
                        ,name => 'AR_GTA_ITEM_EXPORT_LNA'
                        );
    FND_MESSAGE.Set_Token(TOKEN =>'PREFIX'
                         ,VALUE => '{'
                         );
    FND_MESSAGE.Set_Token(TOKEN =>'MIDFIX'
                         ,VALUE => '}['
                         );
    FND_MESSAGE.Set_Token(TOKEN =>'SUFFIX'
                         ,VALUE => ']"~~"'
                         );
    FND_FILE.Put_Line(FND_FILE.Output,FND_MESSAGE.GET);

    --Line2
    FND_MESSAGE.Set_Name(application => 'AR'
                        ,name => 'AR_GTA_CUSTOMER_EXPORT_LNB'
                        );
    FND_MESSAGE.Set_Token(TOKEN =>'PREFIX'
                         ,VALUE => '//'
                         );
    FND_MESSAGE.Set_Token(TOKEN =>'SUFFIX'
                         ,VALUE => ':'
                         );
    FND_FILE.Put_Line(FND_FILE.Output,FND_MESSAGE.GET);

    --Line3
    FND_MESSAGE.Set_Name(application => 'AR'
                        ,name => 'AR_GTA_ITEM_EXPORT_LNB'
                        );
    FND_MESSAGE.Set_Token(TOKEN =>'PREFIX'
                         ,VALUE => '//'
                         );
    FND_MESSAGE.Set_Token(TOKEN =>'MIDFIX'
                         ,VALUE => '~~'
                         );
    FND_FILE.Put_Line(FND_FILE.Output,FND_MESSAGE.GET);

    l_idx:='';
    l_idx:=l_export_item.FIRST;
    WHILE l_idx IS NOT NULL
    LOOP

    --Comment following statement out to not export tax rate anymore
     /* l_export_record:=l_export_item(l_idx).item_number||'~~'||
                       l_export_item(l_idx).item_name||'~~'
                       ||'~~'
                       ||l_export_item(l_idx).tax_name||'~~'
                       ||l_export_item(l_idx).tax_rate||'~~'
                       ||l_export_item(l_idx).item_model||'~~'
                       ||l_export_item(l_idx).uom||'~~'
                       ||'~~'
                       ;*/

     --Updated statement
      l_export_record:=l_export_item(l_idx).item_number||'~~'||
                       l_export_item(l_idx).item_name||'~~'
                       ||'~~'
                       ||l_export_item(l_idx).tax_name||'~~'
                       ||'~~'
                       ||l_export_item(l_idx).item_model||'~~'
                       ||l_export_item(l_idx).uom||'~~'
                       ||'~~'
                       ;

      FND_FILE.Put_Line(FND_FILE.Output,l_export_record);
      l_idx:=l_export_item.NEXT(l_idx);
    END LOOP; --   l_idx IS NOT NULL
  END IF;  --l_export_item.COUNT>0


  --export exception item records
  IF l_noreference.COUNT>0
  THEN                    --export items that don't define cross reference
    FND_FILE.Put_Line(FND_FILE.Output,'//******************************');
    FND_MESSAGE.Set_Name('AR','AR_GTA_ITEM_MISSING_CROSS_REF');
    FND_FILE.Put_Line(FND_FILE.Output,'//'||FND_MESSAGE.Get);

    l_idx:='';
    l_idx:=l_noreference.FIRST;
    WHILE l_idx IS NOT NULL
    LOOP
      l_export_record:='//'||l_noreference(l_idx);
      FND_FILE.Put_Line(FND_FILE.Output,l_export_record);
      l_idx:=l_noreference.NEXT(l_idx);
    END LOOP; -- l_idx IS NOT NULL

    FND_FILE.Put_Line(FND_FILE.Output,'//******************************');
  END IF;  --l_noreference.COUNT>0

  IF l_item_length_exp.COUNT>0
  THEN      --export items that exceed length limitation
    FND_FILE.Put_Line(FND_FILE.Output,'//******************************');
    FND_MESSAGE.Set_Name('AR','AR_GTA_EXCEED_LENGTH');
    FND_FILE.Put_Line(FND_FILE.Output,'//'||FND_MESSAGE.Get);

    l_idx:='';
    l_idx:=l_item_length_exp.FIRST;
    WHILE l_idx IS NOT NULL
    LOOP
      l_export_record:='//'
                       ||l_item_length_exp(l_idx).item_number||'~~'
                       ||l_item_length_exp(l_idx).item_name||'~~'
                       ||'~~'
                       ||l_item_length_exp(l_idx).tax_name||'~~'
                       ||'~~'
                       ||l_item_length_exp(l_idx).item_model||'~~'
                       ||l_item_length_exp(l_idx).uom||'~~'
                       ||'~~'
                       ;

      FND_FILE.Put_Line(FND_FILE.Output,l_export_record);
      l_idx:=l_item_length_exp.NEXT(l_idx);
    END LOOP;  --l_idx IS NOT NULL

    FND_FILE.Put_Line(FND_FILE.Output,'//******************************');
  END IF;  --l_item_lengh_exp.COUNT>0

  --log for debug
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION
  WHEN OTHERS THEN
    IF(l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX || l_procedure_name || '.OTHER_EXCEPTION '
                    , SQLCODE||':'||SQLERRM);
      END IF;--(l_proc_level >= l_dbg_level)

END Export_To_Flat_File;

--==========================================================================
--  PROCEDURE NAME:
--
--    Export_Items                    Public
--
--  DESCRIPTION:
--
--    This procedure is to export item information from
--    inventory to a flat file with special format, the flat
--    will be used as import file to import items into GT system
--
--  PARAMETERS:
--      In:  p_org_id                 Identifier for Operating Unit
--           p_master_org_id          Identifier for Master Organization
--                                    of inventory organization
--           p_item_num_from          High range of item number
--           p_item_num_to            Low range of item number
--           p_category_set_id        Identifier of item category set
--           p_category_structure_id  Identifier for structure of item
--                                    category
--           p_item_category_from     High range of item category
--           p_item_category_to       Low range of item category
--           p_item_name_source       Iten name source, alternative
--                                    value is 'MASTER_ITEM' or
--                                    'LATEST_ITEM_CROSS_REFERENCE',
--                                    this parameter is to decide
--                                    where item name is got from
--           p_cross_reference_type   Cross reference type of item
--           p_item_status            Item status
--           p_creation_date_from     High range of item creation date
--           p_creation_date_to       Low range of item creation date
--
--      Out:
--
--
--  DESIGN REFERENCES:
--    GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005  Donghai Wang Creation
--           06-MAR-2006  Donghai Wang Add fnd log
--           06-Apr-2006  Donghai Wang Remove tax rate from the procedure
--                                     for fix bug 5138356
--           18-Mar-2009  Yao Zhang modified for bug 7812065
--           19-Mar-2009  Yao Zhang modified for bug 8339490
--===========================================================================
PROCEDURE Export_items
( p_org_id                 IN  NUMBER
, p_master_org_id          IN  NUMBER
, p_item_num_from          IN  VARCHAR2
, p_item_num_to            IN  VARCHAR2
, p_category_set_id        IN  NUMBER
, p_category_structure_id  IN  NUMBER
, p_item_category_from     IN  VARCHAR2
, p_item_category_to       IN  VARCHAR2
, p_item_name_source       IN  VARCHAR2
, p_cross_reference_type   IN  VARCHAR2
, p_item_status            IN  VARCHAR2
, p_creation_date_from     IN  VARCHAR2
, p_creation_date_to       IN  VARCHAR2
)
IS
l_org_id                       NUMBER                                                             :=p_org_id;
l_master_org_id                NUMBER                                                             :=p_master_org_id;
l_item_num_from                mtl_system_items_b_kfv.concatenated_segments%TYPE                  :=p_item_num_from;
l_item_num_to                  mtl_system_items_b_kfv.concatenated_segments%TYPE                  :=p_item_num_to;
l_category_set_id              mtl_category_sets_b.category_set_id%TYPE                           :=p_category_set_id;
l_structure_id                 mtl_category_sets_b.structure_id%TYPE                              :=p_category_structure_id;
l_item_category_from           mtl_categories_b_kfv.concatenated_segments%TYPE                    :=p_item_category_from;
l_item_category_to             mtl_categories_b_kfv.concatenated_segments%TYPE                    :=p_item_category_to;
l_creation_date_from           DATE;
l_creation_date_to             DATE;
l_export_item_count            NUMBER;
l_item_name                    mtl_system_items_b.description%TYPE;
l_item_name_source             VARCHAR2(30)                                                       :=p_item_name_source;
l_inventory_item_id            mtl_system_items_b.inventory_item_id%TYPE;
l_cross_reference_type         mtl_cross_references.cross_reference_type%TYPE                     :=p_cross_reference_type;
l_item_number                  mtl_system_items_b_kfv.concatenated_segments%TYPE;
l_item_attribute_category      fnd_descr_flex_column_usages.descriptive_flex_context_code%TYPE;
l_tax_name_column              fnd_descr_flex_column_usages.application_column_name%TYPE;
l_item_model_column            fnd_descr_flex_column_usages.application_column_name%TYPE;
l_tax_name                     mtl_system_items_b.attribute1%TYPE;
l_item_model                   mtl_system_items_b.attribute1%TYPE;
l_dbg_msg                      VARCHAR2(1000);
l_item_status                  MTL_ITEM_STATUS.INVENTORY_ITEM_STATUS_CODE%TYPE                    :=p_item_status;

CURSOR c_item IS
SELECT
  DISTINCT
  items.inventory_item_id
 ,items.concatenated_segments    item_number
 ,items.DESCRIPTION              item_name
--,items.primary_unit_of_measure  uom Yao Zhang comment for bug 8339490
 ,muom.unit_of_measure_tl        uom
FROM
  mtl_system_items_b_kfv         items
 ,mtl_item_categories            mic
 ,mtl_category_sets_b            mcs
 ,mtl_categories_b_kfv           mc
,mtl_units_of_measure_tl        muom --yao zhang add for bug 8339490
WHERE items.organization_id=l_master_org_id
  AND items.inventory_item_status_code=nvl(l_item_status,items.inventory_item_status_code)
  AND items.concatenated_segments>=nvl(l_item_num_from,items.concatenated_segments)
  AND items.concatenated_segments<=nvl(l_item_num_to,items.concatenated_segments)
  AND items.creation_date BETWEEN NVL(l_creation_date_from,items.creation_date)
                             AND NVL(l_creation_date_to,items.creation_date)
  AND mic.organization_id(+)=l_master_org_id
  AND mic.inventory_item_id(+)=items.inventory_item_id
  AND ((mic.category_set_id=l_category_set_id) OR (l_category_set_id IS NULL))
  AND mic.category_set_id=mcs.category_set_id(+)
  AND mic.category_id=mc.category_id(+)
  AND ((mcs.structure_id=l_structure_id) OR (l_structure_id IS NULL))
  AND ((mc.concatenated_segments>=l_item_category_from) OR (l_item_category_from IS NULL))
  AND ((mc.concatenated_segments<=l_item_category_to) OR (l_item_category_to IS NULL))
  --Yao Zhang add for bug 8339490
  AND muom.uom_code = items.primary_uom_code
  AND muom.LANGUAGE = userenv('LANG');
  --Yao Zhang add end;

l_item                         c_item%ROWTYPE;

CURSOR c_reference_desc IS
SELECT

  reference1.cross_reference
FROM
  mtl_cross_references reference1
WHERE reference1.inventory_item_id=l_inventory_item_id
 AND (reference1.organization_id=l_master_org_id OR reference1.organization_id IS NULL)
 AND reference1.cross_reference_type=l_cross_reference_type
 AND reference1.creation_date=(SELECT
                                 MAX(creation_date)
                               FROM
                                 mtl_cross_references reference2
                               WHERE reference2.inventory_item_id=l_inventory_item_id
                                 AND (reference2.organization_id=l_master_org_id OR  reference2.organization_id IS NULL)
                                 AND reference2.cross_reference_type=l_cross_reference_type
                               );

CURSOR c_get_dff IS
SELECT
  inv_item_context_code
 ,inv_tax_attribute_column
 ,inv_model_attribute_column
FROM
  ar_gta_system_parameters
WHERE
  org_id=l_org_id;


l_noreference g_noreference_tbl;

l_noreference_idx  NUMBER;

CURSOR c_tax_name IS
SELECT
  decode(l_tax_name_column
        ,'ATTRIBUTE1'
        ,ATTRIBUTE1
        ,'ATTRIBUTE2'
        ,ATTRIBUTE2
        ,'ATTRIBUTE3'
        ,ATTRIBUTE3
        ,'ATTRIBUTE4'
        ,ATTRIBUTE4
        ,'ATTRIBUTE5'
        ,ATTRIBUTE5
        ,'ATTRIBUTE6'
        ,ATTRIBUTE6
        ,'ATTRIBUTE7'
        ,ATTRIBUTE7
        ,'ATTRIBUTE8'
        ,ATTRIBUTE8
        ,'ATTRIBUTE9'
        ,ATTRIBUTE9
        ,'ATTRIBUTE10'
        ,ATTRIBUTE10
        ,'ATTRIBUTE11'
        ,ATTRIBUTE11
        ,'ATTRIBUTE12'
        ,ATTRIBUTE12
        ,'ATTRIBUTE13'
        ,ATTRIBUTE13
        ,'ATTRIBUTE14'
        ,ATTRIBUTE14
        ,'ATTRIBUTE15'
        ,ATTRIBUTE15
        --Yao Zhang fix bug 7812065 add
        ,'ATTRIBUTE16'
        ,ATTRIBUTE16
        ,'ATTRIBUTE17'
        ,ATTRIBUTE17
        ,'ATTRIBUTE18'
        ,ATTRIBUTE18
        ,'ATTRIBUTE19'
        ,ATTRIBUTE19
        ,'ATTRIBUTE20'
        ,ATTRIBUTE20
        ,'ATTRIBUTE21'
        ,ATTRIBUTE21
        ,'ATTRIBUTE22'
        ,ATTRIBUTE22
        ,'ATTRIBUTE23'
        ,ATTRIBUTE23
        ,'ATTRIBUTE24'
        ,ATTRIBUTE24
        ,'ATTRIBUTE25'
        ,ATTRIBUTE25
        ,'ATTRIBUTE26'
        ,ATTRIBUTE26
        ,'ATTRIBUTE27'
        ,ATTRIBUTE27
        ,'ATTRIBUTE28'
        ,ATTRIBUTE28
        ,'ATTRIBUTE29'
        ,ATTRIBUTE29
        ,'ATTRIBUTE30'
        ,ATTRIBUTE30
        --Yao Zhang add end
        ,NULL
        )
FROM
  mtl_system_items_b
WHERE inventory_item_id=l_inventory_item_id
  AND organization_id=l_master_org_id
  AND attribute_category=l_item_attribute_category;

CURSOR c_item_model IS
SELECT

  decode(l_item_model_column
        ,'ATTRIBUTE1'
        ,ATTRIBUTE1
        ,'ATTRIBUTE2'
        ,ATTRIBUTE2
        ,'ATTRIBUTE3'
        ,ATTRIBUTE3
        ,'ATTRIBUTE4'
        ,ATTRIBUTE4
        ,'ATTRIBUTE5'
        ,ATTRIBUTE5
        ,'ATTRIBUTE6'
        ,ATTRIBUTE6
        ,'ATTRIBUTE7'
        ,ATTRIBUTE7
        ,'ATTRIBUTE8'
        ,ATTRIBUTE8
        ,'ATTRIBUTE9'
        ,ATTRIBUTE9
        ,'ATTRIBUTE10'
        ,ATTRIBUTE10
        ,'ATTRIBUTE11'
        ,ATTRIBUTE11
        ,'ATTRIBUTE12'
        ,ATTRIBUTE12
        ,'ATTRIBUTE13'
        ,ATTRIBUTE13
        ,'ATTRIBUTE14'
        ,ATTRIBUTE14
        ,'ATTRIBUTE15'
        ,ATTRIBUTE15
         --Yao Zhang fix bug 7812065 add
        ,'ATTRIBUTE16'
        ,ATTRIBUTE16
        ,'ATTRIBUTE17'
        ,ATTRIBUTE17
        ,'ATTRIBUTE18'
        ,ATTRIBUTE18
        ,'ATTRIBUTE19'
        ,ATTRIBUTE19
        ,'ATTRIBUTE20'
        ,ATTRIBUTE20
        ,'ATTRIBUTE21'
        ,ATTRIBUTE21
        ,'ATTRIBUTE22'
        ,ATTRIBUTE22
        ,'ATTRIBUTE23'
        ,ATTRIBUTE23
        ,'ATTRIBUTE24'
        ,ATTRIBUTE24
        ,'ATTRIBUTE25'
        ,ATTRIBUTE25
        ,'ATTRIBUTE26'
        ,ATTRIBUTE26
        ,'ATTRIBUTE27'
        ,ATTRIBUTE27
        ,'ATTRIBUTE28'
        ,ATTRIBUTE28
        ,'ATTRIBUTE29'
        ,ATTRIBUTE29
        ,'ATTRIBUTE30'
        ,ATTRIBUTE30
        --Yao Zhang add end
        ,NULL
        )
FROM
  mtl_system_items_b
WHERE inventory_item_id=l_inventory_item_id
  AND organization_id=l_master_org_id
  AND attribute_category=l_item_attribute_category;

l_item_length_exp                                      g_item_tbl;
l_item_length_exp_idx                                  NUMBER;

l_export_item                                          g_item_tbl;
l_export_item_idx                                      NUMBER;
l_procedure_name                                       VARCHAR2(50)         :='Export_Items';
l_dbg_level                                            NUMBER               :=FND_LOG.G_Current_Runtime_Level;
l_proc_level                                           NUMBER               :=FND_LOG.Level_Procedure;
l_nodatafound_msg                                      VARCHAR2(1000);

BEGIN

  --log for debug

  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure');

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_org_id '||p_org_id);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_master_org_id '||p_master_org_id);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_item_num_from '||p_item_num_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_item_num_to '||p_item_num_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_category_set_id '||p_category_set_id);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_category_structure_id '||p_category_structure_id);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_item_category_from '||p_item_category_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_item_category_to '||p_item_category_to);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_item_name_source '||p_item_name_source);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_cross_reference_type '||p_cross_reference_type);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_item_status '||p_item_status);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_creation_date_from '||p_creation_date_from);

    FND_LOG.STRING(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.parameters'
                  ,'p_creation_date_to '||p_creation_date_to);
  END IF;  --( l_proc_level >= l_dbg_level )


  --To convert date parameters to date type from varchar2 type

  IF p_creation_date_from IS NOT NULL
  THEN
    l_creation_date_from:=FND_DATE.Canonical_To_Date(p_creation_date_from);
  END IF;

  IF p_creation_date_to IS NOT NULL
  THEN
    l_creation_date_to:=FND_DATE.Canonical_To_Date(p_creation_date_to);
  END IF;


  l_export_item_count:=0;
  l_noreference_idx:=0;
  l_export_item_idx:=0;
  l_item_length_exp_idx:=0;

  --To get DFF definition on items
  OPEN c_get_dff;
  FETCH c_get_dff INTO l_item_attribute_category
                      ,l_tax_name_column
                      ,l_item_model_column
                      ;

  CLOSE c_get_dff;

  OPEN c_item;
  FETCH c_item INTO l_item;
  WHILE c_item%FOUND  --Find item that accord with criteria by paramters
  LOOP
    l_export_item_count:=l_export_item_count+1;
    l_item_number:=l_item.item_number;

    --Intial variables
    l_item_name:='';
    l_item_model:='';
    l_inventory_item_id:=l_item.inventory_item_id;

    --To determine item name according to value of the parameter 'P_ITEM_NAME_SOURCE'
    IF (l_item_name_source='MASTER_ITEM')  --regard item descripiton defined in Oracle EBS system as item name
    THEN
      l_item_name:=l_item.item_name;
    ELSIF (l_item_name_source='LATEST_ITEM_CROSS_REFERENCE')
    THEN

      --Get description of lastest cross referece of the item
       OPEN c_reference_desc;
      FETCH c_reference_desc INTO l_item_name;
      CLOSE c_reference_desc;
    END IF;   --(l_item_name_source='MASTER_ITEM')

    --yawang plesae move the comment on top of this code, don't make coding line too long
    IF (l_item_name IS NULL)                                        --Corss reference is not defined for this item,export this item as exception
    THEN
      l_noreference_idx:=l_noreference_idx+1;
      l_noreference(l_noreference_idx):=l_item_number;
    ELSE
      IF l_item_attribute_category IS NULL  --Not setup item context code in system option form
      THEN
        l_tax_name:='';
        l_item_model:='';
      ELSE

        --Get Tax domination
        OPEN c_tax_name;
        FETCH c_tax_name INTO l_tax_name;
        CLOSE c_tax_name;

        --Get item model
        OPEN c_item_model;
        FETCH c_item_model INTO l_item_model;
        CLOSE c_item_model;

      END IF; --l_item_attribute_category IS NULL

      --Check whether the fields that will be exorted exceed length limitation
      IF check_item_length(l_item_number

                          ,l_item_name
                          ,l_tax_name
                          ,l_item_model
                          ,l_item.uom
                          )
      THEN
        l_export_item_idx:=l_export_item_idx+1;
        l_export_item(l_export_item_idx).item_number:=l_item_number;
        l_export_item(l_export_item_idx).item_name:=l_item_name;
        l_export_item(l_export_item_idx).tax_name:=l_tax_name;
        l_export_item(l_export_item_idx).item_model:=l_item_model;
        l_export_item(l_export_item_idx).uom:=l_item.uom;
      ELSE
        l_item_length_exp_idx:=l_item_length_exp_idx+1;
        l_item_length_exp(l_item_length_exp_idx).item_number:=l_item_number;
        l_item_length_exp(l_item_length_exp_idx).item_name:=l_item_name;
        l_item_length_exp(l_item_length_exp_idx).tax_name:=l_tax_name;
        l_item_length_exp(l_item_length_exp_idx).item_model:=l_item_model;
        l_item_length_exp(l_item_length_exp_idx).uom:=l_item.uom;
      END IF;  --check_item_length(l_item_number,l_item_name,l_tax_name,l_item_model,l_item.uom)
    END IF;--(l_item_name IS NULL)

    FETCH c_item INTO l_item;

  END LOOP;--c_item%FOUND

  --Export item to flat file
  IF l_export_item_count=0
  THEN                     --no data found
    FND_MESSAGE.Set_Name('AR','AR_GTA_NO_DATA_FOUND');
    l_nodatafound_msg:='//'||FND_MESSAGE.Get;
    FND_FILE.Put_Line(FND_FILE.Output
                     ,l_nodatafound_msg
                     );
  ELSIF l_export_item_count>0
  THEN
    Export_To_Flat_File(p_noreference         =>  l_noreference
                       ,p_export_item         =>  l_export_item
                       ,p_item_length_exp     =>  l_item_length_exp
                       );
  END IF;  --l_export_item_count=0
  IF( l_proc_level >= l_dbg_level )
  THEN
    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION
 WHEN OTHERS THEN
   IF(l_proc_level >= l_dbg_level)
   THEN
     FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX || l_procedure_name || '.OTHER_EXCEPTION '
                    , SQLCODE||':'||SQLERRM);
   END IF;--(l_proc_level >= l_dbg_level)
END Export_items;

END AR_GTA_TXT_OPERATOR_PROC;

/
