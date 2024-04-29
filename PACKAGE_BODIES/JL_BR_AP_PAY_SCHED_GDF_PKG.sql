--------------------------------------------------------
--  DDL for Package Body JL_BR_AP_PAY_SCHED_GDF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AP_PAY_SCHED_GDF_PKG" AS
/* $Header: jlbrpgpb.pls 120.12 2006/09/20 01:09:23 dbetanco ship $ */

-- =====================================================================
--                   P R I V A T E    O B J E C T S
-- =====================================================================
--
-- Validate p_date with the Brazilian calendar business days if the date is
-- not business day the procedure return a date before o after according to
-- the setup.
------------------------------------------------------------------------
Procedure VALIDATE_DATE
            (
             p_date date,
             p_city varchar2,
             p_new_date IN OUT NOCOPY date,
             p_status IN OUT NOCOPY number) IS

  -- Local Variables

  l_calendar varchar2(10);
  l_payment_action varchar2(1);
  l_change_date varchar2(1);
  return_question number;
  returned_date   varchar2(11);

  l_org_id  NUMBER;   --  MOAC  Bug # 2306001

  BEGIN
    ------------------------------------------------------------------------
    -- Validate the profile options.
    ------------------------------------------------------------------------
    if p_date IS NOT NULL then
       l_org_id := MO_GLOBAL.get_current_org_id;
       l_payment_action := JL_ZZ_SYS_OPTIONS_PKG.get_payment_action(l_org_id);  -- MOAC
       -- Bug 4715379
       l_calendar := jl_zz_sys_options_pkg.get_calendar;
       l_change_date := jl_zz_sys_options_pkg.get_change_date_automatically(l_org_id);
       if l_payment_action is NOT NULL then
          if l_calendar is NOT NULL then
             if l_change_date is NOT NULL then
                ------------------------------------------------------------
                -- Get the new date.
                ------------------------------------------------------------
                jl_br_workday_calendar.jl_br_check_date(to_char(p_date,'DD-MM-YYYY'),l_calendar,
                        p_city,l_payment_action,returned_date,p_status);
                if p_status = 0 then /* procedure successfull */
                   -----------------------------------------------------------
                   -- Return the new date.
                   -----------------------------------------------------------
                   p_new_date := to_date(returned_date,'DD-MM-YYYY');
                   if p_date <> p_new_date then
                      if l_change_date = 'N' then
                          RETURN;
                      end if;
                   end if;
                end if;
             else
                p_status := 1;
             end if;
          else
            p_status := 2;
          end if;
       else
         p_status := 3;
       end if;
    end if;
END VALIDATE_DATE;

Procedure APXWKB_BR_VALIDATE_DATE_LOCAL
            (
             p_in_date Date,
             p_vendor_site_id Number,
             new_date_val IN OUT NOCOPY Varchar2) IS

    X_payment_location         VARCHAR2(80);
    p_city                     VARCHAR2(25);
    p_state                    VARCHAR2(60); --Bug # 2319552
    p_new_date                 DATE;
    p_status                   NUMBER(38);
    l_vendor_site_id           NUMBER(38);

    l_form_name                varchar2(50);
    errcode1                   number;
    sqlstat1                   varchar2(2000);

    X_org_id                   NUMBER;  -- Bug 2306001

  BEGIN

    -- Bug # 2306001 (MOAC)/ 4715379
    X_org_id := MO_GLOBAL.get_current_org_id;
    X_payment_location := JL_ZZ_SYS_OPTIONS_PKG.get_payment_location(X_org_id);

    IF X_payment_location IS Null THEN
       RETURN;
    END IF;

    IF NVL(X_payment_location,'$') = '1' THEN           -- 1 COMPANY ---------
      -- Get city from ap_system_parameters

      -- Bug 2319552 : BDC - State Lov
      JL_ZZ_AP_LIBRARY_1_PKG.get_city_frm_sys(p_city,1, errcode1, p_state);
    ELSIF NVL(X_payment_location,'$') = '2' THEN        -- 2 SUPPLIER --------
      -- Get city from po_vendor_sites

      -- Bug 2319552 : BDC - State Lov : Start ------
      JL_ZZ_AP_LIBRARY_1_PKG.get_city_frm_povend(p_vendor_site_id, p_city, 1, errcode1, p_state);

    END IF;

    VALIDATE_DATE (p_in_date,
                   p_city,
                   p_new_date,
                   p_status,
                   p_state); -- Bug # 2319552


    IF p_status = 0 THEN
      new_date_val := To_Char(p_new_date,'DD-MON-YYYY'); -- OUT Parameter
    END IF;

  END APXWKB_BR_Validate_Date_Local;
  --------------------------------------------------------------
  -- Update the AP_PAYMENTS_SCHEDULES GDF taken the information
  -- from Supplier's site.
  --------------------------------------------------------------
