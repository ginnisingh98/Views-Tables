--------------------------------------------------------
--  DDL for Package Body EC_TRADING_PARTNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_TRADING_PARTNER_PVT" AS
-- $Header: ECVTPXFB.pls 120.4 2006/04/27 04:23:00 arsriniv ship $

--  ***********************************************
--	procedure Get_TP_Address
--
--  WARNING: This procedure is overloaded
--  ***********************************************
PROCEDURE Get_TP_Address
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_translator_code		IN	VARCHAR2,
   p_location_code_ext		IN	VARCHAR2,
   p_info_type			IN	VARCHAR2,
   p_entity_id			OUT NOCOPY	NUMBER,
   p_entity_address_id		OUT NOCOPY	NUMBER
)
IS
   l_api_name		CONSTANT VARCHAR2(30) := 'Get_TP_Address';
   l_api_version_number	CONSTANT NUMBER	      := 1.0;
   l_return_status		 VARCHAR2(10);

   l_entity_id			NUMBER;
   l_entity_address_id		NUMBER;

cursor ra_add is
       select cas.cust_account_id ,
              cas.cust_acct_site_id
        from  hz_cust_acct_sites cas,
	      hz_cust_accounts ca,
	      hz_parties pt,
	      ece_tp_details etd
	where
	      etd.translator_code = p_translator_code
	  and cas.ece_tp_location_code = p_location_code_ext
	  and etd.tp_header_id = cas.tp_header_id
	  and cas.cust_account_id   = ca.cust_account_id
          and ca.party_id = pt.party_id;

cursor po_site is
       select pv.vendor_id, pvs.vendor_site_id
         from po_vendors pv, po_vendor_sites pvs,
--              ece_tp_headers ec,
              ece_tp_details etd
        where
              etd.translator_code = p_translator_code
--          and etd.tp_header_id = ec.tp_header_id
          and pvs.ece_tp_location_code = p_location_code_ext
          and etd.tp_header_id = pvs.tp_header_id
          and pvs.vendor_id = pv.vendor_id;

cursor ap_bank is
       select cbb.branch_party_id
         from ce_bank_branches_v cbb,
              ece_tp_details etd,
              hz_contact_points hcp
        where
              etd.translator_code          = p_translator_code
          and hcp.edi_ece_tp_location_code = p_location_code_ext
          and hcp.edi_tp_header_id         = etd.tp_header_id
          and hcp.owner_table_id           = cbb.branch_party_id
          and hcp.owner_table_name         = 'HZ_PARTIES'
          and hcp.contact_point_type       = 'EDI';

BEGIN

   EC_DEBUG.PUSH('EC_Trading_Partner_PVT.Get_TP_Address');
   EC_DEBUG.PL(3, 'API version : ',p_api_version_number);
   EC_DEBUG.PL(3, 'p_init_msg_list: ',p_init_msg_list);
   EC_DEBUG.PL(3, 'p_simulate: ',p_simulate);
   EC_DEBUG.PL(3, 'p_validation_level: ',p_validation_level);
   EC_DEBUG.PL(3, 'p_translator_code: ',p_translator_code);
   EC_DEBUG.PL(3, 'p_location_code_ext: ',p_location_code_ext);
   EC_DEBUG.PL(3, 'p_info_type: ',p_info_type);


   -- Standard Start of API savepoint

   SAVEPOINT Get_TP_Address_PVT;

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


   if ( p_info_type = EC_Trading_Partner_PVT.G_CUSTOMER)
   then
      for addr in ra_add
      loop
         l_entity_id := addr.cust_account_id;
         EC_DEBUG.PL(3, 'l_entity_id: ',l_entity_id);
         l_entity_address_id := addr.cust_acct_site_id;
         EC_DEBUG.PL(3, 'l_entity_address_id: ',l_entity_address_id);
      end loop;

   elsif (p_info_type = EC_Trading_Partner_PVT.G_SUPPLIER)
   then
      for site in po_site
      loop
         l_entity_id := site.vendor_id;
         EC_DEBUG.PL(3, 'l_entity_id: ',l_entity_id);
         l_entity_address_id := site.vendor_site_id;
         EC_DEBUG.PL(3, 'l_entity_address_id: ',l_entity_address_id);
      end loop;

   elsif (p_info_type = EC_Trading_Partner_PVT.G_BANK)
   then
      for bank in ap_bank
      loop
         l_entity_id := -1;
         EC_DEBUG.PL(3, 'l_entity_id: ',l_entity_id);
         l_entity_address_id := bank.branch_party_id;
         EC_DEBUG.PL(3, 'l_entity_address_id: ',l_entity_address_id);
      end loop;
   else
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if l_entity_id is NULL
     and l_entity_address_id is NULL
   then
      p_return_status := EC_Trading_Partner_PVT.G_TP_NOT_FOUND;
      fnd_message.set_name('EC','ECE_TP_NOT_FOUND');
      p_msg_data := fnd_message.get;
   else
      p_entity_id := l_entity_id;
      EC_DEBUG.PL(3, 'p_entity_id: ',p_entity_id);
      p_entity_address_id := l_entity_address_id;
      EC_DEBUG.PL(3, 'p_entity_address_id: ',p_entity_address_id);
   end if;


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
      ROLLBACK to Get_TP_Address_PVT;

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

   EC_DEBUG.POP('EC_Trading_Partner_PVT.Get_TP_Address');
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Get_TP_Address_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Get_TP_Address_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN
      EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
      EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
      Rollback to Get_TP_Address_PVT;
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

