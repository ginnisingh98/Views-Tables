--------------------------------------------------------
--  DDL for Package Body PO_DOCS_INTERFACE_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCS_INTERFACE_PURGE" AS
/* $Header: POXPOIPB.pls 120.4.12000000.2 2007/09/28 10:12:05 ppadilam ship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_DOCS_INTERFACE_PURGE');

PROCEDURE exclude_undeletable_records
( x_intf_header_id_tbl IN OUT NOCOPY PO_TBL_NUMBER,
  p_process_code_tbl IN PO_TBL_VARCHAR30,
  p_po_header_id IN NUMBER
);

/*================================================================

  PROCEDURE NAME:   process_po_interface_tables()

==================================================================*/
PROCEDURE process_po_interface_tables(
      X_document_type      IN VARCHAR2,
      X_document_subtype   IN VARCHAR2,
      X_accepted_flag       IN VARCHAR2,
      X_rejected_flag       IN VARCHAR2,
      X_start_date         IN DATE,
       X_end_date           IN DATE,
      X_selected_batch_id   IN NUMBER,
      p_org_id             IN NUMBER   DEFAULT NULL,     -- <R12 MOAC>
      p_po_header_id       IN NUMBER   DEFAULT NULL      -- <PDOI Rewrite>
      )
IS

d_api_name CONSTANT VARCHAR2(30) := 'process_po_interface_tables';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_org_id      NUMBER;

l_intf_header_id_tbl PO_TBL_NUMBER;
l_process_code_tbl PO_TBL_VARCHAR30;
BEGIN

  -- <PDOI Rewrite R12>
  -- The whole procedure is refactored to remove repetitive code
  -- Also, this procedure will now delete data from the following interface
  -- tables:
  --   PO_HEADERS_INTERFACE
  --   PO_LINES_INTERFACE
  --   PO_LINE_LOCATIONS_INTERFACE

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  l_org_id := p_org_id ;   -- <R12 MOAC>

  -- bug5471513
  -- We should get the interface_header_id list first, and then perform
  -- deletion after filtering process is done

  SELECT interface_header_id,
         process_code
  BULK COLLECT
  INTO   l_intf_header_id_tbl,
         l_process_code_tbl
  FROM   po_headers_interface
  WHERE (batch_id = X_selected_batch_id
         OR  X_selected_batch_id IS NULL )

   AND  ((process_code = PO_PDOI_CONSTANTS.g_process_code_ACCEPTED and X_accepted_flag = 'Y')
          OR  (process_code = PO_PDOI_CONSTANTS.g_process_code_REJECTED and X_rejected_flag = 'Y')
          OR  (process_code = PO_PDOI_CONSTANTS.g_process_code_IN_PROCESS AND p_po_header_id IS NOT NULL))

   AND  (org_id = l_org_id
          OR l_org_id is NULL)

   AND  (document_type_code = UPPER(X_document_type)
          OR X_document_type is NULL)

   AND  (document_subtype = UPPER(X_document_subtype)
          OR X_document_subtype is NULL)

   AND  (Trunc(creation_date) >= X_start_date
          OR X_start_date is NULL)

   AND  (trunc(creation_date) <= X_end_date
          OR X_end_date is NULL)

   AND  (p_po_header_id IS NULL
          OR p_po_header_id = po_header_id);

  d_position := 10;

  -- refine the list of records to be deleted
  exclude_undeletable_records
  ( x_intf_header_id_tbl => l_intf_header_id_tbl,
    p_process_code_tbl => l_process_code_tbl,
    p_po_header_id => p_po_header_id
  );

  d_position := 15;

  -- bug5471513
  -- delete header interface records after filtering
  FORALL i IN 1..l_intf_header_id_tbl.COUNT
    DELETE FROM po_headers_interface
    WHERE interface_header_id = l_intf_header_id_tbl(i);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, '# hdr intf rec deleted' || SQL%ROWCOUNT);
  END IF;

  d_position := 18;


  FORALL i IN 1..l_intf_header_id_tbl.COUNT
    DELETE FROM po_lines_interface
    WHERE interface_header_id = l_intf_header_id_tbl(i);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, '# line intf rec deleted' || SQL%ROWCOUNT);
  END IF;

  d_position := 20;

  FORALL i IN 1..l_intf_header_id_tbl.COUNT
    DELETE FROM po_line_locations_interface
    WHERE interface_header_id = l_intf_header_id_tbl(i);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, '# line loc intf rec deleted' || SQL%ROWCOUNT);
  END IF;

  d_position := 30;

  FORALL i IN 1..l_intf_header_id_tbl.COUNT
    DELETE FROM po_distributions_interface
    WHERE interface_header_id = l_intf_header_id_tbl(i);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, '# distr intf rec deleted' || SQL%ROWCOUNT);
  END IF;

  d_position := 40;

  FORALL i IN 1..l_intf_header_id_tbl.COUNT
    DELETE FROM po_price_diff_interface
    WHERE interface_header_id = l_intf_header_id_tbl(i);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, '# price diff intf rec deleted' || SQL%ROWCOUNT);
  END IF;

  d_position := 50;

  FORALL i IN 1..l_intf_header_id_tbl.COUNT
    DELETE FROM po_attr_values_interface
    WHERE interface_header_id = l_intf_header_id_tbl(i);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, '# attr values intf rec deleted' || SQL%ROWCOUNT);
  END IF;

  d_position := 60;

  FORALL i IN 1..l_intf_header_id_tbl.COUNT
    DELETE FROM po_attr_values_tlp_interface
    WHERE interface_header_id = l_intf_header_id_tbl(i);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, '# attr values tlp intf rec deleted' || SQL%ROWCOUNT);
  END IF;

  d_position := 70;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END process_po_interface_tables;