Procedure APXINWKB_BR_DEF_PS_SEGMENTS
           (
            P_Invoice_ID Number,
            p_vendor_site_id Number
           ) IS
  -------------------------------------------------------------
  -- Variables for Interest Values
  -------------------------------------------------------------
  v_inttyp VARCHAR2(150);
  v_intamt VARCHAR2(150);
  v_intprd VARCHAR2(150);
  v_intfml VARCHAR2(150);
  v_intgrd VARCHAR2(150);
  v_pnttyp VARCHAR2(150);
  v_pntamt VARCHAR2(150);
  v_asscn  VARCHAR2(150);
  -----------------------------------------------------------
  -- Global Attribute Category
  -----------------------------------------------------------
  v_glbattctg VARCHAR2(150) := 'JL.BR.APXINWKB.AP_PAY_SCHED';
  -----------------------------------------------------------
  -- Variables for Errors
  -----------------------------------------------------------
  errcode1    NUMBER;
  errcode2    NUMBER;
  errcode3    NUMBER;
  errcode4    NUMBER;
  errcode5    NUMBER;
  errcode6    NUMBER;
  errcode7    NUMBER;

 BEGIN
    -------------------------------------------------------
    -- Get interest type as follows for global_attribute1
    -------------------------------------------------------
    JL_ZZ_AP_LIBRARY_1_PKG.Get_interest_type(p_vendor_site_id, v_inttyp, 1, errcode1);
    ------------------------------------------------------
    -- Get penanlty rate/amount days, interest grace days,
    -- interest period, interest rate/amount as follows for
    -- global_attribute7, global_attribute5, global_attribute3, global_attribute2
    ------------------------------------------------------
    JL_ZZ_AP_LIBRARY_1_PKG.Get_Interest_Penalty_Details(p_vendor_site_id, v_pntamt, v_intgrd,
                                                        v_intprd, v_intamt, 1, errcode2);
    ------------------------------------------------------
    -- Get interest formula as follows for global_attribute4
    ------------------------------------------------------
    JL_ZZ_AP_LIBRARY_1_PKG.Get_Interest_Formula(p_vendor_site_id, v_intfml, 1, errcode4);
    ------------------------------------------------------
    -- Get penalty type as follows for global_attribute6
    ------------------------------------------------------
    JL_ZZ_AP_LIBRARY_1_PKG.Get_Penalty_Type(p_vendor_site_id, v_pnttyp, 1, errcode6);
    -----------------------------------------------------
    -- Update payment_schedules with these default values
    -----------------------------------------------------
       UPDATE AP_PAYMENT_SCHEDULES
                   SET GLOBAL_ATTRIBUTE1 = v_inttyp,
                       GLOBAL_ATTRIBUTE2 = v_intamt,
                       GLOBAL_ATTRIBUTE3 = v_intprd,
                       GLOBAL_ATTRIBUTE4 = v_intfml,
                       GLOBAL_ATTRIBUTE5 = v_intgrd,
                       GLOBAL_ATTRIBUTE6 = v_pnttyp,
                       GLOBAL_ATTRIBUTE7 = v_pntamt,
                       GLOBAL_ATTRIBUTE8 = 'N',
                       GLOBAL_ATTRIBUTE_CATEGORY = v_glbattctg
       WHERE INVOICE_ID = P_Invoice_ID;

 EXCEPTION
   WHEN OTHERS THEN
        NULL;
END APXINWKB_BR_Def_PS_Segments;

