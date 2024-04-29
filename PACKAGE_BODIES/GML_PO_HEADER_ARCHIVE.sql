--------------------------------------------------------
--  DDL for Package Body GML_PO_HEADER_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_PO_HEADER_ARCHIVE" AS
/* $Header: GMLPOHAB.pls 120.1 2005/09/30 13:41:34 pbamb noship $ */

  v_segment1            VARCHAR2(32);
  v_revision_num        NUMBER;
  v_agent_id            PO_HEADERS_ALL.AGENT_ID%TYPE;
  v_bill_to_location_id PO_HEADERS_ALL.BILL_TO_LOCATION_ID%TYPE;
  v_terms_id            PO_HEADERS_ALL.TERMS_ID%TYPE;
  v_freight_code        PO_HEADERS_ALL.FREIGHT_TERMS_LOOKUP_CODE%TYPE;
  v_fob_code            PO_HEADERS_ALL.FOB_LOOKUP_CODE%TYPE;
  v_carrier_code        PO_HEADERS_ALL.SHIP_VIA_LOOKUP_CODE%TYPE;
  v_po_header_id        PO_HEADERS_ALL.PO_HEADER_ID%TYPE;
  err_num               NUMBER;
  err_msg               VARCHAR2(100);

/*========================================================================+
 | PROCEDURE    store                                                     |
 |                                                                        |
 | DESCRIPTION  Stores po_no, revision_num, agent_id and bill_to_location |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   6-DEC-97  Kenny  ---  Created.                                       |
 |  13-MAY-99  NC     ---  Added terms_id,freight_code.fob_code and       |
 |                         carrier_code (Bug #788658).                    |
 |                                                                        |
 |   03-27-00 HW BUG#:1222249  store po_header_id                         |
 +========================================================================*/

  PROCEDURE store(p_segment1 IN VARCHAR2, p_revision_num IN NUMBER,
            p_agent_id IN PO_HEADERS_ALL.AGENT_ID%TYPE,
            p_bill_to_location_id IN PO_HEADERS_ALL.BILL_TO_LOCATION_ID%TYPE,
            p_terms_id IN  PO_HEADERS_ALL.TERMS_ID%TYPE,
            p_freight_code IN PO_HEADERS_ALL.FREIGHT_TERMS_LOOKUP_CODE%TYPE,
            p_fob_code IN PO_HEADERS_ALL.FOB_LOOKUP_CODE%TYPE,
            p_carrier_code IN PO_HEADERS_ALL.SHIP_VIA_LOOKUP_CODE%TYPE,
            p_po_header_id IN PO_LINE_LOCATIONS_ARCHIVE_ALL.PO_HEADER_ID%TYPE)
  AS
  BEGIN
    v_segment1            := p_segment1;
    v_revision_num        := p_revision_num;
    v_agent_id            := p_agent_id;
    v_bill_to_location_id := p_bill_to_location_id;
    v_terms_id            := p_terms_id;
    v_freight_code        := p_freight_code;
    v_fob_code            := p_fob_code;
    v_carrier_code        := p_carrier_code;
    v_po_header_id        := p_po_header_id ;

  END;


 /*=======================================================================+
 | PROCEDURE     process                                                  |
 |                                                                        |
 | DESCRIPTION   This procedure checks if agent_id or bill to location id |
 |               is different from that of a previous revision. If so,    |
 |               resubmit the PO by calling the resubmission procedure.   |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   5-DEC-97  Kenny  --- Created.                                        |
 |  13-MAY-99  NC     --- Modified to call resub() when terms_id,fob_code,|
 |                        carrier_code and freight_code are changed.      |
 |                        (Bug #788658).                                  |
 |                                                                        |
 |  03-27-00 HW BUG#:1222249 - Find the proper PO to synch                |
 |                        and fix problem with mutating by not retrieving |
 |                        any info from po_headers_archive_all            |
 +========================================================================*/

  PROCEDURE process
  AS
    v_old_agent_id              PO_HEADERS_ALL.AGENT_ID%TYPE;
    v_old_bill_to_location_id   PO_HEADERS_ALL.BILL_TO_LOCATION_ID%TYPE;
    v_old_terms_id              PO_HEADERS_ALL.TERMS_ID%TYPE;
    v_old_freight_code          PO_HEADERS_ALL.FREIGHT_TERMS_LOOKUP_CODE%TYPE;
    v_old_fob_code              PO_HEADERS_ALL.FOB_LOOKUP_CODE%TYPE;
    v_old_carrier_code          PO_HEADERS_ALL.SHIP_VIA_LOOKUP_CODE%TYPE;
    v_from_date                 VARCHAR2(13) := SYSDATE;
    v_to_date                   VARCHAR2(13) := SYSDATE;
    errbuf                      VARCHAR2(80);
    retcode                     number;
    v_po_line_id                PO_LINE_LOCATIONS_ARCHIVE_ALL.PO_LINE_ID%TYPE;
    v_ship_to_location_id       PO_LINE_LOCATIONS_ARCHIVE_ALL.SHIP_TO_LOCATION_ID%TYPE;
    v_line_location_id          PO_LINE_LOCATIONS_ARCHIVE_ALL.LINE_LOCATION_ID%TYPE;

    /* Cursor to get old agent id and bill to location id */
