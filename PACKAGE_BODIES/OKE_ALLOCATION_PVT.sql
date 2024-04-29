--------------------------------------------------------
--  DDL for Package Body OKE_ALLOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_ALLOCATION_PVT" as
/* $Header: OKEVFDAB.pls 120.3 2005/11/23 14:37:43 ausmani noship $ */

--
-- Local Variables
--

L_USERID		NUMBER 	     	:= FND_GLOBAL.USER_ID;
L_LOGINID		NUMBER		:= FND_GLOBAL.LOGIN_ID;




--
-- Private Procedures and Functions
--


--
-- Function: get_fund_allocation_id
--
-- Description: This function is used to get fund_allocation_id
--
--

FUNCTION get_fund_allocation_id RETURN NUMBER is

   l_funding_allocation_id		NUMBER;

BEGIN

   select oke_k_fund_allocations_s.nextval
   into   l_funding_allocation_id
   from   dual;

   return(l_funding_allocation_id);

END get_fund_allocation_id;


--
-- Function: get_source_currency
--
-- Description: This function is used to get funding source currency
--
--

FUNCTION get_source_currency(p_funding_source_id 		NUMBER)
			     RETURN VARCHAR2 is

   l_currency		VARCHAR2(15);

   cursor c_currency is
      select currency_code
      from   oke_k_funding_sources
      where  funding_source_id = p_funding_source_id;

BEGIN

   OPEN c_currency;
   FETCH c_currency into l_currency;

   IF (c_currency%NOTFOUND) THEN

       CLOSE c_currency;
       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   CLOSE c_currency;

  return(l_currency);

EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;

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

      RAISE G_EXCEPTION_HALT_VALIDATION;

END get_source_currency;


--
-- Function: get_proj_info
--
-- Description: This function is used to get project information
--
--

PROCEDURE get_proj_info(p_project_id 					NUMBER		,
			p_projfunc_currency	OUT NOCOPY		VARCHAR2	) is

   cursor c_currency is
      select p.projfunc_currency_code
      from   pa_projects_all p
      where  project_id = p_project_id;

BEGIN

   OPEN c_currency;
   FETCH c_currency into p_projfunc_currency;

   IF (c_currency%NOTFOUND) THEN

      CLOSE c_currency;
      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   CLOSE c_currency;

EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;

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

      RAISE G_EXCEPTION_HALT_VALIDATION;

END get_proj_info;


--
-- Procedure: allowable_changes
--
-- Description: This procedure is used to check if changes are allowed
--
--
/*
PROCEDURE allowable_changes(p_fund_allocation_id		NUMBER	,
			    p_project_id			NUMBER  ,
			    p_task_id				NUMBER	,
			    p_start_date_active			DATE
		           ) is

   cursor c_allocation is
      select project_id,
      	     task_id,
      	     start_date_active
      from   oke_k_fund_allocations
      where  fund_allocation_id = p_fund_allocation_id;

   l_allocation		c_allocation%ROWTYPE;
   l_field		VARCHAR2(30);

BEGIN

   OPEN c_allocation;
   FETCH c_allocation into l_allocation;
   CLOSE c_allocation;

   IF (l_allocation.project_id <> p_project_id) then

       l_field := 'Project';

   ELSIF (l_allocation.task_id <> p_task_id) then

       l_field := 'Task';

   ELSIF (l_allocation.start_date_active <> p_start_date_active) then

       l_field := 'Start Date Active';

   END IF;

   IF (l_field is not null) THEN

      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_NO_FUND_CHANGE'	,
      			  p_token1		=>	'FILED'			,
      			  p_token1_value	=>	l_field
      			 );

   END IF;

END allowable_changes;
*/


--
-- Procedure: validate_amount
--
-- Description: This procedure is used to validate amount
--
--

PROCEDURE validate_amount(p_amount 			NUMBER			,
			  p_return_status OUT NOCOPY	VARCHAR2
			 ) is

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_amount is null) 		 OR
      (p_amount = OKE_API.G_MISS_NUM) THEN

      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'	,
      			  p_token1		=>	'VALUE'			,
      			  p_token1_value	=>	'amount'
      			 );

      p_return_status := OKE_API.G_RET_STS_ERROR;

   END IF;

END validate_amount;


--
-- Procedure: validate_project_task
--
-- Description: This procedure is used to validate project_id and task_id relationship
--
--

PROCEDURE validate_project_task(p_project_id		NUMBER		,
			        p_task_id		NUMBER
			       ) is

    cursor c_project_task is
       select 'x'
       from   pa_tasks
       where  task_id = p_task_id
       and    top_task_id = p_task_id
       and    project_id = p_project_id;

    l_dummy_value 	VARCHAR2(1) := '?';

BEGIN

   IF (p_project_id is not null) THEN

       IF (p_task_id is not null) THEN

          OPEN c_project_task;
          FETCH c_project_task into l_dummy_value;
          CLOSE c_project_task;

          IF (l_dummy_value = '?') THEN

              OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			          p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			          p_token1		=>	'VALUE'			,
      			          p_token1_value	=>	'task_id and project_id'
      			         );

      	      RAISE G_EXCEPTION_HALT_VALIDATION;

          END IF;

      END IF;

   ElSIF (p_task_id is not null) THEN

       OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			   p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			   p_token1		=>	'VALUE'			,
      			   p_token1_value	=>	'task_id'
      			  );

       RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;

   WHEN OTHERS THEN
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_project_task%ISOPEN THEN
         CLOSE c_project_task;
      END IF;

END validate_project_task;


--
-- Procedure: validate_header_line
--
-- Description: This procedure is used to validate object_id and k_line_id relationship
--
--

PROCEDURE validate_header_line(p_object_id		NUMBER		,
			       p_k_line_id		NUMBER
			      ) is

    cursor c_header_line is
       select 'x'
       from   okc_k_lines_b
       where  id = p_k_line_id
       and    dnz_chr_id = p_object_id;

    l_dummy_value 	VARCHAR2(1) := '?';
BEGIN

   IF (p_k_line_id is not null) THEN

      OPEN c_header_line;
      FETCH c_header_line into l_dummy_value;
      CLOSE c_header_line;

      IF (l_dummy_value = '?') THEN

          OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			      p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			      p_token1			=>	'VALUE'			,
      			      p_token1_value		=>	'k_line_id and object_id'
      			     );

          RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

   END IF;

EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;

   WHEN OTHERS THEN
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_header_line%ISOPEN THEN
         CLOSE c_header_line;
      END IF;

END validate_header_line;


--
-- Procedure: validate_fund_allocation_id
--
-- Description: This procedure is used to validate fund_allocation_id
--
--

PROCEDURE validate_fund_allocation_id(p_fund_allocation_id 			NUMBER			,
				      p_rowid			OUT NOCOPY	VARCHAR2		,
				      p_version			OUT NOCOPY	NUMBER
			             ) is
   cursor c_fund_allocation_id is
      select rowid, nvl(agreement_version, 0)
      from   oke_k_fund_allocations
      where  fund_allocation_id = p_fund_allocation_id;

BEGIN

  IF (p_fund_allocation_id is null) 			OR
      (p_fund_allocation_id  = OKE_API.G_MISS_NUM) 	THEN

      OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			  p_token1		=> 	'VALUE'				,
      			  p_token1_value	=> 	'fund_allocation_id'
     			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   OPEN c_fund_allocation_id;
   FETCH c_fund_allocation_id into p_rowid, p_version;

   IF (c_fund_allocation_id%NOTFOUND) THEN

      CLOSE c_fund_allocation_id;

      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			  p_token1		=>	'VALUE'			,
      			  p_token1_value	=>	'fund_allocation_id'
      			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   CLOSE c_fund_allocation_id;

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

      IF c_fund_allocation_id%ISOPEN THEN
         CLOSE c_fund_allocation_id;
      END IF;

      RAISE G_EXCEPTION_HALT_VALIDATION;

END validate_fund_allocation_id;


--
-- Procedure: validate_object_id
--
-- Description: This procedure is used to validate object_id
--
--

PROCEDURE validate_object_id(p_object_id 			NUMBER	,
			     p_funding_source_id		NUMBER	,
			     p_return_status	OUT NOCOPY	VARCHAR2
			    ) is
   cursor c_object_id is
      select 'x'
      from   oke_k_funding_sources
      where  object_id = p_object_id
      and    funding_source_id = p_funding_source_id;

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_object_id is null) 		 OR
      (p_object_id = OKE_API.G_MISS_NUM) THEN

      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'	,
      			  p_token1		=>	'VALUE'			,
      			  p_token1_value	=>	'object_id'
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
-- Procedure: validate_funding_source_id
--
-- Description: This procedure is used to validate funding_source_id
--
--

PROCEDURE validate_funding_source_id(p_funding_source_id			NUMBER	,
   			      	     p_return_status		OUT NOCOPY	VARCHAR2
   		                    ) is
   cursor c_funding_source_id is
      select 'x'
      from   oke_k_funding_sources
      where  funding_source_id = p_funding_source_id
      FOR UPDATE OF funding_source_id NOWAIT;

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   --oke_debug.debug('validate_funding_source_id : funding_source_id ' || p_funding_source_id);
   --dbms_output.put_line('validate_funding_source_id : funding_source_id ' || p_funding_source_id);

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_funding_source_id is null) 		 OR
      (p_funding_source_id = OKE_API.G_MISS_NUM) THEN

      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	'OKE_API_MISSING_VALUE'	,
      			  p_token1		=>	'VALUE'			,
      			  p_token1_value	=>	'funding_source_id'
      			 );

       p_return_status := OKE_API.G_RET_STS_ERROR;

   ELSE

     OPEN c_funding_source_id;
     FETCH c_funding_source_id into l_dummy_value;
     CLOSE c_funding_source_id;

     --oke_debug.debug('validate_funding_source_id : l_dummy_value ' || l_dummy_value);
     --dbms_output.put_line('validate_funding_source_id : l_dummy_value ' || l_dummy_value);

     IF (l_dummy_value = '?') THEN

        OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			    p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			    p_token1		=>	'VALUE'			,
      			    p_token1_value	=>	'funding_source_id'
      			   );

        p_return_status := OKE_API.G_RET_STS_ERROR;

     END IF;

   END IF;

