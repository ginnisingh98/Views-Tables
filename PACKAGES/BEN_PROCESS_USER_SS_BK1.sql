--------------------------------------------------------
--  DDL for Package BEN_PROCESS_USER_SS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PROCESS_USER_SS_BK1" AUTHID CURRENT_USER AS
/* $Header: benusrwf.pkh 115.7 2002/12/23 13:22:49 rpgupta noship $*/
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_user_details_b >------------------------|
-- ----------------------------------------------------------------------------
procedure create_user_details_b
            (p_user_name                 in varchar2
           ,p_owner                      in varchar2
           ,p_unencrypted_password       in varchar2
           ,p_session_number             in number
           ,p_start_date                 in date
           ,p_end_date                   in date
           ,p_last_logon_date            in date
           ,p_description                in varchar2
           ,p_password_date              in date
           ,p_password_accesses_left     in number
           ,p_password_lifespan_accesses in number
           ,p_password_lifespan_days     in number
           ,p_employee_id                in number
           ,p_email_address              in varchar2
           ,p_fax                        in varchar2
           ,p_customer_id                in number
           ,p_supplier_id                in number
           ,p_responsibility_id          in number
           ,p_respons_application_id     in number
           ,p_business_group_id          in number
           );
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_user_details_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_details_a
            (p_user_name                 in varchar2
           ,p_owner                      in varchar2
           ,p_unencrypted_password       in varchar2
           ,p_session_number             in number
           ,p_start_date                 in date
           ,p_end_date                   in date
           ,p_last_logon_date            in date
           ,p_description                in varchar2
           ,p_password_date              in date
           ,p_password_accesses_left     in number
           ,p_password_lifespan_accesses in number
           ,p_password_lifespan_days     in number
           ,p_employee_id                in number
           ,p_email_address              in varchar2
           ,p_fax                        in varchar2
           ,p_customer_id                in number
           ,p_supplier_id                in number
           ,p_responsibility_id          in number
           ,p_respons_application_id     in number
           ,p_user_id                    in number
           ,p_business_group_id          in number
           );
--
end ben_process_user_ss_bk1;

 

/
