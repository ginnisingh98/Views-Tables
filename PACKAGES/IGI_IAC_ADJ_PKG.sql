--------------------------------------------------------
--  DDL for Package IGI_IAC_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_ADJ_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiadjs.pls 120.2.12000000.2 2007/10/16 14:18:53 sharoy noship $

   FUNCTION Do_Record_Adjustments(
       p_trans_rec                      FA_API_TYPES.trans_rec_type,
       p_asset_hdr_rec                  FA_API_TYPES.asset_hdr_rec_type,
       p_asset_cat_rec                  FA_API_TYPES.asset_cat_rec_type,
       p_asset_desc_rec                 FA_API_TYPES.asset_desc_rec_type,
       p_asset_type_rec                 FA_API_TYPES.asset_type_rec_type,
       p_asset_fin_rec                  FA_API_TYPES.asset_fin_rec_type,
       p_asset_deprn_rec                FA_API_TYPES.asset_deprn_rec_type,
       p_calling_function               VARCHAR2
    ) return BOOLEAN;

   FUNCTION Do_Process_Adjustments(
       p_book_type_code                 VARCHAR2,
       P_Period_counter                 NUMBER ,
       p_calling_function               VARCHAR2

   ) return BOOLEAN;

END igi_iac_adj_pkg; -- Package spec

 

/
