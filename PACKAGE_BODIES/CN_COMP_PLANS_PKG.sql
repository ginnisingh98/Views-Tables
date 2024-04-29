--------------------------------------------------------
--  DDL for Package Body CN_COMP_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COMP_PLANS_PKG" as
/* $Header: cnpliplb.pls 120.6.12010000.4 2008/09/08 16:05:26 ramchint ship $ */
/*
Date      Name          Description
-------------------------------------------------------------------------+-+
--06-MAR-95 P Cook      Fixed check_unique_rev_class (bug 268849)
--07-APR-95 A Erickson  In set_status: added call to Comp_Plan_Event.
--19-JUL-95 P Cook	Added quota period > plan period comparison to
--                      the validation routine
--28-JUL-95 P Cook	Added when others to delete_record to prevent
--                      unhandled exception when deleting an unassigned plan
--04-AUG-95 P Cook	Removed comparison of quota periods and planm periods
--                      no restrictions anymore.

--Purpose

--When we encounter data problems during execution of a conc program we do not
--stop processing and raise an error. We simply write the error to the plsql
--table and continue processing.
--When we encounter problems in a form we want to either stop further
--processing until the problem is fixed or display a warning before continuing.

--  currently not going to get plan name for insert/update/delete messages
--  issued in batch. when we write the batch code and get the message stack
--  working can replace this single line messaging with an outlined set
--  of messages broken by object. current messaging is targeted at the form
--  this limitiation applies to all comp plan objects
*/

--  -------------------------------------------------------------------------+
--  |                             Custom Validation
--  -------------------------------------------------------------------------+


-------------------------------------------------------------------------++
-- ProcedureName: Get_plan_name
-------------------------------------------------------------------------++
FUNCTION Get_plan_name ( X_Comp_Plan_Id     NUMBER) RETURN VARCHAR2 IS
   g_plan_name VARCHAR2(80);
BEGIN

   SELECT name
     INTO   g_plan_name
     FROM   cn_comp_plans
     WHERE  comp_plan_id  = x_comp_plan_id;

   return g_plan_name;
exception
   when no_data_found then
      return null;
END Get_plan_name;

-- Procedure Name
--
-- Purpose
--   Prevent the plan being made inactive in a period that is already
--   assigned to a salesrep.
--
-- Notes
--
--  -------------------------------------------------------------------------+
--  Procedure Name: Check_period_range
--  -------------------------------------------------------------------------+
FUNCTION check_period_range
  (    X_Comp_Plan_Id    NUMBER
      ,X_Start_Date      DATE
      ,X_End_Date        DATE) RETURN BOOLEAN IS

   -- return true if period range OK, false o/w
   X_dummy        NUMBER;
BEGIN
   SELECT count(1)
     INTO x_dummy
     FROM cn_srp_plan_assigns
    WHERE comp_plan_id  = x_comp_plan_id
      AND (   start_date  < x_start_date
	       OR end_date > x_end_date);

   if x_dummy > 0 then
      fnd_message.set_name('CN','PLN_PLAN_PRD_LT_SRP_PRD');
      fnd_msg_pub.add;
      return false;
   end if;
   return true;
END check_period_range;

-- Procedure Name
--  Check_unique_rev_class
-- Purpose
--  Ensure there are no duplicate revenue classes assigned to a comp plan.
--
-- Notes
--
--  Will not be called if the plan does not have any quota rules.
--  (Manual and draw quotas do not have quota rules)
--  Gets all subordinate revenue classes by exploding the parent revenue
--  classes entered on the plan (explosion includes the parent rev class).
--  If there are less unique values than present in the explosion we know
--  there are duplicate rev classes.
--  ------------------------------------------------------------------------+
--  Procedure Name: check_unique_rev_class
--  ------------------------------------------------------------------------+
-- clku, mblum, fixed bug 2870590
FUNCTION check_unique_rev_class
  ( x_comp_plan_id             NUMBER
    ,x_name                     VARCHAR2
    ,x_allow_rev_class_overlap  VARCHAR2
    ,x_sum_trx_flag VARCHAR2) RETURN BOOLEAN IS

       -- return true if okay, false o/w
       x_rev_class_total        NUMBER := 0;
       x_rev_class_total_unique NUMBER := 0;
       l_count        number := 0;
       l_start_date   date;
       l_end_date     date;

  cursor get_pe_info is
  select q.quota_id, q.start_date, q.end_date
    from cn_quotas_v q,
         cn_quota_assigns qa
   where qa.comp_plan_id = x_comp_plan_id
     and q.quota_id = qa.quota_id
     and q.quota_type_code IN ('EXTERNAL', 'FORMULA');

   type pe_tbl_type is table of get_pe_info%rowtype index by binary_integer;
   pes pe_tbl_type;

      cursor check_overlap_curs(l_rev_class_hierarchy_id number,l_start_date date,
                                l_end_date date, l_quota_id1 number, l_quota_id2 number) IS
      SELECT count(de.value_external_id),
             count(distinct de.value_external_id)
        FROM cn_dim_explosion     de,
             cn_quota_rules       qr,
             cn_dim_hierarchies   dh
       WHERE
	   -- dh.header_dim_hierarchy_id  = l_rev_class_hierarchy_id AND
         l_start_date  <= nvl(dh.end_date, l_start_date)
         AND dh.start_date <= nvl(l_end_date,  dh.start_date)
         AND de.dim_hierarchy_id     = dh.dim_hierarchy_id
         AND de.ancestor_external_id = qr.revenue_class_id
         AND qr.quota_id             in (l_quota_id1, l_quota_id2);

