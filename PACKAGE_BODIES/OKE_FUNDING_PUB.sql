--------------------------------------------------------
--  DDL for Package Body OKE_FUNDING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_FUNDING_PUB" as
/* $Header: OKEPKFDB.pls 120.0.12000000.2 2007/02/19 21:20:53 ifilimon ship $ */

g_module          CONSTANT VARCHAR2(250) := 'oke.plsql.oke_funding_pub.';

--
-- Private Procedures and Functions
--

--
-- Procedure: check_update_add_pa
--
-- Description: This procedure is used to check if update/insert is needed for project funding
--
--

FUNCTION check_update_add_pa(p_fund_allocation_id NUMBER) RETURN BOOLEAN is

   cursor c_exist is
      select 'Y'
      from   oke_k_fund_allocations
      where  fund_allocation_id = p_fund_allocation_id
      and    agreement_version is not null;

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   OPEN c_exist;
   FETCH c_exist into l_dummy_value;
   CLOSE c_exist;

   IF (l_dummy_value = '?') THEN

      return(FALSE);

   ELSE

      return(TRUE);

   END IF;

   CLOSE c_exist;

EXCEPTION
   WHEN OTHERS THEN
       OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
       			   p_msg_name		=>	G_UNEXPECTED_ERROR	,
       			   p_token1		=>	G_SQLCODE_TOKEN		,
       			   p_token1_value	=>	SQLCODE			,
       			   p_token2		=>	G_SQLERRM_TOKEN		,
       			   p_token2_value	=>	SQLERRM
       			   );

       IF (c_exist%ISOPEN) THEN
           CLOSE c_exist;
       END IF;

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END check_update_add_pa;


--
-- Procedure: check_update_add
--
-- Description: This procedure is used to check if update/add is needed for allocation
--
--

FUNCTION check_update_add(p_fund_allocation_id		NUMBER) RETURN	BOOLEAN	is

   cursor c_update is
      select 'x'
      from   oke_k_fund_allocations
      where  fund_allocation_id = p_fund_allocation_id;

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   OPEN c_update;
   FETCH c_update into l_dummy_value;
   CLOSE c_update;

   IF (l_dummy_value = '?') THEN

      return(FALSE);

   ELSE

      return(TRUE);

   END IF;

   CLOSE c_update;

EXCEPTION
   WHEN OTHERS THEN
       OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
       			   p_msg_name		=>	G_UNEXPECTED_ERROR	,
       			   p_token1		=>	G_SQLCODE_TOKEN		,
       			   p_token1_value	=>	SQLCODE			,
       			   p_token2		=>	G_SQLERRM_TOKEN		,
       			   p_token2_value	=>	SQLERRM
       			   );

       IF (c_update%ISOPEN) THEN
           CLOSE c_update;
       END IF;

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END check_update_add;


--
-- Procedure: validate_agreement_id
--
-- Description: This procedure is used to validate the agreement_id
--
--

PROCEDURE validate_agreement_id(p_agreement_id		NUMBER	,
				p_funding_source_id	NUMBER
				) is

   cursor c_agreement(x_length number) is
      select 'x'
      from   pa_agreements_all
      where  agreement_id = p_agreement_id
      and    pm_product_code = G_PRODUCT_CODE
      and    substr(pm_agreement_reference, -1 * x_length, x_length) = '-'|| p_funding_source_id;

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   IF (p_agreement_id is null) 			OR
      (p_agreement_id = OKE_API.G_MISS_NUM)     THEN

       OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
		           p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			   p_token1		=> 	'VALUE'				,
      			   p_token1_value	=> 	'agreement_id'
       			   );

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   OPEN c_agreement((LENGTH(p_funding_source_id) + 1));
   FETCH c_agreement into l_dummy_value;
   CLOSE c_agreement;

   IF (l_dummy_value = '?') THEN

       OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
		           p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			   p_token1		=> 	'VALUE'				,
      			   p_token1_value	=> 	'agreement_id'
       			   );

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
       OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
       			   p_msg_name		=>	G_UNEXPECTED_ERROR	,
       			   p_token1		=>	G_SQLCODE_TOKEN		,
       			   p_token1_value	=>	SQLCODE			,
       			   p_token2		=>	G_SQLERRM_TOKEN		,
       			   p_token2_value	=>	SQLERRM
       			   );

       IF (c_agreement%ISOPEN) THEN
           CLOSE c_agreement;
       END IF;

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END validate_agreement_id;


--
-- Procedure: get_record
--
-- Description: This procedure is used to retrieve the existing fund allocation record
--
--

FUNCTION get_record(p_fund_allocation_id		NUMBER) RETURN ALLOCATION_REC_IN_TYPE is

   cursor c_allocation is
      select fund_allocation_id		,
      	     funding_source_id		,
             project_id			,
             task_id			,
             amount			,
             start_date_active		,
             pa_conversion_type		,
             pa_conversion_date		,
             pa_conversion_rate,
             funding_category
      from   oke_k_fund_allocations
      where  fund_allocation_id = p_fund_allocation_id;

   l_allocation_in_rec	ALLOCATION_REC_IN_TYPE;

BEGIN

   OPEN c_allocation;
   FETCH c_allocation into l_allocation_in_rec.fund_allocation_id	,
   			   l_allocation_in_rec.funding_source_id	,
   			   l_allocation_in_rec.project_id		,
   			   l_allocation_in_rec.task_id			,
   			   l_allocation_in_rec.amount			,
   			   l_allocation_in_rec.start_date_active	,
   			   l_allocation_in_rec.pa_conversion_type	,
   			   l_allocation_in_rec.pa_conversion_date	,
   			   l_allocation_in_rec.pa_conversion_rate	,
         l_allocation_in_rec.funding_category;
   CLOSE c_allocation;

   RETURN (l_allocation_in_rec);