EXCEPTION
   WHEN G_RESOURCE_BUSY THEN
      p_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
      			  p_msg_name		=>	'OKE_ROW_LOCKED'		,
      			  p_token1		=>	'SOURCE'			,
      			  p_token1_value	=>	'OKE_FUNDING_SOURCE_PROMPT'	,
      			  p_token1_translate	=>	OKE_API.G_TRUE			,
      			  p_token2		=>	'ID'				,
      			  p_token2_value	=>	p_funding_source_id
      			 );

      IF c_funding_source_id%ISOPEN THEN
         CLOSE c_funding_source_id;
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

      IF c_funding_source_id%ISOPEN THEN
         CLOSE c_funding_source_id;
      END IF;

END validate_funding_source_id;


--
-- Procedure: validate_k_line_id
--
-- Description: This procedure is used to validate k_line_id
--
--

PROCEDURE validate_k_line_id(p_k_line_id				NUMBER	,
			     p_project_id				NUMBER	,
			     p_fund_allocation_id			NUMBER	,
   		   	     p_return_status	OUT NOCOPY    		VARCHAR2
   		            ) is
   cursor c_line_id is
      select 'x'
      from   oke_k_lines
      where  k_line_id = p_k_line_id;

   cursor c_header is
      select pa_flag
      from   oke_k_fund_allocations
      where  fund_allocation_id = p_fund_allocation_id;

   cursor c_line_project is
      select project_id, task_id
      from   oke_k_lines
      where  k_line_id = p_k_line_id;

   cursor c_valid_line (x_project_id number) is
      select 'x'
      from   dual
      where  p_project_id in
      (select to_number(sub_project_id)
      from   pa_fin_structures_links_v
      start with parent_project_id = x_project_id
      connect by parent_project_id = prior sub_project_id
      );

   cursor c_valid_line2 (x_task_id number,x_project_id number) is
      select 'x'
      from   dual
      where  p_project_id in
      ( select to_number(sub_project_id)
      from   pa_fin_structures_links_v
      START WITH (parent_project_id, parent_task_id)
              IN (SELECT x_project_id, task_id FROM pa_tasks
                   WHERE project_id = x_project_id
                     AND top_task_id = nvl(x_task_id, top_task_id))
      connect by parent_project_id = prior sub_project_id);

   cursor c_line (x_line_id number) is
      select project_id,
	     parent_line_id,
	     task_id
      from   oke_k_lines
      where  k_line_id = x_line_id;

   l_dummy_value	VARCHAR2(1) := '?';
   l_flag 		VARCHAR2(1);
   l_line_project	NUMBER;
   l_master_project	NUMBER;
   l_exist		VARCHAR2(1) := 'N';
   l_valid_project	NUMBER;
   l_line_id		NUMBER;
   l_line_task		NUMBER;

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_k_line_id is not null)		  OR
      (p_k_line_id <> OKE_API.G_MISS_NUM) THEN

      OPEN c_line_id;
      FETCH c_line_id into l_dummy_value;
      CLOSE c_line_id;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'k_line_id'
      			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

      END IF;

      IF (p_fund_allocation_id is not null) THEN

  	 OPEN c_header;
  	 FETCH c_header into l_flag;
  	 CLOSE c_header;

  	 IF (nvl(l_flag, 'N') = 'Y') THEN

  	     OPEN c_line_project;
  	     FETCH c_line_project into l_line_project, l_line_task;
  	     CLOSE c_line_project;

  	     IF (l_line_project is null) THEN

		 l_line_id := p_k_line_id;
		 WHILE (l_exist = 'N') LOOP
		    OPEN c_line(l_line_id);
		    FETCH c_line into l_line_project, l_line_id, l_line_task;
		    CLOSE c_line;

		    IF (l_line_project is not null) OR
		       (l_line_id is null)	    THEN
		    	   l_exist := 'Y';
		    END IF;
		 END LOOP;
	     END IF;

	     IF (l_line_project is not null) THEN
	     	IF (l_line_project <> p_project_id) THEN
	            IF (l_line_task is not null) THEN

  		       OPEN c_valid_line2(l_line_task,l_line_project);
  		       FETCH c_valid_line2 into l_dummy_value;
  		       CLOSE c_valid_line2;

  		    ELSE

  		       OPEN c_valid_line(l_line_project);
  		       FETCH c_valid_line into l_dummy_value;
  		       CLOSE c_valid_line;

  		    END IF;

  		    IF (l_dummy_value = '?') THEN
  		       OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			     		   p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     		   p_token1		=>	'VALUE'			,
      			     		   p_token1_value	=>	'k_line_id'
      			    		  );

        	       p_return_status := OKE_API.G_RET_STS_ERROR;
  		    END IF;
  		END IF;
  	     END IF;

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

      IF c_line_id%ISOPEN THEN
         CLOSE c_line_id;
      END IF;

END validate_k_line_id;


--
-- Procedure: validate_project_id
--
-- Description: This procedure is used to validate project_id
--
--

PROCEDURE validate_project_id(p_project_id			NUMBER,
			      p_k_line_id			NUMBER,
			      p_funding_source_id		NUMBER,
			      p_object_id			NUMBER,
   		      	      p_return_status	OUT NOCOPY	VARCHAR2
   		     	     ) is
   cursor c_project_id is
      select 'x'
      from   pa_project_customers p,
             pa_projects_all a,
      	     oke_k_funding_sources f,
      	     pa_project_types_all l,
      	     hz_cust_accounts h
      where  p.project_id = p_project_id
      and    nvl(a.template_flag, '-99') <> 'Y'
      and    f.funding_source_id = p_funding_source_id
      and    p.customer_id = h.cust_account_id
      and    h.party_id = f.k_party_id
      and    a.project_id = p.project_id
      and    a.project_type = l.project_type
      and    l.project_type_class_code = 'CONTRACT';

   cursor c_line_project is
      select project_id,
      	     task_id
      from   oke_k_lines_v
      where  header_id = p_object_id
      and    k_line_id = p_k_line_id;

   cursor c_master_project is
      select project_id
      from   oke_k_headers
      where  k_header_id = p_object_id;

   cursor c_project_h (x_project_id number) is
      select 'x'
      from   dual
      where  p_project_id in
      (select to_number(sub_project_id)
      from    pa_fin_structures_links_v
      start with parent_project_id = x_project_id
      connect by parent_project_id = prior sub_project_id
      union all
      select x_project_id
      from   dual
      );

   cursor c_project_h2 (x_task_id number, x_project_id number) is
      select 'x'
      from   dual
      where  p_project_id in
      ( select to_number(sub_project_id)
      from    pa_fin_structures_links_v
      start with parent_project_id = x_project_id
      and parent_task_id = x_task_id
      connect by parent_project_id = prior sub_project_id
      union all
      select x_project_id
      from   dual
      );

   cursor c_intent is
      select buy_or_sell
      from   oke_k_headers_v
      where  k_header_id = p_object_id;

   cursor c_project_2 (x_line_id number) is
      select project_id,
	     parent_line_id,
             task_id
      from   oke_k_lines
      where  k_line_id = x_line_id;

   l_dummy_value	VARCHAR2(1) := '?';
   l_project_id		NUMBER;
   l_intent		VARCHAR2(1);
   l_task_id		NUMBER;
   l_line_id		NUMBER;
   l_exist		VARCHAR2(1);

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_project_id is not null) 		OR
      (p_project_id <> OKE_API.G_MISS_NUM) 	THEN

      OPEN c_intent;
      FETCH c_intent into l_intent;
      CLOSE c_intent;

      IF (l_intent = 'S') THEN

         OPEN c_project_id;
         FETCH c_project_id into l_dummy_value;
         CLOSE c_project_id;

         IF (l_dummy_value = '?') THEN

             OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			         p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			         p_token1		=>	'VALUE'			,
      			         p_token1_value		=>	'project_id'
      			         );

             p_return_status := OKE_API.G_RET_STS_ERROR;
             return;

          END IF;

      END IF;

      l_dummy_value := '?';

      IF (p_k_line_id is not null) then
      	 OPEN c_line_project;
      	 FETCH c_line_project into l_project_id, l_task_id;
      	 CLOSE c_line_project;

      	 IF (l_project_id is null) THEN

 	     l_line_id := p_k_line_id;
             l_exist   := 'N';

	     while (l_exist = 'N') loop

	       open c_project_2 (l_line_id);
               l_line_id := null;
	       fetch c_project_2 into l_project_id, l_line_id, l_task_id;
	       close c_project_2;

	       if (l_line_id is null)        or
		  (l_project_id is not null) then
		     l_exist := 'Y';
	       end if;

	     end loop;

      	 END IF;

      END IF;

      IF (l_project_id is null) then
         OPEN c_master_project;
         FETCH c_master_project into l_project_id;
         CLOSE c_master_project;
      END IF;

      IF (l_project_id is null) then

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'project_id'
      			    );

         p_return_status := OKE_API.G_RET_STS_ERROR;

      ELSE

         IF (l_task_id is not null) THEN

             OPEN c_project_h2(l_task_id, l_project_id);
             FETCH c_project_h2 into l_dummy_value;
             CLOSE c_project_h2;

         ELSE

             OPEN c_project_h(l_project_id);
             FETCH c_project_h into l_dummy_value;
             CLOSE c_project_h;

         END IF;

         IF (l_dummy_value = '?') then

             OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			         p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			         p_token1		=>	'VALUE'			,
      			         p_token1_value		=>	'project_id'
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

      IF c_project_id%ISOPEN THEN
         CLOSE c_project_id;
      END IF;

END validate_project_id;


--
-- Procedure: validate_task_id
--
-- Description: This procedure is used to validate task_id
--
--

PROCEDURE validate_task_id(p_task_id					NUMBER	,
   		  	   p_return_status	OUT NOCOPY		VARCHAR2
   		  	 ) is
   cursor c_task_id is
      select 'x'
      from   pa_tasks
      where  task_id    = p_task_id
      and    task_id    = top_task_id;

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_task_id is not null)			OR
      (p_task_id <> OKE_API.G_MISS_NUM) 	THEN

      OPEN c_task_id;
      FETCH c_task_id into l_dummy_value;
      CLOSE c_task_id;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'task_id'
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

      IF c_task_id%ISOPEN THEN
         CLOSE c_task_id;
      END IF;