begin
   IF x_allow_rev_class_overlap = 'N' THEN
       for q in get_pe_info loop
           pes(l_count) := q;
           l_count := l_count + 1;
       end loop;

  for q1 in 0..l_count-1 loop
    for q2 in q1+1..l_count-1 loop
      l_start_date := greatest(pes(q1).start_date, pes(q2).start_date);
      l_end_date   :=    least(nvl(pes(q1).end_date, pes(q2).end_date),
                               nvl(pes(q2).end_date, pes(q1).end_date));

      if l_start_date <= nvl(l_end_date, l_start_date) then
        OPEN check_overlap_curs(cn_global_var.g_rev_class_hierarchy_id,
             l_start_date, l_end_date, pes(q1).quota_id, pes(q2).quota_id);
       FETCH check_overlap_curs INTO x_rev_class_total, x_rev_class_total_unique;
       CLOSE check_overlap_curs;

      IF  x_rev_class_total <> x_rev_class_total_unique THEN
          fnd_message.set_name('CN', 'PLN_PLAN_DUP_REV_CLASS');
          fnd_message.set_token('PLAN_NAME',
          get_plan_name(x_comp_plan_id));
          fnd_msg_pub.add;
          return false;
      END IF;
     end if;
    end loop;
  end loop;
 END IF;
   return true;
END check_unique_rev_class;

-- Procedure Name
--
-- Purpose
--    Prevent deletion of a plan if it is currently assigned to a salesrep
-- Notes
--
--  ------------------------------------------------------------------------+
--  Procedure Name:  Check_Assigned
--  ------------------------------------------------------------------------+
FUNCTION Check_Assigned( X_Comp_Plan_Id  NUMBER) RETURN BOOLEAN IS
   -- return true if okay, false o/w
   X_dummy        NUMBER;
BEGIN
   SELECT count(1)
     INTO x_dummy
     FROM cn_srp_plan_assigns
    WHERE comp_plan_id = x_comp_plan_id;

   if x_dummy > 0 then
      fnd_message.set_name('CN',  'PLN_PLAN_DELETE_NA');
      fnd_msg_pub.add;
      return false;
   end if;

   SELECT count(1)
     INTO x_dummy
     FROM cn_role_plans
    WHERE comp_plan_id = x_comp_plan_id;

   if x_dummy > 0 then
      fnd_message.set_name('CN', 'CN_ROLE_PLAN_ASSIGNED');
      fnd_msg_pub.add;
      return false;
   end if;
   return true;

END Check_Assigned;


-------------------------------------------------------------------------++
--Procedure Name : Get Status
-------------------------------------------------------------------------++
PROCEDURE Get_status
  (  X_Comp_Plan_Id         NUMBER
     ,X_status_code  IN OUT NOCOPY VARCHAR2
     ,X_status       IN OUT NOCOPY VARCHAR2) IS
BEGIN
   SELECT lc.meaning
     ,lc.lookup_code
     INTO   X_Status
     ,X_status_code
     FROM   cn_lookups    lc,
     cn_comp_plans cp
     WHERE cp.status_code  = lc.lookup_code
     AND   lc.lookup_type  = 'PLAN_OBJECT_STATUS'
     AND   cp.comp_plan_id = x_comp_plan_id
     ;

EXCEPTION
   WHEN no_data_found THEN X_status := NULL;

END Get_status;

-- Name
--
-- Purpose
--
-- Notes
--
--
-------------------------------------------------------------------------++
-- Get_Uid
-------------------------------------------------------------------------++
PROCEDURE Get_Uid ( X_Comp_Plan_Id           IN OUT NOCOPY NUMBER    ) IS
BEGIN
IF X_Comp_Plan_Id IS NULL OR X_Comp_Plan_Id = CN_API.G_MISS_ID OR X_Comp_Plan_Id = FND_API.G_MISS_NUM THEN
   SELECT cn_comp_plans_s.nextval
     INTO   x_comp_plan_id
     FROM   sys.dual;
