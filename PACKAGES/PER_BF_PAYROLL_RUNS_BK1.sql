--------------------------------------------------------
--  DDL for Package PER_BF_PAYROLL_RUNS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_PAYROLL_RUNS_BK1" AUTHID CURRENT_USER as
/* $Header: pebprapi.pkh 120.1 2005/10/02 02:12:27 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <create_payroll_run_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_payroll_run_b
  (p_effective_date                in date
  ,p_business_group_id             in number
  ,p_payroll_id                    in number
  ,p_payroll_identifier            in varchar2
  ,p_period_start_date             in date
  ,p_period_end_date               in date
  ,p_processing_date               in date
  ,p_bpr_attribute_category        in varchar2
  ,p_bpr_attribute1                in varchar2
  ,p_bpr_attribute2                in varchar2
  ,p_bpr_attribute3                in varchar2
  ,p_bpr_attribute4                in varchar2
  ,p_bpr_attribute5                in varchar2
  ,p_bpr_attribute6                in varchar2
  ,p_bpr_attribute7                in varchar2
  ,p_bpr_attribute8                in varchar2
  ,p_bpr_attribute9                in varchar2
  ,p_bpr_attribute10               in varchar2
  ,p_bpr_attribute11               in varchar2
  ,p_bpr_attribute12               in varchar2
  ,p_bpr_attribute13               in varchar2
  ,p_bpr_attribute14               in varchar2
  ,p_bpr_attribute15               in varchar2
  ,p_bpr_attribute16               in varchar2
  ,p_bpr_attribute17               in varchar2
  ,p_bpr_attribute18               in varchar2
  ,p_bpr_attribute19               in varchar2
  ,p_bpr_attribute20               in varchar2
  ,p_bpr_attribute21               in varchar2
  ,p_bpr_attribute22               in varchar2
  ,p_bpr_attribute23               in varchar2
  ,p_bpr_attribute24               in varchar2
  ,p_bpr_attribute25               in varchar2
  ,p_bpr_attribute26               in varchar2
  ,p_bpr_attribute27               in varchar2
  ,p_bpr_attribute28               in varchar2
  ,p_bpr_attribute29               in varchar2
  ,p_bpr_attribute30               in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <create_payroll_run_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_payroll_run_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_payroll_id                    in     number
  ,p_payroll_identifier            in     varchar2
  ,p_period_start_date             in     date
  ,p_period_end_date               in     date
  ,p_processing_date               in     date
  ,p_payroll_run_id                in     number
  ,p_object_version_number         in     number
  ,p_bpr_attribute_category        in     varchar2
  ,p_bpr_attribute1                in     varchar2
  ,p_bpr_attribute2                in     varchar2
  ,p_bpr_attribute3                in     varchar2
  ,p_bpr_attribute4                in     varchar2
  ,p_bpr_attribute5                in     varchar2
  ,p_bpr_attribute6                in     varchar2
  ,p_bpr_attribute7                in     varchar2
  ,p_bpr_attribute8                in     varchar2
  ,p_bpr_attribute9                in     varchar2
  ,p_bpr_attribute10               in     varchar2
  ,p_bpr_attribute11               in     varchar2
  ,p_bpr_attribute12               in     varchar2
  ,p_bpr_attribute13               in     varchar2
  ,p_bpr_attribute14               in     varchar2
  ,p_bpr_attribute15               in     varchar2
  ,p_bpr_attribute16               in     varchar2
  ,p_bpr_attribute17               in     varchar2
  ,p_bpr_attribute18               in     varchar2
  ,p_bpr_attribute19               in     varchar2
  ,p_bpr_attribute20               in     varchar2
  ,p_bpr_attribute21               in     varchar2
  ,p_bpr_attribute22               in     varchar2
  ,p_bpr_attribute23               in     varchar2
  ,p_bpr_attribute24               in     varchar2
  ,p_bpr_attribute25               in     varchar2
  ,p_bpr_attribute26               in     varchar2
  ,p_bpr_attribute27               in     varchar2
  ,p_bpr_attribute28               in     varchar2
  ,p_bpr_attribute29               in     varchar2
  ,p_bpr_attribute30               in     varchar2
  );
--
end PER_BF_PAYROLL_RUNS_BK1;

 

/
