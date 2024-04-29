--------------------------------------------------------
--  DDL for Package Body GMS_FP_DISTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_FP_DISTRIBUTIONS_PKG" AS
-- $Header: gmsfdtbb.pls 120.1 2005/07/26 14:22:03 appldev ship $

   PROCEDURE INSERT_ROW ( P_rec GMS_FP_DISTRIBUTIONS%ROWTYPE)
    IS
      X_rec GMS_FP_DISTRIBUTIONS%ROWTYPE;

   BEGIN
      X_rec := P_rec;

      IF X_rec.creation_date is NULL THEN
	     x_rec.creation_date := SYSDATE ;
      END IF ;
      insert into GMS_FP_DISTRIBUTIONS(funding_pattern_id
                                        ,distribution_number
                                        ,award_id
                                        ,distribution_value
                                        ,last_update_date
                                        ,last_updated_by
                                        ,creation_date
                                        ,created_by
                                        ,last_update_login
					)
                                 values( X_rec .funding_pattern_id
                                        ,X_rec .distribution_number
                                        ,X_rec .award_id
                                        ,X_rec .distribution_value
                                        ,X_rec .last_update_date
                                        ,X_rec .last_updated_by
                                        ,X_rec .creation_date
                                        ,X_rec .created_by
                                        ,X_rec .last_update_login);




   END INSERT_ROW;

   PROCEDURE LOCK_ROW ( P_rec GMS_FP_DISTRIBUTIONS%ROWTYPE) IS
     Counter NUMBER;
       CURSOR C IS
           SELECT funding_pattern_id
                  ,distribution_number
                  ,award_id
                  ,distribution_value
           FROM GMS_FP_DISTRIBUTIONS
           WHERE funding_pattern_id    = P_rec.funding_pattern_id
           AND   distribution_number   = P_rec.distribution_number
           AND   award_id              = P_rec.award_id;
           X_rec C%ROWTYPE;
   BEGIN
   Counter := 0;
      LOOP
       BEGIN
        Counter := Counter+1;
        OPEN C;
        FETCH C INTO X_rec;
          if C%NOTFOUND then
            CLOSE C;
            fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
            app_exception.raise_exception;
            close C;
            end if;
            close C;


            if (
               ( (X_rec.funding_pattern_id	=	P_REC.funding_pattern_id ) OR
               (( X_rec.funding_pattern_id is NULL ) AND ( P_REC.funding_pattern_id IS NULL ))
               ) AND
               ( (X_rec.distribution_number	=	P_REC.distribution_number ) OR
               (( X_rec.distribution_number is NULL ) AND ( P_REC.distribution_number IS NULL ))
               ) AND
               ( (X_rec.award_id =	P_REC.award_id ) OR
               (( X_rec.award_id is NULL ) AND ( P_REC.award_id IS NULL ))
               ) AND
               ( (X_rec.distribution_value =	P_REC.distribution_value ) OR
               (( X_rec.distribution_value is NULL ) AND ( P_REC.distribution_value IS NULL ))
               )
               )


              then
               return;
              else
                 fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
                 app_exception.raise_exception;
               end if;
          EXCEPTION
            when APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION then
                IF (C% ISOPEN) THEN
                    close C;
                END IF;
        end;
      end loop;
   END LOCK_ROW;
   PROCEDURE UPDATE_ROW ( P_rec GMS_FP_DISTRIBUTIONS%ROWTYPE) IS
        X_rec GMS_FP_DISTRIBUTIONS%ROWTYPE;
     BEGIN
      X_rec := P_rec;

           update GMS_FP_DISTRIBUTIONS
       	   set distribution_value    = X_rec.distribution_value
              ,award_id 	         = X_rec.award_id
	       where funding_pattern_id  = X_rec.funding_pattern_id
	       and distribution_number   = X_rec.distribution_number;
        --IF (SQL%NOTFOUND) THEN
          --  raise NO_DATA_FOUND;
        --END IF;

     EXCEPTION
	     WHEN OTHERS THEN
		  RAISE ;

  END UPDATE_ROW;
  PROCEDURE DELETE_ROW ( P_rec GMS_FP_DISTRIBUTIONS%ROWTYPE) IS
  X_rec GMS_FP_DISTRIBUTIONS%ROWTYPE;
  BEGIN
        X_rec := P_rec;
                    delete gms_fp_distributions
                    where funding_pattern_id    = X_rec.funding_pattern_id
                    and distribution_number   =   X_rec.distribution_number;

                    IF (SQL%NOTFOUND) THEN
                     raise NO_DATA_FOUND;
                    END IF;

   EXCEPTION
	WHEN OTHERS THEN
		RAISE ;
    END DELETE_ROW;

END GMS_FP_DISTRIBUTIONS_PKG;

/
