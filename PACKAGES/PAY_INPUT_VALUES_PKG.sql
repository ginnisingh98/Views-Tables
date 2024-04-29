--------------------------------------------------------
--  DDL for Package PAY_INPUT_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_INPUT_VALUES_PKG" AUTHID CURRENT_USER as
/* $Header: pyipv.pkh 120.0.12010000.1 2008/07/27 22:56:18 appldev ship $ */

--------------------------------------------------------------------------------
procedure validate_translation (input_value_id IN    number,
                                language IN             varchar2,
                                input_name IN  varchar2);
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_element_type_id IN number);
--------------------------------------------------------------------------------
function NO_DEFAULT_AT_LINK (
--
        p_input_value_id        number,
        p_effective_start_date  date,
        p_effective_end_date    date,
        p_error_if_true         boolean := FALSE) return boolean;
--------------------------------------------------------------------------------
function ELEMENT_ENTRY_NEEDS_DEFAULT (
--
        p_input_value_id        number,
        p_effective_start_date  date,
        p_effective_end_date    date,
        p_error_if_true         boolean := FALSE        ) return boolean ;
--------------------------------------------------------------------------------
procedure RECREATE_DB_ITEMS (
                                        --
        p_element_type_id       number);
--------------------------------------------------------------------------------
procedure PARENT_DELETED (
                                        --
        p_element_type_id       number,
        p_session_date          date            default trunc(sysdate),
        p_validation_start_date date,
        p_validation_end_date   date,
        p_delete_mode           varchar2        default 'DELETE');
-------------------------------------------------------------------------------
function CANT_DELETE_ALL_INPUT_VALUES (
--
p_element_type_id       number,
p_delete_mode           varchar2,
p_validation_start_date date,
p_validation_end_date   date,
p_error_if_true         boolean default FALSE) return boolean ;
--------------------------------------------------------------------------------
function DELETION_ALLOWED (
                                        --
p_input_value_id        number,
p_delete_mode           varchar2,
p_validation_start_date date,
p_validation_end_date   date,
p_error_if_true         boolean default FALSE) return boolean ;
-----------------------------------------------------------------------------
function NO_OF_INPUT_VALUES (p_element_type_id  number) return number;
--------------------------------------------------------------------------------
function DATE_EFFECTIVELY_UPDATED (
                                        --
p_input_value_id                        number,
p_rowid                                 varchar2) return boolean;
--------------------------------------------------------------------------------
function NAME_NOT_UNIQUE (
                                        --
p_element_type_id       number,
p_rowid                 varchar2        default null,
p_name                  varchar2,
p_error_if_true         boolean         default FALSE) return boolean;
--------------------------------------------------------------------------------
function MANDATORY_IN_FUTURE (
                                        --
        p_input_value_id        number,
        p_session_date          date    default trunc(sysdate),
        p_error_if_true         boolean default FALSE   ) return boolean;
--------------------------------------------------------------------------------
procedure INSERT_ROW (
                                        --
        p_effective_start_date          date            default trunc (sysdate),
        p_effective_end_date            date default to_date ('31/12/4712',
                                                                'DD/MM/YYYY'),
        p_element_type_id               number,
        p_lookup_type                   varchar2        default null,
        p_business_group_id             number          default null,
        p_legislation_code              varchar2        default null,
        p_formula_id                    number          default null,
        p_display_sequence              number          default 1,
        p_generate_db_items_flag        varchar2        default 'Y',
        p_hot_default_flag              varchar2        default 'N',
        p_mandatory_flag                varchar2        default 'N',

-- change 115.7 - make p_name default to null
        --p_name                        varchar2        default 'Pay Value',
        p_name                          varchar2        default null,
-- change 115.7 - make p_base_name a mandatory parameter
        --p_base_name                   varchar2        default 'Pay Value',
        p_base_name                     varchar2,

        p_uom                           varchar2        default 'M',
        p_default_value                 varchar2        default null,
        p_legislation_subgroup          varchar2        default null,
        p_max_value                     varchar2        default null,
        p_min_value                     varchar2        default null,
        p_warning_or_error              varchar2        default null,
        p_classification_id             number          default null,
-- Enhancement 2793978
        p_value_set_id                  number          default null,
--
        p_input_value_id        in out  nocopy number,
        p_rowid                 in out  nocopy varchar2);
