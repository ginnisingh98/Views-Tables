--------------------------------------------------------
--  DDL for Package PAY_SEED_SOE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SEED_SOE_PKG" AUTHID CURRENT_USER AS
/* $Header: paysesoe.pkh 120.0 2005/05/29 02:42 appldev noship $ */

PROCEDURE update_profile(
		       errbuf                   out NOCOPY varchar2
		      ,retcode                  out NOCOPY varchar2
		      ,p_business_group_id      in  varchar2
                      ,p_action                 in  varchar2);
END pay_seed_soe_pkg;

 

/
