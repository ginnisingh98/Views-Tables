--------------------------------------------------------
--  DDL for Package Body OKE_FUNDSOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_FUNDSOURCE_PVT" as
/* $Header: OKEVKFDB.pls 120.2 2005/11/23 14:37:58 ausmani noship $ */

--
-- Local Variables
--

L_USERID		NUMBER 	     	:= FND_GLOBAL.USER_ID;
L_LOGINID		NUMBER		:= FND_GLOBAL.LOGIN_ID;



--
-- Private Procedures and Functions
--


--
-- Procedure: validate_agreement_org
--
-- Description: This procedure is used to validate agreement_org_id
--
--

PROCEDURE validate_agreement_org(p_agreement_org_id			NUMBER	,
				 --p_k_header_id			NUMBER	,
			     	 p_return_status	OUT NOCOPY	VARCHAR2
			    	) is

   cursor c_agreement_org_id is
      select 'x'
      from   pa_organizations_project_v p
      where  organization_id = p_agreement_org_id
      and    sysdate between decode(date_from, null, sysdate, date_from)
      and    decode(date_to, null, sysdate, date_to);

   cursor c_agreement_org_id2 is
      select 'x'
      from   hr_all_organization_units
      where  organization_id = p_agreement_org_id
      and    sysdate between decode(date_from, null, sysdate, date_from)
      and    decode(date_to, null, sysdate, date_to);

   l_dummy_value	VARCHAR2(1) := '?';
   l_install		VARCHAR2(1);

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_agreement_org_id is not null) 			OR
      (p_agreement_org_id  <> OKE_API.G_MISS_NUM) 	THEN

      l_install := fnd_profile.value('PA_BILLING_LICENSED');

      if (nvl(l_install, 'N') = 'Y') then

         OPEN c_agreement_org_id;
         FETCH c_agreement_org_id into l_dummy_value;
         CLOSE c_agreement_org_id;

      else

         OPEN c_agreement_org_id2;
         FETCH c_agreement_org_id2 into l_dummy_value;
         CLOSE c_agreement_org_id2;

      end if;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'agreement_org_id'
      			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

      END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_agreement_org_id%ISOPEN THEN
         CLOSE c_agreement_org_id;
      END IF;

END validate_agreement_org;

--
-- Function: get_funding_source_id
--
-- Description: This function is used to get the funding source id for new record
--

FUNCTION get_funding_source_id RETURN NUMBER is

   l_funding_source_id		NUMBER;

BEGIN

   select oke_k_funding_sources_s.nextval
   into   l_funding_source_id
   from   dual;

   return(l_funding_source_id);

END get_funding_source_id;


--
-- Function: get_min_unit
--
-- Description: This function is used to get the minimium currency unit
--

FUNCTION get_min_unit(p_currency	VARCHAR2) RETURN NUMBER is

   l_min_unit		NUMBER;

   cursor c_currency is
      select nvl(minimum_accountable_unit, power(10, -1 * precision))
      from   fnd_currencies
      where  currency_code = p_currency;

BEGIN

   OPEN c_currency;
   FETCH c_currency into l_min_unit;

   IF (c_currency%NOTFOUND) THEN
      CLOSE c_currency;
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
   END IF;

   CLOSE c_currency;
   return(l_min_unit);

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   WHEN OTHERS THEN
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_currency%ISOPEN THEN
         CLOSE c_currency;
      END IF;
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END get_min_unit;


--
-- Function: get_k_currency
--
-- Description: This function is used to get contract currency
--
--

FUNCTION get_k_currency(p_header_id	NUMBER) RETURN VARCHAR2 is

   l_currency_code		VARCHAR2(15);

   cursor c_currency is
      select currency_code
      from   okc_k_headers_b
      where  id = p_header_id;

BEGIN

   OPEN c_currency;
   FETCH c_currency into l_currency_code;

   IF (c_currency%NOTFOUND) THEN

      CLOSE c_currency;
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   END IF;

   return(l_currency_code);
   CLOSE c_currency;

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   WHEN OTHERS THEN
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_currency%ISOPEN THEN
         CLOSE c_currency;
      END IF;
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END get_k_currency;


--
-- Procedure: update_agreement_reference
--
-- Description: This procedure is used to update pa's agreement reference and product code columns
--
--

PROCEDURE update_agreement_reference(p_agreement_id			NUMBER		,
				     p_org_id				NUMBER		,
				     p_currency_code			VARCHAR2	,
				     p_funding_source_id		NUMBER		,
				     p_num_update_flag			VARCHAR2
			            ) is
  cursor c_length(b_owner varchar2) is
   select data_length
   from   all_tab_columns
   where  table_name = 'PA_AGREEMENTS_ALL'
   and    owner = b_owner
   and    column_name = 'AGREEMENT_NUM';

  l_length NUMBER := 0;
  l_return_status boolean;
  l_status        varchar2(10);
  l_industry      varchar2(200);
  l_table_owner   varchar2(10);

BEGIN
  l_return_status := FND_INSTALLATION.GET_APP_INFO(
                                      application_short_name => 'PA',
                                      status                 => l_status,
                                      industry               => l_industry,
                                      oracle_schema          => l_table_owner);

   open c_length(l_table_owner);
   fetch c_length into l_length;
   close c_length;

   update pa_agreements_all
   set    pm_product_code        = G_PRODUCT_CODE,
   --       agreement_num		 = decode(p_num_update_flag, 'Y', substr(agreement_num, 0, 20-1-length(p_currency_code)) || '-' || p_currency_code,
    --      						     'N', agreement_num, agreement_num),
          agreement_num		 = decode(p_num_update_flag, 'Y', substr(agreement_num, 0, l_length-1-length(p_currency_code)) || '-' || p_currency_code,
          						     'N', agreement_num, agreement_num),
	  --agreement_num		 = substr(agreement_num, 0, 20-1-length(p_currency_code)) || '-' || p_currency_code,
          pm_agreement_reference = p_org_id || '-' || p_currency_code || '-' || p_funding_source_id
--   	  pm_agreement_reference = p_org_id || '-Y-' || p_funding_source_id
   where  agreement_id = p_agreement_id;

EXCEPTION
  WHEN OTHERS THEN
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END update_agreement_reference;


--
-- Procedure: update_proj_fld_reference
--
-- Description: This procedure is used to update pa's agreement reference and product code columns
--
--

PROCEDURE update_proj_fld_reference(p_project_funding_id		NUMBER	,
				    p_fund_allocation_id		NUMBER
			            ) is

BEGIN

   update pa_project_fundings
   set    pm_product_code        = G_PRODUCT_CODE,
   	  pm_funding_reference   = p_fund_allocation_id || '.1'
   where  project_funding_id = p_project_funding_id;

EXCEPTION
  WHEN OTHERS THEN
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END update_proj_fld_reference;


--
-- Procedure: get_conversion
--
-- Description: This procedure is used to get the conversion rate
--
--

PROCEDURE get_conversion(p_from_currency			VARCHAR2		,
			 p_to_currency				VARCHAR2		,
			 p_conversion_type			VARCHAR2		,
			 p_conversion_date			DATE			,
			 p_conversion_rate	 IN OUT NOCOPY	NUMBER			,
			 p_return_status	 OUT    NOCOPY	VARCHAR2
			) is

   l_return_status	VARCHAR2(1);

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_from_currency <> p_to_currency) THEN

      IF (p_conversion_type is null) THEN

         OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			     p_msg_name			=>	'OKE_API_MISSING_VALUE'						,
      			     p_token1			=>	'VALUE'								,
      			     p_token1_value		=>	'conversion_type'
  			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;


      ELSIF (p_conversion_date is null) THEN

         OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			     p_msg_name			=>	'OKE_API_MISSING_VALUE'						,
      			     p_token1			=>	'VALUE'								,
      			     p_token1_value		=>	'conversion_date'
  			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

      ELSE

         -- syho, bug 2208979
         IF (upper(p_conversion_type) <> 'USER') THEN

             IF (p_conversion_rate is null) THEN

                 OKE_FUNDING_UTIL_PKG.get_conversion_rate(x_from_currency	=>	p_from_currency				,
           				                  x_to_currency		=>	p_to_currency				,
           				                  x_conversion_type	=>	p_conversion_type			,
           				                  x_conversion_date	=>	p_conversion_date			,
           				                  x_conversion_rate	=>	p_conversion_rate			,
           				                  x_return_status	=>	l_return_status
           				                 );

                 IF (l_return_status = 'N') THEN

                     OKE_API.set_message(p_app_name			=> 	G_APP_NAME			,
      			                 p_msg_name			=>	'OKE_FUND_NO_RATE'
  			                );

                     p_return_status := OKE_API.G_RET_STS_ERROR;

                 END IF;

             ELSE

                 OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			             p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			             p_token1			=>	'VALUE'								,
      			             p_token1_value		=>	'conversion_rate'
  			            );

                 p_return_status := OKE_API.G_RET_STS_ERROR;

             END IF;

         ELSIF (p_conversion_rate is null) THEN

             OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			         p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			         p_token1			=>	'VALUE'								,
      			         p_token1_value			=>	'conversion_rate'
  			        );

             p_return_status := OKE_API.G_RET_STS_ERROR;

         END IF;

      END IF;

   ELSIF (p_conversion_type is not null) THEN

         OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			     p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			     p_token1			=>	'VALUE'								,
      			     p_token1_value		=>	'conversion_type'
  			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

   ELSIF (p_conversion_date is not null) THEN

         OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			     p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			     p_token1			=>	'VALUE'								,
      			     p_token1_value		=>	'conversion_date'
  			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

   ELSIF (p_conversion_rate is not null) THEN

         OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			     p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			     p_token1			=>	'VALUE'								,
      			     p_token1_value		=>	'conversion_rate'
  			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

   END IF;

END get_conversion;


--
-- Procedure: validate_object_type
--
-- Description: This procedure is used to validate object_type
--
--

PROCEDURE validate_object_type(p_object_type 			VARCHAR2	,
			       p_return_status	OUT NOCOPY	VARCHAR2
			       ) is
BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_object_type is null) 			OR
      (p_object_type  = OKE_API.G_MISS_CHAR) 	THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'object_type'
     			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

   ELSE

     IF (upper(p_object_type) <> G_OBJECT_TYPE) THEN

        OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			    p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			    p_token1		=>	'VALUE'			,
      			    p_token1_value	=>	'object_type'
      			   );

        p_return_status := OKE_API.G_RET_STS_ERROR;

     END IF;

   END IF;

END validate_object_type;


--
-- Procedure: validate_amount
--
-- Description: This procedure is used to validate amount
--
--

PROCEDURE validate_amount(p_amount			NUMBER	,
			  p_return_status  OUT NOCOPY	VARCHAR2
			 ) is

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_amount is null) 			OR
      (p_amount  = OKE_API.G_MISS_NUM) 		THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'amount'
     			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

   ELSIF (p_amount < 0) THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_FUND_NEGATIVE_AMT'
     			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

   END IF;

END validate_amount;


--
-- Procedure: validate_funding_source_id
--
-- Description: This procedure is used to validate the funding source id
--
--

PROCEDURE validate_funding_source_id(p_funding_source_id 			NUMBER	,
				     p_rowid			OUT NOCOPY	VARCHAR2,
				     p_pool_party_id		OUT NOCOPY	NUMBER	,
				     p_agreement_flag		OUT NOCOPY	VARCHAR2
			            ) is
   cursor c_funding_source_id is
      select rowid, pool_party_id, agreement_flag
      from   oke_k_funding_sources
      where  funding_source_id = p_funding_source_id;

BEGIN

   IF (p_funding_source_id is null) 			OR
      (p_funding_source_id  = OKE_API.G_MISS_NUM) 	THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'funding_source_id'
     			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   OPEN c_funding_source_id;
   FETCH c_funding_source_id into p_rowid, p_pool_party_id, p_agreement_flag;

   IF (c_funding_source_id%NOTFOUND) THEN

      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			  p_token1		=>	'VALUE'			,
      			  p_token1_value	=>	'funding_source_id'
      			 );

      CLOSE c_funding_source_id;
      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   CLOSE c_funding_source_id;

EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
      raise G_EXCEPTION_HALT_VALIDATION;

   WHEN OTHERS THEN
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_funding_source_id%ISOPEN THEN
         CLOSE c_funding_source_id;
      END IF;

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END validate_funding_source_id;


--
-- Procedure: validate_object_id
--
-- Description: This procedure is used to validate object_id
--
--

PROCEDURE validate_object_id(p_object_id 			NUMBER	,
			     p_return_status	OUT NOCOPY	VARCHAR2
			    ) is

   cursor c_object_id is
      select 'x'
      from   oke_k_headers
      where  k_header_id = p_object_id;

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_object_id is null) 			OR
      (p_object_id  = OKE_API.G_MISS_NUM) 	THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'object_id'
     			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

   ELSE

      OPEN c_object_id;
      FETCH c_object_id into l_dummy_value;
      CLOSE c_object_id;

     IF (l_dummy_value = '?') THEN

        OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			    p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			    p_token1		=>	'VALUE'			,
      			    p_token1_value	=>	'object_id'
      			   );

        p_return_status := OKE_API.G_RET_STS_ERROR;

     END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_object_id%ISOPEN THEN
         CLOSE c_object_id;
      END IF;

END validate_object_id;


--
-- Procedure: validate_currency_code
--
-- Description: This procedure is used to validate currency_code
--
--

PROCEDURE validate_currency_code(p_currency_code			VARCHAR2	,
			         p_return_status	OUT NOCOPY	VARCHAR2
			        ) is

   cursor c_currency_code is
      select 'x'
      from   fnd_currencies
      where  currency_code = upper(p_currency_code);

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_currency_code is null) 			OR
      (p_currency_code  = OKE_API.G_MISS_CHAR) 		THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'currency_code'
     			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

   ELSE

      OPEN c_currency_code;
      FETCH c_currency_code into l_dummy_value;
      CLOSE c_currency_code;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'currency_code'
      			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

      END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME	        ,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_currency_code%ISOPEN THEN
         CLOSE c_currency_code;
      END IF;

END validate_currency_code;


--
-- Procedure: validate_agreement_id
--
-- Description: This procedure is used to validate agreement_id and check if all projects in project
--		fundings are under a valid project hierarchy
--
--

PROCEDURE validate_agreement_id(p_agreement_id	IN		NUMBER		,
			        p_object_id	IN		NUMBER		,
			        p_return_status	OUT NOCOPY	VARCHAR2
			      ) is

   cursor c_agreement_id is
      select 'x'
      from   pa_agreements_all
      where  agreement_id = p_agreement_id
      and    nvl(pm_product_code, '-99') <> G_PRODUCT_CODE;

   cursor c_master_project is
      select project_id
      from   oke_k_headers
      where  k_header_id = p_object_id;

   cursor c_project (x_project_id number) is
      select 'x'
      from   pa_project_fundings
      where  agreement_id = p_agreement_id
      and    project_id not in
      (select to_number(sub_project_id)
       from   pa_fin_structures_links_v
       start with parent_project_id = x_project_id
       connect by parent_project_id = prior sub_project_id
       union all
       select x_project_id
       from   dual
      );

   l_dummy_value	VARCHAR2(1) := '?';
   l_project_id		NUMBER;

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_agreement_id is null) 			OR
      (p_agreement_id  = OKE_API.G_MISS_NUM) 	THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME	        	,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'agreement_id'
     			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

   ELSE

      OPEN c_agreement_id;
      FETCH c_agreement_id into l_dummy_value;
      CLOSE c_agreement_id;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME	        ,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'agreement_id'
      			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

      END IF;

      OPEN c_master_project;
      FETCH c_master_project into l_project_id;
      CLOSE c_master_project;

      IF (l_project_id is null) THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME	        ,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'agreement_id'
      			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

      ELSE

         l_dummy_value := '?';
         OPEN c_project(l_project_id);
         FETCH c_project into l_dummy_value;
         CLOSE c_project;

         IF (l_dummy_value = 'x') THEN

            OKE_API.set_message(p_app_name		=>	G_APP_NAME	        ,
      			        p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			        p_token1		=>	'VALUE'			,
      			        p_token1_value		=>	'agreement_id'
      			       );

       	    p_return_status := OKE_API.G_RET_STS_ERROR;

         END IF;

      END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_agreement_id%ISOPEN THEN
         CLOSE c_agreement_id;
      END IF;

END validate_agreement_id;



--
-- Procedure: lock_agreement_id
--
-- Description: This procedure is used to lock the agreement record
--
--

PROCEDURE lock_agreement_id(p_agreement_id	IN		NUMBER		,
			    p_return_status	OUT NOCOPY	VARCHAR2
			   ) is

   cursor c_agreement_id is
      select 'x'
      from   pa_agreements_all
      where  agreement_id = p_agreement_id
   FOR UPDATE OF agreement_id NOWAIT;

   l_dummy_value 	varchar2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   OPEN c_agreement_id;
   FETCH c_agreement_id into l_dummy_value;
   CLOSE c_agreement_id;

   IF (l_dummy_value = '?') THEN

       OKE_API.set_message(p_app_name		=>	G_APP_NAME	        ,
      			   p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			   p_token1		=>	'VALUE'			,
      			   p_token1_value	=>	'agreement_id'
      			  );

       p_return_status := OKE_API.G_RET_STS_ERROR;

   END IF;

