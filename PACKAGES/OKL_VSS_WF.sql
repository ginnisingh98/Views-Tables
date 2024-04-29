--------------------------------------------------------
--  DDL for Package OKL_VSS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VSS_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRVSWS.pls 115.5 2004/03/23 22:54:32 gkadarka noship $ */

---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_VSS_WF';

procedure getCountersMessage (itemtype in varchar2,
                                      itemkey in varchar2,
                                      actid in number,
                                      funcmode in varchar2,
                                      resultout out nocopy varchar2 );

procedure getCountersDocument (document_id in varchar2,
                                      display_type in varchar2,
                                      document in out nocopy clob,
                                      document_type in out nocopy varchar2 );

procedure update_counter_fnc (itemtype in varchar2,
                                    itemkey in varchar2,
                                    actid in number,
                                    funcmode in varchar2,
                                    resultout out nocopy varchar2 );

PROCEDURE update_counter( p_api_version                    IN  NUMBER,
                                p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                p_trx_id                         IN  NUMBER,
                                x_return_status                  OUT NOCOPY VARCHAR2,
                                x_msg_count                      OUT NOCOPY NUMBER,
                                x_msg_data                       OUT NOCOPY VARCHAR2);


PROCEDURE populate_req_repqte_attr_wf
           (itemtype             in varchar2,
            itemkey              in varchar2,
            actid                in number,
            funcmode             in varchar2,
            resultout            out nocopy varchar2
            );
PROCEDURE approve_quote_status
           (itemtype             in varchar2,
            itemkey              in varchar2,
            actid                in number,
            funcmode             in varchar2,
            resultout            out nocopy varchar2
            );
PROCEDURE reject_quote_status
           (itemtype             in varchar2,
            itemkey              in varchar2,
            actid                in number,
            funcmode             in varchar2,
            resultout            out nocopy varchar2
            );
procedure createRepurchaseQuote(
                            p_api_version                    IN  NUMBER,
                            p_init_msg_list                  IN  VARCHAR2,
                            p_khr_id                         IN  NUMBER,
                            p_kle_id                         IN  NUMBER,
                            p_art_id                         IN  NUMBER,
                            p_qtp_code                       IN  VARCHAR2,
                            p_requestor_id                   IN  VARCHAR2,
                            x_return_status                  OUT NOCOPY VARCHAR2,
                            x_msg_count                      OUT NOCOPY NUMBER,
                            x_msg_data                       OUT NOCOPY VARCHAR2);


END OKL_VSS_WF;

 

/
