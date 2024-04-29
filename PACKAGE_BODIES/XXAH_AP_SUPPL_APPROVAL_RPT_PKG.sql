--------------------------------------------------------
--  DDL for Package Body XXAH_AP_SUPPL_APPROVAL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_AP_SUPPL_APPROVAL_RPT_PKG" 
AS

/***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_AP_SUPPL_APPROVAL_RPT_PKG
   * DESCRIPTION       : PACKAGE body for Supplier Approval Workflow Reports
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY           COMMENTS
   * 03-MAR-2020        1.0       Anish Hussain     Initial Package
   * 06-MAR-2020        1.1       Anish Hussain     Added Procedure for Audit history report
   ****************************************************************************/
   /****
   PROCEDURE pending_suppl_approval_report(errbuf OUT VARCHAR2
                                             ,retcode OUT VARCHAR2
                                             )
   IS
     i                          NUMBER              := 1;
     j                          NUMBER              := 1;
     p_to                       VARCHAR2 (100);
     lv_smtp_server             VARCHAR2 (100)      := 'mail.ah.nl';
     lv_domain                  VARCHAR2 (100);
     lv_from                    VARCHAR2 (100)      := '@ah.nl';
     v_connection               UTL_SMTP.connection;
     c_mime_boundary   CONSTANT VARCHAR2 (256)      := '--AAAAA000956--';
     v_clob                     CLOB;
     ln_len                     INTEGER;
     ln_index                   INTEGER;
     ln_count                   NUMBER;
     ln_code                    VARCHAR2 (10);
     ln_counter                 NUMBER              := 0;
     lv_instance                VARCHAR2 (100);
     ln_cnt                     NUMBER;
     ld_date                    DATE;
     ln_user_id                 fnd_user.user_id%TYPE;
     CURSOR c_data 
     IS
      SELECT  vendor_name,vendor_number,status,action,unit_manager,business_controller,approval_initiated
             ,Bus_approval_status,unit_approval_status,inactive_date
             ,DECODE(approval_initiated,'N','Workflow Not Initiated',pending_with) pending_with
             ,last_updated_by cmt_user
             ,CASE
                WHEN approval_initiated = 'N'
                THEN NULL
                ELSE approval_start_date
              END approval_start_date
             ,CASE 
                WHEN action = 'CREATE' AND APPROVAL_INITIATED = 'Y' AND UNIT_APPROVAL_STATUS <> 'APPROVED'
                THEN approval_start_date
                ELSE NULL
              END Unit_approval_start
             ,CASE 
                WHEN action = 'CREATE' AND APPROVAL_INITIATED = 'Y' AND UNIT_APPROVAL_STATUS = 'APPROVED'
                THEN unit_appr_last_update_date
                WHEN action <> 'CREATE' AND APPROVAL_INITIATED = 'Y'
                THEN approval_start_date
                ELSE NULL
              END business_approval_start
        FROM (SELECT  DISTINCT aps.vendor_name,aps.segment1 vendor_number,sup_status.c_ext_attr1 status,sup_status.c_ext_attr2 action
                     ,supp_app.c_ext_attr1 unit_manager,supp_app.c_ext_attr2 business_controller,supp_app.c_ext_attr3 approval_initiated
                     ,Bus_app.c_ext_attr1 Bus_approval_status,unit_app.c_ext_attr1 unit_approval_status,sup_status.last_update_date inactive_date
                     ,supp_app.cmt_user,supp_app.last_update_date approval_start_date,unit_app.last_update_date unit_appr_last_update_date
                     ,papf.full_name last_updated_by 
                     ,CASE 
                        WHEN sup_status.c_ext_attr2 = 'CREATE' AND unit_app.c_ext_attr1 <> 'APPROVED'
                        THEN supp_app.c_ext_attr1
                        WHEN sup_status.c_ext_attr2 = 'CREATE' AND unit_app.c_ext_attr1 = 'APPROVED' AND Bus_app.c_ext_attr1 <> 'APPROVED'
                        THEN supp_app.c_ext_attr2
                        WHEN sup_status.c_ext_attr2 IN ('BANK_UPDATE','TERMS_UPDATE','BANK_AND_TERMS_UPDATE') AND Bus_app.c_ext_attr1 <> 'APPROVED'
                        THEN supp_app.c_ext_attr2
                      END pending_with
                FROM  pos_supp_prof_ext_b pspe
                     ,ap_suppliers aps
                     ,fnd_user fu
                     ,per_all_people_f papf
                     ,(SELECT papf.full_name cmt_user,pspe.*
                         FROM pos_supp_prof_ext_b pspe
                             ,ego_attr_groups_v eagv
                             ,fnd_user fu
                             ,per_all_people_f papf
                        WHERE 1=1
                          AND eagv.attr_group_name = 'XXAH_SUPPLIER_APPROVERS'
                          AND pspe.attr_group_id = eagv.attr_group_id
                          AND fu.user_id = pspe.last_updated_by
                          AND fu.person_party_id = papf.party_id
                          AND  TRUNC(SYSDATE) BETWEEN TRUNC(NVL(papf.EFFECTIVE_START_DATE,SYSDATE)) AND TRUNC(NVL(papf.EFFECTIVE_END_DATE,SYSDATE))
                          ) supp_app
                     ,(SELECT pspe.*
                         FROM pos_supp_prof_ext_b pspe
                             ,ego_attr_groups_v eagv
                        WHERE 1=1
                          AND eagv.attr_group_name = 'XXAH_BUSINESS_CONT_APPROVAL'
                          AND pspe.attr_group_id = eagv.attr_group_id) Bus_app
                     ,(SELECT pspe.*
                         FROM pos_supp_prof_ext_b pspe
                             ,ego_attr_groups_v eagv
                        WHERE 1=1
                          AND eagv.attr_group_name = 'XXAH_UNIT_MANAGER_APPROVAL'
                          AND pspe.attr_group_id = eagv.attr_group_id) unit_app
                     ,(SELECT pspe.*
                         FROM pos_supp_prof_ext_b pspe
                             ,ego_attr_groups_v eagv
                        WHERE 1=1
                          AND eagv.attr_group_name = 'XXAH_SUPPLIER_STATUS'
                          AND pspe.attr_group_id = eagv.attr_group_id
                          and pspe.c_ext_attr1 ='INACTIVE') sup_status
               WHERE 1=1
                 AND aps.party_id = pspe.party_id
                 AND pspe.party_id(+) = supp_app.party_id
                 AND pspe.party_id(+) = Bus_app.party_id
                 AND pspe.party_id = unit_app.party_id(+)
                 AND pspe.party_id = sup_status.party_id
                 AND fu.user_id = aps.last_updated_by
                 AND fu.person_party_id = papf.party_id
                 AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(papf.EFFECTIVE_START_DATE,SYSDATE)) AND TRUNC(NVL(papf.EFFECTIVE_END_DATE,SYSDATE)))
                 ;
     CURSOR email_address_cur(p_user_id IN fnd_user.user_id%TYPE)
     IS
        SELECT  NVL(papf.email_address,fu.email_address)
          FROM  fnd_user fu
               ,per_all_people_f papf
         WHERE  1=1
           AND  fu.person_party_id = papf.party_id
           AND  TRUNC(SYSDATE) BETWEEN TRUNC(NVL(papf.EFFECTIVE_START_DATE,SYSDATE)) AND TRUNC(NVL(papf.EFFECTIVE_END_DATE,SYSDATE))
           AND  fu.user_id = p_user_id;
  BEGIN
     ld_date := SYSDATE;
     lv_domain := lv_smtp_server;
     fnd_file.put_line(fnd_file.log,'Begin Execution of pending_suppl_approval_report');
     ln_user_id := fnd_profile.value('USER_ID');
     SELECT  instance_name
       INTO  lv_instance
       FROM  v$instance
      WHERE  rownum =1;
     lv_from := lv_instance||lv_from;
     OPEN email_address_cur(ln_user_id);
     FETCH email_address_cur INTO p_to;
     CLOSE email_address_cur;
     BEGIN
        v_clob := 'Vendor Name' || ',' || 'Vendor Number' ||','|| 'Inactive Due to ' ||','||'Inactive From'||','
                  || 'Approval Workflow Initiated'||','||'Approval Workflow Start Date'||','||'CMT User Name'||','
                  || 'Start date of Unit Manager Approval'||','||'Unit Manager' ||','||'Unit Manager Approval Status' ||','
                  || 'Start date of Business Controller Approval'||','||'Business Controller'||','|| 'Business Controller Approval Status'|| ','
                  || 'Pending With'
                  || UTL_TCP.crlf;
        v_connection := UTL_SMTP.open_connection (lv_smtp_server,25); --To open the connection      UTL_SMTP.helo (v_connection, lv_domain);
        utl_smtp.helo(v_connection, lv_smtp_server);
        UTL_SMTP.mail (v_connection, lv_from);
        UTL_SMTP.rcpt (v_connection, p_to); -- To send mail to valid receipent     
        UTL_SMTP.open_data (v_connection);
        UTL_SMTP.write_data (v_connection, 'From: ' || lv_from || UTL_TCP.crlf);
        IF TRIM (p_to) IS NOT NULL
        THEN
           UTL_SMTP.write_data (v_connection, 'To: ' || p_to || UTL_TCP.crlf);
        END IF;
        UTL_SMTP.write_data (v_connection,
                             'Subject: Pending Suppliers for Approval Report' || UTL_TCP.crlf
                            );
        UTL_SMTP.write_data (v_connection, 'MIME-Version: 1.0' || UTL_TCP.crlf);
        UTL_SMTP.write_data (v_connection,
                                'Content-Type: multipart/mixed; boundary="'
                             || c_mime_boundary
                             || '"'
                             || UTL_TCP.crlf
                            );
        UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);
        UTL_SMTP.write_data (v_connection,
                                'This is a multi-part message in MIME format.'
                             || UTL_TCP.crlf
                            );
        UTL_SMTP.write_data (v_connection,
                             '--' || c_mime_boundary || UTL_TCP.crlf
                            );
        UTL_SMTP.write_data (v_connection,
                             'Content-Type: text/plain' || UTL_TCP.crlf
                            );
        ln_cnt := 1;
        --Condition to check for the creation of csv attachment
        IF (ln_cnt <> 0)
        THEN
           UTL_SMTP.write_data
                              (v_connection,
                                  'Content-Disposition: attachment; filename="'
                               || 'Supplier_details'
                               || TO_CHAR (ld_date, 'dd-mon-rrrr hh:mi')
                               || '.csv'
                               || '"'
                               || UTL_TCP.crlf
                              );
        END IF;
        UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);
        FOR i IN c_data
        LOOP
           ln_counter := ln_counter + 1;
           IF ln_counter = 1
           THEN
           UTL_SMTP.write_data (v_connection, v_clob);--To avoid repeation of column heading in csv file
           END IF;
           BEGIN
              v_clob := '="' || i.vendor_name || '"' || ',' 
                        || i.vendor_number  || ',' 
                        || i.action || ',' 
                        || i.inactive_date || ','
                        || i.approval_initiated || ',' 
                        || i.approval_start_date|| ',"'
                        || i.cmt_user|| '",'
                        || i.Unit_approval_start||',"'
                        || i.unit_manager || '",'  
                        || i.unit_approval_status || ',' 
                        || i.business_approval_start||',"'
                        || i.business_controller || '",' 
                        || i.Bus_approval_status || ',"' 
                        || i.pending_with || '"'
                        || UTL_TCP.crlf;
           EXCEPTION
              WHEN OTHERS
              THEN
                 fnd_file.put_line(fnd_file.log,'Exception while generating CSV - '||SQLERRM);
           END;
           UTL_SMTP.write_data (v_connection, v_clob); --Writing data in csv attachment.     
        END LOOP;
        UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);
        UTL_SMTP.close_data (v_connection);
        UTL_SMTP.quit (v_connection);
        COMMIT;
     EXCEPTION
        WHEN OTHERS
        THEN
           fnd_file.put_line(fnd_file.log,'Exception inside mail processing - '||SQLERRM);
     END;
     fnd_file.put_line(fnd_file.log,'End Execution of pending_suppl_approval_report');
  EXCEPTION
    WHEN OTHERS
    THEN
      fnd_file.put_line(fnd_file.log,'Exceptiion in pending_suppl_approval_report - '||SQLERRM);
  END pending_suppl_approval_report;
  */
  PROCEDURE pending_suppl_approval_report(errbuf OUT VARCHAR2
                                             ,retcode OUT VARCHAR2
                                             )
   IS
     i                          NUMBER              := 1;
     j                          NUMBER              := 1;
     p_to                       VARCHAR2 (100);
     lv_smtp_server             VARCHAR2 (100)      := 'vmebsdblpwe01.retail.ah.eu-int-aholddelhaize.com';
     lv_domain                  VARCHAR2 (100);
     lv_from                    VARCHAR2 (100)      := '@ah.nl';
     v_connection               UTL_SMTP.connection;
     c_mime_boundary   CONSTANT VARCHAR2 (256)      := '--AAAAA000956--';
     v_clob                     CLOB;
     ln_len                     INTEGER;
     ln_index                   INTEGER;
     ln_count                   NUMBER;
     ln_code                    VARCHAR2 (10);
     ln_counter                 NUMBER              := 0;
     lv_instance                VARCHAR2 (100);
     ln_cnt                     NUMBER;
     ld_date                    DATE;
     ln_user_id                 fnd_user.user_id%TYPE;
     -----------
     V_SERVER  varchar2(500);
      V_EMAIL varchar2(500);
      V_TOEMAIL varchar2(500);
      V_INSTANCE varchar2(1000);
      v_top varchar2(500);
      v_filename         VARCHAR2 (100);
      v_date             VARCHAR2 (50);
      v_req_id     NUMBER;
      g_request_id                    NUMBER       := fnd_global.conc_request_id;
     CURSOR c_data 
     IS
        SELECT  REPLACE(vendor_name,'&',';') vendor_name,vendor_number,status,action,business_controller,NVL(approval_initiated,'N') approval_initiated
             ,Bus_approval_status,inactive_date
             ,DECODE(NVL(approval_initiated,'N'),'N','Workflow Not Initiated',pending_with) pending_with
             --,last_updated_by cmt_user
             ,NVL(cmt_user,last_updated_by) cmt_user,supplier_type
             ,CASE
                WHEN approval_initiated = 'N'
                THEN NULL
                ELSE approval_start_date
              END approval_start_date
             ,CASE 
                WHEN action = 'CREATE' AND APPROVAL_INITIATED = 'Y' AND UNIT_APPROVAL_STATUS <> 'APPROVED'
                THEN approval_start_date
                ELSE NULL
              END Unit_approval_start
             ,CASE 
                WHEN action = 'CREATE' AND APPROVAL_INITIATED = 'Y' AND UNIT_APPROVAL_STATUS = 'APPROVED'
                THEN unit_appr_last_update_date
                WHEN action <> 'CREATE' AND APPROVAL_INITIATED = 'Y'
                THEN approval_start_date
                ELSE NULL
              END business_approval_start
             ,CASE 
                WHEN action <> 'CREATE'
                THEN NULL
                ELSE unit_manager
              END unit_manager
             ,CASE 
                WHEN action <> 'CREATE'
                THEN NULL
                ELSE unit_approval_status
              END unit_approval_status
        FROM (SELECT  DISTINCT aps.vendor_name,aps.segment1 vendor_number,sup_status.c_ext_attr1 status,sup_status.c_ext_attr2 action
                     ,supp_app.c_ext_attr1 unit_manager,supp_app.c_ext_attr2 business_controller,supp_app.c_ext_attr3 approval_initiated
                     ,Bus_app.c_ext_attr1 Bus_approval_status,unit_app.c_ext_attr1 unit_approval_status,sup_status.last_update_date inactive_date
                     ,supp_app.cmt_user,supp_app.last_update_date approval_start_date,unit_app.last_update_date unit_appr_last_update_date
                     ,papf.full_name last_updated_by 
                     ,pspe.c_ext_attr1 supplier_type
                     ,CASE 
                        WHEN sup_status.c_ext_attr2 = 'CREATE' AND unit_app.c_ext_attr1 <> 'APPROVED'
                        THEN supp_app.c_ext_attr1
                        WHEN sup_status.c_ext_attr2 = 'CREATE' AND unit_app.c_ext_attr1 = 'APPROVED' AND Bus_app.c_ext_attr1 <> 'APPROVED'
                        THEN supp_app.c_ext_attr2
                        WHEN sup_status.c_ext_attr2 IN ('BANK_UPDATE','TERMS_UPDATE','BANK_AND_TERMS_UPDATE') AND Bus_app.c_ext_attr1 <> 'APPROVED'
                        THEN supp_app.c_ext_attr2
                      END pending_with
                FROM  pos_supp_prof_ext_b pspe
                     ,ap_suppliers aps
                     ,fnd_user fu
                     ,per_all_people_f papf
                     ,ego_attr_groups_v eagv
                     ,(SELECT papf.full_name cmt_user,pspe.*
                         FROM pos_supp_prof_ext_b pspe
                             ,ego_attr_groups_v eagv
                             ,fnd_user fu
                             ,per_all_people_f papf
                        WHERE 1=1
                          AND eagv.attr_group_name = 'XXAH_SUPPLIER_APPROVERS'
                          AND pspe.attr_group_id = eagv.attr_group_id
                          AND fu.user_id = pspe.last_updated_by
                          AND fu.person_party_id = papf.party_id
                          AND  TRUNC(SYSDATE) BETWEEN TRUNC(NVL(papf.EFFECTIVE_START_DATE,SYSDATE)) AND TRUNC(NVL(papf.EFFECTIVE_END_DATE,SYSDATE))
                          ) supp_app
                     ,(SELECT pspe.*
                         FROM pos_supp_prof_ext_b pspe
                             ,ego_attr_groups_v eagv
                        WHERE 1=1
                          AND eagv.attr_group_name = 'XXAH_BUSINESS_CONT_APPROVAL'
                          AND pspe.attr_group_id = eagv.attr_group_id) Bus_app
                     ,(SELECT pspe.*
                         FROM pos_supp_prof_ext_b pspe
                             ,ego_attr_groups_v eagv
                        WHERE 1=1
                          AND eagv.attr_group_name = 'XXAH_UNIT_MANAGER_APPROVAL'
                          AND pspe.attr_group_id = eagv.attr_group_id) unit_app
                     ,(SELECT pspe.*
                         FROM pos_supp_prof_ext_b pspe
                             ,ego_attr_groups_v eagv
                        WHERE 1=1
                          AND eagv.attr_group_name = 'XXAH_SUPPLIER_STATUS'
                          AND pspe.attr_group_id = eagv.attr_group_id
                          and pspe.c_ext_attr1 ='INACTIVE') sup_status
               WHERE 1=1
                 AND aps.party_id = pspe.party_id(+)
                 --AND aps.segment1 = '200010095'
                 AND pspe.party_id = supp_app.party_id(+)
                 AND pspe.party_id = Bus_app.party_id(+)
                 AND pspe.party_id = unit_app.party_id(+)
                 AND pspe.party_id = sup_status.party_id
                 AND UPPER(eagv.attr_group_name) = UPPER('XXAH_SUPPLIER_TYPE')
                 AND pspe.attr_group_id = eagv.attr_group_id(+)
                 AND NVL(UPPER(pspe.c_ext_attr1(+)),'ZZZZZZ') != 'NFR'
                 AND fu.user_id = aps.last_updated_by
                 AND fu.person_party_id = papf.party_id
                 AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(papf.EFFECTIVE_START_DATE,SYSDATE)) AND TRUNC(NVL(papf.EFFECTIVE_END_DATE,SYSDATE))
                 )
                 order by 1;
     CURSOR email_address_cur(p_user_id IN fnd_user.user_id%TYPE)
     IS
        SELECT  NVL(papf.email_address,fu.email_address)
          FROM  fnd_user fu
               ,per_all_people_f papf
         WHERE  1=1
           AND  fu.person_party_id = papf.party_id
           AND  TRUNC(SYSDATE) BETWEEN TRUNC(NVL(papf.EFFECTIVE_START_DATE,SYSDATE)) AND TRUNC(NVL(papf.EFFECTIVE_END_DATE,SYSDATE))
           AND  fu.user_id = p_user_id;
  BEGIN
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<?xml version="1.0"?>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SUPPLIER_INFO>');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering');
    select parameter_value 
    into V_SERVER
    from fnd_svc_comp_param_vals fvcp,FND_SVC_COMP_PARAMS_B fpv,FND_SVC_COMPONENTS fpc
    where fpv.parameter_name = 'OUTBOUND_SERVER'
    and fpc.component_name = 'Workflow Notification Mailer'
    and fvcp.component_id = fpc.component_id
    and fvcp.parameter_id  = fpv.parameter_id;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Getting from email Address');
    SELECT  instance_name
       INTO  lv_instance
       FROM  v$instance
      WHERE  rownum =1;
     V_EMAIL := lv_instance||lv_from;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'V_EMAIL'||V_EMAIL);

    select fnd_profile.value('XXAH_TOP_DETAILS') 
      into v_top
      from dual;

    V_INSTANCE := v_top||'/'||'XXAH_Supplier_deatils.rtf';
     fnd_file.put_line(fnd_file.log,'Begin Execution of pending_suppl_approval_report');
     ln_user_id := fnd_profile.value('USER_ID');     
     OPEN email_address_cur(ln_user_id);
     FETCH email_address_cur INTO V_TOEMAIL;
     CLOSE email_address_cur;
     v_date := NULL;
     BEGIN
        SELECT   TO_CHAR (TO_DATE (SYSDATE), 'RRRRMMDD') file_date
          INTO   v_date
          FROM   DUAL;
     EXCEPTION
        WHEN OTHERS
        THEN
          v_date := NULL;
     END;
     v_filename := v_date;
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_SERVER>'||V_SERVER||'</V_SERVER>');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_EMAIL>'||V_EMAIL||'</V_EMAIL>');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_TOEMAIL>'||V_TOEMAIL||'</V_TOEMAIL>');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_INSTANCE>'||V_INSTANCE||'</V_INSTANCE>');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_FILENAME>'||V_FILENAME||'</V_FILENAME>');
        FOR i IN c_data
        LOOP
           ln_counter := ln_counter + 1;           
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SUPPLIER>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<VENDOR_NAME>'||i.vendor_name||'</VENDOR_NAME>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<VENDOR_NUMBER>'||i.vendor_number||'</VENDOR_NUMBER>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<ACTION>'||i.action||'</ACTION>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<INACTIVE_DATE>'||i.inactive_date||'</INACTIVE_DATE>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<APPROVAL_INITIATED>'||i.approval_initiated||'</APPROVAL_INITIATED>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<APPROVAL_START_DATE>'||i.approval_start_date||'</APPROVAL_START_DATE>');FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<VENDOR_NUMBER>'||i.vendor_number||'</VENDOR_NUMBER>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<CMT_USER>'||i.cmt_user||'</CMT_USER>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<UNIT_APPROVAL_START>'||i.Unit_approval_start||'</UNIT_APPROVAL_START>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<UNIT_MANAGER>'||i.unit_manager||'</UNIT_MANAGER>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<UNIT_APPROVAL_STATUS>'||i.unit_approval_status||'</UNIT_APPROVAL_STATUS>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<BUSINESS_APPROVAL_START>'||i.business_approval_start||'</BUSINESS_APPROVAL_START>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<BUSINESS_CONTROLLER>'||i.business_controller||'</BUSINESS_CONTROLLER>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<BUS_APPROVAL_STATUS>'||i.Bus_approval_status||'</BUS_APPROVAL_STATUS>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<PENDING_WITH>'||i.pending_with||'</PENDING_WITH>'); 
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</SUPPLIER>');
        END LOOP;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</SUPPLIER_INFO>');
     IF ln_counter > 0 
     THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Submitting the XML Bursting');
                  v_req_id := fnd_request.submit_request
                              ('XDO'
                              ,'XDOBURSTREP'
                              ,NULL
                              ,SYSDATE
                              ,FALSE
                              ,NULL --'Y'  ---xdo_cp_data_security_pkg.get_concurrent_request_ids
                              ,g_request_id
                              ,'Y');

      IF v_req_id = 0
      THEN
          fnd_file.put_line(fnd_file.log,'Bursting program failed');
      END IF;  -- v_req_id = 0

     end IF;
     fnd_file.put_line(fnd_file.log,'End Execution of pending_suppl_approval_report');
  EXCEPTION
    WHEN OTHERS
    THEN
      fnd_file.put_line(fnd_file.log,'Exceptiion in pending_suppl_approval_report - '||SQLERRM);
  END pending_suppl_approval_report;

  ---------------------------Audit History Report-------------------
  /*
  PROCEDURE supp_appr_audit_history_report(errbuf OUT VARCHAR2
                                           ,retcode OUT VARCHAR2
                                           ,p_vendor_name IN ap_suppliers.vendor_name%TYPE
                                           ,p_approval_from IN VARCHAR2
                                           ,p_approval_to IN VARCHAR2
                                           )
  IS
     i                          NUMBER              := 1;
     j                          NUMBER              := 1;
     p_to                       VARCHAR2 (100);
     lv_smtp_server             VARCHAR2 (100)      := 'mail.ah.nl';
     lv_domain                  VARCHAR2 (100);
     lv_from                    VARCHAR2 (100)      := '@ah.nl';
     v_connection               UTL_SMTP.connection;
     c_mime_boundary   CONSTANT VARCHAR2 (256)      := '--AAAAA000956--';
     v_clob                     CLOB;
     ln_len                     INTEGER;
     ln_index                   INTEGER;
     ln_count                   NUMBER;
     ln_code                    VARCHAR2 (10);
     ln_counter                 NUMBER              := 0;
     lv_instance                VARCHAR2 (100);
     ln_cnt                     NUMBER;
     ld_date                    DATE;
     ln_user_id                 fnd_user.user_id%TYPE;
     CURSOR c_data 
     IS
        SELECT DISTINCT hou.name,aps.segment1, a.*
          FROM (SELECT vendor_name,
                       vendor_site,
                       payment_terms,
                       retainage_rate,
                       action,
                       Unit_manager,
                       business_controller,
                       TRUNC (approval_date) approval_date,
                       party_id,
                       bank_name,
                       bank_branch_name,
                       bank_account_number,
                       bank_account_name,
                       IBAN,
                       currency_code,
                       check_digits
                  FROM (SELECT vendor_name,
                               DECODE (Vendor_site, 'ZZZZZZ', NULL, Vendor_site)
                                  vendor_site,
                               payment_terms,
                               retainage_rate,
                               action,
                               Unit_manager,
                               business_controller,
                               approval_date,
                               party_id,
                               bank_name,
                               bank_branch_name,
                               bank_account_number,
                               bank_account_name,
                               IBAN,
                               currency_code,
                               check_digits
                          FROM (  SELECT DISTINCT
                                         pspe.c_ext_attr2 vendor_name,
                                         MIN (NVL (pspe.c_ext_attr1, 'ZZZZZZ'))
                                            Vendor_site,
                                         NULL payment_terms,
                                         NULL retainage_rate,
                                         pspe.c_ext_attr10 action,
                                         pspe.c_ext_attr11 Unit_manager,
                                         pspe.c_ext_attr12 business_controller,
                                         pspe.d_ext_attr1 approval_date,
                                         pspe.party_id,
                                         pspe.c_ext_attr3 bank_name,
                                         pspe.c_ext_attr4 bank_branch_name,
                                         pspe.c_ext_attr5 bank_account_number,
                                         pspe.c_ext_attr6 bank_account_name,
                                         pspe.c_ext_attr7 IBAN,
                                         pspe.c_ext_attr8 currency_code,
                                         pspe.c_ext_attr9 check_digits
                                    FROM ego_attr_groups_v eagv,
                                         pos_supp_prof_ext_b pspe
                                   WHERE     1 = 1
                                         AND pspe.attr_group_id = eagv.attr_group_id
                                         AND eagv.attr_group_name =
                                                'XXAH_SUPPLIER_BANK_AUDIT_MR'
                                         AND pspe.c_ext_attr10 NOT IN ('BANK_AND_TERMS_UPDATE',
                                                                       'CREATE')
                                GROUP BY pspe.c_ext_attr2,
                                         pspe.c_ext_attr2,
                                         pspe.c_ext_attr10,
                                         pspe.c_ext_attr11,
                                         pspe.c_ext_attr12,
                                         pspe.d_ext_attr1,
                                         pspe.party_id,
                                         pspe.c_ext_attr3,
                                         pspe.c_ext_attr4,
                                         pspe.c_ext_attr5,
                                         pspe.c_ext_attr6,
                                         pspe.c_ext_attr7,
                                         pspe.c_ext_attr8,
                                         pspe.c_ext_attr9
                                UNION
                                SELECT DISTINCT
                                       pspe.c_ext_attr2 vendor_name,
                                       pspe.c_ext_attr1 Vendor_site,
                                       NULL payment_terms,
                                       NULL retainage_rate,
                                       pspe.c_ext_attr10 action,
                                       pspe.c_ext_attr11 Unit_manager,
                                       pspe.c_ext_attr12 business_controller,
                                       pspe.d_ext_attr1 approval_date,
                                       pspe.party_id,
                                       pspe.c_ext_attr3 bank_name,
                                       pspe.c_ext_attr4 bank_branch_name,
                                       pspe.c_ext_attr5 bank_account_number,
                                       pspe.c_ext_attr6 bank_account_name,
                                       pspe.c_ext_attr7 IBAN,
                                       pspe.c_ext_attr8 currency_code,
                                       pspe.c_ext_attr9 check_digits
                                  FROM ego_attr_groups_v eagv,
                                       pos_supp_prof_ext_b pspe
                                 WHERE     1 = 1
                                       AND pspe.attr_group_id = eagv.attr_group_id
                                       AND eagv.attr_group_name =
                                              'XXAH_SUPPLIER_BANK_AUDIT_MR'
                                       AND pspe.c_ext_attr10 NOT IN ('BANK_AND_TERMS_UPDATE',
                                                                     'CREATE')
                                       AND pspe.c_ext_attr1 IS NOT NULL)
                        UNION
                        SELECT vendor_name,
                               DECODE (Vendor_site, 'ZZZZZZ', NULL, Vendor_site)
                                  vendor_site,
                               payment_terms,
                               retainage_rate,
                               action,
                               Unit_manager,
                               business_controller,
                               approval_date,
                               party_id,
                               bank_name,
                               bank_branch_name,
                               bank_account_number,
                               bank_account_name,
                               IBAN,
                               currency_code,
                               check_digits
                          FROM (  SELECT DISTINCT
                                         pspe.c_ext_attr2 vendor_name,
                                         MIN (NVL (pspe.c_ext_attr3, 'ZZZZZZ'))
                                            vendor_site,
                                         pspe.c_ext_attr4 payment_terms,
                                         pspe.c_ext_attr6 retainage_rate,
                                         pspe.c_ext_attr8 action,
                                         pspe.c_ext_attr9 Unit_manager,
                                         pspe.c_ext_attr10 business_controller,
                                         pspe.d_ext_attr1 approval_date,
                                         pspe.party_id,
                                         NULL bank_name,
                                         NULL bank_branch_name,
                                         NULL bank_account_number,
                                         NULL bank_account_name,
                                         NULL IBAN,
                                         NULL currency_code,
                                         NULL check_digits
                                    --,pspe.*,pspe.*
                                    FROM ego_attr_groups_v eagv,
                                         pos_supp_prof_ext_b pspe
                                   WHERE     1 = 1
                                         AND pspe.attr_group_id = eagv.attr_group_id
                                         AND eagv.attr_group_name =
                                                'XXAH_SUPPLIER_TERMS_AUDIT_MR'
                                         AND pspe.c_ext_attr8 NOT IN ('BANK_AND_TERMS_UPDATE',
                                                                      'CREATE')
                                GROUP BY pspe.c_ext_attr2,
                                         pspe.c_ext_attr4,
                                         pspe.c_ext_attr6,
                                         pspe.c_ext_attr8,
                                         pspe.c_ext_attr9,
                                         pspe.c_ext_attr10,
                                         pspe.d_ext_attr1,
                                         pspe.party_id
                                UNION
                                SELECT DISTINCT
                                       pspe.c_ext_attr2 vendor_name,
                                       pspe.c_ext_attr3 vendor_site,
                                       pspe.c_ext_attr4 payment_terms,
                                       pspe.c_ext_attr6 retainage_rate,
                                       pspe.c_ext_attr8 action,
                                       pspe.c_ext_attr9 Unit_manager,
                                       pspe.c_ext_attr10 business_controller,
                                       pspe.d_ext_attr1 approval_date,
                                       pspe.party_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL
                                  --,pspe.*,pspe.*
                                  FROM ego_attr_groups_v eagv,
                                       pos_supp_prof_ext_b pspe
                                 WHERE     1 = 1
                                       AND pspe.attr_group_id = eagv.attr_group_id
                                       AND eagv.attr_group_name =
                                              'XXAH_SUPPLIER_TERMS_AUDIT_MR'
                                       AND pspe.c_ext_attr8 NOT IN ('BANK_AND_TERMS_UPDATE',
                                                                    'CREATE')
                                       AND pspe.c_ext_attr3 IS NOT NULL))
                UNION
                (SELECT DISTINCT
                        NVL (pspe.vendor_name, pspe1.vendor_name) vendor_name,
                        NVL (pspe.vendor_site_code, pspe1.vendor_site_code)
                           vendor_site_code,
                        pspe1.payment_terms,
                        pspe1.retainage_rate,
                        NVL (pspe.action, pspe1.action) action,
                        NVL (pspe.unit_manager, pspe1.unit_manager) unit_manager,
                        NVL (pspe.business_controller, pspe1.business_controller)
                           business_controller,
                        TRUNC (NVL (pspe.approval_date, pspe1.approval_date))
                           approval_date,
                        NVL (pspe.party_id, pspe1.party_id) party_id,
                        pspe.bank_name,
                        pspe.bank_branch_name,
                        pspe.bank_account_number,
                        pspe.bank_account_name,
                        pspe.IBAN,
                        pspe.currency_code,
                        pspe.check_digits
                   FROM (SELECT payment_terms,
                                retainage_rate,
                                DECODE (vendor_site_code,
                                        'ZZZZZZZ', NULL,
                                        vendor_site_code)
                                   vendor_site_code,
                                vendor_name,
                                action,
                                party_id,
                                approval_date,
                                unit_manager,
                                business_controller
                           FROM (  SELECT pspe1.c_ext_attr4 payment_terms,
                                          pspe1.c_ext_attr6 retainage_rate,
                                          MIN (NVL (pspe1.c_ext_attr3, 'ZZZZZZZ'))
                                             vendor_site_code,
                                          pspe1.c_ext_attr2 vendor_name,
                                          pspe1.c_ext_attr8 action,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1 approval_date,
                                          pspe1.c_ext_attr9 unit_manager,
                                          pspe1.c_ext_attr10 business_controller
                                     FROM ego_attr_groups_v eagv,
                                          pos_supp_prof_ext_b pspe1
                                    WHERE     1 = 1
                                          AND eagv.attr_group_name =
                                                 'XXAH_SUPPLIER_TERMS_AUDIT_MR'
                                          AND pspe1.attr_group_id = eagv.attr_group_id
                                          AND pspe1.c_ext_attr8 IN ('BANK_AND_TERMS_UPDATE',
                                                                    'CREATE')
                                 --and party_id = 2101562
                                 GROUP BY pspe1.c_ext_attr4,
                                          pspe1.c_ext_attr6,
                                          pspe1.c_ext_attr2,
                                          pspe1.c_ext_attr8,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1,
                                          pspe1.c_ext_attr9,
                                          pspe1.c_ext_attr10
                                 UNION
                                 SELECT pspe1.c_ext_attr4 payment_terms,
                                        pspe1.c_ext_attr6 retainage_rate,
                                        pspe1.c_ext_attr3 vendor_site_code,
                                        pspe1.c_ext_attr2 vendor_name,
                                        pspe1.c_ext_attr8 action,
                                        pspe1.party_id,
                                        pspe1.d_ext_attr1 approval_date,
                                        pspe1.c_ext_attr9 unit_manager,
                                        pspe1.c_ext_attr10 business_controller
                                   FROM ego_attr_groups_v eagv,
                                        pos_supp_prof_ext_b pspe1
                                  WHERE     1 = 1
                                        AND eagv.attr_group_name =
                                               'XXAH_SUPPLIER_TERMS_AUDIT_MR'
                                        AND pspe1.attr_group_id = eagv.attr_group_id
                                        AND pspe1.c_ext_attr8 IN ('BANK_AND_TERMS_UPDATE',
                                                                  'CREATE')
                                        --and party_id = 2101562
                                        AND pspe1.c_ext_attr3 IS NOT NULL)) pspe1,
                        (SELECT bank_name,
                                bank_branch_name,
                                bank_account_number,
                                bank_account_name,
                                IBAN,
                                currency_code,
                                check_digits,
                                DECODE (vendor_site_code,
                                        'ZZZZZZZ', NULL,
                                        vendor_site_code)
                                   vendor_site_code,
                                vendor_name,
                                action,
                                party_id,
                                approval_date,
                                unit_manager,
                                Business_controller
                           FROM (  SELECT pspe1.c_ext_attr3 bank_name,
                                          pspe1.c_ext_attr4 bank_branch_name,
                                          pspe1.c_ext_attr5 bank_account_number,
                                          pspe1.c_ext_attr6 bank_account_name,
                                          pspe1.c_ext_attr7 IBAN,
                                          pspe1.c_ext_attr8 currency_code,
                                          pspe1.c_ext_attr9 check_digits,
                                          MIN (NVL (pspe1.c_ext_attr1, 'ZZZZZZZ'))
                                             vendor_site_code,
                                          pspe1.c_ext_attr2 vendor_name,
                                          pspe1.c_ext_attr10 action,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1 approval_date,
                                          pspe1.c_ext_attr11 unit_manager,
                                          pspe1.c_ext_attr12 business_controller
                                     FROM ego_attr_groups_v eagv,
                                          pos_supp_prof_ext_b pspe1
                                    WHERE     1 = 1
                                          AND eagv.attr_group_name =
                                                 'XXAH_SUPPLIER_BANK_AUDIT_MR'
                                          AND pspe1.attr_group_id = eagv.attr_group_id
                                          AND pspe1.c_ext_attr10 IN ('BANK_AND_TERMS_UPDATE',
                                                                     'CREATE')
                                 --and party_id = 2101562
                                 GROUP BY pspe1.c_ext_attr3,
                                          pspe1.c_ext_attr4,
                                          pspe1.c_ext_attr5,
                                          pspe1.c_ext_attr6,
                                          pspe1.c_ext_attr7,
                                          pspe1.c_ext_attr8,
                                          pspe1.c_ext_attr9,
                                          pspe1.c_ext_attr2,
                                          pspe1.c_ext_attr10,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1,
                                          pspe1.c_ext_attr11,
                                          pspe1.c_ext_attr12
                                 UNION
                                 SELECT pspe1.c_ext_attr3 bank_name,
                                        pspe1.c_ext_attr4 bank_branch_name,
                                        pspe1.c_ext_attr5 bank_account_number,
                                        pspe1.c_ext_attr6 bank_account_name,
                                        pspe1.c_ext_attr7 IBAN,
                                        pspe1.c_ext_attr8 currency_code,
                                        pspe1.c_ext_attr9 check_digits,
                                        pspe1.c_ext_attr1 vendor_site_code,
                                        pspe1.c_ext_attr2 vendor_name,
                                        pspe1.c_ext_attr10 action,
                                        pspe1.party_id,
                                        pspe1.d_ext_attr1 approval_date,
                                        pspe1.c_ext_attr11 unit_manager,
                                        pspe1.c_ext_attr12 business_controller
                                   FROM ego_attr_groups_v eagv,
                                        pos_supp_prof_ext_b pspe1
                                  WHERE     1 = 1
                                        AND eagv.attr_group_name =
                                               'XXAH_SUPPLIER_BANK_AUDIT_MR'
                                        AND pspe1.attr_group_id = eagv.attr_group_id
                                        AND pspe1.c_ext_attr10 IN ('BANK_AND_TERMS_UPDATE',
                                                                   'CREATE')
                                        --and party_id = 2101562
                                        AND pspe1.c_ext_attr1 IS NOT NULL)) pspe
                  WHERE     1 = 1
                        AND pspe.party_id(+) = pspe1.party_id
                        AND pspe.action(+) = pspe1.action
                        AND NVL (pspe.vendor_site_code(+), 'ZZZZZZZ') =
                               NVL (pspe1.vendor_site_code, 'ZZZZZZZ')
                        AND TRUNC (pspe.approval_date(+)) =
                               TRUNC (pspe1.approval_date)
                        AND pspe1.action IN ('BANK_AND_TERMS_UPDATE', 'CREATE')
                 UNION
                 SELECT DISTINCT
                        NVL (pspe.vendor_name, pspe1.vendor_name) vendor_name,
                        NVL (pspe.vendor_site_code, pspe1.vendor_site_code)
                           vendor_site_code,
                        pspe1.payment_terms,
                        pspe1.retainage_rate,
                        NVL (pspe.action, pspe1.action) action,
                        NVL (pspe.unit_manager, pspe1.unit_manager) unit_manager,
                        NVL (pspe.business_controller, pspe1.business_controller)
                           business_controller,
                        TRUNC (NVL (pspe.approval_date, pspe1.approval_date))
                           approval_date,
                        NVL (pspe.party_id, pspe1.party_id) party_id,
                        pspe.bank_name,
                        pspe.bank_branch_name,
                        pspe.bank_account_number,
                        pspe.bank_account_name,
                        pspe.IBAN,
                        pspe.currency_code,
                        pspe.check_digits
                   FROM (SELECT payment_terms,
                                retainage_rate,
                                DECODE (vendor_site_code,
                                        'ZZZZZZZ', NULL,
                                        vendor_site_code)
                                   vendor_site_code,
                                vendor_name,
                                action,
                                party_id,
                                approval_date,
                                unit_manager,
                                business_controller
                           FROM (  SELECT pspe1.c_ext_attr4 payment_terms,
                                          pspe1.c_ext_attr6 retainage_rate,
                                          MIN (NVL (pspe1.c_ext_attr3, 'ZZZZZZZ'))
                                             vendor_site_code,
                                          pspe1.c_ext_attr2 vendor_name,
                                          pspe1.c_ext_attr8 action,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1 approval_date,
                                          pspe1.c_ext_attr9 unit_manager,
                                          pspe1.c_ext_attr10 business_controller
                                     FROM ego_attr_groups_v eagv,
                                          pos_supp_prof_ext_b pspe1
                                    WHERE     1 = 1
                                          AND eagv.attr_group_name =
                                                 'XXAH_SUPPLIER_TERMS_AUDIT_MR'
                                          AND pspe1.attr_group_id = eagv.attr_group_id
                                          AND pspe1.c_ext_attr8 IN ('BANK_AND_TERMS_UPDATE',
                                                                    'CREATE')
                                 --and party_id = 2101562
                                 GROUP BY pspe1.c_ext_attr4,
                                          pspe1.c_ext_attr6,
                                          pspe1.c_ext_attr2,
                                          pspe1.c_ext_attr8,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1,
                                          pspe1.c_ext_attr9,
                                          pspe1.c_ext_attr10
                                 UNION
                                 SELECT pspe1.c_ext_attr4 payment_terms,
                                        pspe1.c_ext_attr6 retainage_rate,
                                        pspe1.c_ext_attr3 vendor_site_code,
                                        pspe1.c_ext_attr2 vendor_name,
                                        pspe1.c_ext_attr8 action,
                                        pspe1.party_id,
                                        pspe1.d_ext_attr1 approval_date,
                                        pspe1.c_ext_attr9 unit_manager,
                                        pspe1.c_ext_attr10 business_controller
                                   FROM ego_attr_groups_v eagv,
                                        pos_supp_prof_ext_b pspe1
                                  WHERE     1 = 1
                                        AND eagv.attr_group_name =
                                               'XXAH_SUPPLIER_TERMS_AUDIT_MR'
                                        AND pspe1.attr_group_id = eagv.attr_group_id
                                        AND pspe1.c_ext_attr8 IN ('BANK_AND_TERMS_UPDATE',
                                                                  'CREATE')
                                        --and party_id = 2101562
                                        AND pspe1.c_ext_attr3 IS NOT NULL)) pspe1,
                        (SELECT bank_name,
                                bank_branch_name,
                                bank_account_number,
                                bank_account_name,
                                IBAN,
                                currency_code,
                                check_digits,
                                DECODE (vendor_site_code,
                                        'ZZZZZZZ', NULL,
                                        vendor_site_code)
                                   vendor_site_code,
                                vendor_name,
                                action,
                                party_id,
                                approval_date,
                                unit_manager,
                                Business_controller
                           FROM (  SELECT pspe1.c_ext_attr3 bank_name,
                                          pspe1.c_ext_attr4 bank_branch_name,
                                          pspe1.c_ext_attr5 bank_account_number,
                                          pspe1.c_ext_attr6 bank_account_name,
                                          pspe1.c_ext_attr7 IBAN,
                                          pspe1.c_ext_attr8 currency_code,
                                          pspe1.c_ext_attr9 check_digits,
                                          MIN (NVL (pspe1.c_ext_attr1, 'ZZZZZZZ'))
                                             vendor_site_code,
                                          pspe1.c_ext_attr2 vendor_name,
                                          pspe1.c_ext_attr10 action,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1 approval_date,
                                          pspe1.c_ext_attr11 unit_manager,
                                          pspe1.c_ext_attr12 business_controller
                                     FROM ego_attr_groups_v eagv,
                                          pos_supp_prof_ext_b pspe1
                                    WHERE     1 = 1
                                          AND eagv.attr_group_name =
                                                 'XXAH_SUPPLIER_BANK_AUDIT_MR'
                                          AND pspe1.attr_group_id = eagv.attr_group_id
                                          AND pspe1.c_ext_attr10 IN ('BANK_AND_TERMS_UPDATE',
                                                                     'CREATE')
                                 --and party_id = 2101562
                                 GROUP BY pspe1.c_ext_attr3,
                                          pspe1.c_ext_attr4,
                                          pspe1.c_ext_attr5,
                                          pspe1.c_ext_attr6,
                                          pspe1.c_ext_attr7,
                                          pspe1.c_ext_attr8,
                                          pspe1.c_ext_attr9,
                                          pspe1.c_ext_attr2,
                                          pspe1.c_ext_attr10,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1,
                                          pspe1.c_ext_attr11,
                                          pspe1.c_ext_attr12
                                 UNION
                                 SELECT pspe1.c_ext_attr3 bank_name,
                                        pspe1.c_ext_attr4 bank_branch_name,
                                        pspe1.c_ext_attr5 bank_account_number,
                                        pspe1.c_ext_attr6 bank_account_name,
                                        pspe1.c_ext_attr7 IBAN,
                                        pspe1.c_ext_attr8 currency_code,
                                        pspe1.c_ext_attr9 check_digits,
                                        pspe1.c_ext_attr1 vendor_site_code,
                                        pspe1.c_ext_attr2 vendor_name,
                                        pspe1.c_ext_attr10 action,
                                        pspe1.party_id,
                                        pspe1.d_ext_attr1 approval_date,
                                        pspe1.c_ext_attr11 unit_manager,
                                        pspe1.c_ext_attr12 business_controller
                                   FROM ego_attr_groups_v eagv,
                                        pos_supp_prof_ext_b pspe1
                                  WHERE     1 = 1
                                        AND eagv.attr_group_name =
                                               'XXAH_SUPPLIER_BANK_AUDIT_MR'
                                        AND pspe1.attr_group_id = eagv.attr_group_id
                                        AND pspe1.c_ext_attr10 IN ('BANK_AND_TERMS_UPDATE',
                                                                   'CREATE')
                                        --and party_id = 2101562
                                        AND pspe1.c_ext_attr1 IS NOT NULL)) pspe
                  WHERE     1 = 1
                        AND pspe.party_id = pspe1.party_id(+)
                        AND pspe.action = pspe1.action(+)
                        AND NVL (pspe.vendor_site_code, 'ZZZZZZZ') =
                               NVL (pspe1.vendor_site_code(+), 'ZZZZZZZ')
                        AND TRUNC (pspe.approval_date) =
                               TRUNC (pspe1.approval_date(+))
                        AND pspe.action IN ('BANK_AND_TERMS_UPDATE', 'CREATE'))) a,
               ap_supplier_sites_all apsa,
               hr_all_organization_units hou,
               ap_suppliers aps
         WHERE     1 = 1
               AND apsa.vendor_site_code(+) = a.vendor_site
               AND apsa.org_id = hou.organization_id(+)
               AND aps.party_id = a.party_id
               AND apsa.vendor_id(+) = aps.vendor_id
               AND a.vendor_name = NVL(p_vendor_name,a.vendor_name)
               AND TRUNC(a.approval_date) BETWEEN TRUNC(NVl(TO_DATE(p_approval_from,'RRRR/MM/DD HH24:MI:SS'),a.approval_date)) and TRUNC(NVl(TO_DATE(p_approval_to,'RRRR/MM/DD HH24:MI:SS'),a.approval_date))
      ORDER BY approval_date, a.vendor_name;
     CURSOR email_address_cur(p_user_id IN fnd_user.user_id%TYPE)
     IS
        SELECT  NVL(papf.email_address,fu.email_address)
          FROM  fnd_user fu
               ,per_all_people_f papf
         WHERE  1=1
           AND  fu.person_party_id = papf.party_id
           AND  TRUNC(SYSDATE) BETWEEN TRUNC(NVL(papf.EFFECTIVE_START_DATE,SYSDATE)) AND TRUNC(NVL(papf.EFFECTIVE_END_DATE,SYSDATE))
           AND  fu.user_id = p_user_id;
  BEGIN
     ld_date := SYSDATE;
     lv_domain := lv_smtp_server;
     fnd_file.put_line(fnd_file.log,'Parameters Passed');
     fnd_file.put_line(fnd_file.log,'------------------');
     fnd_file.put_line(fnd_file.log,'p_vendor_name - '||p_vendor_name);
     fnd_file.put_line(fnd_file.log,'p_approval_from - '||p_approval_from);
     fnd_file.put_line(fnd_file.log,'p_approval_to - '||p_approval_to);
     fnd_file.put_line(fnd_file.log,'------------------');
     fnd_file.put_line(fnd_file.log,'Begin Execution of supp_appr_audit_history_report');
     ln_user_id := fnd_profile.value('USER_ID');
     SELECT  instance_name
       INTO  lv_instance
       FROM  v$instance
      WHERE  rownum =1;
     lv_from := lv_instance||lv_from;
     OPEN email_address_cur(ln_user_id);
     FETCH email_address_cur INTO p_to;
     CLOSE email_address_cur;
     BEGIN
        v_clob := 'Vendor Name' || ',' || 'Vendor Number' ||','|| 'Vendor Site' ||','||'Operating Unit' || ',' || 'Action' ||','||'Payment Terms'||','
                  ||'Retainage Rate'||','||'Bank Name'||','||'Bank Branch Name'||','||'Bank Account Number'||','
                  ||'Bank Account Name'||','||'IBAN'||','||'Currency Code'||','||'Check Digits'||','
                  ||'Unit Manager' || ',' || 'Business Controller' ||','||'Approval Date' 
                  || UTL_TCP.crlf;
        v_connection := UTL_SMTP.open_connection (lv_smtp_server,25); --To open the connection      UTL_SMTP.helo (v_connection, lv_domain);
        utl_smtp.helo(v_connection, lv_smtp_server);
        UTL_SMTP.mail (v_connection, lv_from);
        UTL_SMTP.rcpt (v_connection, p_to); -- To send mail to valid receipent     
        UTL_SMTP.open_data (v_connection);
        UTL_SMTP.write_data (v_connection, 'From: ' || lv_from || UTL_TCP.crlf);
        IF TRIM (p_to) IS NOT NULL
        THEN
           UTL_SMTP.write_data (v_connection, 'To: ' || p_to || UTL_TCP.crlf);
        END IF;
        UTL_SMTP.write_data (v_connection,
                             'Subject: Suppliers Approval Audit History Report' || UTL_TCP.crlf
                            );
        UTL_SMTP.write_data (v_connection, 'MIME-Version: 1.0' || UTL_TCP.crlf);
        UTL_SMTP.write_data (v_connection,
                                'Content-Type: multipart/mixed; boundary="'
                             || c_mime_boundary
                             || '"'
                             || UTL_TCP.crlf
                            );
        UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);
        UTL_SMTP.write_data (v_connection,
                                'This is a multi-part message in MIME format.'
                             || UTL_TCP.crlf
                            );
        UTL_SMTP.write_data (v_connection,
                             '--' || c_mime_boundary || UTL_TCP.crlf
                            );
        UTL_SMTP.write_data (v_connection,
                             'Content-Type: text/plain' || UTL_TCP.crlf
                            );
        ln_cnt := 1;
        --Condition to check for the creation of csv attachment
        IF (ln_cnt <> 0)
        THEN
           UTL_SMTP.write_data
                              (v_connection,
                                  'Content-Disposition: attachment; filename="'
                               || 'Supplier_details'
                               || TO_CHAR (ld_date, 'dd-mon-rrrr hh:mi')
                               || '.csv'
                               || '"'
                               || UTL_TCP.crlf
                              );
        END IF;
        UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);
        FOR i IN c_data
        LOOP
           ln_counter := ln_counter + 1;
           IF ln_counter = 1
           THEN
           UTL_SMTP.write_data (v_connection, v_clob);--To avoid repeation of column heading in csv file
           END IF;
           BEGIN
              v_clob := '="' || i.vendor_name || '",' 
                        || i.segment1 || ',"'
                        || i.vendor_site  || '",' 
                        || i.name || ',' 
                        || i.action ||','
                        || i.payment_terms ||','
                        || i.retainage_rate ||','
                        || i.bank_name ||','
                        || i.bank_branch_name ||','
                        || i.bank_account_number ||','
                        || i.bank_account_name ||','
                        || i.IBAN ||','
                        || i.currency_code ||','
                        || i.check_digits ||',"' 
                        || i.unit_manager || '","' 
                        || i.business_controller || '",' 
                        || i.approval_date 
                        || UTL_TCP.crlf;
           EXCEPTION
              WHEN OTHERS
              THEN
                 fnd_file.put_line(fnd_file.log,'Exception while generating CSV - '||SQLERRM);
           END;
           UTL_SMTP.write_data (v_connection, v_clob); --Writing data in csv attachment.     
        END LOOP;
        UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);
        UTL_SMTP.close_data (v_connection);
        UTL_SMTP.quit (v_connection);
        COMMIT;
     EXCEPTION
        WHEN OTHERS
        THEN
           fnd_file.put_line(fnd_file.log,'Exception inside mail processing - '||SQLERRM);
     END;
     fnd_file.put_line(fnd_file.log,'End Execution of supp_appr_audit_history_report');
  EXCEPTION
    WHEN OTHERS
    THEN
      fnd_file.put_line(fnd_file.log,'Exceptiion in supp_appr_audit_history_report - '||SQLERRM);
  END supp_appr_audit_history_report;
  */
   PROCEDURE supp_appr_audit_history_report(errbuf OUT VARCHAR2
                                           ,retcode OUT VARCHAR2
                                           ,p_vendor_name IN ap_suppliers.vendor_name%TYPE
                                           ,p_approval_from IN VARCHAR2
                                           ,p_approval_to IN VARCHAR2
                                           )
  IS
     i                          NUMBER              := 1;
     j                          NUMBER              := 1;
     p_to                       VARCHAR2 (1000);
     lv_smtp_server             VARCHAR2 (100)      := 'vmebsdblpwe01.retail.ah.eu-int-aholddelhaize.com';
     lv_domain                  VARCHAR2 (1000);
     lv_from                    VARCHAR2 (100)      := '@ah.nl';
     v_connection               UTL_SMTP.connection;
     c_mime_boundary   CONSTANT VARCHAR2 (256)      := '--AAAAA000956--';
     v_clob                     CLOB;
     ln_len                     INTEGER;
     ln_index                   INTEGER;
     ln_count                   NUMBER;
     ln_code                    VARCHAR2 (10);
     ln_counter                 NUMBER              := 0;
     lv_instance                VARCHAR2 (500);
     ln_cnt                     NUMBER;
     ld_date                    DATE;
     ln_user_id                 fnd_user.user_id%TYPE;
     -----------
     V_SERVER  varchar2(1000);
      V_EMAIL varchar2(1000);
      V_TOEMAIL varchar2(1000);
      V_INSTANCE varchar2(2000);
      v_top varchar2(1000);
      v_filename         VARCHAR2 (200);
      v_date             VARCHAR2 (50);
      v_req_id     NUMBER;
      g_request_id                    NUMBER       := fnd_global.conc_request_id;
     CURSOR c_data 
     IS
        SELECT DISTINCT hou.name,aps.segment1,
                       a.vendor_name,
                       a.vendor_site,
                       a.payment_terms,
                       a.retainage_rate,
                       a.action,
                       a.Unit_manager,
                       a.business_controller,
                       substr(replace(replace(replace( replace(REPLACE(a.Unit_manager_comments,'&',';'),CHR(10),''),CHR(13),''),CHR(09),''),'>',';'),1,200)  Unit_manager_comments,
                       substr(replace(replace(replace( replace(REPLACE(a.business_controller_comments,'&',';'),CHR(10),''),CHR(13),''),CHR(09),''),'>',';'),1,200) business_controller_comments,
                       --a.business_controller_comments,
                       a.approval_date,
                       a.party_id,
                       a.bank_name,
                       a.bank_branch_name,
                       a.bank_account_number,
                       a.bank_account_name,
                       a.IBAN,
                       a.currency_code,
                       a.check_digits,
                       a.org_id
          FROM (SELECT vendor_name,
                       vendor_site,
                       payment_terms,
                       retainage_rate,
                       action,
                       Unit_manager,
                       business_controller,
                       Unit_manager_comments,
                       business_controller_comments,
                       TRUNC (approval_date) approval_date,
                       party_id,
                       bank_name,
                       bank_branch_name,
                       bank_account_number,
                       bank_account_name,
                       IBAN,
                       currency_code,
                       check_digits,
                       org_id
                  FROM (SELECT vendor_name,
                               DECODE (Vendor_site, 'ZZZZZZ', NULL, Vendor_site)
                                  vendor_site,
                               payment_terms,
                               retainage_rate,
                               action,
                               Unit_manager,
                               business_controller,
                               Unit_manager_comments,
                               business_controller_comments,
                               approval_date,
                               party_id,
                               bank_name,
                               bank_branch_name,
                               bank_account_number,
                               bank_account_name,
                               IBAN,
                               currency_code,
                               check_digits,
                               org_id
                          FROM (  SELECT DISTINCT
                                         pspe.c_ext_attr2 vendor_name,
                                         MIN (NVL (pspe.c_ext_attr1, 'ZZZZZZ'))
                                            Vendor_site,
                                         NULL payment_terms,
                                         NULL retainage_rate,
                                         pspe.c_ext_attr10 action,
                                         pspe.c_ext_attr11 Unit_manager,
                                         pspe.c_ext_attr12 business_controller,
                                         pspe.c_ext_attr13 Unit_manager_comments,
                                         pspe.c_ext_attr14 business_controller_comments,
                                         pspe.d_ext_attr1 approval_date,
                                         pspe.party_id,
                                         pspe.c_ext_attr3 bank_name,
                                         pspe.c_ext_attr4 bank_branch_name,
                                         pspe.c_ext_attr5 bank_account_number,
                                         pspe.c_ext_attr6 bank_account_name,
                                         pspe.c_ext_attr7 IBAN,
                                         pspe.c_ext_attr8 currency_code,
                                         pspe.c_ext_attr9 check_digits,
                                         pspe.n_ext_attr2 org_id
                                    FROM ego_attr_groups_v eagv,
                                         pos_supp_prof_ext_b pspe
                                   WHERE     1 = 1
                                         AND pspe.attr_group_id = eagv.attr_group_id
                                         AND eagv.attr_group_name =
                                                'XXAH_SUPPLIER_BANK_AUDIT_MR'
                                         AND pspe.c_ext_attr10 NOT IN ('BANK_AND_TERMS_UPDATE',
                                                                       'CREATE')
                                GROUP BY pspe.c_ext_attr2,
                                         pspe.c_ext_attr2,
                                         pspe.c_ext_attr10,
                                         pspe.c_ext_attr11,
                                         pspe.c_ext_attr12,
                                         pspe.c_ext_attr13,
                                         pspe.c_ext_attr14,
                                         pspe.d_ext_attr1,
                                         pspe.party_id,
                                         pspe.c_ext_attr3,
                                         pspe.c_ext_attr4,
                                         pspe.c_ext_attr5,
                                         pspe.c_ext_attr6,
                                         pspe.c_ext_attr7,
                                         pspe.c_ext_attr8,
                                         pspe.c_ext_attr9,
                                         pspe.n_ext_attr2
                                UNION
                                SELECT DISTINCT
                                       pspe.c_ext_attr2 vendor_name,
                                       pspe.c_ext_attr1 Vendor_site,
                                       NULL payment_terms,
                                       NULL retainage_rate,
                                       pspe.c_ext_attr10 action,
                                       pspe.c_ext_attr11 Unit_manager,
                                       pspe.c_ext_attr12 business_controller,
                                       pspe.c_ext_attr13 Unit_manager_comments,
                                       pspe.c_ext_attr14 business_controller_comments,
                                       pspe.d_ext_attr1 approval_date,
                                       pspe.party_id,
                                       pspe.c_ext_attr3 bank_name,
                                       pspe.c_ext_attr4 bank_branch_name,
                                       pspe.c_ext_attr5 bank_account_number,
                                       pspe.c_ext_attr6 bank_account_name,
                                       pspe.c_ext_attr7 IBAN,
                                       pspe.c_ext_attr8 currency_code,
                                       pspe.c_ext_attr9 check_digits,
                                       pspe.n_ext_attr2 org_id
                                  FROM ego_attr_groups_v eagv,
                                       pos_supp_prof_ext_b pspe
                                 WHERE     1 = 1
                                       AND pspe.attr_group_id = eagv.attr_group_id
                                       AND eagv.attr_group_name =
                                              'XXAH_SUPPLIER_BANK_AUDIT_MR'
                                       AND pspe.c_ext_attr10 NOT IN ('BANK_AND_TERMS_UPDATE',
                                                                     'CREATE')
                                       AND pspe.c_ext_attr1 IS NOT NULL)
                        UNION
                        SELECT vendor_name,
                               DECODE (Vendor_site, 'ZZZZZZ', NULL, Vendor_site)
                                  vendor_site,
                               payment_terms,
                               retainage_rate,
                               action,
                               Unit_manager,
                               business_controller,
                               Unit_manager_comments,
                               business_controller_comments,
                               approval_date,
                               party_id,
                               bank_name,
                               bank_branch_name,
                               bank_account_number,
                               bank_account_name,
                               IBAN,
                               currency_code,
                               check_digits,
                               org_id
                          FROM (  SELECT DISTINCT
                                         pspe.c_ext_attr2 vendor_name,
                                         MIN (NVL (pspe.c_ext_attr3, 'ZZZZZZ'))
                                            vendor_site,
                                         pspe.c_ext_attr4 payment_terms,
                                         pspe.c_ext_attr6 retainage_rate,
                                         pspe.c_ext_attr8 action,
                                         pspe.c_ext_attr9 Unit_manager,
                                         pspe.c_ext_attr10 business_controller,
                                         pspe.c_ext_attr11 Unit_manager_comments,
                                         pspe.c_ext_attr12 business_controller_comments,
                                         pspe.d_ext_attr1 approval_date,
                                         pspe.party_id,
                                         NULL bank_name,
                                         NULL bank_branch_name,
                                         NULL bank_account_number,
                                         NULL bank_account_name,
                                         NULL IBAN,
                                         NULL currency_code,
                                         NULL check_digits,
                                         to_number(pspe.c_ext_attr7) org_id
                                    --,pspe.*,pspe.*
                                    FROM ego_attr_groups_v eagv,
                                         pos_supp_prof_ext_b pspe
                                   WHERE     1 = 1
                                         AND pspe.attr_group_id = eagv.attr_group_id
                                         AND eagv.attr_group_name =
                                                'XXAH_SUPPLIER_TERMS_AUDIT_MR'
                                         AND pspe.c_ext_attr8 NOT IN ('BANK_AND_TERMS_UPDATE',
                                                                      'CREATE')
                                GROUP BY pspe.c_ext_attr2,
                                         pspe.c_ext_attr4,
                                         pspe.c_ext_attr6,
                                         pspe.c_ext_attr8,
                                         pspe.c_ext_attr9,
                                         pspe.c_ext_attr10,
                                         pspe.c_ext_attr11,
                                         pspe.c_ext_attr12,
                                         pspe.d_ext_attr1,
                                         pspe.party_id,
                                         to_number(pspe.c_ext_attr7)
                                UNION
                                SELECT DISTINCT
                                       pspe.c_ext_attr2 vendor_name,
                                       pspe.c_ext_attr3 vendor_site,
                                       pspe.c_ext_attr4 payment_terms,
                                       pspe.c_ext_attr6 retainage_rate,
                                       pspe.c_ext_attr8 action,
                                       pspe.c_ext_attr9 Unit_manager,
                                       pspe.c_ext_attr10 business_controller,
                                       pspe.c_ext_attr11 Unit_manager_comments,
                                       pspe.c_ext_attr12 business_controller_comments,
                                       pspe.d_ext_attr1 approval_date,
                                       pspe.party_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       to_number(pspe.c_ext_attr7) org_id
                                  --,pspe.*,pspe.*
                                  FROM ego_attr_groups_v eagv,
                                       pos_supp_prof_ext_b pspe
                                 WHERE     1 = 1
                                       AND pspe.attr_group_id = eagv.attr_group_id
                                       AND eagv.attr_group_name =
                                              'XXAH_SUPPLIER_TERMS_AUDIT_MR'
                                       AND pspe.c_ext_attr8 NOT IN ('BANK_AND_TERMS_UPDATE',
                                                                    'CREATE')
                                       AND pspe.c_ext_attr3 IS NOT NULL))
                UNION
                (SELECT DISTINCT
                        NVL (pspe.vendor_name, pspe1.vendor_name) vendor_name,
                        NVL (pspe.vendor_site_code, pspe1.vendor_site_code)
                           vendor_site_code,
                        pspe1.payment_terms,
                        pspe1.retainage_rate,
                        NVL (pspe.action, pspe1.action) action,
                        NVL (pspe.unit_manager, pspe1.unit_manager) unit_manager,
                        NVL (pspe.business_controller, pspe1.business_controller)
                           business_controller,
                        NVL (pspe.unit_manager_comments, pspe1.unit_manager_comments) unit_manager_comments,
                        NVL (pspe.business_controller_comments, pspe1.business_controller_comments)
                           business_controller_comments,
                        TRUNC (NVL (pspe.approval_date, pspe1.approval_date))
                           approval_date,
                        NVL (pspe.party_id, pspe1.party_id) party_id,
                        pspe.bank_name,
                        pspe.bank_branch_name,
                        pspe.bank_account_number,
                        pspe.bank_account_name,
                        pspe.IBAN,
                        pspe.currency_code,
                        pspe.check_digits,
                        DECODE(pspe.org_id,NULL, pspe1.org_id,pspe.org_id) org_id
                        --pspe1.org_id
                   FROM (SELECT payment_terms,
                                retainage_rate,
                                DECODE (vendor_site_code,
                                        'ZZZZZZZ', NULL,
                                        vendor_site_code)
                                   vendor_site_code,
                                vendor_name,
                                action,
                                party_id,
                                approval_date,
                                unit_manager,
                                business_controller,
                                unit_manager_comments,
                                business_controller_comments,
                                org_id
                           FROM (  SELECT pspe1.c_ext_attr4 payment_terms,
                                          pspe1.c_ext_attr6 retainage_rate,
                                          MIN (NVL (pspe1.c_ext_attr3, 'ZZZZZZZ'))
                                             vendor_site_code,
                                          pspe1.c_ext_attr2 vendor_name,
                                          pspe1.c_ext_attr8 action,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1 approval_date,
                                          pspe1.c_ext_attr9 unit_manager,
                                          pspe1.c_ext_attr10 business_controller,
                                          pspe1.c_ext_attr11 unit_manager_comments,
                                          pspe1.c_ext_attr12 business_controller_comments,
                                          to_number(pspe1.c_ext_attr7) org_id
                                     FROM ego_attr_groups_v eagv,
                                          pos_supp_prof_ext_b pspe1
                                    WHERE     1 = 1
                                          AND eagv.attr_group_name =
                                                 'XXAH_SUPPLIER_TERMS_AUDIT_MR'
                                          AND pspe1.attr_group_id = eagv.attr_group_id
                                          AND pspe1.c_ext_attr8 IN ('BANK_AND_TERMS_UPDATE',
                                                                    'CREATE')
                                 --and party_id = 2101562
                                 GROUP BY pspe1.c_ext_attr4,
                                          pspe1.c_ext_attr6,
                                          pspe1.c_ext_attr2,
                                          pspe1.c_ext_attr8,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1,
                                          pspe1.c_ext_attr9,
                                          pspe1.c_ext_attr10,
                                          pspe1.c_ext_attr11,
                                          pspe1.c_ext_attr12,
                                          to_number(pspe1.c_ext_attr7)
                                 UNION
                                 SELECT pspe1.c_ext_attr4 payment_terms,
                                        pspe1.c_ext_attr6 retainage_rate,
                                        pspe1.c_ext_attr3 vendor_site_code,
                                        pspe1.c_ext_attr2 vendor_name,
                                        pspe1.c_ext_attr8 action,
                                        pspe1.party_id,
                                        pspe1.d_ext_attr1 approval_date,
                                        pspe1.c_ext_attr9 unit_manager,
                                        pspe1.c_ext_attr10 business_controller,
                                        pspe1.c_ext_attr11 unit_manager_comments,
                                        pspe1.c_ext_attr12 business_controller_comments,
                                        to_number(pspe1.c_ext_attr7) org_id
                                   FROM ego_attr_groups_v eagv,
                                        pos_supp_prof_ext_b pspe1
                                  WHERE     1 = 1
                                        AND eagv.attr_group_name =
                                               'XXAH_SUPPLIER_TERMS_AUDIT_MR'
                                        AND pspe1.attr_group_id = eagv.attr_group_id
                                        AND pspe1.c_ext_attr8 IN ('BANK_AND_TERMS_UPDATE',
                                                                  'CREATE')
                                        --and party_id = 2101562
                                        AND pspe1.c_ext_attr3 IS NOT NULL)) pspe1,
                        (SELECT bank_name,
                                bank_branch_name,
                                bank_account_number,
                                bank_account_name,
                                IBAN,
                                currency_code,
                                check_digits,
                                DECODE (vendor_site_code,
                                        'ZZZZZZZ', NULL,
                                        vendor_site_code)
                                   vendor_site_code,
                                vendor_name,
                                action,
                                party_id,
                                approval_date,
                                unit_manager,
                                Business_controller,
                                unit_manager_comments,
                                business_controller_comments,
                                org_id
                           FROM (  SELECT pspe1.c_ext_attr3 bank_name,
                                          pspe1.c_ext_attr4 bank_branch_name,
                                          pspe1.c_ext_attr5 bank_account_number,
                                          pspe1.c_ext_attr6 bank_account_name,
                                          pspe1.c_ext_attr7 IBAN,
                                          pspe1.c_ext_attr8 currency_code,
                                          pspe1.c_ext_attr9 check_digits,
                                          MIN (NVL (pspe1.c_ext_attr1, 'ZZZZZZZ'))
                                             vendor_site_code,
                                          pspe1.c_ext_attr2 vendor_name,
                                          pspe1.c_ext_attr10 action,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1 approval_date,
                                          pspe1.c_ext_attr11 unit_manager,
                                          pspe1.c_ext_attr12 business_controller,
                                          pspe1.c_ext_attr13 unit_manager_comments,
                                          pspe1.c_ext_attr14 business_controller_comments,
                                          pspe1.n_ext_attr2 org_id
                                     FROM ego_attr_groups_v eagv,
                                          pos_supp_prof_ext_b pspe1
                                    WHERE     1 = 1
                                          AND eagv.attr_group_name =
                                                 'XXAH_SUPPLIER_BANK_AUDIT_MR'
                                          AND pspe1.attr_group_id = eagv.attr_group_id
                                          AND pspe1.c_ext_attr10 IN ('BANK_AND_TERMS_UPDATE',
                                                                     'CREATE')
                                 --and party_id = 2101562
                                 GROUP BY pspe1.c_ext_attr3,
                                          pspe1.c_ext_attr4,
                                          pspe1.c_ext_attr5,
                                          pspe1.c_ext_attr6,
                                          pspe1.c_ext_attr7,
                                          pspe1.c_ext_attr8,
                                          pspe1.c_ext_attr9,
                                          pspe1.c_ext_attr2,
                                          pspe1.c_ext_attr10,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1,
                                          pspe1.c_ext_attr11,
                                          pspe1.c_ext_attr12,
                                          pspe1.c_ext_attr13,
                                          pspe1.c_ext_attr14,
                                          pspe1.n_ext_attr2
                                 UNION
                                 SELECT pspe1.c_ext_attr3 bank_name,
                                        pspe1.c_ext_attr4 bank_branch_name,
                                        pspe1.c_ext_attr5 bank_account_number,
                                        pspe1.c_ext_attr6 bank_account_name,
                                        pspe1.c_ext_attr7 IBAN,
                                        pspe1.c_ext_attr8 currency_code,
                                        pspe1.c_ext_attr9 check_digits,
                                        pspe1.c_ext_attr1 vendor_site_code,
                                        pspe1.c_ext_attr2 vendor_name,
                                        pspe1.c_ext_attr10 action,
                                        pspe1.party_id,
                                        pspe1.d_ext_attr1 approval_date,
                                        pspe1.c_ext_attr11 unit_manager,
                                        pspe1.c_ext_attr12 business_controller,
                                        pspe1.c_ext_attr13 unit_manager_comments,
                                        pspe1.c_ext_attr14 business_controller_comments,
                                        pspe1.n_ext_attr2 org_id
                                   FROM ego_attr_groups_v eagv,
                                        pos_supp_prof_ext_b pspe1
                                  WHERE     1 = 1
                                        AND eagv.attr_group_name =
                                               'XXAH_SUPPLIER_BANK_AUDIT_MR'
                                        AND pspe1.attr_group_id = eagv.attr_group_id
                                        AND pspe1.c_ext_attr10 IN ('BANK_AND_TERMS_UPDATE',
                                                                   'CREATE')
                                        --and party_id = 2101562
                                        AND pspe1.c_ext_attr1 IS NOT NULL)) pspe
                  WHERE     1 = 1
                        AND pspe.party_id(+) = pspe1.party_id
                        AND pspe.action(+) = pspe1.action
                        AND pspe.org_id(+) = pspe1.org_id
                        AND NVL (pspe.vendor_site_code(+), 'ZZZZZZZ') =
                               NVL (pspe1.vendor_site_code, 'ZZZZZZZ')
                        AND TRUNC (pspe.approval_date(+)) =
                               TRUNC (pspe1.approval_date)
                        AND pspe1.action IN ('BANK_AND_TERMS_UPDATE', 'CREATE')
                 UNION
                 SELECT DISTINCT
                        NVL (pspe.vendor_name, pspe1.vendor_name) vendor_name,
                        NVL (pspe.vendor_site_code, pspe1.vendor_site_code)
                           vendor_site_code,
                        pspe1.payment_terms,
                        pspe1.retainage_rate,
                        NVL (pspe.action, pspe1.action) action,
                        NVL (pspe.unit_manager, pspe1.unit_manager) unit_manager,
                        NVL (pspe.business_controller, pspe1.business_controller)
                           business_controller,
                        NVL (pspe.unit_manager_comments, pspe1.unit_manager_comments) unit_manager_comments,
                        NVL (pspe.business_controller_comments, pspe1.business_controller_comments)
                           business_controller_comments,
                        TRUNC (NVL (pspe.approval_date, pspe1.approval_date))
                           approval_date,
                        NVL (pspe.party_id, pspe1.party_id) party_id,
                        pspe.bank_name,
                        pspe.bank_branch_name,
                        pspe.bank_account_number,
                        pspe.bank_account_name,
                        pspe.IBAN,
                        pspe.currency_code,
                        pspe.check_digits,
                        DECODE(pspe.org_id,NULL, pspe1.org_id,pspe.org_id) org_id
                        --pspe1.org_id
                   FROM (SELECT payment_terms,
                                retainage_rate,
                                DECODE (vendor_site_code,
                                        'ZZZZZZZ', NULL,
                                        vendor_site_code)
                                   vendor_site_code,
                                vendor_name,
                                action,
                                party_id,
                                approval_date,
                                unit_manager,
                                business_controller,
                                unit_manager_comments,
                                business_controller_comments,
                                org_id
                           FROM (  SELECT pspe1.c_ext_attr4 payment_terms,
                                          pspe1.c_ext_attr6 retainage_rate,
                                          MIN (NVL (pspe1.c_ext_attr3, 'ZZZZZZZ'))
                                             vendor_site_code,
                                          pspe1.c_ext_attr2 vendor_name,
                                          pspe1.c_ext_attr8 action,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1 approval_date,
                                          pspe1.c_ext_attr9 unit_manager,
                                          pspe1.c_ext_attr10 business_controller,
                                          pspe1.c_ext_attr11 unit_manager_comments,
                                          pspe1.c_ext_attr12 business_controller_comments,
                                          to_number(pspe1.c_ext_attr7) org_id
                                     FROM ego_attr_groups_v eagv,
                                          pos_supp_prof_ext_b pspe1
                                    WHERE     1 = 1
                                          AND eagv.attr_group_name =
                                                 'XXAH_SUPPLIER_TERMS_AUDIT_MR'
                                          AND pspe1.attr_group_id = eagv.attr_group_id
                                          AND pspe1.c_ext_attr8 IN ('BANK_AND_TERMS_UPDATE',
                                                                    'CREATE')
                                 --and party_id = 2101562
                                 GROUP BY pspe1.c_ext_attr4,
                                          pspe1.c_ext_attr6,
                                          pspe1.c_ext_attr2,
                                          pspe1.c_ext_attr8,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1,
                                          pspe1.c_ext_attr9,
                                          pspe1.c_ext_attr10,
                                          pspe1.c_ext_attr11,
                                          pspe1.c_ext_attr12,
                                          to_number(pspe1.c_ext_attr7)
                                 UNION
                                 SELECT pspe1.c_ext_attr4 payment_terms,
                                        pspe1.c_ext_attr6 retainage_rate,
                                        pspe1.c_ext_attr3 vendor_site_code,
                                        pspe1.c_ext_attr2 vendor_name,
                                        pspe1.c_ext_attr8 action,
                                        pspe1.party_id,
                                        pspe1.d_ext_attr1 approval_date,
                                        pspe1.c_ext_attr9 unit_manager,
                                        pspe1.c_ext_attr10 business_controller,
                                        pspe1.c_ext_attr11 unit_manager_comments,
                                        pspe1.c_ext_attr12 business_controller_comments,
                                        to_number(pspe1.c_ext_attr7) org_id
                                   FROM ego_attr_groups_v eagv,
                                        pos_supp_prof_ext_b pspe1
                                  WHERE     1 = 1
                                        AND eagv.attr_group_name =
                                               'XXAH_SUPPLIER_TERMS_AUDIT_MR'
                                        AND pspe1.attr_group_id = eagv.attr_group_id
                                        AND pspe1.c_ext_attr8 IN ('BANK_AND_TERMS_UPDATE',
                                                                  'CREATE')
                                        --and party_id = 2101562
                                        AND pspe1.c_ext_attr3 IS NOT NULL)) pspe1,
                        (SELECT bank_name,
                                bank_branch_name,
                                bank_account_number,
                                bank_account_name,
                                IBAN,
                                currency_code,
                                check_digits,
                                DECODE (vendor_site_code,
                                        'ZZZZZZZ', NULL,
                                        vendor_site_code)
                                   vendor_site_code,
                                vendor_name,
                                action,
                                party_id,
                                approval_date,
                                unit_manager,
                                Business_controller,
                                unit_manager_comments,
                                business_controller_comments,
                                org_id
                           FROM (  SELECT pspe1.c_ext_attr3 bank_name,
                                          pspe1.c_ext_attr4 bank_branch_name,
                                          pspe1.c_ext_attr5 bank_account_number,
                                          pspe1.c_ext_attr6 bank_account_name,
                                          pspe1.c_ext_attr7 IBAN,
                                          pspe1.c_ext_attr8 currency_code,
                                          pspe1.c_ext_attr9 check_digits,
                                          MIN (NVL (pspe1.c_ext_attr1, 'ZZZZZZZ'))
                                             vendor_site_code,
                                          pspe1.c_ext_attr2 vendor_name,
                                          pspe1.c_ext_attr10 action,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1 approval_date,
                                          pspe1.c_ext_attr11 unit_manager,
                                          pspe1.c_ext_attr12 business_controller,
                                          pspe1.c_ext_attr13 unit_manager_comments,
                                          pspe1.c_ext_attr14 business_controller_comments,
                                          pspe1.n_ext_attr2 org_id
                                     FROM ego_attr_groups_v eagv,
                                          pos_supp_prof_ext_b pspe1
                                    WHERE     1 = 1
                                          AND eagv.attr_group_name =
                                                 'XXAH_SUPPLIER_BANK_AUDIT_MR'
                                          AND pspe1.attr_group_id = eagv.attr_group_id
                                          AND pspe1.c_ext_attr10 IN ('BANK_AND_TERMS_UPDATE',
                                                                     'CREATE')
                                 --and party_id = 2101562
                                 GROUP BY pspe1.c_ext_attr3,
                                          pspe1.c_ext_attr4,
                                          pspe1.c_ext_attr5,
                                          pspe1.c_ext_attr6,
                                          pspe1.c_ext_attr7,
                                          pspe1.c_ext_attr8,
                                          pspe1.c_ext_attr9,
                                          pspe1.c_ext_attr2,
                                          pspe1.c_ext_attr10,
                                          pspe1.party_id,
                                          pspe1.d_ext_attr1,
                                          pspe1.c_ext_attr11,
                                          pspe1.c_ext_attr12,
                                          pspe1.c_ext_attr13,
                                          pspe1.c_ext_attr14,
                                          pspe1.n_ext_attr2
                                 UNION
                                 SELECT pspe1.c_ext_attr3 bank_name,
                                        pspe1.c_ext_attr4 bank_branch_name,
                                        pspe1.c_ext_attr5 bank_account_number,
                                        pspe1.c_ext_attr6 bank_account_name,
                                        pspe1.c_ext_attr7 IBAN,
                                        pspe1.c_ext_attr8 currency_code,
                                        pspe1.c_ext_attr9 check_digits,
                                        pspe1.c_ext_attr1 vendor_site_code,
                                        pspe1.c_ext_attr2 vendor_name,
                                        pspe1.c_ext_attr10 action,
                                        pspe1.party_id,
                                        pspe1.d_ext_attr1 approval_date,
                                        pspe1.c_ext_attr11 unit_manager,
                                        pspe1.c_ext_attr12 business_controller,
                                        pspe1.c_ext_attr13 unit_manager_comments,
                                        pspe1.c_ext_attr14 business_controller_comments,
                                        pspe1.n_ext_attr2 org_id                                        
                                   FROM ego_attr_groups_v eagv,
                                        pos_supp_prof_ext_b pspe1
                                  WHERE     1 = 1
                                        AND eagv.attr_group_name =
                                               'XXAH_SUPPLIER_BANK_AUDIT_MR'
                                        AND pspe1.attr_group_id = eagv.attr_group_id
                                        AND pspe1.c_ext_attr10 IN ('BANK_AND_TERMS_UPDATE',
                                                                   'CREATE')
                                        --and party_id = 2101562
                                        AND pspe1.c_ext_attr1 IS NOT NULL)) pspe
                  WHERE     1 = 1
                        AND pspe.party_id = pspe1.party_id(+)
                        AND pspe.action = pspe1.action(+)
                        AND pspe.org_id = pspe1.org_id(+)
                        AND NVL (pspe.vendor_site_code, 'ZZZZZZZ') =
                               NVL (pspe1.vendor_site_code(+), 'ZZZZZZZ')
                        AND TRUNC (pspe.approval_date) =
                               TRUNC (pspe1.approval_date(+))
                        AND pspe.action IN ('BANK_AND_TERMS_UPDATE', 'CREATE'))) a,
               hr_all_organization_units hou,
               ap_suppliers aps,
               ap_supplier_sites_all apsa
         WHERE     1 = 1
               AND apsa.vendor_site_code(+) = a.vendor_site
               AND a.org_id = apsa.org_id
               AND apsa.org_id = hou.organization_id(+)
               AND aps.party_id = a.party_id
               AND apsa.vendor_id(+) = aps.vendor_id
               AND a.vendor_name = NVL(p_vendor_name,a.vendor_name)
               AND TRUNC(a.approval_date) BETWEEN TRUNC(NVl(TO_DATE(p_approval_from,'RRRR/MM/DD HH24:MI:SS'),a.approval_date)) and TRUNC(NVl(TO_DATE(p_approval_to,'RRRR/MM/DD HH24:MI:SS'),a.approval_date))
      ORDER BY a.vendor_name,approval_date;  
     CURSOR email_address_cur(p_user_id IN fnd_user.user_id%TYPE)
     IS
        SELECT  NVL(papf.email_address,fu.email_address)
          FROM  fnd_user fu
               ,per_all_people_f papf
         WHERE  1=1
           AND  fu.person_party_id = papf.party_id
           AND  TRUNC(SYSDATE) BETWEEN TRUNC(NVL(papf.EFFECTIVE_START_DATE,SYSDATE)) AND TRUNC(NVL(papf.EFFECTIVE_END_DATE,SYSDATE))
           AND  fu.user_id = p_user_id;
     lv_vendor_name               ap_suppliers.vendor_name%TYPE;
     lv_vendor_site               ap_supplier_sites.vendor_site_code%TYPE;
     lv_org_name                  hr_all_organization_units.name%TYPE;
     lv_unit_manager_comments     pos_supp_prof_ext_b.c_ext_attr1%TYPE;
     lv_bus_controller_comments  VARCHAR2(200);
