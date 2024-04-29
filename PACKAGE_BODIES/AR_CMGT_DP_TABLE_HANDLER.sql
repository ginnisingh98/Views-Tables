--------------------------------------------------------
--  DDL for Package Body AR_CMGT_DP_TABLE_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_DP_TABLE_HANDLER" AS
/* $Header: ARCMGDTB.pls 120.14 2006/06/29 17:34:17 bsarkar noship $ */

procedure INSERT_ROW
	( p_data_point_name		        IN		VARCHAR2,
	  p_description			    	IN		VARCHAR2,
	  p_data_point_category	   		IN		VARCHAR2,
	  p_user_defined_flag		    	IN		VARCHAR2,
	  p_scorable_flag		        IN		VARCHAR2,
	  p_display_on_checklist	    	IN		VARCHAR2,
	  p_created_by			        IN		NUMBER,
	  p_last_updated_by		        IN		NUMBER,
	  p_last_update_login			IN		NUMBER,
	  p_data_point_id		      	IN   		NUMBER,
	  p_return_data_type			IN		VARCHAR2,
	  p_return_date_format			IN		VARCHAR2,
	  p_application_id				IN		NUMBER,
	  p_parent_data_point_id		IN		NUMBER,
	  p_enabled_flag				IN		VARCHAR2,
	  p_package_name				IN		VARCHAR2,
	  p_function_name				IN		VARCHAR2,
	  p_data_point_sub_category		IN		VARCHAR2,
      p_data_point_code             IN      VARCHAR2
      ) AS
BEGIN
	INSERT INTO AR_CMGT_DATA_POINTS_B
		( data_point_id,
		  data_point_category,
		  user_defined_flag,
		  scorable_flag,
		  display_on_checklist_flag,
		  last_updated_by,
		  last_update_date,
		  created_by,
		  creation_date,
		  last_update_login,
		  return_data_type,
		  return_date_format,
		  enabled_flag,
		  application_id,
		  parent_data_point_id,
		  package_name,
		  function_name,
		  data_point_sub_category,
          data_point_code ) values
		( p_data_point_id,
		  p_data_point_category,
		  p_user_defined_flag,
		  p_scorable_flag,
		  p_display_on_checklist,
		  p_last_updated_by,
		  sysdate,
		  p_created_by,
		  sysdate,
		  p_last_update_login,
		  p_return_data_type,
		  p_return_date_format,
		  p_enabled_flag,
		  p_application_id,
		  p_parent_data_point_id,
		  p_package_name,
		  p_function_name,
		  p_data_point_sub_category,
          p_data_point_code
		 );

	INSERT INTO AR_CMGT_DATA_POINTS_TL
		( data_point_id,
		  data_point_name,
		  description,
		  LANGUAGE,
		  source_lang,
		  last_updated_by,
		  last_update_date,
		  created_by,
		  creation_date,
		  last_update_login,
		  application_id) select
		  p_data_point_id,
		  p_data_point_name,
		  p_description,
		  l.language_code,
	      userenv('LANG'),
		  p_last_updated_by,
		  sysdate,
		  p_created_by,
		  sysdate,
		  p_last_update_login,
		  p_application_id
		 from fnd_languages l
		 where l.installed_flag in ('B','I')
		 and not exists (select NULL
                 	from AR_CMGT_DATA_POINTS_TL t
                 	where T.data_point_id  = p_data_point_id
                 	and T.LANGUAGE = L.LANGUAGE_CODE);


END;

PROCEDURE insert_adp_row(
				 p_data_point_code				IN	VARCHAR2,
                 p_data_point_name              IN  VARCHAR2,
                 p_description                  IN  VARCHAR2,
                 p_data_point_sub_category      IN  VARCHAR2,
                 p_data_point_category          IN  VARCHAR2,
                 p_user_defined_flag            IN  VARCHAR2,
                 p_scorable_flag                IN  VARCHAR2,
                 p_display_on_checklist         IN  VARCHAR2,
                 p_created_by                   IN  NUMBER,
                 p_last_updated_by              IN  NUMBER,
                 p_last_update_login            IN  NUMBER,
                 p_data_point_id                IN  NUMBER,
                 p_application_id               IN  NUMBER,
                 p_parent_data_point_id         IN  NUMBER,
                 p_enabled_flag                 IN  VARCHAR2,
                 p_package_name                 IN  VARCHAR2,
                 p_function_name                IN  VARCHAR2,
				 p_function_type				IN	VARCHAR2,
				 p_return_data_type				IN	VARCHAR2,
				 p_return_date_format			IN	VARCHAR2)
