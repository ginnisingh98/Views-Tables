--------------------------------------------------------
--  DDL for Package IGI_MPP_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_MPP_SETUP_PKG" AUTHID CURRENT_USER AS
-- $Header: igipmsus.pls 115.5 2002/11/18 14:02:41 panaraya ship $
   -- Enter package declarations as shown below

   PROCEDURE insert_row
       (  X_rowid                       in out NOCOPY VARCHAR2
       , X_set_of_books_id             in  NUMBER
       , X_future_posting_ccid         in  NUMBER
       , X_default_accounting_rule_id  in NUMBER
       , X_je_category_name            in VARCHAR2
       , X_je_source_name              in VARCHAR2
       , X_creation_date               in date
       , X_created_by                  in number
       , X_last_update_date            in date
       , X_last_updated_by             in number
       , X_last_update_login           in number
       )  ;
   PROCEDURE update_row
       ( X_rowid                       in out NOCOPY VARCHAR2
       , X_future_posting_ccid         in  NUMBER
       , X_default_accounting_rule_id  in NUMBER
       , X_je_category_name            in VARCHAR2
       , X_je_source_name              in VARCHAR2
       , X_last_update_date            in date
       , X_last_updated_by             in number
       , X_last_update_login           in number
       )  ;
   PROCEDURE lock_row
       ( X_rowid                       in out NOCOPY VARCHAR2
       , X_set_of_books_id             in  NUMBER
       , X_future_posting_ccid         in  NUMBER
       , X_default_accounting_rule_id  in NUMBER
       , X_je_category_name            in VARCHAR2
       , X_je_source_name              in VARCHAR2
       )  ;
END IGI_MPP_SETUP_PKG ;

 

/
