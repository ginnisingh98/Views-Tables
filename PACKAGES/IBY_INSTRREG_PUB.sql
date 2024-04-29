--------------------------------------------------------
--  DDL for Package IBY_INSTRREG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_INSTRREG_PUB" AUTHID CURRENT_USER AS
/*$Header: ibypregs.pls 120.11.12010000.5 2009/07/23 17:05:27 lmallick ship $*/
/*#
 * The IBY_INSTRREG_PUB is the public interface for payment instrument
 * registration in Oracle Payments and lets users add, modify, delete,
 * and query registered payment instruments
 *
 *
 * @rep:scope public
 * @rep:product IBY
 * @rep:displayname Payment Instrument Registration
 * @rep:category BUSINESS_ENTITY IBY_CREDITCARD
 * @rep:doccd iby120ig.pdf Implementing APIs, Oracle Payments Implementation Guide
 */



-- module name used for the application debugging framework
--
G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_INSTRREG_PUB';

-- results interface code; same as for IBY_PAYMENT_ADAPTER_PUB
-- since it returns the same codes from the engine
--
G_INTERFACE_CODE CONSTANT VARCHAR2(30) := 'PMT_ADAPTER';

------------------------------------------------------------------------
-- Constants Declaration
------------------------------------------------------------------------
     C_INSTRTYPE_UNREG  CONSTANT  VARCHAR2(20) := 'UNREGISTERED';
     C_INSTRTYPE_BANKACCT  CONSTANT  VARCHAR2(20) := 'BANKACCOUNT';
     C_INSTRTYPE_CREDITCARD  CONSTANT  VARCHAR2(20) := 'CREDITCARD';
     C_INSTRTYPE_PURCHASECARD  CONSTANT  VARCHAR2(20) := 'PURCHASECARD';

-------------------------------------------------------------------------
   --**Defining all DataStructures required by the APIs**--
--  The following input and output PL/SQL record/table types are defined
-- to store the objects (entities) necessary for the Instrument Registration
-- PL/SQL APIs.
-------------------------------------------------------------------------

--INPUT and OUTPUT DataStructures
  --1. Record Types


TYPE CreditCardInstr_rec_type IS RECORD (
        Instr_Id            NUMBER(15),
        FIName              VARCHAR2(80),
        CC_Type             VARCHAR2(80),
        CC_Num              VARCHAR2(80),
        CC_ExpDate          DATE,
        Instrument_Type     VARCHAR2(30),
        Owner_Id            NUMBER,
        CC_HolderName       VARCHAR2(80),
        CC_HolderType       VARCHAR2(80),
        CC_Desc             VARCHAR2(240),
        Billing_Address_Id  NUMBER,
        Billing_Address1    VARCHAR2(80),
        Billing_Address2    VARCHAR2(80),
        Billing_Address3    VARCHAR2(80),
        Billing_City        VARCHAR2(80),
        Billing_County      VARCHAR2(80),
        Billing_State       VARCHAR2(80),
        Billing_Country     VARCHAR2(80),
        Billing_PostalCode  VARCHAR2(40),
        Single_Use_Flag     VARCHAR2(1),
        Info_Only_Flag      VARCHAR2(1),
        Card_Purpose        VARCHAR2(30),
        Card_Description    VARCHAR2(240),
        Active_Flag         VARCHAR2(1),
        Inactive_Date       DATE,
     Attribute_category    VARCHAR2(150),
     Attribute1 VARCHAR2(150),
     Attribute2 VARCHAR2(150),
     Attribute3 VARCHAR2(150),
     Attribute4 VARCHAR2(150),
     Attribute5 VARCHAR2(150),
     Attribute6 VARCHAR2(150),
     Attribute7 VARCHAR2(150),
     Attribute8 VARCHAR2(150),
     Attribute9 VARCHAR2(150),
     Attribute10 VARCHAR2(150),
     Attribute11 VARCHAR2(150),
     Attribute12 VARCHAR2(150),
     Attribute13 VARCHAR2(150),
     Attribute14 VARCHAR2(150),
     Attribute15 VARCHAR2(150),
     Attribute16 VARCHAR2(150),
     Attribute17 VARCHAR2(150),
     Attribute18 VARCHAR2(150),
     Attribute19 VARCHAR2(150),
     Attribute20 VARCHAR2(150),
     Attribute21 VARCHAR2(150),
     Attribute22 VARCHAR2(150),
     Attribute23 VARCHAR2(150),
     Attribute24 VARCHAR2(150),
     Attribute25 VARCHAR2(150),
     Attribute26 VARCHAR2(150),
     Attribute27 VARCHAR2(150),
     Attribute28 VARCHAR2(150),
     Attribute29 VARCHAR2(150),
     Attribute30 VARCHAR2(150),
     Register_Invalid_Card  VARCHAR2(1)
        );