IS
BEGIN

	INSERT INTO AR_CMGT_DATA_POINTS_B
		( data_point_id,
		  data_point_sub_category,
		  data_point_category,
		  user_defined_flag,
		  scorable_flag,
		  display_on_checklist_flag,
		  last_updated_by,
		  last_update_date,
		  created_by,
		  creation_date,
		  last_update_login,
		  application_id,
		  parent_data_point_id,
		  enabled_flag,
		  package_name,
		  function_name,
		  function_type,
		  return_data_type,
		  return_date_format,
		  data_point_code)
	VALUES
		( p_data_point_id,
		  p_data_point_sub_category,
		  p_data_point_category,
		  p_user_defined_flag,
		  p_scorable_flag,
		  p_display_on_checklist,
		  p_last_updated_by,
		  sysdate,
		  p_created_by,
		  sysdate,
		  p_last_update_login,
		  p_application_id,
          p_parent_data_point_id,
          p_enabled_flag,
          p_package_name,
          p_function_name,
          p_function_type,
          p_return_data_type,
          p_return_date_format,
          p_data_point_code
		 );

	INSERT INTO AR_CMGT_DATA_POINTS_TL
		( data_point_id,
		  data_point_name,
		  description,
		  LANGUAGE,
		  source_lang,
		  last_updated_by,
		  last_update_date,
		  created_by,
		  creation_date,
		  last_update_login,
		  application_id)
	select
		  p_data_point_id,
		  p_data_point_name,
		  p_description,
		  l.language_code,
	      userenv('LANG'),
		  p_last_updated_by,
		  sysdate,
		  p_created_by,
		  sysdate,
		  p_last_update_login,
		  p_application_id
		 from fnd_languages l
		 where l.installed_flag in ('B','I')
		 and not exists (select NULL
                 	from AR_CMGT_DATA_POINTS_TL t
                 	where T.data_point_id  = p_data_point_id
                 	and T.LANGUAGE = L.LANGUAGE_CODE);


END;

procedure UPDATE_ROW
	( p_data_point_id           IN      NUMBER,
      p_data_point_name	       	IN		VARCHAR2,
      p_description             IN      VARCHAR2,
	  p_data_point_category		IN		VARCHAR2,
	  p_user_defined_flag		IN		VARCHAR2,
	  p_scorable_flag		    IN		VARCHAR2,
	  p_display_on_checklist	IN		VARCHAR2,
      p_application_id      	IN      NUMBER,
      p_parent_data_point_id    IN      NUMBER,
      p_enabled_flag        	IN      VARCHAR2,
      p_package_name        	IN      VARCHAR2,
      p_function_name       	IN      VARCHAR2,
      p_data_point_sub_category	IN      VARCHAR2,
	  p_return_data_type    	IN      VARCHAR2,
	  p_return_date_format  	IN      VARCHAR2,
	  p_last_updated_by		    IN		NUMBER,
	  p_last_update_login		IN		NUMBER,
      p_data_point_code         IN      VARCHAR2) AS

BEGIN

    update ar_cmgt_data_points_b
       set data_point_category =  p_data_point_category,
           user_defined_flag   =  p_USER_DEFINED_FLAG,
           scorable_flag   = p_SCORABLE_FLAG,
           display_on_checklist_flag = p_DISPLAY_ON_CHECKLIST,
           application_id  = p_application_id,
	   enabled_flag    = p_enabled_flag,
	   package_name  = p_package_name,
	   function_name = p_function_name,
	   data_point_sub_category = p_data_point_sub_category,
	   return_data_type  = p_return_data_type,
	   return_date_format = p_return_date_format,
           last_update_date = sysdate,
           last_updated_by = p_last_updated_by,
           last_update_login = p_last_update_login,
           data_point_code = p_data_point_code
    where data_point_id = p_data_point_id;

    if (sql%notfound) then
        raise no_data_found;
    end if;
    update ar_cmgt_data_points_tl
      set data_point_name = p_DATA_POINT_NAME,
          description = p_DESCRIPTION,
          application_id = p_application_id,
          last_update_date = sysdate,
          last_updated_by = p_last_updated_by,
	      last_update_login = p_last_update_login,
          source_lang = userenv('LANG')
    WHERE data_point_id = p_data_point_id
    AND   userenv('LANG') in (language, source_lang);

   if  sql%notfound
   then
      raise no_data_found;
   end if;


