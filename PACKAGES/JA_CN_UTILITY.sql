--------------------------------------------------------
--  DDL for Package JA_CN_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_UTILITY" AUTHID CURRENT_USER AS
  --$Header: JACNCUYS.pls 120.0.12010000.2 2008/10/28 06:57:48 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation
  --|                       Redwood Shores, CA, USA
  --|                         All rights reserved.
  --+=======================================================================
  --| FILENAME
  --|     JACNCUYS.pls
  --|
  --| DESCRIPTION
  --|
  --|      This package is to provide share procedures for CNAO programs
  --|
  --| PROCEDURE LIST
  --|
  --|   FUNCTION Check_Profile
  --|   FUNCTION Get_Chart_Of_Account_ID
  --|   FUNCTION Get_Lookup_Meaning
  --|   FUNCTION Check_Nat_Number
  --|   PROCEDURE Change_Output_Filename
  --|   PROCEDURE Submit_Charset_Conversion
  --|   FUNCTION  Get_Lookup_Code
  --|
  --| HISTORY
  --|   02-Mar-2006     Donghai Wang Created
  --|   09-Mar-2006     Joseph Wang added the function Get_Chart_Of_Account_ID
  --|   21-Mar-2006     Joseph Wang replace the function Get_Chart_Of_Account_ID by
  --|                   procedure Get_SOB_And_COA to make it return both Set Of Book
  --|                   and Chart Of Account ID
  --|   31-Mar-2006     Joseph Wang added functions Get_SOB and Get_COA
  --|   11-Apr-2006     Jackey Li   added functions Get_Lookup_Meaning and Check_Nat_Number
  --|   27-Apr-2006     Andrew Liu  added Procedure Output_Conc
  --|   18-May-2006     Andrew Liu  added function Check_Account_Level
  --|   20-Jun-2006     Shujuan Yan added the new procedure Change_Output_Filename,
  --|                   Get_Lookup_Code and Submit_Charset_Conversion
  --|   04-July-2006    Joseph Wang added the function Check_Accounting_Period_Range
  --|   1-Sep-2008      Chaoqun Wu added the function Get_Balancing_Segment_Value
  --|
  --+======================================================================*/

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Check_Profile                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to check if all required profiles has been properly set
  --    for current responsibility. If No, the function will return FALSE to caller and .
  --    raise error message. Those required profiles include ' JG: Product', which should
  --    be set to 'Asia/Pacific Localizations','JG: Territory', which should be set
  --     to 'China' and 'JA: CNAO Legal Entity', which should be NOT NULL
  --
  --
  --  PARAMETERS:
  --      In:
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      02-Mar-2006     Donghai Wang Created
  --
  --===========================================================================

  FUNCTION Check_Profile RETURN BOOLEAN;
  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Get_SOB_And_COA                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to get chart of account id and set of book id
  --    by legal entity, if no data found or exception occurs, x_flag will be
  --    returned with -1
  --
  --
  --
  --  PARAMETERS:
  --      In:        p_legal_entity_id      Legal entity ID
  --      Out:       x_sob_id               Set of book ID
  --      Out:       x_coa_id               Chart of account ID
  --      Out:       x_flag                 Return flag
  --
  --  RETURN:
  --      Flag, -1 for abnormal cases.
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      09-Mar-2006     Joseph Wang Created
  --
  --===========================================================================
  PROCEDURE Get_Sob_And_Coa(p_Legal_Entity_Id NUMBER,
                            x_Sob_Id          OUT NOCOPY NUMBER,
                            x_Coa_Id          OUT NOCOPY NUMBER,
                            x_Flag            OUT NOCOPY NUMBER);

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Get_SOB                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to get set of book id within SQL statements
  --    by legal entity. Actually it invokes the procedure Get_SOB_And_COA
  --    to get return value. If no data found or exception occurs, -9 will be
  --    returned.
  --
  --
  --  PARAMETERS:
  --      In:        p_legal_entity_id      Legal entity ID
  --
  --  RETURN:
  --      Set of book ID, -9 for abnormal cases.
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      31-Mar-2006     Joseph Wang Created
  --
  --===========================================================================
  FUNCTION Get_Sob(p_Legal_Entity_Id NUMBER) RETURN NUMBER;
  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Get_COA                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to get chart of account id within SQL statements
  --    by legal entity. Actually it invokes the procedure Get_SOB_And_COA
  --    to get return value. If no data found or exception occurs, -9 will be
  --    returned.
  --
  --
  --  PARAMETERS:
  --      In:        p_legal_entity_id      Legal entity ID
  --
  --  RETURN:
  --      Chart of account ID, -9 for abnormal cases.
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      31-Mar-2006     Joseph Wang Created
  --
  --  CHANGED:
  --Get_Coa function has been updated by lyb in 20-Mar-2007, because the logic is update in R12.
  --We should get the coa id by access id.
  --===========================================================================
  -- FUNCTION Get_Coa(p_Legal_Entity_Id NUMBER) RETURN NUMBER;
  FUNCTION Get_Coa(p_Access_Set_Id NUMBER) RETURN NUMBER;
  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Get_Lookup_Meaning                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to get lookup meaning under one lookup code
  --        according to lookup type.
  --
  --
  --  PARAMETERS:
  --      In:        p_lookup_code     lookup code
  --
  --  RETURN:
  --      Lookup_meaning Varchar2
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      24-Mar-2006     Jackey Li   Created
  --
  --===========================================================================
  FUNCTION Get_Lookup_Meaning(p_Lookup_Code IN VARCHAR2) RETURN VARCHAR2;

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Check_Nat_Number                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to check if the given string is a natual number.
  --
  --
  --  PARAMETERS:
  --      In:        p_subject     the string need to check
  --
  --  RETURN:
  --      BOOLEAN
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --      11-Apr-2006     Jackey Li   Created
  --
  --===========================================================================
  FUNCTION Check_Nat_Number(p_Subject IN VARCHAR2) RETURN BOOLEAN;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Output_Conc                        Public
  --
  --  DESCRIPTION:
  --
  --      This procedure write data to concurrent output file
  --      the data can be longer than 4000
  --
  --  PARAMETERS:
  --      In:  p_clob         the content which need output to concurrent output
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qugen.hu   Created.
  --           27-APR-2005: Andrew.liu imported.
  --
  --===========================================================================
  PROCEDURE Output_Conc(p_Clob IN CLOB);

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Check_Account_Level                Public
  --
  --  DESCRIPTION:
  --
  --      This procedure check the account level of an account. If the account
  --      level is not null, and is a natural number and less than 16 than return
  --      TRUE, else FALSE.
  --
  --  PARAMETERS:
  --      In:  P_LEVEL        the account level
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           18-MAY-2005: Andrew.liu Created.
  --
  --===========================================================================
  FUNCTION Check_Account_Level(p_Level IN VARCHAR2) RETURN BOOLEAN;
  --==========================================================================
  --  FUNCTION NAME:
  --      Get_Lookup_Code                   Public
  --
  --  DESCRIPTION:
  --      This function is used to get lookup code of lookup meaning,
  --  PARAMETERS:
  --      In: p_lookup_meaning      lookup meaning
  --          p_lookup_type         lookup code
  --          p_view_application_id view application, DEFAULT 0
  --          p_security_group_id   security group
  --
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --       06/03/2006     Shujuan Yan          Created
  --==========================================================================
  FUNCTION Get_Lookup_Code(p_Lookup_Meaning      IN VARCHAR2,
                           p_Lookup_Type         IN VARCHAR2,
                           p_View_Application_Id IN NUMBER DEFAULT 0,
                           p_Security_Group_Id   IN NUMBER DEFAULT 0)
    RETURN VARCHAR2;
  --==========================================================================
  --  PROCEDURE NAME:
  --      Submit_xml_publiser                   Public
  --
  --  DESCRIPTION:
  --      This function is used to submit charset conversion concurrent.
  --  PARAMETERS:
  --      In:   p_xml_request_id       xml publisher concurrent request id
  --            p_source_charset       source charset
  --            p_destination_charset  destination charset
  --            p_source_separator     source separator
  --      Out:  x_charset_request_id   charset conversion request id
  --            x_result_flag          result flag
  --
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --       06/03/2006     Shujuan Yan          Created
  --==========================================================================
  PROCEDURE Submit_Charset_Conversion(p_Xml_Request_Id      IN NUMBER,
                                      p_Source_Charset      IN VARCHAR2,
                                      p_Destination_Charset IN VARCHAR2,
                                      p_Source_Separator    IN VARCHAR2,
                                      x_Charset_Request_Id  OUT NOCOPY NUMBER,
                                      x_Result_Flag         OUT NOCOPY VARCHAR2);
  --==========================================================================
  --  PROCEDURE NAME:
  --      Submit_xml_publiser                   Public
  --
  --  DESCRIPTION:
  --      This function is used to submit the concurrent program of change output file name
  --  PARAMETERS:
  --      In:   p_xml_request_id       xml publisher concurrent request id
  --            p_destination_charset  destination charset
  --            p_destination_filename destination filename
  --      Out:  x_charset_request_id   charset conversion request id
  --            x_result_flag          result flag
  --
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --       06/03/2006     Shujuan Yan          Created
  --==========================================================================
  PROCEDURE Change_Output_Filename(p_Xml_Request_Id       IN NUMBER,
                                   p_Destination_Charset  IN VARCHAR2,
                                   p_Destination_Filename IN VARCHAR2,
                                   x_Filename_Request_Id  OUT NOCOPY NUMBER,
                                   x_Result_Flag          OUT NOCOPY VARCHAR2);

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Check_Cash_Related_Account           Public
  --
  --  DESCRIPTION:
  --
  --     This function is used to check if the gl code combination passed in is --     Cash Related.
  --
  --  PARAMETERS:
  --      In:  p_set_of_bks_id      Identifier of GL set of book
  --           p_acc_flex           GL code combination
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           30-MAY-2005: Donghai Wang Created
  --
  --===========================================================================
  FUNCTION Check_Cash_Related_Account(p_Set_Of_Bks_Id IN NUMBER,
                                      p_Acc_Flex      IN VARCHAR2)
    RETURN BOOLEAN;

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Check_Accounting_Period_Range                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to check whether all the periods' status within
  --    the range are 'C' or 'P'
  --
  --
  --  PARAMETERS:
  --      In:        p_legal_entity_id      Legal entity ID
  --      In:        p_start_period_name    Start period name
  --      In:        p_end_period_name      End period name
  --
  --  RETURN:
  --      True for success, otherwise False
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      04-July-2006     Joseph Wang Created
  --
  --===========================================================================
  FUNCTION Check_Accounting_Period_Range(p_Start_Period_Name IN VARCHAR2,
                                         p_End_Period_Name   IN VARCHAR2,
                                         p_Legal_Entity_Id   NUMBER,
                                         p_ledger_id         IN NUMBER)--added by lyb
    RETURN BOOLEAN;

  FUNCTION Fetch_Account_Structure(p_Le_Id IN NUMBER) RETURN VARCHAR2;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Populate_Ledger_Le_Bsv_Gt                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to populate the balance segment of currenct
  --    legal entity and ledger into temporary table ja_cn_ledger_le_bsv_gt
  --
  --
  --  PARAMETERS:
  --      In:        p_legal_entity_id      Legal entity ID
  --      In:        p_ledger_id            Ledger ID
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      12-Mar-07     Qingjun Zhao Created
  --
  FUNCTION Populate_Ledger_Le_Bsv_Gt(p_Ledger_Id       IN NUMBER,
                                     p_Legal_Entity_Id IN NUMBER)
    RETURN VARCHAR2;

    --==========================================================================
  --  FUNCTION NAME:
  --
  --    Get_Balancing_Segment_Value                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to get balancing segment value for the specified key flexfield segments.
  --
  --
  --  PARAMETERS:
  --      In:        p_coa_id                     Chart of account ID
  --      In:        p_concatenated_segments      Concatenated segments
  --
  --  RETURN:
  --      Balancing segment value, NULL for abnormal cases.
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      29-Aug-2008     Chaoqun Wu Created
  --
  --===========================================================================
  FUNCTION Get_Balancing_Segment_Value(
                                 p_coa_id IN NUMBER,
                                 p_concatenated_segments   IN  VARCHAR2)
  RETURN VARCHAR2;

END Ja_Cn_Utility;


/
