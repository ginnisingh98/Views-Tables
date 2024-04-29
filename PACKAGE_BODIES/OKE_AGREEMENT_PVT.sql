--------------------------------------------------------
--  DDL for Package Body OKE_AGREEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_AGREEMENT_PVT" as
/* $Header: OKEVKAGB.pls 120.3 2005/10/11 12:26:24 ifilimon noship $ */

--
-- Local Variables
--

  L_USER_ID		NUMBER := FND_GLOBAL.USER_ID;
  g_agrnum_length       NUMBER := 0;


--
-- Private Procedures and Functions
--

--
-- Function: set_hard_limit
--
-- Description: This function is used to set the hard limit flag
--
--

FUNCTION set_hard_limit(p_hard_limit	NUMBER) RETURN VARCHAR2
		       is

BEGIN

   IF (p_hard_limit is null)              OR
      (p_hard_limit = OKE_API.G_MISS_NUM) OR
      (p_hard_limit = 0)                  THEN

      return('N');

   ELSE

      return('Y');

   END IF;

END set_hard_limit;


--
-- Function: get_term_id
--
-- Description: This function is used to get term_id
--
--

FUNCTION get_term_id(p_object_id	NUMBER) RETURN NUMBER
		    is

   cursor c_term is
      select to_number(term_value_pk1)
      from   oke_k_terms
      where  term_code = 'RA_PAYMENT_TERMS'
      and    k_header_id = p_object_id
      and    k_line_id is null;

   l_term 		NUMBER;

BEGIN
   --oke_debug.debug('in getting term id....');
   OPEN c_term;
   FETCH c_term into l_term;

   IF (c_term%NOTFOUND) THEN

      CLOSE c_term;
      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'receivable term_id'
     			 );

      RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   CLOSE c_term;
   return(l_term);

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;

   WHEN OTHERS THEN
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_term%ISOPEN THEN
         CLOSE c_term;
      END IF;

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END get_term_id;


--
-- Function: set_default
--
-- Description: This function is used to replace the default values to be null for
--	       	pa df
--

FUNCTION set_default(p_funding_in_rec OKE_FUNDSOURCE_PVT.FUNDING_REC_IN_TYPE)
	 RETURN OKE_FUNDSOURCE_PVT.FUNDING_REC_IN_TYPE is

   l_funding_in_rec	OKE_FUNDSOURCE_PVT.FUNDING_REC_IN_TYPE := p_funding_in_rec;

BEGIN

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

   IF l_funding_in_rec.agreement_org_id = OKE_API.G_MISS_NUM THEN
      l_funding_in_rec.agreement_org_id := null;
   END IF;

   return(l_funding_in_rec);

END set_default;


--
-- Function: populate_values
--
-- Description: This function is used to populate values for
--	       	pa df
--

FUNCTION populate_values(p_allocation_in_rec OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE)
	 RETURN OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE is

   cursor c_allocation is
      select *
      from   oke_k_fund_allocations
      where  fund_allocation_id = p_allocation_in_rec.fund_allocation_id;

   l_allocation_in_rec	OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE := p_allocation_in_rec;
   l_allocation_row	OKE_K_FUND_ALLOCATIONS%ROWTYPE;

BEGIN

   OPEN c_allocation;
   FETCH c_allocation INTO l_allocation_row;
   CLOSE c_allocation;

   l_allocation_in_rec.funding_source_id := l_allocation_row.funding_source_id;
   --l_allocation_in_rec.amount		 := l_allocation_row.amount;
   l_allocation_in_rec.project_id	 := l_allocation_row.project_id;
   l_allocation_in_rec.task_id 		 := l_allocation_row.task_id;
   l_allocation_in_rec.start_date_active := l_allocation_row.start_date_active;
   l_allocation_in_rec.funding_category  := l_allocation_row.funding_category;

   IF l_allocation_in_rec.pa_attribute_category = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute_category := l_allocation_row.pa_attribute_category;
   END IF;

   IF l_allocation_in_rec.pa_attribute1 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute1 := l_allocation_row.pa_attribute1;
   END IF;

   IF l_allocation_in_rec.pa_attribute2 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute2 := l_allocation_row.pa_attribute2;
   END IF;

   IF l_allocation_in_rec.pa_attribute3 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute3 := l_allocation_row.pa_attribute3;
   END IF;

   IF l_allocation_in_rec.pa_attribute4 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute4 := l_allocation_row.pa_attribute4;
   END IF;

   IF l_allocation_in_rec.pa_attribute5 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute5 := l_allocation_row.pa_attribute5;
   END IF;

   IF l_allocation_in_rec.pa_attribute6 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute6 := l_allocation_row.pa_attribute6;
   END IF;

   IF l_allocation_in_rec.pa_attribute7 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute7 := l_allocation_row.pa_attribute7;
   END IF;

   IF l_allocation_in_rec.pa_attribute8 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute8 := l_allocation_row.pa_attribute8;
   END IF;

   IF l_allocation_in_rec.pa_attribute9 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute9 := l_allocation_row.pa_attribute9;
   END IF;

   IF l_allocation_in_rec.pa_attribute10 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute10 := l_allocation_row.pa_attribute10;
   END IF;

   return(l_allocation_in_rec);

END populate_values;

--
-- Function: prepare_agreement_record
--
-- Description: This procedure is used to prepare for agreement record
--

PROCEDURE prepare_agreement_record(p_funding_in_rec 	IN		OKE_FUNDSOURCE_PVT.FUNDING_REC_IN_TYPE,
				   p_agreement_type	IN		VARCHAR2			      ,
				   p_agreement_in_rec   OUT NOCOPY	PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE,
				   p_agreement_length   IN              NUMBER
				   ) is
   l_term_id				NUMBER;
   l_hard_limit				VARCHAR2(1);
   l_revenue_hard_limit			VARCHAR2(1);

BEGIN

   l_hard_limit 	:= set_hard_limit(p_funding_in_rec.hard_limit);
   l_revenue_hard_limit := set_hard_limit(p_funding_in_rec.revenue_hard_limit);
   l_term_id    	:= get_term_id(p_object_id => p_funding_in_rec.object_id);

   p_agreement_in_rec.customer_id		:=	p_funding_in_rec.customer_id				;
   p_agreement_in_rec.customer_num		:=	p_funding_in_rec.customer_number			;
   p_agreement_in_rec.agreement_num		:=	substr(p_funding_in_rec.agreement_number, 1, p_agreement_length);
   p_agreement_in_rec.agreement_type         	:=	p_agreement_type					;
   p_agreement_in_rec.revenue_limit_flag	:=	l_revenue_hard_limit					;
   p_agreement_in_rec.invoice_limit_flag	:=	l_hard_limit						;
   p_agreement_in_rec.expiration_date		:=	p_funding_in_rec.end_date_active			;
   p_agreement_in_rec.description		:=	G_DESCRIPTION						;
   p_agreement_in_rec.owned_by_person_id 	:=	OKE_FUNDING_UTIL_PKG.get_owned_by(L_USER_ID)		;
   p_agreement_in_rec.term_id			:=	l_term_id						;
   p_agreement_in_rec.template_flag		:=	'N'							;
   p_agreement_in_rec.attribute_category        :=      p_funding_in_rec.pa_attribute_category			;
   p_agreement_in_rec.attribute1                :=      p_funding_in_rec.pa_attribute1				;
   p_agreement_in_rec.attribute2                :=      p_funding_in_rec.pa_attribute2				;
   p_agreement_in_rec.attribute3                :=      p_funding_in_rec.pa_attribute3				;
   p_agreement_in_rec.attribute4                :=      p_funding_in_rec.pa_attribute4				;
   p_agreement_in_rec.attribute5                :=      p_funding_in_rec.pa_attribute5				;
   p_agreement_in_rec.attribute6                :=      p_funding_in_rec.pa_attribute6				;
   p_agreement_in_rec.attribute7                :=      p_funding_in_rec.pa_attribute7				;
   p_agreement_in_rec.attribute8                :=      p_funding_in_rec.pa_attribute8				;
   p_agreement_in_rec.attribute9                :=      p_funding_in_rec.pa_attribute9				;
   p_agreement_in_rec.attribute10               :=      p_funding_in_rec.pa_attribute10				;
   p_agreement_in_rec.desc_flex_name		:=      G_PA_DESC_FLEX_NAME					;
   p_agreement_in_rec.owning_organization_id	:=	p_funding_in_rec.agreement_org_id			;
   p_agreement_in_rec.agreement_currency_code   :=      null							;

END prepare_agreement_record;

--
-- Function: format_agreement_num
--
-- Description: This procedure is used to format the agreement number
--
--
PROCEDURE format_agreement_num(p_agreement_number	IN 		VARCHAR2	,
			       p_agreement_num_out	OUT NOCOPY	VARCHAR2	,
         	               p_currency_code		IN		VARCHAR2	,
         	               p_org_id			IN		NUMBER		,
         	               p_reference_in		IN		NUMBER		,
         	               p_reference		OUT NOCOPY	VARCHAR2        ,
			       p_agreement_length       IN              NUMBER
         	              ) is

   cursor c_currency is
      select currency_code
      from   gl_sets_of_books g,
             pa_implementations_all p
      where  nvl(p_org_id, -99) = nvl(p.org_id, -99)
      and    p.set_of_books_id = g.set_of_books_id;

   l_ou_currency 		VARCHAR2(15);

BEGIN

   open c_currency;
   fetch c_currency into l_ou_currency;
   close c_currency;

   if (l_ou_currency <> p_currency_code) then

       -- Bug 3427900, start
      -- p_agreement_num_out := substr(p_agreement_number, 1, (20 - 1 - length(p_currency_code))) || '-' || p_currency_code;
       p_agreement_num_out := substr(p_agreement_number, 1, (p_agreement_length - 1 - length(p_currency_code))) || '-' || p_currency_code;
       -- Bug3427900, end
   else

       p_agreement_num_out := substr(p_agreement_number, 1, p_agreement_length);

   end if;

   p_reference         := p_org_id || '-' || p_currency_code || '-' || p_reference_in;

END format_agreement_num;

--
-- Function: agreement_length
--
-- Description: This function returns the length of agreement number in the table
--
FUNCTION agreement_length RETURN NUMBER is

   cursor c_length(b_owner varchar2) is
      select data_length
      from   all_tab_columns
      where  table_name = 'PA_AGREEMENTS_ALL'
      and    column_name = 'AGREEMENT_NUM'
      and    owner = b_owner;

   l_schema_owner               varchar2(10);
   l_status                     varchar2(10);
   l_industry                   varchar2(100);

 BEGIN

  IF g_agrnum_length=0 THEN
    g_agrnum_length := 20;
    If  FND_INSTALLATION.GET_APP_INFO(
          application_short_name	=>'PA',
          status			=> l_status,
          industry		=> l_industry,
          oracle_schema		=> l_schema_owner)
     then
      open c_length(l_schema_owner);
      fetch c_length into g_agrnum_length;
      close c_length;
    end if;
  END IF;

  return (g_agrnum_length);

END agreement_length;

--
-- Function: get_agreement_org
--
-- Description: This function is used to get the agreement org_id
--
--
/*
FUNCTION get_agreement_org(p_agreement_id		NUMBER)
	 RETURN NUMBER is

   cursor c_org is
     select org_id
     from   pa_agreements_all
     where  agreement_id = p_agreement_id;

   l_org_id	NUMBER;

BEGIN

   OPEN c_org;
   FETCH c_org into l_org_id;

   IF (c_org%NOTFOUND) THEN

      CLOSE c_org;

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'agreement_id'
     			 );

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   END IF;

   CLOSE c_org;

   RETURN(nvl(l_org_id, -99));

END get_agreement_org;

*/
--
-- Procedure: get_proj_funding
--
-- Description: This procedure is used to get project_funding_id
--		and retrieve the project funding row
--
--

PROCEDURE get_proj_funding(p_fund_allocation_id				NUMBER					,
			   p_version					NUMBER					,
			   p_project_funding		OUT NOCOPY	PA_PROJECT_FUNDINGS%ROWTYPE
			  ) is

   cursor c_project is
      select *
      from   pa_project_fundings
      where  pm_product_code = G_PRODUCT_CODE
      and    pm_funding_reference = to_char(p_fund_allocation_id) || '.' || to_char(p_version)
   FOR UPDATE OF project_funding_id NOWAIT;

BEGIN

   OPEN c_project;
   FETCH c_project into p_project_funding;

   IF (c_project%NOTFOUND) THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'project_funding_id'
     			 );

      CLOSE c_project;

      RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   CLOSE c_project;

EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION OR OKE_API.G_EXCEPTION_ERROR THEN
      raise G_EXCEPTION_HALT_VALIDATION;

   WHEN OTHERS THEN
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_project%ISOPEN THEN
         CLOSE c_project;
      END IF;

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END get_proj_funding;


--
-- Procedure: validate_agreement_id
--
-- Description: This procedure is used to validate agreement_id
--
--

PROCEDURE validate_agreement_id(p_agreement_id			NUMBER	,
				p_return_status	OUT NOCOPY	VARCHAR2
			       ) is
BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_agreement_id is null) 			OR
      (p_agreement_id = OKE_API.G_MISS_NUM)	THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'agreement_id'
     			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

    END IF;

END validate_agreement_id;


--
-- Procedure: validate_project_id
--
-- Description: This procedure is used to validate project_id
--
--

PROCEDURE validate_project_id(p_project_id			NUMBER	,
			      p_return_status	OUT NOCOPY	VARCHAR2
			     ) is
BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_project_id is null) 			OR
      (p_project_id = OKE_API.G_MISS_NUM)	THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'project_id'
     			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

    END IF;

END validate_project_id;


--
-- Procedure: validate_task_id
--
-- Description: This procedure is used to validate task_id
--
--

PROCEDURE validate_task_id(p_project_id				NUMBER	,
			   p_task_id				NUMBER	,
			   p_return_status	OUT NOCOPY	VARCHAR2
			  ) is

   l_count		NUMBER;
   l_project_number	VARCHAR2(25);

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_task_id is not null) 			OR
      (p_task_id <> OKE_API.G_MISS_NUM)		THEN

      OKE_FUNDING_UTIL_PKG.multi_customer(x_project_id		=>	p_project_id	,
      					  x_project_number	=>	l_project_number,
      					  x_count		=>	l_count
      					  );

      IF (l_count > 1) then

         OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			     p_msg_name		=>	'OKE_MULTI_CUSTOMER_PROJ'	,
      			     p_token1		=> 	'PROJECT'			,
      			     p_token1_value	=> 	l_project_number
     			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

       END IF;

   END IF;

END validate_task_id;


--
-- Procedure: validate_date_allocated
--
-- Description: This procedure is used to validate date_allocated
--
--

PROCEDURE validate_date_allocated(p_date_allocated			DATE	,
			  	  p_return_status	OUT NOCOPY	VARCHAR2
			         ) is
BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_date_allocated is null) 			OR
      (p_date_allocated = OKE_API.G_MISS_DATE)		THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'start_date_active'
     			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

    END IF;

END validate_date_allocated;


--
-- Procedure: validate_funding_category
--
-- Description: This procedure is used to validate funding_category
--
--

PROCEDURE validate_funding_category(p_funding_category			VARCHAR2	,
			  	    p_return_status	OUT NOCOPY	VARCHAR2
			           ) is
BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_funding_category is null) 				OR
      (p_funding_category = OKE_API.G_MISS_CHAR)		THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'funding_category'
     			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

   END IF;

END validate_funding_category;


--
-- Procedure: validate_line_attributes
--
-- Description: This procedure is used to validate allocation record
--
--

PROCEDURE validate_line_attributes(p_allocation_in_rec		OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE) is
   l_return_status	 VARCHAR2(1);
BEGIN

   --
   -- Validate Agreement_id
   --

   validate_agreement_id(p_agreement_id		=>	p_allocation_in_rec.agreement_id	,
   			 p_return_status	=>	l_return_status);

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate Project_id
   --

   validate_project_id(p_project_id	=>	p_allocation_in_rec.project_id	,
   		       p_return_status	=>	l_return_status);

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate Task_id
   --
   -- Bug 3519242, start
   /*
   validate_task_id(p_task_id		=>	p_allocation_in_rec.task_id	,
   		    p_project_id	=>	p_allocation_in_rec.project_id	,
   		    p_return_status	=>	l_return_status);

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;
   */
   -- Bug 3519242, end

   --
   -- Validate Date_allocated
   --

   validate_date_allocated(p_date_allocated		=>	p_allocation_in_rec.start_date_active	,
   		  	   p_return_status		=>	l_return_status);

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Funding Category
   --

   validate_funding_category(p_funding_category		=>	p_allocation_in_rec.funding_category	,
   		  	     p_return_status		=>	l_return_status);

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

END validate_line_attributes;


--
-- Procedure: get_min_unit
--
-- Description: This procedure is used to get the mini unit of the currency
--
--

PROCEDURE get_min_unit(p_min_unit		OUT NOCOPY	VARCHAR2,
		       p_agreement_currency			VARCHAR2)
		       is

   cursor c_currency is
      select nvl(minimum_accountable_unit, power(10, -1 * precision))
      from   fnd_currencies f
      where  f.currency_code = p_agreement_currency;

BEGIN

   OPEN c_currency;
   FETCH c_currency into p_min_unit;
   CLOSE c_currency;

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;

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
-- Procedure: get_converted_amount
--
-- Description: This function is used to calculate the allocated amount
--
--

PROCEDURE get_converted_amount(p_allocation_in_rec	IN OUT NOCOPY	OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE	,
			       --p_amount			OUT NOCOPY	NUMBER						,
			       p_org_id			OUT NOCOPY      NUMBER						,
			       p_return_status	 	OUT NOCOPY	VARCHAR2
			      )is

    l_min_unit			NUMBER;
    l_currency			VARCHAR2(15);

    NO_FUND			EXCEPTION;

    cursor c_currency is
    	select currency_code
    	from   oke_k_funding_sources
    	where  funding_source_id = p_allocation_in_rec.funding_source_id;

    cursor c_rate is
        select pa_conversion_rate,
               pa_conversion_date,
               pa_conversion_type
        from   oke_k_fund_allocations
        where  fund_allocation_id = p_allocation_in_rec.fund_allocation_id;

    cursor c_ou is
        select org_id,
               agreement_currency_code
        from   pa_agreements_all a
        where  a.agreement_id = p_allocation_in_rec.agreement_id;

    l_allocation 	c_rate%ROWTYPE;
    l_ou		c_ou%ROWTYPE;
    l_amount		number;

BEGIN

    p_return_status := 'S';

    OPEN c_currency;
    FETCH c_currency into l_currency;

    IF (c_currency%NOTFOUND) THEN

       raise NO_FUND;

    END IF;

    CLOSE c_currency;

    OPEN c_rate;
    FETCH c_rate into l_allocation;
    CLOSE c_rate;

    OPEN c_ou;
    FETCH c_ou into l_ou;
    CLOSE c_ou;

    p_org_id := l_ou.org_id;

    IF (l_ou.agreement_currency_code <> l_currency) THEN

        get_min_unit(p_min_unit			=>	l_min_unit					,
    		     p_agreement_currency	=>	l_ou.agreement_currency_code
    		    );

        OKE_FUNDING_UTIL_PKG.get_calculate_amount(x_conversion_type		=>	l_allocation.pa_conversion_type		,
			      		          x_conversion_date		=>	l_allocation.pa_conversion_date		,
			      		          x_conversion_rate		=>	l_allocation.pa_conversion_rate		,
			      		          x_org_amount			=>	p_allocation_in_rec.amount		,
			      		          x_min_unit			=>	l_min_unit				,
			       		          x_fund_currency		=>	l_currency				,
			     	  	          x_project_currency		=>	l_ou.agreement_currency_code		,
      			     		         -- x_amount			=>	p_allocation_in_rec.amount		,
      			     		          x_amount			=>	l_amount				,
      			     		          x_return_status		=>	p_return_status
      			     		         );

        p_allocation_in_rec.pa_conversion_type := null;
        p_allocation_in_rec.pa_conversion_date := null;
        p_allocation_in_rec.pa_conversion_rate := null;
        p_allocation_in_rec.amount 	       := l_amount;

    ELSE

        p_allocation_in_rec.pa_conversion_type := l_allocation.pa_conversion_type;
        p_allocation_in_rec.pa_conversion_date := l_allocation.pa_conversion_date;
        p_allocation_in_rec.pa_conversion_rate := l_allocation.pa_conversion_rate;

    END IF;

