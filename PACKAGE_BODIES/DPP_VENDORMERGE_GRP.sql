--------------------------------------------------------
--  DDL for Package Body DPP_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_VENDORMERGE_GRP" AS
/* $Header: dppgmrgb.pls 120.1 2007/11/27 09:23:51 sdasan noship $ */

	G_PKG_NAME      CONSTANT VARCHAR2(30):='DPP_VENDORMERGE_GRP';

	-----------------------------------------------------------------------

	-- PROCEDURE

	--   Merge_Vendor

	--

	-- HISTORY

	--   26-Nov-2007  jajose  Created

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



		UPDATE DPP_TRANSACTION_HEADERS_ALL

		SET vendor_id = p_vendor_id,

				vendor_site_id = p_vendor_site_id,

				last_update_date = hz_utility_pub.last_update_date,

				last_updated_by = hz_utility_pub.user_id,

				last_update_login = hz_utility_pub.last_update_login,

				program_application_id = hz_utility_pub.program_application_id,

				program_id = hz_utility_pub.program_id,

				program_update_date = sysdate

		WHERE   vendor_id = p_dup_vendor_id

			AND vendor_site_id = p_dup_vendor_site_id;

		IF SQL%FOUND THEN

		   p_return_status := FND_API.G_RET_STS_SUCCESS;

		   l_row_count := SQL%ROWCOUNT;

		ELSE

		   l_row_count := 0;

		END IF;

		-- Prepare message name

		FND_MESSAGE.SET_NAME('DPP','DPP_VENDOR_MERGE');

		FND_MESSAGE.SET_TOKEN('ROWS_UPDATED',l_row_count);

		FND_MESSAGE.SET_TOKEN('TABLE_NAME','DPP_TRANSACTION_HEADERS_ALL');

		-- Add message to API message list.

		FND_MSG_PUB.Add;



		-- Get message count and if 1, return message data.

		FND_MSG_PUB.Count_And_Get

		(  p_count         	=>      p_msg_count,
		   p_data          	=>      p_msg_data

		);


	    IF p_dup_vendor_id <> p_vendor_id THEN

			UPDATE DPP_TRANSACTION_HEADERS_LOG

			SET vendor_id = p_vendor_id,

					vendor_site_id = p_vendor_site_id,

					last_update_date = hz_utility_pub.last_update_date,

					last_updated_by = hz_utility_pub.user_id,

					last_update_login = hz_utility_pub.last_update_login

			WHERE   vendor_id = p_dup_vendor_id

					AND vendor_site_id = p_dup_vendor_site_id;

			IF SQL%FOUND THEN

			   p_return_status := FND_API.G_RET_STS_SUCCESS;

			   l_row_count := SQL%ROWCOUNT;

			ELSE

			   l_row_count := 0;

			END IF;

			-- Prepare message name

			FND_MESSAGE.SET_NAME('DPP','DPP_VENDOR_MERGE');

			FND_MESSAGE.SET_TOKEN('ROWS_UPDATED',l_row_count);

			FND_MESSAGE.SET_TOKEN('TABLE_NAME','DPP_TRANSACTION_HEADERS_LOG');

			-- Add message to API message list.

			FND_MSG_PUB.Add;



			-- Get message count and if 1, return message data.

			FND_MSG_PUB.Count_And_Get

			(  p_count         	=>      p_msg_count,

			   p_data          	=>      p_msg_data

			);



			UPDATE DPP_TXN_HEADERS_INT_ALL

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


			IF SQL%FOUND THEN

			   p_return_status := FND_API.G_RET_STS_SUCCESS;

			   l_row_count := SQL%ROWCOUNT;

			ELSE

			   l_row_count := 0;

			END IF;

			-- Prepare message name

			FND_MESSAGE.SET_NAME('DPP','DPP_VENDOR_MERGE');

			FND_MESSAGE.SET_TOKEN('ROWS_UPDATED',l_row_count);

			FND_MESSAGE.SET_TOKEN('TABLE_NAME','DPP_TXN_HEADERS_INT_ALL');

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

END DPP_VENDORMERGE_GRP;

/
