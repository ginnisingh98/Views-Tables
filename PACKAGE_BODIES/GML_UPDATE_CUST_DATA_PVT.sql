--------------------------------------------------------
--  DDL for Package Body GML_UPDATE_CUST_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_UPDATE_CUST_DATA_PVT" AS
/*  $Header: GMLCUSYB.pls 120.2 2006/11/20 20:03:23 plowe noship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMLCUSYB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package body contains code to update cust_id in OPM            |
 |     Tables so that after customer synchronization is eliminated the     |
 |     CUST_ID properly matches those in Customer tables on APPS side.     |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     26-JAN-2005  PKANETKA        Created                                |
 |     14-NOV-2006  PLOWE           Bug 5651374                            |
 +=========================================================================+
   API Name  : GML_UPDATE_CUST_DATA_PVT
  Type      : Private
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/

/* ======================================================================= */
/*  Function to get equivalent Bill To ID customer id on Apps side for a   */
/*  cust_id in op_cust_mst_opm  passed to it.                              */
/* ======================================================================= */

FUNCTION GET_BILLCUST_ID
 (
  p_opm_cust_id IN NUMBER
 )
 RETURN NUMBER IS

 l_billcust_id NUMBER;
 BEGIN

   SELECT a.cust_id INTO l_billcust_id
   FROM   op_cust_mst_v a, op_cust_mst_opm b
   WHERE  a.cust_no = b.cust_no
    			AND a.of_cust_id = b.of_cust_id    --Bug 5651374 Performance issue.
          AND a.co_code = b.co_code
          AND b.cust_id = p_opm_cust_id
          AND b.bill_ind = 1
          AND rownum < 2;

   RETURN l_billcust_id ;

 EXCEPTION WHEN OTHERS  THEN
   RETURN NULL;

 END GET_BILLCUST_ID;


/* ======================================================================= */
/*  Function to get equivalent ship To ID customer id on Apps side for a   */
/*  cust_id in op_cust_mst_opm  passed to it.                              */
/* ======================================================================= */


FUNCTION GET_SHIPCUST_ID
 (
  p_opm_cust_id IN NUMBER
 )
 RETURN NUMBER IS

 l_shipcust_id NUMBER;

 BEGIN

   SELECT a.cust_id INTO l_shipcust_id
   FROM   op_cust_mst_v a, op_cust_mst_opm b
   WHERE  a.cust_no = b.cust_no
          AND a.of_cust_id = b.of_cust_id    --Bug 5651374 Performance issue.
          AND a.co_code = b.co_code
          AND b.cust_id = p_opm_cust_id
          AND b.ship_ind = 1
          AND rownum < 2;

   RETURN l_shipcust_id;

 EXCEPTION WHEN OTHERS  THEN
  RETURN NULL;

 END GET_SHIPCUST_ID;

/* ======================================================================= */
/*  Function to get first customer id on Apps side for a cust_id in        */
/*  op_cust_mst_opm  passed to it. In This particular case customer id     */
/*  could be bill to as well as ship to. It can not be resolved in OPM     */
/*  How ever Customer_no displayed on the form for old records would still */
/*  be the same. The forms are all Query Only.                             */
/* ======================================================================= */

