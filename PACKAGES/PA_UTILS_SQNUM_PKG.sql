--------------------------------------------------------
--  DDL for Package PA_UTILS_SQNUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_UTILS_SQNUM_PKG" AUTHID CURRENT_USER as
/* $Header: PAXGSQNS.pls 120.1.12000000.2 2008/09/27 09:26:54 bifernan ship $ */


  /*----------------------------------------------------------+
   | get_unique_proj_num : a procedure to get a unique number |
   | 		for the automatic project number.  	      |
   |							      |
   |	unique_number :  contains the returned unique number. |
   |    x_status      :  contains the returned status. 	      |
   |							      |
   |		x_status = 0 	     if it is successful.     |
   |  		         = 1	     if no data found.	      |
   |			 = sqlcode   otherwise		      |
   +----------------------------------------------------------*/
  PROCEDURE get_unique_proj_num(x_table_name       IN      VARCHAR2,
                                user_id          IN        NUMBER,
                                unique_number    IN OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
				x_status         IN OUT    NOCOPY NUMBER); --File.Sql.39 bug 4440895

  /*----------------------------------------------------------+
   | get_unique_invoice_num : a procedure to get a unique     |
   |            number for the automatic project number.      |
   |                                                          |
   |    unique_number :  contains the returned unique number. |
   |    x_status      :  contains the returned status.        |
   |                                                          |
   |            x_status = 0         if it is successful.     |
   |                     = 1         if no data found.        |
   |                     = sqlcode   otherwise                |
   +----------------------------------------------------------*/
  PROCEDURE get_unique_invoice_num(invoice_category IN      VARCHAR2,
                                   user_id          IN        NUMBER,
                                   unique_number    IN OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
				   x_status         IN OUT    NOCOPY NUMBER); --File.Sql.39 bug 4440895

  -- Bug 7335526
   /*--------------------------------------------------------------+
   | revert_unique_proj_num : A procedure to revert a unique       |
   |            number for the automatic project number if project |
   |            creation errors out.                               |
   |                                                               |
   |    p_unique_number :  contains the unique number which should |
   |                       be reverted.                            |
   +---------------------------------------------------------------*/
   PROCEDURE revert_unique_proj_num(p_table_name       IN      VARCHAR2,
                                    p_user_id          IN      NUMBER,
                                    p_unique_number    IN      NUMBER) ;

END PA_UTILS_SQNUM_PKG;
 

/
