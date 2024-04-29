--------------------------------------------------------
--  DDL for Package Body FA_FADI_SHARED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FADI_SHARED_PKG" as
/* $Header: farfadib.pls 120.2.12010000.2 2009/07/19 10:59:17 glchen ship $ */


PROCEDURE GET_ACCT_SEGMENT_NUMBERS (
   BOOK				IN	VARCHAR2,
   BALANCING_SEGNUM	 OUT NOCOPY NUMBER,
   ACCOUNT_SEGNUM	 OUT NOCOPY NUMBER,
   CC_SEGNUM		 OUT NOCOPY NUMBER,
   CALLING_FN			IN	VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  IS

  structure_num		number;
  get_qualifier_segnum_failed   exception;
  gqsval    boolean;

BEGIN
  select accounting_flex_structure
  into structure_num
  from fa_book_controls
  where book_type_code = BOOK;

  gqsval :=  fnd_flex_apis.get_qualifier_segnum (
	appl_id => 101,
	key_flex_code => 'GL#',
	structure_number => structure_num,
	flex_qual_name => 'GL_BALANCING',
	segment_number => balancing_segnum);
  if (gqsval = FALSE) then raise get_qualifier_segnum_failed;  end if;

  gqsval := fnd_flex_apis.get_qualifier_segnum (
	appl_id => 101,
	key_flex_code => 'GL#',
	structure_number => structure_num,
	flex_qual_name => 'GL_ACCOUNT',
	segment_number => account_segnum);
  if (gqsval = FALSE) then raise get_qualifier_segnum_failed;  end if;

  gqsval :=  fnd_flex_apis.get_qualifier_segnum (
	appl_id => 101,
	key_flex_code => 'GL#',
	structure_number => structure_num,
	flex_qual_name => 'FA_COST_CTR',
	segment_number => cc_segnum);
  if (gqsval = FALSE) then raise get_qualifier_segnum_failed;  end if;


EXCEPTION
  when get_qualifier_segnum_failed then
    null;
  when others then
    FA_STANDARD_PKG.RAISE_ERROR
		(CALLED_FN => 'FA_FADI_SHARED_PKG.GET_ACCT_SEGMENT_NUMBERS',
		 CALLING_FN => CALLING_FN, p_log_level_rec => p_log_level_rec);

END GET_ACCT_SEGMENT_NUMBERS;

END FA_FADI_SHARED_PKG;

/
