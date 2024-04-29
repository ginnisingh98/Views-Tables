--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_MIGRATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_MIGRATIONS_PUB" 
/* $Header: pvxpmigb.pls 120.9 2006/09/01 12:40:38 rdsharma noship $ */
as


/*============================================================================
-- Start of comments
--  API name  : Update_Primary_Partner
--  Type      : Private.
--  Function  : This API is a private api used to update the partner types of
--              of a partner. This api would make one of the partner type as primary
--
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_entity_id                IN  integer,
--			p_primary_partner_type     IN  VARCHAR2,
--
--  OUT   : x_return_status    OUT VARCHAR2(1)
--          x_msg_count        OUT NUMBER
--          x_msg_data         OUT VARCHAR2(2000)
--
--  Version : Current version   1.0
--            Initial version   1.0
--
--  Notes   : Note text
--
--  History :
--            Created     2005/12/26  pinagara
--            Modified    2006/08/30  rdsharma  Fix the bug# 5486739.
-- End of comments
============================================================================*/

PROCEDURE Update_Primary_Partner(
                p_entity_id                IN  integer,
		p_primary_partner_type     IN  VARCHAR2,
		x_return_status            OUT NOCOPY VARCHAR2,
		x_msg_count                OUT NOCOPY NUMBER,
		x_msg_data                 OUT NOCOPY VARCHAR
)
IS

 l_entity_id		integer;
 l_party_id		integer;
 l_version	        integer;
 l_attr_value		varchar2(2000);
 l_attr_value_extn	varchar2(4000);
 l_count		integer;
 l_attr_val_tbl	        PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;
 l_partner_name         varchar2(2000);
 l_primary_partner_type varchar2(2000);
 l_addtl_partner_type   varchar2(2000);

 -- Local variable declaration for Standard Out variables.
 l_return_status        VARCHAR2(1);
 l_msg_count            NUMBER;
 l_msg_data             VARCHAR2(2000);


 CURSOR GET_PARTNER_TYPES IS
        SELECT
        	entity_id,
        	version,
        	attr_value,
        	attr_value_extn
        from
                pv_enty_attr_values
        where
                entity_id = p_entity_id and
                latest_flag = 'Y' AND
                attribute_id = 3;


 CURSOR GET_PARTY_NAME(CV_PARTNER_ID INTEGER) IS
  SELECT
            PARTY_NAME, PARTY_ID
    FROM
            PV_PARTNER_PROFILES,
            HZ_PARTIES
    WHERE
            HZ_PARTIES.PARTY_ID = PV_PARTNER_PROFILES.PARTNER_PARTY_ID AND
            PV_PARTNER_PROFILES.PARTNER_ID = CV_PARTNER_ID;


 CURSOR GET_PARTNER_TYPE_DTLS(CV_PARTNER_ID INTEGER) is
		select ATTR_VALUE from pv_enty_attr_values tabl where entity_id = CV_PARTNER_ID and ATTRIBUTE_id= 3
        	and version =  (SELECT
                            MAX(case (version -1)
                            when 0 then
                                1
                            else
                                (version -1)
                            end ) fROM pv_enty_attr_values
                            WHERE
                            entity_id = CV_PARTNER_ID AND
                            ATTRIBUTE_ID = 3 AND
                            LAST_UPDATE_DATE = (SELECT MIN(LAST_UPDATE_DATE) FROM pv_enty_attr_values WHERE ATTR_VALUE_EXTN = 'Y' AND
                                                        ENTITY_ID = tabl.entity_id and attribute_id = 3)
                       )
        union

        SELECT ATTR_VALUE FROM pv_enty_attr_values
        WHERE
            entity_id = CV_PARTNER_ID and
            ATTRIBUTE_ID = 3 AND
            ENTITY_ID not IN (SELECT ENTITY_ID FROM pv_enty_attr_values WHERE entity_id = CV_PARTNER_ID  and ATTRIBUTE_ID = 3 and ATTR_VALUE_eXTN is not NULL) AND
            LATEST_FLAG = 'Y';

begin

    l_addtl_partner_type := null;
    l_count := 1;

    open GET_PARTNER_TYPE_DTLS(CV_PARTNER_ID => p_entity_id);
    fetch GET_PARTNER_TYPE_DTLS into l_attr_value;
    while GET_PARTNER_TYPE_DTLS%found
    loop
