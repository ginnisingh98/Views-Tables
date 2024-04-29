--------------------------------------------------------
--  DDL for Package Body EC_APPLICATION_ADVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_APPLICATION_ADVICE_PUB" AS
-- $Header: ECPADVOB.pls 120.2 2005/09/29 11:30:37 arsriniv ship $

PROCEDURE create_advice(
   p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_communication_method	IN	VARCHAR2,
   p_related_document_id	IN	VARCHAR2,
   p_tp_header_id		IN	NUMBER,
   p_tp_location_code		IN	VARCHAR2,
   p_document_type		IN	VARCHAR2,
   p_document_code		IN	VARCHAR2,
   p_transaction_control1	IN	VARCHAR2 default NULL,
   p_transaction_control2	IN	VARCHAR2 default NULL,
   p_transaction_control3	IN	VARCHAR2 default NULL,
   p_entity_code		IN	VARCHAR2 default NULL,
   p_entity_name		IN	VARCHAR2 default NULL,
   p_entity_address1		IN	VARCHAR2 default NULL,
   p_entity_address2		IN	VARCHAR2 default NULL,
   p_entity_address3		IN	VARCHAR2 default NULL,
   p_entity_address4		IN	VARCHAR2 default NULL,
   p_entity_city		IN	VARCHAR2 default NULL,
   p_entity_postal_code		IN	VARCHAR2 default NULL,
   p_entity_country		IN	VARCHAR2 default NULL,
   p_entity_state		IN	VARCHAR2 default NULL,
   p_entity_province		IN	VARCHAR2 default NULL,
   p_entity_county		IN	VARCHAR2 default NULL,
   p_external_reference_1	IN	VARCHAR2 default NULL,
   p_external_reference_2	IN	VARCHAR2 default NULL,
   p_external_reference_3	IN	VARCHAR2 default NULL,
   p_external_reference_4	IN	VARCHAR2 default NULL,
   p_external_reference_5	IN	VARCHAR2 default NULL,
   p_external_reference_6	IN	VARCHAR2 default NULL,
   p_internal_reference_1	IN	VARCHAR2 default NULL,
   p_internal_reference_2	IN	VARCHAR2 default NULL,
   p_internal_reference_3	IN	VARCHAR2 default NULL,
   p_internal_reference_4	IN	VARCHAR2 default NULL,
   p_internal_reference_5	IN	VARCHAR2 default NULL,
   p_internal_reference_6	IN	VARCHAR2 default NULL,
   p_advice_header_id		OUT NOCOPY	NUMBER
)
IS
   l_api_name		CONSTANT VARCHAR2(30) := 'Create_Advice';
   l_api_version_number	CONSTANT NUMBER	      := 1.0;
   l_return_status		 VARCHAR2(10);
   l_tp_exists                   VARCHAR2(1):='N';		-- Bug 2593437

