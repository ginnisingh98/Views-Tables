--------------------------------------------------------
--  DDL for Package PER_CAGR_APPLY_RESULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CAGR_APPLY_RESULTS_PKG" AUTHID CURRENT_USER AS
/* $Header: pecgrapl.pkh 120.0.12010000.1 2008/07/28 04:20:27 appldev ship $ */
  PROCEDURE initialise (p_params         IN OUT NOCOPY per_cagr_evaluation_pkg.control_structure
                       ,p_select_flag    IN varchar2 default 'B');


  PROCEDURE initialise (p_process_date                 in    date
                       ,p_operation_mode               in    varchar2
                       ,p_business_group_id            in    number
                       ,p_assignment_id                in    number   default null
                       ,p_assignment_set_id            in    number   default null
                       ,p_category                     in    varchar2 default null
                       ,p_collective_agreement_id      in    number   default null
                       ,p_collective_agreement_set_id  in    number   default null
                       ,p_person_id                    in    number   default null
                       ,p_entitlement_item_id          in    number   default null
                       ,p_select_flag                  in    varchar2 default 'B'
                       ,p_commit_flag                  in    varchar2 default 'N'
                       ,p_cagr_request_id              in out nocopy   number);


END per_cagr_apply_results_pkg;

/