EXCEPTION
    WHEN NO_FUND THEN
        OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			    p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			    p_token1		=> 	'VALUE'				,
      			    p_token1_value	=> 	'funding_source_id'
     			    );

        IF c_currency%ISOPEN THEN
           CLOSE c_currency;
        END IF;

        RAISE OKE_API.G_EXCEPTION_ERROR;

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

        IF c_rate%ISOPEN THEN
           CLOSE c_rate;
        END IF;

        IF c_ou%ISOPEN THEN
           CLOSE c_ou;
        END IF;

        RAISE OKE_API.G_EXCEPTION_ERROR;

END get_converted_amount;


--
-- Procedure: validate_agreement_type
--
-- Description: This procedure is used to validate agreement_type
--
--

PROCEDURE validate_agreement_type(p_agreement_type			VARCHAR2	,
   			   	  p_return_status	OUT NOCOPY	VARCHAR2
   			  	 ) is

   cursor c_agreement_type is
      select 'x'
      from   pa_agreement_types
      where  UPPER(agreement_type) = UPPER(p_agreement_type);

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_agreement_type is not null)			OR
      (p_agreement_type <> OKE_API.G_MISS_CHAR) 	THEN

      OPEN c_agreement_type;
      FETCH c_agreement_type into l_dummy_value;
      CLOSE c_agreement_type;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'agreement_type'
      			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

      END IF;

   ELSE

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME				,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'p_agreement_type'
     			 );

      p_return_status		         := OKE_API.G_RET_STS_ERROR;

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

      IF c_agreement_type%ISOPEN THEN
         CLOSE c_agreement_type;
      END IF;

END validate_agreement_type;


--
-- Procedure: validate_customer_num
--
-- Description: This procedure is used to validate customer_number
--
--

PROCEDURE validate_customer_num(p_customer_id		IN		NUMBER		,
   			        p_customer_num		IN		VARCHAR2	,
   			        p_return_status		OUT NOCOPY	VARCHAR2
   		              ) is

   cursor c_customer is
      select 'x'
      from   hz_cust_accounts c,
             hz_parties p
      where  p.party_id = c.party_id
      and    p.party_number = p_customer_num
      and    c.cust_account_id = p_customer_id;

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_customer_num is null) 		 	  OR
      (p_customer_num = OKE_API.G_MISS_CHAR)      THEN

      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'	,
      			  p_token1		=>	'VALUE'			,
      			  p_token1_value	=>	'customer_number'
      			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

   ELSE

      OPEN c_customer;
      FETCH c_customer into l_dummy_value;
      CLOSE c_customer;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'customer_number'
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

      IF c_customer%ISOPEN THEN
         CLOSE c_customer;
      END IF;

END validate_customer_num;


--
-- Procedure: validate_customer_id
--
-- Description: This procedure is used to validate customer_id
--
--

PROCEDURE validate_customer_id(p_customer_id		IN		NUMBER		,
   			       p_k_party_id		IN		NUMBER		,
   			       p_return_status		OUT NOCOPY	VARCHAR2
   		             ) is

   cursor c_customer_id is
      select 'x'
      from   hz_cust_accounts
      where  party_id = p_k_party_id
      and    cust_account_id = p_customer_id;

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_customer_id is null) 		   OR
      (p_customer_id = OKE_API.G_MISS_NUM) THEN

      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'	,
      			  p_token1		=>	'VALUE'			,
      			  p_token1_value	=>	'customer_id'
      			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

   ELSE

      OPEN c_customer_id;
      FETCH c_customer_id into l_dummy_value;
      CLOSE c_customer_id;
   --dbms_output.put_line('l_dummy_value' || l_dummy_value);
      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'customer_id'
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

      IF c_customer_id%ISOPEN THEN
         CLOSE c_customer_id;
      END IF;

END validate_customer_id;


--
-- Procedure: validate_agreement_number
--
-- Description: This procedure is used to validate agreement_number
--
--

PROCEDURE validate_agreement_number(p_agreement_num			VARCHAR2,
				    p_return_status	OUT NOCOPY	VARCHAR2
			           ) is
BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_agreement_num is null) 			OR
      (p_agreement_num = OKE_API.G_MISS_CHAR)		THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'agreement_number'
     			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

    END IF;

END validate_agreement_number;


--
-- Procedure: check_project_null
--
-- Description: This procedure is used to check if any project_id is missing for allocation record
--
--

PROCEDURE check_project_null(p_funding_source_id 		NUMBER
                            ) is

   cursor c_exist is
      select 'x'
      from   oke_k_fund_allocations
      where  funding_source_id = p_funding_source_id;

   cursor c_project is
      select 'x'
      from   oke_k_fund_allocations
      where  funding_source_id = p_funding_source_id
      and    project_id is null
      and    (amount <> 0 or agreement_version is not null);

   l_dummy_value 	VARCHAR2(1) := '?';

BEGIN

   OPEN c_exist;
   FETCH c_exist into l_dummy_value;
   CLOSE c_exist;

   IF (l_dummy_value = '?') THEN

      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_NO_FUND_LINES'
      			  );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   ELSE

      l_dummy_value := '?';
      OPEN c_project;
      FETCH c_project into l_dummy_value;
      CLOSE c_project;
   --dbms_output.put_line('project null l_dummy_value ' || l_dummy_value);
      IF (l_dummy_value = 'x') THEN

          OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			      p_msg_name		=>	'OKE_API_MISSING_VALUE'	,
      			      p_token1			=>	'VALUE'			,
      			      p_token1_value		=>	'project_id'
      			    );

          RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

   END IF;

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

      IF c_project%ISOPEN THEN
         CLOSE c_project;
      END IF;

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

END check_project_null;


--
-- Procedure: validate_agreement_attributes
--
-- Description: This procedure is used to validate agreement record
--
--

PROCEDURE validate_agreement_attributes(p_funding_in_rec		OKE_FUNDSOURCE_PVT.FUNDING_REC_IN_TYPE,
					p_agreement_type		VARCHAR2
					) is
   l_return_status	 VARCHAR2(1);

BEGIN

   --
   -- Validate Agreement_type
   --
   validate_agreement_type(p_agreement_type		=>	p_agreement_type	,
   			   p_return_status		=>	l_return_status		);

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate Agreement_number
   --

   validate_agreement_number(p_agreement_num		=>	p_funding_in_rec.agreement_number	,
   			     p_return_status		=>	l_return_status				);

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate Customer_id
   --

   validate_customer_id(p_customer_id		=>	 p_funding_in_rec.customer_id		,
   		 	p_k_party_id		=>	 p_funding_in_rec.k_party_id		,
   		 	p_return_status		=>	 l_return_status
   		       );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate Customer_number
   --

   validate_customer_num(p_customer_id			=>	 p_funding_in_rec.customer_id		,
   		 	 p_customer_num			=>	 p_funding_in_rec.customer_number	,
   		 	 p_return_status		=>	 l_return_status
   		       );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

END validate_agreement_attributes;


--
-- Procedure: retrieve_agreement
--
-- Description: This procedure is used to retrieve the existing agreement
--
--

PROCEDURE retrieve_agreement(p_agreement_in_rec			IN		PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE	,
			     p_agreement_in_rec_new		OUT NOCOPY	PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE	,
			     p_agreement_amount			OUT NOCOPY	NUMBER
             		     ) is
   cursor c_agreement is
      select *
      from   pa_agreements_all
      where  agreement_id = p_agreement_in_rec.agreement_id;

   l_agreement_row		c_agreement%ROWTYPE;

