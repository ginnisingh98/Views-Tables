--------------------------------------------------------
--  DDL for Package Body PAY_ORG_PAYMENT_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ORG_PAYMENT_METHOD_API" as
/* $Header: pyopmapi.pkb 120.11 2006/08/31 12:23:55 pgongada noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PAY_ORG_PAYMENT_METHOD_API';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_org_payment_method >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_org_payment_method
  (P_VALIDATE                      in     boolean  default false
  ,P_EFFECTIVE_DATE                in     date
  ,P_LANGUAGE_CODE                 in     varchar2 default hr_api.userenv_lang
  ,P_BUSINESS_GROUP_ID             in     number
  ,P_ORG_PAYMENT_METHOD_NAME       in     varchar2
  ,P_PAYMENT_TYPE_ID               in     number
  ,P_CURRENCY_CODE                 in     varchar2 default null
  ,P_ATTRIBUTE_CATEGORY            in     varchar2 default null
  ,P_ATTRIBUTE1                    in     varchar2 default null
  ,P_ATTRIBUTE2                    in     varchar2 default null
  ,P_ATTRIBUTE3                    in     varchar2 default null
  ,P_ATTRIBUTE4                    in     varchar2 default null
  ,P_ATTRIBUTE5                    in     varchar2 default null
  ,P_ATTRIBUTE6                    in     varchar2 default null
  ,P_ATTRIBUTE7                    in     varchar2 default null
  ,P_ATTRIBUTE8                    in     varchar2 default null
  ,P_ATTRIBUTE9                    in     varchar2 default null
  ,P_ATTRIBUTE10                   in     varchar2 default null
  ,P_ATTRIBUTE11                   in     varchar2 default null
  ,P_ATTRIBUTE12                   in     varchar2 default null
  ,P_ATTRIBUTE13                   in     varchar2 default null
  ,P_ATTRIBUTE14                   in     varchar2 default null
  ,P_ATTRIBUTE15                   in     varchar2 default null
  ,P_ATTRIBUTE16                   in     varchar2 default null
  ,P_ATTRIBUTE17                   in     varchar2 default null
  ,P_ATTRIBUTE18                   in     varchar2 default null
  ,P_ATTRIBUTE19                   in     varchar2 default null
  ,P_ATTRIBUTE20                   in     varchar2 default null
--  ,P_PMETH_INFORMATION_CATEGORY    in     varchar2 default null
  ,P_PMETH_INFORMATION1            in     varchar2 default null
  ,P_PMETH_INFORMATION2            in     varchar2 default null
  ,P_PMETH_INFORMATION3            in     varchar2 default null
  ,P_PMETH_INFORMATION4            in     varchar2 default null
  ,P_PMETH_INFORMATION5            in     varchar2 default null
  ,P_PMETH_INFORMATION6            in     varchar2 default null
  ,P_PMETH_INFORMATION7            in     varchar2 default null
  ,P_PMETH_INFORMATION8            in     varchar2 default null
  ,P_PMETH_INFORMATION9            in     varchar2 default null
  ,P_PMETH_INFORMATION10           in     varchar2 default null
  ,P_PMETH_INFORMATION11           in     varchar2 default null
  ,P_PMETH_INFORMATION12           in     varchar2 default null
  ,P_PMETH_INFORMATION13           in     varchar2 default null
  ,P_PMETH_INFORMATION14           in     varchar2 default null
  ,P_PMETH_INFORMATION15           in     varchar2 default null
  ,P_PMETH_INFORMATION16           in     varchar2 default null
  ,P_PMETH_INFORMATION17           in     varchar2 default null
  ,P_PMETH_INFORMATION18           in     varchar2 default null
  ,P_PMETH_INFORMATION19           in     varchar2 default null
  ,P_PMETH_INFORMATION20           in     varchar2 default null
  ,P_COMMENTS                      in     varchar2 default null
  ,P_SEGMENT1                      in     varchar2 default null
  ,P_SEGMENT2                      in     varchar2 default null
  ,P_SEGMENT3                      in     varchar2 default null
  ,P_SEGMENT4                      in     varchar2 default null
  ,P_SEGMENT5                      in     varchar2 default null
  ,P_SEGMENT6                      in     varchar2 default null
  ,P_SEGMENT7                      in     varchar2 default null
  ,P_SEGMENT8                      in     varchar2 default null
  ,P_SEGMENT9                      in     varchar2 default null
  ,P_SEGMENT10                     in     varchar2 default null
  ,P_SEGMENT11                     in     varchar2 default null
  ,P_SEGMENT12                     in     varchar2 default null
  ,P_SEGMENT13                     in     varchar2 default null
  ,P_SEGMENT14                     in     varchar2 default null
  ,P_SEGMENT15                     in     varchar2 default null
  ,P_SEGMENT16                     in     varchar2 default null
  ,P_SEGMENT17                     in     varchar2 default null
  ,P_SEGMENT18                     in     varchar2 default null
  ,P_SEGMENT19                     in     varchar2 default null
  ,P_SEGMENT20                     in     varchar2 default null
  ,P_SEGMENT21                     in     varchar2 default null
  ,P_SEGMENT22                     in     varchar2 default null
  ,P_SEGMENT23                     in     varchar2 default null
  ,P_SEGMENT24                     in     varchar2 default null
  ,P_SEGMENT25                     in     varchar2 default null
  ,P_SEGMENT26                     in     varchar2 default null
  ,P_SEGMENT27                     in     varchar2 default null
  ,P_SEGMENT28                     in     varchar2 default null
  ,P_SEGMENT29                     in     varchar2 default null
  ,P_SEGMENT30                     in     varchar2 default null
  ,P_CONCAT_SEGMENTS               in     varchar2 default null
  ,P_GL_SEGMENT1                   in     varchar2 default null
  ,P_GL_SEGMENT2                   in     varchar2 default null
  ,P_GL_SEGMENT3                   in     varchar2 default null
  ,P_GL_SEGMENT4                   in     varchar2 default null
  ,P_GL_SEGMENT5                   in     varchar2 default null
  ,P_GL_SEGMENT6                   in     varchar2 default null
  ,P_GL_SEGMENT7                   in     varchar2 default null
  ,P_GL_SEGMENT8                   in     varchar2 default null
  ,P_GL_SEGMENT9                   in     varchar2 default null
  ,P_GL_SEGMENT10                  in     varchar2 default null
  ,P_GL_SEGMENT11                  in     varchar2 default null
  ,P_GL_SEGMENT12                  in     varchar2 default null
  ,P_GL_SEGMENT13                  in     varchar2 default null
  ,P_GL_SEGMENT14                  in     varchar2 default null
  ,P_GL_SEGMENT15                  in     varchar2 default null
  ,P_GL_SEGMENT16                  in     varchar2 default null
  ,P_GL_SEGMENT17                  in     varchar2 default null
  ,P_GL_SEGMENT18                  in     varchar2 default null
  ,P_GL_SEGMENT19                  in     varchar2 default null
  ,P_GL_SEGMENT20                  in     varchar2 default null
  ,P_GL_SEGMENT21                  in     varchar2 default null
  ,P_GL_SEGMENT22                  in     varchar2 default null
  ,P_GL_SEGMENT23                  in     varchar2 default null
  ,P_GL_SEGMENT24                  in     varchar2 default null
  ,P_GL_SEGMENT25                  in     varchar2 default null
  ,P_GL_SEGMENT26                  in     varchar2 default null
  ,P_GL_SEGMENT27                  in     varchar2 default null
  ,P_GL_SEGMENT28                  in     varchar2 default null
  ,P_GL_SEGMENT29                  in     varchar2 default null
  ,P_GL_SEGMENT30                  in     varchar2 default null
  ,P_GL_CONCAT_SEGMENTS            in     varchar2 default null
  ,P_GL_CTRL_SEGMENT1              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT2              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT3              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT4              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT5              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT6              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT7              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT8              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT9              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT10             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT11             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT12             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT13             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT14             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT15             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT16             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT17             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT18             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT19             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT20             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT21             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT22             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT23             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT24             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT25             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT26             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT27             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT28             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT29             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT30             in     varchar2 default null
  ,P_GL_CTRL_CONCAT_SEGMENTS       in     varchar2 default null
  ,P_GL_CCRL_SEGMENT1              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT2              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT3              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT4              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT5              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT6              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT7              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT8              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT9              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT10             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT11             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT12             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT13             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT14             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT15             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT16             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT17             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT18             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT19             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT20             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT21             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT22             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT23             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT24             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT25             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT26             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT27             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT28             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT29             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT30             in     varchar2 default null
  ,P_GL_CCRL_CONCAT_SEGMENTS       in     varchar2 default null
  ,P_GL_ERR_SEGMENT1               in     varchar2 default null
  ,P_GL_ERR_SEGMENT2               in     varchar2 default null
  ,P_GL_ERR_SEGMENT3               in     varchar2 default null
  ,P_GL_ERR_SEGMENT4               in     varchar2 default null
  ,P_GL_ERR_SEGMENT5               in     varchar2 default null
  ,P_GL_ERR_SEGMENT6               in     varchar2 default null
  ,P_GL_ERR_SEGMENT7               in     varchar2 default null
  ,P_GL_ERR_SEGMENT8               in     varchar2 default null
  ,P_GL_ERR_SEGMENT9               in     varchar2 default null
  ,P_GL_ERR_SEGMENT10              in     varchar2 default null
  ,P_GL_ERR_SEGMENT11              in     varchar2 default null
  ,P_GL_ERR_SEGMENT12              in     varchar2 default null
  ,P_GL_ERR_SEGMENT13              in     varchar2 default null
  ,P_GL_ERR_SEGMENT14              in     varchar2 default null
  ,P_GL_ERR_SEGMENT15              in     varchar2 default null
  ,P_GL_ERR_SEGMENT16              in     varchar2 default null
  ,P_GL_ERR_SEGMENT17              in     varchar2 default null
  ,P_GL_ERR_SEGMENT18              in     varchar2 default null
  ,P_GL_ERR_SEGMENT19              in     varchar2 default null
  ,P_GL_ERR_SEGMENT20              in     varchar2 default null
  ,P_GL_ERR_SEGMENT21              in     varchar2 default null
  ,P_GL_ERR_SEGMENT22              in     varchar2 default null
  ,P_GL_ERR_SEGMENT23              in     varchar2 default null
  ,P_GL_ERR_SEGMENT24              in     varchar2 default null
  ,P_GL_ERR_SEGMENT25              in     varchar2 default null
  ,P_GL_ERR_SEGMENT26              in     varchar2 default null
  ,P_GL_ERR_SEGMENT27              in     varchar2 default null
  ,P_GL_ERR_SEGMENT28              in     varchar2 default null
  ,P_GL_ERR_SEGMENT29              in     varchar2 default null
  ,P_GL_ERR_SEGMENT30              in     varchar2 default null
  ,P_GL_ERR_CONCAT_SEGMENTS        in     varchar2 default null
  ,P_SETS_OF_BOOK_ID               in     number   default null
  ,P_THIRD_PARTY_PAYMENT           in     varchar2 default 'N'
  ,P_TRANSFER_TO_GL_FLAG           in     varchar2 default null
  ,P_COST_PAYMENT                  in     varchar2 default null
  ,P_COST_CLEARED_PAYMENT          in     varchar2 default null
  ,P_COST_CLEARED_VOID_PAYMENT     in     varchar2 default null
  ,P_EXCLUDE_MANUAL_PAYMENT        in     varchar2 default null
  ,P_DEFAULT_GL_ACCOUNT		   in     varchar2 default 'Y'
  ,P_BANK_ACCOUNT_ID               in     number   default null
  ,P_ORG_PAYMENT_METHOD_ID            out nocopy number
  ,P_EFFECTIVE_START_DATE             out nocopy date
  ,P_EFFECTIVE_END_DATE               out nocopy date
  ,P_OBJECT_VERSION_NUMBER            out nocopy number
  ,P_ASSET_CODE_COMBINATION_ID        out nocopy number
  ,P_COMMENT_ID                       out nocopy number
  ,P_EXTERNAL_ACCOUNT_ID              out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'create_org_payment_method';
  l_object_version_number     pay_org_payment_methods_f.object_version_number%TYPE;
  l_effective_date            date;
  l_org_payment_method_id     pay_org_payment_methods_f.org_payment_method_id%TYPE;
  l_effective_start_date      pay_org_payment_methods_f.effective_start_date%TYPE;
  l_effective_end_date        pay_org_payment_methods_f.effective_end_date%TYPE;
  l_comment_id                pay_org_payment_methods_f.comment_id%TYPE;
  l_external_account_id       pay_org_payment_methods_f.external_account_id%TYPE;
  l_asset_code_combination_id number;
  l_language_code             pay_org_payment_methods_f_tl.language%TYPE;
  l_discard                   number;
  l_territory_code            pay_payment_types.territory_code%TYPE;
  l_key_flex_id               number;
  l_defined_balance_id        pay_org_payment_methods_f.defined_balance_id%TYPE;
  l_currency_code             pay_org_payment_methods_f.currency_code%TYPE;
  l_PMETH_INFORMATION_CATEGORY pay_org_payment_methods_f.PMETH_INFORMATION_CATEGORY%TYPE;
  l_pay_gl_account_id         pay_payment_gl_accounts_f.pay_gl_account_id%TYPE;

  l_gl_cash_ac_id             PAY_PAYMENT_GL_ACCOUNTS_F.GL_CASH_AC_ID%TYPE;
  l_gl_cash_clearing_ac_id    PAY_PAYMENT_GL_ACCOUNTS_F.GL_CASH_CLEARING_AC_ID%TYPE;
  l_gl_control_ac_id          PAY_PAYMENT_GL_ACCOUNTS_F.GL_CONTROL_AC_ID%TYPE;
  l_gl_error_ac_id            PAY_PAYMENT_GL_ACCOUNTS_F.GL_ERROR_AC_ID%TYPE;
  l_set_of_books_id           PAY_PAYMENT_GL_ACCOUNTS_F.SET_OF_BOOKS_ID%TYPE;

  l_def_gl_cash_ac_id             PAY_PAYMENT_GL_ACCOUNTS_F.GL_CASH_AC_ID%TYPE;
  l_def_gl_cash_clearing_ac_id    PAY_PAYMENT_GL_ACCOUNTS_F.GL_CASH_CLEARING_AC_ID%TYPE;
  l_def_gl_control_ac_id          PAY_PAYMENT_GL_ACCOUNTS_F.GL_CONTROL_AC_ID%TYPE;
  l_def_gl_error_ac_id            PAY_PAYMENT_GL_ACCOUNTS_F.GL_ERROR_AC_ID%TYPE;
  l_def_set_of_books_id		  PAY_PAYMENT_GL_ACCOUNTS_F.SET_OF_BOOKS_ID%TYPE;


  l_gl_concat_segments          varchar2(2000);
  l_gl_csh_clr_concat_segment   varchar2(2000);
  l_gl_control_concat_segment   varchar2(2000);
  l_gl_error_concat_segment     varchar2(2000);

  L_DEFAULT_GL_ACCOUNT          varchar2(2);
  l_cstclr_flag                 varchar2(2);
  l_cst_flag                    varchar2(2);

  --
  cursor csr_def_balance (v_business_group_id number) is
     select  db.defined_balance_id
       from  pay_defined_balances db,
             pay_balance_dimensions bd,
             pay_balance_types bt
      where  nvl(db.business_group_id,v_business_group_id) = v_business_group_id
        and  ((db.legislation_code is null)
               or exists
              (select null
                 from per_business_groups pbg
                where pbg.business_group_id = v_business_group_id
                  and pbg.legislation_code = db.legislation_code))
        and  db.balance_dimension_id = bd.balance_dimension_id
        and  db.balance_type_id      = bt.balance_type_id
        and  bd.payments_flag = 'Y'
        and  bt.assignment_remuneration_flag = 'Y'
      order  by db.business_group_id,db.legislation_code;
  --
  cursor csr_territory_code (v_payment_type_id number, v_business_group_id number) is
     select nvl(ppt.territory_code,pbg.legislation_code)
       from pay_payment_types ppt,
            per_business_groups pbg
      where ppt.payment_type_id = v_payment_type_id
        and pbg.business_group_id = v_business_group_id;
  --
  cursor csr_currency_code (v_payment_type_id number) is
     select currency_code
       from pay_payment_types
      where payment_type_id = v_payment_type_id;
  --
  cursor csr_chart_of_accounts_id (v_sets_of_book_id number) is
     select CHART_OF_ACCOUNTS_ID
       from gl_sets_of_books
      where SET_OF_BOOKS_ID = v_sets_of_book_id;
  --
  cursor csr_pmeth_category (v_payment_type_id number) is
     select payment_type_name
       from pay_payment_types
      where payment_type_id = v_payment_type_id;
  --
  cursor csr_gl_accounts (v_external_account_id number) is
     select gl_cash_ac_id,
	    gl_cash_clearing_ac_id,
	    gl_control_ac_id,
	    gl_error_ac_id,
	    set_of_books_id
       from pay_payment_gl_accounts_f
      where external_account_id = v_external_account_id;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_org_payment_method;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  L_DEFAULT_GL_ACCOUNT := P_DEFAULT_GL_ACCOUNT;
  --
  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_org_payment_method_bk1.create_org_payment_method_b
      (P_EFFECTIVE_DATE                 => L_EFFECTIVE_DATE
      ,P_LANGUAGE_CODE                  => l_LANGUAGE_CODE
      ,P_BUSINESS_GROUP_ID              => P_BUSINESS_GROUP_ID
      ,P_ORG_PAYMENT_METHOD_NAME        => P_ORG_PAYMENT_METHOD_NAME
      ,P_PAYMENT_TYPE_ID                => P_PAYMENT_TYPE_ID
      ,P_CURRENCY_CODE                  => P_CURRENCY_CODE
      ,P_ATTRIBUTE_CATEGORY             => P_ATTRIBUTE_CATEGORY
      ,P_ATTRIBUTE1                     => P_ATTRIBUTE1
      ,P_ATTRIBUTE2                     => P_ATTRIBUTE2
      ,P_ATTRIBUTE3                     => P_ATTRIBUTE3
      ,P_ATTRIBUTE4                     => P_ATTRIBUTE4
      ,P_ATTRIBUTE5                     => P_ATTRIBUTE5
      ,P_ATTRIBUTE6                     => P_ATTRIBUTE6
      ,P_ATTRIBUTE7                     => P_ATTRIBUTE7
      ,P_ATTRIBUTE8                     => P_ATTRIBUTE8
      ,P_ATTRIBUTE9                     => P_ATTRIBUTE9
      ,P_ATTRIBUTE10                    => P_ATTRIBUTE10
      ,P_ATTRIBUTE11                    => P_ATTRIBUTE11
      ,P_ATTRIBUTE12                    => P_ATTRIBUTE12
      ,P_ATTRIBUTE13                    => P_ATTRIBUTE13
      ,P_ATTRIBUTE14                    => P_ATTRIBUTE14
      ,P_ATTRIBUTE15                    => P_ATTRIBUTE15
      ,P_ATTRIBUTE16                    => P_ATTRIBUTE16
      ,P_ATTRIBUTE17                    => P_ATTRIBUTE17
      ,P_ATTRIBUTE18                    => P_ATTRIBUTE18
      ,P_ATTRIBUTE19                    => P_ATTRIBUTE19
      ,P_ATTRIBUTE20                    => P_ATTRIBUTE20
--      ,P_PMETH_INFORMATION_CATEGORY     => P_PMETH_INFORMATION_CATEGORY
      ,P_PMETH_INFORMATION1             => P_PMETH_INFORMATION1
      ,P_PMETH_INFORMATION2             => P_PMETH_INFORMATION2
      ,P_PMETH_INFORMATION3             => P_PMETH_INFORMATION3
      ,P_PMETH_INFORMATION4             => P_PMETH_INFORMATION4
      ,P_PMETH_INFORMATION5             => P_PMETH_INFORMATION5
      ,P_PMETH_INFORMATION6             => P_PMETH_INFORMATION6
      ,P_PMETH_INFORMATION7             => P_PMETH_INFORMATION7
      ,P_PMETH_INFORMATION8             => P_PMETH_INFORMATION8
      ,P_PMETH_INFORMATION9             => P_PMETH_INFORMATION9
      ,P_PMETH_INFORMATION10            => P_PMETH_INFORMATION10
      ,P_PMETH_INFORMATION11            => P_PMETH_INFORMATION11
      ,P_PMETH_INFORMATION12            => P_PMETH_INFORMATION12
      ,P_PMETH_INFORMATION13            => P_PMETH_INFORMATION13
      ,P_PMETH_INFORMATION14            => P_PMETH_INFORMATION14
      ,P_PMETH_INFORMATION15            => P_PMETH_INFORMATION15
      ,P_PMETH_INFORMATION16            => P_PMETH_INFORMATION16
      ,P_PMETH_INFORMATION17            => P_PMETH_INFORMATION17
      ,P_PMETH_INFORMATION18            => P_PMETH_INFORMATION18
      ,P_PMETH_INFORMATION19            => P_PMETH_INFORMATION19
      ,P_PMETH_INFORMATION20            => P_PMETH_INFORMATION20
      ,P_COMMENTS                       => P_COMMENTS
      ,P_SEGMENT1                       => P_SEGMENT1
      ,P_SEGMENT2                       => P_SEGMENT2
      ,P_SEGMENT3                       => P_SEGMENT3
      ,P_SEGMENT4                       => P_SEGMENT4
      ,P_SEGMENT5                       => P_SEGMENT5
      ,P_SEGMENT6                       => P_SEGMENT6
      ,P_SEGMENT7                       => P_SEGMENT7
      ,P_SEGMENT8                       => P_SEGMENT8
      ,P_SEGMENT9                       => P_SEGMENT9
      ,P_SEGMENT10                      => P_SEGMENT10
      ,P_SEGMENT11                      => P_SEGMENT11
      ,P_SEGMENT12                      => P_SEGMENT12
      ,P_SEGMENT13                      => P_SEGMENT13
      ,P_SEGMENT14                      => P_SEGMENT14
      ,P_SEGMENT15                      => P_SEGMENT15
      ,P_SEGMENT16                      => P_SEGMENT16
      ,P_SEGMENT17                      => P_SEGMENT17
      ,P_SEGMENT18                      => P_SEGMENT18
      ,P_SEGMENT19                      => P_SEGMENT19
      ,P_SEGMENT20                      => P_SEGMENT20
      ,P_SEGMENT21                      => P_SEGMENT21
      ,P_SEGMENT22                      => P_SEGMENT22
      ,P_SEGMENT23                      => P_SEGMENT23
      ,P_SEGMENT24                      => P_SEGMENT24
      ,P_SEGMENT25                      => P_SEGMENT25
      ,P_SEGMENT26                      => P_SEGMENT26
      ,P_SEGMENT27                      => P_SEGMENT27
      ,P_SEGMENT28                      => P_SEGMENT28
      ,P_SEGMENT29                      => P_SEGMENT29
      ,P_SEGMENT30                      => P_SEGMENT30
      ,P_CONCAT_SEGMENTS                => P_CONCAT_SEGMENTS
      ,P_GL_SEGMENT1                    => P_GL_SEGMENT1
      ,P_GL_SEGMENT2                    => P_GL_SEGMENT2
      ,P_GL_SEGMENT3                    => P_GL_SEGMENT3
      ,P_GL_SEGMENT4                    => P_GL_SEGMENT4
      ,P_GL_SEGMENT5                    => P_GL_SEGMENT5
      ,P_GL_SEGMENT6                    => P_GL_SEGMENT6
      ,P_GL_SEGMENT7                    => P_GL_SEGMENT7
      ,P_GL_SEGMENT8                    => P_GL_SEGMENT8
      ,P_GL_SEGMENT9                    => P_GL_SEGMENT9
      ,P_GL_SEGMENT10                   => P_GL_SEGMENT10
      ,P_GL_SEGMENT11                   => P_GL_SEGMENT11
      ,P_GL_SEGMENT12                   => P_GL_SEGMENT12
      ,P_GL_SEGMENT13                   => P_GL_SEGMENT13
      ,P_GL_SEGMENT14                   => P_GL_SEGMENT14
      ,P_GL_SEGMENT15                   => P_GL_SEGMENT15
      ,P_GL_SEGMENT16                   => P_GL_SEGMENT16
      ,P_GL_SEGMENT17                   => P_GL_SEGMENT17
      ,P_GL_SEGMENT18                   => P_GL_SEGMENT18
      ,P_GL_SEGMENT19                   => P_GL_SEGMENT19
      ,P_GL_SEGMENT20                   => P_GL_SEGMENT20
      ,P_GL_SEGMENT21                   => P_GL_SEGMENT21
      ,P_GL_SEGMENT22                   => P_GL_SEGMENT22
      ,P_GL_SEGMENT23                   => P_GL_SEGMENT23
      ,P_GL_SEGMENT24                   => P_GL_SEGMENT24
      ,P_GL_SEGMENT25                   => P_GL_SEGMENT25
      ,P_GL_SEGMENT26                   => P_GL_SEGMENT26
      ,P_GL_SEGMENT27                   => P_GL_SEGMENT27
      ,P_GL_SEGMENT28                   => P_GL_SEGMENT28
      ,P_GL_SEGMENT29                   => P_GL_SEGMENT29
      ,P_GL_SEGMENT30                   => P_GL_SEGMENT30
      ,P_GL_CONCAT_SEGMENTS             => P_GL_CONCAT_SEGMENTS
      ,P_GL_CTRL_SEGMENT1               => P_GL_CTRL_SEGMENT1
      ,P_GL_CTRL_SEGMENT2               => P_GL_CTRL_SEGMENT2
      ,P_GL_CTRL_SEGMENT3               => P_GL_CTRL_SEGMENT3
      ,P_GL_CTRL_SEGMENT4               => P_GL_CTRL_SEGMENT4
      ,P_GL_CTRL_SEGMENT5               => P_GL_CTRL_SEGMENT5
      ,P_GL_CTRL_SEGMENT6               => P_GL_CTRL_SEGMENT6
      ,P_GL_CTRL_SEGMENT7               => P_GL_CTRL_SEGMENT7
      ,P_GL_CTRL_SEGMENT8               => P_GL_CTRL_SEGMENT8
      ,P_GL_CTRL_SEGMENT9               => P_GL_CTRL_SEGMENT9
      ,P_GL_CTRL_SEGMENT10              => P_GL_CTRL_SEGMENT10
      ,P_GL_CTRL_SEGMENT11              => P_GL_CTRL_SEGMENT11
      ,P_GL_CTRL_SEGMENT12              => P_GL_CTRL_SEGMENT12
      ,P_GL_CTRL_SEGMENT13              => P_GL_CTRL_SEGMENT13
      ,P_GL_CTRL_SEGMENT14              => P_GL_CTRL_SEGMENT14
      ,P_GL_CTRL_SEGMENT15              => P_GL_CTRL_SEGMENT15
      ,P_GL_CTRL_SEGMENT16              => P_GL_CTRL_SEGMENT16
      ,P_GL_CTRL_SEGMENT17              => P_GL_CTRL_SEGMENT17
      ,P_GL_CTRL_SEGMENT18              => P_GL_CTRL_SEGMENT18
      ,P_GL_CTRL_SEGMENT19              => P_GL_CTRL_SEGMENT19
      ,P_GL_CTRL_SEGMENT20              => P_GL_CTRL_SEGMENT20
      ,P_GL_CTRL_SEGMENT21              => P_GL_CTRL_SEGMENT21
      ,P_GL_CTRL_SEGMENT22              => P_GL_CTRL_SEGMENT22
      ,P_GL_CTRL_SEGMENT23              => P_GL_CTRL_SEGMENT23
      ,P_GL_CTRL_SEGMENT24              => P_GL_CTRL_SEGMENT24
      ,P_GL_CTRL_SEGMENT25              => P_GL_CTRL_SEGMENT25
      ,P_GL_CTRL_SEGMENT26              => P_GL_CTRL_SEGMENT26
      ,P_GL_CTRL_SEGMENT27              => P_GL_CTRL_SEGMENT27
      ,P_GL_CTRL_SEGMENT28              => P_GL_CTRL_SEGMENT28
      ,P_GL_CTRL_SEGMENT29              => P_GL_CTRL_SEGMENT29
      ,P_GL_CTRL_SEGMENT30              => P_GL_CTRL_SEGMENT30
      ,P_GL_CTRL_CONCAT_SEGMENTS        => P_GL_CTRL_CONCAT_SEGMENTS
      ,P_GL_CCRL_SEGMENT1               => P_GL_CCRL_SEGMENT1
      ,P_GL_CCRL_SEGMENT2               => P_GL_CCRL_SEGMENT2
      ,P_GL_CCRL_SEGMENT3               => P_GL_CCRL_SEGMENT3
      ,P_GL_CCRL_SEGMENT4               => P_GL_CCRL_SEGMENT4
      ,P_GL_CCRL_SEGMENT5               => P_GL_CCRL_SEGMENT5
      ,P_GL_CCRL_SEGMENT6               => P_GL_CCRL_SEGMENT6
      ,P_GL_CCRL_SEGMENT7               => P_GL_CCRL_SEGMENT7
      ,P_GL_CCRL_SEGMENT8               => P_GL_CCRL_SEGMENT8
      ,P_GL_CCRL_SEGMENT9               => P_GL_CCRL_SEGMENT9
      ,P_GL_CCRL_SEGMENT10              => P_GL_CCRL_SEGMENT10
      ,P_GL_CCRL_SEGMENT11              => P_GL_CCRL_SEGMENT11
      ,P_GL_CCRL_SEGMENT12              => P_GL_CCRL_SEGMENT12
      ,P_GL_CCRL_SEGMENT13              => P_GL_CCRL_SEGMENT13
      ,P_GL_CCRL_SEGMENT14              => P_GL_CCRL_SEGMENT14
      ,P_GL_CCRL_SEGMENT15              => P_GL_CCRL_SEGMENT15
      ,P_GL_CCRL_SEGMENT16              => P_GL_CCRL_SEGMENT16
      ,P_GL_CCRL_SEGMENT17              => P_GL_CCRL_SEGMENT17
      ,P_GL_CCRL_SEGMENT18              => P_GL_CCRL_SEGMENT18
      ,P_GL_CCRL_SEGMENT19              => P_GL_CCRL_SEGMENT19
      ,P_GL_CCRL_SEGMENT20              => P_GL_CCRL_SEGMENT20
      ,P_GL_CCRL_SEGMENT21              => P_GL_CCRL_SEGMENT21
      ,P_GL_CCRL_SEGMENT22              => P_GL_CCRL_SEGMENT22
      ,P_GL_CCRL_SEGMENT23              => P_GL_CCRL_SEGMENT23
      ,P_GL_CCRL_SEGMENT24              => P_GL_CCRL_SEGMENT24
      ,P_GL_CCRL_SEGMENT25              => P_GL_CCRL_SEGMENT25
      ,P_GL_CCRL_SEGMENT26              => P_GL_CCRL_SEGMENT26
      ,P_GL_CCRL_SEGMENT27              => P_GL_CCRL_SEGMENT27
      ,P_GL_CCRL_SEGMENT28              => P_GL_CCRL_SEGMENT28
      ,P_GL_CCRL_SEGMENT29              => P_GL_CCRL_SEGMENT29
      ,P_GL_CCRL_SEGMENT30              => P_GL_CCRL_SEGMENT30
      ,P_GL_CCRL_CONCAT_SEGMENTS        => P_GL_CCRL_CONCAT_SEGMENTS
      ,P_GL_ERR_SEGMENT1                => P_GL_ERR_SEGMENT1
      ,P_GL_ERR_SEGMENT2                => P_GL_ERR_SEGMENT2
      ,P_GL_ERR_SEGMENT3                => P_GL_ERR_SEGMENT3
      ,P_GL_ERR_SEGMENT4                => P_GL_ERR_SEGMENT4
      ,P_GL_ERR_SEGMENT5                => P_GL_ERR_SEGMENT5
      ,P_GL_ERR_SEGMENT6                => P_GL_ERR_SEGMENT6
      ,P_GL_ERR_SEGMENT7                => P_GL_ERR_SEGMENT7
      ,P_GL_ERR_SEGMENT8                => P_GL_ERR_SEGMENT8
      ,P_GL_ERR_SEGMENT9                => P_GL_ERR_SEGMENT9
      ,P_GL_ERR_SEGMENT10               => P_GL_ERR_SEGMENT10
      ,P_GL_ERR_SEGMENT11               => P_GL_ERR_SEGMENT11
      ,P_GL_ERR_SEGMENT12               => P_GL_ERR_SEGMENT12
      ,P_GL_ERR_SEGMENT13               => P_GL_ERR_SEGMENT13
      ,P_GL_ERR_SEGMENT14               => P_GL_ERR_SEGMENT14
      ,P_GL_ERR_SEGMENT15               => P_GL_ERR_SEGMENT15
      ,P_GL_ERR_SEGMENT16               => P_GL_ERR_SEGMENT16
      ,P_GL_ERR_SEGMENT17               => P_GL_ERR_SEGMENT17
      ,P_GL_ERR_SEGMENT18               => P_GL_ERR_SEGMENT18
      ,P_GL_ERR_SEGMENT19               => P_GL_ERR_SEGMENT19
      ,P_GL_ERR_SEGMENT20               => P_GL_ERR_SEGMENT20
      ,P_GL_ERR_SEGMENT21               => P_GL_ERR_SEGMENT21
      ,P_GL_ERR_SEGMENT22               => P_GL_ERR_SEGMENT22
      ,P_GL_ERR_SEGMENT23               => P_GL_ERR_SEGMENT23
      ,P_GL_ERR_SEGMENT24               => P_GL_ERR_SEGMENT24
      ,P_GL_ERR_SEGMENT25               => P_GL_ERR_SEGMENT25
      ,P_GL_ERR_SEGMENT26               => P_GL_ERR_SEGMENT26
      ,P_GL_ERR_SEGMENT27               => P_GL_ERR_SEGMENT27
      ,P_GL_ERR_SEGMENT28               => P_GL_ERR_SEGMENT28
      ,P_GL_ERR_SEGMENT29               => P_GL_ERR_SEGMENT29
      ,P_GL_ERR_SEGMENT30               => P_GL_ERR_SEGMENT30
      ,P_GL_ERR_CONCAT_SEGMENTS         => P_GL_ERR_CONCAT_SEGMENTS
      ,P_SETS_OF_BOOK_ID                => P_SETS_OF_BOOK_ID
      ,P_THIRD_PARTY_PAYMENT            => P_THIRD_PARTY_PAYMENT
      ,P_TRANSFER_TO_GL_FLAG            => P_TRANSFER_TO_GL_FLAG
      ,P_COST_PAYMENT                   => P_COST_PAYMENT
      ,P_COST_CLEARED_PAYMENT           => P_COST_CLEARED_PAYMENT
      ,P_COST_CLEARED_VOID_PAYMENT      => P_COST_CLEARED_VOID_PAYMENT
      ,P_EXCLUDE_MANUAL_PAYMENT         => P_EXCLUDE_MANUAL_PAYMENT
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_org_payment_method_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 25);
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  -- Call table handler pay_exa_ins to control the processing of the external
  -- account combination keyflex, discarding the returning parameter
  -- p_object_version_number
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'payment_type_id'
                            ,p_argument_value => p_payment_type_id
                            );
  --
  open csr_territory_code(p_payment_type_id,p_business_group_id);
  fetch csr_territory_code into l_territory_code;
  if (csr_territory_code%notfound) then
     close csr_territory_code;
     fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
     fnd_message.set_token('COLUMN_NAME', 'PAYMENT_TYPE_ID');
     fnd_message.raise_error;
  end if;
  close csr_territory_code;
  --
  hr_utility.set_location(l_proc, 30);
  IF (P_PMETH_INFORMATION1 IS NOT NULL OR
      P_PMETH_INFORMATION2 IS NOT NULL OR
      P_PMETH_INFORMATION3 IS NOT NULL OR
      P_PMETH_INFORMATION4 IS NOT NULL OR
      P_PMETH_INFORMATION5 IS NOT NULL OR
      P_PMETH_INFORMATION6 IS NOT NULL OR
      P_PMETH_INFORMATION7 IS NOT NULL OR
      P_PMETH_INFORMATION8 IS NOT NULL OR
      P_PMETH_INFORMATION9 IS NOT NULL OR
      P_PMETH_INFORMATION10 IS NOT NULL OR
      P_PMETH_INFORMATION11 IS NOT NULL OR
      P_PMETH_INFORMATION12 IS NOT NULL OR
      P_PMETH_INFORMATION13 IS NOT NULL OR
      P_PMETH_INFORMATION14 IS NOT NULL OR
      P_PMETH_INFORMATION15 IS NOT NULL OR
      P_PMETH_INFORMATION16 IS NOT NULL OR
      P_PMETH_INFORMATION17 IS NOT NULL OR
      P_PMETH_INFORMATION18 IS NOT NULL OR
      P_PMETH_INFORMATION19 IS NOT NULL OR
      P_PMETH_INFORMATION20 IS NOT NULL ) THEN

      open csr_pmeth_category(p_payment_type_id);
      fetch csr_pmeth_category into l_PMETH_INFORMATION_CATEGORY;
      if (csr_pmeth_category%notfound) then
         close csr_pmeth_category;
         fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
         fnd_message.set_token('COLUMN_NAME', 'PMETH_INFORMATION_CATEGORY');
         fnd_message.raise_error;
      end if;
      close csr_pmeth_category;
  END IF;
  --
  hr_utility.set_location(l_proc, 35);
  --
  open csr_currency_code(p_payment_type_id);
  fetch csr_currency_code into l_currency_code;
  if (csr_currency_code%notfound) then
     close csr_currency_code;
     fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
     fnd_message.set_token('COLUMN_NAME', 'PAYMENT_TYPE_ID');
     fnd_message.raise_error;
  end if;
  close csr_currency_code;
  if (p_currency_code is not null) then
     l_currency_code := p_currency_code;
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  --
  if (p_segment1 is not null or
      p_segment2 is not null or
      p_segment3 is not null or
      p_segment4 is not null or
      p_segment5 is not null or
      p_segment6 is not null or
      p_segment7 is not null or
      p_segment8 is not null or
      p_segment9 is not null or
      p_segment10 is not null or
      p_segment11 is not null or
      p_segment12 is not null or
      p_segment13 is not null or
      p_segment14 is not null or
      p_segment15 is not null or
      p_segment16 is not null or
      p_segment17 is not null or
      p_segment18 is not null or
      p_segment19 is not null or
      p_segment20 is not null or
      p_segment21 is not null or
      p_segment22 is not null or
      p_segment23 is not null or
      p_segment24 is not null or
      p_segment25 is not null or
      p_segment26 is not null or
      p_segment27 is not null or
      p_segment28 is not null or
      p_segment29 is not null or
      p_segment30 is not null )  then
  --
    pay_exa_ins.ins_or_sel
    (p_segment1              => p_segment1
    ,p_segment2              => p_segment2
    ,p_segment3              => p_segment3
    ,p_segment4              => p_segment4
    ,p_segment5              => p_segment5
    ,p_segment6              => p_segment6
    ,p_segment7              => p_segment7
    ,p_segment8              => p_segment8
    ,p_segment9              => p_segment9
    ,p_segment10             => p_segment10
    ,p_segment11             => p_segment11
    ,p_segment12             => p_segment12
    ,p_segment13             => p_segment13
    ,p_segment14             => p_segment14
    ,p_segment15             => p_segment15
    ,p_segment16             => p_segment16
    ,p_segment17             => p_segment17
    ,p_segment18             => p_segment18
    ,p_segment19             => p_segment19
    ,p_segment20             => p_segment20
    ,p_segment21             => p_segment21
    ,p_segment22             => p_segment22
    ,p_segment23             => p_segment23
    ,p_segment24             => p_segment24
    ,p_segment25             => p_segment25
    ,p_segment26             => p_segment26
    ,p_segment27             => p_segment27
    ,p_segment28             => p_segment28
    ,p_segment29             => p_segment29
    ,p_segment30             => p_segment30
    ,p_concat_segments       => p_concat_segments
    ,p_business_group_id     => p_business_group_id
    ,p_territory_code        => l_territory_code
    ,p_external_account_id   => l_external_account_id
    ,p_object_version_number => l_discard
    );
  else
    l_territory_code := null;
  end if;
  --
  -- Determine the Assest definition by calling ins_or_sel.
  --
  hr_utility.set_location(l_proc, 45);
  l_set_of_books_id         := p_sets_of_book_id;
  l_gl_cash_ac_id           := null;
  l_gl_cash_clearing_ac_id  := null;
  l_gl_control_ac_id        := null;
  l_gl_error_ac_id          := null;

  l_def_gl_cash_ac_id           := null;
  l_def_gl_cash_clearing_ac_id  := null;
  l_def_gl_control_ac_id        := null;
  l_def_gl_error_ac_id          := null;
  l_def_set_of_books_id	        := null;
  --
  if (l_set_of_books_id is not null) then
     --
     open csr_chart_of_accounts_id(l_set_of_books_id);
     fetch csr_chart_of_accounts_id into l_key_flex_id;
     if (csr_chart_of_accounts_id%notfound and l_set_of_books_id<>0) then
        close csr_chart_of_accounts_id;
        fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
        fnd_message.set_token('COLUMN_NAME', 'sets_of_book_id');
        fnd_message.raise_error;
     end if;
     close csr_chart_of_accounts_id;
     --
  if l_key_flex_id is not null then
  --
     if (p_gl_segment1 is not null or
      p_gl_segment2 is not null or
      p_gl_segment3 is not null or
      p_gl_segment4 is not null or
      p_gl_segment5 is not null or
      p_gl_segment6 is not null or
      p_gl_segment7 is not null or
      p_gl_segment8 is not null or
      p_gl_segment9 is not null or
      p_gl_segment10 is not null or
      p_gl_segment11 is not null or
      p_gl_segment12 is not null or
      p_gl_segment13 is not null or
      p_gl_segment14 is not null or
      p_gl_segment15 is not null or
      p_gl_segment16 is not null or
      p_gl_segment17 is not null or
      p_gl_segment18 is not null or
      p_gl_segment19 is not null or
      p_gl_segment20 is not null or
      p_gl_segment21 is not null or
      p_gl_segment22 is not null or
      p_gl_segment23 is not null or
      p_gl_segment24 is not null or
      p_gl_segment25 is not null or
      p_gl_segment26 is not null or
      p_gl_segment27 is not null or
      p_gl_segment28 is not null or
      p_gl_segment29 is not null or
      p_gl_segment30 is not null )  then
      --
		hr_kflex_utility.ins_or_sel_keyflex_comb
	       (p_appl_short_name       => 'SQLGL'
	       ,p_flex_code             => 'GL#'
	       ,p_flex_num              => l_key_flex_id
	       ,p_segment1              => p_gl_segment1
	       ,p_segment2              => p_gl_segment2
	       ,p_segment3              => p_gl_segment3
	       ,p_segment4              => p_gl_segment4
	       ,p_segment5              => p_gl_segment5
	       ,p_segment6              => p_gl_segment6
	       ,p_segment7              => p_gl_segment7
	       ,p_segment8              => p_gl_segment8
	       ,p_segment9              => p_gl_segment9
	       ,p_segment10             => p_gl_segment10
	       ,p_segment11             => p_gl_segment11
	       ,p_segment12             => p_gl_segment12
	       ,p_segment13             => p_gl_segment13
	       ,p_segment14             => p_gl_segment14
	       ,p_segment15             => p_gl_segment15
	       ,p_segment16             => p_gl_segment16
	       ,p_segment17             => p_gl_segment17
	       ,p_segment18             => p_gl_segment18
	       ,p_segment19             => p_gl_segment19
	       ,p_segment20             => p_gl_segment20
	       ,p_segment21             => p_gl_segment21
	       ,p_segment22             => p_gl_segment22
	       ,p_segment23             => p_gl_segment23
	       ,p_segment24             => p_gl_segment24
	       ,p_segment25             => p_gl_segment25
	       ,p_segment26             => p_gl_segment26
	       ,p_segment27             => p_gl_segment27
	       ,p_segment28             => p_gl_segment28
	       ,p_segment29             => p_gl_segment29
	       ,p_segment30             => p_gl_segment30
	       ,p_concat_segments_in    => p_gl_concat_segments
	       ,p_ccid                  => l_gl_cash_ac_id
	       ,p_concat_segments_out   => l_gl_concat_segments
	       );
		l_ASSET_CODE_COMBINATION_ID := l_gl_cash_ac_id;
      --
      end if;
      hr_utility.set_location(l_proc, 50);
      if (p_gl_ctrl_segment1 is not null or
      p_gl_ctrl_segment2 is not null or
      p_gl_ctrl_segment3 is not null or
      p_gl_ctrl_segment4 is not null or
      p_gl_ctrl_segment5 is not null or
      p_gl_ctrl_segment6 is not null or
      p_gl_ctrl_segment7 is not null or
      p_gl_ctrl_segment8 is not null or
      p_gl_ctrl_segment9 is not null or
      p_gl_ctrl_segment10 is not null or
      p_gl_ctrl_segment11 is not null or
      p_gl_ctrl_segment12 is not null or
      p_gl_ctrl_segment13 is not null or
      p_gl_ctrl_segment14 is not null or
      p_gl_ctrl_segment15 is not null or
      p_gl_ctrl_segment16 is not null or
      p_gl_ctrl_segment17 is not null or
      p_gl_ctrl_segment18 is not null or
      p_gl_ctrl_segment19 is not null or
      p_gl_ctrl_segment20 is not null or
      p_gl_ctrl_segment21 is not null or
      p_gl_ctrl_segment22 is not null or
      p_gl_ctrl_segment23 is not null or
      p_gl_ctrl_segment24 is not null or
      p_gl_ctrl_segment25 is not null or
      p_gl_ctrl_segment26 is not null or
      p_gl_ctrl_segment27 is not null or
      p_gl_ctrl_segment28 is not null or
      p_gl_ctrl_segment29 is not null or
      p_gl_ctrl_segment30 is not null )  then
      --
		hr_kflex_utility.ins_or_sel_keyflex_comb
	       (p_appl_short_name       => 'SQLGL'
	       ,p_flex_code             => 'GL#'
	       ,p_flex_num              => l_key_flex_id
	       ,p_segment1              => p_gl_ctrl_segment1
	       ,p_segment2              => p_gl_ctrl_segment2
	       ,p_segment3              => p_gl_ctrl_segment3
	       ,p_segment4              => p_gl_ctrl_segment4
	       ,p_segment5              => p_gl_ctrl_segment5
	       ,p_segment6              => p_gl_ctrl_segment6
	       ,p_segment7              => p_gl_ctrl_segment7
	       ,p_segment8              => p_gl_ctrl_segment8
	       ,p_segment9              => p_gl_ctrl_segment9
	       ,p_segment10             => p_gl_ctrl_segment10
	       ,p_segment11             => p_gl_ctrl_segment11
	       ,p_segment12             => p_gl_ctrl_segment12
	       ,p_segment13             => p_gl_ctrl_segment13
	       ,p_segment14             => p_gl_ctrl_segment14
	       ,p_segment15             => p_gl_ctrl_segment15
	       ,p_segment16             => p_gl_ctrl_segment16
	       ,p_segment17             => p_gl_ctrl_segment17
	       ,p_segment18             => p_gl_ctrl_segment18
	       ,p_segment19             => p_gl_ctrl_segment19
	       ,p_segment20             => p_gl_ctrl_segment20
	       ,p_segment21             => p_gl_ctrl_segment21
	       ,p_segment22             => p_gl_ctrl_segment22
	       ,p_segment23             => p_gl_ctrl_segment23
	       ,p_segment24             => p_gl_ctrl_segment24
	       ,p_segment25             => p_gl_ctrl_segment25
	       ,p_segment26             => p_gl_ctrl_segment26
	       ,p_segment27             => p_gl_ctrl_segment27
	       ,p_segment28             => p_gl_ctrl_segment28
	       ,p_segment29             => p_gl_ctrl_segment29
	       ,p_segment30             => p_gl_ctrl_segment30
	       ,p_concat_segments_in    => p_gl_ctrl_concat_segments
	       ,p_ccid                  => l_gl_control_ac_id
	       ,p_concat_segments_out   => l_gl_control_concat_segment
	       );
     --
     end if;
     hr_utility.set_location(l_proc, 55);
     if (p_gl_ccrl_segment1 is not null or
      p_gl_ccrl_segment2 is not null or
      p_gl_ccrl_segment3 is not null or
      p_gl_ccrl_segment4 is not null or
      p_gl_ccrl_segment5 is not null or
      p_gl_ccrl_segment6 is not null or
      p_gl_ccrl_segment7 is not null or
      p_gl_ccrl_segment8 is not null or
      p_gl_ccrl_segment9 is not null or
      p_gl_ccrl_segment10 is not null or
      p_gl_ccrl_segment11 is not null or
      p_gl_ccrl_segment12 is not null or
      p_gl_ccrl_segment13 is not null or
      p_gl_ccrl_segment14 is not null or
      p_gl_ccrl_segment15 is not null or
      p_gl_ccrl_segment16 is not null or
      p_gl_ccrl_segment17 is not null or
      p_gl_ccrl_segment18 is not null or
      p_gl_ccrl_segment19 is not null or
      p_gl_ccrl_segment20 is not null or
      p_gl_ccrl_segment21 is not null or
      p_gl_ccrl_segment22 is not null or
      p_gl_ccrl_segment23 is not null or
      p_gl_ccrl_segment24 is not null or
      p_gl_ccrl_segment25 is not null or
      p_gl_ccrl_segment26 is not null or
      p_gl_ccrl_segment27 is not null or
      p_gl_ccrl_segment28 is not null or
      p_gl_ccrl_segment29 is not null or
      p_gl_ccrl_segment30 is not null )  then
      --
		hr_kflex_utility.ins_or_sel_keyflex_comb
	       (p_appl_short_name       => 'SQLGL'
	       ,p_flex_code             => 'GL#'
	       ,p_flex_num              => l_key_flex_id
	       ,p_segment1              => p_gl_ccrl_segment1
	       ,p_segment2              => p_gl_ccrl_segment2
	       ,p_segment3              => p_gl_ccrl_segment3
	       ,p_segment4              => p_gl_ccrl_segment4
	       ,p_segment5              => p_gl_ccrl_segment5
	       ,p_segment6              => p_gl_ccrl_segment6
	       ,p_segment7              => p_gl_ccrl_segment7
	       ,p_segment8              => p_gl_ccrl_segment8
	       ,p_segment9              => p_gl_ccrl_segment9
	       ,p_segment10             => p_gl_ccrl_segment10
	       ,p_segment11             => p_gl_ccrl_segment11
	       ,p_segment12             => p_gl_ccrl_segment12
	       ,p_segment13             => p_gl_ccrl_segment13
	       ,p_segment14             => p_gl_ccrl_segment14
	       ,p_segment15             => p_gl_ccrl_segment15
	       ,p_segment16             => p_gl_ccrl_segment16
	       ,p_segment17             => p_gl_ccrl_segment17
	       ,p_segment18             => p_gl_ccrl_segment18
	       ,p_segment19             => p_gl_ccrl_segment19
	       ,p_segment20             => p_gl_ccrl_segment20
	       ,p_segment21             => p_gl_ccrl_segment21
	       ,p_segment22             => p_gl_ccrl_segment22
	       ,p_segment23             => p_gl_ccrl_segment23
	       ,p_segment24             => p_gl_ccrl_segment24
	       ,p_segment25             => p_gl_ccrl_segment25
	       ,p_segment26             => p_gl_ccrl_segment26
	       ,p_segment27             => p_gl_ccrl_segment27
	       ,p_segment28             => p_gl_ccrl_segment28
	       ,p_segment29             => p_gl_ccrl_segment29
	       ,p_segment30             => p_gl_ccrl_segment30
	       ,p_concat_segments_in    => p_gl_ccrl_concat_segments
	       ,p_ccid                  => l_gl_cash_clearing_ac_id
	       ,p_concat_segments_out   => l_gl_csh_clr_concat_segment
		);
     --
     end if;
     hr_utility.set_location(l_proc, 60);
     if (p_gl_err_segment1 is not null or
      p_gl_err_segment2 is not null or
      p_gl_err_segment3 is not null or
      p_gl_err_segment4 is not null or
      p_gl_err_segment5 is not null or
      p_gl_err_segment6 is not null or
      p_gl_err_segment7 is not null or
      p_gl_err_segment8 is not null or
      p_gl_err_segment9 is not null or
      p_gl_err_segment10 is not null or
      p_gl_err_segment11 is not null or
      p_gl_err_segment12 is not null or
      p_gl_err_segment13 is not null or
      p_gl_err_segment14 is not null or
      p_gl_err_segment15 is not null or
      p_gl_err_segment16 is not null or
      p_gl_err_segment17 is not null or
      p_gl_err_segment18 is not null or
      p_gl_err_segment19 is not null or
      p_gl_err_segment20 is not null or
      p_gl_err_segment21 is not null or
      p_gl_err_segment22 is not null or
      p_gl_err_segment23 is not null or
      p_gl_err_segment24 is not null or
      p_gl_err_segment25 is not null or
      p_gl_err_segment26 is not null or
      p_gl_err_segment27 is not null or
      p_gl_err_segment28 is not null or
      p_gl_err_segment29 is not null or
      p_gl_err_segment30 is not null )  then
      --
		hr_kflex_utility.ins_or_sel_keyflex_comb
	       (p_appl_short_name       => 'SQLGL'
	       ,p_flex_code             => 'GL#'
	       ,p_flex_num              => l_key_flex_id
	       ,p_segment1              => p_gl_err_segment1
	       ,p_segment2              => p_gl_err_segment2
	       ,p_segment3              => p_gl_err_segment3
	       ,p_segment4              => p_gl_err_segment4
	       ,p_segment5              => p_gl_err_segment5
	       ,p_segment6              => p_gl_err_segment6
	       ,p_segment7              => p_gl_err_segment7
	       ,p_segment8              => p_gl_err_segment8
	       ,p_segment9              => p_gl_err_segment9
	       ,p_segment10             => p_gl_err_segment10
	       ,p_segment11             => p_gl_err_segment11
	       ,p_segment12             => p_gl_err_segment12
	       ,p_segment13             => p_gl_err_segment13
	       ,p_segment14             => p_gl_err_segment14
	       ,p_segment15             => p_gl_err_segment15
	       ,p_segment16             => p_gl_err_segment16
	       ,p_segment17             => p_gl_err_segment17
	       ,p_segment18             => p_gl_err_segment18
	       ,p_segment19             => p_gl_err_segment19
	       ,p_segment20             => p_gl_err_segment20
	       ,p_segment21             => p_gl_err_segment21
	       ,p_segment22             => p_gl_err_segment22
	       ,p_segment23             => p_gl_err_segment23
	       ,p_segment24             => p_gl_err_segment24
	       ,p_segment25             => p_gl_err_segment25
	       ,p_segment26             => p_gl_err_segment26
	       ,p_segment27             => p_gl_err_segment27
	       ,p_segment28             => p_gl_err_segment28
	       ,p_segment29             => p_gl_err_segment29
	       ,p_segment30             => p_gl_err_segment30
	       ,p_concat_segments_in    => p_gl_err_concat_segments
	       ,p_ccid                  => l_gl_error_ac_id
	       ,p_concat_segments_out   => l_gl_error_concat_segment
	       );
	  --
	  end if;
	--
	end if;
  --
  end if;
  --
  hr_utility.set_location(l_proc, 65);
  --
  -- Obtains the defined balance id based on the 3rd Party Payment Flag.
  --
  if (P_THIRD_PARTY_PAYMENT = 'Y') then
     l_defined_balance_id := null;
  else
     hr_api.mandatory_arg_error(p_api_name => l_proc
                         ,p_argument       => 'business_group_id'
                         ,p_argument_value => p_business_group_id
                         );
     --
     open csr_def_balance(p_business_group_id);
     fetch csr_def_balance into l_defined_balance_id;
     if (csr_def_balance%notfound) then
        close csr_def_balance;
        fnd_message.set_name('PAY', 'PAY_52982_NO_PAY_METH_DEFINED');
        fnd_message.raise_error;
     end if;
     close csr_def_balance;
  end if;

  hr_utility.set_location(l_proc, 70);
  --
  pay_opm_ins.ins
      (p_effective_date                  => l_effective_date
      ,p_business_group_id               => p_business_group_id
      ,p_external_account_id             => l_external_account_id
      ,p_currency_code                   => l_currency_code
      ,p_payment_type_id                 => p_payment_type_id
      ,p_org_payment_method_name         => p_org_payment_method_name
      ,p_defined_balance_id              => l_defined_balance_id
      ,p_comments                        => p_comments
      ,p_attribute_category              => p_attribute_category
      ,p_attribute1                      => p_attribute1
      ,p_attribute2                      => p_attribute2
      ,p_attribute3                      => p_attribute3
      ,p_attribute4                      => p_attribute4
      ,p_attribute5                      => p_attribute5
      ,p_attribute6                      => p_attribute6
      ,p_attribute7                      => p_attribute7
      ,p_attribute8                      => p_attribute8
      ,p_attribute9                      => p_attribute9
      ,p_attribute10                     => p_attribute10
      ,p_attribute11                     => p_attribute11
      ,p_attribute12                     => p_attribute12
      ,p_attribute13                     => p_attribute13
      ,p_attribute14                     => p_attribute14
      ,p_attribute15                     => p_attribute15
      ,p_attribute16                     => p_attribute16
      ,p_attribute17                     => p_attribute17
      ,p_attribute18                     => p_attribute18
      ,p_attribute19                     => p_attribute19
      ,p_attribute20                     => p_attribute20
      ,p_pmeth_information_category      => l_pmeth_information_category
      ,p_pmeth_information1              => p_pmeth_information1
      ,p_pmeth_information2              => p_pmeth_information2
      ,p_pmeth_information3              => p_pmeth_information3
      ,p_pmeth_information4              => p_pmeth_information4
      ,p_pmeth_information5              => p_pmeth_information5
      ,p_pmeth_information6              => p_pmeth_information6
      ,p_pmeth_information7              => p_pmeth_information7
      ,p_pmeth_information8              => p_pmeth_information8
      ,p_pmeth_information9              => p_pmeth_information9
      ,p_pmeth_information10             => p_pmeth_information10
      ,p_pmeth_information11             => p_pmeth_information11
      ,p_pmeth_information12             => p_pmeth_information12
      ,p_pmeth_information13             => p_pmeth_information13
      ,p_pmeth_information14             => p_pmeth_information14
      ,p_pmeth_information15             => p_pmeth_information15
      ,p_pmeth_information16             => p_pmeth_information16
      ,p_pmeth_information17             => p_pmeth_information17
      ,p_pmeth_information18             => p_pmeth_information18
      ,p_pmeth_information19             => p_pmeth_information19
      ,p_pmeth_information20             => p_pmeth_information20
      ,p_TRANSFER_TO_GL_FLAG             => p_TRANSFER_TO_GL_FLAG
      ,p_cost_payment                    => p_cost_payment
      ,p_cost_cleared_payment            => p_cost_cleared_payment
      ,p_cost_cleared_void_payment       => p_cost_cleared_void_payment
      ,p_exclude_manual_payment          => p_exclude_manual_payment
      ,p_org_payment_method_id           => l_org_payment_method_id
      ,p_object_version_number           => l_object_version_number
      ,p_effective_start_date            => l_effective_start_date
      ,p_effective_end_date              => l_effective_end_date
      ,p_comment_id                      => l_comment_id
      );
  --
  hr_utility.set_location(l_proc, 75);
  --
  pay_opt_ins.ins_tl
      (p_language_code                  => l_language_code
      ,p_org_payment_method_id          => l_org_payment_method_id
      ,p_org_payment_method_name        => p_org_payment_method_name
      );
  --
  hr_utility.set_location(l_proc, 80);
  --
  hr_utility.set_location(l_proc, 85);
  if((L_DEFAULT_GL_ACCOUNT IS NULL OR L_DEFAULT_GL_ACCOUNT = 'N')
      and l_external_account_id is not null and
      PAY_PAYMENT_GL_ACCOUNTS_PKG.DEFAULT_GL_ACCOUNTS(l_external_account_id) is NULL ) then
     L_DEFAULT_GL_ACCOUNT := 'Y';
  end if;
  --
  if (l_gl_cash_ac_id is null and l_gl_cash_clearing_ac_id is null and
      l_gl_control_ac_id is null and l_gl_error_ac_id is null)
      and (l_external_account_id is not null) then
  --
	open csr_gl_accounts(l_external_account_id);
	fetch csr_gl_accounts into l_def_gl_cash_ac_id,l_def_gl_cash_clearing_ac_id,
				   l_def_gl_control_ac_id, l_def_gl_error_ac_id,
				   l_def_set_of_books_id;
	if (csr_gl_accounts%found) then
	--
		l_gl_cash_ac_id := l_def_gl_cash_ac_id;
		l_ASSET_CODE_COMBINATION_ID := l_def_gl_cash_ac_id;
		l_gl_cash_clearing_ac_id := l_def_gl_cash_clearing_ac_id;
		l_gl_control_ac_id := l_def_gl_control_ac_id;
		l_gl_error_ac_id := l_def_gl_error_ac_id;
		l_set_of_books_id := l_def_set_of_books_id;
	--
	end if;
	close csr_gl_accounts;
  --
  end if;
  --
  --
  -- Validation for the cost and cost cleared payments.
  -- If the cost cleared payment is set to 'Y' then all the Cash, Cash Clearing,
  -- Control and Error A/Cs should be there.
  -- If the cost cleared or cost payment is set then Cash and Cash Clearing A/Cs
  -- should be there.

  l_cstclr_flag := p_cost_cleared_payment;
  l_cst_flag := p_cost_payment;

  if (l_cstclr_flag = 'Y') and (l_gl_cash_ac_id is null or
				l_gl_cash_clearing_ac_id is null or
				l_gl_control_ac_id is null or
				l_gl_error_ac_id is null) then
     fnd_message.set_name('PAY', 'PAY_33420_INV_CSTCLR_IDS');
     fnd_message.raise_error;
  elsif (l_cst_flag = 'Y' ) and (l_gl_cash_ac_id is null or
			     l_gl_cash_clearing_ac_id is null) then
     fnd_message.set_name('PAY', 'PAY_33421_INV_CST_IDS');
     fnd_message.raise_error;
  end if;
  --
  --
  -- Updating the ap_bank_accounts_all
  if pay_ce_support_pkg.pay_and_ce_licensed and l_external_account_id is not null then
  --
     --Bug No. 4644827
     --
     --   for r11.5 the same functionality is done through database trigger. Code
     --   is for R12
          if ( p_bank_account_id IS NOT  NULL ) AND (l_external_account_id IS NOT NULL ) then
             pay_maintain_bank_acct.update_payroll_bank_acct(
        	      p_bank_account_id     => p_bank_account_id,
                      p_external_account_id => l_external_account_id,
		      p_org_payment_method_id => l_org_payment_method_id);
          end if;

     pay_maintain_bank_acct.update_asset_ccid(
                   p_assest_ccid              =>l_ASSET_CODE_COMBINATION_ID,
                   p_set_of_books_id          =>l_set_of_books_id,
                   p_external_account_id      =>l_external_account_id
                   );
  --
  end if;
  --
  --Inserting the values into PAY_PAYMENT_GL_ACCOUNTS table.

  hr_utility.set_location(l_proc, 90);
  PAY_PAYMENT_GL_ACCOUNTS_PKG.INSERT_ROW (
  P_PAY_GL_ACCOUNT_ID		=> l_pay_gl_account_id,
  P_EFFECTIVE_START_DATE	=> l_effective_start_date,
  P_EFFECTIVE_END_DATE		=> l_effective_end_date,
  P_SET_OF_BOOKS_ID		=> l_set_of_books_id,
  P_GL_CASH_AC_ID		=> l_gl_cash_ac_id,
  P_GL_CASH_CLEARING_AC_ID	=> l_gl_cash_clearing_ac_id,
  P_GL_CONTROL_AC_ID		=> l_gl_control_ac_id,
  P_GL_ERROR_AC_ID		=> l_gl_error_ac_id,
  P_EXTERNAL_ACCOUNT_ID		=> l_external_account_id,
  P_ORG_PAYMENT_METHOD_ID	=> l_org_payment_method_id,
  P_DEFAULT_GL_ACCOUNT		=> L_DEFAULT_GL_ACCOUNT);
  --
  hr_utility.set_location(l_proc, 95);
  --
  -- Call After Process User Hook
  --
  begin
    pay_org_payment_method_bk1.create_org_payment_method_a
      (P_EFFECTIVE_DATE                 => l_EFFECTIVE_DATE
      ,P_LANGUAGE_CODE                  => l_LANGUAGE_CODE
      ,P_BUSINESS_GROUP_ID              => P_BUSINESS_GROUP_ID
      ,P_ORG_PAYMENT_METHOD_NAME        => P_ORG_PAYMENT_METHOD_NAME
      ,P_PAYMENT_TYPE_ID                => P_PAYMENT_TYPE_ID
      ,P_CURRENCY_CODE                  => l_CURRENCY_CODE
      ,P_ATTRIBUTE_CATEGORY             => P_ATTRIBUTE_CATEGORY
      ,P_ATTRIBUTE1                     => P_ATTRIBUTE1
      ,P_ATTRIBUTE2                     => P_ATTRIBUTE2
      ,P_ATTRIBUTE3                     => P_ATTRIBUTE3
      ,P_ATTRIBUTE4                     => P_ATTRIBUTE4
      ,P_ATTRIBUTE5                     => P_ATTRIBUTE5
      ,P_ATTRIBUTE6                     => P_ATTRIBUTE6
      ,P_ATTRIBUTE7                     => P_ATTRIBUTE7
      ,P_ATTRIBUTE8                     => P_ATTRIBUTE8
      ,P_ATTRIBUTE9                     => P_ATTRIBUTE9
      ,P_ATTRIBUTE10                    => P_ATTRIBUTE10
      ,P_ATTRIBUTE11                    => P_ATTRIBUTE11
      ,P_ATTRIBUTE12                    => P_ATTRIBUTE12
      ,P_ATTRIBUTE13                    => P_ATTRIBUTE13
      ,P_ATTRIBUTE14                    => P_ATTRIBUTE14
      ,P_ATTRIBUTE15                    => P_ATTRIBUTE15
      ,P_ATTRIBUTE16                    => P_ATTRIBUTE16
      ,P_ATTRIBUTE17                    => P_ATTRIBUTE17
      ,P_ATTRIBUTE18                    => P_ATTRIBUTE18
      ,P_ATTRIBUTE19                    => P_ATTRIBUTE19
      ,P_ATTRIBUTE20                    => P_ATTRIBUTE20
--      ,P_PMETH_INFORMATION_CATEGORY     => P_PMETH_INFORMATION_CATEGORY
      ,P_PMETH_INFORMATION1             => P_PMETH_INFORMATION1
      ,P_PMETH_INFORMATION2             => P_PMETH_INFORMATION2
      ,P_PMETH_INFORMATION3             => P_PMETH_INFORMATION3
      ,P_PMETH_INFORMATION4             => P_PMETH_INFORMATION4
      ,P_PMETH_INFORMATION5             => P_PMETH_INFORMATION5
      ,P_PMETH_INFORMATION6             => P_PMETH_INFORMATION6
      ,P_PMETH_INFORMATION7             => P_PMETH_INFORMATION7
      ,P_PMETH_INFORMATION8             => P_PMETH_INFORMATION8
      ,P_PMETH_INFORMATION9             => P_PMETH_INFORMATION9
      ,P_PMETH_INFORMATION10            => P_PMETH_INFORMATION10
      ,P_PMETH_INFORMATION11            => P_PMETH_INFORMATION11
      ,P_PMETH_INFORMATION12            => P_PMETH_INFORMATION12
      ,P_PMETH_INFORMATION13            => P_PMETH_INFORMATION13
      ,P_PMETH_INFORMATION14            => P_PMETH_INFORMATION14
      ,P_PMETH_INFORMATION15            => P_PMETH_INFORMATION15
      ,P_PMETH_INFORMATION16            => P_PMETH_INFORMATION16
      ,P_PMETH_INFORMATION17            => P_PMETH_INFORMATION17
      ,P_PMETH_INFORMATION18            => P_PMETH_INFORMATION18
      ,P_PMETH_INFORMATION19            => P_PMETH_INFORMATION19
      ,P_PMETH_INFORMATION20            => P_PMETH_INFORMATION20
      ,P_COMMENTS                       => P_COMMENTS
      ,P_SEGMENT1                       => P_SEGMENT1
      ,P_SEGMENT2                       => P_SEGMENT2
      ,P_SEGMENT3                       => P_SEGMENT3
      ,P_SEGMENT4                       => P_SEGMENT4
      ,P_SEGMENT5                       => P_SEGMENT5
      ,P_SEGMENT6                       => P_SEGMENT6
      ,P_SEGMENT7                       => P_SEGMENT7
      ,P_SEGMENT8                       => P_SEGMENT8
      ,P_SEGMENT9                       => P_SEGMENT9
      ,P_SEGMENT10                      => P_SEGMENT10
      ,P_SEGMENT11                      => P_SEGMENT11
      ,P_SEGMENT12                      => P_SEGMENT12
      ,P_SEGMENT13                      => P_SEGMENT13
      ,P_SEGMENT14                      => P_SEGMENT14
      ,P_SEGMENT15                      => P_SEGMENT15
      ,P_SEGMENT16                      => P_SEGMENT16
      ,P_SEGMENT17                      => P_SEGMENT17
      ,P_SEGMENT18                      => P_SEGMENT18
      ,P_SEGMENT19                      => P_SEGMENT19
      ,P_SEGMENT20                      => P_SEGMENT20
      ,P_SEGMENT21                      => P_SEGMENT21
      ,P_SEGMENT22                      => P_SEGMENT22
      ,P_SEGMENT23                      => P_SEGMENT23
      ,P_SEGMENT24                      => P_SEGMENT24
      ,P_SEGMENT25                      => P_SEGMENT25
      ,P_SEGMENT26                      => P_SEGMENT26
      ,P_SEGMENT27                      => P_SEGMENT27
      ,P_SEGMENT28                      => P_SEGMENT28
      ,P_SEGMENT29                      => P_SEGMENT29
      ,P_SEGMENT30                      => P_SEGMENT30
      ,P_CONCAT_SEGMENTS                => P_CONCAT_SEGMENTS
      ,P_GL_SEGMENT1                    => P_GL_SEGMENT1
      ,P_GL_SEGMENT2                    => P_GL_SEGMENT2
      ,P_GL_SEGMENT3                    => P_GL_SEGMENT3
      ,P_GL_SEGMENT4                    => P_GL_SEGMENT4
      ,P_GL_SEGMENT5                    => P_GL_SEGMENT5
      ,P_GL_SEGMENT6                    => P_GL_SEGMENT6
      ,P_GL_SEGMENT7                    => P_GL_SEGMENT7
      ,P_GL_SEGMENT8                    => P_GL_SEGMENT8
      ,P_GL_SEGMENT9                    => P_GL_SEGMENT9
      ,P_GL_SEGMENT10                   => P_GL_SEGMENT10
      ,P_GL_SEGMENT11                   => P_GL_SEGMENT11
      ,P_GL_SEGMENT12                   => P_GL_SEGMENT12
      ,P_GL_SEGMENT13                   => P_GL_SEGMENT13
      ,P_GL_SEGMENT14                   => P_GL_SEGMENT14
      ,P_GL_SEGMENT15                   => P_GL_SEGMENT15
      ,P_GL_SEGMENT16                   => P_GL_SEGMENT16
      ,P_GL_SEGMENT17                   => P_GL_SEGMENT17
      ,P_GL_SEGMENT18                   => P_GL_SEGMENT18
      ,P_GL_SEGMENT19                   => P_GL_SEGMENT19
      ,P_GL_SEGMENT20                   => P_GL_SEGMENT20
      ,P_GL_SEGMENT21                   => P_GL_SEGMENT21
      ,P_GL_SEGMENT22                   => P_GL_SEGMENT22
      ,P_GL_SEGMENT23                   => P_GL_SEGMENT23
      ,P_GL_SEGMENT24                   => P_GL_SEGMENT24
      ,P_GL_SEGMENT25                   => P_GL_SEGMENT25
      ,P_GL_SEGMENT26                   => P_GL_SEGMENT26
      ,P_GL_SEGMENT27                   => P_GL_SEGMENT27
      ,P_GL_SEGMENT28                   => P_GL_SEGMENT28
      ,P_GL_SEGMENT29                   => P_GL_SEGMENT29
      ,P_GL_SEGMENT30                   => P_GL_SEGMENT30
      ,P_GL_CONCAT_SEGMENTS             => P_GL_CONCAT_SEGMENTS
      ,P_GL_CTRL_SEGMENT1               => P_GL_CTRL_SEGMENT1
      ,P_GL_CTRL_SEGMENT2               => P_GL_CTRL_SEGMENT2
      ,P_GL_CTRL_SEGMENT3               => P_GL_CTRL_SEGMENT3
      ,P_GL_CTRL_SEGMENT4               => P_GL_CTRL_SEGMENT4
      ,P_GL_CTRL_SEGMENT5               => P_GL_CTRL_SEGMENT5
      ,P_GL_CTRL_SEGMENT6               => P_GL_CTRL_SEGMENT6
      ,P_GL_CTRL_SEGMENT7               => P_GL_CTRL_SEGMENT7
      ,P_GL_CTRL_SEGMENT8               => P_GL_CTRL_SEGMENT8
      ,P_GL_CTRL_SEGMENT9               => P_GL_CTRL_SEGMENT9
      ,P_GL_CTRL_SEGMENT10              => P_GL_CTRL_SEGMENT10
      ,P_GL_CTRL_SEGMENT11              => P_GL_CTRL_SEGMENT11
      ,P_GL_CTRL_SEGMENT12              => P_GL_CTRL_SEGMENT12
      ,P_GL_CTRL_SEGMENT13              => P_GL_CTRL_SEGMENT13
      ,P_GL_CTRL_SEGMENT14              => P_GL_CTRL_SEGMENT14
      ,P_GL_CTRL_SEGMENT15              => P_GL_CTRL_SEGMENT15
      ,P_GL_CTRL_SEGMENT16              => P_GL_CTRL_SEGMENT16
      ,P_GL_CTRL_SEGMENT17              => P_GL_CTRL_SEGMENT17
      ,P_GL_CTRL_SEGMENT18              => P_GL_CTRL_SEGMENT18
      ,P_GL_CTRL_SEGMENT19              => P_GL_CTRL_SEGMENT19
      ,P_GL_CTRL_SEGMENT20              => P_GL_CTRL_SEGMENT20
      ,P_GL_CTRL_SEGMENT21              => P_GL_CTRL_SEGMENT21
      ,P_GL_CTRL_SEGMENT22              => P_GL_CTRL_SEGMENT22
      ,P_GL_CTRL_SEGMENT23              => P_GL_CTRL_SEGMENT23
      ,P_GL_CTRL_SEGMENT24              => P_GL_CTRL_SEGMENT24
      ,P_GL_CTRL_SEGMENT25              => P_GL_CTRL_SEGMENT25
      ,P_GL_CTRL_SEGMENT26              => P_GL_CTRL_SEGMENT26
      ,P_GL_CTRL_SEGMENT27              => P_GL_CTRL_SEGMENT27
      ,P_GL_CTRL_SEGMENT28              => P_GL_CTRL_SEGMENT28
      ,P_GL_CTRL_SEGMENT29              => P_GL_CTRL_SEGMENT29
      ,P_GL_CTRL_SEGMENT30              => P_GL_CTRL_SEGMENT30
      ,P_GL_CTRL_CONCAT_SEGMENTS        => P_GL_CTRL_CONCAT_SEGMENTS
      ,P_GL_CCRL_SEGMENT1               => P_GL_CCRL_SEGMENT1
      ,P_GL_CCRL_SEGMENT2               => P_GL_CCRL_SEGMENT2
      ,P_GL_CCRL_SEGMENT3               => P_GL_CCRL_SEGMENT3
      ,P_GL_CCRL_SEGMENT4               => P_GL_CCRL_SEGMENT4
      ,P_GL_CCRL_SEGMENT5               => P_GL_CCRL_SEGMENT5
      ,P_GL_CCRL_SEGMENT6               => P_GL_CCRL_SEGMENT6
      ,P_GL_CCRL_SEGMENT7               => P_GL_CCRL_SEGMENT7
      ,P_GL_CCRL_SEGMENT8               => P_GL_CCRL_SEGMENT8
      ,P_GL_CCRL_SEGMENT9               => P_GL_CCRL_SEGMENT9
      ,P_GL_CCRL_SEGMENT10              => P_GL_CCRL_SEGMENT10
      ,P_GL_CCRL_SEGMENT11              => P_GL_CCRL_SEGMENT11
      ,P_GL_CCRL_SEGMENT12              => P_GL_CCRL_SEGMENT12
      ,P_GL_CCRL_SEGMENT13              => P_GL_CCRL_SEGMENT13
      ,P_GL_CCRL_SEGMENT14              => P_GL_CCRL_SEGMENT14
      ,P_GL_CCRL_SEGMENT15              => P_GL_CCRL_SEGMENT15
      ,P_GL_CCRL_SEGMENT16              => P_GL_CCRL_SEGMENT16
      ,P_GL_CCRL_SEGMENT17              => P_GL_CCRL_SEGMENT17
      ,P_GL_CCRL_SEGMENT18              => P_GL_CCRL_SEGMENT18
      ,P_GL_CCRL_SEGMENT19              => P_GL_CCRL_SEGMENT19
      ,P_GL_CCRL_SEGMENT20              => P_GL_CCRL_SEGMENT20
      ,P_GL_CCRL_SEGMENT21              => P_GL_CCRL_SEGMENT21
      ,P_GL_CCRL_SEGMENT22              => P_GL_CCRL_SEGMENT22
      ,P_GL_CCRL_SEGMENT23              => P_GL_CCRL_SEGMENT23
      ,P_GL_CCRL_SEGMENT24              => P_GL_CCRL_SEGMENT24
      ,P_GL_CCRL_SEGMENT25              => P_GL_CCRL_SEGMENT25
      ,P_GL_CCRL_SEGMENT26              => P_GL_CCRL_SEGMENT26
      ,P_GL_CCRL_SEGMENT27              => P_GL_CCRL_SEGMENT27
      ,P_GL_CCRL_SEGMENT28              => P_GL_CCRL_SEGMENT28
      ,P_GL_CCRL_SEGMENT29              => P_GL_CCRL_SEGMENT29
      ,P_GL_CCRL_SEGMENT30              => P_GL_CCRL_SEGMENT30
      ,P_GL_CCRL_CONCAT_SEGMENTS        => P_GL_CCRL_CONCAT_SEGMENTS
      ,P_GL_ERR_SEGMENT1                => P_GL_ERR_SEGMENT1
      ,P_GL_ERR_SEGMENT2                => P_GL_ERR_SEGMENT2
      ,P_GL_ERR_SEGMENT3                => P_GL_ERR_SEGMENT3
      ,P_GL_ERR_SEGMENT4                => P_GL_ERR_SEGMENT4
      ,P_GL_ERR_SEGMENT5                => P_GL_ERR_SEGMENT5
      ,P_GL_ERR_SEGMENT6                => P_GL_ERR_SEGMENT6
      ,P_GL_ERR_SEGMENT7                => P_GL_ERR_SEGMENT7
      ,P_GL_ERR_SEGMENT8                => P_GL_ERR_SEGMENT8
      ,P_GL_ERR_SEGMENT9                => P_GL_ERR_SEGMENT9
      ,P_GL_ERR_SEGMENT10               => P_GL_ERR_SEGMENT10
      ,P_GL_ERR_SEGMENT11               => P_GL_ERR_SEGMENT11
      ,P_GL_ERR_SEGMENT12               => P_GL_ERR_SEGMENT12
      ,P_GL_ERR_SEGMENT13               => P_GL_ERR_SEGMENT13
      ,P_GL_ERR_SEGMENT14               => P_GL_ERR_SEGMENT14
      ,P_GL_ERR_SEGMENT15               => P_GL_ERR_SEGMENT15
      ,P_GL_ERR_SEGMENT16               => P_GL_ERR_SEGMENT16
      ,P_GL_ERR_SEGMENT17               => P_GL_ERR_SEGMENT17
      ,P_GL_ERR_SEGMENT18               => P_GL_ERR_SEGMENT18
      ,P_GL_ERR_SEGMENT19               => P_GL_ERR_SEGMENT19
      ,P_GL_ERR_SEGMENT20               => P_GL_ERR_SEGMENT20
      ,P_GL_ERR_SEGMENT21               => P_GL_ERR_SEGMENT21
      ,P_GL_ERR_SEGMENT22               => P_GL_ERR_SEGMENT22
      ,P_GL_ERR_SEGMENT23               => P_GL_ERR_SEGMENT23
      ,P_GL_ERR_SEGMENT24               => P_GL_ERR_SEGMENT24
      ,P_GL_ERR_SEGMENT25               => P_GL_ERR_SEGMENT25
      ,P_GL_ERR_SEGMENT26               => P_GL_ERR_SEGMENT26
      ,P_GL_ERR_SEGMENT27               => P_GL_ERR_SEGMENT27
      ,P_GL_ERR_SEGMENT28               => P_GL_ERR_SEGMENT28
      ,P_GL_ERR_SEGMENT29               => P_GL_ERR_SEGMENT29
      ,P_GL_ERR_SEGMENT30               => P_GL_ERR_SEGMENT30
      ,P_GL_ERR_CONCAT_SEGMENTS         => P_GL_ERR_CONCAT_SEGMENTS
      ,P_SETS_OF_BOOK_ID                => l_set_of_books_id
      ,P_THIRD_PARTY_PAYMENT            => P_THIRD_PARTY_PAYMENT
      ,P_ORG_PAYMENT_METHOD_ID          => l_ORG_PAYMENT_METHOD_ID
      ,P_EFFECTIVE_START_DATE           => l_EFFECTIVE_START_DATE
      ,P_EFFECTIVE_END_DATE             => l_EFFECTIVE_END_DATE
      ,P_OBJECT_VERSION_NUMBER          => l_OBJECT_VERSION_NUMBER
      ,P_ASSET_CODE_COMBINATION_ID      => l_ASSET_CODE_COMBINATION_ID
      ,P_COMMENT_ID                     => l_COMMENT_ID
      ,P_EXTERNAL_ACCOUNT_ID            => l_EXTERNAL_ACCOUNT_ID
      ,P_TRANSFER_TO_GL_FLAG            => P_TRANSFER_TO_GL_FLAG
      ,P_COST_PAYMENT                   => P_COST_PAYMENT
      ,P_COST_CLEARED_PAYMENT           => P_COST_CLEARED_PAYMENT
      ,P_COST_CLEARED_VOID_PAYMENT      => P_COST_CLEARED_VOID_PAYMENT
      ,P_EXCLUDE_MANUAL_PAYMENT         => P_EXCLUDE_MANUAL_PAYMENT
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_org_payment_method_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_org_payment_method_id     := l_org_payment_method_id;
  p_object_version_number     := l_object_version_number;
  p_comment_id                := l_comment_id;
  p_external_account_id       := l_external_account_id;
  p_effective_start_date      := l_effective_start_date;
  p_effective_end_date        := l_effective_end_date;
  p_asset_code_combination_id := l_asset_code_combination_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_org_payment_method;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ORG_PAYMENT_METHOD_ID  := null;
    p_object_version_number  := null;
    p_comment_id := null;
    p_external_account_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_asset_code_combination_id := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 110);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_org_payment_method;
    hr_utility.set_location(' Leaving:'||l_proc, 120);
    p_ORG_PAYMENT_METHOD_ID  := null;
    p_object_version_number  := null;
    p_comment_id := null;
    p_external_account_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_asset_code_combination_id := null;
--
    raise;
end create_org_payment_method;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_org_payment_method >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_org_payment_method
  (P_VALIDATE                      in     boolean  default false
  ,P_EFFECTIVE_DATE                in     date
  ,P_DATETRACK_UPDATE_MODE         in     varchar2
  ,P_LANGUAGE_CODE                 in     varchar2 default hr_api.userenv_lang
  ,P_ORG_PAYMENT_METHOD_ID         in     number
  ,P_OBJECT_VERSION_NUMBER         in out nocopy number
  ,P_ORG_PAYMENT_METHOD_NAME       in     varchar2 default hr_api.g_varchar2
  ,P_CURRENCY_CODE                 in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE_CATEGORY            in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE1                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE2                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE3                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE4                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE5                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE6                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE7                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE8                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE9                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE10                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE11                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE12                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE13                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE14                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE15                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE16                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE17                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE18                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE19                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE20                   in     varchar2 default hr_api.g_varchar2
--  ,P_PMETH_INFORMATION_CATEGORY    in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION1            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION2            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION3            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION4            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION5            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION6            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION7            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION8            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION9            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION10           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION11           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION12           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION13           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION14           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION15           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION16           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION17           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION18           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION19           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION20           in     varchar2 default hr_api.g_varchar2
  ,P_COMMENTS                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT1                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT2                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT3                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT4                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT5                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT6                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT7                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT8                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT9                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT10                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT11                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT12                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT13                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT14                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT15                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT16                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT17                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT18                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT19                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT20                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT21                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT22                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT23                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT24                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT25                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT26                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT27                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT28                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT29                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT30                     in     varchar2 default hr_api.g_varchar2
  ,P_CONCAT_SEGMENTS               in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT1                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT2                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT3                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT4                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT5                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT6                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT7                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT8                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT9                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT10                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT11                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT12                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT13                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT14                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT15                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT16                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT17                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT18                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT19                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT20                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT21                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT22                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT23                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT24                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT25                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT26                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT27                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT28                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT29                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT30                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_CONCAT_SEGMENTS            in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT1              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT2              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT3              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT4              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT5              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT6              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT7              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT8              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT9              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT10             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT11             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT12             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT13             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT14             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT15             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT16             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT17             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT18             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT19             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT20             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT21             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT22             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT23             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT24             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT25             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT26             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT27             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT28             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT29             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT30             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_CONCAT_SEGMENTS       in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT1              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT2              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT3              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT4              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT5              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT6              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT7              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT8              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT9              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT10             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT11             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT12             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT13             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT14             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT15             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT16             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT17             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT18             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT19             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT20             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT21             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT22             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT23             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT24             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT25             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT26             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT27             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT28             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT29             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT30             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_CONCAT_SEGMENTS       in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT1               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT2               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT3               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT4               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT5               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT6               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT7               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT8               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT9               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT10              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT11              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT12              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT13              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT14              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT15              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT16              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT17              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT18              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT19              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT20              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT21              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT22              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT23              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT24              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT25              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT26              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT27              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT28              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT29              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT30              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_CONCAT_SEGMENTS        in     varchar2 default hr_api.g_varchar2
  ,P_SETS_OF_BOOK_ID               in     number   default hr_api.g_number
  ,P_TRANSFER_TO_GL_FLAG           in     varchar2 default hr_api.g_varchar2
  ,P_COST_PAYMENT                  in     varchar2 default hr_api.g_varchar2
  ,P_COST_CLEARED_PAYMENT          in     varchar2 default hr_api.g_varchar2
  ,P_COST_CLEARED_VOID_PAYMENT     in     varchar2 default hr_api.g_varchar2
  ,P_EXCLUDE_MANUAL_PAYMENT        in     varchar2 default hr_api.g_varchar2
  ,P_DEFAULT_GL_ACCOUNT		   in     varchar2 default 'Y'
  ,P_BANK_ACCOUNT_ID               in     number   default hr_api.g_number
  ,P_EFFECTIVE_START_DATE             out nocopy date
  ,P_EFFECTIVE_END_DATE               out nocopy date
  ,P_ASSET_CODE_COMBINATION_ID        out nocopy number
  ,P_COMMENT_ID                       out nocopy number
  ,P_EXTERNAL_ACCOUNT_ID              out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'update_org_payment_method';
  l_object_version_number     pay_org_payment_methods_f.object_version_number%TYPE;
  l_effective_date            date;
  l_effective_start_date      pay_org_payment_methods_f.effective_start_date%TYPE;
  l_effective_end_date        pay_org_payment_methods_f.effective_end_date%TYPE;
  l_comment_id                pay_org_payment_methods_f.comment_id%TYPE;
  l_external_account_id       pay_org_payment_methods_f.external_account_id%TYPE;
  l_asset_code_combination_id number;
  l_language_code             pay_org_payment_methods_f_tl.language%TYPE;
  l_discard                   number;
  l_territory_code            pay_payment_types.territory_code%TYPE;
  l_business_group_id         pay_org_payment_methods_f.business_group_id%TYPE;
  l_key_flex_id               number;
  l_set_of_books_id           number;
  l_asset_code_changed        boolean;
  l_currency_code             pay_org_payment_methods_f.currency_code%TYPE;
  l_PMETH_INFORMATION_CATEGORY pay_org_payment_methods_f.PMETH_INFORMATION_CATEGORY%TYPE;
  l_copy_ov_number            number;

  l_gl_cash_ac_id             PAY_PAYMENT_GL_ACCOUNTS_F.GL_CASH_AC_ID%TYPE;
  l_gl_cash_clearing_ac_id    PAY_PAYMENT_GL_ACCOUNTS_F.GL_CASH_CLEARING_AC_ID%TYPE;
  l_gl_control_ac_id          PAY_PAYMENT_GL_ACCOUNTS_F.GL_CONTROL_AC_ID%TYPE;
  l_gl_error_ac_id            PAY_PAYMENT_GL_ACCOUNTS_F.GL_ERROR_AC_ID%TYPE;
  l_old_external_account_id   PAY_PAYMENT_GL_ACCOUNTS_F.EXTERNAL_ACCOUNT_ID%TYPE;
  l_old_set_of_books_id       PAY_PAYMENT_GL_ACCOUNTS_F.SET_OF_BOOKS_ID%TYPE;

  l_old_gl_cash_ac_id             PAY_PAYMENT_GL_ACCOUNTS_F.GL_CASH_AC_ID%TYPE;
  l_old_gl_cash_clearing_ac_id    PAY_PAYMENT_GL_ACCOUNTS_F.GL_CASH_CLEARING_AC_ID%TYPE;
  l_old_gl_control_ac_id          PAY_PAYMENT_GL_ACCOUNTS_F.GL_CONTROL_AC_ID%TYPE;
  l_old_gl_error_ac_id            PAY_PAYMENT_GL_ACCOUNTS_F.GL_ERROR_AC_ID%TYPE;

  l_gl_concat_segments          varchar2(2000);
  l_gl_csh_clr_concat_segment   varchar2(2000);
  l_gl_control_concat_segment   varchar2(2000);
  l_gl_error_concat_segment     varchar2(2000);

  l_gl_account_id             PAY_PAYMENT_GL_ACCOUNTS_F.PAY_GL_ACCOUNT_ID%TYPE;
  l_extr_changed              boolean;
  l_ccrl_changed	      boolean;
  l_ctrl_changed	      boolean;
  l_err_changed               boolean;
  l_dummy_number              number;
  l_dummy_name                varchar(100);

  l_cstclr_flag               varchar2(2);
  l_cst_flag                  varchar2(2);
  l_pay_gl_account_id_out     PAY_PAYMENT_GL_ACCOUNTS_F.PAY_GL_ACCOUNT_ID%TYPE;
  --
  cursor csr_territory_code (v_org_payment_method_id number) is
     select nvl(pty.territory_code,pbg.legislation_code)
       from pay_payment_types pty
          , pay_org_payment_methods_f opm
          , per_business_groups pbg
      where opm.org_payment_method_id = v_org_payment_method_id
        and pty.payment_type_id = opm.payment_type_id
        and pbg.business_group_id = opm.business_group_id;
  --
  cursor csr_currency_code (v_org_payment_method_id number) is
     select ppt.currency_code
       from pay_org_payment_methods_f opm,
            pay_payment_types ppt
      where opm.org_payment_method_id = v_org_payment_method_id
        and ppt.payment_type_id = opm.payment_type_id;
  --
  cursor csr_business_group_id (v_org_payment_method_id number) is
     select opm.business_group_id
       from pay_org_payment_methods_f opm
      where opm.org_payment_method_id = v_org_payment_method_id;
  --
  cursor csr_chart_of_accounts_id (v_sets_of_book_id number) is
     select CHART_OF_ACCOUNTS_ID
       from gl_sets_of_books
      where SET_OF_BOOKS_ID = v_sets_of_book_id;
  --
  --
  cursor csr_external_account_id (v_org_payment_method_id number, v_effective_date date) is
     select opm.external_account_id
       from pay_org_payment_methods_f opm
      where opm.org_payment_method_id = v_org_payment_method_id
      and v_effective_date between effective_start_date and effective_end_date;
  --
  cursor csr_pmeth_category (v_org_payment_method_id number) is
     select ppt.payment_type_name
       from pay_payment_types ppt,
            pay_org_payment_methods_f opm
      where opm.org_payment_method_id = v_org_payment_method_id
        and ppt.payment_type_id = opm.payment_type_id;
  --
  cursor csr_get_cst_cstclr_flags(v_org_payment_method_id number, v_effective_date date) is
     select cost_payment, cost_cleared_payment
       from pay_org_payment_methods_f
      where org_payment_method_id = v_org_payment_method_id
        and v_effective_date between effective_start_date and effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_copy_ov_number := p_object_version_number;
  l_gl_cash_ac_id           := null;
  l_gl_cash_clearing_ac_id  := null;
  l_gl_control_ac_id        := null;
  l_gl_error_ac_id          := null;

  l_old_gl_cash_ac_id           := null;
  l_old_gl_cash_clearing_ac_id  := null;
  l_old_gl_control_ac_id        := null;
  l_old_gl_error_ac_id          := null;
  --
  -- Issue a savepoint
  --
  savepoint update_org_payment_method;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  -- l_PMETH_INFORMATION_CATEGORY := hr_api.g_varchar2;
  --
  IF (P_PMETH_INFORMATION1 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION2 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION3 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION4 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION5 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION6 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION7 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION8 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION9 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION10 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION11 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION12 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION13 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION14 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION15 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION16 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION17 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION18 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION19 <> hr_api.g_varchar2 OR
      P_PMETH_INFORMATION20 <> hr_api.g_varchar2 ) THEN

      open csr_pmeth_category(P_ORG_PAYMENT_METHOD_ID);
      fetch csr_pmeth_category into l_PMETH_INFORMATION_CATEGORY;
      if (csr_pmeth_category%notfound) then
         close csr_pmeth_category;
         fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
         fnd_message.set_token('COLUMN_NAME', 'PMETH_INFORMATION_CATEGORY');
         fnd_message.raise_error;
      end if;
      close csr_pmeth_category;
  END IF;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to be
  -- passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_org_payment_method_bk2.update_org_payment_method_b
      (P_EFFECTIVE_DATE                 => l_EFFECTIVE_DATE
      ,P_DATETRACK_UPDATE_MODE          => P_DATETRACK_UPDATE_MODE
      ,P_LANGUAGE_CODE                  => l_LANGUAGE_CODE
      ,P_ORG_PAYMENT_METHOD_ID          => P_ORG_PAYMENT_METHOD_ID
      ,P_OBJECT_VERSION_NUMBER          => l_OBJECT_VERSION_NUMBER
      ,P_ORG_PAYMENT_METHOD_NAME        => P_ORG_PAYMENT_METHOD_NAME
      ,P_CURRENCY_CODE                  => P_CURRENCY_CODE
      ,P_ATTRIBUTE_CATEGORY             => P_ATTRIBUTE_CATEGORY
      ,P_ATTRIBUTE1                     => P_ATTRIBUTE1
      ,P_ATTRIBUTE2                     => P_ATTRIBUTE2
      ,P_ATTRIBUTE3                     => P_ATTRIBUTE3
      ,P_ATTRIBUTE4                     => P_ATTRIBUTE4
      ,P_ATTRIBUTE5                     => P_ATTRIBUTE5
      ,P_ATTRIBUTE6                     => P_ATTRIBUTE6
      ,P_ATTRIBUTE7                     => P_ATTRIBUTE7
      ,P_ATTRIBUTE8                     => P_ATTRIBUTE8
      ,P_ATTRIBUTE9                     => P_ATTRIBUTE9
      ,P_ATTRIBUTE10                    => P_ATTRIBUTE10
      ,P_ATTRIBUTE11                    => P_ATTRIBUTE11
      ,P_ATTRIBUTE12                    => P_ATTRIBUTE12
      ,P_ATTRIBUTE13                    => P_ATTRIBUTE13
      ,P_ATTRIBUTE14                    => P_ATTRIBUTE14
      ,P_ATTRIBUTE15                    => P_ATTRIBUTE15
      ,P_ATTRIBUTE16                    => P_ATTRIBUTE16
      ,P_ATTRIBUTE17                    => P_ATTRIBUTE17
      ,P_ATTRIBUTE18                    => P_ATTRIBUTE18
      ,P_ATTRIBUTE19                    => P_ATTRIBUTE19
      ,P_ATTRIBUTE20                    => P_ATTRIBUTE20
--      ,P_PMETH_INFORMATION_CATEGORY     => P_PMETH_INFORMATION_CATEGORY
      ,P_PMETH_INFORMATION1             => P_PMETH_INFORMATION1
      ,P_PMETH_INFORMATION2             => P_PMETH_INFORMATION2
      ,P_PMETH_INFORMATION3             => P_PMETH_INFORMATION3
      ,P_PMETH_INFORMATION4             => P_PMETH_INFORMATION4
      ,P_PMETH_INFORMATION5             => P_PMETH_INFORMATION5
      ,P_PMETH_INFORMATION6             => P_PMETH_INFORMATION6
      ,P_PMETH_INFORMATION7             => P_PMETH_INFORMATION7
      ,P_PMETH_INFORMATION8             => P_PMETH_INFORMATION8
      ,P_PMETH_INFORMATION9             => P_PMETH_INFORMATION9
      ,P_PMETH_INFORMATION10            => P_PMETH_INFORMATION10
      ,P_PMETH_INFORMATION11            => P_PMETH_INFORMATION11
      ,P_PMETH_INFORMATION12            => P_PMETH_INFORMATION12
      ,P_PMETH_INFORMATION13            => P_PMETH_INFORMATION13
      ,P_PMETH_INFORMATION14            => P_PMETH_INFORMATION14
      ,P_PMETH_INFORMATION15            => P_PMETH_INFORMATION15
      ,P_PMETH_INFORMATION16            => P_PMETH_INFORMATION16
      ,P_PMETH_INFORMATION17            => P_PMETH_INFORMATION17
      ,P_PMETH_INFORMATION18            => P_PMETH_INFORMATION18
      ,P_PMETH_INFORMATION19            => P_PMETH_INFORMATION19
      ,P_PMETH_INFORMATION20            => P_PMETH_INFORMATION20
      ,P_COMMENTS                       => P_COMMENTS
      ,P_SEGMENT1                       => P_SEGMENT1
      ,P_SEGMENT2                       => P_SEGMENT2
      ,P_SEGMENT3                       => P_SEGMENT3
      ,P_SEGMENT4                       => P_SEGMENT4
      ,P_SEGMENT5                       => P_SEGMENT5
      ,P_SEGMENT6                       => P_SEGMENT6
      ,P_SEGMENT7                       => P_SEGMENT7
      ,P_SEGMENT8                       => P_SEGMENT8
      ,P_SEGMENT9                       => P_SEGMENT9
      ,P_SEGMENT10                      => P_SEGMENT10
      ,P_SEGMENT11                      => P_SEGMENT11
      ,P_SEGMENT12                      => P_SEGMENT12
      ,P_SEGMENT13                      => P_SEGMENT13
      ,P_SEGMENT14                      => P_SEGMENT14
      ,P_SEGMENT15                      => P_SEGMENT15
      ,P_SEGMENT16                      => P_SEGMENT16
      ,P_SEGMENT17                      => P_SEGMENT17
      ,P_SEGMENT18                      => P_SEGMENT18
      ,P_SEGMENT19                      => P_SEGMENT19
      ,P_SEGMENT20                      => P_SEGMENT20
      ,P_SEGMENT21                      => P_SEGMENT21
      ,P_SEGMENT22                      => P_SEGMENT22
      ,P_SEGMENT23                      => P_SEGMENT23
      ,P_SEGMENT24                      => P_SEGMENT24
      ,P_SEGMENT25                      => P_SEGMENT25
      ,P_SEGMENT26                      => P_SEGMENT26
      ,P_SEGMENT27                      => P_SEGMENT27
      ,P_SEGMENT28                      => P_SEGMENT28
      ,P_SEGMENT29                      => P_SEGMENT29
      ,P_SEGMENT30                      => P_SEGMENT30
      ,P_CONCAT_SEGMENTS                => P_CONCAT_SEGMENTS
      ,P_GL_SEGMENT1                    => P_GL_SEGMENT1
      ,P_GL_SEGMENT2                    => P_GL_SEGMENT2
      ,P_GL_SEGMENT3                    => P_GL_SEGMENT3
      ,P_GL_SEGMENT4                    => P_GL_SEGMENT4
      ,P_GL_SEGMENT5                    => P_GL_SEGMENT5
      ,P_GL_SEGMENT6                    => P_GL_SEGMENT6
      ,P_GL_SEGMENT7                    => P_GL_SEGMENT7
      ,P_GL_SEGMENT8                    => P_GL_SEGMENT8
      ,P_GL_SEGMENT9                    => P_GL_SEGMENT9
      ,P_GL_SEGMENT10                   => P_GL_SEGMENT10
      ,P_GL_SEGMENT11                   => P_GL_SEGMENT11
      ,P_GL_SEGMENT12                   => P_GL_SEGMENT12
      ,P_GL_SEGMENT13                   => P_GL_SEGMENT13
      ,P_GL_SEGMENT14                   => P_GL_SEGMENT14
      ,P_GL_SEGMENT15                   => P_GL_SEGMENT15
      ,P_GL_SEGMENT16                   => P_GL_SEGMENT16
      ,P_GL_SEGMENT17                   => P_GL_SEGMENT17
      ,P_GL_SEGMENT18                   => P_GL_SEGMENT18
      ,P_GL_SEGMENT19                   => P_GL_SEGMENT19
      ,P_GL_SEGMENT20                   => P_GL_SEGMENT20
      ,P_GL_SEGMENT21                   => P_GL_SEGMENT21
      ,P_GL_SEGMENT22                   => P_GL_SEGMENT22
      ,P_GL_SEGMENT23                   => P_GL_SEGMENT23
      ,P_GL_SEGMENT24                   => P_GL_SEGMENT24
      ,P_GL_SEGMENT25                   => P_GL_SEGMENT25
      ,P_GL_SEGMENT26                   => P_GL_SEGMENT26
      ,P_GL_SEGMENT27                   => P_GL_SEGMENT27
      ,P_GL_SEGMENT28                   => P_GL_SEGMENT28
      ,P_GL_SEGMENT29                   => P_GL_SEGMENT29
      ,P_GL_SEGMENT30                   => P_GL_SEGMENT30
      ,P_GL_CONCAT_SEGMENTS             => P_GL_CONCAT_SEGMENTS
      ,P_GL_CTRL_SEGMENT1               => P_GL_CTRL_SEGMENT1
      ,P_GL_CTRL_SEGMENT2               => P_GL_CTRL_SEGMENT2
      ,P_GL_CTRL_SEGMENT3               => P_GL_CTRL_SEGMENT3
      ,P_GL_CTRL_SEGMENT4               => P_GL_CTRL_SEGMENT4
      ,P_GL_CTRL_SEGMENT5               => P_GL_CTRL_SEGMENT5
      ,P_GL_CTRL_SEGMENT6               => P_GL_CTRL_SEGMENT6
      ,P_GL_CTRL_SEGMENT7               => P_GL_CTRL_SEGMENT7
      ,P_GL_CTRL_SEGMENT8               => P_GL_CTRL_SEGMENT8
      ,P_GL_CTRL_SEGMENT9               => P_GL_CTRL_SEGMENT9
      ,P_GL_CTRL_SEGMENT10              => P_GL_CTRL_SEGMENT10
      ,P_GL_CTRL_SEGMENT11              => P_GL_CTRL_SEGMENT11
      ,P_GL_CTRL_SEGMENT12              => P_GL_CTRL_SEGMENT12
      ,P_GL_CTRL_SEGMENT13              => P_GL_CTRL_SEGMENT13
      ,P_GL_CTRL_SEGMENT14              => P_GL_CTRL_SEGMENT14
      ,P_GL_CTRL_SEGMENT15              => P_GL_CTRL_SEGMENT15
      ,P_GL_CTRL_SEGMENT16              => P_GL_CTRL_SEGMENT16
      ,P_GL_CTRL_SEGMENT17              => P_GL_CTRL_SEGMENT17
      ,P_GL_CTRL_SEGMENT18              => P_GL_CTRL_SEGMENT18
      ,P_GL_CTRL_SEGMENT19              => P_GL_CTRL_SEGMENT19
      ,P_GL_CTRL_SEGMENT20              => P_GL_CTRL_SEGMENT20
      ,P_GL_CTRL_SEGMENT21              => P_GL_CTRL_SEGMENT21
      ,P_GL_CTRL_SEGMENT22              => P_GL_CTRL_SEGMENT22
      ,P_GL_CTRL_SEGMENT23              => P_GL_CTRL_SEGMENT23
      ,P_GL_CTRL_SEGMENT24              => P_GL_CTRL_SEGMENT24
      ,P_GL_CTRL_SEGMENT25              => P_GL_CTRL_SEGMENT25
      ,P_GL_CTRL_SEGMENT26              => P_GL_CTRL_SEGMENT26
      ,P_GL_CTRL_SEGMENT27              => P_GL_CTRL_SEGMENT27
      ,P_GL_CTRL_SEGMENT28              => P_GL_CTRL_SEGMENT28
      ,P_GL_CTRL_SEGMENT29              => P_GL_CTRL_SEGMENT29
      ,P_GL_CTRL_SEGMENT30              => P_GL_CTRL_SEGMENT30
      ,P_GL_CTRL_CONCAT_SEGMENTS        => P_GL_CTRL_CONCAT_SEGMENTS
      ,P_GL_CCRL_SEGMENT1               => P_GL_CCRL_SEGMENT1
      ,P_GL_CCRL_SEGMENT2               => P_GL_CCRL_SEGMENT2
      ,P_GL_CCRL_SEGMENT3               => P_GL_CCRL_SEGMENT3
      ,P_GL_CCRL_SEGMENT4               => P_GL_CCRL_SEGMENT4
      ,P_GL_CCRL_SEGMENT5               => P_GL_CCRL_SEGMENT5
      ,P_GL_CCRL_SEGMENT6               => P_GL_CCRL_SEGMENT6
      ,P_GL_CCRL_SEGMENT7               => P_GL_CCRL_SEGMENT7
      ,P_GL_CCRL_SEGMENT8               => P_GL_CCRL_SEGMENT8
      ,P_GL_CCRL_SEGMENT9               => P_GL_CCRL_SEGMENT9
      ,P_GL_CCRL_SEGMENT10              => P_GL_CCRL_SEGMENT10
      ,P_GL_CCRL_SEGMENT11              => P_GL_CCRL_SEGMENT11
      ,P_GL_CCRL_SEGMENT12              => P_GL_CCRL_SEGMENT12
      ,P_GL_CCRL_SEGMENT13              => P_GL_CCRL_SEGMENT13
      ,P_GL_CCRL_SEGMENT14              => P_GL_CCRL_SEGMENT14
      ,P_GL_CCRL_SEGMENT15              => P_GL_CCRL_SEGMENT15
      ,P_GL_CCRL_SEGMENT16              => P_GL_CCRL_SEGMENT16
      ,P_GL_CCRL_SEGMENT17              => P_GL_CCRL_SEGMENT17
      ,P_GL_CCRL_SEGMENT18              => P_GL_CCRL_SEGMENT18
      ,P_GL_CCRL_SEGMENT19              => P_GL_CCRL_SEGMENT19
      ,P_GL_CCRL_SEGMENT20              => P_GL_CCRL_SEGMENT20
      ,P_GL_CCRL_SEGMENT21              => P_GL_CCRL_SEGMENT21
      ,P_GL_CCRL_SEGMENT22              => P_GL_CCRL_SEGMENT22
      ,P_GL_CCRL_SEGMENT23              => P_GL_CCRL_SEGMENT23
      ,P_GL_CCRL_SEGMENT24              => P_GL_CCRL_SEGMENT24
      ,P_GL_CCRL_SEGMENT25              => P_GL_CCRL_SEGMENT25
      ,P_GL_CCRL_SEGMENT26              => P_GL_CCRL_SEGMENT26
      ,P_GL_CCRL_SEGMENT27              => P_GL_CCRL_SEGMENT27
      ,P_GL_CCRL_SEGMENT28              => P_GL_CCRL_SEGMENT28
      ,P_GL_CCRL_SEGMENT29              => P_GL_CCRL_SEGMENT29
      ,P_GL_CCRL_SEGMENT30              => P_GL_CCRL_SEGMENT30
      ,P_GL_CCRL_CONCAT_SEGMENTS        => P_GL_CCRL_CONCAT_SEGMENTS
      ,P_GL_ERR_SEGMENT1                => P_GL_ERR_SEGMENT1
      ,P_GL_ERR_SEGMENT2                => P_GL_ERR_SEGMENT2
      ,P_GL_ERR_SEGMENT3                => P_GL_ERR_SEGMENT3
      ,P_GL_ERR_SEGMENT4                => P_GL_ERR_SEGMENT4
      ,P_GL_ERR_SEGMENT5                => P_GL_ERR_SEGMENT5
      ,P_GL_ERR_SEGMENT6                => P_GL_ERR_SEGMENT6
      ,P_GL_ERR_SEGMENT7                => P_GL_ERR_SEGMENT7
      ,P_GL_ERR_SEGMENT8                => P_GL_ERR_SEGMENT8
      ,P_GL_ERR_SEGMENT9                => P_GL_ERR_SEGMENT9
      ,P_GL_ERR_SEGMENT10               => P_GL_ERR_SEGMENT10
      ,P_GL_ERR_SEGMENT11               => P_GL_ERR_SEGMENT11
      ,P_GL_ERR_SEGMENT12               => P_GL_ERR_SEGMENT12
      ,P_GL_ERR_SEGMENT13               => P_GL_ERR_SEGMENT13
      ,P_GL_ERR_SEGMENT14               => P_GL_ERR_SEGMENT14
      ,P_GL_ERR_SEGMENT15               => P_GL_ERR_SEGMENT15
      ,P_GL_ERR_SEGMENT16               => P_GL_ERR_SEGMENT16
      ,P_GL_ERR_SEGMENT17               => P_GL_ERR_SEGMENT17
      ,P_GL_ERR_SEGMENT18               => P_GL_ERR_SEGMENT18
      ,P_GL_ERR_SEGMENT19               => P_GL_ERR_SEGMENT19
      ,P_GL_ERR_SEGMENT20               => P_GL_ERR_SEGMENT20
      ,P_GL_ERR_SEGMENT21               => P_GL_ERR_SEGMENT21
      ,P_GL_ERR_SEGMENT22               => P_GL_ERR_SEGMENT22
      ,P_GL_ERR_SEGMENT23               => P_GL_ERR_SEGMENT23
      ,P_GL_ERR_SEGMENT24               => P_GL_ERR_SEGMENT24
      ,P_GL_ERR_SEGMENT25               => P_GL_ERR_SEGMENT25
      ,P_GL_ERR_SEGMENT26               => P_GL_ERR_SEGMENT26
      ,P_GL_ERR_SEGMENT27               => P_GL_ERR_SEGMENT27
      ,P_GL_ERR_SEGMENT28               => P_GL_ERR_SEGMENT28
      ,P_GL_ERR_SEGMENT29               => P_GL_ERR_SEGMENT29
      ,P_GL_ERR_SEGMENT30               => P_GL_ERR_SEGMENT30
      ,P_GL_ERR_CONCAT_SEGMENTS         => P_GL_ERR_CONCAT_SEGMENTS
      ,P_SETS_OF_BOOK_ID                => P_SETS_OF_BOOK_ID
      ,P_TRANSFER_TO_GL_FLAG            => P_TRANSFER_TO_GL_FLAG
      ,P_COST_PAYMENT                   => P_COST_PAYMENT
      ,P_COST_CLEARED_PAYMENT           => P_COST_CLEARED_PAYMENT
      ,P_COST_CLEARED_VOID_PAYMENT      => P_COST_CLEARED_VOID_PAYMENT
      ,P_EXCLUDE_MANUAL_PAYMENT         => P_EXCLUDE_MANUAL_PAYMENT
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_org_payment_method_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  l_set_of_books_id := p_sets_of_book_id;
  l_ASSET_CODE_COMBINATION_ID := null;
  l_asset_code_changed := false;
  l_extr_changed  := false;
  --
  -- Process Logic
  --
  -- Call table handler pay_exa_upd to control the processing of the external
  -- account combination keyflex, discarding the returning parameter
  -- p_object_version_number
  --
  hr_utility.set_location('Before determining the external A/C id : ' ||l_proc, 25);
  if ((P_SEGMENT1  <> hr_api.g_varchar2) OR
      (P_SEGMENT2  <> hr_api.g_varchar2) OR
      (P_SEGMENT3  <> hr_api.g_varchar2) OR
      (P_SEGMENT4  <> hr_api.g_varchar2) OR
      (P_SEGMENT5  <> hr_api.g_varchar2) OR
      (P_SEGMENT6  <> hr_api.g_varchar2) OR
      (P_SEGMENT7  <> hr_api.g_varchar2) OR
      (P_SEGMENT8  <> hr_api.g_varchar2) OR
      (P_SEGMENT9  <> hr_api.g_varchar2) OR
      (P_SEGMENT10 <> hr_api.g_varchar2) OR
      (P_SEGMENT11 <> hr_api.g_varchar2) OR
      (P_SEGMENT12 <> hr_api.g_varchar2) OR
      (P_SEGMENT13 <> hr_api.g_varchar2) OR
      (P_SEGMENT14 <> hr_api.g_varchar2) OR
      (P_SEGMENT15 <> hr_api.g_varchar2) OR
      (P_SEGMENT16 <> hr_api.g_varchar2) OR
      (P_SEGMENT17 <> hr_api.g_varchar2) OR
      (P_SEGMENT18 <> hr_api.g_varchar2) OR
      (P_SEGMENT19 <> hr_api.g_varchar2) OR
      (P_SEGMENT20 <> hr_api.g_varchar2) OR
      (P_SEGMENT21 <> hr_api.g_varchar2) OR
      (P_SEGMENT22 <> hr_api.g_varchar2) OR
      (P_SEGMENT23 <> hr_api.g_varchar2) OR
      (P_SEGMENT24 <> hr_api.g_varchar2) OR
      (P_SEGMENT25 <> hr_api.g_varchar2) OR
      (P_SEGMENT26 <> hr_api.g_varchar2) OR
      (P_SEGMENT27 <> hr_api.g_varchar2) OR
      (P_SEGMENT28 <> hr_api.g_varchar2) OR
      (P_SEGMENT29 <> hr_api.g_varchar2) OR
      (P_SEGMENT30 <> hr_api.g_varchar2) OR
      (P_CONCAT_SEGMENTS <> hr_api.g_varchar2)) then
       --
	hr_api.mandatory_arg_error(p_api_name       => l_proc
                               ,p_argument       => 'ORG_PAYMENT_METHOD_ID'
                               ,p_argument_value => P_ORG_PAYMENT_METHOD_ID
                               );
	--
	open csr_business_group_id(P_ORG_PAYMENT_METHOD_ID);
	fetch csr_business_group_id into l_business_group_id;
	if (csr_business_group_id%notfound) then
	--
		close csr_business_group_id;
		fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
		fnd_message.set_token('COLUMN_NAME', 'BUSINESS_GROUP_ID');
		fnd_message.raise_error;
	--
	end if;
	close csr_business_group_id;
	--
	open csr_territory_code(P_ORG_PAYMENT_METHOD_ID);
	fetch csr_territory_code into l_territory_code;
	if (csr_territory_code%notfound) then
	--
		close csr_territory_code;
		fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
	        fnd_message.set_token('COLUMN_NAME', 'PAYMENT_TYPE_ID');
		fnd_message.raise_error;
	--
	end if;
	close csr_territory_code;
	--
	pay_exa_upd.upd_or_sel
       (p_segment1              => p_segment1
       ,p_segment2              => p_segment2
       ,p_segment3              => p_segment3
       ,p_segment4              => p_segment4
       ,p_segment5              => p_segment5
       ,p_segment6              => p_segment6
       ,p_segment7              => p_segment7
       ,p_segment8              => p_segment8
       ,p_segment9              => p_segment9
       ,p_segment10             => p_segment10
       ,p_segment11             => p_segment11
       ,p_segment12             => p_segment12
       ,p_segment13             => p_segment13
       ,p_segment14             => p_segment14
       ,p_segment15             => p_segment15
       ,p_segment16             => p_segment16
       ,p_segment17             => p_segment17
       ,p_segment18             => p_segment18
       ,p_segment19             => p_segment19
       ,p_segment20             => p_segment20
       ,p_segment21             => p_segment21
       ,p_segment22             => p_segment22
       ,p_segment23             => p_segment23
       ,p_segment24             => p_segment24
       ,p_segment25             => p_segment25
       ,p_segment26             => p_segment26
       ,p_segment27             => p_segment27
       ,p_segment28             => p_segment28
       ,p_segment29             => p_segment29
       ,p_segment30             => p_segment30
       ,p_concat_segments       => p_concat_segments
       ,p_business_group_id     => l_business_group_id
       ,p_territory_code        => l_territory_code
       ,p_external_account_id   => l_external_account_id
       ,p_object_version_number => l_discard
       );
       l_extr_changed := true;
  --
  else
  --
     hr_api.mandatory_arg_error(p_api_name       => l_proc
                               ,p_argument       => 'ORG_PAYMENT_METHOD_ID'
                               ,p_argument_value => P_ORG_PAYMENT_METHOD_ID
                               );
     --
     -- External_account_id can be null.
     -- Let the row handlers to validate this.
     --
     -- open csr_external_account_id(P_ORG_PAYMENT_METHOD_ID);
     -- fetch csr_external_account_id into l_external_account_id;
     -- if (csr_external_account_id%notfound) then
     --    close csr_external_account_id;
     --    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
     --    fnd_message.set_token('COLUMN_NAME', 'EXTERNAL_ACCOUNT_ID');
     --    fnd_message.raise_error;
     -- end if;
     -- close csr_external_account_id;
     --
     l_external_account_id := null;
     --
  --
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Determine the Assest definition by calling upd_or_sel.
  --
  --
  if (PAY_ADHOC_UTILS_PKG.chk_post_r11i = 'Y' ) then
      if (l_set_of_books_id = hr_api.g_number) then
		--
	l_set_of_books_id := pay_maintain_bank_acct.get_sob_id(
                    p_org_payment_method_id    => P_ORG_PAYMENT_METHOD_ID);

	if (l_set_of_books_id is null) then
	--
		fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
		fnd_message.set_token('COLUMN_NAME', 'ORG_PAYMENT_METHOD_ID');
		fnd_message.raise_error;
	--
	end if;
	--
      end if;
    --
    if (l_set_of_books_id is not null) then
    --
	open csr_chart_of_accounts_id(l_set_of_books_id);
	fetch csr_chart_of_accounts_id into l_key_flex_id;
	if (csr_chart_of_accounts_id%notfound and l_set_of_books_id<>0) then
	--
		close csr_chart_of_accounts_id;
		fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
		fnd_message.set_token('COLUMN_NAME', 'sets_of_book_id');
		fnd_message.raise_error;
	--
	end if;
	close csr_chart_of_accounts_id;
     --
     end if;
  --
  end if;
  hr_utility.set_location('Before Determining cash A/C id : '||l_proc, 35);
  if (l_set_of_books_id is not null) then
  --
	if ((P_GL_SEGMENT1  <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT2  <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT3  <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT4  <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT5  <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT6  <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT7  <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT8  <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT9  <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT10 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT11 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT12 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT13 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT14 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT15 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT16 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT17 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT18 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT19 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT20 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT21 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT22 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT23 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT24 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT25 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT26 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT27 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT28 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT29 <> hr_api.g_varchar2) OR
         (P_GL_SEGMENT30 <> hr_api.g_varchar2) OR
         (P_GL_CONCAT_SEGMENTS <> hr_api.g_varchar2)) then
         --
		if l_key_flex_id is not null then
			hr_kflex_utility.upd_or_sel_keyflex_comb
			(p_appl_short_name       => 'SQLGL'
			,p_flex_code             => 'GL#'
			,p_flex_num              => l_key_flex_id
			,p_segment1              => p_gl_segment1
			,p_segment2              => p_gl_segment2
			,p_segment3              => p_gl_segment3
			,p_segment4              => p_gl_segment4
			,p_segment5              => p_gl_segment5
			,p_segment6              => p_gl_segment6
			,p_segment7              => p_gl_segment7
			,p_segment8              => p_gl_segment8
			,p_segment9              => p_gl_segment9
			,p_segment10             => p_gl_segment10
			,p_segment11             => p_gl_segment11
			,p_segment12             => p_gl_segment12
			,p_segment13             => p_gl_segment13
			,p_segment14             => p_gl_segment14
			,p_segment15             => p_gl_segment15
			,p_segment16             => p_gl_segment16
			,p_segment17             => p_gl_segment17
			,p_segment18             => p_gl_segment18
			,p_segment19             => p_gl_segment19
			,p_segment20             => p_gl_segment20
			,p_segment21             => p_gl_segment21
			,p_segment22             => p_gl_segment22
			,p_segment23             => p_gl_segment23
			,p_segment24             => p_gl_segment24
			,p_segment25             => p_gl_segment25
			,p_segment26             => p_gl_segment26
			,p_segment27             => p_gl_segment27
			,p_segment28             => p_gl_segment28
			,p_segment29             => p_gl_segment29
			,p_segment30             => p_gl_segment30
			,p_concat_segments_in    => p_gl_concat_segments
			,p_ccid                  => l_gl_cash_ac_id
			,p_concat_segments_out   => l_gl_concat_segments
			);
			l_ASSET_CODE_COMBINATION_ID := l_gl_cash_ac_id;
			l_asset_code_changed := true;
		--
		end if;
	else  --If none of the segments are specified
	--
		if (p_sets_of_book_id <> hr_api.g_number) then
		--
			l_gl_cash_ac_id := null;
			l_asset_code_changed := true;
	        --
		end if;
        --
	end if; --For GL Segments.
	--
	hr_utility.set_location('Before Determining Control A/C id : '||l_proc, 40);
	--
	if ((P_GL_CTRL_SEGMENT1  <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT2  <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT3  <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT4  <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT5  <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT6  <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT7  <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT8  <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT9  <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT10 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT11 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT12 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT13 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT14 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT15 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT16 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT17 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT18 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT19 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT20 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT21 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT22 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT23 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT24 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT25 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT26 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT27 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT28 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT29 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_SEGMENT30 <> hr_api.g_varchar2) OR
	   (P_GL_CTRL_CONCAT_SEGMENTS <> hr_api.g_varchar2)) then
	--
		if l_key_flex_id is not null then
		--
			hr_kflex_utility.upd_or_sel_keyflex_comb
			(p_appl_short_name       => 'SQLGL'
			,p_flex_code             => 'GL#'
			,p_flex_num              => l_key_flex_id
			,p_segment1              => p_gl_ctrl_segment1
			,p_segment2              => p_gl_ctrl_segment2
			,p_segment3              => p_gl_ctrl_segment3
			,p_segment4              => p_gl_ctrl_segment4
			,p_segment5              => p_gl_ctrl_segment5
			,p_segment6              => p_gl_ctrl_segment6
			,p_segment7              => p_gl_ctrl_segment7
			,p_segment8              => p_gl_ctrl_segment8
			,p_segment9              => p_gl_ctrl_segment9
			,p_segment10             => p_gl_ctrl_segment10
			,p_segment11             => p_gl_ctrl_segment11
			,p_segment12             => p_gl_ctrl_segment12
			,p_segment13             => p_gl_ctrl_segment13
			,p_segment14             => p_gl_ctrl_segment14
			,p_segment15             => p_gl_ctrl_segment15
			,p_segment16             => p_gl_ctrl_segment16
			,p_segment17             => p_gl_ctrl_segment17
			,p_segment18             => p_gl_ctrl_segment18
			,p_segment19             => p_gl_ctrl_segment19
			,p_segment20             => p_gl_ctrl_segment20
			,p_segment21             => p_gl_ctrl_segment21
			,p_segment22             => p_gl_ctrl_segment22
			,p_segment23             => p_gl_ctrl_segment23
			,p_segment24             => p_gl_ctrl_segment24
		        ,p_segment25             => p_gl_ctrl_segment25
			,p_segment26             => p_gl_ctrl_segment26
		        ,p_segment27             => p_gl_ctrl_segment27
		        ,p_segment28             => p_gl_ctrl_segment28
			,p_segment29             => p_gl_ctrl_segment29
		        ,p_segment30             => p_gl_ctrl_segment30
		        ,p_concat_segments_in    => p_gl_ctrl_concat_segments
			,p_ccid                  => l_gl_control_ac_id
		        ,p_concat_segments_out   => l_gl_control_concat_segment
		        );
		--
		end if;
	--
	end if;
	--
	hr_utility.set_location('Before Determining Cash Clearing A/C id : '||l_proc, 45);
	--
	if ((P_GL_CCRL_SEGMENT1  <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT2  <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT3  <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT4  <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT5  <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT6  <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT7  <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT8  <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT9  <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT10 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT11 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT12 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT13 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT14 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT15 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT16 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT17 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT18 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT19 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT20 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT21 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT22 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT23 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT24 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT25 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT26 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT27 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT28 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT29 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_SEGMENT30 <> hr_api.g_varchar2) OR
	(P_GL_CCRL_CONCAT_SEGMENTS <> hr_api.g_varchar2)) then
	--
		if l_key_flex_id is not null then
		--
			hr_kflex_utility.upd_or_sel_keyflex_comb
			(p_appl_short_name       => 'SQLGL'
			,p_flex_code             => 'GL#'
			,p_flex_num              => l_key_flex_id
			,p_segment1              => p_gl_ccrl_segment1
			,p_segment2              => p_gl_ccrl_segment2
			,p_segment3              => p_gl_ccrl_segment3
			,p_segment4              => p_gl_ccrl_segment4
			,p_segment5              => p_gl_ccrl_segment5
			,p_segment6              => p_gl_ccrl_segment6
			,p_segment7              => p_gl_ccrl_segment7
			,p_segment8              => p_gl_ccrl_segment8
			,p_segment9              => p_gl_ccrl_segment9
			,p_segment10             => p_gl_ccrl_segment10
			,p_segment11             => p_gl_ccrl_segment11
			,p_segment12             => p_gl_ccrl_segment12
			,p_segment13             => p_gl_ccrl_segment13
			,p_segment14             => p_gl_ccrl_segment14
			,p_segment15		 => p_gl_ccrl_segment15
			,p_segment16             => p_gl_ccrl_segment16
			,p_segment17             => p_gl_ccrl_segment17
			,p_segment18             => p_gl_ccrl_segment18
			,p_segment19             => p_gl_ccrl_segment19
			,p_segment20             => p_gl_ccrl_segment20
			,p_segment21             => p_gl_ccrl_segment21
			,p_segment22             => p_gl_ccrl_segment22
			,p_segment23             => p_gl_ccrl_segment23
			,p_segment24             => p_gl_ccrl_segment24
			,p_segment25             => p_gl_ccrl_segment25
			,p_segment26             => p_gl_ccrl_segment26
			,p_segment27             => p_gl_ccrl_segment27
			,p_segment28             => p_gl_ccrl_segment28
			,p_segment29             => p_gl_ccrl_segment29
			,p_segment30             => p_gl_ccrl_segment30
			,p_concat_segments_in    => p_gl_ccrl_concat_segments
			,p_ccid                  => l_gl_cash_clearing_ac_id
			,p_concat_segments_out   => l_gl_csh_clr_concat_segment
			);
		--
		end if;
	--
	end if;
	--
	hr_utility.set_location('Before Determining Error A/C id : '||l_proc, 50);
	--
	if ((P_GL_ERR_SEGMENT1  <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT2  <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT3  <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT4  <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT5  <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT6  <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT7  <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT8  <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT9  <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT10 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT11 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT12 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT13 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT14 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT15 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT16 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT17 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT18 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT19 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT20 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT21 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT22 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT23 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT24 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT25 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT26 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT27 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT28 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT29 <> hr_api.g_varchar2) OR
	(P_GL_ERR_SEGMENT30 <> hr_api.g_varchar2) OR
	(P_GL_ERR_CONCAT_SEGMENTS <> hr_api.g_varchar2)) then
	--
		if l_key_flex_id is not null then
		--
			hr_kflex_utility.upd_or_sel_keyflex_comb
			(p_appl_short_name       => 'SQLGL'
			,p_flex_code             => 'GL#'
			,p_flex_num              => l_key_flex_id
			,p_segment1              => p_gl_err_segment1
			,p_segment2              => p_gl_err_segment2
			,p_segment3              => p_gl_err_segment3
			,p_segment4              => p_gl_err_segment4
			,p_segment5              => p_gl_err_segment5
			,p_segment6              => p_gl_err_segment6
			,p_segment7              => p_gl_err_segment7
			,p_segment8              => p_gl_err_segment8
			,p_segment9              => p_gl_err_segment9
			,p_segment10             => p_gl_err_segment10
			,p_segment11             => p_gl_err_segment11
			,p_segment12             => p_gl_err_segment12
			,p_segment13             => p_gl_err_segment13
			,p_segment14             => p_gl_err_segment14
			,p_segment15             => p_gl_err_segment15
			,p_segment16             => p_gl_err_segment16
			,p_segment17             => p_gl_err_segment17
			,p_segment18             => p_gl_err_segment18
		        ,p_segment19		 => p_gl_err_segment19
			,p_segment20             => p_gl_err_segment20
			,p_segment21             => p_gl_err_segment21
			,p_segment22             => p_gl_err_segment22
			,p_segment23             => p_gl_err_segment23
			,p_segment24             => p_gl_err_segment24
			,p_segment25             => p_gl_err_segment25
			,p_segment26             => p_gl_err_segment26
			,p_segment27             => p_gl_err_segment27
			,p_segment28             => p_gl_err_segment28
			,p_segment29             => p_gl_err_segment29
			,p_segment30             => p_gl_err_segment30
			,p_concat_segments_in    => p_gl_err_concat_segments
			,p_ccid                  => l_gl_error_ac_id
			,p_concat_segments_out   => l_gl_error_concat_segment
			);
		--
		end if;
	--
	end if;
	--
  --
  end if; -- For set of books id is not null
  --
  --
  open csr_currency_code(p_org_payment_method_id);
  fetch csr_currency_code into l_currency_code;
  if (csr_currency_code%notfound) then
     close csr_currency_code;
     fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
     fnd_message.set_token('COLUMN_NAME', 'ORG_PAYMENT_METHOD_ID');
     fnd_message.raise_error;
  end if;
  close csr_currency_code;
  if (p_currency_code is not null) then
     l_currency_code := p_currency_code;
  end if;
  --
  hr_utility.set_location('Validation for Sychrinizing A/Cids with flags : '||l_proc, 55);
  -- Validation for the cost and cost cleared payments.
  -- If the cost cleared payment is set to 'Y' then all the Cash, Cash Clearing,
  -- Control and Error A/Cs should be specified.
  -- If the cost cleared or cost payment is set then Cash and Cash Clearing A/Cs
  -- should be there.
  --
  open csr_get_cst_cstclr_flags(p_org_payment_method_id, l_effective_date);
  fetch csr_get_cst_cstclr_flags into l_cst_flag, l_cstclr_flag;
  if (csr_get_cst_cstclr_flags%notfound) then
     close csr_get_cst_cstclr_flags;
     fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
     fnd_message.set_token('COLUMN_NAME', 'ORG_PAYMENT_METHOD_ID');
     fnd_message.raise_error;
  end if;
  close csr_get_cst_cstclr_flags;

  if(p_cost_payment is not null) then
	if (p_cost_payment <> hr_api.g_varchar2) then
		l_cst_flag := p_cost_payment;
	end if;
  else
	l_cst_flag := null;
  end if;

  if (p_cost_cleared_payment is not null) then
	if (p_cost_cleared_payment <> hr_api.g_varchar2) then
		l_cstclr_flag := p_cost_cleared_payment;
	end if;
  else
	l_cstclr_flag := null;
  end if;

  if (l_cstclr_flag = 'Y') and (l_gl_cash_ac_id is null or
				l_gl_cash_clearing_ac_id is null or
				l_gl_control_ac_id is null or
				l_gl_error_ac_id is null) then
     fnd_message.set_name('PAY', 'PAY_33420_INV_CSTCLR_IDS');
     fnd_message.raise_error;
  elsif (l_cst_flag = 'Y' ) and (l_gl_cash_ac_id is null or
			     l_gl_cash_clearing_ac_id is null) then
     fnd_message.set_name('PAY', 'PAY_33421_INV_CST_IDS');
     fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Before Row Handler of OPM : '||l_proc, 60);
  --
  pay_opm_upd.upd
      (p_effective_date                => l_effective_date
      ,p_datetrack_mode                => p_datetrack_update_mode
      ,p_org_payment_method_id         => p_org_payment_method_id
      ,p_object_version_number         => l_object_version_number
      ,p_external_account_id           => l_external_account_id
      ,p_currency_code                 => l_currency_code
      ,p_comments                      => p_comments
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_pmeth_information_category    => l_pmeth_information_category
      ,p_pmeth_information1            => p_pmeth_information1
      ,p_pmeth_information2            => p_pmeth_information2
      ,p_pmeth_information3            => p_pmeth_information3
      ,p_pmeth_information4            => p_pmeth_information4
      ,p_pmeth_information5            => p_pmeth_information5
      ,p_pmeth_information6            => p_pmeth_information6
      ,p_pmeth_information7            => p_pmeth_information7
      ,p_pmeth_information8            => p_pmeth_information8
      ,p_pmeth_information9            => p_pmeth_information9
      ,p_pmeth_information10           => p_pmeth_information10
      ,p_pmeth_information11           => p_pmeth_information11
      ,p_pmeth_information12           => p_pmeth_information12
      ,p_pmeth_information13           => p_pmeth_information13
      ,p_pmeth_information14           => p_pmeth_information14
      ,p_pmeth_information15           => p_pmeth_information15
      ,p_pmeth_information16           => p_pmeth_information16
      ,p_pmeth_information17           => p_pmeth_information17
      ,p_pmeth_information18           => p_pmeth_information18
      ,p_pmeth_information19           => p_pmeth_information19
      ,p_pmeth_information20           => p_pmeth_information20
      ,p_TRANSFER_TO_GL_FLAG           => p_TRANSFER_TO_GL_FLAG
      ,p_cost_payment                  => p_cost_payment
      ,p_cost_cleared_payment          => p_cost_cleared_payment
      ,p_cost_cleared_void_payment     => p_cost_cleared_void_payment
      ,p_exclude_manual_payment        => p_exclude_manual_payment
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_comment_id                    => l_comment_id
      );
  --
  pay_opt_upd.upd_tl
      (p_language_code                  => l_language_code
      ,p_org_payment_method_id          => p_org_payment_method_id
      ,p_org_payment_method_name        => p_org_payment_method_name
      );
  --
  hr_utility.set_location('Before Updating Bank Accounts : '||l_proc, 65);
  -- Updating the ap_bank_accounts_all
  if (pay_ce_support_pkg.pay_and_ce_licensed) then
  --

     --   Bug No. 4644827
     --   for r11.5 the same functionality is done through database trigger. Code
     --   is for R12
          IF l_external_account_id IS NOT NULL THEN
             pay_maintain_bank_acct.update_payroll_bank_acct(
            	      p_bank_account_id     => p_bank_account_id,
                      p_external_account_id =>l_external_account_id,
		      p_org_payment_method_id => p_org_payment_method_id);
          end if;


	if (l_asset_code_changed) then
        --
          --Bug No. 4644827
          pay_maintain_bank_acct.update_asset_ccid(
                   p_assest_ccid              =>l_ASSET_CODE_COMBINATION_ID,
                   p_set_of_books_id          =>l_set_of_books_id,
                   p_external_account_id      =>l_external_account_id
                   );
        --
	else
        --
          --Bug No. 4644827
          pay_maintain_bank_acct.update_asset_ccid(
                   p_assest_ccid              =>null,
                   p_set_of_books_id          =>l_set_of_books_id,
                   p_external_account_id      =>l_external_account_id
                   );

        --
        end if;
     --
     -- removing any redundant bank details within ap.
     --
	if (l_external_account_id <> hr_api.g_number) then
            --Bug No. 4644827
  	    pay_maintain_bank_acct.remove_redundant_bank_detail;
	end if;
     --
  end if;

  hr_utility.set_location('Before Updating GL Accounts : '||l_proc, 70);
  PAY_PAYMENT_GL_ACCOUNTS_PKG.UPDATE_ROW
   ( P_EFFECTIVE_START_DATE => l_effective_start_date,
     P_EFFECTIVE_END_DATE   => l_effective_end_date,
     P_SET_OF_BOOKS_ID      => l_set_of_books_id,
     P_GL_CASH_AC_ID        => l_gl_cash_ac_id,
     P_GL_CASH_CLEARING_AC_ID => l_gl_cash_clearing_ac_id,
     P_GL_CONTROL_AC_ID       => l_gl_control_ac_id,
     P_GL_ERROR_AC_ID         => l_gl_error_ac_id,
     P_EXTERNAL_ACCOUNT_ID    => l_external_account_id,
     P_ORG_PAYMENT_METHOD_ID  => p_org_payment_method_id,
     P_DT_UPDATE_MODE         => P_DATETRACK_UPDATE_MODE,
     P_DEFAULT_GL_ACCOUNT     => p_default_gl_account,
     P_PAY_GL_ACCOUNT_ID_OUT  => l_pay_gl_account_id_out
   );

  --
  --
  -- Call After Process User Hook
  --
  begin
    pay_org_payment_method_bk2.update_org_payment_method_a
      (P_EFFECTIVE_DATE                 => l_EFFECTIVE_DATE
      ,P_DATETRACK_UPDATE_MODE          => P_DATETRACK_UPDATE_MODE
      ,P_LANGUAGE_CODE                  => l_LANGUAGE_CODE
      ,P_ORG_PAYMENT_METHOD_ID          => P_ORG_PAYMENT_METHOD_ID
      ,P_OBJECT_VERSION_NUMBER          => l_OBJECT_VERSION_NUMBER
      ,P_ORG_PAYMENT_METHOD_NAME        => P_ORG_PAYMENT_METHOD_NAME
      ,P_CURRENCY_CODE                  => l_CURRENCY_CODE
      ,P_ATTRIBUTE_CATEGORY             => P_ATTRIBUTE_CATEGORY
      ,P_ATTRIBUTE1                     => P_ATTRIBUTE1
      ,P_ATTRIBUTE2                     => P_ATTRIBUTE2
      ,P_ATTRIBUTE3                     => P_ATTRIBUTE3
      ,P_ATTRIBUTE4                     => P_ATTRIBUTE4
      ,P_ATTRIBUTE5                     => P_ATTRIBUTE5
      ,P_ATTRIBUTE6                     => P_ATTRIBUTE6
      ,P_ATTRIBUTE7                     => P_ATTRIBUTE7
      ,P_ATTRIBUTE8                     => P_ATTRIBUTE8
      ,P_ATTRIBUTE9                     => P_ATTRIBUTE9
      ,P_ATTRIBUTE10                    => P_ATTRIBUTE10
      ,P_ATTRIBUTE11                    => P_ATTRIBUTE11
      ,P_ATTRIBUTE12                    => P_ATTRIBUTE12
      ,P_ATTRIBUTE13                    => P_ATTRIBUTE13
      ,P_ATTRIBUTE14                    => P_ATTRIBUTE14
      ,P_ATTRIBUTE15                    => P_ATTRIBUTE15
      ,P_ATTRIBUTE16                    => P_ATTRIBUTE16
      ,P_ATTRIBUTE17                    => P_ATTRIBUTE17
      ,P_ATTRIBUTE18                    => P_ATTRIBUTE18
      ,P_ATTRIBUTE19                    => P_ATTRIBUTE19
      ,P_ATTRIBUTE20                    => P_ATTRIBUTE20
--      ,P_PMETH_INFORMATION_CATEGORY     => P_PMETH_INFORMATION_CATEGORY
      ,P_PMETH_INFORMATION1             => P_PMETH_INFORMATION1
      ,P_PMETH_INFORMATION2             => P_PMETH_INFORMATION2
      ,P_PMETH_INFORMATION3             => P_PMETH_INFORMATION3
      ,P_PMETH_INFORMATION4             => P_PMETH_INFORMATION4
      ,P_PMETH_INFORMATION5             => P_PMETH_INFORMATION5
      ,P_PMETH_INFORMATION6             => P_PMETH_INFORMATION6
      ,P_PMETH_INFORMATION7             => P_PMETH_INFORMATION7
      ,P_PMETH_INFORMATION8             => P_PMETH_INFORMATION8
      ,P_PMETH_INFORMATION9             => P_PMETH_INFORMATION9
      ,P_PMETH_INFORMATION10            => P_PMETH_INFORMATION10
      ,P_PMETH_INFORMATION11            => P_PMETH_INFORMATION11
      ,P_PMETH_INFORMATION12            => P_PMETH_INFORMATION12
      ,P_PMETH_INFORMATION13            => P_PMETH_INFORMATION13
      ,P_PMETH_INFORMATION14            => P_PMETH_INFORMATION14
      ,P_PMETH_INFORMATION15            => P_PMETH_INFORMATION15
      ,P_PMETH_INFORMATION16            => P_PMETH_INFORMATION16
      ,P_PMETH_INFORMATION17            => P_PMETH_INFORMATION17
      ,P_PMETH_INFORMATION18            => P_PMETH_INFORMATION18
      ,P_PMETH_INFORMATION19            => P_PMETH_INFORMATION19
      ,P_PMETH_INFORMATION20            => P_PMETH_INFORMATION20
      ,P_COMMENTS                       => P_COMMENTS
      ,P_SEGMENT1                       => P_SEGMENT1
      ,P_SEGMENT2                       => P_SEGMENT2
      ,P_SEGMENT3                       => P_SEGMENT3
      ,P_SEGMENT4                       => P_SEGMENT4
      ,P_SEGMENT5                       => P_SEGMENT5
      ,P_SEGMENT6                       => P_SEGMENT6
      ,P_SEGMENT7                       => P_SEGMENT7
      ,P_SEGMENT8                       => P_SEGMENT8
      ,P_SEGMENT9                       => P_SEGMENT9
      ,P_SEGMENT10                      => P_SEGMENT10
      ,P_SEGMENT11                      => P_SEGMENT11
      ,P_SEGMENT12                      => P_SEGMENT12
      ,P_SEGMENT13                      => P_SEGMENT13
      ,P_SEGMENT14                      => P_SEGMENT14
      ,P_SEGMENT15                      => P_SEGMENT15
      ,P_SEGMENT16                      => P_SEGMENT16
      ,P_SEGMENT17                      => P_SEGMENT17
      ,P_SEGMENT18                      => P_SEGMENT18
      ,P_SEGMENT19                      => P_SEGMENT19
      ,P_SEGMENT20                      => P_SEGMENT20
      ,P_SEGMENT21                      => P_SEGMENT21
      ,P_SEGMENT22                      => P_SEGMENT22
      ,P_SEGMENT23                      => P_SEGMENT23
      ,P_SEGMENT24                      => P_SEGMENT24
      ,P_SEGMENT25                      => P_SEGMENT25
      ,P_SEGMENT26                      => P_SEGMENT26
      ,P_SEGMENT27                      => P_SEGMENT27
      ,P_SEGMENT28                      => P_SEGMENT28
      ,P_SEGMENT29                      => P_SEGMENT29
      ,P_SEGMENT30                      => P_SEGMENT30
      ,P_CONCAT_SEGMENTS                => P_CONCAT_SEGMENTS
      ,P_GL_SEGMENT1                    => P_GL_SEGMENT1
      ,P_GL_SEGMENT2                    => P_GL_SEGMENT2
      ,P_GL_SEGMENT3                    => P_GL_SEGMENT3
      ,P_GL_SEGMENT4                    => P_GL_SEGMENT4
      ,P_GL_SEGMENT5                    => P_GL_SEGMENT5
      ,P_GL_SEGMENT6                    => P_GL_SEGMENT6
      ,P_GL_SEGMENT7                    => P_GL_SEGMENT7
      ,P_GL_SEGMENT8                    => P_GL_SEGMENT8
      ,P_GL_SEGMENT9                    => P_GL_SEGMENT9
      ,P_GL_SEGMENT10                   => P_GL_SEGMENT10
      ,P_GL_SEGMENT11                   => P_GL_SEGMENT11
      ,P_GL_SEGMENT12                   => P_GL_SEGMENT12
      ,P_GL_SEGMENT13                   => P_GL_SEGMENT13
      ,P_GL_SEGMENT14                   => P_GL_SEGMENT14
      ,P_GL_SEGMENT15                   => P_GL_SEGMENT15
      ,P_GL_SEGMENT16                   => P_GL_SEGMENT16
      ,P_GL_SEGMENT17                   => P_GL_SEGMENT17
      ,P_GL_SEGMENT18                   => P_GL_SEGMENT18
      ,P_GL_SEGMENT19                   => P_GL_SEGMENT19
      ,P_GL_SEGMENT20                   => P_GL_SEGMENT20
      ,P_GL_SEGMENT21                   => P_GL_SEGMENT21
      ,P_GL_SEGMENT22                   => P_GL_SEGMENT22
      ,P_GL_SEGMENT23                   => P_GL_SEGMENT23
      ,P_GL_SEGMENT24                   => P_GL_SEGMENT24
      ,P_GL_SEGMENT25                   => P_GL_SEGMENT25
      ,P_GL_SEGMENT26                   => P_GL_SEGMENT26
      ,P_GL_SEGMENT27                   => P_GL_SEGMENT27
      ,P_GL_SEGMENT28                   => P_GL_SEGMENT28
      ,P_GL_SEGMENT29                   => P_GL_SEGMENT29
      ,P_GL_SEGMENT30                   => P_GL_SEGMENT30
      ,P_GL_CONCAT_SEGMENTS             => P_GL_CONCAT_SEGMENTS
      ,P_GL_CTRL_SEGMENT1               => P_GL_CTRL_SEGMENT1
      ,P_GL_CTRL_SEGMENT2               => P_GL_CTRL_SEGMENT2
      ,P_GL_CTRL_SEGMENT3               => P_GL_CTRL_SEGMENT3
      ,P_GL_CTRL_SEGMENT4               => P_GL_CTRL_SEGMENT4
      ,P_GL_CTRL_SEGMENT5               => P_GL_CTRL_SEGMENT5
      ,P_GL_CTRL_SEGMENT6               => P_GL_CTRL_SEGMENT6
      ,P_GL_CTRL_SEGMENT7               => P_GL_CTRL_SEGMENT7
      ,P_GL_CTRL_SEGMENT8               => P_GL_CTRL_SEGMENT8
      ,P_GL_CTRL_SEGMENT9               => P_GL_CTRL_SEGMENT9
      ,P_GL_CTRL_SEGMENT10              => P_GL_CTRL_SEGMENT10
      ,P_GL_CTRL_SEGMENT11              => P_GL_CTRL_SEGMENT11
      ,P_GL_CTRL_SEGMENT12              => P_GL_CTRL_SEGMENT12
      ,P_GL_CTRL_SEGMENT13              => P_GL_CTRL_SEGMENT13
      ,P_GL_CTRL_SEGMENT14              => P_GL_CTRL_SEGMENT14
      ,P_GL_CTRL_SEGMENT15              => P_GL_CTRL_SEGMENT15
      ,P_GL_CTRL_SEGMENT16              => P_GL_CTRL_SEGMENT16
      ,P_GL_CTRL_SEGMENT17              => P_GL_CTRL_SEGMENT17
      ,P_GL_CTRL_SEGMENT18              => P_GL_CTRL_SEGMENT18
      ,P_GL_CTRL_SEGMENT19              => P_GL_CTRL_SEGMENT19
      ,P_GL_CTRL_SEGMENT20              => P_GL_CTRL_SEGMENT20
      ,P_GL_CTRL_SEGMENT21              => P_GL_CTRL_SEGMENT21
      ,P_GL_CTRL_SEGMENT22              => P_GL_CTRL_SEGMENT22
      ,P_GL_CTRL_SEGMENT23              => P_GL_CTRL_SEGMENT23
      ,P_GL_CTRL_SEGMENT24              => P_GL_CTRL_SEGMENT24
      ,P_GL_CTRL_SEGMENT25              => P_GL_CTRL_SEGMENT25
      ,P_GL_CTRL_SEGMENT26              => P_GL_CTRL_SEGMENT26
      ,P_GL_CTRL_SEGMENT27              => P_GL_CTRL_SEGMENT27
      ,P_GL_CTRL_SEGMENT28              => P_GL_CTRL_SEGMENT28
      ,P_GL_CTRL_SEGMENT29              => P_GL_CTRL_SEGMENT29
      ,P_GL_CTRL_SEGMENT30              => P_GL_CTRL_SEGMENT30
      ,P_GL_CTRL_CONCAT_SEGMENTS        => P_GL_CTRL_CONCAT_SEGMENTS
      ,P_GL_CCRL_SEGMENT1               => P_GL_CCRL_SEGMENT1
      ,P_GL_CCRL_SEGMENT2               => P_GL_CCRL_SEGMENT2
      ,P_GL_CCRL_SEGMENT3               => P_GL_CCRL_SEGMENT3
      ,P_GL_CCRL_SEGMENT4               => P_GL_CCRL_SEGMENT4
      ,P_GL_CCRL_SEGMENT5               => P_GL_CCRL_SEGMENT5
      ,P_GL_CCRL_SEGMENT6               => P_GL_CCRL_SEGMENT6
      ,P_GL_CCRL_SEGMENT7               => P_GL_CCRL_SEGMENT7
      ,P_GL_CCRL_SEGMENT8               => P_GL_CCRL_SEGMENT8
      ,P_GL_CCRL_SEGMENT9               => P_GL_CCRL_SEGMENT9
      ,P_GL_CCRL_SEGMENT10              => P_GL_CCRL_SEGMENT10
      ,P_GL_CCRL_SEGMENT11              => P_GL_CCRL_SEGMENT11
      ,P_GL_CCRL_SEGMENT12              => P_GL_CCRL_SEGMENT12
      ,P_GL_CCRL_SEGMENT13              => P_GL_CCRL_SEGMENT13
      ,P_GL_CCRL_SEGMENT14              => P_GL_CCRL_SEGMENT14
      ,P_GL_CCRL_SEGMENT15              => P_GL_CCRL_SEGMENT15
      ,P_GL_CCRL_SEGMENT16              => P_GL_CCRL_SEGMENT16
      ,P_GL_CCRL_SEGMENT17              => P_GL_CCRL_SEGMENT17
      ,P_GL_CCRL_SEGMENT18              => P_GL_CCRL_SEGMENT18
      ,P_GL_CCRL_SEGMENT19              => P_GL_CCRL_SEGMENT19
      ,P_GL_CCRL_SEGMENT20              => P_GL_CCRL_SEGMENT20
      ,P_GL_CCRL_SEGMENT21              => P_GL_CCRL_SEGMENT21
      ,P_GL_CCRL_SEGMENT22              => P_GL_CCRL_SEGMENT22
      ,P_GL_CCRL_SEGMENT23              => P_GL_CCRL_SEGMENT23
      ,P_GL_CCRL_SEGMENT24              => P_GL_CCRL_SEGMENT24
      ,P_GL_CCRL_SEGMENT25              => P_GL_CCRL_SEGMENT25
      ,P_GL_CCRL_SEGMENT26              => P_GL_CCRL_SEGMENT26
      ,P_GL_CCRL_SEGMENT27              => P_GL_CCRL_SEGMENT27
      ,P_GL_CCRL_SEGMENT28              => P_GL_CCRL_SEGMENT28
      ,P_GL_CCRL_SEGMENT29              => P_GL_CCRL_SEGMENT29
      ,P_GL_CCRL_SEGMENT30              => P_GL_CCRL_SEGMENT30
      ,P_GL_CCRL_CONCAT_SEGMENTS        => P_GL_CCRL_CONCAT_SEGMENTS
      ,P_GL_ERR_SEGMENT1                => P_GL_ERR_SEGMENT1
      ,P_GL_ERR_SEGMENT2                => P_GL_ERR_SEGMENT2
      ,P_GL_ERR_SEGMENT3                => P_GL_ERR_SEGMENT3
      ,P_GL_ERR_SEGMENT4                => P_GL_ERR_SEGMENT4
      ,P_GL_ERR_SEGMENT5                => P_GL_ERR_SEGMENT5
      ,P_GL_ERR_SEGMENT6                => P_GL_ERR_SEGMENT6
      ,P_GL_ERR_SEGMENT7                => P_GL_ERR_SEGMENT7
      ,P_GL_ERR_SEGMENT8                => P_GL_ERR_SEGMENT8
      ,P_GL_ERR_SEGMENT9                => P_GL_ERR_SEGMENT9
      ,P_GL_ERR_SEGMENT10               => P_GL_ERR_SEGMENT10
      ,P_GL_ERR_SEGMENT11               => P_GL_ERR_SEGMENT11
      ,P_GL_ERR_SEGMENT12               => P_GL_ERR_SEGMENT12
      ,P_GL_ERR_SEGMENT13               => P_GL_ERR_SEGMENT13
      ,P_GL_ERR_SEGMENT14               => P_GL_ERR_SEGMENT14
      ,P_GL_ERR_SEGMENT15               => P_GL_ERR_SEGMENT15
      ,P_GL_ERR_SEGMENT16               => P_GL_ERR_SEGMENT16
      ,P_GL_ERR_SEGMENT17               => P_GL_ERR_SEGMENT17
      ,P_GL_ERR_SEGMENT18               => P_GL_ERR_SEGMENT18
      ,P_GL_ERR_SEGMENT19               => P_GL_ERR_SEGMENT19
      ,P_GL_ERR_SEGMENT20               => P_GL_ERR_SEGMENT20
      ,P_GL_ERR_SEGMENT21               => P_GL_ERR_SEGMENT21
      ,P_GL_ERR_SEGMENT22               => P_GL_ERR_SEGMENT22
      ,P_GL_ERR_SEGMENT23               => P_GL_ERR_SEGMENT23
      ,P_GL_ERR_SEGMENT24               => P_GL_ERR_SEGMENT24
      ,P_GL_ERR_SEGMENT25               => P_GL_ERR_SEGMENT25
      ,P_GL_ERR_SEGMENT26               => P_GL_ERR_SEGMENT26
      ,P_GL_ERR_SEGMENT27               => P_GL_ERR_SEGMENT27
      ,P_GL_ERR_SEGMENT28               => P_GL_ERR_SEGMENT28
      ,P_GL_ERR_SEGMENT29               => P_GL_ERR_SEGMENT29
      ,P_GL_ERR_SEGMENT30               => P_GL_ERR_SEGMENT30
      ,P_GL_ERR_CONCAT_SEGMENTS         => P_GL_ERR_CONCAT_SEGMENTS
      ,P_SETS_OF_BOOK_ID                => P_SETS_OF_BOOK_ID
      ,P_EFFECTIVE_START_DATE           => l_EFFECTIVE_START_DATE
      ,P_EFFECTIVE_END_DATE             => l_EFFECTIVE_END_DATE
      ,P_ASSET_CODE_COMBINATION_ID      => l_ASSET_CODE_COMBINATION_ID
      ,P_COMMENT_ID                     => l_COMMENT_ID
      ,P_EXTERNAL_ACCOUNT_ID            => l_EXTERNAL_ACCOUNT_ID
      ,P_TRANSFER_TO_GL_FLAG            => P_TRANSFER_TO_GL_FLAG
      ,P_COST_PAYMENT                   => P_COST_PAYMENT
      ,P_COST_CLEARED_PAYMENT           => P_COST_CLEARED_PAYMENT
      ,P_COST_CLEARED_VOID_PAYMENT      => P_COST_CLEARED_VOID_PAYMENT
      ,P_EXCLUDE_MANUAL_PAYMENT         => P_EXCLUDE_MANUAL_PAYMENT
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_org_payment_method_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number     := l_object_version_number;
  p_comment_id                := l_comment_id;
  p_external_account_id       := l_external_account_id;
  p_effective_start_date      := l_effective_start_date;
  p_effective_end_date        := l_effective_end_date;
  p_asset_code_combination_id := l_asset_code_combination_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 75);
  hr_utility.trace_off;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_org_payment_method;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_comment_id := null;
    p_external_account_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_asset_code_combination_id := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_org_payment_method;
    p_comment_id := null;
    p_external_account_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_asset_code_combination_id := null;
    p_object_version_number := l_copy_ov_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_org_payment_method;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_org_payment_method >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_org_payment_method
  (P_VALIDATE                      in            boolean  default false
  ,P_EFFECTIVE_DATE                in            date
  ,P_DATETRACK_DELETE_MODE         in            varchar2
  ,P_ORG_PAYMENT_METHOD_ID         in            number
  ,P_OBJECT_VERSION_NUMBER         in out nocopy number
  ,P_EFFECTIVE_START_DATE             out nocopy date
  ,P_EFFECTIVE_END_DATE               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'delete_org_payment_method';
  l_effective_start_date      pay_org_payment_methods_f.effective_start_date%TYPE;
  l_effective_end_date        pay_org_payment_methods_f.effective_end_date%TYPE;
  l_object_version_number     pay_org_payment_methods_f.object_version_number%TYPE;
  l_effective_date            date;
  l_copy_ov_number            number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  l_copy_ov_number := p_object_version_number;
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_org_payment_method;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_object_version_number  := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_org_payment_method_bk3.delete_org_payment_method_b
      (P_EFFECTIVE_DATE                => l_EFFECTIVE_DATE
      ,P_DATETRACK_DELETE_MODE         => P_DATETRACK_DELETE_MODE
      ,P_ORG_PAYMENT_METHOD_ID         => P_ORG_PAYMENT_METHOD_ID
      ,P_OBJECT_VERSION_NUMBER         => P_OBJECT_VERSION_NUMBER
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_org_payment_method_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  if (p_datetrack_delete_mode = hr_api.g_zap) then
     --
     --  Need to lock main table to maintain the locking ladder order
     --
     hr_utility.set_location( l_proc, 30);
     --
     pay_opm_shd.lck
       (p_effective_date                   => l_effective_date
       ,p_datetrack_mode                   => p_datetrack_delete_mode
       ,p_org_payment_method_id            => p_org_payment_method_id
       ,p_object_version_number            => p_object_version_number
       ,p_validation_start_date            => l_effective_start_date
       ,p_validation_end_date              => l_effective_end_date
       );
     --
     --  Remove all matching translation rows
     --
     hr_utility.set_location( l_proc, 35);
     --
     pay_opt_del.del_tl
       (P_ORG_PAYMENT_METHOD_ID         => P_ORG_PAYMENT_METHOD_ID
       );
     --
  end if;
  --
  --  Remove non-translated data row
  --
  hr_utility.set_location( l_proc, 40);
  --
  pay_opm_del.del
    (p_effective_date                   => l_effective_date
    ,p_datetrack_mode                   => P_DATETRACK_DELETE_MODE
    ,p_org_payment_method_id            => p_org_payment_method_id
    ,p_object_version_number            => l_object_version_number
    ,p_effective_start_date             => l_effective_start_date
    ,p_effective_end_date               => l_effective_end_date
    );
  --
  --
  -- removing any redundant bank details within ap.
  --
  if (pay_ce_support_pkg.pay_and_ce_licensed) then
     --Bug No. 4644827
     pay_maintain_bank_acct.remove_redundant_bank_detail;
  end if;
  --
  hr_utility.set_location( l_proc, 45);
  PAY_PAYMENT_GL_ACCOUNTS_PKG.DELETE_ROW (
  p_org_payment_method_id  => p_org_payment_method_id
 ,p_effective_date         => l_effective_date
 ,p_datetrack_mode         => P_DATETRACK_DELETE_MODE
 ,p_org_eff_start_date     => l_effective_start_date
 ,p_org_eff_end_date       => l_effective_end_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Call After Process User Hook
  --
  begin
    pay_org_payment_method_bk3.delete_org_payment_method_a
      (P_EFFECTIVE_DATE                => l_EFFECTIVE_DATE
      ,P_DATETRACK_DELETE_MODE         => P_DATETRACK_DELETE_MODE
      ,P_ORG_PAYMENT_METHOD_ID         => P_ORG_PAYMENT_METHOD_ID
      ,P_OBJECT_VERSION_NUMBER         => l_OBJECT_VERSION_NUMBER
      ,P_EFFECTIVE_START_DATE          => l_EFFECTIVE_START_DATE
      ,P_EFFECTIVE_END_DATE            => l_EFFECTIVE_END_DATE
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_org_payment_method_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 21);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_org_payment_method;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 22);
  --
  when others then
  --
  --
  ROLLBACK TO delete_org_payment_method;
  --
  p_object_version_number  := l_copy_ov_number;
  p_effective_start_date   := null;
  p_effective_end_date     := null;
  raise;
  --
end delete_org_payment_method;
--
--
end PAY_ORG_PAYMENT_METHOD_API;

/
