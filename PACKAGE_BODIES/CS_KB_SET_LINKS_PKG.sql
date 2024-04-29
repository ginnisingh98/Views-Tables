--------------------------------------------------------
--  DDL for Package Body CS_KB_SET_LINKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SET_LINKS_PKG" AS
/* $Header: cskbslb.pls 120.1.12010000.2 2010/01/25 13:30:39 isugavan ship $ */

--
-- Clone_link is to duplicate all data with previous verion set_id to new set_id
-- @param ( previous set id, new set id)
-- return (OK_STATUS OR ERROR_STATUS)
--
function Clone_Link(
P_SET_SOURCE_ID in NUMBER,
P_SET_TARGET_ID in NUMBER
)return number IS
  l_count number;
  l_id number;
  l_rowid varchar2(30);
  cursor l_link_csr is
    select * from cs_kb_set_links
    where set_id = p_set_source_id;
BEGIN
  -- Validate Set Id
  select count(*) into l_count
    from cs_kb_sets_b
    where set_id = p_set_source_id;
  if(l_count <= 0) then
    fnd_message.set_name('CS', 'CS_KB_C_INVALID_SET_ID');
    fnd_msg_pub.Add;
    goto error_found;
  end if;

  -- Copying data with previous set id to new set_id.
  for rec_link in l_link_csr loop
    -- dtian: use table handler instead
    select cs_kb_set_links_s.nextval into l_id from dual;

    CS_KB_SET_LINKS_PKG.Insert_Row(
      X_Rowid => l_rowid,
      X_Link_Id => l_id,
      X_Link_type => REC_LINK.LINK_TYPE,
      X_Object_Code => REC_LINK.OBJECT_CODE,
      X_Set_Id => P_SET_TARGET_ID,
      X_Other_Id => REC_LINK.OTHER_ID,
      X_Creation_Date => rec_link.creation_date, --Bugfix8513725
      X_Created_By => fnd_global.user_id,
      X_Last_Update_Date => sysdate,
      X_Last_Updated_By => fnd_global.user_id,
      X_Last_Update_Login => fnd_global.login_id,
      X_ATTRIBUTE_CATEGORY => REC_LINK.ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1 => REC_LINK.ATTRIBUTE1,
      X_ATTRIBUTE2 => REC_LINK.ATTRIBUTE2,
      X_ATTRIBUTE3 => REC_LINK.ATTRIBUTE3,
      X_ATTRIBUTE4 => REC_LINK.ATTRIBUTE4,
      X_ATTRIBUTE5 => REC_LINK.ATTRIBUTE5,
      X_ATTRIBUTE6 => REC_LINK.ATTRIBUTE6,
      X_ATTRIBUTE7 => REC_LINK.ATTRIBUTE7,
      X_ATTRIBUTE8 => REC_LINK.ATTRIBUTE8,
      X_ATTRIBUTE9 => REC_LINK.ATTRIBUTE9,
      X_ATTRIBUTE10 => REC_LINK.ATTRIBUTE10,
      X_ATTRIBUTE11 => REC_LINK.ATTRIBUTE11,
      X_ATTRIBUTE12 => REC_LINK.ATTRIBUTE12,
      X_ATTRIBUTE13 => REC_LINK.ATTRIBUTE13,
      X_ATTRIBUTE14 => REC_LINK.ATTRIBUTE14,
      X_ATTRIBUTE15 => REC_LINK.ATTRIBUTE15
      );
      -- end dtian: use table handler instead
  end loop;

  return OKAY_STATUS;

  <<error_found>>
  return ERROR_STATUS;
END Clone_Link;

-- create a set link entry (new, with error message stack called from OA)
-- This is the api to use as of 11.5.10
-- As of 3407999, this one become a private method. See wrappers after this.
PROCEDURE Create_Set_Link(
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_UPDATE_EXTRA_VERSION in VARCHAR2,
  x_link_id     in OUT NOCOPY           NUMBER,
  x_return_status  OUT NOCOPY           VARCHAR2,
  x_msg_data       OUT NOCOPY           VARCHAR2,
  x_msg_count      OUT NOCOPY           NUMBER
  ) IS
  l_date  date;
  l_created_by number;
  l_login number;
  l_id number;
  l_rowid varchar2(30);
  l_other_link_id number;
  l_other_rowid varchar2(30);
  -- Validation Cursors
  CURSOR Validate_Solution IS
   SELECT set_number, status
   FROM CS_KB_SETS_B
   WHERE set_id = P_SET_ID
     AND ( status = 'PUB' or latest_version_flag = 'Y' );

  l_set_number NUMBER;
  l_set_status VARCHAR2(30);

  CURSOR Get_Object_Query IS
   SELECT 'SELECT count(*) FROM '||
           v.From_Table||
           ' WHERE '||v.select_id||' = :1 '||
           decode( v.where_clause, null, ' ', ' AND ' || v.where_clause )
   FROM jtf_objects_vl v, jtf_object_usages u
   WHERE v.object_code = P_OBJECT_CODE
   AND v.object_code = u.object_code
   AND u.object_user_code='CS_KB_SET'
   and ( v.end_date_active is NULL or v.end_date_active > sysdate );

  l_cursor NUMBER;
  l_return NUMBER;
  l_query varchar2(5000);
  l_ext_obj_count NUMBER;

  CURSOR Check_Duplicate IS
   SELECT count(*)
   FROM CS_KB_SET_LINKS
   WHERE set_id      = P_SET_ID
   AND   other_id    = P_OTHER_ID
   AND   object_code = P_OBJECT_CODE;

  l_dup_count NUMBER;

  -- Cursor to fetch id of the latest version of a solution
  CURSOR Get_Link_To_Latest_Ver(c_soln_number VARCHAR2) IS
   SELECT sb.set_id
   FROM CS_KB_SETS_B sb
   WHERE sb.set_number = c_soln_number
     AND sb.latest_version_flag = 'Y';

  l_latest_soln_ver_id NUMBER;

  -- Cursor to fetch id of the published version of a solution
  CURSOR Get_Link_To_Published_Ver(c_soln_number VARCHAR2) IS
   SELECT sb.set_id
   FROM CS_KB_SETS_B sb
   WHERE sb.set_number = c_soln_number
     AND sb.status = 'PUB';

  l_published_soln_ver_id NUMBER;

  l_other_soln_ver_id NUMBER;

  -- Cursor to detect whether there is already a link to a solution version
  -- from a particular object
  CURSOR Count_Links_to_Soln_Ver(c_soln_id NUMBER, c_object_code VARCHAR2,
                                 c_other_id NUMBER) IS
    SELECT count(*)
    FROM CS_KB_SET_LINKS
    WHERE set_id = c_soln_id
      AND object_code = c_object_code
      AND other_id = c_other_id;

  l_links_to_soln_ver_ct NUMBER;

  l_found_other_version varchar2(1);