end Get_TP_Address;


--  ***********************************************
--	procedure Get_TP_Address_Ref
--
--  Overload this procedure per request from
--  the automotive team
--  ***********************************************
PROCEDURE Get_TP_Address_Ref
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
--   p_translator_code		IN	VARCHAR2,
--   p_location_code_ext		IN	VARCHAR2,
   p_reference_ext1		IN	VARCHAR2,
   p_reference_ext2		IN	VARCHAR2,
   p_info_type			IN	VARCHAR2,
   p_entity_id			OUT NOCOPY	NUMBER,
   p_entity_address_id		OUT NOCOPY	NUMBER
)
IS
   l_api_name		CONSTANT VARCHAR2(30) := 'Get_TP_Address_Ref';
   l_api_version_number	CONSTANT NUMBER	      := 1.0;
   l_return_status		 VARCHAR2(10);

   l_entity_id			NUMBER;
   l_entity_address_id		NUMBER;

cursor ra_add is
       select cas.cust_account_id ,
                         cas.cust_acct_site_id
		  from           hz_cust_acct_sites cas,
		                 hz_cust_accounts ca,
		                 hz_parties pt,
		                 ece_tp_headers eth
                  where
	                eth.tp_reference_ext1 = p_reference_ext1
	            and eth.tp_reference_ext2 = p_reference_ext2
                    and eth.tp_header_id      = cas.tp_header_id
		    and cas.cust_account_id   = ca.cust_account_id
		    and ca.party_id = pt.party_id;

cursor po_site is
       select pv.vendor_id, pvs.vendor_site_id
         from po_vendors pv, po_vendor_sites pvs,
              ece_tp_headers eth
        where
	      eth.tp_reference_ext1 = p_reference_ext1
	  and eth.tp_reference_ext2 = p_reference_ext2
          and eth.tp_header_id = pvs.tp_header_id
          and pvs.vendor_id = pv.vendor_id;

cursor ap_bank is
       select cbb.branch_party_id
         from ce_bank_branches_v cbb,
              ece_tp_headers eth,
              hz_contact_points hcp
        where
	      eth.tp_reference_ext1 = p_reference_ext1
	  and eth.tp_reference_ext2 = p_reference_ext2
          and eth.tp_header_id = hcp.edi_tp_header_id
          and hcp.owner_table_id = cbb.branch_party_id
          and hcp.owner_table_name = 'HZ_PARTIES'
          and hcp.contact_point_type = 'EDI';

