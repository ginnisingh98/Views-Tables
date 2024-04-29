--------------------------------------------------------
--  DDL for Package Body IES_LOOKUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_LOOKUPS_PVT" AS
/* $Header: iesvielb.pls 115.7 2003/06/06 20:16:20 prkotha ship $ */

  PROCEDURE Insert_Lookup
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count	        OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_dscript_id        IN  NUMBER                  ,
    p_lookup_table_id   IN  NUMBER                  ,
    p_lookup_name       IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_lookup_id         OUT NOCOPY NUMBER
  ) IS
    seqval     NUMBER;
    insertstmt varchar2(4000);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Insert_Lookup_PVT;


    EXECUTE immediate 'select ies_lookups_s.nextval from dual' INTO seqval;

    insertStmt := 'INSERT INTO ies_lookups   ( lookup_id       ,
                                created_by      ,
                                creation_date   ,
                                dscript_id      ,
                                lookup_table_id ,
                                lookup_name     ,
                                active_status )
                    VALUES    ( :1,
                                :2,
                                :3,
                                :4,
                                :5,
                                :6,
                                :7 )
     RETURNING lookup_id INTO :8';

     execute immediate insertStmt using seqval,
                                     p_created_by        ,
                                     sysdate             ,
                                     p_dscript_id        ,
                                     p_lookup_table_id   ,
                                     p_lookup_name       ,
                                     p_active_status returning  into x_lookup_id;
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Insert_Lookup_PVT;
       x_return_status := 'E';
       x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
  END Insert_Lookup;

 PROCEDURE Update_Lookup
 (  p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count		OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_lookup_id         IN  NUMBER                  ,
    p_lookup_table_id   IN  NUMBER                  ,
    p_last_updated_by   IN  NUMBER                  ,
    p_lookup_name       IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_lookup_id         OUT NOCOPY NUMBER
  ) IS

  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Update_Lookup_PVT;
    execute immediate 'UPDATE ies_lookups SET last_updated_by  = :1  ,
			   lookup_table_id  = :2  ,
                           last_update_date = :3            ,
                           lookup_name      = :4      ,
                           active_status    = :5
                     WHERE lookup_id = :6
            RETURNING lookup_id INTO :7' USING p_last_updated_by  ,
                                               p_lookup_table_id  ,
                                               sysdate            ,
                                               p_lookup_name      ,
                                               p_active_status,
                                               p_lookup_id RETURNING INTO x_lookup_id;
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Update_Lookup_PVT;
       x_return_status := 'E';
       x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
  END Update_Lookup;
END IES_LOOKUPS_PVT;

/
