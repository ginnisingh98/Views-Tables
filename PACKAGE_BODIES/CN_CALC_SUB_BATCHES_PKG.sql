--------------------------------------------------------
--  DDL for Package Body CN_CALC_SUB_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_SUB_BATCHES_PKG" AS
/* $Header: cnsbbatb.pls 120.2 2006/02/17 11:55:22 ymao noship $ */

G_LAST_UPDATE_DATE          DATE    := sysdate;
G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
G_CREATION_DATE             DATE    := sysdate;
G_CREATED_BY                NUMBER  := fnd_global.user_id;
G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
--
--
--
-- This Procedure is called to
-- 	1. Insert
-- 	2. Update
-- 	3. Delete
-- Records into Table cn_calc_submission_batches
--
--


Procedure Insert_row ( 	 p_calc_sub_batch_id      NUMBER,
			 p_name                   VARCHAR2,
			 p_start_date             DATE,
			 p_end_date               DATE,
			 p_intelligent_flag       VARCHAR2,
			 p_hierarchy_flag         VARCHAR2,
			 p_salesrep_option        VARCHAR2,
			 p_concurrent_flag        VARCHAR2,
			 p_log_name               VARCHAR2,
			 p_status                 VARCHAR2,
			 p_logical_batch_id       NUMBER,
			 p_calc_type              VARCHAR2,
			 p_interval_type_id       NUMBER,
             p_org_id                 NUMBER,
			 P_ATTRIBUTE_CATEGORY     VARCHAR2,
                         P_ATTRIBUTE1             VARCHAR2,
                         P_ATTRIBUTE2             VARCHAR2,
                         P_ATTRIBUTE3             VARCHAR2,
                         P_ATTRIBUTE4             VARCHAR2,
                         P_ATTRIBUTE5             VARCHAR2,
                         P_ATTRIBUTE6             VARCHAR2,
                         P_ATTRIBUTE7             VARCHAR2,
                         P_ATTRIBUTE8             VARCHAR2,
                         P_ATTRIBUTE9             VARCHAR2,
                         P_ATTRIBUTE10            VARCHAR2,
                         P_ATTRIBUTE11            VARCHAR2,
                         P_ATTRIBUTE12            VARCHAR2,
                         P_ATTRIBUTE13            VARCHAR2,
                         P_ATTRIBUTE14            VARCHAR2,
                         P_ATTRIBUTE15            VARCHAR2,
                         P_CREATED_BY             NUMBER  ,
                         P_CREATION_DATE          DATE    ,
                         P_LAST_UPDATE_LOGIN      NUMBER  ,
                         P_LAST_UPDATE_DATE       DATE    ,
                         P_LAST_UPDATED_BY        NUMBER
                        ) IS
   l_calc_sub_batch_id NUMBER(15);
BEGIN

   IF p_calc_sub_batch_id IS NOT NULL THEN
      l_calc_sub_batch_id := p_calc_sub_batch_id;
    ELSE
      SELECT cn_calc_submission_batches_s1.NEXTVAL
	INTO l_calc_sub_batch_id
	FROM dual;
   END IF;

   INSERT INTO cn_calc_submission_batches_all
               (    calc_sub_batch_id,
		    name,
		    start_date,
		    end_date,
		    intelligent_flag,
		    hierarchy_flag,
		    salesrep_option,
		    concurrent_flag,
		    log_name,
		    status,
		    logical_batch_id,
		    calc_type,
		    interval_type_id,
            org_id
		    ,attribute_category
		    ,attribute1
		    ,attribute2
		    ,attribute3
		    ,attribute4
		    ,attribute5
		    ,attribute6
		    ,attribute7
		    ,attribute8
		    ,attribute9
		    ,attribute10
		    ,attribute11
		    ,attribute12
		    ,attribute13
		    ,attribute14
		    ,attribute15
		    ,created_by
		    ,creation_date
		    ,last_update_login
		    ,last_update_date
		    ,last_updated_by
		   )
     VALUES    (    l_calc_sub_batch_id,
		    p_name,
		    p_start_date,
	            p_end_date,
		    p_intelligent_flag,
		    p_hierarchy_flag,
		    p_salesrep_option,
		    p_concurrent_flag,
		    p_log_name,
		    p_status,
		    p_logical_batch_id,
		    p_calc_type,
		    p_interval_type_id,
            p_org_id
		    ,p_attribute_category
		    ,p_attribute1
		    ,p_attribute2
		    ,p_attribute3
		    ,p_attribute4
		    ,p_attribute5
		    ,p_attribute6
		    ,p_attribute7
		    ,p_attribute8
		    ,p_attribute9
		    ,p_attribute10
		    ,p_attribute11
		    ,p_attribute12
		    ,p_attribute13
		    ,p_attribute14
		    ,p_attribute15
		    ,Nvl( p_created_by,g_created_by)
		    ,Nvl( p_creation_date,g_creation_date )
		    ,Nvl( p_last_update_login, g_last_update_login )
		    ,Nvl( p_last_update_date, g_last_update_date )
		    ,Nvl( p_last_updated_by, g_last_updated_by  )
		    ) ;


