--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_ASSIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_ASSIGNS_PKG" as
/* $Header: cnpliqab.pls 120.2 2005/07/05 09:25:19 appldev ship $ */

/*

Date      Name          Description
---------------------------------------------------------------------------+
15-FEB-95 P Cook	Unit tested
13-JUL-95 P Cook	Added lock_record procedure
17-JUL-95 P Cook	Do no raise exception if no srp records found when
			updating a quota
28-JUL-95 P Cook	Split up delete_record to use quota_assign index.
			Only try to delete srp records if a quota assignment
			record was deleted.

*/

/* -------------------------------------------------------------------------
 |                      Variables                                          |
 --------------------------------------------------------------------------*/

  -- All srp plan assigns using this comp plan id
  CURSOR reps (x_comp_plan_id NUMBER) IS
    SELECT srp_plan_assign_id, salesrep_id, role_id, start_date, end_date
    FROM   cn_srp_plan_assigns
    WHERE  comp_plan_id = x_comp_plan_id;

    rep_rec reps%ROWTYPE;

/* -------------------------------------------------------------------------
 |                            Private Routines                              |
  --------------------------------------------------------------------------*/

  -- Name
  --
  -- Purpose
  --
  -- Notes
  --
  --
  PROCEDURE get_uid (X_Quota_Assign_Id       IN OUT NOCOPY NUMBER    ) IS
  BEGIN

    SELECT cn_quota_assigns_s.nextval
    INTO   X_Quota_Assign_Id
    FROM sys.dual;

  END get_uid;

  -- Name
  --
  -- Purpose
  --
  -- Notes
  --
  --
  PROCEDURE Insert_Record( X_Quota_Id             	NUMBER
                          ,X_Comp_Plan_Id         	NUMBER
			  ,X_Quota_Assign_Id  IN OUT NOCOPY 	NUMBER
			  ,X_Quota_Sequence             NUMBER
        ,X_ORG_ID NUMBER) IS

     l_name cn_comp_plans.name%TYPE;
     l_start_date DATE;
     l_end_date   DATE;
     l_null_date  CONSTANT DATE := to_date('31-12-3000','DD-MM-YYYY');
     l_loading_status varchar2(30);
     l_msg_count      number;
     l_msg_data       varchar2(240);
     l_return_status  varchar2(1);

     CURSOR pg_cur(srp_id number)
       IS
	  select start_date, end_date
	    from cn_srp_pay_groups
	    where salesrep_id = srp_id;

     pg_cur_rec  pg_cur%ROWTYPE;

  BEGIN

    Get_Uid(X_Quota_Assign_Id);

      -- If we change the assignments in any way we must immediately make
      -- the plan 'incomplete'. If we rely on a db hit the form plan record
      -- does not get updated since the status and complete_flag
      -- fields are not used as OUT parameters. while its underlying db record
      --  has changed.
      -- must be called aftere the unique checks to ensure the plan
      -- status is not updated even though the quota in/upd cannot be made.

      cn_quota_assigns_pkg.check_exists(x_quota_id);

      cn_comp_plans_pkg.set_status( x_comp_plan_id      => x_comp_plan_id
		 		   ,x_quota_id	        => null
		 		   ,x_rate_schedule_id  => null
	         		   ,x_status_code       => 'INCOMPLETE'
				   ,x_event	        => 'CHANGE_COMP_PLAN');


      INSERT INTO cn_quota_assigns
	(
	 Quota_Id
	 ,Comp_Plan_Id
	 ,Quota_Assign_Id
	 ,Quota_Sequence
	 ,created_by
	 ,creation_date
	 ,last_updated_by
	 ,last_update_date
	 ,last_update_login
	 ,object_version_number
   ,org_id)
	VALUES
	(
	 X_Quota_Id
	 ,X_Comp_Plan_Id
	 ,X_Quota_Assign_Id
	 ,X_Quota_Sequence
	 ,fnd_global.user_id
	 ,sysdate
	 ,fnd_global.user_id
	 ,sysdate
	 ,fnd_global.login_id
	 ,0
   ,X_ORG_ID );

      FOR rep_rec IN reps(x_comp_plan_id) LOOP
	 cn_srp_quota_assigns_pkg.insert_record
	   (  x_srp_plan_assign_id => rep_rec.srp_plan_assign_id
	      ,x_quota_id		 => x_quota_id);

	 -- create srp periods as necessary
	 FOR  pg_cur_rec IN pg_cur(rep_rec.salesrep_id) LOOP
	    IF(pg_cur_rec.start_date <= rep_rec.start_date) THEN
	       l_start_date := rep_rec.start_date;
	     ELSE
	       l_start_date := pg_cur_rec.start_date;
	    END IF;

	    IF(nvl(pg_cur_rec.end_date,l_null_date) >=
	       nvl(rep_rec.end_date,l_null_date)) THEN
	       l_end_date := rep_rec.end_date;
	     ELSE
	       l_end_date := pg_cur_rec.end_date;
	    END IF;

	    IF l_start_date <= nvl(l_end_date, l_null_date) THEN
	       -- Create entry in cn_srp_periods
	       CN_SRP_PERIODS_PVT.Create_Srp_Periods_Per_Quota
		 (p_api_version          => 1.0,
		  x_return_status        => l_return_status,
		  x_msg_count            => l_msg_count,
		  x_msg_data             => l_msg_data,
		  p_role_id              => rep_rec.role_id,
		  p_comp_plan_id         => x_comp_plan_id,
		  p_quota_id             => x_quota_id,
		  p_salesrep_id          => rep_rec.salesrep_id,
		  p_start_date           => l_start_date,
		  p_end_date             => l_end_date,
		  p_sync_flag            => fnd_api.g_false,
		  x_loading_status       => l_loading_status
		  );
	       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
		  RAISE FND_API.G_EXC_ERROR ;
	       END IF;
	    END IF;
	 END LOOP;
      END LOOP;

        BEGIN

	   SELECT name, start_date, end_date
	     INTO l_name, l_start_date, l_end_date
	       FROM cn_comp_plans
	       WHERE comp_plan_id = x_comp_plan_id;
	  EXCEPTION
	     WHEN no_data_found THEN
		l_name := NULL;
	  END ;
       cn_mark_events_pkg.mark_event_comp_plan
           ( p_event_name => 'CHANGE_COMP_PLAN'
             ,p_object_name => l_name
             ,p_object_id   => x_comp_plan_id
             ,p_start_date  => NULL
             ,p_end_date    => NULL
             ,p_start_date_old => l_start_date
             ,p_end_date_old  => l_end_date
             ,p_org_id => X_ORG_ID);


  END Insert_Record;

  -- Name
  --
  -- Purpose
  --
  -- Notes
  --
  --

  PROCEDURE Update_Record( X_Quota_Id         		NUMBER
                  	  ,X_Comp_Plan_Id       	NUMBER
                  	  ,X_Quota_Assign_Id    	NUMBER
			  ,X_Quota_Sequence             NUMBER
			  ,x_quota_id_old		VARCHAR2
        ,X_ORG_ID NUMBER) IS

     l_start_date DATE;
     l_end_date   DATE;
     l_null_date  CONSTANT DATE := to_date('31-12-3000','DD-MM-YYYY');
     l_loading_status varchar2(30);
     l_msg_count      number;
     l_msg_data       varchar2(240);
     l_return_status  varchar2(1);

     CURSOR pg_cur(srp_id number)
       IS
	  select start_date, end_date
	    from cn_srp_pay_groups
	    where salesrep_id = srp_id;

     pg_cur_rec  pg_cur%ROWTYPE;

  BEGIN

      IF (x_quota_id <>  x_quota_id_old ) THEN

        cn_quota_assigns_pkg.check_exists(x_quota_id);

	cn_comp_plans_pkg.set_status(
		x_comp_plan_id		=> x_comp_plan_id
	       ,x_quota_id		=> null
	       ,x_rate_schedule_id	=> null
	       ,x_status_code 		=> 'INCOMPLETE'
	       ,x_event	        	=> 'CHANGE_COMP_PLAN' );

      END IF;

      BEGIN
        UPDATE cn_quota_assigns
	  SET  quota_id         = x_quota_id
	  ,comp_plan_id     = x_comp_plan_id
	  ,quota_sequence   = X_Quota_Sequence
	  ,last_updated_by   = fnd_global.user_id
	  ,last_update_date  = sysdate
	  ,last_update_login = fnd_global.login_id
	  ,object_version_number = object_version_number + 1
         WHERE quota_assign_id   = x_quota_assign_id;

        IF (SQL%NOTFOUND) THEN
          raise no_data_found;
        END IF;

      END;

      IF x_quota_id <>  x_quota_id_old THEN
        FOR rep_rec IN reps(x_comp_plan_id) LOOP
          cn_srp_quota_assigns_pkg.delete_record(
			x_srp_plan_assign_id => rep_rec.srp_plan_assign_id
		       ,x_quota_id 	     => x_quota_id_old);

          cn_srp_quota_assigns_pkg.insert_record(
			x_srp_plan_assign_id => rep_rec.srp_plan_assign_id
	   	       ,x_quota_id	     => x_quota_id);

	  -- create srp periods as necessary
	  FOR  pg_cur_rec IN pg_cur(rep_rec.salesrep_id) LOOP
	     IF(pg_cur_rec.start_date <= rep_rec.start_date) THEN
		l_start_date := rep_rec.start_date;
	      ELSE
		l_start_date := pg_cur_rec.start_date;
	     END IF;

	     IF(nvl(pg_cur_rec.end_date,l_null_date) >=
		nvl(rep_rec.end_date,l_null_date)) THEN
		l_end_date := rep_rec.end_date;
	      ELSE
		l_end_date := pg_cur_rec.end_date;
	     END IF;

	     IF l_start_date <= nvl(l_end_date, l_null_date) THEN
		-- Create entry in cn_srp_periods
		CN_SRP_PERIODS_PVT.Create_Srp_Periods_Per_Quota
		  (p_api_version          => 1.0,
		   x_return_status        => l_return_status,
		   x_msg_count            => l_msg_count,
		   x_msg_data             => l_msg_data,
		   p_role_id              => rep_rec.role_id,
		   p_comp_plan_id         => x_comp_plan_id,
		   p_quota_id             => x_quota_id,
		   p_salesrep_id          => rep_rec.salesrep_id,
		   p_start_date           => l_start_date,
		   p_end_date             => l_end_date,
		   p_sync_flag            => fnd_api.g_false,
		   x_loading_status       => l_loading_status
		   );
		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
		   RAISE FND_API.G_EXC_ERROR ;
		END IF;
	     END IF;
	  END LOOP;
	END LOOP;
      END IF;

  END Update_Record;

  -- Name
  --
  -- Purpose
  --
  -- Notes
  --
  --

  PROCEDURE Delete_Record( X_Quota_Assign_Id  NUMBER
			  ,X_Comp_Plan_Id     NUMBER
			  ,x_quota_id	      NUMBER) IS

     l_name  cn_comp_plans.name%TYPE;
     l_start_date DATE;
     l_end_date   DATE;
     l_quota_id NUMBER;
     l_org_id NUMBER;


     CURSOR get_quota_id_for_mark IS
	Select quota_id
	  from cn_quota_assigns
	  where  comp_plan_id = nvl(x_comp_plan_id, comp_plan_id )
	  and  quota_assign_id = nvl(x_quota_assign_id, quota_assign_id) ;

  BEGIN

    if x_quota_id is NULL then

       open get_quota_id_for_mark;
	  fetch get_quota_id_for_mark into l_quota_id ;
	  close get_quota_id_for_mark;

    end if;

      cn_comp_plans_pkg.set_status( x_comp_plan_id     => x_comp_plan_id
		 		   ,x_quota_id	       => null
		 		   ,x_rate_schedule_id => null
	         		   ,x_status_code      => 'INCOMPLETE'
				   ,x_event	       => 'CHANGE_COMP_PLAN');

      BEGIN
        IF x_quota_assign_id IS NULL THEN

          DELETE FROM cn_quota_assigns
           WHERE comp_plan_id    = x_comp_plan_id;

        ELSE
          DELETE FROM cn_quota_assigns
           WHERE quota_assign_id = x_quota_assign_id
             AND comp_plan_id    = x_comp_plan_id;

        END IF;

        IF SQL%FOUND THEN

	   BEGIN

	      SELECT name, start_date, end_date
		INTO l_name, l_start_date, l_end_date
		FROM cn_comp_plans
		WHERE comp_plan_id = x_comp_plan_id;
	   EXCEPTION
	      WHEN no_data_found THEN
		 l_name := NULL;
	   END ;

	   select org_id into l_org_id from cn_comp_plans
	        where comp_plan_id = x_comp_plan_id;

	   cn_mark_events_pkg.mark_event_comp_plan
	     ( p_event_name => 'CHANGE_COMP_PLAN'
	       ,p_object_name => l_name
	       ,p_object_id   => x_comp_plan_id
	       ,p_start_date  => NULL
	       ,p_end_date    => NULL
	       ,p_start_date_old => l_start_date
	       ,p_end_date_old  => l_end_date,
           	p_org_id => l_org_id);

	   FOR rep_rec IN reps(x_comp_plan_id) LOOP
	      cn_srp_quota_assigns_pkg.delete_record
		(  x_srp_plan_assign_id => rep_rec.srp_plan_assign_id
		   ,x_quota_id	      => x_quota_id);
	   END LOOP;

        END IF;
      END;

  END Delete_Record;

  -- Name
  --
  -- Purpose
  --
  -- Notes
  --
  --

  PROCEDURE lock_record( x_quota_assign_Id  NUMBER
			,x_quota_id	    NUMBER) IS
    CURSOR c IS
    SELECT *
      FROM cn_quota_assigns
     WHERE quota_assign_id = x_quota_assign_id
      FOR UPDATE OF quota_assign_id NOWAIT;
    recinfo c%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    if (     (Recinfo.quota_id     =  X_quota_id) ) THEN
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END lock_record;
/* ------------------------------------------------------------------------
 |                            Public Routine Bodies                         |
  --------------------------------------------------------------------------*/

  -- Name
  --
  -- Purpose
  --
  -- Notes
  --
  --
   PROCEDURE Begin_Record
   (  X_Operation     	     	VARCHAR2
     ,X_Quota_Id             	NUMBER
     ,X_Comp_Plan_Id         	NUMBER
     ,X_Quota_Assign_Id IN OUT NOCOPY NUMBER
     ,X_Quota_Sequence          NUMBER
     ,x_quota_id_old		NUMBER
     ,X_ORG_ID NUMBER) IS
  BEGIN
      IF X_Operation = 'INSERT' THEN
        Insert_record ( X_Quota_Id
                       ,X_Comp_Plan_Id
		       ,X_Quota_Assign_Id
		       ,X_Quota_Sequence
           ,X_ORG_ID );

      ELSIF X_Operation = 'UPDATE' THEN
        Update_record ( X_Quota_Id
                       ,X_Comp_Plan_Id
                       ,X_Quota_Assign_Id
		       ,X_Quota_Sequence
		       ,x_quota_id_old
           ,X_ORG_ID );

      ELSIF X_Operation = 'DELETE' THEN
        Delete_Record ( X_Quota_Assign_Id
		       ,X_Comp_Plan_Id
		       ,x_quota_id);

      ELSIF X_Operation = 'LOCK' THEN
        lock_Record ( x_quota_assign_Id
		     ,x_quota_id);

      END IF;

    END Begin_Record;

  --
  -- Procedure Name
  --	get_quota_info
  -- Purpose
  --
  --

  PROCEDURE get_quota_info( X_quota_id         IN     NUMBER
			   ,X_name	       IN OUT NOCOPY VARCHAR2
			   ,x_quota_type_code  IN OUT NOCOPY VARCHAR2) IS
  BEGIN

      IF X_quota_id IS NOT NULL THEN

	  SELECT name
		,quota_type_code
          INTO   x_name
		,x_quota_type_code
	  FROM   cn_quotas
	  WHERE  quota_id = X_quota_id
	  ;

      END IF;

  EXCEPTION
    WHEN no_data_found THEN
      RAISE no_data_found;

  END get_quota_info;

  -- Name
  --
  -- Purpose
  --  check that the quota exists before you commit the assignment
  -- Notes
  --
  --

  PROCEDURE Check_exists(  X_Quota_Id	     NUMBER) IS
    X_Dummy NUMBER;
  BEGIN
      SELECT 1 INTO  X_dummy FROM   sys.dual
      WHERE EXISTS ( SELECT 1
		     FROM   cn_quotas
	  	     WHERE  quota_id 	= X_quota_id)
       ;

      EXCEPTION
      WHEN no_data_found THEN
	 fnd_message.Set_Name('CN', 'PLN_QUOTA_DELETED');
	 app_exception.Raise_Exception;

  END Check_exists;

  -- Name
  --
  -- Purpose
  --
  -- Notes
  --
  --

  PROCEDURE Check_duplicate( x_quota_id	       NUMBER
			    ,x_quota_assign_id NUMBER
			    ,x_comp_plan_id    NUMBER) IS
    X_Dummy NUMBER;

  BEGIN
    SELECT 1
      INTO x_dummy
      FROM sys.dual
      WHERE NOT EXISTS (
		SELECT 1
	          FROM cn_quota_assigns
	  	 WHERE quota_id 	= x_quota_id
		   AND comp_plan_id     = x_comp_plan_id
		   AND (    x_quota_assign_id IS NULL
			OR quota_assign_id <> x_quota_assign_id))
       ;

   EXCEPTION
      WHEN no_data_found THEN
        fnd_message.Set_Name('CN', 'PLN_QUOTA_ASSIGNED');
        app_exception.Raise_Exception;

  END Check_duplicate;

END CN_QUOTA_ASSIGNS_PKG;

/
