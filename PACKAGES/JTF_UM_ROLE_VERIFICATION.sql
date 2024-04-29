--------------------------------------------------------
--  DDL for Package JTF_UM_ROLE_VERIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_ROLE_VERIFICATION" AUTHID CURRENT_USER as
/* $Header: JTFUMRVS.pls 115.2 2002/11/21 22:58:09 kching ship $ */
-- Start of Comments
-- Package name     : JTF_UM_ROLE_VERIFICATION
-- Purpose          : verify if given role exists in UM and updating principal_id.
-- History          :

/**
 * Procedure   :  UPDATE_AUTH_PRINCIPAL_ID
 * Type        :  Private
 * Pre_reqs    :
 * Description : Updates the existing UM records with the old_auth_principal_id to
 *                     the new_auth_principal_id
 * Parameters
 * input parameters : old_auth_principal_id number
 *                            new_auth_principal_id number
 * Other Comments :
 */
procedure UPDATE_AUTH_PRINCIPAL_ID(old_auth_principal_id  in number,
                                                               new_auth_principal_id in number  );


/**
 * Procedure   :  IS_AUTH_PRINCIPAL_REFERRED
 * Type        :  Private
 * Pre_reqs    :
 * Description : Looks for existence of input auth_principal_id or auth_principal_name in
 *                    UM tables and if so, returns "E" in x_return_status with appropriate message that the
 *                    role cannot be deleted. If the principal does not exist anywhere in the usertype/enrollments,
 *                    returns "S" in the parameter x_return_status
 * Parameters
 * input parameters :  auth_principal_name varchar2
 * output parameters : x_return_status varchar2
 * Errors      :  If the principal exists in UM, sends appropriate message back as part of
 *                error stack
 * Other Comments :
 */
procedure IS_AUTH_PRINCIPAL_REFERRED(
                 auth_principal_name      in  varchar2,
              --   x_if_referred_flag           out NOCOPY varchar2,
                 x_return_status             out NOCOPY varchar2,
                 x_msg_count                out NOCOPY number,
                 x_msg_data                  out NOCOPY varchar2
                 );
End JTF_UM_ROLE_VERIFICATION;

 

/