BEGIN

   EC_DEBUG.PUSH('EC_Trading_Partner_PVT.Get_TP_Address_Ref');
   EC_DEBUG.PL(3, 'API version : ',p_api_version_number);
   EC_DEBUG.PL(3, 'p_init_msg_list: ',p_init_msg_list);
   EC_DEBUG.PL(3, 'p_simulate: ',p_simulate);
   EC_DEBUG.PL(3, 'p_commit: ',p_commit);
   EC_DEBUG.PL(3, 'p_validation_level: ',p_validation_level);
   EC_DEBUG.PL(3, 'p_reference_ext1: ',p_reference_ext1);
   EC_DEBUG.PL(3, 'p_reference_ext2: ',p_reference_ext2);
   EC_DEBUG.PL(3, 'p_info_type: ',p_info_type);

   -- Standard Start of API savepoint

   SAVEPOINT Get_TP_Address_Ref_PVT;

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


   if ( p_info_type = EC_Trading_Partner_PVT.G_CUSTOMER)
   then
      for addr in ra_add
      loop
         l_entity_id := addr.cust_account_id;
         l_entity_address_id := addr.cust_acct_site_id;
         EC_DEBUG.PL(3, 'l_entity_id: ',l_entity_id);
         EC_DEBUG.PL(3, 'l_entity_address_id: ',l_entity_address_id);
      end loop;

   elsif (p_info_type = EC_Trading_Partner_PVT.G_SUPPLIER)
   then
      for site in po_site
      loop
         l_entity_id := site.vendor_id;
         l_entity_address_id := site.vendor_site_id;
         EC_DEBUG.PL(3, 'l_entity_id: ',l_entity_id);
         EC_DEBUG.PL(3, 'l_entity_address_id: ',l_entity_address_id);
      end loop;

   elsif (p_info_type = EC_Trading_Partner_PVT.G_BANK)
   then
      for bank in ap_bank
      loop
         l_entity_id := -1;
         l_entity_address_id := bank.branch_party_id;
         EC_DEBUG.PL(3, 'l_entity_id: ',l_entity_id);
         EC_DEBUG.PL(3, 'l_entity_address_id: ',l_entity_address_id);
      end loop;
   else
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if l_entity_id is NULL
     and l_entity_address_id is NULL
   then
      p_return_status := EC_Trading_Partner_PVT.G_TP_NOT_FOUND;
      fnd_message.set_name('EC','ECE_TP_NOT_FOUND');
      p_msg_data := fnd_message.get;
   else
      p_entity_id := l_entity_id;
      p_entity_address_id := l_entity_address_id;
   end if;

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
      ROLLBACK to Get_TP_Address_Ref_PVT;

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

   EC_DEBUG.POP('EC_Trading_Partner_PVT.Get_TP_Address_Ref');
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Get_TP_Address_Ref_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Get_TP_Address_Ref_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
      EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
      Rollback to Get_TP_Address_Ref_PVT;
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

end Get_TP_Address_Ref;

--  ***********************************************
--	procedure Get_TP_Location_Code
--  ***********************************************
PROCEDURE Get_TP_Location_Code
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_entity_address_id		IN	NUMBER,
   p_info_type			IN	VARCHAR2,
   p_location_code_ext		OUT NOCOPY	VARCHAR2,
   p_reference_ext1		OUT NOCOPY	VARCHAR2,
   p_reference_ext2		OUT NOCOPY	VARCHAR2
)
IS
   l_api_name		CONSTANT VARCHAR2(30) := 'Get_TP_Location_Code';
   l_api_version_number	CONSTANT NUMBER	      := 1.0;
   l_return_status		 VARCHAR2(10);

   l_location_code_ext		VARCHAR2(50);

cursor ra_add is
       select
                  cas.ece_tp_location_code,
                  ec.tp_reference_ext1,
                  ec.tp_reference_ext2
		  from           hz_cust_acct_sites cas,
		                 ece_tp_headers ec
                  where

                    ec.tp_header_id      = cas.tp_header_id
		    and cas.cust_acct_site_id = p_entity_address_id;

cursor po_site is
        select pvs.ece_tp_location_code,
	       ec.tp_reference_ext1,
	       ec.tp_reference_ext2
          from ece_tp_headers ec, po_vendor_sites pvs
         where
               pvs.vendor_site_id = p_entity_address_id
           and pvs.tp_header_id = ec.tp_header_id;

cursor ap_bank is
        select hcp.edi_ece_tp_location_code,
	       ec.tp_reference_ext1,
	       ec.tp_reference_ext2
          from ece_tp_headers ec,
               ce_bank_branches_v cbb,
               hz_contact_points hcp
         where
               cbb.branch_party_id = p_entity_address_id
           and hcp.edi_tp_header_id = ec.tp_header_id
           and hcp.owner_table_id   = cbb.branch_party_id
           and hcp.owner_table_name = 'HZ_PARTIES'
           and hcp.contact_point_type     = 'EDI';

