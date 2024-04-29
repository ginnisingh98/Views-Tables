--------------------------------------------------------
--  DDL for Package Body CN_ROLE_PMT_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ROLE_PMT_PLANS_PKG" AS
/* $Header: cntrptpb.pls 120.2 2005/07/15 02:45:01 raramasa noship $ */

G_LAST_UPDATE_DATE          DATE    := sysdate;
G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
G_CREATION_DATE             DATE    := sysdate;
G_CREATED_BY                NUMBER  := fnd_global.user_id;
G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;


procedure INSERT_ROW
  (X_ORG_ID				  IN NUMBER,
   X_ROLE_PMT_PLAN_ID          	          IN NUMBER,  -- required
   X_ROLE_ID	       	                  IN NUMBER,  -- required
   X_PMT_PLAN_ID	       	          IN NUMBER,  -- required
   X_START_DATE                           IN DATE,    -- required
   X_END_DATE                             IN DATE,
   X_ATTRIBUTE_CATEGORY	         	  IN VARCHAR2,
   X_ATTRIBUTE1		        	  IN VARCHAR2,
   X_ATTRIBUTE2		        	  IN VARCHAR2,
   X_ATTRIBUTE3		        	  IN VARCHAR2,
   X_ATTRIBUTE4		        	  IN VARCHAR2,
   X_ATTRIBUTE5		        	  IN VARCHAR2,
   X_ATTRIBUTE6		        	  IN VARCHAR2,
   X_ATTRIBUTE7		        	  IN VARCHAR2,
   X_ATTRIBUTE8		        	  IN VARCHAR2,
   X_ATTRIBUTE9		        	  IN VARCHAR2,
   X_ATTRIBUTE10		       	  IN VARCHAR2,
   X_ATTRIBUTE11		       	  IN VARCHAR2,
   X_ATTRIBUTE12		       	  IN VARCHAR2,
   X_ATTRIBUTE13		       	  IN VARCHAR2,
  X_ATTRIBUTE14		        	  IN VARCHAR2,
  X_ATTRIBUTE15	       	  	          IN VARCHAR2,
  X_CREATED_BY	        		  IN NUMBER,
  X_CREATION_DATE		       	  IN DATE,
  X_LAST_UPDATE_LOGIN	        	  IN NUMBER,
  X_LAST_UPDATE_DATE 	        	  IN DATE,
  X_LAST_UPDATED_BY			  IN NUMBER) IS


    L_END_DATE 				  cn_role_pmt_plans.END_DATE%type;
    L_ATTRIBUTE_CATEGORY	       	  cn_role_pmt_plans.ATTRIBUTE_CATEGORY%type;
    L_ATTRIBUTE1		       	  cn_role_pmt_plans.ATTRIBUTE1%type;
    L_ATTRIBUTE2		       	  cn_role_pmt_plans.ATTRIBUTE2%type;
    L_ATTRIBUTE3		       	  cn_role_pmt_plans.ATTRIBUTE3%type;
    L_ATTRIBUTE4		       	  cn_role_pmt_plans.ATTRIBUTE4%type;
    L_ATTRIBUTE5		       	  cn_role_pmt_plans.ATTRIBUTE5%type;
    L_ATTRIBUTE6		       	  cn_role_pmt_plans.ATTRIBUTE6%type;
    L_ATTRIBUTE7		       	  cn_role_pmt_plans.ATTRIBUTE7%type;
    L_ATTRIBUTE8		       	  cn_role_pmt_plans.ATTRIBUTE8%type;
    L_ATTRIBUTE9		       	  cn_role_pmt_plans.ATTRIBUTE9%type;
    L_ATTRIBUTE10		       	  cn_role_pmt_plans.ATTRIBUTE10%type;
    L_ATTRIBUTE11		       	  cn_role_pmt_plans.ATTRIBUTE11%type;
    L_ATTRIBUTE12		       	  cn_role_pmt_plans.ATTRIBUTE12%type;
    L_ATTRIBUTE13		       	  cn_role_pmt_plans.ATTRIBUTE13%type;
    L_ATTRIBUTE14		       	  cn_role_pmt_plans.ATTRIBUTE14%type;
    L_ATTRIBUTE15	       		  cn_role_pmt_plans.ATTRIBUTE15%type;
    L_CREATED_BY	       		  cn_role_pmt_plans.CREATED_BY%type;
    L_CREATION_DATE		       	  cn_role_pmt_plans.CREATION_DATE%type;
    L_LAST_UPDATE_LOGIN	       	          cn_role_pmt_plans.LAST_UPDATE_LOGIN%type;
    L_LAST_UPDATE_DATE		          cn_role_pmt_plans.LAST_UPDATE_DATE%type;
    L_LAST_UPDATED_BY			  cn_role_pmt_plans.LAST_UPDATED_BY%type;