FUNCTION GET_ANYCUST_ID
 (
  p_opm_cust_id IN NUMBER
 )
 RETURN NUMBER IS

 l_anycust_id NUMBER;

 BEGIN

   SELECT a.cust_id INTO l_anycust_id
   FROM   op_cust_mst_v a, op_cust_mst_opm b
   WHERE  a.cust_no = b.cust_no
          AND a.of_cust_id = b.of_cust_id    --Bug 5651374 Performance issue.
          AND a.co_code = b.co_code
          AND b.cust_id = p_opm_cust_id
          AND rownum < 2;

   RETURN l_anycust_id;

 EXCEPTION WHEN OTHERS THEN
  RETURN NULL;

 END GET_ANYCUST_ID;


 PROCEDURE UPDATE_CUST_ID
 IS

 l_bill_cust_id NUMBER;
 l_ship_cust_id NUMBER;
 l_any_cust_id  NUMBER;

 CURSOR Cur_cust_id IS
 SELECT b.cust_id FROM op_cust_mst a, op_cust_mst_opm b
 WHERE  a.cust_no = b.cust_no
   AND    a.co_code = b.co_code;


 BEGIN

 FOR r IN Cur_cust_id
 LOOP

   l_ship_cust_id := GET_SHIPCUST_ID(r.cust_id);
   l_bill_cust_id := GET_BILLCUST_ID(r.cust_id);
   l_any_cust_id := GET_ANYCUST_ID(r.cust_id);

   IF (l_ship_cust_id IS NOT NULL) THEN
   -- All Ship to updates
   -- Bug 5383665 Modified where clause to use opm_cust_id instead of cust_id.

     UPDATE gl_acct_map
     SET    cust_id = l_ship_cust_id
     WHERE opm_cust_id = r.cust_id;

     UPDATE op_alot_prm
     SET    cust_id = l_ship_cust_id
     WHERE  opm_cust_id = r.cust_id;

     -- Not bill ?
     UPDATE op_cust_asc
     SET    assoccust_id = l_ship_cust_id
     WHERE  opm_assoccust_id = r.cust_id;

     UPDATE op_gnrc_itm
     SET    cust_id = l_ship_cust_id
     WHERE  opm_cust_id = r.cust_id;

     UPDATE op_txcu_asc
     SET    cust_id = l_ship_cust_id
     WHERE  opm_cust_id = r.cust_id;

     UPDATE op_ordr_hdr
     SET    shipcust_id = l_ship_cust_id
     WHERE  opm_shipcust_id = r.cust_id;

     UPDATE op_ordr_hdr
     SET    ultimate_shipcust_id = l_ship_cust_id
     WHERE  opm_ultimate_shipcust_id = r.cust_id;

     UPDATE op_ordr_dtl
     SET    shipcust_id = l_ship_cust_id
     WHERE  opm_shipcust_id = r.cust_id;

     UPDATE op_prsl_hdr
     SET    shipcust_id = l_ship_cust_id
     WHERE  opm_shipcust_id = r.cust_id;

     UPDATE op_prsl_hdr
     SET    ultimate_shipcust_id = l_ship_cust_id
     WHERE  opm_ultimate_shipcust_id = r.cust_id;

     UPDATE op_prsl_dtl
     SET    shipcust_id = l_ship_cust_id
     WHERE  opm_shipcust_id = r.cust_id;

     UPDATE op_prsl_dtl
     SET    ultimate_shipcust_id = l_ship_cust_id
     WHERE  opm_ultimate_shipcust_id = r.cust_id;

   END IF;

   IF (l_bill_cust_id IS NOT NULL) THEN
   -- All Bill to updates

     UPDATE op_cust_asc
     SET    cust_id = l_bill_cust_id
     WHERE  opm_cust_id = r.cust_id;

     UPDATE op_ordr_hdr
     SET    billcust_id = l_bill_cust_id
     WHERE  opm_billcust_id = r.cust_id;

     UPDATE op_prsl_hdr
     SET    billcust_id = l_bill_cust_id
     WHERE  opm_billcust_id = r.cust_id;

     UPDATE op_prsl_dtl
     SET    billcust_id = l_bill_cust_id
     WHERE  opm_billcust_id = r.cust_id;

   END IF;

   IF (l_any_cust_id IS NOT NULL) THEN
   -- All Other cust_id updates

     UPDATE op_chrg_itm
     SET    cust_id = l_any_cust_id
     WHERE  opm_cust_id = r.cust_id;

     UPDATE op_cust_con
     SET    cust_id = l_any_cust_id
     WHERE  opm_cust_id = r.cust_id;

     UPDATE op_cust_itm
     SET    cust_id = l_any_cust_id
     WHERE  opm_cust_id = r.cust_id;

     UPDATE op_prce_eff
     SET    cust_id = l_any_cust_id
     WHERE  opm_cust_id = r.cust_id;

     UPDATE op_ordr_hdr
     SET    soldtocust_id = l_any_cust_id
     WHERE  opm_soldtocust_id = r.cust_id;

     UPDATE op_ordr_dtl
     SET    soldtocust_id = l_any_cust_id
     WHERE  opm_soldtocust_id = r.cust_id;

     UPDATE op_ordr_dtl
     SET    ultimate_shipcust_id = l_any_cust_id
     WHERE  opm_ultimate_shipcust_id = r.cust_id;

     UPDATE op_prsl_hdr
     SET    soldtocust_id= l_any_cust_id
     WHERE  opm_soldtocust_id = r.cust_id;

     UPDATE op_prsl_dtl
     SET    soldtocust_id= l_any_cust_id
     WHERE  opm_soldtocust_id = r.cust_id;

     UPDATE op_cust_shp
     SET    cust_id = l_any_cust_id
     WHERE  opm_cust_id = r.cust_id;

   END IF;

  END LOOP;


 END UPDATE_CUST_ID;

END GML_UPDATE_CUST_DATA_PVT;

/