END validate_task_id;


--
-- Procedure: validate_fund_type
--
-- Description: This procedure is used to validate fund_type
--
--

PROCEDURE validate_fund_type(p_fund_type			VARCHAR2	,
   		     	     p_return_status	OUT NOCOPY	VARCHAR2
   		    	    ) is
   cursor c_fund_type is
      select 'x'
      from   fnd_lookup_values
      where  lookup_type   = 'FUND_TYPE'
      and    language = userenv('LANG')
      and    enabled_flag = 'Y'
      and    lookup_code = upper(p_fund_type);

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_fund_type is not null)				OR
      (p_fund_type <> OKE_API.G_MISS_CHAR)		THEN

      OPEN c_fund_type;
      FETCH c_fund_type into l_dummy_value;
      CLOSE c_fund_type;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'fund_type'
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

      IF c_fund_type%ISOPEN THEN
         CLOSE c_fund_type;
      END IF;

END validate_fund_type;


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

   IF (p_funding_status is not null)				OR
      (p_funding_status <> OKE_API.G_MISS_CHAR)			THEN

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
-- Procedure: validate_funding_category
--
-- Description: This procedure is used to validate funding_category
--
--

PROCEDURE validate_funding_category(p_funding_category			VARCHAR2	,
			            p_return_status	OUT NOCOPY	VARCHAR2
			           ) is
   cursor c_funding_category is
      select 'x'
      from   pa_lookups
      where  lookup_type = 'FUNDING CATEGORY TYPE'
      and    lookup_code = upper(p_funding_category);

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_funding_category is null)					OR
      (p_funding_category = OKE_API.G_MISS_CHAR)			THEN

       OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			   p_msg_name		=>	'OKE_API_MISSING_VALUE'	,
      			   p_token1		=>	'VALUE'			,
      		           p_token1_value	=>	'funding_category'
      	    	          );

       p_return_status := OKE_API.G_RET_STS_ERROR;

   ELSE

      OPEN c_funding_category;
      FETCH c_funding_category into l_dummy_value;
      CLOSE c_funding_category;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'funding_category'
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

      IF c_funding_category%ISOPEN THEN
         CLOSE c_funding_category;
      END IF;

END validate_funding_category;


--
-- Procedure: validate_conversion_type
--
-- Description: This procedure is used to validate conversion_type
--
--

PROCEDURE validate_conversion_type(p_conversion_type			VARCHAR2	,
			           p_return_status	OUT NOCOPY	VARCHAR2
			           ) is
   cursor c_conversion_type is
      select 'x'
      from   gl_daily_conversion_types
      where  UPPER(conversion_type) = UPPER(p_conversion_type);

   l_dummy_value	VARCHAR2(1) := '?';

BEGIN

   p_return_status := OKE_API.G_RET_STS_SUCCESS;

   IF (p_conversion_type is not null)				OR
      (p_conversion_type <> OKE_API.G_MISS_CHAR)		THEN

      OPEN c_conversion_type;
      FETCH c_conversion_type into l_dummy_value;
      CLOSE c_conversion_type;

      IF (l_dummy_value = '?') THEN

         OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			     p_msg_name		=>	'OKE_API_INVALID_VALUE'	,
      			     p_token1		=>	'VALUE'			,
      			     p_token1_value	=>	'pa_conversion_type'
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

      IF c_conversion_type%ISOPEN THEN
         CLOSE c_conversion_type;
      END IF;

END validate_conversion_type;


--
-- Function: null_allocation_out
--
-- Description: This function is used to set all the missing attribute values to be null
--
--

FUNCTION null_allocation_out(p_allocation_in_rec 	IN	ALLOCATION_REC_IN_TYPE)
			    RETURN ALLOCATION_REC_IN_TYPE
			    is
   l_allocation_in_rec	  ALLOCATION_REC_IN_TYPE := p_allocation_in_rec;
BEGIN

   l_allocation_in_rec.fund_allocation_id := null;

   IF l_allocation_in_rec.agreement_id = OKE_API.G_MISS_NUM THEN
      l_allocation_in_rec.agreement_id := null;
   END IF;

   IF l_allocation_in_rec.amount = OKE_API.G_MISS_NUM THEN
      l_allocation_in_rec.amount := null;
   END IF;

   IF l_allocation_in_rec.funding_source_id = OKE_API.G_MISS_NUM THEN
      l_allocation_in_rec.funding_source_id := null;
   END IF;

   IF l_allocation_in_rec.object_id = OKE_API.G_MISS_NUM THEN
      l_allocation_in_rec.object_id := null;
   END IF;

   IF l_allocation_in_rec.k_line_id = OKE_API.G_MISS_NUM THEN
      l_allocation_in_rec.k_line_id := null;
   END IF;

   IF l_allocation_in_rec.project_id = OKE_API.G_MISS_NUM THEN
      l_allocation_in_rec.project_id := null;
   END IF;

   IF l_allocation_in_rec.task_id = OKE_API.G_MISS_NUM THEN
      l_allocation_in_rec.task_id := null;
   END IF;

   IF l_allocation_in_rec.fund_type = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.fund_type := null;
   END IF;

   IF l_allocation_in_rec.hard_limit = OKE_API.G_MISS_NUM THEN
      l_allocation_in_rec.hard_limit := null;
   END IF;

   IF l_allocation_in_rec.funding_status = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.funding_status := null;
   END IF;

   IF l_allocation_in_rec.fiscal_year = OKE_API.G_MISS_NUM THEN
      l_allocation_in_rec.fiscal_year := null;
   END IF;

   IF l_allocation_in_rec.reference1 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.reference1 := null;
   END IF;

   IF l_allocation_in_rec.reference2 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.reference2 := null;
   END IF;

   IF l_allocation_in_rec.reference3 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.reference3 := null;
   END IF;

   IF l_allocation_in_rec.pa_conversion_type = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_conversion_type := null;
   END IF;

   IF l_allocation_in_rec.pa_conversion_date = OKE_API.G_MISS_DATE THEN
      l_allocation_in_rec.pa_conversion_date := null;
   END IF;

   -- syho, bug 2208979
   IF l_allocation_in_rec.pa_conversion_rate = OKE_API.G_MISS_NUM THEN
      l_allocation_in_rec.pa_conversion_rate := null;
   END IF;
   -- syho, bug 2208979

   IF l_allocation_in_rec.start_date_active = OKE_API.G_MISS_DATE THEN
      l_allocation_in_rec.start_date_active := null;
   END IF;

   IF l_allocation_in_rec.end_date_active = OKE_API.G_MISS_DATE THEN
      l_allocation_in_rec.end_date_active := null;
   END IF;
/*
   IF l_allocation_in_rec.oke_desc_flex_name = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_desc_flex_name := null;
   END IF;
*/
   IF l_allocation_in_rec.oke_attribute_category = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute_category := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute1 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute1 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute2 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute2 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute3 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute3 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute4 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute4 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute5 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute5 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute6 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute6 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute7 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute7 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute8 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute8 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute9 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute9 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute10 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute10 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute11 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute11 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute12 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute12 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute13 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute13 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute14 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute14 := null;
   END IF;

   IF l_allocation_in_rec.oke_attribute15 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.oke_attribute15 := null;
   END IF;

   IF l_allocation_in_rec.revenue_hard_limit = OKE_API.G_MISS_NUM THEN
      l_allocation_in_rec.revenue_hard_limit := null;
   END IF;

   IF l_allocation_in_rec.pa_attribute_category = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute_category := null;
   END IF;

   IF l_allocation_in_rec.pa_attribute1 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute1 := null;
   END IF;

   IF l_allocation_in_rec.pa_attribute2 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute2 := null;
   END IF;

   IF l_allocation_in_rec.pa_attribute3 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute3 := null;
   END IF;

   IF l_allocation_in_rec.pa_attribute4 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute4 := null;
   END IF;

   IF l_allocation_in_rec.pa_attribute5 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute5 := null;
   END IF;

   IF l_allocation_in_rec.pa_attribute6 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute6 := null;
   END IF;

   IF l_allocation_in_rec.pa_attribute7 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute7 := null;
   END IF;

   IF l_allocation_in_rec.pa_attribute8 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute8 := null;
   END IF;

   IF l_allocation_in_rec.pa_attribute9 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute9 := null;
   END IF;

   IF l_allocation_in_rec.pa_attribute10 = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.pa_attribute10 := null;
   END IF;

   IF l_allocation_in_rec.funding_category = OKE_API.G_MISS_CHAR THEN
      l_allocation_in_rec.funding_category := null;
   END IF;

   return(l_allocation_in_rec);

END null_allocation_out;


--
-- Procedure: validate_populate_rec
--
-- Description: This procedure is used to set all the missing attribute values to the existing values in DB
--
--

PROCEDURE validate_populate_rec(p_allocation_in_rec        	IN		ALLOCATION_REC_IN_TYPE  	,
				p_allocation_in_rec_out		OUT NOCOPY      ALLOCATION_REC_IN_TYPE  	,
				p_previous_amount		OUT NOCOPY	NUMBER				,
			       -- p_conversion_rate		OUT NOCOPY	NUMBER				,
				p_flag				OUT NOCOPY	VARCHAR2
			       ) is

   cursor c_allocation_row is
      select *
      from   oke_k_fund_allocations
      where  fund_allocation_id = p_allocation_in_rec.fund_allocation_id
      FOR UPDATE OF fund_allocation_id NOWAIT;

   cursor c_version is
      select major_version + 1
      from   okc_k_vers_numbers
      where  chr_id = p_allocation_in_rec.object_id;

   l_allocation_row		c_allocation_row%ROWTYPE;
   l_error_value		VARCHAR2(50);
   l_version			NUMBER;