BEGIN
--   dbms_output.put_line('begin insert_row');

	SELECT DECODE(X_end_date, FND_API.G_MISS_DATE,
		      to_date(NULL),X_end_date)
	  INTO L_end_date FROM dual;
	SELECT DECODE(X_attribute_category, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_attribute_category)))
	  INTO L_attribute_category FROM dual;
	SELECT DECODE(X_ATTRIBUTE1, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE1)))
	  INTO L_ATTRIBUTE1 FROM dual;
	SELECT DECODE(X_ATTRIBUTE2, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE2)))
	  INTO L_ATTRIBUTE2 FROM dual;
	SELECT DECODE(X_ATTRIBUTE3, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE3)))
	  INTO L_ATTRIBUTE3 FROM dual;
	SELECT DECODE(X_ATTRIBUTE4, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE4)))
	  INTO L_ATTRIBUTE4 FROM dual;
	SELECT DECODE(X_ATTRIBUTE5, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE5)))
	  INTO L_ATTRIBUTE5 FROM dual;
	SELECT DECODE(X_ATTRIBUTE6, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE6)))
	  INTO L_ATTRIBUTE6 FROM dual;
	SELECT DECODE(X_ATTRIBUTE7, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE7)))
	  INTO L_ATTRIBUTE7 FROM dual;
	SELECT DECODE(X_ATTRIBUTE8, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE8)))
	  INTO L_ATTRIBUTE8 FROM dual;
	SELECT DECODE(X_ATTRIBUTE9, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE9)))
	  INTO L_ATTRIBUTE9 FROM dual;
	SELECT DECODE(X_ATTRIBUTE10, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE10)))
	  INTO L_ATTRIBUTE10 FROM dual;
	SELECT DECODE(X_ATTRIBUTE11, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE11)))
	  INTO L_ATTRIBUTE11 FROM dual;
	SELECT DECODE(X_ATTRIBUTE12, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE12)))
	  INTO L_ATTRIBUTE12 FROM dual;
	SELECT DECODE(X_ATTRIBUTE13, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE13)))
	  INTO L_ATTRIBUTE13 FROM dual;
	SELECT DECODE(X_ATTRIBUTE14, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_ATTRIBUTE14)))
	  INTO L_ATTRIBUTE14 FROM dual;
	SELECT DECODE(X_attribute15, FND_API.G_MISS_CHAR,
		      NULL,Ltrim(Rtrim(X_attribute15)))
	  INTO L_attribute15 FROM dual;
	SELECT DECODE(X_created_by, FND_API.G_MISS_NUM,
		      G_CREATED_BY,Ltrim(Rtrim(X_CREATED_BY)))
	  INTO L_created_by FROM dual;
	SELECT DECODE(X_creation_date, FND_API.G_MISS_DATE,
		      G_CREATION_DATE,X_CREATION_DATE)
	  INTO L_creation_date FROM dual;
	SELECT DECODE(X_last_update_login, FND_API.G_MISS_NUM,
		      G_LAST_UPDATE_LOGIN,Ltrim(Rtrim(X_LAST_UPDATE_LOGIN)))
	  INTO L_last_update_login FROM dual;
	SELECT DECODE(X_last_update_date, FND_API.G_MISS_DATE,
		      G_LAST_UPDATE_DATE,X_LAST_UPDATE_DATE)
	  INTO L_last_update_date FROM dual;
	SELECT DECODE(X_last_updated_by, FND_API.G_MISS_NUM,
		      G_LAST_UPDATED_BY,Ltrim(Rtrim(X_LAST_UPDATED_BY)))
	  INTO L_last_updated_by FROM dual;

	-- dbms_output.put_line('before insert_row');

	INSERT INTO cn_role_pmt_plans (
			 ROLE_PMT_PLAN_ID,
			 ROLE_ID,
			 PMT_PLAN_ID,
			 START_DATE,
			 END_DATE,
			 ORG_ID,
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
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATE_LOGIN,
			 LAST_UPDATE_DATE,
			 LAST_UPDATED_BY)
                  VALUES (
			 X_ROLE_PMT_PLAN_ID,
			 X_ROLE_ID,
			 X_PMT_PLAN_ID,
			 X_START_DATE,
			 L_END_DATE,
			 X_ORG_ID,
			 L_ATTRIBUTE_CATEGORY,
			 L_ATTRIBUTE1,
			 L_ATTRIBUTE2,
			 L_ATTRIBUTE3,
			 L_ATTRIBUTE4,
			 L_ATTRIBUTE5,
			 L_ATTRIBUTE6,
			 L_ATTRIBUTE7,
			 L_ATTRIBUTE8,
			 L_ATTRIBUTE9,
			 L_ATTRIBUTE10,
			 L_ATTRIBUTE11,
			 L_ATTRIBUTE12,
			 L_ATTRIBUTE13,
			 L_ATTRIBUTE14,
			 L_ATTRIBUTE15,
			 L_CREATED_BY,
			 L_CREATION_DATE,
			 L_LAST_UPDATE_LOGIN,
			 L_LAST_UPDATE_DATE,
		         L_LAST_UPDATED_BY);

	-- dbms_output.put_line('after insert_row');