--     pos_supp_prof_ext_b.c_ext_attr1%TYPE;
     BK_count Number := 0 ;
  BEGIN
     ld_date := SYSDATE;
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<?xml version="1.0"?>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SUPPLIER_INFO>');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering');
     lv_domain := lv_smtp_server;
     fnd_file.put_line(fnd_file.log,'Parameters Passed');
     fnd_file.put_line(fnd_file.log,'------------------');
     fnd_file.put_line(fnd_file.log,'p_vendor_name - '||p_vendor_name);
     fnd_file.put_line(fnd_file.log,'p_approval_from - '||p_approval_from);
     fnd_file.put_line(fnd_file.log,'p_approval_to - '||p_approval_to);
     fnd_file.put_line(fnd_file.log,'------------------');
     fnd_file.put_line(fnd_file.log,'Begin Execution of supp_appr_audit_history_report');
     ln_user_id := fnd_profile.value('USER_ID');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Getting from email Address');

     SELECT  instance_name
       INTO  lv_instance
       FROM  v$instance
      WHERE  rownum =1;

     V_EMAIL := lv_instance||lv_from;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'V_EMAIL'||V_EMAIL);


     OPEN email_address_cur(ln_user_id);
     FETCH email_address_cur INTO V_TOEMAIL;
     CLOSE email_address_cur;

     BEGIN
        SELECT   TO_CHAR (TO_DATE (SYSDATE), 'RRRRMMDD') file_date
          INTO   v_date
          FROM   DUAL;
     EXCEPTION
        WHEN OTHERS
        THEN
          v_date := NULL;
     END;


     v_filename := v_date;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'V_EMAIL'||V_SERVER);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'V_EMAIL'||V_EMAIL);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'V_EMAIL'||V_TOEMAIL);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'V_EMAIL'||V_INSTANCE);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'V_EMAIL'||V_FILENAME);
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_SERVER>'||V_SERVER||'</V_SERVER>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_EMAIL>'||V_EMAIL||'</V_EMAIL>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_TOEMAIL>'||V_TOEMAIL||'</V_TOEMAIL>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_INSTANCE>'||V_INSTANCE||'</V_INSTANCE>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_FILENAME>'||V_FILENAME||'</V_FILENAME>');
     BK_count := 0;
        FOR i IN c_data
        LOOP
           ln_counter := ln_counter + 1;
           BK_count := 1;
           lv_vendor_name := REPLACE(i.vendor_name,'&',';');
           BK_count := 2;
           lv_vendor_site := REPLACE(i.vendor_site,'&',';');
           BK_count := 3;
           lv_unit_manager_comments := REPLACE(i.unit_manager_comments,'&',';');
           BK_count := 4;
           lv_bus_controller_comments := i.business_controller_comments;
