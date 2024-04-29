--------------------------------------------------------
--  DDL for Package Body XLE_THIRDPARTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_THIRDPARTY" AS
/* $Header: xlethpab.pls 120.10 2005/11/25 11:31:17 bsilveir ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):=' XLE_THIRDPARTY';


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Get_LegalInformation		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Get Business Entity's legal information 				     	|
 |	   --> Legal Name							|
 |         --> Registration Number						|
 |         --> Date Of Birth							|
 |         --> Place Of Birth							|
 |	   --> Company Activity Code						|
 |	   --> Legal Address							|
 |									  	|
 | SCOPE - PUBLIC     								|
 |                                                                          	|
 |                                                                           	|
 | MODIFICATION HISTORY                                                      	|
 |     17-JUN-2004  	Yvonne RAKOTONIRAINY      	Created	             	|
 |									  	|
 +==============================================================================*/

PROCEDURE Get_LegalInformation(

  	--   *****  Standard API parameters *****
 	p_api_version           	IN	NUMBER,
  	p_init_msg_list	        	IN	VARCHAR2,
  	p_commit			IN	VARCHAR2,
  	x_return_status         	OUT     NOCOPY  VARCHAR2,
  	x_msg_count	        	OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,

	--   *****  Business Entity information parameters *****
	p_business_entity_type          IN      VARCHAR2,
	p_business_entity_id            IN      NUMBER,
	p_business_entity_site_id       IN      NUMBER,
	p_country               	IN      VARCHAR2,
	p_legal_function	        IN      VARCHAR2,
        p_legislative_category          IN      VARCHAR2,
	x_legal_information_rec		OUT     NOCOPY LegalInformation_Rec)


IS

l_api_name	    CONSTANT VARCHAR2(30) 	:='Get_LegalInformation';
l_api_version       CONSTANT NUMBER 		:=1.0;


--   *****  Business entity type is SUPPLIER *****
-- For Italy
CURSOR  case1_legal_information_cur IS
  SELECT pvs.vendor_site_code,
  	 pv.num_1099,
	 pv.global_attribute2,
	 pv.global_attribute3,
	 pv.standard_industry_class,
	 pvs.address_line1,
         pvs.address_line2,
         pvs.address_line3,
         pvs.city,
         pvs.zip,
	 pvs.province,
	 pvs.country,
	 pvs.state
  FROM   PO_VENDOR_SITES_ALL pvs,
 	 PO_VENDORS pv
  WHERE  pv.vendor_id=p_business_entity_id
 	 AND pvs.vendor_site_id=p_business_entity_site_id
	 AND pvs.country=p_country
	 AND pv.vendor_id=pvs.vendor_id;

-- For Spain, Greece
CURSOR  case2_legal_information_cur IS
  SELECT decode(pvs.country,'ES',pv.vendor_name,'GR',pvs.vendor_site_code),
	 pv.num_1099,
	 pv.global_attribute2,
	 pv.global_attribute3,
	 pv.standard_industry_class,
	 pvs.address_line1,
  	 pvs.address_line2,
         pvs.address_line3,
         pvs.city,
         pvs.zip,
	 pvs.province,
	 pvs.country,
         pvs.state
  FROM   PO_VENDOR_SITES_ALL pvs,
	 PO_VENDORS pv
  WHERE  pv.vendor_id=p_business_entity_id
         AND pvs.tax_reporting_site_flag='Y'
	 AND pvs.country=p_country
	 AND pv.vendor_id=pvs.vendor_id;



