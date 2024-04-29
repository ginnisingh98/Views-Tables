--------------------------------------------------------
--  DDL for Package Body AST_UWQ_MLIST_MSG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_MLIST_MSG_PKG" AS
/* $Header: astummsb.pls 115.10 2003/02/25 19:29:23 jraj ship $ */

procedure AST_UWQ_MLIST_MESSAGE
 ( p_resource_id        	IN  NUMBER,
   p_language           	IN  VARCHAR2 DEFAULT NULL,
   p_source_lang        	IN  VARCHAR2 DEFAULT NULL,
   p_action_key         	IN  VARCHAR2,
   p_action_input_data_list 	IN system.action_input_data_nst DEFAULT null,
   x_mesg_data_char 	 OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY VARCHAR2,
   x_msg_data                OUT NOCOPY VARCHAR2,
   x_return_status           OUT NOCOPY VARCHAR2) AS

   l_description  varchar2(8200);

   l_name  varchar2(500);
   l_value  varchar2(1996);

   l_campaign_id  number;
   l_schedule_id  number;
   l_camp_descr varchar2(3000);
   l_campaign     varchar2(300);
   l_no_campaign varchar2(2000);

   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_error_msg			   VARCHAR2(100);

   cursor c_camp_description(p_schedule_id in number) is
     select  '< Campaign: ' || a.description  || ' >  < Schedule: ' || b.description || ' >'
	from    ams_campaigns_all_tl a,
        ams_campaign_schedules_vl b
	where   a.campaign_id = b.campaign_id
	and 	a.language = userenv('LANG')
	and     b.schedule_id  = p_schedule_id;

BEGIN

	FOR I IN 1.. p_action_input_data_list.COUNT LOOP
              l_name := p_action_input_data_list(i).name;
              l_value := p_action_input_data_list(i).value;

              ------ Get field name and value of your records ------

	   if     l_name = 'SCHEDULE_ID'   then
   	        l_schedule_id :=  l_value ;
			exit;
   	   elsif l_name = 'SOURCE_DESCRIPTION' then
   	   	l_camp_descr := l_value;
		exit;
	   end if;
	END LOOP;

 if  p_action_key in ( 'astummsb_camp_details' , 'astummsb_camp_details_man') then  -- begin of main "if"

        if l_schedule_id is not null then
  	  OPEN c_camp_description(l_schedule_id);
	    fetch c_camp_description into l_description;

	    if c_camp_description%found then
		null;
            else
	-- ERROR --
	    x_return_status := FND_API.g_ret_sts_unexp_error;
		  fnd_message.set_name('AST','AST_UWQ_INVALID_CAMPAIGN');
		  l_error_msg :=   fnd_message.get;
            FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
            FND_MESSAGE.Set_Token('TEXT', l_error_msg || ' ' || l_description, FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
           end if;
         CLOSE c_camp_description;
       elsif l_camp_descr is not null then
		  fnd_message.set_name('AST','AST_CAMP');
		  l_campaign :=   fnd_message.get;
       	  l_description := '< ' || l_campaign || ':' || l_camp_descr  || ' > ' ;
	   else
		  fnd_message.set_name('AST','AST_NO_CAMP_DATA');
		  l_no_campaign :=   fnd_message.get;
	       l_description := '< '|| l_no_campaign || ': > ';
       end if;

     -- setting the OUT variables -begin

	 x_mesg_data_char	:=l_description;
         x_return_status	:=fnd_api.g_ret_sts_success;

	 fnd_msg_pub.Count_And_Get(p_count => x_msg_count,
	                           p_data  => x_msg_data);

     -- setting the OUT variables -end
   end if;     -- end of main "if"
	exception

	when fnd_api.g_exc_error  then
      x_return_status:=fnd_api.g_ret_sts_error;

	when fnd_api.g_exc_unexpected_error  then
      x_return_status:=fnd_api.g_ret_sts_unexp_error;

	when others then
      x_return_status:=fnd_api.g_ret_sts_unexp_error;

	 fnd_msg_pub.Count_And_Get(p_count => x_msg_count,
	                           p_data  => x_msg_data);

END AST_UWQ_MLIST_MESSAGE;

END AST_UWQ_MLIST_MSG_PKG;

/
