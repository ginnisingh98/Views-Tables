--------------------------------------------------------
--  DDL for Package IGI_IAC_REVAL_IMPL_CRUD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REVAL_IMPL_CRUD" AUTHID CURRENT_USER AS
-- $Header: igiiarps.pls 120.4.12000000.1 2007/08/01 16:17:46 npandya ship $

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

function crud_iac_tables
     ( fp_reval_params   in out NOCOPY IGI_IAC_TYPES.iac_reval_params
      , fp_second_set    in boolean default false )
return boolean ;

END;

 

/