END;

PROCEDURE update_adp_row(
		 p_data_point_code		IN	VARCHAR2,
                 p_data_point_name              IN  VARCHAR2,
                 p_description	                IN  VARCHAR2,
 		 p_data_point_sub_category      IN  VARCHAR2,
                 p_scorable_flag                IN  VARCHAR2,
                 p_data_point_id                IN  NUMBER,
                 p_application_id               IN  NUMBER,
                 p_parent_data_point_id         IN  NUMBER,
                 p_enabled_flag                 IN  VARCHAR2,
                 p_package_name                 IN  VARCHAR2,
                 p_function_name                IN  VARCHAR2,
		 p_function_type		IN	VARCHAR2,
		 p_return_data_type		IN	VARCHAR2,
	 	 p_return_date_format		IN  VARCHAR2,
		 p_last_updated_by		IN  NUMBER,
		 p_last_update_login		IN  NUMBER )
IS
BEGIN
    update ar_cmgt_data_points_b
       set scorable_flag   = p_SCORABLE_FLAG,
           last_update_date = sysdate,
	   application_id = p_application_id,
	   data_point_sub_category = p_data_point_sub_category,
	   parent_data_point_id = p_parent_data_point_id,
	   enabled_flag = p_enabled_flag,
	   package_name = p_package_name,
	   function_name = p_function_name,
	   function_type = p_function_type,
	   last_updated_by =  p_last_updated_by,
	   last_update_login = p_last_update_login,
	   return_data_type  = p_return_data_type,
	   return_date_format = p_return_date_format,
	   data_point_code  = p_data_point_code
    where data_point_id = p_data_point_id;

    if (sql%notfound) then
        raise no_data_found;
    end if;
    update ar_cmgt_data_points_tl
      set data_point_name = p_DATA_POINT_NAME,
	  	  description = p_description,
	  	  application_id = p_application_id,
          last_update_date = sysdate,
          source_lang = userenv('LANG')
    WHERE data_point_id = p_data_point_id
    AND   userenv('LANG') in (language, source_lang);

   if  sql%notfound
   then
      raise no_data_found;
   end if;

end;

procedure DELETE_ROW (
  p_data_point_id in NUMBER
) is
begin
  delete from ar_cmgt_data_points_b
  where data_point_id = p_data_point_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ar_cmgt_data_points_tl
  where data_point_id = p_data_point_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AR_CMGT_DATA_POINTS_TL T
  where not exists
    (select NULL
    from AR_CMGT_DATA_POINTS_B B
    where B.DATA_POINT_ID = T.DATA_POINT_ID
    );

  update AR_CMGT_DATA_POINTS_TL T set (
      data_point_NAME,
      DESCRIPTION
    ) = (select
      B.data_point_NAME,
      B.DESCRIPTION
    from AR_CMGT_DATA_POINTS_TL B
    where B.data_point_id = T.data_point_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.data_point_ID,
      T.LANGUAGE
  ) in (select
      SUBT.data_point_ID,
      SUBT.LANGUAGE
    from AR_CMGT_DATA_POINTS_TL SUBB, AR_CMGT_DATA_POINTS_TL SUBT
    where SUBB.data_point_id = SUBT.data_point_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DATA_POINT_NAME <> SUBT.DATA_POINT_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  INSERT INTO AR_CMGT_DATA_POINTS_TL
		( data_point_id,
		  data_point_name,
		  description,
		  LANGUAGE,
		  application_id,
		  source_lang,
		  last_updated_by,
		  last_update_date,
		  created_by,
		  creation_date,
		  last_update_login ) select
		  t.data_point_id,
		  t.data_point_name,
		  t.description,
		  l.language_code,
		  t.application_id,
	      t.source_lang,
		  t.last_updated_by,
		  t.last_update_date,
		  t.created_by,
		  t.creation_date,
		  t.last_update_login
		  FROM ar_cmgt_data_points_tl t, fnd_languages l
		  WHERE l.installed_flag in ( 'I', 'B')
		  AND   t.language = userenv('LANG')
		  AND   not exists ( select NULL FROM
					ar_cmgt_data_points_tl t1
				     where t1.data_point_id = t.data_point_id
			             and   t1.language  = l.language_code);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  P_DATA_POINT_ID           IN      NUMBER,
  P_DESCRIPTION             IN      VARCHAR2,
  P_DATA_POINT_NAME         IN      VARCHAR2,
  P_OWNER                   IN      VARCHAR2) IS
