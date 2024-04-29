--------------------------------------------------------
--  DDL for Package Body PON_PRICE_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_PRICE_ELEMENTS_PKG" as
/* $Header: PONPETPB.pls 120.2 2006/04/13 13:09:47 sapandey noship $ */

-------------------------------------------------------------------------------
--------------------------  PACKAGE BODY --------------------------------------
-------------------------------------------------------------------------------

PROCEDURE  insert_price_element(p_type_id       IN      NUMBER,
				p_code 		IN	VARCHAR2,
	                        p_name 		IN	VARCHAR2,
                                p_description 	IN	VARCHAR2,
                                p_enabledFlag 	IN	VARCHAR2,
                                p_partyId 	IN	NUMBER,
                                p_source_language 	IN	VARCHAR2,
				p_pricingBasis	IN	VARCHAR2,
				p_contactId	IN	NUMBER,
				p_result	OUT	NOCOPY	NUMBER,
				p_err_code	OUT	NOCOPY	VARCHAR2,
				p_err_msg	OUT	NOCOPY	VARCHAR2) IS

x_err_loc		integer;
x_type_id 		number;
x_system_flag		varchar2(1) := 'N';

BEGIN

x_err_loc := 100;

p_result := 0;


 insert into pon_price_element_types_tl(PRICE_ELEMENT_TYPE_ID,
					TRADING_PARTNER_ID,
					NAME,
					DESCRIPTION,
					LANGUAGE,
					SOURCE_LANG,
					CREATION_DATE,
					CREATED_BY,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY)
				select  p_type_id,
					p_partyId,
					p_name,
					p_description,
					a.language_code,
					p_source_language,
					sysdate,
					p_contactId,
					sysdate,
					p_contactId
				from 	fnd_languages a
				where 	a.installed_flag in ('I', 'B');

 x_err_loc := 300;


 EXCEPTION
      WHEN OTHERS THEN
	p_result   := 2;
	p_err_msg  := SQLERRM;
	p_err_code := SQLCODE;

	RAISE_APPLICATION_ERROR(-20000, 'Exception at PON_PRICE_ELEMENTS_PKG.insert_price_element('|| x_err_loc || '): ' || p_err_code || ' : ' || p_err_msg);


END;



PROCEDURE  update_price_element(p_typeId	IN	NUMBER,
				p_code 		IN	VARCHAR2,
            			p_name 		IN	VARCHAR2,
				p_description 	IN	VARCHAR2,
            			p_enabledFlag 	IN	VARCHAR2,
				p_partyId 	IN	NUMBER,
            			p_language 	IN	VARCHAR2,
				p_pricingBasis 	IN	VARCHAR2,
				p_contactId	IN	NUMBER,
				p_lastUpdate	IN	DATE,
				p_result 	OUT	NOCOPY	NUMBER,
				p_err_code	OUT	NOCOPY	VARCHAR2,
				p_err_msg	OUT 	NOCOPY	VARCHAR2) IS

x_updated               varchar2(1) := 'N';
x_zero_rows		exception;
x_err_loc		integer;

BEGIN

  x_err_loc := 100;
  p_result  := 0;


  begin
  	select 'Y'
  	into   x_updated
  	from   pon_price_element_types
  	where  price_element_type_id = p_typeId
  	and    last_update_date      <> p_lastUpdate;

	p_result := 1;
	p_err_code := 'PON_AUC_PRC_ELMNT_UPDT';

  exception
	when no_data_found then
	x_err_loc := 101;
  end;

  if(p_result = 0) then
   x_err_loc := 200;


   update pon_price_element_types_tl
   set
	name			= p_name,
	description		= p_description,
	source_lang		= p_language,
	last_updated_by 	= p_contactId,
	last_update_date	= sysdate
   where
	price_element_type_id	= p_typeId	and
	language		= p_language;

   x_err_loc := 400;

  end if;

  EXCEPTION

     WHEN OTHERS THEN
	p_result   := 2;
	p_err_msg  := SQLERRM;
	p_err_code := SQLCODE;
        RAISE_APPLICATION_ERROR(-20000, 'Exception at PON_PRICE_ELEMENTS_PKG.update_price_element('|| x_err_loc || '): ' || p_err_code || ' : ' || p_err_msg);


END;

-- ======================================================================
--   PROCEDURE  : ADD_LANGUAGE
--   COMMENT    : Used to popluate the PON_PRICE_ELEMENT_TYPES_TL table when
--                a new language is added. It is called from sql/PONNLINS.sql
-- ======================================================================
PROCEDURE  ADD_LANGUAGE
IS

BEGIN

    --
    -- Get the current language and try to insert a row
    -- in the PON_PRICE_ELEMENT_TYPES_TL table if not
    -- existing
    --

  INSERT INTO
    PON_PRICE_ELEMENT_TYPES_TL (
      PRICE_ELEMENT_TYPE_ID,
      TRADING_PARTNER_ID,
      NAME,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY
    )
    SELECT
      pe.PRICE_ELEMENT_TYPE_ID,
      pe.TRADING_PARTNER_ID,
      pe.NAME,
      pe.DESCRIPTION,
      lang.language_code,
      pe.SOURCE_LANG,
      sysdate,
      pe.CREATED_BY,
      sysdate,
      pe.LAST_UPDATED_BY
    FROM PON_PRICE_ELEMENT_TYPES_TL pe,
              FND_LANGUAGES lang
    WHERE pe.LANGUAGE = USERENV('LANG')
    AND lang.INSTALLED_FLAG IN ('I','B')
    AND NOT EXISTS (SELECT 'x'
                    FROM PON_PRICE_ELEMENT_TYPES_TL pe2
                    WHERE pe2.PRICE_ELEMENT_TYPE_ID = pe.PRICE_ELEMENT_TYPE_ID
                    AND pe2.language = lang.language_code);

END ADD_LANGUAGE;

END PON_PRICE_ELEMENTS_PKG;

/
