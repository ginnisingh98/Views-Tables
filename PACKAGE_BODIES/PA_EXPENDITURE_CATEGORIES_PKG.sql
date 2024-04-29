--------------------------------------------------------
--  DDL for Package Body PA_EXPENDITURE_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EXPENDITURE_CATEGORIES_PKG" as
/* $Header: PAXTECSB.pls 120.1 2005/08/09 04:32:19 avajain noship $ */

 PROCEDURE Insert_Row ( X_Expenditure_category      VARCHAR2,
		       X_Last_update_date 	    DATE,
		       X_Last_updated_by 	    NUMBER,
		       X_Creation_date	 	    DATE,
		       X_Created_by 		    NUMBER,
		       X_Last_update_login 	    NUMBER,
		       X_Start_date_active 	    DATE,
          	       X_Description 		    VARCHAR2,
	               X_End_date_active 	    DATE,
		       X_Attribute_category 	    VARCHAR2,
		       X_Attribute1 		    VARCHAR2,
		       X_Attribute2 		    VARCHAR2,
	 	       X_Attribute3 		    VARCHAR2,
                       X_Attribute4 		    VARCHAR2,
                       X_Attribute5 		    VARCHAR2,
                       X_Attribute6 		    VARCHAR2,
                       X_Attribute7 		    VARCHAR2,
                       X_Attribute8 		    VARCHAR2,
                       X_Attribute9 		    VARCHAR2,
                       X_Attribute10 		    VARCHAR2,
                       X_Attribute11 		    VARCHAR2,
                       X_Attribute12 		    VARCHAR2,
                       X_Attribute13 		    VARCHAR2,
                       X_Attribute14 		    VARCHAR2,
                       X_Attribute15		    VARCHAR2,
		       X_Return_Status	OUT	 NOCOPY   VARCHAR2,
		       X_Msg_Count	OUT	  NOCOPY  NUMBER,
		       X_Msg_Data       OUT   NOCOPY      VARCHAR2
                      )
     IS
     BEGIN
         INSERT INTO Pa_Expenditure_Categories
			(	Expenditure_category,
				Last_update_date,
				Last_updated_by,
             			Creation_date,
             			Created_by,
             			Last_update_login,
             			Start_date_active,
             			Description,
             			End_date_active,
             			Attribute_category,
             			Attribute1,
             			Attribute2,
             			Attribute3,
             			Attribute4,
             			Attribute5,
                   		Attribute6,
                   		Attribute7,
                   		Attribute8,
                   		Attribute9,
                   		Attribute10,
                   		Attribute11,
                   		Attribute12,
                   		Attribute13,
                   		Attribute14,
                   		Attribute15
			)
           VALUES
             (     X_Expenditure_category,
                   X_Last_update_date,
                   X_Last_updated_by,
                   X_Creation_date,
                   X_Created_by,
                   X_Last_update_login,
                   X_Start_date_active,
                   X_Description,
                   X_End_date_active,
                   X_Attribute_category,
                   X_Attribute1,
                   X_Attribute2,
                   X_Attribute3,
                   X_Attribute4,
                   X_Attribute5,
                   X_Attribute6,
                   X_Attribute7,
                   X_Attribute8,
                   X_Attribute9,
                   X_Attribute10,
                   X_Attribute11,
                   X_Attribute12,
                   X_Attribute13,
                   X_Attribute14,
                   X_Attribute15
		   );

	    X_return_status := FND_API.G_RET_STS_SUCCESS;
            X_msg_count     := 0;
            X_msg_data      := NULL;

     EXCEPTION
        WHEN OTHERS THEN
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            X_msg_count     := 1;
            X_msg_data      := SQLERRM;

            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_AGREEMENT_TYPES_PKG' ,
              p_procedure_name => 'Insert_Row');
     END;

  PROCEDURE Lock_Row(  X_Expenditure_category       VARCHAR2,
                       X_Last_update_date 	    DATE,
                       X_Last_updated_by 	    NUMBER,
                       X_Creation_date	 	    DATE,
                       X_Created_by 		    NUMBER,
                       X_Last_update_login 	    NUMBER,
                       X_Start_date_active 	    DATE,
                       X_Description 		    VARCHAR2,
                       X_End_date_active 	    DATE,
                       X_Attribute_category 	    VARCHAR2,
                       X_Attribute1 		    VARCHAR2,
                       X_Attribute2 		    VARCHAR2,
                       X_Attribute3 		    VARCHAR2,
                       X_Attribute4 		    VARCHAR2,
                       X_Attribute5 		    VARCHAR2,
                       X_Attribute6 		    VARCHAR2,
                       X_Attribute7 		    VARCHAR2,
                       X_Attribute8 		    VARCHAR2,
                       X_Attribute9 		    VARCHAR2,
                       X_Attribute10 		    VARCHAR2,
                       X_Attribute11 		    VARCHAR2,
                       X_Attribute12 		    VARCHAR2,
                       X_Attribute13 		    VARCHAR2,
                       X_Attribute14 		    VARCHAR2,
                       X_Attribute15		    VARCHAR2,
		       X_Return_Status	OUT	  NOCOPY  VARCHAR2,
		       X_Msg_Count	OUT	 NOCOPY   NUMBER,
		       X_Msg_Data       OUT   NOCOPY      VARCHAR2
                     )
     IS

        CURSOR C IS
        SELECT *
        FROM  Pa_Expenditure_Categories
        WHERE Expenditure_Category = X_Expenditure_Category
        FOR UPDATE of Expenditure_Category NOWAIT;

       Recinfo C%ROWTYPE;


  BEGIN
      OPEN C;
      FETCH C INTO Recinfo;

     IF (C%NOTFOUND) THEN
         CLOSE C;
         fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      CLOSE C;
      if (
              (  Recinfo.Expenditure_Category   = X_Expenditure_Category)
	 AND  ( (Recinfo.Start_Date_Active      = X_Start_Date_Active)
               OR (    (Recinfo.start_date_active IS NULL)
                   AND (X_Start_Date_Active IS NULL)))
         AND  (   (Recinfo.description          = X_Description)
               OR (    (Recinfo.description IS NULL)
                   AND (X_Description IS NULL)))
         AND  (   (Recinfo.end_date_active      = X_End_Date_Active)
               OR (    (Recinfo.end_date_active IS NULL)
                   AND (X_End_Date_Active IS NULL)))
         AND  (   (Recinfo.attribute_category   = X_Attribute_Category)
               OR (    (Recinfo.attribute_category IS NULL)
                   AND (X_Attribute_Category IS NULL)))
         AND  (   (Recinfo.attribute1           = X_Attribute1)
               OR (    (Recinfo.attribute1 IS NULL)
                   AND (X_Attribute1 IS NULL)))
         AND  (   (Recinfo.attribute2           = X_Attribute2)
               OR (    (Recinfo.attribute2 IS NULL)
                   AND (X_Attribute2 IS NULL)))
         AND  (   (Recinfo.attribute3           = X_Attribute3)
               OR (    (Recinfo.attribute3 IS NULL)
                   AND (X_Attribute3 IS NULL)))
         AND  (   (Recinfo.attribute4           = X_Attribute4)
               OR (    (Recinfo.attribute4 IS NULL)
                   AND (X_Attribute4 IS NULL)))
         AND  (   (Recinfo.attribute5           = X_Attribute5)
               OR (    (Recinfo.attribute5 IS NULL)
                   AND (X_Attribute5 IS NULL)))
         AND  (   (Recinfo.attribute6           = X_Attribute6)
               OR (    (Recinfo.attribute6 IS NULL)
                   AND (X_Attribute6 IS NULL)))
         AND  (   (Recinfo.attribute7           = X_Attribute7)
               OR (    (Recinfo.attribute7 IS NULL)
                   AND (X_Attribute7 IS NULL)))
         AND  (   (Recinfo.attribute8           = X_Attribute8)
               OR (    (Recinfo.attribute8 IS NULL)
                   AND (X_Attribute8 IS NULL)))
         AND  (   (Recinfo.attribute9           = X_Attribute9)
               OR (    (Recinfo.attribute9 IS NULL)
                   AND (X_Attribute9 IS NULL)))
         AND  (   (Recinfo.attribute10          = X_Attribute10)
               OR (    (Recinfo.attribute10 IS NULL)
                   AND (X_Attribute10 IS NULL)))
         AND  (   (Recinfo.attribute11          = X_Attribute11)
               OR (    (Recinfo.attribute11 IS NULL)
                   AND (X_Attribute11 IS NULL)))
         AND  (   (Recinfo.attribute12          = X_Attribute12)
               OR (    (Recinfo.attribute12 IS NULL)
                   AND (X_Attribute12 IS NULL)))
         AND  (   (Recinfo.attribute13          = X_Attribute13)
               OR (    (Recinfo.attribute13 IS NULL)
                   AND (X_Attribute13 IS NULL)))
         AND  (   (Recinfo.attribute14          = X_Attribute14)
               OR (    (Recinfo.attribute14 IS NULL)
                   AND (X_Attribute14 IS NULL)))
         AND  (   (Recinfo.attribute15          = X_Attribute15)
               OR (    (Recinfo.attribute15 IS NULL)
                   AND (X_Attribute15 IS NULL)))
      )
      then
            X_return_status := FND_API.G_RET_STS_SUCCESS;
            X_msg_count     := 0;
            X_msg_data      := NULL;
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      RAISE FND_API.G_EXC_ERROR;
    end if;

     EXCEPTION
         WHEN FND_API.G_EXC_ERROR  THEN
           X_return_status := FND_API.G_RET_STS_ERROR;
           X_msg_count := FND_MSG_PUB.count_msg;
            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_EXPENDITURE_CATEGORIES_PKG' ,
              p_procedure_name => 'Lock_Row');

        WHEN OTHERS THEN
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            X_msg_count     := 1;
            X_msg_data      := SQLERRM;

            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_EXPENDITURE_CATEGORIES_PKG' ,
              p_procedure_name => 'Lock_Row');
     END;


