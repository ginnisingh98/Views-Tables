--------------------------------------------------------
--  DDL for Package Body ASG_PUB_SEQUENCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_PUB_SEQUENCE_PKG" as
/* $Header: asgpseqb.pls 120.2 2006/02/02 15:48:55 rsripada noship $ */


--
--  NAME
--    ASG_PUB_SEQUENCE
--
--  PURPOSE
--
--  HISTORY
--  SEP 21, 2004  yazhang using orace_id to get oracle_username for shcema name
--  MAR 31, 2003  ytian   not to update the creation_date for update_row.
--  JUL 09, 2002  ytian   Modified get_next_client_number.
--  JUN 26, 2002  ytian   modified not to update STATUS.
--  JUn 25  2002  yazhang hardcoded asg_max_client_number with 1,000,000.
--  JUN 03, 2002  ytian   changed _id pk type to varchar2.
--  MAR 22, 2002  ytian   modified insert_row to insert Last_release_version
--                        as 0, so that it gets created/upgraded surely.
--  Mar 21, 2002  ytian   Updated update_row not to update
--                               last_release_version
--  Mar 20, 2002  yazhang return value in getNextClientNumber
--  MAR 11, 2002  ytian   added insert_row, update_row, upload_row
--  Mar 08, 2002  yazhang add get_next_client_number
--  Mar 07, 2002  ytian created

/* get the clientnumber */
Function getCLIENT_NUMBER(X_Clientid IN Varchar2) RETURN number IS

   CURSOR C_CLIENT_NUMBER(v_clientid varchar2)
   IS
   Select client_number
   from ASG_USER
   where upper(user_name) = upper(v_clientid);

   v_client_number number;
BEGIN

   OPEN C_CLIENT_NUMBER(x_clientid);
   FETCH C_CLIENT_NUMBER into v_client_number;
   IF C_CLIENT_NUMBER%NOTFOUND then
   CLOSE C_CLIENT_NUMBER; return null;
   END IF;
   CLOSE C_CLIENT_NUMBER;
   return v_client_number;

END getCLIENT_NUMBER;


Function getNEXT_VALUE RETURN number
   IS

   V_VAL_Z varchar2(100);
   V_DEFINED_Z    boolean;
   BEGIN
    /*
      FND_PROFILE.GET_SPECIFIC('ASG_MAX_CLIENT_NUM',null, null, 279,
                 V_VAL_Z, V_DEFINED_Z);

      if v_val_z is null then
       v_val_z := 1000000;
      END if;
     */
      v_val_z := 1000000;

     return v_val_z;

END getNEXT_VALUE;

Function getSTART_VALUE(X_CLIENT_NUMBER number, X_TABLE_NAME varchar2,
   X_PRIMARY_KEY varchar2, X_START_MOBILE varchar2 ) RETURN number
IS

    v_servername varchar2(240);
    v_id number;
    v_start number;
    dummy_num number;
    v_statement varchar2(1000);
    v_minvalue number;
    v_start_mobile number;
    v_max_users number;

    BEGIN

    v_max_users := getNEXT_VALUE;
    v_start_mobile := to_number(x_start_mobile);


    v_statement := 'select nvl(max(' || x_primary_key ||
               '), '|| x_client_number ||
                  ') from '|| x_table_name ||
                  ' where MOD(' || x_primary_key || ',' || v_max_users ||
                     ') = '|| x_client_number;


    v_id := DBMS_SQL.OPEN_CURSOR;
            DBMS_SQL.PARSE(v_id, v_statement, DBMS_SQL.native);
            DBMS_SQL.DEFINE_COLUMN(v_id, 1, v_start);
            dummy_num := DBMS_SQL.EXECUTE(v_id);
            if DBMS_SQL.FETCH_ROWS(v_id) = 0 then
                    return -1;
            END if;
            DBMS_SQL.COLUMN_VALUE(v_id, 1, v_start);
            DBMS_SQL.CLOSE_CURSOR(v_id);

        if(v_start > v_start_mobile) then
                    v_minValue := v_start;
            else
                    v_minValue := v_start_mobile + x_client_number;
            END if;

        return v_minValue;

    END getSTART_VALUE;


Function  Next_Client_Number (MaxClientNum INTEGER, StartNum INTEGER ) RETURN INTEGER  IS

Max_Num         INTEGER;
Temp_Num        INTEGER;
Curr_Num        INTEGER;
Prev_Num        INTEGER;
Ret_Flag        BOOLEAN := FALSE;
CURSOR  client_num_cur(StartNum INTEGER) IS
        SELECT client_number
        FROM   ASG_USER
        WHERE  client_number > StartNum
        ORDER BY client_number;
CURSOR  start_num_cur(StartNum INTEGER) IS
        SELECT client_number
        FROM ASG_USER
        WHERE client_number =  StartNum;
