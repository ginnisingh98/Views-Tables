--------------------------------------------------------
--  DDL for Package Body QPR_PRICE_NEGOTIATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_PRICE_NEGOTIATION_PUB" AS
/* $Header: QPRADEAPB.pls 120.22 2008/05/30 09:15:39 vinnaray ship $ */

FUNCTION Get_QPR_Status RETURN VARCHAR2 IS

  l_status      VARCHAR2(1);
  l_industry    VARCHAR2(1);
  l_application_id       NUMBER := 667;
  l_retval      BOOLEAN;
  BEGIN


  IF G_PRODUCT_STATUS = FND_API.G_MISS_CHAR THEN

   l_retval := fnd_installation.get(l_application_id,l_application_id,
      						 l_status,l_industry);

        -- if l_status = 'I', QPR is installed.
	   --if l_status = 'N', -- QPR not installled

   G_PRODUCT_STATUS := l_status;

  END IF;

   return G_PRODUCT_STATUS;

 END Get_QPR_Status;

procedure create_pn_request(
                       errbuf out nocopy varchar2,
                       retcode out nocopy varchar2,
                       p_quote_origin in number,
                       p_quote_number in number,
                       p_quote_version in number,
                       p_order_type_name in varchar2,
                       p_quote_header_id in number,
                       p_instance_id in number default null,
                       p_simulation in varchar2 default 'Y',
                       p_response_id out nocopy number,
		       p_is_deal_compliant out nocopy varchar2,
		       p_rules_desc out nocopy varchar2) is
--l_quote_origin number;
--l_src_id number;
--l_app_name varchar2(240);
PRAGMA AUTONOMOUS_TRANSACTION;
begin
    g_origin := p_quote_origin;
    debug_log('In QPR_PRICE_NEGOTIATION_PUB.create_pn_request');
    debug_log('Quote origin: '||p_quote_origin);
    debug_log('Quote header ID: '||p_quote_header_id);
    debug_log('Quote header number: '||p_quote_number);
    debug_log('Quote header version: '||p_quote_version);
    debug_log('Quote Order Type: '||p_order_type_name);
    debug_log('Instance ID : '||p_instance_id);
    debug_log('Simulation Flag : '||p_simulation);


 --   l_src_id := p_quote_origin;
    /*if p_quote_origin = 660 then
	l_quote_origin := 1;
    end if;
    if p_quote_origin = 697 then
	l_quote_origin := 2;
    end if;*/
    if p_simulation = 'N' then
      begin
        select response_header_id into p_response_id
        from (
        select response_header_id
        from qpr_pn_response_hdrs resp, qpr_pn_request_hdrs_b req
        where resp.request_header_id = req.request_header_id
        and req.source_ref_hdr_short_desc = (p_quote_number || ' - Ver ' || p_quote_version)
        and req.source_id = p_quote_origin
        and req.instance_id = p_instance_id
        order by resp.request_header_id, resp.version_number desc)
        where rownum < 2;

        return;
      exception
        when no_data_found then
          null;
      end;
    end if;
    qpr_load_meas_data.load_quote_data_api(errbuf, retcode,
                                     p_instance_id,
                                     --l_quote_origin,
				     p_quote_origin,
                                     p_quote_header_id,
                                     p_quote_number,
                                     p_quote_version,
                                     p_order_type_name);
    if nvl(retcode, 0) = 2 then
      rollback ;
      return;
    else
      commit;
    end if;

    qpr_deal_etl.process_deal_api(errbuf, retcode,
                                   p_instance_id,
                                   p_quote_origin,
                                   p_quote_header_id,
                                   p_simulation,
                                   p_response_id,
                                   p_is_deal_compliant,
				   p_rules_desc
                                   );
    if nvl(retcode, 0) = 2 then
      rollback ;
      return;
    else
      commit;
    end if;
end ;

procedure get_pn_approval_status(
                       errbuf out nocopy varchar2,
                       retcode out nocopy varchar2,
                       p_quote_origin in number,
                       p_quote_header_id in number,
                       o_deal_id out nocopy number,
                       o_status out nocopy varchar2)
is
l_response_status varchar2(20);
l_deal_id number;
begin
	debug_log('In QPR_PRICE_NEGOTIATION_PUB.get_pn_approval_status');
	debug_log('Quote origin: '||p_quote_origin);
	debug_log('Quote header ID: '||p_quote_header_id);
