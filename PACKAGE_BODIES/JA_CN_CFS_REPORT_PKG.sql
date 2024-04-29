--------------------------------------------------------
--  DDL for Package Body JA_CN_CFS_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_CFS_REPORT_PKG" AS
  --$Header: JACNCFDB.pls 120.18.12010000.7 2009/09/29 05:24:22 wuwu ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|      JACNCFDB.pls                                                     |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used to generate the CFS detail report.           |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|                                                                       |
  --|      PROCEDURE    Cfs_Detail_Report     PUBLIC                        |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      27/04/2007     Qingjun Zhao         Created                      |
  --|      28/02/2008     Arming Chen          Fix bug#6751696              |
  --|      01/03/2008     Xiao Lv              Fix bug#6854438              |
  --|      03/03/2008     Arming Chen          Fix bug#6859513              |
  --|      03/11/2008     Xiao Lv,Arming Chen  Fix bug#6697073              |
  --|      03/27/2008     Arming Chen          Fix bug#6920953              |
  --|      08/09/2008     Yao Zhang            Fix bug#7334017 for R12      |
  --|                                                            enhancement|
  --|      17/10/2008     Yao Zhang            fix bug 7487373              |
  --|                                          DETAIL REPORT SHOW AR/AP     |
  --|                                          NUMBER FOR GL/AGIS DATA      |
  --|      17/10/2008     Yao Zhang            Fix bug7487395  DETAIL REPORT|
  --|                                          SHOW ONE MEANINGLESS BLANK   |
  --|                                          TITLE LINE when fun_amount is 0
  --|      21/10/2008     Yao Zhang            Fix bug #7497957 AP/AR DATA  |
  --|                                          WILL BE SHOWN TWICE WHEN DATA|
  --|                                          WITH AMOUNT 0 EXIST          |
  --|      21/10/2008     Yao Zhang            Fix bug 7488223              |
  --|                                          DATA COLLECTION PROGRAM      |
  --|                                          COLLECT AGIS DATA BEYOND BSV |
  --|                                          QUALIFICATION(Detail report  |
  --|                                          should filter data according |
  --|                                          to bsv)                      |
  --|     16/12/2008      Shujuan Yan          Fix bug 7626489
  --|     19/05/2009      Chaoqun Wu           Fix bug#8469791
  --|     18/09/2009      shujuan Yan          Fix bug 8395411 and 8395408  |
  --|     23/09/2009      Chaoqun Wu           Fix bug 8937433 for fixing   |
  --|                                          unclearing case              |
  --|     29/09/2009      Chaoqun Wu           Fix bug 8969631 for fixing   |
  --|                                          cancelled payment and        |
  --|                                          reversed receipt.            |
  --+======================================================================*/
  TYPE NUMBER_TBL IS VARRAY(100) OF NUMBER;
  --TYPE INVOICE_NUM_TBL IS VARRAY(100) OF VARCHAR2(50); --Deleted by Chaoqun for fixing bug#8469791
  TYPE INVOICE_NUM_TBL IS VARRAY(100) OF VARCHAR2(200); --Updated by Chaoqun for fixing bug#8469791
  --==========================================================================
  --  PROCEDURE NAME:
  --    Process_AP_Detail                 Public
  --
  --  DESCRIPTION:
  --    This procedure is used to get detail infromation for transaction in AR
  --
  --  PARAMETERS:
  --      In: P_LEDGER_ID             ID of Ledger
  --      In: P_AE_HEADER_ID          ID of SLA journal header
  --      In: P_AE_LINE_NUM           SLA journal line number
  --      Out: X_TRX_NUMBER           Transaction number
  --      Out: X_INVOICE_NUMBER       Invoice number
  --      Out: X_THIRD_PARTY_NAME     Third Party Name
  --      Out: X_THIRD_PARTY_NUM      Third Party Number
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      05/08/2007     Qingjun Zhao          Created
  --      23/09/2009     Chaoqun Wu            Fix bug 8937433
  --      29/09/2009      Chaoqun Wu           Fix bug 8969631
  --===========================================================================

  PROCEDURE Process_Ap_Detail(p_Ledger_Id        IN NUMBER,
                              p_Ae_Header_Id     IN NUMBER,
                              p_Ae_Line_Num      IN NUMBER,
                              P_FUNC_AMOUNT      IN NUMBER, --Fix bug# 8395411 by Shujuan
                              x_Trx_Number       OUT NOCOPY VARCHAR2,
                              p_Cash_Ae_Header_Id IN NUMBER,  --Added by Chaoqun for fixing bug 8969631
                              p_Cash_Ae_Line_Num  IN NUMBER, --Added by Chaoqun for fixing bug 8969631

                              -- Fix bug#6697073 begin -------------------------
                              -- x_Invoice_Num      OUT NOCOPY VARCHAR2,   --updated for bug  6697073
                              x_Func_Amount      OUT NOCOPY NUMBER_TBL, --updated for bug  6697073

                              x_Invoice_Num      OUT NOCOPY INVOICE_NUM_TBL, --updated for bug  6697073
                              -- Fix bug#6697073 end ----------------------------

                              x_Third_Party_Name OUT NOCOPY VARCHAR2,
                              x_Third_Party_Num  OUT NOCOPY varchar2) IS
    l_Invoice_Id NUMBER;
    l_Dbg_Level  NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name  VARCHAR2(100) := 'Process_Ap_Detail';

    --Fix bug#6697073 begin----------------------------------------
    l_Invoice_idx  NUMBER:=0;
    l_invoice_num_temp   varchar2(60);
    l_invoice_num_array  INVOICE_NUM_TBL := INVOICE_NUM_TBL();
    l_func_amount number;
    l_func_amount_array NUMBER_TBL := NUMBER_TBL();

    cursor c_trx_number is
    SELECT Aca.Check_Number, Pv.Vendor_Name, Pv.Segment1
      FROM Ap_Checks_All            Aca,
           Xla_Transaction_Entities Ent,
           Xla_Ae_Headers           Aeh,
           Po_Vendors               Pv
     WHERE Ent.Application_Id = 200
       AND Aca.Check_Id = Ent.Source_Id_Int_1
       AND Aca.Vendor_Id = Pv.Vendor_Id(+)
       AND Ent.Entity_Code = 'AP_PAYMENTS'
       AND Ent.Entity_Id = Aeh.Entity_Id
       AND Aeh.Ae_Header_Id = p_Ae_Header_Id
       AND Aeh.Ledger_Id = p_Ledger_Id;

   cursor c_invoice_id is
    --Begin: Updated for fixing bug 8937433, 8969631 by Chaoqun
       SELECT xdl.Applied_To_Source_Id_Num_1,
              DECODE((SELECT xah.event_type_code
                        FROM xla_ae_headers xah
                       WHERE xah.Ae_Header_Id = p_Cash_Ae_Header_Id
                         AND rownum = 1
                      ),
                     'PAYMENT UNCLEARED',
                     DECODE(NVL(xdl.UNROUNDED_ACCOUNTED_DR, '-1'),
                                 '-1',
                             -1 * xdl.UNROUNDED_ACCOUNTED_CR,
                             xdl.UNROUNDED_ACCOUNTED_DR),
                      DECODE(NVL(xdl.UNROUNDED_ACCOUNTED_DR, '-1'),
                           '-1',
                              xdl.UNROUNDED_ACCOUNTED_CR,
                              -1 * xdl.UNROUNDED_ACCOUNTED_DR)
                           )
     --End: Updated for fixing bug 8937433, 8969631 by Chaoqun
      FROM Xla_Distribution_Links xdl
     WHERE xdl.Ae_Header_Id = p_Ae_Header_Id
       AND xdl.Ae_Line_Num = p_Ae_Line_Num;
     --Fix bug#6697073 end----------------------------------------


  BEGIN
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'P_AE_HEADER_ID ' || p_Ae_Header_Id);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'P_AE_LINE_NUM' || p_Ae_Line_Num);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'P_LEDGER_ID ' || p_Ledger_Id);
    END IF; --(l_proc_level >= l_dbg_level)

    --Fix bug#6697073 begin-------------------------------------------------------
     OPEN  c_trx_number;
     FETCH c_trx_number
     INTO x_Trx_Number, x_Third_Party_Name, x_Third_Party_Num;
     CLOSE C_trx_number;
     Fnd_File.Put_Line(Fnd_File.Log,x_Trx_Number||','||x_Third_Party_Name||','|| x_Third_Party_Num);

