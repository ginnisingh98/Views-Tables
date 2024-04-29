--------------------------------------------------------
--  DDL for Package Body IRC_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_VENDORMERGE_GRP" AS
/* $Header: irvndmrg.pkb 120.1 2006/04/12 05:36:56 gganesan noship $ */
-- Package Variables
--
g_package  varchar2(33) := '  IRC_VENDORMERGE_GRP.';
-- -- --------------------------------------------------------------------- *
-- Name    : merge_vendor
-- --------------------------------------------------------------------- *
procedure merge_vendor
(p_api_version            IN            NUMBER
,p_init_msg_list          IN            VARCHAR2 default FND_API.G_FALSE
,p_commit                 IN            VARCHAR2 default FND_API.G_FALSE
,p_validation_level       IN            NUMBER   default FND_API.G_VALID_LEVEL_FULL
,p_return_status          OUT  NOCOPY   VARCHAR2
,p_msg_count              OUT  NOCOPY   NUMBER
,p_msg_data               OUT  NOCOPY   VARCHAR2
,p_vendor_id              IN            NUMBER
,p_dup_vendor_id          IN            NUMBER
,p_vendor_site_id         IN            NUMBER
,p_dup_vendor_site_id     IN            NUMBER
,p_party_id               IN            NUMBER
,P_dup_party_id           IN            NUMBER
,p_party_site_id          IN            NUMBER
,p_dup_party_site_id      IN            NUMBER
) is
  l_proc                  varchar2(72) := g_package||'merge_vendor';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint irc_merge_vendor;

  update irc_agency_vacancies
  set agency_id=p_vendor_id
  where agency_id=p_dup_vendor_id;

  update irc_notification_preferences
  set agency_id=p_vendor_id
  where agency_id=p_dup_vendor_id;

  update fnd_profile_option_values
  set profile_option_value=to_char(p_vendor_id)
  where profile_option_value=to_char(p_dup_vendor_id)
  and profile_option_id=(select profile_option_id
  from fnd_profile_options
  where profile_option_name='IRC_AGENCY_NAME');

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;
  hr_utility.set_location('Leaving:'|| l_proc, 20);

exception when others then
    rollback to irc_merge_vendor;
    FND_MSG_PUB.count_and_get(p_count => p_msg_count,
                              p_data  => p_msg_data);
    p_return_status :=  FND_API.G_RET_STS_ERROR;
    hr_utility.set_location('Leaving:'|| l_proc, 30);


end merge_vendor;

--
END irc_vendormerge_grp;

/