--        if l_attr_value <> p_primary_partner_type then
            if length(l_addtl_partner_type) > 0 then
                   l_addtl_partner_type := l_addtl_partner_type || ',' || l_attr_value;
                else
                    l_addtl_partner_type := l_attr_value;
            end if;
--        end if;
        fetch GET_PARTNER_TYPE_DTLS into l_attr_value;
    end loop;
    close GET_PARTNER_TYPE_DTLS;


	OPEN GET_PARTNER_TYPES;
    	Fetch GET_PARTNER_TYPES INTO
    			l_entity_id,
    			l_version,
    			l_attr_value,
    			l_attr_value_extn;

    	if GET_PARTNER_TYPES%found then
    		l_attr_val_tbl(l_count).attr_value := p_primary_partner_type;
    		l_attr_val_tbl(l_count).attr_value_extn := 'Y';
        end if;
    close GET_PARTNER_TYPES;

--    dbms_output.put_line ('entity:' || l_entity_id || ', Type :' || p_primary_partner_type);

    -- Get the Partner name for the supplied PARTNER_ID.
    for x in GET_PARTY_NAME(CV_PARTNER_ID => l_entity_id)
    loop
        l_partner_name := x.party_name;
	l_party_id := x.party_id;
    end loop;

    IF l_partner_name IS NULL  then
        l_partner_name := 'N/A';
    end if;

    PV_ENTY_ATTR_VALUE_PUB.Upsert_Attr_Value (
		  p_api_version_number=> 1.0
		 ,p_init_msg_list    => FND_API.g_false
		 ,p_commit           => FND_API.g_false
		 ,p_validation_level => FND_API.g_valid_level_full
		 ,x_return_status    => l_return_status
		 ,x_msg_count        => l_msg_count
		 ,x_msg_data         => l_msg_data
		 ,p_attribute_id     => 3
		 ,p_entity	     => 'PARTNER'
		 ,p_entity_id	     => l_entity_id
		 ,p_version          => l_version
		 ,p_attr_val_tbl     => l_attr_val_tbl
	);

     FND_FILE.PUT_LINE(FND_FILE.LOG, '' );
     FND_FILE.PUT_LINE(FND_FILE.LOG,'   ' ||  RPAD(l_partner_name||'('||l_entity_id||')',45) || RPAD(p_primary_partner_type,42) || l_addtl_partner_type );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF ( l_msg_count > 1 ) THEN
	   FOR l_msg_index IN 1..l_msg_count LOOP
               apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_index));
	       FND_FILE.PUT_LINE(FND_FILE.LOG,'        ' ||  substr(apps.fnd_message.get,1,254) );
           END LOOP;
         ELSE
	   -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
		p_encoded => FND_API.G_FALSE
		,p_count => l_msg_count
		,p_data  => l_msg_data
	   );
           FND_FILE.PUT_LINE(FND_FILE.LOG,'        ' ||  l_msg_data );
         END IF;
     END IF;

END Update_Primary_Partner;

