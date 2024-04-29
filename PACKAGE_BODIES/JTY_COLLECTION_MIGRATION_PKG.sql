--------------------------------------------------------
--  DDL for Package Body JTY_COLLECTION_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_COLLECTION_MIGRATION_PKG" AS
/* $Header: jtfcolmb.pls 120.1 2006/09/11 21:27:45 mhtran noship $ */

--    Start of Comments

--    ---------------------------------------------------

--    PACKAGE NAME:   JTY_COLLECTION_MIGRATION_PKG

--    ---------------------------------------------------



--  PURPOSE

--      to migrate specific hierarchy to collection usage

--

--

--  PROCEDURES:

--       (see below for specification)

--

--

--  HISTORY

--    08/25/2006  MHTRAN          Package Body Created
--

--    End of Comments

--

  TYPE number_tbl_type is table of NUMBER index by PLS_INTEGER;
  TYPE varchar2_tbl_type is table of VARCHAR2(360) index by PLS_INTEGER;
  TYPE date_tbl_type is table of DATE index by PLS_INTEGER;
  TYPE var_1_tbl_type is table of VARCHAR2(1) index by PLS_INTEGER;
  TYPE var_2000_tbl_type is table of VARCHAR2(2000) index by PLS_INTEGER;

  TYPE Terr_All_Rec_Type  IS RECORD
  (TERR_ID                     number_tbl_type,
   LAST_UPDATE_DATE            date_tbl_type,
   LAST_UPDATED_BY             number_tbl_type,
   CREATION_DATE               date_tbl_type,
   CREATED_BY                  number_tbl_type,
   LAST_UPDATE_LOGIN           number_tbl_type,
   APPLICATION_SHORT_NAME      varchar2_tbl_type,
   NAME                        var_2000_tbl_type,
   RANK                        number_tbl_type,
   ENABLED_FLAG                var_1_tbl_type,
   START_DATE_ACTIVE           date_tbl_type,
   END_DATE_ACTIVE             date_tbl_type,
   PARENT_TERRITORY_ID         number_tbl_type,
   TERRITORY_TYPE_ID           number_tbl_type,
   DESCRIPTION                 varchar2_tbl_type,
   UPDATE_FLAG                 var_1_tbl_type,
   ATTRIBUTE_CATEGORY          varchar2_tbl_type,
   ATTRIBUTE1                  varchar2_tbl_type,
   ATTRIBUTE2                  varchar2_tbl_type,
   ATTRIBUTE3                  varchar2_tbl_type,
   ATTRIBUTE4                  varchar2_tbl_type,
   ATTRIBUTE5                  varchar2_tbl_type,
   ATTRIBUTE6                  varchar2_tbl_type,
   ATTRIBUTE7                  varchar2_tbl_type,
   ATTRIBUTE8                  varchar2_tbl_type,
   ATTRIBUTE9                  varchar2_tbl_type,
   ATTRIBUTE10                 varchar2_tbl_type,
   ATTRIBUTE11                 varchar2_tbl_type,
   ATTRIBUTE12                 varchar2_tbl_type,
   ATTRIBUTE13                 varchar2_tbl_type,
   ATTRIBUTE14                 varchar2_tbl_type,
   ATTRIBUTE15                 varchar2_tbl_type,
   ORG_ID                      number_tbl_type ,
   NUM_WINNERS                 number_tbl_type,
   NUM_QUAL                    number_tbl_type,
   OBJECT_VERSION_NUMBER	   number_tbl_type,
   NEW_TERR_ID				   number_tbl_type
  );

  TYPE terr_qual_rec_type IS RECORD
  (TERR_QUAL_ID			   	   number_tbl_type,
   NEW_TERR_QUAL_ID			   number_tbl_type,
   TERR_ID				   	   number_tbl_type,
   NEW_TERR_ID				   number_tbl_type,
   LAST_UPDATE_DATE            date_tbl_type,
   LAST_UPDATED_BY             number_tbl_type,
   CREATION_DATE               date_tbl_type,
   CREATED_BY                  number_tbl_type,
   LAST_UPDATE_LOGIN           number_tbl_type,
   QUAL_USG_ID      		   number_tbl_type,
   QUALIFIER_MODE              varchar2_tbl_type,
   OVERLAP_ALLOWED_FLAG		   var_1_tbl_type,
   USE_TO_NAME_FLAG			   var_1_tbl_type,
   GENERATE_FLAG			   var_1_tbl_type,
   ORG_ID					   number_tbl_type,
   SECURITY_GROUP_ID		   number_tbl_type,
   OBJECT_VERSION_NUMBER 	   number_tbl_type
  );

  TYPE terr_rsc_rec_type IS RECORD
  (TERR_RSC_ID			   	   number_tbl_type,
   NEW_TERR_ID				   number_tbl_type,
   TERR_ID				   	   number_tbl_type
  );


