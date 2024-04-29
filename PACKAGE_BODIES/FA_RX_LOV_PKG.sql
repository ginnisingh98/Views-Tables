--------------------------------------------------------
--  DDL for Package Body FA_RX_LOV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RX_LOV_PKG" as
/* $Header: faxrxlvb.pls 120.4.12010000.2 2009/07/19 13:12:59 glchen ship $ */

  procedure unparse_lov_select (
	X_lovid		number,
	X_params	fa_rx_lov_pkg.param_array,
	X_param_types	fa_rx_lov_pkg.param_array,
	X_num_params	number,
	X_select out nocopy varchar2,
	X_missing_param out nocopy number) is

  h_sqlstmt	varchar2(32000);
  ii		integer;

  h_date_str	varchar2(25);
  h_date_format varchar2(25);

  begin

    select select_statement
    into h_sqlstmt
    from fa_rx_lov
    where lov_id = X_lovid;

    ii := X_num_params;

    loop
      if X_params(ii) is not null then

	if X_param_types(ii) = 'VARCHAR2' then

	  h_sqlstmt :=  replace(h_sqlstmt, ':P'||to_char(ii),
			''''||X_params(ii)||'''');

	else if X_param_types(ii) = 'NUMBER' then
	  h_sqlstmt :=  replace(h_sqlstmt, ':P'||to_char(ii),X_params(ii));

	else  -- DATE

	  h_date_str := X_params(ii);
	  h_date_format := 'DD/MM/YYYY';

	  h_sqlstmt := replace(h_sqlstmt, ':P'||to_char(ii),
		     'to_date('||''''||h_date_str||''''||','||
		     ''''||h_date_format||''''||')');

	end if;
	end if;

      else	-- param is null; check if it's needed.
		-- If so, then exit right away, indicating missing param #.

	if instr(h_sqlstmt,':P'||to_char(ii)) <> 0 then
	  X_missing_param := ii;
	  return;
	end if;

      end if;
      ii := ii - 1;
      exit when ii < 1;
    end loop;

    X_missing_param := 0;
    X_select := h_sqlstmt;

  end unparse_lov_select;
end FA_RX_LOV_PKG;

/
