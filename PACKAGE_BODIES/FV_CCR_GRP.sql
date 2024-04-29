--------------------------------------------------------
--  DDL for Package Body FV_CCR_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_CCR_GRP" as
/* $Header: FVGACCRB.pls 120.0.12000000.2 2007/09/28 15:03:33 sasukuma ship $*/

G_PKG_NAME 	CONSTANT VARCHAR2(30):='FV_CCR_GRP';

PROCEDURE FV_IS_CCR
( 	p_api_version      	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
	p_object_id			IN	NUMBER,
	p_object_type		IN VARCHAR2,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
	x_ccr_id			OUT	NOCOPY NUMBER,
	x_out_status		OUT	NOCOPY VARCHAR2,
	x_error_code		OUT NOCOPY NUMBER
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'FV_IS_CCR';
l_api_version          	CONSTANT NUMBER 		:= 1.0;
BEGIN
	IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	 	p_api_version,
   	       	    	 		l_api_name,
		    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( nvl(p_init_msg_list,FND_API.G_FALSE) ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success

	x_return_status := FND_API.G_RET_STS_SUCCESS;


	x_out_status := FND_API.G_FALSE;
	IF(p_object_type = 'S') THEN
		SELECT 	ccr_id
		INTO   	x_ccr_id
		FROM   	fv_ccr_vendors
		WHERE 	nvl(vendor_id,-99) = p_object_id
		AND 	plus_four IS NULL;
	ELSIF(p_object_type = 'B') THEN
		SELECT 	ccr_id
		INTO   	x_ccr_id
		FROM   	fv_ccr_vendors
		WHERE 	nvl(bank_branch_id,-99) = p_object_id;
	ELSIF(p_object_type = 'T') THEN
		SELECT 	ccr_id
		INTO   	x_ccr_id
		FROM   	fv_ccr_orgs fcorg
		WHERE	(nvl(fcorg.pay_site_id,-99)=p_object_id
			OR nvl(fcorg.main_address_site_id,-99)=p_object_id);
	ELSIF(p_object_type = 'A') THEN
		SELECT 	ccr_id
		INTO   	x_ccr_id
		FROM   	fv_ccr_orgs fcorg
		WHERE	nvl(bank_account_id,-99) = p_object_id;
	END IF;
	x_out_status := FND_API.G_TRUE;

	FND_MSG_PUB.Count_And_Get
	(
		p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
 	);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_return_status := FND_API.G_RET_STS_SUCCESS;


	WHEN TOO_MANY_ROWS THEN
		x_error_code := 1;
		x_out_status := FND_API.G_TRUE;
		IF(p_object_type IN ('S','B')) THEN
			x_return_status := FND_API.G_RET_STS_SUCCESS;
		ELSE
			x_return_status := FND_API.G_RET_STS_ERROR ;
		END IF;

		 FND_MESSAGE.SET_NAME('FV', 'FV_CCR_GRP_TOO_MANY_ROWS');
 		 FND_MSG_PUB.ADD;


		 FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);

	WHEN FND_API.G_EXC_ERROR THEN

 	         x_return_status := FND_API.G_RET_STS_ERROR ;

		 FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);

	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
END FV_IS_CCR;




PROCEDURE FV_CCR_REG_STATUS
( 	p_api_version      	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
	p_vendor_site_id	IN	NUMBER,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
	x_ccr_status		OUT	NOCOPY VARCHAR2,
	x_error_code		OUT	NOCOPY NUMBER

)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'FV_CCR_REG_STATUS';
l_api_version           CONSTANT NUMBER 		:= 1.0;


