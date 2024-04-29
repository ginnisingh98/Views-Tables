--------------------------------------------------------
--  DDL for Package Body OKE_CLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_CLE_PVT" AS
/* $Header: OKEVCLEB.pls 120.1 2005/11/23 14:37:14 ausmani noship $ */

  FUNCTION validate_attributes( p_cle_rec IN  cle_rec_type)
		RETURN VARCHAR2;

  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKE_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKE_CONTRACTS_UNEXPECTED_ERROR';

  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLcode';
  G_VIEW		 CONSTANT	VARCHAR2(200) := 'OKE_K_LINES_V';

  G_EXCEPTION_HALT_VALIDATION	exception;
  l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

-- validation code goes here

  PROCEDURE validate_parent_line_id (
	p_cle_rec IN cle_rec_type,
	x_return_status OUT NOCOPY VARCHAR2
  ) IS

  CURSOR l_csr IS
  SELECT 'x' FROM OKE_K_LINES_V
  WHERE K_LINE_ID = p_cle_rec.PARENT_LINE_ID;

  l_dummy_val VARCHAR2(1) := '?';

  BEGIN

    x_return_status := OKE_API.G_RET_STS_SUCCESS;

    If (p_cle_rec.parent_line_id <> OKE_API.G_MISS_NUM and
  	   p_cle_rec.parent_line_id IS NOT NULL)
    THEN
      Open l_csr;
      Fetch l_csr Into l_dummy_val;
      Close l_csr;

      -- if l_dummy_val still set to default, data was not found
      If (l_dummy_val = '?') Then

  	    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'parent_line_id',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'OKE_K_LINES_V');
	    -- notify caller of an error
         x_return_status := OKE_API.G_RET_STS_ERROR;
      End If;

    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error

        x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_csr%ISOPEN then
	      close l_csr;
        end if;

  End validate_parent_line_id;



  PROCEDURE validate_customer_item_id (
	p_cle_rec IN cle_rec_type,
	x_return_status OUT NOCOPY VARCHAR2
  ) IS

  CURSOR l_csr IS
  select 'x'
  from mtl_customer_items item
  where item.customer_item_id = p_cle_rec.customer_item_id;

  CURSOR get_intent IS
  SELECT BUY_OR_SELL FROM
  OKC_K_HEADERS_B H, OKC_K_LINES_B L
  WHERE L.DNZ_CHR_ID = H.ID
  AND L.ID = p_cle_rec.k_line_id;

  l_intent VARCHAR2(30);
  l_dummy_val VARCHAR2(1) := '?';

  BEGIN

    x_return_status := OKE_API.G_RET_STS_SUCCESS;

    OPEN get_intent;
    FETCH get_intent INTO l_intent;
    CLOSE get_intent;



    If (p_cle_rec.customer_item_id <> OKE_API.G_MISS_NUM and
  	   p_cle_rec.customer_item_id IS NOT NULL)
    THEN


     IF l_intent = 'S' THEN
      Open l_csr;
      Fetch l_csr Into l_dummy_val;
      Close l_csr;

      -- if l_dummy_val still set to default, data was not found
      If (l_dummy_val = '?') Then

  	    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'CUSTOMER_ITEM_ID',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'MTL_CUSTOMER_ITEMS');
	    -- notify caller of an error
         x_return_status := OKE_API.G_RET_STS_ERROR;
      End If;

     ELSE
  		    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'CUSTOMER_ITEM_ID');

	    -- notify caller of an error
         	x_return_status := OKE_API.G_RET_STS_ERROR;

     END IF;

    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error

        x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_csr%ISOPEN then
	      close l_csr;
        end if;

  End validate_customer_item_id;


  PROCEDURE validate_delivery_date (
	p_cle_rec IN cle_rec_type,
	x_return_status OUT NOCOPY VARCHAR2
  ) IS

  CURSOR c_dates IS
  select trunc(start_date)
  from okc_k_lines_b
  where id = p_cle_rec.k_line_id;


  l_start DATE;

  BEGIN

   x_return_status := OKE_API.G_RET_STS_SUCCESS;

   OPEN c_dates;
   FETCH c_dates INTO l_start;
   CLOSE c_dates;


    IF (p_cle_rec.delivery_date <> OKE_API.G_MISS_DATE and
  	   p_cle_rec.delivery_date IS NOT NULL)
    THEN


     IF (l_start IS NOT NULL AND l_start > p_cle_rec.delivery_date) THEN

  		    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> 'OKE_WRONG_DELIVERY_DATE');


	    -- notify caller of an error
         	x_return_status := OKE_API.G_RET_STS_ERROR;
     END IF;


    END IF;

  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error

        x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End validate_delivery_date;





  PROCEDURE validate_project_id (
	p_cle_rec IN cle_rec_type,
	x_return_status OUT  NOCOPY VARCHAR2
  ) IS

  CURSOR l_csr IS
  SELECT 'x' FROM PA_PROJECTS_ALL
  WHERE PROJECT_ID = p_cle_rec.PROJECT_ID;

  l_dummy_val VARCHAR2(1) := '?';
  l_parent_line_id NUMBER;
  l_header_id NUMBER;

  CURSOR get_line_info IS
  SELECT DNZ_CHR_ID, CLE_ID
  FROM OKC_K_LINES_B
  WHERE ID = p_cle_rec.K_LINE_ID;

  CURSOR get_higher IS
  SELECT KE.PROJECT_ID,KE.TASK_ID
  FROM OKC_ANCESTRYS AN, OKE_K_LINES KE
  WHERE AN.CLE_ID=L_PARENT_LINE_ID AND KE.PROJECT_ID IS NOT NULL
  AND AN.CLE_ID_ASCENDANT = KE.K_LINE_ID
  ORDER BY AN.LEVEL_SEQUENCE DESC;

  CURSOR get_parent IS
  SELECT PROJECT_ID, TASK_ID
  FROM OKE_K_LINES
  WHERE K_LINE_ID = L_PARENT_LINE_ID;


  l_project_id_from 	NUMBER; /* the parent project */
  l_task_id_from 	NUMBER; /* the parent task if any */



  CURSOR RG IS
  SELECT 'x' FROM
  (
  select p.project_id pid,p.segment1
  from pa_projects_all p
  where p.project_id in
  (select to_number(sub_project_id) project_id
  from pa_fin_structures_links_v
  start with parent_project_id = l_project_id_from
  and parent_task_id in (select task_id from pa_tasks where project_id=l_project_id_from
  and top_task_id=nvl(l_task_id_from,top_task_id) )
  connect by parent_project_id = prior sub_project_id)
  union
  select project_id pid,segment1
  from pa_projects_all
  where project_id = l_project_id_from)
  WHERE pid = p_cle_rec.PROJECT_ID;


  CURSOR RG3 IS
  SELECT 'x' FROM
  (
  select project_id pid,segment1
  from pa_projects_all
  where project_id = l_project_id_from)
  WHERE pid = p_cle_rec.PROJECT_ID;

  cursor c_z(x_proj number, x_task number) is /* check is only needed if task is specified as well */
  	select 'x'
	from   pa_fin_structures_links_v
	start with ((parent_project_id =  x_proj ) and parent_task_id in
                   (select task_id from pa_tasks
                    where  project_id = x_proj
                    and    top_task_id = nvl(x_task, top_task_id)))
	connect by parent_project_id = prior sub_project_id;

	l_exist varchar2(10) := '%';


  CURSOR get_header_proj IS
  SELECT project_id
  from oke_k_headers
  where k_header_id = l_header_id;

  BEGIN

    x_return_status := OKE_API.G_RET_STS_SUCCESS;

/* get parent proj task first */

  OPEN get_line_info;
  FETCH get_line_info INTO l_header_id,l_parent_line_id;
  CLOSE get_line_info;

  OPEN get_parent;
  FETCH get_parent INTO l_project_id_from,l_task_id_from;
  CLOSE get_parent;

  IF l_project_id_from IS NULL THEN
   OPEN get_higher;
   FETCH get_higher INTO l_project_id_from,l_task_id_from;
   CLOSE get_higher;
  END IF;

  IF l_project_id_from IS NULL THEN
   open get_header_proj;
   fetch get_header_proj INTO l_project_id_from;
   close get_header_proj;
   l_task_id_from := null;
  END IF;

/* start checks */


    If (p_cle_rec.project_id <> OKE_API.G_MISS_NUM and
  	   p_cle_rec.project_id IS NOT NULL)
    THEN
      If (p_cle_rec.task_id <> OKE_API.G_MISS_NUM and
  	   p_cle_rec.task_id IS NOT NULL) Then
      		open c_z(l_project_id_from,l_task_id_from);
      		fetch c_z into l_exist;
      		close c_z;
     		if (l_exist = '%') then
      			Open RG3;
      			Fetch RG3 Into l_dummy_val;
      			Close RG3;
      			-- if l_dummy_val still set to default, data was not found
      			If (l_dummy_val = '?') Then

 		 	    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'project_id',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'PA_PROJECTS');
	    -- notify caller of an error
         			x_return_status := OKE_API.G_RET_STS_ERROR;
			End If;
		else
	      		Open RG;
      			Fetch RG Into l_dummy_val;
      			Close RG;
      			-- if l_dummy_val still set to default, data was not found
      			If (l_dummy_val = '?') Then

 		 	    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'project_id',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'PA_PROJECTS');
	    -- notify caller of an error
         			x_return_status := OKE_API.G_RET_STS_ERROR;
			End If;
		end if;
      Else
      			Open RG;
      			Fetch RG Into l_dummy_val;
      			Close RG;
      			-- if l_dummy_val still set to default, data was not found
      			If (l_dummy_val = '?') Then

 		 	    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'project_id',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'PA_PROJECTS');
	    -- notify caller of an error
         			x_return_status := OKE_API.G_RET_STS_ERROR;
			End If;

      End If;

    End IF;

  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error

        x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_csr%ISOPEN then
	      close l_csr;
        end if;

  End validate_project_id;

    PROCEDURE validate_task_id (
	p_cle_rec IN cle_rec_type,
	x_return_status OUT NOCOPY VARCHAR2
  ) IS

  CURSOR l_csr IS
  SELECT 'x' FROM PA_TASKS
  WHERE TASK_ID = p_cle_rec.TASK_ID;

  l_project_id NUMBER := p_cle_rec.project_id;
  l_parent_line_id NUMBER;
  l_header_id NUMBER;

  CURSOR get_line_info IS
  SELECT DNZ_CHR_ID, CLE_ID
  FROM OKC_K_LINES_B
  WHERE ID = p_cle_rec.K_LINE_ID;

  CURSOR get_higher IS
  SELECT KE.PROJECT_ID,KE.TASK_ID
  FROM OKC_ANCESTRYS AN, OKE_K_LINES KE
  WHERE AN.CLE_ID=L_PARENT_LINE_ID AND KE.PROJECT_ID IS NOT NULL
  AND AN.CLE_ID_ASCENDANT = KE.K_LINE_ID
  ORDER BY AN.LEVEL_SEQUENCE DESC;

  CURSOR get_parent IS
  SELECT PROJECT_ID, TASK_ID
  FROM OKE_K_LINES
  WHERE K_LINE_ID = L_PARENT_LINE_ID;



  CURSOR get_header_proj IS
  SELECT project_id
  from oke_k_headers
  where k_header_id = l_header_id;

  l_project_id_from 	NUMBER; /* the parent project */
  l_task_id_from 	NUMBER; /* the parent task if any */




CURSOR l_top_task IS
SELECT 'x' FROM (
select task_id, task_number,task_name,description from pa_tasks
where parent_task_id is null
and (( project_id <>l_project_id_from and project_id = l_project_id)
or
( project_id = l_project_id_from and project_id = l_project_id
  and task_id = nvl(l_task_id_from,task_id)))     )
WHERE task_id = p_cle_rec.Task_ID;


  l_dummy_val VARCHAR2(1) := '?';

  BEGIN

    x_return_status := OKE_API.G_RET_STS_SUCCESS;


/* get parent proj task first */

  OPEN get_line_info;
  FETCH get_line_info INTO l_header_id,l_parent_line_id;
  CLOSE get_line_info;

  OPEN get_parent;
  FETCH get_parent INTO l_project_id_from,l_task_id_from;
  CLOSE get_parent;

  IF l_project_id_from IS NULL THEN
   OPEN get_higher;
   FETCH get_higher INTO l_project_id_from,l_task_id_from;
   CLOSE get_higher;
  END IF;

  IF l_project_id_from IS NULL THEN
   open get_header_proj;
   fetch get_header_proj INTO l_project_id_from;
   close get_header_proj;
   l_task_id_from := null;
  END IF;