BEGIN

   p_advice_header_id := -99;		-- Bug 2593437

   begin
     select 'Y'
     into l_tp_exists
     from ece_tp_details
     where document_id='ADVO'
     and tp_header_id= p_tp_header_id;
   exception
    when others then
        null;
   end;

  if l_tp_exists = 'Y' then                             -- Bug 2593437

   -- Standard Start of API savepoint

   SAVEPOINT Create_Advice_PVT;

   -- Standard call to check for call compatibility.

   if NOT FND_API.Compatible_API_Call
   (
	l_api_version_number,
	p_api_version_number,
	l_api_name,
	G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success

   p_return_status := FND_API.G_RET_STS_SUCCESS;


   select ece_advo_headers_s.nextval
     into p_advice_header_id
     from dual;

/*
   EC_Trading_Partner_PVT.Get_TP_Location_Code(
		p_api_version_number	=> 1.0,
		p_return_status		=> l_return_status,
		p_msg_count		=> l_msg_count,
		p_msg_data		=> l_msg_data,
		p_entity_address_id	=> p_entity_address_id,
		p_info_type		=> p_entity_type,
		p_location_code_ext	=> l_location_code_ext,
		p_reference_ext1	=> l_reference_ext1,
		p_reference_ext2	=> l_reference_ext2);

   if l_location_code_ext is NULL
   then
      fnd_message.set_name('EC','EC_TP_NOT_DEFINED');
      FND_MSG_PUB.Add;
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--      c_error_msg := fnd_message.get;
   else

*/



      insert into ECE_ADVO_HEADERS (
		communication_method,
		ADVICE_HEADER_ID,
		DOCUMENT_TYPE,
		DOCUMENT_CODE,
		TP_HEADER_ID,
		TP_LOCATION_CODE_EXT,
		TP_CODE,
		TP_NAME,
		TP_ADDRESS1,
		TP_ADDRESS2,
		TP_ADDRESS3,
		TP_ADDRESS4,
		TP_CITY,
		TP_POSTAL_CODE,
		TP_COUNTRY,
		TP_STATE,
		TP_PROVINCE,
		TP_COUNTY,
		RELATED_DOCUMENT_ID,
		EXTERNAL_REFERENCE1,
		EXTERNAL_REFERENCE2,
		EXTERNAL_REFERENCE3,
		EXTERNAL_REFERENCE4,
		EXTERNAL_REFERENCE5,
		EXTERNAL_REFERENCE6,
		INTERNAL_REFERENCE1,
		INTERNAL_REFERENCE2,
		INTERNAL_REFERENCE3,
		INTERNAL_REFERENCE4,
		INTERNAL_REFERENCE5,
		INTERNAL_REFERENCE6,
		TRANSACTION_CONTROL1,
		TRANSACTION_CONTROL2,
		TRANSACTION_CONTROL3)
	values (
		p_communication_method,
		p_advice_header_id,
		p_document_type,
		p_document_code,
		p_tp_header_id,
		p_tp_location_code,
		p_entity_code,
		p_entity_name,
		p_entity_address1,
		p_entity_address2,
		p_entity_address3,
		p_entity_address4,
		p_entity_city,
		p_entity_postal_code,
		p_entity_country,
		p_entity_state,
		p_entity_province,
		p_entity_county,
		p_related_document_id,
		p_external_reference_1,
		p_external_reference_2,
		p_external_reference_3,
		p_external_reference_4,
		p_external_reference_5,
		p_external_reference_6,
		p_internal_reference_1,
		p_internal_reference_2,
		p_internal_reference_3,
		p_internal_reference_4,
		p_internal_reference_5,
		p_internal_reference_6,
		p_transaction_control1,
		p_transaction_control2,
		p_transaction_control3);



   -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;

   -- Standard check of p_simulate and p_commit parameters

   if FND_API.To_Boolean( p_simulate)
   then
      ROLLBACK to Create_Advice_PVT;

   elsif FND_API.To_Boolean( p_commit)
   then
      commit work;
   end if;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
   (
      p_count		=> p_msg_count,
      p_data		=> p_msg_data
   );

  end if; 		-- Bug 2593437


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Create_Advice_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Create_Advice_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Create_Advice_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      if FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      then
         FND_MSG_PUB.Add_Exc_Msg
         (
            G_FILE_NAME,
            G_PKG_NAME,
            l_api_name
         );
      end if;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

end Create_Advice;





PROCEDURE create_advice_line(
   p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_advice_header_id		IN	NUMBER,
   p_advice_date_time		IN	DATE,
   p_advice_status_code		IN	VARCHAR2,
   p_external_reference_1	IN	VARCHAR2 default NULL,
   p_external_reference_2	IN	VARCHAR2 default NULL,
   p_external_reference_3	IN	VARCHAR2 default NULL,
   p_external_reference_4	IN	VARCHAR2 default NULL,
   p_external_reference_5	IN	VARCHAR2 default NULL,
   p_external_reference_6	IN	VARCHAR2 default NULL,
   p_internal_reference_1	IN	VARCHAR2 default NULL,
   p_internal_reference_2	IN	VARCHAR2 default NULL,
   p_internal_reference_3	IN	VARCHAR2 default NULL,
   p_internal_reference_4	IN	VARCHAR2 default NULL,
   p_internal_reference_5	IN	VARCHAR2 default NULL,
   p_internal_reference_6	IN	VARCHAR2 default NULL,
   p_advo_message_code		IN	VARCHAR2 default NULL,
   p_advo_message_desc		IN	VARCHAR2 default NULL,
   p_advo_data_bad		IN	VARCHAR2 default NULL,
   p_advo_data_good		IN	VARCHAR2 default NULL
)
IS
   l_api_name		CONSTANT VARCHAR2(30) := 'Create_Advice_Line';
   l_api_version_number	CONSTANT NUMBER	      := 1.0;
   l_return_status		 VARCHAR2(10);
   l_document_exists             VARCHAR2(1):='N';	-- Bug 2593437

BEGIN

   begin			-- Bug 2593437
     select 'Y'
     into l_document_exists
     from ece_advo_headers
     where advice_header_id=p_advice_header_id;
   exception
    when others then
        null;
   end;

  if l_document_exists = 'Y' then             -- Bug 2593437


   -- Standard Start of API savepoint

   SAVEPOINT Create_Advice_Line_PVT;

   -- Standard call to check for call compatibility.

   if NOT FND_API.Compatible_API_Call
   (
	l_api_version_number,
	p_api_version_number,
	l_api_name,
	G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success

   p_return_status := FND_API.G_RET_STS_SUCCESS;


	insert into ECE_ADVO_DETAILS(
		ADVICE_DETAIL_ID   ,
		ADVICE_HEADER_ID   ,
		ADVO_DATE_TIME	   ,
		ADVO_STATUS_CODE   ,
		EXTERNAL_REFERENCE1,
		EXTERNAL_REFERENCE2,
		EXTERNAL_REFERENCE3,
		EXTERNAL_REFERENCE4,
		EXTERNAL_REFERENCE5,
		EXTERNAL_REFERENCE6,
		INTERNAL_REFERENCE1,
		INTERNAL_REFERENCE2,
		INTERNAL_REFERENCE3,
		INTERNAL_REFERENCE4,
		INTERNAL_REFERENCE5,
		INTERNAL_REFERENCE6,
		ADVO_MESSAGE_CODE  ,
		ADVO_MESSAGE_DESC  ,
		ADVO_DATA_BAD	   ,
		ADVO_DATA_GOOD)
	values(
		ece_advo_details_s.nextval,
		p_advice_header_id	 ,
		p_advice_date_time	 ,
		p_advice_status_code	 ,
		p_external_reference_1,
		p_external_reference_2,
		p_external_reference_3,
		p_external_reference_4,
		p_external_reference_5,
		p_external_reference_6,
		p_internal_reference_1,
		p_internal_reference_2,
		p_internal_reference_3,
		p_internal_reference_4,
		p_internal_reference_5,
		p_internal_reference_6,
		p_advo_message_code	 ,
		p_advo_message_desc	 ,
		p_advo_data_bad	 ,
		p_advo_data_good);



   -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;

   -- Standard check of p_simulate and p_commit parameters

   if FND_API.To_Boolean( p_simulate)
   then
      ROLLBACK to Create_Advice_Line_PVT;

   elsif FND_API.To_Boolean( p_commit)
   then
      commit work;
   end if;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
   (
      p_count		=> p_msg_count,
      p_data		=> p_msg_data
   );

  end if;		-- Bug 2593437

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Create_Advice_Line_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Create_Advice_Line_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Create_Advice_Line_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      if FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      then
         FND_MSG_PUB.Add_Exc_Msg
         (
            G_FILE_NAME,
            G_PKG_NAME,
            l_api_name
         );
      end if;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

end Create_Advice_Line;



END;


/
