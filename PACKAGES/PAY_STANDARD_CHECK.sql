--------------------------------------------------------
--  DDL for Package PAY_STANDARD_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_STANDARD_CHECK" AUTHID CURRENT_USER AS
/* $Header: pystdchk.pkh 115.1 2002/12/09 10:33:01 jbarker noship $ */
function relevant_total_chk(p_batch_id in number,p_meaning in varchar2) return boolean;
/*
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- pay_standard_check.check_control                                  --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Carries out any totalling require if p_control type is recognised --
 -- as a standard total. Depending upon the outcome of the checks an  --
 -- appropriate status is returned                                    --
 -- If p_control_type is not recognised as a standard control then
 -- not action is taken in this routine. p_std_status indicates whether
 -- or not p_control_type has been recognised as a standard control total
 -----------------------------------------------------------------------
--
*/
procedure check_control
(
p_batch_id              in      	number,
p_control_type          in      	varchar2,
p_control_total         in      	varchar2,
p_std_status            out  nocopy	varchar2,
p_std_message           out  nocopy	varchar2
);
end pay_standard_check;

 

/
