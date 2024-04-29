--------------------------------------------------------
--  DDL for Package IBY_FNDCPT_EXTRACT_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FNDCPT_EXTRACT_GEN_PVT" AUTHID CURRENT_USER AS
/* $Header: ibyfcxgs.pls 120.9.12010000.2 2010/01/07 08:55:13 sgogula ship $ */

  -- Various parameters used by the extract-generating XML views
  --

  -- xml base; sets
  --
  G_VP_XML_BASE CONSTANT VARCHAR2(30) := 'XML_BASE';

  -- payee security key; for payee trxn data decryption
  --
  G_VP_PAYEE_KEY CONSTANT VARCHAR2(30) := 'PAYEE_KEY';

  -- system security key- for registered instrument decryption
  --
  G_VP_SYS_KEY CONSTANT VARCHAR2(30) := 'SYS_KEY';

  -- CVV2 value

  G_VP_SEC_VAL  CONSTANT  VARCHAR2(30) :='SEC_VAL';

  G_VP_EXTRACT_MODE CONSTANT  VARCHAR2(30) :='EXTRACT_MODE';

  -- bug 5115161: payer notification
  PROCEDURE Create_Payer_Notif_Extract_1_0
  (
  p_mbatchid         IN     VARCHAR2,
  p_fromDate         IN     VARCHAR2,
  p_toDate           IN     VARCHAR2,
  p_fromPSON         IN     VARCHAR2,
  p_toPSON           IN     VARCHAR2,
  p_delivery_method  IN     VARCHAR2,
  p_format_code      IN     VARCHAR2,
  p_txn_id           IN     NUMBER,
  p_sys_key          IN     iby_security_pkg.DES3_KEY_TYPE,
  x_extract_doc      OUT NOCOPY CLOB
  );

  --
  -- Name: Create_Extract_1_0
  -- Args: p_instr_type => primary instrument type of the extract
  --       p_req_type => type of requrest for the extract
  --       p_txn_id => identifier of the extract "transaction"; in the
  --                   case of batch extracts this may refer to an entity
  --                   in the IBY_BATCHES_ALL table
  --       p_sys_key => system security key; used for instrument decryption
  --       x_extract_doc => the resultant extract
  --
  PROCEDURE Create_Extract_1_0
  (
  p_instr_type       IN     VARCHAR2,
  p_req_type         IN     VARCHAR2,
  p_txn_id           IN     NUMBER,
  p_sys_key          IN     iby_security_pkg.DES3_KEY_TYPE,
  x_extract_doc      OUT NOCOPY CLOB
  );

  --
  -- Name: Create_Extract_1_0
  -- Args: p_instr_type => primary instrument type of the extract
  --       p_req_type => type of requrest for the extract
  --       p_txn_id => identifier of the extract "transaction"; in the
  --                   case of batch extracts this may refer to an entity
  --                   in the IBY_BATCHES_ALL table
  --       p_payee_key => payee security key; used for data decryption
  --       p_sys_key => system security key; used for instrument decryption
  --       p_sec_val => transaction CVV2 value
  --       x_extract_doc => the resultant extract
  --
  PROCEDURE Create_Extract_1_0
  (
  p_instr_type       IN     VARCHAR2,
  p_req_type         IN     VARCHAR2,
  p_txn_id           IN     NUMBER,
  p_sys_key          IN     iby_security_pkg.DES3_KEY_TYPE,
  p_sec_val          IN     VARCHAR2,
  x_extract_doc      OUT NOCOPY CLOB
  );

  FUNCTION Get_Ins_PayeeAcctAgg(p_mbatch_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_SRA_Attribute(p_trxnmid IN NUMBER, p_attribute_type IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION Get_Payer_Default_Attribute(p_trxnmid IN NUMBER, p_attribute_type IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION Get_Batch_Format(p_batchid IN VARCHAR2, p_format_type IN VARCHAR2)
  RETURN VARCHAR2;

  PROCEDURE Update_Pmt_SRA_Attr_Prt
  (
  p_mbatchid         IN     VARCHAR2,
  p_fromDate         IN     VARCHAR2,
  p_toDate           IN     VARCHAR2,
  p_fromPSON         IN     VARCHAR2,
  p_toPSON           IN     VARCHAR2,
  p_delivery_method  IN     VARCHAR2,
  p_format_code      IN     VARCHAR2
  );

  PROCEDURE Update_Pmt_SRA_Attr_Ele
  (
  p_trxnmid                      IN     NUMBER,
  p_delivery_method              IN     VARCHAR2,
  p_recipient_email              IN     VARCHAR2,
  p_recipient_fax                IN     VARCHAR2
  );

  FUNCTION submit_payer_notification
  (
    p_bep_type             IN VARCHAR2,
    p_settlement_batch     IN VARCHAR2 DEFAULT NULL,
    p_from_settlement_date IN DATE DEFAULT NULL,
    p_to_settlement_date   IN DATE DEFAULT NULL,
    p_from_PSON            IN VARCHAR2 DEFAULT NULL,
    p_to_PSON              IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION submit_accompany_letter
  (
    p_settlement_batch     IN VARCHAR2
  ) RETURN NUMBER;

 FUNCTION is_amended
       ( p_mandate_id IN iby_debit_authorizations.debit_authorization_id%TYPE )
 RETURN varchar2;

 FUNCTION get_assignment_iban
       ( p_assign_id IN iby_debit_authorizations.external_bank_account_use_id%TYPE )
 RETURN varchar2;

 FUNCTION get_mandate_details
       ( p_mandate_id IN iby_debit_authorizations.debit_authorization_id%TYPE )
 RETURN XMLType;

END IBY_FNDCPT_EXTRACT_GEN_PVT;


/