EXCEPTION
   WHEN OTHERS THEN
       OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
       			   p_msg_name		=>	G_UNEXPECTED_ERROR	,
       			   p_token1		=>	G_SQLCODE_TOKEN		,
       			   p_token1_value	=>	SQLCODE			,
       			   p_token2		=>	G_SQLERRM_TOKEN		,
       			   p_token2_value	=>	SQLERRM
       			   );

       IF (c_allocation%ISOPEN) THEN
           CLOSE c_allocation;
       END IF;

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END get_record;





--
-- Public Procedures and Functions
--



--
-- Procedure: create_pa_oke_funding
--
-- Description: This procedure is used to create contract funding and pa agreement
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			OKE_FUNDSOURCE_PVT.fetch_create_funding
--

PROCEDURE create_pa_oke_funding(p_api_version		IN 		NUMBER				,
			 	p_init_msg_list		IN		VARCHAR2 := OKE_API.G_FALSE	,
			 	p_commit		IN		VARCHAR2 := OKE_API.G_FALSE	,
			 	x_return_status		OUT  NOCOPY	VARCHAR2			,
			 	x_msg_count		OUT  NOCOPY	NUMBER				,
			 	x_msg_data		OUT  NOCOPY	VARCHAR2			,
			 	x_funding_source_id	OUT  NOCOPY	NUMBER				,
			 	--p_source_currency	IN		VARCHAR2			,
			 	p_agreement_id		IN		NUMBER				,
			 	p_party_id		IN		NUMBER				,
			 	p_pool_party_id		IN		NUMBER				,
			 	p_object_id		IN		NUMBER				,
			 	--p_pa_conversion_type	IN	VARCHAR2			,
			 	--p_pa_conversion_date	IN	DATE				,
		               -- p_pa_conversion_rate    IN      NUMBER				,
				p_oke_conversion_type	IN		VARCHAR2			,
			 	p_oke_conversion_date	IN		DATE		                ,
                                p_oke_conversion_rate   IN     	        NUMBER
				) is

   l_api_name		CONSTANT	VARCHAR2(30) := 'create_pa_oke_funding';
   l_return_status			VARCHAR2(1);