EXCEPTION
   WHEN G_RESOURCE_BUSY THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_ROW_LOCKED'	,
      			  p_token1		=>	'SOURCE'		,
      			  p_token1_value	=>	'OKE_AGREEMENT_PROMPT'	,
      			  p_token1_translate 	=>      OKE_API.G_TRUE		,
      			  p_token2		=>	'ID'			,
      			  p_token2_value	=>	p_agreement_id
      			 );

      IF c_agreement_id%ISOPEN THEN
         CLOSE c_agreement_id;
      END IF;

   WHEN OTHERS THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_agreement_id%ISOPEN THEN
         CLOSE c_agreement_id;
      END IF;

END lock_agreement_id;


--
-- Procedure: lock_project_funding
--
-- Description: This procedure is used to lock the project funding records
--
--

PROCEDURE lock_project_funding(p_agreement_id	IN		NUMBER		,
			       p_return_status	OUT NOCOPY	VARCHAR2
			      ) is

   cursor c_project_funding is
      select 'x'
      from   pa_project_fundings
      where  agreement_id = p_agreement_id
   FOR UPDATE OF project_funding_id NOWAIT;

   l_dummy_value 	varchar2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   OPEN c_project_funding;
   FETCH c_project_funding into l_dummy_value;
   CLOSE c_project_funding;

EXCEPTION
   WHEN G_RESOURCE_BUSY THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		 ,
      			  p_msg_name		=>	'OKE_ROW_LOCKED'	 ,
      			  p_token1		=>	'SOURCE'		 ,
      			  p_token1_value	=>	'OKE_PRJ_FUNDING_PROMPT' ,
      			  p_token1_translate	=>	OKE_API.G_TRUE		 ,
      			  p_token2		=>	'ID'			 ,
      			  p_token2_value	=>	null
      			 );

      IF c_project_funding%ISOPEN THEN
         CLOSE c_project_funding;
      END IF;

   WHEN OTHERS THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_project_funding%ISOPEN THEN
         CLOSE c_project_funding;
      END IF;

END lock_project_funding;



--
-- Procedure: lock_agreement
--
-- Description: This procedure is used to lock the agreement records
--
--

PROCEDURE lock_agreement(p_agreement_id		IN	NUMBER
		        ) is

   l_return_status	VARCHAR2(1);

BEGIN

   lock_agreement_id(p_agreement_id	=>	p_agreement_id	,
   		     p_return_status	=>	l_return_status
   		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   lock_project_funding(p_agreement_id	=>	p_agreement_id	,
   		        p_return_status	=>	l_return_status
   		       );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

END lock_agreement;


--
-- Procedure: validate_k_party_id
--
-- Description: This procedure is used to validate k_party_id
--
--

PROCEDURE validate_k_party_id(p_k_header_id	IN		NUMBER		,
			      p_k_party_id 	IN		NUMBER		,
			      p_return_status	OUT NOCOPY	VARCHAR2
			      ) is
   cursor c_party_id is
      select 'x'
      from   okc_k_party_roles_b b,
             okx_parties_v v
      where  dnz_chr_id = p_k_header_id
      and    b.object1_id1 = v.id1
      and    b.object1_id2 = v.id2
      and    b.rle_code = 'FUND_BY'
      and    b.jtot_object1_code = 'OKX_PARTY'
      and    v.id1 = p_k_party_id;

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_k_party_id is null) 			OR
      (p_k_party_id  = OKE_API.G_MISS_NUM) 	THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME	        	,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'k_party_id'
     			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

   ELSE

      OPEN c_party_id;
      FETCH c_party_id into l_dummy_value;
      CLOSE c_party_id;

     IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME	        ,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'k_party_id'
      			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

     END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_party_id%ISOPEN THEN
         CLOSE c_party_id;
      END IF;

END validate_k_party_id;


--
-- Procedure: validate_funding_status
--
-- Description: This procedure is used to validate funding_status
--
--

PROCEDURE validate_funding_status(p_funding_status			VARCHAR2	,
			          p_return_status	OUT NOCOPY	VARCHAR2
			         ) is

   cursor c_funding_status is
      select 'x'
      from   fnd_lookup_values
      where  lookup_type = 'FUNDING_STATUS'
      and    enabled_flag = 'Y'
      and    language = userenv('LANG')
      and    lookup_code = upper(p_funding_status);

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_funding_status is not null) THEN

      OPEN c_funding_status;
      FETCH c_funding_status into l_dummy_value;
      CLOSE c_funding_status;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      		     	     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'funding_status'
      			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

      END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_funding_status%ISOPEN THEN
         CLOSE c_funding_status;
      END IF;

END validate_funding_status;


--
-- Procedure: validate_conversion_type
--
-- Description: This procedure is used to validate conversion_type
--
--

PROCEDURE validate_conversion_type(p_conversion_type			VARCHAR2	,
			           p_return_status	OUT NOCOPY	VARCHAR2
			         ) is

   cursor c_type is
      select 'x'
      from   gl_daily_conversion_types
      where  UPPER(conversion_type) = UPPER(p_conversion_type);

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_conversion_type is not null) THEN

      OPEN c_type;
      FETCH c_type into l_dummy_value;
      CLOSE c_type;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      		     	     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'conversion_type'
      			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

      END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_type%ISOPEN THEN
         CLOSE c_type;
      END IF;

END validate_conversion_type;


--
-- Procedure: validate_pool_party_id
--
-- Description: This procedure is used to validate pool_party_id
--
--

PROCEDURE validate_pool_party_id(p_pool_party_id			NUMBER		,
			         p_return_status	OUT NOCOPY	VARCHAR2
			         ) is

   cursor c_pool_party_id is
      select 'x'
      from   oke_pool_parties
      where  pool_party_id = p_pool_party_id
      FOR UPDATE OF pool_party_id NOWAIT;

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_pool_party_id is not null) THEN

      OPEN c_pool_party_id;
      FETCH c_pool_party_id into l_dummy_value;
      CLOSE c_pool_party_id;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      		     	     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'pool_party_id'
      			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

      END IF;

   END IF;

EXCEPTION
   WHEN G_RESOURCE_BUSY THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_ROW_LOCKED'	,
      			  p_token1		=>	'SOURCE'		,
      			  p_token1_value	=>	'OKE_POOL_PARTY_PROMPT'	,
      			  p_token1_translate	=>	OKE_API.G_TRUE		,
      			  p_token2		=>	'ID'			,
      			  p_token2_value	=>	p_pool_party_id
      			 );

      IF c_pool_party_id%ISOPEN THEN
         CLOSE c_pool_party_id;
      END IF;

   WHEN OTHERS THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_pool_party_id%ISOPEN THEN
         CLOSE c_pool_party_id;
      END IF;

END validate_pool_party_id;


--
-- Procedure: validate_pool_party_related
--
-- Description: This procedure is used to validate pool party related attributes
--
--

PROCEDURE validate_pool_party_related(p_pool_party_id				NUMBER	,
				      p_party_id				NUMBER	,
				      p_funding_source_id			NUMBER	,
			              p_amount					NUMBER	,
			              p_currency_code				VARCHAR2,
			              p_start_date				DATE	,
			              p_end_date				DATE	,
			              p_return_status		OUT NOCOPY	VARCHAR2
			            ) is
   cursor c_pool_party_id is
      select currency_code
      from   oke_pool_parties
      where  pool_party_id = p_pool_party_id
      and    party_id	   = p_party_id
   FOR UPDATE OF pool_party_id NOWAIT;

   l_currency_code	VARCHAR2(15);
   l_return_status	VARCHAR2(1);
   l_flag		VARCHAR2(1);

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_pool_party_id is not null)		 OR
      (p_pool_party_id <> OKE_API.G_MISS_NUM) 	 THEN

      OPEN c_pool_party_id;
      FETCH c_pool_party_id into l_currency_code;

      IF (c_pool_party_id%NOTFOUND) THEN

          CLOSE c_pool_party_id;
   	  p_return_status := OKE_API.G_RET_STS_ERROR;
   	   OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
      			       p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			       p_token1			=>	'VALUE'				,
			       p_token1_value		=>	'pool_party_id, k_party_id'
      			      );

      ELSE

          IF (l_currency_code <> p_currency_code) THEN

   	      p_return_status := OKE_API.G_RET_STS_ERROR;
   	      OKE_API.set_message(p_app_name			=>	G_APP_NAME			,
      			          p_msg_name			=>	'OKE_API_INVALID_VALUE'		,
      			          p_token1			=>	'VALUE'				,
			          p_token1_value		=>	'currency_code'
      			         );
     	 ELSE

     	      IF (p_funding_source_id is not null) THEN
     	        l_flag := 'N';
     	      ELSE
     	        l_flag := 'Y';
     	      END IF;

              OKE_FUNDING_UTIL_PKG.validate_source_pool_amount(x_first_amount			=>	p_amount		,
  			   				       x_pool_party_id			=>	p_pool_party_id		,
  			   				       x_source_id			=>	p_funding_source_id	,
  			   	       			       x_new_flag			=>	l_flag			,
  			        			       x_return_status			=>	l_return_status 	);

  	      IF (l_return_status = 'N') THEN

   	          p_return_status := OKE_API.G_RET_STS_ERROR;
  	          OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
      			              p_msg_name		=>	'OKE_FUND_EXCEED_POOL'
      			             );

              -- bug 3346170
	     /* ELSE

                  OKE_FUNDING_UTIL_PKG.validate_source_pool_date(x_start_end				=>	'START'		,
  				     		                 x_pool_party_id			=>	p_pool_party_id	,
  		         	     			         x_date					=>	p_start_date	,
  		          	        		         x_return_status			=>	l_return_status );

  	          IF (l_return_status = 'N') THEN

   	              p_return_status := OKE_API.G_RET_STS_ERROR;
  	              OKE_API.set_message(p_app_name				=>	G_APP_NAME			,
      			                  p_msg_name				=>	'OKE_FUND_INVALID_PTY_DATE'	,
      			                  p_token1				=>	'EFFECTIVE_DATE'		,
      			                  p_token1_value			=>	'OKE_EFFECTIVE_FROM_PROMPT'	,
      			                  p_token1_translate			=>	OKE_API.G_TRUE			,
      			                  p_token2				=>	'OPERATOR'			,
      			                  p_token2_value			=>	'OKE_GREATER_PROMPT'		,
      			                  p_token2_translate			=>	OKE_API.G_TRUE			,
      			                  p_token3				=>	'DATE_SOURCE'			,
      			                  p_token3_value			=>	'OKE_POOL_PARTY_PROMPT'		,
      			                  p_token3_translate			=>	OKE_API.G_TRUE
      			                 );

                  ELSE

  	              OKE_FUNDING_UTIL_PKG.validate_source_pool_date(x_start_end			=>	'END'		,
  				     		              	     x_pool_party_id			=>	p_pool_party_id	,
  		         	     			             x_date				=>	p_end_date	,
  		          	        		             x_return_status			=>	l_return_status );

  	              IF (l_return_status = 'N') THEN

   	                 p_return_status := OKE_API.G_RET_STS_ERROR;
  	                 OKE_API.set_message(p_app_name			=>	G_APP_NAME			,
      			                     p_msg_name			=>	'OKE_FUND_INVALID_PTY_DATE'	,
      			                     p_token1			=>	'EFFECTIVE_DATE'		,
      			                     p_token1_value		=>	'OKE_EFFECTIVE_TO_PROMPT'	,
      			                     p_token1_translate		=>	OKE_API.G_TRUE			,
      			                     p_token2			=>	'OPERATOR'			,
      			                     p_token2_value		=>	'OKE_EARLIER_PROMPT'		,
      			                     p_token2_translate		=>	OKE_API.G_TRUE			,
      			                     p_token3			=>	'DATE_SOURCE'			,
      			                     p_token3_value		=>	'OKE_POOL_PARTY_PROMPT'		,
      			                     p_token3_translate		=>	OKE_API.G_TRUE
      			                    );
     	              END IF;

     	         END IF;
     	 */
              END IF;

           END IF;

           CLOSE c_pool_party_id;

      END IF;

   END IF;

EXCEPTION
   WHEN G_RESOURCE_BUSY THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_ROW_LOCKED'	,
      			  p_token1		=>	'SOURCE'		,
      			  p_token1_value	=>	'OKE_POOL_PARTY_PROMPT'	,
      			  p_token1_translate	=>	OKE_API.G_TRUE		,
      			  p_token2		=>	'ID'			,
      			  p_token2_value	=>	p_pool_party_id
      			 );

      IF c_pool_party_id%ISOPEN THEN
         CLOSE c_pool_party_id;
      END IF;

   WHEN OTHERS THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_pool_party_id%ISOPEN THEN
         CLOSE c_pool_party_id;
      END IF;

END validate_pool_party_related;


--
-- Procedure: validate_attributes
--
-- Description: This procedure is used to validate the attributes of funding_in_rec
--
--

PROCEDURE validate_attributes(p_funding_in_rec	FUNDING_REC_IN_TYPE)
                             is

  l_return_status 	VARCHAR2(1);

BEGIN

   --
   -- Validate Object_type
   --

   validate_object_type(p_object_type	=>	p_funding_in_rec.object_type	,
   			p_return_status	=>	l_return_status
   		       );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate Object_id
   --

   validate_object_id(p_object_id	=>	p_funding_in_rec.object_id	,
   		      p_return_status	=>	l_return_status
   		     );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate Currency Code
   --

   validate_currency_code(p_currency_code	=>	p_funding_in_rec.currency_code	,
   		     	  p_return_status	=>	l_return_status
   		         );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate K_party_id
   --
   validate_k_party_id(p_k_header_id	=>	p_funding_in_rec.object_id	,
   		       p_k_party_id	=>	p_funding_in_rec.k_party_id	,
   		       p_return_status	=>	l_return_status
   		      );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate Amount
   --

   validate_amount(p_amount		=>	p_funding_in_rec.amount	,
   		   p_return_status  	=>	l_return_status
   		  );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate Funding_status
   --

   validate_funding_status(p_funding_status	=>	p_funding_in_rec.funding_status	,
   			   p_return_status	=>	l_return_status
   		          );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate Conversion_type
   --

   validate_conversion_type(p_conversion_type	=>	p_funding_in_rec.k_conversion_type	,
   			    p_return_status	=>	l_return_status
   		           );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate Pool_party_id
   --

   validate_pool_party_id(p_pool_party_id	=>	p_funding_in_rec.pool_party_id	,
   			    p_return_status	=>	l_return_status
   		           );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate Agreement Owning Org Id
   --
   validate_agreement_org(p_agreement_org_id	=>	p_funding_in_rec.agreement_org_id	,
   			 -- p_k_header_id		=>	p_funding_in_rec.object_id		,
   			  p_return_status	=>	l_return_status
   			 );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

END validate_attributes;


--
-- Procedure: validate_record
--
-- Description: This procedure is used to validate the funding record
--
--

PROCEDURE validate_record(p_funding_in_rec	IN OUT NOCOPY	FUNDING_REC_IN_TYPE	,
			  p_flag				VARCHAR2
			  ) is

  l_return_status 	VARCHAR2(1);
  l_currency_code	VARCHAR2(15);
  l_type		VARCHAR2(20);

