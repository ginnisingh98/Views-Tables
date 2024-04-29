--------------------------------------------------------
--  DDL for Package Body FA_CHK_BALSEG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CHK_BALSEG_PKG" as
/* $Header: faxbaseb.pls 120.4.12010000.2 2009/07/19 10:42:11 glchen ship $ */

procedure check_balancing_segments(
	book		in varchar2,
	asset_id	in number,
 	success  out nocopy boolean,
	calling_fn	in varchar2,
        p_log_level_rec in fa_api_types.log_level_rec_type)
is

h_structure_num         number;
h_ccid		        number;
n_segs			number;
all_segments		fnd_flex_ext.SegmentArray;
balancing_segnum   	number;
h_ret_val		boolean;
get_segments_success	boolean;
balseg_mismatch_error  	exception;

/*fix for bug no.3794548.changing BalsegvalType type from varchar(15) to varchar(30)*/
TYPE BalsegvalType IS TABLE of VARCHAR2(30)
     INDEX BY BINARY_INTEGER;
h_bal_seg_val	BalSegValType;
no_rows		BINARY_INTEGER:=0;
i		BINARY_INTEGER:=0;
j		BINARY_INTEGER:=0;
H_DEBUG		BOOLEAN :=FALSE;
error_mesg	varchar2(250);

cursor SEL_DIST_CCID(c_book varchar2,c_asset_id number) IS
       SELECT code_combination_id
	 FROM fa_distribution_history FAD
  	WHERE book_type_code=c_book
	  AND asset_id=c_asset_id
	  AND transaction_header_id_out is null;
BEGIN
  success:=FALSE;
  select accounting_flex_structure
  into h_structure_num
  from fa_book_controls
  where book_type_code = book;

  h_ret_val := fnd_flex_apis.get_qualifier_segnum (
		appl_id => 101,
    		key_flex_code => 'GL#',
		structure_number => h_structure_num,
		flex_qual_name => 'GL_BALANCING',
		segment_number => balancing_segnum);

  if (h_ret_val = FALSE)
  then
     null;
  end if;

   open SEL_DIST_CCID(book,asset_id);
   LOOP
  fetch SEL_DIST_CCID into h_ccid;

  IF (SEL_DIST_CCID%NOTFOUND) then  exit;  end if;
    no_rows := no_rows + 1;
    get_segments_success := fnd_flex_ext.get_Segments (
       		 application_short_name => 'SQLGL',
		 key_flex_code => 'GL#',
		 structure_number => h_structure_num,
		 combination_id => h_ccid,
		 n_segments => n_segs,
		 segments => all_segments);
   if (get_segments_success) then
      h_bal_seg_val(no_rows) := all_segments(balancing_segnum);
   end if;

   end loop;
  close SEL_DIST_CCID;

/* Now Processing the PL/SQL Table containing the values for the balancing
   segments
*/
 if no_rows=1
 then
  success:=TRUE;
  return;
 end if;

  FOR i  IN 1..no_rows LOOP
    FOR j IN i+1..no_rows LOOP
      if h_bal_seg_val(i)<>h_bal_seg_val(j)
      then
	   return;
      end if;
    END LOOP;
  END LOOP;

 success:=TRUE;

 EXCEPTION
      when balseg_mismatch_error then
	success:=FALSE;
     when others then
	success :=FALSE;
	error_mesg := fnd_message.get;

/*FA_STANDARD_PKG.RAISE_ERROR (
		CALLED_FN => 'FA_CHK_BALSEG_PKG.check_balancing_segments',
		CALLING_FN => CALLING_FN, p_log_level_rec => p_log_level_rec);
*/
end check_balancing_segments;

END FA_CHK_BALSEG_PKG;

/