TYPE PurchaseCardInstr_rec_type IS RECORD (
        Instr_Id            NUMBER( 15 ),
        FIName              VARCHAR2(80),
        PC_Type             VARCHAR2(80),
        PC_Num              VARCHAR2(80),
        PC_ExpDate          DATE,
        Instrument_Type     VARCHAR2(30),
        Owner_Id            NUMBER,
        PC_HolderName       VARCHAR2(80),
        PC_HolderType       VARCHAR2(80),
        PC_Subtype       VARCHAR2(80),
        PC_Desc             VARCHAR2(240),
        Billing_Address_Id  NUMBER,
        Billing_Address1    VARCHAR2(80),
        Billing_Address2    VARCHAR2(80),
        Billing_Address3    VARCHAR2(80),
        Billing_City        VARCHAR2(80),
        Billing_County      VARCHAR2(80),
        Billing_State       VARCHAR2(80),
        Billing_Country     VARCHAR2(80),
        Billing_PostalCode  VARCHAR2(40),
        Single_Use_Flag     VARCHAR2(1),
        Info_Only_Flag      VARCHAR2(1),
        Card_Purpose        VARCHAR2(30),
        Active_Flag         VARCHAR2(1),
        Inactive_Date       DATE,
     Attribute_category    VARCHAR2(150),
     Attribute1 VARCHAR2(150),
     Attribute2 VARCHAR2(150),
     Attribute3 VARCHAR2(150),
     Attribute4 VARCHAR2(150),
     Attribute5 VARCHAR2(150),
     Attribute6 VARCHAR2(150),
     Attribute7 VARCHAR2(150),
     Attribute8 VARCHAR2(150),
     Attribute9 VARCHAR2(150),
     Attribute10 VARCHAR2(150),
     Attribute11 VARCHAR2(150),
     Attribute12 VARCHAR2(150),
     Attribute13 VARCHAR2(150),
     Attribute14 VARCHAR2(150),
     Attribute15 VARCHAR2(150),
     Attribute16 VARCHAR2(150),
     Attribute17 VARCHAR2(150),
     Attribute18 VARCHAR2(150),
     Attribute19 VARCHAR2(150),
     Attribute20 VARCHAR2(150),
     Attribute21 VARCHAR2(150),
     Attribute22 VARCHAR2(150),
     Attribute23 VARCHAR2(150),
     Attribute24 VARCHAR2(150),
     Attribute25 VARCHAR2(150),
     Attribute26 VARCHAR2(150),
     Attribute27 VARCHAR2(150),
     Attribute28 VARCHAR2(150),
     Attribute29 VARCHAR2(150),
     Attribute30 VARCHAR2(150)
        );

