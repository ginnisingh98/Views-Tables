--------------------------------------------------------
--  DDL for Package IGF_AP_AWD_YR_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_AWD_YR_SETUP" AUTHID CURRENT_USER AS
/* $Header: IGFAP31S.pls 115.0 2003/06/08 14:02:48 cdcruz noship $ */
/*
  ||  Created By : cdcruz
  ||  Created On : 01- Jun- 2003
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/

   -- Get Allowances against Parents' Income
 PROCEDURE  p_validate_aw_year ( p_sys_awd_yr       IN           VARCHAR2,    -- System award year
				 p_return_val       OUT NOCOPY   VARCHAR2) ;

END igf_ap_awd_yr_setup;

 

/
