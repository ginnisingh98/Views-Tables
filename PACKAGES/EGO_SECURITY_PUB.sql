--------------------------------------------------------
--  DDL for Package EGO_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_SECURITY_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOPSECS.pls 115.3 2003/01/11 02:47:50 dphilip noship $ */
/*---------------------------------------------------------------------------+
 | This package contains public API for Applications Security                |
 +---------------------------------------------------------------------------*/


 TYPE ID_TBL_TYPE IS TABLE OF VARCHAR2(30)
 INDEX BY BINARY_INTEGER;

  --1. Grant Privilege
  ------------------------------------
  PROCEDURE grant_role
  (
   p_api_version           IN  NUMBER,
   p_role_name             IN  VARCHAR2,
   p_object_name           IN  VARCHAR2,
   p_instance_type         IN  VARCHAR2,
   p_instance_set_id       IN  NUMBER,
   p_instance_pk1_value    IN  VARCHAR2,
   p_instance_pk2_value    IN  VARCHAR2,
   p_instance_pk3_value    IN  VARCHAR2,
   p_instance_pk4_value    IN  VARCHAR2,
   p_instance_pk5_value    IN  VARCHAR2,
   p_party_id              IN  NUMBER,
   p_start_date            IN  DATE,
   p_end_date              IN  DATE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_errorcode             OUT NOCOPY NUMBER
  );

    -- Start OF comments
    -- API name  : Grant
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Grant a Role on object instances to a Party.
    --             If this operation fails then the grant is not
    --             done and error code is returned.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
----------------------------------------------------------------------------

  --1 a. Grant Privilege
  ------------------------------------
  PROCEDURE grant_role
  (
   p_api_version        IN  NUMBER,
   p_role_name          IN  VARCHAR2,
   p_object_name        IN  VARCHAR2,
   p_instance_type      IN  VARCHAR2,
   p_object_key         IN  NUMBER,
   p_party_id           IN  NUMBER,
   p_start_date         IN  DATE,
   p_end_date           IN  DATE,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_errorcode          OUT NOCOPY NUMBER
  );

    -- Start OF comments
    -- API name  : Grant
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Grant a Role on object instances to a Party.
    --             If this operation fails then the grant is not
    --             done and error code is returned.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments


---------------------------------------------------------------------

  --11. Grant Privilege
  ------------------------------------
  PROCEDURE grant_role_guid
  (
   p_api_version           IN  NUMBER,
   p_role_name             IN  VARCHAR2,
   p_object_name           IN  VARCHAR2,
   p_instance_type         IN  VARCHAR2,
   p_instance_set_id       IN  NUMBER,
   p_instance_pk1_value    IN  VARCHAR2,
   p_instance_pk2_value    IN  VARCHAR2,
   p_instance_pk3_value    IN  VARCHAR2,
   p_instance_pk4_value    IN  VARCHAR2,
   p_instance_pk5_value    IN  VARCHAR2,
   p_party_id              IN  NUMBER,
   p_start_date            IN  DATE,
   p_end_date              IN  DATE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_errorcode             OUT NOCOPY NUMBER,
   x_grant_guid            OUT NOCOPY RAW
  );

    -- Start OF comments
    -- API name  : Grant
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Grant a Role on object instances to a Party.
    --             If this operation fails then the grant is not
    --             done and error code is returned.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
----------------------------------------------------------------------------

  --11 a. Grant Privilege
  ------------------------------------
  PROCEDURE grant_role_guid
  (
   p_api_version        IN  NUMBER,
   p_role_name          IN  VARCHAR2,
   p_object_name        IN  VARCHAR2,
   p_instance_type      IN  VARCHAR2,
   p_object_key         IN  NUMBER,
   p_party_id           IN  NUMBER,
   p_start_date         IN  DATE,
   p_end_date           IN  DATE,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_errorcode          OUT NOCOPY NUMBER,
   x_grant_guid         OUT NOCOPY RAW
  );

    -- Start OF comments
    -- API name  : Grant
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Grant a Role on object instances to a Party.
    --             If this operation fails then the grant is not
    --             done and error code is returned.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments


