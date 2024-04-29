--------------------------------------------------------
--  DDL for Package Body POA_SAVINGS_ACCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_SAVINGS_ACCT" AS
/* $Header: poasvp5b.pls 115.0 99/07/15 20:06:25 porting shi $ */

  /*
    NAME
     get_cac_info
    DESCRIPTION
     main function for getting cost center, account and company ids
     for Oracle Purchasing
  */
  --
  PROCEDURE get_cac_info (p_ccid IN NUMBER,
                     p_set_of_books_id IN NUMBER,
                     p_cost_center_id OUT VARCHAR2,
                     p_account_id OUT VARCHAR2,
                     p_company_id OUT VARCHAR2)
  IS

  structure_id      NUMBER;
  n_segments        NUMBER;
  segment_number    NUMBER;
  segments          fnd_flex_ext.SegmentArray;
  v_buf             VARCHAR2(240) := NULL;

  BEGIN

    POA_LOG.debug_line('Get_cac_info: entered');


    SELECT chart_of_accounts_id INTO structure_id
    FROM gl_sets_of_books
    WHERE set_of_books_id = p_set_of_books_id;

    IF (fnd_flex_ext.get_segments('SQLGL', 'GL#', structure_id, p_ccid,
                        n_segments, segments)) THEN
      -- get cost center id
      IF (fnd_flex_apis.get_qualifier_segnum(101, 'GL#', structure_id,
                    'FA_COST_CTR',
                    segment_number)) THEN
        p_cost_center_id := segments(segment_number);
      ELSE
        p_cost_center_id := NULL;
      END IF;

     -- get account id
      IF (fnd_flex_apis.get_qualifier_segnum(101, 'GL#', structure_id,
                    'GL_ACCOUNT',
                    segment_number)) THEN
        p_account_id := segments(segment_number);
      ELSE
        p_account_id := NULL;
      END IF;

     -- get company id
      IF (fnd_flex_apis.get_qualifier_segnum(101, 'GL#', structure_id,
                    'GL_BALANCING',
                    segment_number)) THEN
        p_company_id := segments(segment_number);
      ELSE
        p_company_id := NULL;
      END IF;
    END IF;

    POA_LOG.debug_line('Get_cac_info: exit');

  EXCEPTION
    WHEN others THEN
     v_buf := 'Get account info: unexpected error ' || p_ccid || ' ' || p_set_of_books_id;

     ROLLBACK;
     POA_LOG.put_line(v_buf);
     POA_LOG.put_line(' ');

     RAISE;
  END get_cac_info;
  --

END poa_savings_acct;
--

/
