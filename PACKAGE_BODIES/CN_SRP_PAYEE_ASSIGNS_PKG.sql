--------------------------------------------------------
--  DDL for Package Body CN_SRP_PAYEE_ASSIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PAYEE_ASSIGNS_PKG" as
-- $Header: cntspab.pls 120.1 2005/06/10 14:01:45 appldev  $
/*
Date	  Name	     	        Description
***************************************************************************
10-JUN-99 Kumar Sivasankaran 	Created
***************************************************************************
  Name	  : CN_SRP_PAYEE_ASSIGNS_PKG
  Purpose : Holds all server side packages used to insert a
            srp Payee Assigns

  Desc    : BEGIN_RECORD is called at the start of the commit cycle.
*/

  -- Procedure Name
  --	Insert_Record
  -- Purpose
  --    Main insert procedure
/*-------------------------------------------------------------------------*
 |
 | Procedure Name Insert_Record
 |
 *-------------------------------------------------------------------------*/
  PROCEDURE Insert_Record
     ( x_srp_payee_assign_id     IN OUT NOCOPY NUMBER
      ,p_srp_quota_assign_id            NUMBER
      ,p_org_id                         NUMBER
      ,p_payee_id		        NUMBER
      ,p_quota_id                       NUMBER
      ,p_salesrep_id	                NUMBER
      ,p_start_date			DATE
      ,p_end_date	                DATE
      ,p_Last_Update_Date               DATE
      ,p_Last_Updated_By                NUMBER
      ,p_Creation_Date                  DATE
      ,p_Created_By                     NUMBER
      ,p_Last_Update_Login              NUMBER) IS

  BEGIN

     SELECT cn_srp_payee_assigns_s.NEXTVAL
       INTO x_srp_payee_assign_id
       FROM dual;

     INSERT INTO cn_srp_payee_assigns_all (
                srp_payee_assign_id
               ,srp_quota_assign_id
	       ,org_id
	       ,payee_id
               ,quota_id
	       ,salesrep_id
	       ,start_date
               ,end_date
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
	       ,last_update_login
             ) VALUES (
                X_srp_payee_assign_id
               ,p_srp_quota_assign_id
	       ,p_org_id
	       ,p_payee_id
               ,p_quota_id
	       ,p_salesrep_id
	       ,p_start_date
	       ,p_end_date
               ,p_Last_Update_Date
               ,p_Last_Updated_By
               ,p_Creation_Date
               ,p_Created_By
	       ,p_Last_Update_Login
             );

  END Insert_Record;

  -- Procedure Name
  --   Update Record
  -- Purpose
  --   To Update the Srp Payee Assigns
  --
/*-------------------------------------------------------------------------*
 |
 | Procedure Name Update_Record
 |
 *-------------------------------------------------------------------------*/
  PROCEDURE Update_Record(
                        p_srp_payee_assign_id            NUMBER
		       ,p_payee_id		         NUMBER
                       ,p_start_date			 DATE
		       ,p_end_date	                 DATE
                       ,p_Last_Update_Date               DATE
                       ,p_Last_Updated_By                NUMBER
                       ,p_Last_Update_Login              NUMBER) IS
  BEGIN

     UPDATE cn_srp_payee_assigns_all
     SET
       start_date              = p_start_date,
       end_date	               = p_end_date,
       payee_id                = p_payee_id,
       last_update_date        = p_last_update_date,
       last_updated_by         = p_Last_Updated_By,
       last_update_login       = p_last_update_login,
       object_version_number   = object_version_number + 1
     WHERE srp_payee_assign_id = p_srp_payee_assign_id ;

     if (SQL%NOTFOUND) then
        Raise NO_DATA_FOUND;
     end if;

  END Update_Record;

  -- Procedure Name
  --	Delete_Record
  -- Purpose
  --    Delete the Srp Payee Assigns
/*-------------------------------------------------------------------------*
 |
 | Procedure Name Delete_Record
 |
 *-------------------------------------------------------------------------*/
   PROCEDURE Delete_Record( p_srp_payee_assign_id     NUMBER ) IS

   BEGIN
       -- changes for bug#2753634, #3143462
       -- changed the delete to update so that srp_payee_assign_id remains
       -- and can be used for futuer revert operations - use delete_flag

       UPDATE cn_srp_payee_assigns_all
       SET    delete_flag = 'Y'
       WHERE srp_payee_assign_id = p_srp_payee_assign_id;

       --DELETE FROM cn_srp_payee_assigns
       --WHERE  srp_payee_assign_id = p_srp_payee_assign_id;

  END Delete_Record;

/*-------------------------------------------------------------------------*/
  -- Procedure Name
  --	Delete_Record
  -- Purpose
  --    Called from cn_srp_quota_assigns.
/*-------------------------------------------------------------------------*/
 PROCEDURE Delete_Record(
			 p_srp_quota_assign_id  	 NUMBER
			 ,p_quota_id	       		 NUMBER) IS

    CURSOR get_payee_del_strdt_cur IS
       SELECT srp_payee_assign_id
       FROM cn_srp_payee_assigns_all
       WHERE srp_quota_assign_id  = p_srp_quota_assign_id
        AND  quota_id             = p_quota_id  ;

  BEGIN
     -- changes for bug#2753634
     -- changed the delete to update so that srp_payee_assign_id remains
     -- and can be used for futuer revert operations
     For l_get_payee_del_strdt_cur IN get_payee_del_strdt_cur LOOP
	Delete_Record(l_get_payee_del_strdt_cur.srp_payee_assign_id);
     END LOOP;

 END Delete_Record;

END CN_SRP_PAYEE_ASSIGNS_PKG;

/
