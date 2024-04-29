--------------------------------------------------------
--  DDL for Package Body HR_CAGR_CONCURRENT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAGR_CONCURRENT_PROCESS" as
/* $Header: pecgrcon.pkb 115.7 2002/12/04 10:53:44 pkakar noship $ */

procedure cagr_concurrent (errbuf	 out nocopy varchar2
			  ,retcode	 out nocopy number
			  ,p_effective_date     in varchar2
                          ,p_business_group_id  in number
                          ,p_apply_results      in varchar2
                          ,p_operation_mode     in varchar2
                          ,p_validate           in varchar2
                          ,p_assignment_id      in number
                          ,p_collective_agreement_id in number
                          ,p_entitlement_item_id in number) is

  l_cagr_request_id		number := null;
  l_apply_results		varchar2(10);
  l_effective_date		date := fnd_date.canonical_to_date(p_effective_date);

BEGIN

    errbuf := null;
    retcode := 0;

    if p_apply_results IN ('Y','B') then
      -- from cagr_process_mode lookup:
      -- 'B' is eval + apply (both)
      -- 'N' is apply only
      -- 'Y' is eval only

	if p_apply_results = 'B' then
          -- eval + apply (beneficial result)
	  l_apply_results := 'Y';
	else
          -- eval only (do not apply).
          l_apply_results := 'N';
	end if;

     per_cagr_evaluation_pkg.initialise
	(p_process_date                   => l_effective_date
        ,p_operation_mode                 => p_operation_mode
        ,p_business_group_id              => p_business_group_id
        ,p_assignment_id                  => p_assignment_id
        ,p_collective_agreement_id        => p_collective_agreement_id
        ,p_entitlement_item_id            => p_entitlement_item_id
        ,p_commit_flag                    => p_validate
        ,p_apply_results_flag             => l_apply_results
        ,p_cagr_request_id                => l_cagr_request_id);

    elsif p_apply_results = 'N' then

      per_cagr_apply_results_pkg.initialise
 	(p_process_date                   => l_effective_date
        ,p_operation_mode                 => p_operation_mode
        ,p_business_group_id		  => p_business_group_id
        ,p_assignment_id                  => p_assignment_id
        ,p_collective_agreement_id        => p_collective_agreement_id
	,p_select_flag			  => 'B'  --  Apply beneficial value, not chosen value
        ,p_commit_flag                    => p_validate
        ,p_cagr_request_id		  => l_cagr_request_id);

    end if;


end cagr_concurrent;

end hr_cagr_concurrent_process;

/
