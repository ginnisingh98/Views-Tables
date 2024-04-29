--------------------------------------------------------
--  DDL for Package PQH_DOCUMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DOCUMENTS_API" AUTHID CURRENT_USER as
/* $Header: pqdocapi.pkh 120.1 2005/09/15 14:14:40 rthiagar noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------<CREATE_PRINT_DOCUMENT>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_print_document
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_short_name                     in     varchar2
  ,p_document_name                  in 	   varchar2
  ,p_file_id                        in     number
  ,p_formula_id                     in     number
  ,p_enable_flag                    in     varchar2
  ,p_document_category              in     varchar2
  ,p_document_id                    out NOCOPY     number
  ,p_object_version_number          out NOCOPY     number
  ,p_effective_start_date           out NOCOPY     date
  ,p_effective_end_date     	    out NOCOPY	   date
  /* Added for XDO changes */
  ,p_lob_code                       in     varchar2
  ,p_language                       in     varchar2
  ,p_territory                      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------<CREATE_DOCUMENT>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_document
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_short_name                     in     varchar2
  ,p_document_name                  in 	   varchar2
  ,p_file_id                        in     number
  ,p_formula_id                     in     number
  ,p_enable_flag                    in     varchar2
  ,p_document_category              in     varchar2
  ,p_document_id                    out NOCOPY     number
  ,p_object_version_number          out NOCOPY     number
  ,p_effective_start_date           out NOCOPY     date
  ,p_effective_end_date     	    out NOCOPY	   date
  /* Added for XDO changes */
  ,p_lob_code                       in     varchar2
  ,p_language                       in     varchar2
  ,p_territory                      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------<UPDATE_PRINT_DOCUMENT>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_print_document
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_short_name                     in     varchar2 default hr_api.g_varchar2
  ,p_document_name                  in 	   varchar2 default hr_api.g_varchar2
  ,p_file_id                        in     number   default hr_api.g_number
  ,p_formula_id                     in     number   default hr_api.g_number
  ,p_enable_flag                    in     varchar2 default hr_api.g_varchar2
  ,p_document_category              in     varchar2 default hr_api.g_varchar2
  ,p_document_id                    in     number
  ,p_object_version_number          in OUT NOCOPY     number
  ,p_effective_start_date           OUT    NOCOPY     date
  ,p_effective_end_date     	    OUT    NOCOPY     date
  /* Added for XDO changes */
  ,p_lob_code                       in     varchar2
  ,p_language                       in     varchar2
  ,p_territory                      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------<UPDATE_DOCUMENT>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_document
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_short_name                     in     varchar2 default hr_api.g_varchar2
  ,p_document_name                  in 	   varchar2 default hr_api.g_varchar2
  ,p_file_id                        in     number   default hr_api.g_number
  ,p_formula_id                     in     number   default hr_api.g_number
  ,p_enable_flag                    in     varchar2 default hr_api.g_varchar2
  ,p_document_category              in     varchar2 default hr_api.g_varchar2
  ,p_document_id                    in     number
  ,p_object_version_number          in OUT NOCOPY     number
  ,p_effective_start_date           OUT    NOCOPY     date
  ,p_effective_end_date     	    OUT    NOCOPY     date
  /* Added for XDO changes */
  ,p_lob_code                       in     varchar2
  ,p_language                       in     varchar2
  ,p_territory                      in     varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------<DELETE_PRINT_DOCUMENT>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_print_document
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_document_id                    in     number
  ,p_object_version_number          in OUT NOCOPY     number
  ,p_effective_start_date           OUT    NOCOPY     date
  ,p_effective_end_date     	    OUT    NOCOPY     date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------<DELETE_DOCUMENT>--------------------------|
-- ----------------------------------------------------------------------------
procedure delete_document
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_document_id                    in     number
  ,p_object_version_number          in OUT NOCOPY     number
  ,p_effective_start_date           OUT    NOCOPY     date
  ,p_effective_end_date     	    OUT    NOCOPY     date
  );
--
end pqh_documents_api;

 

/