CURSOR  max_client_num_cur IS
        SELECT  MAX(Client_Number)
        FROM    ASG_USER;
BEGIN

        if (StartNum >= MaxClientNum) then
                return(0);
        end if;
        open start_num_cur(StartNum+1);
        fetch start_num_cur into Temp_Num;
        if (start_num_cur%NOTFOUND AND ((StartNum+1) <= MaxClientNum) ) then
                Ret_Flag := TRUE;
        end if;
        close start_num_cur;

        if (Ret_Flag = TRUE) then
                return (StartNum+1);
        end if;

        open max_client_num_cur;
        fetch max_client_num_cur into Max_Num;
        close max_client_num_cur;
        IF((Max_Num IS NOT NULL) AND (MaxClientNum >= (Max_Num+1))) THEN
          RETURN (Max_Num+1);
        END IF;


        OPEN client_num_cur(StartNum);
        Prev_Num := StartNum;
        Curr_Num := StartNum;

        LOOP
                -- Else loop thru all the rows in the table
                -- To identify an unused number
                FETCH  client_num_cur INTO Temp_Num;
                IF (Temp_Num IS NOT NULL) THEN
                        Prev_Num := Curr_Num;
                        Curr_Num := Temp_Num;
                END IF;
                IF (client_num_cur%NOTFOUND) THEN
                        -- Have looked at all the rows
                        -- Close the cursor
                        CLOSE client_num_cur;
                        IF ((Prev_Num+1) < Curr_Num ) THEN
                                -- We have a number to use
                                return (Prev_Num+1);
                        ELSE
                                if (Curr_Num < MaxClientNum) then
                                        return (Curr_Num+1);
                                else
                                        return (0);
                                end if;
                        END IF;
                END IF;

                -- Else check if there is a hole in the sequence
                IF ((Prev_Num+1) < Curr_Num) THEN
                        CLOSE client_num_cur;
                        return (Prev_Num+1);
                END IF;
        END LOOP;
END Next_Client_Number;


Function Get_Next_Client_Number return INTEGER IS
  l_max_client_num_char VARCHAR2(40);
  l_max_client_num INTEGER;
  client_number INTEGER;
BEGIN
 /* FND_PROFILE.get('ASG_MAX_CLIENT_NUMBER', l_max_client_num_char);*/

  l_max_client_num := null;
  if l_max_client_num  is null
  then
   l_max_client_num := 1999999;
  end if;
  client_number := Next_Client_Number(l_max_client_num,0);
  return client_number;
END Get_Next_Client_Number;



procedure insert_row (
   x_SEQUENCE_ID in VARCHAR2,
  x_SEQUENCE_NAME in VARCHAR2,
  x_PUBLICATION_ID in VARCHAR2,
  x_B_SCHEMA in VARCHAR2,
  x_B_TABLE in VARCHAR2,
  x_B_COLUMN in VARCHAR2,
  x_MOBILE_VALUE in VARCHAR2,
  x_ENABLED    in VARCHAR2,
  x_STATUS     in VARCHAR2,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER )
 is

   l_b_schema varchar2(30);

BEGIN
   begin
     select oracle_username into l_b_schema
       from fnd_oracle_userid
      where oracle_id = X_B_SCHEMA;
   exception
     when others then
    l_b_schema := x_B_SCHEMA;
   end;
   insert into ASG_PUB_SEQUENCE (
    SEQUENCE_ID,
    SEQUENCE_NAME,
    PUBLICATION_ID,
    B_SCHEMA,
    B_TABLE,
    B_COLUMN,
    MOBILE_VALUE,
    ENABLED,
    STATUS,
    CURRENT_RELEASE_VERSION,
    LAST_RELEASE_VERSION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  ) values (
    decode(x_SEQUENCE_ID,FND_API.G_MISS_CHAR, NULL, x_SEQUENCE_ID),
    decode(x_SEQUENCE_NAME,FND_API.G_MISS_CHAR, NULL, x_SEQUENCE_NAME),
    decode(x_PUBLICATION_ID,FND_API.G_MISS_CHAR,NULL, x_PUBLICATION_ID),
    decode(l_B_SCHEMA,FND_API.G_MISS_CHAR, NULL, l_B_SCHEMA),
    decode(x_B_TABLE,FND_API.G_MISS_CHAR, NULL, x_B_TABLE),
    decode(x_B_COLUMN,FND_API.G_MISS_CHAR, NULL,x_B_COLUMN),
    decode(x_MOBILE_VALUE,FND_API.G_MISS_CHAR, NULL, x_MOBILE_VALUE),
    decode(x_ENABLED,FND_API.G_MISS_CHAR, NULL, x_ENABLED),
    'N',
    decode(x_CURRENT_RELEASE_VERSION,FND_API.G_MISS_NUM, NULL,
            x_CURRENT_RELEASE_VERSION),
    0,
    decode(x_CREATION_DATE,FND_API.G_MISS_DATE, NULL, x_CREATION_DATE),
    decode(x_CREATED_BY,FND_API.G_MISS_NUM, NULL, x_CREATED_BY),
    decode(x_LAST_UPDATE_DATE,FND_API.G_MISS_DATE, NULL,
                  x_LAST_UPDATE_DATE),
    decode(x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATED_BY)
  );