BEGIN

   --
   -- Validate start and end date range
   --

   OKE_FUNDING_UTIL_PKG.validate_start_end_date(x_start_date	=>	p_funding_in_rec.start_date_active	,
   						x_end_date	=>	p_funding_in_rec.end_date_active	,
   						x_return_status =>	l_return_status
   					       );

   IF (l_return_status = 'N') THEN

       OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			   p_msg_name			=>	'OKE_INVALID_EFFDATE_PAIR'
  			  );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate pool_party_id related attributes
   --

   validate_pool_party_related(p_pool_party_id		=>	p_funding_in_rec.pool_party_id		,
			       p_party_id		=>	p_funding_in_rec.k_party_id		,
			       p_amount			=>	p_funding_in_rec.amount			,
			       p_currency_code		=>	p_funding_in_rec.currency_code		,
			       p_start_date		=>	p_funding_in_rec.start_date_active	,
			       p_end_date		=>	p_funding_in_rec.end_date_active	,
			       p_funding_source_id	=>	p_funding_in_rec.funding_source_id	,
			       p_return_status		=>	l_return_status
			      );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate contract conversion
   --

   --
   -- Get contract currency
   --

   l_currency_code := get_k_currency(p_header_id	=>	p_funding_in_rec.object_id);

   -- syho, bug 2208979
   IF (nvl(p_flag, 'N') = 'Y') THEN

       get_conversion(p_from_currency		=>	p_funding_in_rec.currency_code		,
      		      p_to_currency		=>	l_currency_code				,
      		      p_conversion_type		=>	p_funding_in_rec.k_conversion_type	,
      		      p_conversion_date		=>	p_funding_in_rec.k_conversion_date	,
      		      p_conversion_rate		=>	p_funding_in_rec.k_conversion_rate	,
      		      p_return_status		=>	l_return_status
      		     );

       IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

           RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

   END IF;
   -- syho, bug 2208979

   --
   -- Hard limit cannot be negative
   --
   IF (nvl(p_funding_in_rec.hard_limit, 0) < 0) THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME				,
      			  p_msg_name		=>	'OKE_NEGATIVE_HARD_LIMIT'
      			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (nvl(p_funding_in_rec.revenue_hard_limit, 0) < 0) THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME				,
      			  p_msg_name		=>	'OKE_NEGATIVE_REVENUE_LIMIT'
      			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate hard limit against funding amount
   --

   OKE_FUNDING_UTIL_PKG.validate_hard_limit(x_fund_amount 		=>	p_funding_in_rec.amount		,
   					    x_hard_limit		=>	p_funding_in_rec.hard_limit	,
   					    x_return_status		=>	l_return_status
   					   );

   IF (l_return_status <> 'Y') THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME				,
      			  p_msg_name		=>	'OKE_HARD_LIMIT_EXCEED_FUND'
      			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   OKE_FUNDING_UTIL_PKG.validate_hard_limit(x_fund_amount 		=>	p_funding_in_rec.amount			,
   					    x_hard_limit		=>	p_funding_in_rec.revenue_hard_limit	,
   					    x_return_status		=>	l_return_status
   					   );

   IF (l_return_status <> 'Y') THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME				,
      			  p_msg_name		=>	'OKE_REV_LIMIT_EXCEED_FUND'
      			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate hard limit w/ allocation lines
   --

   IF (p_funding_in_rec.funding_source_id is not null) THEN

      OKE_FUNDING_UTIL_PKG.validate_source_alloc_limit(x_source_id				=>	p_funding_in_rec.funding_source_id		,
  						       x_amount					=>	nvl(p_funding_in_rec.hard_limit, 0)		,
  						       x_revenue_amount				=>	nvl(p_funding_in_rec.revenue_hard_limit, 0)	,
  						       x_type					=>	l_type						,
  			   	        	       x_return_status				=>	l_return_status
  			   	        	       );

      IF (l_return_status = 'N') THEN

          IF (l_type = 'INVOICE') THEN

             OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			         p_msg_name		=>	'OKE_HARD_LIMIT_EXCEED'
      			        );

      	  ELSE

             OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			         p_msg_name		=>	'OKE_REV_LIMIT_EXCEED'
      			        );

      	  END IF;

          RAISE G_EXCEPTION_HALT_VALIDATION;

      ELSIF (l_return_status = 'E') THEN

      	  IF (l_type = 'INVOICE') THEN

             OKE_API.set_message(p_app_name			=> 	G_APP_NAME			,
      			     	 p_msg_name			=>	'OKE_NEGATIVE_HARD_LIMIT_SUM'
      			     	);

      	  ELSE

             OKE_API.set_message(p_app_name			=> 	G_APP_NAME			,
      			     	 p_msg_name			=>	'OKE_NEGATIVE_REV_LIMIT_SUM'
      			     	);

      	  END IF;

          RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

      --
      -- Validate funding amount
      --

      OKE_FUNDING_UTIL_PKG.validate_source_alloc_amount(x_source_id				=>	p_funding_in_rec.funding_source_id	,
  						        x_amount				=>	nvl(p_funding_in_rec.amount,0)		,
  			   	        	        x_return_status				=>	l_return_status
  			   	        	        );

      IF (l_return_status = 'N') THEN

         OKE_API.set_message(p_app_name			=> 	G_APP_NAME			,
      			     p_msg_name			=>	'OKE_FUND_AMT_EXCEED'
      			    );

         RAISE G_EXCEPTION_HALT_VALIDATION;

      ELSIF (l_return_status = 'E') THEN

         OKE_API.set_message(p_app_name			=> 	G_APP_NAME			,
      			     p_msg_name			=>	'OKE_NEGATIVE_ALLOCATION_SUM'
      			    );

         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

      --
      -- Validate the date range
      --
      -- bug 3346170
      /*
      OKE_FUNDING_UTIL_PKG.validate_source_alloc_date(x_start_end			=>	'START'					,
  				      		      x_funding_source_id		=>	p_funding_in_rec.funding_source_id	,
  		         	       	  	      x_date				=>	p_funding_in_rec.start_date_active	,
  		          	      		      x_return_status			=>	l_return_status);

      IF (l_return_status = 'N') THEN

         OKE_API.set_message(p_app_name			=> 	G_APP_NAME			,
      			     p_msg_name			=>	'OKE_FUND_INVALID_PTY_DATE'	,
      			     p_token1			=> 	'EFFECTIVE_DATE'		,
      			     p_token1_value		=> 	'OKE_EFFECTIVE_FROM_PROMPT'	,
      			     p_token1_translate		=>	OKE_API.G_TRUE			,
      			     p_token2			=> 	'OPERATOR'			,
      			     p_token2_value		=> 	'OKE_EARLIER_PROMPT'		,
      			     p_token2_translate		=>	OKE_API.G_TRUE			,
      			     p_token3			=> 	'DATE_SOURCE'			,
      			     p_token3_value		=> 	'OKE_EARLIEST_ALLOC_PROMPT'	,
      			     p_token3_translate		=>	OKE_API.G_TRUE
      			    );

         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

      OKE_FUNDING_UTIL_PKG.validate_source_alloc_date(x_start_end			=>	'END'					,
  				      		      x_funding_source_id		=>	p_funding_in_rec.funding_source_id	,
  		         	       	  	      x_date				=>	p_funding_in_rec.end_date_active	,
  		          	      		      x_return_status			=>	l_return_status);

      IF (l_return_status = 'N') THEN

         OKE_API.set_message(p_app_name			=> 	G_APP_NAME			,
      			     p_msg_name			=>	'OKE_FUND_INVALID_PTY_DATE'	,
      			     p_token1			=> 	'EFFECTIVE_DATE'		,
      			     p_token1_value		=> 	'OKE_EFFECTIVE_TO_PROMPT'	,
      			     p_token1_translate		=>	OKE_API.G_TRUE			,
      			     p_token2			=> 	'OPERATOR'			,
      			     p_token2_value		=> 	'OKE_GREATER_PROMPT'		,
      			     p_token2_translate		=>	OKE_API.G_TRUE			,
      			     p_token3			=> 	'DATE_SOURCE'			,
      			     p_token3_value		=> 	'OKE_LATEST_ALLOC_PROMPT'	,
      			     p_token3_translate		=>	OKE_API.G_TRUE
      			    );

        RAISE G_EXCEPTION_HALT_VALIDATION;

     END IF;
     */
   END IF;

END validate_record;


--
-- Function: null_funding_out
--
-- Description: This function is used to set all the missing values attributes to be null
--
--

FUNCTION null_funding_out(p_funding_in_rec 	IN	FUNDING_REC_IN_TYPE) RETURN FUNDING_REC_IN_TYPE
			  is

   l_funding_in_rec	  FUNDING_REC_IN_TYPE := p_funding_in_rec;

BEGIN

   l_funding_in_rec.funding_source_id := null;

   IF l_funding_in_rec.pool_party_id = OKE_API.G_MISS_NUM THEN
      l_funding_in_rec.pool_party_id := null;
   END IF;

   IF l_funding_in_rec.object_type = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.object_type := null;
   END IF;

   IF l_funding_in_rec.object_id= OKE_API.G_MISS_NUM THEN
      l_funding_in_rec.object_id := null;
   END IF;

   IF l_funding_in_rec.k_party_id= OKE_API.G_MISS_NUM THEN
      l_funding_in_rec.k_party_id := null;
   END IF;

   IF l_funding_in_rec.amount= OKE_API.G_MISS_NUM THEN
      l_funding_in_rec.amount := null;
   END IF;

   IF l_funding_in_rec.currency_code = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.currency_code := null;
   END IF;

   IF l_funding_in_rec.agreement_number = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.agreement_number := null;
   END IF;

   IF l_funding_in_rec.funding_status = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.funding_status := null;
   END IF;

   IF l_funding_in_rec.hard_limit = OKE_API.G_MISS_NUM THEN
      l_funding_in_rec.hard_limit := null;
   END IF;

   IF l_funding_in_rec.k_conversion_type = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.k_conversion_type := null;
   END IF;

   IF l_funding_in_rec.k_conversion_date = OKE_API.G_MISS_DATE THEN
      l_funding_in_rec.k_conversion_date := null;
   END IF;

   -- syho, bug 2208979
   IF l_funding_in_rec.k_conversion_rate = OKE_API.G_MISS_NUM THEN
      l_funding_in_rec.k_conversion_rate := null;
   END IF;
   -- syho, bug 2208979

   IF l_funding_in_rec.start_date_active = OKE_API.G_MISS_DATE THEN
      l_funding_in_rec.start_date_active := null;
   END IF;

   IF l_funding_in_rec.end_date_active = OKE_API.G_MISS_DATE THEN
      l_funding_in_rec.end_date_active := null;
   END IF;
/*
   IF l_funding_in_rec.oke_desc_flex_name = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_desc_flex_name := null;
   END IF;
*/
   IF l_funding_in_rec.oke_attribute_category = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute_category := null;
   END IF;

   IF l_funding_in_rec.oke_attribute1 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute1 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute2 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute2 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute3 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute3 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute4 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute4 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute5 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute5 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute6 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute6 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute7 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute7 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute8 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute8 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute9 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute9 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute10 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute10 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute11 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute11 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute12 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute12 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute13 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute13 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute14 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute14 := null;
   END IF;

   IF l_funding_in_rec.oke_attribute15 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.oke_attribute15 := null;
   END IF;

   IF l_funding_in_rec.pa_attribute_category = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.pa_attribute_category := null;
   END IF;

   IF l_funding_in_rec.pa_attribute1 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.pa_attribute1 := null;
   END IF;

   IF l_funding_in_rec.pa_attribute2 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.pa_attribute2 := null;
   END IF;

   IF l_funding_in_rec.pa_attribute3 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.pa_attribute3 := null;
   END IF;

   IF l_funding_in_rec.pa_attribute4 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.pa_attribute4 := null;
   END IF;

   IF l_funding_in_rec.pa_attribute5 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.pa_attribute5 := null;
   END IF;

   IF l_funding_in_rec.pa_attribute6 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.pa_attribute6 := null;
   END IF;

   IF l_funding_in_rec.pa_attribute7 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.pa_attribute7 := null;
   END IF;

   IF l_funding_in_rec.pa_attribute8 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.pa_attribute8 := null;
   END IF;

   IF l_funding_in_rec.pa_attribute9 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.pa_attribute9 := null;
   END IF;

   IF l_funding_in_rec.pa_attribute10 = OKE_API.G_MISS_CHAR THEN
      l_funding_in_rec.pa_attribute10 := null;
   END IF;

   IF l_funding_in_rec.revenue_hard_limit = OKE_API.G_MISS_NUM THEN
      l_funding_in_rec.revenue_hard_limit := null;
   END IF;

   IF l_funding_in_rec.agreement_org_id = OKE_API.G_MISS_NUM THEN
      l_funding_in_rec.agreement_org_id := null;
   END IF;

   return(l_funding_in_rec);

END null_funding_out;


--
-- Procedure: validate_populate_rec
--
-- Description: This procedure is used to populate missing attributes of the record for update
--
--

PROCEDURE validate_populate_rec(p_funding_in_rec        IN		FUNDING_REC_IN_TYPE  			,
				p_funding_in_rec_out	OUT NOCOPY      FUNDING_REC_IN_TYPE  			,
				--p_conversion_rate	OUT NOCOPY	NUMBER					,
				p_previous_amount	OUT NOCOPY	NUMBER    				,
				p_flag			OUT NOCOPY	VARCHAR2
			       ) is

   cursor c_funding_row is
      select *
      from   oke_k_funding_sources
      where  funding_source_id = p_funding_in_rec.funding_source_id
      FOR UPDATE OF funding_source_id NOWAIT;

   l_funding_row	c_funding_row%ROWTYPE;

BEGIN

   p_flag := 'N';

   OPEN c_funding_row;
   FETCH c_funding_row into l_funding_row;
   CLOSE c_funding_row;

   p_funding_in_rec_out := p_funding_in_rec;

   IF (p_funding_in_rec_out.object_type = OKE_API.G_MISS_CHAR)		THEN
       p_funding_in_rec_out.object_type := l_funding_row.object_type;

   ELSIF (nvl(p_funding_in_rec_out.object_type, '-99') <> l_funding_row.object_type) THEN

      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			  p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			  p_token1			=>	'VALUE'								,
      			  p_token1_value		=>	'object_type'
  			 );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (p_funding_in_rec_out.object_id = OKE_API.G_MISS_NUM)		THEN
      p_funding_in_rec_out.object_id := l_funding_row.object_id;

   ELSIF (nvl(p_funding_in_rec_out.object_id, -99) <> l_funding_row.object_id) THEN

      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			  p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			  p_token1			=>	'VALUE'								,
      			  p_token1_value		=>	'object_id'
  			 );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (p_funding_in_rec_out.pool_party_id = OKE_API.G_MISS_NUM)		THEN
      p_funding_in_rec_out.pool_party_id := l_funding_row.pool_party_id;

   ELSIF (nvl(p_funding_in_rec_out.pool_party_id, -99) <> nvl(l_funding_row.pool_party_id, -99)) THEN

      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			  p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			  p_token1			=>	'VALUE'								,
      			  p_token1_value		=>	'pool_party_id'
  			 );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (p_funding_in_rec_out.k_party_id = OKE_API.G_MISS_NUM)		THEN
      p_funding_in_rec_out.k_party_id := l_funding_row.k_party_id;

   ELSIF (nvl(p_funding_in_rec_out.k_party_id, -99) <> nvl(l_funding_row.k_party_id, -99)) THEN

      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			  p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			  p_token1			=>	'VALUE'								,
      			  p_token1_value		=>	'k_party_id'
  			 );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (p_funding_in_rec_out.amount = OKE_API.G_MISS_NUM)		THEN
      p_funding_in_rec_out.amount := l_funding_row.amount;
   END IF;

   IF (p_funding_in_rec_out.hard_limit = OKE_API.G_MISS_NUM)	THEN
      p_funding_in_rec_out.hard_limit := l_funding_row.hard_limit;
   END IF;

   IF (p_funding_in_rec_out.revenue_hard_limit = OKE_API.G_MISS_NUM)	THEN
      p_funding_in_rec_out.revenue_hard_limit := l_funding_row.revenue_hard_limit;
   END IF;

   IF (p_funding_in_rec_out.agreement_org_id = OKE_API.G_MISS_NUM)	THEN
      p_funding_in_rec_out.agreement_org_id := l_funding_row.agreement_org_id;
   END IF;

   IF p_funding_in_rec_out.currency_code = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.currency_code := l_funding_row.currency_code;

   ELSIF (nvl(upper(p_funding_in_rec_out.currency_code), '-99') <> l_funding_row.currency_code) THEN

      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			  p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			  p_token1			=>	'VALUE'								,
      			  p_token1_value		=>	'currency_code'
  			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF p_funding_in_rec_out.agreement_number = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.agreement_number := l_funding_row.agreement_number;

   ELSIF (nvl(p_funding_in_rec_out.agreement_number, '-99') <> nvl(l_funding_row.agreement_number, '-99')) THEN

      IF (l_funding_row.agreement_flag = 'Y') THEN

  	 OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
     			     p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			     p_token1			=>	'VALUE'								,
      			     p_token1_value		=>	'agreement_number'
  			     );

         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

   END IF;

   IF p_funding_in_rec_out.k_conversion_type = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.k_conversion_type := l_funding_row.k_conversion_type;
   END IF;

   IF p_funding_in_rec_out.k_conversion_date = OKE_API.G_MISS_DATE THEN
      p_funding_in_rec_out.k_conversion_date := l_funding_row.k_conversion_date;
   END IF;

   -- syho, bug 2208979
   IF p_funding_in_rec_out.k_conversion_rate = OKE_API.G_MISS_NUM THEN
      p_funding_in_rec_out.k_conversion_rate := l_funding_row.k_conversion_rate;
   END IF;

   IF (upper(p_funding_in_rec_out.k_conversion_type) <> 'USER') 							   					AND
      (nvl(to_char(p_funding_in_rec_out.k_conversion_date, 'YYYYMMDD'), '19000101') <> nvl(to_char(l_funding_row.k_conversion_date, 'YYYYMMDD'), '19000101') 	OR
       nvl(p_funding_in_rec_out.k_conversion_type, '-99') <> nvl(l_funding_row.k_conversion_type, '-99'))   	   					 	AND
       (p_funding_in_rec_out.k_conversion_rate is not null) 							   					 	THEN

        OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
     			    p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			    p_token1			=>	'VALUE'								,
      			    p_token1_value		=>	'k_conversion_rate'
  			    );

        RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;
   -- syho, bug 2208979

   IF (nvl(to_char(p_funding_in_rec_out.k_conversion_date, 'YYYYMMDD'), '19000101') <> nvl(to_char(l_funding_row.k_conversion_date, 'YYYYMMDD'), '19000101')) OR
      (nvl(p_funding_in_rec_out.k_conversion_type, '-99') <> nvl(l_funding_row.k_conversion_type, '-99')) OR
      (nvl(p_funding_in_rec_out.k_conversion_rate, -99) <> nvl(l_funding_row.k_conversion_rate, -99)) THEN

      p_flag := 'Y';

   END IF;

   IF p_funding_in_rec_out.funding_status = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.funding_status := l_funding_row.funding_status;
   END IF;

   IF p_funding_in_rec_out.start_date_active = OKE_API.G_MISS_DATE THEN
      p_funding_in_rec_out.start_date_active := l_funding_row.start_date_active;
   END IF;

   IF p_funding_in_rec_out.end_date_active = OKE_API.G_MISS_DATE THEN
      p_funding_in_rec_out.end_date_active := l_funding_row.end_date_active;
   END IF;
 /*
   IF p_funding_in_rec_out.oke_desc_flex_name = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_desc_flex_name := null;
   END IF;
 */
   IF p_funding_in_rec_out.oke_attribute_category = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute_category := l_funding_row.attribute_category;
   END IF;

   IF p_funding_in_rec_out.oke_attribute1 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute1 := l_funding_row.attribute1;
   END IF;

   IF p_funding_in_rec_out.oke_attribute2 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute2 := l_funding_row.attribute2;
   END IF;

   IF p_funding_in_rec_out.oke_attribute3 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute3 := l_funding_row.attribute3;
   END IF;

   IF p_funding_in_rec_out.oke_attribute4 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute4 := l_funding_row.attribute4;
   END IF;

   IF p_funding_in_rec_out.oke_attribute5 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute5 := l_funding_row.attribute5;
   END IF;

   IF p_funding_in_rec_out.oke_attribute6 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute6 := l_funding_row.attribute6;
   END IF;

   IF p_funding_in_rec_out.oke_attribute7 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute7 := l_funding_row.attribute7;
   END IF;

   IF p_funding_in_rec_out.oke_attribute8 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute8 := l_funding_row.attribute8;
   END IF;

   IF p_funding_in_rec_out.oke_attribute9 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute9 := l_funding_row.attribute9;
   END IF;

   IF p_funding_in_rec_out.oke_attribute10 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute10 := l_funding_row.attribute10;
   END IF;

   IF p_funding_in_rec_out.oke_attribute11 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute11 := l_funding_row.attribute11;
   END IF;

   IF p_funding_in_rec_out.oke_attribute12 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute12 := l_funding_row.attribute12;
   END IF;

   IF p_funding_in_rec_out.oke_attribute13 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute13 := l_funding_row.attribute13;
   END IF;

   IF p_funding_in_rec_out.oke_attribute14 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute14 := l_funding_row.attribute14;
   END IF;

   IF p_funding_in_rec_out.oke_attribute15 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.oke_attribute15 := l_funding_row.attribute15;
   END IF;

   IF p_funding_in_rec_out.pa_attribute_category = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.pa_attribute_category := l_funding_row.pa_attribute_category;
   END IF;

   IF p_funding_in_rec_out.pa_attribute1 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.pa_attribute1 := l_funding_row.pa_attribute1;
   END IF;

   IF p_funding_in_rec_out.pa_attribute2 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.pa_attribute2 := l_funding_row.pa_attribute2;
   END IF;

   IF p_funding_in_rec_out.pa_attribute3 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.pa_attribute3 := l_funding_row.pa_attribute3;
   END IF;

   IF p_funding_in_rec_out.pa_attribute4 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.pa_attribute4 := l_funding_row.pa_attribute4;
   END IF;

   IF p_funding_in_rec_out.pa_attribute5 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.pa_attribute5 := l_funding_row.pa_attribute5;
   END IF;

   IF p_funding_in_rec_out.pa_attribute6 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.pa_attribute6 := l_funding_row.pa_attribute6;
   END IF;

   IF p_funding_in_rec_out.pa_attribute7 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.pa_attribute7 := l_funding_row.pa_attribute7;
   END IF;

   IF p_funding_in_rec_out.pa_attribute8 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.pa_attribute8 := l_funding_row.pa_attribute8;
   END IF;

   IF p_funding_in_rec_out.pa_attribute9 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.pa_attribute9 := l_funding_row.pa_attribute9;
   END IF;

   IF p_funding_in_rec_out.pa_attribute10 = OKE_API.G_MISS_CHAR THEN
      p_funding_in_rec_out.pa_attribute10 := l_funding_row.pa_attribute10;
   END IF;

   p_previous_amount := l_funding_row.previous_amount;
   --p_previous_amount := l_funding_row.amount;
  -- p_conversion_rate := l_funding_row.k_conversion_rate;