/*
  open c;
  fetch c into X_ROWID;
  if (c%notfound) THEN
    dbms_output.put_line('fail insert');
    close c;
    raise no_data_found;
  end if;
  close c;

  dbms_output.put_line('leaving insert_row');
*/

END insert_row;


procedure UPDATE_ROW (
		      X_ORG_ID				  IN NUMBER,
		      X_ROLE_PMT_PLAN_ID	       	  IN NUMBER,  -- required
		      X_ROLE_ID	       	                  IN NUMBER,
		      X_PMT_PLAN_ID	       	          IN NUMBER,
		      X_START_DATE                        IN DATE,
		      X_END_DATE                          IN DATE,
		      X_ATTRIBUTE_CATEGORY	       	  IN VARCHAR2,
		      X_ATTRIBUTE1		       	  IN VARCHAR2,
		      X_ATTRIBUTE2		       	  IN VARCHAR2,
		      X_ATTRIBUTE3		       	  IN VARCHAR2,
		      X_ATTRIBUTE4		       	  IN VARCHAR2,
		      X_ATTRIBUTE5		       	  IN VARCHAR2,
		      X_ATTRIBUTE6		       	  IN VARCHAR2,
		      X_ATTRIBUTE7		       	  IN VARCHAR2,
		      X_ATTRIBUTE8		       	  IN VARCHAR2,
		      X_ATTRIBUTE9		       	  IN VARCHAR2,
		      X_ATTRIBUTE10		       	  IN VARCHAR2,
		      X_ATTRIBUTE11		       	  IN VARCHAR2,
		      X_ATTRIBUTE12		       	  IN VARCHAR2,
		      X_ATTRIBUTE13		       	  IN VARCHAR2,
		      X_ATTRIBUTE14		       	  IN VARCHAR2,
		      X_ATTRIBUTE15	       		  IN VARCHAR2,
		      X_CREATED_BY	       		  IN NUMBER,
		      X_CREATION_DATE		       	  IN DATE,
		      X_LAST_UPDATE_LOGIN	       	  IN NUMBER,
		      X_LAST_UPDATE_DATE		  IN DATE,
                      X_LAST_UPDATED_BY			  IN NUMBER,
                      X_OBJECT_VERSION_NUMBER             IN NUMBER ) IS

   CURSOR cur IS
     SELECT * FROM cn_role_pmt_plans
       WHERE role_pmt_plan_id = x_role_pmt_plan_id;

   rec cur%ROWTYPE;

