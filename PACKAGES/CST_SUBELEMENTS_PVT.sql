--------------------------------------------------------
--  DDL for Package CST_SUBELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_SUBELEMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTVCCYS.pls 115.4 2002/11/11 23:18:55 gwu ship $ */

TYPE nonmatching_rec_type IS RECORD
			( code 	    VARCHAR2(10),
			  ID        NUMBER,
                          source    VARCHAR2(1)
			 );

TYPE nonmatching_tbl_type IS TABLE OF nonmatching_rec_type
index by binary_integer;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   processInterface                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API serves as the wrapper that suitably creates or summarizes   --
--  subelements in the enhanced interorg cost copy program                --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Anitha B       Created                                 --
----------------------------------------------------------------------------
PROCEDURE processInterface (
		p_api_version                   IN      NUMBER,
                p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level              IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

                x_return_status                 OUT NOCOPY     VARCHAR2,
                x_msg_count                     OUT NOCOPY     NUMBER,
                x_msg_data                      OUT NOCOPY     VARCHAR2,

                p_group_id                      IN      NUMBER,
                p_from_organization_id          IN      NUMBER,
                p_to_organization_id            IN      NUMBER,
                p_from_cost_type_id             IN      NUMBER,
                p_to_cost_type_id               IN      NUMBER,
                p_summary_option                IN      NUMBER,
                p_mtl_subelement                IN      NUMBER,
                p_moh_subelement                IN      NUMBER,
                p_res_subelement                IN      NUMBER,
                p_osp_subelement                IN      NUMBER,
                p_ovh_subelement                IN      NUMBER,
                p_conv_type                     IN      VARCHAR2,
                p_exact_copy_flag               IN      VARCHAR2 );


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getNonMatchingSubElements                                            --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API fetches all the non-matching subelements bewteen two        --
--   organizations and returns them  in a PL/SQL table format             --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Anitha B       Created                                 --
----------------------------------------------------------------------------

PROCEDURE    getNonMatchingSubElements (
                            p_api_version                   IN      NUMBER,
                            p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
                            p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level              IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,

                            x_return_status                 OUT NOCOPY     VARCHAR2,
                            x_msg_count                     OUT NOCOPY     NUMBER,
                            x_msg_data                      OUT NOCOPY     VARCHAR2,

                            x_subelement_tbl                OUT NOCOPY     nonmatching_tbl_type,
                            x_department_tbl                OUT NOCOPY     nonmatching_tbl_type,
                            x_activity_tbl                  OUT NOCOPY     nonmatching_tbl_type,
                            x_subelement_count              OUT NOCOPY     NUMBER,
                            x_department_count              OUT NOCOPY     NUMBER,
                            x_activity_count                OUT NOCOPY     NUMBER,

                            p_group_id                      IN      NUMBER,
                            p_from_organization_id          IN      NUMBER ,
                            p_to_organization_id            IN      NUMBER );



----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   createSubElements                                                    --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API creates subelements in an organization. It also creates     --
--   the necessary departments to which the subelements belong as         --
--   required.                                                            --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Hemant Gosain    Created                               --
----------------------------------------------------------------------------

PROCEDURE    createSubElements (
                            p_api_version                   IN      NUMBER,
                            p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
                            p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level              IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,


                            p_subelement_tbl                IN      nonmatching_tbl_type,
                            p_department_tbl                IN      nonmatching_tbl_type,
                            p_activity_tbl                  IN      nonmatching_tbl_type,
                            p_subelement_count              IN      NUMBER,
                            p_department_count              IN      NUMBER,
                            p_activity_count                IN      NUMBER,
                            p_from_organization_id          IN      NUMBER ,
                            p_to_organization_id            IN      NUMBER,
			    p_exact_copy_flag		    IN	    VARCHAR2,
                            x_return_status                 OUT NOCOPY     VARCHAR2,
                            x_msg_count                     OUT NOCOPY     NUMBER,
                            x_msg_data                      OUT NOCOPY     VARCHAR2);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getDeptAccounts                                                      --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API serevs as a client extension for returning department
--   accounts if the organization is WSM enabled.                         --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Hemant Gosain    Created                               --
----------------------------------------------------------------------------

PROCEDURE    getDeptAccounts (
                   p_api_version            IN      NUMBER,
                   p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
                   p_commit                 IN      VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level       IN      NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,
                   p_department_id          IN      NUMBER,
                   p_from_organization_id   IN      NUMBER,
                   p_to_organization_id     IN      NUMBER,
                   x_scrap_account          OUT NOCOPY     NUMBER,
                   x_est_absorption_account OUT NOCOPY     NUMBER,
                   x_return_status          OUT NOCOPY     VARCHAR2,
                   x_msg_count              OUT NOCOPY     NUMBER,
                   x_msg_data               OUT NOCOPY     VARCHAR2) ;




