--------------------------------------------------------
--  DDL for Package HR_ERRORS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ERRORS_API" AUTHID CURRENT_USER as
/* $Header: hrerrapi.pkh 115.6 2002/12/05 11:07:36 hjonnala ship $ */
--
--
TYPE ErrorRecType is RECORD
     (ErrorField    varchar2 (30)
     ,ErrorCode     varchar2 (30)
     ,ErrorMsg      varchar2 (32000)
     ,WarningFlag   boolean
     ,RowNumber     number
     ,EmailId       varchar2 (500)
     ,EmailMsg      varchar2(32000)
     );
--
TYPE ErrorRecTable is TABLE of ErrorRecType INDEX BY BINARY_INTEGER;
--
TYPE ErrorTextTable is TABLE of varchar2 (32000) INDEX BY BINARY_INTEGER;
--
--
-- Define global variables
--
-- error flag
g_error  boolean := false;
--
-- pl/sql table containing the errors
g_errorTable ErrorRecTable;
--

g_count     number := 0;
--
-- bug 1690449
TYPE ErrorRecLocTable is TABLE of NUMBER INDEX BY BINARY_INTEGER;
--

--
-- ----------------------------------------------------------------------------
-- |--< errorExists >---------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function errorExists return boolean;
--
-- ----------------------------------------------------------------------------
-- |--< warningExists >-------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function warningExists return boolean;
--
-- ----------------------------------------------------------------------------
-- |--< fieldLevelErrorsExist >-----------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
function fieldLevelErrorsExist return boolean;
--
-- ----------------------------------------------------------------------------
-- |--< addErrorToTable >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure addErrorToTable(p_errorField    varchar2  default null
                         ,p_errorCode     varchar2  default null
                         ,p_errorMsg      varchar2
                         ,p_warningFlag   boolean   default false
                         ,p_rowNumber     number    default null
                         ,p_email_id      varchar2  default null
                         ,p_email_msg     varchar2  default null
                         );
--
-- ----------------------------------------------------------------------------
-- |--< noOfErrorRecords >----------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function noOfErrorRecords return number;
--
-- ----------------------------------------------------------------------------
-- |--< noOfWarnings >--------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function noOfWarnings return number;
--
-- ----------------------------------------------------------------------------
-- |--< getPageLevelErrors >--------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function getPageLevelErrors return ErrorRecTable;
--
-- ----------------------------------------------------------------------------
-- |--< getRowLevelErrors >---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function getRowLevelErrors ( p_row_number   varchar2
                            ,p_error_loc     OUT NOCOPY ErrorRecLocTable
                           ) return ErrorTextTable;
--
-- ----------------------------------------------------------------------------
-- |--< getFieldLevelErrors >-------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function getFieldLevelErrors(p_field_name    varchar2
                            ,p_row_number    varchar2    default null
                            ,p_error_loc     OUT NOCOPY ErrorRecLocTable
                            ) return ErrorTextTable;
--
-- ----------------------------------------------------------------------------
-- |--< encryptErrorTable >---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function encryptErrorTable return varchar2;
--
-- ----------------------------------------------------------------------------
-- |--< decryptErrorTable >---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure decryptErrorTable(p_encrypt   varchar2);
--
-- bug 1690449
-- ----------------------------------------------------------------------------
-- |--< deleteErrorRec >---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure deleteErrorRec(p_error_loc   ErrorRecLocTable);
--
end hr_errors_api;

 

/
