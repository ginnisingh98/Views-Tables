--------------------------------------------------------
--  DDL for Package WIP_ICX_ATTACHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_ICX_ATTACHMENT" AUTHID CURRENT_USER as
/* $Header: WIPICXAS.pls 115.6 2002/11/28 11:29:07 rmahidha ship $ */

procedure operation (c_inputs1 in varchar2 default null,
                        c_inputs2 in varchar2 default null,
                        c_inputs3 in varchar2 default null,
                        c_inputs4 in varchar2 default null,
                        c_inputs5 in varchar2 default null,
                        c_inputs6 in varchar2 default null,
                        c_inputs7 in varchar2 default null,
                        c_inputs8 in varchar2 default null,
                        c_inputs9 in varchar2 default null,
                        c_inputs10 in varchar2 default null,
                        c_outputs1 out nocopy varchar2,
                        c_outputs2 out nocopy varchar2,
                        c_outputs3 out nocopy varchar2,
                        c_outputs4 out nocopy varchar2,
                        c_outputs5 out nocopy varchar2,
                        c_outputs6 out nocopy varchar2,
                        c_outputs7 out nocopy varchar2,
                        c_outputs8 out nocopy varchar2,
                        c_outputs9 out nocopy varchar2,
                        c_outputs10 out nocopy varchar2);


procedure component(c_inputs1 in varchar2 default null,
                        c_inputs2 in varchar2 default null,
                        c_inputs3 in varchar2 default null,
                        c_inputs4 in varchar2 default null,
                        c_inputs5 in varchar2 default null,
                        c_inputs6 in varchar2 default null,
                        c_inputs7 in varchar2 default null,
                        c_inputs8 in varchar2 default null,
                        c_inputs9 in varchar2 default null,
                        c_inputs10 in varchar2 default null,
                        c_outputs1 out nocopy varchar2,
                        c_outputs2 out nocopy varchar2,
                        c_outputs3 out nocopy varchar2,
                        c_outputs4 out nocopy varchar2,
                        c_outputs5 out nocopy varchar2,
                        c_outputs6 out nocopy varchar2,
                        c_outputs7 out nocopy varchar2,
                        c_outputs8 out nocopy varchar2,
                        c_outputs9 out nocopy varchar2,
                        c_outputs10 out nocopy varchar2);


end wip_icx_attachment;

 

/
