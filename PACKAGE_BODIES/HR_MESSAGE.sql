--------------------------------------------------------
--  DDL for Package Body HR_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MESSAGE" AS
/* $Header: hrmesage.pkb 115.4 99/07/17 16:42:53 porting ship $ */

--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
TYPE g_error_info_type IS RECORD
  (
   sqlcode	NUMBER := 0,
   sqlerrm	VARCHAR2(2000) := '',
   encoded_error_text   VARCHAR2(2000) := '',
   last_message_name	VARCHAR2(2000) := '',
   last_message_app	VARCHAR2(2000) := '',
   last_message_data    VARCHAR2(2000) := '');

--
-- ----------------------------------------------------------------------------
-- |                         Global Definitions                               |
-- ----------------------------------------------------------------------------
--

g_error_rec g_error_info_type;

--
-- ----------------------------------------------------------------------------
-- |                         Global Package Name                              |
-- ----------------------------------------------------------------------------
--

g_package varchar2(33) := '  hr_message_pkg.';

function get_separator_string(p_encoded_error in varchar2) return varchar2 is

-- This function works out what AOL are using as the separator between the
-- data in the encoded data string.  As of August 1998, the encoded error
-- message had the form:
--
-- MSG_APP||(sep)||MSG_NAME||(sep)||MSG_DATA
--
-- The length is determined by finding the start of the MSG_NAME, and
-- subtracting the length of the message application short name (PER, PAY
-- etc.)
--
-- The separator is then determined by substr starting at the position
-- one character past the length of the message application, and continuing
-- for the length just determined.  This function protects us a little bit
-- from changes in the AOL encoding string when we are trying to determine
-- the token values.
--

l_sep_length NUMBER(4);
l_sep_string VARCHAR2(2000);

begin

l_sep_length:=to_number(INSTR(p_encoded_error,g_error_rec.last_message_name)
                          -  LENGTH(g_error_rec.last_message_app) - 1);

l_sep_string:=substr(p_encoded_error,length(g_error_rec.last_message_app)+1,
                                   l_sep_length);

return l_sep_string;

end get_separator_string;

procedure provide_error is

-- This is the main procedure, which makes calls to the FND_MESSAGE package
-- to populate the global record structure with the name of the last message
-- application, and the last message name.  The other data supplied in
-- the encoded error message string is token information, and is not used
-- until a call to get_token_value is made.

l_encoded_error	VARCHAR2(2000);
l_hr_error_app  VARCHAR2(2000);
l_hr_error_name VARCHAR2(2000);
l_sep_string VARCHAR2(2000) :='';

begin

-- Set up global variables with error information

g_error_rec.sqlcode := sqlcode;
g_error_rec.sqlerrm := sqlerrm;

if ((g_error_rec.sqlcode = -20001) or (g_error_rec.sqlcode = -20002)) then

-- An error has been raised by APPS code - populate other global variables

    l_encoded_error := fnd_message.get_encoded;
    g_error_rec.encoded_error_text := l_encoded_error;

    if (l_encoded_error is not null) then

-- FND MESSAGE still knows which message we are talking about
-- Reset the message, so that the FND_MESSAGE state is not altered by
-- this procedure

     fnd_message.set_encoded(l_encoded_error);

-- Now decode the encoded error message into required components

     fnd_message.parse_encoded(encoded_message => l_encoded_error,
                           app_short_name => g_error_rec.last_message_app,
                           message_name => g_error_rec.last_message_name);

       g_error_rec.last_message_data := '';

   else
--
--  We can't find anything out from FND_MESSAGE.  Perhaps the
--  message text has been retrieved, or some other call has
--  reset the global state.  Treat as non-APP error.
--
    g_error_rec.last_message_name := '';
    g_error_rec.last_message_app := '';
    g_error_rec.last_message_data := '';
    g_error_rec.encoded_error_text := '';
--
   end if; -- l_encoded_error is null
else

-- This was not an error raised by an application procedure -
-- set global definitions to NULL

    g_error_rec.last_message_name := '';
    g_error_rec.last_message_app := '';
    g_error_rec.last_message_data := '';
    g_error_rec.encoded_error_text := '';

end if;  -- Check for error raised by APPS

end provide_error;

procedure parse_encoded(p_encoded_error in varchar2) is

-- This procedure assumes that the calling procedure already
-- has knowledge of the encoded error message (e.g.
-- as in the case of the flexfield server validation
-- routines.).  The string passed in must be in the same
-- format as the encoded string in FND_MESSAGE. I.e. it should
-- have been retrieved with a call to FND_MESSAGE.get_encoded.

begin

-- Use the FND routine to parse the encoded error message into
-- the global variables to make them available to the APIS,
-- forms, other packages etc. in a way consistent with provide_error
-- Do not reset the error message on the FND_MESSAGE stack, since
-- this would alter the state of that package.

   fnd_message.parse_encoded(encoded_message => p_encoded_error,
                           app_short_name => g_error_rec.last_message_app,
                           message_name => g_error_rec.last_message_name);

    g_error_rec.encoded_error_text := p_encoded_error;
    g_error_rec.last_message_data := '';


end;
--
function last_message_number return varchar2 is

-- A call to this function will return the message error code in
-- the following format:
--
   l_error_code_text VARCHAR2(30) := 'APP-MSGNUM';
   l_message_num VARCHAR2(10);
--
-- If you wish to change the format, change the default assignment above,
-- noting that the (sub) string MSGNUM will be replaced with the
-- message number.
--
begin
--
-- Check to see if we have a valid message on the stack
--
   if (g_error_rec.last_message_name is not null) then
