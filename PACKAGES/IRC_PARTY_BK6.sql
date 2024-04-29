--------------------------------------------------------
--  DDL for Package IRC_PARTY_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PARTY_BK6" AUTHID CURRENT_USER as
/* $Header: irhzpapi.pkh 120.15.12010000.5 2010/04/16 14:57:54 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< SELF_REGISTER_USER_B >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure SELF_REGISTER_USER_B
    (p_current_email_address                 IN VARCHAR2
    ,p_responsibility_id                     IN NUMBER
    ,p_resp_appl_id                          IN NUMBER
    ,p_security_group_id                     IN NUMBER
    ,p_first_name                            IN VARCHAR2
    ,p_last_name                             IN VARCHAR2
    ,p_middle_names                          IN VARCHAR2
    ,p_previous_last_name                    IN VARCHAR2
    ,p_employee_number                       IN VARCHAR2
    ,p_national_identifier                   IN VARCHAR2
    ,p_date_of_birth                         IN DATE
    ,p_email_address                         IN VARCHAR2
    ,p_home_phone_number                     IN VARCHAR2
    ,p_work_phone_number                     IN VARCHAR2
    ,p_address_line_1                        IN VARCHAR2
    ,p_manager_last_name                     IN VARCHAR2
    ,p_allow_access                          IN VARCHAR2
    ,p_language                              IN VARCHAR2
    ,p_user_name                             IN VARCHAR2
    );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< SELF_REGISTER_USER_A >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure SELF_REGISTER_USER_A
    (p_current_email_address                 IN VARCHAR2
    ,p_responsibility_id                     IN NUMBER
    ,p_resp_appl_id                          IN NUMBER
    ,p_security_group_id                     IN NUMBER
    ,p_first_name                            IN VARCHAR2
    ,p_last_name                             IN VARCHAR2
    ,p_middle_names                          IN VARCHAR2
    ,p_previous_last_name                    IN VARCHAR2
    ,p_employee_number                       IN VARCHAR2
    ,p_national_identifier                   IN VARCHAR2
    ,p_date_of_birth                         IN DATE
    ,p_email_address                         IN VARCHAR2
    ,p_home_phone_number                     IN VARCHAR2
    ,p_work_phone_number                     IN VARCHAR2
    ,p_address_line_1                        IN VARCHAR2
    ,p_manager_last_name                     IN VARCHAR2
    ,p_allow_access                          IN VARCHAR2
    ,p_language                              IN VARCHAR2
    ,p_user_name                             IN VARCHAR2
    );
--
end IRC_PARTY_BK6;

/
