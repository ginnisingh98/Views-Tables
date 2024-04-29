--------------------------------------------------------
--  DDL for Package CSD_IB_CHOWN_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_IB_CHOWN_CUHK" AUTHID CURRENT_USER as
/* $Header: csdcowns.pls 120.0 2006/02/28 16:17:22 swai noship $ */
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

    TYPE CREATE_TCA_REL_IN_REC_TYPE is RECORD
    (
        instance_id            NUMBER,
        new_owner_party_id     NUMBER,
        new_owner_account_id   NUMBER,
        current_owner_party_id NUMBER
    );

    TYPE CREATE_TCA_REL_OUT_REC_TYPE is RECORD
    (
        return_status            VARCHAR2(1),
        create_tca_rel_flag      VARCHAR2(1)
    );

    TYPE TCA_REL_INFO_IN_REC_TYPE is RECORD
    (
        instance_id                NUMBER,
        new_owner_party_id         NUMBER,
        new_owner_account_id       NUMBER,
        current_owner_party_id     NUMBER
    );

    TYPE TCA_REL_INFO_OUT_REC_TYPE is RECORD
    (
        return_status            VARCHAR2(1),
        relationship_type        VARCHAR2(30),
        relationship_code        VARCHAR2(30)
    );

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
    );

    /*-----------------------------------------------------------------*/
    /* procedure name: get_tca_rel_info                                */
    /* description   : Procedure to get the default tca relationship   */
    /*                 type and code in order to create a tca          */
    /*                 relationship between the new ib owner (subject) */
    /*                 and the old ib owner (object)                   */
    /*-----------------------------------------------------------------*/
    PROCEDURE get_tca_rel_info
    (
        p_in_param     IN          TCA_REL_INFO_IN_REC_TYPE,
        x_out_param    OUT NOCOPY   TCA_REL_INFO_OUT_REC_TYPE
    );

--
END CSD_IB_CHOWN_CUHK;
 

/
