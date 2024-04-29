--------------------------------------------------------
--  DDL for Package Body CS_SRCONTACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SRCONTACT_PKG" AS
/* $Header: cssrcpb.pls 120.9.12010000.4 2010/05/14 22:20:58 siahmed ship $*/
TYPE NUM_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--------------------------------------------------------------------------------
-- Procedure Name : check_duplicates
-- Parameters     :
-- IN             : p_mode            it indicates SR API. it could be CREATE or
--                                    UPDATE
--                : p_incident_id     Service Request Identifier
--                : p_new_contact_tbl SR Contact passed to SR API
--                : p_updated_cp_qry  Partial where clause having updated
--                                    contact points
--                : p_updated_cp_bind An array of Contact point Ids that are
--                                    being updated by SR API call
-- OUT            : x_return_status Error condition indicator
--
--
-- Description    : This procedure gets the list of all contact records from
--                  database that are not being updated in SR API call.
--                  Then it checks for duplicate entries in p_new_contact_tbl
--                  if no duplicate entries are found then it looks for
--                  duplicates between input records and not updated contact
--                  records. If a duplucate is found then x_return_status is
--                  set to Error otherwise it is set to success.
--                  A record is considered duplicate if it has same value of
--                  contact type, party id, contact point type, contact point
--                  id, party role code and overlapping start and end dates
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 10/21/05 smisra   Created
-- 10/25/05 smisrs   Added a new parameter p_mode to check_duplicates and
--                   executed the code to get not updated contacts only for
--                   update SR API.
--------------------------------------------------------------------------------
PROCEDURE check_duplicates
( p_mode                IN         VARCHAR2
, p_new_contact_tbl     IN         CS_SERVICEREQUEST_PVT.contacts_table
, p_updated_cp_qry      IN         VARCHAR2
, p_updated_cp_bind     IN         NUM_TBL
, p_incident_id         IN         NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
) IS
l_not_updated_contacts CS_SERVICEREQUEST_PVT.contacts_table;
--
l_sql VARCHAR2(4000);
l_cur_hdl INT;
l_rows_processed BINARY_INTEGER;
--
l_index     NUMBER;
l_dup_found NUMBER;
--
l_st_dt1    DATE;
l_st_dt2    DATE;
l_end_dt1   DATE;
l_end_dt2   DATE;
--
l_party_id           NUMBER;
l_contact_point_id   NUMBER;
l_contact_type       VARCHAR2(30);
l_party_role_code    VARCHAR2(30);
l_contact_point_type VARCHAR2(30);
l_end_date_active    DATE;
l_start_date_active  DATE;
l_dup_role           CS_HZ_SR_CONTACT_POINTS.party_role_code % TYPE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- For SR Create API, no need to look for existing contact record because
  -- there will be none.
  IF p_mode <> 'CREATE'
  THEN
    l_sql := 'SELECT contact_type, party_id, party_role_code, contact_point_id, contact_point_type, start_date_active, end_date_active
              FROM   cs_hz_sr_contact_points
              WHERE  incident_id = :incident_id
               /* AND  TRUNC(SYSDATE) BETWEEN NVL(start_date_active, TRUNC(SYSDATE))
                                        AND NVL(end_date_active  , TRUNC(SYSDATE)) */';
    IF p_updated_cp_qry <> ':1'
    THEN
      l_sql := l_sql || ' AND sr_contact_point_id NOT IN ( '|| p_updated_cp_qry || ')';
    END IF;

    l_cur_hdl := dbms_sql.open_cursor;
    DBMS_SQL.parse(l_cur_hdl, l_sql, DBMS_SQL.NATIVE);
    --
    DBMS_SQL.bind_variable(l_cur_hdl, ':incident_id' , p_incident_id);
    IF p_updated_cp_qry <> ':1'
    THEN
      FOR indx in p_updated_cp_bind.FIRST..p_updated_cp_bind.LAST
      LOOP
        DBMS_SQL.bind_variable(l_cur_hdl, ':' ||to_char(indx), p_updated_cp_bind(indx));
      END LOOP;
    END IF;
    DBMS_SQL.define_column(l_cur_hdl, 1, l_contact_type, 30);
    DBMS_SQL.define_column(l_cur_hdl, 2, l_party_id);
    DBMS_SQL.define_column(l_cur_hdl, 3, l_party_role_code, 30);
    DBMS_SQL.define_column(l_cur_hdl, 4, l_contact_point_id);
    DBMS_SQL.define_column(l_cur_hdl, 5, l_contact_point_type, 30);
    DBMS_SQL.define_column(l_cur_hdl, 6, l_start_date_active);
    DBMS_SQL.define_column(l_cur_hdl, 7, l_end_date_active);
    l_rows_processed := DBMS_SQL.execute(l_cur_hdl);
    l_index := 0;
    LOOP
      IF DBMS_SQL.fetch_rows(l_cur_hdl) > 0
      THEN
        l_index := l_index + 1;
        DBMS_SQL.column_value(l_cur_hdl, 1, l_contact_type);
        DBMS_SQL.column_value(l_cur_hdl, 2, l_party_id          );
        DBMS_SQL.column_value(l_cur_hdl, 3, l_party_role_code   );
        DBMS_SQL.column_value(l_cur_hdl, 4, l_contact_point_id  );
        DBMS_SQL.column_value(l_cur_hdl, 5, l_contact_point_type);
        DBMS_SQL.column_value(l_cur_hdl, 6, l_start_date_active );
        DBMS_SQL.column_value(l_cur_hdl, 7, l_end_date_active   );
        l_not_updated_contacts(l_index).party_id           := l_party_id;
        l_not_updated_contacts(l_index).contact_type       := l_contact_type;
        l_not_updated_contacts(l_index).party_role_code    := l_party_role_code;
        l_not_updated_contacts(l_index).end_date_active    := l_end_date_active;
        l_not_updated_contacts(l_index).contact_point_id   := l_contact_point_id;
        l_not_updated_contacts(l_index).start_date_active  := l_start_date_active;
        l_not_updated_contacts(l_index).contact_point_type := l_contact_point_type;
      ELSE
        EXIT;
      END IF;
    END LOOP;
    DBMS_SQL.close_cursor(l_cur_hdl);
  END IF;
    --
    --
    --
  l_dup_found := 0;
  IF p_new_contact_tbl.COUNT > 0
  THEN
  FOR i in p_new_contact_tbl.FIRST..p_new_contact_tbl.LAST
  LOOP

    l_st_dt1  := NVL(p_new_contact_tbl(i).start_date_active  , TRUNC(SYSDATE-36500));
    l_end_dt1 := NVL(p_new_contact_tbl(i).end_date_active    , TRUNC(SYSDATE+36500));
    -- if you are not at the last record, look for this and next record for duplicates
    IF i < p_new_contact_tbl.LAST
    THEN
      FOR j in i+1..p_new_contact_tbl.LAST
      LOOP
        l_st_dt2  := NVL(p_new_contact_tbl(j).start_date_active, TRUNC(SYSDATE-36500));
        l_end_dt2 := NVL(p_new_contact_tbl(j).end_date_active  , TRUNC(SYSDATE+36500));
        IF p_new_contact_tbl(i).party_id           = p_new_contact_tbl(j).party_id           AND
           p_new_contact_tbl(i).contact_type       = p_new_contact_tbl(j).contact_type       AND
           p_new_contact_tbl(i).party_role_code    = p_new_contact_tbl(j).party_role_code    AND
           NVL(p_new_contact_tbl(i).contact_point_id  ,-99) = NVL(p_new_contact_tbl(j).contact_point_id  ,-99) AND
           NVL(p_new_contact_tbl(i).contact_point_type,'-') = NVL(p_new_contact_tbl(j).contact_point_type,'-') AND
           ( l_st_dt1 BETWEEN l_st_dt2 AND l_end_dt2 OR
             l_st_dt2 BETWEEN l_st_dt1 AND l_end_dt1
           )
        THEN
          l_dup_found := 1;
          l_dup_role  := p_new_contact_tbl(i).party_role_code;
          EXIT;
        END IF;
      END LOOP;
      -- if duplicate contaqct is found among input records, no need to check any further
      IF l_dup_found <> 0
      THEN
        EXIT;
      END IF;
    END IF; -- end of condition IF i < p_new_contact_tbl.LAST
    -- Check if this record is same as any existing record that is not being updated.
    IF l_not_updated_contacts.count > 0
    THEN
      FOR k in l_not_updated_contacts.FIRST..l_not_updated_contacts.LAST
      LOOP
        l_st_dt2  := NVL(l_not_updated_contacts(k).start_date_active, TRUNC(SYSDATE-36500));
        l_end_dt2 := NVL(l_not_updated_contacts(k).end_date_active  , TRUNC(SYSDATE+36500));
        IF p_new_contact_tbl(i).party_id           = l_not_updated_contacts(k).party_id           AND
           p_new_contact_tbl(i).contact_type       = l_not_updated_contacts(k).contact_type       AND
           p_new_contact_tbl(i).party_role_code    = l_not_updated_contacts(k).party_role_code    AND
           NVL(p_new_contact_tbl(i).contact_point_id  ,-99) = NVL(l_not_updated_contacts(k).contact_point_id  ,-99) AND
           NVL(p_new_contact_tbl(i).contact_point_type,'-') = NVL(l_not_updated_contacts(k).contact_point_type,'-') AND
           ( l_st_dt1  BETWEEN l_st_dt2 AND l_end_dt2 OR
             l_st_dt2 BETWEEN  l_st_dt1 AND l_end_dt1
           )
        THEN
          l_dup_found := 1;
          l_dup_role  := p_new_contact_tbl(i).party_role_code;
          EXIT;
        END IF;
      END LOOP;
      -- if duplicate contaqct is found among input records, no need to check any further
      IF l_dup_found <> 0
      THEN
        EXIT;
      END IF;
    END IF; --end of condition IF l_not_updated_contacts.count > 0
  END LOOP;
  IF l_dup_found <> 0
  THEN
    x_return_status := FND_API.g_ret_sts_error;
    IF l_dup_role = 'CONTACT'
    THEN
      FND_MESSAGE.set_name ('CS', 'CS_SR_DUP_CONTACT_PARTY');
    ELSE
      FND_MESSAGE.set_name ('CS', 'CS_SR_DUP_ASSOC_PARTY');
    END IF;
    FND_MESSAGE.set_token ('API_NAME','CS_SRCONTACT_PKG.check_duplicates');
    FND_MSG_PUB.ADD;
  END IF;
  END IF;
