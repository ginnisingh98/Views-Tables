--------------------------------------------------------
--  DDL for Package Body CN_SRP_PLAN_ASSIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PLAN_ASSIGNS_PKG" AS
-- $Header: cnsrplab.pls 120.0 2005/06/06 17:57:37 appldev noship $
--
-- Package Name
-- CN_SRP_PLAN_ASSIGNS_PKG
-- Purpose
--  Table Handler for CN_SRP_PLAN_ASSIGNS
--  FORM 	CNSRMT
--  BLOCK	SRP_PLAN_ASSIGNS
--
-- History
-- 06-Jun-99	Angela Chung	Created
-- /*-------------------------------------------------------------------------*
-- |
-- |                             PRIVATE VARIABLES
-- |
-- *-------------------------------------------------------------------------*/

--  -------------------------------------------------------------------------+
-- Procedure Name
--	Get_UID
-- Purpose
--    Get the Sequence Number to Create a new Srp Plan Assign.
--  -------------------------------------------------------------------------+
PROCEDURE Get_UID( X_srp_plan_assign_id     IN OUT NOCOPY NUMBER) IS
BEGIN
   SELECT  cn_srp_plan_assigns_s.nextval
     INTO  x_srp_plan_assign_id
     FROM  dual;
END Get_UID;

--  -------------------------------------------------------------------------+
-- Procedure Name
--	Get_UID
-- Purpose
--    Get the Next period
--  -------------------------------------------------------------------------+
FUNCTION next_period (p_end_date DATE, p_org_id NUMBER)
   RETURN cn_period_statuses.end_date%TYPE IS

      l_next_end_date cn_period_statuses.end_date%TYPE;

   BEGIN

      SELECT MAX(end_date)
        INTO l_next_end_date
        FROM cn_period_statuses_all s, cn_repositories_all r
       WHERE s.period_type_id = r.period_type_id
	AND s.period_set_id  = r.period_set_id
	AND s.org_id = p_org_id
	AND r.org_id = p_org_id;

     IF trunc(l_next_end_date) > trunc(p_end_date) THEN

        SELECT MIN(end_date)
          INTO l_next_end_date
          FROM cn_period_statuses_all s, cn_repositories_all r
         WHERE trunc(end_date) >= trunc(p_end_date)
           AND s.period_type_id = r.period_type_id
	  AND s.period_set_id  = r.period_set_id
	  AND s.org_id = p_org_id
	  AND r.org_id = p_org_id;

     END IF;

     RETURN l_next_end_date;

   EXCEPTION
      WHEN no_data_found THEN
         RETURN NULL;
END next_period;

-- -------------------------------------------------------------------------+
-- Procedure Name
--   INSERT_ROW
-- Purpose
--
-- History
--
-- -------------------------------------------------------------------------+
PROCEDURE INSERT_ROW
  (X_SRP_PLAN_ASSIGN_ID IN OUT NOCOPY NUMBER,
   X_SRP_ROLE_ID IN NUMBER,
   X_ROLE_PLAN_ID IN NUMBER,
   X_SALESREP_ID IN NUMBER,
   X_ROLE_ID IN NUMBER,
   X_COMP_PLAN_ID IN NUMBER,
   X_START_DATE IN DATE,
   X_END_DATE IN DATE,
   X_ATTRIBUTE_CATEGORY IN VARCHAR2,
   X_ATTRIBUTE1 IN VARCHAR2,
   X_ATTRIBUTE2 IN VARCHAR2,
   X_ATTRIBUTE3 IN VARCHAR2,
   X_ATTRIBUTE4 IN VARCHAR2,
   X_ATTRIBUTE5 IN VARCHAR2,
   X_ATTRIBUTE6 IN VARCHAR2,
   X_ATTRIBUTE7 IN VARCHAR2,
   X_ATTRIBUTE8 IN VARCHAR2,
   X_ATTRIBUTE9 IN VARCHAR2,
   X_ATTRIBUTE10 IN VARCHAR2,
   X_ATTRIBUTE11 IN VARCHAR2,
   X_ATTRIBUTE12 IN VARCHAR2,
   X_ATTRIBUTE13 IN VARCHAR2,
   X_ATTRIBUTE14 IN VARCHAR2,
   X_ATTRIBUTE15 IN VARCHAR2,
   X_CREATED_BY IN NUMBER,
   X_CREATION_DATE IN DATE,
   X_LAST_UPDATE_DATE IN DATE,
   X_LAST_UPDATED_BY IN NUMBER,
   X_LAST_UPDATE_LOGIN IN NUMBER
   ) IS
      l_dummy NUMBER;
      l_start_period_id cn_srp_periods.period_id%TYPE;
      l_end_period_id   cn_srp_periods.period_id%TYPE;
      l_org_id          NUMBER;