END insert_row;


Procedure Update_row ( 	 p_calc_sub_batch_id      NUMBER,
			 p_name                   VARCHAR2,
			 p_start_date             DATE,
			 p_end_date               DATE,
			 p_intelligent_flag       VARCHAR2,
			 p_hierarchy_flag         VARCHAR2,
			 p_salesrep_option        VARCHAR2,
			 p_concurrent_flag        VARCHAR2,
			 p_log_name               VARCHAR2,
			 p_status                 VARCHAR2,
			 p_logical_batch_id       NUMBER,
			 p_calc_type              VARCHAR2,
			 p_interval_type_id       NUMBER,
                         P_ATTRIBUTE_CATEGORY     VARCHAR2,
                         P_ATTRIBUTE1             VARCHAR2,
                         P_ATTRIBUTE2             VARCHAR2,
                         P_ATTRIBUTE3             VARCHAR2,
                         P_ATTRIBUTE4             VARCHAR2,
                         P_ATTRIBUTE5             VARCHAR2,
                         P_ATTRIBUTE6             VARCHAR2,
                         P_ATTRIBUTE7             VARCHAR2,
                         P_ATTRIBUTE8             VARCHAR2,
                         P_ATTRIBUTE9             VARCHAR2,
                         P_ATTRIBUTE10            VARCHAR2,
                         P_ATTRIBUTE11            VARCHAR2,
                         P_ATTRIBUTE12            VARCHAR2,
                         P_ATTRIBUTE13            VARCHAR2,
                         P_ATTRIBUTE14            VARCHAR2,
                         P_ATTRIBUTE15            VARCHAR2,
                         P_CREATED_BY             NUMBER  ,
                         P_CREATION_DATE          DATE    ,
                         P_LAST_UPDATE_LOGIN      NUMBER  ,
                         P_LAST_UPDATE_DATE       DATE    ,
                         P_LAST_UPDATED_BY        NUMBER
                        ) IS

BEGIN

   UPDATE cn_calc_submission_batches_all SET
     calc_sub_batch_id = p_calc_sub_batch_id,
     name = p_name,
     start_date = p_start_date,
     end_date = p_end_date,
     intelligent_flag = p_intelligent_flag,
     hierarchy_flag  = p_hierarchy_flag,
     salesrep_option = p_salesrep_option ,
     concurrent_flag = p_concurrent_flag ,
     log_name = p_log_name,
     status = p_status ,
     logical_batch_id = p_logical_batch_id,
     calc_type = p_calc_type,
     interval_type_id = p_interval_type_id
     ,attribute_category = p_attribute_category
     ,attribute1 = p_attribute1
     ,attribute2 = p_attribute2
     ,attribute3 = p_attribute3
     ,attribute4 = p_attribute4
     ,attribute5 = p_attribute5
     ,attribute6 = p_attribute6
     ,attribute7 = p_attribute7
     ,attribute8 = p_attribute8
     ,attribute9 = p_attribute9
     ,attribute10 = p_attribute10
     ,attribute11 = p_attribute11
     ,attribute12 = p_attribute12
     ,attribute13 = p_attribute13
     ,attribute14 = p_attribute14
     ,attribute15 = p_attribute15
     ,created_by = Nvl( p_created_by,g_created_by)
     ,creation_date = Nvl( p_creation_date,g_creation_date )
     ,last_update_login = Nvl( p_last_update_login, g_last_update_login )
     ,last_update_date =  Nvl( p_last_update_date, g_last_update_date )
     ,last_updated_by = Nvl( p_last_updated_by, g_last_updated_by  )

   WHERE calc_sub_batch_id = p_calc_sub_batch_id;