begin

    -- only update rows that have not been altered by user

    update AR_CMGT_DATA_POINTS_TL
      set description 		= 	p_description,
          DATA_POINT_NAME       = 	p_data_point_name,
          source_lang 		= 	userenv('LANG'),
          last_update_date 	= 	sysdate,
          last_updated_by 	= 	decode(P_OWNER, 'SEED', 1, 0)
    where data_point_id = p_data_point_id
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW
	( p_data_point_id         		IN        VARCHAR2,
      p_data_point_name	      		IN		VARCHAR2,
	  p_description		      		IN		VARCHAR2,
	  p_data_point_category	  		IN		VARCHAR2,
	  p_user_defined_flag	  		IN		VARCHAR2,
	  p_scorable_flag	      		IN		VARCHAR2,
	  p_display_on_checklist  		IN		VARCHAR2,
      p_application_id      		IN      NUMBER,
      p_parent_data_point_id        IN      NUMBER,
      p_enabled_flag        		IN      VARCHAR2,
      p_package_name        		IN      VARCHAR2,
      p_function_name       		IN      VARCHAR2,
      p_data_point_sub_category		IN		VARCHAR2,
	  p_return_data_type			IN		VARCHAR2,
	  p_return_date_format			IN		VARCHAR2,
	  p_created_by		      		IN		NUMBER,
	  p_last_updated_by	      		IN		NUMBER,
      p_last_update_login     	    IN        NUMBER,
      p_data_point_code             IN      VARCHAR2
       ) AS


BEGIN
        UPDATE_ROW
	       ( p_data_point_id          => p_data_point_id,
             p_data_point_name	      => p_data_point_name,
             p_description            => p_description,
	         p_data_point_category	  => p_data_point_category,
	         p_user_defined_flag	  => p_user_defined_flag,
	         p_scorable_flag		  => p_scorable_flag,
	         p_display_on_checklist   => p_display_on_checklist,
          	 p_application_id      =>      p_application_id,
          	 p_parent_data_point_id        =>      p_parent_data_point_id,
          	 p_enabled_flag        =>      p_enabled_flag,
          	 p_package_name        =>      p_package_name,
          	 p_function_name       =>      p_function_name,
          	 p_data_point_sub_category	=> p_data_point_sub_category,
		 	 p_return_data_type    =>      p_return_data_type,
		 	 p_return_date_format  =>      p_return_date_format,
	         p_last_updated_by		  => p_last_updated_by,
	         p_last_update_login	  => p_last_update_login,
             p_data_point_code        => p_data_point_code);

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               INSERT_ROW
	               ( p_data_point_name		=> p_data_point_name,
	                 p_description			=> p_description,
	                 p_data_point_category	=> p_data_point_category,
	                 p_user_defined_flag	=> p_user_defined_flag,
	                 p_scorable_flag		=> p_scorable_flag,
	                 p_display_on_checklist => p_display_on_checklist,
	                 p_created_by			=> p_created_by,
	                 p_last_updated_by		=> p_last_updated_by,
	                 p_last_update_login	=> p_last_update_login,
	                 p_data_point_id		=> p_data_point_id,
			 		 p_return_data_type     => p_return_data_type,
			 		 p_return_date_format	=> p_return_date_format,
					 p_application_id		=> p_application_id,
	  				 p_parent_data_point_id	=> p_parent_data_point_id,
	  				 p_enabled_flag			=> p_enabled_flag,
	  				 p_package_name			=> p_package_name,
	  				 p_function_name		=> p_function_name,
	  				 p_data_point_sub_category	=> p_data_point_sub_category,
                     p_data_point_code        => p_data_point_code);

END;

procedure TRANSLATE_ADP_ROW (
  p_data_point_code	    IN	    VARCHAR2,
  P_DESCRIPTION             IN      VARCHAR2,
  P_DATA_POINT_NAME         IN      VARCHAR2,
  P_APPLICATION_ID	    IN	    NUMBER,
  P_OWNER                   IN      VARCHAR2) IS