BEGIN

   Get_UID(X_SRP_PLAN_ASSIGN_ID);

   -- get org ID
   SELECT org_id INTO l_org_id
     FROM cn_comp_plans_all
    WHERE comp_plan_id = x_comp_plan_id;

   INSERT INTO CN_SRP_PLAN_ASSIGNS
     (SRP_PLAN_ASSIGN_ID,
      SRP_ROLE_ID,
      ROLE_PLAN_ID,
      SALESREP_ID,
      ORG_ID,
      ROLE_ID,
      COMP_PLAN_ID,
      START_DATE,
      END_DATE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
      ) VALUES
     (X_SRP_PLAN_ASSIGN_ID,
     X_SRP_ROLE_ID,
     X_ROLE_PLAN_ID,
     X_SALESREP_ID,
     l_ORG_ID,
     X_ROLE_ID,
     X_COMP_PLAN_ID,
     X_START_DATE,
     X_END_DATE,
     X_ATTRIBUTE_CATEGORY,
     X_ATTRIBUTE1,
     X_ATTRIBUTE2,
     X_ATTRIBUTE3,
     X_ATTRIBUTE4,
     X_ATTRIBUTE5,
     X_ATTRIBUTE6,
     X_ATTRIBUTE7,
     X_ATTRIBUTE8,
     X_ATTRIBUTE9,
     X_ATTRIBUTE10,
     X_ATTRIBUTE11,
     X_ATTRIBUTE12,
     X_ATTRIBUTE13,
     X_ATTRIBUTE14,
     X_ATTRIBUTE15,
     X_CREATION_DATE,
     X_CREATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN
     );
   SELECT 1 INTO l_dummy  FROM CN_SRP_PLAN_ASSIGNS_ALL
     WHERE SRP_PLAN_ASSIGN_ID = X_SRP_PLAN_ASSIGN_ID;

   -- insert all child records -- called in API:CN_SRP_PLAN_ASSIGNS_PVT
   -- cn_srp_quota_assigns_pkg.insert_record

END INSERT_ROW;

-- -------------------------------------------------------------------------+
-- Procedure Name
--   LOCK_ROW
-- Purpose
--
-- History
--
-- -------------------------------------------------------------------------+
PROCEDURE LOCK_ROW
  (X_SRP_PLAN_ASSIGN_ID IN NUMBER,
   X_SRP_ROLE_ID IN NUMBER,
   X_ROLE_PLAN_ID IN NUMBER,
   X_SALESREP_ID IN NUMBER,
   X_ROLE_ID IN NUMBER,
   X_COMP_PLAN_ID IN NUMBER,
   X_START_DATE IN DATE,
   X_END_DATE IN DATE,
   X_ATTRIBUTE_CATEGORY IN VARCHAR2,
   X_ATTRIBUTE1 IN VARCHAR2,
   X_ATTRIBUTE2 IN VARCHAR2,
   X_ATTRIBUTE3 IN VARCHAR2,
   X_ATTRIBUTE4 IN VARCHAR2,
   X_ATTRIBUTE5 IN VARCHAR2,
   X_ATTRIBUTE6 IN VARCHAR2,
   X_ATTRIBUTE7 IN VARCHAR2,
   X_ATTRIBUTE8 IN VARCHAR2,
   X_ATTRIBUTE9 IN VARCHAR2,
   X_ATTRIBUTE10 IN VARCHAR2,
   X_ATTRIBUTE11 IN VARCHAR2,
   X_ATTRIBUTE12 IN VARCHAR2,
   X_ATTRIBUTE13 IN VARCHAR2,
   X_ATTRIBUTE14 IN VARCHAR2,
   X_ATTRIBUTE15 IN VARCHAR2
   ) IS
      CURSOR c IS
	 SELECT * FROM CN_SRP_PLAN_ASSIGNS_ALL
	   WHERE SRP_PLAN_ASSIGN_ID = X_SRP_PLAN_ASSIGN_ID
	   FOR UPDATE OF SRP_PLAN_ASSIGN_ID nowait;
     tlinfo C%ROWTYPE;