END update_row;

Procedure delete_row ( 	 p_calc_sub_batch_id      NUMBER ) IS

BEGIN
   DELETE cn_calc_submission_batches_all
     WHERE calc_sub_batch_id = p_calc_sub_batch_id;

   IF  (sql%notfound) THEN
    raise no_data_found;
   END IF;

   DELETE cn_calc_submission_entries_all
       WHERE calc_sub_batch_id = p_calc_sub_batch_id;

   DELETE cn_calc_sub_quotas_all
     WHERE calc_sub_batch_id = p_calc_sub_batch_id;

END delete_row;

Procedure lock_row     ( p_calc_sub_batch_id      NUMBER,
			 p_name                   VARCHAR2,
			 p_start_date             DATE,
			 p_end_date               DATE,
			 p_intelligent_flag       VARCHAR2,
			 p_hierarchy_flag         VARCHAR2,
			 p_salesrep_option        VARCHAR2,
			 p_concurrent_flag        VARCHAR2,
			 p_log_name               VARCHAR2,
			 p_status                 VARCHAR2,
			 p_logical_batch_id       NUMBER,
			 p_calc_type              VARCHAR2,
			 p_interval_type_id       NUMBER,
                         P_ATTRIBUTE_CATEGORY     VARCHAR2,
                         P_ATTRIBUTE1             VARCHAR2,
                         P_ATTRIBUTE2             VARCHAR2,
                         P_ATTRIBUTE3             VARCHAR2,
                         P_ATTRIBUTE4             VARCHAR2,
                         P_ATTRIBUTE5             VARCHAR2,
                         P_ATTRIBUTE6             VARCHAR2,
                         P_ATTRIBUTE7             VARCHAR2,
                         P_ATTRIBUTE8             VARCHAR2,
                         P_ATTRIBUTE9             VARCHAR2,
                         P_ATTRIBUTE10            VARCHAR2,
                         P_ATTRIBUTE11            VARCHAR2,
                         P_ATTRIBUTE12            VARCHAR2,
                         P_ATTRIBUTE13            VARCHAR2,
                         P_ATTRIBUTE14            VARCHAR2,
                         P_ATTRIBUTE15            VARCHAR2,
                         P_CREATED_BY             NUMBER  ,
                         P_CREATION_DATE          DATE    ,
                         P_LAST_UPDATE_LOGIN      NUMBER  ,
                         P_LAST_UPDATE_DATE       DATE    ,
                         P_LAST_UPDATED_BY        NUMBER
  ) IS
     CURSOR C IS
	SELECT * FROM cn_calc_submission_batches_all
	  WHERE calc_sub_batch_id = p_calc_sub_batch_id
	  FOR UPDATE OF calc_sub_batch_id NOWAIT;

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

   IF  (	 recinfo.calc_sub_batch_id	      = p_calc_sub_batch_id
		 OR (    recinfo.calc_sub_batch_id IS NULL AND p_calc_sub_batch_id IS NULL)	)
	AND (	 recinfo.name   = p_name
		 OR ( recinfo.name IS NULL AND   p_name IS NULL) 	)
	AND (	 recinfo.start_date   = p_start_date
	     OR ( recinfo.start_date IS NULL AND
		  p_start_date IS NULL) 	)
	AND (	 recinfo.end_date   = p_end_date
	     OR ( recinfo.end_date IS NULL AND
		  p_end_date IS NULL) 	)
	AND (	 recinfo.intelligent_flag   = p_intelligent_flag
	     OR ( recinfo.intelligent_flag IS NULL AND
		  p_intelligent_flag IS NULL) 	)
	AND (	 recinfo.hierarchy_flag   = p_hierarchy_flag
	     OR ( recinfo.hierarchy_flag IS NULL AND
		  p_hierarchy_flag IS NULL) 	)
	AND (	 recinfo.salesrep_option   = p_salesrep_option
	     OR ( recinfo.salesrep_option IS NULL AND
		  p_salesrep_option IS NULL) 	)
	AND (	 recinfo.concurrent_flag   = p_concurrent_flag
	     OR ( recinfo.concurrent_flag IS NULL AND
		  p_concurrent_flag IS NULL) 	)
	AND (	 recinfo.log_name   = p_log_name
	     OR ( recinfo.log_name IS NULL AND
		  p_log_name IS NULL) 	)
	AND (	 recinfo.status   = p_status
	     OR ( recinfo.status IS NULL AND
		  p_status IS NULL) 	)
	AND (	 recinfo.logical_batch_id   = p_logical_batch_id
	     OR ( recinfo.logical_batch_id IS NULL AND
		  p_logical_batch_id IS NULL) 	)
	AND (	 recinfo.calc_type   = p_calc_type
	     OR ( recinfo.calc_type IS NULL AND p_calc_type IS NULL) 	)
	AND (	 recinfo.interval_type_id   = p_interval_type_id
	     OR ( recinfo.interval_type_id IS NULL AND
		  p_interval_type_id IS NULL) 	)
	AND (	 recinfo.attribute_category   = p_attribute_category
	     OR ( recinfo.attribute_category IS NULL AND
		  p_attribute_category IS NULL) 	)
	AND (	  recinfo.attribute1 = p_attribute1
	     OR ( recinfo.attribute1 IS NULL AND p_attribute1 IS NULL)	)
	AND (	  recinfo.attribute2 = p_attribute2
	     OR ( recinfo.attribute2 IS NULL AND p_attribute2 IS NULL)	)
	AND (	  recinfo.attribute3 = p_attribute3
	     OR ( recinfo.attribute3 IS NULL AND p_attribute3 IS NULL)	)

	AND (	  recinfo.attribute4 = p_attribute4
	     OR ( recinfo.attribute4 IS NULL AND p_attribute4 IS NULL)	)

	AND (	  recinfo.attribute5 = p_attribute5
	     OR ( recinfo.attribute5 IS NULL AND p_attribute5 IS NULL)	)

	AND (	  recinfo.attribute6 = p_attribute6
	     OR ( recinfo.attribute6 IS NULL AND p_attribute6 IS NULL)	)

	AND (	  recinfo.attribute7 = p_attribute7
	     OR ( recinfo.attribute7 IS NULL AND p_attribute7 IS NULL)	)

	AND (	  recinfo.attribute8 = p_attribute8
	     OR ( recinfo.attribute8 IS NULL AND p_attribute8 IS NULL)	)

	AND (	  recinfo.attribute9 = p_attribute9
	     OR ( recinfo.attribute9 IS NULL AND p_attribute9 IS NULL)	)

	AND (	  recinfo.attribute10 = p_attribute10
	     OR ( recinfo.attribute10 IS NULL AND p_attribute10 IS NULL) )

	AND (	  recinfo.attribute11 = p_attribute11
	     OR ( recinfo.attribute11 IS NULL AND p_attribute11 IS NULL) )

	AND (	  recinfo.attribute12 = p_attribute12
	     OR ( recinfo.attribute12 IS NULL AND p_attribute12 IS NULL) )

	AND (	  recinfo.attribute13 = p_attribute13
	     OR ( recinfo.attribute13 IS NULL AND p_attribute13 IS NULL) )

	AND (	  recinfo.attribute14 = p_attribute14
	     OR ( recinfo.attribute14 IS NULL AND p_attribute14 IS NULL) )

	AND (	  recinfo.attribute15 = p_attribute15
		  OR ( recinfo.attribute15 IS NULL AND p_attribute15 IS NULL) )

   THEN
      RETURN;
   ELSE
      fnd_message.set_name('FND','FORM_RECORD_CHANGED');
      app_exception.raise_exception;
   END IF;

