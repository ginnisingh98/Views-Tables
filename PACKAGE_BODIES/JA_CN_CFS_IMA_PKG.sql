--------------------------------------------------------
--  DDL for Package Body JA_CN_CFS_IMA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_CFS_IMA_PKG" AS
  --$Header: JACNIMAB.pls 120.3.12010000.2 2009/01/04 06:33:09 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 1998 Oracle Corporation
  --|                       Redwood Shores, CA, USA
  --|                         All rights reserved.
  --+=======================================================================
  --| FILENAME
  --|     JACNIMAB.pls
  --|
  --| DESCRIPTION
  --|
  --|      This package is to provide share procedures for CNAO programs
  --|
  --| PROCEDURE LIST
  --|
  --|   Item_Mapping_Analysis_Report
  --|
  --|
  --| HISTORY
  --|   27-APR-2007     Joy Liu Created
  --|   03-SEP-2008     Chaoqun Wu Fixed bug# 7373268
  --+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --
  -- Item_Mapping_Analysis_Report                   Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to export the record which item mapping form saved.
  --    It can help the audience know the cash flow of the company and do cash forecasting based on it
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf                  Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode                 Mandatory parameter for PL/SQL concurrent programs
  --      In:      P_APLICATION_ID	         Application ID
  --      In:    P_EVENT_CLASS_CODE          Event class code
  --      In:  P_SUPPORTING_REFERENCE_CODE   Supporting reference code
  --      In:   P_CHART_OF_ACCOUNTS_ID       Chart of Accounts ID

  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      27-APR-2007     Joy Liu Created
  --      03-SEP-2008     Chaoqun Wu Fixed bug# 7373268
  --      15-Dec-2008     Shujuan Yan Fixed bug# 7626489
  --===========================================================================

     PROCEDURE Item_Mapping_Analysis_Report(errbuf                        OUT NOCOPY VARCHAR2
                                           ,retcode                       OUT NOCOPY VARCHAR2
                                           ,P_APLICATION_ID		            IN Number
                                           ,P_EVENT_CLASS_CODE		        IN Varchar2
                                           ,P_SUPPORTING_REFERENCE_CODE		IN Varchar2
                                           ,P_CHART_OF_ACCOUNTS_ID        IN NUMBER)AS

    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='Cash Flow Item Mappings Report';

    l_Application_Id             Ja_Cn_Cfs_Item_Mapping_Hdrs.Application_Id%type:=P_APLICATION_ID;
    l_Event_Class_Code           Ja_Cn_Cfs_Item_Mapping_Hdrs.Event_Class_Code%type:=P_EVENT_CLASS_CODE;
    l_Analyciatl_Criterion_Code  Ja_Cn_Cfs_Item_Mapping_Hdrs.Analytical_Criterion_Code%type:=P_SUPPORTING_REFERENCE_CODE;
    l_Chart_Of_Accounts_Id       Ja_Cn_Cfs_Item_Mapping_Hdrs.Chart_Of_Accounts_Id%type:=P_CHART_OF_ACCOUNTS_ID;
    l_Mapping_Header_Id          Ja_Cn_Cfs_Item_Mapping_Hdrs.Mapping_Header_Id%type;
    l_h_effective_start_date     Ja_Cn_Cfs_Item_Mapping_Hdrs.Effective_Start_Date%type;
    l_h_effective_end_date       Ja_Cn_Cfs_Item_Mapping_Hdrs.Effective_End_Date%type;
    l_Application_Name           FND_APPLICATION_TL.Application_Name%type;
    l_Event_Class_Name           xla_event_classes_TL.Name%type;
    l_source_name                Xla_Sources_tl.Name%type;
    l_org_id                     ja_cn_cfs_item_mapping_lines.org_id%type;
    l_org_name                   hr_all_organization_units_tl.name%type;
    l_ac_value                   ja_cn_cfs_item_mapping_lines.ac_value%type;
    l_detailed_cfs_item          ja_cn_cfs_item_mapping_lines.detailed_cfs_item%type;
    l_cash_flow_item_desc        Fnd_Flex_Values_Tl.Description%type;
    l_effective_start_date       Ja_Cn_Cfs_Item_Mapping_lines.Effective_Start_Date%type;
    l_effective_end_date         Ja_Cn_Cfs_Item_Mapping_lines.Effective_End_Date%type;

    l_varchar_test  varchar2(4000);



    l_xml_report      XMLTYPE;
    l_xml_parameter   XMLTYPE;
    l_xml_head        XMLTYPE;
    l_xml_line        XMLTYPE;
    l_xml_item        XMLTYPE;
    l_xml_head_line   XMLTYPE;
    l_xml_root        XMLTYPE;
    l_characterset    varchar(245);


 	 CURSOR  c_mapping_headers is
    SELECT Hdr.Mapping_Header_Id,
           hdr.effective_start_date,
           hdr.effective_end_date,
           hdr.application_id,
           hdr.event_class_code,
           hdr.analytical_criterion_code
      FROM Ja_Cn_Cfs_Item_Mapping_Hdrs Hdr
     WHERE Hdr.Application_Id = nvl(l_Application_Id,Hdr.Application_Id)
       AND Hdr.Event_Class_Code = nvl(l_Event_Class_Code,Hdr.Event_Class_Code)
       AND Hdr.Analytical_Criterion_Code = nvl(l_Analyciatl_Criterion_Code,Hdr.Analytical_Criterion_Code)
       AND Hdr.Chart_Of_Accounts_Id = l_Chart_Of_Accounts_Id;

    CURSOR c_mapping_lines is
    SELECT Ac_Value,
           Detailed_Cfs_Item,
           Effective_Start_Date,
           Effective_End_Date,
           org_id
      FROM ja_cn_cfs_item_mapping_lines Lin
     WHERE Lin.Mapping_Header_Id = l_Mapping_Header_Id;

   --get organization name
    CURSOR c_org_name is
    SELECT NAME
      FROM Hr_All_Organization_Units_Tl
     WHERE Organization_Id = l_org_id
       AND LANGUAGE = USERENV('LANG');

     --get the application name
     CURSOR c_Application_Name is
     select Application_Name
       from FND_APPLICATION_TL
      where Application_Id = l_Application_Id
        and LANGUAGE = USERENV('LANG');

     --get the event_class-name
     CURSOR  c_Event_Class_Name is
      select name
        FROM xla_event_classes_TL
       where Event_Class_Code = l_Event_Class_Code
         and LANGUAGE = USERENV('LANG');

      --get cash flow item description
