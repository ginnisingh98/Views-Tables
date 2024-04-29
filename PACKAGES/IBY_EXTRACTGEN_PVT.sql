--------------------------------------------------------
--  DDL for Package IBY_EXTRACTGEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_EXTRACTGEN_PVT" AUTHID CURRENT_USER AS
/* $Header: ibyxgens.pls 120.10.12010000.2 2009/10/14 05:35:19 pschalla ship $ */

  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_EXTRACTGEN_PVT';


  -- Constants for generating Descriptive Flex Fields
  -- In general value is the table name
  G_DFF_FD_PAYMENT_METHOD VARCHAR2(30)   := 'IBY_PAYMENT_METHODS_B';

  G_DFF_FD_PAYMENT_PROFILE VARCHAR2(30)   := 'IBY_SYS_PMT_PROFILES_B';

  G_DFF_FD_PAY_INSTRUCTION VARCHAR2(30)   := 'IBY_PAY_INSTRUCTIONS_ALL';

  G_DFF_FD_PAYMENT VARCHAR2(30)   := 'IBY_PAYMENTS_ALL';

  G_DFF_FD_DOC_PAYABLE VARCHAR2(30)   := 'IBY_DOCS_PAYABLE_ALL';

  G_DFF_FORMAT VARCHAR2(30)   := 'IBY_FORMATS_B';

  G_DFF_BEP_ACCOUNT VARCHAR2(30)   := 'IBY_BEPKEYS';

  G_DFF_LEGAL_ENTITY VARCHAR2(30)   := 'XLE_FIRSTPARTY_INFORMATION_V';

  G_DFF_PARTY VARCHAR2(30)   := 'HZ_PARTIES';

  G_DFF_INT_BANK_ACCOUNT VARCHAR2(30)   := 'CE_BANK_ACCOUNTS';

  G_DFF_EXT_BANK_ACCOUNT VARCHAR2(30)   := 'IBY_EXT_BANK_ACCOUNTS';

  G_DFF_PO_VENDORS VARCHAR2(30)   := 'PO_VENDORS';

  G_DFF_PO_VENDOR_SITES VARCHAR2(30)   := 'PO_VENDOR_SITES_ALL';

  G_DFF_AP_DOC VARCHAR2(30)   := 'AP_DOCUMENTS_PAYABLE';


  --
  -- Name: Create_Extract
  -- Args: p_extract_code => code of the extract to create
  --       p_extract_version => version of the extract type
  --       p_params => IN parameters to the generator code-point ONLY!!;
  --                   the single OUT parameter should not be included
  --       x_extract_code => the generated extract
  --
  -- Notes: The collection of code-point arguments in p_params
  --        must be sorted in signature-order of the code-point.
  --        Though the table contains strings, all scalar native types are
  --        allowed provided they are in the correct lexical representation.
  --        This is because the parameters will be used to create a dynamic
  --        SQL call statement; this implies that string parameters must
  --        appear properly quoted- i.e.
  --          p_param(i) := '''CREDITCARD''';
  --
  PROCEDURE Create_Extract
  (
  p_extract_code     IN     iby_extracts_vl.extract_code%TYPE,
  p_extract_version  IN     iby_extracts_vl.extract_version%TYPE,
  p_params           IN OUT NOCOPY JTF_VARCHAR2_TABLE_200,
  x_extract_doc      OUT NOCOPY CLOB
  );

  -- Use this function to get descriptive flex field elements
  -- from various tables. This function is intended to be shared
  -- between funds capture and fund disbursement extracts.
  -- Depending on the type of PK of the entity table,
  -- either the entity_id or entity_code should be passed in.
  FUNCTION Get_Dffs(p_entity_table IN VARCHAR2, p_entity_id IN NUMBER, p_entity_code IN VARCHAR2)
  RETURN XMLTYPE;

  -- This function is general for the formatting of files
  -- It allows passing parameters to the XDO template generator
  -- Args: p_template_code.  XDO template code
  --       p_parameters_code.  The code for the parameters we want to use in the
  --                           template during formatting
  --       p_parameters_value. Value of the parameters
  -- The 2 arrays should be defined with the same number of elements
  PROCEDURE get_template_parameters
  (
    p_template_code         IN    iby_formats_b.format_template_code%TYPE,
    p_pay_instruction       IN    VARCHAR2,
    p_parameters_code       OUT NOCOPY JTF_VARCHAR2_TABLE_200,
    p_parameters_value      OUT NOCOPY JTF_VARCHAR2_TABLE_200
  );


  FUNCTION Get_XML_Char_Encoding_Header
  RETURN VARCHAR2;

END IBY_EXTRACTGEN_PVT;

/
