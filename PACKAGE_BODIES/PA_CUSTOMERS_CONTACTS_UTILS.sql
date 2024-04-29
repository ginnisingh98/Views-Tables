--------------------------------------------------------
--  DDL for Package Body PA_CUSTOMERS_CONTACTS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CUSTOMERS_CONTACTS_UTILS" AS
/* $Header: PARPCCUB.pls 120.5.12010000.2 2009/03/06 07:23:45 rthumma ship $ */


-- Global constant
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_CUSTOMERS_CONTACTS_UTILS';


-- API name		: Check_Customer_Name_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_id                   IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_customer_name                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_customer_id                   OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CUSTOMER_NAME_OR_ID
(  p_customer_id                   IN NUMBER     := FND_API.G_MISS_NUM
  ,p_customer_name                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_customer_id                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_current_id NUMBER := NULL;
   l_num_ids NUMBER := 0;
   l_id_found_flag VARCHAR(1) := 'N';


   CURSOR c_ids IS
      SELECT customer_id
      FROM pa_customers_v
      WHERE upper(substr(customer_name,1,50)) = upper(substr(p_customer_name,1,50)) and status = 'A';  -- Bug 8314123
BEGIN
   if (p_customer_id = FND_API.G_MISS_NUM) OR (p_customer_id is NULL) then
      if (p_customer_name is not NULL) then
	  SELECT customer_id
          INTO x_customer_id
          FROM pa_customers_v
          WHERE upper(substr(customer_name,1,50)) = upper(substr(p_customer_name,1,50))  -- Bug 8314123
                and status = 'A';
      else
	  x_customer_id := NULL;
      end if;

   else
      if p_check_id_flag = 'Y' then
         SELECT customer_id
         INTO x_customer_id
         FROM pa_customers_v
         WHERE customer_id = p_customer_id;

      ELSIF (p_check_id_flag='N') THEN
          x_customer_id := p_customer_id;


      ELSIF (p_check_id_flag = 'A') THEN
             IF (p_customer_name IS NULL) THEN
                 -- Return a null ID since the name is null.
                   x_customer_id := NULL;
             ELSE

                 -- Find the ID which matches the Name passed
                 OPEN c_ids;
                    LOOP
                    	FETCH c_ids INTO l_current_id;
                    	EXIT WHEN c_ids%NOTFOUND;
                    	IF (l_current_id =  p_customer_id) THEN
                         	l_id_found_flag := 'Y';
                        	x_customer_id := p_customer_id;
                    	END IF;
                    END LOOP;
                    l_num_ids := c_ids%ROWCOUNT;
                 CLOSE c_ids;

                 IF (l_num_ids = 0) THEN
                     -- No IDs for name
                     RAISE NO_DATA_FOUND;
                 ELSIF (l_num_ids = 1) THEN
                     -- Since there is only one ID for the name use it.
                     x_customer_id := l_current_id;
                 ELSIF (l_id_found_flag = 'N') THEN
                     -- More than one ID for the name and none of the IDs matched
                     -- the ID passed in.
                        RAISE TOO_MANY_ROWS;
                 END IF;
             END IF;



      else
         x_customer_id := NULL;
      end if;

   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when NO_DATA_FOUND then
      x_customer_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_CUSTOMER_ID_INVALID';
   when TOO_MANY_ROWS then
      x_customer_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_CUST_NAME_NOT_UNIQUE';
   when OTHERS then
      x_customer_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_CUSTOMERS_CONTACTS_UTILS', p_procedure_name  => 'CHECK_CUSTOMER_NAME_OR_ID');
      raise;
END CHECK_CUSTOMER_NAME_OR_ID;


-- API name		: Check_Customer_Number_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_id                   IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_customer_number               IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_customer_id                   OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CUSTOMER_NUMBER_OR_ID
(  p_customer_id                   IN NUMBER     := FND_API.G_MISS_NUM
  ,p_customer_number               IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_customer_id                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_current_id NUMBER := NULL;
   l_num_ids NUMBER := 0;
   l_id_found_flag VARCHAR(1) := 'N';


   CURSOR c_ids IS
      SELECT customer_id
      FROM pa_customers_v
      WHERE upper(customer_number) = upper(p_customer_number) and status = 'A';

BEGIN
   if (p_customer_id = FND_API.G_MISS_NUM) OR (p_customer_id is NULL) then
      if (p_customer_number is not NULL) then
	      SELECT customer_id
	      INTO x_customer_id
	      FROM pa_customers_v
	      WHERE upper(customer_number) = upper(p_customer_number)
	      and status = 'A';
      else
	  x_customer_id := NULL;
      end if;

   else
      if p_check_id_flag = 'Y' then
         SELECT customer_id
         INTO x_customer_id
         FROM pa_customers_v
         WHERE customer_id = p_customer_id;

      ELSIF (p_check_id_flag='N') THEN
         x_customer_id := p_customer_id;


      ELSIF (p_check_id_flag = 'A') THEN
             IF (p_customer_number IS NULL) THEN
                 -- Return a null ID since the name is null.
                 x_customer_id := NULL;
             ELSE

                 -- Find the ID which matches the Name passed
                 OPEN c_ids;
                    LOOP
                    	FETCH c_ids INTO l_current_id;
                    	EXIT WHEN c_ids%NOTFOUND;
                    	IF (l_current_id = p_customer_id) THEN
                         	l_id_found_flag := 'Y';
                        	x_customer_id := p_customer_id;
                    	END IF;
                    END LOOP;
                    l_num_ids := c_ids%ROWCOUNT;
                 CLOSE c_ids;

                 IF (l_num_ids = 0) THEN
                     -- No IDs for name
                     RAISE NO_DATA_FOUND;
                 ELSIF (l_num_ids = 1) THEN
                     -- Since there is only one ID for the name use it.
                     x_customer_id := l_current_id;
                 ELSIF (l_id_found_flag = 'N') THEN
                     -- More than one ID for the name and none of the IDs matched
                     -- the ID passed in.
                        RAISE TOO_MANY_ROWS;
                 END IF;
             END IF;
      else
         x_customer_id := NULL;
      end if;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when NO_DATA_FOUND then
      x_customer_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_CUSTOMER_ID_INVALID';
   when TOO_MANY_ROWS then
      x_customer_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_CUST_NUM_NOT_UNIQUE';
   when OTHERS then
      x_customer_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_CUSTOMERS_CONTACTS_UTILS', p_procedure_name  => 'CHECK_CUSTOMER_NUMBER_OR_ID');
      raise;

END CHECK_CUSTOMER_NUMBER_OR_ID;


-- API name		: Check_Bill_Site_Name_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_id                   IN NUMBER     Required
-- p_bill_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_bill_site_name                IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_bill_to_address_id            OUT NUMBER    Optional
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_BILL_SITE_NAME_OR_ID
(  p_customer_id                   IN NUMBER
  ,p_bill_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_bill_site_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_bill_to_address_id            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_current_id NUMBER := NULL;
   l_num_ids NUMBER := 0;
   l_id_found_flag VARCHAR(1) := 'N';


   CURSOR c_ids IS
      SELECT address_id
      FROM pa_customer_sites_v
      WHERE upper(address1) = upper(p_bill_site_name) AND
            customer_id = p_customer_id AND
            site_use_code = 'BILL_TO';

BEGIN
   if (p_bill_to_address_id = FND_API.G_MISS_NUM) OR (p_bill_to_address_id is NULL) then
      if (p_bill_site_name is not NULL) then
          SELECT address_id
          INTO x_bill_to_address_id
          FROM pa_customer_sites_v
          WHERE upper(address1) = upper(p_bill_site_name) AND
                customer_id = p_customer_id AND
                site_use_code = 'BILL_TO';
      else
	  x_bill_to_address_id := NULL;
      end if;
   else
      if p_check_id_flag = 'Y' then
         SELECT address_id
         INTO x_bill_to_address_id
         FROM pa_customer_sites_v
         WHERE address_id = p_bill_to_address_id AND
               customer_id = p_customer_id AND
               site_use_code = 'BILL_TO';
      ELSIF (p_check_id_flag='N') THEN
         x_bill_to_address_id := p_bill_to_address_id;


      ELSIF (p_check_id_flag = 'A') THEN
             IF (p_bill_site_name IS NULL) THEN
                 -- Return a null ID since the name is null.
                 x_bill_to_address_id := NULL;
             ELSE

                 -- Find the ID which matches the Name passed
                 OPEN c_ids;
                    LOOP
                    	FETCH c_ids INTO l_current_id;
                    	EXIT WHEN c_ids%NOTFOUND;
                    	IF (l_current_id = p_bill_to_address_id) THEN
                         	l_id_found_flag := 'Y';
                        	x_bill_to_address_id := p_bill_to_address_id;
                    	END IF;
                    END LOOP;
                    l_num_ids := c_ids%ROWCOUNT;
                 CLOSE c_ids;

                 IF (l_num_ids = 0) THEN
                     -- No IDs for name
                     RAISE NO_DATA_FOUND;
                 ELSIF (l_num_ids = 1) THEN
                     -- Since there is only one ID for the name use it.
                     X_bill_to_address_id := l_current_id;
                 ELSIF (l_id_found_flag = 'N') THEN
                     -- More than one ID for the name and none of the IDs matched
                     -- the ID passed in.
                        RAISE TOO_MANY_ROWS;
                 END IF;
             END IF;

--      else
--         x_bill_to_address_id := p_bill_to_address_id;
      end if;
   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when NO_DATA_FOUND then
      x_bill_to_address_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_BILL_TO_ADDR_ID_INVALID';
   when TOO_MANY_ROWS then
      x_bill_to_address_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_BILL_TO_ADDR_NOT_UNIQUE';
   when OTHERS then
      x_bill_to_address_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_CUSTOMERS_CONTACTS_UTILS', p_procedure_name  => 'CHECK_BILL_SITE_NAME_OR_ID');
      raise;
END CHECK_BILL_SITE_NAME_OR_ID;


-- API name		: Check_Work_Site_Name_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_id                   IN NUMBER     Required
-- p_ship_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_work_site_name                IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_ship_to_address_id            OUT NUMBER    Optional
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_WORK_SITE_NAME_OR_ID
(  p_customer_id                   IN NUMBER
  ,p_ship_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_work_site_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_ship_to_address_id            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_current_id NUMBER := NULL;
   l_num_ids NUMBER := 0;
   l_id_found_flag VARCHAR(1) := 'N';


   CURSOR c_ids IS
      SELECT address_id
      FROM pa_customer_sites_v
      WHERE upper(address1) = upper(p_work_site_name) AND
            customer_id = p_customer_id AND
            site_use_code = 'SHIP_TO';
BEGIN
   if (p_ship_to_address_id = FND_API.G_MISS_NUM) OR (p_ship_to_address_id is NULL) then
      if (p_work_site_name is not NULL) then
      	   SELECT address_id
      	   INTO x_ship_to_address_id
      	   FROM pa_customer_sites_v
      	   WHERE upper(address1) = upper(p_work_site_name) AND
           	   customer_id = p_customer_id AND
            	   site_use_code = 'SHIP_TO';
      else
	  x_ship_to_address_id := NULL;
      end if;

   else
      if p_check_id_flag = 'Y' then
         SELECT address_id
         INTO x_ship_to_address_id
         FROM pa_customer_sites_v
         WHERE address_id = p_ship_to_address_id AND
               customer_id = p_customer_id AND
               site_use_code = 'SHIP_TO';

      ELSIF (p_check_id_flag='N') THEN
         x_ship_to_address_id := p_ship_to_address_id;

      ELSIF (p_check_id_flag = 'A') THEN
             IF (p_work_site_name IS NULL) THEN
                 -- Return a null ID since the name is null.
                  x_ship_to_address_id := NULL;
             ELSE

                 -- Find the ID which matches the Name passed
                 OPEN c_ids;
                    LOOP
                    	FETCH c_ids INTO l_current_id;
                    	EXIT WHEN c_ids%NOTFOUND;
                    	IF (l_current_id = p_ship_to_address_id) THEN
                         	l_id_found_flag := 'Y';
                        	x_ship_to_address_id := p_ship_to_address_id;
                    	END IF;
                    END LOOP;
                    l_num_ids := c_ids%ROWCOUNT;
                 CLOSE c_ids;

                 IF (l_num_ids = 0) THEN
                     -- No IDs for name
                     RAISE NO_DATA_FOUND;
                 ELSIF (l_num_ids = 1) THEN
                     -- Since there is only one ID for the name use it.
                     x_ship_to_address_id := l_current_id;
                 ELSIF (l_id_found_flag = 'N') THEN
                     -- More than one ID for the name and none of the IDs matched
                     -- the ID passed in.
                        RAISE TOO_MANY_ROWS;
                 END IF;
             END IF;

      else
         x_ship_to_address_id := NULL;
      end if;
   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when NO_DATA_FOUND then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_SHIP_TO_ADDR_ID_INVALID';
   when TOO_MANY_ROWS then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_SHIP_TO_ADDR_NOT_UNIQUE';
   when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise;
END CHECK_WORK_SITE_NAME_OR_ID;


-- API name		: Check_Contact_Name_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_id                   IN NUMBER     Required
-- p_project_contact_type_code     IN VARCHAR2   Required
-- p_contact_id                    IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_contact_name                  IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_contact_id                    OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CONTACT_NAME_OR_ID
(  p_customer_id                   IN NUMBER
  ,p_project_contact_type_code     IN VARCHAR2
  ,p_contact_id                    IN NUMBER     := FND_API.G_MISS_NUM
  ,p_contact_name                  IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,p_address_id                    IN NUMBER     := NULL -- Added for Bug 2964227
  ,x_contact_id                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_current_id NUMBER := NULL;
   l_num_ids NUMBER := 0;
   l_id_found_flag VARCHAR(1) := 'N';

   --commented the filter condition on usage_code for Bug#5160623.
   CURSOR c_ids IS
      SELECT contact_id
      FROM pa_customer_contact_names_v
      WHERE upper(rtrim(contact_name)) = upper(rtrim(p_contact_name)) AND -- Bug 4015644
            customer_id = p_customer_id  /* AND
            usage_code = decode(p_project_contact_type_code, 'BILLING', 'BILL_TO',
                                'SHIPPING', 'SHIP_TO', usage_code)  */
	AND (address_id is null OR  nvl(p_address_id, address_id)= address_id ); -- Added for Bug 2964227

-- Bug 2964227 This change is backward compatible. Even if new parmeter is not passed, this will work unaffected.

BEGIN
   if (p_contact_id = FND_API.G_MISS_NUM) OR (p_contact_id is NULL) then
 	 if (p_contact_name is not NULL) then
	      SELECT contact_id
	      INTO x_contact_id
	      FROM pa_customer_contact_names_v
	      WHERE upper(rtrim(contact_name)) = upper(rtrim(p_contact_name)) AND -- Bug 4015644
	            customer_id = p_customer_id AND
	            usage_code = decode(p_project_contact_type_code, 'BILLING', 'BILL_TO',
	                                'SHIPPING', 'SHIP_TO', usage_code)
    	       AND (address_id is null OR  nvl(p_address_id, address_id)= address_id ); -- Added for Bug 2964227
      else
	  x_contact_id := NULL;
      end if;

   else
      if p_check_id_flag = 'Y' then

         -- Commented Following SQL for Performance Bug 4878913 SQL ID : 14907893
         -- SELECT contact_id
         -- INTO x_contact_id
         -- FROM pa_customer_contact_names_v
         -- WHERE contact_id = p_contact_id AND
         --      customer_id = p_customer_id AND
         --      usage_code = decode(p_project_contact_type_code, 'BILLING', 'BILL_TO',
         --                          'SHIPPING', 'SHIP_TO', usage_code)
         --  AND (address_id is null OR  nvl(p_address_id, address_id)= address_id ); -- Added for Bug 2964227

         -- Start of NEW SQL for Bug 4878913 SQL ID : 14907893
	 SELECT distinct acct_role.cust_account_role_id contact_id
	 INTO x_contact_id
	 FROM hz_cust_account_roles acct_role
	    ,hz_role_responsibility role_resp
	 WHERE
	  acct_role.cust_account_role_id = role_resp.cust_account_role_id
	  and acct_role.role_type = 'CONTACT'
	  and nvl(acct_role.current_role_state, 'A') = 'A'
	  and acct_role.cust_account_role_id = p_contact_id
	  AND acct_role.cust_account_id = p_customer_id
	  AND role_resp.responsibility_type = decode(p_project_contact_type_code, 'BILLING', 'BILL_TO',
                                     		   'SHIPPING', 'SHIP_TO',role_resp.responsibility_type)
	 AND (acct_role.cust_acct_site_id is null OR nvl(p_address_id,acct_role.cust_acct_site_id)=acct_role.cust_acct_site_id );
	-- End of NEW SQL for Bug 4878913 SQL ID : 14907893

--      ELSIF (p_check_id_flag='N') THEN
--         x_contact_id := p_contact_id;
      ELSIF (p_check_id_flag = 'A') THEN
             IF (p_contact_name IS NULL) THEN
                 -- Return a null ID since the name is null.
                   x_contact_id := NULL;
             ELSE

                 -- Find the ID which matches the Name passed
                 OPEN c_ids;
                    LOOP
                    	FETCH c_ids INTO l_current_id;
                    	EXIT WHEN c_ids%NOTFOUND;
                    	IF (l_current_id = p_contact_id) THEN
                         	l_id_found_flag := 'Y';
                        	x_contact_id := p_contact_id;
                    	END IF;
                    END LOOP;
                    l_num_ids := c_ids%ROWCOUNT;
                 CLOSE c_ids;

                 IF (l_num_ids = 0) THEN
                     -- No IDs for name
                     RAISE NO_DATA_FOUND;
                 ELSIF (l_num_ids = 1) THEN
                     -- Since there is only one ID for the name use it.
                     x_contact_id := l_current_id;
                 ELSIF (l_id_found_flag = 'N') THEN
                     -- More than one ID for the name and none of the IDs matched
                     -- the ID passed in.
                        RAISE TOO_MANY_ROWS;
                 END IF;
             END IF;
      else
         x_contact_id := NULL;
      end if;
   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when NO_DATA_FOUND then
      x_contact_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_CONTACT_ID_INVALID';
   when TOO_MANY_ROWS then
      x_contact_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_CONTACT_NAME_NOT_UNIQUE';
   when OTHERS then
      x_contact_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_CUSTOMERS_CONTACTS_UTILS', p_procedure_name  => 'CHECK_CONTACT_NAME_OR_ID');
      raise;
END CHECK_CONTACT_NAME_OR_ID;


-- API name		: Check_Contact_Typ_Name_Or_Code
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_contact_type_code     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_contact_type_name     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_project_contact_type_code     OUT VARCHAR2  Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CONTACT_TYP_NAME_OR_CODE
(  p_project_contact_type_code     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_project_contact_type_name     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_project_contact_type_code     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_current_id VARCHAR2(30) := NULL;
   l_num_ids NUMBER := 0;
   l_id_found_flag VARCHAR(1) := 'N';


   CURSOR c_ids IS
      SELECT lookup_code
      FROM pa_lookups
      WHERE upper(meaning) = upper(p_project_contact_type_name) AND
            lookup_type = 'PROJECT CONTACT TYPE' AND
            trunc(sysdate) between start_date_active and nvl(end_date_active, trunc(sysdate));

BEGIN
   if (p_project_contact_type_code = FND_API.G_MISS_CHAR) OR
      (p_project_contact_type_code is NULL) then
      if (p_project_contact_type_name is not NULL) then
           SELECT lookup_code
           INTO x_project_contact_type_code
           FROM pa_lookups
           WHERE upper(meaning) = upper(p_project_contact_type_name) AND
                 lookup_type = 'PROJECT CONTACT TYPE' AND
                 trunc(sysdate) between start_date_active and nvl(end_date_active, trunc(sysdate));
      else
	  x_project_contact_type_code := NULL;
      end if;

   else
      if p_check_id_flag = 'Y' then
         SELECT lookup_code
         INTO x_project_contact_type_code
         FROM pa_lookups
         WHERE lookup_code = p_project_contact_type_code AND
               lookup_type = 'PROJECT CONTACT TYPE' AND
               trunc(sysdate) between start_date_active and nvl(end_date_active, trunc(sysdate));

      ELSIF (p_check_id_flag='N') THEN
         x_project_contact_type_code := p_project_contact_type_code;

      ELSIF (p_check_id_flag = 'A') THEN
             IF (p_project_contact_type_name IS NULL) THEN
                 -- Return a null ID since the name is null.
                  x_project_contact_type_code := NULL;
             ELSE

                 -- Find the ID which matches the Name passed
                 OPEN c_ids;
                    LOOP
                    	FETCH c_ids INTO l_current_id;
                    	EXIT WHEN c_ids%NOTFOUND;
                    	IF (l_current_id = p_project_contact_type_code) THEN
                         	l_id_found_flag := 'Y';
                        	x_project_contact_type_code := p_project_contact_type_code;
                    	END IF;
                    END LOOP;
                    l_num_ids := c_ids%ROWCOUNT;
                 CLOSE c_ids;

                 IF (l_num_ids = 0) THEN
                     -- No IDs for name
                     RAISE NO_DATA_FOUND;
                 ELSIF (l_num_ids = 1) THEN
                     -- Since there is only one ID for the name use it.
                     x_project_contact_type_code := l_current_id;
                 ELSIF (l_id_found_flag = 'N') THEN
                     -- More than one ID for the name and none of the IDs matched
                     -- the ID passed in.
                        RAISE TOO_MANY_ROWS;
                 END IF;
             END IF;


      else
         x_project_contact_type_code := NULL;
      end if;
   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when NO_DATA_FOUND then
      x_project_contact_type_code := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_CONTACT_TYP_CODE_INVALID';
   when TOO_MANY_ROWS then
      x_project_contact_type_code := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_CONT_TYP_CODE_NOT_UNIQUE';
   when OTHERS then
      x_project_contact_type_code := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_CUSTOMERS_CONTACTS_UTILS', p_procedure_name  => 'CHECK_CONTACT_TYP_NAME_OR_CODE');
      raise;
END CHECK_CONTACT_TYP_NAME_OR_CODE;


-- API name		: Check_Duplicate_Customer
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_DUPLICATE_CUSTOMER
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_dummy                         VARCHAR2(1) := NULL;
   CURSOR C(c_project_id NUMBER, c_customer_id NUMBER) IS
      SELECT 'x'
      FROM pa_project_customers
      WHERE project_id = p_project_id AND
            customer_id = p_customer_id;
BEGIN
   if (p_customer_id is not null) then
	   open C(p_project_id, p_customer_id);
	   fetch C into l_dummy;
	   if l_dummy is not NULL then
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_error_msg_code := 'PA_ALL_DUPLICATE_NAME';
	   else
	      x_return_status := FND_API.G_RET_STS_SUCCESS;
	   end if;
	   close C;
   else
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_error_msg_code := 'PA_CUST_NAME_OR_NUM_REQD';
   end if;
EXCEPTION
   when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise;
END CHECK_DUPLICATE_CUSTOMER;


-- API name		: Check_Duplicate_Contact
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_contact_id                    IN NUMBER     Required
-- p_project_contact_type_code     IN VARCHAR2   Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_DUPLICATE_CONTACT
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_contact_id                    IN NUMBER
  ,p_project_contact_type_code     IN VARCHAR2
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_dummy                         VARCHAR2(1) := NULL;
   CURSOR C(c_project_id NUMBER, c_customer_id NUMBER, c_contact_id NUMBER,
            c_project_contact_type_code VARCHAR2) IS
      SELECT 'x'
      FROM pa_project_contacts
      WHERE project_id = c_project_id AND
            customer_id = c_customer_id AND
            contact_id = c_contact_id AND
            project_contact_type_code = c_project_contact_type_code;
BEGIN
   if (p_contact_id is not null) then
	   open C(p_project_id, p_customer_id, p_contact_id, p_project_contact_type_code);
	   fetch C into l_dummy;
	   if l_dummy is not NULL then
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_error_msg_code := 'PA_ALL_DUPLICATE_NAME';
	   else
	      x_return_status := FND_API.G_RET_STS_SUCCESS;
	   end if;
	   close C;
   else
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_error_msg_code := 'PA_CONTACT_NAME_REQD';
   end if;
EXCEPTION
   when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise;
END CHECK_DUPLICATE_CONTACT;


-- API name		: Check_Contribution_Percentage
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_bill_split           IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CONTRIBUTION_PERCENTAGE
(  p_customer_bill_split           IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN
   if (p_customer_bill_split < 0) OR (p_customer_bill_split > 100) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_CUST_BILL_SPLIT_INVALID';
   else
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   end if;
EXCEPTION
   when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise;
END CHECK_CONTRIBUTION_PERCENTAGE;


-- API name		: Check_Contribution_Total
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_bill_split           IN NUMBER     Required
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CONTRIBUTION_TOTAL
(  p_customer_bill_split           IN NUMBER
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_total                         NUMBER;
   CURSOR C(c_project_id NUMBER, c_customer_id NUMBER) IS
      SELECT sum(customer_bill_split)
      FROM pa_project_customers
      WHERE project_id = c_project_id AND
            customer_id <> c_customer_id;
BEGIN
   open C(p_project_id, p_customer_id);
   fetch C into l_total;
   close C;
   l_total := l_total + p_customer_bill_split;
   if l_total > 100 then
      x_return_status := FND_API.G_RET_STS_ERROR;
     -- space in the error msg code due to error in akuploading to seed115
      x_error_msg_code := 'PA_TOT_CUST_BILL_SPLIT_INVLD';
   else
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   end if;

EXCEPTION
   when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise;
END CHECK_CONTRIBUTION_TOTAL;


-- API name		: Check_Bill_Work_Sites_Required
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_bill_split           IN NUMBER     Required
-- p_bill_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_ship_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_BILL_WORK_SITES_REQUIRED
(  p_customer_bill_split           IN NUMBER
  ,p_bill_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_ship_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN
   if p_customer_bill_split > 0 then
      if ((p_bill_to_address_id = FND_API.G_MISS_NUM) OR (p_bill_to_address_id is NULL)) OR
         ((p_ship_to_address_id = FND_API.G_MISS_NUM) OR (p_ship_to_address_id is NULL)) then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_msg_code := 'PA_BILL_AND_WORK_SITE_REQD';
         return;
      end if;
   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise;
END CHECK_BILL_WORK_SITES_REQUIRED;


-- API name		: Check_Cc_Prvdr_Flag_Contrib
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_customer_bill_split           IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CC_PRVDR_FLAG_CONTRIB
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_customer_bill_split           IN NUMBER
  ,p_action                        IN VARCHAR2
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_cc_prvdr_flag                 VARCHAR2(1);

   CURSOR C1(c_project_id NUMBER) IS
      SELECT cc_prvdr_flag
      FROM pa_project_types
      WHERE project_type =
         (SELECT project_type
          FROM pa_projects_all
          WHERE project_id = c_project_id);

/* Changed the having condition to the where condition in the following cursor c2
   to avoid full table scan of pa_project_customers -Bug 2782177 */

   CURSOR C2(c_project_id NUMBER) IS
      SELECT count(customer_id) count, sum(customer_bill_split) sum
      FROM pa_project_customers
      WHERE project_id = c_project_id
      GROUP BY project_id;

   CURSOR C3(c_project_id NUMBER, c_customer_id NUMBER) IS
      SELECT '1'
      FROM pa_project_customers
      WHERE project_id = c_project_id AND
            customer_id = c_customer_id;

   l_dummy                         VARCHAR2(1) := NULL;
   l_recinfo                       C2%ROWTYPE;
BEGIN
   open C1(p_project_id);
   fetch C1 into l_cc_prvdr_flag;
   close C1;

   open C2(p_project_id);
   fetch C2 into l_recinfo;
   close C2;

   if l_cc_prvdr_flag = 'Y' then
      if p_action = 'INSERT' then
         if l_recinfo.count > 0 then
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_msg_code := 'PA_ONLY_ONE_CUST_ALLOWED';
            return;
         else
            if p_customer_bill_split <> 100 then
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_error_msg_code := 'PA_PR_INSUF_BILL_SPLIT';
                return;
            end if;
         end if;
      elsif p_action = 'UPDATE' then
         if l_recinfo.count > 1 then
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_msg_code := 'PA_ONLY_ONE_CUST_ALLOWED';
            return;
         elsif l_recinfo.count = 1 then
            open C3(p_project_id, p_customer_id);
            fetch C3 into l_dummy;
            close C3;

            if l_dummy is NULL then
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_error_msg_code := 'PA_ONLY_ONE_CUST_ALLOWED';
               return;
            else
               if p_customer_bill_split <> 100 then
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  x_error_msg_code := 'PA_PR_INSUF_BILL_SPLIT';
                  return;
               end if;
            end if;
         end if;
      end if;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise;
END CHECK_CC_PRVDR_FLAG_CONTRIB;


-- API name		: Check_Receiver_Proj_Enterable
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_receiver_task_id              IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_bill_another_project_flag     OUT VARCHAR2  Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_RECEIVER_PROJ_ENTERABLE
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_receiver_task_id              IN NUMBER     := FND_API.G_MISS_NUM
  ,x_bill_another_project_flag     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_dummy                         VARCHAR2(1);

   CURSOR C1(c_project_id NUMBER) IS
      SELECT '1'
      FROM
/* Commented for Bug 2499051
      pa_projects a,
*/
      pa_project_types b
      WHERE b.project_type_class_code = 'CONTRACT' AND
            b.project_type =
               (SELECT project_type
                FROM  pa_projects_all
                WHERE project_id = c_project_id) AND
            (b.cc_prvdr_flag = 'N' OR b.cc_prvdr_flag is NULL);
   CURSOR C2(c_customer_id NUMBER) IS
      SELECT '1'
      FROM pa_implementations_all
      WHERE customer_id = c_customer_id;
   CURSOR C3 IS
      SELECT '1'
      FROM pa_implementations
      WHERE cc_ic_billing_prvdr_flag = 'Y';
BEGIN
   open C1(p_project_id);
   fetch C1 into l_dummy;

   open C2(p_customer_id);
   fetch C2 into l_dummy;

   open C3;
   fetch C3 into l_dummy;

   if (C1%FOUND AND C2%FOUND AND C3%FOUND) then
      if (p_receiver_task_id <> FND_API.G_MISS_NUM) AND (p_receiver_task_id is not NULL) then
         x_bill_another_project_flag := 'Y';
      else
         x_bill_another_project_flag := 'N';
      end if;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   else
      if (p_receiver_task_id <> FND_API.G_MISS_NUM) AND (p_receiver_task_id is not NULL) then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_msg_code := 'PA_REC_PROJ_NOT_ALLOWED';
      else
         x_bill_another_project_flag := 'N';
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      end if;
   end if;

   close C1;
   close C2;
   close C3;
EXCEPTION
   when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise;
END CHECK_RECEIVER_PROJ_ENTERABLE;


-- API name		: Check_Invoice_Currency_Info
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_inv_currency_code             IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_type                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_date                 IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_inv_exchange_rate             IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_allow_user_rate_type_flag     IN VARCHAR2   Required Default = 'N'
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_INVOICE_CURRENCY_INFO
(  p_project_id                    IN NUMBER
  ,p_inv_currency_code             IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_date                 IN DATE       := FND_API.G_MISS_DATE
  ,p_inv_exchange_rate             IN NUMBER     := FND_API.G_MISS_NUM
  ,p_allow_user_rate_type_flag     IN VARCHAR2   := 'N'
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_project_currency_code         VARCHAR2(10);
   l_project_currency_code2        VARCHAR2(10);
   l_mcb_flag                      VARCHAR2(1);
   l_cc_prvdr_flag                 VARCHAR2(1); --bug#5554475
   CURSOR C1(c_project_id NUMBER) IS
      SELECT project_currency_code, multi_currency_billing_flag
      FROM pa_projects_all
      WHERE project_id = c_project_id;
BEGIN
-- bug 2070847
   open C1(p_project_id);
   fetch C1 into l_project_currency_code, l_mcb_flag;
   close C1;

   if p_inv_currency_code = FND_API.G_MISS_CHAR then
      l_project_currency_code2 := NULL;
   else
      l_project_currency_code2 := p_inv_currency_code;
   end if;


-- Start of addition for bug 5554475
   select pt.cc_prvdr_flag
   into l_cc_prvdr_flag
   FROM         pa_project_types pt
   ,            pa_projects p
   WHERE        p.project_type = pt.project_type
   AND          p.project_id = p_project_id
   AND		p.org_id     = pt.org_id;


   If (nvl(p_inv_currency_code,FND_API.G_MISS_CHAR)<> FND_API.G_MISS_CHAR) then
      IF ((p_inv_currency_code <> l_project_currency_code) AND ((l_mcb_flag = 'N') and (l_cc_prvdr_flag = 'N'))) then
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_error_msg_code := 'PA_INV_CURR_NON_MCB_OPTION';
               return;
      END if;
   END if;
   -- End of addition for bug 5554475

     -- anlee, bug 2461954
     if (l_project_currency_code <> nvl(l_project_currency_code2, l_project_currency_code))
        AND ((l_mcb_flag = 'Y') OR (l_cc_prvdr_flag = 'Y')) --bug#5554475
     -- anlee end of changes
     THEN
      if (p_inv_rate_type is NULL) or (p_inv_rate_type = FND_API.G_MISS_CHAR) then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_msg_code := 'PA_RATE_TYPE_REQD';
         return;
      end if;
     END IF; --bug 2131206

      if ((upper(p_inv_rate_type) = 'USER') AND ((p_allow_user_rate_type_flag = 'N')
       /*OR
         (pa_multi_currency.is_user_rate_type_allowed(p_inv_currency_code,
          l_project_currency_code, nvl(p_inv_rate_date, sysdate)) = 'N')*/
      )) then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_msg_code := 'PA_USR_RATE_NOT_ALLOWED';
         return;
      end if;

      if upper(p_inv_rate_type) = 'USER' then
         if
    /*       (
     (p_inv_rate_date = FND_API.G_MISS_DATE) OR (p_inv_rate_date is NULL)) OR*/
            ((p_inv_exchange_rate = FND_API.G_MISS_NUM) OR (p_inv_exchange_rate is NULL)) then
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_msg_code := 'PA_XCH_RATE_AND_DATE_REQD';
            return;
         end if;
      end if;

/*  elsif l_project_currency_code = l_project_currency_code2 then
      if ((p_inv_rate_type <> FND_API.G_MISS_CHAR) AND (p_inv_rate_type is not NULL)) OR
         ((p_inv_rate_date <> FND_API.G_MISS_DATE) AND (p_inv_rate_date is not NULL)) OR
         ((p_inv_exchange_rate <>FND_API.G_MISS_NUM) AND (p_inv_exchange_rate is not NULL)) then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_msg_code := 'PA_RATE_INFO_NOT_ALLOWED';
         return;
      end if;
   end if;
*/

   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise;
END CHECK_INVOICE_CURRENCY_INFO;


-- API name		: Check_Update_Contrib_Allowed
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required
/*Changes for the enhancement 2520222.This code will check
if the assigned customer is having valid funding lines and
   user is trying to change existing contribution from non zero to zero
then it will give error.*/

PROCEDURE CHECK_UPDATE_CONTRIB_ALLOWED
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_customer_bill_split           IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   c1_exists                       VARCHAR2(1) := NULL;
   c2_exists                       VARCHAR2(1) := NULL;
   l_customer_bill_split           NUMBER;

   CURSOR C1(c_project_id NUMBER) IS
   SELECT 'x'
   FROM sys.dual
   WHERE exists
         (SELECT null
          FROM pa_draft_revenues r
          WHERE r.project_id = c_project_id) OR
         exists
         (SELECT null
          FROM pa_draft_invoices i
          WHERE i.project_id = c_project_id);

/* BUG#2547423. Changed pa_agreements to pa_agreements_all */
/*Commented the below code for enhancement 2520222*/
   /*CURSOR C2(c_project_id NUMBER, c_customer_id NUMBER) IS
   SELECT 'x'
   FROM pa_agreements_all a, pa_project_fundings f
   WHERE a.customer_id+0 = c_customer_id AND
         a.agreement_id  = f.agreement_id AND
         f.project_id    = c_project_id AND
         f.budget_type_code = 'BASELINE';*/

/*Added the below cursor for the enhancement 2520222*/

      CURSOR C2(c_project_id NUMBER, c_customer_id NUMBER) IS
        SELECT 'x'
        FROM    pa_agreements_all a,
                pa_summary_project_fundings f
        WHERE a.customer_id   = c_customer_id
          AND a.agreement_id  = f.agreement_id
          AND f.project_id    = c_project_id
          AND ( f.total_unbaselined_amount <>0
                OR f.total_baselined_amount <> 0);


   CURSOR C3(c_project_id NUMBER, c_customer_id NUMBER) IS
   SELECT customer_bill_split
   FROM pa_project_customers
   WHERE project_id = c_project_id AND
         customer_id = c_customer_id;
BEGIN
   open C1(p_project_id);
   fetch C1 into c1_exists;
   close C1;

   open C2(p_project_id, p_customer_id);
   fetch C2 into c2_exists;
   close C2;

   if (c1_exists is not NULL)  THEN
 /*Commented for bug 2520222 OR (c2_exists is not NULL))*/
      open C3(p_project_id, p_customer_id);
      fetch C3 into l_customer_bill_split;
      close C3;

      if p_customer_bill_split <> l_customer_bill_split then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_msg_code := 'PA_UPD_CUST_NOT_ALLOWED';
         return;
      end if;
/*Added for bug 2520222*/
  elsif (p_customer_bill_split = 0) then
     if (c2_exists is not NULL ) then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_msg_code := 'PA_BILL_CUST_CONTR_ZERO';
     return;
     end if;
  end if;


     x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise;
END CHECK_UPDATE_CONTRIB_ALLOWED;


-- API name		: Check_Delete_Customer_Allowed
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_DELETE_CUSTOMER_ALLOWED
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   c_exists                        VARCHAR2(1);

/* BUG#2547423. Changed pa_agreements to pa_agreements_all */
   CURSOR C(c_project_id NUMBER, c_customer_id NUMBER) IS
   SELECT 'x'
   FROM pa_agreements_all a, pa_project_fundings f
   WHERE a.customer_id+0 = c_customer_id AND
         a.agreement_id = f.agreement_id AND
         f.project_id = c_project_id;
BEGIN
   open C(p_project_id, p_customer_id);
   fetch C into c_exists;
   close C;

   if c_exists is not NULL then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_PR_CANT_DEL_FUND_CUST';
   else
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   end if;
EXCEPTION
   when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise;
END CHECK_DELETE_CUSTOMER_ALLOWED;


-- API name		: Get_Org_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           : None.
-- Return Type          : Number
FUNCTION GET_ORG_ID
RETURN NUMBER
IS
   x_org_id                        NUMBER;
BEGIN
   SELECT org_id
   INTO x_org_id
   FROM pa_implementations;
   return x_org_id;
EXCEPTION
   when OTHERS then
      null;
END GET_ORG_ID;


-- API name		: Check_Customer_Name_And_Number
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_name                 IN VARCHAR2   Required
-- p_customer_number               IN VARCHAR2   Required
-- x_customer_id                   OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CUSTOMER_NAME_AND_NUMBER
(  p_customer_name                 IN VARCHAR2
  ,p_customer_number               IN VARCHAR2
  ,x_customer_id                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

BEGIN
      SELECT customer_id
      INTO x_customer_id
      FROM pa_customers_v
      WHERE upper(customer_number) = upper(p_customer_number) and
	    upper(substr(customer_name,1,50)) = upper(substr(p_customer_name,1,50))  -- Bug 8314123
 	     and status = 'A';

      x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when NO_DATA_FOUND then
      x_customer_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_CUST_NAME_NUMBER_INVALID';
   when TOO_MANY_ROWS then
      x_customer_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_CUST_NAME_NOT_UNIQUE';
   when OTHERS then
      x_customer_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_CUSTOMERS_CONTACTS_UTILS', p_procedure_name  => 'CHECK_CUSTOMER_NAME_AND_NUMBER');
      raise;
END CHECK_CUSTOMER_NAME_AND_NUMBER;


-- API name		: Get_Contribution_Total
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           : Project_Id
-- Return Type          : Number
FUNCTION GET_CONTRIBUTION_TOTAL (p_project_id IN NUMBER)
RETURN NUMBER
IS
   l_total    NUMBER;
   CURSOR C(c_project_id NUMBER) IS
   SELECT sum(customer_bill_split)
   FROM pa_project_customers
   WHERE project_id = c_project_id;
BEGIN
   OPEN C(p_project_id);
   FETCH C INTO l_total;
   CLOSE C;
   return l_total;
EXCEPTION
   when OTHERS then
      null;
END GET_CONTRIBUTION_TOTAL;


--sunkalya federal changes Bug#5511353
-- Procedure            : Get_Highest_Contr_Fed_Cust
-- Type                 : PRIVATE
-- Purpose              : Gets the highest contribution federal customer. If contribution is same,
--                        then sorts on name and if names are also same, then sorts on
--                        customer id. This API is included as a part of
--			  federal changes.
-- Note                 :
-- Assumptions          :
-- Parameters                   Type          Required    Description and Purpose
-- ---------------------------  ------        --------    --------------------------------------------------------
-- p_project_id                 NUMBER           Y        Project ID for which highest contribution customer is
--                                                        to be returned
-- x_highst_contr_cust_id       NUMBER           N        Customer ID of the highest contribution customer
PROCEDURE Get_Highest_Contr_Fed_Cust(
          p_api_version           IN   NUMBER   := 1.0
        , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only         IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
        , p_debug_mode            IN   VARCHAR2 := 'N'
        , p_project_id            IN   NUMBER
        , x_highst_contr_cust_id  OUT  NOCOPY NUMBER
        , x_return_status         OUT  NOCOPY VARCHAR2
        , x_msg_count             OUT  NOCOPY NUMBER
        , x_msg_data              OUT  NOCOPY VARCHAR2
        ) IS

l_msg_count             NUMBER := 0;
l_debug_mode            VARCHAR2(1);
l_data                  VARCHAR2(2000);
l_msg_data              VARCHAR2(2000);
l_msg_index_out         NUMBER;

l_debug_level2          CONSTANT NUMBER := 2;
l_debug_level3          CONSTANT NUMBER := 3;
l_debug_level4          CONSTANT NUMBER := 4;
l_debug_level5          CONSTANT NUMBER := 5;

l_return_cust_id_tbl    SYSTEM.PA_NUM_TBL_TYPE;
l_return_cust_name_tbl  SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
l_return_cust_num_tbl   SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_return_flag_tbl       SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
Invalid_Arg_Exc		EXCEPTION;

CURSOR
	cur_get_ordered_customers
IS
SELECT
	HZ_C.cust_account_id ,
	HZ_P.party_name ,
	HZ_P.party_number,
	'Y'
FROM
	pa_project_customers proj_cust,
	hz_cust_accounts HZ_C,
	HZ_PARTIES HZ_P
WHERE
	proj_cust.project_id	= p_project_id
AND	proj_cust.customer_id	= hz_c.cust_account_id
AND	hz_c.party_id		= hz_p.party_id
ORDER BY
	proj_cust.customer_bill_split desc,
	hz_p.party_name,
	HZ_P.party_number ;

BEGIN

	  x_highst_contr_cust_id	:= null;
	  x_msg_count			:= 0;
	  x_return_status		:= FND_API.G_RET_STS_SUCCESS;
	  l_debug_mode			:= NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');


	  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
		FND_MSG_PUB.initialize;
	  END IF;

	  IF (p_commit = FND_API.G_TRUE) THEN
		savepoint get_highest_cont_cust_svpt;
	  END IF;

	  IF l_debug_mode = 'Y' THEN

		PA_DEBUG.set_curr_function( p_function   => 'Get_Highest_Contr_Fed_Cust',
					    p_debug_mode => l_debug_mode );
	  END IF;

	  IF l_debug_mode = 'Y' THEN

		Pa_Debug.g_err_stage:= 'Printing Input parameters';
		Pa_Debug.WRITE(G_PKG_NAME,Pa_Debug.g_err_stage,
					   l_debug_level3);

		Pa_Debug.WRITE(G_PKG_NAME,'p_project_id'||':'||p_project_id,
					   l_debug_level3);
	  END IF;

	  IF l_debug_mode = 'Y' THEN
		  Pa_Debug.g_err_stage:= 'Validating Input parameters';
		  Pa_Debug.WRITE(G_PKG_NAME,Pa_Debug.g_err_stage,
					     l_debug_level3);
	  END IF;

	  IF ( p_project_id IS NULL OR p_project_id	= FND_API.G_MISS_NUM)
	  THEN
		   IF l_debug_mode = 'Y' THEN
		       Pa_Debug.g_err_stage:= 'PA_CUSTOMERS_CONTACTS_UTILS : Get_Highest_Contr_Fed_Cust :
				    p_project_id is NULL';
		       Pa_Debug.WRITE(G_PKG_NAME,Pa_Debug.g_err_stage,
					     l_debug_level3);
		   END IF;
		   RAISE Invalid_Arg_Exc;

	  END IF;

	  OPEN  cur_get_ordered_customers;
	  FETCH cur_get_ordered_customers BULK COLLECT INTO l_return_cust_id_tbl, l_return_cust_name_tbl, l_return_cust_num_tbl, l_return_flag_tbl;
	  CLOSE cur_get_ordered_customers;

	    --If the return table is not NULL
	    IF nvl(l_return_flag_tbl.LAST,0) > 0 THEN
		--Return the first record that has return flag as 'Y'
		FOR i IN l_return_flag_tbl.FIRST..l_return_flag_tbl.LAST LOOP
		    IF l_return_flag_tbl(i) = 'Y' THEN
			x_highst_contr_cust_id   := l_return_cust_id_tbl(i);
			EXIT;
		    END IF;
		END LOOP;
	    END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;


     x_highst_contr_cust_id   := null;


     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO get_highest_cont_cust_svpt;
     END IF;

     l_msg_count := Fnd_Msg_Pub.count_msg;
     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_FALSE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := ' PA_CUSTOMERS_CONTACTS_UTILS : Get_Highest_Contr_Fed_Cust : NULL parameters passed';


     x_highst_contr_cust_id   := null;


     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO get_highest_cont_cust_svpt;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_CUSTOMERS_CONTACTS_UTILS'
                    , p_procedure_name  => 'Get_Highest_Contr_Fed_Cust'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(G_PKG_NAME,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;


     x_highst_contr_cust_id   := null;


     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO get_highest_cont_cust_svpt;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
	   ( p_pkg_name         => 'PA_CUSTOMERS_CONTACTS_UTILS'
	    , p_procedure_name  => 'Get_Highest_Contr_Fed_Cust'
	    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(G_PKG_NAME,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END Get_Highest_Contr_Fed_Cust;

--sunkalya federal changes Bug#5511353



END PA_CUSTOMERS_CONTACTS_UTILS;

/