END IF;
END Get_uid;

-- Name
--
-- Purpose
--  Set the plan status to incomplete.
-- Notes
--  Only one of the 3 id's (comp_plan_id, quota_id,rate_schedule_id) will
--  not be null at any one time.
--  Unable to make status_code an OUT parameter as it will mark the plan
--  Changing the date range on a plan does not impact the srp plan assigns
--  and therefore no need to maintain the srp period records
--
--  Called when
--  o The user tries to 'complete' the plan by the cn_comp_plans_pkg.
--	end_record
--  o After update of rate table
--  o After update of quota
-------------------------------------------------------------------------+
-- Procedure Name : Set_status
-------------------------------------------------------------------------+
PROCEDURE set_status
  (  x_comp_plan_id         NUMBER
     ,x_quota_id             NUMBER
     ,x_rate_schedule_id     NUMBER
     ,x_status_code          VARCHAR2
     ,x_event                VARCHAR2) IS

	CURSOR schedules IS
	   SELECT  pa.salesrep_id
	     ,pa.start_date
	     FROM cn_srp_plan_assigns pa
	     WHERE pa.comp_plan_id IN (SELECT qa.comp_plan_id
				       FROM cn_quota_assigns  qa,
				       cn_quotas_v              q,
				       cn_rt_quota_asgns      rqa
				       WHERE qa.quota_id   = q.quota_id
				       AND q.quota_id      = rqa.quota_id
				       AND rqa.rate_schedule_id = X_rate_schedule_id)
	     ORDER BY pa.salesrep_id, pa.start_date;

	CURSOR quotas IS
	   SELECT  pa.salesrep_id
	     ,pa.start_date
	     FROM  cn_srp_plan_assigns pa
	     WHERE  pa.comp_plan_id IN (SELECT qa.comp_plan_id
					FROM cn_quota_assigns qa
					WHERE qa.quota_id = x_quota_id)
	     ORDER BY pa.salesrep_id, pa.start_date;

	schedule_rec 	        schedules%ROWTYPE;
	quota_rec 		quotas%ROWTYPE;
	x_last_date 	        DATE;
	x_last_salesrep_id 	NUMBER;

BEGIN

   x_last_date   := NULL;
   x_last_salesrep_id := NULL;

   -- Log the comp plan event.
   /* IF x_comp_plan_id IS NOT NULL THEN
      cn_event_log_pkg.comp_plan_event( x_comp_plan_id ) ;
   END IF ;*/
   IF x_comp_plan_id IS NOT NULL THEN

      -- Called after comp plan update
      UPDATE cn_comp_plans
	SET    status_code  = x_status_code
	WHERE  comp_plan_id = x_comp_plan_id
	;

    ELSIF x_quota_id IS NOT NULL THEN

      -- called after quota, quota rule or trx factor update
      UPDATE cn_comp_plans
	SET    status_code   = x_status_code
	WHERE  comp_plan_id IN (SELECT qa.comp_plan_id
				FROM   cn_quota_assigns qa
				WHERE  qa.quota_id = x_quota_id)
	;

      IF x_status_code = 'INCOMPLETE' THEN
	 FOR quota_rec IN quotas LOOP

	    -- We only need to call mark_event once for each salesrep. If we can
	    -- find the earliest period in which they are assigned to
	    -- this schedule we can mark all periods forward if it

	    IF((quota_rec.salesrep_id = nvl(x_last_salesrep_id,
					    quota_rec.salesrep_id)
		AND quota_rec.start_date < nvl(x_last_date,
					       quota_rec.start_date+1) )
	       OR quota_rec.salesrep_id <> nvl(x_last_salesrep_id,
					       quota_rec.salesrep_id)
	       ) THEN

	       x_last_date        := quota_rec.start_date;
	       x_last_salesrep_id := quota_rec.salesrep_id;

	       -- cn_srp_periods_pkg.Mark_Event(
	       -- X_salesrep_id     => quota_rec.salesrep_id
	       --,X_start_period_id => quota_rec.start_period_id
	       --,X_end_period_id   => null
	       --,X_event           => x_event);*/
	    END IF;

	 END LOOP;

      END IF;

   ELSIF x_rate_schedule_id IS NOT NULL THEN

      -- Called after rate table update
      UPDATE cn_comp_plans
	SET    status_code   = x_status_code
	WHERE  comp_plan_id IN (SELECT qa.comp_plan_id
				FROM cn_quota_assigns qa,
				cn_quotas_v         q,
				cn_rt_quota_asgns rqa
				WHERE qa.quota_id        = q.quota_id
				AND q.quota_id         = rqa.quota_id
				AND rqa.rate_schedule_id = X_rate_schedule_id)
	;

      IF x_status_code = 'INCOMPLETE' THEN
	 FOR schedule_rec IN schedules LOOP

	    -- We only need to call mark_event once for each salesrep. If we can
	    -- find the earliest period in which they are using this schedule
	    -- we can mark all periods forward if it
	    --

	    IF((schedule_rec.salesrep_id = nvl(x_last_salesrep_id,
					       schedule_rec.salesrep_id)
		AND schedule_rec.start_date < nvl(x_last_date,
						  schedule_rec.start_date+1) )
	       OR schedule_rec.salesrep_id <> nvl(x_last_salesrep_id,
						  schedule_rec.salesrep_id)
	       ) THEN

	       x_last_date   := schedule_rec.start_date;
	       x_last_salesrep_id := quota_rec.salesrep_id;

	       -- cn_srp_periods_pkg.Mark_Event(
	       --         X_salesrep_id     => schedule_rec.salesrep_id
	       --	 ,X_start_period_id => schedule_rec.start_period_id
	       --        ,X_end_period_id   => null
	       --        ,X_event           => x_event); */
	    END IF;
	 END LOOP;

      END IF;



   END IF;

