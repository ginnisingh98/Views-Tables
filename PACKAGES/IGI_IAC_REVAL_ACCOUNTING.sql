--------------------------------------------------------
--  DDL for Package IGI_IAC_REVAL_ACCOUNTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REVAL_ACCOUNTING" AUTHID CURRENT_USER AS
-- $Header: igiiaras.pls 120.3.12000000.2 2007/10/16 14:23:00 sharoy ship $

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

function create_iac_acctg
          ( fp_det_balances in IGI_IAC_DET_BALANCES%ROWTYPE
          , fp_create_acctg_flag in boolean
          , p_event_id           in number  --R12 upgrade
          )
return boolean;

END;

 

/
