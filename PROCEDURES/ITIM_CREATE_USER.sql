--------------------------------------------------------
--  DDL for Procedure ITIM_CREATE_USER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."ITIM_CREATE_USER" (
  user_name                  in  varchar2,
  owner                      in  varchar2,
  unencrypted_password       in  varchar2,
  session_number             in  number   default 0,
  start_date                 in  date     default NULL,
  end_date                   in  date     default NULL,
  last_logon_date            in  date     default NULL,
  description                in  varchar2 default NULL,
  password_date              in  date     default NULL,
  password_accesses_left     in  number   default NULL,
  password_lifespan_accesses in  number   default NULL,
  password_lifespan_days     in  number   default NULL,
  employee_id                in  number   default NULL,
  email_address              in  varchar2 default NULL,
  fax                        in  varchar2 default NULL,
  customer_id                in  number   default NULL,
  supplier_id                in  number   default NULL
)
AS
begin

     FND_USER_PKG.CreateUser (
          x_user_name                  => user_name,
          x_owner                      => owner,
          x_unencrypted_password       => unencrypted_password,
          x_session_number             => session_number,
          x_start_date                 => start_date,
          x_end_date                   => end_date,
          x_last_logon_date            => last_logon_date,
          x_description                => description,
          x_password_date              => password_date,
          x_password_accesses_left     => password_accesses_left,
          x_password_lifespan_accesses => password_lifespan_accesses,
          x_password_lifespan_days     => password_lifespan_days,
          x_employee_id                => employee_id,
          x_email_address              => email_address,
          x_fax                        => fax,
          x_customer_id                => customer_id,
          x_supplier_id                => supplier_id);
end ITIM_CREATE_USER;

/

  GRANT EXECUTE ON "APPS"."ITIM_CREATE_USER" TO "NONAPPS";