BEGIN
  SAVEPOINT CREATE_LINK_SP;

  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  -- Begin Validation
  -- validate params
  if( P_OBJECT_CODE is null
      OR P_SET_ID      is NULL
      OR P_OTHER_ID    is null
      OR p_link_type   is null ) THEN
    fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
    fnd_msg_pub.Add;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    return;
  end if;

  OPEN  Validate_Solution;
  FETCH Validate_Solution INTO l_set_number, l_set_status;
  IF ( Validate_Solution%NOTFOUND ) THEN
    CLOSE Validate_Solution;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_SET_ID');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
    return;
  END IF;
  CLOSE Validate_Solution;

  BEGIN
    OPEN Get_Object_Query;
    FETCH Get_Object_Query INTO l_query;
    CLOSE Get_Object_Query;

    --dbms_output.put_line('Query :'||l_query);
    l_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_cursor, l_query, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_ext_obj_count);
    DBMS_SQL.BIND_VARIABLE(l_cursor, ':1',P_OTHER_ID);
    l_return := DBMS_SQL.EXECUTE(l_cursor);

    IF DBMS_SQL.FETCH_ROWS(l_cursor)>0 THEN
      DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_ext_obj_count);
    END IF;
    DBMS_SQL.CLOSE_CURSOR(l_cursor);

    --dbms_output.put_line('Obj count: '||l_ext_obj_count);

   EXCEPTION
    WHEN OTHERS THEN
     --dbms_output.put_line('Caught invalid obj exception !!! ');
     l_ext_obj_count := 0;
   END;

   IF l_ext_obj_count = 0 THEN

     --dbms_output.put_line('Invalid Ext Object ');
     FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_EXT_OBJ');
     FND_MSG_PUB.ADD;
     X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                               p_count   => X_MSG_COUNT,
                               p_data    => X_MSG_DATA);
     return;
   END IF;

   OPEN  Check_Duplicate;
   FETCH Check_Duplicate INTO l_dup_count;
   CLOSE Check_Duplicate;

   IF l_dup_count > 0 THEN
     -- Bug fix 3350231: Used to return error.
     --  Now just return success if the link is already there.
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
     return;
   END IF;

   IF ( P_LINK_TYPE not in ('PS', 'S', 'NS') ) THEN
     FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_LINK_TYPE');
     FND_MSG_PUB.ADD;
     X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                               p_count   => X_MSG_COUNT,
                               p_data    => X_MSG_DATA);
     return;
   END IF;
  -- End of Validation

  --prepare data, then insert new set link
  IF( x_link_id is null ) THEN
    select cs_kb_set_links_s.nextval into l_id from dual;
  ELSE
    l_id := x_link_id;
  END IF;
--Start of Bugfix8513725
  Begin
	Select creation_date into l_date from cs_sr_kb_solution_links_v
	Where set_id = P_SET_ID
	and   object_code = p_object_code
	and   other_id = p_other_id ;
  Exception
    when No_data_found Then
        l_date := sysdate ;
  End ;

  --End Of Bugfix8513725