-----------------------------------------------------------
-- Validate the dates for DUE_DATE and DISCOUNT_DATE
-- also call the procedure to associate collection documents.
-----------------------------------------------------------
PROCEDURE APXINWKB_BR_VALIDATE_PAY_SCHED
            (
             P_Invoice_ID Number,
             p_invoice_type_lookup_code Varchar2,
             p_colldoc_assoc Varchar2,
             P_Vendor_Site_Id Number
            ) IS
    X_association_method          Varchar2(25);
    s_bank_collection_id          jl_br_ap_collection_docs.bank_collection_id%Type;
    s_associate_flag              Varchar2(1);
    l_rec_count                   Number;
    l_new_date_char               Varchar2(30);
    errcode1                      Number;
    -- Cursor on AP_PAYMENT_SCHEDULES
    CURSOR Payments IS
      SELECT  due_date, discount_date, payment_num
        FROM  ap_payment_schedules
       WHERE  invoice_id = P_Invoice_ID;
BEGIN
  -------------------------------------------------------------------
  -- Get Association Method from ap_system_parameters
  -------------------------------------------------------------------
  JL_ZZ_AP_LIBRARY_1_PKG.get_association_method(X_association_method, 1, errcode1);
  -------------------------------------------------------------------
  -- Loop Cursor Payments
  ------------------------------------------------------------------
  FOR db_reg IN Payments LOOP
     BEGIN
        IF db_reg.due_date IS NOT NULL THEN
            l_new_date_char := '';
            ---------------------------------------------------------
            -- Validate Business Day Calendar for DUE DATE
            ---------------------------------------------------------
            APXWKB_BR_VALIDATE_DATE_LOCAL(db_reg.due_date,P_Vendor_Site_Id,l_new_date_char);
            IF l_new_date_char IS NOT NULL THEN
               -----------------------------------------------------
               -- Update AP_PAYMNET_SCHEDULES.due_date
               -----------------------------------------------------
               UPDATE ap_payment_schedules
                      SET due_date = to_date(l_new_date_char,'DD-MM-YYYY')
                WHERE invoice_id   = P_Invoice_ID
                  AND payment_num  = db_reg.payment_num;
            END IF;
        END IF;
        IF db_reg.discount_date IS NOT NULL THEN
            l_new_date_char := '';
            ---------------------------------------------------------
            -- Validate Business Day Calendar for DISCOUNT DATE
            ---------------------------------------------------------
            APXWKB_BR_VALIDATE_DATE_LOCAL(db_reg.discount_date,P_Vendor_Site_Id,l_new_date_char);
            IF l_new_date_char IS NOT NULL THEN
               -----------------------------------------------------
               -- Update AP_PAYMNET_SCHEDULES.discount_date
               -----------------------------------------------------
               UPDATE ap_payment_schedules
                      SET discount_date = to_date(l_new_date_char ,'DD-MM-YYYY')
                WHERE invoice_id  = P_Invoice_ID
                  AND payment_num = db_reg.payment_num ;
            END IF;
        END IF;
        -----------------------------------------------------------
        -- Associate the Collection Documents to Payments Schedules
        -- Only for Invoice Type STANDARD
        -----------------------------------------------------------
        IF nvl(p_invoice_type_lookup_code,'$') = 'STANDARD' THEN
           IF nvl(p_colldoc_assoc,'N') = 'Y' THEN
              JL_BR_AP_ASSOCIATE_COLLECTION.JL_BR_AP_ASSOCIATE_TRADE_NOTE
                                     ( P_Invoice_ID,
                                       db_reg.payment_num,
                                       X_association_method,
                                       s_bank_collection_id,
                                       s_associate_flag
                                      );
              IF Upper(nvl(s_associate_flag,'N')) = 'Y' THEN
                 UPDATE ap_payment_schedules
                        SET global_attribute11 = s_bank_collection_id
                  WHERE invoice_id  = P_Invoice_ID
                    AND payment_num = db_reg.payment_num;
              END IF;  -- if s_associate = 'Y'
           END IF;  -- if nvl(p_colldoc_assoc,'N') <> 'Y'
        END IF;  -- if nvl(p_invoice_type_lookup_code,'$') <> 'STANDARD'
     EXCEPTION
        WHEN OTHERS THEN
             NULL;
     END;
  END LOOP;
