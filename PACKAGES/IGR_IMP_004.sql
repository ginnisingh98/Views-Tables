--------------------------------------------------------
--  DDL for Package IGR_IMP_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_IMP_004" AUTHID CURRENT_USER AS
/* $Header: IGSRT15S.pls 120.0 2005/06/01 16:13:47 appldev noship $ */

/* ------------------------------------------------------------------------------------------------------------------------
  ||  Created By : rbezawad
  ||  Created On : 28-Feb-05
  ||  Purpose : Extract of IGR related references from Admissions Import process packages (IGSAD98B.pls)
  ||            to get rid of probable compilation errors for non-IGR customers.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  WHO             WHEN                   WHAT
---------------------------------------------------------------------------------------------------------------------------*/

-- The procedure is used to process all the records from the Inquiry Information
-- Interface table that are pending for processing and the parent
-- Inquiry Application record's status is completed ('1')and the parent
-- Interface Record has has a status of Completed ('1') or Warning ('4')
-- And the Parent Interface table record satisfies the following condition
-- p_source_type_id = i.source_type_id and p_batch_id = i.batch_id
  PROCEDURE prc_inq_info (
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_rule             IN VARCHAR2);


-- The procedure is used to process all the records from the Inquiry Characteristics
-- Interface table that are pending for processing and the parent
-- Inquiry Application record's status is completed ('1')and the parent
-- Interface Record has a status of Completed ('1') or Warning ('4')
-- And the Parent Interface table record satisfies the following condition
-- p_source_type_id = i.source_type_id and p_batch_id = i.batch_id
  PROCEDURE prc_inq_char (
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_rule             IN VARCHAR2);

-- The procedure is used to process all the records from the Inquiry Packages
-- Interface table that are pending for processing and the parent
-- Inquiry Application record's status is completed ('1')and the parent
-- Interface Record has status of Completed ('1') or Warning ('4')
-- And the Parent Interface table record satisfies the following condition
-- p_source_type_id = i.source_type_id and p_batch_id = i.batch_id
  PROCEDURE prc_inq_pkg (
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_rule             IN VARCHAR2);

END IGR_IMP_004;

 

/
