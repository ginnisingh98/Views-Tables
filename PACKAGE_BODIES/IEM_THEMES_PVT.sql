--------------------------------------------------------
--  DDL for Package Body IEM_THEMES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_THEMES_PVT" as
/* $Header: iemptheb.pls 115.14 2003/08/26 23:42:00 sboorela shipped $*/
/* Fixed Bug 1339163 kbeagle on 11/29/00 Dup theme error when updating score */
/* 	08/14/01     chtang  added create_item_wrap_sss() for 11.5.6         */
/* 	05/07/02     chtang  added update last_update_date of keyword in calculate_weight */
/*      10/15/02     chtang  added update last_update_date of intent in calculate_weight */
/*****************************************************************************/
G_PKG_NAME CONSTANT varchar2(30) :='IEM_THEMES_PVT ';


PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				 p_score IN   NUMBER,
  				 p_classification_id	IN   NUMBER,
		           p_theme IN VARCHAR2,
		           p_query_response  IN VARCHAR2,
			p_CREATED_BY  IN  NUMBER,
          	p_CREATION_DATE  IN  DATE,
         		p_LAST_UPDATED_BY  IN  NUMBER ,
          	p_LAST_UPDATE_DATE  IN  DATE,
          	p_LAST_UPDATE_LOGIN  IN  NUMBER ,
         		p_ATTRIBUTE1   IN VARCHAR2,
          	p_ATTRIBUTE2   IN VARCHAR2,
          	p_ATTRIBUTE3   IN VARCHAR2,
          	p_ATTRIBUTE4   IN VARCHAR2,
          	p_ATTRIBUTE5   IN VARCHAR2,
          	p_ATTRIBUTE6   IN VARCHAR2,
          	p_ATTRIBUTE7   IN VARCHAR2,
          	p_ATTRIBUTE8   IN VARCHAR2,
          	p_ATTRIBUTE9   IN VARCHAR2,
          	p_ATTRIBUTE10  IN  VARCHAR2,
          	p_ATTRIBUTE11  IN  VARCHAR2,
          	p_ATTRIBUTE12  IN  VARCHAR2,
          	p_ATTRIBUTE13  IN  VARCHAR2,
          	p_ATTRIBUTE14  IN  VARCHAR2,
          	p_ATTRIBUTE15  IN  VARCHAR2,
		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2
			 ) is

	l_api_name        		VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;

	l_cnt 	NUMBER;
	l_seq_id 	NUMBER;

BEGIN
-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Take this out. Handle duplicates in the exception block.
   SELECT COUNT(*) INTO l_cnt from IEM_THEMES WHERE classification_id=p_classification_id
   and theme=p_theme and query_response=p_query_response;

   IF l_cnt=0 THEN
     SELECT iem_themes_s1.nextval
     INTO l_seq_id
     FROM dual;
     INSERT INTO iem_themes (theme_id,
                    classification_id,
                    theme,
				score,
				query_response,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date,
				last_update_login,
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
				ATTRIBUTE15
				)
			values (l_seq_id,
				p_classification_id,
				p_theme,
				p_score,
				p_query_response,
			decode(p_CREATED_BY,null,-1,p_CREATED_BY),
			sysdate,
			decode(p_LAST_UPDATED_BY,null,-1,p_LAST_UPDATED_BY),
			sysdate,
			decode(p_LAST_UPDATE_LOGIN,null,-1,p_LAST_UPDATE_LOGIN),
			p_ATTRIBUTE1,
			p_ATTRIBUTE2,
			p_ATTRIBUTE3,
			p_ATTRIBUTE4,
			p_ATTRIBUTE5,
			p_ATTRIBUTE6,
			p_ATTRIBUTE7,
			p_ATTRIBUTE8,
			p_ATTRIBUTE9,
			p_ATTRIBUTE10,
			p_ATTRIBUTE11,
			p_ATTRIBUTE12,
			p_ATTRIBUTE13,
			p_ATTRIBUTE14,
			p_ATTRIBUTE15);
  END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END;

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_theme_id	IN   NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='delete_item';
	l_api_version_number 	NUMBER:=1.0;
	l_grp_cnt 	NUMBER;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		delete_item_PVT;
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

   DELETE FROM IEM_THEMES WHERE THEME_ID = p_theme_id;

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
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO delete_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO delete_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO delete_item_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);
 END;

 PROCEDURE update_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_theme_id IN NUMBER,
				 p_classification_id	IN   NUMBER,
		           p_theme IN VARCHAR2 ,
				 p_score IN NUMBER,
		           p_query_response  IN VARCHAR2,
         		p_LAST_UPDATED_BY  IN  NUMBER ,
          	p_LAST_UPDATE_DATE  IN  DATE,
          	p_LAST_UPDATE_LOGIN  IN  NUMBER ,
         		p_ATTRIBUTE1   IN VARCHAR2,
          	p_ATTRIBUTE2   IN VARCHAR2,
          	p_ATTRIBUTE3   IN VARCHAR2,
          	p_ATTRIBUTE4   IN VARCHAR2,
          	p_ATTRIBUTE5   IN VARCHAR2,
          	p_ATTRIBUTE6   IN VARCHAR2,
          	p_ATTRIBUTE7   IN VARCHAR2,
          	p_ATTRIBUTE8   IN VARCHAR2,
          	p_ATTRIBUTE9   IN VARCHAR2,
          	p_ATTRIBUTE10  IN  VARCHAR2,
          	p_ATTRIBUTE11  IN  VARCHAR2,
          	p_ATTRIBUTE12  IN  VARCHAR2,
          	p_ATTRIBUTE13  IN  VARCHAR2,
          	p_ATTRIBUTE14  IN  VARCHAR2,
          	p_ATTRIBUTE15  IN  VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) IS

	l_api_name        		VARCHAR2(255):='update_item';
	l_api_version_number 	NUMBER:=1.0;
	l_status				varchar2(10);

	l_grp_cnt 	NUMBER;

     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_DATE    DATE:=SYSDATE;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;

	IEM_DUPLICATE_THEME EXCEPTION;
	PRAGMA EXCEPTION_INIT(IEM_DUPLICATE_THEME, -00001);

