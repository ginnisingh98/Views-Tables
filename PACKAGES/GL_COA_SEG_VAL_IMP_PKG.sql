--------------------------------------------------------
--  DDL for Package GL_COA_SEG_VAL_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_COA_SEG_VAL_IMP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLSVISPS.pls 120.0.12010000.1 2009/12/16 11:55:42 sommukhe noship $ */
  /***********************************************************************************************
    Created By     :   Somnath Mukherjee
    Date Created By:   01-AUG-2008


    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who              When          What
  ********************************************************************************************** */


  --This procedure is a sub process to import records of fnd flex values for Chart of Accounts.
  PROCEDURE create_gl_coa_flex_values(
          p_gl_flex_values_tbl IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2
  ) ;

  PROCEDURE create_gl_coa_flex_values_nh(
          p_gl_flex_values_nh_tbl IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_nh_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2
  ) ;
END gl_coa_seg_val_imp_pkg;

/