/*    SELECT Aca.Check_Number, Pv.Vendor_Name, Pv.Segment1
      INTO x_Trx_Number, x_Third_Party_Name, x_Third_Party_Num
      FROM Ap_Checks_All            Aca,
           Xla_Transaction_Entities Ent,
           Xla_Ae_Headers           Aeh,
           Po_Vendors               Pv
     WHERE Ent.Application_Id = 200
       AND Aca.Check_Id = Ent.Source_Id_Int_1
       AND Aca.Vendor_Id = Pv.Vendor_Id(+)
       AND Ent.Entity_Code = 'AP_PAYMENTS'
       AND Ent.Entity_Id = Aeh.Entity_Id
       AND Aeh.Ae_Header_Id = p_Ae_Header_Id
       AND Aeh.Ledger_Id = p_Ledger_Id; */

    --Get invoice id for current SLA journal line

    open C_invoice_id;
    loop
      FETCH c_invoice_id
      INTO  l_Invoice_Id,l_func_amount;
      exit when C_invoice_id%NOTFOUND;
         l_Invoice_idx:=l_Invoice_idx+1;
          IF l_invoice_id is not null
          THEN
            SELECT Invoice_Num
              INTO l_invoice_num_temp
              FROM Ap_Invoices_all
             WHERE Invoice_Id = l_Invoice_Id;
           ELSE
             l_invoice_num_temp:='';
           END IF;
         l_invoice_num_array.EXTEND;
         l_func_amount_array.EXTEND;
         l_invoice_num_array(l_Invoice_idx):= l_invoice_num_temp;
         l_func_amount_array(l_Invoice_idx):= l_func_amount; /*P_func_amount; -- for bug 8395408 by Shujuan*/

          Fnd_File.Put_Line(Fnd_File.Log,l_invoice_id);
     END LOOP;
    CLOSE C_invoice_id;

    x_Invoice_Num:= l_invoice_num_array;
    x_Func_Amount:= l_func_amount_array;

/*    SELECT DISTINCT Applied_To_Source_Id_Num_1
      INTO l_Invoice_Id
      FROM Xla_Distribution_Links
     WHERE Ae_Header_Id = p_Ae_Header_Id
       AND Ae_Line_Num = p_Ae_Line_Num;
    -- get invoice number for current invoice
    IF l_invoice_id is not null
    THEN
      SELECT Invoice_Num
        INTO x_Invoice_Num
        FROM Ap_Invoices
       WHERE Invoice_Id = l_Invoice_Id;
     ELSE
       x_invoice_num:='';
     END IF;*/
     -- Fix bug#6697073 end--------------------------------------------------------

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level )

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '.Other_Exception AP',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      FND_FILE.PUT_LINE(Fnd_File.Log,'AP'||SQLCODE || ':' || SQLERRM);
      RAISE;
  END Process_Ap_Detail;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Process_Ar_Detail                 Public
  --
  --  DESCRIPTION:
  --    This procedure is used to get detail infromation for transaction in AR
  --
  --  PARAMETERS:
  --      In: P_LEDGER_ID             ID of Ledger
  --      In: P_AE_HEADER_ID          ID of SLA journal header
  --      In: P_AE_LINE_NUM           SLA journal line number
  --      Out: X_TRX_NUMBER           Transaction number
  --      Out: X_INVOICE_NUMBER       Invoice number
  --      Out: X_THIRD_PARTY_NAME     Third Party Name
  --      Out: X_THIRD_PARTY_NUM      Third Party Number
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      05/08/2007     Qingjun Zhao          Created
  --      23/09/2009     Chaoqun Wu            Fix bug 8937433
  --      29/09/2009     Chaoqun Wu            Fix bug 8969631
  --===========================================================================

  PROCEDURE Process_Ar_Detail(p_Ledger_Id        IN NUMBER,
                              p_Ae_Header_Id     IN NUMBER,
                              p_Ae_Line_Num      IN NUMBER,
                              P_FUNC_AMOUNT      IN NUMBER,  -- For bug 8395408 by Shujuan
                              x_Trx_Number       OUT NOCOPY VARCHAR2,
                              p_Cash_Ae_Header_Id IN NUMBER,  --Added by Chaoqun for fixing bug 8969631
                              p_Cash_Ae_Line_Num  IN NUMBER, --Added by Chaoqun for fixing bug 8969631
                            --x_Invoice_Num      OUT NOCOPY VARCHAR2,   --Fix bug#6697073
                              x_Func_Amount      OUT NOCOPY NUMBER_TBL, --Fix bug#6697073
                              x_Invoice_Num      OUT NOCOPY INVOICE_NUM_TBL, --Fix bug#6697073
                              x_Third_Party_Name OUT NOCOPY VARCHAR2,
                              x_Third_Party_Num  OUT NOCOPY varchar2) IS
    l_Customer_Trx_Id NUMBER;
    l_Dbg_Level       NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level      NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name       VARCHAR2(100) := 'Process_Ar_Detail';

    --Fix bug#6697073 begin-----------------------------------------------------
    l_Invoice_idx  NUMBER:=0;
    l_invoice_num_temp   varchar2(60);
    l_invoice_num_array  INVOICE_NUM_TBL := INVOICE_NUM_TBL();
    l_func_amount number;
    l_func_amount_array NUMBER_TBL := NUMBER_TBL();
    CURSOR c_trx_number is
    SELECT Aca.Receipt_Number, Hp.Party_Name, Cust.Account_Number
      FROM Ar_Cash_Receipts_All     Aca,
           Xla_Transaction_Entities Ent,
           Xla_Ae_Headers           Aeh,
           Hz_Cust_Accounts         Cust,
           Hz_Parties               Hp
     WHERE Ent.Application_Id = 222
       AND Aca.Cash_Receipt_Id = Ent.Source_Id_Int_1
       AND Aca.Pay_From_Customer = Cust.Cust_Account_Id(+)
       AND Cust.Party_Id = Hp.Party_Id(+)
       AND Ent.Entity_Code = 'RECEIPTS'
       AND Ent.Entity_Id = Aeh.Entity_Id
       AND Aeh.Ae_Header_Id = p_Ae_Header_Id
       AND Aeh.Ledger_Id = p_Ledger_Id;
    CURSOR c_custom_trx_id is

     --Begin: Updated for fixing bug 8937433, 8969631 by Chaoqun
       SELECT xdl.Applied_To_Source_Id_Num_1 + 0,
              DECODE((SELECT xah.event_type_code
                        FROM xla_ae_headers xah
                       WHERE xah.Ae_Header_Id = p_Cash_Ae_Header_Id
                         AND rownum = 1
                      ),
                     'RECP_UPDATE',
                     DECODE((SELECT ach.status
                               FROM ar_cash_receipt_history_all ach,
                                    xla_ae_headers ah
                              WHERE ah.ae_header_id = p_Cash_Ae_Header_Id
                                AND  ah.event_id = ach.event_id
                                AND rownum = 1),
                            'REMITTED',
                            DECODE(NVL(xdl.UNROUNDED_ACCOUNTED_DR, '-1'),
                                 '-1',
                                   -1 * xdl.UNROUNDED_ACCOUNTED_CR,
                                   xdl.UNROUNDED_ACCOUNTED_DR),
                            DECODE(NVL(xdl.UNROUNDED_ACCOUNTED_DR, '-1'),
                             '-1',
                              xdl.UNROUNDED_ACCOUNTED_CR,
                              -1 * xdl.UNROUNDED_ACCOUNTED_DR)
                           ),
                      DECODE(NVL(xdl.UNROUNDED_ACCOUNTED_DR, '-1'),
                           '-1',
                              xdl.UNROUNDED_ACCOUNTED_CR,
                              -1 * xdl.UNROUNDED_ACCOUNTED_DR)
                            )
     --End: Updated for fixing bug 8937433, 8969631 by Chaoqun
      FROM Xla_Distribution_Links xdl
     WHERE xdl.Ae_Header_Id = p_Ae_Header_Id
       AND xdl.Ae_Line_Num = p_Ae_Line_Num;
     --Fix bug#6697073 end----------------------------------------


  BEGIN
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'P_AE_HEADER_ID ' || p_Ae_Header_Id);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'P_AE_LINE_NUM' || p_Ae_Line_Num);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'P_LEDGER_ID ' || p_Ledger_Id);
    END IF; --(l_proc_level >= l_dbg_level)

    --Fix bug#6697073 begin-------------------------------------------------------

