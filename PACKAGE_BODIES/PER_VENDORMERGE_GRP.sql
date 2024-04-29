--------------------------------------------------------
--  DDL for Package Body PER_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VENDORMERGE_GRP" AS
/* $Header: pevndmrg.pkb 120.0 2006/03/31 05:28:15 bshukla noship $ */
-- Package Variables
--
g_package  varchar2(33) := '  PER_VENDORMERGE_GRP.';
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
  savepoint per_merge_vendor;

  update per_all_assignments_f
  set vendor_id=p_vendor_id
  where vendor_id=p_dup_vendor_id;

  update per_all_assignments_f
  set vendor_site_id=p_vendor_site_id
  where vendor_site_id=p_dup_vendor_site_id;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;
  hr_utility.set_location('Leaving:'|| l_proc, 20);

exception when others then
    rollback to per_merge_vendor;
    FND_MSG_PUB.count_and_get(p_count => p_msg_count,
                              p_data  => p_msg_data);
    p_return_status :=  FND_API.G_RET_STS_ERROR;
    hr_utility.set_location('Leaving:'|| l_proc, 30);


end merge_vendor;

--
END per_vendormerge_grp;

/
