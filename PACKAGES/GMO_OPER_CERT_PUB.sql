--------------------------------------------------------
--  DDL for Package GMO_OPER_CERT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_OPER_CERT_PUB" AUTHID CURRENT_USER AS
/* $Header: GMOOPCTS.pls 120.1 2007/06/21 06:12:10 rvsingh noship $ */
/*#
* This file contains procedures for the Operator Certificate(GMO)APIs in *
* Oracle Process Manufacturing (OPM). Each procedure has a common set of *
* parameters to which API-specific parameters are appended.              *
*************************************************************************/
/*
* @rep:scope public
* @rep:product GMO
* @rep:displayname Production Management public api's
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY PRODUCT_MANAGEMENT_API'S
*/
/*================================================================================
     Procedure
       check_certification
     Description
       This procedure is used to check whether the given user is certified
       or has competency for a given task.
     Parameters
       p_header_id (O)           The header_id used by the inventory transaction manager.
       p_table     (O)           Table to process by Transaction Manager
                                 1 - temp table
                                 2 - interface table
       x_return_status           outcome of the API call
                                 S - Success
                                 E - Error
                                 U - Unexpected Error
       p_commit                  Indicates whether to commit.
                                 'T' (FND_API.G_TRUE) - to commit work
                                 'F' (FND_API.G_FALSE) - Not to commit work
                                 This is defaulted 'F'
       Return                    0 = not certified
                                 1 = certified
                                -1 = No over ride allowed
   ================================================================================*/


     FUNCTION check_certification(
      p_user_id          IN                NUMBER
     ,p_org_id           IN              NUMBER
     ,p_object_id        IN              NUMBER DEFAULT NULL
     ,p_object_type      IN              NUMBER DEFAULT NULL
     ,p_eff_date         IN              DATE
     ,x_return_status    OUT NOCOPY      VARCHAR2) RETURN NUMBER;

     PROCEDURE required_certification(
      p_user_id          	IN              NUMBER
     ,p_org_id           	IN              NUMBER
     ,p_header_id        	IN              NUMBER
     ,p_operator_certificate_id IN       	NUMBER
     ,p_eff_date         	IN              DATE
     ,x_return_status    OUT NOCOPY      	VARCHAR2) ;

     Procedure Update_erecord(
      p_ERECORD_ID               IN NUMBER
     ,p_Operator_certificate_id  IN NUMBER
     ,p_EVENT_KEY                IN VARCHAR2
     ,p_EVENT_NAME               IN VARCHAR2
     ,x_return_status            OUT NOCOPY VARCHAR2);

  FUNCTION check_certification(
      p_user_id          IN                NUMBER
     ,p_org_id           IN              NUMBER
     ,p_object_id        IN              NUMBER DEFAULT NULL
     ,p_object_type      IN              NUMBER DEFAULT NULL
     ,p_eff_date         IN              DATE) RETURN NUMBER;


/*================================================================================
     Procedure
       update_cert_record
     Description
       This procedure is used for  acknowledging  the Operator Certification module to  change the Status
       to S  and  update the E-record ID  once the Transaction is  successful.
     Parameters
       p_Operator_certificate_id            The header_id used by the inventory transaction manager.
      p_EVENT_KEY                                Event Key
      p_EVENT_NAME                            Event Name
      p_ERECORD_ID                            E-Record ID
      p_user_key_label_token             User Key Label
      p_user_key_value                         User Key Value
      p_transaction_id                            Transaction ID
       x_return_status           outcome of the API call
                                 S - Success
                                 E - Error
                                 U - Unexpected Error
   ================================================================================*/

 procedure update_cert_record(p_Operator_certificate_id  IN NUMBER
    ,p_EVENT_KEY                IN  VARCHAR2
    ,p_EVENT_NAME             IN  VARCHAR2
    ,p_ERECORD_ID             IN NUMBER
    ,p_user_key_label_token     IN VARCHAR2
    ,p_user_key_value           IN VARCHAR2
    ,p_transaction_id           IN VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2
    );



    PROCEDURE cert_details (
   p_operator_CERTIFICATE_ID    IN OUT NOCOPY NUMBER
  ,p_HEADER_ID                 IN            NUMBER
  ,p_TRANSACTION_ID            IN            VARCHAR2
  ,p_USER_ID                   IN            NUMBER
  ,p_comments                   IN            VARCHAR2
  ,p_OVERRIDER_ID               IN            NUMBER
  ,p_User_key_label_product    IN            VARCHAR2
  ,p_User_key_label_token      IN            VARCHAR2
  ,p_User_key_value            IN            VARCHAR2
  ,p_Erecord_id                IN            NUMBER
  ,p_Trans_object_id           IN            NUMBER
  ,p_STATUS                    IN            VARCHAR2
  ,p_event_name                IN            VARCHAR2
  ,p_event_key                 IN            VARCHAR2
  ,p_eff_date                  IN            DATE
  ,p_CREATION_DATE             IN            DATE
  ,p_CREATED_BY                IN            NUMBER
  ,p_LAST_UPDATE_DATE          IN            DATE
  ,p_LAST_UPDATED_BY           IN            NUMBER
  ,p_LAST_UPDATE_LOGIN         IN            NUMBER
  ,x_return_Status            OUT   NOCOPY     VARCHAR2 );

END gmo_oper_cert_pub;

/