/* start checks */


    If (p_cle_rec.task_id <> OKE_API.G_MISS_NUM and
  	   p_cle_rec.task_id IS NOT NULL)
    THEN



    If (p_cle_rec.project_id = OKE_API.G_MISS_NUM OR
	p_cle_rec.project_id IS NULL) THEN

  		    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'TASK_ID');
	    -- notify caller of an error
         	x_return_status := OKE_API.G_RET_STS_ERROR;

    End IF;


      Open l_top_task;
      Fetch l_top_task Into l_dummy_val;
      Close l_top_task;

      -- if l_dummy_val still set to default, data was not found
      If (l_dummy_val = '?') Then

  	    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'task_id',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'PA_TASKS');
	    -- notify caller of an error
         x_return_status := OKE_API.G_RET_STS_ERROR;
      End If;

    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error

        x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_csr%ISOPEN then
	      close l_csr;
        end if;

  End validate_task_id;



    PROCEDURE validate_inventory_item_id (
	p_cle_rec IN cle_rec_type,
	x_return_status OUT NOCOPY VARCHAR2
  ) IS

  l_dummy_val VARCHAR2(1) := '?';
  l_org NUMBER;
  l_lse_id NUMBER;

  CURSOR get_org IS
  SELECT INV_ORGANIZATION_ID FROM
  OKC_K_HEADERS_B H,OKC_K_LINES_B L
  WHERE H.ID = L.DNZ_CHR_ID
  AND L.ID = p_cle_rec.k_line_id;

  CURSOR get_lse_id IS
  SELECT lse_id from okc_k_lines_b
  WHERE ID = p_cle_rec.k_line_id;

  CURSOR l_csr IS
  SELECT 'x' FROM OKE_SYSTEM_ITEMS_V
  WHERE ORGANIZATION_ID = l_org
  AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE - 1)
  AND NVL(END_DATE_ACTIVE, SYSDATE + 1) AND STATUS = 'A'
  AND ID1 = p_cle_rec.inventory_item_id;


  CURSOR lnsrc IS
    SELECT jo.object_code
    ,      jo.from_table
    ,      jo.where_clause
    ,      jo.order_by_clause
    ,      jo.name
    FROM   okc_line_style_sources_v ls
    ,      jtf_objects_vl jo
    WHERE  ls.lse_id = l_lse_id
    AND    jo.object_code = ls.jtot_object_code
    AND sysdate BETWEEN start_date
                    AND nvl(end_date,sysdate + 1);

  lnsrcrec  lnsrc%rowtype;

  BEGIN

    x_return_status := OKE_API.G_RET_STS_SUCCESS;

    OPEN get_org;
    FETCH get_org INTO l_org;
    CLOSE get_org;

    OPEN get_lse_id;
    FETCH get_lse_id INTO l_lse_id;
    CLOSE get_lse_id;


    If (p_cle_rec.inventory_item_id <> OKE_API.G_MISS_NUM and
  	   p_cle_rec.inventory_item_id IS NOT NULL)
    THEN

        OPEN  lnsrc;
        FETCH lnsrc INTO lnsrcrec;
        CLOSE lnsrc;

        IF (lnsrcrec.Object_Code = 'OKE_ITEMS') THEN

	      Open l_csr;
	      Fetch l_csr Into l_dummy_val;
	      Close l_csr;

  	    -- if l_dummy_val still set to default, data was not found
     	 If (l_dummy_val = '?') Then

  		    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'INVENTORY_ITEM_ID',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'OKE_SYSTEM_ITEMS_V');
	    -- notify caller of an error
         	x_return_status := OKE_API.G_RET_STS_ERROR;
    	 End If;

	ELSE
  		    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'INVENTORY_ITEM_ID');

	    -- notify caller of an error
         	x_return_status := OKE_API.G_RET_STS_ERROR;

	END IF;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error

        x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_csr%ISOPEN then
	      close l_csr;
        end if;

  End validate_inventory_item_id;


  PROCEDURE validate_billing_method_code (
	p_cle_rec IN cle_rec_type,
	x_return_status OUT NOCOPY VARCHAR2
  ) IS

  CURSOR get_header IS
  SELECT DNZ_CHR_ID
  FROM OKC_K_LINES_B
  WHERE ID = p_cle_rec.k_line_id;

  l_header NUMBER;

  CURSOR l_csr IS
  SELECT 'x' FROM OKE_K_BILLING_METHODS
  WHERE BILLING_METHOD_CODE = p_cle_rec.BILLING_METHOD_CODE
  AND K_HEADER_ID = l_header;

  l_dummy_val VARCHAR2(1) := '?';

  BEGIN

    x_return_status := OKE_API.G_RET_STS_SUCCESS;

    OPEN get_header;
    FETCH get_header INTO l_header;
    CLOSE get_header;


    If (p_cle_rec.billing_method_CODE <> OKE_API.G_MISS_CHAR and
  	   p_cle_rec.billing_method_CODE IS NOT NULL)
    THEN
      Open l_csr;
      Fetch l_csr Into l_dummy_val;
      Close l_csr;

      -- if l_dummy_val still set to default, data was not found
      If (l_dummy_val = '?') Then

  	    OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
				p_msg_name	=> g_no_parent_record,
				p_token1	=> g_col_name_token,
				p_token1_value	=> 'billing_method_code',
				p_token2	=> g_child_table_token,
				p_token2_value	=> G_VIEW,
				p_token3	=> g_parent_table_token,
				p_token3_value	=> 'OKE_K_BILLING_METHODS');
	    -- notify caller of an error
         x_return_status := OKE_API.G_RET_STS_ERROR;
      End If;

    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			      p_msg_name	=> g_unexpected_error,
			      p_token1		=> g_sqlcode_token,
			      p_token1_value	=> sqlcode,
			      p_token2		=> g_sqlerrm_token,
			      p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error

        x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_csr%ISOPEN then
	      close l_csr;
        end if;

  End validate_billing_method_code;



  PROCEDURE validate_uom_code (
	p_cle_rec IN cle_rec_type,
	x_return_status OUT NOCOPY VARCHAR2
  ) IS

  CURSOR l_csr1 IS
  SELECT 'x' FROM
  mtl_item_uoms_view
  where inventory_item_id = p_cle_rec.inventory_item_id
  and uom_code = p_cle_rec.uom_code;


  CURSOR l_csr2 IS
  SELECT 'x' FROM
  mtl_units_of_measure_vl
  where uom_code = p_cle_rec.uom_code;


  l_dummy_val VARCHAR2(1) := '?';

  BEGIN

    x_return_status := OKE_API.G_RET_STS_SUCCESS;

    If (p_cle_rec.UOM_CODE <> OKE_API.G_MISS_CHAR and
  	   p_cle_rec.UOM_CODE IS NOT NULL)
    THEN

    IF (p_cle_rec.inventory_item_id <> OKE_API.G_MISS_NUM and
	p_cle_rec.inventory_item_id IS NOT NULL) THEN

      Open l_csr1;
      Fetch l_csr1 Into l_dummy_val;
      Close l_csr1;
    ELSE
      Open l_csr2;
      Fetch l_csr2 Into l_dummy_val;
      Close l_csr2;
    END IF;

      -- if l_dummy_val still set to default, data was not found
      If (l_dummy_val = '?') Then


        IF (p_cle_rec.inventory_item_id <> OKE_API.G_MISS_NUM and
	  p_cle_rec.inventory_item_id IS NOT NULL) THEN

  	    OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
				p_msg_name	=> g_no_parent_record,
				p_token1	=> g_col_name_token,
				p_token1_value	=> 'UOM_CODE',
				p_token2	=> g_child_table_token,
				p_token2_value	=> G_VIEW,
				p_token3	=> g_parent_table_token,
				p_token3_value	=> 'MTL_ITEM_UOMS_VIEW');
	    -- notify caller of an error
         x_return_status := OKE_API.G_RET_STS_ERROR;
        ELSE
  	    OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
				p_msg_name	=> g_no_parent_record,
				p_token1	=> g_col_name_token,
				p_token1_value	=> 'UOM_CODE',
				p_token2	=> g_child_table_token,
				p_token2_value	=> G_VIEW,
				p_token3	=> g_parent_table_token,
				p_token3_value	=> 'MTL_UNITS_OF_MEASURE_VL');
	    -- notify caller of an error
         x_return_status := OKE_API.G_RET_STS_ERROR;
        END IF;
      End If;

    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			      p_msg_name	=> g_unexpected_error,
			      p_token1		=> g_sqlcode_token,
			      p_token1_value	=> sqlcode,
			      p_token2		=> g_sqlerrm_token,
			      p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error

        x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_csr1%ISOPEN then
	      close l_csr1;
        end if;
        if l_csr2%ISOPEN then
	      close l_csr2;
        end if;

  End validate_uom_code;


PROCEDURE validate_priority_code(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS
  l_dummy_val VARCHAR2(1):= '?';
  CURSOR l_csr IS
  SELECT 'x'  FROM OKE_PRIORITY_CODES_VL
  WHERE PRIORITY_CODE = p_cle_rec.priority_code;

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;


  IF (   p_cle_rec.priority_code <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.priority_code IS NOT NULL) THEN

    OPEN l_csr;
    FETCH l_csr INTO l_dummy_val;
    CLOSE l_csr;

   IF (l_dummy_val = '?') THEN
      OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'PRIORITY_CODE',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKE_PRIORITY_CODES_VL');

      x_return_status := OKE_API.G_RET_STS_ERROR;
   END IF;
  End If;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_priority_code;



PROCEDURE validate_country_code(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS
  l_dummy_val VARCHAR2(1):= '?';


  CURSOR l_csr IS
  SELECT 'x'
  FROM FND_TERRITORIES_VL
  WHERE TERRITORY_CODE = p_cle_rec.COUNTRY_OF_ORIGIN_CODE;

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;


  IF (   p_cle_rec.country_of_origin_code <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.country_of_origin_code IS NOT NULL) THEN

    OPEN l_csr;
    FETCH l_csr INTO l_dummy_val;
    CLOSE l_csr;

   IF (l_dummy_val = '?') THEN
      OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'COUNTRY_OF_ORIGIN_CODE',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'FND_TERRITORIES_VL');

      x_return_status := OKE_API.G_RET_STS_ERROR;
   END IF;
  End If;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_country_code;






PROCEDURE validate_progress_payment_rate(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.PROGRESS_PAYMENT_FLAG <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.PROGRESS_PAYMENT_FLAG IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.PROGRESS_PAYMENT_FLAG) IN ('Y')) THEN
     IF (   p_cle_rec.PROGRESS_PAYMENT_RATE = OKE_API.G_MISS_NUM
      OR p_cle_rec.PROGRESS_PAYMENT_RATE IS NULL) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'PROGRESS_PAYMENT_RATE');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
    END IF;

    IF (UPPER(p_cle_rec.PROGRESS_PAYMENT_FLAG) IN ('N')) THEN
     IF (   p_cle_rec.PROGRESS_PAYMENT_RATE <> OKE_API.G_MISS_NUM
      AND p_cle_rec.PROGRESS_PAYMENT_RATE IS NOT NULL) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_INVALID_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'PROGRESS_PAYMENT_RATE');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
    END IF;


  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_progress_payment_rate;



PROCEDURE validate_progress_payment_liq(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.PROGRESS_PAYMENT_FLAG <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.PROGRESS_PAYMENT_FLAG IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.PROGRESS_PAYMENT_FLAG) IN ('Y')) THEN
     IF (   p_cle_rec.PROGRESS_PAYMENT_LIQ_RATE = OKE_API.G_MISS_NUM
      OR p_cle_rec.PROGRESS_PAYMENT_LIQ_RATE IS NULL) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'PROGRESS_PAYMENT_LIQ_RATE');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
    END IF;

    IF (UPPER(p_cle_rec.PROGRESS_PAYMENT_FLAG) IN ('N')) THEN
     IF (   p_cle_rec.PROGRESS_PAYMENT_LIQ_RATE <> OKE_API.G_MISS_NUM
      AND p_cle_rec.PROGRESS_PAYMENT_LIQ_RATE IS NOT NULL) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_INVALID_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'PROGRESS_PAYMENT_LIQ_RATE');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
    END IF;


  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_progress_payment_liq;

PROCEDURE validate_line_liquidation_rate(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.PROGRESS_PAYMENT_FLAG <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.PROGRESS_PAYMENT_FLAG IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.PROGRESS_PAYMENT_FLAG) IN ('N')) THEN
     IF (   p_cle_rec.LINE_LIQUIDATION_RATE <> OKE_API.G_MISS_NUM
      AND p_cle_rec.LINE_LIQUIDATION_RATE IS NOT NULL) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_INVALID_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'LINE_LIQUIDATION_RATE');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
    END IF;


  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_line_liquidation_rate;




PROCEDURE validate_BILLABLE_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.BILLABLE_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.BILLABLE_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.BILLABLE_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'BILLABLE_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_BILLABLE_flag;




PROCEDURE validate_SHIPPABLE_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.SHIPPABLE_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.SHIPPABLE_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.SHIPPABLE_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'SHIPPABLE_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_SHIPPABLE_flag;



PROCEDURE validate_SUBCONTRACTED_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.SUBCONTRACTED_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.SUBCONTRACTED_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.SUBCONTRACTED_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'SUBCONTRACTED_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_SUBCONTRACTED_flag;




PROCEDURE validate_DELIVERY_ORDER_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.DELIVERY_ORDER_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.DELIVERY_ORDER_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.DELIVERY_ORDER_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'DELIVERY_ORDER_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_DELIVERY_ORDER_flag;



PROCEDURE validate_SPLITED_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.SPLITED_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.SPLITED_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.SPLITED_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'SPLITED_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_SPLITED_flag;




PROCEDURE validate_COMPLETED_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.COMPLETED_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.COMPLETED_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.COMPLETED_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'COMPLETED_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_COMPLETED_flag;



PROCEDURE validate_NSP_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.NSP_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.NSP_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.NSP_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'NSP_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_NSP_flag;




PROCEDURE validate_DROP_SHIPPED_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.DROP_SHIPPED_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.DROP_SHIPPED_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.DROP_SHIPPED_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'DROP_SHIPPED_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_DROP_SHIPPED_flag;



