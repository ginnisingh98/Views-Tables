--------------------------------------------------------
--  DDL for Package Body GMS_FUNDING_PATTERNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_FUNDING_PATTERNS_PKG" AS
-- $Header: gmsfptbb.pls 120.1 2005/07/26 14:22:06 appldev ship $

PROCEDURE INSERT_ROW( P_rec GMS_FUNDING_PATTERNS_ALL%ROWTYPE)
    IS
    X_rec GMS_FUNDING_PATTERNS_ALL%ROWTYPE;

   BEGIN
    X_rec := P_rec;

    IF X_REC.funding_pattern_id  is NULL THEN
  	          select gms_funding_pattern_s.nextval
	          into X_REC.funding_pattern_id
	          from dual;

 END IF ;

 IF X_REC.creation_date is NULL THEN
	x_rec.creation_date := SYSDATE ;
 END IF ;

    insert into GMS_FUNDING_PATTERNS_ALL( funding_pattern_id
                                        	,org_id
                                        	,funding_sequence
                                        	,funding_name
                                   		,retroactive_flag
                                        	,project_id
                                        	,task_id
                                        	,status
                                        	,funds_status
                                        	,start_date
                                        	,end_date
                                      		,last_update_date
                                       		,last_updated_by
                                       		,creation_date
                                       		,created_by
                                       		,last_update_login)
                                 values(X_rec.funding_pattern_id
                                        , X_rec.org_id
                                        ,X_rec.funding_sequence
                                        ,X_rec.funding_name
                                        ,X_rec.retroactive_flag
                                        ,X_rec.project_id
                                        ,X_rec.task_id
                                        ,X_rec.status
                                        , X_rec.funds_status
                                        , X_rec.start_date
                                        , X_rec.end_date
					                    , X_rec.last_update_date
                                        , X_rec.last_updated_by
                                        , X_rec.creation_date
                                        , X_rec.created_by
                                        , X_rec.last_update_login);



   END;



   PROCEDURE LOCK_ROW (  P_rec GMS_FUNDING_PATTERNS_ALL%ROWTYPE) IS
     Counter NUMBER;
       CURSOR C IS
                                     SELECT funding_pattern_id
                                        	,org_id
                                        	,funding_sequence
                                        	,funding_name
                                   		    ,retroactive_flag
                                        	,project_id
                                        	,task_id
                                        	,status
                                        	,funds_status
                                        	,start_date
                                        	,end_date
                                    FROM GMS_FUNDING_PATTERNS_ALL
                                    WHERE funding_pattern_id = P_rec.funding_pattern_id
                                    AND  funding_sequence   =  P_rec.funding_sequence
                                    AND  funding_name       =  P_rec.funding_name
                                    AND  status             =  P_rec.status;
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
               ( (X_rec.funding_sequence	=	P_REC.funding_sequence ) OR
               (( X_rec.funding_sequence is NULL ) AND ( P_REC.funding_sequence IS NULL ))
               ) AND
               ( (X_rec.org_id =	P_REC.org_id ) OR
               (( X_rec.org_id is NULL ) AND ( P_REC.org_id IS NULL ))
               ) AND
               ( (X_rec.funding_name =	P_REC.funding_name ) OR
               (( X_rec.funding_name is NULL ) AND ( P_REC.funding_name IS NULL ))
               ) AND
               ( (X_rec.retroactive_flag =	P_REC.retroactive_flag ) OR
               (( X_rec.retroactive_flag is NULL ) AND ( P_REC.retroactive_flag IS NULL ))
               ) AND
               ( (X_rec.project_id =	P_REC.project_id ) OR
               (( X_rec.project_id is NULL ) AND ( P_REC.project_id IS NULL ))
               )  AND
               ( (X_rec.task_id =	P_REC.task_id ) OR
               (( X_rec.task_id is NULL ) AND ( P_REC.task_id IS NULL ))
               ) AND
               ( (X_rec.status =	P_REC.status ) OR
               (( X_rec.status is NULL ) AND ( P_REC.status IS NULL ))
               ) AND
               ( (X_rec.funds_status =	P_REC.funds_status ) OR
               (( X_rec.funds_status is NULL ) AND ( P_REC.funds_status IS NULL ))
               ) AND
               ( (X_rec.start_date =	P_REC.start_date ) OR
               (( X_rec.start_date is NULL ) AND ( P_REC.start_date IS NULL ))
               )   AND
               ( (X_rec.end_date =	P_REC.end_date ) OR
               (( X_rec.end_date is NULL ) AND ( P_REC.end_date IS NULL ))
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

   PROCEDURE UPDATE_ROW( P_rec GMS_FUNDING_PATTERNS_ALL%ROWTYPE)
   IS
        X_rec GMS_FUNDING_PATTERNS_ALL%ROWTYPE;

   BEGIN
    X_rec := P_rec;
               update GMS_FUNDING_PATTERNS_ALL
		       set  funding_sequence  = X_rec.funding_sequence
                   ,funding_name	  = X_rec.funding_name
                   ,retroactive_flag  = X_rec.retroactive_flag
                   ,status 	          = X_rec.status
                   ,start_date        = nvl(X_rec.start_date,sysdate)
                   ,end_date 	      = X_rec.end_date
            where funding_pattern_id  = X_rec.funding_pattern_id ;
             IF (SQL%NOTFOUND) THEN
                raise NO_DATA_FOUND;
             END IF;

   EXCEPTION
	WHEN OTHERS THEN
		RAISE ;

 END UPDATE_ROW;

 PROCEDURE DELETE_ROW( P_rec GMS_FUNDING_PATTERNS_ALL%ROWTYPE)
 IS
  X_rec GMS_FUNDING_PATTERNS_ALL%ROWTYPE;
 BEGIN
    X_rec := P_rec;
            delete gms_funding_patterns_all
	         where funding_pattern_id=X_rec.funding_pattern_id ;

              IF (SQL%NOTFOUND) THEN
                raise NO_DATA_FOUND;
             END IF;

   EXCEPTION
	WHEN OTHERS THEN
		RAISE ;
 END DELETE_ROW;



END GMS_FUNDING_PATTERNS_PKG;

/