--  l_date := sysdate; -- Commented for Bugfix8513725
  l_created_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  CS_KB_SET_LINKS_PKG.Insert_Row(
    X_Rowid => l_rowid,
    X_Link_Id => l_id,
    X_Link_type => p_link_type,
    X_Object_Code => p_object_code,
    X_Set_Id => p_set_id,
    X_Other_Id => p_other_id,
    X_Creation_Date => l_date,
    X_Created_By => l_created_by,
    X_Last_Update_Date => l_date,
    X_Last_Updated_By => l_created_by,
    X_Last_Update_Login => l_login,
    X_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1 => P_ATTRIBUTE1,
    X_ATTRIBUTE2 => P_ATTRIBUTE2,
    X_ATTRIBUTE3 => P_ATTRIBUTE3,
    X_ATTRIBUTE4 => P_ATTRIBUTE4,
    X_ATTRIBUTE5 => P_ATTRIBUTE5,
    X_ATTRIBUTE6 => P_ATTRIBUTE6,
    X_ATTRIBUTE7 => P_ATTRIBUTE7,
    X_ATTRIBUTE8 => P_ATTRIBUTE8,
    X_ATTRIBUTE9 => P_ATTRIBUTE9,
    X_ATTRIBUTE10 => P_ATTRIBUTE10,
    X_ATTRIBUTE11 => P_ATTRIBUTE11,
    X_ATTRIBUTE12 => P_ATTRIBUTE12,
    X_ATTRIBUTE13 => P_ATTRIBUTE13,
    X_ATTRIBUTE14 => P_ATTRIBUTE14,
    X_ATTRIBUTE15 => P_ATTRIBUTE15
  );

  -- Raise Business Event when a solution is linked
  CS_KB_SET_LINKS_PKG.Raise_Solution_Linked_Event(
    p_set_id      => p_set_id,
    p_object_code => p_object_code,
    p_object_id   => p_other_id,
    p_link_id     => l_id,
    p_link_type   => p_link_type,
    p_event_date  => l_date );

  IF (P_UPDATE_EXTRA_VERSION = 'Y') THEN
      -- If the link being created is to a published solution version, see if
      -- there is also an in-progress version of the same solution. If there is,
      -- we need to also create a link between the object and the latest
      -- in-progess solution version.
      -- Due to 3407999, if the link being created is to an in progress version,
      -- see if there is also an published version of the same solution. If
      -- there is, we need to also create a link between the object and the
      -- published one.
      l_found_other_version := 'N';
      if (l_set_status = 'PUB') then
        OPEN Get_Link_To_Latest_Ver(l_set_number);
        FETCH Get_Link_To_Latest_Ver INTO l_latest_soln_ver_id;
        CLOSE Get_Link_To_Latest_Ver;
        IF( (l_latest_soln_ver_id is not null)
            and l_latest_soln_ver_id <> p_set_id) THEN
            l_found_other_version := 'Y';
            l_other_soln_ver_id := l_latest_soln_ver_id;
        END IF;
      else
        OPEN Get_Link_To_Published_Ver(l_set_number);
        FETCH Get_Link_To_Published_Ver INTO l_published_soln_ver_id;
        CLOSE Get_Link_To_Published_Ver;
        IF( (l_published_soln_ver_id is not null)
            and l_published_soln_ver_id <> p_set_id) THEN
            l_found_other_version := 'Y';
            l_other_soln_ver_id := l_published_soln_ver_id;
        END IF;
      end if;

      IF (l_found_other_version = 'Y') THEN
          -- Create a link to the latest version if one doesn't already exist
          OPEN Count_Links_to_Soln_Ver( l_other_soln_ver_id, p_object_code,
                                        p_other_id);
          FETCH Count_Links_to_Soln_Ver into l_links_to_soln_ver_ct;
          CLOSE Count_Links_to_Soln_Ver;
	    --Start Of  Bugfix8513725
            Begin
	         Select creation_date into l_date from cs_sr_kb_solution_links_v
	         Where set_id = P_SET_ID
	         and   object_code = p_object_code
	         and   other_id = p_other_id ;
            Exception
                when No_data_found Then
                    l_date := sysdate ;
            End ;
 --End Of  Bugfix8513725

          IF ( l_links_to_soln_ver_ct = 0 ) THEN
            select cs_kb_set_links_s.nextval into l_other_link_id from dual;
            CS_KB_SET_LINKS_PKG.Insert_Row(
              X_Rowid => l_other_rowid,
              X_Link_Id => l_other_link_id,
              X_Link_type => p_link_type,
              X_Object_Code => p_object_code,
              X_Set_Id => l_other_soln_ver_id,
              X_Other_Id => p_other_id,
              X_Creation_Date => l_date,
              X_Created_By => l_created_by,
              X_Last_Update_Date => l_date,
              X_Last_Updated_By => l_created_by,
              X_Last_Update_Login => l_login,
              X_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
              X_ATTRIBUTE1 => P_ATTRIBUTE1,
              X_ATTRIBUTE2 => P_ATTRIBUTE2,
              X_ATTRIBUTE3 => P_ATTRIBUTE3,
              X_ATTRIBUTE4 => P_ATTRIBUTE4,
              X_ATTRIBUTE5 => P_ATTRIBUTE5,
              X_ATTRIBUTE6 => P_ATTRIBUTE6,
              X_ATTRIBUTE7 => P_ATTRIBUTE7,
              X_ATTRIBUTE8 => P_ATTRIBUTE8,
              X_ATTRIBUTE9 => P_ATTRIBUTE9,
              X_ATTRIBUTE10 => P_ATTRIBUTE10,
              X_ATTRIBUTE11 => P_ATTRIBUTE11,
              X_ATTRIBUTE12 => P_ATTRIBUTE12,
              X_ATTRIBUTE13 => P_ATTRIBUTE13,
              X_ATTRIBUTE14 => P_ATTRIBUTE14,
              X_ATTRIBUTE15 => P_ATTRIBUTE15
            );
          END IF;
      END IF;
  END IF;
  x_link_id := l_id;
  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('in csl when others ');
    ROLLBACK TO Create_Link_SP;
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.LEVEL_UNEXPECTED, 'cs.plsql.cs_kb_set_links.create_set_link', SQLERRM );
    end if;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    FND_MSG_PUB.Add;
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
end Create_Set_Link;

-- As of bug 3407999, I split the creation into two functions, which will call
-- the same base function.
-- Create_Set_Link will be used for feed back purpose, will update the latest
--   verion if it is different. Group APIs using  Create_Set_Link all use it for
--   feed back purpose. So I let this function keep the name.
-- Create_set_Ext_Link will be used for external object purpose. Only update
--   the current version.
-- The original Create_Set_Link accept one more param P_UPDATE_EXTRA_VERSIONSION.
--
PROCEDURE Create_Set_Link(
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  x_link_id     in OUT NOCOPY           NUMBER,
  x_return_status  OUT NOCOPY           VARCHAR2,
  x_msg_data       OUT NOCOPY           VARCHAR2,
  x_msg_count      OUT NOCOPY           NUMBER
  ) IS
