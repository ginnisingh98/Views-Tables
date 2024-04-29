--------------------------------------------------------
--  DDL for Package PAY_ORG_PAYMENT_METHODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ORG_PAYMENT_METHODS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyopm01t.pkh 120.3 2005/09/30 12:40:27 adkumar noship $ */
procedure insert_row(
        p_row_id                           in out nocopy varchar2,
        p_org_payment_method_id            in out nocopy number,
        p_effective_start_date             date,
        p_effective_end_date               date,
        p_business_group_id                number,
        p_external_account_id              number,
        p_currency_code                    varchar2,
        p_payment_type_id                  number,
        p_defined_balance_id               number,
        p_org_payment_method_name          varchar2,
        p_base_opm_name                    varchar2,
        p_comment_id                       number,
        p_attribute_category               varchar2,
        p_attribute1                       varchar2,
        p_attribute2                       varchar2,
        p_attribute3                       varchar2,
        p_attribute4                       varchar2,
        p_attribute5                       varchar2,
        p_attribute6                       varchar2,
        p_attribute7                       varchar2,
        p_attribute8                       varchar2,
        p_attribute9                       varchar2,
        p_attribute10                      varchar2,
        p_attribute11                      varchar2,
        p_attribute12                      varchar2,
        p_attribute13                      varchar2,
        p_attribute14                      varchar2,
        p_attribute15                      varchar2,
        p_attribute16                      varchar2,
        p_attribute17                      varchar2,
        p_attribute18                      varchar2,
        p_attribute19                      varchar2,
        p_attribute20                      varchar2,
        p_pmeth_information_category       varchar2,
        p_pmeth_information1               varchar2,
        p_pmeth_information2               varchar2,
        p_pmeth_information3               varchar2,
        p_pmeth_information4               varchar2,
        p_pmeth_information5               varchar2,
        p_pmeth_information6               varchar2,
        p_pmeth_information7               varchar2,
        p_pmeth_information8               varchar2,
        p_pmeth_information9               varchar2,
        p_pmeth_information10              varchar2,
        p_pmeth_information11              varchar2,
        p_pmeth_information12              varchar2,
        p_pmeth_information13              varchar2,
        p_pmeth_information14              varchar2,
        p_pmeth_information15              varchar2,
        p_pmeth_information16              varchar2,
        p_pmeth_information17              varchar2,
        p_pmeth_information18              varchar2,
        p_pmeth_information19              varchar2,
        p_pmeth_information20              varchar2,
        p_asset_code_combination_id        number,
        p_set_of_books_id                  number,
        p_transfer_to_gl_flag              varchar2,
        p_cost_payment                     varchar2,
        p_cost_cleared_payment             varchar2,
        p_cost_cleared_void_payment        varchar2,
        p_exclude_manual_payment           varchar2,
        p_gl_set_of_books_id               number,
        p_gl_cash_ac_id                    number,
        p_gl_cash_clearing_ac_id           number,
        p_gl_control_ac_id                 number,
        p_gl_error_ac_id                   number,
        p_default_gl_account               varchar2,
        p_bank_account_id                  number,
        p_pay_gl_account_id_out            out nocopy number
        );
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
                                  p_validation_start_date IN DATE,
                                  p_validation_end_date IN DATE);
-----------------------------------------------------------------------------
procedure validate_translation (org_payment_method_id IN    number,
                                language IN             varchar2,
                                org_payment_method_name IN  varchar2);
-----------------------------------------------------------------------------
--
-- Standard delete procedure
--
procedure delete_row(p_org_payment_method_id  NUMBER,
                     p_row_id  varchar2,
                     p_dt_delete_mode varchar2,
                     p_effective_date date,
                     p_org_effective_start_date date,
                     p_org_effective_end_date date );
-----------------------------------------------------------------------------
--
-- Standard lock procedure
--
procedure lock_row(
        p_row_id                           varchar2,
        p_org_payment_method_id            number,
        p_effective_start_date             date,
        p_effective_end_date               date,
        p_business_group_id                number,
        p_external_account_id              number,
        p_currency_code                    varchar2,
        p_payment_type_id                  number,
        p_defined_balance_id               number,
        p_base_opm_name                    varchar2,
        p_comment_id                       number,
        p_attribute_category               varchar2,
        p_attribute1                       varchar2,
        p_attribute2                       varchar2,
        p_attribute3                       varchar2,
        p_attribute4                       varchar2,
        p_attribute5                       varchar2,
        p_attribute6                       varchar2,
        p_attribute7                       varchar2,
        p_attribute8                       varchar2,
        p_attribute9                       varchar2,
        p_attribute10                      varchar2,
        p_attribute11                      varchar2,
        p_attribute12                      varchar2,
        p_attribute13                      varchar2,
        p_attribute14                      varchar2,
        p_attribute15                      varchar2,
        p_attribute16                      varchar2,
        p_attribute17                      varchar2,
        p_attribute18                      varchar2,
        p_attribute19                      varchar2,
        p_attribute20                      varchar2,
        p_pmeth_information_category       varchar2,
        p_pmeth_information1               varchar2,
        p_pmeth_information2               varchar2,
        p_pmeth_information3               varchar2,
        p_pmeth_information4               varchar2,
        p_pmeth_information5               varchar2,
        p_pmeth_information6               varchar2,
        p_pmeth_information7               varchar2,
        p_pmeth_information8               varchar2,
        p_pmeth_information9               varchar2,
        p_pmeth_information10              varchar2,
        p_pmeth_information11              varchar2,
        p_pmeth_information12              varchar2,
        p_pmeth_information13              varchar2,
        p_pmeth_information14              varchar2,
        p_pmeth_information15              varchar2,
        p_pmeth_information16              varchar2,
        p_pmeth_information17              varchar2,
        p_pmeth_information18              varchar2,
        p_pmeth_information19              varchar2,
        p_pmeth_information20              varchar2,
        p_transfer_to_gl_flag              varchar2,
        p_cost_payment                     varchar2,
        p_cost_cleared_payment             varchar2,
        p_cost_cleared_void_payment        varchar2,
        p_exclude_manual_payment           varchar2,
        p_pay_gl_account_id                number,
        p_set_of_books_id                  number,
        p_gl_cash_ac_id                    number,
        p_gl_cash_clearing_ac_id           number,
        p_gl_control_ac_id                 number,
        p_gl_error_ac_id                   number
        );