BEGIN
     OPEN C;
     FETCH C INTO tlinfo;
     IF (C%NOTFOUND) THEN
        CLOSE C;
        fnd_message.Set_Name('FND', 'FORM_RECORD_DELETED');
        app_exception.raise_exception;
     END IF;
     CLOSE C;

     IF ((tlinfo.SRP_PLAN_ASSIGN_ID = X_SRP_PLAN_ASSIGN_ID)
	 AND (tlinfo.ROLE_PLAN_ID = X_ROLE_PLAN_ID)
	 AND (tlinfo.SRP_ROLE_ID = X_SRP_ROLE_ID)
	 AND (tlinfo.SALESREP_ID = X_SALESREP_ID)
	 AND (tlinfo.ROLE_ID = X_ROLE_ID)
	 AND (tlinfo.COMP_PLAN_ID = X_COMP_PLAN_ID)
	 AND (tlinfo.START_DATE = X_START_DATE)
	 AND ((tlinfo.END_DATE = X_END_DATE)
	      OR ((tlinfo.END_DATE is null) AND (X_END_DATE is null)))
	 AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
	      OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
		  AND (X_ATTRIBUTE_CATEGORY is null)))
	 AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
	      OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
	 AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
	      OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
	 AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
               OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
	 AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
	      OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
	 AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
	      OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
	 AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
	      OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
	 AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
	      OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
	 AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
	      OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
         AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
	      OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
         AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
	      OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
         AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
	      OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
         AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
	      OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
         AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
	      OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
         AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
	      OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
         AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
	      OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
		) THEN
	RETURN;
      ELSE
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
     END IF ;

END LOCK_ROW;

