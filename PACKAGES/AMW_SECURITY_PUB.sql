--------------------------------------------------------
--  DDL for Package AMW_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_SECURITY_PUB" AUTHID CURRENT_USER as
/*$Header: amwpsecs.pls 120.1 2006/01/06 07:05:19 appldev noship $*/

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
   x_grant_guid            OUT NOCOPY RAW,
   p_check_for_existing    IN VARCHAR2 := FND_API.G_TRUE
  );

    PROCEDURE grant_role_guid
  (
   p_api_version           IN  NUMBER,
   p_role_name             IN  VARCHAR2,
   p_object_name           IN  VARCHAR2,
   p_instance_type         IN  VARCHAR2,
   p_object_key            IN  NUMBER,
   p_party_id              IN  NUMBER,
   p_start_date            IN  DATE,
   p_end_date              IN  DATE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_errorcode             OUT NOCOPY NUMBER,
   x_grant_guid            OUT NOCOPY RAW
  );

    PROCEDURE revoke_grant
  (
   p_api_version    IN  NUMBER,
   p_grant_guid     IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_errorcode      OUT NOCOPY NUMBER
  );

    PROCEDURE set_grant_date
  (
   p_api_version    IN  NUMBER,
   p_grant_guid     IN  VARCHAR2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
  );


  PROCEDURE get_security_predicate(
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2,/* SET, INSTANCE*/
    p_user_name        IN  VARCHAR2,
    /* stmnt_type: 'OTHER', 'VPD'=VPD, 'EXISTS'= for checking existence. */
    p_statement_type   IN  VARCHAR2,
    x_predicate        out NOCOPY varchar2,
    x_return_status    out NOCOPY varchar2,
    p_table_alias      IN  VARCHAR2 DEFAULT NULL
  );

end AMW_SECURITY_PUB;

 

/
