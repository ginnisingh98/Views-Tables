--------------------------------------------------------
--  DDL for Package ZX_TAX_VERTEX_QSU_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_VERTEX_QSU_STUB" AUTHID CURRENT_USER AS
/* $Header: zxvtxqss.pls 120.0.12010000.2 2011/01/19 13:00:09 snoothi ship $ */

    /* *********************** Constant Declarations *********************** */

    /* The maximum length of a city name character string. */
    cQSUCiNameLen CONSTANT BINARY_INTEGER := 25;

    /* The maximum length of a company code character string. */
    cQSUCompCdLen CONSTANT BINARY_INTEGER := 5;

    /* The maximum length of a county name character string. */
    cQSUCoNameLen CONSTANT BINARY_INTEGER := 20;

    /* The maximum length of a customer code character string. */
    cQSUCustCdLen CONSTANT BINARY_INTEGER := 32;

    /* The maximum length of a customer exemption certificate character string. */
    cQSUCustExmtCrtfLen CONSTANT BINARY_INTEGER := 15;

    /* The maximum length of a division code character string. */
    cQSUDivCdLen CONSTANT BINARY_INTEGER := 5;

    /* The maximum length of an exempt reason code character string. */
    cQSUExmtRsnCdLen CONSTANT BINARY_INTEGER := 1;

    /* The maximum length of an invoice control number character string. */
    cQSUInvCntrlNumLen CONSTANT BINARY_INTEGER := 5;

    /* The maximum length of an invoice number character string. */
    cQSUInvIdNumLen CONSTANT BINARY_INTEGER := 12;

    /* The maximum length of a nontaxable reason code character string. */
    cQSUNonTxblRsnCdLen CONSTANT BINARY_INTEGER := 1;

    /* The maximum length of a product code character string. */
    cQSUProdCdLen CONSTANT BINARY_INTEGER := 32;

    /* The maximum length of a product reporting code character string. */
    cQSUProdRptngCdLen CONSTANT BINARY_INTEGER := 3;

    /* The maximum length of a state name abbreviation character string. */
    cQSUStNameAbbrevLen CONSTANT BINARY_INTEGER := 2;

    /* The maximum length of a store code character string. */
    cQSUStoreCdLen CONSTANT BINARY_INTEGER := 10;

    /* The maximum length of a transaction user area character string. */
    cQSUUserAreaLen CONSTANT BINARY_INTEGER := 25;

    /* The maximum length of a product version number character string. */
    cQSUVersionNumberLen CONSTANT BINARY_INTEGER := 19;

    /* The maximum length for a zip code character string. */
    cQSUZipCdLen CONSTANT BINARY_INTEGER := 5;

    /* District Application Codes */
    cQSUDiApplyCi CONSTANT BINARY_INTEGER := 0;
    cQSUDiApplyCo CONSTANT BINARY_INTEGER := 1;

    /* Rate Type Codes */
    cQSURateTypeError     CONSTANT BINARY_INTEGER := 0;
    cQSURateTypeOvrd      CONSTANT BINARY_INTEGER := 1;
    cQSURateTypeTDMOvrd   CONSTANT BINARY_INTEGER := 2;
    cQSURateTypeStandard  CONSTANT BINARY_INTEGER := 3;
    cQSURateTypeZero      CONSTANT BINARY_INTEGER := 4;

    /* Tax Type Codes */
    cQSUTaxTypeError     CONSTANT BINARY_INTEGER := 0;
    cQSUTaxTypeRentLease CONSTANT BINARY_INTEGER := 1;
    cQSUTaxTypeSales     CONSTANT BINARY_INTEGER := 2;
    cQSUTaxTypeService   CONSTANT BINARY_INTEGER := 3;
    cQSUTaxTypeUse       CONSTANT BINARY_INTEGER := 4;

    /* Taxability Codes */
    cQSUTxbltyExmt             CONSTANT BINARY_INTEGER := 0;
    cQSUTxbltyExmtTDMCE        CONSTANT BINARY_INTEGER := 1;
    cQSUTxbltyExmtTDMCT        CONSTANT BINARY_INTEGER := 2;
    cQSUTxbltyExmtTDMCTOvrd    CONSTANT BINARY_INTEGER := 3;
    cQSUTxbltyExmtTDMGTOvrd    CONSTANT BINARY_INTEGER := 4;
    cQSUTxbltyExmtTDMPTOvrd    CONSTANT BINARY_INTEGER := 5;
    cQSUTxbltyNonTxbl          CONSTANT BINARY_INTEGER := 6;
    cQSUTxbltyNonTxblTDMCTOvrd CONSTANT BINARY_INTEGER := 7;
    cQSUTxbltyNonTxblTDMGT     CONSTANT BINARY_INTEGER := 8;
    cQSUTxbltyNonTxblTDMGTOvrd CONSTANT BINARY_INTEGER := 9;
    cQSUTxbltyNonTxblTDMLT     CONSTANT BINARY_INTEGER := 10;
    cQSUTxbltyNonTxblTDMMT     CONSTANT BINARY_INTEGER := 11;
    cQSUTxbltyNonTxblTDMPT     CONSTANT BINARY_INTEGER := 12;
    cQSUTxbltyNonTxblTDMPTOvrd CONSTANT BINARY_INTEGER := 13;
    cQSUTxbltyTxbl             CONSTANT BINARY_INTEGER := 14;
    cQSUTxbltyTxblTDMCT        CONSTANT BINARY_INTEGER := 15;
    cQSUTxbltyTxblTDMCTOvrd    CONSTANT BINARY_INTEGER := 16;
    cQSUTxbltyTxblTDMGT        CONSTANT BINARY_INTEGER := 17;
    cQSUTxbltyTxblTDMGTOvrd    CONSTANT BINARY_INTEGER := 18;
    cQSUTxbltyTxblTDMLT        CONSTANT BINARY_INTEGER := 19;
    cQSUTxbltyTxblTDMMT        CONSTANT BINARY_INTEGER := 20;
    cQSUTxbltyTxblTDMPT        CONSTANT BINARY_INTEGER := 21;
    cQSUTxbltyTxblTDMPTOvrd    CONSTANT BINARY_INTEGER := 22;

    /* Jurisdiction Identification Codes */
    cQSUJurisShipTo      CONSTANT BINARY_INTEGER := 0;
    cQSUJurisShipFrom    CONSTANT BINARY_INTEGER := 1;
    cQSUJurisOrderAccept CONSTANT BINARY_INTEGER := 2;

    /* Transaction Codes */
    cQSUTransCdAdjustment     CONSTANT BINARY_INTEGER := 0;
    cQSUTransCdDistributeRate CONSTANT BINARY_INTEGER := 1;
    cQSUTransCdDistributeTax  CONSTANT BINARY_INTEGER := 2;
    cQSUTransCdNormal         CONSTANT BINARY_INTEGER := 3;
    cQSUTransCdTaxOnlyCredit  CONSTANT BINARY_INTEGER := 4;
    cQSUTransCdTaxOnlyDebit   CONSTANT BINARY_INTEGER := 5;

    /* Transaction Status Codes */
    cQSUTransStatusExcess CONSTANT BINARY_INTEGER := 0;
    cQSUTransStatusMemo   CONSTANT BINARY_INTEGER := 1;
    cQSUTransStatusNormal CONSTANT BINARY_INTEGER := 2;

    /* Transaction Sub-Type Codes */
    cQSUTransSubTypeExpense   CONSTANT BINARY_INTEGER := 0;
    cQSUTransSubTypeFreight   CONSTANT BINARY_INTEGER := 1;
    cQSUTransSubTypeMisc      CONSTANT BINARY_INTEGER := 2;
    cQSUTransSubTypeProperty  CONSTANT BINARY_INTEGER := 3;
    cQSUTransSubTypeRentLease CONSTANT BINARY_INTEGER := 4;
    cQSUTransSubTypeService   CONSTANT BINARY_INTEGER := 5;

    /* Transaction Type Codes */
    cQSUTransTypePurchase  CONSTANT BINARY_INTEGER := 0;
    cQSUTransTypeRentLease CONSTANT BINARY_INTEGER := 1;
    cQSUTransTypeSale      CONSTANT BINARY_INTEGER := 2;
    cQSUTransTypeService   CONSTANT BINARY_INTEGER := 3;

    /* City Search Codes */
    cQSUCiSearchZipCiThenZip CONSTANT BINARY_INTEGER := 1;

    /* Rounding methods. */
    cQSURndngMethodQuantum  CONSTANT BINARY_INTEGER := 0;
    cQSURndngMethodLegacy   CONSTANT BINARY_INTEGER := 1;

    /* ************************** Type Definitions ************************* */

    /* Tax Calculation API context information record type. */
    TYPE tQSUContextRecord IS RECORD (
        fGetJurisNames     BOOLEAN        := FALSE,
        fRoundingMethod    BINARY_INTEGER := 0,
        fCaseSensitive     BOOLEAN        := FALSE,
        fCacheJurisInfo    BOOLEAN        := TRUE,
        fJurisMaxCacheSize BINARY_INTEGER := 16,
        fCacheTDMInfo      BOOLEAN        := TRUE,
        fTDMMaxCacheSize   BINARY_INTEGER := 16,
        fTDMCacheAgeLimit  INTEGER        := 3600);

    /* Invoice header information record type. */
    TYPE tQSUInvoiceRecord IS RECORD (
        fJurisSTGeoCd      NUMBER(9)      := NULL,
        fJurisSTStAbbrv    VARCHAR2(2)    := NULL,
        fJurisSTCoName     VARCHAR2(20)   := NULL,
        fJurisSTCiName     VARCHAR2(25)   := NULL,
        fJurisSTCiCmprssd  BOOLEAN        := NULL,
        fJurisSTZipCd      VARCHAR2(5)    := NULL,
        fJurisSTCiSearchCd BINARY_INTEGER := NULL,
        fJurisSTInCi       BOOLEAN        := NULL,
        fJurisSFGeoCd      NUMBER(9)      := NULL,
        fJurisSFStAbbrv    VARCHAR2(2)    := NULL,
        fJurisSFCoName     VARCHAR2(20)   := NULL,
        fJurisSFCiName     VARCHAR2(25)   := NULL,
        fJurisSFCiCmprssd  BOOLEAN        := NULL,
        fJurisSFZipCd      VARCHAR2(5)    := NULL,
        fJurisSFCiSearchCd BINARY_INTEGER := NULL,
        fJurisSFInCi       BOOLEAN        := NULL,
        fJurisOAGeoCd      NUMBER(9)      := NULL,
        fJurisOAStAbbrv    VARCHAR2(2)    := NULL,
        fJurisOACoName     VARCHAR2(20)   := NULL,
        fJurisOACiName     VARCHAR2(25)   := NULL,
        fJurisOACiCmprssd  BOOLEAN        := NULL,
        fJurisOAZipCd      VARCHAR2(5)    := NULL,
        fJurisOACiSearchCd BINARY_INTEGER := NULL,
        fJurisOAInCi       BOOLEAN        := NULL,
        fInvIdNum          VARCHAR2(12)   := NULL,
        fInvCntrlNum       VARCHAR2(5)    := NULL,
        fInvDate           DATE           := NULL,
        fInvGrossAmt       NUMBER         := NULL,
        fInvTotalTaxAmt    NUMBER         := NULL,
        fInvNumLineItems   INTEGER        := NULL,
        fTDMCustCd         VARCHAR2(32)   := NULL,
        fTDMCustClassCd    VARCHAR2(32)   := NULL,
        fCustTxblty        BINARY_INTEGER := NULL,
        fTDMCompCd         VARCHAR2(5)    := NULL,
        fTDMDivCd          VARCHAR2(5)    := NULL,
        fTDMStoreCd        VARCHAR2(10)   := NULL);

    /* Invoice line item information record type. */
    TYPE tQSULineItemRecord IS RECORD (
        fTransType          BINARY_INTEGER := NULL,
        fTransSubType       BINARY_INTEGER := NULL,
        fTransCd            BINARY_INTEGER := NULL,
        fTransDate          DATE           := NULL,
        fTransExtendedAmt   NUMBER         := NULL,
        fTransQuantity      NUMBER         := NULL,
        fTransTotalTaxAmt   NUMBER         := NULL,
        fTransCombinedRate  NUMBER(7,6)    := NULL,
        fTransUserArea      VARCHAR2(25)   := NULL,
        fTransStatusCd      BINARY_INTEGER := NULL,
        fTDMProdCd          VARCHAR2(300)   := NULL,
        fTDMProdRptngCd     VARCHAR2(3)    := NULL,
        fProdTxblty         BINARY_INTEGER := NULL,
        fPriTaxingJuris     BINARY_INTEGER := NULL,
        fPriCustExmtCrtfNum VARCHAR2(15)   := NULL,
        fPriStTxblty        BINARY_INTEGER := NULL,
        fPriStTaxType       BINARY_INTEGER := NULL,
        fPriStTaxedAmt      NUMBER         := NULL,
        fPriStExmtAmt       NUMBER         := NULL,
        fPriStExmtRsnCd     VARCHAR2(1)    := NULL,
        fPriStNonTxblAmt    NUMBER         := NULL,
        fPriStNonTxblRsnCd  VARCHAR2(1)    := NULL,
        fPriStRate          NUMBER(7,6)    := NULL,
        fPriStRateEffDate   DATE           := NULL,
        fPriStRateType      BINARY_INTEGER := NULL,
        fPriStTaxAmt        NUMBER         := NULL,
        fPriStTaxIncluded   BOOLEAN        := NULL,
        fPriCoTxblty        BINARY_INTEGER := NULL,
        fPriCoTaxType       BINARY_INTEGER := NULL,
        fPriCoTaxedAmt      NUMBER         := NULL,
        fPriCoExmtAmt       NUMBER         := NULL,
        fPriCoExmtRsnCd     VARCHAR2(1)    := NULL,
        fPriCoNonTxblAmt    NUMBER         := NULL,
        fPriCoNonTxblRsnCd  VARCHAR2(1)    := NULL,
        fPriCoRate          NUMBER(7,6)    := NULL,
        fPriCoRateEffDate   DATE           := NULL,
        fPriCoRateType      BINARY_INTEGER := NULL,
        fPriCoTaxAmt        NUMBER         := NULL,
        fPriCoTaxIncluded   BOOLEAN        := NULL,
        fPriCiTxblty        BINARY_INTEGER := NULL,
        fPriCiTaxType       BINARY_INTEGER := NULL,
        fPriCiTaxedAmt      NUMBER         := NULL,
        fPriCiExmtAmt       NUMBER         := NULL,
        fPriCiExmtRsnCd     VARCHAR2(1)    := NULL,
        fPriCiNonTxblAmt    NUMBER         := NULL,
        fPriCiNonTxblRsnCd  VARCHAR2(1)    := NULL,
        fPriCiRate          NUMBER(7,6)    := NULL,
        fPriCiRateEffDate   DATE           := NULL,
        fPriCiRateType      BINARY_INTEGER := NULL,
        fPriCiTaxAmt        NUMBER         := NULL,
        fPriCiTaxIncluded   BOOLEAN        := NULL,
        fPriDiTxblty        BINARY_INTEGER := NULL,
        fPriDiTaxType       BINARY_INTEGER := NULL,
        fPriDiTaxedAmt      NUMBER         := NULL,
        fPriDiExmtAmt       NUMBER         := NULL,
        fPriDiExmtRsnCd     VARCHAR2(1)    := NULL,
        fPriDiNonTxblAmt    NUMBER         := NULL,
        fPriDiNonTxblRsnCd  VARCHAR2(1)    := NULL,
        fPriDiRate          NUMBER(7,6)    := NULL,
        fPriDiRateEffDate   DATE           := NULL,
        fPriDiRateType      BINARY_INTEGER := NULL,
        fPriDiTaxAmt        NUMBER         := NULL,
        fPriDiTaxIncluded   BOOLEAN        := NULL,
        fPriDiAppliesTo     BINARY_INTEGER := NULL,
        fAddTaxingJuris     BINARY_INTEGER := NULL,
        fAddCustExmtCrtfNum VARCHAR2(15)   := NULL,
        fAddCoTxblty        BINARY_INTEGER := NULL,
        fAddCoTaxType       BINARY_INTEGER := NULL,
        fAddCoTaxedAmt      NUMBER         := NULL,
        fAddCoExmtAmt       NUMBER         := NULL,
        fAddCoExmtRsnCd     VARCHAR2(1)    := NULL,
        fAddCoNonTxblAmt    NUMBER         := NULL,
        fAddCoNonTxblRsnCd  VARCHAR2(1)    := NULL,
        fAddCoRate          NUMBER(7,6)    := NULL,
        fAddCoRateEffDate   DATE           := NULL,
        fAddCoRateType      BINARY_INTEGER := NULL,
        fAddCoTaxAmt        NUMBER         := NULL,
        fAddCoTaxIncluded   BOOLEAN        := NULL,
        fAddCiTxblty        BINARY_INTEGER := NULL,
        fAddCiTaxType       BINARY_INTEGER := NULL,
        fAddCiTaxedAmt      NUMBER         := NULL,
        fAddCiExmtAmt       NUMBER         := NULL,
        fAddCiExmtRsnCd     VARCHAR2(1)    := NULL,
        fAddCiNonTxblAmt    NUMBER         := NULL,
        fAddCiNonTxblRsnCd  VARCHAR2(1)    := NULL,
        fAddCiRate          NUMBER(7,6)    := NULL,
        fAddCiRateEffDate   DATE           := NULL,
        fAddCiRateType      BINARY_INTEGER := NULL,
        fAddCiTaxAmt        NUMBER         := NULL,
        fAddCiTaxIncluded   BOOLEAN        := NULL,
        fAddDiTxblty        BINARY_INTEGER := NULL,
        fAddDiTaxType       BINARY_INTEGER := NULL,
        fAddDiTaxedAmt      NUMBER         := NULL,
        fAddDiExmtAmt       NUMBER         := NULL,
        fAddDiExmtRsnCd     VARCHAR2(1)    := NULL,
        fAddDiNonTxblAmt    NUMBER         := NULL,
        fAddDiNonTxblRsnCd  VARCHAR2(1)    := NULL,
        fAddDiRate          NUMBER(7,6)    := NULL,
        fAddDiRateEffDate   DATE           := NULL,
        fAddDiRateType      BINARY_INTEGER := NULL,
        fAddDiTaxAmt        NUMBER         := NULL,
        fAddDiTaxIncluded   BOOLEAN        := NULL,
        fAddDiAppliesTo     BINARY_INTEGER := NULL);

    /* Invoice line items table type. */
    TYPE tQSULineItemTable IS TABLE OF tQSULineItemRecord
        INDEX BY BINARY_INTEGER;

    /* Version information record type. */
    TYPE tQSUVersionRecord IS RECORD (
        fVersionNumber VARCHAR2(19) := NULL,
        fReleaseDate   DATE         := NULL);


    /* ********************** Procedure Specifications ********************* */

    /* Calculate taxes for a given invoice. */
    PROCEDURE QSUCalculateTaxes (pContextRec        IN OUT NOCOPY tQSUContextRecord,
                                 pInvoiceRecIn      IN     tQSUInvoiceRecord,
                                 pLineItemTblIn     IN     tQSULineItemTable,
                                 pInvoiceRecOut     IN OUT NOCOPY tQSUInvoiceRecord,
                                 pLineItemTblOut    IN OUT NOCOPY tQSULineItemTable,
                                 pWriteToPreReturns IN     BOOLEAN);

    /* Retrieve version information for the Quantum for Sales */
    /* and Use Tax Oracle PL/SQL Tax Calculation API. */
    PROCEDURE QSUGetVersionInfo (pContextRec IN OUT NOCOPY tQSUContextRecord,
                                 pVersionRec OUT    NOCOPY tQSUVersionRecord);

    /* Initialize invoice data structures. */
    PROCEDURE QSUInitializeInvoice (pContextRec    IN OUT NOCOPY tQSUContextRecord,
                                    pInvoiceRecIn  IN OUT NOCOPY tQSUInvoiceRecord,
                                    pLineItemTblIn IN OUT NOCOPY tQSULineItemTable);

    /* Write invoice output information to the Quantum for Sales */
    /* and Use Tax pre-returns register table. */
    PROCEDURE QSUWritePreReturnsData (pContextRec     IN OUT NOCOPY tQSUContextRecord,
                                      pInvoiceRecOut  IN     tQSUInvoiceRecord,
                                      pLineItemTblOut IN     tQSULineItemTable);

/* Exception is added for Stub */
    QSU_NOT_FOUND   EXCEPTION;


END ZX_TAX_VERTEX_QSU_STUB;

/