BEGIN
-- Standard Start of API savepoint
   SAVEPOINT		update_item_PVT;
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

   update IEM_THEMES SET
   classification_id = decode( p_classification_id, FND_API.G_MISS_NUM,null,null, classification_id, p_classification_id),
   theme =  decode(p_theme,FND_API.G_MISS_CHAR,null,null,theme,p_theme),
   score =  decode(p_score,FND_API.G_MISS_CHAR,null,null,score,p_score),
   query_response = decode( p_query_response, FND_API.G_MISS_CHAR,null,null, query_response, p_query_response),
          LAST_UPDATE_DATE = sysdate,
         LAST_UPDATED_BY = decode(l_LAST_UPDATED_BY, null,last_updated_by,l_LAST_UPDATED_BY),
      LAST_UPDATE_LOGIN = decode( l_LAST_UPDATE_LOGIN,null,last_update_login,l_LAST_UPDATE_LOGIN),
            ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, null,null,ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR,null,null, ATTRIBUTE15, p_ATTRIBUTE15)
   where theme_id = p_theme_id;
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
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN IEM_DUPLICATE_THEME THEN
     ROLLBACK TO update_item_PVT;
     FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_THEME');
     x_return_status := FND_API.G_RET_STS_ERROR;
	/*
     IF   FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
	*/
     FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN OTHERS THEN
	ROLLBACK TO update_item_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);

 END;


/**************WRPR******************/
PROCEDURE create_item_wrap (p_api_version_number    IN   NUMBER,
 	  	      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
                p_score IN   NUMBER,
                p_classification_id     IN   NUMBER,
                p_theme IN VARCHAR2,
                p_query_response  IN VARCHAR2,
              p_CREATED_BY    NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2,
  		      x_msg_count	      OUT NOCOPY NUMBER,
                x_msg_data    OUT NOCOPY  VARCHAR2
           ) is
	l_api_name     VARCHAR2(255):='create_item_jsp';
	l_api_version_number 	NUMBER:=1.0;
	l_grp_cnt 	NUMBER;
	l_cnt		number;
     l_theme VARCHAR2(100);
     l_theme2 VARCHAR2(100);

	IEM_DUPLICATE_THEME EXCEPTION;