BEGIN

  x_msg_count				:=	NULL;
  x_msg_data				:=	NULL;


  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
  					p_api_version,
   	       	    	                l_api_name,
		    	                G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*-----------------------------------------------+
   |   ========  START OF API BODY  ============    |
   +-----------------------------------------------*/

  --   *****  Business entity type is SUPPLIER *****
  IF p_business_entity_type='SUPPLIER' THEN

    -- Legal Information for Italy
    IF p_country='IT' THEN

      OPEN case1_legal_information_cur;
      FETCH case1_legal_information_cur INTO
      	x_legal_information_rec.legal_name,
        x_legal_information_rec.registration_number,
        x_legal_information_rec.date_of_birth,
        x_legal_information_rec.place_of_birth,
	x_legal_information_rec.company_activity_code,
        x_legal_information_rec.address_line1,
        x_legal_information_rec.address_line2,
        x_legal_information_rec.address_line3,
        x_legal_information_rec.city,
        x_legal_information_rec.zip,
        x_legal_information_rec.province,
        x_legal_information_rec.country,
	x_legal_information_rec.state;

        IF case1_legal_information_cur%NOTFOUND THEN
	  --specific xle message under creation fnd message used as workaround
          FND_MESSAGE.SET_NAME('FND','FND_GRANTS_RECORD_NOT_FOUND');
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


      CLOSE case1_legal_information_cur;


    -- Legal Information for Spain and Greece
    ELSIF p_country in ('ES','GR') THEN

      OPEN case2_legal_information_cur;
      FETCH case2_legal_information_cur INTO
      	x_legal_information_rec.legal_name,
        x_legal_information_rec.registration_number,
        x_legal_information_rec.date_of_birth,
        x_legal_information_rec.place_of_birth,
	x_legal_information_rec.company_activity_code,
        x_legal_information_rec.address_line1,
        x_legal_information_rec.address_line2,
        x_legal_information_rec.address_line3,
        x_legal_information_rec.city,
        x_legal_information_rec.zip,
        x_legal_information_rec.province,
        x_legal_information_rec.country,
	x_legal_information_rec.state;

        IF case2_legal_information_cur%NOTFOUND THEN
	  --specific xle message under creation fnd message used as workaround
          FND_MESSAGE.SET_NAME('FND','FND_GRANTS_RECORD_NOT_FOUND');
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


      CLOSE case2_legal_information_cur;

    END IF;

  END IF;


  -- End of API body.

  -- Standard call to get message count and if count is 1,
  --get message info.
  FND_MSG_PUB.Count_And_Get( 	p_count         	=>      x_msg_count ,
  				p_data          	=>      x_msg_data );

 EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get(  p_count         	=>      x_msg_count,
        		               p_data          	=>      x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	   FND_MSG_PUB.Count_And_Get(p_count         	=>      x_msg_count,
                                     p_data         	=>      x_msg_data);
      WHEN OTHERS THEN
    	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      	  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
    	    			     l_api_name);
    	  END IF;
    	  FND_MSG_PUB.Count_And_Get( p_count         	=>      x_msg_count,
        		             p_data          	=>      x_msg_data );


END Get_LegalInformation;


Procedure Get_TP_VATRegistration_PTY
   (
    p_api_version           IN	NUMBER,
  	p_init_msg_list	     	IN	VARCHAR2,
  	p_commit		        IN	VARCHAR2,
  	p_effective_date        IN  zx_registrations.effective_from%Type,
  	x_return_status         OUT NOCOPY  VARCHAR2,
  	x_msg_count		        OUT	NOCOPY NUMBER,
	x_msg_data		        OUT	NOCOPY VARCHAR2,
	p_party_id              IN  NUMBER,
	p_party_type            IN  VARCHAR2,
	x_registration_number   OUT NOCOPY  NUMBER
   )
   IS

   l_api_name			CONSTANT VARCHAR2(30):= 'Get_TP_VATRegistration_PTY';
   l_api_version        CONSTANT NUMBER := 1.0;
   l_commit             VARCHAR2(100);
   l_init_msg_list     VARCHAR2(100);


  BEGIN


    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
	  l_init_msg_list := p_init_msg_list;
    END IF;

    IF p_commit IS NULL THEN
      l_commit := FND_API.G_FALSE;
    ELSE
      l_commit := p_commit;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body


	  /* x_registration_number := ZX_TCM_CONTROL_PKG.Get_Default_Tax_Reg (
			   							p_party_id,
 								        p_party_type,
									    p_effective_date,
                                        p_init_msg_list,
								    	x_return_status,
							            x_msg_count,
									    x_msg_data
       ); */



    x_registration_number := ZX_API_PUB.get_default_tax_reg
                                (
                            p_api_version  => 1.0 ,
                            p_init_msg_list => NULL,
                            p_commit=> NULL,
                            p_validation_level => NULL,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data  => x_msg_data,
                            p_party_id => p_party_id,
                            p_party_type => p_party_type,
                            p_effective_date =>p_effective_date );


	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);


EXCEPTION
	WHEN OTHERS THEN
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    x_msg_data := SQLERRM;
END;



END  XLE_THIRDPARTY;

/
