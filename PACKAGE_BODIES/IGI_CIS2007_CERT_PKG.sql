--------------------------------------------------------
--  DDL for Package Body IGI_CIS2007_CERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS2007_CERT_PKG" AS
   -- $Header: igipuprb.pls 120.0.12000000.1 2007/07/13 07:05:52 vensubra noship $


   l_debug_level Number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level Number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level  Number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level Number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level Number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level Number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level Number	:=	FND_LOG.LEVEL_UNEXPECTED;
   l_path        Varchar2(50)  :=  'IGI.PLSQL.igipuprb.IGI_CIS2007_CERT_PKG.';


   Procedure WriteLog ( pp_mesg in varchar2 ) Is
      l_debug varchar2(1);
   Begin
      l_debug := fnd_profile.value('IGI_DEBUG_OPTION');
      If l_debug = 'Y' Then
         Fnd_file.put_line( fnd_file.log , pp_mesg ) ;
      End If;
   End;


   Procedure Debug( p_level IN Number, p_path IN Varchar2, p_mesg IN Varchar2  ) Is
   Begin
	  If (p_level >=  l_debug_level ) THEN
         FND_LOG.STRING  (p_level , l_path || p_path , p_mesg );
      End If;
   End ;

   Procedure Update_Rates(
      errbuf       OUT NOCOPY VARCHAR2,
      retcode      OUT NOCOPY NUMBER,
      p_tax_id     IN NUMBER,
      p_group_id   IN NUMBER ) Is

      Cursor C_Tax_Info Is
      SELECT agt.group_id Group_Id,
             atc.name Tax_Name,
             atr.tax_rate_id Tax_Rate_Id,
             atr.tax_rate Tax_Rate,
             atr.start_date,
             atr.end_date
      FROM ap_tax_codes        atc,
           ap_awt_group_taxes  agt,
           ap_awt_tax_rates    atr
      WHERE agt.group_id = nvl(p_group_id, group_id)
        AND atc.name = agt.tax_name
        AND atc.tax_id = p_tax_id
        AND atc.tax_type = 'AWT'
        AND(trunc(sysdate) BETWEEN trunc(nvl(atc.start_date,   sysdate -1))
        AND trunc(nvl(atc.inactive_date,   sysdate + 1)))
        AND atc.name = atr.tax_name
        AND atr.rate_type = 'STANDARD'
        AND(trunc(sysdate) BETWEEN trunc(nvl(atr.start_date,   sysdate -1))
        AND trunc(nvl(atr.end_date,   sysdate + 1)))
        ORDER BY agt.group_id, atr.tax_rate;


      Cursor C_Tax_Names(p_new_grp_id in ap_awt_groups.group_id%Type) Is
      SELECT atr.*
      FROM ap_awt_tax_rates atr, igi_cis_tax_treatment_h his
      WHERE his.new_group_id = p_new_grp_id
        AND atr.tax_rate_id = his.tax_rate_id
        AND atr.priority = 1
      ORDER BY atr.vendor_id, atr.vendor_site_id;

      l_new_tax_rate_id ap_awt_tax_rates.tax_rate_id%Type;

   Begin
      -- Process the latest Valid Tax Rate
      For C_Tax_Info_Rec in C_Tax_Info Loop
         -- Debug Messages
         Debug(l_state_level, 'Update_Rates', 'Processing Tax Info Cursor');
         Debug(l_state_level, 'Update_Rates', 'Group ID : ' || C_Tax_Info_Rec.group_id );
         Debug(l_state_level, 'Update_Rates', 'Tax Code : ' || C_Tax_Info_Rec.tax_name);
         Debug(l_state_level, 'Update_Rates', 'New Tax Rate : ' || C_Tax_Info_Rec.tax_rate);
         WriteLog('Processing Tax Code : ' || C_Tax_Info_Rec.tax_name);
         WriteLog('New Tax Rate : ' || C_Tax_Info_Rec.Tax_rate);
         -- Debug Messages

         -- Process all the latest certificates records for the group id.
         For C_Tax_Names_Rec IN C_Tax_Names(C_Tax_Info_Rec.group_id) LOOP
            --Increment the priority of all records with the current tax name
            -- Debug Messages
            Debug(l_state_level, 'Update_Rates', 'Certificate Details ');
            Debug(l_state_level, 'Update_Rates', 'Vendor Id : ' || C_Tax_Names_Rec.vendor_id);
            Debug(l_state_level, 'Update_Rates', 'Vendor Site Id : ' || C_Tax_Names_Rec.vendor_site_id );
            Debug(l_state_level, 'Update_Rates', 'Tax Code : ' || C_Tax_Names_Rec.tax_name);
            -- Debug Messages

            UPDATE ap_awt_tax_rates
            SET priority = priority + 1
            WHERE vendor_id = C_Tax_Names_Rec.vendor_id
              AND vendor_site_id = C_Tax_Names_Rec.vendor_site_id
              AND tax_name = C_Tax_Names_Rec.tax_name;

            -- Debug Messages
            If sql%Found Then
               Debug(l_state_level, 'Update_Rates',
               'Incremented the priority by 1 for all the vendor site certificates, for the Tax Code '
               || C_Tax_Names_Rec.tax_name);
            End If;
            -- Debug Messages

            --Fetch the start date of the record which has the current tax name and
            --is of priority 2
            -- Update the end date of the record to start date of the new rate - 1
            UPDATE ap_awt_tax_rates
            SET end_date = C_Tax_Info_Rec.start_date
            WHERE tax_rate_id = C_Tax_Names_Rec.tax_rate_id;

            -- Debug Messages
            If sql%Found Then
               Debug(l_state_level, 'Update_Rates',
               'End date the current vendor site certificate for the Tax Code '
               || C_Tax_Names_Rec.tax_name);
            End If;
            -- Debug Messages

            -- Generate a new sequence for the new certificate record.
            SELECT ap_awt_tax_rates_s.nextval
            INTO l_new_tax_rate_id
            FROM dual;

            --Insert a new certificate record for the new record with priority 1
            Insert Into ap_awt_tax_rates(
                   tax_rate_id
                  ,tax_name
                  ,tax_rate
                  ,rate_type
                  ,start_date
                  ,vendor_id
                  ,vendor_site_id
                  ,certificate_number
                  ,certificate_type
                  ,comments
                  ,priority
                  ,org_id
                  ,last_update_date
                  ,last_updated_by
                  ,last_update_login
                  ,creation_date
                  ,created_by)
            Values(l_new_tax_rate_id                                -- tax_rate_id
                  ,C_Tax_Names_Rec.tax_name                          -- tax_name
                  ,C_Tax_Info_Rec.tax_rate                          -- tax_rate
                  ,'CERTIFICATE'                                    -- rate_type
                  ,TRUNC(C_Tax_Info_Rec.start_date)                 -- start_date
                  ,C_Tax_Names_Rec.vendor_id                        -- vendor_id
                  ,C_Tax_Names_Rec.vendor_site_id                   -- vendor_site_id
                  ,'CERT'                                           -- certificate_number
                  ,'STANDARD'                                       -- certificate_type
                  ,'TAX RATE CHANGE'                                -- comments
                  ,0                                                -- priority
                  ,C_Tax_Names_Rec.org_id                           -- org_id
                  ,sysdate                                          -- last_update_date
                  ,nvl(fnd_profile.VALUE('USER_ID'),   0)           -- last_update_by
                  ,nvl(fnd_profile.VALUE('LAST_UPDATE_LOGIN'),   0) -- last_update_login
                  ,sysdate                                          -- creation_date
                  ,nvl(fnd_profile.VALUE('USER_ID'),   0));         -- created_by

            -- Debug Messages
            If sql%Found Then
               Debug(l_state_level, 'Update_Rates',
                  'Inserted a new Certificate record for the vendor site for the new rate '
                  || C_Tax_Info_Rec.Tax_rate);
               WriteLog('Details of the New Certificate inserted');
               WriteLog('Vendor Id : ' || C_Tax_Names_Rec.vendor_id);
               WriteLog('Vendor Site Id : ' || C_Tax_Names_Rec.vendor_site_id);
               WriteLog('Tax Code : ' || C_Tax_Names_Rec.tax_name);
               WriteLog('Tax Rate : ' || C_Tax_Info_Rec.tax_rate);
               WriteLog('Start Date : ' || To_Char(C_Tax_Info_Rec.start_date, 'DD-MON-YYYY'));
            End If;
            -- Debug Messages

            --Insert a corrosponding row in the history table
            Insert Into igi_cis_tax_treatment_h(
                   vendor_id
                  ,vendor_site_id
                  ,tax_rate_id
                  ,old_group_id
                  ,new_group_id
                  ,effective_date
                  ,source_name
                  ,last_update_date
                  ,last_updated_by
                  ,last_update_login
                  ,creation_date
                  ,created_by
                  ,request_id
                  ,program_id
                  ,program_application_id
                  ,program_login_id)
            Values(C_Tax_Names_Rec.vendor_id                           -- vendor_id
                  ,C_Tax_Names_Rec.vendor_site_id                      -- vendor_site_id
                  ,l_new_tax_rate_id                                   -- tax_rate_id
                  ,C_Tax_Info_Rec.group_id                             -- old_group_id
                  ,C_Tax_Info_Rec.group_id                             -- new_group_id
                  ,TRUNC(C_Tax_Info_Rec.start_date)                    -- effective_date
                  ,'TAX RATE CHANGE'                                   -- source_name
                  ,sysdate                                          -- last_update_date
                  ,nvl(fnd_profile.VALUE('USER_ID'),   0)           -- last_update_by
                  ,nvl(fnd_profile.VALUE('LAST_UPDATE_LOGIN'),   0) -- last_update_login
                  ,sysdate                                          -- creation_date
                  ,nvl(fnd_profile.VALUE('USER_ID'),   0)           -- created_by
                  ,fnd_global.conc_request_id                       -- request_id
                  ,fnd_global.conc_program_id                       -- program_id
                  ,fnd_global.prog_appl_id                          -- program_application_id
                  ,fnd_global.conc_login_id);                       -- program_login_id

            -- Debug Messages
            If sql%Found Then
               Debug(l_state_level, 'Update_Rates',
                  'Inserted a new history record for the coresponding new certifcate ');
            End If;
            -- Debug Messages

         End Loop; -- C_Tax_Names

         -- Update all the 0 priority records to 1
         UPDATE ap_awt_tax_rates
         SET priority = priority + 1
         WHERE (vendor_id, vendor_site_id, tax_rate_id) in
                           (SELECT atr.vendor_id , atr.vendor_site_id, atr.tax_rate_id
                            FROM ap_awt_tax_rates atr, igi_cis_tax_treatment_h his
                            WHERE new_group_id = C_Tax_Info_Rec.group_id
                            AND atr.tax_rate_id = his.tax_rate_id
                            AND priority = 0 );

         -- Debug Messages
         If sql%Found Then
            Debug(l_state_level, 'Update_Rates',
            'Updated the 0 priority certificates just inserted to 1');
         End If;
         -- Debug Messages

      End Loop; -- C_Tax_Info Loop
      Retcode := 0;
      Commit;
   Exception
      WHEN Others Then
          Errbuf :=  'Error Message: ' || sqlerrm || ' Error Code: ' || to_char(sqlcode);
               Debug(l_state_level, 'Update_Rates',errbuf);
          Retcode := 2;
   End;
End IGI_CIS2007_CERT_PKG;

/