BEGIN
  SAVEPOINT	create_item_jsp;
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
  THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

   select replace (replace ( replace (p_theme, '<', ''), '>', ''), '"', '''') into l_theme
   from dual;

   l_theme2 := rtrim(ltrim(l_theme, ' '), ' ');

-- Take this out. Handle duplicates in the exception block.
   SELECT COUNT(*) INTO l_cnt from IEM_THEMES WHERE classification_id=p_classification_id
   and theme=p_theme and query_response=p_query_response;

  IF (l_cnt > 0 ) then
	 raise IEM_DUPLICATE_THEME;
  end if;

   IEM_THEMES_PVT.create_item(
                             p_api_version_number =>p_api_version_number,
                             p_init_msg_list => p_init_msg_list,
                             p_commit => p_commit,
                             p_score => p_score,
                             p_classification_id => p_classification_id ,
                             p_theme => l_theme2 ,
                             p_query_response => p_query_response,
	p_CREATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_CREATION_DATE  =>SYSDATE,
    	p_LAST_UPDATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_LAST_UPDATE_DATE  =>SYSDATE,
    	p_LAST_UPDATE_LOGIN=>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ,
    	p_ATTRIBUTE1   =>null,
    	p_ATTRIBUTE2   =>null,
    	p_ATTRIBUTE3   =>null,
    	p_ATTRIBUTE4   =>null,
    	p_ATTRIBUTE5   =>null,
    	p_ATTRIBUTE6   =>null,
    	p_ATTRIBUTE7   =>null,
    	p_ATTRIBUTE8   =>null,
    	p_ATTRIBUTE9   =>null,
    	p_ATTRIBUTE10  =>null,
    	p_ATTRIBUTE11  =>null,
    	p_ATTRIBUTE12  =>null,
    	p_ATTRIBUTE13  =>null,
    	p_ATTRIBUTE14  =>null,
    	p_ATTRIBUTE15  =>null,
                             x_return_status =>x_return_status,
                             x_msg_count   => x_msg_count,
                             x_msg_data => x_msg_data);

     IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
     END IF;

     FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN IEM_DUPLICATE_THEME THEN
      ROLLBACK TO create_item_jsp;
      FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_THEME');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_item_jsp;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_item_jsp;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO create_item_jsp;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);

end;

PROCEDURE create_item_wrap_sss (p_api_version_number    IN   NUMBER,
 	  	      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
                p_score IN   NUMBER,
                p_classification_id     IN   NUMBER,
                p_theme IN VARCHAR2,
                p_query_response  IN VARCHAR2,
              p_CREATED_BY    NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2,
  		      x_msg_count	      OUT NOCOPY NUMBER,
	  	      x_msg_data OUT NOCOPY VARCHAR2
           ) is
	l_api_name     VARCHAR2(255):='create_item_jsp';
	l_api_version_number 	NUMBER:=1.0;
	l_grp_cnt 	NUMBER;
	l_cnt		number;
     l_theme VARCHAR2(100);
     l_theme2 VARCHAR2(100);

	IEM_DUPLICATE_THEME EXCEPTION;

BEGIN
  SAVEPOINT	create_item_jsp;
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
  THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

   select replace (replace ( replace (p_theme, '<', ''), '>', ''), '"', '''') into l_theme
   from dual;

   l_theme2 := rtrim(ltrim(l_theme, ' '), ' ');

-- Take this out. Handle duplicates in the exception block.
   SELECT COUNT(*) INTO l_cnt from IEM_THEMES WHERE classification_id=p_classification_id
   and theme=p_theme and query_response=p_query_response;

  IF (l_cnt > 0 ) then
	 raise IEM_DUPLICATE_THEME;
  end if;

   IEM_THEMES_PVT.create_item(
                             p_api_version_number =>p_api_version_number,
                             p_init_msg_list => p_init_msg_list,
                             p_commit => p_commit,
                             p_score => p_score,
                             p_classification_id => p_classification_id ,
                             p_theme => l_theme2 ,
                             p_query_response => p_query_response,
	p_CREATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_CREATION_DATE  =>SYSDATE,
    	p_LAST_UPDATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_LAST_UPDATE_DATE  =>SYSDATE,
    	p_LAST_UPDATE_LOGIN=>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ,
    	p_ATTRIBUTE1   =>null,
    	p_ATTRIBUTE2   =>null,
    	p_ATTRIBUTE3   =>null,
    	p_ATTRIBUTE4   =>null,
    	p_ATTRIBUTE5   =>null,
    	p_ATTRIBUTE6   =>null,
    	p_ATTRIBUTE7   =>null,
    	p_ATTRIBUTE8   =>null,
    	p_ATTRIBUTE9   =>null,
    	p_ATTRIBUTE10  =>null,
    	p_ATTRIBUTE11  =>null,
    	p_ATTRIBUTE12  =>null,
    	p_ATTRIBUTE13  =>null,
    	p_ATTRIBUTE14  =>null,
    	p_ATTRIBUTE15  =>null,
                             x_return_status =>x_return_status,
                             x_msg_count   => x_msg_count,
                             x_msg_data => x_msg_data);

     IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
     END IF;

     FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN IEM_DUPLICATE_THEME THEN
      ROLLBACK TO create_item_jsp;
      FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_KEYWORD');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_item_jsp;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_item_jsp;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO create_item_jsp;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);

end;

PROCEDURE delete_item_wrap
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 ,
      p_commit          IN  VARCHAR2 ,
      p_thes_ids_tbl    IN  jtf_varchar2_Table_100,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2)
 IS
    i       INTEGER;
    l_api_name		varchar2(30):='delete_item_batch';
    l_api_version_number number:=1.0;
