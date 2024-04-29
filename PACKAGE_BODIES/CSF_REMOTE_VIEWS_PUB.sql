--------------------------------------------------------
--  DDL for Package Body CSF_REMOTE_VIEWS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_REMOTE_VIEWS_PUB" AS
/* $Header: CSFPRVWB.pls 115.7.11510.2 2004/06/24 05:20:52 srengana ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSF_REMOTE_VIEWS_PUB';

procedure Parse_Query
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status    OUT VARCHAR2
, x_msg_count        OUT NUMBER
, x_msg_data         OUT VARCHAR2
, p_sql_query        IN  VARCHAR2
, x_query_correct    OUT VARCHAR2
)
is

l_api_name     CONSTANT  VARCHAR2(30) := 'PARSE_QUERY';
l_api_version  CONSTANT  NUMBER       := 1.0;

t_cursor_name integer;

begin
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call
       ( l_api_version
       , p_api_version
       , l_api_name
       , G_PKG_NAME
       )
THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean
   ( p_init_msg_list
   )
THEN
   FND_MSG_PUB.initialize;
END IF;
--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- All statements wich do not begin with 'select' are to be rejected.
-- This way modifications with statements like update ... or
-- delete ... can be prevented.
if Upper
   ( SubStr
     ( LTrim
       ( p_sql_query
       )
     , 1
     , 6
     )
   ) <> 'SELECT'
then
   x_query_correct := FND_API.G_FALSE;
end if;
t_cursor_name := dbms_sql.open_cursor;
dbms_sql.parse
( t_cursor_name
, p_sql_query
, dbms_sql.native
);
dbms_sql.close_cursor
( t_cursor_name
);
x_query_correct := FND_API.G_TRUE;
-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get
( p_count => x_msg_count
, p_data  => x_msg_data
);
EXCEPTION
WHEN FND_API.G_EXC_ERROR
THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get
   ( p_count => x_msg_count
   , p_data  => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   FND_MSG_PUB.Count_And_Get
   ( p_count => x_msg_count
   , p_data  => x_msg_data
   );
WHEN OTHERS
THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   IF FND_MSG_PUB.Check_Msg_Level
      ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      )
   THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      ,	l_api_name
      );
   END IF;
   FND_MSG_PUB.Count_And_Get
   ( p_count => x_msg_count
   , p_data  => x_msg_data
   );
   if dbms_sql.is_open
      (t_cursor_name
      )
   then
      dbms_sql.close_cursor
      (t_cursor_name
      );
   end if;
   x_query_correct := FND_API.G_FALSE;
end Parse_Query;

procedure Execute_Remote_View
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status    OUT VARCHAR2
, x_msg_count        OUT NUMBER
, x_msg_data         OUT VARCHAR2
, p_sqlstring        IN  VARCHAR2
, p_parameter_string IN  VARCHAR2
, p_sqltitle         IN  VARCHAR2
, p_role             IN  VARCHAR2
, p_requestdate      IN  DATE
, p_query_id         IN  NUMBER
, p_queryrequest_id  IN  NUMBER   := FND_API.G_MISS_NUM
, x_queryrequest_id  OUT NUMBER
, x_notification_id  OUT NUMBER
)
is

l_api_name     CONSTANT  VARCHAR2(30) := 'EXECUTE_REMOTE_VIEW';
l_api_version  CONSTANT  NUMBER       := 1.0;

c_query       number;
t_dummy       number;
col_count     integer;
rec_tab       dbms_sql.desc_tab;
col_num       number;
t_header      varchar2(2000);
t_header_line varchar2(2000);
t_result      varchar2(32767);
t_msg_text    varchar2(32767);
t_rec         dbms_sql.desc_rec;
t_col_var     varchar2(2000);
t_col_num     number;
t_col_dat     date;
t_col_row     rowid;
t_sqlstring   varchar2(2000);
t_input       varchar2(2000);
t_NewLine     varchar2(1)         := fnd_global.local_chr(10);
t_length      number;
t_first_line  varchar2(2000);
t_err_string  varchar2(2000);
t_not_id      number;
t_request_id  number;

--MAIL should get fnd username i.s.o resource_number
cursor c_user
( b_res_num varchar2
)
is
 select fnd.USER_NAME
 from   FND_USER fnd
 ,      JTF_RS_RESOURCE_EXTNS jtf
 where  jtf.USER_ID = fnd.USER_ID
 and    jtf.RESOURCE_NUMBER = b_res_num;

r_user                  c_user%ROWTYPE;
t_user            	varchar2(100);




-- Private function!
function replace_vars
( i_sqlstring    in     varchar2
, i_queryinput   in     varchar2
, o_replacements    out varchar2
)
return varchar2
is

t_sql             varchar2(2000) := '';
t_par_offset      number(4)      := 1;
t_par_offset2     number(4)      := 1;
t_sql_offset      number(4)      := 1;
t_sql_offset2     number(4)      := 1;
t_str_copy_offset number(4)      := 1;
t_par_len         number(4)      := Length
                                    ( p_parameter_string
                                    );
t_sep             varchar2(1)    := fnd_global.local_chr(2);
t_par             varchar2(2000);
t_quote           varchar2(1)    := '''';
t_input           varchar2(2000) := '';

-- Private function!
function SQL_quotes
( i_single_quotes_string varchar2
) return varchar2
is
begin
-- Every string has to start and end with a quote => 2 quotes.
-- A quote in a string has to have an extra quote to distingish
-- it from the end-of-string-quote.
-- Single Quote => 4 consecutive quotes
-- Double Quote => 6 consecutive quotes
return replace
       ( i_single_quotes_string
       , ''''
       , ''''''
       );
end SQL_quotes;

--start replace_vars
begin
t_par_offset2 := InStr
                 ( i_queryinput
                 , t_sep
                 , t_par_offset
                 );
while t_par_offset2 <> 0 loop
   t_par := SubStr
            ( i_queryinput
            , t_par_offset
            , t_par_offset2 - t_par_offset
            );
   t_par_offset := t_par_offset2 + 1;
   t_par_offset2 := InStr
                    ( i_queryinput
                    , t_sep
                    , t_par_offset
                    );
   t_sql_offset := InStr
                   ( i_sqlstring
                   , '['
                   , t_sql_offset
                   );
   t_sql_offset2 := InStr
                    ( i_sqlstring
                    , ']'
                    , t_sql_offset
                    );
   -- Forward the parameters to the message.
   if (   t_sql_offset  > 0
      and t_sql_offset2 > 0
      and t_par is not null
      )
   then
      t_input := t_input
              || SubStr
                 ( i_sqlstring
                 , t_sql_offset
                 , t_sql_offset2 - t_sql_offset + 1
                 )
              || ' = '
              || t_par
              || t_NewLine;
      -- check for required quotes around parameter.
      if    SubStr
            ( i_sqlstring
            , t_sql_offset + 1
            , 1
            ) = '#'
      then
         -- Dates are taken literally. It is up to the maker of the query
         -- to provide a query that will accept a date the way engineers
         -- will input it.
         null;
      elsif SubStr
            ( i_sqlstring
            , t_sql_offset + 1
            , 1
            ) = '$'
      then
         t_par := t_quote
               || SQL_quotes
                  ( Replace
                    ( t_par
                    , '*'
                    , '%'
                    )
                  )
               || t_quote;
      else
         -- numbers are to be taken literally.
         null;
      end if;
      t_sql := t_sql
            || SubStr
               ( i_sqlstring
               , t_str_copy_offset
               , t_sql_offset - t_str_copy_offset
               )
            || t_par;
      t_str_copy_offset := t_sql_offset2 + 1;
      t_sql_offset := t_sql_offset2 + 1;
   else
      o_replacements := 'Parameter-mapping error detected!';
      return 'PARAMETER ERROR';
   end if;
end loop;
t_sql := t_sql
         || SubStr
            ( p_sqlstring
            , t_str_copy_offset
            , Length
              ( p_sqlstring
              )
            );
o_replacements := t_input;
return t_sql;
end replace_vars;

-- start Execute_Remote_View
begin
-- Standard Start of API savepoint
SAVEPOINT EXECUTE_REMOTE_VIEW_PUB;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call
       ( l_api_version
       , p_api_version
       , l_api_name
       , G_PKG_NAME
       )
THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean
   ( p_init_msg_list
   )
THEN
   FND_MSG_PUB.initialize;
END IF;
--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Convert resource_number to apps user name
open c_user
     ( b_res_num => p_role
     );
fetch c_user
 into r_user;
if c_user%found
then
  t_user := r_user.user_name;
else
  t_user := 'Unknown user';
end if;
close c_user;

-- Runtime initializations
fnd_message.set_name
( 'CSF'
, 'CSF_RMT_VWS_EXECUTE_REQUEST'
);
fnd_message.set_token
( 'REMOTE_VIEW'
, p_sqltitle
);
fnd_message.set_token
( 'REQUEST_DATE'
, fnd_date.date_to_displaydt
  ( sysdate
  )
);
fnd_message.set_token
( 'ENGINEER'
, t_user
);
t_first_line := fnd_message.get;
-- Check if parameters were supplied.
t_sqlstring := replace_vars
               ( p_sqlstring
               , p_parameter_string
               , t_input
               );
if t_sqlstring = 'PARAMETER ERROR'
then
   fnd_message.Set_Name
   ( 'CSF'
   , 'CSF_RMT_VWS_PAR_MAPPING'
   );
   fnd_msg_pub.add;
   raise FND_API.G_EXC_UNEXPECTED_ERROR;
else
   c_query := dbms_sql.open_cursor;
   -- Start a new block to be able to trap exceptions
   -- when parsing it fails.
   begin
   dbms_sql.parse
   ( c_query
   , t_sqlstring
   , dbms_sql.native
   );
   t_dummy := dbms_sql.execute
   ( c_query
   );
   dbms_sql.describe_columns
   ( c_query
   , col_count
   , rec_tab
   );
   t_header      := '';
   t_header_line := '';
   for col_num in 1 .. col_count loop
      t_rec := rec_tab
               ( col_num
               );
      if    t_rec.col_type in ( 1
                              , 96
                              )  --char
      then
         t_header := t_header
                  || RPad
                     ( t_rec.col_name
                     , t_rec.col_max_len
                     , ' '
                     )
                  || ' ';
         t_header_line := t_header_line
                       || RPad
                          ( '-'
                          , t_rec.col_max_len
                          , '-'
                          )
                       || ' ';
         dbms_sql.define_column
         ( c_query
         , col_num
         , t_col_var
         , t_rec.col_max_len
         );
      elsif t_rec.col_type = 2   --number
      then
         if t_rec.col_precision > 0
         then
            t_length := t_rec.col_precision;
         else
            t_length := t_rec.col_max_len;
         end if;
         t_header := t_header
                  || LPad
                     ( t_rec.col_name
                     , t_length
                     , ' '
                     )
                  || ' ';
         t_header_line := t_header_line
                       || RPad
                          ( '-'
                          , t_length
                          , '-'
                          )
                       || ' ';
         dbms_sql.define_column
         ( c_query
         , col_num
         , t_col_num
         );
      elsif t_rec.col_type = 11   --ROWID
      then
         t_header := t_header
                  || LPad
                     ( t_rec.col_name
                     , 18
                     , ' '
                     )
                  || ' ';
         t_header_line := t_header_line
                       || RPad
                          ( '-'
                          , 18
                          , '-'
                          )
                       || ' ';
         dbms_sql.define_column_rowid
         ( c_query
         , col_num
         , t_col_row
         );
      elsif t_rec.col_type = 12   --date
      then
         t_header := t_header
                  || LPad
                     ( t_rec.col_name
                     , 9
                     , ' '
                     )
                  || ' ';
         t_header_line := t_header_line
                       || RPad
                          ( '-'
                          , 9
                          , '-'
                          )
                       || ' ';
         dbms_sql.define_column
         ( c_query
         , col_num
         , t_col_dat
         );
      else
         t_header := t_header
                  || '?'
                  || ' ';
         t_header_line := t_header_line
                       || '-'
                       || ' ';
      end if;
   end loop;
   t_result := '';
   loop
      if dbms_sql.fetch_rows
         ( c_query
         ) > 0
      then
         -- get column values of the row
         for col_num in 1 .. col_count loop
            t_rec := rec_tab
                     ( col_num
                     );
            if    t_rec.col_type in ( 1
                                    , 96
                                    )   --char
            then
               dbms_sql.column_value
               ( c_query
               , col_num
               , t_col_var
               );
               t_result := t_result
                        || RPad
                           ( t_col_var
                           , t_rec.col_max_len
                           , ' '
                           )
                        || ' ';
            elsif t_rec.col_type = 2   --number
            then
               dbms_sql.column_value
               ( c_query
               , col_num
               , t_col_num
               );
               if t_rec.col_precision > 0
               then
                  t_length := t_rec.col_precision;
               else
                  --  numeric expressions don't have a precision.
                  t_length := t_rec.col_max_len;
               end if;
               t_result := t_result
                        || LPad
                           ( To_Char
                             ( t_col_num
                             )
                           , t_length
                           , ' '
                           )
                        || ' ';
            elsif t_rec.col_type = 11   --ROWID
            then
               dbms_sql.column_value_rowid
               ( c_query
               , col_num
               , t_col_row
               );
               t_result := t_result
                        || t_col_row
                        || ' ';
            elsif t_rec.col_type = 12   --date
            then
               dbms_sql.column_value
               ( c_query
               , col_num
               , t_col_dat
               );
               t_result := t_result
                        || LPad
                           ( To_Char
                             ( t_col_dat
                             )
                           , 9
                           , ' '
                           )
                        || ' ';
            else
               t_result := t_result
                        || '?'
                        || ' ';
            end if;
         end loop;
         t_result := t_result
                  || t_NewLine ;
      else
         exit;
      end if;
   end loop;

   -- Combine various results to from the msg_text.
   t_msg_text := t_first_line
              || t_NewLine
              || p_sqlstring
              || t_NewLine
              || t_input
              || t_NewLine
              || t_header
              || t_NewLine
              || t_header_line
              || t_NewLine
              || t_result;
   -- Ensure the data is not too long.
   if Length
      ( t_msg_text
      ) > 2000
   then
      -- Shorten the message, so at least something will show up.
      fnd_message.set_name
      ( 'CSF'
      , 'CSF_RMT_VWS_RESULT_TOO_LONG'
      );
      t_err_string := fnd_message.get;
      t_msg_text := SubStr
                    ( t_msg_text
                    , 1
                    , 1950
                    )
                 || t_NewLine
                 || '...'
                 || t_NewLine
                 || t_err_string
                 || t_NewLine;
   end if;
   exception
   when others
   then
      dbms_sql.close_cursor
      ( c_query
      );
      fnd_message.set_name
      ( 'CSF'
      , 'CSF_RMT_VWS_PARSE_ERROR'
      );
      fnd_msg_pub.add;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end;
   dbms_sql.close_cursor
   ( c_query
   );
end if;
-- Executing of the query is finished here.
--
-- support for the subject has been dropped, as notifications will not
-- allow it. Place the subject as the first line in the body-text.
-- Place the results in a notification and table csf_l_queryrequests.

t_not_id := wf_notification.send
            ( role     => t_user
            , msg_type => 'CS_MSGS'
            , msg_name => 'FYI_MESSAGE'
            );
wf_notification.SetAttrText
( t_not_id
, 'SENDER'
, 'Remote Query Daemon'
);
wf_notification.SetAttrText
( t_not_id
, 'MESSAGE_TEXT'
, t_msg_text
);
-- Handle the PK.
if p_queryrequest_id is null
then
   -- Generate one.
   select csf_l_queryrequests_s.nextval
   into   t_request_id
   from   dual;
else
   -- Reuse the one provided.
   t_request_id := p_queryrequest_id;
end if;
insert into csf_l_queryrequests
( QUERYREQUEST_ID
, EMPLID
, REQUESTDATE
, QUERY_ID
, QUERYINPUT
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, CREATION_DATE
, CREATED_BY
, LAST_UPDATE_LOGIN
)
values( t_request_id
, p_role
, p_requestdate
, p_query_id
, p_parameter_string
, sysdate
, fnd_global.user_id
, sysdate
, fnd_global.user_id
, 0
);
x_queryrequest_id := t_request_id;

-- Standard check of p_commit.
IF FND_API.To_Boolean
   ( p_commit
   )
THEN
   COMMIT WORK;
END IF;
-- Ensure out parameters are correctly set.
x_notification_id := t_not_id;
FND_MSG_PUB.Count_And_Get
( p_count => x_msg_count
, p_data  => x_msg_data
);
EXCEPTION
WHEN FND_API.G_EXC_ERROR
THEN
   ROLLBACK TO EXECUTE_REMOTE_VIEW_PUB;
   x_return_status := FND_API.G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get
   ( p_count => x_msg_count
   , p_data  => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
   ROLLBACK TO EXECUTE_REMOTE_VIEW_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   FND_MSG_PUB.Count_And_Get
   ( p_count => x_msg_count
   , p_data  => x_msg_data
   );
WHEN OTHERS
THEN
   ROLLBACK TO EXECUTE_REMOTE_VIEW_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   IF FND_MSG_PUB.Check_Msg_Level
      ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      )
   THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      ,	l_api_name
      );
   END IF;
   FND_MSG_PUB.Count_And_Get
   ( p_count => x_msg_count
   , p_data  => x_msg_data
   );
end execute_remote_view;


-- package body CSF_REMOTE_VIEWS_PUB
begin
   null;
end CSF_REMOTE_VIEWS_PUB;

/