BEGIN
   Create_Set_Link(
     P_LINK_TYPE          => P_LINK_TYPE         ,
     P_OBJECT_CODE        => P_OBJECT_CODE       ,
     P_SET_ID             => P_SET_ID            ,
     P_OTHER_ID           => P_OTHER_ID          ,
     P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
     P_ATTRIBUTE1         => P_ATTRIBUTE1        ,
     P_ATTRIBUTE2         => P_ATTRIBUTE2        ,
     P_ATTRIBUTE3         => P_ATTRIBUTE3        ,
     P_ATTRIBUTE4         => P_ATTRIBUTE4        ,
     P_ATTRIBUTE5         => P_ATTRIBUTE5        ,
     P_ATTRIBUTE6         => P_ATTRIBUTE6        ,
     P_ATTRIBUTE7         => P_ATTRIBUTE7        ,
     P_ATTRIBUTE8         => P_ATTRIBUTE8        ,
     P_ATTRIBUTE9         => P_ATTRIBUTE9        ,
     P_ATTRIBUTE10        => P_ATTRIBUTE10       ,
     P_ATTRIBUTE11        => P_ATTRIBUTE11       ,
     P_ATTRIBUTE12        => P_ATTRIBUTE12       ,
     P_ATTRIBUTE13        => P_ATTRIBUTE13       ,
     P_ATTRIBUTE14        => P_ATTRIBUTE14       ,
     P_ATTRIBUTE15        => P_ATTRIBUTE15       ,
     P_UPDATE_EXTRA_VERSION  => 'Y'                 ,
     x_link_id            => x_link_id           ,
     x_return_status      => x_return_status     ,
     x_msg_data           => x_msg_data          ,
     x_msg_count          => x_msg_count);
END;

--
-- Create a set link entry (old, called by jtt, wrapper of new api)
--
function Create_Set_Link(
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2
) return number IS
  l_link_id NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;
begin
   Create_Set_Link(
     P_LINK_TYPE          => P_LINK_TYPE         ,
     P_OBJECT_CODE        => P_OBJECT_CODE       ,
     P_SET_ID             => P_SET_ID            ,
     P_OTHER_ID           => P_OTHER_ID          ,
     P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
     P_ATTRIBUTE1         => P_ATTRIBUTE1        ,
     P_ATTRIBUTE2         => P_ATTRIBUTE2        ,
     P_ATTRIBUTE3         => P_ATTRIBUTE3        ,
     P_ATTRIBUTE4         => P_ATTRIBUTE4        ,
     P_ATTRIBUTE5         => P_ATTRIBUTE5        ,
     P_ATTRIBUTE6         => P_ATTRIBUTE6        ,
     P_ATTRIBUTE7         => P_ATTRIBUTE7        ,
     P_ATTRIBUTE8         => P_ATTRIBUTE8        ,
     P_ATTRIBUTE9         => P_ATTRIBUTE9        ,
     P_ATTRIBUTE10        => P_ATTRIBUTE10       ,
     P_ATTRIBUTE11        => P_ATTRIBUTE11       ,
     P_ATTRIBUTE12        => P_ATTRIBUTE12       ,
     P_ATTRIBUTE13        => P_ATTRIBUTE13       ,
     P_ATTRIBUTE14        => P_ATTRIBUTE14       ,
     P_ATTRIBUTE15        => P_ATTRIBUTE15       ,
     P_UPDATE_EXTRA_VERSION  => 'Y'                 ,
     x_link_id            => l_link_id           ,
     x_return_status      => l_return_status     ,
     x_msg_data           => l_msg_data          ,
     x_msg_count          => l_msg_count);
   if( l_return_status = FND_API.G_RET_STS_SUCCESS ) then
     return l_link_id;
   else
     return ERROR_STATUS;
   end if;
END Create_Set_Link;

-- create a set link entry
-- this function is same as the previous one, except, it defaults LINK_TYPE to PS
function Create_Set_Link(
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2
) return number IS
  l_link_id NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;
begin
   Create_Set_Link(
     P_LINK_TYPE          => 'PS'                ,
     P_OBJECT_CODE        => P_OBJECT_CODE       ,
     P_SET_ID             => P_SET_ID            ,
     P_OTHER_ID           => P_OTHER_ID          ,
     P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
     P_ATTRIBUTE1         => P_ATTRIBUTE1        ,
     P_ATTRIBUTE2         => P_ATTRIBUTE2        ,
     P_ATTRIBUTE3         => P_ATTRIBUTE3        ,
     P_ATTRIBUTE4         => P_ATTRIBUTE4        ,
     P_ATTRIBUTE5         => P_ATTRIBUTE5        ,
     P_ATTRIBUTE6         => P_ATTRIBUTE6        ,
     P_ATTRIBUTE7         => P_ATTRIBUTE7        ,
     P_ATTRIBUTE8         => P_ATTRIBUTE8        ,
     P_ATTRIBUTE9         => P_ATTRIBUTE9        ,
     P_ATTRIBUTE10        => P_ATTRIBUTE10       ,
     P_ATTRIBUTE11        => P_ATTRIBUTE11       ,
     P_ATTRIBUTE12        => P_ATTRIBUTE12       ,
     P_ATTRIBUTE13        => P_ATTRIBUTE13       ,
     P_ATTRIBUTE14        => P_ATTRIBUTE14       ,
     P_ATTRIBUTE15        => P_ATTRIBUTE15       ,
     P_UPDATE_EXTRA_VERSION  => 'Y'                 ,
     x_link_id            => l_link_id           ,
     x_return_status      => l_return_status     ,
     x_msg_data           => l_msg_data          ,
     x_msg_count          => l_msg_count);
   if( l_return_status = FND_API.G_RET_STS_SUCCESS ) then
     return l_link_id;
   else
     return ERROR_STATUS;
   end if;