--
-----------------------------------------------------------------------------
--
-- Standard update procedure
--
procedure update_row(
        p_row_id                           varchar2,
        p_org_payment_method_id            number,
        p_effective_start_date             date,
        p_effective_end_date               date,
        p_business_group_id                number,
        p_external_account_id              number,
        p_currency_code                    varchar2,
        p_payment_type_id                  number,
        p_defined_balance_id               number,
        p_org_payment_method_name          varchar2,
        p_comment_id                       number,
        p_attribute_category               varchar2,
        p_attribute1                       varchar2,
        p_attribute2                       varchar2,
        p_attribute3                       varchar2,
        p_attribute4                       varchar2,
        p_attribute5                       varchar2,
        p_attribute6                       varchar2,
        p_attribute7                       varchar2,
        p_attribute8                       varchar2,
        p_attribute9                       varchar2,
        p_attribute10                      varchar2,
        p_attribute11                      varchar2,
        p_attribute12                      varchar2,
        p_attribute13                      varchar2,
        p_attribute14                      varchar2,
        p_attribute15                      varchar2,
        p_attribute16                      varchar2,
        p_attribute17                      varchar2,
        p_attribute18                      varchar2,
        p_attribute19                      varchar2,
        p_attribute20                      varchar2,
        p_pmeth_information_category       varchar2,
        p_pmeth_information1               varchar2,
        p_pmeth_information2               varchar2,
        p_pmeth_information3               varchar2,
        p_pmeth_information4               varchar2,
        p_pmeth_information5               varchar2,
        p_pmeth_information6               varchar2,
        p_pmeth_information7               varchar2,
        p_pmeth_information8               varchar2,
        p_pmeth_information9               varchar2,
        p_pmeth_information10              varchar2,
        p_pmeth_information11              varchar2,
        p_pmeth_information12              varchar2,
        p_pmeth_information13              varchar2,
        p_pmeth_information14              varchar2,
        p_pmeth_information15              varchar2,
        p_pmeth_information16              varchar2,
        p_pmeth_information17              varchar2,
        p_pmeth_information18              varchar2,
        p_pmeth_information19              varchar2,
        p_pmeth_information20              varchar2,
        p_asset_code_combination_id        number,
        p_set_of_books_id                  number,
        p_dt_update_mode                   varchar2,
        p_base_opm_name                    varchar2,
        p_transfer_to_gl_flag              varchar2,
        p_cost_payment                     varchar2,
        p_cost_cleared_payment             varchar2,
        p_cost_cleared_void_payment        varchar2,
        p_exclude_manual_payment           varchar2,
        p_gl_set_of_books_id               number,
        p_gl_cash_ac_id                    number,
        p_gl_cash_clearing_ac_id           number,
        p_gl_control_ac_id                 number,
        p_gl_error_ac_id                   number,
        p_default_gl_account               varchar2,
        p_bank_account_id                  number,
        p_pay_gl_account_id_out            out nocopy number
        );
--
procedure check_end_date(p_end_date varchar2,
                         p_opm_id number);

function chk_dflt_prpy_ppm(opm_id varchar2,
                           val_start_date varchar2) return boolean;

function payee_type(p_payee_type varchar2,
                    p_payee_id   number,
                    p_effective_date date) return varchar2;

----------------------------------------------------------------
procedure ADD_LANGUAGE;
----------------------------------------------------------------
procedure TRANSLATE_ROW (
   X_O_ORG_PAYMENT_METHOD_NAME in varchar2,
   X_O_EFFECTIVE_START_DATE in date,
   X_O_EFFECTIVE_END_DATE in date,
   X_ORG_PAYMENT_METHOD_NAME in varchar2,
   X_OWNER in varchar2
);
----------------------------------------------------------------
procedure lock_aba_row(
        p_external_account_id   in  number,
        p_set_of_books_id       in  number,
        p_asset_code_combination_id in  number
);
----------------------------------------------------------------
END pay_org_payment_methods_pkg;

 

/