END Set_Status;


-------------------------------------------------------------------------+
-- Procedure Name : Insert_record
-------------------------------------------------------------------------+
PROCEDURE insert_record
  (X_Rowid           IN OUT NOCOPY      VARCHAR2  ,
   X_Comp_Plan_Id    IN OUT NOCOPY      NUMBER    ,
   X_Name                        VARCHAR2  ,
   X_Last_Update_Date            DATE      ,
   X_Last_Updated_By             NUMBER    ,
   X_Creation_Date               DATE      ,
   X_Created_By                  NUMBER    ,
   X_Last_Update_Login           NUMBER    ,
   X_Description                 VARCHAR2  ,
   X_Start_Date                  DATE      ,
   X_End_Date                    DATE      ,
   x_allow_rev_class_overlap	VARCHAR2   ,
   x_attribute_category         VARCHAR2   ,
   x_attribute1                 VARCHAR2   ,
   x_attribute2                 VARCHAR2   ,
   x_attribute3                 VARCHAR2   ,
   x_attribute4                 VARCHAR2   ,
   x_attribute5                 VARCHAR2   ,
   x_attribute6                 VARCHAR2   ,
   x_attribute7                 VARCHAR2   ,
   x_attribute8                 VARCHAR2   ,
   x_attribute9                 VARCHAR2   ,
   x_attribute10                VARCHAR2   ,
   x_attribute11                VARCHAR2   ,
   x_attribute12                VARCHAR2   ,
   x_attribute13                VARCHAR2   ,
   x_attribute14                VARCHAR2   ,
   x_attribute15                VARCHAR2   ,
   x_org_id                     NUMBER     ,
   x_sum_trx_flag               VARCHAR2
   ) IS


  l_sum_trx_flag varchar2(1) := 'Y';

BEGIN

if x_sum_trx_flag = CN_API.G_MISS_CHAR or x_sum_trx_flag = 'N' then
 l_sum_trx_flag :='N';
end if;




   Get_UID( X_Comp_Plan_Id );

   INSERT INTO
	CN_COMP_PLANS
	(
	 Comp_Plan_Id           ,
	 Name                   ,
	 Last_Update_Date       ,
	 Last_Updated_By        ,
	 Creation_Date          ,
	 Created_By             ,
	 Last_Update_Login      ,
	 Description            ,
	 Start_date             ,
	 End_date               ,
	 status_code            ,
	 allow_rev_class_overlap,
	 attribute_category     ,
	 attribute1             ,
	 attribute2             ,
	 attribute3             ,
	 attribute4             ,
	 attribute5             ,
	 attribute6             ,
	 attribute7             ,
	 attribute8             ,
	 attribute9             ,
	 attribute10            ,
	 attribute11            ,
	 attribute12            ,
	 attribute13            ,
	 attribute14            ,
	 attribute15            ,
         object_version_number,
         org_id,
         sum_trx_flag
     )
	VALUES
	(
	 X_Comp_Plan_Id           ,
	 X_Name                   ,
	 X_Last_Update_Date       ,
	 X_Last_Updated_By        ,
	 X_Creation_Date          ,
	 X_Created_By             ,
	 X_Last_Update_Login      ,
	 X_Description            ,
	 X_Start_Date             ,
	 X_End_Date               ,
	 'INCOMPLETE'             ,
	 x_allow_rev_class_overlap,
	 x_attribute_category     ,
	 x_attribute1             ,
	 x_attribute2             ,
	 x_attribute3             ,
	 x_attribute4             ,
	 x_attribute5             ,
	 x_attribute6             ,
	 x_attribute7             ,
	 x_attribute8             ,
	 x_attribute9             ,
	 x_attribute10            ,
	 x_attribute11            ,
	 x_attribute12            ,
	 x_attribute13            ,
	 x_attribute14            ,
	 x_attribute15            ,
         0,
         X_org_id,
         l_sum_trx_flag
         );

