--------------------------------------------------------
--  DDL for Package BEN_CWB_MASS_NOTIFN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_MASS_NOTIFN_PKG" AUTHID CURRENT_USER as
/* $Header: bencwbnf.pkh 120.2 2006/03/22 09:44:56 steotia noship $ */

-- --------------------------------------------------------------------------
-- |---------------------< mass_ntf_cleanup >--------------------------------|
-- --------------------------------------------------------------------------
--
procedure mass_ntf_cleanup
       (itemtype                         in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                   out nocopy varchar2);

-- --------------------------------------------------------------------------
-- |---------------------< get_item_attribute >--------------------------------|
-- --------------------------------------------------------------------------
--
function get_item_attribute
       (itemtype                         in  varchar2
      , itemkey                          in  varchar2
      , aname                            in  varchar2)
      return varchar2;

-- --------------------------------------------------------------------------
-- |----------------------< inc_home_link >---------------------------------|
-- --------------------------------------------------------------------------
--
 procedure inc_home_link
       (itemtype                         in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                   out nocopy varchar2);

-- --------------------------------------------------------------------------
-- |------------------------------< notify >--------------------------------|
-- --------------------------------------------------------------------------
-- Description
--	This procedure contains calls for sending mass notifications via
-- Oracle Workflow. This will be called by a concurent process.
--
procedure notify( errbuf                     out  nocopy  varchar2
                 ,retcode                    out  nocopy  number
	         ,p_pl_id                    in number
		 ,p_lf_evt_ocrd_dt           in varchar2
		 ,p_messg_txt_title          in varchar2 default null
		 ,p_messg_txt_body           in varchar2 default null
		 ,p_target_pop               in varchar2 default null
		 ,p_req_acc_lvl              in varchar2 default null
		 ,p_person_selection_rule_id in number   default null
		 ,p_include_cwb_link         in varchar2 default 'N'
		 ,p_resend_if_prev_sent      in varchar2 default 'N'
		 ,p_mail_to_user             in varchar2 default null
		 ,p_withhold_notifn          in varchar2 default 'N'
                 );

end BEN_CWB_MASS_NOTIFN_PKG;

 

/
