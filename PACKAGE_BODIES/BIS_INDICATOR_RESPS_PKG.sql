--------------------------------------------------------
--  DDL for Package Body BIS_INDICATOR_RESPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_INDICATOR_RESPS_PKG" AS
/* $Header: BISINRSB.pls 115.8 2003/08/15 22:21:42 wleung noship $ */


PROCEDURE check_security_exists
( p_responsibility_id 	IN 	NUMBER
, p_target_level_id	IN 	NUMBER
, x_exists		OUT NOCOPY 	BOOLEAN
);


PROCEDURE resp_value_id_conversion
( p_responsibility_key	        IN      VARCHAR
, x_responsibility_id	        OUT NOCOPY     NUMBER
, x_return_status		OUT NOCOPY 	VARCHAR
, x_return_msg			OUT NOCOPY  	VARCHAR
) ;


PROCEDURE tgt_level_value_id_conversion
( p_target_level_short_name	IN  	VARCHAR
, x_target_level_id 		OUT NOCOPY 	NUMBER
, x_return_status		OUT NOCOPY 	VARCHAR
, x_return_msg			OUT NOCOPY	VARCHAR
);

  PROCEDURE Update_Row(
       x_indicator_resp_id   		in      number
      ,x_target_level_id		in	  number
      ,x_responsibility_id		in	  number
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
  );

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------



PROCEDURE Load_Row
( p_target_level_short_name     IN      VARCHAR
, p_responsibility_short_name   IN      VARCHAR
, p_created_by                  IN      NUMBER
, p_last_updated_by             IN      NUMBER
, p_owner			IN 	VARCHAR
, x_return_status		OUT NOCOPY 	VARCHAR
, x_return_msg			OUT NOCOPY  	VARCHAR
) IS

  l_responsibility_id 	NUMBER;
  l_target_level_id	NUMBER;
  l_row_id		VARCHAR2(30);
  l_return_status1	VARCHAR2(30);
  l_return_status2	VARCHAR2(30);
  l_return_msg1		fnd_new_messages.message_text%TYPE; -- VARCHAR2(2000);
  l_return_msg2		VARCHAR2(80);
  l_exists		BOOLEAN;
  l_indicator_resp_id	NUMBER;
  l_login_id		NUMBER;
  l_user_id		NUMBER;
  l_created_by          NUMBER;
  l_last_updated_by     NUMBER;
  -- l_temp_msg		VARCHAR2(100);
  l_error_msg		VARCHAR2(100);

