--------------------------------------------------------
--  DDL for Package AP_1099_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_1099_UTILITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: ap1099utls.pls 120.1.12010000.2 2009/10/06 12:48:41 ppodhiya ship $ */

   PROCEDURE insert_1099_data
     ( p_calling_module IN varchar2,
       p_sob_id         IN number,
       p_tax_entity_id  IN number,
       p_combined_flag  IN varchar2,
       p_start_date     IN date,
       p_end_date       IN date,
       p_vendor_id      IN number,
       p_query_driver   IN varchar2,
       p_min_reportable_flag IN varchar2,
       p_federal_reportable_flag in varchar2,
       p_region in varchar2
       );

   -- Added for backup withholding enhancement.
   -- Please refer bug8947583 for details.

   PROCEDURE do_awt_withholding_update
     ( p_calling_module IN varchar2,
       p_sob_id         IN number,
       p_tax_entity_id  IN number,
       p_combined_flag  IN varchar2,
       p_start_date     IN date,
       p_end_date       IN date,
       p_vendor_id      IN number,
       p_query_driver   IN varchar2,
       p_min_reportable_flag IN varchar2,
       p_federal_reportable_flag in varchar2,
       p_region in varchar2
       );

END ap_1099_utilities_pkg;

/