END lock_row;

--
Procedure Begin_Record ( P_OPERATION              VARCHAR2,
			 p_calc_sub_batch_id      NUMBER := NULL,
			 p_name                   VARCHAR2 := NULL,
			 p_start_date             DATE := NULL,
			 p_end_date               DATE := NULL,
			 p_intelligent_flag       VARCHAR2 := NULL,
			 p_hierarchy_flag         VARCHAR2 := NULL,
			 p_salesrep_option        VARCHAR2 := NULL,
			 p_concurrent_flag        VARCHAR2 := NULL,
			 p_status                 VARCHAR2 := NULL,
			 p_logical_batch_id       NUMBER := NULL,
			 p_calc_type              VARCHAR2 := NULL,
			 p_interval_type_id       NUMBER := NULL,
             p_org_id                 NUMBER,
			 p_log_name               VARCHAR2 := NULL,
                         P_ATTRIBUTE_CATEGORY     VARCHAR2 := NULL,
                         P_ATTRIBUTE1             VARCHAR2 := NULL,
                         P_ATTRIBUTE2             VARCHAR2 := NULL,
                         P_ATTRIBUTE3             VARCHAR2 := NULL,
                         P_ATTRIBUTE4             VARCHAR2 := NULL,
                         P_ATTRIBUTE5             VARCHAR2 := NULL,
                         P_ATTRIBUTE6             VARCHAR2 := NULL,
			 P_ATTRIBUTE7             VARCHAR2 := NULL,
                         P_ATTRIBUTE8             VARCHAR2 := NULL,
                         P_ATTRIBUTE9             VARCHAR2 := NULL,
                         P_ATTRIBUTE10            VARCHAR2 := NULL,
                         P_ATTRIBUTE11            VARCHAR2 := NULL,
                         P_ATTRIBUTE12            VARCHAR2 := NULL,
                         P_ATTRIBUTE13            VARCHAR2 := NULL,
                         P_ATTRIBUTE14            VARCHAR2 := NULL,
                         P_ATTRIBUTE15            VARCHAR2 := NULL,
                         P_CREATED_BY             NUMBER   := NULL,
                         P_CREATION_DATE          DATE     := NULL,
                         P_LAST_UPDATE_LOGIN      NUMBER   := NULL,
                         P_LAST_UPDATE_DATE       DATE     := NULL,
                         P_LAST_UPDATED_BY        NUMBER   := NULL
    ) IS
