--------------------------------------------------------
--  DDL for Package Body PO_HR_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HR_INTERFACE_PVT" AS
/* $Header: POHRINTB.pls 120.3 2008/06/26 06:52:56 adbharga noship $*/

g_pkg_name       CONSTANT VARCHAR2(30) := 'PO_HR_INTERFACE_PVT';
g_log_head       CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';
g_debug_unexp    BOOLEAN := PO_DEBUG.is_debug_unexp_on;
g_debug_stmt     BOOLEAN := PO_DEBUG.is_debug_stmt_on;


PROCEDURE is_Supplier_Updatable (
                 p_assignment_id        IN  NUMBER,
                 p_effective_date IN  DATE DEFAULT NULL
                 )

IS
  l_api_name           CONSTANT VARCHAR2(30) := 'isSupplierUpdatable';
  l_log_head           CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_api_version        CONSTANT NUMBER := 1.0;
  l_progress           VARCHAR2(3) := '000';
  X_flag               VARCHAR2(1):='N';



BEGIN
  PO_DEBUG.debug_stmt(l_log_head,l_progress,'Start');

  l_progress:=010;
  BEGIN
    select 'Y'
    INTO X_flag
    from dual
    where exists(
        SELECT pca.po_header_id
        FROM po_cwk_associations pca,
             per_all_assignments_f paaf,
             po_headers_all pha ,
             po_lines_all pl
        WHERE paaf.assignment_id = p_assignment_id
        AND paaf.person_id = pca.cwk_person_id
        AND paaf.vendor_id = pha.vendor_id
        AND paaf.vendor_site_id = pha.vendor_site_id
        AND paaf.job_id = pl.job_id
        AND paaf.person_id IS NOT NULL
        AND paaf.vendor_id IS NOT NULL
        AND paaf.vendor_site_id IS NOT NULL
        AND pca.po_header_id = pha.po_header_id
        AND pha.po_header_id = pl.po_header_id
        AND Nvl(p_effective_date,SYSDATE)
               BETWEEN Nvl(paaf.effective_start_date,SYSDATE-1) AND Nvl(paaf.effective_end_date,SYSDATE+1)
     );
  EXCEPTION
    when NO_DATA_FOUND THEN
    PO_DEBUG.debug_stmt(l_log_head,l_progress,'No Record found');
    RETURN;
  END;

  l_progress:=020;
  IF X_flag='Y' THEN
    PO_DEBUG.debug_stmt(l_log_head,l_progress,'Record found');
    fnd_message.set_name('PO','PO_ACTIVE_SUPPLIER_EXISTS');
    APP_EXCEPTION.RAISE_EXCEPTION;

  ELSE
    PO_DEBUG.debug_stmt(l_log_head,l_progress,'No Record found');
    RETURN;
  END IF;

END is_Supplier_Updatable;

END PO_HR_INTERFACE_PVT;


/
