--------------------------------------------------------
--  DDL for Package Body FAFLEX_PKG_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FAFLEX_PKG_WF" as
/* $Header: faflxwfb.pls 120.3.12010000.2 2009/07/19 13:53:01 glchen ship $*/
-------------------------------------------------------------------
-- This function replaces fafbgcc in FA_FLEX_PKG.fafb_call_flex

FUNCTION START_PROCESS
            (X_flex_account_type  in varchar2,
             X_book_type_code     in varchar2,
             X_flex_num           in number,
             X_dist_ccid          in number,
             X_acct_segval        in varchar2,
             X_default_ccid       in number,
             X_account_ccid       in number,
             X_distribution_id    in number default null,
             X_Workflowprocess    in varchar2 default null,
             X_Validation_Date    in date default sysdate,
             X_return_ccid in out nocopy number
            , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return boolean is

-- moved to package spec
-- ItemType        varchar2(30) :='FAFLEXWF';
-- ItemKey         varchar2(30);

   h_concat_segs   varchar2(2000);
   h_concat_ids    varchar2(2000);
   h_concat_descrs varchar2(2000);
   h_errmsg        varchar2(2000);
   h_encoded_msg   varchar2(2000);
   result          boolean;
   h_return_ccid   number;
   char_date       varchar2(27);

   h_appl_short_name varchar2(30);
   h_message_name    varchar2(30);
   h_num             number;
   h_string          varchar2(100);

   h_new_ccid        boolean;

   l_nsegments       NUMBER;
   l_val_date        DATE;

BEGIN  <<GEN_CCID>>

   itemkey := FND_FLEX_WORKFLOW.INITIALIZE
                  ('SQLGL',
                   'GL#',
                   X_flex_num,
                   'FAFLEXWF'
                  );

   wf_engine.SetItemAttrNumber
                  (itemtype => itemtype,
                   itemkey  => itemkey,
                   aname    => 'CHART_OF_ACCOUNTS_ID',
                   avalue   => X_flex_num);

   wf_engine.SetItemAttrText
                  (itemtype => itemtype,
                   itemkey  => itemkey,
                   aname    => 'BOOK_TYPE_CODE',
                   avalue   => X_book_type_code);

   wf_engine.SetItemAttrNumber
                  (itemtype => itemtype,
                   itemkey  => itemkey,
                   aname    => 'DEFAULT_CCID',
                   avalue   =>  X_default_ccid);

   BEGIN

      wf_engine.SetItemAttrDate
                  (itemtype => itemtype,
                   itemkey  => itemkey,
                   aname    => 'VALIDATION_DATE',
                   avalue   => X_validation_date);

   EXCEPTION
      when others then
           if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
              wf_engine.AddItemAttr(itemtype,itemkey,'VALIDATION_DATE');
              wf_engine.SetItemAttrDate
                     (itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'VALIDATION_DATE',
                      avalue   => X_validation_date);
           else
              raise;
           end if;
   END;



   -- Initialize the workflow item attributes

   wf_engine.SetItemAttrText
                     (itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'ACCOUNT_TYPE',
                      avalue   => X_flex_account_type);

   wf_engine.SetItemAttrNumber
                     (itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'DISTRIBUTION_CCID',
                      avalue   => X_dist_ccid );

   wf_engine.SetItemAttrText
                     (itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'ACCT_SEG_VAL',
                      avalue   => X_acct_segval);

   wf_engine.SetItemAttrNumber
                     (itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'ACCOUNT_CCID',
                      avalue   => X_account_ccid);

   wf_engine.SetItemAttrNumber
                     (itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'DISTRIBUTION_ID',
                      avalue   =>  X_distribution_id);

   -- BUG# 1833652
   --  passing the insert_if_new and new_combination parameters
   --  so that combinations will be dynamically inserted
   --     bridgway 06/20/01

   result := FND_FLEX_WORKFLOW.GENERATE
                  ('FAFLEXWF',
                   itemkey,
                   TRUE,
                   X_return_ccid,
                   h_concat_segs,
                   h_concat_ids,
                   h_concat_descrs,
                   h_errmsg,
                   h_new_ccid);

   FA_GCCID_PKG.global_concat_segs := h_concat_segs;

   if (not result) then

      -- BUG# 1504839
      --  enhancing the messaging here for fagda and for form level
      --  transactions.  Now dump the concatonated segs and the FND
      --  error returned in encoded format from Workflow
      --    bridgway 04/12/01

      FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN => 'FAFLEX_PKG_WF.START_PROCESS',
                 NAME       => 'FA_FLEXBUILDER_FAIL_CCID',
                 TOKEN1     => 'ACCOUNT_TYPE',
                 VALUE1     => X_flex_account_type,
                 TOKEN2     => 'BOOK_TYPE_CODE',
                 VALUE2     => X_book_type_code,
                 TOKEN3     => 'DIST_ID',
                 VALUE3     => X_distribution_id,
                 TOKEN4     => 'CONCAT_SEGS',
                 VALUE4     => h_concat_segs
                , p_log_level_rec => p_log_level_rec);

      fnd_message.set_encoded(h_errmsg);
      fnd_msg_pub.add;  -- end 1504839

      return FALSE;
   end if;

   -- BUG# 1818599
   --  changing date format as aol only accept the following
   --  bridgway  06/07/01
   -- BUG# 7529681
   --  setting char_date to sysdate only if validation date is null

   if (X_return_ccid = -1) then
      select to_char(nvl(X_Validation_Date,sysdate),'YYYY/MM/DD HH24:MI:SS')
        into char_date
        from dual;

      h_return_ccid := FND_FLEX_EXT.get_ccid
                         ('SQLGL',
                          'GL#',
                          X_flex_num,
                          char_date,
                          h_concat_segs);
      if (h_return_ccid = 0 ) then

         FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN =>'FAFLEX_PKG_WF.START_PROCESS',
                 NAME       =>'FA_FLEXBUILDER_FAIL_CCID',
                 TOKEN1     => 'ACCOUNT_TYPE',
                 VALUE1     => X_flex_account_type,
                 TOKEN2     => 'BOOK_TYPE_CODE',
                 VALUE2     => X_book_type_code,
                 TOKEN3     => 'DIST_ID',
                 VALUE3     => X_distribution_id,
                 TOKEN4     => 'CONCAT_SEGS',
                 VALUE4     => h_concat_segs
                , p_log_level_rec => p_log_level_rec);
         fnd_message.set_encoded(h_errmsg);
         fnd_msg_pub.add;  -- end 1504839

         return FALSE;
      else

         X_return_ccid := h_return_ccid;
      end if;

   end if;
   RETURN result;

