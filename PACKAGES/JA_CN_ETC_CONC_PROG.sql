--------------------------------------------------------
--  DDL for Package JA_CN_ETC_CONC_PROG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_ETC_CONC_PROG" AUTHID CURRENT_USER AS
  --$Header: JACNETCS.pls 120.0.12000000.1 2007/08/13 14:09:33 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation
  --|                       Redwood Shores, CA, USA
  --|                         All rights reserved.
  --+=======================================================================
  --| FILENAME
  --|     JACNETCS.pls
  --|
  --| DESCRIPTION
  --|
  --|   This is a wrapper package for submission of export
  --|   statement related concurrent programs
  --|
  --|
  --| PROCEDURE LIST
  --|   itemize_ap_journals;
  --|   itemize_ar_journals;
  --|   itemize_pa_journals;
  --|   itemize_po_journals;
  --|   itemize_inv_journals;
  --|   itemize_fa_journals;
  --|   transfer_gl_journals;
  --|   get_description_from_gis;
  --|   post_journal_itemized;
  --|   EAB_Export;
  --|   MultiOrg_Maintain;
  --|   Export_Coa
  --|   Ent_GSSM_Export
  --|   Pub_GSSM_Export
  --|   JOURNAL_ENTRY_EXPORT
  --|   ACCOUNT_BALANCE_EXPORT
  --|   JOURNAL_ENTRY_GENERATION
  --|   ACCOUNT_BALANCE_GENERATION
  --|
  --| HISTORY
  --|   29-Mar-2006     Qingjun Zhao Created
  --    29-Mar-2006     Jackey  Li   Added two procedures
  --|                                 EAB_Export and MultiOrg_Maintain
  --|   29-Mar-2006     Andrew  Liu  Added Export_Coa
  --|   17-May-2006     Andrew  Liu  Added Ent_GSSM_Export and Pub_GSSM_Export
  --|   19-Jun-2006     Joseph Wang added JOURNAL_ENTRY_EXPORT and ACCOUNT_BALANCE_EXPORT
  --|   20-Jun-2006     Jackey Li    added one procedure EAB_Export_Wrapper
  --|   21-Jun-2006     Joseph Wang added JOURNAL_ENTRY_GENERATION and ACCOUNT_BALANCE_GENERATION
  --+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    transfer_gl_sla_to_cnao                 Public
  --
  --  DESCRIPTION:
  --
  --      The 'transfer_gl_sla_to_cnao' procedure accepts parameters from
  --      concurrent program 'Account and Journal Itemization Program' and
  --      calls another procedure
  --      'JA_CN_ACC_JE_ITEMIZATION_PKG.transfer_gl_sla_to_cnao'
  --      with parameters after processing.
  --
  --  PARAMETERS:
  --      In: p_legal_entity_id           Identifier of legal entity
  --                                      parameter for FSG report
  --          p_period_name               GL period Name
  --
  --     Out: errbuf
  --          retcode
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      29-Mar-2006     Qingjun Zhao Created
  --
  --===========================================================================

  PROCEDURE Transfer_Gl_Sla_To_Cnao(Errbuf                 OUT NOCOPY VARCHAR2,
                                    Retcode                OUT NOCOPY VARCHAR2,
                                    p_Chart_Of_Accounts_Id IN NUMBER,
                                    p_Ledger_Id            IN NUMBER,
                                    p_Legal_Entity_Id      IN NUMBER,
                                    p_Period_Name          IN VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --    itemize_ap_journals                   Public
  --
  --  --  DESCRIPTION:
  --
  --      The 'itemize_ap_journals' procedure accepts parameters from
  --      concurrent program 'Itemization program - Journals from Payables' and
  --      calls another procedure
  --      'ja_cn_itemize_ap_journals_pkg.itemize_ap_journals'
  --      with parameters after processing.
  --
  --  PARAMETERS:
  --     Out: errbuf         Mandatory parameter for PL/SQL concurrent programs
  --     Out: retcode        Mandatory parameter for PL/SQL concurrent programs
  --     In:  p_project_option             project source which is defined in
  --                                       GDF of SOB
  --     In:  p_request_id                 identifier of Current request
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      29-Mar-2006     Qingjun Zhao          Created
  --===========================================================================
  --==========================================================================
  --  PROCEDURE NAME:
  --    transfer_gl_journals                  Public
  --
  --  --  DESCRIPTION:
  --
  --      The 'transfer_gl_journals' procedure accepts parameters from
  --      concurrent program 'Itemization program - Journals from General Ledger'
  --      and calls another procedure
  --      'JA_CN_ACC_JE_ITEMIZATION_PKG.transfer_gl_journals'
  --      with parameters after processing.
  --
  --  PARAMETERS:
  --     Out: errbuf         Mandatory parameter for PL/SQL concurrent programs
  --     Out: retcode        Mandatory parameter for PL/SQL concurrent programs
  --     In:  p_project_option             project source which is defined in
  --                                       GDF of SOB
  --     In:  p_request_id                 identifier of Current request
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      29-Mar-2006     Qingjun Zhao          Created
  --===========================================================================
  /*
  PROCEDURE transfer_gl_journals  (
    errbuf           OUT NOCOPY VARCHAR2
   ,retcode          OUT NOCOPY VARCHAR2
   ,p_project_option IN VARCHAR2
   ,p_request_id     IN NUMBER
  );
  */
  --==========================================================================
  --  PROCEDURE NAME:
  --    get_description_from_gis                 Public
  --
  --  --  DESCRIPTION:
  --
  --      The 'get_description_from_gis' procedure accepts parameters from
  --      concurrent program 'Itemization program - Journals from Inter-company'
  --      and calls another procedure
  --      'JA_CN_ACC_JE_ITEMIZATION_PKG.get_description_from_gis'
  --      with parameters after processing.
  --
  --  PARAMETERS:
  --     Out: errbuf         Mandatory parameter for PL/SQL concurrent programs
  --     Out: retcode        Mandatory parameter for PL/SQL concurrent programs
  --     In:  p_project_option             project source which is defined in
  --                                       GDF of SOB
  --     In:  p_request_id                 identifier of Current request
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      29-Mar-2006     Qingjun Zhao          Created
  --===========================================================================
  /*
  PROCEDURE get_description_from_gis  (
    errbuf           OUT NOCOPY VARCHAR2
   ,retcode          OUT NOCOPY VARCHAR2
   ,p_project_option IN VARCHAR2
   ,p_request_id     IN NUMBER
  );
  */
  --==========================================================================
  --  PROCEDURE NAME:
  --    post_journal_itemized                     Public
  --
  --  DESCRIPTION:
  --      The ' post_journal_itemized' procedure accepts parameters from
  --      concurrent program 'Post itemized journals'
  --      and calls another procedure
  --      'JA_CN_POST_UTILITY_PK.post_journal_itemized'
  --      with parameters after processing.
  --
  --  PARAMETERS:
  --     Out: errbuf         Mandatory parameter for PL/SQL concurrent programs
  --     Out: retcode        Mandatory parameter for PL/SQL concurrent programs
  --     In: p_period_name                 the end period name in which
  --                                       the CNAO journal should be processed
  --          p_ledger_id                  ledger ID
  --          p_legal_entity_ID            Legal entity id

  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      29-Mar-2006     Qingjun Zhao          Created
  --      28-Apr-2007     Qingjun Zhao          Change SOB to Ledger for upgrade
  --                                            from 11i to R12
  --===========================================================================

  PROCEDURE Post_Journal_Itemized(Errbuf            OUT NOCOPY VARCHAR2,
                                  Retcode           OUT NOCOPY VARCHAR2,
                                  p_Period_Name     IN VARCHAR2,
                                  p_ledger_Id       IN NUMBER,
                                  p_Legal_Entity_Id IN NUMBER);

  --==========================================================================
  --  PROCEDURE NAME:
  --    EAB_Export                  Public
  --
  --  DESCRIPTION:
  --      This procedure accepts parameters from concurrent program
  --      'Electronic Accounting Book Export'
  --      and calls another procedure 'JA_CN_EAB_EXPORT_PKG.Execute_Export'
  --       with parameters after processing.
  --
  --  PARAMETERS:
  --      In: P_COA_ID                Current chart of accounts ID
  --          p_le_id                 current legal entity ID
  --          P_LEDGER_ID             Current ledger ID
  --          p_fiscal_year           fiscal year under current sob
  --
  --     Out: errbuf
  --          retcode
  --
  --  DESIGN REFERENCES:
  --      CNAO_Electronic_Accounting_Book_Export.doc
  --
  --  CHANGE HISTORY:
  --      03/29/2006      Jackey Li          Created
  --      05/09/2007      Yucheng Sun        Updated
  --===========================================================================

    PROCEDURE EAB_Export(ERRBUF        OUT NOCOPY VARCHAR2
                        ,RETCODE       OUT NOCOPY VARCHAR2
                        ,P_COA_ID      IN NUMBER
                        ,P_LE_ID       IN NUMBER
                        ,P_LEDGER_ID   IN NUMBER
                        ,p_fiscal_year VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --    EAB_Export_Wrapper                  Public
  --
  --  DESCRIPTION:
  --
  --
  --  PARAMETERS:
  --      In: P_COA_ID                current chart of accounts ID
  --          p_ledger_id             current ledger ID
  --          p_le_id                 current legal entity ID
  --          p_fiscal_year           fiscal year under current sob
  --          p_src_charset
  --          p_dest_charset
  --          p_separator
  --          p_file_name
  --
  --     Out: errbuf
  --          retcode
  --
  --  DESIGN REFERENCES:
  --      CNAO_Electronic_Accounting_Book_Export.doc
  --
  --  CHANGE HISTORY:
  --      03/29/2006      Jackey Li          Created
  --      05/09/2007      Yucheng Sun        Updated
  --===========================================================================
  PROCEDURE Eab_Export_Wrapper(Errbuf         OUT NOCOPY VARCHAR2,
                               Retcode        OUT NOCOPY VARCHAR2,
                               P_COA_Id       IN NUMBER,
                               p_Le_Id        IN NUMBER,
                               p_ledger_id    IN NUMBER,
                               p_Fiscal_Year  IN VARCHAR2,
                               p_Src_Charset  IN VARCHAR2,
                               p_Dest_Charset IN VARCHAR2,
                               p_Separator    IN VARCHAR2,
                               p_File_Name    IN VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --    MultiOrg_Maintain                  Public
  --
  --  DESCRIPTION:
  --      This procedure accepts parameters from concurrent program
  --      'Multi-Tiers Organization Maintenance'
  --      and calls another procedure 'JA_CN_MAINTAIN_MULTIORG_PKG.Execute_Maintenance'
  --       with parameters after processing.
  --
  --  PARAMETERS:
  --      In: p_le_id                 current legal entity ID
  --
  --     Out: errbuf
  --          retcode
  --
  --  DESIGN REFERENCES:
  --      CNAO_Multi-Tiers_Organization_Maintenance_TD.doc
  --
  --  CHANGE HISTORY:
  --      03/29/2006      Jackey Li          Created
  --===========================================================================
  /*
    PROCEDURE MultiOrg_Maintain(ERRBUF  OUT NOCOPY VARCHAR2
                               ,RETCODE OUT NOCOPY VARCHAR2
                               ,p_le_id NUMBER);
  */
  --==========================================================================
  --  PROCEDURE NAME:
  --    Export_Coa                    Public
  --
  --  DESCRIPTION:
  --      This procedure checks profile and General Information of
  --      System Options Form, then calls program of COA Export, including
  --      Natural Account and 4 Subsidiary Account of "Project", "Third Party",
  --      "Cost Center" and "Personnel".
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER      Chart of account ID
  --      In: P_LE_ID                 NUMBER      ID of Legal Entity
  --      In: p_Ledger_Id             NUMBER      ID of ledger
  --      In: P_ACCOUNT_TYPE          VARCHAR2    Type of the account
  --      In: P_XML_TEMPLATE_LANGUAGE   VARCHAR2  template language of NA exception report
  --      In: P_XML_TEMPLATE_TERRITORY  VARCHAR2  template territory of NA exception report
  --      In: P_XML_OUTPUT_FORMAT       VARCHAR2  output format of NA exception report
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      03/03/2006     Andrew Liu          Created
  --      04/24/2007     Yucheng Sun         Updated: add ledger id
  --===========================================================================
  PROCEDURE Export_Coa(errbuf                   OUT NOCOPY VARCHAR2,
                       retcode                  OUT NOCOPY VARCHAR2,
                       P_COA_ID                 IN NUMBER,
                       P_LE_ID                  IN NUMBER,
                       p_Ledger_Id              IN NUMBER,
                       P_ACCOUNT_TYPE           IN VARCHAR2,
                       P_XML_TEMPLATE_LANGUAGE  IN VARCHAR2 default 'zh',
                       P_XML_TEMPLATE_TERRITORY IN VARCHAR2 default '00',
                       P_XML_OUTPUT_FORMAT      IN VARCHAR2 default 'RTF');

  --==========================================================================
  --  PROCEDURE NAME:
  --    Export_Coa_Entry              Public
  --
  --  DESCRIPTION:
  --      This procedure submits the program of COA Exports, and then changes
  --      the output file's CharSet and file name.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER      Chart of accounts ID
  --      In: P_LE_ID                 NUMBER      ID of Legal Entity
  --      In: P_ACCOUNT_TYPE          VARCHAR2    Type of the account
  --      In: P_SOURCE_CHARSET          VARCHAR2  source charset for convert
  --      In: P_DESTINATION_CHARSET     VARCHAR2  destination charset for convert
  --      In: P_SOURCE_SEPARATOR        VARCHAR2  source separator for replacement
  --      In: P_DESTINATION_FILENAME    VARCHAR2  output file name
  --      In: P_XML_TEMPLATE_LANGUAGE   VARCHAR2  template language of NA exception report
  --      In: P_XML_TEMPLATE_TERRITORY  VARCHAR2  template territory of NA exception report
  --      In: P_XML_OUTPUT_FORMAT       VARCHAR2  output format of NA exception report
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      03/03/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE Export_Coa_Entry(Errbuf                   OUT NOCOPY VARCHAR2,
                             Retcode                  OUT NOCOPY VARCHAR2,
                             P_COA_ID                 IN NUMBER,
                             p_Le_Id                  IN NUMBER,
                             p_Ledger_Id              IN NUMBER,
                             p_Account_Type           IN VARCHAR2,
                             p_Source_Charset         IN VARCHAR2,
                             p_Destination_Charset    IN VARCHAR2,
                             p_Source_Separator       IN VARCHAR2,
                             p_Destination_Filename   IN VARCHAR2,
                             p_Xml_Template_Language  IN VARCHAR2 DEFAULT 'zh',
                             p_Xml_Template_Territory IN VARCHAR2 DEFAULT '00',
                             p_Xml_Output_Format      IN VARCHAR2 DEFAULT 'RTF');

  --==========================================================================
  --  PROCEDURE NAME:
  --    Ent_GSSM_Export               Public
  --
  --  DESCRIPTION:
  --      This procedure calls GSSM Export program to export GSSM for
  --      Enterprise.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      05/17/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE Ent_Gssm_Export(Errbuf  OUT NOCOPY VARCHAR2,
                            Retcode OUT NOCOPY VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --    Ent_GSSM_Export_Entry         Public
  --
  --  DESCRIPTION:
  --      This procedure submits the program of Enterprise's GSSM Export, and
  --      then changes the output file's CharSet and file name.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_SOURCE_CHARSET        VARCHAR2  source charset for convert
  --      In: P_DESTINATION_CHARSET   VARCHAR2  destination charset for convert
  --      In: P_SOURCE_SEPARATOR      VARCHAR2  source separator for replacement
  --      In: P_DESTINATION_FILENAME  VARCHAR2  output file name
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      03/03/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE Ent_Gssm_Export_Entry(Errbuf                 OUT NOCOPY VARCHAR2,
                                  Retcode                OUT NOCOPY VARCHAR2,
                                  p_Source_Charset       IN VARCHAR2,
                                  p_Destination_Charset  IN VARCHAR2,
                                  p_Source_Separator     IN VARCHAR2,
                                  p_Destination_Filename IN VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --    Pub_GSSM_Export               Public
  --
  --  DESCRIPTION:
  --      This procedure calls GSSM Export program to export GSSM for
  --      Public Sector.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      05/17/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE Pub_Gssm_Export(Errbuf  OUT NOCOPY VARCHAR2,
                            Retcode OUT NOCOPY VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --    Pub_GSSM_Export_Entry         Public
  --
  --  DESCRIPTION:
  --      This procedure submits the program of Public Sector's GSSM Export, and
  --      then changes the output file's CharSet and file name.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_SOURCE_CHARSET        VARCHAR2  source charset for convert
  --      In: P_DESTINATION_CHARSET   VARCHAR2  destination charset for convert
  --      In: P_SOURCE_SEPARATOR      VARCHAR2  source separator for replacement
  --      In: P_DESTINATION_FILENAME  VARCHAR2  output file name
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      03/03/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE Pub_Gssm_Export_Entry(Errbuf                 OUT NOCOPY VARCHAR2,
                                  Retcode                OUT NOCOPY VARCHAR2,
                                  p_Source_Charset       IN VARCHAR2,
                                  p_Destination_Charset  IN VARCHAR2,
                                  p_Source_Separator     IN VARCHAR2,
                                  p_Destination_Filename IN VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    ACCOUNT_BALANCE_EXPORT                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to export the account balances.
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf              Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode             Mandatory parameter for PL/SQL concurrent programs
  --      In:        p_legal_entity      Legal entity ID
  --      In:        p_start_period             start period name
  --      In:        P_end_period               end period name
  --      In: P_XML_TEMPLATE_LANGUAGE    template language of exception report
  --      In: P_XML_TEMPLATE_TERRITORY   template territory of exception report
  --      In: P_XML_OUTPUT_FORMAT        output format of exception report
  --      In: P_SOURCE_CHARSET           source charset for convert
  --      In: P_DESTINATION_CHARSET      destination charset for convert
  --      In: P_SOURCE_SEPARATOR         source separator for replacement
  --      In: P_DESTINATION_FILENAME     output file name
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      19-Jun-2006     Joseph Wang Created
  --      05-July-2006     Add parameters p_start_period and P_end_period
  --                      remove the parameter p_period
  --===========================================================================
  PROCEDURE Account_Balance_Export(Errbuf                   OUT NOCOPY VARCHAR2,
                                   Retcode                  OUT NOCOPY VARCHAR2,
                                   p_coa_id                 IN NUMBER, --added by lyb
                                   p_ledger_id              IN NUMBER, --added by lyb
                                   p_Legal_Entity           IN NUMBER,
                                   p_Start_Period           IN VARCHAR2,
                                   p_End_Period             IN VARCHAR2,
                                   p_Xml_Template_Language  IN VARCHAR2,
                                   p_Xml_Template_Territory IN VARCHAR2,
                                   p_Xml_Output_Format      IN VARCHAR2,
                                   p_Source_Charset         VARCHAR2,
                                   p_Destination_Charset    VARCHAR2,
                                   p_Source_Separator       VARCHAR2,
                                   p_Destination_Filename   VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    ACCOUNT_BALANCE_GENERATION                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to generate the account balances.
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf              Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode             Mandatory parameter for PL/SQL concurrent programs
  --      In:        p_legal_entity      Legal entity ID
  --      In:        p_start_period             start period name
  --      In:        P_end_period               end period name
  --      In: P_XML_TEMPLATE_LANGUAGE    template language of exception report
  --      In: P_XML_TEMPLATE_TERRITORY   template territory of exception report
  --      In: P_XML_OUTPUT_FORMAT        output format of exception report
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      19-Jun-2006     Joseph Wang Created
  --      05-July-2006     Add parameters p_start_period and P_end_period
  --                      remove the parameter p_period
  --===========================================================================

  PROCEDURE Account_Balance_Generation(Errbuf                   OUT NOCOPY VARCHAR2,
                                       Retcode                  OUT NOCOPY VARCHAR2,
                                       p_coa_id                 IN NUMBER, --added by lyb
                                       p_ledger_id              IN NUMBER, --added by lyb
                                       p_Legal_Entity           IN NUMBER,
                                       p_Start_Period           IN VARCHAR2,
                                       p_End_Period             IN VARCHAR2,
                                       p_Xml_Template_Language  IN VARCHAR2,
                                       p_Xml_Template_Territory IN VARCHAR2,
                                       p_Xml_Output_Format      IN VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    JOURNAL_ENTRY_EXPORT                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to export the journal entries.
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf                     Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode                    Mandatory parameter for PL/SQL concurrent programs
  --      In:        p_legal_entity             Legal entity ID
  --      In:        p_start_period             start period name
  --      In:        P_end_period               end period name
  --      In:        P_SOURCE_CHARSET           source charset for convert
  --      In:        P_DESTINATION_CHARSET      destination charset for convert
  --      In:        P_SOURCE_SEPARATOR         source separator for replacement
  --      In:        P_DESTINATION_FILENAME     output file name
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      01-Mar-2006     Joseph Wang Created
  --      15-Jun-2006     Add parameters P_XML_TEMPLATE_LANGUAGE, P_XML_TEMPLATE_TERRITORY, P_XML_OUTPUT_FORMAT
  --      19-Jun-2006     Add parameters P_SOURCE_CHARSET, P_DESTINATION_CHARSET,P_SOURCE_SEPARATOR,
  --                      P_DESTINATION_FILENAME
  --      05-July-2006     Add parameters p_start_period and P_end_period
  --                      remove the parameter p_period
  --
  --===========================================================================

  PROCEDURE Journal_Entry_Export(Errbuf                 OUT NOCOPY VARCHAR2,
                                 Retcode                OUT NOCOPY VARCHAR2,
                                 p_coa_id               IN NUMBER, --added by lyb
                                 p_ledger_id            IN NUMBER, --added by lyb
                                 p_Legal_Entity         IN NUMBER,
                                 p_Start_Period         IN VARCHAR2,
                                 p_End_Period           IN VARCHAR2,
                                 p_Source_Charset       VARCHAR2,
                                 p_Destination_Charset  VARCHAR2,
                                 p_Source_Separator     VARCHAR2,
                                 p_Destination_Filename VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    JOURNAL_ENTRY_GENERATION                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to generate the journal entries.
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf                     Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode                    Mandatory parameter for PL/SQL concurrent programs
  --      In:        p_legal_entity             Legal entity ID
  --      In:        p_start_period             start period name
  --      In:        P_end_period               end period name
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      01-Mar-2006     Joseph Wang Created
  --      15-Jun-2006     Add parameters P_XML_TEMPLATE_LANGUAGE, P_XML_TEMPLATE_TERRITORY, P_XML_OUTPUT_FORMAT
  --      19-Jun-2006     Add parameters P_SOURCE_CHARSET, P_DESTINATION_CHARSET,P_SOURCE_SEPARATOR,
  --                      P_DESTINATION_FILENAME
  --      05-July-2006     Add parameters p_start_period and P_end_period
  --                      remove the parameter p_period
  --
  --===========================================================================
  PROCEDURE JOURNAL_ENTRY_GENERATION(errbuf         OUT NOCOPY VARCHAR2,
                                     retcode        OUT NOCOPY VARCHAR2,
                                     p_coa_id       IN NUMBER,
                                     p_ledger_id    IN NUMBER ,
                                     p_legal_entity IN NUMBER,
                                     p_start_period IN VARCHAR2,
                                     p_end_period   IN VARCHAR2) ;

END Ja_Cn_Etc_Conc_Prog;


 

/
