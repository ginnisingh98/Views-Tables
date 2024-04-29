--------------------------------------------------------
--  DDL for Package Body FA_MASSADD_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSADD_DIST_PKG" as
/* $Header: faxmadtb.pls 120.3.12010000.2 2009/07/19 10:02:54 glchen ship $ */

PROCEDURE DIST_SET (X_name         varchar2,
		    X_total_units  number,
		    X_mass_addition_id  number,
		    X_success  out nocopy boolean, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  h_unit_percentage        number;
  h_dist_units             number;
  h_ccid                   number;
  h_location_id            number;
  h_employee_id            number;
  h_massadd_dist_id        number;

  cursor dist_defaults is
  select dd.unit_percentage, dd.deprn_expense_ccid,
	dd.location_id, dd.employee_id
    from fa_distribution_sets ds, fa_distribution_defaults dd
    where ds.name = X_name
    and ds.dist_set_id = dd.dist_set_id;

  begin
    X_success := FALSE;

    delete from fa_massadd_distributions
    where mass_addition_id = X_mass_addition_id;

    open dist_defaults;
    loop
      fetch dist_defaults into
	h_unit_percentage, h_ccid, h_location_id, h_employee_id;

      if (dist_defaults%NOTFOUND) then exit;  end if;

      h_dist_units := X_total_units * h_unit_percentage / 100;

      select fa_massadd_distributions_s.nextval
 	into h_massadd_dist_id from dual;

      insert into fa_massadd_distributions (
	massadd_dist_id, mass_addition_id, units,
	deprn_expense_ccid, location_id, employee_id) values (
	h_massadd_dist_id, X_mass_addition_id, h_dist_units,
	h_ccid, h_location_id, h_employee_id);
    end loop;
--    commit;
  X_success := TRUE;

  exception when others then
	app_exception.raise_exception;

  end dist_set;


  PROCEDURE SAVEPT IS
  begin
    savepoint distset;
  end savept;

  PROCEDURE ROLLBK IS
  begin

    rollback to savepoint distset;

  end rollbk;

END FA_MASSADD_DIST_PKG;

/