END;

PROCEDURE Create_Set_Ext_Link(
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  x_link_id     in OUT NOCOPY           NUMBER,
  x_return_status  OUT NOCOPY           VARCHAR2,
  x_msg_data       OUT NOCOPY           VARCHAR2,
  x_msg_count      OUT NOCOPY           NUMBER
  ) IS
BEGIN
   Create_Set_Link(
     P_LINK_TYPE          => P_LINK_TYPE         ,
     P_OBJECT_CODE        => P_OBJECT_CODE       ,
     P_SET_ID             => P_SET_ID            ,
     P_OTHER_ID           => P_OTHER_ID          ,
     P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
     P_ATTRIBUTE1         => P_ATTRIBUTE1        ,
     P_ATTRIBUTE2         => P_ATTRIBUTE2        ,
     P_ATTRIBUTE3         => P_ATTRIBUTE3        ,
     P_ATTRIBUTE4         => P_ATTRIBUTE4        ,
     P_ATTRIBUTE5         => P_ATTRIBUTE5        ,
     P_ATTRIBUTE6         => P_ATTRIBUTE6        ,
     P_ATTRIBUTE7         => P_ATTRIBUTE7        ,
     P_ATTRIBUTE8         => P_ATTRIBUTE8        ,
     P_ATTRIBUTE9         => P_ATTRIBUTE9        ,
     P_ATTRIBUTE10        => P_ATTRIBUTE10       ,
     P_ATTRIBUTE11        => P_ATTRIBUTE11       ,
     P_ATTRIBUTE12        => P_ATTRIBUTE12       ,
     P_ATTRIBUTE13        => P_ATTRIBUTE13       ,
     P_ATTRIBUTE14        => P_ATTRIBUTE14       ,
     P_ATTRIBUTE15        => P_ATTRIBUTE15       ,
     P_UPDATE_EXTRA_VERSION  => 'N'                 ,
     x_link_id            => x_link_id           ,
     x_return_status      => x_return_status     ,
     x_msg_data           => x_msg_data          ,
     x_msg_count          => x_msg_count);
END;


-- Update a set link entry
-- This is the api to use as of 11.5.10
procedure Update_Set_Link(
  P_LINK_ID in NUMBER,
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_data       OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER
  ) IS

  -- Validation Cursors
  CURSOR Validate_Link IS
   SELECT sl.set_id, sl.object_code, sl.other_id, sb.set_number, sb.status
   FROM CS_KB_SET_LINKS sl, CS_KB_SETS_B sb
   WHERE sl.link_id = P_LINK_ID
     AND sl.set_id = sb.set_id
     AND ( sb.status = 'PUB' OR sb.latest_version_flag = 'Y' );

  -- Cursor to fetch link to latest in-progress version of a solution
  CURSOR Get_Link_To_Latest_Ver(c_soln_number VARCHAR2, c_object_code VARCHAR2,
                                c_other_id NUMBER) IS
   SELECT sl.link_id, sl.set_id
   FROM CS_KB_SET_LINKS sl, CS_KB_SETS_B sb
   WHERE sb.set_number = c_soln_number
     AND sb.latest_version_flag = 'Y'
     AND sb.set_id = sl.set_id
     AND sl.object_code = c_object_code
     AND sl.other_id = c_other_id;

  -- Cursor to fetch link to published version of a solution
  CURSOR Get_Link_To_Published_Ver(c_soln_number VARCHAR2, c_object_code VARCHAR2,
                                c_other_id NUMBER) IS
   SELECT sl.link_id, sl.set_id
   FROM CS_KB_SET_LINKS sl, CS_KB_SETS_B sb
   WHERE sb.set_number = c_soln_number
     AND sb.status = 'PUB'
     AND sb.set_id = sl.set_id
     AND sl.object_code = c_object_code
     AND sl.other_id = c_other_id;

  l_orig_set_id NUMBER;
  l_orig_object_code VARCHAR2(30);
  l_orig_other_id NUMBER;
  l_orig_soln_number VARCHAR2(30);
  l_orig_soln_status VARCHAR2(30);
  l_other_link_id NUMBER;
  l_other_soln_id NUMBER;

  l_date  date;
  l_updated_by number;
  l_login number;