END validate_populate_rec;


--
-- Procedure: validate_parameters
--
-- Description: This procedure is used to validate the pass-in parameters
--
--

PROCEDURE validate_parameters(p_pool_party_id				NUMBER		,
   		       	      p_party_id				NUMBER		,
   		       	     -- p_source_currency				VARCHAR2	,
   		       	      p_agreement_id				NUMBER		,
   		       	      p_conversion_type				VARCHAR2	,
   		      	    --  p_pa_conversion_type			VARCHAR2	,
   		       	      p_k_header_id				NUMBER
   		      	    ) is

   l_return_status		VARCHAR2(1);

BEGIN

   --
   -- Validate k_header_id
   --

   validate_object_id(p_object_id	=>	p_k_header_id	,
  		      p_return_status 	=> 	l_return_status
  		     );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate currency_code
   --
/*
   validate_currency_code(p_currency_code	 =>	 p_source_currency	,
   			  p_return_status  	 =>	 l_return_status
   			 );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;
 */
   --
   -- Validate conversion_type
   --

   validate_conversion_type(p_conversion_type	=>	p_conversion_type	,
   			    p_return_status	=>	l_return_status
   			   );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;
 /*
   validate_conversion_type(p_conversion_type	=>	p_pa_conversion_type	,
   			    p_return_status	=>	l_return_status
   			   );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;
*/
   --
   -- Validate k_party_id
   --

   validate_k_party_id(p_k_header_id	=>	p_k_header_id	,
   		       p_k_party_id	=>	p_party_id	,
   		       p_return_status	=>	l_return_status
   		      );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- validate pool_party_id
   --

   validate_pool_party_id(p_pool_party_id	=>	p_pool_party_id		,
   			  p_return_status	=>	l_return_status
   			 );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate agreement_id and check if all projects in project fundings are under a valid hierarchy
   --

   validate_agreement_id(p_agreement_id		=>	p_agreement_id	,
   			 p_object_id		=>	p_k_header_id	,
   			 p_return_status	=>	l_return_status
   			);

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

END validate_parameters;


--
-- Procedure: validate_agreement_party
--
-- Description: This procedure is used to get the agreement attributes
--
--

PROCEDURE validate_agreement_party(p_pool_party_id			NUMBER		,
   			   	   p_party_id				NUMBER		,
   			   	   p_customer_id			NUMBER		,
   			   	   p_expiration_date			DATE		,
   			   	  -- p_update_flag			VARCHAR2	,
   			   	   p_currency_code	OUT NOCOPY	VARCHAR2	,
   			   	   p_start_date		OUT NOCOPY	DATE
   			   	   --p_currency_code	OUT		VARCHAR2
   			   	  ) is

   cursor c_party is
     select 'x'
     from    hz_cust_accounts
     where   cust_account_id = p_customer_id
     and     party_id = p_party_id;

   cursor c_pool_party is
     select  currency_code, start_date_active
     from    oke_pool_parties
     where   pool_party_id = p_pool_party_id
     and     party_id = p_party_id
     and     ((start_date_active is null) or
              (p_expiration_date is not null and
	       nvl(start_date_active, p_expiration_date) <= p_expiration_date)
	      or (p_expiration_date is null))
    -- and    ((end_date_active is null) or
    --        (p_expiration_date is not null and
    --        nvl(to_char(end_date_active, 'YYYYMMDD'), '19000101') >= nvl(to_char(p_expiration_date, 'YYYYMMDD'), '19000101')))
  --   and     ((p_expiration_date is not null) and nvl(to_char(end_date_active, 'YYYYMMDD'), '19000101') >= nvl(to_char(p_expiration_date, 'YYYYMMDD'), '19000101')) or
  --   	     end_date_active is null)
    -- and     nvl(end_date_active, nvl(p_expiration_date, sysdate)) >= nvl(p_expiration_date, sysdate)
   FOR UPDATE OF pool_party_id NOWAIT;

   l_dummy_value	VARCHAR2(1) := '?';
  -- l_pool_currency	VARCHAR2(15);

BEGIN

   OPEN c_party;
   FETCH c_party into l_dummy_value;
   CLOSE c_party;

   IF (l_dummy_value = '?') THEN

       OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      		     	   p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			   p_token1		=>	'VALUE'			,
      			   p_token1_value	=>	'party_id'
      			  );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (p_pool_party_id is not null) THEN

      OPEN c_pool_party;
      FETCH c_pool_party into p_currency_code, p_start_date;

      IF (c_pool_party%NOTFOUND) THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
      		     	     p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			     p_token1		=>	'VALUE'				,
      			     p_token1_value	=>	'pool_party_id and party_id'
      			    );

         CLOSE c_pool_party;

         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

      CLOSE c_pool_party;

   END IF;

/*
   IF (p_pool_party_id is not null) THEN

      OPEN c_pool_party;
      FETCH c_pool_party into l_pool_currency;

      IF (c_pool_party%NOTFOUND) THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
      		     	     p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			     p_token1		=>	'VALUE'				,
      			     p_token1_value	=>	'pool_party_id and party_id'
      			    );

         CLOSE c_pool_party;

         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

      CLOSE c_pool_party;

      IF  (l_pool_currency <> p_source_currency) THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
      		     	     p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			     p_token1		=>	'VALUE'				,
      			     p_token1_value	=>	'pool_party_id'
      			    );

         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

   END IF;
 */
EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF c_pool_party%ISOPEN THEN
         CLOSE c_pool_party;
      END IF;

      IF c_party%ISOPEN THEN
         CLOSE c_party;
      END IF;

      raise G_EXCEPTION_HALT_VALIDATION;

   WHEN OTHERS THEN
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_pool_party%ISOPEN THEN
         CLOSE c_pool_party;
      END IF;

      IF c_party%ISOPEN THEN
         CLOSE c_party;
      END IF;

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END validate_agreement_party;



--
-- Public Procedures and Funtions
--


--
-- Procedure create_funding
--
-- Description: This procedure is used to insert record in OKE_K_FUNDING_SOURCES table
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			OKE_FUNDINGSOURCE_PVT.insert_row
--			null_funding_out
--			validate_attributes
--			validate_record
--

PROCEDURE create_funding(p_api_version		IN		NUMBER						,
   			 p_init_msg_list	IN      	VARCHAR2 := OKE_API.G_FALSE			,
   			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_msg_count		OUT NOCOPY	NUMBER						,
   			 p_msg_data		OUT NOCOPY	VARCHAR2					,
			 p_funding_in_rec	IN		FUNDING_REC_IN_TYPE				,
			 p_funding_out_rec	OUT NOCOPY	FUNDING_REC_OUT_TYPE				,
			 p_return_status	OUT NOCOPY	VARCHAR2
			) is

   l_zero		CONSTANT	NUMBER		 := 0;
   l_api_name				VARCHAR2(20) 	 := 'create_funding';
   l_rowid				VARCHAR2(30);
   l_return_status			VARCHAR2(1);
   l_funding_in_rec			FUNDING_REC_IN_TYPE;
  -- l_conversion_rate			NUMBER;

