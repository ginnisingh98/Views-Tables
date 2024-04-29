--------------------------------------------------------
--  DDL for Package PAY_MAINTAIN_BANK_ACCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MAINTAIN_BANK_ACCT" AUTHID CURRENT_USER as
/* $Header: pymntbnk.pkh 120.3 2006/08/31 12:19:51 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_PAYROLL_BANK_ACCT >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--   Name                           Type     Description
--
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure update_payroll_bank_acct(
	p_bank_account_id     IN number,
	p_external_account_id IN NUMBER,
	p_org_payment_method_id IN number
	);

procedure remove_redundant_bank_detail;

procedure get_payment_details(
        p_payment_id          in               number,
	p_voided_payment      in               boolean,
	p_pay_currency_code   out nocopy       varchar2,
	p_recon_currency_code out nocopy       varchar2,
	p_value               out nocopy       varchar2,
	p_base_currency_value out nocopy       number,
	p_action_status       out nocopy       varchar2,
	p_business_group_Id   out nocopy       number
	);

function chk_bank_row_exists(
	p_external_account_id      in     number
	) return varchar2;

procedure get_chart_of_accts_and_sob
	(
	p_external_account_id      in            number,
	p_char_of_accounts_id      out  nocopy   number,
	p_set_of_books_id          out  nocopy   number,
	p_name                     out  nocopy   varchar2,
	p_asset_ccid               out  nocopy   number
	);

procedure update_asset_ccid
(
p_assest_ccid              in       number,
p_set_of_books_id          in       number,
p_external_account_id      in       number
);

Function get_sob_id
(
p_org_payment_method_id    in       number
) return number;


function chk_account_exists
(
p_org_payment_method_id    in       number,
p_validation_start_date    in       date,
p_validation_end_date      in       date
)return boolean;

procedure lock_row
(
p_external_account_id   in    number
);

procedure get_bank_details
(
	p_external_account_id   in    number,
	p_bank_account_id       out nocopy number,
	p_bank_account_name     out nocopy varchar2
);
--
end PAY_MAINTAIN_BANK_ACCT;

 

/
