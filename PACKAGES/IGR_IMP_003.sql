--------------------------------------------------------
--  DDL for Package IGR_IMP_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_IMP_003" AUTHID CURRENT_USER AS
/* $Header: IGSRT14S.pls 120.0 2005/06/01 16:07:12 appldev noship $ */
/* ------------------------------------------------------------------------------------------------------------------------
  ||  Created By : rbezawad
  ||  Created On : 28-Feb-05
  ||  Purpose : Extract of IGR related references from Admissions Import process packages (IGSAD97B.pls)
  ||            to get rid of probable compilation errors for non-IGR customers.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  WHO             WHEN                   WHAT
---------------------------------------------------------------------------------------------------------------------------*/

  PROCEDURE process_person_inquiry (
                                             p_interface_run_id IN NUMBER,
                                             p_source_type_id   IN NUMBER,
                                             p_enable_log       IN VARCHAR2,
                                             p_rule             IN VARCHAR2);

  PROCEDURE process_inquiry_lines (
                                             p_interface_run_id IN NUMBER,
                                             p_enable_log       IN VARCHAR2,
                                             p_rule             IN VARCHAR2);

END IGR_IMP_003;

 

/
