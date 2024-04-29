--------------------------------------------------------
--  DDL for Package Body FA_STANDARD_DDL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_STANDARD_DDL_PKG" as
/* $Header: faxsddlb.pls 120.4.12010000.2 2009/07/19 13:16:47 glchen ship $ */

  procedure create_sequence(X_name varchar2,
			    X_start_num number,
			    X_max_num number default 2000000000,
			    X_Calling_Fn VARCHAR2) is
   out_oracle_schema varchar2(100);
   out_status varchar2(100);
   out_industry varchar2(100);
   L_x boolean;
   L_chkLastNumber number := -1;
   L_count number default 0;

   l_schema   varchar2(50);
   l_status   varchar2(50);
   l_industry varchar2(50);

   schema_err exception;

  begin
    L_x :=  fnd_installation.get_app_info('FND', out_status,
				out_industry, out_oracle_schema);

    if not (fnd_installation.get_app_info (
                 application_short_name => 'OFA',
                 status                 => l_status,
                 industry               => l_industry,
                 oracle_schema          => l_schema)) then
      raise schema_err;
    end if;

    select count(*) into L_count
    from   all_sequences
    where  sequence_name = X_name
    and    sequence_owner = l_schema;

    if L_count > 0 then
      /* BUG# 1499077 - changing the statement type to correctly be
                        drop_sequence instead of create
          -- bridgway 11/29/00
       */

      ad_ddl.do_ddl(out_oracle_schema, 'OFA',
		    ad_ddl.drop_sequence,
		    'drop sequence ' || X_name,X_name);
    end if;

    ad_ddl.do_ddl(out_oracle_schema, 'OFA',
		ad_ddl.create_sequence,
		'create sequence ' ||
		X_name ||
		' start with ' ||
		to_char(X_start_num) ||
		' MAXVALUE ' ||
		to_char(X_max_num) ||
		' ORDER',X_name);

    select last_number into L_chkLastNumber
    from   all_sequences
    where  sequence_name = X_name
    and    sequence_owner = l_schema;

    if (L_chkLastNumber <> X_start_num) then
	-- Error while creating the sequence
     fa_standard_pkg.raise_error(
	 CALLED_FN => 'fa_standard_pkg.create_sequence',
	 CALLING_FN => X_Calling_Fn,
	 NAME => 'FA_SHARED_FATAL_ERROR');
    end if;

  exception
   when schema_err then
        fa_standard_pkg.raise_error(
          CALLED_FN => 'fa_standard_pkg.create_sequence',
          CALLING_FN => X_Calling_Fn);
   when others then
	fa_standard_pkg.raise_error(
	  CALLED_FN => 'fa_standard_pkg.create_sequence',
	  CALLING_FN => X_Calling_Fn);
  end create_sequence;

END FA_STANDARD_DDL_PKG;

/