BEGIN
 SAVEPOINT Update_Link_SP;

 -- Begin Validation
  -- validate params
  if( P_LINK_ID     is null
      OR P_OBJECT_CODE is null
      OR P_SET_ID      is NULL
      OR P_OTHER_ID    is null
      OR p_link_type   is null ) THEN
    fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
    fnd_msg_pub.Add;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    return;
  end if;

  -- validate the link type
  IF ( P_LINK_TYPE not in ('PS', 'S', 'NS') ) THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_LINK_TYPE');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    return;
  END IF;

  -- validate that the link being updated exists and the link being
  -- updated is to either a published or latest solution version.
  OPEN  Validate_Link;
  FETCH Validate_Link INTO l_orig_set_id, l_orig_object_code, l_orig_other_id,
                           l_orig_soln_number, l_orig_soln_status;
  IF ( Validate_Link%NOTFOUND ) THEN
   CLOSE Validate_Link;
   FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_SOLN_LINK_ID');
   FND_MSG_PUB.ADD;
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                             p_count   => X_MSG_COUNT,
                             p_data    => X_MSG_DATA);
   X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
   return;
  ELSE
   CLOSE Validate_Link;
  END IF;

  -- Validate that the update doesn't change the solution version
  -- to which the link is pointing to and also doesn't change the
  -- object code and id of the object it's pointing to. You can only
  -- update the link type for an existing link.
  IF ( l_orig_set_id <> P_SET_ID
       OR l_orig_object_code <> P_OBJECT_CODE
       OR l_orig_other_id <> P_OTHER_ID ) THEN
   FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_SOLN_LINK_UPDATE');
   FND_MSG_PUB.ADD;
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                             p_count   => X_MSG_COUNT,
                             p_data    => X_MSG_DATA);
   X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
   return;
  END IF;
 -- End Validation

  --prepare data, then update the solution link
  l_date := sysdate;
  l_updated_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  CS_KB_SET_LINKS_PKG.Update_Row(
    X_Link_Id => p_link_id,
    X_Link_type => p_link_type,
    X_Object_Code => p_object_code,
    X_Set_Id => p_set_id,
    X_Other_Id => p_other_id,
    X_Last_Update_Date => l_date,
    X_Last_Updated_By => l_updated_by,
    X_Last_Update_Login => l_login,
    X_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1 => P_ATTRIBUTE1,
    X_ATTRIBUTE2 => P_ATTRIBUTE2,
    X_ATTRIBUTE3 => P_ATTRIBUTE3,
    X_ATTRIBUTE4 => P_ATTRIBUTE4,
    X_ATTRIBUTE5 => P_ATTRIBUTE5,
    X_ATTRIBUTE6 => P_ATTRIBUTE6,
    X_ATTRIBUTE7 => P_ATTRIBUTE7,
    X_ATTRIBUTE8 => P_ATTRIBUTE8,
    X_ATTRIBUTE9 => P_ATTRIBUTE9,
    X_ATTRIBUTE10 => P_ATTRIBUTE10,
    X_ATTRIBUTE11 => P_ATTRIBUTE11,
    X_ATTRIBUTE12 => P_ATTRIBUTE12,
    X_ATTRIBUTE13 => P_ATTRIBUTE13,
    X_ATTRIBUTE14 => P_ATTRIBUTE14,
    X_ATTRIBUTE15 => P_ATTRIBUTE15);

   -- Raise Business Event when a solution link is updated
   CS_KB_SET_LINKS_PKG.Raise_Soln_Link_Updated_Event(
     p_set_id      => p_set_id,
     p_object_code => p_object_code,
     p_object_id   => p_other_id,
     p_link_id     => p_link_id,
     p_link_type   => p_link_type,
     p_event_date  => l_date );

  -- If the link being updated is to a published version of a solution,
  -- the same update needs to be made to the same link to the latest
  -- version of the solution.
  -- If the link being updated is to a WIP version, the same should be
  -- propergated to the published version.
  IF ( l_orig_soln_status = 'PUB') THEN
      OPEN Get_Link_To_Latest_Ver(l_orig_soln_number, p_object_code, p_other_id);
      FETCH Get_Link_To_Latest_Ver into l_other_link_id, l_other_soln_id;
      IF ( Get_Link_To_Latest_Ver%NOTFOUND ) THEN
        l_other_link_id := null;
        l_other_soln_id := null;
      END IF;
      CLOSE Get_Link_To_Latest_Ver;
  ELSE
      OPEN Get_Link_To_Published_Ver(l_orig_soln_number, p_object_code, p_other_id);
      FETCH Get_Link_To_Published_Ver into l_other_link_id, l_other_soln_id;
      IF ( Get_Link_To_Published_Ver%NOTFOUND ) THEN
        l_other_link_id := null;
        l_other_soln_id := null;
      END IF;
      CLOSE Get_Link_To_Published_Ver;
  END IF;
  IF ( l_other_link_id is not null
        and l_other_link_id <> p_link_id ) THEN
      CS_KB_SET_LINKS_PKG.Update_Row(
        X_Link_Id => l_other_link_id,
        X_Link_type => p_link_type,
        X_Object_Code => p_object_code,
        X_Set_Id => l_other_soln_id,
        X_Other_Id => p_other_id,
        X_Last_Update_Date => l_date,
        X_Last_Updated_By => l_updated_by,
        X_Last_Update_Login => l_login,
        X_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => P_ATTRIBUTE1,
        X_ATTRIBUTE2 => P_ATTRIBUTE2,
        X_ATTRIBUTE3 => P_ATTRIBUTE3,
        X_ATTRIBUTE4 => P_ATTRIBUTE4,
        X_ATTRIBUTE5 => P_ATTRIBUTE5,
        X_ATTRIBUTE6 => P_ATTRIBUTE6,
        X_ATTRIBUTE7 => P_ATTRIBUTE7,
        X_ATTRIBUTE8 => P_ATTRIBUTE8,
        X_ATTRIBUTE9 => P_ATTRIBUTE9,
        X_ATTRIBUTE10 => P_ATTRIBUTE10,
        X_ATTRIBUTE11 => P_ATTRIBUTE11,
        X_ATTRIBUTE12 => P_ATTRIBUTE12,
        X_ATTRIBUTE13 => P_ATTRIBUTE13,
        X_ATTRIBUTE14 => P_ATTRIBUTE14,
        X_ATTRIBUTE15 => P_ATTRIBUTE15);
  END IF;
  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

exception
  when others then
    ROLLBACK TO Update_Link_SP;
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.LEVEL_UNEXPECTED, 'cs.plsql.cs_kb_set_links.update_set_link', SQLERRM );
    end if;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    FND_MSG_PUB.Add;
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
END Update_Set_Link;