PROCEDURE UPDATE_TERR_RECORD (
    x_errbuf            	  OUT NOCOPY VARCHAR2,
    x_retcode           	  OUT NOCOPY VARCHAR2,
    p_terr_id			  	  IN  NUMBER
) IS

  CURSOR get_terr_def_csr
    (v_terr_id number) IS
  SELECT terr.TERR_ID, terr.LAST_UPDATE_DATE, terr.LAST_UPDATED_BY,
   terr.CREATION_DATE, terr.CREATED_BY, terr.LAST_UPDATE_LOGIN,
   terr.APPLICATION_SHORT_NAME, terr.NAME, terr.RANK,
   terr.ENABLED_FLAG, terr.START_DATE_ACTIVE, terr.END_DATE_ACTIVE,
   terr.PARENT_TERRITORY_ID, terr.TERRITORY_TYPE_ID,
   terr.DESCRIPTION, terr.UPDATE_FLAG,
   terr.ATTRIBUTE_CATEGORY, terr.ATTRIBUTE1, terr.ATTRIBUTE2,
   terr.ATTRIBUTE3, terr.ATTRIBUTE4, terr.ATTRIBUTE5,
   terr.ATTRIBUTE6, terr.ATTRIBUTE7, terr.ATTRIBUTE8,
   terr.ATTRIBUTE9, terr.ATTRIBUTE10, terr.ATTRIBUTE11,
   terr.ATTRIBUTE12, terr.ATTRIBUTE13, terr.ATTRIBUTE14,
   terr.ATTRIBUTE15, terr.ORG_ID,
   terr.NUM_WINNERS, terr.NUM_QUAL, terr.OBJECT_VERSION_NUMBER--,
   --JTF_TERR_s.nextval NEW_TERR_ID
  from JTF_TERR_ALL terr
  where nvl(terr.TERR_GROUP_FLAG,'N') = 'N'
    and NVL(terr.ENABLE_SELF_SERVICE,'N') = 'N'
  CONNECT BY terr.parent_territory_id = PRIOR terr.terr_id
  AND terr.TERR_ID <> 1
  START WITH terr.terr_id = v_terr_id
	  order siblings by terr.terr_id;

  CURSOR get_terr_qual_csr(
    v_terr_id			   number,
	v_new_terr_id		   number,
	v_qtype_usg_id		   number,
	v_sales_qtype_usg_id   number) IS
  select jtq.TERR_QUAL_ID, JTF_TERR_QUAL_s.nextval NEW_TERR_QUAL_ID,
         jtq.TERR_ID, v_new_terr_id NEW_TERR_ID,
		 jtq.LAST_UPDATE_DATE, jtq.LAST_UPDATED_BY,
         jtq.CREATION_DATE, jtq.CREATED_BY, jtq.LAST_UPDATE_LOGIN,
         col_usg.qual_usg_id QUAL_USG_ID, jtq.QUALIFIER_MODE,
         jtq.OVERLAP_ALLOWED_FLAG, jtq.USE_TO_NAME_FLAG, jtq.GENERATE_FLAG,
         jtq.ORG_ID, jtq.SECURITY_GROUP_ID, jtq.OBJECT_VERSION_NUMBER
       from JTF_TERR_QUAL_ALL jtq,
       jtf_qual_usgs_all col_usg, jtf_qual_usgs_all sales_usg
       where jtq.terr_id = v_terr_id
         and jtq.qual_usg_id = sales_usg.qual_usg_id
         and jtq.org_id = sales_usg.org_id
         and col_usg.qual_type_usg_id = v_qtype_usg_id
         and col_usg.seeded_qual_id = sales_usg.seeded_qual_id
         and col_usg.org_id = sales_usg.org_id
         and sales_usg.qual_type_usg_id = v_sales_qtype_usg_id;

  l_terr_def_rec			   Terr_All_Rec_Type;
  l_terr_qual_rec			   terr_qual_rec_type;
  l_terr_rsc_rec			   terr_rsc_rec_type;


  l_terr_type_id        number;
  l_source_id 		    number;
  l_qtype_usg_id 	    number;
  l_qual_type_id		number;
  l_sales_qtype_usg_id  number := -1001;

  l_access_type			varchar2(32);

