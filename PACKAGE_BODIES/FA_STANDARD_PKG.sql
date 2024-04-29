--------------------------------------------------------
--  DDL for Package Body FA_STANDARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_STANDARD_PKG" as
/* $Header: faxsrvrb.pls 120.2.12010000.2 2009/07/19 13:04:14 glchen ship $ */

 procedure raise_error(	called_fn in varchar2,
			calling_fn in varchar2,
			name in varchar2 default null,
			token1 in varchar2 default null,
			value1 in varchar2 default null,
			token2 in varchar2 default null,
			value2 in varchar2 default null,
			token3 in varchar2 default null,
			value3 in varchar2 default null,
			translate in boolean default FALSE, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is
   L_err_num number default 0;
  begin
   L_err_num := SQLCODE;
   if L_err_num = -20001 then
     app_exception.raise_exception;
   elsif L_err_num = -20000 then
     raise_application_error(-20000, SQLERRM);
   end if;

   if name is NULL then
     fnd_message.set_name('OFA', 'FA_SHARED_SERVER_ERROR');
     if fnd_profile.value('PRINT_DEBUG') = 'Y' then
       fnd_message.set_token('CALLED_FN', called_fn);
       fnd_message.set_token('CALLING_FN', calling_fn);
       fnd_message.set_token('SQLERRM', SUBSTR(SQLERRM, 1, 100));
     end if;
     app_exception.raise_exception;
     return;
   end if;

   fnd_message.set_name('OFA', name);
   if fnd_profile.value('PRINT_DEBUG') = 'Y' then
     fnd_message.set_token('CALLED_FN', called_fn);
     fnd_message.set_token('CALLING_FN', calling_fn);
   end if;
   if (token1 is not null) then
    fnd_message.set_token(token1, value1, translate);
   end if;
   if (token2 is not null) then
    fnd_message.set_token(token2, value2, translate);
   end if;
   if (token3 is not null) then
    fnd_message.set_token(token3, value3, translate);
   end if;
   app_exception.raise_exception;
  end raise_error;

END FA_STANDARD_PKG;

/
