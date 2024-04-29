--------------------------------------------------------
--  DDL for Package Body FA_ROUND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ROUND_PKG" as
/* $Header: faxrndb.pls 120.3.12010000.2 2009/07/19 13:09:59 glchen ship $ */

  PROCEDURE fa_round(
	X_amount    in out nocopy number,
	X_book      varchar2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

    h_precision         number;

  BEGIN

    select curr.precision
    into h_precision
    from fnd_currencies curr, gl_sets_of_books sob,
	 fa_book_controls bc
    where curr.currency_code = sob.currency_code
    and  sob.set_of_books_id = bc.set_of_books_id
    and bc.book_type_code = X_book;

    select round(X_amount,h_precision)
    into X_amount
    from dual;

  END fa_round;
--
--
  PROCEDURE fa_ceil(
	X_amount    in out nocopy number,
	X_book      varchar2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS
    h_precision    number;

  BEGIN

    select curr.precision
    into h_precision
    from fnd_currencies curr, gl_sets_of_books sob,
	 fa_book_controls bc
    where curr.currency_code = sob.currency_code
    and  sob.set_of_books_id = bc.set_of_books_id
    and bc.book_type_code = X_book;

    select  ceil(X_amount * power(10,h_precision)) / power(10,h_precision)
    into X_amount
    from dual;

  END fa_Ceil;
--
--
  PROCEDURE fa_floor(
	X_amount    in out nocopy number,
	X_book      varchar2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS
    h_precision    number;
    h_int          number;

  BEGIN

    select curr.precision
    into h_precision
    from fnd_currencies curr, gl_sets_of_books sob,
	 fa_book_controls bc
    where curr.currency_code = sob.currency_code
    and  sob.set_of_books_id = bc.set_of_books_id
    and bc.book_type_code = X_book;

    select  trunc(X_amount * power(10,h_precision)) / power(10,h_precision)
    into X_amount
    from dual;

  END fa_floor;

END FA_ROUND_PKG;

/