BEGIN
   OPEN cur;
   FETCH cur INTO rec;

   IF (cur%notfound) THEN
      CLOSE cur;
      RAISE no_data_found;
   ELSE
        IF (rec.object_version_number <> X_OBJECT_VERSION_NUMBER ) THEN
           fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_unexpected_error;
        END IF;

        SELECT DECODE(X_role_id, FND_API.G_MISS_NUM,
		      rec.role_id,Ltrim(Rtrim(X_role_id)))
	  INTO rec.role_id FROM dual;
        SELECT DECODE(X_pmt_plan_id, FND_API.G_MISS_NUM,
		      rec.pmt_plan_id,Ltrim(Rtrim(X_pmt_plan_id)))
	  INTO rec.pmt_plan_id FROM dual;
        SELECT DECODE(X_start_date, FND_API.G_MISS_DATE,
		      rec.start_date,X_start_date)
	  INTO rec.start_date FROM dual;
        SELECT DECODE(X_end_date, FND_API.G_MISS_DATE,
		      rec.end_date,X_end_date)
	  INTO rec.end_date FROM dual;
	SELECT DECODE(X_attribute_category, FND_API.G_MISS_CHAR,
		      rec.attribute_category,Ltrim(Rtrim(X_attribute_category)))
	  INTO rec.attribute_category FROM dual;
	SELECT DECODE(X_ATTRIBUTE1, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE1,Ltrim(Rtrim(X_ATTRIBUTE1)))
	  INTO rec.ATTRIBUTE1 FROM dual;
	SELECT DECODE(X_ATTRIBUTE2, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE2,Ltrim(Rtrim(X_ATTRIBUTE2)))
	  INTO rec.ATTRIBUTE2 FROM dual;
	SELECT DECODE(X_ATTRIBUTE3, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE3,Ltrim(Rtrim(X_ATTRIBUTE3)))
	  INTO rec.ATTRIBUTE3 FROM dual;
	SELECT DECODE(X_ATTRIBUTE4, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE4,Ltrim(Rtrim(X_ATTRIBUTE4)))
	  INTO rec.ATTRIBUTE4 FROM dual;
	SELECT DECODE(X_ATTRIBUTE5, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE5,Ltrim(Rtrim(X_ATTRIBUTE5)))
	  INTO rec.ATTRIBUTE5 FROM dual;
	SELECT DECODE(X_ATTRIBUTE6, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE6,Ltrim(Rtrim(X_ATTRIBUTE6)))
	  INTO rec.ATTRIBUTE6 FROM dual;
	SELECT DECODE(X_ATTRIBUTE7, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE7,Ltrim(Rtrim(X_ATTRIBUTE7)))
	  INTO rec.ATTRIBUTE7 FROM dual;
	SELECT DECODE(X_ATTRIBUTE8, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE8,Ltrim(Rtrim(X_ATTRIBUTE8)))
	  INTO rec.ATTRIBUTE8 FROM dual;
	SELECT DECODE(X_ATTRIBUTE9, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE9,Ltrim(Rtrim(X_ATTRIBUTE9)))
	  INTO rec.ATTRIBUTE9 FROM dual;
	SELECT DECODE(X_ATTRIBUTE10, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE10,Ltrim(Rtrim(X_ATTRIBUTE10)))
	  INTO rec.ATTRIBUTE10 FROM dual;
	SELECT DECODE(X_ATTRIBUTE11, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE11,Ltrim(Rtrim(X_ATTRIBUTE11)))
	  INTO rec.ATTRIBUTE11 FROM dual;
	SELECT DECODE(X_ATTRIBUTE12, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE12,Ltrim(Rtrim(X_ATTRIBUTE12)))
	  INTO rec.ATTRIBUTE12 FROM dual;
	SELECT DECODE(X_ATTRIBUTE13, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE13,Ltrim(Rtrim(X_ATTRIBUTE13)))
	  INTO rec.ATTRIBUTE13 FROM dual;
	SELECT DECODE(X_ATTRIBUTE14, FND_API.G_MISS_CHAR,
		      rec.ATTRIBUTE14,Ltrim(Rtrim(X_ATTRIBUTE14)))
	  INTO rec.ATTRIBUTE14 FROM dual;
	SELECT DECODE(X_attribute15, FND_API.G_MISS_CHAR,
		      rec.attribute15,Ltrim(Rtrim(X_attribute15)))
	  INTO rec.attribute15 FROM dual;
	SELECT DECODE(X_created_by, FND_API.G_MISS_NUM,
		      G_CREATED_BY,Ltrim(Rtrim(X_created_by)))
	  INTO rec.created_by FROM dual;
	SELECT DECODE(X_creation_date, FND_API.G_MISS_DATE,
		      G_CREATION_DATE,X_creation_date)
	  INTO rec.creation_date FROM dual;
	SELECT DECODE(X_last_update_login, FND_API.G_MISS_NUM,
		      G_LAST_UPDATE_LOGIN,Ltrim(Rtrim(X_last_update_login)))
	  INTO rec.last_update_login FROM dual;
	SELECT DECODE(X_last_update_date, FND_API.G_MISS_DATE,
		      G_LAST_UPDATE_DATE,X_last_update_date)
	  INTO rec.last_update_date FROM dual;
	SELECT DECODE(X_last_updated_by, FND_API.G_MISS_NUM,
		      G_LAST_UPDATED_BY,Ltrim(Rtrim(X_last_updated_by)))
	  INTO rec.last_updated_by FROM dual;

	UPDATE cn_role_pmt_plans SET
	  role_id      = rec.role_id,
	  pmt_plan_id = rec.pmt_plan_id,
	  start_date   = rec.start_date,
	  end_date     = rec.end_date,
	  org_id = rec.org_id,
	  ATTRIBUTE_CATEGORY = rec.ATTRIBUTE_CATEGORY,
	  ATTRIBUTE1 = rec.ATTRIBUTE1,
	  ATTRIBUTE2 = rec.ATTRIBUTE2,
	  ATTRIBUTE3 = rec.ATTRIBUTE3,
	  ATTRIBUTE4 = rec.ATTRIBUTE4,
	  ATTRIBUTE5 = rec.ATTRIBUTE5,
	  ATTRIBUTE6 = rec.ATTRIBUTE6,
	  ATTRIBUTE7 = rec.ATTRIBUTE7,
	  ATTRIBUTE8 = rec.ATTRIBUTE8,
	  ATTRIBUTE9 = rec.ATTRIBUTE9,
	  ATTRIBUTE10 = rec.ATTRIBUTE10,
	  ATTRIBUTE11 = rec.ATTRIBUTE11,
	  ATTRIBUTE12 = rec.ATTRIBUTE12,
	  ATTRIBUTE13 = rec.ATTRIBUTE13,
	  ATTRIBUTE14 = rec.ATTRIBUTE14,
	  ATTRIBUTE15 = rec.ATTRIBUTE15,
	  CREATED_BY = rec.CREATED_BY,
	  CREATION_DATE = rec.CREATION_DATE,
	  LAST_UPDATE_LOGIN = rec.LAST_UPDATE_LOGIN,
	  LAST_UPDATE_DATE = rec.LAST_UPDATE_DATE,
	  LAST_UPDATED_BY = rec.LAST_UPDATED_BY,
          OBJECT_VERSION_NUMBER = rec.OBJECT_VERSION_NUMBER +1
	WHERE role_pmt_plan_id =  rec.role_pmt_plan_id;

        IF (sql%notfound) THEN
           CLOSE cur;
           raise no_data_found;
        END IF;
   END IF;
   CLOSE cur;

END UPDATE_ROW;


procedure LOCK_ROW (X_ROLE_PMT_PLAN_ID	  IN NUMBER) IS
BEGIN
   NULL;
END lock_row;

procedure DELETE_ROW (X_ROLE_PMT_PLAN_ID	  IN NUMBER) IS
BEGIN
   DELETE FROM cn_role_pmt_plans
     WHERE role_pmt_plan_id = x_role_pmt_plan_id;
   IF  (sql%notfound) THEN
    raise no_data_found;
   END IF;
END delete_row;

END cn_role_pmt_plans_pkg;

/