---------------------------------------------------------------------


 --2. Revoke Privilege
  --------------------------
  PROCEDURE revoke_grant
  (
   p_api_version    IN  NUMBER,
   p_grant_guid     IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_errorcode      OUT NOCOPY NUMBER
  );

    -- Start OF comments
    -- API name  : Revoke
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Revoke a Party's role on object instances.
    --             If this operation fails then the revoke is
    --             done and error code is returned.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments

  ----------------------------------------------------------------------------



  --3. Check User Privilege
  ------------------------------------
  FUNCTION check_user_privilege
  (
   p_api_version    IN  NUMBER,
   p_privilege        IN  VARCHAR2,
   p_object_name      IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_user_id        IN  NUMBER
 )
 RETURN VARCHAR2;

    -- Start OF comments
    -- API name  : check_user_privilege
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : check a user's privilege on  object instance(s)
    --             If this operation fails then the check is not
    --             done and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_privilege        IN  VARCHAR2 (required)
    --             name of the privilege (function name)
    --
    --             p_object_name      IN  VARCHAR2 (required)
    --             object on which the privilege should be checked
    --
    --             p_object_key       IN  NUMBER (required)
    --             object key to an instance
    --
    --             p_user_id         IN  NUMBER (required)
    --             user for whom the privilege is checked
    --
    --     OUT  :
    --             RETURN
    --                   FND_API.G_TRUE  privilege EXISTS
    --                   FND_API.G_FALSE NO privilege
    --                   FND_API.G_RET_STS_ERROR if error
    --             FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --

    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
   ----------------------------------------------------------------------------


  --3.b.1 Check Party Privilege
  ------------------------------------
  FUNCTION check_party_privilege
  (
   p_api_version    IN  NUMBER,
   p_privilege      IN  VARCHAR2,
   p_object_name    IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_party_id       IN  NUMBER
 ) RETURN VARCHAR2;

    -- Start OF comments
    -- API name  : check_party_privilege
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : check a user's privilege on  object instance(s)
    --             If this operation fails then the check is not
    --             done and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_privilege        IN  VARCHAR2 (required)
    --             name of the privilege (function name)
    --
    --             p_object_name      IN  VARCHAR2 (required)
    --             object on which the privilege should be checked
    --
    --             p_object_key       IN  NUMBER (required)
    --             object key to an instance
    --
    --             p_party_id         IN  NUMBER (required)
    --             party_id of the privilege is checked
    --
    --     OUT  :
    --             RETURN
    --                   FND_API.G_TRUE  privilege EXISTS
    --                   FND_API.G_FALSE NO privilege
    --                   FND_API.G_RET_STS_ERROR if error
    --             FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --

    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments

  ----------------------------------------------------------------------------


  --3.b.2 Check Party Privilege
  ------------------------------------
  FUNCTION check_party_privilege
  (
   p_api_version        IN  NUMBER,
   p_privilege          IN  VARCHAR2,
   p_object_name        IN  VARCHAR2,
   p_instance_pk1_value IN  VARCHAR2,
   p_instance_pk2_value IN  VARCHAR2,
   p_instance_pk3_value IN  VARCHAR2,
   p_instance_pk4_value IN  VARCHAR2,
   p_instance_pk5_value IN  VARCHAR2,
   p_party_id           IN  NUMBER
 )
 RETURN VARCHAR2;
  ----------------------------------------------------------------------------
  --4. Get Privileges
  ------------------------------------
  PROCEDURE get_privileges
  (
   p_api_version    IN  NUMBER,
   p_object_name      IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_user_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_privilege_tbl  OUT NOCOPY EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE
   );

    -- Start OF comments
    -- API name  : get_privileges
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : get the list of privileges user has on the object instance
    --             If this operation fails then the get is not
    --             done and error code is returned.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
    ----------------------------------------------------------------------------



  --4 b.1 Get Privileges
  ------------------------------------
  PROCEDURE get_party_privileges
  (
   p_api_version    IN  NUMBER,
   p_object_name    IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_party_id       IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_privilege_tbl  OUT NOCOPY EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE
   ) ;


    -- Start OF comments
    -- API name  : get_privileges
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : get the list of privileges user has on the object instance
    --             If this operation fails then the get is not
    --             done and error code is returned.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments

  ----------------------------------------------------------------------------

  --4 b.2 Get Privileges
  ------------------------------------
  PROCEDURE get_party_privileges
  (
   p_api_version        IN  NUMBER,
   p_object_name        IN  VARCHAR2,
   p_instance_pk1_value IN  VARCHAR2,
   p_instance_pk2_value IN  VARCHAR2,
   p_instance_pk3_value IN  VARCHAR2,
   p_instance_pk4_value IN  VARCHAR2,
   p_instance_pk5_value IN  VARCHAR2,
   p_party_id           IN  NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_privilege_tbl      OUT NOCOPY EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE
   );
