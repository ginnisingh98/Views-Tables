--------------------------------------------------------
--  DDL for Package Body CN_ROLE_PAY_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ROLE_PAY_GROUPS_PKG" AS
/* $Header: cntrlpgb.pls 120.3 2005/07/26 02:39:02 sjustina noship $ */

G_LAST_UPDATE_DATE          DATE    := sysdate;
G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
G_CREATION_DATE             DATE    := sysdate;
G_CREATED_BY                NUMBER  := fnd_global.user_id;
G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;


procedure INSERT_ROW
  (X_ROWID      		          IN OUT NOCOPY VARCHAR2,  -- required
   X_ROLE_PAY_GROUP_ID            IN OUT NOCOPY NUMBER,  -- required
   X_ROLE_ID	       	                  IN NUMBER,  -- required
   X_PAY_GROUP_ID	       	          IN NUMBER,  -- required
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
  X_LAST_UPDATED_BY			  IN NUMBER,
  X_ORG_ID                    IN NUMBER,
  X_OBJECT_VERSION_NUMBER     OUT NOCOPY NUMBER
  ) IS


    L_END_DATE 				  cn_role_pay_groups.END_DATE%type;
    L_ATTRIBUTE_CATEGORY	       	  cn_role_pay_groups.ATTRIBUTE_CATEGORY%type;
    L_ATTRIBUTE1		       	  cn_role_pay_groups.ATTRIBUTE1%type;
    L_ATTRIBUTE2		       	  cn_role_pay_groups.ATTRIBUTE2%type;
    L_ATTRIBUTE3		       	  cn_role_pay_groups.ATTRIBUTE3%type;
    L_ATTRIBUTE4		       	  cn_role_pay_groups.ATTRIBUTE4%type;
    L_ATTRIBUTE5		       	  cn_role_pay_groups.ATTRIBUTE5%type;
    L_ATTRIBUTE6		       	  cn_role_pay_groups.ATTRIBUTE6%type;
    L_ATTRIBUTE7		       	  cn_role_pay_groups.ATTRIBUTE7%type;
    L_ATTRIBUTE8		       	  cn_role_pay_groups.ATTRIBUTE8%type;
    L_ATTRIBUTE9		       	  cn_role_pay_groups.ATTRIBUTE9%type;
    L_ATTRIBUTE10		       	  cn_role_pay_groups.ATTRIBUTE10%type;
    L_ATTRIBUTE11		       	  cn_role_pay_groups.ATTRIBUTE11%type;
    L_ATTRIBUTE12		       	  cn_role_pay_groups.ATTRIBUTE12%type;
    L_ATTRIBUTE13		       	  cn_role_pay_groups.ATTRIBUTE13%type;
    L_ATTRIBUTE14		       	  cn_role_pay_groups.ATTRIBUTE14%type;
    L_ATTRIBUTE15	       		  cn_role_pay_groups.ATTRIBUTE15%type;
    L_CREATED_BY	       		  cn_role_pay_groups.CREATED_BY%type;
    L_CREATION_DATE		       	  cn_role_pay_groups.CREATION_DATE%type;
    L_LAST_UPDATE_LOGIN	       	          cn_role_pay_groups.LAST_UPDATE_LOGIN%type;
    L_LAST_UPDATE_DATE		          cn_role_pay_groups.LAST_UPDATE_DATE%type;
    L_LAST_UPDATED_BY			  cn_role_pay_groups.LAST_UPDATED_BY%type;
    L_ORG_ID                      cn_role_pay_groups.ORG_ID%type;

    cursor C is select ROWID from CN_ROLE_PAY_GROUPS
    where ROLE_PAY_GROUP_ID = X_ROLE_PAY_GROUP_ID;

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
   SELECT DECODE(X_ORG_ID, FND_API.G_MISS_NUM,
		      NULL,Ltrim(Rtrim(X_ORG_ID)))
	  INTO L_ORG_ID FROM dual;

	-- dbms_output.put_line('before insert_row');

	INSERT INTO cn_role_pay_groups (
			 ROLE_PAY_GROUP_ID,
			 ROLE_ID,
			 PAY_GROUP_ID,
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
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATE_LOGIN,
			 LAST_UPDATE_DATE,
			 LAST_UPDATED_BY,
             ORG_ID,
             OBJECT_VERSION_NUMBER)
                  VALUES (
			 X_ROLE_PAY_GROUP_ID,
			 X_ROLE_ID,
			 X_PAY_GROUP_ID,
			 X_START_DATE,
			 L_END_DATE,
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
             L_LAST_UPDATED_BY,
             L_ORG_ID,
             1);
X_OBJECT_VERSION_NUMBER:=1;
	-- dbms_output.put_line('after insert_row');

END insert_row;


procedure DELETE_ROW (X_ROLE_PAY_GROUP_ID IN NUMBER) IS
BEGIN
   DELETE FROM cn_role_pay_groups
     WHERE role_pay_group_id = x_role_pay_group_id;
   IF  (sql%notfound) THEN
    raise no_data_found;
   END IF;
END delete_row;

END cn_role_pay_groups_pkg;

/