-- Deprecated as of 11.5.10. Call new Update_Set_link spec.
function Update_Set_Link(
  P_LINK_ID in NUMBER,
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2
) return number is
  l_return_status VARCHAR2(1);
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;
begin
   Update_Set_Link(
     P_LINK_ID            => P_LINK_ID           ,
     P_LINK_TYPE          => P_LINK_TYPE         ,
     P_OBJECT_CODE        => P_OBJECT_CODE       ,
     P_SET_ID             => P_SET_ID            ,
     P_OTHER_ID           => P_OTHER_ID          ,
     P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
     P_ATTRIBUTE1         => P_ATTRIBUTE1        ,
     P_ATTRIBUTE2         => P_ATTRIBUTE2        ,
     P_ATTRIBUTE3         => P_ATTRIBUTE3        ,
     P_ATTRIBUTE4         => P_ATTRIBUTE4        ,
     P_ATTRIBUTE5         => P_ATTRIBUTE5        ,
     P_ATTRIBUTE6         => P_ATTRIBUTE6        ,
     P_ATTRIBUTE7         => P_ATTRIBUTE7        ,
     P_ATTRIBUTE8         => P_ATTRIBUTE8        ,
     P_ATTRIBUTE9         => P_ATTRIBUTE9        ,
     P_ATTRIBUTE10        => P_ATTRIBUTE10       ,
     P_ATTRIBUTE11        => P_ATTRIBUTE11       ,
     P_ATTRIBUTE12        => P_ATTRIBUTE12       ,
     P_ATTRIBUTE13        => P_ATTRIBUTE13       ,
     P_ATTRIBUTE14        => P_ATTRIBUTE14       ,
     P_ATTRIBUTE15        => P_ATTRIBUTE15       ,
     x_return_status      => l_return_status     ,
     x_msg_data           => l_msg_data          ,
     x_msg_count          => l_msg_count);
   if( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
     return ERROR_STATUS;
   end if;
   return OKAY_STATUS;
end Update_Set_Link;

function Delete_Set_Link_W_Obj_Code(
  p_set_id        in Number,
  p_object_code   in Varchar2,
  p_other_id      in Number
) return number is
  cursor get_link_id( c_set_id NUMBER, c_object_code VARCHAR2,
                      c_other_id NUMBER )IS
    select link_id
    from cs_kb_set_links
    where set_id = c_set_id
      and object_code = c_object_code
      and other_id = c_other_id;

  l_link_id NUMBER;
  l_ret_val NUMBER;
begin
  if(P_SET_ID is null or
    P_OBJECT_CODE is null OR P_OTHER_ID is NULL ) then
    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    return ERROR_STATUS;
  end if;

  OPEN get_link_id( p_set_id, p_object_code, p_other_id );
  FETCH get_link_id INTO l_link_id;
  IF ( get_link_id%NOTFOUND ) THEN
    CLOSE get_link_id;
    return ERROR_STATUS;
  ELSE
    CLOSE get_link_id;
    l_ret_val := Delete_Set_Link( l_link_id );
    return l_ret_val;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    return ERROR_STATUS;
end Delete_Set_Link_W_Obj_Code;


function Delete_Set_Link(
  P_LINK_ID in NUMBER
) return number is
  -- Cursor to validate link exists and is to either a published solution
  -- version or an in-progress version.
  cursor Valid_Link IS
    select sb.set_number, sb.status, sl.object_code, sl.other_id
    from cs_kb_set_links sl, cs_kb_sets_b sb
    where sl.link_id = P_LINK_ID
      and sl.set_id = sb.set_id
      and ( sb.status = 'PUB' or sb.latest_version_flag = 'Y' );

  -- Cursor to fetch link to latest in-progress version of a solution
  CURSOR Get_Link_To_Other_Ver(c_soln_number VARCHAR2, c_object_code VARCHAR2,
                                c_other_id NUMBER) IS
   SELECT sl.link_id
   FROM CS_KB_SET_LINKS sl, CS_KB_SETS_B sb
   WHERE sb.set_number = c_soln_number
     AND (sb.latest_version_flag = 'Y' or sb.status = 'PUB')
     AND sb.set_id = sl.set_id
     AND sl.object_code = c_object_code
     AND sl.other_id = c_other_id;

  l_soln_number VARCHAR2(30);
  l_soln_status VARCHAR2(30);
  l_link_object_code VARCHAR2(30);
  l_link_other_id NUMBER;
  l_other_link_id NUMBER;
begin
  SAVEPOINT Delete_Link_SP;

  -- Begin Validation

  -- validate parameter
  if (P_LINK_ID is null ) then
    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    return ERROR_STATUS;
  end if;

  -- make sure the link exists and is to either a published solution version
  -- or the latest in progress version
  OPEN Valid_Link;
  FETCH Valid_Link into l_soln_number, l_soln_status, l_link_object_code,
                        l_link_other_id;
  IF( Valid_Link%NOTFOUND ) THEN
    CLOSE Valid_Link;
    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_INV_API_SOLN_LINK_ID');
      fnd_msg_pub.Add;
    end if;
    return ERROR_STATUS;
  END IF;
  CLOSE Valid_Link;

  -- End Validation

  delete from CS_KB_SET_LINKS
  where LINK_ID = P_LINK_ID;

  -- If the link being deleted is to the published version of a solution,
  -- see if there is a corresponding link to the latest in-progress version.
  -- If so, then delete
  -- If the link being deleted is to a WIP version, check if there is a link
  -- to the published version, if yes. Delete it.
  OPEN Get_Link_To_Other_Ver(l_soln_number, l_link_object_code,
                              l_link_other_id);
  FETCH Get_Link_To_Other_Ver into l_other_link_id;
  IF ( Get_Link_To_Other_Ver%NOTFOUND ) THEN
    l_other_link_id := null;
  END IF;
  CLOSE Get_Link_To_Other_Ver;

  -- The link which link id is P_LINK_ID is already deleted. l_link_other_id is
  -- not null, then it must be the extra verion to be deleted.
  IF ( l_other_link_id is not null) THEN
    delete from CS_KB_SET_LINKS
    where LINK_ID = l_other_link_id;
  END IF;

  return OKAY_STATUS;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO Delete_Link_SP;
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.LEVEL_UNEXPECTED, 'cs.plsql.cs_kb_set_links.delete_set_link', SQLERRM );
    end if;
     if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
      FND_MSG_PUB.Add;
    END IF;
    return ERROR_STATUS;