BEGIN

  -- get template id
  begin
    select terr_type_id into l_terr_type_id
	from jtf_terr_types_all
	where name = 'General Collections'
	  and rownum = 1;
	--dbms_output.put_line('template_id: '||l_terr_type_id);

	exception
	  when no_data_found then
		x_retcode := FND_API.G_RET_STS_ERROR;
		x_errbuf := 'Exception in get template id: ' || sqlcode||': '||SQLERRM;
  end;

  -- get source_id
  begin
    select source_id into l_source_id
	from jtf_sources_all
	where description = 'Collections'
	  and rownum = 1;
	--dbms_output.put_line('source_id: '||l_source_id);

	exception
	  when no_data_found then
		x_retcode := FND_API.G_RET_STS_ERROR;
		x_errbuf := 'Exception in get source_id: ' || sqlcode||': '||SQLERRM;
  end;

  -- get qual_type_usgs_id
  begin

  select qual_type_usg_id, qual_type_id
  into l_qtype_usg_id, l_qual_type_id
  from jtf_qual_type_usgs_all
  where source_id = l_source_id
    and rownum = 1;
	--dbms_output.put_line('qual_type_usgs_id,qual_type_id: '||l_qtype_usg_id ||', '|| l_qual_type_id);

	exception
	  when no_data_found then
		x_retcode := FND_API.G_RET_STS_ERROR;
		x_errbuf := 'Exception in get qual_type_usgs_id: ' || sqlcode||': '||SQLERRM;
  end;

  -- get access_type
  begin

    select name into l_access_type
    from JTF_QUAL_TYPES_ALL
    where qual_type_id = l_qual_type_id
      and rownum = 1;
	--dbms_output.put_line('access_type: '|| l_access_type);

	exception
	  when no_data_found then
		x_retcode := FND_API.G_RET_STS_ERROR;
		x_errbuf := 'Exception in get access_type: ' || sqlcode||': '||SQLERRM;
  end;

  open get_terr_def_csr (p_terr_id);
  fetch get_terr_def_csr bulk collect into
   l_terr_def_rec.TERR_ID, l_terr_def_rec.LAST_UPDATE_DATE, l_terr_def_rec.LAST_UPDATED_BY,
   l_terr_def_rec.CREATION_DATE, l_terr_def_rec.CREATED_BY, l_terr_def_rec.LAST_UPDATE_LOGIN,
   l_terr_def_rec.APPLICATION_SHORT_NAME, l_terr_def_rec.NAME, l_terr_def_rec.RANK,
   l_terr_def_rec.ENABLED_FLAG, l_terr_def_rec.START_DATE_ACTIVE, l_terr_def_rec.END_DATE_ACTIVE,
   l_terr_def_rec.PARENT_TERRITORY_ID, l_terr_def_rec.TERRITORY_TYPE_ID,
   l_terr_def_rec.DESCRIPTION, l_terr_def_rec.UPDATE_FLAG,
   l_terr_def_rec.ATTRIBUTE_CATEGORY, l_terr_def_rec.ATTRIBUTE1, l_terr_def_rec.ATTRIBUTE2,
   l_terr_def_rec.ATTRIBUTE3, l_terr_def_rec.ATTRIBUTE4, l_terr_def_rec.ATTRIBUTE5,
   l_terr_def_rec.ATTRIBUTE6, l_terr_def_rec.ATTRIBUTE7, l_terr_def_rec.ATTRIBUTE8,
   l_terr_def_rec.ATTRIBUTE9, l_terr_def_rec.ATTRIBUTE10, l_terr_def_rec.ATTRIBUTE11,
   l_terr_def_rec.ATTRIBUTE12, l_terr_def_rec.ATTRIBUTE13, l_terr_def_rec.ATTRIBUTE14,
   l_terr_def_rec.ATTRIBUTE15, l_terr_def_rec.ORG_ID,
   l_terr_def_rec.NUM_WINNERS, l_terr_def_rec.NUM_QUAL, l_terr_def_rec.OBJECT_VERSION_NUMBER;
   --l_terr_def_rec.NEW_TERR_ID;
  close get_terr_def_csr;

  -- copy territory definition rows
  IF (l_terr_def_rec.TERR_ID.count > 0) THEN
	--dbms_output.put_line('Start copy territory definition');

    for i in l_terr_def_rec.TERR_ID.first..l_terr_def_rec.TERR_ID.last loop
	  select JTF_TERR_s.nextval into l_terr_def_rec.NEW_TERR_ID(i)
	  from dual;
	--dbms_output.put_line('New terr_id: '|| l_terr_def_rec.NEW_TERR_ID(i));
	end loop;

    forall i in l_terr_def_rec.TERR_ID.first..l_terr_def_rec.TERR_ID.last
      INSERT INTO JTF_TERR_ALL (
        TERR_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
        CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
        APPLICATION_SHORT_NAME, NAME, RANK,
        ENABLED_FLAG, START_DATE_ACTIVE, END_DATE_ACTIVE,
        PARENT_TERRITORY_ID, TERRITORY_TYPE_ID,
        DESCRIPTION, UPDATE_FLAG,
        ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
        ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
        ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
        ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
        ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
        ATTRIBUTE15, ORG_ID,
        NUM_WINNERS, NUM_QUAL, OBJECT_VERSION_NUMBER)
	  VALUES (l_terr_def_rec.NEW_TERR_ID(i), l_terr_def_rec.LAST_UPDATE_DATE(i), l_terr_def_rec.LAST_UPDATED_BY(i),
        l_terr_def_rec.CREATION_DATE(i), l_terr_def_rec.CREATED_BY(i), l_terr_def_rec.LAST_UPDATE_LOGIN(i),
        l_terr_def_rec.APPLICATION_SHORT_NAME(i), l_terr_def_rec.NAME(i), l_terr_def_rec.RANK(i),
        l_terr_def_rec.ENABLED_FLAG(i), l_terr_def_rec.START_DATE_ACTIVE(i), l_terr_def_rec.END_DATE_ACTIVE(i),
        l_terr_def_rec.PARENT_TERRITORY_ID(i), l_terr_type_id,
        l_terr_def_rec.DESCRIPTION(i), l_terr_def_rec.UPDATE_FLAG(i),
        l_terr_def_rec.ATTRIBUTE_CATEGORY(i), l_terr_def_rec.ATTRIBUTE1(i), l_terr_def_rec.ATTRIBUTE2(i),
        l_terr_def_rec.ATTRIBUTE3(i), l_terr_def_rec.ATTRIBUTE4(i), l_terr_def_rec.ATTRIBUTE5(i),
        l_terr_def_rec.ATTRIBUTE6(i), l_terr_def_rec.ATTRIBUTE7(i), l_terr_def_rec.ATTRIBUTE8(i),
        l_terr_def_rec.ATTRIBUTE9(i), l_terr_def_rec.ATTRIBUTE10(i), l_terr_def_rec.ATTRIBUTE11(i),
        l_terr_def_rec.ATTRIBUTE12(i), l_terr_def_rec.ATTRIBUTE13(i), l_terr_def_rec.ATTRIBUTE14(i),
        l_terr_def_rec.ATTRIBUTE15(i), l_terr_def_rec.ORG_ID(i),
        l_terr_def_rec.NUM_WINNERS(i), l_terr_def_rec.NUM_QUAL(i), l_terr_def_rec.OBJECT_VERSION_NUMBER(i));

	--dbms_output.put_line('Terr def insert completed: ' ||SQL%ROWCOUNT);

    forall i in l_terr_def_rec.NEW_TERR_ID.first..l_terr_def_rec.NEW_TERR_ID.last
	  UPDATE JTF_TERR_ALL
	  set parent_territory_id = l_terr_def_rec.NEW_TERR_ID(i)
	  where parent_territory_id = l_terr_def_rec.TERR_ID(i)
	    and TERRITORY_TYPE_ID = l_terr_type_id;

    forall i in l_terr_def_rec.NEW_TERR_ID.first..l_terr_def_rec.NEW_TERR_ID.last
      INSERT INTO JTF_TERR_USGS_ALL(
           TERR_USG_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           TERR_ID,
           SOURCE_ID,
           ORG_ID
          )
	  VALUES (
		JTF_TERR_USGS_s.nextval,
    	l_terr_def_rec.LAST_UPDATE_DATE(i),
    	l_terr_def_rec.LAST_UPDATED_BY(i),
    	l_terr_def_rec.CREATION_DATE(i),
    	l_terr_def_rec.CREATED_BY(i),
    	l_terr_def_rec.LAST_UPDATE_LOGIN(i),
    	l_terr_def_rec.NEW_TERR_ID(i),
    	l_source_id,
    	l_terr_def_rec.ORG_ID(i));
	--dbms_output.put_line('Terr usage insert completed: ' ||SQL%ROWCOUNT);

    forall i in l_terr_def_rec.NEW_TERR_ID.first..l_terr_def_rec.NEW_TERR_ID.last
    INSERT INTO JTF_TERR_QTYPE_USGS_ALL(
           TERR_QTYPE_USG_ID,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           TERR_ID,
           QUAL_TYPE_USG_ID,
           ORG_ID
          )
	  VALUES (
	    JTF_TERR_QTYPE_USGS_s.nextval,
		l_terr_def_rec.LAST_UPDATED_BY(i),
		l_terr_def_rec.LAST_UPDATE_DATE(i),
		l_terr_def_rec.CREATED_BY(i),
		l_terr_def_rec.CREATION_DATE(i),
		l_terr_def_rec.LAST_UPDATE_LOGIN(i),
		l_terr_def_rec.NEW_TERR_ID(i),
		l_qtype_usg_id,
		l_terr_def_rec.ORG_ID(i));
	--dbms_output.put_line('Terr qual type insert completed: ' ||SQL%ROWCOUNT);

	-- copy terr qual rows
    FOR i in l_terr_def_rec.NEW_TERR_ID.first..l_terr_def_rec.NEW_TERR_ID.last LOOP
      OPEN get_terr_qual_csr(l_terr_def_rec.TERR_ID(i), l_terr_def_rec.NEW_TERR_ID(i),
	    l_qtype_usg_id, l_sales_qtype_usg_id);
      FETCH get_terr_qual_csr BULK COLLECT INTO
   	  	l_terr_qual_rec.TERR_QUAL_ID, l_terr_qual_rec.NEW_TERR_QUAL_ID,
		l_terr_qual_rec.TERR_ID, l_terr_qual_rec.NEW_TERR_ID,
	 	l_terr_qual_rec.LAST_UPDATE_DATE, l_terr_qual_rec.LAST_UPDATED_BY,
        l_terr_qual_rec.CREATION_DATE, l_terr_qual_rec.CREATED_BY, l_terr_qual_rec.LAST_UPDATE_LOGIN,
        l_terr_qual_rec.QUAL_USG_ID, l_terr_qual_rec.QUALIFIER_MODE,
        l_terr_qual_rec.OVERLAP_ALLOWED_FLAG, l_terr_qual_rec.USE_TO_NAME_FLAG, l_terr_qual_rec.GENERATE_FLAG,
        l_terr_qual_rec.ORG_ID, l_terr_qual_rec.SECURITY_GROUP_ID, l_terr_qual_rec.OBJECT_VERSION_NUMBER;
      CLOSE get_terr_qual_csr;

	  IF (l_terr_qual_rec.NEW_TERR_QUAL_ID.COUNT > 0) THEN
        forall j in l_terr_qual_rec.NEW_TERR_QUAL_ID.first..l_terr_qual_rec.NEW_TERR_QUAL_ID.last
          INSERT INTO JTF_TERR_QUAL_ALL (
            TERR_QUAL_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
            CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
            TERR_ID,
    		QUAL_USG_ID, QUALIFIER_MODE,
            OVERLAP_ALLOWED_FLAG, USE_TO_NAME_FLAG, GENERATE_FLAG,
            ORG_ID, SECURITY_GROUP_ID, OBJECT_VERSION_NUMBER)
          VALUES (l_terr_qual_rec.NEW_TERR_QUAL_ID(j),
    	 	l_terr_qual_rec.LAST_UPDATE_DATE(j), l_terr_qual_rec.LAST_UPDATED_BY(j),
            l_terr_qual_rec.CREATION_DATE(j), l_terr_qual_rec.CREATED_BY(j),
			l_terr_qual_rec.LAST_UPDATE_LOGIN(j), l_terr_qual_rec.NEW_TERR_ID(j),
            l_terr_qual_rec.QUAL_USG_ID(j), l_terr_qual_rec.QUALIFIER_MODE(j),
            l_terr_qual_rec.OVERLAP_ALLOWED_FLAG(j), l_terr_qual_rec.USE_TO_NAME_FLAG(j),
			l_terr_qual_rec.GENERATE_FLAG(j),
            l_terr_qual_rec.ORG_ID(j), l_terr_qual_rec.SECURITY_GROUP_ID(j),
			l_terr_qual_rec.OBJECT_VERSION_NUMBER(j));

    	--dbms_output.put_line('Terr qual all insert completed: ' ||SQL%ROWCOUNT);

        forall i in l_terr_qual_rec.TERR_QUAL_ID.first..l_terr_qual_rec.TERR_QUAL_ID.last
          INSERT INTO JTF_TERR_VALUES_ALL (
             TERR_VALUE_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE,
             CREATED_BY, CREATION_DATE, LAST_UPDATE_LOGIN,
             TERR_QUAL_ID, INCLUDE_FLAG, COMPARISON_OPERATOR,
             ID_USED_FLAG, LOW_VALUE_CHAR_ID, LOW_VALUE_CHAR,
             HIGH_VALUE_CHAR, LOW_VALUE_NUMBER, HIGH_VALUE_NUMBER,
             VALUE_SET, INTEREST_TYPE_ID, PRIMARY_INTEREST_CODE_ID,
             SECONDARY_INTEREST_CODE_ID, CURRENCY_CODE, ORG_ID,
             SECURITY_GROUP_ID, CNR_GROUP_ID, VALUE1_ID,
             VALUE2_ID, VALUE3_ID, FIRST_CHAR,
             OBJECT_VERSION_NUMBER, VALUE4_ID, SELF_SERVICE_TERR_VALUE_ID)
          (SELECT JTF_TERR_VALUES_s.nextval TERR_VALUE_ID, jtv.LAST_UPDATED_BY, jtv.LAST_UPDATE_DATE,
             jtv.CREATED_BY, jtv.CREATION_DATE, jtv.LAST_UPDATE_LOGIN,
             l_terr_qual_rec.NEW_TERR_QUAL_ID(i) TERR_QUAL_ID,
    		 jtv.INCLUDE_FLAG, jtv.COMPARISON_OPERATOR,
             jtv.ID_USED_FLAG, jtv.LOW_VALUE_CHAR_ID, jtv.LOW_VALUE_CHAR,
             jtv.HIGH_VALUE_CHAR, jtv.LOW_VALUE_NUMBER, jtv.HIGH_VALUE_NUMBER,
             jtv.VALUE_SET, jtv.INTEREST_TYPE_ID, jtv.PRIMARY_INTEREST_CODE_ID,
             jtv.SECONDARY_INTEREST_CODE_ID, jtv.CURRENCY_CODE, jtv.ORG_ID,
             jtv.SECURITY_GROUP_ID, jtv.CNR_GROUP_ID, jtv.VALUE1_ID,
             jtv.VALUE2_ID, jtv.VALUE3_ID, jtv.FIRST_CHAR,
             jtv.OBJECT_VERSION_NUMBER, jtv.VALUE4_ID, jtv.SELF_SERVICE_TERR_VALUE_ID
          FROM JTF_TERR_VALUES_ALL jtv, JTF_TERR_QUAL_ALL jtq
          WHERE jtv.TERR_QUAL_ID = jtq.terr_qual_id
            and jtv.org_id = jtq.org_id
            and jtq.terr_id = l_terr_qual_rec.TERR_ID(i)
    		and jtq.terr_qual_id = l_terr_qual_rec.terr_qual_id(i));
    	--dbms_output.put_line('Terr values all insert completed: ' ||SQL%ROWCOUNT);

	  END IF; -- l_terr_qual_rec.NEW_TERR_QUAL_ID.COUNT
	END LOOP; -- copy terr qual rows

	-- copy terr resource rows
    forall i in l_terr_def_rec.NEW_TERR_ID.first..l_terr_def_rec.NEW_TERR_ID.last
      INSERT INTO JTF_TERR_RSC_ALL (
         TERR_RSC_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
         CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
         TERR_ID, RESOURCE_ID, RESOURCE_TYPE,
         ROLE, PRIMARY_CONTACT_FLAG, START_DATE_ACTIVE,
         END_DATE_ACTIVE, ORG_ID, FULL_ACCESS_FLAG,
         GROUP_ID, SECURITY_GROUP_ID, PERSON_ID,
         OBJECT_VERSION_NUMBER, ATTRIBUTE_CATEGORY, ATTRIBUTE1,
         ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
         ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
         ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
         ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13,
         ATTRIBUTE14, ATTRIBUTE15)
      (SELECT JTF_TERR_RSC_s.nextval TERR_RSC_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
         CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
         l_terr_def_rec.NEW_TERR_ID(i) TERR_ID, RESOURCE_ID, RESOURCE_TYPE,
         ROLE, PRIMARY_CONTACT_FLAG, START_DATE_ACTIVE,
         END_DATE_ACTIVE, ORG_ID, FULL_ACCESS_FLAG,
         GROUP_ID, SECURITY_GROUP_ID, PERSON_ID,
         OBJECT_VERSION_NUMBER, ATTRIBUTE_CATEGORY, ATTRIBUTE1,
         ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
         ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
         ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
         ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13,
         ATTRIBUTE14, ATTRIBUTE15
      FROM JTF_TERR_RSC_ALL
      where terr_id = l_terr_def_rec.TERR_ID(i));
	--dbms_output.put_line('Terr rsc all insert completed: ' ||SQL%ROWCOUNT);

  END IF;

  IF (l_terr_def_rec.NEW_TERR_ID.count > 0) THEN

	--dbms_output.put_line('Start terr rsc access insert');

    for i in l_terr_def_rec.NEW_TERR_ID.first..l_terr_def_rec.NEW_TERR_ID.last loop

	  --dbms_output.put_line('Old terr_id: ' || l_terr_def_rec.TERR_ID(i));
	  --dbms_output.put_line('New terr_id: ' || l_terr_def_rec.NEW_TERR_ID(i));

	  SELECT TERR_RSC_ID, TERR_ID, l_terr_def_rec.TERR_ID(i)
	  BULK COLLECT INTO l_terr_rsc_rec.terr_rsc_id,
	    l_terr_rsc_rec.new_terr_id, l_terr_rsc_rec.terr_id
	  FROM JTF_TERR_RSC_ALL
	  WHERE TERR_ID = l_terr_def_rec.NEW_TERR_ID(i);

	--dbms_output.put_line('Terr_rsc_id Row count: ' ||l_terr_rsc_rec.terr_rsc_id.count);

	  -- copy resource access rows
      IF (l_terr_rsc_rec.terr_rsc_id.COUNT > 0) THEN
        forall i in l_terr_rsc_rec.terr_rsc_id.first..l_terr_rsc_rec.terr_rsc_id.last
    	  INSERT INTO JTF_TERR_RSC_ACCESS_ALL
            (TERR_RSC_ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
             CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
             TERR_RSC_ID, ACCESS_TYPE, ORG_ID,
             SECURITY_GROUP_ID, OBJECT_VERSION_NUMBER, TRANS_ACCESS_CODE )
          SELECT JTF_TERR_RSC_ACCESS_s.nextval TERR_RSC_ACCESS_ID,
    	    jtra.LAST_UPDATE_DATE, jtra.LAST_UPDATED_BY,
            jtra.CREATION_DATE, jtra.CREATED_BY, jtra.LAST_UPDATE_LOGIN,
            l_terr_rsc_rec.terr_rsc_id(i) TERR_RSC_ID,
    		l_access_type ACCESS_TYPE, jtra.ORG_ID,
            jtra.SECURITY_GROUP_ID, jtra.OBJECT_VERSION_NUMBER, jtra.TRANS_ACCESS_CODE
          FROM JTF_TERR_RSC_ALL jtr, JTF_TERR_RSC_ACCESS_ALL jtra
          where jtr.terr_rsc_id = jtra.terr_rsc_id
    	    and jtr.terr_id = l_terr_rsc_rec.terr_id(i)
            and rownum = 1;
    	--dbms_output.put_line('Terr rsc access all insert completed: ' ||SQL%ROWCOUNT);
      END IF;

	end loop;
  END IF;  --l_terr_def_rec

    commit;
	x_retcode := FND_API.G_RET_STS_SUCCESS;
	x_errbuf := 'UPDATE_TERR_RECORD completed successfully';

  EXCEPTION
    WHEN OTHERS THEN
	x_retcode := FND_API.G_RET_STS_ERROR;
	x_errbuf := 'Exception in UPDATE_TERR_RECORD: ' || sqlcode||': '||SQLERRM;

END UPDATE_TERR_RECORD;

END JTY_COLLECTION_MIGRATION_PKG;

/
