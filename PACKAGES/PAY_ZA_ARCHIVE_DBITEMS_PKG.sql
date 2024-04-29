--------------------------------------------------------
--  DDL for Package PAY_ZA_ARCHIVE_DBITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_ARCHIVE_DBITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: pyzaadbi.pkh 120.3 2005/07/04 03:06:10 kapalani noship $ */
   procedure create_archive_routes;
   procedure create_archive_dbi(p_item_name varchar2);

end pay_za_archive_dbitems_pkg;

 

/
