--------------------------------------------------------
--  DDL for Package Body CSD_IB_CHOWN_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_IB_CHOWN_CUHK" as
/* $Header: csdcownb.pls 120.0 2006/02/28 16:18:26 swai noship $ */
--
-- Package name     : CSD_IB_CHOWN_CUHK
-- Purpose          : This package contains custom hooks for changing
--                    installed base owners via depot repair
-- History          :
-- Version       Date       Name        Description
-- 115.0         01/10/06   swai        Created.
--
-- NOTE             :
--

    /*-----------------------------------------------------------------*/
    /* procedure name: get_create_tca_rel_flag                         */
    /* description   : Procedure to determine whether or not a         */
    /*                 tca relationship  should be created between the */
    /*                 new ib owner (subject) and the old ib owner     */
    /*                 (object) when changing IB ownership             */
    /*                 A value of fnd_api.g_true means create the tca  */
    /*                 relationship. Null or any other value (e.g.     */
    /*                 fnd_api.g_false) means do not create the tca    */
    /*                 relationship                                    */
    /*-----------------------------------------------------------------*/
    PROCEDURE get_create_tca_rel_flag
    (
        p_in_param     IN          CREATE_TCA_REL_IN_REC_TYPE,
        x_out_param    OUT NOCOPY  CREATE_TCA_REL_OUT_REC_TYPE
    ) IS
    BEGIN
        x_out_param.return_status := FND_API.G_RET_STS_SUCCESS;
        x_out_param.create_tca_rel_flag := FND_API.G_FALSE;
    END get_create_tca_rel_flag;

    /*-----------------------------------------------------------------*/
    /* procedure name: get_tca_rel_info                                */
    /* description   : Procedure to get the default tca relationship   */
    /*                 type and code in order to create a tca          */
    /*                 relationship between the new ib owner (subject) */
    /*                 and the old ib owner (object)                   */
    /*-----------------------------------------------------------------*/
    PROCEDURE get_tca_rel_info
    (
        p_in_param     IN           TCA_REL_INFO_IN_REC_TYPE,
        x_out_param    OUT NOCOPY   TCA_REL_INFO_OUT_REC_TYPE
    ) IS
    BEGIN
        x_out_param.return_status := FND_API.G_RET_STS_ERROR;
        x_out_param.relationship_type := null;
        x_out_param.relationship_code := null;
    END get_tca_rel_info;

--
END CSD_IB_CHOWN_CUHK;

/
