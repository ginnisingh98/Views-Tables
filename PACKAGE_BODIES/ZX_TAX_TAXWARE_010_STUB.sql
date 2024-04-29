--------------------------------------------------------
--  DDL for Package Body ZX_TAX_TAXWARE_010_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAX_TAXWARE_010_STUB" AS
/* $Header: zxtxw10b.pls 120.1 2005/09/23 02:04:51 svaze ship $ */

   FUNCTION  TAXFN_TAX010( TxParm     IN OUT NOCOPY ZX_TAX_TAXWARE_GEN_STUB.TaxParm,
                           TSelParm   IN OUT NOCOPY CHAR,
                           JrParm     IN OUT NOCOPY ZX_TAX_TAXWARE_GEN_STUB.JurParm
                         ) RETURN  BOOLEAN IS
   BEGIN
    RETURN NULL;
   END;

   FUNCTION  TAXFN_TAX010( OrParm     IN OUT NOCOPY ZX_TAX_TAXWARE_GEN_STUB.t_OraParm,
                           TxParm     IN OUT NOCOPY ZX_TAX_TAXWARE_GEN_STUB.TaxParm,
                           TSelParm   IN OUT NOCOPY CHAR,
                           JrParm     IN OUT NOCOPY ZX_TAX_TAXWARE_GEN_STUB.JurParm
                         ) RETURN  BOOLEAN IS
   BEGIN
    RETURN NULL;
   END;


   FUNCTION  TAXFN910_ValidErr( GenCmplCd     IN CHAR
                               ) RETURN BOOLEAN IS
   BEGIN
    RETURN NULL;
   END;

   FUNCTION TAXFN_release_number return VARCHAR2 is
   BEGIN
     RETURN NULL;
   END;
END ZX_TAX_TAXWARE_010_STUB;

/