END APXINWKB_BR_Validate_Pay_Sched;

--
-- =====================================================================
--                   P U B L I C    O B J E C T S
-- =====================================================================
--
--

PROCEDURE Suppl_Def_Pay_Sched_GDF
            ( P_Invoice_Id  ap_invoices_all.invoice_id%TYPE
             ) IS
  l_invoice_type_lookup_code  varchar2(25);
  s_colldoc_assoc             varchar2(1);
  v_vndstid                   number;
  BEGIN
    ----------------------------------------------------------------------------
    -- Select the Vendor Site ID, Invoice Type and Global_Attr1 from the invoice.
    ----------------------------------------------------------------------------
    SELECT vendor_site_id, invoice_type_lookup_code, substr(global_attribute1,1,1)
      INTO v_vndstid, l_invoice_type_lookup_code, s_colldoc_assoc
      FROM ap_invoices
     WHERE invoice_id = P_Invoice_ID;
   ------------------------------------------------------------------------------------------
   -- First fill the AP_Payment_Schedules GDF
   ------------------------------------------------------------------------------------------
   APXINWKB_BR_DEF_PS_SEGMENTS
                ( P_Invoice_ID,
                  v_vndstid
                );

   ------------------------------------------------------------------------------------------
   -- Validate Calendar (Due_Date,Discount_Date) and Call Trade Note Association
   -- for every payment schedule for this invoice_id thru this following proc.
   -------------------------------------------------------------------------------------------
   APXINWKB_BR_VALIDATE_PAY_SCHED
                ( P_Invoice_ID,
                  l_invoice_type_lookup_code,
                  s_colldoc_assoc,
                  v_vndstid
                );
  EXCEPTION
      WHEN OTHERS THEN
           NULL;
  END Suppl_Def_Pay_Sched_GDF;

Procedure VALIDATE_DATE
            (
             p_date date,
             p_city varchar2,
             p_new_date IN OUT NOCOPY date,
             p_status IN OUT NOCOPY number,
             p_state varchar2) IS --Bug 2319552


  -- Local Variables

  l_calendar varchar2(10);
  l_payment_action varchar2(1);
  l_change_date varchar2(1);
  return_question number;
  returned_date   varchar2(11);

  l_org_id   NUMBER;   --  MOAC Bug # 2306001

  BEGIN
    ------------------------------------------------------------------------
    -- Validate the profile options.
    ------------------------------------------------------------------------
    if p_date IS NOT NULL then
       l_org_id := MO_GLOBAL.get_current_org_id;
       l_payment_action := JL_ZZ_SYS_OPTIONS_PKG.get_payment_action(l_org_id);  -- MOAC
       -- Bug 4715379
       l_calendar := jl_zz_sys_options_pkg.get_calendar;
       l_change_date := jl_zz_sys_options_pkg.get_change_date_automatically(l_org_id);
       if l_payment_action is NOT NULL then
          if l_calendar is NOT NULL then
             if l_change_date is NOT NULL then
                ------------------------------------------------------------
                -- Get the new date.
                ------------------------------------------------------------
                  -- Bug 2319552 : BDC - State Lov : Start ------
                  jl_br_workday_calendar.jl_br_check_date(to_char(p_date,'DD-MM-YYYY'),l_calendar,
                          p_city,l_payment_action,returned_date,p_status, p_state);
                if p_status = 0 then /* procedure successfull */
                   -----------------------------------------------------------
                   -- Return the new date.
                   -----------------------------------------------------------
                   p_new_date := to_date(returned_date,'DD-MM-YYYY');
                   if p_date <> p_new_date then
                      if l_change_date = 'N' then
                          RETURN;
                      end if;
                   end if;
                end if;
             else
                p_status := 1;
             end if;
          else
            p_status := 2;
          end if;
       else
         p_status := 3;
       end if;
    end if;
END VALIDATE_DATE;

