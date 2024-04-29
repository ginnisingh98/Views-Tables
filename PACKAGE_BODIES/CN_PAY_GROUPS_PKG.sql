--------------------------------------------------------
--  DDL for Package Body CN_PAY_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAY_GROUPS_PKG" as
-- $Header: cnpgrptb.pls 120.3 2005/07/26 02:36:09 sjustina ship $


  g_temp_status_code VARCHAR2(30) := NULL;
  g_program_type     VARCHAR2(30) := NULL;

 --------------------------------------------------------------------------
 -- Procedure Name : Get_UID
 -- Purpose        : Get the Sequence Number to Create a new Pay Group
 --------------------------------------------------------------------------

 PROCEDURE Get_UID( X_pay_group_id     IN OUT NOCOPY NUMBER) IS

 BEGIN

    SELECT cn_pay_groups_s.nextval
      INTO   X_pay_group_id
      FROM   sys.dual;

 END Get_UID;


  -------------------------------------------------------------------------
  -- Procedure Name : Insert_Record
  -- Purpose        : Main insert procedure
  -------------------------------------------------------------------------

  PROCEDURE Insert_Record(
                        x_Rowid           IN OUT NOCOPY VARCHAR2
                       ,x_pay_group_Id    IN OUT NOCOPY NUMBER
                       ,x_name			                 VARCHAR2
		               ,x_period_set_name		         VARCHAR2
                       ,x_period_type			         VARCHAR2
		               ,x_start_date			         DATE
		               ,x_end_date			             DATE
		               ,x_pay_group_description		     VARCHAR2
		               ,x_period_set_id                  NUMBER
		               ,x_period_type_id                 NUMBER
		               ,x_attribute_category             VARCHAR2
                       ,x_attribute1                     VARCHAR2
                       ,x_attribute2                     VARCHAR2
                       ,x_attribute3                     VARCHAR2
                       ,x_attribute4                     VARCHAR2
                       ,x_attribute5                     VARCHAR2
                       ,x_attribute6                     VARCHAR2
                       ,x_attribute7                     VARCHAR2
                       ,x_attribute8                     VARCHAR2
                       ,x_attribute9                     VARCHAR2
                       ,x_attribute10                    VARCHAR2
                       ,x_attribute11                    VARCHAR2
                       ,x_attribute12                    VARCHAR2
                       ,x_attribute13                    VARCHAR2
                       ,x_attribute14                    VARCHAR2
                       ,x_attribute15                    VARCHAR2
                       ,x_Created_By                     NUMBER
                       ,x_Creation_Date                  DATE
                       ,x_Last_Updated_By                NUMBER
                       ,x_Last_Update_Date               DATE
                       ,x_Last_Update_Login              NUMBER
                       ,x_object_version_number     OUT  NOCOPY NUMBER
                       ,x_org_id                         NUMBER) IS

  BEGIN

     IF x_pay_group_id is null
     THEN
        Get_UID( X_pay_group_id );
     END IF;

          INSERT INTO cn_pay_groups(
		        pay_group_id
               ,name
               ,period_set_name
               ,period_type
               ,start_date
               ,end_date
               ,pay_group_description
	           ,period_set_id
	           ,period_type_id
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
               ,Created_By
               ,Creation_Date
               ,Last_Updated_By
               ,Last_Update_Date
               ,Last_Update_Login
               ,object_version_number
               ,org_id)
            VALUES (
               	x_pay_group_id
               ,x_name
               ,x_period_set_name
               ,x_period_type
               ,x_start_date
               ,x_end_date
               ,x_pay_group_description
	           ,x_period_set_id
	           ,x_period_type_id
	           ,x_attribute_category
               ,x_attribute1
               ,x_attribute2
               ,x_attribute3
               ,x_attribute4
               ,x_attribute5
               ,x_attribute6
               ,x_attribute7
               ,x_attribute8
               ,x_attribute9
               ,x_attribute10
               ,x_attribute11
               ,x_attribute12
               ,x_attribute13
               ,x_attribute14
               ,x_attribute15
               ,x_Created_By
               ,x_Creation_Date
               ,x_Last_Updated_By
               ,x_Last_Update_Date
               ,x_Last_Update_Login
               ,1
               ,x_org_id
             );
  x_object_version_number := 1;
  END Insert_Record;

  --------------------------------------------------------------------------
  -- Procedure Name : Update Record
  -- Purpose        : To Update the Pay Groups
  --------------------------------------------------------------------------

  PROCEDURE Update_Record(
     x_pay_group_id             NUMBER
    ,x_name		                VARCHAR2   	:= fnd_api.g_miss_char
    ,x_period_set_name	        VARCHAR2	:= fnd_api.g_miss_char
    ,x_period_type              VARCHAR2    := fnd_api.g_miss_char
    ,x_start_date		        DATE		:= fnd_api.g_miss_date
    ,x_end_date		            DATE		:= fnd_api.g_miss_date
    ,x_pay_group_description    VARCHAR2	:= fnd_api.g_miss_char
    ,x_period_set_id            NUMBER      := cn_api.g_miss_id
    ,x_period_type_id           NUMBER      := cn_api.g_miss_id
    ,x_attribute_category       VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute1               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute2               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute3               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute4               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute5               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute6               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute7               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute8               VARCHAR2    := fnd_api.g_miss_char
    ,x_attribute9               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute10              VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute11              VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute12              VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute13              VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute14              VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute15              VARCHAR2	:= fnd_api.g_miss_char
    ,x_Last_Updated_By          NUMBER
    ,x_Last_Update_Date          DATE
    ,x_Last_Update_Login         NUMBER
    ,x_object_version_number OUT NOCOPY NUMBER
    ,x_org_id                    NUMBER ) IS

   l_name			        cn_pay_groups.name%TYPE;
   l_period_set_name		cn_pay_groups.period_set_name%TYPE;
   l_period_type 		    cn_pay_groups.period_type%TYPE;
   l_start_date			    cn_pay_groups.start_date%TYPE;
   l_end_date			    cn_pay_groups.end_date%TYPE;
   l_pay_group_description	cn_pay_groups.pay_group_description%TYPE;
   l_period_set_id          cn_pay_groups.period_set_id%TYPE;
   l_period_type_id         cn_pay_groups.period_type_id%TYPE;
   l_attribute_category		cn_pay_groups.attribute_category%TYPE;
   l_attribute1			    cn_pay_groups.attribute1%TYPE;
   l_attribute2			    cn_pay_groups.attribute2%TYPE;
   l_attribute3	    		cn_pay_groups.attribute3%TYPE;
   l_attribute4	    		cn_pay_groups.attribute4%TYPE;
   l_attribute5	    		cn_pay_groups.attribute5%TYPE;
   l_attribute6	   		    cn_pay_groups.attribute6%TYPE;
   l_attribute7	   		    cn_pay_groups.attribute7%TYPE;
   l_attribute8			    cn_pay_groups.attribute8%TYPE;
   l_attribute9			    cn_pay_groups.attribute9%TYPE;
   l_attribute10		    cn_pay_groups.attribute10%TYPE;
   l_attribute11		    cn_pay_groups.attribute11%TYPE;
   l_attribute12		    cn_pay_groups.attribute12%TYPE;
   l_attribute13		    cn_pay_groups.attribute13%TYPE;
   l_attribute14		    cn_pay_groups.attribute14%TYPE;
   l_attribute15		    cn_pay_groups.attribute15%TYPE;
   l_org_id                 cn_pay_groups.org_id%TYPE;

    CURSOR pay_group_cur IS
       SELECT *
	 FROM cn_pay_groups
        WHERE pay_group_id = x_pay_group_id;

    l_pay_group_rec pay_group_cur%ROWTYPE;

 BEGIN

    OPEN pay_group_cur;
    FETCH pay_group_cur INTO l_pay_group_rec;
    CLOSE pay_group_cur;

    SELECT decode(x_name,
                  fnd_api.g_miss_char, l_pay_group_rec.name,
		  x_name),
	   decode(x_period_set_name,
                  fnd_api.g_miss_char, l_pay_group_rec.period_set_name,
		  x_period_set_name),
	   decode(x_period_type,
                  fnd_api.g_miss_char, l_pay_group_rec.period_type,
		  x_period_type),
	   decode(x_start_date,
                  fnd_api.g_miss_date, l_pay_group_rec.start_date,
		  x_start_date),
	   decode(x_end_date,
                  fnd_api.g_miss_date, l_pay_group_rec.end_date,
		  x_end_date),
	   decode(x_pay_group_description,
                  fnd_api.g_miss_char, l_pay_group_rec.pay_group_description,
		  x_pay_group_description),
      	   decode(x_period_set_id,
                  cn_api.g_miss_id, l_pay_group_rec.period_set_id,
		  x_period_set_id),
      	   decode(x_period_type_id,
                  cn_api.g_miss_id, l_pay_group_rec.period_type_id,
		  x_period_type_id),
	   decode(x_attribute_category,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute_category,
		  x_attribute_category),
	   decode(x_attribute1,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute1,
		  x_attribute1),
	   decode(x_attribute2,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute2,
		  x_attribute2),
	   decode(x_attribute3,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute3,
		  x_attribute3),
	   decode(x_attribute4,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute4,
		  x_attribute4),
	   decode(x_attribute5,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute5,
		  x_attribute5),
	   decode(x_attribute6,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute6,
		  x_attribute6),
	   decode(x_attribute7,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute7,
		  x_attribute7),
	   decode(x_attribute8,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute8,
		  x_attribute8),
	   decode(x_attribute9,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute9,
		  x_attribute9),
	   decode(x_attribute10,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute10,
		  x_attribute10),
	   decode(x_attribute11,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute11,
		  x_attribute11),
	   decode(x_attribute12,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute12,
		  x_attribute12),
	   decode(x_attribute13,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute13,
		  x_attribute13),
	   decode(x_attribute14,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute14,
		  x_attribute14),
	   decode(x_attribute15,
                  fnd_api.g_miss_char, l_pay_group_rec.attribute15,
		  x_attribute15),
        decode(x_org_id,
                  cn_api.g_miss_id, l_pay_group_rec.org_id,
		  x_org_id)

    INTO l_name,
	 l_period_set_name,
         l_period_type,
	 l_start_date,
	 l_end_date,
	 l_pay_group_description,
         l_period_set_id,
         l_period_type_id,
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
	 l_attribute15,
	 l_org_id
    FROM dual;


    UPDATE cn_pay_groups
     SET
       	name                 	=   l_name,
	    period_set_name		    = 	l_period_set_name,
        period_type		        = 	l_period_type,
	    start_date		        =	l_start_date,
	    end_date		        =	l_end_date,
        pay_group_description	=   l_pay_group_description,
        period_set_id           =   l_period_set_id,
        period_type_id          =   l_period_type_id,
        attribute_category	    =	l_attribute_category,
        attribute1		        =   l_attribute1,
        attribute2		        =   l_attribute2,
        attribute3		        =	l_attribute3,
        attribute4		        =	l_attribute4,
        attribute5		        =	l_attribute5,
        attribute6		        =	l_attribute6,
        attribute7		        =	l_attribute7,
        attribute8		        =	l_attribute8,
        attribute9		        =	l_attribute9,
        attribute10		        =	l_attribute10,
        attribute11		        =	l_attribute11,
        attribute12		        =	l_attribute12,
        attribute13		        =	l_attribute13,
        attribute14		        =	l_attribute14,
        attribute15		        =	l_attribute15,
        last_update_date	    =	x_Last_Update_Date,
       	last_updated_by      	=   x_Last_Updated_By,
	    last_update_login    	=   x_Last_Update_Login,
        object_version_number   =   object_version_number + 1
        WHERE pay_group_id      =   x_pay_group_id ;

     select object_version_number into x_object_version_number
     from cn_pay_groups where pay_group_id = x_pay_group_id;

     if (SQL%NOTFOUND) then
        Raise NO_DATA_FOUND;
     end if;

  END Update_Record;


  -------------------------------------------------------------------------
  -- Procedure Name : Delete_Record
  -- Purpose        : Delete the Pay Group if it has not been assigned
  --                  to a salesrep
  -------------------------------------------------------------------------

  PROCEDURE Delete_Record( x_pay_group_id     NUMBER ) IS
  BEGIN

        DELETE FROM cn_pay_groups
        WHERE  pay_group_id = x_pay_group_id;


  END Delete_Record;


  -----------------------------------------------------------------------------
  --  Procedure Name : BEGIN_RECORD
  --  Purpose        : This PUBLIC procedure is called at the start of the
  --		       commit cycle.
  -----------------------------------------------------------------------------
 PROCEDURE Begin_Record(
		               x_Operation		                 VARCHAR2
		               ,x_Rowid            IN OUT NOCOPY VARCHAR2
               	       ,x_pay_group_id     IN OUT NOCOPY NUMBER
                       ,x_name              		     VARCHAR2
		               ,x_period_set_name		         VARCHAR2
                       ,x_period_type                    VARCHAR2
                       ,x_start_date		             DATE
                       ,x_end_date	                     DATE
                       ,x_pay_group_description          VARCHAR2
		               ,x_period_set_id                  NUMBER
		               ,x_period_type_id                 NUMBER
		               ,x_attribute_category             VARCHAR2
                       ,x_attribute1                     VARCHAR2
                       ,x_attribute2                     VARCHAR2
                       ,x_attribute3                     VARCHAR2
                       ,x_attribute4                     VARCHAR2
                       ,x_attribute5                     VARCHAR2
                       ,x_attribute6                     VARCHAR2
                       ,x_attribute7                     VARCHAR2
                       ,x_attribute8                     VARCHAR2
                       ,x_attribute9                     VARCHAR2
                       ,x_attribute10                    VARCHAR2
                       ,x_attribute11                    VARCHAR2
                       ,x_attribute12                    VARCHAR2
                       ,x_attribute13                    VARCHAR2
                       ,x_attribute14                    VARCHAR2
                       ,x_attribute15                    VARCHAR2
                       ,x_Created_By                     NUMBER
                       ,x_Creation_Date                  DATE
                       ,x_Last_Updated_By                NUMBER
                       ,x_Last_Update_Date               DATE
                       ,x_Last_Update_Login              NUMBER
		               ,x_Program_Type			         VARCHAR2
                       ,x_object_version_number    OUT  NOCOPY NUMBER
                       ,x_org_id                         NUMBER) IS

 BEGIN

   IF X_Operation = 'INSERT' THEN

     Insert_Record(     X_Rowid
                       ,X_pay_group_id
                       ,X_name
		               ,X_period_set_name
		               ,x_period_type
                       ,X_start_date
		               ,X_end_date
		               ,X_pay_group_description
		               ,X_period_set_id
		               ,X_period_type_id
		               ,X_attribute_category
                       ,X_attribute1
                       ,X_attribute2
                       ,X_attribute3
                       ,X_attribute4
                       ,X_attribute5
                       ,X_attribute6
                       ,X_attribute7
                       ,X_attribute8
                       ,X_attribute9
                       ,X_attribute10
                       ,X_attribute11
                       ,X_attribute12
                       ,X_attribute13
                       ,X_attribute14
                       ,X_attribute15
                       ,X_Created_By
                       ,X_Creation_Date
                       ,X_Last_Updated_By
                       ,X_Last_Update_Date
		               ,X_Last_Update_Login
                       ,x_object_version_number
                       ,x_org_id);

   ELSIF X_Operation = 'UPDATE' THEN

     Update_Record(	    X_pay_group_id
                       ,X_name
                       ,X_period_set_name
                       ,X_period_type
                       ,X_start_date
		               ,X_end_date
		               ,X_pay_group_description
		               ,X_period_set_id
		               ,X_period_type_id
		               ,X_attribute_category
                       ,X_attribute1
                       ,X_attribute2
                       ,X_attribute3
                       ,X_attribute4
                       ,X_attribute5
                       ,X_attribute6
                       ,X_attribute7
                       ,X_attribute8
                       ,X_attribute9
                       ,X_attribute10
                       ,X_attribute11
                       ,X_attribute12
                       ,X_attribute13
                       ,X_attribute14
                       ,X_attribute15
                       ,X_Last_Updated_By
                       ,X_Last_Update_Date
		               ,X_Last_Update_Login
                       ,x_object_version_number
                       ,x_org_id);

    ELSIF X_Operation = 'DELETE' THEN

       Delete_Record(	X_pay_group_id );

    END IF;

 END Begin_Record;

END CN_PAY_GROUPS_PKG;

/