BEGIN

   x_return_status  		   := OKE_API.G_RET_STS_SUCCESS;

   l_return_status := OKE_API.START_ACTIVITY(p_api_name			=>	l_api_name		,
   			 		     p_pkg_name			=>	G_PKG_NAME		,
   					     p_init_msg_list		=>	p_init_msg_list		,
   			 		     l_api_version		=>	G_API_VERSION_NUMBER	,
   			 		     p_api_version		=>	p_api_version		,
   			 		     p_api_type			=>	'_PUB'			,
   			 	             x_return_status		=>	x_return_status
   			 		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   OKE_FUNDSOURCE_PVT.fetch_create_funding(p_init_msg_list			=>  	OKE_API.G_FALSE		,
			      		   p_api_version			=> 	p_api_version		,
			      		   p_msg_count				=>	x_msg_count		,
   			      		   p_msg_data				=>	x_msg_data		,
   					   p_commit				=>	OKE_API.G_FALSE		,
			                   p_pool_party_id			=>	p_pool_party_id		,
			                   p_party_id				=>	p_party_id		,
			                   --p_source_currency			=>	p_source_currency	,
			                   p_agreement_id			=>	p_agreement_id		,
			        	   p_conversion_type			=>	p_oke_conversion_type	,
			       	 	   p_conversion_date			=>	p_oke_conversion_date	,
			       	 	   p_conversion_rate			=>      p_oke_conversion_rate   ,
			         	   --p_pa_conversion_type			=>      p_pa_conversion_type	,
			         	   --p_pa_conversion_date			=>	p_pa_conversion_date	,
			         	   --p_pa_conversion_rate                 =>      p_pa_conversion_rate    ,
			         	   p_k_header_id			=>	p_object_id		,
			         	   p_funding_source_id			=>	x_funding_source_id	,
			        	   p_return_status			=>	x_return_status
			       		  );

   IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   OKE_API.END_ACTIVITY(x_msg_count	=>	x_msg_count	,
   			x_msg_data      =>	x_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION THEN
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OTHERS THEN
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );
END create_pa_oke_funding;



--
-- Procedure: create_funding
--
-- Description: This procedure is used to create contract funding and pa agreement
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--                      OKE_FUNDSOURCE_PVT.create_funding
--			OKE_ALLOCATION_PVT.add_allocation
--			OKE_FUNDSOURCE_PVT.update_funding
--			OKE_AGREEMENT_PVT.create_agreement
--

PROCEDURE create_funding(p_api_version		IN 		NUMBER				,
			 p_init_msg_list	IN		VARCHAR2 := OKE_API.G_FALSE	,
			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE	,
			 x_return_status	OUT  NOCOPY	VARCHAR2			,
			 x_msg_count		OUT  NOCOPY	NUMBER				,
			 x_msg_data		OUT  NOCOPY	VARCHAR2			,
			 p_agreement_flag	IN		VARCHAR2 := OKE_API.G_FALSE	,
			 p_agreement_type	IN		VARCHAR2 			,
			 p_funding_in_rec	IN		FUNDING_REC_IN_TYPE		,
			 x_funding_out_rec	OUT  NOCOPY	FUNDING_REC_OUT_TYPE		,
			 p_allocation_in_tbl	IN		ALLOCATION_IN_TBL_TYPE		,
			 x_allocation_out_tbl	OUT  NOCOPY	ALLOCATION_OUT_TBL_TYPE
			) is

   l_api_name		CONSTANT	VARCHAR2(30) := 'create_funding';
   i					NUMBER 	     := 0;
   l_return_status			VARCHAR2(1);
   l_allocation_in_rec			allocation_rec_in_type;
   l_allocation_out_rec			allocation_rec_out_type;
   l_funding_in_rec			funding_rec_in_type;

BEGIN

   --dbms_output.put_line('entering oke_funding_pub.create_funding');
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'entering oke_funding_pub.create_funding');

   x_return_status  		   := OKE_API.G_RET_STS_SUCCESS;
   x_funding_out_rec.return_status := OKE_API.G_RET_STS_SUCCESS;

   l_return_status := OKE_API.START_ACTIVITY(p_api_name			=>	l_api_name		,
   			 		     p_pkg_name			=>	G_PKG_NAME		,
   					     p_init_msg_list		=>	p_init_msg_list		,
   			 		     l_api_version		=>	G_API_VERSION_NUMBER	,
   			 		     p_api_version		=>	p_api_version		,
   			 		     p_api_type			=>	'_PUB'			,
   			 	             x_return_status		=>	x_return_status
   			 		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Call OKE_FUNDSOURCE_PVT.create_funding to create contract funding
   --

   --dbms_output.put_line('calling oke_fundsource_pvt.create_funding from oke_funding_pub');
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_fundsource_pvt.create_funding from oke_funding_pub');

   OKE_FUNDSOURCE_PVT.create_funding(p_api_version		=> p_api_version	,
   				     p_init_msg_list		=> OKE_API.G_FALSE	,
   				     p_commit			=> OKE_API.G_FALSE	,
   				     p_msg_count		=> x_msg_count		,
   				     p_msg_data			=> x_msg_data		,
   				     p_funding_in_rec		=> p_funding_in_rec	,
   				     p_funding_out_rec		=> x_funding_out_rec	,
   				     p_return_status		=> x_return_status
   				    );

   IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   l_funding_in_rec := p_funding_in_rec;
   l_funding_in_rec.funding_source_id := x_funding_out_rec.funding_source_id;

   --
   -- Call add_allocation to create contract funding allocation
   --

   --dbms_output.put_line('calling oke_funding_pub.add_allocation');
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_funding_pub.add_allocation');

   IF (p_allocation_in_tbl.COUNT > 0 )THEN

      i := p_allocation_in_tbl.FIRST;

      LOOP

   	l_allocation_in_rec := p_allocation_in_tbl(i);
   	l_allocation_in_rec.funding_source_id := x_funding_out_rec.funding_source_id;

   	OKE_ALLOCATION_PVT.add_allocation(p_api_version		=>	p_api_version		,
   		      			  p_init_msg_list	=>	OKE_API.G_FALSE		,
		       			  p_commit		=>	OKE_API.G_FALSE		,
		       			  p_return_status	=>      x_return_status		,
		       			  p_msg_count		=>	x_msg_count		,
		       			  p_msg_data		=>	x_msg_data		,
		       			  p_allocation_in_rec	=>	l_allocation_in_rec	,
		       			  p_allocation_out_rec	=> 	l_allocation_out_rec	,
		       			  p_validation_flag	=>	OKE_API.G_FALSE
		     			 );

	x_allocation_out_tbl(i)	:= l_allocation_out_rec;

        IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

           RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

        ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

           RAISE OKE_API.G_EXCEPTION_ERROR;

        END IF;

        EXIT WHEN (i = p_allocation_in_tbl.LAST);
        i := p_allocation_in_tbl.NEXT(i);

      END LOOP;

   END IF;

   --
   -- Call OKE_FUNDSOURCE_PVT.update_funding to validate the entire funding record
   --

   OKE_FUNDSOURCE_PVT.update_funding(p_api_version		=> p_api_version	,
   				     p_init_msg_list		=> OKE_API.G_FALSE	,
   				     p_commit			=> OKE_API.G_FALSE	,
   				     p_msg_count		=> x_msg_count		,
   				     p_msg_data			=> x_msg_data		,
   				     p_funding_in_rec		=> l_funding_in_rec	,
   				     p_funding_out_rec		=> x_funding_out_rec	,
   				     p_return_status		=> x_return_status
   				    );

   IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Check for agreement creation option
   --

   IF (FND_API.to_boolean(p_agreement_flag)) THEN

      --dbms_output.put_line('calling oke_agreement_pvt.create_agreement');
     --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_agreement_pvt.create_agreement');

      OKE_AGREEMENT_PVT.create_agreement(p_api_version				=> 	G_API_VERSION_NUMBER			,
   					 p_init_msg_list			=>	OKE_API.G_FALSE				,
   					 p_commit				=>	OKE_API.G_FALSE				,
   					 p_msg_count				=>	x_msg_count				,
   					 p_msg_data				=>	x_msg_data				,
   					 p_agreement_type			=>	p_agreement_type			,
     	 				 p_funding_in_rec			=> 	l_funding_in_rec			,
     	 			--	 p_allocation_in_tbl			=>	p_allocation_in_tbl			,
     	 				 p_return_status			=>	x_return_status
     	 				);

      IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

      ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_ERROR;

      END IF;

   END IF;

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   --dbms_output.put_line('finished oke_funding_pub.create_funding w/ ' || x_return_status);
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished oke_funding_pub.create_funding w/ ' || x_return_status);

   OKE_API.END_ACTIVITY(x_msg_count	=>	x_msg_count	,
   			x_msg_data      =>	x_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION THEN
        x_funding_out_rec.return_status := OKE_API.G_RET_STS_ERROR;
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	x_funding_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OTHERS THEN
   	x_funding_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

END create_funding;


--
-- Procedure: update_funding
--
-- Description: This procedure is used to update contract funding and pa agreement
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			OKE_FUNDSOURCE_PVT.update_funding
--			OKE_API.set_message
--			OKE_AGREEMENT_PVT.update_agreement
--			OKE_AGREEMENT_PVT.create_agreement
--			OKE_FUNDING_UTIL_PKG.check_agreement_exist
--		        check_update_add
--			OKE_ALLOCATION_PVT.add_allocation
--			OKE_ALLOCATION_PVT.update_allocation
--

PROCEDURE update_funding(p_api_version		IN 		NUMBER				,
			 p_init_msg_list	IN		VARCHAR2 := OKE_API.G_FALSE	,
			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE	,
			 x_return_status	OUT  NOCOPY	VARCHAR2			,
			 x_msg_count		OUT  NOCOPY	NUMBER				,
			 x_msg_data		OUT  NOCOPY	VARCHAR2			,
			 p_agreement_flag	IN		VARCHAR2 := OKE_API.G_FALSE	,
			 p_agreement_type	IN		VARCHAR2 			,
			 p_funding_in_rec	IN		FUNDING_REC_IN_TYPE		,
			 x_funding_out_rec	OUT  NOCOPY	FUNDING_REC_OUT_TYPE		,
			 p_allocation_in_tbl	IN		ALLOCATION_IN_TBL_TYPE		,
			 x_allocation_out_tbl	OUT  NOCOPY	ALLOCATION_OUT_TBL_TYPE
			) is

   l_api_name		CONSTANT	VARCHAR2(30) := 'update_funding';
   l_return_status			VARCHAR2(1);
   l_allocation_in_rec			allocation_rec_in_type;
   l_allocation_out_rec			allocation_rec_out_type;
   i					NUMBER := 0;
   l_agreement_exist			VARCHAR2(1);

BEGIN

   --dbms_output.put_line('entering oke_funding_pub.update_funding');
  --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'entering oke_funding_pub.update_funding');

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_funding_out_rec.return_status := OKE_API.G_RET_STS_SUCCESS;

   l_return_status := OKE_API.START_ACTIVITY(p_api_name			=>	l_api_name		,
   			 		     p_pkg_name			=>	G_PKG_NAME		,
   					     p_init_msg_list		=>	p_init_msg_list		,
   			 		     l_api_version		=>	G_API_VERSION_NUMBER	,
   			 		     p_api_version		=>	p_api_version		,
   			 		     p_api_type			=>	'_PUB'			,
   			 	             x_return_status		=>	x_return_status
   			 		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Call OKE_ALLOCATION_PVT.add_allocation and update_allocation to create/update contract funding allocation
   --

   --dbms_output.put_line('checking if add or update allocation');
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'checking if add or update allocation');

   IF (p_allocation_in_tbl.COUNT >0 )THEN

      i := p_allocation_in_tbl.FIRST;

      LOOP

   	l_allocation_in_rec := p_allocation_in_tbl(i);

        --
        -- Check if funding source id of source = funding source id of allocation lines
        --

	IF (l_allocation_in_rec.funding_source_id <> p_funding_in_rec.funding_source_id) THEN

            OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
       			        p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
       			        p_token1		=>	'VALUE'				,
       			        p_token1_value		=>	'allocation.funding_source_id'
       			       );

            RAISE G_EXCEPTION_HALT_VALIDATION;

 	END IF;

        IF (check_update_add(p_fund_allocation_id => l_allocation_in_rec.fund_allocation_id)) THEN

   	   OKE_ALLOCATION_PVT.update_allocation(p_api_version			=>	p_api_version		,
   		             			p_init_msg_list			=>	OKE_API.G_FALSE		,
		             			p_commit			=>	OKE_API.G_FALSE		,
		             			p_return_status			=>      x_return_status		,
		             			p_msg_count			=>	x_msg_count		,
		             			p_msg_data			=>	x_msg_data		,
		             			p_allocation_in_rec		=>	l_allocation_in_rec	,
		            		        p_allocation_out_rec		=> 	l_allocation_out_rec	,
		            		        p_validation_flag		=>	OKE_API.G_FALSE
		            			);

	ELSE

	   OKE_ALLOCATION_PVT.add_allocation(p_api_version		=>	p_api_version		,
			  		     p_init_msg_list		=>	OKE_API.G_FALSE		,
			  		     p_commit			=>	OKE_API.G_FALSE		,
			  		     p_return_status		=> 	x_return_status		,
			  		     p_msg_count		=>	x_msg_count		,
			  		     p_msg_data			=>	x_msg_data		,
			  		     p_validation_flag		=>	OKE_API.G_FALSE		,
		          	 	     p_allocation_in_rec	=>	l_allocation_in_rec	,
		          		     p_allocation_out_rec	=>	l_allocation_out_rec
 			 		     );

        END IF;

	x_allocation_out_tbl(i)	:= l_allocation_out_rec;

        IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

        ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_ERROR;

        END IF;

        EXIT WHEN (i = p_allocation_in_tbl.LAST);
        i := p_allocation_in_tbl.NEXT(i);

      END LOOP;

   END IF;

   --
   -- Call OKE_FUNDSOURCE_PVT.update_funding to update contract funding
   --

   --dbms_output.put_line('calling oke_fundsource_pvt.update_funding');
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_fundsource_pvt.update_funding');

   OKE_FUNDSOURCE_PVT.update_funding(p_api_version	=> p_api_version	,
   				     p_init_msg_list	=> OKE_API.G_FALSE	,
   				     p_commit		=> OKE_API.G_FALSE	,
   				     p_msg_count	=> x_msg_count		,
   				     p_msg_data		=> x_msg_data		,
   				     p_funding_in_rec	=> p_funding_in_rec	,
   				     p_funding_out_rec	=> x_funding_out_rec	,
   				     p_return_status	=> x_return_status	);

   IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Check if agreement update is needed
   --

   IF (FND_API.to_boolean(p_agreement_flag)) THEN

      OKE_FUNDING_UTIL_PKG.check_agreement_exist(x_funding_source_id 	=>	 p_funding_in_rec.funding_source_id ,
      						 x_return_status        =>	 l_agreement_exist
      						 );
      IF (l_agreement_exist = 'Y') THEN

         --dbms_output.put_line('calling oke_agreement_pvt.update_agreement');
        --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_agreement_pvt.update_agreement');

         OKE_AGREEMENT_PVT.update_agreement(p_api_version		=> 	p_api_version				,
   					    p_init_msg_list		=>	OKE_API.G_FALSE				,
   					    p_commit			=>      OKE_API.G_FALSE				,
   					    p_msg_count			=>	x_msg_count				,
   					    p_msg_data			=>	x_msg_data				,
			 		    p_agreement_type		=>	p_agreement_type			,
      					    p_funding_in_rec		=>	p_funding_in_rec			,
       					 --   p_allocation_in_tbl		=>	p_allocation_in_tbl			,
       					    p_return_status		=>	x_return_status
       				           );

      ELSE

         --dbms_output.put_line('calling oke_agreement_pvt.create_agreement');
        --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_agreement_pvt.create_agreement');

         OKE_AGREEMENT_PVT.create_agreement(p_api_version			=> 	p_api_version				,
   					    p_init_msg_list			=>	OKE_API.G_FALSE				,
   					    p_commit				=>      OKE_API.G_FALSE				,
   					    p_msg_count				=>	x_msg_count				,
   					    p_msg_data				=>	x_msg_data				,
   					    p_agreement_type			=>	p_agreement_type			,
     	 				    p_funding_in_rec			=> 	p_funding_in_rec			,
     	 			--	    p_allocation_in_tbl			=>	p_allocation_in_tbl			,
     	 				    p_return_status			=>	x_return_status
     	 				   );

      END IF;

      IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

      ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_ERROR;

      END IF;

   END IF;

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   --dbms_output.put_line('finished oke_funding_pub.create_funding w/ ' || x_return_status);
  --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished oke_funding_pub.create_funding w/ ' || x_return_status);

   OKE_API.END_ACTIVITY(x_msg_count	=>	x_msg_count	,
   			x_msg_data      =>	x_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION THEN
        x_funding_out_rec.return_status := OKE_API.G_RET_STS_ERROR;
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	x_funding_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OTHERS THEN
   	x_funding_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );
END update_funding;


--
-- Procedure: delete_funding
--
-- Description: This procedure is used to delete contract funding and pa agreement
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--		        OKE_FUNDSOURCE_PVT.delete_funding
--			OKE_FUNDING_PUB.delete_allocation
--

PROCEDURE delete_funding(p_api_version		IN 		NUMBER				,
			 p_init_msg_list	IN		VARCHAR2 := OKE_API.G_FALSE	,
			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE	,
			 x_return_status	OUT  NOCOPY	VARCHAR2			,
			 x_msg_count		OUT  NOCOPY	NUMBER				,
			 x_msg_data		OUT  NOCOPY	VARCHAR2			,
			 p_funding_source_id	IN		NUMBER
			-- p_agreement_flag	IN		VARCHAR2 := OKE_API.G_FALSE
			) is

--   l_length				NUMBER;
--   l_temp_val		VARCHAR2(1) :='?';

   cursor c_fund_allocation_id (p_funding_source_id 	NUMBER) is
   	select fund_allocation_id
   	from   oke_k_fund_allocations
   	where  funding_source_id = p_funding_source_id
   	order by amount asc;

   l_allocation_id 			c_fund_allocation_id%ROWTYPE;
   l_api_name		CONSTANT	VARCHAR2(30) := 'delete_funding';
   l_return_status			VARCHAR2(1);