BEGIN

   p_flag := 'N';
   p_allocation_in_rec_out := p_allocation_in_rec;

   OPEN c_version;
   FETCH c_version into l_version;
   CLOSE c_version;

   OPEN c_allocation_row;
   FETCH c_allocation_row into l_allocation_row;
   CLOSE c_allocation_row;

   IF p_allocation_in_rec_out.agreement_id = OKE_API.G_MISS_NUM THEN
      p_allocation_in_rec_out.agreement_id := null;
   END IF;

   IF (p_allocation_in_rec_out.funding_source_id = OKE_API.G_MISS_NUM)		THEN
       p_allocation_in_rec_out.funding_source_id := l_allocation_row.funding_source_id;

   ELSIF (nvl(p_allocation_in_rec_out.funding_source_id, -99) <> l_allocation_row.funding_source_id) THEN

      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			  p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			  p_token1			=>	'VALUE'								,
      			  p_token1_value		=>	'funding_source_id'
  			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (p_allocation_in_rec_out.object_id = OKE_API.G_MISS_NUM)		THEN
      p_allocation_in_rec_out.object_id := l_allocation_row.object_id;

   ELSIF (nvl(p_allocation_in_rec_out.object_id, -99) <> l_allocation_row.object_id) THEN

      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			  p_msg_name			=>	'OKE_API_INVALID_VALUE'						,
      			  p_token1			=>	'VALUE'								,
      			  p_token1_value		=>	'object_id'
  			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (p_allocation_in_rec_out.k_line_id = OKE_API.G_MISS_NUM)		THEN
      p_allocation_in_rec_out.k_line_id := l_allocation_row.k_line_id;
   END IF;

   IF p_allocation_in_rec_out.pa_conversion_date = OKE_API.G_MISS_DATE THEN
       p_allocation_in_rec_out.pa_conversion_date := l_allocation_row.pa_conversion_date;
   END IF;

   IF p_allocation_in_rec_out.pa_conversion_type = OKE_API.G_MISS_CHAR THEN
       p_allocation_in_rec_out.pa_conversion_type := l_allocation_row.pa_conversion_type;
   END IF;

   IF p_allocation_in_rec_out.pa_conversion_rate = OKE_API.G_MISS_NUM THEN
       p_allocation_in_rec_out.pa_conversion_rate := l_allocation_row.pa_conversion_rate;
   END IF;

   IF (p_allocation_in_rec_out.project_id = OKE_API.G_MISS_NUM) THEN
      p_allocation_in_rec_out.project_id := l_allocation_row.project_id;
   END IF;

   IF (nvl(p_allocation_in_rec_out.project_id, -99) <> nvl(l_allocation_row.project_id, -99)) THEN

         p_flag := 'Y';

   ELSIF (nvl(p_allocation_in_rec_out.pa_conversion_type, '-99') <> nvl(l_allocation_row.pa_conversion_type, '-99')) OR
         (nvl(to_char(p_allocation_in_rec_out.pa_conversion_date, 'YYYYMMDD'), '19000101') <> nvl(to_char(l_allocation_row.pa_conversion_date, 'YYYYMMDD'), '19000101')) OR
         (nvl(p_allocation_in_rec_out.pa_conversion_rate, -99) <> nvl(l_allocation_row.pa_conversion_rate, -99)) THEN
   /*
      IF (p_allocation_in_rec_out.pa_conversion_type is not null) AND
         (p_allocation_in_rec_out.pa_conversion_date is not null) THEN
     */
         p_flag := 'Y';


   --   END IF;

   ELSE

      p_flag := 'N';

   END IF;

   IF (p_allocation_in_rec_out.task_id = OKE_API.G_MISS_NUM) THEN
      p_allocation_in_rec_out.task_id := l_allocation_row.task_id;
   END IF;

   --
   -- Check values for contract, project and task if created version = current version
   --

   IF (nvl(p_allocation_in_rec_out.task_id, -99) <> nvl(l_allocation_row.task_id, -99)) AND
      ((nvl(l_allocation_row.created_in_version, -99) <> nvl(l_version, -99))       OR
       (nvl(l_allocation_row.agreement_version, 0) <> 0))			    THEN

      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			  p_msg_name			=>	'OKE_API_NO_UPDATE'						,
      			  p_token1			=>	'VALUE'								,
      			  p_token1_value		=>	'task_id'
  			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (nvl(p_allocation_in_rec_out.project_id, -99) <> nvl(l_allocation_row.project_id, -99)) AND
      ((nvl(l_allocation_row.created_in_version, -99) <> nvl(l_version, -99))             OR
       (nvl(l_allocation_row.agreement_version, 0) <> 0))			          THEN


      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			  p_msg_name			=>	'OKE_API_NO_UPDATE'						,
      			  p_token1			=>	'VALUE'								,
      			  p_token1_value		=>	'project_id'
  			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (nvl(p_allocation_in_rec_out.k_line_id, -99) <> nvl(l_allocation_row.k_line_id, -99)) 		   AND
      ((nvl(l_allocation_row.created_in_version, -99) <> nvl(l_version, -99))                              OR
       ((nvl(l_allocation_row.agreement_version, 0) <> 0) AND (nvl(l_allocation_row.pa_flag, 'N') = 'N'))) THEN

      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			  p_msg_name			=>	'OKE_API_NO_UPDATE'						,
      			  p_token1			=>	'VALUE'								,
      			  p_token1_value		=>	'k_line_id'
  			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF p_allocation_in_rec_out.start_date_active = OKE_API.G_MISS_DATE THEN
      p_allocation_in_rec_out.start_date_active := l_allocation_row.start_date_active;
   END IF;

   IF (nvl(l_allocation_row.agreement_version, 0) <> 0) AND
      (nvl(to_char(p_allocation_in_rec_out.start_date_active, 'YYYYMMDD'), '19000101') <> nvl(to_char(l_allocation_row.start_date_active, 'YYYYMMDD'), '19000101')) THEN

      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			  p_msg_name			=>	'OKE_API_NO_UPDATE'						,
      			  p_token1			=>	'VALUE'								,
      			  p_token1_value		=>	'start_date_active'
  			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF (p_allocation_in_rec_out.amount = OKE_API.G_MISS_NUM)		THEN
      p_allocation_in_rec_out.amount := l_allocation_row.amount;
   END IF;

   --
   -- Check if agreement exists
   --
/*
   IF (nvl(l_allocation_row.agreement_version, 0) <> 0) THEN

      IF (nvl(l_allocation_row.project_id, -99) <> nvl(p_allocation_in_rec_out.project_id, -99)) THEN

         l_error_value := 'Project';

      ELSIF (nvl(l_allocation_row.task_id, -99) <> nvl(p_allocation_in_rec_out.task_id, -99)) THEN

         l_error_value := 'Task';

      ELSIF (l_allocation_row.start_date_active <> p_allocation_in_rec_out.start_date_active) THEN

         l_error_value := 'Start date active';

      END IF;

      IF (l_error_value is not null) THEN

          OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			      p_msg_name			=>	'OKE_NO_FUND_CHANGE'						,
      			      p_token1				=>	'FIELD'								,
      			      p_token1_value			=>	l_error_value
  			    );

     	  RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

   END IF;
 */
   IF p_allocation_in_rec_out.funding_status = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.funding_status := l_allocation_row.funding_status;
   END IF;

   IF p_allocation_in_rec_out.fund_type = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.fund_type := l_allocation_row.fund_type;
   END IF;

   IF p_allocation_in_rec_out.end_date_active = OKE_API.G_MISS_DATE THEN
      p_allocation_in_rec_out.end_date_active := l_allocation_row.end_date_active;
   END IF;

   IF p_allocation_in_rec_out.fiscal_year = OKE_API.G_MISS_NUM THEN
      p_allocation_in_rec_out.fiscal_year := l_allocation_row.fiscal_year;
   END IF;

   IF (p_allocation_in_rec_out.hard_limit = OKE_API.G_MISS_NUM) THEN
      p_allocation_in_rec_out.hard_limit := l_allocation_row.hard_limit;
   END IF;

   IF p_allocation_in_rec_out.reference1 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.reference1 := l_allocation_row.reference1;
   END IF;

   IF p_allocation_in_rec_out.reference2 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.reference2 := l_allocation_row.reference2;
   END IF;

   IF p_allocation_in_rec_out.reference3 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.reference3 := l_allocation_row.reference3;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute_category = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute_category := l_allocation_row.attribute_category;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute1 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute1 := l_allocation_row.attribute1;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute2 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute2 := l_allocation_row.attribute2;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute3 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute3 := l_allocation_row.attribute3;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute4 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute4 := l_allocation_row.attribute4;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute5 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute5 := l_allocation_row.attribute5;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute6 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute6 := l_allocation_row.attribute6;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute7 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute7 := l_allocation_row.attribute7;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute8 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute8 := l_allocation_row.attribute8;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute9 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute9 := l_allocation_row.attribute9;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute10 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute10 := l_allocation_row.attribute10;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute11 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute11 := l_allocation_row.attribute11;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute12 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute12 := l_allocation_row.attribute12;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute13 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute13 := l_allocation_row.attribute13;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute14 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute14 := l_allocation_row.attribute14;
   END IF;

   IF p_allocation_in_rec_out.oke_attribute15 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.oke_attribute15 := l_allocation_row.attribute15;
   END IF;

   IF p_allocation_in_rec_out.revenue_hard_limit = OKE_API.G_MISS_NUM THEN
      p_allocation_in_rec_out.revenue_hard_limit := l_allocation_row.revenue_hard_limit;
   END IF;

   IF p_allocation_in_rec_out.pa_attribute_category = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.pa_attribute_category := l_allocation_row.pa_attribute_category;
   END IF;

   IF p_allocation_in_rec_out.pa_attribute1 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.pa_attribute1 := l_allocation_row.pa_attribute1;
   END IF;

   IF p_allocation_in_rec_out.pa_attribute2 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.pa_attribute2 := l_allocation_row.pa_attribute2;
   END IF;

   IF p_allocation_in_rec_out.pa_attribute3 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.pa_attribute3 := l_allocation_row.pa_attribute3;
   END IF;

   IF p_allocation_in_rec_out.pa_attribute4 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.pa_attribute4 := l_allocation_row.pa_attribute4;
   END IF;

   IF p_allocation_in_rec_out.pa_attribute5 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.pa_attribute5 := l_allocation_row.pa_attribute5;
   END IF;

   IF p_allocation_in_rec_out.pa_attribute6 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.pa_attribute6 := l_allocation_row.pa_attribute6;
   END IF;

   IF p_allocation_in_rec_out.pa_attribute7 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.pa_attribute7 := l_allocation_row.pa_attribute7;
   END IF;

   IF p_allocation_in_rec_out.pa_attribute8 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.pa_attribute8 := l_allocation_row.pa_attribute8;
   END IF;

   IF p_allocation_in_rec_out.pa_attribute9 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.pa_attribute9 := l_allocation_row.pa_attribute9;
   END IF;

   IF p_allocation_in_rec_out.pa_attribute10 = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.pa_attribute10 := l_allocation_row.pa_attribute10;
   END IF;

   IF p_allocation_in_rec_out.funding_category = OKE_API.G_MISS_CHAR THEN
      p_allocation_in_rec_out.funding_category := l_allocation_row.funding_category;
   END IF;

   IF (nvl(l_allocation_row.agreement_version, 0) <> 0) AND
      (nvl(p_allocation_in_rec_out.funding_category, '-99') <> l_allocation_row.funding_category) THEN

      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      			  p_msg_name			=>	'OKE_API_NO_UPDATE'						,
      			  p_token1			=>	'VALUE'								,
      			  p_token1_value		=>	'funding_category'
  			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --p_conversion_rate := l_allocation_row.pa_conversion_rate;
   p_previous_amount := l_allocation_row.previous_amount;