BEGIN

						  			-- BIS_UTILITIES_PUB.put_line(p_text => ' inside load row 1 ' ) ;

  resp_value_id_conversion
  (  p_responsibility_key	=> p_responsibility_short_name
    ,x_responsibility_id	=> l_responsibility_id
    ,x_return_status		=> l_return_status1
    ,x_return_msg		=> l_return_msg1
  )  ;

  									-- BIS_UTILITIES_PUB.put_line(p_text => ' inside load row 1.1 ' || l_return_status1 ) ;

  tgt_level_value_id_conversion
  ( p_target_level_short_name	=> p_target_level_short_name
  , x_target_level_id 		=> l_target_level_id
  , x_return_status		=> l_return_status2
  , x_return_msg		=> l_return_msg2
  );

									-- BIS_UTILITIES_PUB.put_line(p_text => ' inside load row 1.2 ' ) ;

  IF ( (l_return_status1 = 'S') AND (l_return_status2 = 'S') ) THEN	-- BIS_UTILITIES_PUB.put_line(p_text => ' inside load row 2 ' ) ;

    /*
    SELECT BIS_INDICATOR_RESPS_S.nextval
    INTO l_indicator_resp_id
    FROM DUAL;
    */

    IF p_owner = BIS_UTILITIES_PUB.G_SEED_OWNER THEN
      l_user_id := BIS_UTILITIES_PUB.G_SEED_USER_ID;
    ELSE
      l_user_id := fnd_global.user_id;
    END IF;

    IF (p_created_by IS NULL) THEN
      l_created_by := l_user_id;
    ELSE
      l_created_by := p_created_by;
    END IF;

    IF (p_last_updated_by IS NULL) THEN
      l_last_updated_by := l_user_id;
    ELSE
      l_last_updated_by := p_last_updated_by;
    END IF;


    l_login_id := fnd_global.LOGIN_ID;


    check_security_exists
    ( p_responsibility_id 	=> l_responsibility_id
    , p_target_level_id		=> l_target_level_id
    , x_exists			=> l_exists
    );


    IF ( l_exists = FALSE ) THEN	-- BIS_UTILITIES_PUB.put_line(p_text => ' inside load row 3 ' ) ;

      Insert_Row
      (
       x_rowid			=> l_row_id
      ,x_indicator_resp_id	=> l_indicator_resp_id
      ,x_target_level_id	=> l_target_level_id
      ,x_responsibility_id	=> l_responsibility_id
      ,x_created_by       	=> l_created_by
      ,x_creation_date        	=> sysdate
      ,x_last_updated_by 	=> l_last_updated_by
      ,x_last_update_date       => sysdate
      ,x_last_update_login      => l_login_id
      );

      									-- BIS_UTILITIES_PUB.put_line(p_text => ' inside load row 3.1 ' ) ;

    ELSE

      									-- BIS_UTILITIES_PUB.put_line(p_text => ' inside load row 4 ' ) ;

      Update_Row(
       x_indicator_resp_id   	=> l_target_level_id
      ,x_target_level_id	=> l_target_level_id
      ,x_responsibility_id	=> l_responsibility_id
      ,x_last_updated_by 	=> l_last_updated_by
      ,x_last_update_date       => sysdate
      ,x_last_update_login      => l_login_id
      );

      									-- BIS_UTILITIES_PUB.put_line(p_text => ' inside load row 4.1 ' ) ;

    END IF;

  ELSE


    l_error_msg := substr(bis_utilities_pvt.Get_FND_Message (
    				  p_message_name   => 'BISPMF_SCRTY_UPLD_FAIL'
    				, p_msg_param1     => 'RESP_KEY'
    				, p_msg_param1_val =>  p_responsibility_short_name
    				, p_msg_param2     => 'SUM_LVL'
    				, p_msg_param2_val =>  p_target_level_short_name
    				                     ), 1, 100) ;

    BIS_UTILITIES_PUB.put_line(p_text => l_error_msg ) ;

  END IF;

  									-- BIS_UTILITIES_PUB.put_line(p_text => ' inside load row 5 ' ) ;

EXCEPTION

  WHEN OTHERS THEN

    l_error_msg := bis_utilities_pvt.Get_FND_Message (
    				  p_message_name   => 'BISPMF_SCRTY_ERR_UNHNDLD'
    				, p_msg_param1     => 'RESP_KEY'
    				, p_msg_param1_val =>  p_responsibility_short_name
    				, p_msg_param2     => 'SUM_LVL'
    				, p_msg_param2_val =>  p_target_level_short_name
    				                     ) ;

    BIS_UTILITIES_PUB.put_line(p_text => l_error_msg ) ;


END;



PROCEDURE check_security_exists
( p_responsibility_id 	IN 	NUMBER
, p_target_level_id	IN 	NUMBER
, x_exists		OUT NOCOPY 	BOOLEAN
) IS

  l_exists 	BOOLEAN;
  l_count	NUMBER;

