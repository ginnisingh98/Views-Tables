--------------------------------------------------------
--  DDL for Package Body ICX_CAT_AUTO_BULKLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_AUTO_BULKLOAD_PKG" AS
/* $Header: ICX_CAT_AUTO_BULKLOAD_PKG.plb 120.0.12010000.10 2013/04/03 22:57:52 debrchak noship $ */

  d_pkg_name CONSTANT VARCHAR2(50) := 'ICX_CAT_AUTO_BULKLOAD_PKG';

    FUNCTION get_jobtype_from_format(p_format IN VARCHAR2) RETURN VARCHAR2;

    PROCEDURE insert_bulkload_job(  p_format IN VARCHAR2,
                                    p_attachment_key IN VARCHAR2,
                                    p_supplier_ref IN VARCHAR2,
                                    x_ret_status IN OUT NOCOPY VARCHAR2,
                                    x_ret_message IN OUT NOCOPY varchar2
                                  )
    IS

d_api_name CONSTANT VARCHAR2(30) := 'insert_bulkload_job';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

    l_document blob;
    l_job_type VARCHAR2(30);
    l_request_id NUMBER;
    l_user_file_name VARCHAR2(256) := 'AutoTemplate.txt';
    l_osn_doc_id VARCHAR2(256);
    l_tt NUMBER;
    l_ech_tp_header_id NUMBER;
    l_user_id number;
    l_resp_id number;
    l_appl_id number;
    l_menu_id NUMBER;

    l_supplier_id NUMBER;
    l_supplier_site_id NUMBER;

    BEGIN

  d_position := 0;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start insert_bulkload_job');
     PO_LOG.stmt(d_module, d_position, 'p_format: '|| p_format);
     PO_LOG.stmt(d_module, d_position, 'p_attachment_key: '|| p_attachment_key);
     PO_LOG.stmt(d_module, d_position, 'p_supplier_ref: '|| p_supplier_ref);
   END IF;

        -- get the tp header id

        SELECT tp_header_id
        INTO l_ech_tp_header_id
         FROM ecx_in_process_v inp, ecx_tp_headers h
        WHERE internal_control_number = p_attachment_key
        AND INP.party_id = h.party_id AND INP.party_type = h.party_type AND INP.party_site_id = h.party_site_id;

  d_position := 10;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Got TP Header ID');
     PO_LOG.stmt(d_module, d_position, 'l_ech_tp_header_id: '|| l_ech_tp_header_id);
   END IF;
      -- get supplier id and supplier site id

        SELECT h.party_id,   h.party_site_id INTO l_supplier_id, l_supplier_site_id
        FROM ecx_tp_headers h
        WHERE h.tp_header_id = l_ech_tp_header_id;

  d_position := 20;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Got TP Supplier Info');
     PO_LOG.stmt(d_module, d_position, 'l_supplier_id: '|| l_supplier_id);
     PO_LOG.stmt(d_module, d_position, 'l_supplier_site_id: '|| l_supplier_site_id);
   END IF;

      -- get user id from content zone details

        SELECT USER_TO_BE_NOTIFIED INTO l_user_id
            FROM ICX_CAT_PUNCHOUT_ZONE_DETAILS
            WHERE vendor_id = l_supplier_id
            AND vendor_site_id = l_supplier_site_id
            AND ROWNUM = 1;

  d_position := 30;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Got Content Zone Details');
     PO_LOG.stmt(d_module, d_position, 'USER_TO_BE_NOTIFIED: '|| l_user_id);
   END IF;
      -- get the responsibility_id, responsibility_application_id from  user_id

      SELECT fug.responsibility_id, fug.responsibility_application_id
      INTO l_resp_id, l_appl_id
      FROM FND_RESPONSIBILITY frv, fnd_user_resp_groups fug,
                (
                SELECT menu_id
                FROM fnd_menu_entries
                START WITH function_id = (SELECT function_id FROM fnd_form_functions_vl WHERE FUNCTION_name = 'ICX_CAT_UPLOAD_AGREEMENT')
                CONNECT BY Decode(function_id, NULL, sub_menu_id) = PRIOR menu_id
                ORDER BY LEVEL
                ) menus
      WHERE frv.menu_id = menus.menu_id
      AND frv.application_id = fug.responsibility_application_id
      AND frv.responsibility_id = fug.responsibility_id
      AND fug.responsibility_application_id = 178
      AND fug.user_id = l_user_id;

  d_position := 40;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Got Context Details');
     PO_LOG.stmt(d_module, d_position, 'l_resp_id: '|| l_resp_id);
     PO_LOG.stmt(d_module, d_position, 'l_appl_id: '|| l_appl_id);
   END IF;

        fnd_global.apps_initialize(l_user_id,l_resp_id,l_appl_id);
        apps.mo_global.init('ICX');
        COMMIT;

  d_position := 50;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Context Initialized');
   END IF;

        l_job_type := get_jobtype_from_format(p_format);

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_job_type: '|| l_job_type);
   END IF;

        SELECT fl.file_data, fl.file_name, ecx_in_process_v.document_id INTO l_document, l_user_file_name, l_osn_doc_id
        FROM fnd_lobs fl, ecx_in_process_v, ecx_attachment_maps
        WHERE ecx_in_process_v.msgid = ecx_attachment_maps.msgid
        AND ecx_attachment_maps.fid = fl.file_id
        AND ecx_in_process_v.internal_control_number = p_attachment_key;

  d_position := 60;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Got File Details');
     PO_LOG.stmt(d_module, d_position, 'l_user_file_name: '|| l_user_file_name);
     PO_LOG.stmt(d_module, d_position, 'l_osn_doc_id: '|| l_osn_doc_id);
   END IF;

        l_request_id := fnd_request.submit_request('PO',                       -- Application Short Name
                                            'POXCDXBL',                         -- Program
                                            'Catalog Bulk Load - Items Upload',  -- Description
                                            null,                               -- Start Time
                                            false,                              -- Submit Request?
                                            l_user_file_name,                   -- User File Name
                                            l_job_type,                         -- Job type
                                            '',                                 -- Classification Domain
                                            'NO',                              -- Submit for Approval? Default is YES
                                            'NO',                               -- Category mapping
                                            '-1',                               -- error Tolerance
                                            'CAT_ADMIN',                        -- Role
                                            l_ech_tp_header_id);                -- PO Header ID

  d_position := 60;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Concurrent request Submitted');
     PO_LOG.stmt(d_module, d_position, 'l_request_id: '|| l_request_id);
   END IF;

        -- taking substr of osn_doc_id as job table can only accept 20 character as doc number
        l_osn_doc_id := SubStr(l_osn_doc_id, 1, 20);

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_osn_doc_id: '|| l_osn_doc_id);
   END IF;

        INSERT INTO icx_cat_batch_jobs (
                          job_number,
                          job_type,
                          job_status,
                          user_file_name,
                          role,
                          po_header_id,
                          document_type_code,
                          document_number,
                          created_by,
                          creation_Date,
                          last_updated_by,
                          last_update_Date,
                          last_update_login,
                          file_content ) VALUES(    l_request_id,
                                                    l_job_type,
                                                    'PENDING',
                                                    l_user_file_name,
                                                    'CAT_ADMIN',
                                                    l_ech_tp_header_id,
                                                    'PUNCHOUT',
                                                   l_osn_doc_id, --'6624',
                                                    fnd_global.user_id,
                                                    SYSDATE,
                                                    fnd_global.user_id,
                                                    SYSDATE,
                                                    fnd_global.login_id,
                                                    l_document);
  d_position := 70;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Loader Job Submitted');
   END IF;

        COMMIT;

        x_ret_status := 'Success';
        x_ret_message := 'Bulkload Successful at '|| SYSDATE;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'x_ret_message: ' || x_ret_message);
     PO_LOG.stmt(d_module, d_position, 'End send_error_notif with Status: ' || x_ret_status);
   END IF;

        EXCEPTION
        WHEN OTHERS THEN
	   IF (PO_LOG.d_stmt) THEN
	     PO_LOG.stmt(d_module, d_position, 'Exception at insert_bulkload_job');
	   END IF;
           raise_application_error(-20001, 'user and responsibility is not setup correctly for auto bulk loading punchout items');
    END insert_bulkload_job;

    FUNCTION get_jobtype_from_format(p_format IN VARCHAR2) RETURN VARCHAR2 IS
      x_job_type VARCHAR2(30);
      BEGIN
        x_job_type := 'AUTO_CATALOG_UPLOAD';

        IF p_format = 'TXT' THEN
          x_job_type := 'PUNCHOUT_DATA_TXT_UPLOAD';
        elsif p_format = 'XML' THEN
          x_job_type := 'PUNCHOUT_DATA_XML_UPLOAD';
        elsif p_format = 'CIF' THEN
          x_job_type := 'PUNCHOUT_DATA_CIF_UPLOAD';
        elsif p_format = 'CXML' THEN
          x_job_type := 'PUNCHOUT_DATA_CXML_UPLOAD';
        END IF;

        RETURN x_job_type;
    END get_jobtype_from_format;

  END;

/