-- -------------------------------------------------------------------------+
-- Procedure Name
--   UPDATE_ROW
-- Purpose
--
-- History
--
-- -------------------------------------------------------------------------+
PROCEDURE UPDATE_ROW
  (X_SRP_PLAN_ASSIGN_ID IN NUMBER,
   X_SRP_ROLE_ID IN NUMBER,
   X_ROLE_PLAN_ID IN NUMBER,
   X_SALESREP_ID IN NUMBER,
   X_ROLE_ID IN NUMBER,
   X_COMP_PLAN_ID IN NUMBER,
   X_START_DATE IN DATE,
   X_END_DATE IN DATE,
   X_ATTRIBUTE_CATEGORY IN VARCHAR2,
   X_ATTRIBUTE1 IN VARCHAR2,
   X_ATTRIBUTE2 IN VARCHAR2,
   X_ATTRIBUTE3 IN VARCHAR2,
   X_ATTRIBUTE4 IN VARCHAR2,
   X_ATTRIBUTE5 IN VARCHAR2,
   X_ATTRIBUTE6 IN VARCHAR2,
   X_ATTRIBUTE7 IN VARCHAR2,
   X_ATTRIBUTE8 IN VARCHAR2,
   X_ATTRIBUTE9 IN VARCHAR2,
   X_ATTRIBUTE10 IN VARCHAR2,
   X_ATTRIBUTE11 IN VARCHAR2,
   X_ATTRIBUTE12 IN VARCHAR2,
   X_ATTRIBUTE13 IN VARCHAR2,
   X_ATTRIBUTE14 IN VARCHAR2,
   X_ATTRIBUTE15 IN VARCHAR2,
   X_LAST_UPDATE_DATE IN DATE,
   X_LAST_UPDATED_BY IN NUMBER,
   X_LAST_UPDATE_LOGIN IN NUMBER
   ) IS

      l_srp_role_id		CN_SRP_PLAN_ASSIGNS.srp_role_id%TYPE;
      l_role_plan_id		CN_SRP_PLAN_ASSIGNS.role_plan_id%TYPE;
      l_salesrep_id		CN_SRP_PLAN_ASSIGNS.salesrep_id%TYPE;
      l_role_id		        CN_SRP_PLAN_ASSIGNS.role_id%TYPE;
      l_comp_plan_id 		CN_SRP_PLAN_ASSIGNS.comp_plan_id%TYPE;
      l_start_date		CN_SRP_PLAN_ASSIGNS.start_date%TYPE;
      l_end_date		CN_SRP_PLAN_ASSIGNS.end_date%TYPE;
      l_attribute_category	CN_SRP_PLAN_ASSIGNS.attribute_category%TYPE;
      l_attribute1		CN_SRP_PLAN_ASSIGNS.attribute1%TYPE;
      l_attribute2	     	CN_SRP_PLAN_ASSIGNS.attribute2%TYPE;
      l_attribute3	       	CN_SRP_PLAN_ASSIGNS.attribute3%TYPE;
      l_attribute4	       	CN_SRP_PLAN_ASSIGNS.attribute4%TYPE;
      l_attribute5	       	CN_SRP_PLAN_ASSIGNS.attribute5%TYPE;
      l_attribute6	       	CN_SRP_PLAN_ASSIGNS.attribute6%TYPE;
      l_attribute7	       	CN_SRP_PLAN_ASSIGNS.attribute7%TYPE;
      l_attribute8	       	CN_SRP_PLAN_ASSIGNS.attribute8%TYPE;
      l_attribute9	       	CN_SRP_PLAN_ASSIGNS.attribute9%TYPE;
      l_attribute10		CN_SRP_PLAN_ASSIGNS.attribute10%TYPE;
      l_attribute11		CN_SRP_PLAN_ASSIGNS.attribute11%TYPE;
      l_attribute12		CN_SRP_PLAN_ASSIGNS.attribute12%TYPE;
      l_attribute13		CN_SRP_PLAN_ASSIGNS.attribute13%TYPE;
      l_attribute14		CN_SRP_PLAN_ASSIGNS.attribute14%TYPE;
      l_attribute15		CN_SRP_PLAN_ASSIGNS.attribute15%TYPE;

      l_next_start_date         cn_acc_period_statuses_v.end_date%TYPE;

   CURSOR c IS
      SELECT * FROM CN_SRP_PLAN_ASSIGNS_ALL
	WHERE SRP_PLAN_ASSIGN_ID = X_SRP_PLAN_ASSIGN_ID
	FOR UPDATE OF SRP_PLAN_ASSIGN_ID nowait;
     oldrow C%ROWTYPE;

