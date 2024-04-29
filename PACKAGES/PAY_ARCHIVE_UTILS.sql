--------------------------------------------------------
--  DDL for Package PAY_ARCHIVE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ARCHIVE_UTILS" AUTHID CURRENT_USER as
/* $Header: pyarcutl.pkh 115.1 2001/12/24 05:34:05 pkm ship      $ */
   procedure create_archive_dbi(p_live_dbi_name VARCHAR2,
                                p_archive_route_name VARCHAR2 DEFAULT NULL,
                                p_secondary_context_name VARCHAR2 DEFAULT NULL);
   --
   procedure create_archive_dbi(p_extract_item_name     VARCHAR2,
                                p_route_id              NUMBER,
                                p_data_type             VARCHAR2,
                                p_legislation_code      VARCHAR2,
                                p_null_allowed_flag     VARCHAR2 DEFAULT 'Y',
                                p_notfound_allowed_flag VARCHAR2 DEFAULT 'Y');
   --
end pay_archive_utils;

 

/