PROCEDURE validate_CUSTOMER_APPROVAL_REQ(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.CUSTOMER_APPROVAL_REQ_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.CUSTOMER_APPROVAL_REQ_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.CUSTOMER_APPROVAL_REQ_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'CUSTOMER_APPROVAL_REQ_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_CUSTOMER_APPROVAL_REQ;




PROCEDURE validate_INSPECTION_REQ_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.INSPECTION_REQ_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.INSPECTION_REQ_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.INSPECTION_REQ_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'INSPECTION_REQ_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_INSPECTION_REQ_flag;



PROCEDURE validate_INTERIM_RPT_REQ_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.INTERIM_RPT_REQ_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.INTERIM_RPT_REQ_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.INTERIM_RPT_REQ_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'INTERIM_RPT_REQ_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_INTERIM_RPT_REQ_flag;




PROCEDURE validate_SUBJ_A133_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.SUBJ_A133_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.SUBJ_A133_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.SUBJ_A133_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'SUBJ_A133_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_SUBJ_A133_flag;



PROCEDURE validate_EXPORT_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.EXPORT_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.EXPORT_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.EXPORT_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'EXPORT_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_EXPORT_flag;




PROCEDURE validate_CFE_REQ_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.CFE_REQ_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.CFE_REQ_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.CFE_REQ_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'CFE_REQ_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_CFE_REQ_flag;



PROCEDURE validate_COP_REQUIRED_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.COP_REQUIRED_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.COP_REQUIRED_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.COP_REQUIRED_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'COP_REQUIRED_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_COP_REQUIRED_flag;




PROCEDURE validate_DCAA_AUDIT_REQ_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.DCAA_AUDIT_REQ_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.DCAA_AUDIT_REQ_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.DCAA_AUDIT_REQ_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'DCAA_AUDIT_REQ_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_DCAA_AUDIT_REQ_flag;



PROCEDURE validate_DEFINITIZED_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.DEFINITIZED_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.DEFINITIZED_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.DEFINITIZED_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'DEFINITIZED_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_DEFINITIZED_flag;




PROCEDURE validate_BILL_UNDEFINITIZED(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.BILL_UNDEFINITIZED_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.BILL_UNDEFINITIZED_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.BILL_UNDEFINITIZED_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'BILL_UNDEFINITIZED_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_BILL_UNDEFINITIZED;



PROCEDURE validate_NTE_WARNING_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.NTE_WARNING_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.NTE_WARNING_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.NTE_WARNING_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'NTE_WARNING_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_NTE_WARNING_flag;




PROCEDURE validate_FINANCIAL_CTRL_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.FINANCIAL_CTRL_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.FINANCIAL_CTRL_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.FINANCIAL_CTRL_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'FINANCIAL_CTRL_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_FINANCIAL_CTRL_flag;



PROCEDURE validate_C_SCS_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.C_SCS_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.C_SCS_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.C_SCS_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'C_SCS_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_C_SCS_flag;




PROCEDURE validate_C_SSR_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.C_SSR_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.C_SSR_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.C_SSR_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'C_SSR_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_C_SSR_flag;



PROCEDURE validate_PROGRESS_PAYMENT_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.PROGRESS_PAYMENT_flag <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.PROGRESS_PAYMENT_flag IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.PROGRESS_PAYMENT_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'PROGRESS_PAYMENT_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_PROGRESS_PAYMENT_flag;




PROCEDURE validate_cost_of_money(x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_cle_rec.cost_of_money <> OKE_API.G_MISS_CHAR
     AND p_cle_rec.cost_of_money IS NOT NULL) THEN
    IF (UPPER(p_cle_rec.cost_of_money) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'COST_OF_MONEY');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_COST_OF_MONEY;









  FUNCTION get_rec (
    p_cle_rec                      IN cle_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cle_rec_type IS

    CURSOR cle_pk_csr (p_id                 IN NUMBER) IS
    SELECT 	K_LINE_ID			,
		PARENT_LINE_ID			,
		PROJECT_ID			,
		TASK_ID				,
		BILLING_METHOD_CODE		,
		INVENTORY_ITEM_ID				,
		DELIVERY_ORDER_FLAG		,
	        SPLITED_FLAG			,
		PRIORITY_CODE			,
		CUSTOMER_ITEM_ID		,
		CUSTOMER_ITEM_NUMBER		,
		LINE_QUANTITY			,
		DELIVERY_DATE			,
		PROPOSAL_DUE_DATE		,
		UNIT_PRICE			,
		UOM_CODE			,
		LINE_VALUE			,
		LINE_VALUE_TOTAL		,
		UNDEF_UNIT_PRICE		,
		UNDEF_LINE_VALUE		,
		UNDEF_LINE_VALUE_TOTAL		,
		END_DATE			,
		BILLABLE_FLAG			,
		SHIPPABLE_FLAG			,
		SUBCONTRACTED_FLAG		,
		COMPLETED_FLAG			,
		NSP_FLAG			,
		APP_CODE			,
		AS_OF_DATE			,
		AUTHORITY			,
		COUNTRY_OF_ORIGIN_CODE		,
		DROP_SHIPPED_FLAG		,
		CUSTOMER_APPROVAL_REQ_FLAG	,
		DATE_MATERIAL_REQ		,
		INSPECTION_REQ_FLAG		,
		INTERIM_RPT_REQ_FLAG		,
		SUBJ_A133_FLAG			,
		EXPORT_FLAG			,
		CFE_REQ_FLAG			,
		COP_REQUIRED_FLAG		,
		EXPORT_LICENSE_NUM		,
		EXPORT_LICENSE_RES		,
		COPIES_REQUIRED			,
		CDRL_CATEGORY			,
		DATA_ITEM_NAME			,
		DATA_ITEM_SUBTITLE		,
		DATE_OF_FIRST_SUBMISSION	,
		FREQUENCY			,
		REQUIRING_OFFICE		,
		DCAA_AUDIT_REQ_FLAG		,
		DEFINITIZED_FLAG		,
		COST_OF_MONEY			,
		BILL_UNDEFINITIZED_FLAG		,
		NSN_NUMBER			,
		NTE_WARNING_FLAG		,
		DISCOUNT_FOR_PAYMENT		,
		FINANCIAL_CTRL_FLAG		,
		C_SCS_FLAG			,
		C_SSR_FLAG			,
		PREPAYMENT_AMOUNT		,
		PREPAYMENT_PERCENTAGE		,
		PROGRESS_PAYMENT_FLAG		,
		PROGRESS_PAYMENT_LIQ_RATE	,
		PROGRESS_PAYMENT_RATE		,
		AWARD_FEE			,
		AWARD_FEE_POOL_AMOUNT		,
		BASE_FEE			,
		CEILING_COST				,
		CEILING_PRICE				,
		COST_OVERRUN_SHARE_RATIO		,
		COST_UNDERRUN_SHARE_RATIO		,
		LABOR_COST_INDEX			,
		MATERIAL_COST_INDEX			,
		CUSTOMERS_PERCENT_IN_ORDER	,
		DATE_OF_PRICE_REDETERMIN	,
		ESTIMATED_TOTAL_QUANTITY	,
		FEE_AJT_FORMULA		,
		FINAL_FEE			,
		FINAL_PFT_AJT_FORMULA		,
		FIXED_FEE			,
		FIXED_QUANTITY			,
		INITIAL_FEE			,
		INITIAL_PRICE			,
		LEVEL_OF_EFFORT_HOURS		,
		LINE_LIQUIDATION_RATE		,
		MAXIMUM_FEE			,
		MAXIMUM_QUANTITY		,
		MINIMUM_FEE			,
		MINIMUM_QUANTITY		,
		NUMBER_OF_OPTIONS		,
		REVISED_PRICE			,
		TARGET_COST			,
		TARGET_DATE_DEFINITIZE		,
		TARGET_FEE			,
		TARGET_PRICE			,
		TOTAL_ESTIMATED_COST		,
		CREATED_BY			,
		CREATION_DATE			,
		LAST_UPDATED_BY			,
		LAST_UPDATE_LOGIN		,
		LAST_UPDATE_DATE		,
		COST_OF_SALE_RATE

    FROM OKE_K_LINES
    WHERE OKE_K_LINES.K_LINE_ID = p_id;

    l_cle_pk	cle_pk_csr%ROWTYPE;
    l_cle_rec   cle_rec_type;

  BEGIN
    x_no_data_found := TRUE;

    -- get current database value

    OPEN cle_pk_csr(p_cle_rec.K_LINE_ID);
    FETCH cle_pk_csr INTO l_cle_rec.K_LINE_ID			,
		l_cle_rec.PARENT_LINE_ID			,
		l_cle_rec.PROJECT_ID			,
		l_cle_rec.TASK_ID				,
		l_cle_rec.BILLING_METHOD_CODE		,
		l_cle_rec.INVENTORY_ITEM_ID				,
		l_cle_rec.DELIVERY_ORDER_FLAG			,
                l_cle_rec.SPLITED_FLAG			,
		l_cle_rec.PRIORITY_CODE			,
		l_cle_rec.CUSTOMER_ITEM_ID		,
		l_cle_rec.CUSTOMER_ITEM_NUMBER		,
		l_cle_rec.LINE_QUANTITY			,
		l_cle_rec.DELIVERY_DATE			,
	        l_cle_rec.PROPOSAL_DUE_DATE		,
		l_cle_rec.UNIT_PRICE			,
		l_cle_rec.UOM_CODE			,
		l_cle_rec.LINE_VALUE			,
		l_cle_rec.LINE_VALUE_TOTAL		,
		l_cle_rec.UNDEF_UNIT_PRICE			,
		l_cle_rec.UNDEF_LINE_VALUE			,
		l_cle_rec.UNDEF_LINE_VALUE_TOTAL		,
		l_cle_rec.END_DATE			,
		l_cle_rec.BILLABLE_FLAG			,
		l_cle_rec.SHIPPABLE_FLAG			,
		l_cle_rec.SUBCONTRACTED_FLAG		,
		l_cle_rec.COMPLETED_FLAG			,
		l_cle_rec.NSP_FLAG			,
		l_cle_rec.APP_CODE			,
		l_cle_rec.AS_OF_DATE			,
		l_cle_rec.AUTHORITY			,
		l_cle_rec.COUNTRY_OF_ORIGIN_CODE		,
		l_cle_rec.DROP_SHIPPED_FLAG		,
		l_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG	,
		l_cle_rec.DATE_MATERIAL_REQ		,
		l_cle_rec.INSPECTION_REQ_FLAG		,
		l_cle_rec.INTERIM_RPT_REQ_FLAG		,
		l_cle_rec.SUBJ_A133_FLAG			,
		l_cle_rec.EXPORT_FLAG			,
		l_cle_rec.CFE_REQ_FLAG			,
		l_cle_rec.COP_REQUIRED_FLAG		,
		l_cle_rec.EXPORT_LICENSE_NUM		,
		l_cle_rec.EXPORT_LICENSE_RES		,
		l_cle_rec.COPIES_REQUIRED			,
		l_cle_rec.CDRL_CATEGORY			,
		l_cle_rec.DATA_ITEM_NAME			,
		l_cle_rec.DATA_ITEM_SUBTITLE		,
		l_cle_rec.DATE_OF_FIRST_SUBMISSION	,
		l_cle_rec.FREQUENCY			,
		l_cle_rec.REQUIRING_OFFICE		,
		l_cle_rec.DCAA_AUDIT_REQ_FLAG		,
		l_cle_rec.DEFINITIZED_FLAG		,
		l_cle_rec.COST_OF_MONEY			,
		l_cle_rec.BILL_UNDEFINITIZED_FLAG		,
		l_cle_rec.NSN_NUMBER			,
		l_cle_rec.NTE_WARNING_FLAG		,
		l_cle_rec.DISCOUNT_FOR_PAYMENT		,
		l_cle_rec.FINANCIAL_CTRL_FLAG		,
		l_cle_rec.C_SCS_FLAG			,
		l_cle_rec.C_SSR_FLAG			,
		l_cle_rec.PREPAYMENT_AMOUNT		,
		l_cle_rec.PREPAYMENT_PERCENTAGE		,
		l_cle_rec.PROGRESS_PAYMENT_FLAG		,
		l_cle_rec.PROGRESS_PAYMENT_LIQ_RATE	,
		l_cle_rec.PROGRESS_PAYMENT_RATE		,
		l_cle_rec.AWARD_FEE			,
		l_cle_rec.AWARD_FEE_POOL_AMOUNT		,
		l_cle_rec.BASE_FEE			,
		l_cle_rec.CEILING_COST				,
		l_cle_rec.CEILING_PRICE				,
		l_cle_rec.COST_OVERRUN_SHARE_RATIO		,
		l_cle_rec.COST_UNDERRUN_SHARE_RATIO		,
		l_cle_rec.LABOR_COST_INDEX			,
		l_cle_rec.MATERIAL_COST_INDEX			,
		l_cle_rec.CUSTOMERS_PERCENT_IN_ORDER	,
		l_cle_rec.DATE_OF_PRICE_REDETERMIN	,
		l_cle_rec.ESTIMATED_TOTAL_QUANTITY	,
		l_cle_rec.FEE_AJT_FORMULA		,
		l_cle_rec.FINAL_FEE			,
		l_cle_rec.FINAL_PFT_AJT_FORMULA		,
		l_cle_rec.FIXED_FEE			,
		l_cle_rec.FIXED_QUANTITY			,
		l_cle_rec.INITIAL_FEE			,
		l_cle_rec.INITIAL_PRICE			,
		l_cle_rec.LEVEL_OF_EFFORT_HOURS		,
		l_cle_rec.LINE_LIQUIDATION_RATE		,
		l_cle_rec.MAXIMUM_FEE			,
		l_cle_rec.MAXIMUM_QUANTITY		,
		l_cle_rec.MINIMUM_FEE			,
		l_cle_rec.MINIMUM_QUANTITY		,
		l_cle_rec.NUMBER_OF_OPTIONS		,
		l_cle_rec.REVISED_PRICE			,
		l_cle_rec.TARGET_COST			,
		l_cle_rec.TARGET_DATE_DEFINITIZE		,
		l_cle_rec.TARGET_FEE			,
		l_cle_rec.TARGET_PRICE			,
		l_cle_rec.TOTAL_ESTIMATED_COST		,
		l_cle_rec.CREATED_BY			,
		l_cle_rec.CREATION_DATE			,
		l_cle_rec.LAST_UPDATED_BY			,
		l_cle_rec.LAST_UPDATE_LOGIN		,
		l_cle_rec.LAST_UPDATE_DATE		,
		l_cle_rec.COST_OF_SALE_RATE;

    x_no_data_found := cle_pk_csr%NOTFOUND;

    CLOSE cle_pk_csr;

    RETURN(l_cle_rec);

  END get_rec;

  FUNCTION get_rec (
    p_cle_rec	IN cle_rec_type)RETURN cle_rec_type IS
    l_row_notfound		BOOLEAN := TRUE;

  BEGIN
    RETURN(get_rec(p_cle_rec, l_row_notfound));
  END get_rec;

  FUNCTION null_out_defaults(
	 p_cle_rec	IN cle_rec_type ) RETURN cle_rec_type IS

  l_cle_rec cle_rec_type := p_cle_rec;

  BEGIN


    IF  l_cle_rec.PARENT_LINE_ID = OKE_API.G_MISS_NUM THEN
	l_cle_rec.PARENT_LINE_ID := NULL;
    END IF;

    IF	l_cle_rec.PROJECT_ID = OKE_API.G_MISS_NUM THEN
        l_cle_rec.PROJECT_ID := NULL;
    END IF;

    IF  l_cle_rec.TASK_ID = OKE_API.G_MISS_NUM THEN
      	l_cle_rec.TASK_ID := NULL;
    END IF;

    IF	l_cle_rec.BILLING_METHOD_CODE = OKE_API.G_MISS_CHAR THEN
        l_cle_rec.BILLING_METHOD_CODE := NULL;
    END IF;

    IF	l_cle_rec.INVENTORY_ITEM_ID = OKE_API.G_MISS_NUM THEN
        l_cle_rec.INVENTORY_ITEM_ID := NULL;
    END IF;

    IF	l_cle_rec.DELIVERY_ORDER_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.DELIVERY_ORDER_FLAG := NULL;
    END IF;

    IF	l_cle_rec.SPLITED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.SPLITED_FLAG := NULL;
    END IF;

    IF  l_cle_rec.PRIORITY_CODE	= OKE_API.G_MISS_CHAR THEN
	l_cle_rec.PRIORITY_CODE	:= NULL;
    END IF;

    IF	l_cle_rec.CUSTOMER_ITEM_ID = OKE_API.G_MISS_NUM THEN
	l_cle_rec.CUSTOMER_ITEM_ID := NULL;
    END IF;

    IF	l_cle_rec.CUSTOMER_ITEM_NUMBER = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.CUSTOMER_ITEM_NUMBER := NULL;
    END IF;

    IF	l_cle_rec.LINE_QUANTITY	= OKE_API.G_MISS_NUM THEN
        l_cle_rec.LINE_QUANTITY	:= NULL;
    END IF;

    IF	l_cle_rec.DELIVERY_DATE	= OKE_API.G_MISS_DATE THEN
        l_cle_rec.DELIVERY_DATE	:= NULL;
    END IF;

    IF  l_cle_rec.PROPOSAL_DUE_DATE = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.PROPOSAL_DUE_DATE := NULL;
    END IF;

    IF	l_cle_rec.UNIT_PRICE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.UNIT_PRICE := NULL;
    END IF;

    IF	l_cle_rec.UOM_CODE = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.UOM_CODE := NULL;
    END IF;

    IF  l_cle_rec.LINE_VALUE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.LINE_VALUE := NULL;
    END IF;

    IF  l_cle_rec.LINE_VALUE_TOTAL = OKE_API.G_MISS_NUM THEN
	l_cle_rec.LINE_VALUE_TOTAL := NULL;
    END IF;

    IF	l_cle_rec.UNDEF_UNIT_PRICE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.UNDEF_UNIT_PRICE := NULL;
    END IF;

    IF  l_cle_rec.UNDEF_LINE_VALUE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.UNDEF_LINE_VALUE := NULL;
    END IF;

    IF  l_cle_rec.UNDEF_LINE_VALUE_TOTAL = OKE_API.G_MISS_NUM THEN
	l_cle_rec.UNDEF_LINE_VALUE_TOTAL := NULL;
    END IF;

    IF  l_cle_rec.END_DATE = OKE_API.G_MISS_DATE THEN
	l_cle_rec.END_DATE := NULL;
    END IF;


    IF	l_cle_rec.BILLABLE_FLAG	= OKE_API.G_MISS_CHAR THEN
	l_cle_rec.BILLABLE_FLAG	:= NULL;
    END IF;

    IF	l_cle_rec.SHIPPABLE_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.SHIPPABLE_FLAG := NULL;
    END IF;

    IF	l_cle_rec.SUBCONTRACTED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.SUBCONTRACTED_FLAG := NULL;
    END IF;

    IF	l_cle_rec.COMPLETED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.COMPLETED_FLAG := NULL;
    END IF;

    IF	l_cle_rec.NSP_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.NSP_FLAG := NULL;
    END IF;

    IF	l_cle_rec.APP_CODE = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.APP_CODE := NULL;
    END IF;

    IF	l_cle_rec.AS_OF_DATE = OKE_API.G_MISS_DATE THEN
	l_cle_rec.AS_OF_DATE := NULL;
    END IF;

    IF	l_cle_rec.AUTHORITY = OKE_API.G_MISS_CHAR THEN
        l_cle_rec.AUTHORITY := NULL;
    END IF;

    IF  l_cle_rec.COUNTRY_OF_ORIGIN_CODE = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.COUNTRY_OF_ORIGIN_CODE := NULL;
    END IF;

    IF	l_cle_rec.DROP_SHIPPED_FLAG = OKE_API.G_MISS_CHAR THEN
        l_cle_rec.DROP_SHIPPED_FLAG := NULL;
    END IF;

    IF	l_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG := NULL;
    END IF;

    IF  l_cle_rec.DATE_MATERIAL_REQ = OKE_API.G_MISS_DATE THEN
	l_cle_rec.DATE_MATERIAL_REQ := NULL;
    END IF;

    IF	l_cle_rec.INSPECTION_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.INSPECTION_REQ_FLAG := NULL;
    END IF;

    IF	l_cle_rec.INTERIM_RPT_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.INTERIM_RPT_REQ_FLAG := NULL;
    END IF;


    IF	l_cle_rec.SUBJ_A133_FLAG = OKE_API.G_MISS_CHAR THEN
   	l_cle_rec.SUBJ_A133_FLAG := NULL;
    END IF;

    IF	l_cle_rec.EXPORT_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.EXPORT_FLAG := NULL;
    END IF;

    IF	l_cle_rec.CFE_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.CFE_REQ_FLAG := NULL;
    END IF;

    IF	l_cle_rec.COP_REQUIRED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.COP_REQUIRED_FLAG := NULL;
    END IF;

    IF	l_cle_rec.EXPORT_LICENSE_NUM = OKE_API.G_MISS_CHAR THEN
   	l_cle_rec.EXPORT_LICENSE_NUM := NULL;
    END IF;

    IF	l_cle_rec.EXPORT_LICENSE_RES = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.EXPORT_LICENSE_RES := NULL;
    END IF;

    IF	l_cle_rec.COPIES_REQUIRED = OKE_API.G_MISS_NUM THEN
	l_cle_rec.COPIES_REQUIRED := NULL;
    END IF;

    IF	l_cle_rec.CDRL_CATEGORY = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.CDRL_CATEGORY := NULL;
    END IF;

    IF	l_cle_rec.DATA_ITEM_NAME = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.DATA_ITEM_NAME := NULL;
    END IF;

    IF	l_cle_rec.DATA_ITEM_SUBTITLE = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.DATA_ITEM_SUBTITLE := NULL;
    END IF;

    IF	l_cle_rec.DATE_OF_FIRST_SUBMISSION = OKE_API.G_MISS_DATE THEN
	l_cle_rec.DATE_OF_FIRST_SUBMISSION := NULL;
    END IF;

    IF	l_cle_rec.FREQUENCY = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.FREQUENCY := NULL;
    END IF;

    IF	l_cle_rec.REQUIRING_OFFICE = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.REQUIRING_OFFICE := NULL;
    END IF;

    IF	l_cle_rec.DCAA_AUDIT_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.DCAA_AUDIT_REQ_FLAG := NULL;
    END IF;

    IF	l_cle_rec.DEFINITIZED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.DEFINITIZED_FLAG := NULL;
    END IF;

    IF	l_cle_rec.COST_OF_MONEY = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.COST_OF_MONEY := NULL;
    END IF;

    IF  l_cle_rec.BILL_UNDEFINITIZED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.BILL_UNDEFINITIZED_FLAG := NULL;
    END IF;

    IF	l_cle_rec.NSN_NUMBER = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.NSN_NUMBER := NULL;
    END IF;

    IF	l_cle_rec.NTE_WARNING_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.NTE_WARNING_FLAG := NULL;
    END IF;

    IF	l_cle_rec.DISCOUNT_FOR_PAYMENT = OKE_API.G_MISS_NUM THEN
	l_cle_rec.DISCOUNT_FOR_PAYMENT := NULL;
    END IF;

    IF	l_cle_rec.FINANCIAL_CTRL_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.FINANCIAL_CTRL_FLAG := NULL;
    END IF;

    IF	l_cle_rec.C_SCS_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.C_SCS_FLAG := NULL;
    END IF;


    IF	l_cle_rec.C_SSR_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.C_SSR_FLAG := NULL;
    END IF;

    IF	l_cle_rec.PREPAYMENT_AMOUNT = OKE_API.G_MISS_NUM THEN
	l_cle_rec.PREPAYMENT_AMOUNT := NULL;
    END IF;

    IF	l_cle_rec.PREPAYMENT_PERCENTAGE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.PREPAYMENT_PERCENTAGE := NULL;
    END IF;

    IF	l_cle_rec.PROGRESS_PAYMENT_FLAG = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.PROGRESS_PAYMENT_FLAG := NULL;
    END IF;

    IF	l_cle_rec.PROGRESS_PAYMENT_LIQ_RATE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.PROGRESS_PAYMENT_LIQ_RATE := NULL;
    END IF;

    IF	l_cle_rec.PROGRESS_PAYMENT_RATE	= OKE_API.G_MISS_NUM THEN
	l_cle_rec.PROGRESS_PAYMENT_RATE := NULL;
    END IF;

    IF	l_cle_rec.AWARD_FEE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.AWARD_FEE := NULL;
    END IF;

    IF	l_cle_rec.AWARD_FEE_POOL_AMOUNT = OKE_API.G_MISS_NUM THEN
	l_cle_rec.AWARD_FEE_POOL_AMOUNT := NULL;
    END IF;

    IF	l_cle_rec.BASE_FEE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.BASE_FEE := NULL;
    END IF;

    IF	l_cle_rec.CEILING_COST = OKE_API.G_MISS_NUM THEN
	l_cle_rec.CEILING_COST := NULL;
    END IF;

    IF	l_cle_rec.CEILING_PRICE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.CEILING_PRICE := NULL;
    END IF;

    IF	l_cle_rec.COST_OVERRUN_SHARE_RATIO = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.COST_OVERRUN_SHARE_RATIO := NULL;
    END IF;

    IF	l_cle_rec.COST_UNDERRUN_SHARE_RATIO = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.COST_UNDERRUN_SHARE_RATIO := NULL;
    END IF;

    IF	l_cle_rec.LABOR_COST_INDEX = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.LABOR_COST_INDEX := NULL;
    END IF;

    IF	l_cle_rec.MATERIAL_COST_INDEX = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.MATERIAL_COST_INDEX := NULL;
    END IF;

    IF	l_cle_rec.CUSTOMERS_PERCENT_IN_ORDER = OKE_API.G_MISS_NUM THEN
	l_cle_rec.CUSTOMERS_PERCENT_IN_ORDER := NULL;
    END IF;

    IF	l_cle_rec.DATE_OF_PRICE_REDETERMIN = OKE_API.G_MISS_DATE THEN
	l_cle_rec.DATE_OF_PRICE_REDETERMIN := NULL;
    END IF;

    IF	l_cle_rec.ESTIMATED_TOTAL_QUANTITY = OKE_API.G_MISS_NUM THEN
	l_cle_rec.ESTIMATED_TOTAL_QUANTITY := NULL;
    END IF;

    IF	l_cle_rec.FEE_AJT_FORMULA = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.FEE_AJT_FORMULA := NULL;
    END IF;

    IF	l_cle_rec.FINAL_FEE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.FINAL_FEE := NULL;
    END IF;

    IF	l_cle_rec.FINAL_PFT_AJT_FORMULA = OKE_API.G_MISS_CHAR THEN
	l_cle_rec.FINAL_PFT_AJT_FORMULA := NULL;
    END IF;

    IF	l_cle_rec.FIXED_FEE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.FIXED_FEE := NULL;
    END IF;

    IF	l_cle_rec.FIXED_QUANTITY = OKE_API.G_MISS_NUM THEN
	l_cle_rec.FIXED_QUANTITY := NULL;
    END IF;

    IF	l_cle_rec.INITIAL_FEE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.INITIAL_FEE := NULL;
    END IF;

    IF	l_cle_rec.INITIAL_PRICE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.INITIAL_PRICE := NULL;
    END IF;

    IF	l_cle_rec.LEVEL_OF_EFFORT_HOURS = OKE_API.G_MISS_NUM THEN
	l_cle_rec.LEVEL_OF_EFFORT_HOURS := NULL;
    END IF;

    IF	l_cle_rec.LINE_LIQUIDATION_RATE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.LINE_LIQUIDATION_RATE := NULL;
    END IF;

    IF	l_cle_rec.MAXIMUM_FEE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.MAXIMUM_FEE := NULL;
    END IF;

    IF	l_cle_rec.MAXIMUM_QUANTITY = OKE_API.G_MISS_NUM THEN
	l_cle_rec.MAXIMUM_QUANTITY := NULL;
    END IF;

    IF	l_cle_rec.MINIMUM_FEE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.MINIMUM_FEE := NULL;
    END IF;


    IF	l_cle_rec.MINIMUM_QUANTITY = OKE_API.G_MISS_NUM THEN
	l_cle_rec.MINIMUM_QUANTITY := NULL;
    END IF;

    IF	l_cle_rec.NUMBER_OF_OPTIONS = OKE_API.G_MISS_NUM THEN
	l_cle_rec.NUMBER_OF_OPTIONS := NULL;
    END IF;

    IF	l_cle_rec.REVISED_PRICE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.REVISED_PRICE := NULL;
    END IF;

    IF	l_cle_rec.TARGET_COST = OKE_API.G_MISS_NUM THEN
	l_cle_rec.TARGET_COST := NULL;
    END IF;

    IF	l_cle_rec.TARGET_DATE_DEFINITIZE = OKE_API.G_MISS_DATE THEN
	l_cle_rec.TARGET_DATE_DEFINITIZE := NULL;
    END IF;

    IF	l_cle_rec.TARGET_FEE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.TARGET_FEE := NULL;
    END IF;

    IF	l_cle_rec.TARGET_PRICE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.TARGET_PRICE := NULL;
    END IF;

    IF	l_cle_rec.TOTAL_ESTIMATED_COST = OKE_API.G_MISS_NUM THEN
	l_cle_rec.TOTAL_ESTIMATED_COST := NULL;
    END IF;

    IF	l_cle_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	l_cle_rec.CREATED_BY := NULL;
    END IF;

    IF	l_cle_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	l_cle_rec.CREATION_DATE := NULL;
    END IF;

    IF	l_cle_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	l_cle_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF	l_cle_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	l_cle_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF	l_cle_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	l_cle_rec.LAST_UPDATE_DATE := NULL;
    END IF;

    IF	l_cle_rec.COST_OF_SALE_RATE = OKE_API.G_MISS_NUM THEN
	l_cle_rec.COST_OF_SALE_RATE := NULL;
    END IF;


    RETURN(l_cle_rec);

  END null_out_defaults;

-- validate attributes

  FUNCTION validate_attributes(
    p_cle_rec IN  cle_rec_type
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

  BEGIN
    /* call individual validation procedure */
    validate_parent_line_id(
     	p_cle_rec 	=> p_cle_rec,
        x_return_status	=> l_return_status);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_project_id(
     	p_cle_rec 	=> p_cle_rec,
        x_return_status	=> l_return_status);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_task_id(
     	p_cle_rec 	=> p_cle_rec,
        x_return_status	=> l_return_status);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_inventory_item_id(
     	p_cle_rec 	=> p_cle_rec,
        x_return_status	=> l_return_status);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_customer_item_id(
     	p_cle_rec 	=> p_cle_rec,
        x_return_status	=> l_return_status);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

     validate_billing_method_code(
     	p_cle_rec 	=> p_cle_rec,
        x_return_status	=> l_return_status);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;


    validate_country_code(
     	p_cle_rec 	=> p_cle_rec,
        x_return_status	=> l_return_status);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;


   validate_priority_code(
     	p_cle_rec 	=> p_cle_rec,
        x_return_status	=> l_return_status);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;



   validate_uom_code(
     	p_cle_rec 	=> p_cle_rec,
        x_return_status	=> l_return_status);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;



  validate_progress_payment_liq(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_progress_payment_rate(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_line_liquidation_rate(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;


  validate_billable_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_shippable_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_subcontracted_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_delivery_order_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_splited_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_completed_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_nsp_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_drop_shipped_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_customer_approval_req(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_inspection_req_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_interim_rpt_req_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_subj_a133_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_export_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_cfe_req_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_cop_required_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_dcaa_audit_req_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_definitized_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_bill_undefinitized(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_nte_warning_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_financial_ctrl_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_c_scs_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_c_ssr_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_progress_payment_flag(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_cost_of_money(x_return_status => l_return_status,
				p_cle_rec	=>  p_cle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;






    RETURN(x_return_status);

  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
			      p_msg_name		=> g_unexpected_error,
			      p_token1		=> g_sqlcode_token,
			      p_token1_value	=> sqlcode,
			      p_token2		=> g_sqlerrm_token,
			      p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

	   -- return status to caller
        RETURN(x_return_status);

  END Validate_Attributes;


-- validate record


  PROCEDURE validate_qty_price_value (
	p_cle_rec IN cle_rec_type,
	x_return_status OUT NOCOPY VARCHAR2
  ) IS

  BEGIN
    x_return_status := OKE_API.G_RET_STS_SUCCESS;

    If (p_cle_rec.line_quantity <> OKE_API.G_MISS_NUM and
  	   p_cle_rec.line_quantity IS NOT NULL
	AND p_cle_rec.unit_price <> OKE_API.G_MISS_NUM and
	   p_cle_rec.unit_price IS NOT NULL
	AND p_cle_rec.line_value <> OKE_API.G_MISS_NUM and
	   p_cle_rec.line_value IS NOT NULL)

    THEN

      If (p_cle_rec.line_value <> (p_cle_rec.unit_price * p_cle_rec.line_quantity)) Then
  	    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> 'OKE_LINE_VALUE_MISMATCH');

	    -- notify caller of an error
         x_return_status := OKE_API.G_RET_STS_ERROR;
      End If;

    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error

        x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End validate_qty_price_value;


  FUNCTION validate_record (
    p_cle_rec IN cle_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    RETURN(l_return_status);

  END validate_record;

-- validate row

  PROCEDURE validate_row(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_cle_rec           IN cle_rec_type
  ) IS

    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'B_validate_row';
    l_return_status     VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_cle_rec           cle_rec_type := p_cle_rec;

  BEGIN
    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
					      G_PKG_NAME,
					      p_init_msg_list,
					      l_api_version,
					      p_api_version,
					      '_PVT',
					      x_return_status);
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_cle_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cle_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl                      IN cle_tbl_type
    ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_validate_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cle_tbl.COUNT > 0) THEN
      i := p_cle_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cle_rec                     => p_cle_tbl(i));

		-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	     l_overall_status := x_return_status;
	  End If;
	End If;

        EXIT WHEN (i = p_cle_tbl.LAST);
        i := p_cle_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

-- insert data into oke_k_lines

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_rec                      IN cle_rec_type,
    x_cle_rec                      OUT NOCOPY cle_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_cle_rec                      cle_rec_type;
    l_def_cle_rec                  cle_rec_type;
    lx_cle_rec                     cle_rec_type;

    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cle_rec	IN cle_rec_type
    ) RETURN cle_rec_type IS

      l_cle_rec	cle_rec_type := p_cle_rec;

    BEGIN

      l_cle_rec.CREATION_DATE := SYSDATE;
      l_cle_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cle_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cle_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cle_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cle_rec);

    END fill_who_columns;

    -- Set_Attributes for:OKE_K_LINES


    FUNCTION Set_Attributes (
      p_cle_rec IN  cle_rec_type,
      x_cle_rec OUT NOCOPY cle_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cle_rec := p_cle_rec;
      x_cle_rec.BILLABLE_FLAG		:= UPPER(x_cle_rec.BILLABLE_FLAG);
      x_cle_rec.SHIPPABLE_FLAG		:= UPPER(x_cle_rec.SHIPPABLE_FLAG);
      x_cle_rec.SUBCONTRACTED_FLAG	:= UPPER(x_cle_rec.SUBCONTRACTED_FLAG);
      x_cle_rec.DELIVERY_ORDER_FLAG     := UPPER(x_cle_rec.DELIVERY_ORDER_FLAG);
      x_cle_rec.SPLITED_FLAG		:= UPPER(x_cle_rec.SPLITED_FLAG);
      x_cle_rec.COMPLETED_FLAG		:= UPPER(x_cle_rec.COMPLETED_FLAG);
      x_cle_rec.NSP_FLAG		:= UPPER(x_cle_rec.NSP_FLAG);
      x_cle_rec.DROP_SHIPPED_FLAG	:= UPPER(x_cle_rec.DROP_SHIPPED_FLAG);
      x_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG := UPPER(x_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG);
      x_cle_rec.INSPECTION_REQ_FLAG	:= UPPER(x_cle_rec.INSPECTION_REQ_FLAG);
      x_cle_rec.INTERIM_RPT_REQ_FLAG	:= UPPER(x_cle_rec.INTERIM_RPT_REQ_FLAG);
      x_cle_rec.SUBJ_A133_FLAG	:= UPPER(x_cle_rec.SUBJ_A133_FLAG);
      x_cle_rec.EXPORT_FLAG	:= UPPER(x_cle_rec.EXPORT_FLAG);
      x_cle_rec.CFE_REQ_FLAG	:= UPPER(x_cle_rec.CFE_REQ_FLAG);
      x_cle_rec.COP_REQUIRED_FLAG	:= UPPER(x_cle_rec.COP_REQUIRED_FLAG);
      x_cle_rec.DCAA_AUDIT_REQ_FLAG	:= UPPER(x_cle_rec.DCAA_AUDIT_REQ_FLAG);
      x_cle_rec.DEFINITIZED_FLAG	:= UPPER(x_cle_rec.DEFINITIZED_FLAG);
      x_cle_rec.COST_OF_MONEY		:= UPPER(x_cle_rec.COST_OF_MONEY);
      x_cle_rec.BILL_UNDEFINITIZED_FLAG	:= UPPER(x_cle_rec.BILL_UNDEFINITIZED_FLAG);
      x_cle_rec.NTE_WARNING_FLAG	:= UPPER(x_cle_rec.NTE_WARNING_FLAG);
      x_cle_rec.FINANCIAL_CTRL_FLAG	:= UPPER(x_cle_rec.FINANCIAL_CTRL_FLAG);
      x_cle_rec.C_SCS_FLAG	:= UPPER(x_cle_rec.C_SCS_FLAG);
      x_cle_rec.C_SSR_FLAG	:= UPPER(x_cle_rec.C_SSR_FLAG);
      x_cle_rec.PROGRESS_PAYMENT_FLAG	:= UPPER(x_cle_rec.PROGRESS_PAYMENT_FLAG);

      RETURN(l_return_status);

    END Set_Attributes;

  BEGIN

    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);


    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    l_cle_rec := null_out_defaults(p_cle_rec);

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cle_rec,                        -- IN
      l_def_cle_rec);                   -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_def_cle_rec := fill_who_columns(l_def_cle_rec);


    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cle_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    l_return_status := Validate_Record(l_def_cle_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKE_K_LINES(
                K_LINE_ID			,
		PARENT_LINE_ID			,
		PROJECT_ID			,
		TASK_ID				,
		BILLING_METHOD_CODE		,
		INVENTORY_ITEM_ID				,
		DELIVERY_ORDER_FLAG			,
		SPLITED_FLAG			,
		PRIORITY_CODE			,
		CUSTOMER_ITEM_ID		,
		CUSTOMER_ITEM_NUMBER		,
		LINE_QUANTITY			,
		DELIVERY_DATE			,
		PROPOSAL_DUE_DATE		,
		UNIT_PRICE			,
		UOM_CODE			,
		LINE_VALUE			,
		LINE_VALUE_TOTAL		,
		UNDEF_UNIT_PRICE		,
		UNDEF_LINE_VALUE		,
		UNDEF_LINE_VALUE_TOTAL		,
		END_DATE			,
		BILLABLE_FLAG			,
		SHIPPABLE_FLAG			,
		SUBCONTRACTED_FLAG		,
		COMPLETED_FLAG			,
		NSP_FLAG			,
		APP_CODE			,
		AS_OF_DATE			,
		AUTHORITY			,
		COUNTRY_OF_ORIGIN_CODE		,
		DROP_SHIPPED_FLAG		,
		CUSTOMER_APPROVAL_REQ_FLAG	,
		DATE_MATERIAL_REQ		,
		INSPECTION_REQ_FLAG		,
		INTERIM_RPT_REQ_FLAG		,
		SUBJ_A133_FLAG			,
		EXPORT_FLAG			,
		CFE_REQ_FLAG			,
		COP_REQUIRED_FLAG		,
		EXPORT_LICENSE_NUM		,
		EXPORT_LICENSE_RES		,
		COPIES_REQUIRED			,
		CDRL_CATEGORY			,
		DATA_ITEM_NAME			,
		DATA_ITEM_SUBTITLE		,
		DATE_OF_FIRST_SUBMISSION	,
		FREQUENCY			,
		REQUIRING_OFFICE		,
		DCAA_AUDIT_REQ_FLAG		,
		DEFINITIZED_FLAG		,
		COST_OF_MONEY			,
		BILL_UNDEFINITIZED_FLAG		,
		NSN_NUMBER			,
		NTE_WARNING_FLAG		,
		DISCOUNT_FOR_PAYMENT		,
		FINANCIAL_CTRL_FLAG		,
		C_SCS_FLAG			,
		C_SSR_FLAG			,
		PREPAYMENT_AMOUNT		,
		PREPAYMENT_PERCENTAGE		,
		PROGRESS_PAYMENT_FLAG		,
		PROGRESS_PAYMENT_LIQ_RATE	,
		PROGRESS_PAYMENT_RATE		,
		AWARD_FEE			,
		AWARD_FEE_POOL_AMOUNT		,
		BASE_FEE			,
		CEILING_COST				,
		CEILING_PRICE				,
		COST_OVERRUN_SHARE_RATIO		,
		COST_UNDERRUN_SHARE_RATIO		,
		LABOR_COST_INDEX			,
		MATERIAL_COST_INDEX			,
		CUSTOMERS_PERCENT_IN_ORDER	,
		DATE_OF_PRICE_REDETERMIN	,
		ESTIMATED_TOTAL_QUANTITY	,
		FEE_AJT_FORMULA		,
		FINAL_FEE			,
		FINAL_PFT_AJT_FORMULA		,
		FIXED_FEE			,
		FIXED_QUANTITY			,
		INITIAL_FEE			,
		INITIAL_PRICE			,
		LEVEL_OF_EFFORT_HOURS		,
		LINE_LIQUIDATION_RATE		,
		MAXIMUM_FEE			,
		MAXIMUM_QUANTITY		,
		MINIMUM_FEE			,
		MINIMUM_QUANTITY		,
		NUMBER_OF_OPTIONS		,
		REVISED_PRICE			,
		TARGET_COST			,
		TARGET_DATE_DEFINITIZE		,
		TARGET_FEE			,
		TARGET_PRICE			,
		TOTAL_ESTIMATED_COST		,
		CREATED_BY			,
		CREATION_DATE			,
		LAST_UPDATED_BY			,
		LAST_UPDATE_LOGIN		,
		LAST_UPDATE_DATE		,
		COST_OF_SALE_RATE)
    VALUES(
		l_def_cle_rec.K_LINE_ID			,
		l_def_cle_rec.PARENT_LINE_ID		,
		l_def_cle_rec.PROJECT_ID			,
		l_def_cle_rec.TASK_ID			,
		l_def_cle_rec.BILLING_METHOD_CODE		,
		l_def_cle_rec.INVENTORY_ITEM_ID			,
		l_def_cle_rec.DELIVERY_ORDER_FLAG			,
                l_def_cle_rec.SPLITED_FLAG		,
		l_def_cle_rec.PRIORITY_CODE			,
		l_def_cle_rec.CUSTOMER_ITEM_ID		,
		l_def_cle_rec.CUSTOMER_ITEM_NUMBER	,
		l_def_cle_rec.LINE_QUANTITY			,
		l_def_cle_rec.DELIVERY_DATE			,
		l_def_cle_rec.PROPOSAL_DUE_DATE		,
		l_def_cle_rec.UNIT_PRICE			,
		l_def_cle_rec.UOM_CODE			,
		l_def_cle_rec.LINE_VALUE		,
		l_def_cle_rec.LINE_VALUE_TOTAL		,
		l_def_cle_rec.UNDEF_UNIT_PRICE		,
		l_def_cle_rec.UNDEF_LINE_VALUE		,
		l_def_cle_rec.UNDEF_LINE_VALUE_TOTAL	,
		l_def_cle_rec.END_DATE			,
		l_def_cle_rec.BILLABLE_FLAG			,
		l_def_cle_rec.SHIPPABLE_FLAG		,
		l_def_cle_rec.SUBCONTRACTED_FLAG		,
		l_def_cle_rec.COMPLETED_FLAG		,
		l_def_cle_rec.NSP_FLAG			,
		l_def_cle_rec.APP_CODE			,
		l_def_cle_rec.AS_OF_DATE			,
		l_def_cle_rec.AUTHORITY			,
		l_def_cle_rec.COUNTRY_OF_ORIGIN_CODE	,
		l_def_cle_rec.DROP_SHIPPED_FLAG		,
		l_def_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG	,
		l_def_cle_rec.DATE_MATERIAL_REQ		,
		l_def_cle_rec.INSPECTION_REQ_FLAG		,
		l_def_cle_rec.INTERIM_RPT_REQ_FLAG		,
		l_def_cle_rec.SUBJ_A133_FLAG		,
		l_def_cle_rec.EXPORT_FLAG			,
		l_def_cle_rec.CFE_REQ_FLAG			,
		l_def_cle_rec.COP_REQUIRED_FLAG		,
		l_def_cle_rec.EXPORT_LICENSE_NUM		,
		l_def_cle_rec.EXPORT_LICENSE_RES		,
		l_def_cle_rec.COPIES_REQUIRED		,
		l_def_cle_rec.CDRL_CATEGORY			,
		l_def_cle_rec.DATA_ITEM_NAME		,
		l_def_cle_rec.DATA_ITEM_SUBTITLE		,
		l_def_cle_rec.DATE_OF_FIRST_SUBMISSION	,
		l_def_cle_rec.FREQUENCY			,
		l_def_cle_rec.REQUIRING_OFFICE		,
		l_def_cle_rec.DCAA_AUDIT_REQ_FLAG		,
		l_def_cle_rec.DEFINITIZED_FLAG		,
		l_def_cle_rec.COST_OF_MONEY			,
		l_def_cle_rec.BILL_UNDEFINITIZED_FLAG	,
		l_def_cle_rec.NSN_NUMBER			,
		l_def_cle_rec.NTE_WARNING_FLAG		,
		l_def_cle_rec.DISCOUNT_FOR_PAYMENT		,
		l_def_cle_rec.FINANCIAL_CTRL_FLAG		,
		l_def_cle_rec.C_SCS_FLAG			,
		l_def_cle_rec.C_SSR_FLAG			,
		l_def_cle_rec.PREPAYMENT_AMOUNT		,
		l_def_cle_rec.PREPAYMENT_PERCENTAGE		,
		l_def_cle_rec.PROGRESS_PAYMENT_FLAG		,
		l_def_cle_rec.PROGRESS_PAYMENT_LIQ_RATE	,
		l_def_cle_rec.PROGRESS_PAYMENT_RATE		,
		l_def_cle_rec.AWARD_FEE			,
		l_def_cle_rec.AWARD_FEE_POOL_AMOUNT	,
		l_def_cle_rec.BASE_FEE			,
		l_def_cle_rec.CEILING_COST			,
		l_def_cle_rec.CEILING_PRICE			,
		l_def_cle_rec.COST_OVERRUN_SHARE_RATIO		,
		l_def_cle_rec.COST_UNDERRUN_SHARE_RATIO		,
		l_def_cle_rec.LABOR_COST_INDEX			,
		l_def_cle_rec.MATERIAL_COST_INDEX		,
		l_def_cle_rec.CUSTOMERS_PERCENT_IN_ORDER	,
		l_def_cle_rec.DATE_OF_PRICE_REDETERMIN	,
		l_def_cle_rec.ESTIMATED_TOTAL_QUANTITY	,
		l_def_cle_rec.FEE_AJT_FORMULA		,
		l_def_cle_rec.FINAL_FEE			,
		l_def_cle_rec.FINAL_PFT_AJT_FORMULA	,
		l_def_cle_rec.FIXED_FEE			,
		l_def_cle_rec.FIXED_QUANTITY		,
		l_def_cle_rec.INITIAL_FEE			,
		l_def_cle_rec.INITIAL_PRICE			,
		l_def_cle_rec.LEVEL_OF_EFFORT_HOURS		,
		l_def_cle_rec.LINE_LIQUIDATION_RATE		,
		l_def_cle_rec.MAXIMUM_FEE			,
		l_def_cle_rec.MAXIMUM_QUANTITY		,
		l_def_cle_rec.MINIMUM_FEE			,
		l_def_cle_rec.MINIMUM_QUANTITY		,
		l_def_cle_rec.NUMBER_OF_OPTIONS		,
		l_def_cle_rec.REVISED_PRICE			,
		l_def_cle_rec.TARGET_COST			,
		l_def_cle_rec.TARGET_DATE_DEFINITIZE	,
		l_def_cle_rec.TARGET_FEE			,
		l_def_cle_rec.TARGET_PRICE			,
		l_def_cle_rec.TOTAL_ESTIMATED_COST		,
		l_def_cle_rec.CREATED_BY			,
		l_def_cle_rec.CREATION_DATE			,
		l_def_cle_rec.LAST_UPDATED_BY		,
		l_def_cle_rec.LAST_UPDATE_LOGIN		,
		l_def_cle_rec.LAST_UPDATE_DATE		,
		l_def_cle_rec.COST_OF_SALE_RATE);

    -- Set OUT values
    x_cle_rec := l_def_cle_rec;
    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl                      IN cle_tbl_type,
    x_cle_tbl                      OUT NOCOPY cle_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cle_tbl.COUNT > 0) THEN
      i := p_cle_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,

          p_cle_rec                      => p_cle_tbl(i),
          x_cle_rec                      => x_cle_tbl(i));

		-- store the highest degree of error
	 If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	     l_overall_status := x_return_status;
	   End If;
	 End If;

        EXIT WHEN (i = p_cle_tbl.LAST);

        i := p_cle_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

-- update oke_k_lines

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_rec                      IN cle_rec_type,
    x_cle_rec                      OUT NOCOPY cle_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_cle_rec                      cle_rec_type := p_cle_rec;
    l_def_cle_rec                  cle_rec_type;
    lx_cle_rec                     cle_rec_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cle_rec	IN cle_rec_type
    ) RETURN cle_rec_type IS

      l_cle_rec	cle_rec_type := p_cle_rec;

    BEGIN
      l_cle_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cle_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cle_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cle_rec);
    END fill_who_columns;

    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cle_rec	IN cle_rec_type,
      x_cle_rec	OUT NOCOPY cle_rec_type
    ) RETURN VARCHAR2 IS

      l_cle_rec                     cle_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

    BEGIN

      x_cle_rec := p_cle_rec;


      -- Get current database values
      l_cle_rec := get_rec(p_cle_rec, l_row_notfound);


      IF (l_row_notfound) THEN
        l_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      END IF;


      IF  x_cle_rec.PARENT_LINE_ID = OKE_API.G_MISS_NUM THEN
	x_cle_rec.PARENT_LINE_ID := l_cle_rec.PARENT_LINE_ID;
      END IF;

    IF	x_cle_rec.PROJECT_ID = OKE_API.G_MISS_NUM THEN
        x_cle_rec.PROJECT_ID := l_cle_rec.PROJECT_ID;
    END IF;

    IF  x_cle_rec.TASK_ID = OKE_API.G_MISS_NUM THEN
      	x_cle_rec.TASK_ID := l_cle_rec.TASK_ID;
    END IF;

    IF	x_cle_rec.BILLING_METHOD_CODE = OKE_API.G_MISS_CHAR THEN
        x_cle_rec.BILLING_METHOD_CODE := l_cle_rec.BILLING_METHOD_CODE;
    END IF;

    IF	x_cle_rec.INVENTORY_ITEM_ID = OKE_API.G_MISS_NUM THEN
        x_cle_rec.INVENTORY_ITEM_ID := l_cle_rec.INVENTORY_ITEM_ID;
    END IF;

    IF	x_cle_rec.DELIVERY_ORDER_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.DELIVERY_ORDER_FLAG := l_cle_rec.DELIVERY_ORDER_FLAG;
    END IF;

    IF	x_cle_rec.SPLITED_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.SPLITED_FLAG := l_cle_rec.SPLITED_FLAG;
    END IF;

    IF  x_cle_rec.PRIORITY_CODE	= OKE_API.G_MISS_CHAR THEN
	x_cle_rec.PRIORITY_CODE	:= l_cle_rec.PRIORITY_CODE;
    END IF;

    IF	x_cle_rec.CUSTOMER_ITEM_ID = OKE_API.G_MISS_NUM THEN
	x_cle_rec.CUSTOMER_ITEM_ID := l_cle_rec.CUSTOMER_ITEM_ID;
    END IF;

    IF	x_cle_rec.CUSTOMER_ITEM_NUMBER = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.CUSTOMER_ITEM_NUMBER := l_cle_rec.CUSTOMER_ITEM_NUMBER;
    END IF;

    IF	x_cle_rec.LINE_QUANTITY	= OKE_API.G_MISS_NUM THEN
        x_cle_rec.LINE_QUANTITY	:= l_cle_rec.LINE_QUANTITY;
    END IF;

    IF	x_cle_rec.DELIVERY_DATE	= OKE_API.G_MISS_DATE THEN
        x_cle_rec.DELIVERY_DATE	:= l_cle_rec.DELIVERY_DATE;
    END IF;

    IF	x_cle_rec.PROPOSAL_DUE_DATE = OKE_API.G_MISS_CHAR THEN
        x_cle_rec.PROPOSAL_DUE_DATE := l_cle_rec.PROPOSAL_DUE_DATE;
    END IF;

    IF	x_cle_rec.UNIT_PRICE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.UNIT_PRICE := l_cle_rec.UNIT_PRICE;
    END IF;

    IF	x_cle_rec.UOM_CODE = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.UOM_CODE := l_cle_rec.UOM_CODE;
    END IF;

    IF	x_cle_rec.LINE_VALUE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.LINE_VALUE := l_cle_rec.LINE_VALUE;
    END IF;

    IF	x_cle_rec.LINE_VALUE_TOTAL = OKE_API.G_MISS_NUM THEN
	x_cle_rec.LINE_VALUE_TOTAL := l_cle_rec.LINE_VALUE_TOTAL;
    END IF;

    IF	x_cle_rec.UNDEF_UNIT_PRICE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.UNDEF_UNIT_PRICE := l_cle_rec.UNDEF_UNIT_PRICE;
    END IF;

    IF	x_cle_rec.UNDEF_LINE_VALUE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.UNDEF_LINE_VALUE := l_cle_rec.UNDEF_LINE_VALUE;
    END IF;

    IF	x_cle_rec.UNDEF_LINE_VALUE_TOTAL = OKE_API.G_MISS_NUM THEN
	x_cle_rec.UNDEF_LINE_VALUE_TOTAL := l_cle_rec.UNDEF_LINE_VALUE_TOTAL;
    END IF;

    IF	x_cle_rec.END_DATE = OKE_API.G_MISS_DATE THEN
	x_cle_rec.END_DATE := l_cle_rec.END_DATE;
    END IF;

    IF	x_cle_rec.BILLABLE_FLAG	= OKE_API.G_MISS_CHAR THEN
	x_cle_rec.BILLABLE_FLAG	:= l_cle_rec.BILLABLE_FLAG;
    END IF;

    IF	x_cle_rec.SHIPPABLE_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.SHIPPABLE_FLAG := l_cle_rec.SHIPPABLE_FLAG;
    END IF;

    IF	x_cle_rec.SUBCONTRACTED_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.SUBCONTRACTED_FLAG := l_cle_rec.SUBCONTRACTED_FLAG;
    END IF;

    IF	x_cle_rec.COMPLETED_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.COMPLETED_FLAG := l_cle_rec.COMPLETED_FLAG;
    END IF;

    IF	x_cle_rec.NSP_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.NSP_FLAG := l_cle_rec.NSP_FLAG;
    END IF;

    IF	x_cle_rec.APP_CODE = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.APP_CODE := l_cle_rec.APP_CODE;
    END IF;

    IF	x_cle_rec.AS_OF_DATE = OKE_API.G_MISS_DATE THEN
	x_cle_rec.AS_OF_DATE := l_cle_rec.AS_OF_DATE;
    END IF;

    IF	x_cle_rec.AUTHORITY = OKE_API.G_MISS_CHAR THEN
        x_cle_rec.AUTHORITY := l_cle_rec.AUTHORITY;
    END IF;

    IF  x_cle_rec.COUNTRY_OF_ORIGIN_CODE = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.COUNTRY_OF_ORIGIN_CODE := l_cle_rec.COUNTRY_OF_ORIGIN_CODE;
    END IF;

    IF	x_cle_rec.DROP_SHIPPED_FLAG = OKE_API.G_MISS_CHAR THEN
        x_cle_rec.DROP_SHIPPED_FLAG := l_cle_rec.DROP_SHIPPED_FLAG;
    END IF;

    IF	x_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG := l_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG;
    END IF;

    IF  x_cle_rec.DATE_MATERIAL_REQ = OKE_API.G_MISS_DATE THEN
	x_cle_rec.DATE_MATERIAL_REQ := l_cle_rec.DATE_MATERIAL_REQ;
    END IF;

    IF	x_cle_rec.INSPECTION_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.INSPECTION_REQ_FLAG := l_cle_rec.INSPECTION_REQ_FLAG;
    END IF;

    IF	x_cle_rec.INTERIM_RPT_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.INTERIM_RPT_REQ_FLAG := l_cle_rec.INTERIM_RPT_REQ_FLAG;
    END IF;

    IF	x_cle_rec.SUBJ_A133_FLAG = OKE_API.G_MISS_CHAR THEN
   	x_cle_rec.SUBJ_A133_FLAG := l_cle_rec.SUBJ_A133_FLAG;
    END IF;

    IF	x_cle_rec.EXPORT_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.EXPORT_FLAG := l_cle_rec.EXPORT_FLAG;
    END IF;

    IF	x_cle_rec.CFE_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.CFE_REQ_FLAG := l_cle_rec.CFE_REQ_FLAG;
    END IF;

    IF	x_cle_rec.COP_REQUIRED_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.COP_REQUIRED_FLAG := l_cle_rec.COP_REQUIRED_FLAG;
    END IF;

    IF	x_cle_rec.EXPORT_LICENSE_NUM = OKE_API.G_MISS_CHAR THEN
   	x_cle_rec.EXPORT_LICENSE_NUM := l_cle_rec.EXPORT_LICENSE_NUM;
    END IF;

    IF	x_cle_rec.EXPORT_LICENSE_RES = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.EXPORT_LICENSE_RES := l_cle_rec.EXPORT_LICENSE_RES;
    END IF;

    IF	x_cle_rec.COPIES_REQUIRED = OKE_API.G_MISS_NUM THEN
	x_cle_rec.COPIES_REQUIRED := l_cle_rec.COPIES_REQUIRED;
    END IF;

    IF	x_cle_rec.CDRL_CATEGORY = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.CDRL_CATEGORY := l_cle_rec.CDRL_CATEGORY;
    END IF;

    IF	x_cle_rec.DATA_ITEM_NAME = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.DATA_ITEM_NAME := l_cle_rec.DATA_ITEM_NAME;
    END IF;

    IF	x_cle_rec.DATA_ITEM_SUBTITLE = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.DATA_ITEM_SUBTITLE := l_cle_rec.DATA_ITEM_SUBTITLE;
    END IF;

    IF	x_cle_rec.DATE_OF_FIRST_SUBMISSION = OKE_API.G_MISS_DATE THEN
	x_cle_rec.DATE_OF_FIRST_SUBMISSION := l_cle_rec.DATE_OF_FIRST_SUBMISSION;
    END IF;

    IF	x_cle_rec.FREQUENCY = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.FREQUENCY := l_cle_rec.FREQUENCY;
    END IF;

    IF	x_cle_rec.REQUIRING_OFFICE = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.REQUIRING_OFFICE := l_cle_rec.REQUIRING_OFFICE;
    END IF;

    IF	x_cle_rec.DCAA_AUDIT_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.DCAA_AUDIT_REQ_FLAG := l_cle_rec.DCAA_AUDIT_REQ_FLAG;
    END IF;

    IF	x_cle_rec.DEFINITIZED_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.DEFINITIZED_FLAG := l_cle_rec.DEFINITIZED_FLAG;
    END IF;

    IF	x_cle_rec.COST_OF_MONEY = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.COST_OF_MONEY := l_cle_rec.COST_OF_MONEY;
    END IF;

    IF  x_cle_rec.BILL_UNDEFINITIZED_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.BILL_UNDEFINITIZED_FLAG := l_cle_rec.BILL_UNDEFINITIZED_FLAG;
    END IF;

    IF	x_cle_rec.NSN_NUMBER = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.NSN_NUMBER := l_cle_rec.NSN_NUMBER;
    END IF;

    IF	x_cle_rec.NTE_WARNING_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.NTE_WARNING_FLAG := l_cle_rec.NTE_WARNING_FLAG;
    END IF;

    IF	x_cle_rec.DISCOUNT_FOR_PAYMENT = OKE_API.G_MISS_NUM THEN
	x_cle_rec.DISCOUNT_FOR_PAYMENT := l_cle_rec.DISCOUNT_FOR_PAYMENT;
    END IF;

    IF	x_cle_rec.FINANCIAL_CTRL_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.FINANCIAL_CTRL_FLAG := l_cle_rec.FINANCIAL_CTRL_FLAG;
    END IF;

    IF	x_cle_rec.C_SCS_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.C_SCS_FLAG := l_cle_rec.C_SCS_FLAG;
    END IF;

    IF	x_cle_rec.C_SSR_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.C_SSR_FLAG := l_cle_rec.C_SSR_FLAG;
    END IF;

    IF	x_cle_rec.PREPAYMENT_AMOUNT = OKE_API.G_MISS_NUM THEN
	x_cle_rec.PREPAYMENT_AMOUNT := l_cle_rec.PREPAYMENT_AMOUNT;
    END IF;

    IF	x_cle_rec.PREPAYMENT_PERCENTAGE = OKE_API.G_MISS_NUM THEN
        x_cle_rec.PREPAYMENT_PERCENTAGE :=l_cle_rec.PREPAYMENT_PERCENTAGE;
    END IF;

    IF	x_cle_rec.PROGRESS_PAYMENT_FLAG = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.PROGRESS_PAYMENT_FLAG := l_cle_rec.PROGRESS_PAYMENT_FLAG;
    END IF;

    IF	x_cle_rec.PROGRESS_PAYMENT_LIQ_RATE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.PROGRESS_PAYMENT_LIQ_RATE := l_cle_rec.PROGRESS_PAYMENT_LIQ_RATE;
    END IF;

    IF	x_cle_rec.PROGRESS_PAYMENT_RATE	= OKE_API.G_MISS_NUM THEN
	x_cle_rec.PROGRESS_PAYMENT_RATE := l_cle_rec.PROGRESS_PAYMENT_RATE;
    END IF;

    IF	x_cle_rec.AWARD_FEE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.AWARD_FEE := l_cle_rec.AWARD_FEE;
    END IF;

    IF	x_cle_rec.AWARD_FEE_POOL_AMOUNT = OKE_API.G_MISS_NUM THEN
	x_cle_rec.AWARD_FEE_POOL_AMOUNT := l_cle_rec.AWARD_FEE_POOL_AMOUNT;
    END IF;

    IF	x_cle_rec.BASE_FEE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.BASE_FEE := l_cle_rec.BASE_FEE;
    END IF;

    IF	x_cle_rec.CEILING_COST = OKE_API.G_MISS_NUM THEN
	x_cle_rec.CEILING_COST := l_cle_rec.CEILING_COST;
    END IF;

    IF	x_cle_rec.CEILING_PRICE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.CEILING_PRICE := l_cle_rec.CEILING_PRICE;
    END IF;

    IF	x_cle_rec.COST_OVERRUN_SHARE_RATIO = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.COST_OVERRUN_SHARE_RATIO := l_cle_rec.COST_OVERRUN_SHARE_RATIO;
    END IF;

    IF	x_cle_rec.COST_UNDERRUN_SHARE_RATIO = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.COST_UNDERRUN_SHARE_RATIO := l_cle_rec.COST_UNDERRUN_SHARE_RATIO;
    END IF;

    IF	x_cle_rec.LABOR_COST_INDEX = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.LABOR_COST_INDEX := l_cle_rec.LABOR_COST_INDEX;
    END IF;

    IF	x_cle_rec.MATERIAL_COST_INDEX = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.MATERIAL_COST_INDEX := l_cle_rec.MATERIAL_COST_INDEX;
    END IF;

    IF	x_cle_rec.CUSTOMERS_PERCENT_IN_ORDER = OKE_API.G_MISS_NUM THEN
	x_cle_rec.CUSTOMERS_PERCENT_IN_ORDER := l_cle_rec.CUSTOMERS_PERCENT_IN_ORDER;
    END IF;

    IF	x_cle_rec.DATE_OF_PRICE_REDETERMIN = OKE_API.G_MISS_DATE THEN
	x_cle_rec.DATE_OF_PRICE_REDETERMIN := l_cle_rec.DATE_OF_PRICE_REDETERMIN;
    END IF;

    IF	x_cle_rec.ESTIMATED_TOTAL_QUANTITY = OKE_API.G_MISS_NUM THEN
	x_cle_rec.ESTIMATED_TOTAL_QUANTITY := l_cle_rec.ESTIMATED_TOTAL_QUANTITY;
    END IF;

    IF	x_cle_rec.FEE_AJT_FORMULA = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.FEE_AJT_FORMULA := l_cle_rec.FEE_AJT_FORMULA;
    END IF;

    IF	x_cle_rec.FINAL_FEE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.FINAL_FEE :=l_cle_rec.FINAL_FEE;
    END IF;

    IF	x_cle_rec.FINAL_PFT_AJT_FORMULA = OKE_API.G_MISS_CHAR THEN
	x_cle_rec.FINAL_PFT_AJT_FORMULA := l_cle_rec.FINAL_PFT_AJT_FORMULA;
    END IF;

    IF	x_cle_rec.FIXED_FEE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.FIXED_FEE := l_cle_rec.FIXED_FEE ;
    END IF;

    IF	x_cle_rec.FIXED_QUANTITY = OKE_API.G_MISS_NUM THEN
	x_cle_rec.FIXED_QUANTITY := l_cle_rec.FIXED_QUANTITY;
    END IF;

    IF	x_cle_rec.INITIAL_FEE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.INITIAL_FEE := l_cle_rec.INITIAL_FEE;
    END IF;

    IF	x_cle_rec.INITIAL_PRICE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.INITIAL_PRICE := l_cle_rec.INITIAL_PRICE;
    END IF;

    IF	x_cle_rec.LEVEL_OF_EFFORT_HOURS = OKE_API.G_MISS_NUM THEN
	x_cle_rec.LEVEL_OF_EFFORT_HOURS := l_cle_rec.LEVEL_OF_EFFORT_HOURS;
    END IF;

    IF	x_cle_rec.LINE_LIQUIDATION_RATE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.LINE_LIQUIDATION_RATE := l_cle_rec.LINE_LIQUIDATION_RATE;
    END IF;

    IF	x_cle_rec.MAXIMUM_FEE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.MAXIMUM_FEE := l_cle_rec.MAXIMUM_FEE;
    END IF;

    IF	x_cle_rec.MAXIMUM_QUANTITY = OKE_API.G_MISS_NUM THEN
	x_cle_rec.MAXIMUM_QUANTITY := l_cle_rec.MAXIMUM_QUANTITY;
    END IF;

    IF	x_cle_rec.MINIMUM_FEE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.MINIMUM_FEE := l_cle_rec.MINIMUM_FEE;
    END IF;

    IF	x_cle_rec.MINIMUM_QUANTITY = OKE_API.G_MISS_NUM THEN
	x_cle_rec.MINIMUM_QUANTITY := l_cle_rec.MINIMUM_QUANTITY;
    END IF;

    IF	x_cle_rec.NUMBER_OF_OPTIONS = OKE_API.G_MISS_NUM THEN
	x_cle_rec.NUMBER_OF_OPTIONS :=l_cle_rec.NUMBER_OF_OPTIONS ;
    END IF;

    IF	x_cle_rec.REVISED_PRICE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.REVISED_PRICE := l_cle_rec.REVISED_PRICE;
    END IF;

    IF	x_cle_rec.TARGET_COST = OKE_API.G_MISS_NUM THEN
	x_cle_rec.TARGET_COST := l_cle_rec.TARGET_COST;
    END IF;

    IF	x_cle_rec.TARGET_DATE_DEFINITIZE = OKE_API.G_MISS_DATE THEN
	x_cle_rec.TARGET_DATE_DEFINITIZE := l_cle_rec.TARGET_DATE_DEFINITIZE;
    END IF;

    IF	x_cle_rec.TARGET_FEE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.TARGET_FEE := l_cle_rec.TARGET_FEE;
    END IF;

    IF	x_cle_rec.TARGET_PRICE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.TARGET_PRICE := l_cle_rec.TARGET_PRICE;
    END IF;

    IF	x_cle_rec.TOTAL_ESTIMATED_COST = OKE_API.G_MISS_NUM THEN
	x_cle_rec.TOTAL_ESTIMATED_COST := l_cle_rec.TOTAL_ESTIMATED_COST;
    END IF;

    IF	x_cle_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	x_cle_rec.CREATED_BY :=  l_cle_rec.CREATED_BY;
    END IF;

    IF	x_cle_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	x_cle_rec.CREATION_DATE := l_cle_rec.CREATION_DATE;
    END IF;

    IF	x_cle_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	x_cle_rec.LAST_UPDATED_BY := l_cle_rec.LAST_UPDATED_BY;
    END IF;

    IF	x_cle_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	x_cle_rec.LAST_UPDATE_LOGIN := l_cle_rec.LAST_UPDATE_LOGIN;
    END IF;

    IF	x_cle_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	x_cle_rec.LAST_UPDATE_DATE := l_cle_rec.LAST_UPDATE_DATE;
    END IF;

    IF	x_cle_rec.COST_OF_SALE_RATE = OKE_API.G_MISS_NUM THEN
	x_cle_rec.COST_OF_SALE_RATE := l_cle_rec.COST_OF_SALE_RATE;
    END IF;

    RETURN(l_return_status);

  END populate_new_record;

  -- set attributes for oke_k_lines

  FUNCTION set_attributes(
	      p_cle_rec IN  cle_rec_type,
              x_cle_rec OUT NOCOPY cle_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cle_rec := p_cle_rec;
      x_cle_rec.BILLABLE_FLAG		:= UPPER(x_cle_rec.BILLABLE_FLAG);
      x_cle_rec.SHIPPABLE_FLAG		:= UPPER(x_cle_rec.SHIPPABLE_FLAG);
      x_cle_rec.SUBCONTRACTED_FLAG	 := UPPER(x_cle_rec.SUBCONTRACTED_FLAG);
      x_cle_rec.COMPLETED_FLAG		:= UPPER(x_cle_rec.COMPLETED_FLAG);
      x_cle_rec.NSP_FLAG		:= UPPER(x_cle_rec.NSP_FLAG);

      x_cle_rec.DROP_SHIPPED_FLAG	:= UPPER(x_cle_rec.DROP_SHIPPED_FLAG);

      x_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG := UPPER(x_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG);

      x_cle_rec.INSPECTION_REQ_FLAG	:= UPPER(x_cle_rec.INSPECTION_REQ_FLAG);

      x_cle_rec.INTERIM_RPT_REQ_FLAG	:= UPPER(x_cle_rec.INTERIM_RPT_REQ_FLAG);

      x_cle_rec.SUBJ_A133_FLAG	:= UPPER(x_cle_rec.SUBJ_A133_FLAG);

      x_cle_rec.EXPORT_FLAG	:= UPPER(x_cle_rec.EXPORT_FLAG);

      x_cle_rec.CFE_REQ_FLAG	:= UPPER(x_cle_rec.CFE_REQ_FLAG);
      x_cle_rec.COP_REQUIRED_FLAG	:= UPPER(x_cle_rec.COP_REQUIRED_FLAG);

      x_cle_rec.DCAA_AUDIT_REQ_FLAG	:= UPPER(x_cle_rec.DCAA_AUDIT_REQ_FLAG);

      x_cle_rec.DEFINITIZED_FLAG	:= UPPER(x_cle_rec.DEFINITIZED_FLAG);

      x_cle_rec.BILL_UNDEFINITIZED_FLAG	:= UPPER(x_cle_rec.BILL_UNDEFINITIZED_FLAG);
      x_cle_rec.NTE_WARNING_FLAG	:= UPPER(x_cle_rec.NTE_WARNING_FLAG);

      x_cle_rec.FINANCIAL_CTRL_FLAG	:= UPPER(x_cle_rec.FINANCIAL_CTRL_FLAG);

      x_cle_rec.C_SCS_FLAG	:= UPPER(x_cle_rec.C_SCS_FLAG);

      x_cle_rec.C_SSR_FLAG	:= UPPER(x_cle_rec.C_SSR_FLAG);
      x_cle_rec.PROGRESS_PAYMENT_FLAG	:= UPPER(x_cle_rec.PROGRESS_PAYMENT_FLAG);

      RETURN(l_return_status);

    END Set_Attributes;

  BEGIN

    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);


    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    l_return_status := Set_Attributes(
      p_cle_rec,                        -- IN
      l_cle_rec);                       -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_cle_rec, l_def_cle_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    l_def_cle_rec := fill_who_columns(l_def_cle_rec);


    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cle_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;




    l_return_status := Validate_Record(l_def_cle_rec);


    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    UPDATE OKE_K_LINES
    SET
	PARENT_LINE_ID		= l_def_cle_rec.PARENT_LINE_ID,
	PROJECT_ID		= l_def_cle_rec.PROJECT_ID,
	TASK_ID			= l_def_cle_rec.TASK_ID,
	BILLING_METHOD_CODE	= l_def_cle_rec.BILLING_METHOD_CODE,
	INVENTORY_ITEM_ID	= l_def_cle_rec.INVENTORY_ITEM_ID,
	DELIVERY_ORDER_FLAG	= l_def_cle_rec.DELIVERY_ORDER_FLAG,
	SPLITED_FLAG		= l_def_cle_rec.SPLITED_FLAG,
	PRIORITY_CODE		= l_def_cle_rec.PRIORITY_CODE,
	CUSTOMER_ITEM_ID	= l_def_cle_rec.CUSTOMER_ITEM_ID,
	CUSTOMER_ITEM_NUMBER    = l_def_cle_rec.CUSTOMER_ITEM_NUMBER,
	LINE_QUANTITY		= l_def_cle_rec.LINE_QUANTITY,
	DELIVERY_DATE		= l_def_cle_rec.DELIVERY_DATE,
        PROPOSAL_DUE_DATE	= l_def_cle_rec.PROPOSAL_DUE_DATE,
	UNIT_PRICE		= l_def_cle_rec.UNIT_PRICE,
	UOM_CODE		= l_def_cle_rec.UOM_CODE,
	LINE_VALUE		= l_def_cle_rec.LINE_VALUE,
	LINE_VALUE_TOTAL	= l_def_cle_rec.LINE_VALUE_TOTAL,
	UNDEF_UNIT_PRICE	= l_def_cle_rec.UNDEF_UNIT_PRICE,
	UNDEF_LINE_VALUE	= l_def_cle_rec.UNDEF_LINE_VALUE,
	UNDEF_LINE_VALUE_TOTAL	= l_def_cle_rec.UNDEF_LINE_VALUE_TOTAL,
	END_DATE		= l_def_cle_rec.END_DATE,
	BILLABLE_FLAG		= l_def_cle_rec.BILLABLE_FLAG,
	SHIPPABLE_FLAG		= l_def_cle_rec.SHIPPABLE_FLAG,
	SUBCONTRACTED_FLAG	= l_def_cle_rec.SUBCONTRACTED_FLAG,
	COMPLETED_FLAG		= l_def_cle_rec.COMPLETED_FLAG,
	NSP_FLAG		= l_def_cle_rec.NSP_FLAG,
	APP_CODE		= l_def_cle_rec.APP_CODE,
	AS_OF_DATE		= l_def_cle_rec.AS_OF_DATE,
	AUTHORITY		= l_def_cle_rec.AUTHORITY,
	COUNTRY_OF_ORIGIN_CODE	= l_def_cle_rec.COUNTRY_OF_ORIGIN_CODE,
	DROP_SHIPPED_FLAG	= l_def_cle_rec.DROP_SHIPPED_FLAG,
	CUSTOMER_APPROVAL_REQ_FLAG = l_def_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG,
	DATE_MATERIAL_REQ	= l_def_cle_rec.DATE_MATERIAL_REQ,
	INSPECTION_REQ_FLAG	= l_def_cle_rec.INSPECTION_REQ_FLAG,
	INTERIM_RPT_REQ_FLAG	= l_def_cle_rec.INTERIM_RPT_REQ_FLAG,
	SUBJ_A133_FLAG		= l_def_cle_rec.SUBJ_A133_FLAG,
	EXPORT_FLAG		= l_def_cle_rec.EXPORT_FLAG,
	CFE_REQ_FLAG		= l_def_cle_rec.CFE_REQ_FLAG,
	COP_REQUIRED_FLAG	= l_def_cle_rec.COP_REQUIRED_FLAG,
	EXPORT_LICENSE_NUM	= l_def_cle_rec.EXPORT_LICENSE_NUM,
	EXPORT_LICENSE_RES	= l_def_cle_rec.EXPORT_LICENSE_RES,
	COPIES_REQUIRED		= l_def_cle_rec.COPIES_REQUIRED,
	CDRL_CATEGORY		= l_def_cle_rec.CDRL_CATEGORY,
	DATA_ITEM_NAME		= l_def_cle_rec.DATA_ITEM_NAME,
	DATA_ITEM_SUBTITLE	= l_def_cle_rec.DATA_ITEM_SUBTITLE,
	DATE_OF_FIRST_SUBMISSION = l_def_cle_rec.DATE_OF_FIRST_SUBMISSION,
	FREQUENCY		= l_def_cle_rec.FREQUENCY,
	REQUIRING_OFFICE	= l_def_cle_rec.REQUIRING_OFFICE,
	DCAA_AUDIT_REQ_FLAG	= l_def_cle_rec.DCAA_AUDIT_REQ_FLAG,
	DEFINITIZED_FLAG	= l_def_cle_rec.DEFINITIZED_FLAG,
	COST_OF_MONEY		= l_def_cle_rec.COST_OF_MONEY,
	BILL_UNDEFINITIZED_FLAG	= l_def_cle_rec.BILL_UNDEFINITIZED_FLAG,
	NSN_NUMBER		= l_def_cle_rec.NSN_NUMBER,
	NTE_WARNING_FLAG	= l_def_cle_rec.NTE_WARNING_FLAG,
	DISCOUNT_FOR_PAYMENT	= l_def_cle_rec.DISCOUNT_FOR_PAYMENT,
	FINANCIAL_CTRL_FLAG	= l_def_cle_rec.FINANCIAL_CTRL_FLAG,
	C_SCS_FLAG		= l_def_cle_rec.C_SCS_FLAG,
	C_SSR_FLAG		= l_def_cle_rec.C_SSR_FLAG,
	PREPAYMENT_AMOUNT	= l_def_cle_rec.PREPAYMENT_AMOUNT,
	PREPAYMENT_PERCENTAGE	= l_def_cle_rec.PREPAYMENT_PERCENTAGE,
	PROGRESS_PAYMENT_FLAG	= l_def_cle_rec.PROGRESS_PAYMENT_FLAG,
	PROGRESS_PAYMENT_LIQ_RATE = l_def_cle_rec.PROGRESS_PAYMENT_LIQ_RATE,
	PROGRESS_PAYMENT_RATE	= l_def_cle_rec.PROGRESS_PAYMENT_RATE,
	AWARD_FEE		= l_def_cle_rec.AWARD_FEE,
	AWARD_FEE_POOL_AMOUNT	= l_def_cle_rec.AWARD_FEE_POOL_AMOUNT	,
	BASE_FEE		= l_def_cle_rec.BASE_FEE,
	CEILING_COST		= l_def_cle_rec.CEILING_COST,
        CEILING_PRICE	        = l_def_cle_rec.CEILING_PRICE,
        COST_OVERRUN_SHARE_RATIO = l_def_cle_rec.COST_OVERRUN_SHARE_RATIO,
        COST_UNDERRUN_SHARE_RATIO = l_def_cle_rec.COST_UNDERRUN_SHARE_RATIO,
	LABOR_COST_INDEX		= l_def_cle_rec.LABOR_COST_INDEX,
        MATERIAL_COST_INDEX	= l_def_cle_rec.MATERIAL_COST_INDEX,
	CUSTOMERS_PERCENT_IN_ORDER = l_def_cle_rec.CUSTOMERS_PERCENT_IN_ORDER,
	DATE_OF_PRICE_REDETERMIN = l_def_cle_rec.DATE_OF_PRICE_REDETERMIN,
	ESTIMATED_TOTAL_QUANTITY = l_def_cle_rec.ESTIMATED_TOTAL_QUANTITY,
	FEE_AJT_FORMULA		= l_def_cle_rec.FEE_AJT_FORMULA,
	FINAL_FEE		= l_def_cle_rec.FINAL_FEE,
	FINAL_PFT_AJT_FORMULA	= l_def_cle_rec.FINAL_PFT_AJT_FORMULA,
	FIXED_FEE		= l_def_cle_rec.FIXED_FEE,
	FIXED_QUANTITY		= l_def_cle_rec.FIXED_QUANTITY,
	INITIAL_FEE		= l_def_cle_rec.INITIAL_FEE,
	INITIAL_PRICE		= l_def_cle_rec.INITIAL_PRICE,
	LEVEL_OF_EFFORT_HOURS	= l_def_cle_rec.LEVEL_OF_EFFORT_HOURS,
	LINE_LIQUIDATION_RATE	= l_def_cle_rec.LINE_LIQUIDATION_RATE,
	MAXIMUM_FEE		= l_def_cle_rec.MAXIMUM_FEE,
	MAXIMUM_QUANTITY	= l_def_cle_rec.MAXIMUM_QUANTITY,
	MINIMUM_FEE		= l_def_cle_rec.MINIMUM_FEE,
	MINIMUM_QUANTITY	= l_def_cle_rec.MINIMUM_QUANTITY,
	NUMBER_OF_OPTIONS	= l_def_cle_rec.NUMBER_OF_OPTIONS,
	REVISED_PRICE		= l_def_cle_rec.REVISED_PRICE,
	TARGET_COST		= l_def_cle_rec.TARGET_COST,
	TARGET_DATE_DEFINITIZE	= l_def_cle_rec.TARGET_DATE_DEFINITIZE,
	TARGET_FEE		= l_def_cle_rec.TARGET_FEE,
	TARGET_PRICE		= l_def_cle_rec.TARGET_PRICE,
	TOTAL_ESTIMATED_COST	= l_def_cle_rec.TOTAL_ESTIMATED_COST,
	CREATED_BY		= l_def_cle_rec.CREATED_BY,
	CREATION_DATE		= l_def_cle_rec.CREATION_DATE,
	LAST_UPDATED_BY		= l_def_cle_rec.LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN	= l_def_cle_rec.LAST_UPDATE_LOGIN,
	LAST_UPDATE_DATE	= l_def_cle_rec.LAST_UPDATE_DATE,
	COST_OF_SALE_RATE	= l_def_cle_rec.COST_OF_SALE_RATE

    WHERE K_LINE_ID = l_def_cle_rec.K_LINE_ID;


    x_cle_rec := l_def_cle_rec;

    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;


  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl                     IN cle_tbl_type,
    x_cle_tbl                     OUT NOCOPY cle_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_update_row';


    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cle_tbl.COUNT > 0) THEN
      i := p_cle_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cle_rec                      => p_cle_tbl(i),
          x_cle_rec                     => x_cle_tbl(i));

		-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
	  End If;
	End If;

        EXIT WHEN (i = p_cle_tbl.LAST);
        i := p_cle_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_rec                     IN cle_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_cle_rec                     cle_rec_type := p_cle_rec;

  BEGIN

    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);


    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKE_K_LINES
    WHERE K_LINE_ID = l_cle_rec.K_LINE_ID;

    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl                     IN cle_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing
    IF (p_cle_tbl.COUNT > 0) THEN
      i := p_cle_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cle_rec                      => p_cle_tbl(i));



	-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
          End If;
	End If;

        EXIT WHEN (i = p_cle_tbl.LAST);
        i := p_cle_tbl.NEXT(i);
      END LOOP;

	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKE_CLE_PVT;


/