EXCEPTION
  WHEN OTHERS
  THEN
    x_return_status := FND_API.g_ret_sts_error;
    FND_MESSAGE.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    FND_MESSAGE.set_token('P_TEXT','CS_SRCONTACT_PKG.check_duplicates:'||'-'||SQLERRM);
    FND_MSG_PUB.ADD;
END check_duplicates;
--------------------------------------------------------------------------------
-- Function  Name : contact_role_count
-- Parameters     :
-- IN             : p_incident_id Service Request Identifier
-- Return Value   : Number
--
--
-- Description    : For a given service request, this function returns acitve
--                  contact points having role as CONTACT
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 10/06/05 smisra   Created
--------------------------------------------------------------------------------
FUNCTION contact_role_count
( p_incident_id     IN  NUMBER
) RETURN NUMBER IS
l_dt     DATE;
l_count  NUMBER;
BEGIN
  l_dt := TRUNC(SYSDATE);
  SELECT COUNT(1)
  INTO   l_count
  FROM   cs_hz_sr_contact_points
  WHERE  incident_id = p_incident_id
    AND  party_role_code = 'CONTACT'
    AND  NVL(END_DATE_ACTIVE,sysdate) >= l_dt
  ;
  RETURN(l_count);
EXCEPTION
  WHEN OTHERS
  THEN
    NULL;
END contact_role_count;
--------------------------------------------------------------------------------
-- Procedure Name :
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description    :
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 04/27/05 smisra   Created
-- 07/27/05 smisra   removed 1 from sequence name
-- 08/17/05 smisra   add primary_flag, old primary flag to insert statement.
--------------------------------------------------------------------------------
Procedure create_cp_audit
( p_sr_contact_point_id IN NUMBER
, p_incident_id     IN  NUMBER
, p_new_cp_rec IN  CS_SERVICEREQUEST_PVT.contacts_rec
, p_old_cp_rec IN  CS_SERVICEREQUEST_PVT.contacts_rec
, p_cp_modified_by    IN  NUMBER
, p_cp_modified_on    IN  DATE
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
) IS
l_dt DATE;
BEGIN
  l_dt := SYSDATE;
  INSERT INTO CS_HZ_SR_CONTACT_PNTS_AUDIT
  ( sr_contact_point_audit_id
  , sr_contact_point_id
  , incident_id
  , party_id
  , old_party_id
  , contact_type
  , old_contact_type
  , party_role_code
  , old_party_role_code
  , contact_point_type
  , old_contact_point_type
  , contact_point_id
  , old_contact_point_id
  , start_date_active
  , old_start_date_active
  , end_date_active
  , old_end_date_active
  , primary_flag
  , old_primary_flag
  , creation_date
  , last_update_date
  , created_by
  , last_updated_by
  , last_update_login
  , contact_point_modified_by
  , contact_point_modified_on
  )
  VALUES
  ( cs.cs_hz_sr_cont_pnts_audit_s.NEXTVAL
  , p_sr_contact_point_id
  , p_incident_id
  , p_new_cp_rec.party_id
  , p_old_cp_rec.party_id
  , p_new_cp_rec.contact_type
  , p_old_cp_rec.contact_type
  , p_new_cp_rec.party_role_code
  , p_old_cp_rec.party_role_code
  , p_new_cp_rec.contact_point_type
  , p_old_cp_rec.contact_point_type
  , p_new_cp_rec.contact_point_id
  , p_old_cp_rec.contact_point_id
  , p_new_cp_rec.start_date_active
  , p_old_cp_rec.start_date_active
  , p_new_cp_rec.end_date_active
  , p_old_cp_rec.end_date_active
  , p_new_cp_rec.primary_flag
  , p_old_cp_rec.primary_flag
  , l_dt
  , l_dt
  , FND_GLOBAL.USER_ID
  , FND_GLOBAL.USER_ID
  , FND_GLOBAL.LOGIN_ID
  , p_cp_modified_by
  , p_cp_modified_on
  );
