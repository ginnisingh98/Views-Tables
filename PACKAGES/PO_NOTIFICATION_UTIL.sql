--------------------------------------------------------
--  DDL for Package PO_NOTIFICATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NOTIFICATION_UTIL" AUTHID CURRENT_USER AS
/* $Header: PONOTIFUTLS.pls 120.0.12010000.1 2012/04/24 09:12:30 akyanama noship $ */
Function getTax(p_document_id po_headers_all.po_header_id%TYPE) return number;
END PO_NOTIFICATION_UTIL;

/