-----------------------------------------------------

--5. Get instances
-----------------------------------------------
  PROCEDURE get_instances_with_privilege
  (
   p_api_version       IN  NUMBER,
   p_privilege         IN  VARCHAR2,
   p_object_name       IN  VARCHAR2,
   p_party_id          IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_object_key_tbl    OUT NOCOPY ID_TBL_TYPE
  );

-------------------------------------------
--6. get_instances_with_privilege_d
------------------------------------------------
 PROCEDURE get_instances_with_privilege_d
  (
   p_api_version      IN  NUMBER,
   p_privilege        IN  VARCHAR2,
   p_object_name      IN  VARCHAR2,
   p_party_id         IN  NUMBER,
   p_delimiter        IN  VARCHAR2 DEFAULT ',',
   x_return_status    OUT NOCOPY VARCHAR2,
   x_object_string    OUT NOCOPY VARCHAR2
  );
---------------------------------------------


  --7.a. Get the list of predicates Strings on whcih user has privilege
  --------------------------------------------------------
  FUNCTION get_security_predicate
  (
   p_api_version          IN  NUMBER,
   p_user_id              IN  NUMBER,
   p_privilege            IN  VARCHAR2,
   p_object_name            IN  VARCHAR2,
   p_grant_type           IN  VARCHAR2 DEFAULT 'UNIVERSAL'
  ) RETURN VARCHAR2;


------------------------------------------------------------------------------------

  --7.b. Get the list of predicates Strings on which user has privilege
  FUNCTION get_security_predicate
  (
   p_api_version          IN  NUMBER,
   p_user_id              IN  NUMBER,
   p_privilege            IN  VARCHAR2,
   p_object_name            IN  VARCHAR2,
   p_aliased_pk_column    IN  VARCHAR2,
   p_grant_type           IN  VARCHAR2 DEFAULT 'UNIVERSAL'
  ) RETURN VARCHAR2;

------------------------------------------------------------------------------------

 --7.c.1 Get the list of predicates Strings on whcih user has privilege
--------------------------------------
  FUNCTION get_party_security_predicate
  (
   p_api_version          IN  NUMBER,
   p_party_id             IN  NUMBER,
   p_privilege            IN  VARCHAR2,
   p_object_name          IN  VARCHAR2,
   p_aliased_pk_column    IN  VARCHAR2,
   p_grant_type           IN  VARCHAR2 DEFAULT 'UNIVERSAL'
  ) RETURN VARCHAR2;

    -- Start OF comments
    -- API name  : get_security_predicate
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Returns  the predicates belong to a party with a given privilege.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments


------------------------------------------------------------------------------------

