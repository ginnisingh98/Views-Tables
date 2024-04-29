--------------------------------------------------------
--  DDL for Package HR_CAGR_CONCURRENT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_CONCURRENT_PROCESS" AUTHID CURRENT_USER as
/* $Header: pecgrcon.pkh 115.8 2002/12/04 10:53:34 pkakar noship $ */

procedure cagr_concurrent (errbuf	 out nocopy varchar2
			  ,retcode	 out nocopy number
			  ,p_effective_date     in varchar2
                          ,p_business_group_id  in number
                          ,p_apply_results      in varchar2
                          ,p_operation_mode     in varchar2
                          ,p_validate           in varchar2
                          ,p_assignment_id      in number
                          ,p_collective_agreement_id in number
                          ,p_entitlement_item_id in number);

end hr_cagr_concurrent_process;

 

/
