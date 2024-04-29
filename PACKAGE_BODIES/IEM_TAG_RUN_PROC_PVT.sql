--------------------------------------------------------
--  DDL for Package Body IEM_TAG_RUN_PROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_TAG_RUN_PROC_PVT" AS
/* $Header: iemvrprb.pls 120.1 2005/06/23 18:32:24 appldev shipped $ */
--
--
-- Purpose: Assistant api to dynamically run procedure.
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   3/26/2002  created
--  Liang Xia   3/18/2003  Fixed bug 2852915. DBMS_SQL.VARIABLE_VALUE
--  Liang Xia   11/1/2004  Fixed bug 3982076. Valid procedure name for 'TEST'
--  Liang Xia   04/06/2005   Fixed GSCC sql.46 ( bug 4256769 )
-- ---------   ------  ------------------------------------------

G_PKG_NAME CONSTANT varchar2(30) :='IEM_TAG_RUN_PROC_PVT ';

G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;

G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID') ) ;

    -- internal DBMS_DESCRIBE.DESCRIBE_PROCEDURE variables
    v_OverLoad          DBMS_DESCRIBE.NUMBER_TABLE;
    v_Position          DBMS_DESCRIBE.NUMBER_TABLE;
    v_Level             DBMS_DESCRIBE.NUMBER_TABLE;
    v_ArgumentName      DBMS_DESCRIBE.VARCHAR2_TABLE;
    v_DataType          DBMS_DESCRIBE.NUMBER_TABLE;
    v_DefaultValue      DBMS_DESCRIBE.NUMBER_TABLE;
    v_InOut             DBMS_DESCRIBE.NUMBER_TABLE;
    v_Length            DBMS_DESCRIBE.NUMBER_TABLE;
    v_Precision         DBMS_DESCRIBE.NUMBER_TABLE;
    v_Scale             DBMS_DESCRIBE.NUMBER_TABLE;
    v_Radix             DBMS_DESCRIBE.NUMBER_TABLE;
    v_Spare             DBMS_DESCRIBE.NUMBER_TABLE;

      /*GLOBAL VARIABLES FOR PRIVATE USE
  ==================================*/


    PROCEDURE validProcedure
                  (     p_api_version_number      IN  NUMBER,
                        P_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
                        p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
                        p_ProcName                IN VARCHAR2,
                        x_return_status           OUT NOCOPY VARCHAR2,
                        x_msg_count               OUT NOCOPY NUMBER,
                        x_msg_data                OUT NOCOPY VARCHAR2)
    IS
        i                       INTEGER;
        l_api_name		        varchar2(30):='validProcedure';
        l_api_version_number    number:=1.0;

        v_ArgCounter        NUMBER :=1;

        IEM_TAG_PROC_NOT_EXIST          EXCEPTION;
        IEM_TAG_PROC_NOT_EXIST_PACK     EXCEPTION;
        IEM_TAG_PROC_INVALID            EXCEPTION;
        IEM_TAG_PROC_SYNTAX_ERR         EXCEPTION;
        IEM_TAG_PROC_NOT_EXIST_PACK_1  EXCEPTION;
        IEM_TAG_PROC_INVALID_1          EXCEPTION;

        IEM_TAG_PROC_WRONG_SIGNATURE    EXCEPTION;

        -- ORA-20003: the object is invalid can not described.
        -- ORA-20001: the object is not exist.
        PRAGMA              EXCEPTION_INIT( IEM_TAG_PROC_NOT_EXIST, -20001 );
        PRAGMA              EXCEPTION_INIT( IEM_TAG_PROC_NOT_EXIST_PACK, -06564 );
        PRAGMA              EXCEPTION_INIT( IEM_TAG_PROC_NOT_EXIST_PACK_1, -06508 );
        PRAGMA              EXCEPTION_INIT( IEM_TAG_PROC_INVALID, -20003 );
        PRAGMA              EXCEPTION_INIT( IEM_TAG_PROC_INVALID, -10036 );
        PRAGMA              EXCEPTION_INIT( IEM_TAG_PROC_SYNTAX_ERR, -20004 );

        -- Errorcode and errorText
        v_ErrorCode     NUMBER;
        v_ErrorText     VARCHAR2(200);

    BEGIN
    --Standard Savepoint
    SAVEPOINT validProcedure;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API status return
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    if UPPER(p_ProcName) = UPPER('test') then
            raise IEM_TAG_PROC_WRONG_SIGNATURE ;
    end if;

    --Actual API starts here
        DBMS_DESCRIBE.DESCRIBE_PROCEDURE(
            p_ProcName,
            null,
            null,
            v_Overload,
            v_Position,
            v_Level,
            v_ArgumentName,
            v_Datatype,
            v_DefaultValue,
            v_InOut,
            v_Length,
            v_Precision,
            v_Scale,
            v_Radix,
            v_Spare );


       -- Valid signature of procedure. The corrrect procedure signature is
       -- procedure_name( key_value IN IEM_ROUTE_PUB.keyVals_tbl_type, result OUT VARCHAR2)
       IF (v_ArgumentName.count <> 6) THEN
            raise IEM_TAG_PROC_WRONG_SIGNATURE ;
       END IF;

        if v_Datatype(1) <> 251 then
            raise IEM_TAG_PROC_WRONG_SIGNATURE ;
        elsif v_Datatype(2) <> 250 then
            raise IEM_TAG_PROC_WRONG_SIGNATURE ;
        elsif v_Datatype(3) <> 1 then
            raise IEM_TAG_PROC_WRONG_SIGNATURE ;
        elsif v_Datatype(4) <> 1 then
            raise IEM_TAG_PROC_WRONG_SIGNATURE ;
        elsif v_Datatype(5) <> 1 then
            raise IEM_TAG_PROC_WRONG_SIGNATURE ;
        elsif v_Datatype(6) <> 1 then
            raise IEM_TAG_PROC_WRONG_SIGNATURE ;
        end if;

    EXCEPTION
       WHEN IEM_TAG_PROC_INVALID THEN
        ROLLBACK TO validProcedure;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_TAG_PROC_INVALID');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

       WHEN IEM_TAG_PROC_NOT_EXIST THEN
        ROLLBACK TO validProcedure;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_TAG_PROC_NOT_EXIST');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

       WHEN IEM_TAG_PROC_NOT_EXIST_PACK THEN
        ROLLBACK TO validProcedure;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_TAG_PROC_NOT_EXIST');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_TAG_PROC_SYNTAX_ERR THEN
        ROLLBACK TO validProcedure;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_TAG_PROC_SYNTAX_ERR');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN IEM_TAG_PROC_NOT_EXIST_PACK_1 THEN
        ROLLBACK TO validProcedure;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_TAG_PROC_NOT_EXIST');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN IEM_TAG_PROC_INVALID_1 THEN
        ROLLBACK TO validProcedure;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_TAG_PROC_INVALID');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN IEM_TAG_PROC_WRONG_SIGNATURE THEN
        ROLLBACK TO validProcedure;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_TAG_PROC_WRONG_SIGNATURE');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

       WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO validProcedure;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO validProcedure;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


     WHEN OTHERS THEN
	   ROLLBACK TO validProcedure;
        x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);
   END;



 PROCEDURE run_Procedure (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
		    	 p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
            	 p_procedure_name      IN   VARCHAR2,
  				 p_key_value   	       IN   IEM_TAGPROCESS_PUB.keyVals_tbl_type,
                 x_result              OUT NOCOPY  VARCHAR2,
                 x_return_status	   OUT NOCOPY  VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY	NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY	VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='run_Procedure';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    l_proc_name             VARCHAR2(256);
    l_ProcCall              VARCHAR2(500);
    l_result                VARCHAR2(256) := null;

    l_Cursor                NUMBER;
    l_NumRows               NUMBER;
    l_para_out_name         VARCHAR2(500);

    l_IEM_INVALID_PROCEDURE     EXCEPTION;
    logMessage              VARCHAR2(2000);
   -- l_error_text        varchar2(2000);
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		run_Procedure_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
  				    p_api_version_number,
  				    l_api_name,
  				    G_PKG_NAME)
  THEN
  	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Actual API begins here

    -- Valid procedure first
    l_proc_name := LTRIM(RTRIM(p_procedure_name));

    IF l_proc_name is NOT NULL THEN

        IEM_TAG_RUN_PROC_PVT.validProcedure(
                p_api_version_number  => P_Api_Version_Number,
		  	     p_init_msg_list       => FND_API.G_FALSE,
		    	 p_commit              => P_Commit,
                 p_ProcName            => l_proc_name,
                 x_return_status       => l_return_status,
		  	     x_msg_count           => l_msg_count,
	  	  	     x_msg_data            => l_msg_data
			 );
        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise l_IEM_INVALID_PROCEDURE;
        end if;

    END IF;

    -- Populate the key-value glabe variable
    G_key_value.delete;

    for i in 1..p_key_value.count loop
        G_key_value(i).key := p_key_value(i).key;
        G_key_value(i).value := p_key_value(i).value;
        G_key_value(i).datatype := p_key_value(i).datatype;
    end loop;

    -- Get the name of the OUT parameter
    if v_ArgumentName(6) is not null then
        l_para_out_name := v_ArgumentName(6);
    end if;

    l_ProcCall := 'Begin '|| l_proc_name || '(IEM_TAG_RUN_PROC_PVT.G_key_value, :' ||l_para_out_name||'); END;';

    --Open the cursor and parse the statement.
    l_Cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_Cursor, l_ProcCall, DBMS_SQL.native);

    DBMS_SQL.BIND_VARIABLE(l_Cursor,l_para_out_name,
                                    l_result, 500);

    --Execute the procedure.
    l_NumRows := DBMS_SQL.EXECUTE(l_Cursor);

    DBMS_SQL.VARIABLE_VALUE(l_Cursor, l_para_out_name, l_result);

    x_result := l_result;

    DBMS_SQL.close_cursor( l_Cursor );

    -- Standard Check Of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

    -- Standard callto get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
              p_data  =>  x_msg_data
			);