END Insert_Record;


-- Name
--
-- Purpose
--
-- Notes
--
--
-------------------------------------------------------------------------+
-- Procedure Name : Update_record
-------------------------------------------------------------------------+
PROCEDURE update_record
  (
   X_Comp_Plan_Id   IN OUT NOCOPY  NUMBER    ,
   X_Name                   VARCHAR2  ,
   X_Last_Update_Date       DATE      ,
   X_Last_Updated_By        NUMBER    ,
   X_Last_Update_Login      NUMBER    ,
   X_Description            VARCHAR2  ,
   X_Start_date             DATE    ,
   X_Start_date_old         DATE    ,
   X_End_date               DATE    ,
   X_End_date_old           DATE    ,
   x_status_code            VARCHAR2  ,
   x_allow_rev_class_overlap VARCHAR2 ,
   x_allow_rev_class_overlap_old	VARCHAR2,
   x_sum_trx_flag                 VARCHAR2,
   x_attribute_category         VARCHAR2   ,
   x_attribute1                 VARCHAR2   ,
   x_attribute2                 VARCHAR2   ,
   x_attribute3                 VARCHAR2   ,
   x_attribute4                 VARCHAR2   ,
   x_attribute5                 VARCHAR2   ,
   x_attribute6                 VARCHAR2   ,
   x_attribute7                 VARCHAR2   ,
   x_attribute8                 VARCHAR2   ,
   x_attribute9                 VARCHAR2   ,
   x_attribute10                VARCHAR2   ,
   x_attribute11                VARCHAR2   ,
   x_attribute12                VARCHAR2   ,
   x_attribute13                VARCHAR2   ,
   x_attribute14                VARCHAR2   ,
   x_attribute15                VARCHAR2   ) IS

BEGIN
   --    Reinstate when the package is called as a batch process
   --    check_unique( x_comp_plan_id,x_Name);
   --    check_period_range( x_comp_plan_id
   --                       ,x_start_period_id
   --                       ,x_end_period_id);
   UPDATE cn_comp_plans
     SET
     Comp_Plan_Id           = X_Comp_Plan_Id           ,
     Name                   = X_Name                   ,
     Last_Update_Date       = X_Last_Update_Date       ,
     Last_Updated_By        = X_Last_Updated_By        ,
     Last_Update_Login      = X_Last_Update_Login      ,
     Description            = X_Description            ,
     Start_Date             = X_Start_Date             ,
     End_Date               = X_End_Date               ,
     allow_rev_class_overlap= x_allow_rev_class_overlap,
     sum_trx_flag           = x_sum_trx_flag,
     attribute_category     = x_attribute_category,
     attribute1             = x_attribute1,
     attribute2             = x_attribute2,
     attribute3             = x_attribute3,
     attribute4             = x_attribute4,
     attribute5             = x_attribute5,
     attribute6             = x_attribute6,
     attribute7             = x_attribute7,
     attribute8             = x_attribute8,
     attribute9             = x_attribute9,
     attribute10            = x_attribute10,
     attribute11            = x_attribute11,
     attribute12            = x_attribute12,
     attribute13            = x_attribute13,
     attribute14            = x_attribute14,
     attribute15            = x_attribute15,
     object_version_number  = object_version_number + 1,
     status_code            =
     decode(x_start_date , nvl(x_start_date_old,fnd_api.g_miss_date),
	    decode(x_end_date, nvl(x_end_date_old,fnd_api.g_miss_date),
		   decode(x_allow_rev_class_overlap,
			  nvl(x_allow_rev_class_overlap_old,'X'),
			  status_code, 'INCOMPLETE'
			  ),  'INCOMPLETE'
		   ), 'INCOMPLETE'
	    )
     WHERE comp_plan_id = X_comp_plan_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END Update_Record;


