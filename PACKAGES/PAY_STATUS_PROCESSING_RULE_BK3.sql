--------------------------------------------------------
--  DDL for Package PAY_STATUS_PROCESSING_RULE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_STATUS_PROCESSING_RULE_BK3" AUTHID CURRENT_USER as
/* $Header: pypprapi.pkh 120.1 2005/10/02 02:46:29 aroussel $ */
-- ----------------------------------------------------------------------------
-- |------------------------< delete_status_process_rule_b >------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_status_process_rule_b
  (p_effective_date                 in    date
  ,p_datetrack_mode                 in    varchar2
  ,p_status_processing_rule_id      in    number
  ,p_object_version_number          in    NUMBER
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_status_process_rule_a >------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_status_process_rule_a
  (p_effective_date                 in    date
  ,p_datetrack_mode                 in    varchar2
  ,p_status_processing_rule_id      in    number
  ,p_object_version_number          in    number
  ,p_effective_start_date           in    date
  ,p_effective_end_date             in    date);
--
END pay_status_processing_rule_bk3;

 

/
