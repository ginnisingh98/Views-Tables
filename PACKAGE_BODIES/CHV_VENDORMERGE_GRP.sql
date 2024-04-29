--------------------------------------------------------
--  DDL for Package Body CHV_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_VENDORMERGE_GRP" AS
/* $Header: chvgvdrb.pls 120.0 2005/07/29 22:38:50 atsingh noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='CHV_VendorMerge_GRP';

Procedure Merge_Vendor( p_api_version        IN   NUMBER,
	                p_init_msg_list      IN   VARCHAR2 default
                                             FND_API.G_FALSE,
	                p_commit             IN   VARCHAR2 default
                                             FND_API.G_FALSE,
	                p_validation_level   IN   NUMBER  :=
                                             FND_API.G_VALID_LEVEL_FULL,
	                x_return_status      OUT NOCOPY VARCHAR2,
	                x_msg_count          OUT NOCOPY NUMBER,
	                x_msg_data           OUT NOCOPY VARCHAR2,
	                p_vendor_id          IN   NUMBER,
	                p_vendor_site_id     IN   NUMBER,
	                p_dup_vendor_id      IN   NUMBER,
	                p_dup_vendor_site_id IN   NUMBER         )

 IS

        l_api_name	CONSTANT VARCHAR2(30)	:= 'Merge_Vendor';
        l_api_version   CONSTANT NUMBER 	:= 1.0;
        l_row_count	NUMBER;

 BEGIN

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;



        -- Check for call compatibility.
         IF NOT FND_API.Compatible_API_Call ( l_api_version  ,
                                              p_api_version  ,
                                              l_api_name     ,
                                              G_PKG_NAME             )
         THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- Initialize API message list if necessary.
         -- Initialize message list if p_init_msg_list is set to TRUE.
         IF FND_API.to_Boolean( p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
         END IF;

         -- modify  CHV_SCHEDULE_HEADERS
         UPDATE CHV_SCHEDULE_HEADERS
         SET    vendor_id      = p_vendor_id,
                vendor_site_id = p_vendor_site_id
         WHERE  vendor_id      = p_dup_vendor_id
         AND    vendor_site_id = p_dup_vendor_site_id ;

         -- Prepare message name
         FND_MESSAGE.SET_NAME('CHV', 'CHV_SCHEDULE_HEADERS');
	 IF SQL%FOUND THEN
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		l_row_count := SQL%ROWCOUNT;
	 ELSE

		l_row_count := 0;
	 END IF;
	 FND_MESSAGE.SET_TOKEN('ROWS_UPDATED',l_row_count);
	 -- Add message to API message list.
	 FND_MSG_PUB.Add;



         -- modify  CHV_CUM_ADJUSTMENTS
         UPDATE CHV_CUM_ADJUSTMENTS
         SET    vendor_id      = p_vendor_id,
             	vendor_site_id = p_vendor_site_id
         WHERE  vendor_id      = p_dup_vendor_id
         AND    vendor_site_id = p_dup_vendor_site_id ;

         -- Prepare message name
         FND_MESSAGE.SET_NAME('CHV','CHV_CUM_ADJUSTMENTS');
	 IF SQL%FOUND THEN
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		l_row_count := SQL%ROWCOUNT;
	 ELSE

		l_row_count := 0;
	END IF;
	FND_MESSAGE.SET_TOKEN('ROWS_UPDATED',l_row_count);
	-- Add message to API message list.
	FND_MSG_PUB.Add;

	-- Get message count and if 1, return message data.
	FND_MSG_PUB.Count_And_Get
	(  	p_count         	=>      x_msg_count,
		p_data          	=>      x_msg_data
	);




 EXCEPTION

                WHEN OTHERS THEN
                ROLLBACK;

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		FND_MSG_PUB.Count_And_Get
    		       ( p_count         =>      x_msg_count,
        		 p_data          =>      x_msg_data
    		       );

         END Merge_Vendor;

         END CHV_VendorMerge_GRP ;


/