BEGIN

   --dbms_output.put_line('entering oke_funding_pub.delete_funding');
 --  --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'entering oke_funding_pub.delete_funding');

   x_return_status  		   := OKE_API.G_RET_STS_SUCCESS;

   l_return_status := OKE_API.START_ACTIVITY(p_api_name			=>	l_api_name		,
   			 		     p_pkg_name			=>	G_PKG_NAME		,
   					     p_init_msg_list		=>	p_init_msg_list		,
   			 		     l_api_version		=>	G_API_VERSION_NUMBER	,
   			 		     p_api_version		=>	p_api_version		,
   			 		     p_api_type			=>	'_PUB'			,
   			 	             x_return_status		=>	x_return_status
   			 		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Call OKE_FUNDING_PUB to delete contract funding allocation
   --

   --dbms_output.put_line('in loop: calling delete_allocation');
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'in loop: calling delete_allocation');

   FOR l_allocation_id IN c_fund_allocation_id(p_funding_source_id) LOOP

        OKE_ALLOCATION_PVT.delete_allocation(p_api_version			=>	p_api_version				,
   			  		     p_init_msg_list			=>	OKE_API.G_FALSE				,
   			  		     p_commit				=>	OKE_API.G_FALSE				,
   		   	  		     p_return_status			=>      x_return_status				,
   		 	 		     p_msg_count			=>      x_msg_count				,
   		 	  		     p_msg_data				=>	x_msg_data				,
   			  		     p_fund_allocation_id		=>	l_allocation_id.fund_allocation_id
   			 		    );

   	IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

           RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

        ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

           RAISE OKE_API.G_EXCEPTION_ERROR;

        END IF;

   END LOOP;

   --dbms_output.put_line('finished delete_allocation');
  --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished delete_allocation');

   --
   -- Call OKE_FUNDSOURCE_PVT.delete_funding to delete contract funding
   --

   --dbms_output.put_line('calling oke_fundsource_pvt.delete_funding');
  --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_fundsource_pvt.delete_funding');

   OKE_FUNDSOURCE_PVT.delete_funding(p_api_version			=> 	p_api_version		,
   				     p_commit				=>	OKE_API.G_FALSE		,
   				     p_init_msg_list			=>	OKE_API.G_FALSE		,
   				     p_msg_count			=> 	x_msg_count		,
   				     p_msg_data				=> 	x_msg_data		,
   				     p_funding_source_id		=>	p_funding_source_id	,
   				  --   p_agreement_flag			=>	p_agreement_flag	,
   				     p_return_status			=>	x_return_status
   				    );

   IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --dbms_output.put_line('finished oke_funding_pub.delete_funding w/ ' || x_return_status);
  --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished oke_funding_pub.delete_funding w/ ' || x_return_status);

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   OKE_API.END_ACTIVITY(x_msg_count	=>	x_msg_count	,
   			x_msg_data      =>	x_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION THEN
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OTHERS THEN
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );
END delete_funding;