--           substr(replace(replace(replace( replace(REPLACE(i.business_controller_comments,'&',';'),CHR(10),''),CHR(13),''),CHR(09),''),'>',';'),1,100);
           --lv_bus_controller_comments := replace(REPLACE(i.business_controller_comments,'&',';'),'>',';');
           BK_count := 5;
           lv_org_name    := REPLACE(i.name,'&',';');           
           BK_count := 6;

           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SUPPLIER>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<VENDOR_NAME>'||lv_vendor_name||'</VENDOR_NAME>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<VENDOR_NUMBER>'||i.segment1||'</VENDOR_NUMBER>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<VENDOR_SITE>'||lv_vendor_site||'</VENDOR_SITE>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<NAME>'||lv_org_name||'</NAME>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<ACTION>'||i.action||'</ACTION>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<PAYMENT_TERMS>'||i.payment_terms||'</PAYMENT_TERMS>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<RETAINAGE_RATE>'||i.retainage_rate||'</RETAINAGE_RATE>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<BANK_NAME>'||i.bank_name||'</BANK_NAME>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<BANK_BRANCH_NAME>'||i.bank_branch_name||'</BANK_BRANCH_NAME>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<BANK_ACCOUNT_NUMBER>'||i.bank_account_number||'</BANK_ACCOUNT_NUMBER>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<BANK_ACCOUNT_NAME>'||i.bank_account_name||'</BANK_ACCOUNT_NAME>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<IBAN>'||i.IBAN||'</IBAN>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<CURRENCY_CODE>'||i.currency_code||'</CURRENCY_CODE>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<CHECK_DIGITS>'||i.check_digits||'</CHECK_DIGITS>'); 
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<UNIT_MANAGER>'||i.unit_manager||'</UNIT_MANAGER>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<BUSINESS_CONTROLLER>'||i.business_controller||'</BUSINESS_CONTROLLER>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<UNIT_MANAGER_COMMENTS>'||i.unit_manager_comments||'</UNIT_MANAGER_COMMENTS>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<BUSINESS_CONTROLLER_COMMENTS>'||i.business_controller_comments||'</BUSINESS_CONTROLLER_COMMENTS>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<APPROVAL_DATE>'||i.approval_date||'</APPROVAL_DATE>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</SUPPLIER>');              
        END LOOP;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</SUPPLIER_INFO>');
     IF ln_counter > 0 
     THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Submitting the XML Bursting');
                  v_req_id := fnd_request.submit_request
                              ('XDO'
                              ,'XDOBURSTREP'
                              ,NULL
                              ,SYSDATE
                              ,FALSE
                              ,NULL --'Y'  ---xdo_cp_data_security_pkg.get_concurrent_request_ids
                              ,g_request_id
                              ,'Y');

      IF v_req_id = 0
      THEN
          fnd_file.put_line(fnd_file.log,'Bursting program failed');
      END IF;  -- v_req_id = 0

     end IF;
     fnd_file.put_line(fnd_file.log,'End Execution of supp_appr_audit_history_report');
  EXCEPTION
    WHEN OTHERS
    THEN
      fnd_file.put_line(fnd_file.log,'Exceptiion in supp_appr_audit_history_report - '||SQLERRM||lv_vendor_name||BK_count||'  '||lv_bus_controller_comments);
      fnd_file.put_line(fnd_file.log,DBMS_UTILITY.format_error_stack);
  END supp_appr_audit_history_report;
END XXAH_AP_SUPPL_APPROVAL_RPT_PKG;

/