TYPE BankAcctInstr_rec_type IS RECORD (
        Instr_Id            NUMBER( 15 ),
        FIName              VARCHAR2(80),
        Bank_ID             VARCHAR2(25),
        Bank_SwiftCode      VARCHAR2(25),
        Branch_ID           VARCHAR2(30),
        BankAcct_Type       VARCHAR2(80),
        BankAcct_Num        VARCHAR2(80),
        BankAcct_Checkdigits VARCHAR2(80),
        BankAcct_HolderName VARCHAR2(80),
        BankAcct_HolderType VARCHAR2(80),
        Bank_Desc           VARCHAR2(240),
        Acct_HolderAddrId   VARCHAR2(80),
        Bank_AddrId         VARCHAR2(80),
        Bank_Address1       VARCHAR2(80),
        Bank_Address2       VARCHAR2(80),
        Bank_Address3       VARCHAR2(80),
        Bank_City           VARCHAR2(80),
        Bank_County         VARCHAR2(80),
        Bank_State          VARCHAR2(80),
        Bank_Country        VARCHAR2(80),
        Bank_PostalCode     VARCHAR2(40),
        BankAcct_Currency   VARCHAR2(40)
        );

TYPE PmtInstr_rec_type IS RECORD (
        InstrumentType     Varchar2(80) := C_INSTRTYPE_UNREG,
        CreditCardInstr    CreditCardInstr_rec_type,
        BankAcctInstr      BankAcctInstr_rec_type,
        PurchaseCardInstr  PurchaseCardInstr_rec_type,
        Encryption_Key     VARCHAR2(200),
        nls_lang_param     VARCHAR2(200)  -- Bug 6318167
        );

TYPE Response_rec_type IS RECORD (
        Status          NUMBER,
        ErrCode         VARCHAR2(80),
        ErrMessage      VARCHAR2(255),
        NLS_LANG        VARCHAR2(80)
        );

TYPE SecureCardInfoResp_rec_type IS RECORD (
        Response              Response_rec_type,
        ExpiryDateSegmentId   NUMBER,
	MaskedChname          VARCHAR2(100),
	ChnameSegmentId       NUMBER,
	ChnameMaskSetting     VARCHAR2(30),
	ChnameUnmaskLength    NUMBER
	);

TYPE GetExpStatusResp_rec_type IS RECORD (
        Response              Response_rec_type,
        Expired               VARCHAR2(1)
	);


--2. Table Types

TYPE CreditCard_tbl_type IS TABLE OF CreditCardInstr_rec_type
       INDEX BY BINARY_INTEGER;

TYPE PurchaseCard_tbl_type IS TABLE OF PurchaseCardInstr_rec_type
       INDEX BY BINARY_INTEGER;

TYPE BankAcct_tbl_type IS TABLE OF BankAcctInstr_rec_type
       INDEX BY BINARY_INTEGER;



-------------------------------------------------------------------------------
                      -- API Signatures--
-------------------------------------------------------------------------------
   -- 1. OraInstrAdd
   -- Start of comments
   --   API name        : OraInstrAdd
   --   Type            : Public
   --   Pre-reqs        : None
   --   Function        : Adds new Payment Instruments to Payments.
   --   Parameters      :
   --   IN              : p_api_version       IN    NUMBER              Required
   --                     p_init_msg_list     IN    VARCHAR2            Optional
   --                     p_commit            IN    VARCHAR2            Optional
   --                     p_validation_level  IN    NUMBER              Optional
   --                     p_payer_id          IN    VARCHAR2            Required
   --                     p_pmtInstrRec       IN    PmtInstr_rec_type   Required
   --
   --   OUT             : x_return_status     OUT   VARCHAR2
   --                     x_msg_count         OUT   VARCHAR2
   --                     x_msg_data          OUT   NUMBER
   --                     x_instr_id          OUT   NUMBER
   --   Version         :
   --                     Current version      1.0
   --                     Previous version     1.0
   --                     Initial version      1.0
   -- End of comments
-------------------------------------------------------------------------------