---------------------------------------------------------------------------
procedure UPDATE_ROW(
                                        --
        p_ROWID                                         VARCHAR2,
        p_INPUT_VALUE_ID                                NUMBER,
        p_EFFECTIVE_START_DATE                          DATE,
        p_EFFECTIVE_END_DATE                            DATE,
        p_ELEMENT_TYPE_ID                               NUMBER,
        p_LOOKUP_TYPE                                   VARCHAR2,
        p_BUSINESS_GROUP_ID                             NUMBER,
        p_LEGISLATION_CODE                              VARCHAR2,
        p_FORMULA_ID                                    NUMBER,
        p_DISPLAY_SEQUENCE                              NUMBER,
        p_GENERATE_DB_ITEMS_FLAG                        VARCHAR2,
        p_HOT_DEFAULT_FLAG                              VARCHAR2,
        p_MANDATORY_FLAG                                VARCHAR2,
        p_NAME                                          VARCHAR2,
        p_UOM                                           VARCHAR2,
        p_DEFAULT_VALUE                                 VARCHAR2,
        p_LEGISLATION_SUBGROUP                          VARCHAR2,
        p_MAX_VALUE                                     VARCHAR2,
        p_MIN_VALUE                                     VARCHAR2,
        p_WARNING_OR_ERROR                              VARCHAR2,
-- Enhancement 2793978
        p_value_set_id                                  number default null,
--
        p_recreate_db_items                             varchar2,
        p_base_name                                     varchar2);
---------------------------------------------------------------------------
procedure DELETE_ROW (
                                        --
        p_rowid                 varchar2,
        p_input_value_id        number,
        p_delete_mode           varchar2,
        p_session_date          date,
        p_validation_start_date date default
                                     to_date ('01/01/0001','DD/MM/YYYY'),
        p_validation_end_date   date default
                                     to_date ('31/12/4712','DD/MM/YYYY'));
---------------------------------------------------------------------------
procedure LOCK_ROW (
        p_rowid                                         VARCHAR2,
        p_INPUT_VALUE_ID                                NUMBER,
        p_EFFECTIVE_START_DATE                          DATE,
        p_EFFECTIVE_END_DATE                            DATE,
        p_ELEMENT_TYPE_ID                               NUMBER,
        p_LOOKUP_TYPE                                   VARCHAR2,
        p_BUSINESS_GROUP_ID                             NUMBER,
        p_LEGISLATION_CODE                              VARCHAR2,
        p_FORMULA_ID                                    NUMBER,
        p_DISPLAY_SEQUENCE                              NUMBER,
        p_GENERATE_DB_ITEMS_FLAG                        VARCHAR2,
        p_HOT_DEFAULT_FLAG                              VARCHAR2,
        p_MANDATORY_FLAG                                VARCHAR2,
        --p_NAME                                          VARCHAR2,
-- --
        p_BASE_NAME                                          VARCHAR2,
-- --
        p_UOM                                           VARCHAR2,
        p_DEFAULT_VALUE                                 VARCHAR2,
        p_LEGISLATION_SUBGROUP                          VARCHAR2,
        p_MAX_VALUE                                     VARCHAR2,
        p_MIN_VALUE                                     VARCHAR2,
        p_WARNING_OR_ERROR                              VARCHAR2,
-- Enhancement 2793978
        p_value_set_id                                  NUMBER default null
--
        );
-----------------------------------------------------------
procedure ADD_LANGUAGE;
-----------------------------------------------------------
procedure TRANSLATE_ROW (
   X_I_NAME in varchar2,
   X_I_LEGISLATION_CODE in varchar2,
   X_I_EFFECTIVE_START_DATE in date,
   X_I_EFFECTIVE_END_DATE in date,
   X_I_E_ELEMENT_NAME in varchar2,
   X_I_E_LEGISLATION_CODE in varchar2,
   X_I_E_EFFECTIVE_START_DATE in date,
   X_I_E_EFFECTIVE_END_DATE in date,
   X_NAME in varchar2,
   X_OWNER in varchar2
);
-----------------------------------------------------------
-- Enhancement 2793978
function decode_vset_value (
   p_value_set_id in number,
   p_value_set_value in varchar2
   ) return varchar2;
-----------------------------------------------------------
-- Enhancement 2793978
function decode_vset_meaning (
   p_value_set_id in number,
   p_value_set_meaning in varchar2
   ) return varchar2;
-----------------------------------------------------------
end     PAY_INPUT_VALUES_PKG;

/