----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getOSPItem                                                           --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API serevs as a client extension for returning OSP item id      --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Hemant Gosain    Created                               --
----------------------------------------------------------------------------

PROCEDURE    getOSPItem (
                   p_api_version            IN      NUMBER,
                   p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
                   p_commit                 IN      VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level       IN      NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,
                   p_resource_id            IN      NUMBER,
                   p_from_organization_id   IN      NUMBER,
                   p_to_organization_id     IN      NUMBER,

                   x_item_id                OUT NOCOPY     NUMBER,
                   x_return_status          OUT NOCOPY     VARCHAR2,
                   x_msg_count              OUT NOCOPY     NUMBER,
                   x_msg_data               OUT NOCOPY     VARCHAR2);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getDefaultActivity                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API serevs as a client extension for returning                  --
--   default activity for a given subelement                              --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Hemant Gosain    Created                               --
----------------------------------------------------------------------------

PROCEDURE    getDefaultActivity (
                   p_api_version            IN      NUMBER,
                   p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
                   p_commit                 IN      VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level       IN      NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,

                   p_resource_id            IN      NUMBER,
                   p_from_organization_id   IN      NUMBER,
                   p_to_organization_id     IN      NUMBER,
                   x_activity_id            OUT NOCOPY     NUMBER,
                   x_return_status          OUT NOCOPY     VARCHAR2,
                   x_msg_count              OUT NOCOPY     NUMBER,
                   x_msg_data               OUT NOCOPY     VARCHAR2) ;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getExpenditureType                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API serevs as a client extension for returning                  --
--   Expenditure Type for a given subelement                              --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Hemant Gosain    Created                               --
----------------------------------------------------------------------------

PROCEDURE    getExpenditureType (
                   p_api_version            IN      NUMBER,
                   p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
                   p_commit                 IN      VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level       IN      NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,

                   p_resource_id            IN      NUMBER,
                   p_from_organization_id   IN      NUMBER,
                   p_to_organization_id     IN      NUMBER,
                   x_expenditure_type       OUT NOCOPY     VARCHAR2,
                   x_return_status          OUT NOCOPY     VARCHAR2,
                   x_msg_count              OUT NOCOPY     NUMBER,
                   x_msg_data               OUT NOCOPY     VARCHAR2) ;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getSubelementAcct                                                    --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API serevs as a client extension for returning                  --
--   Abosorption and rate variance account for a given subelement         --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Hemant Gosain    Created                               --
----------------------------------------------------------------------------

PROCEDURE    getSubelementAcct (
                   p_api_version            IN      NUMBER,
                   p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
                   p_commit                 IN      VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level       IN      NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,

                   p_resource_id            IN      NUMBER,
                   p_from_organization_id   IN      NUMBER,
                   p_to_organization_id     IN      NUMBER,
                   x_absorption_account     OUT NOCOPY     NUMBER,
                   x_rate_variance_account  OUT NOCOPY     NUMBER,
                   x_return_status          OUT NOCOPY     VARCHAR2,
                   x_msg_count              OUT NOCOPY     NUMBER,
                   x_msg_data               OUT NOCOPY     VARCHAR2) ;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   summarizeSubElements                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API summarizes subelements into a single Item Basis type default--
--   subelements per cost element for all non-matching subelements between--
--    two organizations                                                   --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Anirban Dey    Created                                 --
----------------------------------------------------------------------------

PROCEDURE    summarizeSubElements (
                            p_api_version                   IN      NUMBER,
                            p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
                            p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level              IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,

                            x_return_status                 OUT NOCOPY     VARCHAR2,
                            x_msg_count                     OUT NOCOPY     NUMBER,
                            x_msg_data                      OUT NOCOPY     VARCHAR2,

                            p_subelement_tbl                IN      nonmatching_tbl_type,
                            p_subelement_count              IN      NUMBER,
			    p_department_tbl		    IN      nonmatching_tbl_type,
			    p_department_count		    IN	    NUMBER,
			    p_activity_tbl		    IN	    nonmatching_tbl_type,
			    p_activity_count		    IN	    NUMBER,
			    p_summary_option		    IN      NUMBER,
                            p_material_subelement           IN      NUMBER := null,
                            p_moh_subelement                IN      NUMBER := null,
                            p_resource_subelement           IN      NUMBER := null,
                            p_overhead_subelement           IN      NUMBER := null,
                            p_osp_subelement                IN      NUMBER := null,
                            p_from_organization_id          IN      NUMBER ,
                            p_to_organization_id            IN      NUMBER ,
                            p_from_cost_type_id             IN      NUMBER ,
                            p_to_cost_type_id               IN      NUMBER ,
                            p_group_id                      IN      NUMBER ,
                            p_conversion_type               IN      VARCHAR2  );


END;

 

/