BEGIN
   IF p_operation = 'INSERT' THEN
      insert_row (  p_calc_sub_batch_id,
		    p_name,
		    p_start_date,
		    p_end_date,
		    p_intelligent_flag,
		    p_hierarchy_flag,
		    p_salesrep_option,
		    p_concurrent_flag,
		    p_log_name,
		    p_status,
		    p_logical_batch_id,
		    p_calc_type,
		    p_interval_type_id,
            p_org_id
		    ,p_attribute_category
		    ,p_attribute1
		    ,p_attribute2
		    ,p_attribute3
		    ,p_attribute4
		    ,p_attribute5
		    ,p_attribute6
		    ,p_attribute7
		    ,p_attribute8
		    ,p_attribute9
		    ,p_attribute10
		    ,p_attribute11
		    ,p_attribute12
		    ,p_attribute13
		    ,p_attribute14
		    ,p_attribute15
		    ,p_created_by
		    ,p_creation_date
		    ,p_last_update_login
		    ,p_last_update_date
		    ,p_last_updated_by   ) ;
    ELSIF p_operation = 'UPDATE' THEN
      update_row (  p_calc_sub_batch_id,
		    p_name,
		    p_start_date,
		    p_end_date,
		    p_intelligent_flag,
		    p_hierarchy_flag,
		    p_salesrep_option,
		    p_concurrent_flag,
		    p_log_name,
		    p_status,
		    p_logical_batch_id,
		    p_calc_type,
		    p_interval_type_id
		    ,p_attribute_category
		    ,p_attribute1
		    ,p_attribute2
		    ,p_attribute3
		    ,p_attribute4
		    ,p_attribute5
		    ,p_attribute6
		    ,p_attribute7
		    ,p_attribute8
		    ,p_attribute9
		    ,p_attribute10
		    ,p_attribute11
		    ,p_attribute12
		    ,p_attribute13
		    ,p_attribute14
		    ,p_attribute15
		    ,p_created_by
		    ,p_creation_date
		    ,p_last_update_login
		    ,p_last_update_date
		    ,p_last_updated_by  ) ;
    ELSIF p_operation = 'DELETE' THEN
      delete_row (  p_calc_sub_batch_id );
    ELSIF p_operation = 'LOCK' THEN
      lock_row   (  p_calc_sub_batch_id,
		    p_name,
		    p_start_date,
		    p_end_date,
		    p_intelligent_flag,
		    p_hierarchy_flag,
		    p_salesrep_option,
		    p_concurrent_flag,
		    p_log_name,
		    p_status,
		    p_logical_batch_id,
		    p_calc_type,
		    p_interval_type_id
		    ,p_attribute_category
		    ,p_attribute1
		    ,p_attribute2
		    ,p_attribute3
		    ,p_attribute4
		    ,p_attribute5
		    ,p_attribute6
		    ,p_attribute7
		    ,p_attribute8
		    ,p_attribute9
		    ,p_attribute10
		    ,p_attribute11
		    ,p_attribute12
		    ,p_attribute13
		    ,p_attribute14
		    ,p_attribute15
		    ,p_created_by
		    ,p_creation_date
		    ,p_last_update_login
		    ,p_last_update_date
		    ,p_last_updated_by  );
   END IF;

