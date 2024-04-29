--------------------------------------------------------
--  DDL for Package OKC_ARTWF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ARTWF_PVT" AUTHID CURRENT_USER as
/* $Header: OKCARTWFS.pls 120.4 2006/07/06 23:45:14 muteshev noship $ */

procedure start_wf_after_import( p_req_id in number,
                                 p_batch_number in varchar2,
                                 p_org_id in varchar2);

-- for testing - don't use in apps code
procedure test(   p_org_id in number,
            p_article_version_id in number);

procedure check_status( p_org_id in number,
                p_article_version_id in number,
                x_result out nocopy varchar2,
                x_msg_count out nocopy number,
                x_msg_data out nocopy varchar2);
procedure clean;

-- for testing - don't use in apps code
procedure print_tab;
-- for testing - don't use in apps code
procedure print_err;

function get_write_ptr return binary_integer;
procedure get_write_ptr(x_write_ptr out nocopy binary_integer);
function get_error_ptr return binary_integer;
procedure get_error_ptr(x_error_ptr out nocopy binary_integer);

procedure get_tab(   p_ptr in                         binary_integer,
                   x_article_id out nocopy          okc_articles_all.article_id%type,
                   x_article_version_id out nocopy  okc_article_versions.article_version_id%type,
                   x_article_status out nocopy      okc_article_versions.article_status%type,
                   x_adoption_type out nocopy       okc_article_versions.adoption_type%type,
                   x_global_yn out nocopy           okc_article_versions.global_yn%type,
                   x_key out nocopy                 varchar2);

procedure get_err(   p_ptr in                         binary_integer,
                   x_article_id out nocopy          okc_articles_all.article_id%type,
                   x_article_version_id out nocopy  okc_article_versions.article_version_id%type,
                   x_article_status out nocopy      okc_article_versions.article_status%type,
                   x_adoption_type out nocopy       okc_article_versions.adoption_type%type,
                   x_global_yn out nocopy           okc_article_versions.global_yn%type,
                   x_key out nocopy                 varchar2);

procedure set_notification(   itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              funcmode in varchar2,
                              resultout out nocopy varchar2);

procedure set_approver( itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2);

procedure set_notified_list(  itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              funcmode in varchar2,
                              resultout out nocopy varchar2);

procedure set_notified( itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2);

function get_pending_meaning return varchar2;
function get_adopted_meaning return varchar2;

procedure start_wf_processes(result out nocopy varchar2);
procedure start_wf_process(   org_id in number,
                              article_version_id in number,
                              result out nocopy varchar2);

procedure selector(  itemtype in varchar2,
                     itemkey in varchar2,
                     actid in number,
                     command in varchar2,
                     resultout in out nocopy varchar2);

procedure select_process(  itemtype in varchar2,
                           itemkey in varchar2,
                           actid in number,
                           command in varchar2,
                           resultout in out nocopy varchar2);

procedure set_approved( itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2);

procedure set_rejected( itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2);

procedure decrement_counter(  itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              funcmode in varchar2,
                              resultout out nocopy varchar2);

function validate_article_version(  p_search_flow in varchar2,
                                    p_article_version_id in number,
                                    p_article_status in varchar2,
                                    p_org_id in number)
return varchar2;

function validate_article_version(  p_article_version_id in number,
                                    p_article_status in varchar2,
                                    p_org_id in number)
return varchar2;

function pre_submit_validation(  p_org_id in number)  return varchar2;
function pre_submit_validation(  p_org_id in number, p_intent in varchar2)  return varchar2;

procedure transfer(  itemtype    in varchar2,
                     itemkey     in varchar2,
                    actid      in number,
                    funcmode     in varchar2,
                    resultout   out nocopy varchar2);

PROCEDURE orgname(   document_id in varchar2,
                     display_type in varchar2,
                     document in out NOCOPY varchar2,
                     document_type in out NOCOPY varchar2);

PROCEDURE subject(   document_id in varchar2,
                     display_type in varchar2,
                     document in out NOCOPY varchar2,
                     document_type in out NOCOPY varchar2);

function get_intent_pub( art_ver_id in number) return varchar2;

procedure callback(  document_id in varchar2,
                     display_type in varchar2,
                     document in out NOCOPY varchar2,
                     document_type in out NOCOPY varchar2);

-- bug 5261848 - cr3 start
   function get_g_article_text(p_org_id number, p_article_version_id number)
      return okc_article_versions.article_text%type;
   function get_g_localized_yn(p_org_id number, p_article_version_id number)
      return varchar2;
   function get_g_translated_yn(p_article_version_id number)
      return okc_article_versions.translated_yn%type;
   function get_g_article_version_id(p_org_id number, p_article_version_id number)
      return okc_article_versions.article_version_id%type;
-- bug 5261848 - cr3 end

end;

 

/