EXCEPTION
    WHEN l_IEM_INVALID_PROCEDURE THEN
	 ROLLBACK TO run_Procedure_PVT;

     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        		logMessage := '[Invalid procedure: ' || l_proc_name|| ']';
		        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAG_RUNPROC_PVT.RUN_PROCEDURE', logMessage);
	 end if;
     x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO run_Procedure_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  => x_msg_data
			);
        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        		logMessage := '[FND_API.G_EXC_ERROR happened in RUN_PROCEDURE - ' || l_proc_name|| ' error:'||sqlerrm||']';
		        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAG_RUNPROC_PVT.RUN_PROCEDURE', logMessage);
	    end if;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO run_Procedure_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);
        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        		logMessage := '[FND_API.G_EXC_UNEXPECTED_ERROR happened in RUN_PROCEDURE - ' || l_proc_name|| ' error:'||sqlerrm||']';
		        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAG_RUNPROC_PVT.RUN_PROCEDURE', logMessage);
	    end if;
   WHEN OTHERS THEN
    	ROLLBACK TO run_Procedure_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF 	FND_MSG_PUB.Check_Msg_Level
    			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    	THEN
        	FND_MSG_PUB.Add_Exc_Msg
    	    	(	G_PKG_NAME ,
    	    		l_api_name
    	    	);
    	END IF;

    	FND_MSG_PUB.Count_And_Get
        		( p_count         	=>      x_msg_count,
            	p_data          	=>      x_msg_data
        		);


        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        		logMessage := '[OTHER exception happened in RUN_PROCEDURE - ' || l_proc_name|| ' error:'||sqlerrm||']';
		        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAG_RUNPROC_PVT.RUN_PROCEDURE', logMessage);
	    end if;
       -- dbms_output.put_line('Exception in Run Procedure happened ' || SUBSTR (SQLERRM , 1 , 100));
 END run_Procedure;



 procedure dummy_procedure( key_value IN IEM_TAGPROCESS_PUB.keyVals_tbl_type,
                               result OUT NOCOPY VARCHAR2)
    is
    begin
        /*
        for i in 1..key_value.count loop
            dbms_output.put_line('Key is : ' ||key_value(i).key);
            dbms_output.put_line('Value is : ' ||key_value(i).value);
            dbms_output.put_line('Type is : ' ||key_value(i).datatype);
        end loop;
        */
    result := 'SUCCESS!';

 exception
    when others then
    null;
 end;

  procedure dummy_procedure2( key_value IN IEM_TAGPROCESS_PUB.keyVals_tbl_type,
                               result OUT NOCOPY VARCHAR2)
    is
    begin
    /*
        for i in 1..key_value.count loop
            dbms_output.put_line('Key is : ' ||key_value(i).key);
            dbms_output.put_line('Value is : ' ||key_value(i).value);
            dbms_output.put_line('Type is : ' ||key_value(i).datatype);
        end loop;
    */
    result := 'SUCCESS2 454325324!';

 exception
    when others then
    null;
 end;
END IEM_TAG_RUN_PROC_PVT;

/
