--------------------------------------------------------
--  DDL for Package Body IGI_CIS2007_CDROM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS2007_CDROM_PKG" AS
   -- $Header: igipcrub.pls 120.1.12010000.3 2009/04/20 15:08:03 gaprasad ship $

   Procedure Spawn_Loader(p_csv_file_name IN Varchar2) Is
      l_message        Varchar2(1000);
      l_data_file_name Varchar2(2000);
      l_request1_id    Number;
      l_request2_id    Number;
      l_phase          Varchar2(100);
      l_status         Varchar2(100);
      l_dev_phase      Varchar2(100);
      l_dev_status     Varchar2(100);

      l_appln_name     Varchar2(10) := 'IGI';
      l_con_cp         Varchar2(10) := 'IGIPCDUP';
      l_con_cp_desc    Varchar2(200):= 'IGI: CIS2007 Contractor CD-ROM Data Upload Process';

      l_subcon_cp      Varchar2(10) := 'IGIPSDUP';
      l_subcon_cp_desc Varchar2(200):= 'IGI: CIS2007 Subcontractor CD-ROM Data Upload Process';

      E_Request1_Submit_Error Exception;
      E_Request2_Submit_Error Exception;
      E_Request1_Wait_Error   Exception;
      E_Request2_Wait_Error   Exception;
      E_Loader1_Failure       Exception;
      E_Loader2_Failure       Exception;

   Begin
      l_data_file_name := p_csv_file_name;
      l_request1_id := fnd_request.submit_request(application => l_appln_name,
                                                  program     => l_con_cp,
                                                  description => l_con_cp_desc,
                                                  start_time  => NULL,
                                                  sub_request => FALSE,
                                                  argument1   => l_data_file_name,
                                                  argument2   => chr(0),
                                                  argument3   => NULL,
                                                  argument4   => NULL,
                                                  argument5   => NULL,
                                                  argument6   => NULL,
                                                  argument7   => NULL,
                                                  argument8   => NULL,
                                                  argument9   => NULL,
                                                  argument10  => NULL,
                                                  argument11  => NULL,
                                                  argument12  => NULL,
                                                  argument13  => NULL,
                                                  argument14  => NULL,
                                                  argument15  => NULL,
                                                  argument16  => NULL,
                                                  argument17  => NULL,
                                                  argument18  => NULL,
                                                  argument19  => NULL,
                                                  argument20  => NULL,
                                                  argument21  => NULL,
                                                  argument22  => NULL,
                                                  argument23  => NULL,
                                                  argument24  => NULL,
                                                  argument25  => NULL,
                                                  argument26  => NULL,
                                                  argument27  => NULL,
                                                  argument28  => NULL,
                                                  argument29  => NULL,
                                                  argument30  => NULL,
                                                  argument31  => NULL,
                                                  argument32  => NULL,
                                                  argument33  => NULL,
                                                  argument34  => NULL,
                                                  argument35  => NULL,
                                                  argument36  => NULL,
                                                  argument37  => NULL,
                                                  argument38  => NULL,
                                                  argument39  => NULL,
                                                  argument40  => NULL,
                                                  argument41  => NULL,
                                                  argument42  => NULL,
                                                  argument43  => NULL,
                                                  argument44  => NULL,
                                                  argument45  => NULL,
                                                  argument46  => NULL,
                                                  argument47  => NULL,
                                                  argument48  => NULL,
                                                  argument49  => NULL,
                                                  argument50  => NULL,
                                                  argument51  => NULL,
                                                  argument52  => NULL,
                                                  argument53  => NULL,
                                                  argument54  => NULL,
                                                  argument55  => NULL,
                                                  argument56  => NULL,
                                                  argument57  => NULL,
                                                  argument58  => NULL,
                                                  argument59  => NULL,
                                                  argument60  => NULL,
                                                  argument61  => NULL,
                                                  argument62  => NULL,
                                                  argument63  => NULL,
                                                  argument64  => NULL,
                                                  argument65  => NULL,
                                                  argument66  => NULL,
                                                  argument67  => NULL,
                                                  argument68  => NULL,
                                                  argument69  => NULL,
                                                  argument70  => NULL,
                                                  argument71  => NULL,
                                                  argument72  => NULL,
                                                  argument73  => NULL,
                                                  argument74  => NULL,
                                                  argument75  => NULL,
                                                  argument76  => NULL,
                                                  argument77  => NULL,
                                                  argument78  => NULL,
                                                  argument79  => NULL,
                                                  argument80  => NULL,
                                                  argument81  => NULL,
                                                  argument82  => NULL,
                                                  argument83  => NULL,
                                                  argument84  => NULL,
                                                  argument85  => NULL,
                                                  argument86  => NULL,
                                                  argument87  => NULL,
                                                  argument88  => NULL,
                                                  argument89  => NULL,
                                                  argument90  => NULL,
                                                  argument91  => NULL,
                                                  argument92  => NULL,
                                                  argument93  => NULL,
                                                  argument94  => NULL,
                                                  argument95  => NULL,
                                                  argument96  => NULL,
                                                  argument97  => NULL,
                                                  argument98  => NULL,
                                                  argument99  => NULL,
                                                  argument100 => NULL);

      If l_request1_id = 0 Then
         Raise E_Request1_Submit_Error;
      Else
         Commit;
      End If;

      -- Wait for request completion
      If Not fnd_concurrent.wait_for_request(l_request1_id,
                                             10, -- interval seconds
                                             0, -- max wait seconds
                                             l_phase,
                                             l_status,
                                             l_dev_phase,
                                             l_dev_status,
                                             l_message) Then
         Raise E_Request1_Wait_Error;
      End If;

      -- Check request completion status
      If l_dev_phase <> 'COMPLETE' Or l_dev_status <> 'NORMAL' Then
         Raise E_Loader1_Failure;
      End If;

      l_request2_id := fnd_request.submit_request(application => l_appln_name,
                                                  program     => l_subcon_cp,
                                                  description => l_subcon_cp_desc,
                                                  start_time  => NULL,
                                                  sub_request => FALSE,
                                                  argument1   => l_data_file_name,
                                                  argument2   => chr(0),
                                                  argument3   => NULL,
                                                  argument4   => NULL,
                                                  argument5   => NULL,
                                                  argument6   => NULL,
                                                  argument7   => NULL,
                                                  argument8   => NULL,
                                                  argument9   => NULL,
                                                  argument10  => NULL,
                                                  argument11  => NULL,
                                                  argument12  => NULL,
                                                  argument13  => NULL,
                                                  argument14  => NULL,
                                                  argument15  => NULL,
                                                  argument16  => NULL,
                                                  argument17  => NULL,
                                                  argument18  => NULL,
                                                  argument19  => NULL,
                                                  argument20  => NULL,
                                                  argument21  => NULL,
                                                  argument22  => NULL,
                                                  argument23  => NULL,
                                                  argument24  => NULL,
                                                  argument25  => NULL,
                                                  argument26  => NULL,
                                                  argument27  => NULL,
                                                  argument28  => NULL,
                                                  argument29  => NULL,
                                                  argument30  => NULL,
                                                  argument31  => NULL,
                                                  argument32  => NULL,
                                                  argument33  => NULL,
                                                  argument34  => NULL,
                                                  argument35  => NULL,
                                                  argument36  => NULL,
                                                  argument37  => NULL,
                                                  argument38  => NULL,
                                                  argument39  => NULL,
                                                  argument40  => NULL,
                                                  argument41  => NULL,
                                                  argument42  => NULL,
                                                  argument43  => NULL,
                                                  argument44  => NULL,
                                                  argument45  => NULL,
                                                  argument46  => NULL,
                                                  argument47  => NULL,
                                                  argument48  => NULL,
                                                  argument49  => NULL,
                                                  argument50  => NULL,
                                                  argument51  => NULL,
                                                  argument52  => NULL,
                                                  argument53  => NULL,
                                                  argument54  => NULL,
                                                  argument55  => NULL,
                                                  argument56  => NULL,
                                                  argument57  => NULL,
                                                  argument58  => NULL,
                                                  argument59  => NULL,
                                                  argument60  => NULL,
                                                  argument61  => NULL,
                                                  argument62  => NULL,
                                                  argument63  => NULL,
                                                  argument64  => NULL,
                                                  argument65  => NULL,
                                                  argument66  => NULL,
                                                  argument67  => NULL,
                                                  argument68  => NULL,
                                                  argument69  => NULL,
                                                  argument70  => NULL,
                                                  argument71  => NULL,
                                                  argument72  => NULL,
                                                  argument73  => NULL,
                                                  argument74  => NULL,
                                                  argument75  => NULL,
                                                  argument76  => NULL,
                                                  argument77  => NULL,
                                                  argument78  => NULL,
                                                  argument79  => NULL,
                                                  argument80  => NULL,
                                                  argument81  => NULL,
                                                  argument82  => NULL,
                                                  argument83  => NULL,
                                                  argument84  => NULL,
                                                  argument85  => NULL,
                                                  argument86  => NULL,
                                                  argument87  => NULL,
                                                  argument88  => NULL,
                                                  argument89  => NULL,
                                                  argument90  => NULL,
                                                  argument91  => NULL,
                                                  argument92  => NULL,
                                                  argument93  => NULL,
                                                  argument94  => NULL,
                                                  argument95  => NULL,
                                                  argument96  => NULL,
                                                  argument97  => NULL,
                                                  argument98  => NULL,
                                                  argument99  => NULL,
                                                  argument100 => NULL);

      If l_request2_id = 0 Then
        Raise E_Request2_Submit_Error;
      Else
        Commit;
      End If;

      -- Wait for request completion
      If Not fnd_concurrent.wait_for_request(l_request2_id,
                                             10, -- interval seconds
                                             0, -- max wait seconds
                                             l_phase,
                                             l_status,
                                             l_dev_phase,
                                             l_dev_status,
                                             l_message) THEN
         Raise E_Request2_Wait_Error;
      End If;

      -- Check request completion status
      IF l_dev_phase <> 'COMPLETE' Or l_dev_status <> 'NORMAL' Then
         Raise E_Loader2_Failure;
      End If;
   Exception
      When E_Request1_Submit_Error Then
         fnd_message.retrieve(l_message);
         fnd_file.put_line(fnd_file.log, l_message);
         Raise;
      When E_Request2_Submit_Error Then
         fnd_message.retrieve(l_message);
         fnd_file.put_line(fnd_file.log, l_message);
         Raise;
      When E_Request1_Wait_Error Then
         fnd_message.retrieve(l_message);
         fnd_file.put_line(fnd_file.log, l_message);
         Raise;
      When E_Request2_Wait_Error Then
         fnd_message.retrieve(l_message);
         fnd_file.put_line(fnd_file.log, l_message);
         Raise;
      When E_Loader1_Failure Then
         fnd_message.set_name('IGI', 'IGIPCDUP_NOT_NORM_COMPLETE');
         fnd_message.set_token('FILE_NAME', l_data_file_name);
         l_message := fnd_message.get;
         fnd_file.put_line(fnd_file.log, l_message);
         Raise;
      When E_Loader2_Failure Then
         fnd_message.set_name('IGI', 'IGIPSDUP_NOT_NORM_COMPLETE');
         fnd_message.set_token('FILE_NAME', l_data_file_name);
         l_message := fnd_message.get;
         fnd_file.put_line(fnd_file.log, l_message);
         Raise;
      When Others Then
         fnd_message.retrieve(l_message);
         fnd_file.put_line(fnd_file.log, l_message);
         Raise;
    END Spawn_Loader;

    Procedure Match_And_Update(P_Upl_Option IN Varchar2) IS
      l_message      Varchar2(1000);
      l_match_flag   Varchar2(1);
      l_awt_group_id ap_suppliers.awt_group_id%TYPE;
      l_vendor_id    ap_suppliers.vendor_id%TYPE;

      l_matched_flag ap_suppliers.match_status_flag%TYPE := 'M';
      l_date         Date := SYSDATE;
      l_utr_type     Varchar2(1) := NULL;

      l_prof_net_wth   Varchar2(100) := 'IGI_CIS2007_NET_WTH_GROUP';
      l_prof_gross_wth Varchar2(100) := 'IGI_CIS2007_GROSS_WTH_GROUP';
      l_count        Number;

      Cursor C_Igi_Cis_Cdrom_Lines Is
         Select subcontractor_utr,
                subcontractor_name,
                subcontractor_ref_id,
                tax_month_last_paid,
                tax_treatment
         From igi_cis_cdrom_lines_t;

      Cursor C_Cnt(p_utr in igi_cis_cdrom_lines_t.subcontractor_utr%Type) Is
         Select count(*) cnt
         From igi_cis_cdrom_lines_t
         Where subcontractor_utr = p_utr;
   Begin
      For C_Igi_Cis_Cdrom_Lines_Rec In C_Igi_Cis_Cdrom_Lines Loop
         l_match_flag   := 'U';
         l_awt_group_id := NULL;
         l_vendor_id    := NULL;
         l_utr_type     := NULL;
         l_count := 0;

         For C_Cnt_Rec in C_Cnt(C_Igi_Cis_Cdrom_Lines_Rec.subcontractor_utr) Loop
           l_count := C_Cnt_Rec.cnt;
         End Loop;

         If l_count = 1 Then -- Only one record is found in the CD-ROM
            Begin
               If (C_Igi_Cis_Cdrom_Lines_Rec.subcontractor_utr Is Not Null) Then
                  Select pov.vendor_id
                  Into l_vendor_id
                  From ap_suppliers pov
                  Where pov.partnership_utr = C_Igi_Cis_Cdrom_Lines_Rec.subcontractor_utr  and
			pov.end_date_active IS NULL;   -- Bug 8446711
               End If;
            Exception
               When Others Then
                  l_vendor_id := NULL;
                  l_utr_type  := NULL;
            End;
            If (l_vendor_id Is Not NUll) Then
               l_match_flag := 'M';
               l_utr_type   := 'P';
            Else
               Begin
                  If (C_Igi_Cis_Cdrom_Lines_Rec.subcontractor_utr Is Not Null) Then
                     Select pov.vendor_id
                     Into l_vendor_id
                     From ap_suppliers pov
                     Where pov.unique_tax_reference_num = C_Igi_Cis_Cdrom_Lines_Rec.subcontractor_utr  and
			pov.end_date_active IS NULL;   -- Bug 8446711
                  End If;
               Exception
                  When Others Then
                    l_vendor_id := NULL;
                    l_utr_type  := NULL;
               End;
               If (l_vendor_id Is Not Null) Then
                  l_match_flag := 'M';
                  l_utr_type   := 'U';
               End If;
            End If;
         End If;
         /* Updating the interface table with match flag - to generate the report */
         Update igi_cis_cdrom_lines_t
         Set match_flag = l_match_flag
         Where subcontractor_utr = C_Igi_Cis_Cdrom_Lines_Rec.subcontractor_utr;

         /* if CD-ROM subcontractor matches with AP_SUPPLIERS subcontractor and user asks for Upload also */
         If (l_match_flag = 'M' And p_upl_option = 'U') Then
            If (upper(C_Igi_Cis_Cdrom_Lines_Rec.tax_treatment) = 'NET') Then
               l_awt_group_id := fnd_profile.VALUE(l_prof_net_wth);
            Elsif (upper(C_Igi_Cis_Cdrom_Lines_Rec.tax_treatment) = 'GROSS') Then
               l_awt_group_id := fnd_profile.VALUE(l_prof_gross_wth);
            End If;

            /* calling to update existing certificates .. */
            /* Bug 5705187 */
            IGI_CIS2007_TAX_EFF_DATE.main (
             p_vendor_id      => l_vendor_id,
             p_vendor_site_id => NULL,
             p_tax_grp_id     => l_awt_group_id,
             p_pay_tax_grp_id => l_awt_group_id,                     /* Bug 7218825 */
             p_source         => 'CDROM',
             p_effective_date => l_date
                                  );

            /* calling PO API to update PO tables - AP_SUPPLIERS, AP_SUPPLIER_SITES */
            Igi_cis2007_igipverp_pkg.pr_po_api(l_vendor_id,
                                             NULL,
                                             l_matched_flag,
                                             l_date,
                                             l_awt_group_id,
                                             l_utr_type,
                                             C_Igi_Cis_Cdrom_Lines_Rec.subcontractor_utr,
                                             C_Igi_Cis_Cdrom_Lines_Rec.subcontractor_name,
                                             C_Igi_Cis_Cdrom_Lines_Rec.subcontractor_ref_id,
                                             fnd_global.conc_request_id); --Bug 5606118

          End If;
      End LooP;
   Exception
      When Others Then
         fnd_message.retrieve(l_message);
         fnd_file.put_line(fnd_file.log, l_message);
         Raise;
   End Match_And_Update;

   Procedure Generate_Report(p_upl_option IN Varchar2) Is
      l_message VARCHAR2(1000);
      Cursor C_Cdrom_Matched_Vendors Is
         Select subcontractor_utr,
                subcontractor_name,
                subcontractor_ref_id,
                tax_month_last_paid,
                tax_treatment
         From igi_cis_cdrom_lines_t
         Where match_flag = 'M'
         Order by subcontractor_name;

      Cursor C_Cdrom_Unmatched_Vendors Is
         Select subcontractor_utr,
                subcontractor_name,
                subcontractor_ref_id,
                tax_month_last_paid,
                tax_treatment
         From igi_cis_cdrom_lines_t
         Where match_flag = 'U'
         Order by subcontractor_name;

      Cursor C_Vendor_Not_Found Is
         Select vendor_name,
                partnership_utr ,
                unique_tax_reference_num ,
                national_insurance_number,
                company_registration_number
         From ap_suppliers
         Where cis_enabled_flag = 'Y'
           and vendor_id not in (
              SELECT p.vendor_id
              FROM ap_suppliers p, igi_cis_cdrom_lines_t l
              WHERE (p.partnership_utr = l.subcontractor_utr
                     Or p.unique_tax_reference_num = l.subcontractor_utr)
                And match_flag = 'M')
         Order by vendor_name;

      Cursor C_Site_Invoice_Count(P_Utr in igi_cis_cdrom_lines_t.subcontractor_utr%Type) Is
         Select atr.tax_name tax_name,
                atr.tax_rate tax_rate,
                pvs.vendor_site_code site_code,
                nvl(inv.inv_count,0) inv_count
         From ap_suppliers pv,
              ap_supplier_sites pvs,
              ap_awt_tax_rates atr,
              (Select count(distinct(aps.invoice_id)) inv_count,
                      api.vendor_id,
                      api.vendor_site_id
               From ap_payment_schedules aps,
                    ap_invoices api
               Where aps.amount_remaining > 0
                 And api.invoice_id = aps.invoice_id
               Group by api.vendor_id, api.vendor_site_id) inv
         Where (pv.partnership_utr = P_Utr
                   Or pv.unique_tax_reference_num = P_Utr)
           And pvs.vendor_id = pv.vendor_id
           And atr.vendor_id(+) = pvs.vendor_id
           And atr.vendor_site_id(+) = pvs.vendor_site_id
           And trunc(sysdate) between trunc(nvl(atr.start_date(+), sysdate))
               And trunc(nvl(atr.end_date(+), sysdate))
           And inv.vendor_id(+) = atr.vendor_id
           And inv.vendor_site_id(+) = atr.vendor_site_id
         Order by pvs.vendor_site_code, atr.tax_name;
         l_rec_count Number;
    Begin
       fnd_file.put_line(fnd_file.output, '');
       If (p_upl_option = 'U') Then
          fnd_file.put_line(fnd_file.output,'CD-ROM Data : Matched and Updated');
          fnd_file.put_line(fnd_file.output,'---------------------------------');
       Else
          fnd_file.put_line(fnd_file.output, 'CD-ROM Data : Matched');
          fnd_file.put_line(fnd_file.output, '---------------------');
       End If;

       For C_Cdrom_Matched_Vendors_Rec IN C_Cdrom_Matched_Vendors Loop
          fnd_file.put_line(fnd_file.output,'');
          fnd_file.put_line(fnd_file.output,
             'Subcontractor UTR Subcontractor Name           NINO or CRN Tax month last paid Tax treatment');
          fnd_file.put_line(fnd_file.output,
             '----------------- ---------------------------- ----------- ------------------- -------------');
          fnd_file.put_line(fnd_file.output,
             rpad(nvl(to_char(C_Cdrom_Matched_Vendors_Rec.subcontractor_utr),' '),17) || ' ' ||
             rpad(nvl(C_Cdrom_Matched_Vendors_Rec.subcontractor_name,' '),28) || ' ' ||
             rpad(nvl(C_Cdrom_Matched_Vendors_Rec.subcontractor_ref_id,' '),11) || ' ' ||
             rpad(nvl(to_char(C_Cdrom_Matched_Vendors_Rec.tax_month_last_paid),' '),19) || ' ' ||
             C_Cdrom_Matched_Vendors_Rec.tax_treatment);
             l_rec_count := 0;
          For C_Site_Invoice_Count_Rec in C_Site_Invoice_Count(
                C_Cdrom_Matched_Vendors_Rec.subcontractor_utr) Loop
             If l_rec_count = 0 Then
                fnd_file.put_line(fnd_file.output,'');
                fnd_file.put_line(fnd_file.output,
                   'Current Withholding Tax Certificate Details for ' ||
                   C_Cdrom_Matched_Vendors_Rec.subcontractor_name);
                fnd_file.put_line(fnd_file.output,
                   '-----------------------------------------------');
                fnd_file.put_line(fnd_file.output,
                   'Site            Tax Code        Tax Rate        Number of Open Invoices For the Site');
                fnd_file.put_line(fnd_file.output,
                   '--------------- --------------- --------------- ------------------------------------');
             End If;
             fnd_file.put_line(fnd_file.output,
             rpad(nvl(C_Site_Invoice_Count_Rec.site_code,' '),15) || ' ' ||
             rpad(nvl(C_Site_Invoice_Count_Rec.tax_name,' '),15) || ' ' ||
             rpad(nvl(to_char(C_Site_Invoice_Count_Rec.tax_rate),' '),15) || ' ' ||
             rpad(nvl(to_char(C_Site_Invoice_Count_Rec.inv_count),' '),15));
             l_rec_count := l_rec_count + 1;
          End Loop;
       End Loop;

       fnd_file.put_line(fnd_file.output, '');
       fnd_file.put_line(fnd_file.output,'');

       If (p_upl_option = 'U') Then
          fnd_file.put_line(fnd_file.output,'CD-ROM Data : Unmatched and Not Updated');
          fnd_file.put_line(fnd_file.output,'---------------------------------------');
       Else
          fnd_file.put_line(fnd_file.output, 'CD-ROM Data : Unmatched');
          fnd_file.put_line(fnd_file.output, '-----------------------');
       End If;

       fnd_file.put_line(fnd_file.output,'');
       fnd_file.put_line(fnd_file.output,
          'Subcontractor UTR Subcontractor Name           NINO or CRN Tax month last paid Tax treatment');
       fnd_file.put_line(fnd_file.output,
          '----------------- ---------------------------- ----------- ------------------- -------------');

       For C_Cdrom_Unmatched_Vendors_Rec IN C_Cdrom_Unmatched_Vendors Loop
          fnd_file.put_line(fnd_file.output,
             rpad(nvl(to_char(C_Cdrom_Unmatched_Vendors_Rec.subcontractor_utr),' '),17) || ' ' ||
             rpad(nvl(C_Cdrom_Unmatched_Vendors_Rec.subcontractor_name,' '),28) || ' ' ||
             rpad(nvl(C_Cdrom_Unmatched_Vendors_Rec.subcontractor_ref_id,' '),11) || ' ' ||
             rpad(nvl(to_char(C_Cdrom_Unmatched_Vendors_Rec.tax_month_last_paid),' '),19) || ' ' ||
             C_Cdrom_Unmatched_Vendors_Rec.tax_treatment);
       End Loop;

       fnd_file.put_line(fnd_file.output,'');
       fnd_file.put_line(fnd_file.output,'');
       fnd_file.put_line(fnd_file.output,
          'CIS Enabled Subcontractors not found in the CD-ROM data received from HMRC.');
       fnd_file.put_line(fnd_file.output,
          '---------------------------------------------------------------------------');
       fnd_file.put_line(fnd_file.output,'');
       fnd_file.put_line(fnd_file.output,
          'Vendor Name                   Subcontractor UTR Partnership UTR NINO       CRN       ');
       fnd_file.put_line(fnd_file.output,
          '----------------------------- ----------------- --------------- ---------- --------- ');

       For C_Vendor_Not_Found_Rec IN C_Vendor_Not_Found Loop
          fnd_file.put_line(fnd_file.output,
             rpad(nvl(C_Vendor_Not_Found_Rec.vendor_name,' '),29) || ' ' ||
             rpad(nvl(to_char(C_Vendor_Not_Found_Rec.unique_tax_reference_num),' '),17) || ' ' ||
             rpad(nvl(to_char(C_Vendor_Not_Found_Rec.partnership_utr),' '),15) || ' ' ||
             rpad(nvl(C_Vendor_Not_Found_Rec.national_insurance_number,' '),10) || ' ' ||
             C_Vendor_Not_Found_Rec.company_registration_number);
       End Loop;
   Exception
      When Others Then
         fnd_message.retrieve(l_message);
         fnd_file.put_line(fnd_file.log, l_message);
         Raise;
   End Generate_Report;

   Procedure Cis_Duplicate_Data Is
      l_dup_rec CHAR(1) := 'N';
      l_count   Number  := 0;

      Cursor C_Partnership_UTR Is
         Select PARTNERSHIP_UTR
         From ap_suppliers
         Where cis_enabled_flag='Y' and
	       end_date_active IS NULL   -- Bug 8446711
         Group by PARTNERSHIP_UTR
         Having count(PARTNERSHIP_UTR) > 1;

      Cursor C_Subcontractor_UTR IS
         Select UNIQUE_TAX_REFERENCE_NUM
         From ap_suppliers
         Where cis_enabled_flag='Y' and
	       end_date_active IS NULL   -- Bug 8446711
         Group by UNIQUE_TAX_REFERENCE_NUM
         Having count(UNIQUE_TAX_REFERENCE_NUM) > 1;
   Begin
      For C_Partnership_UTR_Rec in C_Partnership_UTR Loop
         l_dup_rec := 'Y';
      End Loop;

      For C_Subcontractor_UTR_Rec in C_Subcontractor_UTR Loop
         l_dup_rec := 'Y';
      End Loop;

      If l_dup_rec = 'Y' Then
         fnd_file.put_line(fnd_file.output, '');
         fnd_file.put_line(fnd_file.output,
            'The CD-ROM Data Upload Process found duplicate values in the system.');
         fnd_file.put_line(fnd_file.output,
            'These duplicate values could lead to potential data corruption.');
         fnd_file.put_line(fnd_file.output,
            'CD-ROM records matching to duplicate records in the system would not be uploaded');
         fnd_file.put_line(fnd_file.output,
            'Please rectify the duplicate data in your system and then submit the CD-ROM Upload Process again.');
         l_count := 0;
         For C_Partnership_UTR_Rec in C_Partnership_UTR Loop
            If l_count = 0 Then
               fnd_file.put_line(fnd_file.output, '');
               fnd_file.put_line(fnd_file.output,
                  'Duplicate Partnership Unique Taxpayer Reference found in the system');
               fnd_file.put_line(fnd_file.output,
                  '-------------------------------------------------------------------');
            End If;
            fnd_file.put_line(fnd_file.output, C_Partnership_UTR_Rec.PARTNERSHIP_UTR);
            l_count := l_count + 1;
         End loop;

         l_count := 0;
         For C_Subcontractor_UTR_Rec in C_Subcontractor_UTR Loop
            If l_count = 0 Then
               fnd_file.put_line(fnd_file.output, '');
               fnd_file.put_line(fnd_file.output,
                  'Duplicate Subcontractor Unique Taxpayer Reference found in the system');
               fnd_file.put_line(fnd_file.output,
                  '---------------------------------------------------------------------');
            End If;
            fnd_file.put_line(fnd_file.output, C_Subcontractor_UTR_Rec.UNIQUE_TAX_REFERENCE_NUM);
            l_count := l_count + 1;
         End Loop;
      End If;
   End Cis_Duplicate_Data;

   Procedure Cdrom_Duplicate_Data Is
      l_dup_rec CHAR(1) := 'N';
      l_count   Number  := 0;

      Cursor C_Subcontractor_UTR IS
         Select SUBCONTRACTOR_UTR
         From igi_cis_cdrom_lines_t
         Group by SUBCONTRACTOR_UTR
         Having count(SUBCONTRACTOR_UTR) >1;
   Begin
      For C_Subcontractor_UTR_Rec in C_Subcontractor_UTR Loop
         l_dup_rec := 'Y';
      End Loop;

      If l_dup_rec = 'Y' Then
         fnd_file.put_line(fnd_file.output, '');
         fnd_file.put_line(fnd_file.output,
            'The CD-ROM Data Upload Process found duplicate values in the CD-ROM data received from HMRC.');
         fnd_file.put_line(fnd_file.output,
            'These Duplicate values could lead to potential data corruption.');
         fnd_file.put_line(fnd_file.output,
            'Duplicate CD-ROM records would not be uploaded');
         fnd_file.put_line(fnd_file.output,
            'Please rectify the CD-ROM data and then submit the CD-ROM Upload Process again.');
         l_count := 0;
         For C_Subcontractor_UTR_Rec in C_Subcontractor_UTR Loop
            If l_count = 0 Then
               fnd_file.put_line(fnd_file.output, '');
               fnd_file.put_line(fnd_file.output,
                  'Duplicate Subcontractor Unique Taxpayer Reference found in the CD-ROM data');
               fnd_file.put_line(fnd_file.output,
                  '--------------------------------------------------------------------------');
            End If;
            fnd_file.put_line(fnd_file.output, C_Subcontractor_UTR_Rec.SUBCONTRACTOR_UTR);
            l_count := l_count + 1;
         End Loop;
      End If;
   End Cdrom_Duplicate_Data;

   Procedure Import_Cdrom_Data_Process( Errbuf       OUT NOCOPY Varchar2,
                                        Retcode      OUT NOCOPY Number,
                                        P_Upl_Option IN Varchar2 ) Is
      l_csv_file_name      Varchar2(2000) := Null;
      l_message            Varchar2(1000);
      l_meaning            Varchar2(80);
      E_No_Csv_File_Error  Exception;
      E_Update_Not_Allowed Exception;

      Cursor C_Upl_Meaning Is
         Select Meaning
         From Igi_lookups
         Where Lookup_type = 'IGI_CIS2007_CDROM_OPTION'
         and lookup_code = 'U';
   Begin
      fnd_file.put_line(fnd_file.output, 'Date : ' || SYSDATE);
      fnd_file.put_line(fnd_file.output,
         'Construction Industry Scheme : CD-ROM Data Upload Process Report');
      fnd_file.put_line(fnd_file.output,
      '----------------------------------------------------------------');
      fnd_file.put_line(fnd_file.output,'');
      l_csv_file_name := fnd_profile.VALUE('IGI_CIS2007_CDROM_DATA_PATH');
      fnd_file.put_line(fnd_file.log, 'Upload Option: ' || p_upl_option);
      fnd_file.put_line(fnd_file.log, 'CD-ROM csv file: ' || l_csv_file_name);
      fnd_file.put_line(fnd_file.log, '');

      If P_Upl_Option = 'U' Then
         If Trunc(sysdate) < trunc(to_date(fnd_profile.value('IGI_CIS2007_LIB_DATE'),'DD-MM-YYYY')) Then
            For C_Upl_Meaning_Rec in C_Upl_Meaning Loop
               l_meaning := C_Upl_Meaning_Rec.Meaning;
            End Loop;
            fnd_file.put_line(fnd_file.output,
               'The ' || l_meaning || ' Option of the CD-ROM Data Upload Process ' ||
               'cannot be run before ' || to_char(to_date(fnd_profile.value('IGI_CIS2007_LIB_DATE'),
               'DD-MM-YYYY'), 'DD-MON-YYYY'));
            Raise E_Update_Not_Allowed;
         End If;
      End If;

      If (l_csv_file_name IS NULL) Then
        Raise E_No_Csv_File_Error;
      END IF;

      Spawn_Loader(l_csv_file_name);

      Cis_Duplicate_Data;
      Cdrom_Duplicate_Data;

      Match_And_Update(p_upl_option);
      Generate_Report(p_upl_option);
   Exception
      When E_No_Csv_File_Error Then
         fnd_message.set_name('IGI', 'IGI_CDROM_NO_FILES_TO_IMPORT');
         fnd_message.set_token('FILE_NAME', l_csv_file_name);
         l_message := fnd_message.get;
         fnd_file.put_line(fnd_file.log, l_message);
         retcode := 2;
         errbuf  := l_message;
      WHEN Others Then
        fnd_message.retrieve(l_message);
        fnd_file.put_line(fnd_file.log, l_message);
        retcode := 2;
        errbuf  := l_message;
   End Import_Cdrom_Data_Process;

End IGI_CIS2007_CDROM_PKG;

/
