--------------------------------------------------------
--  DDL for Package JL_GLOBE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_GLOBE_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: jlgutils.pls 120.2.12010000.2 2009/06/04 06:34:36 vspuli noship $ */



  /**************************************************************************
   *                                                                        *
   * Name       : populate_icx_trx_reason_code                                                     *
   * Purpose    : Writes the p_line in a system file                        *
   *                                                                        *
   **************************************************************************/

   FUNCTION populate_icx_trx_reason_code (
      p_org_id              IN   NUMBER,
      p_item_id             IN   NUMBER,
      p_deliver_to_org_id   IN   NUMBER
   )
      RETURN VARCHAR2;



  /**************************************************************************
   *                                                                        *
   * Name       : populate_po_trx_reason_code                                                     *
   * Purpose    : Writes the p_line in a system file                        *
   *                                                                        *
   **************************************************************************/

   PROCEDURE populate_po_trx_reason_code(p_level_id IN NUMBER,
                                   p_org_id number);
  /**************************************************************************
   *                                                                        *
   * Name       : debug                                                     *
   * Purpose    : Writes the p_line in a system file                        *
   *                                                                        *
   **************************************************************************/
   PROCEDURE DEBUG (p_line IN VARCHAR2);



END;

/
