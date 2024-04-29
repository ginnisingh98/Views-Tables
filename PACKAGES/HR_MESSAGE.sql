--------------------------------------------------------
--  DDL for Package HR_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MESSAGE" AUTHID CURRENT_USER AS
/* $Header: hrmesage.pkh 115.1 99/07/17 16:42:59 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------<     provide_error     >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is required for this package to function correctly.
--   It ensures that this package is correctly initialized  for any error
--   raised with the FND_MESSAGE package, for which the FND_MESSAGE global
--   variables are set.  It retrieves the encoded error message into a record
--   component, before calling several FND_MESSAGE supplied procedures to
--   obtain the application that set the last message on the stack, as well as
--   the name of that message.  This package is transparent to non-APP
--   (for example ORA-).
--
--   Once this record structure is populated with data, other calls can be
--   made to this package to obtain useful information.  Therefore, in order
--   for the other functions to work sucessfully, a call to provide_error
--   must be executed before any other.
--
-- Prerequisites:
--   If information is required about a particular message, that message
--   must exist on the FND_MESSAGE message stack.  This procedure is
--   transparent to non-application raised error messages.
--
-- In Parameters:
--   None
--
-- Post Success:
--   This procedure never fails as such.  If an application error message
--   exists on the FND_MESSAGE stack and the current SQLCODE error code
--   indicates an application error, then the global variables are initialized
--   In all other instances, the SQLCODE and SQLERRM are transmitted through
--   the procedure.  This procedure does not affect the local state of the
--   FND_MESSAGE package.
--
-- Post Failure:
--   This procedure does not fail.  Null values are written to the message
--   information globals if the error is not raised by an application.  The
--   global components corresponding to SQLCODE and SQLERRM are always set.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure provide_error;
--
-- ----------------------------------------------------------------------------
-- |------------------------<     parse_encoded     >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure assumes that the calling program unit already has
--   knowledge of the encoded error message retrieved by a call to
--   FND_MESSAGE.get_encoded.  This is the case when attempting to trap
--   the errors raised by the descriptive (or key) flexfield server
--   validation engines.  This procedure sets up the global variables
--   of the error record in the same fashion as the procedure provide
--   error.
--
--   Once this record structure is populated with data, other calls can be
--   made to this package to obtain useful information.  Therefore, in order
--   for the other functions to work sucessfully, a call to either
--   provide_error or parse_encoded must be made before any other.
--
-- Prerequisites:
--   This procedure can only be called with a valid FND_MESSAGE encoded
--   error string.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--      p_encoded_error              Y   varchar2 String that results from
--                                                a call to
--                                                FND_MESSAGE.get_encoded
--
-- Post Success:
--   If the string passed is in a valid FND_MESSAGE encoded format, the
--   global error records will be set in accordance with provide_error
--   and made available for use with the probing functions of this package.
--
-- Post Failure:
--   This procedure will not raise an error.  If the string passed to the
--   procedure is not in a valid FND_MESSAGE encoded format, the last
--   message application, and last message name will be set to null.
--   That is the action of FND_MESSAGE.parse_encoded, not this procedure.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure parse_encoded(p_encoded_error in varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------<   last_message_number   >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the last message number that was placed on
--   the stack, assuming it was an HR message, conforming to the standard
--      HR_MSGNUM_ERROR_DESCR.
--   I.e. MSGNUM must be the five digit number associated with a message
--   No SQL is executed to retrieve this number, the message name is
--   decomposed to obtain the number.  SQL could be added if this
--   procedure is needed for non-self service applications.
--
-- Prerequisites:
--   This function must be called after a call to provide_error.  If provide
--   error has not been called beforehand, the results of a call to this
--   function are undefined.
--
-- In Parameters:
--   None
--
-- Post Success:
--   The function returns the last message number, equivalent to
--   the FND_NEW_MESSAGES MESSAGE_NUMBER column value, if the message
--   name conforms to the standard described above.  If called with a
--   non-application raised error, this function will return NULL.
--
-- Post Failure:
--   This procedure does not fail.  Undefined values are returned if the
--   function is called before provide_error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
function last_message_number return VARCHAR2;
--
function last_message_name return VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |------------------------<   last_message_app   >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure returns application short name of that application
--   that raised the last message found on the FND_MESSAGE stack.
--
-- Prerequisites:
--   This function must be called after a call to provide_error.  If provide
--   error has not been called beforehand, the results of a call to this
--   function are undefined.
--
-- In Parameters:
--   None
--
-- Post Success:
--   The function returns the contents the application short name that
--   last set a message on the FND_MESSAGE stack.  If a non-application
--   error has occurred, this function will return NULL.
--
-- Post Failure:
--   This procedure does not fail.  Undefined values are returned if the
--   function is called before provide_error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
function last_message_app return VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |------------------------<    get_token_value    >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure returns the value assigned to a token found in the
--   last message.  This procedure checks that the
--   error message data contains the token value specified in the call
--   and if so, returns the assigned value.
--
-- Prerequisites:
--   This function must be called after a call to provide_error.  If provide
--   error has not been called beforehand, the results of a call to this
--   function are undefined.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--      p_token_name                  Y  varchar2 The name of the token whose
--                                                value is required.
--
-- Post Success:
--   The function returns the value assigned to the token if the supplied
--   token is present in the message data string.  This is case sensitive
--   so that a token pushed onto the stack with identifier 'TOKEN', can only
--   be retrieved from this procedure by passing the value 'TOKEN'.  If
--   the token is not in the message string, or the trapped error was not
--   raised by the application, a null value is returned.
--
-- Post Failure:
--   This procedure does not fail.  Undefined values are returned if the
--   function is called before provide_error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
function get_token_value(p_token_name in varchar2) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |------------------------<   get_message_text    >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure returns the text associated with the message.  The tokens
--   are replaced with their proper values, and the message text will contain
--   the same information as if FND_MESSAGE.get were raised.  However, it
--   leaves the local state of FND_MESSAGE unchanged, meaning that this,
--   or other procedures in this package, or any other procedure can still
--   access the FND_MESSAGE stack.
--
-- Prerequisites:
--   This function must be called after a call to provide_error.  If provide
--   error has not been called beforehand, the results of a call to this
--   function are undefined.
--
-- In Parameters:
--   None
--
-- Post Success:
--   The function returns the full error message as defined in the
--   FND_NEW_MESSAGES table with the tokens replaced by their appropriate
--   values.  The message returned will be translated, if the text is
--   availble in the FND_NEW_MESSAGES table with the appropriate language
--   code.
--
-- Post Failure:
--   This procedure does not fail.  Undefined values are returned if the
--   function is called before provide_error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
function get_message_text return varchar2;
--
-- ----------------------------------------------------------------------------
-- |----------------< General Documentation and Examples    >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Rationale:
-- -----------
-- This package can be used to detect when a specific application
-- error message has been raised. Then either trap it silently,
-- or raise a different error message in it's place. Also provide
-- the ability to obtain the value of known tokens.
--
-- These requirements have come from the HR API strategy, where
-- server-side PL/SQL is used to centralise validation and
-- process logic. HR Development provide these APIs for
-- direct customer use. Also they are called from the core
-- product Forms and WEB pages.
--
-- The APIs perform full validation of data values, regardless
-- of which end user interface is being used.
--
-- When an API discovers a validation rule has been violated
-- an application error is raised by calling
-- fnd_message.set_name and then fnd_message.raise_error.
--
-- For many error conditions it is impossible to write one
-- piece of text which will explain the problem using
-- suitable language for all types of end user:
--   a) A technical person directly setting the API
--      procedure parameters. i.e. Direct PL/SQL call.
--
--   b) An experienced HR professional. i.e. Forms end user.
--
--   c) An inexperienced and infrequent user. i.e. WEB pages.
--
-- For example, the HRMS APIs use an object_version_number
-- value as a locking mechanism. Ideally the error
-- text should be different for each type of end user:
--   a) "The p_object_version_number parameter value
--      does not match the current value for this record."
--
--   b) "Record has been updated.  Requery block to see change."
--      i.e. As the FND FORM_RECORD_CHANGED error.
--
--   c) "This data has been changed by another person. The
--      latest changes are shown below."
--
--      In the WEB pages, case c, an automatic re-query is included.
--
--
-- The APIs should raise the error message containing text
-- aimed at technical users. If required, the graphical
-- user interface code can trap the error raised by the
-- API. Examine any message token values. Then raise a
-- different error message containing text suitable for
-- a non-technical end user.
--
-- There may be scenarios where the user interface can
-- resolve the issue through additional code, and no
-- error text need to be displayed to the end user.
--
-- Example Uses:
-- -------------
--
-- a) HR Development code to trap a particular application error
--    message and raise a different error message instead.
--    For example, the API raises an invalid object_version_number
--    error message. The Form should trap this message and
--    display "Record has been updated.  Requery..." instead.
--
--      begin
--        <<procedure call>>
--      exception
--        when app_exception.application_exception then
--          hr_message.provide_error;
--          if hr_message.last_message_app = 'PER' then
--            if hr_message.last_message = 'HR_7155_OBJECT_INVALID' then
--              fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
--              fnd_message.raise_error;
--            end if;
--          end if;
--          -- Do not trap any other errors
--          raise;
--      end;
--
--
-- b) Consultants and customers calling APIs, want to trap
--    ORA and APP errors:
--
--      declare
--        l_message_text varchar2(2000);
--      begin
--        -- API procedure call
--      exception
--        when other then
--          hr_message.provide_error;
--          l_message_text := hr_message.get_message_text;
--          -- Write l_message_text to error table or log file
--      end;
--
-- {End Of Comments}
--
END HR_MESSAGE;

 

/