BEGIN

   --dbms_output.put_line('entering oke_fundsource_pvt.create_funding');
   --oke_debug.debug('entering oke_fundsource_pvt.create_funding');

   p_return_status  		       := OKE_API.G_RET_STS_SUCCESS;
   p_funding_out_rec.return_status     := OKE_API.G_RET_STS_SUCCESS;

   l_return_status := OKE_API.START_ACTIVITY(p_api_name			=>	l_api_name		,
   			 		     p_pkg_name			=>	G_PKG_NAME		,
   					     p_init_msg_list		=>	p_init_msg_list		,
   			 		     l_api_version		=>	G_API_VERSION_NUMBER	,
   			 		     p_api_version		=>	p_api_version		,
   			 		     p_api_type			=>	'_PVT'			,
   			 	             x_return_status		=>	p_return_status
   			 		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Set Default Null
   --

   --dbms_output.put_line('set default null values for fields');
   --oke_debug.debug('set default null values for fields');

   l_funding_in_rec := null_funding_out(p_funding_in_rec	=> 	p_funding_in_rec);

   --
   -- Validate Attributes
   --

  -- dbms_output.put_line('validate record attributes');
   --oke_debug.debug('validate record attributes');

   validate_attributes(p_funding_in_rec		=>	l_funding_in_rec);

   --
   -- Validate record
   --

   --dbms_output.put_line('validate record');
   --oke_debug.debug('validate record');

   validate_record(p_funding_in_rec		=>	l_funding_in_rec,
   		   p_flag			=>	'Y'             );

   l_funding_in_rec.funding_source_id := get_funding_source_id;
   p_funding_out_rec.funding_source_id := l_funding_in_rec.funding_source_id;

  -- dbms_output.put_line('calling oke_fundingsource_pvt.insert_row from oke_fundsource_pvt');
   --oke_debug.debug('calling oke_fundingsource_pvt.insert_row from oke_fundsource_pvt');

   OKE_FUNDINGSOURCE_PVT.insert_row(X_Rowid     		=>      l_rowid						,
     		      		    X_Funding_Source_Id		=> 	l_funding_in_rec.funding_source_id		,
                       		    X_Pool_Party_Id		=>	l_funding_in_rec.pool_party_id			,
                       		    X_K_Party_Id                =>	l_funding_in_rec.k_party_id    			,
                      	      	    X_Object_Type		=>	upper(l_funding_in_rec.object_type)		,
                      		    X_Object_Id			=>	l_funding_in_rec.object_id			,
                      		    X_Agreement_Number		=>	l_funding_in_rec.agreement_number		,
                      		    X_Currency_Code		=>	upper(l_funding_in_rec.currency_code)		,
                     		    X_Amount			=>	l_funding_in_rec.amount				,
                     		    X_Initial_Amount		=>	l_funding_in_rec.amount				,
                    		    X_Previous_Amount		=>	l_zero						,
                     		    X_Funding_Status		=>	upper(l_funding_in_rec.funding_status)		,
                     		    X_Hard_Limit		=>	l_funding_in_rec.hard_limit			,
                      		    X_K_Conversion_Type		=>	l_funding_in_rec.k_conversion_type		,
                     		    X_K_Conversion_Date		=>	l_funding_in_rec.k_conversion_date		,
                      		    X_K_Conversion_Rate		=>	l_funding_in_rec.k_conversion_rate		,
                    		    X_Start_Date_Active		=>	l_funding_in_rec.start_date_active		,
                    		    X_End_Date_Active		=>	l_funding_in_rec.end_date_active		,
                    		    X_Last_Update_Date  	=>	sysdate						,
                    		    X_Last_Updated_By 		=>	L_USERID					,
                     		    X_Creation_Date  		=>	sysdate						,
                    		    X_Created_By  		=>	L_USERID					,
                     		    X_Last_Update_Login   	=>	L_LOGINID					,
                      		   -- X_Attribute_Category   	=>	upper(l_funding_in_rec.oke_attribute_category)	,
                      		    X_Attribute_Category   	=>	l_funding_in_rec.oke_attribute_category		,
                     		    X_Attribute1       		=>	l_funding_in_rec.oke_attribute1			,
                     		    X_Attribute2  		=>	l_funding_in_rec.oke_attribute2			,
                     		    X_Attribute3  		=>	l_funding_in_rec.oke_attribute3			,
                     		    X_Attribute4           	=>	l_funding_in_rec.oke_attribute4 		,
                     		    X_Attribute5  		=>	l_funding_in_rec.oke_attribute5       		,
                    		    X_Attribute6            	=>	l_funding_in_rec.oke_attribute6         	,
                      		    X_Attribute7          	=>	l_funding_in_rec.oke_attribute7         	,
                     		    X_Attribute8        	=>	l_funding_in_rec.oke_attribute8      	   	,
                      		    X_Attribute9          	=>	l_funding_in_rec.oke_attribute9         	,
                   		    X_Attribute10   		=>	l_funding_in_rec.oke_attribute10        	,
                     		    X_Attribute11   		=>	l_funding_in_rec.oke_attribute11		,
                      		    X_Attribute12          	=>	l_funding_in_rec.oke_attribute12        	,
                      		    X_Attribute13               =>	l_funding_in_rec.oke_attribute13     		,
                      		    X_Attribute14               =>	l_funding_in_rec.oke_attribute14  		,
                      		    X_Attribute15   		=>	l_funding_in_rec.oke_attribute15       	       	,
                      		   -- X_PA_Attribute_Category   	=>	upper(l_funding_in_rec.pa_attribute_category)	,
                      		    X_PA_Attribute_Category   	=>	l_funding_in_rec.pa_attribute_category		,
                     		    X_PA_Attribute1       	=>	l_funding_in_rec.pa_attribute1			,
                     		    X_PA_Attribute2  		=>	l_funding_in_rec.pa_attribute2			,
                     		    X_PA_Attribute3  		=>	l_funding_in_rec.pa_attribute3			,
                     		    X_PA_Attribute4           	=>	l_funding_in_rec.pa_attribute4 			,
                     		    X_PA_Attribute5  		=>	l_funding_in_rec.pa_attribute5       		,
                    		    X_PA_Attribute6            	=>	l_funding_in_rec.pa_attribute6        	 	,
                      		    X_PA_Attribute7          	=>	l_funding_in_rec.pa_attribute7        	 	,
                     		    X_PA_Attribute8        	=>	l_funding_in_rec.pa_attribute8      	   	,
                      		    X_PA_Attribute9          	=>	l_funding_in_rec.pa_attribute9        	 	,
                   		    X_PA_Attribute10   		=>	l_funding_in_rec.pa_attribute10        		,
                   		    X_Revenue_Hard_Limit	=>	l_funding_in_rec.revenue_hard_limit		,
                   		    X_Agreement_Org_id		=>	l_funding_in_rec.agreement_org_id
   				   );

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

  -- dbms_output.put_line('finished oke_fundsource_pvt.create_funding');
   --oke_debug.debug('finished oke_fundsource_pvt.create_funding');

   OKE_API.END_ACTIVITY(x_msg_count	=>	p_msg_count	,
   			x_msg_data      =>	p_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION THEN
        p_funding_out_rec.return_status := OKE_API.G_RET_STS_ERROR;
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	p_funding_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OTHERS THEN
   	p_funding_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

END create_funding;


--
-- Procedure: update_funding
--
-- Description: This procedure is used to update record in OKE_FUNDING_SOURCES table
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			OKE_FUNDINGSOURCE_PVT.update_row
--			validate_funding_source_id
--			validate_populate_rec
--			validate_attributes
--			validate_record
--

PROCEDURE update_funding(p_api_version		IN		NUMBER						,
   			 p_init_msg_list	IN     		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_msg_count		OUT NOCOPY	NUMBER						,
   			 p_msg_data		OUT NOCOPY	VARCHAR2					,
   			 p_funding_in_rec	IN		FUNDING_REC_IN_TYPE				,
			 p_funding_out_rec	OUT NOCOPY	FUNDING_REC_OUT_TYPE				,
			 p_return_status	OUT NOCOPY	VARCHAR2
			) is

   l_api_name		CONSTANT	VARCHAR2(40) := 'update_funding';
   l_return_status			VARCHAR2(1);
   l_previous_amount			NUMBER;
   l_funding_in_rec			FUNDING_REC_IN_TYPE;
  -- l_conversion_rate			NUMBER;
   --l_conversion_rate2			NUMBER;
   l_rowid				VARCHAR2(30);
   l_pool_party_id			NUMBER;
   l_flag				VARCHAR2(1);
   l_agreement_flag			VARCHAR2(1);

BEGIN

   --dbms_output.put_line('entering oke_fundsource_pvt.update_funding');
   --oke_debug.debug('entering oke_fundsource_pvt.update_funding');

   p_return_status := OKE_API.G_RET_STS_SUCCESS;
   p_funding_out_rec.funding_source_id	:= p_funding_in_rec.funding_source_id;
   p_funding_out_rec.return_status := OKE_API.G_RET_STS_SUCCESS;

   l_return_status := OKE_API.START_ACTIVITY(p_api_name			=>	l_api_name		,
   			 		     p_pkg_name			=>	G_PKG_NAME		,
   					     p_init_msg_list		=>	p_init_msg_list		,
   			 		     l_api_version		=>	G_API_VERSION_NUMBER	,
   			 		     p_api_version		=>	p_api_version		,
   			 		     p_api_type			=>	'_PVT'			,
   			 	             x_return_status		=>	p_return_status
   			 		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Validate if it is a valid funding_source_id
   --

   validate_funding_source_id(p_funding_source_id	=>	p_funding_in_rec.funding_source_id	,
   			      p_rowid			=>	l_rowid					,
   			      p_pool_party_id		=>	l_pool_party_id				,
   			      p_agreement_flag		=>	l_agreement_flag
			     );

   --
   -- Validate and set the missing value for the fields
   --

   validate_populate_rec(p_funding_in_rec	=>	p_funding_in_rec			,
			 p_funding_in_rec_out	=>	l_funding_in_rec  			,
			 --p_conversion_rate	=>	l_conversion_rate			,
			 p_previous_amount	=>	l_previous_amount			,
			 p_flag			=>	l_flag
			);

   --
   -- Validate Attributes
   --

   validate_attributes(p_funding_in_rec		=>	l_funding_in_rec);

   --
   -- Validate record
   --

   validate_record(p_funding_in_rec		=>	l_funding_in_rec,
   		   p_flag			=>	l_flag		  );
   		  -- p_conversion_rate		=>	l_conversion_rate2);

  /*
   IF (l_flag = 'Y') THEN

      l_conversion_rate := l_conversion_rate2;

   END IF;
   */
   OKE_FUNDINGSOURCE_PVT.update_row(X_Funding_Source_Id		=> 	l_funding_in_rec.funding_source_id		,
   				    X_Pool_Party_Id		=>	l_funding_in_rec.pool_party_id			,
                       		    X_K_Party_Id                =>	l_funding_in_rec.k_party_id    			,
                     		    X_Amount			=>	l_funding_in_rec.amount				,
                    		    X_Previous_Amount		=>	nvl(l_previous_amount, 0)			,
                     		    X_Funding_Status		=>	upper(l_funding_in_rec.funding_status)		,
                     		    X_agreement_number		=>	l_funding_in_rec.agreement_number		,
                     		    X_Hard_Limit		=>	l_funding_in_rec.hard_limit			,
                      		    X_K_Conversion_Type		=>	l_funding_in_rec.k_conversion_type		,
                     		    X_K_Conversion_Date		=>	l_funding_in_rec.k_conversion_date		,
                      		    X_K_Conversion_Rate		=>	l_funding_in_rec.k_conversion_rate		,
                    		    X_Start_Date_Active		=>	l_funding_in_rec.start_date_active		,
                    		    X_End_Date_Active		=>	l_funding_in_rec.end_date_active		,
                    		    X_Last_Update_Date  	=>	sysdate						,
                    		    X_Last_Updated_By 		=>	L_USERID					,
                     		    X_Last_Update_Login   	=>	L_LOGINID					,
                      		    --X_Attribute_Category   	=>	upper(l_funding_in_rec.oke_attribute_category)	,
                      		    X_Attribute_Category   	=>	l_funding_in_rec.oke_attribute_category		,
                     		    X_Attribute1       		=>	l_funding_in_rec.oke_attribute1			,
                     		    X_Attribute2  		=>	l_funding_in_rec.oke_attribute2			,
                     		    X_Attribute3  		=>	l_funding_in_rec.oke_attribute3			,
                     		    X_Attribute4           	=>	l_funding_in_rec.oke_attribute4 		,
                     		    X_Attribute5  		=>	l_funding_in_rec.oke_attribute5                 ,
                    		    X_Attribute6            	=>	l_funding_in_rec.oke_attribute6          	,
                      		    X_Attribute7          	=>	l_funding_in_rec.oke_attribute7            	,
                     		    X_Attribute8        	=>	l_funding_in_rec.oke_attribute8         	,
                      		    X_Attribute9          	=>	l_funding_in_rec.oke_attribute9           	,
                   		    X_Attribute10   		=>	l_funding_in_rec.oke_attribute10          	,
                     		    X_Attribute11   		=>	l_funding_in_rec.oke_attribute11		,
                      		    X_Attribute12          	=>	l_funding_in_rec.oke_attribute12           	,
                      		    X_Attribute13               =>	l_funding_in_rec.oke_attribute13     		,
                      		    X_Attribute14               =>	l_funding_in_rec.oke_attribute14  		,
                      		    X_Attribute15   		=>	l_funding_in_rec.oke_attribute15              	,
                      		   -- X_PA_Attribute_Category   	=>	upper(l_funding_in_rec.pa_attribute_category)	,
                      		    X_PA_Attribute_Category   	=>	l_funding_in_rec.pa_attribute_category		,
                     		    X_PA_Attribute1       	=>	l_funding_in_rec.pa_attribute1			,
                     		    X_PA_Attribute2  		=>	l_funding_in_rec.pa_attribute2			,
                     		    X_PA_Attribute3  		=>	l_funding_in_rec.pa_attribute3			,
                     		    X_PA_Attribute4           	=>	l_funding_in_rec.pa_attribute4 			,
                     		    X_PA_Attribute5  		=>	l_funding_in_rec.pa_attribute5       		,
                    		    X_PA_Attribute6            	=>	l_funding_in_rec.pa_attribute6        	 	,
                      		    X_PA_Attribute7          	=>	l_funding_in_rec.pa_attribute7        	 	,
                     		    X_PA_Attribute8        	=>	l_funding_in_rec.pa_attribute8      	   	,
                      		    X_PA_Attribute9          	=>	l_funding_in_rec.pa_attribute9        	 	,
                   		    X_PA_Attribute10   		=>	l_funding_in_rec.pa_attribute10         	,
                   		    X_Revenue_Hard_Limit	=>	l_funding_in_rec.revenue_hard_limit		,
                   		    X_Agreement_Org_id		=>	l_funding_in_rec.agreement_org_id
   				   );

  -- dbms_output.put_line('finished oke_fundsource_pvt.update_funding w/ ' || p_return_status);
   --oke_debug.debug('finished oke_fundsource_pvt.update_funding w/ ' || p_return_status);

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   OKE_API.END_ACTIVITY(x_msg_count	=>	p_msg_count	,
   			x_msg_data      =>	p_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION THEN
        p_funding_out_rec.return_status := OKE_API.G_RET_STS_ERROR;
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	p_funding_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OTHERS THEN
   	p_funding_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

END update_funding;



--
-- Procedure: delete_funding
--
-- Description: This procedure is used to delete record in OKE_K_FUNDING_SOURCES table
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			OKE_FUNDINGSOURCE_PVT.delete_row
--			PA_AGREEMENT_PUB.delete_agreement
--			validate_funding_source_id
--

PROCEDURE delete_funding(p_api_version		IN		NUMBER						,
			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_init_msg_list	IN      	VARCHAR2 := OKE_API.G_FALSE			,
   			 p_msg_count		OUT NOCOPY	NUMBER						,
   			 p_msg_data		OUT NOCOPY	VARCHAR2					,
			 p_funding_source_id	IN		NUMBER						,
			-- p_agreement_flag	IN		VARCHAR2 := OKE_API.G_FALSE			,
			 p_return_status	OUT NOCOPY	VARCHAR2
			) is

   cursor c_agreement (p_funding_source_id 	NUMBER,
   		       length			NUMBER) is
        select pm_agreement_reference, org_id
        from   pa_agreements_all
        where  substr(pm_agreement_reference, (-1 * (length + 1)), length + 1) = '-' || TO_CHAR(p_funding_source_id)
        and    pm_product_code = G_PRODUCT_CODE;

   l_agreement 				c_agreement%ROWTYPE;
   l_api_name		CONSTANT	VARCHAR2(40) := 'delete_funding';
   l_return_status			VARCHAR2(1);
   l_agreement_flag			VARCHAR2(1);
   l_rowid				VARCHAR2(30);
   l_pool_party_id			NUMBER;
   l_length				NUMBER;

BEGIN

  -- dbms_output.put_line('entering oke_fundsource_pvt.delete_funding');
   --oke_debug.debug('entering oke_fundsource_pvt.delete_funding');

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   l_return_status := OKE_API.START_ACTIVITY(p_api_name			=>	l_api_name		,
   			 		     p_pkg_name			=>	G_PKG_NAME		,
   					     p_init_msg_list		=>	p_init_msg_list		,
   			 		     l_api_version		=>	G_API_VERSION_NUMBER	,
   			 		     p_api_version		=>	p_api_version		,
   			 		     p_api_type			=>	'_PVT'			,
   			 	             x_return_status		=>	p_return_status
   			 		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Validate if it is a valid funding_source_id
   --

   validate_funding_source_id(p_funding_source_id	=>	p_funding_source_id	,
   			      p_rowid			=>	l_rowid			,
   			      p_pool_party_id		=>	l_pool_party_id		,
   			      p_agreement_flag		=>	l_agreement_flag
 			    );

   --
   -- Call OKE_FUNDINGSOURCE_PVT.delete_row to delete the row
   --

   OKE_FUNDINGSOURCE_PVT.delete_row(x_rowid			=>	l_rowid		,
   				    x_pool_party_id		=>	l_pool_party_id
   				   );

   --
   -- Delete PA agreements if exist
   --

   IF (l_agreement_flag = 'Y') THEN

      l_length := length(p_funding_source_id);

      FOR l_agreement in c_agreement(p_funding_source_id, l_length) LOOP

          --
          -- Call PA_AGREEMENT_PUB.delete_agreement to delete pa agreement
          --

          --dbms_output.put_line('pm_agreement_reference '|| l_agreement.pm_agreement_reference);

          fnd_client_info.set_org_context(l_agreement.org_id);

         -- dbms_output.put_line('calling pa_agreement_pub.delete_agreement from oke_fundsource_pvt');
          --oke_debug.debug('calling pa_agreement_pub.delete_agreement from oke_fundsource_pvt');

          PA_AGREEMENT_PUB.delete_agreement(p_api_version_number		=> 	p_api_version				,
   					    p_commit				=>	OKE_API.G_FALSE				,
   					    p_init_msg_list			=>	OKE_API.G_FALSE				,
   					    p_msg_count				=>	p_msg_count				,
   					    p_msg_data				=>	p_msg_data				,
   					    p_return_status			=>	p_return_status				,
   					    p_pm_product_code			=>	G_PRODUCT_CODE				,
   					    p_pm_agreement_reference		=>	l_agreement.pm_agreement_reference	,
   					    p_agreement_id			=>	null
   				           );

          IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

             RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

          ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

             RAISE OKE_API.G_EXCEPTION_ERROR;

          END IF;

      END LOOP;

   END IF;

   --dbms_output.put_line('finished oke_fundsource_pvt.delete_funding w/ ' || p_return_status);
   --oke_debug.debug('finished oke_fundsource_pvt.delete_funding w/ ' || p_return_status);

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   OKE_API.END_ACTIVITY(x_msg_count	=>	p_msg_count	,
   			x_msg_data      =>	p_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION THEN
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OTHERS THEN
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

END delete_funding;



--
-- Procedure: fetch_create_funding
--
-- Description: This procedure is used by Oracle Form to get the existing agreement record
--		and create a funding record in OKE
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			OKE_FUNDSOURCE_PVT.create_funding
--			OKE_ALLOCATION_PVT.add_allocation
--			OKE_FUNDING_UTIL_PKG.check_single_org
--			OKE_FUNDING_UTIL_PKG.update_source_flag
--			OKE_FUNDING_UTIL_PKG.update_alloc_version
--			validate_pool_party_id
--			get_min_unit
--			lock_agreement
--			update_agreement_reference
--			update_proj_fld_reference
--

PROCEDURE fetch_create_funding(p_init_msg_list			IN		VARCHAR2 := OKE_API.G_FALSE	,
			       p_api_version			IN		NUMBER				,
			       p_msg_count			OUT NOCOPY	NUMBER				,
   			       p_msg_data			OUT NOCOPY	VARCHAR2			,
			       p_commit				IN		VARCHAR2:= OKE_API.G_FALSE	,
			       p_pool_party_id			IN		NUMBER				,
			       p_customer_id			IN		NUMBER				,
			       p_customer_number		IN		VARCHAR2			,
			       --p_pool_currency			IN 	VARCHAR2			,
			       --p_source_currency		IN		VARCHAR2			,
			       p_party_id			IN		NUMBER				,
			       p_agreement_id			IN      	NUMBER				,
			       p_org_id				IN		NUMBER				,
			       p_agreement_number		IN		VARCHAR2			,
			       p_agreement_type			IN		VARCHAR2			,
			       p_amount				IN		NUMBER				,
			       p_revenue_limit_flag		IN		VARCHAR2			,
			       p_agreement_currency		IN 		VARCHAR2			,
			       p_expiration_date		IN		DATE				,
			       p_conversion_type		IN 		VARCHAR2			,
			       p_conversion_date		IN		DATE				,
			       p_conversion_rate		IN		NUMBER				,
			       --p_pa_conversion_type		IN		VARCHAR2			,
			       --p_pa_conversion_date		IN		DATE				,
			       --p_pa_conversion_rate		IN		NUMBER				,
			       p_k_header_id			IN		NUMBER				,
			       p_pa_attribute_category		IN		VARCHAR2			,
			       p_pa_attribute1			IN		VARCHAR2			,
			       p_pa_attribute2			IN		VARCHAR2			,
			       p_pa_attribute3			IN		VARCHAR2			,
			       p_pa_attribute4			IN		VARCHAR2			,
			       p_pa_attribute5			IN		VARCHAR2			,
			       p_pa_attribute6			IN		VARCHAR2			,
			       p_pa_attribute7			IN		VARCHAR2			,
			       p_pa_attribute8			IN		VARCHAR2			,
			       p_pa_attribute9			IN		VARCHAR2			,
			       p_pa_attribute10			IN		VARCHAR2			,
			       p_owning_organization_id		IN		NUMBER				,
  			       p_invoice_limit_flag		IN		VARCHAR2			,
  			      -- p_allow_currency_update		IN	VARCHAR2			,
			      -- p_functional_currency_code	IN		VARCHAR2			,
			       p_funding_source_id		OUT NOCOPY	NUMBER				,
			       p_return_status			OUT NOCOPY	VARCHAR2
			      ) is

      cursor c_project_funding is
      select *
      from   pa_project_fundings
      where  agreement_id = p_agreement_id
      order by allocated_amount desc;

      cursor c_pool_party_date is
      select start_date_active, end_date_active
      from   oke_pool_parties
      where  pool_party_id = p_pool_party_id;

      cursor c_ou is
      select nvl(allow_funding_across_ou_flag, 'N'),
             currency_code
      from   pa_implementations_all p,
             gl_sets_of_books g
      where  nvl(org_id, -99) = nvl(p_org_id, -99)
      and    g.set_of_books_id = p.set_of_books_id;

      cursor c_across is
      select 'x'
      from   pa_project_fundings f,
             pa_projects_all p
      where  nvl(p.org_id, -99) <> nvl(p_org_id, -99)
      and    f.project_id = p.project_id
      and    f.agreement_id = p_agreement_id;

      l_return_status 			VARCHAR2(1);
      l_api_name 	CONSTANT	VARCHAR2(30) := 'fetch_create_funding';
 --     l_fund_currency			VARCHAR2(15);
   --   l_min_unit			NUMBER;
  --    l_allocated_total			NUMBER := 0;
   --   l_converted_amount 		NUMBER;
      l_funding_in_rec			FUNDING_REC_IN_TYPE;
      l_funding_out_rec    		FUNDING_REC_OUT_TYPE;
      l_allocation_in_rec		OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE;
      l_allocation_out_rec 		OKE_ALLOCATION_PVT.ALLOCATION_REC_OUT_TYPE;
      l_allocation_in_tbl		OKE_ALLOCATION_PVT.ALLOCATION_IN_TBL_TYPE;
      i 				NUMBER := 0;
    --  l_hard_limit_total		NUMBER := 0;
      l_project_funding			c_project_funding%ROWTYPE;
   --   l_orig_org_id			NUMBER;
    --  l_revenue_hard_limit_total	NUMBER := 0;
      l_temp_sum			NUMBER := 0;
      l_start_date			DATE;
      l_end_date			DATE;
      l_dummy				VARCHAR2(1) := '?';
      l_mcb_flag			VARCHAR2(1);
      l_org_set				NUMBER;
      l_num_update_flag			VARCHAR2(1);
      l_ou_currency			VARCHAR2(15);

BEGIN

   --oke_debug.debug('entering fetch_create_funding..');

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   l_return_status := OKE_API.START_ACTIVITY(p_api_name			=>	l_api_name		,
   			 		     p_pkg_name			=>	G_PKG_NAME		,
   					     p_init_msg_list		=>	p_init_msg_list		,
   			 		     l_api_version		=>	G_API_VERSION_NUMBER	,
   			 		     p_api_version		=>	p_api_version		,
   			 		     p_api_type			=>	'_PVT'			,
   			 	             x_return_status		=>	p_return_status
   			 		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --oke_debug.debug('oke_api.start_activity finished successfully');

  -- l_fund_currency := p_currency_code;

    IF (p_pool_party_id is not null) THEN

       validate_pool_party_id(p_pool_party_id 	=>	p_pool_party_id		,
       			      p_return_status	=>	p_return_status
       			      );

      IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

      ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_ERROR;

      END IF;

--    END IF;

      OPEN c_pool_party_date;
      FETCH c_pool_party_date INTO l_start_date, l_end_date;
      IF (c_pool_party_date%NOTFOUND) THEN
         CLOSE c_pool_party_date;
      END IF;
      CLOSE c_pool_party_date;

    END IF;
    -- bug 3346170
/*
    IF (l_end_date is not null)	  AND
       (p_expiration_date is null or
       p_expiration_date > l_end_date) THEN

  	  OKE_API.set_message(p_app_name			=>	G_APP_NAME			,
      			      p_msg_name			=>	'OKE_AGREEMENT_END_DATE'
      			      );

          RAISE OKE_API.G_EXCEPTION_ERROR;

    END IF;   */
  /*
    IF (p_agreement_currency <> p_source_currency) THEN

        l_min_unit := get_min_unit(p_source_currency);

    END IF;
 */

   --
   -- Check funding across OU
   --

   OPEN c_ou;
   FETCH c_ou into l_mcb_flag, l_ou_currency;
   CLOSE c_ou;

   IF (l_ou_currency <> p_agreement_currency) THEN

       l_num_update_flag := 'Y';

   ELSE

       l_num_update_flag := 'N';

   END IF;

   IF (l_mcb_flag = 'Y') THEN

       OPEN c_across;
       FETCH c_across into l_dummy;
       CLOSE c_across;

   END IF;

   --
   -- lock agreement record
   --

   lock_agreement(p_agreement_id	=>	p_agreement_id);

   FOR l_project_funding in c_project_funding LOOP
    /*
           IF (l_min_unit is not null) THEN

               l_converted_amount := round(l_project_funding.allocated_amount * (1/p_pa_conversion_rate) / l_min_unit) * l_min_unit;

            ELSE

               l_converted_amount := l_project_funding.allocated_amount;

            END IF; */
           --  oke_debug.debug('l_converted_amount ' || l_converted_amount);
           --  l_allocated_total := l_allocated_total + l_converted_amount;

            --
            -- Same up all the positive amount and create a funding source with this amount first
            --
            IF (l_project_funding.allocated_amount >= 0) THEN

                l_temp_sum := l_temp_sum + l_project_funding.allocated_amount;

            END IF;

            l_allocation_in_rec.fund_allocation_id		:=	null					;
            l_allocation_in_rec.funding_source_id		:=	null					;
            l_allocation_in_rec.object_id			:=	p_k_header_id				;
            l_allocation_in_rec.project_id			:=	l_project_funding.project_id   		;
            l_allocation_in_rec.task_id				:=	l_project_funding.task_id		;
            l_allocation_in_rec.agreement_id			:=	p_agreement_id				;
            l_allocation_in_rec.project_funding_id		:=	l_project_funding.project_funding_id	;

            --
            -- Validate the date_allocated of project funding against pool party start date
            --
	    -- bug 3346170
          /*  IF (p_pool_party_id is not null) THEN
            	IF (nvl(to_char(l_start_date, 'YYYYMMDD'), '19000101') > to_char(l_project_funding.date_allocated, 'YYYYMMDD')) THEN

           	   OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
      			               p_msg_name		=>	'OKE_PA_FUND_POOL_DATE'
      			              );

      		   RAISE OKE_API.G_EXCEPTION_ERROR;

            	END IF;
            END IF;
            */
            l_allocation_in_rec.start_date_active		:=	l_project_funding.date_allocated	;
     	    l_allocation_in_rec.amount				:=	l_project_funding.allocated_amount	;
      	    l_allocation_in_rec.k_line_id			:=	null					;
      	    l_allocation_in_rec.funding_category		:=	l_project_funding.funding_category	;

      	    --
	    -- hard limit = allocation amount if p_revenue_limit_flag = 'Y'
      	    --
      	    IF (p_invoice_limit_flag = 'Y') THEN
      	       l_allocation_in_rec.hard_limit		        :=      l_project_funding.allocated_amount	;
      	       --l_hard_limit_total			        :=	nvl(l_hard_limit_total, 0) +
      	       								--l_project_funding.allocated_amount	;
      	    ELSE
      	       l_allocation_in_rec.hard_limit			:=	null					;
      	    END IF;

      	    IF (p_revenue_limit_flag = 'Y') THEN
      	       l_allocation_in_rec.revenue_hard_limit		:=      l_project_funding.allocated_amount	;
      	      -- l_revenue_hard_limit_total			:=	nvl(l_revenue_hard_limit_total, 0) +
      	       							--	l_project_funding.allocated_amount	;
      	    ELSE
      	       l_allocation_in_rec.revenue_hard_limit		:=	null					;
      	    END IF;

     	    l_allocation_in_rec.fund_type			:=	null					;
     	    l_allocation_in_rec.funding_status			:=	null					;
            l_allocation_in_rec.end_date_active			:=	null					;
	    --l_allocation_in_rec.end_date_active			:=	p_expiration_date			;
     	    l_allocation_in_rec.fiscal_year			:=	null					;
      	    l_allocation_in_rec.reference1			:=	null					;
      	    l_allocation_in_rec.reference2			:=	null					;
            l_allocation_in_rec.reference3			:=	null					;
      	    l_allocation_in_rec.pa_conversion_type 		:=	null					;
      	    l_allocation_in_rec.pa_conversion_date		:=	null					;
      	    l_allocation_in_rec.pa_conversion_rate		:=	null					;
      	  /*
      	    -- syho, bug 2208979
      	    IF (upper(p_pa_conversion_type) = 'USER') THEN
      	       l_allocation_in_rec.pa_conversion_rate		:=      p_pa_conversion_rate			;
      	    ELSE
      	       l_allocation_in_rec.pa_conversion_rate		:=      null					;
      	    END IF;
      	    -- syho, bug 2208979
      	  */
      	    l_allocation_in_rec.oke_attribute_category		:=	null					;
      	    l_allocation_in_rec.oke_attribute1			:=	null					;
      	    l_allocation_in_rec.oke_attribute2    		:=	null					;
      	    l_allocation_in_rec.oke_attribute3			:=	null					;
            l_allocation_in_rec.oke_attribute4			:=	null					;
            l_allocation_in_rec.oke_attribute5			:=	null					;
      	    l_allocation_in_rec.oke_attribute6  		:=	null					;
      	    l_allocation_in_rec.oke_attribute7			:=	null					;
     	    l_allocation_in_rec.oke_attribute8			:=	null					;
     	    l_allocation_in_rec.oke_attribute9			:=	null					;
     	    l_allocation_in_rec.oke_attribute10   		:=	null					;
     	    l_allocation_in_rec.oke_attribute11			:=	null					;
     	    l_allocation_in_rec.oke_attribute12			:=	null					;
     	    l_allocation_in_rec.oke_attribute13    		:=	null					;
      	    l_allocation_in_rec.oke_attribute14			:=	null					;
            l_allocation_in_rec.oke_attribute15			:=	null					;

       	    l_allocation_in_rec.pa_attribute_category		:=	l_project_funding.attribute_category				;
      	    l_allocation_in_rec.pa_attribute1			:=	l_project_funding.attribute1					;
      	    l_allocation_in_rec.pa_attribute2    		:=	l_project_funding.attribute2					;
      	    l_allocation_in_rec.pa_attribute3			:=	l_project_funding.attribute3					;
            l_allocation_in_rec.pa_attribute4			:=	l_project_funding.attribute4					;
            l_allocation_in_rec.pa_attribute5			:=	l_project_funding.attribute5					;
      	    l_allocation_in_rec.pa_attribute6  			:=	l_project_funding.attribute6					;
      	    l_allocation_in_rec.pa_attribute7			:=	l_project_funding.attribute7					;
     	    l_allocation_in_rec.pa_attribute8			:=	l_project_funding.attribute8					;
     	    l_allocation_in_rec.pa_attribute9			:=	l_project_funding.attribute9					;
     	    l_allocation_in_rec.pa_attribute10   		:=	l_project_funding.attribute10					;

            l_allocation_in_tbl(i) := l_allocation_in_rec;
            i := i + 1;

   END LOOP;

--   oke_debug.debug('funding total = ' || l_allocated_total);
/*
   --
   -- get the funding source amount
   --

   IF (l_min_unit is not null) THEN

       l_allocated_total := round(p_amount * (1/p_pa_conversion_rate) / l_min_unit) * l_min_unit;

   ELSE

       l_allocated_total := p_amount;

   END IF;
   */
   --oke_debug.debug('preparing funding record');

   l_funding_in_rec.funding_source_id			:=	null					;
   l_funding_in_rec.object_type				:=	G_OBJECT_TYPE				;
   l_funding_in_rec.object_id				:=	p_k_header_id				;
   l_funding_in_rec.pool_party_id			:=	p_pool_party_id				;
   l_funding_in_rec.k_party_id				:= 	p_party_id				;
  -- l_funding_in_rec.amount				:= 	l_allocated_total			;
   l_funding_in_rec.amount				:= 	l_temp_sum				;
   l_funding_in_rec.customer_id				:=	p_customer_id				;
   l_funding_in_rec.customer_number			:=	p_customer_number			;

   --
   -- Hard limit = fund amount if p_revenue_limit_flag is 'Y'
   --

   IF (p_invoice_limit_flag = 'Y') THEN
      -- l_funding_in_rec.hard_limit			:=	l_hard_limit_total		 	;
         l_funding_in_rec.hard_limit			:= 	l_temp_sum 				;
   ELSE
       l_funding_in_rec.hard_limit			:=	null					;
   END IF;

   IF (p_revenue_limit_flag = 'Y') THEN
      -- l_funding_in_rec.revenue_hard_limit		:=	l_revenue_hard_limit_total		;
         l_funding_in_rec.revenue_hard_limit		:= 	l_temp_sum  				;
   ELSE
       l_funding_in_rec.revenue_hard_limit		:=	null					;
   END IF;

   l_funding_in_rec.currency_code			:=	p_agreement_currency			;
   l_funding_in_rec.k_conversion_type			:=	p_conversion_type			;
   l_funding_in_rec.k_conversion_date			:= 	p_conversion_date			;

   -- syho, bug 2208979
   IF (upper(p_conversion_type) = 'USER') THEN
      l_funding_in_rec.k_conversion_rate		:=	p_conversion_rate			;
   ELSE
      l_funding_in_rec.k_conversion_rate		:=	null					;
   END IF;
   -- syho, bug 2208979

   l_funding_in_rec.end_date_active			:=	p_expiration_date			;
   l_funding_in_rec.agreement_number			:=	p_agreement_number			;
   l_funding_in_rec.start_date_active			:=	l_start_date				;
   l_funding_in_rec.funding_status			:=	null					;
   l_funding_in_rec.oke_attribute_category		:=	null					;
   l_funding_in_rec.oke_attribute1			:=	null					;
   l_funding_in_rec.oke_attribute2    			:=	null					;
   l_funding_in_rec.oke_attribute3			:=	null					;
   l_funding_in_rec.oke_attribute4			:=	null					;
   l_funding_in_rec.oke_attribute5			:=	null					;
   l_funding_in_rec.oke_attribute6  			:=	null					;
   l_funding_in_rec.oke_attribute7			:=	null					;
   l_funding_in_rec.oke_attribute8			:=	null					;
   l_funding_in_rec.oke_attribute9			:=	null					;
   l_funding_in_rec.oke_attribute10   			:=	null					;
   l_funding_in_rec.oke_attribute11			:=	null					;
   l_funding_in_rec.oke_attribute12			:=	null					;
   l_funding_in_rec.oke_attribute13    			:=	null					;
   l_funding_in_rec.oke_attribute14			:=	null					;
   l_funding_in_rec.oke_attribute15			:=	null					;
   l_funding_in_rec.pa_attribute_category		:=	p_pa_attribute_category			;
   l_funding_in_rec.pa_attribute1			:=	p_pa_attribute1				;
   l_funding_in_rec.pa_attribute2    			:=	p_pa_attribute2				;
   l_funding_in_rec.pa_attribute3			:=	p_pa_attribute3				;
   l_funding_in_rec.pa_attribute4			:=	p_pa_attribute4				;
   l_funding_in_rec.pa_attribute5			:=	p_pa_attribute5				;
   l_funding_in_rec.pa_attribute6  			:=	p_pa_attribute6				;
   l_funding_in_rec.pa_attribute7			:=	p_pa_attribute7				;
   l_funding_in_rec.pa_attribute8			:=	p_pa_attribute8				;
   l_funding_in_rec.pa_attribute9			:=	p_pa_attribute9				;
   l_funding_in_rec.pa_attribute10   			:=	p_pa_attribute10			;

   fnd_profile.get('ORG_ID',l_org_set);

   IF (nvl(l_org_set, -99) <> nvl(p_org_id, -99)) THEN
      l_funding_in_rec.agreement_org_id				:=	null				;
   ELSE
      l_funding_in_rec.agreement_org_id 			:=      p_owning_organization_id	;
   END IF;

   --oke_debug.debug('calling create_funding');
   create_funding(p_api_version		=>	p_api_version		,
   		  p_init_msg_list	=>	OKE_API.G_FALSE		,
   		  p_msg_count		=>	p_msg_count		,
   	          p_msg_data		=>	p_msg_data		,
   		  p_funding_in_rec	=>	l_funding_in_rec	,
		  p_funding_out_rec	=>	l_funding_out_rec	,
		  p_return_status	=>	p_return_status
		 );
   --oke_debug.debug('finished create_funding w/status ' || p_return_status);

   IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Update pa agreement with new agreement reference
   --

   update_agreement_reference(p_agreement_id		=>	p_agreement_id				,
   			      p_org_id			=>	p_org_id				,
   			      p_currency_code		=>	p_agreement_currency			,
   			      p_funding_source_id	=>	l_funding_out_rec.funding_source_id	,
   			      p_num_update_flag		=>	l_num_update_flag			);


   IF (l_allocation_in_tbl.COUNT > 0) THEN

      i := l_allocation_in_tbl.FIRST;

      LOOP

      --oke_debug.debug('calling oke_allocation_pvt.add_allocation');
        l_allocation_in_rec := l_allocation_in_tbl(i);
        l_allocation_in_rec.funding_source_id := l_funding_out_rec.funding_source_id;

      --oke_debug.debug('converted_amount ' || l_allocation_in_rec.amount);
        OKE_ALLOCATION_PVT.add_allocation(p_api_version		=>	p_api_version				,
   				          p_init_msg_list	=>	OKE_API.G_FALSE				,
   				          p_commit		=>	OKE_API.G_FALSE				,
   				          p_msg_count		=>	p_msg_count				,
   				          p_msg_data		=>	p_msg_data				,
   				          p_allocation_in_rec	=>	l_allocation_in_rec			,
		   		          p_allocation_out_rec	=>	l_allocation_out_rec			,
		   		          p_return_status	=>	p_return_status
		   		         );

      --oke_debug.debug('finished calling oke_allocation_pvt.add_allocation w/ status' || p_return_status);

        IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

            RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

        ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

            RAISE OKE_API.G_EXCEPTION_ERROR;

        END IF;

        --
        -- Update project funding with new funding reference
        --

        update_proj_fld_reference(p_project_funding_id		=>	l_allocation_in_rec.project_funding_id	,
        			  p_fund_allocation_id		=>	l_allocation_out_rec.fund_allocation_id
        			 );

        --
        -- update agreement_version in OKE_K_FUND_ALLOCATIONS table
        --

        --dbms_output.put_line('calling oke_funding_util.update_alloc_version');
        --oke_debug.debug('calling oke_funding_util.update_alloc_version');

        OKE_FUNDING_UTIL_PKG.update_alloc_version(x_fund_allocation_id		=>	l_allocation_out_rec.fund_allocation_id	,
        				 	  x_version_add			=>	1					,
   					          x_commit			=>	OKE_API.G_FALSE
   					         );

        EXIT WHEN (i = l_allocation_in_tbl.LAST);
        i := l_allocation_in_tbl.NEXT(i);

      END LOOP;

   END IF;

   p_funding_source_id := l_funding_out_rec.funding_source_id;
   --oke_debug.debug('finished calling fetch_create_funding');

   --
   -- Update the funding source amount to the correct amount
   --
   l_funding_in_rec.amount			:= 	p_amount			 ;
   IF (p_invoice_limit_flag = 'Y') THEN
      l_funding_in_rec.hard_limit		:=	p_amount			 ;
   ELSE
      l_funding_in_rec.hard_limit		:=	null				 ;
   END IF;
   IF (p_revenue_limit_flag = 'Y') THEN
      l_funding_in_rec.revenue_hard_limit	:=	p_amount			 ;
   ELSE
      l_funding_in_rec.revenue_hard_limit	:=	null				 ;
   END IF;
   --l_funding_in_rec.hard_limit		:=	l_hard_limit_total		 	;
  -- l_funding_in_rec.revenue_hard_limit	:=	l_revenue_hard_limit_total		;
   l_funding_in_rec.funding_source_id   :=      l_funding_out_rec.funding_source_id	 ;

   --oke_debug.debug('calling create_funding');
   update_funding(p_api_version		=>	p_api_version		,
   		  p_init_msg_list	=>	OKE_API.G_FALSE		,
   		  p_msg_count		=>	p_msg_count		,
   	          p_msg_data		=>	p_msg_data		,
   		  p_funding_in_rec	=>	l_funding_in_rec	,
		  p_funding_out_rec	=>	l_funding_out_rec	,
		  p_return_status	=>	p_return_status
		 );
   --oke_debug.debug('finished create_funding w/status ' || p_return_status);

   IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Update initial amount and pa_flag
   --
   update oke_k_funding_sources
   set    initial_amount = p_amount,
          funding_across_ou = decode(l_dummy, 'x', 'Y')
   where  funding_source_id = l_funding_out_rec.funding_source_id;

   --
   -- update the pa_flag to be 'Y'
   --
   update oke_k_fund_allocations
   set    pa_flag = 'Y'
   where  funding_source_id = l_funding_out_rec.funding_source_id;

   --
   -- update the agreement_flag in OKE_FUNDING_SOURCES table
   --

   OKE_FUNDING_UTIL_PKG.update_source_flag(x_funding_source_id	=>	l_funding_out_rec.funding_source_id	,
   					   x_commit		=>	OKE_API.G_FALSE
   					  );

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   OKE_API.END_ACTIVITY(x_msg_count	=>	p_msg_count	,
   			x_msg_data      =>	p_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR THEN
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OTHERS THEN
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );
END fetch_create_funding;


--
-- Procedure: fetch_create_funding
--
-- Description: This procedure is used to get the existing agreement record
--		and create a funding record in OKE
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			OKE_FUNDSOURCE_PVT.create_funding
--			OKE_ALLOCATION_PVT.add_allocation
--			OKE_FUNDING_UTIL_PKG.check_single_org
--			OKE_FUNDING_UTIL_PKG.update_source_flag
--			OKE_FUNDING_UTIL_PKG.update_alloc_version
--			validate_parameters
--			lock_agreement
--			validate_agreement_party
--			get_k_currency
--			get_conversion
--			get_min_unit
--			create_funding
--			update_agreement_reference
--			update_proj_fld_reference
--

PROCEDURE fetch_create_funding(p_init_msg_list			IN		VARCHAR2 := OKE_API.G_FALSE	,
			       p_api_version			IN		NUMBER				,
			       p_msg_count			OUT NOCOPY	NUMBER				,
   			       p_msg_data			OUT NOCOPY	VARCHAR2			,
			       p_commit				IN		VARCHAR2 := OKE_API.G_FALSE	,
			       p_pool_party_id			IN		NUMBER				,
			       p_party_id			IN		NUMBER				,
			       --p_source_currency		IN		VARCHAR2			,
			       p_agreement_id			IN      	NUMBER				,
			       p_conversion_type		IN 		VARCHAR2			,
			       p_conversion_date		IN		DATE				,
			       p_conversion_rate		IN		NUMBER				,
			       --p_pa_conversion_type		IN	VARCHAR2			,
			       --p_pa_conversion_date		IN	DATE				,
			       --p_pa_conversion_rate		IN	NUMBER				,
			       p_k_header_id			IN		NUMBER				,
			       p_funding_source_id		OUT NOCOPY	NUMBER				,
			       p_return_status			OUT NOCOPY	VARCHAR2
			      ) is

      cursor c_project_funding is
      select *
      from   pa_project_fundings
      where  agreement_id = p_agreement_id
      order by allocated_amount desc;

      cursor c_agreement is
      select *
      from   oke_agreements_v
      where  agreement_id = p_agreement_id;

      cursor c_ou (x_org_id number) is
      select nvl(allow_funding_across_ou_flag, 'N'),
             currency_code
      from   pa_implementations_all p,
             gl_sets_of_books g
      where  nvl(org_id, -99) = nvl(x_org_id, -99)
      and    g.set_of_books_id = p.set_of_books_id;

      cursor c_across (x_org_id number) is
      select 'x'
      from   pa_project_fundings f,
             pa_projects_all p
      where  nvl(p.org_id, -99) <> nvl(x_org_id, -99)
      and    f.project_id = p.project_id
      and    f.agreement_id = p_agreement_id;

 /*
      cursor c_update (x_org_id number) is
      select 'x'
      from   pa_project_fundings f,
             pa_projects_all p
      where  p.project_id = f.project_id
      and    f.agreement_id = p_agreement_id
      and    nvl(p.org_id, -99) <> nvl(x_org_id, -99);
*/
      l_return_status 			VARCHAR2(1);
      l_api_name 	CONSTANT	VARCHAR2(30) := 'fetch_create_funding';
    --  l_fund_currency			VARCHAR2(15);
      --l_min_unit			NUMBER;
    --  l_allocated_total			NUMBER := 0;
     -- l_converted_amount 		NUMBER;
      l_funding_in_rec			FUNDING_REC_IN_TYPE;
      l_funding_out_rec    		FUNDING_REC_OUT_TYPE;
      l_allocation_in_rec		OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE;
      l_allocation_out_rec 		OKE_ALLOCATION_PVT.ALLOCATION_REC_OUT_TYPE;
      l_allocation_in_tbl		OKE_ALLOCATION_PVT.ALLOCATION_IN_TBL_TYPE;
      i 				NUMBER := 0;
      l_contract_currency		VARCHAR2(15);
      l_pool_currency			VARCHAR2(15);
      l_conversion_rate			NUMBER;
      --l_pa_conversion_rate		NUMBER;
      l_agreement			c_agreement%ROWTYPE;
      l_project_funding			c_project_funding%ROWTYPE;
      --l_hard_limit_total		NUMBER := 0;
     -- l_revenue_hard_limit_total	NUMBER := 0;
      l_dummy				VARCHAR2(1) := '?';
     -- l_update_flag			VARCHAR2(1) := 'Y';
      l_start_date			DATE;
      l_temp_sum			NUMBER := 0;
      l_mcb_flag			VARCHAR2(1);
      l_org_set				NUMBER;
      l_num_update_flag			VARCHAR2(1);
      l_ou_currency			VARCHAR2(15);

BEGIN

   --oke_debug.debug('entering fetch_create_funding..');
   --dbms_output.put_line('entering fetch_create_funding..');

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   l_return_status := OKE_API.START_ACTIVITY(p_api_name			=>	l_api_name		,
   			 		     p_pkg_name			=>	G_PKG_NAME		,
   					     p_init_msg_list		=>	p_init_msg_list		,
   			 		     l_api_version		=>	G_API_VERSION_NUMBER	,
   			 		     p_api_version		=>	p_api_version		,
   			 		     p_api_type			=>	'_PVT'			,
   			 	             x_return_status		=>	p_return_status
   			 		    );

   IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- check if all mandatory fields are there or not
   --

   validate_parameters(p_pool_party_id			=>	p_pool_party_id		,
   		       p_party_id			=>	p_party_id		,
   		       --p_source_currency		=>	p_source_currency	,
   		       p_agreement_id			=>	p_agreement_id		,
   		       p_conversion_type		=>	p_conversion_type	,
   		      -- p_pa_conversion_type		=>	p_pa_conversion_type	,
   		       p_k_header_id			=>	p_k_header_id
   		      );

   --
   -- lock agreement record
   --

   lock_agreement(p_agreement_id	=>	p_agreement_id );

   --
   -- get pa agreement attributes
   --

   OPEN c_agreement;
   FETCH c_agreement into l_agreement;
   CLOSE c_agreement;

   --
   -- Check agreement org settings
   --
   OPEN c_ou(l_agreement.org_id);
   FETCH c_ou into l_mcb_flag, l_ou_currency;
   CLOSE c_ou;

   IF (l_ou_currency <> l_agreement.agreement_currency_code) THEN

       l_num_update_flag := 'Y';

   ELSE

       l_num_update_flag := 'N';

   END IF;

   IF (l_mcb_flag = 'Y') THEN

       OPEN c_across(l_agreement.org_id);
       FETCH c_across into l_dummy;
       CLOSE c_across;

   END IF;

   --
   -- Check allow changing funding source currency or not
   --
   /*
   OPEN c_update(l_agreement.org_id);
   FETCH c_update into l_dummy;
   CLOSE c_update;

   IF (l_dummy <> '?') 								    OR
      (l_agreement.agreement_currency_code <> l_agreement.functional_currency_code) THEN

      l_update_flag := 'N';

   END IF;

   IF (l_update_flag = 'N') AND
      (l_agreement.agreement_currency_code <> p_source_currency) THEN

       OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			   p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			   p_token1			=>	'VALUE'								,
      			   p_token1_value		=>	'p_source_currency'
  			  );

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;
*/
   --
   -- validate party_id and pool_party_id
   --

   validate_agreement_party(p_pool_party_id	=>	p_pool_party_id			,
   			    p_party_id		=>	p_party_id			,
   			    p_expiration_date	=>	l_agreement.expiration_date	,
   			    p_customer_id	=>	l_agreement.customer_id		,
   			    --p_update_flag	=>	l_update_flag			,
   			    p_currency_code	=>	l_pool_currency			,
   			    p_start_date	=>	l_start_date
   			   );

   --
   -- Check if pool party currency = agreement currency
   --
   IF (nvl(l_pool_currency, l_agreement.agreement_currency_code) <> l_agreement.agreement_currency_code) THEN

       OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			   p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			   p_token1			=>	'VALUE'								,
      			   p_token1_value		=>	'p_pool_party_id'
  			  );

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   l_contract_currency := get_k_currency(p_header_id 	=>	p_k_header_id);

   --
   -- validate conversion from source to contract
   --

   l_conversion_rate := p_conversion_rate;

   get_conversion(p_from_currency	=>	l_agreement.agreement_currency_code		,
   		  p_to_currency		=>	l_contract_currency				,
   		  p_conversion_type	=>	p_conversion_type				,
   		  p_conversion_date	=>	p_conversion_date				,
   		  p_conversion_rate	=>	l_conversion_rate				,
   		  p_return_status	=>	p_return_status
   		 );

   IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- validate conversion from source to agreement
   --
/*
   l_pa_conversion_rate := p_pa_conversion_rate;

   IF (l_update_flag = 'N') THEN

       IF (p_pa_conversion_type is not null) THEN

       	   OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			       p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			       p_token1				=>	'VALUE'								,
      			       p_token1_value			=>	'pa_conversion_type'
  			      );

           RAISE OKE_API.G_EXCEPTION_ERROR;

       END IF;

       IF (p_pa_conversion_date is not null) THEN

       	   OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			       p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			       p_token1				=>	'VALUE'								,
      			       p_token1_value			=>	'pa_conversion_date'
  			      );

           RAISE OKE_API.G_EXCEPTION_ERROR;

       END IF;

       IF (p_pa_conversion_rate is not null) THEN

       	   OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			       p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			       p_token1				=>	'VALUE'								,
      			       p_token1_value			=>	'pa_conversion_rate'
  			      );

           RAISE OKE_API.G_EXCEPTION_ERROR;

       END IF;

   ELSIF (p_source_currency <> l_agreement.agreement_currency_code) THEN

       l_min_unit := get_min_unit(p_source_currency);

       get_conversion(p_from_currency	=>	p_source_currency			,
         	      p_to_currency	=>	l_agreement.agreement_currency_code	,
   		      p_conversion_type	=>	p_pa_conversion_type			,
   		      p_conversion_date	=>	p_pa_conversion_date			,
   		      p_conversion_rate	=>	l_pa_conversion_rate			,
   		      p_return_status	=>	p_return_status
   		    );

       IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

       ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_ERROR;

       END IF;

    -- syho, 2/11/02
    ELSIF (l_pa_conversion_rate is not null) THEN

       OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			   p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			   p_token1			=>	'VALUE'								,
      			   p_token1_value		=>	'pa_conversion_rate'
  			  );

       RAISE OKE_API.G_EXCEPTION_ERROR;

    ELSIF (p_pa_conversion_type is not null) THEN

       OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			   p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			   p_token1			=>	'VALUE'								,
      			   p_token1_value		=>	'pa_conversion_type'
  			  );

       RAISE OKE_API.G_EXCEPTION_ERROR;

    ELSIF (p_pa_conversion_date is not null) THEN

       OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			   p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			   p_token1			=>	'VALUE'								,
      			   p_token1_value		=>	'pa_conversion_date'
  			  );

       RAISE OKE_API.G_EXCEPTION_ERROR;

    END IF;
    -- syho, 2/11/02
  */
    FOR l_project_funding in c_project_funding LOOP
   /*
           IF (l_min_unit is not null) THEN

               l_converted_amount := round(l_project_funding.allocated_amount * (1/l_pa_conversion_rate) / l_min_unit) * l_min_unit;

            ELSE

               l_converted_amount := l_project_funding.allocated_amount;

            END IF; */
       --     oke_debug.debug('l_converted_amount ' || l_converted_amount);
       --     l_allocated_total := l_allocated_total + l_converted_amount;

            --
            -- Same up all the positive amount and create a funding source with this amount first
            --
            IF (l_project_funding.allocated_amount >= 0) THEN

                l_temp_sum := l_temp_sum + l_project_funding.allocated_amount;

            END IF;

            l_allocation_in_rec.fund_allocation_id		:=	null					;
            l_allocation_in_rec.funding_source_id		:=	null					;
            l_allocation_in_rec.object_id			:=	p_k_header_id				;
            l_allocation_in_rec.project_id			:=	l_project_funding.project_id   		;
            l_allocation_in_rec.task_id				:=	l_project_funding.task_id		;
            l_allocation_in_rec.agreement_id			:=	p_agreement_id				;
            l_allocation_in_rec.project_funding_id		:=	l_project_funding.project_funding_id	;

            --
            -- Validate the date_allocated of project funding against pool party start date
            --
	    -- bug 3346710
           /* IF (p_pool_party_id is not null) THEN
            	IF (nvl(to_char(l_start_date, 'YYYYMMDD'), '19000101') > to_char(l_project_funding.date_allocated, 'YYYYMMDD')) THEN

           	   OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
      			               p_msg_name		=>	'OKE_PA_FUND_POOL_DATE'
      			              );

      		   RAISE OKE_API.G_EXCEPTION_ERROR;

            	END IF;
            END IF;
              */
            l_allocation_in_rec.start_date_active		:=	l_project_funding.date_allocated	;
     	   -- l_allocation_in_rec.amount				:=	l_converted_amount			;
     	    l_allocation_in_rec.amount				:=	l_project_funding.allocated_amount	;
      	    l_allocation_in_rec.k_line_id			:=	null					;
      	    l_allocation_in_rec.funding_category		:=	l_project_funding.funding_category	;

       	    --
	    -- hard limit = allocation amount if p_revenue_limit_flag = 'Y'
      	    --
      	    IF (l_agreement.invoice_limit_flag = 'Y') THEN
      	       l_allocation_in_rec.hard_limit		        :=      l_project_funding.allocated_amount	;
      	      -- l_hard_limit_total			        :=	nvl(l_hard_limit_total, 0) +
      	     --  								l_project_funding.allocated_amount	;
      	    ELSE
      	       l_allocation_in_rec.hard_limit			:=	null					;
      	    END IF;

      	    IF (l_agreement.revenue_limit_flag = 'Y') THEN
      	       l_allocation_in_rec.revenue_hard_limit		:=      l_project_funding.allocated_amount	;
      	     --  l_revenue_hard_limit_total			:=	nvl(l_revenue_hard_limit_total, 0) +
      	     --  								l_project_funding.allocated_amount	;
      	    ELSE
      	       l_allocation_in_rec.revenue_hard_limit		:=	null					;
      	    END IF;

     	    l_allocation_in_rec.fund_type			:=	null					;
     	    l_allocation_in_rec.funding_status			:=	null					;
	    l_allocation_in_rec.end_date_active			:=	null					;
     	    --l_allocation_in_rec.end_date_active			:=	l_agreement.expiration_date		;
     	    l_allocation_in_rec.fiscal_year			:=	null					;
      	    l_allocation_in_rec.reference1			:=	null					;
      	    l_allocation_in_rec.reference2			:=	null					;
            l_allocation_in_rec.reference3			:=	null					;
      	    --l_allocation_in_rec.pa_conversion_type 		:=	p_pa_conversion_type			;
      	    --l_allocation_in_rec.pa_conversion_date		:=	p_pa_conversion_date			;
      	    l_allocation_in_rec.pa_conversion_type 		:=	null					;
      	    l_allocation_in_rec.pa_conversion_date		:=	null					;
      	    l_allocation_in_rec.pa_conversion_rate		:=	null					;

      	  /*
       	    -- syho, bug 2208979
      	    IF (upper(p_pa_conversion_type) = 'USER') THEN
      	       l_allocation_in_rec.pa_conversion_rate		:=      l_pa_conversion_rate			;
      	    ELSE
      	       l_allocation_in_rec.pa_conversion_rate		:=      null					;
      	    END IF;
      	    -- syho, bug 2208979
      	 */
      	    l_allocation_in_rec.oke_attribute_category		:=	null					;
      	    l_allocation_in_rec.oke_attribute1			:=	null					;
      	    l_allocation_in_rec.oke_attribute2    		:=	null					;
      	    l_allocation_in_rec.oke_attribute3			:=	null					;
            l_allocation_in_rec.oke_attribute4			:=	null					;
            l_allocation_in_rec.oke_attribute5			:=	null					;
      	    l_allocation_in_rec.oke_attribute6  		:=	null					;
      	    l_allocation_in_rec.oke_attribute7			:=	null					;
     	    l_allocation_in_rec.oke_attribute8			:=	null					;
     	    l_allocation_in_rec.oke_attribute9			:=	null					;
     	    l_allocation_in_rec.oke_attribute10   		:=	null					;
     	    l_allocation_in_rec.oke_attribute11			:=	null					;
     	    l_allocation_in_rec.oke_attribute12			:=	null					;
     	    l_allocation_in_rec.oke_attribute13    		:=	null					;
      	    l_allocation_in_rec.oke_attribute14			:=	null					;
            l_allocation_in_rec.oke_attribute15			:=	null					;

       	    l_allocation_in_rec.pa_attribute_category		:=	l_project_funding.attribute_category				;
      	    l_allocation_in_rec.pa_attribute1			:=	l_project_funding.attribute1					;
      	    l_allocation_in_rec.pa_attribute2    		:=	l_project_funding.attribute2					;
      	    l_allocation_in_rec.pa_attribute3			:=	l_project_funding.attribute3					;
            l_allocation_in_rec.pa_attribute4			:=	l_project_funding.attribute4					;
            l_allocation_in_rec.pa_attribute5			:=	l_project_funding.attribute5					;
      	    l_allocation_in_rec.pa_attribute6  			:=	l_project_funding.attribute6					;
      	    l_allocation_in_rec.pa_attribute7			:=	l_project_funding.attribute7					;
     	    l_allocation_in_rec.pa_attribute8			:=	l_project_funding.attribute8					;
     	    l_allocation_in_rec.pa_attribute9			:=	l_project_funding.attribute9					;
     	    l_allocation_in_rec.pa_attribute10   		:=	l_project_funding.attribute10					;

            l_allocation_in_tbl(i) := l_allocation_in_rec;

            i := i + 1;

    END LOOP;

--   oke_debug.debug('funding total = ' || l_allocated_total);
/*
   --
   -- check if it is a single org implementation
   --

   OKE_FUNDING_UTIL_PKG.check_single_org(l_single_org_flag);

   --
   -- get funding source amount
   --

   IF (l_min_unit is not null) THEN

      l_allocated_total := round(l_agreement.amount * (1/l_pa_conversion_rate) / l_min_unit) * l_min_unit;

   ELSE

      l_allocated_total := l_agreement.amount;

   END IF;
 */
   --oke_debug.debug('preparing funding record');

   l_funding_in_rec.funding_source_id			:=	null					;
   l_funding_in_rec.object_type				:=	G_OBJECT_TYPE				;
   l_funding_in_rec.object_id				:=	p_k_header_id				;
   l_funding_in_rec.pool_party_id			:=	p_pool_party_id				;
   l_funding_in_rec.k_party_id				:= 	p_party_id				;
  -- l_funding_in_rec.amount				:= 	l_allocated_total			;
   l_funding_in_rec.amount				:= 	l_temp_sum				;
   l_funding_in_rec.customer_id				:=	l_agreement.customer_id			;

   fnd_profile.get('ORG_ID',l_org_set);

   IF (nvl(l_org_set, -99) <> nvl(l_agreement.owning_organization_id, -99)) THEN
      l_funding_in_rec.agreement_org_id			:=	null					;
   ELSE
      l_funding_in_rec.agreement_org_id			:=      l_agreement.owning_organization_id	;
   END IF;

   --
   -- Hard limit = fund amount if revenue_limit_flag is 'Y'
   --

   IF (l_agreement.invoice_limit_flag = 'Y') THEN
      -- l_funding_in_rec.hard_limit			:=	l_hard_limit_total		 	;
         l_funding_in_rec.hard_limit			:=	l_temp_sum				;
   ELSE
       l_funding_in_rec.hard_limit			:=	null					;
   END IF;

   IF (l_agreement.revenue_limit_flag = 'Y') THEN
      -- l_funding_in_rec.revenue_hard_limit		:=	l_revenue_hard_limit_total		 ;
         l_funding_in_rec.revenue_hard_limit		:=	l_temp_sum				 ;
   ELSE
       l_funding_in_rec.revenue_hard_limit		:=	null					;
   END IF;

   l_funding_in_rec.currency_code			:=	l_agreement.agreement_currency_code	;
   l_funding_in_rec.k_conversion_type			:=	p_conversion_type			;
   l_funding_in_rec.k_conversion_date			:= 	p_conversion_date			;

   -- syho, bug 2208979
   IF (upper(p_conversion_type) = 'USER') THEN
      l_funding_in_rec.k_conversion_rate		:=	l_conversion_rate			;
   ELSE
      l_funding_in_rec.k_conversion_rate		:=	null					;
   END IF;
   -- syho, bug 2208979

   l_funding_in_rec.end_date_active			:=	l_agreement.expiration_date		;
   l_funding_in_rec.agreement_number			:=	l_agreement.agreement_num		;
   l_funding_in_rec.start_date_active			:=	l_start_date				;
   l_funding_in_rec.funding_status			:=	null					;
   l_funding_in_rec.oke_attribute_category		:=	null					;
   l_funding_in_rec.oke_attribute1			:=	null					;
   l_funding_in_rec.oke_attribute2    			:=	null					;
   l_funding_in_rec.oke_attribute3			:=	null					;
   l_funding_in_rec.oke_attribute4			:=	null					;
   l_funding_in_rec.oke_attribute5			:=	null					;
   l_funding_in_rec.oke_attribute6  			:=	null					;
   l_funding_in_rec.oke_attribute7			:=	null					;
   l_funding_in_rec.oke_attribute8			:=	null					;
   l_funding_in_rec.oke_attribute9			:=	null					;
   l_funding_in_rec.oke_attribute10   			:=	null					;
   l_funding_in_rec.oke_attribute11			:=	null					;
   l_funding_in_rec.oke_attribute12			:=	null					;
   l_funding_in_rec.oke_attribute13    			:=	null					;
   l_funding_in_rec.oke_attribute14			:=	null					;
   l_funding_in_rec.oke_attribute15			:=	null					;
   l_funding_in_rec.pa_attribute_category		:=	l_agreement.attribute_category		;
   l_funding_in_rec.pa_attribute1			:=	l_agreement.attribute1			;
   l_funding_in_rec.pa_attribute2    			:=	l_agreement.attribute2			;
   l_funding_in_rec.pa_attribute3			:=	l_agreement.attribute3			;
   l_funding_in_rec.pa_attribute4			:=	l_agreement.attribute4			;
   l_funding_in_rec.pa_attribute5			:=	l_agreement.attribute5			;
   l_funding_in_rec.pa_attribute6  			:=	l_agreement.attribute6			;
   l_funding_in_rec.pa_attribute7			:=	l_agreement.attribute7			;
   l_funding_in_rec.pa_attribute8			:=	l_agreement.attribute8			;
   l_funding_in_rec.pa_attribute9			:=	l_agreement.attribute9			;
   l_funding_in_rec.pa_attribute10   			:=	l_agreement.attribute10			;

   --oke_debug.debug('calling create_funding');
   create_funding(p_api_version		=>	p_api_version		,
   		  p_init_msg_list	=>	OKE_API.G_FALSE		,
   		  p_msg_count		=>	p_msg_count		,
   	          p_msg_data		=>	p_msg_data		,
   		  p_funding_in_rec	=>	l_funding_in_rec	,
		  p_funding_out_rec	=>	l_funding_out_rec	,
		  p_return_status	=>	p_return_status
		 );
   --oke_debug.debug('finished create_funding w/status ' || p_return_status);

   IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Update pa agreement with new agreement reference
   --

   update_agreement_reference(p_agreement_id		=>	p_agreement_id				,
   			      p_org_id			=>	l_agreement.org_id			,
   			      p_currency_code		=>	l_agreement.agreement_currency_code	,
   			      p_funding_source_id	=>	l_funding_out_rec.funding_source_id	,
   			      p_num_update_flag		=>	l_num_update_flag			);

   IF (l_allocation_in_tbl.COUNT > 0) THEN

      i := l_allocation_in_tbl.FIRST;

      LOOP

      --oke_debug.debug('calling oke_allocation_pvt.add_allocation');
        l_allocation_in_rec := l_allocation_in_tbl(i);
        l_allocation_in_rec.funding_source_id := l_funding_out_rec.funding_source_id;

      --oke_debug.debug('converted_amount ' || l_allocation_in_rec.amount);
        OKE_ALLOCATION_PVT.add_allocation(p_api_version		=>	p_api_version				,
   				          p_init_msg_list	=>	OKE_API.G_FALSE				,
   				          p_commit		=>	OKE_API.G_FALSE				,
   				          p_msg_count		=>	p_msg_count				,
   				          p_msg_data		=>	p_msg_data				,
   				          p_allocation_in_rec	=>	l_allocation_in_rec			,
		   		          p_allocation_out_rec	=>	l_allocation_out_rec			,
		   		          p_return_status	=>	p_return_status
		   		         );

      --oke_debug.debug('finished calling oke_allocation_pvt.add_allocation w/ status' || p_return_status);

        IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

            RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

        ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

            RAISE OKE_API.G_EXCEPTION_ERROR;

        END IF;

	--
        -- Update project funding with new funding reference
        --

        update_proj_fld_reference(p_project_funding_id		=>	l_allocation_in_rec.project_funding_id		,
        		          p_fund_allocation_id		=>	l_allocation_out_rec.fund_allocation_id
        		         );

        --
        -- update agreement_version in OKE_K_FUND_ALLOCATIONS table
        --

        --dbms_output.put_line('calling oke_funding_util.update_alloc_version');
        --oke_debug.debug('calling oke_funding_util.update_alloc_version');

        OKE_FUNDING_UTIL_PKG.update_alloc_version(x_fund_allocation_id		=>	l_allocation_out_rec.fund_allocation_id	,
   					          x_version_add			=>	1					,
   					          x_commit			=>	OKE_API.G_FALSE
   					         );

        EXIT WHEN (i = l_allocation_in_tbl.LAST);
        i := l_allocation_in_tbl.NEXT(i);

      END LOOP;

   END IF;

   --
   -- Update the funding source amount to the correct amount
   --
   l_funding_in_rec.amount			:= 	l_agreement.amount		;
   IF (nvl(l_agreement.invoice_limit_flag, 'N') = 'Y') THEN
      l_funding_in_rec.hard_limit		:=	l_agreement.amount		;
   ELSE
      l_funding_in_rec.hard_limit 		:= 	null				;
   END IF;
   IF (nvl(l_agreement.revenue_limit_flag, 'N') = 'Y') THEN
      l_funding_in_rec.revenue_hard_limit	:= 	l_agreement.amount		;
   ELSE
      l_funding_in_rec.revenue_hard_limit	:= 	null				;
   END IF;
  -- l_funding_in_rec.hard_limit		:=	l_hard_limit_total		 	;
   --l_funding_in_rec.revenue_hard_limit	:= 	l_revenue_hard_limit_total		;
   l_funding_in_rec.funding_source_id   :=      l_funding_out_rec.funding_source_id	;

   --oke_debug.debug('calling create_funding');
   update_funding(p_api_version		=>	p_api_version		,
   		  p_init_msg_list	=>	OKE_API.G_FALSE		,
   		  p_msg_count		=>	p_msg_count		,
   	          p_msg_data		=>	p_msg_data		,
   		  p_funding_in_rec	=>	l_funding_in_rec	,
		  p_funding_out_rec	=>	l_funding_out_rec	,
		  p_return_status	=>	p_return_status
		 );
   --oke_debug.debug('finished create_funding w/status ' || p_return_status);

   IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Update initial amount and pa_flag
   --
   update oke_k_funding_sources
   set    initial_amount = l_agreement.amount,
          funding_across_ou = decode(l_dummy, 'x', 'Y')
   where  funding_source_id = l_funding_out_rec.funding_source_id;

   p_funding_source_id := l_funding_out_rec.funding_source_id;
   --oke_debug.debug('finished calling fetch_create_funding');

   --
   -- update the pa_flag to be 'Y'
   --
   update oke_k_fund_allocations
   set    pa_flag = 'Y'
   where  funding_source_id = l_funding_out_rec.funding_source_id;

   --
   -- update the agreement_flag in OKE_FUNDING_SOURCES table
   --

   OKE_FUNDING_UTIL_PKG.update_source_flag(x_funding_source_id	=>	l_funding_out_rec.funding_source_id	,
   					   x_commit		=>	OKE_API.G_FALSE
   					  );

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   OKE_API.END_ACTIVITY(x_msg_count	=>	p_msg_count	,
   			x_msg_data      =>	p_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION THEN
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OTHERS THEN
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

END fetch_create_funding;



--
-- Function: get_funding_rec
--
-- Description: This function initializes a record of funding_rec_in_type
--

FUNCTION get_funding_rec RETURN FUNDING_REC_IN_TYPE is
   funding_in_rec	FUNDING_REC_IN_TYPE;
BEGIN

   return funding_in_rec;

END get_funding_rec;

end OKE_FUNDSOURCE_PVT;

/