BEGIN

    --Standard Savepoint
    SAVEPOINT delete_item_wrap;
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

    --Actual API starts here
    FORALL i IN p_thes_ids_tbl.FIRST..p_thes_ids_tbl.LAST
        DELETE
        FROM IEM_THEMES
        WHERE theme_id = p_thes_ids_tbl(i);

    IF SQL%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('IEM', 'IEM_EXP_INVALID_ACCOUNT');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO delete_item_wrap;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO delete_item_wrap;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO delete_item_wrap;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);
    --Standard call to get message count and message info
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data => x_msg_data);
END delete_item_wrap;
PROCEDURE delete_item_wrap_sss
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 ,
      p_commit          IN  VARCHAR2 ,
      p_thes_ids_tbl    IN  jtf_varchar2_Table_100,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2)
 IS
    i       INTEGER;
    l_api_name		varchar2(30):='delete_item_batch';
    l_api_version_number number:=1.0;
    l_status		varchar2(10);
    l_class_id		number;
    l_email_account_id		number;
BEGIN

    --Standard Savepoint
    SAVEPOINT delete_item_wrap;
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

    --Actual API starts here
  FOR j in p_thes_ids_tbl.FIRST..p_thes_ids_tbl.LAST LOOP
    select classification_id into l_class_id
    from iem_themes
    where theme_id=p_thes_ids_tbl(j);
    EXIT;
  END LOOP;
    FORALL i IN p_thes_ids_tbl.FIRST..p_thes_ids_tbl.LAST
        DELETE
        FROM IEM_THEMES
        WHERE theme_id = p_thes_ids_tbl(i);
	-- Score Readjustment using noise reduction algorithim
	delete from iem_theme_docs where theme_id not in
	(select theme_id from iem_themes);
	delete from iem_account_intent_docs where account_intent_doc_id
	not in (select account_intent_doc_id from iem_theme_docs);
		select email_account_id into l_email_account_id
		from iem_classifications
		where classification_id=l_class_id;
iem_themes_pvt.calculate_weight (l_email_account_id,
		      'Q'  ,
		  	l_status	);
iem_themes_pvt.calculate_weight (l_email_account_id,
		      'R'  ,
		  	l_status	);

    IF SQL%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('IEM', 'IEM_EXP_INVALID_ACCOUNT');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO delete_item_wrap;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO delete_item_wrap;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO delete_item_wrap;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);
    --Standard call to get message count and message info
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data => x_msg_data);
END delete_item_wrap_sss;