END INSERT_ROW;

procedure update_row (
   x_SEQUENCE_ID in VARCHAR2,
  x_SEQUENCE_NAME in VARCHAR2,
  x_PUBLICATION_ID in VARCHAR2,
  x_B_SCHEMA in VARCHAR2,
  x_B_TABLE in VARCHAR2,
  x_B_COLUMN in VARCHAR2,
  x_MOBILE_VALUE in VARCHAR2,
  x_ENABLED    in VARCHAR2,
  x_STATUS     in VARCHAR2,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER )
 is

  l_b_schema varchar2(30);

BEGIN

   begin
     select oracle_username into l_b_schema
       from fnd_oracle_userid
      where oracle_id = X_B_SCHEMA;
   exception
     when others then
    l_b_schema := x_B_SCHEMA;
   end;

   update asg_pub_sequence set
     sequence_id = x_sequence_id,
     sequence_name = x_sequence_name,
     publication_id = x_publication_id,
     b_schema = l_b_schema,
     b_table = x_b_table,
     b_column = x_b_column,
     mobile_value = x_mobile_value,
     enabled = x_enabled,
--     status = x_status,
     current_release_version = x_current_release_version,
--     last_release_version = x_last_release_version,
--     CREATION_DATE = x_CREATION_DATE,
--     created_by = x_created_by,
     last_update_date = x_last_update_date,
     last_updated_by = x_last_updated_by
    where sequence_id = X_SEQUENCE_ID;

  if (sql%notfound ) then
    raise no_data_found;
  end if;
END UPDATE_ROW;

procedure load_row (
  x_SEQUENCE_ID in VARCHAR2,
  x_SEQUENCE_NAME in VARCHAR2,
  x_PUBLICATION_ID in VARCHAR2,
  x_B_SCHEMA in VARCHAR2,
  x_B_TABLE in VARCHAR2,
  x_B_COLUMN in VARCHAR2,
  x_MOBILE_VALUE in VARCHAR2,
  x_ENABLED    in VARCHAR2,
  x_STATUS     in VARCHAR2,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  p_owner in VARCHAR2) IS

  l_user_id  number := 0;

BEGIN

   if (p_owner = 'SEED' ) then
     l_user_id := 1;
   end if;

   asg_pub_sequence_pkg.UPDATE_ROW (
    x_SEQUENCE_ID => x_SEQUENCE_ID,
    x_SEQUENCE_NAME => x_SEQUENCE_NAME,
    x_PUBLICATION_ID => x_PUBLICATION_ID,
    x_B_SCHEMA => x_B_SCHEMA,
    x_B_TABLE => x_B_TABLE,
    x_B_COLUMN => x_B_COLUMN,
    x_MOBILE_VALUE => x_MOBILE_VALUE,
    x_ENABLED => x_ENABLED,
    x_STATUS => x_STATUS,
    x_CURRENT_RELEASE_VERSION => x_CURRENT_RELEASE_VERSION,
    x_LAST_RELEASE_VERSIOn => x_LAST_RELEASE_VERSION,
    x_CREATION_DATE    => x_CREATION_DATE,
    x_CREATED_BY => x_CREATED_BY,
    x_LAST_UPDATE_DATE => sysdate,
    x_LAST_UPDATED_BY => l_USER_ID);

 EXCEPTION
   when no_DATA_FOUND THEN
     asg_pub_sequence_pkg.insert_row (
    x_SEQUENCE_ID => x_SEQUENCE_ID,
    x_SEQUENCE_NAME => x_SEQUENCE_NAME,
    x_PUBLICATION_ID => x_PUBLICATION_ID,
    x_B_SCHEMA => x_B_SCHEMA,
    x_B_TABLE => x_B_TABLE,
    x_B_COLUMN => x_B_COLUMN,
    x_MOBILE_VALUE => x_MOBILE_VALUE,
    x_ENABLED => x_ENABLED,
    x_STATUS => x_STATUS,
    x_CURRENT_RELEASE_VERSION => x_CURRENT_RELEASE_VERSION,
    x_LAST_RELEASE_VERSIOn => x_LAST_RELEASE_VERSION,
    x_CREATION_DATE    => sysdate,
    x_CREATED_BY => l_user_id,
    x_LAST_UPDATE_DATE => sysdate,
    x_LAST_UPDATED_BY => l_USER_ID);

END LOAD_ROW;

END ASG_PUB_SEQUENCE_PKG;


/
