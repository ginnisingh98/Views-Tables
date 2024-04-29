--------------------------------------------------------
--  DDL for Package Body AR_CMGT_DNB_TABLE_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_DNB_TABLE_HANDLER" AS
/* $Header: ARCMDNTB.pls 120.0 2005/07/26 22:54:35 bsarkar noship $ */

procedure INSERT_ROW
	( p_data_element_name		    IN		VARCHAR2,
	  p_scorable_flag		        IN		VARCHAR2,
      p_source_table_name           IN      VARCHAR2,
      p_source_column_name          IN      VARCHAR2,
	  p_created_by			        IN		NUMBER,
	  p_last_updated_by		        IN		NUMBER,
	  p_last_update_login			IN		NUMBER,
	  p_data_element_id		      	IN   	NUMBER,
	  p_application_id			 	IN		NUMBER,
	  p_return_data_type		 	IN		VARCHAR2,
      p_return_date_format		 	IN		VARCHAR2
      ) AS
BEGIN
	INSERT INTO AR_CMGT_DNB_ELEMENTS_B
		( data_element_id,
		  scorable_flag,
		  source_table_name,
          source_column_name,
		  last_updated_by,
		  last_update_date,
		  created_by,
		  creation_date,
		  last_update_login,
		  application_id,
		  return_data_type,
		  return_date_format) values
		( p_data_element_id,
		  p_scorable_flag,
		  p_source_table_name,
		  p_source_column_name,
		  p_last_updated_by,
		  sysdate,
		  p_created_by,
		  sysdate,
		  p_last_update_login,
		  p_application_id,
		  p_return_data_type,
		  p_return_date_format
		 );

	INSERT INTO AR_CMGT_DNB_ELEMENTS_TL
		( data_element_id,
		  data_element_name,
		  LANGUAGE,
		  source_lang,
		  last_updated_by,
		  last_update_date,
		  created_by,
		  creation_date,
		  last_update_login) select
		  p_data_element_id,
		  p_data_element_name,
		  l.language_code,
	      userenv('LANG'),
		  p_last_updated_by,
		  sysdate,
		  p_created_by,
		  sysdate,
		  p_last_update_login
		 from fnd_languages l
		 where l.installed_flag in ('B','I')
		 and not exists (select NULL
                 	from ar_cmgt_dnb_elements_TL t
                 	where T.data_element_id  = p_data_element_id
                 	and T.LANGUAGE = L.LANGUAGE_CODE);


END;


procedure UPDATE_ROW
	( p_data_element_id         IN      NUMBER,
      p_data_element_name	    IN		VARCHAR2,
	  p_scorable_flag		    IN		VARCHAR2,
      p_source_table_name       IN      VARCHAR2,
      p_source_column_name      IN      VARCHAR2,
	  p_last_updated_by		    IN		NUMBER,
	  p_last_update_login		IN		NUMBER,
	  p_application_id			IN		NUMBER,
	  p_return_data_type		IN		VARCHAR2,
      p_return_date_format		IN		VARCHAR2) AS

BEGIN

    update ar_cmgt_dnb_elements_b
       set scorable_flag   = p_SCORABLE_FLAG,
           source_table_name = p_source_table_name,
           source_column_name = p_source_column_name,
           last_update_date = sysdate,
           last_updated_by = p_last_updated_by,
           last_update_login = p_last_update_login,
           application_id    = p_application_id,
           return_data_type  = p_return_data_type,
           return_date_format = p_return_date_format
    where data_element_id = p_data_element_id;

    if (sql%notfound) then
        raise no_data_found;
    end if;
    update ar_cmgt_dnb_elements_tl
      set data_element_name = p_data_element_name,
          last_update_date = sysdate,
          last_updated_by = p_last_updated_by,
	      last_update_login = p_last_update_login,
          source_lang = userenv('LANG')
    WHERE data_element_id = p_data_element_id
    AND   userenv('LANG') in (language, source_lang);

   if  sql%notfound
   then
      raise no_data_found;
   end if;


END;