END begin_record;

  --+
  -- Procedure Name
  --   get_calc_sub_batch
  -- Scope
  --    public
  -- Purpose
  --   get the calc_submission for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
PROCEDURE get_calc_sub_batch ( p_physical_batch_id  NUMBER,
			       x_calc_sub_batch_rec OUT NOCOPY calc_sub_batch_rec_type ) IS

BEGIN
   SELECT  calc_sub_batch_id,
     name,
     intelligent_flag,
     hierarchy_flag,
     salesrep_option,
     logical_batch_id,
     start_date,
     end_date,
     calc_type,
     interval_type_id
     INTO
     x_calc_sub_batch_rec.calc_sub_batch_id,
     x_calc_sub_batch_rec.name,
     x_calc_sub_batch_rec.intelligent_flag,
     x_calc_sub_batch_rec.hierarchy_flag,
     x_calc_sub_batch_rec.salesrep_option,
     x_calc_sub_batch_rec.logical_batch_id,
     x_calc_sub_batch_rec.start_date,
     x_calc_sub_batch_rec.end_date,
     x_calc_sub_batch_rec.calc_type,
     x_calc_sub_batch_rec.interval_type_id
     FROM cn_calc_submission_batches_all csb
     WHERE csb.logical_batch_id = (SELECT pb.logical_batch_id
	FROM cn_process_batches_all pb
	WHERE pb.physical_batch_id = p_physical_batch_id
      AND rownum = 1);