/*      CURSOR c_cash_flow_item_desc is
      SELECT Ffvt.Description DESCRIPTION
        FROM Fnd_Flex_Values_Tl Ffvt,Ja_Cn_Cfs_Item_Mapping_Lines JCCIM
       WHERE Ffvt.Flex_Value_Meaning=JCCIM.DETAILED_CFS_ITEM
         AND JCCIM.MAPPING_HEADER_ID=l_Mapping_Header_Id
         and JCCIM.DETAILED_CFS_ITEM=l_detailed_cfs_item
         and Ffvt.LANGUAGE = USERENV('LANG');*/

        CURSOR c_cash_flow_item_desc IS             --Fixed bug# 7373268
       SELECT DISTINCT FFVT.DESCRIPTION DESCRIPTION
         FROM  FND_FLEX_VALUE_SETS          FFVS
              ,FND_FLEX_VALUES_TL           FFVT
              ,FND_FLEX_VALUES              FFV
              ,Ja_Cn_Cfs_Item_Mapping_Lines JCCIML
              ,JA_CN_CASH_VALUESETS_ALL     JCCVA
       WHERE FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID
         AND JCCVA.CHART_OF_ACCOUNTS_ID = l_Chart_Of_Accounts_Id
         AND JCCVA.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
         AND FFVT.FLEX_VALUE_ID = FFV.FLEX_VALUE_ID
         AND FFV.FLEX_VALUE = JCCIML.DETAILED_CFS_ITEM
         AND JCCIML.MAPPING_HEADER_ID=l_Mapping_Header_Id
         and JCCIML.DETAILED_CFS_ITEM=l_detailed_cfs_item
         AND FFVT.LANGUAGE = USERENV('LANG');

     --get source name
     CURSOR c_source_name is
      SELECT St.Name
        FROM Ja_Cn_Cfs_Item_Mapping_Hdrs Cim,
             Xla_Analytical_Hdrs_Tl      Ah,
             Xla_Analytical_Dtls_Tl      Ad,
             Xla_Analytical_Dtls_b       Adl,
             Xla_Analytical_Sources      Sur,
             Xla_Sources_tl              st,
             Xla_Event_Classes_Tl        Ev,
             Fnd_Application_Tl          App
       WHERE Cim.Application_Id = Sur.Source_Application_Id
         AND Cim.Amb_Context_Code = Ah.Amb_Context_Code
         AND cim.analytical_criterion_code = ah.analytical_criterion_code
         AND cim.analytical_criterion_type_code = ah.analytical_criterion_type_code
         AND Ah.Amb_Context_Code = Ad.Amb_Context_Code
         AND ah.analytical_criterion_code = ad.analytical_criterion_code
         AND ah.analytical_criterion_type_code = ad.analytical_criterion_type_code
         AND Ah.Amb_Context_Code = Adl.Amb_Context_Code
         AND ah.analytical_criterion_code = adl.analytical_criterion_code
         AND ah.analytical_criterion_type_code = adl.analytical_criterion_type_code
         AND adl.grouping_order = 1
         AND adl.analytical_detail_code = ad.analytical_detail_code
         AND Ah.Analytical_Criterion_Code = Sur.Analytical_Criterion_Code
         AND ah.amb_context_code = sur.amb_context_code
         AND ah.analytical_criterion_type_code = sur.analytical_criterion_type_code
         AND ad.analytical_detail_code = sur.analytical_detail_code
         AND cim.application_id = sur.application_id
         AND app.application_id = cim.application_id
         AND st.Application_Id = App.Application_Id
         AND st.Source_Code = Sur.Source_Code
         AND st.Source_Type_Code = Sur.Source_Type_Code
         AND sur.application_id = ev.application_id
         AND sur.entity_code = ev.entity_code
         AND sur.event_class_code = ev.event_class_code
         AND App.LANGUAGE = Userenv('LANG')
         AND Ev.LANGUAGE = Userenv('LANG')
         AND Ah.LANGUAGE = Userenv('LANG')
         AND Ad.LANGUAGE = Userenv('LANG')
         AND st.language = Userenv('LANG')
         AND Cim.Mapping_Header_Id= l_Mapping_Header_Id;


   BEGIN
   IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_APLICATION_ID '||P_APLICATION_ID
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_EVENT_CLASS_CODE '||P_EVENT_CLASS_CODE
                    );
      FND_LOG.String(l_proc_level
                    ,l_module_prefix||'.'||l_proc_name||'.parameters'
                    ,'P_SUPPORTING_REFERENCE_CODE '||P_SUPPORTING_REFERENCE_CODE
                    );

      FND_LOG.String(l_proc_level
                    ,l_module_prefix||'.'||l_proc_name||'.parameters'
                    ,'P_CHART_OF_ACCOUNTS_ID '||P_CHART_OF_ACCOUNTS_ID
                    );

    END IF;  --(l_proc_level >= l_dbg_level)


    --call JA_CN_UTILITY.Check_Profile, if it doesn't return true, exit
    IF JA_CN_UTILITY.Check_Profile() <> TRUE THEN
      IF (l_proc_level >= l_dbg_level) THEN
        FND_LOG.STRING(l_proc_level,
                       l_proc_name,
                       'Check profile failed!');
      END IF; --l_exception_level >= l_runtime_level
      retcode := 1;
      errbuf  := '';
      RETURN;
    END IF; --JA_CN_UTILITY.Check_Profile() != TRUE


   OPEN c_Application_Name;
   FETCH c_Application_Name INTO l_Application_Name;
   CLOSE c_Application_Name;
   open c_Event_Class_Name;
   FETCH C_Event_Class_Name INTO l_Event_Class_Name;
   CLOSE c_Event_Class_Name;

    --write the parameter infomation into variable l_xml_parameter and last into l_xml_report
    -- Updated by shujuan for bug 7626489
    l_characterset :=Fnd_Profile.VALUE(NAME => 'ICX_CLIENT_IANA_ENCODING');
    FND_FILE.put_line(FND_FILE.output,'<?xml version="1.0" encoding= '||'"'||l_characterset||'"?>');
    --FND_FILE.put_line(FND_FILE.output,'<?xml version="1.0" encoding="utf-8" ?>');
    l_xml_report := NULL;
    SELECT XMLELEMENT("P_APPLICATION_NAME",l_Application_Name) INTO l_xml_item FROM dual;
    l_xml_parameter := l_xml_item;
    SELECT XMLELEMENT("P_SUPPORTING_REFERENCE_CODE",l_Analyciatl_Criterion_Code ) INTO l_xml_item FROM dual;
    SELECT XMLCONCAT(l_xml_parameter,l_xml_item) INTO l_xml_parameter FROM dual;
    SELECT XMLELEMENT("P_EVENT_CLASS_NAME",l_Event_Class_Name) INTO l_xml_item FROM dual;
    SELECT XMLCONCAT(l_xml_parameter,l_xml_item) INTO l_xml_parameter FROM dual;
    SELECT XMLCONCAT(l_xml_report,l_xml_parameter) INTO l_xml_report FROM dual;

    --get head infomation according to the parameters inputed.
    --for each head, get its lines infomation.


    OPEN c_mapping_headers;
    LOOP
       FETCH c_mapping_headers INTO l_Mapping_Header_Id,
                                    l_h_effective_start_date,
                                    l_h_effective_end_date,
                                    l_Application_Id,
                                    l_Event_Class_Code,
                                    l_Analyciatl_Criterion_Code ;

       EXIT WHEN c_mapping_headers%NOTFOUND;

       l_xml_head_line:=NULL;
       OPEN c_Application_Name;
       FETCH c_Application_Name INTO l_Application_Name;
       CLOSE c_Application_Name;
       open c_Event_Class_Name;
       FETCH C_Event_Class_Name INTO l_Event_Class_Name;
       CLOSE c_Event_Class_Name;

       OPEN c_source_name;
       FETCH c_source_name INTO l_source_name;
       CLOSE c_source_name;
       --write head infomation to l_xml_head, then into l_xml_head_line
       l_xml_head:=NULL;
       SELECT XMLELEMENT("APPLICATION_NAME",l_Application_Name) INTO l_xml_item FROM dual;
       l_xml_head:=l_xml_item;
       SELECT XMLELEMENT("EVENT_CLASS_NAME",l_Event_Class_Name) INTO l_xml_item FROM dual;
       SELECT XMLCONCAT(l_xml_head,l_xml_item) INTO l_xml_head FROM dual;
       SELECT XMLELEMENT("SUPPORTING_REFERENCE_CODE",l_Analyciatl_Criterion_Code) INTO l_xml_item FROM dual;
       SELECT XMLCONCAT(l_xml_head,l_xml_item) INTO l_xml_head FROM dual;
       SELECT XMLELEMENT("SOURCE_NAME",l_source_name) INTO l_xml_item FROM dual;
       SELECT XMLCONCAT(l_xml_head,l_xml_item) INTO l_xml_head FROM dual;
       SELECT XMLELEMENT("H_EFFECTIVE_START_DATE",l_h_effective_start_date) INTO l_xml_item FROM dual;
       SELECT XMLCONCAT(l_xml_head,l_xml_item) INTO l_xml_head FROM dual;
       SELECT XMLELEMENT("H_EFFECTIVE_END_DATE",l_h_effective_end_date) INTO l_xml_item FROM dual;
       SELECT XMLCONCAT(l_xml_head,l_xml_item) INTO l_xml_head FROM dual;
       SELECT XMLCONCAT(l_xml_head_line,l_xml_head) INTO l_xml_head_line FROM dual;

      --get the lines infomation for this head
       OPEN c_mapping_lines;
       LOOP
         FETCH c_mapping_lines INTO l_ac_value,
                                    l_detailed_cfs_item,
                                    l_effective_start_date,
                                    l_effective_end_date,
                                    l_org_id;
         EXIT WHEN c_mapping_lines%NOTFOUND;
         l_cash_flow_item_desc:='';
         OPEN c_cash_flow_item_desc;
         FETCH c_cash_flow_item_desc INTO l_cash_flow_item_desc;
         CLOSE c_cash_flow_item_desc;

         l_org_name:='';
         OPEN c_org_name;
         FETCH c_org_name INTO l_org_name;
         close c_org_name;
         --write lines infomation into l_xml_line, then concat to l_xml_head_line into l_xml_head_line.
         l_xml_line:=NULL;
         SELECT XMLELEMENT("ORG_NAME",l_org_name) INTO l_xml_item FROM dual;
         l_xml_line:=l_xml_item;
         SELECT XMLELEMENT("AC_VALUE",l_ac_value) INTO l_xml_item FROM dual;
         SELECT XMLCONCAT(l_xml_line,l_xml_item) INTO l_xml_line FROM dual;
         SELECT XMLELEMENT("DETAILED_CFS_ITEM",l_detailed_cfs_item) INTO l_xml_item FROM dual;
         SELECT XMLCONCAT(l_xml_line,l_xml_item) INTO l_xml_line FROM dual;
         SELECT XMLELEMENT("DETAILED_ITEM_DESC",l_cash_flow_item_desc) INTO l_xml_item FROM dual;
         SELECT XMLCONCAT(l_xml_line,l_xml_item) INTO l_xml_line FROM dual;
         SELECT XMLELEMENT("EFFECTIVE_START_DATE",l_effective_start_date) INTO l_xml_item FROM dual;
         SELECT XMLCONCAT(l_xml_line,l_xml_item) INTO l_xml_line FROM dual;
         SELECT XMLELEMENT("EFFECTIVE_END_DATE",l_effective_end_date ) INTO l_xml_item FROM dual;
         SELECT XMLCONCAT(l_xml_line,l_xml_item) INTO l_xml_line FROM dual;
         SELECT XMLELEMENT("LINE",l_xml_line) INTO l_xml_line FROM dual;--line circulation
         SELECT XMLCONCAT(l_xml_head_line,l_xml_line) INTO l_xml_head_line FROM dual;

       END LOOP;
       CLOSE c_mapping_lines;
       SELECT XMLELEMENT("HEAD",l_xml_head_line) INTO l_xml_item FROM dual;--head circulation
       SELECT XMLCONCAT(l_xml_report,l_xml_item) INTO l_xml_report FROM dual;
    END LOOP;
    CLOSE c_mapping_headers;

    SELECT XMLELEMENT( "REPORT",l_xml_report) INTO l_xml_root FROM dual;--generate the whole report.
    JA_CN_UTILITY.Output_Conc(l_xml_root.getclobval());

    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.STRING(l_proc_level,
                     l_module_prefix|| '.' || l_proc_name || '.end',
                     'end procedure');
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)
        retcode := 2;
        errbuf  := SQLCODE||':'||SQLERRM;

   END Item_Mapping_Analysis_Report;


END JA_CN_CFS_IMA_PKG;

/