procedure DELETE_ROW (
  p_data_element_id in NUMBER
) is
begin
  delete from ar_cmgt_dnb_elements_b
  where data_element_id = p_data_element_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ar_cmgt_dnb_elements_tl
  where data_element_id = p_data_element_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ar_cmgt_dnb_elements_TL T
  where not exists
    (select NULL
    from ar_cmgt_dnb_elements_B B
    where B.data_element_id = T.data_element_id
    );

  update ar_cmgt_dnb_elements_TL T set (
      data_element_name
    ) = (select
      B.data_element_NAME
    from ar_cmgt_dnb_elements_TL B
    where B.data_element_id = T.data_element_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.data_element_id,
      T.LANGUAGE
  ) in (select
      SUBT.data_element_id,
      SUBT.LANGUAGE
    from ar_cmgt_dnb_elements_TL SUBB, ar_cmgt_dnb_elements_TL SUBT
    where SUBB.data_element_ID = SUBT.data_element_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and SUBB.data_element_name <> SUBT.data_element_name

  );

  INSERT INTO ar_cmgt_dnb_elements_TL
		( data_element_id,
		  data_element_name,
		  LANGUAGE,
		  source_lang,
		  last_updated_by,
		  last_update_date,
		  created_by,
		  creation_date,
		  last_update_login ) select
		  t.data_element_id,
		  t.data_element_name,
		  l.language_code,
	      t.source_lang,
		  t.last_updated_by,
		  t.last_update_date,
		  t.created_by,
		  t.creation_date,
		  t.last_update_login
		  FROM ar_cmgt_dnb_elements_tl t, fnd_languages l
		  WHERE l.installed_flag in ( 'I', 'B')
		  AND   t.language = userenv('LANG')
		  AND   not exists ( select NULL FROM
					ar_cmgt_dnb_elements_tl t1
				     where t1.data_element_id = t.data_element_id
			             and   t1.language  = l.language_code);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  P_data_element_id           IN      NUMBER,
  P_data_element_name         IN      VARCHAR2,
  P_OWNER                   IN      VARCHAR2) IS
begin

    -- only update rows that have not been altered by user

    update ar_cmgt_dnb_elements_TL
      set data_element_name       = 	p_data_element_name,
          source_lang 		      = 	userenv('LANG'),
          last_update_date 	      = 	sysdate,
          last_updated_by 	      = 	decode(P_OWNER, 'SEED', 1, 0)
    where data_element_id         =     p_data_element_id
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW
	( p_data_element_id          IN     VARCHAR2,
      p_data_element_name	     IN		VARCHAR2,
	  p_scorable_flag	         IN		VARCHAR2,
      p_source_table_name        IN      VARCHAR2,
      p_source_column_name       IN      VARCHAR2,
	  p_created_by		         IN		NUMBER,
	  p_last_updated_by	         IN		NUMBER,
      p_last_update_login        IN        NUMBER,
      p_application_id			IN		NUMBER,
	  p_return_data_type		IN		VARCHAR2,
      p_return_date_format		IN		VARCHAR2
       ) AS


BEGIN
        UPDATE_ROW
	       ( p_data_element_id          => p_data_element_id,
             p_data_element_name	      => p_data_element_name,
             p_scorable_flag		  => p_scorable_flag,
             p_source_table_name      => p_source_table_name,
             p_source_column_name     => p_source_column_name,
	         p_last_updated_by		  => p_last_updated_by,
	         p_last_update_login	  => p_last_update_login,
			 p_application_id		  => p_application_id,
	  		 p_return_data_type		  => p_return_data_type,
      		 p_return_date_format	  => p_return_date_format);

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               INSERT_ROW
	               ( p_data_element_name		=> p_data_element_name,
	                 p_scorable_flag		=> p_scorable_flag,
                     p_source_table_name    => p_source_table_name,
                     p_source_column_name   => p_source_column_name,
	                 p_created_by			=> p_created_by,
	                 p_last_updated_by		=> p_last_updated_by,
	                 p_last_update_login	=> p_last_update_login,
	                 p_data_element_id		=> p_data_element_id,
					 p_application_id		  => p_application_id,
	  		 		 p_return_data_type		  => p_return_data_type,
      		 	     p_return_date_format	  => p_return_date_format);

END;

END AR_CMGT_DNB_TABLE_HANDLER;

/