--
-- Procedure: add_allocation
--
-- Description: This procedure is used to create funding allocation and update/add pa funding
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			OKE_ALLOCATION_PVT.add_allocation
--			OKE_AGREEMENT_PVT.add_pa_funding
--

PROCEDURE add_allocation(p_api_version		IN 		NUMBER					,
			 p_init_msg_list	IN		VARCHAR2 := OKE_API.G_FALSE		,
			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE		,
			 x_return_status	OUT  NOCOPY	VARCHAR2				,
			 x_msg_count		OUT  NOCOPY	NUMBER					,
			 x_msg_data		OUT  NOCOPY	VARCHAR2				,
			 p_agreement_flag	IN		VARCHAR2 := OKE_API.G_FALSE		,
		         p_allocation_in_rec	IN		ALLOCATION_REC_IN_TYPE			,
		         x_allocation_out_rec	OUT  NOCOPY	ALLOCATION_REC_OUT_TYPE
 			) is

   l_api_name		CONSTANT	VARCHAR2(30) := 'add_allocation';
   l_return_status			VARCHAR2(1);
   l_allocation_in_rec			ALLOCATION_REC_IN_TYPE := p_allocation_in_rec;

BEGIN

   --dbms_output.put_line('entering oke_funding_pub.add_allocation');
  --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'entering oke_funding_pub.add_allocation');

   x_return_status  		  	 := OKE_API.G_RET_STS_SUCCESS;
   x_allocation_out_rec.return_status 	 := OKE_API.G_RET_STS_SUCCESS;

   l_return_status := OKE_API.START_ACTIVITY(p_api_name			=>	l_api_name		,
   			 		     p_pkg_name			=>	G_PKG_NAME		,
   					     p_init_msg_list		=>	p_init_msg_list		,
   			 		     l_api_version		=>	G_API_VERSION_NUMBER	,
   			 		     p_api_version		=>	p_api_version		,
   			 		     p_api_type			=>	'_PUB'			,
   			 	             x_return_status		=>	x_return_status
   			 		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Call OKE_ALLOCATION_PVT.add_allocation
   --

   --dbms_output.put_line('calling oke_allocation_pvt.add_allocation from oke_funding_pub');
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_allocation_pvt.add_allocation from oke_funding_pub');

   OKE_ALLOCATION_PVT.add_allocation(p_api_version		=> p_api_version	,
   				     p_init_msg_list		=> OKE_API.G_FALSE	,
   				     p_commit			=> OKE_API.G_FALSE	,
   				     p_msg_count		=> x_msg_count		,
   				     p_msg_data			=> x_msg_data		,
   				     p_allocation_in_rec	=> p_allocation_in_rec	,
   				     p_allocation_out_rec	=> x_allocation_out_rec	,
   				     p_validation_flag		=> OKE_API.G_TRUE	,
   				     p_return_status		=> x_return_status
   				    );

   IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Set the fund_allocation_id
   --
   l_allocation_in_rec.fund_allocation_id := x_allocation_out_rec.fund_allocation_id;

   --
   -- Check if agreement update is needed
   --

   IF (FND_API.to_boolean(p_agreement_flag)) THEN

       --
       -- Validate agreement_id
       --
       validate_agreement_id(p_agreement_id			=>	p_allocation_in_rec.agreement_id	,
       		             p_funding_source_id		=>	p_allocation_in_rec.funding_source_id
		  	    );

       --
       -- Get the allocation record
       --
       l_allocation_in_rec := get_record(p_fund_allocation_id	=>	l_allocation_in_rec.fund_allocation_id);
       l_allocation_in_rec.agreement_id := p_allocation_in_rec.agreement_id;

       --dbms_output.put_line('calling oke_agreement_pvt.add_pa_funding from oke_funding_pub');
       --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_agreement_pvt.add_pa_funding from oke_funding_pub');

       OKE_AGREEMENT_PVT.add_pa_funding(p_api_version				=> 	p_api_version		,
   				        p_init_msg_list				=> 	OKE_API.G_FALSE		,
   				        p_commit				=>	OKE_API.G_FALSE		,
   				        p_msg_count				=> 	x_msg_count		,
   				        p_msg_data				=> 	x_msg_data		,
            				p_allocation_in_rec			=>	l_allocation_in_rec	,
         			        p_return_status				=>	x_return_status
         			       );

       IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

           RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

       ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

           RAISE OKE_API.G_EXCEPTION_ERROR;

       END IF;

   END IF;

   --dbms_output.put_line('finished oke_funding_pub.add_allocation w/ ' || x_return_status);
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished oke_funding_pub.add_allocation w/ ' || x_return_status);

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   OKE_API.END_ACTIVITY(x_msg_count	=>	x_msg_count	,
   			x_msg_data      =>	x_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION THEN
        x_allocation_out_rec.return_status := OKE_API.G_RET_STS_ERROR;
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	x_allocation_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OTHERS THEN
   	x_allocation_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );
END add_allocation;


--
-- Procedure: update_allocation
--
-- Description: This procedure is used to update contract funding allocation and pa funding line
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--		        OKE_ALLOCATION_PVT.update_allocation
--			OKE_AGREEMENT_PVT.update_pa_funding
--			OKE_AGREEMENT_PVT.add_pa_funding
--			check_update_add_pa
--

PROCEDURE update_allocation(p_api_version		IN 		NUMBER				,
			    p_init_msg_list		IN		VARCHAR2 := OKE_API.G_FALSE	,
			    p_commit			IN		VARCHAR2 := OKE_API.G_FALSE	,
			    x_return_status		OUT  NOCOPY	VARCHAR2			,
			    x_msg_count			OUT  NOCOPY	NUMBER				,
			    x_msg_data			OUT  NOCOPY	VARCHAR2			,
			    p_agreement_flag		IN		VARCHAR2 := OKE_API.G_FALSE	,
			    p_allocation_in_rec		IN		ALLOCATION_REC_IN_TYPE		,
			    x_allocation_out_rec	OUT  NOCOPY	ALLOCATION_REC_OUT_TYPE
			   ) is

   l_api_name		CONSTANT	VARCHAR2(30) := 'update_allocation';
   l_return_status			VARCHAR2(1);
   l_allocation_in_rec			ALLOCATION_REC_IN_TYPE;

BEGIN

   --dbms_output.put_line('entering oke_funding_pub.update_allocation');
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'entering oke_funding_pub.update_allocation');

   x_return_status  		  	 := OKE_API.G_RET_STS_SUCCESS;
   x_allocation_out_rec.return_status 	 := OKE_API.G_RET_STS_SUCCESS;

   l_return_status := OKE_API.START_ACTIVITY(p_api_name			=>	l_api_name		,
   			 		     p_pkg_name			=>	G_PKG_NAME		,
   					     p_init_msg_list		=>	p_init_msg_list		,
   			 		     l_api_version		=>	G_API_VERSION_NUMBER	,
   			 		     p_api_version		=>	p_api_version		,
   			 		     p_api_type			=>	'_PUB'			,
   			 	             x_return_status		=>	x_return_status
   			 		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   x_allocation_out_rec.fund_allocation_id := p_allocation_in_rec.fund_allocation_id;

   --
   -- Call OKE_ALLOCATION_PVT.update_allocation to update the allocation line
   --

   --dbms_output.put_line('calling oke_allocation_pvt.update_allocation from oke_funding_pub');
  --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_allocation_pvt.update_allocation from oke_funding_pub');

   OKE_ALLOCATION_PVT.update_allocation(p_api_version		=> 	p_api_version		,
   				        p_init_msg_list		=> 	OKE_API.G_FALSE		,
   				        p_commit		=>	OKE_API.G_FALSE		,
   				        p_msg_count		=> 	x_msg_count		,
   				        p_msg_data		=> 	x_msg_data		,
   				        p_allocation_in_rec	=>	p_allocation_in_rec	,
   				        p_allocation_out_rec	=>	x_allocation_out_rec    ,
   				        p_validation_flag	=>	OKE_API.G_TRUE		,
   				        p_return_status		=>	x_return_status
   				      );

   IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Check if agreement update is needed
   --

   IF (FND_API.to_boolean(p_agreement_flag)) THEN

       --
       -- Validate agreement_id
       --
       validate_agreement_id(p_agreement_id			=>	p_allocation_in_rec.agreement_id	,
       		             p_funding_source_id		=>	p_allocation_in_rec.funding_source_id
		  	    );

       --
       -- Get the allocation record
       --
       l_allocation_in_rec := get_record(p_fund_allocation_id	=>	p_allocation_in_rec.fund_allocation_id);
       l_allocation_in_rec.agreement_id := p_allocation_in_rec.agreement_id;

       --dbms_output.put_line('check if it is a update or add in pa');
       --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'check if it is a update or add in pa');

       IF (check_update_add_pa(p_fund_allocation_id  => p_allocation_in_rec.fund_allocation_id)) THEN

             --dbms_output.put_line('calling oke_agreement_pvt.update_pa_funding from oke_funding_pub');
             --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_agreement_pvt.update_pa_funding from oke_funding_pub');

             OKE_AGREEMENT_PVT.update_pa_funding(p_api_version			=> 	p_api_version		,
   				                 p_init_msg_list		=> 	OKE_API.G_FALSE		,
   				          	 p_commit			=>	OKE_API.G_FALSE		,
   				          	 p_msg_count			=> 	x_msg_count		,
   				         	 p_msg_data			=> 	x_msg_data		,
 						 p_allocation_in_rec		=>	l_allocation_in_rec	,
 				         	 p_return_status		=>	x_return_status
       				         	);
        ELSE

             --dbms_output.put_line('calling oke_agreement_pvt.add_pa_funding from oke_funding_pub');
             --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_agreement_pvt.add_pa_funding from oke_funding_pub');

             OKE_AGREEMENT_PVT.add_pa_funding(p_api_version			=> 	p_api_version		,
   				              p_init_msg_list			=> 	OKE_API.G_FALSE		,
   				              p_commit				=>	OKE_API.G_FALSE		,
   				              p_msg_count			=> 	x_msg_count		,
   				              p_msg_data			=> 	x_msg_data		,
            				      p_allocation_in_rec		=>	l_allocation_in_rec	,
         			              p_return_status			=>	x_return_status
         			             );

        END IF;

        IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

           RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

        ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

           RAISE OKE_API.G_EXCEPTION_ERROR;

        END IF;

   END IF;

   --dbms_output.put_line('finished oke_funding_pub.update_allocation w/ ' || x_return_status);
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished oke_funding_pub.update_allocation w/ ' || x_return_status);

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   OKE_API.END_ACTIVITY(x_msg_count	=>	x_msg_count	,
   			x_msg_data      =>	x_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION THEN
        x_allocation_out_rec.return_status := OKE_API.G_RET_STS_ERROR;
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	x_allocation_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OTHERS THEN
   	x_allocation_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );
