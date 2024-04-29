--------------------------------------------------------
--  DDL for Package Body IES_PANEL_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_PANEL_DATA_PVT" AS
/* $Header: iesvipdb.pls 115.5 2002/12/09 21:13:50 appldev ship $ */

  PROCEDURE Insert_Panel_Data
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count		OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_panel_id          IN  NUMBER                  ,
    p_transaction_id    IN  NUMBER                  ,
    p_elapsed_time      IN  NUMBER                  ,
    p_sequence_num      IN  NUMBER                  ,
    p_deleted_status    IN  NUMBER
  ) IS
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Insert_Panel_Data_PVT;
    INSERT INTO ies_panel_data ( panel_data_id        ,
                                 created_by           ,
                                 creation_date        ,
                                 panel_id             ,
                                 transaction_id       ,
                                 elapsed_time         ,
                                 sequence_number      ,
                                 deleted_status       )
                     VALUES    ( ies_panel_data_s.nextval ,
                                 p_created_by             ,
                                 sysdate                  ,
                                 p_panel_id               ,
                                 p_transaction_id         ,
                                 p_elapsed_time           ,
                                 p_sequence_num           ,
                                 p_deleted_status         );
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Insert_Panel_Data_PVT;
       x_return_status := 'E';
       x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
  END Insert_Panel_Data;
END IES_PANEL_DATA_PVT;

/
