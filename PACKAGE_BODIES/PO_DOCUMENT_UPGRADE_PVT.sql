--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_UPGRADE_PVT" AS
/* $Header: POXVUPGB.pls 120.1 2005/08/09 22:22:29 scolvenk noship $ */

    --Start of Comments
    --Name:PO_UPDATE_MGR
    --Pre-reqs:
    --  None.
    --Modifies:
    --  None.
    --Locks:
    --  None.
    --Function:
    -- The procedure would submit subrequests for updating
    -- the po line locations.
    -- This would be called by the Concurrent request POXUPMGR
    --Parameters:
    --IN:
    --p_batch_size
    --  Batch Commit  Size.
    --p_num_workers
    --  Number of workers to be used
    --OUT:
    --X_errbuf
    --  Message when existing a PL/SQL concurrent request
    --X_retcode
    -- Exit Status for the concurrent request
    --IN OUT:
    --N/A
    --Testing:
    --End of Comments

   PROCEDURE PO_UPDATE_MGR(
                  X_errbuf      OUT NOCOPY VARCHAR2,
                  X_retcode     OUT NOCOPY VARCHAR2,
                  p_batch_size  IN NUMBER,
                  p_num_workers IN NUMBER)

   IS
   BEGIN
        --
        -- Manager processing
        --

        AD_CONC_UTILS_PKG.submit_subrequests(
               X_errbuf=>X_errbuf,
               X_retcode=>X_retcode,
               X_workerconc_app_shortname=>'PO',
               X_workerconc_progname=>'POXUPWKR',
               X_batch_size=>p_batch_size,
               X_Num_Workers=>p_num_workers);


   END;


    --Start of Comments
    --Name:PO_UPDATE_WKR
    --Pre-reqs:
    --  None.
    --Modifies:
    --  None.
    --Locks:
    --  None.
    --Function:
    -- This procedure updates the following columns
    -- CLOSED_FOR_RECEIVING_DATE with the transaction date (with timestamp) on the
    --    receving transaction that leads to the shipment status being
    --    set to 'CLOSED FOR RECEVING' OR 'CLOSED'.If the shipment status is
    --    changed back to 'OPEN' OR 'CLOSED FOR INVOICE, then this date would
    --    be nulled out.
    -- CLOSED_FOR_INVOICE_DATE with the invoice date on the invoice that leads
    --    to the shipment status being set to 'CLOSED FOR INVOICE' OR 'CLOSED'.
    --    If the shipment status is changed back to 'OPEN' OR 'CLOSED FOR RECEIVING'
    --   , then this date would be nulled out.
    -- SHIPMENT_CLOSED_DATE with maximum of the CLOSED_FOR_RECEIVING_DATE or
    --     CLOSED_FOR_INVOICE_DATE when the shipment is CLOSED . In all other closure
    --     status, this would be null
    -- This would be called by the Concurrent request POXUPMGR
    --Parameters:
    --IN:
    --p_batch_size
    --  Batch Commit  Size.
    --p_num_workers
    --  Number of workers to be used
    --p_worker_id
    --OUT:
    --X_errbuf
    --  Message when existing a PL/SQL concurrent request
    --X_retcode
    -- Exit Status for the concurrent request
    --IN OUT:
    --N/A
    --Testing:
    --End of Comments

   PROCEDURE PO_UPDATE_WKR(
                  X_errbuf      OUT NOCOPY VARCHAR2,
                  X_retcode     OUT NOCOPY VARCHAR2,
                  p_batch_size  IN NUMBER,
                  p_worker_id   IN NUMBER,
                  p_num_workers IN NUMBER)

   IS

      l_worker_id  number;
      l_product     varchar2(30) := 'PO';
      l_table_name  varchar2(30) := 'PO_LINE_LOCATIONS_ALL';
      l_update_name varchar2(30) := 'poxucpll.sql';
      l_status      varchar2(30);
      l_industry    varchar2(30);
      l_retstatus   boolean;

      l_table_owner          varchar2(30);
      l_any_rows_to_process  boolean;

      l_start_rowid     rowid;
      l_end_rowid       rowid;
      l_rows_processed  number;

     l_userid        po_line_locations_all.last_updated_by%TYPE;
     l_loginid       po_line_locations_all.last_update_login%TYPE;

   BEGIN

     --
     -- get schema name of the table for ROWID range processing
     --
     l_retstatus := fnd_installation.get_app_info(
                        l_product, l_status, l_industry, l_table_owner);

     if ((l_retstatus = FALSE)
         OR
         (l_table_owner is null))
     then
        raise_application_error(-20001,
           'Cannot get schema name for product : '||l_product);
     end if;

     fnd_file.put_line(FND_FILE.LOG, '  p_worker_id : '||p_worker_id);
     fnd_file.put_line(FND_FILE.LOG, 'p_num_workers : '||p_num_workers);

     --
     -- Worker processing
     --

     --
     -- The following could be coded to use EXECUTE IMMEDIATE inorder to remove build time
     -- dependencies as the processing could potentially reference some tables that could
     -- be obsoleted in the current release
     --
     BEGIN

           ad_parallel_updates_pkg.initialize_rowid_range(
                    ad_parallel_updates_pkg.ROWID_RANGE,
                    l_table_owner,
                    l_table_name,
                    l_update_name,
                    p_worker_id,
                    p_num_workers,
                    p_batch_size, 0);

           ad_parallel_updates_pkg.get_rowid_range(
                    l_start_rowid,
                    l_end_rowid,
                    l_any_rows_to_process,
                    p_batch_size,
                    TRUE);

      -- Get User ID to update LAST_UPDATED_BY
      l_userid := FND_GLOBAL.USER_ID;

      -- Get Login ID to update LAST_UPDATE_LOGIN
      l_loginid := FND_GLOBAL.LOGIN_ID;


           while (l_any_rows_to_process = TRUE)
           loop
              -----------------------------------------------------
              --
              -- product specific processing here
              --
              --
              -----------------------------------------------------

         UPDATE  /*+ ROWID (poll) */ po_line_locations_all poll
         SET  poll.closed_for_receiving_date =
                   ( select     nvl(max(RT.transaction_date),
                                     decode(poll.closed_code,
                                              'FINALLY CLOSED',poll.closed_date,
                                              'CLOSED',poll.closed_date,
                                              'CLOSED FOR RECEIVING',poll.last_update_date,
                                               NULL)
                                     )
                      from       rcv_transactions RT
                      where      RT.TRANSACTION_TYPE IN ('RECEIVE','ACCEPT','CORRECT','MATCH')
                      and        RT.po_line_location_id = poll.line_location_id
                      and        poll.closed_code IN ('FINALLY CLOSED','CLOSED','CLOSED FOR RECEIVING')
                    )
             ,poll.closed_for_invoice_date   =
                    ( select   nvl( max(AIN.invoice_date),
                                    decode(poll.closed_code,
                                           'FINALLY CLOSED',poll.closed_date,
                                           'CLOSED',poll.closed_date,
                                           'CLOSED FOR INVOICE',poll.last_update_date,
                                           NULL)
                                   )
                      from     ap_invoice_distributions_all AID,
                               ap_invoices_all AIN,
                               po_distributions_all POD
                      where    AID.invoice_id = AIN.invoice_id
                      and      AID.po_distribution_id = POD.po_distribution_id
                      and      POD.line_location_id = poll.line_location_id
                      and      nvl(AID.reversal_flag,'N') NOT IN ('Y')
                      and      poll.closed_code IN ('FINALLY CLOSED','CLOSED','CLOSED FOR INVOICE')
                    )
              ,poll.shipment_closed_date  = decode(poll.closed_code,'FINALLY CLOSED',poll.closed_date,
                                                                           'CLOSED',poll.closed_date,
                                                                             NULL)
              ,last_update_date = sysdate
              ,last_updated_by  = l_userid
              ,last_update_login = l_loginid
        WHERE poll.rowid BETWEEN l_start_rowid and l_end_rowid
        and   poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
        and   poll.closed_code   IN ('FINALLY CLOSED','CLOSED','CLOSED FOR RECEIVING','CLOSED FOR INVOICE')
                and    ( ( poll.closed_code IN ('CLOSED FOR RECEIVING')
                         AND poll.closed_for_receiving_date IS NULL)
                           OR (poll.closed_code IN ('CLOSED FOR INVOICE')
                             AND  poll.closed_for_invoice_date IS NULL)
                       OR  (poll.closed_code IN ('FINALLY CLOSED','CLOSED')
                             AND (poll.shipment_closed_date IS NULL
                                     OR poll.closed_for_receiving_date IS NULL
                                         OR  poll.closed_for_invoice_date IS NULL))
                                );

              l_rows_processed := SQL%ROWCOUNT;

              ad_parallel_updates_pkg.processed_rowid_range(
                  l_rows_processed,
                  l_end_rowid);

              commit;

              ad_parallel_updates_pkg.get_rowid_range(
                 l_start_rowid,
                 l_end_rowid,
                 l_any_rows_to_process,
                 p_batch_size,
                 FALSE);

           end loop;

           X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

     EXCEPTION
          WHEN OTHERS THEN
            raise;
     END;


   END;

END;

/
