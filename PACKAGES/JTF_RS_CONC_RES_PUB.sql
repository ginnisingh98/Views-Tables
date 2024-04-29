--------------------------------------------------------
--  DDL for Package JTF_RS_CONC_RES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_CONC_RES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsbrs.pls 120.0 2005/05/11 08:19:24 appldev ship $ */

  /*****************************************************************************************
   This is a concurrent program to fetch all employees from the employee database for creating
   resources in resource manager. All employees who are valid on sysdate and are not already
   existing in resource manager will be fetched

   ******************************************************************************************/


  /* Procedure to create the resource  */
  PROCEDURE  create_employee
  (P_CREATE_SRP              IN  VARCHAR2 DEFAULT 'N',
   P_SALES_CREDIT_TYPE       IN  VARCHAR2 DEFAULT NULL,
   P_CHECK_JOB_ROLE_MAP      IN  VARCHAR2 DEFAULT 'N');

  PROCEDURE  terminate_employee;

  PROCEDURE  update_employee
  (P_OVERWRITE_NAME          IN  VARCHAR2 DEFAULT 'N');

  PROCEDURE  synchronize_employee
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2,
   P_OVERWRITE_NAME          IN  VARCHAR2 DEFAULT 'No',
   P_GET_NEW_EMP             IN  VARCHAR2 DEFAULT 'N',
   P_DUMMY_1                 IN  VARCHAR2 DEFAULT 'N',
   P_CREATE_SRP              IN  VARCHAR2 DEFAULT 'N',
   P_DUMMY_2                 IN  VARCHAR2 DEFAULT 'N',
   P_SALES_CREDIT_TYPE       IN  VARCHAR2 DEFAULT NULL,
   P_CHECK_JOB_ROLE_MAP      IN  VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE  update_terminated_employee;

  PROCEDURE  synchronize_party
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2,
   P_OVERWRITE_NAME          IN  VARCHAR2 DEFAULT 'N'
   );

  PROCEDURE update_party
  (P_OVERWRITE_NAME          IN  VARCHAR2 DEFAULT 'N');

  PROCEDURE terminate_partner_rel;

  PROCEDURE  synchronize_supp_contact
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2,
   P_OVERWRITE_NAME          IN  VARCHAR2 DEFAULT 'N'
   );

  PROCEDURE update_supp_contact
  (P_OVERWRITE_NAME          IN  VARCHAR2 DEFAULT 'N');

  PROCEDURE terminate_supplier_contact;

  PROCEDURE update_username;

  PROCEDURE update_userid;

  PROCEDURE  synchronize_user_name
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2,
   P_SYNCHRONIZE             IN  VARCHAR2 DEFAULT 'Both'
  );

END jtf_rs_conc_res_pub;

 

/