/* ***************************************************************
   Function : GET_BORDERO_BANK_REF
   Return   : jl_br_ap_collection_docs.OUR_NUMBER
   Type     : Varchar2
   Objective: Return Bank references stored in 'our_number'
              to ipayments extract. This field is display in
              Bordero as Bank Reference.
   *************************************************************** */
FUNCTION Get_Bordero_Bank_Ref
           (P_Doc_Payable_ID    IN  IBY_Docs_Payable_All.document_payable_id%TYPE,
            P_RETURN_STATUS     OUT NOCOPY  Varchar2)
            RETURN Varchar2
IS
Cursor Bank_Ref IS
    Select  jl.our_number
      From  jl_br_ap_collection_docs jl
           ,ap_payment_schedules_all ap
           ,iby_docs_payable_all iby
    Where   iby.document_payable_id     = P_Doc_Payable_ID
      And   iby.calling_app_doc_unique_ref2 = ap.invoice_id
      And   iby.calling_app_doc_unique_ref3 = ap.payment_num
      And   jl.bank_collection_id       = ap.global_attribute11;

    Bank_Reference jl_br_ap_collection_docs.our_number%TYPE;

Begin
  P_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  Bank_Reference  := NULL;
  FOR Rec IN Bank_Ref LOOP
      Bank_Reference := Rec.our_number;
      RETURN(Bank_Reference);
  END LOOP;
  RETURN(Bank_Reference);

EXCEPTION
   WHEN OTHERS THEN
        -- It was agreed with IBY to do not fail
        NULL;
End Get_Bordero_Bank_Ref;

/* ***************************************************************
   Function : GET_BORDERO_INT_AMT
   Return   : Invoice Interest Amount
   Type     : Number
   Objective: Return Invoice Interest Amount
   *************************************************************** */
FUNCTION Get_Bordero_Int_Amt
           (P_Doc_Payable_ID    IN  IBY_Docs_Payable_All.document_payable_id%TYPE,
            P_Process_Type      IN  VARCHAR2,
            P_RETURN_STATUS     OUT NOCOPY  Varchar2)
            RETURN Number
IS
  CURSOR Process_Type IS
    SELECT pays.process_type
      FROM iby_payments_all     pays
          ,iby_docs_payable_all docs
     WHERE pays.payment_id = docs.payment_id
       AND docs.document_payable_id  = P_Doc_Payable_ID;

   int_amt number;
   l_process_type iby_payments_all.process_type%Type;

Begin
     P_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
     int_amt := 0;
     IF P_Process_Type is null THEN
        For db_reg in Process_Type Loop
            l_process_type := db_reg.process_type;
        End Loop;
     ELSE
            l_process_type := P_Process_Type;
     END IF;
     Begin
       IF (l_process_type = 'IMMEDIATE') THEN

          select sum(nvl(int.invoice_amount,0))
            into int_amt
            from ap_invoices_all int,
                 ap_invoice_relationships  rel,
                 iby_docs_payable_all iby
           where rel.original_invoice_id = iby.calling_app_doc_unique_ref2 -- ap.invoice_id
             and rel.original_payment_num = iby.calling_app_doc_unique_ref3 -- ap.payment_num
             and int.invoice_id = rel.related_invoice_id
             and iby.document_payable_id  = P_Doc_Payable_ID;
            return(int_amt);
        END IF;
     Exception
             WHEN OTHERS THEN
                  return(0);
     End;

     IF (l_process_type <> 'IMMEDIATE'  or P_Process_Type IS NULL) THEN
        SELECT sum(nvl(invoice_amount,0))
          INTO int_amt
          FROM ap_selected_invoices_all ap,
               iby_docs_payable_all iby
         WHERE original_invoice_id  = iby.calling_app_doc_unique_ref2 -- :invoice_id
           AND original_payment_num = iby.calling_app_doc_unique_ref3 -- :payment_num
           AND iby.document_payable_id  = P_Doc_Payable_ID;
           return(int_amt);
     END IF;
    return(int_amt);

EXCEPTION
   WHEN OTHERS THEN
        -- It was agreed with IBY to do not fail
        Return(0);
End Get_Bordero_Int_Amt;

