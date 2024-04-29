--------------------------------------------------------
--  DDL for Package IRC_RECRUITING_SITES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_RECRUITING_SITES_SWI" AUTHID CURRENT_USER As
/* $Header: irrseswi.pkh 120.0.12010000.2 2010/01/18 14:28:32 mkjayara ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_recruiting_site >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_recruiting_sites_api.create_recruiting_site
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_recruiting_site
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_site_name                    in     varchar2
  ,p_date_from                      in date default null
  ,p_date_to                        in date default null
  ,p_posting_username               in varchar2 default null
  ,p_posting_password               in varchar2 default null
  ,p_internal                     in     varchar2  default 'N'
  ,p_external                     in     varchar2  default 'N'
  ,p_third_party                  in     varchar2  default 'Y'
  ,p_redirection_url              in     varchar2  default null
  ,p_posting_url                  in     varchar2  default null
  ,p_posting_cost                 in     number    default null
  ,p_posting_cost_period          in     varchar2  default null
  ,p_posting_cost_currency        in     varchar2  default null
  ,p_stylesheet          in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_recruiting_site_id           in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_posting_impl_class           in     varchar2  default null
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_recruiting_site >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_recruiting_sites_api.delete_recruiting_site
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_recruiting_site
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_recruiting_site_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_recruiting_site >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_recruiting_sites_api.update_recruiting_site
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_recruiting_site
  (p_recruiting_site_id           in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_site_name                    in     varchar2  default hr_api.g_varchar2
  ,p_date_from                    in date default hr_api.g_date
  ,p_date_to                      in date default hr_api.g_date
  ,p_posting_username             in varchar2 default hr_api.g_varchar2
  ,p_posting_password             in varchar2 default hr_api.g_varchar2
  ,p_internal                     in     varchar2  default hr_api.g_varchar2
  ,p_external                     in     varchar2  default hr_api.g_varchar2
  ,p_third_party                  in     varchar2  default hr_api.g_varchar2
  ,p_redirection_url              in     varchar2  default hr_api.g_varchar2
  ,p_posting_url                  in     varchar2  default hr_api.g_varchar2
  ,p_posting_cost                 in     number    default hr_api.g_number
  ,p_posting_cost_period          in     varchar2  default hr_api.g_varchar2
  ,p_posting_cost_currency        in     varchar2  default hr_api.g_varchar2
  ,p_stylesheet                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_posting_impl_class           in     varchar2  default hr_api.g_varchar2
  );
end irc_recruiting_sites_swi;

/
