--------------------------------------------------------
--  DDL for Package OTA_COST_TRANSFER_TO_GL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_COST_TRANSFER_TO_GL_PKG" AUTHID CURRENT_USER as
/* $Header: otactxgl.pkh 115.7 2002/01/03 13:37:21 pkm ship     $ */
--------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------< Insert GL Lines >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Insert two GL Lines for Cost Transfer
--               for two cost centers
--
/* this package is called from concurrent manager by otatrans.sql */
--------------------------------------------------------------------------------
PROCEDURE otagls(p_user_id    in number,
                 p_login_id   in number);

FUNCTION otagli  (p_finance_header_id   in number,
                  p_code_combination_id in varchar2,
                  p_set_of_books_id     in number,
                  p_debited_amount      in number,
                  p_credited_amount     in number,
                  p_currency_code       in varchar2,
                  p_desc                in varchar2,
                  p_cc_id               in number
) RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |----------------< Update OTA Finance Tables Cost Transfers >-------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description : Used to update the values on the ota_finance_headers and
--               ota_finance_lines for cost transfers between cost centers
--------------------------------------------------------------------------------
-- Update OTA Finance Headers for Cost Transfer
--
FUNCTION upd_ota_header (p_finance_header_id in number,
                         p_object_version_number in number)
RETURN VARCHAR2;
--
-- Update OTA Finance Lines for Cost Transfer
--
FUNCTION upd_ota_line (p_finance_header_id in number) RETURN VARCHAR2;
--
end OTA_COST_TRANSFER_TO_GL_PKG;

 

/
