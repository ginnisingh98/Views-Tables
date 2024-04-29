--------------------------------------------------------
--  DDL for Package Body CN_CALC_SUB_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_SUB_ENTRIES_PKG" AS
/* $Header: cnsbbteb.pls 120.2 2005/08/08 09:56:30 ymao ship $ */

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
-- Records into Table cn_calc_submission_entries
--
--


Procedure Insert_row ( 	 p_calc_sub_entry_id      NUMBER,
			 p_calc_sub_batch_id      NUMBER,
			 p_salesrep_id            NUMBER,
			 p_hierarchy_flag         VARCHAR2,
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
   l_calc_sub_entry_id NUMBER(15);
BEGIN
   IF p_calc_sub_entry_id IS NOT NULL THEN
      l_calc_sub_entry_id := p_calc_sub_entry_id;
    ELSE
      SELECT cn_calc_submission_entries_s1.NEXTVAL
	INTO l_calc_sub_entry_id
	FROM dual;
   END IF;

   INSERT INTO cn_calc_submission_entries_all
     (              calc_sub_entry_id,
		    calc_sub_batch_id,
		    salesrep_id,
		    hierarchy_flag,
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
		    ,last_updated_by   )
     VALUES    (
		    l_calc_sub_entry_id,
		    p_calc_sub_batch_id,
		    p_salesrep_id,
		    nvl(p_hierarchy_flag, 'N'),
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
		    ,Nvl( p_last_updated_by, g_last_updated_by  )  ) ;


END insert_row;


Procedure Update_row ( 	 p_calc_sub_entry_id      NUMBER,
			 p_calc_sub_batch_id      NUMBER,
			 p_salesrep_id            NUMBER,
			 p_hierarchy_flag         VARCHAR2,
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

   UPDATE cn_calc_submission_entries_all SET
     calc_sub_entry_id = p_calc_sub_entry_id,
     calc_sub_batch_id = p_calc_sub_batch_id,
     salesrep_id = p_salesrep_id,
     hierarchy_flag = nvl(p_hierarchy_flag, 'N')
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

Procedure delete_row ( 	 p_calc_sub_entry_id      NUMBER ) IS

BEGIN
   DELETE cn_calc_submission_entries_all
     WHERE calc_sub_entry_id = p_calc_sub_entry_id;

   IF  (sql%notfound) THEN
    raise no_data_found;
   END IF;
END delete_row;

Procedure lock_row     ( p_calc_sub_entry_id      NUMBER,
			 p_calc_sub_batch_id      NUMBER,
			 p_salesrep_id            NUMBER,
			 p_hierarchy_flag         VARCHAR2,
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
	SELECT * FROM cn_calc_submission_entries_all
	  WHERE calc_sub_entry_id = p_calc_sub_entry_id
	  FOR UPDATE OF calc_sub_entry_id NOWAIT;

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
	AND (	 recinfo.CALC_SUB_ENTRY_ID   = p_CALC_SUB_ENTRY_ID
	     OR ( recinfo.CALC_SUB_ENTRY_ID IS NULL AND
		  p_CALC_SUB_ENTRY_ID IS NULL) 	)
	AND (	 recinfo.SALESREP_ID   = p_SALESREP_ID
	     OR ( recinfo.SALESREP_ID IS NULL AND
		  p_SALESREP_ID IS NULL) 	)
	AND (	 recinfo.HIERARCHY_FLAG   = p_HIERARCHY_FLAG
	     OR ( recinfo.HIERARCHY_FLAG IS NULL AND
		  p_HIERARCHY_FLAG IS NULL) 	)
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
			 p_calc_sub_entry_id      NUMBER := NULL,
			 p_calc_sub_batch_id      NUMBER := NULL,
			 p_salesrep_id            NUMBER := NULL,
			 p_hierarchy_flag         VARCHAR2 := NULL,
             p_org_id                 NUMBER,
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
      insert_row (  p_calc_sub_entry_id,
		    p_calc_sub_batch_id,
		    p_salesrep_id,
		    p_hierarchy_flag,
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
		    ,p_last_updated_by  ) ;
    ELSIF p_operation = 'UPDATE' THEN
      update_row (  p_calc_sub_entry_id,
		    p_calc_sub_batch_id,
		    p_salesrep_id,
		    p_hierarchy_flag
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
      delete_row (  p_calc_sub_entry_id );
    ELSIF p_operation = 'LOCK' THEN
      lock_row   (  p_calc_sub_entry_id,
		    p_calc_sub_batch_id,
		    p_salesrep_id,
		    p_hierarchy_flag
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
		    ,p_last_updated_by );
   END IF;

END begin_record;



--  --+
  -- Procedure Name
  --  get_calc_sub_entry_id
  -- Scope
  --   public
  -- Purpose
  --   get the calculation type for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  FUNCTION get_calc_sub_entry_id RETURN NUMBER IS
     l_calc_sub_entry_id NUMBER(15);
  BEGIN
     SELECT cn_calc_submission_entries_s1.nextval
      INTO l_calc_sub_entry_id
       FROM sys.dual;

     RETURN l_calc_sub_entry_id;
 END get_calc_sub_entry_id;

--
--
END cn_calc_sub_entries_pkg;

/