-------------------------------------------------------------------------+
-- Procedure Name : Lock Record
-------------------------------------------------------------------------+
PROCEDURE lock_record
  (  X_Rowid                  VARCHAR2  ,
     X_Comp_Plan_Id           NUMBER    ,
     X_Name                   VARCHAR2  ,
     X_Description            VARCHAR2  ,
     X_Start_date             DATE      ,
     X_End_date               DATE      ,
     x_allow_rev_class_overlap VARCHAR2  ,
     x_sum_trx_flag            VARCHAR2  ,
     x_attribute_category     VARCHAR2   ,
     x_attribute1             VARCHAR2   ,
     x_attribute2             VARCHAR2   ,
     x_attribute3             VARCHAR2   ,
     x_attribute4             VARCHAR2   ,
     x_attribute5             VARCHAR2   ,
     x_attribute6             VARCHAR2   ,
     x_attribute7             VARCHAR2   ,
     x_attribute8             VARCHAR2   ,
     x_attribute9             VARCHAR2   ,
     x_attribute10            VARCHAR2   ,
     x_attribute11            VARCHAR2   ,
     x_attribute12            VARCHAR2   ,
     x_attribute13            VARCHAR2   ,
     x_attribute14            VARCHAR2   ,
     x_attribute15            VARCHAR2   ) IS

	CURSOR C IS
	   SELECT * FROM CN_COMP_PLANS
	     WHERE comp_plan_id = X_Comp_Plan_id
	     FOR UPDATE OF COMP_PLAN_ID NOWAIT;
	Recinfo C%ROWTYPE;

BEGIN
   OPEN C;
   FETCH C INTO Recinfo;
   IF C%NOTFOUND THEN
      CLOSE C;
      fnd_message.set_name('FND','FORM_RECORD_DELETED');
      app_exception.raise_exception;
   END IF;
   CLOSE C;
   IF (
       (    Recinfo.Comp_Plan_Id           = x_comp_plan_id           )
       AND (Recinfo.Name                   = x_name                   )
       AND (Recinfo.allow_rev_class_overlap= X_allow_rev_class_overlap)
       AND (   (Recinfo.Description        = x_description            )
	       OR (    (Recinfo.description IS NULL      )
		       AND (X_description IS NULL)
		       )
	       )
       AND (Recinfo.Start_DATE        = X_Start_DATE                  )
       AND (   (Recinfo.End_date      = x_end_date )
	       OR (    (Recinfo.End_date IS NULL   )
		       AND (X_End_date IS NULL     )
		       )
	       ) ) THEN
      RETURN;
    ELSE
      fnd_message.set_name('FND','FORM_RECORD_CHANGED');
      app_exception.raise_exception;
   END IF;

END Lock_Record;


-------------------------------------------------------------------------+
-- Procedure Name : Delete_Record
-------------------------------------------------------------------------+
PROCEDURE delete_record(x_comp_plan_id           NUMBER) IS
   l_okay boolean;
   l_junk number;
   l_exists number;
BEGIN

   l_okay := Check_Assigned( X_Comp_Plan_Id);

   IF not l_okay then
      RAISE FND_API.G_EXC_ERROR ;
   end if;

   select 1 into l_exists FROM cn_comp_plans
     WHERE  comp_plan_id = x_comp_plan_id;

   IF SQL%FOUND THEN
      -- Delete all quota assignments that belong to the plan
      -- this wil cascade to all child tables
      cn_quota_assigns_pkg.begin_record
	(X_Operation           => 'DELETE',
	 X_Quota_Id            => null, -- delete all quotas assigned to plan
	 X_Comp_Plan_Id        => x_comp_plan_id,
	 X_Quota_Assign_Id     => l_junk, -- not used
	 X_Quota_Sequence      => null, -- not used
	 x_quota_id_old        => null,
     x_org_id => NULL);-- not used
   END IF;

   DELETE FROM cn_comp_plans
     WHERE  comp_plan_id = x_comp_plan_id;

END Delete_Record;
-------------------------------------------------------------------------+
--                                PUBLIC ROUTINE BODIES
-------------------------------------------------------------------------+
-- Procedure Name
--    Check_Unique
-- Purpose
--    Detect a value that would cause a constraint violation
-------------------------------------------------------------------------+
-- CHECK UNIQUE
-------------------------------------------------------------------------+
FUNCTION Check_Unique( X_Comp_Plan_Id NUMBER
		       ,X_Name         VARCHAR2) RETURN BOOLEAN IS
   -- return true if ok, false o/w
   X_dummy        NUMBER;

BEGIN
   SELECT count(1)
     INTO X_dummy
     FROM cn_comp_plans
    WHERE name = X_Name
      AND (X_Comp_Plan_Id IS NULL
	   OR X_Comp_Plan_Id <> comp_plan_id);

   if x_dummy > 0 then
      fnd_message.set_name('CN', 'PLN_PLAN_EXISTS');
      fnd_msg_pub.add;
      return false;
   end if;
   return true;