/*    SELECT Aca.Receipt_Number, Hp.Party_Name, Cust.Account_Number
      INTO x_Trx_Number, x_Third_Party_Name, x_Third_Party_Num
      FROM Ar_Cash_Receipts_All     Aca,
           Xla_Transaction_Entities Ent,
           Xla_Ae_Headers           Aeh,
           Hz_Cust_Accounts         Cust,
           Hz_Parties               Hp
     WHERE Ent.Application_Id = 222
       AND Aca.Cash_Receipt_Id = Ent.Source_Id_Int_1
       AND Aca.Pay_From_Customer = Cust.Cust_Account_Id(+)
       AND Cust.Party_Id = Hp.Party_Id(+)
       AND Ent.Entity_Code = 'RECEIPTS'
       AND Ent.Entity_Id = Aeh.Entity_Id
       AND Aeh.Ae_Header_Id = p_Ae_Header_Id
       AND Aeh.Ledger_Id = p_Ledger_Id; */

    OPEN C_trx_number;
    FETCH C_trx_number
     INTO x_Trx_Number, x_Third_Party_Name, x_Third_Party_Num;
    CLOSE c_trx_number;

    open c_custom_trx_id;
    loop
      FETCH c_custom_trx_id
      INTO  l_Customer_Trx_Id,l_func_amount;
      exit when c_custom_trx_id%NOTFOUND;

         l_Invoice_idx:=l_Invoice_idx+1;
          IF l_Customer_Trx_Id is not null
          THEN
             SELECT Trx_Number
              INTO l_invoice_num_temp
              FROM Ra_Customer_Trx_All
             WHERE Customer_Trx_Id = l_Customer_Trx_Id;
           ELSE
             l_invoice_num_temp:='';
           END IF;
         l_invoice_num_array.EXTEND;
         l_func_amount_array.EXTEND;
         l_invoice_num_array(l_Invoice_idx):= l_invoice_num_temp;
         l_func_amount_array(l_Invoice_idx):= l_func_amount; /*p_func_amount; -- for bug 8395408 by Shujuan*/
     END LOOP;
    CLOSE c_custom_trx_id;

    x_Invoice_Num:= l_invoice_num_array;
    x_Func_Amount:= l_func_amount_array;

    /*
    --Get transaction ID
    SELECT DISTINCT Applied_To_Source_Id_Num_1+0
      INTO l_Customer_Trx_Id
      FROM Xla_Distribution_Links
     WHERE Ae_Header_Id = p_Ae_Header_Id
       AND Ae_Line_Num = p_Ae_Line_Num;
    --get invoice number
    IF L_CUSTOMER_TRX_ID IS NOT NULL
    THEN
      SELECT Trx_Number
        INTO x_Invoice_Num
        FROM Ra_Customer_Trx_All
       WHERE Customer_Trx_Id = l_Customer_Trx_Id;
    ELSE
      X_INVOICE_NUM:=to_char(null);
    END IF; --L_CUSTOMER_TRX_ID IS NOT NULL
    */


    --Fix bug#6697073 end---------------------------------------------------------

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Exit procedure');

    END IF; --( l_proc_level >= l_dbg_level )

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '.Other_Exception AR',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      /*
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                          'ar' ||sqlcode||sqlerrm);
      fnd_file.put_line(fnd_file.log,'p_Ledger_Id:'||p_Ledger_Id||',p_Ae_Line_Num'||p_Ae_Line_Num||',p_Ae_Header_Id'||p_Ae_Header_Id);*/
      RAISE;
  END Process_Ar_Detail;
  --==========================================================================
  --  PROCEDURE NAME:
  --    Cfs_Detail_Report                 Public
  --
  --  DESCRIPTION:
  --      This procedure is to generate the cfs detail report.
  --
  --  PARAMETERS:
  --      Out: errbuf
  --      Out: retcode
  --      In: P_LEGAL_ENTITY_ID       ID of Legal Entity
  --      In: P_LEDGER_ID             ID of Ledger
  --      In: P_Chart_of_accounts_ID  Identifier of gl chart of account
  --      In: P_ADHOC_PREFIX          Ad hoc prefix for FSG report, a required
  --                                  parameter for FSG report
  --      In: P_INDUSTRY              Industry with constant value 'C' for
  --                                  now, a required parameter for FSG report
  --      In: P_ID_FLEX_CODE          ID flex code, a required parameter for
  --                                  FSG report
  --      In: P_REPORT_ID             Identifier of FSG report
  --      In: P_GL_PERIOD_FROM        Start period
  --      In: P_GL_PERIOD_TO          End period
  --      In: P_SOURCE                Source of the collection
  --      In: P_INTERNAL_TRX          To indicate if intercompany transactions
  --                                  should be involved in amount calculation
  --                                  of cash flow statement.
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      04/27/2007     Qingjun Zhao          Created
  --      28/12/2008     Shujuan Yan           bug fixing 7626489
  --===========================================================================

  PROCEDURE CFS_DETAIL_REPORT
  (
    ERRBUF                 OUT NOCOPY VARCHAR2
   ,RETCODE                OUT NOCOPY VARCHAR2
   ,P_LEGAL_ENTITY_ID      IN NUMBER
   ,P_LEDGER_ID            IN NUMBER
   ,P_CHART_OF_ACCOUNTS_ID IN NUMBER
   ,P_ADHOC_PREFIX         IN VARCHAR2
   ,P_INDUSTRY             IN VARCHAR2
   ,P_ID_FLEX_CODE         IN VARCHAR2
   ,P_REPORT_ID            IN NUMBER
   ,P_ROW_SET_ID           IN NUMBER
   -- Fix bug#6751696 delete begin
   --,P_ROW_NAME         IN VARCHAR2
   -- Fix bug#6751696 delete end
   -- Fix bug#6751696 add begin
   ,P_ROW_NAME         IN NUMBER
   -- Fix bug#6751696 add end
   ,P_GL_PERIOD_FROM       IN VARCHAR2
   ,P_GL_PERIOD_TO         IN VARCHAR2
   ,P_SOURCE               IN VARCHAR2
   ,P_BSV                  IN VARCHAR2--Fix bug#7334017  add
  ) IS

    L_DBG_LEVEL  NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    L_PROC_LEVEL NUMBER := FND_LOG.LEVEL_PROCEDURE;
    L_PROC_NAME  VARCHAR2(100) := 'Cfs_Detail_Report';
    L_LE_NAME            HR_ALL_ORGANIZATION_UNITS.NAME%TYPE;
    L_PERIOD_NUM_FROM    GL_PERIODS.PERIOD_NUM%TYPE;
    L_PERIOD_NUM_TO      GL_PERIODS.PERIOD_NUM%TYPE;
    L_DATE_FROM          GL_PERIODS.START_DATE%TYPE;
    L_DATE_TO            GL_PERIODS.END_DATE%TYPE;
    L_PERIOD_SET_NAME    GL_PERIODS.PERIOD_SET_NAME%TYPE;
    L_PERIOD_TYPE        GL_SETS_OF_BOOKS.ACCOUNTED_PERIOD_TYPE%TYPE;
    L_YEAR_FROM          GL_PERIODS.PERIOD_YEAR%TYPE;
    L_YEAR_TO            GL_PERIODS.PERIOD_YEAR%TYPE;
    L_TRX_ID             NUMBER;
    L_TRX_LINE_ID        NUMBER;

    -- Fix bug#6697073 begin ------------------------
    -- L_INVOICE_NUM        varchar2(100);
    -- L_TRX_NUMBER         varchar2(100);
    L_INVOICE_NUM        varchar2(240):=null;
    --L_INVOICE_NUM1       INVOICE_NUM_TBL;-- Fix bug#6920953 delete
    L_INVOICE_NUM1       INVOICE_NUM_TBL := INVOICE_NUM_TBL();-- Fix bug#6920953 add
    L_TRX_NUMBER         varchar2(240):=null;
    -- Fix bug#6697073 end --------------------------

    L_CASH_TRX_ID         NUMBER; --Added by Chaoqun for fixing bug 8969631
    L_CASH_TRX_LINE_ID    NUMBER; --Added by Chaoqun for fixing bug 8969631

    L_PERIOD_NUM         GL_PERIODS.PERIOD_NUM%TYPE;
    L_PERIOD_NAME        JA_CN_CFS_ACTIVITIES_ALL.PERIOD_NAME%TYPE;
    L_FUNC_AMOUNT        JA_CN_CFS_ACTIVITIES_ALL.FUNC_AMOUNT%TYPE;
    L_ORIGINAL_AMOUNT    JA_CN_CFS_ACTIVITIES_ALL.ORIGINAL_AMOUNT%TYPE;
    L_DETAILED_CFS_ITEM  JA_CN_CFS_ACTIVITIES_ALL.DETAILED_CFS_ITEM%TYPE;
    L_THIRD_PARTY_NAME   varchar2(100);
    L_THIRD_PARTY_NUMBER varchar2(100);
    L_REFERENCE_NUMBER   JA_CN_CFS_ACTIVITIES_ALL.REFERENCE_NUMBER%TYPE;
    L_SOURCE             JA_CN_CFS_ACTIVITIES_ALL.SOURCE%TYPE;
    -- Fix bug#6751696 delete begin
    --L_ROW_NAME           RG_REPORT_AXES.AXIS_NAME%TYPE;
    -- Fix bug#6751696 delete end
    -- Fix bug#6751696 add begin
    L_ROW_NAME           RG_REPORT_AXES.AXIS_SEQ%TYPE;
    -- Fix bug#6751696 add end
    L_ROW_DESCRIPTION    RG_REPORT_AXES.DESCRIPTION%TYPE;
    L_REPORT_NAME        RG_REPORTS.NAME%TYPE;
    L_LEDGER_NAME        VARCHAR2(30);
    L_INTERCOMPANY_FLAG  JA_CN_CFS_ACTIVITIES_ALL.INTERCOMPANY_FLAG%TYPE;
    L_TRANSACTION_TYPE   JA_CN_CFS_ACTIVITIES_ALL.TRANSACTION_TYPE%TYPE;
    L_BSV                JA_CN_CFS_ACTIVITIES_ALL.Balancing_Segment%TYPE;--enhancment add

    -- Fix bug#6697073 begin----------------------------------------
    -- L_SOURCE_AP          VARCHAR2(10) := 'AP';
    L_SOURCE_AP          VARCHAR2(10) := 'SQLAP';
    -- Fix bug#6697073 end------------------------------------------

    L_SOURCE_AR          VARCHAR2(10) := 'AR';
    L_ROW_AMOUNT NUMBER;
    L_XML_ITEM      XMLTYPE;
    L_XML_ALL       XMLTYPE;
    L_XML_ROW_ITEMS XMLTYPE;
    L_XML_ROW       XMLTYPE;
    L_XML_PERIOD    XMLTYPE;
    L_XML_REPORT    XMLTYPE;
    L_XML_PARAMETER XMLTYPE;
    L_XML_ROOT      XMLTYPE;

    -- Fix bug#6854438 add new variable begin
    L_XML_ROWS_ALL  XMLTYPE;  -- record all the rows
    -- Fix bug#6854438 add new variable end
    L_DIS_FLAG      NUMBER;
    L_ERROR_STATUS BOOLEAN;
    JA_CN_INVALID_GLPERIOD EXCEPTION;
    L_MSG_INVALID_GLPERIOD VARCHAR2(2000);
    l_characterset   varchar(245);

    -- Fix bug#6697073 begin------------------------------------
    L_invoice_count number;
    -- L_FUNC_AMOUNT_TEMP NUMBER_TBL; -- Fix bug#6920953 delete
    L_FUNC_AMOUNT_TEMP NUMBER_TBL := NUMBER_TBL();-- Fix bug#6920953 add
    -- Fix bug#6697073 end--------------------------------------

    --Period when
    CURSOR C_PERIODS(L_DATE_FROM DATE
                   , L_DATE_TO DATE
                   , P_LE_ID NUMBER
                   , P_LEDGER_ID NUMBER
                   , P_SOURCE VARCHAR2
                   , P_REPORT_ID NUMBER
                   , p_bsv    VARCHAR2) IS--enhancment add
      SELECT DISTINCT JCA.PERIOD_NAME
             ,GP.PERIOD_NUM
        FROM JA_CN_CFS_ACTIVITIES_ALL  JCA
            ,JA_CN_CFS_ASSIGNMENTS_ALL JCCA
            ,RG_REPORT_AXES            RRA
            ,RG_REPORTS                RG
            ,GL_LEDGERS                LED
            ,GL_PERIODS                GP
       WHERE JCA.LEGAL_ENTITY_ID = P_LE_ID
         AND JCA.LEDGER_ID = P_LEDGER_ID
         AND JCA.GL_DATE >= L_DATE_FROM
         AND JCA.GL_DATE <= L_DATE_TO
         AND JCA.SOURCE = NVL(P_SOURCE,
                              JCA.SOURCE)
         AND JCCA.DETAILED_CFS_ITEM = JCA.DETAILED_CFS_ITEM
         AND JCCA.CHART_OF_ACCOUNTS_ID = P_CHART_OF_ACCOUNTS_ID
         AND JCCA.AXIS_SET_ID = RRA.AXIS_SET_ID
         AND JCCA.AXIS_SEQ = RRA.AXIS_SEQ
         AND RG.ROW_SET_ID = RRA.AXIS_SET_ID
         AND RG.REPORT_ID = P_REPORT_ID
         AND LED.LEDGER_ID = P_LEDGER_ID
         AND GP.PERIOD_SET_NAME = LED.PERIOD_SET_NAME
         AND GP.PERIOD_NAME = JCA.PERIOD_NAME
         --AND (P_BSV is null or jca.balancing_segment=P_BSV)--Fix bug#7334017  add --fix bug 7488223 delete
         -- fix bug 7488223 add begin
         AND ((P_BSV is not null and jca.balancing_segment=P_BSV)
            or(p_bsv is null and jca.balancing_segment in (select bal_seg_value from JA_CN_LEDGER_LE_BSV_GT
                                                             where legal_entity_id=P_LE_ID and ledger_id=P_LEDGER_ID)
                                                                  ))
         ORDER BY GP.PERIOD_NUM DESC;

    --Rows that should be included
    CURSOR C_ROWS(P_PERIOD_NAME VARCHAR2
                , P_LE_ID NUMBER
                , P_LEDGER_ID NUMBER
                , P_SOURCE VARCHAR2
                , P_REPORT_ID NUMBER
                , p_bsv     VARCHAR2) IS--enhancment add
      SELECT DISTINCT
             -- Fix bug#6751696 delete begin
             --RRA.AXIS_NAME
             -- Fix bug#6751696 delete end
             -- Fix bug#6751696 add begin
             RRA.AXIS_SEQ
             -- Fix bug#6751696 add end
        FROM JA_CN_CFS_ACTIVITIES_ALL  JCA
            ,JA_CN_CFS_ASSIGNMENTS_ALL JCCA
            ,RG_REPORT_AXES            RRA
            ,RG_REPORTS                RG
       WHERE JCA.LEGAL_ENTITY_ID = P_LE_ID
         AND JCA.PERIOD_NAME = P_PERIOD_NAME
         AND JCCA.DETAILED_CFS_ITEM = JCA.DETAILED_CFS_ITEM
         AND JCCA.CHART_OF_ACCOUNTS_ID = P_CHART_OF_ACCOUNTS_ID
         AND JCA.SOURCE = NVL(P_SOURCE,
                              JCA.SOURCE)
         AND JCCA.AXIS_SET_ID = RRA.AXIS_SET_ID
         AND JCCA.AXIS_SEQ = RRA.AXIS_SEQ
         -- Fix bug#6859513 add begin
         AND RRA.AXIS_SEQ = NVL(P_ROW_NAME, RRA.AXIS_SEQ)
         -- Fix bug#6859513 add end
         AND JCA.LEDGER_ID = P_LEDGER_ID
         AND RG.ROW_SET_ID = RRA.AXIS_SET_ID
         AND RG.REPORT_ID = NVL(P_REPORT_ID,
                                RG.REPORT_ID)
         --AND (P_BSV is null or jca.balancing_segment=P_BSV)--Fix bug#7334017  add --fix bug 7488223 delete
         -- fix bug 7488223 add begin
          AND ((P_BSV is not null and jca.balancing_segment=P_BSV)
            or(p_bsv is null and jca.balancing_segment in (select bal_seg_value from JA_CN_LEDGER_LE_BSV_GT
                                                             where legal_entity_id=P_LE_ID and ledger_id=P_LEDGER_ID)
                                                                  ));
         -- -- fix bug 7488223 add end

    --The reports that should be reported
    CURSOR C_REPORTS(P_PERIOD_NAME VARCHAR2
                   -- Fix bug#6751696 delete begin
                   --, P_ROW_NAME VARCHAR2
                   -- Fix bug#6751696 delete end
                   -- Fix bug#6751696 add begin
                   , P_ROW_NAME NUMBER
                   -- Fix bug#6751696 add end
                   , P_LE_ID NUMBER
                   , P_LEDGER_ID NUMBER
                   , P_SOURCE VARCHAR2
                   , P_REPORT_ID VARCHAR2
                   , p_bsv       VARCHAR2) IS--enhancment add
      SELECT JCA.TRX_ID
            ,JCA.SOURCE
            ,JCA.TRANSACTION_TYPE
            ,JCA.TRX_LINE_ID
            ,JCA.CASH_TRX_ID --Added by Chaoqun
            ,JCA.CASH_TRX_LINE_ID --Added by Chaoqun
            ,JCA.FUNC_AMOUNT
            ,JCA.ORIGINAL_AMOUNT
            ,JCA.DETAILED_CFS_ITEM
            ,JCA.THIRD_PARTY_NAME
            ,JCA.THIRD_PARTY_NUMBER
            ,JCA.REFERENCE_NUMBER
            ,RRA.DESCRIPTION
            -- Fix bug#6697073 begin--------------------------------
            ,JCA.TRX_NUMBER
            -- Fix bug#6697073 end----------------------------------
            ,null--fix bug 7487373 add
            ,JCA.Balancing_Segment--enhancment add
        FROM JA_CN_CFS_ACTIVITIES_ALL  JCA
            ,JA_CN_CFS_ASSIGNMENTS_ALL JCCA
            ,RG_REPORTS                RG
            ,RG_REPORT_AXES            RRA
       WHERE JCA.LEGAL_ENTITY_ID = P_LE_ID
         AND JCA.PERIOD_NAME = P_PERIOD_NAME
         AND JCA.SOURCE = NVL(P_SOURCE,
                              JCA.SOURCE)
         AND JCCA.DETAILED_CFS_ITEM = JCA.DETAILED_CFS_ITEM
         AND JCCA.CHART_OF_ACCOUNTS_ID = P_CHART_OF_ACCOUNTS_ID
         AND JCCA.AXIS_SET_ID = RRA.AXIS_SET_ID
         AND JCCA.AXIS_SEQ = RRA.AXIS_SEQ
         AND RG.ROW_SET_ID = RRA.AXIS_SET_ID
         AND RG.REPORT_ID = P_REPORT_ID
         AND JCA.LEDGER_ID = P_LEDGER_ID
         -- Fix bug#6751696 delete begin
         --AND RRA.AXIS_NAME = P_ROW_NAME
         -- Fix bug#6751696 delete end
         -- Fix bug#6751696 add begin
         AND RRA.AXIS_SEQ = P_ROW_NAME
         -- Fix bug#6751696 add end
         --AND (P_BSV is null or jca.balancing_segment=P_BSV)--Fix bug#7334017  add --fix bug 7488223 delete
         -- fix bug 7488223 add begin
          AND ((P_BSV is not null and jca.balancing_segment=P_BSV)
            or(p_bsv is null and jca.balancing_segment in (select bal_seg_value from JA_CN_LEDGER_LE_BSV_GT
                                                             where legal_entity_id=P_LE_ID and ledger_id=P_LEDGER_ID)
                                                                  ))
         -- -- fix bug 7488223 add end
       ORDER BY JCA.SOURCE
               ,JCA.THIRD_PARTY_NUMBER
               ,JCA.REFERENCE_NUMBER;

  BEGIN
    --log for debug
    IF (L_PROC_LEVEL >= L_DBG_LEVEL)
    THEN
      FND_LOG.STRING(L_PROC_LEVEL,
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.begin',
                     'Enter procedure');
      FND_LOG.STRING(L_PROC_LEVEL,
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.parameters',
                     'P_LEGAL_ENTITY_ID ' || P_LEGAL_ENTITY_ID);
      FND_LOG.STRING(L_PROC_LEVEL,
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.parameters',
                     'P_LEDGER_ID ' || P_LEDGER_ID);
      FND_LOG.STRING(L_PROC_LEVEL,
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.parameters',
                     'P_chart_of_accounts_ID ' || P_CHART_OF_ACCOUNTS_ID);

      FND_LOG.STRING(L_PROC_LEVEL,
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.parameters',
                     'P_ADHOC_PREFIX ' || P_ADHOC_PREFIX);

      FND_LOG.STRING(L_PROC_LEVEL,
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.parameters',
                     'P_INDUSTRY ' || P_INDUSTRY);

      FND_LOG.STRING(L_PROC_LEVEL,
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.parameters',
                     'P_ID_FLEX_CODE ' || P_ID_FLEX_CODE);
      FND_LOG.STRING(L_PROC_LEVEL,
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.parameters',
                     'P_GL_PERIOD_FROM ' || P_GL_PERIOD_FROM);
      FND_LOG.STRING(L_PROC_LEVEL,
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.parameters',
                     'P_GL_PERIOD_TO' || P_GL_PERIOD_TO);
      FND_LOG.STRING(L_PROC_LEVEL,
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.parameters',
                     'P_SOURCE ' || P_SOURCE);
      FND_LOG.STRING(L_PROC_LEVEL,
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.parameters',
                     'P_REPORT_ID ' || P_REPORT_ID);
      FND_LOG.STRING(L_PROC_LEVEL,                                         --enhancment add
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.parameters',
                     'P_BSV ' || P_BSV);

    END IF; --(l_proc_level >= l_dbg_level)

    --fix bug 7488223 add begin
     DELETE
    FROM   JA_CN_LEDGER_LE_BSV_GT;
    COMMIT ;
    --
    --ja_cn_utility_pkg.populate_ledger_le_bsv_gt( P_LEDGER_ID,P_LE_ID);

    IF ja_cn_utility.populate_ledger_le_bsv_gt(P_LEDGER_ID,P_LEGAL_ENTITY_ID) <> 'S' THEN
       RETURN;
    END IF;
   --fix bug 7488223 add end

    L_XML_REPORT := NULL;

    --The Legal Entity related infromation stored in the XLE_ENTITY_PROFILES
    --table in R12.
    SELECT name
      INTO l_le_name
      FROM XLE_ENTITY_PROFILES
     WHERE legal_entity_id=p_legal_entity_id;

    --Get the Report Name
    SELECT NAME
      INTO L_REPORT_NAME
      FROM RG_REPORTS
     WHERE REPORT_ID = P_REPORT_ID;

     --get ledger name
     SELECT name
       INTO l_ledger_name
       FROM gl_ledgers
      WHERE ledger_id=p_ledger_id;
    --write the parameter infomation into variable
    --l_xml_parameter and last into l_xml_report
    --FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
    --                  '<?xml version="1.0" encoding="utf-8" ?>');
    -- Updated by shujuan for bug 7626489
    l_characterset :=Fnd_Profile.VALUE(NAME => 'ICX_CLIENT_IANA_ENCODING');
    FND_FILE.put_line(FND_FILE.output,'<?xml version="1.0" encoding= '||'"'||l_characterset||'"?>');
    --for start period
    SELECT XMLELEMENT("P_START_PERIOD",
                      P_GL_PERIOD_FROM)
      INTO L_XML_ITEM
      FROM DUAL;
    L_XML_PARAMETER := L_XML_ITEM;
    --for end period
    SELECT XMLELEMENT("P_END_PERIOD",
                      P_GL_PERIOD_TO)
      INTO L_XML_ITEM
      FROM DUAL;
    SELECT XMLCONCAT(L_XML_PARAMETER,
                     L_XML_ITEM)
      INTO L_XML_PARAMETER
      FROM DUAL;
    --for report name
    SELECT XMLELEMENT("P_REPORT_NAME",
                      L_REPORT_NAME)
      INTO L_XML_ITEM
      FROM DUAL;
    SELECT XMLCONCAT(L_XML_PARAMETER,
                     L_XML_ITEM)
      INTO L_XML_PARAMETER
      FROM DUAL;
    --for source
    SELECT XMLELEMENT("P_SOURCE",
                      P_SOURCE)
      INTO L_XML_ITEM
      FROM DUAL;
    SELECT XMLCONCAT(L_XML_PARAMETER,
                     L_XML_ITEM)
      INTO L_XML_PARAMETER
      FROM DUAL;
    --for ledger name
    SELECT XMLELEMENT("P_LEDGER_NAME",
                      L_LEDGER_NAME)
      INTO L_XML_ITEM
      FROM DUAL;
    SELECT XMLCONCAT(L_XML_PARAMETER,
                     L_XML_ITEM)
      INTO L_XML_PARAMETER
      FROM DUAL;
    --for legal entity
    SELECT XMLELEMENT("P_LEGAL_ENTITY",
                      L_LE_NAME)
      INTO L_XML_ITEM
      FROM DUAL;
    SELECT XMLCONCAT(L_XML_PARAMETER,
                     L_XML_ITEM)
      INTO L_XML_PARAMETER
      FROM DUAL;

    --for row name
    SELECT XMLELEMENT("P_ROW_NAME",
                      P_ROW_NAME)
      INTO L_XML_ITEM
      FROM DUAL;
    SELECT XMLCONCAT(L_XML_PARAMETER,
                     L_XML_ITEM)
      INTO L_XML_PARAMETER
      FROM DUAL;

      --for bsv
      SELECT XMLELEMENT("P_BSV",--enhancment add
                      P_BSV)
      INTO L_XML_ITEM
      FROM DUAL;
    SELECT XMLCONCAT(L_XML_PARAMETER,
                     L_XML_ITEM)
      INTO L_XML_PARAMETER
      FROM DUAL;


    SELECT XMLCONCAT(L_XML_PARAMETER,
                     L_XML_REPORT)
      INTO L_XML_REPORT
      FROM DUAL;


    --Get Period set name, Year_From and Year_To
    SELECT LED.PERIOD_SET_NAME
          ,GP1.PERIOD_YEAR
          ,GP2.PERIOD_YEAR
      INTO L_PERIOD_SET_NAME
          ,L_YEAR_FROM
          ,L_YEAR_TO
      FROM GL_LEDGERS LED
          ,GL_PERIODS GP1
          ,GL_PERIODS GP2
     WHERE LED.LEDGER_ID = P_LEDGER_ID
           AND GP1.PERIOD_SET_NAME = LED.PERIOD_SET_NAME
           AND GP1.PERIOD_NAME = P_GL_PERIOD_FROM
           AND GP2.PERIOD_SET_NAME = LED.PERIOD_SET_NAME
           AND GP2.PERIOD_NAME = P_GL_PERIOD_TO;

    --The from period and to period should be within one accounting year
    IF L_YEAR_FROM <> L_YEAR_TO
    THEN
      RAISE JA_CN_INVALID_GLPERIOD;
    END IF; --l_year_from <> l_year_to


    --get period type
    SELECT ACCOUNTED_PERIOD_TYPE
      INTO L_PERIOD_TYPE
      FROM GL_LEDGERS
     WHERE LEDGER_ID = P_LEDGER_ID;

    --get period number for start period
    SELECT PERIOD_YEAR * 1000 + PERIOD_NUM
          ,START_DATE
      INTO L_PERIOD_NUM_FROM
          ,L_DATE_FROM
      FROM GL_PERIODS
     WHERE PERIOD_SET_NAME = L_PERIOD_SET_NAME
           AND PERIOD_NAME = P_GL_PERIOD_FROM
           AND PERIOD_TYPE = L_PERIOD_TYPE;

    -- get period number for end period
    SELECT PERIOD_YEAR * 1000 + PERIOD_NUM
          ,END_DATE
      INTO L_PERIOD_NUM_TO
          ,L_DATE_TO
      FROM GL_PERIODS
     WHERE PERIOD_SET_NAME = L_PERIOD_SET_NAME
           AND PERIOD_NAME = P_GL_PERIOD_TO
           AND PERIOD_TYPE = L_PERIOD_TYPE;
    --for each periods
    OPEN C_PERIODS(L_DATE_FROM,
                   L_DATE_TO,
                   P_LEGAL_ENTITY_ID,
                   P_LEDGER_ID,
                   P_SOURCE,
                   P_REPORT_ID,
                   P_BSV);--enhancment add

    LOOP
      FETCH C_PERIODS
        INTO L_PERIOD_NAME, L_PERIOD_NUM;
      EXIT WHEN C_PERIODS%NOTFOUND;

      L_XML_PERIOD := NULL;

      -- Fix bug #6854438 initiate variable begin
      L_XML_ROW := NULL;
      L_XML_ROWS_ALL := NULL;
      -- Fix bug #6854438 initiate variable end

      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'l_period_name' || L_PERIOD_NAME);
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'p_row_name' || P_ROW_NAME || P_SOURCE);

      --initiate row amount
      L_ROW_AMOUNT:=0;
      OPEN C_ROWS(L_PERIOD_NAME,
                  P_LEGAL_ENTITY_ID,
                  P_LEDGER_ID,
                  P_SOURCE,
                  P_REPORT_ID,
                  P_BSV);--Fix bug#7334017  add
      LOOP
        FETCH C_ROWS
          INTO L_ROW_NAME;
        EXIT WHEN C_ROWS%NOTFOUND;
        FND_FILE.PUT_LINE(FND_FILE.LOG,
                          'l_row_name' || L_ROW_NAME);
        L_XML_ROW := NULL;
        L_XML_ITEM:=null; --fix bug#7497957 add
        l_dis_flag:=0;--fix bug 7487395 add

        -- Fix bug #6854438 clear variable value begin
        L_XML_PERIOD := NULL;
        l_row_amount := 0;
        -- Fix bug #6854438 clear variable value end

        OPEN C_REPORTS(L_PERIOD_NAME,
                       L_ROW_NAME,
                       P_LEGAL_ENTITY_ID,
                       P_LEDGER_ID,
                       P_SOURCE,
                       P_REPORT_ID,
                       P_BSV);--Fix bug#7334017  add
        LOOP
          FETCH C_REPORTS
            INTO L_TRX_ID
               , L_SOURCE
               , L_TRANSACTION_TYPE
               , L_TRX_LINE_ID
               , L_CASH_TRX_ID  --Added by Chaoqun for fixing bug 8969631
               , L_CASH_TRX_LINE_ID --Added by Chaoqun for fixing bug 8969631
               , L_FUNC_AMOUNT
               , L_ORIGINAL_AMOUNT
               , L_DETAILED_CFS_ITEM
               , L_THIRD_PARTY_NAME
               , L_THIRD_PARTY_NUMBER
               , L_REFERENCE_NUMBER
               , L_ROW_DESCRIPTION
               -- Fix bug#6697073 begin------------------------------------------
               , L_INVOICE_NUM
               -- Fix bug#6697073 end--------------------------------------------
               ,L_TRX_NUMBER--fix bug 7487373 add
               ,L_BSV;
          EXIT WHEN C_REPORTS%NOTFOUND;
          -- Fix bug#6920953 add begin
          L_FUNC_AMOUNT_TEMP.DELETE;
          L_INVOICE_NUM1.DELETE;
          L_FUNC_AMOUNT_TEMP.EXTEND;
          L_INVOICE_NUM1.EXTEND;
          L_FUNC_AMOUNT_TEMP(1) := L_FUNC_AMOUNT;
          L_INVOICE_NUM1(1) := L_INVOICE_NUM;
          -- Fix bug#6920953 add end

          IF L_TRANSACTION_TYPE = 'SLA'
             AND L_SOURCE = L_SOURCE_AP
          THEN
            PROCESS_AP_DETAIL(P_LEDGER_ID        => P_LEDGER_ID,
                              P_AE_HEADER_ID     => L_TRX_ID,
                              P_AE_LINE_NUM      => L_TRX_LINE_ID,
                              p_FUNC_AMOUNT      => L_FUNC_AMOUNT, -- for bug 8395411 by Shujuan
                              X_TRX_NUMBER       => L_TRX_NUMBER,
                              P_CASH_AE_HEADER_ID => L_CASH_TRX_ID,  --Added by Chaoqun for fixing bug 8969631
                              P_CASH_AE_LINE_NUM  => L_CASH_TRX_LINE_ID, --Added by Chaoqun for fixing bug 8969631

                              -- Fix bug#6697073 begin---------------------------
                              -- X_INVOICE_NUM      => L_INVOICE_NUM,
                              --change return type as table type, so it can return more than one invoices.
                              X_FUNC_AMOUNT      => L_FUNC_AMOUNT_TEMP,
                              --change return type as table type, so it can return more than one invoices.
                              X_INVOICE_NUM      => L_INVOICE_NUM1,
                              -- Fix bug#6697073 end-----------------------------

                              X_THIRD_PARTY_NAME => L_THIRD_PARTY_NAME,
                              X_THIRD_PARTY_NUM  => L_THIRD_PARTY_NUMBER);
          END IF; --L_TRANSACTION_TYPE = 'SLA' AND L_SOURCE = L_SOURCE_AP

          IF L_FUNC_AMOUNT<>0 THEN --for bug 6717171

              IF L_TRANSACTION_TYPE = 'SLA'
                 AND L_SOURCE = L_SOURCE_AR
              THEN
                PROCESS_AR_DETAIL(P_LEDGER_ID        => P_LEDGER_ID,
                                  P_AE_HEADER_ID     => L_TRX_ID,
                                  P_AE_LINE_NUM      => L_TRX_LINE_ID,
                                  p_FUNC_AMOUNT      => L_FUNC_AMOUNT, -- For bug 8395408 by Shujuan
                                  X_TRX_NUMBER       => L_TRX_NUMBER,
                                  P_CASH_AE_HEADER_ID => L_CASH_TRX_ID,  --Added by Chaoqun for fixing bug 8969631
                                  P_CASH_AE_LINE_NUM  => L_CASH_TRX_LINE_ID, --Added by Chaoqun for fixing bug 8969631

                                  -- Fix bug#6697073 begin-------------------------------------
                                  -- X_INVOICE_NUM      => L_INVOICE_NUM,
                                  --change return type as table type, so it can return more than one invoices.
                                  X_FUNC_AMOUNT      => L_FUNC_AMOUNT_TEMP,
                                  --change return type as table type, so it can return more than one invoices.
                                  X_INVOICE_NUM      => L_INVOICE_NUM1,
                                  -- Fix bug#6697073 end---------------------------------------

                                  X_THIRD_PARTY_NAME => L_THIRD_PARTY_NAME,
                                  X_THIRD_PARTY_NUM  => L_THIRD_PARTY_NUMBER);
              END IF; --L_TRANSACTION_TYPE = 'SLA' AND L_SOURCE = L_SOURCE_AR


                L_DIS_FLAG:=1;--fix bug 7487395 add

              -- Fix bug#6697073 begin --------------------------------------------

              L_invoice_count := L_INVOICE_NUM1.count;
                FOR l_count IN 1..L_invoice_count
                loop
              -- Fix bug#6697073 end ----------------------------------------------
              SELECT XMLELEMENT("PERIOD_NAME",
                                L_PERIOD_NAME)
                INTO L_XML_ITEM
                FROM DUAL;
              L_XML_ROW_ITEMS := L_XML_ITEM;

              SELECT XMLELEMENT("DETAILED_CFS_ITEM",
                                L_DETAILED_CFS_ITEM)
                INTO L_XML_ITEM
                FROM DUAL;
              SELECT XMLCONCAT(L_XML_ROW_ITEMS,
                               L_XML_ITEM)
                INTO L_XML_ROW_ITEMS
                FROM DUAL;
              SELECT XMLELEMENT("ROW_NAME",
                                L_ROW_DESCRIPTION)
                INTO L_XML_ITEM
                FROM DUAL;
              SELECT XMLCONCAT(L_XML_ROW_ITEMS,
                               L_XML_ITEM)
                INTO L_XML_ROW_ITEMS
                FROM DUAL;
              SELECT XMLELEMENT("SOURCE",
                                L_SOURCE)
                INTO L_XML_ITEM
                FROM DUAL;
              SELECT XMLCONCAT(L_XML_ROW_ITEMS,
                               L_XML_ITEM)
                INTO L_XML_ROW_ITEMS
                FROM DUAL;

                SELECT XMLELEMENT("BSV",--Fix bug#7334017  add
                                L_BSV)
                INTO L_XML_ITEM
                FROM DUAL;
              SELECT XMLCONCAT(L_XML_ROW_ITEMS,
                               L_XML_ITEM)
                INTO L_XML_ROW_ITEMS
                FROM DUAL;


              SELECT XMLELEMENT("THIRD_PARTY_NAME",
                                L_THIRD_PARTY_NAME)
                INTO L_XML_ITEM
                FROM DUAL;
              SELECT XMLCONCAT(L_XML_ROW_ITEMS,
                               L_XML_ITEM)
                INTO L_XML_ROW_ITEMS
                FROM DUAL;
              SELECT XMLELEMENT("RECEIPT_PAYMENT_NUMBER",
                                L_TRX_NUMBER)
                INTO L_XML_ITEM
                FROM DUAL;
              SELECT XMLCONCAT(L_XML_ROW_ITEMS,
                               L_XML_ITEM)
                INTO L_XML_ROW_ITEMS
                FROM DUAL;

                  -- Fix bug#6697073 begin ----------------------------
              SELECT XMLELEMENT("TRANSACTION_NUMBER",
                                    L_INVOICE_NUM1(l_count))--L_INVOICE_NUM
                INTO L_XML_ITEM
                FROM DUAL;
                  -- Fix bug#6697073 end ------------------------------

              SELECT XMLCONCAT(L_XML_ROW_ITEMS,
                               L_XML_ITEM)
                INTO L_XML_ROW_ITEMS
                FROM DUAL;

                  -- Fix bug#6697073 begin ----------------------------
              SELECT XMLELEMENT("TRANSACTION_AMOUNT",
                                    L_FUNC_AMOUNT_TEMP(l_count))--L_FUNC_AMOUNT
                INTO L_XML_ITEM
                FROM DUAL;

              SELECT XMLCONCAT(L_XML_ROW_ITEMS,
                               L_XML_ITEM)
                INTO L_XML_ROW_ITEMS
                FROM DUAL;

              SELECT XMLELEMENT("ROW_DETAIL",
                                L_XML_ROW_ITEMS)
                INTO L_XML_ITEM
                FROM DUAL;
              SELECT XMLCONCAT(L_XML_ROW,
                               L_XML_ITEM)
                INTO L_XML_ROW
                FROM DUAL;

            --count row amount
                  l_row_amount:=l_row_amount+nvl(L_FUNC_AMOUNT_TEMP(l_count),0);
                end loop;
              -- Fix bug#6697073 end ----------------------------------------------


        END IF;-- IF L_FUNC_AMOUNT<>0

        END LOOP;--loop c_reports
        CLOSE c_reports;

      if L_DIS_FLAG<>0 then--fix bug  7487395 add
        SELECT XMLELEMENT("ROW_AMOUNT",
                          L_ROW_AMOUNT)
          INTO L_XML_ITEM
          FROM DUAL;
        SELECT XMLCONCAT(L_XML_ROW,
                         L_XML_ITEM)
          INTO L_XML_ROW
          FROM DUAL;

        SELECT XMLELEMENT("ROW",
                          L_XML_ROW)
          INTO L_XML_ITEM
          FROM DUAL;
       end if;   --fix bug  7487395 add
     -- Fix bug #6854438: record all the rows info by L_XML_ROWS_ALL begin
        IF L_XML_ROWS_ALL IS NULL
         THEN
           L_XML_ROWS_ALL := L_XML_ITEM;
        ELSE
           SELECT XMLCONCAT(L_XML_ROWS_ALL,
                            L_XML_ITEM)
             INTO L_XML_ROWS_ALL
             FROM DUAL;
         END IF;
     -- Fix bug #6854438: record all the rows info by L_XML_ROWS_ALL end

        END LOOP; --cursor c_rows
        CLOSE c_rows;

        SELECT XMLCONCAT(L_XML_PERIOD,
                         L_XML_ROWS_ALL)
          INTO L_XML_PERIOD
          FROM DUAL;

        SELECT XMLELEMENT("PERIOD",
                          L_XML_PERIOD)
          INTO L_XML_ITEM
          FROM DUAL;
        SELECT XMLCONCAT(L_XML_REPORT,
                         L_XML_ITEM)
          INTO L_XML_REPORT
          FROM DUAL;

