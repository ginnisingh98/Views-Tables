--------------------------------------------------------
--  DDL for Package OKL_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: OKLDRTPS.pls 120.0.12010000.4 2018/03/27 12:12:53 ivemulap noship $ */


-- ----------------------------------------------------------------------------
-- Description:
--  Data removal contraints (DRC) procedure for person type : TCA
-- Business Logic validations before deleting a TCA person like customer or vendor or title custodian
-- or title holder or lien holder or agent or private label
-- --------------------------------------------------------------------------------------

PROCEDURE okl_tca_drc
  (p_person_id	IN	NUMBER,
   result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type
 );


------------------------------------------------------------------------------
-- Description:
--  Post processing function for person type : TCA
--  This function masks email id of vendor in OKL_QUOTE_PARTIES table
-- and return 'S' for Success, 'W' for Warning and 'E' for Error
------------------------------------------------------------------------------
PROCEDURE okl_tca_post
  (p_person_id	IN	NUMBER);

END OKL_DRT_PKG;

/
