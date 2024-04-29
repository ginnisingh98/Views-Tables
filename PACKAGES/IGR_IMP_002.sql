--------------------------------------------------------
--  DDL for Package IGR_IMP_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_IMP_002" AUTHID CURRENT_USER AS
/* $Header: IGSRT13S.pls 120.0 2005/06/02 03:33:41 appldev noship $ */
/* ------------------------------------------------------------------------------------------------------------------------
  ||  Created By : rbezawad
  ||  Created On : 27-Feb-05
  ||  Purpose : Extract of IGR related references from Admissions Import process packages (IGSAD79B.pls and IGSAD93B.pls)
  ||            to get rid of probable compilation errors for non-IGR customers.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  WHO             WHEN                   WHAT
---------------------------------------------------------------------------------------------------------------------------*/

  -- Procedure to set the IGS_RC_I_APPL_INT.STATUS value to Warning (status='4') when IGS_RC_I_APPL_INT record
  -- is processed successfully (status='1') but processing of any of the child interface records is not successful
  -- (status<>'1').  Also set the IGS_AD_INTERFACE.STATUS to Error (Status='3') when processing any of the child interface
  -- records (IGS_RC_I_APPL_INT) is not successful (status<>'1').
  PROCEDURE update_parent_record_status (p_interface_run_id  IN NUMBER);

  -- Procedure used to call the procedures in related inquiry source category (INQUIRY_INSTANCE) to import each entity
  -- (INQUIRY_DETAILS, INQUIRY_ACADEMIC_INTEREST, INQUIRY_PACKAGE_ITEMS, INQUIRY_INFORMATION_TYPES and INQUIRY_CHARACTERISTICS).
  PROCEDURE prc_ad_category (p_source_type_id IN NUMBER,
                             p_interface_run_id  IN NUMBER,
                             p_enable_log IN VARCHAR2,
                             p_schema IN VARCHAR2);

  -- Procedure is used to delete the records from the recruitment interface tables, which are processed successfully.
  PROCEDURE del_cmpld_rct_records (p_source_type_id IN NUMBER,
                                   p_interface_run_id  IN NUMBER);

END IGR_IMP_002;

 

/