END get_calc_sub_batch;
  --+
  -- Procedure Name
  --   get_intel_calc_flag
  -- Scope
  --   Local to cn_calc_sub_batches_pkg
  -- Purpose
  --   get the intelligent_flag for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  FUNCTION  get_intel_calc_flag (p_calc_batch_id NUMBER) RETURN VARCHAR2  IS
     x_return VARCHAR2(1);
  BEGIN
     select intelligent_flag
       into x_return
       from cn_calc_submission_batches_all csb
      where csb.logical_batch_id = (select logical_batch_id
                                      from cn_process_batches_all pb
                                     where pb.physical_batch_id = p_calc_batch_id
                                       and rownum = 1);

    RETURN x_return;

  END get_intel_calc_flag;

  --+
  -- Procedure Name
  --   get_forecast_flag
  -- Scope
  --   Local to cn_calc_sub_batches_pkg
  -- Purpose
  --   get the intelligent_flag for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+

  FUNCTION  get_forecast_flag (p_calc_batch_id NUMBER) RETURN VARCHAR2  IS
     x_return VARCHAR2(1);
     l_calc_type VARCHAR2(30);
  BEGIN
     select calc_type
       into l_calc_type
       from cn_calc_submission_batches_all csb
      where csb.logical_batch_id = (select logical_batch_id
                                      from cn_process_batches_all pb
                                     where pb.physical_batch_id = p_calc_batch_id
                                       and rownum = 1);

     IF l_calc_type = 'FORECAST' THEN
	x_return := 'Y';
      ELSE
	x_return := 'N';
     END IF;

    RETURN x_return;

  END get_forecast_flag;

  --+
  -- Procedure Name
  --   get_calc_type
  -- Scope
  --   Local to cn_calc_sub_batches_pkg
  -- Purpose
  --   get the calculation type for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+

  FUNCTION  get_calc_type (p_calc_batch_id NUMBER) RETURN VARCHAR2  IS
     x_return VARCHAR2(30);
  BEGIN
     select calc_type
       into x_return
       from cn_calc_submission_batches_all csb
      where csb.logical_batch_id = (select logical_batch_id
                                      from cn_process_batches_all pb
                                     where pb.physical_batch_id = p_calc_batch_id
                                       and rownum = 1);

    RETURN x_return;

  END get_calc_type;

  --+
  -- Procedure Name
  --   get_salesrep_option
  -- Scope
  --   Local to cn_calc_sub_batches_pkg
  -- Purpose
  --   get the calculation type for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+

  FUNCTION  get_salesrep_option (p_calc_batch_id NUMBER) RETURN VARCHAR2  IS
     x_return VARCHAR2(30);
  BEGIN
     select salesrep_option
       into x_return
       from cn_calc_submission_batches_all csb
      where csb.logical_batch_id = (select logical_batch_id
                                      from cn_process_batches_all pb
                                     where pb.physical_batch_id = p_calc_batch_id
                                       and rownum = 1);

    RETURN x_return;

  END get_salesrep_option;

  --+
  -- Procedure Name
  --   get_concurrent_flag
  -- Scope
  --   public
  -- Purpose
  --   get the concurrent flag for the calc_submission batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  FUNCTION  get_concurrent_flag (p_calc_sub_batch_id NUMBER) RETURN VARCHAR2 IS
     l_concurrent_flag   VARCHAR2(1);
  BEGIN
     SELECT concurrent_flag
       INTO l_concurrent_flag
       FROM cn_calc_submission_batches_all
       WHERE calc_sub_batch_id = p_calc_sub_batch_id;

     RETURN l_concurrent_flag;
  END get_concurrent_flag;

  --+
  -- Procedure Name
  --  get_calc_sub_batch_id
  -- Scope
  --   public
  -- Purpose
  --   get the calculation type for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  FUNCTION get_calc_sub_batch_id  RETURN NUMBER IS
     l_calc_sub_batch_id NUMBER(15);
  BEGIN
     SELECT cn_calc_submission_batches_s1.nextval
       INTO  l_calc_sub_batch_id
       FROM  sys.dual;

     RETURN l_calc_sub_batch_id;
  END get_calc_sub_batch_id;

  --+
  -- Procedure Name
  --  delete_calc_sub_batch
  -- Scope
  --   public
  -- Purpose
  --   delete a calc submission batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  PROCEDURE delete_calc_sub_batch (p_calc_sub_batch_id NUMBER) IS
  BEGIN
     DELETE cn_calc_submission_entries_all
       WHERE calc_sub_batch_id = p_calc_sub_batch_id;

     DELETE cn_calc_sub_quotas_all
       WHERE calc_sub_batch_id = p_calc_sub_batch_id;

  END delete_calc_sub_batch;


  --+
  -- Procedure Name
  --  update_calc_sub_batch
  -- Scope
  --   public
  -- Purpose
  --   update status of a calc submission batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  PROCEDURE update_calc_sub_batch (p_logical_batch_id NUMBER,
				   p_status	     VARCHAR2) IS
    l_salesrep_option varchar2(30);
    l_from_period_id	number(15);
    l_to_period_id	number(15);
    l_start_date      DATE;
    l_end_date        DATE;

    l_intel_flag    VARCHAR2(1);
    l_calc_type     VARCHAR2(30);
    l_org_id        number;

  BEGIN
     UPDATE cn_calc_submission_batches_all
       SET status = p_status
       WHERE logical_batch_id = p_logical_batch_id;

     IF p_status = 'COMPLETE' THEN
	SELECT salesrep_option, intelligent_flag, calc_type,
	  start_date, end_date, org_id
	  INTO l_salesrep_option, l_intel_flag, l_calc_type,
	  l_start_date, l_end_date, l_org_id
	  FROM cn_calc_submission_batches_all
	  WHERE logical_batch_id = p_logical_batch_id;

	IF l_calc_type = 'COMMISSION' THEN
	   IF l_salesrep_option = 'ALL_REPS'
	     OR l_salesrep_option = 'REPS_IN_NOTIFY_LOG' THEN

	      l_from_period_id := cn_api.get_acc_period_id( l_start_date, l_org_id);
	      l_to_period_id   := cn_api.get_acc_period_id( l_end_date, l_org_id);

	      UPDATE  cn_notify_log_all
		SET  status = 'COMPLETE'
		WHERE status 	= 'INCOMPLETE'
        AND org_id = l_org_id
		AND period_id between l_from_period_id and l_to_period_id
		AND ( l_intel_flag = 'Y'
		      OR (l_intel_flag = 'N' AND start_date >= l_start_date ) );
	   END IF;
	END IF;
     END IF;
  END update_calc_sub_batch;
--
--
--
END cn_calc_sub_batches_pkg;

/
