--------------------------------------------------------
--  DDL for Package ASF_ERR_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASF_ERR_REP_PKG" AUTHID CURRENT_USER AS
/* $Header: asflerrs.pls 115.0 2000/10/23 21:36:34 pkm ship     $ */
-- ---------------------------------------------------
--  Start of Comments
-- ---------------------------------------------------
--  PACKAGE NAME:   ASF_ERR_REP_PKG
-- ---------------------------------------------------
--  PURPOSE:
--            Stores the errors in the as_ls_err_t table when the API has
--            a problem to perform its function.
--
--  Procedures:
--           (see below for specification)
--
--  NOTES
--            This package is publicly available for use
--
--  HISTORY
--           05/23/00    SGHARAGO         Created
--
--  End of Comments
----------------------------------------------------------
  PROCEDURE process_error
   (p_dir_flag 			IN VARCHAR2
   ,p_error_num 		IN NUMBER
   ,p_error_code 		IN VARCHAR2
   ,p_error_text 		IN VARCHAR2
   ,p_transaction_id 	IN NUMBER   DEFAULT NULL
   ,p_lead_id 			IN NUMBER   DEFAULT NULL
   ,p_partner_id 		IN NUMBER   DEFAULT NULL
   );
--
END ASF_ERR_REP_PKG;

 

/
