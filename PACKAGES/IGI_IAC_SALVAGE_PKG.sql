--------------------------------------------------------
--  DDL for Package IGI_IAC_SALVAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_SALVAGE_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiascs.pls 120.2.12000000.1 2007/08/01 16:19:08 npandya noship $

FUNCTION Correction
      (P_asset_id IN igi_iac_asset_balances.asset_id%TYPE,
       P_book_type_code IN igi_iac_asset_balances.book_type_code%TYPE,
       P_value IN OUT NOCOPY Number,
       P_cost IN Fa_books.cost%TYPE,
       P_salvage_value IN fa_books.salvage_value%TYPE,
       p_calling_program VARCHAR2)
       RETURN  Boolean;

END igi_iac_salvage_pkg;



 

/
