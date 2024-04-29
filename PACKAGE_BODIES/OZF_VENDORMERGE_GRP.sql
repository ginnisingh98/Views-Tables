--------------------------------------------------------
--  DDL for Package Body OZF_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_VENDORMERGE_GRP" AS
/* $Header: ozfvmrgb.pls 120.3 2005/09/12 06:15:31 sshivali noship $ */
	G_PKG_NAME      CONSTANT VARCHAR2(30):='OZF_VENDORMERGE_GRP';

	-----------------------------------------------------------------------
	-- PROCEDURE
	--   Merge_Vendor
	--
	-- HISTORY
	--   07/30/2001  sshivali  Created.
	-----------------------------------------------------------------------
	PROCEDURE Merge_Vendor
	(    p_api_version			IN            NUMBER
		,p_init_msg_list		IN            VARCHAR2 default FND_API.G_FALSE
		,p_commit				IN            VARCHAR2 default FND_API.G_FALSE
		,p_validation_level		IN            NUMBER   default FND_API.G_VALID_LEVEL_FULL
		,p_return_status		OUT	NOCOPY    VARCHAR2
		,p_msg_count			OUT	NOCOPY    NUMBER
		,p_msg_data			    OUT	NOCOPY    VARCHAR2
		,p_vendor_id			IN            NUMBER
		,p_dup_vendor_id		IN            NUMBER
		,p_vendor_site_id		IN            NUMBER
		,p_dup_vendor_site_id   IN            NUMBER
		,p_party_id				IN            NUMBER
		,p_dup_party_id		    IN            NUMBER
		,p_party_site_id		IN            NUMBER
		,p_dup_party_site_id    IN            NUMBER
	)
	IS
        l_api_name            CONSTANT VARCHAR2(30) := 'MERGE_VENDOR';
        l_api_version	      CONSTANT NUMBER       := 1.0;
        l_row_count		      NUMBER;
	BEGIN
	    p_return_status := FND_API.G_RET_STS_SUCCESS;

        IF NOT FND_API.Compatible_API_Call (  l_api_version,
                                              p_api_version,
                                              l_api_name,
                                              G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize API message list if necessary.
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
        END IF;

		UPDATE OZF_CLAIMS_ALL
		SET     vendor_id = p_vendor_id,
				vendor_site_id = p_vendor_site_id,
				last_update_date = hz_utility_pub.last_update_date,
				last_updated_by = hz_utility_pub.user_id,
				last_update_login = hz_utility_pub.last_update_login,
				program_application_id = hz_utility_pub.program_application_id,
				program_id = hz_utility_pub.program_id,
				program_update_date = sysdate
		WHERE   vendor_id = p_dup_vendor_id
				AND vendor_site_id = p_dup_vendor_site_id;

		-- Prepare message name
		FND_MESSAGE.SET_NAME('OZF','OZF_VENDOR_MERGE');
		IF SQL%FOUND THEN
		   p_return_status := FND_API.G_RET_STS_SUCCESS;
		   l_row_count := SQL%ROWCOUNT;
		ELSE
		   l_row_count := 0;
		END IF;

		FND_MESSAGE.SET_TOKEN('ROWS_UPDATED',l_row_count);
		FND_MESSAGE.SET_TOKEN('TABLE_NAME','OZF_CLAIMS_ALL');
		-- Add message to API message list.
		FND_MSG_PUB.Add;

		-- Get message count and if 1, return message data.
		FND_MSG_PUB.Count_And_Get
		(  p_count         	=>      p_msg_count,
		   p_data          	=>      p_msg_data
		);

	    IF p_dup_vendor_id <> p_vendor_id THEN
			UPDATE OZF_CLAIMS_HISTORY_ALL
			SET     vendor_id = p_vendor_id,
					vendor_site_id = p_vendor_site_id,
					last_update_date = hz_utility_pub.last_update_date,
					last_updated_by = hz_utility_pub.user_id,
					last_update_login = hz_utility_pub.last_update_login,
					program_application_id = hz_utility_pub.program_application_id,
					program_id = hz_utility_pub.program_id,
					program_update_date = sysdate
			WHERE   vendor_id = p_dup_vendor_id
					AND vendor_site_id = p_dup_vendor_site_id;

			-- Prepare message name
			FND_MESSAGE.SET_NAME('OZF','OZF_VENDOR_MERGE');
			IF SQL%FOUND THEN
			   p_return_status := FND_API.G_RET_STS_SUCCESS;
			   l_row_count := SQL%ROWCOUNT;
			ELSE
			   l_row_count := 0;
			END IF;

			FND_MESSAGE.SET_TOKEN('ROWS_UPDATED',l_row_count);
			FND_MESSAGE.SET_TOKEN('TABLE_NAME','OZF_CLAIMS_HISTORY_ALL');
			-- Add message to API message list.
			FND_MSG_PUB.Add;

			-- Get message count and if 1, return message data.
			FND_MSG_PUB.Count_And_Get
			(  p_count         	=>      p_msg_count,
			   p_data          	=>      p_msg_data
			);

			UPDATE OZF_CLAIMS_INT_ALL
			SET     vendor_id = p_vendor_id,
					vendor_site_id = p_vendor_site_id,
					last_update_date = hz_utility_pub.last_update_date,
					last_updated_by = hz_utility_pub.user_id,
					last_update_login = hz_utility_pub.last_update_login,
					program_application_id = hz_utility_pub.program_application_id,
					program_id = hz_utility_pub.program_id,
					program_update_date = sysdate
			WHERE   vendor_id = p_dup_vendor_id
					AND vendor_site_id = p_dup_vendor_site_id;

			-- Prepare message name
			FND_MESSAGE.SET_NAME('OZF','OZF_VENDOR_MERGE');
			IF SQL%FOUND THEN
			   p_return_status := FND_API.G_RET_STS_SUCCESS;
			   l_row_count := SQL%ROWCOUNT;
			ELSE
			   l_row_count := 0;
			END IF;

			FND_MESSAGE.SET_TOKEN('ROWS_UPDATED',l_row_count);
			FND_MESSAGE.SET_TOKEN('TABLE_NAME','OZF_CLAIMS_INT_ALL');
			-- Add message to API message list.
			FND_MSG_PUB.Add;

			-- Get message count and if 1, return message data.
			FND_MSG_PUB.Count_And_Get
			(  p_count         	=>      p_msg_count,
			   p_data          	=>      p_msg_data
			);

			UPDATE OZF_CUST_TRD_PRFLS_ALL
			SET     vendor_id = p_vendor_id,
					vendor_site_id = p_vendor_site_id,
					last_update_date = hz_utility_pub.last_update_date,
					last_updated_by = hz_utility_pub.user_id,
					last_update_login = hz_utility_pub.last_update_login,
					program_application_id = hz_utility_pub.program_application_id,
					program_id = hz_utility_pub.program_id,
					program_update_date = sysdate
			WHERE   vendor_id = p_dup_vendor_id
					AND vendor_site_id = p_dup_vendor_site_id;

			-- Prepare message name
			FND_MESSAGE.SET_NAME('OZF','OZF_VENDOR_MERGE');
			IF SQL%FOUND THEN
			   p_return_status := FND_API.G_RET_STS_SUCCESS;
			   l_row_count := SQL%ROWCOUNT;
			ELSE
			   l_row_count := 0;
			END IF;

			FND_MESSAGE.SET_TOKEN('ROWS_UPDATED',l_row_count);
			FND_MESSAGE.SET_TOKEN('TABLE_NAME','OZF_CUST_TRD_PRFLS_ALL');
			-- Add message to API message list.
			FND_MSG_PUB.Add;

			-- Get message count and if 1, return message data.
			FND_MSG_PUB.Count_And_Get
			(  p_count         	=>      p_msg_count,
			   p_data          	=>      p_msg_data
			);

      END IF;

	EXCEPTION
	  WHEN OTHERS THEN
		 ROLLBACK ;
		 p_return_status :=  FND_API.G_RET_STS_ERROR;
		 FND_MSG_PUB.Count_And_Get
			   ( p_count =>  p_msg_count,
				 p_data  =>  p_msg_data
			   );

	END Merge_Vendor;

END OZF_VENDORMERGE_GRP;

/