--	debug_out('Quote origin: '||p_quote_origin);
--	debug_out('Quote header ID: '||p_quote_header_id);
    	g_origin := p_quote_origin;
	o_status := 'N';
	o_deal_id := null;
	select response_status, response_header_id
	into l_response_status, l_deal_id
	from (
	select resp.response_status, resp.response_header_id
	from qpr_pn_response_hdrs resp, qpr_pn_request_hdrs_b req
	where resp.request_header_id = req.request_header_id
	and req.source_ref_hdr_id = p_quote_header_id
	and req.source_id = p_quote_origin
	order by resp.version_number)
	where rownum < 2;
	if l_response_status = 'APPROVED' then
		o_status := 'Y';
	end if;
	o_deal_id := l_deal_id;
	debug_log('Deal ID: '||o_deal_id);
	debug_log('Deal Approved: '||o_status);
--	debug_out('Deal ID: '||o_deal_id);
--	debug_out('Deal Approved: '||o_status);
exception
	when no_data_found then
	    retcode := 2;
end;

procedure debug_log(text varchar2)
is
begin

   fnd_file.put_line(fnd_file.log, text);

   if (g_origin = 660 or g_origin = 697) then
	qpr_deal_pvt.debug_ext_log(text, g_origin);
   end if;

/*   if g_origin = 660 then
	oe_debug_pub.add(text);
   end if;
   if g_origin = 697 then
      aso_debug_pub.ADD (text);
   end if;*/
end;

function has_active_requests(p_quote_origin number,
			p_quote_header_id number,
			p_instance_id number)
return varchar2
is
begin
   if (qpr_deal_pvt.has_active_requests(p_quote_origin,
				p_quote_header_id,
				p_instance_id)) then
	return('Y');
   else
	return('N');
   end if;
exception
   when others then
	return('N');
end;

function has_saved_requests(p_quote_origin number,
			p_quote_header_id number,
			p_instance_id number)
return varchar2
is
begin
   if (qpr_deal_pvt.has_saved_requests(p_quote_origin,
				p_quote_header_id,
				p_instance_id)) then
	return('Y');
   else
	return('N');
   end if;
exception
   when others then
	return('N');
end;

procedure cancel_active_requests(p_quote_origin in number,
                           p_quote_header_id in number,
                           instance_id in number,
                           suppress_event in boolean default false,
                           x_return_status out nocopy varchar2,
                           x_mesg_data out nocopy varchar2)
is
l_ret varchar2(240);
l_mesg varchar2(240);
x_msg_count number;
begin
    	debug_log('In QPR_PRICE_NEGOTIATION_PUB.cancel_active_requests');
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	qpr_deal_pvt.cancel_pn_request(p_quote_origin,
				p_quote_header_id,
				instance_id,
				l_ret);
	if l_ret <> FND_API.G_RET_STS_SUCCESS then
		raise  exe_severe_error;
	end if;
	if not suppress_event then
		--qpr_deal_pvt.source_call_back(
		qpr_deal_pvt.handle_request_event(
					p_quote_origin,
					p_quote_header_id,
					null,
					null,
					instance_id,
					'CANCELLED',
					l_ret, x_mesg_data);
		if l_ret <> FND_API.G_RET_STS_SUCCESS then
			raise  exe_severe_error;
		end if;
	end if;
exception
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded		=> 	'F',
    		  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_mesg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded		=> 	'F',
    		  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_mesg_data
    		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded		=> 	'F',
    		  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_mesg_data
    		);

end;

procedure create_request(p_quote_origin in number,
                   	p_quote_header_id in number,
			p_instance_id number,
			suppress_event in boolean default false,
		        p_is_deal_compliant out nocopy varchar2,
		        p_rules_desc out nocopy varchar2,
			x_return_status out nocopy varchar2,
			x_mesg_data out nocopy varchar2)
is
  x_msg_count number;
  l_response_id number;
  l_ret number;
  l_err varchar2(240);
begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    g_origin := p_quote_origin;
    debug_log('In QPR_PRICE_NEGOTIATION_PUB.create_request');
    debug_log('Quote origin: '||p_quote_origin);
    debug_log('Quote header ID: '||p_quote_header_id);
    debug_log('Instance ID : '||p_instance_id);

    qpr_load_meas_data.load_quote_data_api(l_err, l_ret,
                                     p_instance_id,
				     p_quote_origin,
                                     p_quote_header_id,
                                     null,
                                     null,
                                     null);
    if nvl(l_ret, 0) = 2 then
		debug_log(l_err);
		raise  exe_severe_error;
    end if;

    qpr_deal_etl.process_deal_api(l_err, l_ret,
                                   p_instance_id,
                                   p_quote_origin,
                                   p_quote_header_id,
                                   'Y', --Allways as simulated
                                   l_response_id,
                                   p_is_deal_compliant,
				   p_rules_desc
                                   );
    if nvl(l_ret, 0) = 2 then
		debug_log(l_err);
		raise  exe_severe_error;
    end if;

