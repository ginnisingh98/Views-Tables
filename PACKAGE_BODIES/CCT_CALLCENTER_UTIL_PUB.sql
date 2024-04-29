--------------------------------------------------------
--  DDL for Package Body CCT_CALLCENTER_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_CALLCENTER_UTIL_PUB" as
/* $Header: cctcutlb.pls 120.0 2005/06/02 09:41:01 appldev noship $ */

Procedure getMiddlewareParam(p_resource_id IN Number Default Null,
                             x_middleware_id IN out nocopy Number,
                             x_param_value out nocopy CCT_KEYVALUE_VARR)
                            IS

	Cursor c_agent_mware(p_agent_id Number)
	Is
		Select m.middleware_id
		from cct_middlewares m,cct_telesets t,cct_agent_rt_stats a
		where a.agent_id=p_agent_id
		and a.client_id=t.teleset_id
		and t.middleware_id=m.middleware_id;

	Cursor c_mware_params(p_middleware_id Number)
	Is
		Select upper(p.name),v.value
		from cct_middleware_params p,cct_middleware_values v,cct_middlewares m
		where m.middleware_id=p_middleware_id
		and m.middlewarE_type_id=p.middleware_type_id
		and p.middleware_param_id=v.middleware_param_id
		and nvl(v.f_deletedflag,'N')<>'D';
	l_middleware_id Number:=G_MIDDLEWARE_NOT_FOUND;
	l_param VARCHAR2(255);
	l_value VARCHAR2(255);
	l_paramValue CCT_KEYVALUE_VARR:= CCT_KEYVALUE_VARR();
	l_result VARCHAR2(32);
Begin
	If p_resource_id is not null then
		Open c_agent_mware(p_resource_id);

		Fetch c_agent_mware into l_middleware_id;

		Close c_agent_mware;

	End if;
	If l_middleware_id<>G_MIDDLEWARE_NOT_FOUND THEN
		Open c_mware_params(l_middleware_id);

		Loop
		  Fetch c_mware_params into l_param,l_value;
		  l_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_paramValue,l_param,l_value);
		  Exit When c_mware_params%NOTFOUND;
		End loop;

		Close c_mware_params;
	End if;

	x_middleware_id:=l_middleware_id;
	x_param_value:=l_paramValue;

Exception

	When others then
		x_middleware_id:=l_middleware_id;
		x_param_value:=l_paramValue;
End;


Procedure getDialableNumber(p_resource_id IN Number,
                            p_country_code In Number,
                            p_area_code IN Number,
                            p_localNumber In Number,
                            x_dialableNumber out nocopy Number)
IS
	l_site_overlay VARCHAR2(32);
	l_outgoing_prefix VARCHAR2(32):=null;
	l_site_area_code VARCHAR2(32):=null;
	l_site_country_code VARCHAR2(32):=null;
	l_domestic_prefix VARCHAR2(32):=null;
	l_idd_prefix VARCHAR2(32):=null;
	l_local_num_max_length VARCHAR2(32):=null;

	l_param_value CCT_KEYVALUE_VARR;
	l_middlewarE_id Number;
	l_defaultDialNumber VARCHAR2(64);
	l_key_exists VARCHAR2(32);
	l_value VARCHAR2(32);
Begin

	l_defaultDialNumber:=To_char(p_country_code)||to_char(p_area_code)||to_char(p_localNumber);
	--get the Middleware Parameter Values
	getMiddlewareparam(p_resource_id,l_middleware_id,l_param_value);

	If l_middleware_id<>G_MIDDLEWARE_NOT_FOUND THEN

		l_value:=CCT_COLLECTION_UTIL_PUB.GET(l_param_value,'SITE_OVERLAY',l_key_exists);
		if(l_key_exists=CCT_COLLECTION_UTIL_PUB.G_TRUE) then
			l_site_overlay:=l_value;
		end if;
		l_value:=CCT_COLLECTION_UTIL_PUB.GET(l_param_value,'OUTGOING_PREFIX',l_key_exists);
		if(l_key_exists=CCT_COLLECTION_UTIL_PUB.G_TRUE) then
			l_outgoing_prefix:=l_value;
		end if;
		l_value:=CCT_COLLECTION_UTIL_PUB.GET(l_param_value,'SITE_AREA_CODE',l_key_exists);
		if(l_key_exists=CCT_COLLECTION_UTIL_PUB.G_TRUE) then
			l_site_area_code:=l_value;
		end if;
		l_value:=CCT_COLLECTION_UTIL_PUB.GET(l_param_value,'SITE_COUNTRY_CODE',l_key_exists);
		if(l_key_exists=CCT_COLLECTION_UTIL_PUB.G_TRUE) then
			l_site_country_code:=l_value;
		end if;
		l_value:=CCT_COLLECTION_UTIL_PUB.GET(l_param_value,'DOMESTIC_PREFIX',l_key_exists);
		if(l_key_exists=CCT_COLLECTION_UTIL_PUB.G_TRUE) then
			l_domestic_prefix:=l_value;
		end if;
		l_value:=CCT_COLLECTION_UTIL_PUB.GET(l_param_value,'IDD_PREFIX',l_key_exists);
		if(l_key_exists=CCT_COLLECTION_UTIL_PUB.G_TRUE) then
			l_idd_prefix:=l_value;
		end if;
		l_value:=CCT_COLLECTION_UTIL_PUB.GET(l_param_value,'LOCAL_NUM_MAX_LENGTH',l_key_exists);
		if(l_key_exists=CCT_COLLECTION_UTIL_PUB.G_TRUE) then
			l_local_num_max_length:=l_value;
		end if;

		x_dialableNumber:=TO_NUMBER(L_OUTGOING_PREFIX||To_char(p_country_code)||to_char(p_area_code)||to_char(p_localNumber));

		if((length(to_char(p_localNumber))<=to_number(l_local_num_max_length)) AND
		    p_country_code is null and p_area_code is null) THEN
			  -- it is a local number
			if(upper(l_site_overlay)='YES') THEN
				-- local number requires area code+ phone number
				-- add outgoing prefix and area code
				x_dialableNumber:=to_number(l_outgoing_prefix||l_site_area_code||to_char(p_localNumber));
			else
				x_dialableNumber:=to_number(l_outgoing_prefix||to_char(p_localNumber));

			end if;
		Else
			if(p_country_code is null) OR (p_country_code=to_number(l_site_country_code)) THEN
				-- Dialing within country

				if (p_area_code is not null) AND (p_area_code <> to_number(l_site_area_code)) THEN
					-- long distance number
					x_dialableNumber:=to_number(l_outgoing_prefix||l_domestic_prefix||to_char(p_area_code)||to_char(p_localNumber));
				else
					if(upper(l_site_overlay)='YES') THEN
						-- local number requires area code+ phone number
						-- add outgoing prefix and area code
						x_dialableNumber:=to_number(l_outgoing_prefix||to_char(p_area_code)||to_char(p_localNumber));
					else
						x_dialableNumber:=to_number(l_outgoing_prefix||to_char(p_localNumber));
					end if;
				END IF;
			ELSE
				-- INTERNATIONAL DIALING
					x_dialableNumber:=to_number(l_outgoing_prefix||l_IDD_prefix||TO_CHAR(P_COUNTRY_CODE)||to_char(p_area_code)||to_char(p_localNumber));
			END IF;
		END IF;
	Else
		x_dialableNumber:=to_number(l_defaultDialNumber);
	End If;
Exception
	When others then
		x_dialableNumber:=to_number(l_defaultDialNumber);
End;

End CCT_CALLCENTER_UTIL_PUB;

/
