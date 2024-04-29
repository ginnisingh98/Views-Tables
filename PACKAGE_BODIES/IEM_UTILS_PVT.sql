--------------------------------------------------------
--  DDL for Package Body IEM_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_UTILS_PVT" as
/* $Header: iemputib.pls 120.0 2005/06/02 13:43:23 appldev noship $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_UTILS_PVT ';

PROCEDURE IEM_EncryptPassword(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2,
        P_Commit    			  IN VARCHAR2,
        p_raw_data	              IN VARCHAR2,
        x_encrypted_data	      OUT NOCOPY  VARCHAR2,
	x_encrypted_key		      OUT NOCOPY  VARCHAR2,
        x_msg_count   		      OUT NOCOPY  NUMBER,
        x_return_status  		  OUT NOCOPY  VARCHAR2,
        x_msg_data   			  OUT NOCOPY  VARCHAR2)

IS
    l_api_name              VARCHAR2(255):='IEM_EncryptPassword';
    l_api_version_number    NUMBER:=1.0;

    l_length                NUMBER:=0;
    l_exts_length           NUMBER:=0;
    l_raw_data              VARCHAR2(200);
    l_random_key		    VARCHAR2(100);

    IEM_PASSWORD_NULL        EXCEPTION;
    IEM_DOUBLE_ENCRIPTED     EXCEPTION;

    PRAGMA              EXCEPTION_INIT( IEM_PASSWORD_NULL, -28231 );
    PRAGMA              EXCEPTION_INIT( IEM_DOUBLE_ENCRIPTED, -28233 );

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT IEM_EncryptPassword_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
           p_api_version_number,
           l_api_name,
           G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API begins

    l_raw_data := RTRIM(LTRIM(p_raw_data));


    IF l_raw_data is null THEN
        RAISE IEM_PASSWORD_NULL;
    END IF;

    -- Normalize input raw data
    select MOD(length(l_raw_data),8) into l_length from dual;

    IF l_length <> 0 THEN
        WHILE l_length < 8 LOOP
            l_raw_data := l_raw_data||' ';
            l_length := l_length + 1;
        END LOOP;
    END IF;

    -- randomly generated encrypted key
	l_random_key := TO_CHAR( ABS(DBMS_RANDOM.Random) );

	x_encrypted_key := l_random_key;

    dbms_obfuscation_toolkit.DESEncrypt(
               input_string => l_raw_data,
               key_string => l_random_key,
               encrypted_string => x_encrypted_data );

     -- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

    -- Standard callto get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
			);

EXCEPTION
    WHEN IEM_PASSWORD_NULL THEN
        ROLLBACK TO IEM_EncryptPassword_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_PASSWORD_NULL');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get( p_count =>      x_msg_count,
                                  p_data  =>      x_msg_data );

    WHEN IEM_DOUBLE_ENCRIPTED THEN
        ROLLBACK TO IEM_EncryptPassword_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_DOUBLE_ENCRIPTED');

        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO IEM_EncryptPassword_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get( p_count =>      x_msg_count,
                                  p_data  =>      x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO IEM_EncryptPassword_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get( p_count =>      x_msg_count,
                                  p_data  =>      x_msg_data );

    WHEN OTHERS THEN
        ROLLBACK TO IEM_EncryptPassword_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME, l_api_name);
        END IF;

        FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                p_data => x_msg_data
            );
END IEM_EncryptPassword;




PROCEDURE IEM_DecryptPassword(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2,
        P_Commit    			  IN VARCHAR2,
        p_input_data              IN VARCHAR2,
	p_decrypted_key              IN VARCHAR2,
        x_decrypted_data  	      OUT NOCOPY  VARCHAR2,
        x_msg_count   		      OUT NOCOPY  NUMBER,
        x_return_status  		  OUT NOCOPY  VARCHAR2,
        x_msg_data   			  OUT NOCOPY  VARCHAR2)

IS
    l_api_name              VARCHAR2(255):='DecryptPassword';
    l_api_version_number    NUMBER:=1.0;

    l_decrypted_data        VARCHAR2(200);

    IEM_PASSWORD_NULL        EXCEPTION;
    IEM_INVALID_INPUT        EXCEPTION; -- not a multiple of 8 bytes

    PRAGMA              EXCEPTION_INIT( IEM_PASSWORD_NULL, -28231 );
    PRAGMA              EXCEPTION_INIT( IEM_INVALID_INPUT, -28232 );

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT IEM_DecryptPassword_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
           p_api_version_number,
           l_api_name,
           G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Decrypt the data
    dbms_obfuscation_toolkit.DESDecrypt(
               input_string => p_input_data,
               key_string => p_decrypted_key,
               decrypted_string => l_decrypted_data );


    -- Normalize output
    x_decrypted_data := RTRIM(LTRIM(l_decrypted_data));

    -- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

    -- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
			);

EXCEPTION
    WHEN IEM_PASSWORD_NULL THEN
        ROLLBACK TO IEM_DecryptPassword_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_PASSWORD_NULL');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get( p_count =>      x_msg_count,
                                  p_data  =>      x_msg_data );

    WHEN IEM_INVALID_INPUT THEN
        ROLLBACK TO IEM_DecryptPassword_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_INVALID_INPUT');

        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO IEM_DecryptPassword_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get( p_count =>      x_msg_count,
                                  p_data  =>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO IEM_DecryptPassword_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get( p_count =>      x_msg_count,
                               p_data  =>      x_msg_data );

    WHEN OTHERS THEN

        ROLLBACK TO IEM_DecryptPassword_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME, l_api_name);
        END IF;

        FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                p_data => x_msg_data
            );
    END IEM_DecryptPassword;

--transfer string containing elements seperated by ; to table
 FUNCTION varchar_to_table ( inString    IN   VARCHAR2 )
        return jtf_varchar2_Table_100
       is
    l_indx number:=0;
   l_temp varchar2(200);
    l_rem varchar2(2000);
    l_table jtf_varchar2_Table_100:=jtf_varchar2_Table_100();
    i BINARY_INTEGER :=1;
 BEGIN
    l_rem := inString ;

    loop
        l_indx := INSTR(l_rem, ';');
        if (l_indx <> 0)then
            l_temp := SUBSTR( l_rem, 1, l_indx-1 );
            l_rem := SUBSTR( l_rem, l_indx+1);
            l_table.extend;
            l_table(i) := l_temp;
            i := i + 1;
        else
            exit;
        end if;
    end loop;

    return l_table;

END    varchar_to_table;

END IEM_UTILS_PVT;

/
