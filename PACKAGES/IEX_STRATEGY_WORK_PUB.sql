--------------------------------------------------------
--  DDL for Package IEX_STRATEGY_WORK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRATEGY_WORK_PUB" AUTHID CURRENT_USER as
/* $Header: iexpstms.pls 120.3.12010000.2 2009/06/25 11:58:57 snuthala ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_STRATEGY_WORK';

TYPE STRATEGY_Mailer_Rec_Type IS RECORD (
            strategy_id     NUMBER := null
    ,       delinquency_id  NUMBER := null
    ,       template_id     NUMBER := null
    ,       xdo_template_id NUMBER := null
    ,       workitem_id    NUMBER := null
    ,       user_id        NUMBER  :=null
    ,       resp_id        NUMBER  :=null
    ,       resp_appl_id   NUMBER  :=null
    );

   G_MISS_STRATEGY_MAILER_REC          STRATEGY_Mailer_Rec_Type;

/**
 * send an email thru fulfilment
 **/
procedure send_mail(
                                      itemtype    in   varchar2,
                                      itemkey     in   varchar2,
                                      actid       in   number,
                                      funcmode    in   varchar2,
                                      result      out NOCOPY  varchar2);

/**
 * setup the workflow which call the mailer thru fulfilment
 **/
procedure strategy_mailer(
    p_api_version             IN  NUMBER ,
    p_init_msg_list           IN  VARCHAR2 ,
    p_commit                  IN  VARCHAR2 ,
    p_strategy_mailer_rec     IN  STRATEGY_MAILER_REC_TYPE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);


procedure populate_fulfillment_wait
          ( p_delinquency_id IN NUMBER,
            p_work_item_id IN NUMBER,
            itemtype            IN   varchar2,
            itemkey             IN   varchar2
           ) ;

procedure wf_send_signal(
  itemtype    in   varchar2,
  itemkey     in   varchar2,
  actid       in   number,
  funcmode    in   varchar2,
  result      out NOCOPY  varchar2);

procedure check_dunning(
  itemtype    in   varchar2,
  itemkey     in   varchar2,
  actid       in   number,
  funcmode    in   varchar2,
  result      out NOCOPY  varchar2);

procedure resend_fulfillment(
p_work_item_id IN NUMBER,
x_status out NOCOPY varchar2,
x_error_message out NOCOPY varchar2,
x_request_id out NOCOPY number
);

--Start schekuri 02-Dec-2005 - bug#4506922
--added for the function WAIT_ON_HOLD_SIGNAL in workflow IEXSTFFM
procedure wait_on_hold_signal(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2);
--end schekuri 02-Dec-2005 - bug#4506922

procedure wait_delivery_signal(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2);

procedure cal_delivery_wait(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2);
procedure send_delivery_signal(
			p_xml_request_id IN NUMBER,
			p_status IN varchar2,
			x_error_message out NOCOPY varchar2);

procedure delivery_failed(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2);

procedure auto_retry_notifications(p_from_date in date,
                                   x_error_message out NOCOPY varchar2);



end IEX_STRATEGY_WORK_PUB;

/