BEGIN

   EC_DEBUG.PUSH('EC_Trading_Partner_PVT.Get_TP_Location_Code');
   EC_DEBUG.PL(3, 'API version : ',p_api_version_number);
   EC_DEBUG.PL(3, 'p_init_msg_list: ',p_init_msg_list);
   EC_DEBUG.PL(3, 'p_simulate: ',p_simulate);
   EC_DEBUG.PL(3, 'p_commit: ',p_commit);
   EC_DEBUG.PL(3, 'p_validation_level: ',p_validation_level);
   EC_DEBUG.PL(3, 'p_entity_address_id: ',p_entity_address_id);
   EC_DEBUG.PL(3, 'p_info_type: ',p_info_type);
   -- Standard Start of API savepoint

   SAVEPOINT Get_TP_Location_Code_PVT;

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


   if ( p_info_type = EC_Trading_Partner_PVT.G_CUSTOMER)
   then
      for addr in ra_add loop
         l_location_code_ext := addr.ece_tp_location_code;
         p_reference_ext1 := addr.tp_reference_ext1;
         p_reference_ext2 := addr.tp_reference_ext2;
         EC_DEBUG.PL(3, 'l_location_code_ext: ',l_location_code_ext);
         EC_DEBUG.PL(3, 'addr.tp_reference_ext1',addr.tp_reference_ext1);
         EC_DEBUG.PL(3, 'addr.tp_reference_ext2',addr.tp_reference_ext2);
      end loop;


   elsif (p_info_type = EC_Trading_Partner_PVT.G_SUPPLIER)
   then
      for site in po_site loop
         l_location_code_ext := site.ece_tp_location_code;
         p_reference_ext1 := site.tp_reference_ext1;
         p_reference_ext2 := site.tp_reference_ext2;
         EC_DEBUG.PL(3, 'site.tp_reference_ext1',site.tp_reference_ext1);
         EC_DEBUG.PL(3, 'site.tp_reference_ext2',site.tp_reference_ext2);
      end loop;

   elsif (p_info_type = EC_Trading_Partner_PVT.G_BANK)
   then
      for bank in ap_bank loop
         l_location_code_ext := bank.edi_ece_tp_location_code;
         p_reference_ext1 := bank.tp_reference_ext1;
         p_reference_ext2 := bank.tp_reference_ext2;
         EC_DEBUG.PL(3, 'bank.tp_reference_ext1',bank.tp_reference_ext1);
         EC_DEBUG.PL(3, 'bank.tp_reference_ext2',bank.tp_reference_ext2);
      end loop;
   else
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if l_location_code_ext is NULL
   then
      p_return_status := EC_Trading_Partner_PVT.G_TP_NOT_FOUND;
      fnd_message.set_name('EC','ECE_TP_NOT_FOUND');
      p_msg_data := fnd_message.get;
      EC_DEBUG.PL(3, 'p_msg_data',p_msg_data);
   else
      p_location_code_ext := l_location_code_ext;
      EC_DEBUG.PL(3, 'l_location_code_ext',l_location_code_ext);
   end if;

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
      ROLLBACK to Get_TP_Location_Code_PVT;

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

EC_DEBUG.POP('EC_Trading_Partner_PVT.Get_TP_Location_Code');
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Get_TP_Location_Code_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Get_TP_Location_Code_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN
      EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
      EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

      Rollback to Get_TP_Location_Code_PVT;
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

end Get_TP_Location_Code;

FUNCTION IS_ENTITY_ENABLED
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_transaction_type		IN	VARCHAR2,
   p_transaction_subtype	IN      VARCHAR2,
   p_entity_type		IN      VARCHAR2,
   p_entity_id			IN      NUMBER
) RETURN BOOLEAN
IS
   l_api_name		    CONSTANT VARCHAR2(30)     := 'IS_ENTITY_ENABLED';
   l_api_version_number	    CONSTANT NUMBER	      := 1.0;
   l_return_status	    VARCHAR2(10);