BEGIN

   --oke_debug.debug('entering retrieve_agreement');
   --dbms_output.put_line('entering retrieve_agreement');

   p_agreement_in_rec_new := p_agreement_in_rec;

   OPEN c_agreement;
   FETCH c_agreement into l_agreement_row;

   IF (c_agreement%NOTFOUND) THEN

      CLOSE c_agreement;
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   END IF;

   CLOSE c_agreement;

   p_agreement_in_rec_new.agreement_type := l_agreement_row.agreement_type;
   p_agreement_in_rec_new.description := l_agreement_row.description;
   p_agreement_in_rec_new.amount := l_agreement_row.amount + nvl(p_agreement_in_rec.amount, 0);
   p_agreement_amount := l_agreement_row.amount;
   p_agreement_in_rec_new.agreement_currency_code := l_agreement_row.agreement_currency_code;

   IF (p_agreement_in_rec_new.revenue_limit_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.revenue_limit_flag := l_agreement_row.revenue_limit_flag;
   END IF;

   IF (p_agreement_in_rec_new.invoice_limit_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.invoice_limit_flag := l_agreement_row.invoice_limit_flag;
   END IF;

   IF (p_agreement_in_rec_new.term_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
       p_agreement_in_rec_new.term_id := l_agreement_row.term_id;
   END IF;

   IF (p_agreement_in_rec_new.owning_organization_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
       p_agreement_in_rec_new.owning_organization_id := l_agreement_row.owning_organization_id;
   END IF;

   IF (p_agreement_in_rec_new.owned_by_person_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
       p_agreement_in_rec_new.owned_by_person_id := l_agreement_row.owned_by_person_id;
   END IF;
 /*
   IF (p_agreement_in_rec_new.attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.attribute_category := l_agreement_row.attribute_category;
   END IF;

   IF (p_agreement_in_rec_new.attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.attribute1 := l_agreement_row.attribute1;
   END IF;

   IF (p_agreement_in_rec_new.attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.attribute2 := l_agreement_row.attribute2;
   END IF;

   IF (p_agreement_in_rec_new.attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.attribute3 := l_agreement_row.attribute3;
   END IF;

   IF (p_agreement_in_rec_new.attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.attribute4 := l_agreement_row.attribute4;
   END IF;

   IF (p_agreement_in_rec_new.attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.attribute5 := l_agreement_row.attribute5;
   END IF;

   IF (p_agreement_in_rec_new.attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.attribute6 := l_agreement_row.attribute6;
   END IF;

   IF (p_agreement_in_rec_new.attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.attribute7 := l_agreement_row.attribute7;
   END IF;

   IF (p_agreement_in_rec_new.attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.attribute8 := l_agreement_row.attribute8;
   END IF;

   IF (p_agreement_in_rec_new.attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.attribute9 := l_agreement_row.attribute9;
   END IF;

   IF (p_agreement_in_rec_new.attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.attribute10 := l_agreement_row.attribute10;
   END IF;
*/
   IF (p_agreement_in_rec_new.template_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
       p_agreement_in_rec_new.template_flag := l_agreement_row.template_flag;
   END IF;

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

      IF c_agreement%ISOPEN THEN
         CLOSE c_agreement;
      END IF;

END retrieve_agreement;


--
-- Procedure: upd_insert_agreement
--
-- Description: This procedure is used to update/create agreement
--
--
/*
PROCEDURE upd_insert_agreement(p_agreement_in_rec				PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE	,
   		 	       p_agreement_tbl		       			AGREEMENT_TBL_TYPE			,
   		 	       p_pa_agreement_tbl				AGREEMENT_TBL_TYPE			,
   		 	       p_funding_source_id				NUMBER					,
   		 	      -- p_insert_flag					VARCHAR2				,
   		 	       p_funding_amount					NUMBER					,
   		 	       p_agreement_out_tbl	OUT NOCOPY		PA_AGREEMENT_TBL_TYPE			,
   		 	       p_pa_agreement_out_tbl	OUT NOCOPY		PA_AGREEMENT_TBL_TYPE			,
   		 	       p_api_version					NUMBER					,
   		 	       p_msg_count		OUT NOCOPY		NUMBER					,
   		 	       p_msg_data		OUT NOCOPY		VARCHAR2				,
   		 	       p_return_status		OUT NOCOPY		VARCHAR2
   			      ) is

   cursor c_total(x_org_id NUMBER) is
     select sum(nvl(f.allocated_amount, 0)), p.agreement_id
     from   pa_project_fundings f,
     	    pa_agreements_all p
     where  p.agreement_id = f.agreement_id
     and    p.pm_product_code = G_PRODUCT_CODE
     and    p.pm_agreement_reference = x_org_id || '-N-' || p_funding_source_id
     group by p.agreement_id;

   cursor c_total2(x_agreement_id NUMBER) is
     select sum(nvl(f.allocated_amount, 0))
     from   pa_project_fundings f
     where  f.agreement_id = x_agreement_id
     group by f.agreement_id;

   cursor c_agreement_count (x_length NUMBER) is
     select count(1)
     from   pa_agreements_all
     where  pm_product_code = G_PRODUCT_CODE
     and    substr(pm_agreement_reference, -1 * x_length, x_length) = '-' || to_char(p_funding_source_id);

   cursor c_update_agreement (x_length NUMBER) is
     select sum(nvl(f.allocated_amount, 0)) amount, pm_agreement_reference, p.agreement_id, org_id
     from   pa_project_fundings f,
     	    pa_agreements_all p
     where  p.agreement_id = f.agreement_id
     and    p.pm_product_code = G_PRODUCT_CODE
     and    substr(pm_agreement_reference, -1 * x_length, x_length) = '-' || to_char(p_funding_source_id)
     group by p.agreement_id, pm_agreement_reference, org_id;

   cursor c_org_count2 is
     select count(distinct org_id)
     from   pa_projects_all
     where  project_id in
            (select distinct project_id
             from   oke_k_fund_allocations
             where  funding_source_id = p_funding_source_id
             and    nvl(pa_flag, 'N') = 'N'
            );

   cursor c_org_count is
     select count(distinct org_id)
     from   pa_projects_all
     where  project_id in
            (select distinct project_id
             from   oke_k_fund_allocations
             where  funding_source_id = p_funding_source_id
            );

   cursor c_allocation is
     select sum(nvl(amount, 0))
     from   oke_k_fund_allocations
     where  funding_source_id = p_funding_source_id;

   i				NUMBER;
   l_org_id_vc			VARCHAR(10);
   l_agreement_out_rec		PA_AGREEMENT_PUB.AGREEMENT_REC_OUT_TYPE;
   l_agreement_in_rec		PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE := p_agreement_in_rec;
   l_agreement_in_rec_new	PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE;
   l_funding_in_tbl		PA_AGREEMENT_PUB.FUNDING_IN_TBL_TYPE;
   l_funding_out_tbl		PA_AGREEMENT_PUB.FUNDING_OUT_TBL_TYPE;
   l_agreement_amount		NUMBER;
   l_agreement_id		NUMBER;
   l_amount			NUMBER;
   l_diff_amount		NUMBER;
   l_orig_pa_amount		NUMBER;
   l_agreement_count		NUMBER;
   l_length			NUMBER;
   l_sum_flag			VARCHAR2(1);
   l_update_flag		VARCHAR2(1);
   l_update			c_update_agreement%ROWTYPE;
   l_org_count			NUMBER;
   l_allocated_amount		NUMBER;
  -- l_pa_org_id			NUMBER;

BEGIN

   --oke_debug.debug('entering upd_insert_agreement');
   --dbms_output.put_line('entering upd_insert_agreement');

   p_return_status  		       := OKE_API.G_RET_STS_SUCCESS;

   l_length := LENGTH(p_funding_source_id);

   OPEN c_agreement_count(l_length + 1);
   FETCH c_agreement_count INTO l_agreement_count;
   IF (c_agreement_count%NOTFOUND) THEN

      l_agreement_count := 0;

   END IF;
   CLOSE c_agreement_count;

   OPEN c_agreement_count2(l_length + 2);
   FETCH c_agreement_count2 INTO l_pa_org_id;
   IF (c_agreement_count2%NOTFOUND) THEN

      l_pa_org_id := -1000;

   END IF;
   CLOSE c_agreement_count2;


   IF (p_pa_agreement_tbl.COUNT = 0) THEN
   	OPEN c_org_count;
   	FETCH c_org_count INTO l_org_count;
   	CLOSE c_org_count;
   ELSE
   	OPEN c_org_count2;
   	FETCH c_org_count2 INTO l_org_count;
        IF (c_org_count2%NOTFOUND) THEN
            l_org_count := 0;
        END IF;
   	CLOSE c_org_count2;
   	l_org_count := l_org_count + 1;
   END IF;

   IF (l_pa_org_id <> -1000) THEN

      l_org_count := l_org_count + 1;

   END IF;


   IF (p_pa_agreement_tbl.COUNT > 0) THEN

      l_org_count := l_org_count + 1;

   END IF;

   --
   -- Determine if agreement amount
   --

   IF (l_agreement_count = 0) THEN

      l_update_flag := 'N';

      IF (l_org_count = 1) THEN

         l_sum_flag := 'N';

      ELSE

         l_sum_flag := 'Y';

      END IF;

   ELSIF (l_agreement_count = 1) THEN

     IF (l_org_count = 1) THEN

        l_sum_flag    := 'N';
        l_update_flag := 'N';

     ELSE

        l_sum_flag    := 'Y';
        l_update_flag := 'Y';

     END IF;

   ELSE

     l_update_flag := 'N';
     l_sum_flag    := 'Y';

   END IF;

   --oke_debug.debug('update_flag ' || l_update_flag);
   --oke_debug.debug('sum_flag '|| l_sum_flag);

   fnd_profile.get('ORG_ID',l_org_id_vc);

   --
   -- Update existing project agreement amount if update_flag = 'Y'
   --
   IF (l_update_flag = 'Y')       	OR
      (p_agreement_tbl.COUNT = 0)  	OR
      (p_pa_agreement_tbl.COUNT = 1)    THEN

      FOR l_update in c_update_agreement(l_length + 1) LOOP

          l_agreement_in_rec.agreement_id := l_update.agreement_id;

          retrieve_agreement(p_agreement_in_rec		=>	l_agreement_in_rec	,
            		     p_agreement_in_rec_new	=>	l_agreement_in_rec_new	,
            		     p_agreement_amount		=>	l_orig_pa_amount
            		    );

         IF (l_org_count = 1)           THEN

             OPEN c_allocation;
             FETCH c_allocation into l_allocated_amount;
             CLOSE c_allocation;

             IF (l_allocated_amount <> 0) THEN

                l_agreement_in_rec_new.amount := (l_update.amount/l_allocated_amount) * p_funding_amount;

             ELSE

                l_agreement_in_rec_new.amount := 0;

             END IF;

          ELSE

             l_agreement_in_rec_new.amount := l_update.amount;

          END IF;

          l_agreement_in_rec_new.pm_agreement_reference := l_update.pm_agreement_reference;

          IF  (nvl(l_org_id_vc, -99) <> nvl(l_update.org_id, -99)) THEN
             l_agreement_in_rec_new.owning_organization_id := null;
          ELSE
             l_agreement_in_rec_new.owning_organization_id := p_agreement_in_rec.owning_organization_id;
          END IF;

          IF (l_update.org_id is not null) THEN

 	     fnd_client_info.set_org_context(l_update.org_id);

          END IF;

	  IF (nvl(l_pa_org_id, -99) <> -1000) 		  AND
	     (l_update.org_id = nvl(l_pa_org_id, -99))      THEN



	  IF (p_pa_agreement_tbl.COUNT <> 0)			 			AND
	     (nvl(l_update.org_id, -99) = p_pa_agreement_tbl(1).object_id)		AND
	     (l_update.agreement_id <> p_pa_agreement_tbl(1).agreement_id) 		THEN

	     l_agreement_in_rec_new.agreement_num := l_agreement_in_rec_new.agreement_num || '*';

	  END IF;

          PA_AGREEMENT_PUB.update_agreement(p_api_version_number		=>	p_api_version					,
   				            p_commit				=>	OKE_API.G_FALSE					,
   				            p_init_msg_list			=>	OKE_API.G_FALSE					,
   				  	    p_msg_count				=> 	p_msg_count					,
   				   	    p_msg_data				=>	p_msg_data					,
   				            p_return_status			=>	p_return_status					,
   				   	    p_pm_product_code			=>	G_PRODUCT_CODE					,
   					    p_agreement_in_rec			=>	l_agreement_in_rec_new				,
   					    p_agreement_out_rec			=>	l_agreement_out_rec				,
   					    p_funding_in_tbl			=>	l_funding_in_tbl				,
   					    p_funding_out_tbl			=>	l_funding_out_tbl
       			                    );

          IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

              RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

          ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

              RAISE OKE_API.G_EXCEPTION_ERROR;

          END IF;

      END LOOP;

   END IF;

   IF (p_agreement_tbl.COUNT > 0) THEN

      i := p_agreement_tbl.FIRST;
      l_agreement_in_rec := p_agreement_in_rec;

      LOOP

         IF (i <> -99) THEN

            fnd_client_info.set_org_context(i);
            l_agreement_in_rec.pm_agreement_reference := i || '-N-' || p_funding_source_id;
            OPEN c_total(i);

         ELSE

            l_agreement_in_rec.pm_agreement_reference := '-N-'|| p_funding_source_id;
            OPEN c_total(null);

         END IF;

         IF  (nvl(l_org_id_vc, -99) <> nvl(i, -99)) THEN
             l_agreement_in_rec.owning_organization_id := null;
         ELSE
             l_agreement_in_rec.owning_organization_id := p_agreement_in_rec.owning_organization_id;
         END IF;

         FETCH c_total into l_amount, l_agreement_id;

         IF (c_total%NOTFOUND) THEN

            IF (l_sum_flag = 'Y') THEN

	       l_agreement_in_rec.amount := p_agreement_tbl(i).total_amount;

	    ELSE

	       l_agreement_in_rec.amount := (p_agreement_tbl(i).total_amount/p_agreement_tbl(i).org_total_amount) * p_funding_amount;

	    END IF;

	    IF (nvl(l_pa_org_id, -99) <> -1000) AND
	       (i = nvl(l_pa_org_id, -99))      THEN

	    IF (p_pa_agreement_tbl.COUNT <> 0)			 		AND
	       (i = p_pa_agreement_tbl(1).object_id)				THEN

	       l_agreement_in_rec.agreement_num := l_agreement_in_rec.agreement_num || '*';

	    END IF;

 	    l_agreement_in_rec.amount := 99999999999999999.99999;

            PA_AGREEMENT_PUB.create_agreement(p_api_version_number	=>	p_api_version				,
	  			              p_commit			=>	OKE_API.G_FALSE				,
	  			     	      p_init_msg_list		=>	OKE_API.G_FALSE				,
	  			     	      p_msg_count		=>	p_msg_count				,
	  			     	      p_msg_data		=>	p_msg_data				,
	  			     	      p_return_status		=>	p_return_status				,
	  			    	      p_pm_product_code		=>	OKE_FUNDING_PUB.G_PRODUCT_CODE		,
	  			     	      p_agreement_in_rec	=>	l_agreement_in_rec			,
	  			     	      p_agreement_out_rec	=>	l_agreement_out_rec			,
	  			     	      p_funding_in_tbl		=>	l_funding_in_tbl			,
   					      p_funding_out_tbl		=>	l_funding_out_tbl
	  			   	      );

            IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

               RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

            ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

               RAISE OKE_API.G_EXCEPTION_ERROR;

            END IF;

            l_agreement_in_rec_new              := l_agreement_in_rec;

            IF (l_sum_flag = 'Y') THEN

	       l_agreement_in_rec_new.amount := p_agreement_tbl(i).total_amount;

	    ELSE

	       l_agreement_in_rec_new.amount := (p_agreement_tbl(i).total_amount/p_agreement_tbl(i).org_total_amount) * p_funding_amount;

	    END IF;

            l_agreement_in_rec_new.agreement_id := l_agreement_out_rec.agreement_id;

         ELSE

            l_diff_amount := p_agreement_tbl(i).total_amount - l_amount;

            l_agreement_in_rec.amount 		   := l_diff_amount;
            l_agreement_in_rec.agreement_id 	   := l_agreement_id;

            retrieve_agreement(p_agreement_in_rec	=>	l_agreement_in_rec	,
            		       p_agreement_in_rec_new	=>	l_agreement_in_rec_new	,
            		       p_agreement_amount	=>	l_orig_pa_amount
            		      );

            IF (l_org_count = 1) THEN

               IF (p_agreement_tbl(i).org_total_amount <> 0) THEN

                  l_agreement_in_rec_new.amount := (p_agreement_tbl(i).total_amount/p_agreement_tbl(i).org_total_amount) * p_funding_amount;

               ELSE

                  l_agreement_in_rec_new.amount := 0;

               END IF;

            END IF;


	    l_agreement_in_rec_new.amount := 99999999999999999.99999;

            --oke_debug.debug('calling pa_agreement_pub.update_agreement from upd_insert_agreement');
            --dbms_output.put_line('calling pa_agreement_pub.update_agreement from upd_insert_agreement');

	    IF (nvl(l_pa_org_id, -99) <> -1000) 		  AND
	       (i = nvl(l_pa_org_id, -99))    			 THEN

	    IF (p_pa_agreement_tbl.COUNT <> 0)			 		AND
	       (i = p_pa_agreement_tbl(1).object_id)				THEN

	       l_agreement_in_rec_new.agreement_num := l_agreement_in_rec_new.agreement_num || '*';

	    END IF;

            PA_AGREEMENT_PUB.update_agreement(p_api_version_number		=>	p_api_version					,
   				              p_commit				=>	OKE_API.G_FALSE					,
   				              p_init_msg_list			=>	OKE_API.G_FALSE					,
   				  	      p_msg_count			=> 	p_msg_count					,
   				   	      p_msg_data			=>	p_msg_data					,
   				              p_return_status			=>	p_return_status					,
   				   	      p_pm_product_code			=>	OKE_FUNDING_PUB.G_PRODUCT_CODE			,
   					      p_agreement_in_rec		=>	l_agreement_in_rec_new				,
   					      p_agreement_out_rec		=>	l_agreement_out_rec				,
   					      p_funding_in_tbl			=>	l_funding_in_tbl				,
   					      p_funding_out_tbl			=>	l_funding_out_tbl
       			                      );

            IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

                RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

            ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

                RAISE OKE_API.G_EXCEPTION_ERROR;

            END IF;

            IF (l_org_count = 1) THEN

               IF (p_agreement_tbl(i).org_total_amount <> 0) THEN

                  l_agreement_in_rec_new.amount := (p_agreement_tbl(i).total_amount /p_agreement_tbl(i).org_total_amount) * p_funding_amount;

               ELSE

                  l_agreement_in_rec_new.amount := 0;

               END IF;

            ELSE

               l_agreement_in_rec_new.amount := p_agreement_tbl(i).total_amount;

            END IF;

         END IF;

         CLOSE c_total;

         p_agreement_out_tbl(i) := l_agreement_in_rec_new;

         EXIT WHEN (i = p_agreement_tbl.LAST);
         i := p_agreement_tbl.NEXT(i);

       END LOOP;

   END IF;

   IF (p_pa_agreement_tbl.COUNT > 0) THEN

       OPEN c_total2(p_pa_agreement_tbl(1).agreement_id);
       FETCH c_total2 INTO l_amount;
       CLOSE c_total2;

       l_agreement_in_rec	:= p_agreement_in_rec;
       l_diff_amount 		:= p_pa_agreement_tbl(1).total_amount - l_amount;

       l_agreement_in_rec.amount 		   := l_diff_amount;
       l_agreement_in_rec.agreement_id 	   	   := p_pa_agreement_tbl(1).agreement_id;

       retrieve_agreement(p_agreement_in_rec		=>	l_agreement_in_rec	,
            		  p_agreement_in_rec_new	=>	l_agreement_in_rec_new	,
            		  p_agreement_amount		=>	l_orig_pa_amount
            		 );

       l_agreement_in_rec_new.amount := 99999999999999999.99999;

       IF (p_pa_agreement_tbl(1).object_id <> -99) THEN

 	   fnd_client_info.set_org_context(p_pa_agreement_tbl(1).object_id);
 	   l_agreement_in_rec_new.pm_agreement_reference := p_pa_agreement_tbl(1).object_id ||'-Y-'|| p_funding_source_id;

       ELSE

           l_agreement_in_rec_new.pm_agreement_reference := '-Y-' || p_funding_source_id;

       END IF;

       PA_AGREEMENT_PUB.update_agreement(p_api_version_number			=>	p_api_version					,
   				         p_commit				=>	OKE_API.G_FALSE					,
   				         p_init_msg_list			=>	OKE_API.G_FALSE					,
   				         p_msg_count				=> 	p_msg_count					,
   				         p_msg_data				=>	p_msg_data					,
   				         p_return_status			=>	p_return_status					,
   				         p_pm_product_code			=>	OKE_FUNDING_PUB.G_PRODUCT_CODE			,
   				         p_agreement_in_rec			=>	l_agreement_in_rec_new				,
   				         p_agreement_out_rec			=>	l_agreement_out_rec				,
   					 p_funding_in_tbl			=>	l_funding_in_tbl				,
   					 p_funding_out_tbl			=>	l_funding_out_tbl
       			                 );

       IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

           RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

       ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

           RAISE OKE_API.G_EXCEPTION_ERROR;

       END IF;

       IF (l_org_count = 1) THEN

           IF (p_pa_agreement_tbl(1).org_total_amount <> 0) THEN

               l_agreement_in_rec_new.amount := (p_pa_agreement_tbl(1).total_amount /p_pa_agreement_tbl(1).org_total_amount) * p_funding_amount;

           ELSE

               l_agreement_in_rec_new.amount := 0;

           END IF;

        ELSE

           l_agreement_in_rec_new.amount := p_pa_agreement_tbl(1).total_amount;

        END IF;

        p_pa_agreement_out_tbl(p_pa_agreement_tbl(1).object_id) := l_agreement_in_rec_new;

   END IF;

--   fnd_client_info.set_org_context(to_number(l_org_id_vc));

   -- syho, bug 2304661
   -- update agreement flexfields
   FOR l_update in c_update_agreement(l_length) LOOP

       l_agreement_in_rec.agreement_id		 := l_update.agreement_id;
       l_agreement_in_rec.amount 		 := 0;
       l_agreement_in_rec.attribute_category 	 := p_agreement_in_rec.attribute_category;
       l_agreement_in_rec.attribute1 		 := p_agreement_in_rec.attribute1;
       l_agreement_in_rec.attribute2		 := p_agreement_in_rec.attribute2;
       l_agreement_in_rec.attribute3		 := p_agreement_in_rec.attribute3;
       l_agreement_in_rec.attribute4		 := p_agreement_in_rec.attribute4;
       l_agreement_in_rec.attribute5   		 := p_agreement_in_rec.attribute5;
       l_agreement_in_rec.attribute6		 := p_agreement_in_rec.attribute6;
       l_agreement_in_rec.attribute7		 := p_agreement_in_rec.attribute7;
       l_agreement_in_rec.attribute8		 := p_agreement_in_rec.attribute8;
       l_agreement_in_rec.attribute9		 := p_agreement_in_rec.attribute9;
       l_agreement_in_rec.attribute10		 := p_agreement_in_rec.attribute10;
       l_agreement_in_rec.pm_agreement_reference := l_update.pm_agreement_reference;

       retrieve_agreement(p_agreement_in_rec		=>	l_agreement_in_rec	,
            		  p_agreement_in_rec_new	=>	l_agreement_in_rec_new	,
            		  p_agreement_amount		=>	l_orig_pa_amount
            		 );

       IF (l_update.org_id is not null) THEN

 	  fnd_client_info.set_org_context(l_update.org_id);

       END IF;

       PA_AGREEMENT_PUB.update_agreement(p_api_version_number			=>	p_api_version					,
   				         p_commit				=>	OKE_API.G_FALSE					,
   				         p_init_msg_list			=>	OKE_API.G_FALSE					,
   				  	 p_msg_count				=> 	p_msg_count					,
   				   	 p_msg_data				=>	p_msg_data					,
   				         p_return_status			=>	p_return_status					,
   				   	 p_pm_product_code			=>	G_PRODUCT_CODE					,
   					 p_agreement_in_rec			=>	l_agreement_in_rec_new				,
   					 p_agreement_out_rec			=>	l_agreement_out_rec				,
   					 p_funding_in_tbl			=>	l_funding_in_tbl				,
   					 p_funding_out_tbl			=>	l_funding_out_tbl
       			                 );

        IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

            RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

        ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

            RAISE OKE_API.G_EXCEPTION_ERROR;

        END IF;

   END LOOP;

   fnd_client_info.set_org_context(to_number(l_org_id_vc));
   --oke_debug.debug('finished upd_insert_agreement');
   --dbms_output.put_line('finished upd_insert_agreement');

END upd_insert_agreement;
*/

--
-- Procedure: update_pa_agreement
--
-- Description: This procedure is used to agreement originally pushed from PA
--
--
/*
PROCEDURE update_pa_agreement(p_agreement_in_rec			PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE	,
   		 	      p_agreement_tbl		       		AGREEMENT_TBL_TYPE			,
   		 	      p_funding_source_id			NUMBER					,
   		 	      p_funding_amount				NUMBER					,
   		 	      p_agreement_out_tbl	OUT NOCOPY	PA_AGREEMENT_TBL_TYPE			,
   		 	      p_api_version				NUMBER					,
   		 	      p_msg_count		OUT NOCOPY	NUMBER					,
   		 	      p_msg_data		OUT NOCOPY	VARCHAR2				,
   		 	      p_return_status		OUT NOCOPY	VARCHAR2
   			      ) is

   cursor c_agreement_count (x_length NUMBER) is
     select count(1)
     from   pa_agreements_all
     where  pm_product_code = G_PRODUCT_CODE
     and    substr(pm_agreement_reference, -1 * x_length, x_length) = to_char(p_funding_source_id);

   cursor c_update_agreement (x_length NUMBER) is
     select sum(nvl(f.allocated_amount, 0)) amount, pm_agreement_reference, p.agreement_id, org_id
     from   pa_project_fundings f,
     	    pa_agreements_all p
     where  p.agreement_id = f.agreement_id
     and    p.pm_product_code = G_PRODUCT_CODE
     and    substr(pm_agreement_reference, -1 * x_length, x_length) = 'Y-' || to_char(p_funding_source_id)
     group by p.agreement_id, pm_agreement_reference, org_id;

   cursor c_allocation is
     select sum(nvl(amount, 0))
     from   oke_k_fund_allocations
     where  funding_source_id = p_funding_source_id;

   i				NUMBER;
   l_org_id_vc			VARCHAR(10);
   l_agreement_out_rec		PA_AGREEMENT_PUB.AGREEMENT_REC_OUT_TYPE;
   l_agreement_in_rec		PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE := p_agreement_in_rec;
   l_agreement_in_rec_new	PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE;
   l_funding_in_tbl		PA_AGREEMENT_PUB.FUNDING_IN_TBL_TYPE;
   l_funding_out_tbl		PA_AGREEMENT_PUB.FUNDING_OUT_TBL_TYPE;
   l_orig_pa_amount		NUMBER;
   l_agreement_count		NUMBER := 0;
   l_sum_flag			VARCHAR2(1);
   l_update			c_update_agreement%ROWTYPE;
   l_allocated_amount		NUMBER;
   l_length			NUMBER;

BEGIN

   --oke_debug.debug('entering upd_insert_agreement');
   --dbms_output.put_line('entering upd_insert_agreement');

   p_return_status  		       := OKE_API.G_RET_STS_SUCCESS;

   l_length := LENGTH(p_funding_source_id);

   OPEN c_agreement_count(l_length);
   FETCH c_agreement_count INTO l_agreement_count;
   CLOSE c_agreement_count;

   OPEN c_update_agreement(l_length + 2);
   FETCH c_update_agreement into l_update;
   IF (c_update_agreement%NOTFOUND) THEN
      return;
   END IF;
   CLOSE c_update_agreement;

   --
   -- Determine if agreement amount
   --

   IF (l_agreement_count = 1) THEN

        l_sum_flag    := 'N';

   ELSE

        l_sum_flag    := 'Y';

   END IF;

   fnd_profile.get('ORG_ID',l_org_id_vc);

   --
   -- Update existing project agreement amount if update_flag = 'Y'
   --
   IF (l_sum_flag = 'Y')          OR
      (p_agreement_tbl.COUNT > 0) THEN

          l_agreement_in_rec.amount := 0;

          l_agreement_in_rec.agreement_id := l_update.agreement_id;

          retrieve_agreement(p_agreement_in_rec		=>	l_agreement_in_rec	,
            		     p_agreement_in_rec_new	=>	l_agreement_in_rec_new	,
            		     p_agreement_amount		=>	l_orig_pa_amount
            		    );

          IF (p_agreement_tbl.COUNT = 0) THEN

  	     IF (l_sum_flag = 'Y') THEN

 		l_agreement_in_rec_new.amount := l_update.amount;

  	     END IF;

  	  ELSIF (l_sum_flag = 'Y') THEN

	    l_agreement_in_rec_new.amount := p_agreement_tbl(l_update.org_id).total_amount;

          ELSE

            IF (p_agreement_tbl(l_update.org_id).org_total_amount <> 0) THEN

	       l_agreement_in_rec_new.amount := (p_agreement_tbl(l_update.org_id).total_amount/p_agreement_tbl(l_update.org_id).org_total_amount) * p_funding_amount;

            ELSE

               l_agreement_in_rec_new.amount := 0;

            END IF;

         END IF;

          l_agreement_in_rec_new.pm_agreement_reference := l_update.pm_agreement_reference;

          IF  (nvl(l_org_id_vc, -99) <> nvl(l_update.org_id, -99)) THEN
             l_agreement_in_rec_new.owning_organization_id := null;
          END IF;

          IF (l_update.org_id is not null) THEN

 	     fnd_client_info.set_org_context(l_update.org_id);

          END IF;

          PA_AGREEMENT_PUB.update_agreement(p_api_version_number		=>	p_api_version					,
   				            p_commit				=>	OKE_API.G_FALSE					,
   				            p_init_msg_list			=>	OKE_API.G_FALSE					,
   				  	    p_msg_count				=> 	p_msg_count					,
   				   	    p_msg_data				=>	p_msg_data					,
   				            p_return_status			=>	p_return_status					,
   				   	    p_pm_product_code			=>	G_PRODUCT_CODE					,
   					    p_agreement_in_rec			=>	l_agreement_in_rec_new				,
   					    p_agreement_out_rec			=>	l_agreement_out_rec				,
   					    p_funding_in_tbl			=>	l_funding_in_tbl				,
   					    p_funding_out_tbl			=>	l_funding_out_tbl
       			                    );

          IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

              RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

          ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

              RAISE OKE_API.G_EXCEPTION_ERROR;

          END IF;

          IF (p_agreement_tbl.COUNT > 0) THEN

              IF (l_sum_flag = 'Y') THEN

                  l_agreement_in_rec_new.amount := (p_agreement_tbl(l_update.org_id).total_amount
                                                     + p_agreement_tbl(l_update.org_id).negative_amount);

              ELSE

                  l_agreement_in_rec_new.amount := ((p_agreement_tbl(l_update.org_id).total_amount
                                                     + p_agreement_tbl(l_update.org_id).negative_amount)/p_agreement_tbl(l_update.org_id).org_total_amount) * p_funding_amount;

              END IF;

          END IF;

          p_agreement_out_tbl(l_update.org_id) := l_agreement_in_rec_new;

   END IF;

   fnd_client_info.set_org_context(to_number(l_org_id_vc));

   --oke_debug.debug('finished upd_insert_agreement');
   --dbms_output.put_line('finished upd_insert_agreement');

END update_pa_agreement;
*/

--
-- Procedure: pa_update_or_add
--
-- Description: This procedure is used to check if it is an update or add to pa project funding table
--
--

PROCEDURE pa_update_or_add(p_fund_allocation_id			NUMBER		,
			   p_new_amount				NUMBER		,
   		   	   p_version		  OUT NOCOPY	NUMBER		,
   		   	   p_diff_amount	  OUT NOCOPY	NUMBER		,
   		    	   p_add_flag		  OUT NOCOPY	VARCHAR2
   		  	 ) is

   cursor c_sum (length NUMBER) is
      select sum(nvl(allocated_amount, 0)), max(project_funding_id)
      from   pa_project_fundings
      where  pm_product_code = G_PRODUCT_CODE
      and    substr(pm_funding_reference, 1, length + 1) = to_char(p_fund_allocation_id) || '.';

   cursor c_proj_funding (x_project_funding_id NUMBER) is
      select nvl(allocated_amount, 0), budget_type_code, pm_funding_reference
      from   pa_project_fundings
      where  project_funding_id = x_project_funding_id;

   l_length 			NUMBER;
   l_max_proj_funding		NUMBER := 0;
   l_sum_amount			NUMBER := 0;
   l_org_amount			NUMBER;
   l_type			VARCHAR2(30);
   l_reference			VARCHAR2(25);

BEGIN

   l_length := LENGTH(p_fund_allocation_id);

   OPEN c_sum(l_length);
   FETCH c_sum INTO l_sum_amount, l_max_proj_funding;

   IF c_sum%NOTFOUND THEN

      CLOSE c_sum;
      p_diff_amount := p_new_amount;
      p_version := 0;
      p_add_flag := 'Y';
      return;

   END IF;

   CLOSE c_sum;

   OPEN c_proj_funding(l_max_proj_funding);
   FETCH c_proj_funding INTO l_org_amount, l_type, l_reference;
   CLOSE c_proj_funding;

   p_version := to_number(substr(l_reference, l_length + 2));
   p_diff_amount := p_new_amount - l_sum_amount;

   IF l_type = 'BASELINE' THEN

      p_add_flag := 'Y';

   ELSE

      p_add_flag := 'N';
      p_diff_amount := p_diff_amount + l_org_amount;

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

      IF c_sum%ISOPEN THEN
         CLOSE c_sum;
      END IF;

      IF c_proj_funding%ISOPEN THEN
         CLOSE c_proj_funding;
      END IF;

END pa_update_or_add;


--
-- Public Procedures and Functions
--

--
-- Procedure create_agreement
--
-- Description: This procedure is used to create pa agreement
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			OKE_FUNDING_UTIL_PKG.funding_mode
--			OKE_FUNDING_UTIL_PKG.get_converted_amount
--			OKE_FUNDING_UTIL_PKG.update_source_flag
--			PA_AGREEMENT_PUB.create_agreement
--			add_pa_funding
--			validate_agreement_attributes
--			check_project_null
--			get_term_id
--			set_hard_limit
--

PROCEDURE create_agreement(p_api_version		IN		NUMBER						,
   			   p_init_msg_list		IN     		VARCHAR2 := OKE_API.G_FALSE			,
   			   p_commit			IN		VARCHAR2 := OKE_API.G_FALSE			,
   			   p_msg_count			OUT NOCOPY	NUMBER						,
   			   p_msg_data			OUT NOCOPY	VARCHAR2					,
   			   p_agreement_type		IN		VARCHAR2 					,
			   p_funding_in_rec		IN		OKE_FUNDSOURCE_PVT.FUNDING_REC_IN_TYPE		,
			 --  p_allocation_in_tbl		IN	OKE_ALLOCATION_PVT.ALLOCATION_IN_TBL_TYPE	,
			   p_return_status   		OUT NOCOPY	VARCHAR2
			  ) is

   cursor c_ou is
      select distinct
             nvl(p.org_id, -99) org_id,
             a.multi_currency_billing_flag,
             p.projfunc_currency_code
      from   oke_k_fund_allocations o,
      	     pa_projects_all p,
      	     pa_implementations_all a
      where  funding_source_id = p_funding_in_rec.funding_source_id
      and    o.project_id = p.project_id
      and    nvl(a.org_id, -99) = nvl(p.org_id, -99)
      and    o.amount <> 0
      order by 1, 2;

   cursor c_allocation(x_org_id number) is
      select p.org_id,
      	     o.pa_conversion_type,
      	     o.pa_conversion_date,
      	     o.pa_conversion_rate,
       	     o.fund_allocation_id,
       	     o.project_id,
       	     o.task_id,
       	     p.segment1 project_number,
       	     o.amount,
       	     p.multi_currency_billing_flag,
       	     p.projfunc_currency_code
      from   oke_k_fund_allocations o,
      	     pa_projects_all p
      where  funding_source_id = p_funding_in_rec.funding_source_id
      and    o.project_id = p.project_id
      and    nvl(p.org_id, -99) = x_org_id
      and    o.amount <> 0
    --  order by o.project_id, task_id;
      order by p.multi_currency_billing_flag, o.project_id, task_id;

   cursor c_allocation_p (x_project_id NUMBER) is
      select o.fund_allocation_id,
      	     o.funding_source_id,
       	     o.project_id,
       	     o.task_id,
       	     o.amount,
       	     a.agreement_id,
       	     o.start_date_active,
       	     o.funding_category
      from   oke_k_fund_allocations o,
  	     pa_projects_all p,
  	     pa_agreements_all a,
  	     pa_implementations_all i
      where  funding_source_id = p_funding_in_rec.funding_source_id
      and    o.project_id = x_project_id
      and    o.project_id = p.project_id
      and    nvl(a.org_id, -99) = nvl(p.org_id, -99)
      and    nvl(a.org_id, -99) = nvl(i.org_id, -99)
      and    a.pm_agreement_reference = p.org_id || '-' || decode(i.multi_currency_billing_flag, 'N', p.projfunc_currency_code,
                                        decode(p.multi_currency_billing_flag, 'Y', p_funding_in_rec.currency_code, p.projfunc_currency_code))
                                        || '-' || p_funding_in_rec.funding_source_id
      and    a.pm_product_code = G_PRODUCT_CODE
      and    o.amount <> 0
      order by o.project_id, o.task_id, o.amount desc;

   cursor c_allocation_t (x_project_id NUMBER) is
      select o.fund_allocation_id,
      	     o.funding_source_id,
       	     o.project_id,
       	     o.task_id,
       	     o.amount,
       	     a.agreement_id,
       	     o.start_date_active  ,
       	     o.funding_category
      from   oke_k_fund_allocations o,
  	     pa_projects_all p,
  	     pa_agreements_all a,
  	     pa_implementations_all i
      where  funding_source_id = p_funding_in_rec.funding_source_id
      and    o.project_id = p.project_id
      and    o.project_id = x_project_id
      and    nvl(a.org_id, -99) = nvl(i.org_id, -99)
      and    nvl(a.org_id, -99) = nvl(p.org_id, -99)
      and    a.pm_agreement_reference = p.org_id || '-' || decode(i.multi_currency_billing_flag, 'N', p.projfunc_currency_code,
                                        decode(p.multi_currency_billing_flag, 'Y', p_funding_in_rec.currency_code, p.projfunc_currency_code))
                                        || '-' || p_funding_in_rec.funding_source_id
      and    a.pm_product_code = G_PRODUCT_CODE
      and    o.amount <> 0
      order by o.project_id, o.task_id desc, o.amount desc;

   l_api_name				VARCHAR2(20) := 'create_agreement';
   i					NUMBER	     := 0;
   l_return_status			VARCHAR2(1);
   l_err_project_number			VARCHAR2(25);
   l_level				VARCHAR2(1);
   l_amount				NUMBER;
   l_org_id_vc   			VARCHAR(10);
   l_agreement_in_rec			PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE;
   l_agreement_out_rec			PA_AGREEMENT_PUB.AGREEMENT_REC_OUT_TYPE;
   l_funding_in_rec		        OKE_FUNDSOURCE_PVT.FUNDING_REC_IN_TYPE;
   l_funding_in_tbl			PA_AGREEMENT_PUB.FUNDING_IN_TBL_TYPE;
   l_funding_out_tbl			PA_AGREEMENT_PUB.FUNDING_OUT_TBL_TYPE;
   l_allocation_in_rec			OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE;
   --l_allocation				c_allocation%ROWTYPE;
   l_proj_sum_tbl			OKE_FUNDING_UTIL_PKG.PROJ_SUM_TBL_TYPE;
   l_task_sum_tbl			OKE_FUNDING_UTIL_PKG.TASK_SUM_TBL_TYPE;
   l_funding_level_tbl			OKE_FUNDING_UTIL_PKG.FUNDING_LEVEL_TBL_TYPE;
   l_agreement_tbl			AGREEMENT_TBL_TYPE;
   l_agreement_length                   NUMBER := 0;

BEGIN

   --oke_debug.debug('entering oke_agreement_pvt.create_agreement');
   --dbms_output.put_line('enter oke_agreement_pvt.create_agreement');

   p_return_status  		       := OKE_API.G_RET_STS_SUCCESS;

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
   -- Get the length of agreement number in table
   --
   l_agreement_length := agreement_length;

   --
   -- Check and validate for mandatory parameters
   --

   --oke_debug.debug('validating agreement_type');
   --dbms_output.put_line('validate agreement attributes');

   validate_agreement_attributes(p_funding_in_rec	=>	p_funding_in_rec	,
   			 	 p_agreement_type	=>	p_agreement_type
   			        );

   --
   -- Validate project_id is not null
   --

   --oke_debug.debug('check if null project_id exists');
   --dbms_output.put_line('check if null project_id exists');

   check_project_null(p_funding_source_id 	=>	p_funding_in_rec.funding_source_id);

   --
   -- Set the default values to be null for pa DF
   --
   l_funding_in_rec := set_default(p_funding_in_rec);

   --l_funding_in_rec := p_funding_in_rec;

   --
   -- Group by funding by OU
   --

   FOR l_ou IN c_ou LOOP
       i := i + 2;
       --
       -- Check if MCB enabled at OU
       --
       IF (l_ou.multi_currency_billing_flag = 'N') THEN

          FOR l_allocation IN c_allocation(l_ou.org_id) LOOP

              IF (l_allocation.projfunc_currency_code <> l_funding_in_rec.currency_code) THEN

                 OKE_FUNDING_UTIL_PKG.get_converted_amount(x_funding_source_id		=>	l_funding_in_rec.funding_source_id	,
			    		                   x_project_id			=>	l_allocation.project_id			,
			    		                   x_project_number		=>	l_allocation.project_number		,
			     		                   x_amount			=>	l_allocation.amount			,
			     		                   x_conversion_type		=>	l_allocation.pa_conversion_type		,
			     		                   x_conversion_date		=>	l_allocation.pa_conversion_date		,
			     		                   x_conversion_rate		=>	l_allocation.pa_conversion_rate		,
						           x_converted_amount		=>	l_amount				,
			     		                   x_return_status		=>	l_return_status
			     		                   );

                 IF (l_return_status = 'E') THEN

                    RAISE OKE_API.G_EXCEPTION_ERROR;

                 ELSIF (l_return_status = 'U') THEN

                    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

                 END IF;

              ELSE

                 l_amount := l_allocation.amount;

              END IF;

              l_agreement_tbl(i).object_id            		:= l_allocation.org_id;
              l_agreement_tbl(i).agreement_currency_code        := l_allocation.projfunc_currency_code;
              IF (l_agreement_tbl(i).total_amount = OKE_API.G_MISS_NUM) THEN
                  l_agreement_tbl(i).total_amount := 0;
              END IF;
              l_agreement_tbl(i).total_amount        		:= l_agreement_tbl(i).total_amount + l_amount;
              IF (l_agreement_tbl(i).org_total_amount = OKE_API.G_MISS_NUM) THEN
                  l_agreement_tbl(i).org_total_amount := 0;
              END IF;
              l_agreement_tbl(i).org_total_amount    	        := l_agreement_tbl(i).org_total_amount + l_allocation.amount;

              IF l_allocation.task_id is not null THEN

                 l_task_sum_tbl(l_allocation.task_id).task_id 		:= l_allocation.task_id;
                 l_task_sum_tbl(l_allocation.task_id).project_id 	:= l_allocation.project_id;
                 l_task_sum_tbl(l_allocation.task_id).amount 		:= nvl(l_task_sum_tbl(l_allocation.task_id).amount, 0) + l_allocation.amount;
                 l_task_sum_tbl(l_allocation.task_id).org_id 		:= l_allocation.org_id;
                 l_task_sum_tbl(l_allocation.task_id).project_number 	:= l_allocation.project_number;

              ELSE

                 l_proj_sum_tbl(l_allocation.project_id).project_id 	:= l_allocation.project_id;
                 l_proj_sum_tbl(l_allocation.project_id).amount 	:= nvl(l_proj_sum_tbl(l_allocation.project_id).amount, 0) + l_allocation.amount;
                 l_proj_sum_tbl(l_allocation.project_id).org_id		:= l_allocation.org_id;
                 l_proj_sum_tbl(l_allocation.project_id).project_number := l_allocation.project_number;

              END IF;

          END LOOP;

       ELSE

          FOR l_allocation IN c_allocation(l_ou.org_id) LOOP

              IF (l_allocation.multi_currency_billing_flag = 'N') 		    AND
                 (l_allocation.projfunc_currency_code <> l_funding_in_rec.currency_code) THEN

                 OKE_FUNDING_UTIL_PKG.get_converted_amount(x_funding_source_id		=>	l_funding_in_rec.funding_source_id	,
			    		                   x_project_id			=>	l_allocation.project_id			,
			    		                   x_project_number		=>	l_allocation.project_number		,
			     		                   x_amount			=>	l_allocation.amount			,
			     		                   x_conversion_type		=>	l_allocation.pa_conversion_type		,
			     		                   x_conversion_date		=>	l_allocation.pa_conversion_date		,
			     		                   x_conversion_rate		=>	l_allocation.pa_conversion_rate		,
						           x_converted_amount		=>	l_amount				,
			     		                   x_return_status		=>	l_return_status
			     		                   );

                  IF (l_return_status = 'E') THEN

                      RAISE OKE_API.G_EXCEPTION_ERROR;

                  ELSIF (l_return_status = 'U') THEN

                      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

                  END IF;

                  l_agreement_tbl(i).object_id            		:= l_allocation.org_id;
                  l_agreement_tbl(i).agreement_currency_code            := l_allocation.projfunc_currency_code;
                  IF (l_agreement_tbl(i).total_amount = OKE_API.G_MISS_NUM) THEN
                     l_agreement_tbl(i).total_amount := 0;
                  END IF;
                  l_agreement_tbl(i).total_amount         		:= l_agreement_tbl(i).total_amount + l_amount;
                  IF (l_agreement_tbl(i).org_total_amount = OKE_API.G_MISS_NUM) THEN
                     l_agreement_tbl(i).org_total_amount := 0;
                  END IF;
                  l_agreement_tbl(i).org_total_amount     		:= l_agreement_tbl(i).org_total_amount + l_allocation.amount;

                  IF l_allocation.task_id is not null THEN

                     l_task_sum_tbl(l_allocation.task_id).task_id 		:= l_allocation.task_id;
                     l_task_sum_tbl(l_allocation.task_id).project_id 		:= l_allocation.project_id;
                     l_task_sum_tbl(l_allocation.task_id).amount 		:= nvl(l_task_sum_tbl(l_allocation.task_id).amount, 0) + l_allocation.amount;
                     l_task_sum_tbl(l_allocation.task_id).org_id 		:= l_allocation.org_id;
                     l_task_sum_tbl(l_allocation.task_id).project_number 	:= l_allocation.project_number;

                  ELSE

                     l_proj_sum_tbl(l_allocation.project_id).project_id 	:= l_allocation.project_id;
                     l_proj_sum_tbl(l_allocation.project_id).amount 		:= nvl(l_proj_sum_tbl(l_allocation.project_id).amount, 0) + l_allocation.amount;
                     l_proj_sum_tbl(l_allocation.project_id).org_id		:= l_allocation.org_id;
                     l_proj_sum_tbl(l_allocation.project_id).project_number 	:= l_allocation.project_number;

                  END IF;

              ELSE

                  l_agreement_tbl(i + 1).object_id       		 := l_allocation.org_id;
                  l_agreement_tbl(i + 1).agreement_currency_code    	 := l_funding_in_rec.currency_code;
                  IF (l_agreement_tbl(i + 1).total_amount = OKE_API.G_MISS_NUM) THEN
                     l_agreement_tbl(i + 1).total_amount := 0;
                  END IF;
                  l_agreement_tbl(i + 1).total_amount     	         := l_agreement_tbl(i + 1).total_amount + l_allocation.amount;
                  IF (l_agreement_tbl(i + 1).org_total_amount = OKE_API.G_MISS_NUM) THEN
                     l_agreement_tbl(i + 1).org_total_amount := 0;
                  END IF;
                  l_agreement_tbl(i + 1).org_total_amount 		 := l_agreement_tbl(i + 1).org_total_amount + l_allocation.amount;

                  IF l_allocation.task_id is not null THEN

                     l_task_sum_tbl(l_allocation.task_id).task_id 		:= l_allocation.task_id;
                     l_task_sum_tbl(l_allocation.task_id).project_id 		:= l_allocation.project_id;
                     l_task_sum_tbl(l_allocation.task_id).amount 		:= nvl(l_task_sum_tbl(l_allocation.task_id).amount, 0) + l_allocation.amount;
                     l_task_sum_tbl(l_allocation.task_id).org_id 		:= l_allocation.org_id;
                     l_task_sum_tbl(l_allocation.task_id).project_number 	:= l_allocation.project_number;

                  ELSE

                     l_proj_sum_tbl(l_allocation.project_id).project_id 	:= l_allocation.project_id;
                     l_proj_sum_tbl(l_allocation.project_id).amount 		:= nvl(l_proj_sum_tbl(l_allocation.project_id).amount, 0) + l_allocation.amount;
                     l_proj_sum_tbl(l_allocation.project_id).org_id		:= l_allocation.org_id;
                     l_proj_sum_tbl(l_allocation.project_id).project_number 	:= l_allocation.project_number;

                  END IF;

              END IF;

          END LOOP;

       END IF;

   END LOOP;

   --
   -- Check if valid allocations exist -- bug#4322146
   --
   IF l_agreement_tbl.COUNT = 0 THEN
     OKE_API.set_message(
       p_app_name => G_APP_NAME, p_msg_name => 'OKE_FUND_NO_VALID_ALLOCATIONS'
     );
     RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;

   --
   -- Check if mixed mode exists
   --

   --oke_debug.debug('calling oke_funding_util.funding_mode');
   --dbms_output.put_line('calling oke_funding_util.funding_mode');

   OKE_FUNDING_UTIL_PKG.funding_mode(x_proj_sum_tbl		=>	l_proj_sum_tbl		,
   				     x_task_sum_tbl		=>	l_task_sum_tbl		,
   				     x_funding_level_tbl	=>	l_funding_level_tbl	,
   				     x_project_err		=>	l_err_project_number	,
   				     x_return_status		=>	l_return_status
   				    );

   IF (l_return_status = 'E') THEN

      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_FUNDING_LEVEL'	,
      			  p_token1		=>	'PROJECT'		,
      			  p_token1_value	=>	l_err_project_number
      			 );

      RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Prepare for agreement record
   --
   prepare_agreement_record(p_funding_in_rec	=>	l_funding_in_rec,
   			    p_agreement_type	=>	p_agreement_type,
   			    p_agreement_in_rec	=>	l_agreement_in_rec,
			    p_agreement_length  =>      l_agreement_length
   			   );

   --l_agreement_org_id := l_agreement_in_rec.owning_organization_id;

--   fnd_profile.get('ORG_ID',l_org_id_vc);
   l_org_id_vc := oke_utils.org_id;

   --
   -- Create agreements for each OU
   --

   IF (l_agreement_tbl.COUNT > 0) THEN

      i := l_agreement_tbl.FIRST;

      LOOP

	 l_agreement_in_rec.amount 		    := 99999999999999999.99999;
	 l_agreement_in_rec.agreement_currency_code := l_agreement_tbl(i).agreement_currency_code;
       --  l_agreement_in_rec.pm_agreement_reference  := l_agreement_tbl(i).object_id || '-' || l_agreement_tbl(i).agreement_currency_code
        --                                               || '-' || p_funding_in_rec.funding_source_id;

         --
         -- Don't populate agreement_org_id if original OU <> agreement OU
         --

         IF  (nvl(l_org_id_vc, -99) <> nvl(l_agreement_tbl(i).object_id, -99)) THEN
             l_agreement_in_rec.owning_organization_id := null;
         ELSE
             l_agreement_in_rec.owning_organization_id := l_funding_in_rec.agreement_org_id;
         END IF;

        -- l_agreement_in_rec.pm_agreement_reference := l_agreement_tbl(i).object_id || '-N-' || p_funding_in_rec.funding_source_id;

	 IF (nvl(l_agreement_tbl(i).object_id, -99) <> -99) THEN

            --fnd_client_info.set_org_context(l_agreement_tbl(i).object_id);
            mo_global.set_policy_context('S',l_agreement_tbl(i).object_id);

         END IF;

         --
         -- Truncate agreement number when necessary
         --
         format_agreement_num(p_agreement_num_out		=>	l_agreement_in_rec.agreement_num		,
         	              p_agreement_number		=>	p_funding_in_rec.agreement_number		,
         	              p_currency_code			=>	l_agreement_in_rec.agreement_currency_code	,
         	              p_org_id				=>	l_agreement_tbl(i).object_id			,
         	              p_reference_in			=>	p_funding_in_rec.funding_source_id		,
         	              p_reference			=>	l_agreement_in_rec.pm_agreement_reference       ,
			      p_agreement_length                =>      l_agreement_length
         	              );

         --oke_debug.debug('calling pa_agreement_pub.create_agreement');

         --oke_debug.debug('agreement amount '|| l_agreement_in_rec.amount);

         PA_AGREEMENT_PUB.create_agreement(p_api_version_number		=>	p_api_version			,
	  			           p_commit			=>	OKE_API.G_FALSE			,
	  			    	   p_init_msg_list		=>	OKE_API.G_FALSE			,
	  			    	   p_msg_count			=>	p_msg_count			,
	  			    	   p_msg_data			=>	p_msg_data			,
	  			    	   p_return_status		=>	p_return_status			,
	  			    	   p_pm_product_code		=>	OKE_FUNDING_PUB.G_PRODUCT_CODE	,
	  			    	   p_agreement_in_rec		=>	l_agreement_in_rec		,
	  			    	   p_agreement_out_rec		=>	l_agreement_out_rec		,
	  			    	   p_funding_in_tbl		=>	l_funding_in_tbl		,
	  			    	   p_funding_out_tbl		=>	l_funding_out_tbl
	  			   	  );

	 IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

             RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

         ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      	     RAISE OKE_API.G_EXCEPTION_ERROR;

         END IF;

         EXIT WHEN (i = l_agreement_tbl.LAST);
         i := l_agreement_tbl.NEXT(i);

      END LOOP;

   END IF;

   --
   -- Prepare for project funding records
   --

   IF (l_funding_level_tbl.COUNT > 0) THEN

       i := l_funding_level_tbl.FIRST;

       LOOP

          l_level := l_funding_level_tbl(i).funding_level;

          IF (l_level = 'P') THEN

              FOR l_allocation IN c_allocation_p (l_funding_level_tbl(i).project_id) LOOP

                  l_allocation_in_rec.fund_allocation_id	:= l_allocation.fund_allocation_id	;
                  l_allocation_in_rec.funding_source_id		:= l_allocation.funding_source_id	;
                  l_allocation_in_rec.project_id		:= l_allocation.project_id		;
                  l_allocation_in_rec.task_id			:= l_allocation.task_id			;
                  l_allocation_in_rec.agreement_id		:= l_allocation.agreement_id		;
                  l_allocation_in_rec.amount			:= l_allocation.amount			;
                  l_allocation_in_rec.start_date_active		:= l_allocation.start_date_active	;
                  l_allocation_in_rec.funding_category		:= l_allocation.funding_category	;

                  --oke_debug.debug('calling add_pa_funding - project_level');
                  --dbms_output.put_line('calling add_pa_funding - project level');

                  add_pa_funding(p_api_version			=>	p_api_version		,
                  		 p_init_msg_list		=>	OKE_API.G_FALSE		,
                  		 p_commit			=>	OKE_API.G_FALSE		,
                  		 p_msg_count			=>	p_msg_count		,
                  		 p_msg_data			=>	p_msg_data		,
                  		 p_allocation_in_rec		=>	l_allocation_in_rec	,
                  		 p_return_status		=>	p_return_status
                  		);

  		 IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		     RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   		 ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		     RAISE OKE_API.G_EXCEPTION_ERROR;

  		 END IF;

              END LOOP;

          ELSE

              FOR l_allocation IN c_allocation_t (l_funding_level_tbl(i).project_id) LOOP

                  l_allocation_in_rec.fund_allocation_id	:= l_allocation.fund_allocation_id	;
                  l_allocation_in_rec.funding_source_id		:= l_allocation.funding_source_id	;
                  l_allocation_in_rec.project_id		:= l_allocation.project_id		;
                  l_allocation_in_rec.task_id			:= l_allocation.task_id			;
                  l_allocation_in_rec.agreement_id		:= l_allocation.agreement_id		;
                  l_allocation_in_rec.amount			:= l_allocation.amount			;
                  l_allocation_in_rec.start_date_active		:= l_allocation.start_date_active	;
                  l_allocation_in_rec.funding_category		:= l_allocation.funding_category	;

                  --oke_debug.debug('calling add_pa_funding - task level');
                  --dbms_output.put_line('calling add_pa_funding - task level');

                  add_pa_funding(p_api_version			=>	p_api_version		,
                  		 p_init_msg_list		=>	OKE_API.G_FALSE		,
                  		 p_commit			=>	OKE_API.G_FALSE		,
                  		 p_msg_count			=>	p_msg_count		,
                  		 p_msg_data			=>	p_msg_data		,
                  		 p_allocation_in_rec		=>	l_allocation_in_rec	,
                  		 p_return_status		=>	p_return_status
                  		);

  		 IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		     RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   		 ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		     RAISE OKE_API.G_EXCEPTION_ERROR;

  		 END IF;

              END LOOP;

          END IF;

          EXIT WHEN (i = l_funding_level_tbl.LAST);
          i := l_funding_level_tbl.NEXT(i);

       END LOOP;

   END IF;

   --
   -- Update the agreement total to the right amount
   --

   IF (l_agreement_tbl.COUNT > 0) THEN

      i := l_agreement_tbl.FIRST;

      LOOP

         IF (l_agreement_tbl.COUNT = 1) THEN
            l_agreement_in_rec.amount 		   := (l_agreement_tbl(i).total_amount/l_agreement_tbl(i).org_total_amount) * p_funding_in_rec.amount;
         ELSE
            l_agreement_in_rec.amount 		   := l_agreement_tbl(i).total_amount;
         END IF;

         IF  (nvl(l_org_id_vc, -99) <> nvl(l_agreement_tbl(i).object_id, -99)) THEN
             l_agreement_in_rec.owning_organization_id := null;
         ELSE
             l_agreement_in_rec.owning_organization_id := l_funding_in_rec.agreement_org_id;
         END IF;
       /*
         l_agreement_in_rec.pm_agreement_reference := l_agreement_tbl(i).object_id || '-'
                                                      || l_agreement_tbl(i).agreement_currency_code || '-'
                                                      || p_funding_in_rec.funding_source_id;
*/
	 IF (nvl(l_agreement_tbl(i).object_id, -99) <> -99) THEN

            fnd_client_info.set_org_context(l_agreement_tbl(i).object_id);

         END IF;

         --
         -- Truncate agreement number when necessary
         --
         format_agreement_num(p_agreement_num_out		=>	l_agreement_in_rec.agreement_num			,
         	              p_agreement_number		=>	p_funding_in_rec.agreement_number			,
         	              p_currency_code			=>	l_agreement_tbl(i).agreement_currency_code		,
         	              p_org_id				=>	l_agreement_tbl(i).object_id				,
         	              p_reference_in			=>	p_funding_in_rec.funding_source_id			,
         	              p_reference			=>	l_agreement_in_rec.pm_agreement_reference               ,
			      p_agreement_length                =>      l_agreement_length
         	              );

         l_agreement_in_rec.agreement_currency_code := l_agreement_tbl(i).agreement_currency_code;

         --oke_debug.debug('calling pa_agreement_pub.update_agreement');
         --dbms_output.put_line('calling pa_agreement_pub.update_agreement');

         --oke_debug.debug('agreement amount '|| l_agreement_in_rec.amount);

         PA_AGREEMENT_PUB.update_agreement(p_api_version_number		=>	p_api_version			,
	  			           p_commit			=>	OKE_API.G_FALSE			,
	  			    	   p_init_msg_list		=>	OKE_API.G_FALSE			,
	  			    	   p_msg_count			=>	p_msg_count			,
	  			    	   p_msg_data			=>	p_msg_data			,
	  			    	   p_return_status		=>	p_return_status			,
	  			    	   p_pm_product_code		=>	OKE_FUNDING_PUB.G_PRODUCT_CODE	,
	  			    	   p_agreement_in_rec		=>	l_agreement_in_rec		,
	  			    	   p_agreement_out_rec		=>	l_agreement_out_rec		,
	  			    	   p_funding_in_tbl		=>	l_funding_in_tbl		,
	  			    	   p_funding_out_tbl		=>	l_funding_out_tbl
	  			   	  );

	 IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

             RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

         ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      	     RAISE OKE_API.G_EXCEPTION_ERROR;

         END IF;

         EXIT WHEN (i = l_agreement_tbl.LAST);
         i := l_agreement_tbl.NEXT(i);

      END LOOP;

   END IF;

   --fnd_client_info.set_org_context(to_number(l_org_id_vc));
   mo_global.set_policy_context('S',to_number(l_org_id_vc));

   --
   -- update agreement flag of OKE_K_FUNDING_SOURCES table
   --

   --dbms_output.put_line('calling oke_funding_util.update_source_flag');
   --oke_debug.debug('calling oke_funding_util.update_source_flag');

   OKE_FUNDING_UTIL_PKG.update_source_flag(x_funding_source_id	=>	p_funding_in_rec.funding_source_id	,
   					   x_commit		=>	OKE_API.G_FALSE
   					  );

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   --dbms_output.put_line('finished oke_agreement_pvt.create_agreement w/ ' || p_return_status);
   --oke_debug.debug('finished oke_agreement_pvt.create_agreement w/ ' || p_return_status);

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
END create_agreement;



--
-- Procedure update_agreement
--
-- Description: This procedure is used to update pa agreement
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			validate_agreement_attributes
--			check_project_null
--			prepare_upd_funding
--

PROCEDURE update_agreement(p_api_version		IN		NUMBER						,
   			   p_init_msg_list		IN      	VARCHAR2 := OKE_API.G_FALSE			,
   			   p_commit			IN		VARCHAR2 := OKE_API.G_FALSE			,
   			   p_msg_count			OUT NOCOPY	NUMBER						,
   			   p_msg_data			OUT NOCOPY	VARCHAR2					,
   			   p_agreement_type		IN		VARCHAR2					,
			   p_funding_in_rec		IN		OKE_FUNDSOURCE_PVT.FUNDING_REC_IN_TYPE		,
			--   p_allocation_in_tbl		IN	OKE_ALLOCATION_PVT.ALLOCATION_IN_TBL_TYPE		,
			   p_return_status   		OUT NOCOPY	VARCHAR2
			  ) is

   cursor c_project is
   	select f.amount,
   	       f.project_id,
   	       f.task_id,
   	       org_id,
   	       p.segment1 project_number
   	from   oke_k_fund_allocations f,
   	       pa_projects_all p
   	where  funding_source_id = p_funding_in_rec.funding_source_id
   	and    f.project_id = p.project_id
        order by p.project_id;

   cursor c_agreement is
   	select nvl(org_id, -99) org_id,
   	       agreement_id,
   	       pm_agreement_reference,
   	       agreement_num,
   	       agreement_currency_code
   	from   pa_agreements_all
   	where  pm_product_code = G_PRODUCT_CODE
        and    substr(pm_agreement_reference, -1 * (length(p_funding_in_rec.funding_source_id) + 1), length(p_funding_in_rec.funding_source_id) + 1)
               = '-' || p_funding_in_rec.funding_source_id;

   cursor c_count is
   	select count(1)
   	from   pa_agreements_all
   	where  pm_product_code = G_PRODUCT_CODE
        and    substr(pm_agreement_reference, -1 * (length(p_funding_in_rec.funding_source_id) + 1), length(p_funding_in_rec.funding_source_id) + 1)
               = '-' || p_funding_in_rec.funding_source_id;

   cursor c_agreement3 is
   	select nvl(org_id, -99) org_id,
   	       p.agreement_id,
   	       a.pm_agreement_reference,
   	       a.agreement_num,
   	       sum(p.allocated_amount) agreement_sum,
   	       a.agreement_currency_code
   	from   pa_agreements_all a,
   	       pa_project_fundings p
   	where  a.pm_product_code = G_PRODUCT_CODE
   	and    a.agreement_id = p.agreement_id
        and    substr(pm_agreement_reference, -1 * (length(p_funding_in_rec.funding_source_id) + 1), length(p_funding_in_rec.funding_source_id) + 1)
               = '-' || p_funding_in_rec.funding_source_id
        group by p.agreement_id, a.pm_agreement_reference, a.agreement_num, a.agreement_currency_code, org_id;

   cursor c_agreement2 (x_org_id	number,
   			x_currency 	varchar) is
   	select nvl(org_id, -99) org_id,
   	       agreement_id
   	from   pa_agreements_all
   	where  pm_product_code = G_PRODUCT_CODE
   	and    nvl(org_id, -99) = x_org_id
        and    pm_agreement_reference = org_id || '-' || x_currency || '-' || p_funding_in_rec.funding_source_id;

   cursor c_agreement4 is
   	select nvl(org_id, -99) org_id,
   	       agreement_id
   	from   pa_agreements_all
   	where  pm_product_code = G_PRODUCT_CODE
        and    substr(pm_agreement_reference, -1 * (length(p_funding_in_rec.funding_source_id) + 1), length(p_funding_in_rec.funding_source_id) + 1)
               =  '-' || p_funding_in_rec.funding_source_id;

   cursor c_agreement5 (x_org_id number) is
        select multi_currency_billing_flag
        from   pa_implementations_all
        where  nvl(org_id, -99) = nvl(x_org_id, -99);

   cursor c_allocation(x_project_id number) is
   	select distinct
   	       org_id				org_id,
   	       null				multi_currency_billing_flag,
   	       null				projfunc_currency_code,
   	       p.agreement_id			agreement_id,
   	       f.fund_allocation_id  ,
   	       f.funding_source_id,
   	       f.start_date_active,
   	       f.project_id,
   	       f.task_id,
   	       f.amount,
   	       f.funding_category
   	from   oke_k_fund_allocations f,
   	       pa_project_fundings p,
   	       pa_agreements_all a
   	where  funding_source_id = p_funding_in_rec.funding_source_id
   	and    f.project_id = x_project_id
   	and    nvl(insert_update_flag, 'N') = 'Y'
        and    p.pm_product_code = G_PRODUCT_CODE
        and    p.project_id = x_project_id
        and    a.agreement_id = p.agreement_id
        and    substr(pm_funding_reference, 1, length(f.fund_allocation_id) + 1) = f.fund_allocation_id || '.'
   	and    agreement_version is not null
   --	and    nvl(f.pa_flag, 'N') <> 'Y'
      --  order by f.project_id, f.task_id asc, f.amount desc;
        union
  -- cursor c_allocation3(x_project_id number) is
   	select distinct
   	       org_id				org_id,
               p.multi_currency_billing_flag	multi_currency_billing_flag,
               p.projfunc_currency_code		projfunc_currency_code,
               -99				agreement_id,
               f.fund_allocation_id,
               f.funding_source_id,
               f.start_date_active,
               f.project_id,
               f.task_id,
               f.amount,
               f.funding_category
   	from   oke_k_fund_allocations f,
   	       pa_projects_all p
   	where  funding_source_id = p_funding_in_rec.funding_source_id
   	and    f.project_id = x_project_id
   	and    nvl(insert_update_flag, 'N') = 'Y'
   	and    agreement_version is null
   	and    f.amount <> 0
   	and    f.project_id = p.project_id
   --	and    nvl(f.pa_flag, 'N') <> 'Y';
      --  order by f.project_id, f.task_id asc, f.amount desc;
        order by 8, 9 asc, 10 desc;

   cursor c_allocation2(x_project_id number) is
   	select distinct
   	       org_id					org_id,
   	       -99					agreement_id,
               p.multi_currency_billing_flag,
               p.projfunc_currency_code,
               f.fund_allocation_id,
               f.funding_source_id,
               f.project_id,
               f.task_id,
               f.start_date_active,
               f.amount,
               f.funding_category
   	from   oke_k_fund_allocations f,
   	       pa_projects_all p
   	where  funding_source_id = p_funding_in_rec.funding_source_id
   	and    f.project_id = x_project_id
   	and    p.project_id = x_project_id
   	and    nvl(insert_update_flag, 'N') = 'Y'
   	and    agreement_version is null
   	and    f.amount <> 0
   --	and    nvl(f.pa_flag, 'N') <> 'Y';
      --  order by f.project_id, f.task_id, f.amount desc;
        union
  -- cursor c_allocation2(x_project_id number) is
   	select distinct
   	       org_id					org_id,
   	       p.agreement_id,
   	       null					multi_currency_billing_flag,
   	       null					projfunc_currency_code,
   	       f.fund_allocation_id,
   	       f.funding_source_id,
   	       f.project_id,
   	       f.task_id,
   	       f.start_date_active,
   	       f.amount,
   	       f.funding_category
   	from   oke_k_fund_allocations f,
   	       pa_project_fundings p,
   	       pa_agreements_all a
   	where  funding_source_id = p_funding_in_rec.funding_source_id
   	and    f.project_id = x_project_id
   	and    nvl(insert_update_flag, 'N') = 'Y'
   	and    f.project_id = p.project_id
   	and    a.agreement_id = p.agreement_id
        and    p.pm_product_code = G_PRODUCT_CODE
        and    substr(pm_funding_reference, 1, length(f.fund_allocation_id) + 1) = fund_allocation_id || '.'
   	and    agreement_version is not null
   --	and    nvl(f.pa_flag, 'N') <> 'Y'
     --   order by f.project_id, f.task_id, f.amount desc;
        order by 7, 8 desc, 10 desc;

   cursor c_allocation_sum is
        select sum(amount)
        from   oke_k_fund_allocations
        where  funding_source_id = p_funding_in_rec.funding_source_id;

   cursor c_source is
        select nvl(funding_across_ou, 'N')
        from   oke_k_funding_sources
        where  funding_source_id = p_funding_in_rec.funding_source_id;

   cursor c_non_mcb is
        select p.segment1
        from   pa_projects_all p,
               oke_k_fund_allocations f,
               oke_k_funding_sources s
        where  p.project_id = f.project_id
        and    f.funding_source_id = p_funding_in_rec.funding_source_id
        and    f.amount <> 0
        and    f.agreement_version is null
        and    nvl(f.insert_update_flag, 'N') = 'Y'
        and    p.multi_currency_billing_flag = 'N'
        and    s.funding_source_id = p_funding_in_rec.funding_source_id
        and    s.currency_code <> p.projfunc_currency_code;

   l_api_name			VARCHAR2(20) := 'update_agreement';
   l_return_status		VARCHAR2(1);
   i 				NUMBER := 0;
   l_allocation_in_rec		OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE;
   l_agreement_in_rec		PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE;
   l_amount			NUMBER;
   l_org_id			NUMBER;
   --l_agreement_tbl		AGREEMENT_TBL_TYPE;
  -- l_orig_agreement_tbl		AGREEMENT_TBL_TYPE;
 --  l_allocation_in_tbl		OKE_ALLOCATION_PVT.ALLOCATION_IN_TBL_TYPE;
  -- l_rate			NUMBER;
   l_project_number		VARCHAR2(25);
   l_proj_sum_tbl		OKE_FUNDING_UTIL_PKG.PROJ_SUM_TBL_TYPE;
   l_task_sum_tbl		OKE_FUNDING_UTIL_PKG.TASK_SUM_TBL_TYPE;
   l_funding_level_tbl		OKE_FUNDING_UTIL_PKG.FUNDING_LEVEL_TBL_TYPE;
  -- l_pa_agreement_tbl		PA_AGREEMENT_TBL_TYPE;
   --l_orig_pa_agreement_tbl	PA_AGREEMENT_TBL_TYPE;
   l_funding_in_tbl		PA_AGREEMENT_PUB.FUNDING_IN_TBL_TYPE;
   l_funding_out_tbl		PA_AGREEMENT_PUB.FUNDING_OUT_TBL_TYPE;
   l_org_id_vc			VARCHAR(10);
   l_agreement_out_rec		PA_AGREEMENT_PUB.AGREEMENT_REC_OUT_TYPE;
   l_err_project_number		VARCHAR2(25);
   l_level			VARCHAR2(1);
   l_funding_in_rec		OKE_FUNDSOURCE_PVT.FUNDING_REC_IN_TYPE;
   l_count			NUMBER := 0;
--   l_length			NUMBER;
 --  l_funding_currency		VARCHAR2(15);
  -- l_agreement_currency		VARCHAR2(15);
  -- l_convert_flag		VARCHAR2(1) := 'Y';
   l_allocation_sum		NUMBER := 0;
   l_agreement_id		NUMBER;
   l_across_flag		VARCHAR2(1);
   l_ou_mcb			VARCHAR2(1);
   l_agreement_length           NUMBER := 0;

BEGIN

   --dbms_output.put_line('entering oke_agreement_pvt.update_agreement');
   --oke_debug.debug('entering oke_agreement_pvt.update_agreement');

   p_return_status  		       := OKE_API.G_RET_STS_SUCCESS;

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
   -- Get the agreement number length in table
   --
   l_agreement_length := agreement_length;

   --
   -- Check and validate for mandatory parameters
   --

   validate_agreement_attributes(p_funding_in_rec	=>	p_funding_in_rec	,
   				 p_agreement_type	=>	p_agreement_type
   				);
   --
   -- Validate project_id is not null
   --

   check_project_null(p_funding_source_id 	=>	p_funding_in_rec.funding_source_id);

   l_funding_in_rec := set_default(p_funding_in_rec);

   -- l_funding_in_rec := p_funding_in_rec;

   --
   -- MCB enhancements
   --

   --
   -- Validate project funding level
   --
   FOR l_project in c_project LOOP

      IF l_project.task_id is not null THEN

         l_task_sum_tbl(l_project.task_id).task_id 		:= l_project.task_id;
         l_task_sum_tbl(l_project.task_id).project_id 		:= l_project.project_id;
         l_task_sum_tbl(l_project.task_id).amount 		:= nvl(l_task_sum_tbl(l_project.task_id).amount, 0) + l_project.amount;
         l_task_sum_tbl(l_project.task_id).org_id 		:= l_project.org_id;
         l_task_sum_tbl(l_project.task_id).project_number	:= l_project.project_number;

      ELSE

         l_proj_sum_tbl(l_project.project_id).project_id 	:= l_project.project_id;
         l_proj_sum_tbl(l_project.project_id).amount		:= nvl(l_proj_sum_tbl(l_project.project_id).amount, 0) + l_project.amount;
         l_proj_sum_tbl(l_project.project_id).org_id 		:= l_project.org_id;
         l_proj_sum_tbl(l_project.project_id).project_number	:= l_project.project_number;

      END IF;

   END LOOP;

   --
   -- Check if mixed mode exists
   --

   --oke_debug.debug('calling oke_funding_util.funding_mode');
   --dbms_output.put_line('calling oke_funding_util.funding_mode');

   OKE_FUNDING_UTIL_PKG.funding_mode(x_proj_sum_tbl		=>	l_proj_sum_tbl		,
   				     x_task_sum_tbl		=>	l_task_sum_tbl		,
      				     x_funding_level_tbl	=>	l_funding_level_tbl	,
   				     x_project_err		=>	l_err_project_number	,
   				     x_return_status		=>	l_return_status
   				    );

   IF (l_return_status = 'E') THEN

      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_FUNDING_LEVEL'	,
      			  p_token1		=>	'PROJECT'		,
      			  p_token1_value	=>	l_err_project_number
      			 );

      RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Prepare for agreement records
   --
   prepare_agreement_record(p_funding_in_rec	=>	l_funding_in_rec,
   			    p_agreement_type	=>	p_agreement_type,
   			    p_agreement_in_rec	=>	l_agreement_in_rec,
			    p_agreement_length  =>      l_agreement_length
   			    );

   l_agreement_in_rec.amount := 99999999999999999.99999;

   --fnd_profile.get('ORG_ID',l_org_id_vc);
     l_org_id_vc:=oke_utils.org_id;

   --
   -- Update existing agreements
   --
   FOR l_agreement in c_agreement LOOP

       IF  (nvl(l_org_id_vc, -99) <> nvl(l_agreement.org_id, -99)) OR
           (p_funding_in_rec.agreement_org_id = OKE_API.G_MISS_NUM) THEN
           l_agreement_in_rec.owning_organization_id := null;
       ELSE
           l_agreement_in_rec.owning_organization_id := p_funding_in_rec.agreement_org_id;
       END IF;

       l_agreement_in_rec.agreement_id 		  := l_agreement.agreement_id;
       l_agreement_in_rec.pm_agreement_reference  := l_agreement.pm_agreement_reference;
       l_agreement_in_rec.agreement_num		  := l_agreement.agreement_num;
       l_agreement_in_rec.agreement_currency_code := l_agreement.agreement_currency_code;

       IF (l_agreement.org_id <> -99) THEN

 	   --fnd_client_info.set_org_context(l_agreement.org_id);
 	     mo_global.set_policy_context('S',l_agreement.org_id);

       END IF;

       PA_AGREEMENT_PUB.update_agreement(p_api_version_number			=>	p_api_version					,
   				         p_commit				=>	OKE_API.G_FALSE					,
   				         p_init_msg_list			=>	OKE_API.G_FALSE					,
   				  	 p_msg_count				=> 	p_msg_count					,
   				   	 p_msg_data				=>	p_msg_data					,
   				         p_return_status			=>	p_return_status					,
   				   	 p_pm_product_code			=>	OKE_FUNDING_PUB.G_PRODUCT_CODE			,
   					 p_agreement_in_rec			=>	l_agreement_in_rec				,
   					 p_agreement_out_rec			=>	l_agreement_out_rec				,
   					 p_funding_in_tbl			=>	l_funding_in_tbl				,
   				         p_funding_out_tbl			=>	l_funding_out_tbl
       			                );

       IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

       ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      	  RAISE OKE_API.G_EXCEPTION_ERROR;

       END IF;

   END LOOP;

--
-- Check if it is an imported agreement
--
   OPEN c_source;
   FETCH c_source into l_across_flag;
   CLOSE c_source;

   l_project_number := null;

   IF (l_across_flag = 'Y') THEN

      OPEN c_non_mcb;
      FETCH c_non_mcb into l_project_number;
      IF c_non_mcb%NOTFOUND THEN
          null;
      ELSE

          OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			      p_msg_name		=>	'OKE_NONMCB_PROJECT'	,
      			      p_token1			=>	'PROJECT'		,
      			      p_token1_value		=>	l_project_number
      			     );

          RAISE OKE_API.G_EXCEPTION_ERROR;

      END IF;
      CLOSE c_non_mcb;

   END IF;

   --
   -- Handle all the funding lines with agreement first
   --
   i := l_funding_level_tbl.FIRST;

   LOOP

       IF (l_funding_level_tbl(i).funding_level = 'P') THEN

          --
          -- Take care of the existing funding lines  - with task first
          --

          FOR l_allocation in c_allocation(l_funding_level_tbl(i).project_id) LOOP

              l_allocation_in_rec.fund_allocation_id		:= l_allocation.fund_allocation_id	;
              l_allocation_in_rec.funding_source_id		:= l_allocation.funding_source_id	;
              l_allocation_in_rec.project_id			:= l_allocation.project_id		;
              l_allocation_in_rec.task_id			:= l_allocation.task_id			;
              l_allocation_in_rec.agreement_id			:= l_allocation.agreement_id		;
              l_allocation_in_rec.amount			:= l_allocation.amount			;
              l_allocation_in_rec.start_date_active		:= l_allocation.start_date_active	;
              l_allocation_in_rec.funding_category		:= l_allocation.funding_category	;

              IF (l_allocation.agreement_id <> -99) THEN

	          update_pa_funding(p_api_version		=>	p_api_version		,
   			            p_init_msg_list		=>	OKE_API.G_FALSE		,
   			   	    p_commit			=>	OKE_API.G_FALSE		,
   			            p_msg_count			=>      p_msg_count		,
   			   	    p_msg_data			=>	p_msg_data		,
			            p_allocation_in_rec		=>	l_allocation_in_rec	,
			  	    p_return_status		=>	p_return_status
			           );

              ELSIF (l_across_flag = 'Y') THEN

                  OPEN c_agreement4;
                  FETCH c_agreement4 into l_org_id, l_agreement_id;
                  CLOSE c_agreement4;

                  l_allocation_in_rec.agreement_id := l_agreement_id;

                  add_pa_funding(p_api_version			=>	p_api_version		,
                  	         p_init_msg_list		=>	OKE_API.G_FALSE		,
                  	         p_commit			=>	OKE_API.G_FALSE		,
                  	         p_msg_count			=>	p_msg_count		,
                  	         p_msg_data			=>	p_msg_data		,
                  	         p_allocation_in_rec		=>	l_allocation_in_rec	,
                                 p_return_status		=>	p_return_status
                  	        );

                  IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	          ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		      RAISE OKE_API.G_EXCEPTION_ERROR;

  	          END IF;

              ELSIF (nvl(l_allocation.multi_currency_billing_flag, 'N') = 'Y') THEN

                  OPEN c_agreement2(x_org_id		=>	l_allocation.org_id			,
                  		    x_currency		=>	p_funding_in_rec.currency_code   	);

                  FETCH c_agreement2 into l_org_id, l_agreement_id;
                  IF c_agreement2%NOTFOUND THEN

                     --
                     -- Check MCB flag at OU
                     --
                     OPEN c_agreement5(x_org_id => l_allocation.org_id);
                     FETCH c_agreement5 into l_ou_mcb;
                     CLOSE c_agreement5;

                     IF (l_ou_mcb = 'Y') THEN

   			l_agreement_in_rec.amount := 99999999999999999.99999;

      			IF  (nvl(l_org_id_vc, -99) <> nvl(l_allocation.org_id, -99)) OR
      			    (p_funding_in_rec.agreement_org_id = OKE_API.G_MISS_NUM) THEN
           		    l_agreement_in_rec.owning_organization_id := null;
       			ELSE
          		    l_agreement_in_rec.owning_organization_id := p_funding_in_rec.agreement_org_id;
       			END IF;

      		        IF (l_allocation.org_id <> -99) THEN

 	   		   --fnd_client_info.set_org_context(l_allocation.org_id);
 	   		    mo_global.set_policy_context('S',l_allocation.org_id);

       			END IF;

                        --
         	        -- Truncate agreement number when necessary
         		--
         		format_agreement_num(p_agreement_num_out		=>	l_agreement_in_rec.agreement_num		,
         	             		     p_currency_code			=>	p_funding_in_rec.currency_code			,
         	             		     p_agreement_number			=>	p_funding_in_rec.agreement_number		,
         	             		     p_org_id				=>	l_allocation.org_id				,
         	             		     p_reference_in			=>	p_funding_in_rec.funding_source_id		,
         	             		     p_reference			=>	l_agreement_in_rec.pm_agreement_reference	,
					     p_agreement_length                 =>      l_agreement_length
         	             		    );

         	        l_agreement_in_rec.agreement_currency_code := p_funding_in_rec.currency_code;

                        PA_AGREEMENT_PUB.create_agreement(p_api_version_number		=>	p_api_version				,
	  			              		  p_commit			=>	OKE_API.G_FALSE				,
	  			     	      		  p_init_msg_list		=>	OKE_API.G_FALSE				,
	  			     	      		  p_msg_count			=>	p_msg_count				,
	  			     	      		  p_msg_data			=>	p_msg_data				,
	  			     	      		  p_return_status		=>	p_return_status				,
	  			    	      		  p_pm_product_code		=>	OKE_FUNDING_PUB.G_PRODUCT_CODE		,
	  			     	      		  p_agreement_in_rec		=>	l_agreement_in_rec			,
	  			     	     		  p_agreement_out_rec		=>	l_agreement_out_rec			,
	  			     	     		  p_funding_in_tbl		=>	l_funding_in_tbl			,
   					     		  p_funding_out_tbl		=>	l_funding_out_tbl
	  				     		 );

             	        IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		           RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	                ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		           RAISE OKE_API.G_EXCEPTION_ERROR;

  	                END IF;

	  		l_agreement_id := l_agreement_out_rec.agreement_id;

                     ELSE

                     CLOSE c_agreement2;
                     OPEN c_agreement2(x_org_id 	=>	l_allocation.org_id			,
                     		       x_currency	=>	l_allocation.projfunc_currency_code	);
                     FETCH c_agreement2 into l_org_id, l_agreement_id;
                     IF c_agreement2%NOTFOUND THEN

   			l_agreement_in_rec.amount := 99999999999999999.99999;

      			IF  (nvl(l_org_id_vc, -99) <> nvl(l_allocation.org_id, -99)) OR
      			    (p_funding_in_rec.agreement_org_id = OKE_API.G_MISS_NUM) THEN
           		    l_agreement_in_rec.owning_organization_id := null;
       			ELSE
          		    l_agreement_in_rec.owning_organization_id := p_funding_in_rec.agreement_org_id;
       			END IF;

      		        IF (l_allocation.org_id <> -99) THEN

 	   		   --fnd_client_info.set_org_context(l_allocation.org_id);
 	   		     mo_global.set_policy_context('S',l_allocation.org_id);

       			END IF;

                        --
         	        -- Truncate agreement number when necessary
         		--
         		format_agreement_num(p_agreement_num_out		=>	l_agreement_in_rec.agreement_num		,
         	             		     p_currency_code			=>	l_allocation.projfunc_currency_code		,
         	             		     p_agreement_number			=>	p_funding_in_rec.agreement_number		,
         	             		     p_org_id				=>	l_allocation.org_id				,
         	             		     p_reference_in			=>	p_funding_in_rec.funding_source_id		,
         	             		     p_reference			=>	l_agreement_in_rec.pm_agreement_reference       ,
					     p_agreement_length                 =>      l_agreement_length
         	             		    );

         	        l_agreement_in_rec.agreement_currency_code := l_allocation.projfunc_currency_code;

                        PA_AGREEMENT_PUB.create_agreement(p_api_version_number		=>	p_api_version				,
	  			              		  p_commit			=>	OKE_API.G_FALSE				,
	  			     	      		  p_init_msg_list		=>	OKE_API.G_FALSE				,
	  			     	      		  p_msg_count			=>	p_msg_count				,
	  			     	      		  p_msg_data			=>	p_msg_data				,
	  			     	      		  p_return_status		=>	p_return_status				,
	  			    	      		  p_pm_product_code		=>	OKE_FUNDING_PUB.G_PRODUCT_CODE		,
	  			     	      		  p_agreement_in_rec		=>	l_agreement_in_rec			,
	  			     	     		  p_agreement_out_rec		=>	l_agreement_out_rec			,
	  			     	     		  p_funding_in_tbl		=>	l_funding_in_tbl			,
   					     		  p_funding_out_tbl		=>	l_funding_out_tbl
	  				     		 );

             	        IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		           RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	                ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		           RAISE OKE_API.G_EXCEPTION_ERROR;

  	                END IF;

	  		l_agreement_id := l_agreement_out_rec.agreement_id;

	   	      END IF;

		    END IF;
		    END IF;
		    CLOSE c_agreement2;

		    l_allocation_in_rec.agreement_id := l_agreement_id;

                    add_pa_funding(p_api_version		=>	p_api_version		,
                  	           p_init_msg_list		=>	OKE_API.G_FALSE		,
                  	           p_commit			=>	OKE_API.G_FALSE		,
                  	           p_msg_count			=>	p_msg_count		,
                  	           p_msg_data			=>	p_msg_data		,
                  	           p_allocation_in_rec		=>	l_allocation_in_rec	,
                                   p_return_status		=>	p_return_status
                  	           );

                    IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	            ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		       RAISE OKE_API.G_EXCEPTION_ERROR;

  	            END IF;

               ELSE

                  OPEN c_agreement2(x_org_id		=>	l_allocation.org_id			,
                  		    x_currency		=>	l_allocation.projfunc_currency_code	);
                  FETCH c_agreement2 into l_org_id, l_agreement_id;
                  IF c_agreement2%NOTFOUND THEN

   		     l_agreement_in_rec.amount := 99999999999999999.99999;

      		     IF  (nvl(l_org_id_vc, -99) <> nvl(l_allocation.org_id, -99)) OR
      		         (p_funding_in_rec.agreement_org_id = OKE_API.G_MISS_NUM) THEN
           		 l_agreement_in_rec.owning_organization_id := null;
       		     ELSE
          		 l_agreement_in_rec.owning_organization_id := p_funding_in_rec.agreement_org_id;
       	             END IF;

      		     IF (l_allocation.org_id <> -99) THEN

 	   		 -- fnd_client_info.set_org_context(l_allocation.org_id);
 	   		     mo_global.set_policy_context('S',l_allocation.org_id);

       	             END IF;

                     --
                     -- Truncate agreement number when necessary
                     --
                     format_agreement_num(p_agreement_num_out			=>	l_agreement_in_rec.agreement_num		,
         	                          p_currency_code			=>	l_allocation.projfunc_currency_code		,
         	                          p_agreement_number			=>	p_funding_in_rec.agreement_number		,
         	                          p_org_id				=>	l_allocation.org_id				,
         	                          p_reference_in			=>	p_funding_in_rec.funding_source_id		,
         	                          p_reference				=>	l_agreement_in_rec.pm_agreement_reference       ,
					  p_agreement_length                    =>      l_agreement_length
         	                         );

         	     l_agreement_in_rec.agreement_currency_code := l_allocation.projfunc_currency_code;

                     PA_AGREEMENT_PUB.create_agreement(p_api_version_number		=>	p_api_version				,
	  			              	       p_commit				=>	OKE_API.G_FALSE				,
	  			     	      	       p_init_msg_list			=>	OKE_API.G_FALSE				,
	  			     	      	       p_msg_count			=>	p_msg_count				,
	  			     	      	       p_msg_data			=>	p_msg_data				,
	  			     	      	       p_return_status			=>	p_return_status				,
	  			    	      	       p_pm_product_code		=>	OKE_FUNDING_PUB.G_PRODUCT_CODE		,
	  			     	      	       p_agreement_in_rec		=>	l_agreement_in_rec			,
	  			     	     	       p_agreement_out_rec		=>	l_agreement_out_rec			,
	  			     	     	       p_funding_in_tbl			=>	l_funding_in_tbl			,
   					     	       p_funding_out_tbl		=>	l_funding_out_tbl
	  				     	     );

             	     IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		         RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	             ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		         RAISE OKE_API.G_EXCEPTION_ERROR;

  	             END IF;

	  	     l_agreement_id := l_agreement_out_rec.agreement_id;

		  END IF;
		  CLOSE c_agreement2;

		  l_allocation_in_rec.agreement_id := l_agreement_id;

                  add_pa_funding(p_api_version		=>	p_api_version		,
                  	         p_init_msg_list	=>	OKE_API.G_FALSE		,
                  	         p_commit		=>	OKE_API.G_FALSE		,
                  	         p_msg_count		=>	p_msg_count		,
                  	         p_msg_data		=>	p_msg_data		,
                  	         p_allocation_in_rec	=>	l_allocation_in_rec	,
                                 p_return_status	=>	p_return_status
                  	         );

             	  IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	          ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		      RAISE OKE_API.G_EXCEPTION_ERROR;

  	          END IF;

               END IF;

          END LOOP;

       ELSE

          FOR l_allocation in c_allocation2(l_funding_level_tbl(i).project_id) LOOP

              l_allocation_in_rec.fund_allocation_id		:= l_allocation.fund_allocation_id	;
              l_allocation_in_rec.funding_source_id		:= l_allocation.funding_source_id	;
              l_allocation_in_rec.project_id			:= l_allocation.project_id		;
              l_allocation_in_rec.task_id			:= l_allocation.task_id			;
              l_allocation_in_rec.agreement_id			:= l_allocation.agreement_id		;
              l_allocation_in_rec.amount			:= l_allocation.amount			;
              l_allocation_in_rec.start_date_active		:= l_allocation.start_date_active	;
              l_allocation_in_rec.funding_category		:= l_allocation.funding_category	;

              IF (l_allocation.agreement_id <> -99) THEN

	          update_pa_funding(p_api_version		=>	p_api_version		,
   			            p_init_msg_list		=>	OKE_API.G_FALSE		,
   			   	    p_commit			=>	OKE_API.G_FALSE		,
   			            p_msg_count			=>      p_msg_count		,
   			   	    p_msg_data			=>	p_msg_data		,
			            p_allocation_in_rec		=>	l_allocation_in_rec	,
			  	    p_return_status		=>	p_return_status
			           );

                  IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		     RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	          ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		     RAISE OKE_API.G_EXCEPTION_ERROR;

  	          END IF;

              ELSIF (l_across_flag = 'Y') THEN

                  OPEN c_agreement4;
                  FETCH c_agreement4 into l_org_id, l_agreement_id;
                  CLOSE c_agreement4;

                  l_allocation_in_rec.agreement_id := l_agreement_id;

                  add_pa_funding(p_api_version			=>	p_api_version		,
                  	         p_init_msg_list		=>	OKE_API.G_FALSE		,
                  	         p_commit			=>	OKE_API.G_FALSE		,
                  	         p_msg_count			=>	p_msg_count		,
                  	         p_msg_data			=>	p_msg_data		,
                  	         p_allocation_in_rec		=>	l_allocation_in_rec	,
                                 p_return_status		=>	p_return_status
                  	        );

                  IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	          ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		      RAISE OKE_API.G_EXCEPTION_ERROR;

  	          END IF;

              ELSIF (nvl(l_allocation.multi_currency_billing_flag, 'N') = 'Y') THEN

                  OPEN c_agreement2(x_org_id		=>	l_allocation.org_id			,
                  		    x_currency		=>	p_funding_in_rec.currency_code   	);
                  FETCH c_agreement2 into l_org_id, l_agreement_id;
                  IF c_agreement2%NOTFOUND THEN

                     --
                     -- Check MCB flag at OU
                     --
                     OPEN c_agreement5(x_org_id => l_allocation.org_id);
                     FETCH c_agreement5 into l_ou_mcb;
                     CLOSE c_agreement5;

                     IF (l_ou_mcb = 'Y') THEN

   			l_agreement_in_rec.amount := 99999999999999999.99999;

      			IF  (nvl(l_org_id_vc, -99) <> nvl(l_allocation.org_id, -99)) OR
      			    (p_funding_in_rec.agreement_org_id = OKE_API.G_MISS_NUM) THEN
           		    l_agreement_in_rec.owning_organization_id := null;
       			ELSE
          		    l_agreement_in_rec.owning_organization_id := p_funding_in_rec.agreement_org_id;
       			END IF;

      		        IF (l_allocation.org_id <> -99) THEN

 	   		   --fnd_client_info.set_org_context(l_allocation.org_id);
 	   		     mo_global.set_policy_context('S',l_allocation.org_id);

       			END IF;

                        --
         	        -- Truncate agreement number when necessary
         		--
         		format_agreement_num(p_agreement_num_out		=>	l_agreement_in_rec.agreement_num		,
         	             		     p_currency_code			=>	p_funding_in_rec.currency_code			,
         	             		     p_agreement_number			=>	p_funding_in_rec.agreement_number		,
         	             		     p_org_id				=>	l_allocation.org_id				,
         	             		     p_reference_in			=>	p_funding_in_rec.funding_source_id		,
         	             		     p_reference			=>	l_agreement_in_rec.pm_agreement_reference       ,
					     p_agreement_length                 =>      l_agreement_length
         	             		    );

         	        l_agreement_in_rec.agreement_currency_code := p_funding_in_rec.currency_code;

                        PA_AGREEMENT_PUB.create_agreement(p_api_version_number		=>	p_api_version				,
	  			              		  p_commit			=>	OKE_API.G_FALSE				,
	  			     	      		  p_init_msg_list		=>	OKE_API.G_FALSE				,
	  			     	      		  p_msg_count			=>	p_msg_count				,
	  			     	      		  p_msg_data			=>	p_msg_data				,
	  			     	      		  p_return_status		=>	p_return_status				,
	  			    	      		  p_pm_product_code		=>	OKE_FUNDING_PUB.G_PRODUCT_CODE		,
	  			     	      		  p_agreement_in_rec		=>	l_agreement_in_rec			,
	  			     	     		  p_agreement_out_rec		=>	l_agreement_out_rec			,
	  			     	     		  p_funding_in_tbl		=>	l_funding_in_tbl			,
   					     		  p_funding_out_tbl		=>	l_funding_out_tbl
	  				     		 );

             	        IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		           RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	                ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		           RAISE OKE_API.G_EXCEPTION_ERROR;

  	                END IF;

	  		l_agreement_id := l_agreement_out_rec.agreement_id;

	             ELSE

                     CLOSE c_agreement2;
                     OPEN c_agreement2(x_org_id 	=>	l_allocation.org_id			,
                     		       x_currency	=>	l_allocation.projfunc_currency_code	);
                     FETCH c_agreement2 into l_org_id, l_agreement_id;
                     IF c_agreement2%NOTFOUND THEN

   			l_agreement_in_rec.amount := 99999999999999999.99999;

      			IF  (nvl(l_org_id_vc, -99) <> nvl(l_allocation.org_id, -99)) OR
      			    (p_funding_in_rec.agreement_org_id = OKE_API.G_MISS_NUM) THEN
           		    l_agreement_in_rec.owning_organization_id := null;
       			ELSE
          		    l_agreement_in_rec.owning_organization_id := p_funding_in_rec.agreement_org_id;
       			END IF;

      		        IF (l_allocation.org_id <> -99) THEN

 	   		   --fnd_client_info.set_org_context(l_allocation.org_id);
 	   		     mo_global.set_policy_context('S',l_allocation.org_id);

       			END IF;

                        --
                        -- Truncate agreement number when necessary
                        --
                        format_agreement_num(p_agreement_num_out		=>	l_agreement_in_rec.agreement_num		,
         	                             p_currency_code			=>	l_allocation.projfunc_currency_code		,
         	                             p_agreement_number			=>	p_funding_in_rec.agreement_number		,
         	                             p_org_id				=>	l_allocation.org_id				,
         	                             p_reference_in			=>	p_funding_in_rec.funding_source_id		,
         	                             p_reference			=>	l_agreement_in_rec.pm_agreement_reference       ,
					     p_agreement_length                 =>      l_agreement_length
         	                            );

         	        l_agreement_in_rec.agreement_currency_code := l_allocation.projfunc_currency_code;

                        PA_AGREEMENT_PUB.create_agreement(p_api_version_number		=>	p_api_version				,
	  			              		  p_commit			=>	OKE_API.G_FALSE				,
	  			     	      		  p_init_msg_list		=>	OKE_API.G_FALSE				,
	  			     	      		  p_msg_count			=>	p_msg_count				,
	  			     	      		  p_msg_data			=>	p_msg_data				,
	  			     	      		  p_return_status		=>	p_return_status				,
	  			    	      		  p_pm_product_code		=>	OKE_FUNDING_PUB.G_PRODUCT_CODE		,
	  			     	      		  p_agreement_in_rec		=>	l_agreement_in_rec			,
	  			     	     		  p_agreement_out_rec		=>	l_agreement_out_rec			,
	  			     	     		  p_funding_in_tbl		=>	l_funding_in_tbl			,
   					     		  p_funding_out_tbl		=>	l_funding_out_tbl
	  				     		 );

             	        IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		           RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	                ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		           RAISE OKE_API.G_EXCEPTION_ERROR;

  	                END IF;

	  		l_agreement_id := l_agreement_out_rec.agreement_id;

		     END IF;

		 END IF;
		 END IF;
		 CLOSE c_agreement2;

		 l_allocation_in_rec.agreement_id := l_agreement_id;

                 add_pa_funding(p_api_version			=>	p_api_version		,
                  	        p_init_msg_list			=>	OKE_API.G_FALSE		,
                  	        p_commit			=>	OKE_API.G_FALSE		,
                  	        p_msg_count			=>	p_msg_count		,
                  	        p_msg_data			=>	p_msg_data		,
                  	        p_allocation_in_rec		=>	l_allocation_in_rec	,
                                p_return_status			=>	p_return_status
                  	       );

                 IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		     RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	         ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		     RAISE OKE_API.G_EXCEPTION_ERROR;

  	         END IF;

  	     ELSE

                  OPEN c_agreement2(x_org_id		=>	l_allocation.org_id			,
                  		    x_currency		=>	l_allocation.projfunc_currency_code	);
                  FETCH c_agreement2 into l_org_id, l_agreement_id;
                  IF c_agreement2%NOTFOUND THEN

   		     l_agreement_in_rec.amount := 99999999999999999.99999;

      		     IF  (nvl(l_org_id_vc, -99) <> nvl(l_allocation.org_id, -99)) OR
      		         (p_funding_in_rec.agreement_org_id = OKE_API.G_MISS_NUM) THEN
           		 l_agreement_in_rec.owning_organization_id := null;
       		     ELSE
          		 l_agreement_in_rec.owning_organization_id := p_funding_in_rec.agreement_org_id;
       	             END IF;

      		     IF (l_allocation.org_id <> -99) THEN

 	   		 -- fnd_client_info.set_org_context(l_allocation.org_id);
 	   		    mo_global.set_policy_context('S',l_allocation.org_id);

       	             END IF;

                     --
                     -- Truncate agreement number when necessary
                     --
                     format_agreement_num(p_agreement_num_out		=>	l_agreement_in_rec.agreement_num		,
         	                          p_currency_code		=>	l_allocation.projfunc_currency_code		,
         	                          p_agreement_number		=>	p_funding_in_rec.agreement_number		,
         	                          p_org_id			=>	l_allocation.org_id				,
         	                          p_reference_in		=>	p_funding_in_rec.funding_source_id		,
         	                          p_reference			=>	l_agreement_in_rec.pm_agreement_reference       ,
					  p_agreement_length            =>      l_agreement_length
         	                          );

         	     l_agreement_in_rec.agreement_currency_code := l_allocation.projfunc_currency_code;

                     PA_AGREEMENT_PUB.create_agreement(p_api_version_number		=>	p_api_version				,
	  			              	       p_commit				=>	OKE_API.G_FALSE				,
	  			     	      	       p_init_msg_list			=>	OKE_API.G_FALSE				,
	  			     	      	       p_msg_count			=>	p_msg_count				,
	  			     	      	       p_msg_data			=>	p_msg_data				,
	  			     	      	       p_return_status			=>	p_return_status				,
	  			    	      	       p_pm_product_code		=>	OKE_FUNDING_PUB.G_PRODUCT_CODE		,
	  			     	      	       p_agreement_in_rec		=>	l_agreement_in_rec			,
	  			     	     	       p_agreement_out_rec		=>	l_agreement_out_rec			,
	  			     	     	       p_funding_in_tbl			=>	l_funding_in_tbl			,
   					     	       p_funding_out_tbl		=>	l_funding_out_tbl
	  				     	     );

             	     IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		         RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	             ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		         RAISE OKE_API.G_EXCEPTION_ERROR;

  	             END IF;

	  	     l_agreement_id := l_agreement_out_rec.agreement_id;

		     END IF;
		     CLOSE c_agreement2;

		     l_allocation_in_rec.agreement_id := l_agreement_id;

                     add_pa_funding(p_api_version		=>	p_api_version		,
                  	            p_init_msg_list		=>	OKE_API.G_FALSE		,
                  	            p_commit			=>	OKE_API.G_FALSE		,
                  	            p_msg_count			=>	p_msg_count		,
                  	            p_msg_data			=>	p_msg_data		,
                  	            p_allocation_in_rec		=>	l_allocation_in_rec	,
                                    p_return_status		=>	p_return_status
                  	            );

             	     IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

     		         RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   	             ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      		         RAISE OKE_API.G_EXCEPTION_ERROR;

  	             END IF;

  	     END IF;

          END LOOP;

       END IF;

       EXIT WHEN (i = l_funding_level_tbl.LAST);
       i := l_funding_level_tbl.NEXT(i);

   END LOOP;

   --
   -- Update the agreement amount
   --
   OPEN c_count;
   FETCH c_count into l_count;
   CLOSE c_count;

   FOR l_agreement in c_agreement3 LOOP

       IF  (nvl(l_org_id_vc, -99) <> nvl(l_agreement.org_id, -99))  OR
           (p_funding_in_rec.agreement_org_id = OKE_API.G_MISS_NUM) THEN
           l_agreement_in_rec.owning_organization_id := null;
       ELSE
           l_agreement_in_rec.owning_organization_id := p_funding_in_rec.agreement_org_id;
       END IF;

       IF (l_agreement.org_id <> -99) THEN

 	   -- fnd_client_info.set_org_context(l_agreement.org_id);
 	      mo_global.set_policy_context('S',l_agreement.org_id);

       END IF;

       l_agreement_in_rec.pm_agreement_reference  := l_agreement.pm_agreement_reference;
       l_agreement_in_rec.agreement_num		  := l_agreement.agreement_num;
       l_agreement_in_rec.agreement_id		  := l_agreement.agreement_id;
       l_agreement_in_rec.agreement_currency_code := l_agreement.agreement_currency_code;

       IF l_count = 1 THEN

          OPEN c_allocation_sum;
          FETCH c_allocation_sum into l_allocation_sum;
          CLOSE c_allocation_sum;

          -- Bug 2996654, fix the divisor as zero issue
          IF l_allocation_sum = 0 THEN
             l_agreement_in_rec.amount := 0;
          ELSE
             l_agreement_in_rec.amount := (l_agreement.agreement_sum/l_allocation_sum)* p_funding_in_rec.amount;
          END IF;
          -- Bug 2996654, end

       ELSIF l_count > 1 THEN

          l_agreement_in_rec.amount := l_agreement.agreement_sum;

       END IF;

       PA_AGREEMENT_PUB.update_agreement(p_api_version_number			=>	p_api_version					,
   				         p_commit				=>	OKE_API.G_FALSE					,
   				         p_init_msg_list			=>	OKE_API.G_FALSE					,
   				  	 p_msg_count				=> 	p_msg_count					,
   				   	 p_msg_data				=>	p_msg_data					,
   				         p_return_status			=>	p_return_status					,
   				   	 p_pm_product_code			=>	OKE_FUNDING_PUB.G_PRODUCT_CODE			,
   					 p_agreement_in_rec			=>	l_agreement_in_rec				,
   					 p_agreement_out_rec			=>	l_agreement_out_rec				,
   					 p_funding_in_tbl			=>	l_funding_in_tbl				,
   				         p_funding_out_tbl			=>	l_funding_out_tbl
       			                );

        IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

             RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

        ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

      	     RAISE OKE_API.G_EXCEPTION_ERROR;

        END IF;

   END LOOP;

   -- fnd_client_info.set_org_context(l_org_id_vc);
      mo_global.set_policy_context('S',l_org_id_vc);

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   --dbms_output.put_line('finished oke_agreement_pvt.update_agreement w/ ' || p_return_status);
   --oke_debug.debug('finished oke_agreement_pvt.update_agreement w/ ' || p_return_status);

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
END update_agreement;



--
-- Procedure: update_pa_funding
--
-- Description: This procedure is used to update record in pa project funding table
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			PA_AGREEMENT_PUB.update_funding
--			PA_AGREEMENT_PUB.add_funding
--			OKE_FUNDING_UTIL_PKG.get_converted_amount
--			OKE_FUNDING_UTIL_PKG.update_alloc_version
--			validate_line_attributes
--			pa_update_or_add
--			get_proj_funding
--

PROCEDURE update_pa_funding(p_api_version		IN		NUMBER						,
   			    p_init_msg_list		IN      	VARCHAR2 := OKE_API.G_FALSE			,
   			    p_commit			IN		VARCHAR2 := OKE_API.G_FALSE			,
   			    p_msg_count			OUT NOCOPY	NUMBER						,
   			    p_msg_data			OUT NOCOPY	VARCHAR2					,
			    p_allocation_in_rec		IN		OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE	,
			    p_return_status		OUT NOCOPY      VARCHAR2
			   ) is

   cursor c_allocation is
     select pa_conversion_rate,
            pa_conversion_type,
            pa_conversion_date,
            p.org_id,
            p.segment1 project_number--,
           -- pa_flag
     from   oke_k_fund_allocations f,
            pa_projects_all p
     where  fund_allocation_id = p_allocation_in_rec.fund_allocation_id
     and    f.project_id = p.project_id;

   cursor c_pa is
     select a.agreement_currency_code,
            nvl(a.org_id, -99),
            s.currency_code
     from   oke_k_fund_allocations o,
            pa_agreements_all a,
            --pa_projects_all p,
            oke_k_funding_sources s
           -- pa_implementations_all i
     where  a.agreement_id = p_allocation_in_rec.agreement_id
    -- and    nvl(i.org_id, -99) = nvl(a.org_id, -99)
     and    s.funding_source_id = o.funding_source_id
    -- and    o.project_id = p.project_id
     and    o.fund_allocation_id = p_allocation_in_rec.fund_allocation_id;
     --and    a.pm_product_code = G_PRODUCT_CODE
     --and    substr(a.pm_funding_reference, 1, x_length + 1) = to_char(p_allocation_in_rec.fund_allocation_id) || '.';
/*
   cursor c_pa (x_length number) is
     select --p.multi_currency_billing_flag,
            a.agreement_currency_code,
            --p.projfunc_currency_code,
            nvl(a.org_id, -99),
            i.multi_currency_billing_flag
     from   oke_k_fund_allocations o,
            pa_agreements_all a,
            pa_projects_all p,
            oke_k_funding_sources s,
            pa_implementations_all i
     where  a.agreement_id = p_allocation_in_rec.agreement_id
     and    nvl(i.org_id, -99) = nvl(a.org_id, -99)
     and    s.funding_source_id = o.funding_source_id
     and    o.project_id = p.project_id
     and    o.fund_allocation_id = p_allocation_in_rec.fund_allocation_id
     and    a.pm_product_code = G_PRODUCT_CODE
     and    substr(a.pm_funding_reference, 1, x_length + 1) = to_char(p_allocation_in_rec.fund_allocation_id) || '.';

   cursor c_project_funding (length number) is
     select *
     from   pa_project_fundings
     where  agreement_id = p_allocation_in_rec.agreement_id
     and    substr(pm_funding_reference, 1, length + 1) = to_char(p_allocation_in_rec.fund_allocation_id) || '.'
     and    pm_product_code = G_PRODUCT_CODE;
*/
   l_allocation				c_allocation%ROWTYPE;
   l_api_name				VARCHAR2(20) := 'update_pa_funding';
   l_return_status			VARCHAR2(1);
   l_amount				NUMBER;
   l_funding_id				NUMBER;
   l_diff_amount			NUMBER;
   l_project_funding			PA_PROJECT_FUNDINGS%ROWTYPE;
   l_version				NUMBER;
   l_add_flag				VARCHAR2(1);
   l_org_id_vc				VARCHAR(10);
   l_org_id_n				NUMBER;
  -- l_length				NUMBER;
  -- l_convert_flag			VARCHAR2(1) := 'Y';
   l_source_currency			VARCHAR2(15);
   l_agreement_currency			VARCHAR2(15);
   l_allocation_in_rec			OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE;

BEGIN

   --dbms_output.put_line('entering oke_agreement_pvt.update_pa_funding');
   --oke_debug.debug('entering oke_agreement_pvt.update_pa_funding');

   p_return_status  		       := OKE_API.G_RET_STS_SUCCESS;

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
   -- Check and validate for mandatory parameters
   --

   validate_line_attributes(p_allocation_in_rec	=>	p_allocation_in_rec);

   --
   -- Calculate the allocated amount
   --

   OPEN c_allocation;
   FETCH c_allocation INTO l_allocation;
   CLOSE c_allocation;

   --
   -- Check if this is a line originally from PA
   --
  -- IF (nvl(l_allocation.pa_flag, 'N') = 'Y') THEN

     -- l_length := LENGTH(p_allocation_in_rec.fund_allocation_id);

      --OPEN c_pa(l_length);
      OPEN c_pa;
     -- FETCH c_pa into l_mcb_flag, l_agreement_currency, l_projfunc_currency, l_source_currency, l_org_id_n, l_ou_mcb_flag;
      FETCH c_pa into l_agreement_currency, l_org_id_n, l_source_currency;
      CLOSE c_pa;
   /*
      IF (l_funding_currency = l_agreement_currency) THEN
         l_convert_flag := 'N';
         l_amount := p_allocation_in_rec.amount;
      END IF;
  */
 --  END IF;

 --  IF (l_convert_flag = 'Y') THEN

     IF (l_agreement_currency <> l_source_currency) THEN

         OKE_FUNDING_UTIL_PKG.get_converted_amount(x_funding_source_id	=>	p_allocation_in_rec.funding_source_id		,
			    		           x_project_id		=>	p_allocation_in_rec.project_id			,
			    		           x_project_number	=>	l_allocation.project_number			,
			     		           x_amount		=>	p_allocation_in_rec.amount			,
			     		           x_conversion_type	=>	l_allocation.pa_conversion_type			,
			     		           x_conversion_date	=>	l_allocation.pa_conversion_date			,
			     		           x_conversion_rate	=>	l_allocation.pa_conversion_rate			,
					           x_converted_amount	=>	l_amount					,
			     		           x_return_status	=>	l_return_status
			     		          );

         IF (l_return_status = 'E') THEN

            RAISE OKE_API.G_EXCEPTION_ERROR;

         ELSIF (l_return_status = 'U') THEN

            RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

         END IF;

      ELSE

         l_amount := p_allocation_in_rec.amount;

      END IF;

   --
   -- Check if project funding line status and amount
   --

   --dbms_output.put_line('calling pa_update_or_add');
   --oke_debug.debug('calling pa_update_or_add');

   pa_update_or_add(p_fund_allocation_id	=>	p_allocation_in_rec.fund_allocation_id	,
   		    p_new_amount		=>	l_amount				,
   		    p_version			=>	l_version				,
   		    p_diff_amount		=>	l_diff_amount				,
   		    p_add_flag			=>	l_add_flag
   		   );

   --
   -- Populate the values
   --
   l_allocation_in_rec := populate_values(p_allocation_in_rec);

   --
   -- Set the enviornment variables
   --

   --fnd_profile.get('ORG_ID',l_org_id_vc);
     l_org_id_vc := oke_utils.org_id;

   --l_org_id_n := get_agreement_org(p_agreement_id 	=> 	p_allocation_in_rec.agreement_id);

   if (nvl(l_org_id_n, -99) <> -99) then

      -- fnd_client_info.set_org_context(l_org_id_n);
         mo_global.set_policy_context('S',l_org_id_n);

   end if;
 /*
   IF (l_ou_mcb_flag <> 'Y') OR
      (l_mcb_flag <> 'Y')    THEN

         l_allocation_in_rec.pa_conversion_type := null;
         l_allocation_in_rec.pa_conversion_rate := null;
         l_allocation_in_rec.pa_conversion_date := null;

   END IF;
  */

   IF (l_agreement_currency <> l_source_currency) THEN

      l_allocation_in_rec.pa_conversion_type := null;
      l_allocation_in_rec.pa_conversion_rate := null;
      l_allocation_in_rec.pa_conversion_date := null;

   ELSE

      l_allocation_in_rec.pa_conversion_type := l_allocation.pa_conversion_type;
      l_allocation_in_rec.pa_conversion_rate := l_allocation.pa_conversion_rate;
      l_allocation_in_rec.pa_conversion_date := l_allocation.pa_conversion_date;

   END IF;

   IF (l_add_flag = 'Y') THEN				--  AND
      --(nvl(l_version, 0) <> 0 or p_allocation_in_rec.amount <> 0) THEN

    IF l_diff_amount<>0 THEN
      --dbms_output.put_line('calling pa_agreement_pub.add_funding from oke_agreement_pvt');
      --oke_debug.debug('calling pa_agreement_pub.add_funding from oke_agreement_pvt');

      PA_AGREEMENT_PUB.add_funding(p_api_version_number		=>	p_api_version										,
   				   p_commit			=>	OKE_API.G_FALSE										,
   				   p_init_msg_list		=>	OKE_API.G_FALSE										,
   				   p_msg_count			=> 	p_msg_count										,
   				   p_msg_data			=>	p_msg_data										,
   				   p_return_status		=>	p_return_status										,
   				   p_pm_product_code		=>	OKE_FUNDING_PUB.G_PRODUCT_CODE								,
   				   p_pm_funding_reference	=>	to_char(l_allocation_in_rec.fund_allocation_id) || '.' || to_char(l_version + 1)	,
   				   p_funding_id			=>	l_funding_id										,
   				   p_pa_project_id		=>	l_allocation_in_rec.project_id								,
   				   p_pa_task_id			=>	l_allocation_in_rec.task_id								,
   				   p_agreement_id		=>	l_allocation_in_rec.agreement_id							,
   				   p_allocated_amount		=>	l_diff_amount										,
   				   p_date_allocated		=>	l_allocation_in_rec.start_date_active							,
   				   p_desc_flex_name		=>	G_PROJ_FUND_DESC_FLEX_NAME								,
   				   p_attribute_category		=>	l_allocation_in_rec.pa_attribute_category						,
   				   p_attribute1			=>	l_allocation_in_rec.pa_attribute1							,
   				   p_attribute2			=>	l_allocation_in_rec.pa_attribute2							,
   				   p_attribute3			=>	l_allocation_in_rec.pa_attribute3							,
   				   p_attribute4			=>	l_allocation_in_rec.pa_attribute4							,
   				   p_attribute5			=>	l_allocation_in_rec.pa_attribute5							,
   				   p_attribute6			=>	l_allocation_in_rec.pa_attribute6							,
   				   p_attribute7			=>	l_allocation_in_rec.pa_attribute7							,
   				   p_attribute8			=>	l_allocation_in_rec.pa_attribute8							,
   				   p_attribute9			=>	l_allocation_in_rec.pa_attribute9							,
   				   p_attribute10		=>	l_allocation_in_rec.pa_attribute10							,
       			           p_funding_id_out		=>	l_funding_id										,
       			           p_project_rate_type		=>	null											,
       			           p_project_rate_date		=>	null											,
       			           p_project_exchange_rate	=>	null											,
       			           p_projfunc_rate_type		=>	l_allocation_in_rec.pa_conversion_type							,
       			           p_projfunc_rate_date		=>	l_allocation_in_rec.pa_conversion_date							,
       			           p_projfunc_exchange_rate	=>	l_allocation_in_rec.pa_conversion_rate							,
       			           p_funding_category		=>	l_allocation_in_rec.funding_category
       			          );

   --
   -- update fund allocation line version
   --

      --dbms_output.put_line('calling oke_funding_util.update_alloc_version');
      --oke_debug.debug('calling oke_funding_util.update_alloc_version');

      OKE_FUNDING_UTIL_PKG.update_alloc_version(x_fund_allocation_id		=>	p_allocation_in_rec.fund_allocation_id	,
      						x_version_add			=>	1					,
   					        x_commit			=>	OKE_API.G_FALSE
   					       );
    END IF;

   ELSE

      --
      -- get project funding row
      --

      get_proj_funding(p_fund_allocation_id	=>	p_allocation_in_rec.fund_allocation_id	,
      		       p_version		=>	l_version				,
   		       p_project_funding	=>	l_project_funding
   	              );


      --dbms_output.put_line('calling pa_agreement_pub.update_funding from oke_agreement_pvt');
      --oke_debug.debug('calling pa_agreement_pub.update_funding from oke_agreement_pvt');

      PA_AGREEMENT_PUB.update_funding(p_api_version_number		=>	p_api_version										,
   				      p_commit				=>	OKE_API.G_FALSE										,
   				      p_init_msg_list			=>	OKE_API.G_FALSE										,
   				      p_msg_count			=> 	p_msg_count										,
   				      p_msg_data			=>	p_msg_data										,
   				      p_return_status			=>	p_return_status										,
   				      p_pm_product_code			=>	G_PRODUCT_CODE										,
   				      p_pm_funding_reference		=>	to_char(l_allocation_in_rec.fund_allocation_id) || '.' || to_char(l_version)		,
   				      p_funding_id			=>	l_project_funding.project_funding_id							,
   				      p_project_id			=>	l_allocation_in_rec.project_id								,
   				      p_task_id				=>	l_allocation_in_rec.task_id								,
   				      p_agreement_id			=>	l_allocation_in_rec.agreement_id							,
   				      p_allocated_amount		=>	l_diff_amount										,
   				      p_date_allocated			=>	p_allocation_in_rec.start_date_active							,
   				      p_desc_flex_name	     	        =>	G_PROJ_FUND_DESC_FLEX_NAME								,
   				      p_attribute_category		=>	l_allocation_in_rec.pa_attribute_category						,
   			              p_attribute1			=>	l_allocation_in_rec.pa_attribute1							,
   			              p_attribute2			=>	l_allocation_in_rec.pa_attribute2							,
   			              p_attribute3			=>	l_allocation_in_rec.pa_attribute3							,
   				      p_attribute4			=>	l_allocation_in_rec.pa_attribute4							,
   				      p_attribute5			=>	l_allocation_in_rec.pa_attribute5							,
   			              p_attribute6			=>	l_allocation_in_rec.pa_attribute6							,
   			              p_attribute7			=>	l_allocation_in_rec.pa_attribute7							,
   			              p_attribute8			=>	l_allocation_in_rec.pa_attribute8							,
   			              p_attribute9			=>	l_allocation_in_rec.pa_attribute9							,
   			              p_attribute10			=>	l_allocation_in_rec.pa_attribute10							,
       			              p_funding_id_out			=>	l_funding_id										,
       			              p_project_rate_type		=>	null											,
       			              p_project_rate_date		=>	null											,
       			              p_project_exchange_rate		=>	null											,
       			              p_projfunc_rate_type		=>	l_allocation_in_rec.pa_conversion_type							,
       			              p_projfunc_rate_date		=>	l_allocation_in_rec.pa_conversion_date							,
       			              p_projfunc_exchange_rate		=>	l_allocation_in_rec.pa_conversion_rate							,
       			              p_funding_category		=>	l_allocation_in_rec.funding_category
       			             );

   --
   -- update fund allocation line version
   --

      --dbms_output.put_line('calling oke_funding_util.update_alloc_version');
      --oke_debug.debug('calling oke_funding_util.update_alloc_version');

      OKE_FUNDING_UTIL_PKG.update_alloc_version(x_fund_allocation_id		=>	p_allocation_in_rec.fund_allocation_id	,
      						x_version_add			=>	0					,
   					        x_commit			=>	OKE_API.G_FALSE
   					       );

   END IF;

   -- fnd_client_info.set_org_context(to_number(l_org_id_vc));
      mo_global.set_policy_context('S',to_number(l_org_id_vc));

   IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   -- syho, bug 2328311
   -- update the ff of the existing project funding lines
   --FOR l_project_funding IN c_project_funding (length(p_allocation_in_rec.fund_allocation_id)) LOOP
      /*
      	  PA_AGREEMENT_PUB.update_funding(p_api_version_number		=>	p_api_version										,
   				      	  p_commit			=>	OKE_API.G_FALSE										,
   				      	  p_init_msg_list		=>	OKE_API.G_FALSE										,
   				      	  p_msg_count			=> 	p_msg_count										,
   				          p_msg_data			=>	p_msg_data										,
   				          p_return_status		=>	p_return_status										,
   				          p_pm_product_code		=>	G_PRODUCT_CODE										,
   				          p_pm_funding_reference	=>	l_project_funding.pm_funding_reference							,
   				          p_funding_id			=>	l_project_funding.project_funding_id							,
   				          p_project_id			=>	l_project_funding.project_id								,
   				          p_task_id			=>	l_project_funding.task_id								,
   				          p_agreement_id		=>	l_project_funding.agreement_id								,
   				          p_allocated_amount		=>	l_project_funding.allocated_amount							,
   				          p_date_allocated		=>	l_project_funding.date_allocated							,
   				          p_desc_flex_name	        =>	G_PROJ_FUND_DESC_FLEX_NAME								,
   				          p_attribute_category		=>	l_allocation_in_rec.pa_attribute_category						,
   			                  p_attribute1			=>	l_allocation_in_rec.pa_attribute1							,
   			                  p_attribute2			=>	l_allocation_in_rec.pa_attribute2							,
   			                  p_attribute3			=>	l_allocation_in_rec.pa_attribute3							,
   				          p_attribute4			=>	l_allocation_in_rec.pa_attribute4							,
   				          p_attribute5			=>	l_allocation_in_rec.pa_attribute5							,
   			                  p_attribute6			=>	l_allocation_in_rec.pa_attribute6							,
   			                  p_attribute7			=>	l_allocation_in_rec.pa_attribute7							,
   			                  p_attribute8			=>	l_allocation_in_rec.pa_attribute8							,
   			                  p_attribute9			=>	l_allocation_in_rec.pa_attribute9							,
   			                  p_attribute10			=>	l_allocation_in_rec.pa_attribute10							,
       			                  p_funding_id_out		=>	l_funding_id
       			                 );

         IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

            RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

         ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

            RAISE OKE_API.G_EXCEPTION_ERROR;

         END IF;
*/
   	 update pa_project_fundings
   	 set    attribute_category	= 	l_allocation_in_rec.pa_attribute_category
   	 ,  	  attribute1		= 	l_allocation_in_rec.pa_attribute1
   	 , 	  attribute2		= 	l_allocation_in_rec.pa_attribute2
  	 ,	  attribute3		= 	l_allocation_in_rec.pa_attribute3
   	 ,	  attribute4		= 	l_allocation_in_rec.pa_attribute4
   	 ,	  attribute5		= 	l_allocation_in_rec.pa_attribute5
   	 ,	  attribute6		= 	l_allocation_in_rec.pa_attribute6
  	 ,	  attribute7		= 	l_allocation_in_rec.pa_attribute7
  	 ,	  attribute8		= 	l_allocation_in_rec.pa_attribute8
   	 ,	  attribute9		= 	l_allocation_in_rec.pa_attribute9
   	 ,	  attribute10		= 	l_allocation_in_rec.pa_attribute10
   	-- where    project_funding_id	=       l_project_funding.project_funding_id;
   	where     agreement_id          =       p_allocation_in_rec.agreement_id
   	and       pm_product_code       =       G_PRODUCT_CODE
   	and       substr(pm_funding_reference, 1, length(p_allocation_in_rec.fund_allocation_id) + 1)
   	          = p_allocation_in_rec.fund_allocation_id || '.';

  -- END LOOP;

   --dbms_output.put_line('finished oke_agreement_pvt.update_funding w/ ' || p_return_status);
   --oke_debug.debug('finished oke_agreement_pvt.update_funding w/ ' || p_return_status);

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
END update_pa_funding;


--
-- Procedure: add_pa_funding
--
-- Description: This procedure is used to add pa funding
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			PA_AGREEMENT_PUB.add_funding
--			validate_line_attributes
--			get_converted_amount
--			get_agreement_org
--

PROCEDURE add_pa_funding(p_api_version			IN		NUMBER						,
   			 p_init_msg_list		IN     		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_commit			IN		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_msg_count			OUT NOCOPY	NUMBER						,
   			 p_msg_data			OUT NOCOPY	VARCHAR2					,
			 p_allocation_in_rec		IN		OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE	,
		         p_return_status		OUT NOCOPY	VARCHAR2
		        ) is

   l_api_name				VARCHAR2(20) := 'add_pa_funding';
   l_return_status			VARCHAR2(1);
   l_funding_id				NUMBER;
 --  l_amount				NUMBER;
   l_org_id_vc				VARCHAR(10);
   l_org_id_n				NUMBER;
   l_allocation_in_rec			OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE;

BEGIN

   --dbms_output.put_line('entering oke_agreement_pvt.add_pa_funding');
   --oke_debug.debug('entering oke_agreement_pvt.add_pa_funding');

   p_return_status  		       := OKE_API.G_RET_STS_SUCCESS;

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
   -- Check and validate for mandatory parameters
   --

   --dbms_output.put_line('checking mandatory parameters for pa');
   --oke_debug.debug('checking mandatory parameters for pa');

   validate_line_attributes(p_allocation_in_rec	=>	p_allocation_in_rec);

   --
   -- Calculate the allocated amount
   --

   l_allocation_in_rec := p_allocation_in_rec;
   --dbms_output.put_line('calculate the converted amount');
   --oke_debug.debug('calculate the converted amount');

   get_converted_amount(p_allocation_in_rec	=>	l_allocation_in_rec			,
		       -- p_amount		=>	l_amount				,
		        p_org_id		=>	l_org_id_n				,
			p_return_status	 	=>	p_return_status
		       );

   IF (p_return_status = 'E') THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   ELSIF (p_return_status = 'U') THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   END IF;

   --
   -- Populate the values
   --

   l_allocation_in_rec := populate_values(l_allocation_in_rec);

   --
   -- Set the enviornment variables
   --

    -- fnd_profile.get('ORG_ID',l_org_id_vc);
       l_org_id_vc := oke_utils.org_id;

   --l_org_id_n := nvl(get_agreement_org(p_agreement_id 	=> 	p_allocation_in_rec.agreement_id), -99);

   if (nvl(l_org_id_n, -99) <> -99) then

      -- fnd_client_info.set_org_context(l_org_id_n);
      mo_global.set_policy_context('S',l_org_id_n);

   end if;

   --dbms_output.put_line('calling pa_agreement_pub.add_funding');
   --oke_debug.debug('calling pa_agreement_pub.add_funding');

   IF (p_allocation_in_rec.amount <> 0) THEN

      PA_AGREEMENT_PUB.add_funding(p_api_version_number		=>	p_api_version						,
   				   p_commit			=>	OKE_API.G_FALSE						,
   				   p_init_msg_list		=>	OKE_API.G_FALSE						,
   				   p_msg_count			=> 	p_msg_count						,
   				   p_msg_data			=>	p_msg_data						,
   				   p_return_status		=>	p_return_status						,
   				   p_pm_product_code		=>	OKE_FUNDING_PUB.G_PRODUCT_CODE				,
   				   p_pm_funding_reference	=>	to_char(l_allocation_in_rec.fund_allocation_id) || '.1'	,
   				   p_funding_id			=>	l_funding_id						,
   				   p_pa_project_id		=>	l_allocation_in_rec.project_id				,
   				   p_pa_task_id			=>	l_allocation_in_rec.task_id				,
   				   p_agreement_id		=>	l_allocation_in_rec.agreement_id			,
   				   p_allocated_amount		=>	l_allocation_in_rec.amount				,
   				   p_date_allocated		=>	l_allocation_in_rec.start_date_active			,
   				   p_desc_flex_name		=>	G_PROJ_FUND_DESC_FLEX_NAME				,
   				   p_attribute_category		=>	l_allocation_in_rec.pa_attribute_category		,
   				   p_attribute1			=>	l_allocation_in_rec.pa_attribute1			,
   				   p_attribute2			=>	l_allocation_in_rec.pa_attribute2			,
   				   p_attribute3			=>	l_allocation_in_rec.pa_attribute3			,
   				   p_attribute4			=>	l_allocation_in_rec.pa_attribute4			,
   				   p_attribute5			=>	l_allocation_in_rec.pa_attribute5			,
   				   p_attribute6			=>	l_allocation_in_rec.pa_attribute6			,
   				   p_attribute7			=>	l_allocation_in_rec.pa_attribute7			,
   				   p_attribute8			=>	l_allocation_in_rec.pa_attribute8			,
   				   p_attribute9			=>	l_allocation_in_rec.pa_attribute9			,
   				   p_attribute10		=>	l_allocation_in_rec.pa_attribute10			,
       			           p_funding_id_out		=>	l_funding_id						,
       			           p_project_rate_type		=>	null							,
       			           p_project_rate_date		=>	null							,
       			           p_project_exchange_rate	=>	null							,
       			           p_projfunc_rate_type		=>	l_allocation_in_rec.pa_conversion_type			,
       		                   p_projfunc_rate_date		=>	l_allocation_in_rec.pa_conversion_date			,
       	    	                   p_projfunc_exchange_rate	=>	l_allocation_in_rec.pa_conversion_rate			,
       	    	                   p_funding_category		=>	l_allocation_in_rec.funding_category
       			         );

   END IF;

   -- fnd_client_info.set_org_context(to_number(l_org_id_vc));
      mo_global.set_policy_context('S',to_number(l_org_id_vc));

   --dbms_output.put_line('finished pa_agreement_pub.add_funding w/ ' || p_return_status);
   --oke_debug.debug('finished pa_agreement_pub.add_funding w/ ' || p_return_status);

   IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

   ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

   --
   -- Update project funding line flexfield since PA AMG add_funding doesn't handle
   --

   update pa_project_fundings
   set    attribute_category	= 	l_allocation_in_rec.pa_attribute_category
   ,  	  attribute1		= 	l_allocation_in_rec.pa_attribute1
   , 	  attribute2		= 	l_allocation_in_rec.pa_attribute2
   ,	  attribute3		= 	l_allocation_in_rec.pa_attribute3
   ,	  attribute4		= 	l_allocation_in_rec.pa_attribute4
   ,	  attribute5		= 	l_allocation_in_rec.pa_attribute5
   ,	  attribute6		= 	l_allocation_in_rec.pa_attribute6
   ,	  attribute7		= 	l_allocation_in_rec.pa_attribute7
   ,	  attribute8		= 	l_allocation_in_rec.pa_attribute8
   ,	  attribute9		= 	l_allocation_in_rec.pa_attribute9
   ,	  attribute10		= 	l_allocation_in_rec.pa_attribute10
   where  pm_product_code	=	G_PRODUCT_CODE
   and    substr(pm_funding_reference, 1, length(l_allocation_in_rec.fund_allocation_id) + 1)
          =  to_char(l_allocation_in_rec.fund_allocation_id) || '.';

   --
   -- update fund allocation line version
   --

   --dbms_output.put_line('calling oke_funding_util.update_alloc_version');
   --oke_debug.debug('calling oke_funding_util.update_alloc_version');

   OKE_FUNDING_UTIL_PKG.update_alloc_version(x_fund_allocation_id	=>	p_allocation_in_rec.fund_allocation_id	,
   					     x_version_add		=> 	1					,
   					     x_commit			=>	OKE_API.G_FALSE
   					    );

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   --dbms_output.put_line('finished oke_agreement_pvt.add_pa_funding w/ ' || p_return_status);
   --oke_debug.debug('finished oke_agreement_pvt.add_pa_funding w/ ' || p_return_status);

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
END add_pa_funding;

end OKE_AGREEMENT_PVT;

/
