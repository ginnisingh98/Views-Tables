--------------------------------------------------------
--  DDL for Package Body POA_SAVINGS_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_SAVINGS_MAIN" AS
/* $Header: poasvp1b.pls 120.0 2005/06/01 12:47:24 appldev noship $ */

  /*
    NAME
      populate_savings -
    DESCRIPTION
     main function for populating poa_savings fact table
     for Oracle Purchasing
  */
  --
  PROCEDURE populate_savings(p_start_date IN DATE, p_end_date IN DATE,
                             p_populate_inc IN BOOLEAN := TRUE)
  IS

  TYPE T_FLEXREF IS REF CURSOR;

  v_num_rows            NUMBER := 0;
  v_start_time          DATE;

  v_account_cursor      T_FLEXREF;
  v_ccid                NUMBER := 0;
  v_cost_center_id      VARCHAR2(2000) := NULL;
  v_account_id          VARCHAR2(2000) := NULL;
  v_company_id          VARCHAR2(2000) := NULL;
  v_set_of_books_id     NUMBER := 0;

  v_buf                 VARCHAR2(240) := NULL;
  x_progress            VARCHAR2(3) := NULL;

  --
  l_poa_schema          VARCHAR2(30);
  l_stmt  		VARCHAR2(120);
  l_status		VARCHAR2(30);
  l_industry		VARCHAR2(30);
  l_batch_size          NUMBER := fnd_profile.value('POA_COLLECTION_BATCH_SIZE');
  l_no_batch            NUMBER;
  cursor v_changed_rows(p_start_date date,p_end_date date,p_batch_size number) is
        SELECT PO_DISTRIBUTION_ID, 1,ceil(rownum/p_batch_size)
         FROM (SELECT  pod.PO_DISTRIBUTION_ID,pol.item_id,pod.creation_date
        FROM    po_lines_all                    pol,
                po_line_locations_all           pll,
                po_headers_all                  poh,
                po_distributions_all            pod
        WHERE   pod.line_location_id            = pll.line_location_id
        and     pod.po_line_id                  = pol.po_line_id
        and     pod.po_header_id                = poh.po_header_id
        and     pll.shipment_type               = 'STANDARD'
        and     pll.approved_flag               = 'Y'
        and     nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
        and     greatest(pol.last_update_date, pll.last_update_date,
                         poh.last_update_date, pod.last_update_date, nvl(pod.program_update_date, pod.last_update_date))
                between  p_start_date and p_end_date
        UNION ALL
        SELECT  pod.PO_DISTRIBUTION_ID,pol.item_id,pod.creation_date
        FROM    po_lines_all                    pol,
                po_line_locations_all           pll,
                po_headers_all                  poh,
                po_releases_all                 por,
                po_distributions_all            pod
        WHERE   pod.line_location_id            = pll.line_location_id
        and     pod.po_release_id               = por.po_release_id
        and     pod.po_line_id                  = pol.po_line_id
        and     pod.po_header_id                = poh.po_header_id
        and     pll.shipment_type               in ('BLANKET', 'SCHEDULED')
        and     pll.approved_flag               = 'Y'
        and     nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
        and     greatest(pol.last_update_date,pll.last_update_date,
                   poh.last_update_date,por.last_update_date,pod.last_update_date, nvl(pod.program_update_date, pod.last_update_date))
                between  p_start_date and p_end_date)
       order by item_id,creation_date;

    TYPE plsqltable IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_primary_key plsqltable;
    l_seq_id      plsqltable;
    l_batch_id    plsqltable;
    l_count NUMBER;
    l_start_time date;
    l_end_time date;
  BEGIN
    select sysdate into l_start_time from dual;
    POA_LOG.debug_line('Populate_savings: entered');
    POA_LOG.debug_line(' ');

    -- check if we need to populate the INC table poa_edw_po_dist_inc.
    -- For EDW, we don't need to, since that is taken care in Push program.
    -- For OLTP, we should.

     if p_populate_inc then

        IF (FND_INSTALLATION.GET_APP_INFO('POA',l_status,l_industry,l_poa_schema)) THEN
          l_stmt := 'TRUNCATE TABLE ' || l_poa_schema ||'.POA_EDW_PO_DIST_INC';
          EXECUTE IMMEDIATE l_stmt;
        END IF;
        open v_changed_rows(p_start_date,p_end_date,l_batch_size);
        loop
        /* l_primary_key.delete; l_seq_id.delete; l_batch_id.delete; */
          fetch v_changed_rows bulk collect into
                l_primary_key,l_seq_id,l_batch_id limit l_batch_size;
          l_count := l_primary_key.count;
          forall i in 1..l_count
	    INSERT INTO poa_edw_po_dist_inc (primary_key, seq_id,batch_id) values(l_primary_key(i),l_seq_id(i),l_batch_id(i));
          EXIT WHEN l_count < l_batch_size;
        end loop;
        close v_changed_rows;
        select sysdate into l_end_time from dual;
        poa_log.put_line('time to populate incremental table: '|| poa_log.duration(l_end_time-l_start_time) || ', start time: ' || to_char(l_start_time, 'MM/DD/YYYY HH24:MI:SS') || ', end time: ' || to_char(l_end_time, 'MM/DD/YYYY HH24:MI:SS'));
     end if;
    -----------------------------------------------------------------------


    -- Temporary table is used for running the report.
    -- Delete from the temporary table where the entries
    -- are more than 2 days old.

    x_progress := '015';
    delete from poa_bis_savings_rpt
    where  last_update_date <= sysdate - 2;

    -- Get the current timestamp. All entries inserted into
    -- the fact table will use this timestamp as the last updated
    -- date and date of creation.

    x_progress := '020';

    select max(batch_id) into l_no_batch from poa_edw_po_dist_inc;

    SELECT sysdate INTO v_start_time from sys.dual;

    if (l_no_batch is NOT NULL) then
      FOR v_batch_no IN 0..l_no_batch LOOP
        poa_savings_np.populate_npcontract(p_start_date, p_end_date,
                                           v_start_time, v_batch_no);
        poa_savings_con.populate_contract(p_start_date, p_end_date,
                                          v_start_time, v_batch_no);
        commit;
      END LOOP;
    end if;

    select sysdate into l_end_time from dual;
    poa_log.put_line('total time taken for bis savings : '||poa_log.duration(l_end_time-l_start_time));

    /* Loop through to get the account information for each
     * distribution
     */

    /* The account information is currently not used by any reports.
     * Scoping this out for now.
     */

