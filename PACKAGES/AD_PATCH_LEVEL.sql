--------------------------------------------------------
--  DDL for Package AD_PATCH_LEVEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PATCH_LEVEL" AUTHID CURRENT_USER as
/*$Header: adplvls.pls 115.0 2004/04/07 13:10:40 sshivara noship $ */

-- Procedure GET_PATCH_LEVEL (apps_short_name (IN), FP_LEVEL (out))
-- This procedure takes an application_short_name (case insensitive)
-- and passes back the level.

procedure get_patch_level(apps_short_name in         varchar2,
                          fp_level        out nocopy varchar2);



-- Procedure GET_RELEASELEVEL (apps_release_level (out))
-- This procedure passes back the release level.

procedure get_release_level(apps_release_level out nocopy varchar2);


-- Procedure compare releases. Copied from AD_PATCH.compare_versions()
-- Compare passed release_levels.
--
-- Result:
--
-- -1 release_1 < release_2
--  0 release_1 = release_2
--  1 release_1 > release_2
--

procedure compare_release_levels(release_1 in  varchar2,
                                 release_2 in  varchar2,
                                 result    out nocopy number);



-- Procedure compare patch_levels.
--
-- Result:
--
-- -1 patchlevel_1 < patchlevel_2
--  0 patchlevel_1 = patchlevel_2
--  1 patchlevel_1 > patchlevel_2
--


procedure compare_patch_levels(patchlevel_1 in  varchar2,
                                 patchlevel_2 in  varchar2,
                                 result    out nocopy number);

end ad_patch_level;

 

/