END Check_Unique;
-------------------------------------------------------------------------+
-- BEGIN RECORD
-------------------------------------------------------------------------+
-- Name
--
-- Purpose
--
-- Notes
--
--
 PROCEDURE Begin_Record
  (
   X_Operation                VARCHAR2
   ,X_Rowid            IN OUT NOCOPY  VARCHAR2
   ,X_Comp_Plan_Id     IN OUT NOCOPY  NUMBER
   ,X_Name                     VARCHAR2
   ,X_Last_Update_Date         DATE
   ,X_Last_Updated_By          NUMBER
   ,X_Creation_Date            DATE
   ,X_Created_By               NUMBER
   ,X_Last_Update_Login        NUMBER
   ,X_Description              VARCHAR2
   ,X_Start_date               DATE
   ,X_Start_date_old           DATE
   ,X_end_date                 DATE
   ,X_end_date_old             DATE
   ,X_Program_Type             VARCHAR2 -- not used
   ,x_status_code              VARCHAR2
   ,x_allow_rev_class_overlap  VARCHAR2
   ,x_allow_rev_class_overlap_old VARCHAR2
   ,x_sum_trx_flag                VARCHAR2
   ,x_attribute_category       VARCHAR2
   ,x_attribute1               VARCHAR2
   ,x_attribute2               VARCHAR2
   ,x_attribute3               VARCHAR2
   ,x_attribute4               VARCHAR2
   ,x_attribute5               VARCHAR2
   ,x_attribute6               VARCHAR2
   ,x_attribute7               VARCHAR2
   ,x_attribute8               VARCHAR2
   ,x_attribute9               VARCHAR2
   ,x_attribute10              VARCHAR2
   ,x_attribute11              VARCHAR2
   ,x_attribute12              VARCHAR2
   ,x_attribute13              VARCHAR2
   ,x_attribute14              VARCHAR2
   ,x_attribute15              VARCHAR2
   ,x_org_id                   NUMBER
  ) IS


BEGIN

   IF X_Operation = 'INSERT' THEN


      Insert_record ( X_Rowid               ,
		      X_Comp_Plan_Id          ,
		      X_Name                  ,
		      X_Last_Update_Date      ,
		      X_Last_Updated_By       ,
		      X_Creation_Date         ,
		      X_Created_By            ,
		      X_Last_Update_Login     ,
		      X_Description           ,
		      X_start_date            ,
		      X_end_date              ,
		      x_allow_rev_class_overlap,
		      x_attribute_category,
		      x_attribute1,
		      x_attribute2,
		      x_attribute3,
		      x_attribute4,
		      x_attribute5 ,
		      x_attribute6 ,
		      x_attribute7,
		      x_attribute8,
		      x_attribute9,
		      x_attribute10,
		      x_attribute11 ,
		      x_attribute12 ,
		      x_attribute13 ,
		      x_attribute14 ,
		      x_attribute15,
		      x_org_id,
          x_sum_trx_flag
		      );

    ELSIF X_Operation = 'UPDATE' THEN

      Update_record (X_Comp_Plan_Id           ,
		     X_Name                   ,
		     X_Last_Update_Date       ,
		     X_Last_Updated_By        ,
		     X_Last_Update_Login      ,
		     X_Description            ,
		     X_Start_date             ,
		     X_Start_date_old         ,
		     X_End_date               ,
		     X_End_date_old           ,
		     x_status_code            ,
		     x_allow_rev_class_overlap,
		     x_allow_rev_class_overlap_old,
         x_sum_trx_flag,
		     x_attribute_category,
                     x_attribute1 ,
                     x_attribute2 ,
                     x_attribute3 ,
                     x_attribute4 ,
                     x_attribute5 ,
                     x_attribute6 ,
                     x_attribute7,
                     x_attribute8,
                     x_attribute9,
                     x_attribute10,
                     x_attribute11 ,
                     x_attribute12 ,
                     x_attribute13 ,
                     x_attribute14 ,
                     x_attribute15 );
    ELSIF X_Operation = 'LOCK' THEN

      Lock_record ( X_Rowid ,
		    X_Comp_Plan_Id           ,
		    X_Name                   ,
		    X_Description            ,
		    X_Start_date             ,
		    X_End_date               ,
		    x_allow_rev_class_overlap,
        x_sum_trx_flag,
		    x_attribute_category ,
		    x_attribute1 ,
		    x_attribute2 ,
		    x_attribute3 ,
		    x_attribute4 ,
		    x_attribute5 ,
		    x_attribute6 ,
		    x_attribute7 ,
		    x_attribute8 ,
		    x_attribute9 ,
		    x_attribute10 ,
		    x_attribute11 ,
		    x_attribute12 ,
		    x_attribute13 ,
		    x_attribute14 ,
		    x_attribute15
		    );
    ELSIF X_Operation = 'DELETE' THEN

      Delete_Record (  X_Comp_Plan_Id);

   END IF;