BEGIN
   OPEN C;
   FETCH C INTO oldrow;
   IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
   CLOSE C;
    SELECT
      decode(x_srp_role_id,
	     fnd_api.g_miss_num, oldrow.srp_role_id,
	     x_srp_role_id),
      decode(x_role_plan_id,
	     fnd_api.g_miss_num, oldrow.role_plan_id,
	     x_role_plan_id),
      decode(x_salesrep_id,
	     fnd_api.g_miss_num, oldrow.salesrep_id,
	     x_salesrep_id),
      decode(x_role_id,
	     fnd_api.g_miss_num, oldrow.role_id,
	     x_role_id),
      decode(x_comp_plan_id,
	     fnd_api.g_miss_num, oldrow.comp_plan_id,
	     x_comp_plan_id),
      decode(x_start_date,
	     fnd_api.g_miss_date, oldrow.start_date,
	     x_start_date),
      decode(x_end_date,
	     fnd_api.g_miss_date, oldrow.end_date,
	     x_end_date),
      decode(x_attribute_category,
	     fnd_api.g_miss_char, oldrow.attribute_category,
	     x_attribute_category),
      decode(x_attribute1,
	     fnd_api.g_miss_char, oldrow.attribute1,
	     x_attribute1),
      decode(x_attribute2,
	     fnd_api.g_miss_char, oldrow.attribute2,
	     x_attribute2),
      decode(x_attribute3,
	     fnd_api.g_miss_char, oldrow.attribute3,
	     x_attribute3),
      decode(x_attribute4,
	     fnd_api.g_miss_char, oldrow.attribute4,
	     x_attribute4),
      decode(x_attribute5,
	     fnd_api.g_miss_char, oldrow.attribute5,
	     x_attribute5),
      decode(x_attribute6,
	     fnd_api.g_miss_char, oldrow.attribute6,
	     x_attribute6),
      decode(x_attribute7,
	     fnd_api.g_miss_char, oldrow.attribute7,
	     x_attribute7),
      decode(x_attribute8,
	     fnd_api.g_miss_char, oldrow.attribute8,
	     x_attribute8),
      decode(x_attribute9,
	     fnd_api.g_miss_char, oldrow.attribute9,
	     x_attribute9),
      decode(x_attribute10,
	     fnd_api.g_miss_char, oldrow.attribute10,
	     x_attribute10),
      decode(x_attribute11,
	     fnd_api.g_miss_char, oldrow.attribute11,
	     x_attribute11),
      decode(x_attribute12,
	     fnd_api.g_miss_char, oldrow.attribute12,
	     x_attribute12),
      decode(x_attribute13,
	     fnd_api.g_miss_char, oldrow.attribute13,
	     x_attribute13),
      decode(x_attribute14,
	     fnd_api.g_miss_char, oldrow.attribute14,
	     x_attribute14),
      decode(x_attribute15,
	     fnd_api.g_miss_char, oldrow.attribute15,
	     x_attribute15)
      INTO
      l_srp_role_id,
      l_role_plan_id,
      l_salesrep_id,
      l_role_id,
      l_comp_plan_id,
      l_start_date,
      l_end_date,
      l_attribute_category,
      l_attribute1,
      l_attribute2,
      l_attribute3,
      l_attribute4,
      l_attribute5,
      l_attribute6,
      l_attribute7,
      l_attribute8,
      l_attribute9,
      l_attribute10,
      l_attribute11,
      l_attribute12,
      l_attribute13,
      l_attribute14,
      l_attribute15
      FROM dual;

   UPDATE CN_SRP_PLAN_ASSIGNS_ALL SET
     SRP_PLAN_ASSIGN_ID = x_srp_plan_assign_id ,
     SRP_ROLE_ID = l_srp_role_id ,
     ROLE_PLAN_ID = l_role_plan_id ,
     SALESREP_ID = l_salesrep_id ,
     ROLE_ID = l_role_id ,
     COMP_PLAN_ID = l_comp_plan_id ,
     START_DATE = l_start_date ,
     END_DATE = l_end_date ,
     ATTRIBUTE_CATEGORY = l_attribute_category ,
     ATTRIBUTE1 = l_attribute1 ,
     ATTRIBUTE2 = l_attribute2 ,
     ATTRIBUTE3 = l_attribute3 ,
     ATTRIBUTE4 = l_attribute4 ,
     ATTRIBUTE5 = l_attribute5 ,
     ATTRIBUTE6 = l_attribute6 ,
     ATTRIBUTE7 = l_attribute7 ,
     ATTRIBUTE8 = l_attribute8 ,
     ATTRIBUTE9 = l_attribute9 ,
     ATTRIBUTE10 = l_attribute10 ,
     ATTRIBUTE11 = l_attribute11 ,
     ATTRIBUTE12 = l_attribute12 ,
     ATTRIBUTE13 = l_attribute13 ,
     ATTRIBUTE14 = l_attribute14 ,
     ATTRIBUTE15 = l_attribute15 ,
     LAST_UPDATE_DATE = x_last_update_date ,
     LAST_UPDATED_BY = x_last_updated_by ,
     LAST_UPDATE_LOGIN = x_last_update_login
     WHERE SRP_PLAN_ASSIGN_ID = x_srp_plan_assign_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   -- The periods have changed we need maintain the period dependent
   -- information. do not need to do srp_quotas and srp_rate_assigns
   IF (x_start_date <> oldrow.start_date) OR
     (Nvl(x_end_date,fnd_api.g_miss_date) <>
      Nvl(oldrow.end_date,fnd_api.g_miss_date)) THEN
      -- start_date remanin unchanged
      IF x_start_date = oldrow.start_date THEN
	 IF x_end_date IS NULL THEN
	    -- oldrow.end_date is not null,extend end_date
	    cn_srp_period_quotas_pkg.insert_record
	      (x_srp_plan_assign_id  => x_srp_plan_assign_id
	       ,x_quota_id	     => NULL
	       ,x_start_period_id    => NULL    -- obsolete
	       ,x_end_period_id      => NULL    -- obsolete
	       ,x_start_date         => next_period(oldrow.end_date,
						    oldrow.org_id)
	       ,x_end_date           => x_end_date );
	    cn_srp_per_quota_rc_pkg.insert_record
	      (x_srp_plan_assign_id  => x_srp_plan_assign_id
	       ,x_quota_id	     => NULL
	       ,x_revenue_class_id   => NULL
	       ,x_start_period_id    => NULL
	       ,x_end_period_id      => NULL
	       ,x_start_date         => next_period(oldrow.end_date,
						    oldrow.org_id)
	       ,x_end_date           => x_end_date);
	  ELSIF oldrow.end_date IS NULL THEN
	    -- x_end_date is not null,shorten end_date
	    cn_srp_period_quotas_pkg.delete_record
	      (  x_srp_plan_assign_id => x_srp_plan_assign_id
		 ,x_quota_id	       => NULL
		 ,x_start_period_id    => NULL    -- obsolete
		 ,x_end_period_id      => NULL    -- obsolete
		 ,x_start_date         => next_period(x_end_date,
						      oldrow.org_id)
		 ,x_end_date           => oldrow.end_date );
	    cn_srp_per_quota_rc_pkg.delete_record
	      (x_srp_plan_assign_id  => x_srp_plan_assign_id
	       ,x_quota_id	     => NULL
	       ,x_revenue_class_id   => NULL
	       ,x_start_period_id    => NULL
	       ,x_end_period_id      => NULL
	       ,x_start_date         => next_period(x_end_date,
						    oldrow.org_id)
	       ,x_end_date           => oldrow.end_date );
	  ELSIF x_end_date > oldrow.end_date THEN
	    -- extend end_date
	     SELECT MIN(start_date)
	    	INTO l_next_start_date
	    	FROM cn_acc_period_statuses_v
	       WHERE period_status IN ('F', 'O')
	       AND org_id = oldrow.org_id;

	   IF  x_end_date > l_next_start_date THEN

	      cn_srp_period_quotas_pkg.insert_record
	        (x_srp_plan_assign_id  => x_srp_plan_assign_id
	        ,x_quota_id	      => NULL
	        ,x_start_period_id    => NULL    -- obsolete
	        ,x_end_period_id      => NULL    -- obsolete
		 ,x_start_date         => next_period(oldrow.end_date,
						      oldrow.org_id)
	        ,x_end_date           => x_end_date );
	      cn_srp_per_quota_rc_pkg.insert_record
	        (x_srp_plan_assign_id  => x_srp_plan_assign_id
	        ,x_quota_id	     => NULL
	        ,x_revenue_class_id   => NULL
	        ,x_start_period_id    => NULL
	        ,x_end_period_id      => NULL
		 ,x_start_date         => next_period(oldrow.end_date,
						      oldrow.org_id)
	        ,x_end_date           => x_end_date);
	     END IF;
	  ELSE
	    -- shorten end_date
	    cn_srp_period_quotas_pkg.delete_record
	      (  x_srp_plan_assign_id => x_srp_plan_assign_id
		 ,x_quota_id	        => NULL
		 ,x_start_period_id    => NULL    -- obsolete
		 ,x_end_period_id      => NULL    -- obsolete
		 ,x_start_date         => next_period(x_end_date,
						      oldrow.org_id)
		 ,x_end_date           => oldrow.end_date );
	    cn_srp_per_quota_rc_pkg.delete_record
	      (x_srp_plan_assign_id  => x_srp_plan_assign_id
	       ,x_quota_id	     => NULL
	       ,x_revenue_class_id   => NULL
	       ,x_start_period_id    => NULL
	       ,x_end_period_id      => NULL
	       ,x_start_date         => next_period(x_end_date,
						    oldrow.org_id)
	       ,x_end_date           => oldrow.end_date );
	 END IF;
       ELSE
	 -- start_date changed, delete/add the whole set
	 -- Remove all assignments for this plan/salesrep

	 -- cascades to per_quota_rc
	 cn_srp_per_quota_rc_pkg.delete_record
	   (x_srp_plan_assign_id  => x_srp_plan_assign_id
	    ,x_quota_id	          => NULL
	    ,x_revenue_class_id   => NULL
	    ,x_start_period_id    => NULL
	    ,x_end_period_id      => NULL
	    ,x_start_date         => oldrow.start_date
	    ,x_end_date           => oldrow.end_date );
	 cn_srp_period_quotas_pkg.delete_record
	   (  x_srp_plan_assign_id => x_srp_plan_assign_id
	      ,x_quota_id	    => NULL
	      ,x_start_period_id    => NULL    -- obsolete
	      ,x_end_period_id      => NULL    -- obsolete
	      ,x_start_date         => oldrow.start_date
	      ,x_end_date           => oldrow.end_date );

	 cn_srp_period_quotas_pkg.insert_record
	   (x_srp_plan_assign_id  => x_srp_plan_assign_id
	    ,x_quota_id	          => NULL
	    ,x_start_period_id    => NULL    -- obsolete
	    ,x_end_period_id      => NULL    -- obsolete
	    ,x_start_date         => x_start_date
	    ,x_end_date           => x_end_date );
	 cn_srp_per_quota_rc_pkg.insert_record
	   (x_srp_plan_assign_id  => x_srp_plan_assign_id
	    ,x_quota_id	          => NULL
	    ,x_revenue_class_id   => NULL
	    ,x_start_period_id    => NULL
	    ,x_end_period_id      => NULL
	    ,x_start_date         => x_start_date
	    ,x_end_date           => x_end_date);
      END IF;
   END IF ;

END UPDATE_ROW;

-- -------------------------------------------------------------------------+
-- Procedure Name
--   DELETE_ROW
-- Purpose
--
-- History
--
-- -------------------------------------------------------------------------+
PROCEDURE DELETE_ROW  (X_SRP_PLAN_ASSIGN_ID IN NUMBER) IS
BEGIN

   -- delete child rec is called in API:CN_SRP_PLAN_ASSIGNS_PVT
   -- cn_srp_quota_assigns_pkg.delete_record

   DELETE FROM CN_SRP_PLAN_ASSIGNS_ALL
     WHERE SRP_PLAN_ASSIGN_ID = X_SRP_PLAN_ASSIGN_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END DELETE_ROW;

END CN_SRP_PLAN_ASSIGNS_PKG;

/
