--------------------------------------------------------
--  DDL for Package QPR_WKFL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_WKFL_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPRUWKFLS.pls 120.5 2008/05/28 12:06:13 bhuchand ship $ */

type char_type is table of varchar2(500) index by pls_integer;

procedure approve_deal(
                        item_type in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2);

procedure reject_deal(
                      item_type in varchar2,
                      itemkey in varchar2,
                      actid in number,
                      funcmode in varchar2,
                      resultout out nocopy varchar2);

procedure set_callback_nfn_details(item_type in varchar2,
                                    itemkey in varchar2,
                                    actid in number,
                                    funcmode in varchar2,
                                    resultout out nocopy varchar2);


procedure set_app_status_nfn_details(item_type in varchar2,
                                    itemkey in varchar2,
                                    actid in number,
                                    funcmode in varchar2,
                                    resultout out nocopy varchar2);

procedure show_deal_details(document_id in varchar2,
                            display_type in varchar2,
                            document in out nocopy varchar2,
                            document_type in out nocopy varchar2);

procedure attach_deal_details (
                               document_id   in varchar2,
                               display_type  in varchar2,
                               document      in out nocopy clob,
                               document_type in out nocopy varchar2
                              );

procedure invoke_cb_nfn_process(p_response_id in number,
                                p_usr_list in char_type,
                                p_comments in varchar2,
                                  retcode out nocopy number,
                                  errbuf out nocopy varchar2);

procedure invoke_toapp_nfn_process(p_response_id in number,
                                    p_fwd_to_user in varchar2,
                                    retcode out nocopy number,
                                    errbuf out nocopy varchar2);

procedure invoke_appstat_nfn_process(p_response_id in number,
                                  p_usr_list in char_type,
                                  p_comments in varchar2,
                                  p_status in varchar2,
                                  retcode out nocopy number,
                                  errbuf out nocopy varchar2);

procedure complete_toapp_nfn_process(p_response_id in number,
                                     p_current_user in varchar2,
                                     p_status in varchar2,
                                     retcode out nocopy number,
                                     errbuf out nocopy varchar2);
procedure cancel_toapp_nfn_process(p_response_id in number,
                                   p_usr_list in char_type,
                                     retcode out nocopy number,
                                     errbuf out nocopy varchar2);
END;


/
