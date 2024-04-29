--------------------------------------------------------
--  DDL for Package HR_ADI_DOCUMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ADI_DOCUMENT_API" AUTHID CURRENT_USER as
/* $Header: hrlobapi.pkh 115.2 2002/11/21 14:22:23 menderby noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_DOCUMENT >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is provided to allow creation of new documents within the
--   FND_LOBS table.
--
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  Commit or rollback
--   p_effective_date               Yes  date     Effective date of the document
--   p_mime_type                    Yes  varchar2 The MIME type of document
--   p_file_name                    Yes  varchar2 The name of the file
--   p_type                         Yes  varchar2 Lookup code relating to file
--                                                type lookup HRMS_ADI_FILE_TYPE
--
-- Post Success:
--   When the document has been sucessfully been inserted the following
--   parameters are set:
--
--   Name                           Type     Description
--   p_file_id                      number   PK of FND_LOBS.
--
-- Post Failure:
--   The API does not create the document and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure CREATE_DOCUMENT
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_mime_type                     in     varchar2
  ,p_file_name                     in     varchar2
  ,p_type                          in     varchar2
  ,p_file_id                          out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_DOCUMENT >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is provided to allow updating of documents within the
--   FND_LOBS table.
--
-- Prerequisites:
--   (i)  The FILE_ID must exist within the FND_LOBS table.
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  Commit or rollback
--   p_effective_date               Yes  date     Effective date of the document
--   p_file_id                      Yes  number   The PK of FND_LOBS
--   p_mime_type                    Yes  varchar2 MIME type of upload file
--   p_file_name                    Yes  varchar2 The name of the file
--
-- Post Success:
--   When the document has been sucessfully been updated the following
--   parameters are set:
--
--   Name                           Type     Description
--
-- Post Failure:
--   The API does not update the file and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure UPDATE_DOCUMENT
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_file_id                       in     number
  ,p_mime_type                     in     varchar2
  ,p_file_name                     in     varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< DELETE_DOCUMENT >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is provided to allow deletion of documents within the
--   FND_LOBS table.
--
-- Prerequisites:
--   (i)  The FILE_ID must exist within the FND_LOBS table.
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  Commit or rollback
--   p_file_id                      Yes  number   The PK of FND_LOBS
--
-- Post Success:
--   The record will cease to exist.
--
-- Post Failure:
--   The record will exist, and an error will be raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure DELETE_DOCUMENT
  (p_validate                      in     boolean  default false
  ,p_file_id                       in     number
  );
--

function search_for_term(p_search_term   in varchar2,
                          p_document_type in varchar2 default null)
                          return varchar2;

function document_to_text(p_file_id in varchar2, p_text_or_html varchar2) return clob;

end HR_ADI_DOCUMENT_API;

 

/