/* HW BUG#:1222249 */
/* This cursor causes a mutation problem */
/*

    CURSOR po_headers_archive_cur(p_segment1 VARCHAR2,
                                  p_revision_num NUMBER) IS
    SELECT agent_id,
     bill_to_location_id,
     terms_id,
     freight_terms_lookup_code,
     fob_lookup_code,
     ship_via_lookup_code

    FROM   po_headers_archive_all
    WHERE  segment1     = p_segment1
    AND    revision_num = p_revision_num;
*/
/* BUG#:1132943 retrieve the correct line */

  CURSOR line_loc_cur IS
  SELECT po_line_id,ship_to_location_id,line_location_id
  FROM   po_line_locations_archive_all
  WHERE  po_header_id = v_po_header_id  ;


  BEGIN

    IF v_revision_num > 0 THEN
/* BUG#:1222249  commented out the call to cursor */
/* and the resub routine. Just call GML_PO_INTERFACE.insert_rec  */

/*
      OPEN  po_headers_archive_cur(v_segment1, v_revision_num-1);
      FETCH po_headers_archive_cur
      INTO  v_old_agent_id,
            v_old_bill_to_location_id,
            v_old_terms_id,
            v_old_freight_code,
            v_old_fob_code,
            v_old_carrier_code;

      CLOSE po_headers_archive_cur;

      IF (v_agent_id  <> v_old_agent_id) OR
	 (v_bill_to_location_id <> v_old_bill_to_location_id) OR
         (v_terms_id  <> v_old_terms_id) OR
         (v_freight_code  <> v_old_freight_code) OR
         (v_fob_code  <> v_old_fob_code) OR
         (v_carrier_code  <> v_old_carrier_code) THEN

          GML_PO_CON_REQ.po_resub(errbuf, retcode, v_from_date, v_to_date, v_segment1);
*/

      OPEN line_loc_cur ;
      FETCH line_loc_cur INTO v_po_line_id,v_ship_to_location_id,v_line_location_id;
      CLOSE line_loc_cur;
      GML_PO_INTERFACE.insert_rec (v_po_header_id,
                               v_po_line_id,
                               v_line_location_id,
                               null,
                               null,
                               null,
                               null,
                               null,
                               null,
                               null,
                               null,
                               'N',
                               null,
                               v_ship_to_location_id, null);
  /* Fire the CPG Purchasing Synchronization Concurrent Request */
  GML_PO_CON_REQ.fire_request;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    raise_application_error(-20000,SQLERRM);
  END;

END GML_PO_HEADER_ARCHIVE;

/