/*============================================================================
-- Start of comments
--  API name  : Convert_Partner_Type
--  Type      : Public.
--  Function  : This api is used to migrate the partners from multiple partner
--              types to single partners with primary partner type
--
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_running_mode                IN  integer,
--			p_overwrite                   IN  VARCHAR2,
--
--  OUT   : Errbuf          OUT VARCHAR2
--          retcode         OUT VARCHAR2
--
--  Version : Current version   1.0
--            Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
PROCEDURE Convert_Partner_Type
     (
        Errbuf                         OUT NOCOPY VARCHAR2,
        Retcode                        OUT NOCOPY VARCHAR2,
        p_Running_Mode        IN varchar2 DEFAULT 'EVALUATION',
        p_OverWrite           IN varchar2 DEFAULT 'N'
) is

  l_count		integer;
  l_distinct_count	integer;
  l_attr_value		varchar2(2000);
  l_processed_count	integer;
  l_unprocessed_count	integer;
  l_entity_id		integer;

  -- Local variable declaration for Standard Out variables.
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);

  -- Cursor to get all the configured partner types under
  -- PV_PARTNER_TYPE_RANKING lookup type.
  CURSOR Get_Ranked_Partner_types is
         select
		lookup_code,
                tag
         from
                fnd_lookup_values
         where
                lookup_type = 'PV_PARTNER_TYPE_RANKING' and
                enabled_flag = 'Y' AND
                language = userenv('LANG') and
                TAG IS NOT NULL
         order by tag asc ;

  -- Cursor to get the count for all unprocessed partners.
  CURSOR Get_Unprocessed_Record_Count IS
         select
                count(distinct entity_id) as partner_count
         from
                pv_enty_attr_values
         where
                attribute_id = 3 and
                attr_value_extn = 'Y';

  -- Cursor to get the count of all partners with each Partner type.
  CURSOR Get_Primary_Partner_Type_count is
	select
		attr_value , count(attr_value) as partner_count
        from
                pv_enty_attr_values
        where
                attribute_id = 3 and latest_flag = 'Y' and attr_value_extn = 'Y'
        group by
                attr_value
        having
                count(attr_value) > 0
        order by
                count(attr_value) desc;

  -- Cursor to get the count for all 'Active' and 'Inactive' Partners.
  CURSOR Get_Partner_Status_Count is
         SELECT
                (select count(status)  from pv_partner_profiles where status = 'A') Active,
                (select count(status)  from pv_partner_profiles where status = 'I') Inactive

         FROM DUAL;

  -- Cursor to get all partners with VAD partner types.
  CURSOR Get_VAD_Prtnr_Typ_Migrn_OvWrt is
	SELECT
		ATTR_VALUE,
		entity_id
	FROM (
		SELECT
			ATTR_VALUE,
			entity_id
		FROM pv_enty_attr_values tabl
		WHERE
		ATTRIBUTE_ID = 3
		AND	 ATTR_VALUE = 'VAD'
		AND  VERSION = (SELECT
					MAX(case (version -1)
					when 0 then
						1
					else
						(version -1)
					end )
				FROM pv_enty_attr_values
				WHERE
					entity_id = tabl.entity_id AND
					LAST_UPDATE_DATE = (	SELECT MIN(LAST_UPDATE_DATE)
								FROM pv_enty_attr_values
								WHERE ATTR_VALUE_EXTN = 'Y'
								AND ENTITY_ID = tabl.entity_id
								AND attribute_id = 3
							    )
				)
	UNION
		SELECT
			ATTR_VALUE,
			entity_id
		FROM  pv_enty_attr_values
		WHERE
			ATTRIBUTE_ID = 3
		AND	LATEST_FLAG = 'Y'
		AND	ATTR_VALUE = 'VAD'
		AND	entity_id in (	SELECT	entity_id
				FROM	pv_enty_attr_values
				WHERE	ATTRIBUTE_ID = 3
				AND	attr_value = 'VAD'
				AND	latest_flag = 'Y'
			      )
		AND	ENTITY_ID NOT IN (SELECT ENTITY_ID
                                    FROM pv_enty_attr_values
                                   WHERE ATTRIBUTE_ID = 3
                                   AND attr_value_extn is not null
				 )
	    )
	   partners,
	   pv_partner_profiles profiles
	WHERE partners.entity_id = profiles.partner_id
	AND profiles.status in ('A', 'I');

   -- Cursor to get all partners with other partner types.
   CURSOR  Get_Prtnr_Typ_Migrn_Overwrite IS
                      select distinct
                  details.attr_value,
                  details.entity_id
           from
              (
                  SELECT
			min(tag) as tag,
                        entity_id
                  FROM
		     (
			SELECT ATTR_VALUE,entity_id
			FROM pv_enty_attr_values tabl
                        WHERE
                              ENTITY_ID IN (SELECT ENTITY_ID FROM pv_enty_attr_values WHERE ATTRIBUTE_ID = 3 AND ATTR_VALUE_EXTN = 'Y') AND
                              ATTRIBUTE_ID = 3 AND
                              VERSION = (SELECT
                                            MAX(case (version -1)
                                            when 0 then
                                                 1
                                            else
                                                 (version -1)
                                            end )
					 FROM pv_enty_attr_values
					 WHERE
                                              entity_id = tabl.entity_id and
                                              LAST_UPDATE_DATE = (SELECT MIN(LAST_UPDATE_DATE)
								  FROM pv_enty_attr_values
								  WHERE ATTR_VALUE_EXTN = 'Y'
								  AND ENTITY_ID = tabl.entity_id
								  AND attribute_id = 3)
                                         )

                                        UNION

                                        SELECT ATTR_VALUE,entity_id
					FROM pv_enty_attr_values
                                        WHERE
                                             ATTRIBUTE_ID = 3 AND
                                             ENTITY_ID NOT IN (SELECT ENTITY_ID
					                       FROM pv_enty_attr_values
							       WHERE ATTRIBUTE_ID = 3
							       AND attr_value_extn is not null ) AND
                                             LATEST_FLAG = 'Y'


                                )  attr,
                                fnd_lookup_values lkp where
                                             ENTITY_ID NOT IN (SELECT ENTITY_ID FROM pv_enty_attr_values WHERE ENTITY_ID = attr.entity_id and ATTR_VALUE = 'VAD') and
                                             attr.attr_value = lkp.lookup_code and
                                             lkp.language = userenv('LANG') and
                                             lkp.lookup_type =  'PV_PARTNER_TYPE_RANKING'
                                group by entity_id
                    ) sorted,
                    pv_enty_attr_values details,
                    fnd_lookup_values match,
                    pv_partner_profiles ppp
                    where
                    details.attr_value = lookup_code and
                    match.lookup_type =  'PV_PARTNER_TYPE_RANKING' and
                    match.language = userenv('LANG') and
                    sorted. entity_id = details.entity_id and
                    details.entity_id = ppp.partner_id and
	                ppp.status IN ('A' , 'I') and
                   to_number(sorted.tag)  = to_number(match.tag)

                order by details.entity_id;


    CURSOR GET_VAD_PRTNR_TYP_MIGRN IS
	SELECT distinct
		attr_value,
		entity_id
	FROM
	    pv_enty_attr_values partners,
	    pv_partner_profiles profiles
	WHERE
	    partners.attribute_id = 3
	AND partners.latest_flag = 'Y'
	AND partners.attr_value = 'VAD'
	AND partners.entity_id not in (
				SELECT
				    distinct entity_id
				FROM
				    pv_enty_attr_values
				WHERE
				    attribute_id = 3
				AND attr_value_extn is not null
				AND latest_flag = 'Y'
			     )
	AND partners.entity_id = profiles.partner_id
	AND profiles.status in ('A', 'I');

    CURSOR GET_PRTNR_TYP_MIGRN IS
	SELECT distinct
		attr_value,
		entity_id
	FROM    pv_enty_attr_values attr,
		fnd_lookup_values lkp,
		pv_partner_profiles ppp
        WHERE
                attribute_id = 3
	AND     latest_flag = 'Y'
	AND     entity_id not in (
				  select
					distinct entity_id
				  from
					pv_enty_attr_values
				  where
					attribute_id = 3 and
					latest_flag = 'Y' AND
					(attr_value = 'VAD' OR attr_value_extn is not null )
                                 )
        AND	attr.attr_value = lkp.lookup_code
	AND	lkp.lookup_type =  'PV_PARTNER_TYPE_RANKING'
	AND	lkp.language = userenv('LANG')
	AND	attr.entity_id = ppp.partner_id
	AND	ppp.status IN ('A' , 'I')
	AND	to_number(tag) = (select min(to_number(tag))
				  from fnd_lookup_values
				  where
                                       lookup_code in (select attr_value
							 from pv_enty_attr_values
							where attribute_id=3
							and entity_id  = attr.entity_id
							and latest_flag = 'Y')
				  and  lookup_type =  'PV_PARTNER_TYPE_RANKING'
				  and tag is not null
				  and language = userenv('LANG')
				  and lookup_code <> 'VAD'
                                  );



BEGIN

  fnd_message.set_name('PV','PV_MIGR_HEADER');
  FND_MESSAGE.SET_TOKEN('STARTDATE',TO_char(SYSDATE,'MM/DD/YYYY hh:mm:ss'));
  FND_MESSAGE.SET_TOKEN('USER',fnd_global.user_name);

  FND_MESSAGE.SET_TOKEN('PARAM1','Running_Mode');
  FND_MESSAGE.SET_TOKEN('PARAM2','Overwrite');
  FND_MESSAGE.SET_TOKEN('PARAMVALUE1',p_running_mode);
  FND_MESSAGE.SET_TOKEN('PARAMVALUE2',p_Overwrite);

  FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

  SAVEPOINT migrate_partner_type;

  --Validating the PV_PARTNER_TYPE_RNKING lookup setup.
  -- If setup is not available then Exit the program.
  select count(*)
         into l_count
  from fnd_lookup_values
  where lookup_type = 'PV_PARTNER_TYPE_RANKING'
  and language = userenv('LANG')
  and enabled_flag = 'Y';

  if not l_count > 0 then
     FND_MESSAGE.set_name('PV','PV_MIGR_LKUP_SETUP');
     FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  end if;

  -- Validate that all different partner types code are included
  -- in PV_PARTNER_TYPE_RNKING lookup setup.
  select
         COUNT(*) into l_count
  from
         pv_attribute_codes_b
  where
         attribute_id = 3 and
         attr_code <> 'VAD' AND
            ATTR_CODE NOT IN
            (
                 SELECT
                        LOOKUP_CODE
                FROM
                        FND_LOOKUP_VALUES
                WHERE
                        LOOKUP_CODE<> 'VAD' AND
                        language = userenv('LANG') and
                        lookup_type = 'PV_PARTNER_TYPE_RANKING'and
                        enabled_flag = 'Y'
            );
    IF l_count > 0 THEN
        FND_MESSAGE.set_name('PV','PV_MIGR_LKUP_INCOMPL');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    end if;


  --Validate that all partner types have been ranked, if yes check if they are numbers
  select
       count(*) into l_count
  from
       FND_LOOKUP_VALUES
  where
       LOOKUP_CODE <> 'VAD' AND
       lookup_type = 'PV_PARTNER_TYPE_RANKING' AND
       language = userenv('LANG') and
       enabled_flag = 'Y' and
       TAG IS NULL;

  if l_count > 0 then
      FND_MESSAGE.set_name('PV','PV_MIGR_RANK_INCOMPL');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  end if;

  --Check for the integer
    begin
         select
               count(to_number(TAG)) into l_count
         from
               FND_LOOKUP_VALUES
         where
               LOOKUP_CODE <> 'VAD' AND
               lookup_type = 'PV_PARTNER_TYPE_RANKING' AND
               enabled_flag = 'Y' and
               language = userenv('LANG') and
               TAG IS NOT NULL;
    exception
        when INVALID_NUMBER then
            FND_MESSAGE.set_name('PV','PV_MIGR_RANK_NUMBER');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    end;


  --Make sure that the same ranking is not used by more than one partner_type

    select
            count(distinct tag) into l_distinct_count
    from
            FND_LOOKUP_VALUES
    where
            LOOKUP_CODE <> 'VAD' AND
            lookup_type = 'PV_PARTNER_TYPE_RANKING' AND
            language = userenv('LANG') and
            TAG IS NOT NULL;

    select
            count(tag) into l_count
    from
            FND_LOOKUP_VALUES
    where
            LOOKUP_CODE <> 'VAD' AND
            lookup_type = 'PV_PARTNER_TYPE_RANKING' AND
            language = userenv('LANG') and
            TAG IS NOT NULL;


    if l_count <> l_distinct_count then
        FND_MESSAGE.set_name('PV','PV_MIGR_RANK_UNIQUE');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    end if;


   -- Writing the header information of the Log report.
   FND_FILE.PUT_LINE(FND_FILE.LOG, '');
   FND_MESSAGE.set_name('PV','PV_MIGR_RANKING');
   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '');

   for x in Get_Ranked_Partner_types
   loop
         FND_FILE.PUT_LINE(FND_FILE.LOG, '                       ' || RPAD(x.lookup_code,50) || '  ' || x.tag);
   end loop;

   FND_FILE.PUT_LINE(FND_FILE.LOG, '');


   -- Writing the 'Active' and 'Inactive' partner type count in the Log report.
   for x in Get_Partner_Status_Count
    loop
       FND_MESSAGE.set_name('PV','PV_MIGR_DETAILS');
       FND_MESSAGE.SET_TOKEN('ACTIVEPARTNERS',x.Active);
       FND_MESSAGE.SET_TOKEN('INACTIVEPARTNERS',x.InActive);
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
   end loop;

   if p_OverWrite = 'N' then
        for x in Get_Unprocessed_Record_Count
        loop
           l_unprocessed_count := x.partner_count;
        end loop;
    else
           l_unprocessed_count := 0;
    end if;

    -- Start processing all VAD partner types.
    IF p_OverWrite = 'Y' then

	l_processed_count := 0;
	-- OPEN the Cursor for all VAD partners for processing with Overwrite(Y)
	OPEN Get_VAD_Prtnr_Typ_Migrn_OvWrt;

        -- FETCH first VAD partner for processing.
	FETCH Get_VAD_Prtnr_Typ_Migrn_OvWrt
           INTO
             l_attr_value,
             l_entity_id;

        WHILE Get_VAD_Prtnr_Typ_Migrn_OvWrt%FOUND
         LOOP
            BEGIN

	        -- Standard Start of savepoint
		SAVEPOINT VAD_Partner_OWRTY;

		-- Initialize return variables before the procedure call.
		l_return_status := FND_API.G_RET_STS_SUCCESS;
		l_msg_count := 0;
		l_msg_data := NULL;

		Update_Primary_Partner
		(
		   p_entity_id		  => l_entity_id,
		   p_primary_partner_type => l_attr_value,
		   x_return_status	  => l_return_status,
		   x_msg_count		  => l_msg_count,
		   x_msg_data		  => l_msg_data
		);

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

              EXCEPTION
	      	WHEN FND_API.G_EXC_ERROR THEN
		    ROLLBACK TO VAD_Partner_OWRTY;
	        WHEN OTHERS THEN
		    ROLLBACK TO VAD_Partner_OWRTY;
	    END;


            l_processed_count := l_processed_count + 1;
	    if mod(l_processed_count,50) = 0 then
		if p_running_mode = 'EXECUTION' then
			commit;
		end if;
	    end if;

                FETCH Get_VAD_Prtnr_Typ_Migrn_OvWrt
                   INTO
                      l_attr_value,
                      l_entity_id;

                -- Commented by Rahul Dev Sharma
		-- CLOSE Get_VAD_Prtnr_Typ_Migrn_OvWrt;

	 END LOOP;  -- Finish the LOOP for all the VAD partners.

	 -- CLOSE the cursor Get_VAD_Prtnr_Typ_Migrn_OvWrt after processing all VAD partners.
	 CLOSE Get_VAD_Prtnr_Typ_Migrn_OvWrt;

	---- ********************************************************* ----
	---- Process all Other Partners second, when p_OverWrite = 'Y' ----
	---- ********************************************************* ----

	-- OPEN the Cursor for all other types partners for processing with Overwrite(Y).
	OPEN Get_Prtnr_Typ_Migrn_Overwrite;

        --   BEGIN
        l_processed_count := l_processed_count + Get_Prtnr_Typ_Migrn_Overwrite%RowCount;
        FETCH
                Get_Prtnr_Typ_Migrn_Overwrite
            INTO
		l_attr_value,
                l_entity_id;

        WHILE Get_Prtnr_Typ_Migrn_Overwrite%FOUND
        LOOP
	    BEGIN

		-- Standard Start of savepoint
		SAVEPOINT OTHER_Partner_OWRTY;

		-- Initialize return variables before the procedure call.
		l_return_status := FND_API.G_RET_STS_SUCCESS;
		l_msg_count := 0;
		l_msg_data := NULL;

                Update_Primary_Partner
		(
			p_entity_id		=> l_entity_id,
			p_primary_partner_type	=> l_attr_value ,
			x_return_status		=> l_return_status,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_msg_data
               );

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

              EXCEPTION
	         WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO OTHER_Partner_OWRTY;
		 WHEN OTHERS THEN
			ROLLBACK TO OTHER_Partner_OWRTY;
	    END;

            l_processed_count := l_processed_count + 1;
            if mod(l_processed_count,50) = 0 then
		if p_running_mode = 'EXECUTION' then
                    commit;
		end if;
            end if;

            FETCH Get_Prtnr_Typ_Migrn_Overwrite
                  INTO
			l_attr_value,
                        l_entity_id;

	   END LOOP;

	 -- CLOSE the cursor Get_Prtnr_Typ_Migrn_OvWrt after processing all other types partners.
	 CLOSE Get_Prtnr_Typ_Migrn_Overwrite;
else
  ---- ***************************************************** ----
  ---- Process all VAD Partners first when p_OverWrite = 'N' ----
  ---- ***************************************************** ----
	l_processed_count := 0;
        OPEN Get_VAD_Prtnr_Typ_Migrn;
        l_processed_count := Get_VAD_Prtnr_Typ_Migrn%RowCount;

        FETCH
            Get_VAD_Prtnr_Typ_Migrn
	INTO
		l_attr_value,
		l_entity_id;

	WHILE   Get_VAD_Prtnr_Typ_Migrn%FOUND
	LOOP
	   BEGIN


	        -- Standard Start of savepoint
		SAVEPOINT VAD_Partner_OWRTN;

		-- Initialize return variables before the procedure call.
		l_return_status := FND_API.G_RET_STS_SUCCESS;
		l_msg_count := 0;
		l_msg_data := NULL;

		Update_Primary_Partner(
			p_entity_id => l_entity_id,
			p_primary_partner_type => l_attr_value ,
			x_return_status    => l_return_status,
			x_msg_count        => l_msg_count,
			x_msg_data         => l_msg_data
		);

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

              EXCEPTION
	      	WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO VAD_Partner_OWRTN;
		WHEN OTHERS THEN
			ROLLBACK TO VAD_Partner_OWRTN;
	   END;

	   l_processed_count := l_processed_count + 1;
	   if mod(l_processed_count,50) = 0 then
		if p_running_mode = 'EXECUTION' then
			commit;
                end if;
	   end if;

	   FETCH
               Get_VAD_Prtnr_Typ_Migrn
		INTO
		    l_attr_value,
		    l_entity_id;
        END LOOP;

        CLOSE Get_VAD_Prtnr_Typ_Migrn;

  ---- ********************************************************* ----
  ---- Process all Other Partners second, when p_OverWrite = 'N' ----
  ---- ********************************************************* ----
        OPEN Get_Prtnr_Typ_Migrn;
        l_processed_count := l_processed_count + Get_Prtnr_Typ_Migrn%RowCount;
        FETCH   Get_Prtnr_Typ_Migrn
		INTO
		  l_attr_value,
		  l_entity_id;

	WHILE Get_Prtnr_Typ_Migrn%FOUND
        LOOP
	   BEGIN
	        -- Standard Start of savepoint
		SAVEPOINT OTHER_Partner_OWRTN;

		-- Initialize return variables before the procedure call.
		l_return_status := FND_API.G_RET_STS_SUCCESS;
		l_msg_count := 0;
		l_msg_data := NULL;

		Update_Primary_Partner(
			p_entity_id => l_entity_id,
			p_primary_partner_type => l_attr_value ,
			x_return_status    => l_return_status,
			x_msg_count        => l_msg_count,
			x_msg_data         => l_msg_data
		);

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

              EXCEPTION
	      	WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO OTHER_Partner_OWRTN;
		WHEN OTHERS THEN
			ROLLBACK TO OTHER_Partner_OWRTN;
	   END;

	   l_processed_count := l_processed_count + 1;
	   if mod(l_processed_count,50) = 0 then
		if p_running_mode = 'EXECUTION' then
			commit;
		end if;
	   end if;

	   FETCH   Get_Prtnr_Typ_Migrn
		INTO
		  l_attr_value,
		  l_entity_id;

	END LOOP;

        CLOSE Get_Prtnr_Typ_Migrn;

END IF;
--         FND_FILE.PUT_LINE(FND_FILE.LOG, '      Partner Type                              Number of Primary Partners');

         FND_MESSAGE.set_name('PV','PV_MIGR_PTNRTYP_COUNT');
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

        FND_FILE.PUT_LINE(FND_FILE.LOG, '');

        for x in Get_Primary_Partner_Type_count
        loop
           FND_FILE.PUT_LINE(FND_FILE.LOG, '                        ' || rpad(x.attr_value,62) || '     ' || x.partner_count );
        end loop;

        FND_FILE.PUT_LINE(FND_FILE.LOG, '');

     FND_MESSAGE.set_name('PV','PV_MIGR_FOOTER');
     FND_MESSAGE.SET_TOKEN('PROCESSED',lpad(l_processed_count,5));
     FND_MESSAGE.SET_TOKEN('UNPROCESSED',lpad(l_unprocessed_count,5));
     FND_MESSAGE.SET_TOKEN('ENDDATE',TO_char(SYSDATE,'MM/DD/YYYY hh:mm:ss'));

     FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

    if p_Running_Mode = 'EVALUATION' then
        ROLLBACK TO migrate_partner_type;
    else
        commit;
    end if;

    EXCEPTION
    WHEN OTHERS THEN
--            ROLLBACK;
            FND_MESSAGE.SET_NAME('PV', 'PV_MIGR_ERROR');
            FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
            errbuf  := FND_MESSAGE.get;
            retcode := 2;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'SQLERRM: ' || SQLERRM);
            FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'message[' ||I||']=');
              FND_FILE.PUT_LINE(FND_FILE.LOG, Substr(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ),1,255));
            END LOOP;
    END;


END;

/