/*#
 * The oraInstrAdd API Creates a new payment instrument.
 *
 * @param p_api_version version of the API; current version is 1.0
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list standard API parameter; default as FND_API.G_FALSE
 * @param p_commit standard API parameter; default as FND_API.G_TRUE
 * @param p_validation_level standard API parameter; default as
 *        FND_API.G_VALID_LEVEL_FULL
 * @rep:paraminfo {@rep:required}
 * @param p_pmtInstrRec payment instrument record
 * @rep:paraminfo {@rep:required}
 * @param x_return_status standard API parameter - output; indicates the overall
 *        status of the API call
 * @param x_msg_count standard API parameter - output; holds the number of
 *        messages in the API message list
 * @param x_msg_data standard API parameter - output; If the number is one,
 *        then message data holds the message in an encoded format
 * @param x_instr_id unique identifier for the newly created payment instrument
 * @param x_result result code of the operation
 *
 * @rep:scope public
 * @rep:displayname Create Payment Instrument
 * @rep:category BUSINESS_ENTITY IBY_CREDITCARD
 */


  PROCEDURE OraInstrAdd
  (
  p_api_version      IN   NUMBER,
  p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
  p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
  p_validation_level IN   NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_pmtInstrRec      IN   PmtInstr_rec_type,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_instr_id         OUT NOCOPY NUMBER,
  x_result           OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


-------------------------------------------------------------------------------
   -- 2. OraInstrMod
   -- Start of comments
   --   API name        : OraInstrMod
   --   Type            : Public
   --   Pre-reqs        : None
   --   Function        : Modifies an existing payment instruments in Payments.
   --   Parameters      :
   --   IN              : p_api_version       IN    NUMBER              Required
   --                     p_init_msg_list     IN    VARCHAR2            Optional
   --                     p_commit            IN    VARCHAR2            Optional
   --                     p_validation_level  IN    NUMBER              Optional
   --                     p_payer_id      IN    VARCHAR2            Required
   --                     p_pmtInstrRec       IN    PmtInstr_rec_type   Required
   --
   --   OUT             : x_return_status     OUT   VARCHAR2
   --                     x_msg_count         OUT   VARCHAR2
   --                     x_msg_data          OUT   NUMBER
   --   Version         :
   --                     Current version      1.0
   --                     Previous version     1.0
   --                     Initial version      1.0
   -- End of comments
-------------------------------------------------------------------------------

/*#
 * The oraInstrMod API Modifies a payment instrument.
 *
 * @param p_api_version version of the API; current version is 1.0
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list standard API parameter; default as FND_API.G_FALSE
 * @param p_commit standard API parameter; default as FND_API.G_TRUE
 * @param p_validation_level standard API parameter; default as
 *        FND_API.G_VALID_LEVEL_FULL
 * @param p_payer_id payer identifier string
 * @rep:paraminfo {@rep:required}
 * @param p_pmtInstrRec payment instrument record. The Instr_Id is required.
 * @rep:paraminfo {@rep:required}
 * @param x_return_status standard API parameter - output; indicates the overall
 *        status of the API call
 * @param x_msg_count standard API parameter - output; holds the number of
 *        messages in the API message list
 * @param x_msg_data standard API parameter - output; if the number is one,
 *        then message data holds the message in an encoded format
 * @param x_result result of the operation
 *
 * @rep:scope public
 * @rep:displayname Modify Payment Instrument
 * @rep:category BUSINESS_ENTITY IBY_CREDITCARD
 */

  PROCEDURE OraInstrMod
          (p_api_version       IN   NUMBER,
          p_init_msg_list      IN   VARCHAR2  := FND_API.G_FALSE,
          p_commit             IN   VARCHAR2  := FND_API.G_TRUE,
          p_validation_level   IN   NUMBER  := FND_API.G_VALID_LEVEL_FULL,
          p_payer_id           IN      VARCHAR2,
          p_pmtInstrRec        IN      PmtInstr_rec_type,
          x_return_status      OUT NOCOPY VARCHAR2,
          x_msg_count          OUT NOCOPY NUMBER,
          x_msg_data           OUT NOCOPY VARCHAR2,
          x_result             OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
          );


-------------------------------------------------------------------------------
   -- 3. OraInstrDel
   -- Start of comments
   --   API name        : OraInstrDel
   --   Type            : Public
   --   Pre-reqs        : None
   --   Function        : Deletes an existing payment instruments in Payments.
   --   Parameters      :
   --   IN              : p_api_version       IN    NUMBER              Required
   --                     p_init_msg_list     IN    VARCHAR2            Optional
   --                     p_commit            IN    VARCHAR2            Optional
   --                     p_validation_level  IN    NUMBER              Optional
   --                     p_payer_id      IN    VARCHAR2            Required
   --                     p_instr_id          IN    NUMBER              Required
   --
   --   OUT             : x_return_status     OUT   VARCHAR2
   --                     x_msg_count         OUT   VARCHAR2
   --                     x_msg_data          OUT   NUMBER
   --   Version         :
   --                     Current version      1.0
   --                     Previous version     1.0
   --                     Initial version      1.0
   -- End of comments
-------------------------------------------------------------------------------

/*#
 * The oraInstrDel API Deletes a payment instrument.
 *
 * @param p_api_version version of the API; current version is 1.0
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list standard API parameter; default as FND_API.G_FALSE
 * @param p_commit standard API parameter; default as FND_API.G_TRUE
 * @param p_validation_level standard API parameter; default as
 *        FND_API.G_VALID_LEVEL_FULL
 * @param p_payer_id payer identifier string
 * @rep:paraminfo {@rep:required}
 * @param p_instr_id payment instrument unique identifier
 * @rep:paraminfo {@rep:required}
 * @param x_return_status standard API parameter - output; indicates the overall
 *        status of the API call
 * @param x_msg_count standard API parameter - output; holds the number of
 *        messages in the API message list
 * @param x_msg_data standard API parameter - output; if the number is one,
 *        then message data holds the message in an encoded format
 *
 * @rep:scope public
 * @rep:displayname Delete Payment Instrument
 * @rep:category BUSINESS_ENTITY IBY_CREDITCARD
 */

  PROCEDURE OraInstrDel ( p_api_version      IN   NUMBER,
           p_init_msg_list   IN   VARCHAR2  := FND_API.G_FALSE,
           p_commit      IN   VARCHAR2  := FND_API.G_TRUE,
           p_validation_level   IN   NUMBER  := FND_API.G_VALID_LEVEL_FULL,
           p_payer_id           IN      VARCHAR2,
           p_instr_id            IN      NUMBER,
           x_return_status   OUT NOCOPY VARCHAR2,
           x_msg_count      OUT NOCOPY NUMBER,
           x_msg_data      OUT NOCOPY VARCHAR2
         );

-------------------------------------------------------------------------------
   -- 4. OraInstrInq
   -- Start of comments
   --   API name        : OraInstrInq
   --   Type            : Public
   --   Pre-reqs        : None
   --   Function        : Returns all the payment instruments that a payer may have.
   --                     This is based on the payer_id only.
   --   Parameters      :
   --   IN              : p_api_version       IN    NUMBER              Required
   --                     p_init_msg_list     IN    VARCHAR2            Optional
   --                     p_commit            IN    VARCHAR2            Optional
   --                     p_validation_level  IN    NUMBER              Optional
   --                     p_payer_id      IN    VARCHAR2            Required
   --
   --   OUT             : x_return_status     OUT   VARCHAR2
   --                     x_msg_count         OUT   VARCHAR2
   --                     x_msg_data          OUT   NUMBER
   --                     x_creditcard_tbl    OUT   CreditCard_tbl_type
   --                     x_purchasecard_tbl  OUT   PurchaseCard_tbl_type
   --                     x_bankacct_tbl      OUT   BankAcct_tbl_type
   --   Version         :
   --                     Current version      1.0
   --                     Previous version     1.0
   --                     Initial version      1.0
   -- End of comments
-------------------------------------------------------------------------------

/*#
 * The oraInstrInq API Queries payment instrument and returns all the
 * payment instruments that a payer may have based on the payer_id.

 * @param p_api_version version of the API; current version is 1.0
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list standard API parameter; default as FND_API.G_FALSE
 * @param p_commit standard API parameter; default as FND_API.G_TRUE
 * @param p_validation_level standard API parameter; default as
 *        FND_API.G_VALID_LEVEL_FULL
 * @param p_payer_id payer identifier string
 * @rep:paraminfo {@rep:required}
 * @param x_return_status standard API parameter - output; indicates the overall
 *        status of the API call
 * @param x_msg_count standard API parameter - output; holds the number of
 *        messages in the API message list
 * @param x_msg_data standard API parameter - output; if the number is one,
 *        then message data holds the message in an encoded format
 * @param x_creditcard_tbl credit cards of the payer
 * @param x_purchasecard_tbl purchase cards of the payer
 * @param x_bankacct_tbl bank accounts of the payer
 *
 * @rep:scope public
 * @rep:displayname Query Payment Instrument
 * @rep:category BUSINESS_ENTITY IBY_CREDITCARD
 */

  PROCEDURE OraInstrInq ( p_api_version         IN    NUMBER,
           p_init_msg_list       IN    VARCHAR2  := FND_API.G_FALSE,
           p_commit              IN    VARCHAR2  := FND_API.G_TRUE,
           p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL,
           p_payer_id            IN    VARCHAR2,
           x_return_status       OUT NOCOPY VARCHAR2,
           x_msg_count           OUT NOCOPY NUMBER,
           x_msg_data            OUT NOCOPY VARCHAR2,
           x_creditcard_tbl      OUT NOCOPY CreditCard_tbl_type,
           x_purchasecard_tbl    OUT NOCOPY PurchaseCard_tbl_type,
           x_bankacct_tbl        OUT NOCOPY BankAcct_tbl_type
           );

   -- 4.1 OraInstrInq
        --
        -- Overloaded version of above API that takes the system security key as
        -- an argument in case an instrument is encrypted
        --
-------------------------------------------------------------------------------
/*#
 * The oraInstrInq API Queries the payment instrument and returns
 * all the payment instruments that a payer may have based on the
 * payer_id. This overloaded version also takes the system security
 * key as an argument in case an instrument is encrypted.
 *
 * @param p_api_version version of the API; current version is 1.0
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list standard API parameter; default as FND_API.G_FALSE
 * @param p_commit standard API parameter; default as FND_API.G_TRUE
 * @param p_validation_level standard API parameter; default as
 *        FND_API.G_VALID_LEVEL_FULL
 * @param p_payer_id payer identifier string
 * @rep:paraminfo {@rep:required}
 * @param p_sys_sec_key instrument registration security key
 * @param x_return_status standard API parameter - output; indicates the overall
 *        status of the API call
 * @param x_msg_count standard API parameter - output; holds the number of
 *        messages in the API message list
 * @param x_msg_data standard API parameter - output; if the number is one,
 *        then message data holds the message in an encoded format
 * @param x_creditcard_tbl credit cards of the payer
 * @param x_purchasecard_tbl purchase cards of the payer
 * @param x_bankacct_tbl bank accounts of the payer
 *
 * @rep:scope public
 * @rep:displayname Query Payment Instrument
 * @rep:category BUSINESS_ENTITY IBY_CREDITCARD
 */
  PROCEDURE OraInstrInq ( p_api_version         IN    NUMBER,
                          p_init_msg_list       IN    VARCHAR2  := FND_API.G_FALSE,
                          p_commit              IN    VARCHAR2  := FND_API.G_TRUE,
                          p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL,
                          p_payer_id            IN    VARCHAR2,
                          p_sys_sec_key         IN    VARCHAR2,
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_msg_count           OUT NOCOPY NUMBER,
                          x_msg_data            OUT NOCOPY VARCHAR2,
                          x_creditcard_tbl      OUT NOCOPY CreditCard_tbl_type,
                          x_purchasecard_tbl    OUT NOCOPY PurchaseCard_tbl_type,
                          x_bankacct_tbl        OUT NOCOPY BankAcct_tbl_type
                        );


-------------------------------------------------------------------------------
   -- 5. OraInstrInq
   -- Start of comments
   --   API name        : OraInstrInq
   --   Type            : Public
   --   Pre-reqs        : None
   --   Function        : Returns the payment instrument information for an instr_id.
   --                     This is based on the payer_id and instr_id.
   --   Parameters      :
   --   IN              : p_api_version       IN    NUMBER              Required
   --                     p_init_msg_list     IN    VARCHAR2            Optional
   --                     p_commit            IN    VARCHAR2            Optional
   --                     p_validation_level  IN    NUMBER              Optional
   --                     p_payer_id      IN    VARCHAR2            Required
   --                     p_instr_id          IN    NUMBER              Required
   --
   --   OUT             : x_return_status     OUT   VARCHAR2
   --                     x_msg_count         OUT   VARCHAR2
   --                     x_msg_data          OUT   NUMBER
   --                     x_pmtInstrRec       OUT   PmtInstr_rec_type
   --   Version         :
   --                     Current version      1.0
   --                     Previous version     1.0
   --                     Initial version      1.0
   -- End of comments
-------------------------------------------------------------------------------

/*#
 * The oraInstrInq API Queries payment instrument and returns the
 * payment instrument information for an instr_id based on the
 * payer_id and instr_id.
 *
 * @param p_api_version version of the API; current version is 1.0
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list standard API parameter; default as FND_API.G_FALSE
 * @param p_commit standard API parameter; default as FND_API.G_TRUE
 * @param p_validation_level standard API parameter; default as
 *        FND_API.G_VALID_LEVEL_FULL
 * @param p_payer_id payer identifier string
 * @rep:paraminfo {@rep:required}
 * @param p_instr_id payment instrument unique identifier
 * @rep:paraminfo {@rep:required}
 * @param x_return_status standard API parameter - output; indicates the overall
 *        status of the API call
 * @param x_msg_count standard API parameter - output; holds the number of
 *        messages in the API message list
 * @param x_msg_data standard API parameter - output; if the number is one,
 *        then message data holds the message in an encoded format
 * @param x_pmtInstrRec payment instrument of the payer
 *
 * @rep:scope public
 * @rep:displayname Query Payment Instrument
 * @rep:category BUSINESS_ENTITY IBY_CREDITCARD
 */
  PROCEDURE OraInstrInq ( p_api_version         IN    NUMBER,
           p_init_msg_list       IN    VARCHAR2  := FND_API.G_FALSE,
           p_commit              IN    VARCHAR2  := FND_API.G_TRUE,
           p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL,
           p_payer_id            IN    VARCHAR2,
           p_instr_id            IN    NUMBER,
           x_return_status       OUT NOCOPY VARCHAR2,
           x_msg_count           OUT NOCOPY NUMBER,
           x_msg_data            OUT NOCOPY VARCHAR2,
           x_pmtInstrRec         OUT NOCOPY PmtInstr_rec_type
           );

   -- 5.1 OraInstrInq
        --
        -- Overloaded version of above API that takes the system security key as
        -- an argument in case an instrument is encrypted
        --
-------------------------------------------------------------------------------
/*#
 * The oraInstrInq API Queries payment instrument and returns the
 * payment instrument information for an instr_id based on the
 * payer_id and instr_id.
 * This overloaded version also takes the system security key
 * as an argument in case the instrument is encrypted.
 *
 * @param p_api_version version of the API; current version is 1.0
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list standard API parameter; default as FND_API.G_FALSE
 * @param p_commit standard API parameter; default as FND_API.G_TRUE
 * @param p_validation_level standard API parameter; default as
 *        FND_API.G_VALID_LEVEL_FULL
 * @param p_payer_id payer identifier string
 * @rep:paraminfo {@rep:required}
 * @param p_instr_id payment instrument unique identifier
 * @rep:paraminfo {@rep:required}
 * @param p_sys_sec_key instrument registration security key
 * @param x_return_status standard API parameter - output; indicates the overall
 *        status of the API call
 * @param x_msg_count standard API parameter - output; holds the number of
 *        messages in the API message list
 * @param x_msg_data standard API parameter - output; if the number is one,
 *        then message data holds the message in an encoded format
 * @param x_pmtInstrRec payment instrument of the payer
 *
 * @rep:scope public
 * @rep:displayname Query Payment Instrument
 * @rep:category BUSINESS_ENTITY IBY_CREDITCARD
 */

  PROCEDURE OraInstrInq ( p_api_version         IN    NUMBER,
           p_init_msg_list       IN    VARCHAR2  := FND_API.G_FALSE,
           p_commit              IN    VARCHAR2  := FND_API.G_TRUE,
           p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL,
           p_payer_id            IN    VARCHAR2,
           p_instr_id            IN    NUMBER,
           p_sys_sec_key         IN    VARCHAR2,
           x_return_status       OUT NOCOPY VARCHAR2,
           x_msg_count           OUT NOCOPY NUMBER,
           x_msg_data            OUT NOCOPY VARCHAR2,
           x_pmtInstrRec         OUT NOCOPY PmtInstr_rec_type
           );


-------------------------------------------------------------------------------
   /* UTILITY FUNCTION#1: ENCODE
      This function returns a Base64 encoded string.
      This function is being used temporarily as there is no standard function available
      in 8i. It is available in 9i though. This should be discarded when used for 9i.
   */
-------------------------------------------------------------------------------

   FUNCTION encode(s IN VARCHAR2) RETURN VARCHAR2;

-------------------------------------------------------------------------------
   /* UTILITY FUNCTION#2: DECODE
      This function returns a decoded string for a Base64 encoded string.
      This function is being used temporarily as there is no standard function available
      in 8i. It is available in 9i though. This should be discarded when used for 9i.
   */
-------------------------------------------------------------------------------
   FUNCTION decode(s IN VARCHAR2) RETURN VARCHAR2;

 -- Secures the sensitive attributes of a credit card and returns the
 -- corresponding segment IDs.
 -- At present, the card expiry date and the card holder name are
 -- considered to be sensitive. So, this API will secure those fields.
 --
 -- param x_return_status indicates the return status of the procedure; 'S'
 --        indicates success, 'U' indicates an error
 -- param x_msg_count holds the number of error messages in the message list
 -- param x_msg_data contains the error messages
 -- param x_resp_rec entity that stores the attrbutes of the
 --        response
 -- scope: private

  PROCEDURE SecureCardInfo
                    ( p_cardExpiryDate     IN  DATE,
		      p_expSegmentId       IN  NUMBER,
	              p_cardHolderName     IN  VARCHAR2,
		      p_chnameSegmentId    IN  NUMBER,
		      p_chnameMaskSetting  IN  VARCHAR2,
		      p_chnameUnmaskLength IN  NUMBER,
                      x_return_status      OUT NOCOPY VARCHAR2,
                      x_msg_count          OUT NOCOPY NUMBER,
                      x_msg_data           OUT NOCOPY VARCHAR2,
                      x_resp_rec           OUT NOCOPY SecureCardInfoResp_rec_type
                    );

 -- Gets the Expiration Status (Y/N) of a credit card w.r.t.
 -- a particular date.
 --
 -- param x_return_status indicates the return status of the procedure; 'S'
 --        indicates success, 'U' indicates an error
 -- param x_msg_count holds the number of error messages in the message list
 -- param x_msg_data contains the error messages
 -- param x_resp_rec entity that stores the attrbutes of the
 --        response
 -- scope: private

  PROCEDURE Get_Expiration_Status
                    ( p_instrid     IN  NUMBER,
		      p_inputDate   IN  DATE,
	              x_return_status      OUT NOCOPY VARCHAR2,
                      x_msg_count          OUT NOCOPY NUMBER,
                      x_msg_data           OUT NOCOPY VARCHAR2,
                      x_resp_rec           OUT NOCOPY GetExpStatusResp_rec_type
                    );




END IBY_INSTRREG_PUB;

/