PROCEDURE exclude_undeletable_records
( x_intf_header_id_tbl IN OUT NOCOPY PO_TBL_NUMBER,
  p_process_code_tbl IN PO_TBL_VARCHAR30,
  p_po_header_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'exclude_undeletable_records';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_new_intf_header_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

l_draft_id PO_DRAFTS.draft_id%TYPE;
l_request_id PO_DRAFTS.request_id%TYPE;
l_old_request_complete VARCHAR2(1);
l_need_collapsing BOOLEAN := FALSE;

l_cur_index NUMBER;
l_counter   NUMBER;
BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (p_po_header_id IS NULL) THEN
    RETURN;
  END IF;

  d_position := 10;

  FOR i IN 1..p_process_code_tbl.COUNT LOOP
    d_position := 20;

    IF (p_process_code_tbl(i) = PO_PDOI_CONSTANTS.g_process_code_IN_PROCESS) THEN
      -- if user wants to purge the intf record that is still in process, make
      -- sure that the drafts are removed and locks are released, if the
      -- record is no longer being touched.

      PO_DRAFTS_PVT.find_draft
      ( p_po_header_id => p_po_header_id,
        x_draft_id => l_draft_id
      );

      d_position := 30;

      IF (l_draft_id IS NOT NULL) THEN
        PO_DRAFTS_PVT.get_request_id
        ( p_draft_id => l_draft_id,
          x_request_id => l_request_id
        );

        IF (l_request_id IS NOT NULL) THEN
          d_position := 40;

          l_old_request_complete := PO_PDOI_UTL.is_old_request_complete
                                    ( p_old_request_id => l_request_id
                                    );

          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'l_old_request_complete',
                        l_old_request_complete);
          END IF;

          IF (l_old_request_complete = FND_API.G_TRUE) THEN
            d_position := 50;

            PO_DRAFTS_PVT.unlock_document
            ( p_po_header_id => p_po_header_id
            );
          ELSE
            d_position := 60;
            -- cannot touch the draft yet since it is still being processed.
            -- the interface records should not be deleted either.
            x_intf_header_id_tbl.DELETE(i);
            l_need_collapsing := TRUE;
          END IF; -- old_request_complete = TRUE
        END IF; -- request_id IS NOT NULL
      END IF; -- draft_id IS NOT NULL
    END IF; -- process_code = IN_PROCESS

  END LOOP;

  IF (l_need_collapsing) THEN
    d_position := 70;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'new array size',
                        x_intf_header_id_tbl.COUNT);
    END IF;

    l_new_intf_header_id_tbl.EXTEND(x_intf_header_id_tbl.COUNT);

    l_cur_index := x_intf_header_id_tbl.FIRST;

    -- Copy all non-deleted data to temporary storage
    WHILE l_cur_index <= x_intf_header_id_tbl.LAST LOOP
      d_position := 80;

  	  l_new_intf_header_id_tbl(l_counter) := x_intf_header_id_tbl(l_cur_index);
      l_counter := l_counter + 1;
      l_cur_index := x_intf_header_id_tbl.NEXT(l_cur_index);
    END LOOP;

    d_position := 90;
    -- get back the array without holes
    x_intf_header_id_tbl := l_new_intf_header_id_tbl;
  END IF;

  d_position := 100;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END exclude_undeletable_records;

END PO_DOCS_INTERFACE_PURGE;

/