BEGIN

  SELECT count(1)
  INTO l_count
  FROM bis_indicator_resps
  WHERE target_level_id = p_target_level_id
    AND responsibility_id = p_responsibility_id;	  -- BIS_UTILITIES_PUB.put_line(p_text => ' l_count = ' || l_count ) ;

  IF ( l_count = 0 ) THEN
    x_exists := FALSE;
  ELSE -- IF (l_count = 1 ) THEN
    x_exists := TRUE;
  -- ELSE
    -- BIS_UTILITIES_PUB.put_line(p_text => ' Error in CHECK_SECURITY_EXISTS: One Summary level has the same responsibility more than once ' ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- BIS_UTILITIES_PUB.put_line(p_text => ' Error in CHECK_SECURITY_EXISTS: in when others ' ) ;
    x_exists := TRUE; -- We don't want to upload it.

END;



PROCEDURE resp_value_id_conversion
( p_responsibility_key	        IN      VARCHAR
, x_responsibility_id	        OUT NOCOPY     NUMBER
, x_return_status		OUT NOCOPY 	VARCHAR
, x_return_msg			OUT NOCOPY  	VARCHAR
) IS

  l_responsibility_id NUMBER;
  l_temp_msg		VARCHAR2(100);
  l_error_msg		VARCHAR2(100);

BEGIN

  							-- BIS_UTILITIES_PUB.put_line(p_text => ' inside resp val id conv 1 ' || p_responsibility_key ) ;

  SELECT responsibility_id
  INTO l_responsibility_id
  FROM fnd_responsibility
  WHERE responsibility_key = p_responsibility_key ;

  							-- BIS_UTILITIES_PUB.put_line(p_text => ' inside resp val id conv 2 ' ) ;

  x_responsibility_id := l_responsibility_id ;
  x_return_status := 'S';


EXCEPTION

  WHEN NO_DATA_FOUND THEN

    l_error_msg := bis_utilities_pvt.Get_FND_Message (
    				  p_message_name   => 'BISPMF_SCRTY_RESP_NO_EXIST'
    				, p_msg_param1     => 'RESP_KEY'
    				, p_msg_param1_val =>  p_responsibility_key
    				                     ) ;

    BIS_UTILITIES_PUB.put_line(p_text => l_error_msg ) ;

    x_return_msg := l_error_msg ;
    x_return_status := 'E';

  WHEN OTHERS THEN

    l_error_msg := bis_utilities_pvt.Get_FND_Message (
    				  p_message_name   => 'BISPMF_SCRTY_RESP_NO_EXIST'
    				, p_msg_param1     => 'RESP_KEY'
    				, p_msg_param1_val =>  p_responsibility_key
    				                     ) ;

    BIS_UTILITIES_PUB.put_line(p_text => l_error_msg ) ;

    x_return_msg := l_error_msg ;
    x_return_status := 'U';

END;




PROCEDURE tgt_level_value_id_conversion
( p_target_level_short_name	IN  	VARCHAR
, x_target_level_id 		OUT NOCOPY 	NUMBER
, x_return_status		OUT NOCOPY 	VARCHAR
, x_return_msg			OUT NOCOPY	VARCHAR
) IS

  l_target_level_id NUMBER;
  l_temp_msg		VARCHAR2(100);
  l_error_msg		VARCHAR2(100);

BEGIN

  SELECT target_level_id
  INTO l_target_level_id
  FROM bis_target_levels
  WHERE short_name = p_target_level_short_name ;

  x_target_level_id := l_target_level_id ;
  x_return_status := 'S' ;


EXCEPTION

  WHEN NO_DATA_FOUND THEN

    l_error_msg := substr(bis_utilities_pvt.Get_FND_Message (
    				  p_message_name   => 'BISPMF_SCRTY_SUMLVL_NO_EXIST'
    				, p_msg_param1     => 'SUM_LVL'
    				, p_msg_param1_val =>  p_target_level_short_name
    				                     ),1,80) ;

    BIS_UTILITIES_PUB.put_line(p_text => l_error_msg ) ;

    x_return_msg := l_error_msg ;
    x_return_status := 'E';

  WHEN OTHERS THEN

    l_error_msg := bis_utilities_pvt.Get_FND_Message (
    				  p_message_name   => 'BISPMF_SCRTY_SUMLVL_NO_EXIST'
    				, p_msg_param1     => 'SUM_LVL'
    				, p_msg_param1_val =>  p_target_level_short_name
    				                     ) ;

    BIS_UTILITIES_PUB.put_line(p_text => l_error_msg ) ;

    x_return_msg := l_error_msg ;
    x_return_status := 'U';

END;


---------------------------------------------------------------------------------

  PROCEDURE Insert_Row(
      x_rowid    				in out NOCOPY  varchar2
      ,x_indicator_resp_id   		in out NOCOPY  number
      ,x_target_level_id		in	  number
      ,x_responsibility_id		in	  number
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
  )
  IS

      CURSOR CROWID IS SELECT rowid FROM bis_indicator_resps
                       WHERE indicator_resp_id = x_indicator_resp_id;

      CURSOR CID IS SELECT bis_indicator_resps_s.nextval
                    FROM sys.dual;
  BEGIN
      Open CID;
      Fetch CID into x_indicator_resp_id;
      if (CID%NOTFOUND) then
         CLOSE CID;
         RAISE NO_DATA_FOUND;
      end if;

      Close CID;

      INSERT INTO bis_indicator_resps (
         indicator_resp_id
         ,target_level_id
         ,responsibility_id
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
      )
      Values
      (
         x_indicator_resp_id
         ,x_target_level_id
         ,x_responsibility_id
         ,x_created_by
         ,x_creation_date
         ,x_last_updated_by
         ,x_last_update_date
         ,x_last_update_login
      );

      Open CROWID;
      Fetch CROWID into x_rowid;
      if (CROWID%NOTFOUND) then
         CLOSE CROWID;
         RAISE NO_DATA_FOUND;
      end if;
      CLOSE CROWID;

  END Insert_Row;


  ----------------------------------------------------

  PROCEDURE Lock_Row(
      x_rowid    				in      varchar2
      ,x_indicator_resp_id   		in      number
      ,x_target_level_id		in	  number
      ,x_responsibility_id		in	  number
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
  )
  IS

      CURSOR C IS
         SELECT *
         FROM bis_indicator_resps
         WHERE rowid = x_rowid
         FOR UPDATE OF indicator_resp_id NOWAIT;

      Recinfo C%ROWTYPE;
  BEGIN
      Open C;
      Fetch C into Recinfo;
      if (C%NOTFOUND) then
         Close C;
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
         APP_EXCEPTION.Raise_Exception;
      end if;
      Close C;
      if (
               (Recinfo.indicator_resp_id 	 = x_indicator_resp_id)
           AND (Recinfo.target_level_id   	 = x_target_level_id)
           AND (Recinfo.responsibility_id  	 = x_responsibility_id)
           AND (Recinfo.created_by  	 	 = x_created_by)
           AND (Recinfo.creation_date		 = x_creation_date)
           AND (Recinfo.last_updated_by   	 = x_last_updated_by)
           AND (Recinfo.last_update_date   	 = x_last_update_date)
           AND (    (Recinfo.last_update_login = x_last_update_login)
                 OR (    (recinfo.last_update_login IS NULL)
                      AND(x_last_update_login IS NULL)))
         ) then
         return;
      else
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
         APP_EXCEPTION.Raise_Exception;
      end if;
  END Lock_Row;
  ----------------------------------------------------


  PROCEDURE Update_Row(
      x_rowid    				in      varchar2
      ,x_indicator_resp_id   		in      number
      ,x_target_level_id		in	  number
      ,x_responsibility_id		in	  number
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
  )
  IS

      l_temp_msg		VARCHAR2(100);
      l_error_msg		VARCHAR2(100);

  BEGIN
      UPDATE bis_indicator_resps
      SET
         target_level_id	 = x_target_level_id
         ,responsibility_id	 = x_responsibility_id
         ,last_updated_by    	 = x_last_updated_by
         ,last_update_date     = x_last_update_date
         ,last_update_login     = x_last_update_login
      WHERE rowid = x_rowid;
      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;

  END Update_Row;

  ----------------------------------------------------

  PROCEDURE Update_Row(
       x_indicator_resp_id   		in      number
      ,x_target_level_id		in	  number
      ,x_responsibility_id		in	  number
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
  )
  IS

      l_temp_msg		VARCHAR2(100);
      l_error_msg		VARCHAR2(100);

  BEGIN
      UPDATE bis_indicator_resps
      SET
          last_updated_by    	 = x_last_updated_by
         ,last_update_date       = x_last_update_date
         ,last_update_login      = x_last_update_login
      WHERE
         target_level_id	 = x_target_level_id
         AND responsibility_id	 = x_responsibility_id  ;

      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;

  END Update_Row;

  ------------------------------------------------------------------------

  PROCEDURE Delete_Row(
      x_rowid    				in      varchar2
  )
  IS
  BEGIN
      DELETE FROM bis_indicator_resps
      WHERE  rowid = x_rowid;

      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;
  END Delete_Row;
  ----------------------------------------------------

  PROCEDURE Check_Unique(
      x_rowid    				in      varchar2
      ,x_target_level_id		in	  number
      ,x_responsibility_id		in	  number
  )
  IS
      CURSOR C IS
      SELECT COUNT(1)
      FROM  bis_indicator_resps
      WHERE target_level_id = x_target_level_id
      AND   responsibility_id = x_responsibility_id
      AND   ((x_rowid is null) OR (rowid <> x_rowid));

      dummy		number;
  BEGIN
      OPEN C;
      Fetch C into dummy;
      Close C;

      if (dummy >= 1) then
         fnd_message.set_name('BIS', 'BIS_DUP_INDRESP');
         APP_EXCEPTION.Raise_Exception;
      end if;
  END Check_Unique;
  ----------------------------------------------------


END BIS_INDICATOR_RESPS_PKG;

/
