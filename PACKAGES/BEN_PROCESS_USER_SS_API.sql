--------------------------------------------------------
--  DDL for Package BEN_PROCESS_USER_SS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PROCESS_USER_SS_API" AUTHID CURRENT_USER AS
/* $Header: benusrwf.pkh 115.7 2002/12/23 13:22:49 rpgupta noship $*/
--
-- Global constants
g_column_delimiter      constant varchar2(3) := '~^|';
g_user_process_seq      number default null;
--
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is the procedure which does the actual work.
-- ---------------------------------------------------------------------------
procedure get_user_data_from_tt
  (p_transaction_step_id             in  number
  ,p_user_name                       out nocopy varchar2
  ,p_user_pswd                       out nocopy varchar2
  ,p_pswd_hint                       out nocopy varchar2
  ,p_owner                        out nocopy varchar2
  ,p_session_number               out nocopy number
  ,p_start_date                   out nocopy date
  ,p_end_date                     out nocopy date
  ,p_last_logon_date              out nocopy date
  ,p_password_date                out nocopy date
  ,p_password_accesses_left       out nocopy number
  ,p_password_lifespan_accesses   out nocopy number
  ,p_password_lifespan_days       out nocopy number
  ,p_employee_id                  out nocopy number
  ,p_email_address                out nocopy varchar2
  ,p_fax                          out nocopy varchar2
  ,p_customer_id                  out nocopy number
  ,p_supplier_id                  out nocopy number
  ,p_business_group_id            out nocopy number
  ,p_respons_id                   out nocopy number
  ,p_respons_appl_id              out nocopy number
   );
--
-- ---------------------------------------------------------------------------
-- ------------------------- < update_user_details > -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will perform validations when a user presses Next
--          on user page or on the Review page.
--          Either case, the data will be saved to the transaction table.
--          If this procedure is invoked from Review page, it will first check
--          that if a transaction already exists.  If it does, it will update
--          the current transaction record.
--          NOTE: The p_validate_mode cannot be in boolean because this
--                procedure will be called from Java which has a different
--                boolean value from pl/sql.
-- ---------------------------------------------------------------------------
procedure update_user_details
  (p_item_type                    in varchar2
  ,p_item_key                     in varchar2
  ,p_actid                        in number
  ,p_login_person_id              in number
  ,p_process_section_name         in varchar2
  ,p_review_page_region_code      in varchar2
  ,p_user_name                    in varchar2
  ,p_owner                        in varchar2
  ,p_unencrypted_password         in varchar2
  ,p_session_number               in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_last_logon_date              in date
  ,p_description                  in varchar2
  ,p_password_date                in date
  ,p_password_accesses_left       in number
  ,p_password_lifespan_accesses   in number
  ,p_password_lifespan_days       in number
  ,p_employee_id                  in number
  ,p_email_address                in varchar2
  ,p_fax                          in varchar2
  ,p_customer_id                  in number
  ,p_supplier_id                  in number
  ,p_business_group_id            in number
  );
--
-- ---------------------------------------------------------------------------
-- ---------------------- < create_user_details> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure does have user hooks and actually calls fnd_user_pkg to do inserts.
-- ---------------------------------------------------------------------------
procedure create_user_details
           (p_validate                   in     boolean  default false
           ,p_user_name                  in varchar2
           ,p_owner                      in varchar2 default null
           ,p_unencrypted_password       in varchar2
           ,p_session_number             in number default 0
           ,p_start_date                 in date default sysdate
           ,p_end_date                   in date default null
           ,p_last_logon_date            in date default null
           ,p_description                in varchar2 default null
           ,p_password_date              in date default sysdate
           ,p_password_accesses_left     in number default null
           ,p_password_lifespan_accesses in number default null
           ,p_password_lifespan_days     in number default null
           ,p_employee_id                in number default null
           ,p_email_address              in varchar2 default null
           ,p_fax                        in varchar2 default null
           ,p_customer_id                in number default null
           ,p_supplier_id                in number default null
           ,p_business_group_id          in number default null
           ,p_responsibility_id          in number default null
           ,p_respons_application_id in number default null
           ,p_api_error                   out nocopy boolean
           ,p_user_id                     out nocopy number
           );
-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- ----------------------------- < process_api > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will be invoked in workflow notification
--          when an approver approves all the changes.  This procedure
--          will call the api to update to the database with p_validate
--          equal to false.
-- ---------------------------------------------------------------------------
procedure process_api
          (p_validate            in boolean default false
          ,p_transaction_step_id in number);
--
-- ---------------------------------------------------------------------------
end ben_process_user_ss_api;
--

 

/