END update_allocation;



--
-- Procedure: delete_allocation
--
-- Description: This procedure is used to delete contract funding allocation and pa project_funding
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--		        OKE_ALLOCATION_PVT.delete_allocation
--

PROCEDURE delete_allocation(p_api_version			IN 		NUMBER				,
			    p_init_msg_list			IN		VARCHAR2 := OKE_API.G_FALSE	,
			    p_commit				IN		VARCHAR2 := OKE_API.G_FALSE	,
			    x_return_status			OUT  NOCOPY	VARCHAR2			,
			    x_msg_count				OUT  NOCOPY	NUMBER				,
			    x_msg_data				OUT  NOCOPY	VARCHAR2			,
			    p_fund_allocation_id		IN		NUMBER
			 --   p_agreement_flag			IN		VARCHAR2 := OKE_API.G_FALSE
			   ) is

   l_api_name		CONSTANT	VARCHAR2(30) := 'delete_allocation';
   l_return_status			VARCHAR2(1);
--   l_temp_val 				VARCHAR2(1)  := '?';

   cursor c_source is
      select s.amount, s.hard_limit, s.revenue_hard_limit, s.funding_source_id
      from   oke_k_funding_sources s,
             oke_k_fund_allocations f
      where  s.funding_source_id = f.funding_source_id
      and    f.fund_allocation_id = p_fund_allocation_id;

   cursor c_allocation (x_funding_source_id number)is
      select sum(amount), sum(hard_limit), sum(revenue_hard_limit)
      from   oke_k_fund_allocations
      where  funding_source_id = x_funding_source_id;

   l_funding_source_id 		NUMBER;
   l_s_amount 			NUMBER;
   l_s_hard_limit 		NUMBER;
   l_s_revenue_limit 		NUMBER;
   l_a_amount 			NUMBER;
   l_a_hard_limit 		NUMBER;
   l_a_revenue_limit   		NUMBER;