END create_cp_audit;
--
--------------------------------------------------------------------------------
-- Procedure Name :
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description    :
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 04/15/05 smisra   Created
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Procedure Name : validate_contact
-- Parameters     :
-- IN             : p_caller_type     This is service request customer type.
--                                    It can be ORGANIZATION or PERSON
--                  p_customer_id     Service request customer id. User for
--                                    validation of contact party.
--                  p_new_contact_rec This record contains contact record passed
--                                    to service request API
--                  p_old_contact_rec This record containt value of contact
--                                    record being update. in case of insert
--                                    this record in NULL
-- OUT            : x_return_status   Indicates success or Error condition
--                                    encountered by procedure.
--
-- Description    : This procedure takes old and new value of contact being
--                  processed and validates it. Old value record is needed to
--                  determine if a particular attribute is changed or not.
--                  validation is performed on only changed attributes.
--                  in case of insert, all attributes that are not null are
--                  assumed to be changed attributes.
--
-- Modification History:
-- Date     Name     Desc
-------- ----------- -----------------------------------------------------------
-- 04/15/05 smisra   Created
-- 08/10/05 smisra   Added following validations
--                   Associate party has to exist in hz_parties only. there may
--                   not be any relationship with SR customer
--                   Primary contact can not have end date value
-- 10/05/05 smisra   Change Request: 4645490
--                   Raise error is party_id, contact_type or party_role_code
--                   is updated
-- 10/21/05 smisra   Added a validation that primary contact can not be future
--                   dated
--------------------------------------------------------------------------------
PROCEDURE validate_contact
( p_caller_type     IN         VARCHAR2
, p_customer_id     IN         NUMBER
, p_new_contact_rec IN         CS_SERVICEREQUEST_PVT.contacts_rec
, p_old_contact_rec IN         CS_SERVICEREQUEST_PVT.contacts_rec
, x_return_status   OUT NOCOPY VARCHAR2
) IS
l_api_name_full VARCHAR2(61);
l_employee_name VARCHAR2(80);
l_party_type    cs_hz_sr_contact_points.contact_type % TYPE;
l_status        hz_parties.status                    % TYPE;
p_mode          VARCHAR2(30);
l_today         DATE;
BEGIN
  l_api_name_full := 'CS_SRCONTACT_PKG.validate_contact';
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_today         := TRUNC(SYSDATE);
  -- set p_mode variable.
  -- This could be passed to this procedure too
  IF p_old_contact_rec.party_id IS NULL
  THEN
     p_mode := 'CREATE';
  ELSE
     p_mode := 'UPDATE';
  END IF;
  --
  -- Check for update of non-updatable columns
  --
  IF p_mode = 'UPDATE'
  THEN
    -- check contact type update
    IF p_new_contact_rec.contact_type <> p_old_contact_rec.contact_type
    THEN
      FND_MESSAGE.set_name  ('CS','CS_SR_CP_CONTACT_TYPE_UPD_NA');
      FND_MESSAGE.set_token ('API_NAME','cs_srcontact_pkg.validate_contact');
      FND_MSG_PUB.add_detail( p_associated_column1=>'CS_HZ_SR_CONTACT_POINTS.CONTACT_TYPE');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- check party_id update
    IF p_new_contact_rec.party_id <> p_old_contact_rec.party_id
    THEN
      FND_MESSAGE.set_name  ('CS','CS_SR_CP_PARTY_ID_UPD_NA');
      FND_MESSAGE.set_token ('API_NAME','cs_srcontact_pkg.validate_contact');
      FND_MSG_PUB.add_detail( p_associated_column1=>'CS_HZ_SR_CONTACT_POINTS.PARTY_ID');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- check party_role_code update
    IF p_new_contact_rec.party_role_code <> p_old_contact_rec.party_role_code
    THEN
      FND_MESSAGE.set_name  ('CS','CS_SR_CP_PARTY_ROLE_UPD_NA');
      FND_MESSAGE.set_token ('API_NAME','cs_srcontact_pkg.validate_contact');
      FND_MSG_PUB.add_detail( p_associated_column1=>'CS_HZ_SR_CONTACT_POINTS.PARTY_ROLE_CODE');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF; -- p_mode = 'UPDATE'
  --
  -- Validate Contact Type
  --
  IF p_new_contact_rec.contact_type IS NULL
  THEN
    CS_SERVICEREQUEST_UTIL.add_null_parameter_msg
    ( p_token_an    => l_api_name_full
    , p_token_np    => 'p_contacts.contact_type'
    , p_table_name  => 'CS_HZ_SR_CONTACT_POINTS'
    , p_column_name => 'CONTACT_TYPE'
    );
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_new_contact_rec.contact_type <> NVL(p_old_contact_rec.contact_type,'xx'))
  THEN
    IF NVL(p_new_contact_rec.party_role_code,'x') <> 'CONTACT'
    THEN
      IF p_new_contact_rec.contact_type = 'ORGANIZATION'       OR
         p_new_contact_rec.contact_type = 'PARTY_RELATIONSHIP' OR
         p_new_contact_rec.contact_type = 'PERSON'             OR
         p_new_contact_rec.contact_type = 'EMPLOYEE'
      THEN
        NULL;
      ELSE
        CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
        ( p_token_an    =>  l_api_name_full
        , p_token_v     =>  p_new_contact_rec.contact_type
        , p_token_p     =>  'p_contacts.contact_type'
        , p_table_name  => 'CS_HZ_SR_CONTACT_POINTS'
        , p_column_name => 'CONTACT_TYPE'
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE -- party role code is CONTACT
      IF (p_new_contact_rec.contact_type  = 'EMPLOYEE' OR
          p_new_contact_rec.contact_type  = 'ORGANIZATION' OR
          p_new_contact_rec.contact_type  = 'PARTY_RELATIONSHIP' OR
          (p_new_contact_rec.contact_type = 'PERSON' AND
           p_caller_type = 'PERSON')
         )
      THEN
        NULL;
        -- contact type is valid. do nothing.
      ELSE
        CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
                 p_token_an    =>  l_api_name_full,
                 p_token_v     =>  p_new_contact_rec.contact_type,
                 p_token_p     =>  'p_contacts.contact_type' ,
                 p_table_name  => 'CS_HZ_SR_CONTACT_POINTS',
                 p_column_name => 'CONTACT_TYPE');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF; -- party_role_code = contact
  END IF;  -- for change in contact type
  --
  -- Validate Contact Party
  --
  IF p_new_contact_rec.party_id IS NULL
  THEN
    CS_SERVICEREQUEST_UTIL.add_null_parameter_msg
    ( p_token_an    => l_api_name_full,
      p_token_np    => 'p_contacts.party_id',
      p_table_name  => 'CS_HZ_SR_CONTACT_POINTS',
      p_column_name => 'PARTY_ID'
    );
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_new_contact_rec.contact_type    <> NVL(p_old_contact_rec.contact_type   , 'xx')    OR
         p_new_contact_rec.party_id        <> NVL(p_old_contact_rec.party_id       , -1  )    OR
         p_new_contact_rec.party_role_code <> NVL(p_old_contact_rec.party_role_code, 'CONTACT'))
  THEN
    IF (p_new_contact_rec.contact_type = 'EMPLOYEE') THEN
      CS_ServiceRequest_UTIL.Validate_Employee
      ( p_api_name          => l_api_name_full
      , p_parameter_name    => 'p_employee_id'
      , p_employee_id       => p_new_contact_rec.party_id
      , p_org_id            => NULL
      , p_employee_name     => l_employee_name
      , x_return_status     => x_return_status
      );
    ELSIF NVL(p_new_contact_rec.party_role_code,'CONTACT') <> 'CONTACT'
    -- Else condition means contact type is either person, org or relationship
    -- so if party role is CONTACT then do not validation relationship between
    -- SR customer and contact party. contact party should merely exist in
    -- hz_parties table
    THEN
      CS_SERVICEREQUEST_UTIL.get_party_details
      ( p_party_id => p_new_contact_rec.party_id
      , x_party_type => l_party_type
      , x_status     => l_status
      , x_return_status => x_return_status
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        FND_MESSAGE.set_name('CS','CS_SR_ASSOC_PARTY_NE');
        FND_MESSAGE.set_token('API_NAME','cs_srcontact_pkg.validate_contact');
        FND_MESSAGE.set_token('PARTY_ID',p_new_contact_rec.party_id);
        FND_MSG_PUB.add_detail
        ( p_associated_column1=>'CS_HZ_SR_CONTACT_POINTS.PARTY_ID'
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF l_status <> 'A'
      THEN
        FND_MESSAGE.set_name('CS','CS_SR_ASSOC_PARTY_INACTIVE');
        FND_MESSAGE.set_token('API_NAME','cs_srcontact_pkg.validate_contact');
        FND_MESSAGE.set_token('PARTY_ID',p_new_contact_rec.party_id);
        FND_MSG_PUB.add_detail
        ( p_associated_column1=>'CS_HZ_SR_CONTACT_POINTS.PARTY_ID'
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF l_party_type <> p_new_contact_rec.contact_type
      THEN
        FND_MESSAGE.set_name('CS','CS_SR_ASSOC_PARTYTYPE_MISMATCH');
        FND_MESSAGE.set_token('API_NAME','cs_srcontact_pkg.validate_contact');
        FND_MESSAGE.set_token('CONTACT_TYPE',l_party_type);
        FND_MSG_PUB.add_detail
        ( p_associated_column1=>'CS_HZ_SR_CONTACT_POINTS.PARTY_ID'
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
    -- This part means party role is not contact and contact type is not employee
    -- so validate contact party and SR customer using relationship between them
      IF p_caller_type = 'ORGANIZATION'
      THEN
        CS_ServiceRequest_UTIL.Validate_Org_Relationship
          ( p_api_name            => l_api_name_full,
            p_parameter_name      => 'p_party_id',
            p_customer_contact_id => p_new_contact_rec.party_id,
            p_customer_id         => p_customer_id,
            p_org_id              => NULL,
            x_return_status       => x_return_status)  ;
      ELSE
        CS_ServiceRequest_UTIL.Validate_Person_Relationship
          ( p_api_name           => l_api_name_full,
            p_parameter_name       => 'p_party_id',
            p_customer_contact_id  => p_new_contact_rec.party_id,
            p_customer_id          => p_customer_id,
            p_org_id               => NULL,
            x_return_status        => x_return_status)  ;
      END IF;
    END IF; -- for party role_code condition
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;   -- for change in contact pe or party id
  --
  -- Validate Contact point Type
  --
  IF (p_new_contact_rec.contact_point_type IS NOT NULL AND
      p_new_contact_rec.contact_point_type <>
        NVL(p_old_contact_rec.contact_point_type,'-9'))
  THEN
    CS_ServiceRequest_UTIL.validate_contact_point_type
    ( p_api_name           => l_api_name_full
    , p_parameter_name     => 'p_contact_point_type'
    , p_contact_point_type => p_new_contact_rec.contact_point_type
    , x_return_status      => x_return_status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  --
  -- Validate Contact Point Id
  --
  IF (p_new_contact_rec.contact_point_id IS NOT NULL AND
       (p_new_contact_rec.contact_point_id <> NVL(p_old_contact_rec.contact_point_id,-9) OR
        NVL(p_new_contact_rec.contact_point_type,'-9') <>
          NVL(p_old_contact_rec.contact_point_type,'-9') ))
  THEN
    IF p_new_contact_rec.contact_type = 'EMPLOYEE'
    THEN
      IF (p_new_contact_rec.contact_point_type = 'PHONE') THEN
        CS_ServiceRequest_UTIL.Validate_Emp_Contact_Point_Id
        ( p_api_name         => l_api_name_full
        , p_parameter_name   => 'p_contact_point_id'
        , p_employee_id      => p_new_contact_rec.party_id
        , p_contact_point_id => p_new_contact_rec.contact_point_id
        , x_return_status    => x_return_status );
      ELSIF (p_new_contact_rec.contact_point_type <> 'EMAIL') THEN
        -- Added this logic for bug#2626855, if the contact_type is
        -- Employee and the contact_point_type is other than email or
        -- phone then give error else success.
        CS_SERVICEREQUEST_UTIL.add_invalid_argument_msg
        ( p_token_an    => l_api_name_full
        , p_token_v     => p_new_contact_rec.contact_point_type
        , p_token_p     => 'p_contact_point_type'
        , p_table_name  => 'CS_HZ_SR_CONTACT_POINTS'
        , p_column_name => 'CONTACT_POINT_TYPE'
        );
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    ELSE -- Contact type is either PERSON or PARTY_RELATIONSHIP
      CS_ServiceRequest_UTIL.Validate_Per_Contact_Point_Id
      ( p_api_name           => l_api_name_full
      , p_parameter_name     => 'p_contact_point_id'
      , p_contact_point_type => p_new_contact_rec.contact_point_type
      , p_contact_point_id   => p_new_contact_rec.contact_point_id
      , p_party_id           => p_new_contact_rec.party_id
      , x_return_status      => x_return_status
      );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF; -- validate contact point id
  --
  -- validate Party role
  --
  IF p_new_contact_rec.party_role_code IS NOT NULL AND
     p_new_contact_rec.party_role_code <> NVL(p_old_contact_rec.party_role_code,'#')
  THEN
    CS_SERVICEREQUEST_UTIL.validate_party_role_code
    ( p_new_contact_rec.party_role_code
    , x_return_status
    );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  -- validate primary flag and party role combination
  IF p_new_contact_rec.primary_flag = 'Y' AND
     p_new_contact_rec.party_role_code <> 'CONTACT'
  THEN
    FND_MESSAGE.set_name('CS','CS_SR_PRIMARY_CONTACT_ROLE');
    FND_MESSAGE.set_token('API_NAME','cs_srcontact_pkg.validate_contact');
    FND_MSG_PUB.add_detail(p_associated_column1=>'CS_HZ_SR_CONTACT_POINTS.PRIMARY_FLAG');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --Added by Lakshmi for  12.1.2 project,Added another 'AND' condition ,
  --To throw an error is a primary contact is endated and Profile 'CS_SR_CONTACT_MANDATORY' is set to Yes.
  IF p_new_contact_rec.primary_flag = 'Y' AND
     p_new_contact_rec.end_date_active IS NOT NULL AND
     FND_PROFILE.value('CS_SR_CONTACT_MANDATORY') = 'Y'
  THEN
    FND_MESSAGE.set_name('CS','CS_SR_PRIMARY_END_DATED');
    FND_MESSAGE.set_token('API_NAME','cs_srcontact_pkg.validate_contact');
    FND_MSG_PUB.add_detail(p_associated_column1=>'CS_HZ_SR_CONTACT_POINTS.PRIMARY_FLAG');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  IF p_new_contact_rec.primary_flag = 'Y' AND
     p_new_contact_rec.start_date_active > l_today
  THEN
    FND_MESSAGE.set_name('CS','CS_SR_PRIMARY_FUTURE_DATED');
    FND_MESSAGE.set_token('API_NAME','cs_srcontact_pkg.validate_contact');
    FND_MSG_PUB.add_detail(p_associated_column1=>'CS_HZ_SR_CONTACT_POINTS.PRIMARY_FLAG');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- validate Start and End date
  --
  IF p_new_contact_rec.end_date_active   IS NOT NULL AND
     p_new_contact_rec.start_date_active IS NOT NULL AND
     p_new_contact_rec.end_date_active <  p_new_contact_rec.start_date_active
  THEN
    FND_MESSAGE.set_name('CS','CS_SR_CP_ENDDT_LT_STARTDT');
    FND_MESSAGE.set_token('API_NAME','cs_srcontact_pkg.validate_contact');
    FND_MESSAGE.set_token('END_DT',to_char(p_new_contact_rec.end_date_active));
    FND_MESSAGE.set_token('START_DT',to_char(p_new_contact_rec.start_date_active));
    FND_MSG_PUB.add_detail(p_associated_column1=>'CS_HZ_SR_CONTACT_POINTS.END_DATE_ACITVE');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg('aa', l_api_name_full);
    END IF;
END validate_contact;
--------------------------------------------------------------------------------
-- Procedure Name : process_g_miss
-- Parameters     :
-- IN             : p_mode            This can be CREATE or UPDATE. If mode is
--                                    not equal to CREATE then corresponding
--                                    record in database is access for replacing
--                                    g_miss with exisitng values.
--                  p_new_contact_rec This record contains contact record passed
--                                    to service request API
--                  x_new_contact_rec p_new_contact_rec with g_miss values
--                                    replaced by either NULL or from database
--                  p_old_contact_rec This record containt value of contact
--                                    record being update. in case of insert
--                                    this record in NULL
-- OUT            : x_return_status   Indicates success or Error condition
--                                    encountered by procedure.
--
-- Description    : This procedure check new contact record and if any value if
--                  missing then it is set to it's value in old contact record.
--
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 04/15/05 smisra   Created
-- 08/10/05 smisra   Defaulted party role code to contact if it is NULL
-- 10/21/05 smisra   Bug 4074184
--                   prepared a list of contact points being updated and
--                   partial where clause for updated contact points
--                   Truncated active start and end dates
--
-- 11/03/06 spusegao Modified Process_GMISS procedure to CLOSE the cursor immediately after
--                   FETCH to resolve the issue described in bug 5629281.
--                   (ORA-06511: PL/SQL: cursor already open)
--
-- -----------------------------------------------------------------------------
PROCEDURE process_g_miss
( p_mode            IN            VARCHAR2
, p_incident_id     IN            NUMBER
, p_new_contact_tbl IN            CS_SERVICEREQUEST_PVT.contacts_table
, x_new_contact_tbl    OUT NOCOPY CS_SERVICEREQUEST_PVT.contacts_table
, x_old_contact_tbl    OUT NOCOPY CS_SERVICEREQUEST_PVT.contacts_table
, x_updated_cp_qry     OUT NOCOPY VARCHAR2
, x_updated_cp_bind    OUT NOCOPY NUM_TBL
, x_return_status      OUT NOCOPY VARCHAR2
) IS
l_incident_id    CS_INCIDENTS_ALL_B.incident_id % type;
l_updated_cp_index NUMBER;
--
CURSOR c_sr_contact (p_sr_contact_point_id NUMBER) IS
  SELECT
    sr_contact_point_id
  , party_id
  , contact_point_id
  , contact_point_type
  , contact_type
  , primary_flag
  , party_role_code
  , start_date_active
  , end_date_active
  , incident_id
  FROM
    cs_hz_sr_contact_points
  WHERE sr_contact_point_id = p_sr_contact_point_id;
BEGIN
  x_new_contact_tbl := p_new_contact_tbl;
  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  x_updated_cp_qry := ':1';
  l_updated_cp_index := 1;
  x_updated_cp_bind(l_updated_cp_index) := -1;
  FOR i in x_new_contact_tbl.FIRST..x_new_contact_tbl.LAST LOOP
    x_old_contact_tbl(i) := NULL;
    IF x_new_contact_tbl(i).sr_contact_point_id IS NOT NULL AND
       x_new_contact_tbl(i).sr_contact_point_id <> FND_API.G_MISS_NUM
    -- so that in update mode, old record is accessed
    -- if caller passed misspelled p_mode, no harm is done. only record
    -- will be accessed and nothing will be found
    THEN
      OPEN c_sr_contact(x_new_contact_tbl(i).sr_contact_point_id);
      FETCH c_sr_contact
      INTO
        x_old_contact_tbl(i).sr_contact_point_id
      , x_old_contact_tbl(i).party_id
      , x_old_contact_tbl(i).contact_point_id
      , x_old_contact_tbl(i).contact_point_type
      , x_old_contact_tbl(i).contact_type
      , x_old_contact_tbl(i).primary_flag
      , x_old_contact_tbl(i).party_role_code
      , x_old_contact_tbl(i).start_date_active
      , x_old_contact_tbl(i).end_date_active
      , l_incident_id;

	 CLOSE c_sr_contact;

--      IF c_sr_contact%FOUND   -- Coommented to resolve bug # 5629281.
      IF x_old_contact_tbl(i).sr_contact_point_id IS NOT NULL
      THEN
        -- in case of insert, p_incident_id will be null
        IF NVL(p_incident_id,-1) <> l_incident_id
        THEN
          FND_MESSAGE.set_name('CS', 'CS_SR_CP_DO_NOT_BELONGS');
          FND_MESSAGE.set_token
          ( 'CP_ID'
          , TO_CHAR(x_new_contact_tbl(i).sr_contact_point_id)
          );
          FND_MESSAGE.set_token
          ( 'INC_ID'
          , TO_CHAR(p_incident_id)
          );
          FND_MSG_PUB.ADD_DETAIL(P_ASSOCIATED_COLUMN1=>'CS_HZ_SR_CONTACT_POINTS.SR_CONTACT_POINT_ID');
          x_return_status   := FND_API.G_RET_STS_ERROR;
          EXIT;
        END IF;
        l_updated_cp_index       := l_updated_cp_index + 1;
        x_updated_cp_qry         :=
          x_updated_cp_qry || ', :' || to_char(l_updated_cp_index);
        x_updated_cp_bind(l_updated_cp_index) := x_old_contact_tbl(i).sr_contact_point_id;
 --       CLOSE c_sr_contact;   -- Coommented to resolve bug # 5629281.
      END IF;
    END IF;
    IF x_new_contact_tbl(i).party_id            = FND_API.G_MISS_NUM
    THEN
       x_new_contact_tbl(i).party_id           := x_old_contact_tbl(i).party_id;
    END IF;
    IF x_new_contact_tbl(i).contact_type        = FND_API.G_MISS_CHAR
    THEN
       x_new_contact_tbl(i).contact_type       := x_old_contact_tbl(i).contact_type;
    END IF;
    IF x_new_contact_tbl(i).primary_flag        = FND_API.G_MISS_CHAR
    THEN
       x_new_contact_tbl(i).primary_flag       := x_old_contact_tbl(i).primary_flag;
    END IF;
    IF x_new_contact_tbl(i).contact_point_id    = FND_API.G_MISS_NUM
    THEN
       x_new_contact_tbl(i).contact_point_id   := x_old_contact_tbl(i).contact_point_id;
    END IF;
    IF x_new_contact_tbl(i).contact_point_type  = FND_API.G_MISS_CHAR
    THEN
       x_new_contact_tbl(i).contact_point_type := x_old_contact_tbl(i).contact_point_type;
    END IF;
    IF x_new_contact_tbl(i).sr_contact_point_id = FND_API.G_MISS_NUM
    THEN
       x_new_contact_tbl(i).sr_contact_point_id:= x_old_contact_tbl(i).sr_contact_point_id;
    END IF;
    IF x_new_contact_tbl(i).party_role_code     = FND_API.G_MISS_CHAR
    THEN
       x_new_contact_tbl(i).party_role_code    := x_old_contact_tbl(i).party_role_code;
    END IF;
    IF x_new_contact_tbl(i).party_role_code IS NULL
    THEN
       x_new_contact_tbl(i).party_role_code    := 'CONTACT';
    END IF;
    IF x_new_contact_tbl(i).start_date_active   = FND_API.G_MISS_DATE
    THEN
       x_new_contact_tbl(i).start_date_active  := x_old_contact_tbl(i).start_date_active;
    END IF;
    IF x_new_contact_tbl(i).end_date_active     = FND_API.G_MISS_DATE
    THEN
       x_new_contact_tbl(i).end_date_active    := x_old_contact_tbl(i).end_date_active;
    END IF;
    x_new_contact_tbl(i).start_date_active  := TRUNC(x_new_contact_tbl(i).start_date_active);
    x_new_contact_tbl(i).end_date_active    := TRUNC(x_new_contact_tbl(i).end_date_active);
  END LOOP;
END process_g_miss;
--------------------------------------------------------------------------------
-- Procedure Name :
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description    :
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 04/15/05 smisra   Created
--------------------------------------------------------------------------------
FUNCTION new_primary
( p_new_contact_tbl     IN  CS_SERVICEREQUEST_PVT.contacts_table
, p_old_contact_tbl IN  CS_SERVICEREQUEST_PVT.contacts_table
, x_return_status   OUT NOCOPY VARCHAR2
) RETURN NUMBER IS
BEGIN
  FOR loop_index in p_new_contact_tbl.FIRST..p_new_contact_tbl.LAST
  LOOP
    IF p_new_contact_tbl(loop_index).primary_flag = 'Y'
    THEN
      -- if new contact is called primary but old record does not call
      -- it primary then there must be other primary contact in database
      IF NVL(p_old_contact_tbl(loop_index).primary_flag,'N') <> 'Y'
      THEN
        RETURN 'Y';
      END IF;
    END IF;
  END LOOP;
  RETURN 'N';
END new_primary;
--
--------------------------------------------------------------------------------
-- Procedure Name :
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description    :
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 04/15/05 smisra   Created
-- 10/05/05 smisra   Change Request : 4645490
--                   Called create_cp_audit only if profile to audit contact
--                   points is enabled.
--                   Removed party_id, contact_type and party_role_code from
--                   update statement as these attributes can not be updated.
--------------------------------------------------------------------------------
PROCEDURE create_update
( p_incident_id     IN  NUMBER
, p_invocation_mode IN  VARCHAR2
, p_sr_update_date  IN  DATE
, p_sr_updated_by   IN  VARCHAR2
, p_sr_update_login IN  VARCHAR2
, p_contact_tbl     IN  CS_SERVICEREQUEST_PVT.contacts_table
, p_old_contact_tbl IN  CS_SERVICEREQUEST_PVT.contacts_table
, x_return_status   OUT NOCOPY VARCHAR2
) IS
--
l_audit_id            NUMBER;
l_msg_data            VARCHAR2(2000);
l_msg_count           NUMBER;
l_activity_code       VARCHAR2(1);
l_sr_contact_point_id NUMBER;
l_sysdate             DATE;
l_add_audit           VARCHAR2(1);
l_audit_enabled       fnd_profile_option_values.profile_option_value % TYPE;
--
BEGIN
   --siahmed added to disable auditing if invocation_mode is set to replay
   --before there was no if condition it was just the following commented line
  --l_audit_enabled := FND_PROFILE.value('CS_SR_CONT_PNT_AUDIT_ENABLED');
  IF (p_invocation_mode = 'REPLAY' ) THEN
     l_audit_enabled := 'N';
  ELSE
     l_audit_enabled := FND_PROFILE.value('CS_SR_CONT_PNT_AUDIT_ENABLED');
  END IF;
  --end of change siahmed

  IF p_contact_tbl.COUNT = 0
  THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;

  l_sysdate := sysdate;
  FOR loop_index in p_contact_tbl.FIRST..p_contact_tbl.LAST LOOP
    l_add_audit := 'N';
    IF p_old_contact_tbl(loop_index).sr_contact_point_id is NULL
    THEN
      SELECT cs_hz_sr_contact_points_s.NEXTVAL
      INTO l_sr_contact_point_id
      FROM DUAL;
      l_activity_code       := 'C';
      --
      l_add_audit := 'Y';
      INSERT INTO cs_hz_sr_contact_points
      ( sr_contact_point_id
      , party_id
      , incident_id
      , contact_point_type
      , contact_type
      , contact_point_id
      , primary_flag
      , party_role_code
      , start_date_active
      , end_date_active
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , last_update_login
      , object_version_number)
      VALUES
      ( l_sr_contact_point_id
      , p_contact_tbl(loop_index).party_id
      , p_incident_id
      , p_contact_tbl(loop_index).contact_point_type
      , p_contact_tbl(loop_index).contact_type
      , p_contact_tbl(loop_index).contact_point_id
      , p_contact_tbl(loop_index).primary_flag
      , NVL(p_contact_tbl(loop_index).party_role_code,'CONTACT')
      , p_contact_tbl(loop_index).start_date_active
      , p_contact_tbl(loop_index).end_date_active
      , p_sr_update_date
      , p_sr_updated_by
      , p_sr_update_date
      , p_sr_updated_by
      , p_sr_update_login
      , 1 );
    -- Else statement does not compare party_id, contact_type nd party role because
    -- these can not be updated.
    ELSIF (NVL(p_contact_tbl(loop_index).contact_point_type,'xz')        <>
             NVL(p_old_contact_tbl(loop_index).contact_point_type,'xz')     OR
           NVL(p_contact_tbl(loop_index).contact_point_id ,-99)          <>
             NVL(p_old_contact_tbl(loop_index).contact_point_id,-99)        OR
           NVL(p_contact_tbl(loop_index).start_date_active,l_sysdate)    <>
             NVL(p_old_contact_tbl(loop_index).start_date_active,l_sysdate) OR
           NVL(p_contact_tbl(loop_index).end_date_active,l_sysdate)      <>
             NVL(p_old_contact_tbl(loop_index).end_date_active,l_sysdate)   OR
           NVL(p_contact_tbl(loop_index).primary_flag,'N')               <>
             NVL(p_old_contact_tbl(loop_index).primary_flag,'N') )
    THEN
      l_add_audit           := 'Y';
      l_activity_code       := 'U';
      l_sr_contact_point_id := p_contact_tbl(loop_index).sr_contact_point_id;
      -- update statement does not include party id, contact type and party role code because
      -- these attributes can not be updated.
      UPDATE cs_hz_sr_contact_points
      SET primary_flag          = p_contact_tbl(loop_index).primary_flag
      ,   contact_point_id      = p_contact_tbl(loop_index).contact_point_id
      ,   contact_point_type    = p_contact_tbl(loop_index).contact_point_type
      ,   start_date_active     = p_contact_tbl(loop_index).start_date_active
      ,   end_date_active       = p_contact_tbl(loop_index).end_date_active
      ,   last_updated_by       = p_sr_updated_by
      ,   last_update_date      = p_sr_update_date
      ,   last_update_login     = p_sr_update_login
      ,   object_version_number = object_version_number+1
      WHERE sr_contact_point_id = l_sr_contact_point_id;
    END IF;
    --- Create Child audit
    IF l_add_audit = 'Y'
    THEN
      CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
      ( p_incident_id           => p_incident_id
      , p_updated_entity_code   => 'SR_CONTACT_POINT'
      , p_updated_entity_id     => l_sr_contact_point_id
      , p_entity_update_date    => p_sr_update_date
      , p_entity_activity_code  => l_activity_code
      , x_audit_id              => l_audit_id
      , x_return_status         => x_return_status
      , x_msg_count             => l_msg_count
      , x_msg_data              => l_msg_data
      );
      IF l_audit_enabled = 'Y'
      THEN
        create_cp_audit
        ( p_sr_contact_point_id => l_sr_contact_point_id
        , p_incident_id         => p_incident_id
        , p_new_cp_rec          => p_contact_tbl(loop_index)
        , p_old_cp_rec          => p_old_contact_tbl(loop_index)
        , p_cp_modified_by      => p_sr_updated_by
        , p_cp_modified_on      => p_sr_update_date
        , x_return_status       => x_return_status
        , x_msg_count           => l_msg_count
        , x_msg_data            => l_msg_data
        );
      END IF;
    END IF;
    /*
    */
  END LOOP;
END CREATE_UPDATE;
-- -----------------------------------------------------------------------------
-- Procedure Name :
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description    :
--
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 04/15/05 smisra   Created
-- 10/06/05 smisra   Added audit of contact point record if primary flag is
--                   set to N
-- -----------------------------------------------------------------------------
PROCEDURE reset_primary_flag
( p_incident_id         IN  NUMBER
, p_sr_contact_point_id IN  NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
) IS
l_new_cp_rec CS_SERVICEREQUEST_PVT.contacts_rec;
l_old_cp_rec CS_SERVICEREQUEST_PVT.contacts_rec;
l_msg_count  NUMBER;
l_msg_data   VARCHAR2(4000);
l_audit_enabled       fnd_profile_option_values.profile_option_value % TYPE;
BEGIN
  l_audit_enabled := FND_PROFILE.value('CS_SR_CONT_PNT_AUDIT_ENABLED');
  UPDATE cs_hz_sr_contact_points
     SET primary_flag = 'N'
   WHERE incident_id = p_incident_id
     AND primary_flag = 'Y'
     AND sr_contact_point_id <> NVL(p_sr_contact_point_id,-9)
   RETURNING
    sr_contact_point_id ,
    party_id            ,
    contact_point_id    ,
    primary_flag        ,
    contact_point_type  ,
    contact_type        ,
    party_role_code     ,
    start_date_active   ,
    end_date_active
  INTO l_new_cp_rec
  ;
  IF SQL%FOUND AND
     l_audit_enabled = 'Y'
  THEN
    l_old_cp_rec := l_new_cp_rec;
    l_old_cp_rec.primary_flag := 'Y';
    create_cp_audit
    ( p_sr_contact_point_id => l_new_cp_rec.sr_contact_point_id
    , p_incident_id         => p_incident_id
    , p_new_cp_rec          => l_new_cp_rec
    , p_old_cp_rec          => l_old_cp_rec
    , p_cp_modified_by      => NULL
    , p_cp_modified_on      => NULL
    , x_return_status       => x_return_status
    , x_msg_count           => l_msg_count
    , x_msg_data            => l_msg_data
    );
  END IF;
EXCEPTION
  WHEN OTHERS
  THEN
    NULL;
END reset_primary_flag;
-- -----------------------------------------------------------------------------
-- Procedure Name :
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description    :
--
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 04/15/05 smisra   Created
-- 10/06/05 smisra   Modified this procedure so that primary contact checks are
--                   performed only if contact table has atleat one contact
--                   point record with role as CONTACT
-- 10/21/05 smisra   Called check_duplicates to fix bug 4074184
-- 10/25/05 smisra   Passed p_mode to check_duplicates procedure
-- -----------------------------------------------------------------------------
PROCEDURE process
( p_mode                     IN  VARCHAR2
, p_incident_id              IN  NUMBER
, p_caller_type              IN  VARCHAR2
, p_customer_id              IN  NUMBER
, p_validation_mode          IN  NUMBER
, p_contact_tbl              IN  CS_SERVICEREQUEST_PVT.contacts_table
, x_contact_tbl              OUT NOCOPY CS_SERVICEREQUEST_PVT.contacts_table
, x_old_contact_tbl          OUT NOCOPY CS_SERVICEREQUEST_PVT.contacts_table
, x_primary_party_id         OUT NOCOPY NUMBER
, x_primary_contact_point_id OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
) IS
--
l_primary_found            number;
l_new_contact_tbl          CS_SERVICEREQUEST_PVT.contacts_table;
l_old_contact_tbl          CS_SERVICEREQUEST_PVT.contacts_table;
l_api_name_full            VARCHAR2(61);
l_existing_primary         NUMBER;
l_contact_party_role_found NUMBER := 0;
l_updated_cp_qry           VARCHAR2(4000);
l_updated_cp_bind          NUM_TBL;

--Start Change ,Added by Lakshmi,for 12.1.2 project
l_primary_contact_id       NUMBER := 0;
l_counter                  NUMBER := 0;
l_primary_contact_type     VARCHAR2(30) := null;
l_last_name                varchar2(50) := null;
l_first_name               varchar2(50) := null;
l_inact_prm_contact        varchar2(5) := null;
l_prm_contact_mand         varchar2(5) := null;
--End of change

CURSOR c_primary_count IS
  SELECT
    party_id
  , DECODE(contact_point_type,'PHONE',contact_point_id,NULL)
  FROM
     cs_hz_sr_contact_points
  WHERE incident_id = p_incident_id
    AND primary_flag = 'Y';
l_sr_contact_point_id_pri NUMBER;
l_today                   DATE;
--
BEGIN
  l_api_name_full := 'CS_SRCONTACT_PKG.process';
  x_return_Status := FND_API.G_RET_STS_SUCCESS;
  l_today         := TRUNC(SYSDATE);
  l_primary_found := 0;
  IF p_contact_tbl.COUNT = 0
  THEN
    RETURN;
  END IF;
  process_g_miss
  ( p_mode            => p_mode
  , p_incident_id     => p_incident_id
  , p_new_contact_tbl => p_contact_tbl
  , x_new_contact_tbl => l_new_contact_tbl
  , x_old_contact_tbl => l_old_contact_tbl
  , x_updated_cp_qry  => l_updated_cp_qry
  , x_updated_cp_bind => l_updated_cp_bind
  , x_return_status   => x_return_status
  );
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  -- Check for primary if contacts are being passed
  --
  FOR loop_index in l_new_contact_tbl.FIRST..l_new_contact_tbl.LAST LOOP
    IF NVL(l_new_contact_tbl(loop_index).party_role_code,'CONTACT') = 'CONTACT' AND
       NVL(l_new_contact_tbl(loop_index).end_date_active,l_today) >= l_today
    THEN
       l_contact_party_role_found := l_contact_party_role_found + 1 ;
    END IF ;

    IF l_new_contact_tbl(loop_index).primary_flag = 'Y'
    THEN
      l_primary_found := l_primary_found + 1;
      x_primary_party_id := l_new_contact_tbl(loop_index).party_id;
      l_sr_contact_point_id_pri := l_new_contact_tbl(loop_index).sr_contact_point_id;
      IF l_new_contact_tbl(loop_index).contact_point_type = 'PHONE'
      THEN
        x_primary_contact_point_id := l_new_contact_tbl(loop_index).contact_point_id;
      END IF;
    END IF;
  END LOOP;

  -- if any contact party is found only then we need to check
  -- for single primary contact
  IF l_contact_party_role_found > 0
  THEN
    IF l_primary_found >= 2
    THEN
      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
      ( p_token_an    => l_api_name_full
      , p_token_v     => 'Y'
      , p_token_p     => 'p_contacts.primary_flag'
      , p_table_name  => 'CS_HZ_SR_CONTACT_POINTS'
      , p_column_name => 'PRIMARY_FLAG'
      );
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_primary_found = 0
    THEN
      l_existing_primary := 0;
      IF p_mode <> 'CREATE'
      THEN
        OPEN  c_primary_count;
        FETCH c_primary_count
        INTO x_primary_party_id, x_primary_contact_point_id;
        IF c_primary_count % FOUND
        THEN
          l_existing_primary := 1;
        END IF;
        CLOSE c_primary_count;
      END IF;
      IF l_existing_primary = 0
      THEN
         CS_SERVICEREQUEST_UTIL.add_null_parameter_msg
         ( p_token_an => l_api_name_full
         , p_token_np => 'Primary Contact Information'
         );
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE -- means primary contact count is exactly 1. in case of update mode
         -- existing primary cantact should be made non primary.
      IF p_mode <> 'CREATE'
      THEN
        IF l_sr_contact_point_id_pri = FND_API.G_MISS_NUM
        THEN
          l_sr_contact_point_id_pri := NULL;
        END IF;
        reset_primary_flag(p_incident_id, l_sr_contact_point_id_pri, x_return_status);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;
  END IF; -- l_contact_party_role_found
  --
  -- Now Validate contact records
  --
  IF p_validation_mode > FND_API.G_VALID_LEVEL_NONE
  THEN
    FOR loop_index in l_new_contact_tbl.FIRST..l_new_contact_tbl.LAST LOOP
--  Commented for 12.1.2 project ,end-dating contact points,Lakshmi
/*   IF l_primary_found = 0 AND
         l_old_contact_tbl(loop_index).primary_flag =  'Y' AND -- if it is null, no execution
         NVL(l_new_contact_tbl(loop_index).primary_flag,'N') <> 'Y'
      THEN
        IF NVL(l_new_contact_tbl(loop_index).end_date_active, l_today) >= l_today OR
           contact_role_count(p_incident_id) > 1
        THEN
           FND_MESSAGE.set_name('CS', 'CS_SR_NO_PRIMARY_LEFT');
           FND_MESSAGE.set_token ('API_NAME','cs_srcontact_pkg.process');
           FND_MESSAGE.set_token
           ( 'INC_ID'
           , TO_CHAR(l_new_contact_tbl(loop_index).sr_contact_point_id)
           );
           FND_MSG_PUB.ADD_DETAIL(P_ASSOCIATED_COLUMN1=>'CS_HZ_SR_CONTACT_POINTS.PRIMARY_FLAG');
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;*/
      -- Comment ends for 12.1.2 project ,end-dating contact points
      validate_contact
      ( p_caller_type     => p_caller_type
      , p_customer_id     => p_customer_id
      , p_new_contact_rec => l_new_contact_tbl(loop_index)
      , p_old_contact_rec => l_old_contact_tbl(loop_index)
      , x_return_status   => x_return_status
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    --
    -- Check for duplicate contact point Records
    --
    check_duplicates
    ( p_mode                => p_mode
    , p_new_contact_tbl     => l_new_contact_tbl
    , p_updated_cp_qry      => l_updated_cp_qry
    , p_updated_cp_bind     => l_updated_cp_bind
    , p_incident_id         => p_incident_id
    , x_return_status       => x_return_status
    );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --Lakshmi - 12.1.2 Nov Project -Change starts for End Dating Contact
     IF l_new_contact_tbl.count = 1 -- IF THERE ONLY ONE CONTACT
      THEN
      IF NVL(l_new_contact_tbl(1).party_role_code,'CONTACT') = 'CONTACT'
	       AND l_new_contact_tbl(1).end_date_active IS NOT NULL
               AND FND_PROFILE.value('CS_SR_CONTACT_MANDATORY') = 'Y'
	 THEN
	      l_primary_contact_type := l_new_contact_tbl(1).CONTACT_TYPE;
	      l_primary_contact_id := l_new_contact_tbl(1).PARTY_ID;
	      l_prm_contact_mand := 'Y';

	 END IF; --Profile value check,If profile is 'N' continue with inactivating
     ELSE -- else contact_tbl  >1
        FOR loop_index in l_new_contact_tbl.FIRST..l_new_contact_tbl.LAST LOOP
            IF NVL(l_new_contact_tbl(loop_index).party_role_code,'CONTACT') = 'CONTACT' AND
	       l_new_contact_tbl(loop_index).end_date_active IS NOT NULL
             THEN
	         l_counter := l_counter+1;
		 IF l_new_contact_tbl(loop_index).PRIMARY_FLAG = 'Y'
		 THEN
		    l_primary_contact_id := l_new_contact_tbl(loop_index).PARTY_ID;
		    l_primary_contact_type := l_new_contact_tbl(loop_index).CONTACT_TYPE;
                 END IF;
              END IF;
        END lOOP;
	IF l_counter = l_new_contact_tbl.count
	   AND FND_PROFILE.value('CS_SR_CONTACT_MANDATORY') = 'Y'
	THEN
	     l_inact_prm_contact := 'Y';
	ELSIF l_counter <> l_new_contact_tbl.count
	      AND l_primary_contact_id <> 0
        THEN
	       	l_prm_contact_mand := 'Y';
         END IF;

     END IF;  -- END OF else of contact >1
     IF l_primary_contact_id <> 0
     THEN
	IF l_primary_contact_type = 'EMPLOYEE'
	THEN
	       select LAST_NAME,FIRST_NAME into l_last_name,l_first_name
	       from PER_ALL_PEOPLE_F  where person_id = l_primary_contact_id;
	ELSIF l_primary_contact_type = 'PERSON'
	THEN
		select PERSON_LAST_NAME,PERSON_FIRST_NAME into l_last_name,l_first_name
		from HZ_PARTIES where party_id = l_primary_contact_id;
	ELSIF l_primary_contact_type = 'PARTY_RELATIONSHIP'
	THEN
		select PERSON_LAST_NAME,PERSON_FIRST_NAME into l_last_name,l_first_name
		from HZ_PARTIES p, HZ_RELATIONSHIPS r
		where r.party_id = l_primary_contact_id
		and r.subject_id = p.party_id
		and r.subject_type = 'PERSON'
		and r.subject_table_name = 'HZ_PARTIES'
		and r.directional_flag = 'F';
	END IF;
        IF l_prm_contact_mand = 'Y'
        THEN
	    FND_MESSAGE.set_name  ('CS','CS_SR_CONTACT_POINT_MANDATORY');
	ELSIF l_inact_prm_contact = 'Y'
	THEN
	    FND_MESSAGE.set_name  ('CS','CS_SR_INACT_PRIMARY_CONTACT');
	END IF;


	FND_MESSAGE.set_token ('CONTACT_LAST_NAME',l_last_name);
	FND_MESSAGE.set_token ('CONTACT_FIRST_NAME',l_first_name);
	FND_MSG_PUB.add;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

    --End of changes for 12.1.2 -End Dating Contact by Lakshmi
  END IF; -- check for validation level
  x_contact_tbl     := l_new_contact_tbl;
  x_old_contact_tbl := l_old_contact_tbl;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg('aa', l_api_name_full);
    END IF;
END process;

--------------------------------------------------------------------------------
-- Procedure Name : populate_cp_audit_rec
-- Parameters     :
-- IN             : p_sr_contact_point_id - Contact point identifier.
-- OUT            : x_cp_contact_rec This is a populated audit record.
--                : x_return_status   Indicates success or Error condition
--                                    encountered by procedure.
--                  x_msg_count
--                  x_msg_data
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 11/23/2005  spusegao created
--------------------------------------------------------------------------------

PROCEDURE Populate_CP_Audit_Rec
 (p_sr_contact_point_id  IN        NUMBER,
  x_sr_contact_rec      OUT NOCOPY CS_SERVICEREQUEST_PVT.CONTACTS_REC,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2) IS

--Local Variabled


-- Get contact point details.
   CURSOR c_get_cp_details IS
          SELECT *
            FROM cs_hz_sr_contact_points
           WHERE sr_contact_point_id = p_sr_contact_point_id ;

BEGIN
--  Get contact point details for the passed contact point identifier.
    FOR c_get_cp_details_rec IN c_get_cp_details
        LOOP
           x_sr_contact_rec.sr_contact_point_id   := c_get_cp_details_rec.sr_contact_point_id;
           x_sr_contact_rec.party_id              := c_get_cp_details_rec.party_id;
           x_sr_contact_rec.contact_point_id      := c_get_cp_details_rec.contact_point_id;
           x_sr_contact_rec.primary_flag          := c_get_cp_details_rec.primary_flag;
           x_sr_contact_rec.contact_point_type    := c_get_cp_details_rec.contact_point_type;
           x_sr_contact_rec.contact_type          := c_get_cp_details_rec.contact_type;
           x_sr_contact_rec.party_role_code       := c_get_cp_details_rec.party_role_code;
           x_sr_contact_rec.start_date_active     := c_get_cp_details_rec.start_date_active;
           x_sr_contact_rec.end_date_active       := c_get_cp_details_rec.end_date_active;
        END LOOP;

EXCEPTION
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
             ( p_count => x_msg_count,
               p_data  => x_msg_data);
          RAISE;
END Populate_CP_Audit_Rec;

END;

/
