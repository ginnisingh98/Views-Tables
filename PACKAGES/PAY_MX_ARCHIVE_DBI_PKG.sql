--------------------------------------------------------
--  DDL for Package PAY_MX_ARCHIVE_DBI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_ARCHIVE_DBI_PKG" AUTHID CURRENT_USER AS
/* $Header: pymxarchdbipkg.pkh 120.0 2005/12/01 09:05:27 ardsouza noship $ */

   PROCEDURE create_archive_routes;

   PROCEDURE create_archive_dbi(p_item_name VARCHAR2);

END pay_mx_archive_dbi_pkg;

 

/
