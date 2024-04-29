--------------------------------------------------------
--  DDL for Package PQH_BUDGET_ANALYSIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_ANALYSIS_PKG" AUTHID CURRENT_USER as
/* $Header: pqbgtanl.pkh 120.0 2005/05/29 01:31:00 appldev noship $ */
--
--
procedure salary_analysis(
 	  errbuf		out nocopy	varchar2
	, retcode		out nocopy      varchar2
	, p_batch_name			varchar2 default null
        , p_effective_date 		varchar2 default null
        , p_start_org_id 		number default null
        , p_start_date  		varchar2 default null
        , p_end_date     		varchar2 default null
	, p_business_group_id		number default null);
--
PROCEDURE get_pos_actual_commit_amt(p_position_id       in       number,
                                 p_start_date in       date,
                                 p_end_date   in       date,
                                 p_effective_date	in date,
                                 p_actual_amount  OUT nocopy number,
				 p_commitment_amount        OUT nocopy  number,
				 p_total_amount             OUT  nocopy  number
                                 );

--
Procedure get_entity(errbuf	            OUT nocopy varchar2
		    , retcode	            OUT nocopy  varchar2
		    , p_batch_name	    IN  varchar2
		    , p_effective_date      IN	varchar2
		    , p_start_date	    IN  varchar2
     		    , p_end_date	    IN  varchar2
		    , p_entity_code	    IN  varchar2
		    , p_unit_of_measure     IN 	varchar2
		    , p_business_group_id   IN	number
		    , p_start_org_id 	    IN  number default null
		    , p_org_structure_id    IN  number default null
		     );
--
Procedure position_analysis(
	  errbuf		out nocopy varchar2
        , retcode		out nocopy varchar2
        , p_batch_name			varchar2
        , p_effective_date 		varchar2
        , p_start_org_id 		number
        , p_org_structure_id		number
        , p_start_date  		varchar2
        , p_end_date     		varchar2
        , p_unit_of_measure             varchar2
	, p_business_group_id		number
         );

--
Procedure job_analysis(
	  errbuf		out nocopy varchar2
        , retcode		out nocopy varchar2
        , p_batch_name			varchar2
        , p_effective_date 		varchar2
        , p_start_date  		varchar2
        , p_end_date     		varchar2
        , p_unit_of_measure             varchar2
	, p_business_group_id		number
);
--

--
Procedure grade_analysis(
	  errbuf		out nocopy varchar2
        , retcode		out nocopy varchar2
        , p_batch_name			varchar2
        , p_effective_date 		varchar2
        , p_start_date  		varchar2
        , p_end_date     		varchar2
        , p_unit_of_measure             varchar2
	, p_business_group_id		number
);
--
Procedure organization_analysis(
	  errbuf		out nocopy varchar2
        , retcode		out nocopy varchar2
        , p_batch_name			varchar2
        , p_effective_date 		varchar2
        , p_start_org_id 		number
        , p_org_structure_id		number
        , p_start_date  		varchar2
        , p_end_date     		varchar2
        , p_unit_of_measure             varchar2
	, p_business_group_id		number
);

--
FUNCTION fyi_notification (p_transaction_id in number) RETURN varchar2;
--
function get_budget_currency(   p_position_id   in number default null
                                  ,p_job_id             in number default null
                                  ,p_grade_id           in number default null
                                  ,p_organization_id    in number default null
                                  ,p_budget_entity      in varchar2
                                  ,p_start_date         in date default sysdate
                                  ,p_end_date           in date default sysdate
                                  ,p_effective_date     in date default sysdate
                                  ,p_business_group_id  in number
                                  ) return varchar2;
end;

 

/