END Begin_Record;
-------------------------------------------------------------------------+
-- END RECORD
-------------------------------------------------------------------------+
-- Procedure Name
--
-- Purpose
--   Write warning messages if:
--   1. No quotas assigned
--   2. Quotas include overlapping revenue classes
--   3. quota active periods are outside the plan active periods
--
-- Notes
--
PROCEDURE End_Record
  (
   X_Rowid                     VARCHAR2  ,
   X_Comp_Plan_Id              NUMBER    ,
   X_Name                      VARCHAR2  ,
   X_Description               VARCHAR2  ,
   x_start_date                DATE      ,
   x_end_date                  DATE      ,
   X_Program_Type              VARCHAR2  ,  -- not used
   x_status_code               VARCHAR2  ,
   x_allow_rev_class_overlap   VARCHAR2,
   x_sum_trx_flag              VARCHAR2) IS

      CURSOR quotas IS
	 SELECT   qa.quota_id
	   ,q.quota_type_code
	   ,q.name
	   FROM    cn_quota_assigns qa,
	   cn_quotas_v q
	   WHERE   qa.comp_plan_id = x_comp_plan_id
	   AND   qa.quota_id = q.quota_id;
      quota_rec quotas%ROWTYPE;

      x_quota_status_code   VARCHAR2(30);
      x_dummy               NUMBER := NULL;
      l_Temp_Status_Code    VARCHAR2(30);
      l_okay                BOOLEAN;
      l_return_status       varchar2(50);
     l_msg_count        NUMBER;
     l_msg_data         VARCHAR2(2000);
BEGIN
   l_temp_status_code  := 'COMPLETE';
   x_quota_status_code := 'COMPLETE';

   OPEN quotas;
   LOOP
      FETCH quotas into quota_rec;

      IF quotas%rowcount = 0 THEN
	 l_temp_status_code  := 'INCOMPLETE';
	 fnd_message.set_name('CN', 'PLN_PLAN_NO_QUOTAS');
	 fnd_message.set_token('PLAN_NAME', get_plan_name(x_comp_plan_id));
	 fnd_msg_pub.add;
	 exit;
       ELSIF quotas%notfound THEN
	 -- at the end of the loop
         exit;
      END IF;

      -- validate the quotas
      /*cn_quotas_pkg.end_record
	( X_Rowid            => null
	 ,X_Quota_Id         => quota_rec.quota_id
	 ,X_Name             => null
	 ,X_Rate_Schedule_Id => x_dummy
	 ,X_Target           => null
	 ,X_Description      => null
	 ,X_Program_Type     => null
	 ,x_status_code      => x_quota_status_code
	 ,x_plan_name        => get_plan_name(x_comp_plan_id)
	 ,x_quota_type_code  => quota_rec.quota_type_code);*/

      cn_plan_element_pvt.validate_plan_element(
      p_api_version   => 1.0           ,
      p_init_msg_list =>'F',
      p_commit        => 'F',
      p_validation_level => fnd_api.g_valid_level_full,
      p_comp_plan_id     => x_comp_plan_id,
      p_quota_id         => quota_rec.quota_id,
      x_status_code      => x_quota_status_code    ,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data);

      -- return the status code from the quota

      -- we want to zoom through all quotas writing their status to
      -- a table for reporting
      -- then simply set the status of the plan to 'incomplete' if
      -- ANY of the quotas are incomplete - hence use of
      -- quota_status_code set on first occurence of incomplete
      -- however because message stacking is not working yet
      -- we only display one message before setting the plan status
      -- to invalid

      IF x_quota_status_code = 'INCOMPLETE' THEN
	 l_temp_status_code := 'INCOMPLETE';
	 exit;
      END IF;

   END LOOP;

   -- if no quotas are assigned or any the assigned quotas do not have quota
   -- rules (rev classes) then the status code will be incomplete and this
   -- uniqueness check will not be executed

   IF l_temp_status_code = 'COMPLETE' THEN

      l_okay := check_unique_rev_class
	( x_comp_plan_Id
	  ,x_name
	  ,x_allow_rev_class_overlap,x_sum_trx_flag);
      if not l_okay then
	 l_temp_status_code := 'INCOMPLETE';
      end if;
   END IF;

   CLOSE quotas;

   set_status ( x_comp_plan_id        => x_comp_plan_id
	       ,x_quota_id            => null
	       ,x_rate_schedule_id    => null
	       ,x_status_code         => l_temp_status_code
	       ,x_event               => null);

   x_quota_status_code := null;

END End_Record;

END CN_COMP_PLANS_PKG;

/
