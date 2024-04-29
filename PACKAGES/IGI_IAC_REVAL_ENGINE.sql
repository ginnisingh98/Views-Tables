--------------------------------------------------------
--  DDL for Package IGI_IAC_REVAL_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REVAL_ENGINE" AUTHID CURRENT_USER AS
-- $Header: igiiares.pls 120.4.12000000.1 2007/08/01 16:17:02 npandya ship $

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

Function  First_Set_calculations  ( p_iac_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params )
RETURN BOOLEAN ;

Function  Next_Set_calculations  ( p_iac_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params )
RETURN BOOLEAN ;

Function  Prepare_Calculations (  p_iac_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params )
RETURN BOOLEAN;

Function  swap ( fp_reval_params1 IN IGI_IAC_TYPES.iac_reval_params
              , fp_reval_params2 OUT NOCOPY IGI_IAC_TYPES.iac_reval_params
              )
return boolean;

END;

 

/