--
-- Have a valid message.  Lets form the number by assuming a form
-- for the message name of the following:
--   HR_(MSGNUM)_ERROR_MESSAGE_DESCR
--
     l_message_num := substr(g_error_rec.last_message_name,
                      (instr(g_error_rec.last_message_name,'_')+1),
                      (instr(g_error_rec.last_message_name,'_',1,2) -
                       instr(g_error_rec.last_message_name,'_')-1));
--
     if (translate(l_message_num,'A0123456789','A') is null) then
--
-- substr above worked correctly - we have a message number, can output
-- a valid message code.
--
            l_error_code_text := replace(l_error_code_text,'MSGNUM',
                                                        l_message_num);
--
     else
--
-- substr failed.  Should return NULL
--
           l_error_code_text := '';
--
     end if;
--
   else
--
--
-- We don't have a valid message on the stack, therefore I should return
-- null for this.
--
     l_error_code_text := '';
--
   end if;
--
   return l_error_code_text;
--
end last_message_number;
--
function last_message_name return varchar2 is

-- A call to this function simply returns whatever is contained
-- in the current global variable record structure for the last
-- message name raised.

begin

return g_error_rec.last_message_name;

end;

function last_message_app return varchar2 is

-- A call to this function simply returns whatever is contained
-- in the current global variable record structure for the last
-- app that raised a message followed by a call to provide_error.

begin

return g_error_rec.last_message_app;

end;

function get_token_value(p_token_name in varchar2
                        ) return varchar2 is

-- This function uses the MSG_DATA component of the encoded error string
-- to determine the value of a given token.
-- The message data has the following structure:
--
-- MSG_DATA = TKN_TRANSLATE||(sep)||TKN_NAME||(sep)||TKN_VALUE||(sep)
--
-- and so on for each token set with this message.  (sep) is the
-- encoding separator used beforehand.

l_sep_string   VARCHAR2(2000);
l_msg_data_start NUMBER(4);
l_data_start	NUMBER(4);
l_data_end	NUMBER(4);
l_token_value	VARCHAR2(2000);


begin

-- To be able to return the token values, we need to assume something about
-- the encoded nature of the message - this is a big assumption, and we
-- shouldn't really do it.  It would be better if the get_encoded returned
-- this along with the other data shown above - but it does not.  This is
-- therefore, unsupported (by AOL) code

-- Use the function described above to work out what the format of the
-- message data separator.

     l_sep_string := get_separator_string(p_encoded_error =>
                                   g_error_rec.encoded_error_text);

-- The compete encoded message data has structure:
--
-- MSG_APP||(sep)||MSG_NAME||(sep)||MSG_DATA
--
-- so the message data starts at the character past the second
-- instance of the encoded string separator character.

     l_msg_data_start := INSTR(g_error_rec.encoded_error_text,
                                                l_sep_string,1,2)+1;

     g_error_rec.last_message_data := substr(g_error_rec.encoded_error_text,
                                                    l_msg_data_start);
--
-- First check to see whether there is information on tokens available,
-- and that information exists for the token requested.  If not, return
-- a NULL value.
--
-- Note:  We will cause an error if the value of a token is
-- also a valid token name.  We should introduce a check on
-- the number of separator strings to ensure that we have a
-- valid token value.
--
if ((g_error_rec.last_message_data is null) or
    (INSTR(g_error_rec.last_message_data,p_token_name)=0)) then

  return null;

else

-- The starting position (in the string) of the value for the given token
-- can be found using the standard character functions.  From the structure
-- seen above for MSG_DATA, it can be found by finding the position of the
-- token name, then adding the length of the token name, and the length of
-- the separator string.

  l_data_start := INSTR(g_error_rec.last_message_data,p_token_name)
                      +length(p_token_name)
                      +length(l_sep_string);

-- The end of the token value corresponds to the next instance of the
-- separator string starting from the start of the token value.

  l_data_end := INSTR(substr(g_error_rec.last_message_data,l_data_start)
                     ,l_sep_string);

  if(l_data_end>0) then

-- If the data end variable contains a value larger than zero, it means
-- that another separator string was found.  Thus another token record
-- exists, and we should make sure that we only return the part of the
-- string between data_start and data_end, which will be the token value

     l_token_value := substr(g_error_rec.last_message_data,l_data_start,
                      (l_data_end-1));

  else

-- This token value was the last information in the MSG_DATA record.
-- The valid value is the whole string starting at the data_start

     l_token_value := substr(g_error_rec.last_message_data,l_data_start);

  end if;

  return l_token_value;
end if;

end;

function get_message_text return varchar2 is

-- Call this function to retrieve the message text corresponding
-- to the message information held in the error information structure -
-- i.e. the last message after which provide_error was called.  If that
-- structure contains no information, the error is not likely to have been
-- raised by an application, hence just sqlerrm is returned in this case.

l_message_text varchar2(2000);

begin

if (g_error_rec.encoded_error_text is null) then

-- This message is not known about inside FND_MESSAGE, either the FND_MESSAGE
-- globals have been reset - in which case, no message text can be retrieved,
-- or this was not an APP error.  In either case, return the SQL error message
-- as this is the only place we can obtain the error message

   return sqlerrm;

else

-- The message text has not been asked for by any application yet - we can get
-- the message text straight from FND_MESSAGE, and reset the FND_MESSAGE
-- package state by reinitiating the message, so that this call does not disturb
-- the global environment

  l_message_text := FND_MESSAGE.get;

  FND_MESSAGE.set_encoded(ENCODED_MESSAGE => g_error_rec.encoded_error_text);

  return l_message_text;

end if;

end;

END HR_MESSAGE;

/
