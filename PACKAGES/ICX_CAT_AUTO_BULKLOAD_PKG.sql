--------------------------------------------------------
--  DDL for Package ICX_CAT_AUTO_BULKLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_AUTO_BULKLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: ICX_CAT_AUTO_BULKLOAD_PKG.pls 120.0.12010000.1 2013/02/22 11:16:28 rparise noship $ */

   PROCEDURE INSERT_bulkload_job(  p_format IN VARCHAR2,
                                  p_attachment_key IN VARCHAR2,
                                  p_supplier_ref IN VARCHAR2,
                                  x_ret_Status IN OUT NOCOPY VARCHAR2,
                                  x_ret_message IN OUT NOCOPY varchar2);
END;

/