/* ***************************************************************
   Function : GET_BORDERO_ABATEMENT
   Return   : Invoice Interest Amount
   Type     : Number
   Objective: Return Invoice Abatement Amount
   *************************************************************** */
FUNCTION Get_Bordero_Abatement
           (P_Doc_Payable_ID    IN  IBY_Docs_Payable_All.document_payable_id%TYPE,
            P_Process_Type      IN  VARCHAR2,
            P_RETURN_STATUS     OUT NOCOPY  Varchar2)
            RETURN Number
IS
   CURSOR Process_Type IS
    SELECT pays.process_type
      FROM iby_payments_all     pays
          ,iby_docs_payable_all docs
     WHERE pays.payment_id = docs.payment_id
       AND docs.document_payable_id  = P_Doc_Payable_ID;

   abate number;
   l_process_type iby_payments_all.process_type%Type;

Begin
   P_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
   abate := 0;

   IF P_Process_Type is null THEN
      For db_reg in Process_Type Loop
          l_process_type := db_reg.process_type;
      End Loop;
   ELSE
          l_process_type := P_Process_Type;
   END IF;
   Begin
     IF (l_process_type = 'IMMEDIATE') THEN

        SELECT abs(sum(nvl(aid.amount,0)))
        INTO abate
        FROM ap_invoice_distributions_all aid,
             ap_invoice_payments_all aip,
             ap_checks_all ac,
             iby_docs_payable_all iby
        WHERE aid.invoice_id = aip.invoice_id
          AND ac.check_number = iby.payment_id -- :check_number
          AND ac.check_id = aip.check_id
          AND aid.parent_invoice_id = iby.calling_app_doc_unique_ref2 -- :invoice_id
          AND iby.document_payable_id  = P_Doc_Payable_ID;
     ELSE
        SELECT abs(sum(nvl(aid.amount,0)))
        INTO abate
        FROM ap_invoice_distributions_all aid,
             ap_selected_invoices_all asi,
             iby_docs_payable_all iby,
             iby_pay_service_requests proc,
             iby_payments_all paym
        WHERE aid.invoice_id = asi.invoice_id
          AND asi.checkrun_name = proc.call_app_pay_service_req_code -- :p_payment_batch
          AND paym.payment_service_request_id = proc.payment_service_request_id
          AND iby.payment_id = paym.payment_id
          AND asi.ok_to_pay_flag <> 'N'
          AND aid.parent_invoice_id = iby.calling_app_doc_unique_ref2 -- :invoice_id
          AND aid.parent_invoice_id <> aid.invoice_id -- fix for bug 2676773
          AND iby.calling_app_id= 200
          AND iby.document_payable_id  = P_Doc_Payable_ID;

     END IF; -- (l_process_type = 'IMMEDIATE')
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
   END;

  RETURN(nvl(abate, 0));

EXCEPTION
   WHEN OTHERS THEN
        -- It was agreed with IBY to do not fail
        RETURN(nvl(abate, 0));
End Get_Bordero_Abatement;

/* ***************************************************************
   Function : Check_Brazil
   Return   : Checking if country is brazil
   Type     : Number
   Objective: Verify if invoice country is brazil
   *************************************************************** */
Function Check_Brazil
           (P_Doc_Payable_ID    IN  IBY_Docs_Payable_All.document_payable_id%TYPE,
            P_RETURN_STATUS     OUT NOCOPY  Varchar2)
RETURN Number
IS
  Cursor ap_inv IS
   SELECT 1 br_c
     FROM ap_invoices_all ap,
          iby_docs_payable_all iby
    WHERE ap.invoice_id = iby.calling_app_doc_unique_ref2
      AND ap.global_attribute_category = 'JL.BR.APXINWKB.AP_INVOICES'
      AND iby.document_payable_id  = P_Doc_Payable_ID;
BEGIN
    P_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    For db_reg in ap_inv Loop
        If db_reg.br_c = 1 Then
           Return(1);
        Else
           Return(0);
        End if;
    End Loop;
    Return(0);
EXCEPTION
   WHEN OTHERS THEN
        -- It was agreed with IBY to do not fail
        RETURN(0);
END Check_Brazil;

END JL_BR_AP_PAY_SCHED_GDF_PKG; -- Package

/
