--------------------------------------------------------
--  DDL for Package ZX_TAX_TAXWARE_010_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_TAXWARE_010_STUB" AUTHID CURRENT_USER AS
/* $Header: zxtxw10s.pls 120.1 2005/09/23 02:03:00 svaze ship $ */

   FUNCTION TAXFN_release_number RETURN VARCHAR2;


   FUNCTION  TAXFN_TAX010( TxParm     IN OUT NOCOPY ZX_TAX_TAXWARE_GEN_STUB.TaxParm,
                           TSelParm   IN OUT NOCOPY CHAR,
                           JrParm     IN OUT NOCOPY ZX_TAX_TAXWARE_GEN_STUB.JurParm
                         ) RETURN  BOOLEAN;

   FUNCTION  TAXFN_TAX010( OrParm     IN OUT NOCOPY ZX_TAX_TAXWARE_GEN_STUB.t_OraParm,
                           TxParm     IN OUT NOCOPY ZX_TAX_TAXWARE_GEN_STUB.TaxParm,
                           TSelParm   IN OUT NOCOPY CHAR,
                           JrParm     IN OUT NOCOPY ZX_TAX_TAXWARE_GEN_STUB.JurParm
                         ) RETURN  BOOLEAN;


   FUNCTION  TAXFN910_ValidErr( GenCmplCd     IN CHAR
                               ) RETURN BOOLEAN;

   TaxLink                     ZX_TAX_TAXWARE_GEN_STUB.TaxParm;
   JurLink                     ZX_TAX_TAXWARE_GEN_STUB.JurParm;
   TaxSelParm                  CHAR;

   TaxFlags                    ZX_TAX_TAXWARE_GEN_STUB.TaxFlagsType;
   JurFlags                    ZX_TAX_TAXWARE_GEN_STUB.JurFlagsType;

   Federal_Record              ZX_TAX_TAXWARE_GEN_STUB.TFTaxMst;
   County_Record               ZX_TAX_TAXWARE_GEN_STUB.TCTaxMst;
   Secondary_County_Record     ZX_TAX_TAXWARE_GEN_STUB.TCTaxMst;
   Local_Record                ZX_TAX_TAXWARE_GEN_STUB.TLTaxMst;
   Secondary_Local_Record      ZX_TAX_TAXWARE_GEN_STUB.TLTaxMst;

   SFCounty                    ZX_TAX_TAXWARE_GEN_STUB.TCTaxMst;
   SFLocal                     ZX_TAX_TAXWARE_GEN_STUB.TLTaxMst;
   STCounty                    ZX_TAX_TAXWARE_GEN_STUB.TCTaxMst;
   STLocal                     ZX_TAX_TAXWARE_GEN_STUB.TLTaxMst;
   POOCounty                   ZX_TAX_TAXWARE_GEN_STUB.TCTaxMst;
   POOLocal                    ZX_TAX_TAXWARE_GEN_STUB.TLTaxMst;
   POACounty                   ZX_TAX_TAXWARE_GEN_STUB.TCTaxMst;
   POALocal                    ZX_TAX_TAXWARE_GEN_STUB.TLTaxMst;

   TYPE   StateTblTyp  IS   TABLE  OF ZX_TAX_TAXWARE_GEN_STUB.StateEntry
   INDEX  BY  BINARY_INTEGER;

   StateTbl                    StateTblTyp;

   TYPE   StateTblCurrTaxTyp  IS   TABLE  OF ZX_TAX_TAXWARE_GEN_STUB.TaxInfo
   INDEX  BY  BINARY_INTEGER;

   StateTblCurrTax             StateTblCurrTaxTyp;

   TYPE   StateTblPriorTaxTyp  IS   TABLE  OF ZX_TAX_TAXWARE_GEN_STUB.TaxInfo
   INDEX  BY  BINARY_INTEGER;

   StateTblPriorTax             StateTblPriorTaxTyp;


   TYPE   ConUseRecTyp   IS   TABLE   OF    ZX_TAX_TAXWARE_GEN_STUB.ConUseRec
   INDEX   BY  BINARY_INTEGER;

   CUdataTbl                   ConUseRecTyp;

   STState                     NUMBER := 0;
   SFState                     NUMBER := 0;
   POOState                    NUMBER := 0;
   POAState                    NUMBER := 0;
   StateCodeN                  NUMBER;
   UseStep                     BOOLEAN;
   UseNexpro                   BOOLEAN;
   UseProduct                  BOOLEAN;
   UseError                    BOOLEAN ;
   ZeroOvAmt                   BOOLEAN := TRUE;
   Sys_Date                     DATE;

END ZX_TAX_TAXWARE_010_STUB;

 

/
