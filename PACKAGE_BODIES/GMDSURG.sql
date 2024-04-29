--------------------------------------------------------
--  DDL for Package Body GMDSURG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMDSURG" AS
/* $Header: GMDPSURB.pls 120.3 2006/01/16 10:55:22 txdaniel noship $ */

  /* ================================================================= */
  /* FUNCTION:                                                         */
  /*   get_surrogate           DYNAMIC SQL INSIDE                      */
  /*                                                                   */
  /* DESCRIPTION:                                                      */
  /*   This PL/SQL function is responsible for                         */
  /*   retrieving a surrogate key unique number                        */
  /*   based on the passed in surrogate key.                           */
  /*                                                                   */
  /*   This function concatinates GEM5_ + passed                       */
  /*   surrogate key name + _s to determine the proper                 */
  /*   named sequence name to retrieve the next                        */
  /*   unique sequence number for the surrogate key.                   */
  /*                                                                   */
  /* SURROGATE KEYS:                                                   */
  /*   trans_id      lot_id           line_id                          */
  /*   batch_id      text_code        contact_id                       */
  /*   addr_id       cust_vend        doc_id                           */
  /*   vendor_id     journal_id       session_id                       */
  /*   interface_id  subled_id        batch_event_id                   */
  /*   subledger_id  actrans_id       item_cost_id                     */
  /*   cmpnt_cost_id apint_trans_id   batchstepline_id                 */
  /*                                                                   */
  /*                                                                   */
  /* SYNOPSIS:                                                         */
  /*   iret := GMDSURG.get_surrogate(psurrogate_name);                  */
  /*                                                                   */
  /*   psurrogate_name  the surrogate key name that                    */
  /*                     you need a unique sequence number for.        */
  /*                                                                   */
  /* RETURNS:                                                          */
  /*     > 0 Success                                                   */
  /*     < 0 RDBMS error                                               */
  /* =============================================================== */
  FUNCTION get_surrogate(psurrogate VARCHAR2)
    RETURN NUMBER IS

    /* Local variables.                                                                              */
    /* ================  MBER                                                                                     */
    l_surrogate    VARCHAR2(2000);
    l_sqlstatement varchar2(1000) := NULL;
    l_name         VARCHAR2(80);

    -- REF cursor defenition

    TYPE REF_CUR is REF CURSOR;
    l_ref_cur REF_CUR;
  /* =================================== */
  BEGIN
    l_name := 'GEM5_'||psurrogate||'_s.nextval';
    /* Create dynamic SQL statement to retrieve next                                               */
    /* sequence value for the surrogate key.                                                       */
    /* ============================================                                                */
    l_sqlstatement := 'SELECT '||l_name||' from SYS.DUAL';


    OPEN l_ref_cur FOR l_sqlstatement;
    FETCH l_ref_cur INTO l_surrogate;
    CLOSE l_ref_cur;

    RETURN l_surrogate;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN SQLCODE;
  END get_surrogate;
END;

/