END validate_populate_rec;


--
-- Procedure: validate_attributes
--
-- Description: This procedure is used to validate allocation record attributes
--
--

PROCEDURE validate_attributes(p_allocation_in_rec	ALLOCATION_REC_IN_TYPE) is
   l_return_status	VARCHAR2(1);
BEGIN

   --
   -- Funding_Source_Id
   --

   validate_funding_source_id(p_funding_source_id	=>	p_allocation_in_rec.funding_source_id	,
   			      p_return_status		=>	l_return_status
   		             );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Object Id
   --

   validate_object_id(p_object_id		=>	p_allocation_in_rec.object_id		,
   		      p_funding_source_id 	=>	p_allocation_in_rec.funding_source_id	,
   		      p_return_status		=>	l_return_status
   		     );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Amount
   --

   validate_amount(p_amount		=>	p_allocation_in_rec.amount	,
   		   p_return_status	=>	l_return_status
   		  );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- K_Line_Id
   --

   validate_k_line_id(p_k_line_id		=>	p_allocation_in_rec.k_line_id		,
   		      p_project_id		=>	p_allocation_in_rec.project_id		,
   		      p_fund_allocation_id	=>	p_allocation_in_rec.fund_allocation_id	,
   		      p_return_status		=>	l_return_status
   		     );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Project_id
   --

   validate_project_id(p_project_id		=>	p_allocation_in_rec.project_id		,
   		       p_k_line_id		=>	p_allocation_in_rec.k_line_id		,
   		       p_funding_source_id	=>	p_allocation_in_rec.funding_source_id	,
   		       p_object_id		=>	p_allocation_in_rec.object_id		,
   		       p_return_status		=>	l_return_status
   		      );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Task_id
   --

   validate_task_id(p_task_id		=>	p_allocation_in_rec.task_id	,
   		    p_return_status	=>	l_return_status
   		      );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Fund_type
   --

   validate_fund_type(p_fund_type		=>	p_allocation_in_rec.fund_type	,
   		      p_return_status		=>	l_return_status
   		      );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Funding_status
   --

   validate_funding_status(p_funding_status		=>	p_allocation_in_rec.funding_status	,
   		      	   p_return_status		=>	l_return_status
   		          );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   -- Conversion_type
   validate_conversion_type(p_conversion_type		=>	p_allocation_in_rec.pa_conversion_type	,
   		      	    p_return_status		=>	l_return_status
   		          );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Funding_category
   --

   validate_funding_category(p_funding_category		=>	p_allocation_in_rec.funding_category	,
   		      	     p_return_status		=>	l_return_status
   		            );

   IF (l_return_status <> OKE_API.G_RET_STS_SUCCESS) THEN

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

END validate_attributes;


--
-- Procedure: validate_record
--
-- Description: This procedure is used to validate allocation record
--
--

PROCEDURE validate_record(p_allocation_in_rec	IN OUT NOCOPY	ALLOCATION_REC_IN_TYPE	,
			  p_validation_flag			VARCHAR2		,
			  p_flag				VARCHAR2
			 -- p_conversion_rate	OUT NOCOPY	NUMBER
			 ) is

   l_return_status	VARCHAR2(1);
   l_source_currency	VARCHAR2(15);
   l_projfunc_currency	VARCHAR2(15);
   l_type		VARCHAR2(20);

BEGIN

   --
   -- Start and End date range
   --

   OKE_FUNDING_UTIL_PKG.validate_start_end_date(x_start_date		=>	p_allocation_in_rec.start_date_active	,
   				   	        x_end_date		=>    	p_allocation_in_rec.end_date_active	,
   				                x_return_status		=>      l_return_status
   				   	       );

   IF (l_return_status = 'N') THEN

      OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			  p_msg_name		=>	'OKE_INVALID_EFFDATE_PAIR'
     			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   --
   -- Validate if date range within source date range
   --

   IF (p_validation_flag = OKE_API.G_TRUE) THEN

       -- Start date
       -- bug 3345170
   /*
       OKE_FUNDING_UTIL_PKG.validate_alloc_source_date
   			    (x_start_end		=>	'START'					,
   			     x_funding_source_id	=>	p_allocation_in_rec.funding_source_id	,
   		  	     x_date			=>	p_allocation_in_rec.start_date_active	,
   		  	     x_return_status		=>	l_return_status
   		  	    );

       IF (l_return_status = 'N') THEN

          OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
      			      p_msg_name		=>	'OKE_FUND_INVALID_PTY_DATE'	,
      			      p_token1			=>	'EFFECTIVE_DATE'		,
      			      p_token1_value		=>	'OKE_EFFECTIVE_FROM_PROMPT'	,
      			      p_token1_translate	=>	OKE_API.G_TRUE			,
      			      p_token2			=>	'OPERATOR'			,
      			      p_token2_value		=>	'OKE_GREATER_PROMPT'		,
      			      p_token2_translate	=>	OKE_API.G_TRUE			,
      			      p_token3			=>	'DATE_SOURCE'			,
      			      p_token3_value		=>	'OKE_FUNDING_SOURCE_PROMPT'	,
      			      p_token3_translate	=>	OKE_API.G_TRUE
      			     );

          RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

       -- End date

       OKE_FUNDING_UTIL_PKG.validate_alloc_source_date
   			(x_start_end		=>	'END'					,
   			 x_funding_source_id	=>	p_allocation_in_rec.funding_source_id	,
   		  	 x_date			=>	p_allocation_in_rec.end_date_active	,
   		  	 x_return_status	=>	l_return_status
   		  	);

       IF (l_return_status = 'N') THEN

          OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
      			      p_msg_name		=>	'OKE_FUND_INVALID_PTY_DATE'	,
      			      p_token1			=>	'EFFECTIVE_DATE'		,
      			      p_token1_value		=>	'OKE_EFFECTIVE_TO_PROMPT'	,
      			      p_token1_translate	=>	OKE_API.G_TRUE			,
      			      p_token2			=>	'OPERATOR'			,
      			      p_token2_value		=>	'OKE_EARLIER_PROMPT'		,
      			      p_token2_translate	=>	OKE_API.G_TRUE			,
      			      p_token3			=>	'DATE_SOURCE'			,
      			      p_token3_value		=>	'OKE_FUNDING_SOURCE_PROMPT'	,
      			      p_token3_translate	=>	OKE_API.G_TRUE
      			     );

          RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;
   */
       --
       -- Validate if enough fund amount to be allocated
       --

       --oke_debug.debug('validating if enough funding amount for funding allocation');
       --dbms_output.put_line('validating if enough funding amount for funding allocation');

       OKE_FUNDING_UTIL_PKG.validate_alloc_source_amount
   			(x_source_id		=>	p_allocation_in_rec.funding_source_id	,
   			 x_allocation_id	=>      p_allocation_in_rec.fund_allocation_id	,
   		  	 x_amount		=>	p_allocation_in_rec.amount		,
   		  	 x_return_status	=>	l_return_status
   		  	);

      IF (l_return_status = 'N') THEN

         OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			     p_msg_name		=>	'OKE_FUND_AMT_EXCEED'
     			    );

         RAISE G_EXCEPTION_HALT_VALIDATION;

      ELSIF (l_return_status = 'E') THEN

         OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			     p_msg_name		=>	'OKE_NEGATIVE_ALLOCATION_SUM'
     			    );

         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

      --
      -- Validate if enough limit amount to be allocated
      --

      --oke_debug.debug('validating if enough hard limit to be allocated');
      --dbms_output.put_line('validating if enough hard limit to be allocated');

      OKE_FUNDING_UTIL_PKG.validate_alloc_source_limit
   			(x_source_id		=>	p_allocation_in_rec.funding_source_id		,
   			 x_allocation_id	=>      p_allocation_in_rec.fund_allocation_id		,
   		  	 x_amount		=>	nvl(p_allocation_in_rec.hard_limit, 0)		,
   		  	 x_revenue_amount	=>	nvl(p_allocation_in_rec.revenue_hard_limit, 0)	,
   		  	 x_type			=>	l_type						,
   		  	 x_return_status	=>	l_return_status
   		  	);

      IF (l_return_status = 'N') THEN

      	  IF (l_type = 'INVOICE') THEN

             OKE_API.set_message(p_app_name		=> 	'OKE'					,
      			         p_msg_name		=>	'OKE_HARD_LIMIT_EXCEED'
     			       );

     	  ELSE

             OKE_API.set_message(p_app_name		=> 	'OKE'					,
      			         p_msg_name		=>	'OKE_REV_LIMIT_EXCEED'
     			       );

     	  END IF;

          RAISE G_EXCEPTION_HALT_VALIDATION;

      ELSIF (l_return_status = 'E') THEN

          IF (l_type = 'INVOICE') THEN

             OKE_API.set_message(p_app_name		=> 	'OKE'						,
      			         p_msg_name		=>	'OKE_NEGATIVE_HARD_LIMIT_SUM'
      			        );

      	  ELSE

             OKE_API.set_message(p_app_name		=> 	'OKE'						,
      			         p_msg_name		=>	'OKE_NEGATIVE_REV_LIMIT_SUM'
      			        );

      	  END IF;

          RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

   END IF;

   --
   -- Validate the combination of project_id and task_id
   --

   validate_project_task(p_project_id		=>	p_allocation_in_rec.project_id	,
   			 p_task_id		=>	p_allocation_in_rec.task_id
   			);

   --
   -- Validate the combination of object_id and k_line_id
   --

   validate_header_line(p_object_id		=>	p_allocation_in_rec.object_id	,
   			p_k_line_id		=>	p_allocation_in_rec.k_line_id
   		       );

   --
   -- Validate PA conversion
   --

   IF (p_allocation_in_rec.project_id is not null) THEN

      l_source_currency := get_source_currency(p_allocation_in_rec.funding_source_id);
      get_proj_info(p_project_id		=>	p_allocation_in_rec.project_id		,
      		    p_projfunc_currency		=>	l_projfunc_currency
      		    );

      IF (l_source_currency = l_projfunc_currency) THEN

         IF (p_allocation_in_rec.pa_conversion_type is not null) THEN

              OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			          p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			          p_token1		=>	'VALUE'				,
      			          p_token1_value	=>	'pa_conversion_type'
     			          );

              RAISE G_EXCEPTION_HALT_VALIDATION;

         ELSIF (p_allocation_in_rec.pa_conversion_date is not null) THEN

              OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			          p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			          p_token1		=>	'VALUE'				,
      			          p_token1_value	=>	'pa_conversion_date'
     			         );

              RAISE G_EXCEPTION_HALT_VALIDATION;

         ELSIF (p_allocation_in_rec.pa_conversion_rate is not null) THEN

              OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			          p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			          p_token1		=>	'VALUE'				,
      			          p_token1_value	=>	'pa_conversion_rate'
     			         );

              RAISE G_EXCEPTION_HALT_VALIDATION;

         END IF;

      ELSIF (p_allocation_in_rec.pa_conversion_type is not null) AND
            (p_allocation_in_rec.pa_conversion_date is not null) THEN

         IF (upper(p_allocation_in_rec.pa_conversion_type) <> 'USER') THEN

            IF (p_allocation_in_rec.pa_conversion_rate is null) THEN

               IF (nvl(p_flag, 'N') = 'Y') THEN

                   OKE_FUNDING_UTIL_PKG.get_conversion_rate(x_from_currency		=>	l_source_currency			,
           				                    x_to_currency		=>	l_projfunc_currency			,
           				                    x_conversion_type		=>      p_allocation_in_rec.pa_conversion_type	,
           				                    x_conversion_date		=>      p_allocation_in_rec.pa_conversion_date	,
           				    	            x_conversion_rate		=>	p_allocation_in_rec.pa_conversion_rate	,
           				                    x_return_status		=>	l_return_status
           			                           );

                   IF (l_return_status = 'N') THEN

                      OKE_API.set_message(p_app_name			=> 	G_APP_NAME							,
      		                          p_msg_name			=>	'OKE_FUND_NO_RATE'
  			                 );

                      RAISE G_EXCEPTION_HALT_VALIDATION;

                   END IF;

                END IF;

            ELSIF (nvl(p_flag, 'N') = 'Y') THEN

               OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			           p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			           p_token1		=>	'VALUE'				,
      			           p_token1_value	=>	'pa_conversion_rate'
     			          );

               RAISE G_EXCEPTION_HALT_VALIDATION;

            END IF;

         END IF;

      ELSIF (nvl(upper(p_allocation_in_rec.pa_conversion_type), '-99') <> 'USER') THEN

      	 IF (p_allocation_in_rec.pa_conversion_rate is not null) THEN

            OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			        p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			        p_token1		=>	'VALUE'				,
      			        p_token1_value		=>	'pa_conversion_rate'
     			       );

            RAISE G_EXCEPTION_HALT_VALIDATION;

          END IF;

      END IF;

   ELSIF (p_allocation_in_rec.pa_conversion_type is not null) THEN

      OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			  p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			  p_token1		=>	'VALUE'				,
      			  p_token1_value	=>	'pa_conversion_type'
     			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   ELSIF (p_allocation_in_rec.pa_conversion_date is not null) THEN

      OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			  p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			  p_token1		=>	'VALUE'				,
      			  p_token1_value	=>	'pa_conversion_date'
     			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   ELSIF (p_allocation_in_rec.pa_conversion_rate is not null) THEN

      OKE_API.set_message(p_app_name		=> 	'OKE'				,
      			  p_msg_name		=>	'OKE_API_INVALID_VALUE'		,
      			  p_token1		=>	'VALUE'				,
      			  p_token1_value	=>	'pa_conversion_rate'
     			 );

      RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