x_tp_detail_id NUMBER;

cursor type_customer is
	select tpd.tp_detail_id
	from   ece_tp_details tpd,hz_cust_acct_sites cas
	where  tpd.tp_header_id = cas.tp_header_id
	and    tpd.document_id = p_transaction_type
	and    tpd.document_type = nvl(p_transaction_subtype,tpd.document_type)
	and    cas.cust_acct_site_id = p_entity_id;

cursor type_supplier is
	select tpd.tp_detail_id
	from   ece_tp_details tpd,po_vendor_sites povs
	where  tpd.tp_header_id = povs.tp_header_id
	and    tpd.document_id = p_transaction_type
	and    tpd.document_type = nvl(p_transaction_subtype,tpd.document_type)
	and    povs.vendor_site_id = p_entity_id;

cursor type_bank is
	select tpd.tp_detail_id
	from   ece_tp_details tpd,
               ce_bank_branches_v cbb,
               hz_contact_points hcp
	where  tpd.tp_header_id = hcp.edi_tp_header_id
	and    tpd.document_id = p_transaction_type
	and    tpd.document_type = nvl(p_transaction_subtype,tpd.document_type)
	and    cbb.branch_party_id = p_entity_id
        and    cbb.branch_party_id = hcp.owner_table_id
        and    hcp.owner_table_name = 'HZ_PARTIES'
        and    hcp.contact_point_type     = 'EDI';

cursor type_location is
	select tpd.tp_detail_id
	from   ece_tp_details tpd,hr_locations hrl
	where  tpd.tp_header_id = hrl.tp_header_id
	and    tpd.document_id = p_transaction_type
	and    tpd.document_type = nvl(p_transaction_subtype,tpd.document_type)
	and    hrl.location_id = p_entity_id;

BEGIN

   EC_DEBUG.PUSH('EC_Trading_Partner_PVT.IS_ENTITY_ENABLED');
   EC_DEBUG.PL(3, 'p_transaction_type: ',p_transaction_type);
   EC_DEBUG.PL(3, 'p_transaction_subtype: ',p_transaction_subtype);
   EC_DEBUG.PL(3, 'p_entity_type: ',p_entity_type);
   EC_DEBUG.PL(3, 'p_entity_id: ',p_entity_id);

   SAVEPOINT Get_TP_Location_Code_PVT;

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


   if ( p_entity_type = EC_Trading_Partner_PVT.G_CUSTOMER)
   then
      for addr in type_customer loop
         x_tp_detail_id := addr.tp_detail_id;
         EC_DEBUG.PL(3, 'x_tp_detail_id: ',x_tp_detail_id);
      end loop;
   elsif (p_entity_type = EC_Trading_Partner_PVT.G_SUPPLIER)
   then
      for addr in type_supplier loop
         x_tp_detail_id := addr.tp_detail_id;
         EC_DEBUG.PL(3, 'x_tp_detail_id: ',x_tp_detail_id);
      end loop;
   elsif (p_entity_type = EC_Trading_Partner_PVT.G_BANK)
   then
      for addr in type_bank loop
         x_tp_detail_id := addr.tp_detail_id;
         EC_DEBUG.PL(3, 'x_tp_detail_id: ',x_tp_detail_id);
      end loop;
   elsif (p_entity_type = EC_Trading_Partner_PVT.G_LOCATION)
   then
      for addr in type_location loop
         x_tp_detail_id := addr.tp_detail_id;
         EC_DEBUG.PL(3, 'x_tp_detail_id: ',x_tp_detail_id);
      end loop;
   else
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
end if;

if x_tp_detail_id is null
 then
	RETURN FALSE;
 else
	RETURN TRUE;
end if;

   -- Standard check of p_simulate and p_commit parameters

   if FND_API.To_Boolean( p_simulate)
   then
      ROLLBACK to Get_TP_Location_Code_PVT;

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

EC_DEBUG.POP('EC_Trading_Partner_PVT.IS_ENTITY_ENABLED');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Get_TP_Location_Code_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Get_TP_Location_Code_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN
      EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
      EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

      Rollback to Get_TP_Location_Code_PVT;
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


END IS_ENTITY_ENABLED;


END EC_Trading_Partner_PVT;


/