--7.c.2 Get the list of predicates Strings on whcih user has privilege
--------------------------------------
  FUNCTION get_party_security_predicate
  (
   p_api_version          IN  NUMBER,
   p_party_id             IN  NUMBER,
   p_privilege            IN  VARCHAR2,
   p_object_name          IN  VARCHAR2,
   p_aliased_pk_column    IN  VARCHAR2,
   p_pk2_alias            IN  VARCHAR2,
   p_pk3_alias            IN  VARCHAR2,
   p_pk4_alias            IN  VARCHAR2,
   p_pk5_alias            IN  VARCHAR2,
   p_grant_type           IN  VARCHAR2 DEFAULT 'UNIVERSAL',
   x_return_status        OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2;
  ------------------------------------------------------------------------------

  --8.a Get Privileges as comma delimited string
------------------------------------
  PROCEDURE get_privileges_d
  (
   p_api_version    IN  NUMBER,
   p_object_name      IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_user_id        IN  NUMBER,
   p_delimiter      IN  VARCHAR2 DEFAULT ',',
   x_return_status  OUT NOCOPY VARCHAR2,
   x_privileges_string  OUT NOCOPY VARCHAR2
  );

   -- Start OF comments
   -- API name  : get_security_predicate
   -- TYPE      : Public
   -- Pre-reqs  : None
   -- FUNCTION  : It returns all previleges as a string seperating the privileges with comma.

   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments

------------------------------------------------------------------------------------

 --8.b Get Privileges as comma delimited string
------------------------------------
PROCEDURE get_party_privileges_d
  (
   p_api_version    IN  NUMBER,
   p_object_name    IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_party_id       IN  NUMBER,
   p_delimiter      IN  VARCHAR2 DEFAULT ',',
   x_return_status  OUT NOCOPY VARCHAR2,
   x_privileges_string  OUT NOCOPY VARCHAR2
  );
-----------------------------------------------------------------
PROCEDURE get_party_privileges_d
  (
   p_api_version    IN  NUMBER,
   p_object_name    IN  VARCHAR2,
   p_pk1_value      IN  VARCHAR2,
   p_pk2_value      IN  VARCHAR2,
   p_pk3_value      IN  VARCHAR2,
   p_pk4_value      IN  VARCHAR2,
   p_pk5_value      IN  VARCHAR2,
   p_party_id       IN  NUMBER,
   p_delimiter      IN  VARCHAR2 DEFAULT ',',
   x_return_status  OUT NOCOPY VARCHAR2,
   x_privileges_string  OUT NOCOPY VARCHAR2
  );
--------------------------------------------------------

 --9. Set end date to a grant
  ------------------------------------
  PROCEDURE set_grant_date
  (
   p_api_version    IN  NUMBER,
   p_grant_guid     IN  VARCHAR2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
  );

  ----------------------------------------------------------------------------
/*
--10. Check_Instance_In_Set
-----------------------------------------------
FUNCTION check_instance_in_set
 (
   p_api_version          IN  NUMBER,
   p_instance_set_id      IN  NUMBER,
   p_instance_pk1_value   IN VARCHAR2
 ) return VARCHAR2 ;
--------------------------------------------

*/
/*
--10. Check_Instance_In_Set
 ------------------------
 FUNCTION check_instance_in_set
 (
   p_api_version    IN  NUMBER,
   p_object_name      IN  VARCHAR2,
   p_instance_set_id IN NUMBER,
   p_instance_id    IN  NUMBER,
   p_party_person_id  IN  NUMBER
 )
 RETURN VARCHAR2 ;
 */
---------------------------------------------------------

--13. check_duplicate_grant
 ------------------------
 FUNCTION check_duplicate_grant
  (
   p_role_name            IN  VARCHAR2,
   p_object_name      IN  VARCHAR2,
   p_object_key_type      IN  VARCHAR2,
   p_object_key           IN  NUMBER,
   p_party_id             IN  NUMBER,
   p_start_date           IN  DATE,
   p_end_date             IN  DATE
 ) RETURN VARCHAR2 ;
 ------------------------

 --14. check_duplicate_item_grant
 ------------------------
 FUNCTION check_duplicate_item_grant
  (
   p_role_id              IN  NUMBER,
   p_object_id        IN  NUMBER,
   p_object_key_type      IN  VARCHAR2,
   p_object_key           IN  NUMBER,
   p_party_id             IN  NUMBER,
   p_start_date           IN  DATE,
   p_end_date             IN  DATE
 ) RETURN VARCHAR2;

 --15. creat_instance_set
 ------------------------
 FUNCTION create_instance_set
  (
   p_instance_set_name      IN  VARCHAR2,
   p_object_name        IN  VARCHAR2,
   p_predicate              IN  VARCHAR2,
   p_display_name           IN  VARCHAR2,
   p_description            IN  VARCHAR2
 ) RETURN NUMBER;


END EGO_SECURITY_PUB;

 

/
