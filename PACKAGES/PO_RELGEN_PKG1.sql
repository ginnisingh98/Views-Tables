--------------------------------------------------------
--  DDL for Package PO_RELGEN_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RELGEN_PKG1" AUTHID CURRENT_USER AS
/* $Header: porelg2s.pls 120.0.12010000.1 2008/09/18 12:20:39 appldev noship $ */

msgbuf                   varchar2(200);

PROCEDURE ARCHIVE_RELEASE(x_po_release_id IN number);

PROCEDURE MRP_SUPPLY;

END PO_RELGEN_PKG1;


/
