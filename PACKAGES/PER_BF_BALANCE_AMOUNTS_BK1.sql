--------------------------------------------------------
--  DDL for Package PER_BF_BALANCE_AMOUNTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_BALANCE_AMOUNTS_BK1" AUTHID CURRENT_USER as
/* $Header: pebbaapi.pkh 120.1 2005/10/02 02:11:58 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_balance_amount_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_balance_amount_b
(p_effective_date                in     date
,p_business_group_id             in     number
,p_balance_type_id               in     number
,p_assignment_id                 in     number
,p_payroll_run_id                in     number
,p_ytd_amount                    in     number
,p_fytd_amount                   in     number
,p_ptd_amount                    in     number
,p_mtd_amount                    in     number
,p_qtd_amount                    in     number
,p_run_amount                    in     number
,p_currency_code                 in     varchar2
,p_bba_attribute_category        in     varchar2
,p_bba_attribute1                in     varchar2
,p_bba_attribute2                in     varchar2
,p_bba_attribute3                in     varchar2
,p_bba_attribute4                in     varchar2
,p_bba_attribute5                in     varchar2
,p_bba_attribute6                in     varchar2
,p_bba_attribute7                in     varchar2
,p_bba_attribute8                in     varchar2
,p_bba_attribute9                in     varchar2
,p_bba_attribute10               in     varchar2
,p_bba_attribute11               in     varchar2
,p_bba_attribute12               in     varchar2
,p_bba_attribute13               in     varchar2
,p_bba_attribute14               in     varchar2
,p_bba_attribute15               in     varchar2
,p_bba_attribute16               in     varchar2
,p_bba_attribute17               in     varchar2
,p_bba_attribute18               in     varchar2
,p_bba_attribute19               in     varchar2
,p_bba_attribute20               in     varchar2
,p_bba_attribute21               in     varchar2
,p_bba_attribute22               in     varchar2
,p_bba_attribute23               in     varchar2
,p_bba_attribute24               in     varchar2
,p_bba_attribute25               in     varchar2
,p_bba_attribute26               in     varchar2
,p_bba_attribute27               in     varchar2
,p_bba_attribute28               in     varchar2
,p_bba_attribute29               in     varchar2
,p_bba_attribute30               in     varchar2
);
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_balance_amount_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_balance_amount_a
(p_effective_date                in     date
,p_business_group_id             in     number
,p_balance_type_id               in     number
,p_assignment_id                 in     number
,p_payroll_run_id                in     number
,p_ytd_amount                    in     number
,p_fytd_amount                   in     number
,p_ptd_amount                    in     number
,p_mtd_amount                    in     number
,p_qtd_amount                    in     number
,p_run_amount                    in     number
,p_currency_code                 in     varchar2
,p_bba_attribute_category        in     varchar2
,p_bba_attribute1                in     varchar2
,p_bba_attribute2                in     varchar2
,p_bba_attribute3                in     varchar2
,p_bba_attribute4                in     varchar2
,p_bba_attribute5                in     varchar2
,p_bba_attribute6                in     varchar2
,p_bba_attribute7                in     varchar2
,p_bba_attribute8                in     varchar2
,p_bba_attribute9                in     varchar2
,p_bba_attribute10               in     varchar2
,p_bba_attribute11               in     varchar2
,p_bba_attribute12               in     varchar2
,p_bba_attribute13               in     varchar2
,p_bba_attribute14               in     varchar2
,p_bba_attribute15               in     varchar2
,p_bba_attribute16               in     varchar2
,p_bba_attribute17               in     varchar2
,p_bba_attribute18               in     varchar2
,p_bba_attribute19               in     varchar2
,p_bba_attribute20               in     varchar2
,p_bba_attribute21               in     varchar2
,p_bba_attribute22               in     varchar2
,p_bba_attribute23               in     varchar2
,p_bba_attribute24               in     varchar2
,p_bba_attribute25               in     varchar2
,p_bba_attribute26               in     varchar2
,p_bba_attribute27               in     varchar2
,p_bba_attribute28               in     varchar2
,p_bba_attribute29               in     varchar2
,p_bba_attribute30               in     varchar2
,p_balance_amount_id             in     number
,p_balance_amount_ovn            in     number
,p_processed_assignment_id       in     number
,p_processed_assignment_ovn      in     number
);
--
end PER_BF_BALANCE_AMOUNTS_BK1;

 

/