BEGIN

	IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	 	p_api_version,
   	       	    	 		l_api_name,
		    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( nvl(p_init_msg_list,FND_API.G_FALSE) ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	SELECT	fcv.ccr_status
	INTO	x_ccr_status
	FROM 	fv_ccr_vendors fcv, fv_ccr_orgs fco
	WHERE 	fcv.CCR_ID = fco.CCR_ID
	AND	(nvl(fco.pay_site_id,-99)=p_vendor_site_id
			OR nvl(fco.main_address_site_id,-99)=p_vendor_site_id);


	FND_MSG_PUB.Count_And_Get
	(
		p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
 	);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_error_code := 2;
		FND_MESSAGE.SET_NAME('FV','FV_SITE_NOT_CCR');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get
		(
		p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
 		);

		x_return_status := FND_API.G_RET_STS_ERROR ;
	WHEN TOO_MANY_ROWS THEN
		FND_MESSAGE.SET_NAME('FV', 'FV_CCR_GRP_TOO_MANY_ROWS');
 		FND_MSG_PUB.ADD;
		x_error_code := 1;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
    	WHEN FND_API.G_EXC_ERROR THEN

		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
END FV_CCR_REG_STATUS;

PROCEDURE IS_VENDOR_FEDERAL
(
  p_api_version    IN  NUMBER,
  p_init_msg_list  IN  VARCHAR2 DEFAULT NULL,
  p_vendor_id      IN  NUMBER,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2,
  x_federal        OUT NOCOPY VARCHAR2,
  x_error_code     OUT NOCOPY NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30)	:= 'IS_VENDOR_FEDERAL';
  l_api_version CONSTANT NUMBER       := 1.0;
  l_error       VARCHAR2(1024);
  l_vendor_type po_vendors.vendor_type_lookup_code%TYPE;
BEGIN
	-- Check for call compatibility.
  IF NOT fnd_api.compatible_api_call
         (
           p_current_version_number => l_api_version,
           p_caller_version_number  => p_api_version,
           p_api_name               => l_api_name,
           p_pkg_name               => g_pkg_name
         )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

	-- Initialize API message list if necessary.
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT vendor_type_lookup_code
    INTO l_vendor_type
    FROM po_vendors
   WHERE vendor_id = p_vendor_id;

  IF (l_vendor_type = 'FEDERAL') THEN
    x_federal := 'Y';
  ELSE
    x_federal := 'N';
  END IF;

  fnd_msg_pub.count_and_get
  (
    p_count => x_msg_count,
    p_data  => x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN NO_DATA_FOUND THEN
		x_error_code := 2;
		fnd_message.set_name('FV','FV_CCR_INVALID_VENDOR_ID');
		fnd_msg_pub.add;
    fnd_msg_pub.count_and_get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
		x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
    fnd_msg_pub.count_and_get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    l_error := SQLERRM;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF fnd_msg_pub.check_msg_level
       (
         p_message_level => fnd_msg_pub.g_msg_lvl_unexp_error
       )
    THEN
      fnd_msg_pub.add_exc_msg
      (
        p_pkg_name       => g_pkg_name,
        p_procedure_name => l_api_name,
        p_error_text     => l_error
      );
    END IF;
    fnd_msg_pub.count_and_get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
END IS_VENDOR_FEDERAL;


PROCEDURE FV_IS_BANK_ACCOUNT_USES_CCR
( 	p_api_version      	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
	p_vendor_site_id	IN	NUMBER,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
	x_out_status		OUT	NOCOPY VARCHAR2,
	x_error_code		OUT NOCOPY NUMBER
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'FV_IS_BANK_ACCOUNT_USES_CCR';
l_api_version          	CONSTANT NUMBER 		:= 1.0;
l_bank_account_id		NUMBER;
BEGIN
	l_bank_account_id := null;
	IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	 	p_api_version,
   	       	    	 		l_api_name,
		    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( nvl(p_init_msg_list,FND_API.G_FALSE) ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success

	x_return_status := FND_API.G_RET_STS_SUCCESS;


	x_out_status := FND_API.G_FALSE;

	SELECT bank_account_id
	INTO l_bank_account_id
	FROM fv_ccr_orgs
	WHERE pay_site_id = p_vendor_site_id;

	if(l_bank_account_id IS NULL) THEN
		x_out_status := FND_API.G_FALSE;
	else
		x_out_status := FND_API.G_TRUE;
	end if;




	FND_MSG_PUB.Count_And_Get
	(
		p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
 	);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_error_code := 2;


	WHEN TOO_MANY_ROWS THEN
		x_error_code := 1;
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		FND_MESSAGE.SET_NAME('FV', 'FV_CCR_GRP_TOO_MANY_ROWS');
 		FND_MSG_PUB.ADD;


		 FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);

	WHEN FND_API.G_EXC_ERROR THEN

 	         x_return_status := FND_API.G_RET_STS_ERROR ;

		 FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);

	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
END FV_IS_BANK_ACCOUNT_USES_CCR;
--------------------------------------------------------------------
  FUNCTION SELECT_THIRD_PARTY
  (
    p_vendor_site_id NUMBER
  ) RETURN VARCHAR2
  IS
    l_api_version number := 1.0;
    l_msg_count number;
    l_msg_data  varchar2(5000);
    l_ccr_status varchar2(2);
    l_error_code  number;
    l_return_status  varchar2(1);

  BEGIN
    fv_ccr_grp.fv_ccr_reg_status
    (
      p_api_version => l_api_version,
      p_vendor_site_id => p_vendor_site_id,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      x_ccr_status => l_ccr_status,
      x_error_code => l_error_code
    );

    IF (l_ccr_status = 'A') THEN
      RETURN 'Y';
    ELSIF (l_error_code = 2) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  END;

--------------------------------------------------------------------

  FUNCTION  SELECT_BANK_ACCOUNT
  (
    p_bank_account_id IN NUMBER,
    p_vendor_site_id NUMBER
  ) RETURN NUMBER
  IS
    l_api_version number := 1.0;
    l_msg_count number;
    l_msg_data  varchar2(5000);
    l_ccr_status varchar2(2);
    l_error_code  number;
    l_return_status  varchar2(1);
    l_bank_account_id NUMBER;

  BEGIN
    fv_ccr_grp.fv_ccr_reg_status
    (
      p_api_version => l_api_version,
      p_vendor_site_id => p_vendor_site_id,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      x_ccr_status => l_ccr_status,
      x_error_code => l_error_code
    );

    IF (l_ccr_status = 'A') THEN
      BEGIN
        SELECT bank_account_id
          INTO l_bank_account_id
          FROM fv_ccr_orgs fco
         WHERE fco.pay_site_id = p_vendor_site_id;

        IF (l_bank_account_id IS NOT NULL) THEN
          RETURN l_bank_account_id;
        ELSE
          RETURN p_bank_account_id;
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN p_bank_account_id;
        WHEN TOO_MANY_ROWS THEN
          RETURN p_bank_account_id;
      END;
    ELSE
      RETURN p_bank_account_id;
    END IF;
    NULL;
  END;

-------------------------------------------

END FV_CCR_GRP;

/