END validate_record;


--
-- Public Procedures and Funtions
--

--
-- Procedure add_allocation
--
-- Description: This procedure is used to insert record in OKE_K_FUND_ALLOCATIONS table
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			OKE_FUNDINGALLOCATION_PVT.insert_row
--			null_allocation_out
--			validate_attributes
--			validate_record
--

PROCEDURE add_allocation(p_api_version			IN		NUMBER							,
   			 p_init_msg_list		IN		VARCHAR2 := OKE_API.G_FALSE				,
   			 p_commit			IN		VARCHAR2 := OKE_API.G_FALSE				,
   			 p_msg_count			OUT NOCOPY	NUMBER							,
   			 p_msg_data			OUT NOCOPY	VARCHAR2						,
			 p_allocation_in_rec		IN		ALLOCATION_REC_IN_TYPE					,
		         p_allocation_out_rec		OUT NOCOPY	ALLOCATION_REC_OUT_TYPE					,
		         p_validation_flag		IN		VARCHAR2 := OKE_API.G_TRUE				,
		         p_return_status		OUT NOCOPY	VARCHAR2
 			) is

   l_return_status			VARCHAR2(1);
   l_rowid				VARCHAR2(30);
   l_fund_allocation_id			NUMBER;
   l_allocation_in_rec			ALLOCATION_REC_IN_TYPE;
   l_api_name		CONSTANT	VARCHAR2(30) := 'add_allocation';
   --l_rate				NUMBER;

