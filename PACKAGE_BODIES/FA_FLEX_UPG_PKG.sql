--------------------------------------------------------
--  DDL for Package Body FA_FLEX_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FLEX_UPG_PKG" AS
/* $Header: faflxupb.pls 120.4.12010000.2 2009/07/19 14:02:44 glchen ship $ */

PROCEDURE CALL_UPGRADED_FLEX(itemtype  in varchar2,
	    	   itemkey	in varchar2,
		   actid	in number,
		   funcmode     in varchar2,
		   result       out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
IS
h_ret_ccid   number;
h_ret_val    boolean;
h_cat_id     number;
h_comment    varchar2(30);
h_debug_flag varchar2(3);
h_flex_id    number :=0;
h_flex_data  varchar2(30):='                             ';
-- fix for 1287708
h_flex_seg   varchar2(2000):=NULL;
h_error_msg  varchar2(80):=NULL;
-- end fix for 1287708
h_error_msg2 varchar2(30):='                             ';
c_package_name       varchar2(30);
h_func       varchar2(40);
h_stmt       varchar2(300);
h_flex_set	     number := -1;
h_dinsert            varchar2(1) := 'N';
h_partial_ok	     varchar2(1) := 'N';
h_flex_num   number;
h_acct_ccid_c varchar2(10);
h_acct_ccid number;
h_def_ccid_c varchar2(10);
h_def_ccid number;
h_acct_seg  varchar2(30);
h_dist_ccid_c varchar2(10);
h_dist_ccid  number;
h_book_type_code  varchar2(30);
h_book_type_code_out  varchar2(30);
h_account_type    varchar2(30);

begin
if (funcmode = 'RUN') THEN

h_book_type_code := wf_engine.GetItemAttrText(itemtype,itemkey,'BOOK_TYPE_CODE');
h_book_type_code_out := replace(h_book_type_code,' ','_');
h_book_type_code_out := replace(h_book_type_code_out,'(','_');
h_book_type_code_out := replace(h_book_type_code_out,')','_');
h_book_type_code_out := replace(h_book_type_code_out,'.','_');
h_book_type_code_out := replace(h_book_type_code_out,'-','_');
h_account_type := wf_engine.GetItemAttrText(itemtype,itemkey,'ACCOUNT_TYPE');
 h_func := h_book_type_code_out || '_' || h_account_type || '.build';
h_flex_num := wf_engine.GetItemAttrNumber(itemtype,itemkey,'CHART_OF_ACCOUNTS_ID');

h_dist_ccid := wf_engine.GetItemAttrNumber(itemtype,itemkey,'DISTRIBUTION_CCID');
h_acct_ccid := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ACCOUNT_CCID');

h_def_ccid := wf_engine.GetItemAttrNumber(itemtype,itemkey,'DEFAULT_CCID');

h_acct_seg := wf_engine.GetItemAttrText(itemtype,itemkey,'ACCT_SEG_VAL');

 IF (h_account_type in ('ASSET_COST','ASSET_CLEARING',
			   'CIP_CLEARING','CIP_COST',
			    'DEPRN_RSV','REV_AMORT','REV_RSV')
     )
 THEN    /*  Category level Accounts  */
   h_ret_val := CATE_LEVEL_ACCT (X_flex_num=>h_flex_num,
		    X_func=>h_func,
		    X_acct_ccid=>to_char(h_acct_ccid),
		    X_acct_seg=>h_acct_seg,
		    X_def_ccid=>to_char(h_def_ccid),
		    X_dist_ccid=>to_char(h_dist_ccid),
		    X_flex_seg=>h_flex_seg,
		    X_error_msg=>h_error_msg,
                    p_log_level_rec=>p_log_level_rec);
 ELSIF (h_account_type = 'DEPRN_EXP')
 THEN    /* Asset Level  */
  h_ret_val := ASSET_LEVEL_ACCT (X_flex_num=>h_flex_num,
		    X_func=>h_func,
		    X_acct_seg=>h_acct_seg,
		    X_dist_ccid=>to_char(h_dist_ccid),
		    X_flex_seg=>h_flex_seg,
		    X_error_msg=>h_error_msg,
                    p_log_level_rec=>p_log_level_rec);
 ELSE   /* Book Level  */
  h_ret_val := BOOK_LEVEL_ACCT (X_flex_num=>h_flex_num,
		    X_func=>h_func,
		    X_acct_seg=>h_acct_seg,
		    X_def_ccid=>to_char(h_def_ccid),
		    X_dist_ccid=>to_char(h_dist_ccid),
		    X_flex_seg=>h_flex_seg,
		    X_error_msg=>h_error_msg,
                    p_log_level_rec=>p_log_level_rec);
 END IF;
 if (h_ret_val)
 then
    FND_FLEX_WORKFLOW.LOAD_CONCATENATED_SEGMENTS('FAFLEXWF',
						 itemkey,
						 h_flex_seg);
   result := 'COMPLETE:SUCCESS';
  if (p_log_level_rec.statement_level)
  then
      FA_DEBUG_PKG.ADD(
              fname => 'FA_FLEX_UPG_PKG.CALL_UPGRADED_FLEX',
	      element => 'After Concanetated segments ',
	       value => 1, p_log_level_rec => p_log_level_rec);
  end if;
   RETURN;
 else
   wf_engine.SetItemAttrText(itemtype=>'FALFEXWF',
			      itemkey=>itemkey,
			      aname=>'ERROR_MESSAGE',
		              avalue=>h_error_msg);
   result := 'COMPLETE:FAILURE';
   RETURN;
 end if;
ELSIF (funcmode = 'CANCEL') THEN
  result := 'COMPLETE:';
  RETURN;
ELSE
  result := '';
  RETURN;
END IF;

 exception
 when others then
 if (p_log_level_rec.statement_level)
 then
    FA_DEBUG_PKG.ADD (
                     fname => 'FA_FLEX_UPG_PKG',
                   element=>'Errored',
                    value=>1, p_log_level_rec => p_log_level_rec);
 end if;
end;  /* CALL_FLEX_FUNCTION */

FUNCTION BOOK_LEVEL_ACCT (X_flex_num in number,
		    X_func      in varchar2,
		    X_acct_seg  in varchar2,
		    X_def_ccid  in  varchar2,
		    X_dist_ccid	    in  varchar2,
		    X_flex_seg   in out nocopy varchar2,
		    X_error_msg  in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN
IS
h_cursor_executed    integer;
cursor_handle	     integer;
h_val    number :=1;
h_flex_seg   varchar2(2000):=NULL;
h_error_msg  varchar2(80):=NULL;

BEGIN<<BOOK_LEVEL_ACCT>>

  cursor_handle := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(cursor_handle,'BEGIN  IF ( ' || X_func ||
		       '(:flex_num,
                        :acct_seg,
			:def_ccid,
                        :dist_ccid,
			:flex_seg,
                        :error_msg)) THEN :x1:=1;ELSE :x1:=0;END IF; END;',DBMS_SQL.V7);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':x1',h_val);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':flex_num',X_flex_num);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':acct_seg',X_acct_seg);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':def_ccid',X_def_ccid);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':dist_ccid',X_dist_ccid);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':flex_seg',h_flex_seg,2000);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':error_msg',h_error_msg,80);
  h_cursor_executed := DBMS_SQL.EXECUTE (cursor_handle);

  DBMS_SQL.VARIABLE_VALUE(cursor_handle,':x1',h_val);
  DBMS_SQL.VARIABLE_VALUE(cursor_handle,':flex_seg',h_flex_seg);
  DBMS_SQL.VARIABLE_VALUE(cursor_handle,':error_msg',h_error_msg);
   X_flex_seg := h_flex_seg;
   X_error_msg := h_error_msg;
  DBMS_SQL.CLOSE_CURSOR(cursor_handle);
  IF (h_val=1)
  THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;
 exception
 when others then
  DBMS_SQL.CLOSE_CURSOR(cursor_handle);
END ;  /* BOOK LEVEL ACCT */

FUNCTION CATE_LEVEL_ACCT (X_flex_num   in number,
		    X_func      in varchar2,
		    X_acct_ccid        in varchar2,
		    X_acct_seg  in varchar2,
		    X_def_ccid     in  varchar2,
		    X_dist_ccid	       in  varchar2,
		    X_flex_seg         in out nocopy varchar2,
		    X_error_msg        in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN
IS
h_cursor_executed    integer;
cursor_handle	     integer;
h_val    number:=1;
h_flex_seg   varchar2(2000):=NULL;
h_error_msg  varchar2(80):=NULL;

BEGIN<<CATE_LEVEL_ACCT>>

  cursor_handle := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(cursor_handle,'BEGIN  IF (' || X_func ||
		       '(:flex_num,
			:acct_ccid,
                        :acct_seg,
			:def_ccid,
                        :dist_ccid,
			:flex_seg,
                        :error_msg)) THEN :x1:=1;ELSE :x1:=0;END IF; END;',DBMS_SQL.V7);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':x1',h_val);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':flex_num',X_flex_num);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':acct_ccid',X_acct_ccid);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':acct_seg',X_acct_seg);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':def_ccid',X_def_ccid);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':dist_ccid',X_dist_ccid);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':flex_seg',h_flex_seg,2000);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':error_msg',h_error_msg,80);
  h_cursor_executed := DBMS_SQL.EXECUTE (cursor_handle);

  DBMS_SQL.VARIABLE_VALUE(cursor_handle,':x1',h_val);
  DBMS_SQL.VARIABLE_VALUE(cursor_handle,':flex_seg',h_flex_seg);
  DBMS_SQL.VARIABLE_VALUE(cursor_handle,':error_msg',h_error_msg);
  X_flex_seg := h_flex_seg;
  X_error_msg := h_error_msg;
  DBMS_SQL.CLOSE_CURSOR(cursor_handle);
  IF (h_val = 1)
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
 exception
 when others then
  DBMS_SQL.CLOSE_CURSOR(cursor_handle);
END ;  /* CATE LEVEL ACCT */

FUNCTION ASSET_LEVEL_ACCT (X_flex_num   in number,
		    X_func      in varchar2,
		    X_acct_seg  in varchar2,
		    X_dist_ccid	       in  varchar2,
		    X_flex_seg         in out nocopy varchar2,
		    X_error_msg        in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN
IS
h_cursor_executed    integer;
cursor_handle	     integer;
h_val    number:=1;
h_flex_seg   varchar2(2000):=NULL;
h_error_msg  varchar2(80):=NULL;

BEGIN<<ASSET_LEVEL_ACCT>>

  cursor_handle := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(cursor_handle,'BEGIN  IF (' || X_func ||
		       '(:flex_num,
                        :acct_seg,
                        :dist_ccid,
			:flex_seg,
                        :error_msg)) THEN :x1:=1;ELSE :x1:=0;END IF; END;',DBMS_SQL.V7);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':x1',h_val);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':flex_num',X_flex_num);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':acct_seg',X_acct_seg);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':dist_ccid',X_dist_ccid);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':flex_seg',h_flex_seg,2000);
  DBMS_SQL.BIND_VARIABLE(cursor_handle,':error_msg',h_error_msg,80);
  h_cursor_executed := DBMS_SQL.EXECUTE (cursor_handle);

  DBMS_SQL.VARIABLE_VALUE(cursor_handle,':x1',h_val);
  DBMS_SQL.VARIABLE_VALUE(cursor_handle,':flex_seg',h_flex_seg);
  DBMS_SQL.VARIABLE_VALUE(cursor_handle,':error_msg',h_error_msg);
  X_flex_seg := h_flex_seg;
  X_error_msg := h_error_msg;
  DBMS_SQL.CLOSE_CURSOR(cursor_handle);
  IF (h_val = 1)
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
 exception
 when others then
  DBMS_SQL.CLOSE_CURSOR(cursor_handle);
END ;  /* ASSET LEVEL ACCT */

END FA_FLEX_UPG_PKG;

/