BEGIN

   --dbms_output.put_line('entering oke_funding_pub.delete_allocation');
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'entering oke_funding_pub.delete_allocation');

   x_return_status  		   := OKE_API.G_RET_STS_SUCCESS;

   l_return_status := OKE_API.START_ACTIVITY(p_api_name			=>	l_api_name		,
   			 		     p_pkg_name			=>	G_PKG_NAME		,
   					     p_init_msg_list		=>	p_init_msg_list		,
   			 		     l_api_version		=>	G_API_VERSION_NUMBER	,
   			 		     p_api_version		=>	p_api_version		,
   			 		     p_api_type			=>	'_PUB'			,
   			 	             x_return_status		=>	x_return_status
   			 		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Check if it is ok to delete allocation
   --
   OPEN c_source;
   FETCH c_source INTO l_s_amount, l_s_hard_limit, l_s_revenue_limit, l_funding_source_id;
   IF (c_source%NOTFOUND) THEN

       CLOSE c_source;
       OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			   p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			   p_token1		=>	'VALUE'				,
      			   p_token1_value	=>	'fund_allocation_id'
     			   );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;
   CLOSE c_source;

   --
   -- Call OKE_ALLOCATION_PVT.delete_allocation to delete funding allocation line
   --

   --dbms_output.put_line('calling oke_allocation_pvt.delete_allocation from oke_funding_pub');
   --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'calling oke_allocation_pvt.delete_allocation from oke_funding_pub');

   OKE_ALLOCATION_PVT.delete_allocation(p_api_version			=>      p_api_version		,
   					p_commit			=>	OKE_API.G_FALSE		,
   				        p_init_msg_list			=>	OKE_API.G_FALSE		,
   				        p_msg_count			=> 	x_msg_count		,
   				        p_msg_data			=> 	x_msg_data		,
   					p_fund_allocation_id		=>	p_fund_allocation_id	,
   				        p_return_status			=>	x_return_status
   				      );

   IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Check sum of allocations
   --
   OPEN c_allocation(l_funding_source_id);
   FETCH c_allocation INTO l_a_amount, l_a_hard_limit, l_a_revenue_limit;
   IF (c_allocation%NOTFOUND) THEN

      l_a_amount 	:=	0;
      l_a_hard_limit	:=	0;
      l_a_revenue_limit := 	0;

   END IF;

   CLOSE c_allocation;

   IF (l_a_amount < 0) THEN

       OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			   p_msg_name		=>	'OKE_NEGATIVE_ALLOCATION_SUM'
     			   );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   ELSIF (l_a_amount > l_s_amount) THEN

       OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			   p_msg_name		=>	'OKE_FUND_AMT_EXCEED'
     			   );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (l_a_hard_limit < 0) THEN

       OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			   p_msg_name		=>	'OKE_NEGATIVE_HARD_LIMIT_SUM'
     			   );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   ELSIF (l_a_hard_limit > l_s_hard_limit) THEN

       OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			   p_msg_name		=>	'OKE_HARD_LIMIT_EXCEED'
     			   );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (l_a_revenue_limit < 0) THEN

       OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			   p_msg_name		=>	'OKE_NEGATIVE_REV_LIMIT_SUM'
     			   );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   ELSIF (l_a_revenue_limit > l_s_revenue_limit) THEN

       OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			   p_msg_name		=>	'OKE_REV_LIMIT_EXCEED'
     			   );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --dbms_output.put_line('finished oke_funding_pub.delete_allocation w/ ' || x_return_status);
  --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished oke_funding_pub.delete_allocation w/ ' || x_return_status);

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   OKE_API.END_ACTIVITY(x_msg_count	=>	x_msg_count	,
   			x_msg_data      =>	x_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION THEN
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );

   WHEN OTHERS THEN
   	x_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	x_msg_count			,
   						     x_msg_data		=>	x_msg_data			,
   						     p_api_type		=>	'_PUB'
   						    );
END delete_allocation;

end OKE_FUNDING_PUB;


/