--     END LOOP; --cursor c_rows

    END LOOP; --cursor c_reports
    CLOSE c_periods;


    SELECT XMLELEMENT("REPORT",
                      L_XML_REPORT)
      INTO L_XML_ROOT
      FROM DUAL;
    JA_CN_UTILITY.OUTPUT_CONC(L_XML_ROOT.GETCLOBVAL());

    --log for debug
    IF (L_PROC_LEVEL >= L_DBG_LEVEL)
    THEN
      FND_LOG.STRING(L_PROC_LEVEL,
                     L_MODULE_PREFIX || '.' || L_PROC_NAME || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level )

  EXCEPTION
    WHEN JA_CN_INVALID_GLPERIOD THEN
      FND_MESSAGE.SET_NAME(APPLICATION => 'JA',
                           NAME        => 'JA_CN_INVALID_GLPERIOD');
      L_MSG_INVALID_GLPERIOD := FND_MESSAGE.GET;
      IF (L_PROC_LEVEL >= L_DBG_LEVEL)
      THEN
        FND_LOG.STRING(L_PROC_LEVEL,
                       L_MODULE_PREFIX || '.' || L_PROC_NAME ||
                       '.JA_CN_INVALID_GLPERIOD ',
                       L_MSG_INVALID_GLPERIOD);
      END IF; --(l_proc_level >= l_dbg_level)

      SELECT XMLELEMENT("EXCEPTION",
                        L_MSG_INVALID_GLPERIOD)
        INTO L_XML_ITEM
        FROM DUAL;
      SELECT XMLCONCAT(L_XML_PARAMETER,
                       L_XML_ITEM)
        INTO L_XML_ALL
        FROM DUAL;
      --To add root node for the xml output and then output it
      SELECT XMLELEMENT("REPORT",
                        L_XML_ALL)
        INTO L_XML_ROOT
        FROM DUAL;
      JA_CN_UTILITY.OUTPUT_CONC(L_XML_ROOT.GETCLOBVAL());

      RETCODE := 1;
      ERRBUF  := L_MSG_INVALID_GLPERIOD;
    WHEN OTHERS THEN
      IF (L_PROC_LEVEL >= L_DBG_LEVEL)
      THEN
        FND_LOG.STRING(L_PROC_LEVEL,
                       L_MODULE_PREFIX || '.' || L_PROC_NAME ||
                       '.Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)

      SELECT XMLELEMENT("EXCEPTION",
                        'Other_Exception')
        INTO L_XML_ITEM
        FROM DUAL;
      SELECT XMLCONCAT(L_XML_PARAMETER,
                       L_XML_ITEM)
        INTO L_XML_ALL
        FROM DUAL;
      --To add root node for the xml output and then output it
      SELECT XMLELEMENT("REPORT",
                        L_XML_ALL)
        INTO L_XML_ROOT
        FROM DUAL;

      JA_CN_UTILITY.OUTPUT_CONC(L_XML_ROOT.GETCLOBVAL());
      IF c_periods%ISOPEN THEN
        CLOSE c_periods;
      END IF;
      IF c_rows%ISOPEN THEN
        CLOSE c_rows;
      END IF;
      IF c_reports%ISOPEN THEN
        CLOSE c_reports;
      END IF;
      RETCODE := 2;
      ERRBUF  := SQLCODE || ':' || SQLERRM;
      RAISE;
  END CFS_DETAIL_REPORT;

END Ja_Cn_Cfs_Report_Pkg;

/