exception
   when others then
        wf_core.context('FA_FLEX_PKG','StartProcess',X_book_type_code,X_dist_ccid,
                        X_default_ccid,X_Workflowprocess);
        raise;
end;


PROCEDURE CORP_OR_TAX(itemtype  in     varchar2,
                      itemkey   in     varchar2,
                      actid     in     number,
                      funcmode  in     varchar2,
                      result       out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   h_book_type_code   varchar2(30);
   h_book_class        varchar2(30);

BEGIN <<CORP_OR_TAX>>

   IF (funcmode = 'RUN') THEN
      h_book_type_code := wf_engine.GetItemAttrText(itemtype,itemkey,'BOOK_TYPE_CODE');
      SELECT book_class
        INTO h_book_class
        FROM fa_book_controls
       WHERE book_type_code = h_book_type_code;

      result := 'COMPLETE:' || h_book_class ;
      RETURN;
   ELSIF (funcmode = 'CANCEL') THEN
      result :=  'COMPLETE:';
      RETURN;
   ELSE
      result := '';
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        wf_core.context('FA_FLEX_PKG','CORP_OR_TAX',
                        itemtype,itemkey,TO_CHAR(actid),funcmode);
     RAISE;
END;

PROCEDURE CHECK_ACCT(itemtype  in     varchar2,
                     itemkey   in     varchar2,
                     actid     in     number,
                     funcmode  in     varchar2,
                     result       out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   h_account_type   VARCHAR2(30);

BEGIN <<CHECK_ACCT>>
   IF (funcmode = 'RUN') THEN
      h_account_type := wf_engine.GetItemAttrText(itemtype,itemkey,'ACCOUNT_TYPE');
      result := 'COMPLETE:' || h_account_type;
      RETURN;
   ELSIF (funcmode = 'CANCEL') THEN
      result :=  'COMPLETE:';
      RETURN;
   ELSE
      result := '';
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        wf_core.context('FA_FLEX_PKG','CHECK_ACCT',
                        itemtype,itemkey,TO_CHAR(actid),funcmode);
     RAISE;
END;  /* CHECK_ACCT */

PROCEDURE CHECK_GROUP(itemtype  in     varchar2,
                      itemkey   in     varchar2,
                      actid     in     number,
                      funcmode  in     varchar2,
                      result       out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

  h_account_type   VARCHAR2(30);

BEGIN <<CHECK_GROUP>>
   IF (funcmode = 'RUN') THEN
      h_account_type := wf_engine.GetItemAttrText(itemtype,itemkey,'ACCOUNT_TYPE');
      IF (h_account_type in ('ASSET_COST','ASSET_CLEARING',
                             'CIP_CLEARING','CIP_COST',
                             'DEPRN_RSV','REV_AMORT','REV_RSV',
                             'BONUS_DEPRN_RSV','BONUS_DEPRN_EXP',
							 'IMPAIR_RSV', 'IMPAIR_EXP', -- Bug:6135190
                             'CAPITAL_ADJ','GENERAL_FUND' -- Bug 6666666
                             )) THEN
         result := 'COMPLETE:' || 'CATE_LEVEL_ACCOUNT';
         RETURN;
      ELSIF (h_account_type in ('DEPRN_EXP')) THEN
         result := 'COMPLETE:' || 'ASSET_LEVEL_ACCOUNT';
         RETURN;
      ELSE      /* All Remaining accounts fall under book level */
         result := 'COMPLETE:' || 'BOOK_LEVEL_ACCOUNT';
         RETURN;
      END IF;

   ELSIF (funcmode = 'CANCEL') THEN
      result :=  'COMPLETE:';
      RETURN;
   ELSE
      result := '';
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        wf_core.context('FA_FLEX_PKG','CHECK_GROUP',
                        itemtype,itemkey,TO_CHAR(actid),funcmode);
   RAISE;
END;

PROCEDURE GET_BOOK_TYPE(itemtype  in     varchar2,
                        itemkey   in     varchar2,
                        actid     in     number,
                        funcmode  in     varchar2,
                        result       out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   h_book_type   VARCHAR2(30);

BEGIN <<GET_BOOK_TYPE>>
   IF (funcmode = 'RUN') THEN
      h_book_type := wf_engine.GetItemAttrText(itemtype,itemkey,'BOOK_TYPE_CODE');
      result := 'COMPLETE:' || h_book_type;
      RETURN;
   ELSIF (funcmode = 'CANCEL') THEN
      result :=  'COMPLETE:';
      RETURN;
   ELSE
      result := '';
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        wf_core.context('FA_FLEX_PKG','GET_BOOK_TYPE', itemtype,itemkey,TO_CHAR(actid),funcmode);
        RAISE;
END;

END FAFLEX_PKG_WF;

/
