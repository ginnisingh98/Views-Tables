--------------------------------------------------------
--  DDL for Package JG_GLOBE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_GLOBE_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: jggutils.pls 120.0.12010000.2 2009/06/17 10:26:18 vspuli noship $ */


   /**************************************************************************
    *                                                                        *
    * Name       : process_po_globe_event                                                     *
    * Purpose    : Process line level global events from PO module          *
    *                                                                        *
    **************************************************************************/

   PROCEDURE process_po_globe_event (
      p_document_type   IN   VARCHAR2,
      p_level_type      IN   VARCHAR2,
      p_level_id        IN   NUMBER
   );


   /**************************************************************************
    *                                                                        *
    * Name       : process_icx_line_globe_event                                                     *
    * Purpose    : Process line level global events from ICX module          *
    *                                                                        *
    **************************************************************************/
   function process_icx_line_globe_event (
      p_org_id              IN              NUMBER,
      p_item_id             IN              NUMBER,
      p_deliver_to_org_id   IN              NUMBER)
      return    VARCHAR2;

   /**************************************************************************
    *                                                                        *
    * Name       : debug                                                     *
    * Purpose    : Writes the p_line in a system file                        *
    *                                                                        *
    **************************************************************************/
   PROCEDURE DEBUG (p_line IN VARCHAR2);
END;


/
