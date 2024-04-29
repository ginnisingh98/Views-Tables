--------------------------------------------------------
--  DDL for Package IGI_IMP_IAC_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IMP_IAC_WEBADI_PKG" AUTHID CURRENT_USER AS
--  $Header: igiimpws.pls 120.4.12000000.1 2007/08/01 16:21:59 npandya noship $

   PROCEDURE Upload_Data(
                         p_asset_number              IN    VARCHAR2,
                         p_book_code                 IN    VARCHAR2,
                         p_category_desc             IN    VARCHAR2,
                         p_cost_mhca                 IN    NUMBER,
                         p_ytd_mhca                  IN    NUMBER,
                         p_accum_deprn_mhca          IN    NUMBER,
                         p_reval_reserve_mhca        IN    NUMBER,
                         p_backlog_mhca              IN    NUMBER,
                         p_general_fund_mhca         IN    NUMBER,
                         p_operating_account_cost    IN    NUMBER,
                         p_operating_account_backlog IN    NUMBER,
                         p_group_id                  IN    NUMBER
                        );

END IGI_IMP_IAC_WEBADI_PKG;

 

/
