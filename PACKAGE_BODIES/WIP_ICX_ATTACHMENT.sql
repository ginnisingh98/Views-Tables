--------------------------------------------------------
--  DDL for Package Body WIP_ICX_ATTACHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_ICX_ATTACHMENT" as
/* $Header: WIPICXAB.pls 115.6 2002/11/28 11:33:54 rmahidha ship $ */

procedure operation(c_inputs1 in varchar2 default null,
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
                        c_outputs10 out nocopy varchar2)is
l_entity_name	varchar2(50);

begin

if icx_sec.validateSession then

	if (c_inputs5 is null) then
	    l_entity_name := 'WIP_DISCRETE_OPERATIONS';
	else
	    l_entity_name := 'WIP_REPETITIVE_OPERATIONS';
	end if;

        fnd_webattch.Summary(
                function_name=>icx_call.encrypt2('WIP_WIPOPMDF'),
                entity_name=>icx_call.encrypt2(l_entity_name),
                pk1_value=>icx_call.encrypt2(c_inputs2),
                pk2_value=>icx_call.encrypt2(c_inputs3),
                pk3_value=>icx_call.encrypt2(c_inputs4),
                pk4_value=>icx_call.encrypt2(c_inputs5),
                pk5_value=>icx_call.encrypt2(NULL),
                from_url=>icx_call.encrypt2(NULL),
                query_only=>icx_call.encrypt2('Y'));
end if;
end;

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
  c_outputs10 out nocopy varchar2)is

begin

if icx_sec.validateSession then
	fnd_webattch.Summary
		(function_name=>icx_call.encrypt2('WIP_WIPMRMDF'),
		entity_name=>icx_call.encrypt2('MTL_SYSTEM_ITEMS'),
                pk1_value=>icx_call.encrypt2(c_inputs5),
                pk2_value=>icx_call.encrypt2(c_inputs4),
   		pk3_value=>icx_call.encrypt2(null),
		pk4_value=>icx_call.encrypt2(NULL),
		pk5_value=>icx_call.encrypt2(NULL),
		from_url=>icx_call.encrypt2(NULL),
		query_only=>icx_call.encrypt2('Y'));
end if;

end;


end wip_icx_attachment;

/