/*
    POA_LOG.debug_line('Opening cursor v_account_cursor');
    POA_LOG.debug_line(' ');

    OPEN v_account_cursor FOR
    SELECT distinct pod.code_combination_id
    ,      pod.set_of_books_id
    FROM   po_distributions_all pod
    where  pod.po_distribution_id IN
      (SELECT distinct poa.distribution_transaction_id
      FROM poa_bis_savings poa);


    LOOP
      FETCH v_account_cursor INTO
      v_ccid,
      v_set_of_books_id;
      EXIT WHEN v_account_cursor%NOTFOUND;

      poa_savings_acct.get_cac_info(v_ccid, v_set_of_books_id,
                                    v_cost_center_id,
                                    v_account_id,
                                    v_company_id);

      x_progress := '030';
      UPDATE poa_bis_savings poa
      set cost_center_id = v_cost_center_id,
          account_id     = v_account_id,
          company_id     = v_company_id
      WHERE poa.distribution_transaction_id IN
        (SELECT pod.po_distribution_id
        FROM po_distributions_all pod
        WHERE pod.code_combination_id = v_ccid
        and   pod.set_of_books_id = v_set_of_books_id);

    END LOOP;
    CLOSE v_account_cursor;

    POA_LOG.debug_line('Closed cursor v_account_cursor');
    POA_LOG.debug_line(' ');

    POA_LOG.debug_line('Populate_savings: Updating account complete ');
    POA_LOG.debug_line(' ');
*/
    POA_LOG.debug_line('Populate_savings: exit');
    POA_LOG.debug_line(' ');

  EXCEPTION
    WHEN others THEN
      v_buf := 'Main function: ' || sqlcode || ': ' || sqlerrm || ': ' || x_progress;
      ROLLBACK;

      POA_LOG.put_line(v_buf);
      POA_LOG.put_line(' ');
      RAISE;
  END populate_savings;
  --

END poa_savings_main;
--

/