end Delete_Set_Link;

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_LINK_ID in NUMBER,
  X_LINK_TYPE in VARCHAR2,
  X_OBJECT_CODE in VARCHAR2,
  X_SET_ID in NUMBER,
  X_OTHER_ID in NUMBER,
  --X_OTHER_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2) IS

  cursor C is select ROWID from CS_KB_SET_LINKS where LINK_ID = X_LINK_ID;


BEGIN


  insert into CS_KB_SET_LINKS (
    LINK_ID,
    LINK_TYPE,
    OBJECT_CODE,
    SET_ID,
    OTHER_ID,
    --OTHER_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY,
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
  ) values (
    X_LINK_ID,
    X_LINK_TYPE,
    X_OBJECT_CODE,
    X_SET_ID,
    X_OTHER_ID,
    --X_OTHER_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15
    );

  open c;
  fetch c into X_ROWID;

  if (c%notfound) then
      close c;
      raise no_data_found;
  end if;

  close c;

END INSERT_ROW;

procedure UPDATE_ROW (
  X_LINK_ID in NUMBER,
  X_LINK_TYPE in VARCHAR2,
  X_OBJECT_CODE in VARCHAR2,
  X_SET_ID in NUMBER,
  X_OTHER_ID in NUMBER,
  --X_OTHER_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2
) IS

BEGIN

  update CS_KB_SET_LINKS set

    LINK_TYPE = X_LINK_TYPE,
    OBJECT_CODE = X_OBJECT_CODE,
    SET_ID = X_SET_ID,
    OTHER_ID  = X_OTHER_ID,
    --OTHER_CODE = X_OTHER_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY =  X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15
  where LINK_ID = X_LINK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END UPDATE_ROW;

procedure Raise_Solution_Linked_Event(
   p_set_id NUMBER,
   p_object_code VARCHAR2,
   p_object_id   VARCHAR2,
   p_link_id     NUMBER,
   p_link_type   VARCHAR2,
   p_event_date  DATE
) is
   l_param_list   wf_parameter_list_t;
   l_set_number   VARCHAR2(30);
   l_status       VARCHAR2(30);
   l_access_level NUMBER;
begin
    -- NOTE: access level for solutions has no meaning for 11510 and beyond.
    select set_number, access_level, status
    into l_set_number, l_access_level, l_status
    from CS_KB_SETS_B
    where set_id  = p_set_id;

   /*** Set up the parameter list ***/
   wf_event.AddParameterToList(
      p_name  => 'SOLUTION_NUMBER',
      p_value => l_set_number,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'OBJECT_CODE',
      p_value => p_object_code,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'OBJECT_ID',
      p_value => p_object_id,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'LINK_ID',
      p_value => p_link_id,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'LINK_TYPE',
      p_value => p_link_type,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'STATUS',
      p_value => l_status,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'ACCESS_LEVEL',
      p_value => l_access_level,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'USER_ID',
      p_value => fnd_global.user_id,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'RESP_ID',
      p_value => fnd_global.resp_id,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'RESP_APPL_ID',
      p_value => fnd_global.resp_appl_id,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'EVENT_DATE',
      p_value => to_char(p_event_date),
      p_parameterlist => l_param_list
   );

   /*** Raise SolutionLinked event ***/
   wf_event.raise(
      p_event_name => 'oracle.apps.cs.knowledge.SolutionLinked',
      p_event_key => to_char( sysdate, 'YYYYMMDD HH24MISS') ,
      p_parameters => l_param_list
   );

   l_param_list.DELETE;

end Raise_Solution_Linked_Event;

procedure Raise_Soln_Link_Updated_Event(
   p_set_id            NUMBER,
   p_object_code       VARCHAR2,
   p_object_id         VARCHAR2,
   p_link_id           NUMBER,
   p_link_type         VARCHAR2,
   p_event_date        DATE
) is
   l_param_list   wf_parameter_list_t;
   l_set_number   VARCHAR2(30);
   l_status       VARCHAR2(30);
begin
    select set_number, status
    into l_set_number, l_status
    from CS_KB_SETS_B
    where set_id  = p_set_id;

   /*** Set up the parameter list ***/
   wf_event.AddParameterToList(
      p_name  => 'LINK_ID',
      p_value => p_link_id,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'SOLUTION_NUMBER',
      p_value => l_set_number,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'OBJECT_CODE',
      p_value => p_object_code,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'OBJECT_ID',
      p_value => p_object_id,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'LINK_TYPE',
      p_value => p_link_type,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'STATUS',
      p_value => l_status,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'USER_ID',
      p_value => fnd_global.user_id,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'RESP_ID',
      p_value => fnd_global.resp_id,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'RESP_APPL_ID',
      p_value => fnd_global.resp_appl_id,
      p_parameterlist => l_param_list
   );

   wf_event.AddParameterToList(
      p_name  => 'EVENT_DATE',
      p_value => to_char(p_event_date),
      p_parameterlist => l_param_list
   );

   /*** Raise SolutionLinkUpdated event ***/
   wf_event.raise(
      p_event_name => 'oracle.apps.cs.knowledge.SolutionLink.Updated',
      p_event_key => to_char( sysdate, 'YYYYMMDD HH24MISS') ,
      p_parameters => l_param_list
   );

   l_param_list.DELETE;

end Raise_Soln_Link_Updated_Event;


end CS_KB_SET_LINKS_PKG;

/