PROCEDURE Update_Row(  X_Expenditure_category       VARCHAR2,
                       X_Last_update_date 	    DATE,
                       X_Last_updated_by 	    NUMBER,
                       X_Creation_date	 	    DATE,
                       X_Created_by 		    NUMBER,
                       X_Last_update_login 	    NUMBER,
                       X_Start_date_active 	    DATE,
                       X_Description 		    VARCHAR2,
                       X_End_date_active 	    DATE,
                       X_Attribute_category 	    VARCHAR2,
                       X_Attribute1 		    VARCHAR2,
                       X_Attribute2 		    VARCHAR2,
                       X_Attribute3 		    VARCHAR2,
                       X_Attribute4 		    VARCHAR2,
                       X_Attribute5 		    VARCHAR2,
                       X_Attribute6 		    VARCHAR2,
                       X_Attribute7 		    VARCHAR2,
                       X_Attribute8 		    VARCHAR2,
                       X_Attribute9 		    VARCHAR2,
                       X_Attribute10 		    VARCHAR2,
                       X_Attribute11 		    VARCHAR2,
                       X_Attribute12 		    VARCHAR2,
                       X_Attribute13 		    VARCHAR2,
                       X_Attribute14 		    VARCHAR2,
                       X_Attribute15		    VARCHAR2,
		       X_Return_Status	OUT	 NOCOPY   VARCHAR2,
		       X_Msg_Count	OUT	 NOCOPY   NUMBER,
		       X_Msg_Data       OUT     NOCOPY    VARCHAR2
                     )
     IS
     CURSOR C IS
     SELECT EXPENDITURE_CATEGORY FROM PA_EXPENDITURE_CATEGORIES
     WHERE
        Expenditure_Category = X_Expenditure_Category;
     BEGIN
     OPEN C;
     IF (C%NOTFOUND) then
     RAISE No_Data_Found;
     ELSE
         UPDATE Pa_Expenditure_Categories SET
                       Expenditure_category	 = X_Expenditure_category	,
		       Last_update_date		 = X_Last_update_date 		,
		       Last_updated_by 		 = X_Last_updated_by 		,
		       Creation_date		 = X_Creation_date	 	,
		       Created_by		 = X_Created_by 		,
		       Last_update_login 	 = X_Last_update_login 		,
		       Start_date_active 	 = X_Start_date_active 		,
		       Description 		 = X_Description 		,
		       End_date_active 		 = X_End_date_active 		,
                       Attribute_Category        = X_Attribute_Category         ,
                       Attribute1                = X_Attribute1                 ,
                       Attribute2                = X_Attribute2                 ,
                       Attribute3                = X_Attribute3                 ,
                       Attribute4                = X_Attribute4                 ,
                       Attribute5                = X_Attribute5                 ,
                       Attribute6                = X_Attribute6                 ,
                       Attribute7                = X_Attribute7                 ,
                       Attribute8                = X_Attribute8                 ,
                       Attribute9                = X_Attribute9                 ,
                       Attribute10               = X_Attribute10                ,
                       Attribute11               = X_Attribute11                ,
                       Attribute12               = X_Attribute12                ,
                       Attribute13               = X_Attribute13                ,
                       Attribute14               = X_Attribute14                ,
                       Attribute15               = X_Attribute15

WHERE       expenditure_category= X_expenditure_category;

	    X_return_status := FND_API.G_RET_STS_SUCCESS;
            X_msg_count     := 0;
            X_msg_data      := NULL;
	end if;

     EXCEPTION
        WHEN OTHERS THEN
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            X_msg_count     := 1;
            X_msg_data      := SQLERRM;

            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_EXPENDITURE_CATEGORIES_PKG' ,
              p_procedure_name => 'Update_Row');

     END;

END PA_EXPENDITURE_CATEGORIES_PKG;

/