PROCEDURE update_item_wrap (p_api_version_number    IN   NUMBER,
 		      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
                p_theme_id IN NUMBER,
                p_classification_id     IN   NUMBER,
                p_theme IN VARCHAR2 ,
                p_score IN NUMBER,
                p_query_response  IN VARCHAR2,
			 x_return_status OUT NOCOPY VARCHAR2,
  		  	 x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	 x_msg_data OUT NOCOPY VARCHAR2
			 )is
	l_api_name        		VARCHAR2(255):='update_item';
     l_cnt NUMBER := 0;
	l_api_version_number 	NUMBER:=1.0;
	l_grp_cnt 	NUMBER;
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_DATE    DATE:=SYSDATE;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;
     l_theme VARCHAR2(100);
     l_theme2 VARCHAR2(100);
     IEM_DUPLICATE_THEME EXCEPTION;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		update_item_PVT;
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

  select replace (replace ( replace (p_theme, '<', ''), '>', ''), '"', '''') into l_theme
	from dual;

 l_theme2 := rtrim(ltrim(l_theme, ' '), ' ');

  -- kbeagle 12-29-00 Added 'and NOT theme_id=p_theme_id' fix for bug 1339163

  SELECT COUNT(*) INTO l_cnt from IEM_THEMES WHERE classification_id=p_classification_id and theme=l_theme2 and query_response=p_query_response and NOT theme_id=p_theme_id;
  IF (l_cnt > 0 ) then
	raise IEM_DUPLICATE_THEME;
  end if;
 IEM_THEMES_PVT.update_item(
                           p_api_version_number =>p_api_version_number,
                           p_init_msg_list => p_init_msg_list,
                           p_commit => p_commit,
                           p_theme_id => p_theme_id,
                           p_classification_id  => p_classification_id,
                           p_theme => l_theme2,
                           p_score => p_score,
                           p_query_response => p_query_response,
    	p_LAST_UPDATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_LAST_UPDATE_DATE  =>SYSDATE,
    	p_LAST_UPDATE_LOGIN=>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ,
    	p_ATTRIBUTE1   =>null,
    	p_ATTRIBUTE2   =>null,
    	p_ATTRIBUTE3   =>null,
    	p_ATTRIBUTE4   =>null,
    	p_ATTRIBUTE5   =>null,
    	p_ATTRIBUTE6   =>null,
    	p_ATTRIBUTE7   =>null,
    	p_ATTRIBUTE8   =>null,
    	p_ATTRIBUTE9   =>null,
    	p_ATTRIBUTE10  =>null,
    	p_ATTRIBUTE11  =>null,
    	p_ATTRIBUTE12  =>null,
    	p_ATTRIBUTE13  =>null,
    	p_ATTRIBUTE14  =>null,
    	p_ATTRIBUTE15  =>null,
                           x_return_status =>x_return_status,
                           x_msg_count   => x_msg_count,
                           x_msg_data => x_msg_data);


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
   WHEN IEM_DUPLICATE_THEME THEN
      ROLLBACK TO update_item_PVT;
      FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_THEME');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO update_item_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);
 END;
/**************************************************************/
PROCEDURE create_item_pm (p_score IN   NUMBER,
  				 p_classification_id	IN   NUMBER,
		           p_theme IN VARCHAR2,
		           p_query_response  IN VARCHAR2,
				 p_doc_seq_no   IN NUMBER,
               p_CREATED_BY    NUMBER,
               p_CREATION_DATE    DATE,
               p_LAST_UPDATED_BY    NUMBER,
               p_LAST_UPDATE_DATE    DATE,
               p_LAST_UPDATE_LOGIN    NUMBER,
		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2) IS

	l_cnt 	NUMBER;
	l_seq_id 	NUMBER;
l_N				number;	--Total no of document in the system
l_R				number;	-- Total no of document in the bin
l_Nt				number;	-- No of relevant doc in the system
l_Rt				number;	-- No of relevant doc in the bin
l_doc_count		number;
l_weight			number;
l_temp			number;
l_email_account_id	number;
l_status			varchar2(10);
l_theme_id		number;
DOC_EXCEP           EXCEPTION;
	BEGIN
	x_return_status:='S';

	select nvl(sum(doc_count),0)+1 into l_cnt
	from iem_themes
	where query_response=p_query_response
	and classification_id=p_classification_id
	and theme=p_theme;
	select email_account_id into l_email_account_id
	from iem_classifications
	where classification_id=p_classification_id;
 IF l_cnt=1 THEN
     SELECT iem_themes_s1.nextval
     INTO l_seq_id
     FROM dual;
     INSERT INTO iem_themes (theme_id,
                    classification_id,
                    theme,
				score,
				query_response,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date,
				last_update_login,
				doc_count)
		VALUES
				(l_seq_id,
				p_classification_id,
				p_theme,
				0,
				p_query_response,
     			p_created_by,
				p_CREATION_DATE,
     			p_LAST_UPDATED_BY,
     			p_LAST_UPDATE_DATE,
     			p_LAST_UPDATE_LOGIN,
				l_cnt);
	     IEM_THEME_DOCS_PVT.create_item(p_account_intent_doc_id=>p_doc_seq_no ,
								 p_theme_id=>l_seq_id ,
		      					 x_return_status=>l_status);
		IF l_status='E' THEN
			raise DOC_EXCEP;
		END IF;
	ELSE
			update iem_themes
			set doc_count=l_cnt
			where query_response=p_query_response
			and classification_id=p_classification_id
			and theme=p_theme;
		select theme_id into l_theme_id
		from iem_themes
		where query_response=p_query_response
		and classification_id=p_classification_id
		and theme=p_theme;
	     IEM_THEME_DOCS_PVT.create_item(p_account_intent_doc_id=>p_doc_seq_no ,
								 p_theme_id=>l_theme_id ,
		      					 x_return_status=>l_status);
		IF l_status='E' THEN
			raise DOC_EXCEP;
		END IF;
	END IF;
	-- Recalculation of Theme Weight
iem_themes_pvt.calculate_weight (l_email_account_id,
		      p_query_response  ,
		  	l_status	);
			x_return_status:=l_status;
	EXCEPTION WHEN DOC_EXCEP THEN
		x_return_status:='E';
	WHEN OTHERS THEN
		x_return_status:='E';
	END;
PROCEDURE calculate_weight (p_email_account_id	IN   NUMBER,
		           		p_query_response  IN VARCHAR2,
		  				x_return_status OUT NOCOPY VARCHAR2) IS

l_N				number;	--Total no of document in the system
l_R				number;	-- Total no of document in the bin
l_Nt				number;	-- No of relevant doc in the system
l_Rt				number;	-- No of relevant doc in the bin
l_doc_count		number;
l_weight			number;
l_temp			number;
l_rms			number;
l_class_id		number;
CURSOR c_theme is
		select a.theme_id,a.classification_id,
		a.theme,a.query_response,a.score
		from iem_themes a,iem_classifications b
		where a.classification_id=b.classification_id
		and b.email_account_id=p_email_account_id
		and a.query_response=p_query_response;

 cursor c1 is select a.classification_id,sum(power(a.score,2)) score
		from iem_themes a,iem_classifications b
		where a.classification_id=b.classification_id
		and b.email_account_id=p_email_account_id
		and a.query_response=p_query_response
		group by a.classification_id;

 cursor c_calc is select a.theme_id,a.score
		from iem_themes a,iem_classifications b
		where a.classification_id=b.classification_id
		and b.email_account_id=p_email_account_id
		and a.query_response=p_query_response
		and a.classification_id=l_class_id;
 BEGIN
	x_return_status:='S';
-- No of document in the system

--	select nvl(sum(document_no),0)
	select count(*)
	into l_N
	from iem_account_intent_docs
	where email_account_id=p_email_account_id
	and query_response=p_query_response;

 for v1 in c_theme LOOP

-- No of documents in the bin

--	select nvl(sum(document_no),0)
	select count(*)
	into l_R
	from iem_account_intent_docs
	where classification_id=v1.classification_id
	and query_response=v1.query_response;

-- no of document matching the theme in the system

	select nvl(sum(a.doc_count),0) into l_Nt
	from iem_themes A,iem_classifications B
	where A.classification_id=B.classification_id
	and B.email_account_id=p_email_account_id
	and A.query_response=v1.query_response
	and A.theme=v1.theme;

-- no of document matching the theme in the bin

	select nvl(sum(doc_count),0) into l_Rt
	from iem_themes
	where query_response=v1.query_response
	and classification_id=v1.classification_id
	and theme=v1.theme;

--	l_temp:=((l_Rt+0.5)/(l_Nt-l_Rt+0.5))*((l_N+.5)/(l_R+.5));
	l_temp:=((l_Rt+0.5)/(l_Nt-l_Rt+0.5))*((l_N-l_Nt-l_R+l_Rt+0.5)/(l_R-l_Rt+0.5));
	l_weight:=round(log(10,l_temp),2);
	update iem_themes
	set score=l_weight
	where theme_id=v1.theme_id;
END LOOP;
-- Normalised the score using RMS
	for v1 in c1 LOOP
		l_class_id:=v1.classification_id;
		update iem_classifications
		set last_update_date=sysdate
		where classification_id=v1.classification_id;
	for v2 in c_calc loop
		update iem_themes
		set score=round(v2.score/sqrt(v1.score),2),
		last_update_date=sysdate
		where theme_id=v2.theme_id;
	end loop;
	end loop;
-- End Of Normalised the score using RMS
EXCEPTION WHEN OTHERS THEN
	x_return_status:='E';
END;
END IEM_THEMES_PVT;

/
