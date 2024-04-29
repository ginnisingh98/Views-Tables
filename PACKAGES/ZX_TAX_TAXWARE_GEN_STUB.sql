--------------------------------------------------------
--  DDL for Package ZX_TAX_TAXWARE_GEN_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_TAXWARE_GEN_STUB" AUTHID CURRENT_USER AS
/* $Header: zxtxwgns.pls 120.0.12010000.2 2011/01/19 12:37:53 snoothi ship $ */

/*
   TxAmtType                   NUMBER(17,5);
*/
   TxAmtType                   NUMBER;

   LoRecValue                  NUMBER;
   SecLoRecValue               NUMBER;
   CnRecValue                  NUMBER;
   SecCnRecValue               NUMBER;
   /* following flag is used to indicate whether DB tables are to be loaded
      into memory or NOT. Initialy value is TRUE, after loading value
      will be FALSE. */
   LoadTable_Flag              BOOLEAN := TRUE;
   /* Used to indicate Record type stored in temporary record variable used */
   /* by  CopyRec   function.*/

   /* Constants for values to be stored in above indicators  */
   SFCOUNTYVAL                 CONSTANT  NUMBER := 1;
   SFLOCALVAL                  CONSTANT  NUMBER := 2;
   STCOUNTYVAL                 CONSTANT  NUMBER := 3;
   STLOCALVAL                  CONSTANT  NUMBER := 4;
   POOCOUNTYVAL                CONSTANT  NUMBER := 5;
   POOLOCALVAL                 CONSTANT  NUMBER := 6;
   POACOUNTYVAL                CONSTANT  NUMBER := 7;
   POALOCALVAL                 CONSTANT  NUMBER := 8;

   /* Tax Program Selection Parameters - SELPARMTYP */
   SELPARMTYP                  CHAR;
   SELPRM_DEFLT_TAXES_ONLY     CONSTANT CHAR   := ' ';
   SELPRM_JUR_ONLY             CONSTANT CHAR   := '1';
   SELPRM_TAXES_ONLY           CONSTANT CHAR   := '2';
   SELPRM_TAX_JUR              CONSTANT CHAR   := '3';
   JUR_TAX_ONLY                CONSTANT CHAR   := 'N';

   /* Tax Calculation Types - TYPECALC */
   TYPECALC                    CHAR;
   CALC_DEFLT_BY_GROSS         CONSTANT CHAR   := ' ';
   CALC_BY_GROSS               CONSTANT CHAR   := 'G';
   CALC_BY_E_CREDIT            CONSTANT CHAR   := 'E';
   CALC_FROM_TAXES             CONSTANT CHAR   := 'T';


   /* Sales/Use/Rental Indicator - TYPETAX */
   TYPETAX                     CHAR;
   IND_SALES                   CONSTANT CHAR   := 'S';
   IND_USE                     CONSTANT CHAR   := 'U';
   IND_SERV                    CONSTANT CHAR   := 'V';
   IND_CONUSE                  CONSTANT CHAR   := 'C';
   IND_RENTAL                  CONSTANT CHAR   := 'R';

   /* OptFiles (Optional Files) values - OPTFTYPE */
   OPTFTYPE                    CHAR;
   OPTF_NO_PROD                CONSTANT CHAR   := '1';
   /* Don't use Product file */
   OPTF_NO_ERR                 CONSTANT CHAR   := '2';
   /* Don't use error file */
   OPTF_NO_ERR_NO_PROD         CONSTANT CHAR   := '3';
   /* Don't use either file */

   /* Completion Code Types - CCLEVEL */
   CCLEVEL                     NUMBER;
   TAXGENERAL                  CONSTANT  NUMBER   := 0;
   TAXSTATE                    CONSTANT  NUMBER   := 1;
   TAXCOUNTY                   CONSTANT  NUMBER   := 2;
   TAXLOCAL                    CONSTANT  NUMBER   := 3;
   TAXSECONDARY                CONSTANT  NUMBER   := 4;

   /* Levels of taxability - TAXLEVEL */
   TAXLEVEL                    NUMBER;
   FEDERAL                     CONSTANT NUMBER   := 0;
   STATE                       CONSTANT NUMBER   := 1;
   COUNTY                      CONSTANT NUMBER   := 2;
   SEC_COUNTY                  CONSTANT NUMBER   := 3;
   LOCAL                       CONSTANT NUMBER   := 4;
   SEC_LOCAL                   CONSTANT NUMBER   := 5;

   /* End Link Value */
   OPENPARM                    CONSTANT CHAR(5) := 'OPEN ';
   CLOSEPARM                   CONSTANT CHAR(5) := 'CLOSE';

   /* Reason Codes */
   REASON_APOFPO               CONSTANT CHAR(2) := 'BM';

   /* GENERAL COMPLETION CODE VALUE */

   SUCCESSCC                   CONSTANT NUMBER := 0;
   INVALIDZIP                  CONSTANT NUMBER := 1;
   INVALIDST                   CONSTANT NUMBER := 3;
   INVALIDGRS                  CONSTANT NUMBER := 4;
   INVALIDTAXAMT               CONSTANT NUMBER := 5;
   GENINVZIPST                 CONSTANT NUMBER := 6;
   TAXACCESSERR                CONSTANT NUMBER := 8;
   INVSELPARM                  CONSTANT NUMBER := 9;
                               /* Also returned by Jurisdiction */
   INVCALCTYP                  CONSTANT NUMBER := 11;
   PRDACCESSERR                CONSTANT NUMBER := 12;
   CONUSEFILEERR               CONSTANT NUMBER := 13 ;
   RATEISZERO                  CONSTANT NUMBER := 14;
   INVALIDEXM                  CONSTANT NUMBER := 15;
   INVALIDFRT                  CONSTANT NUMBER := 16;
   NEGFIELDS                   CONSTANT NUMBER := 17;
   INVALIDDTE                  CONSTANT NUMBER := 18;
   CC_APOFPO                   CONSTANT NUMBER := 19;
   AUDACCESSERR                CONSTANT NUMBER := 25;
   INVCALCERR                  CONSTANT NUMBER := 28;
   CERRACCESSERR               CONSTANT NUMBER := 29;
   JERRACCESSERR               CONSTANT NUMBER := 31;
   INVJURERR                   CONSTANT NUMBER := 30;
   INVJURPROC                  CONSTANT NUMBER := 32;
   PRDINVALID4CU               CONSTANT NUMBER := 39;
   PRDINVALID4SERV             CONSTANT NUMBER := 39;
   CALC_E_ERROR                CONSTANT NUMBER := 42;
   EXEMPTLGRGROSS              CONSTANT NUMBER := 43;
   AMOUNTOVERFLOW              CONSTANT NUMBER := 44;

   /* ifdef SYSCTRL_USE_ST*/
   NOSTEPPROC                  CONSTANT NUMBER := 51;
   STEPNOCUSTERR               CONSTANT NUMBER := 52;
   STEPPARAMERR                CONSTANT NUMBER := 54;
   STEPMISCERR                 CONSTANT NUMBER := 55;
   STEPSTATEERR                CONSTANT NUMBER := 56;
   /* endif */

   /* ifdef _USE_PRODUCT */
   PRODCDCONVNOTFOUND          CONSTANT NUMBER := 71;
   /* endif */

   /* ifde_NEXPRO */
   NOACCESSMERCH               CONSTANT NUMBER := 82;
   NOMERCHANTREC               CONSTANT NUMBER := 83;
   NOACCESSSTNEX               CONSTANT NUMBER := 84;
   NOACCESSLONEX               CONSTANT NUMBER := 85;
   NOMERCHANTID                CONSTANT NUMBER := 86;
   NOSTATENEXREC               CONSTANT NUMBER := 93;
   /* endif */

   JURISERROR                  CONSTANT NUMBER := 95;

   /* TAXCALC LOCATION COMPCODES */
   TAXMAXTAX_NOT_FOUND         CONSTANT NUMBER := 42;
   NOTAXINDUSED                CONSTANT NUMBER := 33;
   INVZIPST                    CONSTANT NUMBER := 06;
   INVCOUNTY                   CONSTANT NUMBER := 19;
   CITYDEFAULT                 CONSTANT NUMBER := 20;
   OVRRDECNTY                  CONSTANT NUMBER := 20;
   INVTAXIND                   CONSTANT NUMBER := 21;
   NOLOTAXFORZP                CONSTANT NUMBER := 22;
   NOCNTAXFORZP                CONSTANT NUMBER := 23;
   REAS_TAX_ADJ                CONSTANT NUMBER := 28;
   REAS_NITEM_INCOMPAT         CONSTANT NUMBER := 29;
   OVRRDERATE                  CONSTANT NUMBER := 30;
   OVRRDEAMT                   CONSTANT NUMBER := 31;
   STEPUSERATE                 CONSTANT NUMBER := 32;
   NOTAXINDUSE                 CONSTANT NUMBER := 33;
   PRODEXEMPT4CU               CONSTANT NUMBER := 39;
   PRODRATE                    CONSTANT NUMBER := 35;
   PRD_MAX_TAX_ADJ             CONSTANT NUMBER := 36;
   PRD_NITEM_INCOMPAT_MAX      CONSTANT NUMBER := 37;
   MAX_TAX_ADJ                 CONSTANT NUMBER := 40;
   NITEM_INCOMPAT_MAX          CONSTANT NUMBER := 41;
   PRDPOLICERATEHALF           CONSTANT NUMBER := 43;
   PRDPOLICERATETHIRD          CONSTANT NUMBER := 43;
   PRDPOLICERATEQUARTER        CONSTANT NUMBER := 43;
   DEFAULT_CURRDATE            CONSTANT NUMBER := 45;
   NO_USE_TAX                  CONSTANT NUMBER := 49;
   NO_TAXES                    CONSTANT NUMBER := 50;
   STATE_TAX_ONLY              CONSTANT NUMBER := 51;
   STATE_FED_SALES_ONLY        CONSTANT NUMBER := 52;
   STATE_FED_USE_ONLY          CONSTANT NUMBER := 53;
   CNLO_NO_TAXES               CONSTANT NUMBER := 54;
   CNLO_SALES_ONLY             CONSTANT NUMBER := 55;
   CNLO_USE_ONLY               CONSTANT NUMBER := 56;
   CNLO_TRANSIT_ONLY           CONSTANT NUMBER := 57;
   CNLO_NO_TRANSIT             CONSTANT NUMBER := 58;
   LO_NO_TAXES                 CONSTANT NUMBER := 59;
   LO_STATE_ONLY               CONSTANT NUMBER := 60;
   CNLO_ADMIN_A                CONSTANT NUMBER := 61;

   E_ESTIMATE                  CONSTANT NUMBER := 72;
   E_NO_EXEMPT_AMT             CONSTANT NUMBER := 73;

   /* if defined _NEXPRO */
   /*       NEXUSNOLOTAX                CONSTANT NUMBER := 61;
							to be deleted ??? */
   NEXUSNOTAX                  CONSTANT NUMBER := 64;
   /* endif */

   PRDNOTOK4CU                 CONSTANT NUMBER := 38;
   PRDNOTOK4SERV               CONSTANT NUMBER := 38;

   /* Extra Comnpletion Code */
   CONUSETRANS                 CONSTANT NUMBER := 1;

   /* Jurisdiction Return C*/

   JURSUCCESS                  CONSTANT NUMBER := 0;
   JURINVPOT                   CONSTANT NUMBER := 1;
   JURINVSRVIN                 CONSTANT NUMBER := 2;
   JURINVLINK                  CONSTANT NUMBER := 3;
   JURERROR                    CONSTANT NUMBER := 99;

   /* Jurisdiction Location Return Codes */

   LOCCNTYDEF                  CONSTANT NUMBER := 1;
   LOCINVSTATE                 CONSTANT NUMBER := 2;
   LOCNOZIP                    CONSTANT NUMBER := 3;
   LOCINVZIP                   CONSTANT NUMBER := 4;
   LOCNOCITY                   CONSTANT NUMBER := 5;
   LOCNOGEO                    CONSTANT NUMBER := 5;
   LOCINVCNTY                  CONSTANT NUMBER := 6;
   LOCINVCITY                  CONSTANT NUMBER := 7;
   LOCCNTYDEFINVCITY           CONSTANT NUMBER := 8;

   /*if defined _NEXPRO*/
   NOSTORZIPCALLNEX            CONSTANT NUMBER := 9;
   /*endif*/

   MAXGROSSAMOUNT              CONSTANT NUMBER := 99999999999.99;
   MAXTAXAMOUNT                CONSTANT NUMBER := 99999999.99;

   /*if defined SYSCTRL_MSDOS*/
   ALIGNSIZE                   CONSTANT NUMBER:= 1;
   /*endif*/

   /* Tax Type Constants - TaxType*/
   TaxType                     CHAR;
   SALESTAX                    CONSTANT CHAR   :='S';
   USETAX                      CONSTANT CHAR   :='U';
   RENTTAX                     CONSTANT CHAR   :='R';
   CONUSETAX                   CONSTANT CHAR   :='C';
   SERVTAX                     CONSTANT CHAR   :='V';
   NOTAX                       CONSTANT CHAR   :='N';
   DEFLT_NOTAX                 CONSTANT CHAR   := ' ';

   /*  Jurisdiction POT constants - JurPOTType */
   JurPOTType                  CHAR;
   POT_DEST                    CONSTANT CHAR :='D';
   POT_ORIG                    CONSTANT CHAR :='O';


   /*  Jurisdiction Location Type constants - JurLocType */
   JurLocType                  CHAR;
   JUR_IS_ST                   CONSTANT CHAR :='T';
   JUR_IS_SF                   CONSTANT CHAR :='F';
   JUR_IS_POA                  CONSTANT CHAR :='A';
   JUR_IS_POO                  CONSTANT CHAR :='O';
   JUR_IS_BT                   CONSTANT CHAR :='B';

   TYPE TaxFlagsType is RECORD
   (
     Have_County               BOOLEAN,
     Have_Local                BOOLEAN,
     Have_Secondary_County     BOOLEAN,
     Have_Secondary_Local      BOOLEAN,
     Used_Override             BOOLEAN,
     Product_Exception         BOOLEAN,
     Alabama_Rental            BOOLEAN,
     CdaTaxOnTax               BOOLEAN,
     LoRnt_UseSales            BOOLEAN,
     CnRnt_UseSales            BOOLEAN,
     Exempt                    BOOLEAN,
     APOFPO                    BOOLEAN,
     MTATax                    BOOLEAN,
     Product_Max               BOOLEAN,
     UsedProdLoTxRt            BOOLEAN,

     /* Override flags are set when the override amounts or rates are passed  */
     FedOverride               BOOLEAN,
     StOverride                BOOLEAN,
     CntyOverride              BOOLEAN,
     CityOverride              BOOLEAN,
     DistOverride              BOOLEAN,
     SecStOverride             BOOLEAN,
     SecCntyOverride           BOOLEAN,
     SecCityOverride           BOOLEAN,
     AllOverride               BOOLEAN,

     /* Special flags are set when either override flags are set */
     /* or no tax indicators are passed                          */
     FedSpecFlg                BOOLEAN,
     StSpecFlg                 BOOLEAN,
     CntySpecFlg               BOOLEAN,
     CitySpecFlg               BOOLEAN,
     DistSpecFlg               BOOLEAN,
     SecStSpecFlg              BOOLEAN,
     SecCntySpecFlg            BOOLEAN,
     SecCitySpecFlg            BOOLEAN,
     AllSpecFlg                BOOLEAN,
     AllTaxCert                BOOLEAN,
     BasisPerc                 BOOLEAN,
     HSTProv                   BOOLEAN
   );

   TYPE HaveTyp is RECORD
   (
     ShipTo                    BOOLEAN,
     ShipFrom                  BOOLEAN,
     POA                       BOOLEAN,
     POO                       BOOLEAN
   );

   TYPE JurFlagsType is RECORD
   (
     HaveLocl                  HaveTyp,
     HaveCnty                  HaveTyp
   );

  TYPE t_OraParm IS RECORD
   (
      OracleID                  NUMBER(15),
      Oracle_Msg_Text           VARCHAR2(512),
      Oracle_Msg_Label          VARCHAR2(12),
      Taxware_Msg_Text          VARCHAR2(256),
      Reserved_Text_1           VARCHAR2(25),
      Reserved_Text_2           VARCHAR2(25),
      Reserved_Text_3           VARCHAR2(25),
      Reserved_BOOL_1           BOOLEAN,
      Reserved_BOOL_2           BOOLEAN,
      Reserved_BOOL_3           BOOLEAN,
      Reserved_CHAR_1           CHAR(2),
      Reserved_CHAR_2           CHAR(2),
      Reserved_CHAR_3           CHAR(2),
      Reserved_NUM_1            NUMBER(15),
      Reserved_NUM_2            NUMBER(15),
      Reserved_BIGNUM_1         NUMBER,
      Reserved_DATE_1           DATE
   );


   TYPE TaxParm  is RECORD
   (
     Countrycode               char(3),
     StateCode                 char(2) ,
     PriZip                    CHAR(5),
     PriGeo                    CHAR(2),
     PriZipExt                 VARCHAR2(4),
     SecZip                    CHAR(5),
     SecGeo                    CHAR(2),
     SecZipExt                 VARCHAR2(4),
     CntyCode                  CHAR(3),
     CntyName                  VARCHAR2(26),
     LoclName                  VARCHAR2(26),
     SecCntyCode               CHAR(3),
     SecCntyName               VARCHAR2(26),
     SecCityName               VARCHAR2(26),
     ShortLoNameInd            BOOLEAN,
     JurLocTp                  CHAR(1),
     GrossAmt                  NUMBER,
     TaxAmt                    NUMBER,
     FedExemptAmt              NUMBER,
     StExemptAmt               NUMBER,
     CntyExemptAmt             NUMBER,
     CityExemptAmt             NUMBER,
     DistExemptAmt             NUMBER,
     SecStExemptAmt            NUMBER,
     SecCnExemptAmt            NUMBER,
     SecLoExemptAmt            NUMBER,
     ContractAmt               NUMBER,
     InstallAmt                NUMBER,
     FrghtAmt                  NUMBER,
     DiscountAmt               NUMBER,
     CalcType                  CHAR(1),
     CreditInd                 BOOLEAN,
     NumItems                  NUMBER(7),
     ProdCode                  VARCHAR2(300),
     RoundInd                  BOOLEAN,
     GenInd                    BOOLEAN,
     /* This field may get deleted */
     BasisPerc                 NUMBER(6,5),
     InvoiceSumInd             BOOLEAN,
     MovementCode              CHAR(1),
     StorageCode               CHAR(1),
     ProdCodeConv              CHAR(1),
     ProdCodeType              CHAR(1),
     FedSlsUse                 CHAR(1),
     StaSlsUse                 CHAR(1),
     CnSlsUse                  CHAR(1),
     LoSlsUse                  CHAR(1),
     SecStSlsUse               CHAR(1),
     SecCnSlsUse               CHAR(1),
     SecLoSlsUse               CHAR(1),
     DistSlsUse                CHAR(1),
     NoTaxInd                  BOOLEAN, /* Changed from char to boolean by vv */
     NoFedTax                  BOOLEAN,
     NoStaTax                  BOOLEAN,
     NoCnTax                   BOOLEAN,
     NoLoTax                   BOOLEAN,
     NoSecCnTax                BOOLEAN,
     NoSecLoTax                BOOLEAN,
     NoSecStTax                BOOLEAN,
     NoDistTax                 BOOLEAN,

     Exempt                    BOOLEAN,
     FedExempt                 BOOLEAN,
     StaExempt                 BOOLEAN,
     CnExempt                  BOOLEAN,
     LoExempt                  BOOLEAN,
     SecStExempt               BOOLEAN,
     SecCnExempt               BOOLEAN,
     SecLoExempt               BOOLEAN,
     DistExempt                BOOLEAN,
     FedOvAmt                  NUMBER(14,2),
     FedOvPer                  NUMBER(5,5),
     StOvAmt                   NUMBER(14,2),
     StOvPer                   NUMBER(5,5),
     CnOvAmt                   NUMBER(14,2),
     CnOvPer                   NUMBER(5,5),
     LoOvAmt                   NUMBER(14,2),
     LoOvPer                   NUMBER(5,5),
     ScCnOvAmt                 NUMBER(14,2),
     ScCnOvPer                 NUMBER(5,5),
     ScLoOvAmt                 NUMBER(14,2),
     ScLoOvPer                 NUMBER(5,5),
     ScStOvAmt                 NUMBER(14,2),
     ScStOvPer                 NUMBER(5,5),
     DistOvAmt                 NUMBER(14,2),
     DistOvPer                 NUMBER(5,5),
     InvoiceDate               DATE,
     DropShipInd               BOOLEAN,
     EndInvoiceInd             BOOLEAN,
     CustNo                    VARCHAR2(20),
     CustName                  VARCHAR2(20),
     AFEWorkOrd                VARCHAR2(26),
     InvoiceNo                 VARCHAR2(20),
     InvoiceLineNo             NUMBER(5),
     PartNumber                VARCHAR2(20),
     FiscalDate                DATE,
     DeliveryDate              DATE,
     InOutCityLimits           CHAR(1),
     FedReasonCode             CHAR(2),
     StReasonCode              CHAR(2),
     CntyReasonCode            CHAR(2),
     CityReasonCode            CHAR(2),
     FedTaxCertNo              VARCHAR2(25),
     StTaxCertNo               VARCHAR2(25),
     CnTaxCertNo               VARCHAR2(25),
     LoTaxCertNo               VARCHAR2(25),
     FromState                 CHAR(2),
     CompanyID                 VARCHAR2(20),
     DivCode                   VARCHAR2(20),
     MiscInfo                  VARCHAR2(50),
     LocnCode                  VARCHAR2(13),
     CostCenter                VARCHAR2(10),
     CurrencyCd1               CHAR(3),
     CurrencyCd2               CHAR(3),
     CurrConvFact              VARCHAR2(15),
     UseNexproInd              CHAR(1),
     ExtraInd1                 BOOLEAN,
     ExtraInd2                 BOOLEAN,
     ExtraInd3                 BOOLEAN,
     AudFileType               CHAR(1),
     ReptInd                   BOOLEAN,
     OptFiles                  CHAR(1),
     GenCmplCd                 CHAR(2),
     FedCmplCd                 CHAR(2),
     StaCmplCd                 CHAR(2),
     CnCmplCd                  CHAR(2),
     LoCmplCd                  CHAR(2),
     ScStCmplCd                CHAR(2),
     ScCnCmplCd                CHAR(2),
     ScLoCmplCd                CHAR(2),
     DistCmplCd                CHAR(2),
     ExtraCmplCd1              CHAR(2),
     ExtraCmplCd2              CHAR(2),
     ExtraCmplCd3              CHAR(2),
     ExtraCmplCd4              CHAR(2),
     FedTxAmt                  NUMBER,
     StaTxAmt                  NUMBER,
     CnTxAmt                   NUMBER,
     LoTxAmt                   NUMBER,
     ScCnTxAmt                 NUMBER,
     ScLoTxAmt                 NUMBER,
     ScStTxAmt                 NUMBER,
     DistTxAmt                 NUMBER,
     FedTxRate                 NUMBER(5,5),
     StaTxRate                 NUMBER(5,5),
     CnTxRate                  NUMBER(5,5),
     LoTxRate                  NUMBER(5,5),
     ScCnTxRate                NUMBER(5,5),
     ScLoTxRate                NUMBER(5,5),
     ScStTxRate                NUMBER(5,5),
     DistTxRate                NUMBER(5,5),
     FedBasisAmt               NUMBER,
     StBasisAmt                NUMBER,
     CntyBasisAmt              NUMBER,
     CityBasisAmt              NUMBER,
     ScStBasisAmt              NUMBER,
     ScCntyBasisAmt            NUMBER,
     ScCityBasisAmt            NUMBER,
     DistBasisAmt              NUMBER,
     JobNo                     VARCHAR2(10),
     CritFlg                   CHAR(1),
     UseStep                   CHAR(1),
     StepProcFlg               CHAR(1),
     FedStatus                 CHAR(1),
     StaStatus                 CHAR(1),
     CnStatus                  CHAR(1),
     LoStatus                  CHAR(1),
     FedComment                CHAR(1),
     StComment                 CHAR(1),
     CnComment                 CHAR(1),
     LoComment                 CHAR(1),
     /* Added fields for R3.0 link structure */
     Volume                    VARCHAR2(15),
     VolExp                    CHAR(3),
     UOM                       VARCHAR2(15),
     BillToCustName            VARCHAR2(20),
     BillToCustId              VARCHAR2(20)
   );




   TYPE StepParm is RECORD
   (
      /* the following fields are input only */
     FuncCode               char,

     CompanyID              varchar2(20),
     CustNo                 varchar2(20),
     ProcFlag               char,
     StCode                 char(2),
     CntyName               varchar2(26),
     CntyCode               char(3),
     LoclName               varchar2(26) ,
     ProdCode               varchar2(300) ,
     JobNo                  varchar2(10) ,

     /* Possible other values used for STEPTEC key search */
     LocnCode               varchar2(13),
     CostCenter             varchar2(10),
     AFEWorkOrd             varchar2(26),
     InvoiceDate            DATE ,

     /* For new functionality */
     TaxType                char,
     CritFlg                char,
     LocAdmCity             char,
     LocAdmCnty             char,
     Tax010Flg              char ,
     SearchBy               char ,
     CreditInd              BOOLEAN,

     /*  the following fields can be input or output */
     FedReasCode            char(2),
     StReasCode             char(2),
     CntyReasCode           char(2),
     LoclReasCode           char(2),

     FedCertNo              varchar2( 25),
     StCertNo               varchar2( 25),
     CntyCertNo             varchar2( 25),
     LoclCertNo             varchar2( 25),

     BasisPerc              NUMBER(6,5),

     /* the following fields are output only */
     ReasFedMaxAmt          number(14,2),
     ReasStMaxAmt           number(14,2),
     ReasSecStMaxAmt        number(14,2),
     ReasCntyMaxAmt         number(14,2),
     ReasCityMaxAmt         number(14,2),
     ReasSecCntyMaxAmt      number(14,2),
     ReasSecCityMaxAmt      number(14,2),
     ReasDistMaxAmt         number(14,2),

     ReasFedMaxRate         number(5,5),
     ReasStMaxRate          number(5,5),
     ReasSecStMaxRate       number(5,5),
     ReasCntyMaxRate        number(5,5),
     ReasCityMaxRate        number(5,5),
     ReasSecCntyMaxRate     number(5,5),
     ReasSecCityMaxRate     number(5,5),
     ReasDistMaxRate        number(5,5),


     ReasFedMaxCode         char(2),
     ReasStMaxCode          char(2),
     ReasSecStMaxCode       char(2),
     ReasCntyMaxCode        char(2),
     ReasCityMaxCode        char(2),
     ReasSecCntyMaxCode     char(2),
     ReasSecCityMaxCode     char(2),
     ReasDistMaxCode        char(2),

     FedStat                char ,
     StStat                 char ,
     SecStStat              char ,
     CntyStat               char ,
     LoclStat               char ,
     SecCntyStat            char ,
     SecLoclStat            char ,
     DistStat               char ,

     FedComment             char ,
     StComment              char ,
     SecStComment           char ,
     CntyComment            char ,
     LoclComment            char ,
     SecCntyComment         char ,
     SecLoclComment         char ,
     DistComment            char ,

     FedRateInd             char ,
     StRateInd              char ,
     SecStRateInd           char ,
     CntyRateInd            char ,
     LoclRateInd            char ,
     SecCntyRateInd         char ,
     SecLoclRateInd         char ,
     DistRateInd            char ,

     FedRate                number(5,5),
     StRate                 number(5,5),
     SecStRate              number(5,5),
     CntyRate               number(5,5),
     LoclRate               number(5,5),
     SecCntyRate            number(5,5),
     SecLoclRate            number(5,5),
     DistRate               number(5,5)

   );








   TYPE  Location is RECORD
   (
     Country                   char(3),
     State                     CHAR(2),
     Cnty                      CHAR(3),
     City                      VARCHAR2(26),
     Zip                       CHAR(5),
     Geo                       CHAR(2),
     ZipExt                    VARCHAR2(4)
   );

   TYPE  JurParm  is RECORD
   (
     ShipFr                    Location,
     ShipTo                    Location,
     POA                       Location,
     POO                       Location,
     BillTo                    Location,
     POT                       CHAR(1),
     ServInd                   CHAR(1),
     InOutCiLimShTo            CHAR(1),
     InOutCiLimShFr            CHAR(1),
     InOutCiLimPOO             CHAR(1),
     InOutCiLimPOA             CHAR(1),
     InOutCiLimBiTo            CHAR(1),
     PlaceBusnShTo             CHAR(1),
     PlaceBusnShFr             CHAR(1),
     PlaceBusnPOO              CHAR(1),
     PlaceBusnPOA              CHAR(1),
     JurLocType                CHAR(1),
     JurState                  CHAR(2),
     JurCity                   VARCHAR2(26),
     JurZip                    CHAR(5),
     JurGeo                    CHAR(2),
     JurZipExt                 VARCHAR2(4),
     TypState                  CHAR(1),
     TypCnty                   CHAR(1),
     TypCity                   CHAR(1),
     TypDist                   CHAR(1),
     SecCity                   VARCHAR2(26),
     SecZip                    VARCHAR2(5),
     SecGeo                    CHAR(2),
     SecZipExt                 VARCHAR2(4),
     SecCounty                 CHAR(3),
     TypFed                    CHAR(1),
     TypSecState               CHAR(1),
     TypSecCnty                CHAR(1),
     TypSecCity                CHAR(1),
     ReturnCode                CHAR(2),
     POOJurRC                  CHAR(2),
     POAJurRC                  CHAR(2),
     ShpToJurRC                CHAR(2),
     ShpFrJurRC                CHAR(2),
     BillToJurRC               CHAR(2),
     EndLink                   CHAR(8)
   );

   TYPE CntySeq is RECORD
   (
     State                     CHAR(2),
     County                    CHAR(3),
     CntyName                  VARCHAR2(26)
   );

   /* Runtime Information Records */
   /*     State Table                */
   TYPE States is RECORD
   (
     StateNum                  NUMBER(2),
     StateAlp                  CHAR(2),
     StateNam                  VARCHAR2(26)
   );

   TYPE ConUseRec is RECORD
   (
     StateCode                 NUMBER(2),
     SalesOrUse                CHAR(1),
     StateInd                  CHAR(1),
     CntyInd                   CHAR(1),
     CityInd                   CHAR(1),
     SecCntyInd                CHAR(1),
     SecCityInd                CHAR(1),
     CustVendInd               char
   );


   TYPE DivisionCds is RECORD
   (
     code                      VARCHAR2(20),
     name                      VARCHAR2(20)
   );

   TYPE ReasonCds  is RECORD
   (
     ReasonCd                  CHAR(2),
     ShortDesc                 VARCHAR2(10),
     ReasonText                VARCHAR2(70)
   );

   TYPE  JurisCd is RECORD
   (
     StateCd                   CHAR(2),
     JurIntrCde                CHAR(2),
     JurCntyCde                CHAR(2),
     JurCityCde                CHAR(2),
     JurTrnsCde                CHAR(2),
     JurisCode                 CHAR(2)
   );


   /* Jurisdiction Descriptions  */
   TYPE  JurisCdDesc is RECORD
   (
     JurisCdType               CHAR(2),
     JurisCdNum                CHAR(2),
     JurisCdText               VARCHAR2(1500)
   );

   /*******************************  T A X I O . H*******/
   /* AccessType*/
   AccessType                  CHAR;
   READFILE                    CONSTANT CHAR :='r';
   WRITEFILE                   CONSTANT CHAR :='w';

   /* ReadType  */
   ReadType                    NUMBER;
   DIRREAD                     CONSTANT NUMBER :=  0;
   SEQREAD                     CONSTANT NUMBER := 1;

   /* Transit indicator  - TRANSTYPE */
   TRANSTYPE                   CHAR;
   TR_NO_TAX                   CONSTANT CHAR  :='0';
   TR_SALES_ONLY               CONSTANT CHAR  :='1';
   TR_SALES_USE                CONSTANT CHAR  :='2';

   /* Jurisdiction code types - JURISCT */
   JURISCT                     NUMBER;
   JURTYP_INTRA_INTER_STATE    CONSTANT NUMBER   := 0;
   JURTYP_COUNTY               CONSTANT NUMBER   := 1;
   JURTYP_CITY                 CONSTANT NUMBER   := 2;
   JURTYP_TRANSIT              CONSTANT NUMBER   := 3;
   JURTYP_TAXING               CONSTANT NUMBER   :=  4;

   /* Error Handling Constants - ERRTYPE   */
   ERRTYPE                     NUMBER;
   NoErr                       CONSTANT NUMBER   := 0;
   ParmErr                     CONSTANT NUMBER   := 4;
   DataErr                     CONSTANT NUMBER   := 5;
   LockErr                     CONSTANT NUMBER   := 7;
   UnLockErr                   CONSTANT NUMBER   := 8;
   UpdateErr                   CONSTANT NUMBER   := 10;
   SQLErr                      CONSTANT NUMBER   := 11;
   NegInputErr                 CONSTANT NUMBER   := 12;
   LargeAmtErr                 CONSTANT NUMBER   := 13;
   DataErr                     CONSTANT NUMBER   := 14;



   /* Constants for Parm Error Numbers */
   INVREADTYPE                 CONSTANT NUMBER := 1;
   INVRECTYPE                  CONSTANT NUMBER := 2;
   MAX_PARMERROR               CONSTANT NUMBER := 3;

   /* Constants for Product parm record errors */
   INVLDPRODPARMID             CONSTANT NUMBER := 1;
   INVLDPRODRANGESEL           CONSTANT NUMBER := 2;
   INVLDPRODRANGE              CONSTANT NUMBER := 3;
   INVLDPRODSTCODE             CONSTANT NUMBER := 4;
   INVLDPRODSTIND              CONSTANT NUMBER := 5;

   /* Constants for Data Error Numbers */
   INVDATE                     CONSTANT NUMBER := 1;
   INVSTCODE                   CONSTANT NUMBER := 2;
   DUPLREC                     CONSTANT NUMBER := 3;
   INVALIDDATA                 CONSTANT NUMBER := 4;
   LREADERROR                  CONSTANT NUMBER := 5;
   LWRITEERROR                 CONSTANT NUMBER := 6;
   INVNEXCODE                  CONSTANT NUMBER := 7;
   INVSTCONV                   CONSTANT NUMBER := 8;
   MAX_DATAERROR               CONSTANT NUMBER := 8;

   /* I/O Operations */
   READFUNC                    CONSTANT NUMBER := 1;
   WRITEFUNC                   CONSTANT NUMBER := 2;
   SQLFUNC                     CONSTANT NUMBER := 3;


   /* Current/Prior Tax Rate Structure */

   TYPE  TaxInfo is RECORD
   (
/*
 * NOTE: KMIZUTA Changed the following line from Date to Date1
 * Needs to be confirmed.
 */
     Date1                      DATE,
     SalesRat                  NUMBER(5,5),
     UseRate                   NUMBER(5,5),
     SpecRate                  NUMBER(5,5)
   );


   TYPE   StateEntry  is RECORD
   (
     StateCode                 NUMBER(2),
     StateAlpha                CHAR(2),
     StateName                 VARCHAR2(26),
     ValidState                BOOLEAN,
     CtyTxInd                  BOOLEAN,
     LclTxInd                  BOOLEAN,
     CtyTrInd                  CHAR(1),/*change by vv from b*/
     LclTrInd                  CHAR(1),/*change by vv from b*/
     MaxTax                    NUMBER(5,5),
     JurCode                   CHAR(1),
     AdminCd                   CHAR(1),
     JurIntrCde                CHAR(2),
     JurCntyCde                CHAR(2),
     JurCityCde                CHAR(2),
     JurTrnsCde                CHAR(2),
     JurisCode                 CHAR(2),
     ProcessInvZp              BOOLEAN,
     TaxByItem                 BOOLEAN,
     TaxFreight                BOOLEAN,
     RentalCode                CHAR(1)
   );

   /********************T A X V A L I D . H*************************/

   /* State Code Limits */
   MINSTCD                     CONSTANT CHAR(2) := '01';
   MAXSTCD                     CONSTANT CHAR(2) := '99';
   MAXSTINT                    CONSTANT NUMBER := 100;

   /* Amount and Rate Constants */
   RATEMULT                    CONSTANT NUMBER(6,5) :=  0.00001;
   AMTMULT                     CONSTANT NUMBER(6,5) :=  0.01;
   CONVMULT                    CONSTANT NUMBER(6,5) :=  0.001;
   AUDIT_TAX_AMT_MULT          CONSTANT NUMBER(6,5) :=  0.001;
   NOAMT                       CONSTANT NUMBER(6,5) :=  0.00;
   NORATE                      CONSTANT NUMBER(6,5) :=  0.00000;
   ZEROAMT                     CONSTANT NUMBER(6,5) :=  0.00;
   ZERORATE                    CONSTANT NUMBER(6,5) :=  0.00000;
   /* EPSILON                     CONSTANT NUMBER(6,5) :=  0.000005; */

   /* APO/FPO Location Names */
   APO                         CONSTANT CHAR(4) := 'APO ';
   FPO                         CONSTANT CHAR(3) := 'FPO';


   /* State Code Constants for States with Special Processing */
   TheStates                   NUMBER;
   ALABAMA                     CONSTANT  NUMBER   :=  1;
   ALASKA                      CONSTANT  NUMBER   :=  2;
   ARIZONA                     CONSTANT  NUMBER   :=  3;
   ARKANSAS                    CONSTANT  NUMBER   :=  4;
   CALIFORNIA                  CONSTANT  NUMBER   :=  5;
   CANADA                      CONSTANT  NUMBER   :=  52;
   COLORADO                    CONSTANT  NUMBER   :=  6;
   DELAWARE                    CONSTANT  NUMBER   :=  8;
   FLORIDA                     CONSTANT  NUMBER   :=  10;
   HAWAII                      CONSTANT  NUMBER   :=  12;
   ILLINOIS                    CONSTANT  NUMBER   :=  14;
   INTERNTL                    CONSTANT   NUMBER  :=  53;
   LOUISIANA                   CONSTANT  NUMBER   :=  19;
   MISSOURI                    CONSTANT  NUMBER   :=  26;
   NEW_YORK                    CONSTANT   NUMBER  :=  33;
   NORTH_DAKOTA                CONSTANT   NUMBER  :=  35;
   TEXAS                       CONSTANT   NUMBER  :=  44;
   TENNESSEE                   CONSTANT   NUMBER  :=  43;
   UTAH                        CONSTANT   NUMBER  :=  45;

   /* Miscellaneous */
   MAX_REASONS                 CONSTANT NUMBER :=  48;

   /* Tax Master File Record Indicators */
   CNTYRECS                    CONSTANT CHAR :=  'Y';
   CITYRECS                    CONSTANT CHAR :=  'Y';

   /* TMRECTYPE */
   TMRECTYPE                   CHAR;
   STRECTYP                    CONSTANT CHAR   :=  '1';
   CNRECTYP                    CONSTANT CHAR   :=  '2';
   LORECTYP                    CONSTANT CHAR   :=  '3' ;

   /* File:    TAXIODB.H  */
   TYPE TaxStKey IS RECORD
   (
      StateCd                  CHAR(2)
   );

   TYPE  TaxCnKey IS RECORD
   (
     StateCd                   CHAR(2),
     CntyCd                    CHAR(3)
   );

   TYPE TaxLoKey IS RECORD
   (
     StateCd                   CHAR(2),
     ZipCode                   CHAR(5),
     GeoCode                   CHAR(2)
   );

   TYPE TFTaxMst IS RECORD
   (
     AdminCd                   CHAR(1),
     CurrentRates              TaxInfo,
     PriorRates                TaxInfo
   );

   TYPE TSTaxMst IS RECORD
   (
     Key                       TaxStKey,
     StateNm                   VARCHAR2(26),
     CtyTxInd                  BOOLEAN,
     LclTxInd                  BOOLEAN,
     CtyTrInd                  CHAR(1),/*change by vv from b*/
     LclTrInd                  CHAR(1),/*change by vv fr b */
     CurrTax                   TaxInfo,
     PriorTax                  TaxInfo,
     MaxTax                    NUMBER(5,5),
     JurCode                   CHAR(1),
     AdminCd                   CHAR(1)
   );

   TYPE TCTaxMst IS RECORD
   (
     Key                       TaxCnKey ,
     CntyName                  VARCHAR2(26),
     CurrTax                   TaxInfo,
     PriorTax                  TaxInfo,
     AdminCd                   CHAR(1),
     TaxCode                   VARCHAR2(10),
     ExcpCode                  CHAR(1)
   );

   TYPE ZipExtRegTyp IS RECORD
   (
     First                     VARCHAR2(4),
     Last                      VARCHAR2(4)
   );

   TYPE  TLTaxMst IS RECORD
   (
     Key                       TaxLoKey ,
     LocName                   VARCHAR2(26),
     CntyCode                  CHAR(3),
     Duplicates                CHAR(1),
     CurrTax                   TaxInfo,
     PriorTax                  TaxInfo,
     CtyTxInd                  BOOLEAN,
     ZipExtReg                 ZipExtRegTyp,
     AdminCd                   CHAR(1),
     TaxCode                   VARCHAR2(10),
     ExcpCode                  CHAR(1)
   );

   /* Product Records */
   TYPE ProdFlgs IS RECORD
   (
     MaxTax                    BOOLEAN,
     RecCity                   BOOLEAN,
     RecCnty                   BOOLEAN,
     TaxState                  CHAR(1),
     TaxCity                   CHAR(1),
     TaxCnty                   CHAR(1),
     TaxTran                   CHAR(1)
   );

   TYPE PrdStKeyTyp IS RECORD
   (
     ProdCode                  CHAR(5),
     StateCd                   NUMBER(2)
   );

   TYPE PrdCnKeyTyp IS RECORD
   (
     ProdCode                  CHAR(5),
     StateCd                   NUMBER(2),
     CntyCode                  CHAR(3)
   );

   TYPE PrdLoKeyTyp IS RECORD
   (
     ProdCode                  CHAR(5),
     StateCd                   NUMBER(2),
     CityName                  VARCHAR2(26)
   );

   /* Union - ProdKey  */
   TYPE ProdKeyTyp IS RECORD
   (
     State                     PrdStKeyTyp,
     County                    PrdCnKeyTyp,
     Local                     PrdLoKeyTyp
   );

   TYPE MaxTaxTyp IS RECORD
   (
     CurrAmt                   NUMBER(14,2),
     PriorAmt                  NUMBER(14,2),
     MaxCurr                   NUMBER(14,2),
     MaxPrior                  NUMBER(14,2),
     CurrRt1                   NUMBER(5,5),
     PriorRt1                  NUMBER(5,5),
     CurrRt2                   NUMBER(5,5),
     PriorRt2                  NUMBER(5,5),
     EffDate                   DATE,
     CurrCode                  CHAR(2),
     PriorCd                   CHAR(2)
   );

   TYPE ProdData IS RECORD
   (
     CurrRat                   NUMBER(5,5),
     PriorRat                  NUMBER(5,5),
     EffDate                   DATE,
     MaxTax                    MaxTaxTyp,
     ProdDesc                  VARCHAR2(12)
   );

   TYPE ProdRec IS RECORD
   (
     Key                       ProdKeyTyp,
     Data                      ProdData,
     Flags                     ProdFlgs
   );

   TYPE ProdStPF IS RECORD
   (
     Key                       PrdStKeyTyp,
     Data                      ProdData,
     Flags                     ProdFlgs
   );

   TYPE ProdCnPF IS RECORD
   (
     Key                       PrdCnKeyTyp,
     Data                      ProdData
   );

   TYPE ProdLoPF IS RECORD
   (
     Key                       PrdLoKeyTyp,
     Data                      ProdData
   );

   /*  Product Conversion Records */
   TYPE prodcode_data is RECORD
   (
     CompanyId                 VARCHAR2(20),
     BusnLocn                  VARCHAR2(13),
     UserPrCode1               VARCHAR2(25),
     UserPrCode2               VARCHAR2(25),
     AvpPrCode                 VARCHAR2(9)
   );

   /******************************N E X P R O ************************/

   /* if defined _TOOLKIT || defined _NEXPRO */
   MAXNEXINT                   CONSTANT INT := 20;
  /* used for array of nexus data */
   /* endif */

   /* if defined SYSCTRL_USE_STEP */
   StepInstalled               BOOLEAN; /* Added by VV */
   /* End if */

   /* Constants for key selection */
   COMPRFILE                   CONSTANT CHAR := 'c' ;
   STNEXFILE                   CONSTANT CHAR := 's' ;
   LONEXFILE                   CONSTANT CHAR := 'l' ;

   /* Enumerated data types -   MPRECTYPE */
   MPRECTYPE                   CHAR;
   MPRECTYP                    CONSTANT CHAR := '1' ;
   SNRECTYP                    CONSTANT CHAR := '2' ;
   LNRECTYP                    CONSTANT CHAR := '3' ;


   /*      NETIODB.H                   */
   TYPE merchant_profileTyp IS RECORD
   (
     compmastind               CHAR(1),
     merchantid                VARCHAR2(20),
     blstatecode               NUMBER(2),
     busnlocn                  VARCHAR2(13),
     costcenter                VARCHAR2(10),
     division                  VARCHAR2(20),
     blzipcode                 CHAR(5),
     blgeocode                 CHAR(2),
     blcityname                VARCHAR2(26),
     blcountycode              CHAR(3),
     blcountyname              VARCHAR2(26),
     servind                   CHAR(1),
     bleffectdate              DATE,
     blexpdate                 DATE,
     usejuris                  CHAR(1),
     useaudit                  CHAR(1),
     taxall                    CHAR,
     usemastnexus              CHAR(1),
     audname                   VARCHAR2(20),
     sfstate                   NUMBER(2),
     sfzip                     CHAR(5),
     sfgeo                     CHAR(2),
     sfcity                    VARCHAR2(26),
     sfcountycode              CHAR(3),
     sfcountyname              VARCHAR2(26),
     sfplacebusn               CHAR(1),
     sfservind                 CHAR(1),
     /* char outside city */
     poostate                  NUMBER(2),
     poozip                    CHAR(5),
     poogeo                    CHAR(2),
     poocity                   VARCHAR2(26),
     poocntycode               CHAR(3),
     poocntyname               VARCHAR2(26),
     pooplacebusn              CHAR(1),
     pooservind                CHAR(1),
     poastate                  NUMBER(2),
     poazip                    CHAR(5),
     poageo                    CHAR(2),
     poacity                   VARCHAR2(26),
     poacntycode               CHAR(3),
     poacntyname               VARCHAR2(26),
     poaplacebusn              CHAR(1),
     poaservind                CHAR(1),
     useerrorfile              CHAR(1),
     stepflag                  CHAR(1),
     stepexpflag               CHAR(1),
     optflags1                 VARCHAR2(50),
     optflags2                 VARCHAR2(50),
     optflags3                 VARCHAR2(50)
   );

   /* State Nexus Record */
   TYPE stnexusTyp IS RECORD
   (
     merchantid                VARCHAR2(20),
     state                     NUMBER(2),
     busnlocn                  VARCHAR2(13),
     nexuscode                 CHAR(1)
   );

   /* Local Nexus File Structure  */
   TYPE loclnexusTyp IS RECORD
   (
     merchantid                VARCHAR2(20),
     state                     NUMBER(2),
     rectype                   CHAR(1),
     name                      VARCHAR2(26),
     busnlocn                  VARCHAR2(13)
   );

   /*Product conversion table Record */
   TYPE  userprod_data IS RECORD
   (
     merchantid                VARCHAR2(20),
     busnlocn                  VARCHAR2(13),
     usercode1                 VARCHAR2(25),
     usercode2                 VARCHAR2(25),
     taxcode                   VARCHAR2(9)
   );

   /* NETIOSEQ.H */
   /* Merchant Profile/State Nexus/ Local Nexus Records */
   /* For AVP's testing purposes only!! */

   /* Union - RecInfo     Struct - MP  */

   TYPE RecInfoMPTyp IS RECORD
   (
     blstatecode               NUMBER(2),
     busnlocn                  VARCHAR2(13),
     costcenter                VARCHAR2(10),
     division                  VARCHAR2(20),
     blzipcode                 CHAR(5),
     blgeocode                 CHAR(2),
     blcityname                VARCHAR2(26),
     blcountycode              CHAR(3),
     blcountyname              VARCHAR2(26),
     servind                   CHAR(1),
     bleffectdate              DATE,
     blexpdate                 DATE,
     usejuris                  CHAR(1),
     useaudit                  CHAR(1),
     taxall                    CHAR,
     usemastnexus              CHAR(1),
     audname                   VARCHAR2(20),
     sfstate                   NUMBER(2),
     sfzip                     CHAR(5),
     sfgeo                     CHAR(2),
     sfcity                    VARCHAR2(26),
     sfcountycode              CHAR(3),
     sfcountyname              VARCHAR2(26),
     sfplacebusn               CHAR(1),
     sfservind                 CHAR(1),
     poostate                  NUMBER(2),
     poozip                    CHAR(5),
     poogeo                    CHAR(2),
     poocity                   VARCHAR2(26),
     poocntycode               CHAR(3),
     poocntyname               VARCHAR2(26),
     pooplacebusn              CHAR(1),
     pooservind                CHAR(1),
     poastate                  NUMBER(2),
     poazip                    CHAR(5),
     poageo                    CHAR(2),
     poacity                   VARCHAR2(26),
     poacntycode               CHAR(3),
     poacntyname               VARCHAR2(26),
     poaplacebusn              CHAR(1),
     poaservind                CHAR(1),
     useerrorfile              CHAR(1),
     stepflag                  CHAR(1),
     stepexpflag               CHAR(1),
     optflags                  VARCHAR2(50)
   );

   /* Union - RecInfo     Struct - SN  */
   TYPE RecInfoSNTyp IS RECORD
   (
     state                     NUMBER(2),
     /*  if defined _NEXPRO  */
     busnlocn                  VARCHAR2(13),
     nexuscode                 CHAR(1)
    /* endif */
   );

   /* Union - RecInfo     Struct - LN  */
   TYPE RecInfoLNTyp IS RECORD
   (
     state                     NUMBER(2),
     rectype                   CHAR(1),
     name                      VARCHAR2(26),
     /*if defined _NEXPRO */
     busnlocn                  VARCHAR2(13)
    /* endif */
   );

   TYPE NetMstCh IS RECORD
   (
     TransCode                 CHAR(1),
     /*  if defined _NEXPRO  */
     compmastind               CHAR(1),
     /*  endif  */
     MerchantID                VARCHAR2(20),
     RecType                   CHAR(1),
     /* Union - RecInfo */
     RecInfoMP                 RecInfoMPTyp,
     RecInfoSN                 RecInfoSNTyp,
     RecInfoLN                 RecInfoLNTyp
   );

   /* start here if defined _NEXPRO  */
   /* NexusCode Table and Local Admin Data Structures        */
   /* For AVP's testing purposes only!!                    */

   TYPE nexcodedata IS RECORD
   (
     NexusCode                 CHAR(1),
     NexusDesc                 CHAR(256)
   );

   TYPE localadmndata IS RECORD
   (
     StateAlphaCode            NUMBER(2),
     StateCode                 NUMBER(2),
     rectype                   CHAR(1),
     LocName                   VARCHAR2(26)
   );

   /*  Pointer Handling generic overloaded Procedures  */
   PROCEDURE TAXSP_CopyRec( CnRec  TCTaxMst, RecFlag CHAR);
   PROCEDURE TAXSP_CopyRec( LoRec  TLTaxMst, RecFlag CHAR);

END ZX_TAX_TAXWARE_GEN_STUB;

/