BEGIN

   --dbms_output.put_line('entering oke_allocation_pvt.add_allocation');
   --oke_debug.debug('entering oke_allocation_pvt.add_allocation');

   p_return_status			   := OKE_API.G_RET_STS_SUCCESS;
   p_allocation_out_rec.return_status	   := OKE_API.G_RET_STS_SUCCESS;

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

   --dbms_output.put_line('set default value as null for all fields');
   --oke_debug.debug('set default value as null for all fields');

   l_allocation_in_rec := null_allocation_out(p_allocation_in_rec	=> 	p_allocation_in_rec);

   --
   -- Validate Attributes
   --

   --dbms_output.put_line('validate record attributes');
   --oke_debug.debug('validate record attributes');

   validate_attributes(p_allocation_in_rec		=>	l_allocation_in_rec);

   --
   -- Validate record
   --

   --dbms_output.put_line('validate record');
   --oke_debug.debug('validate record');

   validate_record(p_allocation_in_rec		=>	l_allocation_in_rec		,
   		   p_validation_flag		=>	p_validation_flag		,
   		   p_flag			=>	'Y'
  		   --p_conversion_rate		=>	l_rate
   		  );

   l_fund_allocation_id 		   := get_fund_allocation_id;
   p_allocation_out_rec.fund_allocation_id := l_fund_allocation_id;

   --dbms_output.put_line('calling oke_fundingallocation_pvt.insert_row from oke_allocation_pvt');
   --oke_debug.debug('calling oke_fundingallocation_pvt.insert_row from oke_allocation_pvt');

   OKE_FUNDINGALLOCATION_PVT.insert_row(X_Rowid				=>	l_rowid							,
   					X_Fund_Allocation_Id		=>	l_fund_allocation_id					,
 		    		        X_Funding_Source_Id		=>	l_allocation_in_rec.funding_source_id			,
		     			X_Object_Id			=>	l_allocation_in_rec.object_id				,
		    		        X_K_Line_Id			=>	l_allocation_in_rec.k_line_id				,
		     			X_Project_Id			=>	l_allocation_in_rec.project_id				,
		     			X_Task_Id			=>	l_allocation_in_rec.task_id				,
		     	                X_Previous_Amount		=>	0							,
		     			X_Amount			=>	l_allocation_in_rec.amount				,
		     			X_Hard_Limit			=>	l_allocation_in_rec.hard_limit				,
		    			X_Fund_Type			=>	upper(l_allocation_in_rec.fund_type)			,
		     			X_Funding_Status		=>	upper(l_allocation_in_rec.funding_status)		,
		     			X_Fiscal_Year			=>	l_allocation_in_rec.fiscal_year				,
		     			X_Reference1			=>	l_allocation_in_rec.reference1				,
		     			X_Reference2			=>	l_allocation_in_rec.reference2				,
		     			X_Reference3			=>	l_allocation_in_rec.reference3				,
					X_PA_CONVERSION_TYPE		=>	l_allocation_in_rec.PA_CONVERSION_TYPE			,
					X_PA_CONVERSION_DATE		=>	l_allocation_in_rec.PA_CONVERSION_DATE			,
					X_PA_CONVERSION_RATE		=>	l_allocation_in_rec.pa_conversion_rate			,
					X_Insert_Update_Flag		=>	'Y'							,
                     			X_Start_Date_Active		=>	l_allocation_in_rec.start_date_active			,
                     			X_End_Date_Active		=>	l_allocation_in_rec.end_date_active			,
                     			X_Last_Update_Date              =>	sysdate							,
                     			X_Last_Updated_By               =>	L_USERID						,
                    			X_Creation_Date                 =>	sysdate							,
                     			X_Created_By                    =>	L_USERID						,
                     			X_Last_Update_Login             =>	L_LOGINID						,
                     			--X_Attribute_Category            =>	upper(l_allocation_in_rec.oke_attribute_category)	,
                     			X_Attribute_Category            =>	l_allocation_in_rec.oke_attribute_category		,
                     			X_Attribute1                    =>	l_allocation_in_rec.oke_attribute1			,
                     			X_Attribute2                    =>	l_allocation_in_rec.oke_attribute2			,
                     			X_Attribute3                    =>	l_allocation_in_rec.oke_attribute3			,
                     			X_Attribute4                    =>	l_allocation_in_rec.oke_attribute4			,
                     			X_Attribute5                    =>	l_allocation_in_rec.oke_attribute5			,
                     			X_Attribute6                    =>	l_allocation_in_rec.oke_attribute6			,
                     			X_Attribute7                    =>	l_allocation_in_rec.oke_attribute7			,
                     			X_Attribute8                    =>	l_allocation_in_rec.oke_attribute8			,
                     			X_Attribute9                    =>	l_allocation_in_rec.oke_attribute9			,
                     			X_Attribute10                   =>	l_allocation_in_rec.oke_attribute10			,
                     			X_Attribute11                   =>	l_allocation_in_rec.oke_attribute11			,
                     			X_Attribute12                   =>	l_allocation_in_rec.oke_attribute12			,
                     			X_Attribute13                   =>	l_allocation_in_rec.oke_attribute13			,
                     			X_Attribute14                   =>	l_allocation_in_rec.oke_attribute14			,
                     			X_Attribute15                   =>	l_allocation_in_rec.oke_attribute15			,
                     			X_Revenue_Hard_Limit		=>	l_allocation_in_rec.revenue_hard_limit			,
                     			X_Funding_Category		=>      upper(l_allocation_in_rec.funding_category)		,
                     			--X_PA_Attribute_Category         =>	upper(l_allocation_in_rec.pa_attribute_category)	,
                     			X_PA_Attribute_Category         =>	l_allocation_in_rec.pa_attribute_category		,
                     			X_PA_Attribute1                 =>	l_allocation_in_rec.pa_attribute1			,
                     			X_PA_Attribute2                 =>	l_allocation_in_rec.pa_attribute2			,
                     			X_PA_Attribute3                 =>	l_allocation_in_rec.pa_attribute3			,
                     			X_PA_Attribute4                 =>	l_allocation_in_rec.pa_attribute4			,
                     			X_PA_Attribute5                 =>	l_allocation_in_rec.pa_attribute5			,
                     			X_PA_Attribute6                 =>	l_allocation_in_rec.pa_attribute6			,
                     			X_PA_Attribute7                 =>	l_allocation_in_rec.pa_attribute7			,
                     			X_PA_Attribute8                 =>	l_allocation_in_rec.pa_attribute8			,
                     			X_PA_Attribute9                 =>	l_allocation_in_rec.pa_attribute9			,
                     			X_PA_Attribute10                =>	l_allocation_in_rec.pa_attribute10
                     		       );

   --dbms_output.put_line('finished oke_allocation_pvt.add_allocation w/ ' || p_return_status);
   --oke_debug.debug('finished oke_allocation_pvt.add_allocation w/ ' || p_return_status);

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   OKE_API.END_ACTIVITY(x_msg_count	=>	p_msg_count	,
   			x_msg_data      =>	p_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION	THEN
        p_allocation_out_rec.return_status := OKE_API.G_RET_STS_ERROR;
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	p_allocation_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OTHERS THEN
   	p_allocation_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

END add_allocation;


--
-- Procedure update_allocation
--
-- Description: This procedure is used to update record in OKE_K_FUND_ALLOCATIONS table
--
-- Calling subprograms: OKE_API.start_activity
--			OKE_API.end_activity
--			allowable_changes
--			OKE_FUNDINGALLOCATION_PVT.update_allocation
--			validate_fund_allocation_id
--			validate_populate_rec
--			validate_attributes
--			validate_record
--

PROCEDURE update_allocation(p_api_version		IN		NUMBER						,
   			    p_init_msg_list		IN		VARCHAR2 :=OKE_API.G_FALSE			,
   			    p_commit			IN		VARCHAR2 :=OKE_API.G_FALSE			,
   			    p_msg_count			OUT NOCOPY	NUMBER						,
   			    p_msg_data			OUT NOCOPY	VARCHAR2					,
			    p_allocation_in_rec		IN		ALLOCATION_REC_IN_TYPE				,
			    p_allocation_out_rec	OUT NOCOPY	ALLOCATION_REC_OUT_TYPE				,
			    p_validation_flag		IN		VARCHAR2 := OKE_API.G_TRUE			,
			    p_return_status		OUT NOCOPY	VARCHAR2
 			   ) is

   l_api_name		CONSTANT	VARCHAR2(30) := 'update_allocation';
   l_allocation_in_rec			ALLOCATION_REC_IN_TYPE;
   l_return_status			VARCHAR2(1);
   l_rowid				VARCHAR2(30);
 --  l_rate				NUMBER;
 --  l_rate2				NUMBER;
   l_flag				VARCHAR2(1);
   l_version				NUMBER;
   l_previous_amount			NUMBER;

BEGIN

   --dbms_output.put_line('entering oke_allocation_pvt.update_allocation');
   --oke_debug.debug('entering oke_allocation_pvt.update_allocation');

   p_return_status			   := OKE_API.G_RET_STS_SUCCESS;
   p_allocation_out_rec.return_status	   := OKE_API.G_RET_STS_SUCCESS;

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
   -- Validate if fund_allocation_id is valid or not
   --

   --dbms_output.put_line('validate fund_allocation_id');
   --oke_debug.debug('validate fund_allocation_id');

   validate_fund_allocation_id(p_fund_allocation_id	=>	p_allocation_in_rec.fund_allocation_id ,
   			       p_rowid			=>	l_rowid				       ,
   			       p_version		=>	l_version
   			       );

   --
   -- Validate and set the missing value for the fields
   --

   --dbms_output.put_line('validate and populate the record');
   --oke_debug.debug('validate and populate the record');

   validate_populate_rec(p_allocation_in_rec		=>	p_allocation_in_rec	,
			 p_allocation_in_rec_out	=>	l_allocation_in_rec  	,
			 p_previous_amount		=>	l_previous_amount	,
			 --p_conversion_rate		=>	l_rate			,
			 p_flag				=>	l_flag
			);

   --
   -- Validate Attributes
   --

   --dbms_output.put_line('validate allocation attributes');
   --oke_debug.debug('validate allocation attributes');

   validate_attributes(p_allocation_in_rec		=>	l_allocation_in_rec	);

   --
   -- Validate record
   --

   --dbms_output.put_line('validate allocation record');
   --oke_debug.debug('validate allocation record');

   validate_record(p_allocation_in_rec		=>	l_allocation_in_rec		,
   		   p_validation_flag		=>	p_validation_flag		,
   		   p_flag			=>	l_flag
  		 --  p_conversion_rate		=>	l_rate2
   		  );
/*
   IF (l_flag = 'Y') THEN

      l_rate := l_rate2;

   END IF;
*/
   --
   -- Validate if record exists in PA and check changes are allowable or not
   --
/*
   IF (l_version <> 0 ) THEN

      --dbms_output.put_line('calling allowable changes');
      --oke_debug.debug('calling allowable changes');

      allowable_changes(p_fund_allocation_id	=>	l_allocation_in_rec.fund_allocation_id	,
			p_project_id		=>	l_allocation_in_rec.project_id		,
			p_task_id		=>	l_allocation_in_rec.task_id		,
			p_start_date_active	=>	l_allocation_in_rec.start_date_active
		       );

   END IF;
*/
   --
   -- Call OKE_FUNDINGALLOCATION_PVT.update_row
   --

   --dbms_output.put_line('calling oke_fundingallocation_pvt.update_row');
   --oke_debug.debug('calling oke_fundingallocation_pvt.update_row');

   OKE_FUNDINGALLOCATION_PVT.update_row(X_Fund_Allocation_Id		=>	l_allocation_in_rec.fund_allocation_id			,
		       		    	X_Amount			=>	l_allocation_in_rec.amount				,
		       		    	X_Previous_Amount		=>	l_previous_amount					,
		       		    	X_Object_id			=>	l_allocation_in_rec.object_id				,
		       		    	X_k_line_id			=>	l_allocation_in_rec.k_line_id				,
		       		    	X_project_id			=>	l_allocation_in_rec.project_id				,
		       		    	x_task_id			=>	l_allocation_in_rec.task_id				,
		       		    	X_Hard_Limit			=>	l_allocation_in_rec.hard_limit				,
		       		    	X_Fund_Type			=>	upper(l_allocation_in_rec.fund_type)			,
		       		    	X_Funding_Status		=>	upper(l_allocation_in_rec.funding_status)		,
		       		    	X_Fiscal_Year			=>	l_allocation_in_rec.fiscal_year				,
		       		    	X_Reference1			=>	l_allocation_in_rec.reference1				,
		       		    	X_Reference2			=>	l_allocation_in_rec.reference2				,
		       		    	X_Reference3			=>	l_allocation_in_rec.reference3				,
					X_Pa_Conversion_Type		=>	l_allocation_in_rec.pa_conversion_type			,
					X_Pa_Conversion_Date		=>	l_allocation_in_rec.pa_conversion_date			,
					X_Pa_Conversion_Rate		=>	l_allocation_in_rec.pa_conversion_rate			,
					X_Insert_Update_Flag		=>	'Y'							,
                       		    	X_Start_Date_Active		=>	l_allocation_in_rec.start_date_active			,
                       		    	X_End_Date_Active		=>	l_allocation_in_rec.end_date_active			,
                       		    	X_Last_Update_Date              =>	sysdate							,
                       		    	X_Last_Updated_By               =>	L_USERID						,
                       		    	X_Last_Update_Login             =>	L_LOGINID						,
                       		    	--X_Attribute_Category            =>	upper(l_allocation_in_rec.oke_attribute_category)	,
                       		    	X_Attribute_Category            =>	l_allocation_in_rec.oke_attribute_category		,
                       		    	X_Attribute1                    =>	l_allocation_in_rec.oke_attribute1			,
                       		    	X_Attribute2                    =>	l_allocation_in_rec.oke_attribute2			,
                       		    	X_Attribute3                    =>	l_allocation_in_rec.oke_attribute3 			,
                       		    	X_Attribute4                    =>	l_allocation_in_rec.oke_attribute4 			,
                       		    	X_Attribute5                    =>	l_allocation_in_rec.oke_attribute5 			,
                       		    	X_Attribute6                    =>	l_allocation_in_rec.oke_attribute6 			,
                       		    	X_Attribute7                    =>	l_allocation_in_rec.oke_attribute7 			,
                       		    	X_Attribute8                    =>	l_allocation_in_rec.oke_attribute8 			,
                       		    	X_Attribute9                    =>	l_allocation_in_rec.oke_attribute9			,
                       		    	X_Attribute10                   =>	l_allocation_in_rec.oke_attribute10 			,
                       		    	X_Attribute11                   =>	l_allocation_in_rec.oke_attribute11 			,
                       		    	X_Attribute12                   =>	l_allocation_in_rec.oke_attribute12 			,
                       		    	X_Attribute13                   =>	l_allocation_in_rec.oke_attribute13 			,
                       		    	X_Attribute14                   =>	l_allocation_in_rec.oke_attribute14 			,
                       		    	X_Attribute15                   =>	l_allocation_in_rec.oke_attribute15 			,
                       		    	X_Revenue_Hard_Limit		=>	l_allocation_in_rec.revenue_hard_limit			,
                       		    	X_Funding_Category		=>	upper(l_allocation_in_rec.funding_category)		,
                       		    	--X_PA_Attribute_Category         =>	upper(l_allocation_in_rec.pa_attribute_category)	,
                       		    	X_PA_Attribute_Category         =>	l_allocation_in_rec.pa_attribute_category		,
                     			X_PA_Attribute1                 =>	l_allocation_in_rec.pa_attribute1			,
                     			X_PA_Attribute2                 =>	l_allocation_in_rec.pa_attribute2			,
                     			X_PA_Attribute3                 =>	l_allocation_in_rec.pa_attribute3			,
                     			X_PA_Attribute4                 =>	l_allocation_in_rec.pa_attribute4			,
                     			X_PA_Attribute5                 =>	l_allocation_in_rec.pa_attribute5			,
                     			X_PA_Attribute6                 =>	l_allocation_in_rec.pa_attribute6			,
                     			X_PA_Attribute7                 =>	l_allocation_in_rec.pa_attribute7			,
                     			X_PA_Attribute8                 =>	l_allocation_in_rec.pa_attribute8			,
                     			X_PA_Attribute9                 =>	l_allocation_in_rec.pa_attribute9			,
                     			X_PA_Attribute10                =>	l_allocation_in_rec.pa_attribute10
                       		       );

   IF FND_API.to_boolean(p_commit) THEN

      COMMIT WORK;

   END IF;

   --dbms_output.put_line('finished oke_allocation_pvt.update_allocation w/ ' || p_return_status);
   --oke_debug.debug('finished oke_allocation_pvt.update_allocation w/ ' || p_return_status);

   OKE_API.END_ACTIVITY(x_msg_count	=>	p_msg_count	,
   			x_msg_data      =>	p_msg_data
   		       );

EXCEPTION
   WHEN OKE_API.G_EXCEPTION_ERROR OR G_EXCEPTION_HALT_VALIDATION THEN
        p_allocation_out_rec.return_status := OKE_API.G_RET_STS_ERROR;
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   	p_allocation_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OKE_API.G_RET_STS_UNEXP_ERROR'	,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

   WHEN OTHERS THEN
   	p_allocation_out_rec.return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
   	p_return_status := OKE_API.HANDLE_EXCEPTIONS(p_api_name		=>	l_api_name			,
   						     p_pkg_name		=>	G_PKG_NAME			,
   						     p_exc_name		=>	'OTHERS'			,
   						     x_msg_count	=>	p_msg_count			,
   						     x_msg_data		=>	p_msg_data			,
   						     p_api_type		=>	'_PVT'
   						    );

END update_allocation;


--
-- Procedure delete_allocation
--
-- Description: This procedure is used to delete record in OKE_K_FUND_ALLOCATIONS table
--
-- Calling subprograms: OKE_FUNDINGALLOCATION_PVT.delete_row
--			OKE_API.start_activity
--			OKE_API.end_activity
--		        validate_fund_allocation_id
--                      PA_AGREEMENT_PUB.delete_funding
--

PROCEDURE delete_allocation(p_api_version		IN		NUMBER						,
		            p_commit			IN		VARCHAR2 := OKE_API.G_FALSE			,
   			    p_init_msg_list		IN		VARCHAR2 := OKE_API.G_FALSE			,
   			    p_msg_count			OUT NOCOPY	NUMBER						,
   			    p_msg_data			OUT NOCOPY	VARCHAR2					,
			    p_fund_allocation_id	IN		NUMBER						,
			  --  p_agreement_flag		IN		VARCHAR2 := OKE_API.G_FALSE			,
			    p_return_status		OUT NOCOPY	VARCHAR2
			   ) is

   l_api_name		CONSTANT	VARCHAR2(30) := 'delete_allocation';
   l_return_status			VARCHAR2(1);
--   l_agreement_flag			VARCHAR2(1);
   l_rowid				VARCHAR2(30);
   l_version				NUMBER;
--   l_funding_reference			VARCHAR2(25);
--   i					NUMBER := 1;
--   l_org_id				NUMBER;
   l_created_ver			NUMBER;
   l_current_ver			NUMBER;
   l_org_id_vc	        		VARCHAR2(10);

/*
   cursor c_org is
      select org_id
      from   pa_projects_all p,
             oke_k_fund_allocations f
      where  f.project_id = p.project_id
      and    fund_allocation_id = p_fund_allocation_id;
*/

    cursor c_ver is
        select major_version + 1,
               nvl(created_in_version, -99)
        from   okc_k_vers_numbers b,
               oke_k_fund_allocations a
        where  b.chr_id = a.object_id
        and    a.fund_allocation_id = p_fund_allocation_id;

   cursor c_proj_funding(x_length number) is
      select project_funding_id, org_id, pm_funding_reference
      from   pa_project_fundings p,
      	     pa_agreements_all a
      where  p.pm_product_code = G_PRODUCT_CODE
      and    a.agreement_id = p.agreement_id
      and    substr(pm_funding_reference, 1, x_length + 1) = p_fund_allocation_id || '.';

BEGIN

   --dbms_output.put_line('entering oke_allocation_pvt.delete_allocation');
   --oke_debug.debug('entering oke_allocation_pvt.delete_allocation');

   p_return_status			   := OKE_API.G_RET_STS_SUCCESS;

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
   -- Validate if it is a valid fund_allocation_id
   --

   validate_fund_allocation_id(p_fund_allocation_id	=>	p_fund_allocation_id	,
   			       p_rowid			=>	l_rowid			,
  			       p_version		=>	l_version
		 	      );

   --
   -- 7/15/02
   -- Validate if the line can be deleted or not
   --
   OPEN c_ver;
   FETCH c_ver into l_current_ver, l_created_ver;
   CLOSE c_ver;

   IF (l_current_ver <> l_created_ver) THEN

       OKE_API.set_message(p_app_name		=>	G_APP_NAME			,
      			   p_msg_name		=>	'OKE_VER_NO_ALLOCATION_DELETE'
      			  );

       RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;
   --
   -- End 7/15/02
   --

   --
   -- Call OKE_FUNDINGALLOCATION_PVT.delete_row to delete the row
   --

   OKE_FUNDINGALLOCATION_PVT.delete_row(x_rowid		=>	l_rowid);

   --
   -- Delete project_funding lines if they exist in PA;
   --
/*
   IF l_version <> 0 THEN

      OPEN c_org;
      FETCH c_org into l_org_id;
      CLOSE c_org;

   END IF;

   FOR i in 1..l_version LOOP

      l_funding_reference := p_fund_allocation_id || '.' || i;
*/
    l_org_id_vc := oke_utils.org_id;

   FOR l_project_funding IN c_proj_funding(length(p_fund_allocation_id)) LOOP

      -- fnd_client_info.set_org_context(l_project_funding.org_id);
         mo_global.set_policy_context('S',l_project_funding.org_id);

      PA_AGREEMENT_PUB.delete_funding(p_api_version_number		=> 	p_api_version					,
   				      p_commit				=>	OKE_API.G_FALSE					,
   				      p_init_msg_list			=>	OKE_API.G_FALSE					,
   				      p_msg_count			=>	p_msg_count					,
   				      p_msg_data			=>	p_msg_data					,
   				      p_return_status			=>	p_return_status					,
   				      p_pm_product_code			=>	G_PRODUCT_CODE					,
   				      p_pm_funding_reference		=>	l_project_funding.pm_funding_reference		,
   				      p_funding_id			=>	l_project_funding.project_funding_id		,
   				      p_check_y_n			=>	'Y'
   				     );

      IF (p_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

         RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

      ELSIF (p_return_status = OKE_API.G_RET_STS_ERROR) THEN

         RAISE OKE_API.G_EXCEPTION_ERROR;

      END IF;

   END LOOP;
   mo_global.set_policy_context('S',to_number(l_org_id_vc));

   --dbms_output.put_line('finished oke_allocation_pvt.delete_allocation w/ ' || p_return_status);
   --oke_debug.debug('finished oke_allocation_pvt.delete_allocation w/ ' || p_return_status);

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

END delete_allocation;



--
-- Function: get_allocation_tbl
--
-- Description: This function is used to return a initialized ALLOCATION_IN_TBL_TYPE
--
-- Calling subprograms: N/A
--

FUNCTION get_allocation_tbl RETURN ALLOCATION_IN_TBL_TYPE is

   allocation_in_tbl	ALLOCATION_IN_TBL_TYPE;

BEGIN

   return allocation_in_tbl;

END get_allocation_tbl;


end OKE_ALLOCATION_PVT;

/