exception
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded		=> 	'F',
    		  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_mesg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded		=> 	'F',
    		  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_mesg_data
    		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded		=> 	'F',
    		  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_mesg_data
    		);
end;

function get_redirect_function(
			p_quote_origin in number,
			p_quote_header_id in number,
			instance_id in number,
			skip_search in boolean default true) return varchar2
is
l_dummy number;
begin
	return(qpr_deal_pvt.get_redirect_function(p_quote_origin,
			p_quote_header_id, instance_id, skip_search));
exception
	when others then
		return null;
end;

procedure initiate_deal(source_id in number,
		source_ref_id in number,
		instance_id number,
		updatable varchar2,
		redirect_function out nocopy varchar2,
		p_is_deal_compliant out nocopy varchar2,
		p_rules_desc out nocopy varchar2,
		x_return_status out nocopy varchar2,
		x_mesg_data out nocopy varchar2)
is
l_err varchar2(240);
l_ret varchar2(240);
l_changed varchar2(1);
x_msg_count number;
l_count_lines number;

cursor c_resp_app is
select distinct rule_description
from qpr_pn_response_approvals pnra, qpr_pn_request_hdrs_b pnre,
	qpr_pn_response_hdrs pnrs
where pnra.response_header_id = pnrs.response_header_id
and pnrs.request_header_id = pnre.request_header_id
and pnrs.version_number = 1
and pnre.source_id = source_id
and pnre.source_ref_hdr_id = source_ref_id
and pnre.instance_id = instance_id;

begin

   g_origin := source_id;
   fnd_msg_pub.initialize;

   debug_log('In QPR_PRICE_NEGOTIATION_PUB.initiate_deal');
   debug_log('Quote origin: '||source_id);
   debug_log('Quote header ID: '||source_ref_id);
   debug_log('Instance ID : '||instance_id);
   debug_log('Updatable : '||updatable);

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   if has_active_requests(source_id, source_ref_id, instance_id) = 'Y' then
      debug_log('There are active requests');
      if nvl(updatable, 'Y') = 'Y' then
	l_changed := QPR_LOAD_MEAS_DATA.is_source_quote_changed(l_err,
                                  l_ret,
                                  instance_id,
                                  source_id,
                                  source_ref_id);
	if nvl(l_ret, 0) = 2 then
		debug_log(l_err);
		raise  exe_severe_error;
	end if;
	if nvl(l_changed, 'Y') = 'Y' then
      	   debug_log('The source document is changed');
	   cancel_active_requests( source_id, source_ref_id, instance_id,
                           true, x_return_status , x_mesg_data);
	    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
			debug_log(x_mesg_data);
			raise  exe_severe_error;
	    end if;
      	   debug_log('The current deal cancelled');
	   create_request(source_id, source_ref_id, instance_id,
				true, p_is_deal_compliant, p_rules_desc,
				x_return_status , x_mesg_data);
	    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
			debug_log(x_mesg_data);
			raise  exe_severe_error;
	    end if;
      	   debug_log('New deal created');
	end if;
      end if;
      if updatable = 'N' or l_changed = 'N' then
	  p_is_deal_compliant := 'Y';
          l_count_lines := 0;
          p_rules_desc := '';
          for rec_app in c_resp_app loop
	    p_is_deal_compliant := 'N';
            p_rules_desc := p_rules_desc || rec_app.rule_description;
            l_count_lines := l_count_lines + 1;
            if l_count_lines > 9 then
              exit;
            else
              p_rules_desc := p_rules_desc || ',';
            end if;
          end loop;
      end if;
   else
	   create_request(source_id, source_ref_id, instance_id,
				true, p_is_deal_compliant, p_rules_desc,
				x_return_status , x_mesg_data);
	    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
			debug_log(x_mesg_data);
			raise  exe_severe_error;
	    end if;
      	    debug_log('New deal created');
   end if;
   redirect_function := get_redirect_function(source_id, source_ref_id, instance_id, true);
   debug_log('Is Deal Compliant: '||p_is_deal_compliant);
   debug_log('Failed rules descriptions: '||p_rules_desc);
exception
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded		=> 	'F',
    		  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_mesg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded		=> 	'F',
    		  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_mesg_data
    		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded		=> 	'F',
    		  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_mesg_data
    		);
end;

END;


/