begin

    -- only update rows that have not been altered by user

    update AR_CMGT_DATA_POINTS_TL
      set description 		= 	p_description,
      	  data_point_name   =   p_data_point_name,
          source_lang 		= 	userenv('LANG'),
          last_update_date 	= 	sysdate,
          last_updated_by 	= 	decode(P_OWNER, 'SEED', 1, 0)
    where data_point_id =  (SELECT data_point_id from ar_cmgt_data_points_b
			    where data_point_code = p_data_point_code
		            and   application_id = p_application_id )
    and   application_id = p_application_id
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ADP_ROW;


procedure LOAD_ADP_ROW
	( p_data_point_code				IN		VARCHAR2,
	  p_data_point_name	      		IN		VARCHAR2,
	  p_description		      		IN		VARCHAR2,
	  p_data_point_category	  		IN		VARCHAR2,
	  p_user_defined_flag	  		IN		VARCHAR2,
	  p_scorable_flag	      		IN		VARCHAR2,
	  p_display_on_checklist  		IN		VARCHAR2,
      p_application_id      		IN      NUMBER,
      p_parent_data_point_code      IN      VARCHAR2,
      p_enabled_flag        		IN      VARCHAR2,
      p_package_name        		IN      VARCHAR2,
      p_function_name       		IN      VARCHAR2,
      p_function_type       		IN      VARCHAR2,
      p_data_point_sub_category		IN		VARCHAR2,
	  p_return_data_type			IN		VARCHAR2,
	  p_return_date_format			IN		VARCHAR2,
	  p_created_by		      		IN		NUMBER,
	  p_last_updated_by	      		IN		NUMBER,
      p_last_update_login     	IN        NUMBER
       ) IS

	l_data_point_id					NUMBER;
	l_parent_data_point_id			NUMBER;
	sqlException					EXCEPTION;
BEGIN
	-- Get the parent data point id
	IF p_parent_data_point_code IS NOT NULL
	THEN
		BEGIN
			SELECT data_point_id
			INTO   l_parent_data_point_id
			FROM   ar_cmgt_data_points_b
			WHERE  data_point_code = p_parent_data_point_code
			AND    application_id  = p_application_id;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				  l_parent_data_point_id := NULL;
		END;
	END IF;
	BEGIN
		SELECT DATA_POINT_ID
		INTO   l_data_point_id
		FROM   ar_cmgt_data_points_b
		WHERE  data_point_code = p_data_point_code
		AND    application_id  = p_application_id;

		update_adp_row(
		 p_data_point_code		=> p_data_point_code,
                 p_data_point_name              => p_data_point_name,
                 p_description	                => p_description,
		 p_data_point_sub_category      => p_data_point_sub_category,
                 p_scorable_flag                => p_scorable_flag,
                 p_data_point_id                => l_data_point_id,
                 p_application_id               => p_application_id,
                 p_parent_data_point_id         => l_parent_data_point_id,
                 p_enabled_flag                 => p_enabled_flag,
                 p_package_name                 => p_package_name,
                 p_function_name                => p_function_name,
		 p_function_type		=> p_function_type,
		 p_return_data_type		=> p_return_data_type,
	 	 p_return_date_format		=> p_return_date_format,
		 p_last_updated_by		=> p_last_updated_by,
		 p_last_update_login		=> p_last_update_login);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				SELECT ar_cmgt_data_points_s.nextval
				INTO   l_data_point_id
				FROM   dual;

				INSERT_adp_ROW
	               ( p_data_point_code		=> p_data_point_code,
				     p_data_point_name		=> p_data_point_name,
	                 p_description			=> p_description,
	                 p_data_point_sub_category => p_data_point_sub_category,
	                 p_data_point_category	=> p_data_point_category,
	                 p_user_defined_flag	=> p_user_defined_flag,
	                 p_scorable_flag		=> p_scorable_flag,
	                 p_display_on_checklist => p_display_on_checklist,
	                 p_created_by			=> p_created_by,
	                 p_last_updated_by		=> p_last_updated_by,
	                 p_last_update_login	=> p_last_update_login,
	                 p_data_point_id		=> l_data_point_id,
	                 p_application_id		=> p_application_id,
	                 p_parent_data_point_id	=> l_parent_data_point_id,
	                 p_enabled_flag			=> p_enabled_flag,
	                 p_package_name			=> p_package_name,
	  				 p_function_name		=> p_function_name,
	  				 p_function_type		=> p_function_type,
			 		 p_return_data_type     => p_return_data_type,
			 		 p_return_date_format	=> p_return_date_format);

	END;
	EXCEPTION
		WHEN OTHERS THEN
			 raise;


END;


END AR_CMGT_DP_TABLE_HANDLER;

/
